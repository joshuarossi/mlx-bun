import host.sim.compose.a4b.VWFrames
import host.sim.full.BridgeJs
import host.sim.compose.a4b.SetupEarlyGlue
import host.sim.conv.CallPieces
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose.SetupEarly

theorem typedSimAt (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n D0 : Nat) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (Disp.okJSJ (VWFrames.typedJ bytes n) (okBackFXS setupP) D0)
      (Disp.KpJ (VWFrames.typedJ bytes n) D0) (VWFrames.typedW bytes n) stk (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (VWFrames.typedJ bytes n).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJS P NB loopVB (VWFrames.typedJ bytes n) D0 hj rfl rfl rfl rfl rfl stk
    (VWFrames.typed_wp bytes n)
  simpa only [P, backRest] using hs

theorem chunkSim (NB T : Nat) (tk : Nat → Nat) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (Disp.okJSJ VWFrames.chunkJ (okBackFXS setupP) 4096)
      (Disp.KpJ VWFrames.chunkJ 4096) wideP stk (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : VWFrames.chunkJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJS P NB loopVB VWFrames.chunkJ 4096 hj rfl rfl rfl rfl rfl stk VWFrames.chunk_wp
  simpa only [P, backRest] using hs

theorem chunkGrowSim (NB T : Nat) (tk : Nat → Nat) (stk : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (Disp.okJSJ VWFrames.chunkJ (okBackFXS setupP) 4096)
      (Disp.KpJ VWFrames.chunkJ 4096) wideP stk (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : VWFrames.chunkJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJSQ P NB loopVB VWFrames.chunkJ 4096 hj rfl rfl rfl rfl rfl stk VWFrames.chunk_wp y0
  have he : Disp.FRJ (FRQ (FullRXD P NB) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))) =
      FRQ (Disp.FRJ (FullRXD P NB)) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) := by
    funext M m x y
    exact propext ⟨fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩, fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩⟩
  rw [he] at hs
  simpa only [P, backRest] using hs

theorem typedSim (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n : Nat) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedOk bytes n) (Disp.KpJ (VWFrames.typedJ bytes n) 4096)
      (VWFrames.typedW bytes n) stk (VBOkF loopVB) := typedSimAt NB T tk bytes n 4096 stk

theorem bodySim (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n : Nat) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.bodyOk bytes n) (Disp.KpJ (VWFrames.typedJ bytes n) VWFrames.bodyD0)
      (VWFrames.typedW bytes n) stk (VBOkF loopVB) := typedSimAt NB T tk bytes n VWFrames.bodyD0 stk

theorem bodyLocalSim (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n : Nat) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (okLocal (VWFrames.bodyOk bytes n)) (Disp.KpJ (VWFrames.typedJ bytes n) VWFrames.bodyD0)
      (VWFrames.typedW bytes n) stk (VBOkF loopVB) := by
  apply (bodySim NB T tk bytes n stk).mono
  intro s S h
  simp only [okLocal, Bool.and_eq_true] at h
  exact h.1

theorem typedGrowSimAt (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n D0 : Nat)
    (stk : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (Disp.okJSJ (VWFrames.typedJ bytes n) (okBackFXS setupP) D0)
      (Disp.KpJ (VWFrames.typedJ bytes n) D0) (VWFrames.typedW bytes n) stk (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (VWFrames.typedJ bytes n).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJSQ P NB loopVB (VWFrames.typedJ bytes n) D0 hj rfl rfl rfl rfl rfl stk
    (VWFrames.typed_wp bytes n) y0
  have he : Disp.FRJ (FRQ (FullRXD P NB) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))) =
      FRQ (Disp.FRJ (FullRXD P NB)) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) := by
    funext M m x y
    exact propext ⟨fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩, fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩⟩
  rw [he] at hs
  simpa only [P, backRest] using hs
end Host.Ts.Sim.Compose.VWFirst
