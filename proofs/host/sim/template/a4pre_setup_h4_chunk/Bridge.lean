import host.sim.template.a4pre_setup_h4_chunk.H0
import host.sim.template.Bridges
import host.sim.LoopFinal
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The bridge points of `PRE_setup_h4_chunk` (seg.json): at each bridge state, the facts its bridge lemma needs. -/

kernel_rfl PRE_setup_h4_chunk.callA1 : Host.Ts.Sim.Template.isCallOf PRE_setup_h4_chunk.s0 "chunkSize" none = true
end Host.Load.Run.Tpl
