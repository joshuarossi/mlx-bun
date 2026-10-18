import host.ts.renameOrdinary.RankOriginInitializedCacheConcatEntry
import host.load.RuntimeOracleConcatCases

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedVectorOracleBatch

noncomputable def roles : Nat → GraphNode := nodeWrite InitializedCache.entryRoles OracleConcatCases.Source336.input.ffi.mlx.nnext
  (concatRole InitializedCache.entryRoles OracleConcatCases.Source336.x OracleConcatCases.Source336.y
    OracleConcatCases.Source336.axis (closedShape [1,4,10240]))
noncomputable def objects : Nat → Object :=
  objectWrite InitializedCache.finalObjects OracleConcatCases.Source336.input.ffi.mlx.next .stream
noncomputable def handles (a : Nat) : Prop :=
  a = OracleConcatCases.Source336.input.ffi.mlx.next ∨ InitializedCache.finalHandles a
noncomputable def nodes (i : Nat) : Prop :=
  i = OracleConcatCases.Source336.input.ffi.mlx.nnext ∨ NativeSeed.nodes i

theorem first_shape : (InitializedCache.entryRoles OracleConcatCases.Source336.x).shape = closedShape [1,3,10240] := by host_kernel_rfl
theorem second_shape : (InitializedCache.entryRoles OracleConcatCases.Source336.y).shape = closedShape [1,1,10240] := by host_kernel_rfl
theorem source_axis : OracleConcatCases.Source336.axis = 1 := by host_kernel_rfl

theorem geometry (ν : Nat → F64) :
    ConcatGeometry ν (InitializedCache.entryRoles OracleConcatCases.Source336.x).shape
      (InitializedCache.entryRoles OracleConcatCases.Source336.y).shape (closedShape [1,4,10240]) OracleConcatCases.Source336.axis := by
  rw [first_shape,second_shape,source_axis]
  simpa only [InitialConcat.first_shape,InitialConcat.second_shape,InitialConcat.source_axis] using InitialConcat.geometry ν

theorem vector_owned : InitializedCache.finalHandles OracleConcatCases.Source336.vec := Or.inl (by host_kernel_rfl)
theorem heap_bound : OracleConcatCases.Source336.input.next < 2^64 := by decide +kernel

theorem capacity_roles (producer : Nat) (selected : producer ∈ CacheEntry.producers) :
    roles producer = CacheEntry.capacityRole LoopVariables.capacity := by
  have prior := CacheEntry.producers_bounded producer selected
  have counters : NativeSeed.native.nnext = OracleConcatCases.Source336.input.ffi.mlx.nnext := by host_kernel_rfl
  rw [counters] at prior
  simpa only [roles,nodeWrite,ite_eq_right (Nat.ne_of_lt prior)] using InitializedCache.entry_role_selected producer selected

theorem offsets (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree)
    (owner : Nat) (selected : owner ∈ CacheEntry.cacheOwners) :
    ((readyNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
      control fnRole thisRole saved caller) caller).nativeHandleResult OracleConcatCases.Source336.out
        OracleConcatCases.Source336.input.ffi.mlx.next).publicFields.fields owner chars!"offset" =
      some (.literal (CacheEntry.offsetMeaning LoopVariables.cacheIndex owner)) :=
  InitializedCacheConcatEntry.ready_offsets ic is control fnRole thisRole saved caller owner selected

/-- Actual initialized execution performs concat under the disjoint oracle and
loop meanings, preserving all existing cache annotations. The fresh graph node
and output-slot handle follow from the current owned vector and geometry. -/
theorem initialized_concat (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742192 start C) = some (result,C') ∧
      Parametric.StateR
        (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          roles NativeSeed.boundary objects handles nodes [] InitializedCache.hostRelation)
        identity (readyLive InitializedCache.finalLive) (fun _ => False) [] [] input.trace input.trace
          P.RestStream.micro0.micro3.s37 result ∧
      RetainedInventory ((readyNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller).nativeHandleResult OracleConcatCases.Source336.out OracleConcatCases.Source336.input.ffi.mlx.next)
        (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity (readyLive InitializedCache.finalLive) P.RestStream.micro0.micro3.s37 result ∧
      ProducerAnnotations ObjectSeed.roots handles nodes roles objects ∧
      ProducerSupport ObjectSeed.roots handles nodes P.RestStream.micro0.micro3.s37.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit))
        (numberServer (P.RestStream.micro0.micro3.S37.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s336,run336,h336,inventory336,policy,support,inst336⟩ :=
    InitializedCacheConcatEntry.initialized_concat_entry ρ C limit table answers
  have handleCounter := h336.native.2.handleMap.head
  change OracleConcatCases.Source336.input.ffi.mlx.next = s336.ffi.mlx.next at handleCounter
  have nodeCounter := h336.native.2.nodeMap.head
  change OracleConcatCases.Source336.input.ffi.mlx.nnext = s336.ffi.mlx.nnext at nodeCounter
  have heapCounter := h336.heap.fresh 0
  change OracleConcatCases.Source336.input.next = s336.next+0 at heapCounter
  rw [Nat.add_zero] at heapCounter
  have currentControl :
      (readyNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller) caller).runtime.control =
      callNote (.obj OracleConcatCases.Source336.address) (.obj RetainedVectorPreludeBatch.concatReceiver)
        ((ConcatFamilyHost.arguments OracleConcatCases.Source336.out OracleConcatCases.Source336.vec
          OracleConcatCases.Source336.stream OracleConcatCases.Source336.axisValue).map FixedArgument.role) := by host_kernel_rfl
  have currentBuffer :
      (readyNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller) caller).buffers.owners
        OracleConcatCases.Source336.out = some (handleSlotNotes 0) := by host_kernel_rfl
  obtain ⟨result,left,right,post,retained,newPolicy,newSupport,inst337⟩ := OracleConcatCases.Source336.retained_transport
    (readyNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller) caller)
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    InitializedCache.entryRoles NativeSeed.boundary InitializedCache.finalObjects InitializedCache.finalHandles NativeSeed.nodes [] InitializedCache.hostRelation
    (readyLive InitializedCache.finalLive) (fun _ => False) [] [] input.trace input.trace s336 inst336 h336 inventory336
    (fun impossible => impossible) vector_owned (closedShape [1,4,10240]) (geometry _) (geometry _)
    (nodeCounter ▸ OracleConcatCases.Source336.source_node_bound)
    (handleCounter ▸ OracleConcatCases.Source336.source_native_bound) (heapCounter ▸ heap_bound)
    ObjectSeed.roots policy (.obj OracleConcatCases.Source336.address) (.obj RetainedVectorPreludeBatch.concatReceiver)
    currentControl currentBuffer
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,newPolicy,newSupport,inst337⟩
  have one := runC_cons P.F 0 s336 result result C' C' C' (h336.control.isHalt_eq.trans rfl) right rfl
  cases boot : bootL Route.cx Decode.world 2000 with
  | none => simp only [boot,Option.bind_none] at run336; cases run336
  | some start =>
    simp only [boot,Option.bind_some] at run336 ⊢
    exact runC_join P.F (m:=32742191) (n:=1) run336 one

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConcat
