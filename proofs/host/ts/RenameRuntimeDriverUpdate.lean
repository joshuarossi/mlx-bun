import host.ts.RenameRetainedUpdate
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric.Driver

/-- Original postfix read, literal add-one store, and old-value return.
Current cell/control/continuation notes supply every occurrence meaning. -/
elab "host_retained_update " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
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
      let expression ← whnf control.getAppArgs[0]!
      let name ← field (← field expression ``Expr.update 3 2) ``Expr.id 1 0
      let env := control.getAppArgs[1]!
      let a ← field (← mkAppM ``lookupEnv #[name,env]) ``Option.some 2 1
      let value ← field (← field (← mkAppM ``St.cell? #[s,a]) ``Option.some 2 1) ``Option.some 2 1
      for (tag,value) in [("sourceName",name),("sourceEnv",env),("sourceAddress",a),("sourceValue",value)] do add tag value
      pure "read"
    else
      let value ← field control ``Ctl.ret 1 0
      let stack ← mkAppM ``St.stack #[s]
      let frame ← whnf (← field stack ``List.cons 3 1)
      add "sourceTail" (← field stack ``List.cons 3 2)
      if frame.isAppOfArity ``Frame.a 1 then
        let assignment ← field frame ``Frame.a 1 0
        let target ← field assignment ``AsgF.updOld 3 2
        let name ← field target ``Target.var 2 0
        let env ← field target ``Target.var 2 1
        let a ← field (← mkAppM ``lookupEnv #[name,env]) ``Option.some 2 1
        let number ← field (← field value ``Val.num 1 0) ``NumV.lit 1 0
        for (tag,value) in [("sourceName",name),("sourceEnv",env),("sourceAddress",a),("sourceNumber",number)] do add tag value
        pure "increment"
      else
        add "sourceValue" value
        add "sourceSaved" (← field (← field frame ``Frame.e 1 0) ``ExprF.const 1 0)
        pure "constant"
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  let (extra,postNotes,call,results) ← if branch == "read" then do
      fact "source_control" s!"{n}.input.ctl = .ev (.update true false (.id {n}.sourceName)) {n}.sourceEnv"
      fact "source_lookup" s!"lookupEnv {n}.sourceName {n}.sourceEnv = some {n}.sourceAddress"
      fact "source_cell" s!"{n}.input.heap.get {n}.sourceAddress = some (.cell (some {n}.sourceValue))"
      pure (s!"(role : Annotated.Value) (entry : notes.runtime.cells.cells {n}.sourceAddress = some role)",
        s!"notes.withRuntime ⟨returnNote role,updateOldFrameNote {n}.sourceName {n}.sourceEnv::notes.runtime.stack,notes.runtime.cells⟩",
        s!"inventory.update_variable_step h {n}.sourceName {n}.sourceEnv {n}.sourceAddress {n}.sourceValue role
          {n}.source_control {n}.source_lookup {n}.source_cell entry","value,left,right,post,retained")
    else if branch == "constant" then do
      fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
      fact "source_frame" s!"{n}.input.stack = .e (.const {n}.sourceSaved)::{n}.sourceTail"
      pure ("(role : Annotated.Value) (tail : List Annotated.Tree) (stackNotes : notes.runtime.stack = constantFrameNote role::tail)",
        "notes.withRuntime ⟨returnNote role,tail,notes.runtime.cells⟩",
        s!"inventory.constant_step h {n}.sourceValue {n}.sourceSaved {n}.sourceTail role tail {n}.source_control {n}.source_frame stackNotes",
        "value,frames,left,right,post,retained")
    else do
      -- Ghost arithmetic is reduced by the kernel. Avoid compiling this
      -- constant through the toolchain's failing LCNF join-point pass.
      Parametric.Driver.emit (header ++ s!"noncomputable def {n}.sourceNextNumber : F64 := F64.bin .add {n}.sourceNumber (.fin false 1 0)")
      fact "source_sum" s!"F64.bin .add {n}.sourceNumber (.fin false 1 0) = {n}.sourceNextNumber"
      fact "source_control" s!"{n}.input.ctl = .ret (.num (.lit {n}.sourceNumber))"
      fact "source_frame" s!"{n}.input.stack = .a (.updOld true false (.var {n}.sourceName {n}.sourceEnv))::{n}.sourceTail"
      fact "source_lookup" s!"lookupEnv {n}.sourceName {n}.sourceEnv = some {n}.sourceAddress"
      fact "source_cell" s!"{n}.input.heap.get {n}.sourceAddress = some (.cell (some (.num (.lit {n}.sourceNumber))))"
      Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next ≤ 2^64 := by decide +kernel")
      pure (s!"(meaning : SymE) (head : Annotated.Tree) (tail : List Annotated.Tree)
        (entry : notes.runtime.cells.cells {n}.sourceAddress = some (.literal meaning))
        (controlNote : notes.runtime.control = returnNote (.literal meaning)) (stackNotes : notes.runtime.stack = head::tail)
        (closed : meaning.closed = true) (targetBound : s.next ≤ 2^64)",
        s!"notes.withRuntime ⟨returnNote (.literal (.bin .add meaning (.lit (.fin false 1 0)))),constantFrameNote (.literal meaning)::tail,
          notes.runtime.cells.write {n}.sourceAddress (.literal (.bin .add meaning (.lit (.fin false 1 0))))⟩",
        s!"inventory.postincrement_step h {n}.sourceName {n}.sourceEnv {n}.sourceAddress {n}.sourceNumber {n}.sourceNextNumber
          meaning {n}.sourceTail head tail {n}.source_control {n}.source_frame {n}.source_lookup {n}.source_cell
          entry controlNote stackNotes closed {n}.source_bound targetBound {n}.source_sum",
        "frames,left,right,post,retained")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) {extra} :
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
