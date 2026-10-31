import host.sim.template.a4dec_ord.States
import host.sim.template.a4dec_ord.H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state DEC_ord.st0 0
host_stream_state DEC_ord.st0 1
host_stream_state DEC_ord.st0 2
end Host.Load.Run.Tpl
