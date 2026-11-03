import host.route.GenOfGpu
import host.route.ColdEntry
import host.route.HandKeep
import host.route.ShortGoals
import host.sim.compose.a4b.FillOne
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Compose Host.Ts.Sim.Template
open Host.Ts.Sim.Compose.Gpu (PiecesR)
open Host.Ts.Sim.Compose.FillPost (ClassPre Hooks memP invs pieces popsOne pA pB2 pB0 pC1 pC0 sA sB2 sC1)
open Host.Load.Run.Prompt
open Host.Load.Run.Tpl (wideG)
open Host.Route.PrefGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # The route from a class's prefill

`routeGenOfHooks`: `routeGenOfGpu` once a class has POST's hooks, its prefill's pieces and its load entry. The paths, their goals, POST's pieces and
the handoff to the decode loop are the classes' common stretch. -/

section
variable {C : M1Max.Contract}
  (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
  (bytes : KernelGpu.SetBytes) (lseSum : Bool)
  (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
  (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
  (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
  (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hL : π.length ≤ 224)
  (hlt : ∀ t ∈ π, t < 248320) (hT : 1 ≤ T) (hctx : π.length + T ≤ 262144)
  (hNE : NE.Succeeds net)
  (hnet : ∀ tab, Host.Mlx.SimGraph.Mach.AneNetOk net
    (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))

local notation "Kr" => routeKernel G bytes Pg lseSum lseNumerator
local notation "Tk" => machTok P Kr NE net env π
local notation "Je" => entryEnv (Host.Load.Run.Prompt.P.at0 (π.map natV) (machReads T Tk))

variable {cap nI capC nIC : Nat}

include hπ hL in
/-- POST's end, into the decode loop's first iteration. -/
theorem handoffOf {Pc : ClassPre 15235 T Tk π capC nIC} (H : Hooks 15235 T Tk π cap nI Pc)
    (hMem : H.MemP = memP P Kr NE net env π T Tk)
    (ld pc0 pf : Nat → ICut FF) (pc : Nat → Nat → ICut FF) (hcapB : cap ≤ routeLoopBaseGpu.D) (t : St FF.S) (Cs : CSrv)
    (h : ((invs H ld pc0 pf pc).dec π.length).Inv t Cs) :
    ∃ kind, (decCutFirstFb 15235 addrPrompt (machGxV P Kr NE net env π kind 15235 Host.Route.Cert.Dec.inputs) wideG
      Host.Route.Cert.Dec.Pw (framesG Host.Route.Cert.Dec.s0 (π.map natV)) Host.Route.Cert.Dec.s0 Host.Route.Cert.Dec.tab0 shortFixP
      (valL (handRho T π.length Tk) T Tk π.length) Tk (.ref 2 :: machReads T Tk) [.num (.ref 1)] routeLoopBaseGpu).Inv t Cs := by
  obtain ⟨x, rfl, rfl, hx, hb, hm⟩ := h
  rw [hMem] at hm
  exact hand_dec (by decide) hπ hL (hand_read _) (hand_fed _) (hand_caches _) hcapB (by decide) (by decide) hx hb hm.2.2 hm.2.1 hm.1

/-- **A class's route.** -/
noncomputable def routeGenOfHooks {Pc : ClassPre 15235 T Tk π capC nIC} (H : Hooks 15235 T Tk π cap nI Pc)
    (hMem : H.MemP = memP P Kr NE net env π T Tk)
    (ld pc0 pf : Nat → ICut FF) (pc : Nat → Nat → ICut FF) (hcap : cap ≤ 4096 + 1593835520)
    (Pp : PiecesR FF (invs H ld pc0 pf pc))
    (loadEntry : CutConv (ldPromptCutAt 15235 setupP wideP (ldStT [] []) T Tk π (ldStT (π.map natV) (machReads T Tk))) (ld π.length)) :
    RouteGenGpu P Kr NE net env π T Tk Je chars!"emitted" (ldStT [] []) (ldStT (π.map natV) (machReads T Tk)) :=
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed hπ (by omega) hlt hNE hnet
  have htk : ∀ j, Tk j ≤ 248319 := machTok_le P Kr NE net env π (hRT []) hπ hlt
  have hTle : T ≤ 262143 := by omega
  have Q := popsOne (P' := P) (KR := Kr) (NE := NE) (net := net) (env := env) H hMem hT
    (fun tab j _ => machTok_def P Kr NE net env π (hRT []) hπ tab j)
    (by have := htk 1; omega) (by have := htk 2; omega)
  have hP : ∀ j L x, H.MemP j L x → memPost P Kr NE net env π j Cert.Row.rowToks (Cert.Row.rowCr j) L x :=
    fun j L x h => by
      rw [hMem] at h
      exact h.1
  routeGenOfGpu P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hπ hL hlt hctx hNE hnet
    (invs H ld pc0 pf pc) Pp loadEntry (pieces (hcap := hcap) (hL1 := hπ) (hL2 := hL) (H := H) ld pc0 pf pc)
    (fun h he => pA H hcap hπ hL hTle Q h he)
    (fun h hne he => pB2 H hcap hπ hL htk Q h hne he)
    (fun h hne hne2 => pB0 (H := H) (hcap := hcap) (hL1 := hπ) (hL2 := hL) (htk := htk) (Q := Q) (h := h) (hne := hne) (hne2 := hne2))
    (fun h he => pC1 H hcap Q h he)
    (fun h hne => pC0 (H := H) (hcap := hcap) (htk := htk) (Q := Q) (h := h) (hne := hne))
    (fun h he => sA (H := H) (hcap := hcap) (hL1 := hπ) (hL2 := hL) (htk := htk) (hTle := hTle) (Q := Q) h he)
    (fun h hne he => sB2 (H := H) (hcap := hcap) (hL1 := hπ) (hL2 := hL) (htk := htk) (Q := Q) h hne he)
    (fun h he => sC1 (H := H) (hcap := hcap) (hL1 := hπ) (hL2 := hL) (htk := htk) (Q := Q) h he)
    (handoffOf P G Pg bytes lseSum lseNumerator NE net env π T hπ hL H hMem ld pc0 pf pc (by unfold routeLoopBaseGpu; dsimp only; omega))
    (fun h he => Cert.Row.graphA (H := H) (hMem := hP) (hcap := hcap) (hL1 := hπ) (hL2 := hL) (hTle := hTle) (Q := Q) h he)
    (fun h hne he => Cert.Row.graphB2 (H := H) (hMem := hP) (hcap := hcap) (hL1 := hπ) (hL2 := hL) (htk := htk) (Q := Q) h hne he)
    (fun h hne hne2 => Cert.Row.graphB0 (H := H) (hMem := hP) (hcap := hcap) (hL1 := hπ) (hL2 := hL) (htk := htk) (Q := Q) _ (saved_cache _ _) h hne hne2)
    (fun h he => Cert.Row.graphC1 (H := H) (hMem := hP) (hcap := hcap) (Q := Q) h he)
    (fun h hne => Cert.Row.graphC0 (H := H) (hMem := hP) (hcap := hcap) (hL1 := hπ) (htk := htk) (Q := Q) _ (saved_cache _ _) h hne)

end
end Host.Route
