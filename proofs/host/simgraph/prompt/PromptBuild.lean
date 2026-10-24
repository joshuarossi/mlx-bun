import host.simgraph.prompt.PDim
import host.simgraph.Dims
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval

/-! # Multi-row step graphs

A prefill step appends `n` prompt rows at cache offset `o`. Its expected graph
is built by a *row family*: the operation templates of one row class (D1,
V23, V4, V58, VW, the Neural Engine buckets), one per layer kind, with every
dimension a `PDim` read through an interpretation `I : PDim → δ` (`id` for
the template, `PDim.eval ν` for an instance) and the control offset `o` and
rows `n` deciding only the KV branches.

* `PKey`: the step's inputs — the decode step's, the prompt ids (the node
  B-newdata creates; the host-side bridge supplies its value, the encoding
  of `π[o, o+n)`), and small int32 data whose cells are dimensions
  (`gated_delta_step`'s `Tin = [n]`): `cells p j vals shape`, stage `p`'s
  `j`-th, valued by `DimData.cellsValue`.
* `kvStepP`: the KV append of `n` rows (kv.ts `updateAndFetch`): grow iff the
  buffer is null or `o + n > cap` by `256·⌈n/256⌉` zero rows (trimming to `o`
  first iff `o % 256 ≠ 0`), write rows `[o, o+n)`, view `[0, o+n)`;
  `kvSigP` its branches; `kvStepP_one`: one row is the decode `kvStepG`.
* `RowOps`: a family — its branch signature, embedding, per-layer templates
  (`layer I o n p s x`: chain position `p`, layout `s`) and head;
  `forwardP` chains them over the layouts. `RowOps.IsNatural` (each template
  natural in the dimension type) gives `forwardP_natural`; `RowOps.SigOK`
  (layers depend on the control only through `sig`) gives `forwardP_sig`.
* `d1Ops key head pos pos1`: the decode step as a family at the symbolic
  position `pos`; `forwardP_d1`: it is `stepG` at `I pos`, `I pos1`. -/

/-! ## Inputs -/

inductive PKey where
  | base (k : InKey)
  | promptIds
  /-- Stage `p`'s `j`-th int32 data node: cells `vals`, shape `shape`. -/
  | cells (p j : Nat) (vals shape : List PDim)
  /-- Stage `p`'s `j`-th int32 data node `0, 1, …, count - 1` (shape `[count]`). -/
  | iota (p j : Nat) (count : PDim)
deriving DecidableEq

/-! ## The KV append of `n` rows at offset `o` -/

/-- The capacity after appending `n` rows at offset `o` (kv.ts, `STEP = 256`). -/
def kvCapP (cap : Option Nat) (o n : Nat) : Nat :=
  match cap with
  | none => 256 * ((n + 255) / 256)
  | some c => if c < o + n then (if o % 256 = 0 then c else o) + 256 * ((n + 255) / 256) else c

abbrev KvSig := Option (Bool × Bool) × Bool

/-- The append's branches: whether a buffer exists, then whether it grows
(`o + n > cap`) and is trimmed first (`o % 256 ≠ 0`), and whether the view is
the whole buffer. -/
def kvSigP (cap : Option Nat) (o n : Nat) : KvSig :=
  (cap.map fun c => (decide (c < o + n), decide (c < o + n) && decide (o % 256 ≠ 0)),
    decide (kvCapP cap o n = o + n))

theorem kvCapP_one (cap : Option Nat) (o : Nat) : kvCapP cap o 1 = kvCap cap o := by
  cases cap <;> rfl

/-- **The prefill capacity invariant** `cap = 256·⌈o/256⌉` (null at `o = 0`) is
kept by an append that grows only at multiples of 256 (prefill-map §5). -/
theorem kvCapP_ceil (o n : Nat) (cap : Option Nat)
    (hcap : cap = if o = 0 then none else some (256 * ((o + 255) / 256)))
    (hgrow : ∀ c, cap = some c → c < o + n → o % 256 = 0) :
    kvCapP cap o n = 256 * ((o + n + 255) / 256) := by
  by_cases ho : o = 0
  · subst ho
    simp only [↓reduceIte] at hcap
    subst hcap
    simp [kvCapP]
  · simp only [ho, ↓reduceIte] at hcap
    subst hcap
    have hg := hgrow _ rfl
    simp only [kvCapP]
    split
    · rename_i h
      have := hg h
      simp only [this, ↓reduceIte]
      omega
    · rename_i h
      omega

theorem kvSigP_one (cap : Option Nat) (o : Nat) : kvSigP cap o 1 = kvSig cap o := by
  simp only [kvSigP, kvSig, kvCapP_one]

section
variable {δ κ : Type} (L : Int → δ) (o n : Nat) (oD onD gD : δ)

def kvOldP (b : Nat) : Build δ κ Nat :=
  if o % 256 = 0 then pure b
  else emit (.slice (D L [0, 0, 0, 0]) [L 1, L 4, oD, L 256] (D L [1, 1, 1, 1])) [b]

def kvGrownP (c b : Nat) : Build δ κ Nat :=
  if c < o + n then do
    let old ← kvOldP L o oD b
    let z ← emit (.zeros [L 1, L 4, gD, L 256] Ffi.dtBf16) []
    emit (.concat 2) [old, z]
  else pure b

def kvGrowP (cap : Option Nat) (key : κ) : Build δ κ Nat :=
  match cap with
  | none => emit (.zeros [L 1, L 4, gD, L 256] Ffi.dtBf16) []
  | some c => do
    let b ← inp key
    kvGrownP L o n oD gD c b

def kvViewP (cap : Option Nat) (b : Nat) : Build δ κ Nat :=
  if kvCapP cap o n = o + n then pure b
  else emit (.slice (D L [0, 0, 0, 0]) [L 1, L 4, onD, L 256] (D L [1, 1, 1, 1])) [b]

/-- kv.ts `updateAndFetch` of `n` rows `x` at offset `o` (dimensions `oD = o`,
`onD = o + n`, `gD = 256·⌈n/256⌉`): the written buffer and the view `[0, o+n)`. -/
def kvStepP (cap : Option Nat) (key : κ) (x : Nat) : Build δ κ (Nat × Nat) := do
  let grown ← kvGrowP L o n oD gD cap key
  let b ← emit (.sliceUpdate [L 0, L 0, oD, L 0] [L 1, L 4, onD, L 256] (D L [1, 1, 1, 1])) [grown, x]
  let view ← kvViewP L o n onD cap b
  pure (b, view)

end

/-- **One row is the decode append.** -/
theorem kvStepP_one {δ κ : Type} (L : Int → δ) (o : Nat) (oD o1D : δ) (cap : Option Nat) (key : κ) (x : Nat) :
    kvStepP L o 1 oD o1D (L 256) cap key x = kvStepG L o oD o1D cap key x := by
  have hv : ∀ b, kvViewP (κ := κ) L o 1 o1D cap b = kvViewG L o o1D cap b := by
    intro b; simp only [kvViewP, kvViewG, kvCapP_one]
  have hg : kvGrowP L o 1 oD (L 256) cap key = kvGrowG L o oD cap key := by
    cases cap <;> rfl
  simp only [kvStepP, kvStepG, hg, hv]

section Natural
variable {δ δ' κ : Type} (f : δ → δ') (L : Int → δ) (o n : Nat) (oD onD gD : δ)

theorem nat_kvOldP (b : Nat) : Natural f (kvOldP (κ := κ) L o oD b) (kvOldP (fun i => f (L i)) o (f oD) b) := by
  unfold kvOldP
  by_cases h : o % 256 = 0
  · simp only [h, ↓reduceIte]; exact natural_pure _
  · simp only [h, ↓reduceIte]; exact natural_emit _ (by dim_map)

theorem nat_kvGrownP (c b : Nat) :
    Natural f (kvGrownP (κ := κ) L o n oD gD c b) (kvGrownP (fun i => f (L i)) o n (f oD) (f gD) c b) := by
  unfold kvGrownP
  by_cases h : c < o + n
  · simp only [h, ↓reduceIte]
    exact natural_bind (nat_kvOldP f L o oD b) fun _ => natural_bind (natural_emit _ (by dim_map)) fun _ =>
      natural_emit _ rfl
  · simp only [h, ↓reduceIte]; exact natural_pure _

theorem nat_kvGrowP (cap : Option Nat) (key : κ) :
    Natural f (kvGrowP L o n oD gD cap key) (kvGrowP (fun i => f (L i)) o n (f oD) (f gD) cap key) := by
  cases cap with
  | none => exact natural_emit _ (by dim_map)
  | some c => exact natural_bind (nat_inp f key) fun b => nat_kvGrownP f L o n oD gD c b

theorem nat_kvViewP (cap : Option Nat) (b : Nat) :
    Natural f (kvViewP (κ := κ) L o n onD cap b) (kvViewP (fun i => f (L i)) o n (f onD) cap b) := by
  unfold kvViewP
  by_cases h : kvCapP cap o n = o + n
  · simp only [h, ↓reduceIte]; exact natural_pure _
  · simp only [h, ↓reduceIte]; exact natural_emit _ (by dim_map)

theorem nat_kvStepP (cap : Option Nat) (key : κ) (x : Nat) :
    Natural f (kvStepP L o n oD onD gD cap key x) (kvStepP (fun i => f (L i)) o n (f oD) (f onD) (f gD) cap key x) := by
  unfold kvStepP
  exact natural_bind (nat_kvGrowP f L o n oD gD cap key) fun _ => natural_bind (natural_emit _ (by dim_map)) fun _ =>
    natural_map _ (nat_kvViewP f L o n onD cap _)

end Natural

section Sig
variable {δ κ : Type} (L : Int → δ) (oD onD gD : δ)

theorem kvStepP_sig (o n o' n' : Nat) (cap cap' : Option Nat) (key : κ) (x : Nat)
    (h : kvSigP cap o n = kvSigP cap' o' n') :
    kvStepP L o n oD onD gD cap key x = kvStepP L o' n' oD onD gD cap' key x := by
  have hv : ∀ b, kvViewP (κ := κ) L o n onD cap b = kvViewP L o' n' onD cap' b := by
    intro b
    have h' : kvCapP cap o n = o + n ↔ kvCapP cap' o' n' = o' + n' := by simpa [kvSigP] using congrArg Prod.snd h
    unfold kvViewP
    by_cases v : kvCapP cap o n = o + n
    · simp only [v, h'.mp v, ↓reduceIte]
    · have v' : ¬ kvCapP cap' o' n' = o' + n' := fun e => v (h'.mpr e)
      simp only [v, v', ↓reduceIte]
  have hg : kvGrowP L o n oD gD cap key = kvGrowP L o' n' oD gD cap' key := by
    have h1 := congrArg Prod.fst h
    cases cap with
    | none =>
      cases cap' with
      | none => rfl
      | some _ => simp [kvSigP] at h1
    | some c =>
      cases cap' with
      | none => simp [kvSigP] at h1
      | some c' =>
        simp only [kvSigP, Option.map_some, Option.some.injEq, Prod.mk.injEq] at h1
        obtain ⟨h1, h2⟩ := h1
        have hc : c < o + n ↔ c' < o' + n' := by simpa using h1
        show (inp key >>= kvGrownP L o n oD gD c) = (inp key >>= kvGrownP L o' n' oD gD c')
        congr 1
        funext b
        unfold kvGrownP
        by_cases g : c < o + n
        · have g' : c' < o' + n' := hc.mp g
          simp only [g, g', ↓reduceIte]
          have ht : o % 256 = 0 ↔ o' % 256 = 0 := by simp [g, g'] at h2; omega
          unfold kvOldP
          by_cases t : o % 256 = 0
          · simp only [t, ht.mp t, ↓reduceIte]
          · have t' : ¬ o' % 256 = 0 := fun e => t (ht.mpr e)
            simp only [t, t', ↓reduceIte]
        · have g' : ¬ c' < o' + n' := fun e => g (hc.mpr e)
          simp only [g, g', ↓reduceIte]
  unfold kvStepP
  rw [hg]
  congr 1; funext g; congr 1; funext b
  rw [hv]

end Sig

/-! ## Row families -/

/-- A row class's operation templates. Dimensions are `PDim` terms read through
`I`; `o`, `n` are the control offset and rows, which only `sig`'s branches may
depend on. -/
structure RowOps (κ : Type) where
  /-- The KV branch signature at a capacity, offset and rows. -/
  sig : Option Nat → Nat → Nat → KvSig
  embed : {δ : Type} → (PDim → δ) → Build δ κ Nat
  /-- One layer at chain position `p` with layout `s` on input node `x`: the
  output node and the layer's two cache nodes. -/
  layer : {δ : Type} → (PDim → δ) → Nat → Nat → Nat → StageLayout → Nat → Build δ κ (Nat × Nat × Nat)
  final : {δ : Type} → (PDim → δ) → Nat → Build δ κ Nat

section
variable {δ κ : Type} (R : RowOps κ) (I : PDim → δ) (o n : Nat)

/-- The layers from chain position `p`: the hidden node and each layer's cache nodes. -/
def chainP : Nat → List StageLayout → Nat → Build δ κ (Nat × List (Nat × Nat))
  | _, [], x => pure (x, [])
  | p, s :: ss, x => do
    let (y, c1, c2) ← R.layer I o n p s x
    let (z, cs) ← chainP (p + 1) ss y
    pure (z, (c1, c2) :: cs)

/-- The family's step: embedding, layers, head; the head's output and the cache nodes. -/
def forwardP (ss : List StageLayout) : Build δ κ (Nat × List (Nat × Nat)) := do
  let x ← R.embed I
  let (y, cs) ← chainP R I o n 0 ss x
  let r ← R.final I y
  pure (r, cs)

/-- The family's expected graph, output node and cache nodes. -/
def familyGraph (ss : List StageLayout) : List (RNode δ κ) × Nat × List (Nat × Nat) :=
  let r := run (forwardP R I o n ss) []
  (r.2, r.1)

end

/-- Each template is natural in the dimension type. -/
structure RowOps.IsNatural {κ : Type} (R : RowOps κ) : Prop where
  embed : ∀ {δ δ' : Type} (f : δ → δ') (I : PDim → δ), Natural f (R.embed I) (R.embed fun d => f (I d))
  layer : ∀ {δ δ' : Type} (f : δ → δ') (I : PDim → δ) (o n p : Nat) (s : StageLayout) (x : Nat),
    Natural f (R.layer I o n p s x) (R.layer (fun d => f (I d)) o n p s x)
  final : ∀ {δ δ' : Type} (f : δ → δ') (I : PDim → δ) (y : Nat),
    Natural f (R.final I y) (R.final (fun d => f (I d)) y)

/-- Layouts agreeing except in attention capacities, which take the same
branches (`sig`) at control `(o, n)` and `(o', n')`. -/
def SigRelR (sig : Option Nat → Nat → Nat → KvSig) (o n o' n' : Nat) : StageLayout → StageLayout → Prop
  | .delta d, .delta d' => d = d'
  | .attention a, .attention a' => a.q = a'.q ∧ a.k = a'.k ∧ a.v = a'.v ∧ a.o = a'.o ∧ a.mlp = a'.mlp ∧
      sig a.kcap o n = sig a'.kcap o' n' ∧ sig a.vcap o n = sig a'.vcap o' n'
  | _, _ => False

/-- The layers depend on the control only through the branch signature. -/
def RowOps.SigOK {κ : Type} (R : RowOps κ) : Prop :=
  ∀ {δ : Type} (I : PDim → δ) (o n o' n' p : Nat) (s s' : StageLayout) (x : Nat),
    SigRelR R.sig o n o' n' s s' → R.layer I o n p s x = R.layer I o' n' p s' x

/-- A row family with its two obligations. -/
structure RowFamily (κ : Type) where
  ops : RowOps κ
  natural : ops.IsNatural
  sigOK : ops.SigOK

section
variable {κ : Type} (R : RowOps κ)

theorem chainP_natural (hR : R.IsNatural) {δ δ' : Type} (f : δ → δ') (I : PDim → δ) (o n : Nat) :
    ∀ (p : Nat) (ss : List StageLayout) (x : Nat),
      Natural f (chainP R I o n p ss x) (chainP R (fun d => f (I d)) o n p ss x)
  | _, [], _ => natural_pure _
  | p, s :: ss, x =>
    natural_bind (hR.layer f I o n p s x) fun ⟨y, _, _⟩ =>
      natural_bind (chainP_natural hR f I o n (p + 1) ss y) fun ⟨_, _⟩ => natural_pure _

theorem forwardP_natural (hR : R.IsNatural) {δ δ' : Type} (f : δ → δ') (I : PDim → δ) (o n : Nat)
    (ss : List StageLayout) : Natural f (forwardP R I o n ss) (forwardP R (fun d => f (I d)) o n ss) :=
  natural_bind (hR.embed f I) fun _ => natural_bind (chainP_natural R hR f I o n 0 ss _) fun ⟨y, _⟩ =>
    natural_bind (hR.final f I y) fun _ => natural_pure _

theorem chainP_sig (hS : R.SigOK) {δ : Type} (I : PDim → δ) (o n o' n' : Nat) :
    ∀ (p : Nat) (ss ss' : List StageLayout), List.Forall₂ (SigRelR R.sig o n o' n') ss ss' → ∀ x : Nat,
      chainP R I o n p ss x = chainP R I o' n' p ss' x
  | _, [], [], .nil, _ => rfl
  | p, s :: ss, s' :: ss', .cons hs hss, x => by
    show (R.layer I o n p s x >>= _) = (R.layer I o' n' p s' x >>= _)
    rw [hS I o n o' n' p s s' x hs]
    congr 1; funext r
    obtain ⟨y, c1, c2⟩ := r
    dsimp only
    rw [chainP_sig hS I o n o' n' (p + 1) ss ss' hss y]

theorem forwardP_sig (hS : R.SigOK) {δ : Type} (I : PDim → δ) (o n o' n' : Nat) (ss ss' : List StageLayout)
    (h : List.Forall₂ (SigRelR R.sig o n o' n') ss ss') : forwardP R I o n ss = forwardP R I o' n' ss' := by
  unfold forwardP
  congr 1; funext x
  rw [chainP_sig R hS I o n o' n' 0 ss ss' h x]

/-- **Instances of a family's template.** The template built at representative
control `(o₀, n₀)` and layouts `ss₀` with symbolic dimensions, evaluated at `ν`,
is the family's graph at `ν` for every control and layouts in the same branches. -/
theorem family_eval (F : RowFamily κ) (o₀ n₀ : Nat) (ss₀ : List StageLayout) (ν : Nat → Int) (o n : Nat)
    (ss : List StageLayout) (hsig : List.Forall₂ (SigRelR F.ops.sig o₀ n₀ o n) ss₀ ss) :
    ((familyGraph F.ops id o₀ n₀ ss₀).1.map (mapN (PDim.eval ν)), (familyGraph F.ops id o₀ n₀ ss₀).2) =
      familyGraph F.ops (PDim.eval ν) o n ss := by
  have hnat := forwardP_natural F.ops F.natural (PDim.eval ν) id o₀ n₀ ss₀ []
  simp only [List.map_nil, id] at hnat
  unfold familyGraph
  rw [← forwardP_sig F.ops F.sigOK (PDim.eval ν) o₀ n₀ o n ss₀ ss hsig, hnat]

end

/-! ## The decode step as a family -/

section D1
variable {κ : Type} (key : InKey → κ) (head : LinLayout) (pos pos1 : PDim)

/-- The decode head after the chain (`stepG`'s tail). -/
def d1Head {δ : Type} (L : Int → δ) (y : Nat) : Build δ κ Nat := do
  let h ← normG (key .finalNorm) y
  let logits ← projectG L head (key ∘ .head) h
  let l ← emit (.reshape (D L [1, 248320])) [logits]
  let lse ← emit (.logsumexp 1 true) [l]
  let values ← emit (kern L chars!"normalized_argmax_partial" partialConfig 0) [l, lse]
  let indices ← emit (kern L chars!"normalized_argmax_partial" partialConfig 1) [l, lse]
  let tok ← emit (kern L chars!"normalized_argmax_finish" finishConfig 0) [values, indices]
  emit (.reshape (D L [1])) [tok]

/-- **The D1 forward as a row family** at the symbolic position `pos`
(`pos1` its successor): the decode step's templates with the offset
dimensions `I pos`, `I pos1`; rows are always one, so the branch signature
is the decode one. -/
def d1Ops : RowOps κ where
  sig cap o _ := kvSig cap o
  embed _ := embedG key
  layer I o _ p s x := stageG (fun i => I (.lit i)) o (I pos) (I pos1) s (fun k => key (.stage p k)) x
  final I y := d1Head key head (fun i => I (.lit i)) y

theorem chainP_d1 {δ : Type} (I : PDim → δ) (o n : Nat) :
    ∀ (p : Nat) (ss : List StageLayout) (x : Nat),
      chainP (d1Ops key head pos pos1) I o n p ss x = chainG (fun i => I (.lit i)) o (I pos) (I pos1) key p ss x
  | _, [], _ => rfl
  | p, s :: ss, x => by
    show (stageG _ o _ _ s _ x >>= _) = (stageG _ o _ _ s _ x >>= _)
    congr 1; funext r
    obtain ⟨y, c1, c2⟩ := r
    dsimp only
    rw [chainP_d1 I o n (p + 1) ss y]

/-- **The D1 family is the decode step** at the position's dimensions. -/
theorem forwardP_d1 {δ : Type} (I : PDim → δ) (o n : Nat) (ss : List StageLayout) :
    forwardP (d1Ops key head pos pos1) I o n ss = stepG (fun i => I (.lit i)) o (I pos) (I pos1) key ss head := by
  unfold forwardP stepG
  congr 1; funext x
  rw [chainP_d1 key head pos pos1 I o n 0 ss x]
  rfl

theorem d1_natural : (d1Ops (κ := κ) key head pos pos1).IsNatural where
  embed f _ := nat_embedG f key
  layer f I o _ p s x := nat_stageG f o (fun i => I (.lit i)) (I pos) (I pos1) s _ x
  final f I y := by
    show Natural f (d1Head key head (fun i => I (.lit i)) y) (d1Head key head (fun i => f (I (.lit i))) y)
    unfold d1Head
    nat_peel

theorem sigRel_of_d1 (o n o' n' : Nat) (s s' : StageLayout)
    (h : SigRelR (d1Ops (κ := κ) key head pos pos1).sig o n o' n' s s') : SigRel o o' s s' := by
  cases s <;> cases s' <;> exact h

theorem d1_sigOK : (d1Ops (κ := κ) key head pos pos1).SigOK := by
  intro δ I o n o' n' p s s' x h
  exact stageG_sig (fun i => I (.lit i)) o o' (I pos) (I pos1) s s' (sigRel_of_d1 key head pos pos1 o n o' n' s s' h) _ x

/-- The D1 family with its obligations. -/
def d1Family : RowFamily κ := ⟨d1Ops key head pos pos1, d1_natural key head pos pos1, d1_sigOK key head pos pos1⟩

theorem sigRelR_d1 (o n o' n' : Nat) (s s' : StageLayout) (h : SigRel o o' s s') :
    SigRelR (d1Ops (κ := κ) key head pos pos1).sig o n o' n' s s' := by
  cases s <;> cases s' <;> exact h

end D1

end Host.Mlx.SimGraph
