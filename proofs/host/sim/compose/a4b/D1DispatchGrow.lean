import host.sim.compose.a4b.D1DispatchSite
import host.sim.compose.PreGrow
import host.sim.full.TargetGrowD
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly

theorem dispatchGrowSim (NB T : Nat) (tk : Nat → Nat) (bs : List Byte)
    (stk : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (dispatchOk bs) (Disp.KpJ (D1Frames.typedJ bs) 4096)
      (D1Frames.typedW bs) stk (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (D1Frames.typedJ bs).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJSQ P NB loopVB (D1Frames.typedJ bs) 4096 hj rfl rfl rfl rfl rfl stk
    (D1Frames.typed_wp bs) y0
  have he : Disp.FRJ (FRQ (FullRXD P NB) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))) =
      FRQ (Disp.FRJ (FullRXD P NB)) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) := by
    funext M n x y
    exact propext ⟨fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩, fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩⟩
  rw [he] at hs
  have hsim : Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD P NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))) (D1Frames.typedOk bs)
      (Disp.KpJ (D1Frames.typedJ bs) 4096) (D1Frames.typedW bs) stk (VBOkF loopVB) := by
    simpa only [P, backRest, D1Frames.typedOk] using hs
  apply hsim.mono
  intro s S h
  change (D1Frames.typedOk bs s S && Disp.localB s) = true at h
  simp only [Bool.and_eq_true] at h
  exact h.1

end Host.Ts.Sim.Compose.D1Split
