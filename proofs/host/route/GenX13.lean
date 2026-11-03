import host.route.GenOfHooks
import host.route.cert.Fin.Caps
import host.sim.compose.a4b.FillX13P
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Compose Host.Ts.Sim.Template
open Host.Ts.Sim.Compose.FillPost (classVW hooksVW invsX1 invsX2 invsX3 piecesX1 piecesX2 piecesX3 loadVW memVW0_enter memVW0_keep)
open Host.Load.Run.Prompt
open Host.Route.PrefGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # The route of an x1, x2 or x3 prompt: 3 to 6 tokens -/

section
variable {C : M1Max.Contract}
  (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
  (bytes : KernelGpu.SetBytes) (lseSum : Bool)
  (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
  (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
  (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
  (π : List Nat) (T : Nat) (hL3 : 3 ≤ π.length) (hL6 : π.length ≤ 6)
  (hlt : ∀ t ∈ π, t < 248320) (hT : 1 ≤ T) (hctx : π.length + T ≤ 262144)
  (hNE : NE.Succeeds net)
  (hnet : ∀ tab, Host.Mlx.SimGraph.Mach.AneNetOk net
    (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))

local notation "Kr" => routeKernel G bytes Pg lseSum lseNumerator
local notation "Tk" => machTok P Kr NE net env π
local notation "Je" => entryEnv (Host.Load.Run.Prompt.P.at0 (List.map natV π) (machReads T Tk))

/-- POST's hooks of a prompt of 3 to 6 tokens, at the class's capacity 70039 and the tail's 216028. -/
noncomputable def hooksRX : FillPost.Hooks 15235 T Tk π 216028 19057 (classVW 15235 T Tk π 70039 19057 (by decide)) :=
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed (π := π) (by omega) (by omega) hlt hNE hnet
  have htk : ∀ j, Tk j ≤ 248319 := machTok_le P Kr NE net env π (hRT []) (by omega) hlt
  hooksVW (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) leaves typed hRT hL3 (by omega) (by decide) (by decide)
    (by decide) hT (fun tab j _ => machTok_def P Kr NE net env π (hRT []) (by omega) tab j) (by have := htk 1; omega)

include hL3 hL6 hlt hNE hnet in
theorem preX : ∀ tab, ∃ s, Host.Mlx.SimGraph.Ref.prefillAt P Kr NE Kr.inPlace net env π tab = some s ∧
    List.Forall₂ (Host.Mlx.SimGraph.Mach.StagePre (π.length - 1))
      (stageWeights (weights (firstValues P.toMlxContract Kr.toKernelContract env tab))) s.hs := fun tab =>
  Host.Route.Cert.Fin.prefill_pre P Kr NE Kr.inPlace net env π Pg rfl leaves typed (by omega) (by omega)
    (Host.Mlx.SimGraph.Mach.scheduleTyped P Kr NE net env π leaves typed (by omega) hlt hNE hnet) tab

local notation "H" => hooksRX P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hL3 hL6 hlt hT hNE hnet

/-- **The route of an x1 prompt** (3 or 4 tokens). -/
noncomputable def routeGenX1 (hL4 : π.length ≤ 4) :
    RouteGenGpu P Kr NE net env π T Tk Je chars!"emitted" (ldStT [] []) (ldStT (List.map natV π) (machReads T Tk)) :=
  routeGenOfHooks P G Pg bytes lseSum lseNumerator NE net env leaves typed π T (by omega) (by omega) hlt hT hctx hNE hnet H rfl
    (invsX1 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) H).ld
    (invsX1 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) H).pc0
    (invsX1 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) H).pf
    (invsX1 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) H).pc
    (by decide)
    (piecesX1 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (by decide) (by decide) (by decide) hL3 hL4 hlt
      (fun t ht => by have := hlt t ht; omega) leaves typed (preX P G Pg bytes lseSum lseNumerator NE net env leaves typed π hL3 hL6 hlt hNE hnet) H
      (fun _ _ _ h v m => memVW0_enter h v m) (fun _ _ _ h m => memVW0_keep h m))
    (loadVW leaves)

/-- **The route of an x2 prompt** (5 tokens). -/
noncomputable def routeGenX2 (h5 : π.length = 5) :
    RouteGenGpu P Kr NE net env π T Tk Je chars!"emitted" (ldStT [] []) (ldStT (List.map natV π) (machReads T Tk)) :=
  routeGenOfHooks P G Pg bytes lseSum lseNumerator NE net env leaves typed π T (by omega) (by omega) hlt hT hctx hNE hnet H rfl
    (invsX2 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) H).ld
    (invsX2 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) H).pc0
    (invsX2 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) H).pf
    (invsX2 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) H).pc
    (by decide)
    (piecesX2 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (by decide) (by decide) (by decide) (by omega) (by omega) hlt
      (fun t ht => by have := hlt t ht; omega) leaves typed (preX P G Pg bytes lseSum lseNumerator NE net env leaves typed π hL3 hL6 hlt hNE hnet) H
      (fun _ _ _ h v m => memVW0_enter h v m) (fun _ _ _ h m => memVW0_keep h m))
    (loadVW leaves)

/-- **The route of an x3 prompt** (6 tokens). -/
noncomputable def routeGenX3 (h6 : π.length = 6) :
    RouteGenGpu P Kr NE net env π T Tk Je chars!"emitted" (ldStT [] []) (ldStT (List.map natV π) (machReads T Tk)) :=
  routeGenOfHooks P G Pg bytes lseSum lseNumerator NE net env leaves typed π T (by omega) (by omega) hlt hT hctx hNE hnet H rfl
    (invsX3 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) H).ld
    (invsX3 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) H).pc0
    (invsX3 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) H).pf
    (invsX3 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) H).pc
    (by decide)
    (piecesX3 (P := P) (KR := Kr) (NE := NE) (net := net) (env := env) (by decide) (by decide) (by decide) (by omega) (by omega) hlt
      (fun t ht => by have := hlt t ht; omega) leaves typed (preX P G Pg bytes lseSum lseNumerator NE net env leaves typed π hL3 hL6 hlt hNE hnet) H
      (fun _ _ _ h v m => memVW0_enter h v m) (fun _ _ _ h m => memVW0_keep h m))
    (loadVW leaves)

end
end Host.Route
