import host.sim.template.base.LoadRA
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Node)
open Host.Load.Run.Full (P.s3272)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Kernel checks of the native base relation (`host.sim.template.base.LoadR`), split by
size so that each module stays under the memory cap: the template's nodes. -/

kernel_rfl Base.nodes_check : (PTrie.keys Base.X0.nodes).all (nodeOK Base.M 20000 Base.X0 Base.Y0) = true

end Host.Load.Run.Tpl
