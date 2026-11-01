import host.route.cert.Row.Tmpl
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

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (env : FfiEval.Env InKey)
  (kind : Nat → Option Compiled)

local notation "Mx" => P.toMlxContract
local notation "Kx" => KR.toKernelContract
local notation "Vs" => routeVs P KR env kind

theorem layout_eq (table : List F64) :
    chainLayout (stageWeights (weights (firstValues Mx Kx env table))) (populatedLayoutHandles 256) = stages :=
  Host.Mlx.SimGraph.Mach.decode_layout (contents Mx Kx env (firstFfiGraph table))

theorem head_eq (table : List F64) : linLayout .affineRow (weights (firstValues Mx Kx env table)).head = head :=
  Host.Mlx.SimGraph.Mach.decode_head_layout (contents Mx Kx env (firstFfiGraph table))

theorem caps_eq (table : List F64) :
    CapsFor 256 (stageWeights (weights (firstValues Mx Kx env table))) (populatedLayoutHandles 256) :=
  Host.Mlx.SimGraph.Mach.decode_layout_caps (contents Mx Kx env (firstFfiGraph table))

end Host.Route.Cert.Row
