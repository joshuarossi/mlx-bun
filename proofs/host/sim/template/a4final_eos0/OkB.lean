import host.sim.template.FullOk
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance function of `FinalEos0`'s first segment (seg.json's frames). -/
noncomputable def FinalEos0.okB0 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false)

/-- The acceptance function of `FinalEos0` after bridge 1 (len at boundary 2). -/
noncomputable def FinalEos0.okB1 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false)

/-- The acceptance function of `FinalEos0` after bridge 2 (len at boundary 5). -/
noncomputable def FinalEos0.okB2 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false)

/-- The acceptance function of `FinalEos0` after bridge 3 (spread at boundary 8). -/
noncomputable def FinalEos0.okB3 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910, 3123627] [(4910, .memo [])]) (fun _ _ => false)

end Host.Load.Run.Tpl
