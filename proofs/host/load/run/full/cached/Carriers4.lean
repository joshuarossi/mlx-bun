import host.load.run.full.cached.Choice5
import host.load.run.full.cached.Choice3
import host.load.run.full.cached.expected4.Join
import host.load.CarrierChoice
namespace Host.Load.Run.Full.Cached
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
/-- The real device feedback tensor; its node is checked in the source graph
before the numerical bridge is used. The array handle is not needed by the
carrier certificate. -/
def token4 : Tensor := ⟨0,22539,{prim := .reshape [.lit 1,.lit 1],ins := [22538],shape := [.lit 1,.lit 1],dtype := 3}⟩
ffi_value_literal selected4 : (CarrierChoice.choose after5.graph SourceKernels.sources Expected4.graph (inputNode after3 token4) token4.node 24920).toOption.getD []
def carriers4 : List Nat := selected4
theorem carriers4_before_next_forward : carriers4.all (fun i => decide (i < 24920)) = true := rfl
end Host.Load.Run.Full.Cached
