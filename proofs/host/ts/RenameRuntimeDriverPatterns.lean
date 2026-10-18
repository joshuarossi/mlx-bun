import host.ts.RenameRuntimeDriverValues
import host.ts.RenameRouteDriverBinding
import host.ts.RuntimeInventoryArrayBinding
import host.ts.RuntimeInventoryDefaultBinding
import host.ts.RuntimeInventoryObjectBinding
import host.ts.RenameRetainedStores

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_retained_pattern: source syntax cannot be printed"

/-- Select original array-pattern, initialized identifier and declaration
continuations. All source metadata, symbolic steps and original endpoints are
kernel checked before the retained transport theorem is accepted. -/
elab "host_retained_pattern " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let branch ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    if control.isAppOfArity ``Ctl.bind 5 then
      let pattern ← whnf control.getAppArgs[0]!
      if pattern.isAppOfArity ``Pat.array 2 then pure "array"
      else if pattern.isAppOfArity ``Pat.id 1 then pure "init"
      else throwError "host_retained_pattern: unsupported binding pattern"
    else
      unless control.isAppOfArity ``Ctl.ret 1 do throwError "host_retained_pattern: expected binding or return control"
      let frame ← whnf (← Parametric.Driver.field (← mkAppM ``St.stack #[s]) ``List.cons 3 1)
      if frame.isAppOfArity ``Frame.b 1 then
        unless (← whnf frame.getAppArgs[0]!).isAppOfArity ``BindF.arr 6 do
          throwError "host_retained_pattern: unsupported binding continuation"
        pure "next"
      else
        let statement ← whnf (← Parametric.Driver.field frame ``Frame.s 1 0)
        unless statement.isAppOfArity ``StmtF.declNext 3 do
          throwError "host_retained_pattern: unsupported declaration continuation"
        pure "declNext"
  Parametric.Driver.emit s!"host_transport_binding {← printed f.raw}, {← printed s.raw} to {← printed t.raw} as {name.getId}"
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let (extra,postNotes,call,results) := if branch == "array" then
      (s!"(roles : List Annotated.Value) (entry : notes.arrays.owners {n}.sourceAddress = some roles)",
       s!"notes.withRuntime (notes.runtime.arrayBinding {n}.sourcePatterns roles {n}.sourceEnv {n}.sourceMode {n}.sourceKind)",
       s!"RetainedInventory.array_binding_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h inventory
         {n}.sourcePatterns {n}.sourceAddress {n}.sourceObject {n}.sourceValues roles {n}.sourceEnv {n}.sourceMode {n}.sourceKind
         {n}.source_control {n}.source_heap {n}.source_kind entry",
       "values,left,right,post,retained")
    else if branch == "next" then
      (s!"(roles : List Annotated.Value) (tailNotes : List Annotated.Tree)
        (stackNotes : notes.runtime.stack = arrayBindingFrameNote {n}.sourcePatterns roles {n}.sourceEnv {n}.sourceMode {n}.sourceKind::tailNotes)",
       s!"notes.withRuntime (" ++ "{" ++ s!"notes.runtime with stack := tailNotes" ++ "}" ++ s!".arrayBinding {n}.sourcePatterns roles {n}.sourceEnv {n}.sourceMode {n}.sourceKind)",
       s!"RetainedInventory.array_binding_next_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h inventory
         {n}.sourceValue {n}.sourcePatterns {n}.sourceValues roles {n}.sourceEnv {n}.sourceMode {n}.sourceKind {n}.sourceTail tailNotes
         {n}.source_control {n}.source_frame stackNotes",
       "values,frames,left,right,post,retained")
    else if branch == "init" then
      (s!"(role : Annotated.Value)
        (controlNote : notes.runtime.control = bindingNote (.id {n}.sourceName) role {n}.sourceEnv .init {n}.sourceKind)
        (targetBound : s.next ≤ 2^64)",
       s!"notes.withRuntime (notes.runtime.initialized {n}.sourceAddress role)",
       s!"inventory.init_step h {n}.sourceName {n}.sourceEnv {n}.sourceAddress {n}.sourceValue {n}.sourcePrior {n}.sourceKind role
         {n}.source_control {n}.source_lookup {n}.source_heap controlNote {n}.source_bound targetBound",
       "value,left,right,post,retained")
    else
      (s!"(headNote : Annotated.Tree) (tailNotes : List Annotated.Tree) (stackNotes : notes.runtime.stack = headNote::tailNotes)",
       s!"notes.withRuntime (" ++ "{" ++ s!"notes.runtime with stack := tailNotes" ++ "}" ++ s!".statement (declarationAction {n}.sourceKind {n}.sourceRest) {n}.sourceEnv)",
       s!"RetainedInventory.declaration_next_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h inventory
         {n}.sourceValue {n}.sourceKind {n}.sourceRest {n}.sourceEnv {n}.sourceTail headNote tailNotes
         {n}.source_control {n}.source_frame stackNotes",
       "frames,left,right,post,retained")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) {extra} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory ({postNotes}) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨{results}⟩ := {call}
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
