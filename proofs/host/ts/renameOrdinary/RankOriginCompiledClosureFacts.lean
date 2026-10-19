import host.ts.renameOrdinary.RankOriginInitializedCompiledVector
import host.load.RuntimeClosureApplyBridge

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.CompiledClosureFacts
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open NamespacedDecode ClosureApplyBridge

noncomputable def entryNotes := InitializedCompiledVector.resultNotes
noncomputable def initializedNotes (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :=
  entryNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
    control fnRole thisRole saved caller) caller
noncomputable def thisRole : Annotated.Value :=
  callReceiverNote CompiledArgumentEntry.From64.Span64.Block78.sourceMode
    (.obj CompiledArgumentEntry.From64.Span64.Block77.sourceAddress)

theorem source_entry : Vector2336.output = P.RestStream.micro0.micro23.s37 := by host_kernel_rfl

theorem source_server : Vector2336.nextServer = Before.Block2337.initialServer := by host_kernel_rfl

theorem current_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (entryNotes notes caller).runtime.control = returnNote (.handle 29376) := by host_kernel_rfl

theorem current_this (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (entryNotes notes caller).runtime.cells.cells After.Block2377.sourceAddress = some thisRole := by
  host_kernel_rfl

theorem current_constructor (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole receiverRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :
    (initializedNotes ic is control fnRole receiverRole saved caller).captures.owners After.Block2353.address =
      some InitializedHandleBuffer.constructorMetadata := by
  calc
    _ = (CompiledArgumentInputFacts.entryNotes ic is control fnRole receiverRole saved caller).captures.owners 95 := by
      host_kernel_rfl
    _ = _ := CompiledArgumentInputFacts.current_constructor ic is control fnRole receiverRole saved caller

theorem constructor_code : InitializedHandleBuffer.constructorMetadata.roles 0 =
    some (.literal (.lit After.Block2353.codeLiteral)) := by host_kernel_rfl

theorem constructor_proto : InitializedHandleBuffer.constructorMetadata.roles 1 =
    some (.literal (.lit After.Block2353.protoLiteral)) := by host_kernel_rfl

theorem current_intrinsic (a : Nat) (small : a < 100) : InitializedCompiledVector.live a := by
  unfold InitializedCompiledVector.live InitializedCompiledArgumentFull.live InitializedCompiledArgumentFull.connectedLive
  repeat first | apply CellsLive.grow | apply ClosureLive.grow | apply Or.inl
  rw [InitialRetained.live,InitialClosure.source_address_limit]
  omega

-- These current-entry absence certificates distinguish missing annotations
-- from roles produced by subsequent source execution.
theorem argument_uninitialized : Vector2336.output.heap.get After.Block2380.address = some (.cell none) := by
  host_kernel_rfl

theorem initial_argument_absent : InitialRetained.cells.cells After.Block2380.address = none := by
  have different : After.Block2380.address ≠ Parameter45.address := by decide +kernel
  have outside : ¬ InitialRetained.live After.Block2380.address := by
    rw [InitialRetained.live,InitialClosure.source_address_limit]
    decide +kernel
  simp only [InitialRetained.cells,Notes.write,ite_eq_right different,structuralCells,ite_eq_right outside]

theorem current_argument_absent (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole receiverRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :
    (initializedNotes ic is control fnRole receiverRole saved caller).runtime.cells.cells After.Block2380.address = none := by
  calc
    _ = (InitialRetained.cells.cells After.Block2380.address).map (Annotated.Value.subst LoopVariables.oracleVariables) := by host_kernel_rfl
    _ = none := by rw [initial_argument_absent]; rfl

theorem compiled_seed_candidate_absent : InitialArrayHandles.candidate input PrivateSeed.native PrivateSeed.prototype
    PrivateSeed.brand PrivateSeed.name After.Block2378.sourceAddress = none := by host_kernel_rfl

theorem compiled_seed_absent : PrivateSeed.notes.owners After.Block2378.sourceAddress = none := by
  simp only [PrivateSeed.notes,InitialArrayHandles.notes,compiled_seed_candidate_absent,Option.map_none,ite_self]

theorem compiled_current_object : Vector2336.output.heap.get After.Block2378.sourceAddress =
    some (.obj After.Block2378.sourceObject) := by host_kernel_rfl

theorem compiled_source_value : After.Block2378.sourceValue = .big (Int.ofNat 1354) := by host_kernel_rfl

theorem compiled_source_descriptor : PrivateData Vector2336.output After.Block2378.sourceAddress
    After.Block2378.sourceBrand After.Block2378.sourceName (.big (Int.ofNat 1354)) := by
  refine ⟨After.Block2378.sourceObject,After.Block2378.sourceWritable,After.Block2378.sourceEnumerable,
    compiled_current_object,?_⟩
  simpa only [compiled_source_value] using After.Block2378.source_descriptor

theorem current_initial_live (a : Nat) (alive : InitialRetained.live a) : InitializedCompiledVector.live a := by
  unfold InitializedCompiledVector.live InitializedCompiledArgumentFull.live InitializedCompiledArgumentFull.connectedLive
  repeat first | exact alive | apply CellsLive.grow | apply ClosureLive.grow | apply Or.inl

theorem owner_live : InitializedCompiledVector.live After.Block2378.sourceAddress :=
  current_initial_live _ (by rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel)

theorem brand_live : InitializedCompiledVector.live After.Block2378.sourceBrand :=
  current_initial_live _ (by rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel)

def compiledRole : Annotated.Value := .handle 1354

theorem current_compiled (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole receiverRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :
    (initializedNotes ic is control fnRole receiverRole saved caller).privates.owners After.Block2378.sourceAddress =
      some ⟨After.Block2378.sourceBrand,After.Block2378.sourceName,compiledRole⟩ := by
  host_kernel_rfl

end Host.Load.Run.Full.Ordinary.RankOrigin.CompiledClosureFacts
