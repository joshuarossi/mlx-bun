import host.sim.compose.a4b.PFW1Walk
import host.sim.compose.a4b.PF15EClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PF1.P0 : LoadP := setupP.raise 19057
noncomputable abbrev PF1.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi)
noncomputable abbrev PF1.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x1_r0_suffix.s8.ffi)
noncomputable abbrev PF1.x0 : NSt := PF1.y0.mlx
noncomputable abbrev PF1.x1 : NSt := PF1.y1.mlx
noncomputable def PF1.thetaX : List (Nat × SymE) := [(30, .lit (F64.ofNat 16)), (31, .lit (F64.ofNat 16))]
noncomputable def PF1.θ : Nat → SymE := thetaOf (PFW1.R.theta ++ PF1.thetaX)
noncomputable def PF1.tabP : List SymE := PRE_first_tail_x1_r0_suffix.S8.tab ++ PRE_pf_vw.S0.tab.map (·.subst PF1.θ)
noncomputable def PF1.numAt (i : Nat) : Bool := match nth? PRE_pf_vw.S0.tab i with
  | some e => decide ((⟨PF1.tabP, []⟩ : SSrv).val (PFW1.R.data.map.num i) = some (e.subst PF1.θ))
  | none => true

kernel_rfl PF1.nnh0 : PFW1.R.data.nh0 = PF1.x0.next
kernel_rfl PF1.nnh1 : PFW1.R.data.nh1 = PF1.x1.next
kernel_rfl PF1.nnn0 : PFW1.R.data.nn0 = PF1.x0.nnext
kernel_rfl PF1.nnn1 : PFW1.R.data.nn1 = PF1.x1.nnext
kernel_rfl PF1.nlo : (Nat.blt 0 PF1.P0.lo && Nat.ble PF1.P0.lo PF1.x0.next && Nat.ble PF1.P0.lo RData.bigHi && Nat.ble RData.bigHi PF1.P0.E) = true
kernel_rfl PF1.ncnt : (Nat.ble PF1.x0.next PF1.x1.next && Nat.ble PF1.x0.nnext PF1.x1.nnext) = true
kernel_rfl PF1.nnband : (Nat.blt 0 PF1.P0.NL && Nat.ble PF1.P0.NL PF1.P0.N0 && Nat.ble PF1.P0.N0 PF1.x0.nnext) = true
kernel_rfl PF1.nhbelow : PFW1.R.data.checkHndBelow = true
kernel_rfl PF1.nhren : checkRenG PFW1.R.data.hnd PFW1.R.hinv (phB PF1.x0) = true
kernel_rfl PF1.nband : PFW1.R.data.checkBand PF1.P0.lo = true
kernel_rfl PF1.nnh1pos : Nat.blt 0 PFW1.R.data.nh1 = true
kernel_rfl PF1.nnren : checkRenG PFW1.R.data.node PFW1.R.ninv (pnB PF1.x0) = true
kernel_rfl PF1.nnlow : (PTrie.keysA PFW1.R.data.node).all (fun j => Nat.ble PF1.P0.NL j && Nat.blt (PFW1.R.data.nodeF j) PF1.x1.nnext) = true
kernel_rfl PF1.nnord : (fullAbove PF1.P0 PF1.x0).all (fun i => Nat.ble i (PFW1.R.data.nodeF i) &&
  (PTrie.keysA PFW1.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PFW1.R.data.nodeF j) (PFW1.R.data.nodeF i)) = true
kernel_rfl PF1.nitems : (PTrie.keysA PF1.x0.items).all (pnB PF1.x0) = true
kernel_rfl PF1.nssT : checkSSt PRE_pf_vw.n PF1.x0 = true
kernel_rfl PF1.nabs0a : PF1.x0.arrs.get 0 = none
kernel_rfl PF1.nabs0b : PF1.x0.objs.get 0 = none
kernel_rfl PF1.ntok1 : PF1.x1.tokens = []
kernel_rfl PF1.npend : PF1.x1.pending = PF1.x0.pending.map PFW1.R.data.map.pend
kernel_rfl PF1.nerrh : PF1.x1.errh = PF1.x0.errh.map PFW1.R.data.map.arg
kernel_rfl PF1.nfiles : PF1.x1.files = PF1.x0.files
kernel_rfl PF1.narch : PF1.x1.arch = PF1.x0.arch
kernel_rfl PF1.nsizes : PF1.x1.deviceSizes = PF1.x0.deviceSizes
kernel_rfl PF1.nwired : PF1.x1.wired = PF1.x0.wired
kernel_rfl PF1.nhost : PF1.y1.host = PF1.y0.host

end Host.Load.Run.Tpl
