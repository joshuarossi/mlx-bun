import host.sim.full.SymReshape
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out dimOf)
open Host.Mlx.Ffi.SymShape (callSym symShapeCall opOutSym inferSym cancelDims eraseDim isSym)

/-! # Accepting the calls the symbolic-shape layer completes

`symPath`: the call is a convolution over a symbolic length or a reshape with `-1` over symbolic
dimensions, which the model leaves to the symbolic-shape layer (decided from the template's state
and arguments alone). `symShapeOk`: the decider of those calls (`NativeOkX.conv1dS`,
`NativeOkX.reshapeS`); `symShapeSmall`: their numeric premise (the convolution length at least
`c₀`, `RefGe`; the reshape's input and given dimensions small), decided by `symShapeSmallB`.
`mlx_simSS`: the layer's completed calls of an accepted call simulate. -/

namespace NativeOkX
variable (P : LoadP) (x : NSt)

def conv1dS : List Arg → Bool
  | [o, a, w, st, pd, dl, gr, _] => hdOk x a && hdOk x w && natOk P st && natOk P pd && natOk P dl &&
    natOk P gr && out P x o &&
    match Host.Mlx.Ffi.arrIns x [a, w], Host.Mlx.Ffi.argNat st, Host.Mlx.Ffi.argNat pd, Host.Mlx.Ffi.argNat dl,
      Host.Mlx.Ffi.argNat gr with
    | some ins, some 1, some pad, some dil, some g => match Host.Mlx.Ffi.shapesOf x ins with
      | some [([_, .sym (.ref _), .lit c], _), ([_, .lit k, .lit ci], _)] =>
        decide (0 < g ∧ c = ci * g ∧ 0 ≤ (dil : Int) * (k - 1) - 2 * pad)
      | _ => false
    | _, _, _, _, _ => false
  | _ => false

def reshapeS : List Arg → Bool
  | [o, a, sh, n, _] => hdOk x a && dimsOk P sh n && out P x o &&
    match Host.Mlx.Ffi.arrIns x [a], Host.Mlx.Ffi.dimsArg sh n with
    | some ins, some new => match Host.Mlx.Ffi.shapesOf x ins with
      | some [(old, _)] => decide (new.filter (· = .lit (-1)) = [.lit (-1)]) && (old ++ new).any isSym &&
          (decide (old.take (givenOf new).length = givenOf new) || (cancelDims old (givenOf new)).isNone) &&
          (old.drop (givenOf new).length).all dimLit && old.all dimOkV && (givenOf new).all dimOkV &&
          decide (prodBnd old < 2 ^ 53) && decide (prodBnd (givenOf new) < 2 ^ 53)
      | _ => false
    | _, _ => false
  | _ => false

end NativeOkX

/-- The convolution's length reference and `c₀`. -/
def convRef (x : NSt) : List Arg → Option (Nat × Nat)
  | [_, a, w, _, pd, dl, _, _] => match Host.Mlx.Ffi.arrIns x [a, w], Host.Mlx.Ffi.argNat pd, Host.Mlx.Ffi.argNat dl with
    | some ins, some pad, some dil => match Host.Mlx.Ffi.shapesOf x ins with
      | some [([_, .sym (.ref j), .lit _], _), ([_, .lit k, .lit _], _)] =>
        some (j, ((dil : Int) * (k - 1) - 2 * pad).toNat)
      | _ => none
    | _, _, _ => none
  | _ => none

/-- A reshape with `-1` over symbolic dimensions. -/
def reshPath (x : NSt) : List Arg → Bool
  | [_, a, sh, n, _] => match Host.Mlx.Ffi.arrIns x [a], Host.Mlx.Ffi.dimsArg sh n with
    | some ins, some new => match Host.Mlx.Ffi.shapesOf x ins with
      | some [(old, _)] => decide (new.filter (· = .lit (-1)) = [.lit (-1)]) && (old ++ new).any isSym
      | _ => false
    | _, _ => false
  | _ => false

/-- The reshape's input references and its given dimensions'. -/
def reshRefs (x : NSt) : List Arg → List Nat
  | [_, a, sh, n, _] => (match Host.Mlx.Ffi.arrIns x [a] with
    | some ins => shRefs x ins
    | none => []) ++ dimsArgRefs sh n
  | _ => []

/-- **The calls the symbolic-shape layer completes.** -/
def symPath (x : NSt) (name : Name) (args : List Arg) : Bool :=
  match Host.Mlx.Ffi.symOf name with
  | some .conv1d => (convRef x args).isSome
  | some .reshape => reshPath x args
  | _ => false

/-- **Their decider.** -/
def symShapeOk (P : LoadP) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  match Host.Mlx.Ffi.symOf name with
  | some .conv1d => NativeOkX.conv1dS P x args
  | some .reshape => NativeOkX.reshapeS P x args
  | _ => false

/-- **Their numeric premise.** -/
def symShapeSmall (ν : Nat → F64) (S : SSrv) (x : NSt) (name : Name) (args : List Arg) : Prop :=
  match Host.Mlx.Ffi.symOf name with
  | some .conv1d => ∀ j c0, convRef x args = some (j, c0) → RefGe ν S c0 j
  | some .reshape => ∀ j ∈ reshRefs x args, RefSmall ν S j
  | _ => True

def symShapeSmallB (VB : Nat → Nat) (S : SSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  match Host.Mlx.Ffi.symOf name with
  | some .conv1d => match convRef x args with
    | some (j, c0) => refGeB VB S c0 j
    | none => true
  | some .reshape => (reshRefs x args).all (refSmallB VB S)
  | _ => true

theorem symShapeSmallB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : NSt} {name : Name}
    {args : List Arg} (h : symShapeSmallB VB S x name args = true) (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) :
    symShapeSmall ν S x name args := by
  unfold symShapeSmallB at h
  unfold symShapeSmall
  split
  · rename_i hs
    rw [hs] at h
    intro j c0 hc
    rw [hc] at h
    exact refGeB_sound h hν
  · rename_i hs
    rw [hs] at h
    exact fun j hj => refSmallB_sound (List.all_eq_true.mp h j hj) hν
  · trivial

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

/-- **The layer's completed calls of an accepted call simulate.** -/
theorem mlx_simSS (args : List Arg) (hok : symShapeOk P x name args = true) (hsm : symShapeSmall ν S x name args) :
    MSim (MPost P NB M ν S C) S C (callSym x name args) (callSym y name (args.map M.arg)) := by
  unfold symShapeOk at hok
  unfold symShapeSmall at hsm
  split at hok
  · rename_i hsym
    rw [hsym] at hsm
    unfold NativeOkX.conv1dS at hok
    split at hok
    · rename_i o a w st pd dl gr e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨⟨⟨⟨ha, hw⟩, k1⟩, k2⟩, k3⟩, k4⟩, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins pad dil g h1 e1 e2 e3 e4
        split at hm
        · rename_i n j c dx oc k ci dw hsh
          simp only [decide_eq_true_eq] at hm
          obtain ⟨hg, hc, h0⟩ := hm
          have hcr : convRef x [o, a, w, st, pd, dl, gr, e] = some (j, ((dil : Int) * (k - 1) - 2 * pad).toNat) := by
            simp only [convRef, h1, e2, e3, hsh]
          exact sim_conv1dSym hs hr hsym ha hw ho hE hNE k1 k2 k3 k4 e1 e2 e3 e4 h1 hsh hg hc
            (Int.toNat_of_nonneg h0).symm (hsm _ _ hcr)
        · cases hm
      · cases hm
    · cases hok
  · rename_i hsym
    rw [hsym] at hsm
    unfold NativeOkX.reshapeS at hok
    split at hok
    · rename_i o a sh n e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨ha, hd⟩, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins new h1 h2
        split at hm
        · rename_i old d hsh
          simp only [Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq] at hm
          obtain ⟨⟨⟨⟨⟨⟨⟨hc, hg⟩, hcase⟩, hrest⟩, vo⟩, vg⟩, po⟩, pg⟩ := hm
          have hcase' : old.take (givenOf new).length = givenOf new ∨ cancelDims old (givenOf new) = none := by
            rcases hcase with h | h
            · exact .inl h
            · exact .inr (Option.isNone_iff_eq_none.mp h)
          have hsm' : ∀ j ∈ shRefs x ins, RefSmall ν S j := fun j hj =>
            hsm j (by simp only [reshRefs, h1]; exact List.mem_append_left _ hj)
          have hsg : ∀ j ∈ dimsArgRefs sh n, RefSmall ν S j := fun j hj =>
            hsm j (by simp only [reshRefs, h1]; exact List.mem_append_right _ hj)
          exact sim_reshapeNeg hs hr hsym ha hd ho hE hNE h1 h2 hsh hc hg hcase' hrest vo vg po pg hsm' hsg
        · cases hm
      · cases hm
    · cases hok
  · cases hok

end

end Host.Ts.Sim.G
