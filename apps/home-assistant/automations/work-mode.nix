let
  basement_zone_id = "sensor.apollo_mtr_1_265c88_zone_1_all_target_count";

  # Time to wait before considering the desk unoccupied.
  away_timeout = {
    seconds = 15;
  };
in
[
  {
    alias = "Work Mode - Detected";
    mode = "single";
    triggers = [
      {
        trigger = "numeric_state";
        entity_id = [ basement_zone_id ];
        above = 0;
      }
    ];

    actions = [
      {
        action = "script.work_mode_on";
      }
    ];
  }
  {
    alias = "Work Mode - Clear";
    mode = "single";
    triggers = [
      {
        trigger = "numeric_state";
        entity_id = [ basement_zone_id ];
        below = 1;
        for = away_timeout;
      }
    ];

    actions = [
      {
        action = "script.work_mode_off";
      }
    ];
  }
]
