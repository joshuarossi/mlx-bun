import host.sim.template.a4pre_first_tail_x15_r0_body.H52
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

/-! The compaction after the merge at call site 189 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1669` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa189` into the merged state
`PRE_first_tail_x15_r0_body.s1668`. -/

def PRE_first_tail_x15_r0_body.pl189 : List Nat := [2824130, 2823966, 2824018, 2824131, 2824132, 2823968, 2824020, 2824129, 2824128, 2824127, 2824126, 2824120, 2824071, 2824122, 2824073]
def PRE_first_tail_x15_r0_body.nr189 : List Nat := [8177, 8178, 8174, 8180, 8176, 8184, 8185, 8182, 8183]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd189 : RData :=
  ⟨2823783, 2824133, Stage.setAll PTrie.nil [(2823768, 2824130), (2823769, 2823966), (2823770, 2824018), (2823771, 2824131), (2823772, 2824132), (2823773, 2823968), (2823774, 2824020), (2823775, 2824129), (2823776, 2824128), (2823777, 2824127), (2823778, 2824126), (2823779, 2824120), (2823780, 2824071), (2823781, 2824122), (2823782, 2824073)], Stage.setAll PTrie.nil [(21933, 21935), (21934, 21936), (21935, 21938), (21936, 21937)],
   21937, 21939, 19037, 19037, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(8169, .ref 8177), (8170, .ref 8178), (8171, .ref 8174), (8172, .ref 8180), (8173, .ref 8176), (8174, .ref 8184), (8175, .ref 8185), (8176, .ref 8182), (8177, .ref 8183)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa189 : Map :=
  Conv.Map.compact 2823768 2824133 8169 PRE_first_tail_x15_r0_body.pl189 (PRE_first_tail_x15_r0_body.nr189.map NumV.ref) PRE_first_tail_x15_r0_body.kd189.big
    PRE_first_tail_x15_r0_body.kd189.region PRE_first_tail_x15_r0_body.kd189.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws189 : List Nat := [4218, 4219, 4220, 4221, 4222, 4223, 4224, 4225, 4226]
noncomputable def PRE_first_tail_x15_r0_body.crs189 : List SymE := PRE_first_tail_x15_r0_body.nr189.map fun r => (nth? PRE_first_tail_x15_r0_body.S1668.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta189 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws189 PRE_first_tail_x15_r0_body.crs189
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB189 : List Nat := [2665, 2672787, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab189 : PRE_first_tail_x15_r0_body.S1669.tab = PRE_first_tail_x15_r0_body.S1667.tab ++ PRE_first_tail_x15_r0_body.cws189.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace189 : PRE_first_tail_x15_r0_body.s1669.trace = PRE_first_tail_x15_r0_body.s1667.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext189 : PRE_first_tail_x15_r0_body.s1669.next = 2823783
kernel_rfl PRE_first_tail_x15_r0_body.ccounters189 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx.nnext) = (21937, 19037)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue189 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1668.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa189.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp189 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx.tokens.all (bSN 8178) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean189 : Conv.cleanListB 21937 131072 (fun r => Nat.ble 87748 r) PRE_first_tail_x15_r0_body.s1669
    (PRE_first_tail_x15_r0_body.wrB189 ++ (List.range 15).map (2823768 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs189 : bigsOutB 21937 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx = true

end Host.Load.Run.Tpl
