import host.sim.compose.a4b.PLW4L7Walk
import host.sim.compose.a4b.PL4L7EClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PL4L7.P0 : LoadP := setupP.raise 21654
noncomputable abbrev PL4L7.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_plx4_L7_entry.s0.ffi)
noncomputable abbrev PL4L7.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_fd_x4_L7_r0_body.s451.ffi)
noncomputable abbrev PL4L7.x0 : NSt := PL4L7.y0.mlx
noncomputable abbrev PL4L7.x1 : NSt := PL4L7.y1.mlx
noncomputable def PL4L7.thetaX : List (Nat × SymE) := [(10, .lit (F64.ofNat 1))]
noncomputable def PL4L7.θ : Nat → SymE := thetaOf (PLW4L7.R.theta ++ PL4L7.thetaX)
noncomputable def PL4L7.tabP : List SymE := PRE_fd_x4_L7_r0_body.S451.tab ++ PRE_plx4_L7_entry.S0.tab.map (·.subst PL4L7.θ)
noncomputable def PL4L7.numAt (i : Nat) : Bool := match nth? PRE_plx4_L7_entry.S0.tab i with
  | some e => decide ((⟨PL4L7.tabP, []⟩ : SSrv).val (PLW4L7.R.data.map.num i) = some (e.subst PL4L7.θ))
  | none => true

kernel_rfl PL4L7.nnh0 : PLW4L7.R.data.nh0 = PL4L7.x0.next
kernel_rfl PL4L7.nnh1 : PLW4L7.R.data.nh1 = PL4L7.x1.next
kernel_rfl PL4L7.nnn0 : PLW4L7.R.data.nn0 = PL4L7.x0.nnext
kernel_rfl PL4L7.nnn1 : PLW4L7.R.data.nn1 = PL4L7.x1.nnext
kernel_rfl PL4L7.nlo : (Nat.blt 0 PL4L7.P0.lo && Nat.ble PL4L7.P0.lo PL4L7.x0.next && Nat.ble PL4L7.P0.lo RData.bigHi && Nat.ble RData.bigHi PL4L7.P0.E) = true
kernel_rfl PL4L7.ncnt : (Nat.ble PL4L7.x0.next PL4L7.x1.next && Nat.ble PL4L7.x0.nnext PL4L7.x1.nnext) = true
kernel_rfl PL4L7.nnband : (Nat.blt 0 PL4L7.P0.NL && Nat.ble PL4L7.P0.NL PL4L7.P0.N0 && Nat.ble PL4L7.P0.N0 PL4L7.x0.nnext) = true
kernel_rfl PL4L7.nhbelow : PLW4L7.R.data.checkHndBelow = true
kernel_rfl PL4L7.nhren : checkRenG PLW4L7.R.data.hnd PLW4L7.R.hinv (phB PL4L7.x0) = true
kernel_rfl PL4L7.nband : PLW4L7.R.data.checkBand PL4L7.P0.lo = true
kernel_rfl PL4L7.nnh1pos : Nat.blt 0 PLW4L7.R.data.nh1 = true
kernel_rfl PL4L7.nnren : checkRenG PLW4L7.R.data.node PLW4L7.R.ninv (pnB PL4L7.x0) = true
kernel_rfl PL4L7.nnlow : (PTrie.keysA PLW4L7.R.data.node).all (fun j => Nat.ble PL4L7.P0.NL j && Nat.blt (PLW4L7.R.data.nodeF j) PL4L7.x1.nnext) = true
kernel_rfl PL4L7.nnord : (fullAbove PL4L7.P0 PL4L7.x0).all (fun i => Nat.ble i (PLW4L7.R.data.nodeF i) &&
  (PTrie.keysA PLW4L7.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PLW4L7.R.data.nodeF j) (PLW4L7.R.data.nodeF i)) = true
kernel_rfl PL4L7.nitems : (PTrie.keysA PL4L7.x0.items).all (pnB PL4L7.x0) = true
kernel_rfl PL4L7.nssT : checkSSt PRE_plx4_L7_entry.n PL4L7.x0 = true
kernel_rfl PL4L7.nabs0a : PL4L7.x0.arrs.get 0 = none
kernel_rfl PL4L7.nabs0b : PL4L7.x0.objs.get 0 = none
kernel_rfl PL4L7.ntok1 : PL4L7.x1.tokens = []
kernel_rfl PL4L7.npend : PL4L7.x1.pending = PL4L7.x0.pending.map PLW4L7.R.data.map.pend
kernel_rfl PL4L7.nerrh : PL4L7.x1.errh = PL4L7.x0.errh.map PLW4L7.R.data.map.arg
kernel_rfl PL4L7.nfiles : PL4L7.x1.files = PL4L7.x0.files
kernel_rfl PL4L7.narch : PL4L7.x1.arch = PL4L7.x0.arch
kernel_rfl PL4L7.nsizes : PL4L7.x1.deviceSizes = PL4L7.x0.deviceSizes
kernel_rfl PL4L7.nwired : PL4L7.x1.wired = PL4L7.x0.wired
kernel_rfl PL4L7.nhost : PL4L7.y1.host = PL4L7.y0.host

end Host.Load.Run.Tpl
