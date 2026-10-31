import host.sim.template.a4pre_first_tail_x15_r0_body.H4
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

/-! The compaction after the merge at call site 13 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s128` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa13` into the merged state
`PRE_first_tail_x15_r0_body.s127`. -/

def PRE_first_tail_x15_r0_body.pl13 : List Nat := []
def PRE_first_tail_x15_r0_body.nr13 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd13 : RData :=
  ⟨2685371, 2685373, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18468, 18468, 15555, 15555, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa13 : Map :=
  Conv.Map.compact 2685371 2685373 635 PRE_first_tail_x15_r0_body.pl13 (PRE_first_tail_x15_r0_body.nr13.map NumV.ref) PRE_first_tail_x15_r0_body.kd13.big
    PRE_first_tail_x15_r0_body.kd13.region PRE_first_tail_x15_r0_body.kd13.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws13 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs13 : List SymE := PRE_first_tail_x15_r0_body.nr13.map fun r => (nth? PRE_first_tail_x15_r0_body.S127.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta13 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws13 PRE_first_tail_x15_r0_body.crs13
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB13 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab13 : PRE_first_tail_x15_r0_body.S128.tab = PRE_first_tail_x15_r0_body.S126.tab ++ PRE_first_tail_x15_r0_body.cws13.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace13 : PRE_first_tail_x15_r0_body.s128.trace = PRE_first_tail_x15_r0_body.s126.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext13 : PRE_first_tail_x15_r0_body.s128.next = 2685371
kernel_rfl PRE_first_tail_x15_r0_body.ccounters13 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s128.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s128.ffi).mlx.nnext) = (18468, 15555)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue13 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s127.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s128.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa13.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp13 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s128.ffi).mlx.tokens.all (bSN 635) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean13 : Conv.cleanListB 18468 131072 (fun r => Nat.ble 73872 r) PRE_first_tail_x15_r0_body.s128
    (PRE_first_tail_x15_r0_body.wrB13 ++ (List.range 0).map (2685371 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs13 : bigsOutB 18468 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s128.ffi).mlx = true

end Host.Load.Run.Tpl
