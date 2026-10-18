import host.ts.RenameRetainedGetterCall
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select a complete guarded getter call from current source closure and
ownership metadata. Source extraction proposes data; kernel-checked equations
establish the actual syntax, descriptors, endpoint and unchanged server. -/
elab "host_retained_getter_call " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← mkAppM ``St.ctl #[s]
    let getter ← field (← field control ``Ctl.call 3 0) ``Val.obj 1 0
    let owner ← field (← field control ``Ctl.call 3 1) ``Val.obj 1 0
    let function ← field (← mkAppM ``St.obj? #[s,getter]) ``Option.some 2 1
    let closure ← whnf (← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0)
    let fn ← field closure ``Code.closure 4 0
    let body ← field (← field fn ``Func.mk 7 3) ``Body.block 1 0
    let test ← field body ``List.cons 3 1
    let disposedName ← field (← field test ``Stmt.if_ 3 0) ``Expr.priv 3 1
    let rest ← field body ``List.cons 3 2
    let handleName ← field (← field (← field (← field rest ``List.cons 3 1) ``Stmt.ret 1 0) ``Option.some 2 1) ``Expr.priv 3 1
    let env ← field closure ``Code.closure 4 1
    let brand ← field (← mkAppM ``lookupEnv #[← mkAppM ``privName #[disposedName],env]) ``Option.some 2 1
    let object ← field (← mkAppM ``St.obj? #[s,owner]) ``Option.some 2 1
    let disposed ← field (← mkAppM ``findPriv #[brand,disposedName,← mkAppM ``Obj.priv #[object]]) ``Option.some 2 1
    let handle ← field (← mkAppM ``findPriv #[brand,handleName,← mkAppM ``Obj.priv #[object]]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceGetter",getter),("sourceOwner",owner),
      ("sourceFunction",function),("sourceObject",object),("sourceName",← field fn ``Func.mk 7 0),
      ("sourceEnv",env),("sourceHome",← field closure ``Code.closure 4 3),("sourceDisposedName",disposedName),
      ("sourceHandleName",handleName),("sourceYes",← field test ``Stmt.if_ 3 1),("sourceBrand",brand),
      ("sourceDisposedWritable",← field disposed ``PropV.data 3 1),("sourceDisposedEnumerable",← field disposed ``PropV.data 3 2),
      ("sourceValue",← field handle ``PropV.data 3 0),("sourceHandleWritable",← field handle ``PropV.data 3 1),
      ("sourceHandleEnumerable",← field handle ``PropV.data 3 2)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `span) (mkNatLit 17)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  for (tag,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.sourceGetter) (.obj {n}.sourceOwner) []"),
    ("source_function_read",s!"{n}.input.heap.get {n}.sourceGetter = some (.obj {n}.sourceFunction)"),
    ("source_function_kind",s!"{n}.sourceFunction.kind = .fn (.closure (getterFunction {n}.sourceName {n}.sourceDisposedName {n}.sourceHandleName {n}.sourceYes) {n}.sourceEnv false {n}.sourceHome)"),
    ("source_object_read",s!"{n}.input.heap.get {n}.sourceOwner = some (.obj {n}.sourceObject)"),
    ("source_ordinary",s!"{n}.sourceObject.kind = .ordinary"),
    ("source_disposed",s!"findPriv {n}.sourceBrand {n}.sourceDisposedName {n}.sourceObject.priv = some (.data (.bool false) {n}.sourceDisposedWritable {n}.sourceDisposedEnumerable)"),
    ("source_handle",s!"findPriv {n}.sourceBrand {n}.sourceHandleName {n}.sourceObject.priv = some (.data {n}.sourceValue {n}.sourceHandleWritable {n}.sourceHandleEnumerable)"),
    ("source_disposed_lookup",s!"lookupEnv (privName {n}.sourceDisposedName) {n}.sourceEnv = some {n}.sourceBrand"),
    ("source_handle_lookup",s!"lookupEnv (privName {n}.sourceHandleName) {n}.sourceEnv = some {n}.sourceBrand"),
    ("source_output",s!"getterCallResult {n}.input {n}.sourceName {n}.sourceEnv {n}.sourceHome {n}.sourceOwner {n}.sourceDisposedName {n}.sourceHandleName {n}.sourceYes {n}.sourceValue = {n}.output"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do fact tag type
  for (tag,field) in [("source_disposed_names","sourceDisposedName"),("source_handle_names","sourceHandleName")] do
    Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : nameEq (privName {n}.{field}) nThis = false ∧ nameEq (privName {n}.{field}) nHome = false := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+2 ≤ 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"def {n}.endLive (live : Nat → Prop) : Nat → Prop :=
    let fn := getterFunction {n}.sourceName {n}.sourceDisposedName {n}.sourceHandleName {n}.sourceYes
    CellsLive (ClosureLive live {n}.input.next false {n}.sourceHome fn)
      (closureState {n}.input fn {n}.sourceEnv false {n}.sourceHome (.obj {n}.sourceOwner) [] .call).next []")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 17 {n}.input C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (role : Annotated.Value)
      (controlNote : notes.runtime.control = callNote (.obj {n}.sourceGetter) (.obj {n}.sourceOwner) [])
      (fieldNote : notes.privates.owners {n}.sourceOwner = some ⟨{n}.sourceBrand,{n}.sourceHandleName,role⟩)
      (targetBound : s.next+2 ≤ 2^64) :
      ∃ result, runC {n}.F 17 {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F 17 s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R ({n}.endLive live) framed before after old old' {n}.output result ∧
        RetainedInventory (getterCallNotes notes {n}.input.next {n}.sourceOwner role)
          ν₀ ν C₀ C R ({n}.endLive live) {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,post,retained,_,_,_⟩ := inventory.getter_call_block h
        {n}.sourceGetter {n}.sourceOwner {n}.sourceBrand {n}.sourceFunction {n}.sourceObject
        {n}.sourceName {n}.sourceEnv {n}.sourceHome {n}.sourceDisposedName {n}.sourceHandleName {n}.sourceYes {n}.sourceValue role
        {n}.sourceDisposedWritable {n}.sourceDisposedEnumerable {n}.sourceHandleWritable {n}.sourceHandleEnumerable
        {n}.source_control {n}.source_function_read {n}.source_function_kind {n}.source_object_read {n}.source_ordinary
        {n}.source_disposed {n}.source_handle {n}.source_disposed_lookup {n}.source_handle_lookup
        {n}.source_disposed_names {n}.source_handle_names fieldNote controlNote {n}.source_bound targetBound
      rw [{n}.source_output] at left post retained
      exact ⟨result,left,right,post,retained,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
