import host.sim.compose.a4b.PF4L9EClosed
import host.sim.BigFree
import host.sim.native.RebigR
import host.sim.compose.JsAbove
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PRE_pf_x4_L9.hnext : (Host.Load.Layers.toLoad PRE_pf_x4_L9.s0.ffi).mlx.next = 22174
noncomputable def PRE_pf_x4_L9.freshAt (a : Nat) : Bool := noBigAtB 22174 131072 PRE_pf_x4_L9.s0 a
tpl_all_blocks PRE_pf_x4_L9.FB from PF4L9EV : PRE_pf_x4_L9.freshAt
kernel_rfl PRE_pf_x4_L9.freshFramed : PF4L9EV.frames.all PRE_pf_x4_L9.freshAt = true
kernel_rfl PRE_pf_x4_L9.freshRoots : noBigRootsB 22174 131072 PRE_pf_x4_L9.s0.trace PRE_pf_x4_L9.s0 = true
kernel_rfl PRE_pf_x4_L9.nativeFresh : bigsOutB 22174 131072 (Host.Load.Layers.toLoad PRE_pf_x4_L9.s0.ffi).mlx = true
theorem PRE_pf_x4_L9.noBigFresh : NoBigSt (fun i => (22174 : Int) ≤ i ∧ i < 131072) PRE_pf_x4_L9.s0.trace PRE_pf_x4_L9.s0 :=
  NoBigSt.of_checks (fun a ha => PRE_pf_x4_L9.allPresent PRE_pf_x4_L9.FB.all PRE_pf_x4_L9.freshFramed a ha) PRE_pf_x4_L9.freshRoots

noncomputable def PRE_pf_x4_L9.jsAt (a : Nat) : Bool := noBigAtP (jsAboveB 2834721) PRE_pf_x4_L9.s0 a
tpl_all_blocks PRE_pf_x4_L9.JH from PF4L9EV : PRE_pf_x4_L9.jsAt
kernel_rfl PRE_pf_x4_L9.jsFramed : PF4L9EV.frames.all PRE_pf_x4_L9.jsAt = true
kernel_rfl PRE_pf_x4_L9.jsRoots : noBigRootsP (jsAboveB 2834721) PRE_pf_x4_L9.s0.trace PRE_pf_x4_L9.s0 = true
kernel_rfl PRE_pf_x4_L9.jsNative : bigsOutB jsLoN jsHiN (Host.Load.Layers.toLoad PRE_pf_x4_L9.s0.ffi).mlx = true
theorem PRE_pf_x4_L9.jsHeap : JsHeapAbove 2834721 PRE_pf_x4_L9.s0 := by
  intro a o ho
  have hc := PRE_pf_x4_L9.allPresent PRE_pf_x4_L9.JH.all PRE_pf_x4_L9.jsFramed a (Present.of_get ho)
  unfold PRE_pf_x4_L9.jsAt noBigAtP at hc
  rw [ho] at hc
  exact noBigHobjP_sound (fun _ hi => hi) hc

end Host.Load.Run.Tpl
