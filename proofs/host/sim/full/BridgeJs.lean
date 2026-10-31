import host.sim.full.TargetGrowD
import host.sim.full.BigJs
import host.sim.full.World
import host.sim.conv.CompactBridge

/-! # The prefill's world: the bridge at a raise, with JavaScript-side calls

A prefill whose chunks run on the Neural Engine activates the bridge, and its compiled closures record
traces, so its chains run at `FullRXD` (the bridge inactive and equal, or active under the map, at a
raise of a band-free `P`), accepted by `Disp.okJSJ (fullJSPXXS P VB framed wide) (okBackFXS P) D0`:
`okCallFXD`'s calls, the continuations `okBackFX` checks or the replay over symbolic shapes
(`G.backOkV`, under `smallBackF`). The one-step theorems (`fullStepSim*XDJS`) and the target's growth
(`fullStepSimXLBXDJSQ`) follow; `fullWorldXD` is the world of its halting paths (no restart: its
template shifts are empty). Its end is the hand-off's start (`Conv.full_handoffTb`). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim
open Host.Ts.Sim.BufSim (Lawful)

/-! ## Restoring JavaScript pointer integers -/

/-- The active bridge reads only node names, which `withJs` preserves. -/
theorem fullRX_withJs {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S}
    (h : FullRX P NB M n x y) (hb : bigsOutB jsLoN jsHiN (mlxOf x) = true) :
    FullRX P NB M.withJs n x y := by
  refine fullRB_withJs (fun _ _ _ h => ?_) h hb
  rcases h with h | ⟨ha, h⟩
  · exact .inl h
  · exact .inr ⟨ha, h.rel.names rfl, h.dense⟩

/-- Restore the JavaScript pointer law at any raise, keeping the bridge relation. -/
theorem fullRXD_withJs {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S}
    (h : FullRXD P NB M n x y) (hb : bigsOutB jsLoN jsHiN (mlxOf x) = true) :
    FullRXD P NB M.withJs n x y := by
  obtain ⟨P', hP, h⟩ := h
  exact ⟨P', hP, fullRX_withJs h hb⟩

section
variable {W : Nat → Option WFrame} {stk : List Frame} {M N σ : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St FF.S} {S : SSrv} {C : CSrv} {P : LoadP} {NB : Nat}

/-- Restore the JavaScript pointer law after a site shift, with the bridge at a raise. -/
theorem _root_.Host.Ts.Sim.RelB.afterJsFullXD (h : RelB FF (FullRXD P NB) W stk N ν K s S t C)
    (hM : BigJs M) (ha : N.a = (M.after σ).a)
    (hbig : ∀ i, jsPtrOf i ≠ none → N.big i = M.big (σ.big i)) (hlo : K.lo ≤ 2 ^ 56)
    (hchk : stateNoBigP (jsShiftBadB σ) K.base s = true)
    (hb : bigsOutB jsLoN jsHiN (mlxOf s.ffi) = true) :
    RelB FF (Disp.FRJ (FullRXD P NB)) W stk N.withJs ν K s S t C :=
  (h.afterJs hM ha hbig hlo hchk (fullRXD_withJs h.ffi hb)).toJ (BigJs.withJs N)

/-- The same restoration with checks per present address and on the roots. -/
theorem _root_.Host.Ts.Sim.RelB.afterJsFullXDBlocks (h : RelB FF (FullRXD P NB) W stk N ν K s S t C)
    (hM : BigJs M) (ha : N.a = (M.after σ).a)
    (hbig : ∀ i, jsPtrOf i ≠ none → N.big i = M.big (σ.big i)) (hlo : K.lo ≤ 2 ^ 56)
    (hheap : ∀ a, Present s a → noBigAtP (jsShiftBadB σ) s a = true)
    (hroots : noBigRootsP (jsShiftBadB σ) K.base s = true)
    (hb : bigsOutB jsLoN jsHiN (mlxOf s.ffi) = true) :
    RelB FF (Disp.FRJ (FullRXD P NB)) W stk N.withJs ν K s S t C :=
  (h.afterJsBlocks hM ha hbig hlo hheap hroots (fullRXD_withJs h.ffi hb)).toJ (BigJs.withJs N)

end

/-! ## Continuations over symbolic shapes with the bridge -/

/-- **The full world's accepted continuations with the bridge and symbolic replays**: `okBackFX`'s, or
the replay over symbolic shapes (`G.backOkV`), at the band raised to the node counter. -/
def okBackFXS (P : LoadP) (x : FF.S) (a : Arg) : Bool :=
  decide (P.NL = P.N0) &&
    (G.backOkG (P.raise (mlxOf x).nnext) (mlxOf x) a || G.backOkV (P.raise (mlxOf x).nnext) (mlxOf x) a)

theorem okBackFXS_of {P : LoadP} {x : FF.S} {a : Arg} (h : okBackFX P x a = true) : okBackFXS P x a = true := by
  simp only [okBackFX, okBackFXS, Bool.and_eq_true, Bool.or_eq_true] at h ⊢
  exact ⟨h.1, .inl h.2⟩

/-- Every continuation `okBackFX` accepts has `smallBackFB` true: its replay is the literal one. -/
theorem smallBackFB_of_okBackFX {P : LoadP} {VB : Nat → Nat} {S : SSrv} {x : FF.S} {a : Arg}
    (h : okBackFX P x a = true) : smallBackFB VB S x a = true := by
  simp only [okBackFX, Bool.and_eq_true] at h
  obtain ⟨x1, c, t, xs, hf, hn, hc⟩ :=
    G.backOkR_found (rc := fun x1 c m o => G.rchk (P.raise (mlxOf x).nnext).NL c x1 m o) h.2
  have hc' : G.rchk x1.nnext c x1 (t.ins.zip xs) t.order = true := by rw [hn]; exact hc
  unfold smallBackFB G.backSmallB G.backSym
  rw [hf]
  dsimp only
  rw [hc']
  rfl

/-- The full world's continuation with the bridge at a raise, from the mlx world's at the band raised to
the node counter. -/
theorem fullBackXD_of {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S} {a : Arg}
    (hr : FullRXD P NB M S.tab.length x y) (hb : P.NL = P.N0)
    (hg : G.MR (P.raise (mlxOf x).nnext) NB M S.tab.length (mlxOf x) (mlxOf y) →
      MSim (G.MPost (P.raise (mlxOf x).nnext) NB M ν S C) S C (Host.Mlx.Ffi.back (mlxOf x) a)
        (Host.Mlx.Ffi.back (mlxOf y) (M.arg a))) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRXD P NB) M' S'.tab.length r r') S C
      (FF.back x a) (FF.back y (M.arg a)) := by
  obtain ⟨hrr, hP⟩ := hr.top hb
  have hgl := G.mlx_liftB hrr.load (hg hrr.load.mlx)
  cases hact : (bridgeOf x).active
  · refine MSim.mono (fullBackOf (hrr.toR hact) hact hgl) ?_
    exact fun M' S' C' r r' h => ⟨h.1, callR_mono (fun _ _ _ _ h => ⟨_, hP, h.toX⟩) h.2⟩
  · have hF : ∀ i, Full (P.raise (mlxOf x).nnext) i := fun i => by
      show i < (mlxOf x).nnext ∨ (mlxOf x).nnext ≤ i; omega
    refine MSim.mono (fullBackOfA hrr hF hact hgl) ?_
    exact fun M' S' C' r r' h => ⟨h.1, callR_mono (fun _ _ _ _ h => ⟨_, hP, h⟩) h.2⟩

/-- **The full world's continuation simulation with the bridge at a raise and symbolic replays.** -/
theorem fullBackSimXDS (P : LoadP) (NB : Nat) : FfiBackSimS FF (FullRXD P NB) (okBackFXS P) smallBackF where
  back := by
    intro M ν S C x y a hsrv hr hok _ hsm
    simp only [okBackFXS, Bool.and_eq_true, decide_eq_true_eq, Bool.or_eq_true] at hok
    obtain ⟨hb, hg | hv⟩ := hok
    · exact fullBackXD_of hr hb fun hm => G.sim_traceBack hsrv hm hg
    · exact fullBackXD_of hr hb fun hm => G.sim_traceBackV hsrv hm hv hsm

/-- The acceptance parameters with the bridge at a raise, the continuations' premise decided by
`smallBackFB`. -/
abbrev fullJSPXXS (P : LoadP) (VB : Nat → Nat) (framed : List Nat) (wide : List (Nat × WFrame) := []) :
    Disp.JSP FF :=
  { fullJSPXX P VB framed wide with smallBackB := smallBackFB VB }

/-- **Agreement** with the acceptance before the smallness check, for literal callbacks. -/
theorem fullJSPXXS_agree (P : LoadP) (VB : Nat → Nat) (framed : List Nat) (wide : List (Nat × WFrame))
    (D0 : Nat) (s : St FF.S) (S : SSrv) :
    Disp.okJSJ (fullJSPXXS P VB framed wide) (okBackFX P) D0 s S =
      Disp.okJSJOld (fullJSPXXS P VB framed wide) (okBackFX P) D0 s S :=
  Disp.okJSJ_eq_old (fun _ _ _ h => smallBackFB_of_okBackFX h) s S

/-- **Lift** an old checked state to the acceptance with symbolic continuation replays. -/
theorem fullJSPXXS_lift {P : LoadP} {VB : Nat → Nat} {framed : List Nat} {wide : List (Nat × WFrame)}
    {D0 : Nat} {s : St FF.S} {S : SSrv}
    (h : Disp.okJSJOld (fullJSPXXS P VB framed wide) (okBackFX P) D0 s S = true) :
    Disp.okJSJ (fullJSPXXS P VB framed wide) (okBackFXS P) D0 s S = true :=
  Disp.okJSJ_mono (fun _ _ h => okBackFXS_of h) ((fullJSPXXS_agree P VB framed wide D0 s S).trans h)

theorem backSimS_liftQ {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {Q : F.S → Prop} {okBack : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Arg → Prop} (hB : FfiBackSimS F FR okBack small) (hL : BufSim.FfiLawful F)
    (hQ : TargetPres F FR Q) : FfiBackSimS F (FRQ FR Q) okBack small where
  back M ν S C x y a hs hr hok hsupp hsm :=
    MSim.mono (MSim.withRunT (hB.back M ν S C x y a hs hr.1 hok hsupp hsm) (hL.back _ _) (hL.back _ _))
      fun _ _ C' _ _ ⟨⟨hg, hc⟩, hrun⟩ => ⟨hg, hc.liftQ fun y' rr ws e => by
        subst e; exact hQ.back M _ x y _ C y' rr ws C' hr.1 hr.2 hrun⟩

/-! ## The one-step theorems at the prefill's acceptance -/

section
variable (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (D0 : Nat) (hJ : J.okCall = okCallFXD P)
  (hsm : J.smallB = smallFX2B VB) (hsb : J.smallBackB = smallBackFB VB) (hlo : J.lo = P.lo)
  (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion)
include hJ hsm hsb hlo hh hg

/-- **The one-step theorem with the bridge at a raise at `okJSJ`** (`fullJSPXXS`, `okBackFXS`), under
frames `W` and a stack base. -/
theorem fullStepSimXBXDJS {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXVB FF (Disp.FRJ (FullRXD P NB)) (Disp.okJSJ J (okBackFXS P) D0) (Disp.KpJ J D0) W stk (VBOkF VB) :=
  Disp.stepSimXVBJS (fullFfiSimXD P NB) (fullBackSimXDS P NB) (by rw [hJ]; exact fullCallSimXD P NB)
    (fun _ _ _ _ _ hν hb => smallFX2B_sound hν (by rw [hsm] at hb; exact hb))
    (fun _ _ _ _ hν hb => smallBackFB_sound hν (by rw [hsb] at hb; exact hb))
    (fullRXD_laws P NB) fullLawful (fullNativeFactsXD P NB J hlo hh hg) hW

/-- The same for any reached state, under frames and a stack base. -/
theorem fullStepSimXLBXDJS {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD P NB)) (Disp.okJSJ J (okBackFXS P) D0) (Disp.KpJ J D0) W stk (VBOkF VB) :=
  Disp.stepSimXLBJS (fullFfiSimXD P NB) (fullBackSimXDS P NB) (by rw [hJ]; exact fullCallSimXD P NB)
    (fun _ _ _ _ _ hν hb => smallFX2B_sound hν (by rw [hsm] at hb; exact hb))
    (fun _ _ _ _ hν hb => smallBackFB_sound hν (by rw [hsb] at hb; exact hb))
    (fullRXD_laws P NB) fullLawful (fullNativeFactsXD P NB J hlo hh hg) hW

/-- The same for any reached state. -/
theorem fullStepSimXLXDJS :
    Disp.StepSimXL FF (Disp.FRJ (FullRXD P NB)) (Disp.okJSJ J (okBackFXS P) D0) (Disp.KpJ J D0) (VBOkF VB) :=
  Disp.stepSimXLJS (fullFfiSimXD P NB) (fullBackSimXDS P NB) (by rw [hJ]; exact fullCallSimXD P NB)
    (fun _ _ _ _ _ hν hb => smallFX2B_sound hν (by rw [hsm] at hb; exact hb))
    (fun _ _ _ _ hν hb => smallBackFB_sound hν (by rw [hsb] at hb; exact hb))
    (fullRXD_laws P NB) fullLawful (fullNativeFactsXD P NB J hlo hh hg)

/-- `fullStepSimXLBXDJS` with the target's growth from `y0`. -/
theorem fullStepSimXLBXDJSQ {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (Disp.FRJ (FRQ (FullRXD P NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (Disp.okJSJ J (okBackFXS P) D0) (Disp.KpJ J D0) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullRXD P NB) J.okCall smallFX2 := by rw [hJ]; exact fullCallSimXD P NB
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  exact Disp.stepSimXLBJS ((fullFfiSimXD P NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS P NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => smallFX2B_sound hν (by rw [hsm] at hb; exact hb))
    (fun _ _ _ _ hν hb => smallBackFB_sound hν (by rw [hsb] at hb; exact hb))
    (fullRXD_laws P NB).liftQ fullLawful (fullNativeFactsXD P NB J hlo hh hg).liftQ hW

end

/-! ## The world of the prefill's halting paths -/

theorem bridgeX_push : BridgePush BridgeX := fun M x y n w h => by
  have h' : BridgeX (M.setNum n w) x y := h.names rfl
  rcases h' with h' | ⟨ha, hA⟩
  · exact .inl h'
  · exact .inr ⟨ha, ⟨hA.rel, hA.dense⟩⟩

/-- **A second token at a raise** (`FullRB.addToken` over `BridgeX`). -/
theorem FullRXD.addToken {P : LoadP} {NB : Nat} {w : NumV} {r : List NumV} {M : Map} {n : Nat} {x y : FF.S}
    (hr : FullRXD { P with rest := w :: r } NB M n x y) :
    FullRXD { P with rest := r } NB (M.setNum n w) (n + 1) (fullPush x n) y := by
  obtain ⟨P', hP, hr⟩ := hr
  rcases hP with rfl | ⟨k, hb, hk, rfl⟩
  · exact ⟨_, .inl rfl, FullRB.addToken bridgeX_push hr⟩
  · exact ⟨_, .inr ⟨k, hb, hk, rfl⟩, FullRB.addToken (P := P.raise k) bridgeX_push hr⟩

/-- **The world of the prefill's halting paths**: the full world's relation with the bridge at a raise
(`FullRXD`). Its template shifts are empty, so its restart holds vacuously: a path halts without one. -/
def fullWorldXD (NB : Nat) : World where
  F := FF
  Par := LoadP
  lo P := P.lo
  E P := P.E
  NE P := P.NE
  R P r := FullRXD { P with rest := r } NB
  toMlx := mlxOf
  laws P _ := fullRXD_laws _ NB
  pushTok := fullPush
  addToken h := FullRXD.addToken h
  NSh _ _ _ _ _ := False
  Start := fullStart
  restart := by
    intro k w P r0 M M1 ν K K1 Wf W0 W1 kp s0 s1 t t1 S0 S1 C C1 n σ θ v r x hst h hr0 hrc hext h1 hKD hKlo hKhi htab
      hor hshift
    exact hshift.ffi.2.elim

end Host.Ts.Sim.Full
