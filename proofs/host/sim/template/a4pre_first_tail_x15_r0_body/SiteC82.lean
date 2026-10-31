import host.sim.template.a4pre_first_tail_x15_r0_body.H22
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

/-! The compaction after the merge at call site 82 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s731` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa82` into the merged state
`PRE_first_tail_x15_r0_body.s730`. -/

def PRE_first_tail_x15_r0_body.pl82 : List Nat := []
def PRE_first_tail_x15_r0_body.nr82 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd82 : RData :=
  ⟨2739589, 2739591, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19826, 19826, 16914, 16914, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa82 : Map :=
  Conv.Map.compact 2739589 2739591 3584 PRE_first_tail_x15_r0_body.pl82 (PRE_first_tail_x15_r0_body.nr82.map NumV.ref) PRE_first_tail_x15_r0_body.kd82.big
    PRE_first_tail_x15_r0_body.kd82.region PRE_first_tail_x15_r0_body.kd82.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws82 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs82 : List SymE := PRE_first_tail_x15_r0_body.nr82.map fun r => (nth? PRE_first_tail_x15_r0_body.S730.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta82 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws82 PRE_first_tail_x15_r0_body.crs82
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB82 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab82 : PRE_first_tail_x15_r0_body.S731.tab = PRE_first_tail_x15_r0_body.S729.tab ++ PRE_first_tail_x15_r0_body.cws82.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace82 : PRE_first_tail_x15_r0_body.s731.trace = PRE_first_tail_x15_r0_body.s729.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext82 : PRE_first_tail_x15_r0_body.s731.next = 2739589
kernel_rfl PRE_first_tail_x15_r0_body.ccounters82 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s731.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s731.ffi).mlx.nnext) = (19826, 16914)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue82 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s730.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s731.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa82.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp82 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s731.ffi).mlx.tokens.all (bSN 3584) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean82 : Conv.cleanListB 19826 131072 (fun r => Nat.ble 79304 r) PRE_first_tail_x15_r0_body.s731
    (PRE_first_tail_x15_r0_body.wrB82 ++ (List.range 0).map (2739589 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs82 : bigsOutB 19826 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s731.ffi).mlx = true

end Host.Load.Run.Tpl
