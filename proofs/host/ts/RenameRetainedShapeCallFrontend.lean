import host.ts.RenameRetainedShapeCall
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

private def emitShapeChecked (source : String) (declaration : String := "generated source contract") : CommandElabM Unit := do
  let count := (← get).messages.reportedPlusUnreported.toList.length
  Parametric.Driver.emit source
  let errors := ((← get).messages.reportedPlusUnreported.toList.drop count).filter (fun m => m.severity == .error)
  unless errors.isEmpty do
    let rendered ← errors.mapM fun m => m.data.toString
    throwError "host_retained_shape_call: kernel rejected {declaration}\n{String.intercalate "\n" rendered}"

private def generateShapeCall (f s initial t next : Syntax) (name : TSyntax `ident) : CommandElabM Unit := do
  let pre := (← getCurrNamespace) ++ name.getId
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Load.Run.Full.Ordinary Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles in\n"
  let fact (tag proposition : String) := emitShapeChecked (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl") (n++"."++tag)
  liftTermElabM do
    let stateTy := mkApp (mkConst ``St) (mkConst ``Host.Load.LSt)
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let source ← Term.elabTermEnsuringType s stateTy
    let target ← Term.elabTermEnsuringType t stateTy
    let ctl ← mkAppM ``St.ctl #[source]
    let shapeGetter ← field (← field ctl ``Ctl.call 3 0) ``Val.obj 1 0
    let owner ← field (← field ctl ``Ctl.call 3 1) ``Val.obj 1 0
    let object ← field (← mkAppM ``St.obj? #[source,shapeGetter]) ``Option.some 2 1
    let closure ← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0
    for (tag,value) in [("F",f),("input",source),("output",target),("shapeGetter",shapeGetter),("owner",owner),("shapeObject",object),
      ("shapeEnv",← field closure ``Code.closure 4 1),("shapeHome",← field closure ``Code.closure 4 3)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    addData (pre ++ `span) (mkNatLit 115)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let makePath (tag rootAddress : String) (roleName : Lean.Name) : CommandElabM Unit := do
    let rec choose (address : Lean.Expr) : Nat → Nat → CommandElabM String
      | 0, _ => throwError "host_retained_shape_call: exhausted ordinary source path"
      | fuel+1, index => do
        let stem := s!"{n}.{tag}{index}"
        let next ← liftTermElabM do
          let object ← field (← mkAppM ``St.obj? #[mkConst (pre ++ `input),address]) ``Option.some 2 1
          let property ← whnf (← mkAppM ``findProp #[mkApp (mkConst ``PKey.str) (mkConst roleName),← mkAppM ``Obj.props #[object]])
          addData (pre ++ Name.mkSimple s!"{tag}{index}Address") address
          addData (pre ++ Name.mkSimple s!"{tag}{index}Object") object
          if property.isAppOfArity ``Option.some 2 then
            addData (pre ++ Name.mkSimple s!"{tag}Property") property.getAppArgs[1]!
            return none
          return some (← field (← mkAppM ``Obj.proto #[object]) ``Val.obj 1 0)
        fact s!"{tag}{index}Read" s!"{n}.input.heap.get {stem}Address = some (.obj {stem}Object)"
        fact s!"{tag}{index}Kind" s!"{stem}Object.kind = .ordinary"
        match next with
        | none =>
          fact s!"{tag}{index}Find" s!"findProp (.str _root_.{roleName}) {stem}Object.props = some {n}.{tag}Property"
          return s!"OrdinaryLookup.hit {fuel} {stem}Address {stem}Object _ {stem}Read {stem}Kind {stem}Find"
        | some next =>
          liftTermElabM <| addData (pre ++ Name.mkSimple s!"{tag}{index}Next") next
          fact s!"{tag}{index}Find" s!"findProp (.str _root_.{roleName}) {stem}Object.props = none"
          fact s!"{tag}{index}Proto" s!"{stem}Object.proto = .obj {stem}Next"
          let child ← choose next fuel (index+1)
          return s!"OrdinaryLookup.next {fuel} {stem}Address {stem}Next {stem}Object {stem}Read {stem}Kind {stem}Find {stem}Proto ({child})"
    let path ← choose (mkConst (pre ++ Name.mkSimple rootAddress)) 16 0
    emitShapeChecked (header ++ s!"theorem {n}.{tag}Path : OrdinaryLookup {n}.input _root_.{roleName} 16 {n}.{rootAddress} (some {n}.{tag}Property) := {path}")
  makePath "ndim" "owner" ``ShapeCall.ndimName
  makePath "getter" "owner" ``NdimCall.handleName
  liftTermElabM do
    let source := mkConst (pre ++ `input)
    let get (tag : String) := mkConst (pre ++ Name.mkSimple tag)
    let save (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let object (address : Lean.Expr) : TermElabM Lean.Expr := do field (← mkAppM ``St.obj? #[source,address]) ``Option.some 2 1
    for (family,property) in [("ndim",get "ndimProperty"),("handle",get "getterProperty")] do
      save (if family == "ndim" then "ndimGetter" else "getter") (← field (← field property ``PropV.acc 3 0) ``Val.obj 1 0)
      save (if family == "ndim" then "ndimSetter" else "handleSetter") (← field property ``PropV.acc 3 1)
      save (if family == "ndim" then "nge" else "hge") (← field property ``PropV.acc 3 2)
    let ndimObject ← object (get "ndimGetter")
    let ndimClosure ← field (← mkAppM ``Obj.kind #[ndimObject]) ``Kind.fn 1 0
    save "ndimObject" ndimObject
    save "ndimEnv" (← field ndimClosure ``Code.closure 4 1)
    save "ndimHome" (← field ndimClosure ``Code.closure 4 3)
    let moduleCell ← field (← mkAppM ``lookupEnv #[mkConst ``NdimCall.nativeModule,get "ndimEnv"]) ``Option.some 2 1
    save "moduleCell" moduleCell
    let module ← field (← field (← field (← mkAppM ``PTrie.get #[← mkAppM ``St.heap #[source],moduleCell]) ``Option.some 2 1) ``HObj.cell 1 0) ``Option.some 2 1
    save "module" (← field module ``Val.obj 1 0)
    let getterObject ← object (get "getter")
    let getterClosure ← field (← mkAppM ``Obj.kind #[getterObject]) ``Kind.fn 1 0
    let fn ← field getterClosure ``Code.closure 4 0
    let statements ← field (← field fn ``Func.mk 7 3) ``Body.block 1 0
    let test ← field statements ``List.cons 3 1
    let rest ← field statements ``List.cons 3 2
    let disposed ← field (← field test ``Stmt.if_ 3 0) ``Expr.priv 3 1
    let privateName ← field (← field (← field (← field rest ``List.cons 3 1) ``Stmt.ret 1 0) ``Option.some 2 1) ``Expr.priv 3 1
    let getEnv ← field getterClosure ``Code.closure 4 1
    let brand ← field (← mkAppM ``lookupEnv #[← mkAppM ``privName #[privateName],getEnv]) ``Option.some 2 1
    let ownerObject ← object (get "owner")
    let disposedProperty ← field (← mkAppM ``findPriv #[brand,disposed,← mkAppM ``Obj.priv #[ownerObject]]) ``Option.some 2 1
    let handleProperty ← field (← mkAppM ``findPriv #[brand,privateName,← mkAppM ``Obj.priv #[ownerObject]]) ``Option.some 2 1
    let handle ← field (← field handleProperty ``PropV.data 3 0) ``Val.big 1 0
    let handle ← whnf (← mkAppM ``Int.toNat #[handle])
    for (tag,value) in [("getterObject",getterObject),("getName",← field fn ``Func.mk 7 0),("getEnv",getEnv),
      ("getHome",← field getterClosure ``Code.closure 4 3),("disposed",disposed),("field",privateName),("yes",← field test ``Stmt.if_ 3 1),
      ("brand",brand),("object",ownerObject),("handle",handle),("dw",← field disposedProperty ``PropV.data 3 1),
      ("de",← field disposedProperty ``PropV.data 3 2),("hw",← field handleProperty ``PropV.data 3 1),("he",← field handleProperty ``PropV.data 3 2)] do save tag value
    let native ← mkAppM ``Host.Load.LSt.mlx #[← mkAppM ``St.ffi #[source]]
    save "node" (← field (← mkAppM ``Host.Mlx.Ffi.St.node? #[native,handle]) ``Option.some 2 1)
    save "producer" (← field (← mkAppM ``PTrie.get #[← mkAppM ``Host.Mlx.Ffi.St.arrs #[native],handle]) ``Option.some 2 1)
    let global ← object (mkConst ``aGlobal)
    save "global" global
    for (family,roleName) in [("number",``NdimCall.numberName),("typed",``ShapeCall.typedName)] do
      let property ← field (← mkAppM ``findProp #[mkApp (mkConst ``PKey.str) (mkConst roleName),← mkAppM ``Obj.props #[global]]) ``Option.some 2 1
      save (family++"Fn") (← field (← field property ``PropV.data 3 0) ``Val.obj 1 0)
      save (if family == "number" then "nw" else "tw") (← field property ``PropV.data 3 1)
      save (if family == "number" then "ne" else "te") (← field property ``PropV.data 3 2)
    let numberObject ← object (get "numberFn")
    save "numberObject" numberObject
    save "numberData" (← field (← field (← mkAppM ``Obj.kind #[numberObject]) ``Kind.fn 1 0) ``Code.native 2 1)
    let bufferCell ← field (← mkAppM ``lookupEnv #[mkConst ``ShapeCall.bufferName,get "shapeEnv"]) ``Option.some 2 1
    save "bufferCell" bufferCell
    let bufferValue ← field (← field (← mkAppM ``PTrie.get #[← mkAppM ``St.heap #[source],bufferCell]) ``Option.some 2 1) ``HObj.cell 1 0
    let bufferFn ← field (← field bufferValue ``Option.some 2 1) ``Val.obj 1 0
    save "bufferFn" bufferFn
    let bufferObject ← object bufferFn
    save "bufferObject" bufferObject
    save "bufferData" (← field (← field (← mkAppM ``Obj.kind #[bufferObject]) ``Kind.fn 1 0) ``Code.native 2 1)
    let typedObject ← object (get "typedFn")
    save "typedObject" typedObject
    let typedData ← field (← field (← mkAppM ``Obj.kind #[typedObject]) ``Kind.fn 1 0) ``Code.native 2 1
    save "kindValue" (← field (← field (← field typedData ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0)
    let typedData ← field typedData ``List.cons 3 2
    let proto ← field (← field (← field typedData ``List.cons 3 1) ``Val.num 1 0) ``NumV.lit 1 0
    save "protoValue" proto
    save "typedProto" (← field (← mkAppM ``F64.toIndex? #[proto]) ``Option.some 2 1)
  makePath "ndimNative" "module" ``NdimCall.nativeName
  makePath "shapeNative" "module" ``ShapeCall.nativeName
  liftTermElabM do
    let source := mkConst (pre ++ `input)
    let get (tag : String) := mkConst (pre ++ Name.mkSimple tag)
    let save (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    for family in ["ndim","shape"] do
      let property := get (family++"NativeProperty")
      let fn ← field (← field property ``PropV.data 3 0) ``Val.obj 1 0
      save (family++"Fn") fn
      save (if family == "ndim" then "nmw" else "smw") (← field property ``PropV.data 3 1)
      save (if family == "ndim" then "nme" else "sme") (← field property ``PropV.data 3 2)
      let object ← field (← mkAppM ``St.obj? #[source,fn]) ``Option.some 2 1
      save (family++"Native") object
      let data ← field (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0) ``Code.native 2 1
      let rest ← field data ``List.cons 3 2
      let types ← field (← field rest ``List.cons 3 1) ``Val.obj 1 0
      save (family++"Types") types
      save (family++"Returns") (← field (← field (← field rest ``List.cons 3 2) ``List.cons 3 1) ``Val.str 1 0)
      save (family++"Signature") (← field (← mkAppM ``St.obj? #[source,types]) ``Option.some 2 1)
  let fields : List (String × String) := [
    ("shapeGetter",s!"{n}.shapeGetter"),
    ("ndimGetter",s!"{n}.ndimGetter"),
    ("owner",s!"{n}.owner"),
    ("getter",s!"{n}.getter"),
    ("brand",s!"{n}.brand"),
    ("numberFn",s!"{n}.numberFn"),
    ("ndimFn",s!"{n}.ndimFn"),
    ("shapeFn",s!"{n}.shapeFn"),
    ("moduleCell",s!"{n}.moduleCell"),
    ("module",s!"{n}.module"),
    ("ndimTypes",s!"{n}.ndimTypes"),
    ("shapeTypes",s!"{n}.shapeTypes"),
    ("handle",s!"{n}.handle"),
    ("producer",s!"{n}.producer"),
    ("typedFn",s!"{n}.typedFn"),
    ("bufferCell",s!"{n}.bufferCell"),
    ("bufferFn",s!"{n}.bufferFn"),
    ("typedProto",s!"{n}.typedProto"),
    ("shapeObject",s!"{n}.shapeObject"),
    ("ndimObject",s!"{n}.ndimObject"),
    ("getterObject",s!"{n}.getterObject"),
    ("object",s!"{n}.object"),
    ("global",s!"{n}.global"),
    ("numberObject",s!"{n}.numberObject"),
    ("ndimNative",s!"{n}.ndimNative"),
    ("shapeNative",s!"{n}.shapeNative"),
    ("ndimSignature",s!"{n}.ndimSignature"),
    ("shapeSignature",s!"{n}.shapeSignature"),
    ("typedObject",s!"{n}.typedObject"),
    ("bufferObject",s!"{n}.bufferObject"),
    ("shapeEnv",s!"{n}.shapeEnv"),
    ("ndimEnv",s!"{n}.ndimEnv"),
    ("getEnv",s!"{n}.getEnv"),
    ("shapeHome",s!"{n}.shapeHome"),
    ("ndimHome",s!"{n}.ndimHome"),
    ("getHome",s!"{n}.getHome"),
    ("getName",s!"{n}.getName"),
    ("disposed",s!"{n}.disposed"),
    ("field",s!"{n}.field"),
    ("yes",s!"{n}.yes"),
    ("nw",s!"{n}.nw"),
    ("ne",s!"{n}.ne"),
    ("nmw",s!"{n}.nmw"),
    ("nme",s!"{n}.nme"),
    ("smw",s!"{n}.smw"),
    ("sme",s!"{n}.sme"),
    ("nge",s!"{n}.nge"),
    ("hge",s!"{n}.hge"),
    ("dw",s!"{n}.dw"),
    ("de",s!"{n}.de"),
    ("hw",s!"{n}.hw"),
    ("he",s!"{n}.he"),
    ("tw",s!"{n}.tw"),
    ("te",s!"{n}.te"),
    ("ndimSetter",s!"{n}.ndimSetter"),
    ("handleSetter",s!"{n}.handleSetter"),
    ("ndimReturns",s!"{n}.ndimReturns"),
    ("shapeReturns",s!"{n}.shapeReturns"),
    ("numberData",s!"{n}.numberData"),
    ("bufferData",s!"{n}.bufferData"),
    ("kindValue",s!"{n}.kindValue"),
    ("protoValue",s!"{n}.protoValue"),
    ("node",s!"{n}.node"),
    ("control","by host_kernel_rfl"),
    ("shapeRead","by host_kernel_rfl"),
    ("shapeKind","by host_kernel_rfl"),
    ("ndimPath",s!"{n}.ndimPath"),
    ("ndimRead","by host_kernel_rfl"),
    ("ndimKind","by host_kernel_rfl"),
    ("numberLookup","by host_kernel_rfl"),
    ("globalRead","by host_kernel_rfl"),
    ("globalKind","by host_kernel_rfl"),
    ("numberProperty","by host_kernel_rfl"),
    ("ndimModuleLookup","by host_kernel_rfl"),
    ("shapeModuleLookup","by host_kernel_rfl"),
    ("moduleRead","by host_kernel_rfl"),
    ("ndimNativePath",s!"{n}.ndimNativePath"),
    ("shapeNativePath",s!"{n}.shapeNativePath"),
    ("getterPath",s!"{n}.getterPath"),
    ("getterRead","by host_kernel_rfl"),
    ("getterKind","by host_kernel_rfl"),
    ("objectRead","by host_kernel_rfl"),
    ("ordinary","by host_kernel_rfl"),
    ("disposedValue","by host_kernel_rfl"),
    ("handleValue","by host_kernel_rfl"),
    ("disposedLookup","by host_kernel_rfl"),
    ("handleLookup","by host_kernel_rfl"),
    ("disposedNames","by decide +kernel"),
    ("handleNames","by decide +kernel"),
    ("numberRead","by host_kernel_rfl"),
    ("numberKind","by host_kernel_rfl"),
    ("ndimNativeRead","by host_kernel_rfl"),
    ("ndimNativeKind","by host_kernel_rfl"),
    ("shapeNativeRead","by host_kernel_rfl"),
    ("shapeNativeKind","by host_kernel_rfl"),
    ("ndimSignatureRead","by host_kernel_rfl"),
    ("ndimSignatureKind","by host_kernel_rfl"),
    ("shapeSignatureRead","by host_kernel_rfl"),
    ("shapeSignatureKind","by host_kernel_rfl"),
    ("sourceNode","by host_kernel_rfl"),
    ("sourceProducer","by host_kernel_rfl"),
    ("nonzero","by host_kernel_rfl"),
    ("rankNonzero","by decide +kernel"),
    ("countIndex","by host_kernel_rfl"),
    ("typedLookup","by host_kernel_rfl"),
    ("typedProperty","by host_kernel_rfl"),
    ("bufferLookup","by host_kernel_rfl"),
    ("bufferRead","by host_kernel_rfl"),
    ("bufferFnRead","by host_kernel_rfl"),
    ("bufferKind","by host_kernel_rfl"),
    ("typedRead","by host_kernel_rfl"),
    ("typedKind","by host_kernel_rfl"),
    ("kindIndex","by host_kernel_rfl"),
    ("protoIndex","by host_kernel_rfl")]
  let entries := fields.map (fun (key,value) => key++" := "++value)
  emitShapeChecked (header ++ s!"noncomputable def {n}.sourceData : ShapeCall.Source {n}.input := "++"{ "++String.intercalate ", " entries++" }") (n++".sourceData")
  fact "source_ffi" s!"{n}.F = Host.Load.ffi"
  fact "source_endpoint" s!"{n}.sourceData.result = {n}.output"
  fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
  emitShapeChecked (header ++ s!"theorem {n}.source_bound : {n}.input.next+13 ≤ 2^64 := by decide +kernel")
  emitShapeChecked (header ++ s!"theorem {n}.retained_transport
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tokens : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St Host.Load.LSt)
    (inst : Inst ν₀ {n}.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tokens host) R live framed before after old old' {n}.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (globalLive : live aGlobal) (moduleCellLive : live {n}.sourceData.moduleCell) (moduleLive : live {n}.sourceData.module)
    (ownerLive : live {n}.sourceData.owner) (ndimGetterLive : live {n}.sourceData.ndimGetter)
    (getterLive : live {n}.sourceData.getter) (numberLive : live {n}.sourceData.numberFn)
    (ndimLive : live {n}.sourceData.ndimFn) (shapeLive : live {n}.sourceData.shapeFn)
    (ndimTypesLive : live {n}.sourceData.ndimTypes) (shapeTypesLive : live {n}.sourceData.shapeTypes)
    (bufferCellLive : live {n}.sourceData.bufferCell) (bufferFnLive : live {n}.sourceData.bufferFn) (typedFnLive : live {n}.sourceData.typedFn)
    (globalFixed : R.a aGlobal = aGlobal) (ndimFrame : ¬ framed {n}.sourceData.ndimTypes) (shapeFrame : ¬ framed {n}.sourceData.shapeTypes)
    (owned : H {n}.sourceData.handle) (region : R.region (4*{n}.sourceData.handle) = 4*R.handle {n}.sourceData.handle)
    (fieldNote : notes.privates.owners {n}.sourceData.owner = some ⟨{n}.sourceData.brand,{n}.sourceData.field,.handle {n}.sourceData.handle⟩)
    (constructor : NativeCaptureNote) (capture : notes.captures.owners {n}.sourceData.typedFn = some constructor)
    (codeNote : constructor.roles 0 = some (.literal (.lit {n}.sourceData.kindValue)))
    (protoNote : constructor.roles 1 = some (.literal (.lit {n}.sourceData.protoValue)))
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live {n}.sourceData.typedProto) (typedFixed : R.a {n}.sourceData.typedProto = {n}.sourceData.typedProto)
    (controlNote : notes.runtime.control = callNote (.obj {n}.sourceData.shapeGetter) (.obj {n}.sourceData.owner) [])
    (targetBound : s.next+13 ≤ 2^64) :
    ∃ result, runC Host.Load.ffi 115 s C = some (result,C) ∧ runC Host.Load.ffi 115 {n}.input C₀ = some ({n}.output,C₀) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tokens host) R ({n}.sourceData.liveResult live) framed before after old old' {n}.output result ∧
      RetainedInventory ({n}.sourceData.notesResult notes nodes) ν₀ ν C₀ C R ({n}.sourceData.liveResult live) {n}.output result ∧
      Inst ν₀ {n}.nextServer C₀ ∧ ProducerAnnotations roots H N nodes objects ∧ ProducerSupport roots H N {n}.output.ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i)) (resourceImage R.handle H) (resourceImage R.node N) result.ffi.mlx := by
    have current : ShapeCall.Current {n}.sourceData notes live framed R H :=
      ⟨globalLive,moduleCellLive,moduleLive,ownerLive,ndimGetterLive,getterLive,numberLive,ndimLive,shapeLive,ndimTypesLive,shapeTypesLive,
        bufferCellLive,bufferFnLive,typedFnLive,globalFixed,ndimFrame,shapeFrame,owned,region,fieldNote,constructor,capture,codeNote,protoNote,
        arrayLive,arrayFixed,bufferLive,bufferFixed,typedLive,typedFixed,controlNote⟩
    obtain ⟨result,left,right,post,retained,_,_,policy',support,targetSupport⟩ := inventory.shape_call_block h policy {n}.sourceData current {n}.source_bound targetBound
    rw [{n}.source_endpoint] at left post retained support
    exact ⟨result,right,left,post,retained,{n}.source_servers ▸ inst,policy',support,targetSupport⟩")

/-- Every failed source selection restores declarations, messages, scopes and
all other Command.State fields before reporting its checked rejection. -/
def elaborateShapeCall (f s initial t next : Syntax) (name : TSyntax `ident) : CommandElabM Unit := do
  let saved : Command.State ← get
  let count := saved.messages.reportedPlusUnreported.toList.length
  try
    generateShapeCall f s initial t next name
    let errors := ((← get).messages.reportedPlusUnreported.toList.drop count).filter (fun m => m.severity == .error)
    unless errors.isEmpty do
      let rendered ← errors.mapM fun m => m.data.toString
      throwError "host_retained_shape_call: kernel rejected generated source contract\n{String.intercalate "\n" rendered}"
  catch error =>
    set saved
    throw error

elab "host_retained_shape_call " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command =>
  elaborateShapeCall f.raw s.raw initial.raw t.raw next.raw name

end Host.Ts.Owned.Annotated.Driver
