import host.route.PostTailVW
import host.sim.compose.a4b.PLTEClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PLTV.P0 : LoadP := setupP.raise 17777
noncomputable abbrev PLTV.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi)
noncomputable abbrev PLTV.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_plvw_common.s4.ffi)
noncomputable abbrev PLTV.x0 : NSt := PLTV.y0.mlx
noncomputable abbrev PLTV.x1 : NSt := PLTV.y1.mlx
noncomputable def PLTV.thetaX : List (Nat × SymE) := []
noncomputable def PLTV.θ : Nat → SymE := thetaOf (PLTailVW.R.theta ++ PLTV.thetaX)
noncomputable def PLTV.numAt (i : Nat) : Bool := match nth? PRE_pl_tail.S0.tab i with
  | some e => decide ((⟨PRE_plvw_common.S4.tab, []⟩ : SSrv).val (PLTailVW.R.data.map.num i) = some (e.subst PLTV.θ))
  | none => true

kernel_rfl PLTV.nnh0 : PLTailVW.R.data.nh0 = PLTV.x0.next
kernel_rfl PLTV.nnh1 : PLTailVW.R.data.nh1 = PLTV.x1.next
kernel_rfl PLTV.nnn0 : PLTailVW.R.data.nn0 = PLTV.x0.nnext
kernel_rfl PLTV.nnn1 : PLTailVW.R.data.nn1 = PLTV.x1.nnext
kernel_rfl PLTV.nlo : (Nat.blt 0 PLTV.P0.lo && Nat.ble PLTV.P0.lo PLTV.x0.next && Nat.ble PLTV.P0.lo RData.bigHi && Nat.ble RData.bigHi PLTV.P0.E) = true
kernel_rfl PLTV.ncnt : (Nat.ble PLTV.x0.next PLTV.x1.next && Nat.ble PLTV.x0.nnext PLTV.x1.nnext) = true
kernel_rfl PLTV.nnband : (Nat.blt 0 PLTV.P0.NL && Nat.ble PLTV.P0.NL PLTV.P0.N0 && Nat.ble PLTV.P0.N0 PLTV.x0.nnext) = true
kernel_rfl PLTV.nhbelow : PLTailVW.R.data.checkHndBelow = true
kernel_rfl PLTV.nhren : checkRenG PLTailVW.R.data.hnd PLTailVW.R.hinv (phB PLTV.x0) = true
kernel_rfl PLTV.nband : PLTailVW.R.data.checkBand PLTV.P0.lo = true
kernel_rfl PLTV.nnh1pos : Nat.blt 0 PLTailVW.R.data.nh1 = true
kernel_rfl PLTV.nnren : checkRenG PLTailVW.R.data.node PLTailVW.R.ninv (pnB PLTV.x0) = true
kernel_rfl PLTV.nnlow : (PTrie.keysA PLTailVW.R.data.node).all (fun j => Nat.ble PLTV.P0.NL j && Nat.blt (PLTailVW.R.data.nodeF j) PLTV.x1.nnext) = true
kernel_rfl PLTV.nnord : (fullAbove PLTV.P0 PLTV.x0).all (fun i => Nat.ble i (PLTailVW.R.data.nodeF i) &&
  (PTrie.keysA PLTailVW.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PLTailVW.R.data.nodeF j) (PLTailVW.R.data.nodeF i)) = true
kernel_rfl PLTV.nitems : (PTrie.keysA PLTV.x0.items).all (pnB PLTV.x0) = true
kernel_rfl PLTV.nssT : checkSSt PRE_pl_tail.n PLTV.x0 = true
kernel_rfl PLTV.nabs0a : PLTV.x0.arrs.get 0 = none
kernel_rfl PLTV.nabs0b : PLTV.x0.objs.get 0 = none
kernel_rfl PLTV.ntok1 : PLTV.x1.tokens = []
kernel_rfl PLTV.npend : PLTV.x1.pending = PLTV.x0.pending.map PLTailVW.R.data.map.pend
kernel_rfl PLTV.nerrh : PLTV.x1.errh = PLTV.x0.errh.map PLTailVW.R.data.map.arg
kernel_rfl PLTV.nfiles : PLTV.x1.files = PLTV.x0.files
kernel_rfl PLTV.narch : PLTV.x1.arch = PLTV.x0.arch
kernel_rfl PLTV.nsizes : PLTV.x1.deviceSizes = PLTV.x0.deviceSizes
kernel_rfl PLTV.nwired : PLTV.x1.wired = PLTV.x0.wired
kernel_rfl PLTV.nhost : PLTV.y1.host = PLTV.y0.host

end Host.Load.Run.Tpl
