import host.mlx.NativeUpdates

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

/-- Native graph production followed by assignment to a null result slot. -/
def createZero (s : St) (n : Node) : St :=
  ((s.addNode n).2.setArr 0 s.nnext).2

namespace Live
variable {NR : NumV → NumV → Prop} {R : Ren}
  {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
  {H N : Nat → Prop} {tail : List NumV} {s s' : St}

theorem createZero (h : Live NR R NodeRel ObjRel H N tail s s') (n n' : Node)
    (hn : NodeRel s.nnext n n')
    (ns : s.nnext < 2^64) (nt : s'.nnext < 2^64)
    (hs : s.next < 2^64) (ht : s'.next < 2^64) :
    Live NR R NodeRel ObjRel (fun a => a = s.next ∨ H a)
      (fun i => i = s.nnext ∨ N i) tail
      (NativeRoles.createZero s n) (NativeRoles.createZero s' n') := by
  have hv := (h.addNode n n' hn ns nt).setArr_zero s.nnext (.inl rfl) hs ht
  have hf := h.nodeMap.head
  change Live NR R NodeRel ObjRel (fun a => a = s.next ∨ H a)
    (fun i => i = s.nnext ∨ N i) tail
    (NativeRoles.createZero s n) (((s'.addNode n').2.setArr 0 (R.node s.nnext)).2) at hv
  rw [hf] at hv
  exact hv

end Live

theorem leafOut_zero (s : St) (out : Arg) (b off : Nat) (p : Prim) (shape : List Dim) (dt : Nat)
    (ho : slotOf out = some (b, off, 0)) :
    leafOut s out p shape dt =
      okW (createZero s ⟨p, [], shape, dt⟩) status0 [u64Write b off s.next] := by
  unfold leafOut
  rw [ho]
  rfl

/-- Shape inference is an explicit premise about the original `infer`.
The conclusion unfolds the actual output helper without substituting a
different graph builder or changing its allocation order. -/
theorem opOut_node_zero (s : St) (out : Arg) (b off : Nat) (p : Prim) (ins : List Nat)
    (inputs : List (List Dim × Nat)) (shape : List Dim) (dt : Nat)
    (ho : slotOf out = some (b, off, 0)) (hi : shapesOf s ins = some inputs)
    (hinfer : infer p inputs = M.pure (some (.node shape dt))) :
    opOut s out p ins =
      okW (createZero s ⟨p, ins, shape, dt⟩) status0 [u64Write b off s.next] := by
  unfold opOut
  rw [ho, hi]
  dsimp only
  rw [hinfer]
  rfl

namespace Live
variable {NR : NumV → NumV → Prop} {R : Ren}
  {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
  {H N : Nat → Prop} {tail : List NumV} {s s' : St}

/-- The real leaf-output helper produces related fresh graph nodes and handles.
The primitive relation is proved by the caller, rather than assumed as a
universal native-call simulation law. -/
theorem leafOut_zero (h : Live NR R NodeRel ObjRel H N tail s s')
    (out out' : Arg) (b off : Nat) (p p' : Prim) (shape shape' : List Dim) (dt dt' : Nat)
    (ho : slotOf out = some (b, off, 0)) (ho' : slotOf out' = some (R.a b, off, 0))
    (hn : NodeRel s.nnext ⟨p, [], shape, dt⟩ ⟨p', [], shape', dt'⟩)
    (ns : s.nnext < 2^64) (nt : s'.nnext < 2^64)
    (hs : s.next < 2^64) (ht : s'.next < 2^64) :
    leafOut s out p shape dt =
        okW (NativeRoles.createZero s ⟨p, [], shape, dt⟩) status0 [u64Write b off s.next] ∧
      leafOut s' out' p' shape' dt' =
        okW (NativeRoles.createZero s' ⟨p', [], shape', dt'⟩) status0 [u64Write (R.a b) off s'.next] ∧
      Live NR R NodeRel ObjRel (fun a => a = s.next ∨ H a)
        (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s ⟨p, [], shape, dt⟩)
        (NativeRoles.createZero s' ⟨p', [], shape', dt'⟩) ∧
      ListR (Host.Ts.Owned.Parametric.ByteR NR R)
        (cellParts .u64 (.big (Int.ofNat s.next)) 8 0)
        (cellParts .u64 (.big (Int.ofNat s'.next)) 8 0) := by
  refine ⟨NativeRoles.leafOut_zero s out b off p shape dt ho,
    NativeRoles.leafOut_zero s' out' (R.a b) off p' shape' dt' ho',
    h.createZero _ _ hn ns nt hs ht, ?_⟩
  rw [← h.handleMap.head]
  exact Parametric.cellParts_roles (.handle _) .u64 8 0

/-- Paired graph output after each side's original shape inference has been
established. Shapes may contain different literal or symbolic dimensions. -/
theorem opOut_node_zero (h : Live NR R NodeRel ObjRel H N tail s s')
    (out out' : Arg) (b off : Nat) (p p' : Prim) (ins ins' : List Nat)
    (inputs inputs' : List (List Dim × Nat)) (shape shape' : List Dim) (dt dt' : Nat)
    (ho : slotOf out = some (b, off, 0)) (ho' : slotOf out' = some (R.a b, off, 0))
    (hi : shapesOf s ins = some inputs) (hi' : shapesOf s' ins' = some inputs')
    (hinfer : infer p inputs = M.pure (some (.node shape dt)))
    (hinfer' : infer p' inputs' = M.pure (some (.node shape' dt')))
    (hn : NodeRel s.nnext ⟨p, ins, shape, dt⟩ ⟨p', ins', shape', dt'⟩)
    (ns : s.nnext < 2^64) (nt : s'.nnext < 2^64)
    (hs : s.next < 2^64) (ht : s'.next < 2^64) :
    opOut s out p ins =
        okW (NativeRoles.createZero s ⟨p, ins, shape, dt⟩) status0 [u64Write b off s.next] ∧
      opOut s' out' p' ins' =
        okW (NativeRoles.createZero s' ⟨p', ins', shape', dt'⟩) status0 [u64Write (R.a b) off s'.next] ∧
      Live NR R NodeRel ObjRel (fun a => a = s.next ∨ H a)
        (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s ⟨p, ins, shape, dt⟩)
        (NativeRoles.createZero s' ⟨p', ins', shape', dt'⟩) :=
  ⟨NativeRoles.opOut_node_zero s out b off p ins inputs shape dt ho hi hinfer,
    NativeRoles.opOut_node_zero s' out' (R.a b) off p' ins' inputs' shape' dt' ho' hi' hinfer',
    h.createZero _ _ hn ns nt hs ht⟩

end Live
end Host.Mlx.Ffi.NativeRoles
