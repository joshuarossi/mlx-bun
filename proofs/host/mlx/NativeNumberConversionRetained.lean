import host.ts.RenameParametricConversions
import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeArguments

set_option Elab.async false

namespace Host.Ts.Owned.Annotated
open Parametric

/-- Number conversion consumes integer data, independently of native handles.
Rounded numeric integers retain their actual binary64 image; exactness is not
assumed or needed for this direction of conversion. -/
inductive IntegerNumberRole : Value → SymE → Prop where
  | ordinary (integer : Int) : IntegerNumberRole (.ordinaryBig integer) (.lit (F64.ofInt integer))
  | numeric (meaning : SymE) : IntegerNumberRole (.numericInteger meaning) meaning
  | exact (meaning : SymE) : IntegerNumberRole (.exactInteger meaning) meaning

theorem IntegerNumberRole.denote {ν : Nat → F64} {C : CSrv} {R : Ren}
    {role : Value} {meaning : SymE} {integer : Int}
    (schema : IntegerNumberRole role meaning) (held : role.Holds ν C R (.big integer)) :
    NumDenote ν C meaning (.lit (F64.ofInt integer)) := by
  cases schema <;> cases held
  · rfl
  · assumption
  · assumption

theorem IntegerNumberRole.view {ν : Nat → F64} {C : CSrv} {R : Ren}
    {role : Value} {meaning : SymE} {value : Val}
    (schema : IntegerNumberRole role meaning) (held : role.Holds ν C R value) :
    ∃ integer, value = .big integer ∧ NumDenote ν C meaning (.lit (F64.ofInt integer)) := by
  cases schema <;> cases held
  · exact ⟨_,rfl,rfl⟩
  · exact ⟨_,rfl,by assumption⟩
  · exact ⟨_,rfl,by assumption⟩

/-- The current integer note determines the original Number conversion. The
actual binary64 rounding is retained in a literal return note, while all saved
occurrences and the entire native relation stay unchanged. -/
theorem RetainedInventory.number_integer_step (F : Ffi)
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
    ∃ t, interpC (step F s₀).run C₀ = some (s₀.ret (intV integer),C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (s₀.ret (intV integer)) t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.literal meaning),notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live (s₀.ret (intV integer)) t ∧ t.ffi = s.ffi := by
  obtain ⟨sourceRole,targetRole⟩ := inventory.runtime.call_argument_role fnRole thisRole [role]
    (.obj fn) receiver _ control note 0 role rfl
  simp only [control,callArgument,Host.Ts.arg,nthD] at sourceRole
  have sourceMeaning := schema.denote sourceRole
  obtain ⟨targetFunction,targetData,targetThis,targetArgs,targetControl,targetRead,targetKind,_,_,argumentRoles⟩ :=
    h.native_call_view fn function (.num .number) data receiver _ control read kind
  cases argumentRoles with | cons argument rest =>
    cases rest
    simp only [targetControl,callArgument,Host.Ts.arg,nthD] at targetRole
    obtain ⟨targetInteger,targetValue,targetMeaning⟩ := schema.view targetRole
    rw [targetValue] at targetControl
    obtain ⟨left,right,post⟩ := step_number_big_roles F (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      s₀ s h C₀ C fn (R.a fn) receiver targetThis integer targetInteger function targetFunction data targetData
      control targetControl (by simp only [St.obj?,read]) (by simp only [St.obj?,targetRead]) kind targetKind
      ⟨meaning,⟨sourceMeaning,targetMeaning⟩⟩
    exact ⟨_,left,right,post,
      ⟨⟨inventory.runtime.keyLive,
        ⟨returnNote_holds (.literal meaning _ sourceMeaning),inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
        ⟨returnNote_holds (.literal meaning _ targetMeaning),inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩,
      inventory.privates.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      inventory.captures.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      inventory.arrays.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      inventory.publicFields.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl),
      inventory.buffers.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩,rfl⟩

end Host.Ts.Owned.Annotated
