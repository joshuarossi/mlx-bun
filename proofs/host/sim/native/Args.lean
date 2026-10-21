import host.sim.native.Call
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Decoded native arguments under the map

Buffer cells read whole elements (`wholeCell`: the image is the imaged
element) or concrete bytes (`byteFix`: no renamed bigint bytes; the element
is concrete). Out-param slots, dimension lists, handle lists and C strings
then decode to the images of the source's. -/

namespace Native

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

end Native

/-- A byte whose concrete value the map keeps. -/
def byteFix (P : LoadP) : Byte → Bool
  | .part _ (.big j) _ => decide (j < P.lo)
  | _ => true

/-- A cell read the map commutes with. -/
def cellOk (P : LoadP) (k : EltK) (bs : List Byte) : Bool :=
  (wholeCell k (bs.take k.size) k.size).isSome || (bs.take k.size).all (byteFix P)

section
variable {P : LoadP} {M : Map} {n : Nat} {x y : NSt} (hr : MR P M n x y)
include hr

theorem MR.concByte_map {b : Byte} {v : Nat} (hb : concByte b = some v) (hf : byteFix P b = true) :
    concByte (M.byte b) = some v := by
  cases b with
  | lit _ => exact hb
  | part k c i =>
    cases c with
    | num w =>
      cases w with
      | lit _ => exact hb
      | ref _ => cases hb
    | big j =>
      simp only [byteFix, decide_eq_true_eq] at hf
      show concByte (.part k (.big (M.big j)) i) = some v
      rw [hr.bigFix j hf]; exact hb

theorem MR.concBytes_map : ∀ {bs : List Byte} {ns : List Nat}, concBytes bs = some ns →
    bs.all (byteFix P) = true → concBytes (bs.map M.byte) = some ns
  | [], _, h, _ => h
  | b :: bs, ns, h, hf => by
    simp only [List.all_cons, Bool.and_eq_true] at hf
    simp only [Host.Ts.concBytes] at h
    cases hb : concByte b with
    | none => rw [hb] at h; cases h
    | some v =>
      rw [hb] at h
      cases hbs : Host.Ts.concBytes bs with
      | none => rw [hbs] at h; cases h
      | some ys =>
        rw [hbs] at h
        rw [List.map_cons, Host.Ts.concBytes, hr.concByte_map hb hf.1, concBytes_map hbs hf.2]
        exact h

/-- A cell read commutes with the map; a concrete read must give an element the map fixes. -/
theorem MR.readCell_map {k : EltK} {bs : List Byte} {c : Cell} (hc : readCell k bs = some c)
    (hok : cellOk P k bs = true) (hfix : (wholeCell k (bs.take k.size) k.size).isSome = false → M.cell c = c) :
    readCell k (bs.map M.byte) = some (M.cell c) := by
  unfold readCell at hc ⊢
  dsimp only at hc ⊢
  rw [← List.map_take, Native.wholeCell_map]
  cases hw : wholeCell k (bs.take k.size) k.size with
  | some c0 =>
    rw [hw] at hc
    cases hc
    rfl
  | none =>
    rw [hw] at hc hfix
    have hf : (bs.take k.size).all (byteFix P) = true := by
      simp only [cellOk, hw, Option.isSome_none, Bool.false_or] at hok; exact hok
    cases hcb : Host.Ts.concBytes (bs.take k.size) with
    | none => rw [hcb] at hc; cases hc
    | some ns =>
      rw [hcb] at hc
      simp only [Option.map_none, hr.concBytes_map hcb hf, Option.bind_some] at hc ⊢
      rw [hc, hfix rfl]
end

namespace Native

/-- A concrete read of a number element gives a literal. -/
theorem readCell_conc_num {k : EltK} {bs : List Byte} {v : NumV}
    (hw : (wholeCell k (bs.take k.size) k.size).isSome = false) (hc : readCell k bs = some (.num v)) :
    ∃ f, v = .lit f := by
  unfold readCell at hc
  dsimp only at hc
  cases h' : wholeCell k (bs.take k.size) k.size with
  | some _ => rw [h'] at hw; cases hw
  | none =>
    rw [h'] at hc
    cases hcb : Host.Ts.concBytes (bs.take k.size) with
    | none => rw [hcb] at hc; cases hc
    | some ns =>
      rw [hcb] at hc
      simp only [Option.bind_some] at hc
      cases hl : Nat.beq (len ns) k.size
      · rw [hl] at hc; cases hc
      · rw [hl] at hc
        simp only [Bool.cond_true, Option.some.injEq] at hc
        cases k <;> simp only [decodeCell, Cell.num.injEq, reduceCtorEq] at hc <;> exact ⟨_, hc.symm⟩

end Native

/-! ## Out-param slots -/

/-- A slot argument: its handle is null or present, and reads back as its image. -/
def slotOk (P : LoadP) (x : NSt) : Arg → Bool
  | .jsPtr _ _ bs => match readCell .u64 bs with
    | some (.big i) => decide (0 ≤ i) && (decide (i = 0) || isPH x i.toNat) &&
        ((wholeCell .u64 (bs.take 8) 8).isSome || ((bs.take 8).all (byteFix P) && decide (i < P.lo)))
    | _ => false
  | _ => false

theorem Map.write_u64 (M : Map) {b off h h' : Nat} (e : M.big (Int.ofNat h) = Int.ofNat h') :
    M.write (Host.Mlx.Ffi.u64Write b off h) = Host.Mlx.Ffi.u64Write (M.a b) off h' := by
  simp only [Host.Mlx.Ffi.u64Write, Map.write, Map.cellParts, Map.cell]
  rw [show ((h : Nat) : Int) = Int.ofNat h from rfl, e]; rfl

section
variable {P : LoadP} {M : Map} {n : Nat} {x y : NSt} (hr : MR P M n x y)
include hr

theorem MR.slot_map {o : Arg} (ho : slotOk P x o = true) :
    ∃ b off sl, Host.Mlx.Ffi.slotOf o = some (b, off, sl) ∧
      Host.Mlx.Ffi.slotOf (M.arg o) = some (M.a b, off, M.handle sl) ∧ (sl = 0 ∨ PH x sl) := by
  cases o with
  | jsPtr b off bs =>
    simp only [slotOk] at ho
    cases hc : readCell .u64 bs with
    | none => rw [hc] at ho; cases ho
    | some c =>
      rw [hc] at ho
      cases c with
      | num _ => cases ho
      | big i =>
        simp only [Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq, isPH_iff] at ho
        obtain ⟨⟨hi0, hpr⟩, hwc⟩ := ho
        have hm : readCell .u64 (bs.map M.byte) = some (M.cell (.big i)) := by
          refine hr.readCell_map hc ?_ ?_
          · show ((wholeCell .u64 (bs.take 8) 8).isSome || (bs.take 8).all (byteFix P)) = true
            rcases hwc with h | h
            · rw [h]; rfl
            · rw [h.1, Bool.or_true]
          · intro hw
            rcases hwc with h | h
            · rw [show EltK.size .u64 = 8 from rfl] at hw; rw [h] at hw; cases hw
            · show Cell.big (M.big i) = Cell.big i; rw [hr.bigFix i h.2]
        refine ⟨b, off, i.toNat, ?_, ?_, ?_⟩
        · simp only [Host.Mlx.Ffi.slotOf, hc]
        · simp only [Host.Mlx.Ffi.slotOf, Map.arg, hm, Map.cell]
          show some (M.a b, off, (M.big i).toNat) = some (M.a b, off, (M.big (Int.ofNat i.toNat)).toNat)
          rw [show Int.ofNat i.toNat = i from Int.toNat_of_nonneg hi0]
        · rcases hpr with h | h
          · left; rw [h]; rfl
          · exact .inr h
  | _ => cases ho
end

/-! ## Integer arrays: dimensions -/

/-- `f` holds at each of `j` consecutive cells of `sz` bytes. -/
def cellsAll (f : List Byte → Bool) (sz : Nat) : Nat → List Byte → Bool
  | 0, _ => true
  | j + 1, bs => f bs && cellsAll f sz j (bs.drop sz)

/-- Cells `0 … k-1` of `i32` elements, each read commuting with the map. -/
def cellsOk (P : LoadP) (k : EltK) (j : Nat) (bs : List Byte) : Bool := cellsAll (cellOk P k) k.size j bs

section
variable {P : LoadP} {M : Map} {n : Nat} {x y : NSt} (hr : MR P M n x y)
include hr

theorem MR.cellsI32_map : ∀ (j : Nat) {bs : List Byte} {xs : List NumV}, Host.Mlx.Ffi.cellsI32 j bs = some xs →
    cellsOk P .i32 j bs = true → Host.Mlx.Ffi.cellsI32 j (bs.map M.byte) = some (xs.map M.nv)
  | 0, _, xs, h, _ => by simp only [Host.Mlx.Ffi.cellsI32, Option.some.injEq] at h; subst h; rfl
  | j + 1, bs, xs, h, hok => by
    simp only [cellsOk, cellsAll, Bool.and_eq_true] at hok
    simp only [Host.Mlx.Ffi.cellsI32] at h ⊢
    cases hc : readCell .i32 bs with
    | none => rw [hc] at h; cases h
    | some c =>
      rw [hc] at h
      cases c with
      | big _ => cases h
      | num v =>
        simp only at h
        cases hrest : Host.Mlx.Ffi.cellsI32 j (bs.drop 4) with
        | none => rw [hrest] at h; cases h
        | some ys =>
          rw [hrest] at h
          simp only [Option.map_some, Option.some.injEq] at h
          subst h
          have hm := hr.readCell_map hc hok.1 (fun hw => by
            obtain ⟨f, rfl⟩ := Native.readCell_conc_num hw hc
            rfl)
          rw [hm]
          simp only [Map.cell]
          rw [← List.map_drop, cellsI32_map j hrest hok.2]
          rfl

/-- Dimension arguments: literal counts, cells read commuting with the map. -/
def dimsOk (P : LoadP) (p c : Arg) : Bool :=
  natOk P c && match p, Host.Mlx.Ffi.argNat c with
    | _, some 0 => true
    | .jsPtr _ _ bs, some k => cellsOk P .i32 k bs
    | _, _ => false

theorem MR.dimsArg_map {p c : Arg} {ds : List Dim} (hok : dimsOk P p c = true)
    (hd : Host.Mlx.Ffi.dimsArg p c = some ds) : Host.Mlx.Ffi.dimsArg (M.arg p) (M.arg c) = some (M.dims ds) := by
  simp only [dimsOk, Bool.and_eq_true] at hok
  obtain ⟨hn, hc⟩ := hok
  unfold Host.Mlx.Ffi.dimsArg at hd ⊢
  rw [hr.natOk_argNat hn]
  cases ha : Host.Mlx.Ffi.argNat c with
  | none => rw [ha] at hd; cases p <;> cases hd
  | some k =>
    rw [ha] at hd hc
    cases k with
    | zero => simp only at hd ⊢; cases hd; rfl
    | succ k =>
      cases p with
      | jsPtr b off bs =>
        simp only at hd hc ⊢
        cases hx : Host.Mlx.Ffi.cellsI32 (k + 1) bs with
        | none => rw [hx] at hd; cases hd
        | some xs =>
          rw [hx] at hd
          simp only [Option.map_some, Option.some.injEq] at hd
          subst hd
          show (Host.Mlx.Ffi.cellsI32 (k + 1) (bs.map M.byte)).map _ = _
          rw [hr.cellsI32_map (k + 1) hx hc, Option.map_some, List.map_map, Map.dims, List.map_map]
          congr 1
          exact List.map_congr_left fun v _ => (Map.dim_dimOf M v).symm
      | _ => cases hd
end

/-! ## C strings -/

theorem cstrBytes_map (M : Map) : ∀ (f : Nat) (bs : List Byte),
    Host.Mlx.Ffi.cstrBytes f (bs.map M.byte) = Host.Mlx.Ffi.cstrBytes f bs
  | 0, _ => rfl
  | _ + 1, [] => rfl
  | f + 1, .lit b :: bs => by
    simp only [List.map_cons, Map.byte, Host.Mlx.Ffi.cstrBytes, cstrBytes_map M f bs]
  | _ + 1, .part _ _ _ :: _ => rfl

theorem cstrArg_map (M : Map) (a : Arg) : Host.Mlx.Ffi.cstrArg (M.arg a) = Host.Mlx.Ffi.cstrArg a := by
  cases a with
  | jsPtr b off bs =>
    show Host.Mlx.Ffi.cstrBytes ((bs.map M.byte).length + 1) (bs.map M.byte) = _
    rw [List.length_map, cstrBytes_map]; rfl
  | _ => rfl

/-! ## Literal dimensions -/

def dimLit : Dim → Bool
  | .lit _ => true
  | .sym _ => false

theorem dims_lit (M : Map) {ds : List Dim} (h : ds.all dimLit = true) : M.dims ds = ds := by
  unfold Map.dims
  conv => rhs; rw [← List.map_id ds]
  exact List.map_congr_left fun d hd => by
    have := List.all_eq_true.mp h d hd
    cases d with
    | lit _ => rfl
    | sym _ => cases this

theorem dimCanon_lit (M : Map) {d : Dim} (h : dimLit d = true) : DimCanon M d := by
  cases d with
  | lit _ => rfl
  | sym _ => cases h

theorem natsOfDims_map (M : Map) : ∀ {ds : List Dim} {ns : List Nat}, Host.Mlx.Ffi.natsOfDims ds = some ns →
    Host.Mlx.Ffi.natsOfDims (M.dims ds) = some ns
  | [], _, h => h
  | .lit i :: ds, ns, h => by
    show Host.Mlx.Ffi.natsOfDims (.lit i :: M.dims ds) = some ns
    simp only [Host.Mlx.Ffi.natsOfDims] at h ⊢
    cases hi : decide (0 ≤ i)
    · rw [hi] at h; cases h
    · rw [hi] at h
      simp only [Bool.cond_true] at h ⊢
      cases hr : Host.Mlx.Ffi.natsOfDims ds with
      | none => rw [hr] at h; cases h
      | some ms =>
        rw [hr] at h
        show (Host.Mlx.Ffi.natsOfDims (M.dims ds)).map _ = _
        rw [natsOfDims_map M hr]; exact h
  | .sym _ :: _, _, h => by cases h


/-! ## Handle arrays and graph inputs -/

/-- `u64` cells holding present handles, each read commuting with the map. -/
def hcellOk (P : LoadP) (x : NSt) (bs : List Byte) : Bool :=
  match readCell .u64 bs with
  | some (.big i) => decide (0 ≤ i) && isPH x i.toNat &&
      ((wholeCell .u64 (bs.take 8) 8).isSome || ((bs.take 8).all (byteFix P) && decide (i < P.lo)))
  | _ => false

def hcellsOk (P : LoadP) (x : NSt) (j : Nat) (bs : List Byte) : Bool := cellsAll (hcellOk P x) 8 j bs

def handlesOk (P : LoadP) (x : NSt) (p c : Arg) : Bool :=
  natOk P c && match p, Host.Mlx.Ffi.argNat c with
    | _, some 0 => true
    | .jsPtr _ _ bs, some k => hcellsOk P x k bs
    | _, _ => false

section
variable {P : LoadP} {M : Map} {n : Nat} {x y : NSt} (hr : MR P M n x y)
include hr

theorem MR.cellsU64_map : ∀ (j : Nat) {bs : List Byte} {hs : List Nat}, Host.Mlx.Ffi.cellsU64 j bs = some hs →
    hcellsOk P x j bs = true →
      Host.Mlx.Ffi.cellsU64 j (bs.map M.byte) = some (hs.map M.handle) ∧ ∀ h ∈ hs, PH x h
  | 0, _, hs, h, _ => by
    simp only [Host.Mlx.Ffi.cellsU64, Option.some.injEq] at h; subst h
    exact ⟨rfl, fun _ hm => by cases hm⟩
  | j + 1, bs, hs, h, hok => by
    simp only [hcellsOk, cellsAll, Bool.and_eq_true] at hok
    obtain ⟨hc1, hok⟩ := hok
    unfold hcellOk at hc1
    simp only [Host.Mlx.Ffi.cellsU64] at h ⊢
    cases hc : readCell .u64 bs with
    | none => rw [hc] at h; cases h
    | some c =>
      rw [hc] at h hc1
      cases c with
      | num _ => cases h
      | big i =>
        simp only [Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq, isPH_iff] at hc1
        obtain ⟨⟨hi0, hp⟩, hwc⟩ := hc1
        simp only at h
        cases hrest : Host.Mlx.Ffi.cellsU64 j (bs.drop 8) with
        | none => rw [hrest] at h; cases h
        | some ys =>
          rw [hrest] at h
          simp only [Option.map_some, Option.some.injEq] at h
          subst h
          have hm : readCell .u64 (bs.map M.byte) = some (M.cell (.big i)) := by
            refine hr.readCell_map hc ?_ ?_
            · show ((wholeCell .u64 (bs.take 8) 8).isSome || (bs.take 8).all (byteFix P)) = true
              rcases hwc with h | h
              · rw [h]; rfl
              · rw [h.1, Bool.or_true]
            · intro hw
              rcases hwc with h | h
              · rw [show EltK.size .u64 = 8 from rfl, h] at hw; cases hw
              · show Cell.big (M.big i) = Cell.big i; rw [hr.bigFix i h.2]
          obtain ⟨ih1, ih2⟩ := cellsU64_map j hrest hok
          rw [hm]
          simp only [Map.cell]
          rw [← List.map_drop, ih1]
          refine ⟨?_, ?_⟩
          · show some ((M.big i).toNat :: ys.map M.handle) = some ((M.big (Int.ofNat i.toNat)).toNat :: ys.map M.handle)
            rw [show Int.ofNat i.toNat = i from Int.toNat_of_nonneg hi0]
          · intro h hm'
            rcases List.mem_cons.mp hm' with rfl | hm'
            · exact hp
            · exact ih2 h hm'

theorem MR.handlesArg_map {p c : Arg} {hs : List Nat} (hok : handlesOk P x p c = true)
    (hh : Host.Mlx.Ffi.handlesArg p c = some hs) :
    Host.Mlx.Ffi.handlesArg (M.arg p) (M.arg c) = some (hs.map M.handle) ∧ ∀ h ∈ hs, PH x h := by
  simp only [handlesOk, Bool.and_eq_true] at hok
  obtain ⟨hn, hc⟩ := hok
  unfold Host.Mlx.Ffi.handlesArg at hh ⊢
  rw [hr.natOk_argNat hn]
  cases ha : Host.Mlx.Ffi.argNat c with
  | none => rw [ha] at hh; cases p <;> cases hh
  | some k =>
    rw [ha] at hh hc
    cases k with
    | zero => simp only at hh ⊢; cases hh; exact ⟨rfl, fun _ hm => by cases hm⟩
    | succ k =>
      cases p with
      | jsPtr b off bs =>
        simp only at hh hc ⊢
        exact hr.cellsU64_map (k + 1) hh hc
      | _ => cases hh

theorem MR.nodesOf_map : ∀ {hs : List Nat}, (∀ h ∈ hs, PH x h) →
    Host.Mlx.Ffi.nodesOf y (hs.map M.handle) = (Host.Mlx.Ffi.nodesOf x hs).map (·.map M.node)
  | [], _ => rfl
  | h :: hs, hp => by
    simp only [List.map_cons, Host.Mlx.Ffi.nodesOf]
    rw [hr.nodeId? (hp h (List.mem_cons_self ..)), nodesOf_map (fun k hk => hp k (List.mem_cons_of_mem _ hk))]
    cases x.nodeId? h <;> cases Host.Mlx.Ffi.nodesOf x hs <;> rfl

theorem MR.arrIns_map : ∀ {as : List Arg}, (∀ a ∈ as, hdOk x a = true) →
    Host.Mlx.Ffi.arrIns y (as.map M.arg) = (Host.Mlx.Ffi.arrIns x as).map (·.map M.node)
  | [], _ => rfl
  | a :: as, ha => by
    obtain ⟨k, rfl, hp, hm⟩ := hr.hdOk_spec (ha a (List.mem_cons_self ..))
    have ih := arrIns_map (fun b hb => ha b (List.mem_cons_of_mem _ hb))
    unfold Host.Mlx.Ffi.arrIns at ih ⊢
    rw [List.map_cons, hm, List.mapM_cons, List.mapM_cons, argNat_nat, argNat_nat, ih]
    simp only [Option.bind_some, hr.nodeId? hp]
    cases x.nodeId? k <;> cases List.mapM (fun a => (Host.Mlx.Ffi.argNat a).bind x.nodeId?) as <;> rfl
end

end Host.Ts.Sim
