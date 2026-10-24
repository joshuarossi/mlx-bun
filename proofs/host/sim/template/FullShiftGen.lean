import host.sim.full.Restart
import host.sim.template.NShiftOf
namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Layers

/-! # Kernel checks of a full-world template shift

The observer parts of `FullShift` (`host.sim.full.Restart`) as Boolean checks over explicit key lists, so
a case's `LiveShift` and `KernShift` at the template's ends are kernel evaluations (`genRestart.ts
--world full`): the start's freed handles and recorded handles are objects (`PTrie.keys` of the freed
set, the flags and the template arguments), and at the image of every start object (`PTrie.keys` of the
start's objects) the end's layers record what the start's do, the template arguments' numbers renamed;
the start's recorded numbers are closed; the pending traces' result regions (`G.PendReg`) at the start's
pending traces, and in order for the fresh ones (an `RData` map's regions). -/

/-! ## Template arguments -/

/-- Equality of recorded template arguments. -/
def targEqB : List Char × TArg → List Char × TArg → Bool
  | (n, .int v), (m, .int u) => decide (n = m) && decide (v = u)
  | (n, .dtype d), (m, .dtype e) => decide (n = m) && Nat.beq d e
  | _, _ => false

theorem targEqB_sound : ∀ {a b : List Char × TArg}, targEqB a b = true → a = b
  | (n, .int v), (m, .int u), h => by
    simp only [targEqB, Bool.and_eq_true, decide_eq_true_eq] at h
    rw [h.1, h.2]
  | (n, .dtype d), (m, .dtype e), h => by
    simp only [targEqB, Bool.and_eq_true, decide_eq_true_eq, Nat.beq_eq] at h
    rw [h.1, h.2]
  | (_, .int _), (_, .dtype _), h => by cases h
  | (_, .dtype _), (_, .int _), h => by cases h

def targsEqB : List (List Char × TArg) → List (List Char × TArg) → Bool
  | [], [] => true
  | a :: l, b :: r => targEqB a b && targsEqB l r
  | _, _ => false

theorem targsEqB_sound : ∀ {l r : List (List Char × TArg)}, targsEqB l r = true → l = r
  | [], [], _ => rfl
  | a :: l, b :: r, h => by
    simp only [targsEqB, Bool.and_eq_true] at h
    rw [targEqB_sound h.1, targsEqB_sound h.2]
  | [], _ :: _, h => by cases h
  | _ :: _, [], h => by cases h

def otargsEqB : Option (List (List Char × TArg)) → Option (List (List Char × TArg)) → Bool
  | none, none => true
  | some l, some r => targsEqB l r
  | _, _ => false

theorem otargsEqB_sound : ∀ {a b : Option (List (List Char × TArg))}, otargsEqB a b = true → a = b
  | none, none, _ => rfl
  | some _, some _, h => by rw [targsEqB_sound h]
  | none, some _, h => by cases h
  | some _, none, h => by cases h

/-- The recorded numbers are references below `n0`. -/
def stargsB (n0 : Nat) (l : List (List Char × TArg)) : Bool :=
  l.all fun p => match p.2 with
    | .int (.ref i) => Nat.blt i n0
    | _ => true

theorem stargs_of {n0 : Nat} {l : List (List Char × TArg)} (h : stargsB n0 l = true) : STargs (· < n0) l := by
  intro n v hm
  have := List.all_eq_true.mp h _ hm
  cases v with
  | lit _ => trivial
  | ref i => exact Nat.blt_eq.mp this

/-! ## Liveness -/

theorem mem_keys_of_isSome {α : Type} {t : PTrie α} {h : Nat} (hs : (t.get h).isSome = true) : h ∈ PTrie.keys t := by
  obtain ⟨x, hx⟩ := Option.isSome_iff_exists.mp hs
  exact PTrie.mem_keys _ _ _ hx

/-- `FreedShift`, checked over the freed handles and the start's objects. -/
def freedShiftB (σ : Map) (x0 : NSt) (fx0 fx1 : PTrie Unit) : Bool :=
  (PTrie.keys fx0).all (fun h => (x0.objs.get h).isSome) &&
    (PTrie.keys x0.objs).all fun h => decide (fx1.get (σ.handle h) = fx0.get h)

theorem freedShift_of {σ : Map} {x0 x1 : NSt} {fx0 fx1 : PTrie Unit} (h : freedShiftB σ x0 fx0 fx1 = true) :
    FreedShift σ x0 x1 fx0 fx1 := by
  simp only [freedShiftB, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at h
  exact ⟨fun k hk => h.1 k (PTrie.mem_keys _ _ _ hk), fun k hk => h.2 k (mem_keys_of_isSome hk)⟩

/-- `LiveShift`: where the start's layer accepts, the end's does, related. -/
def liveShiftB (σ : Map) (x0 : NSt) : Option (PTrie Unit) → Option (PTrie Unit) → Bool
  | none, _ => true
  | some fx0, some fx1 => freedShiftB σ x0 fx0 fx1
  | some _, none => false

theorem liveShift_of {σ : Map} {x0 x1 : NSt} {e0 e1 : Option (PTrie Unit)} (h : liveShiftB σ x0 e0 e1 = true) :
    LiveShift σ x0 x1 e0 e1 := by
  intro fx0 e
  subst e
  cases e1 with
  | none => cases h
  | some fx1 => exact ⟨fx1, rfl, freedShift_of h⟩

/-! ## Kernel recording -/

/-- `KRecShift`, checked over the recorded handles and the start's objects. -/
def krecShiftB (σ : Map) (n0 : Nat) (x0 : NSt) (k0 k1 : KRec) : Bool :=
  (PTrie.keys k0.flags).all (fun h => (x0.objs.get h).isSome) &&
    (PTrie.keys k0.targs).all (fun h => (x0.objs.get h).isSome && (k0.targs.get h).all (stargsB n0)) &&
    (PTrie.keys x0.objs).all fun h => decide (k1.flags.get (σ.handle h) = k0.flags.get h) &&
      otargsEqB (k1.targs.get (σ.handle h)) ((k0.targs.get h).map (List.map (targ σ)))

theorem krecShift_of {σ : Map} {n0 : Nat} {x0 x1 : NSt} {k0 k1 : KRec} (h : krecShiftB σ n0 x0 k0 k1 = true) :
    KRecShift σ n0 x0 x1 k0 k1 := by
  simp only [krecShiftB, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at h
  obtain ⟨⟨hf, ht⟩, ho⟩ := h
  refine ⟨fun k hk => hf k (mem_keys_of_isSome hk), fun k hk => (ht k (mem_keys_of_isSome hk)).1,
    fun k hk => (ho k (mem_keys_of_isSome hk)).1, fun k hk => otargsEqB_sound (ho k (mem_keys_of_isSome hk)).2, ?_⟩
  intro k l hl
  have := (ht k (PTrie.mem_keys _ _ _ hl)).2
  rw [hl] at this
  exact stargs_of this

/-- `KernShift`: where the start's layer accepts, the end's does, related. -/
def kernShiftB (σ : Map) (n0 : Nat) (x0 : NSt) : Option KRec → Option KRec → Bool
  | none, _ => true
  | some k0, some k1 => krecShiftB σ n0 x0 k0 k1
  | some _, none => false

theorem kernShift_of {σ : Map} {n0 : Nat} {x0 x1 : NSt} {e0 e1 : Option KRec} (h : kernShiftB σ n0 x0 e0 e1 = true) :
    KernShift σ n0 x0 x1 e0 e1 := by
  intro k0 e
  subst e
  cases e1 with
  | none => cases h
  | some k1 => exact ⟨k1, rfl, krecShift_of h⟩

/-! ## Pending traces' result regions -/

/-- `G.PendReg`'s regions at the start's pending traces. -/
def pendRegB (σ : Map) (x0 : NSt) : Bool :=
  x0.pending.all fun p => Nat.blt p.id x0.next && Nat.beq (σ.region (4 * p.id + 2)) (4 * σ.handle p.id + 2) &&
    Nat.beq (σ.handle (p.id - 1) + 1) (σ.handle p.id)

/-- `G.PendReg` for a map whose regions are an `RData`'s with the start's and the end's handle counters. -/
theorem pendReg_of {σ : Map} {D : RData} {x0 x1 : NSt} (hreg : σ.region = D.region) (h0 : D.nh0 = x0.next)
    (h1 : D.nh1 = x1.next) (hle : x0.next ≤ x1.next) (hc : pendRegB σ x0 = true) : G.PendReg σ x0 x1 where
  reg p hp := by
    have := List.all_eq_true.mp hc p hp
    simp only [Bool.and_eq_true, Nat.blt_eq, Nat.beq_eq] at this
    exact ⟨this.1.1, this.1.2, this.2⟩
  fresh k hk := by
    rw [hreg, D.region_hd (h := x0.next + k) (c := 2) (by decide) (by omega)]
    simp only [RData.hd, ← h0, RData.ble_true (Nat.le_add_right D.nh0 k), Bool.cond_true]
    omega

/-! ## Kept frames across a site's map

A site's or a class's frames under the caller's (`Conv.isolateW`, `Conv.site_classW`): the restart's `WFix σ` at
each wide frame, decided (a typed array's buffer and the ghost private names' brands fixed and present). -/

/-- `WFix σ` decided at a frame, the present addresses by `A`. -/
def wfixB (σ : Map) (A : Nat → Bool) : WFrame → Bool
  | .typed _ b _ _ => Nat.beq (σ.a b) b
  | .fields ks ps => ks.all (fun k => match k with | .str _ => true | .sym _ => false) &&
      ps.all fun p => Nat.beq (σ.a p.1) p.1 && A p.1
  | _ => true

theorem wfix_of {σ : Map} {A : Nat → Bool} {w : WFrame} (h : wfixB σ A w = true) : WFix σ (fun a => A a = true) w := by
  cases w
  case typed k b off n => exact Nat.eq_of_beq_eq_true h
  case fields ks ps =>
    simp only [wfixB, Bool.and_eq_true, List.all_eq_true, Nat.beq_eq] at h
    refine ⟨fun k hk => ?_, fun p hp => h.2 p hp⟩
    have := h.1 k hk
    cases k with
    | str cs => exact ⟨cs, rfl⟩
    | sym i => cases this
  all_goals trivial

/-! ## The shift -/

/-- **A full-world template shift** from the load world's shift on the projections, the unchanged bridge,
the observer checks and the pending traces' regions. -/
theorem fullShift_of {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : FF.S} (hl : NShift P n0 σ (toLoad x0) (toLoad x1))
    (hb : bridgeOf x1 = bridgeOf x0) (hlive : liveShiftB σ (mlxOf x0) (freedOf x0) (freedOf x1) = true)
    (hkern : kernShiftB σ n0 (mlxOf x0) (krecOf x0) (krecOf x1) = true) (hpend : G.PendReg σ (mlxOf x0) (mlxOf x1)) :
    FullShift P n0 σ x0 x1 :=
  ⟨hl, hb, liveShift_of hlive, kernShift_of hkern, hpend⟩

end Host.Ts.Sim.Template
