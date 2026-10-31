import host.sim.full.BridgeJs
import host.sim.template.a4pre_d1_dispatch.Frames
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.PostHeadSmall
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route Host.Load.Layers

/-- The already established singleton fact, in addition to the original variable bounds. -/
def VP (ν : Nat → F64) : Prop := VBOkF loopVB ν ∧ ν 10 = F64.ofNat 1

/-- Used only by the interval input, never by the operational server or native state. -/
def singleton : Nat → SymE := fun v => if v = 10 then .lit (F64.ofNat 1) else .var v

theorem eval_singleton {ν : Nat → F64} (hν : ν 10 = F64.ofNat 1) (e : SymE) :
    (e.subst singleton).eval ν = e.eval ν := by
  rw [SymE.eval_subst]
  have hv : (fun i => (singleton i).eval ν) = ν := by
    funext i
    by_cases hi : i = 10
    · subst hi; change F64.ofNat 1 = ν 10; exact hν.symm
    · simp only [singleton, if_neg hi, SymE.eval]
  rw [hv]

def refSmall (S : SSrv) (j : Nat) : Bool :=
  match nth? S.tab j with
  | some e => match ivlA loopVB (e.subst singleton) with
    | some (_, h) => decide (h < 2 ^ 31)
    | none => false
  | none => false

theorem refSmall_sound {ν : Nat → F64} {S : SSrv} {j : Nat}
    (hν : VP ν) (h : refSmall S j = true) : RefSmall ν S j := by
  unfold refSmall at h
  split at h
  · rename_i e he
    split at h
    · rename_i lo hi hb
      obtain ⟨k, -, hk, -, heval⟩ := ivlA_sound hν.1 (e.subst singleton) hb
      rw [eval_singleton hν.2] at heval
      exact ⟨e, k, he, heval, by have := of_decide_eq_true h; omega⟩
    · cases h
  · cases h

def smallLoad (S : SSrv) (x : Host.Load.LSt) (name : Name) (args : List Arg) : Bool :=
  (smallRefs x.mlx name args).all (refSmall S)

theorem smallLoad_sound {ν : Nat → F64} {S : SSrv} {x : Host.Load.LSt} {name : Name} {args : List Arg}
    (hν : VP ν) (h : smallLoad S x name args = true) : Host.Ts.Sim.smallLoad ν S x name args :=
  fun j hj => refSmall_sound hν (List.all_eq_true.mp h j hj)

def smallX (S : SSrv) (x : Host.Load.LSt) (name : Name) (args : List Arg) : Bool :=
  smallLoad S x name args && (G.smallRefsX x.mlx name args).all (refSmall S)

theorem smallX_sound {ν : Nat → F64} {S : SSrv} {x : Host.Load.LSt} {name : Name} {args : List Arg}
    (hν : VP ν) (h : smallX S x name args = true) : G.smallX ν S x name args := by
  simp only [smallX, Bool.and_eq_true] at h
  exact ⟨smallLoad_sound hν h.1, fun j hj => refSmall_sound hν (List.all_eq_true.mp h.2 j hj)⟩

-- Source-native result checks and the symbolic-shape/closure checks are unchanged.
def smallFX (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  smallX S (toLoad x) name args && (!isSymShape name || symRunOk S x name args)

theorem smallFX_sound {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : VP ν) (h : smallFX S x name args = true) : Full.smallFX ν S x name args := by
  simp only [smallFX, Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at h
  refine ⟨smallX_sound hν h.1, fun hs => ?_⟩
  rcases h.2 with h2 | h2
  · rw [hs] at h2; cases h2
  · exact symRunOk_sound h2

def smallFS (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif G.symPath (mlxOf x) name args then G.symShapeSmallB loopVB S (mlxOf x) name args
  else smallFX S x name args && G.cloSmallB loopVB S (mlxOf x) name args

theorem smallFS_sound {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : VP ν) (h : smallFS S x name args = true) : Full.smallFS ν S x name args := by
  unfold smallFS at h
  constructor
  · intro hp; rw [hp, Bool.cond_true] at h; exact G.symShapeSmallB_sound h hν.1
  · intro hp; rw [hp, Bool.cond_false, Bool.and_eq_true] at h
    exact ⟨smallFX_sound hν h.1, G.cloSmallB_sound hν.1 h.2⟩

@[irreducible] def smallFX2 (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif (bridgeOf x).active then smallFX S x name args && (!isSymShape name || aneRunOk S x name args) &&
    G.cloSmallB loopVB S (mlxOf x) name args
  else smallFS S x name args

theorem smallFX2_sound {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : VP ν) (h : smallFX2 S x name args = true) : Full.smallFX2 ν S x name args := by
  unfold smallFX2 at h
  constructor
  · intro ha; rw [ha, Bool.cond_false] at h; exact smallFS_sound hν h
  · intro ha
    rw [ha, Bool.cond_true, Bool.and_eq_true, Bool.and_eq_true] at h
    refine ⟨smallFX_sound hν h.1.1, fun hs => ?_, G.cloSmallB_sound hν.1 h.2⟩
    have := h.1.2
    rw [hs] at this
    simpa using this

/-- Exactly the old parameters, with only native-call numerical smallness refined. -/
abbrev J (bytes : List Byte) : Disp.JSP FF :=
  { D1Frames.typedJ bytes with smallB := smallFX2 }

noncomputable def ok (bytes : List Byte) : St FF.S → SSrv → Bool :=
  Disp.okJSJ (J bytes) (okBackFXS setupP) 4096

theorem context (bytes : List Byte) (K : Host.Ts.Sim.Ctx) :
    Disp.KpJ (J bytes) 4096 K ↔ Disp.KpJ (D1Frames.typedJ bytes) 4096 K := Iff.rfl

theorem wide (bytes : List Byte) (W : Nat → Option WFrame) :
    Disp.Wp (J bytes) W ↔ Disp.Wp (D1Frames.typedJ bytes) W := Iff.rfl

theorem wp (bytes : List Byte) : Disp.Wp (J bytes) (D1Frames.typedW bytes) := D1Frames.typed_wp bytes

end Host.Load.Run.Tpl.PostHeadSmall
