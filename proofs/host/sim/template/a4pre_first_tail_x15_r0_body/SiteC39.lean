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

/-! The compaction after the merge at call site 39 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s358` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa39` into the merged state
`PRE_first_tail_x15_r0_body.s357`. -/

def PRE_first_tail_x15_r0_body.pl39 : List Nat := [2707071, 2706246, 2707077, 2707073, 2706248, 2707079]
def PRE_first_tail_x15_r0_body.nr39 : List Nat := [1781, 1780, 1756, 1764, 1769, 1774, 1779, 1753, 1754, 1755, 1762, 1763, 1751, 1758, 1759, 1760, 1761, 1757]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd39 : RData :=
  ⟨2705965, 2707114, Stage.setAll PTrie.nil [(2705959, 2707071), (2705960, 2706246), (2705961, 2707077), (2705962, 2707073), (2705963, 2706248), (2705964, 2707079)], Stage.setAll PTrie.nil [(18981, 19007), (18982, 18985), (18983, 19008)],
   18984, 19009, 16079, 16079, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1751, .ref 1781), (1752, .ref 1780), (1753, .ref 1756), (1754, .ref 1764), (1755, .ref 1769), (1756, .ref 1774), (1757, .ref 1779), (1758, .ref 1753), (1759, .ref 1754), (1760, .ref 1755), (1761, .ref 1762), (1762, .ref 1763), (1763, .ref 1751), (1764, .ref 1758), (1765, .ref 1759), (1766, .ref 1760), (1767, .ref 1761), (1768, .ref 1757)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa39 : Map :=
  Conv.Map.compact 2705959 2707114 1751 PRE_first_tail_x15_r0_body.pl39 (PRE_first_tail_x15_r0_body.nr39.map NumV.ref) PRE_first_tail_x15_r0_body.kd39.big
    PRE_first_tail_x15_r0_body.kd39.region PRE_first_tail_x15_r0_body.kd39.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws39 : List Nat := [1676, 1677, 1678, 1679, 1680, 1681, 1682, 1683, 1684, 1685, 1686, 1687, 1688, 1689, 1690, 1691, 1692, 1693]
noncomputable def PRE_first_tail_x15_r0_body.crs39 : List SymE := PRE_first_tail_x15_r0_body.nr39.map fun r => (nth? PRE_first_tail_x15_r0_body.S357.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta39 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws39 PRE_first_tail_x15_r0_body.crs39
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB39 : List Nat := [2665, 2672398, 2673467, 2705133, 2705678, 2705934]

kernel_rfl PRE_first_tail_x15_r0_body.ctab39 : PRE_first_tail_x15_r0_body.S358.tab = PRE_first_tail_x15_r0_body.S356.tab ++ PRE_first_tail_x15_r0_body.cws39.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace39 : PRE_first_tail_x15_r0_body.s358.trace = PRE_first_tail_x15_r0_body.s356.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext39 : PRE_first_tail_x15_r0_body.s358.next = 2705965
kernel_rfl PRE_first_tail_x15_r0_body.ccounters39 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s358.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s358.ffi).mlx.nnext) = (18984, 16079)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue39 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s357.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s358.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa39.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp39 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s358.ffi).mlx.tokens.all (bSN 1769) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean39 : Conv.cleanListB 18984 131072 (fun r => Nat.ble 75936 r) PRE_first_tail_x15_r0_body.s358
    (PRE_first_tail_x15_r0_body.wrB39 ++ (List.range 6).map (2705959 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs39 : bigsOutB 18984 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s358.ffi).mlx = true

end Host.Load.Run.Tpl
