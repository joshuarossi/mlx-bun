import host.sim.compose.PreCall
import host.sim.conv.RunAccept
import host.sim.dispatch.OkJsImage
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template

theorem imageLocal_of_old {F : Ffi} {J : Disp.JSP F} {D : Nat}
    {okBack : F.S → Arg → Bool} {s : St F.S} {S : SSrv}
    (h : okLocal (Disp.okJSJ J okBack D) s S = true) :
    okLocal (Disp.okJSJImage J D okBack) s S = true := by
  simp only [okLocal, Bool.and_eq_true] at h ⊢
  exact ⟨Disp.okJSJImage_of_old h.1, h.2⟩

/-- Keep the checked template and its length while strengthening the JS simulation. -/
def imageLocalTpl {F : Ffi} {J : Disp.JSP F} {D : Nat} {okBack : F.S → Arg → Bool}
    (T : Stage.StageTpl F (okLocal (Disp.okJSJ J okBack D))) :
    Stage.StageTpl F (okLocal (Disp.okJSJImage J D okBack)) :=
  T.mapOk fun _ _ => imageLocal_of_old

def PrefillSite.withJsImage
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    {J : Disp.JSP FF} {D : Nat} {okBack : FF.S → Arg → Bool}
    {sa sm : St FF.S} {Sa : SSrv} {ws : List Nat}
    (d : PrefillSite FR Kp W (okLocal (Disp.okJSJ J okBack D)) sa sm Sa ws)
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (okLocal (Disp.okJSJImage J D okBack))
      Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (okLocal (Disp.okJSJImage J D okBack)) sa sm Sa ws where
  tpl := imageLocalTpl d.tpl
  wr := d.wr
  start := d.start
  tab := d.tab
  sim := hsim
  localOk := by
    intro s S h
    simp only [okLocal, Bool.and_eq_true] at h
    exact h.2
  foot := d.foot
  nodup := d.nodup
  bound := d.bound
  trace := d.trace
  merged := d.merged
  len := d.len
  freshNodup := d.freshNodup
  fresh := d.fresh

end Host.Ts.Sim.Compose
