import host.sim.compose.a4b.PF15EClosed
import host.sim.BigFree
import host.sim.native.RebigR
import host.sim.compose.JsAbove
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PRE_pf_vw.hnext : (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx.next = 21966
noncomputable def PRE_pf_vw.freshAt (a : Nat) : Bool := noBigAtB 21966 131072 PRE_pf_vw.s0 a
tpl_all_blocks PRE_pf_vw.FB from PF15EV : PRE_pf_vw.freshAt
kernel_rfl PRE_pf_vw.freshFramed : PRE_pf_vw.frames.all PRE_pf_vw.freshAt = true
kernel_rfl PRE_pf_vw.freshRoots : noBigRootsB 21966 131072 PRE_pf_vw.s0.trace PRE_pf_vw.s0 = true
kernel_rfl PRE_pf_vw.nativeFresh : bigsOutB 21966 131072 (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx = true
theorem PRE_pf_vw.noBigFresh : NoBigSt (fun i => (21966 : Int) ≤ i ∧ i < 131072) PRE_pf_vw.s0.trace PRE_pf_vw.s0 :=
  NoBigSt.of_checks (fun a ha => PRE_pf_vw.allPresent PRE_pf_vw.FB.all PRE_pf_vw.freshFramed a ha) PRE_pf_vw.freshRoots

noncomputable def PRE_pf_vw.jsAt (a : Nat) : Bool := noBigAtP (jsAboveB 2825043) PRE_pf_vw.s0 a
tpl_all_blocks PRE_pf_vw.JH from PF15EV : PRE_pf_vw.jsAt
kernel_rfl PRE_pf_vw.jsFramed : PRE_pf_vw.frames.all PRE_pf_vw.jsAt = true
kernel_rfl PRE_pf_vw.jsRoots : noBigRootsP (jsAboveB 2825043) PRE_pf_vw.s0.trace PRE_pf_vw.s0 = true
kernel_rfl PRE_pf_vw.jsNative : bigsOutB jsLoN jsHiN (Host.Load.Layers.toLoad PRE_pf_vw.s0.ffi).mlx = true
theorem PRE_pf_vw.jsHeap : JsHeapAbove 2825043 PRE_pf_vw.s0 := by
  intro a o ho
  have hc := PRE_pf_vw.allPresent PRE_pf_vw.JH.all PRE_pf_vw.jsFramed a (Present.of_get ho)
  unfold PRE_pf_vw.jsAt noBigAtP at hc
  rw [ho] at hc
  exact noBigHobjP_sound (fun _ hi => hi) hc

end Host.Load.Run.Tpl
