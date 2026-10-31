import host.sim.template.a4dec_clearGrow.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_clearGrow.nobjs : (PTrie.keysA DEC_clearGrow.X0.objs).map (fun h => DEC_clearGrow.X1.objs.get (DEC_clearGrow.σ.handle h)) =
  (PTrie.keysA DEC_clearGrow.X0.objs).map (fun h => (DEC_clearGrow.X0.objs.get h).map DEC_clearGrow.σ.nobj)
kernel_rfl DEC_clearGrow.nobjok : (PTrie.keysA DEC_clearGrow.X0.objs).all (objOK DEC_clearGrow.σ DEC_clearGrow.PE.NL DEC_clearGrow.X0) = true
end Host.Load.Run.Tpl
