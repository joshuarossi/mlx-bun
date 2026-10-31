import host.route.Final
import host.load.run.prompt.FrameRel
import host.route.Entry
set_option maxRecDepth 1000000
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim (WFrame)
open Host.Ts.Sim.Full (FF FLR fullWorldXD mlxOf bridgeOf)

/-! ## The prefill's loadDone cut -/

/-- **The Neural Engine memory before any forward**: from any loaded surfaces, the target's bridge log runs to
those surfaces with no fixed value and nothing pending. -/
def AneFresh (t : St FF.S) : Prop :=
  ∀ (C' : M1Max.Contract) (Pc : MlxPrefillContract C') (Kc : RouteKernelContract C')
    (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled) (NE : NeuralEngine)
    (IP : FfiAneEval.InPlace) (G : FfiAneEval.Graph) (init : Nat → Surface),
    FfiAneEval.final Pc Kc weights kind NE IP G init (bridgeOf t.ffi) = some ⟨init, fun _ => none, fun _ => none⟩

/-- **Wide frames where the context frames nothing** cost nothing: at an unframed address `SlotW` is the image
whatever `W`, so the relation without frames is the one under `W` when `W`'s frames lie outside `K.fr`'s
domain. -/
theorem RelB.widen {F : Host.Ts.Ffi} {FR : Host.Ts.Sim.Map → Nat → F.S → F.S → Prop} {stk : List Host.Ts.Frame}
    {M : Host.Ts.Sim.Map} {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {s t : St F.S} {S : Host.Ts.SSrv} {C : Host.Ts.CSrv}
    {W : Nat → Option WFrame}
    (h : Host.Ts.Sim.RelB F FR Host.Ts.Sim.noFrames stk M ν K s S t C) (hW : ∀ a, W a ≠ none → K.fr a = none) :
    Host.Ts.Sim.RelB F FR W stk M ν K s S t C :=
  { h with
    heap := fun a x hg => by
      have hs := h.heap a x hg
      cases hfr : K.fr a with
      | none => exact (Host.Ts.Sim.SlotW.of_fr_none hfr).2 ((Host.Ts.Sim.SlotW.of_fr_none hfr).1 hs)
      | some p =>
        have hw : W a = none := by
          by_contra hne
          have := hW a hne
          rw [hfr] at this
          cases this
        exact (Host.Ts.Sim.SlotW.of_w_none hw).2
          ((Host.Ts.Sim.SlotW.of_w_none (W := Host.Ts.Sim.noFrames) rfl).1 hs) }

/-- The load parameters at which the boot's relation at loadDone holds (`Ld.rel_full`'s side conditions). -/
def LdParams (Pw : Sim.LoadP) (NB : Nat) : Prop :=
  (0 < Pw.lo ∧ Pw.lo ≤ 18151) ∧ (18151 ≤ Pw.E ∧ Pw.E < 2 ^ 46) ∧ (Pw.NL = 15235 ∧ Pw.N0 = 15235) ∧
    (15235 ≤ Pw.NE ∧ Pw.NE < 2 ^ 61) ∧ NB ≤ Pw.NL

/-- **The prefill's loadDone cut** at prompt length `L`: the boot's template state `s0` at loadDone with the
load's table, related to the target by the full world's relation under the route's frames `W` at the remaining
readbacks `machReads T tk`, under the identity map and the route's valuation `machVal T tk` (every template
variable a natural below `2 ^ 20`), the prompt array (2665) framed with a prompt of length `L` below the
vocabulary (`FrameRel.ctx`, the band `[Pw.lo, Pw.E)`), the Neural Engine memory before any forward. -/
def ldCut (NB : Nat) (Pw : Sim.LoadP) (W : Nat → Option WFrame) (s0 : St FF.S) (T : Nat) (tk : Nat → Nat)
    (L : Nat) : Host.Ts.Sim.Prefill.ICut (fullWorldXD NB).F where
  s0 := s0
  tab0 := Decode.tab
  R := fun x s S => Sim.RelF FF (FLR Pw NB (machReads T tk)) W x.M x.ν x.K s S x.t x.C
  B := fun x => x.M = Sim.Map.id ∧ x.ν = machVal T tk ∧ Host.Ts.Sim.Full.VBOkF Sim.loopVB x.ν ∧
    (∃ π' : List Nat, π'.length = L ∧ (∀ t ∈ π', t < 248320) ∧
      x.K = Host.Load.Run.Prompt.FrameRel.ctx s0 2665 (π'.map natV) Pw.lo Pw.E) ∧ AneFresh x.t

/-- The inactive load cut enters the prefill relation without changing the state or context. -/
theorem ldCut_prefillR {NB : Nat} {Pw : Sim.LoadP} {W : Nat → Option WFrame} {s0 : St FF.S}
    {T L : Nat} {tk : Nat → Nat} {x : Sim.SegInst FF}
    (h : (ldCut NB Pw W s0 T tk L).R x s0 ⟨Decode.tab, []⟩) :
    Sim.RelF FF (Host.Ts.Sim.Full.FullRXD { Pw with rest := machReads T tk } NB) W
      x.M x.ν x.K s0 ⟨Decode.tab, []⟩ x.t x.C :=
  { h with ffi := h.ffi.toXD }

/-- The prompt length occupies the first fresh variable, leaving all nine loaded inputs intact. -/
theorem ldCut_rowR {NB : Nat} {Pw : Sim.LoadP} {W : Nat → Option WFrame} {s0 : St FF.S}
    {T L : Nat} {tk : Nat → Nat} {x : Sim.SegInst FF}
    (h : (ldCut NB Pw W s0 T tk L).R x s0 ⟨Decode.tab, []⟩) :
    Sim.RelF FF (Host.Ts.Sim.Full.FullRXD { Pw with rest := machReads T tk } NB) W
      x.M (rowVal x.ν L) x.K s0 ⟨Decode.tab, []⟩ x.t x.C :=
  revalueRow (ldCut_prefillR h) L

end Host.Route
