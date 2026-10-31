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

/-! The compaction after the merge at call site 4 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s50` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa4` into the merged state
`PRE_first_tail_x15_r0_body.s49`. -/

def PRE_first_tail_x15_r0_body.pl4 : List Nat := []
def PRE_first_tail_x15_r0_body.nr4 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd4 : RData :=
  ⟨2678119, 2678121, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18286, 18286, 15381, 15381, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa4 : Map :=
  Conv.Map.compact 2678119 2678121 251 PRE_first_tail_x15_r0_body.pl4 (PRE_first_tail_x15_r0_body.nr4.map NumV.ref) PRE_first_tail_x15_r0_body.kd4.big
    PRE_first_tail_x15_r0_body.kd4.region PRE_first_tail_x15_r0_body.kd4.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws4 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs4 : List SymE := PRE_first_tail_x15_r0_body.nr4.map fun r => (nth? PRE_first_tail_x15_r0_body.S49.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta4 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws4 PRE_first_tail_x15_r0_body.crs4
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB4 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab4 : PRE_first_tail_x15_r0_body.S50.tab = PRE_first_tail_x15_r0_body.S48.tab ++ PRE_first_tail_x15_r0_body.cws4.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace4 : PRE_first_tail_x15_r0_body.s50.trace = PRE_first_tail_x15_r0_body.s48.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext4 : PRE_first_tail_x15_r0_body.s50.next = 2678119
kernel_rfl PRE_first_tail_x15_r0_body.ccounters4 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s50.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s50.ffi).mlx.nnext) = (18286, 15381)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue4 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s49.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s50.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa4.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp4 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s50.ffi).mlx.tokens.all (bSN 251) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean4 : Conv.cleanListB 18286 131072 (fun r => Nat.ble 73144 r) PRE_first_tail_x15_r0_body.s50
    (PRE_first_tail_x15_r0_body.wrB4 ++ (List.range 0).map (2678119 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs4 : bigsOutB 18286 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s50.ffi).mlx = true

end Host.Load.Run.Tpl
