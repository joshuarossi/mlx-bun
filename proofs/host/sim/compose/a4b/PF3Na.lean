import host.sim.compose.a4b.PFW3Walk
import host.sim.compose.a4b.PF15EClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PF3.P0 : LoadP := setupP.raise 19057
noncomputable abbrev PF3.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi)
noncomputable abbrev PF3.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x3_r0_suffix.s8.ffi)
noncomputable abbrev PF3.x0 : NSt := PF3.y0.mlx
noncomputable abbrev PF3.x1 : NSt := PF3.y1.mlx
noncomputable def PF3.thetaX : List (Nat × SymE) := [(30, .lit (F64.ofNat 16)), (31, .lit (F64.ofNat 16))]
noncomputable def PF3.θ : Nat → SymE := thetaOf (PFW3.R.theta ++ PF3.thetaX)
noncomputable def PF3.tabP : List SymE := PRE_first_tail_x3_r0_suffix.S8.tab ++ PRE_pf_vw.S0.tab.map (·.subst PF3.θ)
noncomputable def PF3.numAt (i : Nat) : Bool := match nth? PRE_pf_vw.S0.tab i with
  | some e => decide ((⟨PF3.tabP, []⟩ : SSrv).val (PFW3.R.data.map.num i) = some (e.subst PF3.θ))
  | none => true

kernel_rfl PF3.nnh0 : PFW3.R.data.nh0 = PF3.x0.next
kernel_rfl PF3.nnh1 : PFW3.R.data.nh1 = PF3.x1.next
kernel_rfl PF3.nnn0 : PFW3.R.data.nn0 = PF3.x0.nnext
kernel_rfl PF3.nnn1 : PFW3.R.data.nn1 = PF3.x1.nnext
kernel_rfl PF3.nlo : (Nat.blt 0 PF3.P0.lo && Nat.ble PF3.P0.lo PF3.x0.next && Nat.ble PF3.P0.lo RData.bigHi && Nat.ble RData.bigHi PF3.P0.E) = true
kernel_rfl PF3.ncnt : (Nat.ble PF3.x0.next PF3.x1.next && Nat.ble PF3.x0.nnext PF3.x1.nnext) = true
kernel_rfl PF3.nnband : (Nat.blt 0 PF3.P0.NL && Nat.ble PF3.P0.NL PF3.P0.N0 && Nat.ble PF3.P0.N0 PF3.x0.nnext) = true
kernel_rfl PF3.nhbelow : PFW3.R.data.checkHndBelow = true
kernel_rfl PF3.nhren : checkRenG PFW3.R.data.hnd PFW3.R.hinv (phB PF3.x0) = true
kernel_rfl PF3.nband : PFW3.R.data.checkBand PF3.P0.lo = true
kernel_rfl PF3.nnh1pos : Nat.blt 0 PFW3.R.data.nh1 = true
kernel_rfl PF3.nnren : checkRenG PFW3.R.data.node PFW3.R.ninv (pnB PF3.x0) = true
kernel_rfl PF3.nnlow : (PTrie.keysA PFW3.R.data.node).all (fun j => Nat.ble PF3.P0.NL j && Nat.blt (PFW3.R.data.nodeF j) PF3.x1.nnext) = true
kernel_rfl PF3.nnord : (fullAbove PF3.P0 PF3.x0).all (fun i => Nat.ble i (PFW3.R.data.nodeF i) &&
  (PTrie.keysA PFW3.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PFW3.R.data.nodeF j) (PFW3.R.data.nodeF i)) = true
kernel_rfl PF3.nitems : (PTrie.keysA PF3.x0.items).all (pnB PF3.x0) = true
kernel_rfl PF3.nssT : checkSSt PRE_pf_vw.n PF3.x0 = true
kernel_rfl PF3.nabs0a : PF3.x0.arrs.get 0 = none
kernel_rfl PF3.nabs0b : PF3.x0.objs.get 0 = none
kernel_rfl PF3.ntok1 : PF3.x1.tokens = []
kernel_rfl PF3.npend : PF3.x1.pending = PF3.x0.pending.map PFW3.R.data.map.pend
kernel_rfl PF3.nerrh : PF3.x1.errh = PF3.x0.errh.map PFW3.R.data.map.arg
kernel_rfl PF3.nfiles : PF3.x1.files = PF3.x0.files
kernel_rfl PF3.narch : PF3.x1.arch = PF3.x0.arch
kernel_rfl PF3.nsizes : PF3.x1.deviceSizes = PF3.x0.deviceSizes
kernel_rfl PF3.nwired : PF3.x1.wired = PF3.x0.wired
kernel_rfl PF3.nhost : PF3.y1.host = PF3.y0.host

end Host.Load.Run.Tpl
