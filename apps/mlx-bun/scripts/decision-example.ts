/** Run against `mlx-bun serve <model>`:
 * bun apps/mlx-bun/scripts/decision-example.ts http://127.0.0.1:8080
 * Both protocols use the same question semantics and supplied answer values. */
export const decisionExampleInput = "I was charged twice for my order. Please refund the duplicate payment.";
const instructions = {
  refund: "Does the customer ask for a refund?",
  department: "Which team should handle this request?",
  severity: "How severe is the problem?",
};
const criteria = {
  "billing and refunds": "Payments, duplicate charges, and refunds",
  "technical support": "Software bugs and outages",
  "sales inquiries": "New purchases and upgrades",
};
const levels = ["Minor inconvenience", "Customer payment problem", "Service completely unavailable"];
export function decisionExampleRequests(model = "local") {
  return {
    openai: { model, input: decisionExampleInput, questions: [
      { name: "refund", type: "predicate", instructions: instructions.refund },
      { name: "department", type: "choice", instructions: instructions.department,
        choices: Object.entries(criteria).map(([value, description]) => ({ value, description })) },
      { name: "severity", type: "score", instructions: instructions.severity, levels: levels.map(label => ({ label })) },
    ] },
    jev: { model, state: decisionExampleInput, questions: {
      refund: { type: "noul", instructions: instructions.refund },
      department: { type: "choice", instructions: instructions.department, criteria },
      severity: { type: "score", instructions: instructions.severity, criteria: levels },
    } },
  };
}

export async function runDecisionExample(base: string, model = "local", send: typeof fetch = fetch) {
  const bodies = decisionExampleRequests(model);
  const post = async (path: string, body: unknown) => {
    const response = await send(new URL(path, base), { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(body) });
    const result = await response.json();
    if (!response.ok) throw new Error(`${path}: ${response.status} ${JSON.stringify(result)}`);
    return result;
  };
  const openai = await post("/v1/decisions", bodies.openai);
  const jev = await post("/v1/systemone", bodies.jev);
  // A generation request uses the same model id and loaded weights.
  const generation = await post("/v1/chat/completions", { model,
    messages: [{ role: "user", content: "Reply with the word ready." }], max_tokens: 8, temperature: 0,
    chat_template_kwargs: { enable_thinking: false } });
  return { openai, jev, generation };
}

if (import.meta.main) {
  if (process.argv.includes("--help")) {
    console.log("Usage: bun apps/mlx-bun/scripts/decision-example.ts [server-url] [model-id]\nRequires an existing mlx-bun server; downloads nothing.");
  } else console.log(JSON.stringify(await runDecisionExample(process.argv[2] ?? "http://127.0.0.1:8080", process.argv[3]), null, 2));
}
