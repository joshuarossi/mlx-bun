import host.sim.compose.a4b.D1DispatchTpl

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

noncomputable def dispatchSite (NB T : Nat) (tk : Nat → Nat) (bs : List Byte) :
    PrefillSite (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (Disp.KpJ (D1Frames.typedJ bs) 4096) (D1Frames.typedW bs) (dispatchOk bs)
      D1StageSplit.s20 D1StageSplit.s21 D1StageSplit.S20 D1StageSplit.ws1 where
  tpl := dispatchTpl bs
  wr := D1StageSplit.st1.wr
  start := D1StageSplit.iso1
  tab := D1StageSplit.tab0_1
  sim := dispatchSim NB T tk bs
  localOk := okLocal_localB
  foot := D1StageSplit.stFoot1
  nodup := D1StageSplit.wrNodup1
  bound := D1StageSplit.wrBound1
  trace := D1StageSplit.trace1
  merged := D1StageSplit.merged1
  len := by
    change D1StageSplit.ws1.length = D1StageSplit.st1.S2.tab.length - D1StageSplit.S20.tab.length
    rw [← D1StageSplit.tab0_1, D1StageSplit.mergeLen1]
    rfl
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := D1StageSplit.fresh1
    simp only [Bool.and_eq_true] at h
    exact h.1)

end Host.Ts.Sim.Compose.D1Split
