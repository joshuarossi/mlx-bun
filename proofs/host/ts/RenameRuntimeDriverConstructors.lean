import host.ts.RenameRetainedConstructorBody
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Source-selected base-class or constructor-body entry. Only source syntax
and initialized class metadata choose the rule; retained current arguments
and receiver notes determine the resulting parameter meanings. -/
elab "host_retained_constructor " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let entry ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))))
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let control ← whnf (← mkAppM ``St.ctl #[s])
    if control.isAppOfArity ``Ctl.construct 3 then
      let address ← field control.getAppArgs[0]! ``Val.obj 1 0
      let object ← field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
      let klass ← field (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0) ``Code.klass 4 0
      let fn ← field klass ``Option.some 2 1
      let code ← whnf (← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
      let prototype ← field (← mkAppM ``findProp #[mkConst ``kPrototype,← mkAppM ``Obj.props #[object]]) ``Option.some 2 1
      let proto ← field (← field prototype ``PropV.data 3 0) ``Val.obj 1 0
      for (tag,value) in [("sourceAddress",address),("sourceObject",object),("sourceFunction",fn),
        ("sourceEnv",code.getAppArgs[1]!),("sourceMembers",code.getAppArgs[3]!),
        ("sourceArgs",control.getAppArgs[1]!),("sourcePrototype",proto),
        ("sourceWritable",← field prototype ``PropV.data 3 1),("sourceEnumerable",← field prototype ``PropV.data 3 2)] do add tag value
      pure true
    else
      let value ← field control ``Ctl.ret 1 0
      let stack ← mkAppM ``St.stack #[s]
      let frame ← whnf (← field (← field stack ``List.cons 3 1) ``Frame.k 1 0)
      unless frame.isAppOfArity ``FnF.ctorBody 4 do throwError "host_retained_constructor: expected constructor-body frame"
      for (tag,value) in [("sourceValue",value),("sourceThis",frame.getAppArgs[0]!),
        ("sourceFunction",frame.getAppArgs[1]!),("sourceEnv",frame.getAppArgs[2]!),
        ("sourceArgs",frame.getAppArgs[3]!),("sourceTail",← field stack ``List.cons 3 2)] do add tag value
      pure false
  liftTermElabM do
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  let (extra,postNotes,postLive,call,results) ← if entry then do
      fact "source_control" s!"{n}.input.ctl = .construct (.obj {n}.sourceAddress) {n}.sourceArgs (.obj {n}.sourceAddress)"
      fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
      fact "source_kind" s!"{n}.sourceObject.kind = .fn (.klass (some {n}.sourceFunction) {n}.sourceEnv .null {n}.sourceMembers)"
      fact "source_prototype" s!"findProp kPrototype {n}.sourceObject.props = some (.data (.obj {n}.sourcePrototype) {n}.sourceWritable {n}.sourceEnumerable)"
      Parametric.Driver.emit (header ++ s!"theorem {n}.source_private : PrivateFields {n}.sourceMembers := by repeat constructor")
      Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+2 ≤ 2^64 := by decide +kernel")
      pure ("(fnRole : Annotated.Value) (argRoles : List Annotated.Value)
          (controlNote : notes.runtime.control = constructNote fnRole argRoles) (targetBound : s.next+2 ≤ 2^64)",
        s!"notes.withRuntime (notes.runtime.baseClass {n}.sourceFunction {n}.sourceEnv {n}.sourceMembers argRoles {n}.input.next)",
        s!"BaseClassLive live {n}.input.next",
        s!"inventory.base_class_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h
          {n}.sourceAddress {n}.sourcePrototype {n}.sourceObject {n}.sourceFunction {n}.sourceEnv {n}.sourceMembers
          {n}.sourceArgs {n}.sourceWritable {n}.sourceEnumerable fnRole argRoles {n}.source_control {n}.source_heap
          {n}.source_kind {n}.source_prototype {n}.source_private controlNote {n}.source_bound targetBound",
        "args,members,left,right,post,retained")
    else do
      fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
      fact "source_frame" s!"{n}.input.stack = .k (.ctorBody {n}.sourceThis {n}.sourceFunction {n}.sourceEnv {n}.sourceArgs)::{n}.sourceTail"
      Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+2+(paramNames {n}.sourceFunction).length ≤ 2^64 := by decide +kernel")
      let popped := "{" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}"
      pure (s!"(thisRole : Annotated.Value) (argRoles : List Annotated.Value) (tailNotes : List Annotated.Tree)
          (stackNotes : notes.runtime.stack = constructorBodyFrameNote thisRole {n}.sourceFunction {n}.sourceEnv argRoles::tailNotes)
          (targetBound : s.next+2+(paramNames {n}.sourceFunction).length ≤ 2^64)",
        s!"notes.withRuntime (notes.runtime.constructorBody {n}.sourceFunction argRoles
          (closureEnvironment {popped} {n}.sourceFunction {n}.sourceEnv false .undef {n}.sourceThis) {n}.input.next thisRole tailNotes)",
        s!"ConstructorBodyLive live {n}.input.next {n}.sourceFunction",
        s!"inventory.constructor_body_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h
          {n}.sourceValue {n}.sourceThis {n}.sourceFunction {n}.sourceEnv {n}.sourceArgs {n}.sourceTail
          thisRole argRoles tailNotes {n}.source_control {n}.source_frame stackNotes {n}.source_bound targetBound",
        "this,args,frames,left,right,post,retained")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) {extra} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R ({postLive}) framed before after old old' {n}.output result ∧
        RetainedInventory ({postNotes}) ν₀ ν C₀ C R ({postLive}) {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨{results}⟩ := {call}
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
