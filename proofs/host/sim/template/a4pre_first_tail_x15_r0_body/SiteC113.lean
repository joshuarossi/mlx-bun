import host.sim.template.a4pre_first_tail_x15_r0_body.H34
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

/-! The compaction after the merge at call site 113 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1094` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa113` into the merged state
`PRE_first_tail_x15_r0_body.s1093`. -/

def PRE_first_tail_x15_r0_body.pl113 : List Nat := [2763261]
def PRE_first_tail_x15_r0_body.nr113 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd113 : RData :=
  ⟨2763252, 2763262, Stage.setAll PTrie.nil [(2763251, 2763261)], Stage.setAll PTrie.nil [],
   20420, 20420, 17518, 17518, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa113 : Map :=
  Conv.Map.compact 2763251 2763262 4885 PRE_first_tail_x15_r0_body.pl113 (PRE_first_tail_x15_r0_body.nr113.map NumV.ref) PRE_first_tail_x15_r0_body.kd113.big
    PRE_first_tail_x15_r0_body.kd113.region PRE_first_tail_x15_r0_body.kd113.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws113 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs113 : List SymE := PRE_first_tail_x15_r0_body.nr113.map fun r => (nth? PRE_first_tail_x15_r0_body.S1093.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta113 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws113 PRE_first_tail_x15_r0_body.crs113
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB113 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab113 : PRE_first_tail_x15_r0_body.S1094.tab = PRE_first_tail_x15_r0_body.S1092.tab ++ PRE_first_tail_x15_r0_body.cws113.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace113 : PRE_first_tail_x15_r0_body.s1094.trace = PRE_first_tail_x15_r0_body.s1092.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext113 : PRE_first_tail_x15_r0_body.s1094.next = 2763252
kernel_rfl PRE_first_tail_x15_r0_body.ccounters113 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1094.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1094.ffi).mlx.nnext) = (20420, 17518)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue113 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1093.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1094.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa113.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp113 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1094.ffi).mlx.tokens.all (bSN 4885) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean113 : Conv.cleanListB 20420 131072 (fun r => Nat.ble 81680 r) PRE_first_tail_x15_r0_body.s1094
    (PRE_first_tail_x15_r0_body.wrB113 ++ (List.range 1).map (2763251 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs113 : bigsOutB 20420 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1094.ffi).mlx = true

end Host.Load.Run.Tpl
