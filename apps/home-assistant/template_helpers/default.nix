(import ./is_during_commute.nix)
++ [
  {
    binary_sensor = {
      name = "Basement - Desk - Is Occupied";
      default_entity_id = "binary_sensor.basement_desk_is_occupied";
      unique_id = "basement_desk_is_occupied";
      state = ''
        {% set state = states("sensor.apollo_mtr_1_265c88_zone_1_all_target_count") %}
        {% set state = is_number(state) and state | float > 0 %}
        {{ state }}
      '';
    };
  }
]
