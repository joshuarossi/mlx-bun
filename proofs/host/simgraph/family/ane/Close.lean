import host.mlx.ane.Layers
import host.simgraph.family.AneFamilies
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx
open Host.Mlx.FfiAneEval (Mem pureVal noInput Reader AneLayer LayersOk forwardSegs segsReaders segsNodes segsLog)

/-! # The Neural Engine families' certificates over a forward's run

`aneTpl_graph_step` (AneFamilies.lean) is a family's graph postcondition in
the Neural Engine semantics at a memory `m`, for an environment holding every
reader's and writer's fixed value at its key (`hr`). Over a forward's run
(`forward_run`, host/mlx/ane/Layers.lean):

* `envAt base rk G m`: that environment, built from the memory (each reader's
  and writer's fixed value at its key `rk`, `base` elsewhere); `envAt_hr`
  is `hr` when distinct readers and writers have distinct keys (`KeysInj`);
  `envAt_off`: keys no reader or writer has are `base`'s;
* `aneRk read`: keys for a forward, its readers' family keys (`read`:
  `.linOut p j`, `.mlpOut p`) and every other reader and writer a key no
  family reads (`.p (.iota j 7 0)`; the families read `iota p 2` only);
  `aneRk_inj`;
* `aneTpl_forward`: the forward's log runs to a memory `mF` whose readers
  hold `V`, `V`'s readbacks are the environment's inputs at their keys, and
  the family's carriers hold the reference values computed at that
  environment. With `V` the readbacks of the surfaces the calls leave
  (`Seg.Step`, `call_readback`), the reference's readback inputs are the
  Neural Engine's outputs on the fills of the run's own sources. -/

section
variable {κ : Type}

open Classical in
/-- The environment of memory `m`: each reader's and writer's fixed value at its key, `base` elsewhere. -/
noncomputable def envAt (base : Env κ) (rk : Nat → κ) (G : FfiAneEval.Graph) (m : Mem) : Env κ :=
  ⟨base.weights, fun k =>
    if h : ∃ j, (G.touch j).isSome = true ∧ rk j = k then m.vals (Classical.choose h) else base.inputs k⟩

/-- Distinct readers and writers have distinct keys. -/
def KeysInj (rk : Nat → κ) (G : FfiAneEval.Graph) : Prop :=
  ∀ i j, (G.touch i).isSome = true → (G.touch j).isSome = true → rk i = rk j → i = j

theorem envAt_hr (base : Env κ) (rk : Nat → κ) (G : FfiAneEval.Graph) (m : Mem) (hinj : KeysInj rk G) :
    ∀ j, (G.touch j).isSome = true → (envAt base rk G m).inputs (rk j) = m.vals j := by
  intro j hj
  unfold envAt
  dsimp only
  split
  · rename_i h
    have hc := Classical.choose_spec h
    rw [hinj _ _ hc.1 hj hc.2]
  · rename_i h
    exact absurd ⟨j, hj, rfl⟩ h

theorem envAt_off (base : Env κ) (rk : Nat → κ) (G : FfiAneEval.Graph) (m : Mem) (k : κ)
    (hk : ∀ j, (G.touch j).isSome = true → rk j ≠ k) : (envAt base rk G m).inputs k = base.inputs k := by
  unfold envAt
  dsimp only
  split
  · rename_i h
    obtain ⟨j, hj, e⟩ := h
    exact absurd e (hk j hj)
  · rfl

end

/-- A Neural Engine forward's keys: its readers' family keys, every other node a key no family reads. -/
def aneRk (read : Nat → Option AKey) (j : Nat) : AKey := (read j).getD (.p (.iota j 7 (.lit 0)))

/-- The keys are distinct when the readers' family keys are (and none is a placeholder). -/
theorem aneRk_inj (read : Nat → Option AKey) (G : FfiAneEval.Graph)
    (hread : ∀ i j k, read i = some k → read j = some k → i = j) (hp : ∀ i k, read i = some k → ∀ j, k ≠ .p (.iota j 7 (.lit 0))) :
    KeysInj (aneRk read) G := by
  intro i j _ _ e
  unfold aneRk at e
  cases hi : read i with
  | none =>
    cases hj : read j with
    | none => simp only [hi, hj, Option.getD_none, AKey.p.injEq, PKey.iota.injEq] at e; exact e.1
    | some kj => simp only [hi, hj, Option.getD_none, Option.getD_some] at e; exact absurd e.symm (hp j kj hj i)
  | some ki =>
    cases hj : read j with
    | none => simp only [hi, hj, Option.getD_none, Option.getD_some] at e; exact absurd e (hp i ki hi j)
    | some kj =>
      simp only [hi, hj, Option.getD_some] at e
      subst e
      exact hread i j ki hi hj

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C)
  (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled) (NE : NeuralEngine) (IP : FfiAneEval.InPlace)
  (G : FfiAneEval.Graph)

/-- **A Neural Engine forward's run and its family certificate**: from a memory holding the surfaces `σ` and `V`'s
values at the readers done before, the forward's log runs to `mF`, whose readers hold `V`; at the environment of
`mF` (`envAt`), the readers' keys hold `V`'s values, keys of no reader or writer `base`'s, and the family's graph
postcondition holds at `mF` for every template and reference computation at that environment. -/
theorem aneTpl_forward (V : Nat → Option Value) (ls : List AneLayer) (D : List Reader) (σ σ' : Nat → Surface)
    (m : Mem) (hD : ∀ r ∈ D, FfiAneEval.Reader.At P K weights G r) (h : LayersOk P K weights kind NE IP G V D σ ls σ')
    (hm : m.surf = σ) (hv : ∀ r ∈ D.map Reader.b, m.vals r = V r)
    (base : Env AKey) (hw : base.weights = weights) (rk : Nat → AKey) (hinj : KeysInj rk G)
    (hn : ∀ j nd, G.node j = some nd → noInput nd.prim = true) :
    ∃ mF, FfiAneEval.run P K weights kind NE IP G m (ls.flatMap fun l => segsLog l.segs) = some mF ∧ mF.surf = σ' ∧
      (∀ r ∈ (D ++ segsReaders (forwardSegs ls)).map Reader.b, mF.vals r = V r) ∧
      (∀ j, j ∉ segsNodes (forwardSegs ls) → mF.vals j = m.vals j) ∧
      (∀ r ∈ (D ++ segsReaders (forwardSegs ls)).map Reader.b, (G.touch r).isSome = true →
        (envAt base rk G mF).inputs (rk r) = V r) ∧
      (∀ k, (∀ j, (G.touch j).isSome = true → rk j ≠ k) → (envAt base rk G mF).inputs k = base.inputs k) ∧
      ∀ (R : Rows) (k : AneKinds) (rest : Nat) (T : FamilyTemplate (aneFamily R k rest)) (ν : Nat → Int) (o n : Nat)
        (ss : List StageLayout), List.Forall₂ (SigRelR kvSigP T.o₀ T.n₀ o n) T.ss₀ ss → ∀ (σe cl : Nat → Nat),
        Embeds σe cl (mapG (PDim.eval ν) T.Gs) (keyG rk G.pure) → (∀ c, kind (cl c) = T.kind c) →
        InputsHeldR P K (envAt base rk G mF) kind (keyG rk G.pure)
          (familyGraph (aneTpl R k rest).toTpl.ops (PDim.eval ν) o n ss).1 (T.cert.map σe) →
        KernelsPlain (keyG rk G.pure) → ∀ (out : Value) (cs : List (Value × Value)) (taps : List (List (List Value))),
        forwardTX (aneTpl R k rest) (valueB P K.toKernelContract (envAt base rk G mF) (ksR P K (envAt base rk G mF)))
          (PDim.eval ν) o n ss = some ((out, cs), taps) →
        ∀ q ∈ Handle.facts (familyGraph (aneTpl R k rest).toTpl.ops (PDim.eval ν) o n ss).2 (out, cs) ++
            Handle.facts ((aneTpl R k rest).tapsOf (PDim.eval ν) o n ss) taps,
          pureVal P K weights kind G mF (σe (certAt T.cert q.1)) = some q.2 := by
  obtain ⟨mF, hr, hs, hvF, hf⟩ := FfiAneEval.forward_run P K weights kind NE IP G V ls D σ σ' m hD h hm hv
  refine ⟨mF, hr, hs, hvF, hf, fun r hr' ht => by rw [envAt_hr base rk G mF hinj r ht, hvF r hr'], envAt_off base rk G mF,
    fun R k rest T ν o n ss hsig σe cl emb hk hin hG out cs taps hv' =>
      aneTpl_graph_step P K weights G mF rk (envAt base rk G mF) hw (envAt_hr base rk G mF hinj) hn R k rest T ν o n
        ss hsig σe cl emb kind hk hin hG out cs taps hv'⟩

end

end Host.Mlx.SimGraph
