import host.ts.RenameRetainedProvidedDefault
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Select the original provided-default parameter transition. The original
pattern remains on the binding control until the following interpreter step. -/
elab "host_retained_provided_default " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else some stateTy)
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    add "sourceValue" (← field (← mkAppM ``St.ctl #[s]) ``Ctl.ret 1 0)
    let stack ← mkAppM ``St.stack #[s]
    add "sourceTail" (← field stack ``List.cons 3 2)
    let frame ← field (← field stack ``List.cons 3 1) ``Frame.k 1 0
    add "sourceFunction" (← field frame ``FnF.params 4 0)
    let args ← field frame ``FnF.params 4 2
    let argument ← whnf (← mkAppM ``nthD #[mkConst ``Val.undef,args,mkNatLit 0])
    if argument.isConstOf ``Val.undef then
      throwError "host_retained_provided_default: source argument is undefined"
    add "sourceArgs" args
    add "sourceEnv" (← field frame ``FnF.params 4 3)
    let params ← field frame ``FnF.params 4 1
    add "sourceParams" (← field params ``List.cons 3 2)
    let pattern ← field params ``List.cons 3 1
    add "sourceName" (← field (← field pattern ``Pat.dflt 2 0) ``Pat.id 1 0)
    add "sourceDefault" (← field pattern ``Pat.dflt 2 1)
    add "initialServer" (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    add "nextServer" (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
  fact "source_frame" s!"{n}.input.stack = .k (.params {n}.sourceFunction
    (.dflt (.id {n}.sourceName) {n}.sourceDefault::{n}.sourceParams) {n}.sourceArgs {n}.sourceEnv)::{n}.sourceTail"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_provided : nthD .undef {n}.sourceArgs 0 ≠ .undef := by intro bad; cases bad")
  let sourcePost := "Parametric.parameterProvidedDefault (" ++ "{" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}" ++
    s!") {n}.sourceFunction {n}.sourceName {n}.sourceDefault {n}.sourceParams {n}.sourceArgs {n}.sourceEnv"
  fact "source_post" s!"{sourcePost} = {n}.output"
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (roles : List Annotated.Value) (tailNotes : List Annotated.Tree)
      (stackNotes : notes.runtime.stack = parameterFrameNote {n}.sourceFunction
        (.dflt (.id {n}.sourceName) {n}.sourceDefault::{n}.sourceParams) roles {n}.sourceEnv::tailNotes) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.parameterProvidedDefault
          {n}.sourceFunction {n}.sourceName {n}.sourceDefault {n}.sourceParams roles {n}.sourceEnv tailNotes))
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ ∧
        result.ffi = s.ffi ∧ result.next = s.next ∧ result.heap = s.heap := by
      obtain ⟨result,left,right,post,retained,native,counter,heap⟩ := RetainedInventory.provided_default_parameter_step
        {n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h inventory
        {n}.sourceValue {n}.sourceFunction {n}.sourceName {n}.sourceDefault {n}.sourceParams {n}.sourceArgs {n}.sourceEnv
        {n}.sourceTail roles tailNotes {n}.source_control {n}.source_frame {n}.source_provided stackNotes
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨result,source,right,post,retained,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source,
        native,counter,heap⟩")
end Host.Ts.Owned.Annotated.Driver
