import host.sim.template.a4dec_clearFill.H0
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 2 of chain `DEC_clearFill` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `DEC_clearFill.s10` (the stage's results at canonical places, its trace the call's) under `DEC_clearFill.kappa2` into the merged state
`DEC_clearFill.s9`. -/

def DEC_clearFill.pl2 : List Nat := []
def DEC_clearFill.nr2 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def DEC_clearFill.kd2 : RData :=
  ⟨3124248, 3124267, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   29440, 29441, 24888, 24888, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def DEC_clearFill.kappa2 : Map :=
  Conv.Map.compact 3124248 3124267 290 DEC_clearFill.pl2 (DEC_clearFill.nr2.map NumV.ref) DEC_clearFill.kd2.big
    DEC_clearFill.kd2.region DEC_clearFill.kd2.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def DEC_clearFill.cws2 : List Nat := []
noncomputable def DEC_clearFill.crs2 : List SymE := DEC_clearFill.nr2.map fun r => (nth? DEC_clearFill.S9.tab r).getD (.var 0)
noncomputable def DEC_clearFill.ctheta2 : Nat → SymE := Conv.compactθ DEC_clearFill.cws2 DEC_clearFill.crs2
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def DEC_clearFill.wrB2 : List Nat := [2665, 12504, 2673448]

kernel_rfl DEC_clearFill.ctab2 : DEC_clearFill.S10.tab = DEC_clearFill.S8.tab ++ DEC_clearFill.cws2.map SymE.var
kernel_rfl DEC_clearFill.ctrace2 : DEC_clearFill.s10.trace = DEC_clearFill.s8.trace
kernel_rfl DEC_clearFill.cnext2 : DEC_clearFill.s10.next = 3124248
kernel_rfl DEC_clearFill.ccounters2 : ((Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx.next, (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx.nnext) = (29440, 24888)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl DEC_clearFill.cqueue2 : (Host.Load.Layers.toLoad DEC_clearFill.s9.ffi).mlx.tokens = (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx.tokens.map DEC_clearFill.kappa2.nv
kernel_rfl DEC_clearFill.ctokSupp2 : (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx.tokens.all (bSN 290) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl DEC_clearFill.cclean2 : Conv.cleanListB 29440 131072 (fun r => Nat.ble 117760 r) DEC_clearFill.s10
    (DEC_clearFill.wrB2 ++ (List.range 0).map (3124248 + ·)) = true
kernel_rfl DEC_clearFill.cbigs2 : bigsOutB 29440 131072 (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx = true

end Host.Load.Run.Tpl
