import host.ts.RenameRetainedStructuralMember
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver
import host.ts.RenameKernelRfl
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

/-- Select an ordinary own-data read only when the actual source value has a
structural role. Numeric fields continue to require retained provenance. -/
elab "host_retained_structural_member " f:term ", " s:term " using " initial:term
    " to " t:term " using " next:term " as " name:ident : command => do
  let saved ← get
  try
    let pre := (← getCurrNamespace) ++ name.getId
    liftTermElabM do
      let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
      let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
      let s ← Term.elabTermEnsuringType s stateTy
      let t ← Term.elabTermEnsuringType t stateTy
      let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
      let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
      let control ← mkAppM ``St.ctl #[s]
      let address ← Parametric.Driver.field (← Parametric.Driver.field control ``Ctl.ret 1 0) ``Val.obj 1 0
      let object ← Parametric.Driver.field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
      unless (← whnf (← mkAppM ``Obj.kind #[object])).isConstOf ``Kind.ordinary do
        throwError "structural member: expected ordinary object"
      let stack ← mkAppM ``St.stack #[s]
      let frame ← Parametric.Driver.field (← Parametric.Driver.field stack ``List.cons 3 1) ``Frame.e 1 0
      let member ← whnf frame
      unless member.isAppOfArity ``ExprF.member 2 do throwError "structural member: expected member frame"
      unless (← whnf member.getAppArgs[1]!).isConstOf ``Bool.false do
        throwError "structural member: optional read is not supported"
      let field ← Parametric.Driver.field member.getAppArgs[0]! ``PKey.str 1 0
      let descriptor ← Parametric.Driver.field (← mkAppM ``findProp
        #[mkApp (mkConst ``PKey.str) field,← mkAppM ``Obj.props #[object]]) ``Option.some 2 1
      let descriptor ← whnf descriptor
      unless descriptor.isAppOfArity ``PropV.data 3 do throwError "structural member: expected own data field"
      let value := descriptor.getAppArgs[0]!
      let selected ← whnf (← mkAppM ``structuralRole #[value])
      unless selected.isAppOfArity ``Option.some 2 do
        throwError "structural member: numeric field requires retained provenance"
      for (tag,value) in [("F",f),("input",s),("output",t),("address",address),("object",object),
          ("field",field),("value",value),("role",selected.getAppArgs[1]!),
          ("writable",descriptor.getAppArgs[1]!),("enumerable",descriptor.getAppArgs[2]!),
          ("sourceTail",← Parametric.Driver.field stack ``List.cons 3 2)] do
        let type? := if tag == "input" || tag == "output" then
          some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
        Parametric.Driver.addData (pre ++ Name.mkSimple tag) value type?
      Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
      Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
    let n := "_root_." ++ pre.toString
    let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
    let emit (text : String) : CommandElabM Unit := do
      Parametric.Driver.emit (header ++ text)
      if (← get).messages.hasErrors then
        let mut detail := ""
        for message in (← get).messages.toList.drop saved.messages.toList.length do
          detail := detail ++ (← message.data.toString) ++ "\n"
        throwError "structural member source proof failed: {detail}"
    let fact (tag proposition : String) := emit s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl"
    fact "source_control" s!"{n}.input.ctl = .ret (.obj {n}.address)"
    fact "source_frame" s!"{n}.input.stack = .e (.member (.str {n}.field) false)::{n}.sourceTail"
    fact "source_heap" s!"{n}.input.heap.get {n}.address = some (.obj {n}.object)"
    fact "source_kind" s!"{n}.object.kind = .ordinary"
    fact "source_data" s!"findProp (.str {n}.field) {n}.object.props = some (.data {n}.value {n}.writable {n}.enumerable)"
    fact "source_role" s!"structuralRole {n}.value = some {n}.role"
    let post := "({" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}).ret " ++ s!"{n}.value"
    fact "source_post" s!"({post}) = {n}.output"
    fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
    emit s!"theorem {n}.retained_transport
        (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
        (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
        (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
        (inst : Inst ν₀ {n}.initialServer C₀)
        (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
        (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) :
        ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
          interpC (step {n}.F s).run C = some (result,C) ∧
          Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
          RetainedInventory (notes.withRuntime (notes.runtime.binaryResult {n}.role notes.runtime.stack.tail))
            ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
        obtain ⟨_,_,sourceRun,targetRun,post,retained⟩ := inventory.structural_member_step h
          {n}.address {n}.field {n}.value {n}.role {n}.writable {n}.enumerable {n}.object {n}.sourceTail
          {n}.source_control {n}.source_frame {n}.source_heap {n}.source_kind {n}.source_data
          (structuralRole_sound {n}.source_role)
        rw [{n}.source_post] at sourceRun post retained
        exact ⟨_,sourceRun,targetRun,post,retained,
          pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step sourceRun⟩"
  catch exception =>
    set saved
    throw exception

end Host.Ts.Owned.Annotated.Driver
