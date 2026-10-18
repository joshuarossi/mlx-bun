import host.ts.renameOrdinary.HostCuts
import host.ts.RenameRuntimeRetain
import host.ts.RenameRuntimeDriverRetained
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RuntimeRetained
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_runtime_step P.F, P.RestStream.micro0.micro0.s0 using P.RestStream.micro0.micro0.S0 to P.RestStream.micro0.micro0.s1 using P.RestStream.micro0.micro0.S1 as Source0
host_retain_runtime Source0.runtime_transport using
  (PureRuntimeCase.variable h Source0.sourceName Source0.sourceEnv Source0.address Source0.sourceValue Source0.source_control Source0.source_lookup Source0.source_cell)
  as retained0

host_runtime_step P.F, P.RestStream.micro0.micro0.s2 using P.RestStream.micro0.micro0.S2 to P.RestStream.micro0.micro0.s3 using P.RestStream.micro0.micro0.S3 as Source2
host_retain_runtime Source2.runtime_transport using
  (PureRuntimeCase.literal h Source2.sourceLiteral Source2.sourceValue Source2.sourceEnv Source2.parsed Source2.source_control)
  as retained2

host_runtime_step P.F, P.RestStream.micro0.micro0.s8 using P.RestStream.micro0.micro0.S8 to P.RestStream.micro0.micro0.s9 using P.RestStream.micro0.micro0.S9 as Source8
host_retain_runtime Source8.runtime_literal_transport using
  (PureRuntimeCase.arithmetic h Source8.kind Source8.sourceLeft Source8.sourceRight Source8.sourceTail Source8.source_control Source8.source_stack)
  as retained8

host_retained_pure_step P.F, P.RestStream.micro0.micro0.s14 using P.RestStream.micro0.micro0.S14 to P.RestStream.micro0.micro0.s15 using P.RestStream.micro0.micro0.S15 as Extra14
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s15 using P.RestStream.micro0.micro0.S15 to P.RestStream.micro0.micro0.s16 using P.RestStream.micro0.micro0.S16 as Extra15
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s16 using P.RestStream.micro0.micro0.S16 to P.RestStream.micro0.micro0.s17 using P.RestStream.micro0.micro0.S17 as Extra16
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s17 using P.RestStream.micro0.micro0.S17 to P.RestStream.micro0.micro0.s18 using P.RestStream.micro0.micro0.S18 as Extra17
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s18 using P.RestStream.micro0.micro0.S18 to P.RestStream.micro0.micro0.s19 using P.RestStream.micro0.micro0.S19 as Extra18
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s25 using P.RestStream.micro0.micro0.S25 to P.RestStream.micro0.micro0.s26 using P.RestStream.micro0.micro0.S26 as Extra25
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s26 using P.RestStream.micro0.micro0.S26 to P.RestStream.micro0.micro0.s27 using P.RestStream.micro0.micro0.S27 as Extra26
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s30 using P.RestStream.micro0.micro0.S30 to P.RestStream.micro0.micro0.s31 using P.RestStream.micro0.micro0.S31 as Extra30
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s40 using P.RestStream.micro0.micro0.S40 to P.RestStream.micro0.micro0.s41 using P.RestStream.micro0.micro0.S41 as Extra40
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s42 using P.RestStream.micro0.micro0.S42 to P.RestStream.micro0.micro0.s43 using P.RestStream.micro0.micro0.S43 as Extra42
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s44 using P.RestStream.micro0.micro0.S44 to P.RestStream.micro0.micro0.s45 using P.RestStream.micro0.micro0.S45 as Extra44
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s46 using P.RestStream.micro0.micro0.S46 to P.RestStream.micro0.micro0.s47 using P.RestStream.micro0.micro0.S47 as Extra46
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s51 using P.RestStream.micro0.micro0.S51 to P.RestStream.micro0.micro0.s52 using P.RestStream.micro0.micro0.S52 as Extra51
host_retained_pure_step P.F, P.RestStream.micro0.micro0.s53 using P.RestStream.micro0.micro0.S53 to P.RestStream.micro0.micro0.s54 using P.RestStream.micro0.micro0.S54 as Extra53

end Host.Load.Run.Full.Ordinary.RuntimeRetained
