import host.sim.compose.PreCall
import host.sim.full.TargetGrowD
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template

theorem PrefillSite.ngrow {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop}
    {W : Nat → Option WFrame} {ok : St FF.S → SSrv → Bool}
    {sa sm : St FF.S} {Sa : SSrv} {ws : List Nat}
    (d : PrefillSite FR Kp W ok sa sm Sa ws)
    (hsim : ∀ stk y0, Disp.StepSimXLB FF (FRQ FR fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))
      ok Kp W stk (VBOkF loopVB))
    {M : Map} {ν : Nat → F64} {K : Ctx} {t t' : St FF.S} {C C' : CSrv}
    (hν : VBOkF loopVB ν) (hK : Kp K)
    (hr : RelB FF FR W [] M ν K sa d.tpl.S0 t C)
    (ht : runC FF (d.tpl.n + 1) t C = some (t', C')) :
    Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t'.ffi) := by
  obtain ⟨M', t1, C1, hrun, -, h2⟩ := Conv.site_merge d.tpl d.start rfl
    (fun stk => hsim stk (mlxOf t.ffi)) d.localOk hK hν d.foot d.nodup d.bound d.trace 0
    (relB_withQ hr (Host.Mlx.Ffi.NGrow.refl _))
  rw [ht] at hrun
  cases hrun
  exact h2.ffi.2

end Host.Ts.Sim.Compose
