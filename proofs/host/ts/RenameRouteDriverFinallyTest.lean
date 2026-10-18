import host.ts.renameOrdinary.MlxCleanupSteps
import host.ts.RenameKernelRflTest
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
/-- error: host_transport_return_finally: expected return completion -/
#guard_msgs in
host_transport_return_finally P.F, ConstructorReturn408.input to ConstructorReturn408.output as UnsupportedValueReturn
end Host.Load.Run.Full.Ordinary.VectorToConcat
