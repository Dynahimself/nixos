{ config, lib, ... }:

let
  dot = p: config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/${p}";
  profileName = "dynas";
in
{
  home.file.".zen/profiles.ini".text = ''
    [General]
    StartWithLastProfile=1
    Version=2

    [Profile0]
    Name=default
    IsRelative=1
    Path=${profileName}
    Default=1
  '';

  home.file.".zen/${profileName}/user.js".source = dot "zen/user.js";
  home.file.".zen/${profileName}/chrome/userChrome.css".source = dot "zen/chrome/userChrome.css";
  home.file.".zen/${profileName}/chrome/userContent.css".source = dot "zen/chrome/userContent.css";
  home.file.".zen/${profileName}/chrome/modules".source = dot "zen/chrome/modules";
  home.file.".zen/${profileName}/chrome/content".source = dot "zen/chrome/content";
  home.file.".zen/${profileName}/chrome/assets".source = dot "zen/chrome/assets";
  home.file.".zen/${profileName}/chrome/zen-logo-mocha.svg".source = dot "zen/chrome/assets/zen-logo-mocha.svg";
  home.file.".zen/${profileName}/chrome/accent.css".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.cache/mocha-theme/zen-accent.css";

  home.activation.ensureZenMochaAccent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cache_dir="$HOME/.cache/mocha-theme"
    mkdir -p "$cache_dir"
    if [ ! -f "$cache_dir/zen-accent.css" ]; then
      cat > "$cache_dir/zen-accent.css" <<'CSS'
:root,
:host(:is(.anonymous-content-host, notification-message)) {
  --mocha-accent: #cba6f7;
  --mocha-accent-alt: #89b4fa;
  --mocha-accent-rgb: 203, 166, 247;
  --mocha-accent-alt-rgb: 137, 180, 250;
  --mocha-accent-soft: rgba(203, 166, 247, 0.22);
  --mocha-accent-glow: rgba(203, 166, 247, 0.40);
}
CSS
    fi
  '';
}
