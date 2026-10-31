import host.sim.template.FullOk
import host.sim.full.BackSim
import host.sim.dispatch.OkJs
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance function of `PRE_g0b`'s first segment (seg.json's frames). -/
noncomputable def PRE_g0b.okB0 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `PRE_g0b` after bridge 1 (len at boundary 2). -/
noncomputable def PRE_g0b.okB1 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `PRE_g0b` after bridge 2 (len at boundary 5). -/
noncomputable def PRE_g0b.okB2 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `PRE_g0b` after bridge 3 (len at boundary 8). -/
noncomputable def PRE_g0b.okB3 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

end Host.Load.Run.Tpl
