// Ported from atif-scan 0.8.23 (https://github.com/huggingface/atif-scan, commit 3bbaf3c), src/atif_scan/data/shell.py.
// Copyright (c) 2026 Hugging Face. MIT License; the full text is in apps/mlx-bun/THIRD_PARTY_NOTICES.md.

/**
 * Static reader for shell command text (nothing is ever executed).
 *
 * `parse(text)` splits a shell tool's command into simple commands: their words (quotes
 * removed), redirections, pipeline membership, background/repeated scopes, and nested commands
 * (`$(…)`, `<(…)`, backticks, subshells, `sh -c '…'`, a heredoc fed to a shell). Heredoc
 * bodies given to any other program are file contents, returned as `bodies` spans: they are
 * not commands (a Python heredoc's `if a > b:` isn't a redirect).
 *
 * It reads the common POSIX/bash forms agents write, not the whole grammar. Input it can't
 * structure (an unterminated quote or substitution, nesting too deep) sets
 * `complete=false`; callers then fall back to text patterns rather than trusting a partial
 * structure.
 *
 * Spans are offsets into the input string in UTF-16 code units (JavaScript string indices),
 * where the Python original counts code points: slice the same JavaScript string with them.
 */

export type Span = readonly [number, number];
/** A word and where it is: Python's `tuple[str, Span]`. */
export type Word = readonly [string, Span];
/** `(op, target, span)`. */
export type Redirect = readonly [string, string, Span];

export const SHELLS: ReadonlySet<string> = new Set(["sh", "bash", "zsh", "dash", "ksh", "ash"]);
// Words before the command name that don't name it.
export const KEYWORDS: ReadonlySet<string> = new Set([
  "!", "{", "}", "then", "do", "else", "elif", "if", "while", "until", "time", "exec",
]);
// Wrappers that run the next word; value-taking options are skipped with their value.
export const WRAPPERS: ReadonlyMap<string, ReadonlySet<string>> = new Map<string, ReadonlySet<string>>([
  ["sudo", new Set(["-u", "-g", "-C", "-D", "-h", "-p", "-r", "-t", "-U"])],
  ["env", new Set(["-u", "-C", "-S"])],
  ["nohup", new Set<string>()],
  ["command", new Set<string>()],
  ["builtin", new Set<string>()],
  ["nice", new Set(["-n"])],
  ["stdbuf", new Set(["-i", "-o", "-e"])],
  ["timeout", new Set(["-s", "-k", "--signal", "--kill-after"])],
]);
export const WRITE_OPS: ReadonlySet<string> = new Set([">", ">>", ">|", "&>", "&>>", "<>", ">&"]);
// The exported patterns carry no `g`/`y` flag, so they hold no state between calls. Python's
// `\w` and `\d` are Unicode-aware for `str` patterns, hence the property escapes.
export const ASSIGNMENT = /[A-Za-z_][\p{L}\p{N}_]*=/u;
export const REDIRECT = /\p{Nd}*(?:&>>|&>|>>|>\||>&|<<-|<<<|<<|<&|<>|>|<)/u;
export const OPERATOR = /&&|\|\||;;|\|&|[|;&]/;
export const WORD_END: ReadonlySet<string> = new Set(" \t\n;&|<>()");
// Runs read as they are (fast paths): blanks, and word/double-quoted text without quotes,
// escapes, expansions or (for a word) its end.
export const BLANKS = /[ \t]+/;
export const PLAIN = /[^ \t\n;&|<>()\\'"$`]+/;
export const QUOTED_PLAIN = /[^"\\$`]+/;
export const SHELL_C = /-[a-z]*c[a-z]*/; // -c, -lc, -ec, …
export const MAX_DEPTH = 32;

/** What Python raises as IndexError/ValueError inside the reader: `parse` turns it into an
 * incomplete script. */
class ReadError extends Error {}

/** Python's `pattern.match(text, pos)`: a private sticky copy, `lastIndex` set on every call. */
function matcher(pattern: RegExp): (text: string, pos: number) => RegExpExecArray | null {
  const sticky = new RegExp(pattern.source, `${pattern.flags}y`);
  return (text, pos) => {
    sticky.lastIndex = pos;
    return sticky.exec(text);
  };
}

/** Python's `pattern.fullmatch(text)`. */
function fullMatcher(pattern: RegExp): (text: string) => boolean {
  const anchored = new RegExp(`^(?:${pattern.source})$`, pattern.flags);
  return (text) => anchored.test(text);
}

const assignmentAt = matcher(ASSIGNMENT);
const redirectAt = matcher(REDIRECT);
const operatorAt = matcher(OPERATOR);
const blanksAt = matcher(BLANKS);
const plainAt = matcher(PLAIN);
const quotedPlainAt = matcher(QUOTED_PLAIN);
const isShellC = fullMatcher(SHELL_C);
const isLoopVariable = fullMatcher(/[A-Za-z_][A-Za-z_0-9]*/);
// `str.isdigit()`; Python also accepts the few non-decimal digits (superscripts, circled
// digits) that JavaScript has no property escape for.
const isDigits = fullMatcher(/\p{Nd}+/u);

const isAssignment = (word: string): boolean => assignmentAt(word, 0) !== null;

/** `word.rsplit("/", 1)[-1]`. */
const basename = (word: string): string => word.slice(word.lastIndexOf("/") + 1);

/** `zip(a, b, strict=True)`. */
function zipStrict<A, B>(a: readonly A[], b: readonly B[]): [A, B][] {
  if (a.length !== b.length) throw new ReadError("zip() arguments have different lengths");
  return a.map((item, i): [A, B] => [item, b[i] as B]);
}

/** `itertools.count(1)`. */
class Counter {
  private value = 1;

  next(): number {
    return this.value++;
  }
}

export interface CommandInit {
  words?: string[];
  spans?: Span[];
  redirects?: Redirect[];
  nested?: Command[];
  substituted?: Command[];
  pipeline?: number;
  span?: Span;
  background?: boolean;
  repeated?: boolean;
}

export class Command {
  words: string[];
  spans: Span[];
  redirects: Redirect[]; // (op, target, span)
  // Commands this one runs: an `sh -c` string, a heredoc fed to a shell (`nested`), and
  // command/process substitutions in its words (`substituted`: `$(…)`, `<(…)`, backticks).
  nested: Command[];
  substituted: Command[];
  pipeline: number;
  span: Span;
  // Syntactic scopes, not proof of runtime duration/iterations. False means no
  // recognized scope, not proof that execution is foreground or bounded.
  background: boolean;
  repeated: boolean;

  constructor(init: CommandInit = {}) {
    this.words = init.words ?? [];
    this.spans = init.spans ?? [];
    this.redirects = init.redirects ?? [];
    this.nested = init.nested ?? [];
    this.substituted = init.substituted ?? [];
    this.pipeline = init.pipeline ?? 0;
    this.span = init.span ?? [0, 0];
    this.background = init.background ?? false;
    this.repeated = init.repeated ?? false;
  }

  /** (word, span) from the command name on: assignments, keywords and wrappers
   * (`sudo -u x`, `env A=1`, `timeout 5`) skipped. */
  argv(): Word[] {
    const words: Word[] = zipStrict(this.words, this.spans);
    let i = 0;
    while (i < words.length) {
      const word = (words[i] as Word)[0];
      const base = basename(word);
      const takesValue = WRAPPERS.get(base);
      if (KEYWORDS.has(word) || isAssignment(word)) {
        i += 1;
      } else if (takesValue !== undefined) {
        i += 1;
        while (i < words.length) {
          const option = (words[i] as Word)[0];
          if (!(option.startsWith("-") || isAssignment(option))) break;
          i += takesValue.has(option) ? 2 : 1;
        }
        if (base === "timeout" && i < words.length) i += 1; // the duration
      } else {
        break;
      }
    }
    return words.slice(i);
  }

  /** The command's basename (`/usr/bin/curl` → `curl`); a substitution run as the
   * command (`$(curl …)`) keeps its text. */
  get name(): string | null {
    const first = this.argv()[0];
    if (first === undefined) return null;
    const word = first[0];
    return word.startsWith("$(") || word.startsWith("`") ? word : basename(word);
  }
}

export class Script {
  commands: Command[] = []; // every command, nested included
  bodies: Span[] = []; // heredoc contents (not commands)
  bodyCommands: Command[] = []; // owners, parallel to bodies
  // The bodies `cat`/`tee` write to a file (`cat > f <<EOF`): file content, not input
  // to a program. A body fed to an interpreter (`python - <<EOF`) isn't one.
  fileBodies: Span[] = [];
  // The file each of `fileBodies` is written to (same order).
  fileTargets: string[] = [];
  complete = true;
}

const PARSE_CACHE_SIZE = 512;
const parseCache = new Map<string, Script>();

/** Never throws: anything the reader trips over makes the script incomplete. Cached
 * (several checks read the same command, least recently used of 512 dropped): treat the
 * result as read-only. */
export function parse(text: string): Script {
  const cached = parseCache.get(text);
  if (cached !== undefined) {
    parseCache.delete(text);
    parseCache.set(text, cached);
    return cached;
  }
  const script = parseUncached(text);
  parseCache.set(text, script);
  if (parseCache.size > PARSE_CACHE_SIZE) {
    for (const oldest of parseCache.keys()) {
      parseCache.delete(oldest);
      break;
    }
  }
  return script;
}

/** `parse` without its cache (Python's `parse.__wrapped__`). */
export function parseUncached(text: string): Script {
  const script = new Script();
  try {
    new Reader(text, script, new Counter()).commands(0, null);
  } catch (error) {
    // ReadError stands for IndexError/ValueError, RangeError for RecursionError.
    if (!(error instanceof ReadError || error instanceof RangeError)) throw error;
    script.complete = false;
  }
  propagateScope(script.commands);
  return script;
}

function markScope(
  commands: readonly Command[],
  scope: { background?: boolean; repeated?: boolean },
): void {
  for (const command of commands) {
    command.background ||= scope.background ?? false;
    command.repeated ||= scope.repeated ?? false;
  }
}

/** Children can precede their parent, or be read later (shell heredocs). */
function propagateScope(commands: readonly Command[]): void {
  const pending = [...commands];
  for (let parent = pending.pop(); parent !== undefined; parent = pending.pop()) {
    for (const child of [...parent.nested, ...parent.substituted]) {
      const background = parent.background && !child.background;
      const repeated = parent.repeated && !child.repeated;
      if (background || repeated) {
        child.background ||= background;
        child.repeated ||= repeated;
        pending.push(child);
      }
    }
  }
}

/** What `word` does after reading one part. */
type Next =
  | "continue"
  | "fail" // unreadable: the script is incomplete
  | "stop"; // a substitution already failed: stop where it did

/** The command `commands` is reading, where it started, and its pipeline. */
class Pending {
  command: Command;
  members: Command[] = []; // current AND/OR list, groups included
  grouped = false;
  needsCommand = false; // after a pipeline or AND/OR operator

  constructor(
    public pipeline: number,
    public start: number,
  ) {
    this.command = new Command({ pipeline });
  }

  get empty(): boolean {
    return !(this.command.words.length > 0 || this.command.redirects.length > 0 || this.grouped);
  }
}

type LoopKind = "while" | "until" | "for";
const LOOP_KINDS: readonly LoopKind[] = ["while", "until", "for"];
const COMPOUND_PREFIXES: ReadonlySet<string> = new Set(["if", "then", "else", "elif", "!", "time"]);
const MISPLACED_KEYWORDS: readonly string[] = ["do", "done", "}"];
const UNBOUNDED_WHILE: readonly (readonly string[])[] = [["true"], [":"], ["[", "1", "]"]];
const UNBOUNDED_UNTIL: readonly (readonly string[])[] = [["false"]];
const ARITHMETIC_HEADER: readonly string[] = ["((", ";", ";", "))"];

/** One pass over `text[pos:]`; nested substitutions reuse the same reader (and
 * offsets), backticks and `sh -c` strings get a reader of their own. */
class Reader {
  pos = 0;
  literal = false; // inside an `sh -c` string: substitutions are its own
  heredocs: [string, boolean, Command][] = [];

  constructor(
    readonly text: string,
    readonly script: Script,
    readonly pipelines: Counter,
    readonly base = 0,
  ) {}

  /** `text[index]`: out of range is an error, as it is in Python. */
  at(index: number): string {
    if (index < 0 || index >= this.text.length) throw new ReadError("string index out of range");
    return this.text.charAt(index);
  }

  span(start: number, end: number): Span {
    return [this.base + start, this.base + end];
  }

  /** Every word is written exactly as it reads (no quotes or escapes) and, when given, is
   * one of `allowed`. Stops at the first word that isn't, like Python's lazy
   * `all(… for … in zip(words, spans, strict=True))`: a long command stays cheap. */
  unquoted(words: readonly string[], spans: readonly Span[], allowed?: ReadonlySet<string>): boolean {
    for (const [i, word] of words.entries()) {
      const span = spans[i];
      if (span === undefined) throw new ReadError("zip() arguments have different lengths");
      if (allowed !== undefined && !allowed.has(word)) return false;
      if (this.text.slice(span[0] - this.base, span[1] - this.base) !== word) return false;
    }
    if (spans.length !== words.length) throw new ReadError("zip() arguments have different lengths");
    return true;
  }

  fail(): void {
    this.script.complete = false;
    this.pos = this.text.length;
  }

  /** Read a list, returning whether its closing token (or EOF) was reached. */
  commands(depth: number, stop: string | null, pipeline: number | null = null): boolean {
    if (depth > MAX_DEPTH) {
      this.fail();
      return false;
    }
    const pending = new Pending(pipeline === null ? this.pipelines.next() : pipeline, this.pos);
    while (this.pos < this.text.length) {
      if (!this.commandPart(pending, depth, stop)) return this.script.complete;
    }
    this.finish(pending, true);
    if (stop !== null || pending.needsCommand) this.fail();
    return this.script.complete;
  }

  /** Record the command being read (if it has anything) and start the next one. */
  finish(pending: Pending, newPipeline: boolean): void {
    const command = pending.command;
    if (command.words.length > 0 || command.redirects.length > 0) {
      command.span = this.span(pending.start, this.pos);
      this.script.commands.push(command);
      pending.members.push(command);
    }
    if (newPipeline) {
      pending.pipeline = this.pipelines.next();
      pending.members = [];
    }
    pending.grouped = false;
    pending.command = new Command({ pipeline: pending.pipeline });
    pending.start = this.pos;
  }

  /** Read one blank, separator or token at `pos`; false when `commands` is done. */
  commandPart(pending: Pending, depth: number, stop: string | null): boolean {
    if (this.blank(pending) || this.separator(pending, depth)) return true;
    if (this.atStop(pending, stop)) {
      if (pending.needsCommand) {
        this.fail();
      } else {
        this.finish(pending, true);
        this.pos += (stop ?? "").length;
      }
      return false;
    }
    const read = this.compoundPart(pending, depth);
    pending.needsCommand = false;
    return read;
  }

  /** An unquoted, whole reserved word at the current token boundary. */
  keyword(word: string): boolean {
    const end = this.pos + word.length;
    return (
      this.text.startsWith(word, this.pos) &&
      (end === this.text.length || WORD_END.has(this.at(end)))
    );
  }

  atStop(pending: Pending, stop: string | null): boolean {
    if (stop === null) return false;
    if (stop === ")") return this.at(this.pos) === stop;
    return pending.empty && this.keyword(stop);
  }

  /** Keep compound commands together for a following pipeline or `&`. */
  compoundPart(pending: Pending, depth: number): boolean {
    if (this.compoundStart(pending)) {
      if (this.at(this.pos) === "(" || this.keyword("{")) return this.group(pending, depth);
      for (const kind of LOOP_KINDS) {
        if (this.keyword(kind)) return this.loop(pending, depth, kind);
      }
    }
    if (this.misplacedToken(pending)) {
      this.fail();
      return false;
    }
    return this.token(pending.command, depth);
  }

  /** Reserved prefixes can introduce compounds, but quoted words cannot. */
  compoundStart(pending: Pending): boolean {
    const command = pending.command;
    return (
      !(pending.grouped || command.redirects.length > 0) &&
      this.unquoted(command.words, command.spans, COMPOUND_PREFIXES)
    );
  }

  misplacedToken(pending: Pending): boolean {
    if (pending.empty && MISPLACED_KEYWORDS.some((word) => this.keyword(word))) return true;
    return pending.grouped && redirectAt(this.text, this.pos) === null;
  }

  group(pending: Pending, depth: number): boolean {
    const stop = this.at(this.pos) === "(" ? ")" : "}";
    const before = this.script.commands.length;
    this.pos += 1;
    // The group's first pipeline shares its surrounding pipe, not substitutions.
    const closed = this.commands(depth + 1, stop, pending.pipeline);
    pending.command = new Command({ pipeline: pending.pipeline });
    append(pending.members, this.script.commands.slice(before));
    pending.grouped = true;
    return closed;
  }

  /** Structure loop headers/bodies; only exact constant headers are unbounded. */
  loop(pending: Pending, depth: number, kind: LoopKind): boolean {
    const before = this.script.commands.length;
    this.pos += kind.length;
    const repeated = this.loopHeader(depth, kind);
    if (repeated === null) {
      this.fail();
      return false;
    }
    const body = this.script.commands.length;
    const closed = this.commands(depth + 1, "done");
    const members = this.script.commands.slice(before);
    // A following redirect belongs to the loop, even though it has no command name.
    pending.command = new Command({ pipeline: pending.pipeline, repeated: closed && repeated });
    if (closed) markScope(this.script.commands.slice(body), { repeated });
    append(pending.members, members);
    pending.grouped = true;
    return closed;
  }

  /** Whether the header is unbounded; null means unsupported/incomplete. */
  loopHeader(depth: number, kind: LoopKind): boolean | null {
    if (kind === "for") {
      const start = this.pos - kind.length;
      this.headerSpace();
      if (this.text.startsWith("((", this.pos)) return this.arithmeticLoopHeader() ? true : null;
      return this.wordLoopHeader(depth, start) ? false : null;
    }
    const before = this.script.commands.length;
    if (!this.commands(depth + 1, "do") || this.script.commands.length === before) return null;
    return this.constantCondition(this.script.commands.slice(before), kind);
  }

  /** Keep the existing `for name [in words]` header and its nested expansions. */
  wordLoopHeader(depth: number, start: number): boolean {
    const pending = new Pending(this.pipelines.next(), start);
    const command = pending.command;
    command.words.push("for");
    command.spans.push(this.span(start, start + "for".length));
    if (!this.wordLoopWords(pending, depth)) return false;
    if (this.wordLoopContinuation(command) && !this.wordLoopWords(pending, depth)) return false;
    if (!this.validWordLoop(command)) return false;
    this.finish(pending, true);
    this.pos += 1; // the required semicolon/newline before `do`
    return this.loopDo();
  }

  /** Only a newline after the variable may precede the optional `in` clause. */
  wordLoopContinuation(command: Command): boolean {
    if (command.words.length - 1 !== 1 || !this.text.startsWith("\n", this.pos)) return false;
    const start = this.pos;
    this.headerSpace();
    if (this.keyword("in")) return true;
    this.pos = start;
    return false;
  }

  wordLoopWords(pending: Pending, depth: number): boolean {
    const command = pending.command;
    while (this.pos < this.text.length && !";\n".includes(this.at(this.pos))) {
      if (this.blank(pending)) continue;
      if (WORD_END.has(this.at(this.pos))) return false;
      const word = this.word(depth, command, false);
      if (word === null) return false;
      command.words.push(word[0]);
      command.spans.push(word[1]);
    }
    return true;
  }

  validWordLoop(command: Command): boolean {
    const words = command.words.slice(1);
    const variable = words[0];
    if (variable === undefined || !isLoopVariable(variable)) return false;
    if (words.length > 1 && words[1] !== "in") return false;
    return this.unquoted(words.slice(0, 2), command.spans.slice(1, 3));
  }

  constantCondition(commands: readonly Command[], kind: LoopKind): boolean {
    const command = commands[0];
    if (commands.length !== 1 || command === undefined) return false;
    const expected = kind === "until" ? UNBOUNDED_UNTIL : UNBOUNDED_WHILE;
    const literal = this.unquoted(command.words, command.spans);
    return (
      literal &&
      command.redirects.length === 0 &&
      expected.some(
        (words) =>
          words.length === command.words.length && words.every((word, i) => word === command.words[i]),
      )
    );
  }

  /** Layout in the deliberately narrow `for ((;;))` header. */
  headerSpace(comments = true): void {
    const pending = new Pending(this.pipelines.next(), this.pos);
    while (this.pos < this.text.length) {
      if (this.at(this.pos) === "\n") {
        this.pos += 1;
      } else if ((!comments && this.at(this.pos) === "#") || !this.blank(pending)) {
        break;
      }
    }
  }

  arithmeticLoopHeader(): boolean {
    for (const token of ARITHMETIC_HEADER) {
      this.headerSpace(false);
      if (!this.text.startsWith(token, this.pos)) return false;
      this.pos += token.length;
    }
    this.headerSpace();
    if (this.text.startsWith(";", this.pos)) this.pos += 1;
    return this.loopDo();
  }

  loopDo(): boolean {
    this.headerSpace();
    if (!this.keyword("do")) return false;
    this.pos += "do".length;
    return true;
  }

  /** Skip a space/tab, line continuation or comment at `pos`. */
  blank(pending: Pending): boolean {
    const text = this.text;
    const blanks = blanksAt(text, this.pos);
    if (blanks !== null) {
      this.pos = blanks.index + blanks[0].length;
      if (pending.command.words.length === 0 && pending.command.redirects.length === 0) {
        pending.start = this.pos;
      }
      return true;
    }
    if (text.startsWith("\\\n", this.pos)) {
      this.pos += 2;
      return true;
    }
    if (this.at(this.pos) === "#") {
      const end = text.indexOf("\n", this.pos);
      this.pos = end === -1 ? text.length : end;
      return true;
    }
    return false;
  }

  /** A newline (then the heredoc bodies it opens) or a control operator at `pos`. */
  separator(pending: Pending, depth: number): boolean {
    const text = this.text;
    if (this.at(this.pos) === "\n") {
      this.newline(pending, depth);
      return true;
    }
    const op = operatorAt(text, this.pos);
    if (op === null || text.startsWith("&>", this.pos)) return false;
    if (pending.needsCommand || op[0] === ";;") {
      this.fail();
      return true;
    }
    this.pos = op.index + op[0].length;
    this.finish(pending, false);
    this.endOperator(pending, op[0]);
    return true;
  }

  newline(pending: Pending, depth: number): void {
    if (!pending.needsCommand) this.finish(pending, true);
    this.pos += 1;
    this.readHeredocs(depth);
    pending.start = this.pos;
  }

  endOperator(pending: Pending, op: string): void {
    if (op === "&") markScope(pending.members, { background: true });
    pending.needsCommand = op === "|" || op === "|&" || op === "&&" || op === "||";
    if (op !== "|" && op !== "|&") {
      // An asynchronous AND/OR list also belongs to the same `&`.
      if (op !== "&&" && op !== "||") pending.members = [];
      pending.pipeline = this.pipelines.next();
      pending.command.pipeline = pending.pipeline;
    }
  }

  /** A process substitution, redirection, subshell or word of `command`. */
  token(command: Command, depth: number): boolean {
    const text = this.text;
    const c = this.at(this.pos);
    if ((c === "<" || c === ">") && text.startsWith("(", this.pos + 1)) {
      this.substitution(command, depth, this.pos, this.pos + 2);
      return true;
    }
    // At a token start, so a leading fd number (`2>`) belongs to the redirection.
    const redirect = redirectAt(text, this.pos);
    if (redirect !== null) {
      this.pos = redirect.index + redirect[0].length;
      this.redirect(command, redirect[0].replace(/^[0-9]+/, ""), redirect.index, depth);
      return true;
    }
    if (c === "(" || c === ")") {
      this.fail(); // a function, case pattern, or misplaced parenthesis
      return false;
    }
    const word = this.word(depth, command);
    if (word !== null) {
      command.words.push(word[0]);
      command.spans.push(word[1]);
    }
    return word !== null;
  }

  redirect(command: Command, op: string, at: number, depth: number): void {
    while (this.pos < this.text.length && " \t".includes(this.at(this.pos))) this.pos += 1;
    const target = this.word(depth, command, false);
    if (target === null) return;
    const word = target[0];
    command.redirects.push([op, word, this.span(at, this.pos)]);
    if (op === "<<" || op === "<<-") this.heredocs.push([word, op === "<<-", command]);
  }

  /** Bodies of the heredocs opened on the line just ended, in order. */
  readHeredocs(depth: number): void {
    const text = this.text;
    for (const [delimiter, stripTabs, command] of this.heredocs) {
      const body = this.pos;
      let end = text.length;
      let close = text.length;
      let line = this.pos;
      while (line < text.length) {
        const nl = text.indexOf("\n", line);
        const stop = nl === -1 ? text.length : nl;
        const current = text.slice(line, stop);
        if ((stripTabs ? current.replace(/^\t+/, "") : current) === delimiter) {
          end = line;
          close = stop;
          break;
        }
        line = stop + 1;
      }
      this.pos = close;
      const name = command.name;
      if (name !== null && SHELLS.has(name) && !command.words.some(isShellC)) {
        this.nested(command, text.slice(body, end), body, depth);
      } else {
        this.script.bodies.push(this.span(body, end));
        this.script.bodyCommands.push(command);
        if (name !== null && FILE_WRITERS.has(name)) {
          const target = writes(command)[0];
          if (target !== undefined) {
            this.script.fileBodies.push(this.span(body, end));
            this.script.fileTargets.push(target[0]);
          }
        }
      }
    }
    this.heredocs = [];
  }

  /** Commands in `text` (a backtick body, heredoc or `sh -c` string) run by
   * `command`: parsed with their own reader, spans kept relative to this text. */
  nested(command: Command, text: string, offset: number, depth: number, substituted = false): void {
    if (depth > MAX_DEPTH) {
      this.fail();
      return;
    }
    const inner = new Script();
    const reader = new Reader(text, inner, this.pipelines, this.base + offset);
    reader.commands(depth + 1, null);
    this.script.complete &&= inner.complete;
    // Spans are already absolute (`base`). The four lists are parallel pairs: merge
    // all of them, or a heredoc nested in `bash <<EOF` misaligns bodies and owners.
    append(this.script.bodies, inner.bodies);
    append(this.script.bodyCommands, inner.bodyCommands);
    append(this.script.fileBodies, inner.fileBodies);
    append(this.script.fileTargets, inner.fileTargets);
    append(substituted ? command.substituted : command.nested, inner.commands);
    append(this.script.commands, inner.commands);
  }

  /** `$(…)`, `<(…)` or `>(…)` starting at `start`: its commands belong to `command`. */
  substitution(command: Command, depth: number, start: number, inner: number): void {
    const before = this.script.commands.length;
    this.pos = inner;
    this.commands(depth + 1, ")");
    append(command.substituted, this.script.commands.slice(before));
    command.words.push(this.text.slice(start, this.pos));
    command.spans.push(this.span(start, this.pos));
  }

  /** One word, quotes removed; substitutions inside it are read as commands (their
   * raw text stays in the word). */
  word(depth: number, command: Command, operand = true): Word | null {
    const text = this.text;
    const start = this.pos;
    const out: string[] = [];
    // `sh -c '…'` / `bash -lc "…"`: the string is a script the shell runs. Read it
    // literally here and parse it once, as a script.
    const script = operand && start < text.length && runsScript(command);
    const outer = this.literal;
    this.literal = script;
    while (this.pos < text.length && !WORD_END.has(this.at(this.pos))) {
      const plain = plainAt(text, this.pos);
      if (plain !== null) {
        out.push(plain[0]);
        this.pos = plain.index + plain[0].length;
        continue;
      }
      const step = this.wordPart(out, depth, command);
      if (step !== "continue") {
        // As in the original, `literal` is left as it is on this path.
        if (step === "fail") this.fail();
        return null;
      }
    }
    const word = out.join("");
    this.literal = outer;
    if (script) {
      const quote = this.at(start);
      this.nested(command, word, start + (quote === "'" || quote === '"' ? 1 : 0), depth);
    }
    return [word, this.span(start, this.pos)];
  }

  /** Read one quoted string, escape, expansion or character of a word into `out`. */
  wordPart(out: string[], depth: number, command: Command): Next {
    const c = this.at(this.pos);
    if (this.literal && (c === "$" || c === "`")) return this.keep(out);
    const expansion = this.expansion(out, depth, command);
    if (expansion !== null) return expansion;
    // Word parts by their first character (anything else is a plain character).
    switch (c) {
      case "\\":
        return this.escaped(out);
      case "'":
        return this.singleQuoted(out);
      case '"':
        return this.quoted(out, depth, command);
      case "$":
        return this.parameter(out);
      default:
        return this.keep(out);
    }
  }

  /** The character at `pos`, as it is. */
  keep(out: string[]): Next {
    out.push(this.at(this.pos));
    this.pos += 1;
    return "continue";
  }

  escaped(out: string[]): Next {
    if (!this.text.startsWith("\n", this.pos + 1)) {
      // else a line continuation
      out.push(this.text.slice(this.pos + 1, this.pos + 2));
    }
    this.pos += 2;
    return "continue";
  }

  singleQuoted(out: string[]): Next {
    const end = this.text.indexOf("'", this.pos + 1);
    if (end === -1) return "fail";
    out.push(this.text.slice(this.pos + 1, end));
    this.pos = end + 1;
    return "continue";
  }

  quoted(out: string[], depth: number, command: Command): Next {
    return this.doubleQuoted(out, depth, command) ? "continue" : "fail";
  }

  /** `${…}` kept as text; any other `$` is a plain character. */
  parameter(out: string[]): Next {
    if (!this.text.startsWith("${", this.pos)) return this.keep(out);
    const end = this.text.indexOf("}", this.pos);
    if (end === -1) return "fail";
    out.push(this.text.slice(this.pos, end + 1));
    this.pos = end + 1;
    return "continue";
  }

  /** `$((…))`, `$(…)` or a backtick substitution at `pos`, else null. */
  expansion(out: string[], depth: number, command: Command): Next | null {
    const text = this.text;
    if (text.startsWith("$((", this.pos)) return this.balanced(out, 1) ? "continue" : "fail";
    if (text.startsWith("$(", this.pos)) {
      return this.commandSubstitution(out, depth, command) ? "continue" : "stop";
    }
    if (text.startsWith("`", this.pos)) {
      return this.backticks(out, depth, command) ? "continue" : "fail";
    }
    return null;
  }

  commandSubstitution(out: string[], depth: number, command: Command): boolean {
    const start = this.pos;
    const before = this.script.commands.length;
    this.pos += 2;
    this.commands(depth + 1, ")");
    append(command.substituted, this.script.commands.slice(before));
    out.push(this.text.slice(start, this.pos));
    return this.script.complete;
  }

  backticks(out: string[], depth: number, command: Command): boolean {
    let end = this.pos + 1;
    while (end < this.text.length && this.at(end) !== "`") {
      end += this.at(end) === "\\" ? 2 : 1;
    }
    if (end >= this.text.length) return false;
    this.nested(command, this.text.slice(this.pos + 1, end), this.pos + 1, depth, true);
    out.push(this.text.slice(this.pos, end + 1));
    this.pos = end + 1;
    return true;
  }

  /** `$((…))` arithmetic: kept as text. */
  balanced(out: string[], skip: number): boolean {
    let level = 0;
    let i = this.pos + skip;
    while (i < this.text.length) {
      const c = this.at(i);
      level += c === "(" ? 1 : c === ")" ? -1 : 0;
      i += 1;
      if (level === 0) break;
    }
    if (level !== 0) return false;
    out.push(this.text.slice(this.pos, i));
    this.pos = i;
    return true;
  }

  doubleQuoted(out: string[], depth: number, command: Command): boolean {
    const text = this.text;
    this.pos += 1;
    while (this.pos < text.length) {
      if (this.at(this.pos) === '"') {
        this.pos += 1;
        return true;
      }
      const plain = quotedPlainAt(text, this.pos);
      if (plain !== null) {
        out.push(plain[0]);
        this.pos = plain.index + plain[0].length;
        continue;
      }
      if (!this.quotedPart(out, depth, command)) return false;
    }
    return false;
  }

  /** Read one escape, expansion or character inside double quotes into `out`. */
  quotedPart(out: string[], depth: number, command: Command): boolean {
    const text = this.text;
    const c = this.at(this.pos);
    if (c === "\\" && this.pos + 1 < text.length) {
      const nxt = this.at(this.pos + 1);
      if (nxt !== "\n") out.push('\\$`"'.includes(nxt) ? nxt : c + nxt);
      this.pos += 2;
      return true;
    }
    // In an `sh -c` string, `$` and backticks are the script's own.
    const expansion = this.literal ? null : this.expansion(out, depth, command);
    if (expansion === null) {
      this.keep(out);
      return true;
    }
    return expansion === "continue";
  }
}

/** `target += items`, without spreading a large list into call arguments. */
function append<T>(target: T[], items: readonly T[]): void {
  for (const item of items) target.push(item);
}

// Commands whose heredoc body is written out verbatim (to their redirect or tee target).
export const FILE_WRITERS: ReadonlySet<string> = new Set(["cat", "tee"]);

/** The written heredoc bodies (`fileBodies`) whose file no other command in the script
 * names afterwards: file content, not something the script then runs or uses. */
export function unusedFileBodies(script: Script): Span[] {
  const out: Span[] = [];
  for (const [span, target] of zipStrict(script.fileBodies, script.fileTargets)) {
    const used = script.commands.some((c) => {
      const name = c.name;
      const writer = name !== null && FILE_WRITERS.has(name) && writes(c).some(([t]) => t === target);
      return !writer && c.words.some((w) => namesFile(w, target));
    });
    if (!used) out.push(span);
  }
  return out;
}

/** `word` is the written file `target`: the same path, or its file name. */
function namesFile(word: string, target: string): boolean {
  const base = basename(target);
  return word === target || word === base || word.endsWith(`/${base}`);
}

/** `command` is a shell whose last word is `-c` (the next word is a script). */
export function runsScript(command: Command): boolean {
  const last = command.words[command.words.length - 1];
  if (last === undefined || !isShellC(last)) return false;
  const name = command.name;
  return name !== null && SHELLS.has(name);
}

// --- facts callers use -----------------------------------------------------------------

const NO_VALUES: ReadonlySet<string> = new Set<string>();

/** Non-option arguments after the command name, skipping the values of `values`
 * options (everything after `--` is an operand). */
export function operands(argv: readonly Word[], values: ReadonlySet<string> = NO_VALUES): Word[] {
  const out: Word[] = [];
  let options = true;
  let skip = false;
  for (const [word, span] of argv.slice(1)) {
    if (skip) {
      skip = false;
    } else if (options && word === "--") {
      options = false;
    } else if (options && word.startsWith("-") && word !== "-") {
      skip = values.has(word);
    } else {
      out.push([word, span]);
    }
  }
  return out;
}

// Options whose value is a separate word (so it isn't taken for a file).
export const COPY_VALUES: ReadonlySet<string> = new Set([
  "-t",
  "--target-directory",
  "-S",
  "--suffix",
  "-m",
  "--mode",
  "-o",
  "--owner",
  "-g",
  "--group",
  "-e",
  "--rsh",
]);
export const SED_SCRIPT: ReadonlySet<string> = new Set(["-e", "--expression", "-f", "--file"]);

/** Files `command` writes: redirection targets, and the destinations of tee, touch,
 * cp, mv, install, rsync, ln, dd `of=` and `sed -i`. */
export function writes(command: Command): Word[] {
  const out: Word[] = [];
  for (const [op, target, span] of command.redirects) {
    if (WRITE_OPS.has(op) && !(op === ">&" && (isDigits(target) || target === "-"))) {
      out.push([target, span]);
    }
  }
  const written = ARGUMENT_WRITES.get(command.name ?? "");
  return written === undefined ? out : [...out, ...written(command.argv())];
}

// A source and a destination.
export const MIN_COPY_OPERANDS = 2;

function copyDestination(argv: readonly Word[]): Word[] {
  const words = argv.slice(1);
  for (const [i, [word, span]] of words.entries()) {
    const next = words[i + 1];
    if ((word === "-t" || word === "--target-directory") && next !== undefined) return [next];
    if (word.startsWith("--target-directory=")) return [[word.slice(word.indexOf("=") + 1), span]];
  }
  const paths = operands(argv, COPY_VALUES);
  return paths.length >= MIN_COPY_OPERANDS ? paths.slice(-1) : [];
}

function ddOutput(argv: readonly Word[]): Word[] {
  return argv
    .slice(1)
    .filter(([w]) => w.startsWith("of="))
    .map(([w, s]): Word => [w.slice(3), s]);
}

function sedInPlace(argv: readonly Word[]): Word[] {
  const words = argv.slice(1);
  if (!words.some(([w]) => w.startsWith("-i") || w.startsWith("--in-place"))) return [];
  const paths = operands(argv, SED_SCRIPT);
  const scripted = words.some(([w]) => SED_SCRIPT.has(optionName(w)));
  return scripted ? paths : paths.slice(1);
}

/** `word.split("=", 1)[0]`. */
function optionName(word: string): string {
  const equals = word.indexOf("=");
  return equals === -1 ? word : word.slice(0, equals);
}

// Files a command names as its output, by command name.
export const ARGUMENT_WRITES: ReadonlyMap<string, (argv: readonly Word[]) => Word[]> = new Map<
  string,
  (argv: readonly Word[]) => Word[]
>([
  ["tee", (argv) => operands(argv)],
  ["touch", (argv) => operands(argv)],
  ["cp", copyDestination],
  ["mv", copyDestination],
  ["install", copyDestination],
  ["rsync", copyDestination],
  ["ln", copyDestination],
  ["dd", ddOutput],
  ["sed", sedInPlace],
]);

/** For each command (Python keys them by `id`), the commands its output is piped into. */
export function laterInPipeline(script: Script): Map<Command, Command[]> {
  const byPipeline = new Map<number, Command[]>();
  for (const command of [...script.commands].sort((a, b) => a.span[0] - b.span[0])) {
    const members = byPipeline.get(command.pipeline);
    if (members === undefined) byPipeline.set(command.pipeline, [command]);
    else members.push(command);
  }
  const out = new Map<Command, Command[]>();
  for (const members of byPipeline.values()) {
    for (const [i, command] of members.entries()) out.set(command, members.slice(i + 1));
  }
  return out;
}

// grep-family and ripgrep options, for telling a search pattern from a file operand.
// Per tool: `-E` is a flag to grep but takes an encoding in rg. Pattern options (`-e`)
// and file options (`-f`) take a value too.
const GREP_SHORT_FLAGS: ReadonlySet<string> = new Set("abcEFGHhIiLlnoPqRrsTUuVvwxyZz");
const GREP_SHORT_VALUES: ReadonlySet<string> = new Set("ABCmdD");
const GREP_LONG_VALUES: ReadonlySet<string> = new Set([
  "--after-context",
  "--before-context",
  "--context",
  "--max-count",
  "--directories",
  "--devices",
  "--label",
  "--binary-files",
  "--include",
  "--exclude",
  "--exclude-dir",
  "--exclude-from",
  "--group-separator",
  "--color",
  "--colour",
]);
const RG_SHORT_FLAGS: ReadonlySet<string> = new Set("abcFHhiIlLnNopqsSuUvVwxz0");
const RG_SHORT_VALUES: ReadonlySet<string> = new Set("ABCmMgtTEjdr");
const RG_LONG_VALUES: ReadonlySet<string> = new Set([
  "--after-context",
  "--before-context",
  "--context",
  "--max-count",
  "--max-columns",
  "--glob",
  "--iglob",
  "--type",
  "--type-not",
  "--type-add",
  "--type-clear",
  "--encoding",
  "--threads",
  "--max-depth",
  "--max-filesize",
  "--replace",
  "--pre",
  "--pre-glob",
  "--sort",
  "--sortr",
  "--colors",
  "--color",
  "--context-separator",
  "--field-match-separator",
  "--field-context-separator",
  "--path-separator",
  "--engine",
  "--ignore-file",
]);

/** `(short flags, short options taking a value, long options taking a value)`. */
export type SearcherTables = readonly [ReadonlySet<string>, ReadonlySet<string>, ReadonlySet<string>];

const GREP_TABLES: SearcherTables = [GREP_SHORT_FLAGS, GREP_SHORT_VALUES, GREP_LONG_VALUES];
export const SEARCHERS: ReadonlyMap<string, SearcherTables> = new Map<string, SearcherTables>([
  ["grep", GREP_TABLES],
  ["egrep", GREP_TABLES],
  ["fgrep", GREP_TABLES],
  ["ggrep", GREP_TABLES],
  ["rg", [RG_SHORT_FLAGS, RG_SHORT_VALUES, RG_LONG_VALUES]],
]);
const PATTERN_OPTIONS: ReadonlySet<string> = new Set(["-e", "--regexp"]);
const NO_PATTERN: ReadonlySet<string> = new Set(["--files", "--type-list"]);
const FILE_OPTIONS: ReadonlySet<string> = new Set(["-f", "--file"]);

class Search {
  patterns: Span[] = [];
  operands: Span[] = [];
  given = false; // a pattern or pattern file came from an option

  constructor(
    readonly flags: ReadonlySet<string>,
    readonly values: ReadonlySet<string>,
    readonly longValues: ReadonlySet<string>,
  ) {}
}

/** Python's `iter(words)` with `next(words, default)`. */
class WordCursor {
  private index = 0;

  constructor(private readonly words: readonly Word[]) {}

  next(): Word | undefined {
    const word = this.words[this.index];
    if (word !== undefined) this.index += 1;
    return word;
  }
}

/** Spans of the search patterns of a grep-family or rg command (its `-e` values, or
 * its first operand): text matched against, never a file it opens. `-f` files are not
 * patterns. null when the command isn't one, or an option isn't known (it might take
 * the next word, so which word is the pattern is unsure). */
export function searchPatterns(command: Command): Span[] | null {
  const tables = SEARCHERS.get(command.name ?? "");
  if (tables === undefined) return null;
  const search = new Search(...tables);
  const words = new WordCursor(command.argv().slice(1));
  for (let next = words.next(); next !== undefined; next = words.next()) {
    const [word, span] = next;
    if (word === "--") {
      for (let rest = words.next(); rest !== undefined; rest = words.next()) {
        search.operands.push(rest[1]);
      }
      break;
    }
    if (!searchWord(search, word, span, words)) return null;
  }
  const first = search.operands[0];
  if (!search.given && first !== undefined) search.patterns.push(first);
  return search.patterns;
}

/** Known grep/rg pattern operands, never commands used to construct them.
 *
 * Incomplete scripts get no exemption; substitution command spans are retained.
 * Consumers must restrict this to shell commands, not arbitrary written code. */
export function literalSearchPatterns(text: string): readonly Span[] {
  const script = parse(text);
  if (!script.complete) return [];
  const out: Span[] = [];
  for (const command of script.commands) {
    for (const span of searchPatterns(command) ?? []) {
      append(out, literalPatternParts(command, span));
    }
  }
  return out;
}

function literalPatternParts(command: Command, span: Span): Span[] {
  let start = span[0];
  const end = span[1];
  const parts: Span[] = [];
  const children = command.substituted
    .map((child) => child.span)
    .sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  for (const [childStart, childEnd] of children) {
    if (childEnd <= start || childStart >= end) continue;
    if (start < childStart) parts.push([start, childStart]);
    start = Math.max(start, childEnd);
  }
  if (start < end) parts.push([start, end]);
  return parts;
}

/** Read one word of a search command; false when its meaning is unsure. */
function searchWord(search: Search, word: string, span: Span, words: WordCursor): boolean {
  if (!word.startsWith("-") || word === "-") {
    search.operands.push(span);
    return true;
  }
  if (word.startsWith("--")) return searchLong(search, word, span, words);
  return searchShort(search, word, span, words);
}

/** A cluster of short options (`-rn`, `-A3`, `-ie PATTERN`). */
function searchShort(search: Search, word: string, span: Span, words: WordCursor): boolean {
  for (let k = 1; k < word.length; k += 1) {
    const letter = word.charAt(k);
    if (letter === "e" || letter === "f" || search.values.has(letter)) {
      const attached = word.length > k + 1;
      return take(search, letter, attached ? span : (words.next()?.[1] ?? null));
    }
    if (!search.flags.has(letter)) return false;
  }
  return true;
}

/** An option's value: a pattern (`e`), a pattern file (`f`) or anything else. */
function take(search: Search, option: string, value: Span | null): boolean {
  if (value === null) return false;
  search.given ||= option === "e" || option === "f";
  if (option === "e") search.patterns.push(value);
  return true;
}

function searchLong(search: Search, word: string, span: Span, words: WordCursor): boolean {
  const hasValue = word.includes("=");
  const name = optionName(word);
  if (NO_PATTERN.has(name)) {
    search.given = true; // `rg --files DIR`: every operand is a path, none a pattern
    return true;
  }
  if (PATTERN_OPTIONS.has(name) || FILE_OPTIONS.has(name)) {
    const value = hasValue ? span : (words.next()?.[1] ?? null);
    return take(search, PATTERN_OPTIONS.has(name) ? "e" : "f", value);
  }
  if (search.longValues.has(name) && !hasValue) return words.next() !== undefined;
  // A known value option written `--x=v`, or any `--flag`: an unknown long option without
  // `=` might still take the next word, so only `=` forms and listed values are sure.
  return hasValue || LONG_FLAGS.has(name);
}

const LONG_FLAGS: ReadonlySet<string> = new Set([
  "--files",
  "--files-with-matches",
  "--files-without-match",
  "--count",
  "--line-number",
  "--no-line-number",
  "--with-filename",
  "--no-filename",
  "--ignore-case",
  "--smart-case",
  "--case-sensitive",
  "--fixed-strings",
  "--extended-regexp",
  "--basic-regexp",
  "--perl-regexp",
  "--word-regexp",
  "--line-regexp",
  "--invert-match",
  "--only-matching",
  "--quiet",
  "--silent",
  "--recursive",
  "--dereference-recursive",
  "--hidden",
  "--no-ignore",
  "--no-ignore-vcs",
  "--follow",
  "--text",
  "--null",
  "--no-heading",
  "--heading",
  "--json",
  "--vimgrep",
  "--multiline",
  "--pcre2",
  "--no-messages",
  "--search-zip",
  "--trim",
  "--unrestricted",
  "--column",
  "--byte-offset",
  "--initial-tab",
  "--max-columns-preview",
  "--stats",
  "--debug",
]);
