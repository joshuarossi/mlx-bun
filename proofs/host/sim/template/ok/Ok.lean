import host.sim.LoadSim
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-! The acceptance function of the template's checked runs (`runOk`): the dispatcher's
`okJS` with the load world's parameters (`loadJSP`, `host.sim.LoadSim`) and the decode
loop's framed arrays `forwarded`, `emitted`. -/

/-- The acceptance function (noncomputable: it is only evaluated by the kernel). -/
noncomputable def ok : St Host.Load.ffi.S → SSrv → Bool := Disp.okJS (loadJSP [2673447, 12502])

end Host.Load.Run.Tpl
