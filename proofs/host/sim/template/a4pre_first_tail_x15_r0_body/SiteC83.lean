import host.sim.template.a4pre_first_tail_x15_r0_body.H25
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

/-! The compaction after the merge at call site 83 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s806` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa83` into the merged state
`PRE_first_tail_x15_r0_body.s805`. -/

def PRE_first_tail_x15_r0_body.pl83 : List Nat := [2739887]
def PRE_first_tail_x15_r0_body.nr83 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd83 : RData :=
  ⟨2739878, 2739888, Stage.setAll PTrie.nil [(2739877, 2739887)], Stage.setAll PTrie.nil [],
   19833, 19833, 16918, 16918, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa83 : Map :=
  Conv.Map.compact 2739877 2739888 3601 PRE_first_tail_x15_r0_body.pl83 (PRE_first_tail_x15_r0_body.nr83.map NumV.ref) PRE_first_tail_x15_r0_body.kd83.big
    PRE_first_tail_x15_r0_body.kd83.region PRE_first_tail_x15_r0_body.kd83.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws83 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs83 : List SymE := PRE_first_tail_x15_r0_body.nr83.map fun r => (nth? PRE_first_tail_x15_r0_body.S805.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta83 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws83 PRE_first_tail_x15_r0_body.crs83
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB83 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab83 : PRE_first_tail_x15_r0_body.S806.tab = PRE_first_tail_x15_r0_body.S804.tab ++ PRE_first_tail_x15_r0_body.cws83.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace83 : PRE_first_tail_x15_r0_body.s806.trace = PRE_first_tail_x15_r0_body.s804.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext83 : PRE_first_tail_x15_r0_body.s806.next = 2739878
kernel_rfl PRE_first_tail_x15_r0_body.ccounters83 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s806.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s806.ffi).mlx.nnext) = (19833, 16918)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue83 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s805.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s806.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa83.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp83 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s806.ffi).mlx.tokens.all (bSN 3601) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean83 : Conv.cleanListB 19833 131072 (fun r => Nat.ble 79332 r) PRE_first_tail_x15_r0_body.s806
    (PRE_first_tail_x15_r0_body.wrB83 ++ (List.range 1).map (2739877 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs83 : bigsOutB 19833 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s806.ffi).mlx = true

end Host.Load.Run.Tpl
