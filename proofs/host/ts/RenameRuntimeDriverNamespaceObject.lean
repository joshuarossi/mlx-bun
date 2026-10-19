import host.ts.RenameRetainedNamespaceObject
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Object exports are fixed by the live initialized namespace cell. The
selected object address is checked against both original source executions. -/
elab "host_retained_namespace_object " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let address ← field (← field (← mkAppM ``St.ctl #[s]) ``Ctl.ret 1 0) ``Val.obj 1 0
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let exports ← field (← mkAppM ``Obj.kind #[object]) ``Kind.ns 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← field (← field stack ``List.cons 3 1) ``Frame.c 1 0
    let name ← field (← field frame ``CallF.member 5 0) ``PKey.str 1 0
    let cell ← field (← mkAppM ``findExport #[name,exports]) ``Option.some 2 1
    let value ← field (← field (← mkAppM ``St.cell? #[s,cell]) ``Option.some 2 1) ``Option.some 2 1
    let callee ← field value ``Val.obj 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceAddress",address),("sourceObject",object),
        ("sourceExports",exports),("sourceName",name),("sourceCell",cell),("sourceCallee",callee),
        ("sourceArgs",← field frame ``CallF.member 5 1),("sourceEnv",← field frame ``CallF.member 5 2),
        ("sourceOptObject",← field frame ``CallF.member 5 3),("sourceOptCall",← field frame ``CallF.member 5 4),
        ("sourceTail",← field stack ``List.cons 3 2)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret (.obj {n}.sourceAddress)"
  fact "source_frame" s!"{n}.input.stack = .c (.member (.str {n}.sourceName) {n}.sourceArgs {n}.sourceEnv {n}.sourceOptObject {n}.sourceOptCall)::{n}.sourceTail"
  fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
  fact "source_kind" s!"{n}.sourceObject.kind = .ns {n}.sourceExports"
  fact "source_export" s!"findExport {n}.sourceName {n}.sourceExports = some {n}.sourceCell"
  fact "source_cell" s!"{n}.input.heap.get {n}.sourceCell = some (.cell (some (.obj {n}.sourceCallee)))"
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
      (stackNotes : notes.runtime.stack = headNote::tailNotes) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.methodResult {n}.sourceAddress {n}.sourceArgs {n}.sourceEnv
          {n}.sourceOptCall (.obj {n}.sourceCallee) tailNotes)) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨frames,left,right,post,retained⟩ := inventory.namespace_object_method_step h
        {n}.sourceAddress {n}.sourceCell {n}.sourceCallee {n}.sourceObject {n}.sourceExports {n}.sourceName
        {n}.sourceArgs {n}.sourceEnv {n}.sourceOptObject {n}.sourceOptCall {n}.sourceTail headNote tailNotes
        {n}.source_control {n}.source_frame {n}.source_heap {n}.source_kind {n}.source_export {n}.source_cell stackNotes
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")
end Host.Ts.Owned.Annotated.Driver
