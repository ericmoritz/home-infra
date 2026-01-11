{
  alias = "Update Eric to Corsha Travel Time";
  description = "Update Travel Time to Corsha during typical time";
  triggers = [
    {
      trigger = "time_pattern";
      minutes = "/2";
    }
  ];
  conditions = [
    {
      condition = "or";
      conditions = [
        {
          condition = "time";
          after = "05:00:00";
          before = "10:00:00";
          weekday = [
            "mon"
            "tue"
            "wed"
            "thu"
            "fri"
          ];
        }
        {
          condition = "time";
          after = "15:00:00";
          before = "19:00:00";
          weekday = [
            "mon"
            "tue"
            "wed"
            "thu"
            "fri"
          ];
        }
      ];
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
