import host.sim.template.a4dec4_ord.m.B0
import host.sim.template.Split
import host.sim.template.Bridges
import host.sim.template.FullWorld
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
noncomputable def Final4Eos0Base.s0 := DEC4_ord.s0
noncomputable def Final4Eos0Base.S0 : SSrv := ⟨DEC4_ord.S0.tab, []⟩
def Final4Eos0.promptLen : SymE := .bin .sub (.bin .sub (.var 9) (.var 10)) litOne
set_option interpreter.prefer_native true in
tpl_case_split Final4Eos0 from Final4Eos0Base : "FINALE"
  bridging (Bridge.routeBridges { kinds := ["len", "spread"], lens := [(2665, Final4Eos0.promptLen)] })
(world := full, spec := "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/specs/final4_eos0.json", cap := 2500)
end Host.Load.Run.Tpl
