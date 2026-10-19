import host.ts.RenameRetainedOptInt
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false
namespace Host.Ts.Owned.Annotated

noncomputable def optIntSourceOutput {S : Type} (source : St S) : St S :=
  match source.ctl with
  | .call (.obj address) receiver [value] => match source.obj? address with
    | some {kind := .fn (.closure _ env false .undef),..} => match value with
      | .null => optIntNullCallResult source env receiver
      | .num (.lit x) => match F64.toIndex? x with
        | some n => optIntCallResult source env receiver n
        | none => source
      | _ => source
    | _ => source
  | _ => source

theorem optInt_pure_run_inst (F : Ffi) (ν : Nat → F64) (n : Nat) (source output : St F.S)
    (S₀ S₁ : SSrv) (C : CSrv) (inst : Inst ν S₀ C)
    (symbolic : runS F n source S₀ = some (output,S₁))
    (concrete : runC F n source C = some (output,C)) : Inst ν S₁ C := by
  obtain ⟨D,run,post⟩ := run_sim F ν n source output S₀ S₁ C inst symbolic
  have same : C = D := congrArg Prod.snd (Option.some.inj (concrete.symm.trans run))
  exact same ▸ post
end Host.Ts.Owned.Annotated
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Summarize one complete pinned optInt invocation. Only the current source
closure/global metadata and current argument notes determine its result. -/
elab "host_retained_optInt " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (←getCurrNamespace) ++ name.getId
  let isNull ←liftTermElabM do
    let f ←Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ←Term.elabTermEnsuringType s stateTy
    let t ←Term.elabTermEnsuringType t stateTy
    let ctl ←whnf (←mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do throwError "host_retained_optInt: expected source call"
    let address ←field ctl.getAppArgs[0]! ``Val.obj 1 0
    let args := ctl.getAppArgs[2]!
    let value ←whnf (←field args ``List.cons 3 1)
    unless (←whnf (←field args ``List.cons 3 2)).isAppOfArity ``List.nil 1 do
      throwError "host_retained_optInt: expected one argument"
    let isNull := value.isConstOf ``Val.null
    unless isNull do
      let number ←whnf (←field value ``Val.num 1 0)
      unless number.isAppOfArity ``NumV.lit 1 do throwError "host_retained_optInt: expected literal numeric argument"
      let x := number.getAppArgs[0]!
      let index ←whnf (←mkAppM ``F64.toIndex? #[x])
      unless index.isAppOfArity ``Option.some 2 do throwError "host_retained_optInt: expected nonnegative integral literal"
      let number ←whnf index.getAppArgs[1]!
      addData (pre ++ `sourceNumber) number
    let object ←field (←mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
    let code ←whnf (←field (←mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
    unless code.isAppOfArity ``Code.closure 4 do throwError "host_retained_optInt: expected closure"
    let env := code.getAppArgs[1]!
    for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),("sourceEnv",env),("sourceThis",ctl.getAppArgs[1]!)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    if !isNull then
      unless (←whnf (←mkAppM ``lookupEnv #[toExpr chars!"BigInt",env])).isAppOfArity ``Option.none 1 do
        throwError "host_retained_optInt: expected global BigInt binding"
      let global ←field (←mkAppM ``St.obj? #[s,toExpr aGlobal]) ``Option.some 2 1
      let property ←field (←mkAppM ``findProp #[←mkAppM ``PKey.str #[toExpr chars!"BigInt"],←mkAppM ``Obj.props #[global]]) ``Option.some 2 1
      let property ←whnf property
      unless property.isAppOfArity ``PropV.data 3 do throwError "host_retained_optInt: expected BigInt data property"
      let bigint ←field property.getAppArgs[0]! ``Val.obj 1 0
      let builtin ←field (←mkAppM ``St.obj? #[s,bigint]) ``Option.some 2 1
      let builtinCode ←whnf (←field (←mkAppM ``Obj.kind #[builtin]) ``Kind.fn 1 0)
      let native ←field builtinCode ``Code.native 2 0
      let number ←field native ``Native.num 1 0
      unless (←whnf number).isConstOf ``NumN.bigint do throwError "host_retained_optInt: expected native BigInt"
      for (tag,value) in [("global",global),("bigintAddress",bigint),("builtin",builtin),("data",builtinCode.getAppArgs[1]!),
        ("writable",property.getAppArgs[1]!),("enumerable",property.getAppArgs[2]!)] do addData (pre ++ Name.mkSimple tag) value
    addData (pre ++ `initialServer) (←mkAppM ``numberServer #[←Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (←mkAppM ``numberServer #[←Term.elabTermEnsuringType next (mkConst ``SSrv)])
    pure isNull
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (name type : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{name} : {type} := by host_kernel_rfl")
  let value := if isNull then ".null" else s!"(.num (.lit (F64.ofNat {n}.sourceNumber)))"
  fact "source_control" s!"{n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis [{value}]"
  fact "source_heap" s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"
  fact "source_kind" s!"{n}.object.kind = .fn (.closure optIntFunction {n}.sourceEnv false .undef)"
  if !isNull then
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_number_bound : {n}.sourceNumber < 2^32 := by decide +kernel")
    fact "bigint_lookup" s!"lookupEnv chars!\"BigInt\" {n}.sourceEnv = none"
    fact "global_heap" s!"{n}.input.heap.get aGlobal = some (.obj {n}.global)"
    fact "global_kind" s!"{n}.global.kind = .ordinary"
    fact "global_property" s!"findProp (.str chars!\"BigInt\") {n}.global.props = some (.data (.obj {n}.bigintAddress) {n}.writable {n}.enumerable)"
    fact "bigint_heap" s!"{n}.input.heap.get {n}.bigintAddress = some (.obj {n}.builtin)"
    fact "bigint_kind" s!"{n}.builtin.kind = .fn (.native (.num .bigint) {n}.data)"
  let steps := if isNull then 18 else 40
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+3 ≤ 2^64 := by decide +kernel")
  fact "source_run (C : CSrv)" s!"runC {n}.F {steps} {n}.input C = some ({n}.output,C)"
  fact "source_step" s!"runS {n}.F {steps} {n}.input {n}.initialServer = some ({n}.output,{n}.nextServer)"
  let current := if isNull then "" else s!"(meaning : SymE) (closed : ∀ valuation, meaning.eval valuation = F64.ofNat {n}.sourceNumber) (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)"
  let argRole := if isNull then ".null" else "(.literal meaning)"
  let outputNotes := if isNull then s!"optIntNullCallNotes notes {n}.input.next thisRole" else s!"optIntCallNotes notes {n}.input.next meaning {n}.sourceNumber thisRole"
  let apply := if isNull then s!"inventory.optInt_null_call h {n}.address {n}.object {n}.sourceEnv {n}.sourceThis {n}.source_control {n}.source_heap {n}.source_kind fnRole thisRole controlNote {n}.source_bound targetBound"
    else s!"inventory.optInt_call h {n}.address {n}.object {n}.sourceEnv {n}.sourceThis {n}.bigintAddress {n}.global {n}.builtin {n}.data {n}.writable {n}.enumerable {n}.sourceNumber {n}.source_number_bound meaning closed {n}.source_control {n}.source_heap {n}.source_kind {n}.bigint_lookup {n}.global_heap {n}.global_kind {n}.global_property {n}.bigint_heap {n}.bigint_kind globalLive globalFixed fnRole thisRole controlNote {n}.source_bound targetBound"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      {current} (fnRole thisRole : Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole [{argRole}]) (targetBound : s.next+3 ≤ 2^64) :
      ∃ result, runC {n}.F {steps} {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F {steps} s C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (ClosureLive live {n}.input.next false .undef optIntFunction)
          framed before after old old' {n}.output result ∧
        RetainedInventory ({outputNotes}) ν₀ ν C₀ C R (ClosureLive live {n}.input.next false .undef optIntFunction) {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨result,left,right,post,retained⟩ := {apply}
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨result,source,right,post,retained,optInt_pure_run_inst {n}.F ν₀ {steps} {n}.input {n}.output {n}.initialServer {n}.nextServer C₀ inst {n}.source_step source⟩")
end Host.Ts.Owned.Annotated.Driver
