import assert from "node:assert/strict";
import test from "node:test";
import { parsePrefs, parseStatus } from "../src/tailscale.ts";

test("parses and orders exit nodes", () => {
  const snapshot = parseStatus(JSON.stringify({
    BackendState: "Running",
    Self: { HostName: "local", TailscaleIPs: ["fd00::1", "100.64.0.1"] },
    Peer: {
      ignored: { HostName: "regular", ExitNodeOption: false, Online: true },
      offline: {
        ID: "offline-id",
        HostName: "z-offline",
        DNSName: "z-offline.example.invalid.",
        TailscaleIPs: ["fd00::2", "100.64.0.2"],
        ExitNodeOption: true,
        Online: false,
      },
      online: {
        ID: "online-id",
        HostName: "a-online",
        DNSName: "a-online.example.invalid.",
        ExitNodeOption: true,
        Online: true,
      },
      active: {
        ID: "active-id",
        HostName: "m-active",
        DNSName: "m-active.example.invalid.",
        ExitNodeOption: true,
        ExitNode: true,
        Online: true,
      },
    },
  }));

  assert.equal(snapshot.ipv4, "100.64.0.1");
  assert.deepEqual(snapshot.exitNodes.map(({ id }) => id), ["active-id", "online-id", "offline-id"]);
  assert.equal(snapshot.exitNodes[0].dnsName, "m-active.example.invalid");
  assert.equal(snapshot.exitNodes[2].ipv4, "100.64.0.2");
});

test("parses optional LAN access preference", () => {
  assert.equal(parsePrefs('{"ExitNodeAllowLANAccess":true}'), true);
  assert.equal(parsePrefs("{}"), null);
});
