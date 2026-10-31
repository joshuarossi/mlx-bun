import host.sim.template.a4pre_first_tail_x15_r0_body.H49
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

/-! The compaction after the merge at call site 164 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1583` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa164` into the merged state
`PRE_first_tail_x15_r0_body.s1582`. -/

def PRE_first_tail_x15_r0_body.pl164 : List Nat := [2803194]
def PRE_first_tail_x15_r0_body.nr164 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd164 : RData :=
  ⟨2803176, 2803195, Stage.setAll PTrie.nil [(2803175, 2803194)], Stage.setAll PTrie.nil [],
   21421, 21421, 18529, 18529, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa164 : Map :=
  Conv.Map.compact 2803175 2803195 7066 PRE_first_tail_x15_r0_body.pl164 (PRE_first_tail_x15_r0_body.nr164.map NumV.ref) PRE_first_tail_x15_r0_body.kd164.big
    PRE_first_tail_x15_r0_body.kd164.region PRE_first_tail_x15_r0_body.kd164.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws164 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs164 : List SymE := PRE_first_tail_x15_r0_body.nr164.map fun r => (nth? PRE_first_tail_x15_r0_body.S1582.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta164 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws164 PRE_first_tail_x15_r0_body.crs164
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB164 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab164 : PRE_first_tail_x15_r0_body.S1583.tab = PRE_first_tail_x15_r0_body.S1581.tab ++ PRE_first_tail_x15_r0_body.cws164.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace164 : PRE_first_tail_x15_r0_body.s1583.trace = PRE_first_tail_x15_r0_body.s1581.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext164 : PRE_first_tail_x15_r0_body.s1583.next = 2803176
kernel_rfl PRE_first_tail_x15_r0_body.ccounters164 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx.nnext) = (21421, 18529)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue164 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1582.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa164.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp164 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx.tokens.all (bSN 7066) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean164 : Conv.cleanListB 21421 131072 (fun r => Nat.ble 85684 r) PRE_first_tail_x15_r0_body.s1583
    (PRE_first_tail_x15_r0_body.wrB164 ++ (List.range 1).map (2803175 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs164 : bigsOutB 21421 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx = true

end Host.Load.Run.Tpl
