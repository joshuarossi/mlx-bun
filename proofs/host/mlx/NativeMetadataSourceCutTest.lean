import host.mlx.NativeMetadataSourceCut
import host.mlx.OrdinaryVectorFactoryCut
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.Tests.MetadataSourceCut
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Annotated
open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_derive_metadata_cut P.F, VectorFactoryCall.input using (numberServer P.RestStream.micro0.micro23.S50) as NotMetadata"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "not readonly metadata").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "not readonly metadata").length > 1 then rejected := true
  set saved
  unless rejected do throwError "metadata-only source derivation accepted native allocation"
end Host.Load.Run.Full.Ordinary.Tests.MetadataSourceCut
