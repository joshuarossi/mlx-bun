import host.ts.RenameRuntimeDriverPatterns
import host.ts.renameOrdinary.HostCuts

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedPatterns
host_retained_pattern P.F, P.RestStream.micro0.micro0.s19 using P.RestStream.micro0.micro0.S19
  to P.RestStream.micro0.micro0.s20 using P.RestStream.micro0.micro0.S20 as ArrayEntry19
host_retained_pattern P.F, P.RestStream.micro0.micro0.s20 using P.RestStream.micro0.micro0.S20
  to P.RestStream.micro0.micro0.s21 using P.RestStream.micro0.micro0.S21 as Identifier20
host_retained_pattern P.F, P.RestStream.micro0.micro0.s21 using P.RestStream.micro0.micro0.S21
  to P.RestStream.micro0.micro0.s22 using P.RestStream.micro0.micro0.S22 as ArrayNext21
host_retained_pattern P.F, P.RestStream.micro0.micro0.s23 using P.RestStream.micro0.micro0.S23
  to P.RestStream.micro0.micro0.s24 using P.RestStream.micro0.micro0.S24 as ArrayDone23
host_retained_pattern P.F, P.RestStream.micro0.micro0.s24 using P.RestStream.micro0.micro0.S24
  to P.RestStream.micro0.micro0.s25 using P.RestStream.micro0.micro0.S25 as Declaration24
end Host.Load.Run.Full.Ordinary.RetainedPatterns
