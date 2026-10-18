import host.ts.RenameRetainedPrivateObjectRead
import host.ts.RenameRuntimeDriverValues

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

elab "host_retained_private_object " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let owner ← Parametric.Driver.field (← Parametric.Driver.field (← mkAppM ``St.ctl #[s]) ``Ctl.ret 1 0) ``Val.obj 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← Parametric.Driver.field (← Parametric.Driver.field stack ``List.cons 3 1) ``Frame.e 1 0
    let brand ← Parametric.Driver.field frame ``ExprF.priv 3 0
    let field ← Parametric.Driver.field frame ``ExprF.priv 3 1
    let object ← Parametric.Driver.field (← mkAppM ``St.obj? #[s,owner]) ``Option.some 2 1
    let descriptor ← Parametric.Driver.field (← mkAppM ``findPriv #[brand,field,← mkAppM ``Obj.priv #[object]]) ``Option.some 2 1
    let result ← Parametric.Driver.field (← Parametric.Driver.field descriptor ``PropV.data 3 0) ``Val.obj 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceOwner",owner),("sourceBrand",brand),
      ("sourceName",field),("sourceObject",object),("sourceResult",result),
      ("sourceWritable",← Parametric.Driver.field descriptor ``PropV.data 3 1),
      ("sourceEnumerable",← Parametric.Driver.field descriptor ``PropV.data 3 2),
      ("sourceTail",← Parametric.Driver.field stack ``List.cons 3 2)] do
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret (.obj {n}.sourceOwner)"
  fact "source_stack" s!"{n}.input.stack = .e (.priv {n}.sourceBrand {n}.sourceName false)::{n}.sourceTail"
  fact "source_read" s!"{n}.input.heap.get {n}.sourceOwner = some (.obj {n}.sourceObject)"
  fact "source_kind" s!"{n}.sourceObject.kind = .ordinary"
  fact "source_descriptor" s!"findPriv {n}.sourceBrand {n}.sourceName {n}.sourceObject.priv = some (.data (.obj {n}.sourceResult) {n}.sourceWritable {n}.sourceEnumerable)"
  fact "source_output" ("{" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}.ret (.obj " ++ n ++ ".sourceResult) = " ++ n ++ ".output")
  fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (head : Annotated.Tree) (tail : List Annotated.Tree) (stackNotes : notes.runtime.stack = head::tail) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime " ++ "{notes.runtime with control := returnNote (.obj " ++ n ++ ".sourceResult), stack := tail})" ++ s!"
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨frames,left,right,post,retained⟩ := inventory.private_object_read_step h {n}.sourceOwner {n}.sourceBrand
        {n}.sourceResult {n}.sourceName {n}.sourceWritable {n}.sourceEnumerable {n}.sourceObject {n}.sourceTail
        head tail {n}.source_control {n}.source_stack {n}.source_read {n}.source_kind {n}.source_descriptor stackNotes
      rw [{n}.source_output] at left post retained
      exact ⟨_,left,right,post,retained,{n}.source_servers ▸ inst⟩")

end Host.Ts.Owned.Annotated.Driver
