import host.sim.PrefillSched
import host.sim.lin.Enum
namespace Host.Ts.Sim.Lin.Cls
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Prefill

/-! # The prefill classes as LinGood boxes

A template generated for one representative prompt of a class is reused for every prompt of
the class; its oracle is correct there when `goodLin` (or `goodEnum`) decides it over a box
whose points cover the class. This module states what a class table is; `host.sim.lin.Table`
is the generated table and `host.sim.lin.Cover` proves that it covers exactly the classes of
`host.sim.PrefillSched`.

* **Quantities** (`Q`, `Inst`): a prefill step of a prompt of `L` tokens as the numbers its
  templates read: `L`, the chunk size `C`, the step's start `o`, rows `n`, end `e = o + n`, the
  KV capacity before (`cap`) and after (`cap1`) its append, and `k` (the drain's index, or the
  number of drains before a tail). The step of each position of the chain (`setupI`, `firstI`,
  `drainI`, `tailI`, `finalI`, `postI`) is the schedule's (`*_step`: `nextStep`, `kvCap`).
* **Rows** (`Row`, `InRow`): a box of integer parameters, the quantities as affine forms in
  them, and tags naming the stage classes the step falls in (`Tag`: `nextPrefillStep`'s
  classes `NpsC`, the KV append's `KvC`; `kv2` is a POST step's second append, at `e` with
  capacity `cap1`). A step is in a row when its tags hold and some parameter vector of the box
  gives each quantity its form's value. A class's rows split it where its stage classes differ.
* **Checks** (`good_of_row`, `good_of_row_enum`): a template reading quantity `q` in variable `j`
  (the map `m : List (Nat × Q)`) is checked once per row,
  `goodLin r.ps (varsOf r.V m) O = true`, and its oracle is then correct at every step of the
  row. -/

/-! ## Quantities -/

/-- A number of a prefill step a template variable holds. -/
inductive Q where
  | L
  | C
  | o
  | n
  | e
  | cap
  | cap1
  | k
  | T
  | t1
  | t2
  | kp
  deriving DecidableEq, Repr

/-- A prefill step as its quantities (and, at the route's positions, the budget `T` and tokens 1, 2). -/
structure Inst where
  L : Nat
  C : Nat
  o : Nat
  n : Nat
  cap : Nat
  cap1 : Nat
  k : Nat
  T : Nat
  t1 : Nat
  t2 : Nat

def Inst.get (i : Inst) : Q → Nat
  | .L => i.L
  | .C => i.C
  | .o => i.o
  | .n => i.n
  | .e => i.o + i.n
  | .cap => i.cap
  | .cap1 => i.cap1
  | .k => i.k
  | .T => i.T
  | .t1 => i.t1
  | .t2 => i.t2
  | .kp => i.k - 1

/-! ## The steps of a prompt of length `L` -/

/-- SETUP: the chunk-size choice. -/
def setupI (L : Nat) : Inst := ⟨L, chunkC L, 0, 0, 0, 0, 0, 0, 0, 0⟩

/-- The rows of the first step: a whole chunk, the tail `[0, L - 1)`, or the final row. -/
def firstN (L : Nat) : Nat := if 1 ≤ drains L then chunkC L else if 2 ≤ L then L - 1 else 1

/-- The first step, at `o = 0` into null caches. -/
def firstI (L : Nat) : Inst := ⟨L, chunkC L, 0, firstN L, 0, capL (firstN L), 0, 0, 0, 0⟩

/-- The `j`-th whole chunk (`j ≥ 1`). -/
def drainI (L j : Nat) : Inst :=
  ⟨L, chunkC L, j * chunkC L, chunkC L, capL (j * chunkC L), capL ((j + 1) * chunkC L), j, 0, 0, 0⟩

/-- The tail after the whole chunks. -/
def tailI (L : Nat) : Inst :=
  ⟨L, chunkC L, drains L * chunkC L, tailRows L, capL (drains L * chunkC L), capL (L - 1), drains L, 0, 0, 0⟩

/-- The final row at `L - 1`. -/
def finalI (L : Nat) : Inst := ⟨L, chunkC L, L - 1, 1, capL (L - 1), capL L, drains L, 0, 0, 0⟩

/-- POST: the decode row at offset `L` (and its successor at `L + 1`). -/
def postI (L : Nat) : Inst := ⟨L, chunkC L, L, 1, capL L, capL (L + 1), drains L, 0, 0, 0⟩

/-- A route position's step (POST, a short budget's path): POST's offset and capacities with the
budget `T` and tokens 1 and 2. -/
def routeI (L T t1 t2 : Nat) : Inst := ⟨L, chunkC L, L, 1, capL L, capL (L + 1), drains L, T, t1, t2⟩

/-- The route's positions after the prefill: POST (`T ≥ 3`, token 1 not EOS), the path through an
EOS as token 1 (`T ≥ 2`), the paths at `T = 2` past token 1 and at `T = 1`. -/
inductive RouteKind where
  | post
  | pathA
  | pathB
  | pathC
  deriving DecidableEq, Repr

/-- The route position's facts of the budget and the tokens (in the vocabulary, EOS `248044`; at
`T = 1` token 2 is past the budget). -/
def RouteKind.Holds : RouteKind → Nat → Nat → Nat → Nat → Prop
  | .post, L, T, t1, t2 => 3 ≤ T ∧ L + T ≤ 262144 ∧ t1 ≤ 248319 ∧ t1 ≠ 248044 ∧ t2 ≤ 248319
  | .pathA, L, T, t1, t2 => 2 ≤ T ∧ L + T ≤ 262144 ∧ t1 = 248044 ∧ t2 ≤ 248319
  | .pathB, L, T, t1, t2 => T = 2 ∧ L + T ≤ 262144 ∧ t1 ≤ 248319 ∧ t1 ≠ 248044 ∧ t2 ≤ 248319
  | .pathC, L, T, t1, _ => T = 1 ∧ L + T ≤ 262144 ∧ t1 ≤ 248319

/-- A route position's facts keep the context. -/
theorem RouteKind.ctx {k : RouteKind} {L T t1 t2 : Nat} (h : k.Holds L T t1 t2) : L + T ≤ 262144 := by
  cases k <;> exact h.2.1

/-- The route classes: each position at each post class. -/
def routeKeys : List (RouteKind × PostClass) :=
  [RouteKind.post, .pathA, .pathB, .pathC].flatMap fun k => postClasses.map fun c => (k, c)

/-! ### The decode loop's iterations -/

/-- **The decode loop's cases** after a prompt (`loopSelLW`'s six): the KV cache clear at
`i ≡ 0 (mod 256)` and the decode row's KV class at its offset `L + i + 1` (grow at `0`, fill at
`255` modulo 256). -/
inductive DecKind where
  | ord
  | clear
  | grow
  | fill
  | clearFill
  | clearGrow
  deriving DecidableEq, Repr

/-- The case of iteration `i` after a prompt of length `L`. -/
def DecKind.Holds : DecKind → Nat → Nat → Prop
  | .ord, L, i => i % 256 ≠ 0 ∧ (L + i + 1) % 256 ≠ 0 ∧ (L + i + 1) % 256 ≠ 255
  | .clear, L, i => i % 256 = 0 ∧ (L + i + 1) % 256 ≠ 0 ∧ (L + i + 1) % 256 ≠ 255
  | .grow, L, i => i % 256 ≠ 0 ∧ (L + i + 1) % 256 = 0
  | .fill, L, i => i % 256 ≠ 0 ∧ (L + i + 1) % 256 = 255
  | .clearFill, L, i => i % 256 = 0 ∧ (L + i + 1) % 256 = 255
  | .clearGrow, L, i => i % 256 = 0 ∧ (L + i + 1) % 256 = 0

/-- The case's iterations before the final one at budget `T`. -/
def DecKind.Sel (T L : Nat) (k : DecKind) (i : Nat) : Prop := 1 ≤ i ∧ i + 2 < T ∧ k.Holds L i

/-- The case's KV decode growth (its offset a multiple of 256). -/
def DecKind.grows : DecKind → Bool
  | .grow => true
  | .clearGrow => true
  | _ => false

theorem DecKind.cover (L i : Nat) : ∃ k : DecKind, k.Holds L i := by
  by_cases h1 : i % 256 = 0 <;> by_cases h2 : (L + i + 1) % 256 = 0 <;> by_cases h3 : (L + i + 1) % 256 = 255
  · exact ⟨.clearGrow, h1, h2⟩
  · exact ⟨.clearGrow, h1, h2⟩
  · exact ⟨.clearFill, h1, h3⟩
  · exact ⟨.clear, h1, h2, h3⟩
  · exact ⟨.grow, h1, h2⟩
  · exact ⟨.grow, h1, h2⟩
  · exact ⟨.fill, h1, h3⟩
  · exact ⟨.ord, h1, h2, h3⟩

theorem DecKind.grows_eq {k : DecKind} {L i : Nat} (h : k.Holds L i) : k.grows = decide ((L + i + 1) % 256 = 0) := by
  cases k <;> simp only [DecKind.Holds] at h <;> simp [DecKind.grows] <;> omega

/-- The decode classes. -/
def decKeys : List DecKind := [.ord, .clear, .grow, .fill, .clearFill, .clearGrow]

/-- **A decode iteration's step** at iteration `i` after a prompt of length `L` with budget `T`: the
row at cache offset `L + i + 1`, the capacities before and after it, the iteration `k = i`
(`kp = i - 1`), the budget and the current token `t1`. -/
def decI (L T i t1 : Nat) : Inst := ⟨L, chunkC L, L + i + 1, 1, capL (L + i + 1), capL (L + i + 2), i, T, t1, 0⟩

theorem chunkC_range {L : Nat} (h2 : L ≤ 349525) : 64 ≤ chunkC L ∧ chunkC L ≤ 2048 := by
  rcases chunkC_cases h2 with h | h | h | h | h | h <;> omega

/-- The band of `L` of each chunk size. -/
theorem chunkC_bounds {L : Nat} (h2 : L ≤ 349525) :
    (chunkC L = 2048 → L ≤ 10922) ∧ (chunkC L = 1024 → 10923 ≤ L ∧ L ≤ 21845) ∧
    (chunkC L = 512 → 21846 ≤ L ∧ L ≤ 43690) ∧ (chunkC L = 256 → 43691 ≤ L ∧ L ≤ 87381) ∧
    (chunkC L = 128 → 87382 ≤ L ∧ L ≤ 174762) ∧ (chunkC L = 64 → 174763 ≤ L) := by
  rw [chunkC_eq L h2]
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> intro h <;> (repeat' split at h) <;> omega

/-- A prompt without a whole chunk has chunk 2048 and at most 2048 tokens. -/
theorem first_chunk {L : Nat} (h2 : L ≤ 349525) (h0 : drains L = 0) : chunkC L = 2048 ∧ L ≤ 2048 := by
  have hL := drains_zero_le h2 h0
  refine ⟨?_, hL⟩
  rw [chunkC_eq L h2]
  (repeat' split) <;> omega

theorem rowMem_iff {X t lo hi : Nat} (h : rowBands[X]? = some (lo, hi)) : RowMem X t ↔ lo ≤ t ∧ t ≤ hi := by
  constructor
  · rintro ⟨b, hb, h1, h2⟩
    rw [h] at hb
    cases hb
    exact ⟨h1, h2⟩
  · rintro ⟨h1, h2⟩
    exact ⟨(lo, hi), h, h1, h2⟩

theorem kvOf_ord {o : Nat} (h : KvBranch.ord = kvOf o) : o % 256 ≠ 0 ∧ o % 256 ≠ 255 := by
  unfold kvOf at h
  (repeat' split at h) <;> (try cases h) <;> omega

theorem kvOf_fill {o : Nat} (h : KvBranch.fill = kvOf o) : o % 256 = 255 := by
  unfold kvOf at h
  (repeat' split at h) <;> (try cases h) <;> omega

theorem kvOf_grow {o : Nat} (h : KvBranch.grow = kvOf o) : o % 256 = 0 := by
  unfold kvOf at h
  (repeat' split at h) <;> (try cases h) <;> omega

theorem postOf_r0 {L : Nat} (h : PostClass.r0.Applies L) : L % 256 = 0 := by
  unfold PostClass.Applies postOf at h
  (repeat' split at h) <;> (try cases h) <;> omega

theorem postOf_r255 {L : Nat} (h : PostClass.r255.Applies L) : L % 256 = 255 := by
  unfold PostClass.Applies postOf at h
  (repeat' split at h) <;> (try cases h) <;> omega

theorem postOf_r254 {L : Nat} (h : PostClass.r254.Applies L) : L % 256 = 254 := by
  unfold PostClass.Applies postOf at h
  (repeat' split at h) <;> (try cases h) <;> omega

theorem postOf_other {L : Nat} (h : PostClass.other.Applies L) :
    L % 256 ≠ 0 ∧ L % 256 ≠ 255 ∧ L % 256 ≠ 254 := by
  unfold PostClass.Applies postOf at h
  (repeat' split at h) <;> (try cases h) <;> omega

/-! ### The steps are the schedule's -/

theorem firstI_step {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 349525) :
    (nextStep L (firstI L).o (firstI L).C).stop = (firstI L).o + (firstI L).n ∧
      kvCap true (firstI L).cap (firstI L).o (firstI L).n = (firstI L).cap1 := by
  refine ⟨?_, kvCap_first _⟩
  simp only [firstI, firstN, drains]
  unfold nextStep
  rcases chunkC_cases h2 with h | h | h | h | h | h <;> simp only [h] <;> (repeat' split) <;> (try simp only []) <;> omega

theorem drainI_step {L j : Nat} (h2 : L ≤ 349525) (hj : (j + 1) * chunkC L ≤ L - 1) :
    nextStep L (drainI L j).o (drainI L j).C =
        ⟨(drainI L j).o, (drainI L j).o + (drainI L j).n, false, .chunk⟩ ∧
      kvCap false (drainI L j).cap (drainI L j).o (drainI L j).n = (drainI L j).cap1 := by
  have := chunkC_range h2
  refine ⟨?_, kvCap_drain (chunkC_mem h2)⟩
  simp only [drainI]
  rw [nextStep_drain (by omega) hj, Nat.succ_mul]

theorem tailI_step {L : Nat} (h2 : L ≤ 349525) (ht : 1 ≤ tailRows L) :
    nextStep L (tailI L).o (tailI L).C =
        ⟨(tailI L).o, (tailI L).o + (tailI L).n, false, if (tailI L).n = 1 then .decode else .tail⟩ ∧
      kvCap false (tailI L).cap (tailI L).o (tailI L).n = (tailI L).cap1 := by
  have e := drains_tail L
  have hlt := tailRows_lt h2
  simp only [tailI]
  rw [nextStep_tail e ht hlt, kvCap_tail (chunkC_mem h2) (by omega), e]
  exact ⟨rfl, rfl⟩

theorem finalI_step {L : Nat} (h1 : 2 ≤ L) :
    nextStep L (finalI L).o (finalI L).C = ⟨(finalI L).o, (finalI L).o + (finalI L).n, true, .decode⟩ ∧
      kvCap false (finalI L).cap (finalI L).o (finalI L).n = (finalI L).cap1 := by
  simp only [finalI]
  rw [nextStep_final (by omega), kvCap_one, show L - 1 + 1 = L by omega]
  exact ⟨rfl, rfl⟩

theorem postI_step (L : Nat) : kvCap false (postI L).cap (postI L).o (postI L).n = (postI L).cap1 := kvCap_one L

/-! ## Stage classes -/

/-- The classes of `nextPrefillStep` (`host.sim.stage.NextStepRun`). -/
inductive NpsC where
  | DCby
  | DCeq
  | DTtail
  | DTdec
  | FIN
  deriving DecidableEq, Repr

/-- `nextPrefillStep` at length `L`, position `o`, chunk `C` is in the class (`prefillStage_holds`). -/
def NpsC.Holds : NpsC → Nat → Nat → Nat → Prop
  | .DCby, L, o, C => C < L - o - 1
  | .DCeq, L, o, C => L - o - 1 = C
  | .DTtail, L, o, C => 3 ≤ L - o ∧ L - o - 1 < C
  | .DTdec, L, o, _ => L - o = 2
  | .FIN, L, o, _ => L - o = 1

/-- The classes of the KV append (`host.sim.stage.CacheRun`): a decode row (`D*`) or a window
(`W*`) into a null buffer, a full buffer (growth), to its end, or into room. -/
inductive KvC where
  | DFirst
  | DGrow
  | DFill
  | DFit
  | WFirst
  | WFirst256
  | WGrow
  | WGrow256
  | WFill
  | WFit
  deriving DecidableEq, Repr

/-- An append of `n` rows at offset `o` into capacity `cap` is in the class (`*.Dom` of
`host.sim.stage.CacheHolds`, without the size bounds). -/
def KvC.Holds : KvC → Nat → Nat → Nat → Prop
  | .DFirst, o, cap, n => o = 0 ∧ cap = 0 ∧ n = 1
  | .DGrow, o, cap, n => 256 ≤ o ∧ o % 256 = 0 ∧ cap = o ∧ n = 1
  | .DFill, o, cap, n => 1 ≤ o ∧ cap = o + 1 ∧ n = 1
  | .DFit, o, cap, n => 1 ≤ o ∧ o + 1 < cap ∧ n = 1
  | .WFirst, o, cap, n => o = 0 ∧ cap = 0 ∧ 2 ≤ n ∧ n % 256 ≠ 0
  | .WFirst256, o, cap, n => o = 0 ∧ cap = 0 ∧ 256 ≤ n ∧ n % 256 = 0
  | .WGrow, o, cap, n => 256 ≤ o ∧ o % 256 = 0 ∧ cap = o ∧ 2 ≤ n ∧ n % 256 ≠ 0
  | .WGrow256, o, cap, n => 256 ≤ o ∧ o % 256 = 0 ∧ cap = o ∧ 256 ≤ n ∧ n % 256 = 0
  | .WFill, o, cap, n => 1 ≤ o ∧ 2 ≤ n ∧ cap = o + n
  | .WFit, o, cap, n => 1 ≤ o ∧ 2 ≤ n ∧ o + n < cap

/-- A row's tag. -/
inductive Tag where
  | nps (c : NpsC)
  | kv (c : KvC)
  | kv2 (c : KvC)
  deriving DecidableEq, Repr

def Tag.Holds : Tag → Inst → Prop
  | .nps c, i => c.Holds i.L i.o i.C
  | .kv c, i => c.Holds i.o i.cap i.n
  | .kv2 c, i => c.Holds (i.o + i.n) i.cap1 1

/-! ## Rows -/

/-- A row of a class: the box, the quantities' forms, the tags. -/
structure Row where
  ps : List Prm
  V : List (Q × Aff)
  tags : List Tag

/-- Parameters `x` give every quantity its form's value. -/
def QOk (i : Inst) (x : Nat → Int) : List (Q × Aff) → Prop
  | [] => True
  | (q, f) :: V => ((i.get q : Nat) : Int) = f.eval x ∧ QOk i x V

def TagsOk (i : Inst) : List Tag → Prop
  | [] => True
  | t :: ts => t.Holds i ∧ TagsOk i ts

/-- **Step `i` is in row `r`**: its tags hold and a parameter vector of the box gives each
quantity its form's value. -/
def InRow (r : Row) (i : Inst) : Prop := TagsOk i r.tags ∧ ∃ x, InBox r.ps 0 x ∧ QOk i x r.V

def lookupQ : List (Q × Aff) → Q → Option Aff
  | [], _ => none
  | (p, f) :: V, q => if p = q then some f else lookupQ V q

/-- The forms of a template's variables: `m` maps each variable to the quantity it holds. -/
def varsOf (V : List (Q × Aff)) : List (Nat × Q) → List (Nat × Aff)
  | [] => []
  | (j, q) :: m => match lookupQ V q with
    | some f => (j, f) :: varsOf V m
    | none => varsOf V m

/-- The valuation `ρ` takes every mapped variable to its quantity at step `i`. -/
def MapOk (ρ : Nat → F64) (i : Inst) : List (Nat × Q) → Prop
  | [] => True
  | (j, q) :: m => ρ j = F64.ofNat (i.get q) ∧ MapOk ρ i m

theorem lookupQ_ok {i : Inst} {x : Nat → Int} :
    ∀ {V : List (Q × Aff)} {q : Q} {f : Aff}, QOk i x V → lookupQ V q = some f → ((i.get q : Nat) : Int) = f.eval x
  | [], _, _, _, h => by simp [lookupQ] at h
  | (p, g) :: V, q, f, hv, h => by
    simp only [lookupQ] at h
    split at h
    · next hp => simp only [Option.some.injEq] at h; subst h hp; exact hv.1
    · exact lookupQ_ok hv.2 h

theorem varsOk_of {i : Inst} {x : Nat → Int} {V : List (Q × Aff)} (hq : QOk i x V) {ρ : Nat → F64} :
    ∀ {m : List (Nat × Q)}, MapOk ρ i m → VarsOk ρ x (varsOf V m)
  | [], _ => trivial
  | (j, q) :: m, ⟨hj, hm⟩ => by
    simp only [varsOf]
    split
    · next f hf => exact ⟨by rw [hj]; exact ofNat_ofInt (lookupQ_ok hq hf), varsOk_of hq hm⟩
    · exact varsOk_of hq hm

/-- **A row's check holds at every step of the row**: the template's oracle is correct at the
valuation of any step in the row. -/
theorem good_of_row {r : Row} {m : List (Nat × Q)} {o : List Ans} (h : goodLin r.ps (varsOf r.V m) o = true)
    {i : Inst} (hi : InRow r i) {ρ : Nat → F64} (hρ : MapOk ρ i m) : Good ρ o := by
  obtain ⟨-, x, hx, hq⟩ := hi
  exact goodLin_sound h hx (varsOk_of hq hρ)

/-- The same by enumeration, for a one-parameter row. -/
theorem good_of_row_enum {r : Row} {m : List (Nat × Q)} {o : List Ans} (h : goodEnum r.ps (varsOf r.V m) o = true)
    {i : Inst} (hi : InRow r i) {ρ : Nat → F64} (hρ : MapOk ρ i m) : Good ρ o := by
  obtain ⟨-, x, hx, hq⟩ := hi
  exact goodEnum_sound h hx (varsOk_of hq hρ)

/-- **The decode loop's variables** (`loopVal`): `0` the budget, `9` the offset, `10`–`12` the iteration,
`13` the iteration minus one, `14` the current token, `16` the capacity. -/
def decM : List (Nat × Q) := [(0, .T), (9, .o), (10, .k), (11, .k), (12, .k), (13, .kp), (14, .t1), (16, .cap)]

/-- **A decode row's check decides the oracle at the loop's valuation** of every iteration in the row. -/
theorem good_valL_of_row {r : Row} {o : List Ans} (h : goodLin r.ps (varsOf r.V decM) o = true) {ρ : Nat → F64}
    {T : Nat} {tk : Nat → Nat} {L i nx : Nat} (hi : InRow r (decI L T i (tk (i + 1)))) :
    Good (valL ρ T tk L i nx) o :=
  good_of_row h hi ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, trivial⟩

/-! ## Tables -/

/-- A class's rows in a table (`[]` off the table). -/
def rowsOf {α : Type} [DecidableEq α] : List (α × List Row) → α → List Row
  | [], _ => []
  | (a, rs) :: t, c => if a = c then rs else rowsOf t c

theorem rowsOf_all {α : Type} [DecidableEq α] {P : α → List Row → Prop} :
    ∀ {t : List (α × List Row)}, (∀ p ∈ t, P p.1 p.2) → ∀ c, c ∈ t.map Prod.fst → P c (rowsOf t c)
  | [], _, c, hc => by simp at hc
  | (a, rs) :: t, h, c, hc => by
    simp only [rowsOf]
    split
    · next e => subst e; exact h (a, rs) List.mem_cons_self
    · next e =>
      simp only [List.map_cons, List.mem_cons] at hc
      rcases hc with hc | hc
      · exact absurd hc.symm e
      · exact rowsOf_all (fun p hp => h p (List.mem_cons_of_mem _ hp)) c hc

theorem all_cons {α : Type} {P : α → List Row → Prop} {a : α} {rs : List Row} {t : List (α × List Row)}
    (h : P a rs) (ht : ∀ p ∈ t, P p.1 p.2) : ∀ p ∈ (a, rs) :: t, P p.1 p.2 := by
  intro p hp
  rcases List.mem_cons.mp hp with rfl | hp
  · exact h
  · exact ht p hp

theorem all_nil {α : Type} {P : α → List Row → Prop} : ∀ p ∈ ([] : List (α × List Row)), P p.1 p.2 := by
  intro p hp; cases hp

/-! ### What a table's class rows cover (`L ≤ 262143`: `|π| + T ≤ 262144` with `T ≥ 1`) -/

def SetupP (c : SetupClass) (rs : List Row) : Prop :=
  ∀ L, 1 ≤ L → L ≤ 262143 → c.Applies L → ∃ r ∈ rs, InRow r (setupI L)

def FirstP (c : FirstClass) (rs : List Row) : Prop :=
  ∀ L, 1 ≤ L → L ≤ 262143 → c.Applies L → ∃ r ∈ rs, InRow r (firstI L)

def DrainP (c : DrainClass) (rs : List Row) : Prop :=
  ∀ L j, 1 ≤ L → L ≤ 262143 → c.Applies L j → ∃ r ∈ rs, InRow r (drainI L j)

def TailP (c : TailClass) (rs : List Row) : Prop :=
  ∀ L, 1 ≤ L → L ≤ 262143 → c.Applies L → ∃ r ∈ rs, InRow r (tailI L)

def FinalP (c : FinalClass) (rs : List Row) : Prop :=
  ∀ L, 1 ≤ L → L ≤ 262143 → c.Applies L → ∃ r ∈ rs, InRow r (finalI L)

def PostP (c : PostClass) (rs : List Row) : Prop :=
  ∀ L, 1 ≤ L → L ≤ 262143 → c.Applies L → ∃ r ∈ rs, InRow r (postI L)

def RouteP (k : RouteKind) (c : PostClass) (rs : List Row) : Prop :=
  ∀ L T t1 t2, 1 ≤ L → L ≤ 262143 → k.Holds L T t1 t2 → c.Applies L → ∃ r ∈ rs, InRow r (routeI L T t1 t2)

/-- The decode loop's iterations: every iteration of the case at a prompt of length `L ≥ 1` within the
context, its current token in the vocabulary and not EOS. -/
def DecP (k : DecKind) (rs : List Row) : Prop :=
  ∀ L T i t1, 1 ≤ L → L + T ≤ 262144 → k.Sel T L i → t1 ≤ 248319 → t1 ≠ 248044 → ∃ r ∈ rs, InRow r (decI L T i t1)

/-! ### The cover proofs' leaves

`row_close [defs]` closes a row's three goals (`TagsOk`, `InBox`, `QOk` at an explicit
parameter vector `vx [...]`) from the class's facts in context, by `omega`. -/

syntax "row_close" (" [" Lean.Parser.Tactic.simpLemma,* "]")? : tactic

macro_rules
  | `(tactic| row_close $[[$ls,*]]?) => do
    let ls := ls.getD ⟨#[]⟩
    `(tactic| (
      simp only [TagsOk, Tag.Holds, NpsC.Holds, KvC.Holds, InBox, QOk, Inst.get, eval_mk, dot, vx_zero,
        vx_succ, vx_nil, capL, List.mem_cons, List.not_mem_nil, or_false, not_false_eq_true, and_true, true_and, Int.mul_zero,
        Int.add_zero, Int.zero_add, $ls,*]
      repeat' apply And.intro
      all_goals omega))

end Host.Ts.Sim.Lin.Cls
