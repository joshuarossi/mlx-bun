import host.mlx.NativeUpdates
import host.ts.RenameNative

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned

variable {NR : NumV → NumV → Prop} {R : Ren}
  {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
  {H N : Nat → Prop} {tail : List NumV} {s s' : St}

theorem nodeId? (h : Live NR R NodeRel ObjRel H N tail s s')
    (a k : Nat) (ha : H a) (hne : a ≠ 0) (hk : s.arrs.get a = some k) :
    s'.nodeId? (R.handle a) = some (R.node k) := by
  unfold St.nodeId?
  have hb : Nat.beq (R.handle a) 0 = false := by
    cases he : Nat.beq (R.handle a) 0
    · rfl
    · exact False.elim (h.handle_ne_zero ha hne (Nat.eq_of_beq_eq_true he))
  rw [hb, h.arrs a ha, hk]
  rfl

/-- Actual uint32 readback on both sides consumes the related queue heads,
records them at related graph nodes, and writes related numeric bytes. -/
theorem itemU32_first (h : Live NR R NodeRel ObjRel H N tail s s')
    (a k b off : Nat) (bytes bytes' : List Byte) (n : Node) (t : NumV) (ts : List NumV)
    (ha : H a) (hne : a ≠ 0) (hk : s.arrs.get a = some k)
    (hn : s.node? a = some n) (hd : Nat.beq n.dtype dtUint32 = true)
    (nodeDtype : ∀ i x y, NodeRel i x y → y.dtype = x.dtype)
    (hm : s.items.get k = none) (ht : s.tokens = t :: ts)
    (bs : k < 2^64) (bt : R.node k < 2^64) :
    ∃ t' known,
      NR t t' ∧ ListR NR ts known ∧ s'.tokens = t' :: (known ++ tail) ∧
      (call s chars!"mlx_array_item_uint32" [.jsPtr b off bytes, .big (Int.ofNat a)]).run =
        .pure (some ({ s with tokens := ts, items := s.items.set k t },
          status0, [(b, off, cellParts .u32 (.num t) 4 0)])) ∧
      (call s' chars!"mlx_array_item_uint32" [.jsPtr (R.a b) off bytes', .big (Int.ofNat (R.handle a))]).run =
        .pure (some ({ s' with tokens := known ++ tail, items := s'.items.set (R.node k) t' },
          status0, [(R.a b, off, cellParts .u32 (.num t') 4 0)])) ∧
      Live NR R NodeRel ObjRel H N tail
        { s with tokens := ts, items := s.items.set k t }
        { s' with tokens := known ++ tail, items := s'.items.set (R.node k) t' } ∧
      ListR (Host.Ts.Owned.Parametric.ByteR NR R)
        (cellParts .u32 (.num t) 4 0) (cellParts .u32 (.num t') 4 0) := by
  have hkl := h.arrLive a k ha hk
  obtain ⟨t', known, hr, hks, hts, hl⟩ := h.recordRead k hkl t ts ht bs bt
  obtain ⟨i, n', hi, hn', hnn⟩ := h.node? ha hn
  have hik : i = k := Option.some.inj (hi.symm.trans hk)
  subst i
  have hm' : s'.items.get (R.node k) = none := by
    have hv := h.items k hkl
    rw [hm] at hv
    cases he : s'.items.get (R.node k) with
    | none => rfl
    | some v => rw [he] at hv; cases hv
  have hs : s.nodeId? a = some k := by
    unfold St.nodeId?
    have hb : Nat.beq a 0 = false := by
      cases he : Nat.beq a 0
      · rfl
      · exact False.elim (hne (Nat.eq_of_beq_eq_true he))
    rw [hb]; exact hk
  have hs' := h.nodeId? a k ha hne hk
  refine ⟨t', known, hr, hks, hts, ?_, ?_, hl, Parametric.cellParts_roles (.num hr) .u32 4 0⟩
  · exact itemU32_first_read s b off bytes (.big (Int.ofNat a)) k n t ts
      (by simpa only [argNat_big_nat, Option.bind_some] using hs)
      (by simpa only [argNat_big_nat, Option.bind_some] using hn) hd hm ht
  · exact itemU32_first_read s' (R.a b) off bytes' (.big (Int.ofNat (R.handle a)))
      (R.node k) n' t' (known ++ tail)
      (by simpa only [argNat_big_nat, Option.bind_some] using hs')
      (by simpa only [argNat_big_nat, Option.bind_some] using hn')
      (by rw [nodeDtype k n n' hnn]; exact hd) hm' hts

end Host.Mlx.Ffi.NativeRoles.Live
