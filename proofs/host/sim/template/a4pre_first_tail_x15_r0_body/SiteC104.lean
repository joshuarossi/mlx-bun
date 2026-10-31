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

/-! The compaction after the merge at call site 104 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s921` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa104` into the merged state
`PRE_first_tail_x15_r0_body.s920`. -/

def PRE_first_tail_x15_r0_body.pl104 : List Nat := [2756105]
def PRE_first_tail_x15_r0_body.nr104 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd104 : RData :=
  ⟨2756096, 2756106, Stage.setAll PTrie.nil [(2756095, 2756105)], Stage.setAll PTrie.nil [],
   20241, 20241, 17344, 17344, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa104 : Map :=
  Conv.Map.compact 2756095 2756106 4501 PRE_first_tail_x15_r0_body.pl104 (PRE_first_tail_x15_r0_body.nr104.map NumV.ref) PRE_first_tail_x15_r0_body.kd104.big
    PRE_first_tail_x15_r0_body.kd104.region PRE_first_tail_x15_r0_body.kd104.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws104 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs104 : List SymE := PRE_first_tail_x15_r0_body.nr104.map fun r => (nth? PRE_first_tail_x15_r0_body.S920.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta104 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws104 PRE_first_tail_x15_r0_body.crs104
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB104 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab104 : PRE_first_tail_x15_r0_body.S921.tab = PRE_first_tail_x15_r0_body.S919.tab ++ PRE_first_tail_x15_r0_body.cws104.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace104 : PRE_first_tail_x15_r0_body.s921.trace = PRE_first_tail_x15_r0_body.s919.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext104 : PRE_first_tail_x15_r0_body.s921.next = 2756096
kernel_rfl PRE_first_tail_x15_r0_body.ccounters104 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx.nnext) = (20241, 17344)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue104 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s920.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa104.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp104 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx.tokens.all (bSN 4501) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean104 : Conv.cleanListB 20241 131072 (fun r => Nat.ble 80964 r) PRE_first_tail_x15_r0_body.s921
    (PRE_first_tail_x15_r0_body.wrB104 ++ (List.range 1).map (2756095 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs104 : bigsOutB 20241 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx = true

end Host.Load.Run.Tpl
