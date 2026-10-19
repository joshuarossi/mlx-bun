import host.load.RuntimePostConcatCleanupCuts
import host.ts.RenamePostConcatCleanup
import host.ts.RenameLoopVariableNamespace
import host.ts.RenameRuntimeSourceCut
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.PostConcatCleanup
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/- Source 2002 evaluates `!operand`. The operand is the original private
expression; negation itself allocates nothing and does not choose a role. -/
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let pre := (← getCurrNamespace) ++ `UnaryEntry
  let state := mkConst ((← getCurrNamespace) ++ `Region.s23)
  let control ← whnf (← mkAppM ``St.ctl #[state])
  let expression ← whnf control.getAppArgs[0]!
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `operand) expression.getAppArgs[1]!
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `env) control.getAppArgs[1]!
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `initialServer)
    (← mkAppM ``numberServer #[← Term.elabTermEnsuringType
      (← `(Region.S23.substitute LoopVariables.oracleVariables)) (mkConst ``SSrv)])
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `nextServer)
    (← mkAppM ``numberServer #[← Term.elabTermEnsuringType
      (← `(Region.S24.substitute LoopVariables.oracleVariables)) (mkConst ``SSrv)])

theorem UnaryEntry.source_control :
    Region.s23.ctl = .ev (.unary .not UnaryEntry.operand) UnaryEntry.env := by host_kernel_rfl
theorem UnaryEntry.source_run (C : CSrv) :
    interpC (step P.F Region.s23).run C = some (Region.s24,C) := by host_kernel_rfl
theorem UnaryEntry.source_step :
    interpS (step P.F Region.s23).run UnaryEntry.initialServer =
      some (Region.s24,UnaryEntry.nextServer) := by host_kernel_rfl

theorem UnaryEntry.retained_transport
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ UnaryEntry.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s23 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s23 s) :
    ∃ result, interpC (step P.F Region.s23).run C₀ = some (Region.s24,C₀) ∧
      interpC (step P.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s24 result ∧
      RetainedInventory (notes.withRuntime (notes.runtime.notDescent UnaryEntry.operand UnaryEntry.env))
        ν₀ ν C₀ C R live Region.s24 result ∧ Inst ν₀ UnaryEntry.nextServer C₀ := by
  obtain ⟨left,right,post,retained⟩ := inventory.not_entry_step h UnaryEntry.operand UnaryEntry.env
    UnaryEntry.source_control
  have source := UnaryEntry.source_run C₀
  have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
  dsimp only at same
  rw [same] at post retained
  exact ⟨_,source,right,post,retained,pure_step_inst P.F ν₀ UnaryEntry.initialServer UnaryEntry.nextServer C₀
    Region.s23 Region.s24 inst UnaryEntry.source_step source⟩

/- The private read returns an object. Every object is truthy, so the saved
logical-not frame returns false and leaves the handle annotation untouched. -/
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let pre := (← getCurrNamespace) ++ `UnaryObject
  let state := mkConst ((← getCurrNamespace) ++ `Region.s27)
  let control ← whnf (← mkAppM ``St.ctl #[state])
  let stack ← whnf (← mkAppM ``St.stack #[state])
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `address)
    (← whnf control.getAppArgs[0]!).getAppArgs[0]!
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `tail) stack.getAppArgs[2]!
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `initialServer)
    (← mkAppM ``numberServer #[← Term.elabTermEnsuringType
      (← `(Region.S27.substitute LoopVariables.oracleVariables)) (mkConst ``SSrv)])
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `nextServer)
    (← mkAppM ``numberServer #[← Term.elabTermEnsuringType
      (← `(Region.S28.substitute LoopVariables.oracleVariables)) (mkConst ``SSrv)])

theorem UnaryObject.source_control : Region.s27.ctl = .ret (.obj UnaryObject.address) := by host_kernel_rfl
theorem UnaryObject.source_frame :
    Region.s27.stack = .e (.unary .not)::UnaryObject.tail := by host_kernel_rfl
theorem UnaryObject.source_output :
    ({Region.s27 with stack := UnaryObject.tail}).ret (.bool false) = Region.s28 := by host_kernel_rfl
theorem UnaryObject.source_run (C : CSrv) :
    interpC (step P.F Region.s27).run C = some (Region.s28,C) := by host_kernel_rfl
theorem UnaryObject.source_step :
    interpS (step P.F Region.s27).run UnaryObject.initialServer =
      some (Region.s28,UnaryObject.nextServer) := by host_kernel_rfl

theorem UnaryObject.retained_transport
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ UnaryObject.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s27 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s27 s) :
    ∃ result, interpC (step P.F Region.s27).run C₀ = some (Region.s28,C₀) ∧
      interpC (step P.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s28 result ∧
      RetainedInventory (notes.withRuntime (notes.runtime.binaryResult (.bool false) notes.runtime.stack.tail))
        ν₀ ν C₀ C R live Region.s28 result ∧ Inst ν₀ UnaryObject.nextServer C₀ := by
  obtain ⟨_,left,right,post,retained⟩ := inventory.not_object_step h UnaryObject.address UnaryObject.tail
    UnaryObject.source_control UnaryObject.source_frame
  rw [UnaryObject.source_output] at left post retained
  have source := UnaryObject.source_run C₀
  have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
  dsimp only at same
  rw [same] at post retained
  exact ⟨_,source,right,post,retained,pure_step_inst P.F ν₀ UnaryObject.initialServer UnaryObject.nextServer C₀
    Region.s27 Region.s28 inst UnaryObject.source_step source⟩

theorem UnaryObject.result : Region.s28.ctl = .ret (.bool false) := by host_kernel_rfl

/- Source 2011 returns null into the saved `if`. Null is false, so the original
else arm runs. -/
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let pre := (← getCurrNamespace) ++ `NullIf
  let state := mkConst ((← getCurrNamespace) ++ `Region.s32)
  let stack ← whnf (← mkAppM ``St.stack #[state])
  let frame ← whnf stack.getAppArgs[1]!
  let test ← whnf frame.getAppArgs[0]!
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `yes) test.getAppArgs[0]!
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `no) test.getAppArgs[1]!
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `env) test.getAppArgs[2]!
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `tail) stack.getAppArgs[2]!
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `initialServer)
    (← mkAppM ``numberServer #[← Term.elabTermEnsuringType
      (← `(Region.S32.substitute LoopVariables.oracleVariables)) (mkConst ``SSrv)])
  Host.Ts.Owned.Parametric.Driver.addData (pre ++ `nextServer)
    (← mkAppM ``numberServer #[← Term.elabTermEnsuringType
      (← `(Region.S33.substitute LoopVariables.oracleVariables)) (mkConst ``SSrv)])

theorem NullIf.source_control : Region.s32.ctl = .ret .null := by host_kernel_rfl
theorem NullIf.source_frame :
    Region.s32.stack = .s (.if_ NullIf.yes NullIf.no NullIf.env)::NullIf.tail := by host_kernel_rfl
theorem NullIf.source_output :
    {Region.s32 with ctl := branchCtl false NullIf.yes NullIf.no NullIf.env,stack := NullIf.tail} =
      Region.s33 := by host_kernel_rfl
theorem NullIf.source_run (C : CSrv) :
    interpC (step P.F Region.s32).run C = some (Region.s33,C) := by host_kernel_rfl
theorem NullIf.source_step :
    interpS (step P.F Region.s32).run NullIf.initialServer =
      some (Region.s33,NullIf.nextServer) := by host_kernel_rfl

theorem NullIf.retained_transport
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ NullIf.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s32 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s32 s)
    (head : Annotated.Tree) (tail : List Annotated.Tree)
    (stackNotes : notes.runtime.stack = head::tail) :
    ∃ result, interpC (step P.F Region.s32).run C₀ = some (Region.s33,C₀) ∧
      interpC (step P.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s33 result ∧
      RetainedInventory (notes.withRuntime ⟨branchControlNote false NullIf.yes NullIf.no NullIf.env,tail,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live Region.s33 result ∧ Inst ν₀ NullIf.nextServer C₀ := by
  obtain ⟨_,left,right,post,retained⟩ := inventory.if_null_step h NullIf.yes NullIf.no NullIf.env NullIf.tail
    head tail NullIf.source_control NullIf.source_frame stackNotes
  rw [NullIf.source_output] at left post retained
  have source := NullIf.source_run C₀
  have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
  dsimp only at same
  rw [same] at post retained
  exact ⟨_,source,right,post,retained,pure_step_inst P.F ν₀ NullIf.initialServer NullIf.nextServer C₀
    Region.s32 Region.s33 inst NullIf.source_step source⟩

open Lean Elab Command in
run_cmd do
  for claim in [
      "theorem wrong_operator : Region.s23.ctl = .ev (.unary .neg UnaryEntry.operand) UnaryEntry.env := by host_kernel_rfl",
      "theorem wrong_object_result : Region.s28.ctl = .ret (.bool true) := by host_kernel_rfl",
      "theorem wrong_object_endpoint : ({Region.s27 with stack := UnaryObject.tail}).ret (.bool false) = Region.s29 := by host_kernel_rfl",
      "theorem wrong_entry_endpoint : Region.s24 = Region.s25 := by host_kernel_rfl",
      "theorem wrong_null_arm : {Region.s32 with ctl := branchCtl true NullIf.yes NullIf.no NullIf.env, stack := NullIf.tail} = Region.s33 := by host_kernel_rfl",
      "theorem wrong_null_endpoint : {Region.s32 with ctl := branchCtl false NullIf.yes NullIf.no NullIf.env, stack := NullIf.tail} = Region.s34 := by host_kernel_rfl"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
    set saved
    unless rejected do throwError "logical-not negative did not reach the intended kernel rejection: {claim}"

end Host.Load.Run.Full.Ordinary.PostConcatCleanup
