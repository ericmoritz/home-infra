(import ./is_during_commute.nix)
++ [
  {
    binary_sensor = {
      name = "Basement - Desk - Is Occupied";
      state = ''
        {% set state = states("sensor.apollo_mtr_1_265c88_zone_1_all_target_count") %}
        {% set state = is_number(state) and state | float > 0 %}
        {{ state }}
      '';
    };
  }
]
