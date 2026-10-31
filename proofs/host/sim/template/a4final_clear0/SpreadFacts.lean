import host.sim.template.a4final_clear0.SpreadH0
import host.sim.template.a4final_clear0.OkB
import host.sim.template.a4final_clear0.Bridge
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Compose
noncomputable abbrev FinalClear0.spPre := FinalClear0Sp.s1
noncomputable abbrev FinalClear0.spPreSrv := FinalClear0Sp.S1
noncomputable def FinalClear0.spOpen := FinalClear0.spPre.ret (.obj 2665)
noncomputable abbrev FinalClear0.spOpenSrv := FinalClear0.spPreSrv
kernel_rfl FinalClear0.spRun : runOk FinalClear0.F FinalClear0.okB2 32 FinalClear0.s6 FinalClear0.S6 =
  some (FinalClear0.spPre, FinalClear0.spPreSrv)
kernel_rfl FinalClear0.spInto : interpS (step FinalClear0.F FinalClear0.spPre).run FinalClear0.spPreSrv =
  some (FinalClear0.spOpen, FinalClear0.spOpenSrv)
noncomputable def FinalClear0.spEnv : Env := match FinalClear0.spOpen.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def FinalClear0.spFs : List Frame := FinalClear0.spOpen.stack.drop 1
noncomputable def FinalClear0.spExpr : Expr := match FinalClear0.spOpen.stack with
  | .l (.spread _ (.spread e :: _) _) :: _ => e
  | _ => .id []
noncomputable def FinalClear0.spName : List Char := match FinalClear0.s7.ctl with
  | .ev (.id n) _ => n
  | _ => []
noncomputable def FinalClear0.spCell : Nat := (lookupEnv FinalClear0.spName FinalClear0.spEnv).getD 0
kernel_rfl FinalClear0.spOk : FinalClear0.okB2 FinalClear0.spPre FinalClear0.spPreSrv = true
kernel_rfl FinalClear0.spHalt : isHalt FinalClear0.spPre.ctl = false
kernel_rfl FinalClear0.spCtl : FinalClear0.spOpen.ctl = .ret (.obj 2665)
kernel_rfl FinalClear0.spStack : FinalClear0.spOpen.stack =
  .l (.spread [] [.spread FinalClear0.spExpr] FinalClear0.spEnv) :: FinalClear0.spFs
kernel_rfl FinalClear0.spOpenStep : interpS (step FinalClear0.F FinalClear0.spOpen).run FinalClear0.spOpenSrv =
  some (FinalClear0.s7, FinalClear0.S7)
kernel_rfl FinalClear0.spIdCtl : FinalClear0.s7.ctl = .ev (.id FinalClear0.spName) FinalClear0.spEnv
kernel_rfl FinalClear0.spLookup : lookupEnv FinalClear0.spName FinalClear0.spEnv = some FinalClear0.spCell
kernel_rfl FinalClear0.spCellVal : FinalClear0.s7.cell? FinalClear0.spCell = some (some (.obj 2673448))
kernel_rfl FinalClear0.spCellNoW : Nat.beq FinalClear0.spCell 4910 = false
kernel_rfl FinalClear0.spCellNoFr : [2673448, 12504, 2665, 4910].contains FinalClear0.spCell = false
kernel_rfl FinalClear0.spCloseStack : FinalClear0.s8.stack =
  .l (.spread ([] ++ (arrOf DEC.s0 2665).reverse) [] FinalClear0.envA3) :: FinalClear0.fsA3
kernel_rfl FinalClear0.spGrowPre : Nat.ble FinalClear0.S6.tab.length FinalClear0.spPreSrv.tab.length = true
kernel_rfl FinalClear0.spGrowOpen : Nat.ble FinalClear0.spPreSrv.tab.length FinalClear0.spOpenSrv.tab.length = true
kernel_rfl FinalClear0.spGrowId : Nat.ble FinalClear0.spOpenSrv.tab.length FinalClear0.S7.tab.length = true
kernel_rfl FinalClear0.spGrowClose : Nat.ble FinalClear0.S7.tab.length FinalClear0.S8.tab.length = true
kernel_rfl FinalClear0.spGrowPost : Nat.ble FinalClear0.S8.tab.length FinalClear0.S9.tab.length = true
end Host.Load.Run.Tpl
