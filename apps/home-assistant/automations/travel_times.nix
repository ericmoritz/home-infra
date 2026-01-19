[
  {
    alias = "Travel Times - Update Eric to Corsha";
    description = "Update Travel Time to Corsha during typical time";
    triggers = [
      {
        trigger = "time_pattern";
        minutes = "/5";
      }
    ];
    conditions = [
      {
        condition = "state";
        entity_id = "binary_sensor.is_during_commute";
        state = [ "on" ];
      }
    ];

    actions = [
      {
        action = "homeassistant.update_entity";
        data = {
          entity_id = "sensor.eric_to_corsha_travel_time";
        };
      }
    ];
  }
  {
    alias = "Travel Times - Update Eric to Home";
    triggers = [
      {
        trigger = "time_pattern";
        minutes = "/5";
      }
    ];
    conditions = [
      {
        condition = "state";
        entity_id = "person.admin";
        state = [ "not_home" ];
      }
    ];
    actions = [
      {
        action = "homeassistant.update_entity";
        data = {
          entity_id = "sensor.eric_to_home_travel_time";
        };
      }
    ];
  }
]
