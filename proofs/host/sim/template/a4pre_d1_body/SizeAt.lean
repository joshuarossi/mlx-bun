import host.sim.template.a4pre_d1_body.SizeRun
import host.sim.template.a4pre_d1_body.SizeGrow
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodySize
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Disp Host.Ts.Sim.BufSim

def Post {F : Ffi} (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame)
    (stk : List Frame) (M : Map) (ν : Nat → F64) (K : Host.Ts.Sim.Ctx)
    (S : SSrv) (C : CSrv) (s t : St F.S) (name : Name) :
    Map → SSrv → CSrv → St F.S → St F.S → Prop :=
  fun M' S' C' s1 t1 => (Grow M ν S C M' S' C' ∧
    RelB F FR W stk M' ν ⟨K.fr, s1.trace, t1.trace, K.D, K.lo, K.hi⟩ s1 S' t1 C' ∧
    ∃ asR ret asR' ret' v, s1.trace = ⟨name, asR, ret⟩ :: s.trace ∧ t1.trace = ⟨name, asR', ret'⟩ :: t.trace ∧
      numRet ret = some v ∧ numRet ret' = some (M'.val v)) ∧ runC F 3 t C = some (t1, C')

theorem atCall {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
    {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Host.Ts.Sim.Ctx}
    {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool}
    {okBack : F.S → Arg → Bool} {fsym ta nf : Nat} {name rt : Name} {tys args : List Val}
    {Pred : (Nat → F64) → SSrv → F.S → List Arg → Prop}
    (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) (hF : FfiSim F FR okCall okBack)
    (hL : FfiLawful F)
    (hp : sizeParts s = some (fsym, ta, nf, name, rt, tys, args)) (hargs : sizeArgsOk s = true)
    (hfr : K.fr ta = none)
    (hpre : ∀ asR S1, interpS (decodeArgs F s tys args).run S = some (some asR, S1) → Pred ν S1 s.ffi asR)
    (hcall : SizeCallSim F FR name (Present s) Pred) :
    MSim (Post FR W stk M ν K S C s t name) S C (sizeS F s) (sizeS F t) := by
  obtain ⟨this, thisN, env, fs, fo, no, oa, ndata, hc, hfo, hk, hta, htk, hst, hno, hnk⟩ := sizeParts_spec hp
  obtain ⟨hbuf, hbool⟩ := sizeArgs_spec (K := K) (W := W) (n := S.tab.length) hp hargs
  exact bridgeRun h hFR hF hL hc hfo hk hta htk hfr hst hno hnk hbuf hbool hpre hcall

theorem growAt {P : LoadP} {NB : Nat} {W : Nat → Option WFrame} {stk : List Frame}
    {M : Map} {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {s t : St FF.S} {S : SSrv} {C : CSrv}
    {fsym ta nf : Nat} {name rt : Name} {tys args : List Val} (y0 : Host.Mlx.Ffi.St)
    (h : RelB FF (FRJ (FRQ (FullRXD P NB) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))))
      W stk M ν K s S t C)
    (hp : sizeParts s = some (fsym, ta, nf, name, rt, tys, args)) (hargs : sizeArgsOk s = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false) (hfr : K.fr ta = none)
    (hpre : ∀ asR S1, interpS (decodeArgs FF s tys args).run S = some (some asR, S1) → Pre ν S1 s.ffi asR) :
    MSim (Post (FRJ (FRQ (FullRXD P NB) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))))
      W stk M ν K S C s t name) S C (sizeS FF s) (sizeS FF t) := by
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  refine MSim.mono (atCall h.ofJ (fullRXD_laws P NB).liftQ
    ((fullFfiSimXD P NB).liftQ fullLawful hQ) fullLawful hp hargs hfr hpre
    (callGrow P NB y0 hsym hm hpay (Present s))) ?_
  rintro M' S' C' s1 t1 ⟨⟨hg, hr, hev⟩, hrun⟩
  exact ⟨⟨hg, hr.toJ (h.ffi.2.ext hg.ext), hev⟩, hrun⟩

end Host.Load.Run.Tpl.D1BodySize

-- rechecked: literal chunk length
