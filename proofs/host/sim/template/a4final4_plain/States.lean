import host.sim.template.a4dec4_ord.m.B0
import host.sim.template.Split
import host.sim.template.Bridges
import host.sim.template.FullWorld
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
noncomputable def Final4PlainBase.s0 := DEC4_ord.s0
noncomputable def Final4PlainBase.S0 : SSrv := ⟨DEC4_ord.S0.tab, []⟩
def Final4Plain.promptLen : SymE := .bin .sub (.bin .sub (.var 9) (.var 10)) litOne
set_option interpreter.prefer_native true in
tpl_case_split Final4Plain from Final4PlainBase : "FINAL"
  bridging (Bridge.routeBridges { kinds := ["len", "spread"], lens := [(2665, Final4Plain.promptLen)] })
(world := full, spec := "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/specs/final4_plain.json", cap := 2500)
end Host.Load.Run.Tpl
