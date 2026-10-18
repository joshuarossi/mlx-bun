import host.ts.RenameRuntimeRefinement
import host.ts.RenameRuntimeArguments
import host.ts.RenameRuntimeDispatch
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- The empty argument continuation fixes callee/receiver roles once on entry.
Later collection rules retain those roles and accumulate operand annotations. -/
theorem RuntimeInventory.argument_entry {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S} {cells : Notes}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : CellInventory cells ν₀ ν C₀ C R live s₀ s)
    (kind : Nat) (fn this : Val) (rest : List Elem) (env : Env) (frames : List Frame)
    (stack : s₀.stack = .c (.args kind fn this [] rest env)::frames) :
    ∃ control fnRole thisRole tailNotes,
      RuntimeInventory ⟨control,argumentFrameNote false kind fnRole thisRole [] rest env::tailNotes,cells⟩
        ν₀ ν C₀ C R live s₀ s := by
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  obtain ⟨targetFn,targetThis,targetAcc,frameEq,fnRelation,thisRelation,accRelation⟩ := frameRelation.args_view
  cases accRelation
  rw [frameEq] at targetStack
  obtain ⟨fnRole,sourceFn,targetFnRole⟩ := ValueR.annotations fnRelation
  obtain ⟨thisRole,sourceThis,targetThisRole⟩ := ValueR.annotations thisRelation
  obtain ⟨tailNotes,sourceTail,targetTail⟩ := ForestR.annotations (frameList_forest tailRelation)
  obtain ⟨control,sourceControl,targetControl⟩ := TreeR.annotations h.control
  refine ⟨control,fnRole,thisRole,tailNotes,inventory.keyLive,?_,?_⟩
  · refine ⟨sourceControl,?_,inventory.source⟩
    rw [stack,List.map_cons]
    exact .cons (by simpa only [argumentFrame,identity_environment,Bool.false_eq_true,↓reduceIte] using
      (argumentFrameNote_holds (ν:=ν₀) (C:=C₀) (R:=identity) false kind fnRole thisRole [] rest env fn this []
        sourceFn sourceThis .nil)) sourceTail
  · refine ⟨targetControl,?_,inventory.target⟩
    rw [targetStack,List.map_cons]
    exact .cons (argumentFrameNote_holds false kind fnRole thisRole [] rest env targetFn targetThis []
      targetFnRole targetThisRole .nil) targetTail

theorem RuntimeInventory.return_frame {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St S}
    (h : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s) (role : Value) (v₀ v : Val)
    (sourceRole : role.Holds ν₀ C₀ identity v₀) (targetRole : role.Holds ν C R v)
    (sourceControl : t₀.ctl = .ret v₀) (targetControl : t.ctl = .ret v)
    (sourceHeap : t₀.heap = s₀.heap) (targetHeap : t.heap = s.heap)
    (sourceStack : t₀.stack = s₀.stack) (targetStack : t.stack = s.stack) :
    RuntimeInventory (notes.returning role) ν₀ ν C₀ C R live t₀ t := by
  refine ⟨h.keyLive,?_,?_⟩
  · refine ⟨?_,?_,h.source.cells.frame (fun a _ _ => congrArg (fun heap => heap.get (identity.a a)) sourceHeap)⟩
    · rw [sourceControl]
      exact returnNote_holds sourceRole
    · rw [sourceStack]
      exact h.source.stack
  · refine ⟨?_,?_,h.target.cells.frame (fun a _ _ => congrArg (fun heap => heap.get (R.a a)) targetHeap)⟩
    · rw [targetControl]
      exact returnNote_holds targetRole
    · rw [targetStack]
      exact h.target.stack

end Host.Ts.Owned.Annotated
