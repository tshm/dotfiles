let
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE1nFDHaQvTrUEDiPpT3qvVJXEot5IEhBJmUZ0WKRPYD";
in {
  "user-password.age".publicKeys = [ key ];
}
