import host.ts.renameOrdinary.RankOriginInitializedConcat
import host.load.RuntimeConcatConstructorBatch

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedWrapper
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedVectorPreludeBatch RetainedConcatReturnBatch

theorem ready_live_grow (live : Nat → Prop) (a : Nat) (alive : live a) : readyLive live a := by
  unfold readyLive slotLive arrayLive
  repeat first | exact alive | apply Or.inl

theorem native_frame : P.RestStream.micro0.micro4.s9.ffi = P.RestStream.micro0.micro3.s37.ffi := by
  host_kernel_rfl

/-- The real initialized concat output is wrapped by the original constructor.
The current buffer interpretation is consumed by readU64; constructor execution
derives the new instance and its private handle annotation. -/
theorem initialized_wrapper (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742264 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles ρ ρ C' C')
        (VectorHost.NativeRelation ρ ρ C' C' InitializedConcat.roles NativeSeed.boundary
          InitializedConcat.objects InitializedConcat.handles InitializedConcat.nodes [] InitializedVector.hostRelation)
        identity (wrapperLive (readyLive InitializedVector.finalLive)) (fun _ => False) [] [] input.trace input.trace
          P.RestStream.micro0.micro4.s9 result ∧
      RetainedInventory (wrapperNotes (RankShapeRetained.EntryNotes (InitialRetained.notes ic is)
        control fnRole thisRole saved caller) caller)
        ρ ρ C' C' identity (wrapperLive (readyLive InitializedVector.finalLive)) P.RestStream.micro0.micro4.s9 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedConcat.handles InitializedConcat.nodes
        InitializedConcat.roles InitializedConcat.objects ∧
      ProducerSupport ObjectSeed.roots InitializedConcat.handles InitializedConcat.nodes P.RestStream.micro0.micro4.s9.ffi.mlx ∧
      Inst ρ (numberServer P.RestStream.micro0.micro4.S9) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s337,run337,h337,inventory337,policy,support,inst337⟩ :=
    InitializedConcat.initialized_concat ρ C table answers
  have heapCounter := h337.heap.fresh 0
  change P.RestStream.micro0.micro3.s37.next = s337.next+0 at heapCounter
  rw [Nat.add_zero] at heapCounter
  have budget : s337.next+32 ≤ 2^64 := by rw [← heapCounter]; decide +kernel
  have intrinsic (a : Nat) (small : a < 100) : readyLive InitializedVector.finalLive a :=
    ready_live_grow _ a (InitializedVectorPrelude.vector_live_grow a
      (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega))
  obtain ⟨result,right,post,retained,inst409⟩ := concat_to_wrapper
    (RankShapeRetained.EntryNotes (InitialRetained.notes ic is) control fnRole thisRole saved caller) caller
    ρ ρ C' C' identity _ _ (fun _ => False) [] [] input.trace input.trace s337 inst337 h337 inventory337 budget
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,?_,inst409⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run337; cases run337
    | some start =>
      simp only [boot,Option.bind_some] at run337 ⊢
      exact runC_join P.F (m:=32742192) (n:=72) run337 right
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedWrapper
