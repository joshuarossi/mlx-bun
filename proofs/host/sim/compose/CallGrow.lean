import host.sim.compose.CallLink
import host.sim.full.TargetGrowD
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Load.Layers Host.Ts.Sim.Template

/-! # The target's growth along a decode chain's runs

* `decSimQ`: the pinned decode world's simulation carrying the target's growth (A1's `Full.fullStepSimXLBKFbQ`) at a
  decode chain's acceptance (`decOk`), the premise of A1's `Full.glue_ngrow`, `Full.glueCall_ngrow` (the glue pieces'
  growth).
* `call_ngrow`: `callLink`'s `hgrow`, the growth along a site instance's run, by the site instance's run and merge
  (`Conv.site_merge`) under that simulation at the instance's acceptance. -/

section
variable (b0 : BSt) (NB : Nat) (Pw : LoadP) (fr : List Nat) (wd : List (Nat × WFrame)) (W : Nat → Option WFrame)

/-- **The decode chains' simulation carrying the target's growth** (`decSimAt`'s, with the growth). -/
theorem decSimQ (hW : Disp.Wp (decJ Pw fr wd) W) (r : List NumV) (stk : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (FLRb b0 Pw NB r) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) (decOk Pw fr wd)
      (Disp.Kp (decJ Pw fr wd)) W stk (VBOkF loopVB) :=
  fullStepSimXLBKFbQ { Pw with rest := r } NB loopVB (decJ Pw fr wd) (okCallFS_rest Pw r).symm rfl rfl rfl rfl b0 stk hW y0

end

variable {b0 : BSt} {NB : Nat} {Pw : LoadP} {fr : List Nat} {wd : List (Nat × WFrame)} {W : Nat → Option WFrame}

/-- **The target's mlx state grows along a site instance's run** (see the module doc). -/
theorem call_ngrow (hW : Disp.Wp (decJ Pw fr wd) W) (I : Stage.StageTpl FF (okLocal (decOk Pw fr wd)))
    {sa : St FF.S} {wr : List Nat} (hs0 : I.s0 = { sa with stack := [] }) (hfoot : Conv.StageFoot wr I.s0 I.s2)
    (hnd : wr.Nodup) (hbd : ∀ b ∈ wr, b / 4096 < 4 ^ 31) (htr : ∃ fr, I.s2.trace = fr ++ I.s0.trace) :
    ∀ (r : List NumV) (c : SegInst FF) (t' : St FF.S) (C' : CSrv), VBOkF loopVB c.ν →
      Disp.Kp (decJ Pw fr wd) c.K → RelB FF (FLRb b0 Pw NB r) W [] c.M c.ν c.K sa I.S0 c.t c.C →
      runC FF (I.n + 1) c.t c.C = some (t', C') → Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t'.ffi) := by
  intro r c t' C' hν hK hr ht
  have hsim : ∀ stk, Disp.StepSimXLB FF (FRQ (FLRb b0 Pw NB r) fun y => Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf y))
      (okLocal (decOk Pw fr wd)) (Disp.Kp (decJ Pw fr wd)) W stk (VBOkF loopVB) := fun stk =>
    (decSimQ b0 NB Pw fr wd W hW r stk (mlxOf c.t.ffi)).mono fun s S h => by
      simp only [okLocal, Bool.and_eq_true] at h; exact h.1
  obtain ⟨M', t1, C1, hrun, -, h2⟩ := Conv.site_merge I hs0 rfl hsim okLocal_localB hK hν hfoot hnd hbd htr 0
    (relB_withQ hr (Host.Mlx.Ffi.NGrow.refl _))
  rw [ht] at hrun
  cases hrun
  exact h2.ffi.2

end Host.Ts.Sim.Compose
