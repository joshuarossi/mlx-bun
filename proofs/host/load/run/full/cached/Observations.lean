import host.load.run.full.SourceFirstStep
import host.load.stop.BudgetEnd
namespace Host.Load.Run.Full.Cached
open Host.Ts Host.Mlx Host.Mlx.FfiEval
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem final_emitted_values : emittedValues P.s3575 (entryEnv P.s0) =
    some [.num (.ref 1),.num (.ref 2),.num (.ref 3),.num (.ref 4),.num (.ref 5)] := by rfl

theorem final_read_expression (i : Nat) (h : i ∈ [1,2,3,4,5]) :
    P.S3575.val (.ref i) = some (.var i) := by
  simp at h
  rcases h with rfl | rfl | rfl | rfl | rfl <;> rfl

theorem final_emitted_numbers (ρ : Nat → F64) (server : CSrv)
    (table : server.tab = P.S3575.tab.map (SymE.eval ρ)) :
    emittedNumbers P.s3575 (entryEnv P.s0) server = some [ρ 1,ρ 2,ρ 3,ρ 4,ρ 5] := by
  have numbers (i : Nat) (hi : i ∈ [1,2,3,4,5]) : server.val (.ref i) = some (ρ i) := by
    rw [val_inst table (.ref i),final_read_expression i hi]
    rfl
  unfold emittedNumbers
  rw [final_emitted_values]
  change (server.val (.ref 1)).bind (fun a =>
    (server.val (.ref 2)).bind (fun b => (server.val (.ref 3)).bind (fun c =>
    (server.val (.ref 4)).bind (fun d => (server.val (.ref 5)).bind (fun e => some [a,b,c,d,e]))))) = _
  rw [numbers 1 (by decide),numbers 2 (by decide),numbers 3 (by decide),numbers 4 (by decide),numbers 5 (by decide)]
  rfl

theorem final_read_memo : P.s3575.ffi.mlx.items =
    (((((PTrie.nil : PTrie NumV).set 17776 (.ref 1)).set 20157 (.ref 2)).set 22538 (.ref 3)).set 24919 (.ref 4)).set 27300 (.ref 5) := by rfl
end Host.Load.Run.Full.Cached
