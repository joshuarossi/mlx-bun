import host.sim.compose.a4b.PF4L8EClosed
import host.sim.BigFree
import host.sim.native.RebigR
import host.sim.compose.JsAbove
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PRE_pf_x4_L8.hnext : (Host.Load.Layers.toLoad PRE_pf_x4_L8.s0.ffi).mlx.next = 22174
noncomputable def PRE_pf_x4_L8.freshAt (a : Nat) : Bool := noBigAtB 22174 131072 PRE_pf_x4_L8.s0 a
tpl_all_blocks PRE_pf_x4_L8.FB from PF4L8EV : PRE_pf_x4_L8.freshAt
kernel_rfl PRE_pf_x4_L8.freshFramed : PF4L8EV.frames.all PRE_pf_x4_L8.freshAt = true
kernel_rfl PRE_pf_x4_L8.freshRoots : noBigRootsB 22174 131072 PRE_pf_x4_L8.s0.trace PRE_pf_x4_L8.s0 = true
kernel_rfl PRE_pf_x4_L8.nativeFresh : bigsOutB 22174 131072 (Host.Load.Layers.toLoad PRE_pf_x4_L8.s0.ffi).mlx = true
theorem PRE_pf_x4_L8.noBigFresh : NoBigSt (fun i => (22174 : Int) ≤ i ∧ i < 131072) PRE_pf_x4_L8.s0.trace PRE_pf_x4_L8.s0 :=
  NoBigSt.of_checks (fun a ha => PRE_pf_x4_L8.allPresent PRE_pf_x4_L8.FB.all PRE_pf_x4_L8.freshFramed a ha) PRE_pf_x4_L8.freshRoots

noncomputable def PRE_pf_x4_L8.jsAt (a : Nat) : Bool := noBigAtP (jsAboveB 2834417) PRE_pf_x4_L8.s0 a
tpl_all_blocks PRE_pf_x4_L8.JH from PF4L8EV : PRE_pf_x4_L8.jsAt
kernel_rfl PRE_pf_x4_L8.jsFramed : PF4L8EV.frames.all PRE_pf_x4_L8.jsAt = true
kernel_rfl PRE_pf_x4_L8.jsRoots : noBigRootsP (jsAboveB 2834417) PRE_pf_x4_L8.s0.trace PRE_pf_x4_L8.s0 = true
kernel_rfl PRE_pf_x4_L8.jsNative : bigsOutB jsLoN jsHiN (Host.Load.Layers.toLoad PRE_pf_x4_L8.s0.ffi).mlx = true
theorem PRE_pf_x4_L8.jsHeap : JsHeapAbove 2834417 PRE_pf_x4_L8.s0 := by
  intro a o ho
  have hc := PRE_pf_x4_L8.allPresent PRE_pf_x4_L8.JH.all PRE_pf_x4_L8.jsFramed a (Present.of_get ho)
  unfold PRE_pf_x4_L8.jsAt noBigAtP at hc
  rw [ho] at hc
  exact noBigHobjP_sound (fun _ hi => hi) hc

end Host.Load.Run.Tpl
