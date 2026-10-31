import host.sim.template.a4final_eos0.Run
import host.sim.template.a4final_eos0.Bridge
import host.sim.compose.a4b.GraphStart
import host.sim.compose.Seg
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Compose Host.Ts.Sim.Template Host.Ts.Sim.Full
open Host.Load.Run.Prompt
kernel_rfl FinalEos0.start_exact : FinalEos0.s0 = (fullWorld 0).finalStartW DEC.s0 DEC.tab0.length
kernel_rfl FinalEos0.tab_exact : FinalEos0.S0.tab = DEC.tab0 ++ [.var 17]
kernel_rfl FinalEos0.oracle_exact : FinalEos0.S0.oracle = FinalEos0.O
kernel_rfl FinalEos0.oracle3 : FinalEos0.S3.oracle = []
kernel_rfl FinalEos0.oracle6 : FinalEos0.S6.oracle = []
kernel_rfl FinalEos0.oracle9 : FinalEos0.S9.oracle = []
kernel_rfl FinalEos0.oracle10 : FinalEos0.S10.oracle = []
kernel_rfl FinalEos0.ok0 : FinalEos0.okB0 FinalEos0.s0 FinalEos0.S0 = true
kernel_rfl FinalEos0.ok1 : FinalEos0.okB0 FinalEos0.s1 FinalEos0.S1 = true
kernel_rfl FinalEos0.ok3 : FinalEos0.okB1 FinalEos0.s3 FinalEos0.S3 = true
kernel_rfl FinalEos0.ok4 : FinalEos0.okB1 FinalEos0.s4 FinalEos0.S4 = true
kernel_rfl FinalEos0.ok6 : FinalEos0.okB2 FinalEos0.s6 FinalEos0.S6 = true
kernel_rfl FinalEos0.ok7 : FinalEos0.okB2 FinalEos0.s7 FinalEos0.S7 = true
kernel_rfl FinalEos0.ok9 : FinalEos0.okB3 FinalEos0.s9 FinalEos0.S9 = true
kernel_rfl FinalEos0.halt1 : isHalt FinalEos0.s1.ctl = false
kernel_rfl FinalEos0.halt4 : isHalt FinalEos0.s4.ctl = false
kernel_rfl FinalEos0.halt7 : isHalt FinalEos0.s7.ctl = false
noncomputable def FinalEos0.fs1 : List Frame := FinalEos0.s2.stack.drop 1
noncomputable def FinalEos0.fs2 : List Frame := FinalEos0.s5.stack.drop 1
kernel_rfl FinalEos0.stack1 : FinalEos0.s2.stack = .e (.member kLength false) :: FinalEos0.fs1
kernel_rfl FinalEos0.stack2 : FinalEos0.s5.stack = .e (.member kLength false) :: FinalEos0.fs2
kernel_rfl FinalEos0.kind1 : (objOf FinalEos0.s2 2665).kind = .array (arrOf DEC.s0 2665 ++ [])
kernel_rfl FinalEos0.kind2 : (objOf FinalEos0.s5 2665).kind = .array (arrOf DEC.s0 2665 ++ [])
kernel_rfl FinalEos0.grow03 : Nat.ble FinalEos0.S0.tab.length FinalEos0.S3.tab.length = true
kernel_rfl FinalEos0.grow36 : Nat.ble FinalEos0.S3.tab.length FinalEos0.S6.tab.length = true
kernel_rfl FinalEos0.grow69 : Nat.ble FinalEos0.S6.tab.length FinalEos0.S9.tab.length = true
kernel_rfl FinalEos0.grow910 : Nat.ble FinalEos0.S9.tab.length FinalEos0.S10.tab.length = true
kernel_rfl FinalEos0.grow01 : Nat.ble FinalEos0.S0.tab.length FinalEos0.S1.tab.length = true
kernel_rfl FinalEos0.grow12 : Nat.ble FinalEos0.S1.tab.length FinalEos0.S2.tab.length = true
kernel_rfl FinalEos0.grow34 : Nat.ble FinalEos0.S3.tab.length FinalEos0.S4.tab.length = true
kernel_rfl FinalEos0.grow45 : Nat.ble FinalEos0.S4.tab.length FinalEos0.S5.tab.length = true
kernel_rfl FinalEos0.grow67 : Nat.ble FinalEos0.S6.tab.length FinalEos0.S7.tab.length = true
kernel_rfl FinalEos0.grow78 : Nat.ble FinalEos0.S7.tab.length FinalEos0.S8.tab.length = true
noncomputable def FinalEos0.vF : Val := match FinalEos0.s10.ctl with
  | .halt (.normal v) => v
  | _ => .undef
kernel_rfl FinalEos0.haltF : FinalEos0.s10.ctl = .halt (.normal FinalEos0.vF)
kernel_rfl FinalEos0.emit_get : FinalEos0.s10.heap.get 12504 = some (.obj (objOf FinalEos0.s10 12504))
kernel_rfl FinalEos0.emit_kind : (objOf FinalEos0.s10 12504).kind =
  .array (arrOf DEC.s0 12504 ++ [.num (.ref 79)])
kernel_rfl FinalEos0.cell : FinalEos0.s10.cell? 2590 = some (some (.obj 12504))
kernel_rfl FinalEos0.read : (mlxOf FinalEos0.s10.ffi).items.get 20157 = some (.ref 79)
kernel_rfl FinalEos0.fed : (mlxOf FinalEos0.s10.ffi).items.get 22538 = some (.ref DEC.tab0.length)
kernel_rfl FinalEos0.read_present : ((mlxOf FinalEos0.s10.ffi).nodes.get 20157).isSome = true
kernel_rfl FinalEos0.fed_present : ((mlxOf FinalEos0.s10.ffi).nodes.get 22538).isSome = true
kernel_rfl FinalEos0.tokens : (mlxOf FinalEos0.s10.ffi).tokens = []
kernel_rfl FinalEos0.token_var : nth? FinalEos0.S10.tab 79 = some (.var 14)
kernel_rfl FinalEos0.next_var : nth? FinalEos0.S10.tab DEC.tab0.length = some (.var 17)
noncomputable def FinalEos0.gF : Nat := match FinalEos0.s10.cell? 2589 with
  | some (some (.obj g)) => g
  | _ => 0
noncomputable def FinalEos0.wF : Nat := match ownW FinalEos0.s10 (.obj FinalEos0.gF) chars!"stats" with
  | some (.obj w) => w
  | _ => 0
kernel_rfl FinalEos0.stop_cell : FinalEos0.s10.cell? 2589 = some (some (.obj FinalEos0.gF))
kernel_rfl FinalEos0.stop_gen_frame : wideP FinalEos0.gF = none
kernel_rfl FinalEos0.stop_stats : ownW FinalEos0.s10 (.obj FinalEos0.gF) chars!"stats" = some (.obj FinalEos0.wF)
kernel_rfl FinalEos0.stop_stats_frame : wideP FinalEos0.wF = none
kernel_rfl FinalEos0.stop_reason : ownW FinalEos0.s10 (.obj FinalEos0.wF) chars!"finishReason" = some (.str chars!"stop")

theorem FinalEos0.stop (b0 : BSt) (NB : Nat) : StopAtW (Wd := fullWorldFb b0 NB) wideP addrPrompt FinalEos0.s10 :=
  ⟨by decide, FinalEos0.gF, FinalEos0.wF, FinalEos0.stop_cell, FinalEos0.stop_gen_frame,
    FinalEos0.stop_stats, FinalEos0.stop_stats_frame, FinalEos0.stop_reason⟩


end Host.Load.Run.Tpl
