import host.ts.renameOrdinary.HostCuts
import host.ts.renameOrdinary.MapBodyStates
import host.ts.renameOrdinary.RankOriginH0
import host.ts.RenameRetainedDriverStep
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedHeapReads

host_retained_step P.F, P.RestStream.micro0.micro0.s77 using P.RestStream.micro0.micro0.S77 to P.RestStream.micro0.micro0.s78 using P.RestStream.micro0.micro0.S78 as This77
host_retained_step P.F, P.RestStream.micro0.micro1.s30 using P.RestStream.micro0.micro1.S30 to P.RestStream.micro0.micro1.s31 using P.RestStream.micro0.micro1.S31 as Private130
host_retained_step P.F, P.RestStream.micro0.micro1.s32 using P.RestStream.micro0.micro1.S32 to P.RestStream.micro0.micro1.s33 using P.RestStream.micro0.micro1.S33 as Private132
host_retained_step P.F, P.micro3275.s34 using P.micro3275.S34 to P.micro3275.s35 using P.micro3275.S35 as Disposed34

open Host.Ts Host.Ts.Owned.Annotated in
theorem numeric_field_requires_occurrence :
    ¬ StaticValue (.num (.lit (F64.ofNat 3))) (.literal (.lit (F64.ofNat 3))) := by
  intro invalid
  cases invalid

open Host.Ts Host.Ts.Owned.Annotated in
theorem native_field_requires_occurrence : ¬ StaticValue (.big 29363) (.handle 29363) := by
  intro invalid
  cases invalid

end Host.Load.Run.Full.Ordinary.RetainedHeapReads
