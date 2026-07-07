// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §9 Phase 3, beat matrix Axis 5 — "chat-with-files RAG v1"). Built into
// src/web/app.js by scripts/build-web.ts.
//
// A small, dependency-free, pure BM25 retriever over attached-file text —
// matching optiq Lab's shipped v1 shape (the task's explicit target): chunk
// per-file, tokenize, score chunks against the outgoing message, return the
// top-K with enough metadata (filename + char range) for composer.ts to
// build a cited context block and chat.ts to render a Sources panel.
//
// No network, no embeddings, no external deps — this is the "dependency-
// free BM25 proves the v1 needs no vector infra" bet from the beat matrix.
// A later vector upgrade (src/embed.ts) is explicitly out of scope here
// (Phase 5).

/* ────────────────────────────────────────────────────────────────────
   Chunking
   ──────────────────────────────────────────────────────────────────── */

/** One retrievable unit: a slice of one attached file's text, with the
 *  original [start,end) char offsets so the Sources panel can show a
 *  meaningful "filename + range" citation. */
export interface Chunk {
  fileId: number;
  fileName: string;
  start: number;
  end: number;
  text: string;
}

const CHUNK_TARGET = 1200;

/** Split one file's text into ~CHUNK_TARGET-char chunks, preferring to break
 *  on paragraph boundaries (blank lines) so a chunk doesn't slice through
 *  the middle of a paragraph when a nearby boundary is available. Pure:
 *  takes text in, returns chunks with byte-accurate offsets into that same
 *  text (no trimming of the returned `text` field's positions — leading/
 *  trailing whitespace inside a chunk is fine, it's still exactly
 *  text.slice(start, end)).
 *
 *  Algorithm: walk paragraph boundaries (split on /\n\s*\n/, keeping track
 *  of each paragraph's offset in the original string) and greedily pack
 *  paragraphs into a chunk until adding the next one would exceed
 *  CHUNK_TARGET *and* the chunk already has content — mirroring a standard
 *  greedy bin-packing chunker. A single paragraph longer than CHUNK_TARGET
 *  becomes its own oversized chunk rather than being split mid-word (never
 *  produce an empty chunk, never lose text). */
export function chunkText(fileId: number, fileName: string, text: string): Chunk[] {
  if (!text) return [];
  const chunks: Chunk[] = [];
  // Split on blank-line paragraph boundaries, tracking each paragraph's
  // [start,end) in the ORIGINAL string (not the split pieces' own indices).
  const paraRe = /\n\s*\n/g;
  const paras: { start: number; end: number }[] = [];
  let last = 0;
  let m: RegExpExecArray | null;
  while ((m = paraRe.exec(text))) {
    paras.push({ start: last, end: m.index });
    last = m.index + m[0].length;
  }
  paras.push({ start: last, end: text.length });

  let curStart = -1, curEnd = -1;
  const flush = () => {
    if (curStart < 0 || curEnd <= curStart) return;
    chunks.push({ fileId, fileName, start: curStart, end: curEnd, text: text.slice(curStart, curEnd) });
    curStart = -1; curEnd = -1;
  };
  for (const p of paras) {
    if (p.end <= p.start) continue; // blank paragraph (consecutive blank lines) — nothing to add
    const paraLen = p.end - p.start;
    if (curStart < 0) {
      // Starting a fresh chunk with this paragraph.
      curStart = p.start; curEnd = p.end;
      if (paraLen >= CHUNK_TARGET) flush(); // oversized single paragraph -> its own chunk immediately
      continue;
    }
    const curLen = curEnd - curStart;
    if (curLen + paraLen > CHUNK_TARGET) {
      // Adding this paragraph would overflow the target — close the current
      // chunk at the last paragraph boundary and start a new one with this
      // paragraph (paragraph-boundary-preferring: we never split a paragraph
      // in half to hit the target exactly).
      flush();
      curStart = p.start; curEnd = p.end;
      if (paraLen >= CHUNK_TARGET) flush();
    } else {
      curEnd = p.end;
    }
  }
  flush();
  return chunks;
}

/** Chunk every attached text file (name/text pairs) into one flat list,
 *  independently per file (chunks never span files) — the shape composer.ts
 *  feeds from ComposerState.attachments. */
export function chunkFiles(files: { id: number; name: string; text: string }[]): Chunk[] {
  const out: Chunk[] = [];
  for (const f of files) out.push(...chunkText(f.id, f.name, f.text));
  return out;
}

/* ────────────────────────────────────────────────────────────────────
   Tokenizer
   ──────────────────────────────────────────────────────────────────── */

/** Lowercase, alnum-run tokenizer. Pure and deliberately simple — no
 *  stemming/stopwords, matching the "dependency-free" bar; BM25's own
 *  length-normalization and IDF weighting do most of the useful work even
 *  over a raw token stream. */
export function tokenize(text: string): string[] {
  const m = text.toLowerCase().match(/[a-z0-9]+/g);
  return m || [];
}

/* ────────────────────────────────────────────────────────────────────
   BM25 index + scoring
   ──────────────────────────────────────────────────────────────────── */

// BM25 standard formula (Robertson/Sparck Jones), as in Manning/Raghavan/
// Schütze "Introduction to Information Retrieval" §11.4.3:
//
//   score(D,Q) = Σ_{t∈Q} IDF(t) · ( f(t,D)·(k1+1) ) / ( f(t,D) + k1·(1-b+b·|D|/avgdl) )
//
// with IDF(t) = ln( (N - n(t) + 0.5) / (n(t) + 0.5) + 1 )  (the "+1" variant
// that keeps IDF non-negative for terms present in every document, per the
// same reference). k1=1.5, b=0.75 are the conventional defaults used there.
const K1 = 1.5;
const B = 0.75;

interface IndexedChunk {
  chunk: Chunk;
  termCounts: Map<string, number>;
  length: number;
}

/** A BM25 index over a fixed chunk set. Built lazily (see buildIndex) and
 *  meant to be rebuilt whenever the attachment set changes — indexing a
 *  few dozen small chunks is cheap enough that no incremental-update path
 *  is warranted. */
export interface Bm25Index {
  chunks: IndexedChunk[];
  df: Map<string, number>; // document frequency per term
  avgLength: number;
  n: number;
}

export function buildIndex(chunks: Chunk[]): Bm25Index {
  const indexed: IndexedChunk[] = [];
  const df = new Map<string, number>();
  let totalLen = 0;
  for (const chunk of chunks) {
    const toks = tokenize(chunk.text);
    const termCounts = new Map<string, number>();
    for (const t of toks) termCounts.set(t, (termCounts.get(t) || 0) + 1);
    for (const t of termCounts.keys()) df.set(t, (df.get(t) || 0) + 1);
    totalLen += toks.length;
    indexed.push({ chunk, termCounts, length: toks.length });
  }
  return {
    chunks: indexed,
    df,
    avgLength: indexed.length ? totalLen / indexed.length : 0,
    n: indexed.length,
  };
}

function idf(index: Bm25Index, term: string): number {
  const n = index.df.get(term) || 0;
  return Math.log((index.n - n + 0.5) / (n + 0.5) + 1);
}

export interface ScoredChunk {
  chunk: Chunk;
  score: number;
}

/** Score every chunk in `index` against `query`, returning the top `k` by
 *  descending BM25 score (ties broken by original chunk order, stable).
 *  Chunks that score 0 (no query term present at all) are excluded — a
 *  zero-overlap chunk is never a useful citation regardless of how few
 *  chunks exist. */
export function bm25TopK(index: Bm25Index, query: string, k: number): ScoredChunk[] {
  const qTerms = tokenize(query);
  if (!qTerms.length || !index.n) return [];
  // Dedupe query terms but keep per-term query frequency out of the score
  // (standard BM25 as written above weights by document term frequency
  // only; query-term repetition isn't part of the classic formula).
  const uniqueTerms = [...new Set(qTerms)];
  const scored: ScoredChunk[] = [];
  for (const ic of index.chunks) {
    let score = 0;
    for (const term of uniqueTerms) {
      const f = ic.termCounts.get(term);
      if (!f) continue;
      const numer = f * (K1 + 1);
      const denom = f + K1 * (1 - B + (B * ic.length) / (index.avgLength || 1));
      score += idf(index, term) * (numer / denom);
    }
    if (score > 0) scored.push({ chunk: ic.chunk, score });
  }
  scored.sort((a, b) => b.score - a.score);
  return scored.slice(0, k);
}

/* ────────────────────────────────────────────────────────────────────
   Inline-vs-RAG decision + context-block assembly
   ──────────────────────────────────────────────────────────────────── */

/** Above this total attached-text size, switch from "inline everything"
 *  to "retrieve top-K chunks" — LM Studio's transparent dual-mode
 *  threshold (beat matrix Axis 5), tuned so ordinary small attachments
 *  (READMEs, short notes) never change behavior at all. */
export const INLINE_THRESHOLD_CHARS = 8000;

export const TOP_K = 6;

/** Pure: does this total attached-text length trigger retrieval mode? */
export function shouldRetrieve(totalChars: number): boolean {
  return totalChars > INLINE_THRESHOLD_CHARS;
}

/** One numbered citation as composer.ts will inject it and chat.ts will
 *  reference by index — `n` is the 1-based [n] marker shown to the model
 *  and rendered back to the user. */
export interface Citation {
  n: number;
  fileName: string;
  start: number;
  end: number;
  text: string;
}

/** Build the numbered [1]..[K] citation list from a scored top-K result.
 *  Pure — shared by composer.ts (building the outgoing context block) and
 *  chat.ts/tests (rendering the Sources panel from the same shape). */
export function toCitations(top: ScoredChunk[]): Citation[] {
  return top.map((s, i) => ({
    n: i + 1,
    fileName: s.chunk.fileName,
    start: s.chunk.start,
    end: s.chunk.end,
    text: s.chunk.text,
  }));
}

/** Render the framed context block injected ahead of the user's message
 *  when in retrieval mode: each citation numbered [n] with filename+range,
 *  then ONE instruction line asking the model to cite sources with [n]
 *  markers when used. Plain text (this goes into the outgoing prompt, not
 *  HTML) — chat.ts/markdown.ts handle rendering [n] markers back as links
 *  separately, from the citation map, not from parsing this block. */
export function buildContextBlock(citations: Citation[]): string {
  if (!citations.length) return "";
  let out = "Context from attached files (retrieved by relevance to your message):\n\n";
  for (const c of citations) {
    out += `[${c.n}] ${c.fileName} (chars ${c.start}-${c.end}):\n${c.text}\n\n`;
  }
  out += "When you use information from the context above, cite it inline with the matching [n] marker.\n\n";
  return out;
}

/** Full retrieval pipeline for one outgoing message: chunk the attached
 *  text files, index them, score against `queryText`, and return the
 *  top-K as citations ready for buildContextBlock. Returns [] if there's
 *  nothing to retrieve (no text files, or no query overlap at all). */
export function retrieve(files: { id: number; name: string; text: string }[], queryText: string, k = TOP_K): Citation[] {
  const chunks = chunkFiles(files);
  if (!chunks.length) return [];
  const index = buildIndex(chunks);
  const top = bm25TopK(index, queryText, k);
  return toCitations(top);
}
