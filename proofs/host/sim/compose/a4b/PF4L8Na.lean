import host.sim.compose.a4b.PFW4L8Walk
import host.sim.compose.a4b.PF4L8EClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PF4L8.P0 : LoadP := setupP.raise 19265
noncomputable abbrev PF4L8.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pf_x4_L8.s0.ffi)
noncomputable abbrev PF4L8.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x4_L8_r0_suffix.s8.ffi)
noncomputable abbrev PF4L8.x0 : NSt := PF4L8.y0.mlx
noncomputable abbrev PF4L8.x1 : NSt := PF4L8.y1.mlx
noncomputable def PF4L8.thetaX : List (Nat × SymE) := [(10, .bin .add (.lit (F64.zero false)) (.bin .sub (.bin .sub (.var 9) (.lit (F64.zero false))) (.lit (F64.fin false 1 (0))))), (30, .lit (F64.ofNat 16)), (31, .lit (F64.ofNat 16))]
noncomputable def PF4L8.θ : Nat → SymE := thetaOf (PFW4L8.R.theta ++ PF4L8.thetaX)
noncomputable def PF4L8.tabP : List SymE := PRE_first_tail_x4_L8_r0_suffix.S8.tab ++ PRE_pf_x4_L8.S0.tab.map (·.subst PF4L8.θ)
noncomputable def PF4L8.numAt (i : Nat) : Bool := match nth? PRE_pf_x4_L8.S0.tab i with
  | some e => decide ((⟨PF4L8.tabP, []⟩ : SSrv).val (PFW4L8.R.data.map.num i) = some (e.subst PF4L8.θ))
  | none => true

kernel_rfl PF4L8.nnh0 : PFW4L8.R.data.nh0 = PF4L8.x0.next
kernel_rfl PF4L8.nnh1 : PFW4L8.R.data.nh1 = PF4L8.x1.next
kernel_rfl PF4L8.nnn0 : PFW4L8.R.data.nn0 = PF4L8.x0.nnext
kernel_rfl PF4L8.nnn1 : PFW4L8.R.data.nn1 = PF4L8.x1.nnext
kernel_rfl PF4L8.nlo : (Nat.blt 0 PF4L8.P0.lo && Nat.ble PF4L8.P0.lo PF4L8.x0.next && Nat.ble PF4L8.P0.lo RData.bigHi && Nat.ble RData.bigHi PF4L8.P0.E) = true
kernel_rfl PF4L8.ncnt : (Nat.ble PF4L8.x0.next PF4L8.x1.next && Nat.ble PF4L8.x0.nnext PF4L8.x1.nnext) = true
kernel_rfl PF4L8.nnband : (Nat.blt 0 PF4L8.P0.NL && Nat.ble PF4L8.P0.NL PF4L8.P0.N0 && Nat.ble PF4L8.P0.N0 PF4L8.x0.nnext) = true
kernel_rfl PF4L8.nhbelow : PFW4L8.R.data.checkHndBelow = true
kernel_rfl PF4L8.nhren : checkRenG PFW4L8.R.data.hnd PFW4L8.R.hinv (phB PF4L8.x0) = true
kernel_rfl PF4L8.nband : PFW4L8.R.data.checkBand PF4L8.P0.lo = true
kernel_rfl PF4L8.nnh1pos : Nat.blt 0 PFW4L8.R.data.nh1 = true
kernel_rfl PF4L8.nnren : checkRenG PFW4L8.R.data.node PFW4L8.R.ninv (pnB PF4L8.x0) = true
kernel_rfl PF4L8.nnlow : (PTrie.keysA PFW4L8.R.data.node).all (fun j => Nat.ble PF4L8.P0.NL j && Nat.blt (PFW4L8.R.data.nodeF j) PF4L8.x1.nnext) = true
kernel_rfl PF4L8.nnord : (fullAbove PF4L8.P0 PF4L8.x0).all (fun i => Nat.ble i (PFW4L8.R.data.nodeF i) &&
  (PTrie.keysA PFW4L8.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PFW4L8.R.data.nodeF j) (PFW4L8.R.data.nodeF i)) = true
kernel_rfl PF4L8.nitems : (PTrie.keysA PF4L8.x0.items).all (pnB PF4L8.x0) = true
kernel_rfl PF4L8.nssT : checkSSt PRE_pf_x4_L8.n PF4L8.x0 = true
kernel_rfl PF4L8.nabs0a : PF4L8.x0.arrs.get 0 = none
kernel_rfl PF4L8.nabs0b : PF4L8.x0.objs.get 0 = none
kernel_rfl PF4L8.ntok1 : PF4L8.x1.tokens = []
kernel_rfl PF4L8.npend : PF4L8.x1.pending = PF4L8.x0.pending.map PFW4L8.R.data.map.pend
kernel_rfl PF4L8.nerrh : PF4L8.x1.errh = PF4L8.x0.errh.map PFW4L8.R.data.map.arg
kernel_rfl PF4L8.nfiles : PF4L8.x1.files = PF4L8.x0.files
kernel_rfl PF4L8.narch : PF4L8.x1.arch = PF4L8.x0.arch
kernel_rfl PF4L8.nsizes : PF4L8.x1.deviceSizes = PF4L8.x0.deviceSizes
kernel_rfl PF4L8.nwired : PF4L8.x1.wired = PF4L8.x0.wired
kernel_rfl PF4L8.nhost : PF4L8.y1.host = PF4L8.y0.host

end Host.Load.Run.Tpl
