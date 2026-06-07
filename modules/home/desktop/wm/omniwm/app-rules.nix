{omniwmLib}: let
  inherit (omniwmLib) appRule;
in
  # Keep OmniWM's useful built-in sizing defaults, then layer local float rules
  # for popups and transient utility windows.
  [
    (appRule "6A31F08A-4051-4354-B439-42F4C71894A3" "com.openai.codex" {
      minHeight = 600.0;
      minWidth = 800.0;
    })
    (appRule "4BA546DA-2875-4BEF-B13F-1539E833B1A0" "com.eltima.cmd1.pro.mas" {
      minHeight = 550.0;
      minWidth = 950.0;
    })
    (appRule "486CEFA6-69AA-4A3C-AF27-BCD38F4F138B" "com.google.Chrome" {
      minHeight = 375.0;
      minWidth = 500.0;
    })
    (appRule "979F05F4-FFA2-4EDD-B23F-08A9944C759F" "dev.zed.Zed" {
      minHeight = 240.0;
      minWidth = 360.0;
    })
    (appRule "81426D13-C1A5-475E-AFBC-00BBA05042D0" "com.apple.Safari" {
      minHeight = 220.0;
      minWidth = 574.0;
    })
    (appRule "1CF39647-F30D-4E76-9686-79B551F1B094" "app.zen-browser.zen" {
      minHeight = 495.0;
      minWidth = 500.0;
    })
    (appRule "005C00D3-F665-47F8-BDAE-D80790E9E46B" "org.mozilla.firefox" {
      minHeight = 120.0;
      minWidth = 500.0;
    })
    (appRule "C21156B1-0224-4998-97E3-8F4FA65B9F3B" "company.thebrowser.dia" {
      minHeight = 420.0;
      minWidth = 500.0;
    })
    (appRule "2DE9390B-0DB4-4D0C-9ABA-06F76F1D4EA9" "com.spotify.client" {
      minHeight = 600.0;
      minWidth = 800.0;
    })
    (appRule "AF752D95-8497-4844-BE20-4C93E73BAEF2" "com.hnc.Discord" {
      minHeight = 500.0;
      minWidth = 800.0;
    })
    (appRule "7876C9EF-437E-4D4F-9C27-B1B02F4AABCE" "com.mitchellh.ghostty" {
      minHeight = 48.0;
      minWidth = 90.0;
    })
    (appRule "8ECAB78B-BCDD-4245-BC25-1609A49B1C86" "com.microsoft.Outlook" {
      minHeight = 650.0;
      minWidth = 930.0;
    })
    (appRule "552FB77D-BF0E-4737-90A6-B5BC6986C579" "com.apple.MobileSMS" {
      minHeight = 320.0;
      minWidth = 660.0;
    })
    (appRule "1C64F561-8A2C-43B4-8D7D-3E11D5C7F931" "com.apple.systempreferences" {
      layout = "float";
      minHeight = 650.0;
      minWidth = 900.0;
    })
    (appRule "0CF3018F-7306-4095-9A02-FB5A98F869F7" "com.apple.finder" {
      layout = "float";
      titleSubstring = "Preferences";
    })
    (appRule "A58E2186-F260-4EB5-86A1-B83F4251D25B" "com.apple.calculator" {
      layout = "float";
      minHeight = 420.0;
      minWidth = 320.0;
    })
    (appRule "F2C9B841-8B84-4F8D-9828-42DAB5E41443" "com.apple.ActivityMonitor" {
      layout = "float";
      minHeight = 520.0;
      minWidth = 700.0;
    })
    (appRule "7E60F6F8-4357-4C90-9F49-56A6585EA291" "com.raycast.macos" {
      layout = "float";
      minHeight = 420.0;
      minWidth = 600.0;
    })
    (appRule "2E4D3910-895A-49D8-8E7F-74782A55058B" "com.mitchellh.ghostty" {
      layout = "float";
      minHeight = 600.0;
      minWidth = 900.0;
      titleSubstring = "ghostty-floating";
    })
    (appRule "F1663566-B510-4D23-A79E-D2D9FAD6F071" "com.mitchellh.ghostty" {
      layout = "float";
      minHeight = 240.0;
      minWidth = 700.0;
      titleSubstring = "quick-capture";
    })
    (appRule "180E94E1-4EE3-4B90-84D0-7CB21A43C730" "md.obsidian" {
      minHeight = 600.0;
      minWidth = 800.0;
    })
    (appRule "D383F065-A332-428C-9E11-20915C21F6D2" "com.electron.logseq" {
      minHeight = 600.0;
      minWidth = 800.0;
    })
  ]
