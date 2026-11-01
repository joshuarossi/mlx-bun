import host.route.GpuMem
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (cachesAt CachesBelow Gr)
open Host.Mlx.SimGraph.Mach (routeVal HeldV CacheValuesV cacheValuesV_of_facts refPrompt refPrompt_succ)

/-! # A decode step at the route's values, from a match on the target's graph

`matches_stepV`: `template_stepV` without a template: the match of the step's graph at the target, at any carriers.
`postAt_ofStep`: POST's first held time, from the step at `L - 1`. -/

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (env : FfiEval.Env InKey)
  (kind : Nat → Option Compiled) (Z : Nat → Option Value)

theorem matches_stepV (tab : List F64) (x : Ffi.St) (w : PipelineWeights) (time token : Nat) (hs hs' : List Handles)
    (t : Nat) (ids : Value)
    (hembed : bufferEmbed P.toMlxContract w.embedWords w.embedScales w.embedBiases ids =
      embedTrace P.toMlxContract w.embedWords w.embedScales w.embedBiases token)
    (hfn : w.finalNorm.shape = [5120]) (hsh : ShapesOk (stageWeights w) hs)
    (e : stepTrace P.toMlxContract KR.toKernelContract w time token hs = some (t, hs'))
    (c : Nat) (caps : CapsFor c (stageWeights w) hs) (cert : List Nat)
    (hm : Matches (Gr tab x) (stepGraphOf w hs time).1 cert = true)
    (hin : HeldV (routeVal P KR env kind Z tab x) (stepGraphOf w hs time).1 cert (stepEnvWithIds env.weights w ids hs)) :
    (∃ r, routeVal P KR env kind Z tab x (certAt cert (stepGraphOf w hs time).2.1) = some r ∧ itemUint32 r = some t) ∧
      CapsFor (kvCap (some c) time) (stageWeights w) hs' ∧
      (stepGraphOf w hs time).2.2.length = hs'.length ∧
      (∀ h ∈ hs', (handleVals h).isSome) ∧
      ∀ q ∈ cacheFacts (stepGraphOf w hs time).2.2 hs', routeVal P KR env kind Z tab x (certAt cert q.1) = some q.2 := by
  have hcarry := matches_evalZ P KR env (stepEnvWithIds env.weights w ids hs) kind Z rfl
    (fun j nd hj hne => Host.Mlx.SimGraph.Mach.ffiGraph_route _ _ _ j nd hj hne) hm hin
  obtain ⟨⟨r, hlt, hr, ht⟩, hlen, hsome, hcf⟩ :=
    stepGraph_eval_ids P.toMlxContract KR.toKernelContract env.weights w time token ids hembed hs hs' t hfn hsh e
  refine ⟨⟨r, hcarry _ hlt r hr, ht⟩, capsFor_step P.toMlxContract KR.toKernelContract w time _ hs hs' _ c caps e, hlen, hsome,
    fun q hq => ?_⟩
  obtain ⟨hql, hqv⟩ := hcf q hq
  exact hcarry _ hql _ hqv

variable {KR kind} in
/-- **POST's first held time**, from the decode step at `L - 1`: the target's graph carries the step's graph at `cert`, the
reference's token and handles are at the sampled node and the carriers. -/
theorem postAt_ofStep {NE : NeuralEngine} {net : Host.Mlx.SimGraph.Ref.AneNet} {π : List Nat} {tab : List F64}
    {y : St Host.Ts.Sim.Full.FF.S} {σ toks : Nat → Nat} {Cr : List (Option Nat × Option Nat)} (hπ : 1 ≤ π.length)
    {tok0 t : Nat} {hs hs' : List Handles}
    (hR0 : refPrompt P KR NE KR.inPlace net env π tab (π.length - 1) = some (tok0, hs))
    (hR1 : refPrompt P KR NE KR.inPlace net env π tab (π.length + 0) = some (t, hs'))
    (hb : Base P KR env (routeVs P KR env kind) tab y) (ids : Value)
    (hembed : bufferEmbed P.toMlxContract (weights (firstValues P.toMlxContract KR.toKernelContract env tab)).embedWords
        (weights (firstValues P.toMlxContract KR.toKernelContract env tab)).embedScales
        (weights (firstValues P.toMlxContract KR.toKernelContract env tab)).embedBiases ids =
      embedTrace P.toMlxContract (weights (firstValues P.toMlxContract KR.toKernelContract env tab)).embedWords
        (weights (firstValues P.toMlxContract KR.toKernelContract env tab)).embedScales
        (weights (firstValues P.toMlxContract KR.toKernelContract env tab)).embedBiases tok0)
    (hfn : (weights (firstValues P.toMlxContract KR.toKernelContract env tab)).finalNorm.shape = [5120])
    (hsh : ShapesOk (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) hs)
    (caps : CapsFor (Host.Mlx.SimGraph.Mach.capL (π.length - 1))
      (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) hs)
    (cert : List Nat)
    (hm : Matches (Gr tab (Host.Ts.Sim.Full.mlxOf y.ffi))
      (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs (π.length - 1)).1 cert = true)
    (hin : HeldV (routeVal P KR env kind (fun _ => none) tab (Host.Ts.Sim.Full.mlxOf y.ffi))
      (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs (π.length - 1)).1 cert
      (stepEnvWithIds env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) ids hs))
    (hout : σ (toks 0) = certAt cert
      (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs (π.length - 1)).2.1)
    (hCr : (cachesAt σ Cr).map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      (stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) hs (π.length - 1)).2.2.map
        (fun (a, b) => (some (certAt cert a), some (certAt cert b))))
    (hoB : σ (toks 0) < (Host.Ts.Sim.Full.mlxOf y.ffi).nnext)
    (hcB : CachesBelow (cachesAt σ Cr) (Host.Ts.Sim.Full.mlxOf y.ffi).nnext) :
    PostAt P.toMlxContract KR.toKernelContract env (routeVs P KR env kind) (refPrompt P KR NE KR.inPlace net env π)
      π.length tab 0 σ toks Cr (Host.Ts.Sim.Full.mlxOf y.ffi) := by
  have e : stepTrace P.toMlxContract KR.toKernelContract (weights (firstValues P.toMlxContract KR.toKernelContract env tab))
      (π.length - 1) tok0 hs = some (t, hs') := by
    have h := refPrompt_succ P KR NE KR.inPlace net env π tab (π.length - 1) le_rfl
    rw [show π.length - 1 + 1 = π.length + 0 by omega, hR1, hR0] at h
    exact h.symm
  obtain ⟨⟨r, hr, hi⟩, hcaps, hlen, hsome, hq⟩ := matches_stepV P KR env kind (fun _ => none) tab _ _ _ _ hs hs' t ids
    hembed hfn hsh e _ caps cert hm hin
  have hval := cacheValuesV_of_facts (cachesAt σ Cr) _ hs' (fun a => certAt cert a) hCr hlen hsome hq
  rw [Host.Mlx.SimGraph.Mach.kvCap_capL, show π.length - 1 + 1 = π.length + 0 by omega] at hcaps
  exact
    { ok := hb.ok
      hist := fun k hk => by
        have : k = 0 := by omega
        subst this
        exact ⟨cachesAt σ Cr, ⟨t, hs', hR1, ⟨r, by rw [hout]; exact hr, hi⟩, hval⟩, hoB, hcB⟩
      cur := ⟨t, hs', hR1, hval, hcaps, hcB⟩
      params := hb.params
      reads := hb.reads }

end Host.Route.PrefGraph
