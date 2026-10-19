import host.load.RuntimeCachedArrayEntryCuts
import host.load.RuntimeBlockPlan
import host.ts.RenameRetainedTypedCountStep
import host.ts.RenameCachedArrayEntryBlock
import host.ts.RenameCachedArrayEntryAssignment

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedArrayEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let pre ← getCurrNamespace
  for i in List.range 41 do
    let part := min 3 (i/10)
    let offset := i-part*10
    for tag in ["s","S"] do
      let source := pre ++ Name.mkSimple s!"From{2447+part*10}" ++ `Cut ++ Name.mkSimple s!"{tag}{offset}"
      Host.Ts.Owned.Parametric.Driver.addData (pre ++ `Region ++ Name.mkSimple s!"{tag}{i}") (mkConst source)

host_retained_typed_count P.F, Region.s0 using Region.S0 to Region.s1 using Region.S1 as Allocation

namespace Scope
noncomputable def input := Region.s28
noncomputable def output := Region.s29
noncomputable def initialServer := Region.S28
noncomputable def nextServer := Region.S29
noncomputable def body : List Stmt := match input.ctl with | .ex (.block body) _ => body | _ => []
noncomputable def env : Env := match input.ctl with | .ex _ env => env | _ => []
theorem source_control : input.ctl = .ex (.block body) env := by host_kernel_rfl
theorem source_empty : blockNames body = [] := by host_kernel_rfl
theorem source_output : enterBlock input body env = output := by host_kernel_rfl
theorem source_servers : initialServer = nextServer := by host_kernel_rfl

theorem retained_transport
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s) :
    ∃ result, interpC (step P.F input).run C₀ = some (output,C₀) ∧
      interpC (step P.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' output result ∧
      RetainedInventory (notes.withRuntime (notes.runtime.bodyEntered body env notes.runtime.stack))
        ν₀ ν C₀ C R live output result ∧ Inst ν₀ nextServer C₀ := by
  obtain ⟨left,right,post,retained⟩ := Annotated.CachedArrayEntry.retained_empty_block_step h inventory body env source_empty source_control
  rw [source_output] at left post retained
  exact ⟨_,left,right,post,retained,source_servers ▸ inst⟩
end Scope

namespace Indexed
noncomputable def input := Region.s31
noncomputable def output := Region.s36
noncomputable def initialServer := Region.S31
noncomputable def nextServer := Region.S36
def span : Nat := 5
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let pre ← getCurrNamespace
  let field := Host.Ts.Owned.Parametric.Driver.field
  let source := mkConst (`Host.Load.Run.Full.Ordinary.CachedArrayEntry.Indexed.input)
  let ctl ← mkAppM ``St.ctl #[source]
  let expression ← field ctl ``Ctl.ev 2 0
  let env ← field ctl ``Ctl.ev 2 1
  let pat ← field expression ``Expr.assign 3 1
  let index ← field pat ``Pat.expr 1 0
  let name ← field (← field index ``Expr.index 3 0) ``Expr.id 1 0
  let raw ← field (← field (← field index ``Expr.index 3 1) ``Host.Ts.Expr.lit 1 0) ``Lit.num 1 0
  let x ← field (← mkAppM ``F64.ofLit #[raw]) ``Option.some 2 1
  let number ← field (← mkAppM ``F64.toIndex? #[x]) ``Option.some 2 1
  let cell ← field (← mkAppM ``lookupEnv #[name,env]) ``Option.some 2 1
  let owner ← field (← field (← field (← mkAppM ``PTrie.get #[← mkAppM ``St.heap #[source],cell]) ``Option.some 2 1) ``HObj.cell 1 0) ``Option.some 2 1
  let owner ← field owner ``Val.obj 1 0
  for (tag,value) in [("name",name),("env",env),("raw",raw),("literal",x),("index",number),("cell",cell),("owner",owner),
      ("optional",← field index ``Expr.index 3 2),("rhs",← field expression ``Expr.assign 3 2)] do
    Host.Ts.Owned.Parametric.Driver.addData (pre ++ Name.mkSimple tag) value

theorem source_control : input.ctl = .ev (.assign .assign (.expr (.index (.id name) (.lit (.num raw)) optional)) rhs) env := by host_kernel_rfl
theorem source_lookup : lookupEnv name env = some cell := by host_kernel_rfl
theorem source_cell : input.heap.get cell = some (.cell (some (.obj owner))) := by host_kernel_rfl
theorem source_literal : F64.ofLit raw = some literal := by host_kernel_rfl
theorem source_index : F64.toIndex? literal = some index := by host_kernel_rfl
theorem source_output : Annotated.CachedArrayEntry.indexAssignmentResult input owner index rhs env = output := by host_kernel_rfl
theorem source_servers : initialServer = nextServer := by host_kernel_rfl

theorem retained_transport
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s) :
    ∃ result, runC P.F 5 input C₀ = some (output,C₀) ∧
      runC P.F 5 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' output result ∧
      RetainedInventory (notes.withRuntime ⟨expressionNote rhs env,Annotated.CachedArrayEntry.indexPutNote owner index::notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live output result ∧ Inst ν₀ nextServer C₀ := by
  obtain ⟨left,right,post,retained⟩ := Annotated.CachedArrayEntry.retained_index_assignment h inventory
    name cell owner index raw literal rhs env optional source_control source_lookup source_cell source_literal source_index
  rw [source_output] at left post retained
  exact ⟨_,left,right,post,retained,source_servers ▸ inst⟩
end Indexed

open Lean Elab Command Meta in
run_cmd do
  let pre ← getCurrNamespace
  let mut rules := [pre ++ `Allocation.retained_transport]
  for i in List.range 39 do
    let i := i+1
    if i == 28 then rules := rules ++ [pre ++ `Scope.retained_transport]
    else if i == 31 then rules := rules ++ [pre ++ `Indexed.retained_transport]
    else if 31 < i && i < 36 then pure ()
    else
      Host.Ts.Owned.Parametric.Driver.emit s!"host_source_step P.F, Region.s{i} using Region.S{i} to Region.s{i+1} using Region.S{i+1} as Rest.Block{i}"
      if (← get).messages.hasErrors then throwError "cached entry source rule failed at offset {i}"
      rules := rules ++ [pre ++ `Rest ++ Name.mkSimple s!"Block{i}" ++ `retained_transport]
  liftTermElabM do
    Host.Ts.Owned.Parametric.Driver.addData (pre ++ `Plan.rules) (toExpr rules)

noncomputable def countCell : Nat := Rest.Block25.address
noncomputable def countLiteral : F64 := match Rest.Block25.sourceValue with | .num (.lit x) => x | _ => F64.ofNat 0
theorem current_count_cell : Region.s0.heap.get countCell = some (.cell (some (.num (.lit countLiteral)))) := by host_kernel_rfl
theorem current_count_is_three : countLiteral = F64.ofNat 3 := by host_kernel_rfl

end Host.Load.Run.Full.Ordinary.CachedArrayEntry
