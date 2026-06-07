{lib}: rec {
  colorFromHex = color: let
    hex = lib.removePrefix "#" color;
    channel = offset: (lib.fromHexString (builtins.substring offset 2 hex)) / 255.0;
  in {
    red = channel 0;
    green = channel 2;
    blue = channel 4;
    alpha = 1.0;
  };

  appRule = id: bundleId: attrs:
    {
      inherit id bundleId;
    }
    // attrs;

  workspace = id: name: monitorAssignment: attrs:
    {
      inherit id name;
      layoutType = "niri";
      monitorAssignment.type = monitorAssignment;
    }
    // attrs;
}
