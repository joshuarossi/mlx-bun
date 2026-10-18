import host.ts.renameOrdinary.HostCuts
import host.ts.RenameRuntimeDriverRetained
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedPrefix
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s0 using P.RestStream.micro0.micro0.S0 to P.RestStream.micro0.micro0.s1 using P.RestStream.micro0.micro0.S1 as Source0
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s1 using P.RestStream.micro0.micro0.S1 to P.RestStream.micro0.micro0.s2 using P.RestStream.micro0.micro0.S2 as Source1
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s2 using P.RestStream.micro0.micro0.S2 to P.RestStream.micro0.micro0.s3 using P.RestStream.micro0.micro0.S3 as Source2
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s3 using P.RestStream.micro0.micro0.S3 to P.RestStream.micro0.micro0.s4 using P.RestStream.micro0.micro0.S4 as Source3
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s4 using P.RestStream.micro0.micro0.S4 to P.RestStream.micro0.micro0.s5 using P.RestStream.micro0.micro0.S5 as Source4
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s5 using P.RestStream.micro0.micro0.S5 to P.RestStream.micro0.micro0.s6 using P.RestStream.micro0.micro0.S6 as Source5
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s6 using P.RestStream.micro0.micro0.S6 to P.RestStream.micro0.micro0.s7 using P.RestStream.micro0.micro0.S7 as Source6
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s7 using P.RestStream.micro0.micro0.S7 to P.RestStream.micro0.micro0.s8 using P.RestStream.micro0.micro0.S8 as Source7
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s8 using P.RestStream.micro0.micro0.S8 to P.RestStream.micro0.micro0.s9 using P.RestStream.micro0.micro0.S9 as Source8
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s9 using P.RestStream.micro0.micro0.S9 to P.RestStream.micro0.micro0.s10 using P.RestStream.micro0.micro0.S10 as Source9
end Host.Load.Run.Full.Ordinary.RetainedPrefix
