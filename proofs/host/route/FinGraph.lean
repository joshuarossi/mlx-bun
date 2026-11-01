import host.route.StepCert
import host.simgraph.compose.Split
import host.sim.compose.a4b.GraphColdInputValue
import host.route.cert.Seg
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (cachesAt CachesBelow Gr)
open Host.Mlx.SimGraph.Mach (routeVal HeldV CacheValuesV refPrompt Vals)
open Host.Mlx.Ffi (NGrow)
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Ts.Sim.Compose (NTrack)
open Host.Ts.Sim.Compose.ColdGraph (coldIds)

/-! # The final forward across POST's entry

POST's entry template collects the final forward's inner nodes, so its sampled cut can't carry the last step's whole graph:
the forward's part is read at the forward's return, the head and sampler's at the sampled cut, and the target keeps both.

* `FinAt`: the step graph's first `K` nodes at target nodes `certT`, with the values of their inputs.
* `memFin`: `FinAt` as a cut's bookkeeping. `certT` is existential, since the entry's template no longer names most of those
  nodes: `Kept` lists the ones it does, and `memFin_after` renames them across a walked map.
* `matches_merge`, `postAt_ofFin`: the two parts make the whole step's match at the sampled cut, and POST's first time. -/

section Merge
variable {κ : Type} [DecidableEq κ]

/-- The carriers of a merge: `certT` below `K`, `certH` from it. -/
def mergeCert (K : Nat) (certT certH : List Nat) : List Nat := certT.take K ++ certH.drop K

theorem certAt_merge_lo {K : Nat} {certT : List Nat} (certH : List Nat) (hT : K ≤ certT.length) {j : Nat} (hj : j < K) :
    certAt (mergeCert K certT certH) j = certAt certT j := by
  unfold certAt mergeCert
  rw [List.getD_eq_getElem?_getD, List.getD_eq_getElem?_getD, List.getElem?_append_left (by simp; omega),
    List.getElem?_take_of_lt hj]

theorem certAt_merge_hi {K : Nat} {certT : List Nat} (certH : List Nat) (hT : K ≤ certT.length) {j : Nat} (hj : K ≤ j) :
    certAt (mergeCert K certT certH) j = certAt certH j := by
  unfold certAt mergeCert
  have hl : (certT.take K).length = K := by simp; omega
  rw [List.getD_eq_getElem?_getD, List.getD_eq_getElem?_getD, List.getElem?_append_right (by omega), hl,
    List.getElem?_drop, show K + (j - K) = j by omega]

theorem nodeOk_congr (G : Nat → Option (RNode Int κ)) {c c' : List Nat} {k : Nat} {e : RNode Int κ}
    (hk : certAt c k = certAt c' k) (hi : ∀ j ∈ e.ins, certAt c j = certAt c' j) : nodeOk G c k e = nodeOk G c' k e := by
  unfold nodeOk
  have hm : e.ins.map (certAt c) = e.ins.map (certAt c') := List.map_congr_left hi
  have ha : e.ins.all (fun j => certAt c j < certAt c k) = e.ins.all (fun j => certAt c' j < certAt c' k) := by
    apply Bool.eq_iff_iff.mpr
    simp only [List.all_eq_true, decide_eq_true_eq]
    constructor
    · intro h j hj
      rw [← hi j hj, ← hk]
      exact h j hj
    · intro h j hj
      rw [hi j hj, hk]
      exact h j hj
  rw [ha, hm, hk]

/-- **The two parts make the whole.** -/
theorem matches_merge (G : Nat → Option (RNode Int κ)) (E : List (RNode Int κ)) (d : κ) (K : Nat) (certT certH : List Nat)
    (hT : K ≤ certT.length) (hF : Matches G (E.take K) certT = true)
    (hH : Matches G (maskSeg d K E.length E) certH = true)
    (hbd : ∀ k e, K ≤ k → E[k]? = some e → ∀ j ∈ e.ins, j < K → certAt certH j = certAt certT j) :
    Matches G E (mergeCert K certT certH) = true := by
  refine List.all_eq_true.mpr fun k hk' => ?_
  have hk : k < E.length := List.mem_range.mp hk'
  rw [List.getElem?_eq_getElem hk]
  dsimp only
  by_cases hkK : k < K
  · have h := List.all_eq_true.mp hF k (List.mem_range.mpr (by rw [List.length_take]; omega))
    rw [List.getElem?_take_of_lt hkK, List.getElem?_eq_getElem hk] at h
    dsimp only at h
    have hlt : ∀ j ∈ E[k].ins, j < k := by
      intro j hj
      simp only [nodeOk, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at h
      exact h.1.1 j hj
    rw [nodeOk_congr G (certAt_merge_lo certH hT hkK)
      (fun j hj => certAt_merge_lo certH hT (by have := hlt j hj; omega))]
    exact h
  · have h := List.all_eq_true.mp hH k (List.mem_range.mpr (by rw [maskSeg_length]; exact hk))
    have hm : (maskSeg d K E.length E)[k]? = some E[k] := by
      simp [maskSeg, Nat.le_of_not_lt hkK, hk]
    rw [hm] at h
    dsimp only at h
    rw [nodeOk_congr G (certAt_merge_hi certH hT (Nat.le_of_not_lt hkK)) (fun j hj => ?_)]
    · exact h
    · by_cases hjK : j < K
      · rw [certAt_merge_lo certH hT hjK, hbd k _ (Nat.le_of_not_lt hkK) (List.getElem?_eq_getElem hk) j hj hjK]
      · exact certAt_merge_hi certH hT (Nat.le_of_not_lt hjK)

end Merge

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- **The step graph's first `K` nodes at target nodes `certT`.** The match is at every native growth of `x`. -/
structure FinAt (kind : Nat → Option Compiled) (tab : List F64) (hs : List Handles) (time tok K : Nat) (certT : List Nat)
    (x : Host.Mlx.Ffi.St) : Prop where
  seg : ∀ y, NGrow x y → Matches (Gr tab y)
    ((stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs time).1.take K) certT = true
  len : K ≤ certT.length
  below : ∀ k, k < K → certAt certT k < x.nnext
  held : ∀ k e key v, k < K →
    (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs time).1[k]? = some e →
    e.prim = .input key →
    (stepEnvWithIds env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) (coldIds tok) hs).inputs key =
      some v →
    routeVal P KR env kind (fun _ => none) tab x (certAt certT k) = some v

/-- **After the final forward**, before POST's first time: the reference at `L - 1`, and that step's forward part at the
target. -/
def memFin (Kept : Nat → List (Nat × Nat)) (Kn : Nat → Nat) (L : Nat) (x : SegInst FF) : Prop :=
  L = π.length → ∃ kind, ∀ tab, Host.Ts.Sim.CSrv.Le x.C ⟨tab⟩ → ∃ tok hs certT,
    refPrompt P KR NE KR.inPlace net env π tab (L - 1) = some (tok, hs) ∧
    FinAt P KR env kind tab hs (L - 1) tok (Kn L) certT (mlxOf x.t.ffi) ∧
    Base P KR env (routeVs P KR env kind) tab x.t ∧
    (∀ q ∈ Kept L, certAt certT q.1 = x.M.node q.2) ∧
    (2 ≤ L → CapsFor 256 (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) hs)

variable {P KR NE net env π}

theorem FinAt.grow {kind : Nat → Option Compiled} {tab : List F64} {hs : List Handles} {time tok K : Nat} {certT : List Nat}
    {x y : Host.Mlx.Ffi.St} (h : FinAt P KR env kind tab hs time tok K certT x) (hok : (routeVs P KR env kind).Ok x)
    (hg : NGrow x y) : FinAt P KR env kind tab hs time tok K certT y where
  seg z hz := h.seg z (hg.trans hz)
  len := h.len
  below k hk := Nat.lt_of_lt_of_le (h.below k hk) hg.nnext
  held k e key v hk he hp hv := (routeVs P KR env kind).val_grow hok hg _ _ (h.below k hk) (h.held k e key v hk he hp hv)

/-- A stretch keeps it. -/
theorem memFin_keep {Kept : Nat → List (Nat × Nat)} {Kn : Nat → Nat} (L : Nat) (x y : SegInst FF) (h : NTrack x y)
    (hm : memFin P KR NE net env π Kept Kn L x) : memFin P KR NE net env π Kept Kn L y := by
  intro hL
  obtain ⟨kind, hk⟩ := hm hL
  refine ⟨kind, fun tab hC => ?_⟩
  obtain ⟨tok, hs, certT, hR, hF, hb, hK, hc⟩ := hk tab (h.server.trans hC)
  refine ⟨tok, hs, certT, hR, hF.grow hb.ok h.nodes, hb.grow h.nodes h.tokens, fun q hq => ?_, hc⟩
  rw [h.map]
  exact hK q hq

/-- **A renaming keeps it**: the nodes the new template names are the old ones under a walked map. -/
theorem memFin_after {Kept Kept' : Nat → List (Nat × Nat)} {Kn : Nat → Nat} (L : Nat) (x y : SegInst FF)
    (ht : y.t = x.t) (hC : y.C = x.C)
    (hkept : ∀ q ∈ Kept' L, ∃ c, (q.1, c) ∈ Kept L ∧ y.M.node q.2 = x.M.node c)
    (hm : memFin P KR NE net env π Kept Kn L x) : memFin P KR NE net env π Kept' Kn L y := by
  intro hL
  obtain ⟨kind, hk⟩ := hm hL
  refine ⟨kind, fun tab hle => ?_⟩
  obtain ⟨tok, hs, certT, hR, hF, hb, hK, hc⟩ := hk tab (hC ▸ hle)
  refine ⟨tok, hs, certT, hR, ht ▸ hF, ht ▸ hb, fun q hq => ?_, hc⟩
  obtain ⟨c, hc, he⟩ := hkept q hq
  rw [he]
  exact hK _ hc

/-! ## From the certificates -/

section Check
variable {δ κ : Type} [DecidableEq δ] [DecidableEq κ]
open Host.Route.Cert (headOk tailOk)

/-- A check of the head's nodes is a match of the expected graph's prefix. -/
theorem matchesD_head (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ)) (K : Nat) (cert : List Nat)
    (h : checkNodesD (headOk K G cert) 0 E = true) : MatchesD G (E.take K) cert = true := by
  refine List.all_eq_true.mpr fun k hk' => ?_
  have hk : k < (E.take K).length := List.mem_range.mp hk'
  have hkK : k < K := by rw [List.length_take] at hk; omega
  have hkE : k < E.length := by rw [List.length_take] at hk; omega
  rw [List.getElem?_take_of_lt hkK, List.getElem?_eq_getElem hkE]
  have hc := checkNodesD_get (headOk K G cert) E 0 h (List.getElem?_eq_getElem hkE)
  simp only [headOk, Nat.zero_add, decide_eq_true hkK, Bool.not_true, Bool.false_or] at hc
  exact hc

/-- A check of the tail's nodes is a match of the expected graph with its head masked. -/
theorem matchesD_tail (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ)) (d : κ) (K : Nat) (cert : List Nat)
    (h : checkNodesD (tailOk K G cert) 0 E = true) : MatchesD G (maskSeg d K E.length E) cert = true := by
  refine List.all_eq_true.mpr fun k hk' => ?_
  have hk : k < E.length := by simpa using List.mem_range.mp hk'
  have hc := checkNodesD_get (tailOk K G cert) E 0 h (List.getElem?_eq_getElem hk)
  rw [Nat.zero_add] at hc
  by_cases hkK : K ≤ k
  · have hm : (maskSeg d K E.length E)[k]? = some E[k] := by simp [maskSeg, hkK, hk]
    rw [hm]
    simpa only [tailOk, decide_eq_true hkK, Bool.not_true, Bool.false_or] using hc
  · have hm : (maskSeg d K E.length E)[k]? = some ⟨.input d, []⟩ := by simp [maskSeg, hkK, hk]
    rw [hm]
    simp [nodeOkD, isInputD]

end Check

theorem kernelName_grow {x y : Ffi.St} (hg : NGrow x y) (S : KernelSources) (k : Nat) (name : List Char)
    (hk : kernelName? S x k = some name) : kernelName? S y k = some name := by
  unfold kernelName? at hk ⊢
  cases ho : x.obj? k with
  | none => rw [ho] at hk; cases hk
  | some o =>
    rw [ho] at hk
    cases o with
    | kernel nm sc hd a b =>
      rw [show y.obj? k = some (.kernel nm sc hd a b) from hg.kernels k _ ho ⟨nm, sc, hd, a, b, rfl⟩]
      exact hk
    | _ => cases hk

/-- Growth keeps the graph's nodes below the counter. -/
theorem ffiGraph_grow {κ : Type} {x y : Ffi.St} (N : Nums Int) (S : KernelSources) (hg : NGrow x y) (j : Nat) (nd : RNode Int κ)
    (hj : j < x.nnext) (h : ffiGraph N S x j = some nd) : ffiGraph N S y j = some nd := by
  unfold ffiGraph at h ⊢
  obtain ⟨n, hn, hr⟩ := Option.bind_eq_some_iff.mp h
  rw [hg.nodes j hj, hn, Option.bind_some]
  unfold resolveNode at hr ⊢
  obtain ⟨q, hq, rfl⟩ := Option.map_eq_some_iff.mp hr
  rw [resolvePrim_mono N (kernelName_grow hg S) _ _ _ q hq]
  rfl

/-- An embedding in a target's graph is one in its growth, when the images are below its counter. -/
theorem embeds_grow {κ : Type} {σ cl : Nat → Nat} {G : Nat → Option (RNode Int κ)} {x y : Ffi.St} {N : Nums Int} {S : KernelSources}
    (h : Embeds σ cl G (ffiGraph N S x)) (hb : ∀ i r, G i = some r → σ i < x.nnext) (hg : NGrow x y) :
    Embeds σ cl G (ffiGraph N S y) where
  node i r hr := ffiGraph_grow N S hg _ _ (hb i r hr) (h.node i r hr)
  order := h.order

/-- **POST's first held time at the sampled cut**, from the forward's part at the target and the head's here. -/
theorem postAt_ofFin (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) {kind : Nat → Option Compiled}
    {tab : List F64} {y : St FF.S} {σ toks : Nat → Nat} {Cr : List (Option Nat × Option Nat)} (hπ : 1 ≤ π.length)
    {tok t K : Nat} {hs hs' : List Handles} {certT : List Nat}
    (hR0 : refPrompt P KR NE KR.inPlace net env π tab (π.length - 1) = some (tok, hs))
    (hR1 : refPrompt P KR NE KR.inPlace net env π tab (π.length + 0) = some (t, hs')) (htok : tok < 2 ^ 31)
    (hF : FinAt P KR env kind tab hs (π.length - 1) tok K certT (mlxOf y.ffi))
    (hb : Base P KR env (routeVs P KR env kind) tab y)
    (hsh : ShapesOk (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) hs)
    (hcaps : CapsFor (Host.Ts.Sim.capL (π.length + 0))
      (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) hs')
    (certH : List Nat)
    (hH : Matches (Gr tab (mlxOf y.ffi))
      (maskSeg .tokenIds K (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs (π.length - 1)).1.length
        (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs (π.length - 1)).1) certH = true)
    (hbd : ∀ k e, K ≤ k → (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs (π.length - 1)).1[k]? = some e →
      ∀ j ∈ e.ins, j < K → certAt certH j = certAt certT j)
    (hinH : ∀ k e key v, K ≤ k → (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs (π.length - 1)).1[k]? = some e →
      e.prim = .input key →
      (stepEnvWithIds env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) (coldIds tok) hs).inputs key = some v →
      routeVal P KR env kind (fun _ => none) tab (mlxOf y.ffi) (certAt certH k) = some v)
    (hKo : K ≤ (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs (π.length - 1)).2.1)
    (hout : σ (toks 0) = certAt certH (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs (π.length - 1)).2.1)
    (hCr : (cachesAt σ Cr).map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs (π.length - 1)).2.2.map
        (fun (a, b) => (some (certAt certT a), some (certAt certT b))))
    (hKc : ∀ q ∈ (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs (π.length - 1)).2.2, q.1 < K ∧ q.2 < K)
    (hoB : σ (toks 0) < (mlxOf y.ffi).nnext) (hcB : CachesBelow (cachesAt σ Cr) (mlxOf y.ffi).nnext) :
    PostAt P.toMlxContract KR.toKernelContract env (routeVs P KR env kind) (refPrompt P KR NE KR.inPlace net env π)
      π.length tab 0 σ toks Cr (mlxOf y.ffi) := by
  have hl := firstPipeline_loaded P.toMlxContract KR.toKernelContract env tab leaves typed
  refine postAt_ofStep P env hπ hR0 hR1 hb (coldIds tok)
    (bufferEmbed_eq _ _ _ _ _ _ (Host.Ts.Sim.Compose.ColdGraph.coldIds_buffer tok htok) hl.embedding.words.1 hl.embedding.words.2.1
      hl.embedding.scales.2.1 hl.embedding.biases.2.1) hl.finalNorm.2.1 hsh hcaps (mergeCert K certT certH)
    (matches_merge _ _ .tokenIds K certT certH hF.len (hF.seg _ (NGrow.refl _)) hH hbd) ?_ ?_ ?_ hoB hcB
  · intro k e key v he hp hv
    by_cases hkK : k < K
    · rw [certAt_merge_lo certH hF.len hkK]
      exact hF.held k e key v hkK he hp hv
    · rw [certAt_merge_hi certH hF.len (Nat.le_of_not_lt hkK)]
      exact hinH k e key v (Nat.le_of_not_lt hkK) he hp hv
  · rw [certAt_merge_hi certH hF.len hKo]
    exact hout
  · rw [hCr]
    refine List.map_congr_left fun q hq => ?_
    obtain ⟨h1, h2⟩ := hKc q hq
    obtain ⟨a, b⟩ := q
    simp only at h1 h2 ⊢
    rw [certAt_merge_lo certH hF.len h1, certAt_merge_lo certH hF.len h2]

end Host.Route.PrefGraph
