import host.ts.RenameNumbers
import host.mlx.Ffi
namespace Host.Mlx.Ffi
open Host.Ts
set_option maxRecDepth 1000000

/-! Read-back queue framing for the actual MLX FFI dispatch. A template with enough
read-back values remains valid when later iterations' values follow its queue. -/

deriving instance DecidableEq for Sym

theorem symOf_itemU32 : symOf chars!"mlx_array_item_uint32" = some .itemU32 := by decide +kernel

theorem call_itemU32_eq (s : St) (b off : Nat) (bs : List Byte) (h : Arg) :
    call s chars!"mlx_array_item_uint32" [.jsPtr b off bs, h] =
      match (argNat h).bind s.nodeId?, (argNat h).bind s.node? with
      | some k, some n => bif Nat.beq n.dtype dtUint32 then
          match s.items.get k, s.tokens with
          | some t, _ => okW s status0 [(b, off, cellParts .u32 (.num t) 4 0)]
          | none, t :: ts => okW { s with tokens := ts, items := s.items.set k t }
              status0 [(b, off, cellParts .u32 (.num t) 4 0)]
          | none, [] => stuck
        else stuck
      | _, _ => stuck := by
  unfold call
  rw [symOf_itemU32]
  rfl

/-- The first read of a sampled node writes the head value and records it. This is a
fact about `call`, with concrete native handle and node lookups as its premises. -/
theorem itemU32_first_read (s : St) (b off : Nat) (bs : List Byte) (h : Arg)
    (k : Nat) (n : Node) (t : NumV) (ts : List NumV)
    (hk : (argNat h).bind s.nodeId? = some k)
    (hn : (argNat h).bind s.node? = some n) (hd : Nat.beq n.dtype dtUint32 = true)
    (hm : s.items.get k = none) (ht : s.tokens = t :: ts) :
    (call s chars!"mlx_array_item_uint32" [.jsPtr b off bs, h]).run =
      .pure (some ({ s with tokens := ts, items := s.items.set k t },
        status0, [(b, off, cellParts .u32 (.num t) 4 0)])) := by
  rw [call_itemU32_eq, hk, hn]
  simp only [hd, Bool.cond_true, hm, ht, okW, M.run, M.pure]

/-- Reading a node whose result was already recorded preserves the read-back queue. -/
theorem itemU32_repeat_read (s : St) (b off : Nat) (bs : List Byte) (h : Arg)
    (k : Nat) (n : Node) (t : NumV)
    (hk : (argNat h).bind s.nodeId? = some k)
    (hn : (argNat h).bind s.node? = some n) (hd : Nat.beq n.dtype dtUint32 = true)
    (hm : s.items.get k = some t) :
    (call s chars!"mlx_array_item_uint32" [.jsPtr b off bs, h]).run =
      .pure (some (s, status0, [(b, off, cellParts .u32 (.num t) 4 0)])) := by
  rw [call_itemU32_eq, hk, hn]
  simp only [hd, Bool.cond_true, hm, okW, M.run, M.pure]

/-- Extending the read-back queue by an arbitrary suffix leaves this iteration's first
read unchanged and leaves the suffix available to future iterations. -/
theorem itemU32_first_read_append (s : St) (b off : Nat) (bs : List Byte) (h : Arg)
    (k : Nat) (n : Node) (t : NumV) (ts tail : List NumV)
    (hk : (argNat h).bind s.nodeId? = some k)
    (hn : (argNat h).bind s.node? = some n) (hd : Nat.beq n.dtype dtUint32 = true)
    (hm : s.items.get k = none) (ht : s.tokens = t :: ts) :
    (call { s with tokens := s.tokens ++ tail } chars!"mlx_array_item_uint32" [.jsPtr b off bs, h]).run =
      .pure (some ({ s with tokens := ts ++ tail, items := s.items.set k t },
        status0, [(b, off, cellParts .u32 (.num t) 4 0)])) := by
  exact itemU32_first_read { s with tokens := s.tokens ++ tail } b off bs h k n t (ts ++ tail)
    hk hn hd hm (by rw [ht]; rfl)

/-- The actual read-back write renames the buffer address and numeric reference,
preserving the byte offset and byte order. -/
theorem itemU32_write_renamed (R : Ren) (b off : Nat) (t : NumV) :
    R.write (b, off, cellParts .u32 (.num t) 4 0) =
      (R.a b, off, cellParts .u32 (.num (R.num t)) 4 0) := rfl

/-- A read on a renamed live native handle/node uses the renamed sampled value.
Only the target's concrete live lookups and queue are required; no machine-step
simulation hypothesis is hidden in this statement. -/
theorem itemU32_first_read_renamed (R : Ren) (s : St) (b off : Nat) (bs : List Byte) (h : Arg)
    (k : Nat) (n : Node) (t : NumV) (ts : List NumV)
    (hk : (argNat h).bind s.nodeId? = some k)
    (hn : (argNat h).bind s.node? = some n) (hd : Nat.beq n.dtype dtUint32 = true)
    (hm : s.items.get k = none) (ht : s.tokens = R.num t :: ts) :
    (call s chars!"mlx_array_item_uint32" [.jsPtr (R.a b) off bs, h]).run =
      .pure (some ({ s with tokens := ts, items := s.items.set k (R.num t) },
        R.ret status0, [R.write (b, off, cellParts .u32 (.num t) 4 0)])) := by
  rw [itemU32_write_renamed]
  exact itemU32_first_read s (R.a b) off bs h k n (R.num t) ts hk hn hd hm ht

end Host.Mlx.Ffi
