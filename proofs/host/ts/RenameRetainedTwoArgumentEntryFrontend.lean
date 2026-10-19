import host.ts.RenameRetainedTwoArgumentEntry
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

elab "host_retained_two_argument_entry " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← mkAppM ``St.ctl #[s]
    let callee ← field control ``Ctl.call 3 0
    let address ← field callee ``Val.obj 1 0
    let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let closure ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    unless closure.isAppOfArity ``Code.closure 4 do
      throwError "host_retained_two_argument_entry: expected a closure"
    let fn ← field closure ``Code.closure 4 0
    let functionName ← field fn ``Func.mk 7 0
    let params ← whnf (← field fn ``Func.mk 7 1)
    let firstName ← field (← field params ``List.cons 3 1) ``Pat.id 1 0
    let rest ← whnf (← field params ``List.cons 3 2)
    let secondName ← field (← field rest ``List.cons 3 1) ``Pat.id 1 0
    let tail ← whnf (← field rest ``List.cons 3 2)
    unless tail.isAppOfArity ``List.nil 1 do
      throwError "host_retained_two_argument_entry: expected exactly two parameters"
    let body ← field (← field fn ``Func.mk 7 3) ``Body.block 1 0
    let arguments ← whnf (← field control ``Ctl.call 3 2)
    let firstValue ← field arguments ``List.cons 3 1
    let argRest ← whnf (← field arguments ``List.cons 3 2)
    let secondValue ← field argRest ``List.cons 3 1
    let argTail ← whnf (← field argRest ``List.cons 3 2)
    unless argTail.isAppOfArity ``List.nil 1 do
      throwError "host_retained_two_argument_entry: expected exactly two arguments"
    let arrow ← whnf (closure.getAppArgs[2]!)
    unless arrow.isConstOf ``Bool.false do
      throwError "host_retained_two_argument_entry: expected an ordinary non-arrow closure"
    let home ← whnf (closure.getAppArgs[3]!)
    unless home.isConstOf ``Val.undef do
      throwError "host_retained_two_argument_entry: expected an undefined home"
    let env := closure.getAppArgs[1]!
    let receiver ← field control ``Ctl.call 3 1
    let state? (tag : String) := if tag == "input" || tag == "output" then some stateTy else none
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceCallee",address),("sourceObject",object),
        ("sourceFunction",fn),("sourceName",functionName),("firstName",firstName),("secondName",secondName),
        ("sourceBody",body),("sourceEnv",env),("sourceThis",receiver),("sourceFirst",firstValue),
        ("sourceSecond",secondValue)] do
      addData (pre ++ Name.mkSimple tag) value (state? tag)
    addData (pre ++ `span) (mkNatLit 6)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .call (.obj {n}.sourceCallee) {n}.sourceThis [{n}.sourceFirst,{n}.sourceSecond]"
  fact "source_read" s!"{n}.input.heap.get {n}.sourceCallee = some (.obj {n}.sourceObject)"
  fact "source_kind" s!"{n}.sourceObject.kind = .fn (.closure (twoParameterFunction {n}.sourceName {n}.firstName {n}.secondName {n}.sourceBody) {n}.sourceEnv false .undef)"
  fact "source_distinct" s!"nameEq {n}.firstName {n}.secondName = false"
  fact "source_inert" s!"noInitFunctions {n}.sourceBody = true"
  fact "source_output" s!"twoArgumentEntry {n}.input {n}.sourceName {n}.firstName {n}.secondName {n}.sourceBody {n}.sourceEnv {n}.sourceThis {n}.sourceFirst {n}.sourceSecond = {n}.output"
  fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+4+(blockNames {n}.sourceBody).length ≤ 2^64 := by decide +kernel")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 6 {n}.input C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (firstRole secondRole fnRole thisRole : Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole [firstRole,secondRole])
      (targetBound : s.next+4+(blockNames {n}.sourceBody).length ≤ 2^64) :
      ∃ result, runC {n}.F 6 {n}.input C₀ = some ({n}.output,C₀) ∧
        runC {n}.F 6 s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R
          (CellsLive (ClosureLive live {n}.input.next false .undef (twoParameterFunction {n}.sourceName {n}.firstName {n}.secondName {n}.sourceBody))
            ({n}.input.next+3) (blockNames {n}.sourceBody))
          framed before after old old' {n}.output result ∧
        RetainedInventory (twoArgumentEntryNotes notes {n}.input {n}.sourceName {n}.firstName {n}.secondName {n}.sourceBody
          {n}.sourceEnv {n}.sourceThis {n}.sourceFirst {n}.sourceSecond firstRole secondRole thisRole)
          ν₀ ν C₀ C R
          (CellsLive (ClosureLive live {n}.input.next false .undef (twoParameterFunction {n}.sourceName {n}.firstName {n}.secondName {n}.sourceBody))
            ({n}.input.next+3) (blockNames {n}.sourceBody))
          {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ ∧
        result.ffi = s.ffi ∧
        result.next = s.next+3+(blockNames {n}.sourceBody).length ∧
        (∀ a, a < s.next → result.heap.get a = s.heap.get a) ∧
        (∀ a, a < {n}.input.next → {n}.output.heap.get a = {n}.input.heap.get a) := by
      have transition := inventory.two_argument_entry h {n}.sourceCallee {n}.sourceObject {n}.sourceName
        {n}.firstName {n}.secondName {n}.sourceBody {n}.sourceEnv {n}.sourceThis {n}.sourceFirst {n}.sourceSecond
        firstRole secondRole fnRole thisRole {n}.source_distinct {n}.source_control {n}.source_read {n}.source_kind
        controlNote {n}.source_inert {n}.source_bound targetBound
      dsimp only at transition
      obtain ⟨result,sourceRun,targetRun,post,retained,ffiEq,nextEq,targetHeap,sourceHeap⟩ := transition
      rw [{n}.source_output] at sourceRun post retained sourceHeap
      exact ⟨result,sourceRun,targetRun,post,retained,{n}.source_servers ▸ inst,ffiEq,nextEq,targetHeap,sourceHeap⟩")

end Host.Ts.Owned.Annotated.Driver
