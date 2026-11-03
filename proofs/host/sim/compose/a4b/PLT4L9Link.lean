import host.sim.compose.a4b.PLT4L9
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

/-! # x4 L9's sampled cut at the shared tail

The link renames the class's nodes above `NB` (`PfFactsT`). The class runs one prompt length, so the tail's dimensions and its
computed hand-off values are literals; the trace ids and payloads are the entry's, the offsets the entry's `v28`. -/

noncomputable abbrev keys4L9 : List Nat := (PLTW4L9.R.theta ++ PLT4L9.thetaX).map Prod.fst

kernel_rfl t4L9Kept : ((List.range 9) ++ [9, 10, 11, 16]).all (fun j => decide (PLT4L9.θ j = SymE.var j)) = true
kernel_rfl t4L9Small : (keys4L9.all fun j => [200, 259, 260].contains j || imgSmall [1, 2, 3, 5, 6, 7, 8, 9, 1536] (PLT4L9.θ j)) = true
kernel_rfl t4L9Dims : dimsLitB PLT4L9.θ = true
kernel_rfl t4L9i20 : litAt PLT4L9.θ 20 8 = true
kernel_rfl t4L9i22 : PLT4L9.θ 22 = .var 22
kernel_rfl t4L9i23 : litAt PLT4L9.θ 23 7 = true
kernel_rfl t4L9i24 : PLT4L9.θ 24 = .var 24
kernel_rfl t4L9i25 : litAt PLT4L9.θ 25 7 = true
kernel_rfl t4L9i26 : litAt PLT4L9.θ 26 8 = true
kernel_rfl t4L9i200 : PLT4L9.θ 200 = .bin .add (.var 21) (.lit (F64.ofNat 1))
kernel_rfl t4L9i259 : PLT4L9.θ 259 = .un .int32 (.var 28)
kernel_rfl t4L9i260 : PLT4L9.θ 260 = .un .int32 (.bin .add (.var 28) (.lit (F64.ofNat 1)))
kernel_rfl t4L9A : PLTW4L9.R.data.a 2590 = 2590
kernel_rfl t4L9B : PLTW4L9.R.data.a 2586 = 2586
kernel_rfl t4L9C : PLTW4L9.R.data.a 2589 = 2589
kernel_rfl t4L9E : PLTW4L9.R.data.a 12504 = 12504
kernel_rfl t4L9H : Nat.ble ((mlxOf PRE_plx4_L9_common.s1.ffi).next + 4096) ((mlxOf PRE_pl_tail.s0.ffi).next + 65536) = true
kernel_rfl t4L9N : Nat.ble ((mlxOf PRE_plx4_L9_common.s1.ffi).nnext + 4096) ((mlxOf PRE_pl_tail.s0.ffi).nnext + 65536) = true
kernel_rfl t4L9Grow : Nat.ble PRE_pl_tail.s0.next PRE_plx4_L9_common.s1.next = true
kernel_rfl t4L9Diff : PRE_plx4_L9_common.s1.next - PRE_pl_tail.s0.next = 156819

theorem t4L9_kept {j : Nat} (h : j ∈ (List.range 9) ++ [9, 10, 11, 16]) : PLT4L9.θ j = .var j :=
  of_decide_eq_true (List.all_eq_true.mp t4L9Kept j h)

/-- The hand-off's values at the length 9. -/
theorem hand4L9 {v k : Nat} (h : handVal 9 v = some k) : (v, k) ∈ [(20, 8), (22, 5), (23, 7), (24, 5), (25, 7), (26, 8), (200, 7), (259, 8), (260, 9)] := by
  have hb : Nat.ble 9 2 = false := rfl
  unfold handVal at h
  rw [hb] at h
  simp only [Bool.cond_false] at h
  split at h <;> first | (cases h; simp) | cases h

/-- **x4 L9's link to the shared tail.** -/
theorem hlink4L9 {T cap capT nI nIT : Nat} {tk : Nat → Nat} {π : List Nat} {Mem Mem' : SegInst FF → Prop}
    (hcap : cap + 156819 ≤ capT) (hbound : capT < Sim.bound) (hL : π.length = 9)
    (hs : ∀ x : SegInst FF, Mem x → PinVals 6 5 5 (π.length - 1) x.ν)
    (hook : ∀ x y : SegInst FF, y.t = x.t → y.C = x.C → (∀ c, y.M.node c = x.M.node (PLTW4L9.R.data.nodeF c)) →
      y.M.a 12504 = x.M.a 12504 → Mem x → Mem' y) :
    CutConv (withMem Mem (indexedCut0 [2834731] 15235 T tk cap nI π PRE_plx4_L9_common.s1 PRE_plx4_L9_common.S1))
      (withMem Mem' (indexedCut 15235 T tk capT nIT π PRE_pl_tail.s0 PRE_pl_tail.S0)) :=
  toTailT PLT4L9.facts (fun b hb => by obtain rfl := List.mem_singleton.mp hb; rfl)
    (Nat.le_of_ble_eq_true t4L9H) (Nat.le_of_ble_eq_true t4L9N) (Nat.le_of_ble_eq_true t4L9Grow)
    (by rw [t4L9Diff]; omega) hbound
    (t4L9_kept (by decide)) (t4L9_kept (by decide)) (t4L9_kept (by decide)) (t4L9_kept (by decide))
    (fun j hj => t4L9_kept (List.mem_append_left _ (List.mem_range.mpr hj)))
    (fun x hm hv => valOf (cand := [1, 2, 3, 5, 6, 7, 8, 9, 1536]) (off := [200, 259, 260]) hv (fun _ hj => thetaOf_off hj) t4L9Small (by
      have h28 : x.ν 28 = F64.ofNat 8 := (hs x hm).v28.trans (congrArg F64.ofNat (by omega))
      intro j hj
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
      rcases hj with rfl | rfl | rfl
      · refine ⟨7, by decide, ?_⟩
        rw [t4L9i200]
        change F64.bin .add (x.ν 21) (F64.ofNat 1) = _
        rw [(hs x hm).v21]
        exact bin_add_ofNat 6 1 (by omega)
      · refine ⟨8, by decide, ?_⟩
        rw [t4L9i259]
        exact eval_int32 h28 (by decide)
      · refine ⟨9, by decide, ?_⟩
        rw [t4L9i260]
        refine eval_int32 ?_ (by decide)
        change F64.bin .add (x.ν 28) (F64.ofNat 1) = _
        rw [h28]
        exact bin_add_ofNat 8 1 (by omega)))
    (fun _ _ => dimsLit t4L9Dims _)
    (fun x hm => handPin (fun _ _ h => hand4L9 (hL ▸ h)) t4L9i20 t4L9i22 t4L9i23 t4L9i24 t4L9i25 t4L9i26 t4L9i200 t4L9i259 t4L9i260
      rfl (by omega) (by omega) (by decide) (by decide) (hs x hm))
    t4L9A t4L9B t4L9C t4L9E hook

end Host.Ts.Sim.Compose.Post
