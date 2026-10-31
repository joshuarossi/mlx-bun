import host.sim.compose.a4b.GraphOrdExact
import host.simgraph.Step
import host.load.CacheCarriersCommand
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.DECGraph.Ord
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Mlx _root_.Host.Mlx.GlueStep
open _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Load.Run.Full.Cached.Expected2 (stages head)

/-! Graph correspondence for the ordinary decode chain at every time in its KV branch. -/

kernel_rfl token_node : Gs tokenNode = some ⟨.reshape [.lit 1, .lit 1], [22538]⟩
kernel_rfl token_input : insT .tokenIds = some tokenNode
kernel_rfl outputs_check : choice.outputs = Tpl.Ordinary.cacheOutputs.map (certifiedCachePair choice.cert)

section
variable (w : PipelineWeights) (hs₀ : List Handles) (hcaps₀ : CapsFor 256 (stageWeights w) hs₀)
  (hlay : chainLayout (stageWeights w) hs₀ = stages)
  (hhead : linLayout .affineRow w.head = head)

include hlay hhead in
theorem templateOf_eq : templateOf w hs₀ 1 = (Tpl.Ordinary.graph, Tpl.Ordinary.tokenNode, Tpl.Ordinary.cacheOutputs) := by
  unfold templateOf
  rw [hlay, hhead]
  exact Tpl.Ordinary.template_eq

noncomputable def T : Template w where
  n₀ := 1
  c₀ := 256
  hs₀ := hs₀
  caps₀ := hcaps₀
  Gs := Gs
  cert := choice.cert
  checked := by rw [templateOf_eq w hs₀ hlay hhead]; exact check.matches
  length := by rw [templateOf_eq w hs₀ hlay hhead]; exact cert_length

end

theorem outputs_pairs (cert : List Nat) (ps : List (Nat × Nat)) (outs : List (Option Nat × Option Nat))
    (σ : Nat → Nat) (ho : outs = ps.map (certifiedCachePair cert)) :
    outs.map (fun p => (p.1.map σ, p.2.map σ)) =
      ps.map (fun (a, b) => (some (σ (certAt cert a)), some (σ (certAt cert b)))) := by
  rw [ho, List.map_map]
  rfl

section
variable (w : PipelineWeights) (hs₀ : List Handles) (hcaps₀ : CapsFor 256 (stageWeights w) hs₀)
  (hlay : chainLayout (stageWeights w) hs₀ = stages)
  (hhead : linLayout .affineRow w.head = head)

/-- Every general-native image of this end carries the ordinary graph.
The checked source domain contains no shape-only host-data node. -/
theorem graph_iter (table : List F64) (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : LSt)
    (hR : G.LoadR P NB Mp n endLoad.ffi y) (hNL : NL ≤ P.NL) (hN0 : P.N0 ≤ N0)
    (ρ : Nat → F64) (time : Nat) (hρ : ρ 9 = F64.ofNat time) (hsmall : time + 1 < 2 ^ 31)
    (hnum : ∀ i e, nth? Host.Load.Run.Tpl.DEC_ord.S1D.tab i = some e →
      CSrv.val ⟨table⟩ (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888)
    (l : Loaded) (token : Tensor) (hs : List Handles) (nextCache : List Cache) (c : Nat)
    (caps : CapsFor c (stageWeights w) hs) (interior : time + 1 < c)
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
      (templateOf w T.hs₀ T.n₀).2.1 = Tpl.Ordinary.tokenNode := by
  intro G T
  have hD : ∀ i, tplDom NL N0 fixedBigs endLoad.ffi.mlx i = true → Full P i := by
    intro i hi
    rcases tplDom_band hi with h | h
    · exact .inl (Nat.lt_of_lt_of_le h hNL)
    · exact .inr (Nat.le_trans hN0 h)
  have emb : Embeds Mp.node Mp.handle (mapG (SDim.eval time) Gs) G :=
    embeds_of_GRun Host.Load.Run.Tpl.DEC_ord.S1D 9 SourceKernels.sources hR.mlx time _ ρ hρ hsmall
      (CSrv.val ⟨table⟩) (fun _ => rfl) hnum (fun a => okArg fixedBigs a = true)
      (arg_fixed Mp fixedBigs (by simp [fixedBigs, hrope]))
      (fun _ _ hi hn => tplDom_args hi hn) hD
      (fun i nd hi hn => source_exact (hR.mlx.nlt i (by
        show (endLoad.ffi.mlx.nodes.get i).isSome = true
        rw [hn]
        rfl)) hi hn)
  have htok : token.node = Mp.node tokenNode := by
    have := hin .tokenIds tokenNode token_input
    simpa [inputNode] using this
  have hfeed : mapG (SDim.eval time) Gs tokenNode = some ⟨.reshape [1, 1], [22538]⟩ := by
    simp only [mapG, token_node, Option.map_some]
    rfl
  have heq := templateOf_eq w hs₀ hlay hhead
  refine ⟨emb, (kvSig_interior c time interior).symm, ?_, ?_, ?_, ?_, ?_⟩
  · rw [htok, emb.node _ _ hfeed]
    rfl
  · rw [htok]
    exact emb.order tokenNode 22538 (by rw [hfeed]; rfl) (by decide)
  · show _ = (templateOf w hs₀ 1).2.2.map _
    rw [heq]
    change nextCache.map cacheNodePair = Tpl.Ordinary.cacheOutputs.map
      (fun (a, b) => (some (Mp.node (certAt choice.cert a)), some (Mp.node (certAt choice.cert b))))
    exact hout.trans (outputs_pairs choice.cert Tpl.Ordinary.cacheOutputs choice.outputs Mp.node outputs_check)
  · refine template_inputs w T hs c time caps (kvSig_interior c time interior).symm Mp.node insT
      (inputNode l token) ?_ hin
    show inputCarriersMatchD (templateOf w hs₀ 1).1 choice.cert insT = true
    rw [heq]
    exact check.inputs
  · show (templateOf w hs₀ 1).2.1 = _
    rw [heq]

end

end Host.Ts.Sim.Compose.DECGraph.Ord
