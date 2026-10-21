import host.sim.native.Rel
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Iteration boundaries of the native relation

* `NShift P n0 σ x0 x1`: the template's end `x1` holds a copy of its start
  `x0` under `σ` (the names the next iteration uses for the start's
  resources), its fresh handles and nodes continue in order, and it has read
  all of its tokens (`x1.tokens = []`); `x0` is closed below `n0`.
* `loadRw_restart`: a target `z` weakly related to the end under `M` is weakly
  related to the start with its tokens cleared under `M.after σ`, given room in the
  target for one more iteration's allocations (`Rebig.lean` then reassigns the fresh
  handles' bigint images).
* `LoadRw.reseed`: a source with no tokens left gets fresh token references
  `js` bound to the target's next tokens `vs` (one reference for the ordinary
  templates, two for the final one). -/

structure MShift (P : LoadP) (n0 : Nat) (σ : Map) (x0 x1 : NSt) : Prop where
  bigFix : ∀ i : Int, i < P.lo → σ.big i = i
  bigFixHi : ∀ i : Int, (P.E : Int) ≤ i → i < 2 ^ 56 → σ.big i = i
  nonneg : ∀ h : Nat, 0 ≤ σ.big (Int.ofNat h)
  present : ∀ h, PH x0 h → HMap σ h (σ.handle h) ∧ PH x1 (σ.handle h)
  hinj : ∀ a b, PH x0 a → PH x0 b → σ.handle a = σ.handle b → a = b
  hlt : ∀ h, PH x0 h → h < x0.next
  hband : ∀ h, PH x0 h → P.lo ≤ h → P.lo ≤ σ.handle h
  /-- Fresh handles' regions continue in order while the end's counter stays below `2 ^ 46`
  (`σ.big` on fresh handles is unconstrained). -/
  hfreshR : ∀ k, x1.next + k < 2 ^ 46 → σ.region (4 * (x0.next + k)) = 4 * (x1.next + k) ∧
    σ.region (4 * (x0.next + k) + 1) = 4 * (x1.next + k) + 1
  zero : ∀ i : Int, (σ.big i == 0) = (i == 0)
  hnext : P.lo ≤ x0.next ∧ x0.next ≤ x1.next
  absent0 : x0.arrs.get 0 = none ∧ x0.objs.get 0 = none
  arrs : ∀ h, PH x0 h → x1.arrs.get (σ.handle h) = (x0.arrs.get h).map σ.node
  objs : ∀ h, PH x0 h → x1.objs.get (σ.handle h) = (x0.objs.get h).map σ.nobj
  cfgCanon : ∀ h c, x0.objs.get h = some (.cfg c) → ∀ p ∈ c.outs, ∀ d ∈ p.1, DimCanon σ d
  traced : ∀ h o, x0.objs.get h = some o → ∀ i ∈ objTraces o, i < P.NL
  node0 : σ.node 0 = 0
  nid : ∀ j, j < P.NL → σ.node j = j
  nall : ∀ j, j < x0.nnext → σ.node j < x1.nnext
  norder : ∀ i, PN x0 i → Full P i → ∀ j, j < i → σ.node j < σ.node i
  nfull : ∀ i, PN x0 i → Full P i → Full P (σ.node i)
  nodes : ∀ i nd, x0.nodes.get i = some nd → ∃ nd1, x1.nodes.get (σ.node i) = some nd1 ∧ NodeR P σ i nd nd1
  ninj : ∀ a b, PN x0 a → PN x0 b → σ.node a = σ.node b → a = b
  nlt : ∀ i, PN x0 i → i < x0.nnext
  nfresh : ∀ k, σ.node (x0.nnext + k) = x1.nnext + k
  nband : P.NL ≤ P.N0 ∧ P.N0 ≤ x0.nnext
  nle : x0.nnext ≤ x1.nnext
  tokens : x1.tokens = []
  items : ∀ k, PN x0 k → x1.items.get (σ.node k) = (x0.items.get k).map σ.nv
  itemsPresent : ∀ k, (x0.items.get k).isSome = true → PN x0 k
  pending : x1.pending = x0.pending.map σ.pend
  errh : x1.errh = x0.errh.map σ.arg
  files : x1.files = x0.files
  arch : x1.arch = x0.arch
  sizes : x1.deviceSizes = x0.deviceSizes
  wired : x1.wired = x0.wired
  cl : SSt (· < n0) x0

/-- The native part of the template shift. -/
structure NShift (P : LoadP) (n0 : Nat) (σ : Map) (x0 x1 : Host.Load.LSt) : Prop where
  host : x1.host = x0.host
  hostReg : ∀ h, h < 2 ^ 46 → σ.region (4 * h + 3) = 4 * h + 3
  cbr : ∀ a, σ.region (cbBase + a) = cbBase + σ.a a
  mlx : MShift P n0 σ x0.mlx x1.mlx

/-- The target can absorb one more template iteration's handles and nodes. -/
def NRoom (P : LoadP) (x0 : Host.Load.LSt) (z : Host.Load.LSt) : Prop :=
  z.mlx.next + (P.E - x0.mlx.next) < 2 ^ 46 ∧ z.mlx.nnext + (P.NE - x0.mlx.nnext) < 2 ^ 62

/-- The start state with its tokens cleared. -/
def clearTokens (x : Host.Load.LSt) : Host.Load.LSt := { x with mlx := { x.mlx with tokens := [] } }

section
variable {P : LoadP} {M σ : Map} {n0 n1 : Nat}

private theorem hmap_after {a b c : Nat} (h1 : HMap σ a b) (h2 : HMap M b c) : HMap (M.after σ) a c :=
  ⟨by rw [Map.after_big, h1.1, h2.1], by rw [Map.after_region, h1.2.1, h2.2.1],
    by rw [Map.after_region, h1.2.2, h2.2.2]⟩

theorem mshift_restart {x0 x1 z : NSt} (hs : MShift P n0 σ x0 x1) (hr : MRw P M n1 x1 z)
    (hroom : z.next + (P.E - x0.next) < 2 ^ 46 ∧ z.nnext + (P.NE - x0.nnext) < 2 ^ 62) :
    MRw P (M.after σ) n0 { x0 with tokens := [] } z := by
  have hH : ∀ h, (M.after σ).handle h = M.handle (σ.handle h) := fun h =>
    (Map.handle_after M σ (hs.nonneg h)).symm
  have hsh : ∀ h, PH x0 h → σ.handle h = (σ.big (Int.ofNat h)).toNat := fun _ _ => rfl
  have hx1 := hr.hnext
  have hnn := hr.nroom
  refine
    { lo := hr.lo
      bigFix := fun i hi => by rw [Map.after_big, hs.bigFix i hi, hr.bigFix i hi]
      bigFixHi := fun i h1 h2 => by rw [Map.after_big, hs.bigFixHi i h1 h2, hr.bigFixHi i h1 h2]
      present := fun h hp => by
        rw [hH]; exact hmap_after (hs.present h hp).1 (hr.present _ (hs.present h hp).2)
      hinj := fun a b ha hb he => by
        rw [hH, hH] at he
        exact hs.hinj a b ha hb (hr.hinj _ _ (hs.present a ha).2 (hs.present b hb).2 he)
      hlt := hs.hlt
      himg := fun h hp => by rw [hH]; exact hr.himg _ (hs.present h hp).2
      hband := fun h hp hl => by rw [hH]; exact hr.hband _ (hs.present h hp).2 (hs.hband h hp hl)
      hfreshR := fun k hk => by
        have h1 := hs.hfreshR k (by have := hx1.2; omega)
        have h2 := hr.hfreshR k hk
        exact ⟨by rw [Map.after_region, h1.1, h2.1], by rw [Map.after_region, h1.2, h2.2]⟩
      zero := fun i => by rw [Map.after_big, hr.zero, hs.zero]
      hnext := ⟨hs.hnext.1, Nat.le_trans hs.hnext.2 hx1.2⟩
      hroom := ⟨Nat.le_trans hs.hnext.2 hr.hroom.1, hroom.1⟩
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
      nid := fun j hj => by show M.node (σ.node j) = j; rw [hs.nid j hj, hr.nid j hj]
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
          refine ⟨by rw [e3, e1, Map.prim_after M σ _ (fun h _ => hs.nonneg h)], ?_⟩
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
      nroom := ⟨Nat.le_trans hs.nle hr.nroom.1, Nat.le_trans hs.nle hr.nroom.2.1, hroom.2⟩
      tokens := ⟨z.tokens, rfl⟩
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
      cl := ⟨hs.cl.1, hs.cl.2.1, (fun t ht => by cases ht), hs.cl.2.2.2.1, hs.cl.2.2.2.2⟩ }

/-- **Composition at the restart** (weak relation). -/
theorem loadRw_restart {x0 x1 z : Host.Load.LSt} (hs : NShift P n0 σ x0 x1) (hr : LoadRw P M n1 x1 z)
    (hroom : NRoom P x0 z) : LoadRw P (M.after σ) n0 (clearTokens x0) z where
  host := by rw [hr.host, hs.host]; rfl
  hostReg := fun h hh => by rw [Map.after_region, hs.hostReg h hh, hr.hostReg h hh]
  hostLt := fun h hh => hr.hostLt h (by rw [hs.host]; exact hh)
  cbr := fun a => by rw [Map.after_region, hs.cbr, hr.cbr]; rfl
  mlx := mshift_restart hs.mlx hr.mlx hroom
end

/-! ## Reseeding the tokens -/

/-- `M` with references `js` sent to `vs`. -/
def Map.setNums (M : Map) : List Nat → List NumV → Map
  | j :: js, v :: vs => (M.setNums js vs).setNum j v
  | _, _ => M

theorem setNums_agree (M : Map) : ∀ (js : List Nat) (vs : List NumV), NAgree (· ∉ js) M (M.setNums js vs)
  | [], _ => ⟨rfl, rfl, rfl, rfl, fun _ _ => rfl⟩
  | _ :: _, [] => ⟨rfl, rfl, rfl, rfl, fun _ _ => rfl⟩
  | j :: js, v :: vs => by
    have h1 := setNums_agree M js vs
    have h2 := NAgree.setNum (M.setNums js vs) j v
    refine ⟨h2.a.trans h1.a, h2.big.trans h1.big, h2.region.trans h1.region, h2.node.trans h1.node,
      fun i hi => ?_⟩
    simp only [List.mem_cons, not_or] at hi
    exact (h2.num i hi.1).trans (h1.num i hi.2)

theorem setNums_tokens (M : Map) : ∀ (js : List Nat) (vs : List NumV), js.length = vs.length → js.Nodup →
    (js.map NumV.ref).map (M.setNums js vs).nv = vs
  | [], [], _, _ => rfl
  | j :: js, v :: vs, hl, hnd => by
    simp only [List.length_cons, Nat.add_right_cancel_iff] at hl
    have hnd' := List.nodup_cons.mp hnd
    simp only [List.map_cons, Map.setNums]
    congr 1
    · exact Map.setNum_self _ _ _
    · refine Eq.trans (List.map_congr_left fun t ht => ?_) (setNums_tokens M js vs hl hnd'.2)
      obtain ⟨i, hi, rfl⟩ := List.mem_map.mp ht
      show (bif Nat.beq i j then v else (M.setNums js vs).num i) = (M.setNums js vs).num i
      cases h : Nat.beq i j
      · rfl
      · exact absurd (Nat.eq_of_beq_eq_true h ▸ hi) hnd'.1

/-- The start state with token references `js`. -/
def seedTokens (x : Host.Load.LSt) (js : List Nat) : Host.Load.LSt :=
  { x with mlx := { x.mlx with tokens := js.map NumV.ref } }

/-- **Reseed.** A source (whose tokens are replaced), related to a target whose next tokens are
`vs`, is related with fresh token references `js` (which occur nowhere in the
source) bound to `vs`. -/
theorem LoadRw.reseed {P : LoadP} {M : Map} {n n' : Nat} {x y : Host.Load.LSt} (hr : LoadRw P M n x y)
    {js : List Nat} {vs rest : List NumV} (hy : y.mlx.tokens = vs ++ rest)
    (hl : js.length = vs.length) (hnd : js.Nodup) (hcl : SSt (· ∉ js) x.mlx) (hn : n ≤ n')
    (hj : ∀ j ∈ js, j < n') : LoadRw P (M.setNums js vs) n' (seedTokens x js) y := by
  have ha : LoadRw P (M.setNums js vs) n x y :=
    ⟨hr.host, fun k hk => by rw [(setNums_agree M js vs).region]; exact hr.hostReg k hk, hr.hostLt,
      fun a => by rw [(setNums_agree M js vs).region, (setNums_agree M js vs).a]; exact hr.cbr a,
      hr.mlx.agree hcl (setNums_agree M js vs)⟩
  have hm := ha.mlx
  refine ⟨ha.host, ha.hostReg, ha.hostLt, ha.cbr, { hm with tokens := ?_, cl := ?_ }⟩
  · exact ⟨rest, by rw [hy]; show vs ++ rest = (js.map NumV.ref).map _ ++ rest; rw [setNums_tokens M js vs hl hnd]⟩
  · have hc := SSt.mono (fun i hi => Nat.lt_of_lt_of_le hi hn) hr.mlx.cl
    refine ⟨hc.1, hc.2.1, ?_, hc.2.2.2⟩
    intro t ht
    obtain ⟨j, hjm, rfl⟩ := List.mem_map.mp ht
    exact hj j hjm

end Host.Ts.Sim

namespace Host.Ts.Sim

theorem seedTokens_clear {x : Host.Load.LSt} {js : List Nat} (h : x.mlx.tokens = js.map NumV.ref) :
    seedTokens (clearTokens x) js = x := by
  obtain ⟨m, hst⟩ := x
  obtain ⟨nx, nodes, nn, arrs, objs, toks, files, pend, errh, arch, ds, wired, items⟩ := m
  simp only at h
  subst h
  rfl

end Host.Ts.Sim

/-! ## A further token reference, and independence of `P.rest` -/

namespace Host.Ts.Sim

/-- **A second token.** A fresh reference `n`, bound to the target's next readback `w`, is
appended to the source's tokens. -/
theorem LoadR.addToken {P : LoadP} {M : Map} {n : Nat} {x y : Host.Load.LSt} {w : NumV} {r : List NumV}
    (hr : LoadR { P with rest := w :: r } M n x y) :
    LoadR { P with rest := r } (M.setNum n w) (n + 1)
      { x with mlx := { x.mlx with tokens := x.mlx.tokens ++ [NumV.ref n] } } y := by
  have hc := hr.mlx.cl
  have ha := hr.agree hc (NAgree.ofExt (Map.setNum_ext M n w))
  have hm := ha.mlx
  have e0 : y.mlx.tokens = x.mlx.tokens.map (M.setNum n w).nv ++ (w :: r) := hm.tokensX
  have ht : y.mlx.tokens = (x.mlx.tokens ++ [NumV.ref n]).map (M.setNum n w).nv ++ r := by
    rw [e0, List.map_append, List.append_assoc]
    show _ = _ ++ ((M.setNum n w).num n :: r)
    rw [Map.setNum_self]
  have hlt : ∀ i, i < n → i < n + 1 := fun i hi => Nat.lt_succ_of_lt hi
  refine ⟨ha.host, ha.hostReg, ha.hostLt, ha.cbr, { hm with tokens := ⟨r, ht⟩, tokensX := ht, cl := ?_ }⟩
  refine ⟨fun i nd h => SNode.mono hlt (hc.1 i nd h), fun h o ho => SObj.mono hlt (hc.2.1 h o ho), ?_,
    fun k t h => SN.mono hlt (hc.2.2.2.1 k t h), fun a h => SA.mono hlt (hc.2.2.2.2 a h)⟩
  intro t h
  rcases List.mem_append.mp h with h | h
  · exact SN.mono hlt (hc.2.2.1 t h)
  · simp only [List.mem_singleton] at h
    subst h
    exact Nat.lt_succ_self n

theorem MShift.rest {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : NSt} (r : List NumV) :
    MShift { P with rest := r } n0 σ x0 x1 ↔ MShift P n0 σ x0 x1 :=
  ⟨fun h => { h with }, fun h => { h with }⟩

theorem NShift.rest {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : Host.Load.LSt} (r : List NumV) :
    NShift { P with rest := r } n0 σ x0 x1 ↔ NShift P n0 σ x0 x1 :=
  ⟨fun h => ⟨h.host, h.hostReg, h.cbr, (MShift.rest r).mp h.mlx⟩,
    fun h => ⟨h.host, h.hostReg, h.cbr, (MShift.rest r).mpr h.mlx⟩⟩

theorem MRw.rest {P : LoadP} {M : Map} {n : Nat} {x y : NSt} (r : List NumV) :
    MRw { P with rest := r } M n x y ↔ MRw P M n x y :=
  ⟨fun h => { h with }, fun h => { h with }⟩

theorem LoadRw.rest {P : LoadP} {M : Map} {n : Nat} {x y : Host.Load.LSt} (r : List NumV) :
    LoadRw { P with rest := r } M n x y ↔ LoadRw P M n x y :=
  ⟨fun h => ⟨h.host, h.hostReg, h.hostLt, h.cbr, (MRw.rest r).mp h.mlx⟩,
    fun h => ⟨h.host, h.hostReg, h.hostLt, h.cbr, (MRw.rest r).mpr h.mlx⟩⟩

end Host.Ts.Sim
