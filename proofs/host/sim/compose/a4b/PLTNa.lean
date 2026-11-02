import host.sim.compose.a4b.PLTPWalk
import host.sim.compose.a4b.PLTEClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PLT.P0 : LoadP := setupP.raise 17777
noncomputable abbrev PLT.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi)
noncomputable abbrev PLT.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pl_common.s1.ffi)
noncomputable abbrev PLT.x0 : NSt := PLT.y0.mlx
noncomputable abbrev PLT.x1 : NSt := PLT.y1.mlx
noncomputable def PLT.thetaX : List (Nat × SymE) := []
noncomputable def PLT.θ : Nat → SymE := thetaOf (PLTP.R.theta ++ PLT.thetaX)
noncomputable def PLT.tabP : List SymE := PRE_pl_common.S1.tab ++ PRE_pl_tail.S0.tab.map (·.subst PLT.θ)
noncomputable def PLT.numAt (i : Nat) : Bool := match nth? PRE_pl_tail.S0.tab i with
  | some e => decide ((⟨PLT.tabP, []⟩ : SSrv).val (PLTP.R.data.map.num i) = some (e.subst PLT.θ))
  | none => true

kernel_rfl PLT.nnh0 : PLTP.R.data.nh0 = PLT.x0.next
kernel_rfl PLT.nnh1 : PLTP.R.data.nh1 = PLT.x1.next
kernel_rfl PLT.nnn0 : PLTP.R.data.nn0 = PLT.x0.nnext
kernel_rfl PLT.nnn1 : PLTP.R.data.nn1 = PLT.x1.nnext
kernel_rfl PLT.nlo : (Nat.blt 0 PLT.P0.lo && Nat.ble PLT.P0.lo PLT.x0.next && Nat.ble PLT.P0.lo RData.bigHi && Nat.ble RData.bigHi PLT.P0.E) = true
kernel_rfl PLT.ncnt : (Nat.ble PLT.x0.next PLT.x1.next && Nat.ble PLT.x0.nnext PLT.x1.nnext) = true
kernel_rfl PLT.nnband : (Nat.blt 0 PLT.P0.NL && Nat.ble PLT.P0.NL PLT.P0.N0 && Nat.ble PLT.P0.N0 PLT.x0.nnext) = true
kernel_rfl PLT.nhbelow : PLTP.R.data.checkHndBelow = true
kernel_rfl PLT.nhren : checkRenG PLTP.R.data.hnd PLTP.R.hinv (phB PLT.x0) = true
kernel_rfl PLT.nband : PLTP.R.data.checkBand PLT.P0.lo = true
kernel_rfl PLT.nnh1pos : Nat.blt 0 PLTP.R.data.nh1 = true
kernel_rfl PLT.nnren : checkRenG PLTP.R.data.node PLTP.R.ninv (pnB PLT.x0) = true
kernel_rfl PLT.nnlow : (PTrie.keysA PLTP.R.data.node).all (fun j => Nat.ble PLT.P0.NL j && Nat.blt (PLTP.R.data.nodeF j) PLT.x1.nnext) = true
kernel_rfl PLT.nnord : (fullAbove PLT.P0 PLT.x0).all (fun i => Nat.ble i (PLTP.R.data.nodeF i) &&
  (PTrie.keysA PLTP.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PLTP.R.data.nodeF j) (PLTP.R.data.nodeF i)) = true
kernel_rfl PLT.nitems : (PTrie.keysA PLT.x0.items).all (pnB PLT.x0) = true
kernel_rfl PLT.nssT : checkSSt PRE_pl_tail.n PLT.x0 = true
kernel_rfl PLT.nabs0a : PLT.x0.arrs.get 0 = none
kernel_rfl PLT.nabs0b : PLT.x0.objs.get 0 = none
kernel_rfl PLT.ntok1 : PLT.x1.tokens = []
kernel_rfl PLT.npend : PLT.x1.pending = PLT.x0.pending.map PLTP.R.data.map.pend
kernel_rfl PLT.nerrh : PLT.x1.errh = PLT.x0.errh.map PLTP.R.data.map.arg
kernel_rfl PLT.nfiles : PLT.x1.files = PLT.x0.files
kernel_rfl PLT.narch : PLT.x1.arch = PLT.x0.arch
kernel_rfl PLT.nsizes : PLT.x1.deviceSizes = PLT.x0.deviceSizes
kernel_rfl PLT.nwired : PLT.x1.wired = PLT.x0.wired
kernel_rfl PLT.nhost : PLT.y1.host = PLT.y0.host

end Host.Load.Run.Tpl
