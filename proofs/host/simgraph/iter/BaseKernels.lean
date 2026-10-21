import host.load.run.full.H111
import host.sim.template.Keys
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Mlx.SimGraph.Iter
open Host.Ts Host.Load Host.Load.Run.Full

/-! Every Metal kernel object of the five-token terminal state `P.s3573` is already
an object of the first ordinary readback cut `P.s3272`. -/

/-- `o'` where `o` is a kernel object. -/
def atKernel (o o' : Option Host.Mlx.Ffi.Obj) : Option Host.Mlx.Ffi.Obj :=
  match o with
  | some (.kernel ..) => o'
  | _ => none

kernel_rfl base_kernels_check :
  (Sim.Template.PTrie.keys (P.s3573.ffi : LSt).mlx.objs).map
      (fun k => atKernel ((P.s3573.ffi : LSt).mlx.objs.get k) ((P.s3573.ffi : LSt).mlx.objs.get k)) =
    (Sim.Template.PTrie.keys (P.s3573.ffi : LSt).mlx.objs).map
      (fun k => atKernel ((P.s3573.ffi : LSt).mlx.objs.get k) ((P.s3272.ffi : LSt).mlx.objs.get k))

end Host.Mlx.SimGraph.Iter
