_: {
  programs.fish.shellAbbrs = {
    zip = {
      expansion = "ouch compress %<files> output.zip";
      setCursor = true;
    };
    unzip = "ouch decompress";
    unzipToDir = {
      expansion = "ouch decompress -d %<dir> X.zip";
      setCursor = true;
    };
  };
}
