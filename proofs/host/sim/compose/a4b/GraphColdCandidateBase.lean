import host.sim.compose.a4b.GraphColdNative
import host.sim.compose.a4b.GraphColdEval
import host.load.CacheCarriersCommand
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

/-- Search data only: load primitives cannot be expected non-input operations.
Every original native index is retained as an array position. -/
noncomputable def candidateAt (i : Nat) : Option (RNode PDim InKey) := do
  if !tplDom NL N0 fixedBigs endLoad.ffi.mlx i then none else do
    let nd ← endLoad.ffi.mlx.nodes.get i
    match nd.prim with
    | .load _ _ => none
    | _ => resolveNode (coldNums endSrv) (kernelName? SourceKernels.sources endLoad.ffi.mlx) nd

def candidateInputs : InKey → Option Nat :=
  inputNode Host.Load.Run.Full.parameterChoice ⟨0, tokenNode, ⟨.zeros, [], [], 0⟩⟩
end Host.Ts.Sim.Compose.ColdGraph
