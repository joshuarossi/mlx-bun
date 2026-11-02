import host.sim.compose.a4b.PFW6Walk
import host.sim.compose.a4b.PF15EClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PF6.P0 : LoadP := setupP.raise 19057
noncomputable abbrev PF6.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi)
noncomputable abbrev PF6.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s8.ffi)
noncomputable abbrev PF6.x0 : NSt := PF6.y0.mlx
noncomputable abbrev PF6.x1 : NSt := PF6.y1.mlx
noncomputable def PF6.thetaX : List (Nat × SymE) := [(30, .lit (F64.ofNat 24)), (31, .lit (F64.ofNat 24))]
noncomputable def PF6.θ : Nat → SymE := thetaOf (PFW6.R.theta ++ PF6.thetaX)
noncomputable def PF6.tabP : List SymE := PRE_first_tail_x6_r0_suffix.S8.tab ++ PRE_pf_vw.S0.tab.map (·.subst PF6.θ)
noncomputable def PF6.numAt (i : Nat) : Bool := match nth? PRE_pf_vw.S0.tab i with
  | some e => decide ((⟨PF6.tabP, []⟩ : SSrv).val (PFW6.R.data.map.num i) = some (e.subst PF6.θ))
  | none => true

kernel_rfl PF6.nnh0 : PFW6.R.data.nh0 = PF6.x0.next
kernel_rfl PF6.nnh1 : PFW6.R.data.nh1 = PF6.x1.next
kernel_rfl PF6.nnn0 : PFW6.R.data.nn0 = PF6.x0.nnext
kernel_rfl PF6.nnn1 : PFW6.R.data.nn1 = PF6.x1.nnext
kernel_rfl PF6.nlo : (Nat.blt 0 PF6.P0.lo && Nat.ble PF6.P0.lo PF6.x0.next && Nat.ble PF6.P0.lo RData.bigHi && Nat.ble RData.bigHi PF6.P0.E) = true
kernel_rfl PF6.ncnt : (Nat.ble PF6.x0.next PF6.x1.next && Nat.ble PF6.x0.nnext PF6.x1.nnext) = true
kernel_rfl PF6.nnband : (Nat.blt 0 PF6.P0.NL && Nat.ble PF6.P0.NL PF6.P0.N0 && Nat.ble PF6.P0.N0 PF6.x0.nnext) = true
kernel_rfl PF6.nhbelow : PFW6.R.data.checkHndBelow = true
kernel_rfl PF6.nhren : checkRenG PFW6.R.data.hnd PFW6.R.hinv (phB PF6.x0) = true
kernel_rfl PF6.nband : PFW6.R.data.checkBand PF6.P0.lo = true
kernel_rfl PF6.nnh1pos : Nat.blt 0 PFW6.R.data.nh1 = true
kernel_rfl PF6.nnren : checkRenG PFW6.R.data.node PFW6.R.ninv (pnB PF6.x0) = true
kernel_rfl PF6.nnlow : (PTrie.keysA PFW6.R.data.node).all (fun j => Nat.ble PF6.P0.NL j && Nat.blt (PFW6.R.data.nodeF j) PF6.x1.nnext) = true
kernel_rfl PF6.nnord : (fullAbove PF6.P0 PF6.x0).all (fun i => Nat.ble i (PFW6.R.data.nodeF i) &&
  (PTrie.keysA PFW6.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PFW6.R.data.nodeF j) (PFW6.R.data.nodeF i)) = true
kernel_rfl PF6.nitems : (PTrie.keysA PF6.x0.items).all (pnB PF6.x0) = true
kernel_rfl PF6.nssT : checkSSt PRE_pf_vw.n PF6.x0 = true
kernel_rfl PF6.nabs0a : PF6.x0.arrs.get 0 = none
kernel_rfl PF6.nabs0b : PF6.x0.objs.get 0 = none
kernel_rfl PF6.ntok1 : PF6.x1.tokens = []
kernel_rfl PF6.npend : PF6.x1.pending = PF6.x0.pending.map PFW6.R.data.map.pend
kernel_rfl PF6.nerrh : PF6.x1.errh = PF6.x0.errh.map PFW6.R.data.map.arg
kernel_rfl PF6.nfiles : PF6.x1.files = PF6.x0.files
kernel_rfl PF6.narch : PF6.x1.arch = PF6.x0.arch
kernel_rfl PF6.nsizes : PF6.x1.deviceSizes = PF6.x0.deviceSizes
kernel_rfl PF6.nwired : PF6.x1.wired = PF6.x0.wired
kernel_rfl PF6.nhost : PF6.y1.host = PF6.y0.host

end Host.Load.Run.Tpl
