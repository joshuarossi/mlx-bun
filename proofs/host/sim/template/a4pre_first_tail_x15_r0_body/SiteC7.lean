import host.sim.template.a4pre_first_tail_x15_r0_body.H2
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

/-! The compaction after the merge at call site 7 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s84` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa7` into the merged state
`PRE_first_tail_x15_r0_body.s83`. -/

def PRE_first_tail_x15_r0_body.pl7 : List Nat := []
def PRE_first_tail_x15_r0_body.nr7 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd7 : RData :=
  ⟨2680469, 2680471, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18346, 18346, 15444, 15444, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa7 : Map :=
  Conv.Map.compact 2680469 2680471 380 PRE_first_tail_x15_r0_body.pl7 (PRE_first_tail_x15_r0_body.nr7.map NumV.ref) PRE_first_tail_x15_r0_body.kd7.big
    PRE_first_tail_x15_r0_body.kd7.region PRE_first_tail_x15_r0_body.kd7.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws7 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs7 : List SymE := PRE_first_tail_x15_r0_body.nr7.map fun r => (nth? PRE_first_tail_x15_r0_body.S83.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta7 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws7 PRE_first_tail_x15_r0_body.crs7
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB7 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab7 : PRE_first_tail_x15_r0_body.S84.tab = PRE_first_tail_x15_r0_body.S82.tab ++ PRE_first_tail_x15_r0_body.cws7.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace7 : PRE_first_tail_x15_r0_body.s84.trace = PRE_first_tail_x15_r0_body.s82.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext7 : PRE_first_tail_x15_r0_body.s84.next = 2680469
kernel_rfl PRE_first_tail_x15_r0_body.ccounters7 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s84.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s84.ffi).mlx.nnext) = (18346, 15444)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue7 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s83.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s84.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa7.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp7 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s84.ffi).mlx.tokens.all (bSN 380) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean7 : Conv.cleanListB 18346 131072 (fun r => Nat.ble 73384 r) PRE_first_tail_x15_r0_body.s84
    (PRE_first_tail_x15_r0_body.wrB7 ++ (List.range 0).map (2680469 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs7 : bigsOutB 18346 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s84.ffi).mlx = true

end Host.Load.Run.Tpl
