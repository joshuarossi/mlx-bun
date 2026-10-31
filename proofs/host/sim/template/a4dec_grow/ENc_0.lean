import host.sim.template.a4dec_grow.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_grow.nobjs : (PTrie.keysA DEC_grow.X0.objs).map (fun h => DEC_grow.X1.objs.get (DEC_grow.σ.handle h)) =
  (PTrie.keysA DEC_grow.X0.objs).map (fun h => (DEC_grow.X0.objs.get h).map DEC_grow.σ.nobj)
kernel_rfl DEC_grow.nobjok : (PTrie.keysA DEC_grow.X0.objs).all (objOK DEC_grow.σ DEC_grow.PE.NL DEC_grow.X0) = true
end Host.Load.Run.Tpl
