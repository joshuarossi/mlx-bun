import host.sim.full.BridgeFrameSym
import host.sim.full.StepX

/-! # The full world's native calls with the target's bridge framed

`fullCallSimF`: the decode acceptance's calls (`okCallFS`) simulate at `FullRF`. With the target's
bridge inactive the target's call is the call of the target with the template's bridge, the bridge
carried along (`full_call_swapI`), so `fullCallSimS` applies. With it active and quiet, the load world's
simulations apply and the bridge's update is the identity (`fullCallOfF`; the symbolic-shape layer's
calls by `fullCallSymF`). The one-step theorems follow (`fullStepSim*F`). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.FullKeep (Keep AllX)

/-- The full world's state with its bridge replaced. -/
def setBridgeF (p : FF.S) (b : BSt) : FF.S := ((⟨p.1.1.base, b⟩, p.1.2), p.2)

/-- A full-world result with its bridge replaced. -/
def resB (b : BSt) (o : Res FF.S) : Res FF.S := o.map fun q => (setBridgeF q.1 b, q.2)

/-- **With both bridges inactive, the call is the call with the other bridge, carried along.** -/
theorem full_call_swapI (y : FF.S) (b0 : BSt) {name : Name} {args : List Arg} (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (hb : (bridgeOf y).active = false)
    (hb0 : b0.active = false) :
    FF.call y name args =
      Host.Ts.M.bind (FF.call (setBridgeF y b0) name args) fun o => Host.Ts.M.pure (resB (bridgeOf y) o) := by
  rw [full_call_sym y name args hm hp hb, full_call_sym (setBridgeF y b0) name args hm hp hb0, G.mbind_assoc]
  refine congrArg (Host.Ts.M.bind _) (funext fun o => ?_)
  rcases o with _ | ⟨l, r, ws⟩ <;> rfl

theorem FullRF.swap {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (h : FullRF P NB M n x y) :
    FullR P NB M n x (setBridgeF y (bridgeOf x)) :=
  ⟨h.load, ⟨rfl, h.bridge.1⟩, h.live, h.kern, h.pend⟩

/-- **With the target's bridge inactive**, the call simulation through the template's bridge. -/
theorem fullCallSimF_inactive {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hr : FullRF P NB M S.tab.length x y) (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (hia : (bridgeOf y).active = false)
    (h0 : MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullR P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call (setBridgeF y (bridgeOf x)) name (args.map M.arg))) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRFb (bridgeOf y) P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  rw [full_call_swapI y (bridgeOf x) hm hp hia hr.bridge.1]
  show MSim _ S C (Host.Ts.M.bind (FF.call x name args) Host.Ts.M.pure) _
  refine MSim.bind h0 fun M' S' C' a o hab => MSim.pure ⟨hab.1, ?_⟩
  obtain ⟨-, hc⟩ := hab
  rcases a with _ | ⟨x', r1, ws⟩ <;> rcases o with _ | ⟨y', r2, ws'⟩
  · trivial
  · trivial
  · exact hc
  · exact ⟨⟨hc.1.load, ⟨⟨hc.1.bridge.2, .inl hia⟩, rfl⟩, hc.1.live, hc.1.kern, hc.1.pend⟩, hc.2⟩

/-- **The layers after a load-world call simulation with the target's bridge active and quiet**: the
bridge's update is the identity, the bridge stays quiet. -/
theorem fullCallOfF {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hr : FullRF P NB M S.tab.length x y)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hact : (bridgeOf x).active = false) (hact' : (bridgeOf y).active = true)
    (hq : Quiet M (mlxOf x) (mlxOf y) (bridgeOf y)) (hobs : obsOk (mlxOf x) name args = true)
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) (hka : KernAcc P (mlxOf x) name args)
    (haa : Host.Mlx.Ffi.symOf name = some .arrayFree → ∀ a, args = [a] → hdOk (mlxOf x) a = true)
    (hsm : isSymShape name = true → ∀ a S', interpS (Host.Load.call (toLoad x) name args).run S = some (a, S') →
      a.isSome = true)
    (hg : MSim (G.LPost P NB M ν S C) S C (Host.Load.call (toLoad x) name args)
      (Host.Load.call (toLoad y) name (args.map M.arg))) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRFb (bridgeOf y) P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  rw [full_call_mlx x name args hm hp hact, full_call_active y name _ hm hp hact']
  have hg2 := MSim.both hg (loadFfiLawful.call _ _ _) (loadFfiLawful.call _ _ _)
  refine MSim.bind hg2 fun M' S' C' a o hab => ?_
  obtain ⟨⟨hgr, hcr⟩, hra, hrb⟩ := hab
  rcases a with _ | ⟨l, r, ws⟩
  · cases hss : isSymShape name
    · rw [fullCont_none _ _ _ hss, fullContA_stuck y _ _ hss]
      exact MSim.pure ⟨hgr, trivial⟩
    · have := hsm hss none S' hra
      cases this
  · rcases o with _ | ⟨l', r', ws'⟩
    · exact hcr.elim
    · have kx := keep_of_run hm hra
      have ky := keep_of_runC hm hrb
      have haf := after_quiet hr.load.mlx hcr.1.mlx hgr.ext.node kx hq name (args.map M.arg)
      rw [fullCont_some, fullContA_some y name _ haf]
      have hb : (toLoad x).mlx.next < 2 ^ 64 := by
        have := hr.load.mlx.hnext; have := hr.load.mlx.hroom; omega
      obtain ⟨hnew, hnewK⟩ := call_newFacts hm hb hra
      exact full_some_postX hr hgr hcr kx ky hobs hsupp hka haa hnew hnewK
        (fun _ _ _ _ => ⟨⟨hr.bridge.1, .inr (hq.step hr.load.mlx hgr.ext.node ky)⟩, rfl⟩)

/-- **The decode acceptance's calls with the target's bridge framed**, the target's bridge kept. -/
theorem fullCallSimF_core {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hsrv : Srv M ν S C) (hr : FullRF P NB M S.tab.length x y)
    (hok : okCallFS P x name args = true) (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a)
    (hsm : smallFS ν S x name args) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRFb (bridgeOf y) P NB) M' S'.tab.length r r')
      S C (FF.call x name args) (FF.call y name (args.map M.arg)) := by
    have hok0 := hok
    unfold okCallFS at hok0
    simp only [Bool.and_eq_true, Bool.not_eq_true'] at hok0
    obtain ⟨⟨⟨⟨hm, hp⟩, hact⟩, -⟩, -⟩ := hok0
    cases hia : (bridgeOf y).active
    · exact fullCallSimF_inactive hr hm hp hia
        ((fullCallSimS P NB).call M ν S C x _ name args hsrv hr.swap hok hsupp hsm)
    · have hq : Quiet M (mlxOf x) (mlxOf y) (bridgeOf y) := by
        rcases hr.bridge.2 with h | h
        · rw [hia] at h; cases h
        · exact h
      cases hpath : G.symPath (mlxOf x) name args
      · unfold okCallFS at hok
        rw [hpath, Bool.cond_false] at hok
        simp only [Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at hok
        obtain ⟨⟨-, hsx | hvs⟩, hobs⟩ := hok
        · have hsm' := hsm.2 hpath
          exact fullCallOfF hr hm hp hact hia hq hobs hsupp (kernAccX_of hsx) (arrAccX_of hsx) hsm'.2
            ((G.loadFfiCallSimX P NB).call M ν S C (toLoad x) (toLoad y) name args hsrv hr.load hsx hsupp hsm'.1)
        · unfold cloOk at hvs
          split at hvs
          · rename_i sy hsym
            have hg := G.mlx_lift hr.load hm (G.sim_clo hsrv hr.load.mlx hsym hvs hsupp hr.pend)
            have hkl := G.NativeOkX.clo_kern hvs
            obtain ⟨n1, n2, n3, n4, -, n6, n7, n8⟩ := G.NativeOkX.clo_not hvs
            have hss : isSymShape name = false := by
              unfold isSymShape; rw [hsym]; cases sy <;> first | rfl | contradiction
            refine fullCallOfF hr hm hp hact hia hq hobs hsupp ?_ ?_ (fun h => by rw [hss] at h; cases h) hg
            · intro s hs; rw [hsym] at hs; cases hs
              exact ⟨hkl, fun h => by rcases h with rfl | rfl | rfl <;> contradiction⟩
            · intro hs; rw [hsym] at hs; cases hs; exact absurd rfl n4
          · cases hvs
      · unfold okCallFS at hok
        rw [hpath] at hok
        simp only [Bool.cond_true, Bool.and_eq_true, Bool.not_eq_true'] at hok
        obtain ⟨⟨-, hsk⟩, hobs⟩ := hok
        exact fullCallSymF hsrv hr hm hp hact hia hq hsk hobs hsupp (hsm.1 hpath)

theorem callR_bridge {BR BR' : Map → FF.S → FF.S → Prop} {P : LoadP} {NB : Nat} (h : ∀ M x y, BR M x y → BR' M x y)
    {M : Map} {n : Nat} {r r' : Option (FF.S × Ret × List (Nat × Nat × List Byte))}
    (hc : CallR (F := FF) (FullRB BR P NB) M n r r') : CallR (F := FF) (FullRB BR' P NB) M n r r' := by
  rcases r with _ | ⟨x', r1, ws⟩ <;> rcases r' with _ | ⟨y', r2, ws'⟩
  · trivial
  · trivial
  · exact hc
  · exact ⟨hc.1.mapBridge (h _ _ _), hc.2⟩

/-- **The full world's native-call simulation with the target's bridge framed**, at the decode
acceptance. -/
theorem fullCallSimF (P : LoadP) (NB : Nat) : FfiCallSim FF (FullRF P NB) (okCallFS P) smallFS where
  call M ν S C x y name args hsrv hr hok hsupp hsm :=
    MSim.mono (fullCallSimF_core hsrv hr hok hsupp hsm) fun _ _ _ _ _ h => ⟨h.1, callR_bridge (fun _ _ _ h => h.1) h.2⟩

/-- **The native-call simulation with the target's bridge pinned to `b0`**: the decode acceptance's calls
keep it. -/
theorem fullCallSimFb (b0 : BSt) (P : LoadP) (NB : Nat) : FfiCallSim FF (FullRFb b0 P NB) (okCallFS P) smallFS where
  call M ν S C x y name args hsrv hr hok hsupp hsm := by
    have h := fullCallSimF_core hsrv (hr.mapBridge And.left) hok hsupp hsm
    rw [show bridgeOf y = b0 from hr.bridge.2] at h
    exact h

theorem backSimNone {FR : Map → Nat → FF.S → FF.S → Prop} : FfiBackSim FF FR (fun _ _ => false) :=
  ⟨fun _ _ _ _ _ _ _ _ _ h => absurd h (by simp)⟩

theorem fullRF_laws (P : LoadP) (NB : Nat) : FRLaws (F := FF) (FullRF P NB) := fullR_laws bridgeF_names.stable P NB

/-! ## The one-step theorems -/

section
variable (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFS P)
  (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
  (hg : J.isRegion = fullIsRegion)
include hJ hsm hlo hh hg

/-- **The one-step theorem with the target's bridge framed**, under frames `W` and a stack base. -/
theorem fullStepSimXBF {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXVB FF (FullRF P NB) (Disp.okJS J) (Disp.Kp J) W stk (VBOkF VB) :=
  Disp.stepSimXVB (fullFfiSim P NB) (by rw [hJ]; exact fullCallSimF P NB)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullRF_laws P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- The one-step theorem with the target's bridge framed for any reached state, under frames and a stack base. -/
theorem fullStepSimXLBF {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (FullRF P NB) (Disp.okJS J) (Disp.Kp J) W stk (VBOkF VB) :=
  Disp.stepSimXLB (fullFfiSim P NB) (by rw [hJ]; exact fullCallSimF P NB)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullRF_laws P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- The one-step theorem with the target's bridge framed for any reached state. -/
theorem fullStepSimXLF : Disp.StepSimXL FF (FullRF P NB) (Disp.okJS J) (Disp.Kp J) (VBOkF VB) :=
  Disp.stepSimXL (fullFfiSim P NB) (by rw [hJ]; exact fullCallSimF P NB)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullRF_laws P NB) fullLawful (fullNativeFacts P NB J hlo hh hg)

/-- **The one-step theorem with the target's bridge framed, no continuation accepted** (`Disp.okJSK J
(fun _ _ => false)`), under frames and a stack base. -/
theorem fullStepSimXLBKF {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (FullRF P NB) (Disp.okJSK J (fun _ _ => false)) (Disp.Kp J) W stk (VBOkF VB) :=
  Disp.stepSimXLBK (fullFfiSim P NB) backSimNone (by rw [hJ]; exact fullCallSimF P NB)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullRF_laws P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- `fullStepSimXLBKF` with the target's growth from `y0`. -/
theorem fullStepSimXLBKFQ {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (FullRF P NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))
      (Disp.okJSK J (fun _ _ => false)) (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullRF P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimF P NB
  have hQ := fullTargetPres (FR := FullRF P NB) (fun _ _ _ _ hr h hh => (hr.load.mlx.yabsent h hh).2) y0
  exact Disp.stepSimXLBK ((fullFfiSim P NB).liftQ fullLawful hQ) backSimNone (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullRF_laws P NB).liftQ fullLawful (fullNativeFacts P NB J hlo hh hg).liftQ hW

/-- **The one-step theorem with the target's bridge pinned to `b0`**, no continuation accepted, under
frames and a stack base. -/
theorem fullStepSimXLBKFb (b0 : BSt) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (FullRFb b0 P NB) (Disp.okJSK J (fun _ _ => false)) (Disp.Kp J) W stk (VBOkF VB) :=
  Disp.stepSimXLBK (fullFfiSim P NB) backSimNone (by rw [hJ]; exact fullCallSimFb b0 P NB)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws (bridgeFb_names b0).stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- `fullStepSimXLBKFb` with the target's growth from `y0`. -/
theorem fullStepSimXLBKFbQ (b0 : BSt) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W)
    (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (FullRFb b0 P NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))
      (Disp.okJSK J (fun _ _ => false)) (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullRFb b0 P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimFb b0 P NB
  have hQ := fullTargetPres (FR := FullRFb b0 P NB) (fun _ _ _ _ hr h hh => (hr.load.mlx.yabsent h hh).2) y0
  exact Disp.stepSimXLBK ((fullFfiSim P NB).liftQ fullLawful hQ) backSimNone (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws (bridgeFb_names b0).stable P NB).liftQ fullLawful (fullNativeFacts P NB J hlo hh hg).liftQ hW

/-- The one-step theorem with the target's bridge pinned to `b0` for any reached state (`Disp.okJS`). -/
theorem fullStepSimXLFb (b0 : BSt) : Disp.StepSimXL FF (FullRFb b0 P NB) (Disp.okJS J) (Disp.Kp J) (VBOkF VB) :=
  Disp.stepSimXL (fullFfiSim P NB) (by rw [hJ]; exact fullCallSimFb b0 P NB)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws (bridgeFb_names b0).stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg)

end

end Host.Ts.Sim.Full
