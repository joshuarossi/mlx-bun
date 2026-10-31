import host.sim.full.SizeSim
import host.sim.full.Raise
import host.sim.dispatch.OkJs
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim

/-! # B-size at a raise and under the JS-pointer law

A chain's `mlx_array_size` calls over symbolic shapes are bridges (`gen.ts`, seg.json kind `size`): the
three-step block `Disp.sizeS` is proved by `fullBridgeSize`, not by the chunk acceptance. That lemma is
stated at `FullR P NB`; the band-free chains carry `FullRD P NB` (`okJSK` at `fullJSPXD`) or
`Disp.FRJ (FullRD P NB)` (`okJSJ`). Here the native side is lifted to `FullRD` (`fullSizeCallSimD`) and
the bridge to both relations (`fullBridgeSizeD`, `fullBridgeSizeJD`): the raise is kept, and the law
`BigJs` survives the block because its map only extends (`Grow.ext`, `BigJs.ext`). -/

theorem sizeR_mono {F : Ffi} {FR FR' : Map → Nat → F.S → F.S → Prop} {M : Map} {n : Nat} {A : Nat → Prop}
    (hm : ∀ x y, FR M n x y → FR' M n x y) :
    ∀ {r r' : Option (F.S × Ret × List (Nat × Nat × List Byte))}, Disp.SizeR FR M n A r r' → Disp.SizeR FR' M n A r r'
  | none, _, _ => trivial
  | some _, some _, ⟨h, rest⟩ => ⟨hm _ _ h, rest⟩
  | some _, none, h => h

/-- **B-size's native side at a raise.** -/
theorem fullSizeCallSimD (P : LoadP) (NB : Nat) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (A : Nat → Prop) :
    Disp.SizeCallSim FF (FullRD P NB) name A SizePre := by
  intro M ν S C x y as hsrv hr hsupp hpre
  obtain ⟨P', hP, hr⟩ := hr
  refine MSim.mono (fullSizeCallSim P' NB hsym hm hp A M ν S C x y as hsrv hr hsupp hpre) ?_
  intro M' S' C' r r' h
  exact ⟨h.1, sizeR_mono (fun _ _ hx => ⟨P', hP, hx⟩) h.2⟩

section
variable {P : LoadP} {NB : Nat} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St FF.S} {S : SSrv} {C : CSrv} {fsym ta nf : Nat} {name rt : Name} {tys args : List Val}

/-- **B-size at a raise** (`fullBridgeSize` at `FullRD P NB`). -/
theorem fullBridgeSizeD (h : RelB FF (FullRD P NB) W stk M ν K s S t C)
    (hp : Disp.sizeParts s = some (fsym, ta, nf, name, rt, tys, args)) (hargs : Disp.sizeArgsOk s = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false) (hfr : K.fr ta = none)
    (hpre : ∀ asR S1, interpS (decodeArgs FF s tys args).run S = some (some asR, S1) → SizePre ν S1 s.ffi asR) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧
      RelB FF (FullRD P NB) W stk M' ν ⟨K.fr, s1.trace, t1.trace, K.D, K.lo, K.hi⟩ s1 S' t1 C' ∧
      ∃ asR ret asR' ret' v, s1.trace = ⟨name, asR, ret⟩ :: s.trace ∧ t1.trace = ⟨name, asR', ret'⟩ :: t.trace ∧
        Disp.numRet ret = some v ∧ Disp.numRet ret' = some (M'.val v)) S C
      (Disp.sizeS FF s) (Disp.sizeS FF t) :=
  Disp.bridge_size_at h (fullRD_laws P NB) (fullFfiSimD P NB) hp hargs hfr hpre
    (fullSizeCallSimD P NB hsym hm hpay (Present s))

/-- **B-size under the JS-pointer law at a raise** (the band-free `okJSJ` chains' relation). -/
theorem fullBridgeSizeJD (h : RelB FF (Disp.FRJ (FullRD P NB)) W stk M ν K s S t C)
    (hp : Disp.sizeParts s = some (fsym, ta, nf, name, rt, tys, args)) (hargs : Disp.sizeArgsOk s = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false) (hfr : K.fr ta = none)
    (hpre : ∀ asR S1, interpS (decodeArgs FF s tys args).run S = some (some asR, S1) → SizePre ν S1 s.ffi asR) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧
      RelB FF (Disp.FRJ (FullRD P NB)) W stk M' ν ⟨K.fr, s1.trace, t1.trace, K.D, K.lo, K.hi⟩ s1 S' t1 C' ∧
      ∃ asR ret asR' ret' v, s1.trace = ⟨name, asR, ret⟩ :: s.trace ∧ t1.trace = ⟨name, asR', ret'⟩ :: t.trace ∧
        Disp.numRet ret = some v ∧ Disp.numRet ret' = some (M'.val v)) S C
      (Disp.sizeS FF s) (Disp.sizeS FF t) := by
  refine MSim.mono (fullBridgeSizeD h.ofJ hp hargs hsym hm hpay hfr hpre) ?_
  intro M' S' C' s1 t1 hx
  exact ⟨hx.1, hx.2.1.toJ (h.ffi.2.ext hx.1.ext), hx.2.2⟩

end

end Host.Ts.Sim.Full
