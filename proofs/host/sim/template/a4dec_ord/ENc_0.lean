import host.sim.template.a4dec_ord.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_ord.nobjs : (PTrie.keysA DEC_ord.X0.objs).map (fun h => DEC_ord.X1.objs.get (DEC_ord.σ.handle h)) =
  (PTrie.keysA DEC_ord.X0.objs).map (fun h => (DEC_ord.X0.objs.get h).map DEC_ord.σ.nobj)
kernel_rfl DEC_ord.nobjok : (PTrie.keysA DEC_ord.X0.objs).all (objOK DEC_ord.σ DEC_ord.PE.NL DEC_ord.X0) = true
end Host.Load.Run.Tpl
