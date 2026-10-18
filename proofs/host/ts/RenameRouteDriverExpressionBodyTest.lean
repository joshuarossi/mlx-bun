import host.ts.renameOrdinary.VectorToConcatCallbackPrefix
import host.ts.RenameKernelRflTest
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat

/--
error: host_transport_step: unsupported source constructor Host.Ts.Ctl.call
-/
#guard_msgs in
host_transport_expression_body P.F, Pointer309.input to Pointer309.output as UnsupportedNativeCall

end Host.Load.Run.Full.Ordinary.VectorToConcat
