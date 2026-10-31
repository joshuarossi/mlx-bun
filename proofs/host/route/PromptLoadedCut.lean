import host.route.Gen
import host.route.LoadedCut
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Route.LoadedCut
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim.Full (fullWorld mlxOf)
open Host.Load.Run.Prompt (ldStT Ld.rel_full)

theorem ldPromptCut_inv (NB : Nat) (Pw : Sim.LoadP) (hPw : LdParams Pw NB) (W : Nat → Option Host.Ts.Sim.WFrame)
    (hW : W 2665 = none)
    (π : List Nat) (hlt : ∀ t ∈ π, t < 248320) (T : Nat) (tk : Nat → Nat) (hT : T ≤ 2 ^ 20)
    (htk : ∀ j, tk j ≤ 2 ^ 20) :
    (ldPromptCut NB Pw W (ldStT [] []) T tk π).Inv (ldStT (π.map natV) (machReads T tk)) (routeServer T tk) := by
  obtain ⟨hlo, hE, hN, hNE, hNB⟩ := hPw
  have h := Ld.rel_full Pw NB hlo hE hN hNE hNB (machVal T tk) Pw.lo Pw.E (by omega) (π.map natV) (machReads T tk)
  rw [server_eq] at h
  have hw : ∀ a, W a ≠ none →
      (Host.Load.Run.Prompt.FrameRel.ctx (ldStT [] []) 2665 (π.map natV) Pw.lo Pw.E).fr a = none := by
    intro a ha
    rw [Host.Load.Run.Prompt.FrameRel.ctx_fr]
    have : a ≠ 2665 := fun e => ha (e ▸ hW)
    simp [this]
  have hv : Host.Ts.Sim.Full.VBOkF Sim.loopVB (machVal T tk) := fun v => by
    unfold machVal
    by_cases h0 : v = 0
    · exact ⟨T, hT, by simp [h0]⟩
    · exact ⟨tk v, htk v, by simp [h0]⟩
  exact ldPromptCut_of_rel (RelB.widen h hw) hv hlt
    (fun _ Pc Kc weights kind NE IP G init => bridge_final Pc Kc weights kind NE IP G init _ _)

/-- Only the existing boot run remains external to the checked prompt-entry proof. -/
theorem boot_entry {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C}
    {NE : NeuralEngine} {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey}
    {π : List Nat} {T : Nat} {tk : Nat → Nat} {je : Host.Ts.Env} {nm : Host.Ts.Name}
    {N : Nat} {t0 : St Host.Ts.Sim.Full.FF.S}
    (Gn : RouteGen P KR NE net env π T tk je nm (ldStT [] []))
    (hlt : ∀ t ∈ π, t < 248320) (hT : T ≤ 2 ^ 20) (htk : ∀ j, tk j ≤ 2 ^ 20)
    (hrun : runC (fullWorld Gn.NB).F N t0 (routeServer T tk) =
      some (ldStT (π.map natV) (machReads T tk), routeServer T tk)) :
    ∃ N0 tL CL, runC (fullWorld Gn.NB).F N0 t0 (routeServer T tk) = some (tL, CL) ∧
      (Gn.I.ld π.length).Inv tL CL :=
  ⟨N, _, _, hrun, Gn.loadEntry_inv (ldPromptCut_inv Gn.NB Gn.Pw Gn.hPw Gn.W Gn.hW π hlt T tk hT htk)⟩

end Host.Route.LoadedCut
