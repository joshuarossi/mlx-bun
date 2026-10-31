import host.sim.template.a4pre_first_tail_x15_r0_body.H14
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

/-! The compaction after the merge at call site 45 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s449` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa45` into the merged state
`PRE_first_tail_x15_r0_body.s448`. -/

def PRE_first_tail_x15_r0_body.pl45 : List Nat := [2711102, 2710938, 2710990, 2711103, 2711104, 2710940, 2710992, 2711101, 2711100, 2711099, 2711098, 2711092, 2711043, 2711094, 2711045]
def PRE_first_tail_x15_r0_body.nr45 : List Nat := [2021, 2022, 2018, 2024, 2020, 2028, 2029, 2026, 2027]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd45 : RData :=
  ⟨2710755, 2711105, Stage.setAll PTrie.nil [(2710740, 2711102), (2710741, 2710938), (2710742, 2710990), (2710743, 2711103), (2710744, 2711104), (2710745, 2710940), (2710746, 2710992), (2710747, 2711101), (2710748, 2711100), (2710749, 2711099), (2710750, 2711098), (2710751, 2711092), (2710752, 2711043), (2710753, 2711094), (2710754, 2711045)], Stage.setAll PTrie.nil [(19101, 19103), (19102, 19104), (19103, 19106), (19104, 19105)],
   19105, 19107, 16193, 16193, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2013, .ref 2021), (2014, .ref 2022), (2015, .ref 2018), (2016, .ref 2024), (2017, .ref 2020), (2018, .ref 2028), (2019, .ref 2029), (2020, .ref 2026), (2021, .ref 2027)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa45 : Map :=
  Conv.Map.compact 2710740 2711105 2013 PRE_first_tail_x15_r0_body.pl45 (PRE_first_tail_x15_r0_body.nr45.map NumV.ref) PRE_first_tail_x15_r0_body.kd45.big
    PRE_first_tail_x15_r0_body.kd45.region PRE_first_tail_x15_r0_body.kd45.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws45 : List Nat := [1776, 1777, 1778, 1779, 1780, 1781, 1782, 1783, 1784]
noncomputable def PRE_first_tail_x15_r0_body.crs45 : List SymE := PRE_first_tail_x15_r0_body.nr45.map fun r => (nth? PRE_first_tail_x15_r0_body.S448.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta45 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws45 PRE_first_tail_x15_r0_body.crs45
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB45 : List Nat := [2665, 2672415, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab45 : PRE_first_tail_x15_r0_body.S449.tab = PRE_first_tail_x15_r0_body.S447.tab ++ PRE_first_tail_x15_r0_body.cws45.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace45 : PRE_first_tail_x15_r0_body.s449.trace = PRE_first_tail_x15_r0_body.s447.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext45 : PRE_first_tail_x15_r0_body.s449.next = 2710755
kernel_rfl PRE_first_tail_x15_r0_body.ccounters45 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.nnext) = (19105, 16193)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue45 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s448.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa45.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp45 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.tokens.all (bSN 2022) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean45 : Conv.cleanListB 19105 131072 (fun r => Nat.ble 76420 r) PRE_first_tail_x15_r0_body.s449
    (PRE_first_tail_x15_r0_body.wrB45 ++ (List.range 15).map (2710740 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs45 : bigsOutB 19105 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx = true

end Host.Load.Run.Tpl
