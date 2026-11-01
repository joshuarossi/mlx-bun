import host.route.PrefGraph
import host.route.FinalV
import host.simgraph.mach.Agree
import host.load.boot.ane.Graph
import host.load.run.full.FirstValues
import host.load.ProgramEquality
import host.load.ProgramMatchCommand
import host.mlx.KernelSources
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Ts Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Load.Run.Prompt (Ld.X0 Ld.Yn ldStT ldStT_mlx)
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)

/-! # The graph side at the load cut

`coldG_ld`: the boot's end state holds the prefill's cold bookkeeping (`ColdG`) at the route's values: the checkpoint's
parameters at their nodes (the load program is on the loaded graph, `ld_matches`) and no readback yet (`ld_items`). -/

load_program_matches ld_matches : code, code.cert, Ld.X0

kernel_rfl ld_keys : Host.Ts.Sim.Template.PTrie.keys Ld.X0.items = []
kernel_rfl ld_nnext : Ld.X0.nnext = 15235
kernel_rfl ld_params_below : (parameterTensors parameterChoice).all (fun t => t.node < 15235) = true

theorem ld_items (k : Nat) : Ld.X0.items.get k = none := by
  cases hg : Ld.X0.items.get k with
  | none => rfl
  | some v =>
    have := Host.Ts.Sim.Template.PTrie.mem_keys _ _ _ hg
    rw [ld_keys] at this
    cases this

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (kind : Nat → Option Compiled)

/-- The checkpoint's parameters at the loaded graph, at the route's values. -/
theorem ld_param (leaves : Leaves code env.weights) (tab : List F64) (τ : List NumV) (p : Tensor)
    (hp : p ∈ parameterTensors parameterChoice) :
    Host.Mlx.SimGraph.Mach.routeVal P KR env kind (fun _ => none) tab (Ld.Yn τ) p.node =
      some (firstValues P.toMlxContract KR.toKernelContract env tab p) := by
  have hg : (ffiGraph (concrete (CSrv.val ⟨tab⟩)) SourceKernels.sources (Ld.Yn τ) : Nat → Option (RNode Int InKey)) =
      ffiGraph (concrete (CSrv.val ⟨tab⟩)) SourceKernels.sources Ld.X0 := rfl
  have value := parameter_evaluated P.toMlxContract KR.toKernelContract env
    (ffiGraph (concrete (CSrv.val ⟨tab⟩)) SourceKernels.sources Ld.X0) leaves
    (ld_matches tab SourceKernels.sources) p hp
  have same := parameter_values_eq P.toMlxContract KR.toKernelContract env
    (ffiGraph (concrete (CSrv.val ⟨tab⟩)) SourceKernels.sources Ld.X0) (firstFfiGraph tab)
    code code.cert (parameterTensors parameterChoice)
    (ld_matches tab SourceKernels.sources)
    (first_load_matches tab SourceKernels.sources) code.covers p hp
  refine Host.Mlx.SimGraph.Mach.evalR_routeVal P KR env kind (fun _ => none) tab (Ld.Yn τ) _ _ ?_
  change evalR P.toMlxContract KR.toKernelContract env
    (ffiGraph (concrete (CSrv.val ⟨tab⟩)) SourceKernels.sources (Ld.Yn τ)) p.node = _
  rw [hg]
  exact value.trans (congrArg some same)

/-- **The boot's end state holds the cold bookkeeping**, for every prompt and readback suffix. -/
theorem coldG_ld (leaves : Leaves code env.weights) (fw : List Val) (τ : List NumV) {x : SegInst FF}
    (ht : x.t = ldStT fw τ) :
    ColdG P KR net env (fun _ => routeVs P KR env kind) (fun _ _ => True) x := by
  intro tab _
  rw [ht]
  refine ⟨⟨Host.Mlx.SimGraph.Mach.routeVals_ok_empty P KR env kind _, fun p hp => ?_, ?_, ?_⟩, trivial⟩
  · rw [ldStT_mlx]
    refine ⟨ld_param P KR env kind leaves tab τ p hp, ?_⟩
    have hlt := List.all_eq_true.mp ld_params_below p hp
    have hnn : (Ld.Yn τ).nnext = 15235 := ld_nnext
    rw [hnn]
    exact of_decide_eq_true hlt
  · rw [ldStT_mlx]
    intro node value hv
    have hn : (Ld.Yn τ).items.get node = Ld.X0.items.get node := rfl
    rw [hn, ld_items] at hv
    cases hv
  · rw [ldStT_mlx]
    intro k _
    exact ld_items k

end Host.Route.PrefGraph
