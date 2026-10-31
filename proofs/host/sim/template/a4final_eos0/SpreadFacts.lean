import host.sim.template.a4final_eos0.SpreadH0
import host.sim.template.a4final_eos0.OkB
import host.sim.template.a4final_eos0.Bridge
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Compose
noncomputable abbrev FinalEos0.spPre := FinalEos0Sp.s1
noncomputable abbrev FinalEos0.spPreSrv := FinalEos0Sp.S1
noncomputable def FinalEos0.spOpen := FinalEos0.spPre.ret (.obj 2665)
noncomputable abbrev FinalEos0.spOpenSrv := FinalEos0.spPreSrv
kernel_rfl FinalEos0.spRun : runOk FinalEos0.F FinalEos0.okB2 33 FinalEos0.s6 FinalEos0.S6 =
  some (FinalEos0.spPre, FinalEos0.spPreSrv)
kernel_rfl FinalEos0.spInto : interpS (step FinalEos0.F FinalEos0.spPre).run FinalEos0.spPreSrv =
  some (FinalEos0.spOpen, FinalEos0.spOpenSrv)
noncomputable def FinalEos0.spEnv : Env := match FinalEos0.spOpen.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def FinalEos0.spFs : List Frame := FinalEos0.spOpen.stack.drop 1
noncomputable def FinalEos0.spExpr : Expr := match FinalEos0.spOpen.stack with
  | .l (.spread _ (.spread e :: _) _) :: _ => e
  | _ => .id []
noncomputable def FinalEos0.spName : List Char := match FinalEos0.s7.ctl with
  | .ev (.id n) _ => n
  | _ => []
noncomputable def FinalEos0.spCell : Nat := (lookupEnv FinalEos0.spName FinalEos0.spEnv).getD 0
kernel_rfl FinalEos0.spOk : FinalEos0.okB2 FinalEos0.spPre FinalEos0.spPreSrv = true
kernel_rfl FinalEos0.spHalt : isHalt FinalEos0.spPre.ctl = false
kernel_rfl FinalEos0.spCtl : FinalEos0.spOpen.ctl = .ret (.obj 2665)
kernel_rfl FinalEos0.spStack : FinalEos0.spOpen.stack =
  .l (.spread [] [.spread FinalEos0.spExpr] FinalEos0.spEnv) :: FinalEos0.spFs
kernel_rfl FinalEos0.spOpenStep : interpS (step FinalEos0.F FinalEos0.spOpen).run FinalEos0.spOpenSrv =
  some (FinalEos0.s7, FinalEos0.S7)
kernel_rfl FinalEos0.spIdCtl : FinalEos0.s7.ctl = .ev (.id FinalEos0.spName) FinalEos0.spEnv
kernel_rfl FinalEos0.spLookup : lookupEnv FinalEos0.spName FinalEos0.spEnv = some FinalEos0.spCell
kernel_rfl FinalEos0.spCellVal : FinalEos0.s7.cell? FinalEos0.spCell = some (some (.obj 2673448))
kernel_rfl FinalEos0.spCellNoW : Nat.beq FinalEos0.spCell 4910 = false
kernel_rfl FinalEos0.spCellNoFr : [2673448, 12504, 2665, 4910].contains FinalEos0.spCell = false
kernel_rfl FinalEos0.spCloseStack : FinalEos0.s8.stack =
  .l (.spread ([] ++ (arrOf DEC.s0 2665).reverse) [] FinalEos0.envA3) :: FinalEos0.fsA3
kernel_rfl FinalEos0.spGrowPre : Nat.ble FinalEos0.S6.tab.length FinalEos0.spPreSrv.tab.length = true
kernel_rfl FinalEos0.spGrowOpen : Nat.ble FinalEos0.spPreSrv.tab.length FinalEos0.spOpenSrv.tab.length = true
kernel_rfl FinalEos0.spGrowId : Nat.ble FinalEos0.spOpenSrv.tab.length FinalEos0.S7.tab.length = true
kernel_rfl FinalEos0.spGrowClose : Nat.ble FinalEos0.S7.tab.length FinalEos0.S8.tab.length = true
kernel_rfl FinalEos0.spGrowPost : Nat.ble FinalEos0.S8.tab.length FinalEos0.S9.tab.length = true
end Host.Load.Run.Tpl
