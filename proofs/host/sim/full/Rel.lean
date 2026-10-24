import host.load.LayerLift
import host.sim.native.gen.Load
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers


/-! # The native relation of the full world

`FullR P NB M n x y` relates a template's state `x` of the full world (`Layers.full`: kernel
recording over liveness over symbolic shapes over the Neural Engine world) to a target state `y`.
It is a layer over the load world's general relation `G.LoadR`, which it keeps literally on the
load-world projection `toLoad`, so every relaxation of `G.LoadR` lifts:

* `load`: `G.LoadR P NB M n (toLoad x) (toLoad y)`;
* `bridge`: the Neural Engine bridge, here inactive and equal (`BridgeI`); `FullRB BR` is the
  relation for any bridge relation `BR`, so the active bridge is a second instance and the
  statements for `BridgeI` stand;
* `live`: the liveness layer's freed sets (`LiveR`): where the template's layer has not rejected,
  the target's has not either, and on the template's objects the target's freed set at the image
  handle is the template's (`FreedR`);
* `kern`: the kernel-recording layer's flags and template arguments (`KernR`), related the same way
  with the template arguments' numbers renamed (`targ`).

The observer relations constrain the target only at images of the template's objects and below its
handle counter: the template's recorded handles are objects (`obj`, `flagsObj`, `targsObj`), and
the target's recorded handles are below its counter (`lt`, `flagsLt`, `targsLt`), so the images of
the template's fresh handles are unrecorded. -/

abbrev FF : Ffi := Host.Load.Layers.full

/-- The Neural Engine bridge of a full-world state. -/
abbrev bridgeOf (p : FF.S) : Host.Mlx.FfiAne.St := p.1.1.bridge

/-- The liveness layer's state. -/
abbrev freedOf (p : FF.S) : Option (PTrie Unit) := p.1.2

/-- The kernel-recording layer's state. -/
abbrev krecOf (p : FF.S) : Option KRec := p.2

/-- The mlx model's state. -/
abbrev mlxOf (p : FF.S) : NSt := (toLoad p).mlx

/-! ## Liveness -/

/-- Freed sets: the template's (`fx`, over its mlx state `x`) and the target's (`fy`, over `y`). -/
structure FreedR (M : Map) (x y : NSt) (fx fy : PTrie Unit) : Prop where
  /-- The template's freed handles are objects. -/
  obj : ∀ h, fx.get h = some () → (x.objs.get h).isSome = true
  /-- At the image of a template object the target's freed set is the template's. -/
  img : ∀ h, (x.objs.get h).isSome = true → fy.get (M.handle h) = fx.get h
  /-- The target's freed handles are below its handle counter. -/
  lt : ∀ h, fy.get h = some () → h < y.next

/-- The liveness layers' states: where the template's accepts, the target's accepts, related. -/
def LiveR (M : Map) (x y : NSt) (ex ey : Option (PTrie Unit)) : Prop :=
  ∀ fx, ex = some fx → ∃ fy, ey = some fy ∧ FreedR M x y fx fy

/-! ## Kernel recording -/

/-- A recorded template argument under the map: an int argument's number renamed. -/
def targ (M : Map) : List Char × TArg → List Char × TArg
  | (n, .int v) => (n, .int (M.nv v))
  | (n, .dtype d) => (n, .dtype d)

/-- The numbers of recorded template arguments satisfy `R`. -/
def STargs (R : Nat → Prop) (l : List (List Char × TArg)) : Prop := ∀ n v, (n, TArg.int v) ∈ l → SN R v

/-- Kernel records: the template's (`kx`, over `x`) and the target's (`ky`, over `y`). -/
structure KRecR (M : Map) (n : Nat) (x y : NSt) (kx ky : KRec) : Prop where
  flagsObj : ∀ h, (kx.flags.get h).isSome = true → (x.objs.get h).isSome = true
  targsObj : ∀ h, (kx.targs.get h).isSome = true → (x.objs.get h).isSome = true
  flags : ∀ h, (x.objs.get h).isSome = true → ky.flags.get (M.handle h) = kx.flags.get h
  targs : ∀ h, (x.objs.get h).isSome = true →
    ky.targs.get (M.handle h) = (kx.targs.get h).map (List.map (targ M))
  flagsLt : ∀ h, (ky.flags.get h).isSome = true → h < y.next
  targsLt : ∀ h, (ky.targs.get h).isSome = true → h < y.next
  /-- The template's recorded numbers are closed. -/
  cl : ∀ h l, kx.targs.get h = some l → STargs (· < n) l

/-- The kernel-recording layers' states: where the template's accepts, the target's accepts, related. -/
def KernR (M : Map) (n : Nat) (x y : NSt) (ex ey : Option KRec) : Prop :=
  ∀ kx, ex = some kx → ∃ ky, ey = some ky ∧ KRecR M n x y kx ky

/-! ## The bridge -/

/-- The inactive bridge: the target's bridge is the template's, and no surface is wrapped. -/
def BridgeI (_M : Map) (x y : FF.S) : Prop := bridgeOf y = bridgeOf x ∧ (bridgeOf x).active = false

/-- A bridge relation only reads the map's names. -/
def BridgeStable (BR : Map → FF.S → FF.S → Prop) : Prop :=
  ∀ M M' x y, BR M x y → M'.a = M.a → M'.big = M.big → M'.region = M.region → M'.node = M.node → BR M' x y

theorem bridgeI_stable : BridgeStable BridgeI := fun _ _ _ _ h _ _ _ _ => h

/-! ## Pending traces' result regions

A compiled closure's first application records its trace through a `JSCallback` whose first
argument is the pending trace's result vector, region `4·id + 2` (`Ffi.closureApply`); the
callback hands it back to `mlx_vector_array_set_data`. The target's region of a pending trace is
its own trace's only where the map sends those regions in step with the handles (`reg`), and a
new trace's only where the fresh ones continue in order (`fresh`, `G.MR.hfreshR` at offset 2). The
continuation frees the tracer vector allocated just before the pending id (`Layers.liveBack`):
the map keeps the two adjacent (`reg`'s last part). -/

/-- **The pending traces' result regions under the map.** -/
structure _root_.Host.Ts.Sim.G.PendReg (M : Map) (x y : NSt) : Prop where
  reg : ∀ p ∈ x.pending, p.id < x.next ∧ M.region (4 * p.id + 2) = 4 * M.handle p.id + 2 ∧
    M.handle (p.id - 1) + 1 = M.handle p.id
  fresh : ∀ k, y.next + k < 2 ^ 46 → M.region (4 * (x.next + k) + 2) = 4 * (y.next + k) + 2

theorem _root_.Host.Ts.Sim.G.PendReg.names {M M' : Map} {x y : NSt} (h : G.PendReg M x y) (hb : M'.big = M.big)
    (hr : M'.region = M.region) : G.PendReg M' x y where
  reg p hp := by
    have hh : ∀ k, M'.handle k = M.handle k := fun k => by simp only [Map.handle, hb]
    rw [hr, hh, hh]; exact h.reg p hp
  fresh k hk := by rw [hr]; exact h.fresh k hk

theorem _root_.Host.Ts.Sim.G.PendReg.congr {M : Map} {x x' y : NSt} (h : G.PendReg M x y) (hp : x'.pending = x.pending)
    (hn : x'.next = x.next) : G.PendReg M x' y where
  reg p hp0 := by rw [hn]; exact h.reg p (hp ▸ hp0)
  fresh k hk := by rw [hn]; exact h.fresh k hk

/-! ## The relation -/

/-- **The full world's native relation** for a bridge relation `BR`. -/
structure FullRB (BR : Map → FF.S → FF.S → Prop) (P : LoadP) (NB : Nat) (M : Map) (n : Nat) (x y : FF.S) :
    Prop where
  load : G.LoadR P NB M n (toLoad x) (toLoad y)
  bridge : BR M x y
  live : LiveR M (mlxOf x) (mlxOf y) (freedOf x) (freedOf y)
  kern : KernR M n (mlxOf x) (mlxOf y) (krecOf x) (krecOf y)
  pend : G.PendReg M (mlxOf x) (mlxOf y)

/-- **The full world's native relation with the bridge inactive.** -/
abbrev FullR : LoadP → Nat → Map → Nat → FF.S → FF.S → Prop := FullRB BridgeI

/-- `FullR` with the target's remaining readbacks `r` (`G.LR`'s shape). -/
abbrev FLR (P : LoadP) (NB : Nat) (r : List NumV) : Map → Nat → FF.S → FF.S → Prop :=
  FullR { P with rest := r } NB

/-! ## Stability: `FRLaws` -/

section
variable {M M' : Map}

theorem FreedR.agree {x y : NSt} {fx fy : PTrie Unit} (h : FreedR M x y fx fy) (hb : M'.big = M.big) :
    FreedR M' x y fx fy :=
  ⟨h.obj, fun k hk => by rw [show M'.handle k = M.handle k by simp [Map.handle, hb]]; exact h.img k hk, h.lt⟩

theorem LiveR.agree {x y : NSt} {ex ey : Option (PTrie Unit)} (h : LiveR M x y ex ey) (hb : M'.big = M.big) :
    LiveR M' x y ex ey := fun fx hx => by
  obtain ⟨fy, hy, hf⟩ := h fx hx
  exact ⟨fy, hy, hf.agree hb⟩

theorem targ_agree {R : Nat → Prop} (h : NAgree R M M') {l : List (List Char × TArg)} (hl : STargs R l) :
    l.map (targ M') = l.map (targ M) := by
  refine List.map_congr_left fun p hp => ?_
  obtain ⟨n, t⟩ := p
  cases t with
  | int v => simp only [targ, h.nv (hl n v hp)]
  | dtype d => rfl

theorem STargs.mono {R R' : Nat → Prop} (hR : ∀ i, R i → R' i) {l : List (List Char × TArg)} (h : STargs R l) :
    STargs R' l := fun n v hv => SN.mono hR (h n v hv)

theorem KRecR.agree {n : Nat} {x y : NSt} {kx ky : KRec} (h : KRecR M n x y kx ky) (he : Ext M M' n) :
    KRecR M' n x y kx ky := by
  have ha := NAgree.ofExt he
  refine { h with flags := fun k hk => ?_, targs := fun k hk => ?_ }
  · rw [ha.handle]; exact h.flags k hk
  · rw [ha.handle, h.targs k hk]
    cases e : kx.targs.get k with
    | none => rfl
    | some l => simp only [Option.map_some, targ_agree ha (h.cl k l e)]

theorem KRecR.mono {n n' : Nat} {x y : NSt} {kx ky : KRec} (h : KRecR M n x y kx ky) (hn : n ≤ n') :
    KRecR M n' x y kx ky :=
  { h with cl := fun k l e => (h.cl k l e).mono fun _ hi => Nat.lt_of_lt_of_le hi hn }

theorem KernR.agree {n : Nat} {x y : NSt} {ex ey : Option KRec} (h : KernR M n x y ex ey) (he : Ext M M' n) :
    KernR M' n x y ex ey := fun kx hx => by
  obtain ⟨ky, hy, hk⟩ := h kx hx
  exact ⟨ky, hy, hk.agree he⟩

theorem KernR.mono {n n' : Nat} {x y : NSt} {ex ey : Option KRec} (h : KernR M n x y ex ey) (hn : n ≤ n') :
    KernR M n' x y ex ey := fun kx hx => by
  obtain ⟨ky, hy, hk⟩ := h kx hx
  exact ⟨ky, hy, hk.mono hn⟩

end

theorem fullR_laws {BR : Map → FF.S → FF.S → Prop} (hBR : BridgeStable BR) (P : LoadP) (NB : Nat) :
    FRLaws (F := FF) (FullRB BR P NB) :=
  ⟨fun _ _ _ _ _ hr he =>
    ⟨(G.loadR_laws P NB).stable _ _ _ _ _ hr.load he, hBR _ _ _ _ hr.bridge he.a he.big he.region he.node,
      hr.live.agree he.big, hr.kern.agree he, hr.pend.names he.big he.region⟩,
   fun _ _ _ _ _ hr hn => ⟨(G.loadR_laws P NB).mono _ _ _ _ _ hr.load hn, hr.bridge, hr.live, hr.kern.mono hn, hr.pend⟩⟩

/-! ## The native interface's other parts -/

/-- The full world's calls and continuations are lawful. -/
theorem fullLawful : BufSim.FfiLawful FF :=
  Host.Load.LayerLift.Observer.lawful kern.total
    (Host.Load.LayerLift.Observer.lawful live.total Host.Load.LayerLift.symLawful)

/-- A full world's memory read is the load world's. -/
theorem full_read (p : FF.S) (r off k : Nat) : FF.read p r off k = Host.Load.read (toLoad p) r off k := rfl

/-- The native interface's reads (no call or continuation is accepted here: `FfiCallSim` covers calls). -/
theorem fullFfiSim {BR : Map → FF.S → FF.S → Prop} (P : LoadP) (NB : Nat) :
    FfiSim FF (FullRB BR P NB) (fun _ _ _ => false) (fun _ _ => false) where
  call := fun _ _ _ _ _ _ _ _ _ _ h => absurd h (by simp)
  back := fun _ _ _ _ _ _ _ _ _ h => absurd h (by simp)
  read := fun _ _ _ _ _ _ _ _ hr hx => G.loadR_read hr.load hx

/-- The present-handle predicate of the full world (the load world's on `toLoad`). -/
def fullIsHandle (x : FF.S) (i : Int) : Bool := loadIsHandle (toLoad x) i

/-- The kept-apart regions of the full world (the load world's on `toLoad`). -/
def fullIsRegion (x : FF.S) (r : Nat) : Bool := loadIsRegion (toLoad x) r

theorem fullNativeFacts {BR : Map → FF.S → FF.S → Prop} (P : LoadP) (NB : Nat) (J : Disp.JSP FF)
    (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion) :
    Disp.NativeFacts FF (FullRB BR P NB) J where
  zero := fun _ _ _ _ hr i => hr.load.zero_fact i
  inj := fun _ _ _ _ hr i j hi hj he => by
    rw [hh] at hi hj; rw [hlo] at hj; exact hr.load.inj_fact i j hi hj he
  region := fun _ _ _ _ hr r r' h1 h2 he => by rw [hg] at h1 h2; exact hr.load.region_fact r r' h1 h2 he
  range := fun _ _ _ _ hr i hi => by rw [hh] at hi; exact hr.load.range_fact i hi
  host := fun _ _ _ _ hr r h3 hlt => hr.load.host_fact r h3 hlt
  cb := fun _ _ _ _ hr f hf => hr.load.cb_fact f hf

end Host.Ts.Sim.Full
