# /// script
# requires-python = ">=3.11"
# dependencies = ["z3-solver==4.16.0.0"]
# ///
"""Prove the production trellis_y Metal helper against its integer contract.

Run with `uv run --script proofs/trellis_y.py --help`. No MLX or GPU is loaded.
The deliberately small source translator is trusted code, not a verified compiler.
"""

from __future__ import annotations

import argparse
import ast
from dataclasses import dataclass
import hashlib
from pathlib import Path
import re
import sys

import z3


SOURCE = Path(__file__).resolve().parents[1] / "packages/inference/src/kernels/trellis/codebook.ts"
UINT_MAX = (1 << 32) - 1
INT_MAX = (1 << 31) - 1
z3.set_param(proof=True)


class UnsupportedSource(ValueError):
    """Source outside the reviewed subset must never receive a proof verdict."""


@dataclass(frozen=True)
class Value:
    bits: z3.BitVecRef
    unsigned: bool


@dataclass(frozen=True)
class Obligation:
    name: str
    claim: z3.BoolRef


@dataclass(frozen=True)
class Program:
    source: str
    state: z3.BitVecRef
    result: z3.BitVecRef
    obligations: tuple[Obligation, ...]


def extract(source: str) -> str:
    """Read the actual raw Metal literal without executing the TypeScript module."""
    headers = list(re.finditer(r"export\s+const\s+HEADER\s*=\s*String\.raw`([^`]*)`;", source))
    if len(headers) != 1 or "${" in headers[0].group(1):
        raise UnsupportedSource("expected one non-interpolated HEADER raw string")
    # The production file starts with named imports/comments, then HEADER. By
    # accepting only that prefix, a regex match inside a TS comment or another
    # string cannot be mistaken for the actual exported declaration. Broader
    # TypeScript syntax must get an explicit translator change, not be skipped.
    imports = r'import\s+\{\s*\w+(?:\s*,\s*\w+)*\s*\}\s+from\s+"[^"\\\r\n]*";'
    trivia = r"\s+|//[^\n]*\n|/\*[\s\S]*?\*/"
    if not re.fullmatch(f"(?:{imports}|{trivia})*", source[:headers[0].start()]):
        raise UnsupportedSource("expected only named imports and complete comments before HEADER")
    for imported in re.finditer(imports, source[:headers[0].start()]):
        if re.search(r"\bString\b", imported.group().split("}", 1)[0]):
            raise UnsupportedSource("String.raw must not be shadowed by an import")
    # C comments separate tokens; deleting them would join unrelated tokens.
    raw_header = headers[0].group(1)
    header = re.sub(r"//[^\n]*|/\*.*?\*/", lambda match: " " * len(match.group()), raw_header, flags=re.S)
    functions = list(re.finditer(
        r"static\s+inline\s+int\s+trellis_y\s*\(\s*uint\s+s\s*\)\s*\{[^{}]*\}", header
    ))
    definitions = re.findall(r"\btrellis_y\s*\([^();{}]*\)\s*\{", header)
    if len(functions) != 1 or len(definitions) != 1:
        raise UnsupportedSource("expected one scalar trellis_y(uint s) without nested blocks")
    function = functions[0]
    if "#" in header[:function.end()]:
        raise UnsupportedSource("preprocessor directives before or inside trellis_y are unsupported")
    if "\\" in raw_header[:function.end()]:
        raise UnsupportedSource("escapes and line continuations before or inside trellis_y are unsupported")
    prefix = r"\s*(?:static\s+inline\s+float\s+trellis_bf16\s*\(\s*float\s+v\s*\)\s*\{[^{}]*\}\s*)?"
    if not re.fullmatch(prefix, header[:function.start()]):
        raise UnsupportedSource("only the standalone trellis_bf16 helper may precede trellis_y")
    return function.group()


class Expressions:
    """Translate only the integer expression subset used by this one helper.

    +, *, &, >> and parentheses have the same precedence in C and Python.
    Unsuffixed literals are signed int; u-suffixed literals and uint variables
    are unsigned. Usual same-width arithmetic conversions apply to +, * and &.
    Right shifts preserve the left operand's type; only unsigned shifts are
    supported here. Signed overflow and the restricted shift domain become
    obligations. Metal masks shift counts; this pilot also proves they are <32.
    """

    def __init__(self, state: z3.BitVecRef):
        self.variables = {"s": Value(state, True)}
        self.obligations: list[Obligation] = []

    def require(self, label: str, condition: z3.BoolRef) -> None:
        self.obligations.append(Obligation(f"operation precondition {len(self.obligations) + 1}: {label}", condition))

    def parse(self, expression: str) -> Value:
        # Restrict the lexical language before using Python's expression parser.
        token = r"(?:0[xX][0-9a-fA-F]+|[0-9]+)[uU]?|[a-zA-Z_][a-zA-Z_0-9]*|>>|[()+*&]"
        tokens = re.findall(token, expression)
        if "".join(tokens) != re.sub(r"\s+", "", expression):
            raise UnsupportedSource(f"unsupported expression: {expression.strip()}")
        if any(re.fullmatch(r"[a-zA-Z_][a-zA-Z_0-9]*", item) and item not in self.variables for item in tokens):
            raise UnsupportedSource("only previously declared local variables are allowed")
        expression = re.sub(r"\b(0[xX][0-9a-fA-F]+|[0-9]+)[uU]\b", r"U32(\1)", expression)
        try:
            return self.visit(ast.parse(expression.strip(), mode="eval").body)
        except (SyntaxError, KeyError) as error:
            raise UnsupportedSource(f"unsupported expression: {expression.strip()}") from error

    def visit(self, node: ast.expr) -> Value:
        if isinstance(node, ast.Name):
            return self.variables[node.id]
        if isinstance(node, ast.Constant) and type(node.value) is int and 0 <= node.value <= INT_MAX:
            return Value(z3.BitVecVal(node.value, 32), False)
        if (isinstance(node, ast.Call) and isinstance(node.func, ast.Name) and node.func.id == "U32"
                and len(node.args) == 1 and not node.keywords and isinstance(node.args[0], ast.Constant)
                and type(node.args[0].value) is int and 0 <= node.args[0].value <= UINT_MAX):
            return Value(z3.BitVecVal(node.args[0].value, 32), True)
        if isinstance(node, ast.BinOp):
            left, right = self.visit(node.left), self.visit(node.right)
            a, b = left.bits, right.bits
            unsigned = left.unsigned or right.unsigned
            if isinstance(node.op, ast.RShift) and left.unsigned:
                self.require("shift count is in [0, 31]", z3.ULT(b, 32))
                return Value(z3.LShR(a, b & 31), True)
            if isinstance(node.op, ast.BitAnd):
                return Value(a & b, unsigned)
            if isinstance(node.op, (ast.Add, ast.Mult)):
                result = a + b if isinstance(node.op, ast.Add) else a * b
                if not unsigned:
                    wide_a, wide_b = z3.SignExt(32, a), z3.SignExt(32, b)
                    wide = wide_a + wide_b if isinstance(node.op, ast.Add) else wide_a * wide_b
                    self.require("signed arithmetic does not overflow", z3.SignExt(32, result) == wide)
                return Value(result, unsigned)
        raise UnsupportedSource(f"unsupported expression node: {ast.dump(node)}")


def translate(function: str) -> Program:
    """Require the entire function to match; no ignored statements or effects."""
    match = re.fullmatch(
        r"static\s+inline\s+int\s+trellis_y\s*\(\s*uint\s+s\s*\)\s*\{\s*"
        r"const\s+uint\s+x\s*=\s*([^;]+);\s*"
        r"const\s+uint\s+p\s*=\s*([^;]+);\s*"
        r"return\s+\(int\)\s*\(([^;]+)\)\s*-\s*(0|[1-9][0-9]*)\s*;\s*\}", function
    )
    if not match:
        raise UnsupportedSource("expected two const uint declarations and the signed return expression")
    state = z3.BitVec("s", 32)
    expressions = Expressions(state)
    for name, expression in zip(("x", "p"), match.group(1, 2)):
        value = expressions.parse(expression)
        # Conversion to uint preserves the 32 bits, including from signed int.
        expressions.variables[name] = Value(value.bits, True)
    total = expressions.parse(match.group(3))
    offset = int(match.group(4))
    if not total.unsigned or not 0 <= offset <= INT_MAX:
        raise UnsupportedSource("expected an unsigned sum cast to int and an int subtraction")
    expressions.require("uint-to-int conversion is representable", z3.ULE(total.bits, INT_MAX))
    result = total.bits - offset
    expressions.require("signed subtraction does not overflow",
                        z3.SignExt(32, result) == z3.SignExt(32, total.bits) - offset)
    return Program(function, state, result, tuple(expressions.obligations))


def contract(program: Program) -> tuple[Obligation, ...]:
    """Independent specification: extract four bytes individually, then sum.

    Constants belong to the contract and are not taken from the implementation.
    Changing a production constant therefore cannot silently change the claim.
    Zero-extension makes the specification's sum exact (maximum 4 * 255).
    """
    mixed = program.state * z3.BitVecVal(34038481, 32) + z3.BitVecVal(76625530, 32)
    byte_sum = sum(z3.ZeroExt(24, z3.Extract(low + 7, low, mixed)) for low in (0, 8, 16, 24))
    reference = byte_sum - 510
    return (
        *program.obligations,
        Obligation("optimized result equals the four-byte specification", program.result == reference),
        Obligation("signed result is in [-510, 510]", z3.And(program.result >= -510, program.result <= 510)),
    )


def verify(program: Program, timeout_ms: int, emit: Path | None = None) -> bool:
    if emit:
        emit.mkdir(parents=True, exist_ok=True)
    passed = True
    for index, obligation in enumerate(contract(program), start=1):
        solver = z3.Solver()
        solver.set(timeout=timeout_ms)
        # A free 32-bit s ranges over ALL 2^32 values. UNSAT of the negation
        # proves the claim universally. There are no input assumptions to hide
        # a counterexample or make the contract vacuously true.
        solver.add(z3.Not(obligation.claim))
        if emit:
            (emit / f"{index:02}.smt2").write_text(solver.to_smt2())
        result = solver.check()
        print(f"{str(result).upper():7} {obligation.name}")
        if result == z3.unsat:
            proof = solver.proof()  # Require proof production, not just a verdict.
            if emit:
                (emit / f"{index:02}.z3proof").write_text(proof.sexpr())
        else:
            passed = False
            if result == z3.sat:
                model = solver.model()
                state = model.eval(program.state, model_completion=True).as_long()
                value = model.eval(program.result, model_completion=True).as_signed_long()
                print(f"        counterexample: s=0x{state:08x}, result={value}")
            else:
                print(f"        inconclusive: {solver.reason_unknown()}")
    return passed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--source", type=Path, default=SOURCE, help="codebook.ts to inspect (default: this checkout)")
    parser.add_argument("--timeout-ms", type=int, default=30000, help="per-obligation solver timeout; unknown fails")
    parser.add_argument("--emit", type=Path, help="write SMT queries and Z3 proof objects to an external directory")
    parser.add_argument("--self-test", action="store_true", help="also run translator and counterexample regression tests")
    args = parser.parse_args()
    if args.timeout_ms <= 0:
        parser.error("--timeout-ms must be positive")
    if args.emit and args.emit.resolve().is_relative_to(Path(__file__).resolve().parents[1]):
        parser.error("--emit must point outside the checkout")
    if z3.get_version_string() != "4.16.0":
        parser.error("use the pinned environment: uv run --script proofs/trellis_y.py")
    try:
        program = translate(extract(args.source.read_text()))
    except (OSError, UnsupportedSource) as error:
        print(f"REFUSED {error}", file=sys.stderr)
        return 1
    print(f"{z3.get_full_version()} | source: {args.source}")
    print(f"trellis_y SHA-256: {hashlib.sha256(program.source.encode()).hexdigest()}")
    passed = verify(program, args.timeout_ms, args.emit)
    if args.self_test:
        import unittest
        suite = unittest.defaultTestLoader.discover(str(Path(__file__).parent), pattern="test_*.py")
        passed = unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful() and passed
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
