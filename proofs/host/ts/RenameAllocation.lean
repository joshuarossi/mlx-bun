import host.ts.RenameLive
import host.ts.StoreLaws
namespace Host.Mlx.Ffi
open Host.Ts

theorem NodeR.mono {R : Ren} {P Q : Prop} {n n' : Node} (h : NodeR R P n n') (hp : P → Q) :
    NodeR R Q n n' := ⟨h.shape, h.dtype, h.graph.imp hp id⟩

theorem NodeSlotR.mono {R : Ren} {P Q : Prop} {n n' : Option Node}
    (h : NodeSlotR R P n n') (hp : P → Q) : NodeSlotR R Q n n' := by
  cases h with
  | absent => exact .absent
  | present hv => exact .present (hv.mono hp)

namespace LiveNative

theorem source_fresh_item {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') {i : Nat} (hi : s.nnext ≤ i) : s.items.get i = none := by
  cases hx : s.items.get i with
  | none => rfl
  | some t => have := h.sourceItemsBound i t hx; omega

theorem target_fresh_item {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') {i : Nat} (hi : s'.nnext ≤ i) : s'.items.get i = none := by
  cases hx : s'.items.get i with
  | none => rfl
  | some t => have := h.targetItemsBound i t hx; omega

/-- The real FFI graph allocator commutes with fresh node renaming. Existing opaque
roots remain opaque; the newly emitted node retains its full primitive and input graph. -/
theorem addNode {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') (n n' : Node) (hn : NodeR R False n n')
    (bs : s.nnext / 4096 < 4 ^ 31) (bt : s'.nnext / 4096 < 4 ^ 31) :
    LiveNative R H (fun i => i = s.nnext ∨ N i) (fun i => i ≠ s.nnext ∧ O i) tail
      (s.addNode n).2 (s'.addNode n').2 := by
  have hf : R.node s.nnext = s'.nnext := by simpa using h.nodeFresh 0
  refine {
    arrs := h.arrs, objs := h.objs, arrLive := ?_, nodes := ?_, items := ?_,
    tokens := h.tokens, pending := h.pending, errh := h.errh, files := h.files,
    arch := h.arch, deviceSizes := h.deviceSizes, wired := h.wired,
    handleNonneg := h.handleNonneg, liveHandleBound := h.liveHandleBound,
    liveNodeBound := ?_, handleBound := h.handleBound, nodeBound := ?_,
    sourceItemsBound := ?_, targetItemsBound := ?_, handleInj := h.handleInj,
    sourceObjsBound := h.sourceObjsBound, targetObjsBound := h.targetObjsBound,
    sourceArrsBound := h.sourceArrsBound, targetArrsBound := h.targetArrsBound,
    nodeInj := ?_, handleFresh := h.handleFresh, bigFresh := h.bigFresh,
    nodeFresh := ?_, handleZero := h.handleZero }
  · intro i hi
    change NodeSlotR R (i ≠ s.nnext ∧ O i)
      ((s.nodes.set s.nnext n).get i) ((s'.nodes.set s'.nnext n').get (R.node i))
    rcases hi with rfl | hi
    · rw [hf, PTrie.get_set_self _ _ _ bs, PTrie.get_set_self _ _ _ bt]
      exact .present (hn.mono False.elim)
    · have hib := h.liveNodeBound i hi
      have hir := h.nodeBound i hib
      have hin : i ≠ s.nnext := by omega
      have hin' : R.node i ≠ s'.nnext := by omega
      rw [PTrie.get_set_ne _ _ _ bs _ hin, PTrie.get_set_ne _ _ _ bt _ hin']
      exact (h.nodes i hi).mono (fun ho => ⟨hin, ho⟩)
  · intro a i ha hi
    exact .inr (h.arrLive a i ha hi)
  · intro i hi
    rcases hi with rfl | hi
    · change s'.items.get (R.node s.nnext) = (s.items.get s.nnext).map R.num
      rw [hf, h.source_fresh_item (Nat.le_refl _), h.target_fresh_item (Nat.le_refl _)]
      rfl
    · exact h.items i hi
  · intro i hi
    change i < s.nnext + 1
    rcases hi with rfl | hi
    · omega
    · have := h.liveNodeBound i hi; omega
  · intro i hi
    change R.node i < s'.nnext + 1
    change i < s.nnext + 1 at hi
    by_cases he : i = s.nnext
    · subst i; rw [hf]; omega
    · have hil : i < s.nnext := by omega
      have := h.nodeBound i hil; omega
  · intro i t hi
    have := h.sourceItemsBound i t hi
    change i < s.nnext + 1
    omega
  · intro i t hi
    have := h.targetItemsBound i t hi
    change i < s'.nnext + 1
    omega
  · intro i j hi hj he
    change i < s.nnext + 1 at hi
    change j < s.nnext + 1 at hj
    by_cases hii : i = s.nnext
    · subst i
      by_cases hjj : j = s.nnext
      · exact hjj.symm
      · have hjb : j < s.nnext := by omega
        have hb := h.nodeBound j hjb
        rw [hf] at he
        omega
    · have hib : i < s.nnext := by omega
      by_cases hjj : j = s.nnext
      · subst j
        have hb := h.nodeBound i hib
        rw [hf] at he
        omega
      · exact h.nodeInj i j hib (by omega) he
  · intro k
    change R.node (s.nnext + 1 + k) = s'.nnext + 1 + k
    simpa only [Nat.add_assoc] using h.nodeFresh (1 + k)

end LiveNative
end Host.Mlx.Ffi
