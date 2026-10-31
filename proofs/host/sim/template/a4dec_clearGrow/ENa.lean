import host.sim.template.a4dec_clearGrow.ERestart
import host.sim.template.a4dec.Closed
import host.sim.template.NShiftOf
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The native part of chain `DEC_clearGrow`'s end shift (`NShift DEC_clearGrow.PE` on `toLoad`, `nshift_of`): the small checks. -/

noncomputable abbrev DEC_clearGrow.X0 : NSt := (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx
noncomputable abbrev DEC_clearGrow.X1 : NSt := (Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx

kernel_rfl DEC_clearGrow.nnh0 : DEC_clearGrow.R.data.nh0 = DEC_clearGrow.X0.next
kernel_rfl DEC_clearGrow.nnh1 : DEC_clearGrow.R.data.nh1 = DEC_clearGrow.X1.next
kernel_rfl DEC_clearGrow.nnn0 : DEC_clearGrow.R.data.nn0 = DEC_clearGrow.X0.nnext
kernel_rfl DEC_clearGrow.nnn1 : DEC_clearGrow.R.data.nn1 = DEC_clearGrow.X1.nnext
kernel_rfl DEC_clearGrow.nlo : (Nat.blt 0 DEC_clearGrow.PE.lo && Nat.ble DEC_clearGrow.PE.lo DEC_clearGrow.X0.next && Nat.ble DEC_clearGrow.PE.lo RData.bigHi && Nat.ble RData.bigHi DEC_clearGrow.PE.E) = true
kernel_rfl DEC_clearGrow.ncnt : (Nat.ble DEC_clearGrow.X0.next DEC_clearGrow.X1.next && Nat.ble DEC_clearGrow.X0.nnext DEC_clearGrow.X1.nnext) = true
kernel_rfl DEC_clearGrow.nnband : (Nat.blt 0 DEC_clearGrow.PE.NL && Nat.ble DEC_clearGrow.PE.NL DEC_clearGrow.PE.N0 && Nat.ble DEC_clearGrow.PE.N0 DEC_clearGrow.X0.nnext) = true
kernel_rfl DEC_clearGrow.nhbelow : DEC_clearGrow.R.data.checkHndBelow = true
kernel_rfl DEC_clearGrow.nhren : checkRenG DEC_clearGrow.R.data.hnd DEC_clearGrow.R.hinv (phB DEC_clearGrow.X0) = true
kernel_rfl DEC_clearGrow.nband : DEC_clearGrow.R.data.checkBand DEC_clearGrow.PE.lo = true
kernel_rfl DEC_clearGrow.nnh1pos : Nat.blt 0 DEC_clearGrow.R.data.nh1 = true
kernel_rfl DEC_clearGrow.nnren : checkRenG DEC_clearGrow.R.data.node DEC_clearGrow.R.ninv (pnB DEC_clearGrow.X0) = true
kernel_rfl DEC_clearGrow.nnlow : (PTrie.keysA DEC_clearGrow.R.data.node).all (fun j => Nat.ble DEC_clearGrow.PE.NL j && Nat.blt (DEC_clearGrow.R.data.nodeF j) DEC_clearGrow.X1.nnext) = true
kernel_rfl DEC_clearGrow.nnord : (fullAbove DEC_clearGrow.PE DEC_clearGrow.X0).all (fun i => Nat.ble i (DEC_clearGrow.R.data.nodeF i) &&
  (PTrie.keysA DEC_clearGrow.R.data.node).all fun j => !Nat.blt j i || Nat.blt (DEC_clearGrow.R.data.nodeF j) (DEC_clearGrow.R.data.nodeF i)) = true
kernel_rfl DEC_clearGrow.nitems : (PTrie.keysA DEC_clearGrow.X0.items).all (pnB DEC_clearGrow.X0) = true
kernel_rfl DEC_clearGrow.nssT : checkSSt DT.n DEC_clearGrow.X0 = true
kernel_rfl DEC_clearGrow.nabs0a : DEC_clearGrow.X0.arrs.get 0 = none
kernel_rfl DEC_clearGrow.nabs0b : DEC_clearGrow.X0.objs.get 0 = none
kernel_rfl DEC_clearGrow.ntok1 : DEC_clearGrow.X1.tokens = []
kernel_rfl DEC_clearGrow.npend : DEC_clearGrow.X1.pending = DEC_clearGrow.X0.pending.map DEC_clearGrow.σ.pend
kernel_rfl DEC_clearGrow.nerrh : DEC_clearGrow.X1.errh = DEC_clearGrow.X0.errh.map DEC_clearGrow.σ.arg
kernel_rfl DEC_clearGrow.nfiles : DEC_clearGrow.X1.files = DEC_clearGrow.X0.files
kernel_rfl DEC_clearGrow.narch : DEC_clearGrow.X1.arch = DEC_clearGrow.X0.arch
kernel_rfl DEC_clearGrow.nsizes : DEC_clearGrow.X1.deviceSizes = DEC_clearGrow.X0.deviceSizes
kernel_rfl DEC_clearGrow.nwired : DEC_clearGrow.X1.wired = DEC_clearGrow.X0.wired
kernel_rfl DEC_clearGrow.nhost : (Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).host = (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).host

end Host.Load.Run.Tpl
