import host.sim.compose.a4b.PLTV
import host.sim.compose.PostLinkT
import host.sim.compose.TailVals
import host.sim.conv.Fresh
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl Host.Ts.Sim.Compose.Pf

/-! # VW's sampled cut at the shared tail

The link renames the class's nodes above `NB` (`PfFactsT`). The tail's convolution and trace dimensions come out as terms in the
class's `v27` (`= L - 1`) that evaluate to the literal for every length, checked once over the lengths; the hand-off's values are the
class's POST variables, which VW's entry sets. -/

/-- An expression reading only `v27` and `v28`. -/
def only2728 : SymE → Bool
  | .lit _ => true
  | .var i => Nat.beq i 27 || Nat.beq i 28
  | .bin _ a b => only2728 a && only2728 b
  | .un _ a => only2728 a

theorem only2728_noVar : ∀ (e : SymE), only2728 e = true → ∀ w, ¬ (w = 27 ∨ w = 28) → e.noVar w = true
  | .lit _, _, _, _ => rfl
  | .var i, h, w, hw => by
    have hi : i = 27 ∨ i = 28 := by
      simp only [only2728, Bool.or_eq_true] at h
      rcases h with h | h
      · exact Or.inl (Nat.eq_of_beq_eq_true h)
      · exact Or.inr (Nat.eq_of_beq_eq_true h)
    have hne : Nat.beq i w = false := by
      cases e : Nat.beq i w with
      | false => rfl
      | true => exact absurd (Nat.eq_of_beq_eq_true e ▸ hi) hw
    show (!(Nat.beq i w)) = true
    rw [hne]; rfl
  | .bin _ a b, h, w, hw => by
    simp only [only2728, Bool.and_eq_true] at h
    simp only [SymE.noVar, Bool.and_eq_true]
    exact ⟨only2728_noVar a h.1 w hw, only2728_noVar b h.2 w hw⟩
  | .un _ a, h, w, hw => by
    simp only [only2728] at h
    simp only [SymE.noVar]
    exact only2728_noVar a h w hw

/-- The valuation the check uses: the offset at `v27` and `v28`. -/
def ν0 (n : Nat) : Nat → F64 := fun j => bif Nat.beq j 27 || Nat.beq j 28 then F64.ofNat n else F64.ofNat 0

theorem eval_ν0 {ν : Nat → F64} {n : Nat} (h27 : ν 27 = F64.ofNat n) (h28 : ν 28 = F64.ofNat n) {e : SymE}
    (he : only2728 e = true) : e.eval ν = e.eval (ν0 n) := by
  refine Conv.SymE.eval_congr (V := fun w => ¬ (w = 27 ∨ w = 28)) (fun v hv => ?_) e (only2728_noVar e he)
  have hv' : v = 27 ∨ v = 28 := by
    by_cases h : v = 27 ∨ v = 28
    · exact h
    · exact absurd h hv
  rcases hv' with rfl | rfl
  · exact h27.trans rfl
  · exact h28.trans rfl

/-- The tail's dimensions at the offset `n`. -/
noncomputable def tailDimsAt (n : Nat) : Bool := (List.range 259).all fun v =>
  match tailVal v with
  | some k => only2728 (PLTV.θ v) && (PLTV.θ v).eval (ν0 n) == F64.ofNat k
  | none => true

kernel_rfl tailDimsAll : (List.range 224).all (fun n => Nat.beq n 0 || tailDimsAt n) = true

theorem dimsVW {L : Nat} {ν : Nat → F64} (h2 : 2 ≤ L) (hL : L ≤ 224) (h : VWVals L ν) :
    tail.dims (Shift.valuation PLTV.θ ν) := by
  intro v k hv
  have hn := List.all_eq_true.mp tailDimsAll (L - 1) (List.mem_range.mpr (by omega))
  have hn' : tailDimsAt (L - 1) = true := by
    have h0 : Nat.beq (L - 1) 0 = false := by
      cases e : Nat.beq (L - 1) 0 with
      | false => rfl
      | true => have := Nat.eq_of_beq_eq_true e; omega
    rw [h0, Bool.false_or] at hn
    exact hn
  have hc := List.all_eq_true.mp hn' v (List.mem_range.mpr (tailVal_lt hv))
  simp only [hv, Bool.and_eq_true, beq_iff_eq] at hc
  change (PLTV.θ v).eval ν = _
  rw [eval_ν0 h.v27 h.v28 hc.1]
  exact hc.2

kernel_rfl θ20 : PLTV.θ 20 = .lit (F64.ofNat 8)
kernel_rfl θ22 : PLTV.θ 22 = .var 22
kernel_rfl θ23 : PLTV.θ 23 = .lit (F64.ofNat 7)
kernel_rfl θ24 : PLTV.θ 24 = .var 24
kernel_rfl θ25 : PLTV.θ 25 = .lit (F64.ofNat 7)
kernel_rfl θ26 : PLTV.θ 26 = .var 26
kernel_rfl θ200 : PLTV.θ 200 = .bin .add (.var 21) (.lit (F64.ofNat 1))
kernel_rfl θ259 : PLTV.θ 259 = .un .int32 (.var 28)
kernel_rfl θ260 : PLTV.θ 260 = .un .int32 (.bin .add (.var 28) (.lit (F64.ofNat 1)))

theorem handVW {L : Nat} {ν : Nat → F64} (h3 : 3 ≤ L) (hL : L ≤ 224) (h : VWVals L ν) :
    tail.hand L (Shift.valuation PLTV.θ ν) := by
  intro v k hv
  have hb : Nat.ble L 2 = false := by
    cases e : Nat.ble L 2 with
    | false => rfl
    | true => have := Nat.le_of_ble_eq_true e; omega
  unfold handVal at hv
  rw [hb] at hv
  simp only [Bool.cond_false] at hv
  change (PLTV.θ v).eval ν = _
  split at hv <;> (try cases hv)
  · rw [θ20]; rfl
  · rw [θ22]; exact h.v22
  · rw [θ23]; rfl
  · rw [θ24]; exact h.v24
  · rw [θ25]; rfl
  · rw [θ26]; exact h.v26
  · rw [θ200]
    change F64.bin .add (ν 21) (F64.ofNat 1) = _
    rw [h.v21]
    exact bin_add_ofNat 6 1 (by omega)
  · rw [θ259]
    exact eval_int32 h.v28 (by omega)
  · rw [θ260]
    refine eval_int32 ?_ (by omega)
    change F64.bin .add (ν 28) (F64.ofNat 1) = _
    rw [h.v28, bin_add_ofNat (L - 1) 1 (by omega), show L - 1 + 1 = L by omega]

kernel_rfl θ14 : PLTV.θ 14 = .var 17
kernel_rfl θ9 : PLTV.θ 9 = .var 9
kernel_rfl θ10 : PLTV.θ 10 = .var 10
kernel_rfl θ11 : PLTV.θ 11 = .var 11
kernel_rfl θ16 : PLTV.θ 16 = .var 16
kernel_rfl θres : (List.range 9).all (fun j => decide (PLTV.θ j = .var j)) = true
kernel_rfl keysOk : ((PLTVW.R.theta ++ PLTV.thetaX).map Prod.fst).all
  (fun j => Nat.beq j 14 || (tailVal j).isSome || [20, 23, 25, 200, 259, 260].contains j) = true
kernel_rfl tvA : PLTVW.R.data.a 2590 = 2590
kernel_rfl tvB : PLTVW.R.data.a 2586 = 2586
kernel_rfl tvC : PLTVW.R.data.a 2589 = 2589
kernel_rfl tvE : PLTVW.R.data.a 12504 = 12504
kernel_rfl tvH : Nat.ble ((mlxOf PRE_plvw_common.s1.ffi).next + 4096) ((mlxOf PRE_pl_tail.s0.ffi).next + 65536) = true
kernel_rfl tvN : Nat.ble ((mlxOf PRE_plvw_common.s1.ffi).nnext + 4096) ((mlxOf PRE_pl_tail.s0.ffi).nnext + 65536) = true
kernel_rfl tvGrow : Nat.ble PRE_pl_tail.s0.next PRE_plvw_common.s1.next = true
kernel_rfl tvDiff : PRE_plvw_common.s1.next - PRE_pl_tail.s0.next = 145989

kernel_rfl tailValSmall : (List.range 259).all (fun j => (tailVal j).all fun k => Nat.ble k 1536) = true

theorem tailVal_le {j k : Nat} (h : tailVal j = some k) : k ≤ 1536 := by
  have hc := List.all_eq_true.mp tailValSmall j (List.mem_range.mpr (tailVal_lt h))
  rw [h] at hc
  exact Nat.le_of_ble_eq_true hc

theorem handVal_le {L j k : Nat} (h : handVal L j = some k) : k ≤ L + 8 := by
  unfold handVal at h
  cases hb : Nat.ble L 2 <;> rw [hb] at h <;> simp only [Bool.cond_true, Bool.cond_false] at h <;> split at h <;>
    first | (cases h; omega) | cases h

theorem handSome {L j : Nat} (h3 : 3 ≤ L) (hj : j ∈ [20, 23, 25, 200, 259, 260]) : (handVal L j).isSome = true := by
  have hb : Nat.ble L 2 = false := by
    cases e : Nat.ble L 2 with
    | false => rfl
    | true => have := Nat.le_of_ble_eq_true e; omega
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
  rcases hj with rfl | rfl | rfl | rfl | rfl | rfl <;> simp [handVal, hb]

theorem valVW {L : Nat} {ν : Nat → F64} (h3 : 3 ≤ L) (hL : L ≤ 224) (h : VWVals L ν) (hv : VBOkF loopVB ν) :
    VBOkF loopVB (Shift.valuation PLTV.θ ν) := by
  intro j
  change ∃ k ≤ 2 ^ 20, (PLTV.θ j).eval ν = F64.ofNat k
  cases ht : tailVal j with
  | some k =>
    have hk := tailVal_le ht
    exact ⟨k, by omega, dimsVW (by omega) hL h j k ht⟩
  | none =>
    cases hh : handVal L j with
    | some k =>
      have hk := handVal_le hh
      exact ⟨k, by omega, handVW h3 hL h j k hh⟩
    | none =>
      by_cases h14 : j = 14
      · subst h14
        rw [θ14]
        exact hv 17
      · have hθ : PLTV.θ j = .var j := Pf.thetaOf_off (fun hm => by
          have hc := List.all_eq_true.mp keysOk j hm
          simp only [Bool.or_eq_true, Nat.beq_eq, ht, Option.isSome_none, Bool.false_eq_true, or_false] at hc
          rcases hc with hc | hc
          · exact h14 hc
          · have := handSome h3 (List.contains_iff_mem.mp hc)
            rw [hh] at this
            cases this)
        rw [hθ]
        exact hv j

/-- **VW's link to the shared tail.** -/
theorem hlinkVW {T cap capT nI nIT : Nat} {tk : Nat → Nat} {π : List Nat} {Mem Mem' : SegInst FF → Prop}
    (hcap : cap + 145989 ≤ capT) (hbound : capT < Sim.bound) (h3 : 3 ≤ π.length) (hL : π.length ≤ 224)
    (hs : ∀ x : SegInst FF, Mem x → VWVals π.length x.ν)
    (hook : ∀ x y : SegInst FF, y.t = x.t → y.C = x.C → (∀ c, y.M.node c = x.M.node (PLTVW.R.data.nodeF c)) →
      y.M.a 12504 = x.M.a 12504 → Mem x → Mem' y) :
    CutConv (withMem Mem (indexedCut0 [2823901] 15235 T tk cap nI π PRE_plvw_common.s1 PRE_plvw_common.S1))
      (withMem Mem' (indexedCut 15235 T tk capT nIT π PRE_pl_tail.s0 PRE_pl_tail.S0)) :=
  toTailT PLTV.facts (fun b hb => by obtain rfl := List.mem_singleton.mp hb; rfl)
    (Nat.le_of_ble_eq_true tvH) (Nat.le_of_ble_eq_true tvN) (Nat.le_of_ble_eq_true tvGrow)
    (by rw [tvDiff]; omega) hbound θ9 θ10 θ11 θ16
    (fun j hj => of_decide_eq_true (List.all_eq_true.mp θres j (List.mem_range.mpr hj)))
    (fun x hm hv => valVW h3 hL (hs x hm) hv) (fun x hm => dimsVW (by omega) hL (hs x hm))
    (fun x hm => handVW h3 hL (hs x hm)) tvA tvB tvC tvE hook

end Host.Ts.Sim.Compose.Post
