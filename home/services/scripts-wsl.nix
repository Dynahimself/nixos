{ pkgs, ... }:

let
  cshubPkg = import ../../tools/cshub { inherit pkgs; };
  fleetPkg = pkgs.writeShellScriptBin "fleet" (
    builtins.replaceStrings [ "#!/usr/bin/env bash\n" ] [ "" ] (
      builtins.readFile ../../dotfiles/scripts/fleet
    )
  );
  fleetClipPkg = pkgs.writeShellScriptBin "fleet-clip" (
    builtins.replaceStrings [ "#!/usr/bin/env bash\n" ] [ "" ] (
      builtins.readFile ../../dotfiles/scripts/fleet-clip
    )
  );
  motionCoachPkg = pkgs.writeShellScriptBin "motion-coach" (
    builtins.replaceStrings [ "#!/usr/bin/env bash\n" ] [ "" ] (
      builtins.readFile ../../dotfiles/scripts/motion-coach
    )
  );
in
{
  home.packages = [
    cshubPkg
    fleetPkg
    fleetClipPkg
    motionCoachPkg
  ];
}
