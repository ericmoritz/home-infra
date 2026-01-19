let
  brightness_pct = 85;
  color_temp_kelvin = 2700;
in
{
  work_mode_on = {
    description = "Turn on Work Mode";
    sequence = [
      {
        action = "light.turn_on";
        data = {
          inherit color_temp_kelvin brightness_pct;
        };
        target = {
          entity_id = "light.basement_light_desk_left";
        };
      }
      {
        action = "light.turn_on";
        data = {
          inherit color_temp_kelvin brightness_pct;
        };
        target = {
          entity_id = "light.basement_light_desk_right";
        };
      }
      {
        action = "light.turn_on";
        data = {
          inherit color_temp_kelvin brightness_pct;
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
}
