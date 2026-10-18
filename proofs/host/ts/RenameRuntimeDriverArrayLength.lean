import host.ts.RuntimeInventoryArrayLength
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

/-- Select the original member lookup from source control and continuation.
Its literal result is determined by the current retained array inventory. -/
elab "host_retained_array_length " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      let type? := if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F))))
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value type?
    let add (tag : String) (value : Lean.Expr) := Parametric.Driver.addData (pre ++ Name.mkSimple tag) value
    let control ← mkAppM ``St.ctl #[s]
    let a ← Parametric.Driver.field (← Parametric.Driver.field control ``Ctl.ret 1 0) ``Val.obj 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← Parametric.Driver.field (← Parametric.Driver.field stack ``List.cons 3 1) ``Frame.e 1 0
    let opt ← Parametric.Driver.field frame ``ExprF.member 2 1
    add "sourceAddress" a
    add "sourceOptional" opt
    add "sourceTail" (← Parametric.Driver.field stack ``List.cons 3 2)
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .ret (.obj {n}.sourceAddress)"
  fact "source_frame" s!"{n}.input.stack = .e (.member kLength {n}.sourceOptional)::{n}.sourceTail"
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (roles : List Annotated.Value) (entry : notes.arrays.owners {n}.sourceAddress = some roles)
      (head : Annotated.Tree) (tail : List Annotated.Tree) (stackNotes : notes.runtime.stack = head::tail) :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime ⟨returnNote (.literal (.lit (F64.ofNat roles.length))),tail,notes.runtime.cells⟩)
          ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨frames,left,right,post,retained⟩ := inventory.array_length_step h {n}.sourceAddress roles {n}.sourceOptional
        {n}.sourceTail head tail entry {n}.source_control {n}.source_frame stackNotes
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")
end Host.Ts.Owned.Annotated.Driver
