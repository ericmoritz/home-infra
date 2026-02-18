let
  entities = import ../entities;
in
(import ./travel_times.nix)
++ (import ./laundry.nix)
++ entities.work-mode.automations
++ entities.parents-vanity-occupied.automations
# ++ entities.parents-closet-occupied.automations
++ (import ./webcam.nix)
