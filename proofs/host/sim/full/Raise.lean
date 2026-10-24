import host.sim.full.StepX
namespace Host.Ts.Sim

/-! # Raising a band-free relation's traced band

A trace a compiled closure records during a run names fresh nodes, above the native relation's
traced band (`G.MR.traced`: below `P.NL`). A relation without a shape-only band (`P.NL = P.N0`,
the prompt route's: every node corresponds fully) can raise its band to any `k` between `P.N0` and
the template's node counter (`LoadP.raise`, `G.MR.raise`): nothing else in the relation changes,
and every node below the counter, a recorded trace's included, is below the raised `NL`. The full
world's relation `Full.FullRD` is `FullR` at such a raise; its accepted calls are the ones of
`okCallFS P` (the deciders read `NL` only to bound a replay, monotonically: `okCallFS_raise`). A
relation with a band does not raise: a trace recorded there is rejected, as before. -/

/-- `P` with its band raised to `k`. -/
def LoadP.raise (P : LoadP) (k : Nat) : LoadP := { P with NL := k, N0 := k }

end Host.Ts.Sim

namespace Host.Ts.Sim.G

/-- The replay check is monotone in the band. -/
theorem rchk_mono {NL NL' : Nat} (h : NL ≤ NL') (cls : Nat) :
    ∀ (x : NSt) (m : List (Nat × Nat)) (ns : List Nat), rchk NL cls x m ns = true → rchk NL' cls x m ns = true
  | _, _, [], _ => rfl
  | x, m, a :: ns, hc => by
    unfold rchk at hc ⊢
    simp only [Bool.and_eq_true, decide_eq_true_eq] at hc ⊢
    obtain ⟨ha, hc⟩ := hc
    refine ⟨by omega, ?_⟩
    revert hc
    cases x.nodes.get a with
    | none => exact id
    | some nd =>
      dsimp only
      simp only [Bool.and_eq_true]
      intro ⟨hi, hc⟩
      refine ⟨hi, ?_⟩
      revert hc
      cases leafP nd.prim
      · simp only [Bool.cond_false]
        cases Host.Mlx.Ffi.isKernel nd.prim
        · simp only [Bool.cond_false]
          cases decide (nd.ins.map (Host.Mlx.Ffi.substOf m) = nd.ins)
          · simp only [Bool.cond_false, Bool.and_eq_true]
            intro ⟨hp, hc⟩
            refine ⟨hp, ?_⟩
            revert hc
            cases Host.Mlx.Ffi.shapesOf x (nd.ins.map (Host.Mlx.Ffi.substOf m)) with
            | none => exact id
            | some sh =>
              dsimp only
              simp only [Bool.and_eq_true]
              intro ⟨hs, hc⟩
              refine ⟨hs, ?_⟩
              revert hc
              split
              · exact rchk_mono h cls _ _ ns
              · split
                · exact rchk_mono h cls _ _ ns
                · exact id
              · exact id
              · exact id
          · simp only [Bool.cond_true]; exact rchk_mono h cls _ _ ns
        · simp only [Bool.cond_true]; exact rchk_mono h cls _ _ ns
      · simp only [Bool.cond_true]; exact rchk_mono h cls _ _ ns

section
variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt}

theorem full_raise (hb : P.NL = P.N0) (k i : Nat) : Full (P.raise k) i ↔ Full P i := by
  show (i < k ∨ k ≤ i) ↔ (i < P.NL ∨ P.N0 ≤ i)
  constructor <;> intro _ <;> omega

/-- **The raise of a band-free relation**, to any `k` between its `N0` and the template's node
counter. -/
theorem MR.raise (hr : MR P NB M n x y) (hb : P.NL = P.N0) {k : Nat} (hk0 : P.N0 ≤ k) (hk : k ≤ x.nnext) :
    MR (P.raise k) NB M n x y :=
  { hr with
    traced := fun h o ho i hi => by
      have := hr.traced h o ho i hi
      show i < k
      omega
    nbl := by have := hr.nbl; show NB ≤ k; omega
    norder := fun i hi hf j hj => hr.norder i hi ((full_raise hb k i).1 hf) j hj
    nodes := fun i nd hn => by
      obtain ⟨nd', h1, h2⟩ := hr.nodes i nd hn
      exact ⟨nd', h1, h2.1, h2.2.1, h2.2.2.1, fun hf => h2.2.2.2 ((full_raise hb k i).1 hf)⟩
    nband := ⟨Nat.le_refl k, hk⟩ }

theorem LoadR.raise {x y : Host.Load.LSt} (hr : LoadR P NB M n x y) (hb : P.NL = P.N0) {k : Nat}
    (hk0 : P.N0 ≤ k) (hk : k ≤ x.mlx.nnext) : LoadR (P.raise k) NB M n x y :=
  ⟨hr.host, hr.hostReg, hr.hostLt, hr.cbr, hr.mlx.raise hb hk0 hk⟩

end

/-! ## The deciders under a raise -/

theorem clApplyG_raise {P : LoadP} {x : NSt} {args : List Arg} {k : Nat} (h : P.NL ≤ k)
    (hc : NativeOk.clApplyG P x args = true) : NativeOk.clApplyG (P.raise k) x args = true := by
  unfold NativeOk.clApplyG at hc ⊢
  revert hc
  split
  · simp only [Bool.and_eq_true]
    intro ⟨h1, hc⟩
    refine ⟨h1, ?_⟩
    revert hc
    split
    · simp only [Bool.and_eq_true]
      intro ⟨h2, hc⟩
      refine ⟨h2, ?_⟩
      revert hc
      split
      · simp only [Bool.and_eq_true]
        intro ⟨h3, h4⟩
        exact ⟨rchk_mono h _ _ _ _ h3, h4⟩
      · exact id
    · exact id
  · exact id

theorem okCall_raise (P : LoadP) (k : Nat) : okCall (P.raise k) = okCall P := by
  funext l name args
  unfold okCall
  cases Host.Mlx.Ffi.symOf name with
  | none => rfl
  | some s => cases s <;> rfl

set_option maxRecDepth 20000 in
theorem okCallSG_raise {P : LoadP} {l : Host.Load.LSt} {name : Name} {args : List Arg} {k : Nat} (h : P.NL ≤ k)
    (hc : okCallSG P l name args = true) : okCallSG (P.raise k) l name args = true := by
  unfold okCallSG at hc ⊢
  rw [okCall_raise]
  simp only [Bool.or_eq_true] at hc ⊢
  rcases hc with hc | hc
  · exact .inl hc
  · right
    revert hc
    cases Host.Mlx.Ffi.symOf name with
    | none => exact id
    | some s =>
      dsimp only
      cases s
      all_goals first
        | exact id
        | (simp only [Bool.and_eq_true]; intro ⟨h1, h2⟩; exact ⟨h1, clApplyG_raise h h2⟩)

theorem symX_raise (P : LoadP) (k : Nat) : NativeOkX.sym (P.raise k) = NativeOkX.sym P := by
  funext x s args
  cases s <;> rfl

theorem okCallSX_raise {P : LoadP} {l : Host.Load.LSt} {name : Name} {args : List Arg} {k : Nat} (h : P.NL ≤ k)
    (hc : okCallSX P l name args = true) : okCallSX (P.raise k) l name args = true := by
  unfold okCallSX at hc ⊢
  rw [symX_raise]
  simp only [Bool.or_eq_true] at hc ⊢
  rcases hc with hc | hc
  · exact .inl (okCallSG_raise h hc)
  · exact .inr hc

theorem symShapeOk_raise (P : LoadP) (k : Nat) : symShapeOk (P.raise k) = symShapeOk P := by
  funext x name args
  unfold symShapeOk
  split <;> rfl

end Host.Ts.Sim.G

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim

theorem cloOk_raise (P : LoadP) (k : Nat) : cloOk (P.raise k) = cloOk P := by
  funext x name args
  unfold cloOk
  split
  · unfold G.NativeOkX.clo
    split
    · unfold G.NativeOkX.vset
      split <;> rfl
    · unfold G.NativeOkX.clRecord
      split <;> rfl
    · unfold G.NativeOkX.life
      split <;> rfl
  · rfl

theorem okCallFS_raise {P : LoadP} {x : FF.S} {name : Name} {args : List Arg} {k : Nat} (h : P.NL ≤ k)
    (hc : okCallFS P x name args = true) : okCallFS (P.raise k) x name args = true := by
  unfold okCallFS at hc ⊢
  rw [G.symShapeOk_raise, cloOk_raise]
  simp only [Bool.and_eq_true] at hc ⊢
  obtain ⟨⟨⟨⟨ha, hb⟩, hcc⟩, hd⟩, he⟩ := hc
  refine ⟨⟨⟨⟨ha, hb⟩, hcc⟩, ?_⟩, he⟩
  cases hp : G.symPath (mlxOf x) name args
  · rw [hp, Bool.cond_false] at hd
    rw [Bool.cond_false]
    simp only [Bool.or_eq_true] at hd ⊢
    rcases hd with hd | hd
    · exact .inl (G.okCallSX_raise h hd)
    · exact .inr hd
  · rw [hp, Bool.cond_true] at hd
    rw [Bool.cond_true]
    exact hd

/-! ## The full world's relation at a raise -/

/-- A raise of `P`: `P` itself or, for a band-free `P`, its band raised. -/
def Raised (P P' : LoadP) : Prop := P' = P ∨ ∃ k, P.NL = P.N0 ∧ P.N0 ≤ k ∧ P' = P.raise k

section
variable {P P' : LoadP}

theorem Raised.lo (h : Raised P P') : P'.lo = P.lo := by rcases h with rfl | ⟨k, -, -, rfl⟩ <;> rfl

theorem Raised.okCall {x : FF.S} {name : Name} {args : List Arg} (h : Raised P P')
    (hc : okCallFS P x name args = true) : okCallFS P' x name args = true := by
  rcases h with rfl | ⟨k, hb, hk, rfl⟩
  · exact hc
  · exact okCallFS_raise (by omega) hc

end

/-- **The full world's relation with raised bands**: `FullR` at a raise of `P`. -/
def FullRD (P : LoadP) (NB : Nat) (M : Map) (n : Nat) (x y : FF.S) : Prop :=
  ∃ P', Raised P P' ∧ FullR P' NB M n x y

theorem FullR.toD {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (h : FullR P NB M n x y) :
    FullRD P NB M n x y := ⟨P, .inl rfl, h⟩

theorem fullRD_laws (P : LoadP) (NB : Nat) : FRLaws (F := FF) (FullRD P NB) :=
  ⟨fun M M' n x y hr he => by
      obtain ⟨P', hP, hr⟩ := hr
      exact ⟨P', hP, (fullR_laws bridgeI_stable P' NB).stable M M' n x y hr he⟩,
   fun M n n' x y hr hn => by
      obtain ⟨P', hP, hr⟩ := hr
      exact ⟨P', hP, (fullR_laws bridgeI_stable P' NB).mono M n n' x y hr hn⟩⟩

/-- The native interface's reads at a raise. -/
theorem fullFfiSimD (P : LoadP) (NB : Nat) : FfiSim FF (FullRD P NB) (fun _ _ _ => false) (fun _ _ => false) where
  call := fun _ _ _ _ _ _ _ _ _ _ h => absurd h (by simp)
  back := fun _ _ _ _ _ _ _ _ _ h => absurd h (by simp)
  read := fun M n x y r off k bs hr hx => by
    obtain ⟨P', -, hr⟩ := hr
    exact (fullFfiSim (BR := BridgeI) P' NB).read M n x y r off k bs hr hx

theorem fullNativeFactsD (P : LoadP) (NB : Nat) (J : Disp.JSP FF) (hlo : J.lo = P.lo)
    (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion) : Disp.NativeFacts FF (FullRD P NB) J where
  zero := fun M n x y hr => by
    obtain ⟨P', hP, hr⟩ := hr
    exact (fullNativeFacts (BR := BridgeI) P' NB J (hlo.trans hP.lo.symm) hh hg).zero M n x y hr
  inj := fun M n x y hr => by
    obtain ⟨P', hP, hr⟩ := hr
    exact (fullNativeFacts (BR := BridgeI) P' NB J (hlo.trans hP.lo.symm) hh hg).inj M n x y hr
  region := fun M n x y hr => by
    obtain ⟨P', hP, hr⟩ := hr
    exact (fullNativeFacts (BR := BridgeI) P' NB J (hlo.trans hP.lo.symm) hh hg).region M n x y hr
  range := fun M n x y hr => by
    obtain ⟨P', hP, hr⟩ := hr
    exact (fullNativeFacts (BR := BridgeI) P' NB J (hlo.trans hP.lo.symm) hh hg).range M n x y hr
  host := fun M n x y hr => by
    obtain ⟨P', hP, hr⟩ := hr
    exact (fullNativeFacts (BR := BridgeI) P' NB J (hlo.trans hP.lo.symm) hh hg).host M n x y hr
  cb := fun M n x y hr => by
    obtain ⟨P', hP, hr⟩ := hr
    exact (fullNativeFacts (BR := BridgeI) P' NB J (hlo.trans hP.lo.symm) hh hg).cb M n x y hr

/-- **The native-call simulation at a raise**: the calls `okCallFS P` accepts, simulated at the raise. -/
theorem fullCallSimSD (P : LoadP) (NB : Nat) : FfiCallSim FF (FullRD P NB) (okCallFS P) smallFS where
  call := by
    intro M ν S C x y name args hsrv hr hok hsupp hsm
    obtain ⟨P', hP, hr⟩ := hr
    refine MSim.mono ((fullCallSimS P' NB).call M ν S C x y name args hsrv hr (hP.okCall hok) hsupp hsm) ?_
    intro M' S' C' r r' h
    obtain ⟨hg, hc⟩ := h
    refine ⟨hg, ?_⟩
    rcases r with _ | ⟨x', r1, ws⟩ <;> rcases r' with _ | ⟨y', r2, ws'⟩
    · trivial
    · trivial
    · exact hc
    · exact ⟨⟨P', hP, hc.1⟩, hc.2⟩


/-! ## Calls at the raise to the node counter -/

/-- **The accepted calls at a raise**: `okCallFS P`, or, for a band-free `P`, `okCallFS` at the band raised
to the template's node counter (a compiled closure applying a trace the run recorded). -/
def okCallFSD (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  okCallFS P x name args || (decide (P.NL = P.N0) && okCallFS (P.raise (mlxOf x).nnext) x name args)

/-- **The native-call simulation at a raise**, with the calls accepted at the raise to the node counter. -/
theorem fullCallSimSDD (P : LoadP) (NB : Nat) : FfiCallSim FF (FullRD P NB) (okCallFSD P) smallFS where
  call := by
    intro M ν S C x y name args hsrv hr hok hsupp hsm
    unfold okCallFSD at hok
    rw [Bool.or_eq_true] at hok
    rcases hok with hok | hok
    · exact (fullCallSimSD P NB).call M ν S C x y name args hsrv hr hok hsupp hsm
    · rw [Bool.and_eq_true, decide_eq_true_eq] at hok
      obtain ⟨hb, hok⟩ := hok
      obtain ⟨P', hP, hr⟩ := hr
      have hP' : P'.NL = P'.N0 ∧ P.N0 ≤ P'.N0 ∧ P'.raise (mlxOf x).nnext = P.raise (mlxOf x).nnext := by
        rcases hP with rfl | ⟨k, -, hk, rfl⟩
        · exact ⟨hb, Nat.le_refl _, rfl⟩
        · exact ⟨rfl, hk, rfl⟩
      obtain ⟨hb1, hb2, hb3⟩ := hP'
      have hn : P'.N0 ≤ (mlxOf x).nnext := hr.load.mlx.nband.2
      have hrr : FullR (P.raise (mlxOf x).nnext) NB M S.tab.length x y := by
        rw [← hb3]
        exact ⟨hr.load.raise hb1 hn (Nat.le_refl _), hr.bridge, hr.live, hr.kern, hr.pend⟩
      refine MSim.mono ((fullCallSimS (P.raise (mlxOf x).nnext) NB).call M ν S C x y name args hsrv hrr hok hsupp hsm) ?_
      intro M' S' C' r r' h
      obtain ⟨hg, hc⟩ := h
      refine ⟨hg, ?_⟩
      rcases r with _ | ⟨x', r1, ws⟩ <;> rcases r' with _ | ⟨y', r2, ws'⟩
      · trivial
      · trivial
      · exact hc
      · exact ⟨⟨_, .inr ⟨(mlxOf x).nnext, hb, Nat.le_trans hb2 hn, rfl⟩, hc.1⟩, hc.2⟩

/-- The full world's acceptance parameters at a raise. -/
abbrev fullJSPXD (P : LoadP) (VB : Nat → Nat) (framed : List Nat) (wide : List (Nat × WFrame) := []) : Disp.JSP FF :=
  { okCall := okCallFSD P, smallB := smallFSB VB, lo := P.lo, hi := P.E, framed := framed,
    isHandle := fullIsHandle, isRegion := fullIsRegion, wide := wide }

/-- **The one-step theorem of the full world at a raise**, under frames `W` and a stack base. -/
theorem fullStepSimXBD (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXVB FF (FullRD P NB) (Disp.okJS J) (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullRD P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimSD P NB
  exact Disp.stepSimXVB (fullFfiSimD P NB) hC
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullRD_laws P NB) fullLawful (fullNativeFactsD P NB J hlo hh hg) hW

/-- **The one-step theorem of the full world at a raise.** -/
theorem fullStepSimXD (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) :
    Disp.StepSimXV FF (FullRD P NB) (Disp.okJS J) (Disp.Kp J) (VBOkF VB) :=
  ((fullStepSimXBD P NB VB J hJ hsm hlo hh hg [] Disp.Wp.free).nil).free

end Host.Ts.Sim.Full
