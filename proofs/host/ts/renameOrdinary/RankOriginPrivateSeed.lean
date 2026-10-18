import host.ts.RenameInitialArrayHandles
import host.ts.renameOrdinary.initialClosure.Facts

set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.PrivateSeed
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def classObject : Obj := match input.heap.get 4855 with
  | some (.obj o) => o | _ => ⟨.ordinary,.null,[],[],true⟩
noncomputable def classEnvironment : Env := match classObject.kind with
  | .fn (.klass _ env _ _) => env | _ => []
noncomputable def classMembers : List InstMember := match classObject.kind with
  | .fn (.klass _ _ _ members) => members | _ => []
noncomputable def prototype : Nat := match findProp kPrototype classObject.props with
  | some (.data (.obj p) _ _) => p | _ => 0
noncomputable def brand : Nat := match classMembers with
  | .privField b _ none::_ => b | _ => 0
noncomputable def name : Name := match classMembers with
  | .privField _ n none::_ => n | _ => []
noncomputable def native : Host.Mlx.Ffi.St := input.ffi.mlx
noncomputable def live (a : Nat) : Prop := a < input.next
noncomputable def notes : PrivateNotes := InitialArrayHandles.notes input native live prototype brand name

theorem source_class : input.heap.get 4855 = some (.obj classObject) := by host_kernel_rfl
theorem source_constructor : classObject.kind =
    .fn (.klass (some Sources.Mlx.Array.ast_n20) classEnvironment .null classMembers) := by host_kernel_rfl
theorem source_prototype : findProp kPrototype classObject.props = some (.data (.obj prototype) false false) := by host_kernel_rfl
theorem source_handle_member : classMembers = .privField brand name none::classMembers.tail := by host_kernel_rfl
theorem prototype_value : prototype = 4854 := by host_kernel_rfl
theorem brand_value : brand = 4852 := by host_kernel_rfl
theorem name_value : name = chars!"handle" := by host_kernel_rfl
theorem source_no_null_array : native.arrs.get 0 = none := by host_kernel_rfl
theorem brand_live : live brand := by rw [live,brand_value,InitialClosure.source_address_limit]; decide +kernel

theorem inventory (ν₀ ν : Nat → F64) (C₀ C : CSrv) :
    PrivateInventory notes ν₀ ν C₀ C identity live input input :=
  InitialArrayHandles.inventory input native live prototype brand name brand_live ν₀ ν C₀ C

/-- Every initial owned-handle role carries its native array-producing node.
Class prototype and private name alone never classify an ordinary bigint. -/
theorem ownership (owner : Nat) (note : PrivateNote) (selected : notes.owners owner = some note) :
    live owner ∧ ∃ handle node object w e,
      note = ⟨brand,name,.handle handle⟩ ∧ input.heap.get owner = some (.obj object) ∧
      object.kind = .ordinary ∧ object.proto = .obj prototype ∧
      findPriv brand name object.priv = some (.data (.big (Int.ofNat handle)) w e) ∧
      native.arrs.get handle = some node ∧ ∃ producingNode, native.nodes.get node = some producingNode :=
  InitialArrayHandles.ownership input native live prototype brand name owner note selected

theorem handle_nonzero (owner : Nat) (note : PrivateNote) (selected : notes.owners owner = some note) :
    ∃ handle, note.role = .handle handle ∧ handle ≠ 0 := by
  obtain ⟨_,handle,node,object,w,e,rfl,_,_,_,_,arrRead,_⟩ := ownership owner note selected
  refine ⟨handle,rfl,?_⟩
  intro zero
  rw [zero,source_no_null_array] at arrRead
  cases arrRead

noncomputable def firstNode : Nat := (native.arrs.get 25732).getD 0
noncomputable def secondNode : Nat := (native.arrs.get 29363).getD 0
theorem first_candidate : InitialArrayHandles.candidate input native prototype brand name 2978923 = some (25732,firstNode) := by host_kernel_rfl
theorem second_candidate : InitialArrayHandles.candidate input native prototype brand name 3126165 = some (29363,secondNode) := by host_kernel_rfl
theorem first_native : native.arrs.get 25732 = some firstNode := by host_kernel_rfl
theorem second_native : native.arrs.get 29363 = some secondNode := by host_kernel_rfl

theorem first_entry : notes.owners 2978923 = some ⟨4852,chars!"handle",.handle 25732⟩ := by
  have selected := InitialArrayHandles.entry input native live prototype brand name 2978923 25732 firstNode
    (by rw [live,InitialClosure.source_address_limit]; decide +kernel) first_candidate
  simpa only [notes,brand_value,name_value] using selected
theorem second_entry : notes.owners 3126165 = some ⟨4852,chars!"handle",.handle 29363⟩ := by
  have selected := InitialArrayHandles.entry input native live prototype brand name 3126165 29363 secondNode
    (by rw [live,InitialClosure.source_address_limit]; decide +kernel) second_candidate
  simpa only [notes,brand_value,name_value] using selected

end Host.Load.Run.Full.Ordinary.RankOrigin.PrivateSeed
