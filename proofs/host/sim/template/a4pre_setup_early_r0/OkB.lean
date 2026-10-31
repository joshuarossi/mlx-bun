import host.sim.template.FullOk
import host.sim.full.BackSim
import host.sim.dispatch.OkJs
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance function of `PRE_setup_early_r0`'s first segment (seg.json's frames). -/
noncomputable def PRE_setup_early_r0.okB0 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `PRE_setup_early_r0` after bridge 1 (len at boundary 2). -/
noncomputable def PRE_setup_early_r0.okB1 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `PRE_setup_early_r0` after bridge 2 (stage at boundary 4). -/
noncomputable def PRE_setup_early_r0.okB2 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `PRE_setup_early_r0` after bridge 3 (len at boundary 8). -/
noncomputable def PRE_setup_early_r0.okB3 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `PRE_setup_early_r0` after bridge 4 (len at boundary 11). -/
noncomputable def PRE_setup_early_r0.okB4 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `PRE_setup_early_r0` after bridge 5 (len at boundary 14). -/
noncomputable def PRE_setup_early_r0.okB5 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

end Host.Load.Run.Tpl
