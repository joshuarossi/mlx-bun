import host.sim.template.a4dec_clear.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_clear.nobjs : (PTrie.keysA DEC_clear.X0.objs).map (fun h => DEC_clear.X1.objs.get (DEC_clear.σ.handle h)) =
  (PTrie.keysA DEC_clear.X0.objs).map (fun h => (DEC_clear.X0.objs.get h).map DEC_clear.σ.nobj)
kernel_rfl DEC_clear.nobjok : (PTrie.keysA DEC_clear.X0.objs).all (objOK DEC_clear.σ DEC_clear.PE.NL DEC_clear.X0) = true
end Host.Load.Run.Tpl
