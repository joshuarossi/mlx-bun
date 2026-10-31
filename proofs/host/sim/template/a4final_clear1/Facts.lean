import host.sim.template.a4final_clear1.Run
import host.sim.template.a4final_clear1.Bridge
import host.sim.compose.a4b.GraphStart
import host.sim.compose.Seg
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Compose Host.Ts.Sim.Template Host.Ts.Sim.Full
kernel_rfl FinalClear1.start_exact : FinalClear1.s0 = (fullWorld 0).finalStartW DEC.s0 DEC.tab0.length
kernel_rfl FinalClear1.tab_exact : FinalClear1.S0.tab = DEC.tab0 ++ [.var 17]
kernel_rfl FinalClear1.oracle_exact : FinalClear1.S0.oracle = FinalClear1.O
kernel_rfl FinalClear1.oracle3 : FinalClear1.S3.oracle = []
kernel_rfl FinalClear1.oracle6 : FinalClear1.S6.oracle = []
kernel_rfl FinalClear1.oracle9 : FinalClear1.S9.oracle = []
kernel_rfl FinalClear1.oracle10 : FinalClear1.S10.oracle = []
kernel_rfl FinalClear1.ok0 : FinalClear1.okB0 FinalClear1.s0 FinalClear1.S0 = true
kernel_rfl FinalClear1.ok1 : FinalClear1.okB0 FinalClear1.s1 FinalClear1.S1 = true
kernel_rfl FinalClear1.ok3 : FinalClear1.okB1 FinalClear1.s3 FinalClear1.S3 = true
kernel_rfl FinalClear1.ok4 : FinalClear1.okB1 FinalClear1.s4 FinalClear1.S4 = true
kernel_rfl FinalClear1.ok6 : FinalClear1.okB2 FinalClear1.s6 FinalClear1.S6 = true
kernel_rfl FinalClear1.ok7 : FinalClear1.okB2 FinalClear1.s7 FinalClear1.S7 = true
kernel_rfl FinalClear1.ok9 : FinalClear1.okB3 FinalClear1.s9 FinalClear1.S9 = true
kernel_rfl FinalClear1.halt1 : isHalt FinalClear1.s1.ctl = false
kernel_rfl FinalClear1.halt4 : isHalt FinalClear1.s4.ctl = false
kernel_rfl FinalClear1.halt7 : isHalt FinalClear1.s7.ctl = false
noncomputable def FinalClear1.fs1 : List Frame := FinalClear1.s2.stack.drop 1
noncomputable def FinalClear1.fs2 : List Frame := FinalClear1.s5.stack.drop 1
kernel_rfl FinalClear1.stack1 : FinalClear1.s2.stack = .e (.member kLength false) :: FinalClear1.fs1
kernel_rfl FinalClear1.stack2 : FinalClear1.s5.stack = .e (.member kLength false) :: FinalClear1.fs2
kernel_rfl FinalClear1.kind1 : (objOf FinalClear1.s2 2665).kind = .array (arrOf DEC.s0 2665 ++ [])
kernel_rfl FinalClear1.kind2 : (objOf FinalClear1.s5 2665).kind = .array (arrOf DEC.s0 2665 ++ [])
kernel_rfl FinalClear1.grow03 : Nat.ble FinalClear1.S0.tab.length FinalClear1.S3.tab.length = true
kernel_rfl FinalClear1.grow36 : Nat.ble FinalClear1.S3.tab.length FinalClear1.S6.tab.length = true
kernel_rfl FinalClear1.grow69 : Nat.ble FinalClear1.S6.tab.length FinalClear1.S9.tab.length = true
kernel_rfl FinalClear1.grow910 : Nat.ble FinalClear1.S9.tab.length FinalClear1.S10.tab.length = true
kernel_rfl FinalClear1.grow01 : Nat.ble FinalClear1.S0.tab.length FinalClear1.S1.tab.length = true
kernel_rfl FinalClear1.grow12 : Nat.ble FinalClear1.S1.tab.length FinalClear1.S2.tab.length = true
kernel_rfl FinalClear1.grow34 : Nat.ble FinalClear1.S3.tab.length FinalClear1.S4.tab.length = true
kernel_rfl FinalClear1.grow45 : Nat.ble FinalClear1.S4.tab.length FinalClear1.S5.tab.length = true
kernel_rfl FinalClear1.grow67 : Nat.ble FinalClear1.S6.tab.length FinalClear1.S7.tab.length = true
kernel_rfl FinalClear1.grow78 : Nat.ble FinalClear1.S7.tab.length FinalClear1.S8.tab.length = true
noncomputable def FinalClear1.vF : Val := match FinalClear1.s10.ctl with
  | .halt (.normal v) => v
  | _ => .undef
kernel_rfl FinalClear1.haltF : FinalClear1.s10.ctl = .halt (.normal FinalClear1.vF)
kernel_rfl FinalClear1.emit_get : FinalClear1.s10.heap.get 12504 = some (.obj (objOf FinalClear1.s10 12504))
kernel_rfl FinalClear1.emit_kind : (objOf FinalClear1.s10 12504).kind =
  .array (arrOf DEC.s0 12504 ++ [.num (.ref 79), .num (.ref DEC.tab0.length)])
kernel_rfl FinalClear1.cell : FinalClear1.s10.cell? 2590 = some (some (.obj 12504))
kernel_rfl FinalClear1.read : (mlxOf FinalClear1.s10.ffi).items.get 20157 = some (.ref 79)
kernel_rfl FinalClear1.fed : (mlxOf FinalClear1.s10.ffi).items.get 22538 = some (.ref DEC.tab0.length)
kernel_rfl FinalClear1.read_present : ((mlxOf FinalClear1.s10.ffi).nodes.get 20157).isSome = true
kernel_rfl FinalClear1.fed_present : ((mlxOf FinalClear1.s10.ffi).nodes.get 22538).isSome = true
kernel_rfl FinalClear1.tokens : (mlxOf FinalClear1.s10.ffi).tokens = []
kernel_rfl FinalClear1.token_var : nth? FinalClear1.S10.tab 79 = some (.var 14)
kernel_rfl FinalClear1.next_var : nth? FinalClear1.S10.tab DEC.tab0.length = some (.var 17)
end Host.Load.Run.Tpl
