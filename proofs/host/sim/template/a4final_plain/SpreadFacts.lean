import host.sim.template.a4final_plain.SpreadH0
import host.sim.template.a4final_plain.OkB
import host.sim.template.a4final_plain.Bridge
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Compose
noncomputable abbrev FinalPlain.spPre := FinalPlainSp.s1
noncomputable abbrev FinalPlain.spPreSrv := FinalPlainSp.S1
noncomputable def FinalPlain.spOpen := FinalPlain.spPre.ret (.obj 2665)
noncomputable abbrev FinalPlain.spOpenSrv := FinalPlain.spPreSrv
kernel_rfl FinalPlain.spRun : runOk FinalPlain.F FinalPlain.okB2 32 FinalPlain.s6 FinalPlain.S6 =
  some (FinalPlain.spPre, FinalPlain.spPreSrv)
kernel_rfl FinalPlain.spInto : interpS (step FinalPlain.F FinalPlain.spPre).run FinalPlain.spPreSrv =
  some (FinalPlain.spOpen, FinalPlain.spOpenSrv)
noncomputable def FinalPlain.spEnv : Env := match FinalPlain.spOpen.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def FinalPlain.spFs : List Frame := FinalPlain.spOpen.stack.drop 1
noncomputable def FinalPlain.spExpr : Expr := match FinalPlain.spOpen.stack with
  | .l (.spread _ (.spread e :: _) _) :: _ => e
  | _ => .id []
noncomputable def FinalPlain.spName : List Char := match FinalPlain.s7.ctl with
  | .ev (.id n) _ => n
  | _ => []
noncomputable def FinalPlain.spCell : Nat := (lookupEnv FinalPlain.spName FinalPlain.spEnv).getD 0
kernel_rfl FinalPlain.spOk : FinalPlain.okB2 FinalPlain.spPre FinalPlain.spPreSrv = true
kernel_rfl FinalPlain.spHalt : isHalt FinalPlain.spPre.ctl = false
kernel_rfl FinalPlain.spCtl : FinalPlain.spOpen.ctl = .ret (.obj 2665)
kernel_rfl FinalPlain.spStack : FinalPlain.spOpen.stack =
  .l (.spread [] [.spread FinalPlain.spExpr] FinalPlain.spEnv) :: FinalPlain.spFs
kernel_rfl FinalPlain.spOpenStep : interpS (step FinalPlain.F FinalPlain.spOpen).run FinalPlain.spOpenSrv =
  some (FinalPlain.s7, FinalPlain.S7)
kernel_rfl FinalPlain.spIdCtl : FinalPlain.s7.ctl = .ev (.id FinalPlain.spName) FinalPlain.spEnv
kernel_rfl FinalPlain.spLookup : lookupEnv FinalPlain.spName FinalPlain.spEnv = some FinalPlain.spCell
kernel_rfl FinalPlain.spCellVal : FinalPlain.s7.cell? FinalPlain.spCell = some (some (.obj 2673448))
kernel_rfl FinalPlain.spCellNoW : Nat.beq FinalPlain.spCell 4910 = false
kernel_rfl FinalPlain.spCellNoFr : [2673448, 12504, 2665, 4910].contains FinalPlain.spCell = false
kernel_rfl FinalPlain.spCloseStack : FinalPlain.s8.stack =
  .l (.spread ([] ++ (arrOf DEC.s0 2665).reverse) [] FinalPlain.envA3) :: FinalPlain.fsA3
kernel_rfl FinalPlain.spGrowPre : Nat.ble FinalPlain.S6.tab.length FinalPlain.spPreSrv.tab.length = true
kernel_rfl FinalPlain.spGrowOpen : Nat.ble FinalPlain.spPreSrv.tab.length FinalPlain.spOpenSrv.tab.length = true
kernel_rfl FinalPlain.spGrowId : Nat.ble FinalPlain.spOpenSrv.tab.length FinalPlain.S7.tab.length = true
kernel_rfl FinalPlain.spGrowClose : Nat.ble FinalPlain.S7.tab.length FinalPlain.S8.tab.length = true
kernel_rfl FinalPlain.spGrowPost : Nat.ble FinalPlain.S8.tab.length FinalPlain.S9.tab.length = true
end Host.Load.Run.Tpl
