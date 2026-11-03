import host.sim.compose.a4b.fd.TypedGlue
import host.sim.compose.a4b.fd.DispatchTpl

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

noncomputable def dispatchSite (NB T : Nat) (tk : Nat → Nat) (bs : List Byte) (n : Nat) :
    PrefillSite (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (Disp.KpJ (FDFrames.typedJ bs n) 131072) (FDFrames.typedW bs n) (dispatchOk bs n)
      PRE_fd_vw_r0.s21 PRE_fd_vw_r0.s22 PRE_fd_vw_r0.S21 PRE_fd_vw_r0.ws1 where
  tpl := dispatchTpl bs n
  wr := PRE_fd_vw_r0.st1.wr
  start := PRE_fd_vw_r0.iso1
  tab := PRE_fd_vw_r0.tab0_1
  sim := dispatchSim NB T tk bs n
  localOk := okLocal_localB
  foot := PRE_fd_vw_r0.stFoot1
  nodup := PRE_fd_vw_r0.wrNodup1
  bound := PRE_fd_vw_r0.wrBound1
  trace := PRE_fd_vw_r0.trace1
  merged := PRE_fd_vw_r0.merged1
  len := by
    change PRE_fd_vw_r0.ws1.length = PRE_fd_vw_r0.st1.S2.tab.length - PRE_fd_vw_r0.S21.tab.length
    rw [← PRE_fd_vw_r0.tab0_1, PRE_fd_vw_r0.mergeLen1]
    rfl
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := PRE_fd_vw_r0.fresh1
    simp only [Bool.and_eq_true] at h
    exact h.1)

end Host.Ts.Sim.Compose.FDVW
