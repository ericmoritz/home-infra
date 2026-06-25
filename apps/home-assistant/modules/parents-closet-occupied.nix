{ ... }:
let
  lib = import ../lib;
  consts = import ../consts.nix;
  light_id = "light.parents_light_closet";
in
{
  services.home-assistant.config =
    lib.mkOccupationAutomation {
      name = "Parents - Closet";
      entity_slug = "parents_closet";
      sensor_entity_id = "sensor.bathroom_presence_zone_2_all_target_count";
      detected_script_id = "script.closet_occupied_on";
      detected_script_id_night = "script.closet_occupied_on_night";
      cleared_script_id = "script.closet_occupied_off";
    }
    // {
      script = {
        closet_occupied_on = {
          description = "Turn on Closet Lights";
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
        closet_occupied_on_night = {
          description = "Turn on Closet Lights";
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
        closet_occupied_off = {
          description = "Turn off Closet Lights";
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
