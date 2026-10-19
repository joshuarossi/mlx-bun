import host.ts.renameOrdinary.RankOriginInitializedPostConcat
import host.load.RuntimeNamespacedDecodeFree2056Native
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedPostConcatFree
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open NamespacedDecode
noncomputable def live := InitializedPostConcat.live
noncomputable def roles := InitializedConvolutionFree.roles
noncomputable def objects := InitializedConvolutionFree.objects
noncomputable def nodes := InitializedConvolutionFree.nodes
noncomputable def handles (a : Nat) : Prop := InitializedConvolutionFree.handles a ∧ a ≠ Free2056.handle
noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  let current := InitializedPostConcat.resultNotes notes caller
  current.withRuntime {current.runtime with control := returnNote nativeStatusRole}

theorem source_entry : PostConcatCleanup.Region.s77 = Free2056.input := by host_kernel_rfl
theorem source_server : numberServer (PostConcatCleanup.Region.S77.substitute LoopVariables.oracleVariables) =
    Free2056.initialServer := by host_kernel_rfl
theorem current_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (InitializedPostConcat.resultNotes notes caller).runtime.control =
      callNote (.obj Free2056.address) (.obj 4817) [.handle Free2056.handle] := by host_kernel_rfl
theorem input_owned : InitializedConvolutionFree.handles Free2056.handle := by
  rw [free2056_selected]
  refine ⟨Or.inr ⟨Or.inr (Or.inr (Or.inr (Or.inr ?_))), ?_⟩, ?_⟩
  · rw [NativeSeed.handles,NativeSeed.source_next]; decide +kernel
  · decide +kernel
  · decide +kernel

theorem initialized_post_concat_free (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743912 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          roles NativeSeed.boundary objects handles nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace Free2056.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live Free2056.output result ∧
      ProducerAnnotations ObjectSeed.roots handles nodes roles objects ∧
      ProducerSupport ObjectSeed.roots handles nodes Free2056.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) Free2056.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s2056,run2056,h2056,inventory2056,policy,support,inst2056⟩ :=
    InitializedPostConcat.initialized_post_concat ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have handleCounter := h2056.native.2.handleMap.head
  change Free2056.input.ffi.mlx.next = s2056.ffi.mlx.next at handleCounter
  have targetBound : s2056.ffi.mlx.next < 2^64 := by rw [← handleCounter]; decide +kernel
  obtain ⟨result,left,right,post,retained,inst2057,newPolicy,newSupport,_⟩ := Free2056.retained_transport
    (InitializedPostConcat.resultNotes notes caller)
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    roles NativeSeed.boundary objects ObjectSeed.roots InitializedConvolutionFree.handles nodes [] InitializedCache.hostRelation
    live (fun _ => False) [] [] input.trace input.trace s2056
    (source_server ▸ inst2056) (source_entry ▸ h2056) (source_entry ▸ inventory2056) policy
    (fun impossible => impossible) input_owned targetBound (.obj Free2056.address) (.obj 4817) (current_control notes caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,newPolicy,newSupport,inst2057⟩
  have one := runC_cons P.F 0 s2056 result result C' C' C' (h2056.control.isHalt_eq.trans rfl) right rfl
  cases boot : bootL Route.cx Decode.world 2000 with
  | none => simp only [boot,Option.bind_none] at run2056; cases run2056
  | some start =>
    simp only [boot,Option.bind_some] at run2056 ⊢
    exact runC_join P.F (m:=32743911) (n:=1) run2056 one
end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedPostConcatFree
