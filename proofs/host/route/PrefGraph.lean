import host.route.Final
import host.simgraph.mach.Vals
import host.sim.compose.NTrack
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter
open Host.Mlx.SimGraph.Mach (Vals CacheValuesV ReadbackValuesV)
open Host.Mlx.SimGraph.Ref (RSt routeStep afterDrains preFinal prefillState_eq drainStep tailStep tailThen)
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Ts.Sim.Prefill (drains tailRows chunkC)

/-! # The prefill's graph side at its cuts

The decode cut's invariant reads the machine reference, whose state after the prompt is the fold of `routeStep` over
the schedule (`prefillAt`). The simulation's cuts must therefore say that the target holds that fold's state at every
schedule position, at the route's values (`host.simgraph.mach.Vals`): `V s` for reference state `s`, whose recorded
values are the Neural Engine readers of the forwards `s` has run. As in `GIM`, the caches are read at the cut
template's carriers `Cr` through the node map. These predicates name no chain, so a piece's cuts carry them as an
additive bookkeeping layer. `An` is the Neural Engine memory component, read at the same reference state.

* `ColdG`: before the first forward, where the reference's handles are empty.
* `DrainG Cr k`: at the drain cut after `k ≥ 1` whole chunks (`afterDrains`).
* `PreG Cr`: at the pre-final cut (`preFinal`); `PreG.prefillAt`: that is the reference's `prefillAt`.
* `ExitG Cr out`: at the prefill's exit cut, after the final D1 forward from `prefillAt`'s state: the node
  `x.M.node out` holds the forward's normalized hidden state and the carriers its next handles.
* `stepTrace_final`: the reference's step at the last prompt row is that forward, then the head and the sampler.
* `GlueOk`: what a stretch between forwards keeps; `DrainG.glue`, `PreG.glue`, `ExitG.glue` transport across it.
* `ColdG.preG_tail`, `ColdG.exit`, `DrainG.succ`, `DrainG.preG_tail`, `DrainG.preG_of_no_tail`, `PreG.exit`: a forward
  advances the fold. -/

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)
  (V : RSt → Vals) (An : RSt → St FF.S → Prop)

/-- The checkpoint's weights at table `tab`. -/
noncomputable abbrev wts (tab : List F64) := weights (firstValues P.toMlxContract KR.toKernelContract env tab)

/-- The reference's prefill step at table `tab`. -/
noncomputable abbrev refStep (tab : List F64) :=
  routeStep P KR NE KR.inPlace net env.weights (wts P KR env tab) π

/-- The reference's state before the first step. -/
noncomputable abbrev refInit : RSt := ⟨initialHandles, net.surfaces, []⟩

/-- The parts of the target that hold whatever the caches hold, at values `W`. -/
structure Base (W : Vals) (tab : List F64) (t : St FF.S) : Prop where
  ok : W.Ok (mlxOf t.ffi)
  params : ∀ p ∈ parameterTensors parameterChoice,
    W.val tab (mlxOf t.ffi) p.node = some (firstValues P.toMlxContract KR.toKernelContract env tab p) ∧
      p.node < (mlxOf t.ffi).nnext
  reads : ReadbackValuesV (W.val tab (mlxOf t.ffi)) (CSrv.val ⟨tab⟩) (mlxOf t.ffi).items ∧
    ∀ k, (mlxOf t.ffi).nnext ≤ k → (mlxOf t.ffi).items.get k = none

/-- **The target holds the handles `hs`** at table `tab`, at the carriers `Cr` under the node map `σ`. -/
structure Held (W : Vals) (tab : List F64) (hs : List Handles) (σ : Nat → Nat)
    (Cr : List (Option Nat × Option Nat)) (t : St FF.S) : Prop extends Base P KR env W tab t where
  values : CacheValuesV (W.val tab (mlxOf t.ffi)) (cachesAt σ Cr) hs
  below : CachesBelow (cachesAt σ Cr) (mlxOf t.ffi).nnext

/-- **Before the first forward.** The reference's initial handles are empty (`CacheValuesV` needs populated ones, so
`Held` is false there): the target holds only the base. This reads no node map. -/
def ColdG (x : SegInst FF) : Prop :=
  ∀ tab, Host.Ts.Sim.CSrv.Le x.C ⟨tab⟩ → Base P KR env (V (refInit net)) tab x.t ∧ An (refInit net) x.t

/-- The drain cut after `k ≥ 1` whole chunks holds the reference's fold to it. -/
def DrainG (Cr : List (Option Nat × Option Nat)) (k : Nat) (x : SegInst FF) : Prop :=
  ∀ tab, Host.Ts.Sim.CSrv.Le x.C ⟨tab⟩ → ∃ s, afterDrains (refStep P KR NE net env π tab) π.length k (refInit net) = some s ∧
    Held P KR env (V s) tab s.hs x.M.node Cr x.t ∧ An s x.t

/-- The pre-final cut holds the reference's fold to it. -/
def PreG (Cr : List (Option Nat × Option Nat)) (x : SegInst FF) : Prop :=
  ∀ tab, Host.Ts.Sim.CSrv.Le x.C ⟨tab⟩ → ∃ s, preFinal (refStep P KR NE net env π tab) π.length (refInit net) = some s ∧
    Held P KR env (V s) tab s.hs x.M.node Cr x.t ∧ An s x.t

/-- The final D1 forward of the reference's state at the last prompt row: the normalized hidden state the forward
returns (the node `rmsNorm` of the last layer's output) and the next handles. -/
noncomputable def finalForward (tab : List F64) (hs : List Handles) : Option (Value × List Handles) := do
  let x ← embedTrace P.toMlxContract (wts P KR env tab).embedWords (wts P KR env tab).embedScales
    (wts P KR env tab).embedBiases (π.getD (π.length - 1) 0)
  let (y, hs') ← chainTrace P.toMlxContract KR.toKernelContract (π.length - 1) (stageWeights (wts P KR env tab)) hs x
  let h ← rmsNorm P.toMlxContract.hiddenNorm y (wts P KR env tab).finalNorm (f32 0x358637bd)
  pure (h, hs')

/-- The head and the sampler on the forward's normalized hidden state: the token. -/
noncomputable def finalToken (tab : List F64) (h : Value) : Option Nat := do
  let logits ← GlueLayers.project P.toMlxContract KR.toKernelContract .affineRow (wts P KR env tab).head h
  let l ← reshape logits [1, 248320]
  let [r] ← KernelClosure.eval KR.toKernelContract .normalizedArgmax [l] | none
  itemUint32 r

/-- **The decode step at the last prompt row** is the final forward, then the head and the sampler. -/
theorem stepTrace_final (tab : List F64) (hs : List Handles) :
    stepTrace P.toMlxContract KR.toKernelContract (wts P KR env tab) (π.length - 1) (π.getD (π.length - 1) 0) hs =
      (finalForward P KR env π tab hs).bind fun r => (finalToken P KR env tab r.1).map fun t => (t, r.2) := by
  simp only [stepTrace, finalForward, finalToken, bind, Option.bind, pure, Option.map]
  cases embedTrace P.toMlxContract (wts P KR env tab).embedWords (wts P KR env tab).embedScales
      (wts P KR env tab).embedBiases (π.getD (π.length - 1) 0) with
  | none => rfl
  | some x =>
    dsimp only
    cases chainTrace P.toMlxContract KR.toKernelContract (π.length - 1) (stageWeights (wts P KR env tab)) hs x with
    | none => rfl
    | some r =>
      obtain ⟨y, hs'⟩ := r
      dsimp only
      cases rmsNorm P.toMlxContract.hiddenNorm y (wts P KR env tab).finalNorm (f32 0x358637bd) with
      | none => rfl
      | some h =>
        dsimp only
        cases GlueLayers.project P.toMlxContract KR.toKernelContract .affineRow (wts P KR env tab).head h with
        | none => rfl
        | some logits =>
          dsimp only
          cases reshape logits [1, 248320] with
          | none => rfl
          | some l =>
            dsimp only
            cases KernelClosure.eval KR.toKernelContract .normalizedArgmax [l] with
            | none => rfl
            | some rs =>
              dsimp only
              match rs with
              | [] => rfl
              | [r] =>
                dsimp only
                cases itemUint32 r <;> rfl
              | _ :: _ :: _ => rfl

/-- **The prefill's exit cut**: the final forward's normalized hidden state at the carrier `out`, its handles at `Cr`. -/
def ExitG (Cr : List (Option Nat × Option Nat)) (out : Nat) (x : SegInst FF) : Prop :=
  ∀ tab, Host.Ts.Sim.CSrv.Le x.C ⟨tab⟩ → ∃ s hidden hs,
    Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π tab = some s ∧
    finalForward P KR env π tab s.hs = some (hidden, hs) ∧
    (V s).val tab (mlxOf x.t.ffi) (x.M.node out) = some hidden ∧
    x.M.node out < (mlxOf x.t.ffi).nnext ∧
    Held P KR env (V s) tab hs x.M.node Cr x.t ∧ An s x.t

/-- **What a stretch between forwards keeps.** The relation gives each field at a cut's conversion. -/
structure GlueOk (x y : SegInst FF) : Prop where
  server : Host.Ts.Sim.CSrv.Le x.C y.C
  map : y.M.node = x.M.node
  nodes : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi)
  tokens : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens
  ane : ∀ s, An s x.t → An s y.t

variable {P KR NE net env π V An}

/-- With its token queue unchanged, native growth pops nothing, so the readbacks are unchanged. -/
theorem items_of_tokens {a b : Host.Mlx.Ffi.St} (hg : Host.Mlx.Ffi.NGrow a b) (ht : b.tokens = a.tokens) :
    b.items = a.items := by
  obtain ⟨ps, he, hp⟩ := hg.pops
  rw [ht] at he
  have hn : ps = [] := by
    have hl := congrArg List.length he
    simp only [List.length_append, List.length_map] at hl
    exact List.length_eq_zero_iff.mp (by omega)
  subst hn
  simpa only [Host.Mlx.Ffi.Pops] using hp

theorem Base.grow {W : Vals} {tab : List F64} {t t' : St FF.S} (h : Base P KR env W tab t)
    (hg : Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t'.ffi)) (ht : (mlxOf t'.ffi).tokens = (mlxOf t.ffi).tokens) :
    Base P KR env W tab t' := by
  have hi := items_of_tokens hg ht
  refine ⟨W.ok_grow h.ok hg, fun p hp => ?_, ?_, ?_⟩
  · obtain ⟨he, hlt⟩ := h.params p hp
    exact ⟨W.val_grow h.ok hg _ _ hlt he, Nat.lt_of_lt_of_le hlt hg.nnext⟩
  · rw [hi]
    intro node value hv
    have hlt : node < (mlxOf t.ffi).nnext := by
      by_contra hc
      rw [h.reads.2 node (Nat.le_of_not_lt hc)] at hv
      cases hv
    obtain ⟨token, htk, ⟨r, hr, hit⟩, hn⟩ := h.reads.1 node value hv
    exact ⟨token, htk, ⟨r, W.val_grow h.ok hg _ _ hlt hr, hit⟩, hn⟩
  · intro k hk
    rw [hi]
    exact h.reads.2 k (Nat.le_trans hg.nnext hk)

theorem Held.grow {W : Vals} {tab : List F64} {hs : List Handles} {σ : Nat → Nat}
    {Cr : List (Option Nat × Option Nat)} {t t' : St FF.S} (h : Held P KR env W tab hs σ Cr t)
    (hg : Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t'.ffi)) (ht : (mlxOf t'.ffi).tokens = (mlxOf t.ffi).tokens) :
    Held P KR env W tab hs σ Cr t' where
  toBase := h.toBase.grow hg ht
  values := h.values.mono fun c hc v hv u hu =>
    W.val_grow h.ok hg _ _ (h.below c hc v hv) hu
  below := fun c hc v hv => Nat.lt_of_lt_of_le (h.below c hc v hv) hg.nnext

theorem DrainG.glue {Cr : List (Option Nat × Option Nat)} {k : Nat} {x y : SegInst FF}
    (h : DrainG P KR NE net env π V An Cr k x) (hg : GlueOk An x y) : DrainG P KR NE net env π V An Cr k y := by
  intro tab hC
  obtain ⟨s, hs, hh, ha⟩ := h tab (hg.server.trans hC)
  refine ⟨s, hs, ?_, hg.ane s ha⟩
  rw [hg.map]
  exact hh.grow hg.nodes hg.tokens

theorem PreG.glue {Cr : List (Option Nat × Option Nat)} {x y : SegInst FF}
    (h : PreG P KR NE net env π V An Cr x) (hg : GlueOk An x y) : PreG P KR NE net env π V An Cr y := by
  intro tab hC
  obtain ⟨s, hs, hh, ha⟩ := h tab (hg.server.trans hC)
  refine ⟨s, hs, ?_, hg.ane s ha⟩
  rw [hg.map]
  exact hh.grow hg.nodes hg.tokens

theorem ExitG.glue {Cr : List (Option Nat × Option Nat)} {out : Nat} {x y : SegInst FF}
    (h : ExitG P KR NE net env π V An Cr out x) (hg : GlueOk An x y) : ExitG P KR NE net env π V An Cr out y := by
  intro tab hC
  obtain ⟨s, hidden, hs', hp, hf, he, hlt, hh, ha⟩ := h tab (hg.server.trans hC)
  refine ⟨s, hidden, hs', hp, hf, ?_, ?_, ?_, hg.ane s ha⟩
  · rw [hg.map]
    exact (V s).val_grow hh.ok hg.nodes _ _ hlt he
  · rw [hg.map]
    exact Nat.lt_of_lt_of_le hlt hg.nodes.nnext
  · rw [hg.map]
    exact hh.grow hg.nodes hg.tokens

/-- A stretch's facts (`NTrack`, from the pieces) with the Neural Engine component. -/
theorem GlueOk.of_track {x y : SegInst FF} (h : Host.Ts.Sim.Compose.NTrack x y) (ha : ∀ s, An s x.t → An s y.t) :
    GlueOk An x y :=
  ⟨h.server, h.map, h.nodes, h.tokens, ha⟩

/-- `Held` reads the node map only at the carriers: a restart or compaction renaming them keeps it. -/
theorem Held.congr {W : Vals} {tab : List F64} {hs : List Handles} {σ σ' : Nat → Nat}
    {Cr Cr' : List (Option Nat × Option Nat)} {t : St FF.S} (h : Held P KR env W tab hs σ Cr t)
    (hc : cachesAt σ' Cr' = cachesAt σ Cr) : Held P KR env W tab hs σ' Cr' t where
  toBase := h.toBase
  values := hc ▸ h.values
  below := hc ▸ h.below

theorem DrainG.congr {Cr Cr' : List (Option Nat × Option Nat)} {k : Nat} {x y : SegInst FF}
    (h : DrainG P KR NE net env π V An Cr k x) (ht : y.t = x.t) (hC : y.C = x.C)
    (hc : cachesAt y.M.node Cr' = cachesAt x.M.node Cr) : DrainG P KR NE net env π V An Cr' k y := by
  intro tab hle
  obtain ⟨s, hs, hh, ha⟩ := h tab (hC ▸ hle)
  exact ⟨s, hs, ht ▸ hh.congr hc, ht ▸ ha⟩

theorem PreG.congr {Cr Cr' : List (Option Nat × Option Nat)} {x y : SegInst FF}
    (h : PreG P KR NE net env π V An Cr x) (ht : y.t = x.t) (hC : y.C = x.C)
    (hc : cachesAt y.M.node Cr' = cachesAt x.M.node Cr) : PreG P KR NE net env π V An Cr' y := by
  intro tab hle
  obtain ⟨s, hs, hh, ha⟩ := h tab (hC ▸ hle)
  exact ⟨s, hs, ht ▸ hh.congr hc, ht ▸ ha⟩

theorem ExitG.congr {Cr Cr' : List (Option Nat × Option Nat)} {out out' : Nat} {x y : SegInst FF}
    (h : ExitG P KR NE net env π V An Cr out x) (ht : y.t = x.t) (hC : y.C = x.C)
    (hc : cachesAt y.M.node Cr' = cachesAt x.M.node Cr) (ho : y.M.node out' = x.M.node out) :
    ExitG P KR NE net env π V An Cr' out' y := by
  intro tab hle
  obtain ⟨s, hidden, hs', hp, hf, he, hlt, hh, ha⟩ := h tab (hC ▸ hle)
  exact ⟨s, hidden, hs', hp, hf, ho ▸ ht ▸ he, ho ▸ ht ▸ hlt, ht ▸ hh.congr hc, ht ▸ ha⟩

theorem ColdG.glue {x y : SegInst FF} (h : ColdG P KR net env V An x) (hg : GlueOk An x y) : ColdG P KR net env V An y := by
  intro tab hC
  obtain ⟨hb, ha⟩ := h tab (hg.server.trans hC)
  exact ⟨hb.grow hg.nodes hg.tokens, hg.ane _ ha⟩

/-- `ColdG` reads no node map: any witness at the same target and server holds it. -/
theorem ColdG.of_eq {x y : SegInst FF} (h : ColdG P KR net env V An x) (ht : y.t = x.t) (hC : y.C = x.C) :
    ColdG P KR net env V An y := by
  intro tab hle
  rw [ht]
  exact h tab (hC ▸ hle)

/-- **The first tail** of a prompt with no whole chunk: the first forward takes the cold state to the pre-final cut. -/
theorem ColdG.preG_tail {Cr' : List (Option Nat × Option Nat)} {x y : SegInst FF}
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hd : drains π.length = 0) (ht : tailRows π.length ≠ 0)
    (h : ColdG P KR net env V An x)
    (hstep : ∀ tab, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ →
      Base P KR env (V (refInit net)) tab x.t → An (refInit net) x.t →
      ∃ s', refStep P KR NE net env π tab (tailStep π.length) (refInit net) = some s' ∧
        Held P KR env (V s') tab s'.hs y.M.node Cr' y.t ∧ An s' y.t) :
    PreG P KR NE net env π V An Cr' y := by
  intro tab hC
  obtain ⟨hb, ha⟩ := h tab (hle.trans hC)
  obtain ⟨s', hs', hh', ha'⟩ := hstep tab hC hb ha
  refine ⟨s', ?_, hh', ha'⟩
  simp only [preFinal, afterDrains, hd, Host.Mlx.SimGraph.Ref.drainsFrom, Option.bind_some, tailThen, ite_eq_right ht]
  exact hs'

/-- **The one-token prompt's final forward** takes the cold state to the exit cut. -/
theorem ColdG.exit {Cr' : List (Option Nat × Option Nat)} {out : Nat} {x y : SegInst FF}
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hL : π.length = 1) (h : ColdG P KR net env V An x)
    (hstep : ∀ tab, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ →
      Base P KR env (V (refInit net)) tab x.t → An (refInit net) x.t →
      ∃ hidden hs', finalForward P KR env π tab (refInit net).hs = some (hidden, hs') ∧
        (V (refInit net)).val tab (mlxOf y.t.ffi) (y.M.node out) = some hidden ∧
        y.M.node out < (mlxOf y.t.ffi).nnext ∧
        Held P KR env (V (refInit net)) tab hs' y.M.node Cr' y.t ∧ An (refInit net) y.t) :
    ExitG P KR NE net env π V An Cr' out y := by
  intro tab hC
  obtain ⟨hb, ha⟩ := h tab (hle.trans hC)
  obtain ⟨hidden, hs', hf, he, hlt, hh', ha'⟩ := hstep tab hC hb ha
  refine ⟨refInit net, hidden, hs', ?_, hf, he, hlt, hh', ha'⟩
  unfold Host.Mlx.SimGraph.Ref.prefillAt
  rw [hL]
  exact Host.Mlx.SimGraph.Ref.prefillState_one _ _

/-- The pre-final cut's fold is the reference's prefill. -/
theorem PreG.prefillAt {Cr : List (Option Nat × Option Nat)} {x : SegInst FF}
    (h : PreG P KR NE net env π V An Cr x) (h1 : 1 ≤ π.length) (h2 : π.length ≤ 349525) (tab : List F64)
    (hC : Host.Ts.Sim.CSrv.Le x.C ⟨tab⟩) :
    ∃ s, Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π tab = some s ∧
      Held P KR env (V s) tab s.hs x.M.node Cr x.t ∧ An s x.t := by
  obtain ⟨s, hs, hh, ha⟩ := h tab hC
  refine ⟨s, ?_, hh, ha⟩
  unfold Host.Mlx.SimGraph.Ref.prefillAt
  rw [prefillState_eq _ h1 h2]
  exact hs

/-- With no tail, the last drain cut's fold is already the pre-final cut's. -/
theorem DrainG.preG_of_no_tail {Cr : List (Option Nat × Option Nat)} {x : SegInst FF}
    (h : DrainG P KR NE net env π V An Cr (drains π.length) x) (ht : tailRows π.length = 0) :
    PreG P KR NE net env π V An Cr x := by
  intro tab hC
  obtain ⟨s, hs, hh, ha⟩ := h tab hC
  refine ⟨s, ?_, hh, ha⟩
  simp only [preFinal, hs, Option.bind_some, tailThen, ite_eq_left ht]

/-- The tail advances the last drain cut's fold to the pre-final cut's. -/
theorem DrainG.preG_tail {Cr Cr' : List (Option Nat × Option Nat)} {x y : SegInst FF}
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (ht : tailRows π.length ≠ 0)
    (h : DrainG P KR NE net env π V An Cr (drains π.length) x)
    (hstep : ∀ tab s, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ →
      afterDrains (refStep P KR NE net env π tab) π.length (drains π.length) (refInit net) = some s →
      Held P KR env (V s) tab s.hs x.M.node Cr x.t → An s x.t →
      ∃ s', refStep P KR NE net env π tab (tailStep π.length) s = some s' ∧
        Held P KR env (V s') tab s'.hs y.M.node Cr' y.t ∧ An s' y.t) :
    PreG P KR NE net env π V An Cr' y := by
  intro tab hC
  obtain ⟨s, hs, hh, ha⟩ := h tab (hle.trans hC)
  obtain ⟨s', hs', hh', ha'⟩ := hstep tab s hC hs hh ha
  refine ⟨s', ?_, hh', ha'⟩
  simp only [preFinal, hs, Option.bind_some, tailThen, ite_eq_right ht]
  exact hs'

/-- **A whole chunk advances the fold**, wherever the target holds the step's result. -/
theorem DrainG.succ {Cr Cr' : List (Option Nat × Option Nat)} {k : Nat} {x y : SegInst FF}
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (h : DrainG P KR NE net env π V An Cr k x)
    (hstep : ∀ tab s, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ →
      afterDrains (refStep P KR NE net env π tab) π.length k (refInit net) = some s →
      Held P KR env (V s) tab s.hs x.M.node Cr x.t → An s x.t →
      ∃ s', refStep P KR NE net env π tab (drainStep (chunkC π.length) k) s = some s' ∧
        Held P KR env (V s') tab s'.hs y.M.node Cr' y.t ∧ An s' y.t) :
    DrainG P KR NE net env π V An Cr' (k + 1) y := by
  intro tab hC
  obtain ⟨s, hs, hh, ha⟩ := h tab (hle.trans hC)
  obtain ⟨s', hs', hh', ha'⟩ := hstep tab s hC hs hh ha
  refine ⟨s', ?_, hh', ha'⟩
  rw [Host.Mlx.SimGraph.Ref.afterDrains_succ, hs, Option.bind_some]
  exact hs'

/-- The final D1 forward takes the pre-final cut to the exit cut. -/
theorem PreG.exit {Cr Cr' : List (Option Nat × Option Nat)} {out : Nat} {x y : SegInst FF}
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (h1 : 1 ≤ π.length) (h2 : π.length ≤ 349525)
    (h : PreG P KR NE net env π V An Cr x)
    (hstep : ∀ tab s, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ →
      Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π tab = some s →
      Held P KR env (V s) tab s.hs x.M.node Cr x.t → An s x.t →
      ∃ hidden hs', finalForward P KR env π tab s.hs = some (hidden, hs') ∧
        (V s).val tab (mlxOf y.t.ffi) (y.M.node out) = some hidden ∧
        y.M.node out < (mlxOf y.t.ffi).nnext ∧
        Held P KR env (V s) tab hs' y.M.node Cr' y.t ∧ An s y.t) :
    ExitG P KR NE net env π V An Cr' out y := by
  intro tab hC
  obtain ⟨s, hs, hh, ha⟩ := h.prefillAt h1 h2 tab (hle.trans hC)
  obtain ⟨hidden, hs', hf, he, hlt, hh', ha'⟩ := hstep tab s hC hs hh ha
  exact ⟨s, hidden, hs', hs, hf, he, hlt, hh', ha'⟩

end Host.Route.PrefGraph
