import host.sim.template.a4dec_clear.ERestart
import host.sim.template.a4dec.Closed
import host.sim.template.NShiftOf
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The native part of chain `DEC_clear`'s end shift (`NShift DEC_clear.PE` on `toLoad`, `nshift_of`): the small checks. -/

noncomputable abbrev DEC_clear.X0 : NSt := (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx
noncomputable abbrev DEC_clear.X1 : NSt := (Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx

kernel_rfl DEC_clear.nnh0 : DEC_clear.R.data.nh0 = DEC_clear.X0.next
kernel_rfl DEC_clear.nnh1 : DEC_clear.R.data.nh1 = DEC_clear.X1.next
kernel_rfl DEC_clear.nnn0 : DEC_clear.R.data.nn0 = DEC_clear.X0.nnext
kernel_rfl DEC_clear.nnn1 : DEC_clear.R.data.nn1 = DEC_clear.X1.nnext
kernel_rfl DEC_clear.nlo : (Nat.blt 0 DEC_clear.PE.lo && Nat.ble DEC_clear.PE.lo DEC_clear.X0.next && Nat.ble DEC_clear.PE.lo RData.bigHi && Nat.ble RData.bigHi DEC_clear.PE.E) = true
kernel_rfl DEC_clear.ncnt : (Nat.ble DEC_clear.X0.next DEC_clear.X1.next && Nat.ble DEC_clear.X0.nnext DEC_clear.X1.nnext) = true
kernel_rfl DEC_clear.nnband : (Nat.blt 0 DEC_clear.PE.NL && Nat.ble DEC_clear.PE.NL DEC_clear.PE.N0 && Nat.ble DEC_clear.PE.N0 DEC_clear.X0.nnext) = true
kernel_rfl DEC_clear.nhbelow : DEC_clear.R.data.checkHndBelow = true
kernel_rfl DEC_clear.nhren : checkRenG DEC_clear.R.data.hnd DEC_clear.R.hinv (phB DEC_clear.X0) = true
kernel_rfl DEC_clear.nband : DEC_clear.R.data.checkBand DEC_clear.PE.lo = true
kernel_rfl DEC_clear.nnh1pos : Nat.blt 0 DEC_clear.R.data.nh1 = true
kernel_rfl DEC_clear.nnren : checkRenG DEC_clear.R.data.node DEC_clear.R.ninv (pnB DEC_clear.X0) = true
kernel_rfl DEC_clear.nnlow : (PTrie.keysA DEC_clear.R.data.node).all (fun j => Nat.ble DEC_clear.PE.NL j && Nat.blt (DEC_clear.R.data.nodeF j) DEC_clear.X1.nnext) = true
kernel_rfl DEC_clear.nnord : (fullAbove DEC_clear.PE DEC_clear.X0).all (fun i => Nat.ble i (DEC_clear.R.data.nodeF i) &&
  (PTrie.keysA DEC_clear.R.data.node).all fun j => !Nat.blt j i || Nat.blt (DEC_clear.R.data.nodeF j) (DEC_clear.R.data.nodeF i)) = true
kernel_rfl DEC_clear.nitems : (PTrie.keysA DEC_clear.X0.items).all (pnB DEC_clear.X0) = true
kernel_rfl DEC_clear.nssT : checkSSt DT.n DEC_clear.X0 = true
kernel_rfl DEC_clear.nabs0a : DEC_clear.X0.arrs.get 0 = none
kernel_rfl DEC_clear.nabs0b : DEC_clear.X0.objs.get 0 = none
kernel_rfl DEC_clear.ntok1 : DEC_clear.X1.tokens = []
kernel_rfl DEC_clear.npend : DEC_clear.X1.pending = DEC_clear.X0.pending.map DEC_clear.σ.pend
kernel_rfl DEC_clear.nerrh : DEC_clear.X1.errh = DEC_clear.X0.errh.map DEC_clear.σ.arg
kernel_rfl DEC_clear.nfiles : DEC_clear.X1.files = DEC_clear.X0.files
kernel_rfl DEC_clear.narch : DEC_clear.X1.arch = DEC_clear.X0.arch
kernel_rfl DEC_clear.nsizes : DEC_clear.X1.deviceSizes = DEC_clear.X0.deviceSizes
kernel_rfl DEC_clear.nwired : DEC_clear.X1.wired = DEC_clear.X0.wired
kernel_rfl DEC_clear.nhost : (Host.Load.Layers.toLoad DEC_clear.s11.ffi).host = (Host.Load.Layers.toLoad DEC_clear.s0.ffi).host

end Host.Load.Run.Tpl
