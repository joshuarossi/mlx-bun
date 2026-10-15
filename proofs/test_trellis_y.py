"""CPU-only checks that the proof fails for wrong arithmetic or unsupported source."""

import unittest

import z3

import trellis_y as proof


SOURCE = proof.SOURCE.read_text()
FUNCTION = proof.extract(SOURCE)


def solve(claim):
    solver = z3.Solver()
    solver.set(timeout=30000)
    solver.add(z3.Not(claim))
    return solver, solver.check()


def reference(state):
    mixed = (state * 34038481 + 76625530) % (1 << 32)
    return sum((mixed >> shift) & 255 for shift in (0, 8, 16, 24)) - 510


class TrellisProofTests(unittest.TestCase):
    def test_mutations_have_replayable_counterexamples(self):
        cases = (
            ("mask", "0x00FF00FFu", "0x000F000Fu", 34038481, 0x000F000F, 510),
            ("multiplier", "34038481u", "34038483u", 34038483, 0x00FF00FF, 510),
            ("offset", "- 510;", "- 511;", 34038481, 0x00FF00FF, 511),
        )
        for name, before, after, multiplier, mask, offset in cases:
            with self.subTest(name=name):
                program = proof.translate(FUNCTION.replace(before, after))
                solver, verdict = solve(proof.contract(program)[-2].claim)
                self.assertEqual(verdict, z3.sat)
                model = solver.model()
                state = model.eval(program.state, model_completion=True).as_long()
                mixed = (state * multiplier + 76625530) & 0xFFFFFFFF
                paired = ((mixed & mask) + ((mixed >> 8) & mask)) & 0xFFFFFFFF
                actual = ((paired & 0xFFFF) + (paired >> 16)) - offset
                self.assertEqual(model.eval(program.result).as_signed_long(), actual)
                self.assertNotEqual(actual, reference(state))

    def test_unsupported_function_bodies_are_refused(self):
        bodies = [
            FUNCTION.replace("return", "x = 0u; return"),
            FUNCTION.replace("return", "const uint extra = 0u; return"),
            FUNCTION.replace("s * 34038481u", "unknown(s)"),
            FUNCTION.replace("s * 34038481u", "U32(1)"),
            FUNCTION.replace("- 510;", "- 0510;"),
        ]
        for operator in ("-", "/", "|", "<<", "^", "%"):
            bodies.append(FUNCTION.replace("s * 34038481u", f"s {operator} 1u"))
        bodies.append(FUNCTION.replace("s * 34038481u", "1 >> 1"))
        for body in bodies:
            with self.subTest(body=body):
                with self.assertRaises(proof.UnsupportedSource):
                    proof.translate(body)

    def test_unsupported_source_envelopes_are_refused(self):
        sources = (
            'import { String } from "override";\n' + SOURCE,
            SOURCE + "\nexport const HEADER = String.raw`duplicate`;",
            SOURCE.replace(FUNCTION, FUNCTION + "\n" + FUNCTION),
            SOURCE.replace(FUNCTION, "${injected}\n" + FUNCTION),
            SOURCE.replace(FUNCTION, "#define uint int\n" + FUNCTION),
            SOURCE.replace(FUNCTION, "namespace other {\n" + FUNCTION + "\n}"),
            SOURCE.replace(FUNCTION, "typedef unsigned short uint;\n" + FUNCTION),
            SOURCE.replace("`;", "` + String.raw``;", 1),
        )
        for source in sources:
            with self.subTest(source=source):
                with self.assertRaises(proof.UnsupportedSource):
                    proof.translate(proof.extract(source))

    def test_signed_overflow_precedes_uint_assignment(self):
        program = proof.translate(FUNCTION.replace("s * 34038481u + 76625530u", "2147483647 + 1"))
        obligations = [item for item in program.obligations if "signed arithmetic" in item.name]
        self.assertTrue(obligations)
        self.assertTrue(any(solve(item.claim)[1] == z3.sat for item in obligations))

    def test_comments_cannot_hide_declarations_or_join_tokens(self):
        sources = (
            "/* export const HEADER = String.raw`" + FUNCTION + "`; */\n"
            "export const HEADER = getDifferentCode();",
            SOURCE.replace("trellis_y(uint s)", "trellis_/* gap */y(uint s)", 1),
            SOURCE.replace("34038481u", "3403/* gap */8481u", 1),
            SOURCE.replace("s * 34038481u", "s /* comment " + "\\" + "\n */ * 34038481u", 1),
        )
        for source in sources:
            with self.subTest(source=source):
                with self.assertRaises(proof.UnsupportedSource):
                    proof.translate(proof.extract(source))

    def test_comments_between_complete_tokens_preserve_the_proof(self):
        source = SOURCE.replace("s * 34038481u", "s /* ordinary comment */ * 34038481u", 1)
        program = proof.translate(proof.extract(source))
        for obligation in proof.contract(program):
            with self.subTest(obligation=obligation.name):
                self.assertEqual(solve(obligation.claim)[1], z3.unsat)

    def test_reviewed_shift_domain_rejects_32_and_accepts_31(self):
        # MSL masks shift counts; the verifier deliberately supports only 0..31.
        for shift, expected in ((32, z3.sat), (31, z3.unsat)):
            with self.subTest(shift=shift):
                program = proof.translate(FUNCTION.replace("x >> 8", f"x >> {shift}"))
                shifts = [item for item in program.obligations if "shift count" in item.name]
                self.assertTrue(shifts)
                verdicts = [solve(item.claim)[1] for item in shifts]
                if expected == z3.sat:
                    self.assertIn(z3.sat, verdicts)
                else:
                    self.assertTrue(all(verdict == z3.unsat for verdict in verdicts))


if __name__ == "__main__":
    unittest.main()
