import host.sim.full.LogBase

/-! # The prefill's relation with a log base: step theorems and composition

`fullStepSimXLBNL`, `fullStepSimXLBXDJSL`: the checked runs' one-step theorems of Neural Engine rows and of the
prefill's other rows over `FRL L (FullRXD P NB)`, the same acceptance at every `L`.

`BridgeXL L` is the frame at the bridge relation (`fullRXL_iff`), its log the design's
`b'.log = b.log.map M.effect ++ L` (`bridgeXL_log`). A restart composes a template shift whose effects `es` the next
row's template does not hold with the relation: `bridgeXL_after`, the base `es.map M.effect ++ L`. `BridgeXE` is
the base left existential, for the theorems generic over a bridge relation (`bridgeXE_names`, `bridgeXE_push`,
`shiftComp_XE`). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.FfiAne (Effect Program)

/-! ## The accepted calls are the frame's -/

theorem okCallFA_acc {P : LoadP} {x : FF.S} {name : Name} {args : List Arg} (h : okCallFA P x name args = true) :
    AccName name args := by
  simp only [okCallFA, Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq] at h
  obtain ⟨-, ⟨⟨⟨⟨hm, -⟩, -⟩, -⟩, -⟩ | ⟨⟨⟨⟨hm, hc⟩, -⟩, hop⟩, -⟩⟩ := h
  · exact .inl hm
  · exact .inr ⟨hm, hc, hop⟩

theorem okCallFS_acc {P : LoadP} {x : FF.S} {name : Name} {args : List Arg} (h : okCallFS P x name args = true) :
    AccName name args := by
  simp only [okCallFS, Bool.and_eq_true] at h
  exact .inl h.1.1.1.1

theorem okCallFX2_acc {P : LoadP} {x : FF.S} {name : Name} {args : List Arg} (h : okCallFX2 P x name args = true) :
    AccName name args := by
  unfold okCallFX2 at h
  rw [Bool.or_eq_true] at h
  rcases h with hw | h
  · simp only [okCallFW, Bool.and_eq_true] at hw
    exact .inl hw.1.1.1.1
  · cases ha : (bridgeOf x).active
    · rw [ha, Bool.cond_false] at h; exact okCallFS_acc h
    · rw [ha, Bool.cond_true] at h; exact okCallFA_acc h

theorem okCallFXD_acc {P : LoadP} {x : FF.S} {name : Name} {args : List Arg} (h : okCallFXD P x name args = true) :
    AccName name args := by
  unfold okCallFXD at h
  cases hb : decide (P.NL = P.N0)
  · rw [hb, Bool.cond_false] at h; exact okCallFX2_acc h
  · rw [hb, Bool.cond_true] at h; exact okCallFX2_acc h

theorem okCallFN2_acc {P : LoadP} {x : FF.S} {name : Name} {args : List Arg} (h : okCallFN2 P x name args = true) :
    AccName name args := by
  unfold okCallFN2 at h
  rw [Bool.or_eq_true, Bool.or_eq_true] at h
  rcases h with (hw | hi) | h
  · simp only [okCallFW1, Bool.and_eq_true] at hw
    exact .inl hw.1.1.1.1
  · simp only [okCallFOpI, Bool.and_eq_true, Bool.not_eq_true'] at hi
    exact .inr ⟨hi.1.1.1.1.2, hi.1.1.1.2, hi.1.2⟩
  · cases ha : (bridgeOf x).active
    · rw [ha, Bool.cond_false] at h; exact okCallFS_acc h
    · rw [ha, Bool.cond_true] at h
      cases hp : G.symPath (mlxOf x) name args
      · rw [hp, Bool.cond_false] at h; exact okCallFA_acc h
      · rw [hp, Bool.cond_true] at h
        simp only [okCallFAS, Bool.and_eq_true] at h
        exact .inl h.1.1.1.1.2

theorem okCallFND_acc {P : LoadP} {x : FF.S} {name : Name} {args : List Arg} (h : okCallFND P x name args = true) :
    AccName name args := by
  unfold okCallFND at h
  cases hb : decide (P.NL = P.N0)
  · rw [hb, Bool.cond_false] at h; exact okCallFN2_acc h
  · rw [hb, Bool.cond_true] at h; exact okCallFN2_acc h

/-! ## The checked runs' one-step theorems -/

/-- **A Neural Engine row's one-step theorem with a log base.** -/
theorem fullStepSimXLBNL (L : List Effect) (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (D0 : Nat)
    (hJ : J.okCall = okCallFND P) (hsm : J.smallB = smallFN2B VB) (hsb : J.smallBackB = smallBackFB VB)
    (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion)
    {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (Disp.FRJ (FRL L (FullRXD P NB))) (Disp.okJSF J (okBackFXS P) D0) (Disp.KpJ J D0) W stk
      (VBOkF VB) :=
  Disp.stepSimXLBJF (FfiSim.frameFalse (fullFfiSimXD P NB) L) (FfiBackSimS.frame (fullBackSimXDS P NB) L)
    (by rw [hJ]; exact FfiCallSim.frame (fullCallSimND P NB) (fun _ _ _ h => okCallFND_acc h) L)
    (fun _ _ _ _ _ hν hb => smallFN2B_sound hν (by rw [hsm] at hb; exact hb))
    (fun _ _ _ _ hν hb => smallBackFB_sound hν (by rw [hsb] at hb; exact hb))
    (FRLaws.frame (fullRXD_laws P NB) L) fullLawful (NativeFacts.frame (fullNativeFactsXD P NB J hlo hh hg) L) hW

/-- **The prefill's one-step theorem at `okJSJ` with a log base.** -/
theorem fullStepSimXLBXDJSL (L : List Effect) (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (D0 : Nat)
    (hJ : J.okCall = okCallFXD P) (hsm : J.smallB = smallFX2B VB) (hsb : J.smallBackB = smallBackFB VB)
    (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion)
    {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (Disp.FRJ (FRL L (FullRXD P NB))) (Disp.okJSJ J (okBackFXS P) D0) (Disp.KpJ J D0) W stk
      (VBOkF VB) :=
  Disp.stepSimXLBJS (FfiSim.frameFalse (fullFfiSimXD P NB) L) (FfiBackSimS.frame (fullBackSimXDS P NB) L)
    (by rw [hJ]; exact FfiCallSim.frame (fullCallSimXD P NB) (fun _ _ _ h => okCallFXD_acc h) L)
    (fun _ _ _ _ _ hν hb => smallFX2B_sound hν (by rw [hsm] at hb; exact hb))
    (fun _ _ _ _ hν hb => smallBackFB_sound hν (by rw [hsb] at hb; exact hb))
    (FRLaws.frame (fullRXD_laws P NB) L) fullLawful (NativeFacts.frame (fullNativeFactsXD P NB J hlo hh hg) L) hW

/-! ## The frame at the bridge relation -/

/-- **The bridge relation with a log base and programs up to lock flags.** -/
def BridgeXL (L : List Effect) (M : Map) (x y : FF.S) : Prop :=
  ∃ y0 ps, y = fF L ps y0 ∧ SameP ps (bridgeOf y0) ∧ BridgeX M x y0

theorem fullRXL_iff {L : List Effect} {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} :
    FRL L (FullRX P NB) M n x y ↔ FullRB (BridgeXL L) P NB M n x y := by
  constructor
  · rintro ⟨y0, ps, rfl, hps, hr⟩
    exact ⟨hr.load, ⟨y0, ps, rfl, hps, hr.bridge⟩, hr.live, hr.kern, hr.pend⟩
  · intro h
    obtain ⟨y0, ps, rfl, hps, hb⟩ := h.bridge
    exact ⟨y0, ps, rfl, hps, ⟨h.load, hb, h.live, h.kern, h.pend⟩⟩

/-- The design's log: with the bridge active, the template's under the map, then the base. -/
theorem bridgeXL_log {L : List Effect} {M : Map} {x y : FF.S} (h : BridgeXL L M x y)
    (ha : (bridgeOf x).active = true) : (bridgeOf y).log = (bridgeOf x).log.map M.effect ++ L := by
  obtain ⟨y0, ps, rfl, -, hb⟩ := h
  show (bridgeOf y0).log ++ L = _
  rw [(hb.active ha).rel.log]

theorem bridgeXL_names (L : List Effect) : BridgeNames (BridgeXL L) := by
  rintro M M' x y ⟨y0, ps, e, hps, hb⟩ hn
  exact ⟨y0, ps, e, hps, Conv.bridgeX_names M M' x y0 hb hn⟩

theorem bridgeXL_push (L : List Effect) : BridgePush (BridgeXL L) := by
  rintro M x y n w ⟨y0, ps, e, hps, hb⟩
  exact ⟨y0, ps, e, hps, bridgeX_push M x y0 n w hb⟩

/-- A state with the frame's log and programs moved under another base. -/
def rebase (y : FF.S) (ps : List Program) (l : List Effect) : FF.S :=
  ((⟨y.1.1.base, { y.1.1.bridge with programs := ps, log := l }⟩, y.1.2), y.2)

theorem fF_rebase {y : FF.S} {L L' : List Effect} {ps ps' : List Program} {l : List Effect}
    (h : (bridgeOf y).log ++ L = l ++ L') : fF L ps y = fF L' ps (rebase y ps' l) := by
  obtain ⟨⟨⟨base, b⟩, v⟩, k⟩ := y
  have h' : b.log ++ L = l ++ L' := h
  show (((⟨base, { b with programs := ps, log := b.log ++ L }⟩ : Host.Load.Ane.ASt), v), k) =
    (((⟨base, { b with programs := ps, log := l ++ L' }⟩ : Host.Load.Ane.ASt), v), k)
  rw [h']

/-- **Composition with the bridge active**: the shift's effects `es` move into the base. -/
theorem bridgeXL_after {σ M : Map} {x y z : FF.S} {es L : List Effect} (hs : BridgeXL es σ x y) (hr : BridgeXL L M y z)
    (hn : ∀ n, n < (mlxOf x).nnext → σ.node n < (mlxOf y).nnext) (ha : (bridgeOf x).active = true) :
    BridgeXL (es.map M.effect ++ L) (M.after σ) x z := by
  obtain ⟨y0, ps1, rfl, hps1, hs0⟩ := hs
  obtain ⟨z0, ps2, rfl, hps2, hr0⟩ := hr
  have hA0 := hs0.active ha
  have hya : (bridgeOf y0).active = true := hA0.rel.active.trans ha
  have hA := hr0.active (x := fF es ps1 y0) hya
  have hrel : BRel M (mlxOf y0).nnext (mlxOf z0).nnext (bridgeOf y0)
      (bridgeOf (rebase z0 (bridgeOf y0).programs ((bridgeOf y0).log.map M.effect))) :=
    { hA.rel with programs := rfl, log := rfl }
  have hb1 : BridgeX M y0 (rebase z0 (bridgeOf y0).programs ((bridgeOf y0).log.map M.effect)) :=
    .inr ⟨hya, ⟨hrel, hA.dense⟩⟩
  refine ⟨_, ps2, ?_, ?_, Conv.bridgeX_after hs0 hb1 hn⟩
  · refine fF_rebase ?_
    have e : (bridgeOf z0).log = ((bridgeOf y0).log ++ es).map M.effect := hA.rel.log
    rw [e, List.map_append, List.append_assoc]
  · show ps2.map stripP = (bridgeOf y0).programs.map stripP
    rw [hps2, show (bridgeOf z0).programs = ps1 from hA.rel.programs]
    exact hps1

/-- **The base left existential**, for the theorems generic over a bridge relation. -/
def BridgeXE (M : Map) (x y : FF.S) : Prop := ∃ L, BridgeXL L M x y

theorem bridgeXE_names : BridgeNames BridgeXE := by
  rintro M M' x y ⟨L, h⟩ hn
  exact ⟨L, bridgeXL_names L M M' x y h hn⟩

theorem bridgeXE_push : BridgePush BridgeXE := by
  rintro M x y n w ⟨L, h⟩
  exact ⟨L, bridgeXL_push L M x y n w h⟩

theorem shiftComp_XE : ShiftComp BridgeXE BridgeXE := by
  rintro σ M x y z ⟨es, hs⟩ hn ⟨L, hr⟩
  cases ha : (bridgeOf x).active
  · obtain ⟨y0, ps1, rfl, hps1, hs0⟩ := hs
    obtain ⟨z0, ps2, rfl, hps2, hr0⟩ := hr
    have hI : BridgeI σ x y0 := by
      rcases hs0 with h | ⟨h, -⟩
      · exact h
      · rw [ha] at h; cases h
    have hya : (bridgeOf (fF es ps1 y0)).active = false := by
      show (bridgeOf y0).active = false
      rw [hI.1]; exact ha
    have hzI : BridgeI M (fF es ps1 y0) z0 := by
      rcases hr0 with h | ⟨h, -⟩
      · exact h
      · rw [hya] at h; cases h
    refine ⟨es ++ L, rebase z0 (bridgeOf x).programs (bridgeOf x).log, ps2, ?_, ?_, .inl ⟨?_, ha⟩⟩
    · refine fF_rebase ?_
      have e : (bridgeOf z0).log = (bridgeOf y0).log ++ es := congrArg (·.log) hzI.1
      rw [e, show (bridgeOf y0).log = (bridgeOf x).log from congrArg (·.log) hI.1, List.append_assoc]
    · show ps2.map stripP = (bridgeOf x).programs.map stripP
      rw [hps2, show (bridgeOf z0).programs = ps1 from congrArg (·.programs) hzI.1, hps1,
        show (bridgeOf y0).programs = (bridgeOf x).programs from congrArg (·.programs) hI.1]
    · have e : bridgeOf y0 = bridgeOf x := hI.1
      have e2 : bridgeOf z0 = fB es ps1 (bridgeOf y0) := hzI.1
      show { bridgeOf z0 with programs := (bridgeOf x).programs, log := (bridgeOf x).log } = bridgeOf x
      rw [e2, e]
      rfl
  · exact ⟨_, bridgeXL_after hs hr hn ha⟩

end Host.Ts.Sim.Full
