import host.ts.RuntimeInventoryMethod
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRouteDriverPreparation
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_retained_method: source syntax cannot be printed"

private def ordinaryMethodMetadata (pre : Lean.Name) (f s t : Syntax) : CommandElabM Bool := do
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← mkAppM ``St.ctl #[s]
    let address ← Parametric.Driver.field (← Parametric.Driver.field control ``Ctl.ret 1 0) ``Val.obj 1 0
    let object ← Parametric.Driver.field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let kind ← whnf (← mkAppM ``Obj.kind #[object])
    if !kind.isConstOf ``Kind.ordinary then return false
    let stack ← mkAppM ``St.stack #[s]
    let frame ← whnf (← Parametric.Driver.field (← Parametric.Driver.field stack ``List.cons 3 1) ``Frame.c 1 0)
    unless frame.isAppOfArity ``CallF.member 5 do throwError "host_retained_method: expected member frame"
    let args := frame.getAppArgs
    let name ← Parametric.Driver.field args[0]! ``PKey.str 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceAddress",address),("sourceObject",object),
      ("sourceValue",mkApp (mkConst ``Val.obj) address),("sourceName",name),("sourceArgs",args[1]!),
      ("sourceEnv",args[2]!),("sourceOptObject",args[3]!),("sourceOptCall",args[4]!),
      ("sourceTail",← Parametric.Driver.field stack ``List.cons 3 2)] do
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value
        (if tag == "input" || tag == "output" then some stateTy else none)
    return true

private def ordinaryMethodPath (pre : Lean.Name) : CommandElabM Unit := do
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret (.obj {n}.sourceAddress)"
  fact "source_frame" s!"{n}.input.stack = .c (.member (.str {n}.sourceName) {n}.sourceArgs {n}.sourceEnv {n}.sourceOptObject {n}.sourceOptCall)::{n}.sourceTail"
  let rec choosePath (address : Lean.Expr) : Nat → Nat → CommandElabM String
    | 0, _ => throwError "host_retained_method: exhausted ordinary prototype path"
    | fuel+1, index => do
      let stem := s!"{n}.path{index}"
      let next ← liftTermElabM do
        let object ← Parametric.Driver.field (← mkAppM ``St.obj? #[mkConst (pre ++ `input),address]) ``Option.some 2 1
        let property ← whnf (← mkAppM ``findProp #[mkApp (mkConst ``PKey.str) (mkConst (pre ++ `sourceName)),← mkAppM ``Obj.props #[object]])
        for (tag,value) in [(s!"path{index}Address",address),(s!"path{index}Object",object)] do
          Parametric.Driver.addData (pre ++ Name.mkSimple tag) value
        if property.isAppOfArity ``Option.some 2 then
          let data ← whnf property.getAppArgs[1]!
          unless data.isAppOfArity ``PropV.data 3 do throwError "host_retained_method: ordinary method is not data"
          for (tag,value) in [("sourceMethod",data.getAppArgs[0]!),("sourceWritable",data.getAppArgs[1]!),
            ("sourceEnumerable",data.getAppArgs[2]!)] do Parametric.Driver.addData (pre ++ Name.mkSimple tag) value
          return none
        let proto ← whnf (← mkAppM ``Obj.proto #[object])
        if proto.isConstOf ``Val.null then throwError "host_retained_method: method absent along ordinary prototype path"
        return some (← Parametric.Driver.field proto ``Val.obj 1 0)
      fact s!"path{index}Heap" s!"{n}.input.heap.get {stem}Address = some (.obj {stem}Object)"
      fact s!"path{index}Kind" s!"{stem}Object.kind = .ordinary"
      match next with
      | none =>
        fact s!"path{index}Find" s!"findProp (.str {n}.sourceName) {stem}Object.props = some (.data {n}.sourceMethod {n}.sourceWritable {n}.sourceEnumerable)"
        return s!"OrdinaryLookup.hit {fuel} {stem}Address {stem}Object _ {stem}Heap {stem}Kind {stem}Find"
      | some next =>
        liftTermElabM <| Parametric.Driver.addData (pre ++ Name.mkSimple s!"path{index}Next") next
        fact s!"path{index}Find" s!"findProp (.str {n}.sourceName) {stem}Object.props = none"
        fact s!"path{index}NextEq" s!"{stem}Object.proto = .obj {stem}Next"
        let child ← choosePath next fuel (index+1)
        return s!"OrdinaryLookup.next {fuel} {stem}Address {stem}Next {stem}Object {stem}Heap {stem}Kind {stem}Find {stem}NextEq ({child})"
  let path ← choosePath (mkConst (pre ++ `sourceAddress)) 16 0
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_path : OrdinaryLookup {n}.input {n}.sourceName 16 {n}.sourceAddress (some (.data {n}.sourceMethod {n}.sourceWritable {n}.sourceEnumerable)) := {path}")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")

/-- Namespace export cells use their retained roles; ordinary and array
prototype object methods use the initialized callee address selected by checked
source metadata. The original lookup supplies both heap-frame equations. -/
elab "host_retained_method " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let ordinary ← ordinaryMethodMetadata pre f.raw s.raw t.raw
  if ordinary then ordinaryMethodPath pre
  else Parametric.Driver.emit s!"host_transport_preparation {← printed f.raw}, {← printed s.raw} to {← printed t.raw} as {name.getId}"
  let env ← getEnv
  let branch := if env.contains (pre ++ `sourceExports) then "namespace"
    else if env.contains (pre ++ `sourceParent) then "array" else "object"
  liftTermElabM do
    unless branch == "namespace" do
      let callee ← Parametric.Driver.field (mkConst (pre ++ `sourceMethod)) ``Val.obj 1 0
      Parametric.Driver.addData (pre ++ `sourceCallee) callee
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  if branch == "array" then
    fact "source_data" s!"findProp (.str {n}.sourceName) {n}.sourceParent.props = some (.data (.obj {n}.sourceCallee) {n}.sourceWritable {n}.sourceEnumerable)"
  if branch == "object" then
    fact "source_object_method" s!"{n}.sourceMethod = .obj {n}.sourceCallee"
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_object_path : OrdinaryLookup {n}.input {n}.sourceName 16 {n}.sourceAddress
      (some (.data (.obj {n}.sourceCallee) {n}.sourceWritable {n}.sourceEnumerable)) := by
      simpa only [{n}.source_object_method] using {n}.source_path")
  let parameters := s!"(notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
      (stackNotes : notes.runtime.stack = headNote::tailNotes)"
  let common := s!"{n}.F FR notes.runtime notes.publicFields ν₀ ν C₀ C R live framed before after old old' {n}.input s h inventory.publicFields"
  let (extra,role,body) := if branch == "namespace" then
      (s!"(role : Annotated.Value) (entry : notes.runtime.cells.cells {n}.sourceCell = some role)","role",s!"
      obtain ⟨value,frames,left,right,post,runtime,_,sourceHeap,targetHeap⟩ := inventory.runtime.method_namespace_step {common}
        {n}.sourceAddress {n}.sourceCell {n}.sourceObject {n}.sourceExports {n}.sourceName {n}.sourceArgs {n}.sourceEnv
        {n}.sourceOptObject {n}.sourceOptCall {n}.sourceMethod role {n}.sourceTail headNote tailNotes
        {n}.source_control {n}.source_frame {n}.source_heap {n}.source_kind {n}.source_export {n}.source_cell entry stackNotes")
    else if branch == "array" then
      (s!"(notFramed : ¬ framed {n}.sourceAddress)",s!"(.obj {n}.sourceCallee)",s!"
      obtain ⟨frames,left,right,post,runtime,_,sourceHeap,targetHeap⟩ := inventory.runtime.method_array_step {common}
        {n}.sourceAddress {n}.sourcePrototype {n}.sourceCallee {n}.sourceObject {n}.sourceParent {n}.sourceElements
        {n}.sourceName {n}.sourceArgs {n}.sourceEnv {n}.sourceOptObject {n}.sourceOptCall {n}.sourceWritable
        {n}.sourceEnumerable {n}.sourceTail headNote tailNotes {n}.source_control {n}.source_frame {n}.source_heap
        {n}.source_kind {n}.source_nonindex {n}.source_nonlength {n}.source_absent {n}.source_prototype {n}.source_parent
        {n}.source_parentKind {n}.source_data notFramed stackNotes")
    else
      ("",s!"(.obj {n}.sourceCallee)",s!"
      obtain ⟨frames,left,right,post,runtime,_,sourceHeap,targetHeap⟩ := inventory.runtime.method_object_path_step {common}
        {n}.sourceAddress {n}.sourceCallee {n}.sourceName {n}.sourceArgs {n}.sourceEnv {n}.sourceOptObject {n}.sourceOptCall
        {n}.sourceWritable {n}.sourceEnumerable {n}.sourceTail headNote tailNotes {n}.source_control {n}.source_frame
        {n}.source_object_path stackNotes")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport {parameters} {extra} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.methodResult {n}.sourceAddress {n}.sourceArgs {n}.sourceEnv
          {n}.sourceOptCall {role} tailNotes)) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      {body}
      have retained := inventory.heap_step runtime sourceHeap targetHeap (TableExtends.refl C₀) (TableExtends.refl C)
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
