import host.sim.template.a4pre_first_tail_x15_r0_body.H20
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

/-! The compaction after the merge at call site 72 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s646` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa72` into the merged state
`PRE_first_tail_x15_r0_body.s645`. -/

def PRE_first_tail_x15_r0_body.pl72 : List Nat := [2733071, 2732246, 2733077, 2733073, 2732248, 2733079]
def PRE_first_tail_x15_r0_body.nr72 : List Nat := [3191, 3190, 3166, 3174, 3179, 3184, 3189, 3163, 3164, 3165, 3172, 3173, 3161, 3168, 3169, 3170, 3171, 3167]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd72 : RData :=
  ⟨2731965, 2733114, Stage.setAll PTrie.nil [(2731959, 2733071), (2731960, 2732246), (2731961, 2733077), (2731962, 2733073), (2731963, 2732248), (2731964, 2733079)], Stage.setAll PTrie.nil [(19632, 19658), (19633, 19636), (19634, 19659)],
   19635, 19660, 16727, 16727, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3161, .ref 3191), (3162, .ref 3190), (3163, .ref 3166), (3164, .ref 3174), (3165, .ref 3179), (3166, .ref 3184), (3167, .ref 3189), (3168, .ref 3163), (3169, .ref 3164), (3170, .ref 3165), (3171, .ref 3172), (3172, .ref 3173), (3173, .ref 3161), (3174, .ref 3168), (3175, .ref 3169), (3176, .ref 3170), (3177, .ref 3171), (3178, .ref 3167)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa72 : Map :=
  Conv.Map.compact 2731959 2733114 3161 PRE_first_tail_x15_r0_body.pl72 (PRE_first_tail_x15_r0_body.nr72.map NumV.ref) PRE_first_tail_x15_r0_body.kd72.big
    PRE_first_tail_x15_r0_body.kd72.region PRE_first_tail_x15_r0_body.kd72.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws72 : List Nat := [2231, 2232, 2233, 2234, 2235, 2236, 2237, 2238, 2239, 2240, 2241, 2242, 2243, 2244, 2245, 2246, 2247, 2248]
noncomputable def PRE_first_tail_x15_r0_body.crs72 : List SymE := PRE_first_tail_x15_r0_body.nr72.map fun r => (nth? PRE_first_tail_x15_r0_body.S645.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta72 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws72 PRE_first_tail_x15_r0_body.crs72
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB72 : List Nat := [2665, 2672486, 2673467, 2731133, 2731678, 2731934]

kernel_rfl PRE_first_tail_x15_r0_body.ctab72 : PRE_first_tail_x15_r0_body.S646.tab = PRE_first_tail_x15_r0_body.S644.tab ++ PRE_first_tail_x15_r0_body.cws72.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace72 : PRE_first_tail_x15_r0_body.s646.trace = PRE_first_tail_x15_r0_body.s644.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext72 : PRE_first_tail_x15_r0_body.s646.next = 2731965
kernel_rfl PRE_first_tail_x15_r0_body.ccounters72 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s646.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s646.ffi).mlx.nnext) = (19635, 16727)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue72 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s645.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s646.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa72.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp72 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s646.ffi).mlx.tokens.all (bSN 3179) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean72 : Conv.cleanListB 19635 131072 (fun r => Nat.ble 78540 r) PRE_first_tail_x15_r0_body.s646
    (PRE_first_tail_x15_r0_body.wrB72 ++ (List.range 6).map (2731959 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs72 : bigsOutB 19635 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s646.ffi).mlx = true

end Host.Load.Run.Tpl
