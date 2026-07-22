// Capture small model-free constants by executing an exact archived Colibri pin.
//
// This is an explicit provenance operation, not part of ordinary fixture
// regeneration or tests. It never builds in or writes to the source checkout.
// It requires an already-installed NumPy Python and Apple clang/libomp; it does
// not install, download, serve, or load model weights.
//
// Recorded capture command:
//   bun scripts/capture-colibri-glm52-oracle.ts


import { createHash } from "node:crypto";
import {
  copyFileSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { basename, join, resolve } from "node:path";

const PIN = "44e489b196c9b7876b3d37a0570ebf1c6f90f54c";
const DEFAULT_ORACLE = "/Users/joshrossi/Code/colibri";
const DEFAULT_PYTHON = "/Users/joshrossi/Code/mlx-lm/.venv/bin/python";
const DEFAULT_OUT = resolve(import.meta.dir, "../fixtures/colibri-glm52/oracle-capture.json");
const decoder = new TextDecoder();

interface Options {
  oracle: string;
  python: string;
  out: string;
}

function parseOptions(args: string[]): Options {
  const options: Options = { oracle: DEFAULT_ORACLE, python: DEFAULT_PYTHON, out: DEFAULT_OUT };
  for (let i = 0; i < args.length; i++) {
    const flag = args[i];
    const value = args[++i];
    if (!value) throw new Error(`${flag} requires a value`);
    if (flag === "--oracle") options.oracle = resolve(value);
    else if (flag === "--python") options.python = resolve(value);
    else if (flag === "--out") options.out = resolve(value);
    else throw new Error(`unknown argument: ${flag}`);
  }
  return options;
}

function run(argv: string[], cwd: string): string {
  const result = Bun.spawnSync(argv, { cwd, stdout: "pipe", stderr: "pipe" });
  const stdout = decoder.decode(result.stdout);
  const stderr = decoder.decode(result.stderr);
  if (result.exitCode !== 0) {
    throw new Error(`capture command failed (${result.exitCode}): ${argv.join(" ")}\n${stdout}${stderr}`);
  }
  return stdout.trim();
}

function sha256(path: string): string {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
}

const options = parseOptions(process.argv.slice(2));
const repoRoot = resolve(import.meta.dir, "..");
const captureOrchestrator = resolve(import.meta.dir, "capture-colibri-glm52-oracle.ts");
const pythonHelper = resolve(import.meta.dir, "colibri-glm52-capture.py");
const cHelper = resolve(import.meta.dir, "colibri-glm52-capture.c");

const head = run(["git", "rev-parse", "HEAD"], options.oracle);
if (head !== PIN) throw new Error(`oracle HEAD ${head} != required pin ${PIN}`);
if (run(["git", "status", "--porcelain=v1", "--untracked-files=all"], options.oracle) !== "") {
  throw new Error("oracle checkout is not clean");
}
run(["git", "diff", "--quiet"], options.oracle);
run(["git", "diff", "--cached", "--quiet"], options.oracle);

const temp = mkdtempSync(join(tmpdir(), "mlx-bun-colibri-capture-"));
const archivePath = join(temp, "colibri.tar");
const sourceRoot = join(temp, "source");
const quantJson = join(temp, "quant.json");
const captureSource = join(sourceRoot, "c/tests/mlx_bun_capture.c");
const captureHeader = join(sourceRoot, "c/tests/capture_quant.h");
const captureBinary = join(temp, "colibri-capture");
const executedCommands: string[] = [];

try {
  mkdirSync(sourceRoot, { recursive: true });
  const archiveArgs = ["git", "archive", "--format=tar", `--output=${archivePath}`, PIN];
  run(archiveArgs, options.oracle);
  executedCommands.push(`git -C ${options.oracle} ${archiveArgs.slice(1).join(" ")}`);
  const tarArgs = ["tar", "-xf", archivePath, "-C", sourceRoot];
  run(tarArgs, repoRoot);
  executedCommands.push(tarArgs.join(" "));

  const pythonArgs = [
    options.python,
    pythonHelper,
    "--source-root", sourceRoot,
    "--json-out", quantJson,
    "--header-out", captureHeader,
  ];
  run(pythonArgs, repoRoot);
  executedCommands.push(pythonArgs.join(" "));
  copyFileSync(cHelper, captureSource);

  const clangArgs = [
    "/usr/bin/clang",
    "-O3",
    "-Xclang", "-fopenmp",
    "-I/opt/homebrew/opt/libomp/include",
    "-Wall", "-Wextra", "-Wno-unused-parameter", "-Wno-misleading-indentation",
    "-Wno-unused-function",
    captureSource,
    "-o", captureBinary,
    "-lm",
    "-L/opt/homebrew/opt/libomp/lib", "-lomp",
  ];
  run(clangArgs, join(sourceRoot, "c"));
  executedCommands.push(clangArgs.join(" "));
  const cCaptureText = run([captureBinary], temp);
  executedCommands.push(captureBinary);

  const pythonVersion = JSON.parse(run([
    options.python,
    "-c",
    "import json,platform,sys,numpy; print(json.dumps({'executable':sys.executable,'version':sys.version,'implementation':platform.python_implementation(),'numpy':numpy.__version__}))",
  ], repoRoot));

  const sourceFiles = [
    "c/tools/convert_fp8_to_int4.py",
    "c/glm.c",
    "c/tier.h",
    "c/tests/test_dsa_select.c",
    "c/tests/test_tier.c",
  ];
  const gitBlobs: Record<string, { git_blob: string; sha256: string }> = {};
  for (const path of sourceFiles) {
    gitBlobs[path] = {
      git_blob: run(["git", "rev-parse", `${PIN}:${path}`], options.oracle),
      sha256: sha256(join(sourceRoot, path)),
    };
  }

  const capture = {
    schema_version: 1,
    capture_kind: "exact_pin_model_free_capture",
    captured_at_utc: new Date().toISOString(),
    oracle: {
      repository: "https://github.com/JustVugg/colibri",
      commit: PIN,
      git_tree: run(["git", "rev-parse", `${PIN}^{tree}`], options.oracle),
      source_files: gitBlobs,
      checkout_path_advisory_capture_host_only: options.oracle,
      checkout_precondition: {
        head_exact: true,
        porcelain_empty: true,
        worktree_diff_exit: 0,
        index_diff_exit: 0,
      },
    },
    capture_harness: {
      archive_isolation: true,
      external_checkout_mutated: false,
      model_weights_used: false,
      network_used: false,
      validation_commands_exact_capture_host: [
        `git -C ${options.oracle} rev-parse HEAD`,
        `git -C ${options.oracle} status --porcelain=v1 --untracked-files=all`,
        `git -C ${options.oracle} diff --quiet`,
        `git -C ${options.oracle} diff --cached --quiet`,
      ],
      commands_exact_capture_host: executedCommands,
      helpers: {
        [basename(captureOrchestrator)]: sha256(captureOrchestrator),
        [basename(pythonHelper)]: sha256(pythonHelper),
        [basename(cHelper)]: sha256(cHelper),
      },
    },
    target: {
      os: process.platform,
      arch: process.arch,
      uname_machine: run(["uname", "-m"], repoRoot),
      chip: run(["sysctl", "-n", "machdep.cpu.brand_string"], repoRoot),
      macos_product: run(["sw_vers", "-productVersion"], repoRoot),
      macos_build: run(["sw_vers", "-buildVersion"], repoRoot),
    },
    toolchain: {
      apple_clang: run(["/usr/bin/clang", "--version"], repoRoot),
      python: pythonVersion,
      bun: {
        executable: process.execPath,
        version: run([process.execPath, "--version"], repoRoot),
      },
    },
    provenance: {
      quantization: "direct_capture_from_archived_pinned_python_functions",
      quantized_matmul: "direct_capture_from_archived_pinned_arm_neon_functions",
      dsa: "direct_capture_from_archived_pinned_partial_select_desc",
      lfru: "direct_capture_from_archived_pinned_tier_functions",
      rmsnorm_and_sigmoid: "direct_capture_from_archived_pinned_c_functions",
    },
    constants: {
      python: JSON.parse(readFileSync(quantJson, "utf8")),
      c: JSON.parse(cCaptureText),
    },
  };

  mkdirSync(resolve(options.out, ".."), { recursive: true });
  await Bun.write(options.out, `${JSON.stringify(capture, null, 2)}\n`);
  console.log(`wrote ${options.out}`);
  console.log(`sha256 ${sha256(options.out)}`);
} finally {
  rmSync(temp, { recursive: true, force: true });
}
