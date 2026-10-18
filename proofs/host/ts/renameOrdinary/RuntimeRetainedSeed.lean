import host.ts.renameOrdinary.RuntimeRetainedTen
import host.ts.RenameRuntimeSeeds
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedSeed
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedPrefix

noncomputable def input : St P.F.S := P.RestStream.micro0.micro0.s0
def pointerRole : Annotated.Value := .ptr (.ext 117452) 0
def rankRole : Annotated.Value := .literal (.lit (F64.ofNat 3))
noncomputable def seededCells (cells : Notes) : Notes := (cells.write Source0.address pointerRole).write Source5.address rankRole

theorem source_pointer : Source0.sourceValue = .ptr (.ext 117452) 0 := by host_kernel_rfl
theorem source_rank : input.heap.get Source5.address = some (.cell (some (natV 3))) := by host_kernel_rfl
theorem source_rank_lookup : lookupEnv Source5.sourceName Source0.sourceEnv = some Source5.address := by host_kernel_rfl
theorem pointer_not_rank : Source0.address ≠ Source5.address := by decide +kernel
theorem source_stack : input.stack = .c (.args Source1.sourceKind Source1.sourceFunction Source1.sourceThis []
    Source1.sourceRest Source1.sourceEnv)::Source1.sourceTail := by host_kernel_rfl
theorem pointer_entry (cells : Notes) : (seededCells cells).cells Source0.address = some pointerRole := by
  simp only [seededCells,Notes.write,ite_eq_right pointer_not_rank,ite_true]
theorem rank_entry (cells : Notes) : (seededCells cells).cells Source5.address = some rankRole := by
  simp only [seededCells,Notes.write,ite_true]

/-- Seed the pointer from its actual source cell and the full heap relation.
The rank is the literal result already established by the native rank/shape
prefix. Existing cell meanings survive both annotations. -/
theorem cells_seed (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (cells : Notes) (prior : CellInventory cells ν₀ ν C₀ C R live input s)
    (rank : s.heap.get (R.a Source5.address) = some (.cell (some (natV 3)))) :
    CellInventory (seededCells cells) ν₀ ν C₀ C R live input s := by
  have support := h.controlLive
  change treeSupport live (Encode.ctl Source0.input.ctl) at support
  rw [Source0.source_control] at support
  have pointerLive := env_lookup_live Source0.sourceName Source0.sourceEnv Source0.address support.2.1 Source0.source_lookup
  have rankLive := env_lookup_live Source5.sourceName Source0.sourceEnv Source5.address support.2.1 source_rank_lookup
  have sourcePointer : input.heap.get Source0.address = some (.cell (some (.ptr (.ext 117452) 0))) := by
    have cell := Source0.source_cell
    change input.heap.get Source0.address = some (.cell (some Source0.sourceValue)) at cell
    simpa only [source_pointer] using cell
  obtain ⟨value,targetPointer,valueRelation,_⟩ := h.heap.readCell Source0.address (.ptr (.ext 117452) 0) pointerLive sourcePointer
  cases valueRelation
  have pointerSource : pointerRole.Holds ν₀ C₀ identity (cellValueAt input Source0.address) := by
    simpa only [pointerRole,cellValueAt,sourcePointer,Host.Ts.Ren.mem,Host.Ts.NameMap.mem,id_eq,Annotated.identity] using (Annotated.Value.Holds.ptr (ν:=ν₀) (C:=C₀) (R:=identity) (.ext 117452) 0)
  have pointerTarget : pointerRole.Holds ν C R (cellValueAt s (R.a Source0.address)) := by
    simpa only [pointerRole,cellValueAt,targetPointer] using (Annotated.Value.Holds.ptr (ν:=ν) (C:=C) (R:=R) (.ext 117452) 0)
  have rankSource : rankRole.Holds ν₀ C₀ identity (cellValueAt input Source5.address) := by
    simpa only [rankRole,natV,cellValueAt,source_rank] using
      (Annotated.Value.Holds.literal (ν:=ν₀) (C:=C₀) (R:=identity) (.lit (F64.ofNat 3)) (F64.ofNat 3) rfl)
  have rankTarget : rankRole.Holds ν C R (cellValueAt s (R.a Source5.address)) := by
    simpa only [rankRole,natV,cellValueAt,rank] using
      (Annotated.Value.Holds.literal (ν:=ν) (C:=C) (R:=R) (.lit (F64.ofNat 3)) (F64.ofNat 3) rfl)
  exact (prior.annotate Source0.address pointerRole pointerLive pointerSource pointerTarget).annotate
    Source5.address rankRole rankLive rankSource rankTarget

/-- The caller frame is annotated once from the initial state relation.
All other annotation families are inherited from the reached initialization
cut; no future argument/read/step is an input to this seed. -/
theorem initial_seed (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (cells : Notes) (privates : PrivateNotes) (captures : NativeCaptureNotes) (arrayNotes : ArrayNotes)
    (publics : PublicNotes) (buffers : BufferNotes)
    (cellInventory : CellInventory cells ν₀ ν C₀ C R live input s)
    (privateInventory : PrivateInventory privates ν₀ ν C₀ C R live input s)
    (captureInventory : NativeCaptureInventory captures ν₀ ν C₀ C R live input s)
    (arrayInventory : ArrayInventory arrayNotes ν₀ ν C₀ C R live input s)
    (publicInventory : PublicInventory publics ν₀ ν C₀ C R live input s)
    (bufferInventory : BufferInventory buffers ν₀ ν C₀ C R live input s)
    (rank : s.heap.get (R.a Source5.address) = some (.cell (some (natV 3)))) :
    ∃ (notes : RetainedNotes) (fnRole thisRole : Annotated.Value) (tailNotes : List Annotated.Tree),
      RetainedInventory notes ν₀ ν C₀ C R live input s ∧
      notes.runtime.cells = seededCells cells ∧ notes.captures = captures ∧
      notes.runtime.cells.cells Source0.address = some pointerRole ∧
      notes.runtime.cells.cells Source5.address = some rankRole ∧
      notes.runtime.stack = argumentFrameNote false Source1.sourceKind fnRole thisRole []
        Source1.sourceRest Source1.sourceEnv::tailNotes := by
  have seeded := cells_seed FR R ν₀ ν C₀ C live framed before after old old' s h cells cellInventory rank
  obtain ⟨control,fnRole,thisRole,tailNotes,runtime⟩ := RuntimeInventory.argument_entry h seeded
    Source1.sourceKind Source1.sourceFunction Source1.sourceThis Source1.sourceRest Source1.sourceEnv Source1.sourceTail source_stack
  exact ⟨⟨⟨control,argumentFrameNote false Source1.sourceKind fnRole thisRole [] Source1.sourceRest Source1.sourceEnv::tailNotes,
      seededCells cells⟩,privates,captures,arrayNotes,publics,buffers⟩,
    fnRole,thisRole,tailNotes,⟨runtime,privateInventory,captureInventory,arrayInventory,publicInventory,bufferInventory⟩,
    rfl,rfl,pointer_entry cells,rank_entry cells,rfl⟩
end Host.Load.Run.Full.Ordinary.RetainedSeed
