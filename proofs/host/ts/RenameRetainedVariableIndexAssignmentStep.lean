import host.ts.RenameRetainedVariableIndexAssignment
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver
import host.ts.RenameKernelRfl
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta Parametric.Driver

/-- Select a current local-variable indexed assignment and check the complete
five-step source endpoint before exporting its arbitrary-target transport. -/
elab "host_retained_variable_index_assignment " f:term ", " s:term " using " initial:term
    " to " t:term " using " next:term " as " name:ident : command => do
  let saved ← get
  try
    let pre := (← getCurrNamespace) ++ name.getId
    liftTermElabM do
      let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
      let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
      let s ← Term.elabTermEnsuringType s stateTy
      let t ← Term.elabTermEnsuringType t stateTy
      let control ← whnf (← mkAppM ``St.ctl #[s])
      unless control.isAppOfArity ``Ctl.ev 2 do throwError "variable indexed assignment: expected expression"
      let expression ← whnf control.getAppArgs[0]!
      unless expression.isAppOfArity ``Expr.assign 3 do throwError "variable indexed assignment: expected assignment"
      unless (← whnf expression.getAppArgs[0]!).isConstOf ``AsgOp.assign do
        throwError "variable indexed assignment: expected plain assignment"
      let index ← whnf (← field expression.getAppArgs[1]! ``Pat.expr 1 0)
      unless index.isAppOfArity ``Expr.index 3 do throwError "variable indexed assignment: expected indexed target"
      let ownerName ← field index.getAppArgs[0]! ``Expr.id 1 0
      let indexName ← field index.getAppArgs[1]! ``Expr.id 1 0
      let env := control.getAppArgs[1]!
      let cell ← field (← mkAppM ``lookupEnv #[ownerName,env]) ``Option.some 2 1
      let indexCell ← field (← mkAppM ``lookupEnv #[indexName,env]) ``Option.some 2 1
      let readCell (a : Lean.Expr) := do
        field (← field (← field (← mkAppM ``PTrie.get #[← mkAppM ``St.heap #[s],a]) ``Option.some 2 1)
          ``HObj.cell 1 0) ``Option.some 2 1
      let owner ← field (← readCell cell) ``Val.obj 1 0
      let literal ← field (← field (← readCell indexCell) ``Val.num 1 0) ``NumV.lit 1 0
      let number ← field (← mkAppM ``F64.toIndex? #[literal]) ``Option.some 2 1
      for (tag,value) in [("F",f),("input",s),("output",t),("ownerName",ownerName),("indexName",indexName),
          ("env",env),("cell",cell),("indexCell",indexCell),("owner",owner),("literal",literal),
          ("index",number),("optional",index.getAppArgs[2]!),("rhs",expression.getAppArgs[2]!)] do
        addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
      addData (pre ++ `initialServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType initial (mkConst ``SSrv)])
      addData (pre ++ `nextServer) (← mkAppM ``numberServer #[← Term.elabTermEnsuringType next (mkConst ``SSrv)])
    let n := "_root_." ++ pre.toString
    let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
    let emit (text : String) : CommandElabM Unit := do
      Parametric.Driver.emit (header ++ text)
      if (← get).messages.hasErrors then
        let mut detail := ""
        for message in (← get).messages.toList.drop saved.messages.toList.length do
          detail := detail ++ (← message.data.toString) ++ "\n"
        throwError "variable indexed assignment source proof failed: {detail}"
    let fact (tag proposition : String) := emit s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl"
    fact "source_control" s!"{n}.input.ctl = .ev (.assign .assign (.expr (.index (.id {n}.ownerName) (.id {n}.indexName) {n}.optional)) {n}.rhs) {n}.env"
    fact "source_lookup" s!"lookupEnv {n}.ownerName {n}.env = some {n}.cell"
    fact "source_index_lookup" s!"lookupEnv {n}.indexName {n}.env = some {n}.indexCell"
    fact "source_cell" s!"{n}.input.heap.get {n}.cell = some (.cell (some (.obj {n}.owner)))"
    fact "source_index_cell" s!"{n}.input.heap.get {n}.indexCell = some (.cell (some (.num (.lit {n}.literal))))"
    fact "source_index" s!"F64.toIndex? {n}.literal = some {n}.index"
    fact "source_output" s!"Annotated.CachedArrayEntry.indexAssignmentResult {n}.input {n}.owner {n}.index {n}.rhs {n}.env = {n}.output"
    fact "source_servers" s!"{n}.initialServer = {n}.nextServer"
    emit s!"theorem {n}.source_run (C : CSrv) : runC {n}.F 5 {n}.input C = some ({n}.output,C) := by host_kernel_rfl"
    emit s!"theorem {n}.retained_transport
        (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
        (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
        (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
        (inst : Inst ν₀ {n}.initialServer C₀)
        (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
        (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
        (indexNote : notes.runtime.cells.cells {n}.indexCell = some (.literal (.lit {n}.literal))) :
        ∃ result, runC {n}.F 5 {n}.input C₀ = some ({n}.output,C₀) ∧ runC {n}.F 5 s C = some (result,C) ∧
          Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
          RetainedInventory (notes.withRuntime ⟨expressionNote {n}.rhs {n}.env,
            Annotated.CachedArrayEntry.indexPutNote {n}.owner {n}.index::notes.runtime.stack,notes.runtime.cells⟩)
            ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
        obtain ⟨left,right,post,retained⟩ := inventory.variable_index_assignment h
          {n}.ownerName {n}.indexName {n}.cell {n}.indexCell {n}.owner {n}.index {n}.literal {n}.rhs {n}.env {n}.optional
          {n}.source_control {n}.source_lookup {n}.source_index_lookup {n}.source_cell {n}.source_index_cell {n}.source_index indexNote
        rw [{n}.source_output] at left post retained
        exact ⟨_,left,right,post,retained,{n}.source_servers ▸ inst⟩"
  catch exception =>
    set saved
    throw exception

end Host.Ts.Owned.Annotated.Driver
