import host.sim.template.a4pre_first_tail_x15_r0_body.H11
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

/-! The compaction after the merge at call site 36 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s363` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa36` into the merged state
`PRE_first_tail_x15_r0_body.s362`. -/

def PRE_first_tail_x15_r0_body.pl36 : List Nat := [2704815, 2703990, 2704821, 2704817, 2703992, 2704823]
def PRE_first_tail_x15_r0_body.nr36 : List Nat := [1652, 1651, 1627, 1635, 1640, 1645, 1650, 1624, 1625, 1626, 1633, 1634, 1622, 1629, 1630, 1631, 1632, 1628]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd36 : RData :=
  ⟨2703709, 2704858, Stage.setAll PTrie.nil [(2703703, 2704815), (2703704, 2703990), (2703705, 2704821), (2703706, 2704817), (2703707, 2703992), (2703708, 2704823)], Stage.setAll PTrie.nil [(18924, 18950), (18925, 18928), (18926, 18951)],
   18927, 18952, 16016, 16016, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1622, .ref 1652), (1623, .ref 1651), (1624, .ref 1627), (1625, .ref 1635), (1626, .ref 1640), (1627, .ref 1645), (1628, .ref 1650), (1629, .ref 1624), (1630, .ref 1625), (1631, .ref 1626), (1632, .ref 1633), (1633, .ref 1634), (1634, .ref 1622), (1635, .ref 1629), (1636, .ref 1630), (1637, .ref 1631), (1638, .ref 1632), (1639, .ref 1628)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa36 : Map :=
  Conv.Map.compact 2703703 2704858 1622 PRE_first_tail_x15_r0_body.pl36 (PRE_first_tail_x15_r0_body.nr36.map NumV.ref) PRE_first_tail_x15_r0_body.kd36.big
    PRE_first_tail_x15_r0_body.kd36.region PRE_first_tail_x15_r0_body.kd36.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws36 : List Nat := [1622, 1623, 1624, 1625, 1626, 1627, 1628, 1629, 1630, 1631, 1632, 1633, 1634, 1635, 1636, 1637, 1638, 1639]
noncomputable def PRE_first_tail_x15_r0_body.crs36 : List SymE := PRE_first_tail_x15_r0_body.nr36.map fun r => (nth? PRE_first_tail_x15_r0_body.S362.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta36 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws36 PRE_first_tail_x15_r0_body.crs36
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB36 : List Nat := [2665, 2672393, 2673467, 2702877, 2703422, 2703678]

kernel_rfl PRE_first_tail_x15_r0_body.ctab36 : PRE_first_tail_x15_r0_body.S363.tab = PRE_first_tail_x15_r0_body.S361.tab ++ PRE_first_tail_x15_r0_body.cws36.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace36 : PRE_first_tail_x15_r0_body.s363.trace = PRE_first_tail_x15_r0_body.s361.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext36 : PRE_first_tail_x15_r0_body.s363.next = 2703709
kernel_rfl PRE_first_tail_x15_r0_body.ccounters36 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.nnext) = (18927, 16016)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue36 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s362.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa36.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp36 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.tokens.all (bSN 1640) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean36 : Conv.cleanListB 18927 131072 (fun r => Nat.ble 75708 r) PRE_first_tail_x15_r0_body.s363
    (PRE_first_tail_x15_r0_body.wrB36 ++ (List.range 6).map (2703703 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs36 : bigsOutB 18927 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx = true

end Host.Load.Run.Tpl
