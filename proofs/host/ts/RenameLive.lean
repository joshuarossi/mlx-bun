import host.ts.RenameNative
namespace Host.Ts.NameMap
open Host.Mlx.Ffi
variable {mode : NumMode} (R : NameMap mode)

def dim : Dim → Dim
  | .lit i => .lit i
  | .sym n => match mode with
    | .refs => .sym (R.num n)
    | .concrete _ => dimOf (R.num n)

def cfg (c : Cfg) : Cfg :=
  ⟨c.outs.map (fun (s, d) => (s.map R.dim, d)), c.grid.map R.num, c.group.map R.num,
    c.ints.map (fun (n, v) => (n, R.num v)), c.dtypes, c.init.map R.num⟩

def prim : Prim → Prim
  | .data bs => .data (bs.map R.byte)
  | .load f k => .load f k
  | .tracer i => .tracer i
  | .zeros => .zeros
  | .arange a b c => .arange (R.num a) (R.num b) (R.num c)
  | .reshape sh => .reshape (sh.map R.dim)
  | .transpose ax => .transpose ax
  | .slice a b c => .slice (a.map R.dim) (b.map R.dim) (c.map R.dim)
  | .sliceUpdate a b c => .sliceUpdate (a.map R.dim) (b.map R.dim) (c.map R.dim)
  | .sliceDynamic ax sh => .sliceDynamic ax (sh.map R.dim)
  | .concat ax => .concat ax
  | .unary op => .unary op
  | .binary op => .binary op
  | .astype dt => .astype dt
  | .contiguous => .contiguous
  | .rmsNorm e => .rmsNorm (R.num e)
  | .rope d tr b sc off => .rope d tr (R.arg b) (R.num sc) (R.num off)
  | .sdpa sc m => .sdpa (R.num sc) m
  | .qmm tr g b m => .qmm tr g b m
  | .dequantize g b m d => .dequantize g b m d
  | .take ax => .take ax
  | .conv1d st pd dl gr => .conv1d st pd dl gr
  | .logsumexp ax k => .logsumexp ax k
  | .kernel k c o => .kernel (R.handle k) (R.cfg c) o
  | .replayed c p => .replayed (R.handle c) (prim p)

def nativeTrace (t : Trace) : Trace := ⟨t.ins.map R.node, t.outs.map R.node, t.order.map R.node⟩

def nativeClo : Clo → Clo
  | .empty => .empty
  | .fn cb p => .fn (R.region cb) (R.arg p)
  | .compiled cb p sl ts => .compiled (R.region cb) (R.arg p) sl (ts.map R.nativeTrace)

def nativeObj : Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj
  | .stream => .stream
  | .str s => .str s
  | .vec ns => .vec (ns.map R.node)
  | .vstr n => .vstr n
  | .kernel n s h i o => .kernel n s h i o
  | .cfg c => .cfg (R.cfg c)
  | .clo c => .clo (R.nativeClo c)
  | .amap f => .amap f
  | .smap => .smap
  | .device => .device
  | .dinfo => .dinfo

def nativePending (p : Pending) : Pending :=
  ⟨R.handle p.id, R.a p.outBuf, p.outOff, R.handle p.outSlot, R.handle p.cls,
    p.ins.map R.node, p.tracers.map R.node, p.res.map (List.map R.node)⟩

end Host.Ts.NameMap

attribute [reducible] Host.Ts.NameMap.dim Host.Ts.NameMap.cfg Host.Ts.NameMap.prim
  Host.Ts.NameMap.nativeTrace Host.Ts.NameMap.nativeClo Host.Ts.NameMap.nativeObj Host.Ts.NameMap.nativePending

namespace Host.Ts.Ren
open Host.Mlx.Ffi
abbrev dim (R : Ren) := NameMap.dim R
abbrev cfg (R : Ren) := NameMap.cfg R
abbrev prim (R : Ren) := NameMap.prim R
abbrev nativeTrace (R : Ren) := NameMap.nativeTrace R
abbrev nativeClo (R : Ren) := NameMap.nativeClo R
abbrev nativeObj (R : Ren) := NameMap.nativeObj R
abbrev nativePending (R : Ren) := NameMap.nativePending R
theorem dim_num (R : Ren) (d : Dim) : (R.dim d).num = R.num d.num := by cases d <;> rfl
end Host.Ts.Ren

namespace Host.Mlx.Ffi
open Host.Ts

/-- A live input node is opaque below the cut: its shape and dtype are observable by
native operations. Other live nodes additionally retain their producing primitive and inputs. -/
structure NodeR (R : Ren) (boundary : Prop) (n n' : Node) : Prop where
  shape : n'.shape = n.shape.map R.dim
  dtype : n'.dtype = n.dtype
  graph : boundary ∨ (n'.prim = R.prim n.prim ∧ n'.ins = n.ins.map R.node)

inductive NodeSlotR (R : Ren) (boundary : Prop) : Option Node → Option Node → Prop
  | absent : NodeSlotR R boundary none none
  | present {n n'} : NodeR R boundary n n' → NodeSlotR R boundary (some n) (some n')

/-- Only resources reachable from the loop cut are compared. Earlier allocations may
remain as garbage in either state. `tail` is the future iterations' unread token sequence. -/
structure LiveNative (R : Ren) (liveH liveN boundary : Nat → Prop) (tail : List NumV)
    (s s' : St) : Prop where
  arrs : ∀ h, liveH h → s'.arrs.get (R.handle h) = (s.arrs.get h).map R.node
  objs : ∀ h, liveH h → s'.objs.get (R.handle h) = (s.objs.get h).map R.nativeObj
  nodes : ∀ i, liveN i → NodeSlotR R (boundary i) (s.nodes.get i) (s'.nodes.get (R.node i))
  arrLive : ∀ h i, liveH h → s.arrs.get h = some i → liveN i
  items : ∀ i, liveN i → s'.items.get (R.node i) = (s.items.get i).map R.num
  tokens : s'.tokens = s.tokens.map R.num ++ tail
  pending : s'.pending = s.pending.map R.nativePending
  errh : s'.errh = s.errh.map R.arg
  files : s'.files = s.files
  arch : s'.arch = s.arch
  deviceSizes : s'.deviceSizes = s.deviceSizes
  wired : s'.wired = s.wired
  handleNonneg : ∀ h, liveH h → 0 ≤ R.big (Int.ofNat h)
  liveHandleBound : ∀ h, liveH h → h < s.next
  liveNodeBound : ∀ i, liveN i → i < s.nnext
  handleBound : ∀ h, h < s.next → R.handle h < s'.next
  nodeBound : ∀ i, i < s.nnext → R.node i < s'.nnext
  sourceItemsBound : ∀ i t, s.items.get i = some t → i < s.nnext
  targetItemsBound : ∀ i t, s'.items.get i = some t → i < s'.nnext
  sourceObjsBound : ∀ i o, s.objs.get i = some o → i < s.next
  targetObjsBound : ∀ i o, s'.objs.get i = some o → i < s'.next
  sourceArrsBound : ∀ i n, s.arrs.get i = some n → i < s.next
  targetArrsBound : ∀ i n, s'.arrs.get i = some n → i < s'.next
  handleInj : ∀ h k, h < s.next → k < s.next → R.handle h = R.handle k → h = k
  nodeInj : ∀ i j, i < s.nnext → j < s.nnext → R.node i = R.node j → i = j
  handleFresh : ∀ k, R.handle (s.next + k) = s'.next + k
  bigFresh : ∀ k, R.big (Int.ofNat (s.next + k)) = Int.ofNat (s'.next + k)
  nodeFresh : ∀ k, R.node (s.nnext + k) = s'.nnext + k
  handleZero : R.handle 0 = 0

namespace LiveNative

theorem node_view {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') {i : Nat} (hi : N i) {n : Node}
    (hn : s.nodes.get i = some n) :
    ∃ n', s'.nodes.get (R.node i) = some n' ∧ NodeR R (O i) n n' := by
  have hv := h.nodes i hi
  rw [hn] at hv
  cases ht : s'.nodes.get (R.node i) with
  | none => rw [ht] at hv; cases hv
  | some n' =>
    rw [ht] at hv
    cases hv with
    | present hv => exact ⟨n', rfl, hv⟩

theorem nodeId? {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') {a : Nat} (ha : H a) (hab : a < s.next)
    (hzero : 0 < s.next) : s'.nodeId? (R.handle a) = (s.nodeId? a).map R.node := by
  unfold St.nodeId?
  by_cases hz : a = 0
  · subst a
    simp only [h.handleZero, Nat.beq_refl, Bool.cond_true, Option.map_none]
  · have hz' : R.handle a ≠ 0 := by
      intro he
      have heq : R.handle a = R.handle 0 := by rw [h.handleZero]; exact he
      exact hz (h.handleInj a 0 hab hzero heq)
    have hb : Nat.beq a 0 = false := by
      cases ht : Nat.beq a 0
      · rfl
      · exact False.elim (hz (Nat.eq_of_beq_eq_true ht))
    have hb' : Nat.beq (R.handle a) 0 = false := by
      cases ht : Nat.beq (R.handle a) 0
      · rfl
      · exact False.elim (hz' (Nat.eq_of_beq_eq_true ht))
    simp only [hb, hb', Bool.cond_false, h.arrs a ha]

theorem node? {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') {a : Nat} (ha : H a) {n : Node}
    (hn : s.node? a = some n) :
    ∃ n', s'.node? (R.handle a) = some n' ∧ n'.shape = n.shape.map R.dim ∧ n'.dtype = n.dtype := by
  unfold St.node? at hn ⊢
  rw [h.arrs a ha]
  cases hs : s.arrs.get a with
  | none => simp [hs] at hn
  | some i =>
    simp only [hs, Option.bind_some] at hn
    obtain ⟨n', ht, hv⟩ := h.node_view (h.arrLive a i ha hs) hn
    exact ⟨n', by simp only [Option.map_some, Option.bind_some, ht], hv.shape, hv.dtype⟩

theorem shapesOf {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') : ∀ (is : List Nat) (sh : List (List Dim × Nat)),
    (∀ i ∈ is, N i) → Host.Mlx.Ffi.shapesOf s is = some sh →
    Host.Mlx.Ffi.shapesOf s' (is.map R.node) = some (sh.map fun (s, d) => (s.map R.dim, d))
  | [], sh, _, hr => by
    simp only [Host.Mlx.Ffi.shapesOf, Option.some.injEq] at hr
    subst sh
    rfl
  | i :: is, sh, hi, hr => by
    simp only [Host.Mlx.Ffi.shapesOf] at hr
    cases hn : s.nodes.get i with
    | none => simp [hn] at hr
    | some n =>
      simp only [hn, Option.bind_some] at hr
      cases hs : Host.Mlx.Ffi.shapesOf s is with
      | none => simp [hs] at hr
      | some ss =>
        simp only [hs, Option.map_some, Option.some.injEq] at hr
        subst sh
        obtain ⟨n', ht, hv⟩ := h.node_view (hi i (by simp)) hn
        have htail := h.shapesOf is ss (fun j hj => hi j (by simp [hj])) hs
        simp only [List.map_cons, Host.Mlx.Ffi.shapesOf, ht, Option.bind_some,
          htail, Option.map_some, hv.shape, hv.dtype]

end LiveNative
end Host.Mlx.Ffi
