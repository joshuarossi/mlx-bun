import host.sim.template.a4pre_first_tail_x15_r0_body.H1
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

/-! The compaction after the merge at call site 5 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s54` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa5` into the merged state
`PRE_first_tail_x15_r0_body.s53`. -/

def PRE_first_tail_x15_r0_body.pl5 : List Nat := [2678417]
def PRE_first_tail_x15_r0_body.nr5 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd5 : RData :=
  ⟨2678408, 2678418, Stage.setAll PTrie.nil [(2678407, 2678417)], Stage.setAll PTrie.nil [],
   18293, 18293, 15385, 15385, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa5 : Map :=
  Conv.Map.compact 2678407 2678418 268 PRE_first_tail_x15_r0_body.pl5 (PRE_first_tail_x15_r0_body.nr5.map NumV.ref) PRE_first_tail_x15_r0_body.kd5.big
    PRE_first_tail_x15_r0_body.kd5.region PRE_first_tail_x15_r0_body.kd5.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws5 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs5 : List SymE := PRE_first_tail_x15_r0_body.nr5.map fun r => (nth? PRE_first_tail_x15_r0_body.S53.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta5 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws5 PRE_first_tail_x15_r0_body.crs5
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB5 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab5 : PRE_first_tail_x15_r0_body.S54.tab = PRE_first_tail_x15_r0_body.S52.tab ++ PRE_first_tail_x15_r0_body.cws5.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace5 : PRE_first_tail_x15_r0_body.s54.trace = PRE_first_tail_x15_r0_body.s52.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext5 : PRE_first_tail_x15_r0_body.s54.next = 2678408
kernel_rfl PRE_first_tail_x15_r0_body.ccounters5 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s54.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s54.ffi).mlx.nnext) = (18293, 15385)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue5 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s54.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa5.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp5 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s54.ffi).mlx.tokens.all (bSN 268) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean5 : Conv.cleanListB 18293 131072 (fun r => Nat.ble 73172 r) PRE_first_tail_x15_r0_body.s54
    (PRE_first_tail_x15_r0_body.wrB5 ++ (List.range 1).map (2678407 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs5 : bigsOutB 18293 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s54.ffi).mlx = true

end Host.Load.Run.Tpl
