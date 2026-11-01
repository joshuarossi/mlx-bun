import host.sim.compose.a4b.PLTEClosed
import host.sim.BigFree
import host.sim.native.RebigR
import host.sim.compose.JsAbove
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PRE_pl_tail.hnext : (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx.next = 22018
noncomputable def PRE_pl_tail.freshAt (a : Nat) : Bool := noBigAtB 22018 131072 PRE_pl_tail.s0 a
tpl_all_blocks PRE_pl_tail.FB from PLTEV : PRE_pl_tail.freshAt
kernel_rfl PRE_pl_tail.freshFramed : PRE_pl_tail.frames.all PRE_pl_tail.freshAt = true
kernel_rfl PRE_pl_tail.freshRoots : noBigRootsB 22018 131072 PRE_pl_tail.s0.trace PRE_pl_tail.s0 = true
kernel_rfl PRE_pl_tail.nativeFresh : bigsOutB 22018 131072 (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx = true
theorem PRE_pl_tail.noBigFresh : NoBigSt (fun i => (22018 : Int) ≤ i ∧ i < 131072) PRE_pl_tail.s0.trace PRE_pl_tail.s0 :=
  NoBigSt.of_checks (fun a ha => PRE_pl_tail.allPresent PRE_pl_tail.FB.all PRE_pl_tail.freshFramed a ha) PRE_pl_tail.freshRoots

noncomputable def PRE_pl_tail.jsAt (a : Nat) : Bool := noBigAtP (jsAboveB 2827718) PRE_pl_tail.s0 a
tpl_all_blocks PRE_pl_tail.JH from PLTEV : PRE_pl_tail.jsAt
kernel_rfl PRE_pl_tail.jsFramed : PRE_pl_tail.frames.all PRE_pl_tail.jsAt = true
kernel_rfl PRE_pl_tail.jsRoots : noBigRootsP (jsAboveB 2827718) PRE_pl_tail.s0.trace PRE_pl_tail.s0 = true
kernel_rfl PRE_pl_tail.jsNative : bigsOutB jsLoN jsHiN (Host.Load.Layers.toLoad PRE_pl_tail.s0.ffi).mlx = true
theorem PRE_pl_tail.jsHeap : JsHeapAbove 2827718 PRE_pl_tail.s0 := by
  intro a o ho
  have hc := PRE_pl_tail.allPresent PRE_pl_tail.JH.all PRE_pl_tail.jsFramed a (Present.of_get ho)
  unfold PRE_pl_tail.jsAt noBigAtP at hc
  rw [ho] at hc
  exact noBigHobjP_sound (fun _ hi => hi) hc

end Host.Load.Run.Tpl
