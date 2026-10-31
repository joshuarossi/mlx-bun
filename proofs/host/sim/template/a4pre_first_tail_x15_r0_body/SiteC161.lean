import host.sim.template.a4pre_first_tail_x15_r0_body.H44
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

/-! The compaction after the merge at call site 161 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1419` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa161` into the merged state
`PRE_first_tail_x15_r0_body.s1418`. -/

def PRE_first_tail_x15_r0_body.pl161 : List Nat := [2800929]
def PRE_first_tail_x15_r0_body.nr161 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd161 : RData :=
  ⟨2800920, 2800930, Stage.setAll PTrie.nil [(2800919, 2800929)], Stage.setAll PTrie.nil [],
   21364, 21364, 18466, 18466, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa161 : Map :=
  Conv.Map.compact 2800919 2800930 6937 PRE_first_tail_x15_r0_body.pl161 (PRE_first_tail_x15_r0_body.nr161.map NumV.ref) PRE_first_tail_x15_r0_body.kd161.big
    PRE_first_tail_x15_r0_body.kd161.region PRE_first_tail_x15_r0_body.kd161.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws161 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs161 : List SymE := PRE_first_tail_x15_r0_body.nr161.map fun r => (nth? PRE_first_tail_x15_r0_body.S1418.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta161 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws161 PRE_first_tail_x15_r0_body.crs161
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB161 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab161 : PRE_first_tail_x15_r0_body.S1419.tab = PRE_first_tail_x15_r0_body.S1417.tab ++ PRE_first_tail_x15_r0_body.cws161.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace161 : PRE_first_tail_x15_r0_body.s1419.trace = PRE_first_tail_x15_r0_body.s1417.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext161 : PRE_first_tail_x15_r0_body.s1419.next = 2800920
kernel_rfl PRE_first_tail_x15_r0_body.ccounters161 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1419.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1419.ffi).mlx.nnext) = (21364, 18466)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue161 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1418.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1419.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa161.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp161 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1419.ffi).mlx.tokens.all (bSN 6937) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean161 : Conv.cleanListB 21364 131072 (fun r => Nat.ble 85456 r) PRE_first_tail_x15_r0_body.s1419
    (PRE_first_tail_x15_r0_body.wrB161 ++ (List.range 1).map (2800919 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs161 : bigsOutB 21364 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1419.ffi).mlx = true

end Host.Load.Run.Tpl
