import host.route.cert.Row.Fwd
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (cachesAt cachesAt_comp cachesAt_nodes)
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF fullWorldXD mlxOf)

/-! # POST's bookkeeping across the link and at the halts

`memPost_link`: a class's carriers to the shared tail's, through the walk's node map. `memPost_goal`, `memPost_goalC`: a halted cut's
goals from the reference held. -/

variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat}

/-- **The link into the shared tail**: the target and server kept, the tail's carriers read through the walk's node map. -/
theorem memPost_link {toksC toks : Nat → Nat → Nat} {CrC Cr : Nat → List (Option Nat × Option Nat)} {L : Nat} {x y : SegInst FF}
    {σ : Nat → Nat} (ht : y.t = x.t) (hC : y.C = x.C) (hn : ∀ c, y.M.node c = x.M.node (σ c))
    (hto : σ (toks π.length 0) = toksC π.length 0)
    (hcr : (Cr π.length).map (fun p => (p.1.map σ, p.2.map σ)) = CrC π.length)
    (hm : memPost P KR NE net env π 0 toksC CrC L x) : memPost P KR NE net env π 0 toks Cr L y := by
  intro hL
  subst hL
  obtain ⟨kind, hp⟩ := hm rfl
  refine ⟨kind, hp.congr ht hC (fun k hk => ?_) ?_⟩
  · obtain rfl : k = 0 := by omega
    rw [hn, hto]
  · rw [← hcr, cachesAt_comp]
    congr 1
    exact funext hn

/-- **A halted cut's goal at `k` tokens**, the reference held far enough. -/
theorem memPost_goal {j k NB : Nat} {toks : Nat → Nat → Nat} {Cr : Nat → List (Option Nat × Option Nat)} {x : SegInst FF}
    (hm : memPost P KR NE net env π j toks Cr π.length x) (hk : k ≤ j + 1) :
    ∃ kind, goalMV P KR NE net env π kind NB k x.t x.C := by
  obtain ⟨kind, hp⟩ := hm rfl
  exact ⟨kind, (hp x.C.tab (Host.Ts.Sim.CSrv.Le.refl _)).toGFV hk⟩

/-- **A halted cut's goal without EOS at `j + 1` tokens**: the program's caches at the carriers of time `L + j`. -/
theorem memPost_goalC {j NB : Nat} {je : Host.Ts.Env} {toks : Nat → Nat → Nat} {Cr : Nat → List (Option Nat × Option Nat)}
    {x : SegInst FF} (hL1 : 1 ≤ π.length) (hm : memPost P KR NE net env π j toks Cr π.length x)
    (hc : ∃ cs, Host.Ts.Sim.ExtractSim.cachesT (x.t.reFfi (Layers.toLoad x.t.ffi)) je = some cs ∧
      cs.map cacheNodePair = (Cr π.length).map fun p => (p.1.map x.M.node, p.2.map x.M.node)) :
    ∃ kind, goalCV P KR NE net env π kind NB (j + 1) je x.t x.C := by
  obtain ⟨kind, hp⟩ := hm rfl
  have h := hp x.C.tab (Host.Ts.Sim.CSrv.Le.refl _)
  obtain ⟨cs, hcs, hn⟩ := hc
  refine ⟨kind, h.toGFV (Nat.le_refl _), cs, x.M.node (toks π.length j), hcs, ?_⟩
  have hf := h.forward
  rw [show π.length + (j + 1) - 1 = π.length + j by omega]
  exact forwardAtV_congrC hf ((cachesAt_nodes _ _).trans hn.symm)

end Host.Route.PrefGraph
