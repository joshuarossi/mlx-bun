import metal.Value

namespace Metal
open Core Inference.Contracts.Mlx

/-! # Execution of a launch

One deterministic run of a launch. Threads of a threadgroup run one after
another; a thread stops at a barrier and at a SIMD-group collective. A
SIMD-group resolves a collective when all 32 lanes reach the same one; a
threadgroup passes a barrier when all its threads reach the same one. The
collectives are `simd_sum` (the contract's `simdSum` of the lanes' values),
`simd_shuffle_down` and `simdgroup_multiply_accumulate` (the contract's
`simdMma`, `simdMmaHalfA` or `simdMmaHalfB` on the lanes' registers: each
lane's two elements of A, B and C in, of D out; no lane-to-element layout is
part of the semantics). Threadgroups run one after another. Anything else —
divergent barriers or collectives, out-of-bounds or misaligned accesses,
writes to constant memory, undefined integer operations, operations outside
the modeled subset — has no result (`none`).

Every access to device, constant and threadgroup memory is logged with its
thread, threadgroup and barrier epoch. `RaceFree` says no two threads access
the same byte, one of them writing, in the same epoch of one threadgroup, or
from different threadgroups. For race-free runs every legal interleaving of
the threads reads and writes the same values, so this one run gives every
schedule's result. -/

/-- A memory region: its space, size in bytes, and the alignment its base address
is guaranteed to have (buffers: what MLX's allocation gives; arrays: their
element type's alignment). -/
structure Region where
  space : Space
  size : Nat
  align : Nat
deriving Inhabited

structure Access where
  thread : Nat
  group : Nat
  region : Nat
  byte : Nat
  write : Bool
  deviceEpoch : Nat
  groupEpoch : Nat
deriving Inhabited

/-- Memory of a launch, and the access log (newest first). -/
structure Shared where
  regions : Nat → Option Region
  bytes : Nat → ByteMemory.Bytes
  log : List Access
  deviceEpoch : Nat := 0
  groupEpoch : Nat := 0

/-- What a thread is: its ids and coordinates, its thread arrays' regions,
and the compiler's contraction choices (`fuse site`). -/
structure Ctx where
  thread : Nat
  group : Nat
  coord : Coord → Val
  threadArray : Nat → Nat
  groupArray : Nat → Nat
  fuse : Nat → Bool

abbrev M := StateT Shared Option

def lift {α : Type} : Option α → M α
  | some a => pure a
  | none => failure

/-- Accesses to shared memory are logged; thread memory is private. -/
def logAccess (ctx : Ctx) (region byte : Nat) (write : Bool) : M Unit :=
  modify fun sh =>
    match sh.regions region with
    | some r => if r.space = .thread then sh else
        { sh with log := ⟨ctx.thread, ctx.group, region, byte, write, sh.deviceEpoch, sh.groupEpoch⟩ :: sh.log }
    | none => sh

def alignment : Ty → Nat
  | .scalar s => s.bytes
  | t => t.bytes

/-- Byte offset of an access of type `t` through `p`, checked against the
region and the alignment of the absolute address (the region's guaranteed
base alignment must cover it). A 4-byte threadgroup load from a 4-aligned
region ignores the low two address bits (M1Max `LoadContract`). -/
def place (t : Ty) (p : Ptr) (load : Bool) : M (Region × Nat) := do
  let r ← lift ((← get).regions p.region)
  if p.offset < 0 then failure
  let offset := p.offset.toNat
  let offset := if load ∧ r.space = .threadgroup ∧ t.bytes = 4 ∧ r.align % 4 = 0 then offset - offset % 4 else offset
  if r.align % alignment t ≠ 0 ∨ offset % alignment t ≠ 0 ∨ r.size < offset + t.bytes then failure
  pure (r, offset)

def loadAt (ctx : Ctx) (t : Ty) (p : Ptr) : M Val := do
  let (_, offset) ← place t p true
  for i in List.range t.bytes do logAccess ctx p.region (offset + i) false
  let memory := (← get).bytes p.region
  lift (decode t ((List.range t.bytes).map fun i => memory (offset + i)))

def writeBytes (memory : ByteMemory.Bytes) (offset : Nat) (bytes : List (BitVec 8)) : ByteMemory.Bytes :=
  fun byte => if offset ≤ byte ∧ byte < offset + bytes.length then bytes.getD (byte - offset) 0 else memory byte

def storeAt (ctx : Ctx) (t : Ty) (p : Ptr) (v : Val) : M Unit := do
  let (r, offset) ← place t p false
  if r.space = .constant then failure
  let bytes ← lift (encode t v)
  for i in List.range t.bytes do logAccess ctx p.region (offset + i) true
  modify fun sh => { sh with bytes := fun region =>
    if region = p.region then writeBytes (sh.bytes region) offset bytes else sh.bytes region }

/-- Componentwise lifting to vectors. -/
def lift1 (f : Val → Option Val) : Val → Option Val
  | .vec s xs => (xs.mapM f).map (.vec s)
  | v => f v

def lift2 (f : Val → Val → Option Val) : Val → Val → Option Val
  | .vec s xs, .vec _ ys => if xs.length = ys.length then ((xs.zip ys).mapM fun (x, y) => f x y).map (.vec s) else none
  | a, b => f a b

def natOf : Val → Option Nat
  | .int s w => if s.isSigned ∧ Val.signed s w < 0 then none else some w
  | _ => none

def truth : Val → Option Bool
  | .bool b => some b
  | _ => none

variable (C : M1Max.Contract) (ctx : Ctx) (locals : Nat → Option Val)

def fused (x y z : Val) : M Val :=
  match x, y, z with
  | .f32 x, .f32 y, .f32 z => pure (.f32 (C.fma x y z))
  | _, _, _ => failure

mutual
def eval : CExpr → M Val
  | .lit v => pure v
  | .local slot => lift (locals slot)
  | .coord c => pure (ctx.coord c)
  | .un op s e => do lift (lift1 (unary C op s) (← eval e))
  | .bin op s site a b => do
    let plain : M Val := do lift (lift2 (binary C op s) (← eval a) (← eval b))
    -- Contraction: the compiler may compute `x*y ± z` as one fused operation.
    if ctx.fuse site ∧ s = .f32 then
      match op, a, b with
      | .add, .bin .mul .f32 _ x y, z => do fused C (← eval x) (← eval y) (← eval z)
      | .add, z, .bin .mul .f32 _ x y => do fused C (← eval x) (← eval y) (← eval z)
      | .sub, .bin .mul .f32 _ x y, z => do
        let z ← eval z
        fused C (← eval x) (← eval y) (← lift (unary C .neg .f32 z))
      | .sub, z, .bin .mul .f32 _ x y => do
        let x ← eval x
        fused C (← lift (unary C .neg .f32 x)) (← eval y) (← eval z)
      | _, _, _ => plain
    else plain
  | .fma a b c => do fused C (← eval a) (← eval b) (← eval c)
  | .conv t e => do lift (lift1 (convert C t) (← eval e))
  | .bitcast t e => do lift (bitcast t (← eval e))
  | .and a b => do
    if ← lift (truth (← eval a)) then eval b else pure (.bool false)
  | .or a b => do
    if ← lift (truth (← eval a)) then pure (.bool true) else eval b
  | .cond c a b => do
    if ← lift (truth (← eval c)) then eval a else eval b
  | .load t p => do
    match ← eval p with
    | .ptr q => loadAt ctx t q
    | _ => failure
  | .offset p i => do
    match ← eval p, ← eval i with
    | .ptr q, .int s w => pure (.ptr { q with offset := q.offset + Val.signed s w * q.elem.bytes })
    | _, _ => failure
  | .ptrCast t p => do
    match ← eval p with
    | .ptr q => pure (.ptr { q with elem := t })
    | _ => failure
  | .component v i => do
    match ← eval v, ← eval i with
    | .vec _ xs, i => do let n ← lift (natOf i); lift xs[n]?
    | _, _ => failure
  | .vector s es => do pure (.vec s (← evalList es))

def evalList : List CExpr → M (List Val)
  | [] => pure []
  | e :: es => do let v ← eval e; pure (v :: (← evalList es))
end

/-! ## Threads -/

inductive Frame where
  | block (rest : List CStmt)
  /-- The loop's body has finished: run `step`, then test. -/
  | loop (condition : CExpr) (step body : List CStmt)
  /-- `step` has finished: test the condition. -/
  | next (condition : CExpr) (step body : List CStmt)
  | scope
deriving Inhabited

inductive Status where
  | running
  | barrier (site : Nat) (device threadgroup : Bool)
  | collective (site slot : Nat) (op : Collective) (s : Scalar) (value : Val) (delta : Nat)
  | done
deriving Inhabited

structure Thread where
  ctx : Ctx
  locals : Nat → Option Val
  frames : List Frame
  status : Status := .running

def Thread.set (t : Thread) (slot : Nat) (v : Val) : Thread :=
  { t with locals := fun i => if i = slot then some v else t.locals i }

/-- Frames above the nearest frame satisfying `stop`, removed. -/
def unwindTo (stop : Frame → Bool) : List Frame → Option (List Frame)
  | [] => none
  | f :: fs => if stop f then some (f :: fs) else match f with
    | .scope => none
    | _ => unwindTo stop fs

def isLoop : Frame → Bool
  | .loop .. => true | _ => false
def isLoopOrNext : Frame → Bool
  | .loop .. | .next .. => true | _ => false
def isScope : Frame → Bool
  | .scope => true | _ => false

def test (t : Thread) (c : CExpr) : M Bool := do lift (truth (← eval C t.ctx t.locals c))

/-- Execute statement `s` with the rest of the thread's frames `fs`. -/
def exec (t : Thread) (fs : List Frame) : CStmt → M Thread
  | .set slot e => do pure ({ t with frames := fs }.set slot (← eval C t.ctx t.locals e))
  | .store ty p v => do
    match ← eval C t.ctx t.locals p with
    | .ptr q => do storeAt t.ctx ty q (← eval C t.ctx t.locals v); pure { t with frames := fs }
    | _ => failure
  | .array slot threadgroup index elem =>
    let region := if threadgroup then t.ctx.groupArray index else t.ctx.threadArray index
    pure ({ t with frames := fs }.set slot (.ptr ⟨region, 0, elem⟩))
  | .ite c a b => do
    pure { t with frames := .block (if ← test C t c then a else b) :: fs }
  | .loop c step body => do
    if ← test C t c then pure { t with frames := .block body :: .loop c step body :: fs }
    else pure { t with frames := fs }
  | .continue_ => do pure { t with frames := ← lift (unwindTo isLoop fs) }
  | .break_ => do
    match ← lift (unwindTo isLoopOrNext fs) with
    | _ :: rest => pure { t with frames := rest }
    | [] => failure
  | .scope body => pure { t with frames := .block body :: .scope :: fs }
  | .leave => do
    match ← lift (unwindTo isScope fs) with
    | _ :: rest => pure { t with frames := rest }
    | [] => failure
  | .barrier site device group => pure { t with frames := fs, status := .barrier site device group }
  | .collective site slot op s e delta => do
    let v ← eval C t.ctx t.locals e
    let d ← lift (natOf (← eval C t.ctx t.locals delta))
    pure { t with frames := fs, status := .collective site slot op s v d }

def step (t : Thread) : M Thread :=
  match t.frames with
  | [] => pure { t with status := .done }
  | .block [] :: fs => pure { t with frames := fs }
  | .block (s :: rest) :: fs => exec C t (.block rest :: fs) s
  | .loop c st b :: fs => pure { t with frames := .block st :: .next c st b :: fs }
  | .next c st b :: fs => do
    if ← test C t c then pure { t with frames := .block b :: .loop c st b :: fs }
    else pure { t with frames := fs }
  | .scope :: fs => pure { t with frames := fs }

def isRunning : Status → Bool
  | .running => true | _ => false

/-- Run a thread until it stops (barrier, collective, end), within `fuel` steps. -/
def runThread : Nat → Thread → M Thread
  | 0, t => if isRunning t.status then failure else pure t
  | fuel + 1, t => if isRunning t.status then do runThread fuel (← step C t) else pure t

/-! ## SIMD-groups and threadgroups -/

def collectiveOf : Status → Option (Nat × Collective × Scalar × Nat)
  | .collective site _ op s _ delta => some (site, op, s, delta)
  | _ => none

def valueOf : Status → Option Val
  | .collective _ _ _ _ v _ => some v
  | _ => none

def slotOf : Status → Option Nat
  | .collective _ slot .. => some slot
  | _ => none

/-- A lane's two `thread_elements()` of a SIMD-group matrix, as `f` reads each. -/
def pairOf {α : Type} (f : Val → Option α) : Val → Option (α × α)
  | .vec _ [x, y] => do pure (← f x, ← f y)
  | _ => none

def f32Of : Val → Option Float32
  | .f32 x => some x
  | _ => none

def f16Of : Val → Option Float16.Value
  | .f16 x => some x
  | _ => none

/-- The lanes' registers as the contract's SIMD-group matrix operations take them: lane `l`'s
element `j`. -/
def regs {α : Type} (xs : List (α × α)) (d : α) (l : Fin 32) (j : Fin 2) : α :=
  let p := xs.getD l.val (d, d)
  if j.val = 0 then p.1 else p.2

/-- A lane's `simdgroup_multiply_accumulate` operands `[A, B, C]`. -/
def mmaOps : Val → Option (Val × Val × Val)
  | .vec _ [x, y, z] => some (x, y, z)
  | _ => none

/-- `simdgroup_multiply_accumulate` on the lanes' `[A, B, C]` operands (`A` of element type `a`,
`B` of `b`): each lane's `D` elements. -/
def mma (a b : Scalar) (ops : List (Val × Val × Val)) : Option (Fin 32 → Fin 2 → Float32) := do
  let cs ← ops.mapM fun o => pairOf f32Of o.2.2
  let c := regs cs (FloatMemory.decode 0)
  match a, b with
  | .f32, .f32 => do
    let as ← ops.mapM fun o => pairOf f32Of o.1
    let bs ← ops.mapM fun o => pairOf f32Of o.2.1
    pure (C.simdMma (regs as (FloatMemory.decode 0)) (regs bs (FloatMemory.decode 0)) c)
  | .f16, .f32 => do
    let as ← ops.mapM fun o => pairOf f16Of o.1
    let bs ← ops.mapM fun o => pairOf f32Of o.2.1
    pure (C.simdMmaHalfA (regs as (Val.ofF16Bits 0)) (regs bs (FloatMemory.decode 0)) c)
  | .f32, .f16 => do
    let as ← ops.mapM fun o => pairOf f32Of o.1
    let bs ← ops.mapM fun o => pairOf f16Of o.2.1
    pure (C.simdMmaHalfB (regs as (FloatMemory.decode 0)) (regs bs (Val.ofF16Bits 0)) c)
  | _, _ => none

/-- Result of a collective in every lane of a full SIMD-group. -/
def resolve (op : Collective) (s : Scalar) (delta : Nat) (values : List Val) : Option (List Val) :=
  if values.length ≠ 32 then none else
  match op, s with
  | .sum, .f32 => do
    let xs ← values.mapM fun | .f32 x => some x | _ => none
    let total := C.simdSum fun i => xs.getD i.val (FloatMemory.decode 0)
    some (List.replicate 32 (.f32 total))
  | .shuffleDown, _ => some ((List.range 32).map fun i => values.getD (if i + delta < 32 then i + delta else i) default)
  | .mma a b, .f32 => do
    let ops ← values.mapM mmaOps
    let d ← mma C a b ops
    some (List.ofFn fun l => .vec .f32 [.f32 (d l 0), .f32 (d l 1)])
  | _, _ => none

def blocked : Status → Bool
  | .barrier .. | .done => true | _ => false

/-- Run a SIMD-group's lanes until every lane is at a barrier or done. -/
def runSimd (fuel : Nat) : Nat → List Thread → M (List Thread)
  | 0, _ => failure
  | rounds + 1, lanes => do
    let lanes ← lanes.mapM (runThread C fuel)
    if lanes.all (blocked ·.status) then pure lanes else
    match lanes.map (collectiveOf ·.status) with
    | some key :: rest =>
      if rest.all (· = some key) then do
        let (_, op, s, delta) := key
        let values ← lift (lanes.mapM (valueOf ·.status))
        let results ← lift (resolve C op s delta values)
        let resumed ← lift ((lanes.zip results).mapM fun (t, v) => do
          let slot ← slotOf t.status
          pure ({ t with status := .running }.set slot v))
        runSimd fuel rounds resumed
      else failure
    | _ => failure

def barrierOf : Status → Option (Nat × Bool × Bool)
  | .barrier site d g => some (site, d, g)
  | _ => none

def isDone : Status → Bool
  | .done => true | _ => false

/-- Run a threadgroup (its SIMD-groups, in order) to completion. -/
def runGroup (fuel rounds : Nat) : Nat → List (List Thread) → M Unit
  | 0, _ => failure
  | barriers + 1, simds => do
    let simds ← simds.mapM (runSimd C fuel rounds)
    let threads := simds.flatten
    if threads.all (isDone ·.status) then pure () else
    match threads.map (barrierOf ·.status) with
    | some (site, d, g) :: rest =>
      if rest.all (· = some (site, d, g)) then do
        modify fun sh => { sh with
          deviceEpoch := if d then sh.deviceEpoch + 1 else sh.deviceEpoch,
          groupEpoch := if g then sh.groupEpoch + 1 else sh.groupEpoch }
        runGroup fuel rounds barriers (simds.map (·.map fun t => { t with status := .running }))
      else failure
    | _ => failure

end Metal
