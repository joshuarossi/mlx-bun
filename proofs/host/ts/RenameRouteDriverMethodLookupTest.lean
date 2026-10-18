import host.ts.renameOrdinary.MlxRegistrySteps
import host.ts.RenameKernelRflTest
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
/-- error: host_transport_method_lookup: expected method lookup continuation -/
#guard_msgs in
host_transport_method_lookup P.F, ConstructorThis387.output to ConstructorThis387.output as UnsupportedPrivateAssignment
end Host.Load.Run.Full.Ordinary.VectorToConcat
