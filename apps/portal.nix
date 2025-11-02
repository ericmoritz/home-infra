{ config, pkgs, ... }: {
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
              title = "Movies";
              url = "http://sonarr.home.ericcodes.io/";
            }
            {
              description = "Radarr";
              icon = "hl-radarr";
              title = "TV Shows";
              url = "http://radarr.home.ericcodes.io/";
            }
            {
              # backgroundColor = "#0079ff";
              # color = "#00ffc9";
              description = "Sabnzbd";
              icon = "hl-sabnzbd";
              title = "NZB";
              url = "http://nzb.home.ericcodes.io/";
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

      # Major Tom|http://majortom.home/
      # Diskstation|http://192.168.1.2:5000/
      # Books|http://192.168.1.2:8083/
      # TV Shows|http://sonarr.home.ericcodes.io
      # Movies|http://radarr.home.ericcodes.io
      # SABnzbd|http://nzb.home.ericcodes.io
      # Plex|http://192.168.1.2:32400/web/index.html
      # Jellyfin|http://192.168.1.2:8096/
      # Deluge|http://deluge.home.ericcodes.io/

      # Rolling Fuck|https://books.rollingfuck.wtf/

    };
  };
}
