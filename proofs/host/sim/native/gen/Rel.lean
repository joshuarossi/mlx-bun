import host.sim.native.Args
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # The native relation for any prefill history

`G.MR P NB M n x y` relates the decode template's native state `x` to a target
state `y` reached after any prefill history. It is `Host.Ts.Sim.MR` with three
relaxations; the step lemmas of `host.sim.native` hold for it (`host.sim.native.gen.*`,
namespace `Host.Ts.Sim.G`), compiled-closure applies under the general check
`NativeOk.clApplyG`.

* **Renamed post-load band.** Only nodes below `NB ≤ P.NL` (the pre-load band)
  keep their ids (`nid`); nodes in `[NB, P.NL)` (created after load, before the
  decode loop: lazily created constants, compiled traces) are renamed by
  `M.node` with full correspondence, in order (`norder`). Handles were already
  renamed from `P.lo` on: a history-independent template takes `P.lo` at the
  post-load handle band.
* **Shape-only data nodes** (`shapeOnly`): a fully corresponding template node of
  host data whose shape is not literal (the B-newdata node `[1, n]` of a framed
  buffer) corresponds to a target data node with any bytes.
* **Target-only entries.** Handles, objects, nodes and readbacks the map does not
  name (live MLX handles of JavaScript ghost fields, their nodes, traces of
  history-only compiled closures) are unconstrained (`MR.ghost`).

Shapeless compiled traces record the shapes of their first call, and closure
payloads carry a trace id: the template holds both as number references
(`Dim.sym`, `Arg.num (.ref _)`), which `M` sends to the target's values; the
replay lemma (`host.sim.native.gen.Replay`) allows non-literal recorded shapes.

`Host.Ts.Sim.MR P` is the case `NB = P.NL` without shape-only nodes
(`MR.toG`, `MR.ofG`, `mr_iff`). -/

/-- Host data with a non-literal shape. -/
def shapeOnly (nd : Node) : Bool :=
  (match nd.prim with
    | .data _ => true
    | _ => false) && !(nd.shape.all dimLit)

/-- The primitive of a fully corresponding node: the image, or any host data for a shape-only node. -/
def PrimR (M : Map) (nd : Node) (p' : Prim) : Prop :=
  p' = M.prim nd.prim ∨ (shapeOnly nd = true ∧ ∃ bs, p' = .data bs)

def NodeR (P : LoadP) (M : Map) (i : Nat) (nd nd' : Node) : Prop :=
  nd'.shape = M.dims nd.shape ∧ nd'.dtype = nd.dtype ∧ (∀ d ∈ nd.shape, DimCanon M d) ∧
    (Full P i → PrimR M nd nd'.prim ∧ nd'.ins = nd.ins.map M.node)

theorem PrimR.exact {M : Map} {nd : Node} {p' : Prim} (h : PrimR M nd p') (hs : shapeOnly nd = false) :
    p' = M.prim nd.prim := by
  rcases h with h | ⟨h, -⟩
  · exact h
  · rw [hs] at h; cases h

/-- Shape-only nodes stay shape-only backwards along a map: the preimage of a shape-only node
under `σ` (same constructor, `σ`-images of its dimensions) is shape-only. -/
theorem shapeOnly_of_image (σ : Map) {nd nd1 : Node} (hp : nd1.prim = σ.prim nd.prim)
    (hs : nd1.shape = σ.dims nd.shape) (h : shapeOnly nd1 = true) : shapeOnly nd = true := by
  simp only [shapeOnly, Bool.and_eq_true, Bool.not_eq_true'] at h ⊢
  refine ⟨?_, ?_⟩
  · have h1 := h.1
    rw [hp] at h1
    cases e : nd.prim <;> rw [e] at h1 <;> first | rfl | cases h1
  · cases hl : nd.shape.all dimLit
    · rfl
    · have := h.2
      rw [hs, dims_lit σ hl, hl] at this
      cases this

/-- Primitive correspondence composes with a template shift `σ`. -/
theorem PrimR.after {M σ : Map} {nd nd1 : Node} {p' : Prim} (hp : nd1.prim = σ.prim nd.prim)
    (hs : nd1.shape = σ.dims nd.shape) (hh : ∀ h ∈ primHandles nd.prim, 0 ≤ σ.big (Int.ofNat h))
    (h : PrimR M nd1 p') : PrimR (M.after σ) nd p' := by
  rcases h with h | ⟨h1, bs, h2⟩
  · exact .inl (by rw [h, hp, Map.prim_after M σ _ hh])
  · exact .inr ⟨shapeOnly_of_image σ hp hs h1, bs, h2⟩

theorem NodeR.ofSim {P : LoadP} {M : Map} {i : Nat} {nd nd' : Node} (h : Sim.NodeR P M i nd nd') :
    NodeR P M i nd nd' :=
  ⟨h.1, h.2.1, h.2.2.1, fun hf => ⟨.inl (h.2.2.2 hf).1, (h.2.2.2 hf).2⟩⟩

theorem NodeR.toSim {P : LoadP} {M : Map} {i : Nat} {nd nd' : Node} (h : NodeR P M i nd nd')
    (hs : Full P i → shapeOnly nd = false) : Sim.NodeR P M i nd nd' :=
  ⟨h.1, h.2.1, h.2.2.1, fun hf => ⟨(h.2.2.2 hf).1.exact (hs hf), (h.2.2.2 hf).2⟩⟩

/-- The weak native relation (see the module doc). -/
structure MRw (P : LoadP) (NB : Nat) (M : Map) (n : Nat) (x y : NSt) : Prop where
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
  /-- The pre-load band keeps its ids. -/
  nid : ∀ j, j < NB → M.node j = j
  nbl : NB ≤ P.NL
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

/-- The native relation: fresh handles continue in order up to the template's end counter,
and the target's readbacks are exactly the images of the source's followed by `P.rest`. -/
structure MR (P : LoadP) (NB : Nat) (M : Map) (n : Nat) (x y : NSt) : Prop extends MRw P NB M n x y where
  hfreshB : ∀ k, x.next + k < P.E → M.big (Int.ofNat (x.next + k)) = Int.ofNat (y.next + k)
  tokensX : y.tokens = x.tokens.map M.nv ++ P.rest

/-- The native relation of the load world. -/
structure LoadR (P : LoadP) (NB : Nat) (M : Map) (n : Nat) (x y : Host.Load.LSt) : Prop where
  host : y.host = x.host
  hostReg : ∀ h, h < 2 ^ 46 → M.region (4 * h + 3) = 4 * h + 3
  hostLt : ∀ h, (x.host.objs.get h).isSome = true → h < 2 ^ 46
  cbr : ∀ a, M.region (cbBase + a) = cbBase + M.a a
  mlx : MR P NB M n x.mlx y.mlx

/-- The weak relation of the load world. -/
structure LoadRw (P : LoadP) (NB : Nat) (M : Map) (n : Nat) (x y : Host.Load.LSt) : Prop where
  host : y.host = x.host
  hostReg : ∀ h, h < 2 ^ 46 → M.region (4 * h + 3) = 4 * h + 3
  hostLt : ∀ h, (x.host.objs.get h).isSome = true → h < 2 ^ 46
  cbr : ∀ a, M.region (cbBase + a) = cbBase + M.a a
  mlx : MRw P NB M n x.mlx y.mlx

theorem LoadR.weak {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : Host.Load.LSt} (hr : LoadR P NB M n x y) :
    LoadRw P NB M n x y :=
  ⟨hr.host, hr.hostReg, hr.hostLt, hr.cbr, hr.mlx.toMRw⟩

/-! ## Stability: `FRLaws` -/

section
variable {R : Nat → Prop} {M M' : Map} {NB : Nat}

theorem PrimR.agree (h : NAgree R M M') {nd : Node} {p' : Prim} (hs : SP R nd.prim) (hp : PrimR M nd p') :
    PrimR M' nd p' := by
  rcases hp with hp | hp
  · exact .inl (by rw [h.prim hs]; exact hp)
  · exact .inr hp

/-- The relation only depends on the map's names and on the references the source holds. -/
theorem MRw.agree {P : LoadP} {n : Nat} {x y : NSt} (hr : MRw P NB M n x y) (hcl : SSt R x)
    (h : NAgree R M M') : MRw P NB M' n x y := by
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
      nbl := hr.nbl
      nall := fun j hj => by rw [h.node]; exact hr.nall j hj
      norder := fun i hi hf j hj => by rw [h.node]; exact hr.norder i hi hf j hj
      nodes := fun i nd hn => by
        obtain ⟨nd', h1, hs, hd, hc, hf⟩ := hr.nodes i nd hn
        have hsn := hcl.1 i nd hn
        refine ⟨nd', by rw [h.node]; exact h1, by rw [h.dims hsn.2]; exact hs, hd,
          fun d hm => DimCanon.agree h (hsn.2 d hm) (hc d hm), fun hfull => ?_⟩
        rw [h.node]
        exact ⟨(hf hfull).1.agree h hsn.1, (hf hfull).2⟩
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

theorem MR.agree {P : LoadP} {n : Nat} {x y : NSt} (hr : MR P NB M n x y) (hcl : SSt R x)
    (h : NAgree R M M') : MR P NB M' n x y :=
  { hr.toMRw.agree hcl h with
    hfreshB := fun k hk => by rw [h.big]; exact hr.hfreshB k hk
    tokensX := by rw [hr.tokensX, List.map_congr_left fun t ht => h.nv (hcl.2.2.1 t ht)] }

theorem LoadR.agree {P : LoadP} {n : Nat} {x y : Host.Load.LSt} (hr : LoadR P NB M n x y)
    (hcl : SSt R x.mlx) (h : NAgree R M M') : LoadR P NB M' n x y :=
  ⟨hr.host, fun k hk => by rw [h.region]; exact hr.hostReg k hk, hr.hostLt,
    fun a => by rw [h.region, h.a]; exact hr.cbr a, hr.mlx.agree hcl h⟩

theorem LoadR.mono {P : LoadP} {n n' : Nat} {x y : Host.Load.LSt} (hr : LoadR P NB M n x y) (hn : n ≤ n') :
    LoadR P NB M n' x y :=
  ⟨hr.host, hr.hostReg, hr.hostLt, hr.cbr,
    { hr.mlx with cl := SSt.mono (fun i hi => Nat.lt_of_lt_of_le hi hn) hr.mlx.cl }⟩
end

theorem loadR_laws (P : LoadP) (NB : Nat) : FRLaws (F := Host.Load.ffi) (LoadR P NB) :=
  ⟨fun _ _ _ _ _ hr he => hr.agree hr.mlx.cl (NAgree.ofExt he), fun _ _ _ _ _ hr hn => hr.mono hn⟩

/-! ## Facts for the interpreter side -/

section
variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y)
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

/-! ## Target-only entries

The relation constrains the target only at the images of the template's present handles and
nodes, at the fresh counters and in its global fields: target-only handles, objects, nodes and
readbacks below the counters are free. -/

/-- `y'` agrees with `y` wherever the relation looks; elsewhere below its counters it may hold
anything (handles the template has no counterpart of, their objects, nodes and readbacks). -/
structure GhostExt (M : Map) (x y y' : NSt) : Prop where
  next : y'.next = y.next
  nnext : y'.nnext = y.nnext
  arrs : ∀ h, PH x h → y'.arrs.get (M.handle h) = y.arrs.get (M.handle h)
  objs : ∀ h, PH x h → y'.objs.get (M.handle h) = y.objs.get (M.handle h)
  nodes : ∀ i, PN x i → y'.nodes.get (M.node i) = y.nodes.get (M.node i)
  items : ∀ i, PN x i → y'.items.get (M.node i) = y.items.get (M.node i)
  absent : ∀ h, y.next ≤ h → y'.arrs.get h = none ∧ y'.objs.get h = none
  obj0 : y'.objs.get 0 = none
  yitems : ∀ k, y.nnext ≤ k → y'.items.get k = none
  tokens : y'.tokens = y.tokens
  pending : y'.pending = y.pending
  errh : y'.errh = y.errh
  files : y'.files = y.files
  arch : y'.arch = y.arch
  sizes : y'.deviceSizes = y.deviceSizes
  wired : y'.wired = y.wired

section
variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y y' : NSt}

/-- **Target-only entries are free.** -/
theorem MRw.ghost (hr : MRw P NB M n x y) (hg : GhostExt M x y y') : MRw P NB M n x y' :=
  { hr with
    himg := fun h hp => by rw [hg.next]; exact hr.himg h hp
    hfreshR := fun k hk => by rw [hg.next] at hk ⊢; exact hr.hfreshR k hk
    hnext := by rw [hg.next]; exact hr.hnext
    hroom := by rw [hg.next]; exact hr.hroom
    absent0 := ⟨hr.absent0.1, hr.absent0.2.1, hg.obj0⟩
    yabsent := fun h hh => hg.absent h (by rw [← hg.next]; exact hh)
    arrs := fun h hp => by rw [hg.arrs h hp]; exact hr.arrs h hp
    objs := fun h hp => by rw [hg.objs h hp]; exact hr.objs h hp
    nall := fun j hj => by rw [hg.nnext]; exact hr.nall j hj
    nodes := fun i nd hn => by
      rw [hg.nodes i (by show (x.nodes.get i).isSome = true; rw [hn]; rfl)]; exact hr.nodes i nd hn
    nimg := fun i hi => by rw [hg.nnext]; exact hr.nimg i hi
    nfresh := fun k => by rw [hg.nnext]; exact hr.nfresh k
    nroom := by rw [hg.nnext]; exact hr.nroom
    tokens := by rw [hg.tokens]; exact hr.tokens
    items := fun k hk => by rw [hg.items k hk]; exact hr.items k hk
    yitems := fun k hk => hg.yitems k (by rw [← hg.nnext]; exact hk)
    pending := by rw [hg.pending]; exact hr.pending
    errh := by rw [hg.errh]; exact hr.errh
    files := by rw [hg.files]; exact hr.files
    arch := by rw [hg.arch]; exact hr.arch
    sizes := by rw [hg.sizes]; exact hr.sizes
    wired := by rw [hg.wired]; exact hr.wired }

theorem MR.ghost (hr : MR P NB M n x y) (hg : GhostExt M x y y') : MR P NB M n x y' :=
  { hr.toMRw.ghost hg with
    hfreshB := fun k hk => by rw [hg.next]; exact hr.hfreshB k hk
    tokensX := by rw [hg.tokens]; exact hr.tokensX }
end

/-! ## The special case: `Host.Ts.Sim.MR`

Today's relation is the case where the whole pre-loop band keeps its ids (`NB = P.NL`) and no
fully corresponding template node is shape-only. -/

/-- No fully corresponding template node is shape-only. -/
def NoShapeOnly (P : LoadP) (x : NSt) : Prop := ∀ i nd, x.nodes.get i = some nd → Full P i → shapeOnly nd = false

section
variable {P : LoadP} {M : Map} {n : Nat} {x y : NSt}

theorem _root_.Host.Ts.Sim.MRw.toG (h : Sim.MRw P M n x y) : MRw P P.NL M n x y :=
  { h with
    nbl := Nat.le_refl _
    nodes := fun i nd hn => by
      obtain ⟨nd', h1, h2⟩ := h.nodes i nd hn
      exact ⟨nd', h1, NodeR.ofSim h2⟩ }

theorem MRw.toSim (h : MRw P P.NL M n x y) (hs : NoShapeOnly P x) : Sim.MRw P M n x y :=
  { h with
    nodes := fun i nd hn => by
      obtain ⟨nd', h1, h2⟩ := h.nodes i nd hn
      exact ⟨nd', h1, h2.toSim (hs i nd hn)⟩ }

theorem _root_.Host.Ts.Sim.MR.toG (h : Sim.MR P M n x y) : MR P P.NL M n x y :=
  { h.toMRw.toG with hfreshB := h.hfreshB, tokensX := h.tokensX }

theorem MR.toSim (h : MR P P.NL M n x y) (hs : NoShapeOnly P x) : Sim.MR P M n x y :=
  { h.toMRw.toSim hs with hfreshB := h.hfreshB, tokensX := h.tokensX }

/-- **Special-case consistency**: without shape-only nodes, today's weak relation is the general
one with the whole pre-loop band fixed. -/
theorem mrw_iff (hs : NoShapeOnly P x) : Sim.MRw P M n x y ↔ MRw P P.NL M n x y :=
  ⟨fun h => h.toG, fun h => h.toSim hs⟩

theorem mr_iff (hs : NoShapeOnly P x) : Sim.MR P M n x y ↔ MR P P.NL M n x y :=
  ⟨fun h => h.toG, fun h => h.toSim hs⟩

end

section
variable {P : LoadP} {M : Map} {n : Nat} {x y : Host.Load.LSt}

theorem _root_.Host.Ts.Sim.LoadR.toG (h : Sim.LoadR P M n x y) : LoadR P P.NL M n x y :=
  ⟨h.host, h.hostReg, h.hostLt, h.cbr, h.mlx.toG⟩

theorem LoadR.toSim (h : LoadR P P.NL M n x y) (hs : NoShapeOnly P x.mlx) : Sim.LoadR P M n x y :=
  ⟨h.host, h.hostReg, h.hostLt, h.cbr, h.mlx.toSim hs⟩

theorem _root_.Host.Ts.Sim.LoadRw.toG (h : Sim.LoadRw P M n x y) : LoadRw P P.NL M n x y :=
  ⟨h.host, h.hostReg, h.hostLt, h.cbr, h.mlx.toG⟩

theorem LoadRw.toSim (h : LoadRw P P.NL M n x y) (hs : NoShapeOnly P x.mlx) : Sim.LoadRw P M n x y :=
  ⟨h.host, h.hostReg, h.hostLt, h.cbr, h.mlx.toSim hs⟩

theorem loadR_iff (hs : NoShapeOnly P x.mlx) : Sim.LoadR P M n x y ↔ LoadR P P.NL M n x y :=
  ⟨fun h => h.toG, fun h => h.toSim hs⟩

theorem loadRw_iff (hs : NoShapeOnly P x.mlx) : Sim.LoadRw P M n x y ↔ LoadRw P P.NL M n x y :=
  ⟨fun h => h.toG, fun h => h.toSim hs⟩
end

end Host.Ts.Sim.G
