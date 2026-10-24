import host.simgraph.mach.PreAneFam
import host.simgraph.mach.AneOrder
import host.simgraph.ref.Route
namespace Host.Mlx

/-- **The Neural Engine succeeds on the programs the route loads** (the trust boundary, as the GPU assumption's
launches succeed): at every bucket of 224–2048 rows, the program of each split of the loaded model's Neural Engine
side (`AneNet.split`) evaluates (`NE.eval` returns `some`) on input surfaces of the program's declared inputs, one per
input byte size it declares. `NeuralEngine` itself is unchanged. -/
def NeuralEngine.Succeeds (NE : NeuralEngine) (net : SimGraph.Ref.AneNet) : Prop :=
  ∀ n, 224 ≤ n → n ≤ 2048 → ∀ k sp, net.split n k = some sp →
    ∀ ins : List Surface, ins.length = sp.prog.prog.inputBytes.length → (NE.eval sp.prog.prog ins).isSome

end Host.Mlx

namespace Host.Mlx.SimGraph.Mach
open Host.Mlx.GlueStep Host.Mlx.GlueLayers
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Ref (refRows AneNet SplitSpec FillSpec FillSrc aneTplOf)

/-! # The loaded model's Neural Engine side, as the route's Neural Engine steps need it

`AneNetOk net ws` is what a Neural Engine step needs of the loaded model's Neural Engine side (`AneNet`, built
by the boot from the loaded state) on the loaded stages `ws`, at every bucket `n` of 224–2048 rows (the bucket's
family `aneTplOf n = aneTpl refRows (aneKindsOf n) (aneRestOf n)`):

* only readback keys (`.linOut`, `.mlpOut`) have a split;
* each readback the family reads (a split projection site's or the MLP's, `rbSite`) has a split (`SplitOk`): at
  its layer and tap site, reading back `[n, D]` (`rbDim`: the site's ANE rows, or 5120) within its output surface,
  its program's inputs those it declares, every fill one the route's in-place kernels complete (`FillOk`: a trellis
  fill from construction-time codes and scales, or a half write of one of the site's taps);
* the construction-time inputs are typed: each split site's head and rest rows (`PartsW`), each MLP split's rest
  rows (`MlpRestW`). -/

/-- The bucket's projection kinds (`aneTplOf`). -/
def aneKindsOf (n : Nat) : AneKinds := if n ≤ 512 then aneSmallK else if n ≤ 704 then aneDenseK else aneAffineK

/-- The bucket's MLP split GPU rows (`aneTplOf`). -/
def aneRestOf (n : Nat) : Nat := if n ≤ 768 then 11264 else 10752

theorem aneTplOf_eq {n : Nat} (h1 : 224 ≤ n) (h2 : n ≤ 2048) :
    aneTplOf n = some (aneTpl refRows (aneKindsOf n) (aneRestOf n)) := by
  unfold aneTplOf aneKindsOf aneRestOf aneSmall aneDense aneAffine
  by_cases a : n ≤ 512
  · simp [a, show ¬ n < 224 by omega, show n ≤ 768 by omega]
  by_cases b : n ≤ 704
  · simp [a, b, show ¬ n < 224 by omega, show n ≤ 768 by omega]
  by_cases c : n ≤ 768
  · simp [a, b, c, show ¬ n < 224 by omega]
  · simp [a, b, c, h2, show ¬ n < 224 by omega]

theorem kindsOk_of (n : Nat) : KindsOk (aneKindsOf n) := by
  unfold aneKindsOf
  split
  · exact kindsOk_small
  · split
    · exact kindsOk_dense
    · exact kindsOk_affine

theorem restOf_cases (n : Nat) : aneRestOf n = 11264 ∨ aneRestOf n = 10752 := by
  unfold aneRestOf; split <;> simp

/-- A readback's width and its site's tap sizes: a split site's ANE rows, its flattened head rows `[nA·cols]` and
input `[cols·n]`; the MLP's 5120 and its flattened input `[5120·n]`. -/
def rbDim (kd : AneKinds) (n : Nat) : StageLayout → AKey → Option (Nat × List Nat)
  | .delta d, .linOut _ j => match kd.delta j with
    | .split nA => some (nA, [nA * (dLay d j).cols, (dLay d j).cols * n])
    | _ => none
  | .delta _, .mlpOut _ => some (5120, [5120 * n])
  | .attention a, .linOut _ j => match kd.attn j with
    | .split nA => some (nA, [nA * (aLay a j).cols, (aLay a j).cols * n])
    | _ => none
  | .attention _, .mlpOut _ => some (5120, [5120 * n])
  | _, _ => none

/-- A fill the route's in-place kernels complete (`RouteKernelContract.aneTrellisFill`, `aneTrellisFillK3i`,
`aneWriteHalf`), onto a float16 wrap: a trellis fill of `rows` rows from construction-time codes and scales, or a
half write of the site's tap `i` (of `sizes[i]` elements). -/
def FillOk (sizes : List Nat) (f : FillSpec) : Prop :=
  f.dt = .float16 ∧
  ((∃ rows bits cd sc, f.k = .trellisFill ∧ f.cfg = fillConfig rows bits ∧ FillRoute rows bits ∧
      f.srcs = [.val cd, .val sc] ∧ Typed cd .uint32 [17408, 160 * bits] ∧ Typed sc .float16 [17408] ∧
      rows * 5120 ≤ f.sh.foldr (· * ·) 1) ∨
    (∃ rows cd sc, f.k = .trellisFillK3i ∧ f.cfg = fillConfig rows 3 ∧ (rows = 6144 ∨ rows = 6656) ∧
      f.srcs = [.val cd, .val sc] ∧ Typed cd .uint32 [10, 17408, 48] ∧ Typed sc .float16 [17408] ∧
      rows * 5120 ≤ f.sh.foldr (· * ·) 1) ∨
    (∃ i N, f.k = .writeHalf ∧ f.cfg = writeConfig N ∧ f.srcs = [.tap i] ∧ sizes[i]? = some N ∧
      N ≤ f.sh.foldr (· * ·) 1))

/-- A split call at layer `p`, tap site `s`, reading back `[n, D]`: its reader within the output surface, its
program's inputs those it declares, its fills completing on the site's taps (`sizes`). -/
structure SplitOk (n p s D : Nat) (sizes : List Nat) (sp : SplitSpec) : Prop where
  layer : sp.layer = p
  site : sp.site = s
  m_eq : sp.M = n
  d_eq : sp.D = D
  len : n * D ≤ sp.len
  ins : sp.prog.ins.length = sp.prog.prog.inputBytes.length
  fills : ∀ f ∈ sp.fills, FillOk sizes f

/-- The construction-time inputs at a forward of `n` rows as an environment. -/
def netEnv (net : AneNet) (n : Nat) : Env AKey := ⟨fun _ _ => none, net.inputs n⟩

/-- A split site's head and rest rows at a forward of `n` rows, layer `p`, site `j`. -/
structure PartsW (net : AneNet) (n p j : Nat) (lay : LinLayout) (nA : Nat) : Prop where
  head : LinW (netEnv net n) lay.bits nA lay.cols (.part p j true)
  rest : LinW (netEnv net n) lay.bits (lay.rows - nA) lay.cols (.part p j false)

/-- A layer's Neural Engine side at bucket `n`, position `p`, of kind `sl`: each readback the family reads has its
split; the split sites' head and rest rows and the MLP split's rest rows are typed. -/
def AneNetLayer (net : AneNet) (n p : Nat) (kd : AneKinds) (rest : Nat) (sl : StageLayout) : Prop :=
  (∀ k s D sizes, rbLayer k = some p → rbSite kd sl k = some s → rbDim kd n sl k = some (D, sizes) →
    ∃ sp, net.split n k = some sp ∧ SplitOk n p s D sizes sp) ∧
  match sl with
  | .delta d => (∀ j nA, j < 5 → kd.delta j = .split nA → PartsW net n p j (dLay d j) nA) ∧
      MlpRestW (netEnv net n) d.mlp rest (.mlpRest p)
  | .attention a => (∀ j nA, j < 4 → kd.attn j = .split nA → PartsW net n p j (aLay a j) nA) ∧
      MlpRestW (netEnv net n) a.mlp rest (.mlpRest p)

/-- **The loaded model's Neural Engine side on the loaded stages `ws`** (to be proved from the boot's state): only
readback keys have splits, and at every bucket of 224–2048 rows every layer's Neural Engine side is as its family
reads it (`AneNetLayer`, at the stage's layout for any handles: the projection layouts are the weights'). -/
structure AneNetOk (net : AneNet) (ws : List StageWeights) : Prop where
  keys : ∀ n k sp, net.split n k = some sp → rbLayer k ≠ none
  layers : ∀ n, 224 ≤ n → n ≤ 2048 → ∀ p s h, ws[p]? = some s →
    AneNetLayer net n p (aneKindsOf n) (aneRestOf n) (stageLayout s h)

end Host.Mlx.SimGraph.Mach
