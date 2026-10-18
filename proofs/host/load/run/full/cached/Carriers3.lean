import host.load.run.full.cached.Choice5
import host.load.run.full.cached.Choice2
import host.load.run.full.cached.expected3.Join
import host.load.CarrierChoice
namespace Host.Load.Run.Full.Cached
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
/-- The real device feedback tensor; its node is checked in the source graph
before the numerical bridge is used. The array handle is not needed by the
carrier certificate. -/
def token3 : Tensor := ⟨0,20158,{prim := .reshape [.lit 1,.lit 1],ins := [20157],shape := [.lit 1,.lit 1],dtype := 3}⟩
ffi_value_literal selected3 : (CarrierChoice.choose after5.graph SourceKernels.sources Expected3.graph (inputNode after2 token3) token3.node 22539).toOption.getD []
def carriers3 : List Nat := selected3
theorem carriers3_before_next_forward : carriers3.all (fun i => decide (i < 22539)) = true := rfl
end Host.Load.Run.Full.Cached
