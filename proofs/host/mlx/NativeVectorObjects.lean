import host.mlx.ReplayObjects
import host.mlx.NativeSymbol
import host.mlx.NativeInputs

set_option Elab.async false
set_option maxRecDepth 1000000

namespace Host.Mlx.Ffi.Annotated.VectorBuffer
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def bytes : List Nat → List Host.Ts.Byte
  | [] => []
  | h::hs => cellParts .u64 (.big (Int.ofNat h)) 8 0 ++ bytes hs

def fields : List Nat → List Owned.Annotated.Tree
  | [] => []
  | h::hs => slotPartRoles h 8 0 ++ fields hs

def role (handles : List Nat) : Owned.Annotated.Tree := .node "Kind.buf" [.node "List" (fields handles)]

theorem cells (handles : List Nat) : cellsU64 handles.length (bytes handles) = some handles := by
  induction handles with
  | nil => rfl
  | cons h hs ih =>
    change (cellsU64 hs.length (bytes hs)).map (h::·) = some (h::hs)
    rw [ih]
    rfl

theorem handles (b off : Nat) (hs : List Nat) :
    handlesArg (.jsPtr b off (bytes hs)) (.big (Int.ofNat hs.length)) = some hs := by
  cases hs with
  | nil => rfl
  | cons h hs =>
    simp only [handlesArg,argNat_big_nat,List.length_cons]
    exact cells (h::hs)

theorem related {NR : NumV → NumV → Prop} (R : Ren) (hs : List Nat) :
    ListR (Parametric.ByteR NR R) (bytes hs) (bytes (hs.map R.handle)) := by
  induction hs with
  | nil => exact .nil
  | cons h hs ih => exact (Parametric.cellParts_roles (.handle h) .u64 8 0).append ih

private theorem leading {ν : Nat → F64} {C : CSrv} {R : Ren}
    (handle n i : Nat) (rest : List Owned.Annotated.Tree) (bs : List Host.Ts.Byte)
    (h : Owned.Annotated.ForestHolds ν C R (slotPartRoles handle n i ++ rest) (bs.map Encode.byte)) :
    ∃ tail, bs = cellParts .u64 (.big (Int.ofNat (R.handle handle))) n i ++ tail ∧
      Owned.Annotated.ForestHolds ν C R rest (tail.map Encode.byte) := by
  induction n generalizing i bs with
  | zero => exact ⟨bs,rfl,h⟩
  | succ n ih =>
    cases bs with
    | nil => cases h
    | cons b bs =>
      cases h with | cons hb hs =>
        cases hb with | byte hb =>
          cases hb with | part k r j c hc =>
            cases hc
            obtain ⟨tail,he,ht⟩ := ih (i+1) bs hs
            exact ⟨tail,congrArg (Byte.part .u64 (.big (Int.ofNat (R.handle handle))) i :: ·) he,ht⟩

theorem fields_exact {ν : Nat → F64} {C : CSrv} {R : Ren}
    (hs : List Nat) (bs : List Host.Ts.Byte)
    (h : Owned.Annotated.ForestHolds ν C R (fields hs) (bs.map Encode.byte)) :
    bs = bytes (hs.map R.handle) := by
  induction hs generalizing bs with
  | nil => cases bs <;> cases h; rfl
  | cons handle hs ih =>
    obtain ⟨tail,he,ht⟩ := leading handle 8 0 (fields hs) bs h
    rw [he,ih tail ht]
    rfl

private theorem append_fields {ν : Nat → F64} {C : CSrv} {R : Ren}
    {a b : List Owned.Annotated.Tree} {x y : List Owned.Tree}
    (h : Owned.Annotated.ForestHolds ν C R a x) (g : Owned.Annotated.ForestHolds ν C R b y) :
    Owned.Annotated.ForestHolds ν C R (a++b) (x++y) := by
  induction a generalizing x with
  | nil => cases h; exact g
  | cons a as ih => cases h with
    | cons h hs => exact .cons h (ih hs)

theorem annotated (ν : Nat → F64) (C : CSrv) (R : Ren) (hs : List Nat) :
    (role hs).Holds ν C R (Encode.kind (.buf (bytes (hs.map R.handle)))) := by
  refine .node _ (.cons (.node _ ?_) .nil)
  induction hs with
  | nil => exact .nil
  | cons h hs ih =>
    have head : ∀ n i, Owned.Annotated.ForestHolds ν C R (slotPartRoles h n i)
        ((cellParts .u64 (.big (Int.ofNat (R.handle h))) n i).map Encode.byte) := by
      intro n
      induction n with
      | zero => intro i; exact .nil
      | succ n ih => intro i; exact .cons (.byte (.part _ _ _ _ (.handle h))) (ih (i+1))
    simpa only [fields,List.map_cons,bytes,List.map_append] using append_fields (head 8 0) ih

theorem exact_bytes {ν : Nat → F64} {C : CSrv} {R : Ren} {hs : List Nat} {bs : List Host.Ts.Byte}
    (h : (role hs).Holds ν C R (Encode.kind (.buf bs))) : bs = bytes (hs.map R.handle) := by
  cases h with | node tag fs =>
    cases fs with | cons hb fs =>
      cases hb with | node tag hbs => exact fields_exact hs bs hbs

end Host.Mlx.Ffi.Annotated.VectorBuffer

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi.Annotated

theorem call_vector_data (s : St) (p count : Arg) (handles nodes : List Nat)
    (hp : handlesArg p count = some handles) (hn : nodesOf s handles = some nodes) :
    Ffi.call s chars!"mlx_vector_array_new_data" [p,count] =
      ok (s.newObj (.vec nodes)).2 (.big (Int.ofNat s.next)) := by
  have hs : symOf chars!"mlx_vector_array_new_data" = some .vecNewData := by decide +kernel
  unfold Ffi.call
  rw [hs]
  simp only [hp,Option.bind_some,hn]
  rfl

/-- The input handles are resolved through the live arrays. The fresh vector
and every old object retain fixed indexed annotations; no target lookup is a
premise. Tagged argument-buffer bytes are supplied by their occurrence role. -/
theorem Live.vector_data {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {NodeRel : Nat → Node → Node → Prop} {objects : Nat → Annotated.Object}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R NodeRel (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (b off : Nat) (handles nodes : List Nat) (hl : listSupport H handles)
    (hn : Ffi.nodesOf s handles = some nodes) (bs : s.next < 2^64) (bt : s'.next < 2^64) :
    Ffi.call s chars!"mlx_vector_array_new_data"
        [.jsPtr b off (VectorBuffer.bytes handles),.big (Int.ofNat handles.length)] =
      ok (s.newObj (.vec nodes)).2 (.big (Int.ofNat s.next)) ∧
    Ffi.call s' chars!"mlx_vector_array_new_data"
        [.jsPtr (R.a b) off (VectorBuffer.bytes (handles.map R.handle)),.big (Int.ofNat handles.length)] =
      ok (s'.newObj (.vec (nodes.map R.node))).2 (.big (Int.ofNat s'.next)) ∧
    Live (NumberRoles ν₀ ν C₀ C) R NodeRel
      (ObjectRel (objectWrite objects s.next (.vec nodes)) ν₀ ν C₀ C R)
      (fun a => a = s.next ∨ H a) N tail (s.newObj (.vec nodes)).2 (s'.newObj (.vec (nodes.map R.node))).2 ∧
    Host.Ts.Owned.Parametric.TreeR (NumberRoles ν₀ ν C₀ C) R
      (Host.Ts.Owned.Parametric.ret (.big (Int.ofNat s.next)))
      (Host.Ts.Owned.Parametric.ret (.big (Int.ofNat s'.next))) := by
  refine ⟨call_vector_data s _ _ handles nodes (VectorBuffer.handles b off handles) hn,?_,?_,?_⟩
  · exact call_vector_data s' _ _ (handles.map R.handle) (nodes.map R.node)
      (by simpa only [List.length_map] using VectorBuffer.handles (R.a b) off (handles.map R.handle)) (h.nodesOf handles nodes hl hn)
  · exact h.newObjectRoles _ _ (ObjectRel.write_vec objects ν₀ ν C₀ C R s.next nodes)
      (fun _ ne _ _ p => ObjectRel.write_frame ne p) bs bt
  · rw [← h.handleMap.head]
    exact .node _ (.cons (.value (.handle _)) .nil)

end Host.Mlx.Ffi.NativeRoles
