import host.sim.extract.CacheFix
import host.sim.extract.Stats
import host.load.stop.Stats
import host.sim.template.eosx.Case
import host.sim.template.finale.Case
import host.sim.template.finalec0.Case
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Load.Run.Full Host.Ts.Sim.ExtractSim

/-! # The `generation` cell and the EOS halts' finish reason

The entry environment's `generation` binding lives at cell `genCell`; each loop case's restart
map keeps it. At the halts of the EOS cases, `generation.stats.finishReason` is `"stop"`;
under a relation fixing `genCell` the target reads the same (`statsField_stop`). -/

/-- The entry environment's `generation` cell. -/
def genCell : Nat := 2589

kernel_rfl generation_cell : lookupEnv chars!"generation" (entryEnv P.s0) = some genCell

kernel_rfl ORDINARY.fixGen : ORDINARY.σ.a genCell = genCell
kernel_rfl CLEAR.fixGen : CLEAR.σ.a genCell = genCell
kernel_rfl GROWTH.fixGen : GROWTH.σ.a genCell = genCell
kernel_rfl FILL.fixGen : FILL.σ.a genCell = genCell

kernel_rfl EOSX.finish_reason :
    Stop.statsField EOSX.s4 (entryEnv P.s0) chars!"finishReason" = some (.str chars!"stop")
kernel_rfl FINALE.finish_reason :
    Stop.statsField FINALE.s4 (entryEnv P.s0) chars!"finishReason" = some (.str chars!"stop")
kernel_rfl FINALEC0.finish_reason :
    Stop.statsField FINALEC0.s4 (entryEnv P.s0) chars!"finishReason" = some (.str chars!"stop")

/-- **The finish reason through the relation**: with the `generation` cell fixed, the target
reads the source's `generation.stats.finishReason` string. -/
theorem statsField_stop {FR : Map → Nat → LSt → LSt → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t : St LSt} {S : SSrv} {C : CSrv} (h : Rel Host.Load.ffi FR M ν K s S t C) (hfa : M.a genCell = genCell)
    {x : List Char} (hs : Stop.statsField s (entryEnv P.s0) chars!"finishReason" = some (.str x)) :
    Stop.statsField t (entryEnv P.s0) chars!"finishReason" = some (.str x) :=
  own2_str_map h generation_cell hfa _ _ x hs

end Host.Load.Run.Tpl
