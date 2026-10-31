import host.sim.template.FullOk
import host.sim.full.BackSim
import host.sim.dispatch.OkJs
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance function of `PRE_setup_h1_chunk`'s first segment (seg.json's frames). -/
noncomputable def PRE_setup_h1_chunk.okB0 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `PRE_setup_h1_chunk` after bridge 1 (stage at boundary 0). -/
noncomputable def PRE_setup_h1_chunk.okB1 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

end Host.Load.Run.Tpl
