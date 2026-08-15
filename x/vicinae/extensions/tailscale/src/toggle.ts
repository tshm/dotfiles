import { showToast, Toast } from "@vicinae/api";
import { readStatus, runTailscale } from "./tailscale";

export default async function toggle() {
  const toast = await showToast({ style: Toast.Style.Animated, title: "Checking Tailscale status" });
  try {
    const { backendState } = await readStatus();
    if (backendState === "Running") {
      toast.title = "Disconnecting Tailscale";
      await toast.update();
      await runTailscale(["down"]);
      toast.style = Toast.Style.Success;
      toast.title = "Tailscale disconnected";
    } else if (backendState === "Stopped") {
      toast.title = "Connecting Tailscale";
      await toast.update();
      await runTailscale(["up"]);
      toast.style = Toast.Style.Success;
      toast.title = "Tailscale connected";
    } else {
      throw new Error(`Cannot toggle Tailscale while backend state is ${backendState}`);
    }
  } catch (cause) {
    toast.style = Toast.Style.Failure;
    toast.title = "Tailscale command failed";
    toast.message = cause instanceof Error ? cause.message : String(cause);
  }
  await toast.update();
}
