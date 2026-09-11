import { expect, test } from "bun:test";
import { foreignProcessFindings } from "../../src/preflight";

test("a permitted CPU command stays visible without bypassing memory limits", () => {
  const command = "/usr/libexec/audiomxd";
  const sample = `77 13312 ${command}`;
  expect(foreignProcessFindings(sample).bigProcesses).toHaveLength(1);
  const allowed = foreignProcessFindings(sample, { allowCpuProcesses: [command] });
  expect(allowed.bigProcesses).toHaveLength(0);
  expect(allowed.backgroundCpuProcesses).toEqual([{ rssMB: 13, command: `${command} (77% cpu)` }]);
  expect(foreignProcessFindings(`77 3145728 ${command}`, {
    allowCpuProcesses: [command],
  }).bigProcesses).toHaveLength(1);
});

test("CPU allowances match the whole command and do not exempt other work", () => {
  const found = foreignProcessFindings(
    "77 13312 /usr/libexec/audiomxd-extra\n85 1024 /opt/worker --gpu", {
      allowCpuProcesses: ["/usr/libexec/audiomxd"],
    });
  expect(found.bigProcesses).toHaveLength(2);
  expect(found.backgroundCpuProcesses).toHaveLength(0);
});
