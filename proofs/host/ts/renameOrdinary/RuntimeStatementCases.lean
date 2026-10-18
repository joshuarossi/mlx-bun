import host.ts.renameOrdinary.WeightByteCountSteps
import host.ts.RenameRuntimeDriverStep
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
host_runtime_step P.F, P.RestStream.micro0.micro5.s2 using P.RestStream.micro0.micro5.S2
  to P.RestStream.micro0.micro5.s3 using P.RestStream.micro0.micro5.S3 as RuntimeBlock502
host_runtime_step P.F, P.RestStream.micro0.micro5.s3 using P.RestStream.micro0.micro5.S3
  to P.RestStream.micro0.micro5.s4 using P.RestStream.micro0.micro5.S4 as RuntimeDeclaration503
host_runtime_step P.F, P.RestStream.micro0.micro5.s20 using P.RestStream.micro0.micro5.S20
  to P.RestStream.micro0.micro5.s21 using P.RestStream.micro0.micro5.S21 as RuntimeReturn520
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
