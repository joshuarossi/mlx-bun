import host.sim.template.FullOk
import host.sim.full.BackSim
import host.sim.dispatch.OkJs
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance function of `D1StageSplit`'s first segment (seg.json's frames). -/
noncomputable def D1StageSplit.okB0 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `D1StageSplit` after bridge 1 (stage at boundary 0). -/
noncomputable def D1StageSplit.okB1 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `D1StageSplit` after bridge 2 (slice at boundary 3). -/
noncomputable def D1StageSplit.okB2 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665, 2673479] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `D1StageSplit` after bridge 3 (len at boundary 6). -/
noncomputable def D1StageSplit.okB3 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665, 2673479] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `D1StageSplit` after bridge 4 (typed at boundary 9). -/
noncomputable def D1StageSplit.okB4 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665, 2673479, 2673484, 2673485] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `D1StageSplit` after bridge 5 (ptr at boundary 12). -/
noncomputable def D1StageSplit.okB5 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665, 2673479, 2673484, 2673485] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `D1StageSplit` after bridge 6 (newdata at boundary 15). -/
noncomputable def D1StageSplit.okB6 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665, 2673479, 2673484, 2673485] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `D1StageSplit` after bridge 7 (len at boundary 18). -/
noncomputable def D1StageSplit.okB7 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665, 2673479, 2673484, 2673485] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

/-- The acceptance function of `D1StageSplit` after bridge 8 (stage at boundary 20). -/
noncomputable def D1StageSplit.okB8 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665, 2673479, 2673484, 2673485] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096

end Host.Load.Run.Tpl
