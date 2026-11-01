import host.sim.compose.a4b.x3.DispatchSite
import host.sim.compose.PreGrow
import host.sim.full.TargetGrowD
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X3
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly

theorem dispatchGrowSim (NB T : Nat) (tk : Nat → Nat) (bs : List Byte) (n : Nat)
    (stk : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (dispatchOk bs n) (Disp.KpJ (VWFrames.typedJ bs n) 4096)
      (VWFrames.typedW bs n) stk (VBOkF loopVB) := by
  apply (typedGrowSimAt NB T tk bs n 4096 stk y0).mono
  intro s S h
  simp only [dispatchOk, okLocal, Bool.and_eq_true] at h
  exact h.1

end Host.Ts.Sim.Compose.VWFirst.X3
