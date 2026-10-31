import host.sim.compose.a4b.PLEntryClosed
import host.sim.BigFree
import host.sim.native.RebigR
import host.sim.compose.JsAbove
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PRE_pl_entry.hnext : (Host.Load.Layers.toLoad PRE_pl_entry.s0.ffi).mlx.next = 21986
noncomputable def PRE_pl_entry.freshAt (a : Nat) : Bool := noBigAtB 21986 131072 PRE_pl_entry.s0 a
tpl_all_blocks PRE_pl_entry.FB from PRE_pl_entry : PRE_pl_entry.freshAt
kernel_rfl PRE_pl_entry.freshFramed : PRE_pl_entry.frames.all PRE_pl_entry.freshAt = true
kernel_rfl PRE_pl_entry.freshRoots : noBigRootsB 21986 131072 PRE_pl_entry.s0.trace PRE_pl_entry.s0 = true
kernel_rfl PRE_pl_entry.nativeFresh : bigsOutB 21986 131072 (Host.Load.Layers.toLoad PRE_pl_entry.s0.ffi).mlx = true
theorem PRE_pl_entry.noBigFresh : NoBigSt (fun i => (21986 : Int) ≤ i ∧ i < 131072) PRE_pl_entry.s0.trace PRE_pl_entry.s0 :=
  NoBigSt.of_checks (fun a ha => PRE_pl_entry.allPresent PRE_pl_entry.FB.all PRE_pl_entry.freshFramed a ha) PRE_pl_entry.freshRoots

noncomputable def PRE_pl_entry.jsAt (a : Nat) : Bool := noBigAtP (jsAboveB 2826779) PRE_pl_entry.s0 a
tpl_all_blocks PRE_pl_entry.JH from PRE_pl_entry : PRE_pl_entry.jsAt
kernel_rfl PRE_pl_entry.jsFramed : PRE_pl_entry.frames.all PRE_pl_entry.jsAt = true
kernel_rfl PRE_pl_entry.jsRoots : noBigRootsP (jsAboveB 2826779) PRE_pl_entry.s0.trace PRE_pl_entry.s0 = true
kernel_rfl PRE_pl_entry.jsNative : bigsOutB jsLoN jsHiN (Host.Load.Layers.toLoad PRE_pl_entry.s0.ffi).mlx = true
theorem PRE_pl_entry.jsHeap : JsHeapAbove 2826779 PRE_pl_entry.s0 := by
  intro a o ho
  have hc := PRE_pl_entry.allPresent PRE_pl_entry.JH.all PRE_pl_entry.jsFramed a (Present.of_get ho)
  unfold PRE_pl_entry.jsAt noBigAtP at hc
  rw [ho] at hc
  exact noBigHobjP_sound (fun _ hi => hi) hc

end Host.Load.Run.Tpl
