import host.route.sat.Main
import host.route.Gen
set_option maxRecDepth 1000000

namespace Host.Route.Sat
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Mach (AneNetOk)
open Host.Ts.Sim.Full (fullWorldXD)

/-! # The trust boundary against the route's theorem

`NE.Succeeds` at every Neural Engine side from `RouteTrust.evaluates`, and `route_gen` (the layer `route_main` applies)
at any `RouteTrust`: every trust premise of the theorem is discharged from the structure, so its fields are the
theorem's premises, at the theorem's types. -/

/-- **The Neural Engine succeeds at every Neural Engine side**, in particular at `route_main`'s `netLd`. -/
theorem RouteTrust.succeeds (W : RouteTrust) (net : Host.Mlx.SimGraph.Ref.AneNet) : W.NE.Succeeds net :=
  fun _ _ _ _ _ _ _ _ => W.evaluates _ _

/-- **`route_gen` at a model of the trust boundary**: what remains are the prompt's and budget's bounds and the
route's own premises. -/
theorem route_gen_trust (W : RouteTrust) (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hlt : ∀ t ∈ π, t < 248320)
    (hT : 1 ≤ T) (hctx : π.length + T ≤ 262144) (net : Host.Mlx.SimGraph.Ref.AneNet)
    (hnet : ∀ tab, AneNetOk net (stageWeights (weights (firstValues W.P.toMlxContract
      (routeKernel W.G W.B W.Pg W.lseSum W.lseNumerator).toKernelContract W.env tab))))
    {s0ld : St Host.Ts.Sim.Full.FF.S} (s : St LSt)
    (hs : bootL (RoutePrompt.cx π) (routeWorld T (machTok W.P (routeKernel W.G W.B W.Pg W.lseSum W.lseNumerator)
      W.NE net W.env π)) 2000 = some s)
    (Gn : RouteGen W.P (routeKernel W.G W.B W.Pg W.lseSum W.lseNumerator) W.NE net W.env π T
      (machTok W.P (routeKernel W.G W.B W.Pg W.lseSum W.lseNumerator) W.NE net W.env π) (entryEnv s)
      chars!"emitted" s0ld)
    (hboot : ∃ N0 tL CL, runC (fullWorldXD Gn.NB).F N0 (bootStart s)
      (routeServer T (machTok W.P (routeKernel W.G W.B W.Pg W.lseSum W.lseNumerator) W.NE net W.env π)) =
        some (tL, CL) ∧ (Gn.I.ld π.length).Inv tL CL) :
    RouteOutcomeV W.P (routeKernel W.G W.B W.Pg W.lseSum W.lseNumerator) W.NE net W.env W.leaves W.typed π Gn.kind T s
      Gn.NB :=
  route_gen W.P W.G W.Pg W.B W.lseSum W.lseNumerator W.NE W.env W.leaves W.typed π T hπ hlt hT hctx net
    (W.succeeds net) hnet s hs Gn hboot

end Host.Route.Sat
