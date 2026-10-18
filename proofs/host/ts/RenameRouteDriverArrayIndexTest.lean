import host.ts.renameOrdinary.MapIndexRoles
import host.ts.renameOrdinary.DriverMapBody
import host.ts.RenameParametricArrayPush
import host.ts.RenameKernelRflTest

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary

/--
error: host_transport_step: unsupported source constructor Host.Ts.Frame.lp
-/
#guard_msgs in
host_transport_array_index P.F, MapBody100.input to MapBody100.output as UnsupportedLoopFrame

/--
error: host_transport_step: unsupported source constructor Host.Ts.Frame.c
-/
#guard_msgs in
host_transport_array_index P.F, MapBody114.input to MapBody114.output as UnsupportedCallFrame

end Host.Load.Run.Full.Ordinary
