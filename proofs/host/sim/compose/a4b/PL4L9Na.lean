import host.sim.compose.a4b.PLW4L9Walk
import host.sim.compose.a4b.PL4L9EClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PL4L9.P0 : LoadP := setupP.raise 21654
noncomputable abbrev PL4L9.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_plx4_L9_entry.s0.ffi)
noncomputable abbrev PL4L9.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_fd_x4_L9_r0_body.s451.ffi)
noncomputable abbrev PL4L9.x0 : NSt := PL4L9.y0.mlx
noncomputable abbrev PL4L9.x1 : NSt := PL4L9.y1.mlx
noncomputable def PL4L9.thetaX : List (Nat × SymE) := [(10, .lit (F64.ofNat 1))]
noncomputable def PL4L9.θ : Nat → SymE := thetaOf (PLW4L9.R.theta ++ PL4L9.thetaX)
noncomputable def PL4L9.tabP : List SymE := PRE_fd_x4_L9_r0_body.S451.tab ++ PRE_plx4_L9_entry.S0.tab.map (·.subst PL4L9.θ)
noncomputable def PL4L9.numAt (i : Nat) : Bool := match nth? PRE_plx4_L9_entry.S0.tab i with
  | some e => decide ((⟨PL4L9.tabP, []⟩ : SSrv).val (PLW4L9.R.data.map.num i) = some (e.subst PL4L9.θ))
  | none => true

kernel_rfl PL4L9.nnh0 : PLW4L9.R.data.nh0 = PL4L9.x0.next
kernel_rfl PL4L9.nnh1 : PLW4L9.R.data.nh1 = PL4L9.x1.next
kernel_rfl PL4L9.nnn0 : PLW4L9.R.data.nn0 = PL4L9.x0.nnext
kernel_rfl PL4L9.nnn1 : PLW4L9.R.data.nn1 = PL4L9.x1.nnext
kernel_rfl PL4L9.nlo : (Nat.blt 0 PL4L9.P0.lo && Nat.ble PL4L9.P0.lo PL4L9.x0.next && Nat.ble PL4L9.P0.lo RData.bigHi && Nat.ble RData.bigHi PL4L9.P0.E) = true
kernel_rfl PL4L9.ncnt : (Nat.ble PL4L9.x0.next PL4L9.x1.next && Nat.ble PL4L9.x0.nnext PL4L9.x1.nnext) = true
kernel_rfl PL4L9.nnband : (Nat.blt 0 PL4L9.P0.NL && Nat.ble PL4L9.P0.NL PL4L9.P0.N0 && Nat.ble PL4L9.P0.N0 PL4L9.x0.nnext) = true
kernel_rfl PL4L9.nhbelow : PLW4L9.R.data.checkHndBelow = true
kernel_rfl PL4L9.nhren : checkRenG PLW4L9.R.data.hnd PLW4L9.R.hinv (phB PL4L9.x0) = true
kernel_rfl PL4L9.nband : PLW4L9.R.data.checkBand PL4L9.P0.lo = true
kernel_rfl PL4L9.nnh1pos : Nat.blt 0 PLW4L9.R.data.nh1 = true
kernel_rfl PL4L9.nnren : checkRenG PLW4L9.R.data.node PLW4L9.R.ninv (pnB PL4L9.x0) = true
kernel_rfl PL4L9.nnlow : (PTrie.keysA PLW4L9.R.data.node).all (fun j => Nat.ble PL4L9.P0.NL j && Nat.blt (PLW4L9.R.data.nodeF j) PL4L9.x1.nnext) = true
kernel_rfl PL4L9.nnord : (fullAbove PL4L9.P0 PL4L9.x0).all (fun i => Nat.ble i (PLW4L9.R.data.nodeF i) &&
  (PTrie.keysA PLW4L9.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PLW4L9.R.data.nodeF j) (PLW4L9.R.data.nodeF i)) = true
kernel_rfl PL4L9.nitems : (PTrie.keysA PL4L9.x0.items).all (pnB PL4L9.x0) = true
kernel_rfl PL4L9.nssT : checkSSt PRE_plx4_L9_entry.n PL4L9.x0 = true
kernel_rfl PL4L9.nabs0a : PL4L9.x0.arrs.get 0 = none
kernel_rfl PL4L9.nabs0b : PL4L9.x0.objs.get 0 = none
kernel_rfl PL4L9.ntok1 : PL4L9.x1.tokens = []
kernel_rfl PL4L9.npend : PL4L9.x1.pending = PL4L9.x0.pending.map PLW4L9.R.data.map.pend
kernel_rfl PL4L9.nerrh : PL4L9.x1.errh = PL4L9.x0.errh.map PLW4L9.R.data.map.arg
kernel_rfl PL4L9.nfiles : PL4L9.x1.files = PL4L9.x0.files
kernel_rfl PL4L9.narch : PL4L9.x1.arch = PL4L9.x0.arch
kernel_rfl PL4L9.nsizes : PL4L9.x1.deviceSizes = PL4L9.x0.deviceSizes
kernel_rfl PL4L9.nwired : PL4L9.x1.wired = PL4L9.x0.wired
kernel_rfl PL4L9.nhost : PL4L9.y1.host = PL4L9.y0.host

end Host.Load.Run.Tpl
