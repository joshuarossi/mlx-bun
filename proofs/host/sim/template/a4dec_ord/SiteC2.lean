import host.sim.template.a4dec_ord.H0
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

/-! The compaction after the merge at call site 2 of chain `DEC_ord` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `DEC_ord.s10` (the stage's results at canonical places, its trace the call's) under `DEC_ord.kappa2` into the merged state
`DEC_ord.s9`. -/

def DEC_ord.pl2 : List Nat := []
def DEC_ord.nr2 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def DEC_ord.kd2 : RData :=
  ⟨3124247, 3124266, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   29440, 29441, 24920, 24920, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def DEC_ord.kappa2 : Map :=
  Conv.Map.compact 3124247 3124266 354 DEC_ord.pl2 (DEC_ord.nr2.map NumV.ref) DEC_ord.kd2.big
    DEC_ord.kd2.region DEC_ord.kd2.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def DEC_ord.cws2 : List Nat := []
noncomputable def DEC_ord.crs2 : List SymE := DEC_ord.nr2.map fun r => (nth? DEC_ord.S9.tab r).getD (.var 0)
noncomputable def DEC_ord.ctheta2 : Nat → SymE := Conv.compactθ DEC_ord.cws2 DEC_ord.crs2
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def DEC_ord.wrB2 : List Nat := [2665, 12504, 2673448]

kernel_rfl DEC_ord.ctab2 : DEC_ord.S10.tab = DEC_ord.S8.tab ++ DEC_ord.cws2.map SymE.var
kernel_rfl DEC_ord.ctrace2 : DEC_ord.s10.trace = DEC_ord.s8.trace
kernel_rfl DEC_ord.cnext2 : DEC_ord.s10.next = 3124247
kernel_rfl DEC_ord.ccounters2 : ((Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.next, (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.nnext) = (29440, 24920)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl DEC_ord.cqueue2 : (Host.Load.Layers.toLoad DEC_ord.s9.ffi).mlx.tokens = (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.tokens.map DEC_ord.kappa2.nv
kernel_rfl DEC_ord.ctokSupp2 : (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.tokens.all (bSN 354) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl DEC_ord.cclean2 : Conv.cleanListB 29440 131072 (fun r => Nat.ble 117760 r) DEC_ord.s10
    (DEC_ord.wrB2 ++ (List.range 0).map (3124247 + ·)) = true
kernel_rfl DEC_ord.cbigs2 : bigsOutB 29440 131072 (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx = true

end Host.Load.Run.Tpl
