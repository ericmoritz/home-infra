let
  day_brightness_pct = 50;
  night_brightness_pct = 30;
  color_temp_kelvin = 2700;
  light_id = "light.parents_light_vanity";
in
{
  vanity_occupied_on = {
    description = "Turn on Vanity Lights";
    sequence = [
      {
        action = "light.turn_on";
        data = {
          inherit color_temp_kelvin;
          brightness_pct = day_brightness_pct;
        };
        target = {
          entity_id = light_id;
        };
      }
    ];
  };
  vanity_occupied_on_night = {
    description = "Turn on Vanity Lights";
    sequence = [
      {
        action = "light.turn_on";
        data = {
          inherit color_temp_kelvin;
          brightness_pct = night_brightness_pct;
        };
        target = {
          entity_id = light_id;
        };
      }
    ];
  };
  vanity_occupied_off = {
    description = "Turn off Vanity Lights";
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
}
