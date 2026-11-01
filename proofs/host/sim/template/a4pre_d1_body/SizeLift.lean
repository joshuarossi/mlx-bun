import host.sim.full.SizeJs
import host.sim.full.BridgeStepD
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodySize
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full

def Pre (ν : Nat → F64) (S : SSrv) (x : FF.S) (args : List Arg) : Prop :=
  SizePre ν S x args ∧ (bridgeOf x).active = false

theorem callSim (P : LoadP) (NB : Nat) {name : Name}
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize)
    (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (A : Nat → Prop) :
    Disp.SizeCallSim FF (FullRXD P NB) name A Pre := by
  intro M ν S C x y as hsrv hr hsupp hpre
  obtain ⟨hsize, hi⟩ := hpre
  obtain ⟨P', hP, hbase⟩ := hr
  have hd : FullRD P NB M S.tab.length x y := ⟨P', hP, hbase.toR hi⟩
  refine MSim.mono (fullSizeCallSimD P NB hsym hm hp A M ν S C x y as hsrv hd hsupp hsize) ?_
  intro M' S' C' r r' h
  exact ⟨h.1, sizeR_mono (fun _ _ q => q.toXD) h.2⟩

theorem bridge {P : LoadP} {NB : Nat} {W : Nat → Option WFrame} {stk : List Frame}
    {M : Map} {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {s t : St FF.S} {S : SSrv} {C : CSrv}
    {fsym ta nf : Nat} {name rt : Name} {tys args : List Val}
    (h : RelB FF (Disp.FRJ (FullRXD P NB)) W stk M ν K s S t C)
    (hp : Disp.sizeParts s = some (fsym, ta, nf, name, rt, tys, args))
    (hargs : Disp.sizeArgsOk s = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false) (hfr : K.fr ta = none)
    (hpre : ∀ asR S1, interpS (decodeArgs FF s tys args).run S = some (some asR, S1) → Pre ν S1 s.ffi asR) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧
      RelB FF (Disp.FRJ (FullRXD P NB)) W stk M' ν
        ⟨K.fr, s1.trace, t1.trace, K.D, K.lo, K.hi⟩ s1 S' t1 C' ∧
      ∃ asR ret asR' ret' v, s1.trace = ⟨name, asR, ret⟩ :: s.trace ∧ t1.trace = ⟨name, asR', ret'⟩ :: t.trace ∧
        Disp.numRet ret = some v ∧ Disp.numRet ret' = some (M'.val v)) S C
      (Disp.sizeS FF s) (Disp.sizeS FF t) := by
  refine MSim.mono (Disp.bridge_size_at h.ofJ (fullRXD_laws P NB) (fullFfiSimXD P NB)
    hp hargs hfr hpre (callSim P NB hsym hm hpay (Present s))) ?_
  intro M' S' C' s1 t1 hx
  exact ⟨hx.1, hx.2.1.toJ (h.ffi.2.ext hx.1.ext), hx.2.2⟩

end Host.Load.Run.Tpl.D1BodySize
