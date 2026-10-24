import host.load.boot.ane.Data
import host.simgraph.mach.AnePremise
namespace Host.Load.Boot
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.GlueStep Host.Mlx.SimGraph Host.Mlx.SimGraph.Ref
  Host.Mlx.SimGraph.Mach Host.Mlx.GlueLayers Host.Load.Extract

/-! # The Neural Engine side of the loaded model, from the buckets the boot leaves

From buckets `D` (`aneX`), the bridge `B` and the arrays' contents `c` (the arrays' values
`headerValues c`): at a forward of `n` rows, its bucket (`bucketAt`, the range holding `n`), each
readback key's split (`netSplit`) — the program the bridge holds for the split's create, the fills
`mlp.ts`/`ane-prefill-split.ts` launch in order (an MLP split: the down, gate and up rows by
`trellisFillHalf`/`…K3Interleaved` from the full projections' codes and scales, then the hidden rows
by `writeHalf`; an affine split: the head's dequantized rows, then the input), each on its surface's
fp16 wrap (`half`), the reader over the output surface's wrap — and the construction-time inputs
(`netInputs`: an affine split's head and rest rows, the MLP split's rest rows).

`aneNetOf_layer`: when the buckets pass `aneCheck`, at every bucket of 224–2048 rows each layer's Neural
Engine side is as the route's family reads it (`AneNetLayer`); `netSplit_keys`: only readback keys
have splits. Like the splits, the inputs are the forward's bucket's (the MLP split's rest rows are 11264
up to 768 rows, 10752 above). -/

section
variable (D : List ABucket) (B : FfiAne.St) (c : Nat → Nat → Nat)

/-- The bucket of a forward of `n` rows. -/
def bucketAt (n : Nat) : Option ABucket := D.find? fun b => Nat.ble b.lo n && Nat.ble n b.rows

/-- A trellis fill of `rows` stored rows of `t` onto surface `sid`. -/
def trelFill (k : InPlaceKernel) (rows : Nat) (t : ATrel) (sid : Nat) : FillSpec :=
  ⟨k, fillConfig rows t.bits, sid, .float16, [half B sid], ([1], .int32),
    [.val (headerValues c t.codes), .val (headerValues c t.scales)]⟩

/-- A half write of `N` elements of tap `i` onto surface `sid`. -/
def halfFill (N sid i : Nat) : FillSpec := ⟨.writeHalf, writeConfig N, sid, .float16, [half B sid], ([1], .int32), [.tap i]⟩

/-- An MLP split's fills (`mlpSplit`: wd, wg, wu, x). -/
def mlpFills (n : Nat) (m : AMlp) (pr : FfiAne.Program) : List FillSpec :=
  [trelFill B c (bif m.k3i then .trellisFillK3i else .trellisFill) m.channels m.down (pr.ins.getD 0 0),
    trelFill B c .trellisFill m.channels m.gate (pr.ins.getD 1 0),
    trelFill B c .trellisFill m.channels m.up (pr.ins.getD 2 0),
    halfFill B (5120 * n) (pr.ins.getD 3 0) 0]

/-- An affine split's fills (`AneAffineSplit.forward`: weights, input). -/
def affFills (n : Nat) (a : AAff) (pr : FfiAne.Program) : List FillSpec :=
  [halfFill B (a.cout * a.cin) (pr.ins.getD 0 0) 0, halfFill B (a.cin * n) (pr.ins.getD 1 0) 1]

/-- **The splits** at a forward of `n` rows. -/
def netSplit (n : Nat) : AKey → Option SplitSpec
  | .mlpOut p => do
    let b ← bucketAt D n
    let l ← b.layers[p]?
    let (_, pr) ← FfiAne.program? B l.mlp.create
    pure ⟨p, bif aneAttn p then 4 else 5, pr, mlpFills B c n l.mlp pr, half B pr.out, n, 5120⟩
  | .linOut p j => do
    let b ← bucketAt D n
    let l ← b.layers[p]?
    let a ← l.aff.lookup j
    let (_, pr) ← FfiAne.program? B a.create
    pure ⟨p, j, pr, affFills B n a pr, half B pr.out, n, a.cout⟩
  | _ => none

def linT (x : ALin) : LinKey → Tensor
  | .w => x.w
  | .scales => x.scales
  | .biases => x.biases

def mlpT (m : AMlp) : MlpKey → Option Tensor
  | .gateCodes => some m.rgate.codes
  | .gateScales => some m.rgate.scales
  | .upCodes => some m.rup.codes
  | .upScales => some m.rup.scales
  | .downCodes => some m.rdown.codes
  | .downScales => some m.rdown.scales
  | .norm => none

/-- **The construction-time inputs** at a forward of `n` rows. -/
def netInputs (n : Nat) : AKey → Option Value
  | .part p j hd l => do
    let b ← bucketAt D n
    let L ← b.layers[p]?
    let a ← L.aff.lookup j
    pure (headerValues c (linT (bif hd then a.head else a.rest) l))
  | .mlpRest p m => do
    let b ← bucketAt D n
    let L ← b.layers[p]?
    (mlpT L.mlp m).map (headerValues c)
  | _ => none

/-- **The Neural Engine side**, the surfaces after the load `init`. -/
def aneNetOf (init : Nat → Surface) : AneNet := ⟨netSplit D B c, netInputs D c, init⟩

end

theorem netSplit_keys {D : List ABucket} {B : FfiAne.St} {c : Nat → Nat → Nat} {n : Nat} {k : AKey} {sp : SplitSpec}
    (h : netSplit D B c n k = some sp) : rbLayer k ≠ none := by
  cases k <;> simp_all [netSplit, rbLayer]

/-! ## Buckets and kinds -/

theorem ranges_cover {n : Nat} (h1 : 224 ≤ n) (h2 : n ≤ 2048) : ∃ r ∈ aneRangesT, r.1 ≤ n ∧ n ≤ r.2 := by
  have h : aneRangesT.any (fun r => Nat.ble r.1 n && Nat.ble n r.2) = true := by
    simp only [aneRangesT, List.any_cons, List.any_nil, Bool.or_false, Bool.or_eq_true, Bool.and_eq_true, Nat.ble_eq]
    omega
  obtain ⟨r, hr, e⟩ := List.any_eq_true.1 h
  simp only [Bool.and_eq_true, Nat.ble_eq] at e
  exact ⟨r, hr, e⟩

theorem range_class {r : Nat × Nat} (hr : r ∈ aneRangesT) {n : Nat} (h1 : r.1 ≤ n) (h2 : n ≤ r.2) :
    (n ≤ 512 ↔ r.2 ≤ 512) ∧ (n ≤ 704 ↔ r.2 ≤ 704) ∧ (n ≤ 768 ↔ r.2 ≤ 768) ∧ (768 ≤ r.2 ↔ 704 < n) := by
  simp only [aneRangesT, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp only at h1 h2 ⊢ <;> omega

/-- The bucket of a forward of 224–2048 rows: it holds `n`, its kinds are `n`'s. -/
theorem bucketAt_of {D : List ABucket} (hR : D.map (fun b => (b.lo, b.rows)) = aneRangesT) {n : Nat}
    (h1 : 224 ≤ n) (h2 : n ≤ 2048) :
    ∃ b, bucketAt D n = some b ∧ b ∈ D ∧ n ≤ b.rows ∧ (n ≤ 512 ↔ b.rows ≤ 512) ∧ (n ≤ 704 ↔ b.rows ≤ 704) ∧
      (n ≤ 768 ↔ b.rows ≤ 768) ∧ (768 ≤ b.rows ↔ 704 < n) := by
  obtain ⟨r, hr, r1, r2⟩ := ranges_cover h1 h2
  rw [← hR] at hr
  obtain ⟨b0, hb0, e⟩ := List.mem_map.1 hr
  have hs : (bucketAt D n).isSome := by
    unfold bucketAt
    refine List.find?_isSome.2 ⟨b0, hb0, ?_⟩
    rw [← e] at r1 r2
    simp only [Bool.and_eq_true, Nat.ble_eq]
    exact ⟨r1, r2⟩
  obtain ⟨b, hb⟩ := Option.isSome_iff_exists.1 hs
  have hp := List.find?_some hb
  have hm := List.mem_of_find?_eq_some hb
  simp only [Bool.and_eq_true, Nat.ble_eq] at hp
  have hr' : (b.lo, b.rows) ∈ aneRangesT := by
    rw [← hR]
    exact List.mem_map_of_mem hm
  exact ⟨b, hb, hm, hp.2, range_class hr' hp.1 hp.2⟩

theorem rest_eq {n rows : Nat} (h : n ≤ 768 ↔ rows ≤ 768) : aneRestOf n = restOf rows := by
  unfold aneRestOf restOf
  by_cases hn : n ≤ 768
  · simp [hn, h.mp hn]
  · have : ¬ rows ≤ 768 := fun hr => hn (h.mpr hr)
    simp [hn, this]

theorem delta_split {n p j nA : Nat} (ha : aneAttn p = false) (h : (aneKindsOf n).delta j = .split nA) :
    704 < n ∧ j ∈ aneSites p ∧ nA = aneWidth p j := by
  unfold aneKindsOf at h
  by_cases h1 : n ≤ 512
  · simp only [h1, ite_true, aneSmallK] at h
    split at h <;> cases h
  by_cases h2 : n ≤ 704
  · simp only [h1, h2, ite_true, ite_false, aneDenseK, aneSmallK] at h
    split at h <;> cases h
  simp only [h1, h2, ite_false, aneAffineK] at h
  refine ⟨by omega, ?_⟩
  split at h
  · cases h; subst_vars; simp [aneSites, aneWidth, ha]
  split at h
  · cases h; subst_vars; simp [aneSites, aneWidth, ha]
  split at h
  · cases h; subst_vars; simp [aneSites, aneWidth, ha]
  cases h

theorem attn_split {n p j nA : Nat} (ha : aneAttn p = true) (h : (aneKindsOf n).attn j = .split nA) :
    704 < n ∧ j ∈ aneSites p ∧ nA = aneWidth p j := by
  unfold aneKindsOf at h
  by_cases h1 : n ≤ 512
  · simp only [h1, ite_true, aneSmallK] at h
    split at h <;> cases h
  by_cases h2 : n ≤ 704
  · simp only [h1, h2, ite_true, ite_false, aneDenseK] at h
    cases h
  simp only [h1, h2, ite_false, aneAffineK] at h
  refine ⟨by omega, ?_⟩
  split at h
  · cases h; subst_vars; simp [aneSites, aneWidth, ha]
  split at h
  · cases h; subst_vars; simp [aneSites, aneWidth, ha]
  cases h

theorem projSplit_split {k : AneProj} (h : projSplit k = true) : ∃ nA, k = .split nA := by
  cases k <;> simp_all [projSplit]

theorem lookup_of_map {l : List (Nat × AAff)} {js : List Nat} (h : l.map Prod.fst = js) {j : Nat} (hj : j ∈ js) :
    ∃ a, l.lookup j = some a ∧ (j, a) ∈ l := by
  subst h
  induction l with
  | nil => simp at hj
  | cons x l ih =>
    obtain ⟨j', a'⟩ := x
    by_cases e : j = j'
    · subst e
      exact ⟨a', by simp [List.lookup], by simp⟩
    · simp only [List.map_cons, List.mem_cons, e, false_or] at hj
      obtain ⟨a, h1, h2⟩ := ih hj
      refine ⟨a, ?_, List.mem_cons_of_mem _ h2⟩
      have : (j == j') = false := by simpa using e
      simp [List.lookup, this, h1]

/-! ## The splits -/

theorem foldr_one (x : Nat) : [x].foldr (· * ·) 1 = x := by simp

theorem expand_rm (R bits : Nat) : expandCodes R bits 0 = [R, 160 * bits] := rfl

theorem mlp_split {D : List ABucket} {B : FfiAne.St} {c : Nat → Nat → Nat} {b : ABucket} {l : ALayer} {L : LayS}
    {n p : Nat} (hb : bucketAt D n = some b) (hn : n ≤ b.rows) (hl : b.layers[p]? = some l)
    (hm : MlpOk B b.rows L c l.mlp) :
    ∃ sp, netSplit D B c n (.mlpOut p) = some sp ∧ SplitOk n p (bif aneAttn p then 4 else 5) 5120 [5120 * n] sp := by
  obtain ⟨q, pr, hq, hp⟩ := hm.prog
  have hh := hp.holds
  simp only [List.length_cons, List.length_nil] at hh
  refine ⟨⟨p, bif aneAttn p then 4 else 5, pr, mlpFills B c n l.mlp pr, half B pr.out, n, 5120⟩,
    by simp [netSplit, hb, hl, hq], rfl, rfl, rfl, rfl, ?_, ?_, ?_⟩
  · exact Nat.le_trans (Nat.mul_le_mul_right 5120 hn) hp.out
  · exact hp.ins.trans hp.bytes.symm
  · have hroute := hm.route
    have trel : ∀ bits sid, (bits = 2 ∨ bits = 3 ∨ bits = 4) → l.mlp.channels * 5120 ≤ half B sid →
        ∀ t : ATrel, t.bits = bits → ((headerValues c t.codes).dtype = .uint32 ∧
          (headerValues c t.codes).shape = expandCodes 17408 bits 0) →
        ((headerValues c t.scales).dtype = .float16 ∧ (headerValues c t.scales).shape = [17408]) →
        FillOk [5120 * n] (trelFill B c .trellisFill l.mlp.channels t sid) := by
      intro bits sid hbits hsid t ht hc hs
      refine ⟨rfl, Or.inl ⟨l.mlp.channels, bits, _, _, rfl, by rw [trelFill, ht], ⟨hroute, hbits⟩, rfl, ?_, hs, ?_⟩⟩
      · rw [← expand_rm]; exact hc
      · rw [trelFill, foldr_one]; exact hsid
    intro f hf
    simp only [mlpFills, List.mem_cons, List.not_mem_nil, or_false] at hf
    rcases hf with rfl | rfl | rfl | rfl
    · rcases hm.down with ⟨hk, _, hb3, hc, hs⟩ | ⟨hk, hbd, hc, hs⟩
      · rw [hk]
        refine ⟨rfl, Or.inr (Or.inl ⟨l.mlp.channels, _, _, rfl, by rw [trelFill, hb3], hroute, rfl, hc, hs, ?_⟩)⟩
        rw [trelFill, foldr_one]; exact hh 0 (by omega)
      · rw [hk]
        exact trel _ _ hm.db (hh 0 (by omega)) _ hbd hc hs
    · exact trel _ _ hm.gb (hh 1 (by omega)) _ hm.gate.1 hm.gate.2.1 hm.gate.2.2
    · exact trel _ _ hm.ub (hh 2 (by omega)) _ hm.up.1 hm.up.2.1 hm.up.2.2
    · refine ⟨rfl, Or.inr (Or.inr ⟨0, 5120 * n, rfl, rfl, rfl, rfl, ?_⟩)⟩
      rw [halfFill, foldr_one]
      exact Nat.le_trans (Nat.mul_le_mul_left 5120 hn) (hh 3 (by omega))

theorem aff_split {D : List ABucket} {B : FfiAne.St} {c : Nat → Nat → Nat} {b : ABucket} {l : ALayer} {L : LayS}
    {n p j : Nat} (hb : bucketAt D n = some b) (hn : n ≤ b.rows) (hl : b.layers[p]? = some l)
    (hL : LayerOk B b.rows L p c l) (h768 : 768 ≤ b.rows) (hj : j ∈ aneSites p) :
    ∃ sp, netSplit D B c n (.linOut p j) = some sp ∧
      SplitOk n p j (aneWidth p j) [aneWidth p j * (L.lins.getD j noLin).cols, (L.lins.getD j noLin).cols * n] sp := by
  obtain ⟨hmap, hall⟩ := hL.aff h768
  obtain ⟨a, ha, hmem⟩ := lookup_of_map hmap hj
  have hA := hall _ hmem
  obtain ⟨q, pr, hq, hp⟩ := hA.prog
  have hh := hp.holds
  simp only [List.length_cons, List.length_nil] at hh
  refine ⟨⟨p, j, pr, affFills B n a pr, half B pr.out, n, a.cout⟩, by simp [netSplit, hb, hl, ha, hq],
    rfl, rfl, rfl, hA.cout, ?_, ?_, ?_⟩
  · rw [hA.cout]
    exact Nat.le_trans (Nat.mul_le_mul_right _ hn) hp.out
  · exact hp.ins.trans hp.bytes.symm
  · intro f hf
    simp only [affFills, List.mem_cons, List.not_mem_nil, or_false] at hf
    rcases hf with rfl | rfl
    · refine ⟨rfl, Or.inr (Or.inr ⟨0, a.cout * a.cin, rfl, rfl, rfl, by rw [hA.cout, hA.cin]; rfl, ?_⟩)⟩
      rw [halfFill, foldr_one, hA.cout, hA.cin]
      exact hh 0 (by omega)
    · refine ⟨rfl, Or.inr (Or.inr ⟨1, a.cin * n, rfl, rfl, rfl, by rw [hA.cin]; rfl, ?_⟩)⟩
      rw [halfFill, foldr_one, hA.cin]
      exact Nat.le_trans (Nat.mul_le_mul_left _ hn) (hh 1 (by omega))

/-! ## The construction-time inputs -/

theorem aff_parts {D : List ABucket} {B : FfiAne.St} {c : Nat → Nat → Nat} {init : Nat → Surface} {b : ABucket}
    {l : ALayer} {L : LayS} {n p j : Nat} (hb : bucketAt D n = some b) (hl : b.layers[p]? = some l)
    (hL : LayerOk B b.rows L p c l) (h768 : 768 ≤ b.rows) (hj : j ∈ aneSites p) :
    PartsW (aneNetOf D B c init) n p j (L.lins.getD j noLin) (aneWidth p j) := by
  obtain ⟨hmap, hall⟩ := hL.aff h768
  obtain ⟨a, ha, hmem⟩ := lookup_of_map hmap hj
  have hA := hall _ hmem
  have hin : ∀ hd lk, (netEnv (aneNetOf D B c init) n).inputs (.part p j hd lk) =
      some (headerValues c (linT (bif hd then a.head else a.rest) lk)) := by
    intro hd lk
    simp [netEnv, aneNetOf, netInputs, hb, hl, ha]
  exact ⟨⟨⟨_, hin true .w, hA.head.1⟩, ⟨_, hin true .scales, hA.head.2.1⟩, ⟨_, hin true .biases, hA.head.2.2⟩⟩,
    ⟨⟨_, hin false .w, hA.rest.1⟩, ⟨_, hin false .scales, hA.rest.2.1⟩, ⟨_, hin false .biases, hA.rest.2.2⟩⟩⟩

theorem mlp_rest {D : List ABucket} {B : FfiAne.St} {c : Nat → Nat → Nat} {init : Nat → Surface} {b : ABucket}
    {l : ALayer} {L : LayS} {n p : Nat} (hb : bucketAt D n = some b) (hl : b.layers[p]? = some l)
    (hm : MlpOk B b.rows L c l.mlp) (hr : n ≤ 768 ↔ b.rows ≤ 768) :
    MlpRestW (netEnv (aneNetOf D B c init) n) L.mlp (aneRestOf n) (.mlpRest p) := by
  have hin : ∀ mk t, mlpT l.mlp mk = some t →
      (netEnv (aneNetOf D B c init) n).inputs (.mlpRest p mk) = some (headerValues c t) := by
    intro mk t ht
    simp [netEnv, aneNetOf, netInputs, hb, hl, ht]
  rw [rest_eq hr]
  exact ⟨by unfold restOf; split <;> simp, hm.gb, hm.ub, hm.db,
    ⟨_, hin .gateCodes _ rfl, by rw [← expand_rm]; exact hm.rgate.2.1⟩, ⟨_, hin .gateScales _ rfl, hm.rgate.2.2⟩,
    ⟨_, hin .upCodes _ rfl, by rw [← expand_rm]; exact hm.rup.2.1⟩, ⟨_, hin .upScales _ rfl, hm.rup.2.2⟩,
    ⟨_, hin .downCodes _ rfl, hm.rdown.2.1⟩, ⟨_, hin .downScales _ rfl, hm.rdown.2.2⟩⟩

/-! ## A layer -/

theorem dLay_sum (w : DeltaWeights) (cv rc : Option Value) (j : Nat) (hj : j < 5) :
    dLay (deltaLayout w cv rc) j = (laySum (.delta w)).lins.getD j noLin := by
  match j, hj with
  | 0, _ => rfl
  | 1, _ => rfl
  | 2, _ => rfl
  | 3, _ => rfl
  | 4, _ => rfl

theorem aLay_sum (w : AttentionWeights) (kb vb : Option Value) (j : Nat) (hj : j < 4) :
    aLay (attnLayout w kb vb) j = (laySum (.attention w)).lins.getD j noLin := by
  match j, hj with
  | 0, _ => rfl
  | 1, _ => rfl
  | 2, _ => rfl
  | 3, _ => rfl

theorem deltaSite_of {p j : Nat} (ha : aneAttn p = false) (hj : j ∈ aneSites p) : deltaSite j = some j := by
  simp only [aneSites, ha, Bool.cond_false, List.mem_cons, List.not_mem_nil, or_false] at hj
  rcases hj with rfl | rfl | rfl <;> rfl

theorem attnSite_of {p j : Nat} (ha : aneAttn p = true) (hj : j ∈ aneSites p) : attnSite j = some j := by
  simp only [aneSites, ha, Bool.cond_true, List.mem_cons, List.not_mem_nil, or_false] at hj
  rcases hj with rfl | rfl <;> rfl

theorem sites_lt {p j : Nat} (hj : j ∈ aneSites p) : j < 5 := by
  unfold aneSites at hj
  cases h : aneAttn p <;> simp [h] at hj <;> omega

theorem sites_lt4 {p j : Nat} (ha : aneAttn p = true) (hj : j ∈ aneSites p) : j < 4 := by
  simp only [aneSites, ha, Bool.cond_true, List.mem_cons, List.not_mem_nil, or_false] at hj
  omega

/-- **A layer's Neural Engine side** at a forward of 224–2048 rows, when the buckets pass the check. -/
theorem aneNetOf_layer {D : List ABucket} {B : FfiAne.St} {lays : List LayS} (hchk : aneCheck D B lays = true)
    (c : Nat → Nat → Nat) (init : Nat → Surface) {n p : Nat} (h1 : 224 ≤ n) (h2 : n ≤ 2048) (hp : p < 64)
    {s : StageWeights} (hL : lays[p]? = some (laySum s)) (h : Handles) :
    AneNetLayer (aneNetOf D B c init) n p (aneKindsOf n) (aneRestOf n) (stageLayout s h) := by
  obtain ⟨hR, hD⟩ := aneCheck_sound hchk c
  obtain ⟨b, hb, hbD, hn, _, _, c768, caff⟩ := bucketAt_of hR h1 h2
  obtain ⟨_, hlay⟩ := hD b hbD
  obtain ⟨l, L, hl, hL', hok⟩ := hlay p hp
  rw [hL] at hL'
  cases hL'
  have hmlp := hok.mlp
  cases s with
  | delta w =>
    have ha : aneAttn p = false := hok.attn.symm
    obtain ⟨cv, rc, hsl⟩ : ∃ cv rc, stageLayout (.delta w) h = .delta (deltaLayout w cv rc) := by
      cases h with
      | delta cv rc => exact ⟨cv, rc, rfl⟩
      | attention _ _ => exact ⟨none, none, rfl⟩
    rw [hsl]
    refine ⟨?_, ?_, mlp_rest hb hl hmlp c768⟩
    · intro k s' D' sizes hk hs hd
      cases k with
      | linOut p' j =>
        simp only [rbLayer, Option.some.injEq] at hk
        subst hk
        simp only [rbSite] at hs
        split at hs
        · rename_i hps
          obtain ⟨nA, hnA⟩ := projSplit_split hps
          obtain ⟨haff, hj, rfl⟩ := delta_split ha hnA
          rw [deltaSite_of ha hj, Option.some.injEq] at hs
          subst hs
          simp only [rbDim, hnA, Option.some.injEq, Prod.mk.injEq] at hd
          obtain ⟨rfl, rfl⟩ := hd
          rw [dLay_sum w cv rc _ (sites_lt hj)]
          exact aff_split hb hn hl hok (caff.mpr haff) hj
        · cases hs
      | mlpOut p' =>
        simp only [rbLayer, Option.some.injEq] at hk
        subst hk
        simp only [rbSite, Option.some.injEq] at hs
        subst hs
        simp only [rbDim, Option.some.injEq, Prod.mk.injEq] at hd
        obtain ⟨rfl, rfl⟩ := hd
        have := mlp_split (c := c) hb hn hl hmlp
        rwa [ha] at this
      | p _ => simp [rbLayer] at hk
      | part _ _ _ _ => simp [rbLayer] at hk
      | mlpRest _ _ => simp [rbLayer] at hk
    · intro j nA hj hkd
      obtain ⟨haff, hjs, rfl⟩ := delta_split ha hkd
      rw [dLay_sum w cv rc j hj]
      exact aff_parts hb hl hok (caff.mpr haff) hjs
  | attention w =>
    have ha : aneAttn p = true := hok.attn.symm
    obtain ⟨kb, vb, hsl⟩ : ∃ kb vb, stageLayout (.attention w) h = .attention (attnLayout w kb vb) := by
      cases h with
      | attention kb vb => exact ⟨kb, vb, rfl⟩
      | delta _ _ => exact ⟨none, none, rfl⟩
    rw [hsl]
    refine ⟨?_, ?_, mlp_rest hb hl hmlp c768⟩
    · intro k s' D' sizes hk hs hd
      cases k with
      | linOut p' j =>
        simp only [rbLayer, Option.some.injEq] at hk
        subst hk
        simp only [rbSite] at hs
        split at hs
        · rename_i hps
          obtain ⟨nA, hnA⟩ := projSplit_split hps
          obtain ⟨haff, hj, rfl⟩ := attn_split ha hnA
          rw [attnSite_of ha hj, Option.some.injEq] at hs
          subst hs
          simp only [rbDim, hnA, Option.some.injEq, Prod.mk.injEq] at hd
          obtain ⟨rfl, rfl⟩ := hd
          rw [aLay_sum w kb vb _ (sites_lt4 ha hj)]
          exact aff_split hb hn hl hok (caff.mpr haff) hj
        · cases hs
      | mlpOut p' =>
        simp only [rbLayer, Option.some.injEq] at hk
        subst hk
        simp only [rbSite, Option.some.injEq] at hs
        subst hs
        simp only [rbDim, Option.some.injEq, Prod.mk.injEq] at hd
        obtain ⟨rfl, rfl⟩ := hd
        have := mlp_split (c := c) hb hn hl hmlp
        rwa [ha] at this
      | p _ => simp [rbLayer] at hk
      | part _ _ _ _ => simp [rbLayer] at hk
      | mlpRest _ _ => simp [rbLayer] at hk
    · intro j nA hj hkd
      obtain ⟨haff, hjs, rfl⟩ := attn_split ha hkd
      rw [aLay_sum w kb vb j hj]
      exact aff_parts hb hl hok (caff.mpr haff) hjs

end Host.Load.Boot
