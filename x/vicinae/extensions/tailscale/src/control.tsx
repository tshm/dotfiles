import { Action, ActionPanel, Icon, List, showToast, Toast } from "@vicinae/api";
import { useCallback, useEffect, useState } from "react";
import { readSnapshot, runTailscale, type TailscaleSnapshot } from "./tailscale";

export default function Control() {
  const [snapshot, setSnapshot] = useState<TailscaleSnapshot>();
  const [error, setError] = useState<string>();
  const [isLoading, setIsLoading] = useState(true);

  const load = useCallback(async (preserveSnapshot = false) => {
    setIsLoading(true);
    try {
      setSnapshot(await readSnapshot());
      setError(undefined);
    } catch (cause) {
      if (!preserveSnapshot) {
        setSnapshot(undefined);
        setError(cause instanceof Error ? cause.message : String(cause));
      }
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const mutate = async (title: string, successTitle: string, operation: () => Promise<void>) => {
    const toast = await showToast({ style: Toast.Style.Animated, title });
    try {
      await operation();
      toast.style = Toast.Style.Success;
      toast.title = successTitle;
    } catch (cause) {
      toast.style = Toast.Style.Failure;
      toast.title = "Tailscale command failed";
      toast.message = cause instanceof Error ? cause.message : String(cause);
    } finally {
      await toast.update();
      await load(true);
    }
  };

  if (error && !snapshot) {
    return (
      <List isLoading={isLoading}>
        <List.EmptyView
          icon={Icon.Warning}
          title="Unable to load Tailscale"
          description={error}
          actions={
            <ActionPanel>
              <Action title="Retry" icon={Icon.ArrowClockwise} onAction={() => void load()} />
            </ActionPanel>
          }
        />
      </List>
    );
  }

  if (!snapshot) {
    return <List isLoading={isLoading} />;
  }

  const running = snapshot.backendState === "Running";
  const stopped = snapshot.backendState === "Stopped";
  const mutable = running || stopped;
  const connectionTitle = running ? "Connected" : stopped ? "Disconnected" : snapshot.backendState;

  return (
    <List isLoading={isLoading}>
      <List.Section title="Connection">
        <List.Item
          id="connection"
          title={connectionTitle}
          subtitle={snapshot.hostname}
          accessories={snapshot.ipv4 ? [{ text: snapshot.ipv4 }] : undefined}
          actions={
            <ActionPanel>
              {running && (
                <Action
                  title="Disconnect"
                  icon={Icon.Power}
                  style={Action.Style.Destructive}
                  onAction={() =>
                    void mutate("Disconnecting Tailscale", "Tailscale disconnected", async () => {
                      await runTailscale(["down"]);
                    })
                  }
                />
              )}
              {stopped && (
                <Action
                  title="Connect"
                  icon={Icon.Power}
                  onAction={() =>
                    void mutate("Connecting Tailscale", "Tailscale connected", async () => {
                      await runTailscale(["up"]);
                    })
                  }
                />
              )}
              {snapshot.authUrl && <Action.OpenInBrowser title="Open Login" url={snapshot.authUrl} />}
              <Action title="Refresh" icon={Icon.ArrowClockwise} onAction={() => void load()} />
            </ActionPanel>
          }
        />
      </List.Section>

      <List.Section title="Exit Node">
        <List.Item id="no-exit-node" title="No Exit Node" />
        {snapshot.exitNodes.length === 0 && (
          <List.Item id="no-exit-nodes-available" title="No Exit Nodes Available" />
        )}
        {snapshot.exitNodes.map((node) => (
          <List.Item
            id={node.id}
            key={node.id}
            title={node.hostname}
            subtitle={[node.dnsName, node.ipv4].filter(Boolean).join(" • ")}
            accessories={[
              { tag: node.active ? "Active" : node.online ? "Online" : "Offline" },
              ...(node.active && snapshot.lanAccess === null ? [{ text: "LAN Access Unknown" }] : []),
            ]}
            actions={
              <ActionPanel>
                {mutable && node.online && !node.active && (
                  <Action
                    title="Use as Exit Node"
                    onAction={() =>
                      void mutate("Setting exit node", "Exit node updated", async () => {
                        await runTailscale(["set", `--exit-node=${node.dnsName}`]);
                        if (stopped) await runTailscale(["up"]);
                      })
                    }
                  />
                )}
                {mutable && node.active && (
                  <Action
                    title="Disable Exit Node"
                    style={Action.Style.Destructive}
                    onAction={() =>
                      void mutate("Disabling exit node", "Exit node disabled", async () => {
                        await runTailscale(["set", "--exit-node="]);
                      })
                    }
                  />
                )}
                {mutable && node.active && snapshot.lanAccess !== null && (
                  <Action
                    title={snapshot.lanAccess ? "Disable LAN Access" : "Enable LAN Access"}
                    onAction={() =>
                      void mutate("Updating LAN access", "LAN access updated", async () => {
                        await runTailscale([
                          "set",
                          `--exit-node-allow-lan-access=${!snapshot.lanAccess}`,
                        ]);
                      })
                    }
                  />
                )}
              </ActionPanel>
            }
          />
        ))}
      </List.Section>
    </List>
  );
}
