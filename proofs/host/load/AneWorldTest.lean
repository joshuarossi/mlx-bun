import host.load.AneWorld
import host.mlx.FfiAneEval
namespace Host.Load.Ane.Test
open Host.Ts Host.Load Host.Mlx
open Host.Mlx.FfiAne (Effect Touch Alias)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # One MLP split call through the extended world, on a small instance

The FFI calls `mlpSplit` (ane-prefill-split.ts) makes, in order, for a program
of four inputs (wd, wg, wu: 32 bytes; x: 16) and a 16-byte output, one 64 KiB
surface each: the input wraps, the four fills (two trellis fills' kernel
object, one shared by the down fill here, and the half writer), the blocking
`evalAll`, `evalAsync`, the GPU share's asynchronous evaluation, `wait`, the
output's wrap, slice, reshape and cast, the sum, and the layer's
asynchronous evaluation. Checked by the kernel: the effects the bridge logs,
the classification of the nodes, and the stuck runs that break the ordering
discipline. `readback_instance` applies the value statement to the run's
graph. -/

def litN (n : Nat) : NumV := .lit (F64.ofNat n)
def num (n : Nat) : Arg := .num (litN n)
def u64s (xs : List Nat) : List Byte := xs.flatMap fun x => cellParts .u64 (.big x) 8 0
def i32s (xs : List Int) : List Byte := xs.flatMap fun x => cellParts .i32 (.num (.lit (F64.ofInt x))) 4 0
def cstr (s : List Char) : List Byte := (s.map fun c => Byte.lit c.toNat) ++ [.lit 0]
def slot : Arg := .jsPtr 30 0 (u64s [0])
def ints (xs : List Int) : Arg := .jsPtr 31 0 (i32s xs)

def fillName : List Char := chars!"mlx_bun_ane_trellis_fill"
def writeName : List Char := chars!"mlx_bun_ane_write_half"

def add (s : Ffi.St) (nd : Ffi.Node) : Ffi.St := let (n, s) := s.addNode nd; (s.setArr 0 n).2

/-- Nodes 1–4 (handles 1–4): codes, scales, the flat hidden rows, the GPU
partial; kernel objects 5 (fill) and 6 (half writer); configuration 7 (one
int32 `[1]` output). -/
def base : Ffi.St :=
  let s := Ffi.init [] [] [] []
  let s := add s ⟨.load ['f'] ['c'], [], [.lit 4, .lit 8], Ffi.dtUint32⟩
  let s := add s ⟨.load ['f'] ['s'], [], [.lit 4], Ffi.dtF16⟩
  let s := add s ⟨.load ['f'] ['h'], [], [.lit 8], Ffi.dtBf16⟩
  let s := add s ⟨.load ['f'] ['g'], [], [.lit 2, .lit 4], Ffi.dtBf16⟩
  let (_, s) := s.newObj (.kernel fillName chars!"fill" [] 3 1)
  let (_, s) := s.newObj (.kernel writeName chars!"write" [] 2 1)
  let (_, s) := s.newObj (.cfg ⟨[([.lit 1], Ffi.dtInt32)], [litN 32, litN 4, litN 1], [litN 32, litN 1, litN 1], [], [], none⟩)
  s

def s0 : ASt := ⟨⟨base, HostSt.init [] [] [] 0 [] []⟩, FfiAne.St.empty⟩

def step (s : ASt) (name : List Char) (args : List Arg) : Option (ASt × Ret × List (Nat × Nat × List Byte)) :=
  match (call s name args).run with
  | .pure r => r
  | _ => none

def argOf : Ret → Arg
  | .num x => .num x
  | .big i => .big i
  | .ptr r off => .extPtr r off
  | _ => .null

/-- The handle an operation wrote into its result slot. -/
def written : List (Nat × Nat × List Byte) → Arg
  | (_, _, bs) :: _ => match readCell .u64 bs with
    | some (.big h) => .big h
    | _ => .null
  | [] => .null

def natOf : Arg → Nat
  | .big i => i.toNat
  | _ => 0

def vecOf (s : ASt) (hs : List Nat) : Option (ASt × Arg) := do
  let (s, r, _) ← step s chars!"mlx_vector_array_new_data" [.jsPtr 32 0 (u64s hs), .big hs.length]
  pure (s, argOf r)

/-- `kernel.apply([...], ...)` and the output's handle. -/
def fill (s : ASt) (kernel : Nat) (ins : List Nat) : Option (ASt × Arg) := do
  let (s, v) ← vecOf s ins
  let (s, _, ws) ← step s chars!"mlx_fast_metal_kernel_apply" [slot, .big kernel, v, .big 7, .big 0]
  let (s, _, ws') ← step s chars!"mlx_vector_array_get" [slot, written ws, num 0]
  pure (s, written ws')

/-- `MlxArray.fromPointer(address, [32768], float16)`. -/
def wrapAt (s : ASt) (addr : Ret) : Option (ASt × Arg) := do
  let (s, w, _) ← step s FfiAne.payloadName [argOf addr, ints [32768], num 1, num Ffi.dtF16, num 0, num 4096]
  pure (s, argOf w)

def createArgs : List Arg :=
  [.jsPtr 20 0 (cstr chars!"mil"), num 0, .null, .null, .null, num 4, .jsPtr 21 0 (u64s [32, 32, 32, 16]), num 16, .null,
   .jsPtr 22 0 (i32s [0]), .jsPtr 23 0 (u64s [0]), num 8]

/-- Load: `AneProgram.create`. -/
def loaded : Option (ASt × Arg) := do
  let (s, h, _) ← step s0 chars!"mbane_program_create" createArgs
  pure (s, argOf h)

/-- The fills of one call (`inputArray(0..3)` wrap on first use) and their handles. -/
def fills (s : ASt) (h : Arg) (wraps : Option (List Arg)) (src : Nat) : Option (ASt × List Arg × List Arg) := do
  let (s, ws) ← match wraps with
    | some ws => pure (s, ws)
    | none => do
      let (s, a0, _) ← step s chars!"mbane_input" [h, num 0]
      let (s, w0) ← wrapAt s a0
      let (s, a1, _) ← step s chars!"mbane_input" [h, num 1]
      let (s, w1) ← wrapAt s a1
      let (s, a2, _) ← step s chars!"mbane_input" [h, num 2]
      let (s, w2) ← wrapAt s a2
      let (s, a3, _) ← step s chars!"mbane_input" [h, num 3]
      let (s, w3) ← wrapAt s a3
      pure (s, [w0, w1, w2, w3])
  let (s, d0) ← fill s 5 [1, 2, natOf (ws.getD 0 .null)]
  let (s, d1) ← fill s 5 [1, 2, natOf (ws.getD 1 .null)]
  let (s, d2) ← fill s 5 [1, 2, natOf (ws.getD 2 .null)]
  let (s, d3) ← fill s 6 [src, natOf (ws.getD 3 .null)]
  pure (s, ws, [d0, d1, d2, d3])

/-- The rest of the call after the fills' evaluation: `evalAsync` (after
settling the previous sum, if any), the GPU share, `wait`, `output([2, 4])`
(the output wrap made on first use, `Surfaces.output`), the cast and the sum,
the layer's asynchronous evaluation; the output wrap and the sum's handle. -/
def finish (s : ASt) (h : Arg) (wo : Option Arg) (settle : Option Arg) : Option (ASt × Arg × Arg) := do
  let s ← match settle with
    | some r => do let (s, _, _) ← step s chars!"mlx_array_eval" [r]; pure s
    | none => pure s
  let (s, ok, _) ← step s chars!"mbane_eval_async" [h]
  match ok with
  | .num x => if x = litN 1 then pure () else none
  | _ => none
  let (s, g) ← vecOf s [4]
  let (s, _, _) ← step s chars!"mlx_async_eval" [g]
  let (s, _, _) ← step s chars!"mbane_wait" [h, .jsPtr 23 0 (u64s [0]), num 8]
  let (s, ao, _) ← step s chars!"mbane_output" [h]
  let (s, wo) ← match wo with
    | some w => pure (s, w)
    | none => wrapAt s ao
  let (s, _, ws) ← step s chars!"mlx_slice" [slot, wo, ints [0], .big 1, ints [8], .big 1, ints [1], .big 1, .big 0]
  let (s, _, ws) ← step s chars!"mlx_reshape" [slot, written ws, ints [2, 4], .big 2, .big 0]
  let (s, _, ws) ← step s chars!"mlx_astype" [slot, written ws, num Ffi.dtBf16, .big 0]
  let b := written ws
  let (s, _, ws) ← step s chars!"mlx_reshape" [slot, .big 4, ints [2, 4], .big 2, .big 0]
  let (s, _, ws) ← step s chars!"mlx_add" [slot, b, written ws, .big 0]
  let sum := written ws
  let (s, v) ← vecOf s [natOf sum]
  let (s, _, _) ← step s chars!"mlx_async_eval" [v]
  pure (s, wo, sum)

/-- One call: the fills of the hidden rows written by one evaluation
(blocking: `evalAll`), then `finish`; the input wraps, the output wrap, the sum. -/
def mlpCall (s : ASt) (h : Arg) (wraps : Option (List Arg × Arg)) (blocking : Bool) (settle : Option Arg) :
    Option (ASt × (List Arg × Arg) × Arg) := do
  let (s, ws, ds) ← fills s h (wraps.map Prod.fst) 3
  let (s, v) ← vecOf s (ds.map natOf)
  let (s, _, _) ← step s (if blocking then chars!"mlx_eval" else chars!"mlx_async_eval") [v]
  let (s, wo, sum) ← finish s h (wraps.map Prod.snd) settle
  pure (s, (ws, wo), sum)

def handle : Arg := .extPtr (region 512) 0

def call1 : Option (ASt × (List Arg × Arg) × Arg) := do
  let (s, h) ← loaded
  mlpCall s h none true none

/-! ## The bridge's log and classification -/

def log1 : List Effect := [.gpu [16], .join 0, .start 0, .gpu [9, 10, 11, 12]]

/-- The run: the four fills in one evaluation, the program's evaluation and join, the reader in the layer's
asynchronous evaluation (still running: its value is read when it runs, after the join). -/
theorem call1_log : (call1.map fun (s, _, _) => (s.bridge.log, s.bridge.running, s.bridge.unscheduled)) =
    some (log1, [16], []) := by decide +kernel

/-- The wraps (nodes 5–8 the inputs, 13 the output), the views (14 the slice, 15 the reshape), the writers
(9–12, one surface each), the reader (16, the cast); the GPU partial's reshape (17) and the sum (18) are pure. -/
theorem call1_nodes : (call1.map fun (s, _, _) =>
      ([5, 6, 7, 8, 13, 14, 15].map s.bridge.aliases.get, [9, 10, 11, 12, 16, 17, 18].map s.bridge.touch.get)) =
    some ([some (.wrap 0), some (.wrap 1), some (.wrap 2), some (.wrap 3), some (.wrap 4), some (.view 4),
        some (.view 4)],
      [some (.write [0]), some (.write [1]), some (.write [2]), some (.write [3]), some (.read [4]), none, none]) := by
  decide +kernel

/-- The next call on the same buffers (its fills not reading the previous sum): with `Surfaces.settle`
(`mlx_array_eval` of the deferred sum before `mbane_eval_async`) it runs; without, the previous reader still
runs when the program would overwrite its output, and the model is stuck. -/
theorem call2_settled : ((call1.bind fun (s, ws, sum) => mlpCall s handle (some ws) true (some sum)).map
    fun (s, _, _) => s.bridge.log.take 4) = some [.gpu [25], .join 0, .start 0, .gpu [19, 20, 21, 22]] := by decide +kernel

theorem call2_unsettled : (call1.bind fun (s, ws, _) => mlpCall s handle (some ws) true none).isNone = true := by
  decide +kernel

/-- Fills written by an asynchronous evaluation: still running at `mbane_eval_async`, stuck. -/
theorem async_fills_stuck : (loaded.bind fun (s, h) => mlpCall s h none false none).isNone = true := by decide +kernel

/-- Reading the output while the program is pending (before `mbane_wait`): stuck. -/
def readPending : Option ASt := do
  let (s, h) ← loaded
  let (s, _, ds) ← fills s h none 3
  let (s, v) ← vecOf s (ds.map natOf)
  let (s, _, _) ← step s chars!"mlx_eval" [v]
  let (s, _, _) ← step s chars!"mbane_eval_async" [h]
  let (s, ao, _) ← step s chars!"mbane_output" [h]
  let (s, wo) ← wrapAt s ao
  let (s, _, ws) ← step s chars!"mlx_astype" [slot, wo, num Ffi.dtBf16, .big 0]
  let (s, v) ← vecOf s [natOf (written ws)]
  let (s, _, _) ← step s chars!"mlx_async_eval" [v]
  pure s

theorem read_pending_stuck : readPending.isNone = true := by decide +kernel

/-- A transpose of a wrap (an MLX view the model does not cover): stuck. -/
def transposed : Option ASt := do
  let (s, h) ← loaded
  let (s, a, _) ← step s chars!"mbane_input" [h, num 0]
  let (s, w) ← wrapAt s a
  let (s, _, _) ← step s chars!"mlx_transpose_axes" [slot, w, ints [0], .big 1, .big 0]
  pure s

theorem transpose_stuck : transposed.isNone = true := by decide +kernel

def numRet : Ret → Option NumV
  | .num x => some x
  | _ => none

/-- `mbane_input` returns surface 0's base address. -/
theorem input_address : (loaded.bind fun (s, h) => (step s chars!"mbane_input" [h, num 0]).bind fun (_, r, _) => numRet r) =
    some (.lit (F64.ofNat (FfiAne.addrOf 0))) := by decide +kernel

/-! ## The value statement on this run's graph -/

open FfiEval FfiAneEval Inference.Contracts.Mlx

def nums : Nums Int := concrete fun
  | .lit f => some f
  | .ref _ => none

def ksrc : KernelSources := ⟨fun _ => [], fun _ => []⟩
def isrc : InPlaceSources := ⟨fun k => if k = .writeHalf then chars!"write" else chars!"fill", fun _ => []⟩

def state1 : ASt := match call1 with
  | some (s, _, _) => s
  | none => s0

def graph1 : Graph := Graph.ofState nums ksrc isrc state1.base.mlx state1.bridge

def prog1 : FfiAne.Program :=
  ⟨⟨chars!"mil", [], [32, 32, 32, 16], 16⟩, [0, 1, 2, 3], 4, 1, false, [false, false, false, false], true⟩

deriving instance DecidableEq for Config
deriving instance DecidableEq for Writer

def cfg1 : Config := ⟨[([1], .int32)], (32, 4, 1), (32, 1, 1), [], [], none⟩

theorem graph1_facts :
    graph1.program 0 = some prog1 ∧ state1.bridge.log = log1 ∧
    [1, 2, 3, 16].map graph1.node =
      [some ⟨.load ['f'] ['c'], []⟩, some ⟨.load ['f'] ['s'], []⟩, some ⟨.load ['f'] ['h'], []⟩,
        some ⟨.astype Ffi.dtBf16, [15]⟩] ∧
    [1, 2, 3, 5, 6, 7, 8, 13, 14, 15].map graph1.aliasOf =
      [none, none, none, some (.wrap 0), some (.wrap 1), some (.wrap 2), some (.wrap 3), some (.wrap 4),
        some (.view 4), some (.view 4)] ∧
    [1, 2, 3, 9, 10, 11, 12, 16].map graph1.touch =
      [none, none, none, some (.write [0]), some (.write [1]), some (.write [2]), some (.write [3]), some (.read [4])] ∧
    [5, 6, 7, 8, 13].map graph1.wrapType = List.replicate 5 (some (.float16, [32768])) ∧
    graph1.node 14 = some ⟨.slice [0] [((2 * 4 : Nat) : Int)] [1], [13]⟩ ∧
    graph1.node 15 = some ⟨.reshape [((2 : Nat) : Int), ((4 : Nat) : Int)], [14]⟩ := by
  decide +kernel

theorem graph1_writers : [9, 10, 11, 12].map graph1.writer =
    [some ⟨.trellisFill, cfg1, [1, 2] ++ [5]⟩, some ⟨.trellisFill, cfg1, [1, 2] ++ [6]⟩,
      some ⟨.trellisFill, cfg1, [1, 2] ++ [7]⟩, some ⟨.writeHalf, cfg1, [3] ++ [8]⟩] := by
  decide +kernel

/-- **`mlpSplit_rows` on this run**: from any memory (the surfaces' contents
arbitrary, stale bytes included), given the checkpoint tensors' values and the
in-place launches' final contents on the surfaces as they are (the kernel
contract's part), the log the bridge recorded runs, and the reader's value is
the bf16 of the Neural Engine's output halves on the filled surfaces. -/
theorem readback_instance {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C)
    (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled) (NE : NeuralEngine)
    (IP : InPlace) (m : FfiAneEval.Mem) (codes scales hidden : Value)
    (hc : weights ['f'] ['c'] = some codes) (hs : weights ['f'] ['s'] = some scales)
    (hh : weights ['f'] ['h'] = some hidden)
    (res0 res1 res2 res3 : List ByteMemory.Bytes) (R0 R1 R2 R3 o0 o1 o2 o3 : ByteMemory.Bytes)
    (l0 : IP.launchAll .trellisFill [codes, scales, surfaceValue (m.surf 0) .float16 [32768]] cfg1 = some res0)
    (r0 : res0[2]? = some R0) (e0 : res0[3]? = some o0)
    (l1 : IP.launchAll .trellisFill [codes, scales, surfaceValue (m.surf 1) .float16 [32768]] cfg1 = some res1)
    (r1 : res1[2]? = some R1) (e1 : res1[3]? = some o1)
    (l2 : IP.launchAll .trellisFill [codes, scales, surfaceValue (m.surf 2) .float16 [32768]] cfg1 = some res2)
    (r2 : res2[2]? = some R2) (e2 : res2[3]? = some o2)
    (l3 : IP.launchAll .writeHalf [hidden, surfaceValue (m.surf 3) .float16 [32768]] cfg1 = some res3)
    (r3 : res3[1]? = some R3) (e3 : res3[2]? = some o3)
    (out : Surface) (hne : NE.eval prog1.prog [toSurface R0, toSurface R1, toSurface R2, toSurface R3] = some out) :
    ∃ m' y, run P K weights kind NE IP graph1 m state1.bridge.log.reverse = some m' ∧
      m'.vals 16 = some y ∧ y.dtype = .bfloat16 ∧ y.shape = [2, 4] ∧
      ∀ i, i < 2 * 4 → y.elems i = bfWord (halfToBf (f16 (out (i * 2) + out (i * 2 + 1) * 256))) := by
  obtain ⟨hp, hlog, hn, ha, ht, hwt, h14, h15⟩ := graph1_facts
  have hw := graph1_writers
  simp only [List.map_cons, List.map_nil, List.cons.injEq, List.replicate_succ, List.replicate_zero] at hn ha ht hwt hw
  obtain ⟨hn1, hn2, hn3, hn16, -⟩ := hn
  obtain ⟨ha1, ha2, ha3, ha5, ha6, ha7, ha8, ha13, ha14, ha15, -⟩ := ha
  obtain ⟨ht1, ht2, ht3, ht9, ht10, ht11, ht12, ht16, -⟩ := ht
  obtain ⟨hwt5, hwt6, hwt7, hwt8, hwt13, -⟩ := hwt
  obtain ⟨hw9, hw10, hw11, hw12, -⟩ := hw
  have pv : ∀ (m' : FfiAneEval.Mem) (j : Nat) (f k : List Char) (v : Value), graph1.node j = some ⟨.load f k, []⟩ →
      graph1.touch j = none → weights f k = some v → pureVal P K weights kind graph1 m' j = some v :=
    fun m' j f k v h1 h2 h3 => pureVal_load P K weights kind graph1 m' j f k v h1 h2 h3
  have hcs : ∀ m' : FfiAneEval.Mem, (∀ j, j < 9 → m'.vals j = m.vals j) →
      [1, 2].mapM (pureVal P K weights kind graph1 m') = some [codes, scales] := fun m' _ => by
    simp [pv m' 1 _ _ codes hn1 ht1 hc, pv m' 2 _ _ scales hn2 ht2 hs]
  have hx : ∀ m' : FfiAneEval.Mem, (∀ j, j < 9 → m'.vals j = m.vals j) →
      [3].mapM (pureVal P K weights kind graph1 m') = some [hidden] := fun m' _ => by
    simp [pv m' 3 _ _ hidden hn3 ht3 hh]
  have pre12 : ∀ j ∈ [1, 2], graph1.aliasOf j = none := by simp [ha1, ha2]
  have pre3 : ∀ j ∈ [3], graph1.aliasOf j = none := by simp [ha3]
  have f0 := FillAt.of_launch P K weights kind IP graph1 m 9 9 0 5 .trellisFill cfg1 [1, 2] [codes, scales] .float16
    [32768] ([1], .int32) res0 R0 o0 ht9 hw9 ha5 hwt5 pre12 hcs l0 rfl r0 e0
  have f1 := FillAt.of_launch P K weights kind IP graph1 m 9 10 1 6 .trellisFill cfg1 [1, 2] [codes, scales] .float16
    [32768] ([1], .int32) res1 R1 o1 ht10 hw10 ha6 hwt6 pre12 hcs l1 rfl r1 e1
  have f2 := FillAt.of_launch P K weights kind IP graph1 m 9 11 2 7 .trellisFill cfg1 [1, 2] [codes, scales] .float16
    [32768] ([1], .int32) res2 R2 o2 ht11 hw11 ha7 hwt7 pre12 hcs l2 rfl r2 e2
  have f3 := FillAt.of_launch P K weights kind IP graph1 m 9 12 3 8 .writeHalf cfg1 [3] [hidden] .float16
    [32768] ([1], .int32) res3 R3 o3 ht12 hw12 ha8 hwt8 pre3 hx l3 rfl r3 e3
  have hb : ReadAt P K weights graph1 16 15 4 32768 2 4 :=
    ⟨ht16, hn16, by simp [ha15], fun m' => aliasVal_readView P K weights graph1 m' 13 14 15 4 32768 2 4 ha13 hwt13
      ha14 h14 (by decide) ha15 h15 (by decide)⟩
  rw [hlog]
  exact mlpSplit_rows P K weights kind NE IP graph1 m 0 prog1 hp 0 1 2 3 4 rfl rfl (by decide) 9 9 10 11 12
    R0 R1 R2 R3 (Nat.le_refl 9) (by decide) (by decide) (by decide) f0 f1 f2 f3 out hne 16 15 32768 2 4 (by decide)
    hb (by decide) (by decide)

end Host.Load.Ane.Test
