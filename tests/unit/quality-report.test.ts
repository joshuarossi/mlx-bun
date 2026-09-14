import { expect, test } from "bun:test";
import { existsSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { QualityDB } from "../../src/eval/quality-db";
import { exportQuality, validateQualityReport } from "../../scripts/bench/quality-report";
import { buildReportModel, loadRawReport, renderHtml } from "../../scripts/bench/report";

test("quality export reads committed ledger rows without changing the database", async () => {
  const dir = mkdtempSync(join(tmpdir(),"mlx-quality-report-"));
  try {
    const path = join(dir,"evals.sqlite"), db = new QualityDB(path);
    const modelPath = '</script><img src=x onerror="alert(1)">';
    db.record({ modelPath, task:"mmlu", config:{compiledDecode:"1"}, nSamples:50, pct:80,
      diskGb:12, machineState:JSON.stringify({host:"test",chip:"test chip",ram_gb:24}),notes:"<b>saved text</b>" });
    db.record({ modelPath, task:"kl", config:{}, nSamples:16, klMean:0.155,klRef:"reference",diskGb:0 });
    db.close();
    const before = readFileSync(path);
    const report = exportQuality(path);
    expect(readFileSync(path)).toEqual(before);
    expect(report.rows).toHaveLength(2);
    expect(report.rows[0]!.model_path).toBe(modelPath);
    expect(report.rows[1]!.pct).toBeNull();
    const out = join(dir,"quality.json");
    const cli = Bun.spawnSync([process.execPath,"scripts/bench/quality-report.ts","--db",path,"--out",out]);
    expect(cli.exitCode).toBe(0);
    expect(JSON.parse(cli.stdout.toString()).rows).toBe(2);
    const input = loadRawReport(out);
    expect(input.kind).toBe("quality");
    const model = buildReportModel([input]);
    expect(model.serveRows).toHaveLength(0);
    expect(model.nativeRows).toHaveLength(0);
    expect(model.taskRows).toHaveLength(0);
    const html = renderHtml(model);
    expect(html).not.toContain(modelPath);
    expect(html).toContain("&lt;img");
    expect(html).toContain("80.00");
    expect(html).toContain("0.15500");
    expect(html).toContain("12.000");
    expect(html).toContain("not recorded");
    expect(html.match(/<circle /g)).toHaveLength(1);
    expect(html).toContain("Dataset revision, sample selection and artifact content hashes are not guaranteed");
    expect(input.sha256).toHaveLength(64);
    const missing = join(dir,"absent.sqlite");
    expect(()=>exportQuality(missing)).toThrow();
    expect(existsSync(missing)).toBe(false);
  } finally { rmSync(dir,{recursive:true,force:true}); }
});

test("malformed quality records fail with source and field", () => {
  const base = {kind:"model-quality-ledger",schemaVersion:1,exportedAt:"now",sourceDatabase:"db",rows:[]};
  expect(validateQualityReport(base,"q").rows).toHaveLength(0);
  expect(()=>validateQualityReport({...base,schemaVersion:2},"q")).toThrow("schema 1");
  const row={id:1,ts:1,model_path:"artifact",task:"mmlu",config_json:"{}",n_samples:50,pct:NaN};
  expect(()=>validateQualityReport({...base,rows:[row]},"bad.json")).toThrow("bad.json: row 0 has invalid pct");
  expect(()=>validateQualityReport({...base,rows:[{...row,pct:50,n_samples:-1}]},"q")).toThrow("n_samples");
});
