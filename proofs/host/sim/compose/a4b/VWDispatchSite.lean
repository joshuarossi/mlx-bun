import host.sim.compose.a4b.VWDispatchTpl

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

noncomputable def dispatchSite (NB T : Nat) (tk : Nat → Nat) (bs : List Byte) (n : Nat) :
    PrefillSite (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (Disp.KpJ (VWFrames.typedJ bs n) 4096) (VWFrames.typedW bs n) (dispatchOk bs n)
      PRE_first_tail_x15_r0.s38 PRE_first_tail_x15_r0.s39 PRE_first_tail_x15_r0.S38 PRE_first_tail_x15_r0.ws2 where
  tpl := dispatchTpl bs n
  wr := PRE_first_tail_x15_r0.st2.wr
  start := PRE_first_tail_x15_r0.iso2
  tab := PRE_first_tail_x15_r0.tab0_2
  sim := dispatchSim NB T tk bs n
  localOk := okLocal_localB
  foot := PRE_first_tail_x15_r0.stFoot2
  nodup := PRE_first_tail_x15_r0.wrNodup2
  bound := PRE_first_tail_x15_r0.wrBound2
  trace := PRE_first_tail_x15_r0.trace2
  merged := PRE_first_tail_x15_r0.merged2
  len := by
    change PRE_first_tail_x15_r0.ws2.length = PRE_first_tail_x15_r0.st2.S2.tab.length - PRE_first_tail_x15_r0.S38.tab.length
    rw [← PRE_first_tail_x15_r0.tab0_2, PRE_first_tail_x15_r0.mergeLen2]
    rfl
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := PRE_first_tail_x15_r0.fresh2
    simp only [Bool.and_eq_true] at h
    exact h.1)

end Host.Ts.Sim.Compose.VWFirst
