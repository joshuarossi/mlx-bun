import host.sim.template.a4pre_first_tail_x15_r0_body.H33
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

/-! The compaction after the merge at call site 122 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1077` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa122` into the merged state
`PRE_first_tail_x15_r0_body.s1076`. -/

def PRE_first_tail_x15_r0_body.pl122 : List Nat := [2770417]
def PRE_first_tail_x15_r0_body.nr122 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd122 : RData :=
  ⟨2770408, 2770418, Stage.setAll PTrie.nil [(2770407, 2770417)], Stage.setAll PTrie.nil [],
   20599, 20599, 17692, 17692, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa122 : Map :=
  Conv.Map.compact 2770407 2770418 5269 PRE_first_tail_x15_r0_body.pl122 (PRE_first_tail_x15_r0_body.nr122.map NumV.ref) PRE_first_tail_x15_r0_body.kd122.big
    PRE_first_tail_x15_r0_body.kd122.region PRE_first_tail_x15_r0_body.kd122.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws122 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs122 : List SymE := PRE_first_tail_x15_r0_body.nr122.map fun r => (nth? PRE_first_tail_x15_r0_body.S1076.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta122 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws122 PRE_first_tail_x15_r0_body.crs122
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB122 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab122 : PRE_first_tail_x15_r0_body.S1077.tab = PRE_first_tail_x15_r0_body.S1075.tab ++ PRE_first_tail_x15_r0_body.cws122.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace122 : PRE_first_tail_x15_r0_body.s1077.trace = PRE_first_tail_x15_r0_body.s1075.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext122 : PRE_first_tail_x15_r0_body.s1077.next = 2770408
kernel_rfl PRE_first_tail_x15_r0_body.ccounters122 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1077.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1077.ffi).mlx.nnext) = (20599, 17692)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue122 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1076.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1077.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa122.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp122 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1077.ffi).mlx.tokens.all (bSN 5269) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean122 : Conv.cleanListB 20599 131072 (fun r => Nat.ble 82396 r) PRE_first_tail_x15_r0_body.s1077
    (PRE_first_tail_x15_r0_body.wrB122 ++ (List.range 1).map (2770407 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs122 : bigsOutB 20599 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1077.ffi).mlx = true

end Host.Load.Run.Tpl
