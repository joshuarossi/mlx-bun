import host.ts.renameOrdinary.MlxConstructorSteps
import host.ts.RenameKernelRflTest
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
/-- error: host_transport_private_assign: expected assignment continuation -/
#guard_msgs in
host_transport_private_assign P.F, HandleParameter381.input to HandleParameter381.output as UnsupportedParameter
/-- error: host_transport_private_assign: expected private assignment expression -/
#guard_msgs in
host_transport_private_assign P.F, ConstructorThis387.input to ConstructorThis387.output as UnsupportedThis
end Host.Load.Run.Full.Ordinary.VectorToConcat
