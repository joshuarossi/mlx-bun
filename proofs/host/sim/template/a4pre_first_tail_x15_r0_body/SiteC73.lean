import host.sim.template.a4pre_first_tail_x15_r0_body.H22
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

/-! The compaction after the merge at call site 73 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s716` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa73` into the merged state
`PRE_first_tail_x15_r0_body.s715`. -/

def PRE_first_tail_x15_r0_body.pl73 : List Nat := []
def PRE_first_tail_x15_r0_body.nr73 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd73 : RData :=
  ⟨2732455, 2732457, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19648, 19648, 16740, 16740, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa73 : Map :=
  Conv.Map.compact 2732455 2732457 3200 PRE_first_tail_x15_r0_body.pl73 (PRE_first_tail_x15_r0_body.nr73.map NumV.ref) PRE_first_tail_x15_r0_body.kd73.big
    PRE_first_tail_x15_r0_body.kd73.region PRE_first_tail_x15_r0_body.kd73.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws73 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs73 : List SymE := PRE_first_tail_x15_r0_body.nr73.map fun r => (nth? PRE_first_tail_x15_r0_body.S715.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta73 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws73 PRE_first_tail_x15_r0_body.crs73
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB73 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab73 : PRE_first_tail_x15_r0_body.S716.tab = PRE_first_tail_x15_r0_body.S714.tab ++ PRE_first_tail_x15_r0_body.cws73.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace73 : PRE_first_tail_x15_r0_body.s716.trace = PRE_first_tail_x15_r0_body.s714.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext73 : PRE_first_tail_x15_r0_body.s716.next = 2732455
kernel_rfl PRE_first_tail_x15_r0_body.ccounters73 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.nnext) = (19648, 16740)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue73 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s715.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa73.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp73 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.tokens.all (bSN 3200) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean73 : Conv.cleanListB 19648 131072 (fun r => Nat.ble 78592 r) PRE_first_tail_x15_r0_body.s716
    (PRE_first_tail_x15_r0_body.wrB73 ++ (List.range 0).map (2732455 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs73 : bigsOutB 19648 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx = true

end Host.Load.Run.Tpl
