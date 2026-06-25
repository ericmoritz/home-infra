{ ... }:
let
  brightness_pct = 85;
  color_temp_kelvin = 2700;
  color_red = [
    224
    27
    36
  ];
in
{
  services.home-assistant.config = {
    group.Basement.entities = [
      "input_boolean.eric_work_laptop_camera"
      "input_boolean.eric_work_laptop_microphone"
    ];

    input_boolean = {
      eric_work_laptop_camera = {
        name = "Eric Work Laptop - Camera";
        icon = "mdi:webcam";
      };

      eric_work_laptop_microphone = {
        name = "Eric Work Laptop - Microphone";
        icon = "mdi:microphone";
      };
    };

    automation = [
      ## This defines the webhook that my laptop POSTs the camera and microphone status to
      ## It calls input_boolean.turn_on or tune_off based on the request body's .event value
      {
        alias = "Eric Work Laptop - Webcam - Webhook";
        mode = "single";
        variables = {
          action = "input_boolean.turn_{{ trigger.json.event == 'on' and 'on' or 'off' }}";
          entity_id = "input_boolean.eric_work_laptop_{{ trigger.json.device }}";
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
      ## This automation sets the basement stairs light to red if my desk is occupied and the webcam is on
      {
        alias = "Eric Work Laptop - Webcam - On";
        mode = "single";
        triggers = [
          {
            trigger = "state";
            entity_id = "input_boolean.eric_work_laptop_camera";
            from = "off";
            to = "on";
          }
        ];
        conditions = [
          {
            condition = "state";
            entity_id = "input_boolean.basement_desk_is_occupied";
            state = "on";
          }
        ];
        actions = [
          {
            action = "light.turn_on";
            target = {
              entity_id = "light.basement_light_stairs";
            };
            data = {
              rgb_color = color_red;
              brightness_pct = 100;
            };
          }
        ];
      }
      ## This automation sets the basement stairs light to warm white if my desk is occupied and the webcam is on
      {
        alias = "Eric Work Laptop - Webcam - Off";
        mode = "single";
        triggers = [
          {
            trigger = "state";
            entity_id = "input_boolean.eric_work_laptop_camera";
            from = "on";
            to = "off";
          }
        ];
        conditions = [
          {
            condition = "state";
            entity_id = "input_boolean.basement_desk_is_occupied";
            state = "on";
          }
        ];
        actions = [
          {
            action = "light.turn_on";
            data = {
              inherit color_temp_kelvin brightness_pct;
            };
            target = {
              entity_id = "light.basement_light_stairs";
            };
          }
        ];
      }
    ];
  };
}
