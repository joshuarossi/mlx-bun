import host.sim.template.ok.Ok
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance function of `FINALC0` after the epilogue spread: `ok` with the spread's
new array `3123642` (`FINALC0.aN`) framed as well. -/
noncomputable def FINALC0.okB : St Host.Load.ffi.S → SSrv → Bool := Disp.okJS (loadJSP [2673447, 12502, 3123642])

end Host.Load.Run.Tpl
