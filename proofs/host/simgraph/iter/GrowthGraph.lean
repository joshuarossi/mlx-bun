import host.simgraph.iter.GrowthFacts
import host.simgraph.LoadRel
import host.simgraph.Step
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Iter.Growth
open Host.Load Host.Load.Extract Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Load.Run.Tpl (GROWTH.s153 GROWTH.S153)
open Host.Load.Run.Full.Cached (Expected2.stages Expected2.head)

/-! # The graph side of one GROWTH iteration, for any weights of the route's layout

`GROWTH` is the iteration whose KV buffers are full (`p = c`, `c % 256 = 0`): each
grows by 256 rows. `graph_iter` holds for any pipeline weights `w` whose layout
with the template's handles `hs₀` is the route's (`hlay`, `hhead`); the load
module instantiates them with the checkpoint's weights. -/

variable (w : PipelineWeights) (hs₀ : List Handles) (hcaps₀ : CapsFor 256 (stageWeights w) hs₀)
  (hlay : chainLayout (stageWeights w) hs₀ = Expected2.stages) (hhead : linLayout .affineRow w.head = Expected2.head)

include hlay hhead in
theorem templateOf_eq : templateOf w hs₀ 256 = (Tpl.Growth.graph, Tpl.Growth.tokenNode, Tpl.Growth.cacheOutputs) := by
  unfold templateOf
  rw [hlay, hhead]
  exact Tpl.Growth.template_eq

/-- The GROWTH template: representative offset 256, capacity 256. -/
noncomputable def T : Template w where
  n₀ := 256
  c₀ := 256
  hs₀ := hs₀
  caps₀ := hcaps₀
  Gs := Gs
  cert := choice.cert
  checked := by rw [templateOf_eq w hs₀ hlay hhead]; exact check.matches
  length := by rw [templateOf_eq w hs₀ hlay hhead]; exact cert_length

theorem outputs_pairs (cert : List Nat) (ps : List (Nat × Nat)) (tOut : List (Option Nat × Option Nat))
    (nextCache : List Cache) (σ : Nat → Nat) (htmpl : tOut = ps.map (certifiedCachePair cert))
    (renamed : nextCache.map cacheNodePair = tOut.map fun p => (p.1.map σ, p.2.map σ)) :
    nextCache.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      ps.map (fun (a, b) => (some (σ (certAt cert a)), some (σ (certAt cert b)))) := by
  show nextCache.map cacheNodePair = _
  rw [renamed, htmpl, List.map_map]
  rfl

/-- **The graph side of one GROWTH iteration.** -/
theorem graph_iter (table : List F64) (P : Sim.LoadP) (Mp : Sim.Map) (n : Nat) (y : LSt)
    (hR : Sim.LoadR P Mp n GROWTH.s153.ffi y) (hNL : NL ≤ P.NL) (hN0 : P.N0 ≤ N0)
    (ρ : Nat → F64) (time : Nat) (hρ : ρ 9 = F64.ofNat time) (hsmall : time + 1 < 2 ^ 31)
    (hnum : ∀ i e, nth? GROWTH.S153.tab i = some e → CSrv.val ⟨table⟩ (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888)
    (l : Loaded) (token : Tensor) (hs : List Handles) (nextCache : List Cache) (c : Nat)
    (caps : CapsFor c (stageWeights w) hs) (growth : time = c) (aligned : c % 256 = 0)
    (hin : ∀ key j, insT key = some j → inputNode l token key = some (Mp.node j))
    (hout : nextCache.map cacheNodePair = choice.outputs.map fun p => (p.1.map Mp.node, p.2.map Mp.node)) :
    let G := ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y.mlx
    let T := T w hs₀ hcaps₀ hlay hhead
    Embeds Mp.node Mp.handle (mapG (SDim.eval time) T.Gs) G ∧
    kvSig (some T.c₀) T.n₀ = kvSig (some c) time ∧
    G token.node = some ⟨.reshape [1,1], [Mp.node 22538]⟩ ∧ Mp.node 22538 < token.node ∧
    nextCache.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      (templateOf w T.hs₀ T.n₀).2.2.map
        (fun (a, b) => (some (Mp.node (certAt T.cert a)), some (Mp.node (certAt T.cert b)))) ∧
    inputCarriersMatch (stepGraphOf w hs time).1 (T.cert.map Mp.node) (inputNode l token) = true ∧
    (templateOf w T.hs₀ T.n₀).2.1 = Tpl.Growth.tokenNode := by
  intro G T
  have hD : ∀ i, tplDom NL N0 fixedBigs GROWTH.s153.ffi.mlx i = true → Sim.Full P i := by
    intro i hi
    rcases tplDom_band hi with h | h
    · exact .inl (by omega)
    · exact .inr (by omega)
  have emb : Embeds Mp.node Mp.handle (mapG (SDim.eval time) Gs) G :=
    embeds_of_run GROWTH.S153 9 SourceKernels.sources GROWTH.s153.ffi.mlx y.mlx time _ ρ hρ hsmall
      (CSrv.val ⟨table⟩) Mp.nv Mp.big Mp.arg Mp.handle Mp.node (nv_lit Mp) (fun _ => rfl) hnum
      (fun a => okArg fixedBigs a = true) (arg_fixed Mp fixedBigs (by simp [fixedBigs, hrope]))
      (fun i nd hi hn => tplDom_args hi hn) (kernels_of_MR hR.mlx _) (nativeImage_of_MR hR.mlx _ hD)
  have htok : token.node = Mp.node tokenNode := by
    have := hin .tokenIds tokenNode token_input
    simpa [inputNode] using this
  have hfeed : mapG (SDim.eval time) Gs tokenNode = some ⟨.reshape [1, 1], [22538]⟩ := by
    simp only [mapG, token_node, Option.map_some]
    rfl
  have heq := templateOf_eq w hs₀ hlay hhead
  refine ⟨emb, (kvSig_growth c time growth aligned).symm, ?_, ?_, ?_, ?_, by show (templateOf w hs₀ 256).2.1 = _; rw [heq]⟩
  · rw [htok, emb.node _ _ hfeed]
    rfl
  · rw [htok]
    exact emb.order tokenNode 22538 (by rw [hfeed]; rfl) (by decide)
  · show _ = (templateOf w hs₀ 256).2.2.map _
    rw [heq]
    exact outputs_pairs choice.cert Tpl.Growth.cacheOutputs choice.outputs nextCache Mp.node outputs_check hout
  · refine template_inputs w T hs c time caps (kvSig_growth c time growth aligned).symm Mp.node insT
      (inputNode l token) ?_ hin
    show inputCarriersMatchD (templateOf w hs₀ 256).1 choice.cert insT = true
    rw [heq]
    exact check.inputs

end Host.Mlx.SimGraph.Iter.Growth
