import host.ts.RenameRuntimeDriverArrayPush
import host.ts.renameOrdinary.MapBodyStates

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RetainedArrayPushCases

/-- error: host_retained_arrayPush: expected source call -/
#guard_msgs in
host_retained_arrayPush P.F, {P.RestStream.micro0.micro1.s46 with ctl := .construct .undef [] .undef}
  using P.RestStream.micro0.micro1.S46 to P.RestStream.micro0.micro1.s47 using P.RestStream.micro0.micro1.S47 as RejectConstruct

host_retained_arrayPush P.F, P.RestStream.micro0.micro1.s46 using P.RestStream.micro0.micro1.S46
  to P.RestStream.micro0.micro1.s47 using P.RestStream.micro0.micro1.S47 as Source146

end Host.Load.Run.Full.Ordinary.RetainedArrayPushCases
