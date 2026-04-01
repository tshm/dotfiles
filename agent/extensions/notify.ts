import type { ExtensionAPI, ToolExecutionEndEvent } from "@oh-my-pi/pi-coding-agent";

const CONTROL_CHARS = /[\u0000-\u001f\u007f-\u009f]/g;

function sanitizeMessage(message: string): string {
	const sanitized = message.replace(CONTROL_CHARS, " ").trim();
	return sanitized.length > 0 ? sanitized : "Notification";
}

function detectNotificationSequence(message: string): string {
	const sanitized = sanitizeMessage(message);
	const termProgram = process.env.TERM_PROGRAM?.toLowerCase();

	if (process.env.KITTY_WINDOW_ID || termProgram === "kitty") {
		return `\x1b]99;;${sanitized}\x1b\\`;
	}

	if (
		process.env.GHOSTTY_RESOURCES_DIR ||
		process.env.WEZTERM_PANE ||
		process.env.ITERM_SESSION_ID ||
		termProgram === "ghostty" ||
		termProgram === "wezterm" ||
		termProgram === "iterm.app"
	) {
		return `\x1b]9;${sanitized}\x1b\\`;
	}

	return "\x07";
}

function sendNotification(message: string): void {
	if (!process.stdout.isTTY) return;
	process.stdout.write(detectNotificationSequence(message));
}

function buildCompletionMessage(sessionManager: { getSessionName(): string | undefined }): string {
	const sessionName = sessionManager.getSessionName();
	return sessionName ? `${sessionName}: Complete` : "Complete";
}

function buildErrorMessage(event: ToolExecutionEndEvent): string {
	return `${event.toolName}: Failed`;
}

export default function notifyExtension(pi: ExtensionAPI) {
	let errorNotifiedThisTurn = false;

	pi.on("turn_start", async () => {
		errorNotifiedThisTurn = false;
	});

	pi.on("tool_execution_end", async event => {
		if (!event.isError || errorNotifiedThisTurn) return;
		errorNotifiedThisTurn = true;
		sendNotification(buildErrorMessage(event));
	});

	pi.on("agent_end", async (_event, ctx) => {
		sendNotification(buildCompletionMessage(ctx.sessionManager));
	});
}