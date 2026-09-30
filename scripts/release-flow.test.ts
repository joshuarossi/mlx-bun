import { expect, test } from "bun:test";
import { chmod, copyFile, mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

test("ported publishing flow uses reviewed artifacts, GitHub, tap and workspace npm; dirty source stops it", async () => {
  const root = await mkdtemp(join(tmpdir(), "mlx-release-flow-"));
  try {
    await mkdir(join(root, "scripts")); await mkdir(join(root, "tools")); await mkdir(join(root, "out")); await mkdir(join(root, "prepared/release"), { recursive: true });
    await copyFile(join(import.meta.dir, "publish-release.sh"), join(root, "scripts/publish-release.sh"));
    await writeFile(join(root, "notes.md"), "Reviewed release notes\n");
    for (const name of ["mlx-bun-v0.6.0-arm64.tar.gz", "mlx-bun-arm64.tar.gz"]) {
      await writeFile(join(root, "out", name), "accepted archive"); await writeFile(join(root, "out", `${name}.sha256`), "checksum");
      await writeFile(join(root, "prepared/release", name), "accepted archive");
    }
    const log = join(root, "commands.jsonl");
    // All publication commands are temporary recording executables. Nothing
    // here can contact GitHub/npm, use a signing key or run a benchmark.
    const stub = `#!${process.execPath}
import {appendFileSync,mkdirSync,writeFileSync} from "node:fs";
import {basename,join} from "node:path";
const name=basename(process.argv[1]);const args=process.argv.slice(2);
appendFileSync(process.env.RELEASE_TEST_LOG,JSON.stringify({name,args})+"\\n");
if(name==="npm")console.log("test-user");
else if(name==="bun"){
 if(args.includes("-e"))console.log(args.join(" ").includes("apps/mlx-bun/package.json")?"0.6.0":"a".repeat(40));
 else if(!args.includes("scripts/release-inputs.ts"))throw Error("Unexpected Bun command");
}else if(name==="gh"){
 if(args[0]==="release"&&args[1]==="view")process.exit(1);
}else if(name==="git"){
 if(args[0]==="diff")process.exit(process.env.RELEASE_TEST_DIRTY==="1"?1:0);
 if(args[0]==="rev-parse")console.log("a".repeat(40));
 if(args.includes("clone")){const dir=join(args[1],"tap/Formula");mkdirSync(dir,{recursive:true});writeFileSync(join(dir,"mlx-bun.rb"),'class MlxBun < Formula\\n  version "0.5.0"\\n  url "old"\\n  sha256 "old"\\nend\\n');}
 if(args[0]==="-C"&&args.includes("diff"))process.exit(1);
}else throw Error("Unexpected tool");
`;
    for (const name of ["bun", "npm", "gh", "git"]) { const path = join(root, "tools", name); await writeFile(path, stub); await chmod(path, 0o755); }
    const run = async (dirty = false) => {
      const child = Bun.spawn(["/bin/sh", join(root, "scripts/publish-release.sh")], { cwd: root, stdout: "pipe", stderr: "pipe", env: { ...process.env,
        PATH: `${join(root, "tools")}:${process.env.PATH}`, OUT_DIR: join(root, "out"), BUILD_DIR: join(root, "prepared"), RELEASE_NOTES: join(root, "notes.md"),
        RELEASE_TEST_LOG: log, RELEASE_TEST_DIRTY: dirty ? "1" : "0", RELEASE_SKIP_GIT_CHECK: "0" } });
      const [out, err, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
      return { out, err, code };
    };
    const result = await run(); expect(result.code).toBe(0); expect(result.out).toContain("done — all channels");
    const commands = (await readFile(log, "utf8")).trim().split("\n").map(line => JSON.parse(line) as { name: string; args: string[] });
    const release = commands.find(command => command.name === "gh" && command.args[1] === "create")!;
    expect(release.args).toContain(join(root, "notes.md")); expect(release.args).toContain("a".repeat(40));
    expect(release.args).toContain(join(root, "out/mlx-bun-v0.6.0-arm64.tar.gz.sha256"));
    expect(commands.some(command => command.name === "git" && command.args.includes("push"))).toBe(true);
    expect(commands.at(-1)).toMatchObject({ name: "bun", args: ["--no-env-file", "scripts/release-inputs.ts", "npm", join(root, "prepared"), join(root, "notes.md")] });
    await writeFile(log, ""); const dirty = await run(true); expect(dirty.code).toBe(1); expect(dirty.err).toContain("working tree is dirty");
    expect((await readFile(log, "utf8")).includes('"name":"gh"')).toBe(false);
  } finally { await rm(root, { recursive: true, force: true }); }
});
