# Shared primitives for the repo-history scripts in the parent directory.
#
# Everything here is a projection over `commits`: pull a typed table of commits
# for a window once, then filter, rank, and decorate it. Scripts import this
# with `use (path self "lib/vcs.nu") *`.

# --- Windows ---

# Named periods are durations rather than git's relative expressions ("1 week
# ago") so that a window can be resolved to concrete instants, and an equally
# long preceding window derived from it for period-on-period comparison.
def period-duration [period: string]: nothing -> duration {
    match ($period | str lowercase | str trim) {
        "week" | "last week" => 7day
        "month" | "last month" => 30day
        "quarter" | "last quarter" => 90day
        "year" | "last year" => 365day
        _ => { error make { msg: $"unknown period '($period)': use week | month | quarter | year, or --since <date>" } }
    }
}

# Resolve the reporting window to concrete instants.
#
# `since` and `until` are nullable — hence `any`, as Nushell rejects null for a
# typed parameter — and are parsed by Nushell rather than git, so they must be
# dates it understands ("2026-07-18", "2026-07-18T09:00:00"), not relative
# expressions.
export def "window resolve" [
    period: string          # week | month | quarter | year, used when `since` is null
    --since: any = null     # start of the window; overrides `period`
    --until: any = null     # end of the window; defaults to now
]: nothing -> record<since: datetime, until: datetime> {
    let end = if $until == null { date now } else { $until | into datetime }
    let start = if $since == null { $end - (period-duration $period) } else { $since | into datetime }

    if $start >= $end {
        error make { msg: $"empty window: ($start) is not before ($end)" }
    }

    { since: $start, until: $end }
}

# The equally long window immediately before this one, for comparisons.
export def "window previous" [
    window: record<since: datetime, until: datetime>
]: nothing -> record<since: datetime, until: datetime> {
    { since: ($window.since - ($window.until - $window.since)), until: $window.since }
}

# --- Commits ---

# One row per commit in the window, newest first.
#
# Author identity uses git's mailmap forms (%aN/%aE), so one person committing
# from several addresses collapses to a single author; add a .mailmap to the
# repository being inspected to control the mapping.
#
# The date is the committer date (%cI), which is when the commit landed on the
# trunk. The author date is inherited from the branch's first commit and on a
# squash-merge repo can predate the window that selected the commit, so the two
# must not be mixed: git's --since/--until filter on committer date.
export def commits [
    window: record<since: datetime, until: datetime>
    --repo (-r): path = "."
    --paths: list<string> = []      # git pathspecs; empty means the whole repo
]: nothing -> table {
    let pathspec = if ($paths | is-empty) { [] } else { ["--"] ++ $paths }

    (^git -C $repo log
        --since ($window.since | format date "%Y-%m-%dT%H:%M:%S%z")
        --until ($window.until | format date "%Y-%m-%dT%H:%M:%S%z")
        --pretty="%H%x09%aN%x09%aE%x09%cI%x09%s"
        ...$pathspec)
    | lines
    | where ($it | is-not-empty)
    | split column "\t" sha author email date subject
    | update date { into datetime }
}

# Keep only squash-merged pull requests, exposing the PR number.
#
# A squash merge leaves a single commit whose subject ends in "(#1234)"; commits
# pushed straight to the trunk carry no such suffix and are dropped.
export def with-pr-number []: table -> table {
    $in
    | where subject =~ '\(#\d+\)$'
    | insert pr {|row| $row.subject | parse -r '\(#(?<n>\d+)\)$' | get n.0 | into int }
}

# --- Ranking and rendering ---

# Sort by `column` descending and add dense ranks and shares of the total.
#
# Dense ranking: equal counts share a position and the next distinct count takes
# the following rank, so a three-way tie for first is followed by second.
export def rank-by [column: string]: table -> table {
    let rows = ($in | sort-by {|r| $r | get $column } --reverse)
    let total = ($rows | get $column | math sum)
    let tiers = ($rows | get $column | uniq)

    $rows
    | insert rank {|r| ($tiers | enumerate | where item == ($r | get $column) | get index.0) + 1 }
    | insert share {|r| ((($r | get $column) * 100.0 / $total) | math round --precision 1 | $"($in)%") }
}

# Add a `move` column comparing each row's rank against a previously ranked
# table, matched on `key`. Rows absent from `previous` are new entries.
export def movement [previous: table, key: string]: table -> table {
    $in | insert move {|r|
        let was = (
            $previous
            | where {|p| ($p | get $key) == ($r | get $key) }
            | get rank --optional
            | get 0 --optional
        )

        if $was == null {
            "new"
        } else if $was > $r.rank {
            $"↑($was - $r.rank)"
        } else if $was < $r.rank {
            $"↓($r.rank - $was)"
        } else {
            "–"
        }
    }
}

# Proportional bar, scaled so `max` fills `width`. Any non-zero value gets at
# least one block, so a contributor never renders as absent.
export def bar [value: int, max: int, width: int = 12]: nothing -> string {
    if $max <= 0 or $value <= 0 { return "" }

    let filled = ([((($value * $width) / $max) | math round | into int), 1] | math max)
    "" | fill --character "█" --width $filled
}

# Trend glyphs for a set of timestamps, bucketed into equal slices of the
# window. Buckets are window-relative rather than data-relative so that glyphs
# line up across rows, and heights are scaled to each row's own peak so a quiet
# contributor's shape stays readable next to a busy one.
export def sparkline [
    dates: list<datetime>
    window: record<since: datetime, until: datetime>
    buckets: int = 8
]: nothing -> string {
    let glyphs = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"]
    let span = (($window.until - $window.since) | into int)

    if $span <= 0 or ($dates | is-empty) { return ("" | fill --character " " --width $buckets) }

    let slots = $dates | each {|d|
        let slot = (((($d - $window.since) | into int) * $buckets / $span) | math floor | into int)
        [([$slot, 0] | math max), ($buckets - 1)] | math min
    }

    let histogram = (0..<$buckets | each {|b| $slots | where {|s| $s == $b } | length })
    let peak = ($histogram | math max)

    $histogram | each {|count|
        if $count == 0 {
            " "
        } else {
            $glyphs | get ((($count * 7 / $peak) | math round | into int))
        }
    } | str join
}
