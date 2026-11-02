import host.route.cert.Row.R1.Inputs
import host.load.CacheCarriersCommand
import host.sim.template.a4pre_pl_t1.H0
import host.sim.template.a4pre_pl_t2.H0
import host.sim.template.a4pre_pl_t1.SpreadData
import host.sim.template.a4pre_pl_t2.SpreadData
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Row
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Load Host.Load.Extract Host.Load.Layers

/-! # The program's caches at the short paths' halts

`PRE_pl_t1`'s and `PRE_pl_t2`'s final states read the first forward's and row `r1`'s carriers. -/

def cacheEnv : Env := [(chars!"cache", 2586)]

noncomputable def t1List : Nat :=
  match PRE_pl_t1.s7.cell? 2586 with
  | some (some (.obj a)) => a
  | _ => 0
noncomputable def t2List : Nat :=
  match PRE_pl_t2.s7.cell? 2586 with
  | some (some (.obj a)) => a
  | _ => 0
noncomputable def t1Caches : List Cache := (cachesTW mlxOf PRE_pl_t1.s7 cacheEnv).getD []
noncomputable def t2Caches : List Cache := (cachesTW mlxOf PRE_pl_t2.s7 cacheEnv).getD []

kernel_rfl t1_cell : PRE_pl_t1.s7.cell? 2586 = some (some (.obj t1List))
kernel_rfl t1_free : (Host.Load.Run.Tpl.PostOk.JF [2673435, PRE_pl_t1.cacheArray]).framed.contains t1List = false
kernel_rfl t1_ok : cachesOkWB PRE_pl_t1.s7 cacheEnv (4910 :: ghostAddrs) = true
kernel_rfl t1_caches : cachesTW mlxOf PRE_pl_t1.s7 cacheEnv = some t1Caches
kernel_rfl t1_nodes : t1Caches.map cacheNodePair = R1.ps

kernel_rfl t2_cell : PRE_pl_t2.s7.cell? 2586 = some (some (.obj t2List))
kernel_rfl t2_free : (Host.Load.Run.Tpl.PostOk.JF [2673435, PRE_pl_t2.cacheArray]).framed.contains t2List = false
kernel_rfl t2_ok : cachesOkWB PRE_pl_t2.s7 cacheEnv (4910 :: ghostAddrs) = true
kernel_rfl t2_caches : cachesTW mlxOf PRE_pl_t2.s7 cacheEnv = some t2Caches
kernel_rfl t2_nodes : t2Caches.map cacheNodePair = R1.choice.outputs

end Host.Route.Cert.Row
