{...}: {
  isWorkMachine = true;
  userEmail = "chris.williams@sequencehq.com";

  programs = {
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };
  };
}
