import host.sim.template.NShiftOf
import host.sim.stage.Mlx
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Native names below the counters: the native cut bookkeeping

`NClean c x`: every array, native object, node and readback item of the native state `x` mentions
only **old names** for the counters `c` (`Cnt`): handles below `c.xn` (as bigints, or bigints the
handle band leaves alone), nodes below `c.nn`, JavaScript addresses below `c.ja` (callback regions,
`jsPtr` buffers), table references below `c.n`, canonical dimensions, and no JavaScript value
argument. A map fixing the old names fixes such entries (`host.sim.conv.NFix`), so a compaction map,
which fixes the call's names, needs no check of the call's entries the stage leaves.

The bookkeeping (as `Clean` for the heap): one full check at a chain's start (`ncleanB`), then every
piece checks only the entries it changes or creates against its end's counters (`ncleanListB`,
`NClean.stepB`, with the piece's native footprint off the lists); counters only grow (`NClean.mono`). -/

/-- The counters old names lie below. -/
structure Cnt where
  xn : Nat
  nn : Nat
  ja : Nat
  n : Nat

/-- `c` below `c'` in every counter. -/
structure Cnt.Le (c c' : Cnt) : Prop where
  xn : c.xn ≤ c'.xn
  nn : c.nn ≤ c'.nn
  ja : c.ja ≤ c'.ja
  n : c.n ≤ c'.n

/-- The counters of a call, as a Boolean comparison. -/
def Cnt.leB (c c' : Cnt) : Bool := Nat.ble c.xn c'.xn && Nat.ble c.nn c'.nn && Nat.ble c.ja c'.ja && Nat.ble c.n c'.n

theorem Cnt.le_of_leB {c c' : Cnt} (h : c.leB c' = true) : c.Le c' := by
  simp only [Cnt.leB, Bool.and_eq_true, Nat.ble_eq] at h
  exact ⟨h.1.1.1, h.1.1.2, h.1.2, h.2⟩

theorem all_mono {α : Type} {p q : α → Bool} (hpq : ∀ a, p a = true → q a = true) {l : List α}
    (h : l.all p = true) : l.all q = true := by
  simp only [List.all_eq_true] at h ⊢
  exact fun a ha => hpq a (h a ha)

section
variable (c : Cnt)

/-- An old region: a callback region of an old address, a host region, or a handle's region. -/
def oldRegB (r : Nat) : Bool :=
  bif Nat.ble (2 ^ 48) r then Nat.blt (r - 2 ^ 48) c.ja else (Nat.beq (r % 4) 3 || Nat.blt (r / 4) c.xn)

/-- An old bigint: negative, an old handle, outside the handle band, or a pointer into an old region. -/
def oldBigB : Int → Bool
  | .ofNat k => bif Nat.ble (2 ^ 62) k then oldRegB c ((k - 2 ^ 62) / 2 ^ 24)
    else (Nat.blt k c.xn || Nat.ble RData.bigHi k)
  | .negSucc _ => true

def oldNvB : NumV → Bool
  | .lit _ => true
  | .ref i => Nat.blt i c.n

/-- An old, canonical dimension. -/
def oldDimB : Dim → Bool
  | .lit _ => true
  | .sym (.ref i) => Nat.blt i c.n
  | .sym (.lit f) => (F64.toInt? f).isNone

def oldCellB : Cell → Bool
  | .num x => oldNvB c x
  | .big i => oldBigB c i

def oldByteB : Byte → Bool
  | .lit _ => true
  | .part _ cl _ => oldCellB c cl

def oldArgB : Arg → Bool
  | .num x => oldNvB c x
  | .big i => oldBigB c i
  | .jsPtr b _ bs => Nat.blt b c.ja && bs.all (oldByteB c)
  | .extPtr r _ => oldRegB c r
  | .other _ => false
  | _ => true

def oldCfgB (cf : Cfg) : Bool :=
  cf.outs.all (fun p => p.1.all (oldDimB c)) && cf.grid.all (oldNvB c) && cf.group.all (oldNvB c) &&
    cf.ints.all (fun p => oldNvB c p.2) && cf.init.all (oldNvB c)

def oldPrimB : Prim → Bool
  | .data bs => bs.all (oldByteB c)
  | .arange a b d => oldNvB c a && oldNvB c b && oldNvB c d
  | .reshape s => s.all (oldDimB c)
  | .slice a b d => a.all (oldDimB c) && b.all (oldDimB c) && d.all (oldDimB c)
  | .sliceUpdate a b d => a.all (oldDimB c) && b.all (oldDimB c) && d.all (oldDimB c)
  | .sliceDynamic _ sz => sz.all (oldDimB c)
  | .rmsNorm e => oldNvB c e
  | .rope _ _ b s o => oldArgB c b && oldNvB c s && oldNvB c o
  | .sdpa s _ => oldNvB c s
  | .kernel k cf _ => oldBigB c (.ofNat k) && oldCfgB c cf
  | .replayed cl p => oldBigB c (.ofNat cl) && oldPrimB p
  | _ => true

def oldNodesB (l : List Nat) : Bool := l.all fun j => Nat.blt j c.nn

def oldNodeB (nd : Node) : Bool := oldPrimB c nd.prim && oldNodesB c nd.ins && nd.shape.all (oldDimB c)

def oldTraceB (t : Trace) : Bool := oldNodesB c t.ins && oldNodesB c t.outs && oldNodesB c t.order

def oldCloB : Clo → Bool
  | .empty => true
  | .fn cb p => oldRegB c cb && oldArgB c p
  | .compiled cb p _ ts => oldRegB c cb && oldArgB c p && ts.all (oldTraceB c)

def oldObjB : NObj → Bool
  | .vec ns => oldNodesB c ns
  | .cfg cf => oldCfgB c cf
  | .clo cl => oldCloB c cl
  | _ => true

end

/-! The large literals stay unreduced: these characterizations are proven by congruence, so the kernel
never compares `r - 2 ^ 48` with a reduced form. -/

section
variable {c : Cnt}

theorem oldRegB_hi {r : Nat} (hr : 2 ^ 48 ≤ r) : oldRegB c r = Nat.blt (r - 2 ^ 48) c.ja :=
  (congrArg (fun b => bif b then Nat.blt (r - 2 ^ 48) c.ja else (Nat.beq (r % 4) 3 || Nat.blt (r / 4) c.xn))
    (RData.ble_true hr)).trans Bool.cond_true

theorem oldRegB_lo {r : Nat} (hr : r < 2 ^ 48) : oldRegB c r = (Nat.beq (r % 4) 3 || Nat.blt (r / 4) c.xn) :=
  (congrArg (fun b => bif b then Nat.blt (r - 2 ^ 48) c.ja else (Nat.beq (r % 4) 3 || Nat.blt (r / 4) c.xn))
    (RData.ble_false hr)).trans Bool.cond_false

theorem oldBigB_hi {k : Nat} (hk : 2 ^ 62 ≤ k) : oldBigB c (.ofNat k) = oldRegB c ((k - 2 ^ 62) / 2 ^ 24) :=
  (congrArg (fun b => bif b then oldRegB c ((k - 2 ^ 62) / 2 ^ 24) else (Nat.blt k c.xn || Nat.ble RData.bigHi k))
    (RData.ble_true hk)).trans Bool.cond_true

theorem oldBigB_lo {k : Nat} (hk : k < 2 ^ 62) : oldBigB c (.ofNat k) = (Nat.blt k c.xn || Nat.ble RData.bigHi k) :=
  (congrArg (fun b => bif b then oldRegB c ((k - 2 ^ 62) / 2 ^ 24) else (Nat.blt k c.xn || Nat.ble RData.bigHi k))
    (RData.ble_false hk)).trans Bool.cond_false

end

/-- **The native bookkeeping**: arrays, objects, nodes and readback items mention only old names. -/
structure NClean (c : Cnt) (x : NSt) : Prop where
  arrs : ∀ h j, x.arrs.get h = some j → j < c.nn
  objs : ∀ h o, x.objs.get h = some o → oldObjB c o = true
  nodes : ∀ i nd, x.nodes.get i = some nd → oldNodeB c nd = true
  items : ∀ k v, x.items.get k = some v → oldNvB c v = true

/-! ## Monotonicity -/

section
variable {c c' : Cnt} (hc : c.Le c')
include hc

theorem oldRegB_mono {r : Nat} (h : oldRegB c r = true) : oldRegB c' r = true := by
  by_cases hr : 2 ^ 48 ≤ r
  · rw [oldRegB_hi hr] at h ⊢
    exact Nat.blt_eq.mpr (Nat.lt_of_lt_of_le (Nat.blt_eq.mp h) hc.ja)
  · have hr' := Nat.lt_of_not_le hr
    rw [oldRegB_lo hr'] at h ⊢
    rw [Bool.or_eq_true] at h ⊢
    exact h.imp id (fun h => Nat.blt_eq.mpr (Nat.lt_of_lt_of_le (Nat.blt_eq.mp h) hc.xn))

theorem oldBigB_mono {i : Int} (h : oldBigB c i = true) : oldBigB c' i = true := by
  cases i with
  | negSucc _ => rfl
  | ofNat k =>
    by_cases hk : 2 ^ 62 ≤ k
    · rw [oldBigB_hi hk] at h ⊢
      exact oldRegB_mono hc h
    · have hk' := Nat.lt_of_not_le hk
      rw [oldBigB_lo hk'] at h ⊢
      rw [Bool.or_eq_true] at h ⊢
      exact h.imp (fun h => Nat.blt_eq.mpr (Nat.lt_of_lt_of_le (Nat.blt_eq.mp h) hc.xn)) id

theorem oldNvB_mono {x : NumV} (h : oldNvB c x = true) : oldNvB c' x = true := by
  cases x with
  | lit _ => rfl
  | ref i => simp only [oldNvB, Nat.blt_eq] at h ⊢; have := hc.n; omega

theorem oldDimB_mono {d : Dim} (h : oldDimB c d = true) : oldDimB c' d = true := by
  rcases d with _ | ⟨_ | i⟩
  · rfl
  · exact h
  · simp only [oldDimB, Nat.blt_eq] at h ⊢; have := hc.n; omega

theorem oldCellB_mono {x : Cell} (h : oldCellB c x = true) : oldCellB c' x = true := by
  cases x with
  | num x => exact oldNvB_mono hc h
  | big i => exact oldBigB_mono hc h

theorem oldByteB_mono {b : Byte} (h : oldByteB c b = true) : oldByteB c' b = true := by
  cases b with
  | lit _ => rfl
  | part _ cl _ => exact oldCellB_mono hc h

theorem oldArgB_mono {a : Arg} (h : oldArgB c a = true) : oldArgB c' a = true := by
  cases a with
  | num x => exact oldNvB_mono hc h
  | big i => exact oldBigB_mono hc h
  | jsPtr b o bs =>
    simp only [oldArgB, Bool.and_eq_true, Nat.blt_eq] at h ⊢
    exact ⟨by have := hc.ja; omega, all_mono (fun _ => oldByteB_mono hc) h.2⟩
  | extPtr r o => exact oldRegB_mono hc h
  | other v => exact h
  | null => rfl
  | bool _ => rfl

theorem oldCfgB_mono {cf : Cfg} (h : oldCfgB c cf = true) : oldCfgB c' cf = true := by
  simp only [oldCfgB, Bool.and_eq_true] at h ⊢
  refine ⟨⟨⟨⟨all_mono (fun p hp => all_mono (fun _ => oldDimB_mono hc) hp) h.1.1.1.1,
    all_mono (fun _ => oldNvB_mono hc) h.1.1.1.2⟩, all_mono (fun _ => oldNvB_mono hc) h.1.1.2⟩,
    all_mono (fun p => oldNvB_mono hc) h.1.2⟩, ?_⟩
  cases e : cf.init with
  | none => rfl
  | some v => rw [e] at h; exact oldNvB_mono (c := c) hc (by simpa using h.2)

theorem oldPrimB_mono : ∀ {p : Prim}, oldPrimB c p = true → oldPrimB c' p = true := by
  intro p h
  induction p
  case data bs => exact all_mono (fun _ => oldByteB_mono hc) h
  case arange a b d =>
    simp only [oldPrimB, Bool.and_eq_true] at h ⊢
    exact ⟨⟨oldNvB_mono hc h.1.1, oldNvB_mono hc h.1.2⟩, oldNvB_mono hc h.2⟩
  case reshape s => exact all_mono (fun _ => oldDimB_mono hc) h
  case slice a b d =>
    simp only [oldPrimB, Bool.and_eq_true] at h ⊢
    exact ⟨⟨all_mono (fun _ => oldDimB_mono hc) h.1.1, all_mono (fun _ => oldDimB_mono hc) h.1.2⟩,
      all_mono (fun _ => oldDimB_mono hc) h.2⟩
  case sliceUpdate a b d =>
    simp only [oldPrimB, Bool.and_eq_true] at h ⊢
    exact ⟨⟨all_mono (fun _ => oldDimB_mono hc) h.1.1, all_mono (fun _ => oldDimB_mono hc) h.1.2⟩,
      all_mono (fun _ => oldDimB_mono hc) h.2⟩
  case sliceDynamic _ sz => exact all_mono (fun _ => oldDimB_mono hc) h
  case rmsNorm e => exact oldNvB_mono hc h
  case rope _ _ b s o =>
    simp only [oldPrimB, Bool.and_eq_true] at h ⊢
    exact ⟨⟨oldArgB_mono hc h.1.1, oldNvB_mono hc h.1.2⟩, oldNvB_mono hc h.2⟩
  case sdpa s _ => exact oldNvB_mono hc h
  case kernel k cf _ =>
    simp only [oldPrimB, Bool.and_eq_true] at h ⊢
    exact ⟨oldBigB_mono hc h.1, oldCfgB_mono hc h.2⟩
  case replayed cl p ih =>
    simp only [oldPrimB, Bool.and_eq_true] at h ⊢
    exact ⟨oldBigB_mono hc h.1, ih h.2⟩
  all_goals rfl

theorem oldNodesB_mono {l : List Nat} (h : oldNodesB c l = true) : oldNodesB c' l = true :=
  all_mono (fun j hj => by simp only [Nat.blt_eq] at hj ⊢; have := hc.nn; omega) h

theorem oldNodeB_mono {nd : Node} (h : oldNodeB c nd = true) : oldNodeB c' nd = true := by
  simp only [oldNodeB, Bool.and_eq_true] at h ⊢
  exact ⟨⟨oldPrimB_mono hc h.1.1, oldNodesB_mono hc h.1.2⟩, all_mono (fun _ => oldDimB_mono hc) h.2⟩

theorem oldTraceB_mono {t : Trace} (h : oldTraceB c t = true) : oldTraceB c' t = true := by
  simp only [oldTraceB, Bool.and_eq_true] at h ⊢
  exact ⟨⟨oldNodesB_mono hc h.1.1, oldNodesB_mono hc h.1.2⟩, oldNodesB_mono hc h.2⟩

theorem oldCloB_mono {cl : Clo} (h : oldCloB c cl = true) : oldCloB c' cl = true := by
  cases cl with
  | empty => rfl
  | fn cb p =>
    simp only [oldCloB, Bool.and_eq_true] at h ⊢
    exact ⟨oldRegB_mono hc h.1, oldArgB_mono hc h.2⟩
  | compiled cb p sl ts =>
    simp only [oldCloB, Bool.and_eq_true] at h ⊢
    exact ⟨⟨oldRegB_mono hc h.1.1, oldArgB_mono hc h.1.2⟩, all_mono (fun _ => oldTraceB_mono hc) h.2⟩

theorem oldObjB_mono {o : NObj} (h : oldObjB c o = true) : oldObjB c' o = true := by
  cases o
  case vec ns => exact oldNodesB_mono hc h
  case cfg cf => exact oldCfgB_mono hc h
  case clo cl => exact oldCloB_mono hc h
  all_goals rfl

/-- **The bookkeeping survives the counters' growth.** -/
theorem NClean.mono {x : NSt} (h : NClean c x) : NClean c' x where
  arrs hh j hg := Nat.lt_of_lt_of_le (h.arrs hh j hg) hc.nn
  objs hh o hg := oldObjB_mono hc (h.objs hh o hg)
  nodes i nd hg := oldNodeB_mono hc (h.nodes i nd hg)
  items k v hg := oldNvB_mono hc (h.items k v hg)

end

/-! ## The checks -/

section
variable (c : Cnt) (x : NSt)

def arrOldB (h : Nat) : Bool := match x.arrs.get h with | some j => Nat.blt j c.nn | none => true
def objOldB (h : Nat) : Bool := match x.objs.get h with | some o => oldObjB c o | none => true
def nodeOldB (i : Nat) : Bool := match x.nodes.get i with | some nd => oldNodeB c nd | none => true
def itemOldB (k : Nat) : Bool := match x.items.get k with | some v => oldNvB c v | none => true

/-- **The bookkeeping's full check** (a chain's start). -/
def ncleanB : Bool :=
  (PTrie.keysA x.arrs).all (arrOldB c x) && (PTrie.keysA x.objs).all (objOldB c x) &&
    (PTrie.keysA x.nodes).all (nodeOldB c x) && (PTrie.keysA x.items).all (itemOldB c x)

/-- **A piece's check** of the handles `lh`, nodes `ln` and readback items `li` it changes or creates. -/
def ncleanListB (lh ln li : List Nat) : Bool :=
  lh.all (arrOldB c x) && lh.all (objOldB c x) && ln.all (nodeOldB c x) && li.all (itemOldB c x)

end

section
variable {c : Cnt} {x : NSt}

theorem ncleanB_sound (h : ncleanB c x = true) : NClean c x := by
  simp only [ncleanB, Bool.and_eq_true, List.all_eq_true] at h
  obtain ⟨⟨⟨ha, ho⟩, hn⟩, hi⟩ := h
  refine ⟨fun k j hg => ?_, fun k o hg => ?_, fun i nd hg => ?_, fun k v hg => ?_⟩
  · have := ha k (PTrie.mem_keysA _ _ _ hg); simp only [arrOldB, hg, Nat.blt_eq] at this; exact this
  · have := ho k (PTrie.mem_keysA _ _ _ hg); simp only [objOldB, hg] at this; exact this
  · have := hn i (PTrie.mem_keysA _ _ _ hg); simp only [nodeOldB, hg] at this; exact this
  · have := hi k (PTrie.mem_keysA _ _ _ hg); simp only [itemOldB, hg] at this; exact this

/-- **A piece keeps the bookkeeping**: its end keeps its start's arrays and objects off `lh`, its nodes
off `ln`, its readback items off `li`, its counters grew, and the changed entries are checked. -/
theorem NClean.stepB {c' : Cnt} {x' : NSt} {lh ln li : List Nat} (h : NClean c x) (hc : c.Le c')
    (ha : ∀ k, k ∉ lh → x'.arrs.get k = x.arrs.get k) (ho : ∀ k, k ∉ lh → x'.objs.get k = x.objs.get k)
    (hn : ∀ i, i ∉ ln → x'.nodes.get i = x.nodes.get i) (hi : ∀ k, k ∉ li → x'.items.get k = x.items.get k)
    (hck : ncleanListB c' x' lh ln li = true) : NClean c' x' := by
  have h' := h.mono hc
  simp only [ncleanListB, Bool.and_eq_true, List.all_eq_true] at hck
  obtain ⟨⟨⟨cha, cho⟩, chn⟩, chi⟩ := hck
  refine ⟨fun k j hg => ?_, fun k o hg => ?_, fun i nd hg => ?_, fun k v hg => ?_⟩
  · by_cases hm : k ∈ lh
    · have := cha k hm; simp only [arrOldB, hg, Nat.blt_eq] at this; exact this
    · rw [ha k hm] at hg; exact h'.arrs k j hg
  · by_cases hm : k ∈ lh
    · have := cho k hm; simp only [objOldB, hg] at this; exact this
    · rw [ho k hm] at hg; exact h'.objs k o hg
  · by_cases hm : i ∈ ln
    · have := chn i hm; simp only [nodeOldB, hg] at this; exact this
    · rw [hn i hm] at hg; exact h'.nodes i nd hg
  · by_cases hm : k ∈ li
    · have := chi k hm; simp only [itemOldB, hg] at this; exact this
    · rw [hi k hm] at hg; exact h'.items k v hg

end

/-! ## The footprint in the generator's form -/

/-- An entry off `xs` of a trie that is its start updated at `xs` (with its own values) is the start's. -/
theorem get_keep {α : Type} {y x : PTrie α} {xs : List Nat}
    (h : y = Stage.setAll x (xs.filterMap fun i => (y.get i).map (i, ·)))
    (hb : xs.all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true) : ∀ k, k ∉ xs → y.get k = x.get k := by
  intro k hk
  have e := congrArg (fun t => PTrie.get t k) h
  refine e.trans (Stage.setAll_get x _ k fun p hp => ?_)
  obtain ⟨i, hi, hpi⟩ := List.mem_filterMap.1 hp
  cases hy : y.get i with
  | none => rw [hy] at hpi; cases hpi
  | some v =>
    rw [hy] at hpi
    cases hpi
    simp only [List.all_eq_true, Nat.blt_eq] at hb
    exact ⟨fun e => hk (e ▸ hi), hb i hi⟩

/-- **A piece keeps the bookkeeping**, its footprint as the generator states it: the end's arrays and
objects are its start's updated at the handles `lh`, its nodes at `ln`, its readback items at `li`
(`Stage.setAll` with the end's values), the counters grew, and the changed entries are checked. -/
theorem NClean.stepKeep {c c' : Cnt} {x x' : NSt} {lh ln li : List Nat} (h : NClean c x) (hc : c.leB c' = true)
    (ha : x'.arrs = Stage.setAll x.arrs (lh.filterMap fun i => (x'.arrs.get i).map (i, ·)))
    (ho : x'.objs = Stage.setAll x.objs (lh.filterMap fun i => (x'.objs.get i).map (i, ·)))
    (hn : x'.nodes = Stage.setAll x.nodes (ln.filterMap fun i => (x'.nodes.get i).map (i, ·)))
    (hi : x'.items = Stage.setAll x.items (li.filterMap fun i => (x'.items.get i).map (i, ·)))
    (hb : (lh ++ ln ++ li).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true)
    (hck : ncleanListB c' x' lh ln li = true) : NClean c' x' := by
  simp only [List.all_append, Bool.and_eq_true] at hb
  exact h.stepB (Cnt.le_of_leB hc) (get_keep ha hb.1.1) (get_keep ho hb.1.1) (get_keep hn hb.1.2)
    (get_keep hi hb.2) hck

end Host.Ts.Sim.Conv
