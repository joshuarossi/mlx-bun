import host.sim.template.a4final_clear0.Run
import host.sim.template.a4final_clear0.Bridge
import host.sim.compose.a4b.GraphStart
import host.sim.compose.Seg
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Compose Host.Ts.Sim.Template Host.Ts.Sim.Full
kernel_rfl FinalClear0.start_exact : FinalClear0.s0 = (fullWorld 0).finalStartW DEC.s0 DEC.tab0.length
kernel_rfl FinalClear0.tab_exact : FinalClear0.S0.tab = DEC.tab0 ++ [.var 17]
kernel_rfl FinalClear0.oracle_exact : FinalClear0.S0.oracle = FinalClear0.O
kernel_rfl FinalClear0.oracle3 : FinalClear0.S3.oracle = []
kernel_rfl FinalClear0.oracle6 : FinalClear0.S6.oracle = []
kernel_rfl FinalClear0.oracle9 : FinalClear0.S9.oracle = []
kernel_rfl FinalClear0.oracle10 : FinalClear0.S10.oracle = []
kernel_rfl FinalClear0.ok0 : FinalClear0.okB0 FinalClear0.s0 FinalClear0.S0 = true
kernel_rfl FinalClear0.ok1 : FinalClear0.okB0 FinalClear0.s1 FinalClear0.S1 = true
kernel_rfl FinalClear0.ok3 : FinalClear0.okB1 FinalClear0.s3 FinalClear0.S3 = true
kernel_rfl FinalClear0.ok4 : FinalClear0.okB1 FinalClear0.s4 FinalClear0.S4 = true
kernel_rfl FinalClear0.ok6 : FinalClear0.okB2 FinalClear0.s6 FinalClear0.S6 = true
kernel_rfl FinalClear0.ok7 : FinalClear0.okB2 FinalClear0.s7 FinalClear0.S7 = true
kernel_rfl FinalClear0.ok9 : FinalClear0.okB3 FinalClear0.s9 FinalClear0.S9 = true
kernel_rfl FinalClear0.halt1 : isHalt FinalClear0.s1.ctl = false
kernel_rfl FinalClear0.halt4 : isHalt FinalClear0.s4.ctl = false
kernel_rfl FinalClear0.halt7 : isHalt FinalClear0.s7.ctl = false
noncomputable def FinalClear0.fs1 : List Frame := FinalClear0.s2.stack.drop 1
noncomputable def FinalClear0.fs2 : List Frame := FinalClear0.s5.stack.drop 1
kernel_rfl FinalClear0.stack1 : FinalClear0.s2.stack = .e (.member kLength false) :: FinalClear0.fs1
kernel_rfl FinalClear0.stack2 : FinalClear0.s5.stack = .e (.member kLength false) :: FinalClear0.fs2
kernel_rfl FinalClear0.kind1 : (objOf FinalClear0.s2 2665).kind = .array (arrOf DEC.s0 2665 ++ [])
kernel_rfl FinalClear0.kind2 : (objOf FinalClear0.s5 2665).kind = .array (arrOf DEC.s0 2665 ++ [])
kernel_rfl FinalClear0.grow03 : Nat.ble FinalClear0.S0.tab.length FinalClear0.S3.tab.length = true
kernel_rfl FinalClear0.grow36 : Nat.ble FinalClear0.S3.tab.length FinalClear0.S6.tab.length = true
kernel_rfl FinalClear0.grow69 : Nat.ble FinalClear0.S6.tab.length FinalClear0.S9.tab.length = true
kernel_rfl FinalClear0.grow910 : Nat.ble FinalClear0.S9.tab.length FinalClear0.S10.tab.length = true
kernel_rfl FinalClear0.grow01 : Nat.ble FinalClear0.S0.tab.length FinalClear0.S1.tab.length = true
kernel_rfl FinalClear0.grow12 : Nat.ble FinalClear0.S1.tab.length FinalClear0.S2.tab.length = true
kernel_rfl FinalClear0.grow34 : Nat.ble FinalClear0.S3.tab.length FinalClear0.S4.tab.length = true
kernel_rfl FinalClear0.grow45 : Nat.ble FinalClear0.S4.tab.length FinalClear0.S5.tab.length = true
kernel_rfl FinalClear0.grow67 : Nat.ble FinalClear0.S6.tab.length FinalClear0.S7.tab.length = true
kernel_rfl FinalClear0.grow78 : Nat.ble FinalClear0.S7.tab.length FinalClear0.S8.tab.length = true
noncomputable def FinalClear0.vF : Val := match FinalClear0.s10.ctl with
  | .halt (.normal v) => v
  | _ => .undef
kernel_rfl FinalClear0.haltF : FinalClear0.s10.ctl = .halt (.normal FinalClear0.vF)
kernel_rfl FinalClear0.emit_get : FinalClear0.s10.heap.get 12504 = some (.obj (objOf FinalClear0.s10 12504))
kernel_rfl FinalClear0.emit_kind : (objOf FinalClear0.s10 12504).kind =
  .array (arrOf DEC.s0 12504 ++ [.num (.ref 79), .num (.ref DEC.tab0.length)])
kernel_rfl FinalClear0.cell : FinalClear0.s10.cell? 2590 = some (some (.obj 12504))
kernel_rfl FinalClear0.read : (mlxOf FinalClear0.s10.ffi).items.get 20157 = some (.ref 79)
kernel_rfl FinalClear0.fed : (mlxOf FinalClear0.s10.ffi).items.get 22538 = some (.ref DEC.tab0.length)
kernel_rfl FinalClear0.read_present : ((mlxOf FinalClear0.s10.ffi).nodes.get 20157).isSome = true
kernel_rfl FinalClear0.fed_present : ((mlxOf FinalClear0.s10.ffi).nodes.get 22538).isSome = true
kernel_rfl FinalClear0.tokens : (mlxOf FinalClear0.s10.ffi).tokens = []
kernel_rfl FinalClear0.token_var : nth? FinalClear0.S10.tab 79 = some (.var 14)
kernel_rfl FinalClear0.next_var : nth? FinalClear0.S10.tab DEC.tab0.length = some (.var 17)
end Host.Load.Run.Tpl
