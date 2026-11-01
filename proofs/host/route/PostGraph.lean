import host.route.PrefStep
import host.simgraph.world.MachAtV
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (TplInputs cachesAt CachesBelow)
open Host.Mlx.SimGraph.Mach (MRef Vals CacheValuesV ReadbackValuesV ForwardAtV)

/-! # POST's graph side

Between the prefill's exit (`ExitG`) and the decode cut (`GIMV` at iteration 1) the program samples the token of time
`L`, reads it, and runs two decode steps without entering the loop: the first token is yielded before its own
forward, so the second readback of POST reads the same memoized node and pops nothing.

`PostAt j`: the target holds the reference through time `L + j`: the sampled token of each time at its carrier
`toks k`, the handles of time `L + j` at the carriers `Cr`. It reads the node map only at its carriers.

* `PostAt.zero`: the head and sampler after the final forward (`ExitG`).
* `PostAt.grow`, `PostAt.congr`: a stretch that pops nothing, a renaming of carriers.
* `PostAt.read`: the readback of a sampled token.
* `PostAt.next`: one decode forward and sampler.
* `PostAt.toGIMV`: the decode cut's invariant, at `PostAt 2`.
* `PostAt.toGFV`, `PostAt.forward`: the short paths' goals.
* `PostAt.fwdStep`: the decode forward's certificate (`CaseFwdAtV`) at the row's end, the premise of `PostAt.next`.
* `PostG`: `PostAt` as a cut's bookkeeping, at every table above the server; `PostG.glue`, `PostG.congr`. -/

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey) (Vs : Vals)

/-- **The target holds the reference through time `L + j`.** -/
structure PostAt (R : MRef) (L : Nat) (tab : List F64) (j : Nat) (σ : Nat → Nat) (toks : Nat → Nat)
    (Cr : List (Option Nat × Option Nat)) (x : Host.Mlx.Ffi.St) : Prop where
  ok : Vs.Ok x
  hist : ∀ k, k ≤ j → ∃ cs, ForwardAtV (Vs.val tab x) R tab (L + k) cs (σ (toks k)) ∧ σ (toks k) < x.nnext ∧
    CachesBelow cs x.nnext
  cur : ∃ tok hs, R tab (L + j) = some (tok, hs) ∧ CacheValuesV (Vs.val tab x) (cachesAt σ Cr) hs ∧
    CapsFor (Sim.capL (L + j)) (stageWeights (weights (firstValues M K env tab))) hs ∧
    CachesBelow (cachesAt σ Cr) x.nnext
  params : ∀ t ∈ parameterTensors parameterChoice,
    Vs.val tab x t.node = some (firstValues M K env tab t) ∧ t.node < x.nnext
  reads : ReadbackValuesV (Vs.val tab x) (CSrv.val ⟨tab⟩) x.items ∧ ∀ k, x.nnext ≤ k → x.items.get k = none

variable {M K env Vs} {R : MRef} {L : Nat} {tab : List F64} {j : Nat} {σ σ' : Nat → Nat} {toks toks' : Nat → Nat}
  {Cr Cr' : List (Option Nat × Option Nat)} {x y : Host.Mlx.Ffi.St}

/-- A renaming of the carriers keeps it. -/
theorem PostAt.congr (h : PostAt M K env Vs R L tab j σ toks Cr x) (hσ : ∀ k, k ≤ j → σ' (toks' k) = σ (toks k))
    (hc : cachesAt σ' Cr' = cachesAt σ Cr) : PostAt M K env Vs R L tab j σ' toks' Cr' x where
  ok := h.ok
  hist k hk := by rw [hσ k hk]; exact h.hist k hk
  cur := by rw [hc]; exact h.cur
  params := h.params
  reads := h.reads

private theorem hist_grow (h : PostAt M K env Vs R L tab j σ toks Cr x) (hg : Host.Mlx.Ffi.NGrow x y) {k : Nat}
    (hk : k ≤ j) : ∃ cs, ForwardAtV (Vs.val tab y) R tab (L + k) cs (σ (toks k)) ∧ σ (toks k) < y.nnext ∧
      CachesBelow cs y.nnext := by
  obtain ⟨cs, hf, ho, hc⟩ := h.hist k hk
  exact ⟨cs, forwardAtV_grow Vs hf h.ok hg ho hc, Nat.lt_of_lt_of_le ho hg.nnext,
    fun c hc' t ht => Nat.lt_of_lt_of_le (hc c hc' t ht) hg.nnext⟩

private theorem params_grow (h : PostAt M K env Vs R L tab j σ toks Cr x) (hg : Host.Mlx.Ffi.NGrow x y) :
    ∀ t ∈ parameterTensors parameterChoice,
      Vs.val tab y t.node = some (firstValues M K env tab t) ∧ t.node < y.nnext := fun t ht =>
  ⟨Vs.val_grow h.ok hg _ _ (h.params t ht).2 (h.params t ht).1, Nat.lt_of_lt_of_le (h.params t ht).2 hg.nnext⟩

/-- **A stretch that pops nothing keeps it.** -/
theorem PostAt.grow (h : PostAt M K env Vs R L tab j σ toks Cr x) (hg : Host.Mlx.Ffi.NGrow x y)
    (ht : y.tokens = x.tokens) : PostAt M K env Vs R L tab j σ toks Cr y where
  ok := Vs.ok_grow h.ok hg
  hist _ hk := hist_grow h hg hk
  cur := by
    obtain ⟨tok, hs, hR, hc, hcaps, hb⟩ := h.cur
    exact ⟨tok, hs, hR, hc.mono fun c hc' v hv u hu => Vs.val_grow h.ok hg _ _ (hb c hc' v hv) hu, hcaps,
      fun c hc' t ht' => Nat.lt_of_lt_of_le (hb c hc' t ht') hg.nnext⟩
  params := params_grow h hg
  reads := by
    have hi := items_of_tokens hg ht
    refine ⟨fun k v hv => ?_, fun k hk => ?_⟩
    · rw [hi] at hv
      have hlt : k < x.nnext := by
        refine Classical.byContradiction fun hc => ?_
        rw [h.reads.2 k (Nat.le_of_not_lt hc)] at hv
        cases hv
      obtain ⟨token, htk, ⟨r, hr, hit⟩, hn⟩ := h.reads.1 k v hv
      exact ⟨token, htk, ⟨r, Vs.val_grow h.ok hg _ _ hlt hr, hit⟩, hn⟩
    · rw [hi]
      exact h.reads.2 k (Nat.le_trans hg.nnext hk)

/-- **The readback of the sampled token of time `L + k`.** Its node's new item is that token's value; every other
item is unchanged. -/
theorem PostAt.read (h : PostAt M K env Vs R L tab j σ toks Cr x) (hg : Host.Mlx.Ffi.NGrow x y) {k0 : Nat} (hk0 : k0 ≤ j)
    (hnew : ∀ k v, y.items.get k = some v → x.items.get k = some v ∨ (k = σ (toks k0) ∧
      ∃ tok, (∃ hs, R tab (L + k0) = some (tok, hs)) ∧ tok < 2 ^ 31 ∧ CSrv.val ⟨tab⟩ v = some (F64.ofNat tok)))
    (hy : ∀ k, y.nnext ≤ k → y.items.get k = none) : PostAt M K env Vs R L tab j σ toks Cr y where
  ok := Vs.ok_grow h.ok hg
  hist _ hk := hist_grow h hg hk
  cur := by
    obtain ⟨tok, hs, hR, hc, hcaps, hb⟩ := h.cur
    exact ⟨tok, hs, hR, hc.mono fun c hc' v hv u hu => Vs.val_grow h.ok hg _ _ (hb c hc' v hv) hu, hcaps,
      fun c hc' t ht' => Nat.lt_of_lt_of_le (hb c hc' t ht') hg.nnext⟩
  params := params_grow h hg
  reads := by
    refine ⟨fun k v hv => ?_, hy⟩
    rcases hnew k v hv with hx | ⟨rfl, tok, ⟨hs0, hR0⟩, hb, hν⟩
    · have hlt : k < x.nnext := by
        refine Classical.byContradiction fun hc => ?_
        rw [h.reads.2 k (Nat.le_of_not_lt hc)] at hx
        cases hx
      obtain ⟨token, htk, ⟨r, hr, hit⟩, hn⟩ := h.reads.1 k v hx
      exact ⟨token, htk, ⟨r, Vs.val_grow h.ok hg _ _ hlt hr, hit⟩, hn⟩
    · obtain ⟨cs, ⟨tok', hs', hR', ⟨r, hr, hi⟩, _⟩, hlt, _⟩ := h.hist k0 hk0
      obtain ⟨rfl, -⟩ := Prod.mk.inj (Option.some.inj (hR'.symm.trans hR0))
      exact ⟨tok', hb, ⟨r, Vs.val_grow h.ok hg _ _ hlt hr, hi⟩, hν⟩

/-- **One decode forward and sampler** advances it. The new carriers keep the old tokens'. -/
theorem PostAt.next (h : PostAt M K env Vs R L tab j σ toks Cr x) (hg : Host.Mlx.Ffi.NGrow x y)
    (ht : y.tokens = x.tokens) (hσ : ∀ k, k ≤ j → σ' (toks' k) = σ (toks k))
    (hfwd : ∃ tok next, R tab (L + (j + 1)) = some (tok, next) ∧
      (∃ r, Vs.val tab y (σ' (toks' (j + 1))) = some r ∧ itemUint32 r = some tok) ∧
      CacheValuesV (Vs.val tab y) (cachesAt σ' Cr') next ∧
      CapsFor (Sim.capL (L + (j + 1))) (stageWeights (weights (firstValues M K env tab))) next)
    (hout : σ' (toks' (j + 1)) < y.nnext) (houts : CachesBelow (cachesAt σ' Cr') y.nnext) :
    PostAt M K env Vs R L tab (j + 1) σ' toks' Cr' y where
  ok := Vs.ok_grow h.ok hg
  hist k hk := by
    obtain ⟨tok, next, hR, htok, hc, _⟩ := hfwd
    by_cases hkj : k ≤ j
    · rw [hσ k hkj]
      exact hist_grow h hg hkj
    · have : k = j + 1 := by omega
      subst this
      exact ⟨cachesAt σ' Cr', ⟨tok, next, hR, htok, hc⟩, hout, houts⟩
  cur := by
    obtain ⟨tok, next, hR, _, hc, hcaps⟩ := hfwd
    exact ⟨tok, next, hR, hc, hcaps, houts⟩
  params := params_grow h hg
  reads := (h.grow hg ht).reads

/-- **The decode cut's invariant** at iteration `i`, from the reference held through time `L + i + 1`, at the decode
template's carriers under the map `σ'`. -/
theorem PostAt.toGIMV {I : TplInputs} {i : Nat} (h : PostAt M K env Vs R L tab (i + 1) σ toks Cr x)
    (hr : σ' I.read = σ (toks i)) (hf : σ' I.fed = σ (toks (i + 1))) (hc : cachesAt σ' I.caches = cachesAt σ Cr) :
    GIMV M K env Vs I R L tab i σ' x where
  ok := h.ok
  hist k h1 h2 := by
    obtain ⟨cs, hfw, ho, hb⟩ := h.hist (k - L) (by omega)
    rw [show L + (k - L) = k by omega] at hfw
    exact ⟨cs, _, hfw, ho, hb⟩
  read := by
    rw [hr]
    exact h.hist i (by omega)
  cur := by
    obtain ⟨tok, hs, hR, hcv, hcaps, hb⟩ := h.cur
    obtain ⟨_, ⟨tok', hs', hR', htok, _⟩, ho, _⟩ := h.hist (i + 1) le_rfl
    obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Option.some.inj (hR'.symm.trans hR))
    rw [hc, hf]
    exact ⟨tok', hs', hR, htok, hcv, hcaps, ho, hb⟩
  params := h.params
  reads := h.reads

/-- **The halted goal** at `T` tokens, within the times held. -/
theorem PostAt.toGFV {T : Nat} (h : PostAt M K env Vs R L tab j σ toks Cr x) (hT : T ≤ j + 1) :
    GFV Vs R L T tab x := by
  refine ⟨fun k h1 h2 => ?_, h.reads.1⟩
  obtain ⟨cs, hfw, -, -⟩ := h.hist (k - L) (by omega)
  rw [show L + (k - L) = k by omega] at hfw
  exact ⟨cs, _, hfw⟩

/-- The forward of the last time held, with its handles at the carriers `Cr`. -/
theorem PostAt.forward (h : PostAt M K env Vs R L tab j σ toks Cr x) :
    ForwardAtV (Vs.val tab x) R tab (L + j) (cachesAt σ Cr) (σ (toks j)) := by
  obtain ⟨tok, hs, hR, hcv, _, _⟩ := h.cur
  obtain ⟨_, ⟨tok', hs', hR', htok, _⟩, _, _⟩ := h.hist j le_rfl
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Option.some.inj (hR'.symm.trans hR))
  exact ⟨tok', hs', hR, htok, hcv⟩

section Row
variable {Wd : Sim.World} (pr : GraphProj Wd) {A : Sim.Addr} {I : TplInputs} {L0 i NB n : Nat} {s1 : Wd.F.S}
  {S1tab : List SymE} {outT : Nat} {outs : List (Option Nat × Option Nat)} {P' : Sim.LoadP} {Mp : Sim.Map} {y1 : Wd.F.S}
  {ν : Nat → F64}

/-- **A POST row's forward from its certificate.** `CaseFwdAtV` is the decode iterations' interface, read at the row's
time `L0 + i + 1 = L + j`: the template at the row's end takes the handles and token held at time `L + j` to those of the
next time. -/
theorem PostAt.fwdStep (h : PostAt M K env Vs R L tab j σ toks Cr x)
    (fwd : CaseFwdAtV M K env Vs pr A I R L0 s1 S1tab outT outs i NB) (hL : L0 + i + 1 = L + j)
    (hgy : Host.Mlx.Ffi.NGrow x (Wd.toMlx y1))
    (hld : Sim.G.LoadR P' NB Mp n (pr.toLoad s1) (pr.toLoad y1)) (hNL : P'.NL = A.NL) (hN0 : P'.N0 = A.N0)
    (hν : ν A.tvar = F64.ofNat (L0 + i + 1))
    (hnum : ∀ j e, nth? S1tab j = some e → CSrv.val ⟨tab⟩ (Mp.nv (.ref j)) = some (e.eval ν))
    (hrope : Mp.big (A.rope : Int) = (A.rope : Int))
    (hfed : Mp.node I.fed = σ (toks j)) (hc : cachesAt Mp.node I.caches = cachesAt σ Cr)
    (hnext : ∃ tok' hs', R tab (L + (j + 1)) = some (tok', hs')) (hb : ∀ tok hs, R tab (L + j) = some (tok, hs) → tok < 2 ^ 31) :
    ∃ tok next, R tab (L + (j + 1)) = some (tok, next) ∧
      (∃ r, Vs.val tab (Wd.toMlx y1) (Mp.node outT) = some r ∧ itemUint32 r = some tok) ∧
      CacheValuesV (Vs.val tab (Wd.toMlx y1)) (cachesAt Mp.node outs) next ∧
      CapsFor (Sim.capL (L + (j + 1))) (stageWeights (weights (firstValues M K env tab))) next := by
  obtain ⟨tok, hs, hR, hcv, hcaps, hcb⟩ := h.cur
  obtain ⟨_, ⟨tok1, hs1, hR1, ⟨r, hr, hi⟩, _⟩, ho, _⟩ := h.hist j le_rfl
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Option.some.inj (hR1.symm.trans hR))
  obtain ⟨tok', hs', hR'⟩ := hnext
  have e1 : L0 + i + 1 = L + j := hL
  have e2 : L0 + i + 2 = L + (j + 1) := by omega
  have hout := fwd tab P' Mp n y1 ν hld hNL hN0 hν hnum hrope tok1 hs1 tok' hs'
    (by rw [e1]; exact hR) (by rw [e2]; exact hR') (hb _ _ hR) (by rw [e1]; exact hcaps)
    (by
      rw [hc]
      exact hcv.mono fun c hc' v hv u hu => Vs.val_grow h.ok hgy _ _ (hcb c hc' v hv) hu)
    ⟨r, by rw [hfed]; exact Vs.val_grow h.ok hgy _ _ ho hr, hi⟩
    (fun t ht => Vs.val_grow h.ok hgy _ _ (h.params t ht).2 (h.params t ht).1)
  rw [e2] at hout
  exact ⟨tok', hs', hR', hout⟩

end Row

section Cut
variable (M K env Vs)

/-- **`PostAt` as a cut's bookkeeping**, at every table above the server, reading the cut's node map. -/
def PostG (R : MRef) (L j : Nat) (toks : Nat → Nat) (Cr : List (Option Nat × Option Nat))
    (x : Host.Ts.Sim.SegInst Host.Ts.Sim.Full.FF) : Prop :=
  ∀ tab, Host.Ts.Sim.CSrv.Le x.C ⟨tab⟩ → PostAt M K env Vs R L tab j x.M.node toks Cr (Host.Ts.Sim.Full.mlxOf x.t.ffi)

variable {M K env Vs}

theorem PostG.glue {x y : Host.Ts.Sim.SegInst Host.Ts.Sim.Full.FF} (h : PostG M K env Vs R L j toks Cr x)
    (hg : Host.Ts.Sim.Compose.NTrack x y) : PostG M K env Vs R L j toks Cr y := by
  intro tab hC
  rw [hg.map]
  exact (h tab (hg.server.trans hC)).grow hg.nodes hg.tokens

/-- **The hand-off's invariant.** POST's end, with the reference held through time `L + 2`, under the shift `κ` into the
decode template: the invariant `GxV` at iteration 1 at the hand-off's map. -/
theorem PostG.handoff {I : TplInputs} {κ : Sim.Map} {a b d : Nat} {x : Host.Ts.Sim.SegInst Host.Ts.Sim.Full.FF}
    (h : PostG M K env Vs R L 2 toks Cr x) (hr : κ.node I.read = toks 1) (hf : κ.node I.fed = toks 2)
    (hc : I.caches.map (fun p => (p.1.map κ.node, p.2.map κ.node)) = Cr) :
    GxV M K env Vs I R L 1 ((x.M.after κ).rebig a b d) (Host.Ts.Sim.Full.mlxOf x.t.ffi) x.C := by
  intro tab hle
  refine (h tab hle).toGIMV (i := 1) ?_ ?_ ?_
  · show x.M.node (κ.node I.read) = _
    rw [hr]
  · show x.M.node (κ.node I.fed) = _
    rw [hf]
  · rw [← hc]
    exact (Host.Mlx.SimGraph.Iter.cachesAt_comp x.M.node κ.node I.caches).symm

theorem PostG.congr {x y : Host.Ts.Sim.SegInst Host.Ts.Sim.Full.FF} (h : PostG M K env Vs R L j toks Cr x)
    (ht : y.t = x.t) (hC : y.C = x.C) (hσ : ∀ k, k ≤ j → y.M.node (toks' k) = x.M.node (toks k))
    (hc : cachesAt y.M.node Cr' = cachesAt x.M.node Cr) : PostG M K env Vs R L j toks' Cr' y := by
  intro tab hle
  rw [ht]
  exact (h tab (hC ▸ hle)).congr hσ hc

end Cut

section Zero
variable {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {envP : FfiEval.Env InKey} {π : List Nat} {W : Vals}

/-- **The head and sampler after the final forward.** The forward's normalized hidden state at the exit's carrier; the
template's sampled node holds the sampler's token on it; the handles carried over from the exit. -/
theorem PostAt.zero {t' : St Host.Ts.Sim.Full.FF.S} {s : Host.Mlx.SimGraph.Ref.RSt} {hidden : Value}
    {hs : List Handles} {tok : Nat} {tokN : Nat → Nat}
    (hp : Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net envP π tab = some s)
    (hf : finalForward P KR envP π tab s.hs = some (hidden, hs)) (h1 : 1 ≤ π.length)
    (hH : Held P KR envP W tab hs σ Cr t')
    (htok : finalToken P KR envP tab hidden = some tok)
    (hsample : ∃ r, W.val tab (Host.Ts.Sim.Full.mlxOf t'.ffi) (σ (tokN 0)) = some r ∧ itemUint32 r = some tok)
    (hout : σ (tokN 0) < (Host.Ts.Sim.Full.mlxOf t'.ffi).nnext)
    (hcaps : CapsFor (Sim.capL (π.length + 0)) (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract envP tab))) hs) :
    PostAt P.toMlxContract KR.toKernelContract envP W (Host.Mlx.SimGraph.Mach.refPrompt P KR NE KR.inPlace net envP π)
      π.length tab 0 σ tokN Cr (Host.Ts.Sim.Full.mlxOf t'.ffi) := by
  have hR : Host.Mlx.SimGraph.Mach.refPrompt P KR NE KR.inPlace net envP π tab (π.length + 0) = some (tok, hs) := by
    rw [Nat.add_zero, refPrompt_last P KR NE net envP π tab h1 hp hf, htok]
    rfl
  exact
    { ok := hH.ok
      hist := fun k hk => by
        have : k = 0 := by omega
        subst this
        exact ⟨cachesAt σ Cr, ⟨tok, hs, hR, hsample, hH.values⟩, hout, hH.below⟩
      cur := ⟨tok, hs, hR, hH.values, hcaps, hH.below⟩
      params := hH.params
      reads := hH.reads }

end Zero

end Host.Route.PrefGraph
