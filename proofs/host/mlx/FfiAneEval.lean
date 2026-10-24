import host.mlx.FfiAne
import host.mlx.FfiEvalPrefill
import metal.Gpu
import host.mlx.InPlace
import host.mlx.FfiEvalRoute
namespace Host.Mlx.FfiAneEval
open Inference.Contracts.Mlx
open Host.Mlx.FfiEval
open Host.Mlx.FfiAne (Alias Touch Effect Program)

/-! # Values of the graph over the Neural Engine's buffers

`FfiEval` gives every node of the FFI graph a value that does not depend on
time. A node over an IOSurface (`FfiAne`) has the value of the surface's bytes
when MLX runs it, and the route writes those bytes in place (GPU kernels
through an input, the Neural Engine's output). This module evaluates the
graph with the effects in the order the run made them (the bridge's log):

* `Mem`: every surface's whole contents (stale bytes included: nothing is
  assumed about which bytes a program reads), the values of the readers and
  writers fixed when they ran, and each started program's output.
* `Effect.gpu ns`: each reader and writer in turn, its inputs' values from
  the memory then: an alias input (`aliasVal`) is the surface's current bytes
  through its views, any other input its value in the pure semantics
  (`pureVal`: `evalRP` on the graph whose readers and writers are leaves
  holding their fixed values). A reader applies its primitive (`primEvalP`);
  a writer is the in-place launch (`InPlace`): its wrapped inputs' final
  contents become the surfaces', its output its value.
* `Effect.start p`: the evaluation `NeuralEngine.eval` of program `p` on its
  input surfaces as they are; `Effect.join p`: its output surface holds the
  evaluation's first `outputBytes` bytes (the rest as before).
* Every node that touches no surface keeps the pure semantics (`valueOf`).

The bridge model's checks make every pair of effects on a surface ordered in
a completed run, so applying each at its place in the log is MLX's and the
Neural Engine's behaviour. `mlpSplit_readback` is one MLP split call
(ane-prefill-split.ts mlpSplit) on this semantics. -/

/-! ## Surfaces as arrays -/

/-- A surface read as `shape` little-endian elements of `dt` from byte 0 (the wrap's value). -/
def surfaceValue (S : Surface) (dt : Dtype) (shape : List Nat) : Value :=
  ⟨dt, shape, fun i => (List.range dt.bytes).foldr (fun k acc => S (i * dt.bytes + k) * 256 ^ k + acc) 0⟩

def toSurface (B : ByteMemory.Bytes) : Surface := fun b => (B b).toNat

/-- The first `n` bytes from `out`, the rest from `old`. -/
def overlay (out : Surface) (n : Nat) (old : Surface) : Surface := fun b => if b < n then out b else old b

def upd {α : Type} (f : Nat → α) (k : Nat) (v : α) : Nat → α := fun j => if j = k then v else f j

/-! ## The graph with its surfaces -/

/-- A writer: the in-place kernel, the launch configuration, its inputs. -/
structure Writer where
  kernel : InPlaceKernel
  cfg : Config
  ins : List Nat

structure Graph where
  /-- Resolved nodes (`ffiGraphR`: the route's kernel table). -/
  node : Nat → Option (RNode Int Nat)
  writer : Nat → Option Writer
  aliasOf : Nat → Option Alias
  touch : Nat → Option Touch
  /-- A wrap's dtype and shape. -/
  wrapType : Nat → Option (Dtype × List Nat)
  program : Nat → Option Program

/-- A writer of the FFI graph: a one-output in-place kernel whose object has the route's body. -/
def writerOf (N : Nums Int) (IS : InPlaceSources) (s : Ffi.St) (n : Nat) : Option Writer :=
  (s.nodes.get n).bind fun nd => match nd.prim with
    | .kernel kh cfg 0 => match s.obj? kh with
      | some (.kernel name src hdr _ _) => (inPlaceOf name).bind fun k =>
        if src = IS.source k ∧ hdr = IS.header k then ((resolveCfg N cfg).bind toConfig).map fun c => ⟨k, c, nd.ins⟩
        else none
      | _ => none
    | _ => none

/-- The graph of an FFI state and its bridge state, its nodes resolved with the route's kernel table (`ffiGraphR`:
every node the decode resolution `ffiGraphP N S s` resolves, as it resolves it, and the prefill kernels' nodes). -/
def Graph.ofState (N : Nums Int) (S : KernelSources) (IS : InPlaceSources) (s : Ffi.St) (b : FfiAne.St) : Graph where
  node := ffiGraphR N S s
  writer := writerOf N IS s
  aliasOf := b.aliases.get
  touch := b.touch.get
  wrapType := fun j => (s.nodes.get j).bind fun nd =>
    (Dtype.ofCode nd.dtype).bind fun dt => ((nd.shape.mapM N.d).bind natShape).map (dt, ·)
  program := Host.Ts.nth? b.programs

/-- The pure graph: readers and writers are leaves (`input` of their own id). -/
def Graph.pure (G : Graph) (j : Nat) : Option (RNode Int Nat) :=
  if (G.touch j).isSome then some ⟨.input j, []⟩ else G.node j

/-! ## The semantics -/

structure Mem where
  surf : Nat → Surface
  vals : Nat → Option Value
  pend : Nat → Option Surface

/-! ## The decode evaluator's values (at a decode contract) -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : KernelContract C) (kind : Nat → Option Compiled)

theorem primEvalP_astype (env : Env Nat) (d : Nat) (v : Value) :
    primEvalP P K env (.astype d) [v] = (Dtype.ofCode d).bind (astypeV v) := by
  simp [primEvalP, primEval, rowsEval]

theorem primEvalP_slice (env : Env Nat) (st sp sr : List Int) (v : Value) :
    primEvalP P K env (.slice st sp sr) [v] = primEval P.toMlxContract K env (.slice st sp sr) [v] := by
  simp only [primEvalP]
  cases primEval P.toMlxContract K env (.slice st sp sr) [v] <;> simp [rowsEval]

theorem primEvalP_reshape (env : Env Nat) (sh : List Int) (v : Value) :
    primEvalP P K env (.reshape sh) [v] = primEval P.toMlxContract K env (.reshape sh) [v] := by
  simp only [primEvalP]
  cases primEval P.toMlxContract K env (.reshape sh) [v] <;> simp [rowsEval]

theorem primEval_slice0 (env : Env Nat) (n : Nat) (u : Value) :
    primEval P.toMlxContract K env (.slice [0] [(n : Int)] [1]) [u] = slice u [0] [n] := by
  simp [primEval, unitStrides, natShape]

theorem primEval_reshape2 (env : Env Nat) (M D : Nat) (u : Value) :
    primEval P.toMlxContract K env (.reshape [(M : Int), (D : Int)]) [u] = reshape u [M, D] := by
  have hc : [(M : Int), (D : Int)].count (-1) = 0 := by
    simp only [List.count_cons, List.count_nil, beq_iff_eq]
    split <;> split <;> omega
  simp [primEval, reshapeDims, hc, natShape]

/-- No step-input leaf: the FFI graph's resolved primitives (`resolvePrimP`) have none. -/
def noInput : RPrim Int Nat → Bool
  | .input _ => false
  | .replayed _ p => noInput p
  | _ => true

theorem primEval_env (w : List Char → List Char → Option Value) (v v' : Nat → Option Value) :
    ∀ (p : RPrim Int Nat) (xs : List Value), noInput p = true →
      primEval P.toMlxContract K ⟨w, v⟩ p xs = primEval P.toMlxContract K ⟨w, v'⟩ p xs := by
  intro p
  induction p with
  | input k => intro xs h; simp [noInput] at h
  | replayed c q ih =>
    intro xs h
    show (if elementwise q then none else primEval P.toMlxContract K ⟨w, v⟩ q xs) =
      (if elementwise q then none else primEval P.toMlxContract K ⟨w, v'⟩ q xs)
    rw [ih xs h]
  | _ => intro xs _; rcases xs with _ | ⟨_, _ | ⟨_, _ | ⟨_, _ | ⟨_, _ | ⟨_, _⟩⟩⟩⟩⟩ <;> rfl

theorem primEvalP_env (w : List Char → List Char → Option Value) (v v' : Nat → Option Value)
    (p : RPrim Int Nat) (xs : List Value) (h : noInput p = true) :
    primEvalP P K ⟨w, v⟩ p xs = primEvalP P K ⟨w, v'⟩ p xs := by
  simp only [primEvalP, primEval_env P K w v v' p xs h]

/-- `evalRP` at `i` reads the environment only through the primitives of nodes at or below `i`. -/
theorem evalRP_env (g : Nat → Option (RNode Int Nat)) (env env' : Env Nat) :
    ∀ i, (∀ j, j ≤ i → ∀ nd, g j = some nd → ∀ xs, primEvalP P K env nd.prim xs = primEvalP P K env' nd.prim xs) →
      evalRP P K env kind g i = evalRP P K env' kind g i := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  intro h
  have hargs : ∀ l : List Nat, (l.mapM fun j => if _h : j < i then evalRP P K env kind g j else none) =
      (l.mapM fun j => if _h : j < i then evalRP P K env' kind g j else none) := fun l =>
    mapM_congr' l _ _ fun j _ => by
      by_cases hj : j < i
      · simp only [hj, ↓reduceDIte]; exact ih j hj fun k hk => h k (by omega)
      · simp only [hj, ↓reduceDIte]
  rw [evalRP_eq, evalRP_eq]
  cases hg : g i with
  | none => rfl
  | some nd =>
    dsimp only
    cases cgLeaves g i with
    | some leaves => dsimp only; rw [hargs]
    | none =>
      dsimp only
      cases closureLeaves kind g i with
      | some x => dsimp only; rw [hargs]
      | none =>
        dsimp only
        rw [hargs]
        congr 1
        funext xs
        exact h i (Nat.le_refl i) nd hg xs

end

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C)
  (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled)
  (NE : NeuralEngine) (IP : InPlace) (G : Graph)

def Mem.env (m : Mem) : Env Nat := ⟨weights, m.vals⟩

/-- A node's value in the pure semantics, readers and writers at their fixed values. -/
noncomputable def pureVal (m : Mem) (j : Nat) : Option Value := evalRR P K (m.env weights) kind G.pure j

/-- An alias's value: the surface's current bytes through its views. -/
noncomputable def aliasVal (m : Mem) (j : Nat) : Option Value :=
  match G.aliasOf j with
  | some (.wrap sid) => (G.wrapType j).map fun (dt, sh) => surfaceValue (m.surf sid) dt sh
  | some (.view _) => match G.node j with
    | some ⟨p, [i]⟩ => if _h : i < j then (aliasVal m i).bind fun v => primEvalR P K (m.env weights) p [v] else none
    | _ => none
  | none => none
termination_by j

noncomputable def inVal (m : Mem) (j : Nat) : Option Value :=
  if (G.aliasOf j).isSome then aliasVal P K weights G m j else pureVal P K weights kind G m j

/-- The surfaces after a launch: each wrapped input's final contents. -/
def writeBack : List Nat → Nat → List ByteMemory.Bytes → (Nat → Surface) → Nat → Surface
  | [], _, _, surf => surf
  | j :: js, i, res, surf => writeBack js (i + 1) res (match G.aliasOf j, res[i]? with
    | some (.wrap sid), some B => upd surf sid (toSurface B)
    | _, _ => surf)

/-- A reader or writer runs. -/
noncomputable def runNode (m : Mem) (n : Nat) : Option Mem :=
  match G.touch n with
  | some (.read _) => match G.node n with
    | some nd => match nd.ins.mapM (inVal P K weights kind G m) with
      | some xs => (primEvalR P K (m.env weights) nd.prim xs).map fun v => { m with vals := upd m.vals n (some v) }
      | none => none
    | none => none
  | some (.write _) => match G.writer n with
    | some wr => match wr.ins.mapM (inVal P K weights kind G m) with
      | some xs => match IP.launchAll wr.kernel xs wr.cfg, wr.cfg.outputs with
        | some res, [o] => match res[xs.length]? with
          | some done => some { m with surf := writeBack G wr.ins 0 res m.surf, vals := upd m.vals n (some (outValue done o)) }
          | none => none
        | _, _ => none
      | none => none
    | none => none
  | none => none

noncomputable def runEffect (m : Mem) : Effect → Option Mem
  | .gpu ns => ns.foldlM (runNode P K weights kind IP G) m
  | .start q => match G.program q with
    | some pr => (NE.eval pr.prog (pr.ins.map m.surf)).map fun out => { m with pend := upd m.pend q (some out) }
    | none => none
  | .join q => match G.program q, m.pend q with
    | some pr, some out =>
      some { m with surf := upd m.surf pr.out (overlay out pr.prog.outputBytes (m.surf pr.out)), pend := upd m.pend q none }
    | _, _ => none

noncomputable def run (m : Mem) (es : List Effect) : Option Mem := es.foldlM (runEffect P K weights kind NE IP G) m

/-- The run's memory: its effects from the start, the surfaces holding `init` when allocated. -/
noncomputable def final (init : Nat → Surface) (b : FfiAne.St) : Option Mem :=
  run P K weights kind NE IP G ⟨init, fun _ => none, fun _ => none⟩ b.log.reverse

/-- A node's value: a reader's or writer's fixed value, an alias none (its bytes change), any other node pure. -/
noncomputable def valueOf (m : Mem) (j : Nat) : Option Value :=
  if (G.touch j).isSome then m.vals j else if (G.aliasOf j).isSome then none else pureVal P K weights kind G m j

/-! ## Steps -/

theorem runNode_read (m : Mem) (n : Nat) (sids : List Nat) (nd : RNode Int Nat) (xs : List Value) (v : Value)
    (ht : G.touch n = some (.read sids)) (hn : G.node n = some nd)
    (hx : nd.ins.mapM (inVal P K weights kind G m) = some xs)
    (hv : primEvalR P K (m.env weights) nd.prim xs = some v) :
    runNode P K weights kind IP G m n = some { m with vals := upd m.vals n (some v) } := by
  simp [runNode, ht, hn, hx, hv]

theorem runNode_write (m : Mem) (n : Nat) (sids : List Nat) (wr : Writer) (xs : List Value)
    (res : List ByteMemory.Bytes) (o : List Nat × Dtype) (done : ByteMemory.Bytes)
    (ht : G.touch n = some (.write sids)) (hw : G.writer n = some wr)
    (hx : wr.ins.mapM (inVal P K weights kind G m) = some xs) (hl : IP.launchAll wr.kernel xs wr.cfg = some res)
    (ho : wr.cfg.outputs = [o]) (hd : res[xs.length]? = some done) :
    runNode P K weights kind IP G m n =
      some { m with surf := writeBack G wr.ins 0 res m.surf, vals := upd m.vals n (some (outValue done o)) } := by
  simp [runNode, ht, hw, hx, hl, ho, hd]

theorem runEffect_start (m : Mem) (q : Nat) (pr : Program) (out : Surface) (hq : G.program q = some pr)
    (he : NE.eval pr.prog (pr.ins.map m.surf) = some out) :
    runEffect P K weights kind NE IP G m (.start q) = some { m with pend := upd m.pend q (some out) } := by
  simp [runEffect, hq, he]

theorem runEffect_join (m : Mem) (q : Nat) (pr : Program) (out : Surface) (hq : G.program q = some pr)
    (hp : m.pend q = some out) :
    runEffect P K weights kind NE IP G m (.join q) =
      some { m with surf := upd m.surf pr.out (overlay out pr.prog.outputBytes (m.surf pr.out)), pend := upd m.pend q none } := by
  simp [runEffect, hq, hp]

theorem writeBack_pure (js : List Nat) (i : Nat) (res : List ByteMemory.Bytes) (surf : Nat → Surface)
    (h : ∀ j ∈ js, G.aliasOf j = none) : writeBack G js i res surf = surf := by
  induction js generalizing i surf with
  | nil => rfl
  | cons j js ih =>
    have hj : G.aliasOf j = none := h j (List.mem_cons_self ..)
    simp only [writeBack, hj]
    exact ih _ _ fun x hx => h x (List.mem_cons_of_mem _ hx)

/-- A launch whose only aliased input is its last, a wrap: that surface holds its final contents. -/
theorem writeBack_last (pre : List Nat) (W sid : Nat) (res : List ByteMemory.Bytes) (surf : Nat → Surface)
    (B : ByteMemory.Bytes) (hpre : ∀ j ∈ pre, G.aliasOf j = none) (hW : G.aliasOf W = some (.wrap sid))
    (hB : res[pre.length]? = some B) : writeBack G (pre ++ [W]) 0 res surf = upd surf sid (toSurface B) := by
  suffices h : ∀ (pre : List Nat) (i : Nat) (surf : Nat → Surface), (∀ j ∈ pre, G.aliasOf j = none) →
      res[i + pre.length]? = some B → writeBack G (pre ++ [W]) i res surf = upd surf sid (toSurface B) by
    exact h pre 0 surf hpre (by simpa using hB)
  intro pre
  induction pre with
  | nil => intro i surf _ hi; simp [writeBack, hW, show res[i]? = some B by simpa using hi]
  | cons j js ih =>
    intro i surf hp hi
    have hj : G.aliasOf j = none := hp j (List.mem_cons_self ..)
    simp only [List.cons_append, writeBack, hj]
    exact ih (i + 1) surf (fun x hx => hp x (List.mem_cons_of_mem _ hx))
      (by rw [show i + 1 + js.length = i + (j :: js).length by simp; omega]; exact hi)

/-! ## Reading the output -/

/-- The first `M·D` halves of a surface as `[M, D]` (`AneProgram.output`: the output wrap, sliced and reshaped). -/
def readView (S : Surface) (len M D : Nat) : Option Value :=
  (slice (surfaceValue S .float16 [len]) [0] [M * D]).bind fun u => reshape u [M, D]

/-- The readback: the view cast to bf16 (`used.astype(hidden.dtype)`). -/
def readback (S : Surface) (len M D : Nat) : Option Value :=
  (readView S len M D).bind fun v => astypeV v .bfloat16

theorem surfaceValue_half (S : Surface) (shape : List Nat) (i : Nat) :
    (surfaceValue S .float16 shape).elems i = S (i * 2) + S (i * 2 + 1) * 256 := by
  simp [surfaceValue, Dtype.bytes, List.range_succ]

theorem readView_eq (S : Surface) (len M D : Nat) (h : M * D ≤ len) :
    readView S len M D = some ⟨.float16, [M, D], fun i => S (i * 2) + S (i * 2 + 1) * 256⟩ := by
  unfold readView
  have hs : slice (surfaceValue S .float16 [len]) [0] [M * D] =
      some ⟨.float16, [M * D], fun i => S (i * 2) + S (i * 2 + 1) * 256⟩ := by
    simp [slice, surfaceValue, h, flat, strides, unflat, Dtype.bytes, List.range_succ]
  rw [hs]
  simp [reshape, Value.size]

theorem readback_eq (S : Surface) (len M D : Nat) (h : M * D ≤ len) :
    readback S len M D = some ⟨.bfloat16, [M, D], fun i => bfWord (halfToBf (f16 (S (i * 2) + S (i * 2 + 1) * 256)))⟩ := by
  simp [readback, readView_eq S len M D h, astypeV]

/-- Rows below `M` of the readback are the evaluation's output halves: bytes below `2·M·D ≤ outputBytes`. -/
theorem readback_rows (out old : Surface) (ob len M D : Nat) (h : M * D ≤ len) (hob : 2 * (M * D) ≤ ob) :
    ∃ y, readback (overlay out ob old) len M D = some y ∧ y.dtype = .bfloat16 ∧ y.shape = [M, D] ∧
      ∀ i, i < M * D → y.elems i = bfWord (halfToBf (f16 (out (i * 2) + out (i * 2 + 1) * 256))) := by
  refine ⟨_, readback_eq _ len M D h, rfl, rfl, fun i hi => ?_⟩
  simp only [overlay, show i * 2 < ob by omega, show i * 2 + 1 < ob by omega, ite_true]

theorem primEvalR_astype (env : Env Nat) (d : Nat) (v : Value) :
    primEvalR P K env (.astype d) [v] = (Dtype.ofCode d).bind (astypeV v) := by
  rw [primEvalR_noPrefill P K env (p := .astype d) (fun _ _ _ h => nomatch h), primEvalP_astype]

theorem primEvalR_slice (env : Env Nat) (st sp sr : List Int) (v : Value) :
    primEvalR P K env (.slice st sp sr) [v] = primEval P.toMlxContract K.toKernelContract env (.slice st sp sr) [v] := by
  rw [primEvalR_noPrefill P K env (p := .slice st sp sr) (fun _ _ _ h => nomatch h), primEvalP_slice]

theorem primEvalR_reshape (env : Env Nat) (sh : List Int) (v : Value) :
    primEvalR P K env (.reshape sh) [v] = primEval P.toMlxContract K.toKernelContract env (.reshape sh) [v] := by
  rw [primEvalR_noPrefill P K env (p := .reshape sh) (fun _ _ _ h => nomatch h), primEvalP_reshape]

theorem aliasVal_wrap (m : Mem) (j sid : Nat) (dt : Dtype) (sh : List Nat) (ha : G.aliasOf j = some (.wrap sid))
    (ht : G.wrapType j = some (dt, sh)) : aliasVal P K weights G m j = some (surfaceValue (m.surf sid) dt sh) := by
  rw [aliasVal]; simp [ha, ht]

theorem aliasVal_view (m : Mem) (j i sid : Nat) (p : RPrim Int Nat) (ha : G.aliasOf j = some (.view sid))
    (hn : G.node j = some ⟨p, [i]⟩) (hi : i < j) :
    aliasVal P K weights G m j = (aliasVal P K weights G m i).bind fun v => primEvalR P K (m.env weights) p [v] := by
  rw [aliasVal]; simp [ha, hn, hi]

/-- The output's read chain as the FFI records it: the output wrap `wo`, a slice from 0 to `M·D`, a reshape to `[M, D]`. -/
theorem aliasVal_readView (m : Mem) (wo v1 v2 so len M D : Nat) (hwo : G.aliasOf wo = some (.wrap so))
    (hwt : G.wrapType wo = some (.float16, [len])) (h1 : G.aliasOf v1 = some (.view so))
    (hn1 : G.node v1 = some ⟨.slice [0] [((M * D : Nat) : Int)] [1], [wo]⟩) (h01 : wo < v1)
    (h2 : G.aliasOf v2 = some (.view so)) (hn2 : G.node v2 = some ⟨.reshape [(M : Int), (D : Int)], [v1]⟩) (h12 : v1 < v2) :
    aliasVal P K weights G m v2 = readView (m.surf so) len M D := by
  rw [aliasVal_view P K weights G m v2 v1 so _ h2 hn2 h12, aliasVal_view P K weights G m v1 wo so _ h1 hn1 h01,
    aliasVal_wrap P K weights G m wo so _ _ hwo hwt]
  simp only [Option.bind_some, primEvalR_slice, primEvalR_reshape, primEval_slice0, primEval_reshape2, readView]

/-! ## One MLP split call -/

/-- Writer `d` fills surface `sid` with `R` (its final contents): from every
memory that agrees with `m` on the values below `lo` and on that surface, it
runs, leaving `R` there, changing no other surface, no other value and no
pending output. -/
def FillAt (m : Mem) (lo d sid : Nat) (R : ByteMemory.Bytes) : Prop :=
  ∀ m' : Mem, (∀ j, j < lo → m'.vals j = m.vals j) → m'.surf sid = m.surf sid →
    ∃ m'', runNode P K weights kind IP G m' d = some m'' ∧ m''.surf = upd m'.surf sid (toSurface R) ∧
      (∀ j, j ≠ d → m''.vals j = m'.vals j) ∧ m''.pend = m'.pend

theorem mapM_some_length {α β : Type} (f : α → Option β) :
    ∀ (l : List α) (ys : List β), l.mapM f = some ys → ys.length = l.length
  | [], ys, h => by simp at h; simp [← h]
  | a :: l, ys, h => by
    simp only [List.mapM_cons, Option.bind_eq_bind, Option.pure_def] at h
    cases ha : f a with
    | none => rw [ha] at h; cases h
    | some y =>
      cases hl : l.mapM f with
      | none => rw [ha, hl] at h; cases h
      | some zs =>
        rw [ha, hl] at h
        simp only [Option.bind_some, Option.some.injEq] at h
        subst h
        simp [mapM_some_length f l zs hl]

/-- A fill as the FFI records it: a writer of surface `sid` whose inputs are
pure nodes `pre` with values `xs` (in every memory agreeing with `m` below
`lo`) then the surface's wrap; the launch on the surface's contents in `m`
leaves `R` in it. -/
theorem FillAt.of_launch (m : Mem) (lo d sid W : Nat) (k : InPlaceKernel) (cfg : Config) (pre : List Nat)
    (xs : List Value) (dt : Dtype) (sh : List Nat) (o : List Nat × Dtype) (res : List ByteMemory.Bytes)
    (R done : ByteMemory.Bytes)
    (ht : G.touch d = some (.write [sid])) (hw : G.writer d = some ⟨k, cfg, pre ++ [W]⟩)
    (hW : G.aliasOf W = some (.wrap sid)) (hWt : G.wrapType W = some (dt, sh)) (hpre : ∀ j ∈ pre, G.aliasOf j = none)
    (hxs : ∀ m' : Mem, (∀ j, j < lo → m'.vals j = m.vals j) → pre.mapM (pureVal P K weights kind G m') = some xs)
    (hl : IP.launchAll k (xs ++ [surfaceValue (m.surf sid) dt sh]) cfg = some res) (ho : cfg.outputs = [o])
    (hR : res[pre.length]? = some R) (hd : res[pre.length + 1]? = some done) :
    FillAt P K weights kind IP G m lo d sid R := by
  intro m' hv hs
  have hlen : xs.length = pre.length := mapM_some_length _ pre xs (hxs m' hv)
  have hin : (pre ++ [W]).mapM (inVal P K weights kind G m') = some (xs ++ [surfaceValue (m.surf sid) dt sh]) := by
    have hp : pre.mapM (inVal P K weights kind G m') = pre.mapM (pureVal P K weights kind G m') :=
      mapM_congr' pre _ _ fun j hj => by simp [inVal, hpre j hj]
    have hWv : inVal P K weights kind G m' W = some (surfaceValue (m.surf sid) dt sh) := by
      simp only [inVal, hW, Option.isSome_some, ite_true]
      rw [aliasVal_wrap P K weights G m' W sid dt sh hW hWt, hs]
    simp [List.mapM_append, hp, hxs m' hv, hWv]
  refine ⟨_, runNode_write P K weights kind IP G m' d [sid] ⟨k, cfg, pre ++ [W]⟩ _ res o done ht hw hin hl ho
    (by simpa [hlen] using hd), ?_, ?_, rfl⟩
  · exact writeBack_last G pre W sid res m'.surf R hpre hW hR
  · intro j hj; simp [upd, hj]

/-- A fill from the in-place contract (`WritesThrough` of the launch on the
surface's contents in `m`): `FillAt` with the written input's final bytes,
which are the kernel's stores and the surface's previous bytes elsewhere. -/
theorem FillAt.of_writes (m : Mem) (lo d sid W : Nat) (k : InPlaceKernel) (cfg : Config) (pre : List Nat)
    (xs : List Value) (dt : Dtype) (sh : List Nat) (o : List Nat × Dtype) (stored : Nat → Option (BitVec 8))
    (ht : G.touch d = some (.write [sid])) (hw : G.writer d = some ⟨k, cfg, pre ++ [W]⟩)
    (hW : G.aliasOf W = some (.wrap sid)) (hWt : G.wrapType W = some (dt, sh)) (hpre : ∀ j ∈ pre, G.aliasOf j = none)
    (hxs : ∀ m' : Mem, (∀ j, j < lo → m'.vals j = m.vals j) → pre.mapM (pureVal P K weights kind G m') = some xs)
    (ho : cfg.outputs = [o])
    (hc : WritesThrough IP k (xs ++ [surfaceValue (m.surf sid) dt sh]) cfg pre.length stored) :
    ∃ R, FillAt P K weights kind IP G m lo d sid R ∧
      ∀ b, b < (surfaceValue (m.surf sid) dt sh).size * dt.bytes →
        R b = (stored b).getD ((surfaceValue (m.surf sid) dt sh).storageByte b) := by
  obtain ⟨res, B, dst, hl, hlen, hB, hdst, hbytes⟩ := hc
  have hx : xs.length = pre.length := mapM_some_length _ pre xs (hxs m fun _ _ => rfl)
  have hd : dst = surfaceValue (m.surf sid) dt sh := by
    rw [← hx] at hdst; simpa using hdst.symm
  subst hd
  have hlt : pre.length + 1 < res.length := by simp [hlen, hx, ho]
  refine ⟨B, FillAt.of_launch P K weights kind IP G m lo d sid W k cfg pre xs dt sh o res B (res[pre.length + 1])
    ht hw hW hWt hpre hxs hl ho hB (List.getElem?_eq_getElem hlt), fun b hb => hbytes b hb⟩

/-- A log runs in pieces. -/
theorem run_append (m : Mem) (es fs : List Effect) :
    run P K weights kind NE IP G m (es ++ fs) = (run P K weights kind NE IP G m es).bind fun m' =>
      run P K weights kind NE IP G m' fs := by
  simp [run, List.foldlM_append]

/-- The reader of an MLP split's output: `astype` to bf16 of the view `v` of output surface `so`. -/
structure ReadAt (b v so len M D : Nat) : Prop where
  touch : G.touch b = some (.read [so])
  node : G.node b = some ⟨.astype Ffi.dtBf16, [v]⟩
  isAlias : (G.aliasOf v).isSome = true
  view : ∀ m : Mem, aliasVal P K weights G m v = readView (m.surf so) len M D

theorem ReadAt.run {b v so len M D : Nat} (h : ReadAt P K weights G b v so len M D) (hfit : M * D ≤ len) (m : Mem) :
    runNode P K weights kind IP G m b = some { m with vals := upd m.vals b (readback (m.surf so) len M D) } := by
  have hx : [v].mapM (inVal P K weights kind G m) =
      some [⟨.float16, [M, D], fun i => m.surf so (i * 2) + m.surf so (i * 2 + 1) * 256⟩] := by
    simp [inVal, h.isAlias, h.view m, readView_eq _ len M D hfit]
  rw [runNode_read P K weights kind IP G m b [so] _ _ _ h.touch h.node hx]
  · rw [readback_eq _ len M D hfit]
  · rw [primEvalR_astype]; simp [Ffi.dtBf16, Dtype.ofCode, astypeV]

theorem runEffect_gpu (m : Mem) (ns : List Nat) :
    runEffect P K weights kind NE IP G m (.gpu ns) = ns.foldlM (runNode P K weights kind IP G) m := rfl

/-- **One MLP split call** (ane-prefill-split.ts mlpSplit) as the bridge logs
it: the blocking `evalAll` of the four fills (wd, wg, wu, x: surfaces
`sd sg su sx` of program `q`, filled with `R0 … R3`), `evalAsync`, `wait`, and
the evaluation that runs the output's reader `b`. From any memory `m` (every
surface's contents, stale rows included), the program evaluates on the four
filled surfaces whole, and the readback is the bf16 cast of the first `M·D`
output halves of the output surface: the evaluation's output laid over the
surface's old bytes (`readback_rows`: rows below `M` are the output's when
`2·M·D ≤ outputBytes`). Values below `lo` (the fills' inputs) are untouched. -/
theorem mlpSplit_readback (m : Mem) (q : Nat) (pr : Program) (hq : G.program q = some pr)
    (sd sg su sx so : Nat) (hins : pr.ins = [sd, sg, su, sx]) (hout : pr.out = so)
    (hdist : [sd, sg, su, sx, so].Nodup)
    (lo d0 d1 d2 d3 : Nat) (R0 R1 R2 R3 : ByteMemory.Bytes)
    (h0 : lo ≤ d0) (h01 : d0 < d1) (h12 : d1 < d2) (h23 : d2 < d3)
    (f0 : FillAt P K weights kind IP G m lo d0 sd R0) (f1 : FillAt P K weights kind IP G m lo d1 sg R1)
    (f2 : FillAt P K weights kind IP G m lo d2 su R2) (f3 : FillAt P K weights kind IP G m lo d3 sx R3)
    (out : Surface) (hne : NE.eval pr.prog [toSurface R0, toSurface R1, toSurface R2, toSurface R3] = some out)
    (b v len M D : Nat) (h3b : d3 < b) (hb : ReadAt P K weights G b v so len M D) (hfit : M * D ≤ len) :
    ∃ m', run P K weights kind NE IP G m [.gpu [d0, d1, d2, d3], .start q, .join q, .gpu [b]] = some m' ∧
      m'.vals b = readback (overlay out pr.prog.outputBytes (m.surf so)) len M D ∧
      m'.surf so = overlay out pr.prog.outputBytes (m.surf so) ∧
      ∀ j, j < lo → m'.vals j = m.vals j := by
  have hdg : sd ≠ sg := by intro e; rw [e] at hdist; simp at hdist
  have hdu : sd ≠ su := by intro e; rw [e] at hdist; simp at hdist
  have hdx : sd ≠ sx := by intro e; rw [e] at hdist; simp at hdist
  have hdo : sd ≠ so := by intro e; rw [e] at hdist; simp at hdist
  have hgu : sg ≠ su := by intro e; rw [e] at hdist; simp at hdist
  have hgx : sg ≠ sx := by intro e; rw [e] at hdist; simp at hdist
  have hgo : sg ≠ so := by intro e; rw [e] at hdist; simp at hdist
  have hux : su ≠ sx := by intro e; rw [e] at hdist; simp at hdist
  have huo : su ≠ so := by intro e; rw [e] at hdist; simp at hdist
  have hxo : sx ≠ so := by intro e; rw [e] at hdist; simp at hdist
  -- the fills, each on a memory agreeing with `m` below `lo` and on its surface
  obtain ⟨m1, e1, s1, v1, p1⟩ := f0 m (fun _ _ => rfl) rfl
  have a1 : ∀ j, j < lo → m1.vals j = m.vals j := fun j hj => v1 j (by omega)
  obtain ⟨m2, e2, s2, v2, p2⟩ := f1 m1 a1 (by rw [s1]; simp [upd, Ne.symm hdg])
  have a2 : ∀ j, j < lo → m2.vals j = m.vals j := fun j hj => by rw [v2 j (by omega), a1 j hj]
  obtain ⟨m3, e3, s3, v3, p3⟩ := f2 m2 a2 (by rw [s2, s1]; simp [upd, Ne.symm hgu, Ne.symm hdu])
  have a3 : ∀ j, j < lo → m3.vals j = m.vals j := fun j hj => by rw [v3 j (by omega), a2 j hj]
  obtain ⟨m4, e4, s4, v4, p4⟩ := f3 m3 a3 (by rw [s3, s2, s1]; simp [upd, Ne.symm hux, Ne.symm hgx, Ne.symm hdx])
  have a4 : ∀ j, j < lo → m4.vals j = m.vals j := fun j hj => by rw [v4 j (by omega), a3 j hj]
  have hsurf : pr.ins.map m4.surf = [toSurface R0, toSurface R1, toSurface R2, toSurface R3] := by
    rw [hins, s4, s3, s2, s1]
    simp [upd, hdg, hdu, hdx, hgu, hgx, hux]
  have hso : m4.surf so = m.surf so := by
    rw [s4, s3, s2, s1]; simp [upd, Ne.symm hdo, Ne.symm hgo, Ne.symm huo, Ne.symm hxo]
  have e5 := runEffect_start P K weights kind NE IP G m4 q pr out hq (by rw [hsurf]; exact hne)
  have e6 := runEffect_join P K weights kind NE IP G { m4 with pend := upd m4.pend q (some out) } q pr out hq
    (by simp [upd])
  have e7 := hb.run P K weights kind IP G hfit
    { m4 with surf := upd m4.surf pr.out (overlay out pr.prog.outputBytes (m4.surf pr.out)),
              pend := upd (upd m4.pend q (some out)) q none }
  have h6 : upd m4.surf pr.out (overlay out pr.prog.outputBytes (m4.surf pr.out)) so =
      overlay out pr.prog.outputBytes (m.surf so) := by
    simp [upd, hout, hso]
  dsimp only at e6 e7
  refine ⟨⟨upd m4.surf pr.out (overlay out pr.prog.outputBytes (m4.surf pr.out)),
    upd m4.vals b (readback (upd m4.surf pr.out (overlay out pr.prog.outputBytes (m4.surf pr.out)) so) len M D),
    upd (upd m4.pend q (some out)) q none⟩, ?_, ?_, ?_, ?_⟩
  · simp only [run, List.foldlM_cons, List.foldlM_nil, runEffect_gpu, e1, e2, e3, e4, Option.bind_eq_bind,
      Option.bind_some]
    rw [show (pure m4 : Option Mem) = some m4 from rfl, Option.bind_some, e5, Option.bind_some, e6, Option.bind_some]
    simp only [e7, Option.bind_some]
    rfl
  · rw [h6]; simp [upd]
  · exact h6
  · intro j hj
    simp only [upd, show j ≠ b by omega, ite_false]
    exact a4 j hj

/-- The MLP split's sum (`ops.add(b, g2)`): a pure node over the reader's fixed
value and the GPU partial's value; it is the graph side's MLP output. -/
theorem mlpSplit_sum (m : Mem) (b g2 s : Nat) (bv gv : Value)
    (hs : G.node s = some ⟨.binary chars!"add", [b, g2]⟩) (hts : G.touch s = none)
    (htb : (G.touch b).isSome = true) (hbs : b < s) (hgs : g2 < s)
    (hbv : m.vals b = some bv) (hgv : pureVal P K weights kind G m g2 = some gv) :
    pureVal P K weights kind G m s = add bv gv := by
  have hps : G.pure s = some ⟨.binary chars!"add", [b, g2]⟩ := by simp [Graph.pure, hts, hs]
  have hpb : G.pure b = some ⟨.input b, []⟩ := by simp [Graph.pure, htb]
  have hb' : evalRR P K (m.env weights) kind G.pure b = some bv := by
    rw [evalRR_eq]
    simp only [hpb]
    rw [cgLeaves_none G.pure b _ hpb rfl]
    have hc : closureLeaves kind G.pure b = none := by simp [closureLeaves, hpb, closureAux]
    simp only [hc]
    simp [primEvalR, prefillEval, Option.orElse, primEvalP, primEval, Mem.env, hbv]
  unfold pureVal
  rw [evalRR_eq]
  simp only [hps]
  rw [cgLeaves_none G.pure s _ hps rfl]
  have hc : closureLeaves kind G.pure s = none := by simp [closureLeaves, hps, closureAux]
  simp only [hc]
  simp only [List.mapM_cons, List.mapM_nil, hbs, hgs, ↓reduceDIte, hb']
  rw [show evalRR P K (m.env weights) kind G.pure g2 = some gv from hgv]
  simp only [Option.bind_eq_bind, Option.bind_some, Option.pure_def]
  simp only [primEvalR, primEvalP, primEval]
  cases add bv gv <;> simp [rowsEval, prefillEval, Option.orElse]

/-- **The readback's rows** (`program.output([M, D])` cast to bf16): with
`2·M·D ≤ outputBytes` (M ≤ the program's rows), row-major element `i < M·D` is
the bf16 of output half `i` of the Neural Engine's evaluation on the four
filled surfaces. -/
theorem mlpSplit_rows (m : Mem) (q : Nat) (pr : Program) (hq : G.program q = some pr)
    (sd sg su sx so : Nat) (hins : pr.ins = [sd, sg, su, sx]) (hout : pr.out = so)
    (hdist : [sd, sg, su, sx, so].Nodup)
    (lo d0 d1 d2 d3 : Nat) (R0 R1 R2 R3 : ByteMemory.Bytes)
    (h0 : lo ≤ d0) (h01 : d0 < d1) (h12 : d1 < d2) (h23 : d2 < d3)
    (f0 : FillAt P K weights kind IP G m lo d0 sd R0) (f1 : FillAt P K weights kind IP G m lo d1 sg R1)
    (f2 : FillAt P K weights kind IP G m lo d2 su R2) (f3 : FillAt P K weights kind IP G m lo d3 sx R3)
    (out : Surface) (hne : NE.eval pr.prog [toSurface R0, toSurface R1, toSurface R2, toSurface R3] = some out)
    (b v len M D : Nat) (h3b : d3 < b) (hb : ReadAt P K weights G b v so len M D) (hfit : M * D ≤ len)
    (hob : 2 * (M * D) ≤ pr.prog.outputBytes) :
    ∃ m' y, run P K weights kind NE IP G m [.gpu [d0, d1, d2, d3], .start q, .join q, .gpu [b]] = some m' ∧
      m'.vals b = some y ∧ y.dtype = .bfloat16 ∧ y.shape = [M, D] ∧
      ∀ i, i < M * D → y.elems i = bfWord (halfToBf (f16 (out (i * 2) + out (i * 2 + 1) * 256))) := by
  obtain ⟨m', hr, hv, _, _⟩ := mlpSplit_readback P K weights kind NE IP G m q pr hq sd sg su sx so hins hout hdist
    lo d0 d1 d2 d3 R0 R1 R2 R3 h0 h01 h12 h23 f0 f1 f2 f3 out hne b v len M D h3b hb hfit
  obtain ⟨y, hy, hd, hs, he⟩ := readback_rows out (m.surf so) pr.prog.outputBytes len M D hfit hob
  exact ⟨m', y, hr, hv.trans hy, hd, hs, he⟩

/-! ## Pure values depend on the fixed values below them -/

theorem primEvalR_env (w : List Char → List Char → Option Value) (v v' : Nat → Option Value)
    (p : RPrim Int Nat) (xs : List Value) (h : noInput p = true) :
    primEvalR P K ⟨w, v⟩ p xs = primEvalR P K ⟨w, v'⟩ p xs := by
  simp only [primEvalR, primEvalP_env P K.toKernelContract w v v' p xs h]

/-- `evalRR` at `i` reads the environment only through the primitives of nodes at or below `i`. -/
theorem evalRR_env (g : Nat → Option (RNode Int Nat)) (env env' : Env Nat) :
    ∀ i, (∀ j, j ≤ i → ∀ nd, g j = some nd → ∀ xs, primEvalR P K env nd.prim xs = primEvalR P K env' nd.prim xs) →
      evalRR P K env kind g i = evalRR P K env' kind g i := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  intro h
  have hargs : ∀ l : List Nat, (l.mapM fun j => if _h : j < i then evalRR P K env kind g j else none) =
      (l.mapM fun j => if _h : j < i then evalRR P K env' kind g j else none) := fun l =>
    mapM_congr' l _ _ fun j _ => by
      by_cases hj : j < i
      · simp only [hj, ↓reduceDIte]; exact ih j hj fun k hk => h k (by omega)
      · simp only [hj, ↓reduceDIte]
  rw [evalRR_eq, evalRR_eq]
  cases hg : g i with
  | none => rfl
  | some nd =>
    dsimp only
    cases cgLeaves g i with
    | some leaves => dsimp only; rw [hargs]
    | none =>
      dsimp only
      cases closureLeaves kind g i with
      | some x => dsimp only; rw [hargs]
      | none =>
        dsimp only
        rw [hargs]
        congr 1
        funext xs
        exact h i (Nat.le_refl i) nd hg xs

/-- **A pure value depends only on the fixed values at or below it** (on a graph without step-input leaves). -/
theorem pureVal_congr (hG : ∀ j nd, G.node j = some nd → noInput nd.prim = true) (m m' : Mem) (i : Nat)
    (hv : ∀ j, j ≤ i → m.vals j = m'.vals j) :
    pureVal P K weights kind G m i = pureVal P K weights kind G m' i := by
  unfold pureVal
  apply evalRR_env
  intro j hj nd hnd xs
  unfold Graph.pure at hnd
  by_cases ht : (G.touch j).isSome = true
  · simp only [ht, ↓reduceIte] at hnd
    cases hnd
    cases xs <;> simp [primEvalR, prefillEval, Option.orElse, primEvalP, primEval, rowsEval, Mem.env, hv j hj]
  · simp only [ht] at hnd
    exact primEvalR_env P K weights m.vals m'.vals nd.prim xs (hG j nd hnd)

/-- A checkpoint tensor's pure value, in every memory. -/
theorem pureVal_load (m : Mem) (j : Nat) (f k : List Char) (v : Value) (hn : G.node j = some ⟨.load f k, []⟩)
    (ht : G.touch j = none) (hw : weights f k = some v) : pureVal P K weights kind G m j = some v := by
  have hp : G.pure j = some ⟨.load f k, []⟩ := by simp [Graph.pure, ht, hn]
  unfold pureVal
  rw [evalRR_eq]
  simp only [hp]
  rw [cgLeaves_none G.pure j _ hp rfl]
  have hc : closureLeaves kind G.pure j = none := by simp [closureLeaves, hp, closureAux]
  simp only [hc]
  simp [primEvalR, prefillEval, Option.orElse, primEvalP, primEval, Mem.env, hw]

/-- The resolved FFI graph has no step-input leaves. -/
theorem resolvePrim_noInput (N : Nums Int) (kn : Nat → Option (List Char)) (shape : List Ffi.Dim) (dtype : Nat) :
    ∀ (p : Ffi.Prim) (r : RPrim Int Nat), resolvePrim N kn shape dtype p = some r → noInput r = true := by
  intro p
  induction p with
  | replayed c p ih =>
    intro r h
    simp only [resolvePrim, Option.map_eq_some_iff] at h
    obtain ⟨q, hq, rfl⟩ := h
    exact ih q hq
  | _ =>
    intro r h
    simp only [resolvePrim, Option.map_eq_some_iff, Option.bind_eq_bind, Option.bind_eq_some_iff,
      Option.pure_def, Option.some.injEq] at h
    aesop

theorem resolvePrimP_noInput (N : Nums Int) (kn : Nat → Option (List Char)) (shape : List Ffi.Dim) (dtype : Nat) :
    ∀ (p : Ffi.Prim) (r : RPrim Int Nat), resolvePrimP N kn shape dtype p = some r → noInput r = true := by
  intro p
  induction p with
  | replayed c p ih =>
    intro r h
    simp only [resolvePrimP, Option.map_eq_some_iff] at h
    obtain ⟨q, hq, rfl⟩ := h
    exact ih q hq
  | arange a b c =>
    intro r h
    simp only [resolvePrimP, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def] at h
    aesop
  | _ => intro r h; exact resolvePrim_noInput N kn shape dtype _ r h

theorem ofState_noInput (N : Nums Int) (S : KernelSources) (IS : InPlaceSources) (s : Ffi.St) (b : FfiAne.St) :
    ∀ j nd, (Graph.ofState N S IS s b).node j = some nd → noInput nd.prim = true := by
  intro j nd h
  simp only [Graph.ofState, ffiGraphR, Option.bind_eq_some_iff] at h
  obtain ⟨n, _, hn⟩ := h
  simp only [resolveNodeP, Option.map_eq_some_iff] at hn
  obtain ⟨p, hp, rfl⟩ := hn
  exact resolvePrimP_noInput N _ n.shape n.dtype n.prim p hp

/-! ## The route contract's values agree with the decode evaluation

The semantics evaluates nodes at the route kernel contract `K` (`evalRR`, `primEvalR`: a prefill kernel's node is its
launch through `K.applyP` or `K.inPlace`). Every value the multi-row evaluation at `K`'s decode contract gives is
unchanged (`pureVal_of_decode`); on a decode-only state (no kernel object resolves to a prefill kernel) the graph is
the decode-resolved one and every node evaluates exactly as the decode evaluation (`pureVal_decodeOnly`,
`primEvalR_decodeOnly`). -/

theorem pureVal_of_decode (m : Mem) (j : Nat) (v : Value)
    (h : evalRP P K.toKernelContract (m.env weights) kind G.pure j = some v) : pureVal P K weights kind G m j = some v :=
  evalRP_evalRR P K (m.env weights) kind G.pure j v h

theorem ofState_node_decode (N : Nums Int) (S : KernelSources) (IS : InPlaceSources) (s : Ffi.St) (b : FfiAne.St)
    (j : Nat) (nd : RNode Int Nat) (h : ffiGraphP N S s j = some nd) : (Graph.ofState N S IS s b).node j = some nd :=
  ffiGraphP_route N S s j nd h

theorem ofState_node_decodeOnly (N : Nums Int) {S : KernelSources} (IS : InPlaceSources) {s : Ffi.St}
    (b : FfiAne.St) (hd : DecodeOnly S s) : (Graph.ofState N S IS s b).node = ffiGraphP N S s :=
  ffiGraphR_decodeOnly N hd

/-- On a decode-only state a reader's or alias view's primitive evaluates as at the decode contract. -/
theorem primEvalR_decodeOnly (N : Nums Int) {S : KernelSources} (IS : InPlaceSources) {s : Ffi.St} (b : FfiAne.St)
    (hd : DecodeOnly S s) (j : Nat) (nd : RNode Int Nat) (hn : (Graph.ofState N S IS s b).node j = some nd)
    (env : Env Nat) (xs : List Value) : primEvalR P K env nd.prim xs = primEvalP P K.toKernelContract env nd.prim xs :=
  primEvalR_noPrefill P K env (ffiGraphR_noPrefill N hd j nd hn)

/-- **Decode-only states evaluate as before**: every pure value is the multi-row evaluation's at the decode
contract. -/
theorem pureVal_decodeOnly (N : Nums Int) {S : KernelSources} (IS : InPlaceSources) {s : Ffi.St} (b : FfiAne.St)
    (hd : DecodeOnly S s) (m : Mem) (j : Nat) :
    pureVal P K weights kind (Graph.ofState N S IS s b) m j =
      evalRP P K.toKernelContract (m.env weights) kind (Graph.ofState N S IS s b).pure j := by
  unfold pureVal
  refine evalRR_eq_evalRP P K (m.env weights) kind _ (fun i nd hi => ?_) j
  unfold Graph.pure at hi
  split at hi
  · cases hi; intro _ _ _ h; cases h
  · exact ffiGraphR_noPrefill N hd i nd hi

end

end Host.Mlx.FfiAneEval
