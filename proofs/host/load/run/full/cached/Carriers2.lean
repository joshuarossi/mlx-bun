import host.load.run.full.cached.Choice5
import host.load.run.full.cached.expected2.Join
import host.load.CarrierChoice
namespace Host.Load.Run.Full.Cached
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
/-- The real device feedback tensor; its node is checked in the source graph
before the numerical bridge is used. The array handle is not needed by the
carrier certificate. -/
def token2 : Tensor := ⟨0,17777,{prim := .reshape [.lit 1,.lit 1],ins := [17776],shape := [.lit 1,.lit 1],dtype := 3}⟩
ffi_value_literal selected2 : (CarrierChoice.choose after5.graph SourceKernels.sources Expected2.graph (inputNode firstChoice token2) token2.node 20158).toOption.getD []
def carriers2 : List Nat := selected2
theorem carriers2_before_next_forward : carriers2.all (fun i => decide (i < 20158)) = true := rfl
end Host.Load.Run.Full.Cached
