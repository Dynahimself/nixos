{ pkgs }:

pkgs.writeShellScriptBin "cshub" ''
  exec ${pkgs.python3}/bin/python3 ${./cshub.py} "$@"
''
