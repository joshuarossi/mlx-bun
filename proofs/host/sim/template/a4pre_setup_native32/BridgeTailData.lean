import host.sim.template.a4pre_setup_native32.BridgeTailStates
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
host_stream_state PREBridgeTail 0
host_stream_state PREBridgeTail 1

open Lean Elab Command Meta in
run_elab do
  let env ← getEnv
  let pre := `Host.Load.Run.Tpl.PREBridgeTail
  let names := env.constants.toList.filterMap fun (n, _) =>
    if n.getPrefix == pre && n.getString!.startsWith "bridge19181_" then some n else none
  let [name] := names | throwError "expected one native bridge candidate for 1918 creates"
  let target := pre ++ `b4a
  addDecl (.defnDecl (mkDefinitionValEx target [] (mkConst ``Host.Mlx.FfiAne.St)
    (mkConst name) (.regular 0) .safe [target]))

kernel_rfl PREBridgeTail.snapshot_exact :
  PREBridgeTail.s1.ffi.1.1.bridge = PRENative32.s0.ffi.1.1.bridge

end Host.Load.Run.Tpl
