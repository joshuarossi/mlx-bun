import host.ts.RenameRetainedMapperCall
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select a whole mapper call from initial source metadata. Candidate heap
reads, prototype edges, closure syntax and the full endpoint are checked by
the kernel before the reusable source-function theorem is instantiated. -/
elab "host_retained_mapper_call " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← mkAppM ``St.ctl #[s]
    let callee ← field (← field control ``Ctl.call 3 0) ``Val.obj 1 0
    let arguments ← field control ``Ctl.call 3 2
    let owner ← field (← field arguments ``List.cons 3 1) ``Val.obj 1 0
    let mapper ← field (← mkAppM ``St.obj? #[s,callee]) ``Option.some 2 1
    let closure ← whnf (← field (← mkAppM ``Obj.kind #[mapper]) ``Kind.fn 1 0)
    let fn ← field closure ``Code.closure 4 0
    let parameter ← field (← field (← mkAppM ``fnParams #[fn]) ``List.cons 3 1) ``Pat.id 1 0
    let expression ← field (← field fn ``Func.mk 7 3) ``Body.expr 1 0
    let fieldName ← field expression ``Expr.member 3 1
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceCallee",callee),("sourceOwner",owner),
      ("sourceMapper",mapper),("sourceEnv",closure.getAppArgs[1]!),
      ("sourceName",parameter),("sourceField",fieldName),("sourceThis",← field control ``Ctl.call 3 1),
      ("sourceExtraArgs",← field arguments ``List.cons 3 2)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `span) (mkNatLit 26)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let rec path (address : Lean.Expr) : Nat → Nat → CommandElabM String
    | 0, _ => throwError "mapper call: exhausted ordinary prototype path"
    | fuel+1, index => do
      let stem := s!"{n}.path{index}"
      let next ← liftTermElabM do
        let object ← field (← mkAppM ``St.obj? #[mkConst (pre ++ `input),address]) ``Option.some 2 1
        let property ← whnf (← mkAppM ``findProp #[mkApp (mkConst ``PKey.str) (mkConst (pre ++ `sourceField)),← mkAppM ``Obj.props #[object]])
        for (tag,value) in [(s!"path{index}Address",address),(s!"path{index}Object",object)] do addData (pre ++ Name.mkSimple tag) value
        if property.isAppOfArity ``Option.some 2 then
          let property ← whnf property.getAppArgs[1]!
          let getter ← field (← field property ``PropV.acc 3 0) ``Val.obj 1 0
          for (tag,value) in [("sourceGetter",getter),("sourceSetter",← field property ``PropV.acc 3 1),
            ("sourceEnumerable",← field property ``PropV.acc 3 2)] do addData (pre ++ Name.mkSimple tag) value
          return none
        return some (← field (← mkAppM ``Obj.proto #[object]) ``Val.obj 1 0)
      fact s!"path{index}Read" s!"{n}.input.heap.get {stem}Address = some (.obj {stem}Object)"
      fact s!"path{index}Kind" s!"{stem}Object.kind = .ordinary"
      match next with
      | none =>
        fact s!"path{index}Find" s!"findProp (.str {n}.sourceField) {stem}Object.props = some (.acc (.obj {n}.sourceGetter) {n}.sourceSetter {n}.sourceEnumerable)"
        return s!"OrdinaryLookup.hit {fuel} {stem}Address {stem}Object _ {stem}Read {stem}Kind {stem}Find"
      | some next =>
        liftTermElabM <| addData (pre ++ Name.mkSimple s!"path{index}Next") next
        fact s!"path{index}Find" s!"findProp (.str {n}.sourceField) {stem}Object.props = none"
        fact s!"path{index}Prototype" s!"{stem}Object.proto = .obj {stem}Next"
        let child ← path next fuel (index+1)
        return s!"OrdinaryLookup.next {fuel} {stem}Address {stem}Next {stem}Object {stem}Read {stem}Kind {stem}Find {stem}Prototype ({child})"
  let path ← path (mkConst (pre ++ `sourceOwner)) 16 0
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_path : OrdinaryLookup {n}.input {n}.sourceField 16 {n}.sourceOwner
    (some (.acc (.obj {n}.sourceGetter) {n}.sourceSetter {n}.sourceEnumerable)) := {path}")
  liftTermElabM do
    let source := mkConst (pre ++ `input)
    let getter ← field (← mkAppM ``St.obj? #[source,mkConst (pre ++ `sourceGetter)]) ``Option.some 2 1
    let closure ← whnf (← field (← mkAppM ``Obj.kind #[getter]) ``Kind.fn 1 0)
    let fn ← field closure ``Code.closure 4 0
    let body ← field (← field fn ``Func.mk 7 3) ``Body.block 1 0
    let test ← field body ``List.cons 3 1
    let disposedName ← field (← field test ``Stmt.if_ 3 0) ``Expr.priv 3 1
    let rest ← field body ``List.cons 3 2
    let handleName ← field (← field (← field (← field rest ``List.cons 3 1) ``Stmt.ret 1 0) ``Option.some 2 1) ``Expr.priv 3 1
    let env ← field closure ``Code.closure 4 1
    let brand ← field (← mkAppM ``lookupEnv #[← mkAppM ``privName #[disposedName],env]) ``Option.some 2 1
    let object ← field (← mkAppM ``St.obj? #[source,mkConst (pre ++ `sourceOwner)]) ``Option.some 2 1
    let disposed ← field (← mkAppM ``findPriv #[brand,disposedName,← mkAppM ``Obj.priv #[object]]) ``Option.some 2 1
    let handle ← field (← mkAppM ``findPriv #[brand,handleName,← mkAppM ``Obj.priv #[object]]) ``Option.some 2 1
    for (tag,value) in [("sourceGetterObject",getter),("sourceObject",object),("sourceGetterName",← field fn ``Func.mk 7 0),
      ("sourceGetterEnv",env),("sourceHome",← field closure ``Code.closure 4 3),("sourceDisposedName",disposedName),
      ("sourceHandleName",handleName),("sourceYes",← field test ``Stmt.if_ 3 1),("sourceBrand",brand),
      ("sourceDisposedWritable",← field disposed ``PropV.data 3 1),("sourceDisposedEnumerable",← field disposed ``PropV.data 3 2),
      ("sourceValue",← field handle ``PropV.data 3 0),("sourceHandleWritable",← field handle ``PropV.data 3 1),
      ("sourceHandleEnumerable",← field handle ``PropV.data 3 2)] do addData (pre ++ Name.mkSimple tag) value
  fact "source_control" s!"{n}.input.ctl = .call (.obj {n}.sourceCallee) {n}.sourceThis (.obj {n}.sourceOwner::{n}.sourceExtraArgs)"
  fact "source_mapper_read" s!"{n}.input.heap.get {n}.sourceCallee = some (.obj {n}.sourceMapper)"
  fact "source_mapper_kind" s!"{n}.sourceMapper.kind = .fn (.closure (mapperFunction {n}.sourceName {n}.sourceField) {n}.sourceEnv true .undef)"
  fact "source_getter_read" s!"{n}.input.heap.get {n}.sourceGetter = some (.obj {n}.sourceGetterObject)"
  fact "source_getter_kind" s!"{n}.sourceGetterObject.kind = .fn (.closure (getterFunction {n}.sourceGetterName {n}.sourceDisposedName {n}.sourceHandleName {n}.sourceYes) {n}.sourceGetterEnv false {n}.sourceHome)"
  fact "source_object_read" s!"{n}.input.heap.get {n}.sourceOwner = some (.obj {n}.sourceObject)"
  fact "source_ordinary" s!"{n}.sourceObject.kind = .ordinary"
  fact "source_disposed" s!"findPriv {n}.sourceBrand {n}.sourceDisposedName {n}.sourceObject.priv = some (.data (.bool false) {n}.sourceDisposedWritable {n}.sourceDisposedEnumerable)"
  fact "source_handle" s!"findPriv {n}.sourceBrand {n}.sourceHandleName {n}.sourceObject.priv = some (.data {n}.sourceValue {n}.sourceHandleWritable {n}.sourceHandleEnumerable)"
  fact "source_disposed_lookup" s!"lookupEnv (privName {n}.sourceDisposedName) {n}.sourceGetterEnv = some {n}.sourceBrand"
  fact "source_handle_lookup" s!"lookupEnv (privName {n}.sourceHandleName) {n}.sourceGetterEnv = some {n}.sourceBrand"
  for (tag,field) in [("source_disposed_names","sourceDisposedName"),("source_handle_names","sourceHandleName")] do
    Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : nameEq (privName {n}.{field}) nThis = false ∧ nameEq (privName {n}.{field}) nHome = false := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+3 ≤ 2^64 := by decide +kernel")
  fact "source_output" s!"mapperCallResult {n}.input {n}.sourceEnv {n}.sourceName {n}.sourceField {n}.sourceThis {n}.sourceOwner {n}.sourceExtraArgs {n}.sourceGetter {n}.sourceGetterName {n}.sourceGetterEnv {n}.sourceHome {n}.sourceDisposedName {n}.sourceHandleName {n}.sourceYes {n}.sourceValue = {n}.output"
  fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 26 {n}.input C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (fnRole thisRole role : Annotated.Value) (extraRoles : List Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole (.obj {n}.sourceOwner::extraRoles))
      (fieldNote : notes.privates.owners {n}.sourceOwner = some ⟨{n}.sourceBrand,{n}.sourceHandleName,role⟩)
      (targetBound : s.next+3 ≤ 2^64) :
      ∃ result, runC {n}.F 26 {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F 26 s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R
          (MapperCallLive live {n}.input.next {n}.sourceName {n}.sourceField {n}.sourceGetterName {n}.sourceHome {n}.sourceDisposedName {n}.sourceHandleName {n}.sourceYes)
          framed before after old old' {n}.output result ∧
        RetainedInventory (mapperCallNotes notes {n}.input.next {n}.sourceOwner role) ν₀ ν C₀ C R
          (MapperCallLive live {n}.input.next {n}.sourceName {n}.sourceField {n}.sourceGetterName {n}.sourceHome {n}.sourceDisposedName {n}.sourceHandleName {n}.sourceYes)
          {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,post,retained,_,_,_⟩ := inventory.mapper_call_block h
        {n}.sourceCallee {n}.sourceOwner {n}.sourceGetter {n}.sourceBrand {n}.sourceMapper {n}.sourceGetterObject {n}.sourceObject
        {n}.sourceEnv {n}.sourceName {n}.sourceField {n}.sourceThis {n}.sourceExtraArgs {n}.sourceGetterName {n}.sourceGetterEnv {n}.sourceHome {n}.sourceSetter
        {n}.sourceDisposedName {n}.sourceHandleName {n}.sourceYes {n}.sourceValue role fnRole thisRole extraRoles
        {n}.sourceEnumerable {n}.sourceDisposedWritable {n}.sourceDisposedEnumerable {n}.sourceHandleWritable {n}.sourceHandleEnumerable
        {n}.source_control {n}.source_mapper_read {n}.source_mapper_kind {n}.source_path {n}.source_getter_read {n}.source_getter_kind
        {n}.source_object_read {n}.source_ordinary {n}.source_disposed {n}.source_handle {n}.source_disposed_lookup {n}.source_handle_lookup
        {n}.source_disposed_names {n}.source_handle_names fieldNote controlNote {n}.source_bound targetBound
      rw [{n}.source_output] at left post retained
      exact ⟨result,left,right,post,retained,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
