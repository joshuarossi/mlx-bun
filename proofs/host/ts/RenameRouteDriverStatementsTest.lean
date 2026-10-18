import host.ts.renameOrdinary.VectorToConcatVectorPrefix
import host.ts.renameOrdinary.VectorToConcatPointer
import host.ts.RenameKernelRflTest
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat

/--
error: host_transport_step: unsupported source constructor Host.Ts.Ctl.call
-/
#guard_msgs in
host_transport_statement P.F, Pointer309.input to Pointer309.output as UnsupportedCallStatement

/--
error: host_transport_step: unsupported source constructor Host.Ts.StmtF.decl
-/
#guard_msgs in
host_transport_undefined_branch P.F, Pointer309.input to Pointer309.output as UnsupportedDeclarationBranch

end Host.Load.Run.Full.Ordinary.VectorToConcat
