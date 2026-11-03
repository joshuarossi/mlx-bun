import host.sim.compose.a4b.PLT4L8
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

/-! # x4 L8's sampled cut at the shared tail

The link renames the class's nodes above `NB` (`PfFactsT`). The class runs one prompt length, so every tail variable it doesn't
carry takes its literal there; the hand-off reads the entry's trace id and payload and the trace counter's sum. -/

noncomputable abbrev keys4L8 : List Nat := (PLTW4L8.R.theta ++ PLT4L8.thetaX).map Prod.fst

kernel_rfl t4L8Kept : ((List.range 9) ++ [9, 10, 11, 16]).all (fun j => decide (PLT4L8.θ j = SymE.var j)) = true
kernel_rfl t4L8Small : (keys4L8.all fun j => [200].contains j || imgSmall [1, 2, 3, 5, 6, 7, 8, 9, 1536] (PLT4L8.θ j)) = true
kernel_rfl t4L8Dims : dimsLitB PLT4L8.θ = true
kernel_rfl t4L8i20 : litAt PLT4L8.θ 20 8 = true
kernel_rfl t4L8i22 : PLT4L8.θ 22 = .var 22
kernel_rfl t4L8i23 : litAt PLT4L8.θ 23 7 = true
kernel_rfl t4L8i24 : PLT4L8.θ 24 = .var 24
kernel_rfl t4L8i25 : litAt PLT4L8.θ 25 7 = true
kernel_rfl t4L8i26 : litAt PLT4L8.θ 26 7 = true
kernel_rfl t4L8i200 : PLT4L8.θ 200 = .bin .add (.var 21) (.lit (F64.ofNat 1))
kernel_rfl t4L8i259 : litAt PLT4L8.θ 259 7 = true
kernel_rfl t4L8i260 : litAt PLT4L8.θ 260 8 = true
kernel_rfl t4L8A : PLTW4L8.R.data.a 2590 = 2590
kernel_rfl t4L8B : PLTW4L8.R.data.a 2586 = 2586
kernel_rfl t4L8C : PLTW4L8.R.data.a 2589 = 2589
kernel_rfl t4L8E : PLTW4L8.R.data.a 12504 = 12504
kernel_rfl t4L8H : Nat.ble ((mlxOf PRE_plx4_L8_common.s1.ffi).next + 4096) ((mlxOf PRE_pl_tail.s0.ffi).next + 65536) = true
kernel_rfl t4L8N : Nat.ble ((mlxOf PRE_plx4_L8_common.s1.ffi).nnext + 4096) ((mlxOf PRE_pl_tail.s0.ffi).nnext + 65536) = true
kernel_rfl t4L8Grow : Nat.ble PRE_pl_tail.s0.next PRE_plx4_L8_common.s1.next = true
kernel_rfl t4L8Diff : PRE_plx4_L8_common.s1.next - PRE_pl_tail.s0.next = 156515

theorem t4L8_kept {j : Nat} (h : j ∈ (List.range 9) ++ [9, 10, 11, 16]) : PLT4L8.θ j = .var j :=
  of_decide_eq_true (List.all_eq_true.mp t4L8Kept j h)

/-- The hand-off's values at the length 8. -/
theorem hand4L8 {v k : Nat} (h : handVal 8 v = some k) : (v, k) ∈ [(20, 8), (22, 5), (23, 7), (24, 5), (25, 7), (26, 7), (200, 7), (259, 7), (260, 8)] := by
  have hb : Nat.ble 8 2 = false := rfl
  unfold handVal at h
  rw [hb] at h
  simp only [Bool.cond_false] at h
  split at h <;> first | (cases h; simp) | cases h

/-- **x4 L8's link to the shared tail.** -/
theorem hlink4L8 {T cap capT nI nIT : Nat} {tk : Nat → Nat} {π : List Nat} {Mem Mem' : SegInst FF → Prop}
    (hcap : cap + 156515 ≤ capT) (hbound : capT < Sim.bound) (hL : π.length = 8)
    (hs : ∀ x : SegInst FF, Mem x → PinVals 6 5 5 7 x.ν)
    (hook : ∀ x y : SegInst FF, y.t = x.t → y.C = x.C → (∀ c, y.M.node c = x.M.node (PLTW4L8.R.data.nodeF c)) →
      y.M.a 12504 = x.M.a 12504 → Mem x → Mem' y) :
    CutConv (withMem Mem (indexedCut0 [2834427] 15235 T tk cap nI π PRE_plx4_L8_common.s1 PRE_plx4_L8_common.S1))
      (withMem Mem' (indexedCut 15235 T tk capT nIT π PRE_pl_tail.s0 PRE_pl_tail.S0)) :=
  toTailT PLT4L8.facts (fun b hb => by obtain rfl := List.mem_singleton.mp hb; rfl)
    (Nat.le_of_ble_eq_true t4L8H) (Nat.le_of_ble_eq_true t4L8N) (Nat.le_of_ble_eq_true t4L8Grow)
    (by rw [t4L8Diff]; omega) hbound
    (t4L8_kept (by decide)) (t4L8_kept (by decide)) (t4L8_kept (by decide)) (t4L8_kept (by decide))
    (fun j hj => t4L8_kept (List.mem_append_left _ (List.mem_range.mpr hj)))
    (fun x hm hv => valOf (cand := [1, 2, 3, 5, 6, 7, 8, 9, 1536]) (off := [200]) hv (fun _ hj => thetaOf_off hj) t4L8Small (by
      intro j hj
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
      subst hj
      refine ⟨7, by decide, ?_⟩
      rw [t4L8i200]
      change F64.bin .add (x.ν 21) (F64.ofNat 1) = _
      rw [(hs x hm).v21]
      exact bin_add_ofNat 6 1 (by omega)))
    (fun _ _ => dimsLit t4L8Dims _)
    (fun x hm => hL ▸ handPin (fun _ _ h => hand4L8 h) t4L8i20 t4L8i22 t4L8i23 t4L8i24 t4L8i25 t4L8i26 t4L8i200 t4L8i259 t4L8i260
      rfl (by decide) (hs x hm))
    t4L8A t4L8B t4L8C t4L8E hook

end Host.Ts.Sim.Compose.Post
