import host.sim.template.a4pre_first_tail_x15_r0_body.H52
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

/-! The compaction after the merge at call site 173 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1669` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa173` into the merged state
`PRE_first_tail_x15_r0_body.s1668`. -/

def PRE_first_tail_x15_r0_body.pl173 : List Nat := [2810362]
def PRE_first_tail_x15_r0_body.nr173 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd173 : RData :=
  ⟨2810344, 2810363, Stage.setAll PTrie.nil [(2810343, 2810362)], Stage.setAll PTrie.nil [],
   21600, 21600, 18703, 18703, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa173 : Map :=
  Conv.Map.compact 2810343 2810363 7450 PRE_first_tail_x15_r0_body.pl173 (PRE_first_tail_x15_r0_body.nr173.map NumV.ref) PRE_first_tail_x15_r0_body.kd173.big
    PRE_first_tail_x15_r0_body.kd173.region PRE_first_tail_x15_r0_body.kd173.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws173 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs173 : List SymE := PRE_first_tail_x15_r0_body.nr173.map fun r => (nth? PRE_first_tail_x15_r0_body.S1668.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta173 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws173 PRE_first_tail_x15_r0_body.crs173
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB173 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab173 : PRE_first_tail_x15_r0_body.S1669.tab = PRE_first_tail_x15_r0_body.S1667.tab ++ PRE_first_tail_x15_r0_body.cws173.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace173 : PRE_first_tail_x15_r0_body.s1669.trace = PRE_first_tail_x15_r0_body.s1667.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext173 : PRE_first_tail_x15_r0_body.s1669.next = 2810344
kernel_rfl PRE_first_tail_x15_r0_body.ccounters173 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx.nnext) = (21600, 18703)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue173 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1668.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa173.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp173 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx.tokens.all (bSN 7450) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean173 : Conv.cleanListB 21600 131072 (fun r => Nat.ble 86400 r) PRE_first_tail_x15_r0_body.s1669
    (PRE_first_tail_x15_r0_body.wrB173 ++ (List.range 1).map (2810343 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs173 : bigsOutB 21600 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx = true

end Host.Load.Run.Tpl
