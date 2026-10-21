import host.sim.dispatch.DecideRetC
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.StmtSim

/-! # Deciders for the side conditions of steps/Loop.lean and steps/Bind.lean

`IdxOK` (index reads of `for…of`), `ObjPatOK` and `RestOK` (object patterns). -/

section
variable {F : Ffi} (P : JSP F)

/-- `IdxOK`. -/
def idxB (s : St F.S) (n : Nat) (v : Val) (i : Nat) : Bool :=
  match v with
  | .obj a => frB P a && (match s.obj? a with
    | some o => match o.kind with
      | .typed k b off len => !(Nat.blt i len) || (match bufBytes F s b with
        | some bs => cellReadB P n k (bs.drop (off + i * k.size))
        | none => true)
      | _ => true
    | none => true)
  | _ => true

/-- The index condition of a `for…of` body frame. -/
def srcIdxB (s : St F.S) (n : Nat) : IterSrc → Bool
  | .index x i => idxB P s n x i
  | .proto _ _ => true

/-- `ObjPatOK`. -/
def objPatB (s : St F.S) (n : Nat) (src : Val) : List (Key × Pat) → Bool
  | (k, _) :: _ => match keyOf k with
    | some key => lookupB P s n src key
    | none => true
  | [] => true

/-- `RestOK`. -/
def restB (s : St F.S) (n : Nat) (src : Val) : Bool :=
  match src with
  | .obj a => frB P a && (match s.obj? a with
    | some o => match o.kind with
      | .typed _ _ _ _ => allB (typedB P s n o) (ownKeys F s o)
      | _ => true
    | none => true)
  | _ => true

/-- The rest element of an exhausted object pattern. -/
def objRestPatB (s : St F.S) (n : Nat) (src : Val) (ps : List (Key × Pat)) (rest : Option Pat) : Bool :=
  match ps, rest with
  | [], some _ => restB P s n src && presB s aObjectProto
  | _, _ => true

end

section
variable {F : Ffi} {P : JSP F} {K : Ctx}

theorem Kp.idx (hK : Kp P K) {s : St F.S} {S : SSrv} {v : Val} {i : Nat}
    (h : idxB P s S.tab.length v i = true) : IdxOK F K s S v i := by
  rintro a rfl
  simp only [idxB, Bool.and_eq_true] at h
  refine ⟨hK.fr_none h.1, fun o ho k b off n hk hi bs hb => ?_⟩
  have h2 := h.2
  have hl : Nat.blt i n = true := by rw [Nat.blt_eq]; exact hi
  simp only [ho, hk, hl, Bool.not_true, Bool.false_or, hb] at h2
  exact hK.cellRead h2

theorem Kp.srcIdx (hK : Kp P K) {s : St F.S} {S : SSrv} {src : IterSrc}
    (h : srcIdxB P s S.tab.length src = true) : ∀ x i, src = .index x i → IdxOK F K s S x i := by
  rintro x i rfl
  exact hK.idx h

theorem Kp.objPat (hK : Kp P K) {s : St F.S} {S : SSrv} {src : Val} {ps : List (Key × Pat)}
    (h : objPatB P s S.tab.length src ps = true) : ObjPatOK F K s S src ps := by
  rintro k p ps' key rfl hk
  simp only [objPatB, hk] at h
  exact hK.lookup h

theorem Kp.rest (hK : Kp P K) {s : St F.S} {S : SSrv} {src : Val}
    (h : restB P s S.tab.length src = true) : RestOK F K s S src := by
  rintro a rfl
  simp only [restB, Bool.and_eq_true] at h
  refine ⟨hK.fr_none h.1, fun o ho k hk => ?_⟩
  have h2 := h.2
  simp only [ho] at h2
  cases hko : o.kind with
  | typed kk b off n =>
    simp only [hko] at h2
    exact hK.typed (allB_sound h2 k hk)
  | _ => exact typedOK_plainKind (fun _ _ _ _ he => by rw [hko] at he; cases he)

theorem Kp.objRestPat (hK : Kp P K) {s : St F.S} {S : SSrv} {src : Val} {ps : List (Key × Pat)}
    {rest : Option Pat} (h : objRestPatB P s S.tab.length src ps rest = true) :
    ps = [] → rest ≠ none → RestOK F K s S src ∧ Present s aObjectProto := by
  rintro rfl hr
  cases rest with
  | none => exact absurd rfl hr
  | some _ =>
    simp only [objRestPatB, Bool.and_eq_true] at h
    exact ⟨hK.rest h.1, h.2⟩

end
end Host.Ts.Sim.Disp
