let
  notifyOnEnd =
    {
      alias,
      entity_id,
      message,
      todo_item,
    }:
    {
      inherit alias;
      triggers = [
        {
          trigger = "state";
          inherit entity_id;
          to = "end";
        }
      ];
      actions = [
        {
          action = "todo.add_item";
          data = {
            item = todo_item;
            due_datetime = ''{{ today_at("23:59") | as_datetime }}'';
          };
          target = {
            entity_id = "todo.family_tasks";
          };
        }
        {
          action = "notify.laundry_notify_group";
          data = {
            inherit message;
          };
        }
        {

          action = "tts.speak";
          target = {
            entity_id = "tts.home_assistant_cloud";
          };
          data = {
            cache = true;
            media_player_entity_id = "media_player.laundry_speakers";
            inherit message;
          };
        }
      ];
    };
in
[
  (notifyOnEnd {
    alias = "Laundry - Washer Done";
    entity_id = "sensor.basement_washer_current_status";
    message = "The washer has finished. Please move the clothes to the dryer";
    todo_item = "Move the laundry to the dryer";
  })

  (notifyOnEnd {
    alias = "Laundry - Dryer Done";
    entity_id = "sensor.basement_dryer_current_status";
    message = "The dryer has finished. Please collect the clothes from the dryer";
    todo_item = "Collect the laundry";
  })
]
