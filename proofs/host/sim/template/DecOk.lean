import host.sim.full.BridgeFrameS
import host.sim.template.FullOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The decode template's acceptance with its convolution dims abstracted

`DT3` holds the 48 `#conv` caches' `shape[1]` as variables 114 to 161, each worth 3. A convolution over such a cache and a compiled
closure applied to its output are accepted by `Full.okCallFSS`; their numeric premises hold only at those values (a convolution's
width has a lower bound). So the smallness here reads the variables at 3 (`pin`), for the valuations `VP`. -/

namespace Host.Load.Run.Tpl.DecOk
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template

/-- The abstracted convolution dims. -/
def isConv (v : Nat) : Bool := Nat.ble 114 v && Nat.ble v 161

/-- The valuations of a decode chain: bounded, the convolution dims 3. -/
def VP (ν : Nat → F64) : Prop := VBOkF loopVB ν ∧ ∀ v, isConv v = true → ν v = F64.ofNat 3

/-- Used only by the interval input, never by the operational server or native state. -/
def pin : Nat → SymE := fun v => bif isConv v then .lit (F64.ofNat 3) else .var v

theorem eval_pin {ν : Nat → F64} (hν : VP ν) (e : SymE) : (e.subst pin).eval ν = e.eval ν := by
  rw [SymE.eval_subst]
  have hv : (fun i => (pin i).eval ν) = ν := by
    funext i
    cases hi : isConv i
    · simp only [pin, hi, cond_false, SymE.eval]
    · simp only [pin, hi, cond_true, SymE.eval]; exact (hν.2 i hi).symm
  rw [hv]

def refSmall (S : SSrv) (j : Nat) : Bool :=
  match nth? S.tab j with
  | some e => match ivlA loopVB (e.subst pin) with
    | some (_, h) => decide (h < 2 ^ 31)
    | none => false
  | none => false

theorem refSmall_sound {ν : Nat → F64} {S : SSrv} {j : Nat} (hν : VP ν) (h : refSmall S j = true) : RefSmall ν S j := by
  unfold refSmall at h
  split at h
  · rename_i e he
    split at h
    · rename_i lo hi hb
      obtain ⟨k, -, hk, -, heval⟩ := ivlA_sound hν.1 (e.subst pin) hb
      rw [eval_pin hν] at heval
      exact ⟨e, k, he, heval, by have := of_decide_eq_true h; omega⟩
    · cases h
  · cases h

def refGe (S : SSrv) (c j : Nat) : Bool :=
  match nth? S.tab j with
  | some e => match ivlA loopVB (e.subst pin) with
    | some (l, h) => decide (c ≤ l ∧ h < 2 ^ 31)
    | none => false
  | none => false

theorem refGe_sound {ν : Nat → F64} {S : SSrv} {c j : Nat} (hν : VP ν) (h : refGe S c j = true) : G.RefGe ν S c j := by
  unfold refGe at h
  split at h
  · rename_i e he
    split at h
    · rename_i l hi hi'
      obtain ⟨k, k1, k2, -, k4⟩ := ivlA_sound hν.1 (e.subst pin) hi'
      rw [eval_pin hν] at k4
      have := of_decide_eq_true h
      exact ⟨e, k, he, k4, by omega, by omega⟩
    · cases h
  · cases h

def symSmall (S : SSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  match Host.Mlx.Ffi.symOf name with
  | some .conv1d => match G.convRef x args with
    | some (j, c0) => refGe S c0 j
    | none => true
  | some .reshape => (G.reshRefs x args).all (refSmall S)
  | _ => true

theorem symSmall_sound {ν : Nat → F64} {S : SSrv} {x : NSt} {name : Name} {args : List Arg}
    (hν : VP ν) (h : symSmall S x name args = true) : G.symShapeSmall ν S x name args := by
  unfold symSmall at h
  unfold G.symShapeSmall
  split
  · rename_i hs
    rw [hs] at h
    intro j c0 hc
    simp only [hc] at h
    exact refGe_sound hν h
  · rename_i hs
    rw [hs] at h
    intro j hj
    exact refSmall_sound hν (List.all_eq_true.mp h j hj)
  · trivial

def cloSmallR (S : SSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  !G.cloSym x name args || ((G.cloRefs x args).all (refSmall S) && G.cloRunB S x name args)

theorem cloSmallR_sound {ν : Nat → F64} {S : SSrv} {x : NSt} {name : Name} {args : List Arg}
    (hν : VP ν) (h : cloSmallR S x name args = true) : G.cloSmall ν S x name args := by
  intro hc
  unfold cloSmallR at h
  rw [hc] at h
  simp only [Bool.not_true, Bool.false_or, Bool.and_eq_true] at h
  refine ⟨fun j hj => refSmall_sound hν (List.all_eq_true.mp h.1 j hj), fun r' S' hr' => ?_⟩
  have h2 := h.2
  unfold G.cloRunB at h2
  rw [hr'] at h2
  cases r'
  · cases h2
  · rfl

def smallX (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  ((smallRefs (Host.Load.Layers.toLoad x).mlx name args).all (refSmall S) &&
      (G.smallRefsX (Host.Load.Layers.toLoad x).mlx name args).all (refSmall S)) &&
    (!isSymShape name || symRunOk S x name args)

theorem smallX_sound {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : VP ν) (h : smallX S x name args = true) : Full.smallFX ν S x name args := by
  simp only [smallX, Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at h
  refine ⟨⟨fun j hj => refSmall_sound hν (List.all_eq_true.mp h.1.1 j hj),
    fun j hj => refSmall_sound hν (List.all_eq_true.mp h.1.2 j hj)⟩, fun hs => ?_⟩
  rcases h.2 with h2 | h2
  · rw [hs] at h2; cases h2
  · exact symRunOk_sound h2

def smallS (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif G.symPath (mlxOf x) name args then symSmall S (mlxOf x) name args
  else smallX S x name args && cloSmallR S (mlxOf x) name args

theorem smallS_sound {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : VP ν) (h : smallS S x name args = true) : Full.smallFS ν S x name args := by
  unfold smallS at h
  constructor
  · intro hp; rw [hp, Bool.cond_true] at h; exact symSmall_sound hν h
  · intro hp; rw [hp, Bool.cond_false, Bool.and_eq_true] at h
    exact ⟨smallX_sound hν h.1, cloSmallR_sound hν h.2⟩

def cloSmallSR (S : SSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  !G.cloServer x name args || ((G.cloRefsS x args).all (refSmall S) && G.cloFoundS S x args && G.cloRunB S x name args)

theorem cloSmallSR_sound {ν : Nat → F64} {S : SSrv} {x : NSt} {name : Name} {args : List Arg}
    (hν : VP ν) (h : cloSmallSR S x name args = true) : G.cloSmallS ν S x name args := by
  intro hc
  unfold cloSmallSR at h
  rw [hc] at h
  simp only [Bool.not_true, Bool.false_or, Bool.and_eq_true] at h
  refine ⟨fun j hj => refSmall_sound hν (List.all_eq_true.mp h.1.1 j hj), h.1.2, fun r' S' hr' => ?_⟩
  have h2 := h.2
  unfold G.cloRunB at h2
  rw [hr'] at h2
  cases r'
  · cases h2
  · rfl

/-- The decider of `Full.smallFSS` at those valuations (irreducible, as `smallFSSB`). -/
@[irreducible] def smallD (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  smallS S x name args && cloSmallSR S (mlxOf x) name args

theorem smallD_sound {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : VP ν) (h : smallD S x name args = true) : Full.smallFSS ν S x name args := by
  unfold smallD at h
  rw [Bool.and_eq_true] at h
  exact ⟨smallS_sound hν h.1, cloSmallSR_sound hν h.2⟩

/-- A decode chain's acceptance parameters. -/
abbrev decJ (P : LoadP) (framed : List Nat) (wide : List (Nat × WFrame)) : Disp.JSP FF :=
  { Full.fullJSPXF P loopVB framed wide with smallB := smallD }

/-! ## The simulation -/

section
variable (P : LoadP) (NB : Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFSS P)
  (hsm : J.smallB = smallD) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
  (hg : J.isRegion = fullIsRegion)
include hJ hsm hlo hh hg

/-- `Full.fullStepSimXLBKFbS` at the valuations `VP`. -/
theorem stepSim (b0 : BSt) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (FullRFb b0 P NB) (Disp.okJSK J (fun _ _ => false)) (Disp.Kp J) W stk VP :=
  Disp.stepSimXLBK (fullFfiSim P NB) backSimNone (by rw [hJ]; exact fullCallSimFbS b0 P NB)
    (fun _ _ _ _ _ hν hb => smallD_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws (bridgeFb_names b0).stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- `Full.fullStepSimXLBKFbSQ` at the valuations `VP`. -/
theorem stepSimQ (b0 : BSt) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W)
    (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (FullRFb b0 P NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))
      (Disp.okJSK J (fun _ _ => false)) (Disp.Kp J) W stk VP := by
  have hC : FfiCallSim FF (FullRFb b0 P NB) J.okCall Full.smallFSS := by rw [hJ]; exact fullCallSimFbS b0 P NB
  have hQ := fullTargetPres (FR := FullRFb b0 P NB) (fun _ _ _ _ hr h hh => (hr.load.mlx.yabsent h hh).2) y0
  exact Disp.stepSimXLBK ((fullFfiSim P NB).liftQ fullLawful hQ) backSimNone (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => smallD_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws (bridgeFb_names b0).stable P NB).liftQ fullLawful (fullNativeFacts P NB J hlo hh hg).liftQ hW

end

end Host.Load.Run.Tpl.DecOk
