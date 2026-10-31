import host.sim.template.a4pre_first_tail_x15_r0_body.H16
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

/-! The compaction after the merge at call site 54 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s536` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa54` into the merged state
`PRE_first_tail_x15_r0_body.s535`. -/

def PRE_first_tail_x15_r0_body.pl54 : List Nat := [2718755, 2717930, 2718761, 2718757, 2717932, 2718763]
def PRE_first_tail_x15_r0_body.nr54 : List Nat := [2423, 2422, 2398, 2406, 2411, 2416, 2421, 2395, 2396, 2397, 2404, 2405, 2393, 2400, 2401, 2402, 2403, 2399]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd54 : RData :=
  ⟨2717649, 2718798, Stage.setAll PTrie.nil [(2717643, 2718755), (2717644, 2717930), (2717645, 2718761), (2717646, 2718757), (2717647, 2717932), (2717648, 2718763)], Stage.setAll PTrie.nil [(19274, 19300), (19275, 19278), (19276, 19301)],
   19277, 19302, 16379, 16379, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2393, .ref 2423), (2394, .ref 2422), (2395, .ref 2398), (2396, .ref 2406), (2397, .ref 2411), (2398, .ref 2416), (2399, .ref 2421), (2400, .ref 2395), (2401, .ref 2396), (2402, .ref 2397), (2403, .ref 2404), (2404, .ref 2405), (2405, .ref 2393), (2406, .ref 2400), (2407, .ref 2401), (2408, .ref 2402), (2409, .ref 2403), (2410, .ref 2399)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa54 : Map :=
  Conv.Map.compact 2717643 2718798 2393 PRE_first_tail_x15_r0_body.pl54 (PRE_first_tail_x15_r0_body.nr54.map NumV.ref) PRE_first_tail_x15_r0_body.kd54.big
    PRE_first_tail_x15_r0_body.kd54.region PRE_first_tail_x15_r0_body.kd54.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws54 : List Nat := [1947, 1948, 1949, 1950, 1951, 1952, 1953, 1954, 1955, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1963, 1964]
noncomputable def PRE_first_tail_x15_r0_body.crs54 : List SymE := PRE_first_tail_x15_r0_body.nr54.map fun r => (nth? PRE_first_tail_x15_r0_body.S535.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta54 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws54 PRE_first_tail_x15_r0_body.crs54
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB54 : List Nat := [2665, 2672434, 2673467, 2716817, 2717362, 2717618]

kernel_rfl PRE_first_tail_x15_r0_body.ctab54 : PRE_first_tail_x15_r0_body.S536.tab = PRE_first_tail_x15_r0_body.S534.tab ++ PRE_first_tail_x15_r0_body.cws54.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace54 : PRE_first_tail_x15_r0_body.s536.trace = PRE_first_tail_x15_r0_body.s534.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext54 : PRE_first_tail_x15_r0_body.s536.next = 2717649
kernel_rfl PRE_first_tail_x15_r0_body.ccounters54 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.nnext) = (19277, 16379)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue54 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s535.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa54.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp54 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.tokens.all (bSN 2411) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean54 : Conv.cleanListB 19277 131072 (fun r => Nat.ble 77108 r) PRE_first_tail_x15_r0_body.s536
    (PRE_first_tail_x15_r0_body.wrB54 ++ (List.range 6).map (2717643 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs54 : bigsOutB 19277 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx = true

end Host.Load.Run.Tpl
