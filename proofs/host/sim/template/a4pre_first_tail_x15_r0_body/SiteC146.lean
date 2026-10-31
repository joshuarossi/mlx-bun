import host.sim.template.a4pre_first_tail_x15_r0_body.H44
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

/-! The compaction after the merge at call site 146 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1410` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa146` into the merged state
`PRE_first_tail_x15_r0_body.s1409`. -/

def PRE_first_tail_x15_r0_body.pl146 : List Nat := [2789262]
def PRE_first_tail_x15_r0_body.nr146 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd146 : RData :=
  ⟨2789244, 2789263, Stage.setAll PTrie.nil [(2789243, 2789262)], Stage.setAll PTrie.nil [],
   21071, 21071, 18166, 18166, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa146 : Map :=
  Conv.Map.compact 2789243 2789263 6295 PRE_first_tail_x15_r0_body.pl146 (PRE_first_tail_x15_r0_body.nr146.map NumV.ref) PRE_first_tail_x15_r0_body.kd146.big
    PRE_first_tail_x15_r0_body.kd146.region PRE_first_tail_x15_r0_body.kd146.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws146 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs146 : List SymE := PRE_first_tail_x15_r0_body.nr146.map fun r => (nth? PRE_first_tail_x15_r0_body.S1409.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta146 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws146 PRE_first_tail_x15_r0_body.crs146
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB146 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab146 : PRE_first_tail_x15_r0_body.S1410.tab = PRE_first_tail_x15_r0_body.S1408.tab ++ PRE_first_tail_x15_r0_body.cws146.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace146 : PRE_first_tail_x15_r0_body.s1410.trace = PRE_first_tail_x15_r0_body.s1408.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext146 : PRE_first_tail_x15_r0_body.s1410.next = 2789244
kernel_rfl PRE_first_tail_x15_r0_body.ccounters146 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1410.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1410.ffi).mlx.nnext) = (21071, 18166)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue146 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1409.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1410.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa146.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp146 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1410.ffi).mlx.tokens.all (bSN 6295) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean146 : Conv.cleanListB 21071 131072 (fun r => Nat.ble 84284 r) PRE_first_tail_x15_r0_body.s1410
    (PRE_first_tail_x15_r0_body.wrB146 ++ (List.range 1).map (2789243 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs146 : bigsOutB 21071 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1410.ffi).mlx = true

end Host.Load.Run.Tpl
