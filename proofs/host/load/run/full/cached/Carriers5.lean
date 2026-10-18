import host.load.run.full.cached.Choice5
import host.load.run.full.cached.Choice4
import host.load.run.full.cached.expected5.Join
import host.load.CarrierChoice
namespace Host.Load.Run.Full.Cached
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
/-- The real device feedback tensor; its node is checked in the source graph
before the numerical bridge is used. The array handle is not needed by the
carrier certificate. -/
def token5 : Tensor := ⟨0,24920,{prim := .reshape [.lit 1,.lit 1],ins := [24919],shape := [.lit 1,.lit 1],dtype := 3}⟩
ffi_value_literal selected5 : (CarrierChoice.choose after5.graph SourceKernels.sources Expected5.graph (inputNode after4 token5) token5.node 27301).toOption.getD []
def carriers5 : List Nat := selected5
theorem carriers5_before_next_forward : carriers5.all (fun i => decide (i < 27301)) = true := rfl
end Host.Load.Run.Full.Cached
