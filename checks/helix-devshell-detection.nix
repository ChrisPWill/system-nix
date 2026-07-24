{
  perSystem,
  pkgs,
  ...
}: let
  languageTooling = (import ../lib {}).languageTooling {inherit perSystem pkgs;};
  languages = (pkgs.formats.toml {}).generate "languages.toml" {
    language = [
      {
        name = "nix";
        language-servers = ["nixd"];
        formatter.command = "alejandra";
      }
      {
        name = "python";
        language-servers = ["basedpyright" "ruff"];
        formatter = {
          command = "ruff";
          args = ["format" "-"];
        };
      }
    ];
    language-server = {
      nixd.command = "nixd";
      basedpyright = {
        command = "basedpyright-langserver";
        args = ["--stdio"];
      };
      ruff = {
        command = "ruff";
        args = ["server"];
      };
    };
  };
in
  pkgs.runCommand "helix-devshell-detection-check" {
    nativeBuildInputs =
      [pkgs.helix]
      ++ languageTooling.packagesFor [
        "nix"
        "python"
      ];
  } ''
    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$HOME/.config"
    mkdir -p "$XDG_CONFIG_HOME/helix"
    cp ${languages} "$XDG_CONFIG_HOME/helix/languages.toml"

    hx --health nix > nix-health.txt
    grep -F '${pkgs.nixd}/bin/nixd' nix-health.txt
    grep -F '${pkgs.alejandra}/bin/alejandra' nix-health.txt

    hx --health python > python-health.txt
    grep -F '${pkgs.basedpyright}/bin/basedpyright-langserver' python-health.txt
    grep -F '${pkgs.ruff}/bin/ruff' python-health.txt

    mkdir -p "$out"
    cp nix-health.txt python-health.txt "$out/"
  ''
