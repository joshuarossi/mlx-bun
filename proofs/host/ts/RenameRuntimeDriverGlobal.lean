import host.ts.RuntimeInventoryGlobal
import host.ts.RenameRuntimeStaticGlobal
import host.ts.RenameRuntimeDriverValues
import host.ts.RenameRouteDriverGlobal
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_retained_global: source syntax cannot be printed"

/-- A lexical miss selects initialized global metadata. Object constructors
and structural constants have forced roles; numeric data globals use the
current public inventory rather than a newly chosen interpretation. -/
elab "host_retained_global " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  Parametric.Driver.emit s!"host_transport_global {← printed f.raw}, {← printed s.raw} to {← printed t.raw} as {name.getId}"
  let branch ← liftTermElabM do
    let value ← whnf (mkConst (pre ++ `sourceValue))
    if value.isAppOfArity ``Val.obj 1 then
      Parametric.Driver.addData (pre ++ `sourceAddress) value.getAppArgs[0]!
      pure "object"
    else
      let role := if value.isConstOf ``Val.undef then some (mkConst ``Value.undef)
        else if value.isConstOf ``Val.null then some (mkConst ``Value.null)
        else if value.isAppOfArity ``Val.bool 1 then some (mkApp (mkConst ``Value.bool) value.getAppArgs[0]!)
        else if value.isAppOfArity ``Val.str 1 then some (mkApp (mkConst ``Value.str) value.getAppArgs[0]!)
        else none
      if let some role := role then
        Parametric.Driver.addData (pre ++ `sourceStaticRole) role
        pure "static"
      else pure "data"
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  if branch == "object" then
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_data : findProp (.str {n}.sourceName) {n}.sourceObject.props =
      some (.data (.obj {n}.sourceAddress) {n}.sourceWritable {n}.sourceEnumerable) := by host_kernel_rfl")
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_path : OrdinaryLookup {n}.input {n}.sourceName 16 aGlobal
      (some (.data (.obj {n}.sourceAddress) {n}.sourceWritable {n}.sourceEnumerable)) :=
      .hit 15 aGlobal {n}.sourceObject _ {n}.source_heap {n}.source_kind {n}.source_data")
  else if branch == "static" then
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_static : StaticValue {n}.sourceValue {n}.sourceStaticRole := by constructor")
  let parameters := s!"(notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)"
  let common := s!"{n}.F FR notes.runtime notes.heap notes.arrays notes.publicFields notes.buffers ν₀ ν C₀ C R live framed before after old old' {n}.input s h inventory.heapInventory inventory.arrays inventory.publicFields inventory.buffers"
  let (extra,role,body) := if branch == "object" then
      ("",s!"(.obj {n}.sourceAddress)",s!"
      obtain ⟨left,right,post,runtime,_,_,_,_⟩ := inventory.runtime.global_object_path_step {common}
        {n}.sourceName {n}.sourceEnv {n}.sourceAddress {n}.sourceWritable {n}.sourceEnumerable {n}.source_control
        {n}.source_local {n}.source_path globalLive globalFixed
      have retained := inventory.heap_step runtime rfl rfl (TableExtends.refl C₀) (TableExtends.refl C)")
    else if branch == "static" then
      ("",s!"{n}.sourceStaticRole",s!"
      obtain ⟨value,left,right,post,retained⟩ := inventory.global_static_step {n}.F FR h {n}.sourceName {n}.sourceEnv
        {n}.sourceObject {n}.sourceValue {n}.sourceStaticRole {n}.sourceWritable {n}.sourceEnumerable
        {n}.source_control {n}.source_local {n}.source_heap {n}.source_kind {n}.source_property
        {n}.source_static globalLive globalFixed")
    else
      (s!"(role : Annotated.Value) (entry : notes.publicFields.fields aGlobal {n}.sourceName = some role)","role",s!"
      obtain ⟨value,left,right,post,runtime,_,_,_,_⟩ := inventory.runtime.global_data_step {common}
        {n}.sourceName {n}.sourceEnv {n}.sourceObject {n}.sourceValue role {n}.sourceWritable {n}.sourceEnumerable
        {n}.source_control {n}.source_local {n}.source_heap {n}.source_kind {n}.source_property entry globalFixed
      have retained := inventory.heap_step runtime rfl rfl (TableExtends.refl C₀) (TableExtends.refl C)")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport {parameters} {extra} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.returning {role})) ν₀ ν C₀ C R live {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      {body}
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
