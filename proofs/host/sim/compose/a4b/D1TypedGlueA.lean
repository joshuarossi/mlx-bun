import host.sim.compose.a4b.D1DispatchSite
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

kernel_rfl typedAccepted10 : (fun bs : List Byte => D1Frames.typedOk bs D1StageSplit.s10 D1StageSplit.S10) = fun _ => true
kernel_rfl top10 : noRetBlock D1StageSplit.s10 = true
kernel_rfl typedAccepted11 : (fun bs : List Byte => D1Frames.typedOk bs D1StageSplit.s11 D1StageSplit.S11) = fun _ => true
kernel_rfl top11 : noRetBlock D1StageSplit.s11 = true
kernel_rfl typedAccepted13 : (fun bs : List Byte => D1Frames.typedOk bs D1StageSplit.s13 D1StageSplit.S13) = fun _ => true
kernel_rfl top13 : noRetBlock D1StageSplit.s13 = true
kernel_rfl typedAccepted14 : (fun bs : List Byte => D1Frames.typedOk bs D1StageSplit.s14 D1StageSplit.S14) = fun _ => true
kernel_rfl top14 : noRetBlock D1StageSplit.s14 = true

kernel_rfl typedOracle10 : goodLin final_cold.r0.ps (varsOf final_cold.r0.V D1StageSplit.map_g1_FIN_first) D1StageSplit.S10.oracle = true
boot_rfl typedRun10 from D1StageSplit.s10 to D1StageSplit.s11 :
  (fun bs : List Byte => runOk FF (D1Frames.typedOk bs) 57 D1StageSplit.s10 D1StageSplit.S10) =
    fun _ => some (D1StageSplit.s11, D1StageSplit.S11)

kernel_rfl typedOracle13 : goodLin final_cold.r0.ps (varsOf final_cold.r0.V D1StageSplit.map_g1_FIN_first) D1StageSplit.S13.oracle = true
boot_rfl typedRun13 from D1StageSplit.s13 to D1StageSplit.s14 :
  (fun bs : List Byte => runOk FF (D1Frames.typedOk bs) 15 D1StageSplit.s13 D1StageSplit.S13) =
    fun _ => some (D1StageSplit.s14, D1StageSplit.S14)

end Host.Ts.Sim.Compose.D1Split
