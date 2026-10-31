import host.sim.template.a4eos_cut_ctx.SpreadData
import host.sim.template.a4eos_cut_ctx.Bridge
import host.sim.template.a4eos_cut_ctx.Run
import host.sim.template.a4eos_cut_ctx.OkB
import host.sim.compose.a4b.GraphStart
import host.sim.compose.Seg
import host.sim.template.EndGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Compose Host.Ts.Sim.Template Host.Ts.Sim.Full
open Host.Load.Run.Prompt

kernel_rfl EOSCutCtx.start_exact : EOSCutCtx.start = EOSCutCtxRest.s0
kernel_rfl EOSCutCtx.tab_start : EOSCutCtx.inputSrv.tab = EOSCutCtxRest.S0.tab
kernel_rfl EOSCutCtx.oracle_exact : EOSCutCtxRest.S0.oracle = EOSCutCtxRest.O
kernel_rfl EOSCutCtx.oracle2 : EOSCutCtxRest.S5.oracle = []
kernel_rfl EOSCutCtx.oracle3 : EOSCutCtxRest.S6.oracle = []
kernel_rfl EOSCutCtx.oracle4 : EOSCutCtxRest.S7.oracle = []
kernel_rfl EOSCutCtx.okA0 : EOSCutCtxRest.okB1 EOSCutCtxRest.s3 EOSCutCtxRest.S3 = true
kernel_rfl EOSCutCtx.ctlA : EOSCutCtxRest.s5.ctl = .ret (.obj 2673448)
noncomputable def EOSCutCtx.accA : List Val := match EOSCutCtxRest.s5.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def EOSCutCtx.envA : Env := match EOSCutCtxRest.s5.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def EOSCutCtx.fsA : List Frame := EOSCutCtxRest.s5.stack.drop 1
kernel_rfl EOSCutCtx.stackA : EOSCutCtxRest.s5.stack = .l (.spread EOSCutCtx.accA [] EOSCutCtx.envA) :: EOSCutCtx.fsA
kernel_rfl EOSCutCtx.roomA_check : Nat.blt (EOSCutCtxRest.s5.next + margin) Sim.bound = true
kernel_rfl EOSCutCtx.arrA : (EOSCutCtxRest.s5.heap.get aArrayProto).isSome = true
kernel_rfl EOSCutCtx.newA : EOSCutCtxRest.s5.next = 3123590
kernel_rfl EOSCutCtx.okB0_after : EOSCutCtxRest.okB2 EOSCutCtxRest.s6 EOSCutCtxRest.S6 = true
noncomputable def EOSCutCtx.vF : Val := match EOSCutCtxRest.s7.ctl with
  | .halt (.normal v) => v
  | _ => .undef
kernel_rfl EOSCutCtx.haltF : EOSCutCtxRest.s7.ctl = .halt (.normal EOSCutCtx.vF)
kernel_rfl EOSCutCtx.emit_get : EOSCutCtxRest.s7.heap.get 12504 = some (.obj (objOf EOSCutCtxRest.s7 12504))
kernel_rfl EOSCutCtx.emit_kind : (objOf EOSCutCtxRest.s7 12504).kind = .array (arrOf DEC.s0 12504 ++ [])
kernel_rfl EOSCutCtx.cell : EOSCutCtxRest.s7.cell? 2590 = some (some (.obj 12504))
noncomputable def EOSCutCtx.gF : Nat := match EOSCutCtxRest.s7.cell? 2589 with
  | some (some (.obj g)) => g
  | _ => 0
noncomputable def EOSCutCtx.wF : Nat := match ownW EOSCutCtxRest.s7 (.obj EOSCutCtx.gF) chars!"stats" with
  | some (.obj w) => w
  | _ => 0
kernel_rfl EOSCutCtx.stop_cell : EOSCutCtxRest.s7.cell? 2589 = some (some (.obj EOSCutCtx.gF))
kernel_rfl EOSCutCtx.stop_gen_frame : wideP EOSCutCtx.gF = none
kernel_rfl EOSCutCtx.stop_stats : ownW EOSCutCtxRest.s7 (.obj EOSCutCtx.gF) chars!"stats" = some (.obj EOSCutCtx.wF)
kernel_rfl EOSCutCtx.stop_stats_frame : wideP EOSCutCtx.wF = none
kernel_rfl EOSCutCtx.stop_reason : ownW EOSCutCtxRest.s7 (.obj EOSCutCtx.wF) chars!"finishReason" = some (.str chars!"stop")

theorem EOSCutCtx.stop (b0 : BSt) (NB : Nat) : StopAtW (Wd := fullWorldFb b0 NB) wideP addrPrompt EOSCutCtxRest.s7 :=
  ⟨by decide, EOSCutCtx.gF, EOSCutCtx.wF, EOSCutCtx.stop_cell, EOSCutCtx.stop_gen_frame,
    EOSCutCtx.stop_stats, EOSCutCtx.stop_stats_frame, EOSCutCtx.stop_reason⟩

kernel_rfl EOSCutCtx.read : (mlxOf EOSCutCtxRest.s7.ffi).items.get 20157 = some (.ref 79)
kernel_rfl EOSCutCtx.read_present : ((mlxOf EOSCutCtxRest.s7.ffi).nodes.get 20157).isSome = true
kernel_rfl EOSCutCtx.tokens : (mlxOf EOSCutCtxRest.s7.ffi).tokens = []
kernel_rfl EOSCutCtx.token_var : nth? EOSCutCtxRest.S7.tab 79 = some (.var 14)

noncomputable def EOSCutCtx.fsLen2 : List Frame := EOSCutCtxRest.s2.stack.drop 1
kernel_rfl EOSCutCtx.stackLen2 : EOSCutCtxRest.s2.stack = .e (.member kLength false) :: EOSCutCtx.fsLen2
kernel_rfl EOSCutCtx.kindLen2 : (objOf EOSCutCtxRest.s2 2665).kind = .array (arrOf DEC.s0 2665 ++ [])
kernel_rfl EOSCutCtx.okRest0 : EOSCutCtxRest.okB0 EOSCutCtxRest.s0 EOSCutCtxRest.S0 = true
kernel_rfl EOSCutCtx.okLenPre2 : EOSCutCtxRest.okB0 EOSCutCtxRest.s1 EOSCutCtxRest.S1 = true
kernel_rfl EOSCutCtx.haltLenPre2 : isHalt EOSCutCtxRest.s1.ctl = false
kernel_rfl EOSCutCtx.oracleLen2 : EOSCutCtxRest.S3.oracle = []
kernel_rfl EOSCutCtx.prefixGrow2 : Nat.ble EOSCutCtxRest.S0.tab.length EOSCutCtxRest.S1.tab.length = true
kernel_rfl EOSCutCtx.stepGrow2 : Nat.ble EOSCutCtxRest.S1.tab.length EOSCutCtxRest.S2.tab.length = true
kernel_rfl EOSCutCtx.lenGrow2 : Nat.ble EOSCutCtxRest.S0.tab.length EOSCutCtxRest.S3.tab.length = true
kernel_rfl EOSCutCtx.fullGrow2 : Nat.ble EOSCutCtxRest.S0.tab.length EOSCutCtxRest.S7.tab.length = true

noncomputable def EOSCutCtx.spEnv : Env := match EOSCutCtx.spOpen.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def EOSCutCtx.spFs : List Frame := EOSCutCtx.spOpen.stack.drop 1
noncomputable def EOSCutCtx.spExpr : Expr := match EOSCutCtx.spOpen.stack with
  | .l (.spread _ (.spread e :: _) _) :: _ => e
  | _ => .id []
noncomputable def EOSCutCtx.spName : List Char := match EOSCutCtxRest.s4.ctl with
  | .ev (.id n) _ => n
  | _ => []
noncomputable def EOSCutCtx.spCell : Nat := (lookupEnv EOSCutCtx.spName EOSCutCtx.spEnv).getD 0
kernel_rfl EOSCutCtx.spOk : EOSCutCtxRest.okB1 EOSCutCtx.spPre EOSCutCtx.spPreSrv = true
kernel_rfl EOSCutCtx.spHalt : isHalt EOSCutCtx.spPre.ctl = false
kernel_rfl EOSCutCtx.spCtl : EOSCutCtx.spOpen.ctl = .ret (.obj 2665)
kernel_rfl EOSCutCtx.spStack : EOSCutCtx.spOpen.stack =
  .l (.spread [] [.spread EOSCutCtx.spExpr] EOSCutCtx.spEnv) :: EOSCutCtx.spFs
kernel_rfl EOSCutCtx.spOpenStep : interpS (step EOSCutCtxRest.F EOSCutCtx.spOpen).run EOSCutCtx.spOpenSrv =
  some (EOSCutCtxRest.s4, EOSCutCtxRest.S4)
kernel_rfl EOSCutCtx.spIdCtl : EOSCutCtxRest.s4.ctl = .ev (.id EOSCutCtx.spName) EOSCutCtx.spEnv
kernel_rfl EOSCutCtx.spLookup : lookupEnv EOSCutCtx.spName EOSCutCtx.spEnv = some EOSCutCtx.spCell
kernel_rfl EOSCutCtx.spCellVal : EOSCutCtxRest.s4.cell? EOSCutCtx.spCell = some (some (.obj 2673448))
kernel_rfl EOSCutCtx.spCellNoW : Nat.beq EOSCutCtx.spCell 4910 = false
kernel_rfl EOSCutCtx.spCellNoFr : [2673448, 12504, 2665, 4910].contains EOSCutCtx.spCell = false
kernel_rfl EOSCutCtx.spCloseStack : EOSCutCtxRest.s5.stack =
  .l (.spread ([] ++ (arrOf DEC.s0 2665).reverse) [] EOSCutCtx.envA) :: EOSCutCtx.fsA
kernel_rfl EOSCutCtx.spGrowPre : Nat.ble EOSCutCtxRest.S3.tab.length EOSCutCtx.spPreSrv.tab.length = true
kernel_rfl EOSCutCtx.spGrowOpen : Nat.ble EOSCutCtx.spPreSrv.tab.length EOSCutCtx.spOpenSrv.tab.length = true
kernel_rfl EOSCutCtx.spGrowId : Nat.ble EOSCutCtx.spOpenSrv.tab.length EOSCutCtxRest.S4.tab.length = true
kernel_rfl EOSCutCtx.spGrowClose : Nat.ble EOSCutCtxRest.S4.tab.length EOSCutCtxRest.S5.tab.length = true
kernel_rfl EOSCutCtx.spGrowPost : Nat.ble EOSCutCtxRest.S5.tab.length EOSCutCtxRest.S6.tab.length = true
end Host.Load.Run.Tpl
