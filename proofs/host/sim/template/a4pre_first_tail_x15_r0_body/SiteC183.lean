import host.sim.template.a4pre_first_tail_x15_r0_body.H50
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

/-! The compaction after the merge at call site 183 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1618` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa183` into the merged state
`PRE_first_tail_x15_r0_body.s1617`. -/

def PRE_first_tail_x15_r0_body.pl183 : List Nat := [2820099, 2819274, 2820105, 2820101, 2819276, 2820107]
def PRE_first_tail_x15_r0_body.nr183 : List Nat := [7937, 7936, 7912, 7920, 7925, 7930, 7935, 7909, 7910, 7911, 7918, 7919, 7907, 7914, 7915, 7916, 7917, 7913]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd183 : RData :=
  ⟨2818993, 2820142, Stage.setAll PTrie.nil [(2818987, 2820099), (2818988, 2819274), (2818989, 2820105), (2818990, 2820101), (2818991, 2819276), (2818992, 2820107)], Stage.setAll PTrie.nil [(21813, 21839), (21814, 21817), (21815, 21840)],
   21816, 21841, 18923, 18923, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7907, .ref 7937), (7908, .ref 7936), (7909, .ref 7912), (7910, .ref 7920), (7911, .ref 7925), (7912, .ref 7930), (7913, .ref 7935), (7914, .ref 7909), (7915, .ref 7910), (7916, .ref 7911), (7917, .ref 7918), (7918, .ref 7919), (7919, .ref 7907), (7920, .ref 7914), (7921, .ref 7915), (7922, .ref 7916), (7923, .ref 7917), (7924, .ref 7913)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa183 : Map :=
  Conv.Map.compact 2818987 2820142 7907 PRE_first_tail_x15_r0_body.pl183 (PRE_first_tail_x15_r0_body.nr183.map NumV.ref) PRE_first_tail_x15_r0_body.kd183.big
    PRE_first_tail_x15_r0_body.kd183.region PRE_first_tail_x15_r0_body.kd183.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws183 : List Nat := [4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135]
noncomputable def PRE_first_tail_x15_r0_body.crs183 : List SymE := PRE_first_tail_x15_r0_body.nr183.map fun r => (nth? PRE_first_tail_x15_r0_body.S1617.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta183 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws183 PRE_first_tail_x15_r0_body.crs183
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB183 : List Nat := [2665, 2672770, 2673467, 2818161, 2818706, 2818962]

kernel_rfl PRE_first_tail_x15_r0_body.ctab183 : PRE_first_tail_x15_r0_body.S1618.tab = PRE_first_tail_x15_r0_body.S1616.tab ++ PRE_first_tail_x15_r0_body.cws183.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace183 : PRE_first_tail_x15_r0_body.s1618.trace = PRE_first_tail_x15_r0_body.s1616.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext183 : PRE_first_tail_x15_r0_body.s1618.next = 2818993
kernel_rfl PRE_first_tail_x15_r0_body.ccounters183 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1618.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1618.ffi).mlx.nnext) = (21816, 18923)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue183 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1617.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1618.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa183.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp183 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1618.ffi).mlx.tokens.all (bSN 7925) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean183 : Conv.cleanListB 21816 131072 (fun r => Nat.ble 87264 r) PRE_first_tail_x15_r0_body.s1618
    (PRE_first_tail_x15_r0_body.wrB183 ++ (List.range 6).map (2818987 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs183 : bigsOutB 21816 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1618.ffi).mlx = true

end Host.Load.Run.Tpl
