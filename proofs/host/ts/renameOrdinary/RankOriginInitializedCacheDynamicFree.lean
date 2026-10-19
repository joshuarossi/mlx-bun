import host.ts.renameOrdinary.RankOriginInitializedCacheDynamicSliceCleanup
import host.load.RuntimeNamespacedDecodeDynamicFreeNative
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheDynamicFree
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open NamespacedDecode
noncomputable def live := InitializedCacheDynamicSliceCleanup.live
noncomputable def roles := InitializedCacheDynamicSlice.roles
noncomputable def objects := InitializedCacheDynamicSlice.objects
noncomputable def nodes := InitializedCacheDynamicSlice.nodes
noncomputable def handles (a : Nat) : Prop := InitializedCacheDynamicSlice.handles a ∧ a ≠ Free1677.handle
noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  let current := InitializedCacheDynamicSliceCleanup.resultNotes notes caller
  current.withRuntime {current.runtime with control := returnNote nativeStatusRole}

theorem current_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (InitializedCacheDynamicSliceCleanup.resultNotes notes caller).runtime.control =
      callNote (.obj Free1677.address) (.obj 4817) [.handle Free1677.handle] := rfl

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (resultNotes notes caller).publicFields = notes.publicFields := rfl

theorem input_owned : InitializedCacheDynamicSlice.handles Free1677.handle := by
  have same : Free1677.handle = 29373 := by host_kernel_rfl
  rw [same]
  exact Or.inr InitializedCacheSlice.output_owned

theorem initialized_dynamic_free (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743533 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          roles NativeSeed.boundary objects handles nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace Free1677.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live Free1677.output result ∧
      ProducerAnnotations ObjectSeed.roots handles nodes roles objects ∧
      ProducerSupport ObjectSeed.roots handles nodes Free1677.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) Free1677.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1677,run1677,h1677,inventory1677,policy,support,inst1677⟩ :=
    InitializedCacheDynamicSliceCleanup.initialized_dynamic_slice_cleanup ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have handleCounter := h1677.native.2.handleMap.head
  change Free1677.input.ffi.mlx.next = s1677.ffi.mlx.next at handleCounter
  have targetBound : s1677.ffi.mlx.next < 2^64 := by rw [← handleCounter]; decide +kernel
  obtain ⟨result,left,right,post,retained,inst1678,newPolicy,newSupport,_⟩ := Free1677.retained_transport
    (InitializedCacheDynamicSliceCleanup.resultNotes notes caller)
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    roles NativeSeed.boundary objects ObjectSeed.roots InitializedCacheDynamicSlice.handles nodes [] InitializedCache.hostRelation
    live (fun _ => False) [] [] input.trace input.trace s1677 inst1677 h1677 inventory1677 policy
    (fun impossible => impossible) input_owned targetBound (.obj Free1677.address) (.obj 4817) (current_control notes caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,newPolicy,newSupport,inst1678⟩
  have one := runC_cons P.F 0 s1677 result result C' C' C' (h1677.control.isHalt_eq.trans rfl) right rfl
  cases boot : bootL Route.cx Decode.world 2000 with
  | none => simp only [boot,Option.bind_none] at run1677; cases run1677
  | some start =>
    simp only [boot,Option.bind_some] at run1677 ⊢
    exact runC_join P.F (m:=32743532) (n:=1) run1677 one
end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheDynamicFree
