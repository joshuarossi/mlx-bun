# Kernel proofs

Start with one small, precisely specified piece, prove its implementation, then
use its postcondition when proving callers. These checks run during development;
they add no checks or dispatch to inference.

The first proof covers `trellis_y`, the integer helper in
[`codebook.ts`](../packages/inference/src/kernels/trellis/codebook.ts) shared by
Trellis GPU kernels. It is a source-level proof of this helper, not yet a proof
of an entire GPU launch or matrix multiplication.

## 1. Write the contract independently of the optimization

For every unsigned 32-bit input `s`, define:

```text
x = (34038481 * s + 76625530) mod 2^32
b0 = x mod 256
b1 = floor(x / 256) mod 256
b2 = floor(x / 65536) mod 256
b3 = floor(x / 16777216) mod 256

trellis_y(s) = b0 + b1 + b2 + b3 - 510
-510 <= trellis_y(s) <= 510
```

There are no further input preconditions. The helper reads and writes no memory
and has no effects outside its local variables. Its signed operations must not
overflow. The constants in the specification are fixed independently of the
implementation: changing a multiplier or offset in production cannot silently
change what the proof claims.

## 2. Explain why the optimized arithmetic should work

The implementation computes the byte sum using two packed lanes:

```text
x & 0x00FF00FF        = b0 + 65536*b2
(x >> 8) & 0x00FF00FF = b1 + 65536*b3
p                    = (b0+b1) + 65536*(b2+b3)
```

Each byte pair is at most 510, so neither pair overflows its 16-bit lane.
Consequently, `(p & 0xFFFF) + (p >> 16)` is exactly the sum of the four
bytes, between 0 and 1020. Converting that sum to signed `int` and subtracting
510 is safe and gives the stated result and range.

This is the human argument. The next steps make the computer check it against
the implementation for every possible input.

## 3. Model the language's actual arithmetic

[`trellis_y.py`](trellis_y.py) uses Z3 bit vectors of width 32. Multiplication
and addition of unsigned values wrap modulo `2^32`; right shifts of unsigned
values zero-fill. It tracks signedness and proves that signed arithmetic and
the unsigned-to-signed conversion stay in range.

These rules come from the [Metal Shading Language specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf),
sections "Scalar Data Types" and "Operators". Metal masks shift counts to the
low five bits for 32-bit values. The model implements that rule and additionally
proves that this helper only uses counts from 0 through 31.

Using unbounded mathematical integers for every intermediate would miss the
intentional wrap in `x`. Using signed right shifts would model a different
program. The [Z3 bit-vector guide](https://microsoft.github.io/z3guide/docs/theories/Bitvectors/)
explains the corresponding solver operations.

## 4. Connect the proof to the production source

The verifier reads the `HEADER` raw string directly from `codebook.ts`, extracts
`trellis_y`, and translates its complete function body. It prints the extracted
function's SHA-256 so the checked source can be identified. It does not execute
TypeScript, import MLX, or use the GPU.

The translator deliberately accepts only this helper's small integer language:
two local `uint` declarations, the supported arithmetic and bit operations,
and the final cast and subtraction. Unsupported syntax, extra statements,
ambiguous declarations, interpolation, or unsupported surrounding declarations
are refused. A future source change therefore either gets proved against the
same contract, produces a counterexample, or requires an explicit translator
review. This is a pilot for one helper, not a general Metal parser.

## 5. Ask the solver whether a counterexample exists

The input `s` is an unconstrained 32-bit symbol. For each claim, the verifier
asserts its negation and asks Z3 to solve it:

```text
Does any s exist for which implementation(s) != specification(s)?
```

`UNSAT` means no such input exists: the claim holds over all 4,294,967,296
possible inputs. This is symbolic reasoning, not sampled testing. `SAT` means
the solver found a counterexample, which the script prints. `UNKNOWN`, including
a timeout, is inconclusive and fails the command.

The current source generates six obligations: two shift bounds, representable
conversion to `int`, safe signed subtraction, equality with the byte-by-byte
specification, and the signed result range. Every obligation must be proved;
none is silently assumed to prove another.

## 6. Run the proof and challenge the verifier

Install [uv](https://docs.astral.sh/uv/getting-started/installation/), then run
from the repository root:

```sh
uv run --locked --script proofs/trellis_y.py --self-test
```

The script requires Python 3.11 or later. Its adjacent lockfile pins Z3
`4.16.0.0` and dependency hashes in an isolated environment. The pinned Apple
Silicon wheel requires macOS 15 or later; the proof can also run on Linux.
No native MLX setup or model download is needed.

Expect six `UNSAT` results and passing translator regression tests. The tests
in [`test_trellis_y.py`](test_trellis_y.py) deliberately change the mask,
multiplier, and offset, require counterexamples, and replay those inputs with
ordinary integer arithmetic. They also check that unsupported source is
refused. These tests help check the verifier; the universal guarantee comes
from the symbolic obligations.

To retain the solver queries and proof objects outside the repository:

```sh
uv run --locked --script proofs/trellis_y.py --emit /tmp/trellis-y-proof
```

Each `.smt2` file contains a negated obligation. Each `.z3proof` file contains
Z3's proof object for its `UNSAT` result. The script requests proof production
even without `--emit`. It does not independently validate those objects with
a separate proof checker.

## 7. Use the theorem when proving the next piece

A caller can use the exact result formula and the range `[-510, 510]` as
established facts. For example, a proof of `trellis_refined_y(trellis_y(s))`
can start from this finite integer range, then separately model the float32
conversion, reciprocal, and fused multiply-add operations. Those floating-point
claims are not established by this proof.

For a full kernel, add contracts for buffer sizes, index bounds, initialization,
aliasing, and synchronization. For a layer, show that its fixed calls meet each
kernel's preconditions and collectively establish the layer's postcondition.
For a graph, repeat that composition over its static dependencies, carrying
buffer ownership and state invariants as well as tensor shapes. Compatibility
is proved at development time; no runtime contract checks are needed for facts
already established by the proof. External inputs still need to satisfy the
graph's stated assumptions.

## What remains trusted

This is an SMT proof of the extracted helper under Metal's integer semantics.
It trusts the small source extractor/translator, the independently written
specification, Python/Z3 and their runtime, and the interpretation of Metal's
language rules. It assumes the helper is compiled with the standard Metal
types and no external macros changing its meaning. It does not verify how
callers assemble the header, compiler lowering, GPU hardware, floating-point
decoding, memory accesses in surrounding kernels, or complete model behavior.

An independent proof checker or a verified frontend could reduce that trusted
base later. Until then, describe the result as an SMT-verified integer helper,
and keep the scope explicit when composing further contracts.
