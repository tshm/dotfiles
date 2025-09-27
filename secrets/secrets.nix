let
  key1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE1nFDHaQvTrUEDiPpT3qvVJXEot5IEhBJmUZ0WKRPYD";
  key2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOe16XtRvMF6S+1Z0tkk3R7jV211Ff2ynmoL+BinKmwW";
in {
  "user-password.age".publicKeys = [ key1 key2 ];
}
