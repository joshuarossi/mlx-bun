import host.ts.RenameRetainedInventory
import host.ts.RenameBufferCells
import host.ts.RenameParametricShapeSpread
import host.ts.RenamePrivateKindFrame
import host.ts.RenameCaptureKindFrame

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

theorem typed_store_bytes_paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : List Byte} {source target : List Host.Ts.Byte}
    (left : ListR (fun role byte => role.Holds ν₀ C₀ identity byte) roles source)
    (right : ListR (fun role byte => role.Holds ν C R byte) roles target) :
    ListR (Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R) source target := by
  induction left generalizing target with
  | nil => cases right; exact .nil
  | cons head rest ih =>
    cases right with | cons other tail => exact .cons (Byte.paired head other) (ih tail)

theorem typed_store_patch_related {NR : NumV → NumV → Prop} {R : Ren}
    {source target writes₀ writes : List Host.Ts.Byte}
    (old : ListR (Parametric.ByteR NR R) source target)
    (new : ListR (Parametric.ByteR NR R) writes₀ writes) (off : Nat) :
    ListR (Parametric.ByteR NR R)
      (source.take off ++ writes₀ ++ source.drop (off + len writes₀))
      (target.take off ++ writes ++ target.drop (off + len writes)) := by
  have suffix : ListR (Parametric.ByteR NR R)
      (source.drop (off + len writes₀)) (target.drop (off + len writes)) := by
    rw [← new.len_eq]
    exact old.drop _
  exact ((old.take off).append new).append suffix

theorem typed_store_replace_buffer {NR : NumV → NumV → Prop} {R : Ren} {o₀ o : Obj}
    (related : Parametric.ObjectR NR R o₀ o) {bytes₀ bytes : List Host.Ts.Byte}
    (paired : ListR (Parametric.ByteR NR R) bytes₀ bytes) :
    Parametric.ObjectR NR R {o₀ with kind := .buf bytes₀} {o with kind := .buf bytes} := by
  have forest : Parametric.ForestR NR R (bytes₀.map Encode.byte) (bytes.map Encode.byte) := by
    induction paired with
    | nil => exact .nil
    | cons head rest ih => exact .cons (.byte head) ih
  cases related with | node tag fields =>
    cases fields with | cons kind rest =>
      exact .node _ (.cons (.node _ (.cons (.node _ forest) .nil)) rest)

theorem typed_store_put_view {NR : NumV → NumV → Prop} {R : Ren}
    {owner : Nat} {name : Name} {f : Frame}
    (related : Parametric.FrameR NR R (.a (.put none (.prop (.obj owner) (.str name)) .undef)) f) :
    f = .a (.put none (.prop (.obj (R.a owner)) (.str name)) .undef) := by
  obtain ⟨assignment,rfl,fields⟩ := related.a_view
  have tag := fields.tag_eq
  cases assignment <;> simp only [Encode.asgF,treeTag] at tag
  all_goals try contradiction
  case put op target prior =>
    cases fields with | node _ fields =>
      cases fields with | cons hop fields =>
        cases fields with | cons htarget fields =>
          cases fields with | cons hprior fields =>
            cases hop
            cases hprior with | value hprior =>
              cases hprior
              have tag := htarget.tag_eq
              cases target <;> simp only [Encode.target,treeTag] at tag
              all_goals try contradiction
              case prop value key =>
                cases htarget with | node _ fields =>
                  cases fields with | cons hv fields =>
                    cases fields with | cons hk fields =>
                      cases hv with | value hv =>
                        cases hv
                        have keyTag := hk.tag_eq
                        cases key <;> simp only [Encode.key,treeTag] at keyTag
                        all_goals try contradiction
                        case str name' =>
                          cases hk with | node _ fields =>
                            cases fields with | cons same fields => cases same; rfl

/-- A backing-buffer update cannot change an annotated array owner. Both
source kind disjointness and target address disjointness are derived. -/
theorem typed_store_array_frame {S : Type} {notes : ArrayNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    (inventory : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR (NumberRoles ν₀ ν C₀ C) R live framed before after s₀ s)
    (buffer : Nat) (object₀ new₀ new : Obj) (bytes : List Host.Ts.Byte)
    (alive : live buffer) (read : s₀.heap.get buffer = some (.obj object₀)) (kind : object₀.kind = .buf bytes)
    (sourceBound : buffer < 2^64) (targetBound : R.a buffer < 2^64) :
    ArrayInventory notes ν₀ ν C₀ C R live (s₀.setObj buffer new₀) (s.setObj (R.a buffer) new) := by
  have different : ∀ owner roles, notes.owners owner = some roles → owner ≠ buffer := by
    intro owner roles selected same
    obtain ⟨o,values,object,array,_⟩ := inventory.source owner roles selected
    have object : s₀.heap.get owner = some (.obj o) := object
    rw [same,read] at object
    have equal := HObj.obj.inj (Option.some.inj object)
    subst o
    rw [kind] at array
    cases array
  apply inventory.frame (fun _ h => h)
  · intro owner roles selected
    simp only [St.setObj,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right (different owner roles selected)]
  · intro owner roles selected
    have mapped : R.a owner ≠ R.a buffer := fun same => different owner roles selected
      (heap.inj owner buffer (inventory.keyLive owner roles selected) alive same)
    simp only [St.setObj,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right mapped]

end Host.Ts.Owned.Annotated
