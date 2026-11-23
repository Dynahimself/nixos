{
  DisableAppUpdate = true;
  DisableTelemetry = true;
  DisableFirefoxStudies = true;
  DisablePocket = true;
  DontCheckDefaultBrowser = true;
  NoDefaultBookmarks = true;
  AutofillAddressEnabled = false;
  AutofillCreditCardEnabled = false;

  EnableTrackingProtection = {
    Value = true;
    Locked = false;
    Cryptomining = true;
    Fingerprinting = true;
  };

  FirefoxHome = {
    Search = true;
    TopSites = true;
    SponsoredTopSites = false;
    Highlights = false;
    Pocket = false;
    SponsoredPocket = false;
    Snippets = false;
  };

  UserMessaging = {
    ExtensionRecommendations = false;
    FeatureRecommendations = false;
    UrlbarInterventions = false;
    SkipOnboarding = true;
    MoreFromMozilla = false;
  };

  ExtensionSettings = {
    "*" = {
      installation_mode = "allowed";
    };
    "uBlock0@raymondhill.net" = {
      installation_mode = "normal_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
    };
    "sponsorBlocker@ajay.app" = {
      installation_mode = "normal_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
    };
    "addon@darkreader.org" = {
      installation_mode = "normal_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
    };
    "vimium-c@gdh1995.cn" = {
      installation_mode = "normal_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-c/latest.xpi";
    };
    "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
      installation_mode = "normal_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
    };
    "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" = {
      installation_mode = "normal_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/violentmonkey/latest.xpi";
    };
    "languagetool-webextension@languagetool.org" = {
      installation_mode = "normal_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/languagetool/latest.xpi";
    };
    "{bbb880ce-43c9-47ae-b746-c3e0096c5b76}" = {
      installation_mode = "normal_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/catppuccin-web-file-icons/latest.xpi";
    };
    "copyplaintext@eros.man" = {
      installation_mode = "normal_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/copy-plaintext/latest.xpi";
    };
    "reddit-url-redirector@kichkoupi.com" = {
      installation_mode = "normal_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/reddituntranslate/latest.xpi";
    };
    "savewebpas@jeffersonscher.com" = {
      installation_mode = "normal_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/save-webp-as-png-or-jpeg/latest.xpi";
    };
  };

  SearchEngines = {
    Default = "DuckDuckGo";
    Add = [
      {
        Name = "NixOS Packages";
        URLTemplate = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
        Method = "GET";
        Alias = "@nix";
      }
      {
        Name = "NixOS Options";
        URLTemplate = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
        Method = "GET";
        Alias = "@no";
      }
      {
        Name = "Home Manager Options";
        URLTemplate = "https://home-manager-options.extranix.com/?query={searchTerms}";
        Method = "GET";
        Alias = "@hm";
      }
      {
        Name = "Nixvim Options";
        URLTemplate = "https://nix-community.github.io/nixvim/?search={searchTerms}";
        Method = "GET";
        Alias = "@nv";
      }
      {
        Name = "GitHub";
        URLTemplate = "https://github.com/search?q={searchTerms}";
        Method = "GET";
        Alias = "@gh";
      }
      {
        Name = "MDN Web Docs";
        URLTemplate = "https://developer.mozilla.org/en-US/search?q={searchTerms}";
        Method = "GET";
        Alias = "@mdn";
      }
      {
        Name = ".NET / C# Docs";
        URLTemplate = "https://learn.microsoft.com/en-us/search/?terms={searchTerms}";
        Method = "GET";
        Alias = "@cs";
      }
      {
        Name = "Arch Wiki";
        URLTemplate = "https://wiki.archlinux.org/index.php?search={searchTerms}";
        Method = "GET";
        Alias = "@aw";
      }
      {
        Name = "YouTube";
        URLTemplate = "https://www.youtube.com/results?search_query={searchTerms}";
        Method = "GET";
        Alias = "@yt";
      }
      {
        Name = "Reddit";
        URLTemplate = "https://www.reddit.com/search/?q={searchTerms}";
        Method = "GET";
        Alias = "@rd";
      }
    ];
  };
}
