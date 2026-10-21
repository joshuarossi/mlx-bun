import host.sim.native.Image
import host.sim.Ffi
import host.sim.Step
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # The native relation of the decode route

`LoadR P M n x y` relates the template's native state `x` (a source
iteration) to a target iteration's `y` under the map `M`, with `n` number
references allocated (the closedness bound).

* Host state: identical; host regions (`4h + 3`) map to themselves.
* Handles (bigints): below `P.lo` every bigint is fixed; a present handle
  `h` (a key of `arrs` or `objs`) has a nonnegative image `M.handle h`, its
  shape region `4h` and string region `4h + 1` follow it, and its target
  entries are exactly the images. Fresh handles continue in order as long as
  the target counter stays below `2 ^ 46` (`hfresh`, stated on the target's
  side so it survives the restart's shift); the target has room for the rest
  of the template's allocations (`hroom`).
* Nodes, in three bands: below `P.NL` (created before the decode loop:
  weights, constants, compiled traces) nodes map identically with full
  correspondence; in `[P.NL, P.N0)` (history of earlier iterations) only
  shape and dtype correspond (their primitives differ between iterations and
  their inputs may be absent); from `P.N0` on (created in this run) prim,
  inputs, shape and dtype correspond. Node images respect the order below
  every fully corresponding node (`norder`). Symbolic dimensions of node shapes have canonical
  images (`DimCanon`: shape memory reads back the image number).
* Readback: the target's tokens extend the image of the source's; the item
  memo corresponds on present nodes.
* Closedness: every number reference in `x` satisfies `· < n`. -/

/-- Fixed parameters: the first renamed handle `lo` (the band of renamed
bigints is `[lo, 2 ^ 56)`), the template's end counters `E` (handles) and `NE`
(nodes), the pre-loop node bound `NL` and the template's start node counter `N0`. -/
structure LoadP where
  lo : Nat
  E : Nat
  NE : Nat
  NL : Nat
  N0 : Nat
  /-- The target's readbacks after the source's tokens. -/
  rest : List NumV

/-- A present handle. -/
def PH (x : NSt) (h : Nat) : Prop := (x.arrs.get h).isSome = true ∨ (x.objs.get h).isSome = true

/-- A present node. -/
def PN (x : NSt) (k : Nat) : Prop := (x.nodes.get k).isSome = true

/-- Handle `h` is named `h'` by `M`: as a bigint and through its regions. -/
def HMap (M : Map) (h h' : Nat) : Prop :=
  M.big (Int.ofNat h) = Int.ofNat h' ∧ M.region (4 * h) = 4 * h' ∧ M.region (4 * h + 1) = 4 * h' + 1

/-- A dimension whose image number is the number the target's dimension holds. -/
def DimCanon (M : Map) (d : Dim) : Prop := (M.dim d).num = M.nv d.num

def Full (P : LoadP) (i : Nat) : Prop := i < P.NL ∨ P.N0 ≤ i

def NodeR (P : LoadP) (M : Map) (i : Nat) (nd nd' : Node) : Prop :=
  nd'.shape = M.dims nd.shape ∧ nd'.dtype = nd.dtype ∧ (∀ d ∈ nd.shape, DimCanon M d) ∧
    (Full P i → nd'.prim = M.prim nd.prim ∧ nd'.ins = nd.ins.map M.node)

/-- Nodes a compiled closure's traces replay. -/
def objTraces : NObj → List Nat
  | .clo (.compiled _ _ _ ts) => ts.flatMap Trace.order
  | _ => []

/-- Closedness of a native state. -/
def SSt (R : Nat → Prop) (x : NSt) : Prop :=
  (∀ i nd, x.nodes.get i = some nd → SNode R nd) ∧ (∀ h o, x.objs.get h = some o → SObj R o) ∧
    (∀ t ∈ x.tokens, SN R t) ∧ (∀ k t, x.items.get k = some t → SN R t) ∧ (∀ a, x.errh = some a → SA R a)

/-- The weak native relation: fresh handle images unassigned, readbacks up to a suffix. -/
structure MRw (P : LoadP) (M : Map) (n : Nat) (x y : NSt) : Prop where
  lo : 0 < P.lo
  bigFix : ∀ i : Int, i < P.lo → M.big i = i
  /-- Bigints from the template's end counter on (below `2 ^ 56`) are fixed. -/
  bigFixHi : ∀ i : Int, (P.E : Int) ≤ i → i < 2 ^ 56 → M.big i = i
  present : ∀ h, PH x h → HMap M h (M.handle h)
  hinj : ∀ a b, PH x a → PH x b → M.handle a = M.handle b → a = b
  hlt : ∀ h, PH x h → h < x.next
  himg : ∀ h, PH x h → 0 < M.handle h ∧ M.handle h < y.next
  hband : ∀ h, PH x h → P.lo ≤ h → P.lo ≤ M.handle h
  /-- Fresh handles' regions continue in order. -/
  hfreshR : ∀ k, y.next + k < 2 ^ 46 →
    M.region (4 * (x.next + k)) = 4 * (y.next + k) ∧ M.region (4 * (x.next + k) + 1) = 4 * (y.next + k) + 1
  /-- Bigint images keep zeroness. -/
  zero : ∀ i : Int, (M.big i == 0) = (i == 0)
  hnext : P.lo ≤ x.next ∧ x.next ≤ y.next
  hroom : x.next ≤ P.E ∧ y.next + (P.E - x.next) < 2 ^ 46
  absent0 : x.arrs.get 0 = none ∧ x.objs.get 0 = none ∧ y.objs.get 0 = none
  yabsent : ∀ h, y.next ≤ h → y.arrs.get h = none ∧ y.objs.get h = none
  arrs : ∀ h, PH x h → y.arrs.get (M.handle h) = (x.arrs.get h).map M.node
  objs : ∀ h, PH x h → y.objs.get (M.handle h) = (x.objs.get h).map M.nobj
  cfgCanon : ∀ h c, x.objs.get h = some (.cfg c) → ∀ p ∈ c.outs, ∀ d ∈ p.1, DimCanon M d
  traced : ∀ h o, x.objs.get h = some o → ∀ i ∈ objTraces o, i < P.NL
  node0 : M.node 0 = 0
  nid : ∀ j, j < P.NL → M.node j = j
  nall : ∀ j, j < x.nnext → M.node j < y.nnext
  norder : ∀ i, PN x i → Full P i → ∀ j, j < i → M.node j < M.node i
  nodes : ∀ i nd, x.nodes.get i = some nd → ∃ nd', y.nodes.get (M.node i) = some nd' ∧ NodeR P M i nd nd'
  ninj : ∀ a b, PN x a → PN x b → M.node a = M.node b → a = b
  nlt : ∀ i, PN x i → i < x.nnext
  nimg : ∀ i, PN x i → M.node i < y.nnext
  nfresh : ∀ k, M.node (x.nnext + k) = y.nnext + k
  nband : P.NL ≤ P.N0 ∧ P.N0 ≤ x.nnext
  nroom : x.nnext ≤ y.nnext ∧ x.nnext ≤ P.NE ∧ y.nnext + (P.NE - x.nnext) < 2 ^ 62
  tokens : ∃ rest, y.tokens = x.tokens.map M.nv ++ rest
  items : ∀ k, PN x k → y.items.get (M.node k) = (x.items.get k).map M.nv
  itemsPresent : ∀ k, (x.items.get k).isSome = true → PN x k
  yitems : ∀ k, y.nnext ≤ k → y.items.get k = none
  pending : y.pending = x.pending.map M.pend
  errh : y.errh = x.errh.map M.arg
  files : y.files = x.files
  arch : y.arch = x.arch
  sizes : y.deviceSizes = x.deviceSizes
  wired : y.wired = x.wired
  cl : SSt (· < n) x

/-- The native relation: fresh handles continue in order up to the template's end
counter, and the target's readbacks are exactly the images of the source's followed
by `P.rest`. -/
structure MR (P : LoadP) (M : Map) (n : Nat) (x y : NSt) : Prop extends MRw P M n x y where
  hfreshB : ∀ k, x.next + k < P.E → M.big (Int.ofNat (x.next + k)) = Int.ofNat (y.next + k)
  tokensX : y.tokens = x.tokens.map M.nv ++ P.rest

/-- The native relation of the load world. -/
structure LoadR (P : LoadP) (M : Map) (n : Nat) (x y : Host.Load.LSt) : Prop where
  host : y.host = x.host
  /-- Host regions (`4h + 3`, including the mappings `hostAddr` names) are fixed. -/
  hostReg : ∀ h, h < 2 ^ 46 → M.region (4 * h + 3) = 4 * h + 3
  hostLt : ∀ h, (x.host.objs.get h).isSome = true → h < 2 ^ 46
  /-- `JSCallback` regions follow the address map. -/
  cbr : ∀ a, M.region (cbBase + a) = cbBase + M.a a
  mlx : MR P M n x.mlx y.mlx

/-- The weak relation (at iteration boundaries, before fresh handles are reassigned). -/
structure LoadRw (P : LoadP) (M : Map) (n : Nat) (x y : Host.Load.LSt) : Prop where
  host : y.host = x.host
  hostReg : ∀ h, h < 2 ^ 46 → M.region (4 * h + 3) = 4 * h + 3
  hostLt : ∀ h, (x.host.objs.get h).isSome = true → h < 2 ^ 46
  cbr : ∀ a, M.region (cbBase + a) = cbBase + M.a a
  mlx : MRw P M n x.mlx y.mlx

theorem LoadR.weak {P : LoadP} {M : Map} {n : Nat} {x y : Host.Load.LSt} (hr : LoadR P M n x y) :
    LoadRw P M n x y :=
  ⟨hr.host, hr.hostReg, hr.hostLt, hr.cbr, hr.mlx.toMRw⟩

/-! ## Stability: `FRLaws` -/

section
variable {R : Nat → Prop} {M M' : Map}

theorem DimCanon.agree (h : NAgree R M M') {d : Dim} (hd : SD R d) (hc : DimCanon M d) :
    DimCanon M' d := by
  have hn : SN R d.num := by cases d with
    | lit _ => trivial
    | sym x => exact hd
  unfold DimCanon at *
  rw [h.dim hd, h.nv hn]
  exact hc

theorem SSt.mono {R R' : Nat → Prop} (hR : ∀ i, R i → R' i) {x : NSt} (h : SSt R x) : SSt R' x :=
  ⟨fun i nd hn => SNode.mono hR (h.1 i nd hn), fun i o ho => SObj.mono hR (h.2.1 i o ho),
    fun t ht => SN.mono hR (h.2.2.1 t ht), fun k t ht => SN.mono hR (h.2.2.2.1 k t ht),
    fun a ha => SA.mono hR (h.2.2.2.2 a ha)⟩

/-- The relation only depends on the map's names and on the references the source holds. -/
theorem MRw.agree {P : LoadP} {n : Nat} {x y : NSt} (hr : MRw P M n x y) (hcl : SSt R x)
    (h : NAgree R M M') : MRw P M' n x y := by
  have hH : ∀ k, M'.handle k = M.handle k := h.handle
  have hHM : ∀ a b, HMap M a b → HMap M' a b := fun a b hm => by
    unfold HMap; rw [h.big, h.region]; exact hm
  refine
    { lo := hr.lo
      bigFix := fun i hi => by rw [h.big]; exact hr.bigFix i hi
      bigFixHi := fun i h1 h2 => by rw [h.big]; exact hr.bigFixHi i h1 h2
      present := fun k hk => by rw [hH]; exact hHM _ _ (hr.present k hk)
      hinj := fun a b ha hb he => hr.hinj a b ha hb (by rw [← hH, ← hH b]; exact he)
      hlt := hr.hlt
      himg := fun k hk => by rw [hH]; exact hr.himg k hk
      hband := fun k hk hl => by rw [hH]; exact hr.hband k hk hl
      hfreshR := fun k hk => by rw [h.region]; exact hr.hfreshR k hk
      zero := fun i => by rw [h.big]; exact hr.zero i
      hnext := hr.hnext
      hroom := hr.hroom
      absent0 := hr.absent0
      yabsent := hr.yabsent
      arrs := fun k hk => by rw [hH, h.node]; exact hr.arrs k hk
      objs := fun k hk => by
        rw [hH, hr.objs k hk]
        cases ho : x.objs.get k with
        | none => rfl
        | some o => simp only [Option.map_some, h.nobj (hcl.2.1 k o ho)]
      cfgCanon := fun k c hc p hp d hd => by
        have hs := (hcl.2.1 k _ hc).1 p hp d hd
        exact DimCanon.agree h hs (hr.cfgCanon k c hc p hp d hd)
      traced := hr.traced
      node0 := by rw [h.node]; exact hr.node0
      nid := fun j hj => by rw [h.node]; exact hr.nid j hj
      nall := fun j hj => by rw [h.node]; exact hr.nall j hj
      norder := fun i hi hf j hj => by rw [h.node]; exact hr.norder i hi hf j hj
      nodes := fun i nd hn => by
        obtain ⟨nd', h1, hs, hd, hc, hf⟩ := hr.nodes i nd hn
        have hsn := hcl.1 i nd hn
        refine ⟨nd', by rw [h.node]; exact h1, by rw [h.dims hsn.2]; exact hs, hd,
          fun d hm => DimCanon.agree h (hsn.2 d hm) (hc d hm), fun hfull => ?_⟩
        rw [h.prim hsn.1, h.node]
        exact hf hfull
      ninj := fun a b ha hb he => hr.ninj a b ha hb (by rw [← h.node]; exact he)
      nlt := hr.nlt
      nimg := fun i hi => by rw [h.node]; exact hr.nimg i hi
      nfresh := fun k => by rw [h.node]; exact hr.nfresh k
      nband := hr.nband
      nroom := hr.nroom
      tokens := by
        obtain ⟨rest, hrest⟩ := hr.tokens
        refine ⟨rest, ?_⟩
        rw [hrest, List.map_congr_left fun t ht => h.nv (hcl.2.2.1 t ht)]
      items := fun k hk => by
        rw [h.node, hr.items k hk]
        cases hi : x.items.get k with
        | none => rfl
        | some t => simp only [Option.map_some, h.nv (hcl.2.2.2.1 k t hi)]
      itemsPresent := hr.itemsPresent
      yitems := hr.yitems
      pending := by rw [hr.pending]; exact List.map_congr_left fun p _ => (h.pend p).symm
      errh := by
        rw [hr.errh]
        cases he : x.errh with
        | none => rfl
        | some a => simp only [Option.map_some, h.arg (hcl.2.2.2.2 a he)]
      files := hr.files
      arch := hr.arch
      sizes := hr.sizes
      wired := hr.wired
      cl := hr.cl }

theorem MR.agree {P : LoadP} {n : Nat} {x y : NSt} (hr : MR P M n x y) (hcl : SSt R x)
    (h : NAgree R M M') : MR P M' n x y :=
  { hr.toMRw.agree hcl h with
    hfreshB := fun k hk => by rw [h.big]; exact hr.hfreshB k hk
    tokensX := by rw [hr.tokensX, List.map_congr_left fun t ht => h.nv (hcl.2.2.1 t ht)] }

theorem LoadR.agree {P : LoadP} {n : Nat} {x y : Host.Load.LSt} (hr : LoadR P M n x y)
    (hcl : SSt R x.mlx) (h : NAgree R M M') : LoadR P M' n x y :=
  ⟨hr.host, fun k hk => by rw [h.region]; exact hr.hostReg k hk, hr.hostLt,
    fun a => by rw [h.region, h.a]; exact hr.cbr a, hr.mlx.agree hcl h⟩

theorem LoadR.mono {P : LoadP} {n n' : Nat} {x y : Host.Load.LSt} (hr : LoadR P M n x y) (hn : n ≤ n') :
    LoadR P M n' x y :=
  ⟨hr.host, hr.hostReg, hr.hostLt, hr.cbr,
    { hr.mlx with cl := SSt.mono (fun i hi => Nat.lt_of_lt_of_le hi hn) hr.mlx.cl }⟩
end

theorem loadR_laws (P : LoadP) : FRLaws (F := Host.Load.ffi) (LoadR P) :=
  ⟨fun _ _ _ _ _ hr he => hr.agree hr.mlx.cl (NAgree.ofExt he), fun _ _ _ _ _ hr hn => hr.mono hn⟩

/-! ## Facts for the interpreter side -/

section
variable {P : LoadP} {M : Map} {n : Nat} {x y : NSt} (hr : MR P M n x y)
include hr

/-- Present handles and fixed bigints have distinct images unless equal. -/
theorem MR.big_inj {a b : Nat} (ha : PH x a) (hb : PH x b)
    (he : M.big (Int.ofNat a) = M.big (Int.ofNat b)) : a = b := by
  apply hr.hinj a b ha hb
  have h1 := (hr.present a ha).1
  have h2 := (hr.present b hb).1
  rw [h1, h2] at he
  exact Int.ofNat.inj he

theorem MR.big_inj_fixed {a : Nat} {i : Int} (ha : PH x a) (hi : i < P.lo)
    (he : M.big (Int.ofNat a) = M.big i) : Int.ofNat a = i := by
  rw [hr.bigFix i hi, (hr.present a ha).1] at he
  by_cases hl : P.lo ≤ a
  · have := hr.hband a ha hl
    simp only [Int.ofNat_eq_natCast] at he
    omega
  · have hfa : M.big (Int.ofNat a) = Int.ofNat a := hr.bigFix _ (by simp only [Int.ofNat_eq_natCast]; omega)
    rw [(hr.present a ha).1] at hfa
    rw [← he, ← hfa]

theorem MR.big_range {a : Nat} (ha : PH x a) :
    0 ≤ M.big (Int.ofNat a) ∧ M.big (Int.ofNat a) < 2 ^ 63 ∧ PH y (M.handle a) := by
  rw [(hr.present a ha).1]
  have hi := hr.himg a ha
  have hroom := hr.hroom.2
  refine ⟨Int.natCast_nonneg _, by simp only [Int.ofNat_eq_natCast]; omega, ?_⟩
  rcases ha with ha | ha
  · left; rw [hr.arrs a (.inl ha)]; cases h : x.arrs.get a <;> simp_all
  · right; rw [hr.objs a (.inr ha)]; cases h : x.objs.get a <;> simp_all

theorem MR.region_inj {a b : Nat} (ha : PH x a) (hb : PH x b) (i j : Nat) (hi : i < 2) (hj : j < 2)
    (he : M.region (4 * a + i) = M.region (4 * b + j)) : a = b ∧ i = j := by
  have ra : M.region (4 * a + i) = 4 * M.handle a + i := by
    rcases (show i = 0 ∨ i = 1 by omega) with rfl | rfl
    · exact (hr.present a ha).2.1
    · exact (hr.present a ha).2.2
  have rb : M.region (4 * b + j) = 4 * M.handle b + j := by
    rcases (show j = 0 ∨ j = 1 by omega) with rfl | rfl
    · exact (hr.present b hb).2.1
    · exact (hr.present b hb).2.2
  rw [ra, rb] at he
  have hij : i = j := by omega
  exact ⟨hr.hinj a b ha hb (by omega), hij⟩
end

end Host.Ts.Sim
