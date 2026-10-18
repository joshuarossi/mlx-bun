import host.ts.RenameRuntimeArrayLiteral
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

theorem step_empty_array_eq (F : Ffi) (s : St F.S) (env : Env)
    (control : s.ctl = .ev (.array []) env) :
    step F s = M.pure ((s.alloc (valueArray [])).2.ret (.obj s.next)) := by
  simp only [step,control,evStep,arrayNext,newArray,St.allocObj,retS,valueArray,List.reverse_nil]
  rfl

/-- Empty array syntax creates the fixed empty element inventory directly. -/
theorem RuntimeInventory.array_empty_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (arrays : ArrayNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrays ν₀ ν C₀ C R live s₀ s)
    (env : Env) (control : s₀.ctl = .ev (.array []) env)
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    interpC (step F s₀).run C₀ = some ((s₀.alloc (valueArray [])).2.ret (.obj s₀.next),C₀) ∧
    interpC (step F s).run C = some ((s.alloc (valueArray [])).2.ret (.obj s.next),C) ∧
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live s₀.next) framed before after old old'
      ((s₀.alloc (valueArray [])).2.ret (.obj s₀.next)) ((s.alloc (valueArray [])).2.ret (.obj s.next)) ∧
    RuntimeInventory {notes with control := returnNote (.obj s₀.next)} ν₀ ν C₀ C R (LiveAfter live s₀.next)
      ((s₀.alloc (valueArray [])).2.ret (.obj s₀.next)) ((s.alloc (valueArray [])).2.ret (.obj s.next)) ∧
    ArrayInventory (arrays.write s₀.next []) ν₀ ν C₀ C R (LiveAfter live s₀.next)
      ((s₀.alloc (valueArray [])).2.ret (.obj s₀.next)) ((s.alloc (valueArray [])).2.ret (.obj s.next)) := by
  have targetControl := (h.control_view control).ev_view
  have fresh : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  have cells := inventory.cellInventory.alloc h.heap (valueArray []) (valueArray []) (.obj s₀.next) (.obj s.next) sourceBound targetBound
  refine ⟨?_,?_,?_,?_,?_⟩
  · rw [step_empty_array_eq F s₀ env control]; rfl
  · rw [step_empty_array_eq F s (R.env env) targetControl]; rfl
  · exact h.alloc_valueArray [] [] .nil True.intro prototypeLive prototypeFixed sourceBound targetBound
  · refine ⟨cells.keyLive,⟨returnNote_holds (Value.Holds.obj s₀.next),inventory.source.stack,cells.source⟩,?_⟩
    refine ⟨?_,inventory.target.stack,cells.target⟩
    apply returnNote_holds
    simpa only [fresh] using (Value.Holds.obj (ν:=ν) (C:=C) (R:=R) s₀.next)
  · exact arrayInventory.allocate h.heap [] [] [] .nil .nil True.intro sourceBound targetBound
end Host.Ts.Owned.Annotated
