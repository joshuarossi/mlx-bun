import host.sim.stage.Read
import host.mlx.Ffi
namespace Host.Ts.Sim.Stage
open Host.Ts

/-! # Stage contracts over the MLX FFI model

For stages that call mlx-c (`Host.Mlx.Ffi.ffi`, the FFI model of the route):

* the liveness layer the contracts state allocations and frees against (provisional, until the
  FFI liveness layer lands): a handle is live when it names a node (`mlxLive`; `mlx_array_free`
  resets its slot to `0`); `liveDelta_setAll`: a native state whose handle table is the call's
  updated at distinct handles `es` allocates the handles set to a node and frees those reset;
* `NodesKept`: the graph only grows (no existing node changes);
* readers of the JS objects a contract names: a property (`propOf`), the handle an `MlxArray`
  holds (`handleOf`, its `#handle`), and `ArrAt` (an object's property holds an `MlxArray` of a
  handle);
* `framedW_of`: the isolated frame of a template class whose return heap is the call heap with the
  written ranges `ws` and fresh entries replaced. -/

/-- The MLX FFI model. -/
abbrev MF : Ffi := Host.Mlx.Ffi.ffi

/-- A live MLX array handle: its slot names a node. -/
def mlxLive (x : Host.Mlx.Ffi.St) (h : Nat) : Prop := ∃ n, x.arrs.get h = some n ∧ n ≠ 0

/-- The graph only grows: every node below the call's node counter is unchanged. -/
def NodesKept (x y : Host.Mlx.Ffi.St) : Prop := ∀ n, n < x.nnext → y.nodes.get n = x.nodes.get n

theorem setAll_get_mem {α : Type} : ∀ (h : PTrie α) (es : List (Nat × α)) (a : Nat) (v : α),
    (es.map (·.1)).Nodup → (a, v) ∈ es → (∀ e ∈ es, e.1 / 4096 < 4 ^ 31) → (setAll h es).get a = some v
  | _, [], _, _, _, hm, _ => by cases hm
  | h, (b, w) :: es, a, v, hnd, hm, hs => by
    simp only [setAll]
    have hnd' := List.nodup_cons.mp hnd
    rcases List.mem_cons.mp hm with he | he
    · have hab : a = b := congrArg Prod.fst he
      have hvw : v = w := congrArg Prod.snd he
      subst hab; subst hvw
      have hnot : ∀ e ∈ es, e.1 ≠ a ∧ e.1 / 4096 < 4 ^ 31 := fun e he' =>
        ⟨fun h' => hnd'.1 (by have hm := List.mem_map_of_mem (f := fun p : Nat × α => p.1) he'; simpa [h'] using hm), hs e (List.mem_cons_of_mem _ he')⟩
      rw [setAll_get _ es a hnot]
      exact PTrie.get_set_self h a v (hs (a, v) (List.mem_cons_self ..))
    · exact setAll_get_mem (h.set b w) es a v hnd'.2 he (fun e he' => hs e (List.mem_cons_of_mem _ he'))

/-- **The live-set change of a handle-table update** at distinct small handles `es`: the handles
set to a node are allocated, those reset to `0` freed (a temporary allocated and freed within the
call is in neither live set). -/
theorem liveDelta_setAll {x y : Host.Mlx.Ffi.St} {es : List (Nat × Nat)} (hy : y.arrs = setAll x.arrs es)
    (hnd : (es.map (·.1)).Nodup) (hs : ∀ e ∈ es, e.1 / 4096 < 4 ^ 31) :
    LiveDelta (F := MF) mlxLive (fun h => ∃ n, (h, n) ∈ es ∧ n ≠ 0) (fun h => (h, 0) ∈ es) x y := by
  intro h
  by_cases hk : ∃ n, (h, n) ∈ es
  · obtain ⟨n, hn⟩ := hk
    have hg : y.arrs.get h = some n := by rw [hy]; exact setAll_get_mem _ es h n hnd hn hs
    have uniq : ∀ m, (h, m) ∈ es → m = n := fun m hm => by
      have := setAll_get_mem x.arrs es h m hnd hm hs
      rw [← hy, hg] at this
      exact (Option.some.inj this).symm
    have hl : mlxLive y h ↔ n ≠ 0 := by
      simp only [mlxLive, hg, Option.some.injEq]
      exact ⟨fun ⟨_, e, h0⟩ => e ▸ h0, fun h0 => ⟨n, rfl, h0⟩⟩
    rw [hl]
    constructor
    · intro h0; exact .inr ⟨n, hn, h0⟩
    · rintro (⟨_, h0⟩ | ⟨m, hm, hm0⟩)
      · intro e; exact h0 (e ▸ hn)
      · exact uniq m hm ▸ hm0
  · have hne : ∀ e ∈ es, e.1 ≠ h ∧ e.1 / 4096 < 4 ^ 31 := fun e he =>
      ⟨fun h' => hk ⟨e.2, h' ▸ he⟩, hs e he⟩
    have hg : y.arrs.get h = x.arrs.get h := by rw [hy]; exact setAll_get _ es h hne
    simp only [mlxLive, hg]
    constructor
    · intro hl; exact .inl ⟨hl, fun hm => hk ⟨0, hm⟩⟩
    · rintro (⟨hl, _⟩ | ⟨m, hm, _⟩)
      · exact hl
      · exact absurd ⟨m, hm⟩ hk

/-- Nodes only appended: the return graph is the call graph with its fresh nodes added. -/
theorem nodesKept_of {x y : Host.Mlx.Ffi.St} (hy : y.nodes = setAll x.nodes (freshOf y.nodes x.nnext y.nnext))
    (hsmall : Nat.blt y.nnext 1048576 = true) : NodesKept x y := by
  intro n hn
  rw [hy]
  refine setAll_get _ _ n fun e he => ?_
  have := mem_freshOf he
  have h4 : y.nnext < 1048576 := Nat.blt_eq.mp hsmall
  refine ⟨by omega, ?_⟩
  have : e.1 / 4096 < 256 := by omega
  exact Nat.lt_of_lt_of_le this (by decide)

/-- An object's data property `k`. -/
def propOf (o : Option Obj) (k : List Char) : Option Val :=
  o.bind fun ob => ob.props.findSome? fun q => match q with
    | (.str cs, .data v _ _) => bif cs == k then some v else none
    | _ => none

/-- The native handle an `MlxArray` object holds (its private `#handle`). -/
def handleOf (o : Option Obj) : Option Int :=
  o.bind fun ob => ob.priv.findSome? fun q => match q with
    | ((_, n), .data (.big i) _ _) => bif n == chars!"handle" then some i else none
    | _ => none

/-- The object at `a` holds at `k` an `MlxArray` of handle `h`. -/
def ArrAt {S : Type} (s : St S) (a : Nat) (k : List Char) (h : Int) : Prop :=
  ∃ b, propOf (s.obj? a) k = some (.obj b) ∧ handleOf (s.obj? b) = some h

/-- The entries of `h` at the ranges `ws`. -/
def rangesOf {α : Type} (h : PTrie α) : List (Nat × Nat) → List (Nat × α)
  | [] => []
  | (lo, hi) :: ws => freshOf h lo hi ++ rangesOf h ws

theorem mem_rangesOf {α : Type} {h : PTrie α} : ∀ {ws : List (Nat × Nat)} {e : Nat × α}, e ∈ rangesOf h ws →
    ∃ p ∈ ws, p.1 ≤ e.1 ∧ e.1 < p.2
  | [], _, he => by cases he
  | (lo, hi) :: ws, e, he => by
    rcases List.mem_append.mp he with h1 | h1
    · exact ⟨(lo, hi), List.mem_cons_self .., mem_freshOf h1⟩
    · obtain ⟨p, hp, hp'⟩ := mem_rangesOf h1
      exact ⟨p, List.mem_cons_of_mem _ hp, hp'⟩

/-- **The frame of a template class over a fixed native state**: the return heap is the call heap
with the written ranges `ws` and the fresh entries replaced, jobs, stores and trace the call's
(trace: new events in front), the native states related by `N`. -/
theorem framedW_of {s1 s3 : St Host.Mlx.Ffi.St} {m1 m3 : Nat} {ws : List (Nat × Nat)} {evs : List Event}
    {N : Host.Mlx.Ffi.St → Host.Mlx.Ffi.St → Prop}
    (hheap : s3.heap = setAll s1.heap (rangesOf s3.heap ws ++ freshOf s3.heap s1.next s3.next))
    (hnext : Nat.ble s1.next s3.next = true) (hsmall : Nat.blt s3.next 1048576 = true)
    (hws : ∀ p ∈ ws, Nat.blt p.2 1048576 = true)
    (hj : s3.aux.jobs = s1.aux.jobs) (hs : s3.aux.stores = s1.aux.stores) (ht : s3.aux.trace = evs ++ s1.aux.trace)
    (hN : N s1.aux.ffi s3.aux.ffi) :
    Framed (F := MF) (fun a => ∃ p ∈ ws, p.1 ≤ a ∧ a < p.2) N (tplN s1 m1 []) (tplN s3 m3 []) where
  next := Nat.le_of_ble_eq_true hnext
  heap a ha hw := by
    change a < s1.next at ha
    change s3.heap.get a = s1.heap.get a
    rw [hheap]
    refine setAll_get _ _ a fun e he => ?_
    have h4 : s3.next < 1048576 := Nat.blt_eq.mp hsmall
    rcases List.mem_append.mp he with h1 | h1
    · obtain ⟨p, hp, hp1, hp2⟩ := mem_rangesOf h1
      have hb : p.2 < 1048576 := Nat.blt_eq.mp (hws p hp)
      refine ⟨fun e' => hw ⟨p, hp, e' ▸ hp1, e' ▸ hp2⟩, ?_⟩
      have : e.1 / 4096 < 256 := by omega
      exact Nat.lt_of_lt_of_le this (by decide)
    · have := mem_freshOf h1
      refine ⟨by omega, ?_⟩
      have : e.1 / 4096 < 256 := by omega
      exact Nat.lt_of_lt_of_le this (by decide)
  jobs := hj
  stores := hs
  trace := ⟨evs, ht⟩
  ffi := hN

/-- A primitive's kind as numbers: reshape `[1]`, logsumexp `[2, axis]`, kernel output `[3, kernel, out]`,
replayed by closure `c` `4 :: c :: _`, zeros `[5]`, slice `[6]`, slice update `[7]`, concatenate `[8, axis]`, tracer
`[9, i]`, host data `[10]`, cast `[11, dtype]`, unary and binary operations `12 :: op`, `13 :: op` (the name's
character codes), `conv1d` `[14, stride, padding, dilation, groups]`, dynamic slice `15 :: axes` (`[0]` otherwise). -/
def primKey : Host.Mlx.Ffi.Prim → List Nat
  | .reshape _ => [1]
  | .logsumexp a _ => [2, a]
  | .kernel k _ o => [3, k, o]
  | .replayed c p => 4 :: c :: primKey p
  | .zeros => [5]
  | .slice .. => [6]
  | .sliceUpdate .. => [7]
  | .concat a => [8, a]
  | .tracer i => [9, i]
  | .data _ => [10]
  | .astype d => [11, d]
  | .unary op => 12 :: op.map Char.toNat
  | .binary op => 13 :: op.map Char.toNat
  | .conv1d s p d g => [14, s, p, d, g]
  | .sliceDynamic ax _ => 15 :: ax
  | _ => [0]

/-- The private field `k` of an object (`#k`). -/
def privOf (o : Option Obj) (k : List Char) : Option Val :=
  o.bind fun ob => ob.priv.findSome? fun q => match q with
    | ((_, n), .data v _ _) => bif n == k then some v else none
    | _ => none

/-- The object at `a` holds in its private field `k` an `MlxArray` of handle `h`. -/
def PrivArr {S : Type} (s : St S) (a : Nat) (k : List Char) (h : Int) : Prop :=
  ∃ b, privOf (s.obj? a) k = some (.obj b) ∧ handleOf (s.obj? b) = some h

/-- A node's kind, inputs, shape and dtype. -/
def nodeKey (y : Host.Mlx.Ffi.St) (n : Nat) : Option (List Nat × List Nat × List Host.Mlx.Ffi.Dim × Nat) :=
  (y.nodes.get n).map fun nd => (primKey nd.prim, nd.ins, nd.shape, nd.dtype)

/-- The name of a Metal kernel object. -/
def kernelName (y : Host.Mlx.Ffi.St) (k : Nat) : Option (List Char) :=
  match y.objs.get k with
  | some (.kernel n _ _ _ _) => some n
  | _ => none

/-- **`evalCacheState`'s postcondition** (generation/prefill.ts:12-14): no heap entry written, arrays and graph unchanged, three
events (newest first), the evaluated vector (at the call's next native handle) of nodes `ns`. -/
def EvalPost (ns : List Nat) (t t' : St Host.Mlx.Ffi.St) : Prop :=
  Framed (F := MF) (fun b => ∃ p ∈ ([] : List (Nat × Nat)), p.1 ≤ b ∧ b < p.2)
      (fun x y => y.arrs = x.arrs ∧ y.nodes = x.nodes) t t' ∧
    (t'.trace.take 3).map Event.sym = [chars!"mlx_vector_array_free", chars!"mlx_eval", chars!"mlx_vector_array_new_data"] ∧
    t'.aux.ffi.objs.get t.aux.ffi.next = some (.vec ns)

end Host.Ts.Sim.Stage
