import host.sim.template.a4pre_first_tail_x15_r0_body.H42
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

/-! The compaction after the merge at call site 154 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1361` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa154` into the merged state
`PRE_first_tail_x15_r0_body.s1360`. -/

def PRE_first_tail_x15_r0_body.pl154 : List Nat := []
def PRE_first_tail_x15_r0_body.nr154 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd154 : RData :=
  ⟨2796097, 2796099, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21242, 21242, 18336, 18336, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa154 : Map :=
  Conv.Map.compact 2796097 2796099 6662 PRE_first_tail_x15_r0_body.pl154 (PRE_first_tail_x15_r0_body.nr154.map NumV.ref) PRE_first_tail_x15_r0_body.kd154.big
    PRE_first_tail_x15_r0_body.kd154.region PRE_first_tail_x15_r0_body.kd154.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws154 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs154 : List SymE := PRE_first_tail_x15_r0_body.nr154.map fun r => (nth? PRE_first_tail_x15_r0_body.S1360.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta154 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws154 PRE_first_tail_x15_r0_body.crs154
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB154 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab154 : PRE_first_tail_x15_r0_body.S1361.tab = PRE_first_tail_x15_r0_body.S1359.tab ++ PRE_first_tail_x15_r0_body.cws154.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace154 : PRE_first_tail_x15_r0_body.s1361.trace = PRE_first_tail_x15_r0_body.s1359.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext154 : PRE_first_tail_x15_r0_body.s1361.next = 2796097
kernel_rfl PRE_first_tail_x15_r0_body.ccounters154 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1361.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1361.ffi).mlx.nnext) = (21242, 18336)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue154 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1360.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1361.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa154.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp154 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1361.ffi).mlx.tokens.all (bSN 6662) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean154 : Conv.cleanListB 21242 131072 (fun r => Nat.ble 84968 r) PRE_first_tail_x15_r0_body.s1361
    (PRE_first_tail_x15_r0_body.wrB154 ++ (List.range 0).map (2796097 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs154 : bigsOutB 21242 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1361.ffi).mlx = true

end Host.Load.Run.Tpl
