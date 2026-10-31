import host.sim.template.a4pre_first_tail_x15_r0_body.H24
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

/-! The compaction after the merge at call site 81 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s794` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa81` into the merged state
`PRE_first_tail_x15_r0_body.s793`. -/

def PRE_first_tail_x15_r0_body.pl81 : List Nat := [2739354, 2739190, 2739242, 2739355, 2739356, 2739192, 2739244, 2739353, 2739352, 2739351, 2739350, 2739344, 2739295, 2739346, 2739297]
def PRE_first_tail_x15_r0_body.nr81 : List Nat := [3560, 3561, 3557, 3563, 3559, 3567, 3568, 3565, 3566]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd81 : RData :=
  ⟨2739007, 2739357, Stage.setAll PTrie.nil [(2738992, 2739354), (2738993, 2739190), (2738994, 2739242), (2738995, 2739355), (2738996, 2739356), (2738997, 2739192), (2738998, 2739244), (2738999, 2739353), (2739000, 2739352), (2739001, 2739351), (2739002, 2739350), (2739003, 2739344), (2739004, 2739295), (2739005, 2739346), (2739006, 2739297)], Stage.setAll PTrie.nil [(19809, 19811), (19810, 19812), (19811, 19814), (19812, 19813)],
   19813, 19815, 16904, 16904, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3552, .ref 3560), (3553, .ref 3561), (3554, .ref 3557), (3555, .ref 3563), (3556, .ref 3559), (3557, .ref 3567), (3558, .ref 3568), (3559, .ref 3565), (3560, .ref 3566)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa81 : Map :=
  Conv.Map.compact 2738992 2739357 3552 PRE_first_tail_x15_r0_body.pl81 (PRE_first_tail_x15_r0_body.nr81.map NumV.ref) PRE_first_tail_x15_r0_body.kd81.big
    PRE_first_tail_x15_r0_body.kd81.region PRE_first_tail_x15_r0_body.kd81.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws81 : List Nat := [2379, 2380, 2381, 2382, 2383, 2384, 2385, 2386, 2387]
noncomputable def PRE_first_tail_x15_r0_body.crs81 : List SymE := PRE_first_tail_x15_r0_body.nr81.map fun r => (nth? PRE_first_tail_x15_r0_body.S793.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta81 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws81 PRE_first_tail_x15_r0_body.crs81
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB81 : List Nat := [2665, 2672508, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab81 : PRE_first_tail_x15_r0_body.S794.tab = PRE_first_tail_x15_r0_body.S792.tab ++ PRE_first_tail_x15_r0_body.cws81.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace81 : PRE_first_tail_x15_r0_body.s794.trace = PRE_first_tail_x15_r0_body.s792.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext81 : PRE_first_tail_x15_r0_body.s794.next = 2739007
kernel_rfl PRE_first_tail_x15_r0_body.ccounters81 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi).mlx.nnext) = (19813, 16904)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue81 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s793.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa81.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp81 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi).mlx.tokens.all (bSN 3561) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean81 : Conv.cleanListB 19813 131072 (fun r => Nat.ble 79252 r) PRE_first_tail_x15_r0_body.s794
    (PRE_first_tail_x15_r0_body.wrB81 ++ (List.range 15).map (2738992 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs81 : bigsOutB 19813 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi).mlx = true

end Host.Load.Run.Tpl
