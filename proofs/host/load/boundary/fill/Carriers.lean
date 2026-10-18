import host.load.boundary.fill.Parameters
import host.load.boundary.fill.expected.Join
namespace Host.Load.Run.Full.Fill64
open Host.Ts Host.Load.Extract Host.Load.CacheBoundary Host.Mlx Host.Mlx.FfiEval
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def inputToken : Tensor := ⟨0,22539,{prim := .reshape [.lit 1,.lit 1],ins := [22538],shape := [.lit 1,.lit 1],dtype := 3}⟩
load_boundary_carriers carriers : s1491, Expected.graph, before, inputToken
noncomputable def graph (table : List F64) : Nat → Option (RNode Int InKey) :=
  ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources s1491.ffi.mlx

theorem feedback_node (table : List F64) : graph table inputToken.node = some ⟨.reshape [1,1],[22538]⟩ := rfl
end Host.Load.Run.Full.Fill64
