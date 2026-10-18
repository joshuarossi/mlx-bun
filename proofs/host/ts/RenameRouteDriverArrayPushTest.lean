import host.ts.renameOrdinary.DriverMapPush
import host.ts.renameOrdinary.DriverMapBody
import host.ts.RenameArrayPushFields
import host.ts.RenameKernelRflTest

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary

/--
error: host_transport_step: unsupported source constructor Host.Ts.Ctl.ret
-/
#guard_msgs in
host_transport_array_push P.F, MapBody103.output to MapBody104.output as UnsupportedReturn

/--
error: host_transport_step: unsupported source constructor Host.Ts.Code.closure
-/
#guard_msgs in
host_transport_array_push P.F, MapBody126.input to MapBody126.output as UnsupportedClosure

end Host.Load.Run.Full.Ordinary
