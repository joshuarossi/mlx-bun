import host.sim.template.a4pre_first_tail_x15_r0_body.H14
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

/-! The compaction after the merge at call site 51 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s463` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa51` into the merged state
`PRE_first_tail_x15_r0_body.s462`. -/

def PRE_first_tail_x15_r0_body.pl51 : List Nat := [2716495, 2715670, 2716501, 2716497, 2715672, 2716503]
def PRE_first_tail_x15_r0_body.nr51 : List Nat := [2294, 2293, 2269, 2277, 2282, 2287, 2292, 2266, 2267, 2268, 2275, 2276, 2264, 2271, 2272, 2273, 2274, 2270]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd51 : RData :=
  ⟨2715389, 2716538, Stage.setAll PTrie.nil [(2715383, 2716495), (2715384, 2715670), (2715385, 2716501), (2715386, 2716497), (2715387, 2715672), (2715388, 2716503)], Stage.setAll PTrie.nil [(19217, 19243), (19218, 19221), (19219, 19244)],
   19220, 19245, 16316, 16316, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2264, .ref 2294), (2265, .ref 2293), (2266, .ref 2269), (2267, .ref 2277), (2268, .ref 2282), (2269, .ref 2287), (2270, .ref 2292), (2271, .ref 2266), (2272, .ref 2267), (2273, .ref 2268), (2274, .ref 2275), (2275, .ref 2276), (2276, .ref 2264), (2277, .ref 2271), (2278, .ref 2272), (2279, .ref 2273), (2280, .ref 2274), (2281, .ref 2270)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa51 : Map :=
  Conv.Map.compact 2715383 2716538 2264 PRE_first_tail_x15_r0_body.pl51 (PRE_first_tail_x15_r0_body.nr51.map NumV.ref) PRE_first_tail_x15_r0_body.kd51.big
    PRE_first_tail_x15_r0_body.kd51.region PRE_first_tail_x15_r0_body.kd51.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws51 : List Nat := [1887, 1888, 1889, 1890, 1891, 1892, 1893, 1894, 1895, 1896, 1897, 1898, 1899, 1900, 1901, 1902, 1903, 1904]
noncomputable def PRE_first_tail_x15_r0_body.crs51 : List SymE := PRE_first_tail_x15_r0_body.nr51.map fun r => (nth? PRE_first_tail_x15_r0_body.S462.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta51 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws51 PRE_first_tail_x15_r0_body.crs51
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB51 : List Nat := [2665, 2672429, 2673467, 2714557, 2715102, 2715358]

kernel_rfl PRE_first_tail_x15_r0_body.ctab51 : PRE_first_tail_x15_r0_body.S463.tab = PRE_first_tail_x15_r0_body.S461.tab ++ PRE_first_tail_x15_r0_body.cws51.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace51 : PRE_first_tail_x15_r0_body.s463.trace = PRE_first_tail_x15_r0_body.s461.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext51 : PRE_first_tail_x15_r0_body.s463.next = 2715389
kernel_rfl PRE_first_tail_x15_r0_body.ccounters51 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s463.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s463.ffi).mlx.nnext) = (19220, 16316)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue51 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s462.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s463.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa51.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp51 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s463.ffi).mlx.tokens.all (bSN 2282) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean51 : Conv.cleanListB 19220 131072 (fun r => Nat.ble 76880 r) PRE_first_tail_x15_r0_body.s463
    (PRE_first_tail_x15_r0_body.wrB51 ++ (List.range 6).map (2715383 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs51 : bigsOutB 19220 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s463.ffi).mlx = true

end Host.Load.Run.Tpl
