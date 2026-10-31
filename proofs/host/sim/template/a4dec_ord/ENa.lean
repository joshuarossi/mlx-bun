import host.sim.template.a4dec_ord.ERestart
import host.sim.template.a4dec.Closed
import host.sim.template.NShiftOf
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The native part of chain `DEC_ord`'s end shift (`NShift DEC_ord.PE` on `toLoad`, `nshift_of`): the small checks. -/

noncomputable abbrev DEC_ord.X0 : NSt := (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx
noncomputable abbrev DEC_ord.X1 : NSt := (Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx

kernel_rfl DEC_ord.nnh0 : DEC_ord.R.data.nh0 = DEC_ord.X0.next
kernel_rfl DEC_ord.nnh1 : DEC_ord.R.data.nh1 = DEC_ord.X1.next
kernel_rfl DEC_ord.nnn0 : DEC_ord.R.data.nn0 = DEC_ord.X0.nnext
kernel_rfl DEC_ord.nnn1 : DEC_ord.R.data.nn1 = DEC_ord.X1.nnext
kernel_rfl DEC_ord.nlo : (Nat.blt 0 DEC_ord.PE.lo && Nat.ble DEC_ord.PE.lo DEC_ord.X0.next && Nat.ble DEC_ord.PE.lo RData.bigHi && Nat.ble RData.bigHi DEC_ord.PE.E) = true
kernel_rfl DEC_ord.ncnt : (Nat.ble DEC_ord.X0.next DEC_ord.X1.next && Nat.ble DEC_ord.X0.nnext DEC_ord.X1.nnext) = true
kernel_rfl DEC_ord.nnband : (Nat.blt 0 DEC_ord.PE.NL && Nat.ble DEC_ord.PE.NL DEC_ord.PE.N0 && Nat.ble DEC_ord.PE.N0 DEC_ord.X0.nnext) = true
kernel_rfl DEC_ord.nhbelow : DEC_ord.R.data.checkHndBelow = true
kernel_rfl DEC_ord.nhren : checkRenG DEC_ord.R.data.hnd DEC_ord.R.hinv (phB DEC_ord.X0) = true
kernel_rfl DEC_ord.nband : DEC_ord.R.data.checkBand DEC_ord.PE.lo = true
kernel_rfl DEC_ord.nnh1pos : Nat.blt 0 DEC_ord.R.data.nh1 = true
kernel_rfl DEC_ord.nnren : checkRenG DEC_ord.R.data.node DEC_ord.R.ninv (pnB DEC_ord.X0) = true
kernel_rfl DEC_ord.nnlow : (PTrie.keysA DEC_ord.R.data.node).all (fun j => Nat.ble DEC_ord.PE.NL j && Nat.blt (DEC_ord.R.data.nodeF j) DEC_ord.X1.nnext) = true
kernel_rfl DEC_ord.nnord : (fullAbove DEC_ord.PE DEC_ord.X0).all (fun i => Nat.ble i (DEC_ord.R.data.nodeF i) &&
  (PTrie.keysA DEC_ord.R.data.node).all fun j => !Nat.blt j i || Nat.blt (DEC_ord.R.data.nodeF j) (DEC_ord.R.data.nodeF i)) = true
kernel_rfl DEC_ord.nitems : (PTrie.keysA DEC_ord.X0.items).all (pnB DEC_ord.X0) = true
kernel_rfl DEC_ord.nssT : checkSSt DT.n DEC_ord.X0 = true
kernel_rfl DEC_ord.nabs0a : DEC_ord.X0.arrs.get 0 = none
kernel_rfl DEC_ord.nabs0b : DEC_ord.X0.objs.get 0 = none
kernel_rfl DEC_ord.ntok1 : DEC_ord.X1.tokens = []
kernel_rfl DEC_ord.npend : DEC_ord.X1.pending = DEC_ord.X0.pending.map DEC_ord.σ.pend
kernel_rfl DEC_ord.nerrh : DEC_ord.X1.errh = DEC_ord.X0.errh.map DEC_ord.σ.arg
kernel_rfl DEC_ord.nfiles : DEC_ord.X1.files = DEC_ord.X0.files
kernel_rfl DEC_ord.narch : DEC_ord.X1.arch = DEC_ord.X0.arch
kernel_rfl DEC_ord.nsizes : DEC_ord.X1.deviceSizes = DEC_ord.X0.deviceSizes
kernel_rfl DEC_ord.nwired : DEC_ord.X1.wired = DEC_ord.X0.wired
kernel_rfl DEC_ord.nhost : (Host.Load.Layers.toLoad DEC_ord.s11.ffi).host = (Host.Load.Layers.toLoad DEC_ord.s0.ffi).host

end Host.Load.Run.Tpl
