import host.sim.template.a4pre_first_tail_x15_r0_body.H34
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

/-! The compaction after the merge at call site 115 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1119` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa115` into the merged state
`PRE_first_tail_x15_r0_body.s1118`. -/

def PRE_first_tail_x15_r0_body.pl115 : List Nat := []
def PRE_first_tail_x15_r0_body.nr115 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd115 : RData :=
  ⟨2765219, 2765221, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20470, 20470, 17577, 17577, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa115 : Map :=
  Conv.Map.compact 2765219 2765221 4997 PRE_first_tail_x15_r0_body.pl115 (PRE_first_tail_x15_r0_body.nr115.map NumV.ref) PRE_first_tail_x15_r0_body.kd115.big
    PRE_first_tail_x15_r0_body.kd115.region PRE_first_tail_x15_r0_body.kd115.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws115 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs115 : List SymE := PRE_first_tail_x15_r0_body.nr115.map fun r => (nth? PRE_first_tail_x15_r0_body.S1118.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta115 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws115 PRE_first_tail_x15_r0_body.crs115
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB115 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab115 : PRE_first_tail_x15_r0_body.S1119.tab = PRE_first_tail_x15_r0_body.S1117.tab ++ PRE_first_tail_x15_r0_body.cws115.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace115 : PRE_first_tail_x15_r0_body.s1119.trace = PRE_first_tail_x15_r0_body.s1117.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext115 : PRE_first_tail_x15_r0_body.s1119.next = 2765219
kernel_rfl PRE_first_tail_x15_r0_body.ccounters115 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1119.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1119.ffi).mlx.nnext) = (20470, 17577)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue115 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1119.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa115.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp115 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1119.ffi).mlx.tokens.all (bSN 4997) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean115 : Conv.cleanListB 20470 131072 (fun r => Nat.ble 81880 r) PRE_first_tail_x15_r0_body.s1119
    (PRE_first_tail_x15_r0_body.wrB115 ++ (List.range 0).map (2765219 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs115 : bigsOutB 20470 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1119.ffi).mlx = true

end Host.Load.Run.Tpl
