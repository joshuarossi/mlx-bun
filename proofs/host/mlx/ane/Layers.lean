import host.mlx.ane.Forward
namespace Host.Mlx.FfiAneEval
open Inference.Contracts.Mlx Metal.Kernels
open Host.Mlx.FfiEval
open Host.Mlx.FfiAne (Effect Program)

/-! # The Neural Engine forwards' layers as the bridge logs them

The order of each kind's effects, read from the TypeScript
(models/qwen/qwen38-27b-trellis-m1max.ts `#aneSmall`, `#aneDense`,
`#aneAffine`, `#queued`; layers/ane-prefill-split.ts `mlpSplit`,
`AneAffineSplit.forward`; runtime/graph-forward.ts
`QueuedGraphForwardScope`) and the bridge model (FfiAne.lean `schedule`:
an evaluation runs the unscheduled readers and writers its roots reach, in
creation order):

* every split call fills its program's inputs with one blocking `evalAll`,
  then `evalAsync` (its `settle` of the deferred sum is an evaluation that
  reaches no unscheduled reader or writer), the GPU share's `asyncEvalAll`
  (reaches none), `wait`; the output's reader (`astype` of the output view)
  is created after the join;
* `mlpLayer` (aneSmall, aneDense; delta and attention layers alike): the MLP
  split's four fills (wd, wg, wu, x), its evaluation, and its reader at the
  layer's queued evaluation (`accept`: `asyncEvalAll([next, ...state])`);
* `affineDeltaLayer` (aneAffine's delta layer): the qkv and z splits (their
  readers stay unscheduled: z's input is the layer's normed input), the out
  split, whose input reaches both readers, so they run with its fills, then
  the MLP split with the out reader in its fills' evaluation;
* `affineAttnLayer` (aneAffine's attention layer): the q split, the o split
  with q's reader, the MLP split with o's reader.

Between the layers' segments the forward makes no other surface effect (the
cache stages and the GPU layers evaluate nothing; the per-layer `accept`
runs only the MLP reader). The fills (`trellisFill`, `k3iFill`, `halfFill`)
from the route contract's in-place fields leave the kernel's stores in range
and the surface's previous bytes elsewhere (`*_step`). `call_readback`: a
reader after its call's join holds the bf16 of the program's output halves on
the fills' launch results over the surfaces before the call. -/

/-! ## The fills -/

/-- fill.ts `trellisFillHalf` (`mlx_bun_ane_trellis_fill`) of `rows` stored rows at code width `bits` from the codes
and scales nodes `cdn`, `scn` (values `cd`, `sc`) into surface `sid` (wrap `W` of `len` halves). -/
def trellisFill (d sid W cdn scn : Nat) (cd sc : Value) (rows bits len : Nat) : Fill :=
  ⟨d, sid, W, .trellisFill, fillConfig rows bits, [cdn, scn], [cd, sc], .float16, [len], ([1], .int32)⟩

/-- fill.ts `trellisFillHalfK3Interleaved` (`mlx_bun_ane_trellis_fill_k3i`), the 3-bit interleaved down rows. -/
def k3iFill (d sid W cdn scn : Nat) (cd sc : Value) (rows len : Nat) : Fill :=
  ⟨d, sid, W, .trellisFillK3i, fillConfig rows 3, [cdn, scn], [cd, sc], .float16, [len], ([1], .int32)⟩

/-- fill.ts `writeHalf` (`mlx_bun_ane_write_half`) of the `N` elements of node `srcn` (value `src`). -/
def halfFill (d sid W srcn : Nat) (src : Value) (N len : Nat) : Fill :=
  ⟨d, sid, W, .writeHalf, writeConfig N, [srcn], [src], .float16, [len], ([1], .int32)⟩

/-- A launch that writes its last input through (`WritesThrough`): the fill's step, its surface holding the
kernel's stores in range and its previous bytes elsewhere. -/
theorem Fill.step_of_writes (IP : InPlace) (f : Fill) (σ : Nat → Surface) (stored : Nat → Option (BitVec 8))
    (hl : f.xs.length = f.pre.length) (ho : f.cfg.outputs = [f.o])
    (hc : WritesThrough IP f.k (f.xs ++ [surfaceValue (σ f.sid) f.dt f.sh]) f.cfg f.pre.length stored) :
    ∃ R, f.Step IP σ (upd σ f.sid (toSurface R)) ∧
      ∀ b, b < (surfaceValue (σ f.sid) f.dt f.sh).size * f.dt.bytes →
        R b = (stored b).getD ((surfaceValue (σ f.sid) f.dt f.sh).storageByte b) := by
  obtain ⟨res, B, dst, hla, hlen, hB, hdst, hbytes⟩ := hc
  have hd : dst = surfaceValue (σ f.sid) f.dt f.sh := by
    rw [← hl] at hdst; simpa using hdst.symm
  subst hd
  have hlt : f.pre.length + 1 < res.length := by simp [hlen, hl, ho]
  exact ⟨B, ⟨res, B, res[f.pre.length + 1], hla, hB, List.getElem?_eq_getElem hlt, rfl⟩, hbytes⟩

theorem surfaceValue_size (S : Surface) (dt : Dtype) (len : Nat) : (surfaceValue S dt [len]).size = len := by
  simp [surfaceValue, Value.size]

section
variable {C : M1Max.Contract} (K : RouteKernelContract C)

/-- The row-major trellis fill from the route contract (`aneTrellisFill`). -/
theorem trellisFill_step (d sid W cdn scn : Nat) (cd sc : Value) (rows bits len : Nat) (σ : Nat → Surface)
    (hr : FillRoute rows bits) (hcd : Typed cd .uint32 [17408, 160 * bits]) (hsc : Typed sc .float16 [17408])
    (hsize : rows * 5120 ≤ len) :
    ∃ R, (trellisFill d sid W cdn scn cd sc rows bits len).Step K.inPlace σ (upd σ sid (toSurface R)) ∧
      ∀ b, b < len * 2 → R b = (AneFill.fillStored C bits rows (AneFill.rowMajor bits) cd.storageByte
        sc.storageByte b).getD ((surfaceValue (σ sid) .float16 [len]).storageByte b) := by
  have hc := (K.aneTrellisFill cd sc (surfaceValue (σ sid) .float16 [len]) hr hcd hsc rfl
    (by rw [surfaceValue_size]; exact hsize)).1
  obtain ⟨R, hs, hb⟩ := Fill.step_of_writes K.inPlace (trellisFill d sid W cdn scn cd sc rows bits len) σ _ rfl rfl hc
  refine ⟨R, hs, fun b hb' => hb b ?_⟩
  simpa [trellisFill, surfaceValue_size, Dtype.bytes] using hb'

/-- The 3-bit interleaved fill from the route contract (`aneTrellisFillK3i`). -/
theorem k3iFill_step (d sid W cdn scn : Nat) (cd sc : Value) (rows len : Nat) (σ : Nat → Surface)
    (hr : rows = 6144 ∨ rows = 6656) (hcd : Typed cd .uint32 [10, 17408, 48]) (hsc : Typed sc .float16 [17408])
    (hsize : rows * 5120 ≤ len) :
    ∃ R, (k3iFill d sid W cdn scn cd sc rows len).Step K.inPlace σ (upd σ sid (toSurface R)) ∧
      ∀ b, b < len * 2 → R b = (AneFill.fillStored C 3 rows AneFill.k3i cd.storageByte sc.storageByte b).getD
        ((surfaceValue (σ sid) .float16 [len]).storageByte b) := by
  have hc := (K.aneTrellisFillK3i cd sc (surfaceValue (σ sid) .float16 [len]) hr hcd hsc rfl
    (by rw [surfaceValue_size]; exact hsize)).1
  obtain ⟨R, hs, hb⟩ := Fill.step_of_writes K.inPlace (k3iFill d sid W cdn scn cd sc rows len) σ _ rfl rfl hc
  refine ⟨R, hs, fun b hb' => hb b ?_⟩
  simpa [k3iFill, surfaceValue_size, Dtype.bytes] using hb'

/-- The half writer from the route contract (`aneWriteHalf`). -/
theorem halfFill_step (d sid W srcn : Nat) (src : Value) (N len : Nat) (σ : Nat → Surface) (hr : WriteRoute N)
    (hsd : src.dtype = .bfloat16) (hss : src.size = N) (hsize : N ≤ len) :
    ∃ R, (halfFill d sid W srcn src N len).Step K.inPlace σ (upd σ sid (toSurface R)) ∧
      ∀ b, b < len * 2 → R b = (AneWrite.writeStored C N src.storageByte b).getD
        ((surfaceValue (σ sid) .float16 [len]).storageByte b) := by
  have hc := (K.aneWriteHalf src (surfaceValue (σ sid) .float16 [len]) hr hsd hss rfl
    (by rw [surfaceValue_size]; exact hsize)).1
  obtain ⟨R, hs, hb⟩ := Fill.step_of_writes K.inPlace (halfFill d sid W srcn src N len) σ _ rfl rfl hc
  refine ⟨R, hs, fun b hb' => hb b ?_⟩
  simpa [halfFill, surfaceValue_size, Dtype.bytes] using hb'

end

/-! ## The calls and the layers -/

/-- ane-prefill-split.ts `mlpSplit`: the fills of its program's inputs in symbol order (the down rows `wd`, the gate
and up rows `wg`, `wu`, the input rows `x`), in that launch order. -/
def mlpCall (q : Nat) (wd wg wu x : Fill) : Call := ⟨q, [wd, wg, wu, x]⟩

/-- `AneAffineSplit.forward`: the head rows' weights (`w`), then the input rows (`x`). -/
def affineCall (q : Nat) (w x : Fill) : Call := ⟨q, [w, x]⟩

/-- An aneSmall or aneDense layer: the MLP split, its reader at the layer's queued evaluation. -/
def mlpLayer (mlp : Call) (rm : Reader) : List Seg := [⟨mlp, [], [rm]⟩]

/-- An aneAffine delta layer: qkv, z, out (with qkv's and z's readers), MLP (with out's reader; its own after). -/
def affineDeltaLayer (qkv z out mlp : Call) (rq rz ro rm : Reader) : List Seg :=
  [⟨qkv, [], []⟩, ⟨z, [], []⟩, ⟨out, [rq, rz], []⟩, ⟨mlp, [ro], [rm]⟩]

/-- An aneAffine attention layer: q, o (with q's reader), MLP (with o's reader; its own after). -/
def affineAttnLayer (q o mlp : Call) (rq ro rm : Reader) : List Seg :=
  [⟨q, [], []⟩, ⟨o, [rq], []⟩, ⟨mlp, [ro], [rm]⟩]

theorem mlpLayer_log (mlp : Call) (rm : Reader) :
    segsLog (mlpLayer mlp rm) = [.gpu (mlp.fills.map Fill.d), .start mlp.q, .join mlp.q, .gpu [rm.b]] := rfl

theorem affineDeltaLayer_log (qkv z out mlp : Call) (rq rz ro rm : Reader) :
    segsLog (affineDeltaLayer qkv z out mlp rq rz ro rm) =
      [.gpu (qkv.fills.map Fill.d), .start qkv.q, .join qkv.q,
       .gpu (z.fills.map Fill.d), .start z.q, .join z.q,
       .gpu (rq.b :: rz.b :: out.fills.map Fill.d), .start out.q, .join out.q,
       .gpu (ro.b :: mlp.fills.map Fill.d), .start mlp.q, .join mlp.q, .gpu [rm.b]] := rfl

theorem affineAttnLayer_log (q o mlp : Call) (rq ro rm : Reader) :
    segsLog (affineAttnLayer q o mlp rq ro rm) =
      [.gpu (q.fills.map Fill.d), .start q.q, .join q.q,
       .gpu (rq.b :: o.fills.map Fill.d), .start o.q, .join o.q,
       .gpu (ro.b :: mlp.fills.map Fill.d), .start mlp.q, .join mlp.q, .gpu [rm.b]] := rfl

/-- A Neural Engine forward's layer. -/
inductive AneLayer where
  /-- aneSmall, aneDense (delta and attention layers alike). -/
  | mlp (mlp : Call) (rm : Reader)
  /-- aneAffine's delta layer. -/
  | affDelta (qkv z out mlp : Call) (rq rz ro rm : Reader)
  /-- aneAffine's attention layer. -/
  | affAttn (q o mlp : Call) (rq ro rm : Reader)

def AneLayer.segs : AneLayer → List Seg
  | .mlp c rm => mlpLayer c rm
  | .affDelta qkv z out c rq rz ro rm => affineDeltaLayer qkv z out c rq rz ro rm
  | .affAttn q o c rq ro rm => affineAttnLayer q o c rq ro rm

/-- A forward's segments: its layers' in order. -/
def forwardSegs (ls : List AneLayer) : List Seg := ls.flatMap AneLayer.segs

theorem forwardLog (ls : List AneLayer) : segsLog (forwardSegs ls) = ls.flatMap fun l => segsLog l.segs := by
  simp [forwardSegs, segsLog, List.flatMap_assoc]

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C)
  (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled)
  (NE : NeuralEngine) (IP : InPlace) (G : Graph)

/-! ## A reader after its call -/

/-- **The readback after a call** (its program's input surfaces the fills' distinct surfaces in order, the reader
on its output surface): the bf16 of the evaluation's first `M·D` output halves, the evaluation run on the fills'
launch results over the surfaces as they were before the call (each launch on its surface's whole previous
contents: no row is assumed independent of the others or of the stale rows). -/
theorem call_readback (c : Call) (σ σ' : Nat → Surface) (h : c.Step NE IP G σ σ') (pr : Program)
    (hq : G.program c.q = some pr) (hins : pr.ins = c.fills.map Fill.sid) (hd : (pr.out :: pr.ins).Nodup)
    (r : Reader) (hso : r.so = pr.out) (hfit : r.M * r.D ≤ r.len) (hob : 2 * (r.M * r.D) ≤ pr.prog.outputBytes) :
    ∃ Rs out y, List.Forall₂ (fun f R => f.result IP (σ f.sid) = some R) c.fills Rs ∧
      NE.eval pr.prog (Rs.map toSurface) = some out ∧ readback (σ' r.so) r.len r.M r.D = some y ∧
      y.dtype = .bfloat16 ∧ y.shape = [r.M, r.D] ∧
      ∀ i, i < r.M * r.D → y.elems i = bfWord (halfToBf (f16 (out (i * 2) + out (i * 2 + 1) * 256))) := by
  obtain ⟨Rs, out, h1, h2, h3⟩ := h.out NE IP G pr hq hins hd
  obtain ⟨y, hy, hd', hs, he⟩ := readback_rows out (σ pr.out) pr.prog.outputBytes r.len r.M r.D hfit hob
  exact ⟨Rs, out, y, h1, h2, by rw [hso, h3]; exact hy, hd', hs, he⟩

/-! ## The layers' segments from their calls -/

/-- **An aneSmall or aneDense layer**: the MLP call from `σ` to `σ'`, its reader fixing the readback after the join,
the fills' sources needing the readers done before the layer. -/
theorem mlpLayer_ok (V : Nat → Option Value) (D : List Reader) (mlp : Call) (rm : Reader) (σ σ' : Nat → Surface)
    (hc : mlp.Step NE IP G σ σ') (hrm : V rm.b = readback (σ' rm.so) rm.len rm.M rm.D)
    (hf : ∀ f ∈ mlp.fills, Fill.At G f) (hr : Reader.At P K weights G rm)
    (hs : ∀ f ∈ mlp.fills, SrcAt P K weights kind G V (D.map Reader.b) f.pre f.xs) :
    SegsOk P K weights kind NE IP G V D σ (mlpLayer mlp rm) σ' :=
  ⟨σ', ⟨hc, by simp, by simp [hrm]⟩, ⟨hf, by simp [Seg.readers, hr], by simpa [Seg.readers] using hs⟩, rfl⟩

/-- **An aneAffine delta layer**: the calls from `σ0` through `σ4`, each reader fixing the readback after its
call's join (qkv's output surface untouched by the z call), the fills' sources needing the readers done before
them. -/
theorem affineDeltaLayer_ok (V : Nat → Option Value) (D : List Reader) (qkv z out mlp : Call) (rq rz ro rm : Reader)
    (σ0 σ1 σ2 σ3 σ4 : Nat → Surface)
    (hq : qkv.Step NE IP G σ0 σ1) (hz : z.Step NE IP G σ1 σ2) (ho : out.Step NE IP G σ2 σ3)
    (hm : mlp.Step NE IP G σ3 σ4)
    (hrq : V rq.b = readback (σ1 rq.so) rq.len rq.M rq.D) (hrz : V rz.b = readback (σ2 rz.so) rz.len rz.M rz.D)
    (hro : V ro.b = readback (σ3 ro.so) ro.len ro.M ro.D) (hrm : V rm.b = readback (σ4 rm.so) rm.len rm.M rm.D)
    (prz : Program) (hprz : G.program z.q = some prz) (hzf : rq.so ∉ z.fills.map Fill.sid) (hzo : rq.so ≠ prz.out)
    (hfq : ∀ f ∈ qkv.fills, Fill.At G f) (hfz : ∀ f ∈ z.fills, Fill.At G f) (hfo : ∀ f ∈ out.fills, Fill.At G f)
    (hfm : ∀ f ∈ mlp.fills, Fill.At G f)
    (hr : ∀ r ∈ [rq, rz, ro, rm], Reader.At P K weights G r)
    (hsq : ∀ f ∈ qkv.fills, SrcAt P K weights kind G V (D.map Reader.b) f.pre f.xs)
    (hsz : ∀ f ∈ z.fills, SrcAt P K weights kind G V (D.map Reader.b) f.pre f.xs)
    (hso : ∀ f ∈ out.fills, SrcAt P K weights kind G V (D.map Reader.b ++ [rq.b, rz.b]) f.pre f.xs)
    (hsm : ∀ f ∈ mlp.fills, SrcAt P K weights kind G V (D.map Reader.b ++ [rq.b, rz.b, ro.b]) f.pre f.xs) :
    SegsOk P K weights kind NE IP G V D σ0 (affineDeltaLayer qkv z out mlp rq rz ro rm) σ4 := by
  have hrq' : V rq.b = readback (σ2 rq.so) rq.len rq.M rq.D := by rw [hz.frame NE IP G prz hprz rq.so hzf hzo]; exact hrq
  refine ⟨σ1, ⟨hq, by simp, by simp⟩, ⟨hfq, by simp [Seg.readers], by simpa [Seg.readers] using hsq⟩,
    σ2, ⟨hz, by simp, by simp⟩, ⟨hfz, by simp [Seg.readers], by simpa [Seg.readers] using hsz⟩,
    σ3, ⟨ho, ?_, by simp⟩, ⟨hfo, ?_, by simpa [Seg.readers] using hso⟩,
    σ4, ⟨hm, by simpa using hro, by simpa using hrm⟩, ⟨hfm, ?_, by simpa [Seg.readers] using hsm⟩, rfl⟩
  · intro r hr'
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at hr'
    rcases hr' with rfl | rfl
    · exact hrq'
    · exact hrz
  · intro r hr'; exact hr r (by simp [Seg.readers] at hr' ⊢; tauto)
  · intro r hr'; exact hr r (by simp [Seg.readers] at hr' ⊢; tauto)

/-- **An aneAffine attention layer**: the calls from `σ0` through `σ3`, each reader fixing the readback after its
call's join, the fills' sources needing the readers done before them. -/
theorem affineAttnLayer_ok (V : Nat → Option Value) (D : List Reader) (q o mlp : Call) (rq ro rm : Reader)
    (σ0 σ1 σ2 σ3 : Nat → Surface)
    (hq : q.Step NE IP G σ0 σ1) (ho : o.Step NE IP G σ1 σ2) (hm : mlp.Step NE IP G σ2 σ3)
    (hrq : V rq.b = readback (σ1 rq.so) rq.len rq.M rq.D) (hro : V ro.b = readback (σ2 ro.so) ro.len ro.M ro.D)
    (hrm : V rm.b = readback (σ3 rm.so) rm.len rm.M rm.D)
    (hfq : ∀ f ∈ q.fills, Fill.At G f) (hfo : ∀ f ∈ o.fills, Fill.At G f) (hfm : ∀ f ∈ mlp.fills, Fill.At G f)
    (hr : ∀ r ∈ [rq, ro, rm], Reader.At P K weights G r)
    (hsq : ∀ f ∈ q.fills, SrcAt P K weights kind G V (D.map Reader.b) f.pre f.xs)
    (hso : ∀ f ∈ o.fills, SrcAt P K weights kind G V (D.map Reader.b ++ [rq.b]) f.pre f.xs)
    (hsm : ∀ f ∈ mlp.fills, SrcAt P K weights kind G V (D.map Reader.b ++ [rq.b, ro.b]) f.pre f.xs) :
    SegsOk P K weights kind NE IP G V D σ0 (affineAttnLayer q o mlp rq ro rm) σ3 := by
  refine ⟨σ1, ⟨hq, by simp, by simp⟩, ⟨hfq, by simp [Seg.readers], by simpa [Seg.readers] using hsq⟩,
    σ2, ⟨ho, by simpa using hrq, by simp⟩, ⟨hfo, ?_, by simpa [Seg.readers] using hso⟩,
    σ3, ⟨hm, by simpa using hro, by simpa using hrm⟩, ⟨hfm, ?_, by simpa [Seg.readers] using hsm⟩, rfl⟩
  · intro r hr'; exact hr r (by simp [Seg.readers] at hr' ⊢; tauto)
  · intro r hr'; exact hr r (by simp [Seg.readers] at hr' ⊢; tauto)

/-! ## A whole forward -/

/-- A forward's layers chained: each layer's segments from the surfaces the previous left, every earlier reader
done. -/
def LayersOk (V : Nat → Option Value) : List Reader → (Nat → Surface) → List AneLayer → (Nat → Surface) → Prop
  | _, σ, [], σ' => σ' = σ
  | D, σ, l :: ls, σ'' => ∃ σ', SegsOk P K weights kind NE IP G V D σ l.segs σ' ∧
      LayersOk V (D ++ segsReaders l.segs) σ' ls σ''

theorem layersOk_segs (V : Nat → Option Value) : ∀ (ls : List AneLayer) (D : List Reader) (σ σ' : Nat → Surface),
    LayersOk P K weights kind NE IP G V D σ ls σ' → SegsOk P K weights kind NE IP G V D σ (forwardSegs ls) σ'
  | [], _, σ, σ', h => by simp only [LayersOk] at h; simp [forwardSegs, SegsOk, h]
  | l :: ls, D, σ, σ'', h => by
    obtain ⟨σ', h1, h2⟩ := h
    simp only [forwardSegs, List.flatMap_cons]
    exact (segsOk_append P K weights kind NE IP G V l.segs _ D σ σ'').2
      ⟨σ', h1, layersOk_segs V ls _ σ' σ'' h2⟩

/-- **A Neural Engine forward's effects**: from a memory holding the surfaces `σ` and `V`'s values at the readers
`D` done before (earlier forwards'), the forward's log (its layers' segments in order) runs to a memory holding the
surfaces the last call left and `V`'s values at every reader, every other fixed value kept. -/
theorem forward_run (V : Nat → Option Value) (ls : List AneLayer) (D : List Reader) (σ σ' : Nat → Surface) (m : Mem)
    (hD : ∀ r ∈ D, Reader.At P K weights G r) (h : LayersOk P K weights kind NE IP G V D σ ls σ')
    (hm : m.surf = σ) (hv : ∀ r ∈ D.map Reader.b, m.vals r = V r) :
    ∃ m', run P K weights kind NE IP G m (ls.flatMap fun l => segsLog l.segs) = some m' ∧ m'.surf = σ' ∧
      (∀ r ∈ (D ++ segsReaders (forwardSegs ls)).map Reader.b, m'.vals r = V r) ∧
      ∀ j, j ∉ segsNodes (forwardSegs ls) → m'.vals j = m.vals j := by
  rw [← forwardLog]
  exact segs_run P K weights kind NE IP G V (forwardSegs ls) D σ σ' m hD (layersOk_segs P K weights kind NE IP G V ls D σ σ' h)
    hm hv

end

end Host.Mlx.FfiAneEval
