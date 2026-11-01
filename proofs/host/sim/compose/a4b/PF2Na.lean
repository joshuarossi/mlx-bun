import host.sim.compose.a4b.PFW2Walk
import host.sim.compose.a4b.PF15EClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PF2.P0 : LoadP := setupP.raise 19057
noncomputable abbrev PF2.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi)
noncomputable abbrev PF2.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x2_r0_suffix.s8.ffi)
noncomputable abbrev PF2.x0 : NSt := PF2.y0.mlx
noncomputable abbrev PF2.x1 : NSt := PF2.y1.mlx
noncomputable def PF2.thetaX : List (Nat × SymE) := [(30, .lit (F64.ofNat 16)), (31, .lit (F64.ofNat 16))]
noncomputable def PF2.θ : Nat → SymE := thetaOf (PFW2.R.theta ++ PF2.thetaX)
noncomputable def PF2.tabP : List SymE := PRE_first_tail_x2_r0_suffix.S8.tab ++ PRE_pf_vw.S0.tab.map (·.subst PF2.θ)
noncomputable def PF2.numAt (i : Nat) : Bool := match nth? PRE_pf_vw.S0.tab i with
  | some e => decide ((⟨PF2.tabP, []⟩ : SSrv).val (PFW2.R.data.map.num i) = some (e.subst PF2.θ))
  | none => true

kernel_rfl PF2.nnh0 : PFW2.R.data.nh0 = PF2.x0.next
kernel_rfl PF2.nnh1 : PFW2.R.data.nh1 = PF2.x1.next
kernel_rfl PF2.nnn0 : PFW2.R.data.nn0 = PF2.x0.nnext
kernel_rfl PF2.nnn1 : PFW2.R.data.nn1 = PF2.x1.nnext
kernel_rfl PF2.nlo : (Nat.blt 0 PF2.P0.lo && Nat.ble PF2.P0.lo PF2.x0.next && Nat.ble PF2.P0.lo RData.bigHi && Nat.ble RData.bigHi PF2.P0.E) = true
kernel_rfl PF2.ncnt : (Nat.ble PF2.x0.next PF2.x1.next && Nat.ble PF2.x0.nnext PF2.x1.nnext) = true
kernel_rfl PF2.nnband : (Nat.blt 0 PF2.P0.NL && Nat.ble PF2.P0.NL PF2.P0.N0 && Nat.ble PF2.P0.N0 PF2.x0.nnext) = true
kernel_rfl PF2.nhbelow : PFW2.R.data.checkHndBelow = true
kernel_rfl PF2.nhren : checkRenG PFW2.R.data.hnd PFW2.R.hinv (phB PF2.x0) = true
kernel_rfl PF2.nband : PFW2.R.data.checkBand PF2.P0.lo = true
kernel_rfl PF2.nnh1pos : Nat.blt 0 PFW2.R.data.nh1 = true
kernel_rfl PF2.nnren : checkRenG PFW2.R.data.node PFW2.R.ninv (pnB PF2.x0) = true
kernel_rfl PF2.nnlow : (PTrie.keysA PFW2.R.data.node).all (fun j => Nat.ble PF2.P0.NL j && Nat.blt (PFW2.R.data.nodeF j) PF2.x1.nnext) = true
kernel_rfl PF2.nnord : (fullAbove PF2.P0 PF2.x0).all (fun i => Nat.ble i (PFW2.R.data.nodeF i) &&
  (PTrie.keysA PFW2.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PFW2.R.data.nodeF j) (PFW2.R.data.nodeF i)) = true
kernel_rfl PF2.nitems : (PTrie.keysA PF2.x0.items).all (pnB PF2.x0) = true
kernel_rfl PF2.nssT : checkSSt PRE_pf_vw.n PF2.x0 = true
kernel_rfl PF2.nabs0a : PF2.x0.arrs.get 0 = none
kernel_rfl PF2.nabs0b : PF2.x0.objs.get 0 = none
kernel_rfl PF2.ntok1 : PF2.x1.tokens = []
kernel_rfl PF2.npend : PF2.x1.pending = PF2.x0.pending.map PFW2.R.data.map.pend
kernel_rfl PF2.nerrh : PF2.x1.errh = PF2.x0.errh.map PFW2.R.data.map.arg
kernel_rfl PF2.nfiles : PF2.x1.files = PF2.x0.files
kernel_rfl PF2.narch : PF2.x1.arch = PF2.x0.arch
kernel_rfl PF2.nsizes : PF2.x1.deviceSizes = PF2.x0.deviceSizes
kernel_rfl PF2.nwired : PF2.x1.wired = PF2.x0.wired
kernel_rfl PF2.nhost : PF2.y1.host = PF2.y0.host

end Host.Load.Run.Tpl
