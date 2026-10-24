import host.sim.full.StepX
import host.sim.full.Restart
import host.sim.full.BackSim
import host.sim.dispatch.OkJs
import host.sim.BigJsRel
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers

/-! # The full world with JS pointer integers

* **The native relation under `withJs`** (`fullRB_withJs`): `FullRB` reads the map's bigints only at
  handles (below `2 ^ 46`: `G.MRw.hlt`, `hroom`), below `P.lo`, in `[P.E, 2 ^ 56)`, at the bigints the
  template's mlx state holds (`G.BigsOut`) and through `zero`; `M.withJs` agrees with `M` off the JS
  pointer band `[2^56, 2^56 + 2^61)` and keeps zeroness, so the relation holds under it when the
  template's mlx state holds no bigint in the band (`bigsOutB jsLoN jsHiN`).
* **The one-step theorems for `okJSJ`** (`fullStepSimXBJ`, `fullStepSimXLBJ`, `fullStepSimXLJ`,
  `fullJSPXStepSimJ`): `host.sim.full.StepX`'s at `Disp.stepSimX*J`, with the callback continuation's
  simulation `hB` (`Disp.FfiBackSim.none` when none is accepted).
* **The site lemma at `FullR`** (`RelB.afterJsFull`) and **the restart** (`restart_withJs`):
  `RelB.afterJs` with the native part by `fullRB_withJs`, the law in `Disp.FRJ`.
* **At a raise** (`FullRD`, `host.sim.full.Raise`) with the continuations `okBackF`
  (`fullBackSimD`): the one-step theorems for kernel-creating chains (`fullStepSimXBDJ`,
  `fullStepSimXLBDJ`, `fullStepSimXLDJ`: `okJSJ J (okBackF P) D0` over `Disp.FRJ (FullRD P NB)`),
  `fullRD_withJs`, the site lemma `RelB.afterJsFullD` and the restart's `restart_withJsD`. -/

/-- The JS pointer band `[2^56, 2^56 + 2^61)` as `Nat` bounds. -/
def jsLoN : Nat := 72057594037927936
def jsHiN : Nat := 2377900603251621888

theorem outB_js {i : Int} (h : outB jsLoN jsHiN i = true) : i < 72057594037927936 ∨ 2377900603251621888 ≤ i := by
  have h' : (!(decide ((72057594037927936 : Int) ≤ i ∧ i < 2377900603251621888))) = true := h
  rw [Bool.not_eq_true', decide_eq_false_iff_not] at h'
  by_cases h1 : (72057594037927936 : Int) ≤ i
  · exact .inr (Int.not_lt.mp fun h2 => h' ⟨h1, h2⟩)
  · exact .inl (Int.not_le.mp h1)

theorem outB_js_of {i : Int} (h : i < 72057594037927936) : outB jsLoN jsHiN i = true := by
  show (!(decide ((72057594037927936 : Int) ≤ i ∧ i < 2377900603251621888))) = true
  rw [Bool.not_eq_true', decide_eq_false_iff_not]
  rintro ⟨h1, -⟩
  omega

theorem outB_withJs (M : Map) : BAgree (fun i => outB jsLoN jsHiN i = true) M M.withJs where
  a := rfl
  num := rfl
  region := rfl
  node := rfl
  big := fun i hi => by
    apply Map.withJs_big
    apply jsPtrOf_none
    rcases outB_js hi with h | h
    · exact .inl h
    · exact .inr (by omega)

theorem withJs_zero (M : Map) (hz : ∀ i : Int, (M.big i == 0) = (i == 0)) (i : Int) :
    (M.withJs.big i == 0) = (i == 0) := by
  rw [Map.withJs_big_eq]
  cases hp : jsPtrOf i with
  | none => exact hz i
  | some q =>
    obtain ⟨b, off⟩ := q
    have h1 := (jsPtrOf_ge hp).1
    have h2 : (72057594037927936 : Int) ≤ ptrInt (.js (M.a b)) off := by
      rw [ptrInt_js]; exact Int.ofNat_le.mpr (Nat.le_add_right_of_le (Nat.le_add_right jsBase _))
    dsimp only
    rw [show (ptrInt (.js (M.a b)) off == 0) = false by simp only [beq_eq_false_iff_ne, ne_eq]; omega,
      show (i == 0) = false by simp only [beq_eq_false_iff_ne, ne_eq]; omega]

section
variable {M : Map} {x y : NSt}

/-- The template's handle counter is below `2 ^ 46`. -/
theorem next_lt {P : LoadP} {NB n : Nat} (hr : G.MRw P NB M n x y) : x.next < 2 ^ 46 ∧ P.lo ≤ x.next := by
  obtain ⟨h1, h2⟩ := hr.hroom
  obtain ⟨h3, h4⟩ := hr.hnext
  exact ⟨by omega, h3⟩

/-- A present handle is below `2 ^ 46`. -/
theorem handle_lt {P : LoadP} {NB n : Nat} (hr : G.MRw P NB M n x y) {h : Nat} (hp : PH x h) : h < 2 ^ 46 := by
  have h1 := hr.hlt h hp
  have h2 := (next_lt hr).1
  omega

theorem handle_withJs {h : Nat} (hh : h < 2 ^ 46) : M.withJs.handle h = M.handle h := by
  show (M.withJs.big (Int.ofNat h)).toNat = (M.big (Int.ofNat h)).toNat
  have e : (2 : Nat) ^ 46 < 72057594037927936 := by decide
  have h1 : h < 72057594037927936 := by omega
  have h2 : Int.ofNat h < 72057594037927936 := by simp only [Int.ofNat_eq_natCast]; exact_mod_cast h1
  rw [Map.withJs_big (jsPtrOf_none (.inl h2))]

theorem FreedR.withJs {P : LoadP} {NB n : Nat} (hr : G.MRw P NB M n x y) {fx fy : PTrie Unit}
    (h : FreedR M x y fx fy) : FreedR M.withJs x y fx fy :=
  ⟨h.obj, fun k hk => by rw [handle_withJs (handle_lt hr (.inr hk))]; exact h.img k hk, h.lt⟩

theorem KRecR.withJs {P : LoadP} {NB n n' : Nat} (hr : G.MRw P NB M n' x y) {kx ky : KRec}
    (h : KRecR M n x y kx ky) : KRecR M.withJs n x y kx ky :=
  { h with
    flags := fun k hk => by rw [handle_withJs (handle_lt hr (.inr hk))]; exact h.flags k hk
    targs := fun k hk => by rw [handle_withJs (handle_lt hr (.inr hk))]; exact h.targs k hk }

theorem _root_.Host.Ts.Sim.G.PendReg.withJs (hn : x.next < 2 ^ 46) (h : G.PendReg M x y) : G.PendReg M.withJs x y where
  reg p hp := by
    obtain ⟨h1, h2, h3⟩ := h.reg p hp
    have e1 := handle_withJs (M := M) (show p.id < 2 ^ 46 by omega)
    have e2 := handle_withJs (M := M) (show p.id - 1 < 2 ^ 46 by omega)
    exact ⟨h1, by rw [e1]; exact h2, by rw [e1, e2]; exact h3⟩
  fresh k hk := h.fresh k hk

end

/-- **`FullRB` under `withJs`**, where the template's mlx state holds no JS pointer integer. -/
theorem fullRB_withJs {BR : Map → FF.S → FF.S → Prop} (hBR : ∀ M x y, BR M x y → BR M.withJs x y)
    {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (h : FullRB BR P NB M n x y)
    (hb : bigsOutB jsLoN jsHiN (mlxOf x) = true) : FullRB BR P NB M.withJs n x y := by
  have hm := h.load.mlx
  have hw := hm.toMRw
  obtain ⟨hn46, hlx⟩ := next_lt hw
  have hlo : (P.lo : Int) < 72057594037927936 := by
    have : P.lo < 72057594037927936 := by have : (2 : Nat) ^ 46 < 72057594037927936 := by decide
                                          omega
    exact_mod_cast this
  have hQ : ∀ i : Int, i < 72057594037927936 → outB jsLoN jsHiN i = true := fun _ hi => outB_js_of hi
  have hag := outB_withJs M
  have hw' := hw.agreeB hag
    (fun i hi => hQ i (by omega))
    (fun i _ h2 => hQ i (by have e : (2 : Int) ^ 56 = 72057594037927936 := by decide
                            rw [e] at h2; exact h2))
    (fun k hk => hQ _ (by
      have h1 := handle_lt hw hk
      have e : (2 : Nat) ^ 46 < 72057594037927936 := by decide
      have h2 : k < 72057594037927936 := by omega
      simp only [Int.ofNat_eq_natCast]; exact_mod_cast h2))
    (withJs_zero M hw.zero) (bigsOutB_sound hb) P.rest
  refine ⟨⟨h.load.host, h.load.hostReg, h.load.hostLt, h.load.cbr,
    { hw' with
      hfreshB := fun k hk => by
        have hk46 : (mlxOf x).next + k < 2 ^ 46 := by
          obtain ⟨h1, h2⟩ := hw.hroom
          obtain ⟨h3, h4⟩ := hw.hnext
          change (mlxOf x).next + k < P.E at hk
          omega
        have e : (2 : Nat) ^ 46 < 72057594037927936 := by decide
        have h5 : (mlxOf x).next + k < 72057594037927936 := by omega
        have h6 : Int.ofNat ((mlxOf x).next + k) < 72057594037927936 := by
          simp only [Int.ofNat_eq_natCast]; exact_mod_cast h5
        rw [Map.withJs_big (jsPtrOf_none (.inl h6))]
        exact hm.hfreshB k hk
      tokensX := hm.tokensX }⟩, hBR _ _ _ h.bridge, ?_, ?_, h.pend.withJs hn46⟩
  · intro fx hx
    obtain ⟨fy, hy, hf⟩ := h.live fx hx
    exact ⟨fy, hy, hf.withJs hw⟩
  · intro kx hx
    obtain ⟨ky, hy, hk⟩ := h.kern kx hx
    exact ⟨ky, hy, hk.withJs hw⟩

/-- `fullRB_withJs` at the inactive bridge (`FullR`). -/
theorem fullR_withJs {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (h : FullR P NB M n x y)
    (hb : bigsOutB jsLoN jsHiN (mlxOf x) = true) : FullR P NB M.withJs n x y :=
  fullRB_withJs (fun _ _ _ h => h) h hb

/-! ## The one-step theorems for `okJSJ` -/

section
variable {P : LoadP} {NB : Nat} {VB : Nat → Nat} {J : Disp.JSP FF}

/-- `fullStepSimXB` for `okJSJ`: the law in `Disp.FRJ`, the offset bound in `Disp.KpJ`. -/
theorem fullStepSimXBJ (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (okBack : FF.S → Arg → Bool)
    (D0 : Nat) (hB : FfiBackSim FF (FullR P NB) okBack) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXVB FF (Disp.FRJ (FullR P NB)) (Disp.okJSJ J okBack D0) (Disp.KpJ J D0) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullR P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimS P NB
  exact Disp.stepSimXVBJ (fullFfiSim P NB) hB hC
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws bridgeI_stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- `fullStepSimXLB` for `okJSJ`. -/
theorem fullStepSimXLBJ (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (okBack : FF.S → Arg → Bool)
    (D0 : Nat) (hB : FfiBackSim FF (FullR P NB) okBack) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (Disp.FRJ (FullR P NB)) (Disp.okJSJ J okBack D0) (Disp.KpJ J D0) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullR P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimS P NB
  exact Disp.stepSimXLBJ (fullFfiSim P NB) hB hC
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws bridgeI_stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- `fullStepSimXL` for `okJSJ`. -/
theorem fullStepSimXLJ (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (okBack : FF.S → Arg → Bool)
    (D0 : Nat) (hB : FfiBackSim FF (FullR P NB) okBack) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) :
    Disp.StepSimXL FF (Disp.FRJ (FullR P NB)) (Disp.okJSJ J okBack D0) (Disp.KpJ J D0) (VBOkF VB) :=
  Disp.stepSimXLJ (fullFfiSim P NB) hB (by rw [hJ]; exact fullCallSimS P NB)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws bridgeI_stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg)

/-- `fullJSPXStepSim` for `okJSJ`. -/
theorem fullJSPXStepSimJ (P : LoadP) (NB : Nat) (VB : Nat → Nat) (framed : List Nat) (r : List NumV)
    (okBack : FF.S → Arg → Bool) (D0 : Nat) (hB : FfiBackSim FF (FLR P NB r) okBack) :
    Disp.StepSimXL FF (Disp.FRJ (FLR P NB r)) (Disp.okJSJ (fullJSPX P VB framed) okBack D0)
      (Disp.KpJ (fullJSPX P VB framed) D0) (VBOkF VB) :=
  fullStepSimXLJ { P with rest := r } NB VB (fullJSPX P VB framed) okBack D0 hB (okCallFS_rest P r).symm rfl rfl
    rfl rfl

end

/-! ## Sites -/

section
variable {W : Nat → Option WFrame} {stk : List Frame} {M N σ : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St FF.S} {S : SSrv} {C : CSrv} {P : LoadP} {NB : Nat}

/-- **The site lemma at `FullR`**: a relation under `N` (the names and band of `M.after σ`, `BigJs M`)
becomes one under `N.withJs` in `Disp.FRJ`, when the source passes `σ`'s check and its mlx state holds
no JS pointer integer. -/
theorem _root_.Host.Ts.Sim.RelB.afterJsFull (h : RelB FF (FullR P NB) W stk N ν K s S t C) (hM : BigJs M)
    (ha : N.a = (M.after σ).a) (hbig : ∀ i, jsPtrOf i ≠ none → N.big i = M.big (σ.big i)) (hlo : K.lo ≤ 2 ^ 56)
    (hchk : stateNoBigP (jsShiftBadB σ) K.base s = true) (hb : bigsOutB jsLoN jsHiN (mlxOf s.ffi) = true) :
    RelB FF (Disp.FRJ (FullR P NB)) W stk N.withJs ν K s S t C :=
  (h.afterJs hM ha hbig hlo hchk (fullR_withJs h.ffi hb)).toJ (BigJs.withJs N)

/-- `RelB.afterJsFull` with the check per present address and on the roots. -/
theorem _root_.Host.Ts.Sim.RelB.afterJsFullBlocks (h : RelB FF (FullR P NB) W stk N ν K s S t C) (hM : BigJs M)
    (ha : N.a = (M.after σ).a) (hbig : ∀ i, jsPtrOf i ≠ none → N.big i = M.big (σ.big i)) (hlo : K.lo ≤ 2 ^ 56)
    (hheap : ∀ a, Present s a → noBigAtP (jsShiftBadB σ) s a = true)
    (hroots : noBigRootsP (jsShiftBadB σ) K.base s = true) (hb : bigsOutB jsLoN jsHiN (mlxOf s.ffi) = true) :
    RelB FF (Disp.FRJ (FullR P NB)) W stk N.withJs ν K s S t C :=
  (h.afterJsBlocks hM ha hbig hlo hheap hroots (fullR_withJs h.ffi hb)).toJ (BigJs.withJs N)

end

/-- **The restart** (`full_restart_drop`) **with the law**: the restart map
`((M1.setNum _ v).after σ).rebig a P.E d` switched to its `withJs`, under the law of the end's map
`M1` and the template start's check for `σ`. -/
theorem restart_withJs {W : Nat → Option WFrame} {M1 σ : Map} {ν : Nat → F64} {K : Ctx} {s0 t : St FF.S}
    {S0 : SSrv} {C : CSrv} {P : LoadP} {NB : Nat} {r : List NumV} {m : Nat} {v : NumV} {a d : Nat}
    (h : RelF FF (FLR P NB r) W (((M1.setNum m v).after σ).rebig a P.E d) ν K s0 S0 t C) (hM : BigJs M1)
    (hE : P.E ≤ 2 ^ 56) (hlo : K.lo ≤ 2 ^ 56)
    (hchk : stateNoBigP (jsShiftBadB σ) K.base s0 = true) (hb : bigsOutB jsLoN jsHiN (mlxOf s0.ffi) = true) :
    RelF FF (Disp.FRJ (FLR P NB r)) W (((M1.setNum m v).after σ).rebig a P.E d).withJs ν K s0 S0 t C :=
  RelB.afterJsFull (M := M1.setNum m v) (σ := σ) h (fun b off hb hoff => hM b off hb hoff) rfl
    (fun _ hi => jsBig_rebig hE hi) hlo hchk hb

/-! ## `okJSK` without continuations (chains on a banded `P`) -/

section
variable {P : LoadP} {NB : Nat} {VB : Nat → Nat} {J : Disp.JSP FF}

/-- `fullStepSimXB` for `okJSK J (fun _ _ => false)`: `okJS` with `moreB` (`dispatch/Ext.lean`) and no
continuation accepted (`Disp.FfiBackSim.none`). -/
theorem fullStepSimXBK (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXVB FF (FullR P NB) (Disp.okJSK J (fun _ _ => false)) (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullR P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimS P NB
  exact Disp.stepSimXVBK (fullFfiSim P NB) Disp.FfiBackSim.none hC
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws bridgeI_stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- `fullStepSimXLB` for `okJSK J (fun _ _ => false)`. -/
theorem fullStepSimXLBK (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (FullR P NB) (Disp.okJSK J (fun _ _ => false)) (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullR P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimS P NB
  exact Disp.stepSimXLBK (fullFfiSim P NB) Disp.FfiBackSim.none hC
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws bridgeI_stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- `fullStepSimXL` for `okJSK J (fun _ _ => false)`. -/
theorem fullStepSimXLK (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) :
    Disp.StepSimXL FF (FullR P NB) (Disp.okJSK J (fun _ _ => false)) (Disp.Kp J) (VBOkF VB) :=
  Disp.stepSimXLK (fullFfiSim P NB) Disp.FfiBackSim.none (by rw [hJ]; exact fullCallSimS P NB)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws bridgeI_stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg)

end

/-! ## At a raise, with the continuations `okBackF` -/

theorem fullRD_withJs {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (h : FullRD P NB M n x y)
    (hb : bigsOutB jsLoN jsHiN (mlxOf x) = true) : FullRD P NB M.withJs n x y := by
  obtain ⟨P', hP, h⟩ := h
  exact ⟨P', hP, fullR_withJs h hb⟩

section
variable {P : LoadP} {NB : Nat} {VB : Nat → Nat} {J : Disp.JSP FF}

/-- **Kernel-creating chains at a raise**: `fullStepSimXBDK` for `okJSJ J (okBackF P) D0`, the law in
`Disp.FRJ (FullRD P NB)`, the offset bound in `Disp.KpJ J D0`. -/
theorem fullStepSimXBDJ (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (D0 : Nat)
    (hJ : J.okCall = okCallFSD P) (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo)
    (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame)
    (hW : Disp.Wp J W) :
    Disp.StepSimXVB FF (Disp.FRJ (FullRD P NB)) (Disp.okJSJ J (okBackF P) D0) (Disp.KpJ J D0) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullRD P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimSDD P NB
  exact Disp.stepSimXVBJ (fullFfiSimD P NB) (fullBackSimD P NB) hC
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullRD_laws P NB) fullLawful (fullNativeFactsD P NB J hlo hh hg) hW

/-- `fullStepSimXLBDK` for `okJSJ`. -/
theorem fullStepSimXLBDJ (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (D0 : Nat)
    (hJ : J.okCall = okCallFSD P) (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo)
    (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame)
    (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRD P NB)) (Disp.okJSJ J (okBackF P) D0) (Disp.KpJ J D0) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullRD P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimSDD P NB
  exact Disp.stepSimXLBJ (fullFfiSimD P NB) (fullBackSimD P NB) hC
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullRD_laws P NB) fullLawful (fullNativeFactsD P NB J hlo hh hg) hW

/-- `fullStepSimXLDK` for `okJSJ`. -/
theorem fullStepSimXLDJ (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (D0 : Nat)
    (hJ : J.okCall = okCallFSD P) (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo)
    (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion) :
    Disp.StepSimXL FF (Disp.FRJ (FullRD P NB)) (Disp.okJSJ J (okBackF P) D0) (Disp.KpJ J D0) (VBOkF VB) :=
  Disp.stepSimXLJ (fullFfiSimD P NB) (fullBackSimD P NB) (by rw [hJ]; exact fullCallSimSDD P NB)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullRD_laws P NB) fullLawful (fullNativeFactsD P NB J hlo hh hg)

end

section
variable {W : Nat → Option WFrame} {stk : List Frame} {M N σ : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St FF.S} {S : SSrv} {C : CSrv} {P : LoadP} {NB : Nat}

/-- `RelB.afterJsFull` at a raise. -/
theorem _root_.Host.Ts.Sim.RelB.afterJsFullD (h : RelB FF (FullRD P NB) W stk N ν K s S t C) (hM : BigJs M)
    (ha : N.a = (M.after σ).a) (hbig : ∀ i, jsPtrOf i ≠ none → N.big i = M.big (σ.big i)) (hlo : K.lo ≤ 2 ^ 56)
    (hchk : stateNoBigP (jsShiftBadB σ) K.base s = true) (hb : bigsOutB jsLoN jsHiN (mlxOf s.ffi) = true) :
    RelB FF (Disp.FRJ (FullRD P NB)) W stk N.withJs ν K s S t C :=
  (h.afterJs hM ha hbig hlo hchk (fullRD_withJs h.ffi hb)).toJ (BigJs.withJs N)

/-- `RelB.afterJsFullD` with the check per present address and on the roots. -/
theorem _root_.Host.Ts.Sim.RelB.afterJsFullDBlocks (h : RelB FF (FullRD P NB) W stk N ν K s S t C) (hM : BigJs M)
    (ha : N.a = (M.after σ).a) (hbig : ∀ i, jsPtrOf i ≠ none → N.big i = M.big (σ.big i)) (hlo : K.lo ≤ 2 ^ 56)
    (hheap : ∀ a, Present s a → noBigAtP (jsShiftBadB σ) s a = true)
    (hroots : noBigRootsP (jsShiftBadB σ) K.base s = true) (hb : bigsOutB jsLoN jsHiN (mlxOf s.ffi) = true) :
    RelB FF (Disp.FRJ (FullRD P NB)) W stk N.withJs ν K s S t C :=
  (h.afterJsBlocks hM ha hbig hlo hheap hroots (fullRD_withJs h.ffi hb)).toJ (BigJs.withJs N)

/-- A restart at a raise: its map `((M1.setNum m v).after σ).rebig a E d` (`E ≤ 2^56`) switched to `withJs`. -/
theorem restart_withJsD {M1 : Map} {m : Nat} {v : NumV} {a E d : Nat}
    (h : RelF FF (FullRD P NB) W (((M1.setNum m v).after σ).rebig a E d) ν K s S t C) (hM : BigJs M1)
    (hE : E ≤ 2 ^ 56) (hlo : K.lo ≤ 2 ^ 56)
    (hchk : stateNoBigP (jsShiftBadB σ) K.base s = true) (hb : bigsOutB jsLoN jsHiN (mlxOf s.ffi) = true) :
    RelF FF (Disp.FRJ (FullRD P NB)) W (((M1.setNum m v).after σ).rebig a E d).withJs ν K s S t C :=
  RelB.afterJsFullD (M := M1.setNum m v) (σ := σ) h (fun b off hb hoff => hM b off hb hoff) rfl
    (fun _ hi => jsBig_rebig hE hi) hlo hchk hb

end

end Host.Ts.Sim.Full
