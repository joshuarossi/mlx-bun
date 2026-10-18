import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriverArithmetic
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Select an actual retained arithmetic cut and kernel-check its symbolic
source step. The emitted transport consumes fixed operand notes and the
instantiated source table; no target step or target numeric allocation is read. -/
elab "host_runtime_arithmetic " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let literalOperands ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    let initial ← mkAppM ``numberServer #[initial]
    let next ← mkAppM ``numberServer #[next]
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.ret 1 do
      throwError "host_runtime_arithmetic: expected numeric return control"
    let right ← field ctl.getAppArgs[0]! ``Val.num 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← field stack ``List.cons 3 1
    let tail ← field stack ``List.cons 3 2
    let exprFrame ← whnf (← field frame ``Frame.e 1 0)
    unless exprFrame.isAppOfArity ``ExprF.binR 2 do
      throwError "host_runtime_arithmetic: expected binary-right frame"
    let args := exprFrame.getAppArgs
    let op ← whnf args[0]!
    let kinds : List (Lean.Name × Lean.Name) := [(``BinOp.add,``Parametric.ArithmeticKind.add),(``BinOp.sub,``Parametric.ArithmeticKind.sub),
      (``BinOp.mul,``Parametric.ArithmeticKind.mul),(``BinOp.div,``Parametric.ArithmeticKind.div),(``BinOp.mod,``Parametric.ArithmeticKind.rem),
      (``BinOp.band,``Parametric.ArithmeticKind.band),(``BinOp.bor,``Parametric.ArithmeticKind.bor),(``BinOp.bxor,``Parametric.ArithmeticKind.bxor),
      (``BinOp.shl,``Parametric.ArithmeticKind.shl),(``BinOp.shr,``Parametric.ArithmeticKind.shr),(``BinOp.ushr,``Parametric.ArithmeticKind.ushr)]
    let some (_,kind) := kinds.find? (fun (js,_) => js == op.getAppFn.constName!) |
      throwError "host_runtime_arithmetic: unsupported arithmetic operator {op.getAppFn.constName!}"
    let left ← field args[1]! ``Val.num 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("initialServer",initial),("nextServer",next),
      ("kind",mkConst kind),("sourceLeft",left),("sourceRight",right),("sourceTail",tail)] do
      let type? := if tag == "input" || tag == "output" then some (mkApp (mkConst ``St)
        (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
    let left ← whnf left
    let right ← whnf right
    if left.isAppOfArity ``NumV.lit 1 && right.isAppOfArity ``NumV.lit 1 then
      addData (pre ++ `sourceLeftLiteral) left.getAppArgs[0]!
      addData (pre ++ `sourceRightLiteral) right.getAppArgs[0]!
      pure true
    else pure false
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ret (.num {n}.sourceRight) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_stack : {n}.input.stack = .e (.binR {n}.kind.jsOp (.num {n}.sourceLeft))::{n}.sourceTail := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_concrete (ν₀ : Nat → F64) (C₀ : CSrv) (inst : Inst ν₀ {n}.initialServer C₀) :
    ∃ D₀, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,D₀) ∧ Inst ν₀ {n}.nextServer D₀ :=
    interp_sim ν₀ (step {n}.F {n}.input).run {n}.initialServer C₀ {n}.output {n}.nextServer inst {n}.source_step")
  Parametric.Driver.emit (header ++ s!"theorem {n}.runtime_transport (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RuntimeInventory notes ν₀ ν C₀ C R live {n}.input s)
      (ea eb : SymE) (leftRole rightRole : Annotated.Value) (leftNumeric : NumericRole leftRole ea) (rightNumeric : NumericRole rightRole eb)
      (tailNotes : List Annotated.Tree) (controlNote : notes.control = returnNote rightRole)
      (stackNote : notes.stack = binaryRightNote {n}.kind.jsOp leftRole::tailNotes) :
      ∃ result D₀ D, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,D₀) ∧ interpC (step {n}.F s).run C = some (result,D) ∧
        Inst ν₀ {n}.nextServer D₀ ∧
        Parametric.StateR (NumberRoles ν₀ ν D₀ D) FR R live framed before after old old' {n}.output result ∧
        RuntimeInventory (notes.binaryResult (.num (.bin {n}.kind.numOp ea eb)) tailNotes) ν₀ ν D₀ D R live {n}.output result ∧
        TableExtends C₀ D₀ ∧ TableExtends C D :=
      inventory.arithmetic_cut {n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input {n}.output s
        {n}.initialServer {n}.nextServer {n}.source_step inst h {n}.kind {n}.sourceLeft {n}.sourceRight ea eb leftRole rightRole
        leftNumeric rightNumeric {n}.sourceTail tailNotes {n}.source_control {n}.source_stack controlNote stackNote")
  if literalOperands then
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_literal_control : {n}.input.ctl = .ret (.num (.lit {n}.sourceRightLiteral)) := by host_kernel_rfl")
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_literal_stack : {n}.input.stack = .e (.binR {n}.kind.jsOp (.num (.lit {n}.sourceLeftLiteral)))::{n}.sourceTail := by host_kernel_rfl")
    Parametric.Driver.emit (header ++ s!"theorem {n}.runtime_literal_transport (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RuntimeInventory notes ν₀ ν C₀ C R live {n}.input s)
      (ea eb : SymE) (tailNotes : List Annotated.Tree)
      (controlNote : notes.control = returnNote (.literal eb))
      (stackNote : notes.stack = binaryRightNote {n}.kind.jsOp (.literal ea)::tailNotes) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧ Inst ν₀ {n}.nextServer C₀ ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RuntimeInventory (notes.binaryResult (.literal (.bin {n}.kind.numOp ea eb)) tailNotes) ν₀ ν C₀ C R live {n}.output result :=
      inventory.literal_arithmetic_cut {n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input {n}.output s
        {n}.initialServer {n}.nextServer {n}.source_step inst h {n}.kind {n}.sourceLeftLiteral {n}.sourceRightLiteral
        ea eb {n}.sourceTail tailNotes {n}.source_literal_control {n}.source_literal_stack controlNote stackNote")

end Host.Ts.Owned.Annotated.Driver
