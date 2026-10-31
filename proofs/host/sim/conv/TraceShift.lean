import host.sim.native.Shift

namespace Host.Ts.Sim.Conv
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-- A native shift whose fixed node prefix is `NB`. Recorded traces remain below `P.NL`;
all object, node, ordering, injection and allocation fields are the native shift fields. -/
structure TraceMShift (P : LoadP) (NB n0 : Nat) (σ : Map) (x0 x1 : NSt) : Prop where
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
  nid : ∀ j, j < NB → σ.node j = j
  nbl : NB ≤ P.NL
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

/-- The load-world shift with the same host and callback region equations. -/
structure TraceNShift (P : LoadP) (NB n0 : Nat) (σ : Map) (x0 x1 : Host.Load.LSt) : Prop where
  host : x1.host = x0.host
  hostReg : ∀ h, h < 2 ^ 46 → σ.region (4 * h + 3) = 4 * h + 3
  cbr : ∀ a, σ.region (cbBase + a) = cbBase + σ.a a
  mlx : TraceMShift P NB n0 σ x0.mlx x1.mlx

section
variable {P : LoadP} {NB n0 : Nat} {σ : Map} {x0 x1 : NSt}

/-- The old shift supplies every field, restricting only its fixed prefix. -/
theorem TraceMShift.ofShift (h : MShift P n0 σ x0 x1) (hb : NB ≤ P.NL) :
    TraceMShift P NB n0 σ x0 x1 :=
  { h with nid := fun j hj => h.nid j (Nat.lt_of_lt_of_le hj hb), nbl := hb }

/-- Recover the unchanged old contract exactly when the larger prefix is fixed. -/
theorem TraceMShift.toShift (h : TraceMShift P NB n0 σ x0 x1)
    (hid : ∀ j, j < P.NL → σ.node j = j) : MShift P n0 σ x0 x1 :=
  { h with nid := hid }

/-- Exact agreement with the old contract, including its larger fixed prefix. -/
theorem traceMShift_iff (hb : NB ≤ P.NL) :
    MShift P n0 σ x0 x1 ↔ TraceMShift P NB n0 σ x0 x1 ∧ (∀ j, j < P.NL → σ.node j = j) :=
  ⟨fun h => ⟨TraceMShift.ofShift h hb, h.nid⟩, fun h => h.1.toShift h.2⟩

theorem TraceMShift.withRest (h : TraceMShift P NB n0 σ x0 x1) (r : List NumV) :
    TraceMShift { P with rest := r } NB n0 σ x0 x1 := { h with }
end

section
variable {P : LoadP} {NB n0 : Nat} {σ : Map} {x0 x1 : Host.Load.LSt}

theorem TraceNShift.ofShift (h : NShift P n0 σ x0 x1) (hb : NB ≤ P.NL) :
    TraceNShift P NB n0 σ x0 x1 :=
  ⟨h.host, h.hostReg, h.cbr, TraceMShift.ofShift h.mlx hb⟩

theorem TraceNShift.toShift (h : TraceNShift P NB n0 σ x0 x1)
    (hid : ∀ j, j < P.NL → σ.node j = j) : NShift P n0 σ x0 x1 :=
  ⟨h.host, h.hostReg, h.cbr, h.mlx.toShift hid⟩

theorem traceNShift_iff (hb : NB ≤ P.NL) :
    NShift P n0 σ x0 x1 ↔ TraceNShift P NB n0 σ x0 x1 ∧ (∀ j, j < P.NL → σ.node j = j) :=
  ⟨fun h => ⟨TraceNShift.ofShift h hb, h.mlx.nid⟩, fun h => h.1.toShift h.2⟩

theorem TraceNShift.withRest (h : TraceNShift P NB n0 σ x0 x1) (r : List NumV) :
    TraceNShift { P with rest := r } NB n0 σ x0 x1 :=
  ⟨h.host, h.hostReg, h.cbr, h.mlx.withRest r⟩
end

end Host.Ts.Sim.Conv
