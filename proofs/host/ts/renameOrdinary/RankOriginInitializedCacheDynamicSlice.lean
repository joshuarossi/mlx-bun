import host.load.RuntimeNamespacedDecodeDynamicSliceFacts

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheDynamicSlice
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open NamespacedDecode NamespacedDecode.DynamicCallFacts
open InitializedCacheWeightRank (identity_budget)

def live := InitializedCacheDynamicCall.live
noncomputable def roles := nodeWrite InitializedCacheSlice.roles Slice1549.input.ffi.mlx.nnext
  (sliceDynamicRole InitializedCacheSlice.roles Slice1549.producer Slice1549.startProducer
    Slice1549.axes (constantShape Slice1549.sizes))
noncomputable def objects := objectWrite InitializedCacheSlice.objects Slice1549.input.ffi.mlx.next .stream
noncomputable def handles (a : Nat) : Prop := a = Slice1549.input.ffi.mlx.next ∨ InitializedCacheSlice.handles a
noncomputable def nodes (i : Nat) : Prop := i = Slice1549.input.ffi.mlx.nnext ∨ InitializedCacheSlice.nodes i
noncomputable def normalizedNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  ((inputNotes notes caller).normalizeShapeBuffer Slice1549.axisBuffer Slice1549.axisIntegers).normalizeShapeBuffer
    Slice1549.sizeBuffer Slice1549.sizes
noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  (normalizedNotes notes caller).nativeHandleResult Slice1549.out Slice1549.input.ffi.mlx.next

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (resultNotes notes caller).publicFields = notes.publicFields := rfl

theorem input_owned : InitializedCacheSlice.handles Slice1549.handle := by
  have same : Slice1549.handle = 29373 := by host_kernel_rfl
  rw [same]
  exact InitializedCacheSlice.output_owned
theorem start_owned : InitializedCacheSlice.handles Slice1549.start := by
  have same : Slice1549.start = 18170 := by host_kernel_rfl
  have initial : NativeSeed.handles 18170 := by rw [NativeSeed.handles,NativeSeed.source_next]; decide +kernel
  rw [same]
  exact Or.inr (Or.inr (Or.inr initial))
theorem output_handle : Slice1549.input.ffi.mlx.next = 29374 := by host_kernel_rfl
theorem output_node : Slice1549.input.ffi.mlx.nnext = 22589 := by host_kernel_rfl
theorem output_owned : handles 29374 := Or.inl output_handle.symm
theorem output_shape : (roles 22589).shape = constantShape [1,3,10240] := by host_kernel_rfl
theorem source_array : DynamicSlice.output.ffi.mlx.arrs.get 29374 = some 22589 := by host_kernel_rfl

theorem capacity_roles (producer : Nat) (selected : producer ∈ CacheEntry.producers) :
    roles producer = CacheEntry.capacityRole LoopVariables.capacity := by
  have prior := CacheEntry.producers_bounded producer selected
  have freshLimit : NativeSeed.native.nnext ≤ Slice1549.input.ffi.mlx.nnext := by decide +kernel
  have different := Nat.ne_of_lt (Nat.lt_of_lt_of_le prior freshLimit)
  simpa only [roles,nodeWrite,ite_eq_right different] using InitializedCacheSlice.capacity_roles producer selected

theorem offsets (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree)
    (owner : Nat) (selected : owner ∈ CacheEntry.cacheOwners) :
    (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
      control fnRole thisRole saved caller) caller).publicFields.fields owner chars!"offset" =
        some (.literal (CacheEntry.offsetMeaning LoopVariables.cacheIndex owner)) :=
  InitializedCache.entry_offset_selected ic is owner selected

theorem initialized_dynamic_slice (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743405 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          roles NativeSeed.boundary objects handles nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace Slice1549.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live Slice1549.output result ∧
      ProducerAnnotations ObjectSeed.roots handles nodes roles objects ∧
      ProducerSupport ObjectSeed.roots handles nodes Slice1549.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) Slice1549.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1549,run1549,h1549,inventory1549,policy,support,inst1549⟩ :=
    InitializedCacheDynamicCall.initialized_dynamic_call ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have handleCounter := h1549.native.2.handleMap.head
  change Slice1549.input.ffi.mlx.next = s1549.ffi.mlx.next at handleCounter
  have nodeCounter := h1549.native.2.nodeMap.head
  change Slice1549.input.ffi.mlx.nnext = s1549.ffi.mlx.nnext at nodeCounter
  have room := identity_budget h1549 (by decide +kernel)
  obtain ⟨result,left,right,post,retained,newPolicy,newSupport,inst1550⟩ := Slice1549.retained_transport
    (inputNotes notes caller)
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    InitializedCacheSlice.roles NativeSeed.boundary InitializedCacheSlice.objects InitializedCacheSlice.handles InitializedCacheSlice.nodes [] InitializedCache.hostRelation
    live (fun _ => False) [] [] input.trace input.trace s1549 inst1549 h1549 inventory1549
    (fun impossible => impossible) input_owned start_owned
    (nodeCounter ▸ Slice1549.source_node_bound) (handleCounter ▸ Slice1549.source_native_bound) (by omega)
    ObjectSeed.roots policy (.obj Slice1549.address) (.obj 4817) axisCount sizeCount
    axis_schema size_schema (current_control notes caller) (output_selected notes caller)
    axisExpressions sizeExpressions (axes_selected notes caller) (sizes_selected notes caller) axes_closed sizes_closed
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,newPolicy,newSupport,inst1550⟩
  have one := runC_cons P.F 0 s1549 result result C' C' C' (h1549.control.isHalt_eq.trans rfl) right rfl
  cases boot : bootL Route.cx Decode.world 2000 with
  | none => simp only [boot,Option.bind_none] at run1549; cases run1549
  | some start =>
    simp only [boot,Option.bind_some] at run1549 ⊢
    exact runC_join P.F (m:=32743404) (n:=1) run1549 one
end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheDynamicSlice
