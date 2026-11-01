import host.sim.template.a4pre_first_tail_x6_r0_body.m.B00
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen
import host.sim.stage.Mlx
import host.sim.conv.Closed
import host.sim.conv.NClean
import host.sim.conv.CompactFull
import host.sim.template.FootGen
import host.sim.template.a4pre_first_tail_x6_r0_body.States
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
import host.sim.conv.CallPieces
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
import host.sim.template.CallGen
import host.sim.template.EndGen
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.BootEq
import host.sim.StageRel
import host.sim.compose.a4b.VWFramesDefs
import host.sim.template.FullOk
import host.sim.template.FastOk
import host.sim.Chunk

section -- SiteC0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 0 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s17` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa0` into the merged state
`PRE_first_tail_x6_r0_body.s16`. -/

def PRE_first_tail_x6_r0_body.pl0 : List Nat := [2676569, 2675150, 2676318, 2675881, 2675277, 2675287, 2675891, 2675202, 2676575, 2676571, 2675152, 2675276, 2675880, 2675204, 2676577, 2675275, 2675274, 2675879, 2675878, 2675877, 2675876, 2675236, 2675238]
def PRE_first_tail_x6_r0_body.nr0 : List Nat := [113, 112, 89, 88, 96, 101, 106, 111, 85, 86, 87, 94, 95, 83, 90, 91, 92, 93]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd0 : RData :=
  ⟨2674920, 2676612, Stage.setAll PTrie.nil [(2674897, 2676569), (2674898, 2675150), (2674899, 2676318), (2674900, 2675881), (2674901, 2675277), (2674902, 2675287), (2674903, 2675891), (2674904, 2675202), (2674905, 2676575), (2674906, 2676571), (2674907, 2675152), (2674908, 2675276), (2674909, 2675880), (2674910, 2675204), (2674911, 2676577), (2674912, 2675275), (2674913, 2675274), (2674914, 2675879), (2674915, 2675878), (2674916, 2675877), (2674917, 2675876), (2674918, 2675236), (2674919, 2675238)], Stage.setAll PTrie.nil [(18189, 18241), (18190, 18193), (18191, 18237), (18192, 18216), (18193, 18197), (18194, 18194), (18195, 18242), (18196, 18195)],
   18197, 18243, 15296, 15296, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(83, .ref 113), (84, .ref 112), (85, .ref 89), (86, .ref 88), (87, .ref 96), (88, .ref 101), (89, .ref 106), (90, .ref 111), (91, .ref 85), (92, .ref 86), (93, .ref 87), (94, .ref 94), (95, .ref 95), (96, .ref 83), (97, .ref 90), (98, .ref 91), (99, .ref 92), (100, .ref 93)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa0 : Map :=
  Conv.Map.compact 2674897 2676612 83 PRE_first_tail_x6_r0_body.pl0 (PRE_first_tail_x6_r0_body.nr0.map NumV.ref) PRE_first_tail_x6_r0_body.kd0.big
    PRE_first_tail_x6_r0_body.kd0.region PRE_first_tail_x6_r0_body.kd0.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws0 : List Nat := [1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044, 1045, 1046, 1047, 1048]
noncomputable def PRE_first_tail_x6_r0_body.crs0 : List SymE := PRE_first_tail_x6_r0_body.nr0.map fun r => (nth? PRE_first_tail_x6_r0_body.S16.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta0 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws0 PRE_first_tail_x6_r0_body.crs0
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB0 : List Nat := [483, 610, 613, 1050, 1051, 1054, 1281, 2665, 4941, 2672300, 2673467, 2674071, 2674616, 2674872]

kernel_rfl PRE_first_tail_x6_r0_body.ctab0 : PRE_first_tail_x6_r0_body.S17.tab = PRE_first_tail_x6_r0_body.S15.tab ++ PRE_first_tail_x6_r0_body.cws0.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace0 : PRE_first_tail_x6_r0_body.s17.trace = PRE_first_tail_x6_r0_body.s15.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext0 : PRE_first_tail_x6_r0_body.s17.next = 2674920
kernel_rfl PRE_first_tail_x6_r0_body.ccounters0 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx.nnext) = (18197, 15296)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue0 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s16.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa0.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp0 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx.tokens.all (bSN 101) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean0 : Conv.cleanListB 18197 131072 (fun r => Nat.ble 72788 r) PRE_first_tail_x6_r0_body.s17
    (PRE_first_tail_x6_r0_body.wrB0 ++ (List.range 23).map (2674897 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs0 : bigsOutB 18197 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl0`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl0 : List Nat := [483, 610, 613, 1050, 1051, 1054, 1281, 2665, 4941, 2672300, 2673467, 2674071, 2674616, 2674872, 2674897, 2674898, 2674899, 2674900, 2674901, 2674902, 2674903, 2674904, 2674905, 2674906, 2674907, 2674908, 2674909, 2674910, 2674911, 2674912, 2674913, 2674914, 2674915, 2674916, 2674917, 2674918, 2674919]
def PRE_first_tail_x6_r0_body.clo0 : List Nat := [18169, 18182, 18188, 18189, 18190, 18191, 18192, 18193, 18194, 18195, 18196]
def PRE_first_tail_x6_r0_body.cln0 : List Nat := [15254, 15255, 15256, 15257, 15258, 15259, 15260, 15261, 15262, 15263, 15264, 15265, 15266, 15267, 15268, 15269, 15270, 15271, 15272, 15273, 15274, 15275, 15276, 15277, 15278, 15279, 15280, 15281, 15282, 15283, 15284, 15285, 15286, 15287, 15288, 15289, 15290, 15291, 15292, 15293, 15294, 15295]
def PRE_first_tail_x6_r0_body.cli0 : List Nat := [15254, 15255, 15256, 15257, 15258, 15259, 15260, 15261, 15262, 15263, 15264, 15265, 15266, 15267, 15268, 15269, 15270, 15271, 15272, 15273, 15274, 15275, 15276, 15277, 15278, 15279, 15280, 15281, 15282, 15283, 15284, 15285, 15286, 15287, 15288, 15289, 15290, 15291, 15292, 15293, 15294, 15295]
kernel_rfl PRE_first_tail_x6_r0_body.cheap0 : PRE_first_tail_x6_r0_body.s17.heap = Stage.setAll PRE_first_tail_x6_r0_body.s15.heap (PRE_first_tail_x6_r0_body.cl0.filterMap fun a => (PRE_first_tail_x6_r0_body.s17.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe0 : Nat.ble PRE_first_tail_x6_r0_body.s15.next PRE_first_tail_x6_r0_body.s17.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP0 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s15 PRE_first_tail_x6_r0_body.s17 PRE_first_tail_x6_r0_body.cl0 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp0 : Conv.suppListB PRE_first_tail_x6_r0_body.s17 101 PRE_first_tail_x6_r0_body.cl0 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound0 : Conv.boundListB PRE_first_tail_x6_r0_body.s17 PRE_first_tail_x6_r0_body.cl0 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK0 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK0 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK0 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst0 : Conv.sstListB 101 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx PRE_first_tail_x6_r0_body.cln0 PRE_first_tail_x6_r0_body.clo0 PRE_first_tail_x6_r0_body.cli0 = true

end Host.Load.Run.Tpl
end

section -- SiteCl0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA0 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd0 : (PRE_first_tail_x6_r0_body.clo0 ++ PRE_first_tail_x6_r0_body.cln0 ++ PRE_first_tail_x6_r0_body.cli0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle0 : Conv.Cnt.leB (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck0 : Conv.ncleanListB (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx PRE_first_tail_x6_r0_body.clo0 PRE_first_tail_x6_r0_body.cln0 PRE_first_tail_x6_r0_body.cli0 = true
theorem PRE_first_tail_x6_r0_body.cncl0 (h : Conv.NClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx) : Conv.NClean (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle0 PRE_first_tail_x6_r0_body.ckA0 PRE_first_tail_x6_r0_body.cobjsK0 PRE_first_tail_x6_r0_body.cnodesK0 PRE_first_tail_x6_r0_body.citemsK0 PRE_first_tail_x6_r0_body.cbd0 PRE_first_tail_x6_r0_body.cck0

end Host.Load.Run.Tpl
end

section -- SiteS0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 0 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc0 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P0 : LoadP := PRE_first_tail_x6_r0_body.Pc0.raise 15296
kernel_rfl PRE_first_tail_x6_r0_body.craise0 : Nat.ble PRE_first_tail_x6_r0_body.Pc0.N0 15296 = true
theorem PRE_first_tail_x6_r0_body.raised0 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc0 PRE_first_tail_x6_r0_body.P0 :=
  .inr ⟨15296, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise0, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s16.ffi)
def PRE_first_tail_x6_r0_body.khinv0 : PTrie Nat := Stage.setAll PTrie.nil [(18241, 18189), (18193, 18190), (18237, 18191), (18216, 18192), (18197, 18193), (18194, 18194), (18242, 18195), (18195, 18196)]
def PRE_first_tail_x6_r0_body.kninv0 : PTrie Nat := Stage.setAll PTrie.nil [(15254, 15254), (15255, 15255), (15256, 15256), (15257, 15257), (15258, 15258), (15259, 15259), (15260, 15260), (15261, 15261), (15262, 15262), (15263, 15263), (15264, 15264), (15265, 15265), (15266, 15266), (15267, 15267), (15268, 15268), (15269, 15269), (15270, 15270), (15271, 15271), (15272, 15272), (15273, 15273), (15274, 15274), (15275, 15275), (15276, 15276), (15277, 15277), (15278, 15278), (15279, 15279), (15280, 15280), (15281, 15281), (15282, 15282), (15283, 15283), (15284, 15284), (15285, 15285), (15286, 15286), (15287, 15287), (15288, 15288), (15289, 15289), (15290, 15290), (15291, 15291), (15292, 15292), (15293, 15293), (15294, 15294), (15295, 15295)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS0 : List Nat := [18169, 18182, 18188, 18189, 18190, 18191, 18192, 18193, 18194, 18195, 18196, 18197, 18198, 18199, 18200, 18202, 18203, 18204, 18205, 18206, 18207, 18208, 18209, 18210, 18211, 18212, 18213, 18214, 18215, 18216, 18217, 18218, 18219, 18221, 18222, 18223, 18224, 18225, 18226, 18227, 18228, 18229, 18230, 18231, 18232, 18233, 18234, 18235, 18236, 18237, 18238, 18239, 18240, 18241, 18242]
def PRE_first_tail_x6_r0_body.cnS0 : List Nat := List.range' 15254 42
def PRE_first_tail_x6_r0_body.ciS0 : List Nat := [] ++ List.range' 15254 42

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh00 : PRE_first_tail_x6_r0_body.kd0.nh0 = PRE_first_tail_x6_r0_body.cx0_0.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh10 : PRE_first_tail_x6_r0_body.kd0.nh1 = PRE_first_tail_x6_r0_body.cx1_0.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn00 : PRE_first_tail_x6_r0_body.kd0.nn0 = PRE_first_tail_x6_r0_body.cx0_0.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn10 : PRE_first_tail_x6_r0_body.kd0.nn1 = PRE_first_tail_x6_r0_body.cx1_0.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo0 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P0.lo && Nat.ble PRE_first_tail_x6_r0_body.P0.lo PRE_first_tail_x6_r0_body.cx0_0.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P0.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P0.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt0 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_0.mlx.next PRE_first_tail_x6_r0_body.cx1_0.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_0.mlx.nnext PRE_first_tail_x6_r0_body.cx1_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband0 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P0.NL && Nat.ble PRE_first_tail_x6_r0_body.P0.NL PRE_first_tail_x6_r0_body.P0.N0 && Nat.ble PRE_first_tail_x6_r0_body.P0.N0 PRE_first_tail_x6_r0_body.cx0_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow0 : PRE_first_tail_x6_r0_body.kd0.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren0 : checkRenG PRE_first_tail_x6_r0_body.kd0.hnd PRE_first_tail_x6_r0_body.khinv0 (phB PRE_first_tail_x6_r0_body.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband0 : PRE_first_tail_x6_r0_body.kd0.checkBand PRE_first_tail_x6_r0_body.P0.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos0 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd0.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren0 : checkRenG PRE_first_tail_x6_r0_body.kd0.node PRE_first_tail_x6_r0_body.kninv0 (pnB PRE_first_tail_x6_r0_body.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow0 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd0.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P0.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd0.nodeF j) PRE_first_tail_x6_r0_body.cx1_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a0 : PRE_first_tail_x6_r0_body.cx0_0.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b0 : PRE_first_tail_x6_r0_body.cx0_0.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok10 : PRE_first_tail_x6_r0_body.cx1_0.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend0 : PRE_first_tail_x6_r0_body.cx1_0.mlx.pending = PRE_first_tail_x6_r0_body.cx0_0.mlx.pending.map PRE_first_tail_x6_r0_body.kappa0.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh0 : PRE_first_tail_x6_r0_body.cx1_0.mlx.errh = PRE_first_tail_x6_r0_body.cx0_0.mlx.errh.map PRE_first_tail_x6_r0_body.kappa0.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles0 : PRE_first_tail_x6_r0_body.cx1_0.mlx.files = PRE_first_tail_x6_r0_body.cx0_0.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch0 : PRE_first_tail_x6_r0_body.cx1_0.mlx.arch = PRE_first_tail_x6_r0_body.cx0_0.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes0 : PRE_first_tail_x6_r0_body.cx1_0.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_0.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired0 : PRE_first_tail_x6_r0_body.cx1_0.mlx.wired = PRE_first_tail_x6_r0_body.cx0_0.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost0 : PRE_first_tail_x6_r0_body.cx1_0.host = PRE_first_tail_x6_r0_body.cx0_0.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd0`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn00 : PRE_first_tail_x6_r0_body.kd0.n0 = 2674920
kernel_rfl PRE_first_tail_x6_r0_body.ckn10 : PRE_first_tail_x6_r0_body.kd0.n1 = 2676612
kernel_rfl PRE_first_tail_x6_r0_body.ckheap0 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd0.heap).all (fun x => Nat.ble 2674897 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl0 : (List.range 23).all (fun j => decide (PRE_first_tail_x6_r0_body.kd0.heap.get (2674897 + j) = nth? PRE_first_tail_x6_r0_body.pl0 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja0 : Nat.ble 2674897 2674897 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn0 : Nat.ble 83 83 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD0 : Nat.ble 2674897 PRE_first_tail_x6_r0_body.kd0.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn0 : Nat.ble 18189 PRE_first_tail_x6_r0_body.kd0.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn0 : Nat.ble 15254 PRE_first_tail_x6_r0_body.kd0.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb0 : Nat.ble 18189 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap0 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd0.heap).all (Nat.ble (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd0 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd0.hnd).all (Nat.ble (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode0 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd0.node).all (Nat.ble (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix0 : Conv.FixOld (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa0 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja0) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn0) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD0) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn0) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn0) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb0) PRE_first_tail_x6_r0_body.fheap0 PRE_first_tail_x6_r0_body.fhnd0 PRE_first_tail_x6_r0_body.fnode0
kernel_rfl PRE_first_tail_x6_r0_body.fcxn0 : (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn0 : (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle00 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_0.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_0.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk0 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd0.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A0 : PRE_first_tail_x6_r0_body.cx1_0.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS0.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_0.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O0 : PRE_first_tail_x6_r0_body.cx1_0.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS0.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_0.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N0 : PRE_first_tail_x6_r0_body.cx1_0.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS0.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_0.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I0 : PRE_first_tail_x6_r0_body.cx1_0.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS0.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_0.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd0 : (PRE_first_tail_x6_r0_body.clo0 ++ PRE_first_tail_x6_r0_body.cln0 ++ PRE_first_tail_x6_r0_body.cli0 ++ PRE_first_tail_x6_r0_body.cwS0 ++ PRE_first_tail_x6_r0_body.cnS0 ++ PRE_first_tail_x6_r0_body.ciS0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW0 : PRE_first_tail_x6_r0_body.cwS0.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo0.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI0 : PRE_first_tail_x6_r0_body.ciS0.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli0.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN0 : PRE_first_tail_x6_r0_body.cnS0.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF0 : PRE_first_tail_x6_r0_body.cln0.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh0 : PRE_first_tail_x6_r0_body.clo0.all (handleOK PRE_first_tail_x6_r0_body.kappa0 PRE_first_tail_x6_r0_body.P0.lo PRE_first_tail_x6_r0_body.cx0_0.mlx PRE_first_tail_x6_r0_body.cx1_0.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo0 : PRE_first_tail_x6_r0_body.clo0.map (fun h => PRE_first_tail_x6_r0_body.cx1_0.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa0.handle h)) = PRE_first_tail_x6_r0_body.clo0.map (fun h => (PRE_first_tail_x6_r0_body.cx0_0.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa0.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok0 : PRE_first_tail_x6_r0_body.clo0.all (objOK PRE_first_tail_x6_r0_body.kappa0 PRE_first_tail_x6_r0_body.P0.NL PRE_first_tail_x6_r0_body.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd0 : PRE_first_tail_x6_r0_body.cln0.all (nodeOKF PRE_first_tail_x6_r0_body.kappa0 PRE_first_tail_x6_r0_body.P0 PRE_first_tail_x6_r0_body.cx0_0.mlx PRE_first_tail_x6_r0_body.cx1_0.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp0 : ((PRE_first_tail_x6_r0_body.cln0.filter (fullB PRE_first_tail_x6_r0_body.P0))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_0.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa0.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln0.filter (fullB PRE_first_tail_x6_r0_body.P0))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_0.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa0.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI0 : incrB PRE_first_tail_x6_r0_body.kd0.nodeF (List.range' 15254 42) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK0 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd0.node).all (fun k => Nat.ble 15254 k && Nat.blt k 15296) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL0 : (PRE_first_tail_x6_r0_body.cln0.filter (Nat.ble PRE_first_tail_x6_r0_body.P0.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd0.nodeF i) && (Nat.blt i 15296 || Nat.ble PRE_first_tail_x6_r0_body.kd0.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord0 : (PRE_first_tail_x6_r0_body.cln0.filter (Nat.ble PRE_first_tail_x6_r0_body.P0.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd0.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd0.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd0.nodeF j) (PRE_first_tail_x6_r0_body.kd0.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow0 PRE_first_tail_x6_r0_body.cnn10 PRE_first_tail_x6_r0_body.fnordI0 PRE_first_tail_x6_r0_body.fnordK0 PRE_first_tail_x6_r0_body.fnordL0
kernel_rfl PRE_first_tail_x6_r0_body.fi0 : PRE_first_tail_x6_r0_body.cli0.all (pnB PRE_first_tail_x6_r0_body.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii0 : PRE_first_tail_x6_r0_body.cli0.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_0.mlx.items.get (PRE_first_tail_x6_r0_body.kappa0.node k) = (PRE_first_tail_x6_r0_body.cx0_0.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa0.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot0 (clean : Conv.NClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P0.NL) (cl : SSt (· < 101) PRE_first_tail_x6_r0_body.cx0_0.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P0 101 PRE_first_tail_x6_r0_body.kappa0 PRE_first_tail_x6_r0_body.kd0 PRE_first_tail_x6_r0_body.khinv0 PRE_first_tail_x6_r0_body.kninv0 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx PRE_first_tail_x6_r0_body.cx0_0.mlx PRE_first_tail_x6_r0_body.cx1_0.mlx (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo0 PRE_first_tail_x6_r0_body.cln0 PRE_first_tail_x6_r0_body.cli0 PRE_first_tail_x6_r0_body.cwS0 PRE_first_tail_x6_r0_body.cnS0 PRE_first_tail_x6_r0_body.ciS0 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh00, PRE_first_tail_x6_r0_body.cnh10, PRE_first_tail_x6_r0_body.cnn00, PRE_first_tail_x6_r0_body.cnn10, PRE_first_tail_x6_r0_body.cplo0, PRE_first_tail_x6_r0_body.ccnt0, PRE_first_tail_x6_r0_body.cnband0, PRE_first_tail_x6_r0_body.chbelow0, PRE_first_tail_x6_r0_body.chren0, PRE_first_tail_x6_r0_body.cband0, PRE_first_tail_x6_r0_body.cnh1pos0, PRE_first_tail_x6_r0_body.cnren0, PRE_first_tail_x6_r0_body.cnlow0, PRE_first_tail_x6_r0_body.cabs0a0, PRE_first_tail_x6_r0_body.cabs0b0, PRE_first_tail_x6_r0_body.ctok10, PRE_first_tail_x6_r0_body.cpend0, PRE_first_tail_x6_r0_body.cerrh0, PRE_first_tail_x6_r0_body.cfiles0, PRE_first_tail_x6_r0_body.carch0, PRE_first_tail_x6_r0_body.csizes0, PRE_first_tail_x6_r0_body.cwired0, PRE_first_tail_x6_r0_body.cfix0, clean, PRE_first_tail_x6_r0_body.fcxn0, PRE_first_tail_x6_r0_body.fcnn0, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle00, PRE_first_tail_x6_r0_body.fnk0, PRE_first_tail_x6_r0_body.ckA0, PRE_first_tail_x6_r0_body.cobjsK0, PRE_first_tail_x6_r0_body.cnodesK0, PRE_first_tail_x6_r0_body.citemsK0, PRE_first_tail_x6_r0_body.f1A0, PRE_first_tail_x6_r0_body.f1O0, PRE_first_tail_x6_r0_body.f1N0, PRE_first_tail_x6_r0_body.f1I0, PRE_first_tail_x6_r0_body.fbd0, PRE_first_tail_x6_r0_body.fincW0, PRE_first_tail_x6_r0_body.fincI0, PRE_first_tail_x6_r0_body.fincN0, PRE_first_tail_x6_r0_body.flnF0, PRE_first_tail_x6_r0_body.fh0, PRE_first_tail_x6_r0_body.fo0, PRE_first_tail_x6_r0_body.fok0, PRE_first_tail_x6_r0_body.fnd0, PRE_first_tail_x6_r0_body.fp0, PRE_first_tail_x6_r0_body.fnord0, PRE_first_tail_x6_r0_body.fi0, PRE_first_tail_x6_r0_body.fii0⟩
theorem PRE_first_tail_x6_r0_body.cnshift0 (clean : Conv.NClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P0.NL) (cl : SSt (· < 101) PRE_first_tail_x6_r0_body.cx0_0.mlx) : NShift PRE_first_tail_x6_r0_body.P0 101 PRE_first_tail_x6_r0_body.kappa0 PRE_first_tail_x6_r0_body.cx0_0 PRE_first_tail_x6_r0_body.cx1_0 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot0 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost0 (compact_a_eq PRE_first_tail_x6_r0_body.ckn00 PRE_first_tail_x6_r0_body.ckn10 PRE_first_tail_x6_r0_body.ckheap0 PRE_first_tail_x6_r0_body.ckpl0)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s15.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s15.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s15.ffi) = some PRE_first_tail_x6_r0_body.fxC_0
kernel_rfl PRE_first_tail_x6_r0_body.okrC_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s15.ffi) = some PRE_first_tail_x6_r0_body.krC_0
noncomputable def PRE_first_tail_x6_r0_body.fx0_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s17.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s17.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s17.ffi) = some PRE_first_tail_x6_r0_body.fx0_0
kernel_rfl PRE_first_tail_x6_r0_body.okr0_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s17.ffi) = some PRE_first_tail_x6_r0_body.kr0_0
noncomputable def PRE_first_tail_x6_r0_body.fx1_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s16.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s16.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s16.ffi) = some PRE_first_tail_x6_r0_body.fx1_0
kernel_rfl PRE_first_tail_x6_r0_body.okr1_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s16.ffi) = some PRE_first_tail_x6_r0_body.kr1_0
kernel_rfl PRE_first_tail_x6_r0_body.ff00 : PRE_first_tail_x6_r0_body.fx0_0 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_0 (PRE_first_tail_x6_r0_body.clo0.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_0.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff10 : PRE_first_tail_x6_r0_body.fx1_0 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_0 (PRE_first_tail_x6_r0_body.cwS0.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_0.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck0 : freedLB PRE_first_tail_x6_r0_body.kappa0 PRE_first_tail_x6_r0_body.cx0_0.mlx PRE_first_tail_x6_r0_body.fx0_0 PRE_first_tail_x6_r0_body.fx1_0 PRE_first_tail_x6_r0_body.clo0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf00 : PRE_first_tail_x6_r0_body.kr0_0.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_0.flags (PRE_first_tail_x6_r0_body.clo0.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_0.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt00 : PRE_first_tail_x6_r0_body.kr0_0.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_0.targs (PRE_first_tail_x6_r0_body.clo0.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_0.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf10 : PRE_first_tail_x6_r0_body.kr1_0.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_0.flags (PRE_first_tail_x6_r0_body.cwS0.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_0.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt10 : PRE_first_tail_x6_r0_body.kr1_0.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_0.targs (PRE_first_tail_x6_r0_body.cwS0.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_0.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck0 : krecLB PRE_first_tail_x6_r0_body.kappa0 101 PRE_first_tail_x6_r0_body.cx0_0.mlx PRE_first_tail_x6_r0_body.kr0_0 PRE_first_tail_x6_r0_body.kr1_0 PRE_first_tail_x6_r0_body.clo0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn0 : Nat.ble 83 101 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge0 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s16.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s17.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR0 : pendRegB PRE_first_tail_x6_r0_body.kappa0 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe0 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s17.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s16.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift0 (clean : Conv.NClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P0.NL) (cl : SSt (· < 101) PRE_first_tail_x6_r0_body.cx0_0.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_0.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_0.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_0.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s15.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_0.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P0 101 PRE_first_tail_x6_r0_body.kappa0 PRE_first_tail_x6_r0_body.s17.ffi PRE_first_tail_x6_r0_body.s16.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift0 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue0, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp0 t ht),
    PRE_first_tail_x6_r0_body.cbridge0,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s17.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s16.ffi) (PRE_first_tail_x6_r0_body.cfoot0 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_0 PRE_first_tail_x6_r0_body.ofx1_0 hobjC PRE_first_tail_x6_r0_body.ff00 PRE_first_tail_x6_r0_body.ff10 PRE_first_tail_x6_r0_body.ffck0,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s17.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s16.ffi) (PRE_first_tail_x6_r0_body.cfoot0 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_0 PRE_first_tail_x6_r0_body.okr1_0 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn0) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf00 PRE_first_tail_x6_r0_body.fkt00 PRE_first_tail_x6_r0_body.fkf10 PRE_first_tail_x6_r0_body.fkt10 PRE_first_tail_x6_r0_body.fkck0,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh00 PRE_first_tail_x6_r0_body.cnh10 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe0) PRE_first_tail_x6_r0_body.cpendR0⟩

end Host.Load.Run.Tpl
end

section -- st0/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st0 0
host_stream_state PRE_first_tail_x6_r0_body.st0 1
host_stream_state PRE_first_tail_x6_r0_body.st0 2
host_stream_state PRE_first_tail_x6_r0_body.st0 3
host_stream_state PRE_first_tail_x6_r0_body.st0 4
host_stream_state PRE_first_tail_x6_r0_body.st0 5
host_stream_state PRE_first_tail_x6_r0_body.st0 6
host_stream_state PRE_first_tail_x6_r0_body.st0 7
end Host.Load.Run.Tpl
end

section -- Site0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g0__g1` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s15`, the merged state `PRE_first_tail_x6_r0_body.s16`,
the site template `PRE_first_tail_x6_r0_body.st0` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s17`: the merge.
The footprint's facts are in `SiteF0`, the compaction's in `SiteC0`, `SiteK0`, `SiteNa0`, `SiteNb0`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso0 : PRE_first_tail_x6_r0_body.st0.s0 = { PRE_first_tail_x6_r0_body.s15 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs0 : List Frame := PRE_first_tail_x6_r0_body.s15.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_0 : PRE_first_tail_x6_r0_body.S15.tab.length = 83
kernel_rfl PRE_first_tail_x6_r0_body.tab0_0 : PRE_first_tail_x6_r0_body.st0.S0.tab = PRE_first_tail_x6_r0_body.S15.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws0 : List Nat := [1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1025, 1026, 1027, 1028, 1029, 1030]
kernel_rfl PRE_first_tail_x6_r0_body.fresh0 : (PRE_first_tail_x6_r0_body.S15.tab.all fun e => PRE_first_tail_x6_r0_body.ws0.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S15.oracle.all fun q => PRE_first_tail_x6_r0_body.ws0.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab0 : PRE_first_tail_x6_r0_body.S16.tab = PRE_first_tail_x6_r0_body.S15.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws0
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen0 : PRE_first_tail_x6_r0_body.st0.S7.tab.length - PRE_first_tail_x6_r0_body.st0.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged0`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap0 : PRE_first_tail_x6_r0_body.s16.heap = PRE_first_tail_x6_r0_body.st0.s7.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext0 : PRE_first_tail_x6_r0_body.s16.next = PRE_first_tail_x6_r0_body.st0.s7.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl0 : PRE_first_tail_x6_r0_body.s16.ctl = PRE_first_tail_x6_r0_body.st0.s7.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack0 : PRE_first_tail_x6_r0_body.s16.stack = PRE_first_tail_x6_r0_body.st0.s7.stack ++ PRE_first_tail_x6_r0_body.s15.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs0 : PRE_first_tail_x6_r0_body.s16.jobs = PRE_first_tail_x6_r0_body.st0.s7.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi0 : PRE_first_tail_x6_r0_body.s16.ffi = PRE_first_tail_x6_r0_body.st0.s7.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace0 : PRE_first_tail_x6_r0_body.s16.trace = PRE_first_tail_x6_r0_body.st0.s7.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores0 : PRE_first_tail_x6_r0_body.s16.stores = PRE_first_tail_x6_r0_body.st0.s7.stores

end Host.Load.Run.Tpl
end

section -- SiteD0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 0 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived0 : PRE_first_tail_x6_r0_body.nr0.map (fun r => nth? PRE_first_tail_x6_r0_body.st0.S7.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo0 : PRE_first_tail_x6_r0_body.nr0.all (Nat.ble 83) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj0 : PRE_first_tail_x6_r0_body.cws0.all (fun c => !PRE_first_tail_x6_r0_body.ws0.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ0 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws0 PRE_first_tail_x6_r0_body.crs0 PRE_first_tail_x6_r0_body.ws0

end Host.Load.Run.Tpl
end

section -- st0/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st0`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st0.wrR : List (Nat × Nat) := [(483, 484), (610, 611), (613, 614), (1050, 1052), (1054, 1055), (1281, 1282), (4941, 4942), (2672300, 2672301), (2674071, 2674072), (2674616, 2674617), (2674872, 2674873)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st0.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st0.s7.heap PRE_first_tail_x6_r0_body.st0.wrR ++ freshOf PRE_first_tail_x6_r0_body.st0.s7.heap PRE_first_tail_x6_r0_body.st0.s0.next PRE_first_tail_x6_r0_body.st0.s7.next
noncomputable def PRE_first_tail_x6_r0_body.st0.wr : List Nat := PRE_first_tail_x6_r0_body.st0.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st0.heapFoot : PRE_first_tail_x6_r0_body.st0.s7.heap = setAll PRE_first_tail_x6_r0_body.st0.s0.heap PRE_first_tail_x6_r0_body.st0.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st0.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st0.s0.next PRE_first_tail_x6_r0_body.st0.s7.next = true
theorem PRE_first_tail_x6_r0_body.st0.grows : PRE_first_tail_x6_r0_body.st0.s0.next ≤ PRE_first_tail_x6_r0_body.st0.s7.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st0.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st0.wh : List Nat := [18169, 18182, 18188, 18189, 18190, 18191, 18192, 18193, 18194, 18195, 18196, 18197, 18198, 18199, 18200, 18202, 18203, 18204, 18205, 18206, 18207, 18208, 18209, 18210, 18211, 18212, 18213, 18214, 18215, 18216, 18217, 18218, 18219, 18221, 18222, 18223, 18224, 18225, 18226, 18227, 18228, 18229, 18230, 18231, 18232, 18233, 18234, 18235, 18236, 18237, 18238, 18239, 18240, 18241, 18242]
def PRE_first_tail_x6_r0_body.st0.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st0.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s7.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st0.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s7.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st0.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s7.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st0.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s7.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st0.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s7.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s7.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s7.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st0.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s7.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st0.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s7.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s7.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s7.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st0.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s7.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st0.s7.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB0 : nodupT PRE_first_tail_x6_r0_body.st0.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup0 : PRE_first_tail_x6_r0_body.st0.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB0).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB0 : PRE_first_tail_x6_r0_body.st0.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound0 : ∀ b ∈ PRE_first_tail_x6_r0_body.st0.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB0 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr0 := PRE_first_tail_x6_r0_body.st0.s7.trace.take 183
kernel_rfl PRE_first_tail_x6_r0_body.traceEq0 : PRE_first_tail_x6_r0_body.st0.s7.trace = PRE_first_tail_x6_r0_body.trFr0 ++ PRE_first_tail_x6_r0_body.st0.s0.trace
theorem PRE_first_tail_x6_r0_body.trace0 : ∃ fr, PRE_first_tail_x6_r0_body.st0.s7.trace = fr ++ PRE_first_tail_x6_r0_body.st0.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq0⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide0 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB0 : (PRE_first_tail_x6_r0_body.wide0.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st0.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix0 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide0, WFix Map.id (Present PRE_first_tail_x6_r0_body.st0.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB0 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 0 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s16`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO0 : PRE_first_tail_x6_r0_body.st0.S0.oracle = PRE_first_tail_x6_r0_body.st0.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B0 : PRE_first_tail_x6_r0_body.st0.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st0.s0.next || (PRE_first_tail_x6_r0_body.st0.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot0 : Conv.StageFoot PRE_first_tail_x6_r0_body.st0.wr PRE_first_tail_x6_r0_body.st0.s0 PRE_first_tail_x6_r0_body.st0.s7 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st0.heapFoot PRE_first_tail_x6_r0_body.wrNodup0 PRE_first_tail_x6_r0_body.wrBound0 PRE_first_tail_x6_r0_body.wr0B0 PRE_first_tail_x6_r0_body.st0.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged0 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st0.F.S → PRE_first_tail_x6_r0_body.st0.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st0.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st0.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs0 PRE_first_tail_x6_r0_body.st0.wr PRE_first_tail_x6_r0_body.s15 PRE_first_tail_x6_r0_body.st0.s7 PRE_first_tail_x6_r0_body.st0.s0
      PRE_first_tail_x6_r0_body.st0.s7.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st0.F FR W stk M ν K PRE_first_tail_x6_r0_body.s16 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso0 PRE_first_tail_x6_r0_body.stFoot0 PRE_first_tail_x6_r0_body.wrNodup0 PRE_first_tail_x6_r0_body.wrBound0 PRE_first_tail_x6_r0_body.trace0 PRE_first_tail_x6_r0_body.mheap0
    PRE_first_tail_x6_r0_body.mnext0 PRE_first_tail_x6_r0_body.mctl0 PRE_first_tail_x6_r0_body.mstack0 PRE_first_tail_x6_r0_body.mjobs0 PRE_first_tail_x6_r0_body.mffi0 PRE_first_tail_x6_r0_body.mtrace0 PRE_first_tail_x6_r0_body.mstores0 h

def PRE_first_tail_x6_r0_body.arrEl0_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE0_2665 : arrOf PRE_first_tail_x6_r0_body.s16 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl0_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA0_2665 : isArrB PRE_first_tail_x6_r0_body.s16 2665 = true
theorem PRE_first_tail_x6_r0_body.arr0_2665 : ∃ o, PRE_first_tail_x6_r0_body.s16.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl0_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE0_2665 PRE_first_tail_x6_r0_body.arrA0_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN0_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl0_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR0_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl0_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN0_2665

def PRE_first_tail_x6_r0_body.arrEl0_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE0_2673467 : arrOf PRE_first_tail_x6_r0_body.s16 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl0_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA0_2673467 : isArrB PRE_first_tail_x6_r0_body.s16 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr0_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s16.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl0_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE0_2673467 PRE_first_tail_x6_r0_body.arrA0_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN0_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl0_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR0_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl0_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN0_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k0 : isArrB PRE_first_tail_x6_r0_body.s16 4910 = false
theorem PRE_first_tail_x6_r0_body.keep0 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s16 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k0 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr0_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl0_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 0 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s15`, the merged
state `PRE_first_tail_x6_r0_body.s16`, the canonical state `PRE_first_tail_x6_r0_body.s17`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl0 : PRE_first_tail_x6_r0_body.pl0.all (Nat.ble PRE_first_tail_x6_r0_body.s15.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd0 : nodupT PRE_first_tail_x6_r0_body.pl0 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn10 : Nat.ble PRE_first_tail_x6_r0_body.s15.next 2676612 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst0 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s15.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn0 : PRE_first_tail_x6_r0_body.s17.next = PRE_first_tail_x6_r0_body.s15.next + PRE_first_tail_x6_r0_body.pl0.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn0 : PRE_first_tail_x6_r0_body.s16.next = 2676612
kernel_rfl PRE_first_tail_x6_r0_body.zgrow0 : Nat.ble PRE_first_tail_x6_r0_body.s17.next PRE_first_tail_x6_r0_body.s16.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh0 : PRE_first_tail_x6_r0_body.S15.tab.all (fun e => PRE_first_tail_x6_r0_body.cws0.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd0 : nodupT PRE_first_tail_x6_r0_body.cws0 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi0 : PRE_first_tail_x6_r0_body.nr0.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S16.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt0 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s15.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg0_2665 : PRE_first_tail_x6_r0_body.s17.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s17 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk0_2665 : (objOf PRE_first_tail_x6_r0_body.s17 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm0_2665 : PRE_first_tail_x6_r0_body.s16.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa0.obj (objOf PRE_first_tail_x6_r0_body.s17 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s16 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg0_2673467 : PRE_first_tail_x6_r0_body.s17.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s17 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk0_2673467 : (objOf PRE_first_tail_x6_r0_body.s17 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm0_2673467 : PRE_first_tail_x6_r0_body.s16.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa0.obj (objOf PRE_first_tail_x6_r0_body.s17 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s16 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw0_4910 : (PRE_first_tail_x6_r0_body.s17.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw0_2673472 : (PRE_first_tail_x6_r0_body.s17.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw0_2673473 : (PRE_first_tail_x6_r0_body.s17.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd0 : PRE_first_tail_x6_r0_body.cl0.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr0 : PRE_first_tail_x6_r0_body.st0.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s15.next || PRE_first_tail_x6_r0_body.cl0.contains b) = true
def PRE_first_tail_x6_r0_body.zl0 : List Nat := PRE_first_tail_x6_r0_body.cl0.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE0 : PRE_first_tail_x6_r0_body.zl0.map (fun a => PRE_first_tail_x6_r0_body.s16.heap.get (PRE_first_tail_x6_r0_body.kappa0.a a)) = PRE_first_tail_x6_r0_body.zl0.map (fun a => (PRE_first_tail_x6_r0_body.s17.heap.get a).map PRE_first_tail_x6_r0_body.kappa0.hobj)
theorem PRE_first_tail_x6_r0_body.zimg0 : HeapImg PRE_first_tail_x6_r0_body.kappa0 PRE_first_tail_x6_r0_body.s17 PRE_first_tail_x6_r0_body.s16 PRE_first_tail_x6_r0_body.zl0 := PRE_first_tail_x6_r0_body.zimgE0
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl0 : PRE_first_tail_x6_r0_body.s16.ctl = PRE_first_tail_x6_r0_body.kappa0.ctl PRE_first_tail_x6_r0_body.s17.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack0 : PRE_first_tail_x6_r0_body.s16.stack = PRE_first_tail_x6_r0_body.s17.stack.map PRE_first_tail_x6_r0_body.kappa0.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs0 : PRE_first_tail_x6_r0_body.s16.jobs = PRE_first_tail_x6_r0_body.s17.jobs.map PRE_first_tail_x6_r0_body.kappa0.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores0 : PRE_first_tail_x6_r0_body.s16.stores = PRE_first_tail_x6_r0_body.kappa0.stores PRE_first_tail_x6_r0_body.s17.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots0 : checkRootsSupp PRE_first_tail_x6_r0_body.s17 101 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC0 : PRE_first_tail_x6_r0_body.S15.tab.length + PRE_first_tail_x6_r0_body.cws0.length = 101
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap0 : PRE_first_tail_x6_r0_body.kappa0 = Conv.Map.compact PRE_first_tail_x6_r0_body.s15.next 2676612 PRE_first_tail_x6_r0_body.S15.tab.length PRE_first_tail_x6_r0_body.pl0 (PRE_first_tail_x6_r0_body.nr0.map NumV.ref) PRE_first_tail_x6_r0_body.kd0.big
  PRE_first_tail_x6_r0_body.kd0.region PRE_first_tail_x6_r0_body.kd0.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin0 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s17.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc0 : Conv.jcleanListB (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s17 PRE_first_tail_x6_r0_body.cl0 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB0 : noBigRootsP (fun i => !Conv.oldBigB (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s17.trace PRE_first_tail_x6_r0_body.s17 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm0 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15254 = true
theorem PRE_first_tail_x6_r0_body.cjcl0 (h : Conv.JClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s15) : Conv.JClean (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s17 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle0)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap0 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd0 a ha)) PRE_first_tail_x6_r0_body.zjc0

end Host.Load.Run.Tpl
end

section -- st0/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st0.bodyLast from PRE_first_tail_x6_r0_body.st0.s6 to PRE_first_tail_x6_r0_body.st0.s7 :
  interpS (step PRE_first_tail_x6_r0_body.st0.F PRE_first_tail_x6_r0_body.st0.s6).run PRE_first_tail_x6_r0_body.st0.S6 = some (PRE_first_tail_x6_r0_body.st0.s7, PRE_first_tail_x6_r0_body.st0.S7)
kernel_rfl PRE_first_tail_x6_r0_body.st0.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st0.s6.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st0.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st0.s7.stack = true

end Host.Load.Run.Tpl
end

section -- st0/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st0.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st0.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st0.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st0.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st0.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st0.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st0.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st0.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st0.s0 PRE_first_tail_x6_r0_body.st0.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st0.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st0.s6 PRE_first_tail_x6_r0_body.st0.S6) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st0/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st0.bodyK0F from PRE_first_tail_x6_r0_body.st0.s0 to PRE_first_tail_x6_r0_body.st0.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st0.ks 0).getD 0) PRE_first_tail_x6_r0_body.st0.s0 PRE_first_tail_x6_r0_body.st0.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st0.s1, PRE_first_tail_x6_r0_body.st0.S1)
theorem PRE_first_tail_x6_r0_body.st0.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st0.ks 0).getD 0) PRE_first_tail_x6_r0_body.st0.s0 PRE_first_tail_x6_r0_body.st0.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st0.s1, PRE_first_tail_x6_r0_body.st0.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st0.bodyOkLN_ok PRE_first_tail_x6_r0_body.st0.bodyK0F
end Host.Load.Run.Tpl
end

section -- st0/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st0.bodyK1F from PRE_first_tail_x6_r0_body.st0.s1 to PRE_first_tail_x6_r0_body.st0.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st0.ks 1).getD 0) PRE_first_tail_x6_r0_body.st0.s1 PRE_first_tail_x6_r0_body.st0.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st0.s2, PRE_first_tail_x6_r0_body.st0.S2)
theorem PRE_first_tail_x6_r0_body.st0.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st0.ks 1).getD 0) PRE_first_tail_x6_r0_body.st0.s1 PRE_first_tail_x6_r0_body.st0.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st0.s2, PRE_first_tail_x6_r0_body.st0.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st0.bodyOkLN_ok PRE_first_tail_x6_r0_body.st0.bodyK1F
end Host.Load.Run.Tpl
end

section -- st0/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st0.bodyK2F from PRE_first_tail_x6_r0_body.st0.s2 to PRE_first_tail_x6_r0_body.st0.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st0.ks 2).getD 0) PRE_first_tail_x6_r0_body.st0.s2 PRE_first_tail_x6_r0_body.st0.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st0.s3, PRE_first_tail_x6_r0_body.st0.S3)
theorem PRE_first_tail_x6_r0_body.st0.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st0.ks 2).getD 0) PRE_first_tail_x6_r0_body.st0.s2 PRE_first_tail_x6_r0_body.st0.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st0.s3, PRE_first_tail_x6_r0_body.st0.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st0.bodyOkLN_ok PRE_first_tail_x6_r0_body.st0.bodyK2F
end Host.Load.Run.Tpl
end

section -- st0/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st0.bodyK3F from PRE_first_tail_x6_r0_body.st0.s3 to PRE_first_tail_x6_r0_body.st0.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st0.ks 3).getD 0) PRE_first_tail_x6_r0_body.st0.s3 PRE_first_tail_x6_r0_body.st0.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st0.s4, PRE_first_tail_x6_r0_body.st0.S4)
theorem PRE_first_tail_x6_r0_body.st0.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st0.ks 3).getD 0) PRE_first_tail_x6_r0_body.st0.s3 PRE_first_tail_x6_r0_body.st0.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st0.s4, PRE_first_tail_x6_r0_body.st0.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st0.bodyOkLN_ok PRE_first_tail_x6_r0_body.st0.bodyK3F
end Host.Load.Run.Tpl
end

section -- st0/TypedK4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st0.bodyK4F from PRE_first_tail_x6_r0_body.st0.s4 to PRE_first_tail_x6_r0_body.st0.s5 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st0.ks 4).getD 0) PRE_first_tail_x6_r0_body.st0.s4 PRE_first_tail_x6_r0_body.st0.S4) = fun _ _ => some (PRE_first_tail_x6_r0_body.st0.s5, PRE_first_tail_x6_r0_body.st0.S5)
theorem PRE_first_tail_x6_r0_body.st0.bodyK4 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st0.ks 4).getD 0) PRE_first_tail_x6_r0_body.st0.s4 PRE_first_tail_x6_r0_body.st0.S4) = fun _ _ => some (PRE_first_tail_x6_r0_body.st0.s5, PRE_first_tail_x6_r0_body.st0.S5) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st0.bodyOkLN_ok PRE_first_tail_x6_r0_body.st0.bodyK4F
end Host.Load.Run.Tpl
end

section -- st0/TypedK5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st0.bodyK5F from PRE_first_tail_x6_r0_body.st0.s5 to PRE_first_tail_x6_r0_body.st0.s6 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st0.ks 5).getD 0) PRE_first_tail_x6_r0_body.st0.s5 PRE_first_tail_x6_r0_body.st0.S5) = fun _ _ => some (PRE_first_tail_x6_r0_body.st0.s6, PRE_first_tail_x6_r0_body.st0.S6)
theorem PRE_first_tail_x6_r0_body.st0.bodyK5 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st0.ks 5).getD 0) PRE_first_tail_x6_r0_body.st0.s5 PRE_first_tail_x6_r0_body.st0.S5) = fun _ _ => some (PRE_first_tail_x6_r0_body.st0.s6, PRE_first_tail_x6_r0_body.st0.S6) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st0.bodyOkLN_ok PRE_first_tail_x6_r0_body.st0.bodyK5F
end Host.Load.Run.Tpl
end

section -- st0/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st0.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows) 17040 PRE_first_tail_x6_r0_body.st0.s0 PRE_first_tail_x6_r0_body.st0.S0 = some (PRE_first_tail_x6_r0_body.st0.s6, PRE_first_tail_x6_r0_body.st0.S6) :=
  runOk_trans PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows) ((((((nth? PRE_first_tail_x6_r0_body.st0.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st0.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st0.ks 2).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st0.ks 3).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st0.ks 4).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st0.ks 5).getD 0) PRE_first_tail_x6_r0_body.st0.s0 PRE_first_tail_x6_r0_body.st0.s5 PRE_first_tail_x6_r0_body.st0.s6 PRE_first_tail_x6_r0_body.st0.S0 PRE_first_tail_x6_r0_body.st0.S5 PRE_first_tail_x6_r0_body.st0.S6 (runOk_trans PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows) (((((nth? PRE_first_tail_x6_r0_body.st0.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st0.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st0.ks 2).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st0.ks 3).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st0.ks 4).getD 0) PRE_first_tail_x6_r0_body.st0.s0 PRE_first_tail_x6_r0_body.st0.s4 PRE_first_tail_x6_r0_body.st0.s5 PRE_first_tail_x6_r0_body.st0.S0 PRE_first_tail_x6_r0_body.st0.S4 PRE_first_tail_x6_r0_body.st0.S5 (runOk_trans PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st0.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st0.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st0.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st0.ks 3).getD 0) PRE_first_tail_x6_r0_body.st0.s0 PRE_first_tail_x6_r0_body.st0.s3 PRE_first_tail_x6_r0_body.st0.s4 PRE_first_tail_x6_r0_body.st0.S0 PRE_first_tail_x6_r0_body.st0.S3 PRE_first_tail_x6_r0_body.st0.S4 (runOk_trans PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st0.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st0.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st0.ks 2).getD 0) PRE_first_tail_x6_r0_body.st0.s0 PRE_first_tail_x6_r0_body.st0.s2 PRE_first_tail_x6_r0_body.st0.s3 PRE_first_tail_x6_r0_body.st0.S0 PRE_first_tail_x6_r0_body.st0.S2 PRE_first_tail_x6_r0_body.st0.S3 (runOk_trans PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st0.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st0.ks 1).getD 0) PRE_first_tail_x6_r0_body.st0.s0 PRE_first_tail_x6_r0_body.st0.s1 PRE_first_tail_x6_r0_body.st0.s2 PRE_first_tail_x6_r0_body.st0.S0 PRE_first_tail_x6_r0_body.st0.S1 PRE_first_tail_x6_r0_body.st0.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st0.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st0.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st0.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st0.bodyK3 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st0.bodyK4 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st0.bodyK5 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st0.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st0.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st0.F (PRE_first_tail_x6_r0_body.st0.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st0.s0
  S0 := PRE_first_tail_x6_r0_body.st0.S0
  s1 := PRE_first_tail_x6_r0_body.st0.s6
  S1 := PRE_first_tail_x6_r0_body.st0.S6
  s2 := PRE_first_tail_x6_r0_body.st0.s7
  S2 := PRE_first_tail_x6_r0_body.st0.S7
  n := 17040
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st0.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st0.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st0.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st0.bodyHalt
  last := PRE_first_tail_x6_r0_body.st0.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st0.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 1 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s26` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa1` into the merged state
`PRE_first_tail_x6_r0_body.s25`. -/

def PRE_first_tail_x6_r0_body.pl1 : List Nat := []
def PRE_first_tail_x6_r0_body.nr1 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd1 : RData :=
  ⟨2675765, 2675767, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18226, 18226, 15318, 15318, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa1 : Map :=
  Conv.Map.compact 2675765 2675767 122 PRE_first_tail_x6_r0_body.pl1 (PRE_first_tail_x6_r0_body.nr1.map NumV.ref) PRE_first_tail_x6_r0_body.kd1.big
    PRE_first_tail_x6_r0_body.kd1.region PRE_first_tail_x6_r0_body.kd1.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws1 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs1 : List SymE := PRE_first_tail_x6_r0_body.nr1.map fun r => (nth? PRE_first_tail_x6_r0_body.S25.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta1 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws1 PRE_first_tail_x6_r0_body.crs1
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB1 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab1 : PRE_first_tail_x6_r0_body.S26.tab = PRE_first_tail_x6_r0_body.S24.tab ++ PRE_first_tail_x6_r0_body.cws1.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace1 : PRE_first_tail_x6_r0_body.s26.trace = PRE_first_tail_x6_r0_body.s24.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext1 : PRE_first_tail_x6_r0_body.s26.next = 2675765
kernel_rfl PRE_first_tail_x6_r0_body.ccounters1 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx.nnext) = (18226, 15318)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue1 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s25.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa1.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp1 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx.tokens.all (bSN 122) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean1 : Conv.cleanListB 18226 131072 (fun r => Nat.ble 72904 r) PRE_first_tail_x6_r0_body.s26
    (PRE_first_tail_x6_r0_body.wrB1 ++ (List.range 0).map (2675765 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs1 : bigsOutB 18226 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl1`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl1 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo1 : List Nat := []
def PRE_first_tail_x6_r0_body.cln1 : List Nat := []
def PRE_first_tail_x6_r0_body.cli1 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap1 : PRE_first_tail_x6_r0_body.s26.heap = Stage.setAll PRE_first_tail_x6_r0_body.s24.heap (PRE_first_tail_x6_r0_body.cl1.filterMap fun a => (PRE_first_tail_x6_r0_body.s26.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe1 : Nat.ble PRE_first_tail_x6_r0_body.s24.next PRE_first_tail_x6_r0_body.s26.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP1 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s24 PRE_first_tail_x6_r0_body.s26 PRE_first_tail_x6_r0_body.cl1 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp1 : Conv.suppListB PRE_first_tail_x6_r0_body.s26 122 PRE_first_tail_x6_r0_body.cl1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound1 : Conv.boundListB PRE_first_tail_x6_r0_body.s26 PRE_first_tail_x6_r0_body.cl1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK1 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK1 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK1 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst1 : Conv.sstListB 122 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx PRE_first_tail_x6_r0_body.cln1 PRE_first_tail_x6_r0_body.clo1 PRE_first_tail_x6_r0_body.cli1 = true

end Host.Load.Run.Tpl
end

section -- SiteCl1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA1 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd1 : (PRE_first_tail_x6_r0_body.clo1 ++ PRE_first_tail_x6_r0_body.cln1 ++ PRE_first_tail_x6_r0_body.cli1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle1 : Conv.Cnt.leB (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck1 : Conv.ncleanListB (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx PRE_first_tail_x6_r0_body.clo1 PRE_first_tail_x6_r0_body.cln1 PRE_first_tail_x6_r0_body.cli1 = true
theorem PRE_first_tail_x6_r0_body.cncl1 (h : Conv.NClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx) : Conv.NClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle1 PRE_first_tail_x6_r0_body.ckA1 PRE_first_tail_x6_r0_body.cobjsK1 PRE_first_tail_x6_r0_body.cnodesK1 PRE_first_tail_x6_r0_body.citemsK1 PRE_first_tail_x6_r0_body.cbd1 PRE_first_tail_x6_r0_body.cck1

end Host.Load.Run.Tpl
end

section -- SiteS1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 1 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc1 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P1 : LoadP := PRE_first_tail_x6_r0_body.Pc1.raise 15318
kernel_rfl PRE_first_tail_x6_r0_body.craise1 : Nat.ble PRE_first_tail_x6_r0_body.Pc1.N0 15318 = true
theorem PRE_first_tail_x6_r0_body.raised1 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc1 PRE_first_tail_x6_r0_body.P1 :=
  .inr ⟨15318, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise1, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s25.ffi)
def PRE_first_tail_x6_r0_body.khinv1 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv1 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS1 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS1 : List Nat := List.range' 15318 0
def PRE_first_tail_x6_r0_body.ciS1 : List Nat := [] ++ List.range' 15318 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh01 : PRE_first_tail_x6_r0_body.kd1.nh0 = PRE_first_tail_x6_r0_body.cx0_1.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh11 : PRE_first_tail_x6_r0_body.kd1.nh1 = PRE_first_tail_x6_r0_body.cx1_1.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn01 : PRE_first_tail_x6_r0_body.kd1.nn0 = PRE_first_tail_x6_r0_body.cx0_1.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn11 : PRE_first_tail_x6_r0_body.kd1.nn1 = PRE_first_tail_x6_r0_body.cx1_1.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo1 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P1.lo && Nat.ble PRE_first_tail_x6_r0_body.P1.lo PRE_first_tail_x6_r0_body.cx0_1.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P1.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P1.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt1 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_1.mlx.next PRE_first_tail_x6_r0_body.cx1_1.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_1.mlx.nnext PRE_first_tail_x6_r0_body.cx1_1.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband1 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P1.NL && Nat.ble PRE_first_tail_x6_r0_body.P1.NL PRE_first_tail_x6_r0_body.P1.N0 && Nat.ble PRE_first_tail_x6_r0_body.P1.N0 PRE_first_tail_x6_r0_body.cx0_1.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow1 : PRE_first_tail_x6_r0_body.kd1.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren1 : checkRenG PRE_first_tail_x6_r0_body.kd1.hnd PRE_first_tail_x6_r0_body.khinv1 (phB PRE_first_tail_x6_r0_body.cx0_1.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband1 : PRE_first_tail_x6_r0_body.kd1.checkBand PRE_first_tail_x6_r0_body.P1.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos1 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd1.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren1 : checkRenG PRE_first_tail_x6_r0_body.kd1.node PRE_first_tail_x6_r0_body.kninv1 (pnB PRE_first_tail_x6_r0_body.cx0_1.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow1 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd1.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P1.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd1.nodeF j) PRE_first_tail_x6_r0_body.cx1_1.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a1 : PRE_first_tail_x6_r0_body.cx0_1.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b1 : PRE_first_tail_x6_r0_body.cx0_1.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok11 : PRE_first_tail_x6_r0_body.cx1_1.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend1 : PRE_first_tail_x6_r0_body.cx1_1.mlx.pending = PRE_first_tail_x6_r0_body.cx0_1.mlx.pending.map PRE_first_tail_x6_r0_body.kappa1.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh1 : PRE_first_tail_x6_r0_body.cx1_1.mlx.errh = PRE_first_tail_x6_r0_body.cx0_1.mlx.errh.map PRE_first_tail_x6_r0_body.kappa1.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles1 : PRE_first_tail_x6_r0_body.cx1_1.mlx.files = PRE_first_tail_x6_r0_body.cx0_1.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch1 : PRE_first_tail_x6_r0_body.cx1_1.mlx.arch = PRE_first_tail_x6_r0_body.cx0_1.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes1 : PRE_first_tail_x6_r0_body.cx1_1.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_1.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired1 : PRE_first_tail_x6_r0_body.cx1_1.mlx.wired = PRE_first_tail_x6_r0_body.cx0_1.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost1 : PRE_first_tail_x6_r0_body.cx1_1.host = PRE_first_tail_x6_r0_body.cx0_1.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd1`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn01 : PRE_first_tail_x6_r0_body.kd1.n0 = 2675765
kernel_rfl PRE_first_tail_x6_r0_body.ckn11 : PRE_first_tail_x6_r0_body.kd1.n1 = 2675767
kernel_rfl PRE_first_tail_x6_r0_body.ckheap1 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd1.heap).all (fun x => Nat.ble 2675765 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl1 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd1.heap.get (2675765 + j) = nth? PRE_first_tail_x6_r0_body.pl1 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja1 : Nat.ble 2675765 2675765 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn1 : Nat.ble 122 122 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD1 : Nat.ble 2675765 PRE_first_tail_x6_r0_body.kd1.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn1 : Nat.ble 18226 PRE_first_tail_x6_r0_body.kd1.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn1 : Nat.ble 15318 PRE_first_tail_x6_r0_body.kd1.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb1 : Nat.ble 18226 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap1 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd1.heap).all (Nat.ble (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd1 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd1.hnd).all (Nat.ble (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode1 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd1.node).all (Nat.ble (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix1 : Conv.FixOld (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa1 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja1) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn1) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD1) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn1) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn1) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb1) PRE_first_tail_x6_r0_body.fheap1 PRE_first_tail_x6_r0_body.fhnd1 PRE_first_tail_x6_r0_body.fnode1
kernel_rfl PRE_first_tail_x6_r0_body.fcxn1 : (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn1 : (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle01 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_1.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_1.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk1 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd1.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A1 : PRE_first_tail_x6_r0_body.cx1_1.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS1.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_1.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O1 : PRE_first_tail_x6_r0_body.cx1_1.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS1.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_1.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N1 : PRE_first_tail_x6_r0_body.cx1_1.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS1.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_1.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I1 : PRE_first_tail_x6_r0_body.cx1_1.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS1.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_1.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd1 : (PRE_first_tail_x6_r0_body.clo1 ++ PRE_first_tail_x6_r0_body.cln1 ++ PRE_first_tail_x6_r0_body.cli1 ++ PRE_first_tail_x6_r0_body.cwS1 ++ PRE_first_tail_x6_r0_body.cnS1 ++ PRE_first_tail_x6_r0_body.ciS1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW1 : PRE_first_tail_x6_r0_body.cwS1.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo1.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI1 : PRE_first_tail_x6_r0_body.ciS1.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli1.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN1 : PRE_first_tail_x6_r0_body.cnS1.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF1 : PRE_first_tail_x6_r0_body.cln1.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh1 : PRE_first_tail_x6_r0_body.clo1.all (handleOK PRE_first_tail_x6_r0_body.kappa1 PRE_first_tail_x6_r0_body.P1.lo PRE_first_tail_x6_r0_body.cx0_1.mlx PRE_first_tail_x6_r0_body.cx1_1.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo1 : PRE_first_tail_x6_r0_body.clo1.map (fun h => PRE_first_tail_x6_r0_body.cx1_1.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa1.handle h)) = PRE_first_tail_x6_r0_body.clo1.map (fun h => (PRE_first_tail_x6_r0_body.cx0_1.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa1.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok1 : PRE_first_tail_x6_r0_body.clo1.all (objOK PRE_first_tail_x6_r0_body.kappa1 PRE_first_tail_x6_r0_body.P1.NL PRE_first_tail_x6_r0_body.cx0_1.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd1 : PRE_first_tail_x6_r0_body.cln1.all (nodeOKF PRE_first_tail_x6_r0_body.kappa1 PRE_first_tail_x6_r0_body.P1 PRE_first_tail_x6_r0_body.cx0_1.mlx PRE_first_tail_x6_r0_body.cx1_1.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp1 : ((PRE_first_tail_x6_r0_body.cln1.filter (fullB PRE_first_tail_x6_r0_body.P1))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_1.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa1.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln1.filter (fullB PRE_first_tail_x6_r0_body.P1))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_1.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa1.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI1 : incrB PRE_first_tail_x6_r0_body.kd1.nodeF (List.range' 15318 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK1 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd1.node).all (fun k => Nat.ble 15318 k && Nat.blt k 15318) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL1 : (PRE_first_tail_x6_r0_body.cln1.filter (Nat.ble PRE_first_tail_x6_r0_body.P1.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd1.nodeF i) && (Nat.blt i 15318 || Nat.ble PRE_first_tail_x6_r0_body.kd1.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord1 : (PRE_first_tail_x6_r0_body.cln1.filter (Nat.ble PRE_first_tail_x6_r0_body.P1.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd1.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd1.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd1.nodeF j) (PRE_first_tail_x6_r0_body.kd1.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow1 PRE_first_tail_x6_r0_body.cnn11 PRE_first_tail_x6_r0_body.fnordI1 PRE_first_tail_x6_r0_body.fnordK1 PRE_first_tail_x6_r0_body.fnordL1
kernel_rfl PRE_first_tail_x6_r0_body.fi1 : PRE_first_tail_x6_r0_body.cli1.all (pnB PRE_first_tail_x6_r0_body.cx0_1.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii1 : PRE_first_tail_x6_r0_body.cli1.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_1.mlx.items.get (PRE_first_tail_x6_r0_body.kappa1.node k) = (PRE_first_tail_x6_r0_body.cx0_1.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa1.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot1 (clean : Conv.NClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P1.NL) (cl : SSt (· < 122) PRE_first_tail_x6_r0_body.cx0_1.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P1 122 PRE_first_tail_x6_r0_body.kappa1 PRE_first_tail_x6_r0_body.kd1 PRE_first_tail_x6_r0_body.khinv1 PRE_first_tail_x6_r0_body.kninv1 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx PRE_first_tail_x6_r0_body.cx0_1.mlx PRE_first_tail_x6_r0_body.cx1_1.mlx (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo1 PRE_first_tail_x6_r0_body.cln1 PRE_first_tail_x6_r0_body.cli1 PRE_first_tail_x6_r0_body.cwS1 PRE_first_tail_x6_r0_body.cnS1 PRE_first_tail_x6_r0_body.ciS1 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh01, PRE_first_tail_x6_r0_body.cnh11, PRE_first_tail_x6_r0_body.cnn01, PRE_first_tail_x6_r0_body.cnn11, PRE_first_tail_x6_r0_body.cplo1, PRE_first_tail_x6_r0_body.ccnt1, PRE_first_tail_x6_r0_body.cnband1, PRE_first_tail_x6_r0_body.chbelow1, PRE_first_tail_x6_r0_body.chren1, PRE_first_tail_x6_r0_body.cband1, PRE_first_tail_x6_r0_body.cnh1pos1, PRE_first_tail_x6_r0_body.cnren1, PRE_first_tail_x6_r0_body.cnlow1, PRE_first_tail_x6_r0_body.cabs0a1, PRE_first_tail_x6_r0_body.cabs0b1, PRE_first_tail_x6_r0_body.ctok11, PRE_first_tail_x6_r0_body.cpend1, PRE_first_tail_x6_r0_body.cerrh1, PRE_first_tail_x6_r0_body.cfiles1, PRE_first_tail_x6_r0_body.carch1, PRE_first_tail_x6_r0_body.csizes1, PRE_first_tail_x6_r0_body.cwired1, PRE_first_tail_x6_r0_body.cfix1, clean, PRE_first_tail_x6_r0_body.fcxn1, PRE_first_tail_x6_r0_body.fcnn1, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle01, PRE_first_tail_x6_r0_body.fnk1, PRE_first_tail_x6_r0_body.ckA1, PRE_first_tail_x6_r0_body.cobjsK1, PRE_first_tail_x6_r0_body.cnodesK1, PRE_first_tail_x6_r0_body.citemsK1, PRE_first_tail_x6_r0_body.f1A1, PRE_first_tail_x6_r0_body.f1O1, PRE_first_tail_x6_r0_body.f1N1, PRE_first_tail_x6_r0_body.f1I1, PRE_first_tail_x6_r0_body.fbd1, PRE_first_tail_x6_r0_body.fincW1, PRE_first_tail_x6_r0_body.fincI1, PRE_first_tail_x6_r0_body.fincN1, PRE_first_tail_x6_r0_body.flnF1, PRE_first_tail_x6_r0_body.fh1, PRE_first_tail_x6_r0_body.fo1, PRE_first_tail_x6_r0_body.fok1, PRE_first_tail_x6_r0_body.fnd1, PRE_first_tail_x6_r0_body.fp1, PRE_first_tail_x6_r0_body.fnord1, PRE_first_tail_x6_r0_body.fi1, PRE_first_tail_x6_r0_body.fii1⟩
theorem PRE_first_tail_x6_r0_body.cnshift1 (clean : Conv.NClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P1.NL) (cl : SSt (· < 122) PRE_first_tail_x6_r0_body.cx0_1.mlx) : NShift PRE_first_tail_x6_r0_body.P1 122 PRE_first_tail_x6_r0_body.kappa1 PRE_first_tail_x6_r0_body.cx0_1 PRE_first_tail_x6_r0_body.cx1_1 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot1 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost1 (compact_a_eq PRE_first_tail_x6_r0_body.ckn01 PRE_first_tail_x6_r0_body.ckn11 PRE_first_tail_x6_r0_body.ckheap1 PRE_first_tail_x6_r0_body.ckpl1)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s24.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s24.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_1 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s24.ffi) = some PRE_first_tail_x6_r0_body.fxC_1
kernel_rfl PRE_first_tail_x6_r0_body.okrC_1 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s24.ffi) = some PRE_first_tail_x6_r0_body.krC_1
noncomputable def PRE_first_tail_x6_r0_body.fx0_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s26.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s26.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_1 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s26.ffi) = some PRE_first_tail_x6_r0_body.fx0_1
kernel_rfl PRE_first_tail_x6_r0_body.okr0_1 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s26.ffi) = some PRE_first_tail_x6_r0_body.kr0_1
noncomputable def PRE_first_tail_x6_r0_body.fx1_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s25.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s25.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_1 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s25.ffi) = some PRE_first_tail_x6_r0_body.fx1_1
kernel_rfl PRE_first_tail_x6_r0_body.okr1_1 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s25.ffi) = some PRE_first_tail_x6_r0_body.kr1_1
kernel_rfl PRE_first_tail_x6_r0_body.ff01 : PRE_first_tail_x6_r0_body.fx0_1 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_1 (PRE_first_tail_x6_r0_body.clo1.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_1.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff11 : PRE_first_tail_x6_r0_body.fx1_1 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_1 (PRE_first_tail_x6_r0_body.cwS1.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_1.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck1 : freedLB PRE_first_tail_x6_r0_body.kappa1 PRE_first_tail_x6_r0_body.cx0_1.mlx PRE_first_tail_x6_r0_body.fx0_1 PRE_first_tail_x6_r0_body.fx1_1 PRE_first_tail_x6_r0_body.clo1 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf01 : PRE_first_tail_x6_r0_body.kr0_1.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_1.flags (PRE_first_tail_x6_r0_body.clo1.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_1.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt01 : PRE_first_tail_x6_r0_body.kr0_1.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_1.targs (PRE_first_tail_x6_r0_body.clo1.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_1.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf11 : PRE_first_tail_x6_r0_body.kr1_1.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_1.flags (PRE_first_tail_x6_r0_body.cwS1.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_1.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt11 : PRE_first_tail_x6_r0_body.kr1_1.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_1.targs (PRE_first_tail_x6_r0_body.cwS1.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_1.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck1 : krecLB PRE_first_tail_x6_r0_body.kappa1 122 PRE_first_tail_x6_r0_body.cx0_1.mlx PRE_first_tail_x6_r0_body.kr0_1 PRE_first_tail_x6_r0_body.kr1_1 PRE_first_tail_x6_r0_body.clo1 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn1 : Nat.ble 122 122 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge1 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s25.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s26.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR1 : pendRegB PRE_first_tail_x6_r0_body.kappa1 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe1 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s26.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s25.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift1 (clean : Conv.NClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P1.NL) (cl : SSt (· < 122) PRE_first_tail_x6_r0_body.cx0_1.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_1.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_1.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_1.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s24.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_1.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P1 122 PRE_first_tail_x6_r0_body.kappa1 PRE_first_tail_x6_r0_body.s26.ffi PRE_first_tail_x6_r0_body.s25.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift1 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue1, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp1 t ht),
    PRE_first_tail_x6_r0_body.cbridge1,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s26.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s25.ffi) (PRE_first_tail_x6_r0_body.cfoot1 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_1 PRE_first_tail_x6_r0_body.ofx1_1 hobjC PRE_first_tail_x6_r0_body.ff01 PRE_first_tail_x6_r0_body.ff11 PRE_first_tail_x6_r0_body.ffck1,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s26.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s25.ffi) (PRE_first_tail_x6_r0_body.cfoot1 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_1 PRE_first_tail_x6_r0_body.okr1_1 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn1) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf01 PRE_first_tail_x6_r0_body.fkt01 PRE_first_tail_x6_r0_body.fkf11 PRE_first_tail_x6_r0_body.fkt11 PRE_first_tail_x6_r0_body.fkck1,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh01 PRE_first_tail_x6_r0_body.cnh11 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe1) PRE_first_tail_x6_r0_body.cpendR1⟩

end Host.Load.Run.Tpl
end

section -- st1/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st1 0
host_stream_state PRE_first_tail_x6_r0_body.st1 1
host_stream_state PRE_first_tail_x6_r0_body.st1 2
end Host.Load.Run.Tpl
end

section -- Site1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 1 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g1__g2` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s24`, the merged state `PRE_first_tail_x6_r0_body.s25`,
the site template `PRE_first_tail_x6_r0_body.st1` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s26`: the merge.
The footprint's facts are in `SiteF1`, the compaction's in `SiteC1`, `SiteK1`, `SiteNa1`, `SiteNb1`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso1 : PRE_first_tail_x6_r0_body.st1.s0 = { PRE_first_tail_x6_r0_body.s24 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs1 : List Frame := PRE_first_tail_x6_r0_body.s24.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_1 : PRE_first_tail_x6_r0_body.S24.tab.length = 122
kernel_rfl PRE_first_tail_x6_r0_body.tab0_1 : PRE_first_tail_x6_r0_body.st1.S0.tab = PRE_first_tail_x6_r0_body.S24.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws1 : List Nat := [1049, 1050]
kernel_rfl PRE_first_tail_x6_r0_body.fresh1 : (PRE_first_tail_x6_r0_body.S24.tab.all fun e => PRE_first_tail_x6_r0_body.ws1.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S24.oracle.all fun q => PRE_first_tail_x6_r0_body.ws1.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab1 : PRE_first_tail_x6_r0_body.S25.tab = PRE_first_tail_x6_r0_body.S24.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws1
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen1 : PRE_first_tail_x6_r0_body.st1.S2.tab.length - PRE_first_tail_x6_r0_body.st1.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged1`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap1 : PRE_first_tail_x6_r0_body.s25.heap = PRE_first_tail_x6_r0_body.st1.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext1 : PRE_first_tail_x6_r0_body.s25.next = PRE_first_tail_x6_r0_body.st1.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl1 : PRE_first_tail_x6_r0_body.s25.ctl = PRE_first_tail_x6_r0_body.st1.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack1 : PRE_first_tail_x6_r0_body.s25.stack = PRE_first_tail_x6_r0_body.st1.s2.stack ++ PRE_first_tail_x6_r0_body.s24.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs1 : PRE_first_tail_x6_r0_body.s25.jobs = PRE_first_tail_x6_r0_body.st1.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi1 : PRE_first_tail_x6_r0_body.s25.ffi = PRE_first_tail_x6_r0_body.st1.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace1 : PRE_first_tail_x6_r0_body.s25.trace = PRE_first_tail_x6_r0_body.st1.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores1 : PRE_first_tail_x6_r0_body.s25.stores = PRE_first_tail_x6_r0_body.st1.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 1 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived1 : PRE_first_tail_x6_r0_body.nr1.map (fun r => nth? PRE_first_tail_x6_r0_body.st1.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo1 : PRE_first_tail_x6_r0_body.nr1.all (Nat.ble 122) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj1 : PRE_first_tail_x6_r0_body.cws1.all (fun c => !PRE_first_tail_x6_r0_body.ws1.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ1 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws1 PRE_first_tail_x6_r0_body.crs1 PRE_first_tail_x6_r0_body.ws1

end Host.Load.Run.Tpl
end

section -- st1/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st1`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st1.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st1.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st1.s2.heap PRE_first_tail_x6_r0_body.st1.wrR ++ freshOf PRE_first_tail_x6_r0_body.st1.s2.heap PRE_first_tail_x6_r0_body.st1.s0.next PRE_first_tail_x6_r0_body.st1.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st1.wr : List Nat := PRE_first_tail_x6_r0_body.st1.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st1.heapFoot : PRE_first_tail_x6_r0_body.st1.s2.heap = setAll PRE_first_tail_x6_r0_body.st1.s0.heap PRE_first_tail_x6_r0_body.st1.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st1.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st1.s0.next PRE_first_tail_x6_r0_body.st1.s2.next = true
theorem PRE_first_tail_x6_r0_body.st1.grows : PRE_first_tail_x6_r0_body.st1.s0.next ≤ PRE_first_tail_x6_r0_body.st1.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st1.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st1.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st1.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st1.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st1.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st1.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st1.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st1.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st1.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st1.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st1.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st1.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 1 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB1 : nodupT PRE_first_tail_x6_r0_body.st1.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup1 : PRE_first_tail_x6_r0_body.st1.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB1).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB1 : PRE_first_tail_x6_r0_body.st1.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound1 : ∀ b ∈ PRE_first_tail_x6_r0_body.st1.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB1 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr1 := PRE_first_tail_x6_r0_body.st1.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq1 : PRE_first_tail_x6_r0_body.st1.s2.trace = PRE_first_tail_x6_r0_body.trFr1 ++ PRE_first_tail_x6_r0_body.st1.s0.trace
theorem PRE_first_tail_x6_r0_body.trace1 : ∃ fr, PRE_first_tail_x6_r0_body.st1.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st1.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq1⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide1 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB1 : (PRE_first_tail_x6_r0_body.wide1.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st1.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix1 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide1, WFix Map.id (Present PRE_first_tail_x6_r0_body.st1.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB1 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 1 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s25`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO1 : PRE_first_tail_x6_r0_body.st1.S0.oracle = PRE_first_tail_x6_r0_body.st1.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B1 : PRE_first_tail_x6_r0_body.st1.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st1.s0.next || (PRE_first_tail_x6_r0_body.st1.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot1 : Conv.StageFoot PRE_first_tail_x6_r0_body.st1.wr PRE_first_tail_x6_r0_body.st1.s0 PRE_first_tail_x6_r0_body.st1.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st1.heapFoot PRE_first_tail_x6_r0_body.wrNodup1 PRE_first_tail_x6_r0_body.wrBound1 PRE_first_tail_x6_r0_body.wr0B1 PRE_first_tail_x6_r0_body.st1.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged1 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st1.F.S → PRE_first_tail_x6_r0_body.st1.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st1.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st1.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs1 PRE_first_tail_x6_r0_body.st1.wr PRE_first_tail_x6_r0_body.s24 PRE_first_tail_x6_r0_body.st1.s2 PRE_first_tail_x6_r0_body.st1.s0
      PRE_first_tail_x6_r0_body.st1.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st1.F FR W stk M ν K PRE_first_tail_x6_r0_body.s25 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso1 PRE_first_tail_x6_r0_body.stFoot1 PRE_first_tail_x6_r0_body.wrNodup1 PRE_first_tail_x6_r0_body.wrBound1 PRE_first_tail_x6_r0_body.trace1 PRE_first_tail_x6_r0_body.mheap1
    PRE_first_tail_x6_r0_body.mnext1 PRE_first_tail_x6_r0_body.mctl1 PRE_first_tail_x6_r0_body.mstack1 PRE_first_tail_x6_r0_body.mjobs1 PRE_first_tail_x6_r0_body.mffi1 PRE_first_tail_x6_r0_body.mtrace1 PRE_first_tail_x6_r0_body.mstores1 h

def PRE_first_tail_x6_r0_body.arrEl1_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE1_2665 : arrOf PRE_first_tail_x6_r0_body.s25 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl1_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA1_2665 : isArrB PRE_first_tail_x6_r0_body.s25 2665 = true
theorem PRE_first_tail_x6_r0_body.arr1_2665 : ∃ o, PRE_first_tail_x6_r0_body.s25.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl1_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE1_2665 PRE_first_tail_x6_r0_body.arrA1_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN1_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl1_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR1_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl1_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN1_2665

def PRE_first_tail_x6_r0_body.arrEl1_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE1_2673467 : arrOf PRE_first_tail_x6_r0_body.s25 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl1_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA1_2673467 : isArrB PRE_first_tail_x6_r0_body.s25 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr1_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s25.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl1_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE1_2673467 PRE_first_tail_x6_r0_body.arrA1_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN1_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl1_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR1_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl1_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN1_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k1 : isArrB PRE_first_tail_x6_r0_body.s25 4910 = false
theorem PRE_first_tail_x6_r0_body.keep1 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s25 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k1 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr1_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl1_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 1 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s24`, the merged
state `PRE_first_tail_x6_r0_body.s25`, the canonical state `PRE_first_tail_x6_r0_body.s26`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl1 : PRE_first_tail_x6_r0_body.pl1.all (Nat.ble PRE_first_tail_x6_r0_body.s24.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd1 : nodupT PRE_first_tail_x6_r0_body.pl1 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn11 : Nat.ble PRE_first_tail_x6_r0_body.s24.next 2675767 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst1 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s24.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn1 : PRE_first_tail_x6_r0_body.s26.next = PRE_first_tail_x6_r0_body.s24.next + PRE_first_tail_x6_r0_body.pl1.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn1 : PRE_first_tail_x6_r0_body.s25.next = 2675767
kernel_rfl PRE_first_tail_x6_r0_body.zgrow1 : Nat.ble PRE_first_tail_x6_r0_body.s26.next PRE_first_tail_x6_r0_body.s25.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh1 : PRE_first_tail_x6_r0_body.S24.tab.all (fun e => PRE_first_tail_x6_r0_body.cws1.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd1 : nodupT PRE_first_tail_x6_r0_body.cws1 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi1 : PRE_first_tail_x6_r0_body.nr1.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S25.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt1 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s24.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg1_2665 : PRE_first_tail_x6_r0_body.s26.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s26 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk1_2665 : (objOf PRE_first_tail_x6_r0_body.s26 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm1_2665 : PRE_first_tail_x6_r0_body.s25.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa1.obj (objOf PRE_first_tail_x6_r0_body.s26 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s25 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg1_2673467 : PRE_first_tail_x6_r0_body.s26.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s26 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk1_2673467 : (objOf PRE_first_tail_x6_r0_body.s26 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm1_2673467 : PRE_first_tail_x6_r0_body.s25.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa1.obj (objOf PRE_first_tail_x6_r0_body.s26 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s25 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw1_4910 : (PRE_first_tail_x6_r0_body.s26.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw1_2673472 : (PRE_first_tail_x6_r0_body.s26.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw1_2673473 : (PRE_first_tail_x6_r0_body.s26.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd1 : PRE_first_tail_x6_r0_body.cl1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr1 : PRE_first_tail_x6_r0_body.st1.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s24.next || PRE_first_tail_x6_r0_body.cl1.contains b) = true
def PRE_first_tail_x6_r0_body.zl1 : List Nat := PRE_first_tail_x6_r0_body.cl1.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE1 : PRE_first_tail_x6_r0_body.zl1.map (fun a => PRE_first_tail_x6_r0_body.s25.heap.get (PRE_first_tail_x6_r0_body.kappa1.a a)) = PRE_first_tail_x6_r0_body.zl1.map (fun a => (PRE_first_tail_x6_r0_body.s26.heap.get a).map PRE_first_tail_x6_r0_body.kappa1.hobj)
theorem PRE_first_tail_x6_r0_body.zimg1 : HeapImg PRE_first_tail_x6_r0_body.kappa1 PRE_first_tail_x6_r0_body.s26 PRE_first_tail_x6_r0_body.s25 PRE_first_tail_x6_r0_body.zl1 := PRE_first_tail_x6_r0_body.zimgE1
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl1 : PRE_first_tail_x6_r0_body.s25.ctl = PRE_first_tail_x6_r0_body.kappa1.ctl PRE_first_tail_x6_r0_body.s26.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack1 : PRE_first_tail_x6_r0_body.s25.stack = PRE_first_tail_x6_r0_body.s26.stack.map PRE_first_tail_x6_r0_body.kappa1.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs1 : PRE_first_tail_x6_r0_body.s25.jobs = PRE_first_tail_x6_r0_body.s26.jobs.map PRE_first_tail_x6_r0_body.kappa1.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores1 : PRE_first_tail_x6_r0_body.s25.stores = PRE_first_tail_x6_r0_body.kappa1.stores PRE_first_tail_x6_r0_body.s26.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots1 : checkRootsSupp PRE_first_tail_x6_r0_body.s26 122 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC1 : PRE_first_tail_x6_r0_body.S24.tab.length + PRE_first_tail_x6_r0_body.cws1.length = 122
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap1 : PRE_first_tail_x6_r0_body.kappa1 = Conv.Map.compact PRE_first_tail_x6_r0_body.s24.next 2675767 PRE_first_tail_x6_r0_body.S24.tab.length PRE_first_tail_x6_r0_body.pl1 (PRE_first_tail_x6_r0_body.nr1.map NumV.ref) PRE_first_tail_x6_r0_body.kd1.big
  PRE_first_tail_x6_r0_body.kd1.region PRE_first_tail_x6_r0_body.kd1.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin1 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s26.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc1 : Conv.jcleanListB (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s26 PRE_first_tail_x6_r0_body.cl1 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB1 : noBigRootsP (fun i => !Conv.oldBigB (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s26.trace PRE_first_tail_x6_r0_body.s26 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm1 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15318 = true
theorem PRE_first_tail_x6_r0_body.cjcl1 (h : Conv.JClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s24) : Conv.JClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s26 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle1)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd1 a ha)) PRE_first_tail_x6_r0_body.zjc1

end Host.Load.Run.Tpl
end

section -- st1/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st1.bodyLast from PRE_first_tail_x6_r0_body.st1.s1 to PRE_first_tail_x6_r0_body.st1.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st1.F PRE_first_tail_x6_r0_body.st1.s1).run PRE_first_tail_x6_r0_body.st1.S1 = some (PRE_first_tail_x6_r0_body.st1.s2, PRE_first_tail_x6_r0_body.st1.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st1.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st1.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st1.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st1.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st1/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st1.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st1.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st1.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st1.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st1.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st1.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st1.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st1.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st1.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st1.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st1.s0 PRE_first_tail_x6_r0_body.st1.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st1.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st1.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st1.s1 PRE_first_tail_x6_r0_body.st1.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st1/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st1.bodyK0F from PRE_first_tail_x6_r0_body.st1.s0 to PRE_first_tail_x6_r0_body.st1.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st1.F (PRE_first_tail_x6_r0_body.st1.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st1.ks 0).getD 0) PRE_first_tail_x6_r0_body.st1.s0 PRE_first_tail_x6_r0_body.st1.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st1.s1, PRE_first_tail_x6_r0_body.st1.S1)
theorem PRE_first_tail_x6_r0_body.st1.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st1.F (PRE_first_tail_x6_r0_body.st1.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st1.ks 0).getD 0) PRE_first_tail_x6_r0_body.st1.s0 PRE_first_tail_x6_r0_body.st1.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st1.s1, PRE_first_tail_x6_r0_body.st1.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st1.bodyOkLN_ok PRE_first_tail_x6_r0_body.st1.bodyK0F
end Host.Load.Run.Tpl
end

section -- st1/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st1.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st1.F (PRE_first_tail_x6_r0_body.st1.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st1.s0 PRE_first_tail_x6_r0_body.st1.S0 = some (PRE_first_tail_x6_r0_body.st1.s1, PRE_first_tail_x6_r0_body.st1.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st1.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st1.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st1.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st1.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st1.F (PRE_first_tail_x6_r0_body.st1.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st1.s0
  S0 := PRE_first_tail_x6_r0_body.st1.S0
  s1 := PRE_first_tail_x6_r0_body.st1.s1
  S1 := PRE_first_tail_x6_r0_body.st1.S1
  s2 := PRE_first_tail_x6_r0_body.st1.s2
  S2 := PRE_first_tail_x6_r0_body.st1.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st1.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st1.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st1.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st1.bodyHalt
  last := PRE_first_tail_x6_r0_body.st1.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st1.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 2 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s30` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa2` into the merged state
`PRE_first_tail_x6_r0_body.s29`. -/

def PRE_first_tail_x6_r0_body.pl2 : List Nat := [2676072]
def PRE_first_tail_x6_r0_body.nr2 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd2 : RData :=
  ⟨2676054, 2676073, Stage.setAll PTrie.nil [(2676053, 2676072)], Stage.setAll PTrie.nil [],
   18233, 18233, 15322, 15322, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa2 : Map :=
  Conv.Map.compact 2676053 2676073 139 PRE_first_tail_x6_r0_body.pl2 (PRE_first_tail_x6_r0_body.nr2.map NumV.ref) PRE_first_tail_x6_r0_body.kd2.big
    PRE_first_tail_x6_r0_body.kd2.region PRE_first_tail_x6_r0_body.kd2.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws2 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs2 : List SymE := PRE_first_tail_x6_r0_body.nr2.map fun r => (nth? PRE_first_tail_x6_r0_body.S29.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta2 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws2 PRE_first_tail_x6_r0_body.crs2
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB2 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab2 : PRE_first_tail_x6_r0_body.S30.tab = PRE_first_tail_x6_r0_body.S28.tab ++ PRE_first_tail_x6_r0_body.cws2.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace2 : PRE_first_tail_x6_r0_body.s30.trace = PRE_first_tail_x6_r0_body.s28.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext2 : PRE_first_tail_x6_r0_body.s30.next = 2676054
kernel_rfl PRE_first_tail_x6_r0_body.ccounters2 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx.nnext) = (18233, 15322)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue2 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s29.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa2.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp2 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx.tokens.all (bSN 139) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean2 : Conv.cleanListB 18233 131072 (fun r => Nat.ble 72932 r) PRE_first_tail_x6_r0_body.s30
    (PRE_first_tail_x6_r0_body.wrB2 ++ (List.range 1).map (2676053 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs2 : bigsOutB 18233 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl2`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl2 : List Nat := [2665, 2673467, 2676053]
def PRE_first_tail_x6_r0_body.clo2 : List Nat := []
def PRE_first_tail_x6_r0_body.cln2 : List Nat := []
def PRE_first_tail_x6_r0_body.cli2 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap2 : PRE_first_tail_x6_r0_body.s30.heap = Stage.setAll PRE_first_tail_x6_r0_body.s28.heap (PRE_first_tail_x6_r0_body.cl2.filterMap fun a => (PRE_first_tail_x6_r0_body.s30.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe2 : Nat.ble PRE_first_tail_x6_r0_body.s28.next PRE_first_tail_x6_r0_body.s30.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP2 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s28 PRE_first_tail_x6_r0_body.s30 PRE_first_tail_x6_r0_body.cl2 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp2 : Conv.suppListB PRE_first_tail_x6_r0_body.s30 139 PRE_first_tail_x6_r0_body.cl2 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound2 : Conv.boundListB PRE_first_tail_x6_r0_body.s30 PRE_first_tail_x6_r0_body.cl2 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK2 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln2.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK2 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo2.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK2 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli2.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst2 : Conv.sstListB 139 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx PRE_first_tail_x6_r0_body.cln2 PRE_first_tail_x6_r0_body.clo2 PRE_first_tail_x6_r0_body.cli2 = true

end Host.Load.Run.Tpl
end

section -- SiteCl2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA2 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo2.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd2 : (PRE_first_tail_x6_r0_body.clo2 ++ PRE_first_tail_x6_r0_body.cln2 ++ PRE_first_tail_x6_r0_body.cli2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle2 : Conv.Cnt.leB (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck2 : Conv.ncleanListB (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx PRE_first_tail_x6_r0_body.clo2 PRE_first_tail_x6_r0_body.cln2 PRE_first_tail_x6_r0_body.cli2 = true
theorem PRE_first_tail_x6_r0_body.cncl2 (h : Conv.NClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx) : Conv.NClean (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle2 PRE_first_tail_x6_r0_body.ckA2 PRE_first_tail_x6_r0_body.cobjsK2 PRE_first_tail_x6_r0_body.cnodesK2 PRE_first_tail_x6_r0_body.citemsK2 PRE_first_tail_x6_r0_body.cbd2 PRE_first_tail_x6_r0_body.cck2

end Host.Load.Run.Tpl
end

section -- SiteS2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 2 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc2 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P2 : LoadP := PRE_first_tail_x6_r0_body.Pc2.raise 15322
kernel_rfl PRE_first_tail_x6_r0_body.craise2 : Nat.ble PRE_first_tail_x6_r0_body.Pc2.N0 15322 = true
theorem PRE_first_tail_x6_r0_body.raised2 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc2 PRE_first_tail_x6_r0_body.P2 :=
  .inr ⟨15322, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise2, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s29.ffi)
def PRE_first_tail_x6_r0_body.khinv2 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv2 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS2 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS2 : List Nat := List.range' 15322 0
def PRE_first_tail_x6_r0_body.ciS2 : List Nat := [] ++ List.range' 15322 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh02 : PRE_first_tail_x6_r0_body.kd2.nh0 = PRE_first_tail_x6_r0_body.cx0_2.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh12 : PRE_first_tail_x6_r0_body.kd2.nh1 = PRE_first_tail_x6_r0_body.cx1_2.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn02 : PRE_first_tail_x6_r0_body.kd2.nn0 = PRE_first_tail_x6_r0_body.cx0_2.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn12 : PRE_first_tail_x6_r0_body.kd2.nn1 = PRE_first_tail_x6_r0_body.cx1_2.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo2 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P2.lo && Nat.ble PRE_first_tail_x6_r0_body.P2.lo PRE_first_tail_x6_r0_body.cx0_2.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P2.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P2.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt2 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_2.mlx.next PRE_first_tail_x6_r0_body.cx1_2.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_2.mlx.nnext PRE_first_tail_x6_r0_body.cx1_2.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband2 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P2.NL && Nat.ble PRE_first_tail_x6_r0_body.P2.NL PRE_first_tail_x6_r0_body.P2.N0 && Nat.ble PRE_first_tail_x6_r0_body.P2.N0 PRE_first_tail_x6_r0_body.cx0_2.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow2 : PRE_first_tail_x6_r0_body.kd2.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren2 : checkRenG PRE_first_tail_x6_r0_body.kd2.hnd PRE_first_tail_x6_r0_body.khinv2 (phB PRE_first_tail_x6_r0_body.cx0_2.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband2 : PRE_first_tail_x6_r0_body.kd2.checkBand PRE_first_tail_x6_r0_body.P2.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos2 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd2.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren2 : checkRenG PRE_first_tail_x6_r0_body.kd2.node PRE_first_tail_x6_r0_body.kninv2 (pnB PRE_first_tail_x6_r0_body.cx0_2.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow2 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd2.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P2.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd2.nodeF j) PRE_first_tail_x6_r0_body.cx1_2.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a2 : PRE_first_tail_x6_r0_body.cx0_2.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b2 : PRE_first_tail_x6_r0_body.cx0_2.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok12 : PRE_first_tail_x6_r0_body.cx1_2.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend2 : PRE_first_tail_x6_r0_body.cx1_2.mlx.pending = PRE_first_tail_x6_r0_body.cx0_2.mlx.pending.map PRE_first_tail_x6_r0_body.kappa2.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh2 : PRE_first_tail_x6_r0_body.cx1_2.mlx.errh = PRE_first_tail_x6_r0_body.cx0_2.mlx.errh.map PRE_first_tail_x6_r0_body.kappa2.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles2 : PRE_first_tail_x6_r0_body.cx1_2.mlx.files = PRE_first_tail_x6_r0_body.cx0_2.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch2 : PRE_first_tail_x6_r0_body.cx1_2.mlx.arch = PRE_first_tail_x6_r0_body.cx0_2.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes2 : PRE_first_tail_x6_r0_body.cx1_2.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_2.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired2 : PRE_first_tail_x6_r0_body.cx1_2.mlx.wired = PRE_first_tail_x6_r0_body.cx0_2.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost2 : PRE_first_tail_x6_r0_body.cx1_2.host = PRE_first_tail_x6_r0_body.cx0_2.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd2`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn02 : PRE_first_tail_x6_r0_body.kd2.n0 = 2676054
kernel_rfl PRE_first_tail_x6_r0_body.ckn12 : PRE_first_tail_x6_r0_body.kd2.n1 = 2676073
kernel_rfl PRE_first_tail_x6_r0_body.ckheap2 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd2.heap).all (fun x => Nat.ble 2676053 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl2 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd2.heap.get (2676053 + j) = nth? PRE_first_tail_x6_r0_body.pl2 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja2 : Nat.ble 2676053 2676053 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn2 : Nat.ble 139 139 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD2 : Nat.ble 2676053 PRE_first_tail_x6_r0_body.kd2.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn2 : Nat.ble 18233 PRE_first_tail_x6_r0_body.kd2.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn2 : Nat.ble 15322 PRE_first_tail_x6_r0_body.kd2.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb2 : Nat.ble 18233 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap2 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd2.heap).all (Nat.ble (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd2 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd2.hnd).all (Nat.ble (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode2 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd2.node).all (Nat.ble (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix2 : Conv.FixOld (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa2 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja2) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn2) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD2) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn2) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn2) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb2) PRE_first_tail_x6_r0_body.fheap2 PRE_first_tail_x6_r0_body.fhnd2 PRE_first_tail_x6_r0_body.fnode2
kernel_rfl PRE_first_tail_x6_r0_body.fcxn2 : (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn2 : (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle02 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_2.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_2.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk2 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd2.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A2 : PRE_first_tail_x6_r0_body.cx1_2.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS2.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_2.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O2 : PRE_first_tail_x6_r0_body.cx1_2.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS2.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_2.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N2 : PRE_first_tail_x6_r0_body.cx1_2.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS2.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_2.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I2 : PRE_first_tail_x6_r0_body.cx1_2.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS2.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_2.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd2 : (PRE_first_tail_x6_r0_body.clo2 ++ PRE_first_tail_x6_r0_body.cln2 ++ PRE_first_tail_x6_r0_body.cli2 ++ PRE_first_tail_x6_r0_body.cwS2 ++ PRE_first_tail_x6_r0_body.cnS2 ++ PRE_first_tail_x6_r0_body.ciS2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW2 : PRE_first_tail_x6_r0_body.cwS2.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo2.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI2 : PRE_first_tail_x6_r0_body.ciS2.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli2.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN2 : PRE_first_tail_x6_r0_body.cnS2.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF2 : PRE_first_tail_x6_r0_body.cln2.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh2 : PRE_first_tail_x6_r0_body.clo2.all (handleOK PRE_first_tail_x6_r0_body.kappa2 PRE_first_tail_x6_r0_body.P2.lo PRE_first_tail_x6_r0_body.cx0_2.mlx PRE_first_tail_x6_r0_body.cx1_2.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo2 : PRE_first_tail_x6_r0_body.clo2.map (fun h => PRE_first_tail_x6_r0_body.cx1_2.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa2.handle h)) = PRE_first_tail_x6_r0_body.clo2.map (fun h => (PRE_first_tail_x6_r0_body.cx0_2.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa2.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok2 : PRE_first_tail_x6_r0_body.clo2.all (objOK PRE_first_tail_x6_r0_body.kappa2 PRE_first_tail_x6_r0_body.P2.NL PRE_first_tail_x6_r0_body.cx0_2.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd2 : PRE_first_tail_x6_r0_body.cln2.all (nodeOKF PRE_first_tail_x6_r0_body.kappa2 PRE_first_tail_x6_r0_body.P2 PRE_first_tail_x6_r0_body.cx0_2.mlx PRE_first_tail_x6_r0_body.cx1_2.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp2 : ((PRE_first_tail_x6_r0_body.cln2.filter (fullB PRE_first_tail_x6_r0_body.P2))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_2.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa2.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln2.filter (fullB PRE_first_tail_x6_r0_body.P2))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_2.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa2.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI2 : incrB PRE_first_tail_x6_r0_body.kd2.nodeF (List.range' 15322 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK2 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd2.node).all (fun k => Nat.ble 15322 k && Nat.blt k 15322) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL2 : (PRE_first_tail_x6_r0_body.cln2.filter (Nat.ble PRE_first_tail_x6_r0_body.P2.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd2.nodeF i) && (Nat.blt i 15322 || Nat.ble PRE_first_tail_x6_r0_body.kd2.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord2 : (PRE_first_tail_x6_r0_body.cln2.filter (Nat.ble PRE_first_tail_x6_r0_body.P2.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd2.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd2.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd2.nodeF j) (PRE_first_tail_x6_r0_body.kd2.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow2 PRE_first_tail_x6_r0_body.cnn12 PRE_first_tail_x6_r0_body.fnordI2 PRE_first_tail_x6_r0_body.fnordK2 PRE_first_tail_x6_r0_body.fnordL2
kernel_rfl PRE_first_tail_x6_r0_body.fi2 : PRE_first_tail_x6_r0_body.cli2.all (pnB PRE_first_tail_x6_r0_body.cx0_2.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii2 : PRE_first_tail_x6_r0_body.cli2.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_2.mlx.items.get (PRE_first_tail_x6_r0_body.kappa2.node k) = (PRE_first_tail_x6_r0_body.cx0_2.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa2.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot2 (clean : Conv.NClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P2.NL) (cl : SSt (· < 139) PRE_first_tail_x6_r0_body.cx0_2.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P2 139 PRE_first_tail_x6_r0_body.kappa2 PRE_first_tail_x6_r0_body.kd2 PRE_first_tail_x6_r0_body.khinv2 PRE_first_tail_x6_r0_body.kninv2 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx PRE_first_tail_x6_r0_body.cx0_2.mlx PRE_first_tail_x6_r0_body.cx1_2.mlx (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo2 PRE_first_tail_x6_r0_body.cln2 PRE_first_tail_x6_r0_body.cli2 PRE_first_tail_x6_r0_body.cwS2 PRE_first_tail_x6_r0_body.cnS2 PRE_first_tail_x6_r0_body.ciS2 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh02, PRE_first_tail_x6_r0_body.cnh12, PRE_first_tail_x6_r0_body.cnn02, PRE_first_tail_x6_r0_body.cnn12, PRE_first_tail_x6_r0_body.cplo2, PRE_first_tail_x6_r0_body.ccnt2, PRE_first_tail_x6_r0_body.cnband2, PRE_first_tail_x6_r0_body.chbelow2, PRE_first_tail_x6_r0_body.chren2, PRE_first_tail_x6_r0_body.cband2, PRE_first_tail_x6_r0_body.cnh1pos2, PRE_first_tail_x6_r0_body.cnren2, PRE_first_tail_x6_r0_body.cnlow2, PRE_first_tail_x6_r0_body.cabs0a2, PRE_first_tail_x6_r0_body.cabs0b2, PRE_first_tail_x6_r0_body.ctok12, PRE_first_tail_x6_r0_body.cpend2, PRE_first_tail_x6_r0_body.cerrh2, PRE_first_tail_x6_r0_body.cfiles2, PRE_first_tail_x6_r0_body.carch2, PRE_first_tail_x6_r0_body.csizes2, PRE_first_tail_x6_r0_body.cwired2, PRE_first_tail_x6_r0_body.cfix2, clean, PRE_first_tail_x6_r0_body.fcxn2, PRE_first_tail_x6_r0_body.fcnn2, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle02, PRE_first_tail_x6_r0_body.fnk2, PRE_first_tail_x6_r0_body.ckA2, PRE_first_tail_x6_r0_body.cobjsK2, PRE_first_tail_x6_r0_body.cnodesK2, PRE_first_tail_x6_r0_body.citemsK2, PRE_first_tail_x6_r0_body.f1A2, PRE_first_tail_x6_r0_body.f1O2, PRE_first_tail_x6_r0_body.f1N2, PRE_first_tail_x6_r0_body.f1I2, PRE_first_tail_x6_r0_body.fbd2, PRE_first_tail_x6_r0_body.fincW2, PRE_first_tail_x6_r0_body.fincI2, PRE_first_tail_x6_r0_body.fincN2, PRE_first_tail_x6_r0_body.flnF2, PRE_first_tail_x6_r0_body.fh2, PRE_first_tail_x6_r0_body.fo2, PRE_first_tail_x6_r0_body.fok2, PRE_first_tail_x6_r0_body.fnd2, PRE_first_tail_x6_r0_body.fp2, PRE_first_tail_x6_r0_body.fnord2, PRE_first_tail_x6_r0_body.fi2, PRE_first_tail_x6_r0_body.fii2⟩
theorem PRE_first_tail_x6_r0_body.cnshift2 (clean : Conv.NClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P2.NL) (cl : SSt (· < 139) PRE_first_tail_x6_r0_body.cx0_2.mlx) : NShift PRE_first_tail_x6_r0_body.P2 139 PRE_first_tail_x6_r0_body.kappa2 PRE_first_tail_x6_r0_body.cx0_2 PRE_first_tail_x6_r0_body.cx1_2 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot2 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost2 (compact_a_eq PRE_first_tail_x6_r0_body.ckn02 PRE_first_tail_x6_r0_body.ckn12 PRE_first_tail_x6_r0_body.ckheap2 PRE_first_tail_x6_r0_body.ckpl2)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s28.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s28.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_2 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s28.ffi) = some PRE_first_tail_x6_r0_body.fxC_2
kernel_rfl PRE_first_tail_x6_r0_body.okrC_2 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s28.ffi) = some PRE_first_tail_x6_r0_body.krC_2
noncomputable def PRE_first_tail_x6_r0_body.fx0_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s30.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s30.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_2 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s30.ffi) = some PRE_first_tail_x6_r0_body.fx0_2
kernel_rfl PRE_first_tail_x6_r0_body.okr0_2 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s30.ffi) = some PRE_first_tail_x6_r0_body.kr0_2
noncomputable def PRE_first_tail_x6_r0_body.fx1_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s29.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s29.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_2 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s29.ffi) = some PRE_first_tail_x6_r0_body.fx1_2
kernel_rfl PRE_first_tail_x6_r0_body.okr1_2 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s29.ffi) = some PRE_first_tail_x6_r0_body.kr1_2
kernel_rfl PRE_first_tail_x6_r0_body.ff02 : PRE_first_tail_x6_r0_body.fx0_2 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_2 (PRE_first_tail_x6_r0_body.clo2.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_2.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff12 : PRE_first_tail_x6_r0_body.fx1_2 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_2 (PRE_first_tail_x6_r0_body.cwS2.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_2.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck2 : freedLB PRE_first_tail_x6_r0_body.kappa2 PRE_first_tail_x6_r0_body.cx0_2.mlx PRE_first_tail_x6_r0_body.fx0_2 PRE_first_tail_x6_r0_body.fx1_2 PRE_first_tail_x6_r0_body.clo2 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf02 : PRE_first_tail_x6_r0_body.kr0_2.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_2.flags (PRE_first_tail_x6_r0_body.clo2.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_2.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt02 : PRE_first_tail_x6_r0_body.kr0_2.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_2.targs (PRE_first_tail_x6_r0_body.clo2.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_2.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf12 : PRE_first_tail_x6_r0_body.kr1_2.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_2.flags (PRE_first_tail_x6_r0_body.cwS2.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_2.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt12 : PRE_first_tail_x6_r0_body.kr1_2.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_2.targs (PRE_first_tail_x6_r0_body.cwS2.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_2.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck2 : krecLB PRE_first_tail_x6_r0_body.kappa2 139 PRE_first_tail_x6_r0_body.cx0_2.mlx PRE_first_tail_x6_r0_body.kr0_2 PRE_first_tail_x6_r0_body.kr1_2 PRE_first_tail_x6_r0_body.clo2 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn2 : Nat.ble 139 139 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge2 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s29.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s30.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR2 : pendRegB PRE_first_tail_x6_r0_body.kappa2 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe2 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s30.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s29.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift2 (clean : Conv.NClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P2.NL) (cl : SSt (· < 139) PRE_first_tail_x6_r0_body.cx0_2.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_2.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_2.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_2.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s28.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_2.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P2 139 PRE_first_tail_x6_r0_body.kappa2 PRE_first_tail_x6_r0_body.s30.ffi PRE_first_tail_x6_r0_body.s29.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift2 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue2, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp2 t ht),
    PRE_first_tail_x6_r0_body.cbridge2,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s30.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s29.ffi) (PRE_first_tail_x6_r0_body.cfoot2 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_2 PRE_first_tail_x6_r0_body.ofx1_2 hobjC PRE_first_tail_x6_r0_body.ff02 PRE_first_tail_x6_r0_body.ff12 PRE_first_tail_x6_r0_body.ffck2,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s30.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s29.ffi) (PRE_first_tail_x6_r0_body.cfoot2 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_2 PRE_first_tail_x6_r0_body.okr1_2 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn2) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf02 PRE_first_tail_x6_r0_body.fkt02 PRE_first_tail_x6_r0_body.fkf12 PRE_first_tail_x6_r0_body.fkt12 PRE_first_tail_x6_r0_body.fkck2,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh02 PRE_first_tail_x6_r0_body.cnh12 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe2) PRE_first_tail_x6_r0_body.cpendR2⟩

end Host.Load.Run.Tpl
end

section -- st2/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st2 0
host_stream_state PRE_first_tail_x6_r0_body.st2 1
host_stream_state PRE_first_tail_x6_r0_body.st2 2
end Host.Load.Run.Tpl
end

section -- Site2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 2 of chain `PRE_first_tail_x6_r0_body`: `plan__g2__g3` (`plan`), the call state `PRE_first_tail_x6_r0_body.s28`, the merged state `PRE_first_tail_x6_r0_body.s29`,
the site template `PRE_first_tail_x6_r0_body.st2` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s30`: the merge.
The footprint's facts are in `SiteF2`, the compaction's in `SiteC2`, `SiteK2`, `SiteNa2`, `SiteNb2`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso2 : PRE_first_tail_x6_r0_body.st2.s0 = { PRE_first_tail_x6_r0_body.s28 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs2 : List Frame := PRE_first_tail_x6_r0_body.s28.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_2 : PRE_first_tail_x6_r0_body.S28.tab.length = 139
kernel_rfl PRE_first_tail_x6_r0_body.tab0_2 : PRE_first_tail_x6_r0_body.st2.S0.tab = PRE_first_tail_x6_r0_body.S28.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws2 : List Nat := [1051, 1052, 1053, 1054, 1055, 1056, 1057, 1058, 1059]
kernel_rfl PRE_first_tail_x6_r0_body.fresh2 : (PRE_first_tail_x6_r0_body.S28.tab.all fun e => PRE_first_tail_x6_r0_body.ws2.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S28.oracle.all fun q => PRE_first_tail_x6_r0_body.ws2.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab2 : PRE_first_tail_x6_r0_body.S29.tab = PRE_first_tail_x6_r0_body.S28.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws2
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen2 : PRE_first_tail_x6_r0_body.st2.S2.tab.length - PRE_first_tail_x6_r0_body.st2.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged2`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap2 : PRE_first_tail_x6_r0_body.s29.heap = PRE_first_tail_x6_r0_body.st2.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext2 : PRE_first_tail_x6_r0_body.s29.next = PRE_first_tail_x6_r0_body.st2.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl2 : PRE_first_tail_x6_r0_body.s29.ctl = PRE_first_tail_x6_r0_body.st2.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack2 : PRE_first_tail_x6_r0_body.s29.stack = PRE_first_tail_x6_r0_body.st2.s2.stack ++ PRE_first_tail_x6_r0_body.s28.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs2 : PRE_first_tail_x6_r0_body.s29.jobs = PRE_first_tail_x6_r0_body.st2.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi2 : PRE_first_tail_x6_r0_body.s29.ffi = PRE_first_tail_x6_r0_body.st2.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace2 : PRE_first_tail_x6_r0_body.s29.trace = PRE_first_tail_x6_r0_body.st2.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores2 : PRE_first_tail_x6_r0_body.s29.stores = PRE_first_tail_x6_r0_body.st2.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 2 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived2 : PRE_first_tail_x6_r0_body.nr2.map (fun r => nth? PRE_first_tail_x6_r0_body.st2.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo2 : PRE_first_tail_x6_r0_body.nr2.all (Nat.ble 139) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj2 : PRE_first_tail_x6_r0_body.cws2.all (fun c => !PRE_first_tail_x6_r0_body.ws2.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ2 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws2 PRE_first_tail_x6_r0_body.crs2 PRE_first_tail_x6_r0_body.ws2

end Host.Load.Run.Tpl
end

section -- st2/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st2`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st2.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st2.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st2.s2.heap PRE_first_tail_x6_r0_body.st2.wrR ++ freshOf PRE_first_tail_x6_r0_body.st2.s2.heap PRE_first_tail_x6_r0_body.st2.s0.next PRE_first_tail_x6_r0_body.st2.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st2.wr : List Nat := PRE_first_tail_x6_r0_body.st2.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st2.heapFoot : PRE_first_tail_x6_r0_body.st2.s2.heap = setAll PRE_first_tail_x6_r0_body.st2.s0.heap PRE_first_tail_x6_r0_body.st2.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st2.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st2.s0.next PRE_first_tail_x6_r0_body.st2.s2.next = true
theorem PRE_first_tail_x6_r0_body.st2.grows : PRE_first_tail_x6_r0_body.st2.s0.next ≤ PRE_first_tail_x6_r0_body.st2.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st2.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st2.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st2.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st2.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st2.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st2.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st2.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st2.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st2.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st2.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st2.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st2.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 2 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB2 : nodupT PRE_first_tail_x6_r0_body.st2.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup2 : PRE_first_tail_x6_r0_body.st2.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB2).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB2 : PRE_first_tail_x6_r0_body.st2.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound2 : ∀ b ∈ PRE_first_tail_x6_r0_body.st2.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB2 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr2 := PRE_first_tail_x6_r0_body.st2.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq2 : PRE_first_tail_x6_r0_body.st2.s2.trace = PRE_first_tail_x6_r0_body.trFr2 ++ PRE_first_tail_x6_r0_body.st2.s0.trace
theorem PRE_first_tail_x6_r0_body.trace2 : ∃ fr, PRE_first_tail_x6_r0_body.st2.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st2.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq2⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide2 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB2 : (PRE_first_tail_x6_r0_body.wide2.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st2.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix2 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide2, WFix Map.id (Present PRE_first_tail_x6_r0_body.st2.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB2 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 2 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s29`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO2 : PRE_first_tail_x6_r0_body.st2.S0.oracle = PRE_first_tail_x6_r0_body.st2.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B2 : PRE_first_tail_x6_r0_body.st2.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st2.s0.next || (PRE_first_tail_x6_r0_body.st2.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot2 : Conv.StageFoot PRE_first_tail_x6_r0_body.st2.wr PRE_first_tail_x6_r0_body.st2.s0 PRE_first_tail_x6_r0_body.st2.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st2.heapFoot PRE_first_tail_x6_r0_body.wrNodup2 PRE_first_tail_x6_r0_body.wrBound2 PRE_first_tail_x6_r0_body.wr0B2 PRE_first_tail_x6_r0_body.st2.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged2 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st2.F.S → PRE_first_tail_x6_r0_body.st2.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st2.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st2.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs2 PRE_first_tail_x6_r0_body.st2.wr PRE_first_tail_x6_r0_body.s28 PRE_first_tail_x6_r0_body.st2.s2 PRE_first_tail_x6_r0_body.st2.s0
      PRE_first_tail_x6_r0_body.st2.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st2.F FR W stk M ν K PRE_first_tail_x6_r0_body.s29 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso2 PRE_first_tail_x6_r0_body.stFoot2 PRE_first_tail_x6_r0_body.wrNodup2 PRE_first_tail_x6_r0_body.wrBound2 PRE_first_tail_x6_r0_body.trace2 PRE_first_tail_x6_r0_body.mheap2
    PRE_first_tail_x6_r0_body.mnext2 PRE_first_tail_x6_r0_body.mctl2 PRE_first_tail_x6_r0_body.mstack2 PRE_first_tail_x6_r0_body.mjobs2 PRE_first_tail_x6_r0_body.mffi2 PRE_first_tail_x6_r0_body.mtrace2 PRE_first_tail_x6_r0_body.mstores2 h

def PRE_first_tail_x6_r0_body.arrEl2_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE2_2665 : arrOf PRE_first_tail_x6_r0_body.s29 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl2_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA2_2665 : isArrB PRE_first_tail_x6_r0_body.s29 2665 = true
theorem PRE_first_tail_x6_r0_body.arr2_2665 : ∃ o, PRE_first_tail_x6_r0_body.s29.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl2_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE2_2665 PRE_first_tail_x6_r0_body.arrA2_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN2_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl2_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR2_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl2_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN2_2665

def PRE_first_tail_x6_r0_body.arrEl2_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE2_2673467 : arrOf PRE_first_tail_x6_r0_body.s29 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl2_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA2_2673467 : isArrB PRE_first_tail_x6_r0_body.s29 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr2_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s29.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl2_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE2_2673467 PRE_first_tail_x6_r0_body.arrA2_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN2_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl2_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR2_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl2_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN2_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k2 : isArrB PRE_first_tail_x6_r0_body.s29 4910 = false
theorem PRE_first_tail_x6_r0_body.keep2 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s29 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k2 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr2_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl2_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 2 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s28`, the merged
state `PRE_first_tail_x6_r0_body.s29`, the canonical state `PRE_first_tail_x6_r0_body.s30`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl2 : PRE_first_tail_x6_r0_body.pl2.all (Nat.ble PRE_first_tail_x6_r0_body.s28.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd2 : nodupT PRE_first_tail_x6_r0_body.pl2 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn12 : Nat.ble PRE_first_tail_x6_r0_body.s28.next 2676073 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst2 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s28.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn2 : PRE_first_tail_x6_r0_body.s30.next = PRE_first_tail_x6_r0_body.s28.next + PRE_first_tail_x6_r0_body.pl2.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn2 : PRE_first_tail_x6_r0_body.s29.next = 2676073
kernel_rfl PRE_first_tail_x6_r0_body.zgrow2 : Nat.ble PRE_first_tail_x6_r0_body.s30.next PRE_first_tail_x6_r0_body.s29.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh2 : PRE_first_tail_x6_r0_body.S28.tab.all (fun e => PRE_first_tail_x6_r0_body.cws2.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd2 : nodupT PRE_first_tail_x6_r0_body.cws2 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi2 : PRE_first_tail_x6_r0_body.nr2.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S29.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt2 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s28.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg2_2665 : PRE_first_tail_x6_r0_body.s30.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s30 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk2_2665 : (objOf PRE_first_tail_x6_r0_body.s30 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm2_2665 : PRE_first_tail_x6_r0_body.s29.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa2.obj (objOf PRE_first_tail_x6_r0_body.s30 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s29 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg2_2673467 : PRE_first_tail_x6_r0_body.s30.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s30 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk2_2673467 : (objOf PRE_first_tail_x6_r0_body.s30 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm2_2673467 : PRE_first_tail_x6_r0_body.s29.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa2.obj (objOf PRE_first_tail_x6_r0_body.s30 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s29 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw2_4910 : (PRE_first_tail_x6_r0_body.s30.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw2_2673472 : (PRE_first_tail_x6_r0_body.s30.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw2_2673473 : (PRE_first_tail_x6_r0_body.s30.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd2 : PRE_first_tail_x6_r0_body.cl2.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr2 : PRE_first_tail_x6_r0_body.st2.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s28.next || PRE_first_tail_x6_r0_body.cl2.contains b) = true
def PRE_first_tail_x6_r0_body.zl2 : List Nat := PRE_first_tail_x6_r0_body.cl2.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE2 : PRE_first_tail_x6_r0_body.zl2.map (fun a => PRE_first_tail_x6_r0_body.s29.heap.get (PRE_first_tail_x6_r0_body.kappa2.a a)) = PRE_first_tail_x6_r0_body.zl2.map (fun a => (PRE_first_tail_x6_r0_body.s30.heap.get a).map PRE_first_tail_x6_r0_body.kappa2.hobj)
theorem PRE_first_tail_x6_r0_body.zimg2 : HeapImg PRE_first_tail_x6_r0_body.kappa2 PRE_first_tail_x6_r0_body.s30 PRE_first_tail_x6_r0_body.s29 PRE_first_tail_x6_r0_body.zl2 := PRE_first_tail_x6_r0_body.zimgE2
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl2 : PRE_first_tail_x6_r0_body.s29.ctl = PRE_first_tail_x6_r0_body.kappa2.ctl PRE_first_tail_x6_r0_body.s30.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack2 : PRE_first_tail_x6_r0_body.s29.stack = PRE_first_tail_x6_r0_body.s30.stack.map PRE_first_tail_x6_r0_body.kappa2.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs2 : PRE_first_tail_x6_r0_body.s29.jobs = PRE_first_tail_x6_r0_body.s30.jobs.map PRE_first_tail_x6_r0_body.kappa2.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores2 : PRE_first_tail_x6_r0_body.s29.stores = PRE_first_tail_x6_r0_body.kappa2.stores PRE_first_tail_x6_r0_body.s30.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots2 : checkRootsSupp PRE_first_tail_x6_r0_body.s30 139 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC2 : PRE_first_tail_x6_r0_body.S28.tab.length + PRE_first_tail_x6_r0_body.cws2.length = 139
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap2 : PRE_first_tail_x6_r0_body.kappa2 = Conv.Map.compact PRE_first_tail_x6_r0_body.s28.next 2676073 PRE_first_tail_x6_r0_body.S28.tab.length PRE_first_tail_x6_r0_body.pl2 (PRE_first_tail_x6_r0_body.nr2.map NumV.ref) PRE_first_tail_x6_r0_body.kd2.big
  PRE_first_tail_x6_r0_body.kd2.region PRE_first_tail_x6_r0_body.kd2.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin2 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s30.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc2 : Conv.jcleanListB (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s30 PRE_first_tail_x6_r0_body.cl2 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB2 : noBigRootsP (fun i => !Conv.oldBigB (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s30.trace PRE_first_tail_x6_r0_body.s30 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm2 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15322 = true
theorem PRE_first_tail_x6_r0_body.cjcl2 (h : Conv.JClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s28) : Conv.JClean (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s30 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle2)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap2 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd2 a ha)) PRE_first_tail_x6_r0_body.zjc2

end Host.Load.Run.Tpl
end

section -- st2/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st2.bodyLast from PRE_first_tail_x6_r0_body.st2.s1 to PRE_first_tail_x6_r0_body.st2.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st2.F PRE_first_tail_x6_r0_body.st2.s1).run PRE_first_tail_x6_r0_body.st2.S1 = some (PRE_first_tail_x6_r0_body.st2.s2, PRE_first_tail_x6_r0_body.st2.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st2.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st2.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st2.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st2.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st2/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st2.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st2.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st2.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st2.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st2.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st2.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st2.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st2.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st2.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st2.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st2.s0 PRE_first_tail_x6_r0_body.st2.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st2.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st2.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st2.s1 PRE_first_tail_x6_r0_body.st2.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st2/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st2.bodyK0F from PRE_first_tail_x6_r0_body.st2.s0 to PRE_first_tail_x6_r0_body.st2.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st2.F (PRE_first_tail_x6_r0_body.st2.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st2.ks 0).getD 0) PRE_first_tail_x6_r0_body.st2.s0 PRE_first_tail_x6_r0_body.st2.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st2.s1, PRE_first_tail_x6_r0_body.st2.S1)
theorem PRE_first_tail_x6_r0_body.st2.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st2.F (PRE_first_tail_x6_r0_body.st2.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st2.ks 0).getD 0) PRE_first_tail_x6_r0_body.st2.s0 PRE_first_tail_x6_r0_body.st2.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st2.s1, PRE_first_tail_x6_r0_body.st2.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st2.bodyOkLN_ok PRE_first_tail_x6_r0_body.st2.bodyK0F
end Host.Load.Run.Tpl
end

section -- st2/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st2.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st2.F (PRE_first_tail_x6_r0_body.st2.bodyOkL bytes rows) 206 PRE_first_tail_x6_r0_body.st2.s0 PRE_first_tail_x6_r0_body.st2.S0 = some (PRE_first_tail_x6_r0_body.st2.s1, PRE_first_tail_x6_r0_body.st2.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st2.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st2.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st2.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st2.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st2.F (PRE_first_tail_x6_r0_body.st2.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st2.s0
  S0 := PRE_first_tail_x6_r0_body.st2.S0
  s1 := PRE_first_tail_x6_r0_body.st2.s1
  S1 := PRE_first_tail_x6_r0_body.st2.S1
  s2 := PRE_first_tail_x6_r0_body.st2.s2
  S2 := PRE_first_tail_x6_r0_body.st2.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st2.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st2.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st2.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st2.bodyHalt
  last := PRE_first_tail_x6_r0_body.st2.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st2.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 3 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s47` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa3` into the merged state
`PRE_first_tail_x6_r0_body.s46`. -/

def PRE_first_tail_x6_r0_body.pl3 : List Nat := [2678735, 2677910, 2678741, 2678737, 2677912, 2678743]
def PRE_first_tail_x6_r0_body.nr3 : List Nat := [242, 241, 217, 225, 230, 235, 240, 214, 215, 216, 223, 224, 212, 219, 220, 221, 222, 218]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd3 : RData :=
  ⟨2677629, 2678778, Stage.setAll PTrie.nil [(2677623, 2678735), (2677624, 2677910), (2677625, 2678741), (2677626, 2678737), (2677627, 2677912), (2677628, 2678743)], Stage.setAll PTrie.nil [(18270, 18296), (18271, 18274), (18272, 18297)],
   18273, 18298, 15368, 15368, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(212, .ref 242), (213, .ref 241), (214, .ref 217), (215, .ref 225), (216, .ref 230), (217, .ref 235), (218, .ref 240), (219, .ref 214), (220, .ref 215), (221, .ref 216), (222, .ref 223), (223, .ref 224), (224, .ref 212), (225, .ref 219), (226, .ref 220), (227, .ref 221), (228, .ref 222), (229, .ref 218)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa3 : Map :=
  Conv.Map.compact 2677623 2678778 212 PRE_first_tail_x6_r0_body.pl3 (PRE_first_tail_x6_r0_body.nr3.map NumV.ref) PRE_first_tail_x6_r0_body.kd3.big
    PRE_first_tail_x6_r0_body.kd3.region PRE_first_tail_x6_r0_body.kd3.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws3 : List Nat := [1091, 1092, 1093, 1094, 1095, 1096, 1097, 1098, 1099, 1100, 1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108]
noncomputable def PRE_first_tail_x6_r0_body.crs3 : List SymE := PRE_first_tail_x6_r0_body.nr3.map fun r => (nth? PRE_first_tail_x6_r0_body.S46.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta3 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws3 PRE_first_tail_x6_r0_body.crs3
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB3 : List Nat := [2665, 2672305, 2673467, 2676797, 2677342, 2677598]

kernel_rfl PRE_first_tail_x6_r0_body.ctab3 : PRE_first_tail_x6_r0_body.S47.tab = PRE_first_tail_x6_r0_body.S45.tab ++ PRE_first_tail_x6_r0_body.cws3.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace3 : PRE_first_tail_x6_r0_body.s47.trace = PRE_first_tail_x6_r0_body.s45.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext3 : PRE_first_tail_x6_r0_body.s47.next = 2677629
kernel_rfl PRE_first_tail_x6_r0_body.ccounters3 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx.nnext) = (18273, 15368)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue3 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s46.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa3.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp3 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx.tokens.all (bSN 230) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean3 : Conv.cleanListB 18273 131072 (fun r => Nat.ble 73092 r) PRE_first_tail_x6_r0_body.s47
    (PRE_first_tail_x6_r0_body.wrB3 ++ (List.range 6).map (2677623 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs3 : bigsOutB 18273 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl3`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl3 : List Nat := [2665, 2672305, 2673467, 2676797, 2677342, 2677598, 2677623, 2677624, 2677625, 2677626, 2677627, 2677628]
def PRE_first_tail_x6_r0_body.clo3 : List Nat := [18250, 18263, 18269, 18270, 18271, 18272]
def PRE_first_tail_x6_r0_body.cln3 : List Nat := [15341, 15342, 15343, 15344, 15345, 15346, 15347, 15348, 15349, 15350, 15351, 15352, 15353, 15354, 15355, 15356, 15357, 15358, 15359, 15360, 15361, 15362, 15363, 15364, 15365, 15366, 15367]
def PRE_first_tail_x6_r0_body.cli3 : List Nat := [15341, 15342, 15343, 15344, 15345, 15346, 15347, 15348, 15349, 15350, 15351, 15352, 15353, 15354, 15355, 15356, 15357, 15358, 15359, 15360, 15361, 15362, 15363, 15364, 15365, 15366, 15367]
kernel_rfl PRE_first_tail_x6_r0_body.cheap3 : PRE_first_tail_x6_r0_body.s47.heap = Stage.setAll PRE_first_tail_x6_r0_body.s45.heap (PRE_first_tail_x6_r0_body.cl3.filterMap fun a => (PRE_first_tail_x6_r0_body.s47.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe3 : Nat.ble PRE_first_tail_x6_r0_body.s45.next PRE_first_tail_x6_r0_body.s47.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP3 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s45 PRE_first_tail_x6_r0_body.s47 PRE_first_tail_x6_r0_body.cl3 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp3 : Conv.suppListB PRE_first_tail_x6_r0_body.s47 230 PRE_first_tail_x6_r0_body.cl3 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound3 : Conv.boundListB PRE_first_tail_x6_r0_body.s47 PRE_first_tail_x6_r0_body.cl3 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK3 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln3.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK3 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo3.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK3 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli3.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst3 : Conv.sstListB 230 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx PRE_first_tail_x6_r0_body.cln3 PRE_first_tail_x6_r0_body.clo3 PRE_first_tail_x6_r0_body.cli3 = true

end Host.Load.Run.Tpl
end

section -- SiteCl3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA3 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo3.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd3 : (PRE_first_tail_x6_r0_body.clo3 ++ PRE_first_tail_x6_r0_body.cln3 ++ PRE_first_tail_x6_r0_body.cli3).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle3 : Conv.Cnt.leB (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) (⟨18273, 15368, 2677629, 230⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck3 : Conv.ncleanListB (⟨18273, 15368, 2677629, 230⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx PRE_first_tail_x6_r0_body.clo3 PRE_first_tail_x6_r0_body.cln3 PRE_first_tail_x6_r0_body.cli3 = true
theorem PRE_first_tail_x6_r0_body.cncl3 (h : Conv.NClean (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx) : Conv.NClean (⟨18273, 15368, 2677629, 230⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle3 PRE_first_tail_x6_r0_body.ckA3 PRE_first_tail_x6_r0_body.cobjsK3 PRE_first_tail_x6_r0_body.cnodesK3 PRE_first_tail_x6_r0_body.citemsK3 PRE_first_tail_x6_r0_body.cbd3 PRE_first_tail_x6_r0_body.cck3

end Host.Load.Run.Tpl
end

section -- SiteS3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 3 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc3 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P3 : LoadP := PRE_first_tail_x6_r0_body.Pc3.raise 15368
kernel_rfl PRE_first_tail_x6_r0_body.craise3 : Nat.ble PRE_first_tail_x6_r0_body.Pc3.N0 15368 = true
theorem PRE_first_tail_x6_r0_body.raised3 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc3 PRE_first_tail_x6_r0_body.P3 :=
  .inr ⟨15368, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise3, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_3 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_3 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s46.ffi)
def PRE_first_tail_x6_r0_body.khinv3 : PTrie Nat := Stage.setAll PTrie.nil [(18296, 18270), (18274, 18271), (18297, 18272)]
def PRE_first_tail_x6_r0_body.kninv3 : PTrie Nat := Stage.setAll PTrie.nil [(15341, 15341), (15342, 15342), (15343, 15343), (15344, 15344), (15345, 15345), (15346, 15346), (15347, 15347), (15348, 15348), (15349, 15349), (15350, 15350), (15351, 15351), (15352, 15352), (15353, 15353), (15354, 15354), (15355, 15355), (15356, 15356), (15357, 15357), (15358, 15358), (15359, 15359), (15360, 15360), (15361, 15361), (15362, 15362), (15363, 15363), (15364, 15364), (15365, 15365), (15366, 15366), (15367, 15367)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS3 : List Nat := [18250, 18263, 18269, 18270, 18271, 18272, 18273, 18274, 18275, 18276, 18277, 18278, 18279, 18280, 18281, 18282, 18283, 18284, 18285, 18286, 18287, 18288, 18289, 18290, 18291, 18292, 18293, 18294, 18295, 18296, 18297]
def PRE_first_tail_x6_r0_body.cnS3 : List Nat := List.range' 15341 27
def PRE_first_tail_x6_r0_body.ciS3 : List Nat := [] ++ List.range' 15341 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh03 : PRE_first_tail_x6_r0_body.kd3.nh0 = PRE_first_tail_x6_r0_body.cx0_3.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh13 : PRE_first_tail_x6_r0_body.kd3.nh1 = PRE_first_tail_x6_r0_body.cx1_3.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn03 : PRE_first_tail_x6_r0_body.kd3.nn0 = PRE_first_tail_x6_r0_body.cx0_3.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn13 : PRE_first_tail_x6_r0_body.kd3.nn1 = PRE_first_tail_x6_r0_body.cx1_3.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo3 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P3.lo && Nat.ble PRE_first_tail_x6_r0_body.P3.lo PRE_first_tail_x6_r0_body.cx0_3.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P3.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P3.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt3 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_3.mlx.next PRE_first_tail_x6_r0_body.cx1_3.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_3.mlx.nnext PRE_first_tail_x6_r0_body.cx1_3.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband3 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P3.NL && Nat.ble PRE_first_tail_x6_r0_body.P3.NL PRE_first_tail_x6_r0_body.P3.N0 && Nat.ble PRE_first_tail_x6_r0_body.P3.N0 PRE_first_tail_x6_r0_body.cx0_3.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow3 : PRE_first_tail_x6_r0_body.kd3.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren3 : checkRenG PRE_first_tail_x6_r0_body.kd3.hnd PRE_first_tail_x6_r0_body.khinv3 (phB PRE_first_tail_x6_r0_body.cx0_3.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband3 : PRE_first_tail_x6_r0_body.kd3.checkBand PRE_first_tail_x6_r0_body.P3.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos3 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd3.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren3 : checkRenG PRE_first_tail_x6_r0_body.kd3.node PRE_first_tail_x6_r0_body.kninv3 (pnB PRE_first_tail_x6_r0_body.cx0_3.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow3 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd3.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P3.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd3.nodeF j) PRE_first_tail_x6_r0_body.cx1_3.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a3 : PRE_first_tail_x6_r0_body.cx0_3.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b3 : PRE_first_tail_x6_r0_body.cx0_3.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok13 : PRE_first_tail_x6_r0_body.cx1_3.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend3 : PRE_first_tail_x6_r0_body.cx1_3.mlx.pending = PRE_first_tail_x6_r0_body.cx0_3.mlx.pending.map PRE_first_tail_x6_r0_body.kappa3.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh3 : PRE_first_tail_x6_r0_body.cx1_3.mlx.errh = PRE_first_tail_x6_r0_body.cx0_3.mlx.errh.map PRE_first_tail_x6_r0_body.kappa3.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles3 : PRE_first_tail_x6_r0_body.cx1_3.mlx.files = PRE_first_tail_x6_r0_body.cx0_3.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch3 : PRE_first_tail_x6_r0_body.cx1_3.mlx.arch = PRE_first_tail_x6_r0_body.cx0_3.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes3 : PRE_first_tail_x6_r0_body.cx1_3.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_3.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired3 : PRE_first_tail_x6_r0_body.cx1_3.mlx.wired = PRE_first_tail_x6_r0_body.cx0_3.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost3 : PRE_first_tail_x6_r0_body.cx1_3.host = PRE_first_tail_x6_r0_body.cx0_3.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd3`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn03 : PRE_first_tail_x6_r0_body.kd3.n0 = 2677629
kernel_rfl PRE_first_tail_x6_r0_body.ckn13 : PRE_first_tail_x6_r0_body.kd3.n1 = 2678778
kernel_rfl PRE_first_tail_x6_r0_body.ckheap3 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd3.heap).all (fun x => Nat.ble 2677623 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl3 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd3.heap.get (2677623 + j) = nth? PRE_first_tail_x6_r0_body.pl3 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja3 : Nat.ble 2677623 2677623 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn3 : Nat.ble 212 212 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD3 : Nat.ble 2677623 PRE_first_tail_x6_r0_body.kd3.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn3 : Nat.ble 18270 PRE_first_tail_x6_r0_body.kd3.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn3 : Nat.ble 15341 PRE_first_tail_x6_r0_body.kd3.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb3 : Nat.ble 18270 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap3 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd3.heap).all (Nat.ble (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd3 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd3.hnd).all (Nat.ble (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode3 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd3.node).all (Nat.ble (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix3 : Conv.FixOld (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa3 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja3) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn3) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD3) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn3) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn3) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb3) PRE_first_tail_x6_r0_body.fheap3 PRE_first_tail_x6_r0_body.fhnd3 PRE_first_tail_x6_r0_body.fnode3
kernel_rfl PRE_first_tail_x6_r0_body.fcxn3 : (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn3 : (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle03 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_3.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_3.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk3 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd3.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A3 : PRE_first_tail_x6_r0_body.cx1_3.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS3.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_3.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O3 : PRE_first_tail_x6_r0_body.cx1_3.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS3.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_3.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N3 : PRE_first_tail_x6_r0_body.cx1_3.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS3.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_3.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I3 : PRE_first_tail_x6_r0_body.cx1_3.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS3.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_3.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd3 : (PRE_first_tail_x6_r0_body.clo3 ++ PRE_first_tail_x6_r0_body.cln3 ++ PRE_first_tail_x6_r0_body.cli3 ++ PRE_first_tail_x6_r0_body.cwS3 ++ PRE_first_tail_x6_r0_body.cnS3 ++ PRE_first_tail_x6_r0_body.ciS3).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW3 : PRE_first_tail_x6_r0_body.cwS3.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo3.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI3 : PRE_first_tail_x6_r0_body.ciS3.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli3.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN3 : PRE_first_tail_x6_r0_body.cnS3.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF3 : PRE_first_tail_x6_r0_body.cln3.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh3 : PRE_first_tail_x6_r0_body.clo3.all (handleOK PRE_first_tail_x6_r0_body.kappa3 PRE_first_tail_x6_r0_body.P3.lo PRE_first_tail_x6_r0_body.cx0_3.mlx PRE_first_tail_x6_r0_body.cx1_3.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo3 : PRE_first_tail_x6_r0_body.clo3.map (fun h => PRE_first_tail_x6_r0_body.cx1_3.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa3.handle h)) = PRE_first_tail_x6_r0_body.clo3.map (fun h => (PRE_first_tail_x6_r0_body.cx0_3.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa3.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok3 : PRE_first_tail_x6_r0_body.clo3.all (objOK PRE_first_tail_x6_r0_body.kappa3 PRE_first_tail_x6_r0_body.P3.NL PRE_first_tail_x6_r0_body.cx0_3.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd3 : PRE_first_tail_x6_r0_body.cln3.all (nodeOKF PRE_first_tail_x6_r0_body.kappa3 PRE_first_tail_x6_r0_body.P3 PRE_first_tail_x6_r0_body.cx0_3.mlx PRE_first_tail_x6_r0_body.cx1_3.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp3 : ((PRE_first_tail_x6_r0_body.cln3.filter (fullB PRE_first_tail_x6_r0_body.P3))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_3.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa3.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln3.filter (fullB PRE_first_tail_x6_r0_body.P3))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_3.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa3.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI3 : incrB PRE_first_tail_x6_r0_body.kd3.nodeF (List.range' 15341 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK3 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd3.node).all (fun k => Nat.ble 15341 k && Nat.blt k 15368) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL3 : (PRE_first_tail_x6_r0_body.cln3.filter (Nat.ble PRE_first_tail_x6_r0_body.P3.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd3.nodeF i) && (Nat.blt i 15368 || Nat.ble PRE_first_tail_x6_r0_body.kd3.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord3 : (PRE_first_tail_x6_r0_body.cln3.filter (Nat.ble PRE_first_tail_x6_r0_body.P3.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd3.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd3.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd3.nodeF j) (PRE_first_tail_x6_r0_body.kd3.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow3 PRE_first_tail_x6_r0_body.cnn13 PRE_first_tail_x6_r0_body.fnordI3 PRE_first_tail_x6_r0_body.fnordK3 PRE_first_tail_x6_r0_body.fnordL3
kernel_rfl PRE_first_tail_x6_r0_body.fi3 : PRE_first_tail_x6_r0_body.cli3.all (pnB PRE_first_tail_x6_r0_body.cx0_3.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii3 : PRE_first_tail_x6_r0_body.cli3.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_3.mlx.items.get (PRE_first_tail_x6_r0_body.kappa3.node k) = (PRE_first_tail_x6_r0_body.cx0_3.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa3.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot3 (clean : Conv.NClean (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P3.NL) (cl : SSt (· < 230) PRE_first_tail_x6_r0_body.cx0_3.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P3 230 PRE_first_tail_x6_r0_body.kappa3 PRE_first_tail_x6_r0_body.kd3 PRE_first_tail_x6_r0_body.khinv3 PRE_first_tail_x6_r0_body.kninv3 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx PRE_first_tail_x6_r0_body.cx0_3.mlx PRE_first_tail_x6_r0_body.cx1_3.mlx (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo3 PRE_first_tail_x6_r0_body.cln3 PRE_first_tail_x6_r0_body.cli3 PRE_first_tail_x6_r0_body.cwS3 PRE_first_tail_x6_r0_body.cnS3 PRE_first_tail_x6_r0_body.ciS3 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh03, PRE_first_tail_x6_r0_body.cnh13, PRE_first_tail_x6_r0_body.cnn03, PRE_first_tail_x6_r0_body.cnn13, PRE_first_tail_x6_r0_body.cplo3, PRE_first_tail_x6_r0_body.ccnt3, PRE_first_tail_x6_r0_body.cnband3, PRE_first_tail_x6_r0_body.chbelow3, PRE_first_tail_x6_r0_body.chren3, PRE_first_tail_x6_r0_body.cband3, PRE_first_tail_x6_r0_body.cnh1pos3, PRE_first_tail_x6_r0_body.cnren3, PRE_first_tail_x6_r0_body.cnlow3, PRE_first_tail_x6_r0_body.cabs0a3, PRE_first_tail_x6_r0_body.cabs0b3, PRE_first_tail_x6_r0_body.ctok13, PRE_first_tail_x6_r0_body.cpend3, PRE_first_tail_x6_r0_body.cerrh3, PRE_first_tail_x6_r0_body.cfiles3, PRE_first_tail_x6_r0_body.carch3, PRE_first_tail_x6_r0_body.csizes3, PRE_first_tail_x6_r0_body.cwired3, PRE_first_tail_x6_r0_body.cfix3, clean, PRE_first_tail_x6_r0_body.fcxn3, PRE_first_tail_x6_r0_body.fcnn3, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle03, PRE_first_tail_x6_r0_body.fnk3, PRE_first_tail_x6_r0_body.ckA3, PRE_first_tail_x6_r0_body.cobjsK3, PRE_first_tail_x6_r0_body.cnodesK3, PRE_first_tail_x6_r0_body.citemsK3, PRE_first_tail_x6_r0_body.f1A3, PRE_first_tail_x6_r0_body.f1O3, PRE_first_tail_x6_r0_body.f1N3, PRE_first_tail_x6_r0_body.f1I3, PRE_first_tail_x6_r0_body.fbd3, PRE_first_tail_x6_r0_body.fincW3, PRE_first_tail_x6_r0_body.fincI3, PRE_first_tail_x6_r0_body.fincN3, PRE_first_tail_x6_r0_body.flnF3, PRE_first_tail_x6_r0_body.fh3, PRE_first_tail_x6_r0_body.fo3, PRE_first_tail_x6_r0_body.fok3, PRE_first_tail_x6_r0_body.fnd3, PRE_first_tail_x6_r0_body.fp3, PRE_first_tail_x6_r0_body.fnord3, PRE_first_tail_x6_r0_body.fi3, PRE_first_tail_x6_r0_body.fii3⟩
theorem PRE_first_tail_x6_r0_body.cnshift3 (clean : Conv.NClean (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P3.NL) (cl : SSt (· < 230) PRE_first_tail_x6_r0_body.cx0_3.mlx) : NShift PRE_first_tail_x6_r0_body.P3 230 PRE_first_tail_x6_r0_body.kappa3 PRE_first_tail_x6_r0_body.cx0_3 PRE_first_tail_x6_r0_body.cx1_3 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot3 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost3 (compact_a_eq PRE_first_tail_x6_r0_body.ckn03 PRE_first_tail_x6_r0_body.ckn13 PRE_first_tail_x6_r0_body.ckheap3 PRE_first_tail_x6_r0_body.ckpl3)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_3 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s45.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_3 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s45.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_3 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s45.ffi) = some PRE_first_tail_x6_r0_body.fxC_3
kernel_rfl PRE_first_tail_x6_r0_body.okrC_3 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s45.ffi) = some PRE_first_tail_x6_r0_body.krC_3
noncomputable def PRE_first_tail_x6_r0_body.fx0_3 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s47.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_3 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s47.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_3 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s47.ffi) = some PRE_first_tail_x6_r0_body.fx0_3
kernel_rfl PRE_first_tail_x6_r0_body.okr0_3 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s47.ffi) = some PRE_first_tail_x6_r0_body.kr0_3
noncomputable def PRE_first_tail_x6_r0_body.fx1_3 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s46.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_3 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s46.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_3 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s46.ffi) = some PRE_first_tail_x6_r0_body.fx1_3
kernel_rfl PRE_first_tail_x6_r0_body.okr1_3 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s46.ffi) = some PRE_first_tail_x6_r0_body.kr1_3
kernel_rfl PRE_first_tail_x6_r0_body.ff03 : PRE_first_tail_x6_r0_body.fx0_3 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_3 (PRE_first_tail_x6_r0_body.clo3.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_3.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff13 : PRE_first_tail_x6_r0_body.fx1_3 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_3 (PRE_first_tail_x6_r0_body.cwS3.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_3.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck3 : freedLB PRE_first_tail_x6_r0_body.kappa3 PRE_first_tail_x6_r0_body.cx0_3.mlx PRE_first_tail_x6_r0_body.fx0_3 PRE_first_tail_x6_r0_body.fx1_3 PRE_first_tail_x6_r0_body.clo3 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf03 : PRE_first_tail_x6_r0_body.kr0_3.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_3.flags (PRE_first_tail_x6_r0_body.clo3.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_3.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt03 : PRE_first_tail_x6_r0_body.kr0_3.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_3.targs (PRE_first_tail_x6_r0_body.clo3.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_3.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf13 : PRE_first_tail_x6_r0_body.kr1_3.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_3.flags (PRE_first_tail_x6_r0_body.cwS3.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_3.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt13 : PRE_first_tail_x6_r0_body.kr1_3.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_3.targs (PRE_first_tail_x6_r0_body.cwS3.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_3.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck3 : krecLB PRE_first_tail_x6_r0_body.kappa3 230 PRE_first_tail_x6_r0_body.cx0_3.mlx PRE_first_tail_x6_r0_body.kr0_3 PRE_first_tail_x6_r0_body.kr1_3 PRE_first_tail_x6_r0_body.clo3 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn3 : Nat.ble 212 230 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge3 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s46.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s47.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR3 : pendRegB PRE_first_tail_x6_r0_body.kappa3 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe3 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s47.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s46.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift3 (clean : Conv.NClean (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P3.NL) (cl : SSt (· < 230) PRE_first_tail_x6_r0_body.cx0_3.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_3.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_3.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_3.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s45.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_3.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P3 230 PRE_first_tail_x6_r0_body.kappa3 PRE_first_tail_x6_r0_body.s47.ffi PRE_first_tail_x6_r0_body.s46.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift3 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue3, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp3 t ht),
    PRE_first_tail_x6_r0_body.cbridge3,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s47.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s46.ffi) (PRE_first_tail_x6_r0_body.cfoot3 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_3 PRE_first_tail_x6_r0_body.ofx1_3 hobjC PRE_first_tail_x6_r0_body.ff03 PRE_first_tail_x6_r0_body.ff13 PRE_first_tail_x6_r0_body.ffck3,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s47.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s46.ffi) (PRE_first_tail_x6_r0_body.cfoot3 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_3 PRE_first_tail_x6_r0_body.okr1_3 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn3) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf03 PRE_first_tail_x6_r0_body.fkt03 PRE_first_tail_x6_r0_body.fkf13 PRE_first_tail_x6_r0_body.fkt13 PRE_first_tail_x6_r0_body.fkck3,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh03 PRE_first_tail_x6_r0_body.cnh13 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe3) PRE_first_tail_x6_r0_body.cpendR3⟩

end Host.Load.Run.Tpl
end

section -- st3/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st3 0
host_stream_state PRE_first_tail_x6_r0_body.st3 1
host_stream_state PRE_first_tail_x6_r0_body.st3 2
host_stream_state PRE_first_tail_x6_r0_body.st3 3
host_stream_state PRE_first_tail_x6_r0_body.st3 4
host_stream_state PRE_first_tail_x6_r0_body.st3 5
end Host.Load.Run.Tpl
end

section -- Site3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 3 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g3__g4` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s45`, the merged state `PRE_first_tail_x6_r0_body.s46`,
the site template `PRE_first_tail_x6_r0_body.st3` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s47`: the merge.
The footprint's facts are in `SiteF3`, the compaction's in `SiteC3`, `SiteK3`, `SiteNa3`, `SiteNb3`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso3 : PRE_first_tail_x6_r0_body.st3.s0 = { PRE_first_tail_x6_r0_body.s45 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs3 : List Frame := PRE_first_tail_x6_r0_body.s45.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_3 : PRE_first_tail_x6_r0_body.S45.tab.length = 212
kernel_rfl PRE_first_tail_x6_r0_body.tab0_3 : PRE_first_tail_x6_r0_body.st3.S0.tab = PRE_first_tail_x6_r0_body.S45.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws3 : List Nat := [1060, 1061, 1062, 1063, 1064, 1065, 1066, 1067, 1068, 1069, 1070, 1071, 1072, 1073, 1074, 1075, 1076, 1077, 1078, 1079, 1080, 1081, 1082, 1083, 1084, 1085, 1086, 1087, 1088, 1089, 1090]
kernel_rfl PRE_first_tail_x6_r0_body.fresh3 : (PRE_first_tail_x6_r0_body.S45.tab.all fun e => PRE_first_tail_x6_r0_body.ws3.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S45.oracle.all fun q => PRE_first_tail_x6_r0_body.ws3.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab3 : PRE_first_tail_x6_r0_body.S46.tab = PRE_first_tail_x6_r0_body.S45.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws3
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen3 : PRE_first_tail_x6_r0_body.st3.S5.tab.length - PRE_first_tail_x6_r0_body.st3.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged3`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap3 : PRE_first_tail_x6_r0_body.s46.heap = PRE_first_tail_x6_r0_body.st3.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext3 : PRE_first_tail_x6_r0_body.s46.next = PRE_first_tail_x6_r0_body.st3.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl3 : PRE_first_tail_x6_r0_body.s46.ctl = PRE_first_tail_x6_r0_body.st3.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack3 : PRE_first_tail_x6_r0_body.s46.stack = PRE_first_tail_x6_r0_body.st3.s5.stack ++ PRE_first_tail_x6_r0_body.s45.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs3 : PRE_first_tail_x6_r0_body.s46.jobs = PRE_first_tail_x6_r0_body.st3.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi3 : PRE_first_tail_x6_r0_body.s46.ffi = PRE_first_tail_x6_r0_body.st3.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace3 : PRE_first_tail_x6_r0_body.s46.trace = PRE_first_tail_x6_r0_body.st3.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores3 : PRE_first_tail_x6_r0_body.s46.stores = PRE_first_tail_x6_r0_body.st3.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 3 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived3 : PRE_first_tail_x6_r0_body.nr3.map (fun r => nth? PRE_first_tail_x6_r0_body.st3.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo3 : PRE_first_tail_x6_r0_body.nr3.all (Nat.ble 212) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj3 : PRE_first_tail_x6_r0_body.cws3.all (fun c => !PRE_first_tail_x6_r0_body.ws3.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ3 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws3 PRE_first_tail_x6_r0_body.crs3 PRE_first_tail_x6_r0_body.ws3

end Host.Load.Run.Tpl
end

section -- st3/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st3`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st3.wrR : List (Nat × Nat) := [(2672305, 2672306), (2676797, 2676798), (2677342, 2677343), (2677598, 2677599)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st3.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st3.s5.heap PRE_first_tail_x6_r0_body.st3.wrR ++ freshOf PRE_first_tail_x6_r0_body.st3.s5.heap PRE_first_tail_x6_r0_body.st3.s0.next PRE_first_tail_x6_r0_body.st3.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st3.wr : List Nat := PRE_first_tail_x6_r0_body.st3.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st3.heapFoot : PRE_first_tail_x6_r0_body.st3.s5.heap = setAll PRE_first_tail_x6_r0_body.st3.s0.heap PRE_first_tail_x6_r0_body.st3.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st3.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st3.s0.next PRE_first_tail_x6_r0_body.st3.s5.next = true
theorem PRE_first_tail_x6_r0_body.st3.grows : PRE_first_tail_x6_r0_body.st3.s0.next ≤ PRE_first_tail_x6_r0_body.st3.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st3.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st3.wh : List Nat := [18250, 18263, 18269, 18270, 18271, 18272, 18273, 18274, 18275, 18276, 18277, 18278, 18279, 18280, 18281, 18282, 18283, 18284, 18285, 18286, 18287, 18288, 18289, 18290, 18291, 18292, 18293, 18294, 18295, 18296, 18297]
def PRE_first_tail_x6_r0_body.st3.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st3.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st3.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st3.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st3.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st3.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st3.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st3.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st3.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st3.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 3 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB3 : nodupT PRE_first_tail_x6_r0_body.st3.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup3 : PRE_first_tail_x6_r0_body.st3.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB3).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB3 : PRE_first_tail_x6_r0_body.st3.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound3 : ∀ b ∈ PRE_first_tail_x6_r0_body.st3.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB3 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr3 := PRE_first_tail_x6_r0_body.st3.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq3 : PRE_first_tail_x6_r0_body.st3.s5.trace = PRE_first_tail_x6_r0_body.trFr3 ++ PRE_first_tail_x6_r0_body.st3.s0.trace
theorem PRE_first_tail_x6_r0_body.trace3 : ∃ fr, PRE_first_tail_x6_r0_body.st3.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st3.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq3⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide3 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB3 : (PRE_first_tail_x6_r0_body.wide3.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st3.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix3 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide3, WFix Map.id (Present PRE_first_tail_x6_r0_body.st3.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB3 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 3 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s46`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO3 : PRE_first_tail_x6_r0_body.st3.S0.oracle = PRE_first_tail_x6_r0_body.st3.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B3 : PRE_first_tail_x6_r0_body.st3.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st3.s0.next || (PRE_first_tail_x6_r0_body.st3.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot3 : Conv.StageFoot PRE_first_tail_x6_r0_body.st3.wr PRE_first_tail_x6_r0_body.st3.s0 PRE_first_tail_x6_r0_body.st3.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st3.heapFoot PRE_first_tail_x6_r0_body.wrNodup3 PRE_first_tail_x6_r0_body.wrBound3 PRE_first_tail_x6_r0_body.wr0B3 PRE_first_tail_x6_r0_body.st3.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged3 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st3.F.S → PRE_first_tail_x6_r0_body.st3.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st3.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st3.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs3 PRE_first_tail_x6_r0_body.st3.wr PRE_first_tail_x6_r0_body.s45 PRE_first_tail_x6_r0_body.st3.s5 PRE_first_tail_x6_r0_body.st3.s0
      PRE_first_tail_x6_r0_body.st3.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st3.F FR W stk M ν K PRE_first_tail_x6_r0_body.s46 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso3 PRE_first_tail_x6_r0_body.stFoot3 PRE_first_tail_x6_r0_body.wrNodup3 PRE_first_tail_x6_r0_body.wrBound3 PRE_first_tail_x6_r0_body.trace3 PRE_first_tail_x6_r0_body.mheap3
    PRE_first_tail_x6_r0_body.mnext3 PRE_first_tail_x6_r0_body.mctl3 PRE_first_tail_x6_r0_body.mstack3 PRE_first_tail_x6_r0_body.mjobs3 PRE_first_tail_x6_r0_body.mffi3 PRE_first_tail_x6_r0_body.mtrace3 PRE_first_tail_x6_r0_body.mstores3 h

def PRE_first_tail_x6_r0_body.arrEl3_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE3_2665 : arrOf PRE_first_tail_x6_r0_body.s46 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl3_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA3_2665 : isArrB PRE_first_tail_x6_r0_body.s46 2665 = true
theorem PRE_first_tail_x6_r0_body.arr3_2665 : ∃ o, PRE_first_tail_x6_r0_body.s46.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl3_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE3_2665 PRE_first_tail_x6_r0_body.arrA3_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN3_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl3_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR3_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl3_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN3_2665

def PRE_first_tail_x6_r0_body.arrEl3_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE3_2673467 : arrOf PRE_first_tail_x6_r0_body.s46 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl3_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA3_2673467 : isArrB PRE_first_tail_x6_r0_body.s46 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr3_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s46.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl3_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE3_2673467 PRE_first_tail_x6_r0_body.arrA3_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN3_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl3_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR3_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl3_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN3_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k3 : isArrB PRE_first_tail_x6_r0_body.s46 4910 = false
theorem PRE_first_tail_x6_r0_body.keep3 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s46 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k3 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr3_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl3_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 3 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s45`, the merged
state `PRE_first_tail_x6_r0_body.s46`, the canonical state `PRE_first_tail_x6_r0_body.s47`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl3 : PRE_first_tail_x6_r0_body.pl3.all (Nat.ble PRE_first_tail_x6_r0_body.s45.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd3 : nodupT PRE_first_tail_x6_r0_body.pl3 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn13 : Nat.ble PRE_first_tail_x6_r0_body.s45.next 2678778 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst3 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s45.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn3 : PRE_first_tail_x6_r0_body.s47.next = PRE_first_tail_x6_r0_body.s45.next + PRE_first_tail_x6_r0_body.pl3.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn3 : PRE_first_tail_x6_r0_body.s46.next = 2678778
kernel_rfl PRE_first_tail_x6_r0_body.zgrow3 : Nat.ble PRE_first_tail_x6_r0_body.s47.next PRE_first_tail_x6_r0_body.s46.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh3 : PRE_first_tail_x6_r0_body.S45.tab.all (fun e => PRE_first_tail_x6_r0_body.cws3.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd3 : nodupT PRE_first_tail_x6_r0_body.cws3 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi3 : PRE_first_tail_x6_r0_body.nr3.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S46.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt3 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s45.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg3_2665 : PRE_first_tail_x6_r0_body.s47.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s47 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk3_2665 : (objOf PRE_first_tail_x6_r0_body.s47 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm3_2665 : PRE_first_tail_x6_r0_body.s46.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa3.obj (objOf PRE_first_tail_x6_r0_body.s47 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s46 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg3_2673467 : PRE_first_tail_x6_r0_body.s47.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s47 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk3_2673467 : (objOf PRE_first_tail_x6_r0_body.s47 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm3_2673467 : PRE_first_tail_x6_r0_body.s46.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa3.obj (objOf PRE_first_tail_x6_r0_body.s47 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s46 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw3_4910 : (PRE_first_tail_x6_r0_body.s47.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw3_2673472 : (PRE_first_tail_x6_r0_body.s47.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw3_2673473 : (PRE_first_tail_x6_r0_body.s47.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd3 : PRE_first_tail_x6_r0_body.cl3.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr3 : PRE_first_tail_x6_r0_body.st3.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s45.next || PRE_first_tail_x6_r0_body.cl3.contains b) = true
def PRE_first_tail_x6_r0_body.zl3 : List Nat := PRE_first_tail_x6_r0_body.cl3.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE3 : PRE_first_tail_x6_r0_body.zl3.map (fun a => PRE_first_tail_x6_r0_body.s46.heap.get (PRE_first_tail_x6_r0_body.kappa3.a a)) = PRE_first_tail_x6_r0_body.zl3.map (fun a => (PRE_first_tail_x6_r0_body.s47.heap.get a).map PRE_first_tail_x6_r0_body.kappa3.hobj)
theorem PRE_first_tail_x6_r0_body.zimg3 : HeapImg PRE_first_tail_x6_r0_body.kappa3 PRE_first_tail_x6_r0_body.s47 PRE_first_tail_x6_r0_body.s46 PRE_first_tail_x6_r0_body.zl3 := PRE_first_tail_x6_r0_body.zimgE3
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl3 : PRE_first_tail_x6_r0_body.s46.ctl = PRE_first_tail_x6_r0_body.kappa3.ctl PRE_first_tail_x6_r0_body.s47.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack3 : PRE_first_tail_x6_r0_body.s46.stack = PRE_first_tail_x6_r0_body.s47.stack.map PRE_first_tail_x6_r0_body.kappa3.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs3 : PRE_first_tail_x6_r0_body.s46.jobs = PRE_first_tail_x6_r0_body.s47.jobs.map PRE_first_tail_x6_r0_body.kappa3.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores3 : PRE_first_tail_x6_r0_body.s46.stores = PRE_first_tail_x6_r0_body.kappa3.stores PRE_first_tail_x6_r0_body.s47.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots3 : checkRootsSupp PRE_first_tail_x6_r0_body.s47 230 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC3 : PRE_first_tail_x6_r0_body.S45.tab.length + PRE_first_tail_x6_r0_body.cws3.length = 230
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap3 : PRE_first_tail_x6_r0_body.kappa3 = Conv.Map.compact PRE_first_tail_x6_r0_body.s45.next 2678778 PRE_first_tail_x6_r0_body.S45.tab.length PRE_first_tail_x6_r0_body.pl3 (PRE_first_tail_x6_r0_body.nr3.map NumV.ref) PRE_first_tail_x6_r0_body.kd3.big
  PRE_first_tail_x6_r0_body.kd3.region PRE_first_tail_x6_r0_body.kd3.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin3 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s47.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc3 : Conv.jcleanListB (⟨18273, 15368, 2677629, 230⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s47 PRE_first_tail_x6_r0_body.cl3 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB3 : noBigRootsP (fun i => !Conv.oldBigB (⟨18273, 15368, 2677629, 230⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s47.trace PRE_first_tail_x6_r0_body.s47 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm3 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15341 = true
theorem PRE_first_tail_x6_r0_body.cjcl3 (h : Conv.JClean (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s45) : Conv.JClean (⟨18273, 15368, 2677629, 230⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s47 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle3)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap3 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd3 a ha)) PRE_first_tail_x6_r0_body.zjc3

end Host.Load.Run.Tpl
end

section -- st3/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st3.bodyLast from PRE_first_tail_x6_r0_body.st3.s4 to PRE_first_tail_x6_r0_body.st3.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st3.F PRE_first_tail_x6_r0_body.st3.s4).run PRE_first_tail_x6_r0_body.st3.S4 = some (PRE_first_tail_x6_r0_body.st3.s5, PRE_first_tail_x6_r0_body.st3.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st3.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st3.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st3.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st3.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st3/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st3.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st3.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st3.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st3.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st3.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st3.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st3.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st3.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st3.s0 PRE_first_tail_x6_r0_body.st3.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st3.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st3.s4 PRE_first_tail_x6_r0_body.st3.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st3/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st3.bodyK0F from PRE_first_tail_x6_r0_body.st3.s0 to PRE_first_tail_x6_r0_body.st3.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st3.F (PRE_first_tail_x6_r0_body.st3.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st3.ks 0).getD 0) PRE_first_tail_x6_r0_body.st3.s0 PRE_first_tail_x6_r0_body.st3.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st3.s1, PRE_first_tail_x6_r0_body.st3.S1)
theorem PRE_first_tail_x6_r0_body.st3.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st3.F (PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st3.ks 0).getD 0) PRE_first_tail_x6_r0_body.st3.s0 PRE_first_tail_x6_r0_body.st3.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st3.s1, PRE_first_tail_x6_r0_body.st3.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st3.bodyOkLN_ok PRE_first_tail_x6_r0_body.st3.bodyK0F
end Host.Load.Run.Tpl
end

section -- st3/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st3.bodyK1F from PRE_first_tail_x6_r0_body.st3.s1 to PRE_first_tail_x6_r0_body.st3.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st3.F (PRE_first_tail_x6_r0_body.st3.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st3.ks 1).getD 0) PRE_first_tail_x6_r0_body.st3.s1 PRE_first_tail_x6_r0_body.st3.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st3.s2, PRE_first_tail_x6_r0_body.st3.S2)
theorem PRE_first_tail_x6_r0_body.st3.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st3.F (PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st3.ks 1).getD 0) PRE_first_tail_x6_r0_body.st3.s1 PRE_first_tail_x6_r0_body.st3.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st3.s2, PRE_first_tail_x6_r0_body.st3.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st3.bodyOkLN_ok PRE_first_tail_x6_r0_body.st3.bodyK1F
end Host.Load.Run.Tpl
end

section -- st3/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st3.bodyK2F from PRE_first_tail_x6_r0_body.st3.s2 to PRE_first_tail_x6_r0_body.st3.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st3.F (PRE_first_tail_x6_r0_body.st3.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st3.ks 2).getD 0) PRE_first_tail_x6_r0_body.st3.s2 PRE_first_tail_x6_r0_body.st3.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st3.s3, PRE_first_tail_x6_r0_body.st3.S3)
theorem PRE_first_tail_x6_r0_body.st3.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st3.F (PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st3.ks 2).getD 0) PRE_first_tail_x6_r0_body.st3.s2 PRE_first_tail_x6_r0_body.st3.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st3.s3, PRE_first_tail_x6_r0_body.st3.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st3.bodyOkLN_ok PRE_first_tail_x6_r0_body.st3.bodyK2F
end Host.Load.Run.Tpl
end

section -- st3/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st3.bodyK3F from PRE_first_tail_x6_r0_body.st3.s3 to PRE_first_tail_x6_r0_body.st3.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st3.F (PRE_first_tail_x6_r0_body.st3.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st3.ks 3).getD 0) PRE_first_tail_x6_r0_body.st3.s3 PRE_first_tail_x6_r0_body.st3.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st3.s4, PRE_first_tail_x6_r0_body.st3.S4)
theorem PRE_first_tail_x6_r0_body.st3.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st3.F (PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st3.ks 3).getD 0) PRE_first_tail_x6_r0_body.st3.s3 PRE_first_tail_x6_r0_body.st3.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st3.s4, PRE_first_tail_x6_r0_body.st3.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st3.bodyOkLN_ok PRE_first_tail_x6_r0_body.st3.bodyK3F
end Host.Load.Run.Tpl
end

section -- st3/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st3.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st3.F (PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st3.s0 PRE_first_tail_x6_r0_body.st3.S0 = some (PRE_first_tail_x6_r0_body.st3.s4, PRE_first_tail_x6_r0_body.st3.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st3.F (PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st3.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st3.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st3.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st3.ks 3).getD 0) PRE_first_tail_x6_r0_body.st3.s0 PRE_first_tail_x6_r0_body.st3.s3 PRE_first_tail_x6_r0_body.st3.s4 PRE_first_tail_x6_r0_body.st3.S0 PRE_first_tail_x6_r0_body.st3.S3 PRE_first_tail_x6_r0_body.st3.S4 (runOk_trans PRE_first_tail_x6_r0_body.st3.F (PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st3.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st3.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st3.ks 2).getD 0) PRE_first_tail_x6_r0_body.st3.s0 PRE_first_tail_x6_r0_body.st3.s2 PRE_first_tail_x6_r0_body.st3.s3 PRE_first_tail_x6_r0_body.st3.S0 PRE_first_tail_x6_r0_body.st3.S2 PRE_first_tail_x6_r0_body.st3.S3 (runOk_trans PRE_first_tail_x6_r0_body.st3.F (PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st3.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st3.ks 1).getD 0) PRE_first_tail_x6_r0_body.st3.s0 PRE_first_tail_x6_r0_body.st3.s1 PRE_first_tail_x6_r0_body.st3.s2 PRE_first_tail_x6_r0_body.st3.S0 PRE_first_tail_x6_r0_body.st3.S1 PRE_first_tail_x6_r0_body.st3.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st3.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st3.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st3.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st3.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st3.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st3.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st3.F (PRE_first_tail_x6_r0_body.st3.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st3.s0
  S0 := PRE_first_tail_x6_r0_body.st3.S0
  s1 := PRE_first_tail_x6_r0_body.st3.s4
  S1 := PRE_first_tail_x6_r0_body.st3.S4
  s2 := PRE_first_tail_x6_r0_body.st3.s5
  S2 := PRE_first_tail_x6_r0_body.st3.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st3.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st3.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st3.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st3.bodyHalt
  last := PRE_first_tail_x6_r0_body.st3.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st3.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC4
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 4 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s55` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa4` into the merged state
`PRE_first_tail_x6_r0_body.s54`. -/

def PRE_first_tail_x6_r0_body.pl4 : List Nat := []
def PRE_first_tail_x6_r0_body.nr4 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd4 : RData :=
  ⟨2678119, 2678121, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18286, 18286, 15381, 15381, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa4 : Map :=
  Conv.Map.compact 2678119 2678121 251 PRE_first_tail_x6_r0_body.pl4 (PRE_first_tail_x6_r0_body.nr4.map NumV.ref) PRE_first_tail_x6_r0_body.kd4.big
    PRE_first_tail_x6_r0_body.kd4.region PRE_first_tail_x6_r0_body.kd4.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws4 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs4 : List SymE := PRE_first_tail_x6_r0_body.nr4.map fun r => (nth? PRE_first_tail_x6_r0_body.S54.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta4 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws4 PRE_first_tail_x6_r0_body.crs4
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB4 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab4 : PRE_first_tail_x6_r0_body.S55.tab = PRE_first_tail_x6_r0_body.S53.tab ++ PRE_first_tail_x6_r0_body.cws4.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace4 : PRE_first_tail_x6_r0_body.s55.trace = PRE_first_tail_x6_r0_body.s53.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext4 : PRE_first_tail_x6_r0_body.s55.next = 2678119
kernel_rfl PRE_first_tail_x6_r0_body.ccounters4 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx.nnext) = (18286, 15381)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue4 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s54.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa4.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp4 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx.tokens.all (bSN 251) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean4 : Conv.cleanListB 18286 131072 (fun r => Nat.ble 73144 r) PRE_first_tail_x6_r0_body.s55
    (PRE_first_tail_x6_r0_body.wrB4 ++ (List.range 0).map (2678119 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs4 : bigsOutB 18286 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK4
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl4`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl4 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo4 : List Nat := []
def PRE_first_tail_x6_r0_body.cln4 : List Nat := []
def PRE_first_tail_x6_r0_body.cli4 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap4 : PRE_first_tail_x6_r0_body.s55.heap = Stage.setAll PRE_first_tail_x6_r0_body.s53.heap (PRE_first_tail_x6_r0_body.cl4.filterMap fun a => (PRE_first_tail_x6_r0_body.s55.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe4 : Nat.ble PRE_first_tail_x6_r0_body.s53.next PRE_first_tail_x6_r0_body.s55.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP4 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s53 PRE_first_tail_x6_r0_body.s55 PRE_first_tail_x6_r0_body.cl4 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp4 : Conv.suppListB PRE_first_tail_x6_r0_body.s55 251 PRE_first_tail_x6_r0_body.cl4 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound4 : Conv.boundListB PRE_first_tail_x6_r0_body.s55 PRE_first_tail_x6_r0_body.cl4 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK4 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln4.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK4 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo4.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK4 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli4.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst4 : Conv.sstListB 251 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx PRE_first_tail_x6_r0_body.cln4 PRE_first_tail_x6_r0_body.clo4 PRE_first_tail_x6_r0_body.cli4 = true

end Host.Load.Run.Tpl
end

section -- SiteCl4
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA4 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo4.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd4 : (PRE_first_tail_x6_r0_body.clo4 ++ PRE_first_tail_x6_r0_body.cln4 ++ PRE_first_tail_x6_r0_body.cli4).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle4 : Conv.Cnt.leB (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck4 : Conv.ncleanListB (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx PRE_first_tail_x6_r0_body.clo4 PRE_first_tail_x6_r0_body.cln4 PRE_first_tail_x6_r0_body.cli4 = true
theorem PRE_first_tail_x6_r0_body.cncl4 (h : Conv.NClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx) : Conv.NClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle4 PRE_first_tail_x6_r0_body.ckA4 PRE_first_tail_x6_r0_body.cobjsK4 PRE_first_tail_x6_r0_body.cnodesK4 PRE_first_tail_x6_r0_body.citemsK4 PRE_first_tail_x6_r0_body.cbd4 PRE_first_tail_x6_r0_body.cck4

end Host.Load.Run.Tpl
end

section -- SiteS4
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 4 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc4 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P4 : LoadP := PRE_first_tail_x6_r0_body.Pc4.raise 15381
kernel_rfl PRE_first_tail_x6_r0_body.craise4 : Nat.ble PRE_first_tail_x6_r0_body.Pc4.N0 15381 = true
theorem PRE_first_tail_x6_r0_body.raised4 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc4 PRE_first_tail_x6_r0_body.P4 :=
  .inr ⟨15381, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise4, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_4 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_4 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s54.ffi)
def PRE_first_tail_x6_r0_body.khinv4 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv4 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS4 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS4 : List Nat := List.range' 15381 0
def PRE_first_tail_x6_r0_body.ciS4 : List Nat := [] ++ List.range' 15381 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh04 : PRE_first_tail_x6_r0_body.kd4.nh0 = PRE_first_tail_x6_r0_body.cx0_4.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh14 : PRE_first_tail_x6_r0_body.kd4.nh1 = PRE_first_tail_x6_r0_body.cx1_4.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn04 : PRE_first_tail_x6_r0_body.kd4.nn0 = PRE_first_tail_x6_r0_body.cx0_4.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn14 : PRE_first_tail_x6_r0_body.kd4.nn1 = PRE_first_tail_x6_r0_body.cx1_4.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo4 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P4.lo && Nat.ble PRE_first_tail_x6_r0_body.P4.lo PRE_first_tail_x6_r0_body.cx0_4.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P4.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P4.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt4 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_4.mlx.next PRE_first_tail_x6_r0_body.cx1_4.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_4.mlx.nnext PRE_first_tail_x6_r0_body.cx1_4.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband4 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P4.NL && Nat.ble PRE_first_tail_x6_r0_body.P4.NL PRE_first_tail_x6_r0_body.P4.N0 && Nat.ble PRE_first_tail_x6_r0_body.P4.N0 PRE_first_tail_x6_r0_body.cx0_4.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow4 : PRE_first_tail_x6_r0_body.kd4.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren4 : checkRenG PRE_first_tail_x6_r0_body.kd4.hnd PRE_first_tail_x6_r0_body.khinv4 (phB PRE_first_tail_x6_r0_body.cx0_4.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband4 : PRE_first_tail_x6_r0_body.kd4.checkBand PRE_first_tail_x6_r0_body.P4.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos4 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd4.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren4 : checkRenG PRE_first_tail_x6_r0_body.kd4.node PRE_first_tail_x6_r0_body.kninv4 (pnB PRE_first_tail_x6_r0_body.cx0_4.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow4 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd4.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P4.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd4.nodeF j) PRE_first_tail_x6_r0_body.cx1_4.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a4 : PRE_first_tail_x6_r0_body.cx0_4.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b4 : PRE_first_tail_x6_r0_body.cx0_4.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok14 : PRE_first_tail_x6_r0_body.cx1_4.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend4 : PRE_first_tail_x6_r0_body.cx1_4.mlx.pending = PRE_first_tail_x6_r0_body.cx0_4.mlx.pending.map PRE_first_tail_x6_r0_body.kappa4.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh4 : PRE_first_tail_x6_r0_body.cx1_4.mlx.errh = PRE_first_tail_x6_r0_body.cx0_4.mlx.errh.map PRE_first_tail_x6_r0_body.kappa4.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles4 : PRE_first_tail_x6_r0_body.cx1_4.mlx.files = PRE_first_tail_x6_r0_body.cx0_4.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch4 : PRE_first_tail_x6_r0_body.cx1_4.mlx.arch = PRE_first_tail_x6_r0_body.cx0_4.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes4 : PRE_first_tail_x6_r0_body.cx1_4.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_4.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired4 : PRE_first_tail_x6_r0_body.cx1_4.mlx.wired = PRE_first_tail_x6_r0_body.cx0_4.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost4 : PRE_first_tail_x6_r0_body.cx1_4.host = PRE_first_tail_x6_r0_body.cx0_4.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd4`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn04 : PRE_first_tail_x6_r0_body.kd4.n0 = 2678119
kernel_rfl PRE_first_tail_x6_r0_body.ckn14 : PRE_first_tail_x6_r0_body.kd4.n1 = 2678121
kernel_rfl PRE_first_tail_x6_r0_body.ckheap4 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd4.heap).all (fun x => Nat.ble 2678119 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl4 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd4.heap.get (2678119 + j) = nth? PRE_first_tail_x6_r0_body.pl4 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja4 : Nat.ble 2678119 2678119 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn4 : Nat.ble 251 251 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD4 : Nat.ble 2678119 PRE_first_tail_x6_r0_body.kd4.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn4 : Nat.ble 18286 PRE_first_tail_x6_r0_body.kd4.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn4 : Nat.ble 15381 PRE_first_tail_x6_r0_body.kd4.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb4 : Nat.ble 18286 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap4 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd4.heap).all (Nat.ble (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd4 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd4.hnd).all (Nat.ble (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode4 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd4.node).all (Nat.ble (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix4 : Conv.FixOld (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa4 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja4) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn4) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD4) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn4) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn4) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb4) PRE_first_tail_x6_r0_body.fheap4 PRE_first_tail_x6_r0_body.fhnd4 PRE_first_tail_x6_r0_body.fnode4
kernel_rfl PRE_first_tail_x6_r0_body.fcxn4 : (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn4 : (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle04 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_4.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_4.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk4 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd4.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A4 : PRE_first_tail_x6_r0_body.cx1_4.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS4.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_4.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O4 : PRE_first_tail_x6_r0_body.cx1_4.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS4.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_4.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N4 : PRE_first_tail_x6_r0_body.cx1_4.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS4.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_4.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I4 : PRE_first_tail_x6_r0_body.cx1_4.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS4.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_4.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd4 : (PRE_first_tail_x6_r0_body.clo4 ++ PRE_first_tail_x6_r0_body.cln4 ++ PRE_first_tail_x6_r0_body.cli4 ++ PRE_first_tail_x6_r0_body.cwS4 ++ PRE_first_tail_x6_r0_body.cnS4 ++ PRE_first_tail_x6_r0_body.ciS4).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW4 : PRE_first_tail_x6_r0_body.cwS4.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo4.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI4 : PRE_first_tail_x6_r0_body.ciS4.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli4.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN4 : PRE_first_tail_x6_r0_body.cnS4.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF4 : PRE_first_tail_x6_r0_body.cln4.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh4 : PRE_first_tail_x6_r0_body.clo4.all (handleOK PRE_first_tail_x6_r0_body.kappa4 PRE_first_tail_x6_r0_body.P4.lo PRE_first_tail_x6_r0_body.cx0_4.mlx PRE_first_tail_x6_r0_body.cx1_4.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo4 : PRE_first_tail_x6_r0_body.clo4.map (fun h => PRE_first_tail_x6_r0_body.cx1_4.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa4.handle h)) = PRE_first_tail_x6_r0_body.clo4.map (fun h => (PRE_first_tail_x6_r0_body.cx0_4.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa4.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok4 : PRE_first_tail_x6_r0_body.clo4.all (objOK PRE_first_tail_x6_r0_body.kappa4 PRE_first_tail_x6_r0_body.P4.NL PRE_first_tail_x6_r0_body.cx0_4.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd4 : PRE_first_tail_x6_r0_body.cln4.all (nodeOKF PRE_first_tail_x6_r0_body.kappa4 PRE_first_tail_x6_r0_body.P4 PRE_first_tail_x6_r0_body.cx0_4.mlx PRE_first_tail_x6_r0_body.cx1_4.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp4 : ((PRE_first_tail_x6_r0_body.cln4.filter (fullB PRE_first_tail_x6_r0_body.P4))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_4.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa4.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln4.filter (fullB PRE_first_tail_x6_r0_body.P4))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_4.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa4.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI4 : incrB PRE_first_tail_x6_r0_body.kd4.nodeF (List.range' 15381 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK4 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd4.node).all (fun k => Nat.ble 15381 k && Nat.blt k 15381) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL4 : (PRE_first_tail_x6_r0_body.cln4.filter (Nat.ble PRE_first_tail_x6_r0_body.P4.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd4.nodeF i) && (Nat.blt i 15381 || Nat.ble PRE_first_tail_x6_r0_body.kd4.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord4 : (PRE_first_tail_x6_r0_body.cln4.filter (Nat.ble PRE_first_tail_x6_r0_body.P4.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd4.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd4.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd4.nodeF j) (PRE_first_tail_x6_r0_body.kd4.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow4 PRE_first_tail_x6_r0_body.cnn14 PRE_first_tail_x6_r0_body.fnordI4 PRE_first_tail_x6_r0_body.fnordK4 PRE_first_tail_x6_r0_body.fnordL4
kernel_rfl PRE_first_tail_x6_r0_body.fi4 : PRE_first_tail_x6_r0_body.cli4.all (pnB PRE_first_tail_x6_r0_body.cx0_4.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii4 : PRE_first_tail_x6_r0_body.cli4.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_4.mlx.items.get (PRE_first_tail_x6_r0_body.kappa4.node k) = (PRE_first_tail_x6_r0_body.cx0_4.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa4.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot4 (clean : Conv.NClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P4.NL) (cl : SSt (· < 251) PRE_first_tail_x6_r0_body.cx0_4.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P4 251 PRE_first_tail_x6_r0_body.kappa4 PRE_first_tail_x6_r0_body.kd4 PRE_first_tail_x6_r0_body.khinv4 PRE_first_tail_x6_r0_body.kninv4 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx PRE_first_tail_x6_r0_body.cx0_4.mlx PRE_first_tail_x6_r0_body.cx1_4.mlx (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo4 PRE_first_tail_x6_r0_body.cln4 PRE_first_tail_x6_r0_body.cli4 PRE_first_tail_x6_r0_body.cwS4 PRE_first_tail_x6_r0_body.cnS4 PRE_first_tail_x6_r0_body.ciS4 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh04, PRE_first_tail_x6_r0_body.cnh14, PRE_first_tail_x6_r0_body.cnn04, PRE_first_tail_x6_r0_body.cnn14, PRE_first_tail_x6_r0_body.cplo4, PRE_first_tail_x6_r0_body.ccnt4, PRE_first_tail_x6_r0_body.cnband4, PRE_first_tail_x6_r0_body.chbelow4, PRE_first_tail_x6_r0_body.chren4, PRE_first_tail_x6_r0_body.cband4, PRE_first_tail_x6_r0_body.cnh1pos4, PRE_first_tail_x6_r0_body.cnren4, PRE_first_tail_x6_r0_body.cnlow4, PRE_first_tail_x6_r0_body.cabs0a4, PRE_first_tail_x6_r0_body.cabs0b4, PRE_first_tail_x6_r0_body.ctok14, PRE_first_tail_x6_r0_body.cpend4, PRE_first_tail_x6_r0_body.cerrh4, PRE_first_tail_x6_r0_body.cfiles4, PRE_first_tail_x6_r0_body.carch4, PRE_first_tail_x6_r0_body.csizes4, PRE_first_tail_x6_r0_body.cwired4, PRE_first_tail_x6_r0_body.cfix4, clean, PRE_first_tail_x6_r0_body.fcxn4, PRE_first_tail_x6_r0_body.fcnn4, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle04, PRE_first_tail_x6_r0_body.fnk4, PRE_first_tail_x6_r0_body.ckA4, PRE_first_tail_x6_r0_body.cobjsK4, PRE_first_tail_x6_r0_body.cnodesK4, PRE_first_tail_x6_r0_body.citemsK4, PRE_first_tail_x6_r0_body.f1A4, PRE_first_tail_x6_r0_body.f1O4, PRE_first_tail_x6_r0_body.f1N4, PRE_first_tail_x6_r0_body.f1I4, PRE_first_tail_x6_r0_body.fbd4, PRE_first_tail_x6_r0_body.fincW4, PRE_first_tail_x6_r0_body.fincI4, PRE_first_tail_x6_r0_body.fincN4, PRE_first_tail_x6_r0_body.flnF4, PRE_first_tail_x6_r0_body.fh4, PRE_first_tail_x6_r0_body.fo4, PRE_first_tail_x6_r0_body.fok4, PRE_first_tail_x6_r0_body.fnd4, PRE_first_tail_x6_r0_body.fp4, PRE_first_tail_x6_r0_body.fnord4, PRE_first_tail_x6_r0_body.fi4, PRE_first_tail_x6_r0_body.fii4⟩
theorem PRE_first_tail_x6_r0_body.cnshift4 (clean : Conv.NClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P4.NL) (cl : SSt (· < 251) PRE_first_tail_x6_r0_body.cx0_4.mlx) : NShift PRE_first_tail_x6_r0_body.P4 251 PRE_first_tail_x6_r0_body.kappa4 PRE_first_tail_x6_r0_body.cx0_4 PRE_first_tail_x6_r0_body.cx1_4 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot4 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost4 (compact_a_eq PRE_first_tail_x6_r0_body.ckn04 PRE_first_tail_x6_r0_body.ckn14 PRE_first_tail_x6_r0_body.ckheap4 PRE_first_tail_x6_r0_body.ckpl4)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_4 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s53.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_4 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s53.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_4 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s53.ffi) = some PRE_first_tail_x6_r0_body.fxC_4
kernel_rfl PRE_first_tail_x6_r0_body.okrC_4 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s53.ffi) = some PRE_first_tail_x6_r0_body.krC_4
noncomputable def PRE_first_tail_x6_r0_body.fx0_4 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s55.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_4 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s55.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_4 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s55.ffi) = some PRE_first_tail_x6_r0_body.fx0_4
kernel_rfl PRE_first_tail_x6_r0_body.okr0_4 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s55.ffi) = some PRE_first_tail_x6_r0_body.kr0_4
noncomputable def PRE_first_tail_x6_r0_body.fx1_4 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s54.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_4 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s54.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_4 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s54.ffi) = some PRE_first_tail_x6_r0_body.fx1_4
kernel_rfl PRE_first_tail_x6_r0_body.okr1_4 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s54.ffi) = some PRE_first_tail_x6_r0_body.kr1_4
kernel_rfl PRE_first_tail_x6_r0_body.ff04 : PRE_first_tail_x6_r0_body.fx0_4 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_4 (PRE_first_tail_x6_r0_body.clo4.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_4.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff14 : PRE_first_tail_x6_r0_body.fx1_4 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_4 (PRE_first_tail_x6_r0_body.cwS4.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_4.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck4 : freedLB PRE_first_tail_x6_r0_body.kappa4 PRE_first_tail_x6_r0_body.cx0_4.mlx PRE_first_tail_x6_r0_body.fx0_4 PRE_first_tail_x6_r0_body.fx1_4 PRE_first_tail_x6_r0_body.clo4 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf04 : PRE_first_tail_x6_r0_body.kr0_4.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_4.flags (PRE_first_tail_x6_r0_body.clo4.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_4.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt04 : PRE_first_tail_x6_r0_body.kr0_4.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_4.targs (PRE_first_tail_x6_r0_body.clo4.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_4.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf14 : PRE_first_tail_x6_r0_body.kr1_4.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_4.flags (PRE_first_tail_x6_r0_body.cwS4.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_4.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt14 : PRE_first_tail_x6_r0_body.kr1_4.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_4.targs (PRE_first_tail_x6_r0_body.cwS4.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_4.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck4 : krecLB PRE_first_tail_x6_r0_body.kappa4 251 PRE_first_tail_x6_r0_body.cx0_4.mlx PRE_first_tail_x6_r0_body.kr0_4 PRE_first_tail_x6_r0_body.kr1_4 PRE_first_tail_x6_r0_body.clo4 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn4 : Nat.ble 251 251 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge4 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s54.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s55.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR4 : pendRegB PRE_first_tail_x6_r0_body.kappa4 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe4 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s55.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s54.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift4 (clean : Conv.NClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P4.NL) (cl : SSt (· < 251) PRE_first_tail_x6_r0_body.cx0_4.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_4.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_4.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_4.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s53.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_4.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P4 251 PRE_first_tail_x6_r0_body.kappa4 PRE_first_tail_x6_r0_body.s55.ffi PRE_first_tail_x6_r0_body.s54.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift4 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue4, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp4 t ht),
    PRE_first_tail_x6_r0_body.cbridge4,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s55.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s54.ffi) (PRE_first_tail_x6_r0_body.cfoot4 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_4 PRE_first_tail_x6_r0_body.ofx1_4 hobjC PRE_first_tail_x6_r0_body.ff04 PRE_first_tail_x6_r0_body.ff14 PRE_first_tail_x6_r0_body.ffck4,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s55.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s54.ffi) (PRE_first_tail_x6_r0_body.cfoot4 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_4 PRE_first_tail_x6_r0_body.okr1_4 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn4) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf04 PRE_first_tail_x6_r0_body.fkt04 PRE_first_tail_x6_r0_body.fkf14 PRE_first_tail_x6_r0_body.fkt14 PRE_first_tail_x6_r0_body.fkck4,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh04 PRE_first_tail_x6_r0_body.cnh14 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe4) PRE_first_tail_x6_r0_body.cpendR4⟩

end Host.Load.Run.Tpl
end

section -- st4/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st4 0
host_stream_state PRE_first_tail_x6_r0_body.st4 1
host_stream_state PRE_first_tail_x6_r0_body.st4 2
end Host.Load.Run.Tpl
end

section -- Site4
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 4 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g4__g5` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s53`, the merged state `PRE_first_tail_x6_r0_body.s54`,
the site template `PRE_first_tail_x6_r0_body.st4` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s55`: the merge.
The footprint's facts are in `SiteF4`, the compaction's in `SiteC4`, `SiteK4`, `SiteNa4`, `SiteNb4`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso4 : PRE_first_tail_x6_r0_body.st4.s0 = { PRE_first_tail_x6_r0_body.s53 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs4 : List Frame := PRE_first_tail_x6_r0_body.s53.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_4 : PRE_first_tail_x6_r0_body.S53.tab.length = 251
kernel_rfl PRE_first_tail_x6_r0_body.tab0_4 : PRE_first_tail_x6_r0_body.st4.S0.tab = PRE_first_tail_x6_r0_body.S53.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws4 : List Nat := [1109, 1110]
kernel_rfl PRE_first_tail_x6_r0_body.fresh4 : (PRE_first_tail_x6_r0_body.S53.tab.all fun e => PRE_first_tail_x6_r0_body.ws4.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S53.oracle.all fun q => PRE_first_tail_x6_r0_body.ws4.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab4 : PRE_first_tail_x6_r0_body.S54.tab = PRE_first_tail_x6_r0_body.S53.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws4
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen4 : PRE_first_tail_x6_r0_body.st4.S2.tab.length - PRE_first_tail_x6_r0_body.st4.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged4`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap4 : PRE_first_tail_x6_r0_body.s54.heap = PRE_first_tail_x6_r0_body.st4.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext4 : PRE_first_tail_x6_r0_body.s54.next = PRE_first_tail_x6_r0_body.st4.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl4 : PRE_first_tail_x6_r0_body.s54.ctl = PRE_first_tail_x6_r0_body.st4.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack4 : PRE_first_tail_x6_r0_body.s54.stack = PRE_first_tail_x6_r0_body.st4.s2.stack ++ PRE_first_tail_x6_r0_body.s53.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs4 : PRE_first_tail_x6_r0_body.s54.jobs = PRE_first_tail_x6_r0_body.st4.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi4 : PRE_first_tail_x6_r0_body.s54.ffi = PRE_first_tail_x6_r0_body.st4.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace4 : PRE_first_tail_x6_r0_body.s54.trace = PRE_first_tail_x6_r0_body.st4.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores4 : PRE_first_tail_x6_r0_body.s54.stores = PRE_first_tail_x6_r0_body.st4.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD4
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 4 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived4 : PRE_first_tail_x6_r0_body.nr4.map (fun r => nth? PRE_first_tail_x6_r0_body.st4.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo4 : PRE_first_tail_x6_r0_body.nr4.all (Nat.ble 251) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj4 : PRE_first_tail_x6_r0_body.cws4.all (fun c => !PRE_first_tail_x6_r0_body.ws4.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ4 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws4 PRE_first_tail_x6_r0_body.crs4 PRE_first_tail_x6_r0_body.ws4

end Host.Load.Run.Tpl
end

section -- st4/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st4`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st4.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st4.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st4.s2.heap PRE_first_tail_x6_r0_body.st4.wrR ++ freshOf PRE_first_tail_x6_r0_body.st4.s2.heap PRE_first_tail_x6_r0_body.st4.s0.next PRE_first_tail_x6_r0_body.st4.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st4.wr : List Nat := PRE_first_tail_x6_r0_body.st4.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st4.heapFoot : PRE_first_tail_x6_r0_body.st4.s2.heap = setAll PRE_first_tail_x6_r0_body.st4.s0.heap PRE_first_tail_x6_r0_body.st4.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st4.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st4.s0.next PRE_first_tail_x6_r0_body.st4.s2.next = true
theorem PRE_first_tail_x6_r0_body.st4.grows : PRE_first_tail_x6_r0_body.st4.s0.next ≤ PRE_first_tail_x6_r0_body.st4.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st4.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st4.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st4.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st4.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st4.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st4.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st4.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st4.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st4.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st4.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st4.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st4.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF4
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 4 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB4 : nodupT PRE_first_tail_x6_r0_body.st4.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup4 : PRE_first_tail_x6_r0_body.st4.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB4).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB4 : PRE_first_tail_x6_r0_body.st4.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound4 : ∀ b ∈ PRE_first_tail_x6_r0_body.st4.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB4 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr4 := PRE_first_tail_x6_r0_body.st4.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq4 : PRE_first_tail_x6_r0_body.st4.s2.trace = PRE_first_tail_x6_r0_body.trFr4 ++ PRE_first_tail_x6_r0_body.st4.s0.trace
theorem PRE_first_tail_x6_r0_body.trace4 : ∃ fr, PRE_first_tail_x6_r0_body.st4.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st4.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq4⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide4 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB4 : (PRE_first_tail_x6_r0_body.wide4.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st4.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix4 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide4, WFix Map.id (Present PRE_first_tail_x6_r0_body.st4.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB4 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL4
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 4 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s54`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO4 : PRE_first_tail_x6_r0_body.st4.S0.oracle = PRE_first_tail_x6_r0_body.st4.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B4 : PRE_first_tail_x6_r0_body.st4.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st4.s0.next || (PRE_first_tail_x6_r0_body.st4.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot4 : Conv.StageFoot PRE_first_tail_x6_r0_body.st4.wr PRE_first_tail_x6_r0_body.st4.s0 PRE_first_tail_x6_r0_body.st4.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st4.heapFoot PRE_first_tail_x6_r0_body.wrNodup4 PRE_first_tail_x6_r0_body.wrBound4 PRE_first_tail_x6_r0_body.wr0B4 PRE_first_tail_x6_r0_body.st4.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged4 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st4.F.S → PRE_first_tail_x6_r0_body.st4.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st4.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st4.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs4 PRE_first_tail_x6_r0_body.st4.wr PRE_first_tail_x6_r0_body.s53 PRE_first_tail_x6_r0_body.st4.s2 PRE_first_tail_x6_r0_body.st4.s0
      PRE_first_tail_x6_r0_body.st4.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st4.F FR W stk M ν K PRE_first_tail_x6_r0_body.s54 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso4 PRE_first_tail_x6_r0_body.stFoot4 PRE_first_tail_x6_r0_body.wrNodup4 PRE_first_tail_x6_r0_body.wrBound4 PRE_first_tail_x6_r0_body.trace4 PRE_first_tail_x6_r0_body.mheap4
    PRE_first_tail_x6_r0_body.mnext4 PRE_first_tail_x6_r0_body.mctl4 PRE_first_tail_x6_r0_body.mstack4 PRE_first_tail_x6_r0_body.mjobs4 PRE_first_tail_x6_r0_body.mffi4 PRE_first_tail_x6_r0_body.mtrace4 PRE_first_tail_x6_r0_body.mstores4 h

def PRE_first_tail_x6_r0_body.arrEl4_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE4_2665 : arrOf PRE_first_tail_x6_r0_body.s54 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl4_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA4_2665 : isArrB PRE_first_tail_x6_r0_body.s54 2665 = true
theorem PRE_first_tail_x6_r0_body.arr4_2665 : ∃ o, PRE_first_tail_x6_r0_body.s54.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl4_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE4_2665 PRE_first_tail_x6_r0_body.arrA4_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN4_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl4_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR4_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl4_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN4_2665

def PRE_first_tail_x6_r0_body.arrEl4_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE4_2673467 : arrOf PRE_first_tail_x6_r0_body.s54 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl4_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA4_2673467 : isArrB PRE_first_tail_x6_r0_body.s54 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr4_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s54.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl4_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE4_2673467 PRE_first_tail_x6_r0_body.arrA4_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN4_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl4_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR4_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl4_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN4_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k4 : isArrB PRE_first_tail_x6_r0_body.s54 4910 = false
theorem PRE_first_tail_x6_r0_body.keep4 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s54 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k4 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr4_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl4_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ4
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 4 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s53`, the merged
state `PRE_first_tail_x6_r0_body.s54`, the canonical state `PRE_first_tail_x6_r0_body.s55`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl4 : PRE_first_tail_x6_r0_body.pl4.all (Nat.ble PRE_first_tail_x6_r0_body.s53.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd4 : nodupT PRE_first_tail_x6_r0_body.pl4 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn14 : Nat.ble PRE_first_tail_x6_r0_body.s53.next 2678121 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst4 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s53.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn4 : PRE_first_tail_x6_r0_body.s55.next = PRE_first_tail_x6_r0_body.s53.next + PRE_first_tail_x6_r0_body.pl4.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn4 : PRE_first_tail_x6_r0_body.s54.next = 2678121
kernel_rfl PRE_first_tail_x6_r0_body.zgrow4 : Nat.ble PRE_first_tail_x6_r0_body.s55.next PRE_first_tail_x6_r0_body.s54.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh4 : PRE_first_tail_x6_r0_body.S53.tab.all (fun e => PRE_first_tail_x6_r0_body.cws4.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd4 : nodupT PRE_first_tail_x6_r0_body.cws4 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi4 : PRE_first_tail_x6_r0_body.nr4.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S54.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt4 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s53.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg4_2665 : PRE_first_tail_x6_r0_body.s55.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s55 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk4_2665 : (objOf PRE_first_tail_x6_r0_body.s55 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm4_2665 : PRE_first_tail_x6_r0_body.s54.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa4.obj (objOf PRE_first_tail_x6_r0_body.s55 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s54 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg4_2673467 : PRE_first_tail_x6_r0_body.s55.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s55 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk4_2673467 : (objOf PRE_first_tail_x6_r0_body.s55 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm4_2673467 : PRE_first_tail_x6_r0_body.s54.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa4.obj (objOf PRE_first_tail_x6_r0_body.s55 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s54 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw4_4910 : (PRE_first_tail_x6_r0_body.s55.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw4_2673472 : (PRE_first_tail_x6_r0_body.s55.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw4_2673473 : (PRE_first_tail_x6_r0_body.s55.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd4 : PRE_first_tail_x6_r0_body.cl4.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr4 : PRE_first_tail_x6_r0_body.st4.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s53.next || PRE_first_tail_x6_r0_body.cl4.contains b) = true
def PRE_first_tail_x6_r0_body.zl4 : List Nat := PRE_first_tail_x6_r0_body.cl4.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE4 : PRE_first_tail_x6_r0_body.zl4.map (fun a => PRE_first_tail_x6_r0_body.s54.heap.get (PRE_first_tail_x6_r0_body.kappa4.a a)) = PRE_first_tail_x6_r0_body.zl4.map (fun a => (PRE_first_tail_x6_r0_body.s55.heap.get a).map PRE_first_tail_x6_r0_body.kappa4.hobj)
theorem PRE_first_tail_x6_r0_body.zimg4 : HeapImg PRE_first_tail_x6_r0_body.kappa4 PRE_first_tail_x6_r0_body.s55 PRE_first_tail_x6_r0_body.s54 PRE_first_tail_x6_r0_body.zl4 := PRE_first_tail_x6_r0_body.zimgE4
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl4 : PRE_first_tail_x6_r0_body.s54.ctl = PRE_first_tail_x6_r0_body.kappa4.ctl PRE_first_tail_x6_r0_body.s55.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack4 : PRE_first_tail_x6_r0_body.s54.stack = PRE_first_tail_x6_r0_body.s55.stack.map PRE_first_tail_x6_r0_body.kappa4.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs4 : PRE_first_tail_x6_r0_body.s54.jobs = PRE_first_tail_x6_r0_body.s55.jobs.map PRE_first_tail_x6_r0_body.kappa4.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores4 : PRE_first_tail_x6_r0_body.s54.stores = PRE_first_tail_x6_r0_body.kappa4.stores PRE_first_tail_x6_r0_body.s55.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots4 : checkRootsSupp PRE_first_tail_x6_r0_body.s55 251 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC4 : PRE_first_tail_x6_r0_body.S53.tab.length + PRE_first_tail_x6_r0_body.cws4.length = 251
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap4 : PRE_first_tail_x6_r0_body.kappa4 = Conv.Map.compact PRE_first_tail_x6_r0_body.s53.next 2678121 PRE_first_tail_x6_r0_body.S53.tab.length PRE_first_tail_x6_r0_body.pl4 (PRE_first_tail_x6_r0_body.nr4.map NumV.ref) PRE_first_tail_x6_r0_body.kd4.big
  PRE_first_tail_x6_r0_body.kd4.region PRE_first_tail_x6_r0_body.kd4.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin4 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s55.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc4 : Conv.jcleanListB (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s55 PRE_first_tail_x6_r0_body.cl4 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB4 : noBigRootsP (fun i => !Conv.oldBigB (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s55.trace PRE_first_tail_x6_r0_body.s55 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm4 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15381 = true
theorem PRE_first_tail_x6_r0_body.cjcl4 (h : Conv.JClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s53) : Conv.JClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s55 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle4)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap4 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd4 a ha)) PRE_first_tail_x6_r0_body.zjc4

end Host.Load.Run.Tpl
end

section -- st4/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st4.bodyLast from PRE_first_tail_x6_r0_body.st4.s1 to PRE_first_tail_x6_r0_body.st4.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st4.F PRE_first_tail_x6_r0_body.st4.s1).run PRE_first_tail_x6_r0_body.st4.S1 = some (PRE_first_tail_x6_r0_body.st4.s2, PRE_first_tail_x6_r0_body.st4.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st4.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st4.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st4.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st4.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st4/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st4.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st4.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st4.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st4.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st4.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st4.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st4.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st4.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st4.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st4.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st4.s0 PRE_first_tail_x6_r0_body.st4.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st4.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st4.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st4.s1 PRE_first_tail_x6_r0_body.st4.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st4/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st4.bodyK0F from PRE_first_tail_x6_r0_body.st4.s0 to PRE_first_tail_x6_r0_body.st4.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st4.F (PRE_first_tail_x6_r0_body.st4.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st4.ks 0).getD 0) PRE_first_tail_x6_r0_body.st4.s0 PRE_first_tail_x6_r0_body.st4.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st4.s1, PRE_first_tail_x6_r0_body.st4.S1)
theorem PRE_first_tail_x6_r0_body.st4.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st4.F (PRE_first_tail_x6_r0_body.st4.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st4.ks 0).getD 0) PRE_first_tail_x6_r0_body.st4.s0 PRE_first_tail_x6_r0_body.st4.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st4.s1, PRE_first_tail_x6_r0_body.st4.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st4.bodyOkLN_ok PRE_first_tail_x6_r0_body.st4.bodyK0F
end Host.Load.Run.Tpl
end

section -- st4/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st4.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st4.F (PRE_first_tail_x6_r0_body.st4.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st4.s0 PRE_first_tail_x6_r0_body.st4.S0 = some (PRE_first_tail_x6_r0_body.st4.s1, PRE_first_tail_x6_r0_body.st4.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st4.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st4.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st4.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st4.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st4.F (PRE_first_tail_x6_r0_body.st4.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st4.s0
  S0 := PRE_first_tail_x6_r0_body.st4.S0
  s1 := PRE_first_tail_x6_r0_body.st4.s1
  S1 := PRE_first_tail_x6_r0_body.st4.S1
  s2 := PRE_first_tail_x6_r0_body.st4.s2
  S2 := PRE_first_tail_x6_r0_body.st4.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st4.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st4.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st4.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st4.bodyHalt
  last := PRE_first_tail_x6_r0_body.st4.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st4.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC5
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 5 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s59` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa5` into the merged state
`PRE_first_tail_x6_r0_body.s58`. -/

def PRE_first_tail_x6_r0_body.pl5 : List Nat := [2678417]
def PRE_first_tail_x6_r0_body.nr5 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd5 : RData :=
  ⟨2678408, 2678418, Stage.setAll PTrie.nil [(2678407, 2678417)], Stage.setAll PTrie.nil [],
   18293, 18293, 15385, 15385, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa5 : Map :=
  Conv.Map.compact 2678407 2678418 268 PRE_first_tail_x6_r0_body.pl5 (PRE_first_tail_x6_r0_body.nr5.map NumV.ref) PRE_first_tail_x6_r0_body.kd5.big
    PRE_first_tail_x6_r0_body.kd5.region PRE_first_tail_x6_r0_body.kd5.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws5 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs5 : List SymE := PRE_first_tail_x6_r0_body.nr5.map fun r => (nth? PRE_first_tail_x6_r0_body.S58.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta5 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws5 PRE_first_tail_x6_r0_body.crs5
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB5 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab5 : PRE_first_tail_x6_r0_body.S59.tab = PRE_first_tail_x6_r0_body.S57.tab ++ PRE_first_tail_x6_r0_body.cws5.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace5 : PRE_first_tail_x6_r0_body.s59.trace = PRE_first_tail_x6_r0_body.s57.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext5 : PRE_first_tail_x6_r0_body.s59.next = 2678408
kernel_rfl PRE_first_tail_x6_r0_body.ccounters5 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx.nnext) = (18293, 15385)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue5 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s58.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa5.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp5 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx.tokens.all (bSN 268) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean5 : Conv.cleanListB 18293 131072 (fun r => Nat.ble 73172 r) PRE_first_tail_x6_r0_body.s59
    (PRE_first_tail_x6_r0_body.wrB5 ++ (List.range 1).map (2678407 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs5 : bigsOutB 18293 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK5
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl5`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl5 : List Nat := [2665, 2673467, 2678407]
def PRE_first_tail_x6_r0_body.clo5 : List Nat := []
def PRE_first_tail_x6_r0_body.cln5 : List Nat := []
def PRE_first_tail_x6_r0_body.cli5 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap5 : PRE_first_tail_x6_r0_body.s59.heap = Stage.setAll PRE_first_tail_x6_r0_body.s57.heap (PRE_first_tail_x6_r0_body.cl5.filterMap fun a => (PRE_first_tail_x6_r0_body.s59.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe5 : Nat.ble PRE_first_tail_x6_r0_body.s57.next PRE_first_tail_x6_r0_body.s59.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP5 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s57 PRE_first_tail_x6_r0_body.s59 PRE_first_tail_x6_r0_body.cl5 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp5 : Conv.suppListB PRE_first_tail_x6_r0_body.s59 268 PRE_first_tail_x6_r0_body.cl5 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound5 : Conv.boundListB PRE_first_tail_x6_r0_body.s59 PRE_first_tail_x6_r0_body.cl5 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK5 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln5.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK5 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo5.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK5 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli5.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst5 : Conv.sstListB 268 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx PRE_first_tail_x6_r0_body.cln5 PRE_first_tail_x6_r0_body.clo5 PRE_first_tail_x6_r0_body.cli5 = true

end Host.Load.Run.Tpl
end

section -- SiteCl5
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA5 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo5.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd5 : (PRE_first_tail_x6_r0_body.clo5 ++ PRE_first_tail_x6_r0_body.cln5 ++ PRE_first_tail_x6_r0_body.cli5).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle5 : Conv.Cnt.leB (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck5 : Conv.ncleanListB (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx PRE_first_tail_x6_r0_body.clo5 PRE_first_tail_x6_r0_body.cln5 PRE_first_tail_x6_r0_body.cli5 = true
theorem PRE_first_tail_x6_r0_body.cncl5 (h : Conv.NClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx) : Conv.NClean (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle5 PRE_first_tail_x6_r0_body.ckA5 PRE_first_tail_x6_r0_body.cobjsK5 PRE_first_tail_x6_r0_body.cnodesK5 PRE_first_tail_x6_r0_body.citemsK5 PRE_first_tail_x6_r0_body.cbd5 PRE_first_tail_x6_r0_body.cck5

end Host.Load.Run.Tpl
end

section -- SiteS5
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 5 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc5 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P5 : LoadP := PRE_first_tail_x6_r0_body.Pc5.raise 15385
kernel_rfl PRE_first_tail_x6_r0_body.craise5 : Nat.ble PRE_first_tail_x6_r0_body.Pc5.N0 15385 = true
theorem PRE_first_tail_x6_r0_body.raised5 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc5 PRE_first_tail_x6_r0_body.P5 :=
  .inr ⟨15385, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise5, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_5 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_5 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s58.ffi)
def PRE_first_tail_x6_r0_body.khinv5 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv5 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS5 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS5 : List Nat := List.range' 15385 0
def PRE_first_tail_x6_r0_body.ciS5 : List Nat := [] ++ List.range' 15385 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh05 : PRE_first_tail_x6_r0_body.kd5.nh0 = PRE_first_tail_x6_r0_body.cx0_5.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh15 : PRE_first_tail_x6_r0_body.kd5.nh1 = PRE_first_tail_x6_r0_body.cx1_5.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn05 : PRE_first_tail_x6_r0_body.kd5.nn0 = PRE_first_tail_x6_r0_body.cx0_5.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn15 : PRE_first_tail_x6_r0_body.kd5.nn1 = PRE_first_tail_x6_r0_body.cx1_5.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo5 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P5.lo && Nat.ble PRE_first_tail_x6_r0_body.P5.lo PRE_first_tail_x6_r0_body.cx0_5.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P5.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P5.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt5 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_5.mlx.next PRE_first_tail_x6_r0_body.cx1_5.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_5.mlx.nnext PRE_first_tail_x6_r0_body.cx1_5.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband5 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P5.NL && Nat.ble PRE_first_tail_x6_r0_body.P5.NL PRE_first_tail_x6_r0_body.P5.N0 && Nat.ble PRE_first_tail_x6_r0_body.P5.N0 PRE_first_tail_x6_r0_body.cx0_5.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow5 : PRE_first_tail_x6_r0_body.kd5.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren5 : checkRenG PRE_first_tail_x6_r0_body.kd5.hnd PRE_first_tail_x6_r0_body.khinv5 (phB PRE_first_tail_x6_r0_body.cx0_5.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband5 : PRE_first_tail_x6_r0_body.kd5.checkBand PRE_first_tail_x6_r0_body.P5.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos5 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd5.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren5 : checkRenG PRE_first_tail_x6_r0_body.kd5.node PRE_first_tail_x6_r0_body.kninv5 (pnB PRE_first_tail_x6_r0_body.cx0_5.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow5 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd5.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P5.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd5.nodeF j) PRE_first_tail_x6_r0_body.cx1_5.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a5 : PRE_first_tail_x6_r0_body.cx0_5.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b5 : PRE_first_tail_x6_r0_body.cx0_5.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok15 : PRE_first_tail_x6_r0_body.cx1_5.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend5 : PRE_first_tail_x6_r0_body.cx1_5.mlx.pending = PRE_first_tail_x6_r0_body.cx0_5.mlx.pending.map PRE_first_tail_x6_r0_body.kappa5.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh5 : PRE_first_tail_x6_r0_body.cx1_5.mlx.errh = PRE_first_tail_x6_r0_body.cx0_5.mlx.errh.map PRE_first_tail_x6_r0_body.kappa5.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles5 : PRE_first_tail_x6_r0_body.cx1_5.mlx.files = PRE_first_tail_x6_r0_body.cx0_5.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch5 : PRE_first_tail_x6_r0_body.cx1_5.mlx.arch = PRE_first_tail_x6_r0_body.cx0_5.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes5 : PRE_first_tail_x6_r0_body.cx1_5.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_5.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired5 : PRE_first_tail_x6_r0_body.cx1_5.mlx.wired = PRE_first_tail_x6_r0_body.cx0_5.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost5 : PRE_first_tail_x6_r0_body.cx1_5.host = PRE_first_tail_x6_r0_body.cx0_5.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd5`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn05 : PRE_first_tail_x6_r0_body.kd5.n0 = 2678408
kernel_rfl PRE_first_tail_x6_r0_body.ckn15 : PRE_first_tail_x6_r0_body.kd5.n1 = 2678418
kernel_rfl PRE_first_tail_x6_r0_body.ckheap5 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd5.heap).all (fun x => Nat.ble 2678407 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl5 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd5.heap.get (2678407 + j) = nth? PRE_first_tail_x6_r0_body.pl5 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja5 : Nat.ble 2678407 2678407 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn5 : Nat.ble 268 268 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD5 : Nat.ble 2678407 PRE_first_tail_x6_r0_body.kd5.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn5 : Nat.ble 18293 PRE_first_tail_x6_r0_body.kd5.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn5 : Nat.ble 15385 PRE_first_tail_x6_r0_body.kd5.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb5 : Nat.ble 18293 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap5 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd5.heap).all (Nat.ble (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd5 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd5.hnd).all (Nat.ble (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode5 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd5.node).all (Nat.ble (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix5 : Conv.FixOld (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa5 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja5) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn5) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD5) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn5) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn5) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb5) PRE_first_tail_x6_r0_body.fheap5 PRE_first_tail_x6_r0_body.fhnd5 PRE_first_tail_x6_r0_body.fnode5
kernel_rfl PRE_first_tail_x6_r0_body.fcxn5 : (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn5 : (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle05 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_5.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_5.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk5 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd5.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A5 : PRE_first_tail_x6_r0_body.cx1_5.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS5.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_5.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O5 : PRE_first_tail_x6_r0_body.cx1_5.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS5.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_5.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N5 : PRE_first_tail_x6_r0_body.cx1_5.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS5.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_5.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I5 : PRE_first_tail_x6_r0_body.cx1_5.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS5.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_5.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd5 : (PRE_first_tail_x6_r0_body.clo5 ++ PRE_first_tail_x6_r0_body.cln5 ++ PRE_first_tail_x6_r0_body.cli5 ++ PRE_first_tail_x6_r0_body.cwS5 ++ PRE_first_tail_x6_r0_body.cnS5 ++ PRE_first_tail_x6_r0_body.ciS5).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW5 : PRE_first_tail_x6_r0_body.cwS5.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo5.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI5 : PRE_first_tail_x6_r0_body.ciS5.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli5.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN5 : PRE_first_tail_x6_r0_body.cnS5.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF5 : PRE_first_tail_x6_r0_body.cln5.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh5 : PRE_first_tail_x6_r0_body.clo5.all (handleOK PRE_first_tail_x6_r0_body.kappa5 PRE_first_tail_x6_r0_body.P5.lo PRE_first_tail_x6_r0_body.cx0_5.mlx PRE_first_tail_x6_r0_body.cx1_5.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo5 : PRE_first_tail_x6_r0_body.clo5.map (fun h => PRE_first_tail_x6_r0_body.cx1_5.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa5.handle h)) = PRE_first_tail_x6_r0_body.clo5.map (fun h => (PRE_first_tail_x6_r0_body.cx0_5.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa5.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok5 : PRE_first_tail_x6_r0_body.clo5.all (objOK PRE_first_tail_x6_r0_body.kappa5 PRE_first_tail_x6_r0_body.P5.NL PRE_first_tail_x6_r0_body.cx0_5.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd5 : PRE_first_tail_x6_r0_body.cln5.all (nodeOKF PRE_first_tail_x6_r0_body.kappa5 PRE_first_tail_x6_r0_body.P5 PRE_first_tail_x6_r0_body.cx0_5.mlx PRE_first_tail_x6_r0_body.cx1_5.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp5 : ((PRE_first_tail_x6_r0_body.cln5.filter (fullB PRE_first_tail_x6_r0_body.P5))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_5.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa5.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln5.filter (fullB PRE_first_tail_x6_r0_body.P5))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_5.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa5.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI5 : incrB PRE_first_tail_x6_r0_body.kd5.nodeF (List.range' 15385 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK5 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd5.node).all (fun k => Nat.ble 15385 k && Nat.blt k 15385) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL5 : (PRE_first_tail_x6_r0_body.cln5.filter (Nat.ble PRE_first_tail_x6_r0_body.P5.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd5.nodeF i) && (Nat.blt i 15385 || Nat.ble PRE_first_tail_x6_r0_body.kd5.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord5 : (PRE_first_tail_x6_r0_body.cln5.filter (Nat.ble PRE_first_tail_x6_r0_body.P5.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd5.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd5.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd5.nodeF j) (PRE_first_tail_x6_r0_body.kd5.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow5 PRE_first_tail_x6_r0_body.cnn15 PRE_first_tail_x6_r0_body.fnordI5 PRE_first_tail_x6_r0_body.fnordK5 PRE_first_tail_x6_r0_body.fnordL5
kernel_rfl PRE_first_tail_x6_r0_body.fi5 : PRE_first_tail_x6_r0_body.cli5.all (pnB PRE_first_tail_x6_r0_body.cx0_5.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii5 : PRE_first_tail_x6_r0_body.cli5.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_5.mlx.items.get (PRE_first_tail_x6_r0_body.kappa5.node k) = (PRE_first_tail_x6_r0_body.cx0_5.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa5.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot5 (clean : Conv.NClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P5.NL) (cl : SSt (· < 268) PRE_first_tail_x6_r0_body.cx0_5.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P5 268 PRE_first_tail_x6_r0_body.kappa5 PRE_first_tail_x6_r0_body.kd5 PRE_first_tail_x6_r0_body.khinv5 PRE_first_tail_x6_r0_body.kninv5 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx PRE_first_tail_x6_r0_body.cx0_5.mlx PRE_first_tail_x6_r0_body.cx1_5.mlx (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo5 PRE_first_tail_x6_r0_body.cln5 PRE_first_tail_x6_r0_body.cli5 PRE_first_tail_x6_r0_body.cwS5 PRE_first_tail_x6_r0_body.cnS5 PRE_first_tail_x6_r0_body.ciS5 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh05, PRE_first_tail_x6_r0_body.cnh15, PRE_first_tail_x6_r0_body.cnn05, PRE_first_tail_x6_r0_body.cnn15, PRE_first_tail_x6_r0_body.cplo5, PRE_first_tail_x6_r0_body.ccnt5, PRE_first_tail_x6_r0_body.cnband5, PRE_first_tail_x6_r0_body.chbelow5, PRE_first_tail_x6_r0_body.chren5, PRE_first_tail_x6_r0_body.cband5, PRE_first_tail_x6_r0_body.cnh1pos5, PRE_first_tail_x6_r0_body.cnren5, PRE_first_tail_x6_r0_body.cnlow5, PRE_first_tail_x6_r0_body.cabs0a5, PRE_first_tail_x6_r0_body.cabs0b5, PRE_first_tail_x6_r0_body.ctok15, PRE_first_tail_x6_r0_body.cpend5, PRE_first_tail_x6_r0_body.cerrh5, PRE_first_tail_x6_r0_body.cfiles5, PRE_first_tail_x6_r0_body.carch5, PRE_first_tail_x6_r0_body.csizes5, PRE_first_tail_x6_r0_body.cwired5, PRE_first_tail_x6_r0_body.cfix5, clean, PRE_first_tail_x6_r0_body.fcxn5, PRE_first_tail_x6_r0_body.fcnn5, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle05, PRE_first_tail_x6_r0_body.fnk5, PRE_first_tail_x6_r0_body.ckA5, PRE_first_tail_x6_r0_body.cobjsK5, PRE_first_tail_x6_r0_body.cnodesK5, PRE_first_tail_x6_r0_body.citemsK5, PRE_first_tail_x6_r0_body.f1A5, PRE_first_tail_x6_r0_body.f1O5, PRE_first_tail_x6_r0_body.f1N5, PRE_first_tail_x6_r0_body.f1I5, PRE_first_tail_x6_r0_body.fbd5, PRE_first_tail_x6_r0_body.fincW5, PRE_first_tail_x6_r0_body.fincI5, PRE_first_tail_x6_r0_body.fincN5, PRE_first_tail_x6_r0_body.flnF5, PRE_first_tail_x6_r0_body.fh5, PRE_first_tail_x6_r0_body.fo5, PRE_first_tail_x6_r0_body.fok5, PRE_first_tail_x6_r0_body.fnd5, PRE_first_tail_x6_r0_body.fp5, PRE_first_tail_x6_r0_body.fnord5, PRE_first_tail_x6_r0_body.fi5, PRE_first_tail_x6_r0_body.fii5⟩
theorem PRE_first_tail_x6_r0_body.cnshift5 (clean : Conv.NClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P5.NL) (cl : SSt (· < 268) PRE_first_tail_x6_r0_body.cx0_5.mlx) : NShift PRE_first_tail_x6_r0_body.P5 268 PRE_first_tail_x6_r0_body.kappa5 PRE_first_tail_x6_r0_body.cx0_5 PRE_first_tail_x6_r0_body.cx1_5 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot5 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost5 (compact_a_eq PRE_first_tail_x6_r0_body.ckn05 PRE_first_tail_x6_r0_body.ckn15 PRE_first_tail_x6_r0_body.ckheap5 PRE_first_tail_x6_r0_body.ckpl5)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_5 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s57.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_5 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s57.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_5 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s57.ffi) = some PRE_first_tail_x6_r0_body.fxC_5
kernel_rfl PRE_first_tail_x6_r0_body.okrC_5 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s57.ffi) = some PRE_first_tail_x6_r0_body.krC_5
noncomputable def PRE_first_tail_x6_r0_body.fx0_5 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s59.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_5 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s59.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_5 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s59.ffi) = some PRE_first_tail_x6_r0_body.fx0_5
kernel_rfl PRE_first_tail_x6_r0_body.okr0_5 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s59.ffi) = some PRE_first_tail_x6_r0_body.kr0_5
noncomputable def PRE_first_tail_x6_r0_body.fx1_5 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s58.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_5 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s58.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_5 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s58.ffi) = some PRE_first_tail_x6_r0_body.fx1_5
kernel_rfl PRE_first_tail_x6_r0_body.okr1_5 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s58.ffi) = some PRE_first_tail_x6_r0_body.kr1_5
kernel_rfl PRE_first_tail_x6_r0_body.ff05 : PRE_first_tail_x6_r0_body.fx0_5 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_5 (PRE_first_tail_x6_r0_body.clo5.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_5.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff15 : PRE_first_tail_x6_r0_body.fx1_5 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_5 (PRE_first_tail_x6_r0_body.cwS5.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_5.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck5 : freedLB PRE_first_tail_x6_r0_body.kappa5 PRE_first_tail_x6_r0_body.cx0_5.mlx PRE_first_tail_x6_r0_body.fx0_5 PRE_first_tail_x6_r0_body.fx1_5 PRE_first_tail_x6_r0_body.clo5 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf05 : PRE_first_tail_x6_r0_body.kr0_5.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_5.flags (PRE_first_tail_x6_r0_body.clo5.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_5.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt05 : PRE_first_tail_x6_r0_body.kr0_5.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_5.targs (PRE_first_tail_x6_r0_body.clo5.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_5.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf15 : PRE_first_tail_x6_r0_body.kr1_5.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_5.flags (PRE_first_tail_x6_r0_body.cwS5.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_5.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt15 : PRE_first_tail_x6_r0_body.kr1_5.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_5.targs (PRE_first_tail_x6_r0_body.cwS5.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_5.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck5 : krecLB PRE_first_tail_x6_r0_body.kappa5 268 PRE_first_tail_x6_r0_body.cx0_5.mlx PRE_first_tail_x6_r0_body.kr0_5 PRE_first_tail_x6_r0_body.kr1_5 PRE_first_tail_x6_r0_body.clo5 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn5 : Nat.ble 268 268 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge5 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s58.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s59.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR5 : pendRegB PRE_first_tail_x6_r0_body.kappa5 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe5 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s59.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s58.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift5 (clean : Conv.NClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P5.NL) (cl : SSt (· < 268) PRE_first_tail_x6_r0_body.cx0_5.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_5.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_5.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_5.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s57.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_5.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P5 268 PRE_first_tail_x6_r0_body.kappa5 PRE_first_tail_x6_r0_body.s59.ffi PRE_first_tail_x6_r0_body.s58.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift5 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue5, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp5 t ht),
    PRE_first_tail_x6_r0_body.cbridge5,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s59.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s58.ffi) (PRE_first_tail_x6_r0_body.cfoot5 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_5 PRE_first_tail_x6_r0_body.ofx1_5 hobjC PRE_first_tail_x6_r0_body.ff05 PRE_first_tail_x6_r0_body.ff15 PRE_first_tail_x6_r0_body.ffck5,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s59.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s58.ffi) (PRE_first_tail_x6_r0_body.cfoot5 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_5 PRE_first_tail_x6_r0_body.okr1_5 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn5) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf05 PRE_first_tail_x6_r0_body.fkt05 PRE_first_tail_x6_r0_body.fkf15 PRE_first_tail_x6_r0_body.fkt15 PRE_first_tail_x6_r0_body.fkck5,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh05 PRE_first_tail_x6_r0_body.cnh15 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe5) PRE_first_tail_x6_r0_body.cpendR5⟩

end Host.Load.Run.Tpl
end

section -- st5/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st5 0
host_stream_state PRE_first_tail_x6_r0_body.st5 1
host_stream_state PRE_first_tail_x6_r0_body.st5 2
end Host.Load.Run.Tpl
end

section -- Site5
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 5 of chain `PRE_first_tail_x6_r0_body`: `plan__g5__g6` (`plan`), the call state `PRE_first_tail_x6_r0_body.s57`, the merged state `PRE_first_tail_x6_r0_body.s58`,
the site template `PRE_first_tail_x6_r0_body.st5` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s59`: the merge.
The footprint's facts are in `SiteF5`, the compaction's in `SiteC5`, `SiteK5`, `SiteNa5`, `SiteNb5`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso5 : PRE_first_tail_x6_r0_body.st5.s0 = { PRE_first_tail_x6_r0_body.s57 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs5 : List Frame := PRE_first_tail_x6_r0_body.s57.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_5 : PRE_first_tail_x6_r0_body.S57.tab.length = 268
kernel_rfl PRE_first_tail_x6_r0_body.tab0_5 : PRE_first_tail_x6_r0_body.st5.S0.tab = PRE_first_tail_x6_r0_body.S57.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws5 : List Nat := [1111, 1112, 1113]
kernel_rfl PRE_first_tail_x6_r0_body.fresh5 : (PRE_first_tail_x6_r0_body.S57.tab.all fun e => PRE_first_tail_x6_r0_body.ws5.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S57.oracle.all fun q => PRE_first_tail_x6_r0_body.ws5.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab5 : PRE_first_tail_x6_r0_body.S58.tab = PRE_first_tail_x6_r0_body.S57.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws5
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen5 : PRE_first_tail_x6_r0_body.st5.S2.tab.length - PRE_first_tail_x6_r0_body.st5.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged5`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap5 : PRE_first_tail_x6_r0_body.s58.heap = PRE_first_tail_x6_r0_body.st5.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext5 : PRE_first_tail_x6_r0_body.s58.next = PRE_first_tail_x6_r0_body.st5.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl5 : PRE_first_tail_x6_r0_body.s58.ctl = PRE_first_tail_x6_r0_body.st5.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack5 : PRE_first_tail_x6_r0_body.s58.stack = PRE_first_tail_x6_r0_body.st5.s2.stack ++ PRE_first_tail_x6_r0_body.s57.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs5 : PRE_first_tail_x6_r0_body.s58.jobs = PRE_first_tail_x6_r0_body.st5.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi5 : PRE_first_tail_x6_r0_body.s58.ffi = PRE_first_tail_x6_r0_body.st5.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace5 : PRE_first_tail_x6_r0_body.s58.trace = PRE_first_tail_x6_r0_body.st5.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores5 : PRE_first_tail_x6_r0_body.s58.stores = PRE_first_tail_x6_r0_body.st5.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD5
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 5 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived5 : PRE_first_tail_x6_r0_body.nr5.map (fun r => nth? PRE_first_tail_x6_r0_body.st5.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo5 : PRE_first_tail_x6_r0_body.nr5.all (Nat.ble 268) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj5 : PRE_first_tail_x6_r0_body.cws5.all (fun c => !PRE_first_tail_x6_r0_body.ws5.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ5 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws5 PRE_first_tail_x6_r0_body.crs5 PRE_first_tail_x6_r0_body.ws5

end Host.Load.Run.Tpl
end

section -- st5/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st5`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st5.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st5.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st5.s2.heap PRE_first_tail_x6_r0_body.st5.wrR ++ freshOf PRE_first_tail_x6_r0_body.st5.s2.heap PRE_first_tail_x6_r0_body.st5.s0.next PRE_first_tail_x6_r0_body.st5.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st5.wr : List Nat := PRE_first_tail_x6_r0_body.st5.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st5.heapFoot : PRE_first_tail_x6_r0_body.st5.s2.heap = setAll PRE_first_tail_x6_r0_body.st5.s0.heap PRE_first_tail_x6_r0_body.st5.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st5.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st5.s0.next PRE_first_tail_x6_r0_body.st5.s2.next = true
theorem PRE_first_tail_x6_r0_body.st5.grows : PRE_first_tail_x6_r0_body.st5.s0.next ≤ PRE_first_tail_x6_r0_body.st5.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st5.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st5.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st5.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st5.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st5.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st5.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st5.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st5.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st5.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st5.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st5.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st5.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF5
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 5 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB5 : nodupT PRE_first_tail_x6_r0_body.st5.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup5 : PRE_first_tail_x6_r0_body.st5.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB5).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB5 : PRE_first_tail_x6_r0_body.st5.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound5 : ∀ b ∈ PRE_first_tail_x6_r0_body.st5.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB5 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr5 := PRE_first_tail_x6_r0_body.st5.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq5 : PRE_first_tail_x6_r0_body.st5.s2.trace = PRE_first_tail_x6_r0_body.trFr5 ++ PRE_first_tail_x6_r0_body.st5.s0.trace
theorem PRE_first_tail_x6_r0_body.trace5 : ∃ fr, PRE_first_tail_x6_r0_body.st5.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st5.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq5⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide5 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB5 : (PRE_first_tail_x6_r0_body.wide5.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st5.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix5 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide5, WFix Map.id (Present PRE_first_tail_x6_r0_body.st5.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB5 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL5
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 5 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s58`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO5 : PRE_first_tail_x6_r0_body.st5.S0.oracle = PRE_first_tail_x6_r0_body.st5.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B5 : PRE_first_tail_x6_r0_body.st5.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st5.s0.next || (PRE_first_tail_x6_r0_body.st5.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot5 : Conv.StageFoot PRE_first_tail_x6_r0_body.st5.wr PRE_first_tail_x6_r0_body.st5.s0 PRE_first_tail_x6_r0_body.st5.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st5.heapFoot PRE_first_tail_x6_r0_body.wrNodup5 PRE_first_tail_x6_r0_body.wrBound5 PRE_first_tail_x6_r0_body.wr0B5 PRE_first_tail_x6_r0_body.st5.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged5 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st5.F.S → PRE_first_tail_x6_r0_body.st5.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st5.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st5.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs5 PRE_first_tail_x6_r0_body.st5.wr PRE_first_tail_x6_r0_body.s57 PRE_first_tail_x6_r0_body.st5.s2 PRE_first_tail_x6_r0_body.st5.s0
      PRE_first_tail_x6_r0_body.st5.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st5.F FR W stk M ν K PRE_first_tail_x6_r0_body.s58 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso5 PRE_first_tail_x6_r0_body.stFoot5 PRE_first_tail_x6_r0_body.wrNodup5 PRE_first_tail_x6_r0_body.wrBound5 PRE_first_tail_x6_r0_body.trace5 PRE_first_tail_x6_r0_body.mheap5
    PRE_first_tail_x6_r0_body.mnext5 PRE_first_tail_x6_r0_body.mctl5 PRE_first_tail_x6_r0_body.mstack5 PRE_first_tail_x6_r0_body.mjobs5 PRE_first_tail_x6_r0_body.mffi5 PRE_first_tail_x6_r0_body.mtrace5 PRE_first_tail_x6_r0_body.mstores5 h

def PRE_first_tail_x6_r0_body.arrEl5_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE5_2665 : arrOf PRE_first_tail_x6_r0_body.s58 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl5_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA5_2665 : isArrB PRE_first_tail_x6_r0_body.s58 2665 = true
theorem PRE_first_tail_x6_r0_body.arr5_2665 : ∃ o, PRE_first_tail_x6_r0_body.s58.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl5_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE5_2665 PRE_first_tail_x6_r0_body.arrA5_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN5_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl5_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR5_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl5_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN5_2665

def PRE_first_tail_x6_r0_body.arrEl5_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE5_2673467 : arrOf PRE_first_tail_x6_r0_body.s58 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl5_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA5_2673467 : isArrB PRE_first_tail_x6_r0_body.s58 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr5_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s58.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl5_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE5_2673467 PRE_first_tail_x6_r0_body.arrA5_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN5_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl5_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR5_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl5_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN5_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k5 : isArrB PRE_first_tail_x6_r0_body.s58 4910 = false
theorem PRE_first_tail_x6_r0_body.keep5 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s58 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k5 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr5_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl5_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ5
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 5 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s57`, the merged
state `PRE_first_tail_x6_r0_body.s58`, the canonical state `PRE_first_tail_x6_r0_body.s59`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl5 : PRE_first_tail_x6_r0_body.pl5.all (Nat.ble PRE_first_tail_x6_r0_body.s57.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd5 : nodupT PRE_first_tail_x6_r0_body.pl5 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn15 : Nat.ble PRE_first_tail_x6_r0_body.s57.next 2678418 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst5 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s57.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn5 : PRE_first_tail_x6_r0_body.s59.next = PRE_first_tail_x6_r0_body.s57.next + PRE_first_tail_x6_r0_body.pl5.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn5 : PRE_first_tail_x6_r0_body.s58.next = 2678418
kernel_rfl PRE_first_tail_x6_r0_body.zgrow5 : Nat.ble PRE_first_tail_x6_r0_body.s59.next PRE_first_tail_x6_r0_body.s58.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh5 : PRE_first_tail_x6_r0_body.S57.tab.all (fun e => PRE_first_tail_x6_r0_body.cws5.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd5 : nodupT PRE_first_tail_x6_r0_body.cws5 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi5 : PRE_first_tail_x6_r0_body.nr5.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S58.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt5 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s57.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg5_2665 : PRE_first_tail_x6_r0_body.s59.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s59 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk5_2665 : (objOf PRE_first_tail_x6_r0_body.s59 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm5_2665 : PRE_first_tail_x6_r0_body.s58.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa5.obj (objOf PRE_first_tail_x6_r0_body.s59 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s58 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg5_2673467 : PRE_first_tail_x6_r0_body.s59.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s59 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk5_2673467 : (objOf PRE_first_tail_x6_r0_body.s59 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm5_2673467 : PRE_first_tail_x6_r0_body.s58.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa5.obj (objOf PRE_first_tail_x6_r0_body.s59 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s58 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw5_4910 : (PRE_first_tail_x6_r0_body.s59.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw5_2673472 : (PRE_first_tail_x6_r0_body.s59.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw5_2673473 : (PRE_first_tail_x6_r0_body.s59.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd5 : PRE_first_tail_x6_r0_body.cl5.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr5 : PRE_first_tail_x6_r0_body.st5.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s57.next || PRE_first_tail_x6_r0_body.cl5.contains b) = true
def PRE_first_tail_x6_r0_body.zl5 : List Nat := PRE_first_tail_x6_r0_body.cl5.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE5 : PRE_first_tail_x6_r0_body.zl5.map (fun a => PRE_first_tail_x6_r0_body.s58.heap.get (PRE_first_tail_x6_r0_body.kappa5.a a)) = PRE_first_tail_x6_r0_body.zl5.map (fun a => (PRE_first_tail_x6_r0_body.s59.heap.get a).map PRE_first_tail_x6_r0_body.kappa5.hobj)
theorem PRE_first_tail_x6_r0_body.zimg5 : HeapImg PRE_first_tail_x6_r0_body.kappa5 PRE_first_tail_x6_r0_body.s59 PRE_first_tail_x6_r0_body.s58 PRE_first_tail_x6_r0_body.zl5 := PRE_first_tail_x6_r0_body.zimgE5
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl5 : PRE_first_tail_x6_r0_body.s58.ctl = PRE_first_tail_x6_r0_body.kappa5.ctl PRE_first_tail_x6_r0_body.s59.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack5 : PRE_first_tail_x6_r0_body.s58.stack = PRE_first_tail_x6_r0_body.s59.stack.map PRE_first_tail_x6_r0_body.kappa5.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs5 : PRE_first_tail_x6_r0_body.s58.jobs = PRE_first_tail_x6_r0_body.s59.jobs.map PRE_first_tail_x6_r0_body.kappa5.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores5 : PRE_first_tail_x6_r0_body.s58.stores = PRE_first_tail_x6_r0_body.kappa5.stores PRE_first_tail_x6_r0_body.s59.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots5 : checkRootsSupp PRE_first_tail_x6_r0_body.s59 268 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC5 : PRE_first_tail_x6_r0_body.S57.tab.length + PRE_first_tail_x6_r0_body.cws5.length = 268
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap5 : PRE_first_tail_x6_r0_body.kappa5 = Conv.Map.compact PRE_first_tail_x6_r0_body.s57.next 2678418 PRE_first_tail_x6_r0_body.S57.tab.length PRE_first_tail_x6_r0_body.pl5 (PRE_first_tail_x6_r0_body.nr5.map NumV.ref) PRE_first_tail_x6_r0_body.kd5.big
  PRE_first_tail_x6_r0_body.kd5.region PRE_first_tail_x6_r0_body.kd5.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin5 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s59.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc5 : Conv.jcleanListB (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s59 PRE_first_tail_x6_r0_body.cl5 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB5 : noBigRootsP (fun i => !Conv.oldBigB (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s59.trace PRE_first_tail_x6_r0_body.s59 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm5 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15385 = true
theorem PRE_first_tail_x6_r0_body.cjcl5 (h : Conv.JClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s57) : Conv.JClean (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s59 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle5)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap5 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd5 a ha)) PRE_first_tail_x6_r0_body.zjc5

end Host.Load.Run.Tpl
end

section -- st5/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st5.bodyLast from PRE_first_tail_x6_r0_body.st5.s1 to PRE_first_tail_x6_r0_body.st5.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st5.F PRE_first_tail_x6_r0_body.st5.s1).run PRE_first_tail_x6_r0_body.st5.S1 = some (PRE_first_tail_x6_r0_body.st5.s2, PRE_first_tail_x6_r0_body.st5.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st5.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st5.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st5.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st5.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st5/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st5.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st5.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st5.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st5.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st5.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st5.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st5.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st5.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st5.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st5.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st5.s0 PRE_first_tail_x6_r0_body.st5.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st5.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st5.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st5.s1 PRE_first_tail_x6_r0_body.st5.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st5/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st5.bodyK0F from PRE_first_tail_x6_r0_body.st5.s0 to PRE_first_tail_x6_r0_body.st5.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st5.F (PRE_first_tail_x6_r0_body.st5.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st5.ks 0).getD 0) PRE_first_tail_x6_r0_body.st5.s0 PRE_first_tail_x6_r0_body.st5.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st5.s1, PRE_first_tail_x6_r0_body.st5.S1)
theorem PRE_first_tail_x6_r0_body.st5.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st5.F (PRE_first_tail_x6_r0_body.st5.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st5.ks 0).getD 0) PRE_first_tail_x6_r0_body.st5.s0 PRE_first_tail_x6_r0_body.st5.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st5.s1, PRE_first_tail_x6_r0_body.st5.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st5.bodyOkLN_ok PRE_first_tail_x6_r0_body.st5.bodyK0F
end Host.Load.Run.Tpl
end

section -- st5/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st5.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st5.F (PRE_first_tail_x6_r0_body.st5.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st5.s0 PRE_first_tail_x6_r0_body.st5.S0 = some (PRE_first_tail_x6_r0_body.st5.s1, PRE_first_tail_x6_r0_body.st5.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st5.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st5.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st5.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st5.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st5.F (PRE_first_tail_x6_r0_body.st5.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st5.s0
  S0 := PRE_first_tail_x6_r0_body.st5.S0
  s1 := PRE_first_tail_x6_r0_body.st5.s1
  S1 := PRE_first_tail_x6_r0_body.st5.S1
  s2 := PRE_first_tail_x6_r0_body.st5.s2
  S2 := PRE_first_tail_x6_r0_body.st5.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st5.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st5.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st5.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st5.bodyHalt
  last := PRE_first_tail_x6_r0_body.st5.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st5.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC6
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 6 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s76` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa6` into the merged state
`PRE_first_tail_x6_r0_body.s75`. -/

def PRE_first_tail_x6_r0_body.pl6 : List Nat := [2681085, 2680260, 2681091, 2681087, 2680262, 2681093]
def PRE_first_tail_x6_r0_body.nr6 : List Nat := [371, 370, 346, 354, 359, 364, 369, 343, 344, 345, 352, 353, 341, 348, 349, 350, 351, 347]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd6 : RData :=
  ⟨2679979, 2681128, Stage.setAll PTrie.nil [(2679973, 2681085), (2679974, 2680260), (2679975, 2681091), (2679976, 2681087), (2679977, 2680262), (2679978, 2681093)], Stage.setAll PTrie.nil [(18330, 18356), (18331, 18334), (18332, 18357)],
   18333, 18358, 15431, 15431, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(341, .ref 371), (342, .ref 370), (343, .ref 346), (344, .ref 354), (345, .ref 359), (346, .ref 364), (347, .ref 369), (348, .ref 343), (349, .ref 344), (350, .ref 345), (351, .ref 352), (352, .ref 353), (353, .ref 341), (354, .ref 348), (355, .ref 349), (356, .ref 350), (357, .ref 351), (358, .ref 347)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa6 : Map :=
  Conv.Map.compact 2679973 2681128 341 PRE_first_tail_x6_r0_body.pl6 (PRE_first_tail_x6_r0_body.nr6.map NumV.ref) PRE_first_tail_x6_r0_body.kd6.big
    PRE_first_tail_x6_r0_body.kd6.region PRE_first_tail_x6_r0_body.kd6.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws6 : List Nat := [1145, 1146, 1147, 1148, 1149, 1150, 1151, 1152, 1153, 1154, 1155, 1156, 1157, 1158, 1159, 1160, 1161, 1162]
noncomputable def PRE_first_tail_x6_r0_body.crs6 : List SymE := PRE_first_tail_x6_r0_body.nr6.map fun r => (nth? PRE_first_tail_x6_r0_body.S75.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta6 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws6 PRE_first_tail_x6_r0_body.crs6
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB6 : List Nat := [2665, 2672310, 2673467, 2679147, 2679692, 2679948]

kernel_rfl PRE_first_tail_x6_r0_body.ctab6 : PRE_first_tail_x6_r0_body.S76.tab = PRE_first_tail_x6_r0_body.S74.tab ++ PRE_first_tail_x6_r0_body.cws6.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace6 : PRE_first_tail_x6_r0_body.s76.trace = PRE_first_tail_x6_r0_body.s74.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext6 : PRE_first_tail_x6_r0_body.s76.next = 2679979
kernel_rfl PRE_first_tail_x6_r0_body.ccounters6 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx.nnext) = (18333, 15431)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue6 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s75.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa6.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp6 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx.tokens.all (bSN 359) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean6 : Conv.cleanListB 18333 131072 (fun r => Nat.ble 73332 r) PRE_first_tail_x6_r0_body.s76
    (PRE_first_tail_x6_r0_body.wrB6 ++ (List.range 6).map (2679973 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs6 : bigsOutB 18333 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK6
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl6`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl6 : List Nat := [2665, 2672310, 2673467, 2679147, 2679692, 2679948, 2679973, 2679974, 2679975, 2679976, 2679977, 2679978]
def PRE_first_tail_x6_r0_body.clo6 : List Nat := [18310, 18323, 18329, 18330, 18331, 18332]
def PRE_first_tail_x6_r0_body.cln6 : List Nat := [15404, 15405, 15406, 15407, 15408, 15409, 15410, 15411, 15412, 15413, 15414, 15415, 15416, 15417, 15418, 15419, 15420, 15421, 15422, 15423, 15424, 15425, 15426, 15427, 15428, 15429, 15430]
def PRE_first_tail_x6_r0_body.cli6 : List Nat := [15404, 15405, 15406, 15407, 15408, 15409, 15410, 15411, 15412, 15413, 15414, 15415, 15416, 15417, 15418, 15419, 15420, 15421, 15422, 15423, 15424, 15425, 15426, 15427, 15428, 15429, 15430]
kernel_rfl PRE_first_tail_x6_r0_body.cheap6 : PRE_first_tail_x6_r0_body.s76.heap = Stage.setAll PRE_first_tail_x6_r0_body.s74.heap (PRE_first_tail_x6_r0_body.cl6.filterMap fun a => (PRE_first_tail_x6_r0_body.s76.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe6 : Nat.ble PRE_first_tail_x6_r0_body.s74.next PRE_first_tail_x6_r0_body.s76.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP6 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s74 PRE_first_tail_x6_r0_body.s76 PRE_first_tail_x6_r0_body.cl6 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp6 : Conv.suppListB PRE_first_tail_x6_r0_body.s76 359 PRE_first_tail_x6_r0_body.cl6 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound6 : Conv.boundListB PRE_first_tail_x6_r0_body.s76 PRE_first_tail_x6_r0_body.cl6 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK6 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln6.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK6 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo6.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK6 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli6.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst6 : Conv.sstListB 359 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx PRE_first_tail_x6_r0_body.cln6 PRE_first_tail_x6_r0_body.clo6 PRE_first_tail_x6_r0_body.cli6 = true

end Host.Load.Run.Tpl
end

section -- SiteCl6
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA6 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo6.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd6 : (PRE_first_tail_x6_r0_body.clo6 ++ PRE_first_tail_x6_r0_body.cln6 ++ PRE_first_tail_x6_r0_body.cli6).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle6 : Conv.Cnt.leB (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck6 : Conv.ncleanListB (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx PRE_first_tail_x6_r0_body.clo6 PRE_first_tail_x6_r0_body.cln6 PRE_first_tail_x6_r0_body.cli6 = true
theorem PRE_first_tail_x6_r0_body.cncl6 (h : Conv.NClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx) : Conv.NClean (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle6 PRE_first_tail_x6_r0_body.ckA6 PRE_first_tail_x6_r0_body.cobjsK6 PRE_first_tail_x6_r0_body.cnodesK6 PRE_first_tail_x6_r0_body.citemsK6 PRE_first_tail_x6_r0_body.cbd6 PRE_first_tail_x6_r0_body.cck6

end Host.Load.Run.Tpl
end

section -- SiteS6
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 6 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc6 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P6 : LoadP := PRE_first_tail_x6_r0_body.Pc6.raise 15431
kernel_rfl PRE_first_tail_x6_r0_body.craise6 : Nat.ble PRE_first_tail_x6_r0_body.Pc6.N0 15431 = true
theorem PRE_first_tail_x6_r0_body.raised6 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc6 PRE_first_tail_x6_r0_body.P6 :=
  .inr ⟨15431, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise6, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_6 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_6 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s75.ffi)
def PRE_first_tail_x6_r0_body.khinv6 : PTrie Nat := Stage.setAll PTrie.nil [(18356, 18330), (18334, 18331), (18357, 18332)]
def PRE_first_tail_x6_r0_body.kninv6 : PTrie Nat := Stage.setAll PTrie.nil [(15404, 15404), (15405, 15405), (15406, 15406), (15407, 15407), (15408, 15408), (15409, 15409), (15410, 15410), (15411, 15411), (15412, 15412), (15413, 15413), (15414, 15414), (15415, 15415), (15416, 15416), (15417, 15417), (15418, 15418), (15419, 15419), (15420, 15420), (15421, 15421), (15422, 15422), (15423, 15423), (15424, 15424), (15425, 15425), (15426, 15426), (15427, 15427), (15428, 15428), (15429, 15429), (15430, 15430)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS6 : List Nat := [18310, 18323, 18329, 18330, 18331, 18332, 18333, 18334, 18335, 18336, 18337, 18338, 18339, 18340, 18341, 18342, 18343, 18344, 18345, 18346, 18347, 18348, 18349, 18350, 18351, 18352, 18353, 18354, 18355, 18356, 18357]
def PRE_first_tail_x6_r0_body.cnS6 : List Nat := List.range' 15404 27
def PRE_first_tail_x6_r0_body.ciS6 : List Nat := [] ++ List.range' 15404 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh06 : PRE_first_tail_x6_r0_body.kd6.nh0 = PRE_first_tail_x6_r0_body.cx0_6.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh16 : PRE_first_tail_x6_r0_body.kd6.nh1 = PRE_first_tail_x6_r0_body.cx1_6.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn06 : PRE_first_tail_x6_r0_body.kd6.nn0 = PRE_first_tail_x6_r0_body.cx0_6.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn16 : PRE_first_tail_x6_r0_body.kd6.nn1 = PRE_first_tail_x6_r0_body.cx1_6.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo6 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P6.lo && Nat.ble PRE_first_tail_x6_r0_body.P6.lo PRE_first_tail_x6_r0_body.cx0_6.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P6.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P6.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt6 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_6.mlx.next PRE_first_tail_x6_r0_body.cx1_6.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_6.mlx.nnext PRE_first_tail_x6_r0_body.cx1_6.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband6 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P6.NL && Nat.ble PRE_first_tail_x6_r0_body.P6.NL PRE_first_tail_x6_r0_body.P6.N0 && Nat.ble PRE_first_tail_x6_r0_body.P6.N0 PRE_first_tail_x6_r0_body.cx0_6.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow6 : PRE_first_tail_x6_r0_body.kd6.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren6 : checkRenG PRE_first_tail_x6_r0_body.kd6.hnd PRE_first_tail_x6_r0_body.khinv6 (phB PRE_first_tail_x6_r0_body.cx0_6.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband6 : PRE_first_tail_x6_r0_body.kd6.checkBand PRE_first_tail_x6_r0_body.P6.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos6 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd6.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren6 : checkRenG PRE_first_tail_x6_r0_body.kd6.node PRE_first_tail_x6_r0_body.kninv6 (pnB PRE_first_tail_x6_r0_body.cx0_6.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow6 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd6.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P6.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd6.nodeF j) PRE_first_tail_x6_r0_body.cx1_6.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a6 : PRE_first_tail_x6_r0_body.cx0_6.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b6 : PRE_first_tail_x6_r0_body.cx0_6.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok16 : PRE_first_tail_x6_r0_body.cx1_6.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend6 : PRE_first_tail_x6_r0_body.cx1_6.mlx.pending = PRE_first_tail_x6_r0_body.cx0_6.mlx.pending.map PRE_first_tail_x6_r0_body.kappa6.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh6 : PRE_first_tail_x6_r0_body.cx1_6.mlx.errh = PRE_first_tail_x6_r0_body.cx0_6.mlx.errh.map PRE_first_tail_x6_r0_body.kappa6.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles6 : PRE_first_tail_x6_r0_body.cx1_6.mlx.files = PRE_first_tail_x6_r0_body.cx0_6.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch6 : PRE_first_tail_x6_r0_body.cx1_6.mlx.arch = PRE_first_tail_x6_r0_body.cx0_6.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes6 : PRE_first_tail_x6_r0_body.cx1_6.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_6.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired6 : PRE_first_tail_x6_r0_body.cx1_6.mlx.wired = PRE_first_tail_x6_r0_body.cx0_6.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost6 : PRE_first_tail_x6_r0_body.cx1_6.host = PRE_first_tail_x6_r0_body.cx0_6.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd6`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn06 : PRE_first_tail_x6_r0_body.kd6.n0 = 2679979
kernel_rfl PRE_first_tail_x6_r0_body.ckn16 : PRE_first_tail_x6_r0_body.kd6.n1 = 2681128
kernel_rfl PRE_first_tail_x6_r0_body.ckheap6 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd6.heap).all (fun x => Nat.ble 2679973 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl6 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd6.heap.get (2679973 + j) = nth? PRE_first_tail_x6_r0_body.pl6 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja6 : Nat.ble 2679973 2679973 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn6 : Nat.ble 341 341 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD6 : Nat.ble 2679973 PRE_first_tail_x6_r0_body.kd6.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn6 : Nat.ble 18330 PRE_first_tail_x6_r0_body.kd6.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn6 : Nat.ble 15404 PRE_first_tail_x6_r0_body.kd6.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb6 : Nat.ble 18330 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap6 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd6.heap).all (Nat.ble (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd6 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd6.hnd).all (Nat.ble (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode6 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd6.node).all (Nat.ble (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix6 : Conv.FixOld (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa6 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja6) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn6) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD6) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn6) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn6) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb6) PRE_first_tail_x6_r0_body.fheap6 PRE_first_tail_x6_r0_body.fhnd6 PRE_first_tail_x6_r0_body.fnode6
kernel_rfl PRE_first_tail_x6_r0_body.fcxn6 : (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn6 : (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle06 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_6.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_6.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk6 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd6.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A6 : PRE_first_tail_x6_r0_body.cx1_6.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS6.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_6.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O6 : PRE_first_tail_x6_r0_body.cx1_6.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS6.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_6.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N6 : PRE_first_tail_x6_r0_body.cx1_6.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS6.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_6.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I6 : PRE_first_tail_x6_r0_body.cx1_6.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS6.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_6.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd6 : (PRE_first_tail_x6_r0_body.clo6 ++ PRE_first_tail_x6_r0_body.cln6 ++ PRE_first_tail_x6_r0_body.cli6 ++ PRE_first_tail_x6_r0_body.cwS6 ++ PRE_first_tail_x6_r0_body.cnS6 ++ PRE_first_tail_x6_r0_body.ciS6).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW6 : PRE_first_tail_x6_r0_body.cwS6.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo6.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI6 : PRE_first_tail_x6_r0_body.ciS6.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli6.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN6 : PRE_first_tail_x6_r0_body.cnS6.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF6 : PRE_first_tail_x6_r0_body.cln6.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh6 : PRE_first_tail_x6_r0_body.clo6.all (handleOK PRE_first_tail_x6_r0_body.kappa6 PRE_first_tail_x6_r0_body.P6.lo PRE_first_tail_x6_r0_body.cx0_6.mlx PRE_first_tail_x6_r0_body.cx1_6.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo6 : PRE_first_tail_x6_r0_body.clo6.map (fun h => PRE_first_tail_x6_r0_body.cx1_6.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa6.handle h)) = PRE_first_tail_x6_r0_body.clo6.map (fun h => (PRE_first_tail_x6_r0_body.cx0_6.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa6.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok6 : PRE_first_tail_x6_r0_body.clo6.all (objOK PRE_first_tail_x6_r0_body.kappa6 PRE_first_tail_x6_r0_body.P6.NL PRE_first_tail_x6_r0_body.cx0_6.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd6 : PRE_first_tail_x6_r0_body.cln6.all (nodeOKF PRE_first_tail_x6_r0_body.kappa6 PRE_first_tail_x6_r0_body.P6 PRE_first_tail_x6_r0_body.cx0_6.mlx PRE_first_tail_x6_r0_body.cx1_6.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp6 : ((PRE_first_tail_x6_r0_body.cln6.filter (fullB PRE_first_tail_x6_r0_body.P6))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_6.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa6.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln6.filter (fullB PRE_first_tail_x6_r0_body.P6))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_6.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa6.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI6 : incrB PRE_first_tail_x6_r0_body.kd6.nodeF (List.range' 15404 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK6 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd6.node).all (fun k => Nat.ble 15404 k && Nat.blt k 15431) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL6 : (PRE_first_tail_x6_r0_body.cln6.filter (Nat.ble PRE_first_tail_x6_r0_body.P6.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd6.nodeF i) && (Nat.blt i 15431 || Nat.ble PRE_first_tail_x6_r0_body.kd6.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord6 : (PRE_first_tail_x6_r0_body.cln6.filter (Nat.ble PRE_first_tail_x6_r0_body.P6.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd6.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd6.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd6.nodeF j) (PRE_first_tail_x6_r0_body.kd6.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow6 PRE_first_tail_x6_r0_body.cnn16 PRE_first_tail_x6_r0_body.fnordI6 PRE_first_tail_x6_r0_body.fnordK6 PRE_first_tail_x6_r0_body.fnordL6
kernel_rfl PRE_first_tail_x6_r0_body.fi6 : PRE_first_tail_x6_r0_body.cli6.all (pnB PRE_first_tail_x6_r0_body.cx0_6.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii6 : PRE_first_tail_x6_r0_body.cli6.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_6.mlx.items.get (PRE_first_tail_x6_r0_body.kappa6.node k) = (PRE_first_tail_x6_r0_body.cx0_6.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa6.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot6 (clean : Conv.NClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P6.NL) (cl : SSt (· < 359) PRE_first_tail_x6_r0_body.cx0_6.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P6 359 PRE_first_tail_x6_r0_body.kappa6 PRE_first_tail_x6_r0_body.kd6 PRE_first_tail_x6_r0_body.khinv6 PRE_first_tail_x6_r0_body.kninv6 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx PRE_first_tail_x6_r0_body.cx0_6.mlx PRE_first_tail_x6_r0_body.cx1_6.mlx (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo6 PRE_first_tail_x6_r0_body.cln6 PRE_first_tail_x6_r0_body.cli6 PRE_first_tail_x6_r0_body.cwS6 PRE_first_tail_x6_r0_body.cnS6 PRE_first_tail_x6_r0_body.ciS6 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh06, PRE_first_tail_x6_r0_body.cnh16, PRE_first_tail_x6_r0_body.cnn06, PRE_first_tail_x6_r0_body.cnn16, PRE_first_tail_x6_r0_body.cplo6, PRE_first_tail_x6_r0_body.ccnt6, PRE_first_tail_x6_r0_body.cnband6, PRE_first_tail_x6_r0_body.chbelow6, PRE_first_tail_x6_r0_body.chren6, PRE_first_tail_x6_r0_body.cband6, PRE_first_tail_x6_r0_body.cnh1pos6, PRE_first_tail_x6_r0_body.cnren6, PRE_first_tail_x6_r0_body.cnlow6, PRE_first_tail_x6_r0_body.cabs0a6, PRE_first_tail_x6_r0_body.cabs0b6, PRE_first_tail_x6_r0_body.ctok16, PRE_first_tail_x6_r0_body.cpend6, PRE_first_tail_x6_r0_body.cerrh6, PRE_first_tail_x6_r0_body.cfiles6, PRE_first_tail_x6_r0_body.carch6, PRE_first_tail_x6_r0_body.csizes6, PRE_first_tail_x6_r0_body.cwired6, PRE_first_tail_x6_r0_body.cfix6, clean, PRE_first_tail_x6_r0_body.fcxn6, PRE_first_tail_x6_r0_body.fcnn6, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle06, PRE_first_tail_x6_r0_body.fnk6, PRE_first_tail_x6_r0_body.ckA6, PRE_first_tail_x6_r0_body.cobjsK6, PRE_first_tail_x6_r0_body.cnodesK6, PRE_first_tail_x6_r0_body.citemsK6, PRE_first_tail_x6_r0_body.f1A6, PRE_first_tail_x6_r0_body.f1O6, PRE_first_tail_x6_r0_body.f1N6, PRE_first_tail_x6_r0_body.f1I6, PRE_first_tail_x6_r0_body.fbd6, PRE_first_tail_x6_r0_body.fincW6, PRE_first_tail_x6_r0_body.fincI6, PRE_first_tail_x6_r0_body.fincN6, PRE_first_tail_x6_r0_body.flnF6, PRE_first_tail_x6_r0_body.fh6, PRE_first_tail_x6_r0_body.fo6, PRE_first_tail_x6_r0_body.fok6, PRE_first_tail_x6_r0_body.fnd6, PRE_first_tail_x6_r0_body.fp6, PRE_first_tail_x6_r0_body.fnord6, PRE_first_tail_x6_r0_body.fi6, PRE_first_tail_x6_r0_body.fii6⟩
theorem PRE_first_tail_x6_r0_body.cnshift6 (clean : Conv.NClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P6.NL) (cl : SSt (· < 359) PRE_first_tail_x6_r0_body.cx0_6.mlx) : NShift PRE_first_tail_x6_r0_body.P6 359 PRE_first_tail_x6_r0_body.kappa6 PRE_first_tail_x6_r0_body.cx0_6 PRE_first_tail_x6_r0_body.cx1_6 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot6 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost6 (compact_a_eq PRE_first_tail_x6_r0_body.ckn06 PRE_first_tail_x6_r0_body.ckn16 PRE_first_tail_x6_r0_body.ckheap6 PRE_first_tail_x6_r0_body.ckpl6)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_6 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s74.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_6 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s74.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_6 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s74.ffi) = some PRE_first_tail_x6_r0_body.fxC_6
kernel_rfl PRE_first_tail_x6_r0_body.okrC_6 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s74.ffi) = some PRE_first_tail_x6_r0_body.krC_6
noncomputable def PRE_first_tail_x6_r0_body.fx0_6 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s76.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_6 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s76.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_6 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s76.ffi) = some PRE_first_tail_x6_r0_body.fx0_6
kernel_rfl PRE_first_tail_x6_r0_body.okr0_6 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s76.ffi) = some PRE_first_tail_x6_r0_body.kr0_6
noncomputable def PRE_first_tail_x6_r0_body.fx1_6 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s75.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_6 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s75.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_6 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s75.ffi) = some PRE_first_tail_x6_r0_body.fx1_6
kernel_rfl PRE_first_tail_x6_r0_body.okr1_6 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s75.ffi) = some PRE_first_tail_x6_r0_body.kr1_6
kernel_rfl PRE_first_tail_x6_r0_body.ff06 : PRE_first_tail_x6_r0_body.fx0_6 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_6 (PRE_first_tail_x6_r0_body.clo6.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_6.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff16 : PRE_first_tail_x6_r0_body.fx1_6 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_6 (PRE_first_tail_x6_r0_body.cwS6.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_6.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck6 : freedLB PRE_first_tail_x6_r0_body.kappa6 PRE_first_tail_x6_r0_body.cx0_6.mlx PRE_first_tail_x6_r0_body.fx0_6 PRE_first_tail_x6_r0_body.fx1_6 PRE_first_tail_x6_r0_body.clo6 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf06 : PRE_first_tail_x6_r0_body.kr0_6.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_6.flags (PRE_first_tail_x6_r0_body.clo6.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_6.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt06 : PRE_first_tail_x6_r0_body.kr0_6.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_6.targs (PRE_first_tail_x6_r0_body.clo6.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_6.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf16 : PRE_first_tail_x6_r0_body.kr1_6.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_6.flags (PRE_first_tail_x6_r0_body.cwS6.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_6.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt16 : PRE_first_tail_x6_r0_body.kr1_6.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_6.targs (PRE_first_tail_x6_r0_body.cwS6.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_6.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck6 : krecLB PRE_first_tail_x6_r0_body.kappa6 359 PRE_first_tail_x6_r0_body.cx0_6.mlx PRE_first_tail_x6_r0_body.kr0_6 PRE_first_tail_x6_r0_body.kr1_6 PRE_first_tail_x6_r0_body.clo6 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn6 : Nat.ble 341 359 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge6 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s75.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s76.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR6 : pendRegB PRE_first_tail_x6_r0_body.kappa6 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe6 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s76.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s75.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift6 (clean : Conv.NClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P6.NL) (cl : SSt (· < 359) PRE_first_tail_x6_r0_body.cx0_6.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_6.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_6.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_6.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s74.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_6.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P6 359 PRE_first_tail_x6_r0_body.kappa6 PRE_first_tail_x6_r0_body.s76.ffi PRE_first_tail_x6_r0_body.s75.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift6 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue6, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp6 t ht),
    PRE_first_tail_x6_r0_body.cbridge6,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s76.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s75.ffi) (PRE_first_tail_x6_r0_body.cfoot6 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_6 PRE_first_tail_x6_r0_body.ofx1_6 hobjC PRE_first_tail_x6_r0_body.ff06 PRE_first_tail_x6_r0_body.ff16 PRE_first_tail_x6_r0_body.ffck6,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s76.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s75.ffi) (PRE_first_tail_x6_r0_body.cfoot6 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_6 PRE_first_tail_x6_r0_body.okr1_6 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn6) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf06 PRE_first_tail_x6_r0_body.fkt06 PRE_first_tail_x6_r0_body.fkf16 PRE_first_tail_x6_r0_body.fkt16 PRE_first_tail_x6_r0_body.fkck6,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh06 PRE_first_tail_x6_r0_body.cnh16 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe6) PRE_first_tail_x6_r0_body.cpendR6⟩

end Host.Load.Run.Tpl
end

section -- st6/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st6 0
host_stream_state PRE_first_tail_x6_r0_body.st6 1
host_stream_state PRE_first_tail_x6_r0_body.st6 2
host_stream_state PRE_first_tail_x6_r0_body.st6 3
host_stream_state PRE_first_tail_x6_r0_body.st6 4
host_stream_state PRE_first_tail_x6_r0_body.st6 5
end Host.Load.Run.Tpl
end

section -- Site6
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 6 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g6__g7` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s74`, the merged state `PRE_first_tail_x6_r0_body.s75`,
the site template `PRE_first_tail_x6_r0_body.st6` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s76`: the merge.
The footprint's facts are in `SiteF6`, the compaction's in `SiteC6`, `SiteK6`, `SiteNa6`, `SiteNb6`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso6 : PRE_first_tail_x6_r0_body.st6.s0 = { PRE_first_tail_x6_r0_body.s74 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs6 : List Frame := PRE_first_tail_x6_r0_body.s74.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_6 : PRE_first_tail_x6_r0_body.S74.tab.length = 341
kernel_rfl PRE_first_tail_x6_r0_body.tab0_6 : PRE_first_tail_x6_r0_body.st6.S0.tab = PRE_first_tail_x6_r0_body.S74.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws6 : List Nat := [1114, 1115, 1116, 1117, 1118, 1119, 1120, 1121, 1122, 1123, 1124, 1125, 1126, 1127, 1128, 1129, 1130, 1131, 1132, 1133, 1134, 1135, 1136, 1137, 1138, 1139, 1140, 1141, 1142, 1143, 1144]
kernel_rfl PRE_first_tail_x6_r0_body.fresh6 : (PRE_first_tail_x6_r0_body.S74.tab.all fun e => PRE_first_tail_x6_r0_body.ws6.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S74.oracle.all fun q => PRE_first_tail_x6_r0_body.ws6.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab6 : PRE_first_tail_x6_r0_body.S75.tab = PRE_first_tail_x6_r0_body.S74.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws6
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen6 : PRE_first_tail_x6_r0_body.st6.S5.tab.length - PRE_first_tail_x6_r0_body.st6.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged6`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap6 : PRE_first_tail_x6_r0_body.s75.heap = PRE_first_tail_x6_r0_body.st6.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext6 : PRE_first_tail_x6_r0_body.s75.next = PRE_first_tail_x6_r0_body.st6.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl6 : PRE_first_tail_x6_r0_body.s75.ctl = PRE_first_tail_x6_r0_body.st6.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack6 : PRE_first_tail_x6_r0_body.s75.stack = PRE_first_tail_x6_r0_body.st6.s5.stack ++ PRE_first_tail_x6_r0_body.s74.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs6 : PRE_first_tail_x6_r0_body.s75.jobs = PRE_first_tail_x6_r0_body.st6.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi6 : PRE_first_tail_x6_r0_body.s75.ffi = PRE_first_tail_x6_r0_body.st6.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace6 : PRE_first_tail_x6_r0_body.s75.trace = PRE_first_tail_x6_r0_body.st6.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores6 : PRE_first_tail_x6_r0_body.s75.stores = PRE_first_tail_x6_r0_body.st6.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD6
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 6 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived6 : PRE_first_tail_x6_r0_body.nr6.map (fun r => nth? PRE_first_tail_x6_r0_body.st6.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo6 : PRE_first_tail_x6_r0_body.nr6.all (Nat.ble 341) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj6 : PRE_first_tail_x6_r0_body.cws6.all (fun c => !PRE_first_tail_x6_r0_body.ws6.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ6 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws6 PRE_first_tail_x6_r0_body.crs6 PRE_first_tail_x6_r0_body.ws6

end Host.Load.Run.Tpl
end

section -- st6/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st6`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st6.wrR : List (Nat × Nat) := [(2672310, 2672311), (2679147, 2679148), (2679692, 2679693), (2679948, 2679949)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st6.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st6.s5.heap PRE_first_tail_x6_r0_body.st6.wrR ++ freshOf PRE_first_tail_x6_r0_body.st6.s5.heap PRE_first_tail_x6_r0_body.st6.s0.next PRE_first_tail_x6_r0_body.st6.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st6.wr : List Nat := PRE_first_tail_x6_r0_body.st6.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st6.heapFoot : PRE_first_tail_x6_r0_body.st6.s5.heap = setAll PRE_first_tail_x6_r0_body.st6.s0.heap PRE_first_tail_x6_r0_body.st6.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st6.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st6.s0.next PRE_first_tail_x6_r0_body.st6.s5.next = true
theorem PRE_first_tail_x6_r0_body.st6.grows : PRE_first_tail_x6_r0_body.st6.s0.next ≤ PRE_first_tail_x6_r0_body.st6.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st6.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st6.wh : List Nat := [18310, 18323, 18329, 18330, 18331, 18332, 18333, 18334, 18335, 18336, 18337, 18338, 18339, 18340, 18341, 18342, 18343, 18344, 18345, 18346, 18347, 18348, 18349, 18350, 18351, 18352, 18353, 18354, 18355, 18356, 18357]
def PRE_first_tail_x6_r0_body.st6.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st6.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st6.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st6.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st6.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st6.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st6.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st6.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st6.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st6.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF6
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 6 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB6 : nodupT PRE_first_tail_x6_r0_body.st6.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup6 : PRE_first_tail_x6_r0_body.st6.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB6).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB6 : PRE_first_tail_x6_r0_body.st6.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound6 : ∀ b ∈ PRE_first_tail_x6_r0_body.st6.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB6 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr6 := PRE_first_tail_x6_r0_body.st6.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq6 : PRE_first_tail_x6_r0_body.st6.s5.trace = PRE_first_tail_x6_r0_body.trFr6 ++ PRE_first_tail_x6_r0_body.st6.s0.trace
theorem PRE_first_tail_x6_r0_body.trace6 : ∃ fr, PRE_first_tail_x6_r0_body.st6.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st6.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq6⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide6 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB6 : (PRE_first_tail_x6_r0_body.wide6.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st6.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix6 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide6, WFix Map.id (Present PRE_first_tail_x6_r0_body.st6.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB6 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL6
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 6 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s75`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO6 : PRE_first_tail_x6_r0_body.st6.S0.oracle = PRE_first_tail_x6_r0_body.st6.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B6 : PRE_first_tail_x6_r0_body.st6.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st6.s0.next || (PRE_first_tail_x6_r0_body.st6.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot6 : Conv.StageFoot PRE_first_tail_x6_r0_body.st6.wr PRE_first_tail_x6_r0_body.st6.s0 PRE_first_tail_x6_r0_body.st6.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st6.heapFoot PRE_first_tail_x6_r0_body.wrNodup6 PRE_first_tail_x6_r0_body.wrBound6 PRE_first_tail_x6_r0_body.wr0B6 PRE_first_tail_x6_r0_body.st6.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged6 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st6.F.S → PRE_first_tail_x6_r0_body.st6.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st6.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st6.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs6 PRE_first_tail_x6_r0_body.st6.wr PRE_first_tail_x6_r0_body.s74 PRE_first_tail_x6_r0_body.st6.s5 PRE_first_tail_x6_r0_body.st6.s0
      PRE_first_tail_x6_r0_body.st6.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st6.F FR W stk M ν K PRE_first_tail_x6_r0_body.s75 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso6 PRE_first_tail_x6_r0_body.stFoot6 PRE_first_tail_x6_r0_body.wrNodup6 PRE_first_tail_x6_r0_body.wrBound6 PRE_first_tail_x6_r0_body.trace6 PRE_first_tail_x6_r0_body.mheap6
    PRE_first_tail_x6_r0_body.mnext6 PRE_first_tail_x6_r0_body.mctl6 PRE_first_tail_x6_r0_body.mstack6 PRE_first_tail_x6_r0_body.mjobs6 PRE_first_tail_x6_r0_body.mffi6 PRE_first_tail_x6_r0_body.mtrace6 PRE_first_tail_x6_r0_body.mstores6 h

def PRE_first_tail_x6_r0_body.arrEl6_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE6_2665 : arrOf PRE_first_tail_x6_r0_body.s75 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl6_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA6_2665 : isArrB PRE_first_tail_x6_r0_body.s75 2665 = true
theorem PRE_first_tail_x6_r0_body.arr6_2665 : ∃ o, PRE_first_tail_x6_r0_body.s75.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl6_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE6_2665 PRE_first_tail_x6_r0_body.arrA6_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN6_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl6_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR6_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl6_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN6_2665

def PRE_first_tail_x6_r0_body.arrEl6_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE6_2673467 : arrOf PRE_first_tail_x6_r0_body.s75 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl6_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA6_2673467 : isArrB PRE_first_tail_x6_r0_body.s75 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr6_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s75.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl6_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE6_2673467 PRE_first_tail_x6_r0_body.arrA6_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN6_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl6_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR6_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl6_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN6_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k6 : isArrB PRE_first_tail_x6_r0_body.s75 4910 = false
theorem PRE_first_tail_x6_r0_body.keep6 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s75 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k6 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr6_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl6_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ6
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 6 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s74`, the merged
state `PRE_first_tail_x6_r0_body.s75`, the canonical state `PRE_first_tail_x6_r0_body.s76`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl6 : PRE_first_tail_x6_r0_body.pl6.all (Nat.ble PRE_first_tail_x6_r0_body.s74.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd6 : nodupT PRE_first_tail_x6_r0_body.pl6 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn16 : Nat.ble PRE_first_tail_x6_r0_body.s74.next 2681128 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst6 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s74.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn6 : PRE_first_tail_x6_r0_body.s76.next = PRE_first_tail_x6_r0_body.s74.next + PRE_first_tail_x6_r0_body.pl6.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn6 : PRE_first_tail_x6_r0_body.s75.next = 2681128
kernel_rfl PRE_first_tail_x6_r0_body.zgrow6 : Nat.ble PRE_first_tail_x6_r0_body.s76.next PRE_first_tail_x6_r0_body.s75.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh6 : PRE_first_tail_x6_r0_body.S74.tab.all (fun e => PRE_first_tail_x6_r0_body.cws6.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd6 : nodupT PRE_first_tail_x6_r0_body.cws6 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi6 : PRE_first_tail_x6_r0_body.nr6.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S75.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt6 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s74.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg6_2665 : PRE_first_tail_x6_r0_body.s76.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s76 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk6_2665 : (objOf PRE_first_tail_x6_r0_body.s76 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm6_2665 : PRE_first_tail_x6_r0_body.s75.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa6.obj (objOf PRE_first_tail_x6_r0_body.s76 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s75 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg6_2673467 : PRE_first_tail_x6_r0_body.s76.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s76 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk6_2673467 : (objOf PRE_first_tail_x6_r0_body.s76 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm6_2673467 : PRE_first_tail_x6_r0_body.s75.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa6.obj (objOf PRE_first_tail_x6_r0_body.s76 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s75 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw6_4910 : (PRE_first_tail_x6_r0_body.s76.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw6_2673472 : (PRE_first_tail_x6_r0_body.s76.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw6_2673473 : (PRE_first_tail_x6_r0_body.s76.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd6 : PRE_first_tail_x6_r0_body.cl6.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr6 : PRE_first_tail_x6_r0_body.st6.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s74.next || PRE_first_tail_x6_r0_body.cl6.contains b) = true
def PRE_first_tail_x6_r0_body.zl6 : List Nat := PRE_first_tail_x6_r0_body.cl6.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE6 : PRE_first_tail_x6_r0_body.zl6.map (fun a => PRE_first_tail_x6_r0_body.s75.heap.get (PRE_first_tail_x6_r0_body.kappa6.a a)) = PRE_first_tail_x6_r0_body.zl6.map (fun a => (PRE_first_tail_x6_r0_body.s76.heap.get a).map PRE_first_tail_x6_r0_body.kappa6.hobj)
theorem PRE_first_tail_x6_r0_body.zimg6 : HeapImg PRE_first_tail_x6_r0_body.kappa6 PRE_first_tail_x6_r0_body.s76 PRE_first_tail_x6_r0_body.s75 PRE_first_tail_x6_r0_body.zl6 := PRE_first_tail_x6_r0_body.zimgE6
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl6 : PRE_first_tail_x6_r0_body.s75.ctl = PRE_first_tail_x6_r0_body.kappa6.ctl PRE_first_tail_x6_r0_body.s76.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack6 : PRE_first_tail_x6_r0_body.s75.stack = PRE_first_tail_x6_r0_body.s76.stack.map PRE_first_tail_x6_r0_body.kappa6.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs6 : PRE_first_tail_x6_r0_body.s75.jobs = PRE_first_tail_x6_r0_body.s76.jobs.map PRE_first_tail_x6_r0_body.kappa6.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores6 : PRE_first_tail_x6_r0_body.s75.stores = PRE_first_tail_x6_r0_body.kappa6.stores PRE_first_tail_x6_r0_body.s76.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots6 : checkRootsSupp PRE_first_tail_x6_r0_body.s76 359 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC6 : PRE_first_tail_x6_r0_body.S74.tab.length + PRE_first_tail_x6_r0_body.cws6.length = 359
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap6 : PRE_first_tail_x6_r0_body.kappa6 = Conv.Map.compact PRE_first_tail_x6_r0_body.s74.next 2681128 PRE_first_tail_x6_r0_body.S74.tab.length PRE_first_tail_x6_r0_body.pl6 (PRE_first_tail_x6_r0_body.nr6.map NumV.ref) PRE_first_tail_x6_r0_body.kd6.big
  PRE_first_tail_x6_r0_body.kd6.region PRE_first_tail_x6_r0_body.kd6.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin6 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s76.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc6 : Conv.jcleanListB (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s76 PRE_first_tail_x6_r0_body.cl6 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB6 : noBigRootsP (fun i => !Conv.oldBigB (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s76.trace PRE_first_tail_x6_r0_body.s76 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm6 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15404 = true
theorem PRE_first_tail_x6_r0_body.cjcl6 (h : Conv.JClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s74) : Conv.JClean (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s76 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle6)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap6 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd6 a ha)) PRE_first_tail_x6_r0_body.zjc6

end Host.Load.Run.Tpl
end

section -- st6/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st6.bodyLast from PRE_first_tail_x6_r0_body.st6.s4 to PRE_first_tail_x6_r0_body.st6.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st6.F PRE_first_tail_x6_r0_body.st6.s4).run PRE_first_tail_x6_r0_body.st6.S4 = some (PRE_first_tail_x6_r0_body.st6.s5, PRE_first_tail_x6_r0_body.st6.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st6.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st6.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st6.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st6.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st6/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st6.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st6.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st6.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st6.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st6.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st6.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st6.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st6.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st6.s0 PRE_first_tail_x6_r0_body.st6.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st6.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st6.s4 PRE_first_tail_x6_r0_body.st6.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st6/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st6.bodyK0F from PRE_first_tail_x6_r0_body.st6.s0 to PRE_first_tail_x6_r0_body.st6.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st6.F (PRE_first_tail_x6_r0_body.st6.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st6.ks 0).getD 0) PRE_first_tail_x6_r0_body.st6.s0 PRE_first_tail_x6_r0_body.st6.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st6.s1, PRE_first_tail_x6_r0_body.st6.S1)
theorem PRE_first_tail_x6_r0_body.st6.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st6.F (PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st6.ks 0).getD 0) PRE_first_tail_x6_r0_body.st6.s0 PRE_first_tail_x6_r0_body.st6.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st6.s1, PRE_first_tail_x6_r0_body.st6.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st6.bodyOkLN_ok PRE_first_tail_x6_r0_body.st6.bodyK0F
end Host.Load.Run.Tpl
end

section -- st6/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st6.bodyK1F from PRE_first_tail_x6_r0_body.st6.s1 to PRE_first_tail_x6_r0_body.st6.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st6.F (PRE_first_tail_x6_r0_body.st6.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st6.ks 1).getD 0) PRE_first_tail_x6_r0_body.st6.s1 PRE_first_tail_x6_r0_body.st6.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st6.s2, PRE_first_tail_x6_r0_body.st6.S2)
theorem PRE_first_tail_x6_r0_body.st6.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st6.F (PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st6.ks 1).getD 0) PRE_first_tail_x6_r0_body.st6.s1 PRE_first_tail_x6_r0_body.st6.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st6.s2, PRE_first_tail_x6_r0_body.st6.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st6.bodyOkLN_ok PRE_first_tail_x6_r0_body.st6.bodyK1F
end Host.Load.Run.Tpl
end

section -- st6/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st6.bodyK2F from PRE_first_tail_x6_r0_body.st6.s2 to PRE_first_tail_x6_r0_body.st6.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st6.F (PRE_first_tail_x6_r0_body.st6.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st6.ks 2).getD 0) PRE_first_tail_x6_r0_body.st6.s2 PRE_first_tail_x6_r0_body.st6.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st6.s3, PRE_first_tail_x6_r0_body.st6.S3)
theorem PRE_first_tail_x6_r0_body.st6.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st6.F (PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st6.ks 2).getD 0) PRE_first_tail_x6_r0_body.st6.s2 PRE_first_tail_x6_r0_body.st6.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st6.s3, PRE_first_tail_x6_r0_body.st6.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st6.bodyOkLN_ok PRE_first_tail_x6_r0_body.st6.bodyK2F
end Host.Load.Run.Tpl
end

section -- st6/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st6.bodyK3F from PRE_first_tail_x6_r0_body.st6.s3 to PRE_first_tail_x6_r0_body.st6.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st6.F (PRE_first_tail_x6_r0_body.st6.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st6.ks 3).getD 0) PRE_first_tail_x6_r0_body.st6.s3 PRE_first_tail_x6_r0_body.st6.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st6.s4, PRE_first_tail_x6_r0_body.st6.S4)
theorem PRE_first_tail_x6_r0_body.st6.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st6.F (PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st6.ks 3).getD 0) PRE_first_tail_x6_r0_body.st6.s3 PRE_first_tail_x6_r0_body.st6.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st6.s4, PRE_first_tail_x6_r0_body.st6.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st6.bodyOkLN_ok PRE_first_tail_x6_r0_body.st6.bodyK3F
end Host.Load.Run.Tpl
end

section -- st6/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st6.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st6.F (PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st6.s0 PRE_first_tail_x6_r0_body.st6.S0 = some (PRE_first_tail_x6_r0_body.st6.s4, PRE_first_tail_x6_r0_body.st6.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st6.F (PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st6.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st6.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st6.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st6.ks 3).getD 0) PRE_first_tail_x6_r0_body.st6.s0 PRE_first_tail_x6_r0_body.st6.s3 PRE_first_tail_x6_r0_body.st6.s4 PRE_first_tail_x6_r0_body.st6.S0 PRE_first_tail_x6_r0_body.st6.S3 PRE_first_tail_x6_r0_body.st6.S4 (runOk_trans PRE_first_tail_x6_r0_body.st6.F (PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st6.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st6.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st6.ks 2).getD 0) PRE_first_tail_x6_r0_body.st6.s0 PRE_first_tail_x6_r0_body.st6.s2 PRE_first_tail_x6_r0_body.st6.s3 PRE_first_tail_x6_r0_body.st6.S0 PRE_first_tail_x6_r0_body.st6.S2 PRE_first_tail_x6_r0_body.st6.S3 (runOk_trans PRE_first_tail_x6_r0_body.st6.F (PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st6.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st6.ks 1).getD 0) PRE_first_tail_x6_r0_body.st6.s0 PRE_first_tail_x6_r0_body.st6.s1 PRE_first_tail_x6_r0_body.st6.s2 PRE_first_tail_x6_r0_body.st6.S0 PRE_first_tail_x6_r0_body.st6.S1 PRE_first_tail_x6_r0_body.st6.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st6.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st6.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st6.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st6.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st6.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st6.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st6.F (PRE_first_tail_x6_r0_body.st6.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st6.s0
  S0 := PRE_first_tail_x6_r0_body.st6.S0
  s1 := PRE_first_tail_x6_r0_body.st6.s4
  S1 := PRE_first_tail_x6_r0_body.st6.S4
  s2 := PRE_first_tail_x6_r0_body.st6.s5
  S2 := PRE_first_tail_x6_r0_body.st6.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st6.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st6.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st6.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st6.bodyHalt
  last := PRE_first_tail_x6_r0_body.st6.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st6.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 7 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s84` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa7` into the merged state
`PRE_first_tail_x6_r0_body.s83`. -/

def PRE_first_tail_x6_r0_body.pl7 : List Nat := []
def PRE_first_tail_x6_r0_body.nr7 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd7 : RData :=
  ⟨2680469, 2680471, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18346, 18346, 15444, 15444, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa7 : Map :=
  Conv.Map.compact 2680469 2680471 380 PRE_first_tail_x6_r0_body.pl7 (PRE_first_tail_x6_r0_body.nr7.map NumV.ref) PRE_first_tail_x6_r0_body.kd7.big
    PRE_first_tail_x6_r0_body.kd7.region PRE_first_tail_x6_r0_body.kd7.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws7 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs7 : List SymE := PRE_first_tail_x6_r0_body.nr7.map fun r => (nth? PRE_first_tail_x6_r0_body.S83.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta7 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws7 PRE_first_tail_x6_r0_body.crs7
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB7 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab7 : PRE_first_tail_x6_r0_body.S84.tab = PRE_first_tail_x6_r0_body.S82.tab ++ PRE_first_tail_x6_r0_body.cws7.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace7 : PRE_first_tail_x6_r0_body.s84.trace = PRE_first_tail_x6_r0_body.s82.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext7 : PRE_first_tail_x6_r0_body.s84.next = 2680469
kernel_rfl PRE_first_tail_x6_r0_body.ccounters7 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx.nnext) = (18346, 15444)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue7 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s83.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa7.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp7 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx.tokens.all (bSN 380) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean7 : Conv.cleanListB 18346 131072 (fun r => Nat.ble 73384 r) PRE_first_tail_x6_r0_body.s84
    (PRE_first_tail_x6_r0_body.wrB7 ++ (List.range 0).map (2680469 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs7 : bigsOutB 18346 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl7`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl7 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo7 : List Nat := []
def PRE_first_tail_x6_r0_body.cln7 : List Nat := []
def PRE_first_tail_x6_r0_body.cli7 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap7 : PRE_first_tail_x6_r0_body.s84.heap = Stage.setAll PRE_first_tail_x6_r0_body.s82.heap (PRE_first_tail_x6_r0_body.cl7.filterMap fun a => (PRE_first_tail_x6_r0_body.s84.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe7 : Nat.ble PRE_first_tail_x6_r0_body.s82.next PRE_first_tail_x6_r0_body.s84.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP7 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s82 PRE_first_tail_x6_r0_body.s84 PRE_first_tail_x6_r0_body.cl7 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp7 : Conv.suppListB PRE_first_tail_x6_r0_body.s84 380 PRE_first_tail_x6_r0_body.cl7 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound7 : Conv.boundListB PRE_first_tail_x6_r0_body.s84 PRE_first_tail_x6_r0_body.cl7 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK7 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln7.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK7 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo7.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK7 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli7.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst7 : Conv.sstListB 380 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx PRE_first_tail_x6_r0_body.cln7 PRE_first_tail_x6_r0_body.clo7 PRE_first_tail_x6_r0_body.cli7 = true

end Host.Load.Run.Tpl
end

section -- SiteCl7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA7 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo7.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd7 : (PRE_first_tail_x6_r0_body.clo7 ++ PRE_first_tail_x6_r0_body.cln7 ++ PRE_first_tail_x6_r0_body.cli7).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle7 : Conv.Cnt.leB (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck7 : Conv.ncleanListB (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx PRE_first_tail_x6_r0_body.clo7 PRE_first_tail_x6_r0_body.cln7 PRE_first_tail_x6_r0_body.cli7 = true
theorem PRE_first_tail_x6_r0_body.cncl7 (h : Conv.NClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx) : Conv.NClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle7 PRE_first_tail_x6_r0_body.ckA7 PRE_first_tail_x6_r0_body.cobjsK7 PRE_first_tail_x6_r0_body.cnodesK7 PRE_first_tail_x6_r0_body.citemsK7 PRE_first_tail_x6_r0_body.cbd7 PRE_first_tail_x6_r0_body.cck7

end Host.Load.Run.Tpl
end

section -- SiteS7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 7 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc7 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P7 : LoadP := PRE_first_tail_x6_r0_body.Pc7.raise 15444
kernel_rfl PRE_first_tail_x6_r0_body.craise7 : Nat.ble PRE_first_tail_x6_r0_body.Pc7.N0 15444 = true
theorem PRE_first_tail_x6_r0_body.raised7 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc7 PRE_first_tail_x6_r0_body.P7 :=
  .inr ⟨15444, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise7, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_7 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_7 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s83.ffi)
def PRE_first_tail_x6_r0_body.khinv7 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv7 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS7 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS7 : List Nat := List.range' 15444 0
def PRE_first_tail_x6_r0_body.ciS7 : List Nat := [] ++ List.range' 15444 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh07 : PRE_first_tail_x6_r0_body.kd7.nh0 = PRE_first_tail_x6_r0_body.cx0_7.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh17 : PRE_first_tail_x6_r0_body.kd7.nh1 = PRE_first_tail_x6_r0_body.cx1_7.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn07 : PRE_first_tail_x6_r0_body.kd7.nn0 = PRE_first_tail_x6_r0_body.cx0_7.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn17 : PRE_first_tail_x6_r0_body.kd7.nn1 = PRE_first_tail_x6_r0_body.cx1_7.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo7 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P7.lo && Nat.ble PRE_first_tail_x6_r0_body.P7.lo PRE_first_tail_x6_r0_body.cx0_7.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P7.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P7.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt7 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_7.mlx.next PRE_first_tail_x6_r0_body.cx1_7.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_7.mlx.nnext PRE_first_tail_x6_r0_body.cx1_7.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband7 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P7.NL && Nat.ble PRE_first_tail_x6_r0_body.P7.NL PRE_first_tail_x6_r0_body.P7.N0 && Nat.ble PRE_first_tail_x6_r0_body.P7.N0 PRE_first_tail_x6_r0_body.cx0_7.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow7 : PRE_first_tail_x6_r0_body.kd7.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren7 : checkRenG PRE_first_tail_x6_r0_body.kd7.hnd PRE_first_tail_x6_r0_body.khinv7 (phB PRE_first_tail_x6_r0_body.cx0_7.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband7 : PRE_first_tail_x6_r0_body.kd7.checkBand PRE_first_tail_x6_r0_body.P7.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos7 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd7.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren7 : checkRenG PRE_first_tail_x6_r0_body.kd7.node PRE_first_tail_x6_r0_body.kninv7 (pnB PRE_first_tail_x6_r0_body.cx0_7.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow7 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd7.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P7.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd7.nodeF j) PRE_first_tail_x6_r0_body.cx1_7.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a7 : PRE_first_tail_x6_r0_body.cx0_7.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b7 : PRE_first_tail_x6_r0_body.cx0_7.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok17 : PRE_first_tail_x6_r0_body.cx1_7.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend7 : PRE_first_tail_x6_r0_body.cx1_7.mlx.pending = PRE_first_tail_x6_r0_body.cx0_7.mlx.pending.map PRE_first_tail_x6_r0_body.kappa7.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh7 : PRE_first_tail_x6_r0_body.cx1_7.mlx.errh = PRE_first_tail_x6_r0_body.cx0_7.mlx.errh.map PRE_first_tail_x6_r0_body.kappa7.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles7 : PRE_first_tail_x6_r0_body.cx1_7.mlx.files = PRE_first_tail_x6_r0_body.cx0_7.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch7 : PRE_first_tail_x6_r0_body.cx1_7.mlx.arch = PRE_first_tail_x6_r0_body.cx0_7.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes7 : PRE_first_tail_x6_r0_body.cx1_7.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_7.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired7 : PRE_first_tail_x6_r0_body.cx1_7.mlx.wired = PRE_first_tail_x6_r0_body.cx0_7.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost7 : PRE_first_tail_x6_r0_body.cx1_7.host = PRE_first_tail_x6_r0_body.cx0_7.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd7`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn07 : PRE_first_tail_x6_r0_body.kd7.n0 = 2680469
kernel_rfl PRE_first_tail_x6_r0_body.ckn17 : PRE_first_tail_x6_r0_body.kd7.n1 = 2680471
kernel_rfl PRE_first_tail_x6_r0_body.ckheap7 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd7.heap).all (fun x => Nat.ble 2680469 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl7 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd7.heap.get (2680469 + j) = nth? PRE_first_tail_x6_r0_body.pl7 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja7 : Nat.ble 2680469 2680469 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn7 : Nat.ble 380 380 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD7 : Nat.ble 2680469 PRE_first_tail_x6_r0_body.kd7.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn7 : Nat.ble 18346 PRE_first_tail_x6_r0_body.kd7.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn7 : Nat.ble 15444 PRE_first_tail_x6_r0_body.kd7.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb7 : Nat.ble 18346 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap7 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd7.heap).all (Nat.ble (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd7 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd7.hnd).all (Nat.ble (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode7 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd7.node).all (Nat.ble (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix7 : Conv.FixOld (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa7 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja7) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn7) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD7) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn7) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn7) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb7) PRE_first_tail_x6_r0_body.fheap7 PRE_first_tail_x6_r0_body.fhnd7 PRE_first_tail_x6_r0_body.fnode7
kernel_rfl PRE_first_tail_x6_r0_body.fcxn7 : (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn7 : (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle07 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_7.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_7.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk7 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd7.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A7 : PRE_first_tail_x6_r0_body.cx1_7.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS7.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_7.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O7 : PRE_first_tail_x6_r0_body.cx1_7.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS7.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_7.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N7 : PRE_first_tail_x6_r0_body.cx1_7.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS7.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_7.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I7 : PRE_first_tail_x6_r0_body.cx1_7.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS7.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_7.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd7 : (PRE_first_tail_x6_r0_body.clo7 ++ PRE_first_tail_x6_r0_body.cln7 ++ PRE_first_tail_x6_r0_body.cli7 ++ PRE_first_tail_x6_r0_body.cwS7 ++ PRE_first_tail_x6_r0_body.cnS7 ++ PRE_first_tail_x6_r0_body.ciS7).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW7 : PRE_first_tail_x6_r0_body.cwS7.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo7.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI7 : PRE_first_tail_x6_r0_body.ciS7.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli7.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN7 : PRE_first_tail_x6_r0_body.cnS7.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF7 : PRE_first_tail_x6_r0_body.cln7.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh7 : PRE_first_tail_x6_r0_body.clo7.all (handleOK PRE_first_tail_x6_r0_body.kappa7 PRE_first_tail_x6_r0_body.P7.lo PRE_first_tail_x6_r0_body.cx0_7.mlx PRE_first_tail_x6_r0_body.cx1_7.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo7 : PRE_first_tail_x6_r0_body.clo7.map (fun h => PRE_first_tail_x6_r0_body.cx1_7.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa7.handle h)) = PRE_first_tail_x6_r0_body.clo7.map (fun h => (PRE_first_tail_x6_r0_body.cx0_7.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa7.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok7 : PRE_first_tail_x6_r0_body.clo7.all (objOK PRE_first_tail_x6_r0_body.kappa7 PRE_first_tail_x6_r0_body.P7.NL PRE_first_tail_x6_r0_body.cx0_7.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd7 : PRE_first_tail_x6_r0_body.cln7.all (nodeOKF PRE_first_tail_x6_r0_body.kappa7 PRE_first_tail_x6_r0_body.P7 PRE_first_tail_x6_r0_body.cx0_7.mlx PRE_first_tail_x6_r0_body.cx1_7.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp7 : ((PRE_first_tail_x6_r0_body.cln7.filter (fullB PRE_first_tail_x6_r0_body.P7))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_7.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa7.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln7.filter (fullB PRE_first_tail_x6_r0_body.P7))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_7.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa7.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI7 : incrB PRE_first_tail_x6_r0_body.kd7.nodeF (List.range' 15444 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK7 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd7.node).all (fun k => Nat.ble 15444 k && Nat.blt k 15444) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL7 : (PRE_first_tail_x6_r0_body.cln7.filter (Nat.ble PRE_first_tail_x6_r0_body.P7.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd7.nodeF i) && (Nat.blt i 15444 || Nat.ble PRE_first_tail_x6_r0_body.kd7.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord7 : (PRE_first_tail_x6_r0_body.cln7.filter (Nat.ble PRE_first_tail_x6_r0_body.P7.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd7.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd7.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd7.nodeF j) (PRE_first_tail_x6_r0_body.kd7.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow7 PRE_first_tail_x6_r0_body.cnn17 PRE_first_tail_x6_r0_body.fnordI7 PRE_first_tail_x6_r0_body.fnordK7 PRE_first_tail_x6_r0_body.fnordL7
kernel_rfl PRE_first_tail_x6_r0_body.fi7 : PRE_first_tail_x6_r0_body.cli7.all (pnB PRE_first_tail_x6_r0_body.cx0_7.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii7 : PRE_first_tail_x6_r0_body.cli7.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_7.mlx.items.get (PRE_first_tail_x6_r0_body.kappa7.node k) = (PRE_first_tail_x6_r0_body.cx0_7.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa7.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot7 (clean : Conv.NClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P7.NL) (cl : SSt (· < 380) PRE_first_tail_x6_r0_body.cx0_7.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P7 380 PRE_first_tail_x6_r0_body.kappa7 PRE_first_tail_x6_r0_body.kd7 PRE_first_tail_x6_r0_body.khinv7 PRE_first_tail_x6_r0_body.kninv7 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx PRE_first_tail_x6_r0_body.cx0_7.mlx PRE_first_tail_x6_r0_body.cx1_7.mlx (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo7 PRE_first_tail_x6_r0_body.cln7 PRE_first_tail_x6_r0_body.cli7 PRE_first_tail_x6_r0_body.cwS7 PRE_first_tail_x6_r0_body.cnS7 PRE_first_tail_x6_r0_body.ciS7 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh07, PRE_first_tail_x6_r0_body.cnh17, PRE_first_tail_x6_r0_body.cnn07, PRE_first_tail_x6_r0_body.cnn17, PRE_first_tail_x6_r0_body.cplo7, PRE_first_tail_x6_r0_body.ccnt7, PRE_first_tail_x6_r0_body.cnband7, PRE_first_tail_x6_r0_body.chbelow7, PRE_first_tail_x6_r0_body.chren7, PRE_first_tail_x6_r0_body.cband7, PRE_first_tail_x6_r0_body.cnh1pos7, PRE_first_tail_x6_r0_body.cnren7, PRE_first_tail_x6_r0_body.cnlow7, PRE_first_tail_x6_r0_body.cabs0a7, PRE_first_tail_x6_r0_body.cabs0b7, PRE_first_tail_x6_r0_body.ctok17, PRE_first_tail_x6_r0_body.cpend7, PRE_first_tail_x6_r0_body.cerrh7, PRE_first_tail_x6_r0_body.cfiles7, PRE_first_tail_x6_r0_body.carch7, PRE_first_tail_x6_r0_body.csizes7, PRE_first_tail_x6_r0_body.cwired7, PRE_first_tail_x6_r0_body.cfix7, clean, PRE_first_tail_x6_r0_body.fcxn7, PRE_first_tail_x6_r0_body.fcnn7, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle07, PRE_first_tail_x6_r0_body.fnk7, PRE_first_tail_x6_r0_body.ckA7, PRE_first_tail_x6_r0_body.cobjsK7, PRE_first_tail_x6_r0_body.cnodesK7, PRE_first_tail_x6_r0_body.citemsK7, PRE_first_tail_x6_r0_body.f1A7, PRE_first_tail_x6_r0_body.f1O7, PRE_first_tail_x6_r0_body.f1N7, PRE_first_tail_x6_r0_body.f1I7, PRE_first_tail_x6_r0_body.fbd7, PRE_first_tail_x6_r0_body.fincW7, PRE_first_tail_x6_r0_body.fincI7, PRE_first_tail_x6_r0_body.fincN7, PRE_first_tail_x6_r0_body.flnF7, PRE_first_tail_x6_r0_body.fh7, PRE_first_tail_x6_r0_body.fo7, PRE_first_tail_x6_r0_body.fok7, PRE_first_tail_x6_r0_body.fnd7, PRE_first_tail_x6_r0_body.fp7, PRE_first_tail_x6_r0_body.fnord7, PRE_first_tail_x6_r0_body.fi7, PRE_first_tail_x6_r0_body.fii7⟩
theorem PRE_first_tail_x6_r0_body.cnshift7 (clean : Conv.NClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P7.NL) (cl : SSt (· < 380) PRE_first_tail_x6_r0_body.cx0_7.mlx) : NShift PRE_first_tail_x6_r0_body.P7 380 PRE_first_tail_x6_r0_body.kappa7 PRE_first_tail_x6_r0_body.cx0_7 PRE_first_tail_x6_r0_body.cx1_7 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot7 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost7 (compact_a_eq PRE_first_tail_x6_r0_body.ckn07 PRE_first_tail_x6_r0_body.ckn17 PRE_first_tail_x6_r0_body.ckheap7 PRE_first_tail_x6_r0_body.ckpl7)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_7 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s82.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_7 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s82.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_7 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s82.ffi) = some PRE_first_tail_x6_r0_body.fxC_7
kernel_rfl PRE_first_tail_x6_r0_body.okrC_7 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s82.ffi) = some PRE_first_tail_x6_r0_body.krC_7
noncomputable def PRE_first_tail_x6_r0_body.fx0_7 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s84.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_7 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s84.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_7 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s84.ffi) = some PRE_first_tail_x6_r0_body.fx0_7
kernel_rfl PRE_first_tail_x6_r0_body.okr0_7 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s84.ffi) = some PRE_first_tail_x6_r0_body.kr0_7
noncomputable def PRE_first_tail_x6_r0_body.fx1_7 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s83.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_7 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s83.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_7 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s83.ffi) = some PRE_first_tail_x6_r0_body.fx1_7
kernel_rfl PRE_first_tail_x6_r0_body.okr1_7 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s83.ffi) = some PRE_first_tail_x6_r0_body.kr1_7
kernel_rfl PRE_first_tail_x6_r0_body.ff07 : PRE_first_tail_x6_r0_body.fx0_7 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_7 (PRE_first_tail_x6_r0_body.clo7.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_7.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff17 : PRE_first_tail_x6_r0_body.fx1_7 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_7 (PRE_first_tail_x6_r0_body.cwS7.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_7.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck7 : freedLB PRE_first_tail_x6_r0_body.kappa7 PRE_first_tail_x6_r0_body.cx0_7.mlx PRE_first_tail_x6_r0_body.fx0_7 PRE_first_tail_x6_r0_body.fx1_7 PRE_first_tail_x6_r0_body.clo7 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf07 : PRE_first_tail_x6_r0_body.kr0_7.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_7.flags (PRE_first_tail_x6_r0_body.clo7.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_7.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt07 : PRE_first_tail_x6_r0_body.kr0_7.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_7.targs (PRE_first_tail_x6_r0_body.clo7.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_7.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf17 : PRE_first_tail_x6_r0_body.kr1_7.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_7.flags (PRE_first_tail_x6_r0_body.cwS7.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_7.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt17 : PRE_first_tail_x6_r0_body.kr1_7.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_7.targs (PRE_first_tail_x6_r0_body.cwS7.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_7.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck7 : krecLB PRE_first_tail_x6_r0_body.kappa7 380 PRE_first_tail_x6_r0_body.cx0_7.mlx PRE_first_tail_x6_r0_body.kr0_7 PRE_first_tail_x6_r0_body.kr1_7 PRE_first_tail_x6_r0_body.clo7 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn7 : Nat.ble 380 380 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge7 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s83.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s84.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR7 : pendRegB PRE_first_tail_x6_r0_body.kappa7 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe7 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s84.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s83.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift7 (clean : Conv.NClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P7.NL) (cl : SSt (· < 380) PRE_first_tail_x6_r0_body.cx0_7.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_7.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_7.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_7.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s82.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_7.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P7 380 PRE_first_tail_x6_r0_body.kappa7 PRE_first_tail_x6_r0_body.s84.ffi PRE_first_tail_x6_r0_body.s83.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift7 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue7, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp7 t ht),
    PRE_first_tail_x6_r0_body.cbridge7,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s84.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s83.ffi) (PRE_first_tail_x6_r0_body.cfoot7 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_7 PRE_first_tail_x6_r0_body.ofx1_7 hobjC PRE_first_tail_x6_r0_body.ff07 PRE_first_tail_x6_r0_body.ff17 PRE_first_tail_x6_r0_body.ffck7,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s84.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s83.ffi) (PRE_first_tail_x6_r0_body.cfoot7 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_7 PRE_first_tail_x6_r0_body.okr1_7 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn7) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf07 PRE_first_tail_x6_r0_body.fkt07 PRE_first_tail_x6_r0_body.fkf17 PRE_first_tail_x6_r0_body.fkt17 PRE_first_tail_x6_r0_body.fkck7,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh07 PRE_first_tail_x6_r0_body.cnh17 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe7) PRE_first_tail_x6_r0_body.cpendR7⟩

end Host.Load.Run.Tpl
end

section -- st7/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st7 0
host_stream_state PRE_first_tail_x6_r0_body.st7 1
host_stream_state PRE_first_tail_x6_r0_body.st7 2
end Host.Load.Run.Tpl
end

section -- Site7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 7 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g7__g8` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s82`, the merged state `PRE_first_tail_x6_r0_body.s83`,
the site template `PRE_first_tail_x6_r0_body.st7` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s84`: the merge.
The footprint's facts are in `SiteF7`, the compaction's in `SiteC7`, `SiteK7`, `SiteNa7`, `SiteNb7`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso7 : PRE_first_tail_x6_r0_body.st7.s0 = { PRE_first_tail_x6_r0_body.s82 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs7 : List Frame := PRE_first_tail_x6_r0_body.s82.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_7 : PRE_first_tail_x6_r0_body.S82.tab.length = 380
kernel_rfl PRE_first_tail_x6_r0_body.tab0_7 : PRE_first_tail_x6_r0_body.st7.S0.tab = PRE_first_tail_x6_r0_body.S82.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws7 : List Nat := [1163, 1164]
kernel_rfl PRE_first_tail_x6_r0_body.fresh7 : (PRE_first_tail_x6_r0_body.S82.tab.all fun e => PRE_first_tail_x6_r0_body.ws7.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S82.oracle.all fun q => PRE_first_tail_x6_r0_body.ws7.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab7 : PRE_first_tail_x6_r0_body.S83.tab = PRE_first_tail_x6_r0_body.S82.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws7
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen7 : PRE_first_tail_x6_r0_body.st7.S2.tab.length - PRE_first_tail_x6_r0_body.st7.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged7`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap7 : PRE_first_tail_x6_r0_body.s83.heap = PRE_first_tail_x6_r0_body.st7.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext7 : PRE_first_tail_x6_r0_body.s83.next = PRE_first_tail_x6_r0_body.st7.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl7 : PRE_first_tail_x6_r0_body.s83.ctl = PRE_first_tail_x6_r0_body.st7.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack7 : PRE_first_tail_x6_r0_body.s83.stack = PRE_first_tail_x6_r0_body.st7.s2.stack ++ PRE_first_tail_x6_r0_body.s82.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs7 : PRE_first_tail_x6_r0_body.s83.jobs = PRE_first_tail_x6_r0_body.st7.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi7 : PRE_first_tail_x6_r0_body.s83.ffi = PRE_first_tail_x6_r0_body.st7.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace7 : PRE_first_tail_x6_r0_body.s83.trace = PRE_first_tail_x6_r0_body.st7.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores7 : PRE_first_tail_x6_r0_body.s83.stores = PRE_first_tail_x6_r0_body.st7.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 7 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived7 : PRE_first_tail_x6_r0_body.nr7.map (fun r => nth? PRE_first_tail_x6_r0_body.st7.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo7 : PRE_first_tail_x6_r0_body.nr7.all (Nat.ble 380) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj7 : PRE_first_tail_x6_r0_body.cws7.all (fun c => !PRE_first_tail_x6_r0_body.ws7.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ7 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws7 PRE_first_tail_x6_r0_body.crs7 PRE_first_tail_x6_r0_body.ws7

end Host.Load.Run.Tpl
end

section -- st7/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st7`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st7.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st7.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st7.s2.heap PRE_first_tail_x6_r0_body.st7.wrR ++ freshOf PRE_first_tail_x6_r0_body.st7.s2.heap PRE_first_tail_x6_r0_body.st7.s0.next PRE_first_tail_x6_r0_body.st7.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st7.wr : List Nat := PRE_first_tail_x6_r0_body.st7.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st7.heapFoot : PRE_first_tail_x6_r0_body.st7.s2.heap = setAll PRE_first_tail_x6_r0_body.st7.s0.heap PRE_first_tail_x6_r0_body.st7.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st7.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st7.s0.next PRE_first_tail_x6_r0_body.st7.s2.next = true
theorem PRE_first_tail_x6_r0_body.st7.grows : PRE_first_tail_x6_r0_body.st7.s0.next ≤ PRE_first_tail_x6_r0_body.st7.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st7.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st7.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st7.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st7.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st7.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st7.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st7.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st7.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st7.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st7.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st7.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st7.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 7 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB7 : nodupT PRE_first_tail_x6_r0_body.st7.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup7 : PRE_first_tail_x6_r0_body.st7.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB7).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB7 : PRE_first_tail_x6_r0_body.st7.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound7 : ∀ b ∈ PRE_first_tail_x6_r0_body.st7.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB7 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr7 := PRE_first_tail_x6_r0_body.st7.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq7 : PRE_first_tail_x6_r0_body.st7.s2.trace = PRE_first_tail_x6_r0_body.trFr7 ++ PRE_first_tail_x6_r0_body.st7.s0.trace
theorem PRE_first_tail_x6_r0_body.trace7 : ∃ fr, PRE_first_tail_x6_r0_body.st7.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st7.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq7⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide7 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB7 : (PRE_first_tail_x6_r0_body.wide7.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st7.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix7 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide7, WFix Map.id (Present PRE_first_tail_x6_r0_body.st7.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB7 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 7 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s83`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO7 : PRE_first_tail_x6_r0_body.st7.S0.oracle = PRE_first_tail_x6_r0_body.st7.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B7 : PRE_first_tail_x6_r0_body.st7.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st7.s0.next || (PRE_first_tail_x6_r0_body.st7.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot7 : Conv.StageFoot PRE_first_tail_x6_r0_body.st7.wr PRE_first_tail_x6_r0_body.st7.s0 PRE_first_tail_x6_r0_body.st7.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st7.heapFoot PRE_first_tail_x6_r0_body.wrNodup7 PRE_first_tail_x6_r0_body.wrBound7 PRE_first_tail_x6_r0_body.wr0B7 PRE_first_tail_x6_r0_body.st7.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged7 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st7.F.S → PRE_first_tail_x6_r0_body.st7.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st7.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st7.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs7 PRE_first_tail_x6_r0_body.st7.wr PRE_first_tail_x6_r0_body.s82 PRE_first_tail_x6_r0_body.st7.s2 PRE_first_tail_x6_r0_body.st7.s0
      PRE_first_tail_x6_r0_body.st7.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st7.F FR W stk M ν K PRE_first_tail_x6_r0_body.s83 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso7 PRE_first_tail_x6_r0_body.stFoot7 PRE_first_tail_x6_r0_body.wrNodup7 PRE_first_tail_x6_r0_body.wrBound7 PRE_first_tail_x6_r0_body.trace7 PRE_first_tail_x6_r0_body.mheap7
    PRE_first_tail_x6_r0_body.mnext7 PRE_first_tail_x6_r0_body.mctl7 PRE_first_tail_x6_r0_body.mstack7 PRE_first_tail_x6_r0_body.mjobs7 PRE_first_tail_x6_r0_body.mffi7 PRE_first_tail_x6_r0_body.mtrace7 PRE_first_tail_x6_r0_body.mstores7 h

def PRE_first_tail_x6_r0_body.arrEl7_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE7_2665 : arrOf PRE_first_tail_x6_r0_body.s83 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl7_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA7_2665 : isArrB PRE_first_tail_x6_r0_body.s83 2665 = true
theorem PRE_first_tail_x6_r0_body.arr7_2665 : ∃ o, PRE_first_tail_x6_r0_body.s83.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl7_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE7_2665 PRE_first_tail_x6_r0_body.arrA7_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN7_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl7_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR7_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl7_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN7_2665

def PRE_first_tail_x6_r0_body.arrEl7_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE7_2673467 : arrOf PRE_first_tail_x6_r0_body.s83 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl7_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA7_2673467 : isArrB PRE_first_tail_x6_r0_body.s83 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr7_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s83.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl7_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE7_2673467 PRE_first_tail_x6_r0_body.arrA7_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN7_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl7_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR7_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl7_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN7_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k7 : isArrB PRE_first_tail_x6_r0_body.s83 4910 = false
theorem PRE_first_tail_x6_r0_body.keep7 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s83 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k7 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr7_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl7_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 7 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s82`, the merged
state `PRE_first_tail_x6_r0_body.s83`, the canonical state `PRE_first_tail_x6_r0_body.s84`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl7 : PRE_first_tail_x6_r0_body.pl7.all (Nat.ble PRE_first_tail_x6_r0_body.s82.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd7 : nodupT PRE_first_tail_x6_r0_body.pl7 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn17 : Nat.ble PRE_first_tail_x6_r0_body.s82.next 2680471 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst7 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s82.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn7 : PRE_first_tail_x6_r0_body.s84.next = PRE_first_tail_x6_r0_body.s82.next + PRE_first_tail_x6_r0_body.pl7.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn7 : PRE_first_tail_x6_r0_body.s83.next = 2680471
kernel_rfl PRE_first_tail_x6_r0_body.zgrow7 : Nat.ble PRE_first_tail_x6_r0_body.s84.next PRE_first_tail_x6_r0_body.s83.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh7 : PRE_first_tail_x6_r0_body.S82.tab.all (fun e => PRE_first_tail_x6_r0_body.cws7.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd7 : nodupT PRE_first_tail_x6_r0_body.cws7 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi7 : PRE_first_tail_x6_r0_body.nr7.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S83.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt7 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s82.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg7_2665 : PRE_first_tail_x6_r0_body.s84.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s84 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk7_2665 : (objOf PRE_first_tail_x6_r0_body.s84 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm7_2665 : PRE_first_tail_x6_r0_body.s83.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa7.obj (objOf PRE_first_tail_x6_r0_body.s84 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s83 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg7_2673467 : PRE_first_tail_x6_r0_body.s84.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s84 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk7_2673467 : (objOf PRE_first_tail_x6_r0_body.s84 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm7_2673467 : PRE_first_tail_x6_r0_body.s83.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa7.obj (objOf PRE_first_tail_x6_r0_body.s84 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s83 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw7_4910 : (PRE_first_tail_x6_r0_body.s84.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw7_2673472 : (PRE_first_tail_x6_r0_body.s84.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw7_2673473 : (PRE_first_tail_x6_r0_body.s84.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd7 : PRE_first_tail_x6_r0_body.cl7.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr7 : PRE_first_tail_x6_r0_body.st7.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s82.next || PRE_first_tail_x6_r0_body.cl7.contains b) = true
def PRE_first_tail_x6_r0_body.zl7 : List Nat := PRE_first_tail_x6_r0_body.cl7.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE7 : PRE_first_tail_x6_r0_body.zl7.map (fun a => PRE_first_tail_x6_r0_body.s83.heap.get (PRE_first_tail_x6_r0_body.kappa7.a a)) = PRE_first_tail_x6_r0_body.zl7.map (fun a => (PRE_first_tail_x6_r0_body.s84.heap.get a).map PRE_first_tail_x6_r0_body.kappa7.hobj)
theorem PRE_first_tail_x6_r0_body.zimg7 : HeapImg PRE_first_tail_x6_r0_body.kappa7 PRE_first_tail_x6_r0_body.s84 PRE_first_tail_x6_r0_body.s83 PRE_first_tail_x6_r0_body.zl7 := PRE_first_tail_x6_r0_body.zimgE7
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl7 : PRE_first_tail_x6_r0_body.s83.ctl = PRE_first_tail_x6_r0_body.kappa7.ctl PRE_first_tail_x6_r0_body.s84.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack7 : PRE_first_tail_x6_r0_body.s83.stack = PRE_first_tail_x6_r0_body.s84.stack.map PRE_first_tail_x6_r0_body.kappa7.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs7 : PRE_first_tail_x6_r0_body.s83.jobs = PRE_first_tail_x6_r0_body.s84.jobs.map PRE_first_tail_x6_r0_body.kappa7.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores7 : PRE_first_tail_x6_r0_body.s83.stores = PRE_first_tail_x6_r0_body.kappa7.stores PRE_first_tail_x6_r0_body.s84.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots7 : checkRootsSupp PRE_first_tail_x6_r0_body.s84 380 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC7 : PRE_first_tail_x6_r0_body.S82.tab.length + PRE_first_tail_x6_r0_body.cws7.length = 380
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap7 : PRE_first_tail_x6_r0_body.kappa7 = Conv.Map.compact PRE_first_tail_x6_r0_body.s82.next 2680471 PRE_first_tail_x6_r0_body.S82.tab.length PRE_first_tail_x6_r0_body.pl7 (PRE_first_tail_x6_r0_body.nr7.map NumV.ref) PRE_first_tail_x6_r0_body.kd7.big
  PRE_first_tail_x6_r0_body.kd7.region PRE_first_tail_x6_r0_body.kd7.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin7 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s84.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc7 : Conv.jcleanListB (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s84 PRE_first_tail_x6_r0_body.cl7 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB7 : noBigRootsP (fun i => !Conv.oldBigB (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s84.trace PRE_first_tail_x6_r0_body.s84 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm7 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15444 = true
theorem PRE_first_tail_x6_r0_body.cjcl7 (h : Conv.JClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s82) : Conv.JClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s84 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle7)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap7 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd7 a ha)) PRE_first_tail_x6_r0_body.zjc7

end Host.Load.Run.Tpl
end

section -- st7/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st7.bodyLast from PRE_first_tail_x6_r0_body.st7.s1 to PRE_first_tail_x6_r0_body.st7.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st7.F PRE_first_tail_x6_r0_body.st7.s1).run PRE_first_tail_x6_r0_body.st7.S1 = some (PRE_first_tail_x6_r0_body.st7.s2, PRE_first_tail_x6_r0_body.st7.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st7.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st7.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st7.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st7.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st7/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st7.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st7.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st7.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st7.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st7.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st7.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st7.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st7.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st7.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st7.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st7.s0 PRE_first_tail_x6_r0_body.st7.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st7.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st7.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st7.s1 PRE_first_tail_x6_r0_body.st7.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st7/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st7.bodyK0F from PRE_first_tail_x6_r0_body.st7.s0 to PRE_first_tail_x6_r0_body.st7.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st7.F (PRE_first_tail_x6_r0_body.st7.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st7.ks 0).getD 0) PRE_first_tail_x6_r0_body.st7.s0 PRE_first_tail_x6_r0_body.st7.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st7.s1, PRE_first_tail_x6_r0_body.st7.S1)
theorem PRE_first_tail_x6_r0_body.st7.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st7.F (PRE_first_tail_x6_r0_body.st7.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st7.ks 0).getD 0) PRE_first_tail_x6_r0_body.st7.s0 PRE_first_tail_x6_r0_body.st7.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st7.s1, PRE_first_tail_x6_r0_body.st7.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st7.bodyOkLN_ok PRE_first_tail_x6_r0_body.st7.bodyK0F
end Host.Load.Run.Tpl
end

section -- st7/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st7.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st7.F (PRE_first_tail_x6_r0_body.st7.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st7.s0 PRE_first_tail_x6_r0_body.st7.S0 = some (PRE_first_tail_x6_r0_body.st7.s1, PRE_first_tail_x6_r0_body.st7.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st7.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st7.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st7.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st7.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st7.F (PRE_first_tail_x6_r0_body.st7.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st7.s0
  S0 := PRE_first_tail_x6_r0_body.st7.S0
  s1 := PRE_first_tail_x6_r0_body.st7.s1
  S1 := PRE_first_tail_x6_r0_body.st7.S1
  s2 := PRE_first_tail_x6_r0_body.st7.s2
  S2 := PRE_first_tail_x6_r0_body.st7.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st7.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st7.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st7.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st7.bodyHalt
  last := PRE_first_tail_x6_r0_body.st7.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st7.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC8
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 8 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s88` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa8` into the merged state
`PRE_first_tail_x6_r0_body.s87`. -/

def PRE_first_tail_x6_r0_body.pl8 : List Nat := [2680767]
def PRE_first_tail_x6_r0_body.nr8 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd8 : RData :=
  ⟨2680758, 2680768, Stage.setAll PTrie.nil [(2680757, 2680767)], Stage.setAll PTrie.nil [],
   18353, 18353, 15448, 15448, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa8 : Map :=
  Conv.Map.compact 2680757 2680768 397 PRE_first_tail_x6_r0_body.pl8 (PRE_first_tail_x6_r0_body.nr8.map NumV.ref) PRE_first_tail_x6_r0_body.kd8.big
    PRE_first_tail_x6_r0_body.kd8.region PRE_first_tail_x6_r0_body.kd8.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws8 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs8 : List SymE := PRE_first_tail_x6_r0_body.nr8.map fun r => (nth? PRE_first_tail_x6_r0_body.S87.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta8 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws8 PRE_first_tail_x6_r0_body.crs8
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB8 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab8 : PRE_first_tail_x6_r0_body.S88.tab = PRE_first_tail_x6_r0_body.S86.tab ++ PRE_first_tail_x6_r0_body.cws8.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace8 : PRE_first_tail_x6_r0_body.s88.trace = PRE_first_tail_x6_r0_body.s86.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext8 : PRE_first_tail_x6_r0_body.s88.next = 2680758
kernel_rfl PRE_first_tail_x6_r0_body.ccounters8 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx.nnext) = (18353, 15448)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue8 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s87.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa8.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp8 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx.tokens.all (bSN 397) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean8 : Conv.cleanListB 18353 131072 (fun r => Nat.ble 73412 r) PRE_first_tail_x6_r0_body.s88
    (PRE_first_tail_x6_r0_body.wrB8 ++ (List.range 1).map (2680757 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs8 : bigsOutB 18353 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK8
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl8`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl8 : List Nat := [2665, 2673467, 2680757]
def PRE_first_tail_x6_r0_body.clo8 : List Nat := []
def PRE_first_tail_x6_r0_body.cln8 : List Nat := []
def PRE_first_tail_x6_r0_body.cli8 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap8 : PRE_first_tail_x6_r0_body.s88.heap = Stage.setAll PRE_first_tail_x6_r0_body.s86.heap (PRE_first_tail_x6_r0_body.cl8.filterMap fun a => (PRE_first_tail_x6_r0_body.s88.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe8 : Nat.ble PRE_first_tail_x6_r0_body.s86.next PRE_first_tail_x6_r0_body.s88.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP8 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s86 PRE_first_tail_x6_r0_body.s88 PRE_first_tail_x6_r0_body.cl8 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp8 : Conv.suppListB PRE_first_tail_x6_r0_body.s88 397 PRE_first_tail_x6_r0_body.cl8 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound8 : Conv.boundListB PRE_first_tail_x6_r0_body.s88 PRE_first_tail_x6_r0_body.cl8 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK8 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln8.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK8 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo8.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK8 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli8.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst8 : Conv.sstListB 397 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx PRE_first_tail_x6_r0_body.cln8 PRE_first_tail_x6_r0_body.clo8 PRE_first_tail_x6_r0_body.cli8 = true

end Host.Load.Run.Tpl
end

section -- SiteCl8
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA8 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo8.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd8 : (PRE_first_tail_x6_r0_body.clo8 ++ PRE_first_tail_x6_r0_body.cln8 ++ PRE_first_tail_x6_r0_body.cli8).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle8 : Conv.Cnt.leB (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck8 : Conv.ncleanListB (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx PRE_first_tail_x6_r0_body.clo8 PRE_first_tail_x6_r0_body.cln8 PRE_first_tail_x6_r0_body.cli8 = true
theorem PRE_first_tail_x6_r0_body.cncl8 (h : Conv.NClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx) : Conv.NClean (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle8 PRE_first_tail_x6_r0_body.ckA8 PRE_first_tail_x6_r0_body.cobjsK8 PRE_first_tail_x6_r0_body.cnodesK8 PRE_first_tail_x6_r0_body.citemsK8 PRE_first_tail_x6_r0_body.cbd8 PRE_first_tail_x6_r0_body.cck8

end Host.Load.Run.Tpl
end

section -- SiteS8
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 8 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc8 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P8 : LoadP := PRE_first_tail_x6_r0_body.Pc8.raise 15448
kernel_rfl PRE_first_tail_x6_r0_body.craise8 : Nat.ble PRE_first_tail_x6_r0_body.Pc8.N0 15448 = true
theorem PRE_first_tail_x6_r0_body.raised8 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc8 PRE_first_tail_x6_r0_body.P8 :=
  .inr ⟨15448, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise8, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_8 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_8 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s87.ffi)
def PRE_first_tail_x6_r0_body.khinv8 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv8 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS8 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS8 : List Nat := List.range' 15448 0
def PRE_first_tail_x6_r0_body.ciS8 : List Nat := [] ++ List.range' 15448 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh08 : PRE_first_tail_x6_r0_body.kd8.nh0 = PRE_first_tail_x6_r0_body.cx0_8.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh18 : PRE_first_tail_x6_r0_body.kd8.nh1 = PRE_first_tail_x6_r0_body.cx1_8.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn08 : PRE_first_tail_x6_r0_body.kd8.nn0 = PRE_first_tail_x6_r0_body.cx0_8.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn18 : PRE_first_tail_x6_r0_body.kd8.nn1 = PRE_first_tail_x6_r0_body.cx1_8.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo8 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P8.lo && Nat.ble PRE_first_tail_x6_r0_body.P8.lo PRE_first_tail_x6_r0_body.cx0_8.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P8.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P8.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt8 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_8.mlx.next PRE_first_tail_x6_r0_body.cx1_8.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_8.mlx.nnext PRE_first_tail_x6_r0_body.cx1_8.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband8 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P8.NL && Nat.ble PRE_first_tail_x6_r0_body.P8.NL PRE_first_tail_x6_r0_body.P8.N0 && Nat.ble PRE_first_tail_x6_r0_body.P8.N0 PRE_first_tail_x6_r0_body.cx0_8.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow8 : PRE_first_tail_x6_r0_body.kd8.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren8 : checkRenG PRE_first_tail_x6_r0_body.kd8.hnd PRE_first_tail_x6_r0_body.khinv8 (phB PRE_first_tail_x6_r0_body.cx0_8.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband8 : PRE_first_tail_x6_r0_body.kd8.checkBand PRE_first_tail_x6_r0_body.P8.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos8 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd8.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren8 : checkRenG PRE_first_tail_x6_r0_body.kd8.node PRE_first_tail_x6_r0_body.kninv8 (pnB PRE_first_tail_x6_r0_body.cx0_8.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow8 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd8.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P8.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd8.nodeF j) PRE_first_tail_x6_r0_body.cx1_8.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a8 : PRE_first_tail_x6_r0_body.cx0_8.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b8 : PRE_first_tail_x6_r0_body.cx0_8.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok18 : PRE_first_tail_x6_r0_body.cx1_8.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend8 : PRE_first_tail_x6_r0_body.cx1_8.mlx.pending = PRE_first_tail_x6_r0_body.cx0_8.mlx.pending.map PRE_first_tail_x6_r0_body.kappa8.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh8 : PRE_first_tail_x6_r0_body.cx1_8.mlx.errh = PRE_first_tail_x6_r0_body.cx0_8.mlx.errh.map PRE_first_tail_x6_r0_body.kappa8.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles8 : PRE_first_tail_x6_r0_body.cx1_8.mlx.files = PRE_first_tail_x6_r0_body.cx0_8.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch8 : PRE_first_tail_x6_r0_body.cx1_8.mlx.arch = PRE_first_tail_x6_r0_body.cx0_8.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes8 : PRE_first_tail_x6_r0_body.cx1_8.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_8.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired8 : PRE_first_tail_x6_r0_body.cx1_8.mlx.wired = PRE_first_tail_x6_r0_body.cx0_8.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost8 : PRE_first_tail_x6_r0_body.cx1_8.host = PRE_first_tail_x6_r0_body.cx0_8.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd8`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn08 : PRE_first_tail_x6_r0_body.kd8.n0 = 2680758
kernel_rfl PRE_first_tail_x6_r0_body.ckn18 : PRE_first_tail_x6_r0_body.kd8.n1 = 2680768
kernel_rfl PRE_first_tail_x6_r0_body.ckheap8 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd8.heap).all (fun x => Nat.ble 2680757 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl8 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd8.heap.get (2680757 + j) = nth? PRE_first_tail_x6_r0_body.pl8 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja8 : Nat.ble 2680757 2680757 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn8 : Nat.ble 397 397 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD8 : Nat.ble 2680757 PRE_first_tail_x6_r0_body.kd8.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn8 : Nat.ble 18353 PRE_first_tail_x6_r0_body.kd8.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn8 : Nat.ble 15448 PRE_first_tail_x6_r0_body.kd8.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb8 : Nat.ble 18353 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap8 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd8.heap).all (Nat.ble (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd8 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd8.hnd).all (Nat.ble (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode8 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd8.node).all (Nat.ble (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix8 : Conv.FixOld (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa8 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja8) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn8) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD8) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn8) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn8) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb8) PRE_first_tail_x6_r0_body.fheap8 PRE_first_tail_x6_r0_body.fhnd8 PRE_first_tail_x6_r0_body.fnode8
kernel_rfl PRE_first_tail_x6_r0_body.fcxn8 : (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn8 : (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle08 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_8.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_8.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk8 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd8.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A8 : PRE_first_tail_x6_r0_body.cx1_8.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS8.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_8.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O8 : PRE_first_tail_x6_r0_body.cx1_8.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS8.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_8.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N8 : PRE_first_tail_x6_r0_body.cx1_8.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS8.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_8.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I8 : PRE_first_tail_x6_r0_body.cx1_8.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS8.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_8.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd8 : (PRE_first_tail_x6_r0_body.clo8 ++ PRE_first_tail_x6_r0_body.cln8 ++ PRE_first_tail_x6_r0_body.cli8 ++ PRE_first_tail_x6_r0_body.cwS8 ++ PRE_first_tail_x6_r0_body.cnS8 ++ PRE_first_tail_x6_r0_body.ciS8).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW8 : PRE_first_tail_x6_r0_body.cwS8.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo8.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI8 : PRE_first_tail_x6_r0_body.ciS8.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli8.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN8 : PRE_first_tail_x6_r0_body.cnS8.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF8 : PRE_first_tail_x6_r0_body.cln8.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh8 : PRE_first_tail_x6_r0_body.clo8.all (handleOK PRE_first_tail_x6_r0_body.kappa8 PRE_first_tail_x6_r0_body.P8.lo PRE_first_tail_x6_r0_body.cx0_8.mlx PRE_first_tail_x6_r0_body.cx1_8.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo8 : PRE_first_tail_x6_r0_body.clo8.map (fun h => PRE_first_tail_x6_r0_body.cx1_8.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa8.handle h)) = PRE_first_tail_x6_r0_body.clo8.map (fun h => (PRE_first_tail_x6_r0_body.cx0_8.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa8.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok8 : PRE_first_tail_x6_r0_body.clo8.all (objOK PRE_first_tail_x6_r0_body.kappa8 PRE_first_tail_x6_r0_body.P8.NL PRE_first_tail_x6_r0_body.cx0_8.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd8 : PRE_first_tail_x6_r0_body.cln8.all (nodeOKF PRE_first_tail_x6_r0_body.kappa8 PRE_first_tail_x6_r0_body.P8 PRE_first_tail_x6_r0_body.cx0_8.mlx PRE_first_tail_x6_r0_body.cx1_8.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp8 : ((PRE_first_tail_x6_r0_body.cln8.filter (fullB PRE_first_tail_x6_r0_body.P8))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_8.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa8.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln8.filter (fullB PRE_first_tail_x6_r0_body.P8))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_8.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa8.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI8 : incrB PRE_first_tail_x6_r0_body.kd8.nodeF (List.range' 15448 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK8 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd8.node).all (fun k => Nat.ble 15448 k && Nat.blt k 15448) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL8 : (PRE_first_tail_x6_r0_body.cln8.filter (Nat.ble PRE_first_tail_x6_r0_body.P8.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd8.nodeF i) && (Nat.blt i 15448 || Nat.ble PRE_first_tail_x6_r0_body.kd8.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord8 : (PRE_first_tail_x6_r0_body.cln8.filter (Nat.ble PRE_first_tail_x6_r0_body.P8.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd8.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd8.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd8.nodeF j) (PRE_first_tail_x6_r0_body.kd8.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow8 PRE_first_tail_x6_r0_body.cnn18 PRE_first_tail_x6_r0_body.fnordI8 PRE_first_tail_x6_r0_body.fnordK8 PRE_first_tail_x6_r0_body.fnordL8
kernel_rfl PRE_first_tail_x6_r0_body.fi8 : PRE_first_tail_x6_r0_body.cli8.all (pnB PRE_first_tail_x6_r0_body.cx0_8.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii8 : PRE_first_tail_x6_r0_body.cli8.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_8.mlx.items.get (PRE_first_tail_x6_r0_body.kappa8.node k) = (PRE_first_tail_x6_r0_body.cx0_8.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa8.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot8 (clean : Conv.NClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P8.NL) (cl : SSt (· < 397) PRE_first_tail_x6_r0_body.cx0_8.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P8 397 PRE_first_tail_x6_r0_body.kappa8 PRE_first_tail_x6_r0_body.kd8 PRE_first_tail_x6_r0_body.khinv8 PRE_first_tail_x6_r0_body.kninv8 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx PRE_first_tail_x6_r0_body.cx0_8.mlx PRE_first_tail_x6_r0_body.cx1_8.mlx (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo8 PRE_first_tail_x6_r0_body.cln8 PRE_first_tail_x6_r0_body.cli8 PRE_first_tail_x6_r0_body.cwS8 PRE_first_tail_x6_r0_body.cnS8 PRE_first_tail_x6_r0_body.ciS8 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh08, PRE_first_tail_x6_r0_body.cnh18, PRE_first_tail_x6_r0_body.cnn08, PRE_first_tail_x6_r0_body.cnn18, PRE_first_tail_x6_r0_body.cplo8, PRE_first_tail_x6_r0_body.ccnt8, PRE_first_tail_x6_r0_body.cnband8, PRE_first_tail_x6_r0_body.chbelow8, PRE_first_tail_x6_r0_body.chren8, PRE_first_tail_x6_r0_body.cband8, PRE_first_tail_x6_r0_body.cnh1pos8, PRE_first_tail_x6_r0_body.cnren8, PRE_first_tail_x6_r0_body.cnlow8, PRE_first_tail_x6_r0_body.cabs0a8, PRE_first_tail_x6_r0_body.cabs0b8, PRE_first_tail_x6_r0_body.ctok18, PRE_first_tail_x6_r0_body.cpend8, PRE_first_tail_x6_r0_body.cerrh8, PRE_first_tail_x6_r0_body.cfiles8, PRE_first_tail_x6_r0_body.carch8, PRE_first_tail_x6_r0_body.csizes8, PRE_first_tail_x6_r0_body.cwired8, PRE_first_tail_x6_r0_body.cfix8, clean, PRE_first_tail_x6_r0_body.fcxn8, PRE_first_tail_x6_r0_body.fcnn8, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle08, PRE_first_tail_x6_r0_body.fnk8, PRE_first_tail_x6_r0_body.ckA8, PRE_first_tail_x6_r0_body.cobjsK8, PRE_first_tail_x6_r0_body.cnodesK8, PRE_first_tail_x6_r0_body.citemsK8, PRE_first_tail_x6_r0_body.f1A8, PRE_first_tail_x6_r0_body.f1O8, PRE_first_tail_x6_r0_body.f1N8, PRE_first_tail_x6_r0_body.f1I8, PRE_first_tail_x6_r0_body.fbd8, PRE_first_tail_x6_r0_body.fincW8, PRE_first_tail_x6_r0_body.fincI8, PRE_first_tail_x6_r0_body.fincN8, PRE_first_tail_x6_r0_body.flnF8, PRE_first_tail_x6_r0_body.fh8, PRE_first_tail_x6_r0_body.fo8, PRE_first_tail_x6_r0_body.fok8, PRE_first_tail_x6_r0_body.fnd8, PRE_first_tail_x6_r0_body.fp8, PRE_first_tail_x6_r0_body.fnord8, PRE_first_tail_x6_r0_body.fi8, PRE_first_tail_x6_r0_body.fii8⟩
theorem PRE_first_tail_x6_r0_body.cnshift8 (clean : Conv.NClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P8.NL) (cl : SSt (· < 397) PRE_first_tail_x6_r0_body.cx0_8.mlx) : NShift PRE_first_tail_x6_r0_body.P8 397 PRE_first_tail_x6_r0_body.kappa8 PRE_first_tail_x6_r0_body.cx0_8 PRE_first_tail_x6_r0_body.cx1_8 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot8 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost8 (compact_a_eq PRE_first_tail_x6_r0_body.ckn08 PRE_first_tail_x6_r0_body.ckn18 PRE_first_tail_x6_r0_body.ckheap8 PRE_first_tail_x6_r0_body.ckpl8)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_8 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s86.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_8 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s86.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_8 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s86.ffi) = some PRE_first_tail_x6_r0_body.fxC_8
kernel_rfl PRE_first_tail_x6_r0_body.okrC_8 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s86.ffi) = some PRE_first_tail_x6_r0_body.krC_8
noncomputable def PRE_first_tail_x6_r0_body.fx0_8 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s88.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_8 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s88.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_8 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s88.ffi) = some PRE_first_tail_x6_r0_body.fx0_8
kernel_rfl PRE_first_tail_x6_r0_body.okr0_8 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s88.ffi) = some PRE_first_tail_x6_r0_body.kr0_8
noncomputable def PRE_first_tail_x6_r0_body.fx1_8 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s87.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_8 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s87.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_8 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s87.ffi) = some PRE_first_tail_x6_r0_body.fx1_8
kernel_rfl PRE_first_tail_x6_r0_body.okr1_8 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s87.ffi) = some PRE_first_tail_x6_r0_body.kr1_8
kernel_rfl PRE_first_tail_x6_r0_body.ff08 : PRE_first_tail_x6_r0_body.fx0_8 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_8 (PRE_first_tail_x6_r0_body.clo8.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_8.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff18 : PRE_first_tail_x6_r0_body.fx1_8 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_8 (PRE_first_tail_x6_r0_body.cwS8.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_8.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck8 : freedLB PRE_first_tail_x6_r0_body.kappa8 PRE_first_tail_x6_r0_body.cx0_8.mlx PRE_first_tail_x6_r0_body.fx0_8 PRE_first_tail_x6_r0_body.fx1_8 PRE_first_tail_x6_r0_body.clo8 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf08 : PRE_first_tail_x6_r0_body.kr0_8.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_8.flags (PRE_first_tail_x6_r0_body.clo8.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_8.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt08 : PRE_first_tail_x6_r0_body.kr0_8.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_8.targs (PRE_first_tail_x6_r0_body.clo8.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_8.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf18 : PRE_first_tail_x6_r0_body.kr1_8.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_8.flags (PRE_first_tail_x6_r0_body.cwS8.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_8.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt18 : PRE_first_tail_x6_r0_body.kr1_8.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_8.targs (PRE_first_tail_x6_r0_body.cwS8.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_8.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck8 : krecLB PRE_first_tail_x6_r0_body.kappa8 397 PRE_first_tail_x6_r0_body.cx0_8.mlx PRE_first_tail_x6_r0_body.kr0_8 PRE_first_tail_x6_r0_body.kr1_8 PRE_first_tail_x6_r0_body.clo8 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn8 : Nat.ble 397 397 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge8 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s87.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s88.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR8 : pendRegB PRE_first_tail_x6_r0_body.kappa8 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe8 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s88.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s87.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift8 (clean : Conv.NClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P8.NL) (cl : SSt (· < 397) PRE_first_tail_x6_r0_body.cx0_8.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_8.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_8.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_8.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s86.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_8.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P8 397 PRE_first_tail_x6_r0_body.kappa8 PRE_first_tail_x6_r0_body.s88.ffi PRE_first_tail_x6_r0_body.s87.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift8 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue8, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp8 t ht),
    PRE_first_tail_x6_r0_body.cbridge8,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s88.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s87.ffi) (PRE_first_tail_x6_r0_body.cfoot8 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_8 PRE_first_tail_x6_r0_body.ofx1_8 hobjC PRE_first_tail_x6_r0_body.ff08 PRE_first_tail_x6_r0_body.ff18 PRE_first_tail_x6_r0_body.ffck8,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s88.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s87.ffi) (PRE_first_tail_x6_r0_body.cfoot8 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_8 PRE_first_tail_x6_r0_body.okr1_8 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn8) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf08 PRE_first_tail_x6_r0_body.fkt08 PRE_first_tail_x6_r0_body.fkf18 PRE_first_tail_x6_r0_body.fkt18 PRE_first_tail_x6_r0_body.fkck8,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh08 PRE_first_tail_x6_r0_body.cnh18 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe8) PRE_first_tail_x6_r0_body.cpendR8⟩

end Host.Load.Run.Tpl
end

section -- st8/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st8 0
host_stream_state PRE_first_tail_x6_r0_body.st8 1
host_stream_state PRE_first_tail_x6_r0_body.st8 2
end Host.Load.Run.Tpl
end

section -- Site8
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 8 of chain `PRE_first_tail_x6_r0_body`: `plan__g8__g9` (`plan`), the call state `PRE_first_tail_x6_r0_body.s86`, the merged state `PRE_first_tail_x6_r0_body.s87`,
the site template `PRE_first_tail_x6_r0_body.st8` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s88`: the merge.
The footprint's facts are in `SiteF8`, the compaction's in `SiteC8`, `SiteK8`, `SiteNa8`, `SiteNb8`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso8 : PRE_first_tail_x6_r0_body.st8.s0 = { PRE_first_tail_x6_r0_body.s86 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs8 : List Frame := PRE_first_tail_x6_r0_body.s86.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_8 : PRE_first_tail_x6_r0_body.S86.tab.length = 397
kernel_rfl PRE_first_tail_x6_r0_body.tab0_8 : PRE_first_tail_x6_r0_body.st8.S0.tab = PRE_first_tail_x6_r0_body.S86.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws8 : List Nat := [1165, 1166, 1167]
kernel_rfl PRE_first_tail_x6_r0_body.fresh8 : (PRE_first_tail_x6_r0_body.S86.tab.all fun e => PRE_first_tail_x6_r0_body.ws8.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S86.oracle.all fun q => PRE_first_tail_x6_r0_body.ws8.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab8 : PRE_first_tail_x6_r0_body.S87.tab = PRE_first_tail_x6_r0_body.S86.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws8
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen8 : PRE_first_tail_x6_r0_body.st8.S2.tab.length - PRE_first_tail_x6_r0_body.st8.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged8`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap8 : PRE_first_tail_x6_r0_body.s87.heap = PRE_first_tail_x6_r0_body.st8.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext8 : PRE_first_tail_x6_r0_body.s87.next = PRE_first_tail_x6_r0_body.st8.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl8 : PRE_first_tail_x6_r0_body.s87.ctl = PRE_first_tail_x6_r0_body.st8.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack8 : PRE_first_tail_x6_r0_body.s87.stack = PRE_first_tail_x6_r0_body.st8.s2.stack ++ PRE_first_tail_x6_r0_body.s86.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs8 : PRE_first_tail_x6_r0_body.s87.jobs = PRE_first_tail_x6_r0_body.st8.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi8 : PRE_first_tail_x6_r0_body.s87.ffi = PRE_first_tail_x6_r0_body.st8.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace8 : PRE_first_tail_x6_r0_body.s87.trace = PRE_first_tail_x6_r0_body.st8.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores8 : PRE_first_tail_x6_r0_body.s87.stores = PRE_first_tail_x6_r0_body.st8.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD8
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 8 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived8 : PRE_first_tail_x6_r0_body.nr8.map (fun r => nth? PRE_first_tail_x6_r0_body.st8.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo8 : PRE_first_tail_x6_r0_body.nr8.all (Nat.ble 397) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj8 : PRE_first_tail_x6_r0_body.cws8.all (fun c => !PRE_first_tail_x6_r0_body.ws8.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ8 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws8 PRE_first_tail_x6_r0_body.crs8 PRE_first_tail_x6_r0_body.ws8

end Host.Load.Run.Tpl
end

section -- st8/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st8`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st8.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st8.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st8.s2.heap PRE_first_tail_x6_r0_body.st8.wrR ++ freshOf PRE_first_tail_x6_r0_body.st8.s2.heap PRE_first_tail_x6_r0_body.st8.s0.next PRE_first_tail_x6_r0_body.st8.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st8.wr : List Nat := PRE_first_tail_x6_r0_body.st8.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st8.heapFoot : PRE_first_tail_x6_r0_body.st8.s2.heap = setAll PRE_first_tail_x6_r0_body.st8.s0.heap PRE_first_tail_x6_r0_body.st8.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st8.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st8.s0.next PRE_first_tail_x6_r0_body.st8.s2.next = true
theorem PRE_first_tail_x6_r0_body.st8.grows : PRE_first_tail_x6_r0_body.st8.s0.next ≤ PRE_first_tail_x6_r0_body.st8.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st8.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st8.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st8.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st8.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st8.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st8.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st8.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st8.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st8.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st8.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st8.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st8.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF8
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 8 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB8 : nodupT PRE_first_tail_x6_r0_body.st8.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup8 : PRE_first_tail_x6_r0_body.st8.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB8).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB8 : PRE_first_tail_x6_r0_body.st8.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound8 : ∀ b ∈ PRE_first_tail_x6_r0_body.st8.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB8 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr8 := PRE_first_tail_x6_r0_body.st8.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq8 : PRE_first_tail_x6_r0_body.st8.s2.trace = PRE_first_tail_x6_r0_body.trFr8 ++ PRE_first_tail_x6_r0_body.st8.s0.trace
theorem PRE_first_tail_x6_r0_body.trace8 : ∃ fr, PRE_first_tail_x6_r0_body.st8.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st8.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq8⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide8 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB8 : (PRE_first_tail_x6_r0_body.wide8.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st8.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix8 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide8, WFix Map.id (Present PRE_first_tail_x6_r0_body.st8.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB8 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL8
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 8 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s87`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO8 : PRE_first_tail_x6_r0_body.st8.S0.oracle = PRE_first_tail_x6_r0_body.st8.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B8 : PRE_first_tail_x6_r0_body.st8.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st8.s0.next || (PRE_first_tail_x6_r0_body.st8.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot8 : Conv.StageFoot PRE_first_tail_x6_r0_body.st8.wr PRE_first_tail_x6_r0_body.st8.s0 PRE_first_tail_x6_r0_body.st8.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st8.heapFoot PRE_first_tail_x6_r0_body.wrNodup8 PRE_first_tail_x6_r0_body.wrBound8 PRE_first_tail_x6_r0_body.wr0B8 PRE_first_tail_x6_r0_body.st8.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged8 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st8.F.S → PRE_first_tail_x6_r0_body.st8.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st8.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st8.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs8 PRE_first_tail_x6_r0_body.st8.wr PRE_first_tail_x6_r0_body.s86 PRE_first_tail_x6_r0_body.st8.s2 PRE_first_tail_x6_r0_body.st8.s0
      PRE_first_tail_x6_r0_body.st8.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st8.F FR W stk M ν K PRE_first_tail_x6_r0_body.s87 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso8 PRE_first_tail_x6_r0_body.stFoot8 PRE_first_tail_x6_r0_body.wrNodup8 PRE_first_tail_x6_r0_body.wrBound8 PRE_first_tail_x6_r0_body.trace8 PRE_first_tail_x6_r0_body.mheap8
    PRE_first_tail_x6_r0_body.mnext8 PRE_first_tail_x6_r0_body.mctl8 PRE_first_tail_x6_r0_body.mstack8 PRE_first_tail_x6_r0_body.mjobs8 PRE_first_tail_x6_r0_body.mffi8 PRE_first_tail_x6_r0_body.mtrace8 PRE_first_tail_x6_r0_body.mstores8 h

def PRE_first_tail_x6_r0_body.arrEl8_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE8_2665 : arrOf PRE_first_tail_x6_r0_body.s87 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl8_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA8_2665 : isArrB PRE_first_tail_x6_r0_body.s87 2665 = true
theorem PRE_first_tail_x6_r0_body.arr8_2665 : ∃ o, PRE_first_tail_x6_r0_body.s87.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl8_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE8_2665 PRE_first_tail_x6_r0_body.arrA8_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN8_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl8_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR8_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl8_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN8_2665

def PRE_first_tail_x6_r0_body.arrEl8_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE8_2673467 : arrOf PRE_first_tail_x6_r0_body.s87 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl8_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA8_2673467 : isArrB PRE_first_tail_x6_r0_body.s87 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr8_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s87.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl8_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE8_2673467 PRE_first_tail_x6_r0_body.arrA8_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN8_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl8_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR8_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl8_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN8_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k8 : isArrB PRE_first_tail_x6_r0_body.s87 4910 = false
theorem PRE_first_tail_x6_r0_body.keep8 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s87 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k8 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr8_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl8_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ8
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 8 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s86`, the merged
state `PRE_first_tail_x6_r0_body.s87`, the canonical state `PRE_first_tail_x6_r0_body.s88`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl8 : PRE_first_tail_x6_r0_body.pl8.all (Nat.ble PRE_first_tail_x6_r0_body.s86.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd8 : nodupT PRE_first_tail_x6_r0_body.pl8 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn18 : Nat.ble PRE_first_tail_x6_r0_body.s86.next 2680768 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst8 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s86.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn8 : PRE_first_tail_x6_r0_body.s88.next = PRE_first_tail_x6_r0_body.s86.next + PRE_first_tail_x6_r0_body.pl8.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn8 : PRE_first_tail_x6_r0_body.s87.next = 2680768
kernel_rfl PRE_first_tail_x6_r0_body.zgrow8 : Nat.ble PRE_first_tail_x6_r0_body.s88.next PRE_first_tail_x6_r0_body.s87.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh8 : PRE_first_tail_x6_r0_body.S86.tab.all (fun e => PRE_first_tail_x6_r0_body.cws8.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd8 : nodupT PRE_first_tail_x6_r0_body.cws8 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi8 : PRE_first_tail_x6_r0_body.nr8.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S87.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt8 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s86.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg8_2665 : PRE_first_tail_x6_r0_body.s88.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s88 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk8_2665 : (objOf PRE_first_tail_x6_r0_body.s88 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm8_2665 : PRE_first_tail_x6_r0_body.s87.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa8.obj (objOf PRE_first_tail_x6_r0_body.s88 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s87 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg8_2673467 : PRE_first_tail_x6_r0_body.s88.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s88 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk8_2673467 : (objOf PRE_first_tail_x6_r0_body.s88 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm8_2673467 : PRE_first_tail_x6_r0_body.s87.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa8.obj (objOf PRE_first_tail_x6_r0_body.s88 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s87 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw8_4910 : (PRE_first_tail_x6_r0_body.s88.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw8_2673472 : (PRE_first_tail_x6_r0_body.s88.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw8_2673473 : (PRE_first_tail_x6_r0_body.s88.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd8 : PRE_first_tail_x6_r0_body.cl8.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr8 : PRE_first_tail_x6_r0_body.st8.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s86.next || PRE_first_tail_x6_r0_body.cl8.contains b) = true
def PRE_first_tail_x6_r0_body.zl8 : List Nat := PRE_first_tail_x6_r0_body.cl8.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE8 : PRE_first_tail_x6_r0_body.zl8.map (fun a => PRE_first_tail_x6_r0_body.s87.heap.get (PRE_first_tail_x6_r0_body.kappa8.a a)) = PRE_first_tail_x6_r0_body.zl8.map (fun a => (PRE_first_tail_x6_r0_body.s88.heap.get a).map PRE_first_tail_x6_r0_body.kappa8.hobj)
theorem PRE_first_tail_x6_r0_body.zimg8 : HeapImg PRE_first_tail_x6_r0_body.kappa8 PRE_first_tail_x6_r0_body.s88 PRE_first_tail_x6_r0_body.s87 PRE_first_tail_x6_r0_body.zl8 := PRE_first_tail_x6_r0_body.zimgE8
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl8 : PRE_first_tail_x6_r0_body.s87.ctl = PRE_first_tail_x6_r0_body.kappa8.ctl PRE_first_tail_x6_r0_body.s88.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack8 : PRE_first_tail_x6_r0_body.s87.stack = PRE_first_tail_x6_r0_body.s88.stack.map PRE_first_tail_x6_r0_body.kappa8.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs8 : PRE_first_tail_x6_r0_body.s87.jobs = PRE_first_tail_x6_r0_body.s88.jobs.map PRE_first_tail_x6_r0_body.kappa8.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores8 : PRE_first_tail_x6_r0_body.s87.stores = PRE_first_tail_x6_r0_body.kappa8.stores PRE_first_tail_x6_r0_body.s88.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots8 : checkRootsSupp PRE_first_tail_x6_r0_body.s88 397 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC8 : PRE_first_tail_x6_r0_body.S86.tab.length + PRE_first_tail_x6_r0_body.cws8.length = 397
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap8 : PRE_first_tail_x6_r0_body.kappa8 = Conv.Map.compact PRE_first_tail_x6_r0_body.s86.next 2680768 PRE_first_tail_x6_r0_body.S86.tab.length PRE_first_tail_x6_r0_body.pl8 (PRE_first_tail_x6_r0_body.nr8.map NumV.ref) PRE_first_tail_x6_r0_body.kd8.big
  PRE_first_tail_x6_r0_body.kd8.region PRE_first_tail_x6_r0_body.kd8.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin8 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s88.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc8 : Conv.jcleanListB (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s88 PRE_first_tail_x6_r0_body.cl8 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB8 : noBigRootsP (fun i => !Conv.oldBigB (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s88.trace PRE_first_tail_x6_r0_body.s88 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm8 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15448 = true
theorem PRE_first_tail_x6_r0_body.cjcl8 (h : Conv.JClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s86) : Conv.JClean (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s88 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle8)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap8 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd8 a ha)) PRE_first_tail_x6_r0_body.zjc8

end Host.Load.Run.Tpl
end

section -- st8/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st8.bodyLast from PRE_first_tail_x6_r0_body.st8.s1 to PRE_first_tail_x6_r0_body.st8.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st8.F PRE_first_tail_x6_r0_body.st8.s1).run PRE_first_tail_x6_r0_body.st8.S1 = some (PRE_first_tail_x6_r0_body.st8.s2, PRE_first_tail_x6_r0_body.st8.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st8.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st8.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st8.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st8.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st8/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st8.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st8.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st8.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st8.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st8.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st8.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st8.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st8.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st8.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st8.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st8.s0 PRE_first_tail_x6_r0_body.st8.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st8.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st8.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st8.s1 PRE_first_tail_x6_r0_body.st8.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st8/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st8.bodyK0F from PRE_first_tail_x6_r0_body.st8.s0 to PRE_first_tail_x6_r0_body.st8.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st8.F (PRE_first_tail_x6_r0_body.st8.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st8.ks 0).getD 0) PRE_first_tail_x6_r0_body.st8.s0 PRE_first_tail_x6_r0_body.st8.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st8.s1, PRE_first_tail_x6_r0_body.st8.S1)
theorem PRE_first_tail_x6_r0_body.st8.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st8.F (PRE_first_tail_x6_r0_body.st8.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st8.ks 0).getD 0) PRE_first_tail_x6_r0_body.st8.s0 PRE_first_tail_x6_r0_body.st8.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st8.s1, PRE_first_tail_x6_r0_body.st8.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st8.bodyOkLN_ok PRE_first_tail_x6_r0_body.st8.bodyK0F
end Host.Load.Run.Tpl
end

section -- st8/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st8.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st8.F (PRE_first_tail_x6_r0_body.st8.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st8.s0 PRE_first_tail_x6_r0_body.st8.S0 = some (PRE_first_tail_x6_r0_body.st8.s1, PRE_first_tail_x6_r0_body.st8.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st8.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st8.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st8.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st8.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st8.F (PRE_first_tail_x6_r0_body.st8.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st8.s0
  S0 := PRE_first_tail_x6_r0_body.st8.S0
  s1 := PRE_first_tail_x6_r0_body.st8.s1
  S1 := PRE_first_tail_x6_r0_body.st8.S1
  s2 := PRE_first_tail_x6_r0_body.st8.s2
  S2 := PRE_first_tail_x6_r0_body.st8.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st8.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st8.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st8.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st8.bodyHalt
  last := PRE_first_tail_x6_r0_body.st8.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st8.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC9
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 9 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s104` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa9` into the merged state
`PRE_first_tail_x6_r0_body.s103`. -/

def PRE_first_tail_x6_r0_body.pl9 : List Nat := [2682856, 2682692, 2682744, 2682857, 2682858, 2682694, 2682746, 2682855, 2682854, 2682853, 2682852, 2682846, 2682797, 2682848, 2682799]
def PRE_first_tail_x6_r0_body.nr9 : List Nat := [482, 483, 479, 485, 481, 489, 490, 487, 488]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd9 : RData :=
  ⟨2682509, 2682859, Stage.setAll PTrie.nil [(2682494, 2682856), (2682495, 2682692), (2682496, 2682744), (2682497, 2682857), (2682498, 2682858), (2682499, 2682694), (2682500, 2682746), (2682501, 2682855), (2682502, 2682854), (2682503, 2682853), (2682504, 2682852), (2682505, 2682846), (2682506, 2682797), (2682507, 2682848), (2682508, 2682799)], Stage.setAll PTrie.nil [(18393, 18395), (18394, 18396), (18395, 18398), (18396, 18397)],
   18397, 18399, 15482, 15482, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(474, .ref 482), (475, .ref 483), (476, .ref 479), (477, .ref 485), (478, .ref 481), (479, .ref 489), (480, .ref 490), (481, .ref 487), (482, .ref 488)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa9 : Map :=
  Conv.Map.compact 2682494 2682859 474 PRE_first_tail_x6_r0_body.pl9 (PRE_first_tail_x6_r0_body.nr9.map NumV.ref) PRE_first_tail_x6_r0_body.kd9.big
    PRE_first_tail_x6_r0_body.kd9.region PRE_first_tail_x6_r0_body.kd9.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws9 : List Nat := [1185, 1186, 1187, 1188, 1189, 1190, 1191, 1192, 1193]
noncomputable def PRE_first_tail_x6_r0_body.crs9 : List SymE := PRE_first_tail_x6_r0_body.nr9.map fun r => (nth? PRE_first_tail_x6_r0_body.S103.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta9 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws9 PRE_first_tail_x6_r0_body.crs9
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB9 : List Nat := [2665, 2672322, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab9 : PRE_first_tail_x6_r0_body.S104.tab = PRE_first_tail_x6_r0_body.S102.tab ++ PRE_first_tail_x6_r0_body.cws9.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace9 : PRE_first_tail_x6_r0_body.s104.trace = PRE_first_tail_x6_r0_body.s102.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext9 : PRE_first_tail_x6_r0_body.s104.next = 2682509
kernel_rfl PRE_first_tail_x6_r0_body.ccounters9 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx.nnext) = (18397, 15482)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue9 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s103.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa9.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp9 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx.tokens.all (bSN 483) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean9 : Conv.cleanListB 18397 131072 (fun r => Nat.ble 73588 r) PRE_first_tail_x6_r0_body.s104
    (PRE_first_tail_x6_r0_body.wrB9 ++ (List.range 15).map (2682494 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs9 : bigsOutB 18397 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK9
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl9`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl9 : List Nat := [2665, 2672322, 2673467, 2682494, 2682495, 2682496, 2682497, 2682498, 2682499, 2682500, 2682501, 2682502, 2682503, 2682504, 2682505, 2682506, 2682507, 2682508]
def PRE_first_tail_x6_r0_body.clo9 : List Nat := [18393, 18394, 18395, 18396]
def PRE_first_tail_x6_r0_body.cln9 : List Nat := [15476, 15477, 15478, 15479, 15480, 15481]
def PRE_first_tail_x6_r0_body.cli9 : List Nat := [15476, 15477, 15478, 15479, 15480, 15481]
kernel_rfl PRE_first_tail_x6_r0_body.cheap9 : PRE_first_tail_x6_r0_body.s104.heap = Stage.setAll PRE_first_tail_x6_r0_body.s102.heap (PRE_first_tail_x6_r0_body.cl9.filterMap fun a => (PRE_first_tail_x6_r0_body.s104.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe9 : Nat.ble PRE_first_tail_x6_r0_body.s102.next PRE_first_tail_x6_r0_body.s104.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP9 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s102 PRE_first_tail_x6_r0_body.s104 PRE_first_tail_x6_r0_body.cl9 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp9 : Conv.suppListB PRE_first_tail_x6_r0_body.s104 483 PRE_first_tail_x6_r0_body.cl9 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound9 : Conv.boundListB PRE_first_tail_x6_r0_body.s104 PRE_first_tail_x6_r0_body.cl9 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK9 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln9.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK9 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo9.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK9 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli9.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst9 : Conv.sstListB 483 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx PRE_first_tail_x6_r0_body.cln9 PRE_first_tail_x6_r0_body.clo9 PRE_first_tail_x6_r0_body.cli9 = true

end Host.Load.Run.Tpl
end

section -- SiteCl9
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA9 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo9.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd9 : (PRE_first_tail_x6_r0_body.clo9 ++ PRE_first_tail_x6_r0_body.cln9 ++ PRE_first_tail_x6_r0_body.cli9).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle9 : Conv.Cnt.leB (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck9 : Conv.ncleanListB (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx PRE_first_tail_x6_r0_body.clo9 PRE_first_tail_x6_r0_body.cln9 PRE_first_tail_x6_r0_body.cli9 = true
theorem PRE_first_tail_x6_r0_body.cncl9 (h : Conv.NClean (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx) : Conv.NClean (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle9 PRE_first_tail_x6_r0_body.ckA9 PRE_first_tail_x6_r0_body.cobjsK9 PRE_first_tail_x6_r0_body.cnodesK9 PRE_first_tail_x6_r0_body.citemsK9 PRE_first_tail_x6_r0_body.cbd9 PRE_first_tail_x6_r0_body.cck9

end Host.Load.Run.Tpl
end

section -- SiteS9
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 9 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc9 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P9 : LoadP := PRE_first_tail_x6_r0_body.Pc9.raise 15482
kernel_rfl PRE_first_tail_x6_r0_body.craise9 : Nat.ble PRE_first_tail_x6_r0_body.Pc9.N0 15482 = true
theorem PRE_first_tail_x6_r0_body.raised9 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc9 PRE_first_tail_x6_r0_body.P9 :=
  .inr ⟨15482, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise9, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_9 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_9 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s103.ffi)
def PRE_first_tail_x6_r0_body.khinv9 : PTrie Nat := Stage.setAll PTrie.nil [(18395, 18393), (18396, 18394), (18398, 18395), (18397, 18396)]
def PRE_first_tail_x6_r0_body.kninv9 : PTrie Nat := Stage.setAll PTrie.nil [(15476, 15476), (15477, 15477), (15478, 15478), (15479, 15479), (15480, 15480), (15481, 15481)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS9 : List Nat := [18393, 18394, 18395, 18396, 18397, 18398]
def PRE_first_tail_x6_r0_body.cnS9 : List Nat := List.range' 15476 6
def PRE_first_tail_x6_r0_body.ciS9 : List Nat := [] ++ List.range' 15476 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh09 : PRE_first_tail_x6_r0_body.kd9.nh0 = PRE_first_tail_x6_r0_body.cx0_9.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh19 : PRE_first_tail_x6_r0_body.kd9.nh1 = PRE_first_tail_x6_r0_body.cx1_9.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn09 : PRE_first_tail_x6_r0_body.kd9.nn0 = PRE_first_tail_x6_r0_body.cx0_9.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn19 : PRE_first_tail_x6_r0_body.kd9.nn1 = PRE_first_tail_x6_r0_body.cx1_9.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo9 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P9.lo && Nat.ble PRE_first_tail_x6_r0_body.P9.lo PRE_first_tail_x6_r0_body.cx0_9.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P9.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P9.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt9 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_9.mlx.next PRE_first_tail_x6_r0_body.cx1_9.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_9.mlx.nnext PRE_first_tail_x6_r0_body.cx1_9.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband9 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P9.NL && Nat.ble PRE_first_tail_x6_r0_body.P9.NL PRE_first_tail_x6_r0_body.P9.N0 && Nat.ble PRE_first_tail_x6_r0_body.P9.N0 PRE_first_tail_x6_r0_body.cx0_9.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow9 : PRE_first_tail_x6_r0_body.kd9.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren9 : checkRenG PRE_first_tail_x6_r0_body.kd9.hnd PRE_first_tail_x6_r0_body.khinv9 (phB PRE_first_tail_x6_r0_body.cx0_9.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband9 : PRE_first_tail_x6_r0_body.kd9.checkBand PRE_first_tail_x6_r0_body.P9.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos9 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd9.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren9 : checkRenG PRE_first_tail_x6_r0_body.kd9.node PRE_first_tail_x6_r0_body.kninv9 (pnB PRE_first_tail_x6_r0_body.cx0_9.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow9 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd9.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P9.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd9.nodeF j) PRE_first_tail_x6_r0_body.cx1_9.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a9 : PRE_first_tail_x6_r0_body.cx0_9.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b9 : PRE_first_tail_x6_r0_body.cx0_9.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok19 : PRE_first_tail_x6_r0_body.cx1_9.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend9 : PRE_first_tail_x6_r0_body.cx1_9.mlx.pending = PRE_first_tail_x6_r0_body.cx0_9.mlx.pending.map PRE_first_tail_x6_r0_body.kappa9.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh9 : PRE_first_tail_x6_r0_body.cx1_9.mlx.errh = PRE_first_tail_x6_r0_body.cx0_9.mlx.errh.map PRE_first_tail_x6_r0_body.kappa9.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles9 : PRE_first_tail_x6_r0_body.cx1_9.mlx.files = PRE_first_tail_x6_r0_body.cx0_9.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch9 : PRE_first_tail_x6_r0_body.cx1_9.mlx.arch = PRE_first_tail_x6_r0_body.cx0_9.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes9 : PRE_first_tail_x6_r0_body.cx1_9.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_9.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired9 : PRE_first_tail_x6_r0_body.cx1_9.mlx.wired = PRE_first_tail_x6_r0_body.cx0_9.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost9 : PRE_first_tail_x6_r0_body.cx1_9.host = PRE_first_tail_x6_r0_body.cx0_9.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd9`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn09 : PRE_first_tail_x6_r0_body.kd9.n0 = 2682509
kernel_rfl PRE_first_tail_x6_r0_body.ckn19 : PRE_first_tail_x6_r0_body.kd9.n1 = 2682859
kernel_rfl PRE_first_tail_x6_r0_body.ckheap9 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd9.heap).all (fun x => Nat.ble 2682494 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl9 : (List.range 15).all (fun j => decide (PRE_first_tail_x6_r0_body.kd9.heap.get (2682494 + j) = nth? PRE_first_tail_x6_r0_body.pl9 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja9 : Nat.ble 2682494 2682494 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn9 : Nat.ble 474 474 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD9 : Nat.ble 2682494 PRE_first_tail_x6_r0_body.kd9.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn9 : Nat.ble 18393 PRE_first_tail_x6_r0_body.kd9.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn9 : Nat.ble 15476 PRE_first_tail_x6_r0_body.kd9.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb9 : Nat.ble 18393 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap9 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd9.heap).all (Nat.ble (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd9 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd9.hnd).all (Nat.ble (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode9 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd9.node).all (Nat.ble (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix9 : Conv.FixOld (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa9 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja9) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn9) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD9) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn9) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn9) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb9) PRE_first_tail_x6_r0_body.fheap9 PRE_first_tail_x6_r0_body.fhnd9 PRE_first_tail_x6_r0_body.fnode9
kernel_rfl PRE_first_tail_x6_r0_body.fcxn9 : (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn9 : (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle09 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_9.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_9.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk9 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd9.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A9 : PRE_first_tail_x6_r0_body.cx1_9.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS9.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_9.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O9 : PRE_first_tail_x6_r0_body.cx1_9.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS9.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_9.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N9 : PRE_first_tail_x6_r0_body.cx1_9.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS9.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_9.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I9 : PRE_first_tail_x6_r0_body.cx1_9.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS9.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_9.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd9 : (PRE_first_tail_x6_r0_body.clo9 ++ PRE_first_tail_x6_r0_body.cln9 ++ PRE_first_tail_x6_r0_body.cli9 ++ PRE_first_tail_x6_r0_body.cwS9 ++ PRE_first_tail_x6_r0_body.cnS9 ++ PRE_first_tail_x6_r0_body.ciS9).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW9 : PRE_first_tail_x6_r0_body.cwS9.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo9.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI9 : PRE_first_tail_x6_r0_body.ciS9.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli9.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN9 : PRE_first_tail_x6_r0_body.cnS9.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF9 : PRE_first_tail_x6_r0_body.cln9.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh9 : PRE_first_tail_x6_r0_body.clo9.all (handleOK PRE_first_tail_x6_r0_body.kappa9 PRE_first_tail_x6_r0_body.P9.lo PRE_first_tail_x6_r0_body.cx0_9.mlx PRE_first_tail_x6_r0_body.cx1_9.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo9 : PRE_first_tail_x6_r0_body.clo9.map (fun h => PRE_first_tail_x6_r0_body.cx1_9.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa9.handle h)) = PRE_first_tail_x6_r0_body.clo9.map (fun h => (PRE_first_tail_x6_r0_body.cx0_9.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa9.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok9 : PRE_first_tail_x6_r0_body.clo9.all (objOK PRE_first_tail_x6_r0_body.kappa9 PRE_first_tail_x6_r0_body.P9.NL PRE_first_tail_x6_r0_body.cx0_9.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd9 : PRE_first_tail_x6_r0_body.cln9.all (nodeOKF PRE_first_tail_x6_r0_body.kappa9 PRE_first_tail_x6_r0_body.P9 PRE_first_tail_x6_r0_body.cx0_9.mlx PRE_first_tail_x6_r0_body.cx1_9.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp9 : ((PRE_first_tail_x6_r0_body.cln9.filter (fullB PRE_first_tail_x6_r0_body.P9))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_9.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa9.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln9.filter (fullB PRE_first_tail_x6_r0_body.P9))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_9.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa9.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI9 : incrB PRE_first_tail_x6_r0_body.kd9.nodeF (List.range' 15476 6) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK9 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd9.node).all (fun k => Nat.ble 15476 k && Nat.blt k 15482) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL9 : (PRE_first_tail_x6_r0_body.cln9.filter (Nat.ble PRE_first_tail_x6_r0_body.P9.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd9.nodeF i) && (Nat.blt i 15482 || Nat.ble PRE_first_tail_x6_r0_body.kd9.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord9 : (PRE_first_tail_x6_r0_body.cln9.filter (Nat.ble PRE_first_tail_x6_r0_body.P9.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd9.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd9.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd9.nodeF j) (PRE_first_tail_x6_r0_body.kd9.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow9 PRE_first_tail_x6_r0_body.cnn19 PRE_first_tail_x6_r0_body.fnordI9 PRE_first_tail_x6_r0_body.fnordK9 PRE_first_tail_x6_r0_body.fnordL9
kernel_rfl PRE_first_tail_x6_r0_body.fi9 : PRE_first_tail_x6_r0_body.cli9.all (pnB PRE_first_tail_x6_r0_body.cx0_9.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii9 : PRE_first_tail_x6_r0_body.cli9.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_9.mlx.items.get (PRE_first_tail_x6_r0_body.kappa9.node k) = (PRE_first_tail_x6_r0_body.cx0_9.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa9.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot9 (clean : Conv.NClean (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P9.NL) (cl : SSt (· < 483) PRE_first_tail_x6_r0_body.cx0_9.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P9 483 PRE_first_tail_x6_r0_body.kappa9 PRE_first_tail_x6_r0_body.kd9 PRE_first_tail_x6_r0_body.khinv9 PRE_first_tail_x6_r0_body.kninv9 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx PRE_first_tail_x6_r0_body.cx0_9.mlx PRE_first_tail_x6_r0_body.cx1_9.mlx (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo9 PRE_first_tail_x6_r0_body.cln9 PRE_first_tail_x6_r0_body.cli9 PRE_first_tail_x6_r0_body.cwS9 PRE_first_tail_x6_r0_body.cnS9 PRE_first_tail_x6_r0_body.ciS9 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh09, PRE_first_tail_x6_r0_body.cnh19, PRE_first_tail_x6_r0_body.cnn09, PRE_first_tail_x6_r0_body.cnn19, PRE_first_tail_x6_r0_body.cplo9, PRE_first_tail_x6_r0_body.ccnt9, PRE_first_tail_x6_r0_body.cnband9, PRE_first_tail_x6_r0_body.chbelow9, PRE_first_tail_x6_r0_body.chren9, PRE_first_tail_x6_r0_body.cband9, PRE_first_tail_x6_r0_body.cnh1pos9, PRE_first_tail_x6_r0_body.cnren9, PRE_first_tail_x6_r0_body.cnlow9, PRE_first_tail_x6_r0_body.cabs0a9, PRE_first_tail_x6_r0_body.cabs0b9, PRE_first_tail_x6_r0_body.ctok19, PRE_first_tail_x6_r0_body.cpend9, PRE_first_tail_x6_r0_body.cerrh9, PRE_first_tail_x6_r0_body.cfiles9, PRE_first_tail_x6_r0_body.carch9, PRE_first_tail_x6_r0_body.csizes9, PRE_first_tail_x6_r0_body.cwired9, PRE_first_tail_x6_r0_body.cfix9, clean, PRE_first_tail_x6_r0_body.fcxn9, PRE_first_tail_x6_r0_body.fcnn9, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle09, PRE_first_tail_x6_r0_body.fnk9, PRE_first_tail_x6_r0_body.ckA9, PRE_first_tail_x6_r0_body.cobjsK9, PRE_first_tail_x6_r0_body.cnodesK9, PRE_first_tail_x6_r0_body.citemsK9, PRE_first_tail_x6_r0_body.f1A9, PRE_first_tail_x6_r0_body.f1O9, PRE_first_tail_x6_r0_body.f1N9, PRE_first_tail_x6_r0_body.f1I9, PRE_first_tail_x6_r0_body.fbd9, PRE_first_tail_x6_r0_body.fincW9, PRE_first_tail_x6_r0_body.fincI9, PRE_first_tail_x6_r0_body.fincN9, PRE_first_tail_x6_r0_body.flnF9, PRE_first_tail_x6_r0_body.fh9, PRE_first_tail_x6_r0_body.fo9, PRE_first_tail_x6_r0_body.fok9, PRE_first_tail_x6_r0_body.fnd9, PRE_first_tail_x6_r0_body.fp9, PRE_first_tail_x6_r0_body.fnord9, PRE_first_tail_x6_r0_body.fi9, PRE_first_tail_x6_r0_body.fii9⟩
theorem PRE_first_tail_x6_r0_body.cnshift9 (clean : Conv.NClean (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P9.NL) (cl : SSt (· < 483) PRE_first_tail_x6_r0_body.cx0_9.mlx) : NShift PRE_first_tail_x6_r0_body.P9 483 PRE_first_tail_x6_r0_body.kappa9 PRE_first_tail_x6_r0_body.cx0_9 PRE_first_tail_x6_r0_body.cx1_9 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot9 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost9 (compact_a_eq PRE_first_tail_x6_r0_body.ckn09 PRE_first_tail_x6_r0_body.ckn19 PRE_first_tail_x6_r0_body.ckheap9 PRE_first_tail_x6_r0_body.ckpl9)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_9 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s102.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_9 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s102.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_9 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s102.ffi) = some PRE_first_tail_x6_r0_body.fxC_9
kernel_rfl PRE_first_tail_x6_r0_body.okrC_9 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s102.ffi) = some PRE_first_tail_x6_r0_body.krC_9
noncomputable def PRE_first_tail_x6_r0_body.fx0_9 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s104.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_9 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s104.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_9 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s104.ffi) = some PRE_first_tail_x6_r0_body.fx0_9
kernel_rfl PRE_first_tail_x6_r0_body.okr0_9 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s104.ffi) = some PRE_first_tail_x6_r0_body.kr0_9
noncomputable def PRE_first_tail_x6_r0_body.fx1_9 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s103.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_9 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s103.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_9 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s103.ffi) = some PRE_first_tail_x6_r0_body.fx1_9
kernel_rfl PRE_first_tail_x6_r0_body.okr1_9 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s103.ffi) = some PRE_first_tail_x6_r0_body.kr1_9
kernel_rfl PRE_first_tail_x6_r0_body.ff09 : PRE_first_tail_x6_r0_body.fx0_9 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_9 (PRE_first_tail_x6_r0_body.clo9.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_9.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff19 : PRE_first_tail_x6_r0_body.fx1_9 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_9 (PRE_first_tail_x6_r0_body.cwS9.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_9.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck9 : freedLB PRE_first_tail_x6_r0_body.kappa9 PRE_first_tail_x6_r0_body.cx0_9.mlx PRE_first_tail_x6_r0_body.fx0_9 PRE_first_tail_x6_r0_body.fx1_9 PRE_first_tail_x6_r0_body.clo9 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf09 : PRE_first_tail_x6_r0_body.kr0_9.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_9.flags (PRE_first_tail_x6_r0_body.clo9.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_9.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt09 : PRE_first_tail_x6_r0_body.kr0_9.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_9.targs (PRE_first_tail_x6_r0_body.clo9.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_9.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf19 : PRE_first_tail_x6_r0_body.kr1_9.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_9.flags (PRE_first_tail_x6_r0_body.cwS9.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_9.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt19 : PRE_first_tail_x6_r0_body.kr1_9.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_9.targs (PRE_first_tail_x6_r0_body.cwS9.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_9.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck9 : krecLB PRE_first_tail_x6_r0_body.kappa9 483 PRE_first_tail_x6_r0_body.cx0_9.mlx PRE_first_tail_x6_r0_body.kr0_9 PRE_first_tail_x6_r0_body.kr1_9 PRE_first_tail_x6_r0_body.clo9 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn9 : Nat.ble 474 483 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge9 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s103.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s104.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR9 : pendRegB PRE_first_tail_x6_r0_body.kappa9 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe9 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s104.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s103.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift9 (clean : Conv.NClean (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P9.NL) (cl : SSt (· < 483) PRE_first_tail_x6_r0_body.cx0_9.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_9.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_9.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_9.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s102.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_9.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P9 483 PRE_first_tail_x6_r0_body.kappa9 PRE_first_tail_x6_r0_body.s104.ffi PRE_first_tail_x6_r0_body.s103.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift9 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue9, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp9 t ht),
    PRE_first_tail_x6_r0_body.cbridge9,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s104.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s103.ffi) (PRE_first_tail_x6_r0_body.cfoot9 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_9 PRE_first_tail_x6_r0_body.ofx1_9 hobjC PRE_first_tail_x6_r0_body.ff09 PRE_first_tail_x6_r0_body.ff19 PRE_first_tail_x6_r0_body.ffck9,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s104.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s103.ffi) (PRE_first_tail_x6_r0_body.cfoot9 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_9 PRE_first_tail_x6_r0_body.okr1_9 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn9) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf09 PRE_first_tail_x6_r0_body.fkt09 PRE_first_tail_x6_r0_body.fkf19 PRE_first_tail_x6_r0_body.fkt19 PRE_first_tail_x6_r0_body.fkck9,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh09 PRE_first_tail_x6_r0_body.cnh19 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe9) PRE_first_tail_x6_r0_body.cpendR9⟩

end Host.Load.Run.Tpl
end

section -- st9/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st9 0
host_stream_state PRE_first_tail_x6_r0_body.st9 1
host_stream_state PRE_first_tail_x6_r0_body.st9 2
host_stream_state PRE_first_tail_x6_r0_body.st9 3
end Host.Load.Run.Tpl
end

section -- Site9
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 9 of chain `PRE_first_tail_x6_r0_body`: `kvW__g9__g10` (`appendWindow`), the call state `PRE_first_tail_x6_r0_body.s102`, the merged state `PRE_first_tail_x6_r0_body.s103`,
the site template `PRE_first_tail_x6_r0_body.st9` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s104`: the merge.
The footprint's facts are in `SiteF9`, the compaction's in `SiteC9`, `SiteK9`, `SiteNa9`, `SiteNb9`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso9 : PRE_first_tail_x6_r0_body.st9.s0 = { PRE_first_tail_x6_r0_body.s102 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs9 : List Frame := PRE_first_tail_x6_r0_body.s102.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_9 : PRE_first_tail_x6_r0_body.S102.tab.length = 474
kernel_rfl PRE_first_tail_x6_r0_body.tab0_9 : PRE_first_tail_x6_r0_body.st9.S0.tab = PRE_first_tail_x6_r0_body.S102.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws9 : List Nat := [1168, 1169, 1170, 1171, 1172, 1173, 1174, 1175, 1176, 1177, 1178, 1179, 1180, 1181, 1182, 1183, 1184]
kernel_rfl PRE_first_tail_x6_r0_body.fresh9 : (PRE_first_tail_x6_r0_body.S102.tab.all fun e => PRE_first_tail_x6_r0_body.ws9.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S102.oracle.all fun q => PRE_first_tail_x6_r0_body.ws9.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab9 : PRE_first_tail_x6_r0_body.S103.tab = PRE_first_tail_x6_r0_body.S102.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws9
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen9 : PRE_first_tail_x6_r0_body.st9.S3.tab.length - PRE_first_tail_x6_r0_body.st9.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged9`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap9 : PRE_first_tail_x6_r0_body.s103.heap = PRE_first_tail_x6_r0_body.st9.s3.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext9 : PRE_first_tail_x6_r0_body.s103.next = PRE_first_tail_x6_r0_body.st9.s3.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl9 : PRE_first_tail_x6_r0_body.s103.ctl = PRE_first_tail_x6_r0_body.st9.s3.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack9 : PRE_first_tail_x6_r0_body.s103.stack = PRE_first_tail_x6_r0_body.st9.s3.stack ++ PRE_first_tail_x6_r0_body.s102.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs9 : PRE_first_tail_x6_r0_body.s103.jobs = PRE_first_tail_x6_r0_body.st9.s3.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi9 : PRE_first_tail_x6_r0_body.s103.ffi = PRE_first_tail_x6_r0_body.st9.s3.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace9 : PRE_first_tail_x6_r0_body.s103.trace = PRE_first_tail_x6_r0_body.st9.s3.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores9 : PRE_first_tail_x6_r0_body.s103.stores = PRE_first_tail_x6_r0_body.st9.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD9
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 9 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived9 : PRE_first_tail_x6_r0_body.nr9.map (fun r => nth? PRE_first_tail_x6_r0_body.st9.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo9 : PRE_first_tail_x6_r0_body.nr9.all (Nat.ble 474) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj9 : PRE_first_tail_x6_r0_body.cws9.all (fun c => !PRE_first_tail_x6_r0_body.ws9.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ9 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws9 PRE_first_tail_x6_r0_body.crs9 PRE_first_tail_x6_r0_body.ws9

end Host.Load.Run.Tpl
end

section -- st9/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st9`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st9.wrR : List (Nat × Nat) := [(2672322, 2672323)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st9.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st9.s3.heap PRE_first_tail_x6_r0_body.st9.wrR ++ freshOf PRE_first_tail_x6_r0_body.st9.s3.heap PRE_first_tail_x6_r0_body.st9.s0.next PRE_first_tail_x6_r0_body.st9.s3.next
noncomputable def PRE_first_tail_x6_r0_body.st9.wr : List Nat := PRE_first_tail_x6_r0_body.st9.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st9.heapFoot : PRE_first_tail_x6_r0_body.st9.s3.heap = setAll PRE_first_tail_x6_r0_body.st9.s0.heap PRE_first_tail_x6_r0_body.st9.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st9.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st9.s0.next PRE_first_tail_x6_r0_body.st9.s3.next = true
theorem PRE_first_tail_x6_r0_body.st9.grows : PRE_first_tail_x6_r0_body.st9.s0.next ≤ PRE_first_tail_x6_r0_body.st9.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st9.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st9.wh : List Nat := [18393, 18394, 18395, 18396, 18397, 18398]
def PRE_first_tail_x6_r0_body.st9.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st9.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st9.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st9.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st9.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st9.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st9.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st9.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st9.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st9.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF9
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 9 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB9 : nodupT PRE_first_tail_x6_r0_body.st9.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup9 : PRE_first_tail_x6_r0_body.st9.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB9).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB9 : PRE_first_tail_x6_r0_body.st9.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound9 : ∀ b ∈ PRE_first_tail_x6_r0_body.st9.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB9 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr9 := PRE_first_tail_x6_r0_body.st9.s3.trace.take 26
kernel_rfl PRE_first_tail_x6_r0_body.traceEq9 : PRE_first_tail_x6_r0_body.st9.s3.trace = PRE_first_tail_x6_r0_body.trFr9 ++ PRE_first_tail_x6_r0_body.st9.s0.trace
theorem PRE_first_tail_x6_r0_body.trace9 : ∃ fr, PRE_first_tail_x6_r0_body.st9.s3.trace = fr ++ PRE_first_tail_x6_r0_body.st9.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq9⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide9 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB9 : (PRE_first_tail_x6_r0_body.wide9.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st9.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix9 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide9, WFix Map.id (Present PRE_first_tail_x6_r0_body.st9.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB9 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL9
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 9 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s103`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO9 : PRE_first_tail_x6_r0_body.st9.S0.oracle = PRE_first_tail_x6_r0_body.st9.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B9 : PRE_first_tail_x6_r0_body.st9.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st9.s0.next || (PRE_first_tail_x6_r0_body.st9.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot9 : Conv.StageFoot PRE_first_tail_x6_r0_body.st9.wr PRE_first_tail_x6_r0_body.st9.s0 PRE_first_tail_x6_r0_body.st9.s3 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st9.heapFoot PRE_first_tail_x6_r0_body.wrNodup9 PRE_first_tail_x6_r0_body.wrBound9 PRE_first_tail_x6_r0_body.wr0B9 PRE_first_tail_x6_r0_body.st9.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged9 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st9.F.S → PRE_first_tail_x6_r0_body.st9.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st9.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st9.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs9 PRE_first_tail_x6_r0_body.st9.wr PRE_first_tail_x6_r0_body.s102 PRE_first_tail_x6_r0_body.st9.s3 PRE_first_tail_x6_r0_body.st9.s0
      PRE_first_tail_x6_r0_body.st9.s3.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st9.F FR W stk M ν K PRE_first_tail_x6_r0_body.s103 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso9 PRE_first_tail_x6_r0_body.stFoot9 PRE_first_tail_x6_r0_body.wrNodup9 PRE_first_tail_x6_r0_body.wrBound9 PRE_first_tail_x6_r0_body.trace9 PRE_first_tail_x6_r0_body.mheap9
    PRE_first_tail_x6_r0_body.mnext9 PRE_first_tail_x6_r0_body.mctl9 PRE_first_tail_x6_r0_body.mstack9 PRE_first_tail_x6_r0_body.mjobs9 PRE_first_tail_x6_r0_body.mffi9 PRE_first_tail_x6_r0_body.mtrace9 PRE_first_tail_x6_r0_body.mstores9 h

def PRE_first_tail_x6_r0_body.arrEl9_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE9_2665 : arrOf PRE_first_tail_x6_r0_body.s103 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl9_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA9_2665 : isArrB PRE_first_tail_x6_r0_body.s103 2665 = true
theorem PRE_first_tail_x6_r0_body.arr9_2665 : ∃ o, PRE_first_tail_x6_r0_body.s103.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl9_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE9_2665 PRE_first_tail_x6_r0_body.arrA9_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN9_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl9_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR9_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl9_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN9_2665

def PRE_first_tail_x6_r0_body.arrEl9_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE9_2673467 : arrOf PRE_first_tail_x6_r0_body.s103 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl9_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA9_2673467 : isArrB PRE_first_tail_x6_r0_body.s103 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr9_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s103.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl9_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE9_2673467 PRE_first_tail_x6_r0_body.arrA9_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN9_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl9_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR9_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl9_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN9_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k9 : isArrB PRE_first_tail_x6_r0_body.s103 4910 = false
theorem PRE_first_tail_x6_r0_body.keep9 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s103 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k9 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr9_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl9_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ9
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 9 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s102`, the merged
state `PRE_first_tail_x6_r0_body.s103`, the canonical state `PRE_first_tail_x6_r0_body.s104`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl9 : PRE_first_tail_x6_r0_body.pl9.all (Nat.ble PRE_first_tail_x6_r0_body.s102.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd9 : nodupT PRE_first_tail_x6_r0_body.pl9 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn19 : Nat.ble PRE_first_tail_x6_r0_body.s102.next 2682859 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst9 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s102.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn9 : PRE_first_tail_x6_r0_body.s104.next = PRE_first_tail_x6_r0_body.s102.next + PRE_first_tail_x6_r0_body.pl9.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn9 : PRE_first_tail_x6_r0_body.s103.next = 2682859
kernel_rfl PRE_first_tail_x6_r0_body.zgrow9 : Nat.ble PRE_first_tail_x6_r0_body.s104.next PRE_first_tail_x6_r0_body.s103.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh9 : PRE_first_tail_x6_r0_body.S102.tab.all (fun e => PRE_first_tail_x6_r0_body.cws9.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd9 : nodupT PRE_first_tail_x6_r0_body.cws9 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi9 : PRE_first_tail_x6_r0_body.nr9.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S103.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt9 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s102.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg9_2665 : PRE_first_tail_x6_r0_body.s104.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s104 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk9_2665 : (objOf PRE_first_tail_x6_r0_body.s104 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm9_2665 : PRE_first_tail_x6_r0_body.s103.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa9.obj (objOf PRE_first_tail_x6_r0_body.s104 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s103 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg9_2673467 : PRE_first_tail_x6_r0_body.s104.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s104 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk9_2673467 : (objOf PRE_first_tail_x6_r0_body.s104 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm9_2673467 : PRE_first_tail_x6_r0_body.s103.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa9.obj (objOf PRE_first_tail_x6_r0_body.s104 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s103 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw9_4910 : (PRE_first_tail_x6_r0_body.s104.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw9_2673472 : (PRE_first_tail_x6_r0_body.s104.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw9_2673473 : (PRE_first_tail_x6_r0_body.s104.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd9 : PRE_first_tail_x6_r0_body.cl9.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr9 : PRE_first_tail_x6_r0_body.st9.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s102.next || PRE_first_tail_x6_r0_body.cl9.contains b) = true
def PRE_first_tail_x6_r0_body.zl9 : List Nat := PRE_first_tail_x6_r0_body.cl9.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE9 : PRE_first_tail_x6_r0_body.zl9.map (fun a => PRE_first_tail_x6_r0_body.s103.heap.get (PRE_first_tail_x6_r0_body.kappa9.a a)) = PRE_first_tail_x6_r0_body.zl9.map (fun a => (PRE_first_tail_x6_r0_body.s104.heap.get a).map PRE_first_tail_x6_r0_body.kappa9.hobj)
theorem PRE_first_tail_x6_r0_body.zimg9 : HeapImg PRE_first_tail_x6_r0_body.kappa9 PRE_first_tail_x6_r0_body.s104 PRE_first_tail_x6_r0_body.s103 PRE_first_tail_x6_r0_body.zl9 := PRE_first_tail_x6_r0_body.zimgE9
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl9 : PRE_first_tail_x6_r0_body.s103.ctl = PRE_first_tail_x6_r0_body.kappa9.ctl PRE_first_tail_x6_r0_body.s104.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack9 : PRE_first_tail_x6_r0_body.s103.stack = PRE_first_tail_x6_r0_body.s104.stack.map PRE_first_tail_x6_r0_body.kappa9.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs9 : PRE_first_tail_x6_r0_body.s103.jobs = PRE_first_tail_x6_r0_body.s104.jobs.map PRE_first_tail_x6_r0_body.kappa9.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores9 : PRE_first_tail_x6_r0_body.s103.stores = PRE_first_tail_x6_r0_body.kappa9.stores PRE_first_tail_x6_r0_body.s104.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots9 : checkRootsSupp PRE_first_tail_x6_r0_body.s104 483 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC9 : PRE_first_tail_x6_r0_body.S102.tab.length + PRE_first_tail_x6_r0_body.cws9.length = 483
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap9 : PRE_first_tail_x6_r0_body.kappa9 = Conv.Map.compact PRE_first_tail_x6_r0_body.s102.next 2682859 PRE_first_tail_x6_r0_body.S102.tab.length PRE_first_tail_x6_r0_body.pl9 (PRE_first_tail_x6_r0_body.nr9.map NumV.ref) PRE_first_tail_x6_r0_body.kd9.big
  PRE_first_tail_x6_r0_body.kd9.region PRE_first_tail_x6_r0_body.kd9.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin9 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s104.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc9 : Conv.jcleanListB (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s104 PRE_first_tail_x6_r0_body.cl9 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB9 : noBigRootsP (fun i => !Conv.oldBigB (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s104.trace PRE_first_tail_x6_r0_body.s104 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm9 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15476 = true
theorem PRE_first_tail_x6_r0_body.cjcl9 (h : Conv.JClean (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s102) : Conv.JClean (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s104 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle9)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap9 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd9 a ha)) PRE_first_tail_x6_r0_body.zjc9

end Host.Load.Run.Tpl
end

section -- st9/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st9.bodyLast from PRE_first_tail_x6_r0_body.st9.s2 to PRE_first_tail_x6_r0_body.st9.s3 :
  interpS (step PRE_first_tail_x6_r0_body.st9.F PRE_first_tail_x6_r0_body.st9.s2).run PRE_first_tail_x6_r0_body.st9.S2 = some (PRE_first_tail_x6_r0_body.st9.s3, PRE_first_tail_x6_r0_body.st9.S3)
kernel_rfl PRE_first_tail_x6_r0_body.st9.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st9.s2.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st9.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st9.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st9/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st9.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st9.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st9.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st9.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st9.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st9.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st9.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st9.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st9.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st9.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st9.s0 PRE_first_tail_x6_r0_body.st9.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st9.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st9.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st9.s2 PRE_first_tail_x6_r0_body.st9.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st9/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st9.bodyK0F from PRE_first_tail_x6_r0_body.st9.s0 to PRE_first_tail_x6_r0_body.st9.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st9.F (PRE_first_tail_x6_r0_body.st9.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st9.ks 0).getD 0) PRE_first_tail_x6_r0_body.st9.s0 PRE_first_tail_x6_r0_body.st9.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st9.s1, PRE_first_tail_x6_r0_body.st9.S1)
theorem PRE_first_tail_x6_r0_body.st9.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st9.F (PRE_first_tail_x6_r0_body.st9.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st9.ks 0).getD 0) PRE_first_tail_x6_r0_body.st9.s0 PRE_first_tail_x6_r0_body.st9.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st9.s1, PRE_first_tail_x6_r0_body.st9.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st9.bodyOkLN_ok PRE_first_tail_x6_r0_body.st9.bodyK0F
end Host.Load.Run.Tpl
end

section -- st9/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st9.bodyK1F from PRE_first_tail_x6_r0_body.st9.s1 to PRE_first_tail_x6_r0_body.st9.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st9.F (PRE_first_tail_x6_r0_body.st9.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st9.ks 1).getD 0) PRE_first_tail_x6_r0_body.st9.s1 PRE_first_tail_x6_r0_body.st9.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st9.s2, PRE_first_tail_x6_r0_body.st9.S2)
theorem PRE_first_tail_x6_r0_body.st9.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st9.F (PRE_first_tail_x6_r0_body.st9.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st9.ks 1).getD 0) PRE_first_tail_x6_r0_body.st9.s1 PRE_first_tail_x6_r0_body.st9.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st9.s2, PRE_first_tail_x6_r0_body.st9.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st9.bodyOkLN_ok PRE_first_tail_x6_r0_body.st9.bodyK1F
end Host.Load.Run.Tpl
end

section -- st9/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st9.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st9.F (PRE_first_tail_x6_r0_body.st9.bodyOkL bytes rows) 3452 PRE_first_tail_x6_r0_body.st9.s0 PRE_first_tail_x6_r0_body.st9.S0 = some (PRE_first_tail_x6_r0_body.st9.s2, PRE_first_tail_x6_r0_body.st9.S2) :=
  runOk_trans PRE_first_tail_x6_r0_body.st9.F (PRE_first_tail_x6_r0_body.st9.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st9.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st9.ks 1).getD 0) PRE_first_tail_x6_r0_body.st9.s0 PRE_first_tail_x6_r0_body.st9.s1 PRE_first_tail_x6_r0_body.st9.s2 PRE_first_tail_x6_r0_body.st9.S0 PRE_first_tail_x6_r0_body.st9.S1 PRE_first_tail_x6_r0_body.st9.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st9.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st9.bodyK1 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st9.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st9.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st9.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st9.F (PRE_first_tail_x6_r0_body.st9.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st9.s0
  S0 := PRE_first_tail_x6_r0_body.st9.S0
  s1 := PRE_first_tail_x6_r0_body.st9.s2
  S1 := PRE_first_tail_x6_r0_body.st9.S2
  s2 := PRE_first_tail_x6_r0_body.st9.s3
  S2 := PRE_first_tail_x6_r0_body.st9.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st9.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st9.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st9.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st9.bodyHalt
  last := PRE_first_tail_x6_r0_body.st9.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st9.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC10
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 10 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s112` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa10` into the merged state
`PRE_first_tail_x6_r0_body.s111`. -/

def PRE_first_tail_x6_r0_body.pl10 : List Nat := []
def PRE_first_tail_x6_r0_body.nr10 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd10 : RData :=
  ⟨2683093, 2683095, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18410, 18410, 15492, 15492, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa10 : Map :=
  Conv.Map.compact 2683093 2683095 506 PRE_first_tail_x6_r0_body.pl10 (PRE_first_tail_x6_r0_body.nr10.map NumV.ref) PRE_first_tail_x6_r0_body.kd10.big
    PRE_first_tail_x6_r0_body.kd10.region PRE_first_tail_x6_r0_body.kd10.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws10 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs10 : List SymE := PRE_first_tail_x6_r0_body.nr10.map fun r => (nth? PRE_first_tail_x6_r0_body.S111.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta10 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws10 PRE_first_tail_x6_r0_body.crs10
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB10 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab10 : PRE_first_tail_x6_r0_body.S112.tab = PRE_first_tail_x6_r0_body.S110.tab ++ PRE_first_tail_x6_r0_body.cws10.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace10 : PRE_first_tail_x6_r0_body.s112.trace = PRE_first_tail_x6_r0_body.s110.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext10 : PRE_first_tail_x6_r0_body.s112.next = 2683093
kernel_rfl PRE_first_tail_x6_r0_body.ccounters10 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx.nnext) = (18410, 15492)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue10 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s111.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa10.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp10 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx.tokens.all (bSN 506) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean10 : Conv.cleanListB 18410 131072 (fun r => Nat.ble 73640 r) PRE_first_tail_x6_r0_body.s112
    (PRE_first_tail_x6_r0_body.wrB10 ++ (List.range 0).map (2683093 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs10 : bigsOutB 18410 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK10
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl10`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl10 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo10 : List Nat := []
def PRE_first_tail_x6_r0_body.cln10 : List Nat := []
def PRE_first_tail_x6_r0_body.cli10 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap10 : PRE_first_tail_x6_r0_body.s112.heap = Stage.setAll PRE_first_tail_x6_r0_body.s110.heap (PRE_first_tail_x6_r0_body.cl10.filterMap fun a => (PRE_first_tail_x6_r0_body.s112.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe10 : Nat.ble PRE_first_tail_x6_r0_body.s110.next PRE_first_tail_x6_r0_body.s112.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP10 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s110 PRE_first_tail_x6_r0_body.s112 PRE_first_tail_x6_r0_body.cl10 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp10 : Conv.suppListB PRE_first_tail_x6_r0_body.s112 506 PRE_first_tail_x6_r0_body.cl10 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound10 : Conv.boundListB PRE_first_tail_x6_r0_body.s112 PRE_first_tail_x6_r0_body.cl10 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK10 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln10.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK10 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo10.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK10 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli10.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst10 : Conv.sstListB 506 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx PRE_first_tail_x6_r0_body.cln10 PRE_first_tail_x6_r0_body.clo10 PRE_first_tail_x6_r0_body.cli10 = true

end Host.Load.Run.Tpl
end

section -- SiteCl10
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA10 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo10.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd10 : (PRE_first_tail_x6_r0_body.clo10 ++ PRE_first_tail_x6_r0_body.cln10 ++ PRE_first_tail_x6_r0_body.cli10).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle10 : Conv.Cnt.leB (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck10 : Conv.ncleanListB (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx PRE_first_tail_x6_r0_body.clo10 PRE_first_tail_x6_r0_body.cln10 PRE_first_tail_x6_r0_body.cli10 = true
theorem PRE_first_tail_x6_r0_body.cncl10 (h : Conv.NClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx) : Conv.NClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle10 PRE_first_tail_x6_r0_body.ckA10 PRE_first_tail_x6_r0_body.cobjsK10 PRE_first_tail_x6_r0_body.cnodesK10 PRE_first_tail_x6_r0_body.citemsK10 PRE_first_tail_x6_r0_body.cbd10 PRE_first_tail_x6_r0_body.cck10

end Host.Load.Run.Tpl
end
