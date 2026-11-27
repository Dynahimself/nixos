// Dyna's Zen Browser 1.24.3b configuration (Catppuccin Mocha + Smoothfox + Fastfox)

// === Stylesheets & Theme ===
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("svg.context-properties.content.enabled", true);
user_pref("layout.css.has-selector.enabled", true);
user_pref("browser.tabs.drawInTitlebar", true);
user_pref("browser.compactmode.show", true);
user_pref("ui.systemUsesDarkTheme", 1);
user_pref("layout.css.prefers-color-scheme.content-override", 0);
user_pref("zen.view.window.scheme", 0);
user_pref("zen.theme.content-element-separation", 6);
user_pref("zen.theme.essentials-favicon-bg", true);
user_pref("zen.theme.styled-status-panel", true);
user_pref("zen.view.enable-loading-indicator", true);

// === Zen 1.24.3b Ergonomics ===
user_pref("zen.view.compact", false);
user_pref("zen.view.compact.hide-tabbar", true);
user_pref("zen.view.compact.hide-toolbar", false);
user_pref("zen.view.compact.animate-sidebar", true);
user_pref("zen.view.compact.show-sidebar-and-toolbar-on-hover", true);
user_pref("zen.view.compact.sidebar-keep-hover.duration", 200);
user_pref("zen.view.compact.show-background-tab-toast", true);
user_pref("zen.view.use-single-toolbar", true);
user_pref("zen.view.borderless-fullscreen", true);
user_pref("zen.view.grey-out-inactive-windows", true);

user_pref("zen.urlbar.behavior", "floating-on-type");
user_pref("zen.urlbar.replace-newtab", true);
user_pref("zen.urlbar.suggestions.quick-actions", true);
user_pref("zen.urlbar.show-sponsored", false);
user_pref("zen.urlbar.single-toolbar-show-copy-url", true);

user_pref("zen.glance.enabled", true);
user_pref("zen.glance.activation-method", "alt");
user_pref("zen.glance.animation-duration", 220);
user_pref("zen.glance.enable-contextmenu-search", true);

user_pref("zen.splitView.enable-drag-over-split", true);
user_pref("zen.splitView.enable-tab-click-split", true);
user_pref("zen.splitView.enable-tab-drop", true);

user_pref("zen.tabs.select-recently-used-on-close", true);
user_pref("zen.tabs.rename-tabs", true);
user_pref("zen.tabs.essentials.max", 12);
user_pref("zen.pinned-tab-manager.close-shortcut-behavior", "reset-unload-switch");

user_pref("zen.workspaces.wrap-around-navigation", true);
user_pref("zen.workspaces.switch-animation-duration", 180);
user_pref("zen.workspaces.continue-where-left-off", true);
user_pref("zen.folders.search.enabled", true);
user_pref("zen.mediacontrols.enabled", true);
user_pref("zen.welcome-screen.seen", true);
user_pref("zen.updates.show-update-notification", false);

// === Startup, Tabs, UX & Preserved User Choices ===
user_pref("browser.startup.homepage", "http://100.68.54.112:8210");
user_pref("browser.startup.page", 3);
user_pref("browser.tabs.closeWindowWithLastTab", false);
user_pref("browser.ctrlTab.sortByRecentlyUsed", true);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.bookmarks.openInTabClosesMenu", false);
user_pref("browser.tabs.hoverPreview.enabled", true);
user_pref("browser.tabs.hoverPreview.showThumbnails", true);
user_pref("findbar.highlightAll", true);
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("widget.use-xdg-desktop-portal.mime-handler", 1);

user_pref("layout.spellcheckDefault", 0);
user_pref("media.autoplay.default", 0);
user_pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);

// === 240Hz / 144Hz GPU, WebRender, VA-API & Smoothfox Physics ===
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.precache-shaders", true);
user_pref("gfx.webrender.compositor", false);
user_pref("gfx.canvas.accelerated.cache-items", 4096);
user_pref("gfx.canvas.accelerated.cache-size", 512);
user_pref("gfx.content.skia-font-cache-size", 20);

user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("media.av1.enabled", true);
user_pref("media.rdd-ffmpeg.enabled", true);

user_pref("general.smoothScroll", true);
user_pref("general.smoothScroll.msdPhysics.enabled", false);
user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 120);
user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 1250);
user_pref("general.smoothScroll.msdPhysics.regularSpringConstant", 1000);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 12);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio", "1.3");
user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 2000);
user_pref("general.smoothScroll.currentVelocityWeighting", "0.25");
user_pref("general.smoothScroll.stopDecelerationWeighting", "0.4");
user_pref("mousewheel.default.delta_multiplier_y", 100);
user_pref("apz.overscroll.enabled", false);

// === Fastfox Network & Memory Hygiene ===
user_pref("browser.cache.jsbc_compression_level", 3);
user_pref("browser.sessionstore.interval", 30000);
user_pref("browser.sessionhistory.max_total_viewers", 4);
user_pref("network.buffer.cache.size", 262144);
user_pref("network.buffer.cache.count", 128);
user_pref("network.http.max-connections", 1800);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5);
user_pref("network.http.pacing.requests.enabled", false);
user_pref("network.dnsCacheExpiration", 3600);
user_pref("network.ssl_tokens_cache_capacity", 10240);
user_pref("network.http.http3.enable", true);
user_pref("image.mem.decode_bytes_at_a_time", 32768);
user_pref("content.notify.interval", 100000);

// === Telemetry Removal & Safe Privacy (Homelab-HTTP Friendly) ===
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("extensions.pocket.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);

user_pref("dom.security.https_first", true);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("privacy.query_stripping.enabled", true);
user_pref("privacy.query_stripping.enabled.pbmode", true);
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);
user_pref("browser.send_pings", false);

// === DevTools Ready ===
user_pref("devtools.theme", "dark");
user_pref("devtools.chrome.enabled", true);
user_pref("devtools.debugger.remote-enabled", true);

// === PDF.js Catppuccin Mocha ===
// Keep native forcePageColors OFF (its HCM filter applies linear-gamma transfer that bloats font anti-aliasing);
// page colors are handled in sRGB via chrome/content/pdfjs.css instead.
user_pref("pdfjs.forcePageColors", false);
user_pref("pdfjs.viewerCssTheme", 2);
user_pref("pdfjs.highlightEditorColors", "yellow=#f9e2af,green=#a6e3a1,blue=#89b4fa,pink=#f5c2e7,red=#f38ba8,yellow_HCM=#f9e2af,green_HCM=#a6e3a1,blue_HCM=#89b4fa,pink_HCM=#f5c2e7,red_HCM=#f38ba8");
