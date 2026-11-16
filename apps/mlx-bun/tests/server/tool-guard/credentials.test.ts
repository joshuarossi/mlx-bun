// Cases ported from atif-scan 0.8.23 (commit 3bbaf3c; Copyright (c) 2026 Hugging Face, MIT License):
// tests/test_credentials_context.py, test_webhook_credentials.py, and the credential cases of test_side_channel.py and
// test_detectors_review.py. Synthetic, unissued credentials only; no URL is ever contacted.
//
// Skipped Python cases and assertions (not ported, with the reason):
// - every assertion on `evidence.cite` (`cite`, its `mask`, `trace_secrets`): citations are not ported. Where a Python
//   case asserts on both `credentials.mask` and cite's `mask`, the `credentials.mask` half is kept.
// - test_credentials_context: test_single_character_assignment_does_not_corrupt_prompt (cite only);
//   the `spec.version == "10"` assertion (specs carry no version).
// - test_webhook_credentials: test_bounded_constant_assembly_redacts_contributors_and_repeats,
//   test_split_components_propagate_but_short_common_fragments_do_not,
//   test_source_literal_escapes_and_same_line_unicode_keep_redaction_provenance (URLs assembled from Python string
//   constants are recovered with Python's `ast`; "assembled from constants" below pins what this port does instead);
//   test_source_recovery_has_finite_limits_and_preserves_direct_recognition, test_trace_wide_citations…,
//   test_viewer_full_and_reports…, test_native_auth_carrier… and later (cite, viewer, CLI, outbound_credentials);
//   the frozen-dataclass and repr assertions of test_shared_api_is_frozen… (no Python object model).
// - test_side_channel: test_credentials_detected_and_masked asserts on cite's `mask`; here the same texts are checked
//   against `credentials.mask` (adapted, not the same function).
import { describe, expect, test } from "bun:test";
import * as c from "../../../src/server/tool-guard/scan/credentials";
import { CredentialExposure } from "../../../src/server/tool-guard/scan/detectors/side-channel";
import { parseTrace } from "../../../src/server/tool-guard/scan/trace";
import * as webhooks from "../../../src/server/tool-guard/scan/webhooks";

const KEY = "LLM|123456789012|syntheticCredential98765";
const OPAQUE = "OpaqueSynthetic8274";
const exposures = (text: string): c.Found[] => [...c.findExposures(text)];
const found = (text: string): c.Found[] => [...c.find(text)];
/** The exposure check over one agent message. */
const exposed = (text: string): string => new CredentialExposure().evaluate(parseTrace([{ source: "agent", message: text }])).status;

describe("credential shapes (test_side_channel.py)", () => {
  test.each([
    KEY,
    `OPENAI_API_KEY=${KEY}`,
    `os.environ["OPENAI_API_KEY"]="${KEY}"`,
    'api_key="opaqueCredential98765"',
    "--api-key opaqueCredential98765",
    "x-api-key: opaqueCredential98765",
    "STRIPE_SECRET_KEY=opaqueCredential98765",
    "sk-proj-abcdEFGH1234ijklMNOP",
    "git clone --token opaqueCredential98765 repo",
    "DB_PASSWORD=Opaque98765+/abc==",
    'password: "svc_pass_2026"',
    "CLAUDE_CODE_MESSAGING_TOKEN=0123456789abcdef0123456789abcdef",
    // Sandbox control-plane and cluster API headers (DeepSeek TB4 hf-sandbox shapes).
    'curl -H "X-Sandbox-Token: opaqueCredential98765" http://127.0.0.1:49983/files',
    "-H 'Authorization: Bearer opaqueCredential98765' https://kubernetes.default.svc/",
    "Proxy-Authorization: Bearer opaqueCredential98765",
  ])("credentials are detected and masked: %s", text => {
    expect(found(text).length).toBeGreaterThan(0);
    expect(c.mask(text)).not.toContain(KEY);
    expect(c.mask(text)).not.toContain("opaqueCredential98765");
  });

  test.each([
    "TIKTOKEN_CACHE_DIR=/root/cache MAX_TOKENS=5000 TOKENIZERS_PARALLELISM=false",
    'SSH_KEY_PATH="/root/.ssh/id" MY_TOKEN=${TOKEN}',
    'api_key="your-key"',
    "env",
    // Regressions from TB2.1 Claude Code traces: code and public keys, not secrets.
    "predicted = max(scores, key=scores.get)",
    "largest = max(contours, key=cv2.contourArea)\\n",
    'const key = "SPECIAL_" + fn.toString(16);',
    "KeyError: 'adapt_engaged_setting'",
    '{"apiKeySource": "ANTHROPIC_API_KEY"}',
    '"captchaApiKey":"6LcFakeSiteKey0123456789","stripePublicKey":"pk_live_abcDEF123456"',
    "openssl pkcs12 -password=KEY_PASSWORD -in cert.pem",
    "(define (rk-free-variables-list expr) ...)",
    "compare per-token probabilities; a multi-token approach.",
    "keyUsage = digitalSignature,keyEncipherment",
    "out = model(x, past_key_values=cache.past_values, src_key_padding_mask=mask_tensor)",
    "token_owner=list_owner_address, secret_oid=3f2a9c1b7d4e5f60",
    'token_chars = "ABCDEFGHIJ"',
    "docker run --secret=<secret-id>] secret=cfg[secret_name]",
    "askpass -password SSH_ASKPASS_REQUIRE=force",
    // Regressions from TB4 traces: public signing keys and identifiers.
    "GPG_KEY=0123456789ABCDEF0123456789ABCDEF01234567 HOME=/root",
    'rate_key = "embedding_lr" if key == "embedding" else "head_lr"',
    '<Lookup primaryKey="customer_id" displayKey="displayName" />',
    "primary_key: 'account_ref', sort_key: 'createdAt'",
    "token = 'identifier_tail'",
    'STATE_KEY = "cutover:state" INFLIGHT_KEY = "app:inflight_writes"',
    'STORE_KEY = "__store_marker__"',
    "key_r = 'model.layers.0.mlp.weight'",
  ])("non-secrets are not detected: %s", text => {
    expect(found(text)).toEqual([]);
  });

  test("known mask: empty and overlapping values", () => {
    expect(c.mask("abababa", ["", "ababa"])).toBe("***");
  });

  test("a long non-secret assignment candidate", () => {
    // Regression: retrying the keyed regex at every character used quadratic time.
    expect(found("a".repeat(100_000))).toEqual([]);
  });

  // test_detectors_review.py: one example per TOKEN_SHAPES alternative, each starting with a lookahead character.
  test.each([
    "-----BEGIN RSA PRIVATE KEY-----\nabc\n-----END RSA PRIVATE KEY-----",
    "sk-proj-abcdefgh12345678",
    `hf_${"a1".repeat(12)}`,
    `ghp_${"b2".repeat(12)}`,
    `github_pat_${"c3".repeat(12)}`,
    "xoxb-1234567890abc",
    "AKIAA1B2C3D4E5F6G7H8",
    `AIza${"d".repeat(35)}`,
    "eyJhbGciOiJIUzI1.eyJzdWIiOiIxMjM0.dozjgNryP4J3jVmN",
    "LLM|1234567|abcdefghijklmn",
  ])("each token shape is found whole: %s", example => {
    expect(found(example)[0]!.span).toEqual([0, example.length]);
    expect("-sprhgxAeL").toContain(example[0]!);
  });
});

describe("credential context (test_credentials_context.py)", () => {
  const LOOKUP_NAMES = [
    "SettingsKey", "EnabledKey", "SettingKey", "analysis_key", "IMPLICIT_METHOD_SCOPE_KEY", "ATOMIC_PLUGIN_KEY", "consistentHashMergeKey",
    "listMapKey", "mergeKeyConsistentHash", "routing_key", "x-dead-letter-routing-key", "descriptionKey", "optionsKey", "CIRCUIT_HANDLE_KEY",
    "add-foreign-key",
    // Unrelated identifiers exercise structural families, not memorized pairs.
    "requestScopeKey", "rendererPluginKey", "resourceHandleKey", "recordMapKey", "tenantSettingsKey", "queueRoutingKey", "recordMergeKey",
    "tableForeignKey", "widgetDescriptionKey", "match_key", "recordMatchKey", "MATCH_KEY",
  ];
  const TEMPLATES = [(name: string, value: string) => `${name} = "${value}"`, (name: string, value: string) => `"${name}": "${value}"`];

  test.each(LOOKUP_NAMES.flatMap(name => TEMPLATES.map(template => [template(name, OPAQUE)])))("lookup names are not exposure but still masked: %s", text => {
    expect(exposures(text)).toEqual([]);
    expect(found(text).length).toBeGreaterThan(0);
    expect(c.values([text]).has(OPAQUE)).toBe(true);
    expect(c.mask(text)).not.toContain(OPAQUE);
    expect(c.mask(OPAQUE, c.values([text]))).toBe("***");
    expect(exposed(text)).toBe("no_match");
  });

  test.each([
    "SettingApiKey", "analysis_secret", "routing_auth_key", "ATOMIC_PLUGIN_ACCESS_KEY", "CIRCUIT_HANDLE_PASSWORD", "optionsToken", "MERGE_PRIVATE_KEY",
    "unfamiliar_key", "ZEPHYR_API_KEY", "requestScopeApiKey", "rendererPluginSecret", "resourceHandleAuthKey", "recordMapAccessKey",
    "mapping_key", // substrings are not structural components
    "scoped_key", "match_api_key", "matching_key",
  ])("explicit authentication and unknown names remain candidates: %s", name => {
    expect(exposures(`${name}="${OPAQUE}"`).length).toBeGreaterThan(0);
  });

  test.each(LOOKUP_NAMES)("token shapes override lookup names: %s", name => {
    expect(exposures(`"${name}": "sk-proj-syntheticCredential8274"`).some(f => f.kind === "token")).toBe(true);
  });

  test.each(["test-api-key", "dummy-key", "example_api_key", "fake-api-key-12345", "placeholder-token", "sk-test-api-key-123456789"])(
    "explicit dummy values are not findings: %s",
    value => {
      expect(exposures(`api_key="${value}"`)).toEqual([]);
      expect(exposures(`--api-key ${value}`)).toEqual([]);
    },
  );

  test.each(["test-api-key", "dummy-key", "sk-test-api-key-123456789"])("previously masked dummies stay masked: %s", value => {
    const text = `api_key="${value}"`;
    expect(c.values([text]).has(value)).toBe(true);
    expect(c.mask(text)).not.toContain(value);
    expect(c.mask(value, c.values([text]))).toBe("***");
  });

  test.each(["aB7defg8", "testament8274", "test_live_real8274", "exampleCredential8274", "test-api-key-realOpaque8274", "dummy-actualOpaque8274", "unfamiliarSecret8274"])(
    "unknown and test-prefixed secrets are detected and masked: %s",
    value => {
      const text = `api_key="${value}"`;
      expect(exposures(text).length).toBeGreaterThan(0);
      expect(found(text).length).toBeGreaterThan(0);
      expect(c.mask(value, c.values([text]))).toBe("***");
      expect(c.mask(text)).toBe('api_key="***"');
    },
  );

  test("fixture context does not excuse arbitrary credentials", () => {
    const text = `# tests/test_client.py fixture\napi_key="${OPAQUE}"`;
    expect(exposures(text).length).toBeGreaterThan(0);
    expect(exposed(text)).toBe("match");
  });

  const ELLIPSIS = String.fromCharCode(0x2026);
  test.each(["PRIVATE KEY", "RSA PRIVATE KEY", "EC PRIVATE KEY"].flatMap(kind => ["...", ELLIPSIS, "<redacted>"].map(body => [kind, body] as const)))(
    "a closed placeholder PEM is not a finding but is always masked: %s %s",
    (kind, body) => {
      const block = `-----BEGIN ${kind}-----\n${body}\n-----END ${kind}-----`;
      expect(exposures(block)).toEqual([]);
      expect(found(block).length).toBeGreaterThan(0);
      expect(c.values([block]).has(block)).toBe(true);
      expect(c.mask(block)).toBe("[private key]");
    },
  );

  test.each([
    "-----BEGIN PRIVATE KEY-----\n...",
    "-----BEGIN PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----",
    "-----BEGIN PRIVATE KEY-----\nU3ludGhldGlj\n...\n-----END PRIVATE KEY-----",
    "-----BEGIN PRIVATE KEY-----\nU3ludGhldGlj\n-----END PRIVATE KEY-----",
  ])("an unclosed, mismatched or non-placeholder PEM remains a candidate: %s", block => {
    expect(exposures(block).length).toBeGreaterThan(0);
    expect(c.mask(block)).toBe("[private key]");
  });

  test.each([
    "TIKTOKEN_CACHE_DIR=/root/cache MAX_TOKENS=5000",
    'SSH_KEY_PATH="/root/.ssh/id" MY_TOKEN=${TOKEN}',
    'api_key="your-key"',
    "token = tok.encode(x)",
    "token_chars = 'ABCDEFGHIJ'",
    "KeyError: 'adapt_engaged_setting'",
    "openssl pkcs12 -password=KEY_PASSWORD -in cert.pem",
  ])("existing code and reference exclusions: %s", text => {
    expect(exposures(text)).toEqual([]);
  });

  test("the exposure detector's identity", () => {
    const spec = new CredentialExposure().spec;
    expect([spec.id, spec.severity, spec.title]).toEqual(["observation.credentials_exposed", "low", "Possible credential-like value"]);
  });

  const SSH_ALGORITHMS = ["sk-ssh-ed25519@openssh.com", "sk-ssh-ed25519-cert-v01@openssh.com", "sk-ecdsa-sha2-nistp256@openssh.com", "sk-ecdsa-sha2-nistp256-cert-v01@openssh.com"];
  test.each(SSH_ALGORITHMS.flatMap(value => [[value], [`api_key="${value}"`], [`--api-key ${value}`]]))("public SSH algorithms are not credentials: %s", text => {
    expect(exposures(text)).toEqual([]);
    expect(exposed(text)).toBe("no_match");
    // Existing broad masking stays independent, including partial token-shape matches.
    for (const hit of found(text)) expect(c.values([text]).has(text.slice(hit.value[0], hit.value[1]))).toBe(true);
  });

  test.each([
    "sk-ssh-ed25519-cert-v01",
    "sk-ssh-ed25519-cert-v01@untrusted.example",
    "sk-ssh-ed25519-cert-v01@openssh.com.attacker",
    "sk-ecdsa-sha2-nistp256@openssh.com-extra",
    "sk-proj-syntheticCredential8274",
  ])("near SSH names and opaque tokens remain candidates: %s", value => {
    expect(exposures(value).length).toBeGreaterThan(0);
    expect(c.mask(value)).not.toBe(value);
  });

  test("a public algorithm does not hide an adjacent credential", () => {
    const token = "sk-proj-syntheticCredential8274";
    const text = `sk-ssh-ed25519-cert-v01@openssh.com, ${token}`;
    const hits = exposures(text);
    expect(hits.length).toBe(1);
    expect(text.slice(hits[0]!.value[0], hits[0]!.value[1])).toBe(token);
  });

  const SHORT = ["p", "abc", "aB7", "aB7defg", "42", "12345678", "123456789012"];
  const SHORT_TEMPLATES = [(v: string) => `api_key="${v}"`, (v: string) => `"password": "${v}"`, (v: string) => `passwd=${v}`, (v: string) => `--api-key ${v}`];
  test.each(SHORT.flatMap(value => SHORT_TEMPLATES.map(template => [template(value), value] as const)))("short and numeric values keep legacy boundaries: %s", (text, value) => {
    expect(exposures(text)).toEqual([]);
    expect(found(text)).toEqual([]);
    expect(c.values([text]).size).toBe(0);
    expect(c.mask(text)).toBe(text);
    const prompt = `Keep prompts intact: paragraph abc aB7defg 123456789012. Repeat ${value}.`;
    expect(c.mask(prompt, c.values([text]))).toBe(prompt);
  });

  test.each(['rate_key = "embedding_lr"', "token = 'identifier_tail'", "GPG_KEY=0123456789ABCDEF0123456789ABCDEF01234567", 'primary_key = "account_ref"'])(
    "identifier and public key exclusions: %s",
    text => {
      expect(exposures(text)).toEqual([]);
      expect(exposed(text)).toBe("no_match");
    },
  );

  test.each([
    "if token==prev_tok:\n    merged += 1", // TB4 telecom-entity-resolution tokenizer
    "keep = [t for t in toks if token==t]",
    "assert api_key==expected_key",
  ])("comparisons are not secret assignments: %s", code => {
    // Regression: `token==prev_tok` read "=prev_tok" as a secret-named value.
    expect(exposures(code)).toEqual([]);
  });

  test("secret assignments still count next to comparisons", () => {
    expect(exposures(`if a==b:\n    API_TOKEN=${OPAQUE}`).length).toBeGreaterThan(0);
  });

  // Byte-level BPE marks (U+0120 leading space, U+010A newline) and SentencePiece's word start (U+2581).
  const G = String.fromCharCode(0x120);
  const NL = String.fromCharCode(0x10a);
  const SP = String.fromCharCode(0x2581);
  test.each([
    // Regression (TB2.1 gpt2-codegolf, DeepSeek reasoning about GPT-2's vocabulary).
    `Token 34764 → merge token: "${G}WARRANT" ✓ (leading space)`,
    `token = '${G}Hello${G}world'`,
    `token: "${SP}sentencepiece"`,
    `tokens = {"token": "line${NL}next${G}word"}`,
  ])("tokenizer pieces are not credentials: %s", text => {
    expect(exposures(text)).toEqual([]);
  });

  test("a tokenizer marker does not hide a key shape", () => {
    expect(exposures(`token: "${G}WARRANT" api_key="${OPAQUE}"`).length).toBeGreaterThan(0);
  });
});

describe("webhook capabilities (test_webhook_credentials.py)", () => {
  const SLACK_TOKEN = "SyntheticUnissuedTokenABC123";
  const DISCORD_TOKEN = `SyntheticUnissuedTokenNotIssuedForTesting_${"9".repeat(32)}`;
  const SLACK_PREFIX = "https://hooks.slack.com/services/T00000000/B00000000/";
  const DISCORD_PREFIX = `https://discord.com/api/webhooks/${"0".repeat(18)}/`;
  const SLACK = SLACK_PREFIX + SLACK_TOKEN;
  const DISCORD = DISCORD_PREFIX + DISCORD_TOKEN;
  const CAPABILITIES: [string, string, string][] = [[SLACK, SLACK_TOKEN, "slack"], [DISCORD, DISCORD_TOKEN, "discord"]];
  const BACKSLASH = String.fromCharCode(92);

  test.each(CAPABILITIES)("the shared API recognizes %s", (url, token, service) => {
    const capability = webhooks.webhookCapability(url)!;
    expect(capability.service).toBe(service as "slack" | "discord");
    expect(capability.token).toBe(token);
  });

  const WRAPS = [(url: string) => url, (url: string) => `WEBHOOK_URL="${url}"`, (url: string) => `"WEBHOOK_URL": "${url}"`];
  test.each(CAPABILITIES.flatMap(([url, token]) => WRAPS.map(wrap => [wrap(url), url, token] as const)))("capabilities and components are masked and exposed: %s", (text, url, token) => {
    expect(exposures(text).some(f => f.kind === "webhook")).toBe(true);
    expect(c.values([text]).has(token)).toBe(true);
    expect(exposed(text)).toBe("match");
    const masked = c.mask(text);
    expect(masked).not.toContain(token);
    expect(masked).not.toContain(url);
    expect(masked).toContain("***");
    expect(c.mask(token, c.values([text]))).toBe("***");
  });

  const SURROUNDS = [(url: string) => `<${url}>`, (url: string) => `(${url}).`, (url: string) => `\`${url}\``, (url: string) => `${url}?wait=true#note`];
  test.each(CAPABILITIES.flatMap(([url, token]) => SURROUNDS.map(surround => [surround(url), token] as const)))("wrapping punctuation and queries are masked: %s", (text, token) => {
    expect(c.mask(text)).not.toContain(token);
  });

  test.each([
    SLACK.replace("hooks.slack.com", "hooks.slack.com.evil.invalid"),
    SLACK.replace("hooks.slack.com", "hooks.slack.com@evil.invalid"),
    SLACK.replace("hooks.slack.com", "evil@hooks.slack.com"),
    SLACK.replace("hooks.slack.com", "localhost"),
    SLACK.replace("hooks.slack.com", "127.0.0.1"),
    SLACK.replace("hooks.slack.com", "hooks.slack.com."),
    SLACK.replace("hooks.slack.com", "hooks%2eslack.com"),
    SLACK.replace("hooks.slack.com", "hooks.slack.com:8443"),
    SLACK.replace("https:", "http:"),
    SLACK.replace("/services/", "/other/services/"),
    `${SLACK}/extra`,
    DISCORD.replace("discord.com", "discord.com.evil.invalid"),
    DISCORD.replace("discord.com", "discord.com@localhost"),
    DISCORD.replace("discord.com", "user@discord.com"),
    DISCORD.replace("/api/", "/not-api/"),
    DISCORD.replace("/webhooks/", "/webhooks%2f"),
    `https://example.invalid/redirect?next=${SLACK}`,
    `<${SLACK}>`,
    `WEBHOOK_URL="${SLACK}"`,
    `${SLACK}\n`,
    `${SLACK}?x=${BACKSLASH}`,
    SLACK + String.fromCharCode(127),
    `${SLACK}?x=${String.fromCharCode(0)}`,
    SLACK.replace("hooks.", `hooks.${BACKSLASH}t`),
    SLACK.replace("hooks.", `hooks.${BACKSLASH}${BACKSLASH}`),
  ])("the exact request target rejects host and path tricks: %s", url => {
    expect(webhooks.webhookCapability(url)).toBeNull();
  });

  test.each([
    SLACK.replace("hooks.slack.com", "HOOKS.SLACK.COM:443"),
    SLACK.replace("hooks.slack.com", "hooks.slack-gov.com"),
    DISCORD.replace("discord.com", "discordapp.com"),
    DISCORD.replace("discord.com", "canary.discord.com"),
    DISCORD.replace("discord.com", "ptb.discordapp.com"),
    DISCORD.replace("/api/", "/api/v10/"),
    `${DISCORD}/slack`,
    `${DISCORD}/github?wait=true`,
  ])("explicit endpoint variants: %s", url => {
    expect(webhooks.webhookCapability(url)).not.toBeNull();
  });

  test.each(["hooks.slack.com.evil.invalid", "localhost", "user@hooks.slack.com"])("non-vendor URLs are not webhook exposures: %s", host => {
    const text = SLACK.replace("hooks.slack.com", host);
    expect(exposures(text)).toEqual([]);
    expect(c.mask(text)).toBe(text);
  });

  test.each(CAPABILITIES)("a documentation role does not exempt genuine-shaped values: %s", url => {
    expect(exposures(`# Documentation example in tests/fixture.py: ${url}`).length).toBeGreaterThan(0);
  });

  test.each(CAPABILITIES.flatMap(([url, token]) => ["0", "X"].map(placeholder => [url, token, placeholder] as const)))(
    "repeated dummy tokens are masked but not exposure: %s",
    (url, token, placeholder) => {
      const dummy = placeholder.repeat(token.length);
      const text = url.replace(token, dummy);
      expect(webhooks.webhookCapability(text)).not.toBeNull();
      expect(exposures(text)).toEqual([]);
      expect(c.mask(text)).not.toContain(dummy);
    },
  );

  test.each([
    "https://hooks.slack.com/services/TEAM/CHANNEL/TOKEN",
    "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN",
    "https://hooks.slack.com/services/<team>/<channel>/<token>",
  ])("public placeholders do not create findings: %s", text => {
    expect(webhooks.webhookCapability(text)).toBeNull();
    expect(exposures(text)).toEqual([]);
  });

  test.each(CAPABILITIES)("encoded tokens mask raw and decoded repeats: %s", (url, token) => {
    const encoded = [...token].map(ch => `%${ch.charCodeAt(0).toString(16).toUpperCase().padStart(2, "0")}`).join("");
    const text = url.replace(token, encoded);
    expect(webhooks.webhookCapability(text)!.token).toBe(token);
    const known = c.values([text, token]);
    expect(known.has(token) && known.has(encoded)).toBe(true);
    const masked = c.mask(`${text}\n${token}`);
    expect(masked).not.toContain(encoded);
    expect(masked).not.toContain(token);
  });

  test("a JSON-escaped URL is recognized as a whole literal", () => {
    const text = SLACK_TOKEN + JSON.stringify({ hook: SLACK }).replaceAll("/", `${BACKSLASH}/`);
    expect(exposures(text).some(f => f.kind === "webhook")).toBe(true);
    expect(c.mask(text)).not.toContain(SLACK_TOKEN);
  });

  test.each([
    `host = "${SLACK_PREFIX}"\ntail = get_token()\nu = host + tail`,
    `host = "${SLACK_PREFIX}"\npart = "${SLACK_TOKEN}"\npart = unknown\nu = host + part`,
    `host = "${SLACK_PREFIX}"\npart = "${SLACK_TOKEN}"\npart = mutate(part)\nu = host + part`,
    `host = "${SLACK_PREFIX}"\npart = "${SLACK_TOKEN}"\nimport part\nu = host + part`,
    `host = "${SLACK_PREFIX}"\ndef f(host):\n    return host + "${SLACK_TOKEN}"`,
  ])("a dynamic or ambiguous assembly is not claimed: %s", source => {
    expect([...webhooks.find(source, true)]).toEqual([]);
  });

  test("a recognized whole capability is masked despite unresolved context", () => {
    expect(c.mask(`url = "${SLACK}" + dynamic_suffix()`)).not.toContain(SLACK_TOKEN);
  });

  // Deviation from atif-scan: a URL assembled from Python string constants is not recovered (no Python parser).
  test.each([
    `url = "${SLACK_PREFIX}" + "${SLACK_TOKEN}"`,
    `host = "${SLACK_PREFIX}"\ntail = "${SLACK_TOKEN}"\nurl = host + tail`,
  ])("a URL assembled from constants is not recovered (deviation): %s", source => {
    expect(exposures(source).some(f => f.kind === "webhook")).toBe(false);
  });
});
