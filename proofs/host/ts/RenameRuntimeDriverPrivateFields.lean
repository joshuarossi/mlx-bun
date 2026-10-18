import host.ts.RenameRetainedPrivateFields
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Select the original private-fields rule from the source control and frame.
The initializer result retains its current role; the undefined initial field
uses the language's fixed undefined value. -/
elab "host_retained_private_fields " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let initialField ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let value ← field (← mkAppM ``St.ctl #[s]) ``Ctl.ret 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← whnf (← field (← field stack ``List.cons 3 1) ``Frame.k 1 0)
    let fields := frame.isAppOfArity ``FnF.fields 3
    let (owner,brand,name,members,env) ← if fields then do
        let members := frame.getAppArgs[1]!
        let member ← whnf (← field members ``List.cons 3 1)
        unless member.isAppOfArity ``InstMember.privField 3 do
          throwError "host_retained_private_fields: expected private field"
        let init ← whnf member.getAppArgs[2]!
        unless init.isAppOfArity ``Option.none 1 do
          throwError "host_retained_private_fields: first field must be uninitialized"
        pure (frame.getAppArgs[0]!,member.getAppArgs[0]!,member.getAppArgs[1]!,
          ← field members ``List.cons 3 2,frame.getAppArgs[2]!)
      else do
        unless frame.isAppOfArity ``FnF.privVal 5 do
          throwError "host_retained_private_fields: expected fields or initializer frame"
        pure (frame.getAppArgs[0]!,frame.getAppArgs[1]!,frame.getAppArgs[2]!,frame.getAppArgs[3]!,frame.getAppArgs[4]!)
    let members ← whnf members
    let nextField ← if members.isAppOfArity ``List.nil 1 then pure (mkConst ``PrivateNext.done)
      else do
        let member ← whnf (← field members ``List.cons 3 1)
        unless member.isAppOfArity ``InstMember.privField 3 do
          throwError "host_retained_private_fields: expected next private initializer"
        let expression ← field member.getAppArgs[2]! ``Option.some 2 1
        mkAppM ``PrivateNext.initial #[member.getAppArgs[0]!,member.getAppArgs[1]!,expression,
          ← field members ``List.cons 3 2]
    let object ← field (← mkAppM ``St.obj? #[s,owner]) ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceValue",value),("sourceOwner",owner),
      ("sourceBrand",brand),("sourceName",name),("sourceNext",nextField),("sourceEnv",env),
      ("sourceTail",← field stack ``List.cons 3 2),("sourceObject",object)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
    pure fields
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
  let frame := if initialField then
      s!".fields {n}.sourceOwner (.privField {n}.sourceBrand {n}.sourceName none::{n}.sourceNext.members) {n}.sourceEnv"
    else s!".privVal {n}.sourceOwner {n}.sourceBrand {n}.sourceName {n}.sourceNext.members {n}.sourceEnv"
  fact "source_frame" s!"{n}.input.stack = .k ({frame})::{n}.sourceTail"
  fact "source_heap" s!"{n}.input.heap.get {n}.sourceOwner = some (.obj {n}.sourceObject)"
  fact "source_kind" s!"{n}.sourceObject.kind = .ordinary"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_private : {n}.sourceNext.valid := by repeat constructor")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next ≤ 2^64 := by decide +kernel")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  let (extra,role,call,results) := if initialField then
      ("", ".undef",
        s!"inventory.private_fields_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h
          {n}.sourceValue {n}.sourceOwner {n}.sourceBrand {n}.sourceName {n}.sourceObject {n}.sourceNext {n}.sourceEnv {n}.sourceTail
          headNote tailNotes {n}.source_private {n}.source_control {n}.source_frame {n}.source_heap {n}.source_kind
          stackNotes {n}.source_bound targetBound", "object,frames,left,right,post,retained")
    else
      ("(role : Annotated.Value) (controlNote : notes.runtime.control = returnNote role)", "role",
        s!"inventory.private_initializer_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old' {n}.input s h
          {n}.sourceValue {n}.sourceOwner {n}.sourceBrand {n}.sourceName {n}.sourceObject {n}.sourceNext {n}.sourceEnv {n}.sourceTail
          role headNote tailNotes {n}.source_private {n}.source_control {n}.source_frame {n}.source_heap {n}.source_kind
          controlNote stackNotes {n}.source_bound targetBound", "value,object,frames,left,right,post,retained")
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) {extra}
      (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
      (stackNotes : notes.runtime.stack = headNote::tailNotes) (targetBound : s.next ≤ 2^64) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.privateFields {n}.sourceOwner {n}.sourceBrand {n}.sourceName {role} tailNotes
          {n}.sourceNext {n}.sourceEnv) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨{results}⟩ := {call}
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
