import host.ts.RenameRetainedObjectShorthand
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Select the original initializer-store followed immediately by a lexical
shorthand read. The current cell note fixes that next value's meaning. -/
elab "host_retained_object_short " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))))
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let control ← mkAppM ``St.ctl #[s]
    let value ← field control ``Ctl.ret 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← whnf (← field (← field stack ``List.cons 3 1) ``Frame.l 1 0)
    unless frame.isAppOfArity ``LitF.objVal 4 do throwError "host_retained_object_short: expected object value continuation"
    let args := frame.getAppArgs
    let owner := args[0]!
    let name ← field args[1]! ``PKey.str 1 0
    let nextName ← field (← field args[2]! ``List.cons 3 1) ``Property.short 1 0
    let rest ← field args[2]! ``List.cons 3 2
    let env := args[3]!
    let object ← field (← mkAppM ``St.obj? #[s,owner]) ``Option.some 2 1
    let a ← field (← mkAppM ``lookupEnv #[nextName,env]) ``Option.some 2 1
    let nextValue ← field (← field (← mkAppM ``St.cell? #[s,a]) ``Option.some 2 1) ``Option.some 2 1
    for (tag,value) in [("sourceValue",value),("sourceAddress",owner),("sourceName",name),("sourceNextName",nextName),
      ("sourceRest",rest),("sourceEnv",env),("sourceObject",object),("sourceCell",a),("sourceNextValue",nextValue),
      ("sourceTail",← field stack ``List.cons 3 2)] do add tag value
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
  fact "source_frame" s!"{n}.input.stack = .l (.objVal {n}.sourceAddress (.str {n}.sourceName) (.short {n}.sourceNextName::{n}.sourceRest) {n}.sourceEnv)::{n}.sourceTail"
  fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
  fact "source_kind" s!"{n}.sourceObject.kind = .ordinary"
  fact "source_lookup" s!"lookupEnv {n}.sourceNextName {n}.sourceEnv = some {n}.sourceCell"
  fact "source_cell" s!"{n}.input.heap.get {n}.sourceCell = some (.cell (some {n}.sourceNextValue))"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next ≤ 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (role nextRole : Annotated.Value) (head : Annotated.Tree) (tail : List Annotated.Tree)
      (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = head::tail)
      (entry : notes.runtime.cells.cells {n}.sourceCell = some nextRole) (targetBound : s.next ≤ 2^64) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory ((notes.publicStored {n}.sourceAddress {n}.sourceName role tail).withRuntime
          ⟨returnNote nextRole,objectValueFrameNote {n}.sourceAddress {n}.sourceNextName {n}.sourceRest {n}.sourceEnv::tail,notes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨value,object,frames,nextValue,left,right,post,retained⟩ := inventory.object_value_short_step h
        {n}.sourceAddress {n}.sourceName {n}.sourceValue {n}.sourceObject {n}.sourceTail {n}.sourceEnv
        {n}.sourceNextName {n}.sourceRest {n}.sourceCell {n}.sourceNextValue role nextRole head tail
        {n}.source_control {n}.source_frame {n}.source_heap {n}.source_kind {n}.source_lookup {n}.source_cell
        entry controlNote stackNotes {n}.source_bound targetBound
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")
end Host.Ts.Owned.Annotated.Driver
