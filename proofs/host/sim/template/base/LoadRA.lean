import host.sim.template.base.Rel
import host.sim.template.NShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Node)
open Host.Load.Run.Full (P.s3272)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Kernel checks of the native base relation (`host.sim.template.base.LoadR`), split by
size so that each module stays under the memory cap: the cut's native state, the
counters, the handles and the small fields. -/

/-- The cut's native state with unread token suffix `τ`. -/
noncomputable def Base.Y (τ : List NumV) : Host.Load.LSt :=
  { (P.s3272.ffi : Host.Load.LSt) with mlx := { (P.s3272.ffi : Host.Load.LSt).mlx with tokens := .ref 2 :: τ } }

noncomputable abbrev Base.X0 : NSt := Base.s0.ffi.mlx
noncomputable abbrev Base.Y0 : NSt := (P.s3272.ffi : Host.Load.LSt).mlx

kernel_rfl Base.next_same : Base.Y0.next = Base.X0.next
kernel_rfl Base.nnext_same : Base.Y0.nnext = Base.X0.nnext
kernel_rfl Base.x0next : Base.X0.next = 29302
kernel_rfl Base.x0nnext : Base.X0.nnext = 22539
kernel_rfl Base.items0 : PTrie.keys Base.X0.items = []
kernel_rfl Base.absent0a : Base.X0.arrs.get 0 = none
kernel_rfl Base.absent0b : Base.X0.objs.get 0 = none
kernel_rfl Base.absent0c : Base.Y0.objs.get 0 = none
kernel_rfl Base.pending_eq : Base.Y0.pending = Base.X0.pending.map Base.M.pend
kernel_rfl Base.errh_eq : Base.Y0.errh = Base.X0.errh.map Base.M.arg
kernel_rfl Base.files_eq : Base.Y0.files = Base.X0.files
kernel_rfl Base.arch_eq : Base.Y0.arch = Base.X0.arch
kernel_rfl Base.sizes_eq : Base.Y0.deviceSizes = Base.X0.deviceSizes
kernel_rfl Base.wired_eq : Base.Y0.wired = Base.X0.wired
kernel_rfl Base.host_eq : (P.s3272.ffi : Host.Load.LSt).host = Base.s0.ffi.host
kernel_rfl Base.hostLt_check : (entriesK Base.s0.ffi.host.objs 0 1).all (fun p => Nat.blt p.1 (2 ^ 46)) = true
kernel_rfl Base.num79 : Base.M.nv (.ref 79) = .ref 2
kernel_rfl Base.yitems_check : (PTrie.keys Base.Y0.items).all (fun k => Nat.blt k Base.Y0.nnext) = true
kernel_rfl Base.handles_check : (handlesOf Base.X0).all (handleOK Base.M 25000 Base.X0 Base.Y0) = true

end Host.Load.Run.Tpl
