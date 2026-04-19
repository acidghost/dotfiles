import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function(pi: ExtensionAPI) {
    pi.on("agent_end", async () => {
        process.stdout.write(`\x1b]777;notify;Pi;Ready for input\x07`);
    });
}
