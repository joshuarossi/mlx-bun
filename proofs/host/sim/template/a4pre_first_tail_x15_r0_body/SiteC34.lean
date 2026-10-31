import host.sim.template.a4pre_first_tail_x15_r0_body.H10
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

/-! The compaction after the merge at call site 34 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s342` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa34` into the merged state
`PRE_first_tail_x15_r0_body.s341`. -/

def PRE_first_tail_x15_r0_body.pl34 : List Nat := []
def PRE_first_tail_x15_r0_body.nr34 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd34 : RData :=
  ⟨2701917, 2701919, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18882, 18882, 15966, 15966, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa34 : Map :=
  Conv.Map.compact 2701917 2701919 1532 PRE_first_tail_x15_r0_body.pl34 (PRE_first_tail_x15_r0_body.nr34.map NumV.ref) PRE_first_tail_x15_r0_body.kd34.big
    PRE_first_tail_x15_r0_body.kd34.region PRE_first_tail_x15_r0_body.kd34.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws34 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs34 : List SymE := PRE_first_tail_x15_r0_body.nr34.map fun r => (nth? PRE_first_tail_x15_r0_body.S341.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta34 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws34 PRE_first_tail_x15_r0_body.crs34
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB34 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab34 : PRE_first_tail_x15_r0_body.S342.tab = PRE_first_tail_x15_r0_body.S340.tab ++ PRE_first_tail_x15_r0_body.cws34.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace34 : PRE_first_tail_x15_r0_body.s342.trace = PRE_first_tail_x15_r0_body.s340.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext34 : PRE_first_tail_x15_r0_body.s342.next = 2701917
kernel_rfl PRE_first_tail_x15_r0_body.ccounters34 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.nnext) = (18882, 15966)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue34 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s341.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa34.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp34 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.tokens.all (bSN 1532) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean34 : Conv.cleanListB 18882 131072 (fun r => Nat.ble 75528 r) PRE_first_tail_x15_r0_body.s342
    (PRE_first_tail_x15_r0_body.wrB34 ++ (List.range 0).map (2701917 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs34 : bigsOutB 18882 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx = true

end Host.Load.Run.Tpl
