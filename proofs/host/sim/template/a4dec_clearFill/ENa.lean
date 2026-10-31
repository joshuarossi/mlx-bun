import host.sim.template.a4dec_clearFill.ERestart
import host.sim.template.a4dec.Closed
import host.sim.template.NShiftOf
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The native part of chain `DEC_clearFill`'s end shift (`NShift DEC_clearFill.PE` on `toLoad`, `nshift_of`): the small checks. -/

noncomputable abbrev DEC_clearFill.X0 : NSt := (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx
noncomputable abbrev DEC_clearFill.X1 : NSt := (Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx

kernel_rfl DEC_clearFill.nnh0 : DEC_clearFill.R.data.nh0 = DEC_clearFill.X0.next
kernel_rfl DEC_clearFill.nnh1 : DEC_clearFill.R.data.nh1 = DEC_clearFill.X1.next
kernel_rfl DEC_clearFill.nnn0 : DEC_clearFill.R.data.nn0 = DEC_clearFill.X0.nnext
kernel_rfl DEC_clearFill.nnn1 : DEC_clearFill.R.data.nn1 = DEC_clearFill.X1.nnext
kernel_rfl DEC_clearFill.nlo : (Nat.blt 0 DEC_clearFill.PE.lo && Nat.ble DEC_clearFill.PE.lo DEC_clearFill.X0.next && Nat.ble DEC_clearFill.PE.lo RData.bigHi && Nat.ble RData.bigHi DEC_clearFill.PE.E) = true
kernel_rfl DEC_clearFill.ncnt : (Nat.ble DEC_clearFill.X0.next DEC_clearFill.X1.next && Nat.ble DEC_clearFill.X0.nnext DEC_clearFill.X1.nnext) = true
kernel_rfl DEC_clearFill.nnband : (Nat.blt 0 DEC_clearFill.PE.NL && Nat.ble DEC_clearFill.PE.NL DEC_clearFill.PE.N0 && Nat.ble DEC_clearFill.PE.N0 DEC_clearFill.X0.nnext) = true
kernel_rfl DEC_clearFill.nhbelow : DEC_clearFill.R.data.checkHndBelow = true
kernel_rfl DEC_clearFill.nhren : checkRenG DEC_clearFill.R.data.hnd DEC_clearFill.R.hinv (phB DEC_clearFill.X0) = true
kernel_rfl DEC_clearFill.nband : DEC_clearFill.R.data.checkBand DEC_clearFill.PE.lo = true
kernel_rfl DEC_clearFill.nnh1pos : Nat.blt 0 DEC_clearFill.R.data.nh1 = true
kernel_rfl DEC_clearFill.nnren : checkRenG DEC_clearFill.R.data.node DEC_clearFill.R.ninv (pnB DEC_clearFill.X0) = true
kernel_rfl DEC_clearFill.nnlow : (PTrie.keysA DEC_clearFill.R.data.node).all (fun j => Nat.ble DEC_clearFill.PE.NL j && Nat.blt (DEC_clearFill.R.data.nodeF j) DEC_clearFill.X1.nnext) = true
kernel_rfl DEC_clearFill.nnord : (fullAbove DEC_clearFill.PE DEC_clearFill.X0).all (fun i => Nat.ble i (DEC_clearFill.R.data.nodeF i) &&
  (PTrie.keysA DEC_clearFill.R.data.node).all fun j => !Nat.blt j i || Nat.blt (DEC_clearFill.R.data.nodeF j) (DEC_clearFill.R.data.nodeF i)) = true
kernel_rfl DEC_clearFill.nitems : (PTrie.keysA DEC_clearFill.X0.items).all (pnB DEC_clearFill.X0) = true
kernel_rfl DEC_clearFill.nssT : checkSSt DT.n DEC_clearFill.X0 = true
kernel_rfl DEC_clearFill.nabs0a : DEC_clearFill.X0.arrs.get 0 = none
kernel_rfl DEC_clearFill.nabs0b : DEC_clearFill.X0.objs.get 0 = none
kernel_rfl DEC_clearFill.ntok1 : DEC_clearFill.X1.tokens = []
kernel_rfl DEC_clearFill.npend : DEC_clearFill.X1.pending = DEC_clearFill.X0.pending.map DEC_clearFill.σ.pend
kernel_rfl DEC_clearFill.nerrh : DEC_clearFill.X1.errh = DEC_clearFill.X0.errh.map DEC_clearFill.σ.arg
kernel_rfl DEC_clearFill.nfiles : DEC_clearFill.X1.files = DEC_clearFill.X0.files
kernel_rfl DEC_clearFill.narch : DEC_clearFill.X1.arch = DEC_clearFill.X0.arch
kernel_rfl DEC_clearFill.nsizes : DEC_clearFill.X1.deviceSizes = DEC_clearFill.X0.deviceSizes
kernel_rfl DEC_clearFill.nwired : DEC_clearFill.X1.wired = DEC_clearFill.X0.wired
kernel_rfl DEC_clearFill.nhost : (Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).host = (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).host

end Host.Load.Run.Tpl
