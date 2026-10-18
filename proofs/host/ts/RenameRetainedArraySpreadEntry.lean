import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRuntimeArrayLiteral
import host.ts.RenameParametricExpressionEntry

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def arraySpreadFrameNote (roles : List Value) (rest : List Elem) (env : Env) : Tree :=
  .node "Frame.l" [.node "LitF.spread" [valuesNote roles,.atom (List Elem) rest,environmentNote env]]

theorem arraySpreadFrameNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
    {roles : List Value} {values : List Val} (rest : List Elem) (env : Env)
    (held : ListR (fun role value => role.Holds ν C R value) roles values) :
    (arraySpreadFrameNote roles rest env).Holds ν C R (Encode.frame (.l (.spread values rest (R.env env)))) :=
  .node _ (.cons (.node _ (.cons (valuesNote_holds held) (.cons (.atom (List Elem) rest)
    (.cons (environmentNote_holds ν C R env) .nil)))) .nil)

def RuntimeNotes.arraySpreadEntry (notes : RuntimeNotes) (e : Expr) (rest : List Elem) (env : Env) : RuntimeNotes :=
  {notes with control := expressionNote e env,stack := arraySpreadFrameNote [] rest env::notes.stack}

private theorem RuntimeNotes.Holds.arraySpreadEntry {S : Type} {notes : RuntimeNotes}
    {ν : Nat → F64} {C : CSrv} {R : Ren} {s : St S}
    (held : notes.Holds ν C R s) (e : Expr) (rest : List Elem) (env : Env) :
    (notes.arraySpreadEntry e rest env).Holds ν C R
      ((s.push (.l (.spread [] rest (R.env env)))).go (.ev e (R.env env))) :=
  ⟨expressionNote_holds ν C R e env,.cons (arraySpreadFrameNote_holds rest env .nil) held.stack,held.cells⟩

/-- The original leading spread evaluates its operand with an empty spread
accumulator. The source syntax fixes the continuation, and the unchanged heap
retains all six annotation families. No operand or target result is assumed. -/
theorem RetainedInventory.array_spread_entry_step
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (e : Expr) (rest : List Elem) (env : Env)
    (control : s₀.ctl = .ev (.array (.spread e::rest)) env) :
    interpC (step F s₀).run C₀ = some ((s₀.push (.l (.spread [] rest env))).go (.ev e env),C₀) ∧
    interpC (step F s).run C = some ((s.push (.l (.spread [] rest (R.env env)))).go (.ev e (R.env env)),C) ∧
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      ((s₀.push (.l (.spread [] rest env))).go (.ev e env))
      ((s.push (.l (.spread [] rest (R.env env)))).go (.ev e (R.env env))) ∧
    RetainedInventory (notes.withRuntime (notes.runtime.arraySpreadEntry e rest env)) ν₀ ν C₀ C R live
      ((s₀.push (.l (.spread [] rest env))).go (.ev e env))
      ((s.push (.l (.spread [] rest (R.env env)))).go (.ev e (R.env env))) := by
  obtain ⟨left,right,post⟩ := step_array_spread_entry_from_source F (NumberRoles ν₀ ν C₀ C) FR R
    C₀ C live framed before after old old' s₀ s h e rest env control
  have source := inventory.runtime.source.arraySpreadEntry e rest env
  simp only [identity_environment] at source
  have runtime : RuntimeInventory (notes.runtime.arraySpreadEntry e rest env) ν₀ ν C₀ C R live
      ((s₀.push (.l (.spread [] rest env))).go (.ev e env))
      ((s.push (.l (.spread [] rest (R.env env)))).go (.ev e (R.env env))) :=
    ⟨inventory.runtime.keyLive,source,inventory.runtime.target.arraySpreadEntry e rest env⟩
  exact ⟨left,right,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
