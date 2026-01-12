[
  {
    platform = "group";
    name = "Laundry notify group";
    services = map (action: { inherit action; }) [
      "mobile_app_eric_phone"
      "mobile_app_bella_phone"
      "mobile_app_riot_s_pixel_7"
      "mobile_app_sm_n975u"
      "mobile_app_sm_x510"
    ];
  }
]
