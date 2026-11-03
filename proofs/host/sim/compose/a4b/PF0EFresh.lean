import host.sim.compose.a4b.PF0EClosed
import host.sim.BigFree
import host.sim.native.RebigR
import host.sim.compose.JsAbove
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PRE_pf_x0.hnext : (Host.Load.Layers.toLoad PRE_pf_x0.s0.ffi).mlx.next = 21986
noncomputable def PRE_pf_x0.freshAt (a : Nat) : Bool := noBigAtB 21986 131072 PRE_pf_x0.s0 a
tpl_all_blocks PRE_pf_x0.FB from PF0EV : PRE_pf_x0.freshAt
kernel_rfl PRE_pf_x0.freshFramed : PF0EV.frames.all PRE_pf_x0.freshAt = true
kernel_rfl PRE_pf_x0.freshRoots : noBigRootsB 21986 131072 PRE_pf_x0.s0.trace PRE_pf_x0.s0 = true
kernel_rfl PRE_pf_x0.nativeFresh : bigsOutB 21986 131072 (Host.Load.Layers.toLoad PRE_pf_x0.s0.ffi).mlx = true
theorem PRE_pf_x0.noBigFresh : NoBigSt (fun i => (21986 : Int) ≤ i ∧ i < 131072) PRE_pf_x0.s0.trace PRE_pf_x0.s0 :=
  NoBigSt.of_checks (fun a ha => PRE_pf_x0.allPresent PRE_pf_x0.FB.all PRE_pf_x0.freshFramed a ha) PRE_pf_x0.freshRoots

noncomputable def PRE_pf_x0.jsAt (a : Nat) : Bool := noBigAtP (jsAboveB 2826767) PRE_pf_x0.s0 a
tpl_all_blocks PRE_pf_x0.JH from PF0EV : PRE_pf_x0.jsAt
kernel_rfl PRE_pf_x0.jsFramed : PF0EV.frames.all PRE_pf_x0.jsAt = true
kernel_rfl PRE_pf_x0.jsRoots : noBigRootsP (jsAboveB 2826767) PRE_pf_x0.s0.trace PRE_pf_x0.s0 = true
kernel_rfl PRE_pf_x0.jsNative : bigsOutB jsLoN jsHiN (Host.Load.Layers.toLoad PRE_pf_x0.s0.ffi).mlx = true
theorem PRE_pf_x0.jsHeap : JsHeapAbove 2826767 PRE_pf_x0.s0 := by
  intro a o ho
  have hc := PRE_pf_x0.allPresent PRE_pf_x0.JH.all PRE_pf_x0.jsFramed a (Present.of_get ho)
  unfold PRE_pf_x0.jsAt noBigAtP at hc
  rw [ho] at hc
  exact noBigHobjP_sound (fun _ hi => hi) hc

end Host.Load.Run.Tpl
