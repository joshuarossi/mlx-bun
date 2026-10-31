import host.sim.compose.a4b.PrefillD1First
import host.sim.template.a4pre_d1_dispatch.Simulation
import host.sim.template.BootEq

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly

noncomputable def dispatchOk (bs : List Byte) : St FF.S → SSrv → Bool :=
  Template.okLocal (D1Frames.typedOk bs)

kernel_rfl dispatchOk0 :
  (fun bs : List Byte => dispatchOk bs D1StageSplit.st1.s0 D1StageSplit.st1.S0) = fun _ => true
kernel_rfl dispatchOk1 :
  (fun bs : List Byte => dispatchOk bs D1StageSplit.st1.s1 D1StageSplit.st1.S1) = fun _ => true

boot_rfl dispatchRun from D1StageSplit.st1.s0 to D1StageSplit.st1.s1 :
  (fun bs : List Byte => runOk FF (dispatchOk bs) 154 D1StageSplit.st1.s0 D1StageSplit.st1.S0) =
    fun _ => some (D1StageSplit.st1.s1, D1StageSplit.st1.S1)

noncomputable def dispatchTpl (bs : List Byte) : Stage.StageTpl FF (dispatchOk bs) where
  s0 := D1StageSplit.st1.s0
  S0 := D1StageSplit.st1.S0
  s1 := D1StageSplit.st1.s1
  S1 := D1StageSplit.st1.S1
  s2 := D1StageSplit.st1.s2
  S2 := D1StageSplit.st1.S2
  n := 154
  ok0 := congrFun dispatchOk0 bs
  run := congrFun dispatchRun bs
  ok1 := congrFun dispatchOk1 bs
  halt := D1StageSplit.st1.halt1
  last := D1StageSplit.st1.last
  top := D1StageSplit.st1.tpl.top

theorem dispatchSim (NB T : Nat) (tk : Nat → Nat) (bs : List Byte) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (dispatchOk bs) (Disp.KpJ (D1Frames.typedJ bs) 4096) (D1Frames.typedW bs) stk (VBOkF loopVB) := by
  have hj : ∀ r, Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (D1Frames.typedOk bs) (Disp.KpJ (D1Frames.typedJ bs) 4096) (D1Frames.typedW bs) r (VBOkF loopVB) := by
    intro r
    let P : LoadP := { setupP with rest := machReads T tk }
    have hc : (D1Frames.typedJ bs).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
    have h := fullStepSimXLBXDJS P NB loopVB (D1Frames.typedJ bs) 4096 hc rfl rfl rfl rfl rfl r
      (D1Frames.typed_wp bs)
    simpa only [P, D1Frames.typedOk, D1Frames.typedJ, backRest] using h
  apply (hj stk).mono
  intro s S h
  change (D1Frames.typedOk bs s S && Disp.localB s) = true at h
  simp only [Bool.and_eq_true] at h
  exact h.1

end Host.Ts.Sim.Compose.D1Split
