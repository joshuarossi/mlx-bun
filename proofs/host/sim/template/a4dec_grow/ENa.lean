import host.sim.template.a4dec_grow.ERestart
import host.sim.template.a4dec.Closed
import host.sim.template.NShiftOf
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The native part of chain `DEC_grow`'s end shift (`NShift DEC_grow.PE` on `toLoad`, `nshift_of`): the small checks. -/

noncomputable abbrev DEC_grow.X0 : NSt := (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx
noncomputable abbrev DEC_grow.X1 : NSt := (Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx

kernel_rfl DEC_grow.nnh0 : DEC_grow.R.data.nh0 = DEC_grow.X0.next
kernel_rfl DEC_grow.nnh1 : DEC_grow.R.data.nh1 = DEC_grow.X1.next
kernel_rfl DEC_grow.nnn0 : DEC_grow.R.data.nn0 = DEC_grow.X0.nnext
kernel_rfl DEC_grow.nnn1 : DEC_grow.R.data.nn1 = DEC_grow.X1.nnext
kernel_rfl DEC_grow.nlo : (Nat.blt 0 DEC_grow.PE.lo && Nat.ble DEC_grow.PE.lo DEC_grow.X0.next && Nat.ble DEC_grow.PE.lo RData.bigHi && Nat.ble RData.bigHi DEC_grow.PE.E) = true
kernel_rfl DEC_grow.ncnt : (Nat.ble DEC_grow.X0.next DEC_grow.X1.next && Nat.ble DEC_grow.X0.nnext DEC_grow.X1.nnext) = true
kernel_rfl DEC_grow.nnband : (Nat.blt 0 DEC_grow.PE.NL && Nat.ble DEC_grow.PE.NL DEC_grow.PE.N0 && Nat.ble DEC_grow.PE.N0 DEC_grow.X0.nnext) = true
kernel_rfl DEC_grow.nhbelow : DEC_grow.R.data.checkHndBelow = true
kernel_rfl DEC_grow.nhren : checkRenG DEC_grow.R.data.hnd DEC_grow.R.hinv (phB DEC_grow.X0) = true
kernel_rfl DEC_grow.nband : DEC_grow.R.data.checkBand DEC_grow.PE.lo = true
kernel_rfl DEC_grow.nnh1pos : Nat.blt 0 DEC_grow.R.data.nh1 = true
kernel_rfl DEC_grow.nnren : checkRenG DEC_grow.R.data.node DEC_grow.R.ninv (pnB DEC_grow.X0) = true
kernel_rfl DEC_grow.nnlow : (PTrie.keysA DEC_grow.R.data.node).all (fun j => Nat.ble DEC_grow.PE.NL j && Nat.blt (DEC_grow.R.data.nodeF j) DEC_grow.X1.nnext) = true
kernel_rfl DEC_grow.nnord : (fullAbove DEC_grow.PE DEC_grow.X0).all (fun i => Nat.ble i (DEC_grow.R.data.nodeF i) &&
  (PTrie.keysA DEC_grow.R.data.node).all fun j => !Nat.blt j i || Nat.blt (DEC_grow.R.data.nodeF j) (DEC_grow.R.data.nodeF i)) = true
kernel_rfl DEC_grow.nitems : (PTrie.keysA DEC_grow.X0.items).all (pnB DEC_grow.X0) = true
kernel_rfl DEC_grow.nssT : checkSSt DT.n DEC_grow.X0 = true
kernel_rfl DEC_grow.nabs0a : DEC_grow.X0.arrs.get 0 = none
kernel_rfl DEC_grow.nabs0b : DEC_grow.X0.objs.get 0 = none
kernel_rfl DEC_grow.ntok1 : DEC_grow.X1.tokens = []
kernel_rfl DEC_grow.npend : DEC_grow.X1.pending = DEC_grow.X0.pending.map DEC_grow.σ.pend
kernel_rfl DEC_grow.nerrh : DEC_grow.X1.errh = DEC_grow.X0.errh.map DEC_grow.σ.arg
kernel_rfl DEC_grow.nfiles : DEC_grow.X1.files = DEC_grow.X0.files
kernel_rfl DEC_grow.narch : DEC_grow.X1.arch = DEC_grow.X0.arch
kernel_rfl DEC_grow.nsizes : DEC_grow.X1.deviceSizes = DEC_grow.X0.deviceSizes
kernel_rfl DEC_grow.nwired : DEC_grow.X1.wired = DEC_grow.X0.wired
kernel_rfl DEC_grow.nhost : (Host.Load.Layers.toLoad DEC_grow.s11.ffi).host = (Host.Load.Layers.toLoad DEC_grow.s0.ffi).host

end Host.Load.Run.Tpl
