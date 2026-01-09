{ config, pkgs, ... }:
{

  services.nginx.virtualHosts."${config.services.dashy.virtualHost.domain}" = {
    forceSSL = true;
    useACMEHost = "home.ericcodes.io";
  };

  services.dashy = {
    enable = true;
    virtualHost = {
      domain = "portal.home.ericcodes.io";
      enableNginx = true;
    };
    settings = {
      appConfig = {
        cssThemes = [ ];
        enableFontAwesome = true;
        fontAwesomeKey = "e9076c7025";
        theme = "vaporwave";
      };
      pageInfo = {
        description = "Portal";
        title = "Portal";
      };
      sections = [
        {
          displayData = {
            collapsed = false;
            cols = 2;
            customStyles = "border: 2px dashed red;";
            itemSize = "large";
          };
          items = [
            {
              description = "Jellyfin";
              icon = "hl-jellyfin";
              title = "Jellyfin";
              url = "http://192.168.1.2:8096/";
            }
            {
              description = "Sonarr";
              icon = "hl-sonarr";
              title = "TV Shows";
              url = "https://sonarr.home.ericcodes.io/";
            }
            {
              description = "Radarr";
              icon = "hl-radarr";
              title = "Movies";
              url = "https://radarr.home.ericcodes.io/";
            }
            {
              description = "Roms";
              icon = "hl-romm";
              title = "Roms";
              url = "https://roms.home.ericcodes.io/";
            }
            {
              # backgroundColor = "#0079ff";
              # color = "#00ffc9";
              description = "Sabnzbd";
              icon = "hl-sabnzbd";
              title = "NZB";
              url = "https://nzb.home.ericcodes.io/";
            }
            {
              description = "Transmission";
              icon = "hl-transmission";
              title = "Torrents";
              url = "https://torrents.home.ericcodes.io/";
            }
            {
              description = "Home Assistant";
              icon = "hl-home-assistant";
              title = "Home Assistant";
              url = "https://hass.home.ericcodes.io/";
            }
          ];
          name = "Media";
        }

        {
          displayData = {
            collapsed = false;
            cols = 2;
            customStyles = "border: 2px dashed red;";
            itemSize = "large";
          };
          items = [
            {
              description = "Books";
              icon = "hl-calibreweb";
              title = "Personal Books";
              url = "https://books.apps.ericcodes.io/";
            }
            {
              icon = "favicon";
              title = "Cloudlog";
              url = "https://qso.apps.ericcodes.io/";
            }
            {
              icon = "hl-freshrss";
              title = "RSS";
              url = "https://rss.apps.ericcodes.io/";
            }
            {
              icon = "hl-irc";
              title = "IRC";
              url = "https://irc.apps.ericcodes.io/";
            }
            {
              description = "Coffee with Comrades Library";
              icon = "hl-calibreweb";
              title = "Rolling Fuck";
              url = "https://books.rollingfuck.wtf/";
            }
          ];
          name = "Apps";
        }

      ];

      # Major Tom|https://majortom.home/
      # Diskstation|https://192.168.1.2:5000/
      # Books|https://192.168.1.2:8083/
      # TV Shows|https://sonarr.home.ericcodes.io
      # Movies|https://radarr.home.ericcodes.io
      # SABnzbd|https://nzb.home.ericcodes.io
      # Plex|https://192.168.1.2:32400/web/index.html
      # Jellyfin|https://192.168.1.2:8096/
      # Deluge|https://deluge.home.ericcodes.io/

      # Rolling Fuck|https://books.rollingfuck.wtf/

    };
  };
}
