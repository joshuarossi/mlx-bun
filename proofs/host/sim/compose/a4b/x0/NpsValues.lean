import host.sim.compose.a4b.x0.NpsMerged
import host.sim.LoopArith
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl

def npsResult : SymE := .bin .add litZero (.bin .sub (.bin .sub (.var 9) litZero) litOne)
kernel_rfl npsResultAt : nth? PRE_first_tail_x0_r0.st1.S2.tab 18 = some npsResult
kernel_rfl npsResults : PRE_first_tail_x0_r0.nr1.map
  (fun r => nth? PRE_first_tail_x0_r0.st1.S2.tab r) = [some npsResult]

theorem npsResultEval {ν : Nat → F64} {L : Nat} (hv : ν 9 = F64.ofNat L)
    (h1 : 1 ≤ L) (hb : L < 2 ^ 53) : npsResult.eval ν = F64.ofNat (L - 1) := by
  have hv' : (SymE.var 9).eval ν = F64.ofNat L := hv
  have hsub := eval_sub hv' (eval_litZero (ν := ν)) hb (Nat.zero_le L)
  simp only [Nat.sub_zero] at hsub
  have he := eval_sub hsub (eval_litOne (ν := ν)) hb h1
  have h := eval_add (eval_litZero (ν := ν)) he (by omega)
  simpa only [npsResult, Nat.zero_add] using h
end Host.Ts.Sim.Compose.VWFirst.X0
