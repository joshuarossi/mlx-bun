import host.mlx.Ffi
import host.mlx.NeuralEngine
namespace Host.Mlx.FfiAne
open Host.Ts
open Host.Mlx.Ffi (Node Prim Dim argNat argInt cstrArg handlesArg dimsArg natsOfDims dtSize setAt)

/-! # The Neural Engine bridge and its buffers in the FFI model

The bridge (packages/inference/native/ane-bridge.m) is trusted and entered
through its C functions; this module is the model of what each one does to
the buffers and programs the route uses (src/kernels/ane/linear.ts), and of
how MLX's evaluations of arrays over those buffers are ordered against the
Neural Engine's. It keeps no values: `FfiAneEval` gives the values.

* Surfaces (IOSurfaces): `mbane_program_create` allocates one per input and
  one output, each a whole number of 64 KiB units (`make_surface`), unless it
  shares another program's (`share`): an identical program (the same MIL and
  weights) is that program, with one more holder; any other loads on the
  share's surfaces, after the bridge's size check. Surface `i`'s base address
  is the number `addrOf i` (Bun returns a pointer as a number), page aligned
  and outside the ranges `hostAddr` decodes: JavaScript cannot read surface
  memory through the model.
* Programs: the loaded `AneProgram`, its surfaces, holders, the pending flag
  and the CPU locks. `mbane_input`/`mbane_output` lock and return the base
  address; `mbane_eval_async` returns 0 while an evaluation is pending,
  otherwise releases the locks and starts the evaluation (`Effect.start`: the
  program reads its input surfaces as they are then); `mbane_wait` joins it
  (`Effect.join`: the output surface holds the result) and returns 1. A run's
  evaluations are taken to succeed: the value semantics has no value past an
  evaluation the framework rejects (`NeuralEngine.eval = none`), where the
  bridge would return 0 and the route throw.
* Wraps: `mlx_array_new_data_managed_payload` on a surface's base address
  with the surface's whole size is a zero-copy MLX array over the surface
  (Metal maps a page-aligned, page-multiple region without a copy; the route
  wraps every surface whole). Its node has no value of its own (an operation
  name at arity zero, `surfaceName`); `aliases` records it.
* Nodes over surfaces, classified when created (`classify`): a slice of a
  rank-one alias with unit strides, a reshape of an alias, or an `astype` to
  the alias' own dtype is a view (MLX shares the buffer: no memory access when
  it runs, MLX v0.32.2 `Slice`/`Reshape::eval_gpu` on row-contiguous inputs,
  `astype` returning its input); a custom kernel whose aliased inputs are all
  wraps (MLX binds a row-contiguous input as is, so the kernel can write
  through it) and which has one output is a writer of those surfaces; an
  `astype` to another dtype, an elementwise or graph operation (`.unary`,
  `.binary`) or a concatenation is a reader (it reads its inputs into a fresh
  output when it runs; MLX donates no buffer shared with a live wrap). Any
  other node over a surface leaves the model stuck.
* Evaluation (`schedule`): `mlx_eval`, `mlx_async_eval`, `mlx_array_eval` and
  the readback `mlx_array_item_uint32` schedule every unscheduled ancestor of
  their arrays; the readers and writers among them form one `Effect.gpu` (in
  node order). A blocking call returns once its arrays are computed, so the
  readers and writers among their ancestors are complete; an asynchronous one
  leaves its readers and writers running until a later blocking call reaches
  them (or `mlx_synchronize`). Memory effects of a running node happen at some
  time before it completes, so the model is stuck on every pair it cannot
  order: a writer of a surface with another node touching it running or in
  the same evaluation, a reader with a writer running, a node touching a
  pending program's output surface, a writer of its input surfaces; and
  `mbane_eval_async` with a writer of an input surface or any node touching
  the output surface running, or with another pending program on one of its
  surfaces. In a completed run every effect on a surface is therefore ordered,
  and its time within its window does not matter.

The route's discipline passes these checks exactly as the code does it
(ane-prefill-split.ts mlpSplit and AneAffineSplit.forward; linear.ts): the
fills are written by one blocking `evalAll` before `evalAsync`; `evalAsync`
first settles the deferred reader (`Surfaces.settle`: `mlx_array_eval` of the
previous output's reader, which completes it), the GPU share is queued while
the Neural Engine runs and touches no surface, `wait` precedes the output's
wrap, slice, reshape and `astype`, and the sum is deferred (`deferOutput`)
until the next evaluation on the buffers. Rows past the written ones keep what
earlier calls left: surfaces are threaded whole.

Load and decode never call the bridge past `mbane_program_create` and never
wrap a surface: until the first wrap (`active`), every MLX call is
`Host.Mlx.Ffi.call` and the bridge state only records programs. -/

/-! ## State -/

/-- Bytes the bridge allocates for a buffer of `n` bytes (ane-bridge.m `make_surface`, linear.ts `allocated`). -/
def allocated (n : Nat) : Nat := bif Nat.blt n 65536 then 65536 else (n + 65535) / 65536 * 65536

def surfaceBase : Nat := 2 ^ 45
def surfaceSpan : Nat := 2 ^ 32

/-- Base address of surface `sid`. -/
def addrOf (sid : Nat) : Nat := surfaceBase + sid * surfaceSpan

/-- A program the bridge loaded (`mbane_program`): the program, its input
surfaces in MIL symbol order and its output surface, holders, the pending
flag, the CPU locks. -/
structure Program where
  prog : AneProgram
  ins : List Nat
  out : Nat
  holders : Nat
  pending : Bool
  inLocked : List Bool
  outLocked : Bool
deriving DecidableEq

/-- A node over a surface: the wrap itself, or a view of it. -/
inductive Alias where
  | wrap (sid : Nat)
  | view (sid : Nat)
deriving DecidableEq

def Alias.sid : Alias → Nat
  | .wrap s => s
  | .view s => s

def Alias.isWrap : Alias → Bool
  | .wrap _ => true
  | .view _ => false

/-- How a node touches surface memory when MLX runs it. -/
inductive Touch where
  | read (sids : List Nat)
  | write (sids : List Nat)
deriving DecidableEq

def Touch.sids : Touch → List Nat
  | .read s => s
  | .write s => s

def Touch.writes : Touch → Bool
  | .read _ => false
  | .write _ => true

/-- An effect on surface memory, in the order the run makes them. -/
inductive Effect where
  /-- One MLX evaluation runs these readers and writers (ascending). -/
  | gpu (nodes : List Nat)
  /-- `mbane_eval_async`: program `p` evaluates on its input surfaces as they are now. -/
  | start (p : Nat)
  /-- `mbane_wait`: program `p`'s output surface holds the evaluation's output. -/
  | join (p : Nat)
deriving DecidableEq

structure St where
  /-- Surface `i`'s allocated bytes. -/
  surfaces : List Nat
  programs : List Program
  /-- `mbane_program_create` call `n` (the load world's `HObj.ane n`) ↦ the program its handle is. -/
  handles : PTrie Nat
  /-- Some surface is wrapped. -/
  active : Bool
  aliases : PTrie Alias
  touch : PTrie Touch
  /-- Readers and writers MLX has not scheduled, ascending. -/
  unscheduled : List Nat
  /-- Readers and writers scheduled and not known complete. -/
  running : List Nat
  /-- Newest first. -/
  log : List Effect

def St.empty : St := ⟨[], [], .nil, false, .nil, .nil, [], [], []⟩

def memN (x : Nat) (l : List Nat) : Bool := l.any (Nat.beq x)

def St.surfaceSize (b : St) (sid : Nat) : Nat := nthD 0 b.surfaces sid

/-! ## Programs (`mbane_program_create`) -/

def alloc (b : St) (bytes : Nat) : Nat × St := (len b.surfaces, { b with surfaces := b.surfaces ++ [allocated bytes] })

def allocAll (b : St) : List Nat → List Nat × St
  | [] => ([], b)
  | n :: ns =>
    let (i, b) := alloc b n
    let (is, b) := allocAll b ns
    (i :: is, b)

/-- The program a create call names: the MIL text, no weight files (none on
the route), the input sizes (`inputCount` u64 cells), the output size. -/
def parseSpec : List Arg → Option AneProgram
  | [mil, wc, _, _, _, ic, sz, ob, _, _, _, _] =>
    match cstrArg mil, argNat wc, argNat ic, handlesArg sz ic, argNat ob with
    | some text, some 0, some k, some sizes, some out =>
      bif Nat.ble 1 k && Nat.ble k 8 then some ⟨text, [], sizes, out⟩ else none
    | _, _, _, _, _ => none
  | _ => none

/-- The bridge's check that a share's surfaces hold the program's buffers. -/
def fits (b : St) (q : Program) (p : AneProgram) : Bool :=
  Nat.ble (len p.inputBytes) (len q.ins) && Nat.ble p.outputBytes (b.surfaceSize q.out) &&
    (List.zip p.inputBytes q.ins).all fun (n, sid) => Nat.ble n (b.surfaceSize sid)

def fresh (p : AneProgram) (ins : List Nat) (out : Nat) : Program :=
  ⟨p, ins, out, 1, false, ins.map fun _ => false, false⟩

def addProgram (b : St) (n : Nat) (p : Program) : St :=
  { b with programs := b.programs ++ [p], handles := b.handles.set n (len b.programs) }

/-- `mbane_program_create` call `n` (`share`: the create call of the share's
handle). A call the bridge refuses (a malformed or unsupported program, a
share that does not fit or is released) records no program: the load world
still returns its handle, and a later use of it is stuck. -/
def create (b : St) (n : Nat) (args : List Arg) (share : Option Nat) : St :=
  match parseSpec args with
  | none => b
  | some p => match share with
    | none =>
      let (ins, b) := allocAll b p.inputBytes
      let (out, b) := alloc b p.outputBytes
      addProgram b n (fresh p ins out)
    | some m => match b.handles.get m with
      | none => b
      | some q => match nth? b.programs q with
        | none => b
        | some qp =>
          bif Nat.beq qp.holders 0 || !fits b qp p then b
          else bif decide (qp.prog.mil = p.mil) && decide (qp.prog.weights = p.weights) then
            { b with programs := setAt b.programs q { qp with holders := qp.holders + 1 }, handles := b.handles.set n q }
          else addProgram b n (fresh p (qp.ins.take (len p.inputBytes)) qp.out)

/-- The program create call `n`'s handle is, while held. -/
def program? (b : St) (n : Nat) : Option (Nat × Program) :=
  match b.handles.get n with
  | some q => match nth? b.programs q with
    | some p => bif Nat.beq p.holders 0 then none else some (q, p)
    | none => none
  | none => none

def setProgram (b : St) (q : Nat) (p : Program) : St := { b with programs := setAt b.programs q p }

/-- The bridge state of a load run from its FFI trace (newest first): the
create calls in order, a share decoded through the handles earlier creates
returned, as the load world numbers them (`HObj.ane n` for the `n`-th). -/
def ofTrace (t : List Host.Ts.Event) : St := go t.reverse St.empty [] 0
where
  go : List Host.Ts.Event → St → List (Nat × Nat) → Nat → St
    | [], b, _, _ => b
    | e :: es, b, regions, n =>
      bif nameEq e.sym chars!"mbane_program_create" then
        let share := match e.args with
          | [_, _, _, _, _, _, _, _, .extPtr r 0, _, _, _] => (regions.find? fun (x, _) => Nat.beq x r).map Prod.snd
          | _ => none
        let regions := match e.ret with
          | .ptr r 0 => (r, n) :: regions
          | _ => regions
        go es (create b n e.args share) regions (n + 1)
      else go es b regions n

/-! ## Ordering checks -/

def St.touchOf (b : St) (n : Nat) : Option Touch := b.touch.get n

/-- A running node touches surface `X`, writing it if `w`, or a running writer touches it. -/
def runningClash (b : St) (X : Nat) (w : Bool) : Bool :=
  b.running.any fun r => match b.touchOf r with
    | some t => memN X t.sids && (w || t.writes)
    | none => false

/-- A pending program writes `X` (its output), or reads it and `w`. -/
def pendingClash (b : St) (X : Nat) (w : Bool) : Bool :=
  b.programs.any fun p => p.pending && (Nat.beq p.out X || (w && memN X p.ins))

/-- The readers and writers of one evaluation are ordered against everything else. -/
def eventOk (b : St) (newly : List Nat) : Bool :=
  newly.all fun t => match b.touchOf t with
    | some k => k.sids.all fun X =>
        !pendingClash b X k.writes && !runningClash b X k.writes &&
        (!k.writes || Nat.beq (len (newly.filter fun u => match b.touchOf u with
          | some k' => memN X k'.sids
          | none => false)) 1)
    | none => false

/-- `mbane_eval_async` of program `q`: its inputs written, its output read, no other pending program on its surfaces. -/
def startOk (b : St) (q : Nat) (p : Program) : Bool :=
  p.ins.all (fun X => !runningClash b X false) && !runningClash b p.out true &&
    (b.programs.zipIdx.all fun (o, i) => Nat.beq i q || !o.pending ||
      !((o.out :: o.ins).any fun X => memN X (p.out :: p.ins)))

/-! ## Evaluation -/

/-- Push the inputs at or above `lo` not yet seen. -/
def pushIns (lo : Nat) : List Nat → List Nat → PTrie Bool → List Nat × PTrie Bool
  | [], st, seen => (st, seen)
  | i :: is, st, seen =>
    bif Nat.blt i lo || (seen.get i).isSome then pushIns lo is st seen
    else pushIns lo is (i :: st) (seen.set i true)

/-- Nodes at or above `lo` reachable from the stack (each pushed once). -/
def reach (s : Ffi.St) (lo : Nat) : Nat → List Nat → PTrie Bool → Option (PTrie Bool)
  | 0, _, _ => none
  | _ + 1, [], seen => some seen
  | f + 1, n :: st, seen => match s.nodes.get n with
    | some nd =>
      let (st, seen) := pushIns lo nd.ins st seen
      reach s lo f st seen
    | none => reach s lo f st seen

def reachOf (s : Ffi.St) (lo : Nat) (roots : List Nat) : Option (PTrie Bool) :=
  let (st, seen) := pushIns lo roots [] .nil
  reach s lo (s.nnext + len roots + 1) st seen

def minL : Nat → List Nat → Nat
  | m, [] => m
  | m, x :: xs => minL (bif Nat.blt x m then x else m) xs

/-- An evaluation of `roots`: the unscheduled readers and writers among their
ancestors run (one `Effect.gpu`); a blocking one completes every running
reader and writer among them. With none unscheduled, an asynchronous
evaluation (or any, with none running) changes nothing and walks no graph. -/
def schedule (b : St) (s : Ffi.St) (roots : List Nat) (blocking : Bool) : Option St :=
  bif b.unscheduled.isEmpty && (!blocking || b.running.isEmpty) then some b else
  match b.unscheduled ++ b.running with
  | [] => some b
  | t :: ts => match reachOf s (minL t ts) roots with
    | none => none
    | some seen =>
      let has := fun n => (seen.get n).isSome
      let newly := b.unscheduled.filter has
      bif eventOk b newly then
        let running := b.running ++ newly
        some { b with unscheduled := b.unscheduled.filter fun n => !has n,
                      running := bif blocking then running.filter fun n => !has n else running,
                      log := bif newly.isEmpty then b.log else .gpu newly :: b.log }
      else none

/-! ## Classification of new nodes -/

def St.aliasOf (b : St) (n : Nat) : Option Alias := b.aliases.get n

def aliasIns (b : St) : List Nat → List Alias
  | [] => []
  | i :: is => match b.aliasOf i with
    | some a => a :: aliasIns b is
    | none => aliasIns b is

def unitStrides (sr : List Dim) : Bool := sr.all fun d => decide (d = .lit 1)

def register (b : St) (n : Nat) (t : Touch) : St :=
  { b with touch := b.touch.set n t, unscheduled := b.unscheduled ++ [n] }

def asView (b : St) (n : Nat) (a : Alias) : St := { b with aliases := b.aliases.set n (.view a.sid) }

/-- A new node: unrelated to surfaces, a view, a reader or a writer (see above); stuck otherwise. -/
def classifyNode (b : St) (s : Ffi.St) (n : Nat) : Option St :=
  match s.nodes.get n with
  | none => some b
  | some nd => match aliasIns b nd.ins with
    | [] => some b
    | a :: as =>
      let sids := (a :: as).map Alias.sid
      match nd.prim, nd.ins with
      | .slice _ _ sr, [i] => match s.nodes.get i with
        | some src => bif Nat.beq (len src.shape) 1 && unitStrides sr then some (asView b n a) else none
        | none => none
      | .reshape _, [_] => some (asView b n a)
      | .astype d, [i] => match s.nodes.get i with
        | some src => bif Nat.beq src.dtype d then some (asView b n a) else some (register b n (.read sids))
        | none => none
      | .kernel _ c _, _ =>
        bif (a :: as).all Alias.isWrap && Nat.beq (len c.outs) 1 then some (register b n (.write sids)) else none
      | .unary _, _ => some (register b n (.read sids))
      | .binary _, _ => some (register b n (.read sids))
      | .concat _, _ => some (register b n (.read sids))
      | _, _ => none

/-- Classify nodes `n`, `n + 1`, … below `s.nnext` (fuel `f`). -/
def classify (b : St) (s : Ffi.St) : Nat → Nat → Option St
  | 0, _ => some b
  | f + 1, n => bif Nat.blt n s.nnext then (classifyNode b s n).bind fun b => classify b s f (n + 1) else some b

/-! ## Calls -/

def surfaceName (sid : Nat) : List Char := chars!"ane_surface:" ++ Nat.toDigits 10 sid

def sidOf (b : St) (a : Nat) : Option Nat :=
  bif Nat.ble surfaceBase a && Nat.beq ((a - surfaceBase) % surfaceSpan) 0 &&
      Nat.blt ((a - surfaceBase) / surfaceSpan) (len b.surfaces) then some ((a - surfaceBase) / surfaceSpan)
  else none

/-- The surface whose base address a pointer argument is. -/
def surfaceOf (b : St) : Arg → Option Nat
  | .num (.lit x) => (F64.toIndex? x).bind (sidOf b)
  | .big i => bif decide (0 ≤ i) then sidOf b i.toNat else none
  | _ => none

/-- `mlx_array_new_data_managed_payload(data, shape, ndim, dtype, payload, dtor)` on a surface, whole. -/
def wrap (b : St) (s : Ffi.St) (args : List Arg) : Option (Ffi.St × St × Ret) :=
  match args with
  | [p, sh, nd, dt, _, _] => match surfaceOf b p, dimsArg sh nd, argNat dt with
    | some sid, some shape, some dt => match natsOfDims shape with
      | some ds =>
        bif Nat.beq (ds.foldr (· * ·) 1 * dtSize dt) (b.surfaceSize sid) then
          let (node, s) := s.addNode ⟨.unary (surfaceName sid), [], shape, dt⟩
          let (h, s) := s.setArr 0 node
          some (s, { b with active := true, aliases := b.aliases.set node (.wrap sid) }, .big h)
        else none
      | none => none
    | _, _, _ => none
  | _ => none

def addrRet (sid : Nat) : Ret := .num (.lit (F64.ofNat (addrOf sid)))

/-- `mbane_input(h, i)`: write-locks input `i` and returns its base address (null out of range). -/
def input (b : St) (n : Nat) (i : Arg) : Option (St × Ret) :=
  match program? b n, argInt i with
  | some (q, p), some i =>
    bif decide (0 ≤ i) && Nat.blt i.toNat (len p.ins) then
      some (setProgram b q { p with inLocked := setAt p.inLocked i.toNat true }, addrRet (nthD 0 p.ins i.toNat))
    else some (b, .null)
  | _, _ => none

/-- `mbane_output(h)`: read-locks the output and returns its base address. -/
def output (b : St) (n : Nat) : Option (St × Ret) :=
  (program? b n).map fun (q, p) => (setProgram b q { p with outLocked := true }, addrRet p.out)

/-- `mbane_eval_async(h)`. -/
def evalAsync (b : St) (n : Nat) : Option (St × Ret) :=
  match program? b n with
  | some (q, p) =>
    bif p.pending then some (b, .num zeroN)
    else bif startOk b q p then
      some ({ setProgram b q { p with pending := true, inLocked := p.inLocked.map fun _ => false, outLocked := false }
              with log := .start q :: b.log }, .num one)
    else none
  | none => none

/-- `mbane_wait(h, err, n)`. -/
def wait (b : St) (n : Nat) : Option (St × Ret) :=
  match program? b n with
  | some (q, p) =>
    bif p.pending then some ({ setProgram b q { p with pending := false } with log := .join q :: b.log }, .num one)
    else some (b, .num one)
  | none => none

/-- `mbane_free(h)`: one holder fewer; the last waits for a pending evaluation and releases the locks. -/
def free (b : St) (n : Nat) : Option (St × Ret) :=
  (program? b n).map fun (q, p) =>
    bif Nat.beq p.holders 1 then
      ({ setProgram b q { p with holders := 0, pending := false, inLocked := p.inLocked.map fun _ => false, outLocked := false }
         with log := bif p.pending then .join q :: b.log else b.log }, .void)
    else (setProgram b q { p with holders := p.holders - 1 }, .void)

/-- The arrays an evaluating call names and whether it blocks. -/
inductive EvalCall where
  | roots (ns : List Nat) (blocking : Bool)
  | all
  | other

def vecRoots (s : Ffi.St) (v : Arg) : List Nat :=
  match (argNat v).bind s.obj? with
  | some (.vec ns) => ns
  | _ => []

def arrRoot (s : Ffi.St) (h : Arg) : List Nat :=
  match (argNat h).bind s.nodeId? with
  | some n => [n]
  | none => []

def evalCall (s : Ffi.St) (name : Name) (args : List Arg) : EvalCall :=
  bif nameEq name chars!"mlx_eval" then (match args with | [v] => .roots (vecRoots s v) true | _ => .other)
  else bif nameEq name chars!"mlx_async_eval" then (match args with | [v] => .roots (vecRoots s v) false | _ => .other)
  else bif nameEq name chars!"mlx_array_eval" then (match args with | [h] => .roots (arrRoot s h) true | _ => .other)
  else bif nameEq name chars!"mlx_array_item_uint32" then (match args with | [_, h] => .roots (arrRoot s h) true | _ => .other)
  else bif nameEq name chars!"mlx_synchronize" then .all
  else .other

/-- The bridge state after MLX call `name` took the mlx state from `s` to `s'`. -/
def after (b : St) (s s' : Ffi.St) (name : Name) (args : List Arg) : Option St :=
  match evalCall s name args with
  | .roots ns blocking => schedule b s ns blocking
  | .all => some { b with running := [] }
  | .other => classify b s' (s'.nnext - s.nnext) s.nnext

abbrev Writes := List (Nat × Nat × List Byte)

def payloadName : List Char := chars!"mlx_array_new_data_managed_payload"

/-- An MLX call: a surface wrap, else `Host.Mlx.Ffi.call` and, once a surface
is wrapped, its effect on the bridge state. -/
def mlxCall (b : St) (s : Ffi.St) (name : Name) (args : List Arg) : M (Option (Ffi.St × St × Ret × Writes)) :=
  bif nameEq name payloadName then .pure ((wrap b s args).map fun (s, b, r) => (s, b, r, []))
  else .bind (Ffi.call s name args) fun
    | some (s', r, ws) => .pure (bif b.active then (after b s s' name args).map fun b => (s', b, r, ws) else some (s', b, r, ws))
    | none => .pure none

/-- A trace continuation (`Host.Mlx.Ffi.back`): its replayed nodes classified. -/
def back (b : St) (s : Ffi.St) (a : Arg) : M (Option (Ffi.St × St × Ret × Writes)) :=
  .bind (Ffi.back s a) fun
    | some (s', r, ws) =>
      .pure (bif b.active then (classify b s' (s'.nnext - s.nnext) s.nnext).map fun b => (s', b, r, ws) else some (s', b, r, ws))
    | none => .pure none

end Host.Mlx.FfiAne
