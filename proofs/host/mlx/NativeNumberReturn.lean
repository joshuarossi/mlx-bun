import host.mlx.NativeNumberConversionRetained
import host.ts.RenameRetainedGetterReturn
import host.ts.RenameRetainedHeapFrame
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

private theorem one_step (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

/-- The original integer conversion preserves every host field apart from
control. These equations follow from the current call and native function,
without an effect premise about the target execution. -/
theorem RetainedInventory.number_integer_step_framed (F : Ffi)
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (FR : Ren → F.S → F.S → Prop)
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (fn : Nat) (function : Obj) (data : List Val) (receiver : Val) (integer : Int)
    (control : s₀.ctl = .call (.obj fn) receiver [.big integer])
    (read : s₀.heap.get fn = some (.obj function))
    (kind : function.kind = .fn (.native (.num .number) data))
    (meaning : SymE) (role fnRole thisRole : Value) (schema : IntegerNumberRole role meaning)
    (note : notes.runtime.control = callNote fnRole thisRole [role]) :
    ∃ result, interpC (step F s₀).run C₀ = some (s₀.ret (intV integer),C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (s₀.ret (intV integer)) result ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.literal meaning),notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live (s₀.ret (intV integer)) result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next ∧ result.stack = s.stack := by
  obtain ⟨result,left,right,post,retained,ffi⟩ := inventory.number_integer_step F FR h
    fn function data receiver integer control read kind meaning role fnRole thisRole schema note
  obtain ⟨_,targetRole⟩ := inventory.runtime.call_argument_role fnRole thisRole [role]
    (.obj fn) receiver _ control note 0 role rfl
  obtain ⟨targetFunction,targetData,targetThis,targetArgs,targetControl,targetRead,targetKind,_,_,argumentRoles⟩ :=
    h.native_call_view fn function (.num .number) data receiver _ control read kind
  cases argumentRoles with | cons argument rest =>
    cases rest
    simp only [targetControl,callArgument,Host.Ts.arg,nthD] at targetRole
    obtain ⟨targetInteger,targetValue,_⟩ := schema.view targetRole
    rw [targetValue] at targetControl
    have actual : interpC (step F s).run C = some (s.ret (intV targetInteger),C) := by
      rw [step_number_big_eq F s (R.a fn) targetThis targetInteger targetFunction targetData
        targetControl (by simp only [St.obj?,targetRead]) targetKind]
      rfl
    have same := congrArg Prod.fst (Option.some.inj (right.symm.trans actual))
    dsimp only at same
    exact ⟨result,left,right,post,retained,by rw [same]; rfl,ffi,by rw [same]; rfl,by rw [same]; rfl⟩

/-- A native integer result is collected as Number's sole argument, converted
with the interpreter's actual binary64 rounding, and returned to the saved
caller in six original transitions. The heap, native state, counters and all
six retained annotation families survive for arbitrary callers. -/
theorem RetainedInventory.integer_number_return_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (fn : Nat) (function : Obj) (data : List Val) (receiver : Val) (integer : Int)
    (meaning : SymE) (role fnRole thisRole : Value) (schema : IntegerNumberRole role meaning)
    (argEnv bodyEnv : Env) (caller : List Frame)
    (retNote blockNote scopeNote boundaryNote : Tree) (callerNotes : List Tree)
    (control : s₀.ctl = .ret (.big integer))
    (stack : s₀.stack = .c (.args 0 (.obj fn) receiver [] [] argEnv) ::
      .s .ret :: .s (.block [] bodyEnv) :: .s (.scope []) :: .k (.fn .call) :: caller)
    (read : s₀.heap.get fn = some (.obj function))
    (kind : function.kind = .fn (.native (.num .number) data))
    (controlNote : notes.runtime.control = returnNote role)
    (stackNotes : notes.runtime.stack = argumentFrameNote false 0 fnRole thisRole [] [] argEnv ::
      retNote::blockNote::scopeNote::boundaryNote::callerNotes) :
    ∃ result, runC F 6 s₀ C₀ = some ({s₀ with ctl := .ret (intV integer),stack := caller},C₀) ∧
      runC F 6 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        {s₀ with ctl := .ret (intV integer),stack := caller} result ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.literal meaning),callerNotes,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live {s₀ with ctl := .ret (intV integer),stack := caller} result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next := by
  let frames := .s .ret :: .s (.block [] bodyEnv) :: .s (.scope []) :: .k (.fn .call) :: caller
  obtain ⟨value,targetFn,targetThis,targetAcc,targetFrames,left1,right1,h1,runtime1⟩ :=
    inventory.runtime.argument_step F FR notes.runtime ν₀ ν C₀ C R live framed before after old old' s₀ s h
      (.big integer) role fnRole thisRole [] 0 (.obj fn) receiver [] [] argEnv frames
      (retNote::blockNote::scopeNote::boundaryNote::callerNotes) control stack (by decide) controlNote stackNotes
  have pure := PureRuntimeCase.arguments h (.big integer) 0 (.obj fn) receiver [] [] argEnv frames control stack (by decide)
  have effects1 := pure.effects left1 right1
  have retained1 := inventory.pure_step runtime1 pure left1 right1 (.refl C₀) (.refl C)
  obtain ⟨s2,left2,right2,h2,retained2,heap2,ffi2,next2,_⟩ := retained1.number_integer_step_framed F FR h1
    fn function data receiver integer rfl read kind meaning role fnRole thisRole schema rfl
  obtain ⟨result,left4,right4,h4,retained4,heap4,ffi4,next4,_⟩ := retained2.getter_return_block h2
    (intV integer) (.literal meaning) bodyEnv caller retNote blockNote scopeNote boundaryNote callerNotes rfl rfl rfl rfl
  have active : isHalt s₀.ctl = false := by rw [control]; rfl
  have active1 : isHalt (argumentState {s₀ with stack := frames} 0 (.obj fn) receiver [.big integer] [] argEnv).ctl = false := rfl
  exact ⟨result,runC_join F (runC_join F (one_step F _ _ C₀ active left1) (one_step F _ _ C₀ active1 left2)) left4,
    runC_join F (runC_join F (one_step F _ _ C (h.control.isHalt_eq.trans active) right1)
      (one_step F _ _ C (h1.control.isHalt_eq.trans active1) right2)) right4,h4,retained4,
    heap4.trans (heap2.trans effects1.2.heap),ffi4.trans (ffi2.trans effects1.2.native),
    next4.trans (next2.trans effects1.2.next)⟩
end Host.Ts.Owned.Annotated
