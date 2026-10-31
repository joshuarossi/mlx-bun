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

/-! The compaction after the merge at call site 80 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s711` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa80` into the merged state
`PRE_first_tail_x15_r0_body.s710`. -/

def PRE_first_tail_x15_r0_body.pl80 : List Nat := [2737265]
def PRE_first_tail_x15_r0_body.nr80 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd80 : RData :=
  ⟨2737256, 2737266, Stage.setAll PTrie.nil [(2737255, 2737265)], Stage.setAll PTrie.nil [],
   19769, 19769, 16870, 16870, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa80 : Map :=
  Conv.Map.compact 2737255 2737266 3475 PRE_first_tail_x15_r0_body.pl80 (PRE_first_tail_x15_r0_body.nr80.map NumV.ref) PRE_first_tail_x15_r0_body.kd80.big
    PRE_first_tail_x15_r0_body.kd80.region PRE_first_tail_x15_r0_body.kd80.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws80 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs80 : List SymE := PRE_first_tail_x15_r0_body.nr80.map fun r => (nth? PRE_first_tail_x15_r0_body.S710.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta80 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws80 PRE_first_tail_x15_r0_body.crs80
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB80 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab80 : PRE_first_tail_x15_r0_body.S711.tab = PRE_first_tail_x15_r0_body.S709.tab ++ PRE_first_tail_x15_r0_body.cws80.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace80 : PRE_first_tail_x15_r0_body.s711.trace = PRE_first_tail_x15_r0_body.s709.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext80 : PRE_first_tail_x15_r0_body.s711.next = 2737256
kernel_rfl PRE_first_tail_x15_r0_body.ccounters80 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s711.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s711.ffi).mlx.nnext) = (19769, 16870)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue80 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s710.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s711.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa80.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp80 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s711.ffi).mlx.tokens.all (bSN 3475) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean80 : Conv.cleanListB 19769 131072 (fun r => Nat.ble 79076 r) PRE_first_tail_x15_r0_body.s711
    (PRE_first_tail_x15_r0_body.wrB80 ++ (List.range 1).map (2737255 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs80 : bigsOutB 19769 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s711.ffi).mlx = true

end Host.Load.Run.Tpl
