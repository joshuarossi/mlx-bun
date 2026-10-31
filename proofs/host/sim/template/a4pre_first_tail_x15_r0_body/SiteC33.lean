import host.sim.template.a4pre_first_tail_x15_r0_body.H9
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

/-! The compaction after the merge at call site 33 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s304` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa33` into the merged state
`PRE_first_tail_x15_r0_body.s303`. -/

def PRE_first_tail_x15_r0_body.pl33 : List Nat := [2701682, 2701518, 2701570, 2701683, 2701684, 2701520, 2701572, 2701681, 2701680, 2701679, 2701678, 2701672, 2701623, 2701674, 2701625]
def PRE_first_tail_x15_r0_body.nr33 : List Nat := [1508, 1509, 1505, 1511, 1507, 1515, 1516, 1513, 1514]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd33 : RData :=
  ⟨2701335, 2701685, Stage.setAll PTrie.nil [(2701320, 2701682), (2701321, 2701518), (2701322, 2701570), (2701323, 2701683), (2701324, 2701684), (2701325, 2701520), (2701326, 2701572), (2701327, 2701681), (2701328, 2701680), (2701329, 2701679), (2701330, 2701678), (2701331, 2701672), (2701332, 2701623), (2701333, 2701674), (2701334, 2701625)], Stage.setAll PTrie.nil [(18865, 18867), (18866, 18868), (18867, 18870), (18868, 18869)],
   18869, 18871, 15956, 15956, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1500, .ref 1508), (1501, .ref 1509), (1502, .ref 1505), (1503, .ref 1511), (1504, .ref 1507), (1505, .ref 1515), (1506, .ref 1516), (1507, .ref 1513), (1508, .ref 1514)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa33 : Map :=
  Conv.Map.compact 2701320 2701685 1500 PRE_first_tail_x15_r0_body.pl33 (PRE_first_tail_x15_r0_body.nr33.map NumV.ref) PRE_first_tail_x15_r0_body.kd33.big
    PRE_first_tail_x15_r0_body.kd33.region PRE_first_tail_x15_r0_body.kd33.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws33 : List Nat := [1571, 1572, 1573, 1574, 1575, 1576, 1577, 1578, 1579]
noncomputable def PRE_first_tail_x15_r0_body.crs33 : List SymE := PRE_first_tail_x15_r0_body.nr33.map fun r => (nth? PRE_first_tail_x15_r0_body.S303.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta33 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws33 PRE_first_tail_x15_r0_body.crs33
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB33 : List Nat := [2665, 2672384, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab33 : PRE_first_tail_x15_r0_body.S304.tab = PRE_first_tail_x15_r0_body.S302.tab ++ PRE_first_tail_x15_r0_body.cws33.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace33 : PRE_first_tail_x15_r0_body.s304.trace = PRE_first_tail_x15_r0_body.s302.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext33 : PRE_first_tail_x15_r0_body.s304.next = 2701335
kernel_rfl PRE_first_tail_x15_r0_body.ccounters33 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nnext) = (18869, 15956)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue33 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s303.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa33.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp33 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.tokens.all (bSN 1509) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean33 : Conv.cleanListB 18869 131072 (fun r => Nat.ble 75476 r) PRE_first_tail_x15_r0_body.s304
    (PRE_first_tail_x15_r0_body.wrB33 ++ (List.range 15).map (2701320 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs33 : bigsOutB 18869 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx = true

end Host.Load.Run.Tpl
