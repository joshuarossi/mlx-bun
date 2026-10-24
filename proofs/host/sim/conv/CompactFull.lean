import host.sim.conv.Compact
import host.sim.full.RestartD
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Layers

/-! # Compaction in the full world

`compact` at the full world's restart relation (`FRrF`) and native shift (`FSnF`), then the fresh
handle images reassigned (`G.LoadRw.rebig`, `RelF.rebig`): `full_restart_drop` without its token step.
The native part of the compaction map is a `FullShift` (the load world's `NShift`: the caller's
handles and nodes fixed, the stage's result handles and nodes at canonical places, the canonical
fresh ones after them in order); the bigint freedom of the canonical state (`hfree`) is the cut
bookkeeping (`Clean.noBigSt`). The merged state's readback tokens are consumed (`NShift`'s
`tokens`), and the canonical state holds none. -/

/-- **Compaction in the full world**: the merged state's relation (frames `W`, context `K1`) to the
canonical state's under the compaction map `κ`, every frame kept, the canonical fresh handles sent to
the target's next ones. -/
theorem full_compact (NB : Nat) {P : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx}
    {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv} {θ : Nat → SymE}
    (h1 : RelF FF (FLR P NB r) W M1 ν K1 s1 S1 t1 C1)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShift P S0.tab.length σ x y) κ θ (kpOf K1 W) W K1
      s0 S0 s1 S1)
    (htok : (mlxOf s0.ffi).tokens = [])
    (hbig : bigsOutB (mlxOf s0.ffi).next P.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound)
    (hroomN : NRoom P (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FLR P NB r) W ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
      (Shift.valuation θ ν)
      ⟨Shift.framedNext M1 K1 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t1 C1 := by
  have hsh : FullShift { P with rest := r } S0.tab.length κ s0.ffi s1.ffi := hshift.ffi.2.withRest _
  have hns := hsh.load
  have hw : G.LoadRw { P with rest := r } NB M1 S1.tab.length (clearTokens (toLoad s1.ffi)) (toLoad t1.ffi) := by
    rw [clearTokens_nil hns.mlx.tokens]
    exact h1.ffi.load.weak
  have hf : FRrF { P with rest := r } NB s0.ffi M1 S1.tab.length s1.ffi t1.ffi :=
    ⟨⟨hw, hroomN⟩, h1.ffi.bridge, h1.ffi.live, h1.ffi.kern, h1.ffi.pend⟩
  have h2 := h1.mapFR' (FR' := FRrF { P with rest := r } NB s0.ffi) hf
  have hshift' : ShiftD FF (FSnF { P with rest := r } S0.tab.length s0.ffi) κ θ (kpOf K1 W) W K1 s0 S0 s1 S1 :=
    { hshift with ffi := ⟨hshift.ffi.1, hsh⟩ }
  have hrel := compact (FS := FSnF { P with rest := r } S0.tab.length s0.ffi)
    (fun x y z hxy hyz => fsnF_compose _ x y z hxy hyz) h2 hshift' hg hroom
  obtain ⟨⟨hw0, -⟩, hb0, hl0, hk0, hp0⟩ := hrel.ffi
  have hz : (toLoad t1.ffi).mlx.tokens = (toLoad s0.ffi).mlx.tokens.map (M1.after κ).nv ++ r := by
    have := h1.ffi.load.mlx.tokensX
    rw [hns.mlx.tokens] at this
    show (mlxOf t1.ffi).tokens = (mlxOf s0.ffi).tokens.map _ ++ r
    rw [htok]
    simpa using this
  have hld := G.LoadRw.rebig hw0 hbig (fun t ht => by
    change t ∈ (mlxOf s0.ffi).tokens at ht
    rw [htok] at ht; cases ht) hz
  have hobj : ∀ h, ((mlxOf s0.ffi).objs.get h).isSome = true →
      ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next).handle h = (M1.after κ).handle h :=
    fun h hh => rebig_handle _ _ _ _ (hrel.ffi.1.1.mlx.hlt h (.inr hh))
  have hffi : FLR P NB r ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next) S0.tab.length
      s0.ffi t1.ffi :=
    ⟨hld, hb0, hl0.rebig hobj, hk0.rebig hobj rfl, hp0.rebig _ _⟩
  rw [Map.rebig_eq] at hffi ⊢
  exact hrel.rebig (fun i hi => by simp [hi]) (fun i hi => hband i hi) hfree hffi

/-! ## A non-empty readback queue

At a prefill site the merged state's readback queue need not be empty. The compaction then carries
it: the canonical tokens are the merged ones' preimages (`FullShiftQ.tokens`) and the load world's
shift is taken between the token-cleared states (`FullShiftQ.load`, `NShift` at `clearTokens`), so
the restart's pieces (`G.loadRw_restart`, `G.LoadRw.rebig`) apply unchanged and the rebig binds the
canonical tokens to the target's queue (`full_compactQ`). -/

theorem _root_.Host.Ts.Sim.G.MRw.clear {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt}
    (h : G.MRw P NB M n x y) : G.MRw P NB M n { x with tokens := [] } y :=
  { h with
    tokens := ⟨y.tokens, rfl⟩
    cl := ⟨h.cl.1, h.cl.2.1, (fun t ht => by cases ht), h.cl.2.2.2.1, h.cl.2.2.2.2⟩ }

theorem _root_.Host.Ts.Sim.G.LoadRw.clear {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : Host.Load.LSt}
    (h : G.LoadRw P NB M n x y) : G.LoadRw P NB M n (clearTokens x) y :=
  ⟨h.host, h.hostReg, h.hostLt, h.cbr, h.mlx.clear⟩

theorem clearTokens_idem (x : Host.Load.LSt) : clearTokens (clearTokens x) = clearTokens x := rfl

section
variable {M σ : Map} {x0 x1 z : NSt}

/-- `FreedR.restart` from the two facts of the shift it reads. -/
theorem _root_.Host.Ts.Sim.Full.FreedR.restartC {fx0 fx1 fz : PTrie Unit} (hnn : ∀ h : Nat, 0 ≤ σ.big (Int.ofNat h))
    (hobj : ∀ h, (x0.objs.get h).isSome = true → (x1.objs.get (σ.handle h)).isSome = true)
    (hs : FreedShift σ x0 x1 fx0 fx1) (hr : FreedR M x1 z fx1 fz) : FreedR (M.after σ) x0 z fx0 fz where
  obj := hs.obj
  img h hh := by rw [← Map.handle_after M σ (hnn h), hr.img _ (hobj h hh), hs.img h hh]
  lt := hr.lt

/-- `KRecR.restart` from the two facts of the shift it reads. -/
theorem _root_.Host.Ts.Sim.Full.KRecR.restartC {n0 n1 : Nat} {k0 k1 kz : KRec} (hnn : ∀ h : Nat, 0 ≤ σ.big (Int.ofNat h))
    (hobj : ∀ h, (x0.objs.get h).isSome = true → (x1.objs.get (σ.handle h)).isSome = true)
    (hs : KRecShift σ n0 x0 x1 k0 k1) (hr : KRecR M n1 x1 z k1 kz) : KRecR (M.after σ) n0 x0 z k0 kz where
  flagsObj := hs.flagsObj
  targsObj := hs.targsObj
  flags h hh := by rw [← Map.handle_after M σ (hnn h), hr.flags _ (hobj h hh), hs.flags h hh]
  targs h hh := by
    rw [← Map.handle_after M σ (hnn h), hr.targs _ (hobj h hh), hs.targs h hh, Option.map_map]
    congr 1
    funext l
    simp only [Function.comp, List.map_map]
    exact List.map_congr_left fun t _ => targ_after M σ t
  flagsLt := hr.flagsLt
  targsLt := hr.targsLt
  cl := hs.cl

end

/-- **The compaction's native shift with a readback queue**: `FullShift` with the load world's shift
between the token-cleared states and the canonical tokens the merged ones' preimages, closed below
`n0`; the pending traces' regions as `FullShift.pend`. -/
structure FullShiftQ (P : LoadP) (n0 : Nat) (σ : Map) (x0 x1 : FF.S) : Prop where
  load : NShift P n0 σ (clearTokens (toLoad x0)) (clearTokens (toLoad x1))
  tokens : (mlxOf x1).tokens = (mlxOf x0).tokens.map σ.nv
  tokSupp : ∀ t ∈ (mlxOf x0).tokens, Host.Ts.Sim.SN (· < n0) t
  bridge : bridgeOf x1 = bridgeOf x0
  live : LiveShift σ (mlxOf x0) (mlxOf x1) (freedOf x0) (freedOf x1)
  kern : KernShift σ n0 (mlxOf x0) (mlxOf x1) (krecOf x0) (krecOf x1)
  pend : G.PendReg σ (mlxOf x0) (mlxOf x1)

theorem FullShiftQ.withRest {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : FF.S} (h : FullShiftQ P n0 σ x0 x1)
    (r : List NumV) : FullShiftQ { P with rest := r } n0 σ x0 x1 :=
  { h with load := h.load.withRest r }


/-! ## Over the bridge relation

The compaction for the full world's relation `FullRB BR` with the shift's bridge part `BS`
(`FullShiftQB`), `BR` reading the map only through its node names (`BridgeNames`: the fresh handles'
reassignment keeps it) and `BS` composing with it (`ShiftComp`), as the restart's (`full_restart_dropB`).
Today's compaction is the instance `BridgeI` with the bridge kept (`BSI`, `FullShiftQ.toB`). -/

/-- **The compaction's native shift with the bridge part `BS`.** -/
structure FullShiftQB (BS : Map → FF.S → FF.S → Prop) (P : LoadP) (n0 : Nat) (σ : Map) (x0 x1 : FF.S) : Prop where
  load : NShift P n0 σ (clearTokens (toLoad x0)) (clearTokens (toLoad x1))
  tokens : (mlxOf x1).tokens = (mlxOf x0).tokens.map σ.nv
  tokSupp : ∀ t ∈ (mlxOf x0).tokens, Host.Ts.Sim.SN (· < n0) t
  bridge : BS σ x0 x1
  live : LiveShift σ (mlxOf x0) (mlxOf x1) (freedOf x0) (freedOf x1)
  kern : KernShift σ n0 (mlxOf x0) (mlxOf x1) (krecOf x0) (krecOf x1)
  pend : G.PendReg σ (mlxOf x0) (mlxOf x1)

theorem FullShiftQB.withRest {BS : Map → FF.S → FF.S → Prop} {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : FF.S}
    (h : FullShiftQB BS P n0 σ x0 x1) (r : List NumV) : FullShiftQB BS { P with rest := r } n0 σ x0 x1 :=
  { h with load := h.load.withRest r }

/-- Today's shift is the instance with the bridge kept. -/
theorem FullShiftQ.toB {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : FF.S} (h : FullShiftQ P n0 σ x0 x1) :
    FullShiftQB BSI P n0 σ x0 x1 :=
  ⟨h.load, h.tokens, h.tokSupp, h.bridge, h.live, h.kern, h.pend⟩

/-- The compaction's native shift with the bridge part `BS` from the canonical start `x0`. -/
def FSnQB (BS : Map → FF.S → FF.S → Prop) (P : LoadP) (n0 : Nat) (x0 : FF.S) : Map → FF.S → FF.S → Prop :=
  fun σ x y => x = x0 ∧ FullShiftQB BS P n0 σ x y

/-- The restart relation over `BR` at a raise. -/
def FRrFBD (BR : Map → FF.S → FF.S → Prop) (P : LoadP) (NB : Nat) (x0 : FF.S) : Map → Nat → FF.S → FF.S → Prop :=
  fun M n x z => ∃ P1, Raised P P1 ∧ FRrFB BR P1 NB x0 M n x z

section
variable {BR BS : Map → FF.S → FF.S → Prop}

/-- **The compaction's composition over the bridge relation.** -/
theorem fsnQB_compose (hc : ShiftComp BS BR) {P : LoadP} {NB n0 n1 : Nat} {x0 : FF.S} {σ : Map} :
    ∀ M x y z, FSnQB BS P n0 x0 σ x y → FRrFB BR P NB x0 M n1 y z → FRrFB BR P NB x0 (M.after σ) n0 x z := by
  rintro M x y z ⟨rfl, hs⟩ ⟨⟨hr, hroom⟩, hb, hl, hk, hp⟩
  have hm := hs.load.mlx
  have hobj : ∀ h, ((mlxOf x).objs.get h).isSome = true → ((mlxOf y).objs.get (σ.handle h)).isSome = true :=
    fun h hh => obj_shift hm hh
  refine ⟨⟨?_, hroom⟩, hc σ M x y z hs.bridge hm.nall hb, ?_, ?_,
    hp.after hs.pend hm.pending hm.nonneg hr.mlx.hnext.2⟩
  · have := G.loadRw_restart hs.load hr hroom
    rwa [clearTokens_idem] at this
  · intro fx0 e0
    obtain ⟨fx1, e1, hf⟩ := hs.live fx0 e0
    obtain ⟨fz, ez, hfz⟩ := hl fx1 e1
    exact ⟨fz, ez, FreedR.restartC hm.nonneg hobj hf hfz⟩
  · intro k0 e0
    obtain ⟨k1, e1, hk1⟩ := hs.kern k0 e0
    obtain ⟨kz, ez, hkz⟩ := hk k1 e1
    exact ⟨kz, ez, KRecR.restartC hm.nonneg hobj hk1 hkz⟩

/-- **Compaction over the bridge relation**: the merged state's relation (frames `W`, context `K1`) to
the canonical state's under the compaction map `κ`, the readback queue carried (`FullShiftQB`). -/
theorem full_compactQB (hn : BridgeNames BR) (hc : ShiftComp BS BR) (NB : Nat) {P : LoadP} {r : List NumV}
    {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx} {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv}
    {C1 : CSrv} {θ : Nat → SymE}
    (h1 : RelF FF (FullRB BR { P with rest := r } NB) W M1 ν K1 s1 S1 t1 C1)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftQB BS P S0.tab.length σ x y) κ θ (kpOf K1 W) W K1
      s0 S0 s1 S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound)
    (hroomN : NRoom P (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FullRB BR { P with rest := r } NB) W
      ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next) (Shift.valuation θ ν)
      ⟨Shift.framedNext M1 K1 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t1 C1 := by
  have hsh : FullShiftQB BS { P with rest := r } S0.tab.length κ s0.ffi s1.ffi := hshift.ffi.2.withRest _
  have hw : G.LoadRw { P with rest := r } NB M1 S1.tab.length (clearTokens (toLoad s1.ffi)) (toLoad t1.ffi) :=
    h1.ffi.load.weak.clear
  have hf : FRrFB BR { P with rest := r } NB s0.ffi M1 S1.tab.length s1.ffi t1.ffi :=
    ⟨⟨hw, hroomN⟩, h1.ffi.bridge, h1.ffi.live, h1.ffi.kern, h1.ffi.pend⟩
  have h2 := h1.mapFR' (FR' := FRrFB BR { P with rest := r } NB s0.ffi) hf
  have hshift' : ShiftD FF (FSnQB BS { P with rest := r } S0.tab.length s0.ffi) κ θ (kpOf K1 W) W K1 s0 S0 s1 S1 :=
    { hshift with ffi := ⟨hshift.ffi.1, hsh⟩ }
  have hrel := compact (FS := FSnQB BS { P with rest := r } S0.tab.length s0.ffi)
    (fun x y z hxy hyz => fsnQB_compose hc _ x y z hxy hyz) h2 hshift' hg hroom
  obtain ⟨⟨hw0, -⟩, hb0, hl0, hk0, hp0⟩ := hrel.ffi
  have hz : (toLoad t1.ffi).mlx.tokens = (toLoad s0.ffi).mlx.tokens.map (M1.after κ).nv ++ r := by
    have h' : (mlxOf t1.ffi).tokens = (mlxOf s1.ffi).tokens.map M1.nv ++ r := h1.ffi.load.mlx.tokensX
    rw [hsh.tokens, List.map_map] at h'
    show (mlxOf t1.ffi).tokens = (mlxOf s0.ffi).tokens.map (M1.after κ).nv ++ r
    rw [h']
    congr 1
    exact List.map_congr_left fun t _ => Map.nv_after M1 κ t
  have hld := G.LoadRw.rebig hw0 hbig hsh.tokSupp hz
  have hobj : ∀ h, ((mlxOf s0.ffi).objs.get h).isSome = true →
      ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next).handle h = (M1.after κ).handle h :=
    fun h hh => rebig_handle _ _ _ _ (hw0.mlx.hlt h (.inr hh))
  have hffi : FullRB BR { P with rest := r } NB ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
      S0.tab.length s0.ffi t1.ffi :=
    ⟨hld, hn _ _ _ _ hb0 rfl, hl0.rebig hobj, hk0.rebig hobj rfl, hp0.rebig _ _⟩
  rw [Map.rebig_eq] at hffi ⊢
  exact hrel.rebig (fun i hi => by simp [hi]) (fun i hi => hband i hi) hfree hffi

end

/-- **Compaction in the full world with a readback queue**: `full_compact` with the merged state's
queue carried to the canonical state (`FullShiftQ`): no empty-queue condition. The instance `BridgeI`
of `full_compactQB`. -/
theorem full_compactQ (NB : Nat) {P : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx}
    {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv} {θ : Nat → SymE}
    (h1 : RelF FF (FLR P NB r) W M1 ν K1 s1 S1 t1 C1)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftQ P S0.tab.length σ x y) κ θ (kpOf K1 W) W K1
      s0 S0 s1 S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound)
    (hroomN : NRoom P (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FLR P NB r) W ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
      (Shift.valuation θ ν)
      ⟨Shift.framedNext M1 K1 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t1 C1 :=
  full_compactQB bridgeI_names shiftComp_I NB h1 { hshift with ffi := ⟨hshift.ffi.1, hshift.ffi.2.toB⟩ }
    hbig hfree hband hg hroom hroomN

/-! ## At a raise

The relation with raised bands (`FullRD`): the merged state's relation at any raise of `P`, the shift
at the canonical state's raise `P0` (`fsnQBD_compose`, `G.loadRw_restartR`), and the result at a raise
of `P` again (`full_compactQBD`, its instance `full_compactQD`). With `P0 = P` and the relation at `P` this
is `full_compactQB`. -/

theorem _root_.Host.Ts.Sim.Full.Raised.withRest {P P0 : LoadP} (h : Raised P P0) (r : List NumV) :
    Raised { P with rest := r } { P0 with rest := r } := by
  rcases h with rfl | ⟨k, hb, hk, rfl⟩
  · exact .inl rfl
  · exact .inr ⟨k, hb, hk, rfl⟩

theorem _root_.Host.Ts.Sim.Full.Raised.rest {P P' : LoadP} (h : Raised P P') : P'.rest = P.rest := by
  rcases h with rfl | ⟨k, -, -, rfl⟩ <;> rfl


section
variable {BR BS : Map → FF.S → FF.S → Prop}

/-- `fsnQB_compose` at a raise: the shift at the start's raise `P0`, the restart relation at any raise. -/
theorem fsnQBD_compose (hc : ShiftComp BS BR) {P P0 : LoadP} {NB n0 n1 : Nat} {x0 : FF.S} {σ : Map}
    (hP0 : Raised P P0) (hNB : NB ≤ P0.NL) :
    ∀ M x y z, FSnQB BS P0 n0 x0 σ x y → FRrFBD BR P NB x0 M n1 y z → FRrFBD BR P NB x0 (M.after σ) n0 x z := by
  rintro M x y z ⟨hx, hs⟩ ⟨P1, hP1, ⟨hr, hroom⟩, hb, hl, hk, hp⟩
  obtain ⟨hlo, hE, hNE, hF⟩ := hP0.restart hP1
  have hroom0 : NRoom P0 (toLoad x0) (toLoad z) := by
    unfold NRoom at hroom ⊢; rw [← hE, ← hNE]; exact hroom
  subst x0
  have hm := hs.load.mlx
  have hobj : ∀ h, ((mlxOf x).objs.get h).isSome = true → ((mlxOf y).objs.get (σ.handle h)).isSome = true :=
    fun h hh => obj_shift hm hh
  refine ⟨P0, hP0, ⟨?_, hroom0⟩, hc σ M x y z hs.bridge hm.nall hb, ?_, ?_,
    hp.after hs.pend hm.pending hm.nonneg hr.mlx.hnext.2⟩
  · have := G.loadRw_restartR hs.load hr hlo hE hNE hF hNB hroom0
    rwa [clearTokens_idem] at this
  · intro fx0 e0
    obtain ⟨fx1, e1, hf⟩ := hs.live fx0 e0
    obtain ⟨fz, ez, hfz⟩ := hl fx1 e1
    exact ⟨fz, ez, FreedR.restartC hm.nonneg hobj hf hfz⟩
  · intro k0 e0
    obtain ⟨k1, e1, hk1⟩ := hs.kern k0 e0
    obtain ⟨kz, ez, hkz⟩ := hk k1 e1
    exact ⟨kz, ez, KRecR.restartC hm.nonneg hobj hk1 hkz⟩

/-- **Compaction over the bridge relation at a raise**: the merged state's relation at a raise of `P`,
the shift at a raise `P0` whose band holds the node bound `NB`, the result at a raise. -/
theorem full_compactQBD (hn : BridgeNames BR) (hc : ShiftComp BS BR) (NB : Nat) {P P0 : LoadP} {r : List NumV}
    {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx} {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv}
    {C1 : CSrv} {θ : Nat → SymE} (hP0 : Raised P P0) (hNB : NB ≤ P0.NL)
    (h1 : RelF FF (fun M n x y => ∃ P', Raised { P with rest := r } P' ∧ FullRB BR P' NB M n x y) W M1 ν K1 s1 S1 t1 C1)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftQB BS P0 S0.tab.length σ x y) κ θ (kpOf K1 W) W K1
      s0 S0 s1 S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound)
    (hroomN : NRoom P (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (fun M n x y => ∃ P', Raised { P with rest := r } P' ∧ FullRB BR P' NB M n x y) W
      ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next) (Shift.valuation θ ν)
      ⟨Shift.framedNext M1 K1 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t1 C1 := by
  have hsh : FullShiftQB BS { P0 with rest := r } S0.tab.length κ s0.ffi s1.ffi := hshift.ffi.2.withRest _
  obtain ⟨P1, hP1, h1f⟩ := h1.ffi
  obtain ⟨-, hE1, hNE1, -⟩ := Raised.restart (.inl rfl) hP1
  have hroomN1 : NRoom P1 (toLoad s0.ffi) (toLoad t1.ffi) := by
    unfold NRoom at hroomN ⊢; rw [hE1, hNE1]; exact hroomN
  have hf : FRrFBD BR { P with rest := r } NB s0.ffi M1 S1.tab.length s1.ffi t1.ffi :=
    ⟨P1, hP1, ⟨h1f.load.weak.clear, hroomN1⟩, h1f.bridge, h1f.live, h1f.kern, h1f.pend⟩
  have h2 := h1.mapFR' (FR' := FRrFBD BR { P with rest := r } NB s0.ffi) hf
  have hshift' : ShiftD FF (FSnQB BS { P0 with rest := r } S0.tab.length s0.ffi) κ θ (kpOf K1 W) W K1 s0 S0 s1 S1 :=
    { hshift with ffi := ⟨hshift.ffi.1, hsh⟩ }
  have hrel := compact (FS := FSnQB BS { P0 with rest := r } S0.tab.length s0.ffi)
    (fun x y z hxy hyz => fsnQBD_compose hc (hP0.withRest r) hNB _ x y z hxy hyz) h2 hshift' hg hroom
  obtain ⟨P2, hP2, ⟨hw0, -⟩, hb0, hl0, hk0, hp0⟩ := hrel.ffi
  obtain ⟨-, hE2, -, -⟩ := Raised.restart (.inl rfl) hP2
  have hz : (toLoad t1.ffi).mlx.tokens = (toLoad s0.ffi).mlx.tokens.map (M1.after κ).nv ++ r := by
    have h' : (mlxOf t1.ffi).tokens = (mlxOf s1.ffi).tokens.map M1.nv ++ P1.rest := h1f.load.mlx.tokensX
    rw [show P1.rest = r from hP1.rest, hsh.tokens, List.map_map] at h'
    show (mlxOf t1.ffi).tokens = (mlxOf s0.ffi).tokens.map (M1.after κ).nv ++ r
    rw [h']
    congr 1
    exact List.map_congr_left fun t _ => Map.nv_after M1 κ t
  have hld : G.LoadR { P2 with rest := r } NB
      ((M1.after κ).rebig (mlxOf s0.ffi).next P2.E (mlxOf t1.ffi).next) S0.tab.length (toLoad s0.ffi)
      (toLoad t1.ffi) := G.LoadRw.rebig hw0 (by rw [hE2]; exact hbig) hsh.tokSupp hz
  have hmap : (M1.after κ).rebig (mlxOf s0.ffi).next P2.E (mlxOf t1.ffi).next =
      (M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next := by rw [hE2]
  rw [hmap] at hld
  have hobj : ∀ h, ((mlxOf s0.ffi).objs.get h).isSome = true →
      ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next).handle h = (M1.after κ).handle h :=
    fun h hh => rebig_handle _ _ _ _ (hw0.mlx.hlt h (.inr hh))
  have hffi : (fun M n x y => ∃ P', Raised { P with rest := r } P' ∧ FullRB BR P' NB M n x y)
      ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next) S0.tab.length s0.ffi t1.ffi :=
    ⟨{ P2 with rest := r }, hP2.withRest r, hld, hn _ _ _ _ hb0 rfl, hl0.rebig hobj, hk0.rebig hobj rfl,
      hp0.rebig _ _⟩
  rw [Map.rebig_eq] at hffi ⊢
  exact hrel.rebig (fun i hi => by simp [hi]) (fun i hi => hband i hi) hfree hffi

end

/-- **Compaction at a raise**: `full_compactQ` with the merged state's relation at a raise of `P`
(`FullRD`), the shift at a raise `P0` whose band holds the node bound `NB`, and the result at a raise.
The instance `BridgeI` of `full_compactQBD`. -/
theorem full_compactQD (NB : Nat) {P P0 : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx}
    {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv} {θ : Nat → SymE}
    (hP0 : Raised P P0) (hNB : NB ≤ P0.NL)
    (h1 : RelF FF (FullRD { P with rest := r } NB) W M1 ν K1 s1 S1 t1 C1)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftQ P0 S0.tab.length σ x y) κ θ (kpOf K1 W) W K1
      s0 S0 s1 S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound)
    (hroomN : NRoom P (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FullRD { P with rest := r } NB) W ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
      (Shift.valuation θ ν)
      ⟨Shift.framedNext M1 K1 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t1 C1 :=
  full_compactQBD bridgeI_names shiftComp_I NB hP0 hNB h1 { hshift with ffi := ⟨hshift.ffi.1, hshift.ffi.2.toB⟩ }
    hbig hfree hband hg hroom hroomN

end Host.Ts.Sim.Conv
