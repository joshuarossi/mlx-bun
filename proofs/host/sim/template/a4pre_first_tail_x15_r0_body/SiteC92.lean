import host.sim.template.a4pre_first_tail_x15_r0_body.H27
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

/-! The compaction after the merge at call site 92 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s893` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa92` into the merged state
`PRE_first_tail_x15_r0_body.s892`. -/

def PRE_first_tail_x15_r0_body.pl92 : List Nat := [2746681]
def PRE_first_tail_x15_r0_body.nr92 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd92 : RData :=
  ⟨2746672, 2746682, Stage.setAll PTrie.nil [(2746671, 2746681)], Stage.setAll PTrie.nil [],
   20005, 20005, 17107, 17107, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa92 : Map :=
  Conv.Map.compact 2746671 2746682 3988 PRE_first_tail_x15_r0_body.pl92 (PRE_first_tail_x15_r0_body.nr92.map NumV.ref) PRE_first_tail_x15_r0_body.kd92.big
    PRE_first_tail_x15_r0_body.kd92.region PRE_first_tail_x15_r0_body.kd92.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws92 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs92 : List SymE := PRE_first_tail_x15_r0_body.nr92.map fun r => (nth? PRE_first_tail_x15_r0_body.S892.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta92 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws92 PRE_first_tail_x15_r0_body.crs92
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB92 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab92 : PRE_first_tail_x15_r0_body.S893.tab = PRE_first_tail_x15_r0_body.S891.tab ++ PRE_first_tail_x15_r0_body.cws92.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace92 : PRE_first_tail_x15_r0_body.s893.trace = PRE_first_tail_x15_r0_body.s891.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext92 : PRE_first_tail_x15_r0_body.s893.next = 2746672
kernel_rfl PRE_first_tail_x15_r0_body.ccounters92 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s893.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s893.ffi).mlx.nnext) = (20005, 17107)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue92 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s892.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s893.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa92.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp92 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s893.ffi).mlx.tokens.all (bSN 3988) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean92 : Conv.cleanListB 20005 131072 (fun r => Nat.ble 80020 r) PRE_first_tail_x15_r0_body.s893
    (PRE_first_tail_x15_r0_body.wrB92 ++ (List.range 1).map (2746671 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs92 : bigsOutB 20005 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s893.ffi).mlx = true

end Host.Load.Run.Tpl
