{
  alias = "Update Eric to Home Travel Time";
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
        entity_id = "sensor.eric_to_corsha_travel_time";
      };
    }
  ];
}
