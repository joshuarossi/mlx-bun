import host.sim.template.a4pre_first_tail_x15_r0_body.H13
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

/-! The compaction after the merge at call site 44 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s433` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa44` into the merged state
`PRE_first_tail_x15_r0_body.s432`. -/

def PRE_first_tail_x15_r0_body.pl44 : List Nat := [2709013]
def PRE_first_tail_x15_r0_body.nr44 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd44 : RData :=
  ⟨2709004, 2709014, Stage.setAll PTrie.nil [(2709003, 2709013)], Stage.setAll PTrie.nil [],
   19061, 19061, 16159, 16159, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa44 : Map :=
  Conv.Map.compact 2709003 2709014 1936 PRE_first_tail_x15_r0_body.pl44 (PRE_first_tail_x15_r0_body.nr44.map NumV.ref) PRE_first_tail_x15_r0_body.kd44.big
    PRE_first_tail_x15_r0_body.kd44.region PRE_first_tail_x15_r0_body.kd44.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws44 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs44 : List SymE := PRE_first_tail_x15_r0_body.nr44.map fun r => (nth? PRE_first_tail_x15_r0_body.S432.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta44 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws44 PRE_first_tail_x15_r0_body.crs44
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB44 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab44 : PRE_first_tail_x15_r0_body.S433.tab = PRE_first_tail_x15_r0_body.S431.tab ++ PRE_first_tail_x15_r0_body.cws44.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace44 : PRE_first_tail_x15_r0_body.s433.trace = PRE_first_tail_x15_r0_body.s431.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext44 : PRE_first_tail_x15_r0_body.s433.next = 2709004
kernel_rfl PRE_first_tail_x15_r0_body.ccounters44 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.nnext) = (19061, 16159)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue44 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s432.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa44.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp44 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.tokens.all (bSN 1936) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean44 : Conv.cleanListB 19061 131072 (fun r => Nat.ble 76244 r) PRE_first_tail_x15_r0_body.s433
    (PRE_first_tail_x15_r0_body.wrB44 ++ (List.range 1).map (2709003 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs44 : bigsOutB 19061 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx = true

end Host.Load.Run.Tpl
