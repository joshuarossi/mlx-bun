import host.sim.compose.a4b.PLTW0Walk
import host.sim.compose.a4b.PLTEClosed
import host.sim.template.NShiftT
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PLT0.P0 : LoadP := setupP.raise 17777
noncomputable abbrev PLT0.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi)
noncomputable abbrev PLT0.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_plx0_common.s1.ffi)
noncomputable abbrev PLT0.x0 : NSt := PLT0.y0.mlx
noncomputable abbrev PLT0.x1 : NSt := PLT0.y1.mlx
noncomputable def PLT0.thetaX : List (Nat × SymE) := [(246, .lit (F64.ofNat 3)), (247, .lit (F64.ofNat 3)), (248, .lit (F64.ofNat 3)), (249, .lit (F64.ofNat 1)), (250, .lit (F64.ofNat 1)), (251, .lit (F64.ofNat 1)), (252, .lit (F64.ofNat 1)), (253, .lit (F64.ofNat 1)), (254, .lit (F64.ofNat 1)), (255, .lit (F64.ofNat 1)), (256, .lit (F64.ofNat 1536)), (257, .lit (F64.ofNat 3)), (258, .lit (F64.ofNat 1)), (259, .lit (F64.ofNat 1)), (260, .lit (F64.ofNat 2))]
noncomputable def PLT0.θ : Nat → SymE := thetaOf (PLTW0.R.theta ++ PLT0.thetaX)
noncomputable def PLT0.tabP : List SymE := PRE_plx0_common.S1.tab ++ PRE_pl_tail.S0.tab.map (·.subst PLT0.θ)
noncomputable def PLT0.numAt (i : Nat) : Bool := match nth? PRE_pl_tail.S0.tab i with
  | some e => decide ((⟨PLT0.tabP, []⟩ : SSrv).val (PLTW0.R.data.map.num i) = some (e.subst PLT0.θ))
  | none => true

kernel_rfl PLT0.nnh0 : PLTW0.R.data.nh0 = PLT0.x0.next
kernel_rfl PLT0.nnh1 : PLTW0.R.data.nh1 = PLT0.x1.next
kernel_rfl PLT0.nnn0 : PLTW0.R.data.nn0 = PLT0.x0.nnext
kernel_rfl PLT0.nnn1 : PLTW0.R.data.nn1 = PLT0.x1.nnext
kernel_rfl PLT0.nlo : (Nat.blt 0 PLT0.P0.lo && Nat.ble PLT0.P0.lo PLT0.x0.next && Nat.ble PLT0.P0.lo RData.bigHi && Nat.ble RData.bigHi PLT0.P0.E) = true
kernel_rfl PLT0.ncnt : (Nat.ble PLT0.x0.next PLT0.x1.next && Nat.ble PLT0.x0.nnext PLT0.x1.nnext) = true
kernel_rfl PLT0.nnband : (Nat.blt 0 15235 && Nat.ble 15235 PLT0.P0.NL && Nat.ble PLT0.P0.NL PLT0.P0.N0 && Nat.ble PLT0.P0.N0 PLT0.x0.nnext && Nat.beq PLT0.P0.NL PLT0.P0.N0) = true
kernel_rfl PLT0.nhbelow : PLTW0.R.data.checkHndBelow = true
kernel_rfl PLT0.nhren : checkRenG PLTW0.R.data.hnd PLTW0.R.hinv (phB PLT0.x0) = true
kernel_rfl PLT0.nband : PLTW0.R.data.checkBand PLT0.P0.lo = true
kernel_rfl PLT0.nnh1pos : Nat.blt 0 PLTW0.R.data.nh1 = true
kernel_rfl PLT0.nnren : checkRenG PLTW0.R.data.node PLTW0.R.ninv (pnB PLT0.x0) = true
kernel_rfl PLT0.nnlow : (PTrie.keysA PLTW0.R.data.node).all (fun j => Nat.ble 15235 j && Nat.blt (PLTW0.R.data.nodeF j) PLT0.x1.nnext) = true
kernel_rfl PLT0.nitems : (PTrie.keysA PLT0.x0.items).all (pnB PLT0.x0) = true
kernel_rfl PLT0.nssT : checkSSt PRE_pl_tail.n PLT0.x0 = true
kernel_rfl PLT0.nabs0a : PLT0.x0.arrs.get 0 = none
kernel_rfl PLT0.nabs0b : PLT0.x0.objs.get 0 = none
kernel_rfl PLT0.ntok1 : PLT0.x1.tokens = []
kernel_rfl PLT0.npend : PLT0.x1.pending = PLT0.x0.pending.map PLTW0.R.data.map.pend
kernel_rfl PLT0.nerrh : PLT0.x1.errh = PLT0.x0.errh.map PLTW0.R.data.map.arg
kernel_rfl PLT0.nfiles : PLT0.x1.files = PLT0.x0.files
kernel_rfl PLT0.narch : PLT0.x1.arch = PLT0.x0.arch
kernel_rfl PLT0.nsizes : PLT0.x1.deviceSizes = PLT0.x0.deviceSizes
kernel_rfl PLT0.nwired : PLT0.x1.wired = PLT0.x0.wired
kernel_rfl PLT0.nhost : PLT0.y1.host = PLT0.y0.host

end Host.Load.Run.Tpl
