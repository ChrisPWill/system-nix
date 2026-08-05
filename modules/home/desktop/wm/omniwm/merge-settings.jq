def ids($items):
  [$items[]?.id];

def patch_by_id($live; $patches):
  reduce $patches[]? as $patch (
    $live;
    if any(.[]; .id == $patch.id) then
      map(if .id == $patch.id then . * $patch else . end)
    else
      . + [$patch]
    end
  );

def replace_managed_by_id($live; $managed; $previous_ids):
  (ids($managed) + $previous_ids | unique) as $managed_ids
  | [$live[]? | select(.id as $id | $managed_ids | index($id) | not)] + $managed;

$policy_file[0] as $policy
| $previous_managed_ids_file[0] as $previous_managed_ids
| ($policy | del(.appRules, .hotkeys, .workspaces)) as $table_policy
| . * $table_policy
| .hotkeys = patch_by_id((.hotkeys // []); ($policy.hotkeys // []))
| .appRules = replace_managed_by_id(
    (.appRules // []);
    ($policy.appRules // []);
    ($previous_managed_ids.appRules // [])
  )
| .workspaces = $policy.workspaces
