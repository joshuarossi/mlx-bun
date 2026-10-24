import host.sim.lin.Enum
namespace Host.Ts.Sim.Lin.G10
open Host.Ts Host.Ts.Sim.Lin

/-! # G10: the comparisons `goodLin` does not decide, and how each is checked

The oracles here are built from the TypeScript the way the interpreter asks them (a test with a
symbolic operand becomes an answer; one between two literals is computed, `host.ts.Core`
`numTest`/`numBin`); the route's oracles come from the stage templates, with these shapes.

* **The down plan's costs** (`plan`, kernels/trellis/down-mma-wide.ts:40-53): `best` starts at
  `cost: Infinity`, and each pass compares `Math.ceil(M / (8·MT)) * cost <= best.cost` with the
  costs `0.6`, `1`, `1.44`. `0.6` and `1.44` are not integers, so `goodLin` decides none of the
  row-major answers (`plan_lin_undecided`). They are checked by `goodEnum` over the integer
  values of `M`: the 17 row-major bands in `9…223` (one answer pattern each, `planBands`; they are
  `PrefillSched.rowBands` 5…21) are `plan_band_*`, at most 40 points each, and the whole range
  (215 points) is `plan_all`. The interleaved layout's one pass costs `1`: `goodLin` decides it
  over `9…223` (`planI_lin`).
* **`±Infinity`** is the literal `F64.inf neg` in the oracle (`.lit (.inf false)` for `Infinity`,
  the global constant of host/ts/Init.lean:278; `-Infinity` is computed on the literal,
  `.lit (.inf true)`). `goodLin` decides tests against it and `min`/`max` with it
  (`LinGood.AV.inf`): `rows <= Infinity` of the model's `prompt` ranges
  (models/qwen/qwen38-27b-trellis-m1max.ts:1180, `{from: 2049, to: Infinity}`) at
  `2049 ≤ rows ≤ 262144` (`find_inf`; on the route every tail and chunk has at most 2048 rows and
  stops at an earlier range, `find_ane`), and `Math.max(-Infinity, M)` (`max_neg_inf`).
* **`int32`/`uint32` wraps**: `goodLin` keeps a form exact when its range over the box lies in one
  wrapping window, else it knows only the window (`LinGood.absWrap`). Every quantity of the class
  table is below `2^19`, so no conversion of a route number crosses `2^31`; a box that does (a token
  in `[0, 2^32)`) leaves the sign test undecided (`int32_wide`) and the check fails rather than
  answering wrongly; the vocabulary's box `[0, 248320)` decides it (`int32_vocab`). -/

/-- The parser's form of a non-negative integer literal. -/
def nl (k : Nat) : SymE := .lit (if k = 0 then .zero false else .fin false k 0)

/-- The literals `0.6`, `1`, `1.44` as the lexer reads them. -/
def c06 : F64 := F64.ofDecimal 6 (-1)
def c1 : F64 := .fin false 1 0
def c144 : F64 := F64.ofDecimal 144 (-2)

theorem c06_lit : F64.ofLit "0.6".toList = some c06 := by decide +kernel
theorem c1_lit : F64.ofLit "1".toList = some c1 := by decide +kernel
theorem c144_lit : F64.ofLit "1.44".toList = some c144 := by decide +kernel

/-- `Math.ceil(M / (8·mt)) * cost`, `M` the table entry `var 0`. -/
def total (mt : Nat) (cost : F64) : SymE := .bin .mul (.un .ceil (.bin .div (.var 0) (nl (8 * mt)))) (.lit cost)

/-- `plan("rowMajor", M)`: the three passes' `total <= best.cost`, `r2` (two blocks per pass at
most cost the one-block pass) and `r3` (three blocks at most cost the best so far). -/
def planD (r2 r3 : Bool) : List Ans :=
  [⟨.le, total 1 c06, .lit (.inf false), true⟩, ⟨.le, total 2 c1, total 1 c06, r2⟩,
   ⟨.le, total 3 c144, if r2 then total 2 c1 else total 1 c06, r3⟩]

/-- `plan("interleaved", M)`: one pass of cost `1`. -/
def planI : List Ans := [⟨.le, total 1 c1, .lit (.inf false), true⟩]

/-- `M` itself as the one parameter. -/
def mV : List (Nat × Aff) := [(0, ⟨0, [1]⟩)]

def box (lo hi : Int) : List Prm := [⟨lo, hi, []⟩]

/-- The row-major bands of `9…223` and their answers. -/
def planBands : List (Int × Int × Bool × Bool) :=
  [(9, 16, true, false), (17, 24, false, true), (25, 32, true, false), (33, 48, true, true), (49, 64, true, false),
   (65, 72, true, true), (73, 80, true, false), (81, 96, true, true), (97, 112, true, false), (113, 120, true, true),
   (121, 128, true, false), (129, 144, true, true), (145, 160, true, false), (161, 168, true, true),
   (169, 176, true, false), (177, 216, true, true), (217, 223, true, false)]

theorem plan_lin_undecided : goodLin (box 9 16) mV (planD true false) = false := by decide +kernel

theorem plan_band_9 : goodEnum (box 9 16) mV (planD true false) = true := by decide +kernel
theorem plan_band_17 : goodEnum (box 17 24) mV (planD false true) = true := by decide +kernel
theorem plan_band_177 : goodEnum (box 177 216) mV (planD true true) = true := by decide +kernel

/-- Every band: `goodEnum` over its points. -/
theorem plan_all : planBands.all (fun (lo, hi, r2, r3) => goodEnum (box lo hi) mV (planD r2 r3)) = true := by
  decide +kernel

/-- A band's oracle is correct at every `M` of the band. -/
theorem plan_good {lo hi : Int} {r2 r3 : Bool} (hb : (lo, hi, r2, r3) ∈ planBands) {M : Nat} (h1 : lo ≤ M) (h2 : M ≤ hi)
    {ρ : Nat → F64} (hρ : ρ 0 = F64.ofNat M) : Good ρ (planD r2 r3) :=
  goodEnum_sound (List.all_eq_true.mp plan_all _ hb) (x := vx [M]) (by simp [box, InBox]; omega)
    (by simp only [mV, VarsOk, and_true]; rw [hρ]; exact ofNat_ofInt (by simp [Aff.eval, dot]))

theorem planI_lin : goodLin (box 9 223) mV planI = true := by decide +kernel

/-- `this.prompt`'s ranges (models/qwen/qwen38-27b-trellis-m1max.ts:1180, `aneRanges` :1073). -/
def promptRanges : List (Nat × F64) :=
  [(1, .fin false 1 0), (2, .fin false 3 0), (4, .fin false 4 0), (5, .fin false 8 0), (9, .fin false 223 0),
   (224, .fin false 256 0), (257, .fin false 320 0), (321, .fin false 384 0), (385, .fin false 448 0),
   (449, .fin false 512 0), (513, .fin false 576 0), (577, .fin false 640 0), (641, .fin false 704 0),
   (705, .fin false 768 0), (769, .fin false 896 0), (897, .fin false 1024 0), (1025, .fin false 1280 0),
   (1281, .fin false 1536 0), (1537, .fin false 1792 0), (1793, .fin false 2048 0), (2049, .inf false)]

/-- `ranges.find(range => positions >= range.from && positions <= range.to)` (generation/phase-dispatch.ts:85)
returning range `k`, `positions` the table entry `var 0`. -/
def findD (rs : List (Nat × F64)) (k : Nat) : List Ans :=
  ((rs.take k).map fun (f, t) => [⟨.le, nl f, .var 0, true⟩, ⟨.le, .var 0, .lit t, false⟩]).flatten ++
  match rs[k]? with
  | some (f, t) => [⟨.le, nl f, .var 0, true⟩, ⟨.le, .var 0, .lit t, true⟩]
  | none => []

theorem find_inf : goodLin (box 2049 262144) mV (findD promptRanges 20) = true := by decide +kernel
theorem find_ane : goodLin (box 224 256) mV (findD promptRanges 5) = true := by decide +kernel

theorem max_neg_inf : goodLin (box 9 223) mV [⟨.lt, .bin .max (.lit (.inf true)) (.var 0), nl 5, false⟩] = true := by
  decide +kernel

theorem int32_wide : goodLin (box 0 4294967295) mV [⟨.lt, .un .int32 (.var 0), nl 0, false⟩] = false := by decide +kernel
theorem int32_vocab : goodLin (box 0 248319) mV [⟨.lt, .un .int32 (.var 0), nl 0, false⟩] = true := by decide +kernel

end Host.Ts.Sim.Lin.G10
