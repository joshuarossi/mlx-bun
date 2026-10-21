import host.sim.Support
import host.sim.Free
import host.load.World
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Images of native (mlx model) data under a cross-iteration map

Handles are bigints (`M.handle`), graph nodes are named by `M.node`, numbers
by `M.nv`, JS buffers by `M.a`, native regions by `M.region`. A symbolic
dimension `Dim.sym x` is sent to the dimension the target reads for the
image number, `dimOf (M.nv x)` (a literal integer when the target's number
is one). Support is stated for an arbitrary predicate `R` on number
references, so the same lemmas serve closedness (`· < n`) and fresh
reference indices (`· ≠ j`). -/

abbrev NObj := Host.Mlx.Ffi.Obj
abbrev NSt := Host.Mlx.Ffi.St

namespace Map
variable (M : Map)

def dim : Dim → Dim
  | .lit i => .lit i
  | .sym x => dimOf (M.nv x)

def dims (ds : List Dim) : List Dim := ds.map M.dim

def cfg (c : Cfg) : Cfg :=
  ⟨c.outs.map fun (s, d) => (M.dims s, d), c.grid.map M.nv, c.group.map M.nv,
    c.ints.map fun (n, v) => (n, M.nv v), c.dtypes, c.init.map M.nv⟩

def prim : Prim → Prim
  | .data bs => .data (bs.map M.byte)
  | .load f k => .load f k
  | .tracer i => .tracer i
  | .zeros => .zeros
  | .arange a b c => .arange (M.nv a) (M.nv b) (M.nv c)
  | .reshape s => .reshape (M.dims s)
  | .transpose ax => .transpose ax
  | .slice a b c => .slice (M.dims a) (M.dims b) (M.dims c)
  | .sliceUpdate a b c => .sliceUpdate (M.dims a) (M.dims b) (M.dims c)
  | .sliceDynamic ax sz => .sliceDynamic ax (M.dims sz)
  | .concat a => .concat a
  | .unary op => .unary op
  | .binary op => .binary op
  | .astype d => .astype d
  | .contiguous => .contiguous
  | .rmsNorm e => .rmsNorm (M.nv e)
  | .rope d t b s o => .rope d t (M.arg b) (M.nv s) (M.nv o)
  | .sdpa s m => .sdpa (M.nv s) m
  | .qmm t g b m => .qmm t g b m
  | .dequantize g b m d => .dequantize g b m d
  | .take a => .take a
  | .conv1d a b c d => .conv1d a b c d
  | .logsumexp a k => .logsumexp a k
  | .kernel k c o => .kernel (M.handle k) (M.cfg c) o
  | .replayed c p => .replayed (M.handle c) (prim p)

def nnode (nd : Node) : Node := ⟨M.prim nd.prim, nd.ins.map M.node, M.dims nd.shape, nd.dtype⟩

def trace (t : Trace) : Trace := ⟨t.ins.map M.node, t.outs.map M.node, t.order.map M.node⟩

def clo : Clo → Clo
  | .empty => .empty
  | .fn cb p => .fn (M.region cb) (M.arg p)
  | .compiled cb p sl ts => .compiled (M.region cb) (M.arg p) sl (ts.map M.trace)

def nobj : NObj → NObj
  | .vec ns => .vec (ns.map M.node)
  | .cfg c => .cfg (M.cfg c)
  | .clo c => .clo (M.clo c)
  | o => o

def pend (p : Pending) : Pending :=
  ⟨M.handle p.id, M.a p.outBuf, p.outOff, M.handle p.outSlot, M.handle p.cls, p.ins.map M.node,
    p.tracers.map M.node, p.res.map (·.map M.node)⟩

/-- Shapes with dtypes, as shape inference sees them. -/
def shp (p : List Dim × Nat) : List Dim × Nat := (M.dims p.1, p.2)

theorem dim_dimOf (x : NumV) : M.dim (dimOf x) = dimOf (M.nv x) := by
  cases x with
  | ref _ => rfl
  | lit f =>
    unfold dimOf
    cases h : F64.toInt? f <;> simp [Map.dim, Map.nv, dimOf, h]

theorem dim_lit (i : Int) : M.dim (.lit i) = .lit i := rfl

end Map

/-! ## Support -/

section
variable (R : Nat → Prop)

def SN : NumV → Prop
  | .lit _ => True
  | .ref i => R i

def SD : Dim → Prop
  | .lit _ => True
  | .sym x => SN R x

def SDs (ds : List Dim) : Prop := ∀ d ∈ ds, SD R d

def SC : Cell → Prop
  | .num x => SN R x
  | .big _ => True

def SB : Byte → Prop
  | .lit _ => True
  | .part _ c _ => SC R c

def SBs (bs : List Byte) : Prop := ∀ b ∈ bs, SB R b

/-- Native-stored arguments are never `other` (the decoder never produces one). -/
def SA : Arg → Prop
  | .num x => SN R x
  | .jsPtr _ _ bs => SBs R bs
  | .other _ => False
  | _ => True

def SCfg (c : Cfg) : Prop :=
  (∀ p ∈ c.outs, SDs R p.1) ∧ (∀ x ∈ c.grid, SN R x) ∧ (∀ x ∈ c.group, SN R x) ∧
    (∀ p ∈ c.ints, SN R p.2) ∧ (∀ x, c.init = some x → SN R x)

def SP : Prim → Prop
  | .data bs => SBs R bs
  | .arange a b c => SN R a ∧ SN R b ∧ SN R c
  | .reshape s => SDs R s
  | .slice a b c => SDs R a ∧ SDs R b ∧ SDs R c
  | .sliceUpdate a b c => SDs R a ∧ SDs R b ∧ SDs R c
  | .sliceDynamic _ sz => SDs R sz
  | .rmsNorm e => SN R e
  | .rope _ _ b s o => SA R b ∧ SN R s ∧ SN R o
  | .sdpa s _ => SN R s
  | .kernel _ c _ => SCfg R c
  | .replayed _ p => SP p
  | _ => True

def SNode (nd : Node) : Prop := SP R nd.prim ∧ SDs R nd.shape

def SClo : Clo → Prop
  | .empty => True
  | .fn _ p => SA R p
  | .compiled _ p _ _ => SA R p

def SObj : NObj → Prop
  | .cfg c => SCfg R c
  | .clo c => SClo R c
  | _ => True
end

/-! ## Agreement: maps that share names and agree on the supported references -/

structure NAgree (R : Nat → Prop) (M M' : Map) : Prop where
  a : M'.a = M.a
  big : M'.big = M.big
  region : M'.region = M.region
  node : M'.node = M.node
  num : ∀ i, R i → M'.num i = M.num i

theorem NAgree.ofExt {M M' : Map} {n : Nat} (h : Ext M M' n) : NAgree (· < n) M M' :=
  ⟨h.a, h.big, h.region, h.node, h.num⟩

theorem NAgree.setNum (M : Map) (j : Nat) (v : NumV) : NAgree (· ≠ j) M (M.setNum j v) :=
  ⟨rfl, rfl, rfl, rfl, fun i hi => by
    show (bif Nat.beq i j then v else M.num i) = M.num i
    cases h : Nat.beq i j
    · rfl
    · exact absurd (Nat.eq_of_beq_eq_true h) hi⟩

section
variable {R : Nat → Prop} {M M' : Map} (h : NAgree R M M')
include h

theorem NAgree.handle (x : Nat) : M'.handle x = M.handle x := by simp [Map.handle, h.big]

theorem NAgree.nv {x : NumV} (hx : SN R x) : M'.nv x = M.nv x := by
  cases x with
  | lit _ => rfl
  | ref i => exact h.num i hx

theorem NAgree.dim {d : Dim} (hd : SD R d) : M'.dim d = M.dim d := by
  cases d with
  | lit _ => rfl
  | sym x => simp only [Map.dim, h.nv hd]

theorem NAgree.dims {ds : List Dim} (hd : SDs R ds) : M'.dims ds = M.dims ds :=
  List.map_congr_left fun d hm => h.dim (hd d hm)

theorem NAgree.byte {b : Byte} (hb : SB R b) : M'.byte b = M.byte b := by
  cases b with
  | lit _ => rfl
  | part k c i =>
    cases c with
    | num x => simp only [Map.byte, Map.cell, h.nv hb]
    | big j => simp only [Map.byte, Map.cell, h.big]

theorem NAgree.bytes {bs : List Byte} (hb : SBs R bs) : bs.map M'.byte = bs.map M.byte :=
  List.map_congr_left fun b hm => h.byte (hb b hm)

theorem NAgree.arg {a : Arg} (ha : SA R a) : M'.arg a = M.arg a := by
  cases a with
  | null => rfl
  | num x => simp only [Map.arg, h.nv ha]
  | big i => simp only [Map.arg, h.big]
  | bool _ => rfl
  | jsPtr b o bs => simp only [Map.arg, h.a, h.bytes ha]
  | extPtr r o => simp only [Map.arg, h.region]
  | other _ => exact ha.elim

theorem NAgree.cfg {c : Cfg} (hc : SCfg R c) : M'.cfg c = M.cfg c := by
  obtain ⟨h1, h2, h3, h4, h5⟩ := hc
  unfold Map.cfg
  congr 1
  · exact List.map_congr_left fun ⟨s, d⟩ hm => by simp only [h.dims (h1 _ hm)]
  · exact List.map_congr_left fun x hm => h.nv (h2 x hm)
  · exact List.map_congr_left fun x hm => h.nv (h3 x hm)
  · exact List.map_congr_left fun ⟨m, v⟩ hm => by simp only [h.nv (h4 _ hm)]
  · cases hi : c.init with
    | none => rfl
    | some x => simp only [Option.map_some, h.nv (h5 x hi)]

theorem NAgree.prim {p : Prim} (hp : SP R p) : M'.prim p = M.prim p := by
  induction p with
  | data _ => simp only [Map.prim, h.bytes hp]
  | arange _ _ _ => simp only [Map.prim, h.nv hp.1, h.nv hp.2.1, h.nv hp.2.2]
  | reshape _ => simp only [Map.prim, h.dims hp]
  | slice _ _ _ => simp only [Map.prim, h.dims hp.1, h.dims hp.2.1, h.dims hp.2.2]
  | sliceUpdate _ _ _ => simp only [Map.prim, h.dims hp.1, h.dims hp.2.1, h.dims hp.2.2]
  | sliceDynamic _ _ => simp only [Map.prim, h.dims hp]
  | rmsNorm _ => simp only [Map.prim, h.nv hp]
  | rope _ _ _ _ _ => simp only [Map.prim, h.arg hp.1, h.nv hp.2.1, h.nv hp.2.2]
  | sdpa _ _ => simp only [Map.prim, h.nv hp]
  | kernel _ _ _ => simp only [Map.prim, h.handle, h.cfg hp]
  | replayed _ _ ih => simp only [Map.prim, h.handle, ih hp]
  | _ => rfl

theorem NAgree.nnode {nd : Node} (hn : SNode R nd) : M'.nnode nd = M.nnode nd := by
  simp only [Map.nnode, h.prim hn.1, h.dims hn.2, h.node]

theorem NAgree.trace (t : Trace) : M'.trace t = M.trace t := by
  simp only [Map.trace, h.node]

theorem NAgree.clo {c : Clo} (hc : SClo R c) : M'.clo c = M.clo c := by
  cases c with
  | empty => rfl
  | fn cb p => simp only [Map.clo, h.region, h.arg hc]
  | compiled cb p sl ts => simp only [Map.clo, h.region, h.arg hc, funext h.trace]

theorem NAgree.nobj {o : NObj} (ho : SObj R o) : M'.nobj o = M.nobj o := by
  cases o <;> simp_all only [Map.nobj, SObj, h.node, h.cfg, h.clo]

theorem NAgree.pend (p : Pending) : M'.pend p = M.pend p := by
  simp only [Map.pend, h.handle, h.a, h.node]

end

/-! ## Monotonicity of support -/

section
variable {R R' : Nat → Prop} (hR : ∀ i, R i → R' i)
include hR

theorem SN.mono {x : NumV} (hx : SN R x) : SN R' x := by
  cases x with
  | lit _ => trivial
  | ref i => exact hR i hx

theorem SD.mono {d : Dim} (hd : SD R d) : SD R' d := by
  cases d with
  | lit _ => trivial
  | sym x => exact SN.mono hR hd

theorem SDs.mono {ds : List Dim} (hd : SDs R ds) : SDs R' ds := fun d hm => SD.mono hR (hd d hm)

theorem SB.mono {b : Byte} (hb : SB R b) : SB R' b := by
  cases b with
  | lit _ => trivial
  | part k c i =>
    cases c with
    | num x => exact SN.mono hR hb
    | big _ => trivial

theorem SBs.mono {bs : List Byte} (hb : SBs R bs) : SBs R' bs := fun b hm => SB.mono hR (hb b hm)

theorem SA.mono {a : Arg} (ha : SA R a) : SA R' a := by
  cases a with
  | num x => exact SN.mono hR ha
  | jsPtr _ _ bs => exact SBs.mono hR ha
  | other _ => exact ha.elim
  | _ => trivial

theorem SCfg.mono {c : Cfg} (hc : SCfg R c) : SCfg R' c :=
  ⟨fun p hm => SDs.mono hR (hc.1 p hm), fun x hm => SN.mono hR (hc.2.1 x hm),
    fun x hm => SN.mono hR (hc.2.2.1 x hm), fun p hm => SN.mono hR (hc.2.2.2.1 p hm),
    fun x hx => SN.mono hR (hc.2.2.2.2 x hx)⟩

theorem SP.mono {p : Prim} (hp : SP R p) : SP R' p := by
  induction p with
  | data _ => exact SBs.mono hR hp
  | arange _ _ _ => exact ⟨SN.mono hR hp.1, SN.mono hR hp.2.1, SN.mono hR hp.2.2⟩
  | reshape _ => exact SDs.mono hR hp
  | slice _ _ _ => exact ⟨SDs.mono hR hp.1, SDs.mono hR hp.2.1, SDs.mono hR hp.2.2⟩
  | sliceUpdate _ _ _ => exact ⟨SDs.mono hR hp.1, SDs.mono hR hp.2.1, SDs.mono hR hp.2.2⟩
  | sliceDynamic _ _ => exact SDs.mono hR hp
  | rmsNorm _ => exact SN.mono hR hp
  | rope _ _ _ _ _ => exact ⟨SA.mono hR hp.1, SN.mono hR hp.2.1, SN.mono hR hp.2.2⟩
  | sdpa _ _ => exact SN.mono hR hp
  | kernel _ _ _ => exact SCfg.mono hR hp
  | replayed _ _ ih => exact ih hp
  | _ => trivial

theorem SNode.mono {nd : Node} (hn : SNode R nd) : SNode R' nd := ⟨SP.mono hR hn.1, SDs.mono hR hn.2⟩

theorem SClo.mono {c : Clo} (hc : SClo R c) : SClo R' c := by
  cases c with
  | empty => trivial
  | fn _ p => exact SA.mono hR hc
  | compiled _ p _ _ => exact SA.mono hR hc

theorem SObj.mono {o : NObj} (ho : SObj R o) : SObj R' o := by
  cases o with
  | cfg c => exact SCfg.mono hR ho
  | clo c => exact SClo.mono hR ho
  | _ => trivial

end

/-! ## Composition: `σ`, then `M` -/

section
variable (M σ : Map)

/-- Handles compose when `σ` keeps them nonnegative (`toNat` clamps). -/
theorem Map.handle_after {h : Nat} (hp : 0 ≤ σ.big (Int.ofNat h)) :
    M.handle (σ.handle h) = (M.after σ).handle h := by
  show (M.big (Int.ofNat (σ.big (Int.ofNat h)).toNat)).toNat = (M.big (σ.big (Int.ofNat h))).toNat
  rw [show Int.ofNat (σ.big (Int.ofNat h)).toNat = σ.big (Int.ofNat h) from Int.toNat_of_nonneg hp]

theorem Map.dim_after (d : Dim) : M.dim (σ.dim d) = (M.after σ).dim d := by
  cases d with
  | lit _ => rfl
  | sym x =>
    show M.dim (dimOf (σ.nv x)) = dimOf ((M.after σ).nv x)
    rw [Map.dim_dimOf, Map.nv_after]

theorem Map.dims_after (ds : List Dim) : M.dims (σ.dims ds) = (M.after σ).dims ds := by
  simp only [Map.dims, List.map_map]
  exact List.map_congr_left fun d _ => Map.dim_after M σ d

theorem Map.cfg_after (c : Cfg) : M.cfg (σ.cfg c) = (M.after σ).cfg c := by
  simp only [Map.cfg, List.map_map, Option.map_map]
  congr 1
  · exact List.map_congr_left fun p _ => by simp [Map.dims_after]
  · exact List.map_congr_left fun x _ => Map.nv_after M σ x
  · exact List.map_congr_left fun x _ => Map.nv_after M σ x
  · exact List.map_congr_left fun p _ => by simp [Map.nv_after]
  · congr 1; funext x; exact Map.nv_after M σ x

/-- Handles named in a primitive. -/
def primHandles : Prim → List Nat
  | .kernel k _ _ => [k]
  | .replayed c p => c :: primHandles p
  | _ => []

theorem Map.prim_after (p : Prim) (hh : ∀ h ∈ primHandles p, 0 ≤ σ.big (Int.ofNat h)) :
    M.prim (σ.prim p) = (M.after σ).prim p := by
  induction p with
  | data bs =>
    simp only [Map.prim, List.map_map]; congr 1
    exact List.map_congr_left fun b _ => Map.byte_after M σ b
  | arange _ _ _ => simp only [Map.prim, Map.nv_after]
  | reshape _ => simp only [Map.prim, Map.dims_after]
  | slice _ _ _ => simp only [Map.prim, Map.dims_after]
  | sliceUpdate _ _ _ => simp only [Map.prim, Map.dims_after]
  | sliceDynamic _ _ => simp only [Map.prim, Map.dims_after]
  | rmsNorm _ => simp only [Map.prim, Map.nv_after]
  | rope _ _ _ _ _ => simp only [Map.prim, Map.nv_after, Map.arg_after]
  | sdpa _ _ => simp only [Map.prim, Map.nv_after]
  | kernel k _ _ =>
    simp only [Map.prim, Map.cfg_after, Map.handle_after M σ (hh k (List.mem_singleton_self k))]
  | replayed c p ih =>
    simp only [Map.prim, Map.handle_after M σ (hh c (List.mem_cons_self ..)),
      ih (fun h hm => hh h (List.mem_cons_of_mem _ hm))]
  | _ => rfl

theorem Map.trace_after (t : Trace) : M.trace (σ.trace t) = (M.after σ).trace t := by
  simp only [Map.trace, List.map_map]; rfl

theorem Map.clo_after (c : Clo) : M.clo (σ.clo c) = (M.after σ).clo c := by
  cases c with
  | empty => rfl
  | fn cb p => simp only [Map.clo, Map.after_region, Map.arg_after]
  | compiled cb p sl ts =>
    simp only [Map.clo, Map.after_region, Map.arg_after, List.map_map]
    congr 1
    exact List.map_congr_left fun t _ => Map.trace_after M σ t

theorem Map.nobj_after (o : NObj) : M.nobj (σ.nobj o) = (M.after σ).nobj o := by
  cases o with
  | vec ns => simp only [Map.nobj, List.map_map]; rfl
  | cfg c => simp only [Map.nobj, Map.cfg_after]
  | clo c => simp only [Map.nobj, Map.clo_after]
  | _ => rfl

theorem Map.nnode_after (nd : Node) (hh : ∀ h ∈ primHandles nd.prim, 0 ≤ σ.big (Int.ofNat h)) :
    M.nnode (σ.nnode nd) = (M.after σ).nnode nd := by
  simp only [Map.nnode, Map.prim_after M σ nd.prim hh, Map.dims_after, List.map_map]; rfl

theorem Map.pend_after (p : Pending) (hh : ∀ h ∈ [p.id, p.outSlot, p.cls], 0 ≤ σ.big (Int.ofNat h)) :
    M.pend (σ.pend p) = (M.after σ).pend p := by
  simp only [Map.pend, Option.map_map, List.map_map, Map.after_a]
  rw [Map.handle_after M σ (hh _ (by simp)), Map.handle_after M σ (hh _ (by simp)),
    Map.handle_after M σ (hh _ (by simp))]
  congr 1
  cases p.res <;> simp [Function.comp_def, Map.after]

end
end Host.Ts.Sim
