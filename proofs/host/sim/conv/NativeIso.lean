import host.sim.native.gen.Shift
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Isolate: the native part

`MIso P0 P1 n0 σ x0 x1`: the caller's native state `x1` (parameters `P1`) holds a copy of the stage
template's native start `x0` (parameters `P0`) under `σ`: `MShift` (`host.sim.native.Shift`) with
the two sides' parameters apart, the template's fresh handles mapped in order to the caller's
(`hfreshB`) and its readbacks the images of the caller's (`tokens`). `mshift_iso`: a target related
to the caller under `M` is related to the template start under `M.after σ` (the strong relation:
fresh handles in order, readbacks), given the parameters' order:

* the same handle band start `lo` and pre-loop band `NL`;
* the caller's fixed bigints include the template's (`P1.E ≤ P0.E`) and the template's fresh
  handles land inside the caller's (`hE`: `x0.next + k < P0.E → x1.next + k < P1.E`);

so a stage template's native counters sit above every caller's (the template's handle names are
free: the generator places them high). `loadR_iso`: the same for `G.LoadR`, the isolate's native law
(`hFS` of `host.sim.conv.Iso.isolate`). -/

structure MIso (P0 P1 : LoadP) (n0 : Nat) (σ : Map) (x0 x1 : NSt) : Prop where
  bigFix : ∀ i : Int, i < P0.lo → σ.big i = i
  bigFixHi : ∀ i : Int, (P0.E : Int) ≤ i → i < 2 ^ 56 → σ.big i = i
  nonneg : ∀ h : Nat, 0 ≤ σ.big (Int.ofNat h)
  present : ∀ h, PH x0 h → HMap σ h (σ.handle h) ∧ PH x1 (σ.handle h)
  hinj : ∀ a b, PH x0 a → PH x0 b → σ.handle a = σ.handle b → a = b
  hlt : ∀ h, PH x0 h → h < x0.next
  hband : ∀ h, PH x0 h → P0.lo ≤ h → P1.lo ≤ σ.handle h
  hfreshR : ∀ k, x1.next + k < 2 ^ 46 → σ.region (4 * (x0.next + k)) = 4 * (x1.next + k) ∧
    σ.region (4 * (x0.next + k) + 1) = 4 * (x1.next + k) + 1
  hfreshB : ∀ k, x0.next + k < P0.E → σ.big (Int.ofNat (x0.next + k)) = Int.ofNat (x1.next + k)
  zero : ∀ i : Int, (σ.big i == 0) = (i == 0)
  hnext : P0.lo ≤ x0.next
  absent0 : x0.arrs.get 0 = none ∧ x0.objs.get 0 = none
  arrs : ∀ h, PH x0 h → x1.arrs.get (σ.handle h) = (x0.arrs.get h).map σ.node
  objs : ∀ h, PH x0 h → x1.objs.get (σ.handle h) = (x0.objs.get h).map σ.nobj
  cfgCanon : ∀ h c, x0.objs.get h = some (.cfg c) → ∀ p ∈ c.outs, ∀ d ∈ p.1, DimCanon σ d
  traced : ∀ h o, x0.objs.get h = some o → ∀ i ∈ objTraces o, i < P0.NL
  node0 : σ.node 0 = 0
  nid : ∀ j, j < P0.NL → σ.node j = j
  nall : ∀ j, j < x0.nnext → σ.node j < x1.nnext
  norder : ∀ i, PN x0 i → Full P0 i → ∀ j, j < i → σ.node j < σ.node i
  nfull : ∀ i, PN x0 i → Full P0 i → Full P1 (σ.node i)
  nodes : ∀ i nd, x0.nodes.get i = some nd → ∃ nd1, x1.nodes.get (σ.node i) = some nd1 ∧ Host.Ts.Sim.NodeR P0 σ i nd nd1
  ninj : ∀ a b, PN x0 a → PN x0 b → σ.node a = σ.node b → a = b
  nlt : ∀ i, PN x0 i → i < x0.nnext
  nfresh : ∀ k, σ.node (x0.nnext + k) = x1.nnext + k
  nband : P0.NL ≤ P0.N0 ∧ P0.N0 ≤ x0.nnext
  tokens : x1.tokens = x0.tokens.map σ.nv
  items : ∀ k, PN x0 k → x1.items.get (σ.node k) = (x0.items.get k).map σ.nv
  itemsPresent : ∀ k, (x0.items.get k).isSome = true → PN x0 k
  pending : x1.pending = x0.pending.map σ.pend
  errh : x1.errh = x0.errh.map σ.arg
  files : x1.files = x0.files
  arch : x1.arch = x0.arch
  sizes : x1.deviceSizes = x0.deviceSizes
  wired : x1.wired = x0.wired
  cl : SSt (· < n0) x0

/-- The native part of the call morphism in the load world. -/
structure NIso (P0 P1 : LoadP) (n0 : Nat) (σ : Map) (x0 x1 : Host.Load.LSt) : Prop where
  host : x1.host = x0.host
  hostReg : ∀ h, h < 2 ^ 46 → σ.region (4 * h + 3) = 4 * h + 3
  cbr : ∀ a, σ.region (cbBase + a) = cbBase + σ.a a
  mlx : MIso P0 P1 n0 σ x0.mlx x1.mlx

section
variable {P0 P1 : LoadP} {NB : Nat} {M σ : Map} {n0 n1 : Nat}

private theorem hmap_after' {a b c : Nat} (h1 : HMap σ a b) (h2 : HMap M b c) : HMap (M.after σ) a c :=
  ⟨by rw [Map.after_big, h1.1, h2.1], by rw [Map.after_region, h1.2.1, h2.2.1],
    by rw [Map.after_region, h1.2.2, h2.2.2]⟩

/-- **Isolate, native part**: the weak relation. -/
theorem miso_w {x0 x1 z : NSt} (hs : MIso P0 P1 n0 σ x0 x1) (hr : MRw P1 NB M n1 x1 z)
    (hlo : P0.lo = P1.lo) (hNL : P0.NL = P1.NL) (hE : P1.E ≤ P0.E)
    (hz : x0.next ≤ z.next) (hroom : x0.next ≤ P0.E ∧ z.next + (P0.E - x0.next) < 2 ^ 46)
    (hroomN : x0.nnext ≤ z.nnext ∧ x0.nnext ≤ P0.NE ∧ z.nnext + (P0.NE - x0.nnext) < 2 ^ 62) :
    MRw P0 NB (M.after σ) n0 x0 z := by
  have hH : ∀ h, (M.after σ).handle h = M.handle (σ.handle h) := fun h =>
    (Map.handle_after M σ (hs.nonneg h)).symm
  have hx1 := hr.hnext
  refine
    { lo := by rw [hlo]; exact hr.lo
      bigFix := fun i hi => by rw [Map.after_big, hs.bigFix i hi, hr.bigFix i (by rw [← hlo]; exact hi)]
      bigFixHi := fun i h1 h2 => by
        rw [Map.after_big, hs.bigFixHi i h1 h2, hr.bigFixHi i (Int.le_trans (Int.ofNat_le.mpr hE) h1) h2]
      present := fun h hp => by
        rw [hH]; exact hmap_after' (hs.present h hp).1 (hr.present _ (hs.present h hp).2)
      hinj := fun a b ha hb he => by
        rw [hH, hH] at he
        exact hs.hinj a b ha hb (hr.hinj _ _ (hs.present a ha).2 (hs.present b hb).2 he)
      hlt := hs.hlt
      himg := fun h hp => by rw [hH]; exact hr.himg _ (hs.present h hp).2
      hband := fun h hp hl => by
        rw [hH, hlo]; exact hr.hband _ (hs.present h hp).2 (hs.hband h hp hl)
      hfreshR := fun k hk => by
        have h1 := hs.hfreshR k (by have := hx1.2; omega)
        have h2 := hr.hfreshR k hk
        exact ⟨by rw [Map.after_region, h1.1, h2.1], by rw [Map.after_region, h1.2, h2.2]⟩
      zero := fun i => by rw [Map.after_big, hr.zero, hs.zero]
      hnext := ⟨hs.hnext, hz⟩
      hroom := hroom
      absent0 := ⟨hs.absent0.1, hs.absent0.2, hr.absent0.2.2⟩
      yabsent := hr.yabsent
      arrs := fun h hp => by
        rw [hH, hr.arrs _ (hs.present h hp).2, hs.arrs h hp]
        show ((x0.arrs.get h).map σ.node).map M.node = (x0.arrs.get h).map (fun k => M.node (σ.node k))
        rw [Option.map_map]; rfl
      objs := fun h hp => by
        rw [hH, hr.objs _ (hs.present h hp).2, hs.objs h hp, Option.map_map]
        show _ = (x0.objs.get h).map (M.after σ).nobj
        congr 1; funext o; exact Map.nobj_after M σ o
      cfgCanon := fun h c hc p hp d hd => by
        have h1 := hs.objs h (.inr (by show (x0.objs.get h).isSome = true; rw [hc]; rfl))
        rw [hc] at h1
        have h2 := hr.cfgCanon _ _ h1 _ (List.mem_map.mpr ⟨p, hp, rfl⟩) (σ.dim d)
          (List.mem_map.mpr ⟨d, hd, rfl⟩)
        have h3 := hs.cfgCanon h c hc p hp d hd
        unfold DimCanon at *
        rw [← Map.dim_after, h2, h3, Map.nv_after]
      traced := hs.traced
      node0 := by show M.node (σ.node 0) = 0; rw [hs.node0, hr.node0]
      nid := fun j hj => by
        show M.node (σ.node j) = j
        rw [hs.nid j (by rw [hNL]; exact Nat.lt_of_lt_of_le hj hr.nbl), hr.nid j hj]
      nbl := by rw [hNL]; exact hr.nbl
      nall := fun j hj => hr.nall _ (hs.nall j hj)
      norder := fun i hi hf j hj => by
        obtain ⟨nd1, h1, -⟩ := hs.nodes i _ (Option.get_mem hi)
        exact hr.norder _ (by show (x1.nodes.get (σ.node i)).isSome = true; rw [h1]; rfl)
          (hs.nfull i hi hf) _ (hs.norder i hi hf j hj)
      nodes := fun i nd hn => by
        obtain ⟨nd1, h1, hs1, hd1, hc1, hf1⟩ := hs.nodes i nd hn
        obtain ⟨nd', h2, hs2, hd2, hc2, hf2⟩ := hr.nodes _ nd1 h1
        refine ⟨nd', h2, ?_, by rw [hd2, hd1], ?_, fun hf => ?_⟩
        · rw [hs2, hs1, Map.dims_after]
        · intro d hd
          have h3 := hc2 (σ.dim d) (by rw [hs1]; exact List.mem_map.mpr ⟨d, hd, rfl⟩)
          unfold DimCanon at *
          rw [← Map.dim_after, h3, hc1 d hd, Map.nv_after]
        · have hp : PN x0 i := by show (x0.nodes.get i).isSome = true; rw [hn]; rfl
          obtain ⟨e1, e2⟩ := hf1 hf
          obtain ⟨e3, e4⟩ := hf2 (hs.nfull i hp hf)
          refine ⟨PrimR.after e1 hs1 (fun h _ => hs.nonneg h) e3, ?_⟩
          rw [e4, e2, List.map_map]; rfl
      ninj := fun a b ha hb he => by
        obtain ⟨_, h1, -⟩ := hs.nodes a _ (Option.get_mem ha)
        obtain ⟨_, h2, -⟩ := hs.nodes b _ (Option.get_mem hb)
        exact hs.ninj a b ha hb (hr.ninj _ _ (by show (x1.nodes.get _).isSome = true; rw [h1]; rfl)
          (by show (x1.nodes.get _).isSome = true; rw [h2]; rfl) he)
      nlt := hs.nlt
      nimg := fun i hi => by
        obtain ⟨_, h1, -⟩ := hs.nodes i _ (Option.get_mem hi)
        exact hr.nimg _ (by show (x1.nodes.get _).isSome = true; rw [h1]; rfl)
      nfresh := fun k => by show M.node (σ.node (x0.nnext + k)) = _; rw [hs.nfresh, hr.nfresh]
      nband := hs.nband
      nroom := hroomN
      tokens := by
        obtain ⟨rest, hrest⟩ := hr.tokens
        refine ⟨rest, ?_⟩
        rw [hrest, hs.tokens, List.map_map]
        congr 1
        exact List.map_congr_left fun t _ => Map.nv_after M σ t
      items := fun k hk => by
        obtain ⟨_, h1, -⟩ := hs.nodes k _ (Option.get_mem hk)
        show z.items.get (M.node (σ.node k)) = _
        rw [hr.items _ (by show (x1.nodes.get _).isSome = true; rw [h1]; rfl), hs.items k hk, Option.map_map]
        congr 1; funext t; exact Map.nv_after M σ t
      itemsPresent := hs.itemsPresent
      yitems := hr.yitems
      pending := by
        rw [hr.pending, hs.pending, List.map_map]
        exact List.map_congr_left fun p _ => Map.pend_after M σ p (fun h _ => hs.nonneg h)
      errh := by
        rw [hr.errh, hs.errh, Option.map_map]
        show _ = x0.errh.map (M.after σ).arg
        congr 1; funext a; exact Map.arg_after M σ a
      files := by rw [hr.files, hs.files]
      arch := by rw [hr.arch, hs.arch]
      sizes := by rw [hr.sizes, hs.sizes]
      wired := by rw [hr.wired, hs.wired]
      cl := hs.cl }

/-- **Isolate, native part**: the strong relation, with the template's fresh handles inside the
caller's band (`hE'`). -/
theorem miso {x0 x1 z : NSt} (hs : MIso P0 P1 n0 σ x0 x1) (hr : MR P1 NB M n1 x1 z)
    (hlo : P0.lo = P1.lo) (hNL : P0.NL = P1.NL) (hE : P1.E ≤ P0.E)
    (hE' : ∀ k, x0.next + k < P0.E → x1.next + k < P1.E) (hrest : P0.rest = P1.rest)
    (hz : x0.next ≤ z.next) (hroom : x0.next ≤ P0.E ∧ z.next + (P0.E - x0.next) < 2 ^ 46)
    (hroomN : x0.nnext ≤ z.nnext ∧ x0.nnext ≤ P0.NE ∧ z.nnext + (P0.NE - x0.nnext) < 2 ^ 62) :
    MR P0 NB (M.after σ) n0 x0 z :=
  { miso_w hs hr.toMRw hlo hNL hE hz hroom hroomN with
    hfreshB := fun k hk => by
      rw [Map.after_big, hs.hfreshB k hk]
      exact hr.hfreshB k (hE' k hk)
    tokensX := by
      rw [hr.tokensX, hs.tokens, List.map_map, hrest]
      congr 1
      exact List.map_congr_left fun t _ => Map.nv_after M σ t }

/-- **The isolate's native law for the load world.** -/
theorem loadR_iso {x0 x1 z : Host.Load.LSt} (hs : NIso P0 P1 n0 σ x0 x1) (hr : LoadR P1 NB M n1 x1 z)
    (hlo : P0.lo = P1.lo) (hNL : P0.NL = P1.NL) (hE : P1.E ≤ P0.E)
    (hE' : ∀ k, x0.mlx.next + k < P0.E → x1.mlx.next + k < P1.E) (hrest : P0.rest = P1.rest)
    (hz : x0.mlx.next ≤ z.mlx.next)
    (hroom : x0.mlx.next ≤ P0.E ∧ z.mlx.next + (P0.E - x0.mlx.next) < 2 ^ 46)
    (hroomN : x0.mlx.nnext ≤ z.mlx.nnext ∧ x0.mlx.nnext ≤ P0.NE ∧ z.mlx.nnext + (P0.NE - x0.mlx.nnext) < 2 ^ 62) :
    LoadR P0 NB (M.after σ) n0 x0 z where
  host := by rw [hr.host, hs.host]
  hostReg := fun h hh => by rw [Map.after_region, hs.hostReg h hh, hr.hostReg h hh]
  hostLt := fun h hh => hr.hostLt h (by rw [hs.host]; exact hh)
  cbr := fun a => by rw [Map.after_region, hs.cbr, hr.cbr]; rfl
  mlx := miso hs.mlx hr.mlx hlo hNL hE hE' hrest hz hroom hroomN

end

end Host.Ts.Sim.G
