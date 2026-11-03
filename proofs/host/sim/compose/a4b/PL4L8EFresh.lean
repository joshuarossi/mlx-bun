import host.sim.compose.a4b.PL4L8EClosed
import host.sim.BigFree
import host.sim.native.RebigR
import host.sim.compose.JsAbove
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PRE_plx4_L8_entry.hnext : (Host.Load.Layers.toLoad PRE_plx4_L8_entry.s0.ffi).mlx.next = 25858
noncomputable def PRE_plx4_L8_entry.freshAt (a : Nat) : Bool := noBigAtB 25858 131072 PRE_plx4_L8_entry.s0 a
tpl_all_blocks PRE_plx4_L8_entry.FB from PL4L8EV : PRE_plx4_L8_entry.freshAt
kernel_rfl PRE_plx4_L8_entry.freshFramed : PL4L8EV.frames.all PRE_plx4_L8_entry.freshAt = true
kernel_rfl PRE_plx4_L8_entry.freshRoots : noBigRootsB 25858 131072 PRE_plx4_L8_entry.s0.trace PRE_plx4_L8_entry.s0 = true
kernel_rfl PRE_plx4_L8_entry.nativeFresh : bigsOutB 25858 131072 (Host.Load.Layers.toLoad PRE_plx4_L8_entry.s0.ffi).mlx = true
theorem PRE_plx4_L8_entry.noBigFresh : NoBigSt (fun i => (25858 : Int) ≤ i ∧ i < 131072) PRE_plx4_L8_entry.s0.trace PRE_plx4_L8_entry.s0 :=
  NoBigSt.of_checks (fun a ha => PRE_plx4_L8_entry.allPresent PRE_plx4_L8_entry.FB.all PRE_plx4_L8_entry.freshFramed a ha) PRE_plx4_L8_entry.freshRoots

noncomputable def PRE_plx4_L8_entry.jsAt (a : Nat) : Bool := noBigAtP (jsAboveB 2983294) PRE_plx4_L8_entry.s0 a
tpl_all_blocks PRE_plx4_L8_entry.JH from PL4L8EV : PRE_plx4_L8_entry.jsAt
kernel_rfl PRE_plx4_L8_entry.jsFramed : PL4L8EV.frames.all PRE_plx4_L8_entry.jsAt = true
kernel_rfl PRE_plx4_L8_entry.jsRoots : noBigRootsP (jsAboveB 2983294) PRE_plx4_L8_entry.s0.trace PRE_plx4_L8_entry.s0 = true
kernel_rfl PRE_plx4_L8_entry.jsNative : bigsOutB jsLoN jsHiN (Host.Load.Layers.toLoad PRE_plx4_L8_entry.s0.ffi).mlx = true
theorem PRE_plx4_L8_entry.jsHeap : JsHeapAbove 2983294 PRE_plx4_L8_entry.s0 := by
  intro a o ho
  have hc := PRE_plx4_L8_entry.allPresent PRE_plx4_L8_entry.JH.all PRE_plx4_L8_entry.jsFramed a (Present.of_get ho)
  unfold PRE_plx4_L8_entry.jsAt noBigAtP at hc
  rw [ho] at hc
  exact noBigHobjP_sound (fun _ hi => hi) hc

end Host.Load.Run.Tpl
