import host.ts.RenameRuntimeSeeds
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Fix the nested constructor continuation once at entry. Its object callee
and undefined receiver are structural consequences of the state relation.
The following saved frame and caller tail receive annotations at this cut. -/
theorem RuntimeInventory.argument_pair_entry {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S} {cells : Notes}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : CellInventory cells ν₀ ν C₀ C R live s₀ s)
    (kind : Nat) (fn this : Val) (rest : List Elem) (env : Env)
    (nextKind address : Nat) (nextRest : List Elem) (nextEnv : Env) (saved : Frame) (frames : List Frame)
    (stack : s₀.stack = .c (.args kind fn this [] rest env)::
      .c (.args nextKind (.obj address) .undef [] nextRest nextEnv)::saved::frames) :
    ∃ control fnRole thisRole savedNote tailNotes,
      RuntimeInventory ⟨control,argumentFrameNote false kind fnRole thisRole [] rest env::
        argumentFrameNote false nextKind (.obj address) .undef [] nextRest nextEnv::savedNote::tailNotes,cells⟩
        ν₀ ν C₀ C R live s₀ s := by
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  obtain ⟨targetFn,targetThis,targetAcc,frameEq,fnRelation,thisRelation,accRelation⟩ := frameRelation.args_view
  cases accRelation
  obtain ⟨nextFrame,remaining,nextStack,nextRelation,remainingRelation⟩ := frames_cons_view tailRelation
  obtain ⟨constructor,receiver,constructorArgs,nextEq,constructorRelation,receiverRelation,argsRelation⟩ := nextRelation.args_view
  cases constructorRelation
  cases receiverRelation
  cases argsRelation
  obtain ⟨savedFrame,caller,savedStack,savedRelation,callerRelation⟩ := frames_cons_view remainingRelation
  obtain ⟨fnRole,sourceFn,targetFnRole⟩ := ValueR.annotations fnRelation
  obtain ⟨thisRole,sourceThis,targetThisRole⟩ := ValueR.annotations thisRelation
  obtain ⟨savedNote,sourceSaved,targetSaved⟩ := TreeR.annotations savedRelation
  obtain ⟨tailNotes,sourceTail,targetTail⟩ := ForestR.annotations (frameList_forest callerRelation)
  obtain ⟨control,sourceControl,targetControl⟩ := TreeR.annotations h.control
  refine ⟨control,fnRole,thisRole,savedNote,tailNotes,inventory.keyLive,?_,?_⟩
  · refine ⟨sourceControl,?_,inventory.source⟩
    rw [stack,List.map_cons,List.map_cons,List.map_cons]
    apply ForestHolds.cons
    · simpa only [argumentFrame,identity_environment,Bool.false_eq_true,↓reduceIte] using
        (argumentFrameNote_holds (ν:=ν₀) (C:=C₀) (R:=identity) false kind fnRole thisRole [] rest env fn this []
          sourceFn sourceThis .nil)
    · apply ForestHolds.cons
      · simpa only [argumentFrame,identity_environment,Bool.false_eq_true,↓reduceIte] using
          (argumentFrameNote_holds (ν:=ν₀) (C:=C₀) (R:=identity) false nextKind (.obj address) .undef [] nextRest nextEnv
            (.obj address) .undef [] (.obj address) .undef .nil)
      · exact .cons sourceSaved sourceTail
  · refine ⟨targetControl,?_,inventory.target⟩
    rw [frameEq,nextStack,nextEq,savedStack] at targetStack
    rw [targetStack,List.map_cons,List.map_cons,List.map_cons]
    exact .cons (argumentFrameNote_holds false kind fnRole thisRole [] rest env targetFn targetThis []
      targetFnRole targetThisRole .nil)
      (.cons (argumentFrameNote_holds false nextKind (.obj address) .undef [] nextRest nextEnv
        (.obj (R.a address)) .undef [] (.obj address) .undef .nil) (.cons targetSaved targetTail))
end Host.Ts.Owned.Annotated
