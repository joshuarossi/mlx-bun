import host.ts.renameOrdinary.RankOriginInitializedCacheSliceReady
import host.load.RuntimeOracleConvolutionSliceFacts

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheSlice
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedOracleConvolutionBatch
open InitializedCacheWeightRank (identity_budget)

def live28 := InitializedCacheSliceReady.live28
noncomputable def normalizedRoles := nodeShapeRoles InitializedCacheConcat.roles Slice1086.Normalized.producer Slice1086.Normalized.inputSizes
noncomputable def roles := sliceOutputRoles Slice1086.Normalized.kind normalizedRoles Slice1086.Normalized.input.ffi.mlx.nnext
  Slice1086.Normalized.producer (constantShape Slice1086.Normalized.first) (constantShape Slice1086.Normalized.last)
  (constantShape (List.replicate Slice1086.Normalized.inputSizes.length 1))
  (constantShape (sliceExtents Slice1086.Normalized.first Slice1086.Normalized.last))
noncomputable def objects := objectWrite InitializedCacheConcat.objects Slice1086.Normalized.input.ffi.mlx.next .stream
noncomputable def handles (a : Nat) : Prop := a = Slice1086.Normalized.input.ffi.mlx.next ∨ InitializedCacheConcat.handles a
noncomputable def nodes := Slice1086.Normalized.kind.support Slice1086.Normalized.input.ffi.mlx.nnext InitializedCacheConcat.nodes
noncomputable def normalizedNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  RetainedNotes.normalizeShapeBuffer
    (RetainedNotes.normalizeShapeBuffer
      ((sliceReadyNotes notes caller).normalizeShapeBuffer Slice1086.Normalized.start Slice1086.Normalized.first)
      Slice1086.Normalized.stop Slice1086.Normalized.last)
    Slice1086.Normalized.stride (List.replicate Slice1086.Normalized.inputSizes.length 1)
noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  (normalizedNotes notes caller).nativeHandleResult Slice1086.Normalized.out Slice1086.Normalized.input.ffi.mlx.next

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (resultNotes notes caller).publicFields = notes.publicFields := rfl

theorem history_closed : closedLiteralShape (InitializedCacheConcat.roles Slice1086.Normalized.producer).shape = true := by
  host_kernel_rfl

theorem output_handle : Slice1086.Normalized.input.ffi.mlx.next = 29373 := by host_kernel_rfl
theorem output_node : Slice1086.Normalized.input.ffi.mlx.nnext = 22588 := by host_kernel_rfl
theorem output_owned : handles 29373 := Or.inl output_handle.symm
theorem output_shape : (roles 22588).shape = constantShape [1,3,10240] := by host_kernel_rfl
theorem source_array : P.RestStream.micro0.micro10.s87.ffi.mlx.arrs.get 29373 = some 22588 := by host_kernel_rfl

theorem output_buffer (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (resultNotes notes caller).buffers.owners Slice1086.Normalized.out =
      some (handleSlotNotes Slice1086.Normalized.input.ffi.mlx.next) := by
  simp only [resultNotes,RetainedNotes.nativeHandleResult,BufferNotes.write,ite_true]

theorem capacity_roles (producer : Nat) (selected : producer ∈ CacheEntry.producers) :
    roles producer = CacheEntry.capacityRole LoopVariables.capacity := by
  have prior := CacheEntry.producers_bounded producer selected
  have sourceLimit : NativeSeed.native.nnext ≤ Slice1086.Normalized.producer := by decide +kernel
  have freshLimit : NativeSeed.native.nnext ≤ Slice1086.Normalized.input.ffi.mlx.nnext := by decide +kernel
  have sourceDifferent := Nat.ne_of_lt (Nat.lt_of_lt_of_le prior sourceLimit)
  have freshDifferent := Nat.ne_of_lt (Nat.lt_of_lt_of_le prior freshLimit)
  have kind : Slice1086.Normalized.kind = .fresh := by host_kernel_rfl
  simpa only [roles,kind,sliceOutputRoles,normalizedRoles,nodeShapeRoles,nodeWrite,
    ite_eq_right freshDifferent,ite_eq_right sourceDifferent] using InitializedCacheConcat.capacity_roles producer selected

theorem offsets (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree)
    (owner : Nat) (selected : owner ∈ CacheEntry.cacheOwners) :
    (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
      control fnRole thisRole saved caller) caller).publicFields.fields owner chars!"offset" =
        some (.literal (CacheEntry.offsetMeaning LoopVariables.cacheIndex owner)) :=
  InitializedCache.entry_offset_selected ic is owner selected

theorem initialized_slice (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742942 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' roles NativeSeed.boundary
          objects handles nodes [] InitializedCache.hostRelation)
        identity live28 (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro10.s87 result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity live28 P.RestStream.micro0.micro10.s87 result ∧
      ProducerAnnotations ObjectSeed.roots handles nodes
        roles objects ∧
      ProducerSupport ObjectSeed.roots handles nodes P.RestStream.micro0.micro10.s87.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) (numberServer (P.RestStream.micro0.micro10.S87.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1086,run1086,h1086,inventory1086,policy,support,inst1086⟩ :=
    InitializedCacheSliceReady.initialized_slice_ready ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have handleCounter := h1086.native.2.handleMap.head
  change Slice1086.Normalized.input.ffi.mlx.next = s1086.ffi.mlx.next at handleCounter
  have nodeCounter := h1086.native.2.nodeMap.head
  change Slice1086.Normalized.input.ffi.mlx.nnext = s1086.ffi.mlx.nnext at nodeCounter
  have room := identity_budget h1086 (by decide +kernel)
  obtain ⟨result,left,right,post,retained,newPolicy,newSupport,inst1087⟩ := Slice1086.retained_transport
    (sliceReadyNotes notes caller)
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation
    live28 (fun _ => False) [] [] input.trace input.trace s1086 inst1086 h1086 inventory1086
    (fun impossible => impossible) InitializedCacheConvolutionRank.owned_input history_closed
    (nodeCounter ▸ Slice1086.Normalized.source_node_bound) (handleCounter ▸ Slice1086.Normalized.source_native_bound) (by omega)
    ObjectSeed.roots policy (.obj Slice1086.Normalized.address) (.obj 4817) countRole countRole countRole
    count_schema count_schema count_schema (current_control notes caller) (output_selected notes caller)
    startExpressions stopExpressions strideExpressions
    (start_selected notes caller) (stop_selected notes caller) (stride_selected notes caller)
    start_closed stop_closed stride_closed
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,newPolicy,newSupport,inst1087⟩
  have one := runC_cons P.F 0 s1086 result result C' C' C' (h1086.control.isHalt_eq.trans rfl) right rfl
  cases boot : bootL Route.cx Decode.world 2000 with
  | none => simp only [boot,Option.bind_none] at run1086; cases run1086
  | some start =>
    simp only [boot,Option.bind_some] at run1086 ⊢
    exact runC_join P.F (m:=32742941) (n:=1) run1086 one

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheSlice
