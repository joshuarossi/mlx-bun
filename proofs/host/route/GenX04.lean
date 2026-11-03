import host.route.GenOfHooks
import host.route.cert.Fin.Caps
import host.sim.compose.a4b.FillX4L7P
import host.sim.compose.a4b.FillX4L8P
import host.sim.compose.a4b.FillX4L9P
import host.sim.compose.a4b.FillX0P
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Compose Host.Ts.Sim.Template
open Host.Ts.Sim.Compose.FillPost (loadVW classX4L7 hooksX4L7 invsX4L7 piecesX4L7 memX4L70_enter memX4L70_keep classX4L8 hooksX4L8 invsX4L8 piecesX4L8 memX4L80_enter memX4L80_keep classX4L9 hooksX4L9 invsX4L9 piecesX4L9 memX4L90_enter memX4L90_keep classX0 hooksX0 invsX0 piecesX0 memX00_enter memX00_keep)
open Host.Load.Run.Prompt
open Host.Route.PrefGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # The route of an x4 prompt (7, 8 or 9 tokens) and of an x0 prompt (2 tokens) -/

section
variable {C : M1Max.Contract}
  (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
  (bytes : KernelGpu.SetBytes) (lseSum : Bool)
  (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
  (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
  (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
  (π : List Nat) (T : Nat) (hlt : ∀ t ∈ π, t < 248320) (hT : 1 ≤ T) (hctx : π.length + T ≤ 262144)
  (hNE : NE.Succeeds net)
  (hnet : ∀ tab, Host.Mlx.SimGraph.Mach.AneNetOk net
    (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))

local notation "Kr" => routeKernel G bytes Pg lseSum lseNumerator
local notation "Tk" => machTok P Kr NE net env π
local notation "Je" => entryEnv (Host.Load.Run.Prompt.P.at0 (List.map natV π) (machReads T Tk))

include leaves typed hlt hNE hnet in
theorem preS (h2 : 2 ≤ π.length) (h9 : π.length ≤ 9) : ∀ tab, ∃ s, Host.Mlx.SimGraph.Ref.prefillAt P Kr NE (Kr).inPlace net env π tab = some s ∧
    List.Forall₂ (Host.Mlx.SimGraph.Mach.StagePre (π.length - 1))
      (stageWeights (weights (firstValues P.toMlxContract (Kr).toKernelContract env tab))) s.hs := fun tab =>
  Host.Route.Cert.Fin.prefill_pre P Kr NE (Kr).inPlace net env π Pg rfl leaves typed (by omega) (by omega)
    (Host.Mlx.SimGraph.Mach.scheduleTyped P Kr NE net env π leaves typed (by omega) hlt hNE hnet) tab

include leaves typed in
theorem stepS : ∀ tab, ∃ t hs', stepTrace P.toMlxContract (Kr).toKernelContract
    (weights (firstValues P.toMlxContract (Kr).toKernelContract env tab)) 0 (π.getD 0 0) initialHandles = some (t, hs') := fun tab => by
  have hw := Host.Mlx.SimGraph.Mach.pipeTy_of_loaded P.toMlxContract (Kr).toKernelContract
    (firstPipeline_loaded P.toMlxContract (Kr).toKernelContract env tab leaves typed)
  obtain ⟨tok', hs', e', -, -⟩ := Host.Mlx.SimGraph.Mach.stepTrace_ty P.toMlxContract (Kr).toKernelContract Pg rfl hw (π.getD 0 0)
    (Host.Mlx.SimGraph.Mach.initial_ty _)
  exact ⟨tok', hs', e'⟩

/-- POST's hooks of a X4L7 prompt (7 tokens), at the class's capacity 70039 and the tail's 226250. -/
noncomputable def hooksRX4L7 (hk : π.length = 7) : FillPost.Hooks 15235 T Tk π 226250 19265 (classX4L7 15235 T Tk π 70039 19265 (by decide)) :=
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed (π := π) (by omega) (by omega) hlt hNE hnet
  have htk : ∀ j, Tk j ≤ 248319 := machTok_le P Kr NE net env π (hRT []) (by omega) hlt
  hooksX4L7 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) leaves typed hRT hk (by decide) (by decide)
    (by decide) hT (fun tab j _ => machTok_def P Kr NE net env π (hRT []) (by omega) tab j) (by have := htk 1; omega)

local notation "HX4L7" => hooksRX4L7 P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hlt hT hNE hnet

/-- **The route of a X4L7 prompt** (7 tokens). -/
noncomputable def routeGenX4L7 (hk : π.length = 7) :
    RouteGenGpu P Kr NE net env π T Tk Je chars!"emitted" (ldStT [] []) (ldStT (List.map natV π) (machReads T Tk)) :=
  routeGenOfHooks P G Pg bytes lseSum lseNumerator NE net env leaves typed π T (by omega) (by omega) hlt hT hctx hNE hnet (HX4L7 hk) rfl
    (invsX4L7 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX4L7 hk)).ld
    (invsX4L7 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX4L7 hk)).pc0
    (invsX4L7 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX4L7 hk)).pf
    (invsX4L7 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX4L7 hk)).pc
    (by decide)
    (piecesX4L7 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (by decide) (by decide) (by decide) hk hlt
      (fun t ht => by have := hlt t ht; omega) leaves typed (preS P G Pg bytes lseSum lseNumerator NE net env leaves typed π hlt hNE hnet (by omega) (by omega)) (HX4L7 hk)
      (fun _ _ _ h v m => memX4L70_enter h v m) (fun _ _ _ h m => memX4L70_keep h m))
    (loadVW leaves)

/-- POST's hooks of a X4L8 prompt (8 tokens), at the class's capacity 70039 and the tail's 226554. -/
noncomputable def hooksRX4L8 (hk : π.length = 8) : FillPost.Hooks 15235 T Tk π 226554 19265 (classX4L8 15235 T Tk π 70039 19265 (by decide)) :=
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed (π := π) (by omega) (by omega) hlt hNE hnet
  have htk : ∀ j, Tk j ≤ 248319 := machTok_le P Kr NE net env π (hRT []) (by omega) hlt
  hooksX4L8 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) leaves typed hRT hk (by decide) (by decide)
    (by decide) hT (fun tab j _ => machTok_def P Kr NE net env π (hRT []) (by omega) tab j) (by have := htk 1; omega)

local notation "HX4L8" => hooksRX4L8 P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hlt hT hNE hnet

/-- **The route of a X4L8 prompt** (8 tokens). -/
noncomputable def routeGenX4L8 (hk : π.length = 8) :
    RouteGenGpu P Kr NE net env π T Tk Je chars!"emitted" (ldStT [] []) (ldStT (List.map natV π) (machReads T Tk)) :=
  routeGenOfHooks P G Pg bytes lseSum lseNumerator NE net env leaves typed π T (by omega) (by omega) hlt hT hctx hNE hnet (HX4L8 hk) rfl
    (invsX4L8 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX4L8 hk)).ld
    (invsX4L8 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX4L8 hk)).pc0
    (invsX4L8 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX4L8 hk)).pf
    (invsX4L8 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX4L8 hk)).pc
    (by decide)
    (piecesX4L8 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (by decide) (by decide) (by decide) hk hlt
      (fun t ht => by have := hlt t ht; omega) leaves typed (preS P G Pg bytes lseSum lseNumerator NE net env leaves typed π hlt hNE hnet (by omega) (by omega)) (HX4L8 hk)
      (fun _ _ _ h v m => memX4L80_enter h v m) (fun _ _ _ h m => memX4L80_keep h m))
    (loadVW leaves)

/-- POST's hooks of a X4L9 prompt (9 tokens), at the class's capacity 70039 and the tail's 226858. -/
noncomputable def hooksRX4L9 (hk : π.length = 9) : FillPost.Hooks 15235 T Tk π 226858 19265 (classX4L9 15235 T Tk π 70039 19265 (by decide)) :=
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed (π := π) (by omega) (by omega) hlt hNE hnet
  have htk : ∀ j, Tk j ≤ 248319 := machTok_le P Kr NE net env π (hRT []) (by omega) hlt
  hooksX4L9 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) leaves typed hRT hk (by decide) (by decide)
    (by decide) hT (fun tab j _ => machTok_def P Kr NE net env π (hRT []) (by omega) tab j) (by have := htk 1; omega)

local notation "HX4L9" => hooksRX4L9 P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hlt hT hNE hnet

/-- **The route of a X4L9 prompt** (9 tokens). -/
noncomputable def routeGenX4L9 (hk : π.length = 9) :
    RouteGenGpu P Kr NE net env π T Tk Je chars!"emitted" (ldStT [] []) (ldStT (List.map natV π) (machReads T Tk)) :=
  routeGenOfHooks P G Pg bytes lseSum lseNumerator NE net env leaves typed π T (by omega) (by omega) hlt hT hctx hNE hnet (HX4L9 hk) rfl
    (invsX4L9 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX4L9 hk)).ld
    (invsX4L9 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX4L9 hk)).pc0
    (invsX4L9 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX4L9 hk)).pf
    (invsX4L9 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX4L9 hk)).pc
    (by decide)
    (piecesX4L9 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (by decide) (by decide) (by decide) hk hlt
      (fun t ht => by have := hlt t ht; omega) leaves typed (preS P G Pg bytes lseSum lseNumerator NE net env leaves typed π hlt hNE hnet (by omega) (by omega)) (HX4L9 hk)
      (fun _ _ _ h v m => memX4L90_enter h v m) (fun _ _ _ h m => memX4L90_keep h m))
    (loadVW leaves)

/-- POST's hooks of a X0 prompt (2 tokens), at the class's capacity 70039 and the tail's 217523. -/
noncomputable def hooksRX0 (hk : π.length = 2) : FillPost.Hooks 15235 T Tk π 217523 17764 (classX0 15235 T Tk π 70039 17764 (by decide)) :=
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed (π := π) (by omega) (by omega) hlt hNE hnet
  have htk : ∀ j, Tk j ≤ 248319 := machTok_le P Kr NE net env π (hRT []) (by omega) hlt
  hooksX0 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) leaves typed hRT hk (by decide) (by decide)
    (by decide) hT (fun tab j _ => machTok_def P Kr NE net env π (hRT []) (by omega) tab j) (by have := htk 1; omega)

local notation "HX0" => hooksRX0 P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hlt hT hNE hnet

/-- **The route of a X0 prompt** (2 tokens). -/
noncomputable def routeGenX0 (hk : π.length = 2) :
    RouteGenGpu P Kr NE net env π T Tk Je chars!"emitted" (ldStT [] []) (ldStT (List.map natV π) (machReads T Tk)) :=
  routeGenOfHooks P G Pg bytes lseSum lseNumerator NE net env leaves typed π T (by omega) (by omega) hlt hT hctx hNE hnet (HX0 hk) rfl
    (invsX0 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX0 hk)).ld
    (invsX0 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX0 hk)).pc0
    (invsX0 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX0 hk)).pf
    (invsX0 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (HX0 hk)).pc
    (by decide)
    (piecesX0 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (by decide) (by decide) (by decide) hk hlt
      (fun t ht => by have := hlt t ht; omega) leaves typed (stepS P G Pg bytes lseSum lseNumerator env leaves typed π) (preS P G Pg bytes lseSum lseNumerator NE net env leaves typed π hlt hNE hnet (by omega) (by omega)) (HX0 hk)
      (fun _ _ _ h v m => memX00_enter h v m) (fun _ _ _ h m => memX00_keep h m))
    (loadVW leaves)

end
end Host.Route
