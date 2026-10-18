import host.load.RuntimeNamespacedDecodeCuts1175
import host.load.RuntimeBlockPlan
import host.mlx.NativeSourcePlugins
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let pre ← getCurrNamespace
  for i in List.range 101 do
    let part := min 3 (i/25)
    let offset := i-part*25
    for tag in ["s","S"] do
      let source := pre ++ Name.mkSimple s!"From{1100+part*25}" ++ Name.mkSimple s!"{tag}{offset}"
      Parametric.Driver.addData (pre ++ (Name.mkSimple "Region1100") ++ Name.mkSimple s!"{tag}{i}") (mkConst source)

theorem source1200 : Region1100.s100 = P.RestStream.micro0.s12 := by host_kernel_rfl
theorem server1200 : Region1100.S100 = numberServer P.RestStream.micro0.S12 := by host_kernel_rfl

end Host.Load.Run.Full.Ordinary.NamespacedDecode
