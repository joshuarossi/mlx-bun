import host.ts.RenameRetainedIndex
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Select original nonoptional computed-key scheduling or an owned-array
element read. Meanings come from the current return/array notes. -/
elab "host_retained_index " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let left ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))))
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let control ← mkAppM ``St.ctl #[s]
    let value ← field control ``Ctl.ret 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← whnf (← field (← field stack ``List.cons 3 1) ``Frame.e 1 0)
    add "sourceTail" (← field stack ``List.cons 3 2)
    if frame.isAppOfArity ``ExprF.indexL 3 then
      add "sourceValue" value
      add "sourceKey" frame.getAppArgs[0]!
      add "sourceEnv" frame.getAppArgs[1]!
      pure true
    else
      let a ← field (← field frame ``ExprF.indexR 1 0) ``Val.obj 1 0
      let key ← field (← field value ``Val.num 1 0) ``NumV.lit 1 0
      let i ← field (← mkAppM ``numIndex #[value]) ``Option.some 2 1
      let object ← field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
      let values ← field (← mkAppM ``Obj.kind #[object]) ``Kind.array 1 0
      for (tag,value) in [("sourceAddress",a),("sourceIndex",i),("sourceKey",key),("sourceObject",object),("sourceValues",values)] do add tag value
      pure false
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  let (extra,postNotes,call,results) ← if left then do
      fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
      fact "source_frame" s!"{n}.input.stack = .e (.indexL {n}.sourceKey {n}.sourceEnv false)::{n}.sourceTail"
      pure ("(role : Annotated.Value) (controlNote : notes.runtime.control = returnNote role)",
        s!"notes.withRuntime ⟨expressionNote {n}.sourceKey {n}.sourceEnv,indexRightFrameNote role::tail,notes.runtime.cells⟩",
        s!"inventory.index_left_step h {n}.sourceValue role {n}.sourceKey {n}.sourceEnv {n}.sourceTail head tail
          {n}.source_control {n}.source_frame controlNote stackNotes","receiver,frames,left,right,post,retained")
    else do
      fact "source_control" s!"{n}.input.ctl = .ret (.num (.lit {n}.sourceKey))"
      fact "source_frame" s!"{n}.input.stack = .e (.indexR (.obj {n}.sourceAddress))::{n}.sourceTail"
      fact "source_index" s!"numIndex (.num (.lit {n}.sourceKey)) = some {n}.sourceIndex"
      fact "source_heap" s!"{n}.input.heap.get {n}.sourceAddress = some (.obj {n}.sourceObject)"
      fact "source_kind" s!"{n}.sourceObject.kind = .array {n}.sourceValues"
      pure (s!"(roles : List Annotated.Value) (role : Annotated.Value) (meaning : SymE)
        (entry : notes.arrays.owners {n}.sourceAddress = some roles)
        (element : nth? roles {n}.sourceIndex = some role)
        (controlNote : notes.runtime.control = returnNote (.literal meaning)) (closed : meaning.closed = true)",
        "notes.withRuntime ⟨returnNote role,tail,notes.runtime.cells⟩",
        s!"inventory.closed_array_index_step h {n}.sourceAddress {n}.sourceIndex roles role meaning {n}.sourceKey
          {n}.sourceTail head tail entry element {n}.source_control {n}.source_frame {n}.source_index closed controlNote stackNotes",
        "value,targetValue,frames,left,right,post,retained")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (head : Annotated.Tree) (tail : List Annotated.Tree) (stackNotes : notes.runtime.stack = head::tail) {extra} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory ({postNotes}) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨{results}⟩ := {call}
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")
end Host.Ts.Owned.Annotated.Driver
