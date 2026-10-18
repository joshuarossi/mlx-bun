import host.load.RuntimeVectorReadyBatch
import host.ts.renameOrdinary.RankOriginInitializedVectorPrelude

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedConcatEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedVectorPreludeBatch

theorem native_frame : P.RestStream.micro0.micro3.s36.ffi = P.RestStream.micro0.micro2.s50.ffi := by host_kernel_rfl

theorem constructor_selected (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree) :
    (RankShapeRetained.EntryNotes (InitialRetained.notes ic is) control fnRole thisRole saved caller).captures.owners 95 =
      some InitializedHandleBuffer.constructorMetadata := InitializedHandleBuffer.constructor_selected

/-- The original boot reaches the first concat call. Captured builtin roles,
the null output slot and current argument notes are derived along the connected
source prefix; the strong indexed native relation is retained throughout. -/
theorem initialized_concat_entry (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742191 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles ρ ρ C' C')
        (VectorHost.NativeRelation ρ ρ C' C' ObjectSeed.roles NativeSeed.boundary InitializedVector.finalObjects
          InitializedVector.finalHandles NativeSeed.nodes [] InitializedVector.hostRelation)
        identity (readyLive InitializedVector.finalLive) (fun _ => False) [] [] input.trace input.trace
          P.RestStream.micro0.micro3.s36 result ∧
      RetainedInventory (readyNotes (RankShapeRetained.EntryNotes (InitialRetained.notes ic is)
        control fnRole thisRole saved caller) caller) ρ ρ C' C' identity (readyLive InitializedVector.finalLive)
          P.RestStream.micro0.micro3.s36 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedVector.finalHandles NativeSeed.nodes ObjectSeed.roles InitializedVector.finalObjects ∧
      ProducerSupport ObjectSeed.roots InitializedVector.finalHandles NativeSeed.nodes P.RestStream.micro0.micro3.s36.ffi.mlx ∧
      Inst ρ (numberServer P.RestStream.micro0.micro3.S36) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s250,run250,h250,inventory250,policy,support,inst250⟩ :=
    InitializedVector.initialized_vector ρ C table answers
  have fresh := h250.heap.fresh 0
  have counter : P.RestStream.micro0.micro2.s50.next = s250.next := by
    simpa only [Nat.add_zero,identity,id_eq] using fresh
  have budget : s250.next+32 ≤ 2^64 := counter ▸ InitializedVectorPrelude.source_bound
  have intrinsic (a : Nat) (small : a < 100) : InitializedVector.finalLive a :=
    InitializedVectorPrelude.vector_live_grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  obtain ⟨result,run86,h336,inventory336,inst336⟩ := vector_to_concat
    (RankShapeRetained.EntryNotes (InitialRetained.notes ic is) control fnRole thisRole saved caller) caller
    ρ ρ C' C' identity ObjectSeed.roles NativeSeed.boundary InitializedVector.finalObjects InitializedVector.finalHandles
    NativeSeed.nodes [] InitializedVector.hostRelation InitializedVector.finalLive (fun _ => False) [] [] input.trace input.trace
    s250 inst250 h250 inventory250 budget (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (fun impossible => impossible)
    (intrinsic _ (by decide +kernel)) rfl (constructor_selected ic is control fnRole thisRole saved caller)
    (intrinsic _ (by decide +kernel)) rfl
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,h336,inventory336,policy,?_,inst336⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run250; cases run250
    | some start =>
      simp only [boot,Option.bind_some] at run250 ⊢
      exact runC_join P.F (m:=32742105) (n:=86) run250 run86
  · rw [native_frame]
    exact support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedConcatEntry
