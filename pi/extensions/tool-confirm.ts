import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function(pi: ExtensionAPI) {
    let enabled = true;

    pi.on("session_start", () => {
        enabled = true;
    });

    pi.registerCommand("tool-confirm", {
        description: "Toggle bash confirmation on/off",
        handler: async (_args, ctx) => {
            enabled = !enabled;
            ctx.ui.notify(
                enabled ? "Bash confirmation: ON" : "Bash confirmation: OFF",
                "info",
            );
        },
    });

    pi.on("tool_call", async (event, ctx) => {
        if (event.toolName !== "bash") return;

        if (!enabled) return;

        if (!ctx.hasUI) {
            return { block: true, reason: "Bash blocked (no UI for confirmation)" };
        }

        const command = (event.input.command as string) ?? "";

        const choice = await ctx.ui.select(
            `Execute bash command?\n\n  ${command}`,
            ["Allow", "Block", "Allow All (this session)"],
        );

        if (!choice || choice === "Block") {
            return { block: true, reason: "Blocked by user" };
        }
    });
}
