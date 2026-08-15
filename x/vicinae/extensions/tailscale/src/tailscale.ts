import { execFile } from "node:child_process";

export interface ExitNode {
  id: string;
  hostname: string;
  dnsName: string;
  ipv4?: string;
  online: boolean;
  active: boolean;
}

export interface TailscaleSnapshot {
  backendState: string;
  authUrl?: string;
  hostname?: string;
  ipv4?: string;
  exitNodes: ExitNode[];
  lanAccess: boolean | null;
}

type JsonObject = Record<string, unknown>;

const tailscalePath = "/run/current-system/sw/bin/tailscale";

function object(value: unknown): JsonObject {
  return value !== null && typeof value === "object" ? (value as JsonObject) : {};
}

function string(value: unknown): string | undefined {
  return typeof value === "string" && value.length > 0 ? value : undefined;
}

function ipv4(value: unknown): string | undefined {
  return Array.isArray(value)
    ? value.find((address): address is string => typeof address === "string" && address.includes("."))
    : undefined;
}


export function parseStatus(raw: string): Omit<TailscaleSnapshot, "lanAccess"> {
  const status = object(JSON.parse(raw));
  const self = object(status.Self);
  const peers = Object.entries(object(status.Peer))
    .map(([key, value]) => {
      const peer = object(value);
      const dnsName = string(peer.DNSName)?.replace(/\.+$/, "");
      const hostname = string(peer.HostName) ?? dnsName ?? key;
      return {
        id: string(peer.ID) ?? key,
        hostname,
        dnsName: dnsName ?? hostname,
        ipv4: ipv4(peer.TailscaleIPs),
        online: peer.Online === true,
        active: peer.ExitNode === true,
        option: peer.ExitNodeOption === true,
      };
    })
    .filter((peer) => peer.option)
    .sort(
      (a, b) =>
        Number(b.active) - Number(a.active) ||
        Number(b.online) - Number(a.online) ||
        a.hostname.localeCompare(b.hostname),
    )
    .map(({ option: _, ...peer }) => peer);

  return {
    backendState: string(status.BackendState) ?? "Unknown",
    authUrl: string(status.AuthURL),
    hostname: string(self.HostName),
    ipv4: ipv4(self.TailscaleIPs),
    exitNodes: peers,
  };
}

export function parsePrefs(raw: string): boolean | null {
  const value = object(JSON.parse(raw)).ExitNodeAllowLANAccess;
  return typeof value === "boolean" ? value : null;
}

export function runTailscale(args: readonly string[]): Promise<string> {
  const { promise, resolve, reject } = (
    Promise as PromiseConstructor & {
      withResolvers<T>(): {
        promise: Promise<T>;
        resolve: (value: T | PromiseLike<T>) => void;
        reject: (reason?: unknown) => void;
      };
    }
  ).withResolvers<string>();
  execFile(
    tailscalePath,
    [...args],
    { encoding: "utf8", maxBuffer: 10 * 1024 * 1024 },
    (error, stdout, stderr) => {
      if (!error) {
        resolve(stdout);
        return;
      }

      const detail = stderr.trim();
      reject(detail ? new Error(`${error.message}\n${detail}`, { cause: error }) : error);
    },
  );
  return promise;
}

export async function readStatus(): Promise<Omit<TailscaleSnapshot, "lanAccess">> {
  return parseStatus(await runTailscale(["status", "--json"]));
}

export async function readSnapshot(): Promise<TailscaleSnapshot> {
  const [status, lanAccess] = await Promise.all([
    readStatus(),
    runTailscale(["debug", "prefs"]).then(parsePrefs).catch(() => null),
  ]);
  return { ...status, lanAccess };
}
