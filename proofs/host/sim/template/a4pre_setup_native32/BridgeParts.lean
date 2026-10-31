import host.sim.template.a4pre_setup_native32.BridgePartsData
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

open Lean Elab Command Meta in
run_elab do
  let env ← getEnv
  let pre := `Host.Load.Run.Tpl.PREBridgeParts
  for (tag, dest) in [("bridge5481_", `b1), ("bridge10961_", `b2), ("bridge16441_", `b3)] do
    let names := env.constants.toList.filterMap fun (n, _) =>
      if n.getPrefix == pre && n.getString!.startsWith tag then some n else none
    let [name] := names | throwError "expected one native bridge candidate with tag {tag}"
    let target := pre ++ dest
    addDecl (.defnDecl (mkDefinitionValEx target [] (mkConst ``Host.Mlx.FfiAne.St)
      (mkConst name) (.regular 0) .safe [target]))

kernel_rfl PREBridgeParts.log_length : Host.Load.Run.Prompt.P.oblog2818.length = 2192
kernel_rfl PREBridgeParts.snapshot_exact :
  PREBridgeParts.s1.ffi.1.1.bridge = PRENative32.s0.ffi.1.1.bridge

end Host.Load.Run.Tpl
