import host.sim.template.a4dec_clearFill.States
import host.sim.template.a4dec_clearFill.H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state DEC_clearFill.st0 0
host_stream_state DEC_clearFill.st0 1
host_stream_state DEC_clearFill.st0 2
end Host.Load.Run.Tpl
