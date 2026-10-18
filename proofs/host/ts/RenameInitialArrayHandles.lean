import host.ts.RenamePrivateInventory
import host.mlx.NativeRoles
import host.mlx.NativeIdentitySeed

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.InitialArrayHandles
open Parametric

def objectHandle (native : Host.Mlx.Ffi.St) (prototype brand : Nat) (name : Name) (object : Obj) : Option (Nat × Nat) :=
  match object.kind,object.proto with
  | .ordinary,.obj p =>
    if p = prototype then
      match findPriv brand name object.priv with
      | some (.data (.big (.ofNat handle)) _ _) =>
        match native.arrs.get handle with
        | some node => match native.nodes.get node with
          | some _ => some (handle,node)
          | none => none
        | none => none
      | _ => none
    else none
  | _,_ => none

def candidate {S : Type} (s : St S) (native : Host.Mlx.Ffi.St)
    (prototype brand : Nat) (name : Name) (owner : Nat) : Option (Nat × Nat) :=
  match s.heap.get owner with
  | some (.obj object) => objectHandle native prototype brand name object
  | _ => none

theorem objectHandle_sound (native : Host.Mlx.Ffi.St) (prototype brand : Nat) (name : Name)
    (object : Obj) (handle node : Nat) (selected : objectHandle native prototype brand name object = some (handle,node)) :
    object.kind = .ordinary ∧ object.proto = .obj prototype ∧
      (∃ w e, findPriv brand name object.priv = some (.data (.big (Int.ofNat handle)) w e)) ∧
      native.arrs.get handle = some node ∧ ∃ producingNode, native.nodes.get node = some producingNode := by
  unfold objectHandle at selected
  split at selected <;> try cases selected
  rename_i p kind proto
  split at selected <;> try cases selected
  rename_i same
  subst p
  split at selected <;> try cases selected
  rename_i h w e field
  split at selected <;> try cases selected
  rename_i n array
  split at selected <;> try cases selected
  rename_i producingNode produced
  exact ⟨kind,proto,⟨w,e,field⟩,array,producingNode,produced⟩

theorem candidate_sound {S : Type} (s : St S) (native : Host.Mlx.Ffi.St)
    (prototype brand : Nat) (name : Name) (owner handle node : Nat)
    (selected : candidate s native prototype brand name owner = some (handle,node)) :
    ∃ object w e, s.heap.get owner = some (.obj object) ∧ object.kind = .ordinary ∧
      object.proto = .obj prototype ∧ findPriv brand name object.priv = some (.data (.big (Int.ofNat handle)) w e) ∧
      native.arrs.get handle = some node ∧ ∃ producingNode, native.nodes.get node = some producingNode := by
  unfold candidate at selected
  split at selected <;> try cases selected
  rename_i object read
  obtain ⟨ordinary,proto,⟨w,e,field⟩,array,produced⟩ := objectHandle_sound native prototype brand name object handle node selected
  exact ⟨object,w,e,read,ordinary,proto,field,array,produced⟩

noncomputable def notes {S : Type} (s : St S) (native : Host.Mlx.Ffi.St)
    (live : Nat → Prop) (prototype brand : Nat) (name : Name) : PrivateNotes := by
  classical
  exact ⟨fun owner => if live owner then
    (candidate s native prototype brand name owner).map (fun pair => ⟨brand,name,.handle pair.1⟩) else none⟩

theorem entry {S : Type} (s : St S) (native : Host.Mlx.Ffi.St) (live : Nat → Prop)
    (prototype brand : Nat) (name : Name) (owner handle node : Nat) (alive : live owner)
    (selected : candidate s native prototype brand name owner = some (handle,node)) :
    (notes s native live prototype brand name).owners owner = some ⟨brand,name,.handle handle⟩ := by
  simp only [notes,ite_eq_left alive,selected,Option.map_some]

/-- Every selected handle note retains actual initialized native-array
membership, alongside the ordinary instance and private descriptor evidence. -/
theorem ownership {S : Type} (s : St S) (native : Host.Mlx.Ffi.St) (live : Nat → Prop)
    (prototype brand : Nat) (name : Name) (owner : Nat) (note : PrivateNote)
    (selected : (notes s native live prototype brand name).owners owner = some note) :
    live owner ∧ ∃ handle node object w e,
      note = ⟨brand,name,.handle handle⟩ ∧ s.heap.get owner = some (.obj object) ∧
      object.kind = .ordinary ∧ object.proto = .obj prototype ∧
      findPriv brand name object.priv = some (.data (.big (Int.ofNat handle)) w e) ∧
      native.arrs.get handle = some node ∧ ∃ producingNode, native.nodes.get node = some producingNode := by
  classical
  by_cases alive : live owner
  · simp only [notes,ite_eq_left alive] at selected
    cases found : candidate s native prototype brand name owner with
    | none => simp only [found,Option.map_none] at selected; cases selected
    | some pair =>
      obtain ⟨handle,node⟩ := pair
      simp only [found,Option.map_some,Option.some.injEq] at selected
      obtain ⟨object,w,e,read,ordinary,proto,field,array,produced⟩ := candidate_sound s native prototype brand name owner handle node found
      exact ⟨alive,handle,node,object,w,e,selected.symm,read,ordinary,proto,field,array,produced⟩
  · simp only [notes,ite_eq_right alive] at selected
    cases selected

/-- Actual identity initialization uses the verified owned-array classifier;
an ordinary bigint with the same prototype but no native array is omitted. -/
theorem inventory {S : Type} (s : St S) (native : Host.Mlx.Ffi.St) (live : Nat → Prop)
    (prototype brand : Nat) (name : Name) (brandLive : live brand) (ν₀ ν : Nat → F64) (C₀ C : CSrv) :
    PrivateInventory (notes s native live prototype brand name) ν₀ ν C₀ C identity live s s := by
  have select := ownership s native live prototype brand name
  have held (ρ : Nat → F64) (server : CSrv) (owner : Nat) (note : PrivateNote)
      (selected : (notes s native live prototype brand name).owners owner = some note) :
      note.Holds ρ server identity owner s := by
    obtain ⟨_,handle,node,object,w,e,rfl,read,_,_,field,_⟩ := select owner note selected
    refine ⟨.big (Int.ofNat handle),⟨object,w,e,read,field⟩,?_⟩
    simpa only [Host.Mlx.Ffi.Annotated.Initial.identity_handle] using
      Value.Holds.handle (ν:=ρ) (C:=server) (R:=identity) handle
  refine ⟨?_,held ν₀ C₀,held ν C⟩
  intro owner note selected
  obtain ⟨alive,handle,node,object,w,e,rfl,_⟩ := select owner note selected
  exact ⟨alive,brandLive⟩

end Host.Ts.Owned.Annotated.InitialArrayHandles
