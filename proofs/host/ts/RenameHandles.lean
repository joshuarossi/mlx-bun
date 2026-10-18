import host.ts.RenameAllocation
namespace Host.Mlx.Ffi
open Host.Ts
namespace LiveNative

theorem source_fresh_obj {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') {i : Nat} (hi : s.next ≤ i) : s.objs.get i = none := by
  cases hx : s.objs.get i with
  | none => rfl
  | some o => have := h.sourceObjsBound i o hx; omega

theorem target_fresh_obj {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') {i : Nat} (hi : s'.next ≤ i) : s'.objs.get i = none := by
  cases hx : s'.objs.get i with
  | none => rfl
  | some o => have := h.targetObjsBound i o hx; omega

/-- The real MLX result-slot allocator, starting from a null slot, creates corresponding
fresh handles for corresponding live nodes and preserves all prior live resources. -/
theorem setArr_zero {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') (i : Nat) (hi : N i)
    (bs : s.next / 4096 < 4 ^ 31) (bt : s'.next / 4096 < 4 ^ 31) :
    LiveNative R (fun a => a = s.next ∨ H a) N O tail
      (s.setArr 0 i).2 (s'.setArr 0 (R.node i)).2 := by
  have hf : R.handle s.next = s'.next := by simpa using h.handleFresh 0
  have hbf : R.big (Int.ofNat s.next) = Int.ofNat s'.next := by simpa using h.bigFresh 0
  refine {
    arrs := ?_, objs := ?_, nodes := h.nodes, arrLive := ?_, items := h.items,
    tokens := h.tokens, pending := h.pending, errh := h.errh, files := h.files,
    arch := h.arch, deviceSizes := h.deviceSizes, wired := h.wired,
    handleNonneg := ?_, liveHandleBound := ?_, liveNodeBound := h.liveNodeBound,
    handleBound := ?_, nodeBound := h.nodeBound,
    sourceItemsBound := h.sourceItemsBound, targetItemsBound := h.targetItemsBound,
    sourceObjsBound := ?_, targetObjsBound := ?_, sourceArrsBound := ?_, targetArrsBound := ?_,
    handleInj := ?_, nodeInj := h.nodeInj, handleFresh := ?_, bigFresh := ?_,
    nodeFresh := h.nodeFresh, handleZero := h.handleZero }
  · intro a ha
    change (s'.arrs.set s'.next (R.node i)).get (R.handle a) =
      ((s.arrs.set s.next i).get a).map R.node
    rcases ha with rfl | ha
    · rw [hf, PTrie.get_set_self _ _ _ bt, PTrie.get_set_self _ _ _ bs]
      rfl
    · have ab := h.liveHandleBound a ha
      have ab' := h.handleBound a ab
      rw [PTrie.get_set_ne _ _ _ bt _ (by omega), PTrie.get_set_ne _ _ _ bs _ (by omega)]
      exact h.arrs a ha
  · intro a ha
    rcases ha with rfl | ha
    · change s'.objs.get (R.handle s.next) = (s.objs.get s.next).map R.nativeObj
      rw [hf, h.source_fresh_obj (Nat.le_refl _), h.target_fresh_obj (Nat.le_refl _)]
      rfl
    · exact h.objs a ha
  · intro a j ha haj
    change (s.arrs.set s.next i).get a = some j at haj
    rcases ha with rfl | ha
    · rw [PTrie.get_set_self _ _ _ bs] at haj
      have hij : i = j := Option.some.inj haj
      subst j
      exact hi
    · rw [PTrie.get_set_ne _ _ _ bs _ (by have := h.liveHandleBound a ha; omega)] at haj
      exact h.arrLive a j ha haj
  · intro a ha
    rcases ha with rfl | ha
    · rw [hbf]
      exact Int.natCast_nonneg _
    · exact h.handleNonneg a ha
  · intro a ha
    change a < s.next + 1
    rcases ha with rfl | ha
    · omega
    · have := h.liveHandleBound a ha; omega
  · intro a ha
    change a < s.next + 1 at ha
    change R.handle a < s'.next + 1
    by_cases he : a = s.next
    · subst a; rw [hf]; omega
    · have hb : a < s.next := by omega
      have := h.handleBound a hb; omega
  · intro a o ha
    change a < s.next + 1
    have := h.sourceObjsBound a o ha; omega
  · intro a o ha
    change a < s'.next + 1
    have := h.targetObjsBound a o ha; omega
  · intro a j ha
    change (s.arrs.set s.next i).get a = some j at ha
    change a < s.next + 1
    rw [PTrie.get_set _ _ _ bs] at ha
    by_cases he : a = s.next
    · subst a; omega
    · simp only [ite_eq_right he] at ha
      have := h.sourceArrsBound a j ha; omega
  · intro a j ha
    change (s'.arrs.set s'.next (R.node i)).get a = some j at ha
    change a < s'.next + 1
    rw [PTrie.get_set _ _ _ bt] at ha
    by_cases he : a = s'.next
    · subst a; omega
    · simp only [ite_eq_right he] at ha
      have := h.targetArrsBound a j ha; omega
  · intro a b ha hb he
    change a < s.next + 1 at ha
    change b < s.next + 1 at hb
    by_cases haa : a = s.next
    · subst a
      by_cases hbb : b = s.next
      · exact hbb.symm
      · have bb : b < s.next := by omega
        have := h.handleBound b bb
        rw [hf] at he
        omega
    · have ab : a < s.next := by omega
      by_cases hbb : b = s.next
      · subst b
        have := h.handleBound a ab
        rw [hf] at he
        omega
      · exact h.handleInj a b ab (by omega) he
  · intro k
    change R.handle (s.next + 1 + k) = s'.next + 1 + k
    simpa only [Nat.add_assoc] using h.handleFresh (1 + k)
  · intro k
    change R.big (Int.ofNat (s.next + 1 + k)) = Int.ofNat (s'.next + 1 + k)
    simpa only [Nat.add_assoc] using h.bigFresh (1 + k)

end LiveNative
end Host.Mlx.Ffi
