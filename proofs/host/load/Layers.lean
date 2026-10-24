import host.load.AneWorld
import host.mlx.FfiSymShape
import host.ts.StoreLaws
namespace Host.Load.Layers
open Host.Ts Host.Mlx

/-! # Layers over the load world

The load world (`Host.Load.ffi`) and its MLX model (`Host.Mlx.Ffi`) stay as
they are, so every checked run and its stream data stay valid. A prompt of
symbolic length runs in a stack of layers over them, each adding state or
completing calls the layer below leaves stuck, and never changing a result the
layer below gives:

1. the Neural Engine world (`Host.Load.Ane.ffi`, the bridge's buffers);
2. symbolic shapes (`symFfi`): a call the Neural Engine world leaves stuck is
   completed by `Ffi.SymShape.symShapeCall` (`mlx_array_size`, `mlx_conv1d`,
   `mlx_reshape` over symbolic dimensions); every other result is the world
   below's (`symCall_eq`);
3. liveness (`live`, an `Observer`): the set of released object handles. A
   free of a handle that is not live is mlx-c undefined behaviour (a double
   free, an object of another kind, a pointer it did not allocate): this
   layer rejects it (the model below lets an object free be a no-op);
4. kernel recording (`kern`, an `Observer`): the `ensure_row_contiguous` and
   `atomic_outputs` flags each `mlx_fast_metal_kernel_new` received, and each
   configuration's template arguments in insertion order (MLX's
   `template_args`). A launch is accepted only if its configuration's order is
   dtypes then ints and agrees with the model's configuration (the order the
   route's custom-kernel contract assembles, `KernelRecorded`).

An observer runs the world below and then updates its state from the call, the
states before and after and the result, or rejects the call: its results
project to the world below's (`Observer.post_some`). In the stack each
observer records a rejection instead (`Observer.total`: its state is `none`
from the first call it rejects), so the stack never rejects a call the world
below completes; `accepted` reads the verdicts. `full` is the stack.
`LayerLift.full_lift`: every execution of the load world without bridge
calls or surface wraps is an execution of `full` with the same projections,
returns and writes, accepted exactly if the liveness and kernel-recording folds
accept it; `FfiNat.Lift`: the same for machine runs. -/

abbrev Res (S : Type) := Option (S × Ret × List (Nat × Nat × List Byte))

/-! ## Symbolic shapes over the Neural Engine world -/

/-- The Neural Engine world's call, and where it is stuck on an MLX call (other than a surface wrap)
the symbolic-shape layer's, followed by the bridge's bookkeeping as `FfiAne.mlxCall` does. -/
def symCall (s : Ane.ASt) (name : Name) (args : List Arg) : Ane.R :=
  .bind (Ane.call s name args) fun
    | some r => .pure (some r)
    | none => bif isMlx name && !nameEq name FfiAne.payloadName then
        .bind (Ffi.SymShape.symShapeCall s.base.mlx name args) fun
          | some (m, r, ws) => .pure (bif s.bridge.active then
              (FfiAne.after s.bridge s.base.mlx m name args).map fun b => (⟨{ s.base with mlx := m }, b⟩, r, ws)
            else some (⟨{ s.base with mlx := m }, s.bridge⟩, r, ws))
          | none => .pure none
      else .pure none

abbrev symFfi : Ffi := ⟨Ane.ASt, symCall, Ane.read, fun _ => 4096, Ane.back⟩

/-- **Agreement.** The layer runs the Neural Engine world's call and keeps its result where it is defined. -/
theorem symCall_eq (s : Ane.ASt) (name : Name) (args : List Arg) (γ : Type) (k : Res Ane.ASt → Free γ) :
    symCall s name args γ k = Ane.call s name args γ (fun
      | some r => k (some r)
      | none => (bif isMlx name && !nameEq name FfiAne.payloadName then
          .bind (Ffi.SymShape.symShapeCall s.base.mlx name args) fun
            | some (m, r, ws) => .pure (bif s.bridge.active then
                (FfiAne.after s.bridge s.base.mlx m name args).map fun b => (⟨{ s.base with mlx := m }, b⟩, r, ws)
              else some (⟨{ s.base with mlx := m }, s.bridge⟩, r, ws))
            | none => .pure none
          else (.pure none : Ane.R)) γ k) := by
  unfold symCall M.bind
  congr 1
  funext o
  cases o <;> rfl

theorem symFfi_back : symFfi.back = Ane.back := rfl
theorem symFfi_read : symFfi.read = Ane.read := rfl

/-! ## Observers -/

/-- A layer that observes each completed call and trace continuation of the world `F` below:
its state is updated from the states before and after, the call and its return, or the call is
rejected (stuck in this layer only). -/
structure Observer (F : Ffi) where
  E : Type
  onCall : E → F.S → F.S → Name → List Arg → Ret → Option E
  onBack : E → F.S → F.S → Arg → Ret → Option E

namespace Observer
variable {F : Ffi} (O : Observer F)

/-- The observed result of a call of the world below. -/
def post (g : F.S → Ret → Option O.E) : Res F.S → Res (F.S × O.E)
  | some (x', r, ws) => (g x' r).map fun e' => ((x', e'), r, ws)
  | none => none

def call (p : F.S × O.E) (name : Name) (args : List Arg) : M (Res (F.S × O.E)) :=
  .bind (F.call p.1 name args) fun o => .pure (O.post (fun x' r => O.onCall p.2 p.1 x' name args r) o)

def back (p : F.S × O.E) (a : Arg) : M (Res (F.S × O.E)) :=
  .bind (F.back p.1 a) fun o => .pure (O.post (fun x' r => O.onBack p.2 p.1 x' a r) o)

/-- The world with the observer. -/
abbrev ffi : Ffi := ⟨F.S × O.E, O.call, fun p => F.read p.1, F.addr, O.back⟩

theorem call_eq (p : F.S × O.E) (name : Name) (args : List Arg) (γ : Type) (k : Res (F.S × O.E) → Free γ) :
    O.ffi.call p name args γ k =
      F.call p.1 name args γ (fun o => k (O.post (fun x' r => O.onCall p.2 p.1 x' name args r) o)) := rfl

theorem back_eq (p : F.S × O.E) (a : Arg) (γ : Type) (k : Res (F.S × O.E) → Free γ) :
    O.ffi.back p a γ k = F.back p.1 a γ (fun o => k (O.post (fun x' r => O.onBack p.2 p.1 x' a r) o)) := rfl

theorem read_eq (p : F.S × O.E) : O.ffi.read p = F.read p.1 := rfl

/-- **Projection.** An observed result is the world below's result, accepted by the observer. -/
theorem post_some {g : F.S → Ret → Option O.E} {o : Res F.S} {x' : F.S} {e' : O.E} {r : Ret}
    {ws : List (Nat × Nat × List Byte)} :
    O.post g o = some ((x', e'), r, ws) ↔ o = some (x', r, ws) ∧ g x' r = some e' := by
  cases o with
  | none => simp [post]
  | some q =>
    obtain ⟨y, r', ws'⟩ := q
    simp only [post, Option.map_eq_some_iff, Prod.mk.injEq, Option.some.injEq]
    constructor
    · rintro ⟨a, hga, ⟨rfl, rfl⟩, rfl, rfl⟩; exact ⟨⟨rfl, rfl, rfl⟩, hga⟩
    · rintro ⟨⟨rfl, rfl, rfl⟩, hga⟩; exact ⟨_, hga, ⟨rfl, rfl⟩, rfl, rfl⟩

/-- The observer rejects exactly what it does not accept. -/
theorem post_none {g : F.S → Ret → Option O.E} {x' : F.S} {r : Ret} {ws : List (Nat × Nat × List Byte)}
    (h : g x' r = none) : O.post g (some (x', r, ws)) = none := by simp [post, h]

/-- `O` recording rejections: its state is `none` from the first update `O` rejects; it rejects nothing. -/
abbrev total : Observer F :=
  ⟨Option O.E, fun e x x' name args r => some (e.bind fun e => O.onCall e x x' name args r),
    fun e x x' a r => some (e.bind fun e => O.onBack e x x' a r)⟩

end Observer

/-! ## Liveness -/

/-- The objects each object free deletes (the C++ type of its `ctx`, mlx-c `private/*.h`). -/
def freeKind : Ffi.Sym → Ffi.Obj → Bool
  | .streamFree, .stream | .stringFree, .str _ | .deviceInfoFree, .dinfo | .deviceFree, .device
  | .vecFree, .vec _ | .vstrFree, .vstr _ | .closureFree, .clo _ | .kernelFree, .kernel .. | .cfgFree, .cfg _
  | .mapArrayFree, .amap _ | .mapStringFree, .smap => true
  | _, _ => false

def isArrFree : Ffi.Sym → Bool
  | .arrayFree => true
  | _ => false

/-- The object frees. -/
def isObjFree : Ffi.Sym → Bool
  | .streamFree | .stringFree | .deviceInfoFree | .deviceFree | .vecFree | .vstrFree | .closureFree
  | .kernelFree | .cfgFree | .mapArrayFree | .mapStringFree => true
  | _ => false

/-- A call on the model's state `m` before it, with released object handles `freed`: an array free
must name a node (a handle the model has not released), an object free a live object of its kind;
the null handle is a no-op (mlx-c `*_free_` deletes only a non-null `ctx`). Other calls pass. -/
def liveFree (freed : PTrie Unit) (m : Ffi.St) (x : Ffi.Sym) (a : Arg) : Option (PTrie Unit) :=
  bif isObjFree x then match Ffi.argNat a with
    | some 0 => some freed
    | some h => match m.arrs.get h, m.objs.get h, freed.get h with
      | none, some o, none => bif freeKind x o then some (freed.set h ()) else none
      | _, _, _ => none
    | none => none
  else bif isArrFree x then match Ffi.argNat a with
    | some 0 => some freed
    | some h => bif (m.node? h).isSome then some freed else none
    | none => none
  else some freed

def liveCall (freed : PTrie Unit) (m : Ffi.St) (name : Name) (args : List Arg) : Option (PTrie Unit) :=
  match Ffi.symOf name, args with
  | some x, [a] => liveFree freed m x a
  | _, _ => some freed

/-- A trace continuation: mlx-c's closure wrapper frees its input vector after the callback,
the tracer vector `closureApply` allocated just before the pending apply's id. -/
def liveBack (freed : PTrie Unit) (m : Ffi.St) : Option (PTrie Unit) :=
  match m.pending with
  | p :: _ => match m.objs.get (p.id - 1), freed.get (p.id - 1) with
    | some (.vec _), none => some (freed.set (p.id - 1) ())
    | _, _ => none
  | [] => some freed

/-- The liveness observer over the symbolic-shape world. -/
abbrev live : Observer symFfi :=
  ⟨PTrie Unit, fun e x _ name args _ => liveCall e x.base.mlx name args, fun e x _ _ _ => liveBack e x.base.mlx⟩

/-- A live handle of the model's state `m` with released objects `freed`: an array handle naming a
node id other than 0 (the model's release points it at node 0), or an object not released. -/
def isLive (m : Ffi.St) (freed : PTrie Unit) (h : Nat) : Bool :=
  match m.arrs.get h with
  | some n => !Nat.beq n 0
  | none => (m.objs.get h).isSome && (freed.get h).isNone

/-- The live handles. -/
def liveSet (m : Ffi.St) (freed : PTrie Unit) : List Nat := (List.range m.next).filter (isLive m freed)

theorem beq_zero (n : Nat) : Nat.beq n 0 = decide (n = 0) := by cases n <;> rfl

theorem mem_liveSet {m : Ffi.St} {freed : PTrie Unit} {x : Nat} :
    x ∈ liveSet m freed ↔ x < m.next ∧ isLive m freed x = true := by
  simp [liveSet, List.mem_filter, List.mem_range]

theorem liveSet_addNode (m : Ffi.St) (freed : PTrie Unit) (nd : Ffi.Node) :
    liveSet (m.addNode nd).2 freed = liveSet m freed := rfl

/-- An object allocation adds its handle. -/
theorem mem_liveSet_newObj {m : Ffi.St} {freed : PTrie Unit} (o : Ffi.Obj) (hb : m.next < 2 ^ 64)
    (ha : m.arrs.get m.next = none) (hf : freed.get m.next = none) (x : Nat) :
    x ∈ liveSet (m.newObj o).2 freed ↔ x ∈ liveSet m freed ∨ x = m.next := by
  rw [mem_liveSet, mem_liveSet]
  show x < m.next + 1 ∧ _ ↔ _
  have hi : isLive (m.newObj o).2 freed x = if x = m.next then true else isLive m freed x := by
    simp only [Ffi.St.newObj, isLive, PTrie.get_set_u64 _ _ _ hb]
    by_cases hx : x = m.next
    · subst hx; simp [ha, hf]
    · simp [hx]
  rw [hi]
  by_cases hx : x = m.next
  · subst hx; simp
  · simp only [hx, ite_false, or_false]
    exact ⟨fun ⟨h1, h2⟩ => ⟨by omega, h2⟩, fun ⟨h1, h2⟩ => ⟨by omega, h2⟩⟩

/-- An operation writing a null result slot adds the new handle. -/
theorem mem_liveSet_setArr_null {m : Ffi.St} {freed : PTrie Unit} (n : Nat) (hb : m.next < 2 ^ 64) (hn : n ≠ 0)
    (x : Nat) : x ∈ liveSet (m.setArr 0 n).2 freed ↔ x ∈ liveSet m freed ∨ x = m.next := by
  rw [mem_liveSet, mem_liveSet]
  show x < m.next + 1 ∧ _ ↔ _
  have hi : isLive (m.setArr 0 n).2 freed x = if x = m.next then true else isLive m freed x := by
    simp only [Ffi.St.setArr, Nat.beq_refl, Bool.cond_true, isLive, PTrie.get_set_u64 _ _ _ hb]
    by_cases hx : x = m.next
    · subst hx; simp [beq_zero, hn]
    · simp [hx]
  rw [hi]
  by_cases hx : x = m.next
  · subst hx; simp
  · simp only [hx, ite_false, or_false]
    exact ⟨fun ⟨h1, h2⟩ => ⟨by omega, h2⟩, fun ⟨h1, h2⟩ => ⟨by omega, h2⟩⟩

/-- An accepted array free of a non-null handle removes it (the model's release, `St.freeArr`). -/
theorem mem_liveSet_freeArr {m : Ffi.St} {freed : PTrie Unit} {h : Nat} (hz : h ≠ 0) (hb : h < 2 ^ 64)
    (x : Nat) : x ∈ liveSet (m.freeArr h) freed ↔ x ∈ liveSet m freed ∧ x ≠ h := by
  have hzb : Nat.beq h 0 = false := by simp [beq_zero, hz]
  have he : m.freeArr h = { m with arrs := m.arrs.set h 0 } := by simp [Ffi.St.freeArr, hzb]
  have hi : isLive (m.freeArr h) freed x = (isLive m freed x && !decide (x = h)) := by
    rw [he]
    simp only [isLive, PTrie.get_set_u64 _ _ _ hb]
    by_cases hx : x = h
    · subst hx; simp
    · simp [hx]
  rw [mem_liveSet, mem_liveSet, hi, he]
  simp only [Bool.and_eq_true, Bool.not_eq_true', decide_eq_false_iff_not]
  exact ⟨fun ⟨a, b, c⟩ => ⟨⟨a, b⟩, c⟩, fun ⟨⟨a, b⟩, c⟩ => ⟨a, b, c⟩⟩

/-- An accepted object free of a non-null handle removes it (the model keeps the object). -/
theorem liveCall_obj {freed freed' : PTrie Unit} {m : Ffi.St} {name : Name} {a : Arg} {x : Ffi.Sym} {h : Nat}
    (hs : Ffi.symOf name = some x) (hx : isObjFree x = true) (ha : Ffi.argNat a = some h) (hz : h ≠ 0)
    (hl : liveCall freed m name [a] = some freed') :
    ∃ o, m.arrs.get h = none ∧ m.objs.get h = some o ∧ freed.get h = none ∧ freeKind x o = true ∧
      freed' = freed.set h () := by
  obtain ⟨k, rfl⟩ : ∃ k, h = k + 1 := ⟨h - 1, by omega⟩
  have e : liveCall freed m name [a] = liveFree freed m x a := by unfold liveCall; rw [hs]
  rw [e] at hl
  simp only [liveFree, hx, Bool.cond_true, ha] at hl
  split at hl
  · rename_i o h1 h2 h3
    cases hk : freeKind x o
    · simp [hk] at hl
    · simp only [hk, Bool.cond_true, Option.some.injEq] at hl
      exact ⟨o, h1, h2, h3, hk, hl.symm⟩
  · cases hl

theorem mem_liveSet_freeObj {m : Ffi.St} {freed : PTrie Unit} {h : Nat} (hb : h < 2 ^ 64)
    (ha : m.arrs.get h = none) (x : Nat) :
    x ∈ liveSet m (freed.set h ()) ↔ x ∈ liveSet m freed ∧ x ≠ h := by
  have hi : isLive m (freed.set h ()) x = (isLive m freed x && !decide (x = h)) := by
    simp only [isLive, PTrie.get_set_u64 _ _ _ hb]
    by_cases hx : x = h
    · subst hx; simp [ha]
    · simp [hx]
  rw [mem_liveSet, mem_liveSet, hi]
  simp only [Bool.and_eq_true, Bool.not_eq_true', decide_eq_false_iff_not]
  exact ⟨fun ⟨a, b, c⟩ => ⟨⟨a, b⟩, c⟩, fun ⟨⟨a, b⟩, c⟩ => ⟨a, b, c⟩⟩

/-- The model's object frees keep its state (the release is this layer's). -/
theorem call_objFree {m : Ffi.St} {name : Name} {x : Ffi.Sym} (hs : Ffi.symOf name = some x) (hx : isObjFree x = true)
    (a : Arg) : ∃ r, Host.Mlx.Ffi.call m name [a] = Host.Mlx.Ffi.ok m r := by
  unfold Host.Mlx.Ffi.call; rw [hs]
  cases x <;> first | exact ⟨_, rfl⟩ | exact absurd hx (by simp [isObjFree])

/-! ## Kernel recording -/

/-- A template argument (`mlx_fast_metal_kernel_config_add_template_arg_int`/`_dtype`). -/
inductive TArg where
  | int (v : NumV)
  | dtype (d : Nat)

/-- The kernels' flags and the configurations' template arguments, by handle. -/
structure KRec where
  /-- `(ensure_row_contiguous, atomic_outputs)` each `mlx_fast_metal_kernel_new` received. -/
  flags : PTrie (Bool × Bool)
  /-- Template arguments in insertion order (MLX's one `template_args` vector). -/
  targs : PTrie (List (List Char × TArg))

def KRec.empty : KRec := ⟨.nil, .nil⟩

def dtypesOf : List (List Char × TArg) → List (List Char × Nat)
  | [] => []
  | (n, .dtype d) :: r => (n, d) :: dtypesOf r
  | (_, .int _) :: r => dtypesOf r

def intsOf : List (List Char × TArg) → List (List Char × NumV)
  | [] => []
  | (n, .int v) :: r => (n, v) :: intsOf r
  | (_, .dtype _) :: r => intsOf r

/-- Every dtype argument before every int argument (the order metal-kernel.ts adds them). -/
def ordered : List (List Char × TArg) → Bool
  | (_, .dtype _) :: r => ordered r
  | r => r.all fun t => match t.2 with | .int _ => true | .dtype _ => false

/-- A call on the model's state `m` before it, returning `r`. -/
def kernCall (k : KRec) (m : Ffi.St) (name : Name) (args : List Arg) (r : Ret) : Option KRec :=
  match Ffi.symOf name, args, r with
  | some .kernelNew, [_, _, _, _, _, rc, ao], .big h => match Ffi.argBool rc, Ffi.argBool ao with
    | some rc, some ao => some { k with flags := k.flags.set h.toNat (rc, ao) }
    | _, _ => none
  | some .cfgNew, [], .big h => some { k with targs := k.targs.set h.toNat [] }
  | some .cfgDtype, [c, nm, dt], _ => match Ffi.argNat c, Ffi.cstrArg nm, Ffi.argNat dt with
    | some h, some n, some d => (k.targs.get h).map fun l => { k with targs := k.targs.set h (l ++ [(n, .dtype d)]) }
    | _, _, _ => none
  | some .cfgInt, [c, nm, .num v], _ => match Ffi.argNat c, Ffi.cstrArg nm with
    | some h, some n => (k.targs.get h).map fun l => { k with targs := k.targs.set h (l ++ [(n, .int v)]) }
    | _, _ => none
  | some .kernelApply, [_, kh, _, c, _], _ => match Ffi.argNat kh, Ffi.argNat c with
    | some kh, some ch => match k.flags.get kh, k.targs.get ch, m.obj? ch with
      | some _, some l, some (.cfg cfg) =>
        bif ordered l && decide (cfg.dtypes = dtypesOf l) && decide (cfg.ints = intsOf l) then some k else none
      | _, _, _ => none
    | _, _ => none
  | _, _, _ => some k

/-- A launch the layer accepts: its kernel's flags were recorded, and its configuration's template
arguments, recorded in insertion order, are dtypes then ints and are the model's configuration's. -/
theorem kernCall_launch {k k' : KRec} {m : Ffi.St} {name : Name} {o kha v cha st : Arg} {r : Ret} {kh ch : Nat}
    (hs : Ffi.symOf name = some .kernelApply) (hkh : Ffi.argNat kha = some kh) (hch : Ffi.argNat cha = some ch)
    (h : kernCall k m name [o, kha, v, cha, st] r = some k') :
    ∃ fl l c, k.flags.get kh = some fl ∧ k.targs.get ch = some l ∧ m.obj? ch = some (.cfg c) ∧
      ordered l = true ∧ c.dtypes = dtypesOf l ∧ c.ints = intsOf l ∧ k' = k := by
  unfold kernCall at h
  rw [hs] at h
  simp only [hkh, hch] at h
  split at h
  · rename_i fl l c h1 h2 h3
    cases hb : (ordered l && decide (c.dtypes = dtypesOf l) && decide (c.ints = intsOf l))
    · simp [hb] at h
    · simp only [hb, Bool.cond_true, Option.some.injEq] at h
      simp only [Bool.and_eq_true, decide_eq_true_eq] at hb
      exact ⟨fl, l, c, h1, h2, h3, hb.1.1, hb.1.2, hb.2, h.symm⟩
  · cases h

/-- The kernel-recording observer over the liveness layer. -/
abbrev kern : Observer live.total.ffi :=
  ⟨KRec, fun e x _ name args r => kernCall e x.1.base.mlx name args r, fun e _ _ _ _ => some e⟩

/-! ## The stack -/

/-- The full world: kernel recording over liveness over symbolic shapes over the Neural Engine world. -/
abbrev full : Ffi := kern.total.ffi

/-- A Neural Engine world state with empty layer states. -/
def start (s : Ane.ASt) : full.S := ((s, some .nil), some KRec.empty)

/-- The load world's state of a full-world state. -/
def toLoad (p : full.S) : LSt := p.1.1.base

/-- No layer rejected a call. -/
def accepted (p : full.S) : Bool := p.1.2.isSome && p.2.isSome

end Host.Load.Layers
