import host.simgraph.family.AneLayers
import host.simgraph.family.KernelSlot
import host.simgraph.family.KeyMap
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx
open Host.Mlx.FfiAneEval (Mem pureVal noInput)

/-! # The Neural Engine row families

The GPU side of each Neural Engine forward (prefill-map §2–4) as a
`RowTplX AKey`: the bucket's projection kinds per site (`AneKinds`) and the
MLP split's GPU rows (`rest`):

| family | projections (delta qkv z a b out; attention q k v o) | MLP rest |
|---|---|---|
| `aneSmall` (ane256–512, chunks 256, 512) | dense dense plain plain dense; dense plain plain dense | 11264 |
| `aneDense` (ane576–704) | as `aneSmall`; dense ×4 | 11264 |
| `aneAffine 11264` (ane768) | split 3840, split 2304, plain, plain, split 1920; split 4608, dense, dense, split 1920 | 11264 |
| `aneAffine 10752` (ane896–2048, chunks 1024, 2048) | as above | 10752 |

Keys (`AKey`): the GPU families' (`.p`), each split's readback (`linOut p j`,
`mlpOut p`: the `astype` of the program's output view, a reader), an affine
split's head and rest weight rows (`part`), the MLP split's rest rows
(`mlpRest`). Each family is natural, branches only on the KV signature and
simulates its reference computation (`aneTpl_eval`: the expected graph holds
the output, caches and taps).

`aneTpl_graph_step` is the graph postcondition in the Neural Engine
semantics: with the readers' and writers' leaves keyed by `rk` (each reader
by its readback's key) and an environment holding each one's fixed value, the
carriers of the output, the caches and every tap hold the reference values as
pure values (`pureVal`). -/

/-- The Neural Engine forwards' input keys. -/
inductive AKey where
  | p (k : PKey)
  /-- Layer `p`'s affine split at site `j`: its readback. -/
  | linOut (p j : Nat)
  /-- Layer `p`'s MLP split: its readback. -/
  | mlpOut (p : Nat)
  /-- Layer `p`'s affine split at site `j`: the head (`true`) or rest rows' weights (`rowsOf` at construction). -/
  | part (p j : Nat) (head : Bool) (l : LinKey)
  /-- Layer `p`'s MLP split: the rest rows' codes and scales (`trellisRows`/`trellisStoredRows`). -/
  | mlpRest (p : Nat) (m : MlpKey)
deriving DecidableEq

/-- The projection kind at each site of a delta and an attention layer. -/
structure AneKinds where
  delta : Nat → AneProj
  attn : Nat → AneProj

/-- #aneSmall (M:1252-1315): Dense qkv, z, out, q, o; Plain a, b, k, v. -/
def aneSmallK : AneKinds :=
  ⟨fun j => if j = 2 ∨ j = 3 then .plain else .dense, fun j => if j = 1 ∨ j = 2 then .plain else .dense⟩

/-- #aneDense: attention Dense ×4. -/
def aneDenseK : AneKinds := ⟨aneSmallK.delta, fun _ => .dense⟩

/-- #aneAffine (written-layers.ts:154-162, 245-250): splits at .375 of qkv, z, out, q, o; Dense k, v. -/
def aneAffineK : AneKinds :=
  ⟨fun j => if j = 0 then .split 3840 else if j = 1 then .split 2304 else if j = 4 then .split 1920 else .plain,
    fun j => if j = 0 then .split 4608 else if j = 3 then .split 1920 else .dense⟩

section
variable {δ : Type} {m : Type → Type} [Monad m] {α : Type} (B : Backend δ AKey m α) (I : PDim → δ) (R : Rows)

/-- Layer `p`'s projection at site `j` of kind `kd j`. -/
def aneProjAt (kd : Nat → AneProj) (p j : Nat) (lay : LinLayout) (x : α) : m (α × α × α) :=
  aneProjT B I R (kd j) lay (fun l => .p (stageKey p (.lin j l))) (.part p j true) (.part p j false) (.linOut p j) x

/-- Layer `p`'s MLP split. -/
def aneMlpAt (rest p : Nat) (ml : MlpLayout) (x : α) : m (α × α) := aneMlpT B I R rest ml (.mlpRest p) (.mlpOut p) x

def aneSKey (p : Nat) (k : SKey) : AKey := .p (stageKey p k)
def aneAux (p i : Nat) : AKey := .p (auxKey R .causal p i)

end

/-- A Neural Engine row family at the step's symbolic offset and rows. -/
def aneTpl (R : Rows) (k : AneKinds) (rest : Nat) : RowTplX AKey where
  sig := kvSigP
  embed B _ := embedT B (AKey.p .promptIds) fun k => AKey.p (.base k)
  layer B I o n p s x := match s with
    | .delta d => aneDeltaLayerT B I (aneProjAt B I R k.delta p) (aneMlpAt B I R rest p) R d (aneSKey p) (aneAux R p) x
    | .attention a =>
      aneAttentionLayerT B I (aneProjAt B I R k.attn p) (aneMlpAt B I R rest p) R o n a (aneSKey p) (aneAux R p) x
  final B _ y := normT B (AKey.p (.base .finalNorm)) y

def aneSmall (R : Rows) : RowTplX AKey := aneTpl R aneSmallK 11264
def aneDense (R : Rows) : RowTplX AKey := aneTpl R aneDenseK 11264
def aneAffine (R : Rows) (rest : Nat) : RowTplX AKey := aneTpl R aneAffineK rest

/-! ## Naturality, branches, simulation -/

section
variable (R : Rows) (k : AneKinds) (rest : Nat)

theorem aneTpl_natural : (aneTpl R k rest).IsNatural where
  embed f _ := by dsimp only [aneTpl]; exact nat_embedT f _ _
  layer f I o n p s x := by
    dsimp only [aneTpl]
    cases s with
    | delta d =>
      exact nat_aneDeltaLayerT f (aneProjAt graphB I R k.delta p) (aneProjAt graphB (fun d => f (I d)) R k.delta p)
        (aneMlpAt graphB I R rest p) (aneMlpAt graphB (fun d => f (I d)) R rest p)
        (fun j lay x => nat_aneProjT f I R _ lay _ _ _ _ x) (fun lay x => nat_aneMlpT f I R rest lay _ _ x) R d _ _ x
    | attention a =>
      exact nat_aneAttentionLayerT f (aneProjAt graphB I R k.attn p) (aneProjAt graphB (fun d => f (I d)) R k.attn p)
        (aneMlpAt graphB I R rest p) (aneMlpAt graphB (fun d => f (I d)) R rest p)
        (fun j lay x => nat_aneProjT f I R _ lay _ _ _ _ x) (fun lay x => nat_aneMlpT f I R rest lay _ _ x) R o n a _ _ x
  final f _ y := by dsimp only [aneTpl]; exact nat_normT f _ y

theorem aneTpl_sigOK : (aneTpl R k rest).SigOK := by
  intro δ I o n o' n' p s s' x h
  cases s with
  | delta d =>
    cases s' with
    | delta d' => cases (h : d = d'); rfl
    | attention _ => exact h.elim
  | attention a =>
    cases s' with
    | delta _ => exact h.elim
    | attention a' => exact aneAttentionLayerT_sig I (aneProjAt graphB I R k.attn p) (aneMlpAt graphB I R rest p) R o n o' n' a a' h _ _ x

/-- The family without its taps, with its obligations (for `FamilyTemplate`). -/
def aneFamily : RowFamily AKey := (aneTpl R k rest).family (aneTpl_natural R k rest) (aneTpl_sigOK R k rest)

variable {C : M1Max.Contract} {P : MlxPrefillContract C} {K : KernelContract C} {env : Env AKey} {ks : KernelSem}

theorem aneTpl_simulates : (aneTpl R k rest).Simulates P K env ks where
  embed _ fs := by dsimp only [aneTpl]; exact sim_embedT _ _ fs
  layer ν o n p s x v fs h := by
    dsimp only [aneTpl]
    cases s with
    | delta d =>
      exact sim_aneDeltaLayerT ν (aneProjAt graphB (PDim.eval ν) R k.delta p)
        (aneProjAt (valueB P K env ks) (PDim.eval ν) R k.delta p) (aneMlpAt graphB (PDim.eval ν) R rest p)
        (aneMlpAt (valueB P K env ks) (PDim.eval ν) R rest p)
        (fun j lay fs x v h => sim_aneProjT ν R _ lay _ _ _ _ fs x v h)
        (fun lay fs x v h => sim_aneMlpT ν R rest lay _ _ fs x v h) R d _ _ fs x v h
    | attention a =>
      exact sim_aneAttentionLayerT ν (aneProjAt graphB (PDim.eval ν) R k.attn p)
        (aneProjAt (valueB P K env ks) (PDim.eval ν) R k.attn p) (aneMlpAt graphB (PDim.eval ν) R rest p)
        (aneMlpAt (valueB P K env ks) (PDim.eval ν) R rest p)
        (fun j lay fs x v h => sim_aneProjT ν R _ lay _ _ _ _ fs x v h)
        (fun lay fs x v h => sim_aneMlpT ν R rest lay _ _ fs x v h) R o n a _ _ fs x v h
  final _ y v fs h := by dsimp only [aneTpl]; exact sim_normT fs _ y v h

/-- **The family's expected graph holds its reference values**, taps included. -/
theorem aneTpl_eval (ν : Nat → Int) (o n : Nat) (ss : List StageLayout) (out : Value) (cs : List (Value × Value))
    (taps : List (List (List Value)))
    (hv : forwardTX (aneTpl R k rest) (valueB P K env ks) (PDim.eval ν) o n ss = some ((out, cs), taps)) :
    AllEvE P K env ks (familyGraph (aneTpl R k rest).toTpl.ops (PDim.eval ν) o n ss).1
      (Handle.facts (familyGraph (aneTpl R k rest).toTpl.ops (PDim.eval ν) o n ss).2 (out, cs) ++
        Handle.facts ((aneTpl R k rest).tapsOf (PDim.eval ν) o n ss) taps) :=
  familyGraphX_eval (aneTpl R k rest) (aneTpl_simulates R k rest) ν o n ss out cs taps hv

end

/-! ## The pure graph keyed by the readbacks -/

section
variable {δ κ κ' : Type} (f : κ → κ')

theorem strip_keyP (p : RPrim δ κ) : strip (keyP f p) = keyP f (strip p) := by
  induction p <;> simp_all [keyP]

theorem keyP_kernel {p : RPrim δ κ} {name : List Char} {c : RCfg δ} {out : Nat} :
    keyP f p = .kernel name c out ↔ p = .kernel name c out := by
  cases p <;> simp [keyP]

end

/-- The pure graph's kernel nodes are the FFI graph's: unreplayed when those are. -/
theorem kernelsPlain_pure (G : FfiAneEval.Graph) (rk : Nat → AKey)
    (h : ∀ j nd name c out, G.node j = some nd → strip nd.prim = .kernel name c out → nd.prim = .kernel name c out) :
    KernelsPlain (keyG rk G.pure) := by
  intro j nd name c out hj hs
  simp only [keyG, Option.map_eq_some_iff] at hj
  obtain ⟨nd0, hj0, rfl⟩ := hj
  unfold FfiAneEval.Graph.pure at hj0
  split at hj0
  · cases hj0; simp [keyN, keyP] at hs
  · simp only [keyN, strip_keyP, keyP_kernel] at hs ⊢
    exact h j nd0 name c out hj0 hs

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C)

/-- A reader's or writer's leaf holds the environment's value at its key. -/
theorem evalRR_reader (env : Env AKey) (kind : Nat → Option Compiled) (G : FfiAneEval.Graph) (rk : Nat → AKey)
    (b : Nat) (hb : (G.touch b).isSome = true) :
    evalRR P K env kind (keyG rk G.pure) b = env.inputs (rk b) := by
  have hg : keyG rk G.pure b = some ⟨.input (rk b), []⟩ := by
    simp [keyG, FfiAneEval.Graph.pure, hb, keyN, keyP]
  rw [evalRR_eq, hg]
  dsimp only
  rw [cgLeaves_none _ b _ hg rfl]
  dsimp only
  have hc : closureLeaves kind (keyG rk G.pure) b = none := by simp [closureLeaves, hg, closureAux]
  rw [hc]
  dsimp only
  simp only [List.mapM_nil, Option.pure_def, Option.bind_some]
  cases hv : env.inputs (rk b) <;> simp [primEvalR, primEvalP, primEval, prefillEval, Option.orElse, rowsEval, hv]

/-- **The graph postcondition of a Neural Engine forward** in the Neural
Engine semantics at memory `m`: the readers' and writers' leaves keyed by
`rk`, the environment holding each one's fixed value at its key (`hr`) and
the run's weights (`hw`); the iteration's keyed pure graph carries the
family's graph (`emb`); when the reference computation returns the output,
caches and taps, their carriers' pure values are those values. -/
theorem aneTpl_graph_step (weights : List Char → List Char → Option Value) (G : FfiAneEval.Graph) (m : Mem)
    (rk : Nat → AKey) (env : Env AKey) (hw : env.weights = weights)
    (hr : ∀ j, (G.touch j).isSome = true → env.inputs (rk j) = m.vals j)
    (hn : ∀ j nd, G.node j = some nd → noInput nd.prim = true)
    (R : Rows) (k : AneKinds) (rest : Nat) (T : FamilyTemplate (aneFamily R k rest)) (ν : Nat → Int) (o n : Nat)
    (ss : List StageLayout) (hsig : List.Forall₂ (SigRelR kvSigP T.o₀ T.n₀ o n) T.ss₀ ss) (σ cl : Nat → Nat)
    (emb : Embeds σ cl (mapG (PDim.eval ν) T.Gs) (keyG rk G.pure)) (kind' : Nat → Option Compiled)
    (hk : ∀ c, kind' (cl c) = T.kind c)
    (hin : InputsHeldR P K env kind' (keyG rk G.pure)
      (familyGraph (aneTpl R k rest).toTpl.ops (PDim.eval ν) o n ss).1 (T.cert.map σ))
    (hG : KernelsPlain (keyG rk G.pure)) (out : Value) (cs : List (Value × Value)) (taps : List (List (List Value)))
    (hv : forwardTX (aneTpl R k rest) (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval ν) o n ss =
      some ((out, cs), taps)) :
    ∀ q ∈ Handle.facts (familyGraph (aneTpl R k rest).toTpl.ops (PDim.eval ν) o n ss).2 (out, cs) ++
        Handle.facts ((aneTpl R k rest).tapsOf (PDim.eval ν) o n ss) taps,
      pureVal P K weights kind' G m (σ (certAt T.cert q.1)) = some q.2 := by
  intro q hq
  have hall := aneTpl_eval (P := P) (K := K.toKernelContract) (env := env) (ks := ksR P K env) R k rest ν o n ss
    out cs taps hv
  rw [pureVal_keyG P K weights kind' G m rk env hw hr hn]
  exact family_template_stepR P K T ν o n ss hsig env (keyG rk G.pure) σ cl emb kind' hk hin hG q.1 q.2 (hall q hq)

end

/-! ## The GPU share's vector expansions at the route contract -/

theorem prefillOf_vectorExpand : prefillOf chars!"mlx_bun_trellis_vector_expand" = some .vectorExpand :=
  prefillOf_self .vectorExpand

/-- The vector expansion's launch resolves to the contract's `expandConfig` (row tile 128 iff interleaved). -/
theorem toConfig_expand (ν : Nat → Int) (rows bits il : Nat) :
    toConfig (expandCfg (PDim.eval ν) rows bits il) = some (expandConfig rows bits il (if il = 0 then 0 else 128)) := by
  by_cases h : il = 0 <;>
    simp [toConfig, expandCfg, kcfg, outOf, natShape, triple?, nat?, dtOf, intOf, initOf, PDim.eval, h, Dtype.ofCode,
      Ffi.dtBf16, expandConfig] <;> omega

end Host.Mlx.SimGraph
