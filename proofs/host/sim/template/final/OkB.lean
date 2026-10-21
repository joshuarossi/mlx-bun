import host.sim.template.ok.Ok
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance function of `FINAL` after the epilogue spread: `ok` with the spread's
new array `3123641` (`FINAL.aN`) framed as well. -/
noncomputable def FINAL.okB : St Host.Load.ffi.S → SSrv → Bool := Disp.okJS (loadJSP [2673447, 12502, 3123641])

end Host.Load.Run.Tpl
