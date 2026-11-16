// Ported from atif-scan 0.8.23 (commit 3bbaf3c): tests/test_shell.py and
// tests/test_shell_lifetime.py. Synthetic strings only: they are parsed, never executed.
import { describe, expect, test } from "bun:test";
import * as shell from "../../../src/server/tool-guard/scan/shell";

function writes(text: string): string[] {
  const script = shell.parse(text);
  expect(script.complete).toBe(true);
  return script.commands.flatMap((command) => shell.writes(command).map(([path]) => path));
}

function names(text: string): string[] {
  return shell
    .parse(text)
    .commands.map((c) => c.name ?? "")
    .sort();
}

function nameSet(script: shell.Script): Set<string | null> {
  return new Set(script.commands.map((c) => c.name));
}

function expectSuperset(actual: Set<string | null>, wanted: readonly string[]): void {
  for (const name of wanted) expect(actual.has(name)).toBe(true);
}

function assertScope(
  text: string,
  background: readonly (string | null)[],
  repeated: readonly string[] = [],
): shell.Script {
  const script = shell.parse(text);
  expect(script.complete).toBe(true);
  for (const command of script.commands) {
    const label = JSON.stringify(command.words);
    expect([label, "background", command.background]).toEqual([
      label,
      "background",
      background.includes(command.name),
    ]);
    expect([label, "repeated", command.repeated]).toEqual([
      label,
      "repeated",
      command.name !== null && repeated.includes(command.name),
    ]);
  }
  return script;
}

/** The pytest `linear` fixture: `fn(size)` must scale linearly, not quadratically. Times n
 * and 4n (best of 3); anything done in under 50 ms at 4n passes. */
function best(fn: (size: number) => void, size: number): number {
  let fastest = Number.POSITIVE_INFINITY;
  for (let run = 0; run < 3; run += 1) {
    const start = performance.now();
    fn(size);
    fastest = Math.min(fastest, (performance.now() - start) / 1000);
  }
  return fastest;
}

function linear(fn: (size: number) => void, n: number, ratio = 8.0): void {
  const small = best(fn, n);
  const large = best(fn, 4 * n);
  expect([large < 0.05 || large < ratio * small, small, large]).toEqual([true, small, large]);
}

describe("test_shell.py", () => {
  const writeTargets: [string, string[]][] = [
    ["echo 1 > /tests/a; cat x >> /tests/b 2>&1", ["/tests/a", "/tests/b"]],
    ["ls &> /tmp/o; ls 2>/dev/null", ["/tmp/o", "/dev/null"]],
    ["sudo -u root tee -a /tests/a /tests/b < in", ["/tests/a", "/tests/b"]],
    ["cp /app/a.c /app/b.c /tests/", ["/tests/"]], // the old pattern wanted one source
    ["cp -t /tests/ a b; install -m 755 run /usr/bin/run", ["/tests/", "/usr/bin/run"]],
    ["ln -sf /app/x /tests/x; dd if=/dev/zero of=/tests/y bs=1", ["/tests/x", "/tests/y"]],
    ["touch a b; sed -i 's/x/y/' f.py", ["a", "b", "f.py"]],
    ["sed -i -e 's#/tests/#/app/#' conf.py", ["conf.py"]], // a script isn't a target
    ["echo 'a > /tests/b'; grep -E 'x|y' f", []], // quoted operators
    ["bash -lc 'echo 1 > /tests/x'", ["/tests/x"]],
    ['sh -c "echo \\"a\\" > /tests/q"', ["/tests/q"]],
    ["bash <<EOF\necho hi > /tests/z\nEOF", ["/tests/z"]],
    ["x=$(( 1 + 2 )) && echo `date` > /tmp/d", ["/tmp/d"]],
  ];
  test.each(writeTargets)("write targets: %p", (text, expected) => {
    expect(writes(text)).toEqual(expected);
  });

  test("heredoc bodies are contents, not commands", () => {
    const text = "cat > /app/x.py <<'EOF'\nif a > b: pass\nEOF\npython3 /app/x.py > /tmp/out";
    const script = shell.parse(text);
    expect(writes(text)).toEqual(["/app/x.py", "/tmp/out"]);
    expect(script.bodies).toHaveLength(1);
    const body = script.bodies[0] as shell.Span;
    expect(text.slice(body[0], body[1])).toBe("if a > b: pass\n");
    expect(names(text)).toEqual(["cat", "python3"]);
  });

  const fileBodies: [string, boolean][] = [
    ["cat > /app/p.ts <<'EOF'\nfetch(u)\nEOF", true],
    ["cat <<EOF > /app/p.ts\nfetch(u)\nEOF", true],
    ["tee -a /app/p.ts <<'EOF'\nfetch(u)\nEOF", true],
    ["python3 - <<'PY'\nfetch(u)\nPY", false], // fed to a program
    ["cat <<'EOF'\nfetch(u)\nEOF", false], // printed, not written
    ["node <<'EOF' > /tmp/out\nfetch(u)\nEOF", false], // run; its output is written
  ];
  test.each(fileBodies)("file bodies are heredocs written to a file: %p", (text, written) => {
    const script = shell.parse(text);
    expect(script.bodies).toHaveLength(1);
    const body = script.bodies[0] as shell.Span;
    expect(text.slice(body[0], body[1])).toBe("fetch(u)\n");
    expect(script.fileBodies).toEqual(written ? [body] : []);
  });

  test("heredocs nested in a shell heredoc keep their owners", () => {
    // Regression: a trial ran `python3 - <<PY` and `cat > f <<EOF` inside `bash <<SH`; the
    // nested bodies were merged without their owner commands or write targets.
    const text =
      "bash <<'SH'\n" +
      "python3 - <<'PY'\nimport urllib.request\nurllib.request.urlopen('https://example.com/q')\nPY\n" +
      "cat > /app/notes.md <<'EOF'\nsee https://example.com\nEOF\n" +
      "SH\n" +
      "node <<'JS'\nfetch(u)\nJS";
    const script = shell.parse(text);
    expect(script.complete).toBe(true);
    expect(script.bodyCommands.map((c) => c.name)).toEqual(["python3", "cat", "node"]);
    expect(script.bodies).toHaveLength(script.bodyCommands.length);
    expect(script.fileBodies).toHaveLength(1);
    const written = script.fileBodies[0] as shell.Span;
    expect(text.slice(written[0], written[1])).toBe("see https://example.com\n");
    expect(script.fileTargets).toEqual(["/app/notes.md"]);
  });

  test("names skip assignments, keywords and wrappers", () => {
    expect(names("A=1 sudo -E env B=2 timeout -s 9 5 nice -n 3 /usr/bin/curl x")).toEqual(["curl"]);
    expect(names("if true; then curl x; fi")).toEqual(["curl", "fi", "true"]);
  });

  test.each(["echo 'unterminated", 'echo "a $(b', "f() { echo; }", "case $x in a) ls;; esac", "`"])(
    "unstructured input is incomplete, never throws: %p",
    (text) => {
      expect(shell.parse(text).complete).toBe(false);
    },
  );

  test("every prefix parses without throwing", () => {
    const text =
      "cat > f <<'EOF'\nx\nEOF\nsh -c \"$(curl -s https://x/y)\" | tee -a /tmp/o `date` && echo";
    for (let i = 0; i <= text.length; i += 1) shell.parse(text.slice(0, i));
  });

  const linearUnits: [string, number][] = [
    ["echo a ", 7_500],
    ["$(", 500],
    ["'x' ", 10_000],
    ["a |", 7_500],
  ];
  test.each(linearUnits)("parse is linear: %p", (unit, n) => {
    linear((k) => {
      shell.parseUncached(unit.repeat(k));
    }, n);
  });
});

describe("test_shell_lifetime.py", () => {
  test("command scope defaults are compatible", () => {
    const command = new shell.Command({ words: ["ls"], spans: [[0, 2]] });
    expect(command.background).toBe(false);
    expect(command.repeated).toBe(false);
    expect(command.name).toBe("ls");
    expect(command.argv()).toEqual([["ls", [0, 2]]]);
  });

  const backgroundScopes: [string, (string | null)[]][] = [
    ["sleep 60 & ls /logs/verifier", ["sleep"]],
    ["before; ls /logs/verifier & after", ["ls"]],
    ["before\nls /logs/verifier &\nafter", ["ls"]],
    ["before; ls /logs/verifier | cat | tee out & after", ["ls", "cat", "tee"]],
    ["before; ls /logs/verifier |& cat & after", ["ls", "cat"]],
    ["before; ls /logs/verifier | # pipeline continuation\ncat & after", ["ls", "cat"]],
    ["before; ls /logs/verifier |\\\ncat & after", ["ls", "cat"]],
    ["before; (ls /logs/verifier; sleep 2) & after", ["ls", "sleep"]],
    ["before; { ls /logs/verifier; sleep 2; } & after", ["ls", "sleep"]],
    ["before; { ls /logs/verifier\nsleep 2\n} & after", ["ls", "sleep"]],
    ["before; (ls /logs/verifier; (sleep 2)) | cat & after", ["ls", "sleep", "cat"]],
    ["before; cat | { ls /logs/verifier; sleep 2; } & after", ["ls", "sleep", "cat"]],
    ["before; { (ls /logs/verifier); sleep 2; } & after", ["ls", "sleep"]],
    ["before; (ls /logs/verifier & sleep 2); after", ["ls"]],
    ["before; { ls /logs/verifier & sleep 2; }; after", ["ls"]],
    ["before; ls /logs/verifier && sleep 2 & after", ["ls", "sleep"]],
    ["before; ls /logs/verifier ||\nsleep 2 & after", ["ls", "sleep"]],
    ["before; ls /logs/verifier & sleep 2 & after", ["ls", "sleep"]],
    ["ls /logs/verifier &> out; after", []],
    ["ls /logs/verifier &>> out 2>&1; after", []],
    ["ls /logs/verifier > out 2>&1 & after", ["ls"]],
    ["before; (ls /logs/verifier) > out & after", ["ls", null]],
  ];
  test.each(backgroundScopes)("background scope: %p", (text, background) => {
    assertScope(text, background);
  });

  for (const separator of ["; ", "\n"]) {
    for (const header of [
      "while true",
      "while :",
      "while [ 1 ]",
      "until false",
      "for ((;;))",
      "for (( ; ; ))",
    ]) {
      test(`unbounded loop body stops at done: ${JSON.stringify([header, separator])}`, () => {
        const text = `before; ${header}${separator}do ls /logs/verifier; sleep 2; done; after`;
        const script = assertScope(text, [], ["ls", "sleep"]);
        expectSuperset(nameSet(script), ["before", "ls", "sleep", "after"]);
        expect(script.commands.some((c) => ["do", "done", "for"].includes(c.name ?? ""))).toBe(false);
      });
    }
  }

  test.each([
    "while false",
    "until true",
    "while [ 0 ]",
    "while [ 1 = 2 ]",
    "while trueish",
    "while /bin/true",
    "while 'true'",
    'while tr"ue"',
    "while true argument",
    "while true > out",
    "while true; false",
    "while true && false",
  ])("other conditions are not recognized as unbounded: %p", (header) => {
    assertScope(`${header}; do ls /logs/verifier; done; after`, []);
  });

  test("nested loop and group scopes", () => {
    assertScope(
      "before; while true; do { ls /logs/verifier; (sleep 2); } & " +
        "until false; do cat out; done; echo tick; done; after",
      ["ls", "sleep"],
      ["ls", "sleep", "false", "cat", "echo"],
    );
  });

  test("background loop and its pipeline", () => {
    assertScope(
      "before; while true; do ls /logs/verifier; sleep 2; done | cat & after",
      ["true", "ls", "sleep", "cat"],
      ["ls", "sleep"],
    );
  });

  test("only inner loop is repeated", () => {
    assertScope(
      "while test ready; do before; while :; do ls /logs/verifier; done; after; done; last",
      [],
      ["ls"],
    );
  });

  test.each([
    "sh -c 'ls /logs/verifier; bash -c \"sleep 2\"'",
    "sh -c \"ls /logs/verifier; bash -c 'sleep 2'\"",
    "env A=1 sh -c 'ls /logs/verifier; bash -c \"sleep 2\"'",
    "sh <<'SH'\nls /logs/verifier; bash -c 'sleep 2'\nSH\n",
  ])("nested shells inherit both scopes: %p", (body) => {
    assertScope(
      `before; while true; do ${body}\ndone & after`,
      ["true", "sh", "bash", "ls", "sleep"],
      ["sh", "bash", "ls", "sleep"],
    );
  });

  test("background shell heredoc is read after parent scope is set", () => {
    assertScope(
      "before; sh <<'SH' &\nwhile :; do ls /logs/verifier; done\nSH\nafter",
      ["sh", ":", "ls"],
      ["ls"],
    );
  });

  test("nested scope does not escape to parent or sibling", () => {
    assertScope(
      "sh -c 'while true; do ls /logs/verifier; done & sleep 2'; after",
      ["true", "ls"],
      ["ls"],
    );
  });

  test.each(["$(ls /logs/verifier)", "`ls /logs/verifier`", "<(ls /logs/verifier)"])(
    "substitutions inherit execution scope: %p",
    (substitution) => {
      assertScope(`while :; do cat ${substitution}; done & after`, [":", "cat", "ls"], ["cat", "ls"]);
    },
  );

  test.each([
    "echo 'while true; do ls /logs/verifier & done'; after",
    'echo "until false; do ls /logs/verifier & done"; after',
    "echo 'for ((;;)); do ls /logs/verifier; done &'; after",
    "echo '(ls /logs/verifier; sleep 2) &'; after",
    "echo '{ ls /logs/verifier; sleep 2; } &'; after",
    "echo \\& while true; after",
    "echo while true; echo do; echo done; after",
    "echo { ls /logs/verifier; echo }; after",
    "echo awhile true; after",
    "echo hi # while true; do ls /logs/verifier &\nafter",
    "# for ((;;)); do ls /logs/verifier; done &\nafter",
    "cat <<'EOF'\nwhile true; do ls /logs/verifier; done &\nEOF\nafter",
    "cat > script <<EOF\n(ls /logs/verifier; sleep 2) &\nEOF\nafter",
    "python - <<'PY'\nfor ((;;)); do ls /logs/verifier; done &\nPY\nafter",
    "'while' true; after",
    "whi'le' true; after",
  ])("quoted syntax, comments and dormant heredocs have no scope: %p", (text) => {
    assertScope(text, []);
  });

  test("fake done in quotes, comment or heredoc does not close loop", () => {
    assertScope(
      "while true; do echo 'done &'; # done &\n" +
        "cat <<'EOF'\ndone &\nEOF\nls /logs/verifier; done; after",
      [],
      ["echo", "cat", "ls"],
    );
  });

  test.each([
    "while true; do ls /logs/verifier",
    "while true; ls /logs/verifier; done",
    "while true do ls /logs/verifier; done",
    "while; do ls /logs/verifier; done",
    "for ((; # not arithmetic syntax\n;)); do ls /logs/verifier; done",
    "while true && do ls /logs/verifier; done",
    "while true; do ls /logs/verifier; 'done'",
    "for ((;;)); do ls /logs/verifier",
    "for ((i=0; i<3; i++)); do ls /logs/verifier; done",
    "for '((;;))'; do ls /logs/verifier; done",
    "(ls /logs/verifier; sleep 2 &",
    "{ ls /logs/verifier; sleep 2 &",
    "{ ls /logs/verifier } &",
    "(ls /logs/verifier) sleep 2 &",
    "f() { ls /logs/verifier; } &",
    "case x in x) ls /logs/verifier &;; esac",
    "while true; do ls /logs/verifier | done",
    "ls /logs/verifier |",
    "ls /logs/verifier &&",
  ])("unsupported or unclosed structures remain incomplete: %p", (text) => {
    expect(shell.parse(text).complete).toBe(false);
  });

  test("unclosed loop does not claim a repeated body", () => {
    const script = shell.parse("while true; do ls /logs/verifier");
    expect(script.complete).toBe(false);
    expect(script.commands.some((c) => c.repeated)).toBe(false);
  });

  test("all prefixes are safe to parse", () => {
    const text =
      "before; { while [ 1 ]; do sh -c 'ls /logs/verifier | cat'; " +
      "for ((;;)); do sleep 2; done; done; } & after";
    for (let end = 0; end <= text.length; end += 1) shell.parse(text.slice(0, end));
  });

  test("pipeline and span consumers remain compatible", () => {
    const text = "ls /logs/verifier | cat > out & after";
    const script = shell.parse(text);
    expect(script.commands).toHaveLength(3);
    const [first, second, last] = script.commands as [shell.Command, shell.Command, shell.Command];
    expect(first.pipeline).toBe(second.pipeline);
    expect(second.pipeline).not.toBe(last.pipeline);
    const later = shell.laterInPipeline(script);
    expect([...later.keys()]).toEqual([first, second, last]);
    expect(later.get(first)).toEqual([second]);
    expect(later.get(first)?.[0]).toBe(second);
    expect(later.get(second)).toEqual([]);
    expect(later.get(last)).toEqual([]);
    expect(first.argv()).toEqual([
      ["ls", [0, 2]],
      ["/logs/verifier", [3, 17]],
    ]);
    expect(shell.writes(second)[0]?.[0]).toBe("out");
    for (const command of script.commands) {
      expect(command.spans).toHaveLength(command.words.length);
      for (const [i, word] of command.words.entries()) {
        const [start, end] = command.spans[i] as shell.Span;
        expect(text.slice(start, end)).toBe(word);
      }
    }
  });

  test("scope does not leak between identical commands", () => {
    const script = shell.parse(
      "ls /logs/verifier; while :; do ls /logs/verifier; done & ls /logs/verifier",
    );
    expect(script.complete).toBe(true);
    expect(
      script.commands.filter((c) => c.name === "ls").map((c) => [c.background, c.repeated]),
    ).toEqual([
      [false, false],
      [true, true],
      [false, false],
    ]);
  });

  test("command after done in and-or list is not repeated", () => {
    assertScope("while :; do ls /logs/verifier; done && cat out; after", [], ["ls"]);
  });

  test.each([
    "for item in a b",
    "for item",
    "for item in",
    "for item in 'while true' 'do' 'done &'",
    'for item in "$@"',
    "for item in $(printf a)",
  ])("word list loops keep existing consumers without claiming unboundedness: %p", (header) => {
    const script = assertScope(`before; ${header}; do ls /logs/verifier; done; after`, []);
    expectSuperset(nameSet(script), ["before", "for", "ls", "after"]);
  });

  test("word list loop body can be backgrounded as a group", () => {
    assertScope("before; for item in a b; do ls /logs/verifier; sleep 2; done & after", [
      "for",
      "ls",
      "sleep",
    ]);
  });

  test("nested unbounded loop in word list loop", () => {
    assertScope(
      "for item in a b; do before; while :; do ls /logs/verifier; done; after; done",
      [],
      ["ls"],
    );
  });

  test.each([
    "for 'item' in a",
    "for item 'in' a",
    "for 1 in a",
    "for item other a",
    "for item in a | cat",
  ])("unsupported word list headers stay incomplete: %p", (header) => {
    expect(shell.parse(`${header}; do ls /logs/verifier; done`).complete).toBe(false);
  });

  const prefixes: [string, string][] = [
    ["if true; then ", "; fi"],
    ["if false; then :; else ", "; fi"],
    ["if false; then :; elif true; then ", "; fi"],
    ["if ", "; then :; fi"],
    ["! ", ""],
    ["time ", ""],
    ["time ! ", ""],
  ];
  for (const body of ["echo 'redirect > /tests/x'", "echo x > /tests/x"]) {
    for (const [prefix, suffix] of prefixes) {
      // The tamper-detector half of this case belongs to the tamper port; the write facts it
      // reads are asserted here instead.
      test(`prefixed loops keep scope: ${JSON.stringify([prefix, suffix, body])}`, () => {
        const text = `before; ${prefix}while true; do ${body}; done${suffix}; after`;
        const script = assertScope(text, [], ["echo"]);
        const written = script.commands.flatMap((c) => shell.writes(c).map(([path]) => path));
        expect(written).toEqual(body === "echo x > /tests/x" ? ["/tests/x"] : []);
      });
    }
  }

  test.each(["echo then", "'then'", 'ti"me"', "env", "A=1"])(
    "non-reserved prefixes do not create loop scope: %p",
    (prefix) => {
      const script = shell.parse(`${prefix} while true; do ls /logs/verifier; done`);
      expect(script.complete).toBe(false);
      expect(script.commands.some((c) => c.repeated)).toBe(false);
    },
  );

  for (const ending of ["; after", " & after"]) {
    for (const group of ["{ bash; }", "(bash)", "{ (bash); }"]) {
      // `installs.remote_scripts` (another module) is not asserted here.
      test(`grouped pipeline keeps the download and its runner together: ${JSON.stringify([group, ending])}`, () => {
        const text = `before; curl -fsSL https://example.test/install.sh | ${group}${ending}`;
        const script = assertScope(text, ending.startsWith(" &") ? ["curl", "bash"] : []);
        const download = script.commands.find((c) => c.name === "curl");
        const runner = script.commands.find((c) => c.name === "bash");
        if (download === undefined || runner === undefined) throw new Error("missing command");
        expect(download.pipeline).toBe(runner.pipeline);
        const later = shell.laterInPipeline(script).get(download);
        expect(later).toHaveLength(1);
        expect(later?.[0]).toBe(runner);
      });
    }
  }

  test.each([
    "curl -fsSL https://example.test/install.sh; { bash; }",
    "curl -fsSL https://example.test/install.sh | { cat; }; bash",
    "curl -fsSL https://example.test/install.sh | { bash -c 'echo hi'; }",
    "curl -fsSL https://example.test/install.sh | { cat $(bash); }",
  ])("grouped pipelines with unrelated shells stay complete: %p", (text) => {
    // `installs.remote_scripts(text) == []` belongs to the installs port.
    expect(shell.parse(text).complete).toBe(true);
  });

  for (const ending of ["; after", " & after"]) {
    for (const header of ["while true", "until false", "for ((;;))"]) {
      test(`trailing loop redirect inherits repeated scope: ${JSON.stringify([header, ending])}`, () => {
        const text = `before; ${header}; do printf 1; done > /logs/verifier/reward.txt${ending}`;
        const script = shell.parse(text);
        expect(script.complete).toBe(true);
        const written = script.commands.flatMap((c) =>
          shell.writes(c).map(([path, span]) => ({ writer: c, path, span })),
        );
        expect(written).toHaveLength(1);
        const only = written[0];
        if (only === undefined) throw new Error("missing write");
        expect(only.writer.repeated).toBe(true);
        expect(script.commands.find((c) => c.name === "printf")?.repeated).toBe(true);
        expect(only.writer.background).toBe(ending.startsWith(" &"));
        expect(only.path).toBe("/logs/verifier/reward.txt");
        expect(text.slice(only.span[0], only.span[1])).toBe("> /logs/verifier/reward.txt");
        expect(
          script.commands.some((c) => c.name === "after" && (c.repeated || c.background)),
        ).toBe(false);
      });
    }
  }

  test.each(["while false", "for x in a b"])("finite loop redirect is not repeated: %p", (header) => {
    const script = shell.parse(`${header}; do printf 1; done > /logs/verifier/reward.txt`);
    expect(script.complete).toBe(true);
    expect(script.commands.some((c) => c.repeated)).toBe(false);
  });

  for (const words of ["in a b", "in", 'in "$@"', "in $(printf a)"]) {
    for (const layout of ["\n", " \n ", "\n\n", "\n# synthetic comment\n"]) {
      test(`word list loop accepts newlines before in: ${JSON.stringify([layout, words])}`, () => {
        const script = assertScope(
          `before; for x${layout}${words}; do ls /logs/verifier; done & after`,
          ["for", "printf", "ls"],
        );
        const header = script.commands.find((c) => c.name === "for");
        expect(header?.words.slice(0, 3)).toEqual(["for", "x", "in"]);
      });
    }
  }

  test("word list loop newline without in remains supported", () => {
    assertScope("before; for x\n# synthetic comment\ndo ls /logs/verifier; done & after", [
      "for",
      "ls",
    ]);
  });

  test.each(["for x; in a b", "for x\n'in' a b", "for x\nother a b"])(
    "invalid multiline word list headers stay incomplete: %p",
    (header) => {
      expect(shell.parse(`${header}; do ls /logs/verifier; done &`).complete).toBe(false);
    },
  );
});

// Not in the Python suite, which only reaches these through other detectors: the facts
// below follow from reading shell.py by hand.
describe("search patterns and file bodies (added for the port)", () => {
  function patterns(text: string): (string[] | null)[] {
    return shell
      .parse(text)
      .commands.map((c) => shell.searchPatterns(c)?.map(([start, end]) => text.slice(start, end)) ?? null);
  }

  const cases: [string, (string[] | null)[]][] = [
    ["grep -rn 'needle' src", [["'needle'"]]],
    ["grep -e one -e two file", [["one", "two"]]],
    ["grep -ie one file", [["one"]]],
    ["grep -A3 needle file", [["needle"]]],
    ["grep -A 3 needle file", [["needle"]]],
    ["grep -f patterns.txt file", [[]]],
    ["grep --regexp=one --include '*.ts' dir", [["--regexp=one"]]],
    ["grep --unknown needle file", [null]],
    ["grep -e", [null]],
    ["rg -E utf8 needle", [["needle"]]],
    ["grep -E needle", [["needle"]]],
    ["rg --files src", [[]]],
    ["grep -- -needle file", [["-needle"]]],
    ["sudo /usr/bin/grep needle f | cat", [["needle"], null]],
  ];
  test.each(cases)("searchPatterns: %p", (text, expected) => {
    expect(patterns(text)).toEqual(expected);
  });

  test("literalSearchPatterns leaves out substituted commands and incomplete scripts", () => {
    const text = 'grep "a$(curl x)b" file';
    expect(shell.literalSearchPatterns(text).map(([start, end]) => text.slice(start, end))).toEqual([
      '"a$(',
      ')b"',
    ]);
    expect(shell.literalSearchPatterns("grep 'needle")).toEqual([]);
    expect(shell.literalSearchPatterns("grep needle file")).toEqual([[5, 11]]);
  });

  test("unusedFileBodies keeps bodies whose file nothing else names", () => {
    const unused = "cat > /app/notes.md <<'EOF'\nhello\nEOF\nls /app";
    expect(shell.unusedFileBodies(shell.parse(unused))).toEqual(shell.parse(unused).fileBodies);
    expect(shell.parse(unused).fileBodies).toHaveLength(1);
    const used = "cat > /app/run.sh <<'EOF'\nhello\nEOF\nbash /app/run.sh";
    expect(shell.parse(used).fileBodies).toHaveLength(1);
    expect(shell.unusedFileBodies(shell.parse(used))).toEqual([]);
    const byName = "cat > /app/run.sh <<'EOF'\nhello\nEOF\ncd /app && bash ./run.sh";
    expect(shell.unusedFileBodies(shell.parse(byName))).toEqual([]);
  });

  test("operands and runsScript", () => {
    const [command] = shell.parse("cp -t /dst -- -a b").commands;
    if (command === undefined) throw new Error("missing command");
    expect(shell.operands(command.argv(), shell.COPY_VALUES).map(([word]) => word)).toEqual(["-a", "b"]);
    expect(shell.runsScript(new shell.Command({ words: ["bash", "-lc"], spans: [[0, 4], [5, 8]] }))).toBe(true);
    expect(shell.runsScript(new shell.Command({ words: ["python", "-c"], spans: [[0, 6], [7, 9]] }))).toBe(false);
  });

  test("the parse cache returns the same script and stays bounded", () => {
    const script = shell.parse("echo cached");
    expect(shell.parse("echo cached")).toBe(script);
    for (let i = 0; i < 600; i += 1) shell.parse(`echo evict ${i}`);
    expect(shell.parse("echo cached")).not.toBe(script);
  });

  test("spans are UTF-16 offsets into the input", () => {
    const text = "echo '😀' > /tmp/o";
    const [command] = shell.parse(text).commands;
    if (command === undefined) throw new Error("missing command");
    expect(command.words).toEqual(["echo", "😀"]);
    expect(command.spans.map(([start, end]) => text.slice(start, end))).toEqual(["echo", "'😀'"]);
    expect(shell.writes(command).map(([path, [start, end]]) => [path, text.slice(start, end)])).toEqual([
      ["/tmp/o", "> /tmp/o"],
    ]);
  });
});
