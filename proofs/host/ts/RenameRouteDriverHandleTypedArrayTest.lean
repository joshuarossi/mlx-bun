import host.ts.renameOrdinary.DriverMapTyped
import host.ts.RenameKernelRflTest

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary

/--
error: host_transport_step: unsupported source constructor Host.Ts.Ctl.call
-/
#guard_msgs in
host_transport_handle_typed_array P.F, MapPush203.input to MapPush203.output as UnsupportedPush

/--
error: host_transport_step: unsupported source constructor Host.Ts.Ctl.ret
-/
#guard_msgs in
host_transport_handle_typed_array P.F, MapReturn222.input to MapReturn222.output as UnsupportedReturn

end Host.Load.Run.Full.Ordinary
