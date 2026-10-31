import host.sim.template.a4final_plain.Run
import host.sim.template.a4final_plain.Bridge
import host.sim.compose.a4b.GraphStart
import host.sim.compose.Seg
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Compose Host.Ts.Sim.Template Host.Ts.Sim.Full
kernel_rfl FinalPlain.start_exact : FinalPlain.s0 = (fullWorld 0).finalStartW DEC.s0 DEC.tab0.length
kernel_rfl FinalPlain.tab_exact : FinalPlain.S0.tab = DEC.tab0 ++ [.var 17]
kernel_rfl FinalPlain.oracle_exact : FinalPlain.S0.oracle = FinalPlain.O
kernel_rfl FinalPlain.oracle3 : FinalPlain.S3.oracle = []
kernel_rfl FinalPlain.oracle6 : FinalPlain.S6.oracle = []
kernel_rfl FinalPlain.oracle9 : FinalPlain.S9.oracle = []
kernel_rfl FinalPlain.oracle10 : FinalPlain.S10.oracle = []
kernel_rfl FinalPlain.ok0 : FinalPlain.okB0 FinalPlain.s0 FinalPlain.S0 = true
kernel_rfl FinalPlain.ok1 : FinalPlain.okB0 FinalPlain.s1 FinalPlain.S1 = true
kernel_rfl FinalPlain.ok3 : FinalPlain.okB1 FinalPlain.s3 FinalPlain.S3 = true
kernel_rfl FinalPlain.ok4 : FinalPlain.okB1 FinalPlain.s4 FinalPlain.S4 = true
kernel_rfl FinalPlain.ok6 : FinalPlain.okB2 FinalPlain.s6 FinalPlain.S6 = true
kernel_rfl FinalPlain.ok7 : FinalPlain.okB2 FinalPlain.s7 FinalPlain.S7 = true
kernel_rfl FinalPlain.ok9 : FinalPlain.okB3 FinalPlain.s9 FinalPlain.S9 = true
kernel_rfl FinalPlain.halt1 : isHalt FinalPlain.s1.ctl = false
kernel_rfl FinalPlain.halt4 : isHalt FinalPlain.s4.ctl = false
kernel_rfl FinalPlain.halt7 : isHalt FinalPlain.s7.ctl = false
noncomputable def FinalPlain.fs1 : List Frame := FinalPlain.s2.stack.drop 1
noncomputable def FinalPlain.fs2 : List Frame := FinalPlain.s5.stack.drop 1
kernel_rfl FinalPlain.stack1 : FinalPlain.s2.stack = .e (.member kLength false) :: FinalPlain.fs1
kernel_rfl FinalPlain.stack2 : FinalPlain.s5.stack = .e (.member kLength false) :: FinalPlain.fs2
kernel_rfl FinalPlain.kind1 : (objOf FinalPlain.s2 2665).kind = .array (arrOf DEC.s0 2665 ++ [])
kernel_rfl FinalPlain.kind2 : (objOf FinalPlain.s5 2665).kind = .array (arrOf DEC.s0 2665 ++ [])
kernel_rfl FinalPlain.grow03 : Nat.ble FinalPlain.S0.tab.length FinalPlain.S3.tab.length = true
kernel_rfl FinalPlain.grow36 : Nat.ble FinalPlain.S3.tab.length FinalPlain.S6.tab.length = true
kernel_rfl FinalPlain.grow69 : Nat.ble FinalPlain.S6.tab.length FinalPlain.S9.tab.length = true
kernel_rfl FinalPlain.grow910 : Nat.ble FinalPlain.S9.tab.length FinalPlain.S10.tab.length = true
kernel_rfl FinalPlain.grow01 : Nat.ble FinalPlain.S0.tab.length FinalPlain.S1.tab.length = true
kernel_rfl FinalPlain.grow12 : Nat.ble FinalPlain.S1.tab.length FinalPlain.S2.tab.length = true
kernel_rfl FinalPlain.grow34 : Nat.ble FinalPlain.S3.tab.length FinalPlain.S4.tab.length = true
kernel_rfl FinalPlain.grow45 : Nat.ble FinalPlain.S4.tab.length FinalPlain.S5.tab.length = true
kernel_rfl FinalPlain.grow67 : Nat.ble FinalPlain.S6.tab.length FinalPlain.S7.tab.length = true
kernel_rfl FinalPlain.grow78 : Nat.ble FinalPlain.S7.tab.length FinalPlain.S8.tab.length = true
noncomputable def FinalPlain.vF : Val := match FinalPlain.s10.ctl with
  | .halt (.normal v) => v
  | _ => .undef
kernel_rfl FinalPlain.haltF : FinalPlain.s10.ctl = .halt (.normal FinalPlain.vF)
kernel_rfl FinalPlain.emit_get : FinalPlain.s10.heap.get 12504 = some (.obj (objOf FinalPlain.s10 12504))
kernel_rfl FinalPlain.emit_kind : (objOf FinalPlain.s10 12504).kind =
  .array (arrOf DEC.s0 12504 ++ [.num (.ref 79), .num (.ref DEC.tab0.length)])
kernel_rfl FinalPlain.cell : FinalPlain.s10.cell? 2590 = some (some (.obj 12504))
kernel_rfl FinalPlain.read : (mlxOf FinalPlain.s10.ffi).items.get 20157 = some (.ref 79)
kernel_rfl FinalPlain.fed : (mlxOf FinalPlain.s10.ffi).items.get 22538 = some (.ref DEC.tab0.length)
kernel_rfl FinalPlain.read_present : ((mlxOf FinalPlain.s10.ffi).nodes.get 20157).isSome = true
kernel_rfl FinalPlain.fed_present : ((mlxOf FinalPlain.s10.ffi).nodes.get 22538).isSome = true
kernel_rfl FinalPlain.tokens : (mlxOf FinalPlain.s10.ffi).tokens = []
kernel_rfl FinalPlain.token_var : nth? FinalPlain.S10.tab 79 = some (.var 14)
kernel_rfl FinalPlain.next_var : nth? FinalPlain.S10.tab DEC.tab0.length = some (.var 17)
end Host.Load.Run.Tpl
