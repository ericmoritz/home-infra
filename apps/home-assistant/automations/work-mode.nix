let
  is_occupied_id = "binary_sensor.basement_desk_is_occupied";

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
        trigger = "state";
        entity_id = [ is_occupied_id ];
        from = [ "off" ];
        to = [ "on" ];
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
        trigger = "state";
        entity_id = [ is_occupied_id ];
        from = [ "on" ];
        to = [ "off" ];
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
