import host.route.cert.Dec.Clear.Inputs
import host.sim.template.a4dec4_clear.EEnd
import host.sim.compose.ChainFill
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

set_option autoImplicit false
namespace Host.Route.Cert.Dec.Clear
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Compose
open Host.Mlx.SimGraph Host.Mlx.SimGraph.Iter
open Host.Mlx.FfiEval
open Host.Route.Cert.Dec (cacheNodes inputs)

kernel_rfl end_read : Host.Load.Run.Tpl.DEC4_clear.σ.node 20157 = 22538
kernel_rfl end_fed : Host.Load.Run.Tpl.DEC4_clear.σ.node 22538 = certAt choice.cert Tpl.Ordinary.tokenNode
kernel_rfl end_caches : cacheNodes.map (fun p =>
    (p.1.map Host.Load.Run.Tpl.DEC4_clear.σ.node, p.2.map Host.Load.Run.Tpl.DEC4_clear.σ.node)) = choice.outputs
kernel_rfl end_readback : (mlxOf Host.Load.Run.Tpl.DEC4_clear.s11.ffi).items.get 20157 = some (.ref 79)
kernel_rfl end_read_present : ((mlxOf Host.Load.Run.Tpl.DEC4_clear.s11.ffi).nodes.get 20157).isSome = true
kernel_rfl end_tokens : (mlxOf Host.Load.Run.Tpl.DEC4_clear.s11.ffi).tokens = []
kernel_rfl end_output_present : ((mlxOf Host.Load.Run.Tpl.DEC4_clear.s11.ffi).nodes.get
    (certAt choice.cert Tpl.Ordinary.tokenNode)).isSome = true
kernel_rfl end_cache_present : PresentB (mlxOf Host.Load.Run.Tpl.DEC4_clear.s11.ffi) choice.outputs = true

/-- Readback, output and cache carriers at the exact checked clear end and restart map. -/
noncomputable def endGM (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM inputs ((Host.Load.Run.Tpl.DEC4_clear.iterEnd NB).toFb b0) where
  outT := certAt choice.cert Tpl.Ordinary.tokenNode
  outs := choice.outputs
  read := end_read
  fed := end_fed
  caches := end_caches
  h1read := end_readback
  h1pread := end_read_present
  s1tok := end_tokens
  pout := end_output_present
  pouts := present_of_B _ _ end_cache_present

end Host.Route.Cert.Dec.Clear
