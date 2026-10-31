import host.route.LoadCut
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill

/-- The load cut for the route's actual prompt, over the unchanged generic load cut. -/
def ldPromptCut (NB : Nat) (Pw : LoadP) (W : Nat → Option WFrame) (s0 : St FF.S)
    (T : Nat) (tk : Nat → Nat) (π : List Nat) : ICut FF :=
  { ldCut NB Pw W s0 T tk π.length with
    B := fun x => (ldCut NB Pw W s0 T tk π.length).B x ∧
      x.K.fr 2665 = some ([], π.map natV) }

theorem ldPromptCut_forget (NB : Nat) (Pw : LoadP) (W : Nat → Option WFrame) (s0 : St FF.S)
    (T : Nat) (tk : Nat → Nat) (π : List Nat) :
    CutConv (ldPromptCut NB Pw W s0 T tk π) (ldCut NB Pw W s0 T tk π.length) :=
  fun x hr hb => ⟨x, rfl, rfl, hr, hb.1⟩

theorem ldPromptCut_frame {NB : Nat} {Pw : LoadP} {W : Nat → Option WFrame} {s0 : St FF.S}
    {T : Nat} {tk : Nat → Nat} {π : List Nat} {x : SegInst FF}
    (hb : (ldPromptCut NB Pw W s0 T tk π).B x) :
    x.K.fr 2665 = some ([], π.map natV) := hb.2

/-- The boot's concrete relation already supplies the prompt refinement. -/
theorem ldPromptCut_of_rel {NB : Nat} {Pw : LoadP} {W : Nat → Option WFrame} {s0 t : St FF.S}
    {T : Nat} {tk : Nat → Nat} {π : List Nat} {C : CSrv}
    (hr : RelF FF (FLR Pw NB (machReads T tk)) W Map.id (machVal T tk)
      (Host.Load.Run.Prompt.FrameRel.ctx s0 2665 (π.map natV) Pw.lo Pw.E)
      s0 ⟨Host.Load.Decode.tab, []⟩ t C)
    (hv : VBOkF loopVB (machVal T tk)) (hlt : ∀ k ∈ π, k < 248320) (hf : AneFresh t) :
    (ldPromptCut NB Pw W s0 T tk π).Inv t C := by
  refine ⟨⟨Map.id, machVal T tk,
    Host.Load.Run.Prompt.FrameRel.ctx s0 2665 (π.map natV) Pw.lo Pw.E, t, C⟩,
    rfl, rfl, hr, ⟨rfl, rfl, hv, ⟨π, rfl, hlt, rfl⟩, hf⟩, ?_⟩
  rw [Host.Load.Run.Prompt.FrameRel.ctx_fr]
  rfl

end Host.Route
