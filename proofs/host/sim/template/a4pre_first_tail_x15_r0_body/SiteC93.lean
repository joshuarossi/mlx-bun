import host.sim.template.a4pre_first_tail_x15_r0_body.H28
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

/-! The compaction after the merge at call site 93 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s909` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa93` into the merged state
`PRE_first_tail_x15_r0_body.s908`. -/

def PRE_first_tail_x15_r0_body.pl93 : List Nat := [2748770, 2748606, 2748658, 2748771, 2748772, 2748608, 2748660, 2748769, 2748768, 2748767, 2748766, 2748760, 2748711, 2748762, 2748713]
def PRE_first_tail_x15_r0_body.nr93 : List Nat := [4073, 4074, 4070, 4076, 4072, 4080, 4081, 4078, 4079]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd93 : RData :=
  ⟨2748423, 2748773, Stage.setAll PTrie.nil [(2748408, 2748770), (2748409, 2748606), (2748410, 2748658), (2748411, 2748771), (2748412, 2748772), (2748413, 2748608), (2748414, 2748660), (2748415, 2748769), (2748416, 2748768), (2748417, 2748767), (2748418, 2748766), (2748419, 2748760), (2748420, 2748711), (2748421, 2748762), (2748422, 2748713)], Stage.setAll PTrie.nil [(20045, 20047), (20046, 20048), (20047, 20050), (20048, 20049)],
   20049, 20051, 17141, 17141, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4065, .ref 4073), (4066, .ref 4074), (4067, .ref 4070), (4068, .ref 4076), (4069, .ref 4072), (4070, .ref 4080), (4071, .ref 4081), (4072, .ref 4078), (4073, .ref 4079)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa93 : Map :=
  Conv.Map.compact 2748408 2748773 4065 PRE_first_tail_x15_r0_body.pl93 (PRE_first_tail_x15_r0_body.nr93.map NumV.ref) PRE_first_tail_x15_r0_body.kd93.big
    PRE_first_tail_x15_r0_body.kd93.region PRE_first_tail_x15_r0_body.kd93.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws93 : List Nat := [2578, 2579, 2580, 2581, 2582, 2583, 2584, 2585, 2586]
noncomputable def PRE_first_tail_x15_r0_body.crs93 : List SymE := PRE_first_tail_x15_r0_body.nr93.map fun r => (nth? PRE_first_tail_x15_r0_body.S908.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta93 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws93 PRE_first_tail_x15_r0_body.crs93
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB93 : List Nat := [2665, 2672539, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab93 : PRE_first_tail_x15_r0_body.S909.tab = PRE_first_tail_x15_r0_body.S907.tab ++ PRE_first_tail_x15_r0_body.cws93.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace93 : PRE_first_tail_x15_r0_body.s909.trace = PRE_first_tail_x15_r0_body.s907.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext93 : PRE_first_tail_x15_r0_body.s909.next = 2748423
kernel_rfl PRE_first_tail_x15_r0_body.ccounters93 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx.nnext) = (20049, 17141)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue93 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s908.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa93.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp93 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx.tokens.all (bSN 4074) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean93 : Conv.cleanListB 20049 131072 (fun r => Nat.ble 80196 r) PRE_first_tail_x15_r0_body.s909
    (PRE_first_tail_x15_r0_body.wrB93 ++ (List.range 15).map (2748408 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs93 : bigsOutB 20049 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx = true

end Host.Load.Run.Tpl
