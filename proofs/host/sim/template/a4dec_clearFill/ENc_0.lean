import host.sim.template.a4dec_clearFill.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_clearFill.nobjs : (PTrie.keysA DEC_clearFill.X0.objs).map (fun h => DEC_clearFill.X1.objs.get (DEC_clearFill.σ.handle h)) =
  (PTrie.keysA DEC_clearFill.X0.objs).map (fun h => (DEC_clearFill.X0.objs.get h).map DEC_clearFill.σ.nobj)
kernel_rfl DEC_clearFill.nobjok : (PTrie.keysA DEC_clearFill.X0.objs).all (objOK DEC_clearFill.σ DEC_clearFill.PE.NL DEC_clearFill.X0) = true
end Host.Load.Run.Tpl
