import host.load.boot.Boot
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Load

/-! `P.absRun : ∀ fw, runS P.F 28172201 (P.a0 fw) P.S0 = some (P.a2818 fw, P.S2818)`: the boot's check in
the observer world over every unread readback suffix (`host/load/boot`, `P.obRun`), at the original
world's suffix (`P.tokenBase`), with the observer dropped (`Boot.w_proj_runS`). -/

set_option maxRecDepth 1000000 in
theorem P.absRun (fw : List Val) : runS P.F 28172201 (P.a0 fw) P.S0 = some (P.a2818 fw, P.S2818) := by
  rw [← P.at0_base fw, ← P.at2818_base fw]
  exact Host.Load.Boot.w_proj_runS 28172201 (P.at0 fw P.tokenBase) P.ob0 P.S0 (P.at2818 fw P.tokenBase) P.ob2818
    P.S2818 (P.obRun fw P.tokenBase)

end Host.Load.Run.Prompt
