import host.sim.template.FullOk
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance function of `EOSCut`'s first segment (seg.json's frames). -/
noncomputable def EOSCut.okB0 : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false)

/-- The acceptance function of `EOSCut` after the epilogue spread: `ok` with the spread's
new array `3123590` (`EOSCut.aN`) framed as well. -/
noncomputable def EOSCut.okB : St Host.Load.Layers.full.S → SSrv → Bool := Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910, 3123590] [(4910, .memo [])]) (fun _ _ => false)

end Host.Load.Run.Tpl
