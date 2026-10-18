import host.ts.RuntimeClosureCommand
import host.ts.RenameKernelRfl
set_option Elab.async false
namespace Host.Ts.Owned.Parametric.ClosureCheck.Tests

def leaves : Tree := .node "fixture" [.value (.obj 5),.value (.num (.ref 1)),
  .address 7,.symbol 17,.cell (.num (.ref 0)),.byte (.lit 300)]
theorem valid : tree 8 2 leaves = true := by rfl
theorem address_boundary : tree 7 2 leaves = false := by rfl
theorem table_boundary : tree 8 1 leaves = false := by rfl
theorem closed : treeNumeric (NumberBelow 2) leaves ∧ treeSupport (· < 8) leaves :=
  tree_sound 8 2 leaves valid

def stored : PTrie HObj := PTrie.nil |>.set 32 (.cell (some (.obj 5)))
theorem heap_valid : heap 8 2 stored = true := by rfl
theorem heap_bad_reference : heap 5 2 stored = false := by rfl
theorem stored_lookup : stored.get 32 = some (.cell (some (.obj 5))) := by rfl
theorem stored_closed : heapObjectNumeric (NumberBelow 2) (.cell (some (.obj 5))) ∧
    treeSupport (· < 8) (Encode.hobj (.cell (some (.obj 5)))) :=
  heap_get 8 2 stored heap_valid 32 _ stored_lookup

def state : St Unit := ⟨stored,40,.ret .undef,[],⟨[],(),[],[]⟩⟩
host_closure_groups state,8,2,0,1 as Groups
host_closure_heap state,8,2 using Groups as joined

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    elabCommand (← `(theorem wrong_table : tree 8 1 leaves = true := by host_kernel_rfl))
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "invalid numeric-closure certificate was not rejected by the kernel"

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    elabCommand (← `(host_closure_groups state,5,2,0,1 as WrongAddress))
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "invalid heap-group certificate was not rejected by the kernel"

end Host.Ts.Owned.Parametric.ClosureCheck.Tests
