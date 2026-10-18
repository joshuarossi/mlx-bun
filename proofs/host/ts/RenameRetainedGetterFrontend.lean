import host.ts.RenameRetainedGetterBody
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Instantiate the reusable getter-body contract from source metadata. The
batch consumes one checked nine-step block and the current retained field note. -/
elab "host_retained_getter_body " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← mkAppM ``St.ctl #[s]
    let expression ← field control ``Ctl.ev 2 0
    let env ← field control ``Ctl.ev 2 1
    let disposedName ← field expression ``Expr.priv 3 1
    let thisCell ← field (← mkAppM ``lookupEnv #[mkConst ``nThis,env]) ``Option.some 2 1
    let thisValue ← field (← field (← mkAppM ``St.cell? #[s,thisCell]) ``Option.some 2 1) ``Option.some 2 1
    let owner ← field thisValue ``Val.obj 1 0
    let brand ← field (← mkAppM ``lookupEnv #[← mkAppM ``privName #[disposedName],env]) ``Option.some 2 1
    let object ← field (← mkAppM ``St.obj? #[s,owner]) ``Option.some 2 1
    let stack ← mkAppM ``St.stack #[s]
    let ifFrame ← field (← field stack ``List.cons 3 1) ``Frame.s 1 0
    let yes ← field ifFrame ``StmtF.if_ 3 0
    let blockStack ← field stack ``List.cons 3 2
    let blockFrame ← field (← field blockStack ``List.cons 3 1) ``Frame.s 1 0
    let statement ← field (← field blockFrame ``StmtF.block 2 0) ``List.cons 3 1
    let handleExpr ← field (← field statement ``Stmt.ret 1 0) ``Option.some 2 1
    let handleName ← field handleExpr ``Expr.priv 3 1
    let disposed ← field (← mkAppM ``findPriv #[brand,disposedName,← mkAppM ``Obj.priv #[object]]) ``Option.some 2 1
    let handle ← field (← mkAppM ``findPriv #[brand,handleName,← mkAppM ``Obj.priv #[object]]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceEnv",env),
      ("sourceThisCell",thisCell),("sourceOwner",owner),("sourceBrand",brand),("sourceObject",object),
      ("sourceDisposedName",disposedName),("sourceHandleName",handleName),("sourceYes",yes),
      ("sourceTail",← field blockStack ``List.cons 3 2),("sourceValue",← field handle ``PropV.data 3 0),
      ("sourceDisposedWritable",← field disposed ``PropV.data 3 1),("sourceDisposedEnumerable",← field disposed ``PropV.data 3 2),
      ("sourceHandleWritable",← field handle ``PropV.data 3 1),("sourceHandleEnumerable",← field handle ``PropV.data 3 2)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `span) (mkNatLit 9)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .ev (.priv .this {n}.sourceDisposedName false) {n}.sourceEnv"),
    ("source_stack",s!"{n}.input.stack = .s (.if_ {n}.sourceYes none {n}.sourceEnv):: .s (.block [.ret (some (.priv .this {n}.sourceHandleName false))] {n}.sourceEnv):: {n}.sourceTail"),
    ("source_this_lookup",s!"lookupEnv nThis {n}.sourceEnv = some {n}.sourceThisCell"),
    ("source_disposed_lookup",s!"lookupEnv (privName {n}.sourceDisposedName) {n}.sourceEnv = some {n}.sourceBrand"),
    ("source_handle_lookup",s!"lookupEnv (privName {n}.sourceHandleName) {n}.sourceEnv = some {n}.sourceBrand"),
    ("source_this_read",s!"{n}.input.heap.get {n}.sourceThisCell = some (.cell (some (.obj {n}.sourceOwner)))"),
    ("source_object_read",s!"{n}.input.heap.get {n}.sourceOwner = some (.obj {n}.sourceObject)"),
    ("source_kind",s!"{n}.sourceObject.kind = .ordinary"),
    ("source_disposed",s!"findPriv {n}.sourceBrand {n}.sourceDisposedName {n}.sourceObject.priv = some (.data (.bool false) {n}.sourceDisposedWritable {n}.sourceDisposedEnumerable)"),
    ("source_handle",s!"findPriv {n}.sourceBrand {n}.sourceHandleName {n}.sourceObject.priv = some (.data {n}.sourceValue {n}.sourceHandleWritable {n}.sourceHandleEnumerable)"),
    ("source_output",s!"getterBodyOutput {n}.input {n}.sourceEnv {n}.sourceTail {n}.sourceValue = {n}.output"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do fact tag type
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 9 {n}.input C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (role : Annotated.Value) (ifNote blockNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
      (thisNote : notes.runtime.cells.cells {n}.sourceThisCell = some (.obj {n}.sourceOwner))
      (fieldNote : notes.privates.owners {n}.sourceOwner = some ⟨{n}.sourceBrand,{n}.sourceHandleName,role⟩)
      (stackNotes : notes.runtime.stack = ifNote::blockNote::tailNotes) :
      ∃ result, runC {n}.F 9 {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F 9 s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.getterBodyResult {n}.sourceEnv tailNotes {n}.sourceHandleName role))
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,post,retained,_,_,_⟩ := inventory.getter_body_block h {n}.sourceEnv
        {n}.sourceThisCell {n}.sourceOwner {n}.sourceBrand {n}.sourceDisposedName {n}.sourceHandleName {n}.sourceObject
        {n}.sourceValue role {n}.sourceDisposedWritable {n}.sourceDisposedEnumerable {n}.sourceHandleWritable {n}.sourceHandleEnumerable
        {n}.sourceYes {n}.sourceTail ifNote blockNote tailNotes {n}.source_control {n}.source_stack
        {n}.source_this_lookup {n}.source_disposed_lookup {n}.source_handle_lookup {n}.source_this_read
        {n}.source_object_read {n}.source_kind {n}.source_disposed {n}.source_handle thisNote fieldNote stackNotes
      rw [{n}.source_output] at left post retained
      exact ⟨result,left,right,post,retained,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
