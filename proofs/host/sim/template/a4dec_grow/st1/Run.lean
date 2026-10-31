import host.sim.template.a4dec_grow.st1.K0
import host.sim.template.a4dec_grow.st1.K1
import host.sim.template.a4dec_grow.st1.K2
import host.sim.template.a4dec_grow.st1.K3
import host.sim.template.a4dec_grow.st1.K4
import host.sim.template.a4dec_grow.st1.K5
import host.sim.template.a4dec_grow.st1.K6
import host.sim.template.a4dec_grow.st1.K7
import host.sim.template.a4dec_grow.st1.K8
import host.sim.template.a4dec_grow.st1.K9
import host.sim.template.a4dec_grow.st1.K10
import host.sim.template.a4dec_grow.st1.K11
import host.sim.template.a4dec_grow.st1.K12
import host.sim.template.a4dec_grow.st1.K13
import host.sim.template.a4dec_grow.st1.K14
import host.sim.template.a4dec_grow.st1.K15
import host.sim.template.a4dec_grow.st1.K16
import host.sim.template.a4dec_grow.st1.K17
import host.sim.template.a4dec_grow.st1.K18
import host.sim.template.a4dec_grow.st1.K19
import host.sim.template.a4dec_grow.st1.K20
import host.sim.template.a4dec_grow.st1.K21
import host.sim.template.a4dec_grow.st1.K22
import host.sim.template.a4dec_grow.st1.K23
import host.sim.template.a4dec_grow.st1.K24
import host.sim.template.a4dec_grow.st1.K25
import host.sim.template.a4dec_grow.st1.K26
import host.sim.template.a4dec_grow.st1.K27
import host.sim.template.a4dec_grow.st1.K28
import host.sim.template.a4dec_grow.st1.K29
import host.sim.template.a4dec_grow.st1.K30
import host.sim.template.a4dec_grow.st1.K31
import host.sim.template.a4dec_grow.st1.K32
import host.sim.template.a4dec_grow.st1.K33
import host.sim.template.a4dec_grow.st1.K34
import host.sim.template.a4dec_grow.st1.K35
import host.sim.template.a4dec_grow.st1.K36
import host.sim.template.a4dec_grow.st1.K37
import host.sim.template.a4dec_grow.st1.K38
import host.sim.template.ChainRange
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim Host.Ts.Sim.Template
sim_chain_range DEC_grow.st1 DEC_grow.st1.okL 0 152 run
end Host.Load.Run.Tpl
