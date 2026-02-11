let
  lib = import ../lib;
in
{
  work-mode = lib.mkOccupationAutomation {
    name = "Basement - Desk";
    entity_slug = "basement_desk";
    sensor_entity_id = "sensor.apollo_mtr_1_265c88_zone_1_all_target_count";
    detected_script_id = "script.work_mode_on";
    detected_script_id_night = "script.work_mode_on";
    cleared_script_id = "script.work_mode_off";
  };

  parents-vanity-occupied = lib.mkOccupationAutomation {
    name = "Parents - Vanity";
    entity_slug = "parents_vanity";
    sensor_entity_id = "sensor.bathroom_presence_zone_1_all_target_count";
    detected_script_id = "script.vanity_occupied_on";
    detected_script_id_night = "script.vanity_occupied_on_night";
    cleared_script_id = "script.vanity_occupied_off";
  };

  parents-closet-occupied = lib.mkOccupationAutomation {
    name = "Parents - Closet";
    entity_slug = "parents_closet";
    sensor_entity_id = "sensor.bathroom_presence_zone_2_all_target_count";
    detected_script_id = "script.closet_occupied_on";
    detected_script_id_night = "script.closet_occupied_on_night";
    cleared_script_id = "script.closet_occupied_off";
  };
}
