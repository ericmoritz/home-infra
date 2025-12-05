let
  eric-t470 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDppXzPalgkxgaEnabqirf2sbx1LJW60jpjK0XSoLMa/ylnR8e0fHSYhU3lxaSxswUkMV71USt/7mtSWSu0suQEpqAocon55xCBFa6pmDSWae2196WfQokmJFHYVDbt/LmmI38/1zLOCmqAXOEqjfc/ggXaKnO/FTwp+Ie+MrlaHYFCJemNWSbLH4mrrBpT3R7BZVgHePUMcoiZF0ZWMwcYOlGOk4rd6xsz7JxKAS65GOp50n3nwdtMb8BCyy/0ZpELNC8i9JxomDeuOQl8czPn1OFvhEi/j6OGt3Ycu85uYQDqE3ORP92LVwm7Pj+iJxDaxyTmAMMsbVhl5MJRS5j5GrftKfVbonUcXEdlKQ/lTtlAXQ7Sp6NaylryMcb3Ko9/ZqOQdXZZf57d3qgoz4wuNEvRjBVXA+77HHBNstR996+G0s4wgwx394IJ11i7nAELqNSNAblOBAEyGKssF60F7TcqT1ZLVD7b+4AHrqNSSnup3GePPREIXcG7FcgT0+U= eric@eric-t470";

  eric-fw13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt4tgmV3TOhci/NP6oUixTgQ9HUplUS3uisunDfP8JX eric@eric-fw13";

  users = [ eric-t470 eric-fw13 ]; 

  k3s-master = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB1aCWXXKSHr9mzSRpy/QePPRkgAkiyYmtX5G8R8HTOx";

  systems = [k3s-master];
in {
  "wireshark-private-key.age".publicKeys = users ++ systems;
  "slskd-env.age".publicKeys = users ++ systems;
}
