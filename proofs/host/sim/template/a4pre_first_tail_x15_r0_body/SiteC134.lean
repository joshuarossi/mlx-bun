import host.sim.template.a4pre_first_tail_x15_r0_body.H40
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

/-! The compaction after the merge at call site 134 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1295` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa134` into the merged state
`PRE_first_tail_x15_r0_body.s1294`. -/

def PRE_first_tail_x15_r0_body.pl134 : List Nat := [2779829]
def PRE_first_tail_x15_r0_body.nr134 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd134 : RData :=
  ⟨2779820, 2779830, Stage.setAll PTrie.nil [(2779819, 2779829)], Stage.setAll PTrie.nil [],
   20835, 20835, 17929, 17929, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa134 : Map :=
  Conv.Map.compact 2779819 2779830 5782 PRE_first_tail_x15_r0_body.pl134 (PRE_first_tail_x15_r0_body.nr134.map NumV.ref) PRE_first_tail_x15_r0_body.kd134.big
    PRE_first_tail_x15_r0_body.kd134.region PRE_first_tail_x15_r0_body.kd134.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws134 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs134 : List SymE := PRE_first_tail_x15_r0_body.nr134.map fun r => (nth? PRE_first_tail_x15_r0_body.S1294.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta134 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws134 PRE_first_tail_x15_r0_body.crs134
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB134 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab134 : PRE_first_tail_x15_r0_body.S1295.tab = PRE_first_tail_x15_r0_body.S1293.tab ++ PRE_first_tail_x15_r0_body.cws134.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace134 : PRE_first_tail_x15_r0_body.s1295.trace = PRE_first_tail_x15_r0_body.s1293.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext134 : PRE_first_tail_x15_r0_body.s1295.next = 2779820
kernel_rfl PRE_first_tail_x15_r0_body.ccounters134 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.nnext) = (20835, 17929)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue134 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1294.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa134.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp134 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.tokens.all (bSN 5782) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean134 : Conv.cleanListB 20835 131072 (fun r => Nat.ble 83340 r) PRE_first_tail_x15_r0_body.s1295
    (PRE_first_tail_x15_r0_body.wrB134 ++ (List.range 1).map (2779819 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs134 : bigsOutB 20835 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx = true

end Host.Load.Run.Tpl
