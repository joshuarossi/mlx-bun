import host.mlx.ReplaySupport
import host.mlx.NativeSupport

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

/-- Graph IDs retained by a compiled native trace, independently of numeric
meanings or handle identities. -/
structure TraceSupport (N : Nat → Prop) (t : Trace) : Prop where
  inputs : listSupport N t.ins
  outputs : listSupport N t.outs
  order : listSupport N t.order

def ObjectSupport (N : Nat → Prop) : Obj → Prop
  | .vec nodes => listSupport N nodes
  | .clo (.compiled _ _ _ traces) => listSupport (TraceSupport N) traces
  | _ => True

/-- Source-side graph support carried alongside indexed native annotations.
Opaque recurrent/weight roots may hide their earlier ancestry; every other
selected node, vector and captured trace retains its producer dependencies. -/
structure ProducerSupport (roots H N : Nat → Prop) (s : St) : Prop where
  objects : ∀ i obj, H i → s.obj? i = some obj → ObjectSupport N obj
  nodes : ∀ i node, N i → s.nodes.get i = some node → ¬ roots i → listSupport N node.ins

private theorem lift_support {α : Type} {P Q : α → Prop} (f : ∀ i, P i → Q i) :
    ∀ xs, listSupport P xs → listSupport Q xs
  | [], _ => True.intro
  | i::is, h => ⟨f i h.1,lift_support f is h.2⟩

theorem TraceSupport.mono {N K : Nat → Prop} {t : Trace} (h : TraceSupport N t)
    (inclusion : ∀ i, N i → K i) : TraceSupport K t :=
  ⟨lift_support inclusion t.ins h.inputs,lift_support inclusion t.outs h.outputs,lift_support inclusion t.order h.order⟩

theorem ObjectSupport.mono {N K : Nat → Prop} {o : Obj} (h : ObjectSupport N o)
    (inclusion : ∀ i, N i → K i) : ObjectSupport K o := by
  cases o with
  | vec nodes => exact lift_support inclusion nodes h
  | clo closure =>
    cases closure with
    | compiled callback payload shapeless traces => exact lift_support (fun _ h => h.mono inclusion) traces h
    | empty => trivial
    | fn callback payload => trivial
  | _ => trivial

theorem ProducerSupport.vector {roots H N : Nat → Prop} {s : St}
    (h : ProducerSupport roots H N s) (i : Nat) (nodes : List Nat)
    (held : H i) (read : s.obj? i = some (.vec nodes)) : listSupport N nodes :=
  h.objects i (.vec nodes) held read

theorem ProducerSupport.compiled {roots H N : Nat → Prop} {s : St}
    (h : ProducerSupport roots H N s) (i callback : Nat) (payload : Arg) (shapeless : Bool) (traces : List Trace)
    (held : H i) (read : s.obj? i = some (.clo (.compiled callback payload shapeless traces))) :
    listSupport (TraceSupport N) traces := h.objects i _ held read

theorem ProducerSupport.single_trace {roots H N : Nat → Prop} {s : St}
    (h : ProducerSupport roots H N s) (i callback : Nat) (payload : Arg) (shapeless : Bool) (trace : Trace)
    (held : H i) (read : s.obj? i = some (.clo (.compiled callback payload shapeless [trace]))) :
    TraceSupport N trace := (h.compiled i callback payload shapeless [trace] held read).1

theorem ProducerSupport.objects_mono {roots H N K : Nat → Prop} {s : St}
    (h : ProducerSupport roots H N s) (inclusion : ∀ i, N i → K i) :
    ∀ i obj, H i → s.obj? i = some obj → ObjectSupport K obj := by
  intro i obj held read
  exact (h.objects i obj held read).mono inclusion

theorem ProducerSupport.onlyHandles {roots H J N : Nat → Prop} {s : St}
    (h : ProducerSupport roots H N s) (inclusion : ∀ i, J i → H i) :
    ProducerSupport roots J N s :=
  ⟨fun i obj held read => h.objects i obj (inclusion i held) read,h.nodes⟩

/-- Allocating an array handle does not create a native object at that handle.
The explicit absent-object fact follows from the native store counter bound. -/
theorem ProducerSupport.growArrayHandle {roots H N : Nat → Prop} {s : St}
    (h : ProducerSupport roots H N s) (a : Nat) (absent : s.obj? a = none) :
    ProducerSupport roots (fun i => i = a ∨ H i) N s := by
  constructor
  · intro i obj held read
    cases held with
    | inl equal => subst i; rw [absent] at read; cases read
    | inr held => exact h.objects i obj held read
  · exact h.nodes

theorem ProducerSupport.frame {roots H N : Nat → Prop} {s t : St}
    (h : ProducerSupport roots H N s) (objects : t.objs = s.objs) (nodes : t.nodes = s.nodes) :
    ProducerSupport roots H N t := by
  constructor
  · intro i obj held read
    apply h.objects i obj held
    change t.objs.get i = some obj at read
    simpa only [St.obj?,objects] using read
  · intro i node held read full
    exact h.nodes i node held (by simpa only [nodes] using read) full

theorem ProducerSupport.setObj {roots H N : Nat → Prop} {s : St}
    (h : ProducerSupport roots H N s) (slot : Nat) (obj : Obj)
    (created : ObjectSupport N obj) (bound : slot < 2^64) :
    ProducerSupport roots H N (s.setObj slot obj) := by
  constructor
  · intro i value held read
    change (s.objs.set slot obj).get i = some value at read
    rw [PTrie.get_set_u64 _ _ _ bound] at read
    by_cases equal : i = slot
    · rw [ite_eq_left equal] at read
      cases read
      exact created
    · rw [ite_eq_right equal] at read
      exact h.objects i value held read
  · exact h.nodes

theorem ProducerSupport.newObj {roots H N : Nat → Prop} {s : St}
    (h : ProducerSupport roots H N s) (obj : Obj) (created : ObjectSupport N obj)
    (bound : s.next < 2^64) :
    ProducerSupport roots (fun i => i = s.next ∨ H i) N (s.newObj obj).2 := by
  constructor
  · intro i value held read
    change (s.objs.set s.next obj).get i = some value at read
    rw [PTrie.get_set_u64 _ _ _ bound] at read
    by_cases equal : i = s.next
    · rw [ite_eq_left equal] at read
      cases read
      exact created
    · rw [ite_eq_right equal] at read
      exact h.objects i value (held.resolve_left equal) read
  · exact h.nodes

theorem ProducerSupport.addNode {roots H N : Nat → Prop} {s : St}
    (h : ProducerSupport roots H N s) (node : Node) (inputs : listSupport N node.ins)
    (bound : s.nnext < 2^64) :
    ProducerSupport roots H (fun i => i = s.nnext ∨ N i) (s.addNode node).2 := by
  let K : Nat → Prop := fun i => i = s.nnext ∨ N i
  have inclusion : ∀ i, N i → K i := fun _ hi => Or.inr hi
  constructor
  · intro i obj held read
    exact (h.objects i obj held read).mono inclusion
  · intro i value held read full
    change (s.nodes.set s.nnext node).get i = some value at read
    rw [PTrie.get_set_u64 _ _ _ bound] at read
    by_cases equal : i = s.nnext
    · rw [ite_eq_left equal] at read
      cases read
      exact lift_support inclusion node.ins inputs
    · rw [ite_eq_right equal] at read
      exact lift_support inclusion value.ins (h.nodes i value (held.resolve_left equal) read full)

end Host.Mlx.Ffi.NativeRoles
