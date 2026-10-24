import host.mlx.ane.DepClosed
namespace Host.Mlx.FfiAneEval
open Inference.Contracts.Mlx
open Host.Mlx.FfiEval
open Host.Mlx.FfiAne (Effect Program)

/-! # A Neural Engine forward's effects, in order

`mlpSplit_readback` is one split call on the Neural Engine semantics. A
forward makes one or more calls per layer, and its readers do not all run
right after their call's join: aneAffine's qkv and z readers run with the out
split's fills, the out (or o) reader with the MLP split's fills (each the
first evaluation that reaches them, ane-prefill-split.ts), and the MLP
reader at the layer's queued evaluation (graph-forward.ts
`QueuedGraphForwardScope.accept`). This module runs any such order:

* `Seg`: a split call (`Call`: program `q`, its fills in launch order) with
  the readers of earlier calls that run in the same evaluation as its fills
  (`pre`) and the readers that run in one evaluation after its join
  (`post`); `Seg.log` is the bridge's log of it: `.gpu (pre ++ fills)`,
  `.start q`, `.join q`, then `.gpu post` unless empty.
* Surfaces are threaded whole (`Fill.Step`, `Call.Step`): a fill's surface
  after its launch is the written input's final bytes as the launch leaves
  them from the surface's contents before (stale bytes included); the
  program evaluates on its input surfaces as the fills left them; the join
  lays the evaluation's output over the output surface's old bytes. Nothing
  is assumed about which bytes a program reads (no row locality).
* `V` is the value each reader fixes: a reader's value is the readback of
  its output surface when it runs (`Seg.Step`), and a fill's sources have
  their values in every memory whose earlier readers hold `V` (`SrcAt`; from
  a final memory by `srcAt_of`).
* `seg_run`, `segs_run`: from any memory holding the surfaces, the log runs,
  leaves the surfaces after the calls and every reader `V`'s value, and
  changes no other fixed value. `segsOk_append` composes segment lists (a
  forward from its layers). -/

/-! ## Calls and their segments -/

/-- A fill as the FFI records it: writer `d` of surface `sid` launches in-place kernel `k` at `cfg` on the pure
sources `pre` (values `xs`) and the surface's wrap `W` (dtype `dt`, shape `sh`); its one output is `o`. -/
structure Fill where
  d : Nat
  sid : Nat
  W : Nat
  k : InPlaceKernel
  cfg : Config
  pre : List Nat
  xs : List Value
  dt : Dtype
  sh : List Nat
  o : List Nat × Dtype

/-- A reader of an output surface: `b`, the bf16 `astype` of view `v` (the first `M·D` halves as `[M, D]`) of the
output surface `so`'s wrap of `len` halves. -/
structure Reader where
  b : Nat
  v : Nat
  so : Nat
  len : Nat
  M : Nat
  D : Nat

/-- A split call: program `q` (the bridge's program index) and its fills in launch order. -/
structure Call where
  q : Nat
  fills : List Fill

/-- A call with the readers that run with its fills (`pre`) and after its join (`post`). -/
structure Seg where
  call : Call
  pre : List Reader
  post : List Reader

/-- One MLX evaluation of the readers and writers `ns`; none when there are none (the bridge logs no empty one). -/
def gpuOf : List Nat → List Effect
  | [] => []
  | n :: ns => [.gpu (n :: ns)]

/-- The bridge's log of a segment (oldest first). -/
def Seg.log (s : Seg) : List Effect :=
  [.gpu (s.pre.map Reader.b ++ s.call.fills.map Fill.d), .start s.call.q, .join s.call.q] ++ gpuOf (s.post.map Reader.b)

def Seg.readers (s : Seg) : List Reader := s.pre ++ s.post

/-- The readers and writers a segment runs. -/
def Seg.nodes (s : Seg) : List Nat := s.pre.map Reader.b ++ s.call.fills.map Fill.d ++ s.post.map Reader.b

def segsLog (ss : List Seg) : List Effect := ss.flatMap Seg.log
def segsReaders (ss : List Seg) : List Reader := ss.flatMap Seg.readers
def segsNodes (ss : List Seg) : List Nat := ss.flatMap Seg.nodes

theorem segsLog_append (ss tt : List Seg) : segsLog (ss ++ tt) = segsLog ss ++ segsLog tt := by simp [segsLog]
theorem segsReaders_append (ss tt : List Seg) : segsReaders (ss ++ tt) = segsReaders ss ++ segsReaders tt := by
  simp [segsReaders]
theorem segsNodes_append (ss tt : List Seg) : segsNodes (ss ++ tt) = segsNodes ss ++ segsNodes tt := by
  simp [segsNodes]

/-! ## Surfaces -/

/-- Fill `f` on surfaces `σ` leaves `σ'`: its launch on the surface's contents completes (written input then
output) and the surface holds the written input's final bytes. -/
def Fill.Step (IP : InPlace) (f : Fill) (σ σ' : Nat → Surface) : Prop :=
  ∃ res R done, IP.launchAll f.k (f.xs ++ [surfaceValue (σ f.sid) f.dt f.sh]) f.cfg = some res ∧
    res[f.pre.length]? = some R ∧ res[f.pre.length + 1]? = some done ∧ σ' = upd σ f.sid (toSurface R)

/-- The written input's final bytes of a fill's launch on surface contents `S`. -/
def Fill.result (IP : InPlace) (f : Fill) (S : Surface) : Option ByteMemory.Bytes :=
  (IP.launchAll f.k (f.xs ++ [surfaceValue S f.dt f.sh]) f.cfg).bind (·[f.pre.length]?)

/-- The fills in order. -/
inductive Fills.Step (IP : InPlace) : List Fill → (Nat → Surface) → (Nat → Surface) → Prop
  | nil (σ : Nat → Surface) : Fills.Step IP [] σ σ
  | cons (f : Fill) (fs : List Fill) (σ σ1 σ2 : Nat → Surface) :
      f.Step IP σ σ1 → Fills.Step IP fs σ1 σ2 → Fills.Step IP (f :: fs) σ σ2

theorem Fill.Step.result {IP : InPlace} {f : Fill} {σ σ' : Nat → Surface} (h : f.Step IP σ σ') :
    ∃ R, f.result IP (σ f.sid) = some R ∧ σ' = upd σ f.sid (toSurface R) := by
  obtain ⟨res, R, _, hl, hR, _, rfl⟩ := h
  exact ⟨R, by simp [Fill.result, hl, hR], rfl⟩

theorem Fill.Step.frame {IP : InPlace} {f : Fill} {σ σ' : Nat → Surface} (h : f.Step IP σ σ') (X : Nat)
    (hX : X ≠ f.sid) : σ' X = σ X := by
  obtain ⟨_, _, _, _, _, _, rfl⟩ := h
  simp [upd, hX]

theorem Fills.Step.frame {IP : InPlace} {fs : List Fill} {σ σ' : Nat → Surface} (h : Fills.Step IP fs σ σ')
    (X : Nat) (hX : X ∉ fs.map Fill.sid) : σ' X = σ X := by
  induction h with
  | nil => rfl
  | cons f fs σ σ1 σ2 h1 _ ih =>
    simp only [List.map_cons, List.mem_cons, not_or] at hX
    rw [ih hX.2, h1.frame X hX.1]

/-- **Each fill's surface after distinct fills** is its launch's result on the surface as it was before them (its
stale bytes threaded through the launch). -/
theorem Fills.Step.at {IP : InPlace} {fs : List Fill} {σ σ' : Nat → Surface} (h : Fills.Step IP fs σ σ')
    (hd : (fs.map Fill.sid).Nodup) : ∀ f ∈ fs, ∃ R, f.result IP (σ f.sid) = some R ∧ σ' f.sid = toSurface R := by
  induction h with
  | nil => intro f hf; cases hf
  | cons f fs σ σ1 σ2 h1 h2 ih =>
    simp only [List.map_cons, List.nodup_cons] at hd
    intro g hg
    rcases List.mem_cons.1 hg with rfl | hg
    · obtain ⟨R, hR, rfl⟩ := h1.result
      refine ⟨R, hR, ?_⟩
      rw [h2.frame g.sid hd.1]
      simp [upd]
    · obtain ⟨R, hR, hs⟩ := ih hd.2 g hg
      have hne : g.sid ≠ f.sid := fun e => hd.1 (e ▸ List.mem_map_of_mem hg)
      exact ⟨R, by rw [← h1.frame g.sid hne]; exact hR, hs⟩

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C)
  (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled)
  (NE : NeuralEngine) (IP : InPlace) (G : Graph)

/-- Call `c` on surfaces `σ` leaves `σ'`: the fills, the evaluation of program `c.q` on its input surfaces as they
left them, the output laid over the output surface's old bytes. -/
def Call.Step (c : Call) (σ σ' : Nat → Surface) : Prop :=
  ∃ σ1 pr out, G.program c.q = some pr ∧ Fills.Step IP c.fills σ σ1 ∧ NE.eval pr.prog (pr.ins.map σ1) = some out ∧
    σ' = upd σ1 pr.out (overlay out pr.prog.outputBytes (σ1 pr.out))

/-- A call changes only its fills' and its program's output surfaces. -/
theorem Call.Step.frame {c : Call} {σ σ' : Nat → Surface} (h : c.Step NE IP G σ σ') (pr : Program)
    (hq : G.program c.q = some pr) (X : Nat) (h1 : X ∉ c.fills.map Fill.sid) (h2 : X ≠ pr.out) : σ' X = σ X := by
  obtain ⟨σ1, pr', out, hq', hf, _, rfl⟩ := h
  rw [hq] at hq'
  cases hq'
  simp only [upd, h2, ite_false]
  exact hf.frame X h1

/-- **The output surface after a call** (its program's input surfaces the fills' distinct surfaces in order): the
evaluation, on the fills' launch results over the surfaces before the call, laid over the output surface's old
bytes. -/
theorem Call.Step.out {c : Call} {σ σ' : Nat → Surface} (h : c.Step NE IP G σ σ') (pr : Program)
    (hq : G.program c.q = some pr) (hins : pr.ins = c.fills.map Fill.sid) (hd : (pr.out :: pr.ins).Nodup) :
    ∃ Rs out, List.Forall₂ (fun f R => f.result IP (σ f.sid) = some R) c.fills Rs ∧
      NE.eval pr.prog (Rs.map toSurface) = some out ∧ σ' pr.out = overlay out pr.prog.outputBytes (σ pr.out) := by
  obtain ⟨σ1, pr', out, hq', hf, hne, rfl⟩ := h
  rw [hq] at hq'
  cases hq'
  rw [hins] at hd
  simp only [List.nodup_cons] at hd
  have hat := hf.at hd.2
  have hR : ∀ fs : List Fill, (∀ f ∈ fs, ∃ R, f.result IP (σ f.sid) = some R ∧ σ1 f.sid = toSurface R) →
      ∃ Rs, List.Forall₂ (fun f R => f.result IP (σ f.sid) = some R) fs Rs ∧ fs.map (σ1 ∘ Fill.sid) = Rs.map toSurface := by
    intro fs
    induction fs with
    | nil => intro _; exact ⟨[], .nil, rfl⟩
    | cons f fs ih =>
      intro hfs
      obtain ⟨R, hR, hs⟩ := hfs f (List.mem_cons_self ..)
      obtain ⟨Rs, h1, h2⟩ := ih fun g hg => hfs g (List.mem_cons_of_mem _ hg)
      exact ⟨R :: Rs, .cons hR h1, by simp only [List.map_cons, Function.comp, hs, List.cons.injEq, true_and]; exact h2⟩
  obtain ⟨Rs, h1, h2⟩ := hR c.fills hat
  refine ⟨Rs, out, h1, ?_, ?_⟩
  · rw [← h2, ← List.map_map, ← hins]; exact hne
  · simp only [upd, ite_true]
    rw [hf.frame pr.out (hins ▸ hd.1)]

/-! ## Facts -/

/-- A fill's FFI facts: a writer of its surface on its pure sources and the surface's wrap, with one output. -/
structure Fill.At (f : Fill) : Prop where
  touch : G.touch f.d = some (.write [f.sid])
  writer : G.writer f.d = some ⟨f.k, f.cfg, f.pre ++ [f.W]⟩
  wrap : G.aliasOf f.W = some (.wrap f.sid)
  wrapType : G.wrapType f.W = some (f.dt, f.sh)
  pure : ∀ j ∈ f.pre, G.aliasOf j = none
  out : f.cfg.outputs = [f.o]

/-- A reader's FFI facts (`ReadAt`) with its view inside the wrap. -/
def Reader.At (r : Reader) : Prop := ReadAt P K weights G r.b r.v r.so r.len r.M r.D ∧ r.M * r.D ≤ r.len

/-- The pure nodes `pre` have the values `xs` in every memory whose readers in `D` hold `V`'s values. -/
def SrcAt (V : Nat → Option Value) (D pre : List Nat) (xs : List Value) : Prop :=
  ∀ m : Mem, (∀ r ∈ D, m.vals r = V r) → pre.mapM (pureVal P K weights kind G m) = some xs

/-- **Sources from a final memory**: the sources' pure values in a memory `mF` whose readers in `D` hold `V`, when
every reader or writer among the sources' ancestors is in `D`. -/
theorem srcAt_of (hG : ∀ j nd, G.node j = some nd → noInput nd.prim = true) (V : Nat → Option Value)
    (D : List Nat) (mF : Mem) (hF : ∀ r ∈ D, mF.vals r = V r) (pre : List Nat) (xs : List Value)
    (hx : pre.mapM (pureVal P K weights kind G mF) = some xs)
    (hanc : ∀ j ∈ pre, ∀ a, Anc kind G.pure j a → (G.touch a).isSome = true → a ∈ D) :
    SrcAt P K weights kind G V D pre xs := by
  intro m hm
  rw [← hx]
  refine mapM_congr' pre _ _ fun j hj => pureVal_congrAnc P K kind weights G hG m mF j fun a ha ht => ?_
  have hD := hanc j hj a ha ht
  rw [hm a hD, hF a hD]

/-- A segment's facts, its fills' sources needing the readers `D` (earlier, done) and its own `pre`. -/
structure Seg.At (V : Nat → Option Value) (D : List Nat) (s : Seg) : Prop where
  fills : ∀ f ∈ s.call.fills, Fill.At G f
  readers : ∀ r ∈ s.readers, Reader.At P K weights G r
  src : ∀ f ∈ s.call.fills, SrcAt P K weights kind G V (D ++ s.pre.map Reader.b) f.pre f.xs

/-- Segment `s` on surfaces `σ` leaves `σ'`, each reader fixing `V`'s value: the readback of its output surface
when it runs (before the call's fills for `pre`, after its join for `post`). -/
structure Seg.Step (V : Nat → Option Value) (s : Seg) (σ σ' : Nat → Surface) : Prop where
  call : s.call.Step NE IP G σ σ'
  pre : ∀ r ∈ s.pre, V r.b = readback (σ r.so) r.len r.M r.D
  post : ∀ r ∈ s.post, V r.b = readback (σ' r.so) r.len r.M r.D

/-! ## Runs -/

theorem run_gpuOf (m : Mem) (ns : List Nat) :
    run P K weights kind NE IP G m (gpuOf ns) = ns.foldlM (runNode P K weights kind IP G) m := by
  cases ns with
  | nil => rfl
  | cons n ns => simp [gpuOf, run, runEffect_gpu]

/-- Fixed values agreeing with `V` on `A` and set to `V`'s on `B`, the rest kept: they agree on `A ++ B`. -/
theorem agree_after (V : Nat → Option Value) (A B : List Nat) (m m' : Mem) (hA : ∀ r ∈ A, m.vals r = V r)
    (hB : ∀ r ∈ B, m'.vals r = V r) (hf : ∀ j, j ∉ B → m'.vals j = m.vals j) : ∀ r ∈ A ++ B, m'.vals r = V r := by
  intro r hr
  by_cases h : r ∈ B
  · exact hB r h
  · rw [hf r h]
    exact hA r ((List.mem_append.1 hr).resolve_right h)

theorem readers_run (V : Nat → Option Value) : ∀ (rs : List Reader) (m : Mem),
    (∀ r ∈ rs, Reader.At P K weights G r) → (∀ r ∈ rs, V r.b = readback (m.surf r.so) r.len r.M r.D) →
    ∃ m', (rs.map Reader.b).foldlM (runNode P K weights kind IP G) m = some m' ∧ m'.surf = m.surf ∧
      m'.pend = m.pend ∧ (∀ r ∈ rs.map Reader.b, m'.vals r = V r) ∧ ∀ j, j ∉ rs.map Reader.b → m'.vals j = m.vals j
  | [], m, _, _ => ⟨m, rfl, rfl, rfl, by simp, fun _ _ => rfl⟩
  | r :: rs, m, ha, hv => by
    obtain ⟨hr, hfit⟩ := ha r (List.mem_cons_self ..)
    have e1 := hr.run P K weights kind IP G hfit m
    obtain ⟨m', e', hs', hp', hv', hf'⟩ := readers_run V rs
      { m with vals := upd m.vals r.b (readback (m.surf r.so) r.len r.M r.D) }
      (fun x hx => ha x (List.mem_cons_of_mem _ hx)) (fun x hx => hv x (List.mem_cons_of_mem _ hx))
    refine ⟨m', ?_, hs', hp', ?_, ?_⟩
    · simp only [List.map_cons, List.foldlM_cons, e1, Option.bind_eq_bind, Option.bind_some]
      exact e'
    · refine agree_after V [r.b] (rs.map Reader.b) _ m' (fun x hx => ?_) hv' hf'
      simp only [List.mem_singleton] at hx
      subst hx
      simp [upd, hv r (List.mem_cons_self ..)]
    · intro j hj
      simp only [List.map_cons, List.mem_cons, not_or] at hj
      rw [hf' j hj.2]
      simp [upd, hj.1]

theorem fill_run (V : Nat → Option Value) (D : List Nat) (f : Fill) (σ σ' : Nat → Surface) (ha : Fill.At G f)
    (hs : SrcAt P K weights kind G V D f.pre f.xs) (hst : f.Step IP σ σ') (m : Mem) (hm : m.surf = σ)
    (hv : ∀ r ∈ D, m.vals r = V r) :
    ∃ m', runNode P K weights kind IP G m f.d = some m' ∧ m'.surf = σ' ∧ m'.pend = m.pend ∧
      ∀ j, j ≠ f.d → m'.vals j = m.vals j := by
  obtain ⟨res, R, done, hl, hR, hd, rfl⟩ := hst
  have hxs := hs m hv
  have hlen : f.xs.length = f.pre.length := mapM_some_length _ f.pre f.xs hxs
  have hin : (f.pre ++ [f.W]).mapM (inVal P K weights kind G m) =
      some (f.xs ++ [surfaceValue (m.surf f.sid) f.dt f.sh]) := by
    have hp : f.pre.mapM (inVal P K weights kind G m) = f.pre.mapM (pureVal P K weights kind G m) :=
      mapM_congr' f.pre _ _ fun j hj => by simp [inVal, ha.pure j hj]
    have hWv : inVal P K weights kind G m f.W = some (surfaceValue (m.surf f.sid) f.dt f.sh) := by
      simp only [inVal, ha.wrap, Option.isSome_some, ite_true]
      exact aliasVal_wrap P K weights G m f.W f.sid f.dt f.sh ha.wrap ha.wrapType
    simp [List.mapM_append, hp, hxs, hWv]
  rw [← hm] at hl
  refine ⟨_, runNode_write P K weights kind IP G m f.d [f.sid] ⟨f.k, f.cfg, f.pre ++ [f.W]⟩ _ res f.o done ha.touch
    ha.writer hin hl ha.out (by simpa [hlen] using hd), ?_, rfl, ?_⟩
  · dsimp only
    rw [writeBack_last G f.pre f.W f.sid res m.surf R ha.pure ha.wrap hR, hm]
  · intro j hj; simp [upd, hj]

theorem fills_run (V : Nat → Option Value) (D : List Nat) {fs : List Fill} {σ σ' : Nat → Surface}
    (hst : Fills.Step IP fs σ σ') (ha : ∀ f ∈ fs, Fill.At G f ∧ SrcAt P K weights kind G V D f.pre f.xs)
    (hdw : ∀ r ∈ D, ∀ f ∈ fs, r ≠ f.d) :
    ∀ m : Mem, m.surf = σ → (∀ r ∈ D, m.vals r = V r) →
      ∃ m', (fs.map Fill.d).foldlM (runNode P K weights kind IP G) m = some m' ∧ m'.surf = σ' ∧ m'.pend = m.pend ∧
        ∀ j, j ∉ fs.map Fill.d → m'.vals j = m.vals j := by
  induction hst with
  | nil σ => intro m hm _; exact ⟨m, rfl, hm, rfl, fun _ _ => rfl⟩
  | cons f fs σ σ1 σ2 h1 _ ih =>
    intro m hm hv
    obtain ⟨haf, hsf⟩ := ha f (List.mem_cons_self ..)
    obtain ⟨m1, e1, s1, p1, v1⟩ := fill_run P K weights kind IP G V D f σ σ1 haf hsf h1 m hm hv
    obtain ⟨m2, e2, s2, p2, v2⟩ := ih (fun g hg => ha g (List.mem_cons_of_mem _ hg))
      (fun r hr g hg => hdw r hr g (List.mem_cons_of_mem _ hg)) m1 s1
      (fun r hr => by rw [v1 r (hdw r hr f (List.mem_cons_self ..)), hv r hr])
    refine ⟨m2, ?_, s2, p2.trans p1, fun j hj => ?_⟩
    · simp only [List.map_cons, List.foldlM_cons, e1, Option.bind_eq_bind, Option.bind_some]
      exact e2
    · simp only [List.map_cons, List.mem_cons, not_or] at hj
      rw [v2 j hj.2, v1 j hj.1]

/-- A reader is not a writer. -/
theorem reader_ne_writer {r : Reader} {f : Fill} (hr : Reader.At P K weights G r) (hf : Fill.At G f) : r.b ≠ f.d := by
  intro e
  have h1 := hr.1.touch
  rw [e, hf.touch] at h1
  cases h1

/-- **One segment**: from a memory holding the surfaces `σ` and `V`'s values at the readers `D` already done, the
segment's log runs to a memory holding the surfaces after the call and `V`'s values at `D` and the segment's readers,
every other fixed value kept. -/
theorem seg_run (V : Nat → Option Value) (D : List Reader) (s : Seg) (σ σ' : Nat → Surface)
    (hD : ∀ r ∈ D, Reader.At P K weights G r) (hs : s.Step NE IP G V σ σ')
    (ha : s.At P K weights kind G V (D.map Reader.b)) (m : Mem) (hm : m.surf = σ)
    (hv : ∀ r ∈ D.map Reader.b, m.vals r = V r) :
    ∃ m', run P K weights kind NE IP G m s.log = some m' ∧ m'.surf = σ' ∧
      (∀ r ∈ (D ++ s.readers).map Reader.b, m'.vals r = V r) ∧ ∀ j, j ∉ s.nodes → m'.vals j = m.vals j := by
  obtain ⟨σ1, pr, out, hq, hfs, hne, hσ'⟩ := hs.call
  have hpre : ∀ r ∈ s.pre, Reader.At P K weights G r := fun r hr => ha.readers r (List.mem_append_left _ hr)
  have hpost : ∀ r ∈ s.post, Reader.At P K weights G r := fun r hr => ha.readers r (List.mem_append_right _ hr)
  -- the readers run with the fills, then the fills
  obtain ⟨m1, e1, s1, p1, v1, f1⟩ := readers_run P K weights kind IP G V s.pre m hpre
    (fun r hr => by rw [hm]; exact hs.pre r hr)
  have a1 := agree_after V (D.map Reader.b) (s.pre.map Reader.b) m m1 hv v1 f1
  have hdw : ∀ r ∈ D.map Reader.b ++ s.pre.map Reader.b, ∀ f ∈ s.call.fills, r ≠ f.d := by
    intro r hr f hf
    simp only [List.mem_append, List.mem_map] at hr
    rcases hr with ⟨x, hx, rfl⟩ | ⟨x, hx, rfl⟩
    · exact reader_ne_writer P K weights G (hD x hx) (ha.fills f hf)
    · exact reader_ne_writer P K weights G (hpre x hx) (ha.fills f hf)
  obtain ⟨m2, e2, s2, p2, f2⟩ := fills_run P K weights kind IP G V _ hfs
    (fun f hf => ⟨ha.fills f hf, ha.src f hf⟩) hdw m1 (s1.trans hm) a1
  have a2 : ∀ r ∈ D.map Reader.b ++ s.pre.map Reader.b, m2.vals r = V r := fun r hr => by
    rw [f2 r fun h => by
      obtain ⟨f, hf, rfl⟩ := List.mem_map.1 h
      exact hdw _ hr f hf rfl]
    exact a1 r hr
  -- the evaluation and its join
  have e5 := runEffect_start P K weights kind NE IP G m2 s.call.q pr out hq (by rw [s2]; exact hne)
  have e6 := runEffect_join P K weights kind NE IP G { m2 with pend := upd m2.pend s.call.q (some out) } s.call.q pr
    out hq (by simp [upd])
  dsimp only at e6
  let m4 : Mem :=
    { m2 with surf := upd m2.surf pr.out (overlay out pr.prog.outputBytes (m2.surf pr.out)),
              pend := upd (upd m2.pend s.call.q (some out)) s.call.q none }
  have s4 : m4.surf = σ' := by rw [hσ']; simp only [m4, s2]
  -- the readers after the join
  obtain ⟨m5, e7, s5, _, v5, f5⟩ := readers_run P K weights kind IP G V s.post m4 hpost
    (fun r hr => by rw [s4]; exact hs.post r hr)
  refine ⟨m5, ?_, s5.trans s4, ?_, ?_⟩
  · simp only [Seg.log, List.cons_append, List.nil_append]
    simp only [run, List.foldlM_cons, runEffect_gpu, List.foldlM_append, e1, Option.bind_eq_bind, Option.bind_some, e2]
    rw [e5, Option.bind_some, e6, Option.bind_some]
    have h := run_gpuOf P K weights kind NE IP G m4 (s.post.map Reader.b)
    simp only [run] at h
    exact h.trans e7
  · have := agree_after V _ (s.post.map Reader.b) m2 m5 a2 v5 (fun j hj => by rw [f5 j hj])
    intro r hr
    apply this
    simpa [Seg.readers, List.map_append, List.append_assoc] using hr
  · intro j hj
    simp only [Seg.nodes, List.mem_append, not_or] at hj
    rw [f5 j hj.2]
    show m2.vals j = m.vals j
    rw [f2 j hj.1.2, f1 j hj.1.1]

/-! ## Segment lists -/

/-- Segments `ss` on surfaces `σ` leave `σ'`, each with its facts, the readers before it (from `D` on) done. -/
def SegsOk (V : Nat → Option Value) : List Reader → (Nat → Surface) → List Seg → (Nat → Surface) → Prop
  | _, σ, [], σ' => σ' = σ
  | D, σ, s :: ss, σ'' => ∃ σ', s.Step NE IP G V σ σ' ∧ s.At P K weights kind G V (D.map Reader.b) ∧
      SegsOk V (D ++ s.readers) σ' ss σ''

theorem segsOk_append (V : Nat → Option Value) :
    ∀ (ss tt : List Seg) (D : List Reader) (σ σ'' : Nat → Surface),
      SegsOk P K weights kind NE IP G V D σ (ss ++ tt) σ'' ↔
        ∃ σ', SegsOk P K weights kind NE IP G V D σ ss σ' ∧
          SegsOk P K weights kind NE IP G V (D ++ segsReaders ss) σ' tt σ''
  | [], tt, D, σ, σ'' => by simp [SegsOk, segsReaders]
  | s :: ss, tt, D, σ, σ'' => by
    simp only [List.cons_append, SegsOk]
    constructor
    · rintro ⟨σ', h1, h2, h3⟩
      obtain ⟨σ2, h4, h5⟩ := (segsOk_append V ss tt (D ++ s.readers) σ' σ'').1 h3
      refine ⟨σ2, ⟨σ', h1, h2, h4⟩, ?_⟩
      simpa [segsReaders, List.append_assoc] using h5
    · rintro ⟨σ2, ⟨σ', h1, h2, h4⟩, h5⟩
      refine ⟨σ', h1, h2, (segsOk_append V ss tt (D ++ s.readers) σ' σ'').2 ⟨σ2, h4, ?_⟩⟩
      simpa [segsReaders, List.append_assoc] using h5

/-- The facts of the readers of segments that hold their facts. -/
theorem segsOk_readers (V : Nat → Option Value) :
    ∀ (ss : List Seg) (D : List Reader) (σ σ' : Nat → Surface), SegsOk P K weights kind NE IP G V D σ ss σ' →
      ∀ r ∈ segsReaders ss, Reader.At P K weights G r
  | [], _, _, _, _ => by simp [segsReaders]
  | s :: ss, D, σ, σ'', h => by
    obtain ⟨σ', _, h2, h3⟩ := h
    intro r hr
    simp only [segsReaders, List.flatMap_cons, List.mem_append] at hr
    rcases hr with hr | hr
    · exact h2.readers r hr
    · exact segsOk_readers V ss _ σ' σ'' h3 r hr

/-- **A forward's segments**: from a memory holding the surfaces `σ` and `V`'s values at the readers `D` already
done, the segments' log runs to a memory holding the surfaces after the last call and `V`'s values at `D` and every
segment's reader, every other fixed value kept. -/
theorem segs_run (V : Nat → Option Value) :
    ∀ (ss : List Seg) (D : List Reader) (σ σ' : Nat → Surface) (m : Mem), (∀ r ∈ D, Reader.At P K weights G r) →
      SegsOk P K weights kind NE IP G V D σ ss σ' → m.surf = σ → (∀ r ∈ D.map Reader.b, m.vals r = V r) →
      ∃ m', run P K weights kind NE IP G m (segsLog ss) = some m' ∧ m'.surf = σ' ∧
        (∀ r ∈ (D ++ segsReaders ss).map Reader.b, m'.vals r = V r) ∧ ∀ j, j ∉ segsNodes ss → m'.vals j = m.vals j
  | [], D, σ, σ', m, _, h, hm, hv => ⟨m, rfl, hm.trans h.symm, by simpa [segsReaders] using hv, fun _ _ => rfl⟩
  | s :: ss, D, σ, σ'', m, hD, h, hm, hv => by
    obtain ⟨σ', h1, h2, h3⟩ := h
    obtain ⟨m1, e1, s1, v1, f1⟩ := seg_run P K weights kind NE IP G V D s σ σ' hD h1 h2 m hm hv
    have hD' : ∀ r ∈ D ++ s.readers, Reader.At P K weights G r := by
      intro r hr
      rcases List.mem_append.1 hr with hr | hr
      · exact hD r hr
      · exact h2.readers r hr
    obtain ⟨m2, e2, s2, v2, f2⟩ := segs_run V ss (D ++ s.readers) σ' σ'' m1 hD' h3 s1 v1
    refine ⟨m2, ?_, s2, ?_, ?_⟩
    · simp only [segsLog, List.flatMap_cons, run_append, e1, Option.bind_some]
      exact e2
    · simpa [segsReaders, List.append_assoc] using v2
    · intro j hj
      simp only [segsNodes, List.flatMap_cons, List.mem_append, not_or] at hj
      rw [f2 j hj.2, f1 j hj.1]

end

end Host.Mlx.FfiAneEval
