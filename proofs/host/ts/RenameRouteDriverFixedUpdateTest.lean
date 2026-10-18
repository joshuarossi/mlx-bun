import host.ts.renameOrdinary.DriverMapCompare
import host.ts.RenameKernelRflTest

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary

/--
error: host_transport_fixed_update: expected postfix increment
-/
#guard_msgs in
host_transport_fixed_update P.F, MapTest152.input to MapTest152.output as UnsupportedBinary

/--
error: host_transport_step: unsupported source constructor Host.Ts.Val.bool
-/
#guard_msgs in
host_transport_fixed_lt P.F, MapCompare156.output to MapCompare156.output as UnsupportedBoolean

end Host.Load.Run.Full.Ordinary
