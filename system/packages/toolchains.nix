{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gcc
    clang-tools
    gopls
    rust-analyzer
    jdt-language-server
    omnisharp-roslyn
    typescript-language-server
    vscode-langservers-extracted
    delve
    netcoredbg
    go
    zig
    dotnet-sdk_10
    php
    php.packages.composer
    luajitPackages.luarocks
    luajitPackages.plenary-nvim
    temurin-bin-25
    cargo
    rustc
    nodejs
    lua
    python311
    python313Packages.pycryptodomex
    python313Packages.influxdb-client
    python313Packages.oracledb
    python314Packages.pmsensor
  ];
}
