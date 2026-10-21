import host.sim.dispatch.DecideProps
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Deciders for the side conditions of steps/Builtins.lean

`PlainElemsOK`, `InclOK`, `SvzOK`, `MapGetOK`, `NumberOK`, `BigIntOK` (pointer
arguments into JS memory are rejected: their condition mentions the counter offset
`K.D`, which the source does not know), `EntriesOK` and `HasOwnOK`. -/

section
variable {F : Ffi} (P : JSP F)

/-- `PlainElemsOK`. -/
def plainElemsB {S' : Type} (s : St S') (v : Val) : Bool :=
  match v with
  | .obj a => frB P a && (match s.obj? a with
    | some o => match o.kind with
      | .typed _ _ _ _ => false
      | _ => true
    | none => true)
  | _ => true

/-- `InclOK`. -/
def inclB {S' : Type} (s : St S') (this v : Val) : Bool :=
  match this with
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .array es => allB (fun x => strictB P x v) es
      | _ => true
    | none => true
  | _ => true

def isNaNB : F64 → Bool
  | .nan => true
  | _ => false

/-- `SvzOK`. -/
def svzB : Val → Val → Bool
  | .num (.lit _), .num (.lit _) => true
  | .num (.lit x), .num (.ref _) => !isNaNB x
  | .num (.ref _), .num (.lit y) => !isNaNB y
  | .num (.ref _), .num (.ref _) => false
  | x, y => strictB P x y

/-- `MapGetOK`. -/
def mapGetB {S' : Type} (s : St S') (this k : Val) : Bool :=
  match this with
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .map es => allB (fun p => svzB P p.1 k) es
      | _ => true
    | none => true
  | _ => true

/-- `BigIntOK` (JS-memory pointers rejected). -/
def bigIntB : Val → Bool
  | .ptr (.js _) _ => false
  | .ptr (.ext _) off => Nat.blt off 16777216
  | .num (.lit x) => match F64.toInt? x with
    | some i => bfB P i
    | none => true
  | .bool b => bfB P (bif b then 1 else 0)
  | .str cs => match parseBig cs with
    | some i => bfB P i
    | none => true
  | _ => true

/-- `EntriesOK`. -/
def entriesB (s : St F.S) (n : Nat) (v : Val) : Bool :=
  match v with
  | .obj a => frB P a && (match s.obj? a with
    | some o => (match o.kind with
        | .typed _ _ _ _ => allB (typedB P s n o) (ownKeys F s o)
        | _ => true) && Nat.ble (ownKeys F s o).length two20
    | none => true)
  | _ => true

/-- `HasOwnOK`. -/
def hasOwnB {S' : Type} (s : St S') (o k : Val) : Bool :=
  plainElemsB P s o && bfVB P k

end

section
variable {F : Ffi} {P : JSP F} {K : Ctx}

theorem Kp.plainElems (hK : Kp P K) {S' : Type} {s : St S'} {v : Val} (h : plainElemsB P s v = true) :
    PlainElemsOK K s v := by
  rintro a rfl
  simp only [plainElemsB, Bool.and_eq_true] at h
  refine ⟨hK.fr_none h.1, fun o ho k b off n hk => ?_⟩
  have h2 := h.2
  simp only [ho, hk] at h2
  cases h2

theorem Kp.incl (hK : Kp P K) {S' : Type} {s : St S'} {this v : Val} (h : inclB P s this v = true) :
    InclOK K s this v := by
  rintro a o es rfl ho hk x hx
  simp only [inclB, ho, hk] at h
  exact hK.strict (allB_sound h x hx)

theorem Kp.svz (hK : Kp P K) {x y : Val} (h : svzB P x y = true) : SvzOK K x y := by
  rcases x with _ | _ | _ | ⟨x | _⟩ | _ | _ | _ | _ | _ <;>
    rcases y with _ | _ | _ | ⟨y | _⟩ | _ | _ | _ | _ | _ <;>
    simp only [SvzOK] <;> simp only [svzB] at h <;>
    first
    | trivial
    | exact hK.strict h
    | (intro he; subst he; simp [isNaNB] at h)
    | (simp at h)

theorem Kp.mapGet (hK : Kp P K) {S' : Type} {s : St S'} {this k : Val} (h : mapGetB P s this k = true) :
    MapGetOK K s this k := by
  rintro a o es rfl ho hk p hp
  simp only [mapGetB, ho, hk] at h
  exact hK.svz (allB_sound h p hp)

theorem Kp.number (hK : Kp P K) {args : List Val} (h : bfVB P (arg args 0) = true) : NumberOK K args :=
  hK.bfBig h

theorem Kp.bigInt (hK : Kp P K) {next : Nat} {v : Val} (h : bigIntB P v = true) : BigIntOK K next v := by
  cases v with
  | bool b => exact hK.bf h
  | num x =>
    cases x with
    | lit x =>
      intro i hi
      simp only [bigIntB, hi] at h
      exact hK.bf h
    | ref _ => trivial
  | str cs =>
    intro i hi
    simp only [bigIntB, hi] at h
    exact hK.bf h
  | ptr m off =>
    cases m with
    | js _ => simp [bigIntB] at h
    | ext _ =>
      simp only [bigIntB, Nat.blt_eq] at h
      show off < 2 ^ 24
      omega
  | _ => trivial

theorem Kp.entries (hK : Kp P K) {s : St F.S} {S : SSrv} {v : Val} (h : entriesB P s S.tab.length v = true) :
    EntriesOK F K s S v := by
  rintro a rfl
  simp only [entriesB, Bool.and_eq_true] at h
  refine ⟨hK.fr_none h.1, fun o ho => ?_⟩
  have h2 := h.2
  simp only [ho, Bool.and_eq_true] at h2
  refine ⟨fun k hk => ?_, le20 h2.2⟩
  have h3 := h2.1
  cases hko : o.kind with
  | typed kk b off n =>
    simp only [hko] at h3
    exact hK.typed (allB_sound h3 k hk)
  | _ => exact typedOK_plainKind' (fun _ _ _ _ he => by rw [hko] at he; cases he)
where
  typedOK_plainKind' {s : St F.S} {S : SSrv} {o : Obj} {k : PKey}
      (hk : ∀ kk b off n, o.kind ≠ .typed kk b off n) : TypedOK F K s S o k :=
    fun kk b off n _ hko => absurd hko (hk kk b off n)

theorem Kp.hasOwn (hK : Kp P K) {S' : Type} {s : St S'} {o k : Val} (h : hasOwnB P s o k = true) :
    HasOwnOK K s o k := by
  simp only [hasOwnB, Bool.and_eq_true] at h
  have hp := hK.plainElems h.1
  exact ⟨fun a ha => hp a ha, hK.bfBig h.2⟩

end
end Host.Ts.Sim.Disp
