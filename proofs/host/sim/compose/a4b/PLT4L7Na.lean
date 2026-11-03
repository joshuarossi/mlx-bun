import host.sim.compose.a4b.PLTW4L7Walk
import host.sim.compose.a4b.PLTEClosed
import host.sim.template.NShiftT
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PLT4L7.P0 : LoadP := setupP.raise 17777
noncomputable abbrev PLT4L7.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi)
noncomputable abbrev PLT4L7.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_plx4_L7_common.s1.ffi)
noncomputable abbrev PLT4L7.x0 : NSt := PLT4L7.y0.mlx
noncomputable abbrev PLT4L7.x1 : NSt := PLT4L7.y1.mlx
noncomputable def PLT4L7.thetaX : List (Nat × SymE) := []
noncomputable def PLT4L7.θ : Nat → SymE := thetaOf (PLTW4L7.R.theta ++ PLT4L7.thetaX)
noncomputable def PLT4L7.tabP : List SymE := PRE_plx4_L7_common.S1.tab ++ PRE_pl_tail.S0.tab.map (·.subst PLT4L7.θ)
noncomputable def PLT4L7.numAt (i : Nat) : Bool := match nth? PRE_pl_tail.S0.tab i with
  | some e => decide ((⟨PLT4L7.tabP, []⟩ : SSrv).val (PLTW4L7.R.data.map.num i) = some (e.subst PLT4L7.θ))
  | none => true

kernel_rfl PLT4L7.nnh0 : PLTW4L7.R.data.nh0 = PLT4L7.x0.next
kernel_rfl PLT4L7.nnh1 : PLTW4L7.R.data.nh1 = PLT4L7.x1.next
kernel_rfl PLT4L7.nnn0 : PLTW4L7.R.data.nn0 = PLT4L7.x0.nnext
kernel_rfl PLT4L7.nnn1 : PLTW4L7.R.data.nn1 = PLT4L7.x1.nnext
kernel_rfl PLT4L7.nlo : (Nat.blt 0 PLT4L7.P0.lo && Nat.ble PLT4L7.P0.lo PLT4L7.x0.next && Nat.ble PLT4L7.P0.lo RData.bigHi && Nat.ble RData.bigHi PLT4L7.P0.E) = true
kernel_rfl PLT4L7.ncnt : (Nat.ble PLT4L7.x0.next PLT4L7.x1.next && Nat.ble PLT4L7.x0.nnext PLT4L7.x1.nnext) = true
kernel_rfl PLT4L7.nnband : (Nat.blt 0 15235 && Nat.ble 15235 PLT4L7.P0.NL && Nat.ble PLT4L7.P0.NL PLT4L7.P0.N0 && Nat.ble PLT4L7.P0.N0 PLT4L7.x0.nnext && Nat.beq PLT4L7.P0.NL PLT4L7.P0.N0) = true
kernel_rfl PLT4L7.nhbelow : PLTW4L7.R.data.checkHndBelow = true
kernel_rfl PLT4L7.nhren : checkRenG PLTW4L7.R.data.hnd PLTW4L7.R.hinv (phB PLT4L7.x0) = true
kernel_rfl PLT4L7.nband : PLTW4L7.R.data.checkBand PLT4L7.P0.lo = true
kernel_rfl PLT4L7.nnh1pos : Nat.blt 0 PLTW4L7.R.data.nh1 = true
kernel_rfl PLT4L7.nnren : checkRenG PLTW4L7.R.data.node PLTW4L7.R.ninv (pnB PLT4L7.x0) = true
kernel_rfl PLT4L7.nnlow : (PTrie.keysA PLTW4L7.R.data.node).all (fun j => Nat.ble 15235 j && Nat.blt (PLTW4L7.R.data.nodeF j) PLT4L7.x1.nnext) = true
kernel_rfl PLT4L7.nitems : (PTrie.keysA PLT4L7.x0.items).all (pnB PLT4L7.x0) = true
kernel_rfl PLT4L7.nssT : checkSSt PRE_pl_tail.n PLT4L7.x0 = true
kernel_rfl PLT4L7.nabs0a : PLT4L7.x0.arrs.get 0 = none
kernel_rfl PLT4L7.nabs0b : PLT4L7.x0.objs.get 0 = none
kernel_rfl PLT4L7.ntok1 : PLT4L7.x1.tokens = []
kernel_rfl PLT4L7.npend : PLT4L7.x1.pending = PLT4L7.x0.pending.map PLTW4L7.R.data.map.pend
kernel_rfl PLT4L7.nerrh : PLT4L7.x1.errh = PLT4L7.x0.errh.map PLTW4L7.R.data.map.arg
kernel_rfl PLT4L7.nfiles : PLT4L7.x1.files = PLT4L7.x0.files
kernel_rfl PLT4L7.narch : PLT4L7.x1.arch = PLT4L7.x0.arch
kernel_rfl PLT4L7.nsizes : PLT4L7.x1.deviceSizes = PLT4L7.x0.deviceSizes
kernel_rfl PLT4L7.nwired : PLT4L7.x1.wired = PLT4L7.x0.wired
kernel_rfl PLT4L7.nhost : PLT4L7.y1.host = PLT4L7.y0.host

end Host.Load.Run.Tpl
