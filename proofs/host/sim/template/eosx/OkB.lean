import host.sim.template.ok.Ok
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance function of `EOSX` after the epilogue spread: `ok` with the spread's
new array `3123589` (`EOSX.aN`) framed as well. -/
noncomputable def EOSX.okB : St Host.Load.ffi.S → SSrv → Bool := Disp.okJS (loadJSP [2673447, 12502, 3123589])

end Host.Load.Run.Tpl
