import host.sim.Support
import host.sim.Num
namespace Host.Ts.Sim

/-- The bound on source counters the checked runs enforce; with the offset `D < bound`
every target address stays below `2 ^ 62` (the stores' addressing range). -/
def bound : Nat := 2 ^ 61

/-! # The cross-iteration state relation

`Rel` relates a source (template) state `s` under the symbolic server `S` to
a target state `t` under the concrete server `C`: every heap entry present
in the source has its image at the mapped address of the target (the
target may hold more: garbage of earlier iterations), and control, stack,
jobs, stores and the events since the bases are images. Arrays at `framed`
addresses (output arrays a loop only appends to) keep their own prefixes on
each side; only the elements appended since the bases correspond.

The source is closed: its data mentions only present addresses and
allocated number references, so extending the map at fresh references or
addresses leaves every image unchanged. -/

def Present {S : Type} (s : St S) (a : Nat) : Prop := (s.heap.get a).isSome = true

/-- A framed array: both prefixes are fixed, the suffix appended since then corresponds. -/
def FramedObj (M : Map) (pre pre' : List Val) (o o' : Obj) : Prop :=
  ∃ xs, o.kind = .array (pre ++ xs) ∧ o' = { M.obj o with kind := .array (pre' ++ M.vals xs) }

/-- A heap entry of the target corresponding to a present source entry. -/
def SlotOK (M : Map) (fr : Nat → Option (List Val × List Val)) (a : Nat) (h : HObj) (h' : Option HObj) : Prop :=
  match fr a with
  | none => h' = some (M.hobj h)
  | some (pre, pre') => ∃ o o', h = .obj o ∧ h' = some (.obj o') ∧ FramedObj M pre pre' o o'

/-! ## Frames beyond framed arrays

A run may also frame (design `host-L-design.md` §1.2, §3.6 item 4):

* a **buffer** or a **typed array** the target holds with its own bytes or length (the
  prompt chunk's `Int32Array`); the template holds an `ordinary` placeholder, so no reader
  that derives a buffer's or typed array's frame from its kind ever meets one;
* a **ghost** cell or object: any target cell, or any target object of a kind frames admit (memos
  only some histories fill); the template side must not hold live native handles there;
* **ghost fields**: an object whose properties at keys `ks` and private members at `ps` are
  unconstrained (and may be absent on either side), the rest images in order;
* a **`Map` by key**: each string key the source holds the target holds too, with the image of
  the source's first value at it (any value at the ghost key codes `gs`); the target may hold more;
* a **`Map` memo**: a `Map` by key whose target holds no further string key outside the ghost
  codes `gs` (a key the source lacks and no ghost is absent on both sides), so `get` and `has` of
  such keys agree.

Their addresses are framed (`Ctx.fr` is `some`, its payload unused there), so an accepted step
never reads them as unframed; the frames are a parameter `W` of `RelF`, and `Rel` is `RelF`
without them. -/

inductive WFrame where
  | buf (bs' : List Byte)
  | typed (k : EltK) (b off n' : Nat)
  | ghost
  | fields (ks : List PKey) (ps : List (Nat × Name))
  | mapKeys (gs : List Nat)
  | memo (gs : List Nat)

/-- Kinds a ghost object or a ghost-field object may have (never one whose readers derive its
frame from its kind: arrays, functions, promises, generators, buffers, typed arrays, views). -/
def Wideable : Kind → Prop
  | .ordinary | .map _ | .box _ => True
  | _ => False

/-- Kinds a target object under a frame may have: those `Wideable` admits, a buffer, a typed array. -/
def WTarget (k : Kind) : Prop :=
  Wideable k ∨ (∃ bs, k = .buf bs) ∨ ∃ kk b off n, k = .typed kk b off n

/-- Property lists that are images except at ghost keys, which either side may hold anywhere. -/
inductive PropsW (M : Map) (ks : List PKey) : Props → Props → Prop
  | nil : PropsW M ks [] []
  | both (k : PKey) (p p' : PropV) (l l' : Props) : k ∉ ks → p' = M.prop p → PropsW M ks l l' →
      PropsW M ks ((k, p) :: l) ((M.key k, p') :: l')
  | ghostL (k : PKey) (p : PropV) (l l' : Props) : k ∈ ks → PropsW M ks l l' → PropsW M ks ((k, p) :: l) l'
  | ghostR (k : PKey) (p' : PropV) (l l' : Props) : (∃ k0 ∈ ks, M.key k0 = k) → PropsW M ks l l' →
      PropsW M ks l ((k, p') :: l')

/-- Private member lists that are images except at ghost names. -/
inductive PrivsW (M : Map) (ps : List (Nat × Name)) :
    List ((Nat × Name) × PropV) → List ((Nat × Name) × PropV) → Prop
  | nil : PrivsW M ps [] []
  | both (b : Nat) (n : Name) (p p' : PropV) (l l' : List ((Nat × Name) × PropV)) : (b, n) ∉ ps →
      p' = M.prop p → PrivsW M ps l l' → PrivsW M ps (((b, n), p) :: l) (((M.a b, n), p') :: l')
  | ghostL (b : Nat) (n : Name) (p : PropV) (l l' : List ((Nat × Name) × PropV)) : (b, n) ∈ ps →
      PrivsW M ps l l' → PrivsW M ps (((b, n), p) :: l) l'
  | ghostR (b' : Nat) (n : Name) (p' : PropV) (l l' : List ((Nat × Name) × PropV)) :
      (∃ b, (b, n) ∈ ps ∧ M.a b = b') → PrivsW M ps l l' → PrivsW M ps l (((b', n), p') :: l')

/-- `Map` entries related by string key (the first value at each key code, as `get` reads it). -/
def MapW (M : Map) (gs : List Nat) (es es' : List (Val × Val)) : Prop :=
  ∀ c v, StringIndex.firstValue c es = some v → ∃ v', StringIndex.firstValue c es' = some v' ∧ (c ∈ gs ∨ v' = M.val v)

/-- String keys the source lacks are absent on the target too, except at the ghost codes `gs`. -/
def MapNone (gs : List Nat) (es es' : List (Val × Val)) : Prop :=
  ∀ c, c ∉ gs → StringIndex.firstValue c es = none → StringIndex.firstValue c es' = none

/-- The target entry of a source entry under a frame. -/
def WideOK (M : Map) : WFrame → HObj → Option HObj → Prop
  | .buf bs', .obj o, some (.obj o') => o.kind = .ordinary ∧ o' = { M.obj o with kind := .buf bs' }
  | .typed k b off n', .obj o, some (.obj o') =>
    o.kind = .ordinary ∧ o' = { M.obj o with kind := .typed k (M.a b) off n' }
  | .ghost, .obj o, some (.obj o') => Wideable o.kind ∧ Wideable o'.kind
  | .ghost, .cell _, some (.cell _) => True
  | .fields ks ps, .obj o, some (.obj o') => Wideable o.kind ∧ o'.kind = M.kind o.kind ∧
    o'.proto = M.val o.proto ∧ o'.extensible = o.extensible ∧ PropsW M ks o.props o'.props ∧
    PrivsW M ps o.priv o'.priv
  | .mapKeys gs, .obj o, some (.obj o') =>
    ∃ es es', o.kind = .map es ∧ o' = { M.obj o with kind := .map es' } ∧ MapW M gs es es'
  | .memo gs, .obj o, some (.obj o') =>
    ∃ es es', o.kind = .map es ∧ o' = { M.obj o with kind := .map es' } ∧ MapW M gs es es' ∧ MapNone gs es es'
  | _, _, _ => False

/-- The fixed parameters of a run's relation: framed arrays with their two prefixes,
the event bases, the counter offset and the band `[lo, hi)` of renamed native handles. -/
structure Ctx where
  fr : Nat → Option (List Val × List Val)
  base : List Event
  base' : List Event
  D : Nat
  lo : Nat
  hi : Nat

/-- Bigints the map fixes: negative, below the renamed handle band, or between the
band and the pointer integers (`ptrInt` values are at least `2 ^ 56`). -/
def BigFixed (lo hi : Nat) (i : Int) : Prop :=
  i < 0 ∨ (0 ≤ i ∧ i < lo) ∨ ((hi : Int) ≤ i ∧ i < 2 ^ 56)

/-- A heap entry of the target under the frames: at an unframed address the image, at a framed
one a framed array (`SlotOK`) or the frame `W a`. -/
def SlotW (M : Map) (fr : Nat → Option (List Val × List Val)) (W : Nat → Option WFrame) (a : Nat)
    (h : HObj) (h' : Option HObj) : Prop :=
  match W a with
  | some w => match fr a with
    | none => h' = some (M.hobj h)
    | some _ => WideOK M w h h'
  | none => SlotOK M fr a h h'

/-- At `a` the frames `W` play no role (`SlotW` is `SlotOK` there): no frame of `W`, an unframed
address, or an object of a kind no frame admits. Under `Rel` it holds everywhere (`NoW.free`). -/
def NoW {S' : Type} (K : Ctx) (W : Nat → Option WFrame) (s : St S') (a : Nat) : Prop :=
  W a = none ∨ K.fr a = none ∨ ∃ o, s.obj? a = some o ∧ ¬ Wideable o.kind

/-- No frames beyond framed arrays. -/
abbrev noFrames : Nat → Option WFrame := fun _ => none

/-- `Rel` with the further frames `W` (`SlotW`) and a target-only stack base `stk`: the target's
stack is the source's image followed by `stk` (caller frames the source does not hold, as `base'`
is a target-only trace base). -/
structure RelB (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (stk : List Frame)
    (M : Map) (ν : Nat → F64) (K : Ctx) (s : St F.S) (S : SSrv) (t : St F.S) (C : CSrv) : Prop where
  srv : Srv M ν S C
  heap : ∀ a h, s.heap.get a = some h → SlotW M K.fr W a h (t.heap.get (M.a a))
  /-- Fresh addresses continue in order; allocated ones map injectively below the target's next. -/
  next : ∀ k, M.a (s.next + k) = t.next + k
  /-- Both sides allocate in lockstep: a constant offset of the counters. -/
  offset : t.next = s.next + K.D
  room : K.D < bound
  /-- Ordinary bigints keep their values; pointer integers follow their memory. -/
  bigFixed : ∀ i, BigFixed K.lo K.hi i → M.big i = i
  bigExt : ∀ r off, off < 2 ^ 24 → M.big (ptrInt (.ext r) off) = ptrInt (.ext (M.region r)) off
  band : K.hi ≤ 2 ^ 56
  /-- Intrinsic objects (prototypes, globals: addresses below `aFirst`) are shared. -/
  intr : ∀ a, a < aFirst → M.a a = a
  bound : ∀ a, Present s a → M.a a < t.next
  inj : ∀ a b, Present s a → Present s b → M.a a = M.a b → a = b
  presentBound : ∀ a, Present s a → a < s.next
  framedPresent : ∀ a p, K.fr a = some p → Present s a
  ctl : t.ctl = M.ctl s.ctl
  stack : t.stack = s.stack.map M.frame ++ stk
  jobs : t.jobs = s.jobs.map M.job
  stores : t.stores = M.stores s.stores
  /-- The native relation, given the number of allocated references (its closedness bound). -/
  ffi : FR M S.tab.length s.ffi t.ffi
  trace : ∃ fresh, s.trace = fresh ++ K.base ∧ t.trace = fresh.map M.event ++ K.base'
  /-- Closedness of the source. -/
  heapSupp : ∀ a h, s.heap.get a = some h → Supp.hobj (Present s) S.tab.length h
  ctlSupp : Supp.ctl (Present s) S.tab.length s.ctl
  stackSupp : ∀ f ∈ s.stack, Supp.frame (Present s) S.tab.length f
  jobsSupp : ∀ j ∈ s.jobs, Supp.job (Present s) S.tab.length j
  storesSupp : Supp.stores (Present s) S.tab.length s.stores
  traceSupp : ∃ fresh, s.trace = fresh ++ K.base ∧ ∀ e ∈ fresh, Supp.event (Present s) S.tab.length e

/-- `RelB` without a stack base. -/
abbrev RelF (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (M : Map)
    (ν : Nat → F64) (K : Ctx) (s : St F.S) (S : SSrv) (t : St F.S) (C : CSrv) : Prop :=
  RelB F FR W [] M ν K s S t C

/-- The relation without frames beyond framed arrays: its heap clause is `SlotOK` (`SlotW` at
`noFrames` reduces to it). -/
abbrev Rel (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (M : Map) (ν : Nat → F64) (K : Ctx)
    (s : St F.S) (S : SSrv) (t : St F.S) (C : CSrv) : Prop :=
  RelF F FR noFrames M ν K s S t C

end Host.Ts.Sim
