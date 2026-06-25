let
  lib = import ../lib;
  consts = import ../consts.nix;
  brightness_pct = 85;
in
{
  services.home-assistant.config =
    lib.mkOccupationAutomation {
      name = "Basement - Desk";
      entity_slug = "basement_desk";
      sensor_entity_id = "sensor.apollo_mtr_1_265c88_zone_1_all_target_count";
      detected_script_id = "script.work_mode_on";
      detected_script_id_night = "script.work_mode_on";
      cleared_script_id = "script.work_mode_off";
      away_timeout = 60;
    }
    // {
      script = {
        work_mode_on = {
          description = "Turn on Work Mode";
          sequence = [
            {
              action = "light.turn_on";
              data = {
                color_temp_kelvin = consts.color_temp_kelvin;
                inherit brightness_pct;
              };
              target = {
                entity_id = "light.basement_light_desk_left";
              };
            }
            {
              action = "light.turn_on";
              data = {
                color_temp_kelvin = consts.color_temp_kelvin;
                inherit brightness_pct;
              };
              target = {
                entity_id = "light.basement_light_desk_right";
              };
            }
            {
              action = "light.turn_on";
              data = {
                color_temp_kelvin = consts.color_temp_kelvin;
                inherit brightness_pct;
              };
              target = {
                entity_id = "light.basement_light_desk_left_rear";
              };
            }
          ];
        };
        work_mode_off = {
          description = "Turn on Work Mode";
          sequence = [
            {
              action = "light.turn_off";
              data = { };
              target = {
                entity_id = "light.basement_light_desk_left";
              };
            }
            {
              action = "light.turn_off";
              data = { };
              target = {
                entity_id = "light.basement_light_desk_right";
              };
            }
            {
              action = "light.turn_off";
              data = { };
              target = {
                entity_id = "light.basement_light_desk_left_rear";
              };
            }
          ];

        };
      };
    };
}
