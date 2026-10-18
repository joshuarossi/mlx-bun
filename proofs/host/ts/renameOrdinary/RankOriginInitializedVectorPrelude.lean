import host.load.RuntimeVectorPreludeBatch

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedVectorPrelude
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedVectorPreludeBatch

theorem vector_live_grow (a : Nat) (alive : InitialRetained.live a) : InitializedVector.finalLive a := by
  have base := InitializedHandleBuffer.live_grow a alive
  unfold InitializedVector.finalLive InitializedVector.startLive RetainedVectorEntryBatch.endLive
  repeat first | exact base | apply Or.inl

theorem source_bound : P.RestStream.micro0.micro2.s50.next+32 ≤ 2^64 := by decide +kernel
theorem native_frame : P.RestStream.micro0.micro2.s82.ffi = P.RestStream.micro0.micro2.s50.ffi := by host_kernel_rfl

/-- The reached native vector continues through the real outArray call to
source282. Entry cell/argument/native roles all come from initialized_vector;
only its original boot table and consumed rank answers are caller inputs. -/
theorem initialized_prelude (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742137 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles ρ ρ C' C')
        (VectorHost.NativeRelation ρ ρ C' C' ObjectSeed.roles NativeSeed.boundary InitializedVector.finalObjects
          InitializedVector.finalHandles NativeSeed.nodes [] InitializedVector.hostRelation)
        identity (midLive InitializedVector.finalLive) (fun _ => False) [] [] input.trace input.trace
          P.RestStream.micro0.micro2.s82 result ∧
      RetainedInventory (midNotes (RankShapeRetained.EntryNotes (InitialRetained.notes ic is)
        control fnRole thisRole saved caller) caller) ρ ρ C' C' identity (midLive InitializedVector.finalLive)
          P.RestStream.micro0.micro2.s82 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedVector.finalHandles NativeSeed.nodes ObjectSeed.roles InitializedVector.finalObjects ∧
      ProducerSupport ObjectSeed.roots InitializedVector.finalHandles NativeSeed.nodes P.RestStream.micro0.micro2.s82.ffi.mlx ∧
      Inst ρ (numberServer P.RestStream.micro0.micro2.S82) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s250,run250,h250,inventory250,policy,support,inst250⟩ :=
    InitializedVector.initialized_vector ρ C table answers
  have fresh := h250.heap.fresh 0
  have counter : P.RestStream.micro0.micro2.s50.next = s250.next := by
    simpa only [Nat.add_zero,identity,id_eq] using fresh
  have budget : s250.next+32 ≤ 2^64 := counter ▸ source_bound
  have intrinsic (a : Nat) (small : a < 100) : InitializedVector.finalLive a :=
    vector_live_grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  obtain ⟨result,run32,h282,inventory282,inst282⟩ := vector_to_mid
    (RankShapeRetained.EntryNotes (InitialRetained.notes ic is) control fnRole thisRole saved caller) caller
    ρ ρ C' C' identity _ InitializedVector.finalLive (fun _ => False) [] [] input.trace input.trace
    s250 inst250 h250 inventory250 budget (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,h282,inventory282,policy,?_,inst282⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run250; cases run250
    | some start =>
      simp only [boot,Option.bind_some] at run250 ⊢
      exact runC_join P.F (m:=32742105) (n:=32) run250 run32
  · rw [native_frame]
    exact support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedVectorPrelude
