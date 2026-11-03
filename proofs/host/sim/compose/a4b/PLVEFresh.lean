import host.sim.compose.a4b.PLVEClosed
import host.sim.BigFree
import host.sim.native.RebigR
import host.sim.compose.JsAbove
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PRE_plvw_entry.hnext : (Host.Load.Layers.toLoad PRE_plvw_entry.s0.ffi).mlx.next = 25650
noncomputable def PRE_plvw_entry.freshAt (a : Nat) : Bool := noBigAtB 25650 131072 PRE_plvw_entry.s0 a
tpl_all_blocks PRE_plvw_entry.FB from PLVEV : PRE_plvw_entry.freshAt
kernel_rfl PRE_plvw_entry.freshFramed : PLVEV.frames.all PRE_plvw_entry.freshAt = true
kernel_rfl PRE_plvw_entry.freshRoots : noBigRootsB 25650 131072 PRE_plvw_entry.s0.trace PRE_plvw_entry.s0 = true
kernel_rfl PRE_plvw_entry.nativeFresh : bigsOutB 25650 131072 (Host.Load.Layers.toLoad PRE_plvw_entry.s0.ffi).mlx = true
theorem PRE_plvw_entry.noBigFresh : NoBigSt (fun i => (25650 : Int) ≤ i ∧ i < 131072) PRE_plvw_entry.s0.trace PRE_plvw_entry.s0 :=
  NoBigSt.of_checks (fun a ha => PRE_plvw_entry.allPresent PRE_plvw_entry.FB.all PRE_plvw_entry.freshFramed a ha) PRE_plvw_entry.freshRoots

noncomputable def PRE_plvw_entry.jsAt (a : Nat) : Bool := noBigAtP (jsAboveB 2972768) PRE_plvw_entry.s0 a
tpl_all_blocks PRE_plvw_entry.JH from PLVEV : PRE_plvw_entry.jsAt
kernel_rfl PRE_plvw_entry.jsFramed : PLVEV.frames.all PRE_plvw_entry.jsAt = true
kernel_rfl PRE_plvw_entry.jsRoots : noBigRootsP (jsAboveB 2972768) PRE_plvw_entry.s0.trace PRE_plvw_entry.s0 = true
kernel_rfl PRE_plvw_entry.jsNative : bigsOutB jsLoN jsHiN (Host.Load.Layers.toLoad PRE_plvw_entry.s0.ffi).mlx = true
theorem PRE_plvw_entry.jsHeap : JsHeapAbove 2972768 PRE_plvw_entry.s0 := by
  intro a o ho
  have hc := PRE_plvw_entry.allPresent PRE_plvw_entry.JH.all PRE_plvw_entry.jsFramed a (Present.of_get ho)
  unfold PRE_plvw_entry.jsAt noBigAtP at hc
  rw [ho] at hc
  exact noBigHobjP_sound (fun _ hi => hi) hc

end Host.Load.Run.Tpl
