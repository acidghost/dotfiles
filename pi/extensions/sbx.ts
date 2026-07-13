/**
 * Pi-nono sandbox extension (`sbx`).
 *
 * Security model
 * ---------------
 * This extension wraps Pi's read/write/edit/bash tools so that every operation
 * the agent performs is mediated by a layered, fail-closed access-control model.
 * Nothing executes directly on the host without either being covered by an
 * allow-rule or explicitly approved by the user through the Pi UI.
 *
 * Modes
 * -----
 * `/sbx` owns the sandbox policy for this Pi runtime:
 *
 * - `off`: use Pi's built-in tools without this extension's policy.
 * - `confirm`: require explicit UI approval before agent Bash tool calls.
 * - `nono`: apply the complete nono and path-gating policy below.
 *
 * `/sbx [off|confirm|nono]` selects a mode; `/sbx` with no argument toggles
 * between `off` and `nono`. The extension starts in `off` when Pi is already
 * wrapped by nono (detected via `NONO_CAP_FILE`) to avoid accidental nesting.
 * It emits read-only `nono:sbx:state` notifications when its mode is published
 * at session start or changes.
 *
 * Layered controls implemented in `nono` mode:
 *
 *  1. Sandbox-default Bash (nono).
 *     All bash tool calls and user-initiated bash sessions run through `nono run`
 *     under a configurable profile (`NONO_PI_BASH_PROFILE`, default `pi`). nono
 *     enforces OS-level filesystem access (landlock/seatbelt-style) restricted to
 *     Pi's start working directory plus any roots added with `/add-dir`.
 *
 *  2. Path-root gating for read/write/edit.
 *     Read, write, and edit operations are allowed without prompting only when
 *     their (canonicalized) target falls under the start directory or an
 *     `/add-dir` root (`allowedRoots`). Targets outside those roots require a
 *     one-time per-session, per-operation approval via `ctx.ui.confirm`; without
 *     a UI the operation is denied outright.
 *
 *  3. Approval-gated host fallback for Bash.
 *     When a sandboxed command fails with a sandbox-denial signature
 *     (EACCES/EPERM/landlock/seatbelt/nono:...), the user may approve a single
 *     outside-sandbox retry on the host (`createLocalBashOperations`). This keeps
 *     the sandbox as the default while offering a recoverable escape hatch.
 *
 *  4. Explicit outside-sandbox escape hatch.
 *     Prefixing a command with `PI_NONO_OUTSIDE=1 ` requests direct host
 *     execution; the marker is stripped and the user must approve via the UI
 *     (no UI => denied).
 *
 *  5. Session-scoped allow-list and approvals.
 *     `allowedRoots` and `approvedPathAccess` are module-level sets reset on each
 *     extension load (`export default`), so grants never persist across sessions.
 *     The selected mode is also reset on extension load.
 *
 *  6. Agent awareness.
 *     A `before_agent_start` hook appends a short security-policy summary to the
 *     system prompt so the model knows how to request outside-sandbox access and
 *     which paths need approval.
 *
 * Failure mode: when no UI is present, every approval-requiring path defaults to
 * denial rather than silent execution.
 */
import { spawn } from "node:child_process";
import { constants } from "node:fs";
import { access, mkdir, readFile, realpath, stat, writeFile } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import type {
    BashOperations,
    EditOperations,
    ExtensionAPI,
    ExtensionContext,
    ReadOperations,
    WriteOperations,
} from "@earendil-works/pi-coding-agent";
import {
    createBashTool,
    createEditTool,
    createLocalBashOperations,
    createReadTool,
    createWriteTool,
} from "@earendil-works/pi-coding-agent";

// biome-ignore lint/complexity/useLiteralKeys: index signature
const NONO_PROFILE = process.env["NONO_PI_BASH_PROFILE"] ?? "pi";
const OUTSIDE_BASH_MARKER = "PI_NONO_OUTSIDE=1";
const PI_START_CWD = process.cwd();
const STARTED_INSIDE_NONO = Object.hasOwn(process.env, "NONO_CAP_FILE");

const allowedRoots = new Set<string>();
const approvedPathAccess = new Set<string>();

type SandboxMode = "off" | "confirm" | "nono";

function isSandboxMode(value: string): value is SandboxMode {
    return value === "off" || value === "confirm" || value === "nono";
}

function isProbablySandboxDenial(output: string): boolean {
    return /Operation not permitted|Permission denied|EACCES|EPERM|sandbox|landlock|seatbelt|nono:/i.test(
        output,
    );
}

function wantsOutsideSandbox(command: string): boolean {
    return command.trimStart().startsWith(OUTSIDE_BASH_MARKER);
}

function stripOutsideSandboxMarker(command: string): string {
    const trimmed = command.trimStart();
    return trimmed.startsWith(OUTSIDE_BASH_MARKER)
        ? trimmed.slice(OUTSIDE_BASH_MARKER.length).trimStart()
        : command;
}

function normalizeForDisplay(filePath: string): string {
    const relative = path.relative(PI_START_CWD, filePath);
    return relative && !relative.startsWith("..") && !path.isAbsolute(relative)
        ? relative
        : filePath;
}

function isInsideRoot(root: string, filePath: string): boolean {
    const relative = path.relative(root, filePath);
    return relative === "" || (!relative.startsWith("..") && !path.isAbsolute(relative));
}

async function canonicalizeExistingDirectory(dirPath: string): Promise<string> {
    dirPath = stripAtPrefixAndQuotes(dirPath);
    const absolute =
        dirPath.startsWith("~/") || dirPath === "~"
            ? path.join(os.homedir(), dirPath.slice(1))
            : path.resolve(PI_START_CWD, dirPath);
    const canonical = await realpath(absolute);
    const info = await stat(canonical);
    if (!info.isDirectory()) throw new Error(`${dirPath} is not a directory`);
    return canonical;
}

function stripAtPrefixAndQuotes(value: string): string {
    let result = value.trim();
    if (result.startsWith("@")) result = result.slice(1);
    if (
        (result.startsWith('"') && result.endsWith('"')) ||
        (result.startsWith("'") && result.endsWith("'"))
    ) {
        result = result.slice(1, -1);
    }
    return result;
}

async function canonicalizeTarget(targetPath: string): Promise<string> {
    const absolute = path.resolve(targetPath);
    try {
        return await realpath(absolute);
    } catch {
        let current = path.dirname(absolute);
        const missingParts = [path.basename(absolute)];

        while (true) {
            try {
                const existingParent = await realpath(current);
                return path.join(existingParent, ...missingParts.reverse());
            } catch {
                const parent = path.dirname(current);
                if (parent === current) return absolute;
                missingParts.push(path.basename(current));
                current = parent;
            }
        }
    }
}

async function isAllowedByRoot(targetPath: string): Promise<boolean> {
    const canonical = await canonicalizeTarget(targetPath);
    for (const root of allowedRoots) {
        if (isInsideRoot(root, canonical)) return true;
    }
    return false;
}

async function requirePathApproval(
    ctx: ExtensionContext,
    operation: "read" | "write" | "edit",
    targetPath: string,
): Promise<void> {
    if (await isAllowedByRoot(targetPath)) return;

    const canonical = await canonicalizeTarget(targetPath);
    const key = `${operation}:${canonical}`;
    if (approvedPathAccess.has(key)) return;

    if (!ctx.hasUI) {
        throw new Error(
            `${operation} denied for ${targetPath}: outside allowed directories and no UI is available for approval.`,
        );
    }

    const ok = await ctx.ui.confirm(
        `Approve ${operation} outside allowed directories?`,
        [
            `Path: ${normalizeForDisplay(canonical)}`,
            "",
            `Allowed roots this session:`,
            ...Array.from(allowedRoots).map((root) => `- ${normalizeForDisplay(root)}`),
            "",
            "Use /add-dir <path> to allow a directory for the rest of this session.",
        ].join("\n"),
    );

    if (!ok) throw new Error(`${operation} denied by user for ${targetPath}`);
    approvedPathAccess.add(key);
}

function detectImageMimeType(filePath: string): string | null {
    const ext = path.extname(filePath).toLowerCase();
    if (ext === ".png") return "image/png";
    if (ext === ".jpg" || ext === ".jpeg") return "image/jpeg";
    if (ext === ".gif") return "image/gif";
    if (ext === ".webp") return "image/webp";
    return null;
}

function createGatedReadOperations(ctx: ExtensionContext): ReadOperations {
    return {
        async access(filePath) {
            await requirePathApproval(ctx, "read", filePath);
            await access(filePath, constants.R_OK);
        },
        async readFile(filePath) {
            await requirePathApproval(ctx, "read", filePath);
            return readFile(filePath);
        },
        async detectImageMimeType(filePath) {
            await requirePathApproval(ctx, "read", filePath);
            return detectImageMimeType(filePath);
        },
    };
}

function createGatedWriteOperations(ctx: ExtensionContext): WriteOperations {
    return {
        async mkdir(dir) {
            await requirePathApproval(ctx, "write", dir);
            await mkdir(dir, { recursive: true });
        },
        async writeFile(filePath, content) {
            await requirePathApproval(ctx, "write", filePath);
            await writeFile(filePath, content, "utf8");
        },
    };
}

function createGatedEditOperations(ctx: ExtensionContext): EditOperations {
    return {
        async access(filePath) {
            await requirePathApproval(ctx, "edit", filePath);
            await access(filePath, constants.R_OK | constants.W_OK);
        },
        async readFile(filePath) {
            await requirePathApproval(ctx, "edit", filePath);
            return readFile(filePath);
        },
        async writeFile(filePath, content) {
            await requirePathApproval(ctx, "edit", filePath);
            await writeFile(filePath, content, "utf8");
        },
    };
}

function createNonoBashOperations(profile: string): BashOperations {
    return {
        exec(command, cwd, { onData, signal, timeout, env }) {
            return new Promise((resolve, reject) => {
                const child = spawn(
                    "nono",
                    [
                        "run",
                        "--silent",
                        "--profile",
                        profile,
                        "--allow",
                        PI_START_CWD,
                        ...allowedRoots.values().flatMap((r) => ["--allow", r]),
                        "--",
                        "bash",
                        "-lc",
                        command,
                    ],
                    {
                        cwd,
                        env,
                        stdio: ["ignore", "pipe", "pipe"],
                        detached: process.platform !== "win32",
                    },
                );

                let timedOut = false;
                const kill = () => {
                    if (!child.pid) return;
                    if (process.platform === "win32") child.kill();
                    else process.kill(-child.pid, "SIGTERM");
                };

                const timer =
                    timeout && timeout > 0
                        ? setTimeout(() => {
                              timedOut = true;
                              kill();
                          }, timeout * 1000)
                        : undefined;

                const abort = () => kill();
                signal?.addEventListener("abort", abort, { once: true });

                child.stdout.on("data", onData);
                child.stderr.on("data", onData);
                child.on("error", reject);
                child.on("exit", (code) => {
                    if (timer) clearTimeout(timer);
                    signal?.removeEventListener("abort", abort);

                    if (signal?.aborted) reject(new Error("aborted"));
                    else if (timedOut) reject(new Error(`timeout:${timeout}`));
                    else resolve({ exitCode: code });
                });
            });
        },
    };
}

function createApprovedFallbackBashOperations(ctx: ExtensionContext): BashOperations {
    const sandbox = createNonoBashOperations(NONO_PROFILE);
    const host = createLocalBashOperations();

    return {
        async exec(command, cwd, options) {
            const chunks: Buffer[] = [];
            const onData = (data: Buffer) => {
                chunks.push(Buffer.from(data));
                options.onData(data);
            };

            const sandboxResult = await sandbox.exec(command, cwd, { ...options, onData });
            const output = Buffer.concat(chunks).toString("utf8");
            if (sandboxResult.exitCode === 0 || !isProbablySandboxDenial(output))
                return sandboxResult;

            if (!ctx?.hasUI) return sandboxResult;

            const ok = await ctx.ui.confirm(
                "Run Bash outside nono sandbox?",
                [
                    "The sandboxed command appears to have been denied by nono or the OS sandbox.",
                    "",
                    "Command:",
                    command,
                    "",
                    "Run it outside the nono sandbox?",
                ].join("\n"),
            );

            if (!ok) return sandboxResult;

            options.onData(
                Buffer.from(
                    "\n[nono sandbox denied access; user approved outside-sandbox retry]\n",
                ),
            );
            return host.exec(command, cwd, options);
        },
    };
}

function allowedRootsSummary(): string {
    return Array.from(allowedRoots)
        .map((root) => `- ${normalizeForDisplay(root)}`)
        .join("\n");
}

async function requireBashConfirmation(ctx: ExtensionContext, command: string): Promise<void> {
    if (!ctx.hasUI) throw new Error("Bash blocked: no UI is available for confirmation.");

    const choice = await ctx.ui.select(`Execute bash command?\n\n  ${command}`, ["Allow", "Block"]);
    if (!choice || choice === "Block") throw new Error("Bash blocked by user.");
}

export default async function (pi: ExtensionAPI) {
    let mode: SandboxMode = STARTED_INSIDE_NONO ? "off" : "nono";

    const publishState = () => {
        pi.events.emit("nono:sbx:state", Object.freeze({ mode, enabled: mode !== "off" }));
    };

    const setStatus = (ctx: ExtensionContext) => {
        const status =
            mode === "nono"
                ? ctx.ui.theme.fg("accent", `nono bash: ${NONO_PROFILE}`)
                : mode === "confirm"
                  ? ctx.ui.theme.fg("accent", "bash confirmation")
                  : undefined;
        ctx.ui.setStatus("sbx", status);
    };

    const setMode = (nextMode: SandboxMode, ctx: ExtensionContext) => {
        mode = nextMode;
        setStatus(ctx);
        publishState();
    };

    allowedRoots.clear();
    approvedPathAccess.clear();
    allowedRoots.add(await canonicalizeExistingDirectory(PI_START_CWD));

    const baseRead = createReadTool(PI_START_CWD);
    const baseWrite = createWriteTool(PI_START_CWD);
    const baseEdit = createEditTool(PI_START_CWD);
    const baseBash = createBashTool(PI_START_CWD);
    const hostBash = createBashTool(PI_START_CWD);

    pi.registerCommand("sbx", {
        description: "Set sandbox mode: off, confirm, or nono (no argument toggles nono)",
        handler: async (args, ctx) => {
            const requestedMode = args.trim().toLowerCase();
            if (!requestedMode) {
                setMode(mode === "off" ? "nono" : "off", ctx);
            } else if (isSandboxMode(requestedMode)) {
                setMode(requestedMode, ctx);
            } else {
                ctx.ui.notify("Usage: /sbx [off|confirm|nono]", "error");
                return;
            }

            ctx.ui.notify(`Sandbox mode: ${mode}`, "info");
        },
    });

    pi.registerCommand("add-dir", {
        description: "Allow read/write/edit under a directory in nono mode",
        handler: async (args, ctx) => {
            if (mode !== "nono") {
                ctx.ui.notify("/add-dir is available only in nono mode; use /sbx nono.", "warning");
                return;
            }

            const input = args.trim();
            if (!input) {
                ctx.ui.notify(`Allowed directories:\n${allowedRootsSummary()}`, "info");
                return;
            }

            try {
                const dir = await canonicalizeExistingDirectory(input);
                allowedRoots.add(dir);
                ctx.ui.notify(`Allowed for this session: ${normalizeForDisplay(dir)}`, "info");
            } catch (error) {
                const message = error instanceof Error ? error.message : String(error);
                ctx.ui.notify(`Could not add directory: ${message}`, "error");
            }
        },
    });

    pi.registerTool({
        ...baseRead,
        async execute(id, params, signal, onUpdate, ctx) {
            if (mode !== "nono") return baseRead.execute(id, params, signal, onUpdate);

            const tool = createReadTool(PI_START_CWD, {
                operations: createGatedReadOperations(ctx),
            });
            return tool.execute(id, params, signal, onUpdate);
        },
    });

    pi.registerTool({
        ...baseWrite,
        async execute(id, params, signal, onUpdate, ctx) {
            if (mode !== "nono") return baseWrite.execute(id, params, signal, onUpdate);

            const tool = createWriteTool(PI_START_CWD, {
                operations: createGatedWriteOperations(ctx),
            });
            return tool.execute(id, params, signal, onUpdate);
        },
    });

    pi.registerTool({
        ...baseEdit,
        async execute(id, params, signal, onUpdate, ctx) {
            if (mode !== "nono") return baseEdit.execute(id, params, signal, onUpdate);

            const tool = createEditTool(PI_START_CWD, {
                operations: createGatedEditOperations(ctx),
            });
            return tool.execute(id, params, signal, onUpdate);
        },
    });

    pi.registerTool({
        ...baseBash,
        async execute(id, params, signal, onUpdate, ctx) {
            if (mode === "off") return baseBash.execute(id, params, signal, onUpdate);
            if (mode === "confirm") {
                await requireBashConfirmation(ctx, params.command);
                return baseBash.execute(id, params, signal, onUpdate);
            }

            if (wantsOutsideSandbox(params.command)) {
                const command = stripOutsideSandboxMarker(params.command);
                if (!ctx.hasUI)
                    throw new Error(
                        "Outside-sandbox Bash requires approval, but no UI is available.",
                    );

                const ok = await ctx.ui.confirm(
                    "Run Bash outside nono sandbox?",
                    [`Command:`, command].join("\n"),
                );
                if (!ok) throw new Error("Outside-sandbox Bash blocked by user.");

                return hostBash.execute(id, { ...params, command }, signal, onUpdate);
            }

            const tool = createBashTool(PI_START_CWD, {
                operations: createApprovedFallbackBashOperations(ctx),
            });
            return tool.execute(id, params, signal, onUpdate);
        },
    });

    pi.on("user_bash", (_event, ctx) => {
        if (mode !== "nono") return;
        return { operations: createApprovedFallbackBashOperations(ctx) };
    });

    pi.on("session_start", (_event, ctx) => {
        setStatus(ctx);
        publishState();
    });

    pi.on("session_shutdown", (_event, ctx) => {
        ctx.ui.setStatus("sbx", undefined);
    });

    pi.on("before_agent_start", (event) => {
        if (mode === "off") return;

        const policy =
            mode === "confirm"
                ? "- Bash commands require explicit user confirmation before execution."
                : [
                      `- Bash commands run inside a nono sandbox by default using profile \`${NONO_PROFILE}\`.`,
                      `- If Bash truly needs host/outside-sandbox access, prefix the command with \`${OUTSIDE_BASH_MARKER} \`; the user will be asked for approval.`,
                      "- read/write/edit are allowed without approval only under the directory where Pi started and directories added with /add-dir for this session. Other paths require user approval.",
                  ].join("\n");

        return {
            systemPrompt: `${event.systemPrompt}\n\nSecurity policy from pi-nono extension:\n${policy}`,
        };
    });
}
