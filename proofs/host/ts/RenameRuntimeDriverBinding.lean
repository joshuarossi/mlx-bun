import host.ts.RenameRuntimeDriverValues
import host.ts.RenameRouteDriverBinding
import host.ts.RenameRuntimeBinding
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_runtime_binding: source syntax cannot be printed"

/-- Declaration-value and initialized identifier binding use the current
fixed operand role. A store updates the retained cell inventory and frames the
private/capture families using the original bounded heap operation. -/
elab "host_runtime_binding " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let isInit ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    if control.isAppOfArity ``Ctl.bind 5 then
      unless (← whnf control.getAppArgs[0]!).isAppOfArity ``Pat.id 1 &&
        (← whnf control.getAppArgs[3]!).isConstOf ``BindMode.init do
        throwError "host_runtime_binding: expected initialized identifier"
      pure true
    else
      unless control.isAppOfArity ``Ctl.ret 1 do throwError "host_runtime_binding: expected declaration return"
      let frame ← Parametric.Driver.field (← mkAppM ``St.stack #[s]) ``List.cons 3 1
      let statement ← Parametric.Driver.field frame ``Frame.s 1 0
      unless (← whnf statement).isAppOfArity ``StmtF.decl 4 do
        throwError "host_runtime_binding: unsupported source statement frame"
      pure false
  Parametric.Driver.emit s!"host_transport_binding {← printed f.raw}, {← printed s.raw} to {← printed t.raw} as {name.getId}"
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  let parameters := s!"(notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RuntimeInventory notes ν₀ ν C₀ C R live {n}.input s)"
  if isInit then
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_post : ({n}.input.setCell {n}.sourceAddress {n}.sourceValue).ret .undef = {n}.output := by host_kernel_rfl")
    Parametric.Driver.emit (header ++ s!"theorem {n}.runtime_transport {parameters}
      (privates : PrivateNotes) (captures : NativeCaptureNotes)
      (heap : HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live {n}.input s)
      (role : Annotated.Value)
      (controlNote : notes.control = bindingNote (.id {n}.sourceName) role {n}.sourceEnv .init {n}.sourceKind)
      (targetBound : s.next ≤ 2^64) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
      interpC (step {n}.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
      RuntimeInventory (notes.initialized {n}.sourceAddress role) ν₀ ν C₀ C R live {n}.output result ∧
      HeapInventory ((HeapNotes.mk notes.cells privates captures).writeCell {n}.sourceAddress role) ν₀ ν C₀ C R live {n}.output result ∧
      Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨value,left,right,related,annotated,postHeap⟩ := inventory.init_step {n}.F FR notes privates captures ν₀ ν C₀ C R live framed before after old old'
        {n}.input s h heap {n}.sourceName {n}.sourceEnv {n}.sourceAddress {n}.sourceValue {n}.sourcePrior {n}.sourceKind role
        {n}.source_control {n}.source_lookup {n}.source_heap controlNote {n}.source_bound targetBound
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by simpa only [{n}.source_post] using left
      exact ⟨_,source,right,{n}.source_post ▸ related,{n}.source_post ▸ annotated,{n}.source_post ▸ postHeap,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")
  else
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_post : declarationValue (" ++ "{" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}" ++ s!") {n}.sourceKind {n}.sourcePattern {n}.sourceRest {n}.sourceEnv {n}.sourceValue = {n}.output := by host_kernel_rfl")
    Parametric.Driver.emit (header ++ s!"theorem {n}.runtime_transport {parameters}
      (role : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
      (controlNote : notes.control = returnNote role) (stackNotes : notes.stack = headNote::tailNotes) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
      interpC (step {n}.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
      RuntimeInventory (notes.bindValue role {n}.sourcePattern {n}.sourceKind {n}.sourceRest {n}.sourceEnv tailNotes) ν₀ ν C₀ C R live {n}.output result ∧
      Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨value,frames,left,right,related,annotated⟩ := inventory.declaration_value_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old'
        {n}.input s h {n}.sourceValue role {n}.sourceKind {n}.sourcePattern {n}.sourceRest {n}.sourceEnv {n}.sourceTail headNote tailNotes
        {n}.source_control {n}.source_frame {n}.source_kind controlNote stackNotes
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by simpa only [{n}.source_post] using left
      exact ⟨_,source,right,{n}.source_post ▸ related,{n}.source_post ▸ annotated,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
