import host.sim.compose.a4b.D1Nps
import host.sim.compose.a4b.D1SliceData

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl fuel1 : (nth? D1StageSplit.ks 1).getD 0 = 72
kernel_rfl accepted1 : D1StageSplit.okB1 D1StageSplit.s1 D1StageSplit.S1 = true
kernel_rfl live2 : isHalt D1StageSplit.s2.ctl = false
kernel_rfl top3 : noRetBlock D1StageSplit.s3 = true
kernel_rfl bridge3 : bridgeOf D1StageSplit.s3.ffi = bridgeOf D1StageSplit.s1.ffi
kernel_rfl oracle1 : goodLin final_cold.r0.ps (varsOf final_cold.r0.V D1StageSplit.map_g1_FIN_first)
  D1StageSplit.S1.oracle = true

end Host.Ts.Sim.Compose.D1Split
