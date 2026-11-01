import host.route.CertStep
import host.simgraph.mach.Agree
import host.route.PrefGraph
import host.load.run.full.InitialLayout
import host.simgraph.family.FoldedData
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter
open Host.Mlx.SimGraph.Mach (CacheValuesV routeVal GrR evalR_routeVal)
open Host.Mlx.SimGraph.Ref (refRows refNu rowSem rowIds stepEnv handlesOf)

/-! # A first forward's certificate

`FamCert`: a row family's expected graph at the cold layout, checked against a first forward's end template. It names no
chain: a generated module instantiates it from `simgraph_choose_route` and `simgraph_check_segment`.

* `ffiGraphR_key`: the route's graph at prompt keys is its graph at input keys, keyed.
* `FamCert.emb`: the end template embeds in the route's graph, from the native relation.
* `FamCert.plain`: the kernels are plain at the carriers, because the domain excludes replayed ones.
* `FamCert.inputs`: the carriers of the family's inputs hold them.
* `FamCert.values`: **the forward's handles at their carriers.** -/

/-! ## Keys -/

section
variable {δ κ κ' : Type} (f : κ → κ')

theorem resolvePrim_key (N : Nums δ) (kn : Nat → Option (List Char)) (shape : List Ffi.Dim) (dtype : Nat) :
    ∀ p : Ffi.Prim, (resolvePrim (κ := κ) N kn shape dtype p).map (keyP f) = resolvePrim (κ := κ') N kn shape dtype p := by
  intro p
  induction p with
  | replayed c p ih =>
    simp only [resolvePrim, Option.map_map]
    rw [← ih, Option.map_map]
    rfl
  | data b =>
    simp only [resolvePrim, Option.bind_eq_bind, Option.pure_def]
    cases b.mapM N.byte <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases shape.mapM N.d <;> rfl
  | zeros =>
    simp only [resolvePrim]
    cases shape.mapM N.d <;> rfl
  | reshape l =>
    simp only [resolvePrim]
    cases l.mapM N.d <;> rfl
  | slice a b c =>
    simp only [resolvePrim, Option.bind_eq_bind, Option.pure_def]
    cases a.mapM N.d <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases b.mapM N.d <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases c.mapM N.d <;> rfl
  | sliceUpdate a b c =>
    simp only [resolvePrim, Option.bind_eq_bind, Option.pure_def]
    cases a.mapM N.d <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases b.mapM N.d <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases c.mapM N.d <;> rfl
  | sliceDynamic _ l =>
    simp only [resolvePrim]
    cases l.mapM N.d <;> rfl
  | rmsNorm e =>
    simp only [resolvePrim]
    cases N.word e <;> rfl
  | rope _ _ b s o =>
    simp only [resolvePrim, Option.bind_eq_bind, Option.pure_def]
    cases Ffi.argNat b <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases N.word s <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases N.dim o <;> rfl
  | sdpa s _ =>
    simp only [resolvePrim]
    cases N.word s <;> rfl
  | kernel k c _ =>
    simp only [resolvePrim, Option.bind_eq_bind, Option.pure_def]
    cases kn k <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases resolveCfg N c <;> rfl
  | _ => rfl

end

theorem resolvePrimP_key {κ κ' : Type} (f : κ → κ') (N : Nums Int) (kn : Nat → Option (List Char)) (shape : List Ffi.Dim)
    (dtype : Nat) : ∀ p : Ffi.Prim,
      (resolvePrimP (κ := κ) N kn shape dtype p).map (keyP f) = resolvePrimP (κ := κ') N kn shape dtype p
  | .arange a b c => by
    simp only [resolvePrimP, Option.bind_eq_bind]
    cases N.dim a with
    | none => rfl
    | some x =>
      simp only [Option.bind_some]
      cases N.dim c with
      | none => rfl
      | some y =>
        simp only [Option.bind_some]
        cases shape.mapM N.d with
        | none => rfl
        | some l =>
          simp only [Option.bind_some]
          match l with
          | [] => rfl
          | [n] =>
            dsimp only
            split <;> rfl
          | _ :: _ :: _ => rfl
  | .replayed c p => by
    simp only [resolvePrimP, Option.map_map]
    rw [← resolvePrimP_key f N kn shape dtype p, Option.map_map]
    rfl
  | .data _ | .load _ _ | .tracer _ | .zeros | .reshape _ | .transpose _ | .slice _ _ _ | .sliceUpdate _ _ _
  | .sliceDynamic _ _ | .concat _ | .unary _ | .binary _ | .astype _ | .contiguous | .rmsNorm _ | .rope _ _ _ _ _
  | .sdpa _ _ | .qmm _ _ _ _ | .dequantize _ _ _ _ | .take _ | .conv1d _ _ _ _ | .logsumexp _ _ | .kernel _ _ _ =>
    resolvePrim_key f N kn shape dtype _

theorem ffiGraphR_key {κ κ' : Type} (f : κ → κ') (N : Nums Int) (S : KernelSources) (s : Ffi.St) :
    keyG f (ffiGraphR (κ := κ) N S s) = ffiGraphR (κ := κ') N S s := by
  funext i
  simp only [keyG, ffiGraphR]
  cases s.nodes.get i with
  | none => rfl
  | some nd =>
    simp only [Option.bind_some, resolveNodeP, Option.map_map]
    rw [← resolvePrimP_key f N (routeKernelName? S s) nd.shape nd.dtype nd.prim, Option.map_map]
    rfl

end Host.Route.PrefGraph
