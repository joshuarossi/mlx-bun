import host.ts.RenameRetainedDispose
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

private def disposePath (pre : Lean.Name) (state : Lean.Expr) (stem : String)
    (property : Host.Ts.Name) (initial : Lean.Expr) : CommandElabM String := do
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag type : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by host_kernel_rfl")
  let rec choose (address : Lean.Expr) : Nat → Nat → CommandElabM String
    | 0, _ => throwError "host_retained_dispose: exhausted current source prototype path"
    | fuel+1, index => do
      let tag := s!"{stem}{index}"
      let next ← liftTermElabM do
        let object ← field (←mkAppM ``St.obj? #[state,address]) ``Option.some 2 1
        let found ←whnf (←mkAppM ``findProp #[←mkAppM ``PKey.str #[toExpr property],←mkAppM ``Obj.props #[object]])
        addData (pre ++ Name.mkSimple (tag++"Address")) address
        addData (pre ++ Name.mkSimple (tag++"Object")) object
        if found.isAppOfArity ``Option.some 2 then
          let value ←whnf found.getAppArgs[1]!
          unless value.isAppOfArity ``PropV.data 3 do throwError "host_retained_dispose: expected current data method"
          let callee ←field value.getAppArgs[0]! ``Val.obj 1 0
          let roleStem := if stem == "registryPath" then "registry" else "module"
          let fn := if stem == "registryPath" then "unregisterFn" else "freeFn"
          addData (pre ++ Name.mkSimple fn) callee
          addData (pre ++ Name.mkSimple (roleStem++"Writable")) value.getAppArgs[1]!
          addData (pre ++ Name.mkSimple (roleStem++"Enumerable")) value.getAppArgs[2]!
          return none
        let proto ←field (←mkAppM ``Obj.proto #[object]) ``Val.obj 1 0
        addData (pre ++ Name.mkSimple (tag++"Next")) proto
        return some proto
      let base := n++"."++tag
      fact (tag++"Read") s!"{n}.input.heap.get {base}Address = some (.obj {base}Object)"
      fact (tag++"Kind") s!"{base}Object.kind = .ordinary"
      let propertyText := if stem == "registryPath" then "Dispose.unregister" else "Dispose.free"
      match next with
      | none =>
        let roleStem := if stem == "registryPath" then "registry" else "module"
        let fn := if stem == "registryPath" then "unregisterFn" else "freeFn"
        fact (tag++"Find") s!"findProp (.str {propertyText}) {base}Object.props = some (.data (.obj {n}.{fn}) {n}.{roleStem}Writable {n}.{roleStem}Enumerable)"
        return s!"OrdinaryLookup.hit {fuel} {base}Address {base}Object _ {base}Read {base}Kind {base}Find"
      | some address =>
        fact (tag++"Find") s!"findProp (.str {propertyText}) {base}Object.props = none"
        fact (tag++"Proto") s!"{base}Object.proto = .obj {base}Next"
        let child ← choose address fuel (index+1)
        return s!"OrdinaryLookup.next {fuel} {base}Address {base}Next {base}Object {base}Read {base}Kind {base}Find {base}Proto ({child})"
  choose initial 16 0

private def generateDispose (f s initial t next : Syntax) (name : TSyntax `ident) : CommandElabM Unit := do
  let pre := (←getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ←Term.elabTermEnsuringType f (mkConst ``Ffi)
    unless ←isDefEq f (mkConst ``Host.Load.ffi) do throwError "host_retained_dispose: expected actual load FFI"
    let ty := mkApp (mkConst ``St) (mkConst ``Host.Load.LSt)
    let s ←Term.elabTermEnsuringType s ty
    let t ←Term.elabTermEnsuringType t ty
    let ctl ←whnf (←mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_dispose: expected current source call"
    let method ←field ctl.getAppArgs[0]! ``Val.obj 1 0
    let owner ←field ctl.getAppArgs[1]! ``Val.obj 1 0
    unless (←whnf ctl.getAppArgs[2]!).isAppOfArity ``List.nil 1 do throwError "host_retained_dispose: expected zero arguments"
    let methodObject ←field (←mkAppM ``St.obj? #[s,method]) ``Option.some 2 1
    let code ←whnf (←field (←mkAppM ``Obj.kind #[methodObject]) ``Kind.fn 1 0)
    unless code.isAppOfArity ``Code.closure 4 do throwError "host_retained_dispose: expected source closure"
    unless ←isDefEq code.getAppArgs[0]! (mkConst ``Dispose.function) do throwError "host_retained_dispose: expected pinned dispose function"
    let env := code.getAppArgs[1]!
    let ownerObject ←field (←mkAppM ``St.obj? #[s,owner]) ``Option.some 2 1
    let brand ←field (←mkAppM ``lookupEnv #[←mkAppM ``privName #[toExpr chars!"disposed"],env]) ``Option.some 2 1
    let privateField (name : Host.Ts.Name) := do field (←mkAppM ``findPriv #[brand,toExpr name,←mkAppM ``Obj.priv #[ownerObject]]) ``Option.some 2 1
    let disposed ←whnf (←privateField chars!"disposed")
    let handle ←whnf (←privateField chars!"handle")
    let token ←whnf (←privateField chars!"token")
    let handleId ←mkAppM ``Int.toNat #[←field handle.getAppArgs[0]! ``Val.big 1 0]
    let tokenAddress ←field token.getAppArgs[0]! ``Val.obj 1 0
    let registryCell ←field (←mkAppM ``lookupEnv #[toExpr chars!"registry",env]) ``Option.some 2 1
    let moduleCell ←field (←mkAppM ``lookupEnv #[toExpr chars!"C",env]) ``Option.some 2 1
    let cellObject (a : Lean.Expr) := do field (←field (←field (←mkAppM ``St.cell? #[s,a]) ``Option.some 2 1) ``Option.some 2 1) ``Val.obj 1 0
    let registryAddress ←cellObject registryCell
    let moduleAddress ←cellObject moduleCell
    for (tag,value) in [("F",f),("input",s),("output",t),("method",method),("owner",owner),("brand",brand),
      ("methodObject",methodObject),("ownerObject",ownerObject),("env",env),("home",code.getAppArgs[3]!),
      ("arrayHandle",handleId),("tokenAddress",tokenAddress),("registryCell",registryCell),("moduleCell",moduleCell),
      ("registryAddress",registryAddress),("moduleAddress",moduleAddress),("flagEnumerable",disposed.getAppArgs[2]!),
      ("handleWritable",handle.getAppArgs[1]!),("handleEnumerable",handle.getAppArgs[2]!),
      ("tokenWritable",token.getAppArgs[1]!),("tokenEnumerable",token.getAppArgs[2]!)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some ty else none)
    addData (pre ++ `span) (mkNatLit 40)
    addData (pre ++ `initialServer) (←mkAppM ``numberServer #[←Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (←mkAppM ``numberServer #[←Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let registryPath ←disposePath pre (mkConst (pre++`input)) "registryPath" chars!"unregister" (mkConst (pre++`registryAddress))
  let modulePath ←disposePath pre (mkConst (pre++`input)) "modulePath" chars!"mlx_array_free" (mkConst (pre++`moduleAddress))
  liftTermElabM do
    let s := mkConst (pre++`input)
    let unregisterObject ←field (←mkAppM ``St.obj? #[s,mkConst (pre++`unregisterFn)]) ``Option.some 2 1
    let unregisterCode ←field (←mkAppM ``Obj.kind #[unregisterObject]) ``Kind.fn 1 0
    let unregisterData ←field unregisterCode ``Code.native 2 1
    let freeObject ←field (←mkAppM ``St.obj? #[s,mkConst (pre++`freeFn)]) ``Option.some 2 1
    let freeCode ←field (←mkAppM ``Obj.kind #[freeObject]) ``Kind.fn 1 0
    let captures ←field freeCode ``Code.native 2 1
    let rest ←field captures ``List.cons 3 2
    let types ←field (←field rest ``List.cons 3 1) ``Val.obj 1 0
    let rest ←field rest ``List.cons 3 2
    let returns ←field (←field rest ``List.cons 3 1) ``Val.str 1 0
    let signatureObject ←field (←mkAppM ``St.obj? #[s,types]) ``Option.some 2 1
    for (tag,value) in [("unregisterObject",unregisterObject),("unregisterData",unregisterData),
      ("freeObject",freeObject),("types",types),("returns",returns),("signatureObject",signatureObject)] do
      addData (pre ++ Name.mkSimple tag) value
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated Host.Load.Run.Full.Ordinary in\n"
  let fields := ["method","owner","brand","registryCell","registryAddress","unregisterFn","moduleCell","moduleAddress","freeFn","types","tokenAddress","arrayHandle",
    "methodObject","ownerObject","unregisterObject","freeObject","signatureObject","env","home","unregisterData","returns",
    "flagEnumerable","handleWritable","handleEnumerable","tokenWritable","tokenEnumerable","registryWritable","registryEnumerable","moduleWritable","moduleEnumerable"]
  Parametric.Driver.emit (header ++ s!"noncomputable def {n}.data : Dispose.SourceData := " ++ "{" ++
    String.intercalate "," (fields.map fun field => s!"{field} := {n}.{field}") ++ "}")
  Parametric.Driver.emit (header ++ s!"theorem {n}.registry_path : OrdinaryLookup {n}.input Dispose.unregister 16 {n}.registryAddress
    (some (.data (.obj {n}.unregisterFn) {n}.registryWritable {n}.registryEnumerable)) := {registryPath}")
  Parametric.Driver.emit (header ++ s!"theorem {n}.module_path : OrdinaryLookup {n}.input Dispose.free 16 {n}.moduleAddress
    (some (.data (.obj {n}.freeFn) {n}.moduleWritable {n}.moduleEnumerable)) := {modulePath}")
  let entries := ["control","methodRead","methodKind","ownerRead","ordinary","disposed","handleRead","tokenRead","flagLookup","handleLookup","tokenLookup",
    "registryLookup","moduleLookup","registryCellRead","moduleCellRead","unregisterRead","unregisterKind","freeRead","freeKind","signatureRead","signatureKind"]
  let record := String.intercalate "," (entries.map fun field => s!"{field} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_entry (live : Nat → Prop)
    (registryLive : live {n}.registryAddress) (moduleLive : live {n}.moduleAddress) : Dispose.SourceEntry {n}.data live {n}.input := by
    refine " ++ "{" ++ s!"{record},registryPath := {n}.registry_path,modulePath := {n}.module_path,registryLive := registryLive,moduleLive := moduleLive,below := ?_" ++ "}" ++ "
    intro a member
    simp only [List.mem_cons,List.not_mem_nil,or_false] at member
    rcases member with rfl|rfl|rfl|rfl|rfl|rfl <;> decide +kernel")
  let fact (tag type : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by host_kernel_rfl")
  fact "source_output" s!"Dispose.successResult {n}.input {n}.data = {n}.output"
  fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
  fact "source_run (C : CSrv)" s!"runC {n}.F 40 {n}.input C = some ({n}.output,C)"
  for (tag,type) in [("source_bound",s!"{n}.input.next+2 ≤ 2^64"),("handle_bound",s!"{n}.arrayHandle < 2^64"),
      ("source_nonzero",s!"{n}.arrayHandle ≠ 0")] do
    Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {type} := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
    (inst : Inst ν₀ {n}.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' {n}.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (handleNote : notes.privates.owners {n}.owner = some ⟨{n}.brand,Dispose.handle,.handle {n}.arrayHandle⟩)
    (registryLive : live {n}.registryAddress) (moduleLive : live {n}.moduleAddress)
    (signatureFrame : ¬ framed {n}.types) (handleLive : H {n}.arrayHandle)
    (targetBound : s.next+2 ≤ 2^64) (targetHandleBound : s.ffi.mlx.next < 2^64) :
    ∃ result, runC {n}.F 40 s C = some (result,C) ∧ runC {n}.F 40 {n}.input C₀ = some ({n}.output,C₀) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects (fun i => H i ∧ i ≠ {n}.arrayHandle) N tail host)
        R (Dispose.liveAfter live {n}.input {n}.env {n}.home {n}.owner) framed before after old old' {n}.output result ∧
      RetainedInventory (Dispose.successNotes notes {n}.input.next {n}.owner) ν₀ ν C₀ C R
        (Dispose.liveAfter live {n}.input {n}.env {n}.home {n}.owner) {n}.output result ∧
      Inst ν₀ {n}.nextServer C₀ ∧ ProducerAnnotations roots (fun i => H i ∧ i ≠ {n}.arrayHandle) N nodes objects ∧
      ProducerSupport roots (fun i => H i ∧ i ≠ {n}.arrayHandle) N {n}.output.ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i))
        (resourceImage R.handle (fun i => H i ∧ i ≠ {n}.arrayHandle)) (resourceImage R.node N) result.ffi.mlx := by
    obtain ⟨result,left,right,post,retained,policy',support,targetSupport⟩ := Dispose.successful_call inventory h policy
      {n}.data ({n}.source_entry live registryLive moduleLive) handleNote signatureFrame handleLive {n}.source_nonzero
      {n}.source_bound targetBound {n}.handle_bound targetHandleBound
    rw [{n}.source_output] at left post retained support
    exact ⟨result,right,left,post,retained,{n}.source_servers ▸ inst,policy',support,targetSupport⟩")

/-- Extraction may choose metadata, but every syntax/read/run/endpoint fact is
kernel checked. Failure restores all declarations and messages from this call. -/
def elaborateDispose (f s initial t next : Syntax) (name : TSyntax `ident) : CommandElabM Unit := do
  let saved : Command.State ←get
  try
    generateDispose f s initial t next name
    if (←get).messages.hasErrors then
      let messages ←(←get).messages.toList.mapM fun message => message.data.toString
      throwError "host_retained_dispose: kernel rejected generated source contract\n{String.intercalate "\n" messages}"
  catch error =>
    set saved
    throw error

elab "host_retained_dispose " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command =>
  elaborateDispose f.raw s.raw initial.raw t.raw next.raw name
end Host.Ts.Owned.Annotated.Driver
