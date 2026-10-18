import host.load.stop.Clear256H0
import host.load.Compose
import host.ts.StoreLaws
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
open Host.Ts Host.Load

host_chunk Clear256 0
host_chain_run_staged Clear256

/-- Only the generated counter is specialized. Reaching this entry with
the corresponding arbitrary prefix is a source-invariant obligation. -/
theorem Clear256.entry_specialization :
    Clear256.entry = Stop.generatedAt Clear256.original Clear256.generatedCell 257 := by rfl

-- Submit reflexivity directly, as host_chunk does, so the kernel checks
-- this short source prefix without duplicating its reduction in a tactic.
open Lean Elab Command Meta in
run_elab do
  let lhs ← Term.elabTermAndSynthesize
    (← `((runS Host.Load.ffi 69 P.s3273 P.S3273).map Prod.fst)) none
  let rhs ← Term.elabTermAndSynthesize (← `(some Clear256.original)) (some (← inferType lhs))
  let type ← mkEq lhs rhs
  let value ← mkEqRefl lhs
  addDecl (.thmDecl { name := `Host.Load.Run.Full.Clear256.source_reached, levelParams := [], type, value })

theorem Clear256.source_control :
    Clear256.original.ctl = .ex Clear256.statement Clear256.localEnv := by rfl

theorem Clear256.source_statement :
    Clear256.statement = Host.Ts.Sources.Inference.Generation.Autoregressive.ast_n368 := by rfl

theorem Clear256.generated_binding :
    (chars!"generated", Clear256.generatedCell) ∈ Clear256.localEnv := by decide

theorem Clear256.generated_unique :
    Clear256.localEnv.filter (fun p => decide (p.1 = chars!"generated")) =
      [(chars!"generated", Clear256.generatedCell)] := by decide

theorem Clear256.generated_value :
    Clear256.entry.cell? Clear256.generatedCell = some (some (.num (.lit (F64.ofNat 257)))) := by rfl

theorem Clear256.periodic : (257 - 1) % 256 = 0 := by decide

theorem Clear256.execution :
    runS Host.Load.ffi 32 Clear256.entry Clear256.srv = some (Clear256.s1, Clear256.S1) :=
  Clear256.run

theorem Clear256.after_clear : Stop.afterClear Clear256.s1 = true := by rfl

theorem Clear256.native_state_preserved : Clear256.s1.ffi = Clear256.entry.ffi := by rfl

theorem Clear256.caller_preserved : Clear256.s1.stack.tail = Clear256.entry.stack.tail := by rfl

theorem Clear256.heap_extension :
    Clear256.s1.heap = Clear256.entry.heap.set Clear256.entry.next (.cell (some .undef)) := by rfl

theorem Clear256.old_heap_preserved (i : Nat) (hi : i < Clear256.entry.next) :
    Clear256.s1.heap.get i = Clear256.entry.heap.get i := by
  rw [Clear256.heap_extension]
  exact PTrie.get_set_ne _ _ _ (by decide) i (Nat.ne_of_lt hi)

theorem Clear256.one_event : Clear256.s1.trace.tail = Clear256.entry.trace := by rfl

theorem Clear256.clear_called :
    (Clear256.s1.trace.head?.map (·.sym)) = some chars!"mlx_clear_cache" := by rfl

end Host.Load.Run.Full
