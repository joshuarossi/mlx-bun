import host.sim.compose.a4b.PLW0Walk
import host.sim.compose.a4b.PL0EClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PL0.P0 : LoadP := setupP.raise 20138
noncomputable abbrev PL0.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_plx0_entry.s0.ffi)
noncomputable abbrev PL0.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_fd_x0_r0_body.s447.ffi)
noncomputable abbrev PL0.x0 : NSt := PL0.y0.mlx
noncomputable abbrev PL0.x1 : NSt := PL0.y1.mlx
noncomputable def PL0.thetaX : List (Nat × SymE) := [(10, .lit (F64.ofNat 1))]
noncomputable def PL0.θ : Nat → SymE := thetaOf (PLW0.R.theta ++ PL0.thetaX)
noncomputable def PL0.tabP : List SymE := PRE_fd_x0_r0_body.S447.tab ++ PRE_plx0_entry.S0.tab.map (·.subst PL0.θ)
noncomputable def PL0.numAt (i : Nat) : Bool := match nth? PRE_plx0_entry.S0.tab i with
  | some e => decide ((⟨PL0.tabP, []⟩ : SSrv).val (PLW0.R.data.map.num i) = some (e.subst PL0.θ))
  | none => true

kernel_rfl PL0.nnh0 : PLW0.R.data.nh0 = PL0.x0.next
kernel_rfl PL0.nnh1 : PLW0.R.data.nh1 = PL0.x1.next
kernel_rfl PL0.nnn0 : PLW0.R.data.nn0 = PL0.x0.nnext
kernel_rfl PL0.nnn1 : PLW0.R.data.nn1 = PL0.x1.nnext
kernel_rfl PL0.nlo : (Nat.blt 0 PL0.P0.lo && Nat.ble PL0.P0.lo PL0.x0.next && Nat.ble PL0.P0.lo RData.bigHi && Nat.ble RData.bigHi PL0.P0.E) = true
kernel_rfl PL0.ncnt : (Nat.ble PL0.x0.next PL0.x1.next && Nat.ble PL0.x0.nnext PL0.x1.nnext) = true
kernel_rfl PL0.nnband : (Nat.blt 0 PL0.P0.NL && Nat.ble PL0.P0.NL PL0.P0.N0 && Nat.ble PL0.P0.N0 PL0.x0.nnext) = true
kernel_rfl PL0.nhbelow : PLW0.R.data.checkHndBelow = true
kernel_rfl PL0.nhren : checkRenG PLW0.R.data.hnd PLW0.R.hinv (phB PL0.x0) = true
kernel_rfl PL0.nband : PLW0.R.data.checkBand PL0.P0.lo = true
kernel_rfl PL0.nnh1pos : Nat.blt 0 PLW0.R.data.nh1 = true
kernel_rfl PL0.nnren : checkRenG PLW0.R.data.node PLW0.R.ninv (pnB PL0.x0) = true
kernel_rfl PL0.nnlow : (PTrie.keysA PLW0.R.data.node).all (fun j => Nat.ble PL0.P0.NL j && Nat.blt (PLW0.R.data.nodeF j) PL0.x1.nnext) = true
kernel_rfl PL0.nnord : (fullAbove PL0.P0 PL0.x0).all (fun i => Nat.ble i (PLW0.R.data.nodeF i) &&
  (PTrie.keysA PLW0.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PLW0.R.data.nodeF j) (PLW0.R.data.nodeF i)) = true
kernel_rfl PL0.nitems : (PTrie.keysA PL0.x0.items).all (pnB PL0.x0) = true
kernel_rfl PL0.nssT : checkSSt PRE_plx0_entry.n PL0.x0 = true
kernel_rfl PL0.nabs0a : PL0.x0.arrs.get 0 = none
kernel_rfl PL0.nabs0b : PL0.x0.objs.get 0 = none
kernel_rfl PL0.ntok1 : PL0.x1.tokens = []
kernel_rfl PL0.npend : PL0.x1.pending = PL0.x0.pending.map PLW0.R.data.map.pend
kernel_rfl PL0.nerrh : PL0.x1.errh = PL0.x0.errh.map PLW0.R.data.map.arg
kernel_rfl PL0.nfiles : PL0.x1.files = PL0.x0.files
kernel_rfl PL0.narch : PL0.x1.arch = PL0.x0.arch
kernel_rfl PL0.nsizes : PL0.x1.deviceSizes = PL0.x0.deviceSizes
kernel_rfl PL0.nwired : PL0.x1.wired = PL0.x0.wired
kernel_rfl PL0.nhost : PL0.y1.host = PL0.y0.host

end Host.Load.Run.Tpl
