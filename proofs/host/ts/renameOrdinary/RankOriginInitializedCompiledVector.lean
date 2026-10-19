import host.ts.renameOrdinary.RankOriginCompiledArgumentVectorFacts

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCompiledVector
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open NamespacedDecode CompiledArgumentVectorFacts

noncomputable def live := InitializedCompiledArgumentFull.live
noncomputable def roles := InitializedPostConcatFree.roles
noncomputable def nodes := InitializedPostConcatFree.nodes
noncomputable def objects := objectWrite InitializedPostConcatFree.objects 29376 (.vec [22590,10,11])
noncomputable def handles (a : Nat) : Prop := a = 29376 ∨ InitializedPostConcatFree.handles a
noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  let current := InitializedCompiledArgumentFull.resultNotes notes caller
  current.withRuntime {current.runtime with control := returnNote (.handle 29376)}

/-- The initialized source path constructs the compiled-input native vector
from the handle bytes produced by the preceding 279 TypeScript transitions. -/
theorem initialized_compiled_vector (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32744192 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          roles NativeSeed.boundary objects handles nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace Vector2336.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live Vector2336.output result ∧
      ProducerAnnotations ObjectSeed.roots handles nodes roles objects ∧
      ProducerSupport ObjectSeed.roots handles nodes Vector2336.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) Vector2336.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s2336,run2336,h2336,inventory2336,policy,support,inst2336⟩ :=
    InitializedCompiledArgumentFull.initialized_compiled_arguments ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have handleCounter := h2336.native.2.handleMap.head
  change Vector2336.input.ffi.mlx.next = s2336.ffi.mlx.next at handleCounter
  have targetBound : s2336.ffi.mlx.next < 2^64 := by
    rw [← handleCounter]
    change VectorInputCall.input.ffi.mlx.next < 2^64
    rw [VectorInputCall.source_counter]
    decide +kernel
  obtain ⟨result,left,right,post,retained,inst2337,newPolicy,newSupport⟩ := Vector2336.retained_transport
    (InitializedCompiledArgumentFull.resultNotes notes caller)
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    roles NativeSeed.boundary InitializedPostConcatFree.objects InitializedPostConcatFree.handles nodes [] InitializedCache.hostRelation
    live (fun _ => False) [] [] input.trace input.trace s2336
    (source_server ▸ inst2336) (source_entry ▸ h2336) (source_entry ▸ inventory2336)
    (fun impossible => impossible) owned targetBound ObjectSeed.roots policy
    (.obj 4709) (.obj 4817) (countRole notes caller) (count_schema notes caller)
    (current_control notes caller) (current_buffer notes caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,newPolicy,newSupport,inst2337⟩
  have one := runC_cons P.F 0 s2336 result result C' C' C' (h2336.control.isHalt_eq.trans rfl) right rfl
  cases boot : bootL Route.cx Decode.world 2000 with
  | none => simp only [boot,Option.bind_none] at run2336; cases run2336
  | some start =>
    simp only [boot,Option.bind_some] at run2336 ⊢
    exact runC_join P.F (m:=32744191) (n:=1) run2336 one

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCompiledVector
