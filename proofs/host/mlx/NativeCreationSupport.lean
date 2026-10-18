import host.mlx.NativeProducerSupport
import host.mlx.OrdinaryConcatNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem Live.obj_absent_at_or_above {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s') (a : Nat) (future : s.next ≤ a) : s.obj? a = none := by
  cases read : s.obj? a with
  | none => rfl
  | some obj => have bound := h.sourceObjsBound a obj read; omega

theorem ProducerSupport.setArr {roots H N : Nat → Prop} {s : St}
    (support : ProducerSupport roots H N s) (slot node : Nat) :
    ProducerSupport roots H N (s.setArr slot node).2 := by
  apply support.frame
  · cases hzero : Nat.beq slot 0 <;> simp [St.setArr,hzero]
  · cases hzero : Nat.beq slot 0 <;> simp [St.setArr,hzero]

theorem ProducerSupport.setArr_zero {roots H N : Nat → Prop} {s : St}
    (support : ProducerSupport roots H N s) (node : Nat) (absent : s.obj? s.next = none) :
    ProducerSupport roots (fun a => a = s.next ∨ H a) N (s.setArr 0 node).2 :=
  (support.growArrayHandle s.next absent).setArr 0 node

/-- The null-slot allocation used by ordinary native primitives preserves
source graph/vector/trace closure while adding exactly its new producer. -/
theorem ProducerSupport.createZero {roots H N : Nat → Prop} {s : St}
    (support : ProducerSupport roots H N s) (node : Node) (inputs : listSupport N node.ins)
    (absent : s.obj? s.next = none) (nodesBound : s.nnext < 2^64) :
    ProducerSupport roots (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i)
      (NativeRoles.createZero s node) :=
  (support.addNode node inputs nodesBound).setArr_zero s.nnext absent

theorem Live.createZero_supported {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel NodeRel' : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {roots H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s') (support : ProducerSupport roots H N s)
    (node node' : Node) (inputs : listSupport N node.ins)
    (created : NodeRel' s.nnext node node')
    (frame : ∀ i, i ≠ s.nnext → ∀ x y, NodeRel i x y → NodeRel' i x y)
    (ns : s.nnext < 2^64) (nt : s'.nnext < 2^64) (hs : s.next < 2^64) (ht : s'.next < 2^64) :
    Live NR R NodeRel' ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
      (NativeRoles.createZero s node) (NativeRoles.createZero s' node') ∧
    ProducerSupport roots (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i)
      (NativeRoles.createZero s node) :=
  ⟨h.createZeroRoles node node' created frame ns nt hs ht,
    support.createZero node inputs (h.obj_absent_at_or_above s.next (Nat.le_refl _)) ns⟩

end Host.Mlx.Ffi.NativeRoles
