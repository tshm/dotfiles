let
  key1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE1nFDHaQvTrUEDiPpT3qvVJXEot5IEhBJmUZ0WKRPYD";
  key2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOe16XtRvMF6S+1Z0tkk3R7jV211Ff2ynmoL+BinKmwW";
  key3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1GtASZbx/L6Nm348S7peM7yQbLcg7xH+wqkWBtD6Y7";
  key4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkbkhd9iLo7GU4vu1GPPPTHZVhr8pJVCTt8JCaL/Ncb";
  keys = [ key1 key2 key3 key4 ];
in {
  "user-password-hash.age".publicKeys = keys;
  "wifi-secrets.age".publicKeys = keys;
}
