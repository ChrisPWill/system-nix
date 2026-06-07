{omniwmLib}: let
  inherit (omniwmLib) workspace;
in [
  (workspace "AD36F001-C57E-41A5-AC1D-DF5249D007F0" "1" "main" {})
  (workspace "454CECD4-5E9D-4ED1-95D7-979D48817F5F" "2" "main" {})
  (workspace "BEB842B5-E894-4791-9FD1-397C3CDD3538" "3" "main" {})
  (workspace "248AA883-2261-4D45-943C-79C0E46A232B" "4" "main" {})
  (workspace "8B8C45D6-CE9E-41D9-BD50-BE4989D5E3DE" "5" "main" {})
  (workspace "5953F2BF-A378-4266-91B2-287174C4FA4D" "6" "main" {})
  (workspace "A7D5E104-6985-4516-8ED5-07F144F2A33D" "7" "main" {})
  (workspace "0978B19D-5380-492B-B7F3-6A325B390F71" "8" "main" {})
  (workspace "7E95FE7A-D633-4D41-95E0-3D28A466E66E" "9" "main" {})

  # OmniWM raw workspace names are numeric and monitor assignments are
  # semantic. Display names preserve the laptop workspace labels used by the
  # skhd bindings.
  (workspace "E03D84B1-2E74-44FC-96C1-57C6DA132911" "10" "secondary" {
    displayName = "Q";
  })
  (workspace "B6F19E3D-9B42-427D-9C1E-F0E3E6D6C0E3" "11" "secondary" {
    displayName = "W";
  })
  (workspace "D89AF713-3C9A-4D3E-A980-7C8BAEC3F816" "12" "secondary" {
    displayName = "E";
  })
  (workspace "8F1B3D9E-1B13-4F86-BC37-87C7A443E541" "13" "secondary" {
    displayName = "A";
  })
  (workspace "37F8D135-6C7F-42CA-97DD-4759270C4CB3" "14" "secondary" {
    displayName = "S";
  })
  (workspace "5F1B6A6D-C399-43F4-806E-036475FC8DC2" "15" "secondary" {
    displayName = "D";
  })
]
