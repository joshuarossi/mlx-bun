import host.ts.RenameRuntimeDriverUpdate
import host.ts.renameOrdinary.MapBodyStates
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedUpdates
host_retained_update P.F, P.RestStream.micro0.micro1.s48 using P.RestStream.micro0.micro1.S48
  to P.RestStream.micro0.micro1.s49 using P.RestStream.micro0.micro1.S49 as Read148
host_retained_update P.F, P.RestStream.micro0.micro1.s49 using P.RestStream.micro0.micro1.S49
  to P.RestStream.micro0.micro1.s50 using P.RestStream.micro0.micro1.S50 as Store149
host_retained_update P.F, P.RestStream.micro0.micro1.s50 using P.RestStream.micro0.micro1.S50
  to P.RestStream.micro0.micro1.s51 using P.RestStream.micro0.micro1.S51 as ReturnOld150
end Host.Load.Run.Full.Ordinary.RetainedUpdates
