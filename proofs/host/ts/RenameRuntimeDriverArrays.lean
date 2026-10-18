import host.ts.RenameRuntimeDriverValues
import host.ts.RuntimeInventoryArrays

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Select real source array construction and owned JavaScript-array argument
spread. Roles are retained from the accumulator/current operand or array
inventory, never reconstructed from a target result. -/
elab "host_retained_array " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let branch ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))))
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let control ← whnf (← mkAppM ``St.ctl #[s])
    if control.isAppOfArity ``Ctl.ev 2 then
      let elements ← whnf (← field control.getAppArgs[0]! ``Expr.array 1 0)
      add "sourceEnv" control.getAppArgs[1]!
      if elements.isAppOfArity ``List.nil 1 then pure "empty"
      else
        add "sourceExpression" (← field (← field elements ``List.cons 3 1) ``Elem.expr 1 0)
        add "sourceRest" (← field elements ``List.cons 3 2)
        pure "entry"
    else
      let value ← field control ``Ctl.ret 1 0
      let stack ← mkAppM ``St.stack #[s]
      let frame ← whnf (← field stack ``List.cons 3 1)
      add "sourceValue" value
      add "sourceTail" (← field stack ``List.cons 3 2)
      if frame.isAppOfArity ``Frame.l 1 then
        let array ← whnf frame.getAppArgs[0]!
        unless array.isAppOfArity ``LitF.array 3 do throwError "host_retained_array: expected ordinary array accumulator"
        add "sourceAcc" array.getAppArgs[0]!
        add "sourceEnv" array.getAppArgs[2]!
        let rest ← whnf array.getAppArgs[1]!
        if rest.isAppOfArity ``List.nil 1 then pure "final"
        else
          add "sourceExpression" (← field (← field rest ``List.cons 3 1) ``Elem.expr 1 0)
          add "sourceRest" (← field rest ``List.cons 3 2)
          pure "next"
      else
        let call ← whnf (← field frame ``Frame.c 1 0)
        unless call.isAppOfArity ``CallF.spread 6 do throwError "host_retained_array: expected JS-array argument spread"
        let a ← field value ``Val.obj 1 0
        let object ← field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
        let values ← field (← mkAppM ``Obj.kind #[object]) ``Kind.array 1 0
        for (tag,value) in [("sourceAddress",a),("sourceObject",object),("sourceValues",values),
          ("sourceKind",call.getAppArgs[0]!),("sourceFunction",call.getAppArgs[1]!),("sourceThis",call.getAppArgs[2]!),
          ("sourceAcc",call.getAppArgs[3]!),("sourceRest",call.getAppArgs[4]!),("sourceEnv",call.getAppArgs[5]!)] do add tag value
        pure "spread"
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  if branch == "entry" then
    fact "source_control" s!"{n}.input.ctl = .ev (.array (.expr {n}.sourceExpression::{n}.sourceRest)) {n}.sourceEnv"
  else if branch == "empty" then
    fact "source_control" s!"{n}.input.ctl = .ev (.array []) {n}.sourceEnv"
  else
    fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
    let frame := if branch == "spread" then
        s!".c (.spread {n}.sourceKind {n}.sourceFunction {n}.sourceThis {n}.sourceAcc {n}.sourceRest {n}.sourceEnv)"
      else if branch == "next" then
        s!".l (.array {n}.sourceAcc (.expr {n}.sourceExpression::{n}.sourceRest) {n}.sourceEnv)"
      else s!".l (.array {n}.sourceAcc [] {n}.sourceEnv)"
    fact "source_frame" s!"{n}.input.stack = {frame}::{n}.sourceTail"
  let allocates := branch == "empty" || branch == "final"
  if allocates then
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next < 2^64 := by decide +kernel")
  let allocation := s!"(prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto) (targetBound : s.next < 2^64)"
  let (extra,postNotes,call,results) ← if branch == "entry" then
      pure ("",s!"notes.withRuntime (notes.runtime.arrayElement [] {n}.sourceExpression {n}.sourceRest {n}.sourceEnv)",
        s!"inventory.array_entry_step h {n}.sourceExpression {n}.sourceRest {n}.sourceEnv {n}.source_control",
        "left,right,post,retained")
    else if branch == "empty" then
      pure (allocation,"notes.arrayCreated {notes.runtime with control := returnNote (.obj " ++ s!"{n}.input.next" ++ ")} " ++ s!"{n}.input.next []",
        s!"inventory.array_empty_step h {n}.sourceEnv {n}.source_control prototypeLive prototypeFixed {n}.source_bound targetBound",
        "left,right,post,retained")
    else if branch == "spread" then do
      fact "source_receiver" s!"{n}.sourceValue = .obj {n}.sourceAddress"
      fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
      fact "source_kind" s!"{n}.sourceObject.kind = .array {n}.sourceValues"
      Parametric.Driver.emit (header ++ s!"theorem {n}.source_ordinary : {n}.sourceKind ≤ 1 := by decide +kernel")
      pure (s!"(elements : List Annotated.Value) (entry : notes.arrays.owners {n}.sourceAddress = some elements)
        (fnRole thisRole : Annotated.Value) (roles : List Annotated.Value) (tailNotes : List Annotated.Tree)
        (stackNotes : notes.runtime.stack = argumentFrameNote true {n}.sourceKind fnRole thisRole roles {n}.sourceRest {n}.sourceEnv::tailNotes)",
        "notes.withRuntime ({notes.runtime with stack := tailNotes}.arguments " ++ s!"{n}.sourceKind fnRole thisRole (elements.reverse ++ roles) {n}.sourceRest {n}.sourceEnv)",
        s!"inventory.array_argument_spread_step h {n}.sourceAddress elements entry fnRole thisRole roles {n}.sourceKind {n}.sourceFunction
          {n}.sourceThis {n}.sourceAcc {n}.sourceRest {n}.sourceEnv {n}.sourceTail tailNotes
          (by simpa only [{n}.source_receiver] using {n}.source_control) {n}.source_frame {n}.source_ordinary stackNotes",
        "values,targetValues,fn,this,acc,frames,left,right,post,retained")
    else
      let saved := if branch == "final" then "[]" else s!"(.expr {n}.sourceExpression::{n}.sourceRest)"
      let extra := s!"(role : Annotated.Value) (roles : List Annotated.Value) (tailNotes : List Annotated.Tree)
        (controlNote : notes.runtime.control = returnNote role)
        (stackNotes : notes.runtime.stack = arrayLiteralFrameNote roles {saved} {n}.sourceEnv::tailNotes)"
      if branch == "final" then
        pure (extra ++ " " ++ allocation,"notes.arrayCreated {notes.runtime with control := returnNote (.obj " ++ s!"{n}.input.next" ++ "),stack := tailNotes} " ++ s!"{n}.input.next (role::roles).reverse",
          s!"inventory.array_final_step h {n}.sourceValue role {n}.sourceAcc roles {n}.sourceEnv {n}.sourceTail tailNotes
            {n}.source_control {n}.source_frame controlNote stackNotes prototypeLive prototypeFixed {n}.source_bound targetBound",
          "value,acc,frames,left,right,post,retained")
      else
        pure (extra,"notes.withRuntime ({notes.runtime with stack := tailNotes}.arrayElement (role::roles) " ++ s!"{n}.sourceExpression {n}.sourceRest {n}.sourceEnv)",
          s!"inventory.array_next_step h {n}.sourceValue role {n}.sourceAcc roles {n}.sourceExpression {n}.sourceRest {n}.sourceEnv
            {n}.sourceTail tailNotes {n}.source_control {n}.source_frame controlNote stackNotes",
          "value,acc,frames,left,right,post,retained")
  let liveResult := if allocates then s!"(LiveAfter live {n}.input.next)" else "live"
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) {extra} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R {liveResult} framed before after old old' {n}.output result ∧
        RetainedInventory ({postNotes}) ν₀ ν C₀ C R {liveResult} {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨{results}⟩ := {call}
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
