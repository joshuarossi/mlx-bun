import host.load.boot.ld.N
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Node)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Kernel checks of the native relation at `loadDone`: the handles, objects, nodes, readback memo
and closedness of the template's native state. -/

kernel_rfl Ld.handles_check : (handlesOf Ld.X0).all (handleOK Map.id 1 Ld.X0 Ld.X0) = true
kernel_rfl Ld.objs_check :
  (PTrie.keys Ld.X0.objs).map (fun h => Ld.X0.objs.get (Map.id.handle h)) =
    (PTrie.keys Ld.X0.objs).map (fun h => (Ld.X0.objs.get h).map Map.id.nobj)
kernel_rfl Ld.objok_check : (PTrie.keys Ld.X0.objs).all (objOK Map.id 15235 Ld.X0) = true
kernel_rfl Ld.nodes_check : (PTrie.keys Ld.X0.nodes).all (nodeOK Map.id 15235 Ld.X0 Ld.X0) = true
kernel_rfl Ld.prims_check :
  (fullKeys 15235 Ld.X0).map (fun i => (Ld.X0.nodes.get (Map.id.node i)).map Node.prim) =
    (fullKeys 15235 Ld.X0).map (fun i => (Ld.X0.nodes.get i).map fun nd => Map.id.prim nd.prim)
kernel_rfl Ld.items_check : (PTrie.keys Ld.X0.items).all (fun k => (Ld.X0.nodes.get k).isSome && Nat.blt k 15235) = true
kernel_rfl Ld.ssT : checkSSt Ld.S0.tab.length Ld.X0 = true

end Host.Load.Run.Prompt
