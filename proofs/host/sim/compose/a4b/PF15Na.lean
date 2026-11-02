import host.sim.compose.a4b.PFW15Walk
import host.sim.compose.a4b.PF15EClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PF15.P0 : LoadP := setupP.raise 19057
noncomputable abbrev PF15.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi)
noncomputable abbrev PF15.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s8.ffi)
noncomputable abbrev PF15.x0 : NSt := PF15.y0.mlx
noncomputable abbrev PF15.x1 : NSt := PF15.y1.mlx
noncomputable def PF15.thetaX : List (Nat × SymE) := [(30, .lit (F64.ofNat 16)), (31, .lit (F64.ofNat 16))]
noncomputable def PF15.θ : Nat → SymE := thetaOf (PFW15.R.theta ++ PF15.thetaX)
noncomputable def PF15.tabP : List SymE := PRE_first_tail_x15_r0_suffix.S8.tab ++ PRE_pf_vw.S0.tab.map (·.subst PF15.θ)
noncomputable def PF15.numAt (i : Nat) : Bool := match nth? PRE_pf_vw.S0.tab i with
  | some e => decide ((⟨PF15.tabP, []⟩ : SSrv).val (PFW15.R.data.map.num i) = some (e.subst PF15.θ))
  | none => true

kernel_rfl PF15.nnh0 : PFW15.R.data.nh0 = PF15.x0.next
kernel_rfl PF15.nnh1 : PFW15.R.data.nh1 = PF15.x1.next
kernel_rfl PF15.nnn0 : PFW15.R.data.nn0 = PF15.x0.nnext
kernel_rfl PF15.nnn1 : PFW15.R.data.nn1 = PF15.x1.nnext
kernel_rfl PF15.nlo : (Nat.blt 0 PF15.P0.lo && Nat.ble PF15.P0.lo PF15.x0.next && Nat.ble PF15.P0.lo RData.bigHi && Nat.ble RData.bigHi PF15.P0.E) = true
kernel_rfl PF15.ncnt : (Nat.ble PF15.x0.next PF15.x1.next && Nat.ble PF15.x0.nnext PF15.x1.nnext) = true
kernel_rfl PF15.nnband : (Nat.blt 0 PF15.P0.NL && Nat.ble PF15.P0.NL PF15.P0.N0 && Nat.ble PF15.P0.N0 PF15.x0.nnext) = true
kernel_rfl PF15.nhbelow : PFW15.R.data.checkHndBelow = true
kernel_rfl PF15.nhren : checkRenG PFW15.R.data.hnd PFW15.R.hinv (phB PF15.x0) = true
kernel_rfl PF15.nband : PFW15.R.data.checkBand PF15.P0.lo = true
kernel_rfl PF15.nnh1pos : Nat.blt 0 PFW15.R.data.nh1 = true
kernel_rfl PF15.nnren : checkRenG PFW15.R.data.node PFW15.R.ninv (pnB PF15.x0) = true
kernel_rfl PF15.nnlow : (PTrie.keysA PFW15.R.data.node).all (fun j => Nat.ble PF15.P0.NL j && Nat.blt (PFW15.R.data.nodeF j) PF15.x1.nnext) = true
kernel_rfl PF15.nnord : (fullAbove PF15.P0 PF15.x0).all (fun i => Nat.ble i (PFW15.R.data.nodeF i) &&
  (PTrie.keysA PFW15.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PFW15.R.data.nodeF j) (PFW15.R.data.nodeF i)) = true
kernel_rfl PF15.nitems : (PTrie.keysA PF15.x0.items).all (pnB PF15.x0) = true
kernel_rfl PF15.nssT : checkSSt PRE_pf_vw.n PF15.x0 = true
kernel_rfl PF15.nabs0a : PF15.x0.arrs.get 0 = none
kernel_rfl PF15.nabs0b : PF15.x0.objs.get 0 = none
kernel_rfl PF15.ntok1 : PF15.x1.tokens = []
kernel_rfl PF15.npend : PF15.x1.pending = PF15.x0.pending.map PFW15.R.data.map.pend
kernel_rfl PF15.nerrh : PF15.x1.errh = PF15.x0.errh.map PFW15.R.data.map.arg
kernel_rfl PF15.nfiles : PF15.x1.files = PF15.x0.files
kernel_rfl PF15.narch : PF15.x1.arch = PF15.x0.arch
kernel_rfl PF15.nsizes : PF15.x1.deviceSizes = PF15.x0.deviceSizes
kernel_rfl PF15.nwired : PF15.x1.wired = PF15.x0.wired
kernel_rfl PF15.nhost : PF15.y1.host = PF15.y0.host

end Host.Load.Run.Tpl
