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

/-! The compaction after the merge at call site 97 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s946` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa97` into the merged state
`PRE_first_tail_x15_r0_body.s945`. -/

def PRE_first_tail_x15_r0_body.pl97 : List Nat := []
def PRE_first_tail_x15_r0_body.nr97 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd97 : RData :=
  ⟨2751287, 2751289, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20120, 20120, 17214, 17214, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa97 : Map :=
  Conv.Map.compact 2751287 2751289 4226 PRE_first_tail_x15_r0_body.pl97 (PRE_first_tail_x15_r0_body.nr97.map NumV.ref) PRE_first_tail_x15_r0_body.kd97.big
    PRE_first_tail_x15_r0_body.kd97.region PRE_first_tail_x15_r0_body.kd97.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws97 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs97 : List SymE := PRE_first_tail_x15_r0_body.nr97.map fun r => (nth? PRE_first_tail_x15_r0_body.S945.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta97 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws97 PRE_first_tail_x15_r0_body.crs97
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB97 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab97 : PRE_first_tail_x15_r0_body.S946.tab = PRE_first_tail_x15_r0_body.S944.tab ++ PRE_first_tail_x15_r0_body.cws97.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace97 : PRE_first_tail_x15_r0_body.s946.trace = PRE_first_tail_x15_r0_body.s944.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext97 : PRE_first_tail_x15_r0_body.s946.next = 2751287
kernel_rfl PRE_first_tail_x15_r0_body.ccounters97 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s946.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s946.ffi).mlx.nnext) = (20120, 17214)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue97 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s945.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s946.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa97.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp97 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s946.ffi).mlx.tokens.all (bSN 4226) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean97 : Conv.cleanListB 20120 131072 (fun r => Nat.ble 80480 r) PRE_first_tail_x15_r0_body.s946
    (PRE_first_tail_x15_r0_body.wrB97 ++ (List.range 0).map (2751287 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs97 : bigsOutB 20120 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s946.ffi).mlx = true

end Host.Load.Run.Tpl
