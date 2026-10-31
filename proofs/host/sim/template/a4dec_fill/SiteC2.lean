import host.sim.template.a4dec_fill.H0
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

/-! The compaction after the merge at call site 2 of chain `DEC_fill` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `DEC_fill.s10` (the stage's results at canonical places, its trace the call's) under `DEC_fill.kappa2` into the merged state
`DEC_fill.s9`. -/

def DEC_fill.pl2 : List Nat := []
def DEC_fill.nr2 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def DEC_fill.kd2 : RData :=
  ⟨3124247, 3124266, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   29440, 29441, 24888, 24888, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def DEC_fill.kappa2 : Map :=
  Conv.Map.compact 3124247 3124266 290 DEC_fill.pl2 (DEC_fill.nr2.map NumV.ref) DEC_fill.kd2.big
    DEC_fill.kd2.region DEC_fill.kd2.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def DEC_fill.cws2 : List Nat := []
noncomputable def DEC_fill.crs2 : List SymE := DEC_fill.nr2.map fun r => (nth? DEC_fill.S9.tab r).getD (.var 0)
noncomputable def DEC_fill.ctheta2 : Nat → SymE := Conv.compactθ DEC_fill.cws2 DEC_fill.crs2
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def DEC_fill.wrB2 : List Nat := [2665, 12504, 2673448]

kernel_rfl DEC_fill.ctab2 : DEC_fill.S10.tab = DEC_fill.S8.tab ++ DEC_fill.cws2.map SymE.var
kernel_rfl DEC_fill.ctrace2 : DEC_fill.s10.trace = DEC_fill.s8.trace
kernel_rfl DEC_fill.cnext2 : DEC_fill.s10.next = 3124247
kernel_rfl DEC_fill.ccounters2 : ((Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.next, (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.nnext) = (29440, 24888)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl DEC_fill.cqueue2 : (Host.Load.Layers.toLoad DEC_fill.s9.ffi).mlx.tokens = (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.tokens.map DEC_fill.kappa2.nv
kernel_rfl DEC_fill.ctokSupp2 : (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.tokens.all (bSN 290) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl DEC_fill.cclean2 : Conv.cleanListB 29440 131072 (fun r => Nat.ble 117760 r) DEC_fill.s10
    (DEC_fill.wrB2 ++ (List.range 0).map (3124247 + ·)) = true
kernel_rfl DEC_fill.cbigs2 : bigsOutB 29440 131072 (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx = true

end Host.Load.Run.Tpl
