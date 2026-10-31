import host.sim.template.a4pre_first_tail_x15_r0_body.H51
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

/-! The compaction after the merge at call site 169 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1636` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa169` into the merged state
`PRE_first_tail_x15_r0_body.s1635`. -/

def PRE_first_tail_x15_r0_body.pl169 : List Nat := []
def PRE_first_tail_x15_r0_body.nr169 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd169 : RData :=
  ⟨2807795, 2807797, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21536, 21536, 18636, 18636, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa169 : Map :=
  Conv.Map.compact 2807795 2807797 7304 PRE_first_tail_x15_r0_body.pl169 (PRE_first_tail_x15_r0_body.nr169.map NumV.ref) PRE_first_tail_x15_r0_body.kd169.big
    PRE_first_tail_x15_r0_body.kd169.region PRE_first_tail_x15_r0_body.kd169.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws169 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs169 : List SymE := PRE_first_tail_x15_r0_body.nr169.map fun r => (nth? PRE_first_tail_x15_r0_body.S1635.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta169 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws169 PRE_first_tail_x15_r0_body.crs169
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB169 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab169 : PRE_first_tail_x15_r0_body.S1636.tab = PRE_first_tail_x15_r0_body.S1634.tab ++ PRE_first_tail_x15_r0_body.cws169.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace169 : PRE_first_tail_x15_r0_body.s1636.trace = PRE_first_tail_x15_r0_body.s1634.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext169 : PRE_first_tail_x15_r0_body.s1636.next = 2807795
kernel_rfl PRE_first_tail_x15_r0_body.ccounters169 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1636.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1636.ffi).mlx.nnext) = (21536, 18636)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue169 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1635.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1636.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa169.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp169 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1636.ffi).mlx.tokens.all (bSN 7304) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean169 : Conv.cleanListB 21536 131072 (fun r => Nat.ble 86144 r) PRE_first_tail_x15_r0_body.s1636
    (PRE_first_tail_x15_r0_body.wrB169 ++ (List.range 0).map (2807795 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs169 : bigsOutB 21536 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1636.ffi).mlx = true

end Host.Load.Run.Tpl
