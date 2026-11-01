import host.sim.compose.a4b.fd.Frames
import host.sim.full.BridgeJs
import host.sim.compose.a4b.SetupEarlyGlue
import host.sim.conv.CallPieces
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose.SetupEarly

theorem typedSimAt (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n D0 : Nat) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (Disp.okJSJ (FDFrames.typedJ bytes n) (okBackFXS setupP) D0)
      (Disp.KpJ (FDFrames.typedJ bytes n) D0) (FDFrames.typedW bytes n) stk (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (FDFrames.typedJ bytes n).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJS P NB loopVB (FDFrames.typedJ bytes n) D0 hj rfl rfl rfl rfl rfl stk
    (FDFrames.typed_wp bytes n)
  simpa only [P, backRest] using hs

theorem chunkSim (NB T : Nat) (tk : Nat → Nat) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (Disp.okJSJ FDFrames.chunkJ (okBackFXS setupP) 4096)
      (Disp.KpJ FDFrames.chunkJ 4096) wideP stk (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : FDFrames.chunkJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJS P NB loopVB FDFrames.chunkJ 4096 hj rfl rfl rfl rfl rfl stk FDFrames.chunk_wp
  simpa only [P, backRest] using hs

theorem chunkGrowSim (NB T : Nat) (tk : Nat → Nat) (stk : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (Disp.okJSJ FDFrames.chunkJ (okBackFXS setupP) 4096)
      (Disp.KpJ FDFrames.chunkJ 4096) wideP stk (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : FDFrames.chunkJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJSQ P NB loopVB FDFrames.chunkJ 4096 hj rfl rfl rfl rfl rfl stk FDFrames.chunk_wp y0
  have he : Disp.FRJ (FRQ (FullRXD P NB) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))) =
      FRQ (Disp.FRJ (FullRXD P NB)) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) := by
    funext M m x y
    exact propext ⟨fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩, fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩⟩
  rw [he] at hs
  simpa only [P, backRest] using hs

theorem typedSim (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n : Nat) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (FDFrames.typedOk bytes n) (Disp.KpJ (FDFrames.typedJ bytes n) 4096)
      (FDFrames.typedW bytes n) stk (VBOkF loopVB) := typedSimAt NB T tk bytes n 4096 stk

theorem bodySim (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n : Nat) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (FDFrames.bodyOk bytes n) (Disp.KpJ (FDFrames.typedJ bytes n) FDFrames.bodyD0)
      (FDFrames.typedW bytes n) stk (VBOkF loopVB) := typedSimAt NB T tk bytes n FDFrames.bodyD0 stk

theorem bodyLocalSim (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n : Nat) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (okLocal (FDFrames.bodyOk bytes n)) (Disp.KpJ (FDFrames.typedJ bytes n) FDFrames.bodyD0)
      (FDFrames.typedW bytes n) stk (VBOkF loopVB) := by
  apply (bodySim NB T tk bytes n stk).mono
  intro s S h
  simp only [okLocal, Bool.and_eq_true] at h
  exact h.1

theorem typedGrowSimAt (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n D0 : Nat)
    (stk : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (Disp.okJSJ (FDFrames.typedJ bytes n) (okBackFXS setupP) D0)
      (Disp.KpJ (FDFrames.typedJ bytes n) D0) (FDFrames.typedW bytes n) stk (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (FDFrames.typedJ bytes n).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJSQ P NB loopVB (FDFrames.typedJ bytes n) D0 hj rfl rfl rfl rfl rfl stk
    (FDFrames.typed_wp bytes n) y0
  have he : Disp.FRJ (FRQ (FullRXD P NB) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))) =
      FRQ (Disp.FRJ (FullRXD P NB)) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) := by
    funext M m x y
    exact propext ⟨fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩, fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩⟩
  rw [he] at hs
  simpa only [P, backRest] using hs
end Host.Ts.Sim.Compose.FDVW
