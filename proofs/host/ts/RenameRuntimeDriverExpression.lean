import host.ts.RenameRuntimeDriverValues
import host.ts.RenameRouteDriverStructural
import host.ts.RenameRuntimeArguments
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_runtime_structural: source syntax cannot be printed"

/-- Select original binary descent, left continuation, or ordinary argument
collection. The source endpoint and source numeric-table transition are checked
before the reusable inventory rule is emitted. -/
elab "host_runtime_structural " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let tag ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    if control.isAppOfArity ``Ctl.ev 2 then
      let expression ← whnf control.getAppArgs[0]!
      unless expression.isAppOfArity ``Expr.bin 3 do
        throwError "host_runtime_structural: unsupported source expression"
      for (tag,value) in [("sourceOp",expression.getAppArgs[0]!),
        ("sourceLeft",expression.getAppArgs[1]!), ("sourceRight",expression.getAppArgs[2]!)] do
        Parametric.Driver.addData (pre ++ Name.mkSimple tag) value
      pure 0
    else
      unless control.isAppOfArity ``Ctl.ret 1 do
        throwError "host_runtime_structural: expected source expression or return"
      let stack ← mkAppM ``St.stack #[s]
      let frame ← Parametric.Driver.field stack ``List.cons 3 1
      let frame ← whnf frame
      if frame.isAppOfArity ``Frame.c 1 then
        let callFrame ← whnf frame.getAppArgs[0]!
        unless callFrame.isAppOfArity ``CallF.args 6 do
          throwError "host_runtime_structural: unsupported source call frame"
        pure 1
      else
        let expressionFrame ← Parametric.Driver.field frame ``Frame.e 1 0
        unless (← whnf expressionFrame).isAppOfArity ``ExprF.binL 3 do
          throwError "host_runtime_structural: unsupported source expression frame"
        pure 2
  Parametric.Driver.emit s!"host_transport_structural {← printed f.raw}, {← printed s.raw} to {← printed t.raw} as {name.getId}"
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  if tag == 0 then
    Parametric.Driver.emit (header ++ s!"theorem {n}.runtime_source_post : (({n}.input.push (.e (.binL {n}.sourceOp {n}.sourceRight {n}.sourceEnv))).go (.ev {n}.sourceLeft {n}.sourceEnv)) = {n}.output := by host_kernel_rfl")
  let parameters := s!"(notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RuntimeInventory notes ν₀ ν C₀ C R live {n}.input s)"
  let (extra,postNotes,body) := if tag == 0 then
      ("",s!"notes.binaryDescent {n}.sourceOp {n}.sourceLeft {n}.sourceRight {n}.sourceEnv",s!"
      obtain ⟨left,right,related,annotated⟩ := inventory.binary_descent_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old'
        {n}.input s h {n}.sourceOp {n}.sourceLeft {n}.sourceRight {n}.sourceEnv {n}.source_control
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by simpa only [{n}.runtime_source_post] using left
      exact ⟨_,source,right,{n}.runtime_source_post ▸ related,{n}.runtime_source_post ▸ annotated,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")
    else if tag == 2 then
      (s!"(role : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
        (controlNote : notes.control = returnNote role) (stackNote : notes.stack = headNote::tailNotes)",
        s!"notes.binaryLeft role {n}.sourceOp {n}.sourceRight {n}.sourceEnv tailNotes",s!"
      obtain ⟨value,frames,left,right,related,annotated,_⟩ := inventory.binary_left_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old'
        {n}.input s h {n}.sourceValue role {n}.sourceOp {n}.sourceRight {n}.sourceEnv {n}.sourceTail headNote tailNotes
        {n}.source_control {n}.source_frame controlNote stackNote
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by simpa only [{n}.source_post] using left
      exact ⟨_,source,right,{n}.source_post ▸ related,{n}.source_post ▸ annotated,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")
    else
      (s!"(role fnRole thisRole : Annotated.Value) (roles : List Annotated.Value) (tailNotes : List Annotated.Tree)
        (controlNote : notes.control = returnNote role)
        (stackNotes : notes.stack = argumentFrameNote false {n}.sourceKind fnRole thisRole roles {n}.sourceRest {n}.sourceEnv::tailNotes)",
        "({notes with stack := tailNotes}.arguments " ++ s!"{n}.sourceKind fnRole thisRole (role::roles) {n}.sourceRest {n}.sourceEnv)",s!"
      obtain ⟨value,fn,this,acc,frames,left,right,related,annotated⟩ := inventory.argument_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old'
        {n}.input s h {n}.sourceValue role fnRole thisRole roles {n}.sourceKind {n}.sourceFunction {n}.sourceThis
        {n}.sourceAcc {n}.sourceRest {n}.sourceEnv {n}.sourceTail tailNotes {n}.source_control {n}.source_frame (by decide) controlNote stackNotes
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by simpa only [{n}.source_post] using left
      exact ⟨_,source,right,{n}.source_post ▸ related,{n}.source_post ▸ annotated,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")
  Parametric.Driver.emit (header ++ s!"theorem {n}.runtime_transport {parameters} {extra} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
      interpC (step {n}.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
      RuntimeInventory ({postNotes}) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by {body}")

end Host.Ts.Owned.Annotated.Driver
