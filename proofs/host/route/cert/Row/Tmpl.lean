import host.route.cert.Row.Core
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Row
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (Gr TplInputs cachesAt cachesAt_nodes loadedAt tensorAt CachesBelow)
open Host.Mlx.SimGraph.Mach (MRef MRefDecodes WeightShapes template_cached_forwardV compat_of_caps shapesOk_of_caps
  CacheValuesV refPrompt)
open Host.Ts.Sim (LoadP Map SegInst capL)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Load.Run.Full.Cached.Expected2 (stages head)
open Host.Route.PrefGraph

section Template
variable (w : PipelineWeights) (hs₀ : List Handles) (hcaps₀ : CapsFor 256 (stageWeights w) hs₀)
  (hlay : chainLayout (stageWeights w) hs₀ = stages) (hhead : linLayout .affineRow w.head = head)

include hlay hhead in
theorem templateOf_eq : templateOf w hs₀ 1 = (Tpl.Ordinary.graph, Tpl.Ordinary.tokenNode, Tpl.Ordinary.cacheOutputs) := by
  unfold templateOf
  rw [hlay, hhead]
  exact Tpl.Ordinary.template_eq

/-- The ordinary template over a row's graph. -/
noncomputable def rowT (Gs : Nat → Option (RNode SDim InKey)) (cert : List Nat)
    (hm : MatchesD Gs Tpl.Ordinary.graph cert = true) (hlen : Tpl.Ordinary.graph.length ≤ cert.length) : Template w where
  n₀ := 1
  c₀ := 256
  hs₀ := hs₀
  caps₀ := hcaps₀
  Gs := Gs
  cert := cert
  checked := by rw [templateOf_eq w hs₀ hlay hhead]; exact hm
  length := by rw [templateOf_eq w hs₀ hlay hhead]; exact hlen

end Template

/-- A row's checked certificate: its match, its inputs, the token's reshape of the fed node, its outputs. -/
structure RowCert (s : Ffi.St) (S : SSrv) (d : Nat) where
  cert : List Nat
  insT : InKey → Option Nat
  tokenNode : Nat
  fed : Nat
  ps : List (Option Nat × Option Nat)
  outs : List (Option Nat × Option Nat)
  hm : MatchesD (rowGs s S d) Tpl.Ordinary.graph cert = true
  hinp : inputCarriersMatchD Tpl.Ordinary.graph cert insT = true
  hlen : Tpl.Ordinary.graph.length ≤ cert.length
  htn : rowGs s S d tokenNode = some ⟨.reshape [.lit 1, .lit 1], [fed]⟩
  htk : insT .tokenIds = some tokenNode
  hfl : fed < tokenNode
  hins : ∀ σ : Nat → Nat, (∀ j, j < 15235 → σ j = j) → ∀ key j, insT key = some j →
    inputNode (loadedAt σ ps) (tensorAt (σ tokenNode)) key = some (σ j)
  houts : outs = Tpl.Ordinary.cacheOutputs.map (certifiedCachePair cert)
  hdown : (List.range s.nnext).all (downB (exactTplDom 15235 15235 [5554869888] s) s) = true

theorem outputs_pairs (cert : List Nat) (ps : List (Nat × Nat)) (outs : List (Option Nat × Option Nat))
    (σ : Nat → Nat) (ho : outs = ps.map (certifiedCachePair cert)) :
    outs.map (fun p => (p.1.map σ, p.2.map σ)) =
      ps.map (fun (a, b) => (some (σ (certAt cert a)), some (σ (certAt cert b)))) := by
  rw [ho, List.map_map]
  rfl

/-- **The template's facts at any weights**, from the row's embedding and its checked certificate. -/
theorem row_tpl (w : PipelineWeights) (hs₀ : List Handles) (hcaps₀ : CapsFor 256 (stageWeights w) hs₀)
    (hlay : chainLayout (stageWeights w) hs₀ = stages) (hhead : linLayout .affineRow w.head = head)
    {s : Ffi.St} {S : SSrv} {d : Nat} (c : RowCert s S d) (G : Nat → Option (RNode Int InKey)) (σ cl : Nat → Nat) (n : Nat)
    (emb : Embeds σ cl (mapG (SDim.eval n) (rowGs s S d)) G) (l : Loaded) (token : Tensor) (hs : List Handles)
    (nextCache : List Cache) (cap : Nat) (caps : CapsFor cap (stageWeights w) hs) (interior : n + 1 < cap)
    (hin : ∀ key j, c.insT key = some j → inputNode l token key = some (σ j)) (htok : token.node = σ c.tokenNode)
    (hout : nextCache.map cacheNodePair = c.outs.map fun p => (p.1.map σ, p.2.map σ)) :
    let T := rowT w hs₀ hcaps₀ hlay hhead (rowGs s S d) c.cert c.hm c.hlen
    kvSig (some T.c₀) T.n₀ = kvSig (some cap) n ∧
      G token.node = some ⟨.reshape [1, 1], [σ c.fed]⟩ ∧ σ c.fed < token.node ∧
      nextCache.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
        (templateOf w T.hs₀ T.n₀).2.2.map
          (fun (a, b) => (some (σ (certAt T.cert a)), some (σ (certAt T.cert b)))) ∧
      inputCarriersMatch (stepGraphOf w hs n).1 (T.cert.map σ) (inputNode l token) = true ∧
      (templateOf w T.hs₀ T.n₀).2.1 = Tpl.Ordinary.tokenNode := by
  intro T
  have hfeed : mapG (SDim.eval n) (rowGs s S d) c.tokenNode = some ⟨.reshape [1, 1], [c.fed]⟩ := by
    simp only [mapG, c.htn, Option.map_some]
    rfl
  have heq := templateOf_eq w hs₀ hlay hhead
  have hbr : kvSig (some T.c₀) T.n₀ = kvSig (some cap) n := (kvSig_interior cap n interior).symm
  refine ⟨hbr, ?_, ?_, ?_, ?_, ?_⟩
  · rw [htok, emb.node _ _ hfeed]
    rfl
  · rw [htok]
    exact emb.order c.tokenNode _ hfeed c.fed (List.mem_singleton.mpr rfl)
  · show _ = (templateOf w hs₀ 1).2.2.map _
    rw [heq]
    change nextCache.map cacheNodePair = Tpl.Ordinary.cacheOutputs.map
      (fun (a, b) => (some (σ (certAt c.cert a)), some (σ (certAt c.cert b))))
    exact hout.trans (outputs_pairs c.cert Tpl.Ordinary.cacheOutputs c.outs σ c.houts)
  · refine template_inputs w T hs cap n caps hbr σ c.insT (inputNode l token) ?_ hin
    show inputCarriersMatchD (templateOf w hs₀ 1).1 c.cert c.insT = true
    rw [heq]
    exact c.hinp
  · show (templateOf w hs₀ 1).2.1 = _
    rw [heq]

end Host.Route.Cert.Row
