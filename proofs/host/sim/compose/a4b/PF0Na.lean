import host.sim.compose.a4b.PFW0Walk
import host.sim.compose.a4b.PF0EClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PF0.P0 : LoadP := setupP.raise 17764
noncomputable abbrev PF0.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pf_x0.s0.ffi)
noncomputable abbrev PF0.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x0_r0_suffix.s8.ffi)
noncomputable abbrev PF0.x0 : NSt := PF0.y0.mlx
noncomputable abbrev PF0.x1 : NSt := PF0.y1.mlx
noncomputable def PF0.thetaX : List (Nat × SymE) := [(10, .bin .add (.lit (F64.zero false)) (.bin .sub (.bin .sub (.var 9) (.lit (F64.zero false))) (.lit (F64.fin false 1 (0))))), (30, .lit (F64.ofNat 16)), (31, .lit (F64.ofNat 16))]
noncomputable def PF0.θ : Nat → SymE := thetaOf (PFW0.R.theta ++ PF0.thetaX)
noncomputable def PF0.tabP : List SymE := PRE_first_tail_x0_r0_suffix.S8.tab ++ PRE_pf_x0.S0.tab.map (·.subst PF0.θ)
noncomputable def PF0.numAt (i : Nat) : Bool := match nth? PRE_pf_x0.S0.tab i with
  | some e => decide ((⟨PF0.tabP, []⟩ : SSrv).val (PFW0.R.data.map.num i) = some (e.subst PF0.θ))
  | none => true

kernel_rfl PF0.nnh0 : PFW0.R.data.nh0 = PF0.x0.next
kernel_rfl PF0.nnh1 : PFW0.R.data.nh1 = PF0.x1.next
kernel_rfl PF0.nnn0 : PFW0.R.data.nn0 = PF0.x0.nnext
kernel_rfl PF0.nnn1 : PFW0.R.data.nn1 = PF0.x1.nnext
kernel_rfl PF0.nlo : (Nat.blt 0 PF0.P0.lo && Nat.ble PF0.P0.lo PF0.x0.next && Nat.ble PF0.P0.lo RData.bigHi && Nat.ble RData.bigHi PF0.P0.E) = true
kernel_rfl PF0.ncnt : (Nat.ble PF0.x0.next PF0.x1.next && Nat.ble PF0.x0.nnext PF0.x1.nnext) = true
kernel_rfl PF0.nnband : (Nat.blt 0 PF0.P0.NL && Nat.ble PF0.P0.NL PF0.P0.N0 && Nat.ble PF0.P0.N0 PF0.x0.nnext) = true
kernel_rfl PF0.nhbelow : PFW0.R.data.checkHndBelow = true
kernel_rfl PF0.nhren : checkRenG PFW0.R.data.hnd PFW0.R.hinv (phB PF0.x0) = true
kernel_rfl PF0.nband : PFW0.R.data.checkBand PF0.P0.lo = true
kernel_rfl PF0.nnh1pos : Nat.blt 0 PFW0.R.data.nh1 = true
kernel_rfl PF0.nnren : checkRenG PFW0.R.data.node PFW0.R.ninv (pnB PF0.x0) = true
kernel_rfl PF0.nnlow : (PTrie.keysA PFW0.R.data.node).all (fun j => Nat.ble PF0.P0.NL j && Nat.blt (PFW0.R.data.nodeF j) PF0.x1.nnext) = true
kernel_rfl PF0.nnord : (fullAbove PF0.P0 PF0.x0).all (fun i => Nat.ble i (PFW0.R.data.nodeF i) &&
  (PTrie.keysA PFW0.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PFW0.R.data.nodeF j) (PFW0.R.data.nodeF i)) = true
kernel_rfl PF0.nitems : (PTrie.keysA PF0.x0.items).all (pnB PF0.x0) = true
kernel_rfl PF0.nssT : checkSSt PRE_pf_x0.n PF0.x0 = true
kernel_rfl PF0.nabs0a : PF0.x0.arrs.get 0 = none
kernel_rfl PF0.nabs0b : PF0.x0.objs.get 0 = none
kernel_rfl PF0.ntok1 : PF0.x1.tokens = []
kernel_rfl PF0.npend : PF0.x1.pending = PF0.x0.pending.map PFW0.R.data.map.pend
kernel_rfl PF0.nerrh : PF0.x1.errh = PF0.x0.errh.map PFW0.R.data.map.arg
kernel_rfl PF0.nfiles : PF0.x1.files = PF0.x0.files
kernel_rfl PF0.narch : PF0.x1.arch = PF0.x0.arch
kernel_rfl PF0.nsizes : PF0.x1.deviceSizes = PF0.x0.deviceSizes
kernel_rfl PF0.nwired : PF0.x1.wired = PF0.x0.wired
kernel_rfl PF0.nhost : PF0.y1.host = PF0.y0.host

end Host.Load.Run.Tpl
