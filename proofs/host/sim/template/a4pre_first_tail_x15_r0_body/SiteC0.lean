import host.sim.template.a4pre_first_tail_x15_r0_body.H0
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

/-! The compaction after the merge at call site 0 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s17` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa0` into the merged state
`PRE_first_tail_x15_r0_body.s16`. -/

def PRE_first_tail_x15_r0_body.pl0 : List Nat := [2676569, 2675150, 2676318, 2675881, 2675277, 2675287, 2675891, 2675202, 2676575, 2676571, 2675152, 2675276, 2675880, 2675204, 2676577, 2675275, 2675274, 2675879, 2675878, 2675877, 2675876, 2675236, 2675238]
def PRE_first_tail_x15_r0_body.nr0 : List Nat := [113, 112, 89, 88, 96, 101, 106, 111, 85, 86, 87, 94, 95, 83, 90, 91, 92, 93]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd0 : RData :=
  ⟨2674920, 2676612, Stage.setAll PTrie.nil [(2674897, 2676569), (2674898, 2675150), (2674899, 2676318), (2674900, 2675881), (2674901, 2675277), (2674902, 2675287), (2674903, 2675891), (2674904, 2675202), (2674905, 2676575), (2674906, 2676571), (2674907, 2675152), (2674908, 2675276), (2674909, 2675880), (2674910, 2675204), (2674911, 2676577), (2674912, 2675275), (2674913, 2675274), (2674914, 2675879), (2674915, 2675878), (2674916, 2675877), (2674917, 2675876), (2674918, 2675236), (2674919, 2675238)], Stage.setAll PTrie.nil [(18189, 18241), (18190, 18193), (18191, 18237), (18192, 18216), (18193, 18197), (18194, 18194), (18195, 18242), (18196, 18195)],
   18197, 18243, 15296, 15296, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(83, .ref 113), (84, .ref 112), (85, .ref 89), (86, .ref 88), (87, .ref 96), (88, .ref 101), (89, .ref 106), (90, .ref 111), (91, .ref 85), (92, .ref 86), (93, .ref 87), (94, .ref 94), (95, .ref 95), (96, .ref 83), (97, .ref 90), (98, .ref 91), (99, .ref 92), (100, .ref 93)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa0 : Map :=
  Conv.Map.compact 2674897 2676612 83 PRE_first_tail_x15_r0_body.pl0 (PRE_first_tail_x15_r0_body.nr0.map NumV.ref) PRE_first_tail_x15_r0_body.kd0.big
    PRE_first_tail_x15_r0_body.kd0.region PRE_first_tail_x15_r0_body.kd0.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws0 : List Nat := [1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044, 1045, 1046, 1047, 1048]
noncomputable def PRE_first_tail_x15_r0_body.crs0 : List SymE := PRE_first_tail_x15_r0_body.nr0.map fun r => (nth? PRE_first_tail_x15_r0_body.S16.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta0 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws0 PRE_first_tail_x15_r0_body.crs0
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB0 : List Nat := [483, 610, 613, 1050, 1051, 1054, 1281, 2665, 4941, 2672300, 2673467, 2674071, 2674616, 2674872]

kernel_rfl PRE_first_tail_x15_r0_body.ctab0 : PRE_first_tail_x15_r0_body.S17.tab = PRE_first_tail_x15_r0_body.S15.tab ++ PRE_first_tail_x15_r0_body.cws0.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace0 : PRE_first_tail_x15_r0_body.s17.trace = PRE_first_tail_x15_r0_body.s15.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext0 : PRE_first_tail_x15_r0_body.s17.next = 2674920
kernel_rfl PRE_first_tail_x15_r0_body.ccounters0 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx.nnext) = (18197, 15296)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s16.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa0.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx.tokens.all (bSN 101) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean0 : Conv.cleanListB 18197 131072 (fun r => Nat.ble 72788 r) PRE_first_tail_x15_r0_body.s17
    (PRE_first_tail_x15_r0_body.wrB0 ++ (List.range 23).map (2674897 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs0 : bigsOutB 18197 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx = true

end Host.Load.Run.Tpl
