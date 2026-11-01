import host.sim.compose.a4b.PrefillFirstTailX15
import host.sim.compose.a4b.fd.Sim
import host.sim.template.BootEq
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

noncomputable def dispatchOk (bs : List Byte) (n : Nat) : St FF.S → SSrv → Bool :=
  Template.okLocal (FDFrames.typedOk bs n)

kernel_rfl dispatchOk0 : (fun (bs : List Byte) (n : Nat) => dispatchOk bs n
  PRE_fd_vw_r0.st1.s0 PRE_fd_vw_r0.st1.S0) = fun _ _ => true
kernel_rfl dispatchOk1 : (fun (bs : List Byte) (n : Nat) => dispatchOk bs n
  PRE_fd_vw_r0.st1.s1 PRE_fd_vw_r0.st1.S1) = fun _ _ => true

boot_rfl dispatchRun from PRE_fd_vw_r0.st1.s0 to PRE_fd_vw_r0.st1.s1 :
  (fun (bs : List Byte) (n : Nat) => runOk FF (dispatchOk bs n) 424
    PRE_fd_vw_r0.st1.s0 PRE_fd_vw_r0.st1.S0) =
    fun _ _ => some (PRE_fd_vw_r0.st1.s1, PRE_fd_vw_r0.st1.S1)

noncomputable def dispatchTpl (bs : List Byte) (n : Nat) : Stage.StageTpl FF (dispatchOk bs n) where
  s0 := PRE_fd_vw_r0.st1.s0
  S0 := PRE_fd_vw_r0.st1.S0
  s1 := PRE_fd_vw_r0.st1.s1
  S1 := PRE_fd_vw_r0.st1.S1
  s2 := PRE_fd_vw_r0.st1.s2
  S2 := PRE_fd_vw_r0.st1.S2
  n := 424
  ok0 := congrFun (congrFun dispatchOk0 bs) n
  run := congrFun (congrFun dispatchRun bs) n
  ok1 := congrFun (congrFun dispatchOk1 bs) n
  halt := PRE_fd_vw_r0.st1.halt1
  last := PRE_fd_vw_r0.st1.last
  top := PRE_fd_vw_r0.st1.tpl.top

theorem dispatchSim (NB T : Nat) (tk : Nat → Nat) (bs : List Byte) (n : Nat) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (dispatchOk bs n) (Disp.KpJ (FDFrames.typedJ bs n) 4096) (FDFrames.typedW bs n) stk (VBOkF loopVB) := by
  apply (typedSim NB T tk bs n stk).mono
  intro s S h
  simp only [dispatchOk, okLocal, Bool.and_eq_true] at h
  exact h.1

end Host.Ts.Sim.Compose.FDVW
