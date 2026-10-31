import host.sim.template.FullOk
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance function of `DEC_clearGrow`'s first segment (seg.json's frames). -/
noncomputable def DEC_clearGrow.okB0 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false)

/-- The acceptance function of `DEC_clearGrow` after bridge 1 (stage at boundary 0). -/
noncomputable def DEC_clearGrow.okB1 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false)

/-- The acceptance function of `DEC_clearGrow` after bridge 2 (stage at boundary 4). -/
noncomputable def DEC_clearGrow.okB2 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false)

/-- The acceptance function of `DEC_clearGrow` after bridge 3 (stage at boundary 8). -/
noncomputable def DEC_clearGrow.okB3 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false)

end Host.Load.Run.Tpl
