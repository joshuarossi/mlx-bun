import host.sim.compose.a4b.PostWalkD1
import host.sim.compose.a4b.PLEntryClosed
import host.sim.template.NShiftOf
import host.sim.compose.PostLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PLD1.P0 : LoadP := setupP.raise 17764
noncomputable abbrev PLD1.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pl_entry.s0.ffi)
noncomputable abbrev PLD1.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad D1Body.s155.ffi)
noncomputable abbrev PLD1.x0 : NSt := PLD1.y0.mlx
noncomputable abbrev PLD1.x1 : NSt := PLD1.y1.mlx
noncomputable def PLD1.θ : Nat → SymE := thetaOf PLWalkD1.R.theta
noncomputable def PLD1.numAt (i : Nat) : Bool := match nth? PRE_pl_entry.S0.tab i with
  | some e => decide ((⟨D1Body.S155.tab, []⟩ : SSrv).val (PLWalkD1.R.data.map.num i) = some (e.subst PLD1.θ))
  | none => true

kernel_rfl PLD1.nnh0 : PLWalkD1.R.data.nh0 = PLD1.x0.next
kernel_rfl PLD1.nnh1 : PLWalkD1.R.data.nh1 = PLD1.x1.next
kernel_rfl PLD1.nnn0 : PLWalkD1.R.data.nn0 = PLD1.x0.nnext
kernel_rfl PLD1.nnn1 : PLWalkD1.R.data.nn1 = PLD1.x1.nnext
kernel_rfl PLD1.nlo : (Nat.blt 0 PLD1.P0.lo && Nat.ble PLD1.P0.lo PLD1.x0.next && Nat.ble PLD1.P0.lo RData.bigHi && Nat.ble RData.bigHi PLD1.P0.E) = true
kernel_rfl PLD1.ncnt : (Nat.ble PLD1.x0.next PLD1.x1.next && Nat.ble PLD1.x0.nnext PLD1.x1.nnext) = true
kernel_rfl PLD1.nnband : (Nat.blt 0 PLD1.P0.NL && Nat.ble PLD1.P0.NL PLD1.P0.N0 && Nat.ble PLD1.P0.N0 PLD1.x0.nnext) = true
kernel_rfl PLD1.nhbelow : PLWalkD1.R.data.checkHndBelow = true
kernel_rfl PLD1.nhren : checkRenG PLWalkD1.R.data.hnd PLWalkD1.R.hinv (phB PLD1.x0) = true
kernel_rfl PLD1.nband : PLWalkD1.R.data.checkBand PLD1.P0.lo = true
kernel_rfl PLD1.nnh1pos : Nat.blt 0 PLWalkD1.R.data.nh1 = true
kernel_rfl PLD1.nnren : checkRenG PLWalkD1.R.data.node PLWalkD1.R.ninv (pnB PLD1.x0) = true
kernel_rfl PLD1.nnlow : (PTrie.keysA PLWalkD1.R.data.node).all (fun j => Nat.ble PLD1.P0.NL j && Nat.blt (PLWalkD1.R.data.nodeF j) PLD1.x1.nnext) = true
kernel_rfl PLD1.nnord : (fullAbove PLD1.P0 PLD1.x0).all (fun i => Nat.ble i (PLWalkD1.R.data.nodeF i) &&
  (PTrie.keysA PLWalkD1.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PLWalkD1.R.data.nodeF j) (PLWalkD1.R.data.nodeF i)) = true
kernel_rfl PLD1.nitems : (PTrie.keysA PLD1.x0.items).all (pnB PLD1.x0) = true
kernel_rfl PLD1.nssT : checkSSt PRE_pl_entry.n PLD1.x0 = true
kernel_rfl PLD1.nabs0a : PLD1.x0.arrs.get 0 = none
kernel_rfl PLD1.nabs0b : PLD1.x0.objs.get 0 = none
kernel_rfl PLD1.ntok1 : PLD1.x1.tokens = []
kernel_rfl PLD1.npend : PLD1.x1.pending = PLD1.x0.pending.map PLWalkD1.R.data.map.pend
kernel_rfl PLD1.nerrh : PLD1.x1.errh = PLD1.x0.errh.map PLWalkD1.R.data.map.arg
kernel_rfl PLD1.nfiles : PLD1.x1.files = PLD1.x0.files
kernel_rfl PLD1.narch : PLD1.x1.arch = PLD1.x0.arch
kernel_rfl PLD1.nsizes : PLD1.x1.deviceSizes = PLD1.x0.deviceSizes
kernel_rfl PLD1.nwired : PLD1.x1.wired = PLD1.x0.wired
kernel_rfl PLD1.nhost : PLD1.y1.host = PLD1.y0.host

end Host.Load.Run.Tpl
