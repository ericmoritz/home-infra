[
  {
    alias = "Webcam - Eric Work Laptop";
    mode = "single";
    variables = {

      action = "input_boolean.turn_{{ trigger.json.event == 'on' and 'on' or 'off' }}";
      entity_id = "input_boolean.webcam_eric_work_laptop_{{ trigger.json.device }}";
    };

    triggers = [
      {
        trigger = "webhook";
        allowed_methods = [ "POST" ];
        local_only = false;
        webhook_id = "webcam_eric_work_laptop";
      }
    ];
    actions = [
      {
        action = "{{ action }}";
        target = {
          entity_id = "{{ entity_id }}";
        };
      }
    ];
  }
]
