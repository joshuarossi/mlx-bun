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
    | some o => nsAllB P o && (match o.kind with
      | .typed _ _ _ _ => allB (typedB P s n o) (ownKeys F s o)
      | _ => true)
    | none => true)
  | _ => true

/-- `LookupNoW` of an iterator source's iterator. -/
def srcNoWB (s : St F.S) : IterSrc → Bool
  | .proto it _ => lookupNoWB P s it
  | .index _ _ => true

/-- `CellNoW` of a list of names. -/
def namesNoWB (env : Env) (ns : List Name) : Bool := allB (cellNoWB P env) ns

/-- The rest element of an exhausted object pattern. -/
def objRestPatB (s : St F.S) (n : Nat) (src : Val) (ps : List (Key × Pat)) (rest : Option Pat) : Bool :=
  match ps, rest with
  | [], some _ => restB P s n src && presB s aObjectProto
  | _, _ => true

end

section
variable {F : Ffi} {P : JSP F} {K : Ctx} {W : Nat → Option WFrame} {stk : List Frame}

theorem Kp.srcNoW (hK : Kp P K) (hW : Wp P W) {s : St F.S} {src : IterSrc} (h : srcNoWB P s src = true) :
    ∀ it nx, src = .proto it nx → LookupNoW F K W s it := by
  rintro it nx rfl
  exact hK.lookupNoW hW h

theorem Kp.namesNoW (hK : Kp P K) (hW : Wp P W) {env : Env} {ns : List Name} (h : namesNoWB P env ns = true) :
    ∀ n ∈ ns, CellNoW K W env n :=
  fun n hn => hK.cellNoW hW (allB_sound h n hn)

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

theorem Kp.objPat (hK : Kp P K) (hW : Wp P W) {s : St F.S} {S : SSrv} {src : Val} {ps : List (Key × Pat)}
    (h : objPatB P s S.tab.length src ps = true) : ObjPatOK F K W s S src ps := by
  rintro k p ps' key rfl hk
  simp only [objPatB, hk] at h
  exact hK.lookup hW h

theorem Kp.rest (hK : Kp P K) (hW : Wp P W) {s : St F.S} {S : SSrv} {src : Val}
    (h : restB P s S.tab.length src = true) : RestOK F K W s S src := by
  rintro a rfl
  simp only [restB, Bool.and_eq_true] at h
  refine ⟨hK.fr_none h.1, fun o ho k hk => ?_⟩
  have h2 := h.2
  simp only [ho, Bool.and_eq_true] at h2
  refine ⟨?_, hK.nsOK (s := s) hW h2.1 k⟩
  have h3 := h2.2
  cases hko : o.kind with
  | typed kk b off n =>
    simp only [hko] at h3
    exact hK.typed (allB_sound h3 k hk)
  | _ => exact typedOK_plainKind (fun _ _ _ _ he => by rw [hko] at he; cases he)

theorem Kp.objRestPat (hK : Kp P K) (hW : Wp P W) {s : St F.S} {S : SSrv} {src : Val} {ps : List (Key × Pat)}
    {rest : Option Pat} (h : objRestPatB P s S.tab.length src ps rest = true) :
    ps = [] → rest ≠ none → RestOK F K W s S src ∧ Present s aObjectProto := by
  rintro rfl hr
  cases rest with
  | none => exact absurd rfl hr
  | some _ =>
    simp only [objRestPatB, Bool.and_eq_true] at h
    exact ⟨hK.rest hW h.1, h.2⟩

end
end Host.Ts.Sim.Disp
