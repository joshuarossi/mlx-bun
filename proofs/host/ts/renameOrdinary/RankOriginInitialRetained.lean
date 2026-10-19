import host.ts.renameOrdinary.InitialClosure
import host.ts.renameOrdinary.RankShapeRetained
import host.ts.renameOrdinary.TypedCaptureInitialization
import host.ts.renameOrdinary.DriverParameters
import host.ts.RenameStructuralCellSeed
import host.mlx.NativeIdentitySeed
import host.ts.renameOrdinary.RankOriginPrivateSeed

set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitialRetained
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def live (a : Nat) : Prop := a < input.next
noncomputable def cells : Notes := (structuralCells live input).write Parameter45.address (.handle 2)
noncomputable def captures : NativeCaptureNotes := literalCaptures live input
def compiledNote : PrivateNote := ⟨4944,chars!"compiled",.handle 1354⟩
noncomputable def privates : PrivateNotes := PrivateSeed.notes.write 328446 compiledNote

noncomputable def compiledObject : Obj := match input.heap.get 328446 with
  | some (.obj object) => object
  | _ => ⟨.ordinary,.null,[],[],true⟩
noncomputable def compiledWritable : Bool := match findPriv 4944 chars!"compiled" compiledObject.priv with
  | some (.data _ writable _) => writable
  | _ => false
noncomputable def compiledEnumerable : Bool := match findPriv 4944 chars!"compiled" compiledObject.priv with
  | some (.data _ _ enumerable) => enumerable
  | _ => false
def constructorMetadata : NativeCaptureNote := literalNativeNote (.buf .typedCtor) [natV 4,natV 21]
noncomputable def notes (control : Annotated.Tree) (stack : List Annotated.Tree) : RetainedNotes :=
  ⟨⟨control,stack,cells⟩,privates,captures,ArrayNotes.empty,PublicNotes.empty,BufferNotes.empty⟩

theorem source_default_gpu : input.heap.get Parameter45.address = some (.cell (some (.big (Int.ofNat 2)))) := by host_kernel_rfl
theorem source_stream_object : input.ffi.mlx.objs.get 2 = some .stream := by host_kernel_rfl
theorem stream_cell_live : live Parameter45.address := by
  dsimp only [live]
  rw [InitialClosure.source_address_limit]
  decide +kernel

theorem stream_role (ρ : Nat → F64) (C : CSrv) :
    (Annotated.Value.handle 2).Holds ρ C identity (cellValueAt input Parameter45.address) := by
  simpa only [cellValueAt,source_default_gpu,Host.Mlx.Ffi.Annotated.Initial.identity_handle] using
    (Annotated.Value.Holds.handle (ν:=ρ) (C:=C) (R:=identity) 2)

theorem compiled_heap : input.heap.get 328446 = some (.obj compiledObject) := by host_kernel_rfl

theorem compiled_descriptor : findPriv 4944 chars!"compiled" compiledObject.priv =
    some (.data (.big (Int.ofNat 1354)) compiledWritable compiledEnumerable) := by host_kernel_rfl

theorem compiled_source : PrivateData input 328446 4944 chars!"compiled" (.big (Int.ofNat 1354)) :=
  ⟨compiledObject,compiledWritable,compiledEnumerable,compiled_heap,compiled_descriptor⟩

theorem compiled_owner_live : live 328446 := by
  rw [live,InitialClosure.source_address_limit]
  decide +kernel

theorem compiled_brand_live : live 4944 := by
  rw [live,InitialClosure.source_address_limit]
  decide +kernel

theorem compiled_role (ρ : Nat → F64) (C : CSrv) : compiledNote.Holds ρ C identity 328446 input :=
  ⟨.big (Int.ofNat 1354),compiled_source,.handle 1354⟩

-- Classify this actual initialized closure field separately from the array
-- classifier: its source and target are the same boot-reached heap.
theorem private_inventory (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.micro3275.S1.tab.map (SymE.eval ρ)) :
    PrivateInventory privates ρ ρ C C identity live input input :=
  (PrivateSeed.inventory ρ ρ C C).annotate (InitialClosure.identity_table ρ C table).heap
    328446 compiledNote compiled_owner_live compiled_brand_live (compiled_role ρ C) (compiled_role ρ C)

theorem compiled_selected : privates.owners 328446 = some compiledNote := by
  simp only [privates,PrivateNotes.write,ite_true]

theorem cell_inventory (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.micro3275.S1.tab.map (SymE.eval ρ)) :
    CellInventory cells ρ ρ C C identity live input input :=
  (CellInventory.structural_seed (InitialClosure.identity_table ρ C table) ρ ρ C C).annotate
    Parameter45.address (.handle 2) stream_cell_live (stream_role ρ C) (stream_role ρ C)

theorem rank_absent : cells.cells Variable5.address = none := by
  have different : Variable5.address ≠ Parameter45.address := by decide +kernel
  simpa only [cells,Notes.write,ite_eq_right different] using
    structuralCells.uninitialized live initial_rank_uninitialized

theorem pointer_absent : cells.cells PointerBinding48.sourceAddress = none := by
  have different : PointerBinding48.sourceAddress ≠ Parameter45.address := by decide +kernel
  simpa only [cells,Notes.write,ite_eq_right different] using
    structuralCells.uninitialized live initial_pointer_uninitialized

theorem constructor_live : live 90 := by
  dsimp only [live]
  rw [InitialClosure.source_address_limit]
  decide +kernel

theorem constructor_selected : captures.owners 90 = some constructorMetadata :=
  literalCaptures.entry constructor_live initial_int32_heap TypedBuffer.source_kind

theorem constructor_code : constructorMetadata.roles 0 = some (.literal (.lit (F64.ofNat 4))) := rfl
theorem constructor_proto : constructorMetadata.roles 1 = some (.literal (.lit (F64.ofNat 21))) := rfl

theorem capture_inventory (ρ : Nat → F64) (C : CSrv) :
    NativeCaptureInventory captures ρ ρ C C identity live input input :=
  NativeCaptureInventory.literal_seed_same input ρ ρ C C identity live (fun _ _ _ => rfl)

/-- All annotation families are initialized from the actual boot-reached
source. Runtime notes are selected from its proved identity relation; no
post-state role or retained-inventory premise is used. -/
theorem initial_inventory (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.micro3275.S1.tab.map (SymE.eval ρ)) :
    ∃ control stack, RetainedInventory (notes control stack) ρ ρ C C identity live input input := by
  have h := InitialClosure.identity_table ρ C table
  obtain ⟨control,sourceControl,targetControl⟩ := TreeR.annotations h.control
  obtain ⟨stack,sourceStack,targetStack⟩ := ForestR.annotations (frameList_forest h.stack)
  have cellInventory := cell_inventory ρ C table
  refine ⟨control,stack,⟨cellInventory.keyLive,⟨sourceControl,sourceStack,cellInventory.source⟩,
    ⟨targetControl,targetStack,cellInventory.target⟩⟩,private_inventory ρ C table,
    capture_inventory ρ C,ArrayInventory.empty,PublicInventory.empty,BufferInventory.empty⟩

end Host.Load.Run.Full.Ordinary.RankOrigin.InitialRetained
