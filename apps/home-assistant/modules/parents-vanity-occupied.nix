{ ... }:
let
  lib = import ../lib;
  consts = import ../consts.nix;
  light_id = "light.parents_light_vanity";
in
{
  services.home-assistant.config =
    lib.mkOccupationAutomation {
      name = "Parents - Vanity";
      entity_slug = "parents_vanity";
      sensor_entity_id = "sensor.bathroom_presence_zone_1_all_target_count";
      detected_script_id = "script.vanity_occupied_on";
      detected_script_id_night = "script.vanity_occupied_on_night";
      cleared_script_id = "script.vanity_occupied_off";
    }
    // {
      script = {
        vanity_occupied_on = {
          description = "Turn on Vanity Lights";
          sequence = [
            {
              action = "light.turn_on";
              data = {
                color_temp_kelvin = consts.color_temp_kelvin;
                brightness_pct = consts.day_brightness_pct;
              };
              target = {
                entity_id = light_id;
              };
            }
          ];
        };
        vanity_occupied_on_night = {
          description = "Turn on Vanity Lights";
          sequence = [
            {
              action = "light.turn_on";
              data = {
                color_temp_kelvin = consts.color_temp_kelvin;
                brightness_pct = consts.night_brightness_pct;
              };
              target = {
                entity_id = light_id;
              };
            }
          ];
        };
        vanity_occupied_off = {
          description = "Turn off Vanity Lights";
          sequence = [
            {
              action = "light.turn_off";
              data = { };
              target = {
                entity_id = light_id;
              };
            }
          ];

        };
      };
    };
}
