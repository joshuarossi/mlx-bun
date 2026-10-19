import host.load.RuntimeNamespacedDecodeConvolutionFacts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConvolution
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open NamespacedDecode NamespacedDecode.ConvolutionCallFacts
open InitializedCacheWeightRank (identity_budget)

noncomputable def live := InitializedCacheConvolutionCall.live
noncomputable def normalizedRoles := nodeShapeRoles
  (nodeShapeRoles InitializedCacheDynamicFree.roles Conv1856.x Conv1856.inputSizes) Conv1856.y Conv1856.weightSizes
noncomputable def roles := nodeWrite normalizedRoles Conv1856.input.ffi.mlx.nnext
  (convRole normalizedRoles Conv1856.parameters Conv1856.x Conv1856.y (constantShape Conv1856.outputSizes))
noncomputable def objects := objectWrite InitializedCacheDynamicFree.objects Conv1856.input.ffi.mlx.next .stream
noncomputable def handles (a : Nat) : Prop := a = Conv1856.input.ffi.mlx.next ∨ InitializedCacheDynamicFree.handles a
noncomputable def nodes (i : Nat) : Prop := i = Conv1856.input.ffi.mlx.nnext ∨ InitializedCacheDynamicFree.nodes i
noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  (inputNotes notes caller).nativeHandleResult Conv1856.out Conv1856.input.ffi.mlx.next

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (resultNotes notes caller).publicFields = notes.publicFields := rfl

theorem input_owned : InitializedCacheDynamicFree.handles Conv1856.hx := by
  refine ⟨Or.inr (Or.inr (Or.inl ?_)), ?_⟩
  · host_kernel_rfl
  · decide +kernel

theorem weight_owned : InitializedCacheDynamicFree.handles Conv1856.hy := by
  have handle : Conv1856.hy = 1365 := by host_kernel_rfl
  have initial : NativeSeed.handles 1365 := by rw [NativeSeed.handles,NativeSeed.source_next]; decide +kernel
  refine ⟨Or.inr (Or.inr (Or.inr (Or.inr ?_))), ?_⟩
  · rw [handle]; exact initial
  · decide +kernel

theorem input_closed : closedLiteralShape (InitializedCacheDynamicFree.roles Conv1856.x).shape = true := by host_kernel_rfl
theorem weight_closed : closedLiteralShape (InitializedCacheDynamicFree.roles Conv1856.y).shape = true := by host_kernel_rfl
theorem output_handle : Conv1856.input.ffi.mlx.next = 29375 := by host_kernel_rfl
theorem output_node : Conv1856.input.ffi.mlx.nnext = 22590 := by host_kernel_rfl
theorem output_owned : handles 29375 := Or.inl output_handle.symm
theorem output_shape : (roles 22590).shape = constantShape [1,1,10240] := by host_kernel_rfl

theorem initialized_convolution (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743712 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          roles NativeSeed.boundary objects handles nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace Conv1856.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live Conv1856.output result ∧
      ProducerAnnotations ObjectSeed.roots handles nodes roles objects ∧
      ProducerSupport ObjectSeed.roots handles nodes Conv1856.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) Conv1856.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1856,run1856,h1856,inventory1856,policy,support,inst1856⟩ :=
    InitializedCacheConvolutionCall.initialized_convolution_call ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have handleCounter := h1856.native.2.handleMap.head
  change Conv1856.input.ffi.mlx.next = s1856.ffi.mlx.next at handleCounter
  have nodeCounter := h1856.native.2.nodeMap.head
  change Conv1856.input.ffi.mlx.nnext = s1856.ffi.mlx.nnext at nodeCounter
  have room := identity_budget h1856 (by decide +kernel)
  obtain ⟨result,left,right,post,retained,newPolicy,newSupport,inst1857⟩ := Conv1856.retained_transport
    (inputNotes notes caller)
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    InitializedCacheDynamicFree.roles NativeSeed.boundary InitializedCacheDynamicFree.objects InitializedCacheDynamicFree.handles InitializedCacheDynamicFree.nodes [] InitializedCache.hostRelation
    live (fun _ => False) [] [] input.trace input.trace s1856 inst1856 h1856 inventory1856
    (fun impossible => impossible) ⟨input_owned,weight_owned,True.intro⟩ input_closed weight_closed
    (nodeCounter ▸ Conv1856.source_node_bound) (handleCounter ▸ Conv1856.source_native_bound) (by omega)
    ObjectSeed.roots policy (.obj Conv1856.address) (.obj 4817) strideRole paddingRole dilationRole groupsRole
    stride_schema padding_schema dilation_schema groups_schema (current_control notes caller) (output_selected notes caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,newPolicy,newSupport,inst1857⟩
  have one := runC_cons P.F 0 s1856 result result C' C' C' (h1856.control.isHalt_eq.trans rfl) right rfl
  cases boot : bootL Route.cx Decode.world 2000 with
  | none => simp only [boot,Option.bind_none] at run1856; cases run1856
  | some start =>
    simp only [boot,Option.bind_some] at run1856 ⊢
    exact runC_join P.F (m:=32743711) (n:=1) run1856 one
end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConvolution
