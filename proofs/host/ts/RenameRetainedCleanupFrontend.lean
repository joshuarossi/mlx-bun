import host.ts.RenameRetainedCleanup
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Source-selected nonempty scope entry or normal disposer completion. The
pending completion and pair meanings are moved from current retained notes. -/
elab "host_retained_cleanup " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (←getCurrNamespace) ++ name.getId
  let isScope ←liftTermElabM do
    let f ←Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ←Term.elabTermEnsuringType s stateTy
    let t ←Term.elabTermEnsuringType t stateTy
    let ctl ←whnf (←mkAppM ``St.ctl #[s])
    let stack ←mkAppM ``St.stack #[s]
    let frame ←field stack ``List.cons 3 1
    let statement ←whnf (←field frame ``Frame.s 1 0)
    let scope := statement.isAppOfArity ``StmtF.scope 1
    unless scope || statement.isAppOfArity ``StmtF.dispose 2 do
      throwError "host_retained_cleanup: expected scope or disposal frame"
    let resources ←whnf statement.getAppArgs[0]!
    let pending ←if scope then
      if ctl.isAppOfArity ``Ctl.ret 1 then mkAppM ``Comp.normal #[ctl.getAppArgs[0]!]
      else if ctl.isAppOfArity ``Ctl.abr 1 then mkAppM ``Comp.abrupt #[ctl.getAppArgs[0]!]
      else throwError "host_retained_cleanup: scope requires normal or abrupt completion"
    else do
      unless ctl.isAppOfArity ``Ctl.ret 1 do
        throwError "host_retained_cleanup: throwing disposer requires separate error rule"
      pure statement.getAppArgs[1]!
    if scope then
      unless resources.isAppOfArity ``List.cons 3 do throwError "host_retained_cleanup: expected nonempty scope"
      let pair ←whnf resources.getAppArgs[1]!
      addData (pre ++ `sourceResource) pair.getAppArgs[2]!
      addData (pre ++ `sourceMethod) pair.getAppArgs[3]!
      addData (pre ++ `sourceRest) resources.getAppArgs[2]!
    else addData (pre ++ `sourceReturned) ctl.getAppArgs[0]!
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceResources",resources),("sourcePending",pending),
        ("sourceFrames",←field stack ``List.cons 3 2)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (←mkAppM ``numberServer #[←Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (←mkAppM ``numberServer #[←Term.elabTermEnsuringType next (mkConst ``SSrv)])
    pure scope
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (name type : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{name} : {type} := by host_kernel_rfl")
  fact "source_control" (if isScope then s!"{n}.input.ctl = completionControl {n}.sourcePending" else s!"{n}.input.ctl = .ret {n}.sourceReturned")
  fact "source_stack" (if isScope then s!"{n}.input.stack = .s (.scope (({n}.sourceResource,{n}.sourceMethod)::{n}.sourceRest))::{n}.sourceFrames"
    else s!"{n}.input.stack = .s (.dispose {n}.sourceResources {n}.sourcePending)::{n}.sourceFrames")
  fact "source_run (C : CSrv)" s!"interpC (step {n}.F {n}.input).run C = some ({n}.output,C)"
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  let pending := if isScope then "(cleanupCompletionNote notes.runtime.control)" else "pendingNote"
  let pendingArg := if isScope then "" else "(pendingNote : Annotated.Tree)"
  let stackSchema := if isScope then "cleanupScopeNote pairsNote" else "cleanupDisposeNote pairsNote pendingNote"
  let apply := if isScope then s!"inventory.scope_cleanup_step FR h {n}.sourcePending {n}.sourceResource {n}.sourceMethod {n}.sourceRest {n}.sourceFrames {n}.source_control {n}.source_stack pairsNote tailNotes stackNotes"
    else s!"inventory.dispose_cleanup_step FR h {n}.sourceReturned {n}.sourcePending {n}.sourceResources {n}.sourceFrames {n}.source_control {n}.source_stack pairsNote pendingNote tailNotes stackNotes"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (pairsNote : Annotated.Tree) {pendingArg} (tailNotes : List Annotated.Tree)
      (stackNotes : notes.runtime.stack = {stackSchema}::tailNotes) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.cleanup pairsNote {pending} tailNotes) ν₀ ν C₀ C R live {n}.output result ∧
        result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨targetPending,targetResources,targetFrames,left,right,post,retained⟩ := {apply}
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,cleanupNext_heap _ _ _,cleanupNext_ffi _ _ _,cleanupNext_next _ _ _,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
