import host.sim.template.a4dec_fill.ERestart
import host.sim.template.a4dec.Closed
import host.sim.template.NShiftOf
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The native part of chain `DEC_fill`'s end shift (`NShift DEC_fill.PE` on `toLoad`, `nshift_of`): the small checks. -/

noncomputable abbrev DEC_fill.X0 : NSt := (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx
noncomputable abbrev DEC_fill.X1 : NSt := (Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx

kernel_rfl DEC_fill.nnh0 : DEC_fill.R.data.nh0 = DEC_fill.X0.next
kernel_rfl DEC_fill.nnh1 : DEC_fill.R.data.nh1 = DEC_fill.X1.next
kernel_rfl DEC_fill.nnn0 : DEC_fill.R.data.nn0 = DEC_fill.X0.nnext
kernel_rfl DEC_fill.nnn1 : DEC_fill.R.data.nn1 = DEC_fill.X1.nnext
kernel_rfl DEC_fill.nlo : (Nat.blt 0 DEC_fill.PE.lo && Nat.ble DEC_fill.PE.lo DEC_fill.X0.next && Nat.ble DEC_fill.PE.lo RData.bigHi && Nat.ble RData.bigHi DEC_fill.PE.E) = true
kernel_rfl DEC_fill.ncnt : (Nat.ble DEC_fill.X0.next DEC_fill.X1.next && Nat.ble DEC_fill.X0.nnext DEC_fill.X1.nnext) = true
kernel_rfl DEC_fill.nnband : (Nat.blt 0 DEC_fill.PE.NL && Nat.ble DEC_fill.PE.NL DEC_fill.PE.N0 && Nat.ble DEC_fill.PE.N0 DEC_fill.X0.nnext) = true
kernel_rfl DEC_fill.nhbelow : DEC_fill.R.data.checkHndBelow = true
kernel_rfl DEC_fill.nhren : checkRenG DEC_fill.R.data.hnd DEC_fill.R.hinv (phB DEC_fill.X0) = true
kernel_rfl DEC_fill.nband : DEC_fill.R.data.checkBand DEC_fill.PE.lo = true
kernel_rfl DEC_fill.nnh1pos : Nat.blt 0 DEC_fill.R.data.nh1 = true
kernel_rfl DEC_fill.nnren : checkRenG DEC_fill.R.data.node DEC_fill.R.ninv (pnB DEC_fill.X0) = true
kernel_rfl DEC_fill.nnlow : (PTrie.keysA DEC_fill.R.data.node).all (fun j => Nat.ble DEC_fill.PE.NL j && Nat.blt (DEC_fill.R.data.nodeF j) DEC_fill.X1.nnext) = true
kernel_rfl DEC_fill.nnord : (fullAbove DEC_fill.PE DEC_fill.X0).all (fun i => Nat.ble i (DEC_fill.R.data.nodeF i) &&
  (PTrie.keysA DEC_fill.R.data.node).all fun j => !Nat.blt j i || Nat.blt (DEC_fill.R.data.nodeF j) (DEC_fill.R.data.nodeF i)) = true
kernel_rfl DEC_fill.nitems : (PTrie.keysA DEC_fill.X0.items).all (pnB DEC_fill.X0) = true
kernel_rfl DEC_fill.nssT : checkSSt DT.n DEC_fill.X0 = true
kernel_rfl DEC_fill.nabs0a : DEC_fill.X0.arrs.get 0 = none
kernel_rfl DEC_fill.nabs0b : DEC_fill.X0.objs.get 0 = none
kernel_rfl DEC_fill.ntok1 : DEC_fill.X1.tokens = []
kernel_rfl DEC_fill.npend : DEC_fill.X1.pending = DEC_fill.X0.pending.map DEC_fill.σ.pend
kernel_rfl DEC_fill.nerrh : DEC_fill.X1.errh = DEC_fill.X0.errh.map DEC_fill.σ.arg
kernel_rfl DEC_fill.nfiles : DEC_fill.X1.files = DEC_fill.X0.files
kernel_rfl DEC_fill.narch : DEC_fill.X1.arch = DEC_fill.X0.arch
kernel_rfl DEC_fill.nsizes : DEC_fill.X1.deviceSizes = DEC_fill.X0.deviceSizes
kernel_rfl DEC_fill.nwired : DEC_fill.X1.wired = DEC_fill.X0.wired
kernel_rfl DEC_fill.nhost : (Host.Load.Layers.toLoad DEC_fill.s11.ffi).host = (Host.Load.Layers.toLoad DEC_fill.s0.ffi).host

end Host.Load.Run.Tpl
