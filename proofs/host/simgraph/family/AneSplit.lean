import host.simgraph.family.AneFamilies
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx Metal.Kernels
open Host.Mlx.FfiAneEval

/-! # The Neural Engine splits' effect segments

A split's effect segment in the Neural Engine semantics (`FfiAneEval`): its
writers fill the program's input surfaces from pure sources, the program
evaluates, the reader casts the output view. Composed with the families
(`aneTpl_graph_step`: the sources' values) and the route contract's in-place
fields (`RouteKernelContract.aneTrellisFill`, `aneTrellisFillK3i`,
`aneWriteHalf`):

* `fillAt_trellis`, `fillAt_trellisK3i`, `fillAt_writeHalf`: a writer of
  the FFI graph (`WriterAt`) on pure sources with known values (`PureAt`)
  fills its surface (`FillAt`) with the contract's stored bytes in range and
  the surface's old bytes elsewhere;
* `aneMlp_effect` (four fills: wd, wg, wu, x) and `aneAffine_effect` (two:
  w, x): the readback's rows are the bf16 of the program's output halves on
  the filled surfaces;
* `affineSplit_concat`: the affine split's concatenation is the readback's
  with the GPU rows' value (`mlpSplit_sum` is the MLP split's sum);
* `pureAt_of`: a source's pure value from the family's graph postcondition
  at a later memory agreeing below the split. -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C)
  (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled) (NE : NeuralEngine)
  (G : FfiAneEval.Graph)

/-- Writer `d` of the FFI graph fills surface `sid` with kernel `k` at `cfg`
from the pure nodes `pre` and the surface's wrap `W` (dtype `dt`, shape `sh`). -/
structure WriterAt (d sid W : Nat) (k : InPlaceKernel) (cfg : Config) (pre : List Nat) (dt : Dtype) (sh : List Nat) :
    Prop where
  touch : G.touch d = some (.write [sid])
  writer : G.writer d = some ⟨k, cfg, pre ++ [W]⟩
  wrap : G.aliasOf W = some (.wrap sid)
  wrapType : G.wrapType W = some (dt, sh)
  pure : ∀ j ∈ pre, G.aliasOf j = none

/-- The pure nodes `pre` have the values `xs` in every memory agreeing with `m` below `lo`. -/
def PureAt (m : Mem) (lo : Nat) (pre : List Nat) (xs : List Value) : Prop :=
  ∀ m' : Mem, (∀ j, j < lo → m'.vals j = m.vals j) → pre.mapM (pureVal P K weights kind G m') = some xs

/-- **Pure sources below the split**: nodes below `lo` whose pure values in a
memory `mF` agreeing with `m` below `lo` are `xs`. -/
theorem pureAt_of (hG : ∀ j nd, G.node j = some nd → noInput nd.prim = true) (m mF : Mem) (lo : Nat)
    (hF : ∀ j, j < lo → mF.vals j = m.vals j) :
    ∀ (pre : List Nat) (xs : List Value), List.Forall₂ (fun j x => j < lo ∧ pureVal P K weights kind G mF j = some x)
      pre xs → PureAt P K weights kind G m lo pre xs
  | [], [], .nil => fun _ _ => rfl
  | j :: pre, x :: xs, .cons ⟨hj, hx⟩ hr => by
    intro m' hm'
    have h1 : pureVal P K weights kind G m' j = some x := by
      rw [pureVal_congr P K weights kind G hG m' mF j fun i hi => by rw [hm' i (by omega), hF i (by omega)]]
      exact hx
    have h2 := pureAt_of hG m mF lo hF pre xs hr m' hm'
    simp only [List.mapM_cons, h1, h2, Option.bind_eq_bind, Option.bind_some, Option.pure_def]

/-! ## The fills from the in-place contract -/

/-- `mlx_bun_ane_trellis_fill` (row-major) of `rows` rows at width `bits`. -/
theorem fillAt_trellis (m : Mem) (lo d sid W : Nat) (pre : List Nat) (sh : List Nat) (rows bits : Nat) (cd sc : Value)
    (hw : WriterAt G d sid W .trellisFill (fillConfig rows bits) pre .float16 sh)
    (hx : PureAt P K weights kind G m lo pre [cd, sc]) (hl : pre.length = 2) (hr : FillRoute rows bits)
    (hcd : Typed cd .uint32 [17408, 160 * bits]) (hsc : Typed sc .float16 [17408])
    (hsize : rows * 5120 ≤ (surfaceValue (m.surf sid) .float16 sh).size) :
    ∃ R, FillAt P K weights kind K.inPlace G m lo d sid R ∧
      ∀ b, b < (surfaceValue (m.surf sid) .float16 sh).size * Dtype.float16.bytes →
        R b = (AneFill.fillStored C bits rows (AneFill.rowMajor bits) cd.storageByte sc.storageByte b).getD
          ((surfaceValue (m.surf sid) .float16 sh).storageByte b) := by
  have hc := (K.aneTrellisFill cd sc (surfaceValue (m.surf sid) .float16 sh) hr hcd hsc rfl hsize).1
  rw [← hl] at hc
  exact FillAt.of_writes P K weights kind K.inPlace G m lo d sid W .trellisFill (fillConfig rows bits) pre [cd, sc]
    .float16 sh ([1], .int32) _ hw.touch hw.writer hw.wrap hw.wrapType hw.pure hx rfl hc

/-- `mlx_bun_ane_trellis_fill_k3i` (the 3-bit block interleave) of `rows` rows. -/
theorem fillAt_trellisK3i (m : Mem) (lo d sid W : Nat) (pre : List Nat) (sh : List Nat) (rows : Nat) (cd sc : Value)
    (hw : WriterAt G d sid W .trellisFillK3i (fillConfig rows 3) pre .float16 sh)
    (hx : PureAt P K weights kind G m lo pre [cd, sc]) (hl : pre.length = 2) (hr : rows = 6144 ∨ rows = 6656)
    (hcd : Typed cd .uint32 [10, 17408, 48]) (hsc : Typed sc .float16 [17408])
    (hsize : rows * 5120 ≤ (surfaceValue (m.surf sid) .float16 sh).size) :
    ∃ R, FillAt P K weights kind K.inPlace G m lo d sid R ∧
      ∀ b, b < (surfaceValue (m.surf sid) .float16 sh).size * Dtype.float16.bytes →
        R b = (AneFill.fillStored C 3 rows AneFill.k3i cd.storageByte sc.storageByte b).getD
          ((surfaceValue (m.surf sid) .float16 sh).storageByte b) := by
  have hc := (K.aneTrellisFillK3i cd sc (surfaceValue (m.surf sid) .float16 sh) hr hcd hsc rfl hsize).1
  rw [← hl] at hc
  exact FillAt.of_writes P K weights kind K.inPlace G m lo d sid W .trellisFillK3i (fillConfig rows 3) pre [cd, sc]
    .float16 sh ([1], .int32) _ hw.touch hw.writer hw.wrap hw.wrapType hw.pure hx rfl hc

/-- `mlx_bun_ane_write_half` of the `N` elements of `src`. -/
theorem fillAt_writeHalf (m : Mem) (lo d sid W : Nat) (pre : List Nat) (sh : List Nat) (N : Nat) (src : Value)
    (hw : WriterAt G d sid W .writeHalf (writeConfig N) pre .float16 sh)
    (hx : PureAt P K weights kind G m lo pre [src]) (hl : pre.length = 1) (hr : WriteRoute N)
    (hsd : src.dtype = .bfloat16) (hss : src.size = N) (hsize : N ≤ (surfaceValue (m.surf sid) .float16 sh).size) :
    ∃ R, FillAt P K weights kind K.inPlace G m lo d sid R ∧
      ∀ b, b < (surfaceValue (m.surf sid) .float16 sh).size * Dtype.float16.bytes →
        R b = (AneWrite.writeStored C N src.storageByte b).getD ((surfaceValue (m.surf sid) .float16 sh).storageByte b) := by
  have hc := (K.aneWriteHalf src (surfaceValue (m.surf sid) .float16 sh) hr hsd hss rfl hsize).1
  rw [← hl] at hc
  exact FillAt.of_writes P K weights kind K.inPlace G m lo d sid W .writeHalf (writeConfig N) pre [src]
    .float16 sh ([1], .int32) _ hw.touch hw.writer hw.wrap hw.wrapType hw.pure hx rfl hc

/-! ## The splits -/

variable (IP : InPlace)

/-- **One affine split call** (`AneAffineSplit.forward`) as the bridge logs it:
the blocking `evalAll` of the two writes (w, x: surfaces `sw sx` of program
`q`), `evalAsync`, `wait`, and the evaluation running the output's reader
`b` (`mlpSplit_readback` with two inputs). -/
theorem affineSplit_readback (m : Mem) (q : Nat) (pr : FfiAne.Program) (hq : G.program q = some pr)
    (sw sx so : Nat) (hins : pr.ins = [sw, sx]) (hout : pr.out = so) (hdist : [sw, sx, so].Nodup)
    (lo d0 d1 : Nat) (R0 R1 : ByteMemory.Bytes) (h0 : lo ≤ d0) (h01 : d0 < d1)
    (f0 : FillAt P K weights kind IP G m lo d0 sw R0) (f1 : FillAt P K weights kind IP G m lo d1 sx R1)
    (out : Surface) (hne : NE.eval pr.prog [toSurface R0, toSurface R1] = some out)
    (b v len M D : Nat) (h1b : d1 < b) (hb : ReadAt P K weights G b v so len M D) (hfit : M * D ≤ len) :
    ∃ m', FfiAneEval.run P K weights kind NE IP G m [.gpu [d0, d1], .start q, .join q, .gpu [b]] = some m' ∧
      m'.vals b = readback (overlay out pr.prog.outputBytes (m.surf so)) len M D ∧
      m'.surf so = overlay out pr.prog.outputBytes (m.surf so) ∧
      ∀ j, j < lo → m'.vals j = m.vals j := by
  have hwx : sw ≠ sx := by intro e; rw [e] at hdist; simp at hdist
  have hwo : sw ≠ so := by intro e; rw [e] at hdist; simp at hdist
  have hxo : sx ≠ so := by intro e; rw [e] at hdist; simp at hdist
  obtain ⟨m1, e1, s1, v1, p1⟩ := f0 m (fun _ _ => rfl) rfl
  have a1 : ∀ j, j < lo → m1.vals j = m.vals j := fun j hj => v1 j (by omega)
  obtain ⟨m2, e2, s2, v2, p2⟩ := f1 m1 a1 (by rw [s1]; simp [upd, Ne.symm hwx])
  have a2 : ∀ j, j < lo → m2.vals j = m.vals j := fun j hj => by rw [v2 j (by omega), a1 j hj]
  have hsurf : pr.ins.map m2.surf = [toSurface R0, toSurface R1] := by
    rw [hins, s2, s1]
    simp [upd, hwx]
  have hso : m2.surf so = m.surf so := by
    rw [s2, s1]; simp [upd, Ne.symm hwo, Ne.symm hxo]
  have e5 := runEffect_start P K weights kind NE IP G m2 q pr out hq (by rw [hsurf]; exact hne)
  have e6 := runEffect_join P K weights kind NE IP G { m2 with pend := upd m2.pend q (some out) } q pr out hq
    (by simp [upd])
  have e7 := hb.run P K weights kind IP G hfit
    { m2 with surf := upd m2.surf pr.out (overlay out pr.prog.outputBytes (m2.surf pr.out)),
              pend := upd (upd m2.pend q (some out)) q none }
  have h6 : upd m2.surf pr.out (overlay out pr.prog.outputBytes (m2.surf pr.out)) so =
      overlay out pr.prog.outputBytes (m.surf so) := by
    simp [upd, hout, hso]
  dsimp only at e6 e7
  refine ⟨⟨upd m2.surf pr.out (overlay out pr.prog.outputBytes (m2.surf pr.out)),
    upd m2.vals b (readback (upd m2.surf pr.out (overlay out pr.prog.outputBytes (m2.surf pr.out)) so) len M D),
    upd (upd m2.pend q (some out)) q none⟩, ?_, ?_, ?_, ?_⟩
  · simp only [FfiAneEval.run, List.foldlM_cons, List.foldlM_nil, runEffect_gpu, e1, e2, Option.bind_eq_bind,
      Option.bind_some]
    rw [show (pure m2 : Option Mem) = some m2 from rfl, Option.bind_some, e5, Option.bind_some, e6, Option.bind_some]
    simp only [e7, Option.bind_some]
    rfl
  · rw [h6]; simp [upd]
  · exact h6
  · intro j hj
    simp only [upd, show j ≠ b by omega, ite_false]
    exact a2 j hj

/-- **The MLP split's effect segment**: fills of the four surfaces (from the
contract's fields, each leaving `R i` with its characterization `S i`), then
for any output of the program on them, the run leaves the reader the bf16 of
the output's first `M·D` halves (`2·M·D ≤ outputBytes`), values below the
split untouched. -/
theorem aneMlp_effect (m : Mem) (q : Nat) (pr : FfiAne.Program) (hq : G.program q = some pr)
    (sd sg su sx so : Nat) (hins : pr.ins = [sd, sg, su, sx]) (hout : pr.out = so)
    (hdist : [sd, sg, su, sx, so].Nodup) (lo d0 d1 d2 d3 : Nat) (h0 : lo ≤ d0) (h01 : d0 < d1) (h12 : d1 < d2)
    (h23 : d2 < d3) (S0 S1 S2 S3 : ByteMemory.Bytes → Prop)
    (F0 : ∃ R, FillAt P K weights kind IP G m lo d0 sd R ∧ S0 R) (F1 : ∃ R, FillAt P K weights kind IP G m lo d1 sg R ∧ S1 R)
    (F2 : ∃ R, FillAt P K weights kind IP G m lo d2 su R ∧ S2 R) (F3 : ∃ R, FillAt P K weights kind IP G m lo d3 sx R ∧ S3 R)
    (b v len M D : Nat) (h3b : d3 < b) (hb : ReadAt P K weights G b v so len M D) (hfit : M * D ≤ len)
    (hob : 2 * (M * D) ≤ pr.prog.outputBytes) :
    ∃ R0 R1 R2 R3, S0 R0 ∧ S1 R1 ∧ S2 R2 ∧ S3 R3 ∧
      ∀ out, NE.eval pr.prog [toSurface R0, toSurface R1, toSurface R2, toSurface R3] = some out →
        ∃ m' y, FfiAneEval.run P K weights kind NE IP G m [.gpu [d0, d1, d2, d3], .start q, .join q, .gpu [b]] = some m' ∧
          m'.vals b = some y ∧ y.dtype = .bfloat16 ∧ y.shape = [M, D] ∧
          (∀ i, i < M * D → y.elems i = bfWord (halfToBf (f16 (out (i * 2) + out (i * 2 + 1) * 256)))) ∧
          ∀ j, j < lo → m'.vals j = m.vals j := by
  obtain ⟨R0, f0, s0⟩ := F0
  obtain ⟨R1, f1, s1⟩ := F1
  obtain ⟨R2, f2, s2⟩ := F2
  obtain ⟨R3, f3, s3⟩ := F3
  refine ⟨R0, R1, R2, R3, s0, s1, s2, s3, fun out hne => ?_⟩
  obtain ⟨m', hr, hv, _, hlo⟩ := mlpSplit_readback P K weights kind NE IP G m q pr hq sd sg su sx so hins hout hdist
    lo d0 d1 d2 d3 R0 R1 R2 R3 h0 h01 h12 h23 f0 f1 f2 f3 out hne b v len M D h3b hb hfit
  obtain ⟨y, hy, hd, hs, he⟩ := readback_rows out (m.surf so) pr.prog.outputBytes len M D hfit hob
  exact ⟨m', y, hr, hv.trans hy, hd, hs, he, hlo⟩

/-- **The affine split's effect segment** (two writes: weights, input). -/
theorem aneAffine_effect (m : Mem) (q : Nat) (pr : FfiAne.Program) (hq : G.program q = some pr)
    (sw sx so : Nat) (hins : pr.ins = [sw, sx]) (hout : pr.out = so) (hdist : [sw, sx, so].Nodup)
    (lo d0 d1 : Nat) (h0 : lo ≤ d0) (h01 : d0 < d1) (S0 S1 : ByteMemory.Bytes → Prop)
    (F0 : ∃ R, FillAt P K weights kind IP G m lo d0 sw R ∧ S0 R) (F1 : ∃ R, FillAt P K weights kind IP G m lo d1 sx R ∧ S1 R)
    (b v len M D : Nat) (h1b : d1 < b) (hb : ReadAt P K weights G b v so len M D) (hfit : M * D ≤ len)
    (hob : 2 * (M * D) ≤ pr.prog.outputBytes) :
    ∃ R0 R1, S0 R0 ∧ S1 R1 ∧
      ∀ out, NE.eval pr.prog [toSurface R0, toSurface R1] = some out →
        ∃ m' y, FfiAneEval.run P K weights kind NE IP G m [.gpu [d0, d1], .start q, .join q, .gpu [b]] = some m' ∧
          m'.vals b = some y ∧ y.dtype = .bfloat16 ∧ y.shape = [M, D] ∧
          (∀ i, i < M * D → y.elems i = bfWord (halfToBf (f16 (out (i * 2) + out (i * 2 + 1) * 256)))) ∧
          ∀ j, j < lo → m'.vals j = m.vals j := by
  obtain ⟨R0, f0, s0⟩ := F0
  obtain ⟨R1, f1, s1⟩ := F1
  refine ⟨R0, R1, s0, s1, fun out hne => ?_⟩
  obtain ⟨m', hr, hv, _, hlo⟩ := affineSplit_readback P K weights kind NE G IP m q pr hq sw sx so hins hout hdist
    lo d0 d1 R0 R1 h0 h01 f0 f1 out hne b v len M D h1b hb hfit
  obtain ⟨y, hy, hd, hs, he⟩ := readback_rows out (m.surf so) pr.prog.outputBytes len M D hfit hob
  exact ⟨m', y, hr, hv.trans hy, hd, hs, he, hlo⟩

/-- The affine split's concatenation (`ops.concatAxis([b, g2], -1)`): a pure
node over the reader's fixed value and the GPU rows' value. -/
theorem affineSplit_concat (m : Mem) (b g2 s : Nat) (bv gv : Value)
    (hs : G.node s = some ⟨.concat 1, [b, g2]⟩) (hts : G.touch s = none)
    (htb : (G.touch b).isSome = true) (hbs : b < s) (hgs : g2 < s)
    (hbv : m.vals b = some bv) (hgv : pureVal P K weights kind G m g2 = some gv) :
    pureVal P K weights kind G m s = concatenate bv gv 1 := by
  have hps : G.pure s = some ⟨.concat 1, [b, g2]⟩ := by simp [FfiAneEval.Graph.pure, hts, hs]
  have hpb : G.pure b = some ⟨.input b, []⟩ := by simp [FfiAneEval.Graph.pure, htb]
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
  cases concatenate bv gv 1 <;> simp [rowsEval, prefillEval, Option.orElse]

end

end Host.Mlx.SimGraph
