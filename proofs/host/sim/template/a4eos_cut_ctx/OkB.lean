import host.sim.template.FullOk
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance function of `EOSCutCtxRest`'s first segment (seg.json's frames). -/
noncomputable def EOSCutCtxRest.okB0 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false)

/-- The acceptance function of `EOSCutCtxRest` after bridge 1 (len at boundary 2). -/
noncomputable def EOSCutCtxRest.okB1 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false)

/-- The acceptance function of `EOSCutCtxRest` after bridge 2 (spread at boundary 5). -/
noncomputable def EOSCutCtxRest.okB2 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910, 3123590] [(4910, .memo [])]) (fun _ _ => false)

end Host.Load.Run.Tpl
