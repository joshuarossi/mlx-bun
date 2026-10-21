import host.sim.template.base.LoadRA
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Node)
open Host.Load.Run.Full (P.s3272)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Kernel checks of the native base relation (`host.sim.template.base.LoadR`), split by
size so that each module stays under the memory cap: the full nodes' primitives and the template's closedness. -/

kernel_rfl Base.prims_check :
  (fullKeys 20000 Base.X0).map (fun i => (Base.Y0.nodes.get (Base.M.node i)).map Node.prim) =
    (fullKeys 20000 Base.X0).map (fun i => (Base.X0.nodes.get i).map fun nd => Base.M.prim nd.prim)
kernel_rfl Base.ssT : checkSSt Base.n Base.X0 = true

end Host.Load.Run.Tpl
