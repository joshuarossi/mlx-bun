import host.sim.full.Step
import host.sim.RestartDrop
import host.sim.LoadIter
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers

/-! # Restarts in the full world

The restart of `load_restart_drop` (`host.sim.RestartDrop`) for `FullR`: after a run from a related
template start to a related end, the target is related to the template start again under the restart
map `((M1.setNum _ v).after σ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next`
(`full_restart_drop`). It is the generic restart (`restartDrop`, `RelF.rebig`) at the full world's
restart relation `FRrF` and native shift `FSnF`; the mlx part is the general relation's restart
pieces (`G.loadRw_restart`, `G.LoadRw.rebig`), and the other parts are renamed:

* the template's shift (`FullShift`) holds the load-world shift `NShift` on `toLoad`, keeps the
  inactive bridge, and records at the shifted handles what the start records (`LiveShift`,
  `KernShift`; the template's layers accepted along its run, and its recorded handles are objects);
* the observer relations compose with the shift (`FreedR.restart`, `KRecR.restart`) and only read
  handle images of objects, which the reassignment of fresh handle images keeps (`FreedR.rebig`,
  `KRecR.rebig`). -/

/-! ## The template's shift -/

/-- The liveness layer's part of a template shift. -/
structure FreedShift (σ : Map) (x0 x1 : NSt) (fx0 fx1 : PTrie Unit) : Prop where
  obj : ∀ h, fx0.get h = some () → (x0.objs.get h).isSome = true
  img : ∀ h, (x0.objs.get h).isSome = true → fx1.get (σ.handle h) = fx0.get h

/-- Where the start's liveness layer accepts, the end's accepts, related. -/
def LiveShift (σ : Map) (x0 x1 : NSt) (e0 e1 : Option (PTrie Unit)) : Prop :=
  ∀ fx0, e0 = some fx0 → ∃ fx1, e1 = some fx1 ∧ FreedShift σ x0 x1 fx0 fx1

/-- The kernel-recording layer's part of a template shift (the start's numbers closed below `n0`). -/
structure KRecShift (σ : Map) (n0 : Nat) (x0 x1 : NSt) (k0 k1 : KRec) : Prop where
  flagsObj : ∀ h, (k0.flags.get h).isSome = true → (x0.objs.get h).isSome = true
  targsObj : ∀ h, (k0.targs.get h).isSome = true → (x0.objs.get h).isSome = true
  flags : ∀ h, (x0.objs.get h).isSome = true → k1.flags.get (σ.handle h) = k0.flags.get h
  targs : ∀ h, (x0.objs.get h).isSome = true → k1.targs.get (σ.handle h) = (k0.targs.get h).map (List.map (targ σ))
  cl : ∀ h l, k0.targs.get h = some l → STargs (· < n0) l

/-- Where the start's kernel-recording layer accepts, the end's accepts, related. -/
def KernShift (σ : Map) (n0 : Nat) (x0 x1 : NSt) (e0 e1 : Option KRec) : Prop :=
  ∀ k0, e0 = some k0 → ∃ k1, e1 = some k1 ∧ KRecShift σ n0 x0 x1 k0 k1

/-- **The full world's native shift** of a template run with the bridge inactive. -/
structure FullShift (P : LoadP) (n0 : Nat) (σ : Map) (x0 x1 : FF.S) : Prop where
  load : NShift P n0 σ (toLoad x0) (toLoad x1)
  bridge : bridgeOf x1 = bridgeOf x0
  live : LiveShift σ (mlxOf x0) (mlxOf x1) (freedOf x0) (freedOf x1)
  kern : KernShift σ n0 (mlxOf x0) (mlxOf x1) (krecOf x0) (krecOf x1)
  pend : G.PendReg σ (mlxOf x0) (mlxOf x1)

theorem FullShift.withRest {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : FF.S} (h : FullShift P n0 σ x0 x1)
    (r : List NumV) : FullShift { P with rest := r } n0 σ x0 x1 :=
  { h with load := h.load.withRest r }

/-! ## Composition with the shift -/

section
variable {P : LoadP} {n0 : Nat} {M σ : Map} {x0 x1 z : NSt}

theorem obj_shift (hs : MShift P n0 σ x0 x1) {h : Nat} (hh : (x0.objs.get h).isSome = true) :
    (x1.objs.get (σ.handle h)).isSome = true := by
  rw [hs.objs h (.inr hh)]
  cases e : x0.objs.get h with
  | none => rw [e] at hh; cases hh
  | some _ => rfl

theorem FreedR.restart {fx0 fx1 fz : PTrie Unit} (hm : MShift P n0 σ x0 x1) (hs : FreedShift σ x0 x1 fx0 fx1)
    (hr : FreedR M x1 z fx1 fz) : FreedR (M.after σ) x0 z fx0 fz where
  obj := hs.obj
  img h hh := by
    rw [← Map.handle_after M σ (hm.nonneg h), hr.img _ (obj_shift hm hh), hs.img h hh]
  lt := hr.lt

theorem targ_after (M σ : Map) (t : List Char × TArg) : targ M (targ σ t) = targ (M.after σ) t := by
  obtain ⟨n, t⟩ := t
  cases t with
  | int v => show (n, TArg.int (M.nv (σ.nv v))) = (n, TArg.int ((M.after σ).nv v)); rw [Map.nv_after]
  | dtype d => rfl

theorem KRecR.restart {n1 : Nat} {k0 k1 kz : KRec} (hm : MShift P n0 σ x0 x1) (hs : KRecShift σ n0 x0 x1 k0 k1)
    (hr : KRecR M n1 x1 z k1 kz) : KRecR (M.after σ) n0 x0 z k0 kz where
  flagsObj := hs.flagsObj
  targsObj := hs.targsObj
  flags h hh := by
    rw [← Map.handle_after M σ (hm.nonneg h), hr.flags _ (obj_shift hm hh), hs.flags h hh]
  targs h hh := by
    rw [← Map.handle_after M σ (hm.nonneg h), hr.targs _ (obj_shift hm hh), hs.targs h hh, Option.map_map]
    congr 1
    funext l
    simp only [Function.comp, List.map_map]
    exact List.map_congr_left fun t _ => targ_after M σ t
  flagsLt := hr.flagsLt
  targsLt := hr.targsLt
  cl := hs.cl

end

/-! ## Reassigning fresh handle images -/

section
variable {M M' : Map} {x z : NSt}

theorem FreedR.rebig {fx fz : PTrie Unit} (hr : FreedR M x z fx fz)
    (hh : ∀ h, (x.objs.get h).isSome = true → M'.handle h = M.handle h) : FreedR M' x z fx fz :=
  ⟨hr.obj, fun h hx => by rw [hh h hx]; exact hr.img h hx, hr.lt⟩

theorem LiveR.rebig {ex ez : Option (PTrie Unit)} (hr : LiveR M x z ex ez)
    (hh : ∀ h, (x.objs.get h).isSome = true → M'.handle h = M.handle h) : LiveR M' x z ex ez := fun fx e => by
  obtain ⟨fz, e', hf⟩ := hr fx e
  exact ⟨fz, e', hf.rebig hh⟩

theorem KRecR.rebig {n : Nat} {kx kz : KRec} (hr : KRecR M n x z kx kz)
    (hh : ∀ h, (x.objs.get h).isSome = true → M'.handle h = M.handle h) (hn : M'.num = M.num) :
    KRecR M' n x z kx kz := by
  have ht : targ M' = targ M := by
    funext t; obtain ⟨n, t⟩ := t
    cases t with
    | int v => cases v with
      | lit _ => rfl
      | ref i => show (n, TArg.int (M'.num i)) = (n, TArg.int (M.num i)); rw [hn]
    | dtype _ => rfl
  exact { hr with
    flags := fun h hx => by rw [hh h hx]; exact hr.flags h hx
    targs := fun h hx => by rw [hh h hx, ht]; exact hr.targs h hx }

theorem KernR.rebig {n : Nat} {ex ez : Option KRec} (hr : KernR M n x z ex ez)
    (hh : ∀ h, (x.objs.get h).isSome = true → M'.handle h = M.handle h) (hn : M'.num = M.num) :
    KernR M' n x z ex ez := fun kx e => by
  obtain ⟨kz, e', hk⟩ := hr kx e
  exact ⟨kz, e', hk.rebig hh hn⟩

theorem rebig_handle (M : Map) (a b d : Nat) {h : Nat} (hl : h < a) : (M.rebig a b d).handle h = M.handle h := by
  show (if (a : Int) ≤ Int.ofNat h ∧ Int.ofNat h < b then Int.ofNat h - a + d else M.big (Int.ofNat h)).toNat = _
  have hn : ¬ ((a : Int) ≤ Int.ofNat h ∧ Int.ofNat h < b) := by simp only [Int.ofNat_eq_natCast]; omega
  rw [ite_eq_right_of_eq_false _ _ (eq_false hn)]
  rfl

end

/-! ## The restart relation -/

/-! ## Pending traces' result regions across a restart -/

/-- Through the shift `σ`: the map after it renames the start's pending traces' regions with its
handles, and the fresh regions continue in order. -/
theorem _root_.Host.Ts.Sim.G.PendReg.after {M σ : Map} {x0 x1 z : NSt} (hp : G.PendReg M x1 z)
    (hs : G.PendReg σ x0 x1) (hpend : x1.pending = x0.pending.map σ.pend)
    (hnn : ∀ h : Nat, 0 ≤ σ.big (Int.ofNat h)) (hle : x1.next ≤ z.next) : G.PendReg (M.after σ) x0 z where
  reg p hp0 := by
    obtain ⟨l1, l2, l3⟩ := hs.reg p hp0
    have hm : σ.pend p ∈ x1.pending := by rw [hpend]; exact List.mem_map_of_mem hp0
    obtain ⟨-, m2, m3⟩ := hp.reg _ hm
    refine ⟨l1, ?_, ?_⟩
    · show M.region (σ.region (4 * p.id + 2)) = 4 * (M.after σ).handle p.id + 2
      rw [l2, ← Map.handle_after M σ (hnn p.id)]
      exact m2
    · rw [← Map.handle_after M σ (hnn p.id), ← Map.handle_after M σ (hnn (p.id - 1))]
      have e : σ.handle (p.id - 1) = (σ.pend p).id - 1 := by show _ = σ.handle p.id - 1; omega
      rw [e]; exact m3
  fresh k hk := by
    show M.region (σ.region (4 * (x0.next + k) + 2)) = _
    rw [hs.fresh k (by omega)]
    exact hp.fresh k hk

/-- The fresh handles' bigints reassigned from the start's counter: the pending traces keep theirs. -/
theorem _root_.Host.Ts.Sim.G.PendReg.rebig {M : Map} {x z : NSt} (hp : G.PendReg M x z) (b d : Nat) :
    G.PendReg (M.rebig x.next b d) x z where
  reg p hp0 := by
    obtain ⟨l1, l2, l3⟩ := hp.reg p hp0
    exact ⟨l1, by rw [rebig_handle M x.next b d l1]; exact l2,
      by rw [rebig_handle M x.next b d l1, rebig_handle M x.next b d (by omega)]; exact l3⟩
  fresh k hk := hp.fresh k hk

/-- The restart's relation (`FRr`'s shape): the weak general relation with the template's tokens
cleared and room for one more run from `x0`, and the bridge and observer relations. -/
def FRrF (P : LoadP) (NB : Nat) (x0 : FF.S) : Map → Nat → FF.S → FF.S → Prop :=
  fun M n x z => (G.LoadRw P NB M n (clearTokens (toLoad x)) (toLoad z) ∧ NRoom P (toLoad x0) (toLoad z)) ∧
    BridgeI M x z ∧ LiveR M (mlxOf x) (mlxOf z) (freedOf x) (freedOf z) ∧
    KernR M n (mlxOf x) (mlxOf z) (krecOf x) (krecOf z) ∧ G.PendReg M (mlxOf x) (mlxOf z)

/-- The restart's native shift, from the template start `x0`. -/
def FSnF (P : LoadP) (n0 : Nat) (x0 : FF.S) : Map → FF.S → FF.S → Prop :=
  fun σ x y => x = x0 ∧ FullShift P n0 σ x y

theorem fsnF_compose {P : LoadP} {NB n0 n1 : Nat} {x0 : FF.S} {σ : Map} :
    ∀ M x y z, FSnF P n0 x0 σ x y → FRrF P NB x0 M n1 y z → FRrF P NB x0 (M.after σ) n0 x z := by
  rintro M x y z ⟨rfl, hs⟩ ⟨⟨hr, hroom⟩, hb, hl, hk, hp⟩
  have hm := hs.load.mlx
  refine ⟨⟨?_, hroom⟩, ⟨by rw [hb.1, hs.bridge], by rw [← hs.bridge]; exact hb.2⟩, ?_, ?_,
    hp.after hs.pend hm.pending hm.nonneg hr.mlx.hnext.2⟩
  · rw [clearTokens_nil hs.load.mlx.tokens] at hr
    exact G.loadRw_restart hs.load hr hroom
  · intro fx0 e0
    obtain ⟨fx1, e1, hf⟩ := hs.live fx0 e0
    obtain ⟨fz, ez, hfz⟩ := hl fx1 e1
    exact ⟨fz, ez, hfz.restart hm hf⟩
  · intro k0 e0
    obtain ⟨k1, e1, hk1⟩ := hs.kern k0 e0
    obtain ⟨kz, ez, hkz⟩ := hk k1 e1
    exact ⟨kz, ez, hkz.restart hm hk1⟩

/-- Native handle and node counters advance in lockstep within a run (`lockstep` for the general
relation). -/
theorem lockstepG {P P' : LoadP} {NB : Nat} {M M1 : Map} {n n1 : Nat} {x0 x1 y0 y1 : Host.Load.LSt}
    (h0 : G.LoadR P NB M n x0 y0) (h1 : G.LoadR P' NB M1 n1 x1 y1) (he : Ext M M1 n) (hE : P'.E = P.E)
    (hle : x0.mlx.next ≤ x1.mlx.next) (hlt : x1.mlx.next < P.E) (hnle : x0.mlx.nnext ≤ x1.mlx.nnext) :
    y1.mlx.next = y0.mlx.next + (x1.mlx.next - x0.mlx.next) ∧
      y1.mlx.nnext = y0.mlx.nnext + (x1.mlx.nnext - x0.mlx.nnext) := by
  constructor
  · have e1 := h1.mlx.hfreshB 0 (by rw [hE]; omega)
    have e0 := h0.mlx.hfreshB (x1.mlx.next - x0.mlx.next) (by omega)
    rw [he.big] at e1
    simp only [Nat.add_zero] at e1
    rw [show x0.mlx.next + (x1.mlx.next - x0.mlx.next) = x1.mlx.next by omega, e1] at e0
    exact Int.ofNat.inj e0
  · have e1 := h1.mlx.nfresh 0
    have e0 := h0.mlx.nfresh (x1.mlx.nnext - x0.mlx.nnext)
    rw [he.node] at e1
    simp only [Nat.add_zero] at e1
    rw [show x0.mlx.nnext + (x1.mlx.nnext - x0.mlx.nnext) = x1.mlx.nnext by omega, e1] at e0
    exact e0

/-! ## The restart -/

/-- The template start's native facts at the token reference `k` (`lfStart` on the load-world
projection). -/
def fullStart (P : LoadP) (k : Nat) (s0 : St FF.S) : Prop :=
  (mlxOf s0.ffi).tokens = [.ref k] ∧ bigsOutB (mlxOf s0.ffi).next P.E (mlxOf s0.ffi) = true ∧
    NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E) s0.trace s0

/-! ## Over the bridge relation

The restart for `FullRB BR` with the template shift's bridge part `BS` (`FullShiftB`): `BR` reads the
map only through its node names (`BridgeNames`), and the shift's bridge part composes with it
(`ShiftComp`). `FullR` with `FullShift` is the instance `BridgeI`, `bridgeOf x1 = bridgeOf x0`. -/

/-- The bridge relation reads the map only through its node names. -/
def BridgeNames (BR : Map → FF.S → FF.S → Prop) : Prop :=
  ∀ M M' x y, BR M x y → M'.node = M.node → BR M' x y

theorem BridgeNames.stable {BR : Map → FF.S → FF.S → Prop} (h : BridgeNames BR) : BridgeStable BR :=
  fun M M' x y hb _ _ _ hn => h M M' x y hb hn

theorem bridgeI_names : BridgeNames BridgeI := fun _ _ _ _ h _ => h

/-- **The full world's native shift with the bridge part `BS`.** -/
structure FullShiftB (BS : Map → FF.S → FF.S → Prop) (P : LoadP) (n0 : Nat) (σ : Map) (x0 x1 : FF.S) : Prop where
  load : NShift P n0 σ (toLoad x0) (toLoad x1)
  bridge : BS σ x0 x1
  live : LiveShift σ (mlxOf x0) (mlxOf x1) (freedOf x0) (freedOf x1)
  kern : KernShift σ n0 (mlxOf x0) (mlxOf x1) (krecOf x0) (krecOf x1)
  pend : G.PendReg σ (mlxOf x0) (mlxOf x1)

theorem FullShiftB.withRest {BS : Map → FF.S → FF.S → Prop} {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : FF.S}
    (h : FullShiftB BS P n0 σ x0 x1) (r : List NumV) : FullShiftB BS { P with rest := r } n0 σ x0 x1 :=
  { h with load := h.load.withRest r }

/-- The template shift's bridge part with the bridge kept. -/
def BSI (_σ : Map) (x0 x1 : FF.S) : Prop := bridgeOf x1 = bridgeOf x0

theorem FullShift.toB {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : FF.S} (h : FullShift P n0 σ x0 x1) :
    FullShiftB BSI P n0 σ x0 x1 :=
  ⟨h.load, h.bridge, h.live, h.kern, h.pend⟩

/-- The shift's bridge part composes with the bridge relation at the end. -/
def ShiftComp (BS BR : Map → FF.S → FF.S → Prop) : Prop :=
  ∀ σ M x0 x1 z, BS σ x0 x1 → (∀ j, j < (mlxOf x0).nnext → σ.node j < (mlxOf x1).nnext) → BR M x1 z →
    BR (M.after σ) x0 z

theorem shiftComp_I : ShiftComp BSI BridgeI := fun _ _ _ _ _ hs _ hb =>
  ⟨by rw [hb.1, show bridgeOf _ = bridgeOf _ from hs], by rw [← show bridgeOf _ = bridgeOf _ from hs]; exact hb.2⟩

/-- **The restart relation with the bridge relation `BR`** (`FRrF`'s with `BridgeI` replaced). -/
def FRrFB (BR : Map → FF.S → FF.S → Prop) (P : LoadP) (NB : Nat) (x0 : FF.S) : Map → Nat → FF.S → FF.S → Prop :=
  fun M n x z => (G.LoadRw P NB M n (clearTokens (toLoad x)) (toLoad z) ∧ NRoom P (toLoad x0) (toLoad z)) ∧
    BR M x z ∧ LiveR M (mlxOf x) (mlxOf z) (freedOf x) (freedOf z) ∧
    KernR M n (mlxOf x) (mlxOf z) (krecOf x) (krecOf z) ∧ G.PendReg M (mlxOf x) (mlxOf z)

/-- The restart's native shift with the bridge part `BS`, from the template start `x0`. -/
def FSnFB (BS : Map → FF.S → FF.S → Prop) (P : LoadP) (n0 : Nat) (x0 : FF.S) : Map → FF.S → FF.S → Prop :=
  fun σ x y => x = x0 ∧ FullShiftB BS P n0 σ x y

theorem fsnFB_compose {BS BR : Map → FF.S → FF.S → Prop} (hc : ShiftComp BS BR) {P : LoadP} {NB n0 n1 : Nat}
    {x0 : FF.S} {σ : Map} :
    ∀ M x y z, FSnFB BS P n0 x0 σ x y → FRrFB BR P NB x0 M n1 y z → FRrFB BR P NB x0 (M.after σ) n0 x z := by
  rintro M x y z ⟨rfl, hs⟩ ⟨⟨hr, hroom⟩, hb, hl, hk, hp⟩
  have hm := hs.load.mlx
  refine ⟨⟨?_, hroom⟩, hc σ M x y z hs.bridge hm.nall hb, ?_, ?_,
    hp.after hs.pend hm.pending hm.nonneg hr.mlx.hnext.2⟩
  · rw [clearTokens_nil hs.load.mlx.tokens] at hr
    exact G.loadRw_restart hs.load hr hroom
  · intro fx0 e0
    obtain ⟨fx1, e1, hf⟩ := hs.live fx0 e0
    obtain ⟨fz, ez, hfz⟩ := hl fx1 e1
    exact ⟨fz, ez, hfz.restart hm hf⟩
  · intro k0 e0
    obtain ⟨k1, e1, hk1⟩ := hs.kern k0 e0
    obtain ⟨kz, ez, hkz⟩ := hk k1 e1
    exact ⟨kz, ez, hkz.restart hm hk1⟩

section
variable {BR BS : Map → FF.S → FF.S → Prop} (hn : BridgeNames BR) (hc : ShiftComp BS BR)
include hn hc

/-- **The restart from the end relation alone, over the bridge relation `BR`.** -/
theorem full_restart_dropEB (NB k w : Nat) {P : LoadP} {r0 : List NumV} {M1 : Map} {ν : Nat → F64} {K1 : Ctx}
    {W0 W1 : Nat → Option WFrame} {kp : Nat → Bool} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv}
    {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (hst : fullStart P k s0) (hr0 : r0 = v :: r)
    (h1 : RelF FF (FullRB BR { P with rest := r0 } NB) W1 M1 ν K1 s1 S1 t1 C1)
    (htab : ∀ e ∈ S1.tab, e.noVar w = true) (hor : ∀ q ∈ S1.oracle, q.noVar w = true)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftB BS P S0.tab.length σ x y) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩)
    (hW : ∀ a w, W0 a = some w → W1 a = some w) (hσ : σ.num k = .ref S1.tab.length) (hk : k < S0.tab.length)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C1.val v = some x) (hroom : t1.next - s0.next < Sim.bound)
    (hroomH : (mlxOf t1.ffi).next + (P.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hroomN : (mlxOf t1.ffi).nnext + (P.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62) :
    RelF FF (FullRB BR { P with rest := r } NB) W0
      (((M1.setNum S1.tab.length v).after σ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
      (Shift.valuation θ (upd ν w x))
      ⟨dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩
      s0 ⟨S0.tab, []⟩ t1 C1 := by
  subst hr0
  obtain ⟨htok, hbig, hfree⟩ := hst
  have hsh : FullShiftB BS { P with rest := v :: r } S0.tab.length σ s0.ffi s1.ffi := hshift.ffi.2.withRest _
  have hns := hsh.load
  have htk : (mlxOf t1.ffi).tokens = v :: r := by
    have := h1.ffi.load.mlx.tokensX
    rw [hns.mlx.tokens] at this
    simpa using this
  have hlaws := fullR_laws hn.stable { P with rest := v :: r } NB
  have h1' := (hlaws.stable _ _ _ _ _ h1.ffi (Map.setNum_ext M1 S1.tab.length v))
  have h1'' := hlaws.mono _ _ _ _ _ h1' (Nat.le_succ S1.tab.length)
  have hw : G.LoadRw { P with rest := v :: r } NB (M1.setNum S1.tab.length v) (S1.tab.length + 1)
      (clearTokens (toLoad s1.ffi)) (toLoad t1.ffi) := by
    rw [clearTokens_nil hns.mlx.tokens]
    exact h1''.load.weak
  have hf : FRrFB BR { P with rest := v :: r } NB s0.ffi (M1.setNum S1.tab.length v) (S1.tab.length + 1)
      s1.ffi t1.ffi :=
    ⟨⟨hw, hroomH, hroomN⟩, h1''.bridge, h1''.live, h1''.kern, h1''.pend⟩
  have h2 := (h1.extendVar' hlaws htab hor hx).mapFR' (FR' := FRrFB BR { P with rest := v :: r } NB s0.ffi)
    (by simpa using hf)
  have hshift' : ShiftD FF (FSnFB BS { P with rest := v :: r } S0.tab.length s0.ffi) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩ := { hshift with ffi := ⟨hshift.ffi.1, hsh⟩ }
  have hrel := restartDrop (F := FF) (FR := FRrFB BR { P with rest := v :: r } NB s0.ffi)
    (FS := FSnFB BS { P with rest := v :: r } S0.tab.length s0.ffi)
    (fun x y z hxy hyz => by simpa using fsnFB_compose hc _ x y z hxy (by simpa using hyz)) h2
    (hshift'.withOracle []) hW (fun _ hq => by cases hq) hroom
  obtain ⟨⟨hw0, -⟩, hb0, hl0, hk0, hp0⟩ := hrel.ffi
  have hz : (toLoad t1.ffi).mlx.tokens =
      (toLoad s0.ffi).mlx.tokens.map ((M1.setNum S1.tab.length v).after σ).nv ++ r := by
    show (mlxOf t1.ffi).tokens = (mlxOf s0.ffi).tokens.map _ ++ r
    rw [htk, htok]
    simp only [List.map_cons, List.map_nil, List.cons_append, List.nil_append, Map.nv]
    show v :: r = (M1.setNum S1.tab.length v).nv (σ.num k) :: r
    rw [hσ]
    simp [Map.nv, Map.setNum_self]
  have hld := G.LoadRw.rebig hw0 hbig (fun t ht => by
    change t ∈ (mlxOf s0.ffi).tokens at ht
    rw [htok] at ht; simp at ht; subst ht; exact hk) hz
  have hobj : ∀ h, ((mlxOf s0.ffi).objs.get h).isSome = true →
      (((M1.setNum S1.tab.length v).after σ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next).handle h =
        ((M1.setNum S1.tab.length v).after σ).handle h := fun h hh =>
    rebig_handle _ _ _ _ (hrel.ffi.1.1.mlx.hlt h (.inr hh))
  have hffi : FullRB BR { P with rest := r } NB
      (((M1.setNum S1.tab.length v).after σ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
      S0.tab.length s0.ffi t1.ffi :=
    ⟨hld, hn _ _ _ _ hb0 rfl, hl0.rebig hobj, hk0.rebig hobj rfl, hp0.rebig _ _⟩
  rw [Map.rebig_eq] at hffi ⊢
  exact hrel.rebig (fun i hi => by simp [hi]) (fun i hi => hband i hi) hfree hffi

/-- **The full world's restart dropping frames, over the bridge relation `BR`.** -/
theorem full_restart_dropB (NB k w : Nat) {P : LoadP} {r0 : List NumV} {M M1 : Map} {ν : Nat → F64} {K K1 : Ctx}
    {Wf W0 W1 : Nat → Option WFrame} {kp : Nat → Bool} {s0 s1 t t1 : St FF.S} {S0 S1 : SSrv} {C C1 : CSrv}
    {n : Nat} {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (hst : fullStart P k s0) (h : RelF FF (FullRB BR { P with rest := r0 } NB) Wf M ν K s0 S0 t C)
    (hr0 : r0 = v :: r) (hrc : runC FF n t C = some (t1, C1)) (hext : Ext M M1 S0.tab.length)
    (h1 : RelF FF (FullRB BR { P with rest := r0 } NB) W1 M1 ν K1 s1 S1 t1 C1)
    (hKD : K1.D = K.D) (hKlo : K1.lo = K.lo) (hKhi : K1.hi = K.hi)
    (htab : ∀ e ∈ S1.tab, e.noVar w = true) (hor : ∀ q ∈ S1.oracle, q.noVar w = true)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftB BS P S0.tab.length σ x y) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩)
    (hW : ∀ a w, W0 a = some w → W1 a = some w)
    (hσ : σ.num k = .ref S1.tab.length) (hk : k < S0.tab.length)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C.val v = some x) (hE : (mlxOf s1.ffi).next < P.E) (hD : s1.next - s0.next + K.D < Sim.bound)
    (hroomH : (mlxOf t.ffi).next + ((mlxOf s1.ffi).next - (mlxOf s0.ffi).next) + (P.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hroomN : (mlxOf t.ffi).nnext + ((mlxOf s1.ffi).nnext - (mlxOf s0.ffi).nnext) + (P.NE - (mlxOf s0.ffi).nnext) <
      2 ^ 62) :
    t1.next = t.next + (s1.next - s0.next) ∧
      (mlxOf t1.ffi).next = (mlxOf t.ffi).next + ((mlxOf s1.ffi).next - (mlxOf s0.ffi).next) ∧
      (mlxOf t1.ffi).nnext = (mlxOf t.ffi).nnext + ((mlxOf s1.ffi).nnext - (mlxOf s0.ffi).nnext) ∧
      RelF FF (FullRB BR { P with rest := r } NB) W0
        (((M1.setNum S1.tab.length v).after σ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
        (Shift.valuation θ (upd ν w x))
        ⟨dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨S0.tab, []⟩ t1 C1 := by
  have hns := (hshift.ffi.2.withRest r0).load
  have hl := lockstepG h.ffi.load h1.ffi.load hext rfl hns.mlx.hnext.2 hE hns.mlx.nle
  have hoff : t1.next = t.next + (s1.next - s0.next) := by
    have e1 := h1.offset; rw [hKD] at e1; have := h.offset; have := hshift.grows; omega
  have hvx : C1.val v = some x := (runC_le n t C t1 C1 hrc).val hx
  have hroom : t1.next - s0.next < Sim.bound := by
    rw [hoff]; have := h.offset; have := hshift.grows; omega
  refine ⟨hoff, hl.1, hl.2, ?_⟩
  have := full_restart_dropEB hn hc NB k w hst hr0 h1 htab hor hshift hW hσ hk
    (by rw [hKlo, hKhi]; exact hband) hvx hroom (by rw [hl.1]; omega) (by rw [hl.2]; omega)
  rw [hKlo, hKhi] at this
  exact this

end

/-- **The full world's restart dropping frames** (`load_restart_dropA` for `FullR`): the end
relation under frames `W1` and its context `K1`, the kept arrays `kp` and frames `W0`, at the token
reference `k` and the look-ahead variable `w`. -/
theorem full_restart_drop (NB k w : Nat) {P : LoadP} {r0 : List NumV} {M M1 : Map} {ν : Nat → F64} {K K1 : Ctx}
    {Wf W0 W1 : Nat → Option WFrame} {kp : Nat → Bool} {s0 s1 t t1 : St FF.S} {S0 S1 : SSrv} {C C1 : CSrv}
    {n : Nat} {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (hst : fullStart P k s0) (h : RelF FF (FLR P NB r0) Wf M ν K s0 S0 t C) (hr0 : r0 = v :: r)
    (hrc : runC FF n t C = some (t1, C1)) (hext : Ext M M1 S0.tab.length)
    (h1 : RelF FF (FLR P NB r0) W1 M1 ν K1 s1 S1 t1 C1)
    (hKD : K1.D = K.D) (hKlo : K1.lo = K.lo) (hKhi : K1.hi = K.hi)
    (htab : ∀ e ∈ S1.tab, e.noVar w = true) (hor : ∀ q ∈ S1.oracle, q.noVar w = true)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShift P S0.tab.length σ x y) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩)
    (hW : ∀ a w, W0 a = some w → W1 a = some w)
    (hσ : σ.num k = .ref S1.tab.length) (hk : k < S0.tab.length)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C.val v = some x) (hE : (mlxOf s1.ffi).next < P.E) (hD : s1.next - s0.next + K.D < Sim.bound)
    (hroomH : (mlxOf t.ffi).next + ((mlxOf s1.ffi).next - (mlxOf s0.ffi).next) + (P.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hroomN : (mlxOf t.ffi).nnext + ((mlxOf s1.ffi).nnext - (mlxOf s0.ffi).nnext) + (P.NE - (mlxOf s0.ffi).nnext) <
      2 ^ 62) :
    t1.next = t.next + (s1.next - s0.next) ∧
      (mlxOf t1.ffi).next = (mlxOf t.ffi).next + ((mlxOf s1.ffi).next - (mlxOf s0.ffi).next) ∧
      (mlxOf t1.ffi).nnext = (mlxOf t.ffi).nnext + ((mlxOf s1.ffi).nnext - (mlxOf s0.ffi).nnext) ∧
      RelF FF (FLR P NB r) W0 (((M1.setNum S1.tab.length v).after σ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
        (Shift.valuation θ (upd ν w x))
        ⟨dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨S0.tab, []⟩ t1 C1 := by
  exact full_restart_dropB bridgeI_names shiftComp_I NB k w hst h hr0 hrc hext h1 hKD hKlo hKhi htab hor
    { hshift with ffi := ⟨hshift.ffi.1, hshift.ffi.2.toB⟩ } hW hσ hk hband hx hE hD hroomH hroomN

/-- **`full_restart_drop` from the end relation alone** (`World.EndLaws.restartE` at `fullWorld`):
the room at the end, the readback's value at the end's server, the band at the end's context. -/
theorem full_restart_dropE (NB k w : Nat) {P : LoadP} {r0 : List NumV} {M1 : Map} {ν : Nat → F64} {K1 : Ctx}
    {W0 W1 : Nat → Option WFrame} {kp : Nat → Bool} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv}
    {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (hst : fullStart P k s0) (hr0 : r0 = v :: r) (h1 : RelF FF (FLR P NB r0) W1 M1 ν K1 s1 S1 t1 C1)
    (htab : ∀ e ∈ S1.tab, e.noVar w = true) (hor : ∀ q ∈ S1.oracle, q.noVar w = true)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShift P S0.tab.length σ x y) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩)
    (hW : ∀ a w, W0 a = some w → W1 a = some w) (hσ : σ.num k = .ref S1.tab.length) (hk : k < S0.tab.length)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C1.val v = some x) (hroom : t1.next - s0.next < Sim.bound)
    (hroomH : (mlxOf t1.ffi).next + (P.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hroomN : (mlxOf t1.ffi).nnext + (P.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62) :
    RelF FF (FLR P NB r) W0 (((M1.setNum S1.tab.length v).after σ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
      (Shift.valuation θ (upd ν w x))
      ⟨dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩
      s0 ⟨S0.tab, []⟩ t1 C1 := by
  exact full_restart_dropEB bridgeI_names shiftComp_I NB k w hst hr0 h1 htab hor
    { hshift with ffi := ⟨hshift.ffi.1, hshift.ffi.2.toB⟩ } hW hσ hk hband hx hroom hroomH hroomN

end Host.Ts.Sim.Full
