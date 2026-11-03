import host.sim.compose.a4b.PL0EClosed
import host.sim.BigFree
import host.sim.native.RebigR
import host.sim.compose.JsAbove
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PRE_plx0_entry.hnext : (Host.Load.Layers.toLoad PRE_plx0_entry.s0.ffi).mlx.next = 25619
noncomputable def PRE_plx0_entry.freshAt (a : Nat) : Bool := noBigAtB 25619 131072 PRE_plx0_entry.s0 a
tpl_all_blocks PRE_plx0_entry.FB from PL0EV : PRE_plx0_entry.freshAt
kernel_rfl PRE_plx0_entry.freshFramed : PL0EV.frames.all PRE_plx0_entry.freshAt = true
kernel_rfl PRE_plx0_entry.freshRoots : noBigRootsB 25619 131072 PRE_plx0_entry.s0.trace PRE_plx0_entry.s0 = true
kernel_rfl PRE_plx0_entry.nativeFresh : bigsOutB 25619 131072 (Host.Load.Layers.toLoad PRE_plx0_entry.s0.ffi).mlx = true
theorem PRE_plx0_entry.noBigFresh : NoBigSt (fun i => (25619 : Int) ≤ i ∧ i < 131072) PRE_plx0_entry.s0.trace PRE_plx0_entry.s0 :=
  NoBigSt.of_checks (fun a ha => PRE_plx0_entry.allPresent PRE_plx0_entry.FB.all PRE_plx0_entry.freshFramed a ha) PRE_plx0_entry.freshRoots

noncomputable def PRE_plx0_entry.jsAt (a : Nat) : Bool := noBigAtP (jsAboveB 2974263) PRE_plx0_entry.s0 a
tpl_all_blocks PRE_plx0_entry.JH from PL0EV : PRE_plx0_entry.jsAt
kernel_rfl PRE_plx0_entry.jsFramed : PL0EV.frames.all PRE_plx0_entry.jsAt = true
kernel_rfl PRE_plx0_entry.jsRoots : noBigRootsP (jsAboveB 2974263) PRE_plx0_entry.s0.trace PRE_plx0_entry.s0 = true
kernel_rfl PRE_plx0_entry.jsNative : bigsOutB jsLoN jsHiN (Host.Load.Layers.toLoad PRE_plx0_entry.s0.ffi).mlx = true
theorem PRE_plx0_entry.jsHeap : JsHeapAbove 2974263 PRE_plx0_entry.s0 := by
  intro a o ho
  have hc := PRE_plx0_entry.allPresent PRE_plx0_entry.JH.all PRE_plx0_entry.jsFramed a (Present.of_get ho)
  unfold PRE_plx0_entry.jsAt noBigAtP at hc
  rw [ho] at hc
  exact noBigHobjP_sound (fun _ hi => hi) hc

end Host.Load.Run.Tpl
