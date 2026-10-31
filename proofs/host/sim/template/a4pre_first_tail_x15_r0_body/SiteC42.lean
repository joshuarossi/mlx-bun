import host.sim.template.a4pre_first_tail_x15_r0_body.H12
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

/-! The compaction after the merge at call site 42 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s385` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa42` into the merged state
`PRE_first_tail_x15_r0_body.s384`. -/

def PRE_first_tail_x15_r0_body.pl42 : List Nat := [2709331, 2708506, 2709337, 2709333, 2708508, 2709339]
def PRE_first_tail_x15_r0_body.nr42 : List Nat := [1910, 1909, 1885, 1893, 1898, 1903, 1908, 1882, 1883, 1884, 1891, 1892, 1880, 1887, 1888, 1889, 1890, 1886]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd42 : RData :=
  ⟨2708225, 2709374, Stage.setAll PTrie.nil [(2708219, 2709331), (2708220, 2708506), (2708221, 2709337), (2708222, 2709333), (2708223, 2708508), (2708224, 2709339)], Stage.setAll PTrie.nil [(19038, 19064), (19039, 19042), (19040, 19065)],
   19041, 19066, 16142, 16142, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(1880, .ref 1910), (1881, .ref 1909), (1882, .ref 1885), (1883, .ref 1893), (1884, .ref 1898), (1885, .ref 1903), (1886, .ref 1908), (1887, .ref 1882), (1888, .ref 1883), (1889, .ref 1884), (1890, .ref 1891), (1891, .ref 1892), (1892, .ref 1880), (1893, .ref 1887), (1894, .ref 1888), (1895, .ref 1889), (1896, .ref 1890), (1897, .ref 1886)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa42 : Map :=
  Conv.Map.compact 2708219 2709374 1880 PRE_first_tail_x15_r0_body.pl42 (PRE_first_tail_x15_r0_body.nr42.map NumV.ref) PRE_first_tail_x15_r0_body.kd42.big
    PRE_first_tail_x15_r0_body.kd42.region PRE_first_tail_x15_r0_body.kd42.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws42 : List Nat := [1736, 1737, 1738, 1739, 1740, 1741, 1742, 1743, 1744, 1745, 1746, 1747, 1748, 1749, 1750, 1751, 1752, 1753]
noncomputable def PRE_first_tail_x15_r0_body.crs42 : List SymE := PRE_first_tail_x15_r0_body.nr42.map fun r => (nth? PRE_first_tail_x15_r0_body.S384.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta42 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws42 PRE_first_tail_x15_r0_body.crs42
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB42 : List Nat := [2665, 2672403, 2673467, 2707393, 2707938, 2708194]

kernel_rfl PRE_first_tail_x15_r0_body.ctab42 : PRE_first_tail_x15_r0_body.S385.tab = PRE_first_tail_x15_r0_body.S383.tab ++ PRE_first_tail_x15_r0_body.cws42.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace42 : PRE_first_tail_x15_r0_body.s385.trace = PRE_first_tail_x15_r0_body.s383.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext42 : PRE_first_tail_x15_r0_body.s385.next = 2708225
kernel_rfl PRE_first_tail_x15_r0_body.ccounters42 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx.nnext) = (19041, 16142)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue42 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s384.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa42.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp42 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx.tokens.all (bSN 1898) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean42 : Conv.cleanListB 19041 131072 (fun r => Nat.ble 76164 r) PRE_first_tail_x15_r0_body.s385
    (PRE_first_tail_x15_r0_body.wrB42 ++ (List.range 6).map (2708219 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs42 : bigsOutB 19041 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx = true

end Host.Load.Run.Tpl
