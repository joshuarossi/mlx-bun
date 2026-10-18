import host.ts.RenameRetainedArrayPush
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Select the original mutable-array builtin. Fixed current array and call
notes supply every appended element meaning; source bytes do not choose them. -/
elab "host_retained_arrayPush " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_arrayPush: expected source call"
    let address ← field ctl.getAppArgs[0]! ``Val.obj 1 0
    let owner ← field ctl.getAppArgs[1]! ``Val.obj 1 0
    let function ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ← whnf (← field (← mkAppM ``Obj.kind #[function]) ``Kind.fn 1 0)
    let native ← whnf (← field code ``Code.native 2 0)
    let builtin ← field native ``Native.arr 1 0
    unless (← whnf builtin).isConstOf ``ArrN.push do throwError "host_retained_arrayPush: expected Array.push builtin"
    let object ← field (← mkAppM ``St.obj? #[s,owner]) ``Option.some 2 1
    let values ← field (← mkAppM ``Obj.kind #[object]) ``Kind.array 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("owner",owner),("function",function),
      ("object",object),("data",code.getAppArgs[1]!),("arguments",ctl.getAppArgs[2]!),("values",values)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  for (fact,type) in [
    ("source_control",s!"{n}.input.ctl = .call (.obj {n}.address) (.obj {n}.owner) {n}.arguments"),
    ("source_function",s!"{n}.input.heap.get {n}.address = some (.obj {n}.function)"),
    ("source_builtin",s!"{n}.function.kind = .fn (.native (.arr .push) {n}.data)"),
    ("source_object",s!"{n}.input.heap.get {n}.owner = some (.obj {n}.object)"),
    ("source_array",s!"{n}.object.kind = .array {n}.values"),
    ("source_extensible",s!"{n}.object.extensible = true")]
    do Parametric.Driver.emit (header ++ s!"theorem {n}.{fact} : {type} := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next ≤ 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (roles argRoles : List Annotated.Value) (entry : notes.arrays.owners {n}.owner = some roles)
      (controlNote : notes.runtime.control = callNote (.obj {n}.address) (.obj {n}.owner) argRoles)
      (notFramed : ¬ framed {n}.owner) (targetBound : s.next ≤ 2^64) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.arrayPush {n}.owner (len ({n}.values++{n}.arguments)) roles argRoles)
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨sourcePost,result,left,right,post,retained⟩ := RetainedInventory.array_push_step {n}.F FR notes ν₀ ν C₀ C R live framed
        before after old old' {n}.input s h inventory {n}.address {n}.owner {n}.function {n}.object {n}.data {n}.arguments {n}.values
        roles argRoles {n}.source_control {n}.source_function {n}.source_builtin {n}.source_object {n}.source_array
        {n}.source_extensible entry controlNote notFramed {n}.source_bound targetBound
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
