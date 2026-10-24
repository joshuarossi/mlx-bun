import host.load.Parameters
import host.load.boot.World
import host.mlx.PrefillKernels
import host.mlx.GlueStep
namespace Host.Load.Boot
open Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Mlx.GlueStep Host.Mlx.GlueLayers Host.Load.Extract

/-! # The loaded model's Neural Engine side, as the boot leaves it

The route builds one Neural Engine layer stack per bucket of rows (the prompt ranges of unit `"ane"`,
`from`–`to`, each operation's closure binding `ane<to>`): each layer's MLP split (`AneTrellisMlpSplit`,
`…K3i`: its program, rows, channels, the full gate/up/down Trellis projections it fills from and the
GPU's rest rows) and, from 768 rows, its affine splits (a delta layer's `inProjQkv`, `inProjZ`,
`outProj`; an attention layer's `qProj`, `oProj`: program, head and rest rows). `aneX` reads them from
the load state without running anything (`Extract`): arrays as `Tensor` (handle, graph node,
header), programs by their create call (`HObj.ane n`).

`aneCheck` is what the route's Neural Engine side needs of them, on the bridge and the loaded stages'
layouts: the buckets are the ranges `aneRangesT`, 64 layers each; per layer the stage kind, the MLP
split's rows and channels (the rest rows `restOf`), its projections' widths and arrays' types
(`trelOk`), the affine splits' widths, inputs and rows' types (`linOk`); each program held by the
bridge with as many inputs as it declares and surfaces holding the bucket's rows (`progOk`). The
soundness lemmas turn it into statements. -/

/-- A Trellis projection: codes, scales, code width (`geometry.k`). -/
structure ATrel where
  codes : Tensor
  scales : Tensor
  bits : Nat

/-- An affine projection's rows: words, scales, biases. -/
structure ALin where
  w : Tensor
  scales : Tensor
  biases : Tensor

/-- A layer's MLP split. -/
structure AMlp where
  create : Nat
  k3i : Bool
  rows : Nat
  channels : Nat
  gate : ATrel
  up : ATrel
  down : ATrel
  rgate : ATrel
  rup : ATrel
  rdown : ATrel

/-- An affine split (`AneAffineSplit`): its streamed program's create, `cin`, `cout`, `seq`; head and rest rows. -/
structure AAff where
  create : Nat
  cin : Nat
  cout : Nat
  seq : Nat
  head : ALin
  rest : ALin

/-- A layer: its MLP split and affine splits by site. -/
structure ALayer where
  mlp : AMlp
  aff : List (Nat × AAff)

/-- A bucket: the range `lo`–`rows`, its layers. -/
structure ABucket where
  lo : Nat
  rows : Nat
  layers : List ALayer

/-! ## Reading the state -/

/-- Every fourth layer is an attention layer. -/
def aneAttn (p : Nat) : Bool := Nat.beq (p % 4) 3

/-- A layer's affine split sites (delta: qkv, z, out; attention: q, o). -/
def aneSites (p : Nat) : List Nat := bif aneAttn p then [0, 3] else [0, 1, 4]

/-- An affine split's Neural Engine rows (`aneChannels(N, .375)`). -/
def aneWidth (p j : Nat) : Nat :=
  bif aneAttn p then (bif Nat.beq j 0 then 4608 else 1920)
  else (bif Nat.beq j 0 then 3840 else bif Nat.beq j 1 then 2304 else 1920)

/-- The mixer field of an affine split site. -/
def affName (p j : Nat) : List Char :=
  bif aneAttn p then (bif Nat.beq j 0 then chars!"qProj" else chars!"oProj")
  else (bif Nat.beq j 0 then chars!"inProjQkv" else bif Nat.beq j 1 then chars!"inProjZ" else chars!"outProj")

/-- The MLP split's GPU rows at a bucket (`AnePremise.aneRestOf`). -/
def restOf (n : Nat) : Nat := if n ≤ 768 then 11264 else 10752

/-- The create call of an `AneProgram` (its private `handle`, the load world's `HObj.ane n`). -/
def progCreate (s : St LSt) (pg : Val) : Option Nat := do
  match ← privateField s pg chars!"handle" with
  | .ptr (.ext r) 0 => match objArgH s.ffi.host (.extPtr r 0) with
    | some (.ane n) => some n
    | _ => none
  | _ => none

def aTrel (s : St LSt) (v : Val) : Option ATrel := do
  let g ← own s v chars!"geometry"
  pure ⟨← fieldTensor s v chars!"codes", ← fieldTensor s v chars!"scales", ← (own s g chars!"k").bind nat⟩

def aLin (s : St LSt) (v : Val) (w sc b : List Char) : Option ALin := do
  pure ⟨← fieldTensor s v w, ← fieldTensor s v sc, ← fieldTensor s v b⟩

def aMlp (s : St LSt) (sp : Val) : Option AMlp := do
  let r ← own s sp chars!"rest"
  pure ⟨← (own s sp chars!"program").bind (progCreate s), nameEq (← className s sp) chars!"AneTrellisMlpSplitK3i",
    ← (own s sp chars!"rows").bind nat, ← (own s sp chars!"channels").bind nat,
    ← (own s sp chars!"gate").bind (aTrel s), ← (own s sp chars!"up").bind (aTrel s),
    ← (own s sp chars!"down").bind (aTrel s), ← (own s r chars!"gate").bind (aTrel s),
    ← (own s r chars!"up").bind (aTrel s), ← (own s r chars!"down").bind (aTrel s)⟩

def aAff (s : St LSt) (v : Val) : Option AAff := do
  let m ← own s v chars!"program"
  pure ⟨← (own s m chars!"program").bind (progCreate s), ← (own s m chars!"cin").bind nat,
    ← (own s m chars!"cout").bind nat, ← (own s m chars!"seq").bind nat,
    ← (own s v chars!"head").bind fun h => aLin s h chars!"w" chars!"scales" chars!"biases",
    ← (own s v chars!"rest").bind fun h => aLin s h chars!"_w" chars!"_scales" chars!"_biases"⟩

def aLayer (s : St LSt) (aff : Bool) (p : Nat) (l : Val) : Option ALayer := do
  let m ← (own s l chars!"mlp").bind fun m => (own s m chars!"split").bind (aMlp s)
  let mx ← own s l chars!"mixer"
  let a ← bif aff then (aneSites p).mapM fun j => ((own s mx (affName p j)).bind (aAff s)).map (j, ·) else pure []
  pure ⟨m, a⟩

def aBucket (s : St LSt) (r : Val) : Option ABucket := do
  let lo ← (own s r chars!"from").bind nat
  let hi ← (own s r chars!"to").bind nat
  let op ← own s r chars!"operation"
  let ls ← (closureBinding s op (chars!"ane" ++ Nat.toDigits 10 hi)).bind (elements s)
  pure ⟨lo, hi, ← (List.range ls.length).mapM fun p => ls[p]?.bind (aLayer s (Nat.ble 768 hi) p)⟩

def isAne (s : St LSt) (r : Val) : Bool :=
  match own s r chars!"unit" with
  | some (.str u) => nameEq u chars!"ane"
  | _ => false

/-- **The buckets** of the model object's prompt ranges of unit `"ane"`. -/
def aneX (s : St LSt) (model : Val) : Option (List ABucket) := do
  let pr ← (own s model chars!"prompt").bind (elements s)
  (pr.filter (isAne s)).mapM (aBucket s)

/-! ## The check -/

/-- An array's header type: what `headerValues` gives it at any contents. -/
def hdr (t : Tensor) : Dtype × List Nat := ((headerValues (fun _ _ => 0) t).dtype, (headerValues (fun _ _ => 0) t).shape)

def tyIs (t : Tensor) (d : Dtype) (sh : List Nat) : Bool := decide (hdr t = (d, sh))

def bitsOk (b : Nat) : Bool := Nat.beq b 2 || Nat.beq b 3 || Nat.beq b 4

def trelOk (t : ATrel) (R bits il : Nat) : Bool :=
  Nat.beq t.bits bits && tyIs t.codes .uint32 (expandCodes R bits il) && tyIs t.scales .float16 [R]

def linOk (x : ALin) (r : Nat) (lay : LinLayout) : Bool :=
  tyIs x.w .uint32 [r, lay.cols * lay.bits / 32] && tyIs x.scales .bfloat16 [r, lay.cols / 64] &&
    tyIs x.biases .bfloat16 [r, lay.cols / 64]

/-- A surface's fp16 elements (the wrap the route makes of it). -/
def half (B : FfiAne.St) (sid : Nat) : Nat := B.surfaceSize sid / 2

/-- The bridge holds create `n`'s program with `need.length` inputs, input `i`'s surface holding `need[i]`
halves and the output's `out`. -/
def progOk (B : FfiAne.St) (n : Nat) (need : List Nat) (out : Nat) : Bool :=
  match FfiAne.program? B n with
  | some (_, pr) => Nat.beq pr.ins.length need.length && Nat.beq pr.prog.inputBytes.length need.length &&
      ((List.range need.length).all fun i => Nat.ble (need.getD i 0) (half B (pr.ins.getD i 0))) &&
      Nat.ble out (half B pr.out)
  | none => false

/-- A loaded stage's kind, projection layouts and MLP widths. -/
structure LayS where
  attn : Bool
  lins : List LinLayout
  mlp : MlpLayout

def laySum : StageWeights → LayS
  | .delta w => ⟨false, [linLayout w.qkvKind w.qkv, linLayout w.zKind w.z, linLayout .plain w.a, linLayout .plain w.b,
      linLayout w.outKind w.out], mlpLayout w.mlp⟩
  | .attention w => ⟨true, [linLayout w.qKind w.q, linLayout w.kKind w.k, linLayout w.vKind w.v, linLayout w.oKind w.o],
      mlpLayout w.mlp⟩

def mlpOk (B : FfiAne.St) (rows : Nat) (L : LayS) (m : AMlp) : Bool :=
  let rest := restOf rows
  let gb := L.mlp.gateBits
  let ub := L.mlp.upBits
  let db := L.mlp.downBits
  Nat.beq m.rows rows && Nat.beq (m.channels + rest) 17408 && (Nat.beq m.channels 6144 || Nat.beq m.channels 6656) &&
  bitsOk gb && bitsOk ub && bitsOk db && trelOk m.gate 17408 gb 0 && trelOk m.up 17408 ub 0 &&
  (bif m.k3i then Nat.beq db 3 && trelOk m.down 17408 3 2 else trelOk m.down 17408 db 0) &&
  trelOk m.rgate rest gb 0 && trelOk m.rup rest ub 0 && trelOk m.rdown rest db (if db = 3 then 2 else 0) &&
  progOk B m.create [m.channels * 5120, m.channels * 5120, m.channels * 5120, 5120 * rows] (rows * 5120)

def noLin : LinLayout := ⟨.plain, 0, 0, 0⟩

def affOk (B : FfiAne.St) (rows : Nat) (L : LayS) (p : Nat) (ja : Nat × AAff) : Bool :=
  let lay := L.lins.getD ja.1 noLin
  let nA := aneWidth p ja.1
  Nat.beq ja.2.cout nA && Nat.beq ja.2.cin lay.cols && Nat.beq ja.2.seq rows &&
  linOk ja.2.head nA lay && linOk ja.2.rest (lay.rows - nA) lay &&
  progOk B ja.2.create [nA * lay.cols, lay.cols * rows] (rows * nA)

def layerOk (B : FfiAne.St) (rows : Nat) (L : LayS) (p : Nat) (l : ALayer) : Bool :=
  (L.attn == aneAttn p) && mlpOk B rows L l.mlp &&
  bif Nat.ble 768 rows then (l.aff.map Prod.fst == aneSites p) && l.aff.all (affOk B rows L p) else true

/-- The ranges of unit `"ane"` (`qwen38-27b-trellis-m1max.ts` `aneRanges`). -/
def aneRangesT : List (Nat × Nat) :=
  [(224, 256), (257, 320), (321, 384), (385, 448), (449, 512), (513, 576), (577, 640), (641, 704), (705, 768),
    (769, 896), (897, 1024), (1025, 1280), (1281, 1536), (1537, 1792), (1793, 2048)]

def bucketOk (B : FfiAne.St) (lays : List LayS) (b : ABucket) : Bool :=
  Nat.beq b.layers.length 64 && (List.range 64).all fun p => match b.layers[p]?, lays[p]? with
    | some l, some L => layerOk B b.rows L p l
    | _, _ => false

/-- **The check.** -/
def aneCheck (D : List ABucket) (B : FfiAne.St) (lays : List LayS) : Bool :=
  (D.map fun b => (b.lo, b.rows)) == aneRangesT && D.all (bucketOk B lays)

/-! ## Soundness -/

theorem hdr_headerValues (c : Nat → Nat → Nat) (t : Tensor) :
    (headerValues c t).dtype = (hdr t).1 ∧ (headerValues c t).shape = (hdr t).2 := ⟨rfl, rfl⟩

theorem tyIs_sound {t : Tensor} {d : Dtype} {sh : List Nat} (h : tyIs t d sh = true) (c : Nat → Nat → Nat) :
    (headerValues c t).dtype = d ∧ (headerValues c t).shape = sh := by
  have e : hdr t = (d, sh) := of_decide_eq_true h
  exact ⟨(hdr_headerValues c t).1.trans (congrArg Prod.fst e), (hdr_headerValues c t).2.trans (congrArg Prod.snd e)⟩

theorem bitsOk_sound {b : Nat} (h : bitsOk b = true) : b = 2 ∨ b = 3 ∨ b = 4 := by
  simp only [bitsOk, Bool.or_eq_true, Nat.beq_eq] at h
  omega

theorem trelOk_sound {t : ATrel} {R bits il : Nat} (h : trelOk t R bits il = true) (c : Nat → Nat → Nat) :
    t.bits = bits ∧ ((headerValues c t.codes).dtype = .uint32 ∧ (headerValues c t.codes).shape = expandCodes R bits il) ∧
      ((headerValues c t.scales).dtype = .float16 ∧ (headerValues c t.scales).shape = [R]) := by
  simp only [trelOk, Bool.and_eq_true, Nat.beq_eq] at h
  exact ⟨h.1.1, tyIs_sound h.1.2 c, tyIs_sound h.2 c⟩

theorem linOk_sound {x : ALin} {r : Nat} {lay : LinLayout} (h : linOk x r lay = true) (c : Nat → Nat → Nat) :
    ((headerValues c x.w).dtype = .uint32 ∧ (headerValues c x.w).shape = [r, lay.cols * lay.bits / 32]) ∧
    ((headerValues c x.scales).dtype = .bfloat16 ∧ (headerValues c x.scales).shape = [r, lay.cols / 64]) ∧
    ((headerValues c x.biases).dtype = .bfloat16 ∧ (headerValues c x.biases).shape = [r, lay.cols / 64]) := by
  simp only [linOk, Bool.and_eq_true] at h
  exact ⟨tyIs_sound h.1.1 c, tyIs_sound h.1.2 c, tyIs_sound h.2 c⟩

/-- What `progOk` states. -/
structure ProgOk (B : FfiAne.St) (n : Nat) (need : List Nat) (out : Nat) (pr : FfiAne.Program) : Prop where
  ins : pr.ins.length = need.length
  bytes : pr.prog.inputBytes.length = need.length
  holds : ∀ i, i < need.length → need.getD i 0 ≤ half B (pr.ins.getD i 0)
  out : out ≤ half B pr.out

theorem progOk_sound {B : FfiAne.St} {n : Nat} {need : List Nat} {out : Nat} (h : progOk B n need out = true) :
    ∃ q pr, FfiAne.program? B n = some (q, pr) ∧ ProgOk B n need out pr := by
  unfold progOk at h
  split at h
  · rename_i q pr hp
    simp only [Bool.and_eq_true, Nat.beq_eq, List.all_eq_true, List.mem_range, Nat.ble_eq] at h
    exact ⟨q, pr, hp, h.1.1.1, h.1.1.2, h.1.2, h.2⟩
  · exact absurd h (by simp)

/-- What `mlpOk` states. -/
structure MlpOk (B : FfiAne.St) (rows : Nat) (L : LayS) (c : Nat → Nat → Nat) (m : AMlp) : Prop where
  hrows : m.rows = rows
  channels : m.channels + restOf rows = 17408
  route : m.channels = 6144 ∨ m.channels = 6656
  gb : L.mlp.gateBits = 2 ∨ L.mlp.gateBits = 3 ∨ L.mlp.gateBits = 4
  ub : L.mlp.upBits = 2 ∨ L.mlp.upBits = 3 ∨ L.mlp.upBits = 4
  db : L.mlp.downBits = 2 ∨ L.mlp.downBits = 3 ∨ L.mlp.downBits = 4
  gate : m.gate.bits = L.mlp.gateBits ∧ ((headerValues c m.gate.codes).dtype = .uint32 ∧
    (headerValues c m.gate.codes).shape = expandCodes 17408 L.mlp.gateBits 0) ∧
    ((headerValues c m.gate.scales).dtype = .float16 ∧ (headerValues c m.gate.scales).shape = [17408])
  up : m.up.bits = L.mlp.upBits ∧ ((headerValues c m.up.codes).dtype = .uint32 ∧
    (headerValues c m.up.codes).shape = expandCodes 17408 L.mlp.upBits 0) ∧
    ((headerValues c m.up.scales).dtype = .float16 ∧ (headerValues c m.up.scales).shape = [17408])
  down : (m.k3i = true ∧ L.mlp.downBits = 3 ∧ m.down.bits = 3 ∧ ((headerValues c m.down.codes).dtype = .uint32 ∧
      (headerValues c m.down.codes).shape = expandCodes 17408 3 2) ∧
      ((headerValues c m.down.scales).dtype = .float16 ∧ (headerValues c m.down.scales).shape = [17408])) ∨
    (m.k3i = false ∧ m.down.bits = L.mlp.downBits ∧ ((headerValues c m.down.codes).dtype = .uint32 ∧
      (headerValues c m.down.codes).shape = expandCodes 17408 L.mlp.downBits 0) ∧
      ((headerValues c m.down.scales).dtype = .float16 ∧ (headerValues c m.down.scales).shape = [17408]))
  rgate : m.rgate.bits = L.mlp.gateBits ∧ ((headerValues c m.rgate.codes).dtype = .uint32 ∧
    (headerValues c m.rgate.codes).shape = expandCodes (restOf rows) L.mlp.gateBits 0) ∧
    ((headerValues c m.rgate.scales).dtype = .float16 ∧ (headerValues c m.rgate.scales).shape = [restOf rows])
  rup : m.rup.bits = L.mlp.upBits ∧ ((headerValues c m.rup.codes).dtype = .uint32 ∧
    (headerValues c m.rup.codes).shape = expandCodes (restOf rows) L.mlp.upBits 0) ∧
    ((headerValues c m.rup.scales).dtype = .float16 ∧ (headerValues c m.rup.scales).shape = [restOf rows])
  rdown : m.rdown.bits = L.mlp.downBits ∧ ((headerValues c m.rdown.codes).dtype = .uint32 ∧
    (headerValues c m.rdown.codes).shape =
      expandCodes (restOf rows) L.mlp.downBits (if L.mlp.downBits = 3 then 2 else 0)) ∧
    ((headerValues c m.rdown.scales).dtype = .float16 ∧ (headerValues c m.rdown.scales).shape = [restOf rows])
  prog : ∃ q pr, FfiAne.program? B m.create = some (q, pr) ∧
    ProgOk B m.create [m.channels * 5120, m.channels * 5120, m.channels * 5120, 5120 * rows] (rows * 5120) pr

theorem mlpOk_sound {B : FfiAne.St} {rows : Nat} {L : LayS} {m : AMlp} (h : mlpOk B rows L m = true)
    (c : Nat → Nat → Nat) : MlpOk B rows L c m := by
  simp only [mlpOk, Bool.and_eq_true, Nat.beq_eq, Bool.or_eq_true] at h
  obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨hr, hc⟩, hro⟩, hg⟩, hu⟩, hd⟩, tg⟩, tu⟩, td⟩, trg⟩, tru⟩, trd⟩, hp⟩ := h
  refine ⟨hr, hc, hro, bitsOk_sound hg, bitsOk_sound hu, bitsOk_sound hd, trelOk_sound tg c, trelOk_sound tu c, ?_,
    trelOk_sound trg c, trelOk_sound tru c, trelOk_sound trd c, progOk_sound hp⟩
  cases hk : m.k3i
  · rw [hk] at td
    exact Or.inr ⟨rfl, trelOk_sound td c⟩
  · rw [hk] at td
    simp only [Bool.cond_true, Bool.and_eq_true, Nat.beq_eq] at td
    exact Or.inl ⟨rfl, td.1, trelOk_sound td.2 c⟩

/-- What `affOk` states. -/
structure AffOk (B : FfiAne.St) (rows : Nat) (L : LayS) (p : Nat) (c : Nat → Nat → Nat) (j : Nat) (a : AAff) : Prop where
  cout : a.cout = aneWidth p j
  cin : a.cin = (L.lins.getD j noLin).cols
  hseq : a.seq = rows
  head : ((headerValues c a.head.w).dtype = .uint32 ∧
      (headerValues c a.head.w).shape = [aneWidth p j, (L.lins.getD j noLin).cols * (L.lins.getD j noLin).bits / 32]) ∧
    ((headerValues c a.head.scales).dtype = .bfloat16 ∧
      (headerValues c a.head.scales).shape = [aneWidth p j, (L.lins.getD j noLin).cols / 64]) ∧
    ((headerValues c a.head.biases).dtype = .bfloat16 ∧
      (headerValues c a.head.biases).shape = [aneWidth p j, (L.lins.getD j noLin).cols / 64])
  rest : ((headerValues c a.rest.w).dtype = .uint32 ∧ (headerValues c a.rest.w).shape =
      [(L.lins.getD j noLin).rows - aneWidth p j, (L.lins.getD j noLin).cols * (L.lins.getD j noLin).bits / 32]) ∧
    ((headerValues c a.rest.scales).dtype = .bfloat16 ∧ (headerValues c a.rest.scales).shape =
      [(L.lins.getD j noLin).rows - aneWidth p j, (L.lins.getD j noLin).cols / 64]) ∧
    ((headerValues c a.rest.biases).dtype = .bfloat16 ∧ (headerValues c a.rest.biases).shape =
      [(L.lins.getD j noLin).rows - aneWidth p j, (L.lins.getD j noLin).cols / 64])
  prog : ∃ q pr, FfiAne.program? B a.create = some (q, pr) ∧
    ProgOk B a.create [aneWidth p j * (L.lins.getD j noLin).cols, (L.lins.getD j noLin).cols * rows]
      (rows * aneWidth p j) pr

theorem affOk_sound {B : FfiAne.St} {rows : Nat} {L : LayS} {p : Nat} {ja : Nat × AAff}
    (h : affOk B rows L p ja = true) (c : Nat → Nat → Nat) : AffOk B rows L p c ja.1 ja.2 := by
  simp only [affOk, Bool.and_eq_true, Nat.beq_eq] at h
  obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := h
  exact ⟨h1, h2, h3, linOk_sound h4 c, linOk_sound h5 c, progOk_sound h6⟩

/-- What `layerOk` states. -/
structure LayerOk (B : FfiAne.St) (rows : Nat) (L : LayS) (p : Nat) (c : Nat → Nat → Nat) (l : ALayer) : Prop where
  attn : L.attn = aneAttn p
  mlp : MlpOk B rows L c l.mlp
  aff : 768 ≤ rows → l.aff.map Prod.fst = aneSites p ∧ ∀ ja ∈ l.aff, AffOk B rows L p c ja.1 ja.2

theorem layerOk_sound {B : FfiAne.St} {rows : Nat} {L : LayS} {p : Nat} {l : ALayer} (h : layerOk B rows L p l = true)
    (c : Nat → Nat → Nat) : LayerOk B rows L p c l := by
  simp only [layerOk, Bool.and_eq_true, beq_iff_eq] at h
  obtain ⟨⟨ha, hm⟩, hf⟩ := h
  refine ⟨ha, mlpOk_sound hm c, fun hr => ?_⟩
  have : Nat.ble 768 rows = true := Nat.ble_eq.mpr hr
  rw [this] at hf
  simp only [Bool.cond_true, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at hf
  exact ⟨hf.1, fun ja hja => affOk_sound (hf.2 ja hja) c⟩

/-- **What the check states** of the buckets `D` on the bridge `B` at the stages' layouts `lays`. -/
theorem aneCheck_sound {D : List ABucket} {B : FfiAne.St} {lays : List LayS} (h : aneCheck D B lays = true)
    (c : Nat → Nat → Nat) :
    D.map (fun b => (b.lo, b.rows)) = aneRangesT ∧ ∀ b ∈ D, b.layers.length = 64 ∧
      ∀ p, p < 64 → ∃ l L, b.layers[p]? = some l ∧ lays[p]? = some L ∧ LayerOk B b.rows L p c l := by
  simp only [aneCheck, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h
  refine ⟨h.1, fun b hb => ?_⟩
  have hb := h.2 b hb
  simp only [bucketOk, Bool.and_eq_true, Nat.beq_eq, List.all_eq_true, List.mem_range] at hb
  refine ⟨hb.1, fun p hp => ?_⟩
  have := hb.2 p hp
  split at this
  · rename_i l L e1 e2
    exact ⟨l, L, e1, e2, layerOk_sound this c⟩
  · exact absurd this (by simp)

end Host.Load.Boot
