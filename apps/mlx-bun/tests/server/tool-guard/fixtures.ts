// Shared with SafeAgents' tests/conftest.py (commit a8ee22d; Copyright 2026 the HuggingFace Inc. team, Apache License 2.0).
export const OSS = "example-bucket.oss-cn-beijing.aliyuncs.com";
type TestRequest = { messages: Record<string, unknown>[]; tools: Record<string, unknown>[] };
export const bashRequest = (user: string): TestRequest => ({
  messages: [{ role: "user", content: user }],
  tools: [{ type: "function", function: { name: "bash" } }],
});
