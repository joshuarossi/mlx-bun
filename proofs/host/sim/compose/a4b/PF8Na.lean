import host.sim.compose.a4b.PFW8Walk
import host.sim.compose.a4b.PFVEClosed
import host.sim.template.NShiftOf
import host.sim.compose.PfLink
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def PF8.P0 : LoadP := setupP.raise 19057
noncomputable abbrev PF8.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi)
noncomputable abbrev PF8.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_suffix.s8.ffi)
noncomputable abbrev PF8.x0 : NSt := PF8.y0.mlx
noncomputable abbrev PF8.x1 : NSt := PF8.y1.mlx
noncomputable def PF8.thetaX : List (Nat × SymE) := [(30, SymE.lit (F64.fin false 16 (0))), (31, SymE.lit (F64.fin false 24 (0)))]
noncomputable def PF8.θ : Nat → SymE := thetaOf (PFW8.R.theta ++ PF8.thetaX)
noncomputable def PF8.numAt (i : Nat) : Bool := match nth? PRE_pf_vw.S0.tab i with
  | some e => decide ((⟨PRE_first_tail_x8_r0_suffix.S8.tab, []⟩ : SSrv).val (PFW8.R.data.map.num i) = some (e.subst PF8.θ))
  | none => true

kernel_rfl PF8.nnh0 : PFW8.R.data.nh0 = PF8.x0.next
kernel_rfl PF8.nnh1 : PFW8.R.data.nh1 = PF8.x1.next
kernel_rfl PF8.nnn0 : PFW8.R.data.nn0 = PF8.x0.nnext
kernel_rfl PF8.nnn1 : PFW8.R.data.nn1 = PF8.x1.nnext
kernel_rfl PF8.nlo : (Nat.blt 0 PF8.P0.lo && Nat.ble PF8.P0.lo PF8.x0.next && Nat.ble PF8.P0.lo RData.bigHi && Nat.ble RData.bigHi PF8.P0.E) = true
kernel_rfl PF8.ncnt : (Nat.ble PF8.x0.next PF8.x1.next && Nat.ble PF8.x0.nnext PF8.x1.nnext) = true
kernel_rfl PF8.nnband : (Nat.blt 0 PF8.P0.NL && Nat.ble PF8.P0.NL PF8.P0.N0 && Nat.ble PF8.P0.N0 PF8.x0.nnext) = true
kernel_rfl PF8.nhbelow : PFW8.R.data.checkHndBelow = true
kernel_rfl PF8.nhren : checkRenG PFW8.R.data.hnd PFW8.R.hinv (phB PF8.x0) = true
kernel_rfl PF8.nband : PFW8.R.data.checkBand PF8.P0.lo = true
kernel_rfl PF8.nnh1pos : Nat.blt 0 PFW8.R.data.nh1 = true
kernel_rfl PF8.nnren : checkRenG PFW8.R.data.node PFW8.R.ninv (pnB PF8.x0) = true
kernel_rfl PF8.nnlow : (PTrie.keysA PFW8.R.data.node).all (fun j => Nat.ble PF8.P0.NL j && Nat.blt (PFW8.R.data.nodeF j) PF8.x1.nnext) = true
kernel_rfl PF8.nnord : (fullAbove PF8.P0 PF8.x0).all (fun i => Nat.ble i (PFW8.R.data.nodeF i) &&
  (PTrie.keysA PFW8.R.data.node).all fun j => !Nat.blt j i || Nat.blt (PFW8.R.data.nodeF j) (PFW8.R.data.nodeF i)) = true
kernel_rfl PF8.nitems : (PTrie.keysA PF8.x0.items).all (pnB PF8.x0) = true
kernel_rfl PF8.nssT : checkSSt PRE_pf_vw.n PF8.x0 = true
kernel_rfl PF8.nabs0a : PF8.x0.arrs.get 0 = none
kernel_rfl PF8.nabs0b : PF8.x0.objs.get 0 = none
kernel_rfl PF8.ntok1 : PF8.x1.tokens = []
kernel_rfl PF8.npend : PF8.x1.pending = PF8.x0.pending.map PFW8.R.data.map.pend
kernel_rfl PF8.nerrh : PF8.x1.errh = PF8.x0.errh.map PFW8.R.data.map.arg
kernel_rfl PF8.nfiles : PF8.x1.files = PF8.x0.files
kernel_rfl PF8.narch : PF8.x1.arch = PF8.x0.arch
kernel_rfl PF8.nsizes : PF8.x1.deviceSizes = PF8.x0.deviceSizes
kernel_rfl PF8.nwired : PF8.x1.wired = PF8.x0.wired
kernel_rfl PF8.nhost : PF8.y1.host = PF8.y0.host

end Host.Load.Run.Tpl
