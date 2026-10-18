import host.ts.RenameRuntimeDriverValues
import host.ts.RenameRuntimeCallStart
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric

/-- An object callee starts argument collection with the saved receiver's
fixed role. Source syntax and snapshots determine the actual call mode. -/
elab "host_runtime_call_start " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let control ← mkAppM ``St.ctl #[s]
    let address ← Parametric.Driver.field (← Parametric.Driver.field control ``Ctl.ret 1 0) ``Val.obj 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← whnf (← Parametric.Driver.field (← Parametric.Driver.field stack ``List.cons 3 1) ``Frame.c 1 0)
    let args := frame.getAppArgs
    let (mode,this,arguments,env) ← if frame.isAppOfArity ``CallF.callee 3 then
        pure (mkApp (mkConst ``CallStart.callee) args[2]!,mkConst ``Val.undef,args[0]!,args[1]!)
      else if frame.isAppOfArity ``CallF.method 4 then
        pure (mkApp (mkConst ``CallStart.method) args[3]!,args[0]!,args[1]!,args[2]!)
      else if frame.isAppOfArity ``CallF.newCallee 2 then
        pure (mkConst ``CallStart.construct,mkConst ``Val.undef,args[0]!,args[1]!)
      else throwError "host_runtime_call_start: unsupported source call frame"
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceAddress",address),("sourceMode",mode),
      ("sourceThis",this),("sourceArgs",arguments),("sourceEnv",env),("sourceTail",← Parametric.Driver.field stack ``List.cons 3 2)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value type?
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret (.obj {n}.sourceAddress)"
  fact "source_frame" s!"{n}.input.stack = {n}.sourceMode.frame {n}.sourceThis {n}.sourceArgs {n}.sourceEnv::{n}.sourceTail"
  fact "source_post" ("argumentState ({" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}) " ++
    s!"{n}.sourceMode.kind (.obj {n}.sourceAddress) ({n}.sourceMode.receiver {n}.sourceThis) [] {n}.sourceArgs {n}.sourceEnv = {n}.output")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  let postNotes := "({notes with stack := tailNotes}.arguments " ++
    s!"{n}.sourceMode.kind (.obj {n}.sourceAddress) (callReceiverNote {n}.sourceMode thisRole) [] {n}.sourceArgs {n}.sourceEnv)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.runtime_transport
      (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RuntimeInventory notes ν₀ ν C₀ C R live {n}.input s)
      (thisRole : Annotated.Value) (tailNotes : List Annotated.Tree)
      (stackNotes : notes.stack = callStartFrameNote {n}.sourceMode thisRole {n}.sourceArgs {n}.sourceEnv::tailNotes) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
      interpC (step {n}.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
      RuntimeInventory ({postNotes}) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨receiver,frames,left,right,related,annotated⟩ := inventory.call_start_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old'
        {n}.input s h {n}.sourceMode {n}.sourceAddress {n}.sourceThis thisRole {n}.sourceArgs {n}.sourceEnv {n}.sourceTail tailNotes
        {n}.source_control {n}.source_frame stackNotes
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by simpa only [{n}.source_post] using left
      exact ⟨_,source,right,{n}.source_post ▸ related,{n}.source_post ▸ annotated,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")

end Host.Ts.Owned.Annotated.Driver
