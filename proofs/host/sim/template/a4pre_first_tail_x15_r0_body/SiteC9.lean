import host.sim.template.a4pre_first_tail_x15_r0_body.H3
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

/-! The compaction after the merge at call site 9 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s104` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa9` into the merged state
`PRE_first_tail_x15_r0_body.s103`. -/

def PRE_first_tail_x15_r0_body.pl9 : List Nat := [2682856, 2682692, 2682744, 2682857, 2682858, 2682694, 2682746, 2682855, 2682854, 2682853, 2682852, 2682846, 2682797, 2682848, 2682799]
def PRE_first_tail_x15_r0_body.nr9 : List Nat := [482, 483, 479, 485, 481, 489, 490, 487, 488]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd9 : RData :=
  ⟨2682509, 2682859, Stage.setAll PTrie.nil [(2682494, 2682856), (2682495, 2682692), (2682496, 2682744), (2682497, 2682857), (2682498, 2682858), (2682499, 2682694), (2682500, 2682746), (2682501, 2682855), (2682502, 2682854), (2682503, 2682853), (2682504, 2682852), (2682505, 2682846), (2682506, 2682797), (2682507, 2682848), (2682508, 2682799)], Stage.setAll PTrie.nil [(18393, 18395), (18394, 18396), (18395, 18398), (18396, 18397)],
   18397, 18399, 15482, 15482, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(474, .ref 482), (475, .ref 483), (476, .ref 479), (477, .ref 485), (478, .ref 481), (479, .ref 489), (480, .ref 490), (481, .ref 487), (482, .ref 488)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa9 : Map :=
  Conv.Map.compact 2682494 2682859 474 PRE_first_tail_x15_r0_body.pl9 (PRE_first_tail_x15_r0_body.nr9.map NumV.ref) PRE_first_tail_x15_r0_body.kd9.big
    PRE_first_tail_x15_r0_body.kd9.region PRE_first_tail_x15_r0_body.kd9.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws9 : List Nat := [1185, 1186, 1187, 1188, 1189, 1190, 1191, 1192, 1193]
noncomputable def PRE_first_tail_x15_r0_body.crs9 : List SymE := PRE_first_tail_x15_r0_body.nr9.map fun r => (nth? PRE_first_tail_x15_r0_body.S103.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta9 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws9 PRE_first_tail_x15_r0_body.crs9
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB9 : List Nat := [2665, 2672322, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab9 : PRE_first_tail_x15_r0_body.S104.tab = PRE_first_tail_x15_r0_body.S102.tab ++ PRE_first_tail_x15_r0_body.cws9.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace9 : PRE_first_tail_x15_r0_body.s104.trace = PRE_first_tail_x15_r0_body.s102.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext9 : PRE_first_tail_x15_r0_body.s104.next = 2682509
kernel_rfl PRE_first_tail_x15_r0_body.ccounters9 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx.nnext) = (18397, 15482)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue9 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s103.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa9.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp9 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx.tokens.all (bSN 483) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean9 : Conv.cleanListB 18397 131072 (fun r => Nat.ble 73588 r) PRE_first_tail_x15_r0_body.s104
    (PRE_first_tail_x15_r0_body.wrB9 ++ (List.range 15).map (2682494 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs9 : bigsOutB 18397 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx = true

end Host.Load.Run.Tpl
