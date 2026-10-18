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

/-- Namespace export cells use their retained roles; ordinary and array
prototype object methods use the initialized callee address selected by checked
source metadata. The original lookup supplies both heap-frame equations. -/
elab "host_retained_method " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  Parametric.Driver.emit s!"host_transport_preparation {← printed f.raw}, {← printed s.raw} to {← printed t.raw} as {name.getId}"
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
  if branch != "namespace" then
    let sourceObject := if branch == "array" then "sourceParent" else "sourceObject"
    fact "source_data" s!"findProp (.str {n}.sourceName) {n}.{sourceObject}.props = some (.data (.obj {n}.sourceCallee) {n}.sourceWritable {n}.sourceEnumerable)"
    if branch == "object" then
      Parametric.Driver.emit (header ++ s!"theorem {n}.source_path : OrdinaryLookup {n}.input {n}.sourceName 16 {n}.sourceAddress
        (some (.data (.obj {n}.sourceCallee) {n}.sourceWritable {n}.sourceEnumerable)) :=
        .hit 15 {n}.sourceAddress {n}.sourceObject _ {n}.source_heap {n}.source_kind {n}.source_data")
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
        {n}.source_path stackNotes")
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
