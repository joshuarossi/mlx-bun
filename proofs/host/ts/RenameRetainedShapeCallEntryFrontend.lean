import host.ts.RenameRetainedShapeCallEntry
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

private def emitShapeEntryChecked (source : String) (declaration : String := "generated source contract") : CommandElabM Unit := do
  let count := (← get).messages.reportedPlusUnreported.toList.length
  Parametric.Driver.emit source
  let errors := ((← get).messages.reportedPlusUnreported.toList.drop count).filter (fun m => m.severity == .error)
  unless errors.isEmpty do
    let rendered ← errors.mapM fun m => m.data.toString
    throwError "host_retained_shape_entry: kernel rejected {declaration}\n{String.intercalate "\n" rendered}"

private def generateShapeEntry (f s initial t next : Syntax) (name : TSyntax `ident) : CommandElabM Unit := do
  let pre := (← getCurrNamespace) ++ name.getId
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := emitShapeEntryChecked (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl") (n++"."++tag)
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkConst ``Host.Load.LSt)
    let source ← Term.elabTermEnsuringType s stateTy
    let target ← Term.elabTermEnsuringType t stateTy
    let control ← mkAppM ``St.ctl #[source]
    let getter ← field (← field control ``Ctl.call 3 0) ``Val.obj 1 0
    let owner ← field (← field control ``Ctl.call 3 1) ``Val.obj 1 0
    let object ← field (← mkAppM ``St.obj? #[source,getter]) ``Option.some 2 1
    let closure ← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0
    for (tag,value) in [("F",f),("input",source),("output",target),("sourceGetter",getter),("sourceOwner",owner),
      ("sourceObject",object),("sourceEnv",← field closure ``Code.closure 4 1),("sourceHome",← field closure ``Code.closure 4 3)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `span) (mkNatLit 7)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let rec choose (address : Lean.Expr) : Nat → Nat → CommandElabM String
    | 0, _ => throwError "host_retained_shape_entry: exhausted ordinary source path"
    | fuel+1, index => do
      let stem := s!"{n}.path{index}"
      let next ← liftTermElabM do
        let object ← field (← mkAppM ``St.obj? #[mkConst (pre ++ `input),address]) ``Option.some 2 1
        let property ← whnf (← mkAppM ``findProp #[mkApp (mkConst ``PKey.str) (mkConst ``ShapeCall.ndimName),← mkAppM ``Obj.props #[object]])
        addData (pre ++ Name.mkSimple s!"path{index}Address") address
        addData (pre ++ Name.mkSimple s!"path{index}Object") object
        if property.isAppOfArity ``Option.some 2 then
          let descriptor := property.getAppArgs[1]!
          addData (pre ++ `sourceProperty) descriptor
          return none
        return some (← field (← mkAppM ``Obj.proto #[object]) ``Val.obj 1 0)
      fact s!"path{index}Read" s!"{n}.input.heap.get {stem}Address = some (.obj {stem}Object)"
      fact s!"path{index}Kind" s!"{stem}Object.kind = .ordinary"
      match next with
      | none =>
        fact s!"path{index}Find" s!"findProp (.str ShapeCall.ndimName) {stem}Object.props = some {n}.sourceProperty"
        return s!"OrdinaryLookup.hit {fuel} {stem}Address {stem}Object _ {stem}Read {stem}Kind {stem}Find"
      | some next =>
        liftTermElabM <| addData (pre ++ Name.mkSimple s!"path{index}Next") next
        fact s!"path{index}Find" s!"findProp (.str ShapeCall.ndimName) {stem}Object.props = none"
        fact s!"path{index}Proto" s!"{stem}Object.proto = .obj {stem}Next"
        let child ← choose next fuel (index+1)
        return s!"OrdinaryLookup.next {fuel} {stem}Address {stem}Next {stem}Object {stem}Read {stem}Kind {stem}Find {stem}Proto ({child})"
  let path ← choose (mkConst (pre ++ `sourceOwner)) 16 0
  emitShapeEntryChecked (header ++ s!"theorem {n}.source_path : OrdinaryLookup {n}.input ShapeCall.ndimName 16 {n}.sourceOwner (some {n}.sourceProperty) := {path}")
  liftTermElabM do
    let property := mkConst (pre ++ `sourceProperty)
    addData (pre ++ `sourceNdimGetter) (← field (← field property ``PropV.acc 3 0) ``Val.obj 1 0)
    addData (pre ++ `sourceSetter) (← field property ``PropV.acc 3 1)
    addData (pre ++ `sourceEnumerable) (← field property ``PropV.acc 3 2)
  for (tag,proposition) in [
    ("source_ffi",s!"{n}.F = Host.Load.ffi"),
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.sourceGetter) (.obj {n}.sourceOwner) []"),
    ("source_read",s!"{n}.input.heap.get {n}.sourceGetter = some (.obj {n}.sourceObject)"),
    ("source_kind",s!"{n}.sourceObject.kind = .fn (.closure Sources.Mlx.Array.ast_n67 {n}.sourceEnv false {n}.sourceHome)"),
    ("source_property",s!"{n}.sourceProperty = .acc (.obj {n}.sourceNdimGetter) {n}.sourceSetter {n}.sourceEnumerable"),
    ("source_endpoint",s!"ShapeCall.entry {n}.input {n}.sourceEnv {n}.sourceHome {n}.sourceOwner {n}.sourceNdimGetter = {n}.output"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do fact tag proposition
  emitShapeEntryChecked (header ++ s!"theorem {n}.source_bound : {n}.input.next+4 ≤ 2^64 := by decide +kernel")
  emitShapeEntryChecked (header ++ s!"theorem {n}.retained_transport
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St Host.Load.LSt)
    (inst : Inst ν₀ {n}.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
    (ownerLive : live {n}.sourceOwner)
    (controlNote : notes.runtime.control = callNote (.obj {n}.sourceGetter) (.obj {n}.sourceOwner) [])
    (targetBound : s.next+4 ≤ 2^64) :
    ∃ result, runC Host.Load.ffi 7 s C = some (result,C) ∧ runC Host.Load.ffi 7 {n}.input C₀ = some ({n}.output,C₀) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (ShapeCall.entryLive live {n}.input {n}.sourceEnv {n}.sourceHome {n}.sourceOwner) framed before after old old' {n}.output result ∧
      RetainedInventory (ShapeCall.entryNotes notes {n}.input {n}.sourceEnv {n}.sourceHome {n}.sourceOwner {n}.sourceNdimGetter) ν₀ ν C₀ C R
        (ShapeCall.entryLive live {n}.input {n}.sourceEnv {n}.sourceHome {n}.sourceOwner) {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
    have path := {n}.source_path
    rw [{n}.source_property] at path
    obtain ⟨result,left,right,post,retained,_,_,_⟩ := ShapeCall.entry_block (F:=Host.Load.ffi) inventory h {n}.sourceGetter {n}.sourceOwner {n}.sourceNdimGetter
      {n}.sourceObject {n}.sourceEnv {n}.sourceHome {n}.sourceSetter {n}.sourceEnumerable {n}.source_control {n}.source_read {n}.source_kind path
      ownerLive controlNote {n}.source_bound targetBound
    have left' := left.trans (congrArg (fun st : St Host.Load.LSt => some (st,C₀)) {n}.source_endpoint)
    let relationAt := fun st : St Host.Load.LSt => Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R
      (ShapeCall.entryLive live {n}.input {n}.sourceEnv {n}.sourceHome {n}.sourceOwner) framed before after old old' st result
    have post' : relationAt {n}.output := Eq.mp (congrArg relationAt {n}.source_endpoint) post
    let retainedAt := fun st : St Host.Load.LSt => RetainedInventory
      (ShapeCall.entryNotes notes {n}.input {n}.sourceEnv {n}.sourceHome {n}.sourceOwner {n}.sourceNdimGetter) ν₀ ν C₀ C R
      (ShapeCall.entryLive live {n}.input {n}.sourceEnv {n}.sourceHome {n}.sourceOwner) st result
    have retained' : retainedAt {n}.output := Eq.mp (congrArg retainedAt {n}.source_endpoint) retained
    exact ⟨result,right,left',post',retained',{n}.source_servers ▸ inst⟩")

def elaborateShapeEntry (f s initial t next : Syntax) (name : TSyntax `ident) : CommandElabM Unit := do
  let saved : Command.State ← get
  let count := saved.messages.reportedPlusUnreported.toList.length
  try
    generateShapeEntry f s initial t next name
    let errors := ((← get).messages.reportedPlusUnreported.toList.drop count).filter (fun m => m.severity == .error)
    unless errors.isEmpty do
      let rendered ← errors.mapM fun m => m.data.toString
      throwError "host_retained_shape_entry: kernel rejected generated source contract\n{String.intercalate "\n" rendered}"
  catch error =>
    set saved
    throw error

elab "host_retained_shape_entry " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command =>
  elaborateShapeEntry f.raw s.raw initial.raw t.raw next.raw name

end Host.Ts.Owned.Annotated.Driver
