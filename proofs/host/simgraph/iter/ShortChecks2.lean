import host.simgraph.iter.BaseKernels
import host.simgraph.iter.BaseMisc
import host.load.run.tail.Short2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Run.Full Host.Load.Run.Full.Cached Host.Ts Host.Load.Run.Tail

/-! Concrete facts of the 2-token budget's halted state against the five-token terminal state. -/

kernel_rfl short2_nodes_check :
  (List.range 20158).map (fun j => (Short2.s2.ffi : LSt).mlx.nodes.get j) =
    (List.range 20158).map (fun j => (P.s3573.ffi : LSt).mlx.nodes.get j)
kernel_rfl short2_kernels_check :
  (Sim.Template.PTrie.keys (P.s3573.ffi : LSt).mlx.objs).map (fun k => atKernel ((P.s3573.ffi : LSt).mlx.objs.get k) ((P.s3573.ffi : LSt).mlx.objs.get k)) =
    (Sim.Template.PTrie.keys (P.s3573.ffi : LSt).mlx.objs).map (fun k => atKernel ((P.s3573.ffi : LSt).mlx.objs.get k) ((Short2.s2.ffi : LSt).mlx.objs.get k))
kernel_rfl short2_items_eq :
  (Short2.s2.ffi : LSt).mlx.items = ((PTrie.nil : PTrie NumV).set 17776 (.ref 1)).set 20157 (.ref 2)
kernel_rfl short2_ref1 : nth? Short2.S2.tab 1 = some (.var 1)
kernel_rfl short2_ref2 : nth? Short2.S2.tab 2 = some (.var 2)
kernel_rfl short2_below1 : cachesBelowB firstChoice.cache 20158 = true
kernel_rfl short2_below2 : cachesBelowB after2.cache 20158 = true

end Host.Mlx.SimGraph.Iter
