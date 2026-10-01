{ inputs, ... }: {
  flake.homeModules.davidutzDesktop = { pkgs, ... }:
    let
      # The overlay builds addons with our pkgs, so nixpkgs.config.allowUnfree reaches
      # unfree ones like keepa; the flake's `packages` use its own nixpkgs and refuse them.
      addons = (pkgs.extend inputs.firefox-addons.overlays.default).firefox-addons;
      inherit (addons) buildFirefoxXpiAddon;

      # Extensions missing from rycee's firefox-addons, pinned to an exact release.
      amo = { pname, version, addonId, file, sha256 }: buildFirefoxXpiAddon {
        inherit pname version addonId sha256;
        url = "https://addons.mozilla.org/firefox/downloads/file/${file}";
        meta = { };
      };
      extra = [
        (amo {
          pname = "youtube-agerestriction-unblocker";
          version = "1.0.4";
          addonId = "jid1-82bQxmQ0klINKg@jetpack";
          file = "4270757/youtube_agerestriction_unblock-1.0.4resigned1.xpi";
          sha256 = "sha256-mx6uxmibUdLzG6+dwdgjleu1xfrOK4nLo1ekxvjKtF0=";
        })
        (amo {
          pname = "snapchat-web";
          version = "1.0.7";
          addonId = "{4cdc299c-0eb3-450b-afc6-b2159744fdf7}";
          file = "4747100/snapchat_web-1.0.7.xpi";
          sha256 = "sha256-PqwlZriDOUHNamknKEBuZ5xnxgXf7N8T6cSTJGbMh7Q=";
        })
        (amo {
          pname = "twitch-vod-downloader";
          version = "2.15";
          addonId = "{33873724-a6c2-478f-831a-fdd2bb875896}";
          file = "4040718/andre_bradshaw-2.15.xpi";
          sha256 = "sha256-pUTJ5x4WgCsEv5qkQG0qZV7VOs2QKZOxEKROx8ZM3yA=";
        })
        (amo {
          pname = "anti-anti-debug";
          version = "1.0.7";
          addonId = "anti-anti-debug@andrews";
          file = "4298361/anti_anti_debug-1.0.7.xpi";
          sha256 = "sha256-GWnNXeO00Sdtrx0QeGagS8/f3Jl2eA0JOi5atqRtUbY=";
        })
        (amo {
          pname = "hide-youtube-shorts";
          version = "1.11.0";
          addonId = "{88ebde3a-4581-4c6b-8019-2a05a9e3e938}";
          file = "4779333/hide_youtube_shorts-1.11.0.xpi";
          sha256 = "sha256-DEQ+nQTkWLN1QDVkG5p6rKhSAn0E+YFe1IlaePLmN2U=";
        })
        (amo {
          pname = "twitch-ad-blocker";
          version = "1.0.1";
          addonId = "{25d049c4-af50-480c-bea8-09fc8bcc5323}";
          file = "4050152/twitch_ad_blocker-1.0.1.xpi";
          sha256 = "sha256-nHKchSkqm440MurV9sONCiortN8Xk4nrAc09ucOCZfI=";
        })
        (amo {
          pname = "connective-signing";
          version = "1.0.14";
          addonId = "{4f643bc8-78f5-49c6-8efd-78ee30289f0b}";
          file = "4924512/connective_signing_ext-1.0.14.xpi";
          sha256 = "sha256-jkrqaiwO1Ktc3j9SWIh8ptdQ5X+H6Ele05zg43Dh5h0=";
        })
        # jcode's browser bridge, published on GitHub instead of AMO.
        (buildFirefoxXpiAddon {
          pname = "browser-agent-bridge";
          version = "0.9.7";
          addonId = "browser-agent-bridge@1jehuang.github.io";
          url = "https://github.com/1jehuang/firefox-agent-bridge/releases/download/v0.10.0/browser-agent-bridge-0.9.7.xpi";
          sha256 = "sha256-QAH4XePFUBNx68t8jVJXOYl46SQ4u++lyeF2GlAYCRU=";
          meta = { };
        })
      ];
    in
    {
      imports = [ inputs.zen-browser.homeModules.beta ];

      programs.zen-browser = {
        enable = true;
        policies = {
          DisableTelemetry = true;
          DisableAppUpdate = true;
          DontCheckDefaultBrowser = true;
        };
        profiles.default = {
          extensions.packages = with addons; [
            ublock-origin
            bitwarden
            darkreader
            sponsorblock
            docsafterdark
            leechblock-ng
            metamask
            keepa
            csgofloat
            video-downloadhelper
            aw-watcher-web
          ] ++ extra;
          settings = { "browser.tabs.warnOnClose" = false; };
        };
      };
    };
}
