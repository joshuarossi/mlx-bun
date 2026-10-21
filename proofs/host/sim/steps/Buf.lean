import host.sim.steps.Props
namespace Host.Ts.Sim

/-! # Typed arrays, buffers and DataViews

Helpers (namespace `BufSim`):
* `Lawful`: a machine computation runs its continuation on its own result
  (`interpS`/`interpC` of `m γ k` is the run of `m` followed by `k`). With it,
  `MSim.withRun` adds the source run to a simulation's postcondition, so side
  conditions can speak about values the source computes (decoded FFI arguments,
  native results).
* Number conversions with support of the result (`numUn_simS`, `truthy_sim`),
  `offsetArg`, `toCell`, `cellsOf`, `readCell` and `bufBytes` under the map.
* `newTyped`, `retS`, thrown errors and the native dispatch of `.call`/`.construct`. -/

namespace BufSim

/-! ## Lawful computations -/

def Lawful {α : Type} (m : Host.Ts.M α) : Prop :=
  (∀ (γ : Type) (k : α → Free γ) (S : SSrv),
    interpS (m γ k) S = (interpS m.run S).bind fun p => interpS (k p.1) p.2) ∧
  (∀ (γ : Type) (k : α → Free γ) (C : CSrv),
    interpC (m γ k) C = (interpC m.run C).bind fun p => interpC (k p.1) p.2)

theorem Lawful.pure {α : Type} (a : α) : Lawful (Host.Ts.M.pure a) :=
  ⟨fun _ _ _ => rfl, fun _ _ _ => rfl⟩

theorem Lawful.fail {α : Type} (msg : String) : Lawful (Host.Ts.M.fail (α := α) msg) :=
  ⟨fun _ _ _ => rfl, fun _ _ _ => rfl⟩

theorem Lawful.bind {α β : Type} {m : Host.Ts.M α} {f : α → Host.Ts.M β} (hm : Lawful m)
    (hf : ∀ a, Lawful (f a)) : Lawful (Host.Ts.M.bind m f) := by
  refine ⟨fun γ k S => ?_, fun γ k C => ?_⟩
  · show interpS (m γ fun a => f a γ k) S = (interpS (m β fun a => (f a).run) S).bind _
    rw [hm.1, hm.1, Option.bind_assoc]
    congr 1
    funext p
    exact (hf p.1).1 γ k p.2
  · show interpC (m γ fun a => f a γ k) C = (interpC (m β fun a => (f a).run) C).bind _
    rw [hm.2, hm.2, Option.bind_assoc]
    congr 1
    funext p
    exact (hf p.1).2 γ k p.2

theorem numUn_lawful (op : NUn) (x : NumV) : Lawful (numUn op x) := by
  cases x with
  | lit _ => exact Lawful.pure _
  | ref i =>
    refine ⟨fun γ k S => ?_, fun γ k C => ?_⟩
    · show interpS (.un op (.ref i) fun j => k (.ref j)) S =
        (interpS (.un op (.ref i) fun j => .pure (NumV.ref j)) S).bind _
      rw [interpS_un, interpS_un]
      cases S.val (.ref i) <;> rfl
    · show interpC (.un op (.ref i) fun j => k (.ref j)) C =
        (interpC (.un op (.ref i) fun j => .pure (NumV.ref j)) C).bind _
      rw [interpC_un, interpC_un]
      cases C.val (.ref i) <;> rfl

theorem numTest_lawful (op : NTest) (x y : NumV) : Lawful (numTest op x y) := by
  have req : ∀ a b : NumV, (∀ u v, a = .lit u → b = .lit v → False) →
      ∀ γ (k : Bool → Free γ), (numTest op a b) γ k = .test op a b k := by
    intro a b hab γ k
    cases a with
    | lit u =>
      cases b with
      | lit v => exact (hab u v rfl rfl).elim
      | ref _ => rfl
    | ref _ => cases b <;> rfl
  have gen : ∀ a b : NumV, (∀ u v, a = .lit u → b = .lit v → False) → Lawful (numTest op a b) := by
    intro a b hab
    refine ⟨fun γ k S => ?_, fun γ k C => ?_⟩
    · rw [req a b hab, Host.Ts.M.run, req a b hab, interpS_test, interpS_test]
      cases S.val a with
      | none => rfl
      | some ea =>
        cases S.val b with
        | none => rfl
        | some eb =>
          simp only
          cases S.answer op ea eb with
          | none => rfl
          | some p => rfl
    · rw [req a b hab, Host.Ts.M.run, req a b hab, interpC_test, interpC_test]
      cases C.val a with
      | none => rfl
      | some ea =>
        cases C.val b with
        | none => rfl
        | some eb => rfl
  cases x with
  | lit u =>
    cases y with
    | lit v => exact Lawful.pure _
    | ref j => exact gen _ _ (fun _ _ _ h => nomatch h)
  | ref i => exact gen _ _ (fun _ _ h _ => nomatch h)

/-- The source run, added to a simulation's postcondition. -/
theorem MSim.withRun {α β : Type} {P : Map → SSrv → CSrv → α → β → Prop} {S : SSrv} {C : CSrv}
    {m : Host.Ts.M α} {m' : Host.Ts.M β} (h : MSim P S C m m') (hs : Lawful m) (ht : Lawful m') :
    MSim (fun M' S' C' a b => P M' S' C' a b ∧ interpS m.run S = some (a, S')) S C m m' := by
  intro γ δ Q k k' hk r S2 hu
  rw [hs.1] at hu
  cases hrun : interpS m.run S with
  | none => rw [hrun] at hu; cases hu
  | some p =>
    obtain ⟨a, S1⟩ := p
    rw [hrun] at hu
    obtain ⟨M1, b, C1, hc, hp⟩ := MSim.run h a S1 hrun
    obtain ⟨M2, r', C2, hc', hq⟩ := hk M1 S1 C1 a b ⟨hp, hrun⟩ r S2 hu
    exact ⟨M2, r', C2, by rw [ht.2, hc]; exact hc', hq⟩


theorem Lawful.cond {α : Type} (c : Bool) {m1 m2 : Host.Ts.M α} (h1 : Lawful m1) (h2 : Lawful m2) :
    Lawful (bif c then m1 else m2) := by cases c <;> assumption

theorem typedGet_lawful (F : Ffi) (s : St F.S) (k : EltK) (b off n i : Nat) :
    Lawful (typedGet F s k b off n i) := by
  unfold typedGet
  refine Lawful.cond _ ?_ (Lawful.pure _)
  split
  · split
    · exact Lawful.pure _
    · exact Lawful.fail _
  · exact Lawful.fail _

theorem typedElems_lawful (F : Ffi) (s : St F.S) (k : EltK) (b off : Nat) :
    ∀ n i, Lawful (typedElems F s k b off n i)
  | 0, _ => Lawful.pure _
  | n + 1, i => by
    simp only [typedElems]
    refine Lawful.bind (typedGet_lawful F s k b off _ i) fun r => ?_
    rcases r with _ | ⟨v, w, e⟩ | ⟨g, st, e⟩
    · exact Lawful.fail _
    · exact Lawful.bind (typedElems_lawful F s k b off n (i + 1)) fun _ => Lawful.pure _
    · exact Lawful.fail _

theorem elemsOf_lawful (F : Ffi) (s : St F.S) (v : Val) : Lawful (elemsOf F s v) := by
  cases v with
  | obj a =>
    simp only [elemsOf]
    split
    · exact Lawful.pure _
    · exact Lawful.bind (typedElems_lawful _ _ _ _ _ _ _) fun _ => Lawful.pure _
    · exact Lawful.pure _
  | _ => exact Lawful.pure _

/-! ## Small facts -/

theorem arg_vals (M : Map) : ∀ (args : List Val) (i : Nat), arg (M.vals args) i = M.val (arg args i)
  | [], _ => rfl
  | _ :: _, 0 => rfl
  | _ :: as, i + 1 => arg_vals M as i

theorem lenL_map {α β : Type} (f : α → β) : ∀ (l : List α) (n : Nat), lenL (l.map f) n = lenL l n
  | [], _ => rfl
  | _ :: l, n => lenL_map f l (n + 1)

theorem len_map {α β : Type} (f : α → β) (l : List α) : len (l.map f) = len l := lenL_map f l 0

theorem cellA {A A' : Nat → Prop} {n : Nat} {c : Cell} (h : Supp.cell A n c) : Supp.cell A' n c := by
  cases c <;> exact h

theorem byteA {A A' : Nat → Prop} {n : Nat} {b : Byte} (h : Supp.byte A n b) : Supp.byte A' n b := by
  cases b with
  | lit _ => trivial
  | part _ c _ => exact cellA (c := c) h

theorem bytesA {A A' : Nat → Prop} {n : Nat} {bs : List Byte} (h : Supp.bytes A n bs) :
    Supp.bytes A' n bs := fun b hb => byteA (h b hb)

theorem bytes_mono {A : Nat → Prop} {n n' : Nat} {bs : List Byte} (h : Supp.bytes A n bs)
    (hn : n ≤ n') : Supp.bytes A n' bs := Supp.bytes_mono (fun _ ha => ha) hn h

theorem cell_mono {A : Nat → Prop} {n n' : Nat} {c : Cell} (h : Supp.cell A n c)
    (hn : n ≤ n') : Supp.cell A n' c := Supp.cell_mono (fun _ ha => ha) hn h

theorem bytes_append {A : Nat → Prop} {n : Nat} {xs ys : List Byte} (hx : Supp.bytes A n xs)
    (hy : Supp.bytes A n ys) : Supp.bytes A n (xs ++ ys) := fun b hb => by
  rcases List.mem_append.1 hb with hb | hb
  · exact hx b hb
  · exact hy b hb

theorem bytes_take {A : Nat → Prop} {n : Nat} {bs : List Byte} (h : Supp.bytes A n bs) (k : Nat) :
    Supp.bytes A n (bs.take k) := fun b hb => h b (List.mem_of_mem_take hb)

theorem bytes_drop {A : Nat → Prop} {n : Nat} {bs : List Byte} (h : Supp.bytes A n bs) (k : Nat) :
    Supp.bytes A n (bs.drop k) := fun b hb => h b (List.mem_of_mem_drop hb)

theorem cellParts_supp {A : Nat → Prop} {n : Nat} (k : EltK) {c : Cell} (hc : Supp.cell A n c) :
    ∀ m i, Supp.bytes A n (Host.Ts.cellParts k c m i)
  | 0, _ => fun _ hb => nomatch hb
  | m + 1, i => fun b hb => by
    rcases List.mem_cons.1 hb with rfl | hb
    · exact hc
    · exact cellParts_supp k hc m (i + 1) b hb

theorem cellBytes_map (M : Map) (k : EltK) : ∀ cs : List Cell,
    (cellBytes k cs).map M.byte = cellBytes k (cs.map M.cell)
  | [] => rfl
  | c :: cs => by
    simp only [cellBytes, List.map_append, List.map_cons, M.cellParts k c, cellBytes_map M k cs]

theorem cellBytes_supp {A : Nat → Prop} {n : Nat} (k : EltK) : ∀ {cs : List Cell},
    (∀ c ∈ cs, Supp.cell A n c) → Supp.bytes A n (cellBytes k cs)
  | [], _ => fun _ hb => nomatch hb
  | c :: _, h => bytes_append (cellParts_supp k (h c (List.mem_cons_self ..)) _ _)
      (cellBytes_supp k fun c' hc => h c' (List.mem_cons_of_mem _ hc))

/-! ## Numbers with support of the result -/

section
variable {ν : Nat → F64}

theorem numUn_simS {A : Nat → Prop} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (op : NUn)
    (a : NumV) :
    MSim (fun M' S' C' r r' => r' = M'.nv r ∧ Grow M ν S C M' S' C' ∧ Supp.nv A S'.tab.length r) S C
      (numUn op a) (numUn op (M.nv a)) := by
  refine MSim.mono (MSim.withRun (numUn_sim hs op a) (numUn_lawful _ _) (numUn_lawful _ _)) ?_
  rintro M' S' C' r r' ⟨⟨h1, h2⟩, hrun⟩
  refine ⟨h1, h2, ?_⟩
  cases a with
  | lit x =>
    simp only [Host.Ts.M.run, numUn, Host.Ts.M.pure, interpS_pure, Option.some.injEq,
      Prod.mk.injEq] at hrun
    obtain ⟨rfl, -⟩ := hrun
    trivial
  | ref i =>
    change interpS (.un op (.ref i) fun j => .pure (NumV.ref j)) S = some (r, S') at hrun
    rw [interpS_un] at hrun
    cases hv : S.val (.ref i) with
    | none => rw [hv] at hrun; cases hrun
    | some e =>
      rw [hv] at hrun
      simp only [interpS_pure, Option.some.injEq, Prod.mk.injEq] at hrun
      obtain ⟨rfl, rfl⟩ := hrun
      show S.tab.length < (S.tab ++ [SymE.un op e]).length
      simp

/-- `offsetArg` reads a literal (or `undefined`): both sides read the same offset. -/
def offsetP : Val → Option Nat
  | .undef => some 0
  | .num (.lit x) => F64.toIndex? x
  | _ => none

theorem offsetArg_msim {β β' : Type} {P : Map → SSrv → CSrv → β → β' → Prop} {S : SSrv} {C : CSrv}
    (M : Map) (v : Val) {f : Nat → Host.Ts.M β} {f' : Nat → Host.Ts.M β'}
    (hf : ∀ n, offsetP v = some n → MSim P S C (f n) (f' n)) :
    MSim P S C (Host.Ts.M.bind (offsetArg v) f) (Host.Ts.M.bind (offsetArg (M.val v)) f') := by
  cases v with
  | undef => exact hf 0 rfl
  | num x =>
    cases x with
    | lit x =>
      cases hx : F64.toIndex? x with
      | none =>
        show MSim P S C (Host.Ts.M.bind (match F64.toIndex? x with
          | some n => Host.Ts.M.pure n | none => Host.Ts.M.fail "offset") f) _
        rw [hx]
        exact MSim.fail _ _
      | some n =>
        show MSim P S C (Host.Ts.M.bind (match F64.toIndex? x with
          | some n => Host.Ts.M.pure n | none => Host.Ts.M.fail "offset") f)
          (Host.Ts.M.bind (match F64.toIndex? x with
          | some n => Host.Ts.M.pure n | none => Host.Ts.M.fail "offset") f')
        rw [hx]
        exact hf n hx
    | ref _ => exact MSim.fail _ _
  | _ => exact MSim.fail _ _

theorem truthy_sim {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (v : Val)
    (hb : ∀ i, v = .big i → M.big i = i) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C (truthy v) (truthy (M.val v)) := by
  cases v with
  | num x => exact numTest_sim hs .truthy x zeroN
  | big i =>
    show MSim _ S C (Host.Ts.M.pure _) (Host.Ts.M.pure _)
    rw [hb i rfl]
    exact MSim.pure ⟨rfl, Grow.refl hs⟩
  | _ => exact MSim.pure ⟨rfl, Grow.refl hs⟩

/-! ## Element conversion -/

/-- `toCell` of a bigint. -/
def toCellBig (k : EltK) (i : Int) : Option Cell :=
  match k with
  | .i64 => some (.big (signed 64 (modInt i (2 ^ 64))))
  | .u64 => some (.big (modInt i (2 ^ 64) : Nat))
  | _ => none

theorem toCell_big (k : EltK) (i : Int) : toCell k (.big i) = Host.Ts.M.pure (toCellBig k i) := by
  cases k <;> rfl

/-- The postcondition of element conversions. -/
def CellP (A : Nat → Prop) (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) :
    Map → SSrv → CSrv → Option Cell → Option Cell → Prop :=
  fun M' S' C' r r' => r' = r.map M'.cell ∧ Grow M ν S C M' S' C' ∧
    ∀ c, r = some c → Supp.cell A S'.tab.length c

theorem numUn_cell {A : Nat → Prop} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (op : NUn)
    (x : NumV) :
    MSim (CellP A M ν S C) S C
      (Host.Ts.M.bind (numUn op x) fun y => Host.Ts.M.pure (some (Cell.num y)))
      (Host.Ts.M.bind (numUn op (M.nv x)) fun y => Host.Ts.M.pure (some (Cell.num y))) :=
  MSim.bind (numUn_simS (A := A) hs op x) fun M' S' C' y y' ⟨h1, h2, h3⟩ =>
    MSim.pure ⟨by rw [h1]; rfl, h2, fun c hc => by cases hc; exact h3⟩

theorem numCell_sim {A : Nat → Prop} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (k : EltK)
    (x : NumV) (hx : Supp.nv A S.tab.length x) :
    MSim (CellP A M ν S C) S C (numCell k x) (numCell k (M.nv x)) := by
  cases k
  case f64 => exact MSim.pure ⟨rfl, Grow.refl hs, fun c hc => by cases hc; exact hx⟩
  case i64 => exact MSim.pure ⟨rfl, Grow.refl hs, fun c hc => nomatch hc⟩
  case u64 => exact MSim.pure ⟨rfl, Grow.refl hs, fun c hc => nomatch hc⟩
  all_goals exact numUn_cell hs _ x

theorem toCell_sim {A : Nat → Prop} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (k : EltK)
    (v : Val) (hv : Supp.val A S.tab.length v)
    (hb : ∀ i, v = .big i → toCellBig k (M.big i) = (toCellBig k i).map M.cell) :
    MSim (CellP A M ν S C) S C (toCell k v) (toCell k (M.val v)) := by
  cases v with
  | num x => exact numCell_sim hs k x hv
  | big i =>
    show MSim _ S C (toCell k (.big i)) (toCell k (.big (M.big i)))
    rw [toCell_big, toCell_big, hb i rfl]
    refine MSim.pure ⟨rfl, Grow.refl hs, fun c hc => ?_⟩
    cases k <;> simp only [toCellBig, Option.some.injEq, reduceCtorEq] at hc <;> first | (subst hc; trivial) | skip
  | bool b => exact numCell_sim hs k _ trivial
  | null => exact numCell_sim hs k _ trivial
  | undef =>
    cases k <;> exact MSim.pure ⟨rfl, Grow.refl hs, fun c hc => by
      simp only [Option.some.injEq, reduceCtorEq] at hc
      first | (subst hc; trivial) | skip⟩
  | _ => exact MSim.pure ⟨rfl, Grow.refl hs, fun c hc => nomatch hc⟩

end


section
variable {ν : Nat → F64}

theorem toCellBig_cell {M M' : Map} (hb : M'.big = M.big) (k : EltK) (i : Int) :
    (toCellBig k i).map M'.cell = (toCellBig k i).map M.cell := by
  cases k <;> simp [toCellBig, Map.cell, hb]

/-- The postcondition of `cellsOf`. -/
def CellsP (A : Nat → Prop) (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) :
    Map → SSrv → CSrv → Option (List Cell) → Option (List Cell) → Prop :=
  fun M' S' C' r r' => r' = r.map (List.map M'.cell) ∧ Grow M ν S C M' S' C' ∧
    ∀ cs, r = some cs → ∀ c ∈ cs, Supp.cell A S'.tab.length c

theorem cellsOf_sim {A : Nat → Prop} (k : EltK) : ∀ (vs : List Val) {M : Map} {S : SSrv} {C : CSrv},
    Srv M ν S C → Supp.vals A S.tab.length vs →
    (∀ i, Val.big i ∈ vs → toCellBig k (M.big i) = (toCellBig k i).map M.cell) →
    MSim (CellsP A M ν S C) S C (cellsOf k vs) (cellsOf k (M.vals vs))
  | [], M, S, C, hs, _, _ => MSim.pure ⟨rfl, Grow.refl hs, fun cs hcs c hc => by
      cases hcs; exact nomatch hc⟩
  | v :: vs, M, S, C, hs, hv, hb => by
    show MSim _ S C (Host.Ts.M.bind (toCell k v) _) (Host.Ts.M.bind (toCell k (M.val v)) _)
    refine MSim.bind (toCell_sim (A := A) hs k v (hv v (List.mem_cons_self ..))
      (fun i hi => hb i (by rw [← hi]; exact List.mem_cons_self ..))) ?_
    rintro M1 S1 C1 r r' ⟨rfl, g1, s1⟩
    cases r with
    | none => exact MSim.pure ⟨rfl, g1, fun cs hcs => nomatch hcs⟩
    | some c =>
      have hvs : Supp.vals A S.tab.length vs := fun w hw => hv w (List.mem_cons_of_mem _ hw)
      have he : M.vals vs = M1.vals vs := Map.vals_agree (g1.ext.agree (A := A)) hvs
      show MSim _ S1 C1 (Host.Ts.M.bind (cellsOf k vs) _) (Host.Ts.M.bind (cellsOf k (M.vals vs)) _)
      rw [he]
      refine MSim.bind (cellsOf_sim k vs g1.srv (Supp.vals_mono (fun _ h => h) g1.len hvs)
        (fun i hi => by
          rw [toCellBig_cell g1.ext.big, g1.ext.big]
          exact hb i (List.mem_cons_of_mem _ hi))) ?_
      rintro M2 S2 C2 r2 r2' ⟨rfl, g2, s2⟩
      have hc : Supp.cell A S1.tab.length c := s1 c rfl
      have hmc : M1.cell c = M2.cell c := Map.cell_agree (g2.ext.agree (A := A)) hc
      refine MSim.pure ⟨?_, g1.trans g2, ?_⟩
      · cases r2 <;> simp [hmc]
      · intro cs hcs c' hc'
        cases r2 with
        | none => cases hcs
        | some cs2 =>
          simp only [Option.map_some, Option.some.injEq] at hcs
          subst hcs
          rcases List.mem_cons.1 hc' with rfl | hc'
          · exact cell_mono hc g2.len
          · exact s2 cs2 rfl c' hc'

end

/-! ## Bigint conversions under the map -/

def CellFixed (lo hi : Nat) : Cell → Prop
  | .num _ => True
  | .big i => BigFixed lo hi i

def ByteFixed (lo hi : Nat) : Byte → Prop
  | .lit _ => True
  | .part _ c _ => CellFixed lo hi c

/-- A bigint stored into a 64-bit element: fixed by the map with a fixed result, or a
renamed handle (in the band). -/
def BigConvOK (K : Ctx) (k : EltK) (i : Int) : Prop :=
  (BigFixed K.lo K.hi i ∧ ∀ c, toCellBig k i = some c → CellFixed K.lo K.hi c) ∨
    ((K.lo : Int) ≤ i ∧ i < K.hi)

/-- The range of a 64-bit element of kind `k`: the image of a renamed handle stored into a
`BigInt64Array`/`BigUint64Array` must lie in it (a map fact the native relation knows). -/
def BigRange (k : EltK) (j : Int) : Prop :=
  0 ≤ j ∧ j < (match k with | .i64 => 2 ^ 63 | _ => 2 ^ 64)

theorem modInt_small {x : Int} (h0 : 0 ≤ x) (h1 : x < 2 ^ 64) : ((modInt x (2 ^ 64) : Nat) : Int) = x := by
  unfold modInt
  have : x % ((2 ^ 64 : Nat) : Int) = x := Int.emod_eq_of_lt h0 (by simpa using h1)
  rw [this, Int.toNat_of_nonneg h0]

theorem signed_small {x : Int} (h0 : 0 ≤ x) (h1 : x < 2 ^ 63) : signed 64 (modInt x (2 ^ 64)) = x := by
  have hm := modInt_small h0 (by omega)
  unfold signed
  have hlt : Nat.blt (modInt x (2 ^ 64)) (2 ^ (64 - 1)) = true := by
    rw [Nat.blt_eq]
    omega
  rw [hlt]
  exact hm

theorem CellFixed.cell {M : Map} {lo hi : Nat} (hfix : ∀ i, BigFixed lo hi i → M.big i = i) {c : Cell}
    (hc : CellFixed lo hi c) (hlit : ∀ x, c = .num x → ∃ y, x = .lit y) : M.cell c = c := by
  cases c with
  | num x =>
    obtain ⟨y, rfl⟩ := hlit x rfl
    rfl
  | big i => show Cell.big (M.big i) = .big i; rw [hfix i hc]

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

theorem toCellBig_map (h : Rel F FR M ν K s S t C) {k : EltK} {i : Int} (hc : BigConvOK K k i)
    (hr : (K.lo : Int) ≤ i → i < K.hi → BigRange k (M.big i)) :
    toCellBig k (M.big i) = (toCellBig k i).map M.cell := by
  rcases hc with ⟨hfi, hres⟩ | ⟨hlo, hhi⟩
  · rw [h.bigFixed i hfi]
    cases hk : toCellBig k i with
    | none => rfl
    | some c =>
      have hcf := hres c hk
      have : M.cell c = c := CellFixed.cell h.bigFixed hcf (fun x hx => by
        subst hx; cases k <;> simp [toCellBig] at hk)
      rw [Option.map_some, this]
  · have hband := h.band
    obtain ⟨hb0, hb1⟩ := hr hlo hhi
    have hi0 : 0 ≤ i := by omega
    have hi1 : i < 2 ^ 63 := by
      have : (K.hi : Int) ≤ 2 ^ 56 := by exact_mod_cast hband
      omega
    cases k <;> simp only [toCellBig, Option.map_some, Option.map_none, Map.cell]
    · rw [signed_small hb0 hb1, signed_small hi0 hi1]
    · rw [modInt_small hb0 hb1, modInt_small hi0 (by omega)]

end

/-! ## Reading elements from bytes -/

theorem partsFrom_map (M : Map) (k : EltK) : ∀ (bs : List Byte) (i n : Nat),
    wholeCell.partsFrom k (bs.map M.byte) i n = wholeCell.partsFrom k bs i n
  | [], _, _ => rfl
  | .lit _ :: _, _, _ => rfl
  | .part j c m :: rest, i, n => by
    show (kindEq j k && Nat.beq m i && wholeCell.partsFrom k (rest.map M.byte) (i + 1) n) = _
    rw [partsFrom_map M k rest]
    rfl

theorem wholeCell_map (M : Map) (k : EltK) (bs : List Byte) (n : Nat) :
    wholeCell k (bs.map M.byte) n = (wholeCell k bs n).map M.cell := by
  cases bs with
  | nil => rfl
  | cons b rest =>
    cases b with
    | lit _ => rfl
    | part j c m =>
      cases m with
      | zero =>
        show (bif kindEq j k && wholeCell.partsFrom k (rest.map M.byte) 1 n then some (M.cell c) else none) =
          (bif kindEq j k && wholeCell.partsFrom k rest 1 n then some c else none).map M.cell
        rw [partsFrom_map]
        cases kindEq j k && wholeCell.partsFrom k rest 1 n <;> rfl
      | succ _ => rfl

theorem concBytes_map {M : Map} {lo hi : Nat} (hfix : ∀ i, BigFixed lo hi i → M.big i = i) :
    ∀ {bs : List Byte} {ns : List Nat}, (∀ b ∈ bs, ByteFixed lo hi b) → concBytes bs = some ns →
      concBytes (bs.map M.byte) = some ns
  | [], _, _, h => h
  | b :: bs, ns, hf, h => by
    simp only [concBytes, List.map_cons] at h ⊢
    cases hb : concByte b with
    | none => rw [hb] at h; cases h
    | some x =>
      rw [hb] at h
      cases hr : concBytes bs with
      | none => rw [hr] at h; cases h
      | some ns' =>
        rw [hr] at h
        have hb' : concByte (M.byte b) = some x := by
          have hfb := hf b (List.mem_cons_self ..)
          cases b with
          | lit _ => exact hb
          | part k c i =>
            cases c with
            | num v =>
              cases v with
              | lit _ => exact hb
              | ref _ => cases hb
            | big j =>
              show concByte (.part k (.big (M.big j)) i) = some x
              rw [hfix j hfb]
              exact hb
        rw [hb', concBytes_map hfix (fun b' hm => hf b' (List.mem_cons_of_mem _ hm)) hr]
        exact h

/-- A source element read the target reads as the image: the element bytes form one
written element, or they are concrete with fixed bigints and a fixed result. The
result is closed. -/
def ReadOK (lo hi n : Nat) (k : EltK) (bs : List Byte) : Prop :=
  ∀ c, readCell k bs = some c → Supp.cell (fun _ => True) n c ∧
    ((wholeCell k (bs.take k.size) k.size).isSome = true ∨
      ((∀ b ∈ bs.take k.size, ByteFixed lo hi b) ∧ CellFixed lo hi c))

theorem decodeCell_lit (k : EltK) (ns : List Nat) (x : NumV) (h : decodeCell k ns = .num x) :
    ∃ y, x = .lit y := by
  cases k <;> simp only [decodeCell, Cell.num.injEq, reduceCtorEq] at h <;> exact ⟨_, h.symm⟩

theorem readCell_map {M : Map} {lo hi n : Nat} (hfix : ∀ i, BigFixed lo hi i → M.big i = i)
    {k : EltK} {bs : List Byte} {c : Cell} (hok : ReadOK lo hi n k bs) (hc : readCell k bs = some c) :
    readCell k (bs.map M.byte) = some (M.cell c) := by
  obtain ⟨-, hw⟩ := hok c hc
  dsimp only [readCell] at hc ⊢
  rw [← List.map_take, wholeCell_map]
  cases hwc : wholeCell k (bs.take k.size) k.size with
  | some c0 =>
    rw [hwc] at hc
    cases hc
    rfl
  | none =>
    rw [hwc] at hc hw
    rcases hw with hw | ⟨hbf, hcf⟩
    · cases hw
    · simp only [Option.map_none]
      cases hcb : concBytes (bs.take k.size) with
      | none => rw [hcb] at hc; cases hc
      | some ns =>
        rw [hcb] at hc
        rw [concBytes_map hfix hbf hcb]
        simp only [Option.bind_some] at hc ⊢
        cases hl : Nat.beq (len ns) k.size
        · rw [hl] at hc; cases hc
        · simp only [hl, Bool.cond_true, Option.some.injEq] at hc ⊢
          subst hc
          rw [CellFixed.cell hfix hcf (decodeCell_lit k ns)]


/-! ## Heap lookups and buffers under the relation -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

theorem s64 (hn : s.next < Sim.bound) : s.next < 2 ^ 64 := by
  have hb : Sim.bound = 2 ^ 61 := rfl
  rw [hb] at hn
  omega

theorem obj?_cell {s : St F.S} {a : Nat} {v : Option Val} (hg : s.heap.get a = some (.cell v)) :
    s.obj? a = none := by
  unfold St.obj?; rw [hg]

/-- A non-array object is never framed: its target image is the mapped object. -/
theorem obj?_plain (h : Rel F FR M ν K s S t C) {a : Nat} {o : Obj}
    (ho : s.obj? a = some o) (hk : ∀ es, o.kind ≠ .array es) : t.obj? (M.a a) = some (M.obj o) := by
  cases hfr : K.fr a with
  | none => exact h.obj? ho hfr
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    obtain ⟨_, _, ⟨xs, hk', _⟩⟩ := h.obj?_framed ho hfr
    exact absurd hk' (hk _)

/-- A lookup at a present address: nothing on both sides, the image, or arrays on both sides
(framed arrays). -/
theorem obj?_cases (h : Rel F FR M ν K s S t C) {a : Nat} (hp : Present s a) :
    (s.obj? a = none ∧ t.obj? (M.a a) = none) ∨
    (∃ o, s.obj? a = some o ∧ t.obj? (M.a a) = some (M.obj o)) ∨
    (∃ o o' es es', s.obj? a = some o ∧ t.obj? (M.a a) = some o' ∧ o.kind = .array es ∧
      o'.kind = .array es') := by
  obtain ⟨h0, hg⟩ := hp.get
  cases h0 with
  | cell v =>
    have ht := h.get hg (h.fr_cell hg)
    exact .inl ⟨obj?_cell hg, obj?_cell (v := v.map M.val) ht⟩
  | obj o =>
    have ho : s.obj? a = some o := obj?_iff.2 hg
    cases hfr : K.fr a with
    | none => exact .inr (.inl ⟨o, ho, h.obj? ho hfr⟩)
    | some p =>
      obtain ⟨pre, pre'⟩ := p
      obtain ⟨o', ht, ⟨xs, hk, rfl⟩⟩ := h.obj?_framed ho hfr
      exact .inr (.inr ⟨o, _, _, _, ho, ht, hk, rfl⟩)

/-- A source buffer's bytes: the target buffer at the image holds their image. -/
theorem bufBytes_rel {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {b : Nat} {bs : List Byte}
    (hb : bufBytes F s b = some bs) : bufBytes F t (M.a b) = some (bs.map M.byte) := by
  unfold bufBytes at hb ⊢
  cases ho : s.obj? b with
  | none => rw [ho] at hb; cases hb
  | some o =>
    rw [ho] at hb
    obtain ⟨k, p, ps, pv, e⟩ := o
    cases k with
    | buf bs0 =>
      cases hb
      rw [obj?_plain h ho (fun _ h => nomatch h)]
      rfl
    | extBuf r off len =>
      rw [obj?_plain h ho (fun _ h => nomatch h)]
      exact hF.read M S.tab.length s.ffi t.ffi r off len bs h.ffi hb
    | _ => cases hb

/-- Side condition on a buffer address: if it is an external buffer, its native memory is
readable and holds closed bytes. -/
def BufOK (F : Ffi) (s : St F.S) (n : Nat) (b : Nat) : Prop :=
  ∀ o, s.obj? b = some o → ∀ r off len, o.kind = .extBuf r off len →
    ∃ bs, F.read s.ffi r off len = some bs ∧ Supp.bytes (fun _ => True) n bs

/-- At a present address with `BufOK`, the target's bytes are exactly the image, and the
source bytes are closed. -/
theorem bufBytes_exact {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {b : Nat} (hp : Present s b)
    (hok : BufOK F s S.tab.length b) :
    bufBytes F t (M.a b) = (bufBytes F s b).map (List.map M.byte) ∧
      ∀ bs, bufBytes F s b = some bs → Supp.bytes (Present s) S.tab.length bs := by
  rcases obj?_cases h hp with ⟨hs, ht⟩ | ⟨o, hs, ht⟩ | ⟨o, o', es, es', hs, ht, hk, hk'⟩
  · unfold bufBytes; rw [hs, ht]; exact ⟨rfl, fun _ h => nomatch h⟩
  · obtain ⟨k, p, ps, pv, e⟩ := o
    have hsupp := h.obj?_supp hs
    cases k with
    | buf bs0 =>
      unfold bufBytes; rw [hs, ht]
      exact ⟨rfl, fun bs hb => by cases hb; exact hsupp.1⟩
    | extBuf r off len =>
      obtain ⟨bs, hr, hbs⟩ := hok _ hs r off len rfl
      unfold bufBytes; rw [hs, ht]
      refine ⟨?_, fun bs' hb => ?_⟩
      · show F.read t.ffi (M.region r) off len = (F.read s.ffi r off len).map (List.map M.byte)
        rw [hr, hF.read M S.tab.length s.ffi t.ffi r off len bs h.ffi hr]
        rfl
      · change F.read s.ffi r off len = some bs' at hb
        rw [hr] at hb
        cases hb
        exact bytesA hbs
    | _ => unfold bufBytes; rw [hs, ht]; exact ⟨rfl, fun _ h => nomatch h⟩
  · obtain ⟨k, p, ps, pv, e⟩ := o
    obtain ⟨k', p', ps', pv', e'⟩ := o'
    simp only at hk hk'
    subst hk hk'
    unfold bufBytes; rw [hs, ht]; exact ⟨rfl, fun _ h => nomatch h⟩

/-! ## Control steps -/

theorem sim_rel {s' t' : St F.S} (h : Rel F FR M ν K s' S t' C) :
    MSim (StepPost F FR M ν K S C) S C (Host.Ts.M.pure s') (Host.Ts.M.pure t') :=
  MSim.pure ⟨Grow.refl h.srv, h⟩

theorem sim_ret (h : Rel F FR M ν K s S t C) (v : Val) (hv : Supp.val (Present s) S.tab.length v) :
    MSim (StepPost F FR M ν K S C) S C (retS F s v) (retS F t (M.val v)) :=
  sim_rel (h.ret v hv)

/-- Throwing a new error object with an intrinsic prototype. -/
theorem throwErr_sim (h : Rel F FR M ν K s S t C) (p : Nat) (msg : List Char)
    (hn : s.next < Sim.bound) (hI : M.a p = p) (hp : Present s p) :
    MSim (StepPost F FR M ν K S C) S C (throwErr s p msg) (throwErr t p msg) := by
  have h64 := s64 hn
  let ps : Props := [(.str ['m','e','s','s','a','g','e'], .data (.str msg) true false)]
  have hP : ∀ a, Present s a → Present (s.allocObj .ordinary (.obj p) ps).2 a :=
    fun _ ha => Present.alloc _ h64 ha
  have hv : M.val (.obj p) = .obj p := by show Val.obj (M.a p) = .obj p; rw [hI]
  obtain ⟨ha, hr⟩ := h.allocObj .ordinary (.obj p) ps hn trivial (hP p hp)
    (fun x hx => by
      simp only [ps, List.mem_cons, List.not_mem_nil, or_false] at hx
      subst hx
      exact ⟨trivial, trivial⟩)
  rw [hv] at ha hr
  have := sim_rel (hr.go (.abr (.throw (.obj (s.allocObj .ordinary (.obj p) ps).1)))
    (Present.alloc_next s _ h64))
  rw [show M.ctl (.abr (.throw (.obj (s.allocObj .ordinary (.obj p) ps).1))) =
    .abr (.throw (.obj (M.a (s.allocObj .ordinary (.obj p) ps).1))) from rfl, ← ha] at this
  exact this

theorem typeErr_sim (h : Rel F FR M ν K s S t C) (msg : List Char) (hn : s.next < Sim.bound)
    (hI : ∀ a, a < aFirst → M.a a = a) (hp : Present s aTypeErrorProto) :
    MSim (StepPost F FR M ν K S C) S C (typeErr s msg) (typeErr t msg) :=
  throwErr_sim h _ msg hn (hI _ (by decide)) hp

theorem rangeErr_sim (h : Rel F FR M ν K s S t C) (msg : List Char) (hn : s.next < Sim.bound)
    (hI : ∀ a, a < aFirst → M.a a = a) (hp : Present s aRangeErrorProto) :
    MSim (StepPost F FR M ν K S C) S C (rangeErr s msg) (rangeErr t msg) :=
  throwErr_sim h _ msg hn (hI _ (by decide)) hp

/-- Allocate an object with an intrinsic prototype and return it. -/
theorem allocObj_ret_sim (h : Rel F FR M ν K s S t C) (k : Kind) (p : Nat)
    (hn : s.next < Sim.bound) (hI : M.a p = p) (hp : Present s p)
    (hk : Supp.kind (Present s) S.tab.length k) :
    MSim (StepPost F FR M ν K S C) S C
      (retS F (s.allocObj k (.obj p) []).2 (.obj (s.allocObj k (.obj p) []).1))
      (retS F (t.allocObj (M.kind k) (.obj p) []).2 (.obj (t.allocObj (M.kind k) (.obj p) []).1)) := by
  have h64 := s64 hn
  have hP : ∀ a, Present s a → Present (s.allocObj k (.obj p) []).2 a :=
    fun _ ha => Present.alloc _ h64 ha
  have hv : M.val (.obj p) = .obj p := by show Val.obj (M.a p) = .obj p; rw [hI]
  obtain ⟨ha, hr⟩ := h.allocObj k (.obj p) [] hn (Supp.kind_mono hP (Nat.le_refl _) hk) (hP p hp)
    (fun _ hx => nomatch hx)
  rw [hv] at ha hr
  have := sim_ret hr (.obj (s.allocObj k (.obj p) []).1) (Present.alloc_next s _ h64)
  rw [show M.val (.obj (s.allocObj k (.obj p) []).1) = .obj (M.a (s.allocObj k (.obj p) []).1) from rfl,
    ← ha] at this
  exact this

/-- `newTyped`: a fresh buffer and a typed array over it, returned. -/
theorem newTyped_sim (h : Rel F FR M ν K s S t C) (k : EltK) (proto : Nat) (bytes : List Byte) (n : Nat)
    (hn : s.next + 2 < Sim.bound) (hpl : proto < aFirst)
    (hp14 : Present s aArrayBufferProto) (hpp : Present s proto)
    (hb : Supp.bytes (Present s) S.tab.length bytes) :
    MSim (StepPost F FR M ν K S C) S C
      (retS F (newTyped F s k proto bytes n).2 (.obj (newTyped F s k proto bytes n).1))
      (retS F (newTyped F t k proto (bytes.map M.byte) n).2
        (.obj (newTyped F t k proto (bytes.map M.byte) n).1)) := by
  have hI := h.intr
  have hn1 : s.next < Sim.bound := by omega
  have h64 := s64 hn1
  have hP : ∀ a, Present s a → Present (s.allocObj (.buf bytes) (.obj aArrayBufferProto) []).2 a :=
    fun _ ha => Present.alloc _ h64 ha
  have hv : M.val (.obj aArrayBufferProto) = .obj aArrayBufferProto := by
    show Val.obj (M.a aArrayBufferProto) = _; rw [hI _ (by decide)]
  obtain ⟨ha, hr⟩ := h.allocObj (.buf bytes) (.obj aArrayBufferProto) [] hn1
    (Supp.bytes_mono hP (Nat.le_refl _) hb) (hP _ hp14) (fun _ hx => nomatch hx)
  rw [hv] at ha hr
  have hn2 : (s.allocObj (.buf bytes) (.obj aArrayBufferProto) []).2.next < Sim.bound := by
    show s.next + 1 < Sim.bound; omega
  have := allocObj_ret_sim hr (.typed k (s.allocObj (.buf bytes) (.obj aArrayBufferProto) []).1 0 n)
    proto hn2 (hI _ hpl) (hP _ hpp) (Present.alloc_next s _ h64)
  rw [show M.kind (.typed k (s.allocObj (.buf bytes) (.obj aArrayBufferProto) []).1 0 n) =
    .typed k (M.a (s.allocObj (.buf bytes) (.obj aArrayBufferProto) []).1) 0 n from rfl, ← ha] at this
  exact this

/-! ## Native dispatch -/

theorem step_call_native {a : Nat} {this : Val} {args : List Val} {o : Obj} {n : Native}
    {data : List Val} (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native n data)) : step F s = callNative F s n data this args := by
  simp only [step, hc, callStep, ho, hk]

theorem step_call_native_t (h : Rel F FR M ν K s S t C) {a : Nat} {this : Val} {args : List Val}
    {o : Obj} {n : Native} {data : List Val} (hc : s.ctl = .call (.obj a) this args)
    (ho : s.obj? a = some o) (hk : o.kind = .fn (.native n data)) :
    step F t = callNative F t n (M.vals data) (M.val this) (M.vals args) := by
  have htc : t.ctl = .call (.obj (M.a a)) (M.val this) (M.vals args) := by rw [h.ctl, hc]; rfl
  have hto : t.obj? (M.a a) = some (M.obj o) := obj?_plain h ho (by rw [hk]; exact fun _ h => nomatch h)
  have htk : (M.obj o).kind = .fn (.native n (M.vals data)) := by
    show M.kind o.kind = _; rw [hk]; rfl
  simp only [step, htc, callStep, hto, htk]

theorem step_construct_native {a : Nat} {args : List Val} {nt : Val} {o : Obj} {n : Native}
    {data : List Val} (hc : s.ctl = .construct (.obj a) args nt) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native n data)) : step F s = constructNative F s n data args nt := by
  simp only [step, hc, constructStep, ho, hk]

theorem step_construct_native_t (h : Rel F FR M ν K s S t C) {a : Nat} {args : List Val} {nt : Val}
    {o : Obj} {n : Native} {data : List Val} (hc : s.ctl = .construct (.obj a) args nt)
    (ho : s.obj? a = some o) (hk : o.kind = .fn (.native n data)) :
    step F t = constructNative F t n (M.vals data) (M.vals args) (M.val nt) := by
  have htc : t.ctl = .construct (.obj (M.a a)) (M.vals args) (M.val nt) := by rw [h.ctl, hc]; rfl
  have hto : t.obj? (M.a a) = some (M.obj o) := obj?_plain h ho (by rw [hk]; exact fun _ h => nomatch h)
  have htk : (M.obj o).kind = .fn (.native n (M.vals data)) := by
    show M.kind o.kind = _; rw [hk]; rfl
  simp only [step, htc, constructStep, hto, htk]

theorem call_supp (h : Rel F FR M ν K s S t C) {f this : Val} {args : List Val}
    (hc : s.ctl = .call f this args) :
    Supp.val (Present s) S.tab.length this ∧ Supp.vals (Present s) S.tab.length args := by
  have := h.ctlSupp
  rw [hc] at this
  exact ⟨this.2.1, this.2.2⟩

theorem construct_supp (h : Rel F FR M ν K s S t C) {f nt : Val} {args : List Val}
    (hc : s.ctl = .construct f args nt) : Supp.vals (Present s) S.tab.length args := by
  have := h.ctlSupp
  rw [hc] at this
  exact this.2.1

theorem arg_supp {A : Nat → Prop} {n : Nat} {args : List Val} (h : Supp.vals A n args) (i : Nat) :
    Supp.val A n (arg args i) := by
  induction args generalizing i with
  | nil => trivial
  | cons v vs ih =>
    cases i with
    | zero => exact h v (List.mem_cons_self ..)
    | succ i => exact ih (fun w hw => h w (List.mem_cons_of_mem _ hw)) i

end


section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

theorem margin2 (hn : s.next + margin < Sim.bound) : s.next + 2 < Sim.bound := by
  have : 2 < margin := by decide
  omega

theorem lits_map (M : Map) (ns : List Nat) : (ns.map Byte.lit).map M.byte = ns.map Byte.lit := by
  rw [List.map_map]; rfl

theorem lits_supp {A : Nat → Prop} {n : Nat} (ns : List Nat) : Supp.bytes A n (ns.map Byte.lit) :=
  fun b hb => by
    obtain ⟨_, _, rfl⟩ := List.mem_map.1 hb
    trivial

/-- `Buffer.from(string)`: a `Uint8Array` of the UTF-8 bytes. -/
theorem _root_.Host.Ts.Sim.step_buf_bufferFrom (h : Rel F FR M ν K s S t C) {a : Nat} {this : Val} {args : List Val}
    {o : Obj} {data : List Val} (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.buf .bufferFrom) data)) (hn : s.next + margin < Sim.bound)
    (hp14 : Present s aArrayBufferProto)
    (hp38 : Present s aBufferProto) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  have hI := h.intr
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  show MSim _ S C (bufN F s this args data .bufferFrom)
    (bufN F t (M.val this) (M.vals args) (M.vals data) .bufferFrom)
  unfold bufN
  rw [arg_vals]
  cases harg : arg args 0 with
  | str cs =>
    have := newTyped_sim h .u8 aBufferProto ((utf8 cs).map Byte.lit) (len (utf8 cs)) (margin2 hn)
      (by decide) hp14 hp38 (lits_supp _)
    rw [lits_map] at this
    exact this
  | _ => exact MSim.fail _ _


theorem zeroBytes_map (M : Map) : ∀ n, (zeroBytes n).map M.byte = zeroBytes n
  | 0 => rfl
  | n + 1 => by simp only [zeroBytes, List.map_cons, zeroBytes_map M n]; rfl

theorem zeroBytes_supp {A : Nat → Prop} {m : Nat} : ∀ n, Supp.bytes A m (zeroBytes n)
  | 0 => fun _ h => nomatch h
  | n + 1 => fun b hb => by
    rcases List.mem_cons.1 hb with rfl | hb
    · trivial
    · exact zeroBytes_supp n b hb

theorem StepPost_grow {M' : Map} {S' : SSrv} {C' : CSrv} (g : Grow M ν S C M' S' C')
    {m m' : Host.Ts.M (St F.S)} (hm : MSim (StepPost F FR M' ν K S' C') S' C' m m') :
    MSim (StepPost F FR M ν K S C) S' C' m m' :=
  MSim.mono hm fun _ _ _ _ _ ⟨g2, hr⟩ => ⟨g.trans g2, hr⟩

theorem hI_grow {M' : Map} {n : Nat} (hI : ∀ a, a < aFirst → M.a a = a) (g : Ext M M' n) :
    ∀ a, a < aFirst → M'.a a = a := by rw [g.a]; exact hI

/-- Lookup at a present unframed address. -/
theorem obj?_nofr (h : Rel F FR M ν K s S t C) {a : Nat} (hp : Present s a) (hfr : K.fr a = none) :
    t.obj? (M.a a) = (s.obj? a).map M.obj := by
  obtain ⟨h0, hg⟩ := hp.get
  have ht := h.get hg hfr
  cases h0 with
  | cell v => rw [obj?_cell hg, obj?_cell (v := v.map M.val) ht]; rfl
  | obj o => rw [obj?_iff.2 hg, obj?_iff.2 ht]; rfl

/-- `new T(x)` for element kind `k` and prototype `proto`: from nothing, a length, a buffer
(JS or native) or the elements of an array or typed array (`elemsOf`). -/
theorem typedCtor_sim {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR) (hF : FfiSim F FR okCall okBack)
    (k : EltK) (proto : Nat) {args : List Val} (hargs : Supp.vals (Present s) S.tab.length args)
    (hn : s.next + margin < Sim.bound) (hpl : proto < aFirst)
    (hp14 : Present s aArrayBufferProto) (hpp : Present s proto)
    (hpR : Present s aRangeErrorProto) (hpT : Present s aTypeErrorProto)
    (hok : ElemsOK F K s S (arg args 0))
    (hbig : ∀ vs S1, interpS (elemsOf F s (arg args 0)).run S = some (some vs, S1) →
      ∀ i, Val.big i ∈ vs → BigConvOK K k i)
    (hrange : ∀ vs S1, interpS (elemsOf F s (arg args 0)).run S = some (some vs, S1) →
      ∀ i, Val.big i ∈ vs → (K.lo : Int) ≤ i → i < K.hi → BigRange k (M.big i)) :
    MSim (StepPost F FR M ν K S C) S C (bufN.typedCtor F s args k proto)
    (bufN.typedCtor F t (M.vals args) k proto) := by
  have hI := h.intr
  have hn1 : s.next < Sim.bound := by have := margin2 hn; omega
  unfold bufN.typedCtor
  simp only [arg_vals]
  have hs0 := arg_supp hargs 0
  cases harg : arg args 0 with
  | undef => exact newTyped_sim h k proto [] 0 (margin2 hn) hpl hp14 hpp (fun _ h => nomatch h)
  | num x =>
    cases x with
    | lit x =>
      cases hx : F64.toIndex? x with
      | none =>
        simp only [Map.val, Map.nv, hx]
        exact rangeErr_sim h _ hn1 hI hpR
      | some n =>
        simp only [Map.val, Map.nv, hx]
        have := newTyped_sim h k proto (zeroBytes (n * k.size)) n (margin2 hn) hpl hp14 hpp
          (zeroBytes_supp _)
        rw [zeroBytes_map] at this
        exact this
    | ref _ => exact MSim.fail _ _
  | obj b =>
    rw [harg] at hs0 hok hbig hrange
    have hfb := (hok b rfl).1
    have ht := obj?_nofr h hs0 hfb
    simp only [Map.val]
    cases hs : s.obj? b with
    | none =>
      rw [hs] at ht
      simp only [hs, ht, Option.map_none, elemsOf]
      exact MSim.fail _ _
    | some o =>
      rw [hs, Option.map_some] at ht
      have hso := h.obj?_supp hs
      obtain ⟨kd, pr, ps, pv, e⟩ := o
      cases kd with
      | buf bs =>
        simp only [ht, Map.obj, Map.kind]
        refine offsetArg_msim M _ fun off _ => ?_
        cases harg2 : arg args 2 with
        | undef =>
          rw [len_map]
          exact allocObj_ret_sim h (.typed k b off ((len bs - off) / k.size)) proto hn1 (hI _ hpl) hpp hs0
        | _ =>
          exact offsetArg_msim M _ fun n _ =>
            allocObj_ret_sim h (.typed k b off n) proto hn1 (hI _ hpl) hpp hs0
      | extBuf r o0 l =>
        simp only [ht, Map.obj, Map.kind]
        refine offsetArg_msim M _ fun off _ => ?_
        cases harg2 : arg args 2 with
        | undef =>
          exact allocObj_ret_sim h (.typed k b off ((l - off) / k.size)) proto hn1 (hI _ hpl) hpp hs0
        | _ =>
          exact offsetArg_msim M _ fun n _ =>
            allocObj_ret_sim h (.typed k b off n) proto hn1 (hI _ hpl) hpp hs0
      | _ =>
        rw [ht]
        refine MSim.bind (MSim.withRun (elemsOf_sim h hF hs0 hok) (elemsOf_lawful _ _ _)
          (elemsOf_lawful _ _ _)) ?_
        rintro M0 S0 C0 r r' ⟨⟨hM0, hS0, hC0, hr, hsupp⟩, hrun⟩
        subst M0 S0 C0
        cases r with
        | none => rw [hr]; exact MSim.fail _ _
        | some vs =>
          rw [hr]
          simp only [Option.map_some]
          refine MSim.bind (cellsOf_sim (A := Present s) k vs h.srv (hsupp vs rfl)
            (fun i hi => toCellBig_map h (hbig vs S hrun i hi) (hrange vs S hrun i hi))) ?_
          rintro M' S' C' r r' ⟨rfl, g, hsc⟩
          have h' := h.grow hFR g
          have hI' := hI_grow hI g.ext
          cases r with
          | none => exact StepPost_grow g (typeErr_sim h' _ hn1 hI' hpT)
          | some cs =>
            simp only [Option.map_some]
            rw [len_map, ← cellBytes_map]
            exact StepPost_grow g (newTyped_sim h' k proto (cellBytes k cs) (len cs) (margin2 hn) hpl
              hp14 hpp (cellBytes_supp k (hsc cs rfl)))
  | _ =>
    simp only [Map.val]
    exact typeErr_sim h _ hn1 hI hpT


/-- `new Uint8Array(x)`, `new BigUint64Array(xs)`, … (`construct` of the native typed-array
constructor with data `[code, proto]`). -/
theorem _root_.Host.Ts.Sim.step_buf_typedCtor {okCall : F.S → Name → List Arg → Bool}
    {okBack : F.S → Arg → Bool} (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR)
    (hF : FfiSim F FR okCall okBack)
    {a : Nat} {args : List Val} {nt : Val} {o : Obj} {c p : F64} {ci proto : Nat}
    (hc : s.ctl = .construct (.obj a) args nt) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.buf .typedCtor) [.num (.lit c), .num (.lit p)]))
    (hci : F64.toIndex? c = some ci) (hpi : F64.toIndex? p = some proto)
    (hn : s.next + margin < Sim.bound) (hpl : proto < aFirst)
    (hp14 : Present s aArrayBufferProto) (hpp : Present s proto)
    (hpR : Present s aRangeErrorProto) (hpT : Present s aTypeErrorProto)
    (hok : ElemsOK F K s S (arg args 0))
    (hbig : ∀ vs S1, interpS (elemsOf F s (arg args 0)).run S = some (some vs, S1) →
      ∀ i, Val.big i ∈ vs → BigConvOK K (eltOfCode ci) i)
    (hrange : ∀ vs S1, interpS (elemsOf F s (arg args 0)).run S = some (some vs, S1) →
      ∀ i, Val.big i ∈ vs → (K.lo : Int) ≤ i → i < K.hi → BigRange (eltOfCode ci) (M.big i)) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  have hI := h.intr
  rw [step_construct_native hc ho hk, step_construct_native_t h hc ho hk]
  have hd : M.vals [Val.num (.lit c), .num (.lit p)] = [.num (.lit c), .num (.lit p)] := rfl
  rw [hd]
  simp only [constructNative, bufN, hci, hpi]
  exact typedCtor_sim h hFR hF (eltOfCode ci) proto (construct_supp h hc) hn hpl hp14 hpp hpR hpT
    hok hbig hrange


/-! ## DataView reads and writes -/

theorem viewOf_rel (h : Rel F FR M ν K s S t C) {v : Val} (hv : Supp.val (Present s) S.tab.length v) :
    viewOf F t (M.val v) = (viewOf F s v).map fun x => (M.a x.1, x.2.1, x.2.2) := by
  cases v with
  | obj a =>
    rcases obj?_cases h hv with ⟨hs, ht⟩ | ⟨o, hs, ht⟩ | ⟨o, o', es, es', hs, ht, hk, hk'⟩
    · show viewOf F t (.obj (M.a a)) = _
      simp only [viewOf, hs, ht, Option.map_none]
    · show viewOf F t (.obj (M.a a)) = _
      obtain ⟨kd, pr, ps, pv, e⟩ := o
      cases kd <;> simp only [viewOf, hs, ht, Map.obj, Map.kind, Option.map_none, Option.map_some]
    · show viewOf F t (.obj (M.a a)) = _
      obtain ⟨kd, pr, ps, pv, e⟩ := o
      obtain ⟨kd', pr', ps', pv', e'⟩ := o'
      simp only at hk hk'
      subst hk hk'
      simp only [viewOf, hs, ht, Option.map_none]
  | _ => rfl

theorem viewOf_some {v : Val} {b off n : Nat} (hv : viewOf F s v = some (b, off, n)) :
    ∃ a o, v = .obj a ∧ s.obj? a = some o ∧ o.kind = .view b off n := by
  cases v with
  | obj a =>
    cases ho : s.obj? a with
    | none => simp only [viewOf, ho] at hv; cases hv
    | some o =>
      simp only [viewOf, ho] at hv
      obtain ⟨kd, pr, ps, pv, e⟩ := o
      cases kd <;> try cases hv
      exact ⟨a, _, rfl, ho, rfl⟩
  | _ => cases hv

theorem fr_none (h : Rel F FR M ν K s S t C) {a : Nat} {o : Obj} (ho : s.obj? a = some o)
    (hk : ∀ es, o.kind ≠ .array es) : K.fr a = none := by
  cases hfr : K.fr a with
  | none => rfl
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    obtain ⟨_, _, ⟨xs, hk', _⟩⟩ := h.obj?_framed ho hfr
    exact absurd hk' (hk _)

theorem cellVal_map (M : Map) (c : Cell) : M.val (cellVal c) = cellVal (M.cell c) := by
  cases c <;> rfl

theorem cellVal_supp {A : Nat → Prop} {n : Nat} {c : Cell} (hc : Supp.cell (fun _ => True) n c) :
    Supp.val A n (cellVal c) := by
  cases c <;> exact hc

/-- `DataView.prototype.getX(pos, little)`. -/
theorem get_sim {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR) (hF : FfiSim F FR okCall okBack) (k : EltK)
    {this : Val} {args : List Val} (hthis : Supp.val (Present s) S.tab.length this)
    (hn : s.next < Sim.bound) (hpT : Present s aTypeErrorProto)
    (hle : ∀ i, arg args 1 = .big i → BigFixed K.lo K.hi i)
    (hrd : ∀ b off n bs pos (le : Bool), viewOf F s this = some (b, off, n) → bufBytes F s b = some bs →
      offsetP (arg args 0) = some pos →
      ReadOK K.lo K.hi S.tab.length k
    (bif le then (bs.drop (off + pos)).take k.size else ((bs.drop (off + pos)).take k.size).reverse)) :
    MSim (StepPost F FR M ν K S C) S C (bufN.get F s this args k) (bufN.get F t (M.val this) (M.vals args) k) := by
  have hI := h.intr
  unfold bufN.get
  simp only [arg_vals]
  rw [viewOf_rel h hthis]
  cases hvw : viewOf F s this with
  | none => exact typeErr_sim h _ hn hI hpT
  | some x =>
    obtain ⟨b, off, n⟩ := x
    simp only [Option.map_some]
    refine offsetArg_msim M _ fun pos hpos => ?_
    refine MSim.bind (truthy_sim h.srv (arg args 1) (fun i hi => h.bigFixed i (hle i hi))) ?_
    rintro M' S' C' le le' ⟨hl, g⟩
    rw [hl]
    have h' := h.grow hFR g
    cases hbs : bufBytes F s b with
    | none => exact MSim.fail _ _
    | some bs =>
      have hbt := bufBytes_rel h' hF hbs
      rw [g.ext.a] at hbt
      simp only [hbt]
      have hw : (bif le then ((bs.map M'.byte).drop (off + pos)).take k.size
          else (((bs.map M'.byte).drop (off + pos)).take k.size).reverse) =
          (bif le then (bs.drop (off + pos)).take k.size
            else ((bs.drop (off + pos)).take k.size).reverse).map M'.byte := by
        cases le <;> simp [List.map_reverse]
      rw [hw]
      have hok := hrd b off n bs pos le hvw hbs hpos
      cases hrc : readCell k (bif le then (bs.drop (off + pos)).take k.size
          else ((bs.drop (off + pos)).take k.size).reverse) with
      | none => exact MSim.fail _ _
      | some c =>
        rw [readCell_map h'.bigFixed hok hrc]
        have := sim_ret h' (cellVal c) (cellVal_supp (cell_mono (hok c hrc).1 g.len))
        rw [cellVal_map] at this
        exact StepPost_grow g this


/-- Replacing the bytes of a JS buffer object: the relation holds for the image bytes. -/
theorem Rel.setBuf (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) {b : Nat} {bs : List Byte}
    {p : Val} {ps : Props} {pr : List ((Nat × Name) × PropV)} {ex : Bool}
    (ho : s.obj? b = some ⟨.buf bs, p, ps, pr, ex⟩) (nbs : List Byte)
    (hnb : Supp.bytes (Present s) S.tab.length nbs) :
    t.obj? (M.a b) = some ⟨.buf (bs.map M.byte), M.val p, M.props ps,
        pr.map (fun ((b, n), q) => ((M.a b, n), M.prop q)), ex⟩ ∧
      Rel F FR M ν K (s.setObj b ⟨.buf nbs, p, ps, pr, ex⟩) S
      (t.setObj (M.a b) ⟨.buf (nbs.map M.byte), M.val p, M.props ps,
        pr.map (fun ((b, n), q) => ((M.a b, n), M.prop q)), ex⟩) C := by
  have hso := h.obj?_supp ho
  have hfr := fr_none h ho (fun _ h => nomatch h)
  exact ⟨obj?_plain h ho (fun _ h => nomatch h),
    h.setObj ⟨.buf nbs, p, ps, pr, ex⟩ hn (Present.of_get (obj?_iff.1 ho)) hfr
      ⟨hnb, hso.2.1, hso.2.2.1, hso.2.2.2⟩⟩

theorem window_map (M : Map) (bs : List Byte) (i j : Nat) (le : Bool) :
    (bif le then ((bs.map M.byte).drop i).take j else (((bs.map M.byte).drop i).take j).reverse) =
      (bif le then (bs.drop i).take j else ((bs.drop i).take j).reverse).map M.byte := by
  cases le <;> simp [List.map_reverse]

/-- `DataView.prototype.setX(pos, value, little)`. -/
theorem set_sim (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR) (k : EltK)
    {this : Val} {args : List Val} (hthis : Supp.val (Present s) S.tab.length this)
    (hargs : Supp.vals (Present s) S.tab.length args)
    (hn : s.next < Sim.bound) (hpT : Present s aTypeErrorProto)
    (hle : ∀ i, arg args 2 = .big i → BigFixed K.lo K.hi i)
    (hbig : ∀ i, arg args 1 = .big i → BigConvOK K k i)
    (hrange : ∀ i, arg args 1 = .big i → (K.lo : Int) ≤ i → i < K.hi → BigRange k (M.big i)) :
    MSim (StepPost F FR M ν K S C) S C (bufN.set F s this args k) (bufN.set F t (M.val this) (M.vals args) k) := by
  have hI := h.intr
  unfold bufN.set
  simp only [arg_vals]
  rw [viewOf_rel h hthis]
  cases hvw : viewOf F s this with
  | none => exact typeErr_sim h _ hn hI hpT
  | some x =>
    obtain ⟨b, off, n⟩ := x
    simp only [Option.map_some]
    refine offsetArg_msim M _ fun pos hpos => ?_
    refine MSim.bind (truthy_sim h.srv (arg args 2) (fun i hi => h.bigFixed i (hle i hi))) ?_
    rintro M1 S1 C1 le le' ⟨hl, g1⟩
    rw [hl]
    have h1 := h.grow hFR g1
    have hv1 := arg_supp hargs 1
    rw [Map.val_agree (g1.ext.agree (A := Present s)) hv1]
    refine MSim.bind (toCell_sim h1.srv k (arg args 1) (Supp.val_mono (fun _ h => h) g1.len hv1)
      (fun i hi => toCellBig_map h1 (hbig i hi) (by rw [g1.ext.big]; exact hrange i hi))) ?_
    rintro M2 S2 C2 r r' ⟨rfl, g2, hsc⟩
    have h2 := h1.grow hFR g2
    have g := g1.trans g2
    have hI2 := hI_grow hI g.ext
    cases r with
    | none => exact StepPost_grow g (typeErr_sim h2 _ hn hI2 hpT)
    | some c =>
      cases hbo : s.obj? b with
      | none => exact MSim.fail _ _
      | some bo =>
        obtain ⟨kd, p, ps, pr, ex⟩ := bo
        cases kd with
        | buf bs =>
          have hc2 : Supp.cell (Present s) S2.tab.length c := hsc c rfl
          have hso := h.obj?_supp hbo
          let parts := bif le then cellParts k c k.size 0 else (cellParts k c k.size 0).reverse
          have hparts : Supp.bytes (Present s) S2.tab.length parts := by
            have := cellParts_supp k hc2 k.size 0
            cases le
            · exact fun x hx => this x (List.mem_reverse.1 hx)
            · exact this
          have hbs : Supp.bytes (Present s) S2.tab.length bs := bytes_mono hso.1 g.len
          obtain ⟨ht, hr⟩ := Rel.setBuf h2 hn hbo
            (bs.take (off + pos) ++ parts ++ bs.drop (off + pos + k.size))
            (bytes_append (bytes_append (bytes_take hbs _) hparts) (bytes_drop hbs _))
          rw [g.ext.a] at ht hr
          simp only [ht, Option.map_some]
          have := sim_ret hr .undef trivial
          have hpm : (bif le then cellParts k (M2.cell c) k.size 0
              else (cellParts k (M2.cell c) k.size 0).reverse) = parts.map M2.byte := by
            cases le <;> simp [parts, List.map_reverse, Map.cellParts]
          simp only [List.map_append, List.map_take, List.map_drop] at this
          rw [hpm]
          exact StepPost_grow g this
        | _ => exact MSim.fail _ _


section dv
variable {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
  {a : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

/-- DataView reads: the side conditions of `get_sim` for the element kind of the method. -/
abbrev GetSide (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (k : EltK) (this : Val) (args : List Val) : Prop :=
  (∀ i, arg args 1 = .big i → BigFixed K.lo K.hi i) ∧
  ∀ b off n bs pos (le : Bool), viewOf F s this = some (b, off, n) → bufBytes F s b = some bs →
    offsetP (arg args 0) = some pos →
    ReadOK K.lo K.hi S.tab.length k
      (bif le then (bs.drop (off + pos)).take k.size else ((bs.drop (off + pos)).take k.size).reverse)

theorem _root_.Host.Ts.Sim.step_buf_getU32 (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR) (hF : FfiSim F FR okCall okBack)
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.buf .getU32) data)) (hn : s.next < Sim.bound)
    (hpT : Present s aTypeErrorProto)
    (hside : GetSide F K s S .u32 this args) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  have hI := h.intr
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  exact get_sim h hFR hF .u32 (call_supp h hc).1 hn hpT hside.1 hside.2

theorem _root_.Host.Ts.Sim.step_buf_getI32 (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR) (hF : FfiSim F FR okCall okBack)
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.buf .getI32) data)) (hn : s.next < Sim.bound)
    (hpT : Present s aTypeErrorProto)
    (hside : GetSide F K s S .i32 this args) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  have hI := h.intr
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  exact get_sim h hFR hF .i32 (call_supp h hc).1 hn hpT hside.1 hside.2

theorem _root_.Host.Ts.Sim.step_buf_getF32 (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR) (hF : FfiSim F FR okCall okBack)
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.buf .getF32) data)) (hn : s.next < Sim.bound)
    (hpT : Present s aTypeErrorProto)
    (hside : GetSide F K s S .f32 this args) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  have hI := h.intr
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  exact get_sim h hFR hF .f32 (call_supp h hc).1 hn hpT hside.1 hside.2

theorem _root_.Host.Ts.Sim.step_buf_getBigU64 (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR) (hF : FfiSim F FR okCall okBack)
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.buf .getBigU64) data)) (hn : s.next < Sim.bound)
    (hpT : Present s aTypeErrorProto)
    (hside : GetSide F K s S .u64 this args) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  have hI := h.intr
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  exact get_sim h hFR hF .u64 (call_supp h hc).1 hn hpT hside.1 hside.2

/-- DataView writes: the side conditions of `set_sim`. -/
abbrev SetSide (K : Ctx) (k : EltK) (args : List Val) : Prop :=
  (∀ i, arg args 2 = .big i → BigFixed K.lo K.hi i) ∧ ∀ i, arg args 1 = .big i → BigConvOK K k i

theorem _root_.Host.Ts.Sim.step_buf_setF32 (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.buf .setF32) data)) (hn : s.next < Sim.bound)
    (hpT : Present s aTypeErrorProto) (hside : SetSide K .f32 args)
    (hrange : ∀ i, arg args 1 = .big i → (K.lo : Int) ≤ i → i < K.hi → BigRange .f32 (M.big i)) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  have hI := h.intr
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  exact set_sim h hFR .f32 (call_supp h hc).1 (call_supp h hc).2 hn hpT hside.1 hside.2 hrange

theorem _root_.Host.Ts.Sim.step_buf_setU32 (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.buf .setU32) data)) (hn : s.next < Sim.bound)
    (hpT : Present s aTypeErrorProto) (hside : SetSide K .u32 args)
    (hrange : ∀ i, arg args 1 = .big i → (K.lo : Int) ≤ i → i < K.hi → BigRange .u32 (M.big i)) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  have hI := h.intr
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  exact set_sim h hFR .u32 (call_supp h hc).1 (call_supp h hc).2 hn hpT hside.1 hside.2 hrange

theorem _root_.Host.Ts.Sim.step_buf_setI32 (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.buf .setI32) data)) (hn : s.next < Sim.bound)
    (hpT : Present s aTypeErrorProto) (hside : SetSide K .i32 args)
    (hrange : ∀ i, arg args 1 = .big i → (K.lo : Int) ≤ i → i < K.hi → BigRange .i32 (M.big i)) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  have hI := h.intr
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  exact set_sim h hFR .i32 (call_supp h hc).1 (call_supp h hc).2 hn hpT hside.1 hside.2 hrange

theorem _root_.Host.Ts.Sim.step_buf_setBigU64 (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.buf .setBigU64) data)) (hn : s.next < Sim.bound)
    (hpT : Present s aTypeErrorProto) (hside : SetSide K .u64 args)
    (hrange : ∀ i, arg args 1 = .big i → (K.lo : Int) ≤ i → i < K.hi → BigRange .u64 (M.big i)) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  have hI := h.intr
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  exact set_sim h hFR .u64 (call_supp h hc).1 (call_supp h hc).2 hn hpT hside.1 hside.2 hrange

end dv

end

end BufSim
end Host.Ts.Sim
