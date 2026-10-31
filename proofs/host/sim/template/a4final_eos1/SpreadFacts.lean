import host.sim.template.a4final_eos1.SpreadH0
import host.sim.template.a4final_eos1.OkB
import host.sim.template.a4final_eos1.Bridge
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Compose
noncomputable abbrev FinalEos1.spPre := FinalEos1Sp.s1
noncomputable abbrev FinalEos1.spPreSrv := FinalEos1Sp.S1
noncomputable def FinalEos1.spOpen := FinalEos1.spPre.ret (.obj 2665)
noncomputable abbrev FinalEos1.spOpenSrv := FinalEos1.spPreSrv
kernel_rfl FinalEos1.spRun : runOk FinalEos1.F FinalEos1.okB2 33 FinalEos1.s6 FinalEos1.S6 =
  some (FinalEos1.spPre, FinalEos1.spPreSrv)
kernel_rfl FinalEos1.spInto : interpS (step FinalEos1.F FinalEos1.spPre).run FinalEos1.spPreSrv =
  some (FinalEos1.spOpen, FinalEos1.spOpenSrv)
noncomputable def FinalEos1.spEnv : Env := match FinalEos1.spOpen.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def FinalEos1.spFs : List Frame := FinalEos1.spOpen.stack.drop 1
noncomputable def FinalEos1.spExpr : Expr := match FinalEos1.spOpen.stack with
  | .l (.spread _ (.spread e :: _) _) :: _ => e
  | _ => .id []
noncomputable def FinalEos1.spName : List Char := match FinalEos1.s7.ctl with
  | .ev (.id n) _ => n
  | _ => []
noncomputable def FinalEos1.spCell : Nat := (lookupEnv FinalEos1.spName FinalEos1.spEnv).getD 0
kernel_rfl FinalEos1.spOk : FinalEos1.okB2 FinalEos1.spPre FinalEos1.spPreSrv = true
kernel_rfl FinalEos1.spHalt : isHalt FinalEos1.spPre.ctl = false
kernel_rfl FinalEos1.spCtl : FinalEos1.spOpen.ctl = .ret (.obj 2665)
kernel_rfl FinalEos1.spStack : FinalEos1.spOpen.stack =
  .l (.spread [] [.spread FinalEos1.spExpr] FinalEos1.spEnv) :: FinalEos1.spFs
kernel_rfl FinalEos1.spOpenStep : interpS (step FinalEos1.F FinalEos1.spOpen).run FinalEos1.spOpenSrv =
  some (FinalEos1.s7, FinalEos1.S7)
kernel_rfl FinalEos1.spIdCtl : FinalEos1.s7.ctl = .ev (.id FinalEos1.spName) FinalEos1.spEnv
kernel_rfl FinalEos1.spLookup : lookupEnv FinalEos1.spName FinalEos1.spEnv = some FinalEos1.spCell
kernel_rfl FinalEos1.spCellVal : FinalEos1.s7.cell? FinalEos1.spCell = some (some (.obj 2673448))
kernel_rfl FinalEos1.spCellNoW : Nat.beq FinalEos1.spCell 4910 = false
kernel_rfl FinalEos1.spCellNoFr : [2673448, 12504, 2665, 4910].contains FinalEos1.spCell = false
kernel_rfl FinalEos1.spCloseStack : FinalEos1.s8.stack =
  .l (.spread ([] ++ (arrOf DEC.s0 2665).reverse) [] FinalEos1.envA3) :: FinalEos1.fsA3
kernel_rfl FinalEos1.spGrowPre : Nat.ble FinalEos1.S6.tab.length FinalEos1.spPreSrv.tab.length = true
kernel_rfl FinalEos1.spGrowOpen : Nat.ble FinalEos1.spPreSrv.tab.length FinalEos1.spOpenSrv.tab.length = true
kernel_rfl FinalEos1.spGrowId : Nat.ble FinalEos1.spOpenSrv.tab.length FinalEos1.S7.tab.length = true
kernel_rfl FinalEos1.spGrowClose : Nat.ble FinalEos1.S7.tab.length FinalEos1.S8.tab.length = true
kernel_rfl FinalEos1.spGrowPost : Nat.ble FinalEos1.S8.tab.length FinalEos1.S9.tab.length = true
end Host.Load.Run.Tpl
