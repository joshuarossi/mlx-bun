import host.ts.renameOrdinary.RankOriginInitializedConvolutionFreeEntry
import host.load.RuntimeNamespacedDecodeFree1978Native
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedConvolutionFree
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open NamespacedDecode
noncomputable def live := InitializedConvolutionFreeEntry.live
noncomputable def roles := InitializedCacheConvolution.roles
noncomputable def objects := InitializedCacheConvolution.objects
noncomputable def nodes := InitializedCacheConvolution.nodes
noncomputable def handles (a : Nat) : Prop := InitializedCacheConvolution.handles a ∧ a ≠ Free1978.handle
noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  let current := InitializedConvolutionFreeEntry.resultNotes notes caller
  current.withRuntime {current.runtime with control := returnNote nativeStatusRole}

theorem source_entry : PostConvCleanup.Region.s121 = Free1978.input := by
  host_kernel_rfl

theorem source_server : numberServer (PostConvCleanup.Region.S121.substitute LoopVariables.oracleVariables) =
    Free1978.initialServer := by
  host_kernel_rfl

theorem current_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (InitializedConvolutionFreeEntry.resultNotes notes caller).runtime.control =
      callNote (.obj Free1978.address) (.obj 4817) [.handle Free1978.handle] := by
  host_kernel_rfl

theorem input_owned : InitializedCacheConvolution.handles Free1978.handle := by
  refine Or.inr ⟨Or.inr (Or.inr (Or.inl ?_)), ?_⟩
  · host_kernel_rfl
  · decide +kernel

theorem initialized_free (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743834 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          roles NativeSeed.boundary objects handles nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace Free1978.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live Free1978.output result ∧
      ProducerAnnotations ObjectSeed.roots handles nodes roles objects ∧
      ProducerSupport ObjectSeed.roots handles nodes Free1978.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) Free1978.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1978,run1978,h1978,inventory1978,policy,support,inst1978⟩ :=
    InitializedConvolutionFreeEntry.initialized_free_entry ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have handleCounter := h1978.native.2.handleMap.head
  change Free1978.input.ffi.mlx.next = s1978.ffi.mlx.next at handleCounter
  have targetBound : s1978.ffi.mlx.next < 2^64 := by rw [← handleCounter]; decide +kernel
  obtain ⟨result,left,right,post,retained,inst1979,newPolicy,newSupport,_⟩ := Free1978.retained_transport
    (InitializedConvolutionFreeEntry.resultNotes notes caller)
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    roles NativeSeed.boundary objects ObjectSeed.roots InitializedCacheConvolution.handles nodes [] InitializedCache.hostRelation
    live (fun _ => False) [] [] input.trace input.trace s1978
    (source_server ▸ inst1978) (source_entry ▸ h1978) (source_entry ▸ inventory1978) policy
    (fun impossible => impossible) input_owned targetBound (.obj Free1978.address) (.obj 4817) (current_control notes caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,newPolicy,newSupport,inst1979⟩
  have one := runC_cons P.F 0 s1978 result result C' C' C' (h1978.control.isHalt_eq.trans rfl) right rfl
  cases boot : bootL Route.cx Decode.world 2000 with
  | none => simp only [boot,Option.bind_none] at run1978; cases run1978
  | some start =>
    simp only [boot,Option.bind_some] at run1978 ⊢
    exact runC_join P.F (m:=32743833) (n:=1) run1978 one
end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedConvolutionFree
