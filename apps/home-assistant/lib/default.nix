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

    in
    {
      helpers = [
        {
          binary_sensor = {
            name = "${name} - Is Occupation";
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

      automations = [
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
          ];
        }
      ];
    };
}
