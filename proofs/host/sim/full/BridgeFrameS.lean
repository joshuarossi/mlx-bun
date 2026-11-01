import host.sim.full.BridgeFrameCall
import host.sim.full.ReplayS
import host.sim.full.RunFast

/-! # Applies whose trace lookup asks the server, at the decode relation

A decode template holding symbolic dimensions in its compiled traces compares them with the tracer's inputs through the
server, so its applies leave `cloOk`. `okCallFSS` adds them to the decode acceptance (`okCallSV`, at the chain's own
band), `smallFSS` their premise (`G.cloSmallS`); `fullCallSimFS`, `fullCallSimFbS` are the simulations at `FullRF` and at
the pinned bridge, and `fullStepSimXLBKFbS`, `fullStepSimXLBKFbSQ` the one-step theorems the decode chains use. -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers

/-- **The decode acceptance with the applies whose lookup asks the server.** -/
def okCallFSS (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  okCallFS P x name args || okCallSV P x name args

/-- `smallFS` with their premise. -/
def smallFSS (ν : Nat → F64) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Prop :=
  smallFS ν S x name args ∧ G.cloSmallS ν S (mlxOf x) name args

/-- The decider of `G.cloSmallS`. -/
def cloSmallSB (VB : Nat → Nat) (S : SSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  !G.cloServer x name args ||
    ((G.cloRefsS x args).all (refSmallB VB S) && G.cloFoundS S x args && G.cloRunB S x name args)

theorem cloSmallSB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : NSt} {name : Name} {args : List Arg}
    (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (h : cloSmallSB VB S x name args = true) : G.cloSmallS ν S x name args := by
  intro hc
  unfold cloSmallSB at h
  rw [hc] at h
  simp only [Bool.not_true, Bool.false_or, Bool.and_eq_true] at h
  refine ⟨fun j hj => refSmallB_sound (List.all_eq_true.mp h.1.1 j hj) hν, h.1.2, fun r S' hr' => ?_⟩
  have h2 := h.2
  unfold G.cloRunB at h2
  rw [hr'] at h2
  cases r
  · cases h2
  · rfl

/-- The decider of `smallFSS` (irreducible, as `smallFSB`). -/
@[irreducible] def smallFSSB (VB : Nat → Nat) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  smallFSB VB S x name args && cloSmallSB VB S (mlxOf x) name args

theorem smallFSSB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (h : smallFSSB VB S x name args = true) : smallFSS ν S x name args := by
  unfold smallFSSB at h
  rw [Bool.and_eq_true] at h
  exact ⟨smallFSB_sound hν h.1, cloSmallSB_sound hν h.2⟩

/-! ## Over the fast table -/

/-- `G.cloFoundS` over `FSrv`. -/
noncomputable def cloFoundSF (c : FSrv) (x : NSt) (args : List Arg) : Bool :=
  match G.cloParts x args with
  | some (xs, ts) => match interpF (Host.Mlx.Ffi.findTrace x false xs ts).run c with
    | some (some _, _) => true
    | _ => false
  | none => false

theorem cloFoundSF_eq {c : FSrv} (h : c.Wf) (x : NSt) (args : List Arg) :
    cloFoundSF c x args = G.cloFoundS c.toS x args := by
  unfold cloFoundSF G.cloFoundS
  cases G.cloParts x args with
  | none => rfl
  | some p =>
    obtain ⟨xs, ts⟩ := p
    dsimp only
    rw [← (interpF_eq (Host.Mlx.Ffi.findTrace x false xs ts).run c h).1]
    cases interpF (Host.Mlx.Ffi.findTrace x false xs ts).run c with
    | none => rfl
    | some p =>
      obtain ⟨o, c1⟩ := p
      cases o <;> rfl

/-- `cloSmallSB` over `FSrv`. -/
noncomputable def cloSmallSF (VB : Nat → Nat) (c : FSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  !G.cloServer x name args || ((G.cloRefsS x args).all (refSmallF VB c) && cloFoundSF c x args && cloRunF c x name args)

theorem cloSmallSF_eq (VB : Nat → Nat) {c : FSrv} (h : c.Wf) (x : NSt) (name : Name) (args : List Arg) :
    cloSmallSF VB c x name args = cloSmallSB VB c.toS x name args := by
  unfold cloSmallSF cloSmallSB
  rw [refSmallF_eq VB h, cloFoundSF_eq h, cloRunF_eq h]

/-- `smallFSSB` over `FSrv`. -/
noncomputable def smallFSSF (VB : Nat → Nat) (c : FSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  smallFSF VB c x name args && cloSmallSF VB c (mlxOf x) name args

theorem smallFSSF_eq (VB : Nat → Nat) {c : FSrv} (h : c.Wf) (x : FF.S) (name : Name) (args : List Arg) :
    smallFSSF VB c x name args = smallFSSB VB c.toS x name args := by
  unfold smallFSSF smallFSSB
  rw [smallFSF_eq VB h, cloSmallSF_eq VB h]

/-- The decode acceptance parameters with those applies (`fullJSPX`'s, `okCall`, `smallB` replaced). -/
abbrev fullJSPXF (P : LoadP) (VB : Nat → Nat) (framed : List Nat) (wide : List (Nat × WFrame) := []) : Disp.JSP FF :=
  { okCall := okCallFSS P, smallB := smallFSSB VB, lo := P.lo, hi := P.E, framed := framed,
    isHandle := fullIsHandle, isRegion := fullIsRegion, wide := wide }

/-! ## The simulation -/

/-- The accepted calls don't read the readbacks. -/
theorem okCallFSS_rest (P : LoadP) (r : List NumV) : okCallFSS { P with rest := r } = okCallFSS P := by
  funext x name args
  unfold okCallFSS okCallSV
  rw [okCallFS_rest, clApplyS_rest]

/-- **An apply whose lookup asks the server, the target's bridge framed**, the target's bridge kept. -/
theorem fullCloSimSF {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hsrv : Srv M ν S C) (hr : FullRF P NB M S.tab.length x y)
    (hok : okCallSV P x name args = true) (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a)
    (hsm : G.cloSmallS ν S (mlxOf x) name args) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRFb (bridgeOf y) P NB) M' S'.tab.length r r')
      S C (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  simp only [okCallSV, Bool.and_eq_true, Bool.not_eq_true'] at hok
  obtain ⟨⟨⟨⟨⟨hm, hp⟩, hact⟩, hgate⟩, hokS⟩, hobs⟩ := hok
  have hsym := G.cloServer_sym hgate
  cases hia : (bridgeOf y).active
  · exact fullCallSimF_inactive hr hm hp hia (fullCloSimS hsrv hr.swap hm hp hact hgate hokS hobs hsupp hsm)
  · have hq : Quiet M (mlxOf x) (mlxOf y) (bridgeOf y) := by
      rcases hr.bridge.2 with h | h
      · rw [hia] at h; cases h
      · exact h
    have hg := G.mlx_lift hr.load hm (G.sim_closureApplyS hsrv hr.load.mlx hsym hokS hgate hsm)
    have hss : isSymShape name = false := by unfold isSymShape; rw [hsym]
    refine fullCallOfF hr hm hp hact hia hq hobs hsupp ?_ ?_ (fun h => by rw [hss] at h; cases h) hg
    · intro s hs; rw [hsym] at hs; cases hs
      exact ⟨(fun h => nomatch h), (fun h => by rcases h with h | h | h <;> cases h)⟩
    · intro hs; rw [hsym] at hs; cases hs

theorem fullCallSimFS_core {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hsrv : Srv M ν S C) (hr : FullRF P NB M S.tab.length x y)
    (hok : okCallFSS P x name args = true) (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a)
    (hsm : smallFSS ν S x name args) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRFb (bridgeOf y) P NB) M' S'.tab.length r r')
      S C (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  unfold okCallFSS at hok
  rw [Bool.or_eq_true] at hok
  rcases hok with h | h
  · exact fullCallSimF_core hsrv hr h hsupp hsm.1
  · exact fullCloSimSF hsrv hr h hsupp hsm.2

/-- **The native-call simulation with the target's bridge framed, with those applies.** -/
theorem fullCallSimFS (P : LoadP) (NB : Nat) : FfiCallSim FF (FullRF P NB) (okCallFSS P) smallFSS where
  call _ _ _ _ _ _ _ _ hsrv hr hok hsupp hsm :=
    MSim.mono (fullCallSimFS_core hsrv hr hok hsupp hsm) fun _ _ _ _ _ h => ⟨h.1, callR_bridge (fun _ _ _ h => h.1) h.2⟩

/-- **The native-call simulation with the target's bridge pinned to `b0`, with those applies.** -/
theorem fullCallSimFbS (b0 : BSt) (P : LoadP) (NB : Nat) : FfiCallSim FF (FullRFb b0 P NB) (okCallFSS P) smallFSS where
  call _ _ _ _ _ y _ _ hsrv hr hok hsupp hsm := by
    have h := fullCallSimFS_core hsrv (hr.mapBridge And.left) hok hsupp hsm
    rw [show bridgeOf y = b0 from hr.bridge.2] at h
    exact h

/-! ## The one-step theorems -/

section
variable (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFSS P)
  (hsm : J.smallB = smallFSSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
  (hg : J.isRegion = fullIsRegion)
include hJ hsm hlo hh hg

/-- **`fullStepSimXLBKFb` with those applies.** -/
theorem fullStepSimXLBKFbS (b0 : BSt) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (FullRFb b0 P NB) (Disp.okJSK J (fun _ _ => false)) (Disp.Kp J) W stk (VBOkF VB) :=
  Disp.stepSimXLBK (fullFfiSim P NB) backSimNone (by rw [hJ]; exact fullCallSimFbS b0 P NB)
    (fun _ _ _ _ _ hν hb => smallFSSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws (bridgeFb_names b0).stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- **`fullStepSimXLBKFbQ` with those applies.** -/
theorem fullStepSimXLBKFbSQ (b0 : BSt) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W)
    (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (FullRFb b0 P NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))
      (Disp.okJSK J (fun _ _ => false)) (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullRFb b0 P NB) J.okCall smallFSS := by rw [hJ]; exact fullCallSimFbS b0 P NB
  have hQ := fullTargetPres (FR := FullRFb b0 P NB) (fun _ _ _ _ hr h hh => (hr.load.mlx.yabsent h hh).2) y0
  exact Disp.stepSimXLBK ((fullFfiSim P NB).liftQ fullLawful hQ) backSimNone (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => smallFSSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws (bridgeFb_names b0).stable P NB).liftQ fullLawful (fullNativeFacts P NB J hlo hh hg).liftQ hW

end

end Host.Ts.Sim.Full
