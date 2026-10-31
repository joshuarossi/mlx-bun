import host.sim.template.a4final_clear1.SpreadH0
import host.sim.template.a4final_clear1.OkB
import host.sim.template.a4final_clear1.Bridge
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Compose
noncomputable abbrev FinalClear1.spPre := FinalClear1Sp.s1
noncomputable abbrev FinalClear1.spPreSrv := FinalClear1Sp.S1
noncomputable def FinalClear1.spOpen := FinalClear1.spPre.ret (.obj 2665)
noncomputable abbrev FinalClear1.spOpenSrv := FinalClear1.spPreSrv
kernel_rfl FinalClear1.spRun : runOk FinalClear1.F FinalClear1.okB2 32 FinalClear1.s6 FinalClear1.S6 =
  some (FinalClear1.spPre, FinalClear1.spPreSrv)
kernel_rfl FinalClear1.spInto : interpS (step FinalClear1.F FinalClear1.spPre).run FinalClear1.spPreSrv =
  some (FinalClear1.spOpen, FinalClear1.spOpenSrv)
noncomputable def FinalClear1.spEnv : Env := match FinalClear1.spOpen.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def FinalClear1.spFs : List Frame := FinalClear1.spOpen.stack.drop 1
noncomputable def FinalClear1.spExpr : Expr := match FinalClear1.spOpen.stack with
  | .l (.spread _ (.spread e :: _) _) :: _ => e
  | _ => .id []
noncomputable def FinalClear1.spName : List Char := match FinalClear1.s7.ctl with
  | .ev (.id n) _ => n
  | _ => []
noncomputable def FinalClear1.spCell : Nat := (lookupEnv FinalClear1.spName FinalClear1.spEnv).getD 0
kernel_rfl FinalClear1.spOk : FinalClear1.okB2 FinalClear1.spPre FinalClear1.spPreSrv = true
kernel_rfl FinalClear1.spHalt : isHalt FinalClear1.spPre.ctl = false
kernel_rfl FinalClear1.spCtl : FinalClear1.spOpen.ctl = .ret (.obj 2665)
kernel_rfl FinalClear1.spStack : FinalClear1.spOpen.stack =
  .l (.spread [] [.spread FinalClear1.spExpr] FinalClear1.spEnv) :: FinalClear1.spFs
kernel_rfl FinalClear1.spOpenStep : interpS (step FinalClear1.F FinalClear1.spOpen).run FinalClear1.spOpenSrv =
  some (FinalClear1.s7, FinalClear1.S7)
kernel_rfl FinalClear1.spIdCtl : FinalClear1.s7.ctl = .ev (.id FinalClear1.spName) FinalClear1.spEnv
kernel_rfl FinalClear1.spLookup : lookupEnv FinalClear1.spName FinalClear1.spEnv = some FinalClear1.spCell
kernel_rfl FinalClear1.spCellVal : FinalClear1.s7.cell? FinalClear1.spCell = some (some (.obj 2673448))
kernel_rfl FinalClear1.spCellNoW : Nat.beq FinalClear1.spCell 4910 = false
kernel_rfl FinalClear1.spCellNoFr : [2673448, 12504, 2665, 4910].contains FinalClear1.spCell = false
kernel_rfl FinalClear1.spCloseStack : FinalClear1.s8.stack =
  .l (.spread ([] ++ (arrOf DEC.s0 2665).reverse) [] FinalClear1.envA3) :: FinalClear1.fsA3
kernel_rfl FinalClear1.spGrowPre : Nat.ble FinalClear1.S6.tab.length FinalClear1.spPreSrv.tab.length = true
kernel_rfl FinalClear1.spGrowOpen : Nat.ble FinalClear1.spPreSrv.tab.length FinalClear1.spOpenSrv.tab.length = true
kernel_rfl FinalClear1.spGrowId : Nat.ble FinalClear1.spOpenSrv.tab.length FinalClear1.S7.tab.length = true
kernel_rfl FinalClear1.spGrowClose : Nat.ble FinalClear1.S7.tab.length FinalClear1.S8.tab.length = true
kernel_rfl FinalClear1.spGrowPost : Nat.ble FinalClear1.S8.tab.length FinalClear1.S9.tab.length = true
end Host.Load.Run.Tpl
