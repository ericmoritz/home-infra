# This is a toggle that flips to true on weekdays between the 5am and
# 10am as well as 3pm and 7pm.
#
# It is used to trigger the Update Eric to Corsha Travel Time and to
# toggle the visibility of the travel time card on the overview page
[
  {
    binary_sensor = {
      name = "Is During Commute";
      state = ''
        {% set ts = now() %}
        {% set is_weekday = ts.isoweekday() < 6 %}
        {% set is_morning_commute = ts.hour >= 5 and ts.hour < 10 %}
        {% set is_evening_commute = ts.hour >= 15 and ts.hour < 19 %}

        {{ is_weekday and (is_morning_commute or is_evening_commute) }}
      '';
    };
  }
]
