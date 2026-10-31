import host.route.LoadCut
import host.load.boot.ld.Full
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Route.LoadedCut
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim.Full (fullWorld mlxOf)
open Host.Load.Run.Prompt (ldStT Ld.rel_full)

kernel_rfl server_tab : Host.Load.Run.Prompt.P.S2818.tab = Host.Load.Decode.tab

theorem server_eq : Host.Load.Run.Prompt.P.S2818 = ⟨Host.Load.Decode.tab, []⟩ := by
  rw [← server_tab, ← Host.Load.Run.Prompt.Ld.S2818_oracle]

theorem allocAll_log : ∀ (b : FfiAne.St) (ns : List Nat), (FfiAne.allocAll b ns).2.log = b.log
  | _, [] => rfl
  | _, _ :: ns => allocAll_log _ ns

theorem cond_log {b x y : FfiAne.St} (c : Bool) (hx : x.log = b.log) (hy : y.log = b.log) :
    (bif c then x else y).log = b.log := by
  cases c <;> assumption

theorem create_log (b : FfiAne.St) (n : Nat) (args : List Host.Ts.Arg) (share : Option Nat) :
    (FfiAne.create b n args share).log = b.log := by
  unfold FfiAne.create
  split
  · rfl
  · split
    · simp only [FfiAne.addProgram, FfiAne.alloc, allocAll_log]
    · split
      · rfl
      · split
        · rfl
        · exact cond_log _ rfl (cond_log _ rfl rfl)

theorem replay_log : ∀ log : Host.Load.Boot.BLog, (Host.Load.Boot.replay log).log = []
  | [] => rfl
  | (_, _, _) :: r => (create_log _ _ _ _).trans (replay_log r)

theorem bridge_final {C : M1Max.Contract} (Pm : MlxPrefillContract C)
    (K : RouteKernelContract C) (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled)
    (NE : NeuralEngine) (IP : FfiAneEval.InPlace) (G : FfiAneEval.Graph) (init : Nat → Surface)
    (fw : List Val) (τ : List NumV) :
    FfiAneEval.final Pm K weights kind NE IP G init (Host.Ts.Sim.Full.bridgeOf (ldStT fw τ).ffi) =
      some ⟨init, fun _ => none, fun _ => none⟩ := by
  show FfiAneEval.final Pm K weights kind NE IP G init (ldStT fw τ).ffi.1.1.bridge = _
  rw [Host.Load.Run.Prompt.ldStT_layers]
  unfold FfiAneEval.final
  rw [replay_log]
  rfl

theorem ldCut_inv (NB : Nat) (Pw : Sim.LoadP) (hPw : LdParams Pw NB) (W : Nat → Option Host.Ts.Sim.WFrame)
    (hW : W 2665 = none)
    (π : List Nat) (hlt : ∀ t ∈ π, t < 248320) (T : Nat) (tk : Nat → Nat) (hT : T ≤ 2 ^ 20)
    (htk : ∀ j, tk j ≤ 2 ^ 20) :
    (ldCut NB Pw W (ldStT [] []) T tk π.length).Inv (ldStT (π.map natV) (machReads T tk)) (routeServer T tk) := by
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
  exact ⟨⟨Sim.Map.id, machVal T tk, Host.Load.Run.Prompt.FrameRel.ctx (ldStT [] []) 2665 (π.map natV) Pw.lo Pw.E,
      ldStT (π.map natV) (machReads T tk), routeServer T tk⟩, rfl, rfl, RelB.widen h hw, rfl, rfl, hv,
    ⟨π, rfl, hlt, rfl⟩,
    fun _ Pc Kc weights kind NE IP G init => bridge_final Pc Kc weights kind NE IP G init _ _⟩

end Host.Route.LoadedCut
