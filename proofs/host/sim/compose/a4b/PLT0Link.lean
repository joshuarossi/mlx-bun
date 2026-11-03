import host.sim.compose.a4b.PLT0
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

/-! # x0's sampled cut at the shared tail

The link renames the class's nodes above `NB` (`PfFactsT`). The class runs one prompt length, so every tail variable it doesn't
carry takes its literal there; the hand-off reads the entry's trace id and payload and the trace counter's sum. -/

noncomputable abbrev keys0 : List Nat := (PLTW0.R.theta ++ PLT0.thetaX).map Prod.fst

kernel_rfl t0Kept : ((List.range 9) ++ [9, 10, 11, 16]).all (fun j => decide (PLT0.θ j = SymE.var j)) = true
kernel_rfl t0Small : (keys0.all fun j => [200].contains j || imgSmall [1, 2, 3, 5, 6, 7, 8, 9, 1536] (PLT0.θ j)) = true
kernel_rfl t0Dims : dimsLitB PLT0.θ = true
kernel_rfl t0i20 : litAt PLT0.θ 20 6 = true
kernel_rfl t0i22 : PLT0.θ 22 = .var 22
kernel_rfl t0i23 : litAt PLT0.θ 23 5 = true
kernel_rfl t0i24 : PLT0.θ 24 = .var 24
kernel_rfl t0i25 : litAt PLT0.θ 25 5 = true
kernel_rfl t0i26 : litAt PLT0.θ 26 1 = true
kernel_rfl t0i200 : PLT0.θ 200 = .bin .add (.var 21) (.lit (F64.ofNat 1))
kernel_rfl t0i259 : litAt PLT0.θ 259 1 = true
kernel_rfl t0i260 : litAt PLT0.θ 260 2 = true
kernel_rfl t0A : PLTW0.R.data.a 2590 = 2590
kernel_rfl t0B : PLTW0.R.data.a 2586 = 2586
kernel_rfl t0C : PLTW0.R.data.a 2589 = 2589
kernel_rfl t0E : PLTW0.R.data.a 12504 = 12504
kernel_rfl t0H : Nat.ble ((mlxOf PRE_plx0_common.s1.ffi).next + 4096) ((mlxOf PRE_pl_tail.s0.ffi).next + 65536) = true
kernel_rfl t0N : Nat.ble ((mlxOf PRE_plx0_common.s1.ffi).nnext + 4096) ((mlxOf PRE_pl_tail.s0.ffi).nnext + 65536) = true
kernel_rfl t0Grow : Nat.ble PRE_pl_tail.s0.next PRE_plx0_common.s1.next = true
kernel_rfl t0Diff : PRE_plx0_common.s1.next - PRE_pl_tail.s0.next = 147484

theorem t0_kept {j : Nat} (h : j ∈ (List.range 9) ++ [9, 10, 11, 16]) : PLT0.θ j = .var j :=
  of_decide_eq_true (List.all_eq_true.mp t0Kept j h)

/-- The hand-off's values at the length 2. -/
theorem hand0 {v k : Nat} (h : handVal 2 v = some k) : (v, k) ∈ [(20, 6), (22, 4), (23, 5), (24, 4), (25, 5), (26, 1), (200, 5), (259, 1), (260, 2)] := by
  have hb : Nat.ble 2 2 = true := rfl
  unfold handVal at h
  rw [hb] at h
  simp only [Bool.cond_true] at h
  split at h <;> first | (cases h; simp) | cases h

/-- **x0's link to the shared tail.** -/
theorem hlink0 {T cap capT nI nIT : Nat} {tk : Nat → Nat} {π : List Nat} {Mem Mem' : SegInst FF → Prop}
    (hcap : cap + 147484 ≤ capT) (hbound : capT < Sim.bound) (hL : π.length = 2)
    (hs : ∀ x : SegInst FF, Mem x → PinVals 4 4 4 1 x.ν)
    (hook : ∀ x y : SegInst FF, y.t = x.t → y.C = x.C → (∀ c, y.M.node c = x.M.node (PLTW0.R.data.nodeF c)) →
      y.M.a 12504 = x.M.a 12504 → Mem x → Mem' y) :
    CutConv (withMem Mem (indexedCut0 [2826777] 15235 T tk cap nI π PRE_plx0_common.s1 PRE_plx0_common.S1))
      (withMem Mem' (indexedCut 15235 T tk capT nIT π PRE_pl_tail.s0 PRE_pl_tail.S0)) :=
  toTailT PLT0.facts (fun b hb => by obtain rfl := List.mem_singleton.mp hb; rfl)
    (Nat.le_of_ble_eq_true t0H) (Nat.le_of_ble_eq_true t0N) (Nat.le_of_ble_eq_true t0Grow)
    (by rw [t0Diff]; omega) hbound
    (t0_kept (by decide)) (t0_kept (by decide)) (t0_kept (by decide)) (t0_kept (by decide))
    (fun j hj => t0_kept (List.mem_append_left _ (List.mem_range.mpr hj)))
    (fun x hm hv => valOf (cand := [1, 2, 3, 5, 6, 7, 8, 9, 1536]) (off := [200]) hv (fun _ hj => thetaOf_off hj) t0Small (by
      intro j hj
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
      subst hj
      refine ⟨5, by decide, ?_⟩
      rw [t0i200]
      change F64.bin .add (x.ν 21) (F64.ofNat 1) = _
      rw [(hs x hm).v21]
      exact bin_add_ofNat 4 1 (by omega)))
    (fun _ _ => dimsLit t0Dims _)
    (fun x hm => hL ▸ handPin (fun _ _ h => hand0 h) t0i20 t0i22 t0i23 t0i24 t0i25 t0i26 t0i200 t0i259 t0i260
      rfl (by decide) (hs x hm))
    t0A t0B t0C t0E hook

end Host.Ts.Sim.Compose.Post
