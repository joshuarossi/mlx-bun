import host.sim.compose.a4b.PFW4L9Walk
import host.sim.compose.a4b.PF4L9EClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PF4L9.P0 : LoadP := setupP.raise 19265
noncomputable abbrev PF4L9.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pf_x4_L9.s0.ffi)
noncomputable abbrev PF4L9.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_suffix.s8.ffi)
noncomputable abbrev PF4L9.x0 : NSt := PF4L9.y0.mlx
noncomputable abbrev PF4L9.x1 : NSt := PF4L9.y1.mlx
noncomputable def PF4L9.thetaX : List (Nat × SymE) := [(10, .bin .add (.lit (F64.zero false)) (.bin .sub (.bin .sub (.var 9) (.lit (F64.zero false))) (.lit (F64.fin false 1 (0))))), (30, .lit (F64.ofNat 16)), (31, .lit (F64.ofNat 16))]
noncomputable def PF4L9.θ : Nat → SymE := thetaOf (PFW4L9.R.theta ++ PF4L9.thetaX)
noncomputable def PF4L9.tabP : List SymE := PRE_first_tail_x4_L9_r0_suffix.S8.tab ++ PRE_pf_x4_L9.S0.tab.map (·.subst PF4L9.θ)
noncomputable def PF4L9.numAt (i : Nat) : Bool := match nth? PRE_pf_x4_L9.S0.tab i with
  | some e => decide ((⟨PF4L9.tabP, []⟩ : SSrv).val (PFW4L9.R.data.map.num i) = some (e.subst PF4L9.θ))
  | none => true

kernel_rfl PF4L9.nnh0 : PFW4L9.R.data.nh0 = PF4L9.x0.next
kernel_rfl PF4L9.nnh1 : PFW4L9.R.data.nh1 = PF4L9.x1.next
kernel_rfl PF4L9.nnn0 : PFW4L9.R.data.nn0 = PF4L9.x0.nnext
kernel_rfl PF4L9.nnn1 : PFW4L9.R.data.nn1 = PF4L9.x1.nnext
kernel_rfl PF4L9.nlo : (Nat.blt 0 PF4L9.P0.lo && Nat.ble PF4L9.P0.lo PF4L9.x0.next && Nat.ble PF4L9.P0.lo RData.bigHi && Nat.ble RData.bigHi PF4L9.P0.E) = true
kernel_rfl PF4L9.ncnt : (Nat.ble PF4L9.x0.next PF4L9.x1.next && Nat.ble PF4L9.x0.nnext PF4L9.x1.nnext) = true
kernel_rfl PF4L9.nnband : (Nat.blt 0 PF4L9.P0.NL && Nat.ble PF4L9.P0.NL PF4L9.P0.N0 && Nat.ble PF4L9.P0.N0 PF4L9.x0.nnext) = true
kernel_rfl PF4L9.nhbelow : PFW4L9.R.data.checkHndBelow = true
kernel_rfl PF4L9.nhren : checkRenG PFW4L9.R.data.hnd PFW4L9.R.hinv (phB PF4L9.x0) = true
kernel_rfl PF4L9.nband : PFW4L9.R.data.checkBand PF4L9.P0.lo = true
kernel_rfl PF4L9.nnh1pos : Nat.blt 0 PFW4L9.R.data.nh1 = true
kernel_rfl PF4L9.nnren : checkRenG PFW4L9.R.data.node PFW4L9.R.ninv (pnB PF4L9.x0) = true
kernel_rfl PF4L9.nnlow : (PTrie.keysA PFW4L9.R.data.node).all (fun j => Nat.ble PF4L9.P0.NL j && Nat.blt (PFW4L9.R.data.nodeF j) PF4L9.x1.nnext) = true
kernel_rfl PF4L9.nnord : (fullAbove PF4L9.P0 PF4L9.x0).all (fun i => Nat.ble i (PFW4L9.R.data.nodeF i) &&
  (PTrie.keysA PFW4L9.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PFW4L9.R.data.nodeF j) (PFW4L9.R.data.nodeF i)) = true
kernel_rfl PF4L9.nitems : (PTrie.keysA PF4L9.x0.items).all (pnB PF4L9.x0) = true
kernel_rfl PF4L9.nssT : checkSSt PRE_pf_x4_L9.n PF4L9.x0 = true
kernel_rfl PF4L9.nabs0a : PF4L9.x0.arrs.get 0 = none
kernel_rfl PF4L9.nabs0b : PF4L9.x0.objs.get 0 = none
kernel_rfl PF4L9.ntok1 : PF4L9.x1.tokens = []
kernel_rfl PF4L9.npend : PF4L9.x1.pending = PF4L9.x0.pending.map PFW4L9.R.data.map.pend
kernel_rfl PF4L9.nerrh : PF4L9.x1.errh = PF4L9.x0.errh.map PFW4L9.R.data.map.arg
kernel_rfl PF4L9.nfiles : PF4L9.x1.files = PF4L9.x0.files
kernel_rfl PF4L9.narch : PF4L9.x1.arch = PF4L9.x0.arch
kernel_rfl PF4L9.nsizes : PF4L9.x1.deviceSizes = PF4L9.x0.deviceSizes
kernel_rfl PF4L9.nwired : PF4L9.x1.wired = PF4L9.x0.wired
kernel_rfl PF4L9.nhost : PF4L9.y1.host = PF4L9.y0.host

end Host.Load.Run.Tpl
