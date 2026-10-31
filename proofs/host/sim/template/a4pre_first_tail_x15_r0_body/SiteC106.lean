import host.sim.template.a4pre_first_tail_x15_r0_body.H32
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

/-! The compaction after the merge at call site 106 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1032` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa106` into the merged state
`PRE_first_tail_x15_r0_body.s1031`. -/

def PRE_first_tail_x15_r0_body.pl106 : List Nat := []
def PRE_first_tail_x15_r0_body.nr106 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd106 : RData :=
  ⟨2758429, 2758431, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20298, 20298, 17388, 17388, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa106 : Map :=
  Conv.Map.compact 2758429 2758431 4610 PRE_first_tail_x15_r0_body.pl106 (PRE_first_tail_x15_r0_body.nr106.map NumV.ref) PRE_first_tail_x15_r0_body.kd106.big
    PRE_first_tail_x15_r0_body.kd106.region PRE_first_tail_x15_r0_body.kd106.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws106 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs106 : List SymE := PRE_first_tail_x15_r0_body.nr106.map fun r => (nth? PRE_first_tail_x15_r0_body.S1031.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta106 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws106 PRE_first_tail_x15_r0_body.crs106
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB106 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab106 : PRE_first_tail_x15_r0_body.S1032.tab = PRE_first_tail_x15_r0_body.S1030.tab ++ PRE_first_tail_x15_r0_body.cws106.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace106 : PRE_first_tail_x15_r0_body.s1032.trace = PRE_first_tail_x15_r0_body.s1030.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext106 : PRE_first_tail_x15_r0_body.s1032.next = 2758429
kernel_rfl PRE_first_tail_x15_r0_body.ccounters106 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.nnext) = (20298, 17388)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue106 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1031.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa106.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp106 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.tokens.all (bSN 4610) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean106 : Conv.cleanListB 20298 131072 (fun r => Nat.ble 81192 r) PRE_first_tail_x15_r0_body.s1032
    (PRE_first_tail_x15_r0_body.wrB106 ++ (List.range 0).map (2758429 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs106 : bigsOutB 20298 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx = true

end Host.Load.Run.Tpl
