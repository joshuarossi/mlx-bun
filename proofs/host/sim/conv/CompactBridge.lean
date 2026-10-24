import host.sim.conv.CompactFull
import host.sim.full.BridgeRaise
import host.sim.template.NShiftOf
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Layers
open Host.Ts.Sim.Template (PTrie.keysA PTrie.mem_keysA)

/-! # Compactions and restarts with the Neural Engine bridge

Once the bridge records node ids, a shift renaming nodes (a compaction's `κ`, a restart's `σ`) no
longer keeps it equal: the shift's bridge part is the bridge relation itself at the shift's map,
`BridgeX σ x0 x1` (inactive and equal, or active and renamed, `BRel σ`, the start's nodes present).
It composes with a relation's (`bridgeX_after`: `BRel` composes along `M.after σ`, the shift sending
the start's nodes below its end's counter), and only reads the map's node names (`BridgeX.names`), so
the fresh handles' reassignment keeps it.

`FullShiftQX` is `FullShiftQ` with that bridge part, `FRrFB BridgeX` the restart relation with the
full world's bridge relation, and `full_compactQX` / `full_compactQXD` the compactions at `FullRX` and
at its raises; `FullShiftX` and `fsnFX_compose` the restarts' shift. With the start's bridge inactive
the shift is today's (`FullShiftQ.toX`, `FullShiftQX.toQ`, `FullShift.toX`), and so is the relation
(`FullR.toX`, `FullRX.toR`). -/

/-! ## The bridge part -/

/-- **`BRel` composes** along the shift's and the relation's maps, the shift sending the start's
nodes below its end's counter. -/
theorem _root_.Host.Ts.Sim.Full.BRel.comp {σ M : Map} {nx ny nz : Nat} {b b1 b2 : BSt} (hs : BRel σ nx ny b b1)
    (hr : BRel M ny nz b1 b2) (hn : ∀ n, n < nx → σ.node n < ny) : BRel (M.after σ) nx nz b b2 where
  surfaces := hr.surfaces.trans hs.surfaces
  programs := hr.programs.trans hs.programs
  handles := hr.handles.trans hs.handles
  active := hr.active.trans hs.active
  aliases n h := (hr.aliases _ (hn n h)).trans (hs.aliases n h)
  aliasX := hs.aliasX
  aliasY := hr.aliasY
  touch n h := (hr.touch _ (hn n h)).trans (hs.touch n h)
  touchX := hs.touchX
  touchY := hr.touchY
  unscheduled := by rw [hr.unscheduled, hs.unscheduled, List.map_map]; rfl
  running := by rw [hr.running, hs.running, List.map_map]; rfl
  queued := hs.queued
  log := by
    rw [hr.log, hs.log, List.map_map]
    congr 1
    funext e
    cases e <;> simp only [Function.comp, Map.effect, List.map_map]
    rfl

/-- The bridge relation reads only the map's node names. -/
theorem _root_.Host.Ts.Sim.Full.BridgeX.names {M M' : Map} {x y : FF.S} (h : BridgeX M x y)
    (hn : M'.node = M.node) : BridgeX M' x y := by
  rcases h with h | ⟨ha, h⟩
  · exact .inl h
  · exact .inr ⟨ha, h.rel.names hn, h.dense⟩

/-- **The bridge relation composes with a shift's**: the shift's bridge part `BridgeX σ x y` and the
relation's `BridgeX M y z` give `BridgeX (M.after σ) x z`. -/
theorem bridgeX_after {σ M : Map} {x y z : FF.S} (hs : BridgeX σ x y) (hr : BridgeX M y z)
    (hn : ∀ n, n < (mlxOf x).nnext → σ.node n < (mlxOf y).nnext) : BridgeX (M.after σ) x z := by
  rcases hs with ⟨he, hxa⟩ | ⟨hxa, hA⟩
  · rcases hr with ⟨he', -⟩ | ⟨hya, -⟩
    · exact .inl ⟨he'.trans he, hxa⟩
    · rw [he, hxa] at hya; cases hya
  · have hya : (bridgeOf y).active = true := hA.rel.active.trans hxa
    rcases hr with ⟨-, hyi⟩ | ⟨-, hB⟩
    · rw [hya] at hyi; cases hyi
    · exact .inr ⟨hxa, hA.rel.comp hB.rel hn, hA.dense⟩

/-- The bridge relation is a restart's (`full_restart_dropB`): it reads only node names, and the
shift's bridge part `BridgeX` composes with it. -/
theorem bridgeX_names : BridgeNames BridgeX := fun _ _ _ _ h hn => h.names hn

theorem shiftComp_X : ShiftComp BridgeX BridgeX := fun _ _ _ _ _ hs hn hb => bridgeX_after hs hb hn

/-! ## The shifts -/

/-- **The compaction's native shift with the bridge renamed**: `FullShiftQB` at the bridge part
`BridgeX σ`. -/
abbrev FullShiftQX : LoadP → Nat → Map → FF.S → FF.S → Prop := FullShiftQB BridgeX

/-- With the start's bridge inactive, today's shift is one. -/
theorem FullShiftQ.toX {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : FF.S} (h : FullShiftQ P n0 σ x0 x1)
    (ha : (bridgeOf x0).active = false) : FullShiftQX P n0 σ x0 x1 :=
  ⟨h.load, h.tokens, h.tokSupp, .inl ⟨h.bridge, ha⟩, h.live, h.kern, h.pend⟩

/-- With the start's bridge inactive, the shift is today's. -/
theorem FullShiftQX.toQ {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : FF.S} (h : FullShiftQX P n0 σ x0 x1)
    (ha : (bridgeOf x0).active = false) : FullShiftQ P n0 σ x0 x1 where
  load := h.load
  tokens := h.tokens
  tokSupp := h.tokSupp
  bridge := by
    rcases h.bridge with ⟨he, -⟩ | ⟨ha', -⟩
    · exact he
    · rw [ha] at ha'; cases ha'
  live := h.live
  kern := h.kern
  pend := h.pend

/-- The compaction's native shift from the canonical start `x0`. -/
def FSnQX (P : LoadP) (n0 : Nat) (x0 : FF.S) : Map → FF.S → FF.S → Prop :=
  fun σ x y => x = x0 ∧ FullShiftQX P n0 σ x y

/-- **The restart's native shift with the bridge renamed**: `FullShift` with the bridge part
`BridgeX σ`. -/
abbrev FullShiftX : LoadP → Nat → Map → FF.S → FF.S → Prop := FullShiftB BridgeX

/-- With the start's bridge inactive, the restarts' shift is one. -/
theorem _root_.Host.Ts.Sim.Full.FullShift.toX {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : FF.S}
    (h : FullShift P n0 σ x0 x1) (ha : (bridgeOf x0).active = false) : FullShiftX P n0 σ x0 x1 :=
  ⟨h.load, .inl ⟨h.bridge, ha⟩, h.live, h.kern, h.pend⟩

/-- The restart's native shift from the template start `x0`. -/
def FSnFX (P : LoadP) (n0 : Nat) (x0 : FF.S) : Map → FF.S → FF.S → Prop :=
  fun σ x y => x = x0 ∧ FullShiftX P n0 σ x y

/-! ## The restart relation -/

/-- The restart relation with the bridge at a raise. -/
def FRrFXD (P : LoadP) (NB : Nat) (x0 : FF.S) : Map → Nat → FF.S → FF.S → Prop :=
  fun M n x z => ∃ P1, Raised P P1 ∧ FRrFB BridgeX P1 NB x0 M n x z

/-! ## Composition -/

/-- **The compaction's composition with the bridge renamed.** -/
theorem fsnQX_compose {P : LoadP} {NB n0 n1 : Nat} {x0 : FF.S} {σ : Map} :
    ∀ M x y z, FSnQX P n0 x0 σ x y → FRrFB BridgeX P NB x0 M n1 y z → FRrFB BridgeX P NB x0 (M.after σ) n0 x z :=
  fsnQB_compose shiftComp_X

/-- `fsnQX_compose` at a raise: the shift at the start's raise `P0`, the restart relation at any raise. -/
theorem fsnQXD_compose {P P0 : LoadP} {NB n0 n1 : Nat} {x0 : FF.S} {σ : Map} (hP0 : Raised P P0)
    (hNB : NB ≤ P0.NL) :
    ∀ M x y z, FSnQX P0 n0 x0 σ x y → FRrFXD P NB x0 M n1 y z → FRrFXD P NB x0 (M.after σ) n0 x z :=
  fsnQBD_compose shiftComp_X hP0 hNB

/-- **The restart's composition with the bridge renamed.** -/
theorem fsnFX_compose {P : LoadP} {NB n0 n1 : Nat} {x0 : FF.S} {σ : Map} :
    ∀ M x y z, FSnFX P n0 x0 σ x y → FRrFB BridgeX P NB x0 M n1 y z → FRrFB BridgeX P NB x0 (M.after σ) n0 x z :=
  fsnFB_compose shiftComp_X

/-- `fsnFX_compose` at a raise. -/
theorem fsnFXD_compose {P P0 : LoadP} {NB n0 n1 : Nat} {x0 : FF.S} {σ : Map} (hP0 : Raised P P0)
    (hNB : NB ≤ P0.NL) :
    ∀ M x y z, FSnFX P0 n0 x0 σ x y → FRrFXD P NB x0 M n1 y z → FRrFXD P NB x0 (M.after σ) n0 x z := by
  rintro M x y z ⟨hx, hs⟩ ⟨P1, hP1, ⟨hr, hroom⟩, hb, hl, hk, hp⟩
  obtain ⟨hlo, hE, hNE, hF⟩ := hP0.restart hP1
  have hroom0 : NRoom P0 (toLoad x0) (toLoad z) := by
    unfold NRoom at hroom ⊢; rw [← hE, ← hNE]; exact hroom
  subst x0
  have hm := hs.load.mlx
  refine ⟨P0, hP0, ⟨?_, hroom0⟩, bridgeX_after hs.bridge hb hm.nall, ?_, ?_,
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

/-! ## Compaction -/

/-- **Compaction with the bridge renamed**: `full_compactQ` at `FullRX`, the shift's bridge part the
bridge relation at the compaction map. -/
theorem full_compactQX (NB : Nat) {P : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx}
    {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv} {θ : Nat → SymE}
    (h1 : RelF FF (FullRX { P with rest := r } NB) W M1 ν K1 s1 S1 t1 C1)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftQX P S0.tab.length σ x y) κ θ (kpOf K1 W) W K1
      s0 S0 s1 S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound)
    (hroomN : NRoom P (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FullRX { P with rest := r } NB) W ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
      (Shift.valuation θ ν)
      ⟨Shift.framedNext M1 K1 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t1 C1 :=
  full_compactQB bridgeX_names shiftComp_X NB h1 hshift hbig hfree hband hg hroom hroomN

/-- **Compaction with the bridge renamed at a raise**: `full_compactQD` at `FullRX`'s raises. -/
theorem full_compactQXD (NB : Nat) {P P0 : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx}
    {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv} {θ : Nat → SymE}
    (hP0 : Raised P P0) (hNB : NB ≤ P0.NL)
    (h1 : RelF FF (FullRXD { P with rest := r } NB) W M1 ν K1 s1 S1 t1 C1)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftQX P0 S0.tab.length σ x y) κ θ (kpOf K1 W) W K1
      s0 S0 s1 S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound)
    (hroomN : NRoom P (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FullRXD { P with rest := r } NB) W ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
      (Shift.valuation θ ν)
      ⟨Shift.framedNext M1 K1 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t1 C1 :=
  full_compactQBD bridgeX_names shiftComp_X NB hP0 hNB h1 hshift hbig hfree hband hg hroom hroomN

/-! ## The bridge part from checks

The generator's checks of an active bridge shift (`brel_of_checks`): the surfaces, programs, handles
and activity equal; each recorded node table's keys below the start's counter, the end's keys below its
counter and each the image of a start key, the end's entries at the images the start's (an image check
over the start's keys, no decision procedure on the entries); the queues and the log the images; the
start's nodes below its counter present (`bridgeA_of_checks`), so the node map is injective there
(`ninj_dense`). -/

/-- A node table renamed injectively below `nx`, from checks over its keys. -/
theorem renamed_get {α : Type} {f : Nat → Nat} {nx ny : Nat} {t t' : PTrie α}
    (hinj : ∀ i j, i < nx → j < nx → f i = f j → i = j)
    (hK : (PTrie.keysA t).all (fun n => Nat.blt n nx) = true)
    (hK' : (PTrie.keysA t').all (fun m => Nat.blt m ny && (PTrie.keysA t).any (fun n => Nat.beq (f n) m)) = true)
    (hV : (PTrie.keysA t).map (fun n => t'.get (f n)) = (PTrie.keysA t).map (fun n => t.get n)) :
    (∀ n, n < nx → t'.get (f n) = t.get n) ∧ (∀ n, (t.get n).isSome = true → n < nx) ∧
      (∀ m, (t'.get m).isSome = true → m < ny) := by
  have hv : ∀ n ∈ PTrie.keysA t, t'.get (f n) = t.get n := fun n hn => List.map_inj_left.mp hV n hn
  have hkl : ∀ n ∈ PTrie.keysA t, n < nx := fun n hn => Nat.blt_eq.mp (List.all_eq_true.mp hK n hn)
  have hk : ∀ n, (t.get n).isSome = true → n < nx := fun n h => by
    obtain ⟨v, e⟩ := Option.isSome_iff_exists.mp h
    exact hkl n (PTrie.mem_keysA t n v e)
  have hk' : ∀ m, (t'.get m).isSome = true → m < ny ∧ ∃ n ∈ PTrie.keysA t, f n = m := fun m h => by
    obtain ⟨v, e⟩ := Option.isSome_iff_exists.mp h
    have := List.all_eq_true.mp hK' m (PTrie.mem_keysA t' m v e)
    simp only [Bool.and_eq_true, List.any_eq_true] at this
    obtain ⟨h1, n, hn, h2⟩ := this
    exact ⟨Nat.blt_eq.mp h1, n, hn, Nat.eq_of_beq_eq_true h2⟩
  refine ⟨fun n hn => ?_, hk, fun m h => (hk' m h).1⟩
  cases e : t.get n with
  | some v => exact (hv n (PTrie.mem_keysA t n v e)).trans e
  | none =>
    cases e' : t'.get (f n) with
    | none => rfl
    | some w =>
      obtain ⟨-, n', hn', hfn'⟩ := hk' (f n) (by rw [e']; rfl)
      have hnn : n' = n := hinj n' n (hkl n' hn') hn hfn'
      subst hnn
      have := hv n' hn'
      rw [e', e] at this
      cases this

/-- **The bridge states under a map from the generator's checks.** -/
theorem brel_of_checks {σ : Map} {nx ny : Nat} {b b' : BSt}
    (hsurf : b'.surfaces = b.surfaces) (hprog : b'.programs = b.programs) (hhand : b'.handles = b.handles)
    (hact : b'.active = b.active) (hinj : ∀ i j, i < nx → j < nx → σ.node i = σ.node j → i = j)
    (haK : (PTrie.keysA b.aliases).all (fun n => Nat.blt n nx) = true)
    (haK' : (PTrie.keysA b'.aliases).all
      (fun m => Nat.blt m ny && (PTrie.keysA b.aliases).any (fun n => Nat.beq (σ.node n) m)) = true)
    (haV : (PTrie.keysA b.aliases).map (fun n => b'.aliases.get (σ.node n)) =
      (PTrie.keysA b.aliases).map (fun n => b.aliases.get n))
    (htK : (PTrie.keysA b.touch).all (fun n => Nat.blt n nx) = true)
    (htK' : (PTrie.keysA b'.touch).all
      (fun m => Nat.blt m ny && (PTrie.keysA b.touch).any (fun n => Nat.beq (σ.node n) m)) = true)
    (htV : (PTrie.keysA b.touch).map (fun n => b'.touch.get (σ.node n)) =
      (PTrie.keysA b.touch).map (fun n => b.touch.get n))
    (hun : b'.unscheduled = b.unscheduled.map σ.node) (hrun : b'.running = b.running.map σ.node)
    (hq : (b.unscheduled ++ b.running).all (fun n => Nat.blt n nx) = true)
    (hlog : b'.log = b.log.map σ.effect) : BRel σ nx ny b b' :=
  have ha := renamed_get hinj haK haK' haV
  have ht := renamed_get hinj htK htK' htV
  { surfaces := hsurf
    programs := hprog
    handles := hhand
    active := hact
    aliases := ha.1
    aliasX := ha.2.1
    aliasY := ha.2.2
    touch := ht.1
    touchX := ht.2.1
    touchY := ht.2.2
    unscheduled := hun
    running := hrun
    queued := fun n hn => Nat.blt_eq.mp (List.all_eq_true.mp hq n hn)
    log := hlog }

/-- A shift's node map is injective on a start whose nodes below its counter are all present. -/
theorem ninj_dense {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : NSt} (hm : MShift P n0 σ x0 x1)
    (hd : ∀ i, i < x0.nnext → PN x0 i) : ∀ i j, i < x0.nnext → j < x0.nnext → σ.node i = σ.node j → i = j :=
  fun i j hi hj he => hm.ninj i j (hd i hi) (hd j hj) he

/-- The start's nodes below its counter present, by a check. -/
theorem dense_of_check {x : NSt} (h : (List.range x.nnext).all (fun i => (x.nodes.get i).isSome) = true) :
    ∀ i, i < x.nnext → PN x i :=
  fun i hi => List.all_eq_true.mp h i (List.mem_range.mpr hi)

/-- **An active bridge shift from the checks**: the start's bridge active, `BRel` at the start's and
the end's node counters, the start dense. -/
theorem bridgeX_of_active {σ : Map} {x y : FF.S} (ha : (bridgeOf x).active = true)
    (hrel : BRel σ (mlxOf x).nnext (mlxOf y).nnext (bridgeOf x) (bridgeOf y))
    (hd : ∀ i, i < (mlxOf x).nnext → PN (mlxOf x) i) : BridgeX σ x y :=
  .inr ⟨ha, hrel, hd⟩

/-- An inactive bridge shift from the checks: the start's bridge inactive, the end's equal. -/
theorem bridgeX_of_inactive {σ : Map} {x y : FF.S} (ha : (bridgeOf x).active = false)
    (he : bridgeOf y = bridgeOf x) : BridgeX σ x y :=
  .inl ⟨he, ha⟩

end Host.Ts.Sim.Conv
