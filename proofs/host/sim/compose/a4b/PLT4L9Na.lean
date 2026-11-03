import host.sim.compose.a4b.PLTW4L9Walk
import host.sim.compose.a4b.PLTEClosed
import host.sim.template.NShiftT
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PLT4L9.P0 : LoadP := setupP.raise 17777
noncomputable abbrev PLT4L9.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi)
noncomputable abbrev PLT4L9.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_plx4_L9_common.s1.ffi)
noncomputable abbrev PLT4L9.x0 : NSt := PLT4L9.y0.mlx
noncomputable abbrev PLT4L9.x1 : NSt := PLT4L9.y1.mlx
noncomputable def PLT4L9.thetaX : List (Nat × SymE) := []
noncomputable def PLT4L9.θ : Nat → SymE := thetaOf (PLTW4L9.R.theta ++ PLT4L9.thetaX)
noncomputable def PLT4L9.tabP : List SymE := PRE_plx4_L9_common.S1.tab ++ PRE_pl_tail.S0.tab.map (·.subst PLT4L9.θ)
noncomputable def PLT4L9.numAt (i : Nat) : Bool := match nth? PRE_pl_tail.S0.tab i with
  | some e => decide ((⟨PLT4L9.tabP, []⟩ : SSrv).val (PLTW4L9.R.data.map.num i) = some (e.subst PLT4L9.θ))
  | none => true

kernel_rfl PLT4L9.nnh0 : PLTW4L9.R.data.nh0 = PLT4L9.x0.next
kernel_rfl PLT4L9.nnh1 : PLTW4L9.R.data.nh1 = PLT4L9.x1.next
kernel_rfl PLT4L9.nnn0 : PLTW4L9.R.data.nn0 = PLT4L9.x0.nnext
kernel_rfl PLT4L9.nnn1 : PLTW4L9.R.data.nn1 = PLT4L9.x1.nnext
kernel_rfl PLT4L9.nlo : (Nat.blt 0 PLT4L9.P0.lo && Nat.ble PLT4L9.P0.lo PLT4L9.x0.next && Nat.ble PLT4L9.P0.lo RData.bigHi && Nat.ble RData.bigHi PLT4L9.P0.E) = true
kernel_rfl PLT4L9.ncnt : (Nat.ble PLT4L9.x0.next PLT4L9.x1.next && Nat.ble PLT4L9.x0.nnext PLT4L9.x1.nnext) = true
kernel_rfl PLT4L9.nnband : (Nat.blt 0 15235 && Nat.ble 15235 PLT4L9.P0.NL && Nat.ble PLT4L9.P0.NL PLT4L9.P0.N0 && Nat.ble PLT4L9.P0.N0 PLT4L9.x0.nnext && Nat.beq PLT4L9.P0.NL PLT4L9.P0.N0) = true
kernel_rfl PLT4L9.nhbelow : PLTW4L9.R.data.checkHndBelow = true
kernel_rfl PLT4L9.nhren : checkRenG PLTW4L9.R.data.hnd PLTW4L9.R.hinv (phB PLT4L9.x0) = true
kernel_rfl PLT4L9.nband : PLTW4L9.R.data.checkBand PLT4L9.P0.lo = true
kernel_rfl PLT4L9.nnh1pos : Nat.blt 0 PLTW4L9.R.data.nh1 = true
kernel_rfl PLT4L9.nnren : checkRenG PLTW4L9.R.data.node PLTW4L9.R.ninv (pnB PLT4L9.x0) = true
kernel_rfl PLT4L9.nnlow : (PTrie.keysA PLTW4L9.R.data.node).all (fun j => Nat.ble 15235 j && Nat.blt (PLTW4L9.R.data.nodeF j) PLT4L9.x1.nnext) = true
kernel_rfl PLT4L9.nitems : (PTrie.keysA PLT4L9.x0.items).all (pnB PLT4L9.x0) = true
kernel_rfl PLT4L9.nssT : checkSSt PRE_pl_tail.n PLT4L9.x0 = true
kernel_rfl PLT4L9.nabs0a : PLT4L9.x0.arrs.get 0 = none
kernel_rfl PLT4L9.nabs0b : PLT4L9.x0.objs.get 0 = none
kernel_rfl PLT4L9.ntok1 : PLT4L9.x1.tokens = []
kernel_rfl PLT4L9.npend : PLT4L9.x1.pending = PLT4L9.x0.pending.map PLTW4L9.R.data.map.pend
kernel_rfl PLT4L9.nerrh : PLT4L9.x1.errh = PLT4L9.x0.errh.map PLTW4L9.R.data.map.arg
kernel_rfl PLT4L9.nfiles : PLT4L9.x1.files = PLT4L9.x0.files
kernel_rfl PLT4L9.narch : PLT4L9.x1.arch = PLT4L9.x0.arch
kernel_rfl PLT4L9.nsizes : PLT4L9.x1.deviceSizes = PLT4L9.x0.deviceSizes
kernel_rfl PLT4L9.nwired : PLT4L9.x1.wired = PLT4L9.x0.wired
kernel_rfl PLT4L9.nhost : PLT4L9.y1.host = PLT4L9.y0.host

end Host.Load.Run.Tpl
