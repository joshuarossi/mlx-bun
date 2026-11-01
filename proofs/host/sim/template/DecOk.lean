import host.sim.full.BridgeFrameS
import host.sim.template.FullOk
import host.sim.compose.Retab
import host.sim.template.DimVals
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The decode template's acceptance with its convolution dims abstracted

`DT3` holds the 48 `#conv` caches' `shape[1]` as variables 114 to 161, each worth 3, and the D1 traces' dims derived from them as 102 to 109. A convolution over such a cache and a compiled
closure applied to its output are accepted by `Full.okCallFSS`; their numeric premises hold only at those values (a convolution's
width has a lower bound). So the smallness here reads the variables at 3 (`pin`), for the valuations `VP`. -/

namespace Host.Load.Run.Tpl.DecOk
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template

/-- The abstracted convolution dims. -/
def isConv (v : Nat) : Bool := Nat.ble 114 v && Nat.ble v 161

theorem decVal_conv {v : Nat} (h : isConv v = true) : decVal v = some 3 := by
  unfold isConv at h
  unfold decVal
  rw [h]
  rfl

/-- The valuations of a decode chain: bounded, the abstracted dims at their values. -/
def VP (ν : Nat → F64) : Prop := VBOkF loopVB ν ∧ ∀ v k, decVal v = some k → ν v = F64.ofNat k

/-- Used only by the interval input, never by the operational server or native state. -/
def pin : Nat → SymE := fun v =>
  match decVal v with
  | some k => .lit (F64.ofNat k)
  | none => .var v

theorem eval_pin {ν : Nat → F64} (hν : VP ν) (e : SymE) : (e.subst pin).eval ν = e.eval ν := by
  rw [SymE.eval_subst]
  have hv : (fun i => (pin i).eval ν) = ν := by
    funext i
    unfold pin
    cases hi : decVal i with
    | none => rfl
    | some k => exact (hν.2 i k hi).symm
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

/-! ## The end of an iteration

Each iteration leaves a convolution cache one token longer and slices it back, so its dim is `int32((v + 1) - 1)`. At the valuations
`VP` that is `v` again, and the end's table may read it so (`RelB.retabEq`), which keeps the iteration's substitution the identity there. -/

/-- An entry `int32((v + 1) - 1)` of an abstracted dim, read as its variable. -/
def convBack : SymE → SymE
  | e@(.un .int32 (.bin .sub (.bin .add (.var v) (.lit a)) (.lit b))) =>
    bif isConv v && decide (a = F64.ofNat 1) && decide (b = F64.ofNat 1) then .var v else e
  | e => e

theorem convBack_eval {ν : Nat → F64} (hν : VP ν) (e : SymE) : (convBack e).eval ν = e.eval ν := by
  unfold convBack
  split
  · rename_i v a b
    cases hc : isConv v && decide (a = F64.ofNat 1) && decide (b = F64.ofNat 1) with
    | false => rw [cond_false]
    | true =>
      rw [cond_true]
      simp only [Bool.and_eq_true, decide_eq_true_eq] at hc
      obtain ⟨⟨hv, rfl⟩, rfl⟩ := hc
      exact (conv_entry_eval (hν.2 v 3 (decVal_conv hv))).symm
  · rfl

/-- The end's table with its abstracted dims read as their variables. -/
def convTab (S : SSrv) : SSrv := ⟨S.tab.map convBack, S.oracle⟩

theorem nth?_map_convBack (l : List SymE) (i : Nat) (e' : SymE) (h : nth? (l.map convBack) i = some e') :
    ∃ e, nth? l i = some e ∧ convBack e = e' := by
  induction l generalizing i with
  | nil => cases h
  | cons a l ih =>
    cases i with
    | zero => exact ⟨a, rfl, Option.some.inj h⟩
    | succ i => exact ih i h

/-- **The relation at that table.** -/
theorem retab {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Ctx} {s : St F.S} {S : SSrv} {t : St F.S} {C : CSrv} (hν : VP ν)
    (h : RelB F FR W stk M ν K s S t C) : RelB F FR W stk M ν K s (convTab S) t C :=
  h.retabEq (List.length_map _) rfl fun i e' he' => by
    obtain ⟨e, he, rfl⟩ := nth?_map_convBack S.tab i e' he'
    exact ⟨e, he, (convBack_eval hν e).symm⟩

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
