import host.sim.template.FullOk
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance function of `FinalPlain`'s first segment (seg.json's frames). -/
noncomputable def FinalPlain.okB0 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false)

/-- The acceptance function of `FinalPlain` after bridge 1 (len at boundary 2). -/
noncomputable def FinalPlain.okB1 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false)

/-- The acceptance function of `FinalPlain` after bridge 2 (len at boundary 5). -/
noncomputable def FinalPlain.okB2 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false)

/-- The acceptance function of `FinalPlain` after bridge 3 (spread at boundary 8). -/
noncomputable def FinalPlain.okB3 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910, 3123642] [(4910, .memo [])]) (fun _ _ => false)

end Host.Load.Run.Tpl
