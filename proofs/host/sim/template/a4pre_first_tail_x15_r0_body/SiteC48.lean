import host.sim.template.a4pre_first_tail_x15_r0_body.H13
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

/-! The compaction after the merge at call site 48 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s436` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa48` into the merged state
`PRE_first_tail_x15_r0_body.s435`. -/

def PRE_first_tail_x15_r0_body.pl48 : List Nat := [2714235, 2713410, 2714241, 2714237, 2713412, 2714243]
def PRE_first_tail_x15_r0_body.nr48 : List Nat := [2165, 2164, 2140, 2148, 2153, 2158, 2163, 2137, 2138, 2139, 2146, 2147, 2135, 2142, 2143, 2144, 2145, 2141]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd48 : RData :=
  ⟨2713129, 2714278, Stage.setAll PTrie.nil [(2713123, 2714235), (2713124, 2713410), (2713125, 2714241), (2713126, 2714237), (2713127, 2713412), (2713128, 2714243)], Stage.setAll PTrie.nil [(19160, 19186), (19161, 19164), (19162, 19187)],
   19163, 19188, 16253, 16253, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2135, .ref 2165), (2136, .ref 2164), (2137, .ref 2140), (2138, .ref 2148), (2139, .ref 2153), (2140, .ref 2158), (2141, .ref 2163), (2142, .ref 2137), (2143, .ref 2138), (2144, .ref 2139), (2145, .ref 2146), (2146, .ref 2147), (2147, .ref 2135), (2148, .ref 2142), (2149, .ref 2143), (2150, .ref 2144), (2151, .ref 2145), (2152, .ref 2141)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa48 : Map :=
  Conv.Map.compact 2713123 2714278 2135 PRE_first_tail_x15_r0_body.pl48 (PRE_first_tail_x15_r0_body.nr48.map NumV.ref) PRE_first_tail_x15_r0_body.kd48.big
    PRE_first_tail_x15_r0_body.kd48.region PRE_first_tail_x15_r0_body.kd48.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws48 : List Nat := [1827, 1828, 1829, 1830, 1831, 1832, 1833, 1834, 1835, 1836, 1837, 1838, 1839, 1840, 1841, 1842, 1843, 1844]
noncomputable def PRE_first_tail_x15_r0_body.crs48 : List SymE := PRE_first_tail_x15_r0_body.nr48.map fun r => (nth? PRE_first_tail_x15_r0_body.S435.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta48 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws48 PRE_first_tail_x15_r0_body.crs48
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB48 : List Nat := [2665, 2672424, 2673467, 2712297, 2712842, 2713098]

kernel_rfl PRE_first_tail_x15_r0_body.ctab48 : PRE_first_tail_x15_r0_body.S436.tab = PRE_first_tail_x15_r0_body.S434.tab ++ PRE_first_tail_x15_r0_body.cws48.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace48 : PRE_first_tail_x15_r0_body.s436.trace = PRE_first_tail_x15_r0_body.s434.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext48 : PRE_first_tail_x15_r0_body.s436.next = 2713129
kernel_rfl PRE_first_tail_x15_r0_body.ccounters48 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s436.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s436.ffi).mlx.nnext) = (19163, 16253)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue48 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s435.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s436.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa48.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp48 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s436.ffi).mlx.tokens.all (bSN 2153) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean48 : Conv.cleanListB 19163 131072 (fun r => Nat.ble 76652 r) PRE_first_tail_x15_r0_body.s436
    (PRE_first_tail_x15_r0_body.wrB48 ++ (List.range 6).map (2713123 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs48 : bigsOutB 19163 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s436.ffi).mlx = true

end Host.Load.Run.Tpl
