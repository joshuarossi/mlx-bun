import host.sim.compose.a4b.PLT4L7
import host.sim.compose.PostLinkT
import host.sim.compose.a4b.PinVals
import host.sim.conv.Fresh
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl Host.Ts.Sim.Compose.Pf

/-! # x4 L7's sampled cut at the shared tail

The link renames the class's nodes above `NB` (`PfFactsT`). The class runs one prompt length, so every tail variable it doesn't
carry takes its literal there; the hand-off reads the entry's trace id and payload and the trace counter's sum. -/

noncomputable abbrev keys4L7 : List Nat := (PLTW4L7.R.theta ++ PLT4L7.thetaX).map Prod.fst

kernel_rfl t4L7Kept : ((List.range 9) ++ [9, 10, 11, 16]).all (fun j => decide (PLT4L7.θ j = SymE.var j)) = true
kernel_rfl t4L7Small : (keys4L7.all fun j => [200].contains j || imgSmall [1, 2, 3, 5, 6, 7, 8, 9, 1536] (PLT4L7.θ j)) = true
kernel_rfl t4L7Dims : dimsLitB PLT4L7.θ = true
kernel_rfl t4L7i20 : litAt PLT4L7.θ 20 8 = true
kernel_rfl t4L7i22 : PLT4L7.θ 22 = .var 22
kernel_rfl t4L7i23 : litAt PLT4L7.θ 23 7 = true
kernel_rfl t4L7i24 : PLT4L7.θ 24 = .var 24
kernel_rfl t4L7i25 : litAt PLT4L7.θ 25 7 = true
kernel_rfl t4L7i26 : litAt PLT4L7.θ 26 6 = true
kernel_rfl t4L7i200 : PLT4L7.θ 200 = .bin .add (.var 21) (.lit (F64.ofNat 1))
kernel_rfl t4L7i259 : litAt PLT4L7.θ 259 6 = true
kernel_rfl t4L7i260 : litAt PLT4L7.θ 260 7 = true
kernel_rfl t4L7A : PLTW4L7.R.data.a 2590 = 2590
kernel_rfl t4L7B : PLTW4L7.R.data.a 2586 = 2586
kernel_rfl t4L7C : PLTW4L7.R.data.a 2589 = 2589
kernel_rfl t4L7E : PLTW4L7.R.data.a 12504 = 12504
kernel_rfl t4L7H : Nat.ble ((mlxOf PRE_plx4_L7_common.s1.ffi).next + 4096) ((mlxOf PRE_pl_tail.s0.ffi).next + 65536) = true
kernel_rfl t4L7N : Nat.ble ((mlxOf PRE_plx4_L7_common.s1.ffi).nnext + 4096) ((mlxOf PRE_pl_tail.s0.ffi).nnext + 65536) = true
kernel_rfl t4L7Grow : Nat.ble PRE_pl_tail.s0.next PRE_plx4_L7_common.s1.next = true
kernel_rfl t4L7Diff : PRE_plx4_L7_common.s1.next - PRE_pl_tail.s0.next = 156211

theorem t4L7_kept {j : Nat} (h : j ∈ (List.range 9) ++ [9, 10, 11, 16]) : PLT4L7.θ j = .var j :=
  of_decide_eq_true (List.all_eq_true.mp t4L7Kept j h)

/-- The hand-off's values at the length 7. -/
theorem hand4L7 {v k : Nat} (h : handVal 7 v = some k) : (v, k) ∈ [(20, 8), (22, 5), (23, 7), (24, 5), (25, 7), (26, 6), (200, 7), (259, 6), (260, 7)] := by
  have hb : Nat.ble 7 2 = false := rfl
  unfold handVal at h
  rw [hb] at h
  simp only [Bool.cond_false] at h
  split at h <;> first | (cases h; simp) | cases h

/-- **x4 L7's link to the shared tail.** -/
theorem hlink4L7 {T cap capT nI nIT : Nat} {tk : Nat → Nat} {π : List Nat} {Mem Mem' : SegInst FF → Prop}
    (hcap : cap + 156211 ≤ capT) (hbound : capT < Sim.bound) (hL : π.length = 7)
    (hs : ∀ x : SegInst FF, Mem x → PinVals 6 5 5 6 x.ν)
    (hook : ∀ x y : SegInst FF, y.t = x.t → y.C = x.C → (∀ c, y.M.node c = x.M.node (PLTW4L7.R.data.nodeF c)) →
      y.M.a 12504 = x.M.a 12504 → Mem x → Mem' y) :
    CutConv (withMem Mem (indexedCut0 [2834123] 15235 T tk cap nI π PRE_plx4_L7_common.s1 PRE_plx4_L7_common.S1))
      (withMem Mem' (indexedCut 15235 T tk capT nIT π PRE_pl_tail.s0 PRE_pl_tail.S0)) :=
  toTailT PLT4L7.facts (fun b hb => by obtain rfl := List.mem_singleton.mp hb; rfl)
    (Nat.le_of_ble_eq_true t4L7H) (Nat.le_of_ble_eq_true t4L7N) (Nat.le_of_ble_eq_true t4L7Grow)
    (by rw [t4L7Diff]; omega) hbound
    (t4L7_kept (by decide)) (t4L7_kept (by decide)) (t4L7_kept (by decide)) (t4L7_kept (by decide))
    (fun j hj => t4L7_kept (List.mem_append_left _ (List.mem_range.mpr hj)))
    (fun x hm hv => valOf (cand := [1, 2, 3, 5, 6, 7, 8, 9, 1536]) (off := [200]) hv (fun _ hj => thetaOf_off hj) t4L7Small (by
      intro j hj
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
      subst hj
      refine ⟨7, by decide, ?_⟩
      rw [t4L7i200]
      change F64.bin .add (x.ν 21) (F64.ofNat 1) = _
      rw [(hs x hm).v21]
      exact bin_add_ofNat 6 1 (by omega)))
    (fun _ _ => dimsLit t4L7Dims _)
    (fun x hm => hL ▸ handPin (fun _ _ h => hand4L7 h) t4L7i20 t4L7i22 t4L7i23 t4L7i24 t4L7i25 t4L7i26 t4L7i200 t4L7i259 t4L7i260
      rfl (by decide) (hs x hm))
    t4L7A t4L7B t4L7C t4L7E hook

end Host.Ts.Sim.Compose.Post
