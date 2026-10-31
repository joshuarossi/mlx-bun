import host.sim.template.FullOk
import host.sim.full.BackSim
import host.sim.dispatch.OkJs
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance function of `PRE_first_tail_x15_r0_suffix`'s first segment (seg.json's frames). -/
noncomputable def PRE_first_tail_x15_r0_suffix.okB0 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665, 2673467, 2673472, 2673473] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `PRE_first_tail_x15_r0_suffix` after bridge 1 (stage at boundary 2). -/
noncomputable def PRE_first_tail_x15_r0_suffix.okB1 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665, 2673467, 2673472, 2673473] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `PRE_first_tail_x15_r0_suffix` after bridge 2 (len at boundary 6). -/
noncomputable def PRE_first_tail_x15_r0_suffix.okB2 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665, 2673467, 2673472, 2673473] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

end Host.Load.Run.Tpl
