import host.sim.DecodeAddrSeam
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # Worlds

The composition layer (the prefill's cut steps, the decode loop's invariant and steps, the halts,
the route) reads its world through what this record names, so the same statements hold for the
load world `LF` (`lfWorld`, `host.sim.world.LF`) and for the full FFI world (`Layers.full`, after
loadDone) once its native relation and restart are proven:

* `F`: the FFI;
* `Par`, `lo`, `E`, `NE`: the native relation's fixed parameters (the renamed handle band from
  `lo`, the template's end counters `E` (handles) and `NE` (nodes));
* `R P r`: the native relation, by the target's remaining readbacks `r`, with its laws `laws`
  (`Rel.extendVar'` at a halt's look-ahead reference);
* `toMlx`: the mlx model's state of a world state (counters, tokens, growth `NGrow`; the graph
  side's statements);
* `pushTok`, `addToken`: the final template start appends the look-ahead token reference to the
  source's tokens, and the relation follows (`LoadR.addToken`);
* `NSh`, `Start`, `restart`: the template run's native shift, the template start's native facts
  (at the start's token reference `k`) and the restart after a run from a related template
  start to a related end (`load_restart_dropA`'s statement).

`World.EndLaws Wd`: the restart from the end relation alone and the native relation's fresh counters, which
a decode iteration through compactions needs (`lfWorld_end`; for the full world, A1's).

`finalStartW` is `finalStart` over a world; `objectW`, `ownW`, `elementsW`, `statsFieldW` are the
read-only projections of `Host.Load.Extract` and `Stop.statsField` over any FFI state type, and
`RelF.emittedW` is `RelF.emitted` over any world. -/

/-- **A world** of the composition layer (see the module doc). -/
structure World where
  F : Ffi
  Par : Type
  lo : Par → Nat
  E : Par → Nat
  NE : Par → Nat
  R : Par → List NumV → Map → Nat → F.S → F.S → Prop
  toMlx : F.S → Host.Mlx.Ffi.St
  laws : ∀ P r, FRLaws (F := F) (R P r)
  pushTok : F.S → Nat → F.S
  addToken : ∀ {P : Par} {w : NumV} {r : List NumV} {M : Map} {n : Nat} {x y : F.S},
    R P (w :: r) M n x y → R P r (M.setNum n w) (n + 1) (pushTok x n) y
  NSh : Par → Nat → Map → F.S → F.S → Prop
  Start : Par → Nat → St F.S → Prop
  restart : ∀ (k w : Nat) {P : Par} {r0 : List NumV} {M M1 : Map} {ν : Nat → F64} {K K1 : Ctx}
    {Wf W0 W1 : Nat → Option WFrame} {kp : Nat → Bool} {s0 s1 t t1 : St F.S} {S0 S1 : SSrv} {C C1 : CSrv}
    {n : Nat} {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64},
    Start P k s0 → RelF F (R P r0) Wf M ν K s0 S0 t C → r0 = v :: r →
    runC F n t C = some (t1, C1) → Ext M M1 S0.tab.length → RelF F (R P r0) W1 M1 ν K1 s1 S1 t1 C1 →
    K1.D = K.D → K1.lo = K.lo → K1.hi = K.hi →
    (∀ e ∈ S1.tab, e.noVar w = true) → (∀ q ∈ S1.oracle, q.noVar w = true) →
    ShiftD F (fun σ x y => x = s0.ffi ∧ NSh P S0.tab.length σ x y) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩ →
    (∀ a w, W0 a = some w → W1 a = some w) →
    σ.num k = .ref S1.tab.length → k < S0.tab.length →
    (∀ i : Int, ((toMlx s0.ffi).next : Int) ≤ i ∧ i < E P → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56) →
    C.val v = some x → (toMlx s1.ffi).next < E P → s1.next - s0.next + K.D < Sim.bound →
    (toMlx t.ffi).next + ((toMlx s1.ffi).next - (toMlx s0.ffi).next) + (E P - (toMlx s0.ffi).next) < 2 ^ 46 →
    (toMlx t.ffi).nnext + ((toMlx s1.ffi).nnext - (toMlx s0.ffi).nnext) + (NE P - (toMlx s0.ffi).nnext) <
      2 ^ 62 →
    t1.next = t.next + (s1.next - s0.next) ∧
      (toMlx t1.ffi).next = (toMlx t.ffi).next + ((toMlx s1.ffi).next - (toMlx s0.ffi).next) ∧
      (toMlx t1.ffi).nnext = (toMlx t.ffi).nnext + ((toMlx s1.ffi).nnext - (toMlx s0.ffi).nnext) ∧
      RelF F (R P r) W0 (((M1.setNum S1.tab.length v).after σ).rebig (toMlx s0.ffi).next (E P) (toMlx t1.ffi).next)
        (Shift.valuation θ (upd ν w x))
        ⟨dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨S0.tab, []⟩ t1 C1

/-- **The restart from the end relation alone**, and the native relation's fresh counters: what a
decode iteration through compactions needs (`decodeIter_piecesCW`, `host.sim.world.IterCut`).
`restartE` is `restart` without the start relation, the run and the counter lockstep: a
compaction inside the iteration moves the map's fresh part and resets the context's offset, so
the end's map does not extend the start's; the room is stated at the end, the readback's value at
the end's server, the band at the end's context. `bigFresh`, `nodeFresh`: a related pair's map
sends the source's fresh handles and nodes to the target's in order (`MR.hfreshB`, `MRw.nfresh`),
from which the iteration's ghost reads the target's mlx counters. -/
structure World.EndLaws (Wd : World) : Prop where
  restartE : ∀ (k w : Nat) {P : Wd.Par} {r0 : List NumV} {M1 : Map} {ν : Nat → F64} {K1 : Ctx}
    {W0 W1 : Nat → Option WFrame} {kp : Nat → Bool} {s0 s1 t1 : St Wd.F.S} {S0 S1 : SSrv} {C1 : CSrv}
    {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64},
    Wd.Start P k s0 → r0 = v :: r → RelF Wd.F (Wd.R P r0) W1 M1 ν K1 s1 S1 t1 C1 →
    (∀ e ∈ S1.tab, e.noVar w = true) → (∀ q ∈ S1.oracle, q.noVar w = true) →
    ShiftD Wd.F (fun σ x y => x = s0.ffi ∧ Wd.NSh P S0.tab.length σ x y) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩ →
    (∀ a w, W0 a = some w → W1 a = some w) →
    σ.num k = .ref S1.tab.length → k < S0.tab.length →
    (∀ i : Int, ((Wd.toMlx s0.ffi).next : Int) ≤ i ∧ i < Wd.E P → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56) →
    C1.val v = some x → t1.next - s0.next < Sim.bound →
    (Wd.toMlx t1.ffi).next + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46 →
    (Wd.toMlx t1.ffi).nnext + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62 →
    RelF Wd.F (Wd.R P r) W0
      (((M1.setNum S1.tab.length v).after σ).rebig (Wd.toMlx s0.ffi).next (Wd.E P) (Wd.toMlx t1.ffi).next)
      (Shift.valuation θ (upd ν w x))
      ⟨dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩
      s0 ⟨S0.tab, []⟩ t1 C1
  bigFresh : ∀ {P : Wd.Par} {r : List NumV} {M : Map} {n : Nat} {x y : Wd.F.S}, Wd.R P r M n x y → ∀ k,
    (Wd.toMlx x).next + k < Wd.E P → M.big (Int.ofNat ((Wd.toMlx x).next + k)) = Int.ofNat ((Wd.toMlx y).next + k)
  nodeFresh : ∀ {P : Wd.Par} {r : List NumV} {M : Map} {n : Nat} {x y : Wd.F.S}, Wd.R P r M n x y → ∀ k,
    M.node ((Wd.toMlx x).nnext + k) = (Wd.toMlx y).nnext + k

namespace World
variable (Wd : World)

/-- The final template start: the loop template with its look-ahead token reference `n`. -/
def finalStartW (s0 : St Wd.F.S) (n : Nat) : St Wd.F.S := s0.setFfi (Wd.pushTok s0.ffi n)

/-- The target's mlx state grows. -/
def Grows (t t' : St Wd.F.S) : Prop := Host.Mlx.Ffi.NGrow (Wd.toMlx t.ffi) (Wd.toMlx t'.ffi)

theorem Grows.refl (t : St Wd.F.S) : Wd.Grows t t := Host.Mlx.Ffi.NGrow.refl _

theorem Grows.trans {t1 t2 t3 : St Wd.F.S} (h1 : Wd.Grows t1 t2) (h2 : Wd.Grows t2 t3) : Wd.Grows t1 t3 :=
  Host.Mlx.Ffi.NGrow.trans h1 h2

end World

/-! ## Read-only projections over any FFI state -/

section Extract
variable {S : Type}

/-- `Host.Load.Extract.object` over any FFI state. -/
def objectW (s : St S) : Val → Option Obj
  | .obj a => s.obj? a
  | _ => none

/-- `Host.Load.Extract.own` over any FFI state. -/
def ownW (s : St S) (v : Val) (n : List Char) : Option Val :=
  (objectW s v).bind fun o => (findProp (.str n) o.props).bind Host.Load.Extract.data

/-- `Host.Load.Extract.elements` over any FFI state. -/
def elementsW (s : St S) (v : Val) : Option (List Val) := do
  let o ← objectW s v
  match o.kind with | .array es => some es | _ => none

/-- `Stop.statsField` over any FFI state: `generation.stats.<key>`. -/
def statsFieldW (s : St S) (env : Env) (key : List Char) : Option Val := do
  let generation ← bindingOf s env chars!"generation"
  let stats ← ownW s generation chars!"stats"
  ownW s stats key

end Extract

/-- **The emitted tokens under the frames** over any FFI (`RelF.emitted`): the binding's cell and
the framed array carry no frame of `W`. -/
theorem RelF.emittedW {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {M : Map}
    {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}
    (h : RelF F FR W M ν K s S t C)
    {env : Env} {n : Name} {cE b : Nat} {pre pre' xs : List Val} {o : Obj}
    (hl : lookupEnv n env = some cE) (hc : s.cell? cE = some (some (.obj b)))
    (hfa : M.a cE = cE) (hfb : M.a b = b) (hk : K.fr b = some (pre, pre'))
    (hg : s.heap.get b = some (.obj o)) (hkind : o.kind = .array (pre ++ xs))
    (hwc : W cE = none) (hwb : W b = none) :
    (bindingOf t env n).bind (elementsW t) = some (pre' ++ M.vals xs) := by
  have hc' : t.cell? cE = some (some (.obj b)) := by
    have := h.cell? hc (.inl hwc)
    rw [hfa] at this
    exact this.trans (by show some (some (Val.obj (M.a b))) = _; rw [hfb])
  obtain ⟨o', ho', ys, hys, rfl⟩ := h.obj?_framed (obj?_iff.2 hg) hk hwb
  rw [hkind] at hys
  have hxy : ys = xs := (List.append_cancel_left (Kind.array.inj hys)).symm
  subst hxy
  rw [hfb] at ho'
  unfold bindingOf
  rw [hl, Option.bind_some, hc']
  show elementsW t (.obj b) = _
  simp [elementsW, objectW]
  erw [ho']
  rfl

end Host.Ts.Sim
