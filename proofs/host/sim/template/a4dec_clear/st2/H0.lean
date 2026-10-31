import host.sim.template.a4dec_clear.States
import host.sim.template.a4dec_clear.H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state DEC_clear.st2 0
host_stream_state DEC_clear.st2 1
host_stream_state DEC_clear.st2 2
end Host.Load.Run.Tpl
