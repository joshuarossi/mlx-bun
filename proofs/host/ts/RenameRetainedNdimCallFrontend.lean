import host.ts.RenameRetainedNdimCall
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

private def newNdimErrors (count : Nat) : CommandElabM (List Message) := do
  return ((← get).messages.reportedPlusUnreported.toList.drop count).filter (fun message => message.severity == .error)

private def emitNdimChecked (source : String) : CommandElabM Unit := do
  let count := (← get).messages.reportedPlusUnreported.toList.length
  Parametric.Driver.emit source
  let errors ← newNdimErrors count
  unless errors.isEmpty do
    let rendered ← errors.mapM fun message => message.data.toString
    throwError "host_retained_ndim_call: kernel rejected generated source contract\n{String.intercalate "\n" rendered}"

/-- Current source extraction is checked by the kernel before the generic
whole-call theorem is exported. -/
private def generateNdimCall (f s initial t next : Syntax) (name : TSyntax `ident) : CommandElabM Unit := do
  let pre := (← getCurrNamespace) ++ name.getId
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Load.Run.Full.Ordinary Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles in\n"
  let fact (tag proposition : String) := emitNdimChecked (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkConst ``Host.Load.LSt)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← mkAppM ``St.ctl #[s]
    let getter ← field (← field ctl ``Ctl.call 3 0) ``Val.obj 1 0
    let owner ← field (← field ctl ``Ctl.call 3 1) ``Val.obj 1 0
    let function ← field (← mkAppM ``St.obj? #[s,getter]) ``Option.some 2 1
    let closure ← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0
    let env ← field closure ``Code.closure 4 1
    let moduleCell ← field (← mkAppM ``lookupEnv #[mkConst ``NdimCall.nativeModule,env]) ``Option.some 2 1
    let module ← field (← field (← field (← mkAppM ``PTrie.get #[← mkAppM ``St.heap #[s],moduleCell]) ``Option.some 2 1) ``HObj.cell 1 0) ``Option.some 2 1
    let module ← field module ``Val.obj 1 0
    let global ← field (← mkAppM ``St.obj? #[s,mkConst ``aGlobal]) ``Option.some 2 1
    let numberProperty ← field (← mkAppM ``findProp #[mkApp (mkConst ``PKey.str) (mkConst ``NdimCall.numberName),← mkAppM ``Obj.props #[global]]) ``Option.some 2 1
    let numberFn ← field (← field numberProperty ``PropV.data 3 0) ``Val.obj 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceNdimGetter",getter),("sourceOwner",owner),
      ("sourceNdimObject",function),("sourceEnv",env),("sourceHome",← field closure ``Code.closure 4 3),
      ("sourceModuleCell",moduleCell),("sourceModule",module),("sourceGlobal",global),("sourceNumberFn",numberFn),
      ("sourceNumberWritable",← field numberProperty ``PropV.data 3 1),("sourceNumberEnumerable",← field numberProperty ``PropV.data 3 2)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `span) (mkNatLit 39)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let makePath (tag rootAddress roleName : String) (accessor : Bool) : CommandElabM Unit := do
    let rec choose (address : Lean.Expr) : Nat → Nat → CommandElabM String
      | 0, _ => throwError "host_retained_ndim_call: exhausted ordinary source path"
      | fuel+1, index => do
        let stem := s!"{n}.{tag}{index}"
        let next ← liftTermElabM do
          let object ← field (← mkAppM ``St.obj? #[mkConst (pre ++ `input),address]) ``Option.some 2 1
          let property ← whnf (← mkAppM ``findProp #[mkApp (mkConst ``PKey.str) (mkConst (pre ++ Name.mkSimple roleName)),← mkAppM ``Obj.props #[object]])
          for (key,value) in [(s!"{tag}{index}Address",address),(s!"{tag}{index}Object",object)] do addData (pre ++ Name.mkSimple key) value
          if property.isAppOfArity ``Option.some 2 then
            let descriptor := property.getAppArgs[1]!
            addData (pre ++ Name.mkSimple s!"{tag}Property") descriptor
            return none
          return some (← field (← mkAppM ``Obj.proto #[object]) ``Val.obj 1 0)
        fact s!"{tag}{index}Read" s!"{n}.input.heap.get {stem}Address = some (.obj {stem}Object)"
        fact s!"{tag}{index}Kind" s!"{stem}Object.kind = .ordinary"
        match next with
        | none =>
          fact s!"{tag}{index}Find" s!"findProp (.str {n}.{roleName}) {stem}Object.props = some {n}.{tag}Property"
          return s!"OrdinaryLookup.hit {fuel} {stem}Address {stem}Object _ {stem}Read {stem}Kind {stem}Find"
        | some next =>
          liftTermElabM <| addData (pre ++ Name.mkSimple s!"{tag}{index}Next") next
          fact s!"{tag}{index}Find" s!"findProp (.str {n}.{roleName}) {stem}Object.props = none"
          fact s!"{tag}{index}Proto" s!"{stem}Object.proto = .obj {stem}Next"
          let child ← choose next fuel (index+1)
          return s!"OrdinaryLookup.next {fuel} {stem}Address {stem}Next {stem}Object {stem}Read {stem}Kind {stem}Find {stem}Proto ({child})"
    let path ← choose (mkConst (pre ++ Name.mkSimple rootAddress)) 16 0
    emitNdimChecked (header ++ s!"theorem {n}.{tag}Path : OrdinaryLookup {n}.input {n}.{roleName} 16 {n}.{rootAddress} (some {n}.{tag}Property) := {path}")
    liftTermElabM do
      let descriptor := mkConst (pre ++ Name.mkSimple s!"{tag}Property")
      let constructor := if accessor then ``PropV.acc else ``PropV.data
      let address ← field (← field descriptor constructor 3 0) ``Val.obj 1 0
      for (key,value) in [(if accessor then "sourceGetter" else "sourceNativeFn",address),
        (s!"{tag}Second",← field descriptor constructor 3 1),(s!"{tag}Third",← field descriptor constructor 3 2)] do addData (pre ++ Name.mkSimple key) value
  liftTermElabM do
    addData (pre ++ `sourceNativeName) (mkConst ``NdimCall.nativeName)
    addData (pre ++ `sourceHandleName) (mkConst ``NdimCall.handleName)
  makePath "native" "sourceModule" "sourceNativeName" false
  makePath "getter" "sourceOwner" "sourceHandleName" true
  liftTermElabM do
    let source := mkConst (pre ++ `input)
    let object (tag : Lean.Name) : TermElabM Lean.Expr := do
      field (← mkAppM ``St.obj? #[source,mkConst (pre ++ tag)]) ``Option.some 2 1
    let getterObject ← object `sourceGetter
    let getterClosure ← field (← mkAppM ``Obj.kind #[getterObject]) ``Kind.fn 1 0
    let getterFunction ← field getterClosure ``Code.closure 4 0
    let body ← field (← field getterFunction ``Func.mk 7 3) ``Body.block 1 0
    let test ← field body ``List.cons 3 1
    let disposed ← field (← field test ``Stmt.if_ 3 0) ``Expr.priv 3 1
    let rest ← field body ``List.cons 3 2
    let privateName ← field (← field (← field (← field rest ``List.cons 3 1) ``Stmt.ret 1 0) ``Option.some 2 1) ``Expr.priv 3 1
    let getEnv ← field getterClosure ``Code.closure 4 1
    let brand ← field (← mkAppM ``lookupEnv #[← mkAppM ``privName #[privateName],getEnv]) ``Option.some 2 1
    let ownerObject ← object `sourceOwner
    let disposedProperty ← field (← mkAppM ``findPriv #[brand,disposed,← mkAppM ``Obj.priv #[ownerObject]]) ``Option.some 2 1
    let handleProperty ← field (← mkAppM ``findPriv #[brand,privateName,← mkAppM ``Obj.priv #[ownerObject]]) ``Option.some 2 1
    let handle ← field (← field handleProperty ``PropV.data 3 0) ``Val.big 1 0
    let handle ← whnf (← mkAppM ``Int.toNat #[handle])
    let numberObject ← object `sourceNumberFn
    let nativeObject ← object `sourceNativeFn
    let nativeData ← field (← field (← mkAppM ``Obj.kind #[nativeObject]) ``Kind.fn 1 0) ``Code.native 2 1
    let nativeData ← field nativeData ``List.cons 3 2
    let types ← field (← field nativeData ``List.cons 3 1) ``Val.obj 1 0
    let returns ← field (← field (← field nativeData ``List.cons 3 2) ``List.cons 3 1) ``Val.str 1 0
    let signature ← field (← mkAppM ``St.obj? #[source,types]) ``Option.some 2 1
    let native ← mkAppM ``St.ffi #[source]
    let node ← field (← mkAppM ``Host.Mlx.Ffi.St.node? #[← mkAppM ``Host.Load.LSt.mlx #[native],handle]) ``Option.some 2 1
    for (tag,value) in [("sourceGetterObject",getterObject),("sourceObject",ownerObject),("sourceGetterName",← field getterFunction ``Func.mk 7 0),
      ("sourceGetterEnv",getEnv),("sourceGetterHome",← field getterClosure ``Code.closure 4 3),("sourceDisposed",disposed),
      ("sourceField",privateName),("sourceYes",← field test ``Stmt.if_ 3 1),("sourceBrand",brand),("sourceHandle",handle),
      ("sourceDisposedWritable",← field disposedProperty ``PropV.data 3 1),("sourceDisposedEnumerable",← field disposedProperty ``PropV.data 3 2),
      ("sourceHandleWritable",← field handleProperty ``PropV.data 3 1),("sourceHandleEnumerable",← field handleProperty ``PropV.data 3 2),
      ("sourceNumberObject",numberObject),("sourceNativeObject",nativeObject),("sourceTypes",types),("sourceReturns",returns),
      ("sourceSignature",signature),("sourceNode",node),
      ("sourceNumberData",← field (← field (← mkAppM ``Obj.kind #[numberObject]) ``Kind.fn 1 0) ``Code.native 2 1)] do addData (pre ++ Name.mkSimple tag) value
  for (tag,proposition) in [
    ("source_ffi",s!"{n}.F = Host.Load.ffi"),
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.sourceNdimGetter) (.obj {n}.sourceOwner) []"),
    ("source_ndim_read",s!"{n}.input.heap.get {n}.sourceNdimGetter = some (.obj {n}.sourceNdimObject)"),
    ("source_ndim_kind",s!"{n}.sourceNdimObject.kind = .fn (.closure Sources.Mlx.Array.ast_n61 {n}.sourceEnv false {n}.sourceHome)"),
    ("source_number_lookup",s!"lookupEnv NdimCall.numberName {n}.sourceEnv = none"),
    ("source_global_read",s!"{n}.input.heap.get aGlobal = some (.obj {n}.sourceGlobal)"),
    ("source_global_kind",s!"{n}.sourceGlobal.kind = .ordinary"),
    ("source_number_property",s!"findProp (.str NdimCall.numberName) {n}.sourceGlobal.props = some (.data (.obj {n}.sourceNumberFn) {n}.sourceNumberWritable {n}.sourceNumberEnumerable)"),
    ("source_module_lookup",s!"lookupEnv NdimCall.nativeModule {n}.sourceEnv = some {n}.sourceModuleCell"),
    ("source_module_read",s!"{n}.input.heap.get {n}.sourceModuleCell = some (.cell (some (.obj {n}.sourceModule)))"),
    ("source_native_property",s!"{n}.nativeProperty = .data (.obj {n}.sourceNativeFn) {n}.nativeSecond {n}.nativeThird"),
    ("source_getter_property",s!"{n}.getterProperty = .acc (.obj {n}.sourceGetter) {n}.getterSecond {n}.getterThird"),
    ("source_getter_read",s!"{n}.input.heap.get {n}.sourceGetter = some (.obj {n}.sourceGetterObject)"),
    ("source_getter_kind",s!"{n}.sourceGetterObject.kind = .fn (.closure (getterFunction {n}.sourceGetterName {n}.sourceDisposed {n}.sourceField {n}.sourceYes) {n}.sourceGetterEnv false {n}.sourceGetterHome)"),
    ("source_object_read",s!"{n}.input.heap.get {n}.sourceOwner = some (.obj {n}.sourceObject)"),
    ("source_ordinary",s!"{n}.sourceObject.kind = .ordinary"),
    ("source_disposed",s!"findPriv {n}.sourceBrand {n}.sourceDisposed {n}.sourceObject.priv = some (.data (.bool false) {n}.sourceDisposedWritable {n}.sourceDisposedEnumerable)"),
    ("source_handle",s!"findPriv {n}.sourceBrand {n}.sourceField {n}.sourceObject.priv = some (.data (.big (Int.ofNat {n}.sourceHandle)) {n}.sourceHandleWritable {n}.sourceHandleEnumerable)"),
    ("source_disposed_lookup",s!"lookupEnv (privName {n}.sourceDisposed) {n}.sourceGetterEnv = some {n}.sourceBrand"),
    ("source_handle_lookup",s!"lookupEnv (privName {n}.sourceField) {n}.sourceGetterEnv = some {n}.sourceBrand"),
    ("source_number_read",s!"{n}.input.heap.get {n}.sourceNumberFn = some (.obj {n}.sourceNumberObject)"),
    ("source_number_kind",s!"{n}.sourceNumberObject.kind = .fn (.native (.num .number) {n}.sourceNumberData)"),
    ("source_native_read",s!"{n}.input.heap.get {n}.sourceNativeFn = some (.obj {n}.sourceNativeObject)"),
    ("source_native_kind",s!"{n}.sourceNativeObject.kind = .fn (.native (.ffi .symbol) [.str NdimCall.nativeName,.obj {n}.sourceTypes,.str {n}.sourceReturns])"),
    ("source_signature_read",s!"{n}.input.heap.get {n}.sourceTypes = some (.obj {n}.sourceSignature)"),
    ("source_signature_kind",s!"{n}.sourceSignature.kind = .array [.str chars!\"u64\"]"),
    ("source_node",s!"{n}.input.ffi.mlx.node? {n}.sourceHandle = some {n}.sourceNode"),
    ("source_endpoint",s!"NdimCall.callResult {n}.input {n}.sourceEnv {n}.sourceHome {n}.sourceOwner {n}.sourceGetterName {n}.sourceGetterEnv {n}.sourceGetterHome {n}.sourceDisposed {n}.sourceField {n}.sourceYes {n}.sourceNumberFn {n}.sourceNativeFn {n}.sourceModule {n}.sourceGetter {n}.sourceHandle (len {n}.sourceNode.shape) = {n}.output"),
    ("source_servers",s!"{n}.initialServer = {n}.nextServer")]
    do fact tag proposition
  for (tag,field) in [("source_disposed_names","sourceDisposed"),("source_handle_names","sourceField")] do
    emitNdimChecked (header ++ s!"theorem {n}.{tag} : nameEq (privName {n}.{field}) nThis = false ∧ nameEq (privName {n}.{field}) nHome = false := by decide +kernel")
  emitNdimChecked (header ++ s!"theorem {n}.source_bound : {n}.input.next+4 ≤ 2^64 := by decide +kernel")
  emitNdimChecked (header ++ s!"def {n}.endLive (live : Nat → Prop) : Nat → Prop := NdimCall.callLive live {n}.input {n}.sourceEnv {n}.sourceHome {n}.sourceOwner {n}.sourceGetterName {n}.sourceGetterEnv {n}.sourceGetterHome {n}.sourceDisposed {n}.sourceField {n}.sourceYes {n}.sourceNumberFn {n}.sourceNativeFn {n}.sourceModule {n}.sourceGetter")
  emitNdimChecked (header ++ s!"theorem {n}.retained_transport
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tailTokens : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St Host.Load.LSt)
    (inst : Inst ν₀ {n}.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tailTokens host) R live framed before after old old' {n}.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (globalLive : live aGlobal) (moduleCellLive : live {n}.sourceModuleCell) (moduleLive : live {n}.sourceModule)
    (ownerLive : live {n}.sourceOwner) (getterLive : live {n}.sourceGetter) (numberLive : live {n}.sourceNumberFn)
    (nativeLive : live {n}.sourceNativeFn) (typesLive : live {n}.sourceTypes)
    (globalFixed : R.a aGlobal = aGlobal) (signatureFrame : ¬ framed {n}.sourceTypes) (handleLive : H {n}.sourceHandle)
    (fieldNote : notes.privates.owners {n}.sourceOwner = some ⟨{n}.sourceBrand,{n}.sourceField,.handle {n}.sourceHandle⟩)
    (controlNote : notes.runtime.control = callNote (.obj {n}.sourceNdimGetter) (.obj {n}.sourceOwner) [])
    (targetBound : s.next+4 ≤ 2^64) :
    ∃ result, runC Host.Load.ffi 39 s C = some (result,C) ∧ runC Host.Load.ffi 39 {n}.input C₀ = some ({n}.output,C₀) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tailTokens host) R ({n}.endLive live) framed before after old old' {n}.output result ∧
      RetainedInventory (NdimCall.callNotes notes {n}.input {n}.sourceEnv {n}.sourceHome {n}.sourceOwner {n}.sourceNumberFn {n}.sourceNativeFn {n}.sourceModule {n}.sourceGetter (len {n}.sourceNode.shape)) ν₀ ν C₀ C R ({n}.endLive live) {n}.output result ∧
      Inst ν₀ {n}.nextServer C₀ ∧ ProducerAnnotations roots H N nodes objects ∧ ProducerSupport roots H N {n}.output.ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i)) (resourceImage R.handle H) (resourceImage R.node N) result.ffi.mlx := by
    have nativePath := {n}.nativePath
    have getterPath := {n}.getterPath
    rw [{n}.source_native_property] at nativePath
    rw [{n}.source_getter_property] at getterPath
    obtain ⟨result,left,right,post,retained,_,_,_,policy',support,targetSupport⟩ := inventory.ndim_call_block h policy
      {n}.sourceNdimGetter {n}.sourceOwner {n}.sourceGetter {n}.sourceBrand {n}.sourceNumberFn {n}.sourceNativeFn {n}.sourceModuleCell {n}.sourceModule {n}.sourceTypes {n}.sourceHandle
      {n}.sourceNdimObject {n}.sourceGetterObject {n}.sourceObject {n}.sourceGlobal {n}.sourceNumberObject {n}.sourceNativeObject {n}.sourceSignature
      {n}.sourceEnv {n}.sourceGetterEnv {n}.sourceHome {n}.sourceGetterHome {n}.sourceGetterName {n}.sourceDisposed {n}.sourceField {n}.sourceYes
      {n}.sourceNumberWritable {n}.sourceNumberEnumerable {n}.nativeSecond {n}.nativeThird {n}.getterThird
      {n}.sourceDisposedWritable {n}.sourceDisposedEnumerable {n}.sourceHandleWritable {n}.sourceHandleEnumerable
      {n}.getterSecond {n}.sourceReturns {n}.sourceNumberData {n}.sourceNode
      {n}.source_control {n}.source_ndim_read {n}.source_ndim_kind {n}.source_number_lookup {n}.source_global_read {n}.source_global_kind {n}.source_number_property
      {n}.source_module_lookup {n}.source_module_read nativePath getterPath {n}.source_getter_read {n}.source_getter_kind {n}.source_object_read {n}.source_ordinary
      {n}.source_disposed {n}.source_handle {n}.source_disposed_lookup {n}.source_handle_lookup {n}.source_disposed_names {n}.source_handle_names
      {n}.source_number_read {n}.source_number_kind {n}.source_native_read {n}.source_native_kind {n}.source_signature_read {n}.source_signature_kind
      globalLive moduleCellLive moduleLive ownerLive getterLive numberLive nativeLive typesLive globalFixed signatureFrame handleLive {n}.source_node fieldNote controlNote {n}.source_bound targetBound
    rw [{n}.source_endpoint] at left post retained support
    exact ⟨result,right,left,post,retained,{n}.source_servers ▸ inst,policy',support,targetSupport⟩")


/-- A failed selection restores the full command state, including declarations,
messages, scopes and elaborator extensions. Existing errors are not reclassified. -/
def elaborateNdimCall (f s initial t next : Syntax) (name : TSyntax `ident) : CommandElabM Unit := do
  let saved : Command.State ← get
  let count := saved.messages.reportedPlusUnreported.toList.length
  try
    generateNdimCall f s initial t next name
    let errors ← newNdimErrors count
    unless errors.isEmpty do
      let rendered ← errors.mapM fun message => message.data.toString
      throwError "host_retained_ndim_call: kernel rejected generated source contract\n{String.intercalate "\n" rendered}"
  catch error =>
    set saved
    throw error

elab "host_retained_ndim_call " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command =>
  elaborateNdimCall f.raw s.raw initial.raw t.raw next.raw name

end Host.Ts.Owned.Annotated.Driver
