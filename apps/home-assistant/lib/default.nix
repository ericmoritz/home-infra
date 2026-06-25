{
  mkOccupationAutomation =
    {
      name,
      entity_slug,
      sensor_entity_id,
      detected_script_id,
      detected_script_id_night,
      cleared_script_id,
      away_timeout ? 15,
    }:
    let
      toggle_id = "binary_sensor.${entity_slug}_is_occupied";
      boolean_id = "input_boolean.${entity_slug}_is_occupied";
    in
    {
      template = [
        {
          binary_sensor = {
            name = "${name} - Is Occupied";
            default_entity_id = toggle_id;
            unique_id = "${entity_slug}_is_occupied";
            state = ''
              {% set state = states("${sensor_entity_id}") %}
              {% set state = is_number(state) and state | float > 0 %}
              {{ state }}
            '';
          };
        }
      ];

      input_boolean = {
        "${entity_slug}_is_occupied" = {
          name = "${name} - Is Occupied";
          initial = "off";
        };
      };

      automation = [
        {
          alias = "${name} - Detected";
          mode = "single";
          triggers = [
            {
              trigger = "state";
              entity_id = [ toggle_id ];
              from = [ "off" ];
              to = [ "on" ];
            }
          ];
          actions = [
            {
              action = ''{{ "${detected_script_id}" if is_state("sun.sun", "above_horizon") else "${detected_script_id_night}" }}'';
            }
            {
              action = "input_boolean.turn_on";
              target = {
                entity_id = boolean_id;
              };
            }
          ];
        }
        {
          alias = "${name} - Clear";
          mode = "single";
          triggers = [
            {
              trigger = "state";
              entity_id = [ toggle_id ];
              from = [ "on" ];
              to = [ "off" ];
              for = away_timeout;
            }
          ];

          actions = [
            {
              action = cleared_script_id;
            }
            {
              action = "input_boolean.turn_off";
              target = {
                entity_id = boolean_id;
              };
            }
          ];
        }
      ];
    };
}
