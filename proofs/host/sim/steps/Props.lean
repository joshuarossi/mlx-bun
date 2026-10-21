import host.sim.steps.Var
import host.sim.Ffi
namespace Host.Ts.Sim

/-! # Property access under the map

Simulation lemmas for the property and heap-access helpers (`Props.lean`, and
the element and equality helpers of `Builtins.lean`). Reads that ask no server
have `ReadPost` postconditions: the map and both servers are unchanged and the
target result is the image of the source result, which is supported. Helpers
that produce the next machine state have `StepPost` postconditions.

Side conditions (source-only): framed arrays are read only at keys other than
indices and `length` (`OwnOK`); typed-array element reads need `CellRead`;
writes need the written object unframed. Intrinsic prototypes need the map to
fix them (`Map.Intr`, not part of `Rel`). -/

/-! ## Lists and keys under the map -/

theorem nth?_map {α β : Type} (f : α → β) : ∀ (l : List α) (i : Nat), nth? (l.map f) i = (nth? l i).map f
  | [], _ => rfl
  | _ :: _, 0 => rfl
  | _ :: l, i + 1 => nth?_map f l i

theorem nth?_mem {α : Type} : ∀ {l : List α} {i : Nat} {a : α}, nth? l i = some a → a ∈ l
  | [], _, _, h => nomatch h
  | _ :: _, 0, _, h => by cases h; exact List.mem_cons_self ..
  | _ :: _, _ + 1, _, h => List.mem_cons_of_mem _ (nth?_mem h)

theorem lenL_map {α β : Type} (f : α → β) : ∀ (l : List α) (n : Nat), lenL (l.map f) n = lenL l n
  | [], _ => rfl
  | _ :: l, n => lenL_map f l (Nat.succ n)

theorem len_map {α β : Type} (f : α → β) (l : List α) : len (l.map f) = len l := lenL_map f l 0

theorem setNth_map {α β : Type} (f : α → β) (d : α) : ∀ (l : List α) (i : Nat) (a : α),
    (setNth d l i a).map f = setNth (f d) (l.map f) i (f a)
  | [], 0, _ => rfl
  | [], i + 1, a => by simp only [setNth, List.map_cons, List.map_nil, setNth_map f d [] i a]
  | _ :: _, 0, _ => rfl
  | b :: l, i + 1, a => by simp only [setNth, List.map_cons, setNth_map f d l i a]

theorem keyIndex_map (M : Map) (k : PKey) : keyIndex (M.key k) = keyIndex k := by
  cases k <;> rfl

theorem beq_iff {a b : Nat} : Nat.beq a b = true ↔ a = b :=
  ⟨Nat.eq_of_beq_eq_true, fun h => by subst h; exact Nat.beq_refl a⟩

private theorem blt_true {i n : Nat} (h : Nat.blt i n = true) : i < n := by rwa [Nat.blt_eq] at h
private theorem blt_false {i n : Nat} (h : Nat.blt i n = false) : ¬ i < n := by
  intro hi; rw [← Nat.blt_eq, h] at hi; cases hi

theorem Map.sym_lt (M : Map) {i : Nat} (hi : i < 16) : M.sym i = i := by
  unfold Map.sym
  cases hb : Nat.blt i 16
  · exact absurd hi (blt_false hb)
  · rfl

theorem Map.sym_ge (M : Map) {i : Nat} (hi : ¬ i < 16) : M.sym i = M.a (i - 16) + 16 := by
  unfold Map.sym
  cases hb : Nat.blt i 16
  · rfl
  · exact absurd (blt_true hb) hi

section
variable {A : Nat → Prop} {n : Nat} {M : Map}

/-- Supported symbols keep their equality: the map is injective on `A`. -/
theorem Map.sym_inj (hinj : ∀ a b, A a → A b → M.a a = M.a b → a = b) {i j : Nat}
    (hi : Supp.sym A n i) (hj : Supp.sym A n j) (h : M.sym i = M.sym j) : i = j := by
  by_cases hi16 : i < 16 <;> by_cases hj16 : j < 16
  · rwa [M.sym_lt hi16, M.sym_lt hj16] at h
  · rw [M.sym_lt hi16, M.sym_ge hj16] at h; omega
  · rw [M.sym_ge hi16, M.sym_lt hj16] at h; omega
  · rw [M.sym_ge hi16, M.sym_ge hj16] at h
    have := hinj _ _ (hi (by omega)) (hj (by omega)) (by omega)
    omega

theorem Map.key_code (hinj : ∀ a b, A a → A b → M.a a = M.a b → a = b) {k j : PKey}
    (hk : Supp.key A n k) (hj : Supp.key A n j) : (M.key k).code = (M.key j).code ↔ k.code = j.code := by
  cases k with
  | str a =>
    cases j with
    | str b => exact Iff.rfl
    | sym j => simp only [Map.key, PKey.code, Nat.mul_eq, Nat.succ_eq_add_one]; omega
  | sym i =>
    cases j with
    | str b => simp only [Map.key, PKey.code, Nat.mul_eq, Nat.succ_eq_add_one]; omega
    | sym j =>
      simp only [Map.key, PKey.code, Nat.mul_eq, Nat.succ_eq_add_one]
      constructor
      · intro h
        have := Map.sym_inj (n := n) hinj hk hj (by omega)
        omega
      · intro h
        have : i = j := by omega
        subst this; rfl

theorem keyEq_map (hinj : ∀ a b, A a → A b → M.a a = M.a b → a = b) {k j : PKey}
    (hk : Supp.key A n k) (hj : Supp.key A n j) : keyEq (M.key k) (M.key j) = keyEq k j := by
  show Nat.beq _ _ = Nat.beq _ _
  rw [Bool.eq_iff_iff, beq_iff, beq_iff]
  exact Map.key_code hinj hk hj

theorem keyEq_map_str (hinj : ∀ a b, A a → A b → M.a a = M.a b → a = b) {k : PKey}
    (hk : Supp.key A n k) (cs : List Char) : keyEq (M.key k) (.str cs) = keyEq k (.str cs) :=
  keyEq_map (j := .str cs) hinj hk trivial

theorem findPropLinear_map (hinj : ∀ a b, A a → A b → M.a a = M.a b → a = b) {k : PKey}
    (hk : Supp.key A n k) : ∀ {ps : Props}, Supp.props A n ps →
    findPropLinear (M.key k) (M.props ps) = (findPropLinear k ps).map M.prop
  | [], _ => rfl
  | (j, p) :: ps, hps => by
    have hj := (hps (j, p) (List.mem_cons_self ..)).1
    have ih := findPropLinear_map hinj hk (ps := ps) fun x hx => hps x (List.mem_cons_of_mem _ hx)
    show findPropLinear (M.key k) ((M.key j, M.prop p) :: M.props ps) = _
    rw [findPropLinear_cons, findPropLinear_cons]
    change brec (keyEq (M.key k) (M.key j)) _ _ = (brec (keyEq k j) _ _ : Option PropV).map M.prop
    rw [keyEq_map hinj hk hj]
    cases keyEq k j
    · exact ih
    · rfl

theorem findProp_map (hinj : ∀ a b, A a → A b → M.a a = M.a b → a = b) {k : PKey} {ps : Props}
    (hk : Supp.key A n k) (hps : Supp.props A n ps) :
    findProp (M.key k) (M.props ps) = (findProp k ps).map M.prop := by
  rw [findProp_eq_linear, findProp_eq_linear]
  exact findPropLinear_map hinj hk hps

theorem findPropLinear_supp {k : PKey} : ∀ {ps : Props} {p : PropV}, Supp.props A n ps →
    findPropLinear k ps = some p → Supp.prop A n p
  | [], _, _, h => nomatch h
  | (j, q) :: ps, p, hps, h => by
    rw [findPropLinear_cons] at h
    cases hb : Nat.beq k.code j.code
    · rw [hb] at h
      exact findPropLinear_supp (fun x hx => hps x (List.mem_cons_of_mem _ hx)) h
    · rw [hb] at h
      cases h
      exact (hps (j, q) (List.mem_cons_self ..)).2

theorem findProp_supp {k : PKey} {ps : Props} {p : PropV} (hps : Supp.props A n ps)
    (h : findProp k ps = some p) : Supp.prop A n p := by
  rw [findProp_eq_linear] at h
  exact findPropLinear_supp hps h

theorem setPropL_cons (k j : PKey) (p q : PropV) (ps : Props) :
    setPropL k p ((j, q) :: ps) = brec (keyEq k j) ((j, p) :: ps) ((j, q) :: setPropL k p ps) := rfl

theorem setPropL_map (hinj : ∀ a b, A a → A b → M.a a = M.a b → a = b) {k : PKey} (p : PropV)
    (hk : Supp.key A n k) : ∀ {ps : Props}, Supp.props A n ps →
    M.props (setPropL k p ps) = setPropL (M.key k) (M.prop p) (M.props ps)
  | [], _ => rfl
  | (j, q) :: ps, hps => by
    have hj := (hps (j, q) (List.mem_cons_self ..)).1
    have ih := setPropL_map hinj p hk (ps := ps) fun x hx => hps x (List.mem_cons_of_mem _ hx)
    show _ = setPropL (M.key k) (M.prop p) ((M.key j, M.prop q) :: M.props ps)
    rw [setPropL_cons, setPropL_cons, keyEq_map hinj hk hj]
    cases keyEq k j
    · show (M.key j, M.prop q) :: M.props (setPropL k p ps) = _
      rw [ih]
    · rfl

theorem setPropL_supp {k : PKey} {p : PropV} (hk : Supp.key A n k) (hp : Supp.prop A n p) :
    ∀ {ps : Props}, Supp.props A n ps → Supp.props A n (setPropL k p ps)
  | [], _ => fun x hx => by
    rcases List.mem_singleton.1 hx with rfl
    exact ⟨hk, hp⟩
  | (j, q) :: ps, hps => by
    have hj := (hps (j, q) (List.mem_cons_self ..)).1
    have hs : Supp.props A n ps := fun x hx => hps x (List.mem_cons_of_mem _ hx)
    rw [setPropL_cons]
    cases keyEq k j
    · intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · exact hps _ (List.mem_cons_self ..)
      · exact setPropL_supp hk hp hs x hx
    · intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · exact ⟨hj, hp⟩
      · exact hs x hx

end

/-! ## Private members and exports -/

/-- Image of a private-member list (as in `Map.obj`). -/
def Map.privs (M : Map) (l : List ((Nat × Name) × PropV)) : List ((Nat × Name) × PropV) :=
  l.map fun ((b, n), p) => ((M.a b, n), M.prop p)

theorem Map.obj_priv (M : Map) (o : Obj) : (M.obj o).priv = M.privs o.priv := rfl

/-- Support of a private-member list (as in `Supp.obj`). -/
def Supp.privs (A : Nat → Prop) (n : Nat) (l : List ((Nat × Name) × PropV)) : Prop :=
  ∀ x ∈ l, A x.1.1 ∧ Supp.prop A n x.2

theorem findExport_map (M : Map) (nm : Name) : ∀ ex : List (Name × Nat),
    findExport nm (List.map (fun x => (x.fst, M.a x.snd)) ex) = (findExport nm ex).map M.a
  | [] => rfl
  | (m, c) :: ex => by
    simp only [List.map_cons, findExport]
    cases nameEq nm m
    · exact findExport_map M nm ex
    · rfl

section
variable {A : Nat → Prop} {n : Nat} {M : Map}

theorem beq_map (hinj : ∀ a b, A a → A b → M.a a = M.a b → a = b) {a b : Nat} (ha : A a) (hb : A b) :
    Nat.beq (M.a a) (M.a b) = Nat.beq a b := by
  rw [Bool.eq_iff_iff, beq_iff, beq_iff]
  exact ⟨hinj a b ha hb, fun h => h ▸ rfl⟩

theorem findPriv_map (hinj : ∀ a b, A a → A b → M.a a = M.a b → a = b) {b : Nat} (nm : Name) (hb : A b) :
    ∀ {l : List ((Nat × Name) × PropV)}, Supp.privs A n l →
    findPriv (M.a b) nm (M.privs l) = (findPriv b nm l).map M.prop
  | [], _ => rfl
  | ((c, m), p) :: l, hl => by
    have hc := (hl _ (List.mem_cons_self ..)).1
    have ih := findPriv_map hinj nm hb (l := l) fun x hx => hl x (List.mem_cons_of_mem _ hx)
    show (bif Nat.beq (M.a b) (M.a c) && nameEq nm m then some (M.prop p) else findPriv (M.a b) nm (M.privs l)) =
      (bif Nat.beq b c && nameEq nm m then some p else findPriv b nm l).map M.prop
    rw [beq_map hinj hb hc]
    cases Nat.beq b c && nameEq nm m
    · exact ih
    · rfl

theorem findPriv_supp {b : Nat} {nm : Name} : ∀ {l : List ((Nat × Name) × PropV)} {p : PropV},
    Supp.privs A n l → findPriv b nm l = some p → Supp.prop A n p
  | [], _, _, h => nomatch h
  | ((c, m), q) :: l, p, hl, h => by
    change (bif privEq b nm (c, m) then some q else findPriv b nm l) = some p at h
    cases hb : privEq b nm (c, m)
    · rw [hb] at h
      exact findPriv_supp (fun x hx => hl x (List.mem_cons_of_mem _ hx)) h
    · rw [hb] at h
      cases h
      exact (hl _ (List.mem_cons_self ..)).2

theorem setPrivL_map (hinj : ∀ a b, A a → A b → M.a a = M.a b → a = b) {b : Nat} (nm : Name) (p : PropV)
    (hb : A b) : ∀ {l : List ((Nat × Name) × PropV)}, Supp.privs A n l →
    M.privs (setPrivL b nm p l) = setPrivL (M.a b) nm (M.prop p) (M.privs l)
  | [], _ => rfl
  | ((c, m), q) :: l, hl => by
    have hc := (hl _ (List.mem_cons_self ..)).1
    have ih := setPrivL_map hinj nm p hb (l := l) fun x hx => hl x (List.mem_cons_of_mem _ hx)
    show M.privs (bif Nat.beq b c && nameEq nm m then ((c, m), p) :: l else ((c, m), q) :: setPrivL b nm p l) =
      (bif Nat.beq (M.a b) (M.a c) && nameEq nm m then ((M.a c, m), M.prop p) :: M.privs l
        else ((M.a c, m), M.prop q) :: setPrivL (M.a b) nm (M.prop p) (M.privs l))
    rw [beq_map hinj hb hc]
    cases Nat.beq b c && nameEq nm m
    · show ((M.a c, m), M.prop q) :: M.privs (setPrivL b nm p l) = _
      rw [ih]
      rfl
    · rfl

theorem setPrivL_supp {b : Nat} {nm : Name} {p : PropV} (hb : A b) (hp : Supp.prop A n p) :
    ∀ {l : List ((Nat × Name) × PropV)}, Supp.privs A n l → Supp.privs A n (setPrivL b nm p l)
  | [], _ => fun x hx => by
    rcases List.mem_singleton.1 hx with rfl
    exact ⟨hb, hp⟩
  | ((c, m), q) :: l, hl => by
    have hs : Supp.privs A n l := fun x hx => hl x (List.mem_cons_of_mem _ hx)
    change Supp.privs A n (bif privEq b nm (c, m) then ((c, m), p) :: l else ((c, m), q) :: setPrivL b nm p l)
    cases privEq b nm (c, m)
    · intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · exact hl _ (List.mem_cons_self ..)
      · exact setPrivL_supp hb hp hs x hx
    · intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · exact ⟨(hl _ (List.mem_cons_self ..)).1, hp⟩
      · exact hs x hx

end

/-! ## Buffer bytes and typed-array cells -/

/-- A byte whose concrete value the map keeps: bigint parts must be fixed bigints. -/
def ByteFixed (K : Ctx) : Byte → Prop
  | .part _ (.big i) _ => BigFixed K.lo K.hi i
  | _ => True

/-- A typed-array element read from source bytes `bs` (from the element's offset on)
that the target reads as the image: the read cell is supported, and unless it is a
whole written cell, its bytes and (bigint) value are fixed by the map. -/
def CellRead (K : Ctx) (A : Nat → Prop) (n : Nat) (k : EltK) (bs : List Byte) : Prop :=
  ∀ c, readCell k bs = some c → Supp.cell A n c ∧
    ((wholeCell k (bs.take k.size) k.size).isSome = true ∨
      (∀ b ∈ bs.take k.size, ByteFixed K b) ∧ ∀ i, c = .big i → BigFixed K.lo K.hi i)

theorem partsFrom_map (M : Map) (k : EltK) : ∀ (bs : List Byte) (i n : Nat),
    wholeCell.partsFrom k (bs.map M.byte) i n = wholeCell.partsFrom k bs i n
  | [], _, _ => rfl
  | .lit _ :: _, _, _ => rfl
  | .part j c m :: rest, i, n => by
    simp only [List.map_cons, Map.byte, wholeCell.partsFrom, partsFrom_map M k rest]

theorem wholeCell_map (M : Map) (k : EltK) (bs : List Byte) (n : Nat) :
    wholeCell k (bs.map M.byte) n = (wholeCell k bs n).map M.cell := by
  match bs with
  | [] => rfl
  | .lit _ :: _ => rfl
  | .part j c 0 :: rest =>
    simp only [List.map_cons, Map.byte, wholeCell, partsFrom_map]
    cases kindEq j k && wholeCell.partsFrom k rest 1 n <;> rfl
  | .part j c (m + 1) :: rest => rfl

section
variable {K : Ctx} {M : Map} (hbig : ∀ i, BigFixed K.lo K.hi i → M.big i = i)
include hbig

theorem concByte_map {b : Byte} {x : Nat} (hb : concByte b = some x) (hf : ByteFixed K b) :
    concByte (M.byte b) = some x := by
  cases b with
  | lit _ => exact hb
  | part k c i =>
    cases c with
    | num v =>
      cases v with
      | lit y => exact hb
      | ref j => cases hb
    | big j =>
      show concByte (.part k (.big (M.big j)) i) = some x
      rw [hbig j hf]
      exact hb

theorem concBytes_map : ∀ {bs : List Byte} {ns : List Nat}, concBytes bs = some ns →
    (∀ b ∈ bs, ByteFixed K b) → concBytes (bs.map M.byte) = some ns
  | [], _, h, _ => h
  | b :: bs, ns, h, hf => by
    simp only [concBytes] at h
    cases hb : concByte b with
    | none => rw [hb] at h; cases h
    | some x =>
      rw [hb] at h
      cases hbs : concBytes bs with
      | none => rw [hbs] at h; cases h
      | some ys =>
        rw [hbs] at h
        rw [List.map_cons, concBytes, concByte_map hbig hb (hf b (List.mem_cons_self ..)),
          concBytes_map hbs (fun b hb => hf b (List.mem_cons_of_mem _ hb))]
        exact h

theorem decodeCell_fixed (k : EltK) (ns : List Nat)
    (hf : ∀ i, decodeCell k ns = .big i → BigFixed K.lo K.hi i) :
    M.cell (decodeCell k ns) = decodeCell k ns := by
  cases k <;> simp only [decodeCell, Map.cell, Map.nv] at hf ⊢
  · rw [hbig _ (hf _ rfl)]
  · rw [hbig _ (hf _ rfl)]

theorem readCell_map {k : EltK} {bs : List Byte} {c : Cell} (hc : readCell k bs = some c)
    (hok : (wholeCell k (bs.take k.size) k.size).isSome = true ∨
      (∀ b ∈ bs.take k.size, ByteFixed K b) ∧ ∀ i, c = .big i → BigFixed K.lo K.hi i) :
    readCell k (bs.map M.byte) = some (M.cell c) := by
  unfold readCell at hc ⊢
  dsimp only at hc ⊢
  rw [← List.map_take, wholeCell_map]
  cases hw : wholeCell k (bs.take k.size) k.size with
  | some c0 =>
    rw [hw] at hc
    cases hc
    rfl
  | none =>
    rw [hw] at hc hok
    simp only [Option.isSome_none, Bool.false_eq_true, false_or] at hok
    cases hcb : concBytes (bs.take k.size) with
    | none => rw [hcb] at hc; cases hc
    | some ns =>
      rw [hcb] at hc
      simp only [Option.map_none, concBytes_map hbig hcb hok.1, Option.bind_some] at hc ⊢
      cases hl : Nat.beq (len ns) k.size
      · rw [hl] at hc; cases hc
      · rw [hl] at hc
        cases hc
        simp only [Bool.cond_true]
        rw [decodeCell_fixed hbig k ns hok.2]
end

theorem cellVal_map (M : Map) (c : Cell) : cellVal (M.cell c) = M.val (cellVal c) := by
  cases c <;> rfl

theorem Supp.cellVal {A : Nat → Prop} {n : Nat} {c : Cell} (h : Supp.cell A n c) :
    Supp.val A n (cellVal c) := by
  cases c
  · exact h
  · trivial

/-! ## Postconditions -/

/-- Postcondition of a server-free read: the map and both servers are unchanged
and the results are related by `R`. -/
def ReadPost {α β : Type} (M : Map) (S : SSrv) (C : CSrv) (R : α → β → Prop) :
    Map → SSrv → CSrv → α → β → Prop :=
  fun M' S' C' a b => M' = M ∧ S' = S ∧ C' = C ∧ R a b

def Supp.oprop (A : Nat → Prop) (n : Nat) : Option PropV → Prop
  | none => True
  | some p => Supp.prop A n p

/-- Looked-up properties: the target's is the image of the source's, which is supported. -/
def PropR (M : Map) (A : Nat → Prop) (n : Nat) (r r' : Option PropV) : Prop :=
  r' = r.map M.prop ∧ Supp.oprop A n r

theorem ReadPost.pure {α β : Type} {M : Map} {S : SSrv} {C : CSrv} {R : α → β → Prop} {a : α} {b : β}
    (hR : R a b) : MSim (ReadPost M S C R) S C (Host.Ts.M.pure a) (Host.Ts.M.pure b) :=
  MSim.pure ⟨rfl, rfl, rfl, hR⟩

theorem MSim.cond {α β : Type} {P : Map → SSrv → CSrv → α → β → Prop} {S : SSrv} {C : CSrv}
    (b : Bool) {m1 m2 : Host.Ts.M α} {m1' m2' : Host.Ts.M β} (h1 : MSim P S C m1 m1') (h2 : MSim P S C m2 m2') :
    MSim P S C (bif b then m1 else m2) (bif b then m1' else m2') := by
  cases b
  · exact h2
  · exact h1

/-- The intrinsic objects (allocated by `Init` below `aFirst`) keep their addresses.
Not part of `Rel`; every step that names an intrinsic address needs it. -/
def Map.Intr (M : Map) : Prop := ∀ a, a < aFirst → M.a a = a

/-! ## Side conditions of reads -/

/-- Typed-array element reads through `ownGet` of key `k` on `o`. -/
def TypedOK (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (o : Obj) (k : PKey) : Prop :=
  ∀ kk b off n i, o.kind = .typed kk b off n → keyIndex k = some i → i < n →
    ∀ bs, bufBytes F s b = some bs → CellRead K (Present s) S.tab.length kk (bs.drop (off + i * kk.size))

/-- Own property `k` of `o` at `a`: a framed array is read only at keys other than
indices and `length`; typed-array elements are `TypedOK`. -/
def OwnOK (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (a : Nat) (o : Obj) (k : PKey) : Prop :=
  (K.fr a = none ∨ keyIndex k = none ∧ keyEq k kLength = false) ∧ TypedOK F K s S o k

/-- `OwnOK` along the prototype chain of `a`, within `f` links. -/
def ChainOK (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (k : PKey) : Nat → Nat → Prop
  | 0, _ => True
  | f + 1, a => ∀ o, s.obj? a = some o → OwnOK F K s S a o k ∧ ∀ b, o.proto = .obj b → ChainOK F K s S k f b

/-- The side condition of `lookup`. -/
def LookupOK (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (recv : Val) (k : PKey) : Prop :=
  match recv with
  | .obj a => ChainOK F K s S k 16 a
  | .str _ => ChainOK F K s S k 16 aStringProto
  | v => ∀ p, protoOf F s v = some p → ChainOK F K s S k 16 p

theorem TypedOK.of_plain {F : Ffi} {K : Ctx} {s : St F.S} {S : SSrv} {o : Obj} {k : PKey}
    (hk : keyIndex k = none) : TypedOK F K s S o k :=
  fun _ _ _ _ _ _ hi => nomatch hk.symm.trans hi

/-- Keys other than indices and `length` need nothing along the chain. -/
theorem ChainOK.of_plain {F : Ffi} {K : Ctx} {s : St F.S} {S : SSrv} {k : PKey}
    (hk : keyIndex k = none) (hl : keyEq k kLength = false) : ∀ f a, ChainOK F K s S k f a
  | 0, _ => trivial
  | f + 1, _ => fun _ _ => ⟨⟨.inr ⟨hk, hl⟩, TypedOK.of_plain hk⟩, fun b _ => ChainOK.of_plain hk hl f b⟩

theorem LookupOK.of_plain {F : Ffi} {K : Ctx} {s : St F.S} {S : SSrv} {k : PKey}
    (hk : keyIndex k = none) (hl : keyEq k kLength = false) (recv : Val) : LookupOK F K s S recv k := by
  cases recv <;> first
    | exact ChainOK.of_plain hk hl 16 _
    | exact fun p _ => ChainOK.of_plain hk hl 16 p

/-! ## Reads -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

/-- Framed addresses hold arrays. -/
theorem Rel.framed_array (h : Rel F FR M ν K s S t C) {a : Nat} {o : Obj} {p : List Val × List Val}
    (ho : s.obj? a = some o) (hfr : K.fr a = some p) : ∃ es, o.kind = .array es := by
  obtain ⟨pre, pre'⟩ := p
  obtain ⟨_, _, xs, hk, _⟩ := h.obj?_framed ho hfr
  exact ⟨_, hk⟩

/-- An object that is not an array is not framed. -/
theorem Rel.fr_none (h : Rel F FR M ν K s S t C) {a : Nat} {o : Obj} (ho : s.obj? a = some o)
    (hk : ∀ es, o.kind ≠ .array es) : K.fr a = none := by
  cases hfr : K.fr a with
  | none => rfl
  | some p =>
    obtain ⟨es, he⟩ := h.framed_array ho hfr
    exact absurd he (hk es)

theorem Rel.bufBytes_some (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {b : Nat}
    {bs : List Byte} (hb : bufBytes F s b = some bs) : bufBytes F t (M.a b) = some (bs.map M.byte) := by
  unfold Host.Ts.bufBytes at hb ⊢
  cases ho : s.obj? b with
  | none => rw [ho] at hb; cases hb
  | some o =>
    rw [ho] at hb
    have hfr : K.fr b = none := h.fr_none ho fun es he => by
      obtain ⟨kd, pr, ps, pv, ex⟩ := o
      simp only at he
      subst he
      cases hb
    rw [h.obj? ho hfr]
    obtain ⟨kd, pr, ps, pv, ex⟩ := o
    cases kd <;> simp only [Map.obj, Map.kind] at hb ⊢ <;> try cases hb
    · rfl
    · exact hF.read _ _ _ _ _ _ _ _ h.ffi hb

theorem typedGet_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {kk : EltK} {b off n i : Nat}
    (hok : i < n → ∀ bs, bufBytes F s b = some bs →
      CellRead K (Present s) S.tab.length kk (bs.drop (off + i * kk.size))) :
    MSim (ReadPost M S C (PropR M (Present s) S.tab.length)) S C
      (typedGet F s kk b off n i) (typedGet F t kk (M.a b) off n i) := by
  unfold typedGet
  cases hlt : Nat.blt i n
  · exact ReadPost.pure ⟨rfl, trivial⟩
  · simp only [Bool.cond_true]
    cases hb : bufBytes F s b with
    | none => exact MSim.fail _ _
    | some bs =>
      rw [h.bufBytes_some hF hb]
      simp only
      cases hc : readCell kk (bs.drop (off + i * kk.size)) with
      | none => exact MSim.fail _ _
      | some c =>
        have hcr := hok (blt_true hlt) bs hb c hc
        rw [← List.map_drop, readCell_map h.bigFixed hc hcr.2]
        exact ReadPost.pure ⟨by simp only [Option.map_some, Map.prop, cellVal_map], Supp.cellVal hcr.1⟩

theorem ownGet_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {o : Obj} {k : PKey}
    (hso : Supp.obj (Present s) S.tab.length o) (hk : Supp.key (Present s) S.tab.length k)
    (hok : TypedOK F K s S o k) :
    MSim (ReadPost M S C (PropR M (Present s) S.tab.length)) S C
      (ownGet F s o k) (ownGet F t (M.obj o) (M.key k)) := by
  have hfp : findProp (M.key k) (M.props o.props) = (findProp k o.props).map M.prop :=
    findProp_map h.inj hk hso.2.2.1
  have hfps : Supp.oprop (Present s) S.tab.length (findProp k o.props) := by
    cases hf : findProp k o.props with
    | none => trivial
    | some p => exact findProp_supp hso.2.2.1 hf
  have hstr := keyEq_map_str h.inj hk
  have hkl : keyEq (M.key k) kLength = keyEq k kLength := hstr _
  have dflt : MSim (ReadPost M S C (PropR M (Present s) S.tab.length)) S C
      (Host.Ts.M.pure (findProp k o.props)) (Host.Ts.M.pure (findProp (M.key k) (M.props o.props))) :=
    ReadPost.pure ⟨hfp, hfps⟩
  have nat : ∀ (x : Nat) (w e : Bool), MSim (ReadPost M S C (PropR M (Present s) S.tab.length)) S C
      (Host.Ts.M.pure (some (.data (natV x) w e))) (Host.Ts.M.pure (some (.data (natV x) w e))) :=
    fun _ _ _ => ReadPost.pure ⟨rfl, trivial⟩
  obtain ⟨kd, pr, ps, pv, ex⟩ := o
  cases kd with
  | array es =>
    have hes : Supp.vals (Present s) S.tab.length es := hso.1
    simp only [ownGet, Map.obj, Map.kind, keyIndex_map, hkl]
    cases hi : keyIndex k with
    | some i =>
      refine ReadPost.pure ⟨?_, ?_⟩
      · rw [Map.vals, nth?_map, Option.map_map, Option.map_map]
        rfl
      · cases hn : nth? es i with
        | none => trivial
        | some v => exact hes v (nth?_mem hn)
    | none =>
      simp only
      rw [Map.vals, len_map]
      exact MSim.cond _ (nat _ _ _) dflt
  | typed kk b off n =>
    simp only [ownGet, Map.obj, Map.kind, keyIndex_map, hkl, hstr]
    cases hi : keyIndex k with
    | some i => exact typedGet_sim h hF fun hlt => hok kk b off n i rfl hi hlt
    | none =>
      simp only
      refine MSim.cond _ (nat _ _ _) (MSim.cond _ (nat _ _ _) (MSim.cond _ (nat _ _ _) (MSim.cond _ ?_ dflt)))
      exact ReadPost.pure ⟨rfl, hso.1⟩
  | buf bs =>
    simp only [ownGet, Map.obj, Map.kind, hstr]
    rw [len_map]
    exact MSim.cond _ (nat _ _ _) dflt
  | extBuf r o l =>
    simp only [ownGet, Map.obj, Map.kind, hstr]
    exact MSim.cond _ (nat _ _ _) dflt
  | map es =>
    simp only [ownGet, Map.obj, Map.kind, hstr]
    rw [Map.pairs, len_map]
    exact MSim.cond _ (nat _ _ _) dflt
  | set es =>
    simp only [ownGet, Map.obj, Map.kind, hstr]
    rw [Map.vals, len_map]
    exact MSim.cond _ (nat _ _ _) dflt
  | ns ex =>
    cases k with
    | sym i => exact ReadPost.pure ⟨rfl, trivial⟩
    | str nm =>
      simp only [ownGet, Map.obj, Map.kind, Map.key]
      rw [findExport_map]
      cases hx : findExport nm ex with
      | none => exact ReadPost.pure ⟨rfl, trivial⟩
      | some c =>
        simp only [Option.map_some]
        cases hc : s.cell? c with
        | none => exact MSim.fail _ _
        | some v =>
          rw [h.cell? hc]
          cases v with
          | none => exact MSim.fail _ _
          | some v => exact ReadPost.pure ⟨rfl, h.cell?_supp hc⟩
  | ordinary => exact dflt
  | fn c => exact dflt
  | view b o l => exact dflt
  | promise p => exact dflt
  | gen g a q => exact dflt
  | box v => exact dflt
  | iter v i m => exact dflt

/-- A framed array read at a key other than an index or `length`: the target array
keeps its own prefix, but the properties are images. -/
theorem ownGet_framed (h : Rel F FR M ν K s S t C) {o o' : Obj} {pre pre' : List Val} {k : PKey}
    (hfo : FramedObj M pre pre' o o') (hso : Supp.obj (Present s) S.tab.length o)
    (hk : Supp.key (Present s) S.tab.length k) (hi : keyIndex k = none) (hl : keyEq k kLength = false) :
    MSim (ReadPost M S C (PropR M (Present s) S.tab.length)) S C
      (ownGet F s o k) (ownGet F t o' (M.key k)) := by
  obtain ⟨xs, hkd, rfl⟩ := hfo
  have hfp : findProp (M.key k) (M.props o.props) = (findProp k o.props).map M.prop :=
    findProp_map h.inj hk hso.2.2.1
  have hfps : Supp.oprop (Present s) S.tab.length (findProp k o.props) := by
    cases hf : findProp k o.props with
    | none => trivial
    | some p => exact findProp_supp hso.2.2.1 hf
  have hkl : keyEq (M.key k) kLength = false := (keyEq_map_str h.inj hk _).trans hl
  unfold ownGet
  rw [hkd, keyIndex_map, hi, hkl, hl]
  exact ReadPost.pure ⟨hfp, hfps⟩

theorem getChain_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {k : PKey}
    (hk : Supp.key (Present s) S.tab.length k) : ∀ f a, ChainOK F K s S k f a →
    MSim (ReadPost M S C (PropR M (Present s) S.tab.length)) S C
      (getChain F s k f a) (getChain F t (M.key k) f (M.a a))
  | 0, _, _ => MSim.fail _ _
  | f + 1, a, hc => by
    rw [getChain.eq_2, getChain.eq_2]
    cases ho : s.obj? a with
    | none => exact MSim.fail _ _
    | some o =>
      obtain ⟨⟨hfr, hty⟩, hpr⟩ := hc o ho
      have hso := h.obj?_supp ho
      have key : ∃ o', t.obj? (M.a a) = some o' ∧ o'.proto = M.val o.proto ∧
          MSim (ReadPost M S C (PropR M (Present s) S.tab.length)) S C (ownGet F s o k) (ownGet F t o' (M.key k)) := by
        cases hf : K.fr a with
        | none => exact ⟨_, h.obj? ho hf, rfl, ownGet_sim h hF hso hk hty⟩
        | some p =>
          obtain ⟨pre, pre'⟩ := p
          obtain ⟨o', ho', hfo⟩ := h.obj?_framed ho hf
          have hpl : keyIndex k = none ∧ keyEq k kLength = false := by
            rcases hfr with hfr | hpl
            · rw [hf] at hfr; cases hfr
            · exact hpl
          refine ⟨o', ho', ?_, ownGet_framed h hfo hso hk hpl.1 hpl.2⟩
          obtain ⟨xs, _, rfl⟩ := hfo
          rfl
      obtain ⟨o', ho', hpro, hown⟩ := key
      have hsp : Supp.val (Present s) S.tab.length o.proto := hso.2.1
      rw [ho']
      refine MSim.bind hown ?_
      rintro M' S' C' r r' ⟨-, hS, hC, rfl, hsupp⟩
      rw [hS, hC]
      cases r with
      | some p => exact ReadPost.pure ⟨rfl, hsupp⟩
      | none =>
        rw [Option.map_none, hpro]
        cases hp : o.proto with
        | obj b =>
          rw [hp] at hsp
          exact getChain_sim h hF hk f b (hpr b hp)
        | _ => exact ReadPost.pure ⟨rfl, trivial⟩

theorem protoOf_map (M : Map) (v : Val) : protoOf F t (M.val v) = protoOf F s v := by
  cases v <;> rfl

theorem lookup_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hI : M.Intr)
    {recv : Val} {k : PKey} (hr : Supp.val (Present s) S.tab.length recv)
    (hk : Supp.key (Present s) S.tab.length k) (hok : LookupOK F K s S recv k) :
    MSim (ReadPost M S C (PropR M (Present s) S.tab.length)) S C
      (lookup F s recv k) (lookup F t (M.val recv) (M.key k)) := by
  have hpro : ∀ p, protoOf F s recv = some p → p < aFirst := by
    intro p hp
    cases recv <;> simp only [protoOf, Option.some.injEq, reduceCtorEq] at hp <;> subst hp <;> decide
  have prim : ∀ p, protoOf F s recv = some p → ChainOK F K s S k 16 p →
      MSim (ReadPost M S C (PropR M (Present s) S.tab.length)) S C
        (getChain F s k 16 p) (getChain F t (M.key k) 16 p) := by
    intro p hp hc
    have := getChain_sim h hF hk 16 p hc
    rwa [hI p (hpro p hp)] at this
  cases recv with
  | obj a => exact getChain_sim h hF hk 16 a hok
  | str cs =>
    have hkl : keyEq (M.key k) kLength = keyEq k kLength := keyEq_map_str h.inj hk _
    simp only [lookup, Map.val, keyIndex_map, hkl]
    cases hi : keyIndex k with
    | some i =>
      refine ReadPost.pure ⟨?_, ?_⟩
      · rw [Option.map_map]
        rfl
      · cases nth? cs i <;> trivial
    | none =>
      simp only
      refine MSim.cond _ (ReadPost.pure ⟨rfl, trivial⟩) ?_
      have := getChain_sim h hF hk 16 aStringProto hok
      rwa [hI aStringProto (by decide)] at this
  | undef => exact ReadPost.pure ⟨rfl, trivial⟩
  | null => exact ReadPost.pure ⟨rfl, trivial⟩
  | bool b => exact prim _ rfl (hok _ rfl)
  | num x => exact prim _ rfl (hok _ rfl)
  | big i => exact prim _ rfl (hok _ rfl)
  | sym i => exact prim _ rfl (hok _ rfl)
  | ptr m off => exact prim _ rfl (hok _ rfl)

/-- Running a looked-up property (`readProp`) on related states. -/
theorem Rel.read (h : Rel F FR M ν K s S t C) {recv : Val} {p : Option PropV}
    (hr : Supp.val (Present s) S.tab.length recv) (hp : Supp.oprop (Present s) S.tab.length p) :
    Rel F FR M ν K (readProp F s recv p) S (readProp F t (M.val recv) (p.map M.prop)) C := by
  rcases p with _ | ⟨v, w, e⟩ | ⟨g, st, e⟩
  · exact h.ret .undef trivial
  · exact h.ret v hp
  · cases g with
    | undef => exact h.ret .undef trivial
    | null => exact h.go (.call .null recv []) ⟨trivial, hr, fun _ hx => nomatch hx⟩
    | bool b => exact h.go (.call (.bool b) recv []) ⟨trivial, hr, fun _ hx => nomatch hx⟩
    | num x => exact h.go (.call (.num x) recv []) ⟨hp.1, hr, fun _ hx => nomatch hx⟩
    | big i => exact h.go (.call (.big i) recv []) ⟨trivial, hr, fun _ hx => nomatch hx⟩
    | str cs => exact h.go (.call (.str cs) recv []) ⟨trivial, hr, fun _ hx => nomatch hx⟩
    | sym i => exact h.go (.call (.sym i) recv []) ⟨hp.1, hr, fun _ hx => nomatch hx⟩
    | obj a => exact h.go (.call (.obj a) recv []) ⟨hp.1, hr, fun _ hx => nomatch hx⟩
    | ptr m off => exact h.go (.call (.ptr m off) recv []) ⟨hp.1, hr, fun _ hx => nomatch hx⟩

/-- A thrown error object with an intrinsic prototype the map fixes. -/
theorem throwErr_sim (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) {p : Nat} (hp : Present s p)
    (hpa : M.a p = p) (msg : List Char) :
    MSim (StepPost F FR M ν K S C) S C (throwErr s p msg) (throwErr t p msg) := by
  have hs64 : s.next < 2 ^ 64 := by
    have : Sim.bound = 2 ^ 61 := rfl
    omega
  let ps : Props := [(.str ['m','e','s','s','a','g','e'], .data (.str msg) true false)]
  have hps : Supp.props (Present (s.allocObj .ordinary (.obj p) ps).2) S.tab.length ps := fun x hx => by
    rcases List.mem_singleton.1 hx with rfl
    exact ⟨trivial, trivial⟩
  obtain ⟨heq, hrel⟩ := h.allocObj .ordinary (.obj p) ps hn trivial (Present.alloc _ hs64 hp) hps
  have e : t.allocObj .ordinary (.obj p) ps = t.allocObj (M.kind .ordinary) (M.val (.obj p)) (M.props ps) := by
    simp only [Map.kind, Map.val, hpa]
    rfl
  show MSim _ S C
    (Host.Ts.M.pure ((s.allocObj .ordinary (.obj p) ps).2.go (.abr (.throw (.obj (s.allocObj .ordinary (.obj p) ps).1)))))
    (Host.Ts.M.pure ((t.allocObj .ordinary (.obj p) ps).2.go (.abr (.throw (.obj (t.allocObj .ordinary (.obj p) ps).1)))))
  rw [e, heq]
  exact MSim.pure ⟨Grow.refl h.srv, hrel.go (.abr (.throw (.obj _))) (Present.alloc_next s _ hs64)⟩

theorem typeErr_sim (h : Rel F FR M ν K s S t C) (hI : M.Intr) (hn : s.next < Sim.bound)
    (hP : Present s aTypeErrorProto) (msg : List Char) :
    MSim (StepPost F FR M ν K S C) S C (typeErr s msg) (typeErr t msg) :=
  throwErr_sim h hn hP (hI _ (by decide)) msg

theorem rangeErr_sim (h : Rel F FR M ν K s S t C) (hI : M.Intr) (hn : s.next < Sim.bound)
    (hP : Present s aRangeErrorProto) (msg : List Char) :
    MSim (StepPost F FR M ν K S C) S C (rangeErr s msg) (rangeErr t msg) :=
  throwErr_sim h hn hP (hI _ (by decide)) msg

theorem refErr_sim (h : Rel F FR M ν K s S t C) (hI : M.Intr) (hn : s.next < Sim.bound)
    (hP : Present s aReferenceErrorProto) (msg : List Char) :
    MSim (StepPost F FR M ν K S C) S C (refErr s msg) (refErr t msg) :=
  throwErr_sim h hn hP (hI _ (by decide)) msg

/-- `o[k]`: a property get, running a getter by going to `.call`. -/
theorem getV_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hI : M.Intr)
    (hn : s.next < Sim.bound) (hP : Present s aTypeErrorProto) {recv : Val} {k : PKey}
    (hr : Supp.val (Present s) S.tab.length recv) (hk : Supp.key (Present s) S.tab.length k)
    (hok : LookupOK F K s S recv k) :
    MSim (StepPost F FR M ν K S C) S C (getV F s recv k) (getV F t (M.val recv) (M.key k)) := by
  have rest : MSim (StepPost F FR M ν K S C) S C
      (Host.Ts.M.bind (lookup F s recv k) fun p => Host.Ts.M.pure (readProp F s recv p))
      (Host.Ts.M.bind (lookup F t (M.val recv) (M.key k)) fun p => Host.Ts.M.pure (readProp F t (M.val recv) p)) := by
    refine MSim.bind (lookup_sim h hF hI hr hk hok) ?_
    rintro M' S' C' r r' ⟨-, hS, hC, rfl, hsupp⟩
    rw [hS, hC]
    exact MSim.pure ⟨Grow.refl h.srv, h.read hr hsupp⟩
  cases recv with
  | undef => exact typeErr_sim h hI hn hP _
  | null => exact typeErr_sim h hI hn hP _
  | bool b => exact rest
  | num x => exact rest
  | big i => exact rest
  | str cs => exact rest
  | sym i => exact rest
  | obj a => exact rest
  | ptr m off => exact rest

/-- Optional values: the target's is the image of the source's, which is supported. -/
def ValR (M : Map) (A : Nat → Prop) (n : Nat) (r r' : Option Val) : Prop :=
  r' = r.map M.val ∧ ∀ v, r = some v → Supp.val A n v

theorem dataOf_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hI : M.Intr)
    {recv : Val} {k : PKey} (hr : Supp.val (Present s) S.tab.length recv)
    (hk : Supp.key (Present s) S.tab.length k) (hok : LookupOK F K s S recv k) :
    MSim (ReadPost M S C (ValR M (Present s) S.tab.length)) S C
      (dataOf F s recv k) (dataOf F t (M.val recv) (M.key k)) := by
  refine MSim.bind (lookup_sim h hF hI hr hk hok) ?_
  rintro M' S' C' r r' ⟨-, hS, hC, rfl, hsupp⟩
  rw [hS, hC]
  rcases r with _ | ⟨v, w, e⟩ | ⟨g, st, e⟩
  · exact ReadPost.pure ⟨rfl, fun v hv => by cases hv; trivial⟩
  · exact ReadPost.pure ⟨rfl, fun v' hv => by cases hv; exact hsupp⟩
  · exact ReadPost.pure ⟨rfl, fun v hv => by cases hv⟩

end

/-! ## Writes -/

theorem Map.obj_props (M : Map) (o : Obj) (ps : Props) :
    M.obj { o with props := ps } = { M.obj o with props := M.props ps } := by
  cases o; rfl

theorem Map.obj_privs (M : Map) (o : Obj) (pv : List ((Nat × Name) × PropV)) :
    M.obj { o with priv := pv } = { M.obj o with priv := M.privs pv } := by
  cases o; rfl

theorem Map.obj_kind' (M : Map) (o : Obj) (k : Kind) :
    M.obj { o with kind := k } = { M.obj o with kind := M.kind k } := by
  cases o; rfl

theorem setNth_supp {A : Nat → Prop} {n : Nat} {d : Val} (hd : Supp.val A n d) {v : Val} (hv : Supp.val A n v) :
    ∀ {es : List Val} {i : Nat}, Supp.vals A n es → Supp.vals A n (setNth d es i v)
  | [], 0, _ => fun x hx => by rcases List.mem_singleton.1 hx with rfl; exact hv
  | [], i + 1, _ => fun x hx => by
    rcases List.mem_cons.1 hx with rfl | hx
    · exact hd
    · exact setNth_supp hd hv (es := []) (i := i) (fun _ h => nomatch h) x hx
  | _ :: es, 0, hes => fun x hx => by
    rcases List.mem_cons.1 hx with rfl | hx
    · exact hv
    · exact hes x (List.mem_cons_of_mem _ hx)
  | b :: es, i + 1, hes => fun x hx => by
    rcases List.mem_cons.1 hx with rfl | hx
    · exact hes _ (List.mem_cons_self ..)
    · exact setNth_supp hd hv (fun y hy => hes y (List.mem_cons_of_mem _ hy)) x hx

theorem resize_map (M : Map) (es : List Val) (n : Nat) : M.vals (resize es n) = resize (M.vals es) n := by
  unfold resize
  simp only [Map.vals, len_map]
  cases Nat.ble n (len es)
  · simp only [Bool.cond_false, List.map_append, List.map_replicate]
    rfl
  · simp only [Bool.cond_true, List.map_take]

theorem resize_supp {A : Nat → Prop} {m : Nat} {es : List Val} (hes : Supp.vals A m es) (n : Nat) :
    Supp.vals A m (resize es n) := by
  unfold resize
  cases Nat.ble n (len es)
  · intro x hx
    rcases List.mem_append.1 hx with hx | hx
    · exact hes x hx
    · rw [(List.mem_replicate.1 hx).2]; trivial
  · exact fun x hx => hes x (List.mem_of_mem_take hx)

theorem writeCell_map (M : Map) (k : EltK) (c : Cell) (bs : List Byte) (off : Nat) :
    (writeCell k c bs off).map M.byte = writeCell k (M.cell c) (bs.map M.byte) off := by
  simp only [writeCell, List.map_append, List.map_take, List.map_drop, Map.cellParts]

theorem cellParts_supp {A : Nat → Prop} {m : Nat} {k : EltK} {c : Cell} (hc : Supp.cell A m c) :
    ∀ n i, Supp.bytes A m (cellParts k c n i)
  | 0, _ => fun _ h => nomatch h
  | n + 1, i => fun x hx => by
    rcases List.mem_cons.1 hx with rfl | hx
    · exact hc
    · exact cellParts_supp hc n (i + 1) x hx

theorem writeCell_supp {A : Nat → Prop} {m : Nat} {k : EltK} {c : Cell} {bs : List Byte} (off : Nat)
    (hc : Supp.cell A m c) (hbs : Supp.bytes A m bs) : Supp.bytes A m (writeCell k c bs off) := by
  intro x hx
  simp only [writeCell, List.mem_append] at hx
  rcases hx with (hx | hx) | hx
  · exact hbs x (List.mem_of_mem_take hx)
  · exact cellParts_supp hc _ _ x hx
  · exact hbs x (List.mem_of_mem_drop hx)

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

theorem Rel.present_set (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) {a : Nat} (ha : Present s a)
    (o : Obj) : ∀ b, Present s b → Present (s.setObj a o) b := by
  have hb : Sim.bound = 2 ^ 61 := rfl
  have := h.presentBound a ha
  exact fun b hp => Present.set (.obj o) (by omega) hp

/-- Extending the map along a server growth keeps the relation. -/
theorem Rel.grow {M' : Map} {S' : SSrv} {C' : CSrv} (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR)
    (hg : Grow M ν S C M' S' C') : Rel F FR M' ν K s S' t C' :=
  h.extend hg.ext hg.srv hg.len hFR.stable hFR.mono

theorem Map.Intr.ext {M M' : Map} {n : Nat} (hI : M.Intr) (he : Ext M M' n) : M'.Intr := by
  intro a ha
  rw [he.a]
  exact hI a ha

/-- A step simulation after a server growth is one from before it. -/
theorem StepPost.after {M' : Map} {S' : SSrv} {C' : CSrv} {m m' : Host.Ts.M (St F.S)}
    (hg : Grow M ν S C M' S' C') (hm : MSim (StepPost F FR M' ν K S' C') S' C' m m') :
    MSim (StepPost F FR M ν K S C) S' C' m m' :=
  MSim.mono hm fun _ _ _ _ _ ⟨hg', hr⟩ => ⟨hg.trans hg', hr⟩

/-- `CreateDataProperty` on a present unframed address. -/
theorem Rel.defineData (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) {a : Nat} {k : PKey} {v : Val}
    (ha : Present s a) (hfr : K.fr a = none) (hk : Supp.key (Present s) S.tab.length k)
    (hv : Supp.val (Present s) S.tab.length v) :
    Rel F FR M ν K (Host.Ts.defineData F s a k v) S (Host.Ts.defineData F t (M.a a) (M.key k) (M.val v)) C := by
  unfold Host.Ts.defineData
  cases ho : s.obj? a with
  | none =>
    obtain ⟨hh, hg⟩ := ha.get
    cases hh with
    | obj o => rw [obj?_iff.2 hg] at ho; cases ho
    | cell c =>
      have ht : t.obj? (M.a a) = none := by
        unfold St.obj?
        rw [h.get hg hfr]
        rfl
      rw [ht]
      exact h
  | some o =>
    rw [h.obj? ho hfr]
    have hso := h.obj?_supp ho
    have hprops : Rel F FR M ν K (s.setObj a { o with props := setPropL k (.data v true true) o.props }) S
        (t.setObj (M.a a) { M.obj o with props := setPropL (M.key k) (.data (M.val v) true true) (M.obj o).props }) C := by
      have := h.setObj { o with props := setPropL k (.data v true true) o.props } hn ha hfr
        ⟨hso.1, hso.2.1, setPropL_supp (p := .data v true true) hk hv hso.2.2.1, hso.2.2.2⟩
      rwa [Map.obj_props, setPropL_map h.inj _ hk hso.2.2.1] at this
    obtain ⟨kd, pr, ps, pv, ex⟩ := o
    cases kd with
    | array es =>
      simp only [Map.obj, Map.kind, keyIndex_map]
      cases hi : keyIndex k with
      | none => exact hprops
      | some i =>
        simp only
        have := h.setObj ⟨.array (setNth .undef es i v), pr, ps, pv, ex⟩ hn ha hfr
          ⟨setNth_supp (d := .undef) trivial hv hso.1, hso.2.1, hso.2.2.1, hso.2.2.2⟩
        simp only [Map.obj, Map.kind, Map.vals, setNth_map] at this
        exact this
    | _ => exact hprops

theorem Rel.defineProp (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) {a : Nat} {k : PKey} {p : PropV}
    (ha : Present s a) (hfr : K.fr a = none) (hk : Supp.key (Present s) S.tab.length k)
    (hp : Supp.prop (Present s) S.tab.length p) :
    Rel F FR M ν K (Host.Ts.defineProp F s a k p) S (Host.Ts.defineProp F t (M.a a) (M.key k) (M.prop p)) C := by
  unfold Host.Ts.defineProp
  cases ho : s.obj? a with
  | none =>
    obtain ⟨hh, hg⟩ := ha.get
    cases hh with
    | obj o => rw [obj?_iff.2 hg] at ho; cases ho
    | cell c =>
      have ht : t.obj? (M.a a) = none := by
        unfold St.obj?
        rw [h.get hg hfr]
        rfl
      rw [ht]
      exact h
  | some o =>
    rw [h.obj? ho hfr]
    have hso := h.obj?_supp ho
    have := h.setObj { o with props := setPropL k p o.props } hn ha hfr
      ⟨hso.1, hso.2.1, setPropL_supp hk hp hso.2.2.1, hso.2.2.2⟩
    rwa [Map.obj_props, setPropL_map h.inj _ hk hso.2.2.1] at this

end

/-! ## Typed-array element conversion -/

section
variable {ν : Nat → F64}

private theorem srvPush {M : Map} {S : SSrv} {C C1 : CSrv} (hs : Srv M ν S C) (hle : CSrv.Le C C1)
    (e : SymE) (x : NumV) (hx : C1.val x = some (e.eval ν)) :
    Srv (M.setNum S.tab.length x) ν { S with tab := S.tab ++ [e] } C1 := by
  refine ⟨?_, hs.good⟩
  intro i e' he
  rcases nth?_append_eq S.tab e i e' he with ⟨hi, hi'⟩ | ⟨rfl, rfl⟩
  · rw [(M.setNum_ext S.tab.length x).num i hi]
    exact hle.val (hs.num i e' hi')
  · rw [M.setNum_self]
    exact hx

private theorem growPush {M : Map} {S : SSrv} {C C1 : CSrv} (hs : Srv M ν S C) (hle : CSrv.Le C C1)
    (e : SymE) (x : NumV) (hx : C1.val x = some (e.eval ν)) :
    Grow M ν S C (M.setNum S.tab.length x) { S with tab := S.tab ++ [e] } C1 :=
  ⟨M.setNum_ext _ _, srvPush hs hle e x hx, by simp⟩

private theorem numUnReq {δ : Type} (op : NUn) (x : NumV) (k' : NumV → Free δ)
    (h : ∀ u, x = .lit u → False) :
    (numUn op x) δ k' = .un op x fun j => k' (.ref j) := by
  cases x with
  | lit u => exact (h u rfl).elim
  | ref _ => rfl

/-- `numUn_sim` that also gives the support of the source result. -/
theorem numUn_supp_sim {M : Map} {S : SSrv} {C : CSrv} (A : Nat → Prop) (hs : Srv M ν S C) (op : NUn) (a : NumV) :
    MSim (fun M' S' C' r r' => r' = M'.nv r ∧ Grow M ν S C M' S' C' ∧ Supp.nv A S'.tab.length r) S C
      (numUn op a) (numUn op (M.nv a)) := by
  intro γ δ Q k k' hk
  have req : ∀ (K : Nat → Free γ), (∀ i, K i = k (.ref i)) →
      FSim Q S C (.un op a K) ((numUn op (M.nv a)) δ k') := by
    intro K hK r S' hu
    rw [interpS_un] at hu
    cases hva : S.val a with
    | none => rw [hva] at hu; cases hu
    | some ea =>
      rw [hva] at hu
      simp only at hu
      rw [hK] at hu
      have ca := hs.num.val hva
      have hsupp : Supp.nv A ({ S with tab := S.tab ++ [.un op ea] } : SSrv).tab.length (.ref S.tab.length) := by
        show S.tab.length < (S.tab ++ [_]).length
        simp
      by_cases lit : ∃ u, M.nv a = .lit u
      · obtain ⟨u, hu'⟩ := lit
        rw [hu'] at ca
        simp only [CSrv.val, Option.some.injEq] at ca
        subst ca
        have hg := growPush hs (CSrv.Le.refl C) (.un op ea) (.lit (F64.un op (ea.eval ν))) rfl
        obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length) (.lit (F64.un op (ea.eval ν)))
          ⟨(M.setNum_self _ _).symm, hg, hsupp⟩ r S' hu
        refine ⟨M', b', C', ?_, hq⟩
        rw [hu']
        exact hv
      · have hnot : ∀ u, M.nv a = .lit u → False := fun u h1 => lit ⟨u, h1⟩
        have hg := growPush hs (C1 := ⟨C.tab ++ [F64.un op (ea.eval ν)]⟩) ⟨_, rfl⟩
          (.un op ea) (.ref C.tab.length) (nth?_length_append C.tab _)
        obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length) (.ref C.tab.length)
          ⟨(M.setNum_self _ _).symm, hg, hsupp⟩ r S' hu
        refine ⟨M', b', C', ?_, hq⟩
        rw [numUnReq op _ k' hnot, interpC_un, ca]
        exact hv
  cases a with
  | lit x => exact hk M S C _ _ ⟨rfl, Grow.refl hs, trivial⟩
  | ref i => exact req _ (fun _ => rfl)

end

/-- Converted cells: the target's is the image (under the grown map) of the source's,
which is supported. -/
def CellPost (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) (A : Nat → Prop) :
    Map → SSrv → CSrv → Option Cell → Option Cell → Prop :=
  fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ r' = r.map M'.cell ∧ ∀ c, r = some c → Supp.cell A S'.tab.length c

/-- Bigint stores into 64-bit typed arrays keep their values: the operand and the
wrapped result are fixed bigints. -/
def CellOK (K : Ctx) : EltK → Val → Prop
  | .i64, .big i => BigFixed K.lo K.hi i ∧ BigFixed K.lo K.hi (signed 64 (modInt i (2 ^ 64)))
  | .u64, .big i => BigFixed K.lo K.hi i ∧ BigFixed K.lo K.hi ((modInt i (2 ^ 64) : Nat) : Int)
  | _, _ => True

section
variable {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {A : Nat → Prop}

theorem numCell_sim (hs : Srv M ν S C) (k : EltK) {x : NumV} (hx : Supp.nv A S.tab.length x) :
    MSim (CellPost M ν S C A) S C (numCell k x) (numCell k (M.nv x)) := by
  have un : ∀ op : NUn, MSim (CellPost M ν S C A) S C
      (Host.Ts.M.bind (numUn op x) fun y => Host.Ts.M.pure (some (Cell.num y)))
      (Host.Ts.M.bind (numUn op (M.nv x)) fun y => Host.Ts.M.pure (some (Cell.num y))) := fun op =>
    MSim.bind (numUn_supp_sim A hs op x) fun M' S' C' r r' ⟨hr, hg, hsupp⟩ =>
      MSim.pure ⟨hg, by rw [hr]; rfl, fun c hc => by cases hc; exact hsupp⟩
  cases k
  · exact un _
  · exact un _
  · exact un _
  · exact un _
  · exact un _
  · exact un _
  · exact un _
  · exact MSim.pure ⟨Grow.refl hs, rfl, fun c hc => by cases hc; exact hx⟩
  · exact MSim.pure ⟨Grow.refl hs, rfl, fun c hc => by cases hc⟩
  · exact MSim.pure ⟨Grow.refl hs, rfl, fun c hc => by cases hc⟩

theorem toCell_sim {K : Ctx} (hs : Srv M ν S C) (hbig : ∀ i, BigFixed K.lo K.hi i → M.big i = i) (k : EltK)
    {v : Val} (hv : Supp.val A S.tab.length v) (hok : CellOK K k v) :
    MSim (CellPost M ν S C A) S C (toCell k v) (toCell k (M.val v)) := by
  cases v with
  | num x => exact numCell_sim hs k hv
  | bool b => exact numCell_sim hs k trivial
  | null => exact numCell_sim hs k trivial
  | undef =>
    cases k <;> exact MSim.pure ⟨Grow.refl hs, rfl, fun c hc => by cases hc <;> trivial⟩
  | big i =>
    cases k with
    | i64 =>
      obtain ⟨hi, hr⟩ := hok
      refine MSim.pure ⟨Grow.refl hs, ?_, fun c hc => by cases hc; trivial⟩
      simp only [hbig i hi, Option.map_some, Map.cell, hbig _ hr]
    | u64 =>
      obtain ⟨hi, hr⟩ := hok
      refine MSim.pure ⟨Grow.refl hs, ?_, fun c hc => by cases hc; trivial⟩
      simp only [hbig i hi, Option.map_some, Map.cell, hbig _ hr]
    | _ => exact MSim.pure ⟨Grow.refl hs, rfl, fun c hc => by cases hc⟩
  | str cs => exact MSim.pure ⟨Grow.refl hs, rfl, fun c hc => by cases hc⟩
  | sym i => exact MSim.pure ⟨Grow.refl hs, rfl, fun c hc => by cases hc⟩
  | obj a => exact MSim.pure ⟨Grow.refl hs, rfl, fun c hc => by cases hc⟩
  | ptr m off => exact MSim.pure ⟨Grow.refl hs, rfl, fun c hc => by cases hc⟩

end

/-! ## Puts -/

/-- The side condition of `putV`: the receiver object is unframed, inherited setters
are looked up under `ChainOK`, and typed-array stores are `CellOK`. -/
def PutOK (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (recv : Val) (k : PKey) (v : Val) : Prop :=
  ∀ a, recv = .obj a → K.fr a = none ∧ ∀ o, s.obj? a = some o →
    (∀ p, o.proto = .obj p → ChainOK F K s S k 16 p) ∧
    (∀ kk b off n, o.kind = .typed kk b off n → CellOK K kk v)

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

theorem typedPut_sim (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR) (hI : M.Intr) (hn : s.next < Sim.bound)
    (hP : Present s aTypeErrorProto) {a : Nat} {o : Obj} {kk : EltK} {b off n i : Nat} {v : Val}
    (hv : Supp.val (Present s) S.tab.length v) (hok : CellOK K kk v) :
    MSim (StepPost F FR M ν K S C) S C (typedPut F s a o kk b off n i v)
      (typedPut F t (M.a a) (M.obj o) kk (M.a b) off n i (M.val v)) := by
  unfold typedPut
  refine MSim.bind (toCell_sim (A := Present s) h.srv h.bigFixed kk hv hok) ?_
  rintro M' S' C' r r' ⟨hg, rfl, hsupp⟩
  have h' := h.grow hFR hg
  have hI' := hI.ext hg.ext
  have hva : M'.val v = M.val v := (Map.val_agree hg.ext.agree hv).symm
  have hle : S.tab.length ≤ S'.tab.length := hg.len
  have hPid : ∀ x, Present s x → Present s x := fun _ hx => hx
  have hv' : Supp.val (Present s) S'.tab.length v := Supp.val_mono hPid hle hv
  cases r with
  | none => exact StepPost.after hg (typeErr_sim h' hI' hn hP _)
  | some c =>
    simp only [Option.map_some]
    refine MSim.cond _ ?_ (MSim.pure ⟨hg, by rw [← hva]; exact h'.ret v hv'⟩)
    cases hb : s.obj? b with
    | none => exact MSim.fail _ _
    | some bo =>
      have hso := h.obj?_supp hb
      obtain ⟨kd, pr, ps, pv, ex⟩ := bo
      cases kd with
      | buf bs =>
        have hfr : K.fr b = none := h.fr_none hb (fun es he => by cases he)
        have hb' := h'.obj? hb hfr
        rw [hg.ext.a] at hb'
        rw [hb']
        have hso' := Supp.obj_mono hPid hle hso
        have hnew := h'.setObj ⟨.buf (writeCell kk c bs (off + i * kk.size)), pr, ps, pv, ex⟩ hn
          (Present.of_get (obj?_iff.1 hb)) hfr
          ⟨writeCell_supp _ (hsupp c rfl) hso'.1, hso'.2.1, hso'.2.2.1, hso'.2.2.2⟩
        have hnew' := hnew.ret v (Supp.val_mono (h'.present_set hn (Present.of_get (obj?_iff.1 hb)) _) (Nat.le_refl _) hv')
        have e : M'.obj ⟨.buf (writeCell kk c bs (off + i * kk.size)), pr, ps, pv, ex⟩ =
            { M'.obj ⟨.buf bs, pr, ps, pv, ex⟩ with
              kind := .buf (writeCell kk (M'.cell c) (bs.map M'.byte) (off + i * kk.size)) } := by
          simp only [Map.obj, Map.kind, writeCell_map]
        rw [e, hg.ext.a, hva] at hnew'
        exact MSim.pure ⟨hg, hnew'⟩
      | _ => exact MSim.fail _ _

theorem putOrd_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hI : M.Intr)
    (hn : s.next < Sim.bound) (hP : Present s aTypeErrorProto) {a : Nat} {o : Obj} {k : PKey} {v : Val}
    (ho : s.obj? a = some o) (hfr : K.fr a = none) (hk : Supp.key (Present s) S.tab.length k)
    (hv : Supp.val (Present s) S.tab.length v) (hch : ∀ p, o.proto = .obj p → ChainOK F K s S k 16 p) :
    MSim (StepPost F FR M ν K S C) S C (putV.putOrd F s a o k v)
      (putV.putOrd F t (M.a a) (M.obj o) (M.key k) (M.val v)) := by
  have hso := h.obj?_supp ho
  have ha : Present s a := Present.of_get (obj?_iff.1 ho)
  have hP' := h.present_set hn ha
  have hle : S.tab.length ≤ S.tab.length := Nat.le_refl _
  have call : ∀ st, Supp.val (Present s) S.tab.length st → MSim (StepPost F FR M ν K S C) S C
      (Host.Ts.M.pure ((s.push (.e (.const v))).go (.call st (.obj a) [v])))
      (Host.Ts.M.pure ((t.push (.e (.const (M.val v)))).go (.call (M.val st) (.obj (M.a a)) [M.val v]))) :=
    fun st hst => MSim.pure ⟨Grow.refl h.srv, (h.push (.e (.const v)) hv).go (.call st (.obj a) [v])
      ⟨hst, ha, fun x hx => by rcases List.mem_singleton.1 hx with rfl; exact hv⟩⟩
  have terr := typeErr_sim h hI hn hP
  have add : Rel F FR M ν K ((s.setObj a { o with props := o.props ++ [(k, .data v true true)] }).ret v) S
      ((t.setObj (M.a a) { M.obj o with props := M.props o.props ++ [(M.key k, .data (M.val v) true true)] }).ret
        (M.val v)) C := by
    have hps : Supp.props (Present s) S.tab.length (o.props ++ [(k, .data v true true)]) := fun x hx => by
      rcases List.mem_append.1 hx with hx | hx
      · exact hso.2.2.1 x hx
      · rcases List.mem_singleton.1 hx with rfl
        exact ⟨hk, hv⟩
    have := (h.setObj { o with props := o.props ++ [(k, .data v true true)] } hn ha hfr
      ⟨hso.1, hso.2.1, hps, hso.2.2.2⟩).ret v (Supp.val_mono (hP' _) hle hv)
    rwa [Map.obj_props, Map.props, List.map_append] at this
  unfold putV.putOrd
  rw [show (M.obj o).props = M.props o.props from rfl, findProp_map h.inj hk hso.2.2.1]
  cases hf : findProp k o.props with
  | some p =>
    have hps := findProp_supp hso.2.2.1 hf
    rcases p with ⟨x, w, e⟩ | ⟨g, st, e⟩
    · simp only [Option.map_some, Map.prop]
      refine MSim.cond w ?_ (terr _)
      have := (h.setObj { o with props := setPropL k (.data v true e) o.props } hn ha hfr
        ⟨hso.1, hso.2.1, setPropL_supp (p := .data v true e) hk hv hso.2.2.1, hso.2.2.2⟩).ret v
        (Supp.val_mono (hP' _) hle hv)
      rw [Map.obj_props, setPropL_map h.inj _ hk hso.2.2.1] at this
      exact MSim.pure ⟨Grow.refl h.srv, this⟩
    · cases st with
      | undef => exact terr _
      | null => exact call _ hps.2
      | bool _ => exact call _ hps.2
      | num _ => exact call _ hps.2
      | big _ => exact call _ hps.2
      | str _ => exact call _ hps.2
      | sym _ => exact call _ hps.2
      | obj _ => exact call _ hps.2
      | ptr _ _ => exact call _ hps.2
  | none =>
    simp only [Option.map_none]
    rw [show (M.obj o).proto = M.val o.proto from rfl]
    refine MSim.bind (P := ReadPost M S C (PropR M (Present s) S.tab.length)) ?_ ?_
    · have hsp : Supp.val (Present s) S.tab.length o.proto := hso.2.1
      cases hp : o.proto with
      | obj p =>
        rw [hp] at hsp
        exact getChain_sim h hF hk 16 p (hch p hp)
      | _ => exact ReadPost.pure ⟨rfl, trivial⟩
    · rintro M' S' C' r r' ⟨-, hS, hC, rfl, hsupp⟩
      rw [hS, hC]
      have addM : MSim (StepPost F FR M ν K S C) S C
          (bif o.extensible then Host.Ts.M.pure ((s.setObj a { o with props := o.props ++ [(k, .data v true true)] }).ret v)
            else typeErr s (chars!"cannot add a property to a non-extensible object"))
          (bif (M.obj o).extensible then
            Host.Ts.M.pure ((t.setObj (M.a a) { M.obj o with props := M.props o.props ++ [(M.key k, .data (M.val v) true true)] }).ret (M.val v))
            else typeErr t (chars!"cannot add a property to a non-extensible object")) :=
        MSim.cond _ (MSim.pure ⟨Grow.refl h.srv, add⟩) (terr _)
      rcases r with _ | ⟨x, w, e⟩ | ⟨g, st, e⟩
      · exact addM
      · cases w
        · exact terr _
        · exact addM
      · cases st with
        | undef => exact terr _
        | null => exact call _ hsupp.2
        | bool _ => exact call _ hsupp.2
        | num _ => exact call _ hsupp.2
        | big _ => exact call _ hsupp.2
        | str _ => exact call _ hsupp.2
        | sym _ => exact call _ hsupp.2
        | obj _ => exact call _ hsupp.2
        | ptr _ _ => exact call _ hsupp.2

/-- `o[k] = v` (strict mode): own data, setter, array index or length, typed-array
element, or a new property. -/
theorem putV_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    (hI : M.Intr) (hn : s.next < Sim.bound) (hP : Present s aTypeErrorProto) (hPR : Present s aRangeErrorProto)
    {recv : Val} {k : PKey} {v : Val} (hk : Supp.key (Present s) S.tab.length k)
    (hv : Supp.val (Present s) S.tab.length v) (hok : PutOK F K s S recv k v) :
    MSim (StepPost F FR M ν K S C) S C (putV F s recv k v) (putV F t (M.val recv) (M.key k) (M.val v)) := by
  cases recv with
  | obj a =>
    obtain ⟨hfr, hok'⟩ := hok a rfl
    unfold putV
    simp only [Map.val]
    cases ho : s.obj? a with
    | none => exact MSim.fail _ _
    | some o =>
      obtain ⟨hch, hcell⟩ := hok' o ho
      have ord := putOrd_sim h hF hI hn hP ho hfr hk hv hch
      have ha : Present s a := Present.of_get (obj?_iff.1 ho)
      have hso := h.obj?_supp ho
      have hP' := h.present_set hn ha
      rw [h.obj? ho hfr]
      simp only
      rw [keyIndex_map, show (M.obj o).kind = M.kind o.kind from rfl]
      obtain ⟨kd, pr, ps, pv, ex⟩ := o
      cases kd with
      | array es =>
        rw [show M.kind (.array es) = .array (M.vals es) from rfl]
        cases hi : keyIndex k with
        | some i =>
          simp only
          refine MSim.cond _ ?_ (typeErr_sim h hI hn hP _)
          have := (h.setObj ⟨.array (setNth .undef es i v), pr, ps, pv, ex⟩ hn ha hfr
            ⟨setNth_supp (d := .undef) trivial hv hso.1, hso.2.1, hso.2.2.1, hso.2.2.2⟩).ret v
            (Supp.val_mono (hP' _) (Nat.le_refl _) hv)
          have e : M.obj ⟨.array (setNth .undef es i v), pr, ps, pv, ex⟩ =
              { M.obj ⟨.array es, pr, ps, pv, ex⟩ with kind := .array (setNth .undef (M.vals es) i (M.val v)) } := by
            simp only [Map.obj, Map.kind, Map.vals, setNth_map]
            rfl
          rw [e] at this
          exact MSim.pure ⟨Grow.refl h.srv, this⟩
        | none =>
          simp only
          have hkl : keyEq (M.key k) kLength = keyEq k kLength := keyEq_map_str h.inj hk _
          rw [hkl]
          refine MSim.cond _ ?_ ord
          cases v with
          | num x =>
            cases x with
            | lit x =>
              simp only [Map.nv]
              cases hx : F64.toIndex? x with
              | none => exact rangeErr_sim h hI hn hPR _
              | some n =>
                simp only
                refine MSim.cond _ ?_ (typeErr_sim h hI hn hP _)
                have := (h.setObj ⟨.array (resize es n), pr, ps, pv, ex⟩ hn ha hfr
                  ⟨resize_supp hso.1 n, hso.2.1, hso.2.2.1, hso.2.2.2⟩).ret (.num (.lit x)) trivial
                have e : M.obj ⟨.array (resize es n), pr, ps, pv, ex⟩ =
                    { M.obj ⟨.array es, pr, ps, pv, ex⟩ with kind := .array (resize (M.vals es) n) } := by
                  simp only [Map.obj, Map.kind, resize_map]
                rw [e] at this
                exact MSim.pure ⟨Grow.refl h.srv, this⟩
            | ref j => exact MSim.fail _ _
          | undef => exact MSim.fail _ _
          | null => exact MSim.fail _ _
          | bool _ => exact MSim.fail _ _
          | big _ => exact MSim.fail _ _
          | str _ => exact MSim.fail _ _
          | sym _ => exact MSim.fail _ _
          | obj _ => exact MSim.fail _ _
          | ptr _ _ => exact MSim.fail _ _
      | typed kk b off n =>
        rw [show M.kind (.typed kk b off n) = .typed kk (M.a b) off n from rfl]
        cases hi : keyIndex k with
        | some i => exact typedPut_sim h hFR hI hn hP hv (hcell kk b off n rfl)
        | none => exact ord
      | ns ex => exact typeErr_sim h hI hn hP _
      | ordinary => exact ord
      | fn _ => exact ord
      | buf _ => exact ord
      | extBuf _ _ _ => exact ord
      | view _ _ _ => exact ord
      | map _ => exact ord
      | set _ => exact ord
      | promise _ => exact ord
      | gen _ _ _ => exact ord
      | box _ => exact ord
      | iter _ _ _ => exact ord
  | undef => exact typeErr_sim h hI hn hP _
  | null => exact typeErr_sim h hI hn hP _
  | bool _ => exact typeErr_sim h hI hn hP _
  | num _ => exact typeErr_sim h hI hn hP _
  | big _ => exact typeErr_sim h hI hn hP _
  | str _ => exact typeErr_sim h hI hn hP _
  | sym _ => exact typeErr_sim h hI hn hP _
  | ptr _ _ => exact typeErr_sim h hI hn hP _

/-- The target object at the image of a present source object: framed or not, its
prototype, properties, private members and extensibility are images. -/
theorem Rel.obj?_some (h : Rel F FR M ν K s S t C) {a : Nat} {o : Obj} (ho : s.obj? a = some o) :
    ∃ o', t.obj? (M.a a) = some o' ∧ o'.proto = M.val o.proto ∧ o'.props = M.props o.props ∧
      o'.priv = M.privs o.priv ∧ o'.extensible = o.extensible := by
  cases hf : K.fr a with
  | none => exact ⟨_, h.obj? ho hf, rfl, rfl, rfl, rfl⟩
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    obtain ⟨o', ho', xs, _, rfl⟩ := h.obj?_framed ho hf
    exact ⟨_, ho', rfl, rfl, rfl, rfl⟩

/-- `o.#n`: a private member get. -/
theorem privGetV_sim (h : Rel F FR M ν K s S t C) (hI : M.Intr) (hn : s.next < Sim.bound)
    (hP : Present s aTypeErrorProto) {recv : Val} {b : Nat} {nm : Name}
    (hr : Supp.val (Present s) S.tab.length recv) (hb : Present s b) :
    MSim (StepPost F FR M ν K S C) S C (privGetV F s recv b nm) (privGetV F t (M.val recv) (M.a b) nm) := by
  cases recv with
  | obj a =>
    unfold privGetV
    simp only [Map.val]
    cases ho : s.obj? a with
    | none => exact MSim.fail _ _
    | some o =>
      obtain ⟨o', ho', -, -, hpv, -⟩ := h.obj?_some ho
      have hso := h.obj?_supp ho
      rw [ho']
      simp only
      rw [hpv, findPriv_map h.inj nm hb hso.2.2.2]
      cases hf : findPriv b nm o.priv with
      | none => exact typeErr_sim h hI hn hP _
      | some p =>
        exact MSim.pure ⟨Grow.refl h.srv, h.read (recv := .obj a) hr (findPriv_supp hso.2.2.2 hf)⟩
  | undef => exact typeErr_sim h hI hn hP _
  | null => exact typeErr_sim h hI hn hP _
  | bool _ => exact typeErr_sim h hI hn hP _
  | num _ => exact typeErr_sim h hI hn hP _
  | big _ => exact typeErr_sim h hI hn hP _
  | str _ => exact typeErr_sim h hI hn hP _
  | sym _ => exact typeErr_sim h hI hn hP _
  | ptr _ _ => exact typeErr_sim h hI hn hP _

/-- `o.#n = v`: a private member put (the object unframed). -/
theorem privPutV_sim (h : Rel F FR M ν K s S t C) (hI : M.Intr) (hn : s.next < Sim.bound)
    (hP : Present s aTypeErrorProto) {recv : Val} {b : Nat} {nm : Name} {v : Val}
    (hr : Supp.val (Present s) S.tab.length recv) (hb : Present s b)
    (hv : Supp.val (Present s) S.tab.length v) (hfr : ∀ a, recv = .obj a → K.fr a = none) :
    MSim (StepPost F FR M ν K S C) S C (privPutV F s recv b nm v)
      (privPutV F t (M.val recv) (M.a b) nm (M.val v)) := by
  cases recv with
  | obj a =>
    have hfa := hfr a rfl
    unfold privPutV
    simp only [Map.val]
    cases ho : s.obj? a with
    | none => exact MSim.fail _ _
    | some o =>
      have hso := h.obj?_supp ho
      have ha : Present s a := Present.of_get (obj?_iff.1 ho)
      rw [h.obj? ho hfa]
      simp only
      rw [Map.obj_priv, findPriv_map h.inj nm hb hso.2.2.2]
      have call : ∀ st, Supp.val (Present s) S.tab.length st → MSim (StepPost F FR M ν K S C) S C
          (Host.Ts.M.pure ((s.push (.e (.const v))).go (.call st (.obj a) [v])))
          (Host.Ts.M.pure ((t.push (.e (.const (M.val v)))).go (.call (M.val st) (.obj (M.a a)) [M.val v]))) :=
        fun st hst => MSim.pure ⟨Grow.refl h.srv, (h.push (.e (.const v)) hv).go (.call st (.obj a) [v])
          ⟨hst, ha, fun x hx => by rcases List.mem_singleton.1 hx with rfl; exact hv⟩⟩
      cases hf : findPriv b nm o.priv with
      | none => exact typeErr_sim h hI hn hP _
      | some p =>
        have hps := findPriv_supp hso.2.2.2 hf
        rcases p with ⟨x, w, e⟩ | ⟨g, st, e⟩
        · cases w
          · exact typeErr_sim h hI hn hP _
          · have := (h.setObj { o with priv := setPrivL b nm (.data v true e) o.priv } hn ha hfa
              ⟨hso.1, hso.2.1, hso.2.2.1, setPrivL_supp (p := .data v true e) hb hv hso.2.2.2⟩).ret v
              (Supp.val_mono (h.present_set hn ha _) (Nat.le_refl _) hv)
            rw [Map.obj_privs, setPrivL_map h.inj nm _ hb hso.2.2.2] at this
            exact MSim.pure ⟨Grow.refl h.srv, this⟩
        · cases st with
          | undef => exact typeErr_sim h hI hn hP _
          | null => exact call _ hps.2
          | bool _ => exact call _ hps.2
          | num _ => exact call _ hps.2
          | big _ => exact call _ hps.2
          | str _ => exact call _ hps.2
          | sym _ => exact call _ hps.2
          | obj _ => exact call _ hps.2
          | ptr _ _ => exact call _ hps.2
  | undef => exact typeErr_sim h hI hn hP _
  | null => exact typeErr_sim h hI hn hP _
  | bool _ => exact typeErr_sim h hI hn hP _
  | num _ => exact typeErr_sim h hI hn hP _
  | big _ => exact typeErr_sim h hI hn hP _
  | str _ => exact typeErr_sim h hI hn hP _
  | sym _ => exact typeErr_sim h hI hn hP _
  | ptr _ _ => exact typeErr_sim h hI hn hP _

end

/-! ## Element lists, arrays, keys -/

/-- Optional value lists: the target's is the image of the source's, which is supported. -/
def ValsR (M : Map) (A : Nat → Prop) (n : Nat) (r r' : Option (List Val)) : Prop :=
  r' = r.map M.vals ∧ ∀ vs, r = some vs → Supp.vals A n vs

/-- Typed-array element reads at indices `[i, i + n)` of buffer `b`. -/
def ElemsReadOK (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (k : EltK) (b off n i : Nat) : Prop :=
  ∀ j, j < n → ∀ bs, bufBytes F s b = some bs →
    CellRead K (Present s) S.tab.length k (bs.drop (off + (i + j) * k.size))

/-- The side condition of `elemsOf`: an object operand is unframed and its typed-array
elements are `CellRead`. -/
def ElemsOK (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (v : Val) : Prop :=
  ∀ a, v = .obj a → K.fr a = none ∧ ∀ o, s.obj? a = some o →
    ∀ k b off n, o.kind = .typed k b off n → ElemsReadOK F K s S k b off n 0

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

theorem typedElems_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (k : EltK) (b off : Nat) :
    ∀ n i, ElemsReadOK F K s S k b off n i →
    MSim (ReadPost M S C (fun vs vs' => vs' = M.vals vs ∧ Supp.vals (Present s) S.tab.length vs)) S C
      (typedElems F s k b off n i) (typedElems F t k (M.a b) off n i)
  | 0, _, _ => ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
  | n + 1, i, hok => by
    simp only [typedElems]
    have hg := typedGet_sim h hF (kk := k) (b := b) (off := off) (n := i + n + 1) (i := i) fun _ bs hb => by
      have := hok 0 (Nat.zero_lt_succ _) bs hb
      rwa [Nat.add_zero] at this
    refine MSim.bind hg ?_
    rintro M' S' C' r r' ⟨-, hS, hC, rfl, hsupp⟩
    rw [hS, hC]
    rcases r with _ | ⟨v, w, e⟩ | ⟨g, st, e⟩
    · exact MSim.fail _ _
    · have ih := typedElems_sim h hF k b off n (i + 1) fun j hj bs hb => by
        have := hok (j + 1) (Nat.succ_lt_succ hj) bs hb
        rwa [show i + (j + 1) = i + 1 + j by omega] at this
      refine MSim.bind ih ?_
      rintro M'' S'' C'' vs vs' ⟨-, hS', hC', rfl, hvs⟩
      rw [hS', hC']
      refine ReadPost.pure ⟨rfl, fun x hx => ?_⟩
      rcases List.mem_cons.1 hx with rfl | hx
      · exact hsupp
      · exact hvs x hx
    · exact MSim.fail _ _

theorem Rel.obj?_none (h : Rel F FR M ν K s S t C) {a : Nat} (ha : Present s a) (ho : s.obj? a = none) :
    t.obj? (M.a a) = none := by
  obtain ⟨hh, hg⟩ := ha.get
  cases hh with
  | obj o => rw [obj?_iff.2 hg] at ho; cases ho
  | cell c =>
    unfold St.obj?
    rw [h.get hg (h.fr_cell hg)]
    rfl

theorem elemsOf_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {v : Val}
    (hv : Supp.val (Present s) S.tab.length v) (hok : ElemsOK F K s S v) :
    MSim (ReadPost M S C (ValsR M (Present s) S.tab.length)) S C (elemsOf F s v) (elemsOf F t (M.val v)) := by
  cases v with
  | obj a =>
    obtain ⟨hfr, hok'⟩ := hok a rfl
    simp only [elemsOf, Map.val]
    cases ho : s.obj? a with
    | none =>
      rw [h.obj?_none hv ho]
      exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
    | some o =>
      have hso := h.obj?_supp ho
      rw [h.obj? ho hfr]
      obtain ⟨kd, pr, ps, pv, ex⟩ := o
      cases kd with
      | array es => exact ReadPost.pure ⟨rfl, fun vs hvs => by cases hvs; exact hso.1⟩
      | typed k b off n =>
        refine MSim.bind (typedElems_sim h hF k b off n 0 (hok' _ ho k b off n rfl)) ?_
        rintro M' S' C' vs vs' ⟨-, hS, hC, rfl, hvs⟩
        rw [hS, hC]
        exact ReadPost.pure ⟨rfl, fun x hx => by cases hx; exact hvs⟩
      | ordinary => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
      | fn _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
      | buf _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
      | extBuf _ _ _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
      | view _ _ _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
      | map _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
      | set _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
      | promise _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
      | gen _ _ _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
      | ns _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
      | box _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
      | iter _ _ _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
  | str cs =>
    refine ReadPost.pure ⟨?_, fun vs hvs x hx => ?_⟩
    · simp only [Option.map_some, Map.vals, List.map_map]
      rfl
    · cases hvs
      obtain ⟨c, -, rfl⟩ := List.mem_map.1 hx
      trivial
  | undef => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
  | null => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
  | bool _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
  | num _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
  | big _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
  | sym _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩
  | ptr _ _ => exact ReadPost.pure ⟨rfl, fun _ h => nomatch h⟩

/-- `arrayOf` at a present unframed address. -/
theorem Rel.arrayOf (h : Rel F FR M ν K s S t C) {a : Nat} (ha : Present s a) (hfr : K.fr a = none) :
    Host.Ts.arrayOf F t (M.a a) = (Host.Ts.arrayOf F s a).map fun (o, es) => (M.obj o, M.vals es) := by
  unfold Host.Ts.arrayOf
  cases ho : s.obj? a with
  | none =>
    obtain ⟨hh, hg⟩ := ha.get
    cases hh with
    | obj o => rw [obj?_iff.2 hg] at ho; cases ho
    | cell c =>
      have ht : t.obj? (M.a a) = none := by
        unfold St.obj?
        rw [h.get hg hfr]
        rfl
      rw [ht]
      rfl
  | some o =>
    rw [h.obj? ho hfr]
    obtain ⟨kd, pr, ps, pv, ex⟩ := o
    cases kd <;> rfl

/-- `arrayOf` at a framed address: the target array keeps its own prefix. -/
theorem Rel.arrayOf_framed (h : Rel F FR M ν K s S t C) {a : Nat} {pre pre' : List Val} {o : Obj}
    {es : List Val} (hfr : K.fr a = some (pre, pre')) (hs : Host.Ts.arrayOf F s a = some (o, es)) :
    ∃ o' xs, Host.Ts.arrayOf F t (M.a a) = some (o', pre' ++ M.vals xs) ∧ es = pre ++ xs ∧
      FramedObj M pre pre' o o' := by
  unfold Host.Ts.arrayOf at hs ⊢
  cases ho : s.obj? a with
  | none => rw [ho] at hs; cases hs
  | some o0 =>
    rw [ho] at hs
    simp only at hs
    obtain ⟨o', ho', hfo⟩ := h.obj?_framed ho hfr
    obtain ⟨xs, hk, rfl⟩ := hfo
    rw [hk] at hs
    cases hs
    rw [ho']
    exact ⟨_, xs, rfl, rfl, xs, hk, rfl⟩

theorem Rel.byteLen (h : Rel F FR M ν K s S t C) {b : Nat} (hb : Present s b) :
    Host.Ts.byteLen F t (M.a b) = Host.Ts.byteLen F s b := by
  unfold Host.Ts.byteLen
  cases ho : s.obj? b with
  | none =>
    obtain ⟨hh, hg⟩ := hb.get
    cases hh with
    | obj o => rw [obj?_iff.2 hg] at ho; cases ho
    | cell c =>
      have ht : t.obj? (M.a b) = none := by
        unfold St.obj?
        rw [h.get hg (h.fr_cell hg)]
        rfl
      rw [ht]
  | some o =>
    cases hf : K.fr b with
    | some p =>
      obtain ⟨pre, pre'⟩ := p
      obtain ⟨o', ho', xs, hk, rfl⟩ := h.obj?_framed ho hf
      rw [ho']
      obtain ⟨kd, pr, ps, pv, ex⟩ := o
      simp only at hk
      subst hk
      rfl
    | none =>
      rw [h.obj? ho hf]
      obtain ⟨kd, pr, ps, pv, ex⟩ := o
      cases kd <;> try rfl
      simp only [Map.obj, Map.kind, len_map]

end

theorem filter_map_key (M : Map) (p : PKey × PropV → Bool) (hp : ∀ x, p (M.key x.1, M.prop x.2) = p x) :
    ∀ ps : Props, ((M.props ps).filter p).map Prod.fst = ((ps.filter p).map Prod.fst).map M.key
  | [] => rfl
  | x :: ps => by
    have ih := filter_map_key M p hp ps
    show ((((M.key x.1, M.prop x.2) :: M.props ps).filter p).map Prod.fst) = _
    rw [List.filter_cons, List.filter_cons, hp x]
    cases p x
    · exact ih
    · simp only [ite_true, List.map_cons, ih]

section
variable {F : Ffi} {s t : St F.S}

/-- Own enumerable keys of an image object are the images of the keys. -/
theorem ownKeys_map (M : Map) (o : Obj) : ownKeys F t (M.obj o) = (ownKeys F s o).map M.key := by
  obtain ⟨kd, pr, ps, pv, ex⟩ := o
  unfold ownKeys
  simp only [List.map_append]
  congr 1
  · cases kd <;> simp only [Map.obj, Map.kind, Map.vals, Map.pairs, len_map, List.map_map, List.map_nil] <;> rfl
  · exact filter_map_key M _ (fun ⟨k, q⟩ => by
      cases k <;> rcases q with ⟨v, w, e⟩ | ⟨g, st, e⟩ <;> cases e <;> rfl) ps

theorem ownKeys_supp {A : Nat → Prop} {n : Nat} {o : Obj} (hps : Supp.props A n o.props) :
    ∀ k ∈ ownKeys F s o, Supp.key A n k := by
  intro k hk
  unfold ownKeys at hk
  simp only [List.mem_append] at hk
  rcases hk with hk | hk
  · obtain ⟨kd, pr, ps, pv, ex⟩ := o
    cases kd <;> simp only [List.mem_map, List.not_mem_nil] at hk
    · obtain ⟨_, _, rfl⟩ := hk; trivial
    · obtain ⟨_, _, rfl⟩ := hk; trivial
    · obtain ⟨⟨_, _⟩, _, rfl⟩ := hk; trivial
  · obtain ⟨x, hx, rfl⟩ := List.mem_map.1 hk
    exact (hps x (List.mem_filter.1 hx).1).1

end

/-- Image of a key-value list. -/
def Map.kvs (M : Map) (kvs : List (PKey × Val)) : List (PKey × Val) := kvs.map fun x => (M.key x.1, M.val x.2)

/-- Optional key-value lists: the target's is the image of the source's, which is supported. -/
def KVR (M : Map) (A : Nat → Prop) (n : Nat) (r r' : Option (List (PKey × Val))) : Prop :=
  r' = r.map M.kvs ∧ ∀ kvs, r = some kvs → ∀ x ∈ kvs, Supp.key A n x.1 ∧ Supp.val A n x.2

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

theorem dataPropsGo_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {o : Obj}
    (hso : Supp.obj (Present s) S.tab.length o) : ∀ ks : List PKey,
    (∀ k ∈ ks, Supp.key (Present s) S.tab.length k ∧ TypedOK F K s S o k) →
    MSim (ReadPost M S C (KVR M (Present s) S.tab.length)) S C
      (dataProps.go F s o ks) (dataProps.go F t (M.obj o) (ks.map M.key))
  | [], _ => ReadPost.pure ⟨rfl, fun kvs h x hx => by cases h; cases hx⟩
  | k :: ks, hks => by
    obtain ⟨hk, hty⟩ := hks k (List.mem_cons_self ..)
    simp only [dataProps.go, List.map_cons]
    refine MSim.bind (ownGet_sim h hF hso hk hty) ?_
    rintro M' S' C' r r' ⟨-, hS, hC, rfl, hsupp⟩
    rw [hS, hC]
    rcases r with _ | ⟨v, w, e⟩ | ⟨g, st, e⟩
    · exact ReadPost.pure ⟨rfl, fun kvs h => by cases h⟩
    · refine MSim.bind (dataPropsGo_sim h hF hso ks fun k hk => hks k (List.mem_cons_of_mem _ hk)) ?_
      rintro M'' S'' C'' q q' ⟨-, hS', hC', rfl, hq⟩
      rw [hS', hC']
      refine ReadPost.pure ⟨?_, ?_⟩
      · cases q <;> rfl
      · intro kvs hkvs x hx
        cases q with
        | none => cases hkvs
        | some l =>
          cases hkvs
          rcases List.mem_cons.1 hx with rfl | hx
          · exact ⟨hk, hsupp⟩
          · exact hq l rfl x hx
    · exact ReadPost.pure ⟨rfl, fun kvs h => by cases h⟩

/-- Own enumerable data properties of an unframed object image (`Object.entries`). -/
theorem dataProps_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {o : Obj}
    (hso : Supp.obj (Present s) S.tab.length o) (hok : ∀ k ∈ ownKeys F s o, TypedOK F K s S o k) :
    MSim (ReadPost M S C (KVR M (Present s) S.tab.length)) S C (dataProps F s o) (dataProps F t (M.obj o)) := by
  unfold dataProps
  rw [ownKeys_map (s := s)]
  exact dataPropsGo_sim h hF hso _ fun k hk => ⟨ownKeys_supp hso.2.2.1 k hk, hok k hk⟩

/-! ### Strict equality -/

/-- Strict equality of related values gives the same answer, given that the map keeps
the bigint and native-region comparisons of the operands. -/
theorem strictEq_sim_of (h : Rel F FR M ν K s S t C) {x y : Val}
    (hx : Supp.val (Present s) S.tab.length x) (hy : Supp.val (Present s) S.tab.length y)
    (hb : ∀ i j, x = .big i → y = .big j → decide (M.big i = M.big j) = decide (i = j))
    (hr : ∀ r o r' o', x = .ptr (.ext r) o → y = .ptr (.ext r') o' →
      Nat.beq (M.region r) (M.region r') = Nat.beq r r') :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C
      (strictEq F s x y) (strictEq F t (M.val x) (M.val y)) := by
  have pf : ∀ b : Bool, MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C
      (Host.Ts.M.pure b) (Host.Ts.M.pure b) := fun b => MSim.pure ⟨rfl, Grow.refl h.srv⟩
  cases x <;> cases y
  all_goals (try (cases ‹Mem›))
  all_goals (try (cases ‹Mem›))
  all_goals (try exact pf _)
  case num.num x y => exact numTest_sim h.srv .eq x y
  case big.big i j =>
    show MSim _ S C (Host.Ts.M.pure (decide (i = j))) (Host.Ts.M.pure (decide (M.big i = M.big j)))
    rw [hb i j rfl rfl]
    exact pf _
  case sym.sym i j =>
    have e : Nat.beq (M.sym i) (M.sym j) = Nat.beq i j := by
      rw [Bool.eq_iff_iff, beq_iff, beq_iff]
      exact ⟨Map.sym_inj (n := S.tab.length) h.inj hx hy, fun e => e ▸ rfl⟩
    show MSim _ S C (Host.Ts.M.pure (Nat.beq i j)) (Host.Ts.M.pure (Nat.beq (M.sym i) (M.sym j)))
    rw [e]
    exact pf _
  case obj.obj a b =>
    show MSim _ S C (Host.Ts.M.pure (Nat.beq a b)) (Host.Ts.M.pure (Nat.beq (M.a a) (M.a b)))
    rw [beq_map h.inj hx hy]
    exact pf _
  case ptr.ptr.js.js ox oy bb bx =>
    show MSim _ S C (Host.Ts.M.pure (Nat.beq bx bb && Nat.beq ox oy))
      (Host.Ts.M.pure (Nat.beq (M.a bx) (M.a bb) && Nat.beq ox oy))
    rw [beq_map h.inj hx hy]
    exact pf _
  case ptr.ptr.ext.ext ox oy bb bx =>
    show MSim _ S C (Host.Ts.M.pure (Nat.beq bx bb && Nat.beq ox oy))
      (Host.Ts.M.pure (Nat.beq (M.region bx) (M.region bb) && Nat.beq ox oy))
    rw [hr bx ox bb oy rfl rfl]
    exact pf _

/-- Bigint and native-pointer comparisons the map keeps without injectivity: bigint
operands are both fixed, or equal; native pointers are into the same region. -/
def StrictOK (K : Ctx) (x y : Val) : Prop :=
  (∀ i j, x = .big i → y = .big j → BigFixed K.lo K.hi i ∧ BigFixed K.lo K.hi j ∨ i = j) ∧
  (∀ r o r' o', x = .ptr (.ext r) o → y = .ptr (.ext r') o' → r = r')

theorem strictEq_sim (h : Rel F FR M ν K s S t C) {x y : Val}
    (hx : Supp.val (Present s) S.tab.length x) (hy : Supp.val (Present s) S.tab.length y)
    (hok : StrictOK K x y) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C
      (strictEq F s x y) (strictEq F t (M.val x) (M.val y)) := by
  refine strictEq_sim_of h hx hy (fun i j hi hj => ?_) (fun r o r' o' hr hr' => ?_)
  · rcases hok.1 i j hi hj with ⟨hfi, hfj⟩ | rfl
    · rw [h.bigFixed i hfi, h.bigFixed j hfj]
    · rw [decide_eq_true rfl, decide_eq_true rfl]
  · obtain rfl := hok.2 r o r' o' hr hr'
    rw [Nat.beq_refl, Nat.beq_refl]

/-- Strict equality when the map is injective on bigints and native regions (not part of `Rel`). -/
theorem strictEq_sim_inj (h : Rel F FR M ν K s S t C) (hbig : ∀ i j, M.big i = M.big j → i = j)
    (hreg : ∀ r r', M.region r = M.region r' → r = r') {x y : Val}
    (hx : Supp.val (Present s) S.tab.length x) (hy : Supp.val (Present s) S.tab.length y) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C
      (strictEq F s x y) (strictEq F t (M.val x) (M.val y)) := by
  refine strictEq_sim_of h hx hy (fun i j _ _ => ?_) (fun r _ r' _ _ _ => ?_)
  · exact decide_eq_decide.2 ⟨hbig i j, fun e => e ▸ rfl⟩
  · rw [Bool.eq_iff_iff, beq_iff, beq_iff]
    exact ⟨hreg r r', fun e => e ▸ rfl⟩

/-! ### Folds of `defineData` (object spread, rest patterns) -/

theorem defineData_heap (s : St F.S) (a : Nat) (k : PKey) (v : Val) :
    (Host.Ts.defineData F s a k v).next = s.next ∧
      ((Host.Ts.defineData F s a k v) = s ∨ ∃ o, Host.Ts.defineData F s a k v = s.setObj a o) := by
  unfold Host.Ts.defineData
  cases s.obj? a with
  | none => exact ⟨rfl, .inl rfl⟩
  | some o =>
    obtain ⟨kd, pr, ps, pv, ex⟩ := o
    cases kd
    case array es =>
      cases keyIndex k
      · exact ⟨rfl, .inr ⟨_, rfl⟩⟩
      · exact ⟨rfl, .inr ⟨_, rfl⟩⟩
    all_goals exact ⟨rfl, .inr ⟨_, rfl⟩⟩

private theorem defineData_foldl_aux {a : Nat} (hfr : K.fr a = none) : ∀ (kvs : List (PKey × Val))
    {s t : St F.S}, Rel F FR M ν K s S t C → s.next < Sim.bound → Present s a →
    (∀ x ∈ kvs, Supp.key (Present s) S.tab.length x.1 ∧ Supp.val (Present s) S.tab.length x.2) →
    Rel F FR M ν K (kvs.foldl (fun s (k, x) => Host.Ts.defineData F s a k x) s) S
      ((M.kvs kvs).foldl (fun t (k, x) => Host.Ts.defineData F t (M.a a) k x) t) C
  | [], _, _, h, _, _, _ => h
  | (k, v) :: kvs, s, t, h, hn, ha, hkvs => by
    obtain ⟨hk, hv⟩ := hkvs (k, v) (List.mem_cons_self ..)
    have h1 := h.defineData hn ha hfr hk hv
    obtain ⟨hnext, hs⟩ := defineData_heap s a k v
    have hP : ∀ b, Present s b → Present (Host.Ts.defineData F s a k v) b := by
      rcases hs with hs | ⟨o, hs⟩
      · rw [hs]; exact fun _ hb => hb
      · rw [hs]; exact h.present_set hn ha o
    have hle : S.tab.length ≤ S.tab.length := Nat.le_refl _
    exact defineData_foldl_aux hfr kvs h1 (by rw [hnext]; exact hn) (hP a ha) fun x hx =>
      ⟨Supp.key_mono hP hle (hkvs x (List.mem_cons_of_mem _ hx)).1,
        Supp.val_mono hP hle (hkvs x (List.mem_cons_of_mem _ hx)).2⟩

theorem Rel.defineData_foldl (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) {a : Nat}
    (ha : Present s a) (hfr : K.fr a = none) (kvs : List (PKey × Val))
    (hkvs : ∀ x ∈ kvs, Supp.key (Present s) S.tab.length x.1 ∧ Supp.val (Present s) S.tab.length x.2) :
    Rel F FR M ν K (kvs.foldl (fun s (k, x) => Host.Ts.defineData F s a k x) s) S
      ((M.kvs kvs).foldl (fun t (k, x) => Host.Ts.defineData F t (M.a a) k x) t) C :=
  defineData_foldl_aux hfr kvs h hn ha hkvs

end

end Host.Ts.Sim
