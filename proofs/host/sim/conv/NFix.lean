import host.sim.conv.NClean
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Maps fixing the old names fix the old native data

`FixOld c σ`: `σ` fixes every name below the counters `c` (JavaScript addresses, table references,
old bigints and regions, nodes). It then fixes every native datum whose names are old (`fix_nobj`,
`fix_nnode`, `fix_prim`, …), so under the bookkeeping `NClean c x` it fixes every entry of `x`. A
compaction map is such a map for the call's counters (`fixOld_compact`), from small checks of its
tables: its renamed handles, nodes and numbers lie past the call's counters. -/

/-- `σ` fixes the names below the counters `c`. -/
structure FixOld (c : Cnt) (σ : Map) : Prop where
  a : ∀ x, x < c.ja → σ.a x = x
  num : ∀ i, i < c.n → σ.num i = .ref i
  big : ∀ i, oldBigB c i = true → σ.big i = i
  region : ∀ r, oldRegB c r = true → σ.region r = r
  node : ∀ j, j < c.nn → σ.node j = j

theorem map_fix {α : Type} {f : α → α} {p : α → Bool} (hfp : ∀ a, p a = true → f a = a) :
    ∀ {l : List α}, l.all p = true → l.map f = l
  | [], _ => rfl
  | a :: l, h => by
    simp only [List.all_cons, Bool.and_eq_true] at h
    rw [List.map_cons, hfp a h.1, map_fix hfp h.2]

section
variable {c : Cnt} {σ : Map} (hf : FixOld c σ)
include hf

theorem fix_nv {x : NumV} (h : oldNvB c x = true) : σ.nv x = x := by
  cases x with
  | lit _ => rfl
  | ref i => exact hf.num i (Nat.blt_eq.mp h)

theorem fix_handle {k : Nat} (h : oldBigB c (.ofNat k) = true) : σ.handle k = k := by
  show (σ.big (Int.ofNat k)).toNat = k
  rw [hf.big _ h]; rfl

theorem fix_dim {d : Dim} (h : oldDimB c d = true) : σ.dim d = d := by
  rcases d with i | ⟨f | i⟩
  · rfl
  · change (F64.toInt? f).isNone = true at h
    show dimOf (.lit f) = .sym (.lit f)
    cases e : F64.toInt? f with
    | none => simp only [dimOf, e]
    | some _ => rw [e] at h; cases h
  · show dimOf (σ.nv (.ref i)) = .sym (.ref i)
    rw [fix_nv hf (x := .ref i) h]; rfl

theorem fix_dims {ds : List Dim} (h : ds.all (oldDimB c) = true) : σ.dims ds = ds :=
  map_fix (fun _ => fix_dim hf) h

theorem fix_cell {x : Cell} (h : oldCellB c x = true) : σ.cell x = x := by
  cases x with
  | num x => show Cell.num (σ.nv x) = _; rw [fix_nv hf h]
  | big i => show Cell.big (σ.big i) = _; rw [hf.big i h]

theorem fix_byte {b : Byte} (h : oldByteB c b = true) : σ.byte b = b := by
  cases b with
  | lit _ => rfl
  | part k x i => show Byte.part k (σ.cell x) i = _; rw [fix_cell hf h]

theorem fix_arg {a : Arg} (h : oldArgB c a = true) : σ.arg a = a := by
  cases a with
  | num x => show Arg.num (σ.nv x) = _; rw [fix_nv hf h]
  | big i => show Arg.big (σ.big i) = _; rw [hf.big i h]
  | jsPtr b o bs =>
    simp only [oldArgB, Bool.and_eq_true, Nat.blt_eq] at h
    show Arg.jsPtr (σ.a b) o (bs.map σ.byte) = _
    rw [hf.a b h.1, map_fix (fun _ => fix_byte hf) h.2]
  | extPtr r o => show Arg.extPtr (σ.region r) o = _; rw [hf.region r h]
  | other v => cases h
  | null => rfl
  | bool _ => rfl

theorem fix_cfg {cf : Cfg} (h : oldCfgB c cf = true) : σ.cfg cf = cf := by
  simp only [oldCfgB, Bool.and_eq_true] at h
  obtain ⟨⟨⟨⟨ho, hg⟩, hgr⟩, hi⟩, hin⟩ := h
  obtain ⟨outs, grid, group, ints, dtypes, init⟩ := cf
  show (⟨outs.map fun (s, d) => (σ.dims s, d), grid.map σ.nv, group.map σ.nv, ints.map fun (n, v) => (n, σ.nv v),
    dtypes, init.map σ.nv⟩ : Cfg) = _
  rw [map_fix (f := fun (p : List Dim × Nat) => (σ.dims p.1, p.2)) (fun p hp => by rw [fix_dims hf hp]) ho,
    map_fix (fun _ => fix_nv hf) hg, map_fix (fun _ => fix_nv hf) hgr,
    map_fix (f := fun (p : List Char × NumV) => (p.1, σ.nv p.2)) (fun p hp => by rw [fix_nv hf hp]) hi]
  cases init with
  | none => rfl
  | some v => simp only [Option.all_some] at hin; simp only [Option.map_some, fix_nv hf hin]

theorem fix_prim : ∀ {p : Prim}, oldPrimB c p = true → σ.prim p = p := by
  intro p h
  induction p
  case data bs => show Prim.data (bs.map σ.byte) = _; rw [map_fix (fun _ => fix_byte hf) h]
  case arange a b d =>
    simp only [oldPrimB, Bool.and_eq_true] at h
    show Prim.arange (σ.nv a) (σ.nv b) (σ.nv d) = _
    rw [fix_nv hf h.1.1, fix_nv hf h.1.2, fix_nv hf h.2]
  case reshape s => show Prim.reshape (σ.dims s) = _; rw [fix_dims hf h]
  case slice a b d =>
    simp only [oldPrimB, Bool.and_eq_true] at h
    show Prim.slice (σ.dims a) (σ.dims b) (σ.dims d) = _
    rw [fix_dims hf h.1.1, fix_dims hf h.1.2, fix_dims hf h.2]
  case sliceUpdate a b d =>
    simp only [oldPrimB, Bool.and_eq_true] at h
    show Prim.sliceUpdate (σ.dims a) (σ.dims b) (σ.dims d) = _
    rw [fix_dims hf h.1.1, fix_dims hf h.1.2, fix_dims hf h.2]
  case sliceDynamic ax sz => show Prim.sliceDynamic ax (σ.dims sz) = _; rw [fix_dims hf h]
  case rmsNorm e => show Prim.rmsNorm (σ.nv e) = _; rw [fix_nv hf h]
  case rope d t b s o =>
    simp only [oldPrimB, Bool.and_eq_true] at h
    show Prim.rope d t (σ.arg b) (σ.nv s) (σ.nv o) = _
    rw [fix_arg hf h.1.1, fix_nv hf h.1.2, fix_nv hf h.2]
  case sdpa s m => show Prim.sdpa (σ.nv s) m = _; rw [fix_nv hf h]
  case kernel k cf o =>
    simp only [oldPrimB, Bool.and_eq_true] at h
    show Prim.kernel (σ.handle k) (σ.cfg cf) o = _
    rw [fix_handle hf h.1, fix_cfg hf h.2]
  case replayed cl p ih =>
    simp only [oldPrimB, Bool.and_eq_true] at h
    show Prim.replayed (σ.handle cl) (σ.prim p) = _
    rw [fix_handle hf h.1, ih h.2]
  all_goals rfl

theorem fix_nodes {l : List Nat} (h : oldNodesB c l = true) : l.map σ.node = l :=
  map_fix (fun j hj => hf.node j (Nat.blt_eq.mp hj)) h

theorem fix_nnode {nd : Node} (h : oldNodeB c nd = true) : σ.nnode nd = nd := by
  simp only [oldNodeB, Bool.and_eq_true] at h
  obtain ⟨prim, ins, shape, dtype⟩ := nd
  show (⟨σ.prim prim, ins.map σ.node, σ.dims shape, dtype⟩ : Node) = _
  rw [fix_prim hf h.1.1, fix_nodes hf h.1.2, fix_dims hf h.2]

theorem fix_trace {t : Trace} (h : oldTraceB c t = true) : σ.trace t = t := by
  simp only [oldTraceB, Bool.and_eq_true] at h
  obtain ⟨ins, outs, order⟩ := t
  show (⟨ins.map σ.node, outs.map σ.node, order.map σ.node⟩ : Trace) = _
  rw [fix_nodes hf h.1.1, fix_nodes hf h.1.2, fix_nodes hf h.2]

theorem fix_clo {cl : Clo} (h : oldCloB c cl = true) : σ.clo cl = cl := by
  cases cl with
  | empty => rfl
  | fn cb p =>
    simp only [oldCloB, Bool.and_eq_true] at h
    show Clo.fn (σ.region cb) (σ.arg p) = _
    rw [hf.region cb h.1, fix_arg hf h.2]
  | compiled cb p sl ts =>
    simp only [oldCloB, Bool.and_eq_true] at h
    show Clo.compiled (σ.region cb) (σ.arg p) sl (ts.map σ.trace) = _
    rw [hf.region cb h.1.1, fix_arg hf h.1.2, map_fix (fun _ => fix_trace hf) h.2]

/-- **A map fixing the old names fixes an old native object.** -/
theorem fix_nobj {o : NObj} (h : oldObjB c o = true) : σ.nobj o = o := by
  cases o
  case vec ns => show Host.Mlx.Ffi.Obj.vec (ns.map σ.node) = _; rw [fix_nodes hf h]
  case cfg cf => show Host.Mlx.Ffi.Obj.cfg (σ.cfg cf) = _; rw [fix_cfg hf h]
  case clo cl => show Host.Mlx.Ffi.Obj.clo (σ.clo cl) = _; rw [fix_clo hf h]
  all_goals rfl

end

/-! ## Compaction maps fix the call's names -/

section
variable (D : RData) {c : Cnt}

theorem _root_.Host.Ts.Sim.Template.RData.big_mid {k : Nat} (h1 : RData.bigHi ≤ k) (h2 : k < 2 ^ 62) : D.big (Int.ofNat k) = Int.ofNat k := by
  have e1 : Nat.ble (2 ^ 62) k = false := RData.ble_false h2
  have e2 : Nat.blt k RData.bigHi = false :=
    Bool.eq_false_iff.mpr fun h => absurd (Nat.blt_eq.mp h) (Nat.not_lt.mpr h1)
  show D.bigN k = Int.ofNat k
  unfold RData.bigN
  rw [e1, Bool.cond_false, e2, Bool.cond_false]

/-- Keys of a table at or past a bound, as a Boolean check. -/
theorem keys_ge {α : Type} {t : PTrie α} {b : Nat} (h : (PTrie.keysA t).all (Nat.ble b) = true) :
    ∀ k y, t.get k = some y → b ≤ k := fun k y hg =>
  Nat.le_of_ble_eq_true (List.all_eq_true.mp h k (PTrie.mem_keysA _ _ _ hg))

theorem _root_.Host.Ts.Sim.Template.RData.hd_fix (hk : ∀ k y, D.hnd.get k = some y → c.xn ≤ k) (hx : c.xn ≤ D.nh0) {h : Nat} (hh : h < c.xn) :
    D.hd h = h := by
  rw [RData.hd_old D (Nat.lt_of_lt_of_le hh hx)]
  cases e : D.hnd.get h with
  | none => rfl
  | some y => exact absurd (hk h y e) (Nat.not_le.mpr hh)

theorem _root_.Host.Ts.Sim.Template.RData.a_fix (hk : ∀ k y, D.heap.get k = some y → c.ja ≤ k) (hx : c.ja ≤ D.n0) {a : Nat} (ha : a < c.ja) :
    D.a a = a := by
  rw [RData.a_old D (Nat.lt_of_lt_of_le ha hx)]
  cases e : D.heap.get a with
  | none => rfl
  | some y => exact absurd (hk a y e) (Nat.not_le.mpr ha)

theorem _root_.Host.Ts.Sim.Template.RData.node_fix (hk : ∀ k y, D.node.get k = some y → c.nn ≤ k) (hx : c.nn ≤ D.nn0) {j : Nat} (hj : j < c.nn) :
    D.nodeF j = j := by
  rw [RData.node_old D (Nat.lt_of_lt_of_le hj hx)]
  cases e : D.node.get j with
  | none => rfl
  | some y => exact absurd (hk j y e) (Nat.not_le.mpr hj)

theorem _root_.Host.Ts.Sim.Template.RData.region_fix (hh : ∀ k y, D.hnd.get k = some y → c.xn ≤ k) (hx : c.xn ≤ D.nh0)
    (ha : ∀ k y, D.heap.get k = some y → c.ja ≤ k) (hja : c.ja ≤ D.n0) {r : Nat} (hr : oldRegB c r = true) :
    D.region r = r := by
  by_cases hb : 2 ^ 48 ≤ r
  · rw [oldRegB_hi hb] at hr
    have hlt := Nat.blt_eq.mp hr
    have e : cbBase + (r - 2 ^ 48) = r := by unfold cbBase; omega
    rw [← e, D.region_cb, D.a_fix ha hja hlt]
  · have hb' := Nat.lt_of_not_le hb
    rw [oldRegB_lo hb', Bool.or_eq_true] at hr
    have h46 : r / 4 < 2 ^ 46 := by omega
    rcases hr with h3 | hx'
    · have e : 4 * (r / 4) + 3 = r := by have := Nat.beq_eq.mp h3; omega
      rw [← e, D.region_host h46]
    · have hlt := Nat.blt_eq.mp hx'
      by_cases h3 : r % 4 = 3
      · have e : 4 * (r / 4) + 3 = r := by omega
        rw [← e, D.region_host h46]
      · have e : 4 * (r / 4) + r % 4 = r := by omega
        rw [← e, D.region_hd (by omega) h46, D.hd_fix hh hx hlt]

theorem _root_.Host.Ts.Sim.Template.RData.big_fix (hh : ∀ k y, D.hnd.get k = some y → c.xn ≤ k) (hx : c.xn ≤ D.nh0)
    (ha : ∀ k y, D.heap.get k = some y → c.ja ≤ k) (hja : c.ja ≤ D.n0) (hxb : c.xn ≤ RData.bigHi) :
    ∀ {i : Int}, oldBigB c i = true → D.big i = i
  | .negSucc _, _ => rfl
  | .ofNat k, hi => by
    by_cases hk : 2 ^ 62 ≤ k
    · rw [oldBigB_hi hk] at hi
      have e : 2 ^ 62 + (k - 2 ^ 62) / 2 ^ 24 * 2 ^ 24 + (k - 2 ^ 62) % 2 ^ 24 = k := by omega
      have hoff : (k - 2 ^ 62) % 2 ^ 24 < 2 ^ 24 := Nat.mod_lt _ (by decide)
      have hp : Int.ofNat k = ptrInt (.ext ((k - 2 ^ 62) / 2 ^ 24)) ((k - 2 ^ 62) % 2 ^ 24) := by
        show Int.ofNat k = ((2 ^ 62 + (k - 2 ^ 62) / 2 ^ 24 * 2 ^ 24 + (k - 2 ^ 62) % 2 ^ 24 : Nat) : Int)
        rw [e]; rfl
      rw [hp, D.big_ext _ _ hoff, D.region_fix hh hx ha hja hi]
    · have hk' := Nat.lt_of_not_le hk
      rw [oldBigB_lo hk', Bool.or_eq_true] at hi
      rcases hi with h1 | h1
      · have hl := Nat.blt_eq.mp h1
        rw [D.big_small (Nat.lt_of_lt_of_le hl hxb), D.hd_fix hh hx hl]
      · exact D.big_mid (Nat.le_of_ble_eq_true h1) hk'

end

/-- **A compaction map fixes the call's names**, from its tables lying past the call's counters. -/
theorem fixOld_compact {c : Cnt} {D : RData} {n0 n1 nS : Nat} {pl : List Nat} {nr : List NumV}
    (hja : c.ja ≤ n0) (hn : c.n ≤ nS) (hjaD : c.ja ≤ D.n0) (hxn : c.xn ≤ D.nh0) (hnn : c.nn ≤ D.nn0)
    (hxb : c.xn ≤ RData.bigHi)
    (hheap : (PTrie.keysA D.heap).all (Nat.ble c.ja) = true) (hhnd : (PTrie.keysA D.hnd).all (Nat.ble c.xn) = true)
    (hnode : (PTrie.keysA D.node).all (Nat.ble c.nn) = true) :
    FixOld c (Map.compact n0 n1 nS pl nr D.big D.region D.nodeF) where
  a x hx := Map.compact_lt (Nat.lt_of_lt_of_le hx hja)
  num i hi := Map.compact_num_lt (Nat.lt_of_lt_of_le hi hn)
  big i hi := D.big_fix (keys_ge hhnd) hxn (keys_ge hheap) hjaD hxb hi
  region r hr := D.region_fix (keys_ge hhnd) hxn (keys_ge hheap) hjaD hr
  node j hj := D.node_fix (keys_ge hnode) hnn hj

end Host.Ts.Sim.Conv
