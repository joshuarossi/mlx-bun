// Opt-in acceptance for the Docker Python verifier with real containers. After
// provisioning the image (app README, Dataset jobs), from apps/mlx-bun:
//
//   MLX_BUN_TEST_DOCKER_VERIFIER=1 MLX_BUN_TEST_DOCKER_IMAGE='python@sha256:<digest>' \
//     bun test tests/dataset/python-verifier-docker.test.ts
//
// The image must already be present for linux/arm64: nothing is pulled. Each
// case then checks that no verifier container remains. Skipped without the flag.
import { afterEach, beforeAll, describe, expect, test } from "bun:test";
import { hostname } from "node:os";
import { resolve } from "node:path";
import { createPythonVerifier, PYTHON_VERIFIER_LIMITS, PYTHON_VERIFIER_OWNER_LABEL } from "../../src/dataset/python-verifier";

const enabled = process.env.MLX_BUN_TEST_DOCKER_VERIFIER === "1";
const image = process.env.MLX_BUN_TEST_DOCKER_IMAGE ?? "";
const dockerEnv = { PATH: process.env.PATH ?? "", ...(process.env.DOCKER_HOST ? { DOCKER_HOST: process.env.DOCKER_HOST } : {}) };
const CASE_MS = 60_000;

function docker(...args: string[]) {
  const child = Bun.spawnSync(["docker", ...args], { env: dockerEnv });
  return { code: child.exitCode, stdout: child.stdout.toString().trim(), stderr: child.stderr.toString().trim() };
}
function verifierContainers(): string[] {
  const listed = docker("ps", "--all", "--filter", "name=mlx-bun-python-verify-", "--format", "{{.Names}}");
  if (listed.code !== 0) throw new Error(`docker ps failed: ${listed.stderr}`);
  return listed.stdout.split("\n").filter(Boolean).sort();
}

describe.skipIf(!enabled)("Docker Python verifier acceptance", () => {
  const verify = createPythonVerifier({ image, dockerHost: process.env.DOCKER_HOST });
  let existing: string[] = [];
  beforeAll(() => {
    if (!enabled) return;
    if (!/@sha256:[0-9a-f]{64}$/.test(image)) throw new Error("MLX_BUN_TEST_DOCKER_IMAGE must name the provisioned image by digest");
    const platform = docker("image", "inspect", "--format", "{{.Os}}/{{.Architecture}}", image);
    if (platform.code !== 0 || platform.stdout !== "linux/arm64")
      throw new Error(`provision ${image} first: docker pull --platform linux/arm64 ${image} (${platform.stderr || platform.stdout})`);
    existing = verifierContainers();
  });
  afterEach(() => { if (enabled) expect(verifierContainers()).toEqual(existing); });

  test("a passing program is verified", async () => {
    expect(await verify("def inc(x):\n    return x + 1\n\nassert inc(1) == 2\nassert inc(-1) == 0\n")).toEqual({ status: "verified" });
  }, CASE_MS);

  test("a failing assertion fails with its traceback", async () => {
    const result = await verify("def inc(x):\n    return x\n\nassert inc(1) == 2, 'off by one'\n");
    expect(result).toMatchObject({ status: "failed", exitCode: 1 });
    expect(result.status === "failed" && result.error).toContain("AssertionError: off by one");
  }, CASE_MS);

  test("an image that is not present is unverified and is not pulled", async () => {
    const absent = `${image.slice(0, image.indexOf("@"))}@sha256:${"0".repeat(64)}`;
    expect(await createPythonVerifier({ image: absent, dockerHost: process.env.DOCKER_HOST })("assert True\n"))
      .toMatchObject({ status: "unverified", reason: "image-missing" });
    expect(docker("image", "inspect", absent).code).not.toBe(0);
  }, CASE_MS);

  test("the program can write only /tmp, and cannot see host files or environment, hold privileges, or reach the network", async () => {
    process.env.MLX_BUN_VERIFIER_CANARY = "host-secret";
    try {
      const program = `import os, socket
open("/tmp/probe", "w").write("x")
assert open("/tmp/probe").read() == "x"
for path in ["/probe", "/dev/shm/probe", "/root/probe", "/home/probe"]:
    try:
        open(path, "w").write("x")
    except OSError:
        pass
    else:
        raise SystemExit("wrote " + path)
assert not os.path.exists(${JSON.stringify(process.env.HOME ?? "/Users")}), "host home is visible"
assert "MLX_BUN_VERIFIER_CANARY" not in os.environ, "host environment leaked"
assert (os.getuid(), os.getgid()) == (65534, 65534)
status = open("/proc/self/status").read()
assert "CapEff:\\t0000000000000000" in status, status
assert "NoNewPrivs:\\t1" in status, status
assert "Seccomp:\\t2" in status, status
# Some kernels (Docker Desktop's) create fallback tunnel devices in every
# namespace; they stay down and the program cannot raise them.
up = [n for n in os.listdir("/sys/class/net") if n != "lo" and os.path.isdir("/sys/class/net/" + n)
      and int(open("/sys/class/net/" + n + "/flags").read(), 16) & 1]
assert up == [], up
for attempt in (lambda: socket.create_connection(("1.1.1.1", 53), timeout=2), lambda: socket.getaddrinfo("example.com", 80)):
    try:
        attempt()
    except OSError:
        pass
    else:
        raise SystemExit("network reachable")
`;
      expect(await verify(program)).toEqual({ status: "verified" });
    } finally { delete process.env.MLX_BUN_VERIFIER_CANARY; }
  }, CASE_MS);

  test("a verifier removes a leftover container whose owner on this host is gone", async () => {
    const gone = Bun.spawnSync(["true"]).pid;
    const leftover = `mlx-bun-python-verify-leftover-${gone}`;
    const created = docker("create", "--label", `${PYTHON_VERIFIER_OWNER_LABEL}=${hostname()}:${gone}`, "--name", leftover, image, "true");
    expect(created.code, created.stderr).toBe(0);
    expect(await createPythonVerifier({ image, dockerHost: process.env.DOCKER_HOST })("assert True\n")).toEqual({ status: "verified" });
    expect(verifierContainers()).not.toContain(leftover);
  }, CASE_MS);

  test("flooding output is cut off and unverified", async () => {
    expect(await verify("import sys\nwhile True:\n    sys.stdout.write('x' * 65536)\n"))
      .toMatchObject({ status: "unverified", reason: "output-overflow" });
  }, CASE_MS);

  test("a program that runs past the time limit is stopped and unverified", async () => {
    const started = performance.now();
    expect(await verify("while True:\n    pass\n")).toMatchObject({ status: "unverified", reason: "timeout" });
    expect(performance.now() - started).toBeGreaterThanOrEqual(PYTHON_VERIFIER_LIMITS.runMs);
    expect(performance.now() - started).toBeLessThan(PYTHON_VERIFIER_LIMITS.runMs + PYTHON_VERIFIER_LIMITS.commandMs);
  }, CASE_MS);

  test("cancellation stops a running program promptly and is unverified", async () => {
    const abort = new AbortController();
    const started = performance.now();
    setTimeout(() => abort.abort(), 2_000);
    expect(await verify("import time\nwhile True:\n    time.sleep(1)\n", abort.signal)).toMatchObject({ status: "unverified", reason: "cancelled" });
    expect(performance.now() - started).toBeLessThan(10_000);
  }, CASE_MS);

  test("exceeding the memory limit is unverified", async () => {
    expect(await verify("data = b'x' * (1024 ** 3)\n")).toMatchObject({ status: "unverified", reason: "oom" });
  }, CASE_MS);

  test("the standalone runner uses the same verifier and removes the container on SIGTERM", async () => {
    const script = resolve(import.meta.dir, "../../scripts/verify-python.ts");
    const run = (source: string) => Bun.spawn([process.execPath, "--no-env-file", script, "--image", image],
      { stdin: Buffer.from(source), stdout: "pipe", stderr: "pipe" });
    const passing = run("assert sorted([3, 1, 2]) == [1, 2, 3]\n");
    expect(await passing.exited).toBe(0);
    expect(JSON.parse(await new Response(passing.stdout).text())).toEqual({ status: "verified" });
    const failing = run("assert sorted([3, 1, 2]) == [3, 2, 1]\n");
    expect(await failing.exited).toBe(1);
    expect(JSON.parse(await new Response(failing.stdout).text())).toMatchObject({ status: "failed", exitCode: 1 });
    const sleeping = run("import time\ntime.sleep(60)\n");
    for (let i = 0; verifierContainers().length === existing.length; i++) {
      if (i > 100) throw new Error("the runner never created its container");
      await Bun.sleep(100);
    }
    sleeping.kill("SIGTERM");
    expect(await sleeping.exited).toBe(2);
    expect(JSON.parse(await new Response(sleeping.stdout).text())).toMatchObject({ status: "unverified", reason: "cancelled" });
  }, CASE_MS);
});
