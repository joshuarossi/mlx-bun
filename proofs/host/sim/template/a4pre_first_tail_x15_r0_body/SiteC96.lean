import host.sim.template.a4pre_first_tail_x15_r0_body.H29
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

/-! The compaction after the merge at call site 96 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s938` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa96` into the merged state
`PRE_first_tail_x15_r0_body.s937`. -/

def PRE_first_tail_x15_r0_body.pl96 : List Nat := [2751903, 2751078, 2751909, 2751905, 2751080, 2751911]
def PRE_first_tail_x15_r0_body.nr96 : List Nat := [4217, 4216, 4192, 4200, 4205, 4210, 4215, 4189, 4190, 4191, 4198, 4199, 4187, 4194, 4195, 4196, 4197, 4193]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd96 : RData :=
  ⟨2750797, 2751946, Stage.setAll PTrie.nil [(2750791, 2751903), (2750792, 2751078), (2750793, 2751909), (2750794, 2751905), (2750795, 2751080), (2750796, 2751911)], Stage.setAll PTrie.nil [(20104, 20130), (20105, 20108), (20106, 20131)],
   20107, 20132, 17201, 17201, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4187, .ref 4217), (4188, .ref 4216), (4189, .ref 4192), (4190, .ref 4200), (4191, .ref 4205), (4192, .ref 4210), (4193, .ref 4215), (4194, .ref 4189), (4195, .ref 4190), (4196, .ref 4191), (4197, .ref 4198), (4198, .ref 4199), (4199, .ref 4187), (4200, .ref 4194), (4201, .ref 4195), (4202, .ref 4196), (4203, .ref 4197), (4204, .ref 4193)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa96 : Map :=
  Conv.Map.compact 2750791 2751946 4187 PRE_first_tail_x15_r0_body.pl96 (PRE_first_tail_x15_r0_body.nr96.map NumV.ref) PRE_first_tail_x15_r0_body.kd96.big
    PRE_first_tail_x15_r0_body.kd96.region PRE_first_tail_x15_r0_body.kd96.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws96 : List Nat := [2629, 2630, 2631, 2632, 2633, 2634, 2635, 2636, 2637, 2638, 2639, 2640, 2641, 2642, 2643, 2644, 2645, 2646]
noncomputable def PRE_first_tail_x15_r0_body.crs96 : List SymE := PRE_first_tail_x15_r0_body.nr96.map fun r => (nth? PRE_first_tail_x15_r0_body.S937.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta96 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws96 PRE_first_tail_x15_r0_body.crs96
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB96 : List Nat := [2665, 2672548, 2673467, 2749965, 2750510, 2750766]

kernel_rfl PRE_first_tail_x15_r0_body.ctab96 : PRE_first_tail_x15_r0_body.S938.tab = PRE_first_tail_x15_r0_body.S936.tab ++ PRE_first_tail_x15_r0_body.cws96.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace96 : PRE_first_tail_x15_r0_body.s938.trace = PRE_first_tail_x15_r0_body.s936.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext96 : PRE_first_tail_x15_r0_body.s938.next = 2750797
kernel_rfl PRE_first_tail_x15_r0_body.ccounters96 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s938.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s938.ffi).mlx.nnext) = (20107, 17201)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue96 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s937.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s938.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa96.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp96 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s938.ffi).mlx.tokens.all (bSN 4205) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean96 : Conv.cleanListB 20107 131072 (fun r => Nat.ble 80428 r) PRE_first_tail_x15_r0_body.s938
    (PRE_first_tail_x15_r0_body.wrB96 ++ (List.range 6).map (2750791 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs96 : bigsOutB 20107 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s938.ffi).mlx = true

end Host.Load.Run.Tpl
