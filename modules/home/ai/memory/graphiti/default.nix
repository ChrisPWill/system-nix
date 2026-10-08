{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.graphiti;

  # Pinned by digest so a flake update never silently changes the schema of
  # stored data; bump deliberately after reading upstream release notes.
  image = "zepai/knowledge-graph-mcp:1.1.0@sha256:a2536b6d59b4afb359a13aeaa4a9d2f4db195af14231168efda6a3d166228956";

  project = "graphiti";
  mcpUrl = "http://127.0.0.1:${toString cfg.port}/mcp/";
  dockerHost = "unix://${config.home.homeDirectory}/.colima/default/docker.sock";

  # Colima only shares $HOME with its VM, so bind-mount sources must live
  # there; a /nix/store path would appear as an empty directory in the container.
  mountedConfig = "${config.xdg.dataHome}/graphiti/config.yaml";
  mountedQueueService = "${config.xdg.dataHome}/graphiti/queue_service.py";

  logFile = "${config.home.homeDirectory}/Library/Logs/graphiti.launchd.log";

  composeFile = (pkgs.formats.yaml {}).generate "graphiti-compose.yaml" {
    name = project;
    services.graphiti = {
      inherit image;
      environment = {
        CONFIG_PATH = "/app/mcp/config/config.yaml";
        MODEL_NAME = cfg.llmModel;
        EMBEDDER_MODEL = cfg.embedder.model;
        EMBEDDER_DIMENSIONS = toString cfg.embedder.dimensions;
        # host.docker.internal reaches the host's loopback through Colima, so
        # Ollama never has to listen beyond 127.0.0.1.
        OPENAI_API_URL = "http://host.docker.internal:11434/v1";
        # Graphiti refuses to start without a key; Ollama ignores it.
        OPENAI_API_KEY = "ollama";
        GRAPHITI_GROUP_ID = cfg.defaultGroupId;
        # Caps parallel LLM and database calls within one episode. It does not
        # stop episodes for different groups overlapping; ./queue_service.py
        # serialises those.
        SEMAPHORE_LIMIT = toString cfg.concurrency;
        GRAPHITI_TELEMETRY_ENABLED = "false";
        BROWSER = "0";
      };
      # Shares the Colima VM with project service stacks; a cap means memory
      # pressure kills Graphiti (which launchd restarts) rather than, say, a
      # local Postgres. Observed use is ~600MB during ingestion.
      mem_limit = "2g";
      extra_hosts = ["host.docker.internal:host-gateway"];
      ports = ["127.0.0.1:${toString cfg.port}:8000"];
      volumes = [
        "${mountedConfig}:/app/mcp/config/config.yaml:ro"
        "${mountedQueueService}:/app/mcp/src/services/queue_service.py:ro"
        "${cfg.dataDir}:/var/lib/falkordb/data"
      ];
    };
  };

  # Keeps compose attached so launchd owns the lifecycle: stopping the agent
  # stops the container, and there is no `restart:` policy to fight it.
  #
  # The image daemonises FalkorDB (Redis) with default snapshotting and only
  # forwards SIGTERM to the MCP server, so Redis is killed without a final
  # save. Low-volume, curated writes could then sit unsaved for up to an hour.
  # Hence the tighter snapshot interval and the explicit SAVE before stopping.
  runGraphiti = pkgs.writeShellApplication {
    name = "graphiti-run";
    runtimeInputs = [pkgs.docker-compose pkgs.curl pkgs.coreutils];
    runtimeEnv.DOCKER_HOST = dockerHost;
    text = ''
      compose() { docker-compose -f ${composeFile} "$@"; }
      redis() { compose exec -T graphiti redis-cli "$@"; }

      # Colima's agent starts at the same login, so the socket may not exist yet.
      until curl -fsS --unix-socket "''${DOCKER_HOST#unix://}" http://docker/_ping >/dev/null 2>&1; do
        sleep 2
      done
      mkdir -p ${lib.escapeShellArg cfg.dataDir}
      install -D -m 0644 ${./config.yaml} ${lib.escapeShellArg mountedConfig}
      install -D -m 0644 ${./queue_service.py} ${lib.escapeShellArg mountedQueueService}

      # shellcheck disable=SC2329 # invoked via trap
      shutdown() {
        redis SAVE >/dev/null || echo "graphiti: final FalkorDB save failed" >&2
        compose stop
        exit 0
      }
      trap shutdown TERM INT

      compose up --remove-orphans &
      up_pid=$!

      until redis PING >/dev/null 2>&1; do
        kill -0 "$up_pid" 2>/dev/null || { wait "$up_pid"; exit $?; }
        sleep 2
      done
      redis CONFIG SET save "60 1" >/dev/null

      # Reaching here means the container stopped without our shutdown trap
      # (e.g. an OOM kill). `compose up` still exits 0 in that case, and
      # launchd only restarts on failure, so report it as one.
      status=0
      wait "$up_pid" || status=$?
      echo "graphiti: container exited unexpectedly (compose status $status)" >&2
      exit 1
    '';
  };

  # add_memory returns before extraction runs, so an episode that fails
  # (typically an LLM answer that doesn't validate) is discarded without the
  # saving agent ever finding out. The log is the only record of it.
  graphitiStatus = pkgs.writeShellApplication {
    name = "graphiti-status";
    runtimeInputs = [pkgs.docker-compose pkgs.curl pkgs.gawk pkgs.gnused];
    runtimeEnv.DOCKER_HOST = dockerHost;
    text = ''
      echo "== health (${mcpUrl})"
      curl -fsS --max-time 5 http://127.0.0.1:${toString cfg.port}/health && echo || echo "unreachable"
      echo "== container"
      docker-compose -f ${composeFile} ps -a
      echo "== ollama models loaded"
      curl -fsS --max-time 5 http://127.0.0.1:11434/api/ps || echo "ollama unreachable"
      echo
      echo "== dropped episodes since container start (UTC)"
      dropped=$(
        awk '/Starting FalkorDB\.\.\./ { n = 0 } /Failed to process episode/ { lines[n++] = $0 }
             END { for (i = 0; i < n; i++) print lines[i] }' ${lib.escapeShellArg logFile} 2>/dev/null |
          sed -E 's/.*\| ([0-9-]+ [0-9:]+) - .* for group ([^:]+): (.*)/\1  \2  \3/'
      )
      if [ -n "$dropped" ]; then
        echo "$dropped"
        echo "$(grep -c . <<<"$dropped") dropped; re-save them, since add_memory reported success"
      else
        echo "none"
      fi
      echo
      echo "logs: ${logFile}"
    '';
  };

  # The MCP server's get_episodes reads whichever graph the shared driver last
  # pointed at, so FalkorDB is queried directly. FalkorDB keeps each group in
  # a graph of the same name, so a mismatch means an episode was misfiled.
  graphitiEpisodes = pkgs.writeShellApplication {
    name = "graphiti-episodes";
    runtimeInputs = [pkgs.docker-compose pkgs.jq];
    runtimeEnv.DOCKER_HOST = dockerHost;
    text = ''
      usage() { echo "usage: graphiti-episodes [--content] [graph]" >&2; }
      redis() { docker-compose -f ${composeFile} exec -T graphiti redis-cli "$@"; }

      content=false
      graphs=()
      for arg in "$@"; do
        case "$arg" in
          --content) content=true ;;
          -h | --help) usage; exit 0 ;;
          -*) usage; exit 2 ;;
          *) graphs+=("$arg") ;;
        esac
      done

      mapfile -t existing < <(redis GRAPH.LIST)
      if [ ''${#graphs[@]} -eq 0 ]; then
        graphs=("''${existing[@]}")
      fi

      query="MATCH (e:Episodic) RETURN e.group_id, e.name, e.created_at"
      if $content; then query+=", e.content"; fi
      query+=" ORDER BY e.created_at"

      if [ -t 1 ]; then flag=$'\e[1;31m'; reset=$'\e[0m'; else flag=""; reset=""; fi

      misfiled=0
      for graph in "''${graphs[@]}"; do
        echo "== $graph"
        if ! printf '%s\n' "''${existing[@]}" | grep -qxF -- "$graph"; then
          echo "no such graph"
          continue
        fi
        rows=$(redis --json GRAPH.QUERY "$graph" "$query" | jq -c '.[1][]')
        [ -n "$rows" ] || { echo "(no episodes)"; continue; }
        while IFS= read -r row; do
          group=$(jq -r '.[0]' <<<"$row")
          line=$(jq -r '"\(.[2])  \(.[1])"' <<<"$row")
          if [ "$group" != "$graph" ]; then
            misfiled=$((misfiled + 1))
            echo "''${flag}$line  [MISFILED: group_id $group]''${reset}"
          else
            echo "$line"
          fi
          if $content; then jq -r '.[3]' <<<"$row" | sed 's/^/    /'; echo; fi
        done <<<"$rows"
      done

      if [ "$misfiled" -gt 0 ]; then
        echo
        echo "''${flag}$misfiled episode(s) stored in a graph that doesn't match their group_id''${reset}"
      fi
    '';
  };
in {
  options.services.graphiti = {
    enable = lib.mkEnableOption "Graphiti knowledge-graph memory shared by coding agents over MCP";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "Loopback port for the MCP HTTP endpoint.";
    };

    llmModel = lib.mkOption {
      type = lib.types.str;
      # MoE: ~30B-class extraction quality with only ~3B active parameters, so
      # ingestion stays fast. The instruct (non-thinking) variant keeps
      # <think> blocks out of the JSON Graphiti has to parse.
      default = "qwen3:30b-a3b-instruct-2507-q4_K_M";
      description = "Ollama model used for entity extraction, deduplication and fact invalidation.";
    };

    embedder = {
      model = lib.mkOption {
        type = lib.types.str;
        default = "nomic-embed-text";
        description = ''
          Ollama embedding model. Changing it (or its dimensions) invalidates
          every stored vector, so the graph must be rebuilt afterwards.
        '';
      };
      dimensions = lib.mkOption {
        type = lib.types.int;
        default = 768;
        description = "Output dimensions of the embedding model.";
      };
    };

    defaultGroupId = lib.mkOption {
      type = lib.types.str;
      default =
        if config.isWorkMachine
        then "sequence-platform"
        else "personal-engineering";
      description = "Graph partition used when an agent does not pass a group_id.";
    };

    concurrency = lib.mkOption {
      type = lib.types.ints.positive;
      # Ollama serves one request at a time, so parallel calls only queue
      # there and risk timing out.
      default = 1;
      description = ''
        Parallel LLM and database calls within one episode (Graphiti's
        SEMAPHORE_LIMIT). Episodes themselves always run one at a time.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.dataHome}/graphiti/falkordb";
      description = "Host directory holding FalkorDB's persisted graph.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        # Linux needs a different route from the container to a loopback-only
        # Ollama (no Colima host forwarding), plus a systemd unit. Deferred
        # until a Linux host actually wants this.
        assertion = pkgs.stdenv.hostPlatform.isDarwin;
        message = "services.graphiti currently supports macOS (Colima) only.";
      }
    ];

    services.local-ollama = {
      enable = true;
      models = [cfg.llmModel cfg.embedder.model];
      # Extraction prompts carry existing entities alongside the episode, so
      # they outgrow Ollama's default window quickly.
      contextLength = lib.mkDefault 16384;
      # Frees ~19GB of unified memory between bursts of ingestion; reloading
      # is only reads, and usually served from the page cache anyway.
      keepAlive = lib.mkDefault "10m";
    };

    home.packages = [graphitiStatus graphitiEpisodes];

    launchd.agents.graphiti = {
      enable = true;
      config = {
        ProgramArguments = [(lib.getExe runGraphiti)];
        RunAtLoad = true;
        KeepAlive = {
          SuccessfulExit = false;
        };
        EnvironmentVariables.HOME = config.home.homeDirectory;
        StandardOutPath = logFile;
        StandardErrorPath = logFile;
      };
    };

    programs.mcp = {
      enable = true;
      servers.graphiti.url = mcpUrl;
    };
    programs.claude-code.enableMcpIntegration = true;

    # Not programs.codex.enableMcpIntegration: that makes Home Manager own
    # ~/.codex/config.toml, which Codex itself keeps writing to (project trust,
    # hook hashes, plugins). Registering through Codex's own CLI edits just this
    # entry. The guard matters: every `add` re-serialises the whole
    # [mcp_servers] table, so it should only run when the entry is missing or stale.
    home.activation.registerGraphitiWithCodex = lib.mkIf config.programs.codex.enable (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        codex=${lib.getExe config.programs.codex.package}
        current=$($codex mcp get graphiti --json 2>/dev/null | ${lib.getExe pkgs.jq} -r '.transport.url // empty' || true)
        if [ "$current" != ${lib.escapeShellArg mcpUrl} ]; then
          run $codex mcp add graphiti --url ${lib.escapeShellArg mcpUrl}
        fi
      ''
    );
  };
}
