import host.sim.template.a4pre_first_tail_x15_r0_body.H27
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

/-! The compaction after the merge at call site 91 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s889` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa91` into the merged state
`PRE_first_tail_x15_r0_body.s888`. -/

def PRE_first_tail_x15_r0_body.pl91 : List Nat := []
def PRE_first_tail_x15_r0_body.nr91 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd91 : RData :=
  ⟨2746383, 2746385, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19998, 19998, 17103, 17103, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa91 : Map :=
  Conv.Map.compact 2746383 2746385 3971 PRE_first_tail_x15_r0_body.pl91 (PRE_first_tail_x15_r0_body.nr91.map NumV.ref) PRE_first_tail_x15_r0_body.kd91.big
    PRE_first_tail_x15_r0_body.kd91.region PRE_first_tail_x15_r0_body.kd91.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws91 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs91 : List SymE := PRE_first_tail_x15_r0_body.nr91.map fun r => (nth? PRE_first_tail_x15_r0_body.S888.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta91 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws91 PRE_first_tail_x15_r0_body.crs91
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB91 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab91 : PRE_first_tail_x15_r0_body.S889.tab = PRE_first_tail_x15_r0_body.S887.tab ++ PRE_first_tail_x15_r0_body.cws91.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace91 : PRE_first_tail_x15_r0_body.s889.trace = PRE_first_tail_x15_r0_body.s887.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext91 : PRE_first_tail_x15_r0_body.s889.next = 2746383
kernel_rfl PRE_first_tail_x15_r0_body.ccounters91 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s889.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s889.ffi).mlx.nnext) = (19998, 17103)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue91 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s888.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s889.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa91.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp91 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s889.ffi).mlx.tokens.all (bSN 3971) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean91 : Conv.cleanListB 19998 131072 (fun r => Nat.ble 79992 r) PRE_first_tail_x15_r0_body.s889
    (PRE_first_tail_x15_r0_body.wrB91 ++ (List.range 0).map (2746383 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs91 : bigsOutB 19998 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s889.ffi).mlx = true

end Host.Load.Run.Tpl
