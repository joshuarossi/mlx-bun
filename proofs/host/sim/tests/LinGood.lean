import host.sim.LinGood
import host.sim.CasesEos
import host.sim.template.ordinary.States
import host.sim.template.clear.States
import host.sim.template.growth.States
import host.sim.template.fill.States
import host.sim.template.final.States
import host.sim.template.finalc0.States
import host.sim.template.finalc1.States
set_option linter.unusedVariables false
namespace Host.Ts.Sim.Lin.Tests
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Load.Run.Tpl

/-! # LinGood validation

1. The decode loop's case oracles (`Host.Ts.Sim.ordD`, …, `finalDG`, `eosD`, `finalEDG`) are
   re-proved Good with the hand proofs' statements (`good_*'`), and the real template oracles
   (`ORDINARY.O`, … — 501 to 517 answers, 8 for the finals) are checked directly.
2. The same with a symbolic prompt length: offset `L + i + 1`, capacity `256·⌈(L+i+1)/256⌉`
   (`good_ordL`, `good_clearFillL`).
3. Synthetic prefill oracles built from the TypeScript: chunk-size selection
   (`sdpaFallbackBytes` halving), `nextPrefillStep` with `Number.isSafeInteger`, and the KV
   growth tests of `updateAndFetch`, over `L`, `o = 2048·k`, rows `n` (`setup_*`, `drain_*`,
   `tail_good`). -/

/-! ## The decode loop -/

/-- `ORDINARY`: `i = 256·a + r`, `r ∈ [1, 255]`; `c = p + 2 + d`; `T = i + 3 + t`; `tok ≠ EOS`. -/
def ordB : List Prm :=
  [⟨0, 4194304, []⟩, ⟨1, 255, []⟩, ⟨1, 1073741823, []⟩, ⟨0, 1073741824, []⟩, ⟨0, 1073741824, []⟩,
   ⟨0, 4294967295, [248044]⟩]

def ordV : List (Nat × Aff) :=
  [(0, 256 • P 0 + P 1 + P 4 + 3), (9, P 2), (10, 256 • P 0 + P 1), (11, 256 • P 0 + P 1),
   (12, 256 • P 0 + P 1), (13, 256 • P 0 + P 1 - 1), (14, P 5), (16, P 2 + P 3 + 2)]

theorem ord_check : goodLin ordB ordV ordD = true := by decide +kernel

theorem good_ord' {rest : Nat → F64} {T p i c tok ptok next : Nat} (hi0 : i ≠ 0) (htok : tok ≠ 248044)
    (hrem : i % 256 ≠ 0) (hT : i + 2 < T) (hpc : p + 1 < c) (hp0 : 0 < p) (hi : i < 2 ^ 30) (hTb : T < 2 ^ 30)
    (hp : p < 2 ^ 30) (hc : c < 2 ^ 30) (ht : tok < 2 ^ 32) : Good (loopVal rest T p i c tok ptok next) ordD :=
  goodLin_sound ord_check (x := vx [(i : Int) / 256, (i : Int) % 256, p, (c : Int) - p - 2, (T : Int) - i - 3, tok])
    (by lin_mem [ordB]) (by lin_mem [ordV])

/-- `CLEAR`: `i = 256·a`, `a ≥ 1`. -/
def clearB : List Prm :=
  [⟨1, 4194304, []⟩, ⟨1, 1073741823, []⟩, ⟨0, 1073741824, []⟩, ⟨0, 1073741824, []⟩, ⟨0, 4294967295, [248044]⟩]

def clearV : List (Nat × Aff) :=
  [(0, 256 • P 0 + P 3 + 3), (9, P 1), (10, 256 • P 0), (11, 256 • P 0), (12, 256 • P 0), (13, 256 • P 0 - 1),
   (14, P 4), (16, P 1 + P 2 + 2)]

theorem clear_check : goodLin clearB clearV clearD = true := by decide +kernel

theorem good_clear' {rest : Nat → F64} {T p i c tok ptok next : Nat} (hi0 : i ≠ 0) (htok : tok ≠ 248044)
    (hrem : i % 256 = 0) (hT : i + 2 < T) (hpc : p + 1 < c) (hp0 : 0 < p) (hi : i < 2 ^ 30) (hTb : T < 2 ^ 30)
    (hp : p < 2 ^ 30) (hc : c < 2 ^ 30) (ht : tok < 2 ^ 32) : Good (loopVal rest T p i c tok ptok next) clearD :=
  goodLin_sound clear_check (x := vx [(i : Int) / 256, p, (c : Int) - p - 2, (T : Int) - i - 3, tok])
    (by lin_mem [clearB]) (by lin_mem [clearV])

/-- `GROWTH`: `p = 256·b`, `c = p - e` with `e ∈ [0, 254]`. -/
def growB : List Prm :=
  [⟨0, 4194304, []⟩, ⟨1, 255, []⟩, ⟨1, 4194304, []⟩, ⟨0, 254, []⟩, ⟨0, 1073741824, []⟩, ⟨0, 4294967295, [248044]⟩]

def growV : List (Nat × Aff) :=
  [(0, 256 • P 0 + P 1 + P 4 + 3), (9, 256 • P 2), (10, 256 • P 0 + P 1), (11, 256 • P 0 + P 1),
   (12, 256 • P 0 + P 1), (13, 256 • P 0 + P 1 - 1), (14, P 5), (16, 256 • P 2 - P 3)]

theorem grow_check : goodLin growB growV growD = true := by decide +kernel

theorem good_grow' {rest : Nat → F64} {T p i c tok ptok next : Nat} (hi0 : i ≠ 0) (htok : tok ≠ 248044)
    (hrem : i % 256 ≠ 0) (hT : i + 2 < T) (hcp : c ≤ p) (hpc : p + 1 < c + 256) (hpr : p % 256 = 0) (hp0 : 0 < p)
    (hi : i < 2 ^ 30) (hTb : T < 2 ^ 30) (hp : p < 2 ^ 30) (hc : c < 2 ^ 30) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T p i c tok ptok next) growD :=
  goodLin_sound grow_check
    (x := vx [(i : Int) / 256, (i : Int) % 256, (p : Int) / 256, (p : Int) - c, (T : Int) - i - 3, tok])
    (by lin_mem [growB]) (by lin_mem [growV])

/-- `FILL`: `c = p + 1`. -/
def fillB : List Prm :=
  [⟨0, 4194304, []⟩, ⟨1, 255, []⟩, ⟨1, 1073741822, []⟩, ⟨0, 1073741824, []⟩, ⟨0, 4294967295, [248044]⟩]

def fillV : List (Nat × Aff) :=
  [(0, 256 • P 0 + P 1 + P 3 + 3), (9, P 2), (10, 256 • P 0 + P 1), (11, 256 • P 0 + P 1),
   (12, 256 • P 0 + P 1), (13, 256 • P 0 + P 1 - 1), (14, P 4), (16, P 2 + 1)]

theorem fill_check : goodLin fillB fillV fillD = true := by decide +kernel

theorem good_fill' {rest : Nat → F64} {T p i c tok ptok next : Nat} (hi0 : i ≠ 0) (htok : tok ≠ 248044)
    (hrem : i % 256 ≠ 0) (hT : i + 2 < T) (hpc : p + 1 = c) (hp0 : 0 < p) (hi : i < 2 ^ 30) (hTb : T < 2 ^ 30)
    (hp : p < 2 ^ 30) (hc : c < 2 ^ 30) (ht : tok < 2 ^ 32) : Good (loopVal rest T p i c tok ptok next) fillD :=
  goodLin_sound fill_check (x := vx [(i : Int) / 256, (i : Int) % 256, p, (T : Int) - i - 3, tok])
    (by lin_mem [fillB]) (by lin_mem [fillV])

/-! ### The final iteration: one class per cache-clear branch; `T = i + 2 - t` -/

def tokP : Prm := ⟨0, 4294967295, [248044]⟩

/-- Neither clear test holds: `i = 256·a + r`, `r ∈ [1, 254]`. -/
def finB₀ : List Prm := [⟨0, 4194304, []⟩, ⟨1, 254, []⟩, ⟨0, 2147483648, []⟩, tokP, tokP]
def finV₀ : List (Nat × Aff) := [(0, 256 • P 0 + P 1 + 2 - P 2), (10, 256 • P 0 + P 1), (14, P 3), (17, P 4)]
/-- The first clear test holds: `i = 256·a`. -/
def finB₁ : List Prm := [⟨1, 4194304, []⟩, ⟨0, 2147483648, []⟩, tokP, tokP]
def finV₁ : List (Nat × Aff) := [(0, 256 • P 0 + 2 - P 1), (10, 256 • P 0), (14, P 2), (17, P 3)]
/-- The second clear test holds: `i = 256·a + 255`. -/
def finB₂ : List Prm := [⟨0, 4194303, []⟩, ⟨0, 2147483648, []⟩, tokP, tokP]
def finV₂ : List (Nat × Aff) := [(0, 256 • P 0 + 257 - P 1), (10, 256 • P 0 + 255), (14, P 2), (17, P 3)]

theorem fin_check₀ : goodLin finB₀ finV₀ (finalDG false false) = true := by decide +kernel
theorem fin_check₁ : goodLin finB₁ finV₁ (finalDG true false) = true := by decide +kernel
theorem fin_check₂ : goodLin finB₂ finV₂ (finalDG false true) = true := by decide +kernel

theorem good_finalG' {rest : Nat → F64} {T p i c tok ptok next : Nat} {r3 r7 : Bool} (hi0 : i ≠ 0)
    (htok : tok ≠ 248044) (hrem : decide (i % 256 = 0) = r3) (hrem1 : decide ((i + 1) % 256 = 0) = r7)
    (hT : T ≤ i + 2) (hnext : next ≠ 248044) (hi : i < 2 ^ 30) (hTb : T < 2 ^ 30)
    (ht : tok < 2 ^ 32) (hn : next < 2 ^ 32) : Good (loopVal rest T p i c tok ptok next) (finalDG r3 r7) := by
  cases r3 <;> cases r7 <;> simp only [decide_eq_false_iff_not, decide_eq_true_eq] at hrem hrem1
  · exact goodLin_sound fin_check₀ (x := vx [(i : Int) / 256, (i : Int) % 256, (i : Int) + 2 - T, tok, next])
      (by lin_mem [finB₀, tokP]) (by lin_mem [finV₀])
  · exact goodLin_sound fin_check₂ (x := vx [(i : Int) / 256, (i : Int) + 2 - T, tok, next])
      (by lin_mem [finB₂, tokP]) (by lin_mem [finV₂])
  · exact goodLin_sound fin_check₁ (x := vx [(i : Int) / 256, (i : Int) + 2 - T, tok, next])
      (by lin_mem [finB₁, tokP]) (by lin_mem [finV₁])
  · omega

/-! ### EOS -/

def eosB : List Prm := [⟨1, 1073741823, []⟩]
def eosV : List (Nat × Aff) := [(10, P 0), (14, 248044)]

theorem eos_check : goodLin eosB eosV eosD = true := by decide +kernel

theorem good_eos' {rest : Nat → F64} {T p i c tok ptok next : Nat} (hi0 : i ≠ 0) (htok : tok = 248044)
    (hi : i < 2 ^ 30) : Good (loopVal rest T p i c tok ptok next) eosD :=
  goodLin_sound eos_check (x := vx [i]) (by lin_mem [eosB]) (by lin_mem [eosV])

def finEB₀ : List Prm := [⟨0, 4194304, []⟩, ⟨1, 255, []⟩, ⟨0, 2147483648, []⟩, tokP]
def finEV₀ : List (Nat × Aff) := [(0, 256 • P 0 + P 1 + 2 - P 2), (10, 256 • P 0 + P 1), (14, P 3), (17, 248044)]
def finEB₁ : List Prm := [⟨1, 4194304, []⟩, ⟨0, 2147483648, []⟩, tokP]
def finEV₁ : List (Nat × Aff) := [(0, 256 • P 0 + 2 - P 1), (10, 256 • P 0), (14, P 2), (17, 248044)]

theorem finE_check₀ : goodLin finEB₀ finEV₀ (finalEDG false) = true := by decide +kernel
theorem finE_check₁ : goodLin finEB₁ finEV₁ (finalEDG true) = true := by decide +kernel

theorem good_finalEG' {rest : Nat → F64} {T p i c tok ptok next : Nat} {r3 : Bool} (hi0 : i ≠ 0)
    (htok : tok ≠ 248044) (hrem : decide (i % 256 = 0) = r3) (hT : T ≤ i + 2) (hnext : next = 248044)
    (hi : i < 2 ^ 30) (hTb : T < 2 ^ 30) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T p i c tok ptok next) (finalEDG r3) := by
  cases r3 <;> simp only [decide_eq_false_iff_not, decide_eq_true_eq] at hrem
  · exact goodLin_sound finE_check₀ (x := vx [(i : Int) / 256, (i : Int) % 256, (i : Int) + 2 - T, tok])
      (by lin_mem [finEB₀, tokP]) (by lin_mem [finEV₀])
  · exact goodLin_sound finE_check₁ (x := vx [(i : Int) / 256, (i : Int) + 2 - T, tok])
      (by lin_mem [finEB₁, tokP]) (by lin_mem [finEV₁])

/-! ### The real template oracles, every answer (no distinct-answer reduction) -/

theorem ORDINARY.lin_check : goodLin ordB ordV ORDINARY.O = true := by decide +kernel
theorem CLEAR.lin_check : goodLin clearB clearV CLEAR.O = true := by decide +kernel
theorem GROWTH.lin_check : goodLin growB growV GROWTH.O = true := by decide +kernel
theorem FILL.lin_check : goodLin fillB fillV FILL.O = true := by decide +kernel
theorem FINAL.lin_check : goodLin finB₀ finV₀ FINAL.O = true := by decide +kernel
theorem FINALC0.lin_check : goodLin finB₁ finV₁ FINALC0.O = true := by decide +kernel
theorem FINALC1.lin_check : goodLin finB₂ finV₂ FINALC1.O = true := by decide +kernel

/-- The real `ORDINARY` oracle under `good_ord`'s hypotheses, without `ordD`. -/
theorem ORDINARY.good_lin {rest : Nat → F64} {T p i c tok ptok next : Nat} (htok : tok ≠ 248044)
    (hrem : i % 256 ≠ 0) (hT : i + 2 < T) (hpc : p + 1 < c) (hp0 : 0 < p) (hi : i < 2 ^ 30) (hTb : T < 2 ^ 30)
    (hp : p < 2 ^ 30) (hc : c < 2 ^ 30) (ht : tok < 2 ^ 32) : Good (loopVal rest T p i c tok ptok next) ORDINARY.O :=
  goodLin_sound ORDINARY.lin_check
    (x := vx [(i : Int) / 256, (i : Int) % 256, p, (c : Int) - p - 2, (T : Int) - i - 3, tok])
    (by lin_mem [ordB]) (by lin_mem [ordV])

/-! ## The decode loop with a prompt of length `L`

The offset is `p = L + i + 1` and the capacity `256·⌈p/256⌉`; a case fixes the residues of `i`
and of `p` (`p = 256·b + s`), and the capacity is then the form `256·b + 256`. -/

def capL (p : Nat) : Nat := 256 * ((p + 255) / 256)

/-- `ORDINARY` at any `L`: `i % 256 ≠ 0`, `p % 256 ∉ {0, 255}`. -/
def ordLB : List Prm :=
  [⟨0, 4194304, []⟩, ⟨1, 255, []⟩, ⟨0, 4194304, []⟩, ⟨1, 254, []⟩, ⟨0, 1073741824, []⟩, tokP]

def ordLV : List (Nat × Aff) :=
  [(0, 256 • P 0 + P 1 + P 4 + 3), (9, 256 • P 2 + P 3), (10, 256 • P 0 + P 1), (11, 256 • P 0 + P 1),
   (12, 256 • P 0 + P 1), (13, 256 • P 0 + P 1 - 1), (14, P 5), (16, 256 • P 2 + 256)]

theorem ordL_check : goodLin ordLB ordLV ordD = true := by decide +kernel

theorem good_ordL {rest : Nat → F64} {L T i tok ptok next : Nat} (hrem : i % 256 ≠ 0)
    (hs0 : (L + i + 1) % 256 ≠ 0) (hs1 : (L + i + 1) % 256 ≠ 255) (hT : i + 2 < T) (hp : L + i + 1 < 2 ^ 30)
    (hTb : T < 2 ^ 30) (htok : tok ≠ 248044) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (L + i + 1) i (capL (L + i + 1)) tok ptok next) ordD :=
  goodLin_sound ordL_check
    (x := vx [(i : Int) / 256, (i : Int) % 256, ((L + i + 1 : Nat) : Int) / 256, ((L + i + 1 : Nat) : Int) % 256,
      (T : Int) - i - 3, tok])
    (by lin_mem [ordLB, tokP]) (by lin_mem [ordLV, capL])

/-- The new case `CLEARFILL`: `fillD` with the clear answer true. -/
def clearFillD : List Ans :=
  fillD.map fun q => if q = ⟨.eq, .bin .rem gen1Prev lit256, litZero, false⟩ then { q with r := true } else q

/-- `i = 256·a`, `p = 256·b + 255`. -/
def clearFillLB : List Prm := [⟨1, 4194304, []⟩, ⟨0, 4194303, []⟩, ⟨0, 1073741824, []⟩, tokP]

def clearFillLV : List (Nat × Aff) :=
  [(0, 256 • P 0 + P 2 + 3), (9, 256 • P 1 + 255), (10, 256 • P 0), (11, 256 • P 0), (12, 256 • P 0),
   (13, 256 • P 0 - 1), (14, P 3), (16, 256 • P 1 + 256)]

theorem clearFillL_check : goodLin clearFillLB clearFillLV clearFillD = true := by decide +kernel

theorem good_clearFillL {rest : Nat → F64} {L T i tok ptok next : Nat} (hi0 : i ≠ 0) (hrem : i % 256 = 0)
    (hs : (L + i + 1) % 256 = 255) (hT : i + 2 < T) (hp : L + i + 1 < 2 ^ 30) (hTb : T < 2 ^ 30)
    (htok : tok ≠ 248044) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (L + i + 1) i (capL (L + i + 1)) tok ptok next) clearFillD :=
  goodLin_sound clearFillL_check
    (x := vx [(i : Int) / 256, ((L + i + 1 : Nat) : Int) / 256, (T : Int) - i - 3, tok])
    (by lin_mem [clearFillLB, tokP]) (by lin_mem [clearFillLV, capL])

/-! ## Synthetic prefill oracles

Variables: `v1` the prompt length `L`, `v2` the position `o`, `v3` the chunk size `C`, `v4` the KV
capacity. Comparisons are the interpreter's: `a > b` asks `lt b a`, `a >= b` asks `le b a`. -/

/-- The parser's form of a non-negative integer literal. -/
def nl (k : Nat) : SymE := .lit (if k = 0 then .zero false else .fin false k 0)

/-- `Number.isSafeInteger(v)`, as the symbolic `litTest` path asks it: `trunc(v) === v` and
`|v| ≤ 2^53 - 1`. -/
def safeInt (v : SymE) : List Ans :=
  [⟨.eq, .un .trunc v, v, true⟩, ⟨.le, v, nl 9007199254740991, true⟩,
   ⟨.le, .lit (.fin true 9007199254740991 0), v, true⟩]

/-! ### Chunk size: `sdpaFallbackBytes(geometry, C, L) > 1024^3` with `C` halving from 2048

`queries = Math.min(C, L)`; each of the 16 full-attention layers (24 heads, head dim 256)
updates `peak = Math.max(peak, 24 * queries * L * 2)`. -/

def scores (C : Nat) : SymE := .bin .mul (.bin .mul (.bin .mul (nl 24) (.bin .min (nl C) (.var 1))) (.var 1)) (nl 2)

def peak (C : Nat) : Nat → SymE
  | 0 => .bin .max (nl 0) (scores C)
  | n + 1 => .bin .max (peak C n) (scores C)

/-- The workspace test for chunk `C` with answer `big`. -/
def sdpaD (C : Nat) (big : Bool) : List Ans :=
  [⟨.le, .bin .min (nl C) (.var 1), nl 8, false⟩, ⟨.lt, nl 1073741824, peak C 15, big⟩]

/-- `generateInner` up to the first step at `o = 0`: chunk selection (`Cs`), `cached >= L`, the
budget `maxTokens ?? Infinity` bound, and `nextPrefillStep` at position `0` with chunk `C`
(`whole`: the first step is a whole chunk). -/
def setupD (Cs : List (Nat × Bool)) (C : Nat) (whole yield : Bool) : List Ans :=
  (Cs.map fun (c, b) => sdpaD c b).flatten ++
  [⟨.le, .var 1, nl 0, false⟩, ⟨.lt, .var 1, .lit (.inf false), true⟩,
   ⟨.le, .bin .min (.var 1) (.lit (.inf false)), nl 262144, true⟩] ++
  safeInt (.var 1) ++
  [⟨.le, .var 1, nl 0, false⟩, ⟨.lt, nl 1, .bin .sub (.var 1) (nl 0), true⟩,
   ⟨.le, nl C, .bin .sub (.bin .sub (.var 1) (nl 0)) (nl 1), whole⟩,
   ⟨.lt, nl C, .bin .sub (.bin .sub (.var 1) (nl 0)) (nl 1), yield⟩]

/-- `L ∈ [9, 2048]`: chunk 2048 (`48·L² ≤ 2^30`), the first step is the tail. -/
theorem setup_short : goodLin [⟨9, 2048, []⟩] [(1, P 0)] (setupD [(2048, false)] 2048 false false) = true := by
  decide +kernel

/-- `L ∈ [2050, 10922]`: chunk 2048 (`98304·L ≤ 2^30`), the first step is a whole chunk. -/
theorem setup_2048 : goodLin [⟨2050, 10922, []⟩] [(1, P 0)] (setupD [(2048, false)] 2048 true true) = true := by
  decide +kernel

/-- `L ∈ [10923, 21845]`: chunk 2048 is too large, 1024 fits. -/
theorem setup_1024 :
    goodLin [⟨10923, 21845, []⟩] [(1, P 0)] (setupD [(2048, true), (1024, false)] 1024 true true) = true := by
  decide +kernel

/-- `L ∈ [87382, 174762]`: chunks 2048 … 256 are too large, 128 fits. -/
theorem setup_128 :
    goodLin [⟨87382, 174762, []⟩] [(1, P 0)]
      (setupD [(2048, true), (1024, true), (512, true), (256, true), (128, false)] 128 true true) = true := by
  decide +kernel

/-! ### A prefill step at `o = 2048·k`: `nextPrefillStep`, then the KV append of its rows -/

def remE : SymE := .bin .sub (.var 1) (.var 2)
def rem1 : SymE := .bin .sub remE (nl 1)

/-- `nextPrefillStep({length: L, position: o, chunkSize: C, tailSplit: true})`; `whole` (a
whole chunk, else the tail `[o, L - 1)`) and `yield` (`remaining - 1 > C`). -/
def stepD (whole yield : Bool) : List Ans :=
  safeInt (.var 1) ++ safeInt (.var 2) ++ safeInt (.var 3) ++
  [⟨.lt, .var 3, nl 1, false⟩, ⟨.lt, .var 2, nl 0, false⟩, ⟨.le, .var 1, .var 2, false⟩,
   ⟨.lt, nl 1, remE, true⟩, ⟨.le, .var 3, rem1, whole⟩, ⟨.lt, .var 3, rem1, yield⟩]

/-- The step's end `o + (whole ? C : remaining - 1)`, and its rows `end - o`. -/
def stepEnd (whole : Bool) : SymE := .bin .add (.var 2) (if whole then .var 3 else rem1)
def rows (whole : Bool) : SymE := .bin .sub (stepEnd whole) (.var 2)

/-- `KVCache.updateAndFetch` with `n` rows at offset `v2` and capacity `v4` (growth): the
growth test, `nSteps = Math.floor((256 + n - 1) / 256)`, the zeros' `int32` shape, the trim
test `prev % 256 !== 0`, and the bounds checks of the update and read slices at `int32`
offsets, against the grown capacity (`fits`: the end stays below it). -/
def growD (n : SymE) (fits : Bool) : List Ans :=
  let e : SymE := .bin .add (.var 2) n
  let sz : SymE := .bin .mul (.un .floor (.bin .div (.bin .sub (.bin .add (nl 256) n) (nl 1)) (nl 256))) (nl 256)
  let cap' : SymE := .bin .add (.var 4) sz
  let o32 : SymE := .un .int32 (.var 2)
  let e32 : SymE := .un .int32 e
  [⟨.eq, .bin .sub e (.var 2), nl 1, false⟩, ⟨.lt, .var 4, e, true⟩, ⟨.lt, .un .int32 sz, nl 0, false⟩,
   ⟨.eq, .bin .rem (.var 2) (nl 256), nl 0, true⟩,
   ⟨.lt, o32, nl 0, false⟩, ⟨.lt, e32, nl 0, false⟩, ⟨.lt, o32, cap', true⟩, ⟨.lt, nl 0, o32, true⟩,
   ⟨.lt, e32, cap', fits⟩, ⟨.lt, nl 0, e32, true⟩, ⟨.lt, e32, o32, false⟩,
   ⟨.eq, nl 1, .bin .sub e32 o32, false⟩, ⟨.lt, nl 0, cap', true⟩, ⟨.eq, .bin .sub e32 (nl 0), cap', !fits⟩]

def drainD (yield : Bool) : List Ans := stepD true yield ++ growD (rows true) false
def tailD : List Ans := stepD false false ++ growD (rows false) true

/-- A whole chunk after `k ≥ 1` chunks with more than one chunk left: `L = 2048·k + 2049 + s`. -/
def drainB : List Prm := [⟨1, 127, []⟩, ⟨1, 262144, []⟩]
def drainV : List (Nat × Aff) := [(1, 2048 • P 0 + P 1 + 2049), (2, 2048 • P 0), (3, 2048), (4, 2048 • P 0)]

theorem drain_check : goodLin drainB drainV (drainD true) = true := by decide +kernel

/-- The class as hypotheses: `C = 2048`, `1 ≤ k`, `o = k·C`, `L - o - 1 > C`, capacity `o`. -/
theorem drain_good {ρ : Nat → F64} {L o k : Nat} (hk : 1 ≤ k) (hk' : k ≤ 127) (ho : o = 2048 * k)
    (hL : L - o - 1 > 2048) (hLb : L ≤ 262144 + o + 2049) (h1 : ρ 1 = F64.ofNat L) (h2 : ρ 2 = F64.ofNat o)
    (h3 : ρ 3 = F64.ofNat 2048) (h4 : ρ 4 = F64.ofNat o) : Good ρ (drainD true) :=
  goodLin_sound drain_check (x := vx [k, (L : Int) - o - 2049]) (by lin_mem [drainB])
    (by lin_mem [drainV, h1, h2, h3, h4])

/-- The last whole chunk before the tail: `L - o - 1 = C`. -/
def drainLastV : List (Nat × Aff) := [(1, 2048 • P 0 + 2049), (2, 2048 • P 0), (3, 2048), (4, 2048 • P 0)]

theorem drain_last_check : goodLin [⟨1, 127, []⟩] drainLastV (drainD false) = true := by decide +kernel

/-- The tail `[o, L - 1)` of `n ∈ [9, 223]` rows after `k ≥ 1` chunks: `L = 2048·k + n + 1`. -/
def tailB : List Prm := [⟨1, 5, []⟩, ⟨9, 223, []⟩]
def tailV : List (Nat × Aff) := [(1, 2048 • P 0 + P 1 + 1), (2, 2048 • P 0), (3, 2048), (4, 2048 • P 0)]

theorem tail_check : goodLin tailB tailV tailD = true := by decide +kernel

theorem tail_good {ρ : Nat → F64} {L o k : Nat} (hk : 1 ≤ k) (hk' : k ≤ 5) (ho : o = 2048 * k)
    (hn : 10 ≤ L - o) (hn' : L - o ≤ 224) (h1 : ρ 1 = F64.ofNat L) (h2 : ρ 2 = F64.ofNat o)
    (h3 : ρ 3 = F64.ofNat 2048) (h4 : ρ 4 = F64.ofNat o) : Good ρ tailD :=
  goodLin_sound tail_check (x := vx [k, (L : Int) - o - 1]) (by lin_mem [tailB])
    (by lin_mem [tailV, h1, h2, h3, h4])

end Host.Ts.Sim.Lin.Tests
