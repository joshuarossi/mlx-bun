import host.sim.template.a4final_eos1.Run
import host.sim.template.a4final_eos1.Bridge
import host.sim.compose.a4b.GraphStart
import host.sim.compose.Seg
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Compose Host.Ts.Sim.Template Host.Ts.Sim.Full
open Host.Load.Run.Prompt
kernel_rfl FinalEos1.start_exact : FinalEos1.s0 = (fullWorld 0).finalStartW DEC.s0 DEC.tab0.length
kernel_rfl FinalEos1.tab_exact : FinalEos1.S0.tab = DEC.tab0 ++ [.var 17]
kernel_rfl FinalEos1.oracle_exact : FinalEos1.S0.oracle = FinalEos1.O
kernel_rfl FinalEos1.oracle3 : FinalEos1.S3.oracle = []
kernel_rfl FinalEos1.oracle6 : FinalEos1.S6.oracle = []
kernel_rfl FinalEos1.oracle9 : FinalEos1.S9.oracle = []
kernel_rfl FinalEos1.oracle10 : FinalEos1.S10.oracle = []
kernel_rfl FinalEos1.ok0 : FinalEos1.okB0 FinalEos1.s0 FinalEos1.S0 = true
kernel_rfl FinalEos1.ok1 : FinalEos1.okB0 FinalEos1.s1 FinalEos1.S1 = true
kernel_rfl FinalEos1.ok3 : FinalEos1.okB1 FinalEos1.s3 FinalEos1.S3 = true
kernel_rfl FinalEos1.ok4 : FinalEos1.okB1 FinalEos1.s4 FinalEos1.S4 = true
kernel_rfl FinalEos1.ok6 : FinalEos1.okB2 FinalEos1.s6 FinalEos1.S6 = true
kernel_rfl FinalEos1.ok7 : FinalEos1.okB2 FinalEos1.s7 FinalEos1.S7 = true
kernel_rfl FinalEos1.ok9 : FinalEos1.okB3 FinalEos1.s9 FinalEos1.S9 = true
kernel_rfl FinalEos1.halt1 : isHalt FinalEos1.s1.ctl = false
kernel_rfl FinalEos1.halt4 : isHalt FinalEos1.s4.ctl = false
kernel_rfl FinalEos1.halt7 : isHalt FinalEos1.s7.ctl = false
noncomputable def FinalEos1.fs1 : List Frame := FinalEos1.s2.stack.drop 1
noncomputable def FinalEos1.fs2 : List Frame := FinalEos1.s5.stack.drop 1
kernel_rfl FinalEos1.stack1 : FinalEos1.s2.stack = .e (.member kLength false) :: FinalEos1.fs1
kernel_rfl FinalEos1.stack2 : FinalEos1.s5.stack = .e (.member kLength false) :: FinalEos1.fs2
kernel_rfl FinalEos1.kind1 : (objOf FinalEos1.s2 2665).kind = .array (arrOf DEC.s0 2665 ++ [])
kernel_rfl FinalEos1.kind2 : (objOf FinalEos1.s5 2665).kind = .array (arrOf DEC.s0 2665 ++ [])
kernel_rfl FinalEos1.grow03 : Nat.ble FinalEos1.S0.tab.length FinalEos1.S3.tab.length = true
kernel_rfl FinalEos1.grow36 : Nat.ble FinalEos1.S3.tab.length FinalEos1.S6.tab.length = true
kernel_rfl FinalEos1.grow69 : Nat.ble FinalEos1.S6.tab.length FinalEos1.S9.tab.length = true
kernel_rfl FinalEos1.grow910 : Nat.ble FinalEos1.S9.tab.length FinalEos1.S10.tab.length = true
kernel_rfl FinalEos1.grow01 : Nat.ble FinalEos1.S0.tab.length FinalEos1.S1.tab.length = true
kernel_rfl FinalEos1.grow12 : Nat.ble FinalEos1.S1.tab.length FinalEos1.S2.tab.length = true
kernel_rfl FinalEos1.grow34 : Nat.ble FinalEos1.S3.tab.length FinalEos1.S4.tab.length = true
kernel_rfl FinalEos1.grow45 : Nat.ble FinalEos1.S4.tab.length FinalEos1.S5.tab.length = true
kernel_rfl FinalEos1.grow67 : Nat.ble FinalEos1.S6.tab.length FinalEos1.S7.tab.length = true
kernel_rfl FinalEos1.grow78 : Nat.ble FinalEos1.S7.tab.length FinalEos1.S8.tab.length = true
noncomputable def FinalEos1.vF : Val := match FinalEos1.s10.ctl with
  | .halt (.normal v) => v
  | _ => .undef
kernel_rfl FinalEos1.haltF : FinalEos1.s10.ctl = .halt (.normal FinalEos1.vF)
kernel_rfl FinalEos1.emit_get : FinalEos1.s10.heap.get 12504 = some (.obj (objOf FinalEos1.s10 12504))
kernel_rfl FinalEos1.emit_kind : (objOf FinalEos1.s10 12504).kind =
  .array (arrOf DEC.s0 12504 ++ [.num (.ref 79)])
kernel_rfl FinalEos1.cell : FinalEos1.s10.cell? 2590 = some (some (.obj 12504))
kernel_rfl FinalEos1.read : (mlxOf FinalEos1.s10.ffi).items.get 20157 = some (.ref 79)
kernel_rfl FinalEos1.fed : (mlxOf FinalEos1.s10.ffi).items.get 22538 = some (.ref DEC.tab0.length)
kernel_rfl FinalEos1.read_present : ((mlxOf FinalEos1.s10.ffi).nodes.get 20157).isSome = true
kernel_rfl FinalEos1.fed_present : ((mlxOf FinalEos1.s10.ffi).nodes.get 22538).isSome = true
kernel_rfl FinalEos1.tokens : (mlxOf FinalEos1.s10.ffi).tokens = []
kernel_rfl FinalEos1.token_var : nth? FinalEos1.S10.tab 79 = some (.var 14)
kernel_rfl FinalEos1.next_var : nth? FinalEos1.S10.tab DEC.tab0.length = some (.var 17)
noncomputable def FinalEos1.gF : Nat := match FinalEos1.s10.cell? 2589 with
  | some (some (.obj g)) => g
  | _ => 0
noncomputable def FinalEos1.wF : Nat := match ownW FinalEos1.s10 (.obj FinalEos1.gF) chars!"stats" with
  | some (.obj w) => w
  | _ => 0
kernel_rfl FinalEos1.stop_cell : FinalEos1.s10.cell? 2589 = some (some (.obj FinalEos1.gF))
kernel_rfl FinalEos1.stop_gen_frame : wideP FinalEos1.gF = none
kernel_rfl FinalEos1.stop_stats : ownW FinalEos1.s10 (.obj FinalEos1.gF) chars!"stats" = some (.obj FinalEos1.wF)
kernel_rfl FinalEos1.stop_stats_frame : wideP FinalEos1.wF = none
kernel_rfl FinalEos1.stop_reason : ownW FinalEos1.s10 (.obj FinalEos1.wF) chars!"finishReason" = some (.str chars!"stop")

theorem FinalEos1.stop (b0 : BSt) (NB : Nat) : StopAtW (Wd := fullWorldFb b0 NB) wideP addrPrompt FinalEos1.s10 :=
  ⟨by decide, FinalEos1.gF, FinalEos1.wF, FinalEos1.stop_cell, FinalEos1.stop_gen_frame,
    FinalEos1.stop_stats, FinalEos1.stop_stats_frame, FinalEos1.stop_reason⟩


end Host.Load.Run.Tpl
