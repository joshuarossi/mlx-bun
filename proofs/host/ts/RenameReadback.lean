import host.ts.RenameAllocation
namespace Host.Mlx.Ffi
open Host.Ts

namespace LiveNative

/-- Recording one sampled token preserves every other live memoized item and leaves
the arbitrary unread suffix available to subsequent loop iterations. -/
theorem recordRead {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') (i : Nat) (hi : N i) (t : NumV) (ts : List NumV)
    (bs : i / 4096 < 4 ^ 31) (bt : R.node i / 4096 < 4 ^ 31) :
    LiveNative R H N O tail { s with tokens := ts, items := s.items.set i t }
      { s' with tokens := ts.map R.num ++ tail, items := s'.items.set (R.node i) (R.num t) } := by
  have ib := h.liveNodeBound i hi
  have ib' := h.nodeBound i ib
  refine { h with items := ?_, tokens := rfl, sourceItemsBound := ?_, targetItemsBound := ?_ }
  · intro j hj
    change (s'.items.set (R.node i) (R.num t)).get (R.node j) =
      ((s.items.set i t).get j).map R.num
    rw [PTrie.get_set _ _ _ bt, PTrie.get_set _ _ _ bs]
    by_cases he : j = i
    · subst j
      simp only [ite_true, Option.map_some]
    · have he' : R.node j ≠ R.node i := fun heq => he (h.nodeInj j i (h.liveNodeBound j hj) ib heq)
      simp only [ite_eq_right he, ite_eq_right he', h.items j hj]
  · intro j u hj
    change (s.items.set i t).get j = some u at hj
    rw [PTrie.get_set _ _ _ bs] at hj
    by_cases he : j = i
    · subst j; exact ib
    · simp only [ite_eq_right he] at hj
      exact h.sourceItemsBound j u hj
  · intro j u hj
    change (s'.items.set (R.node i) (R.num t)).get j = some u at hj
    rw [PTrie.get_set _ _ _ bt] at hj
    by_cases he : j = R.node i
    · subst j; exact ib'
    · simp only [ite_eq_right he] at hj
      exact h.targetItemsBound j u hj

end LiveNative

theorem argNat_big_nat (a : Nat) : argNat (.big (Int.ofNat a)) = some a := by
  simp only [argNat, argInt, Option.bind_some]
  rfl

theorem argNat_renamed_handle (R : Ren) (a : Nat) (ha : 0 ≤ R.big (Int.ofNat a)) :
    argNat (R.arg (.big (Int.ofNat a))) = some (R.handle a) := by
  simp only [Ren.arg, argNat, argInt, Option.bind_some, ha, decide_true, Bool.cond_true, Ren.handle]

/-- The complete native read-back dispatch on corresponding live handles. This proves
both actual calls and preservation of live state, including a caller-supplied unread suffix. -/
theorem call_itemU32_live {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') (a b off i : Nat) (bs : List Byte) (n : Node)
    (ha : H a) (hzero : 0 < s.next) (hid : s.nodeId? a = some i)
    (hn : s.node? a = some n) (hd : Nat.beq n.dtype dtUint32 = true)
    (hm : s.items.get i = none) (t : NumV) (ts : List NumV) (ht : s.tokens = t :: ts)
    (bi : i / 4096 < 4 ^ 31) (bi' : R.node i / 4096 < 4 ^ 31) :
    let u := { s with tokens := ts, items := s.items.set i t }
    let u' := { s' with tokens := ts.map R.num ++ tail, items := s'.items.set (R.node i) (R.num t) }
    (call s chars!"mlx_array_item_uint32" [.jsPtr b off bs, .big (Int.ofNat a)]).run =
      .pure (some (u, status0, [(b, off, cellParts .u32 (.num t) 4 0)])) ∧
    (call s' chars!"mlx_array_item_uint32" [R.arg (.jsPtr b off bs), R.arg (.big (Int.ofNat a))]).run =
      .pure (some (u', R.ret status0, [R.write (b, off, cellParts .u32 (.num t) 4 0)])) ∧
    LiveNative R H N O tail u u' := by
  dsimp only
  have hi : N i := by
    unfold St.nodeId? at hid
    cases hz : Nat.beq a 0
    · simp only [hz, Bool.cond_false] at hid
      exact h.arrLive a i ha hid
    · simp only [hz, Bool.cond_true] at hid
      cases hid
  have hid' : s'.nodeId? (R.handle a) = some (R.node i) := by
    rw [h.nodeId? ha (h.liveHandleBound a ha) hzero, hid]
    rfl
  obtain ⟨n', hn', hshape, hdt⟩ := h.node? ha hn
  have hm' : s'.items.get (R.node i) = none := by rw [h.items i hi, hm]; rfl
  have ht' : s'.tokens = R.num t :: (ts.map R.num ++ tail) := by rw [h.tokens, ht]; rfl
  refine ⟨itemU32_first_read s b off bs (.big (Int.ofNat a)) i n t ts ?_ ?_ hd hm ht, ?_,
    h.recordRead i hi t ts bi bi'⟩
  · rw [argNat_big_nat]; exact hid
  · rw [argNat_big_nat]; exact hn
  · apply itemU32_first_read_renamed R s' b off (bs.map R.byte) (R.arg (.big (Int.ofNat a)))
      (R.node i) n' t (ts.map R.num ++ tail)
    · rw [argNat_renamed_handle R a (h.handleNonneg a ha)]; exact hid'
    · rw [argNat_renamed_handle R a (h.handleNonneg a ha)]; exact hn'
    · rw [hdt]; exact hd
    · exact hm'
    · exact ht'

end Host.Mlx.Ffi
