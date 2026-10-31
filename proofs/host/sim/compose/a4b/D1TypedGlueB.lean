import host.sim.compose.a4b.D1TypedGlueA
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

kernel_rfl typedAccepted16 : (fun bs : List Byte => D1Frames.typedOk bs D1StageSplit.s16 D1StageSplit.S16) = fun _ => true
kernel_rfl top16 : noRetBlock D1StageSplit.s16 = true
kernel_rfl typedAccepted17 : (fun bs : List Byte => D1Frames.typedOk bs D1StageSplit.s17 D1StageSplit.S17) = fun _ => true
kernel_rfl top17 : noRetBlock D1StageSplit.s17 = true
kernel_rfl typedAccepted19 : (fun bs : List Byte => D1Frames.typedOk bs D1StageSplit.s19 D1StageSplit.S19) = fun _ => true
kernel_rfl top19 : noRetBlock D1StageSplit.s19 = true
kernel_rfl typedAccepted20 : (fun bs : List Byte => D1Frames.typedOk bs D1StageSplit.s20 D1StageSplit.S20) = fun _ => true
kernel_rfl top20 : noRetBlock D1StageSplit.s20 = true
kernel_rfl typedAccepted21 : (fun bs : List Byte => D1Frames.typedOk bs D1StageSplit.s21 D1StageSplit.S21) = fun _ => true
kernel_rfl top21 : noRetBlock D1StageSplit.s21 = true
kernel_rfl typedAccepted22 : (fun bs : List Byte => D1Frames.typedOk bs D1StageSplit.s22 D1StageSplit.S22) = fun _ => true
kernel_rfl top22 : noRetBlock D1StageSplit.s22 = true

kernel_rfl typedOracle16 : goodLin final_cold.r0.ps (varsOf final_cold.r0.V D1StageSplit.map_g1_FIN_first) D1StageSplit.S16.oracle = true
boot_rfl typedRun16 from D1StageSplit.s16 to D1StageSplit.s17 :
  (fun bs : List Byte => runOk FF (D1Frames.typedOk bs) 71 D1StageSplit.s16 D1StageSplit.S16) =
    fun _ => some (D1StageSplit.s17, D1StageSplit.S17)

kernel_rfl typedOracle19 : goodLin final_cold.r0.ps (varsOf final_cold.r0.V D1StageSplit.map_g1_FIN_first) D1StageSplit.S19.oracle = true
boot_rfl typedRun19 from D1StageSplit.s19 to D1StageSplit.s20 :
  (fun bs : List Byte => runOk FF (D1Frames.typedOk bs) 1 D1StageSplit.s19 D1StageSplit.S19) =
    fun _ => some (D1StageSplit.s20, D1StageSplit.S20)

kernel_rfl typedOracle21 : goodLin final_cold.r0.ps (varsOf final_cold.r0.V D1StageSplit.map_g1_FIN_first) D1StageSplit.S21.oracle = true
boot_rfl typedRun21 from D1StageSplit.s21 to D1StageSplit.s22 :
  (fun bs : List Byte => runOk FF (D1Frames.typedOk bs) 7 D1StageSplit.s21 D1StageSplit.S21) =
    fun _ => some (D1StageSplit.s22, D1StageSplit.S22)

end Host.Ts.Sim.Compose.D1Split
