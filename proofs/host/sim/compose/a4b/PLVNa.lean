import host.sim.compose.a4b.PLVWalk
import host.sim.compose.a4b.PLVEClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PLV.P0 : LoadP := setupP.raise 21446
noncomputable abbrev PLV.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_plvw_entry.s0.ffi)
noncomputable abbrev PLV.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_fd_vw_r0_body.s900.ffi)
noncomputable abbrev PLV.x0 : NSt := PLV.y0.mlx
noncomputable abbrev PLV.x1 : NSt := PLV.y1.mlx
noncomputable def PLV.thetaX : List (Nat × SymE) := []
noncomputable def PLV.θ : Nat → SymE := thetaOf (PLVW.R.theta ++ PLV.thetaX)
noncomputable def PLV.tabP : List SymE := PRE_fd_vw_r0_body.S900.tab ++ PRE_plvw_entry.S0.tab.map (·.subst PLV.θ)
noncomputable def PLV.numAt (i : Nat) : Bool := match nth? PRE_plvw_entry.S0.tab i with
  | some e => decide ((⟨PLV.tabP, []⟩ : SSrv).val (PLVW.R.data.map.num i) = some (e.subst PLV.θ))
  | none => true

kernel_rfl PLV.nnh0 : PLVW.R.data.nh0 = PLV.x0.next
kernel_rfl PLV.nnh1 : PLVW.R.data.nh1 = PLV.x1.next
kernel_rfl PLV.nnn0 : PLVW.R.data.nn0 = PLV.x0.nnext
kernel_rfl PLV.nnn1 : PLVW.R.data.nn1 = PLV.x1.nnext
kernel_rfl PLV.nlo : (Nat.blt 0 PLV.P0.lo && Nat.ble PLV.P0.lo PLV.x0.next && Nat.ble PLV.P0.lo RData.bigHi && Nat.ble RData.bigHi PLV.P0.E) = true
kernel_rfl PLV.ncnt : (Nat.ble PLV.x0.next PLV.x1.next && Nat.ble PLV.x0.nnext PLV.x1.nnext) = true
kernel_rfl PLV.nnband : (Nat.blt 0 PLV.P0.NL && Nat.ble PLV.P0.NL PLV.P0.N0 && Nat.ble PLV.P0.N0 PLV.x0.nnext) = true
kernel_rfl PLV.nhbelow : PLVW.R.data.checkHndBelow = true
kernel_rfl PLV.nhren : checkRenG PLVW.R.data.hnd PLVW.R.hinv (phB PLV.x0) = true
kernel_rfl PLV.nband : PLVW.R.data.checkBand PLV.P0.lo = true
kernel_rfl PLV.nnh1pos : Nat.blt 0 PLVW.R.data.nh1 = true
kernel_rfl PLV.nnren : checkRenG PLVW.R.data.node PLVW.R.ninv (pnB PLV.x0) = true
kernel_rfl PLV.nnlow : (PTrie.keysA PLVW.R.data.node).all (fun j => Nat.ble PLV.P0.NL j && Nat.blt (PLVW.R.data.nodeF j) PLV.x1.nnext) = true
kernel_rfl PLV.nnord : (fullAbove PLV.P0 PLV.x0).all (fun i => Nat.ble i (PLVW.R.data.nodeF i) &&
  (PTrie.keysA PLVW.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PLVW.R.data.nodeF j) (PLVW.R.data.nodeF i)) = true
kernel_rfl PLV.nitems : (PTrie.keysA PLV.x0.items).all (pnB PLV.x0) = true
kernel_rfl PLV.nssT : checkSSt PRE_plvw_entry.n PLV.x0 = true
kernel_rfl PLV.nabs0a : PLV.x0.arrs.get 0 = none
kernel_rfl PLV.nabs0b : PLV.x0.objs.get 0 = none
kernel_rfl PLV.ntok1 : PLV.x1.tokens = []
kernel_rfl PLV.npend : PLV.x1.pending = PLV.x0.pending.map PLVW.R.data.map.pend
kernel_rfl PLV.nerrh : PLV.x1.errh = PLV.x0.errh.map PLVW.R.data.map.arg
kernel_rfl PLV.nfiles : PLV.x1.files = PLV.x0.files
kernel_rfl PLV.narch : PLV.x1.arch = PLV.x0.arch
kernel_rfl PLV.nsizes : PLV.x1.deviceSizes = PLV.x0.deviceSizes
kernel_rfl PLV.nwired : PLV.x1.wired = PLV.x0.wired
kernel_rfl PLV.nhost : PLV.y1.host = PLV.y0.host

end Host.Load.Run.Tpl
