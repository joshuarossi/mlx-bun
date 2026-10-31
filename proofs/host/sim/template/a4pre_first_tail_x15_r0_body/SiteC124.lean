import host.sim.template.a4pre_first_tail_x15_r0_body.H37
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

/-! The compaction after the merge at call site 124 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1205` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa124` into the merged state
`PRE_first_tail_x15_r0_body.s1204`. -/

def PRE_first_tail_x15_r0_body.pl124 : List Nat := []
def PRE_first_tail_x15_r0_body.nr124 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd124 : RData :=
  ⟨2772375, 2772377, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20649, 20649, 17751, 17751, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa124 : Map :=
  Conv.Map.compact 2772375 2772377 5381 PRE_first_tail_x15_r0_body.pl124 (PRE_first_tail_x15_r0_body.nr124.map NumV.ref) PRE_first_tail_x15_r0_body.kd124.big
    PRE_first_tail_x15_r0_body.kd124.region PRE_first_tail_x15_r0_body.kd124.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws124 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs124 : List SymE := PRE_first_tail_x15_r0_body.nr124.map fun r => (nth? PRE_first_tail_x15_r0_body.S1204.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta124 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws124 PRE_first_tail_x15_r0_body.crs124
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB124 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab124 : PRE_first_tail_x15_r0_body.S1205.tab = PRE_first_tail_x15_r0_body.S1203.tab ++ PRE_first_tail_x15_r0_body.cws124.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace124 : PRE_first_tail_x15_r0_body.s1205.trace = PRE_first_tail_x15_r0_body.s1203.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext124 : PRE_first_tail_x15_r0_body.s1205.next = 2772375
kernel_rfl PRE_first_tail_x15_r0_body.ccounters124 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.nnext) = (20649, 17751)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue124 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1204.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa124.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp124 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.tokens.all (bSN 5381) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean124 : Conv.cleanListB 20649 131072 (fun r => Nat.ble 82596 r) PRE_first_tail_x15_r0_body.s1205
    (PRE_first_tail_x15_r0_body.wrB124 ++ (List.range 0).map (2772375 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs124 : bigsOutB 20649 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx = true

end Host.Load.Run.Tpl
