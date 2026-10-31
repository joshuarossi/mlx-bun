import host.sim.template.a4dec_fill.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_fill.nobjs : (PTrie.keysA DEC_fill.X0.objs).map (fun h => DEC_fill.X1.objs.get (DEC_fill.σ.handle h)) =
  (PTrie.keysA DEC_fill.X0.objs).map (fun h => (DEC_fill.X0.objs.get h).map DEC_fill.σ.nobj)
kernel_rfl DEC_fill.nobjok : (PTrie.keysA DEC_fill.X0.objs).all (objOK DEC_fill.σ DEC_fill.PE.NL DEC_fill.X0) = true
end Host.Load.Run.Tpl
