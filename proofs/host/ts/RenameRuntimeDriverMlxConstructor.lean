import host.ts.RenameRetainedMlxConstructorBlock
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Select a complete MLXArray constructor from current source class and
captured registry metadata. Every extracted fact and endpoint is kernel checked. -/
elab "host_retained_mlx_constructor " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Ts.Owned.Annotated.MlxConstruction in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    unless control.isAppOfArity ``Ctl.construct 3 do throwError "MLXArray summary: expected current class entry"
    let address ← field control.getAppArgs[0]! ``Val.obj 1 0
    let argument ← field control.getAppArgs[1]! ``List.cons 3 1
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let klass ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    unless klass.isAppOfArity ``Code.klass 4 do throwError "MLXArray summary: class metadata missing"
    let env := klass.getAppArgs[1]!
    let member ← field klass.getAppArgs[3]! ``List.cons 3 1
    let brand ← field member ``InstMember.privField 3 0
    let prototype ← field (← mkAppM ``findProp #[mkConst ``kPrototype,← mkAppM ``Obj.props #[object]]) ``Option.some 2 1
    let proto ← field (← field prototype ``PropV.data 3 0) ``Val.obj 1 0
    let cell ← field (← mkAppM ``lookupEnv #[toExpr (chars!"registry"),env]) ``Option.some 2 1
    let value ← field (← field (← mkAppM ``St.cell? #[s,cell]) ``Option.some 2 1) ``Option.some 2 1
    let registry ← field value ``Val.obj 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceAddress",address),("sourceArgument",argument),
      ("sourceObject",object),("sourceEnv",env),("sourceBrand",brand),("sourcePrototype",proto),
      ("sourceWritable",← field prototype ``PropV.data 3 1),("sourceEnumerable",← field prototype ``PropV.data 3 2),
      ("sourceRegistryCell",cell),("sourceRegistry",registry)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `span) (mkNatLit 37)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  fact "source_control" s!"{n}.input.ctl = .construct (.obj {n}.sourceAddress) [{n}.sourceArgument] (.obj {n}.sourceAddress)"
  fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
  fact "source_kind" s!"{n}.sourceObject.kind = .fn (.klass (some constructorFunction) {n}.sourceEnv .null (members {n}.sourceBrand))"
  fact "source_prototype" s!"findProp kPrototype {n}.sourceObject.props = some (.data (.obj {n}.sourcePrototype) {n}.sourceWritable {n}.sourceEnumerable)"
  fact "source_handle_brand" s!"lookupEnv (privName chars!\"handle\") {n}.sourceEnv = some {n}.sourceBrand"
  fact "source_token_brand" s!"lookupEnv (privName chars!\"token\") {n}.sourceEnv = some {n}.sourceBrand"
  fact "source_registry_lookup" s!"lookupEnv chars!\"registry\" {n}.sourceEnv = some {n}.sourceRegistryCell"
  fact "source_registry_cell" s!"{n}.input.heap.get {n}.sourceRegistryCell = some (.cell (some (.obj {n}.sourceRegistry)))"
  let rec choosePath (address : Lean.Expr) : Nat → Nat → CommandElabM String
    | 0, _ => throwError "MLXArray summary: registry prototype path exhausted"
    | fuel+1, index => do
      let stem := s!"{n}.path{index}"
      let next ← liftTermElabM do
        let object ← field (← mkAppM ``St.obj? #[mkConst (pre ++ `input),address]) ``Option.some 2 1
        let property ← whnf (← mkAppM ``findProp #[mkApp (mkConst ``PKey.str) (toExpr (chars!"register")),← mkAppM ``Obj.props #[object]])
        for (tag,value) in [(s!"path{index}Address",address),(s!"path{index}Object",object)] do addData (pre ++ Name.mkSimple tag) value
        if property.isAppOfArity ``Option.some 2 then
          let data ← whnf property.getAppArgs[1]!
          unless data.isAppOfArity ``PropV.data 3 do throwError "MLXArray summary: register is not data"
          let callee ← field data.getAppArgs[0]! ``Val.obj 1 0
          let object ← field (← mkAppM ``St.obj? #[mkConst (pre ++ `input),callee]) ``Option.some 2 1
          let native ← field (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0) ``Code.native 2 1
          for (tag,value) in [("sourceCallee",callee),("sourceCalleeObject",object),("sourceNativeData",native),
            ("sourceRegisterWritable",data.getAppArgs[1]!),("sourceRegisterEnumerable",data.getAppArgs[2]!)] do addData (pre ++ Name.mkSimple tag) value
          return none
        let proto ← whnf (← mkAppM ``Obj.proto #[object])
        if proto.isConstOf ``Val.null then throwError "MLXArray summary: register missing"
        return some (← field proto ``Val.obj 1 0)
      fact s!"path{index}Heap" s!"{n}.input.heap.get {stem}Address = some (.obj {stem}Object)"
      fact s!"path{index}Kind" s!"{stem}Object.kind = .ordinary"
      match next with
      | none =>
        fact s!"path{index}Find" s!"findProp (.str chars!\"register\") {stem}Object.props = some (.data (.obj {n}.sourceCallee) {n}.sourceRegisterWritable {n}.sourceRegisterEnumerable)"
        return s!"OrdinaryLookup.hit {fuel} {stem}Address {stem}Object _ {stem}Heap {stem}Kind {stem}Find"
      | some next =>
        liftTermElabM <| addData (pre ++ Name.mkSimple s!"path{index}Next") next
        fact s!"path{index}Find" s!"findProp (.str chars!\"register\") {stem}Object.props = none"
        fact s!"path{index}NextEq" s!"{stem}Object.proto = .obj {stem}Next"
        let child ← choosePath next fuel (index+1)
        return s!"OrdinaryLookup.next {fuel} {stem}Address {stem}Next {stem}Object {stem}Heap {stem}Kind {stem}Find {stem}NextEq ({child})"
  let path ← choosePath (mkConst (pre ++ `sourceRegistry)) 16 0
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_path : OrdinaryLookup {n}.input chars!\"register\" 16 {n}.sourceRegistry
    (some (.data (.obj {n}.sourceCallee) {n}.sourceRegisterWritable {n}.sourceRegisterEnumerable)) := {path}")
  fact "source_callee_heap" s!"{n}.input.heap.get {n}.sourceCallee = some (.obj {n}.sourceCalleeObject)"
  fact "source_callee_kind" s!"{n}.sourceCalleeObject.kind = .fn (.native (.fn .finRegister) {n}.sourceNativeData)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+6 ≤ 2^64 := by decide +kernel")
  fact "source_output" s!"constructorOutput {n}.input {n}.sourceEnv {n}.sourcePrototype {n}.sourceBrand {n}.sourceArgument = {n}.output"
  fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 37 {n}.input C = some ({n}.output,C) := by host_kernel_rfl")
  fact "source_step" s!"runS {n}.F 37 {n}.input {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (fnRole argRole : Annotated.Value) (controlNote : notes.runtime.control = constructNote fnRole [argRole])
      (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto) (targetBound : s.next+6 ≤ 2^64) :
      ∃ result, runC {n}.F 37 {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F 37 s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (ParametersLive live {n}.input.next) framed before after old old' {n}.output result ∧
        RetainedInventory (constructorNotes notes {n}.input {n}.sourceEnv {n}.sourcePrototype {n}.sourceBrand {n}.sourceArgument argRole)
          ν₀ ν C₀ C R (ParametersLive live {n}.input.next) {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,post,retained⟩ := construct_block inventory h {n}.sourceAddress {n}.sourcePrototype {n}.sourceBrand
        {n}.sourceRegistryCell {n}.sourceRegistry {n}.sourceCallee {n}.sourceObject {n}.sourceCalleeObject
        {n}.sourceEnv {n}.sourceArgument fnRole argRole {n}.sourceNativeData {n}.sourceWritable {n}.sourceEnumerable
        {n}.sourceRegisterWritable {n}.sourceRegisterEnumerable {n}.source_control {n}.source_heap {n}.source_kind {n}.source_prototype
        {n}.source_handle_brand {n}.source_token_brand {n}.source_registry_lookup {n}.source_registry_cell {n}.source_path
        {n}.source_callee_heap {n}.source_callee_kind controlNote objectLive objectFixed {n}.source_bound targetBound
      rw [{n}.source_output] at left post retained
      exact ⟨result,left,right,post,retained,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
