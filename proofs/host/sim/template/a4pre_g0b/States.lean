import host.sim.template.a4pre_first_tail_x15_r0.H0
import host.sim.template.ReturnLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

kernel_rfl PRE_g0b.sourceRet : PRE_first_tail_x15_r0.s6.ctl = .ret (.num (.lit (F64.ofNat 2048)))
kernel_rfl PRE_g0b.sourceN : PRE_first_tail_x15_r0.S6.tab.length = 10
return_literal PRE_g0b.rawInput from PRE_first_tail_x15_r0.s6 at 10
bridge_empty PRE_g0b.input from PRE_g0b.rawInput
server_literal PRE_g0b.inputSrv := (⟨PRE_first_tail_x15_r0.S6.tab ++ [.var 10], []⟩ : SSrv)
kernel_rfl PRE_g0b.inputRet : PRE_g0b.rawInput = PRE_first_tail_x15_r0.s6.ret (.num (.ref 10))
kernel_rfl PRE_g0b.inputTab : PRE_g0b.inputSrv.tab = PRE_first_tail_x15_r0.S6.tab ++ [.var 10]
kernel_rfl PRE_g0b.freshC : PRE_first_tail_x15_r0.S6.tab.all (fun e => e.noVar 10) = true

-- Keep the fixed load cut's two queued lookaheads in every serialized boundary.
set_option interpreter.prefer_native true in
tpl_chain PRE_g0b from PRE_g0b.input, PRE_g0b.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_g0b/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)

end Host.Load.Run.Tpl
