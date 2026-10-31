import host.sim.template.a4pre_first_tail_x15_r0_body.H39
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

/-! The compaction after the merge at call site 143 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1260` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa143` into the merged state
`PRE_first_tail_x15_r0_body.s1259`. -/

def PRE_first_tail_x15_r0_body.pl143 : List Nat := [2786980]
def PRE_first_tail_x15_r0_body.nr143 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd143 : RData :=
  ⟨2786962, 2786981, Stage.setAll PTrie.nil [(2786961, 2786980)], Stage.setAll PTrie.nil [],
   21013, 21013, 18103, 18103, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa143 : Map :=
  Conv.Map.compact 2786961 2786981 6166 PRE_first_tail_x15_r0_body.pl143 (PRE_first_tail_x15_r0_body.nr143.map NumV.ref) PRE_first_tail_x15_r0_body.kd143.big
    PRE_first_tail_x15_r0_body.kd143.region PRE_first_tail_x15_r0_body.kd143.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws143 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs143 : List SymE := PRE_first_tail_x15_r0_body.nr143.map fun r => (nth? PRE_first_tail_x15_r0_body.S1259.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta143 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws143 PRE_first_tail_x15_r0_body.crs143
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB143 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab143 : PRE_first_tail_x15_r0_body.S1260.tab = PRE_first_tail_x15_r0_body.S1258.tab ++ PRE_first_tail_x15_r0_body.cws143.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace143 : PRE_first_tail_x15_r0_body.s1260.trace = PRE_first_tail_x15_r0_body.s1258.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext143 : PRE_first_tail_x15_r0_body.s1260.next = 2786962
kernel_rfl PRE_first_tail_x15_r0_body.ccounters143 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext) = (21013, 18103)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue143 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1259.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa143.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp143 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.tokens.all (bSN 6166) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean143 : Conv.cleanListB 21013 131072 (fun r => Nat.ble 84052 r) PRE_first_tail_x15_r0_body.s1260
    (PRE_first_tail_x15_r0_body.wrB143 ++ (List.range 1).map (2786961 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs143 : bigsOutB 21013 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx = true

end Host.Load.Run.Tpl
