import { readFileSync } from "node:fs";
import { verifyResponse } from "../../src/eval/tasks/ifeval";
const rows = readFileSync("/tmp/ifeval-ours.jsonl", "utf8").trim().split("\n").map((l) => JSON.parse(l));
let pass = 0;
for (const r of rows) {
  if (verifyResponse(r.response, r.instruction_id_list, r.kwargs).pass) pass++;
}
console.log(`our strict (FIXED verifier): ${pass}/${rows.length} = ${(pass / rows.length * 100).toFixed(1)}%   [his: 354/541=65.4%, published 64.7]`);
