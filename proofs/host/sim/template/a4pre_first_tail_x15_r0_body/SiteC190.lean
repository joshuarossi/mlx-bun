import host.sim.template.a4pre_first_tail_x15_r0_body.H57
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

/-! The compaction after the merge at call site 190 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1837` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa190` into the merged state
`PRE_first_tail_x15_r0_body.s1836`. -/

def PRE_first_tail_x15_r0_body.pl190 : List Nat := []
def PRE_first_tail_x15_r0_body.nr190 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd190 : RData :=
  ⟨2824365, 2824367, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21950, 21950, 19047, 19047, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa190 : Map :=
  Conv.Map.compact 2824365 2824367 8201 PRE_first_tail_x15_r0_body.pl190 (PRE_first_tail_x15_r0_body.nr190.map NumV.ref) PRE_first_tail_x15_r0_body.kd190.big
    PRE_first_tail_x15_r0_body.kd190.region PRE_first_tail_x15_r0_body.kd190.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws190 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs190 : List SymE := PRE_first_tail_x15_r0_body.nr190.map fun r => (nth? PRE_first_tail_x15_r0_body.S1836.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta190 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws190 PRE_first_tail_x15_r0_body.crs190
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB190 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab190 : PRE_first_tail_x15_r0_body.S1837.tab = PRE_first_tail_x15_r0_body.S1835.tab ++ PRE_first_tail_x15_r0_body.cws190.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace190 : PRE_first_tail_x15_r0_body.s1837.trace = PRE_first_tail_x15_r0_body.s1835.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext190 : PRE_first_tail_x15_r0_body.s1837.next = 2824365
kernel_rfl PRE_first_tail_x15_r0_body.ccounters190 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.nnext) = (21950, 19047)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue190 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1836.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa190.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp190 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.tokens.all (bSN 8201) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean190 : Conv.cleanListB 21950 131072 (fun r => Nat.ble 87800 r) PRE_first_tail_x15_r0_body.s1837
    (PRE_first_tail_x15_r0_body.wrB190 ++ (List.range 0).map (2824365 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs190 : bigsOutB 21950 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx = true

end Host.Load.Run.Tpl
