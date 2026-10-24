import host.sim.full.Restart
import host.sim.full.Raise

/-! # Restarts and compactions at a raise

The restart composition (`G.mshift_restart`) with the end relation at another band than the shift's:
the template shift at the start's band `P0`, the end relation at `P1` with the same handle and node
bounds, and every node `P0` corresponds fully corresponding at `P1` (`mshift_restartR`). The result is
at `P0`: the start's traces are below its band (the shift's `traced`), and the end's recorded traces
are not read. Two raises of the same `P` qualify (`Raised.restart`), and the full world's restart
relation at a raise (`FRrFD`) composes with the shift at the start's raise (`fsnFD_compose`). -/

namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

section

variable {P0 P1 : LoadP} {NB : Nat} {M σ : Map} {n0 n1 : Nat}

private theorem hmap_after' {a b c : Nat} (h1 : HMap σ a b) (h2 : HMap M b c) : HMap (M.after σ) a c :=
  ⟨by rw [Map.after_big, h1.1, h2.1], by rw [Map.after_region, h1.2.1, h2.2.1],
    by rw [Map.after_region, h1.2.2, h2.2.2]⟩

/-- **Composition at the restart across bands** (weak relation). -/
theorem mshift_restartR {x0 x1 z : NSt} (hs : MShift P0 n0 σ x0 x1) (hr : MRw P1 NB M n1 x1 z)
    (hlo : P1.lo = P0.lo) (hE : P1.E = P0.E) (hNE : P1.NE = P0.NE) (hF : ∀ j, Full P0 j → Full P1 j)
    (hNB : NB ≤ P0.NL)
    (hroom : z.next + (P0.E - x0.next) < 2 ^ 46 ∧ z.nnext + (P0.NE - x0.nnext) < 2 ^ 62) :
    MRw P0 NB (M.after σ) n0 { x0 with tokens := [] } z := by
  have hH : ∀ h, (M.after σ).handle h = M.handle (σ.handle h) := fun h =>
    (Map.handle_after M σ (hs.nonneg h)).symm
  have hx1 := hr.hnext
  have hnn := hr.nroom
  refine
    { lo := hlo ▸ hr.lo
      bigFix := fun i hi => by rw [Map.after_big, hs.bigFix i hi, hr.bigFix i (by rw [hlo]; exact hi)]
      bigFixHi := fun i h1 h2 => by
        rw [Map.after_big, hs.bigFixHi i h1 h2, hr.bigFixHi i (by rw [hE]; exact h1) h2]
      present := fun h hp => by
        rw [hH]; exact hmap_after' (hs.present h hp).1 (hr.present _ (hs.present h hp).2)
      hinj := fun a b ha hb he => by
        rw [hH, hH] at he
        exact hs.hinj a b ha hb (hr.hinj _ _ (hs.present a ha).2 (hs.present b hb).2 he)
      hlt := hs.hlt
      himg := fun h hp => by rw [hH]; exact hr.himg _ (hs.present h hp).2
      hband := fun h hp hl => by
        rw [hH]; have := hr.hband _ (hs.present h hp).2 (by rw [hlo]; exact hs.hband h hp hl); rwa [hlo] at this
      hfreshR := fun k hk => by
        have h1 := hs.hfreshR k (by have := hx1.2; omega)
        have h2 := hr.hfreshR k hk
        exact ⟨by rw [Map.after_region, h1.1, h2.1], by rw [Map.after_region, h1.2, h2.2]⟩
      zero := fun i => by rw [Map.after_big, hr.zero, hs.zero]
      hnext := ⟨hs.hnext.1, Nat.le_trans hs.hnext.2 hx1.2⟩
      hroom := ⟨Nat.le_trans hs.hnext.2 (hE ▸ hr.hroom.1), hroom.1⟩
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
        show M.node (σ.node j) = j; rw [hs.nid j (Nat.lt_of_lt_of_le hj hNB), hr.nid j hj]
      nbl := hNB
      nall := fun j hj => hr.nall _ (hs.nall j hj)
      norder := fun i hi hf j hj => by
        obtain ⟨nd1, h1, -⟩ := hs.nodes i _ (Option.get_mem hi)
        exact hr.norder _ (by show (x1.nodes.get (σ.node i)).isSome = true; rw [h1]; rfl)
          (hF _ (hs.nfull i hi hf)) _ (hs.norder i hi hf j hj)
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
          obtain ⟨e3, e4⟩ := hf2 (hF _ (hs.nfull i hp hf))
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
      nroom := ⟨Nat.le_trans hs.nle hr.nroom.1, Nat.le_trans hs.nle (hNE ▸ hr.nroom.2.1), hroom.2⟩
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

/-- **Composition at the restart across bands** (weak load-world relation). -/
theorem loadRw_restartR {x0 x1 z : Host.Load.LSt} (hs : NShift P0 n0 σ x0 x1) (hr : LoadRw P1 NB M n1 x1 z)
    (hlo : P1.lo = P0.lo) (hE : P1.E = P0.E) (hNE : P1.NE = P0.NE) (hF : ∀ j, Full P0 j → Full P1 j)
    (hNB : NB ≤ P0.NL) (hroom : NRoom P0 x0 z) : LoadRw P0 NB (M.after σ) n0 (clearTokens x0) z where
  host := by rw [hr.host, hs.host]; rfl
  hostReg := fun h hh => by rw [Map.after_region, hs.hostReg h hh, hr.hostReg h hh]
  hostLt := fun h hh => hr.hostLt h (by rw [hs.host]; exact hh)
  cbr := fun a => by rw [Map.after_region, hs.cbr, hr.cbr]; rfl
  mlx := mshift_restartR hs.mlx hr.mlx hlo hE hNE hF hNB hroom

end

end Host.Ts.Sim.G

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers

/-- Two raises of `P` share its bounds, and every node fully corresponding at one does at the other. -/
theorem Raised.restart {P P0 P1 : LoadP} (h0 : Raised P P0) (h1 : Raised P P1) :
    P1.lo = P0.lo ∧ P1.E = P0.E ∧ P1.NE = P0.NE ∧ ∀ j, Full P0 j → Full P1 j := by
  have hb : ∀ {Q : LoadP}, Raised P Q → Q.lo = P.lo ∧ Q.E = P.E ∧ Q.NE = P.NE := by
    intro Q h; rcases h with rfl | ⟨k, -, -, rfl⟩ <;> exact ⟨rfl, rfl, rfl⟩
  obtain ⟨a0, b0, c0⟩ := hb h0
  obtain ⟨a1, b1, c1⟩ := hb h1
  refine ⟨a1.trans a0.symm, b1.trans b0.symm, c1.trans c0.symm, fun j hj => ?_⟩
  rcases h1 with e1 | ⟨k1, -, -, e1⟩
  · rcases h0 with e0 | ⟨k0, hb0, -, -⟩
    · rw [e1, ← e0]; exact hj
    · rw [e1]; show j < P.NL ∨ P.N0 ≤ j; omega
  · rw [e1]; show j < k1 ∨ k1 ≤ j; omega

/-- **The restart relation at a raise**: `FRrF` at a raise of `P`. -/
def FRrFD (P : LoadP) (NB : Nat) (x0 : FF.S) : Map → Nat → FF.S → FF.S → Prop :=
  fun M n x z => ∃ P1, Raised P P1 ∧ FRrF P1 NB x0 M n x z

theorem FRrF.toD {P : LoadP} {NB : Nat} {x0 : FF.S} {M : Map} {n : Nat} {x z : FF.S} (h : FRrF P NB x0 M n x z) :
    FRrFD P NB x0 M n x z := ⟨P, .inl rfl, h⟩

/-- **The restart's composition at a raise**: the shift at the start's raise `P0` and the restart
relation at any raise give the restart relation at `P0`. -/
theorem fsnFD_compose {P P0 : LoadP} {NB n0 n1 : Nat} {x0 : FF.S} {σ : Map} (hP0 : Raised P P0)
    (hNB : NB ≤ P0.NL) :
    ∀ M x y z, FSnF P0 n0 x0 σ x y → FRrFD P NB x0 M n1 y z → FRrFD P NB x0 (M.after σ) n0 x z := by
  rintro M x y z ⟨hx, hs⟩ ⟨P1, hP1, ⟨hr, hroom⟩, hb, hl, hk, hp⟩
  obtain ⟨hlo, hE, hNE, hF⟩ := hP0.restart hP1
  have hroom0 : NRoom P0 (toLoad x0) (toLoad z) := by
    unfold NRoom at hroom ⊢; rw [← hE, ← hNE]; exact hroom
  subst hx
  have hm := hs.load.mlx
  refine ⟨P0, hP0, ⟨?_, hroom0⟩, ⟨by rw [hb.1, hs.bridge], by rw [← hs.bridge]; exact hb.2⟩, ?_, ?_,
    hp.after hs.pend hm.pending hm.nonneg hr.mlx.hnext.2⟩
  · rw [clearTokens_nil hs.load.mlx.tokens] at hr
    exact G.loadRw_restartR hs.load hr hlo hE hNE hF hNB hroom0
  · intro fx0 e0
    obtain ⟨fx1, e1, hf⟩ := hs.live fx0 e0
    obtain ⟨fz, ez, hfz⟩ := hl fx1 e1
    exact ⟨fz, ez, hfz.restart hm hf⟩
  · intro k0 e0
    obtain ⟨k1, e1, hk1⟩ := hs.kern k0 e0
    obtain ⟨kz, ez, hkz⟩ := hk k1 e1
    exact ⟨kz, ez, hkz.restart hm hk1⟩

end Host.Ts.Sim.Full
