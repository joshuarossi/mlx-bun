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
  | .obj a => nwoB P s a && (match s.obj? a with
    | some o => match o.kind with
      | .map es => allB (fun p => svzB P p.1 k) es
      | _ => true
    | none => true)
  | _ => true

/-- `get` on a `mapKeys`-framed map at a string key it holds, not a ghost (`step_map_get_keys`). -/
def mapGetKeysB {S' : Type} (s : St S') (this k : Val) : Bool :=
  match this, k with
  | .obj a, .str cs => match wideAt P a, s.obj? a with
    | some (.mapKeys gs), some o => match o.kind with
      | .map es => !frB P a && (StringIndex.firstValue (pack cs) es).isSome && !memB (pack cs) gs
      | _ => false
    | _, _ => false
  | _, _ => false

/-- The map address, string key and source entries of a `Map` call on `this` with key `k`. -/
def mapStrOf {S' : Type} (s : St S') (this k : Val) : Option (Nat × List Char × List (Val × Val)) :=
  match this, k with
  | .obj a, .str cs => match s.obj? a with
    | some o => match o.kind with
      | .map es => some (a, cs, es)
      | _ => none
    | none => none
  | _, _ => none

/-- `set` with a string key on an unframed `Map`, a `Map` by key or a memo (`step_map_set`). -/
def mapSetB {S' : Type} (s : St S') (this k : Val) : Bool :=
  match mapStrOf s this k with
  | some (a, _, _) => frB P a || (match wideAt P a with
    | some (.mapKeys _) => true
    | some (.memo _) => true
    | _ => false)
  | none => false

/-- `set` on an unframed `Map` whose entry keys compare with the key alike (`step_map_set_svz`). -/
def mapSetSvzB {S' : Type} (s : St S') (this k : Val) : Bool :=
  match this with
  | .obj a => frB P a && (match s.obj? a with
    | some o => match o.kind with
      | .map es => allB (fun p => svzB P p.1 k) es
      | _ => false
    | none => false)
  | _ => false

/-- `has` with a string key on an unframed `Map`, on a `Map` by key holding it, on a memo when the
key is no ghost (`step_map_has`). -/
def mapHasB {S' : Type} (s : St S') (this k : Val) : Bool :=
  match mapStrOf s this k with
  | some (a, cs, es) => frB P a || (match wideAt P a with
    | some (.mapKeys _) => (StringIndex.firstValue (pack cs) es).isSome
    | some (.memo gs) => !memB (pack cs) gs
    | _ => false)
  | none => false

/-- `get` with a string key that is no ghost on a memo, held or not (`step_map_get_memo`). -/
def mapGetMemoB {S' : Type} (s : St S') (this k : Val) : Bool :=
  match mapStrOf s this k with
  | some (a, cs, _) => !frB P a && (match wideAt P a with
    | some (.memo gs) => !memB (pack cs) gs
    | _ => false)
  | none => false

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
    | some o => nsAllB P o && (match o.kind with
        | .typed _ _ _ _ => allB (typedB P s n o) (ownKeys F s o)
        | _ => true) && Nat.ble (ownKeys F s o).length two20
    | none => true)
  | _ => true

/-- `HasOwnOK`. -/
def hasOwnB {S' : Type} (s : St S') (o k : Val) : Bool :=
  plainElemsB P s o && bfVB P k && (match o with
    | .obj a => match s.obj? a with
      | some ob => nsAllB P ob
      | none => true
    | _ => true)

end

section
variable {F : Ffi} {P : JSP F} {K : Ctx} {W : Nat → Option WFrame} {stk : List Frame}

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

theorem Kp.mapGet (hK : Kp P K) (hW : Wp P W) {S' : Type} {s : St S'} {this k : Val}
    (h : mapGetB P s this k = true) : MapGetOK K W s this k := by
  refine ⟨?_, ?_⟩
  · rintro a o es rfl ho hk p hp
    simp only [mapGetB, ho, hk, Bool.and_eq_true] at h
    exact hK.svz (allB_sound h.2 p hp)
  · rintro a rfl
    simp only [mapGetB, Bool.and_eq_true] at h
    exact hK.noW hW h.1

theorem mapGetKeysB_sound {S' : Type} {s : St S'} {this k : Val} (h : mapGetKeysB P s this k = true) :
    ∃ a cs mo es gs, this = .obj a ∧ k = .str cs ∧ wideAt P a = some (.mapKeys gs) ∧ s.obj? a = some mo ∧
      mo.kind = .map es ∧ frB P a = false ∧ (StringIndex.firstValue (pack cs) es).isSome = true ∧
      pack cs ∉ gs := by
  unfold mapGetKeysB at h
  split at h
  · rename_i a cs
    split at h
    · rename_i gs o hw ho
      split at h
      · rename_i es hk
        simp only [Bool.and_eq_true, Bool.not_eq_true'] at h
        refine ⟨a, cs, o, es, gs, rfl, rfl, hw, ho, hk, h.1.1, h.1.2, fun hm => ?_⟩
        have := (memB_iff _ _).2 hm
        rw [this] at h
        exact absurd h.2 (by decide)
      · cases h
    · cases h
  · cases h

theorem mapStrOf_some {S' : Type} {s : St S'} {this k : Val} {a : Nat} {cs : List Char} {es : List (Val × Val)}
    (h : mapStrOf s this k = some (a, cs, es)) :
    this = .obj a ∧ k = .str cs ∧ ∃ mo, s.obj? a = some mo ∧ mo.kind = .map es := by
  unfold mapStrOf at h
  split at h
  · split at h
    · rename_i mo hmo
      split at h
      · rename_i es' hk
        cases h
        exact ⟨rfl, rfl, mo, hmo, hk⟩
      · cases h
    · cases h
  · cases h

theorem memB_false {c : Nat} {gs : List Nat} (h : (!memB c gs) = true) : c ∉ gs := fun hm => by
  have := (memB_iff _ _).2 hm
  rw [this] at h
  cases h

theorem mapSetB_sound {S' : Type} {s : St S'} {this k : Val} (h : mapSetB P s this k = true) :
    ∃ a cs es mo, this = .obj a ∧ k = .str cs ∧ s.obj? a = some mo ∧ mo.kind = .map es ∧
      (frB P a = true ∨ (frB P a = false ∧ ∃ gs, wideAt P a = some (.mapKeys gs) ∨ wideAt P a = some (.memo gs))) := by
  unfold mapSetB at h
  cases hm : mapStrOf s this k with
  | none => rw [hm] at h; cases h
  | some x =>
    obtain ⟨a, cs, es⟩ := x
    rw [hm] at h
    obtain ⟨rfl, rfl, mo, hmo, hmk⟩ := mapStrOf_some hm
    refine ⟨a, cs, es, mo, rfl, rfl, hmo, hmk, ?_⟩
    dsimp only at h
    cases hf : frB P a with
    | true => exact .inl rfl
    | false =>
      rw [hf, Bool.false_or] at h
      refine .inr ⟨rfl, ?_⟩
      split at h
      · rename_i gs hw; exact ⟨gs, .inl hw⟩
      · rename_i gs hw; exact ⟨gs, .inr hw⟩
      · cases h

theorem Kp.mapSetSvz (hK : Kp P K) {S' : Type} {s : St S'} {this k : Val} (h : mapSetSvzB P s this k = true) :
    ∃ a mo es, this = .obj a ∧ s.obj? a = some mo ∧ mo.kind = .map es ∧ K.fr a = none ∧
      ∀ p ∈ es, SvzOK K p.1 k := by
  cases this with
  | obj a =>
    simp only [mapSetSvzB, Bool.and_eq_true] at h
    cases ho : s.obj? a with
    | none => rw [ho] at h; simp at h
    | some mo =>
      rw [ho] at h
      obtain ⟨kd, pr, ps, pv, e⟩ := mo
      cases kd with
      | map es => exact ⟨a, _, es, rfl, ho, rfl, hK.fr_none h.1, fun p hp => hK.svz (allB_sound h.2 p hp)⟩
      | _ => simp at h
  | _ => simp [mapSetSvzB] at h

theorem mapHasB_sound {S' : Type} {s : St S'} {this k : Val} (h : mapHasB P s this k = true) :
    ∃ a cs es mo, this = .obj a ∧ k = .str cs ∧ s.obj? a = some mo ∧ mo.kind = .map es ∧
      (frB P a = true ∨ (frB P a = false ∧ ∃ gs,
        (wideAt P a = some (.mapKeys gs) ∧ (StringIndex.firstValue (pack cs) es).isSome = true) ∨
          (wideAt P a = some (.memo gs) ∧ pack cs ∉ gs))) := by
  unfold mapHasB at h
  cases hm : mapStrOf s this k with
  | none => rw [hm] at h; cases h
  | some x =>
    obtain ⟨a, cs, es⟩ := x
    rw [hm] at h
    obtain ⟨rfl, rfl, mo, hmo, hmk⟩ := mapStrOf_some hm
    refine ⟨a, cs, es, mo, rfl, rfl, hmo, hmk, ?_⟩
    dsimp only at h
    cases hf : frB P a with
    | true => exact .inl rfl
    | false =>
      rw [hf, Bool.false_or] at h
      refine .inr ⟨rfl, ?_⟩
      split at h
      · rename_i gs hw; exact ⟨gs, .inl ⟨hw, h⟩⟩
      · rename_i gs hw; exact ⟨gs, .inr ⟨hw, memB_false h⟩⟩
      · cases h

theorem mapGetMemoB_sound {S' : Type} {s : St S'} {this k : Val} (h : mapGetMemoB P s this k = true) :
    ∃ a cs es mo gs, this = .obj a ∧ k = .str cs ∧ s.obj? a = some mo ∧ mo.kind = .map es ∧
      frB P a = false ∧ wideAt P a = some (.memo gs) ∧ pack cs ∉ gs := by
  unfold mapGetMemoB at h
  cases hm : mapStrOf s this k with
  | none => rw [hm] at h; cases h
  | some x =>
    obtain ⟨a, cs, es⟩ := x
    rw [hm] at h
    obtain ⟨rfl, rfl, mo, hmo, hmk⟩ := mapStrOf_some hm
    simp only [Bool.and_eq_true, Bool.not_eq_true'] at h
    obtain ⟨hf, h⟩ := h
    split at h
    · rename_i gs hw; exact ⟨a, cs, es, mo, gs, rfl, rfl, hmo, hmk, hf, hw, memB_false h⟩
    · cases h

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

theorem Kp.entries (hK : Kp P K) (hW : Wp P W) {s : St F.S} {S : SSrv} {v : Val}
    (h : entriesB P s S.tab.length v = true) : EntriesOK F K W s S v := by
  rintro a rfl
  simp only [entriesB, Bool.and_eq_true] at h
  refine ⟨hK.fr_none h.1, fun o ho => ?_⟩
  have h2 := h.2
  simp only [ho, Bool.and_eq_true] at h2
  refine ⟨fun k hk => ⟨?_, hK.nsOK (s := s) hW h2.1.1 k⟩, le20 h2.2⟩
  have h3 := h2.1.2
  cases hko : o.kind with
  | typed kk b off n =>
    simp only [hko] at h3
    exact hK.typed (allB_sound h3 k hk)
  | _ => exact typedOK_plainKind' (fun _ _ _ _ he => by rw [hko] at he; cases he)
where
  typedOK_plainKind' {s : St F.S} {S : SSrv} {o : Obj} {k : PKey}
      (hk : ∀ kk b off n, o.kind ≠ .typed kk b off n) : TypedOK F K s S o k :=
    fun kk b off n _ hko => absurd hko (hk kk b off n)

theorem Kp.hasOwn (hK : Kp P K) (hW : Wp P W) {S' : Type} {s : St S'} {o k : Val}
    (h : hasOwnB P s o k = true) : HasOwnOK K W s o k := by
  simp only [hasOwnB, Bool.and_eq_true] at h
  have hp := hK.plainElems h.1.1
  refine ⟨fun a ha => ⟨(hp a ha).1, fun ob hob => ⟨(hp a ha).2 ob hob, ?_⟩⟩, hK.bfBig h.1.2⟩
  have h3 := h.2
  subst ha
  simp only [hob] at h3
  exact hK.nsAll (S' := S') hW h3

end
end Host.Ts.Sim.Disp
