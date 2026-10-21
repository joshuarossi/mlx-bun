import host.simgraph.iter.BaseKernels
import host.simgraph.iter.BaseMisc
import host.load.run.tail.Short1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Run.Full Host.Load.Run.Full.Cached Host.Ts Host.Load.Run.Tail

/-! Concrete facts of the 1-token budget's halted state against the five-token terminal state. -/

kernel_rfl short1_nodes_check :
  (List.range 17777).map (fun j => (Short1.s4.ffi : LSt).mlx.nodes.get j) =
    (List.range 17777).map (fun j => (P.s3573.ffi : LSt).mlx.nodes.get j)
kernel_rfl short1_kernels_check :
  (Sim.Template.PTrie.keys (P.s3573.ffi : LSt).mlx.objs).map (fun k => atKernel ((P.s3573.ffi : LSt).mlx.objs.get k) ((P.s3573.ffi : LSt).mlx.objs.get k)) =
    (Sim.Template.PTrie.keys (P.s3573.ffi : LSt).mlx.objs).map (fun k => atKernel ((P.s3573.ffi : LSt).mlx.objs.get k) ((Short1.s4.ffi : LSt).mlx.objs.get k))
kernel_rfl short1_items_eq : (Short1.s4.ffi : LSt).mlx.items = (PTrie.nil : PTrie NumV).set 17776 (.ref 1)
kernel_rfl short1_ref1 : nth? Short1.S4.tab 1 = some (.var 1)
kernel_rfl short1_below1 : cachesBelowB firstChoice.cache 17777 = true

end Host.Mlx.SimGraph.Iter
