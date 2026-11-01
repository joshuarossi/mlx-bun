import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
import host.sim.conv.Closed
import host.sim.conv.NClean
import host.sim.conv.CompactFull
import host.sim.template.FootGen
import host.sim.template.a4pre_first_tail_x15_r0_body.States
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B00
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
import host.sim.conv.CallPieces
import host.sim.stage.Mlx
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
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen

section -- SiteK99
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl99`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl99 : List Nat := [2665, 2672553, 2673467, 2752225, 2752770, 2753026, 2753051, 2753052, 2753053, 2753054, 2753055, 2753056]
def PRE_first_tail_x15_r0_body.clo99 : List Nat := [20141, 20154, 20160, 20161, 20162, 20163]
def PRE_first_tail_x15_r0_body.cln99 : List Nat := [17237, 17238, 17239, 17240, 17241, 17242, 17243, 17244, 17245, 17246, 17247, 17248, 17249, 17250, 17251, 17252, 17253, 17254, 17255, 17256, 17257, 17258, 17259, 17260, 17261, 17262, 17263]
def PRE_first_tail_x15_r0_body.cli99 : List Nat := [17237, 17238, 17239, 17240, 17241, 17242, 17243, 17244, 17245, 17246, 17247, 17248, 17249, 17250, 17251, 17252, 17253, 17254, 17255, 17256, 17257, 17258, 17259, 17260, 17261, 17262, 17263]
kernel_rfl PRE_first_tail_x15_r0_body.cheap99 : PRE_first_tail_x15_r0_body.s967.heap = Stage.setAll PRE_first_tail_x15_r0_body.s965.heap (PRE_first_tail_x15_r0_body.cl99.filterMap fun a => (PRE_first_tail_x15_r0_body.s967.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe99 : Nat.ble PRE_first_tail_x15_r0_body.s965.next PRE_first_tail_x15_r0_body.s967.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP99 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s965 PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.cl99 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp99 : Conv.suppListB PRE_first_tail_x15_r0_body.s967 4334 PRE_first_tail_x15_r0_body.cl99 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound99 : Conv.boundListB PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.cl99 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK99 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln99.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK99 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo99.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK99 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli99.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst99 : Conv.sstListB 4334 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx PRE_first_tail_x15_r0_body.cln99 PRE_first_tail_x15_r0_body.clo99 PRE_first_tail_x15_r0_body.cli99 = true

end Host.Load.Run.Tpl
end

section -- SiteCl99
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA99 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo99.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd99 : (PRE_first_tail_x15_r0_body.clo99 ++ PRE_first_tail_x15_r0_body.cln99 ++ PRE_first_tail_x15_r0_body.cli99).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle99 : Conv.Cnt.leB (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) (⟨20164, 17264, 2753057, 4334⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck99 : Conv.ncleanListB (⟨20164, 17264, 2753057, 4334⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx PRE_first_tail_x15_r0_body.clo99 PRE_first_tail_x15_r0_body.cln99 PRE_first_tail_x15_r0_body.cli99 = true
theorem PRE_first_tail_x15_r0_body.cncl99 (h : Conv.NClean (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx) : Conv.NClean (⟨20164, 17264, 2753057, 4334⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle99 PRE_first_tail_x15_r0_body.ckA99 PRE_first_tail_x15_r0_body.cobjsK99 PRE_first_tail_x15_r0_body.cnodesK99 PRE_first_tail_x15_r0_body.citemsK99 PRE_first_tail_x15_r0_body.cbd99 PRE_first_tail_x15_r0_body.cck99

end Host.Load.Run.Tpl
end

section -- SiteS99
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 99 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc99 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P99 : LoadP := PRE_first_tail_x15_r0_body.Pc99.raise 17264
kernel_rfl PRE_first_tail_x15_r0_body.craise99 : Nat.ble PRE_first_tail_x15_r0_body.Pc99.N0 17264 = true
theorem PRE_first_tail_x15_r0_body.raised99 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc99 PRE_first_tail_x15_r0_body.P99 :=
  .inr ⟨17264, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise99, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_99 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_99 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s966.ffi)
def PRE_first_tail_x15_r0_body.khinv99 : PTrie Nat := Stage.setAll PTrie.nil [(20187, 20161), (20165, 20162), (20188, 20163)]
def PRE_first_tail_x15_r0_body.kninv99 : PTrie Nat := Stage.setAll PTrie.nil [(17237, 17237), (17238, 17238), (17239, 17239), (17240, 17240), (17241, 17241), (17242, 17242), (17243, 17243), (17244, 17244), (17245, 17245), (17246, 17246), (17247, 17247), (17248, 17248), (17249, 17249), (17250, 17250), (17251, 17251), (17252, 17252), (17253, 17253), (17254, 17254), (17255, 17255), (17256, 17256), (17257, 17257), (17258, 17258), (17259, 17259), (17260, 17260), (17261, 17261), (17262, 17262), (17263, 17263)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS99 : List Nat := [20141, 20154, 20160, 20161, 20162, 20163, 20164, 20165, 20166, 20167, 20168, 20169, 20170, 20171, 20172, 20173, 20174, 20175, 20176, 20177, 20178, 20179, 20180, 20181, 20182, 20183, 20184, 20185, 20186, 20187, 20188]
def PRE_first_tail_x15_r0_body.cnS99 : List Nat := List.range' 17237 27
def PRE_first_tail_x15_r0_body.ciS99 : List Nat := [] ++ List.range' 17237 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh099 : PRE_first_tail_x15_r0_body.kd99.nh0 = PRE_first_tail_x15_r0_body.cx0_99.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh199 : PRE_first_tail_x15_r0_body.kd99.nh1 = PRE_first_tail_x15_r0_body.cx1_99.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn099 : PRE_first_tail_x15_r0_body.kd99.nn0 = PRE_first_tail_x15_r0_body.cx0_99.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn199 : PRE_first_tail_x15_r0_body.kd99.nn1 = PRE_first_tail_x15_r0_body.cx1_99.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo99 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P99.lo && Nat.ble PRE_first_tail_x15_r0_body.P99.lo PRE_first_tail_x15_r0_body.cx0_99.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P99.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P99.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt99 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_99.mlx.next PRE_first_tail_x15_r0_body.cx1_99.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_99.mlx.nnext PRE_first_tail_x15_r0_body.cx1_99.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband99 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P99.NL && Nat.ble PRE_first_tail_x15_r0_body.P99.NL PRE_first_tail_x15_r0_body.P99.N0 && Nat.ble PRE_first_tail_x15_r0_body.P99.N0 PRE_first_tail_x15_r0_body.cx0_99.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow99 : PRE_first_tail_x15_r0_body.kd99.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren99 : checkRenG PRE_first_tail_x15_r0_body.kd99.hnd PRE_first_tail_x15_r0_body.khinv99 (phB PRE_first_tail_x15_r0_body.cx0_99.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband99 : PRE_first_tail_x15_r0_body.kd99.checkBand PRE_first_tail_x15_r0_body.P99.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos99 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd99.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren99 : checkRenG PRE_first_tail_x15_r0_body.kd99.node PRE_first_tail_x15_r0_body.kninv99 (pnB PRE_first_tail_x15_r0_body.cx0_99.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P99.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd99.nodeF j) PRE_first_tail_x15_r0_body.cx1_99.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a99 : PRE_first_tail_x15_r0_body.cx0_99.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b99 : PRE_first_tail_x15_r0_body.cx0_99.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok199 : PRE_first_tail_x15_r0_body.cx1_99.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.pending = PRE_first_tail_x15_r0_body.cx0_99.mlx.pending.map PRE_first_tail_x15_r0_body.kappa99.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.errh = PRE_first_tail_x15_r0_body.cx0_99.mlx.errh.map PRE_first_tail_x15_r0_body.kappa99.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.files = PRE_first_tail_x15_r0_body.cx0_99.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.arch = PRE_first_tail_x15_r0_body.cx0_99.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_99.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.wired = PRE_first_tail_x15_r0_body.cx0_99.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost99 : PRE_first_tail_x15_r0_body.cx1_99.host = PRE_first_tail_x15_r0_body.cx0_99.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd99`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn099 : PRE_first_tail_x15_r0_body.kd99.n0 = 2753057
kernel_rfl PRE_first_tail_x15_r0_body.ckn199 : PRE_first_tail_x15_r0_body.kd99.n1 = 2754206
kernel_rfl PRE_first_tail_x15_r0_body.ckheap99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.heap).all (fun x => Nat.ble 2753051 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl99 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd99.heap.get (2753051 + j) = nth? PRE_first_tail_x15_r0_body.pl99 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja99 : Nat.ble 2753051 2753051 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn99 : Nat.ble 4316 4316 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD99 : Nat.ble 2753051 PRE_first_tail_x15_r0_body.kd99.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn99 : Nat.ble 20161 PRE_first_tail_x15_r0_body.kd99.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn99 : Nat.ble 17237 PRE_first_tail_x15_r0_body.kd99.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb99 : Nat.ble 20161 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.heap).all (Nat.ble (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.hnd).all (Nat.ble (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.node).all (Nat.ble (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix99 : Conv.FixOld (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa99 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja99) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn99) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD99) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn99) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn99) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb99) PRE_first_tail_x15_r0_body.fheap99 PRE_first_tail_x15_r0_body.fhnd99 PRE_first_tail_x15_r0_body.fnode99
kernel_rfl PRE_first_tail_x15_r0_body.fcxn99 : (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn99 : (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle099 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_99.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_99.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS99.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_99.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS99.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_99.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS99.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_99.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS99.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_99.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd99 : (PRE_first_tail_x15_r0_body.clo99 ++ PRE_first_tail_x15_r0_body.cln99 ++ PRE_first_tail_x15_r0_body.cli99 ++ PRE_first_tail_x15_r0_body.cwS99 ++ PRE_first_tail_x15_r0_body.cnS99 ++ PRE_first_tail_x15_r0_body.ciS99).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW99 : PRE_first_tail_x15_r0_body.cwS99.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo99.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI99 : PRE_first_tail_x15_r0_body.ciS99.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli99.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN99 : PRE_first_tail_x15_r0_body.cnS99.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF99 : PRE_first_tail_x15_r0_body.cln99.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh99 : PRE_first_tail_x15_r0_body.clo99.all (handleOK PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.P99.lo PRE_first_tail_x15_r0_body.cx0_99.mlx PRE_first_tail_x15_r0_body.cx1_99.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo99 : PRE_first_tail_x15_r0_body.clo99.map (fun h => PRE_first_tail_x15_r0_body.cx1_99.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa99.handle h)) = PRE_first_tail_x15_r0_body.clo99.map (fun h => (PRE_first_tail_x15_r0_body.cx0_99.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa99.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok99 : PRE_first_tail_x15_r0_body.clo99.all (objOK PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.P99.NL PRE_first_tail_x15_r0_body.cx0_99.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd99 : PRE_first_tail_x15_r0_body.cln99.all (nodeOKF PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.P99 PRE_first_tail_x15_r0_body.cx0_99.mlx PRE_first_tail_x15_r0_body.cx1_99.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp99 : ((PRE_first_tail_x15_r0_body.cln99.filter (fullB PRE_first_tail_x15_r0_body.P99))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_99.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa99.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln99.filter (fullB PRE_first_tail_x15_r0_body.P99))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_99.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa99.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI99 : incrB PRE_first_tail_x15_r0_body.kd99.nodeF (List.range' 17237 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.node).all (fun k => Nat.ble 17237 k && Nat.blt k 17264) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL99 : (PRE_first_tail_x15_r0_body.cln99.filter (Nat.ble PRE_first_tail_x15_r0_body.P99.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd99.nodeF i) && (Nat.blt i 17264 || Nat.ble PRE_first_tail_x15_r0_body.kd99.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord99 : (PRE_first_tail_x15_r0_body.cln99.filter (Nat.ble PRE_first_tail_x15_r0_body.P99.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd99.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd99.nodeF j) (PRE_first_tail_x15_r0_body.kd99.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow99 PRE_first_tail_x15_r0_body.cnn199 PRE_first_tail_x15_r0_body.fnordI99 PRE_first_tail_x15_r0_body.fnordK99 PRE_first_tail_x15_r0_body.fnordL99
kernel_rfl PRE_first_tail_x15_r0_body.fi99 : PRE_first_tail_x15_r0_body.cli99.all (pnB PRE_first_tail_x15_r0_body.cx0_99.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii99 : PRE_first_tail_x15_r0_body.cli99.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_99.mlx.items.get (PRE_first_tail_x15_r0_body.kappa99.node k) = (PRE_first_tail_x15_r0_body.cx0_99.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa99.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot99 (clean : Conv.NClean (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P99.NL) (cl : SSt (· < 4334) PRE_first_tail_x15_r0_body.cx0_99.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P99 4334 PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.kd99 PRE_first_tail_x15_r0_body.khinv99 PRE_first_tail_x15_r0_body.kninv99 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx PRE_first_tail_x15_r0_body.cx0_99.mlx PRE_first_tail_x15_r0_body.cx1_99.mlx (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo99 PRE_first_tail_x15_r0_body.cln99 PRE_first_tail_x15_r0_body.cli99 PRE_first_tail_x15_r0_body.cwS99 PRE_first_tail_x15_r0_body.cnS99 PRE_first_tail_x15_r0_body.ciS99 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh099, PRE_first_tail_x15_r0_body.cnh199, PRE_first_tail_x15_r0_body.cnn099, PRE_first_tail_x15_r0_body.cnn199, PRE_first_tail_x15_r0_body.cplo99, PRE_first_tail_x15_r0_body.ccnt99, PRE_first_tail_x15_r0_body.cnband99, PRE_first_tail_x15_r0_body.chbelow99, PRE_first_tail_x15_r0_body.chren99, PRE_first_tail_x15_r0_body.cband99, PRE_first_tail_x15_r0_body.cnh1pos99, PRE_first_tail_x15_r0_body.cnren99, PRE_first_tail_x15_r0_body.cnlow99, PRE_first_tail_x15_r0_body.cabs0a99, PRE_first_tail_x15_r0_body.cabs0b99, PRE_first_tail_x15_r0_body.ctok199, PRE_first_tail_x15_r0_body.cpend99, PRE_first_tail_x15_r0_body.cerrh99, PRE_first_tail_x15_r0_body.cfiles99, PRE_first_tail_x15_r0_body.carch99, PRE_first_tail_x15_r0_body.csizes99, PRE_first_tail_x15_r0_body.cwired99, PRE_first_tail_x15_r0_body.cfix99, clean, PRE_first_tail_x15_r0_body.fcxn99, PRE_first_tail_x15_r0_body.fcnn99, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle099, PRE_first_tail_x15_r0_body.fnk99, PRE_first_tail_x15_r0_body.ckA99, PRE_first_tail_x15_r0_body.cobjsK99, PRE_first_tail_x15_r0_body.cnodesK99, PRE_first_tail_x15_r0_body.citemsK99, PRE_first_tail_x15_r0_body.f1A99, PRE_first_tail_x15_r0_body.f1O99, PRE_first_tail_x15_r0_body.f1N99, PRE_first_tail_x15_r0_body.f1I99, PRE_first_tail_x15_r0_body.fbd99, PRE_first_tail_x15_r0_body.fincW99, PRE_first_tail_x15_r0_body.fincI99, PRE_first_tail_x15_r0_body.fincN99, PRE_first_tail_x15_r0_body.flnF99, PRE_first_tail_x15_r0_body.fh99, PRE_first_tail_x15_r0_body.fo99, PRE_first_tail_x15_r0_body.fok99, PRE_first_tail_x15_r0_body.fnd99, PRE_first_tail_x15_r0_body.fp99, PRE_first_tail_x15_r0_body.fnord99, PRE_first_tail_x15_r0_body.fi99, PRE_first_tail_x15_r0_body.fii99⟩
theorem PRE_first_tail_x15_r0_body.cnshift99 (clean : Conv.NClean (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P99.NL) (cl : SSt (· < 4334) PRE_first_tail_x15_r0_body.cx0_99.mlx) : NShift PRE_first_tail_x15_r0_body.P99 4334 PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.cx0_99 PRE_first_tail_x15_r0_body.cx1_99 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot99 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost99 (compact_a_eq PRE_first_tail_x15_r0_body.ckn099 PRE_first_tail_x15_r0_body.ckn199 PRE_first_tail_x15_r0_body.ckheap99 PRE_first_tail_x15_r0_body.ckpl99)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_99 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s965.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_99 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s965.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_99 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s965.ffi) = some PRE_first_tail_x15_r0_body.fxC_99
kernel_rfl PRE_first_tail_x15_r0_body.okrC_99 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s965.ffi) = some PRE_first_tail_x15_r0_body.krC_99
noncomputable def PRE_first_tail_x15_r0_body.fx0_99 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s967.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_99 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s967.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_99 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s967.ffi) = some PRE_first_tail_x15_r0_body.fx0_99
kernel_rfl PRE_first_tail_x15_r0_body.okr0_99 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s967.ffi) = some PRE_first_tail_x15_r0_body.kr0_99
noncomputable def PRE_first_tail_x15_r0_body.fx1_99 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s966.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_99 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s966.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_99 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s966.ffi) = some PRE_first_tail_x15_r0_body.fx1_99
kernel_rfl PRE_first_tail_x15_r0_body.okr1_99 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s966.ffi) = some PRE_first_tail_x15_r0_body.kr1_99
kernel_rfl PRE_first_tail_x15_r0_body.ff099 : PRE_first_tail_x15_r0_body.fx0_99 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_99 (PRE_first_tail_x15_r0_body.clo99.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_99.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff199 : PRE_first_tail_x15_r0_body.fx1_99 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_99 (PRE_first_tail_x15_r0_body.cwS99.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_99.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck99 : freedLB PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.cx0_99.mlx PRE_first_tail_x15_r0_body.fx0_99 PRE_first_tail_x15_r0_body.fx1_99 PRE_first_tail_x15_r0_body.clo99 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf099 : PRE_first_tail_x15_r0_body.kr0_99.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_99.flags (PRE_first_tail_x15_r0_body.clo99.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_99.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt099 : PRE_first_tail_x15_r0_body.kr0_99.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_99.targs (PRE_first_tail_x15_r0_body.clo99.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_99.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf199 : PRE_first_tail_x15_r0_body.kr1_99.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_99.flags (PRE_first_tail_x15_r0_body.cwS99.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_99.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt199 : PRE_first_tail_x15_r0_body.kr1_99.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_99.targs (PRE_first_tail_x15_r0_body.cwS99.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_99.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck99 : krecLB PRE_first_tail_x15_r0_body.kappa99 4334 PRE_first_tail_x15_r0_body.cx0_99.mlx PRE_first_tail_x15_r0_body.kr0_99 PRE_first_tail_x15_r0_body.kr1_99 PRE_first_tail_x15_r0_body.clo99 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn99 : Nat.ble 4316 4334 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge99 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s966.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s967.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR99 : pendRegB PRE_first_tail_x15_r0_body.kappa99 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe99 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s966.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift99 (clean : Conv.NClean (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P99.NL) (cl : SSt (· < 4334) PRE_first_tail_x15_r0_body.cx0_99.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_99.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_99.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_99.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_99.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P99 4334 PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.s967.ffi PRE_first_tail_x15_r0_body.s966.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift99 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue99, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp99 t ht),
    PRE_first_tail_x15_r0_body.cbridge99,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s967.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s966.ffi) (PRE_first_tail_x15_r0_body.cfoot99 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_99 PRE_first_tail_x15_r0_body.ofx1_99 hobjC PRE_first_tail_x15_r0_body.ff099 PRE_first_tail_x15_r0_body.ff199 PRE_first_tail_x15_r0_body.ffck99,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s967.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s966.ffi) (PRE_first_tail_x15_r0_body.cfoot99 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_99 PRE_first_tail_x15_r0_body.okr1_99 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn99) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf099 PRE_first_tail_x15_r0_body.fkt099 PRE_first_tail_x15_r0_body.fkf199 PRE_first_tail_x15_r0_body.fkt199 PRE_first_tail_x15_r0_body.fkck99,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh099 PRE_first_tail_x15_r0_body.cnh199 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe99) PRE_first_tail_x15_r0_body.cpendR99⟩

end Host.Load.Run.Tpl
end

section -- st99/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st99 0
host_stream_state PRE_first_tail_x15_r0_body.st99 1
host_stream_state PRE_first_tail_x15_r0_body.st99 2
host_stream_state PRE_first_tail_x15_r0_body.st99 3
host_stream_state PRE_first_tail_x15_r0_body.st99 4
host_stream_state PRE_first_tail_x15_r0_body.st99 5
end Host.Load.Run.Tpl
end

section -- Site99
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 99 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g99__g100` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s965`, the merged state `PRE_first_tail_x15_r0_body.s966`,
the site template `PRE_first_tail_x15_r0_body.st99` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s967`: the merge.
The footprint's facts are in `SiteF99`, the compaction's in `SiteC99`, `SiteK99`, `SiteNa99`, `SiteNb99`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso99 : PRE_first_tail_x15_r0_body.st99.s0 = { PRE_first_tail_x15_r0_body.s965 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs99 : List Frame := PRE_first_tail_x15_r0_body.s965.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_99 : PRE_first_tail_x15_r0_body.S965.tab.length = 4316
kernel_rfl PRE_first_tail_x15_r0_body.tab0_99 : PRE_first_tail_x15_r0_body.st99.S0.tab = PRE_first_tail_x15_r0_body.S965.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws99 : List Nat := [2658, 2659, 2660, 2661, 2662, 2663, 2664, 2665, 2666, 2667, 2668, 2669, 2670, 2671, 2672, 2673, 2674, 2675, 2676, 2677, 2678, 2679, 2680, 2681, 2682, 2683, 2684, 2685, 2686, 2687, 2688]
kernel_rfl PRE_first_tail_x15_r0_body.fresh99 : (PRE_first_tail_x15_r0_body.S965.tab.all fun e => PRE_first_tail_x15_r0_body.ws99.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S965.oracle.all fun q => PRE_first_tail_x15_r0_body.ws99.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab99 : PRE_first_tail_x15_r0_body.S966.tab = PRE_first_tail_x15_r0_body.S965.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws99
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen99 : PRE_first_tail_x15_r0_body.st99.S5.tab.length - PRE_first_tail_x15_r0_body.st99.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged99`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap99 : PRE_first_tail_x15_r0_body.s966.heap = PRE_first_tail_x15_r0_body.st99.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext99 : PRE_first_tail_x15_r0_body.s966.next = PRE_first_tail_x15_r0_body.st99.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl99 : PRE_first_tail_x15_r0_body.s966.ctl = PRE_first_tail_x15_r0_body.st99.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack99 : PRE_first_tail_x15_r0_body.s966.stack = PRE_first_tail_x15_r0_body.st99.s5.stack ++ PRE_first_tail_x15_r0_body.s965.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs99 : PRE_first_tail_x15_r0_body.s966.jobs = PRE_first_tail_x15_r0_body.st99.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi99 : PRE_first_tail_x15_r0_body.s966.ffi = PRE_first_tail_x15_r0_body.st99.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace99 : PRE_first_tail_x15_r0_body.s966.trace = PRE_first_tail_x15_r0_body.st99.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores99 : PRE_first_tail_x15_r0_body.s966.stores = PRE_first_tail_x15_r0_body.st99.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD99
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 99 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived99 : PRE_first_tail_x15_r0_body.nr99.map (fun r => nth? PRE_first_tail_x15_r0_body.st99.S5.tab r) =
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
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo99 : PRE_first_tail_x15_r0_body.nr99.all (Nat.ble 4316) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj99 : PRE_first_tail_x15_r0_body.cws99.all (fun c => !PRE_first_tail_x15_r0_body.ws99.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ99 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws99 PRE_first_tail_x15_r0_body.crs99 PRE_first_tail_x15_r0_body.ws99

end Host.Load.Run.Tpl
end

section -- st99/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st99`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st99.wrR : List (Nat × Nat) := [(2672553, 2672554), (2752225, 2752226), (2752770, 2752771), (2753026, 2753027)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st99.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st99.s5.heap PRE_first_tail_x15_r0_body.st99.wrR ++ freshOf PRE_first_tail_x15_r0_body.st99.s5.heap PRE_first_tail_x15_r0_body.st99.s0.next PRE_first_tail_x15_r0_body.st99.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st99.wr : List Nat := PRE_first_tail_x15_r0_body.st99.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st99.heapFoot : PRE_first_tail_x15_r0_body.st99.s5.heap = setAll PRE_first_tail_x15_r0_body.st99.s0.heap PRE_first_tail_x15_r0_body.st99.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st99.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st99.s0.next PRE_first_tail_x15_r0_body.st99.s5.next = true
theorem PRE_first_tail_x15_r0_body.st99.grows : PRE_first_tail_x15_r0_body.st99.s0.next ≤ PRE_first_tail_x15_r0_body.st99.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st99.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st99.wh : List Nat := [20141, 20154, 20160, 20161, 20162, 20163, 20164, 20165, 20166, 20167, 20168, 20169, 20170, 20171, 20172, 20173, 20174, 20175, 20176, 20177, 20178, 20179, 20180, 20181, 20182, 20183, 20184, 20185, 20186, 20187, 20188]
def PRE_first_tail_x15_r0_body.st99.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st99.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st99.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st99.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st99.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st99.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st99.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st99.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st99.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF99
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 99 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB99 : nodupT PRE_first_tail_x15_r0_body.st99.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup99 : PRE_first_tail_x15_r0_body.st99.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB99).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB99 : PRE_first_tail_x15_r0_body.st99.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound99 : ∀ b ∈ PRE_first_tail_x15_r0_body.st99.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB99 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr99 := PRE_first_tail_x15_r0_body.st99.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq99 : PRE_first_tail_x15_r0_body.st99.s5.trace = PRE_first_tail_x15_r0_body.trFr99 ++ PRE_first_tail_x15_r0_body.st99.s0.trace
theorem PRE_first_tail_x15_r0_body.trace99 : ∃ fr, PRE_first_tail_x15_r0_body.st99.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st99.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq99⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide99 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB99 : (PRE_first_tail_x15_r0_body.wide99.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st99.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix99 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide99, WFix Map.id (Present PRE_first_tail_x15_r0_body.st99.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB99 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL99
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 99 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s966`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO99 : PRE_first_tail_x15_r0_body.st99.S0.oracle = PRE_first_tail_x15_r0_body.st99.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B99 : PRE_first_tail_x15_r0_body.st99.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st99.s0.next || (PRE_first_tail_x15_r0_body.st99.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot99 : Conv.StageFoot PRE_first_tail_x15_r0_body.st99.wr PRE_first_tail_x15_r0_body.st99.s0 PRE_first_tail_x15_r0_body.st99.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st99.heapFoot PRE_first_tail_x15_r0_body.wrNodup99 PRE_first_tail_x15_r0_body.wrBound99 PRE_first_tail_x15_r0_body.wr0B99 PRE_first_tail_x15_r0_body.st99.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged99 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st99.F.S → PRE_first_tail_x15_r0_body.st99.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st99.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st99.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs99 PRE_first_tail_x15_r0_body.st99.wr PRE_first_tail_x15_r0_body.s965 PRE_first_tail_x15_r0_body.st99.s5 PRE_first_tail_x15_r0_body.st99.s0
      PRE_first_tail_x15_r0_body.st99.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st99.F FR W stk M ν K PRE_first_tail_x15_r0_body.s966 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso99 PRE_first_tail_x15_r0_body.stFoot99 PRE_first_tail_x15_r0_body.wrNodup99 PRE_first_tail_x15_r0_body.wrBound99 PRE_first_tail_x15_r0_body.trace99 PRE_first_tail_x15_r0_body.mheap99
    PRE_first_tail_x15_r0_body.mnext99 PRE_first_tail_x15_r0_body.mctl99 PRE_first_tail_x15_r0_body.mstack99 PRE_first_tail_x15_r0_body.mjobs99 PRE_first_tail_x15_r0_body.mffi99 PRE_first_tail_x15_r0_body.mtrace99 PRE_first_tail_x15_r0_body.mstores99 h

def PRE_first_tail_x15_r0_body.arrEl99_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE99_2665 : arrOf PRE_first_tail_x15_r0_body.s966 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl99_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA99_2665 : isArrB PRE_first_tail_x15_r0_body.s966 2665 = true
theorem PRE_first_tail_x15_r0_body.arr99_2665 : ∃ o, PRE_first_tail_x15_r0_body.s966.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl99_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE99_2665 PRE_first_tail_x15_r0_body.arrA99_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN99_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl99_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR99_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl99_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN99_2665

def PRE_first_tail_x15_r0_body.arrEl99_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE99_2673467 : arrOf PRE_first_tail_x15_r0_body.s966 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl99_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA99_2673467 : isArrB PRE_first_tail_x15_r0_body.s966 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr99_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s966.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl99_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE99_2673467 PRE_first_tail_x15_r0_body.arrA99_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN99_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl99_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR99_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl99_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN99_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k99 : isArrB PRE_first_tail_x15_r0_body.s966 4910 = false
theorem PRE_first_tail_x15_r0_body.keep99 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s966 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k99 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr99_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl99_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ99
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 99 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s965`, the merged
state `PRE_first_tail_x15_r0_body.s966`, the canonical state `PRE_first_tail_x15_r0_body.s967`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl99 : PRE_first_tail_x15_r0_body.pl99.all (Nat.ble PRE_first_tail_x15_r0_body.s965.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd99 : nodupT PRE_first_tail_x15_r0_body.pl99 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn199 : Nat.ble PRE_first_tail_x15_r0_body.s965.next 2754206 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst99 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s965.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn99 : PRE_first_tail_x15_r0_body.s967.next = PRE_first_tail_x15_r0_body.s965.next + PRE_first_tail_x15_r0_body.pl99.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn99 : PRE_first_tail_x15_r0_body.s966.next = 2754206
kernel_rfl PRE_first_tail_x15_r0_body.zgrow99 : Nat.ble PRE_first_tail_x15_r0_body.s967.next PRE_first_tail_x15_r0_body.s966.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh99 : PRE_first_tail_x15_r0_body.S965.tab.all (fun e => PRE_first_tail_x15_r0_body.cws99.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd99 : nodupT PRE_first_tail_x15_r0_body.cws99 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi99 : PRE_first_tail_x15_r0_body.nr99.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S966.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt99 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s965.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg99_2665 : PRE_first_tail_x15_r0_body.s967.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s967 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk99_2665 : (objOf PRE_first_tail_x15_r0_body.s967 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm99_2665 : PRE_first_tail_x15_r0_body.s966.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa99.obj (objOf PRE_first_tail_x15_r0_body.s967 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s966 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg99_2673467 : PRE_first_tail_x15_r0_body.s967.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s967 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk99_2673467 : (objOf PRE_first_tail_x15_r0_body.s967 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm99_2673467 : PRE_first_tail_x15_r0_body.s966.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa99.obj (objOf PRE_first_tail_x15_r0_body.s967 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s966 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw99_4910 : (PRE_first_tail_x15_r0_body.s967.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw99_2673472 : (PRE_first_tail_x15_r0_body.s967.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw99_2673473 : (PRE_first_tail_x15_r0_body.s967.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd99 : PRE_first_tail_x15_r0_body.cl99.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr99 : PRE_first_tail_x15_r0_body.st99.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s965.next || PRE_first_tail_x15_r0_body.cl99.contains b) = true
def PRE_first_tail_x15_r0_body.zl99 : List Nat := PRE_first_tail_x15_r0_body.cl99.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE99 : PRE_first_tail_x15_r0_body.zl99.map (fun a => PRE_first_tail_x15_r0_body.s966.heap.get (PRE_first_tail_x15_r0_body.kappa99.a a)) = PRE_first_tail_x15_r0_body.zl99.map (fun a => (PRE_first_tail_x15_r0_body.s967.heap.get a).map PRE_first_tail_x15_r0_body.kappa99.hobj)
theorem PRE_first_tail_x15_r0_body.zimg99 : HeapImg PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.s966 PRE_first_tail_x15_r0_body.zl99 := PRE_first_tail_x15_r0_body.zimgE99
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl99 : PRE_first_tail_x15_r0_body.s966.ctl = PRE_first_tail_x15_r0_body.kappa99.ctl PRE_first_tail_x15_r0_body.s967.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack99 : PRE_first_tail_x15_r0_body.s966.stack = PRE_first_tail_x15_r0_body.s967.stack.map PRE_first_tail_x15_r0_body.kappa99.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs99 : PRE_first_tail_x15_r0_body.s966.jobs = PRE_first_tail_x15_r0_body.s967.jobs.map PRE_first_tail_x15_r0_body.kappa99.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores99 : PRE_first_tail_x15_r0_body.s966.stores = PRE_first_tail_x15_r0_body.kappa99.stores PRE_first_tail_x15_r0_body.s967.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots99 : checkRootsSupp PRE_first_tail_x15_r0_body.s967 4334 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC99 : PRE_first_tail_x15_r0_body.S965.tab.length + PRE_first_tail_x15_r0_body.cws99.length = 4334
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap99 : PRE_first_tail_x15_r0_body.kappa99 = Conv.Map.compact PRE_first_tail_x15_r0_body.s965.next 2754206 PRE_first_tail_x15_r0_body.S965.tab.length PRE_first_tail_x15_r0_body.pl99 (PRE_first_tail_x15_r0_body.nr99.map NumV.ref) PRE_first_tail_x15_r0_body.kd99.big
  PRE_first_tail_x15_r0_body.kd99.region PRE_first_tail_x15_r0_body.kd99.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin99 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s967.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc99 : Conv.jcleanListB (⟨20164, 17264, 2753057, 4334⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.cl99 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB99 : noBigRootsP (fun i => !Conv.oldBigB (⟨20164, 17264, 2753057, 4334⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s967.trace PRE_first_tail_x15_r0_body.s967 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm99 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17237 = true
theorem PRE_first_tail_x15_r0_body.cjcl99 (h : Conv.JClean (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s965) : Conv.JClean (⟨20164, 17264, 2753057, 4334⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s967 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle99)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap99 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd99 a ha)) PRE_first_tail_x15_r0_body.zjc99

end Host.Load.Run.Tpl
end

section -- st99/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st99.bodyLast from PRE_first_tail_x15_r0_body.st99.s4 to PRE_first_tail_x15_r0_body.st99.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st99.F PRE_first_tail_x15_r0_body.st99.s4).run PRE_first_tail_x15_r0_body.st99.S4 = some (PRE_first_tail_x15_r0_body.st99.s5, PRE_first_tail_x15_r0_body.st99.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st99.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st99.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st99.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st99.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st99/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st99.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st99.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st99.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st99.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st99.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st99.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st99.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st99.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st99.s0 PRE_first_tail_x15_r0_body.st99.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st99.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st99.s4 PRE_first_tail_x15_r0_body.st99.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st99/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st99.bodyK0F from PRE_first_tail_x15_r0_body.st99.s0 to PRE_first_tail_x15_r0_body.st99.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st99.ks 0).getD 0) PRE_first_tail_x15_r0_body.st99.s0 PRE_first_tail_x15_r0_body.st99.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st99.s1, PRE_first_tail_x15_r0_body.st99.S1)
theorem PRE_first_tail_x15_r0_body.st99.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st99.ks 0).getD 0) PRE_first_tail_x15_r0_body.st99.s0 PRE_first_tail_x15_r0_body.st99.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st99.s1, PRE_first_tail_x15_r0_body.st99.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st99.bodyOkLN_ok PRE_first_tail_x15_r0_body.st99.bodyK0F
end Host.Load.Run.Tpl
end

section -- st99/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st99.bodyK1F from PRE_first_tail_x15_r0_body.st99.s1 to PRE_first_tail_x15_r0_body.st99.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st99.ks 1).getD 0) PRE_first_tail_x15_r0_body.st99.s1 PRE_first_tail_x15_r0_body.st99.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st99.s2, PRE_first_tail_x15_r0_body.st99.S2)
theorem PRE_first_tail_x15_r0_body.st99.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st99.ks 1).getD 0) PRE_first_tail_x15_r0_body.st99.s1 PRE_first_tail_x15_r0_body.st99.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st99.s2, PRE_first_tail_x15_r0_body.st99.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st99.bodyOkLN_ok PRE_first_tail_x15_r0_body.st99.bodyK1F
end Host.Load.Run.Tpl
end

section -- st99/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st99.bodyK2F from PRE_first_tail_x15_r0_body.st99.s2 to PRE_first_tail_x15_r0_body.st99.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st99.ks 2).getD 0) PRE_first_tail_x15_r0_body.st99.s2 PRE_first_tail_x15_r0_body.st99.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st99.s3, PRE_first_tail_x15_r0_body.st99.S3)
theorem PRE_first_tail_x15_r0_body.st99.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st99.ks 2).getD 0) PRE_first_tail_x15_r0_body.st99.s2 PRE_first_tail_x15_r0_body.st99.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st99.s3, PRE_first_tail_x15_r0_body.st99.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st99.bodyOkLN_ok PRE_first_tail_x15_r0_body.st99.bodyK2F
end Host.Load.Run.Tpl
end

section -- st99/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st99.bodyK3F from PRE_first_tail_x15_r0_body.st99.s3 to PRE_first_tail_x15_r0_body.st99.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st99.ks 3).getD 0) PRE_first_tail_x15_r0_body.st99.s3 PRE_first_tail_x15_r0_body.st99.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st99.s4, PRE_first_tail_x15_r0_body.st99.S4)
theorem PRE_first_tail_x15_r0_body.st99.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st99.ks 3).getD 0) PRE_first_tail_x15_r0_body.st99.s3 PRE_first_tail_x15_r0_body.st99.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st99.s4, PRE_first_tail_x15_r0_body.st99.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st99.bodyOkLN_ok PRE_first_tail_x15_r0_body.st99.bodyK3F
end Host.Load.Run.Tpl
end

section -- st99/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st99.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st99.s0 PRE_first_tail_x15_r0_body.st99.S0 = some (PRE_first_tail_x15_r0_body.st99.s4, PRE_first_tail_x15_r0_body.st99.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st99.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st99.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st99.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st99.ks 3).getD 0) PRE_first_tail_x15_r0_body.st99.s0 PRE_first_tail_x15_r0_body.st99.s3 PRE_first_tail_x15_r0_body.st99.s4 PRE_first_tail_x15_r0_body.st99.S0 PRE_first_tail_x15_r0_body.st99.S3 PRE_first_tail_x15_r0_body.st99.S4 (runOk_trans PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st99.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st99.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st99.ks 2).getD 0) PRE_first_tail_x15_r0_body.st99.s0 PRE_first_tail_x15_r0_body.st99.s2 PRE_first_tail_x15_r0_body.st99.s3 PRE_first_tail_x15_r0_body.st99.S0 PRE_first_tail_x15_r0_body.st99.S2 PRE_first_tail_x15_r0_body.st99.S3 (runOk_trans PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st99.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st99.ks 1).getD 0) PRE_first_tail_x15_r0_body.st99.s0 PRE_first_tail_x15_r0_body.st99.s1 PRE_first_tail_x15_r0_body.st99.s2 PRE_first_tail_x15_r0_body.st99.S0 PRE_first_tail_x15_r0_body.st99.S1 PRE_first_tail_x15_r0_body.st99.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st99.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st99.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st99.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st99.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st99.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st99.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st99.s0
  S0 := PRE_first_tail_x15_r0_body.st99.S0
  s1 := PRE_first_tail_x15_r0_body.st99.s4
  S1 := PRE_first_tail_x15_r0_body.st99.S4
  s2 := PRE_first_tail_x15_r0_body.st99.s5
  S2 := PRE_first_tail_x15_r0_body.st99.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st99.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st99.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st99.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st99.bodyHalt
  last := PRE_first_tail_x15_r0_body.st99.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st99.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC100
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 100 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s975` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa100` into the merged state
`PRE_first_tail_x15_r0_body.s974`. -/

def PRE_first_tail_x15_r0_body.pl100 : List Nat := []
def PRE_first_tail_x15_r0_body.nr100 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd100 : RData :=
  ⟨2753547, 2753549, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20177, 20177, 17277, 17277, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa100 : Map :=
  Conv.Map.compact 2753547 2753549 4355 PRE_first_tail_x15_r0_body.pl100 (PRE_first_tail_x15_r0_body.nr100.map NumV.ref) PRE_first_tail_x15_r0_body.kd100.big
    PRE_first_tail_x15_r0_body.kd100.region PRE_first_tail_x15_r0_body.kd100.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws100 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs100 : List SymE := PRE_first_tail_x15_r0_body.nr100.map fun r => (nth? PRE_first_tail_x15_r0_body.S974.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta100 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws100 PRE_first_tail_x15_r0_body.crs100
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB100 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab100 : PRE_first_tail_x15_r0_body.S975.tab = PRE_first_tail_x15_r0_body.S973.tab ++ PRE_first_tail_x15_r0_body.cws100.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace100 : PRE_first_tail_x15_r0_body.s975.trace = PRE_first_tail_x15_r0_body.s973.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext100 : PRE_first_tail_x15_r0_body.s975.next = 2753547
kernel_rfl PRE_first_tail_x15_r0_body.ccounters100 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.nnext) = (20177, 17277)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue100 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s974.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa100.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp100 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.tokens.all (bSN 4355) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean100 : Conv.cleanListB 20177 131072 (fun r => Nat.ble 80708 r) PRE_first_tail_x15_r0_body.s975
    (PRE_first_tail_x15_r0_body.wrB100 ++ (List.range 0).map (2753547 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs100 : bigsOutB 20177 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK100
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl100`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl100 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo100 : List Nat := []
def PRE_first_tail_x15_r0_body.cln100 : List Nat := []
def PRE_first_tail_x15_r0_body.cli100 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap100 : PRE_first_tail_x15_r0_body.s975.heap = Stage.setAll PRE_first_tail_x15_r0_body.s973.heap (PRE_first_tail_x15_r0_body.cl100.filterMap fun a => (PRE_first_tail_x15_r0_body.s975.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe100 : Nat.ble PRE_first_tail_x15_r0_body.s973.next PRE_first_tail_x15_r0_body.s975.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP100 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s973 PRE_first_tail_x15_r0_body.s975 PRE_first_tail_x15_r0_body.cl100 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp100 : Conv.suppListB PRE_first_tail_x15_r0_body.s975 4355 PRE_first_tail_x15_r0_body.cl100 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound100 : Conv.boundListB PRE_first_tail_x15_r0_body.s975 PRE_first_tail_x15_r0_body.cl100 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK100 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln100.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK100 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo100.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK100 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli100.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst100 : Conv.sstListB 4355 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx PRE_first_tail_x15_r0_body.cln100 PRE_first_tail_x15_r0_body.clo100 PRE_first_tail_x15_r0_body.cli100 = true

end Host.Load.Run.Tpl
end

section -- SiteCl100
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA100 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo100.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd100 : (PRE_first_tail_x15_r0_body.clo100 ++ PRE_first_tail_x15_r0_body.cln100 ++ PRE_first_tail_x15_r0_body.cli100).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle100 : Conv.Cnt.leB (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck100 : Conv.ncleanListB (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx PRE_first_tail_x15_r0_body.clo100 PRE_first_tail_x15_r0_body.cln100 PRE_first_tail_x15_r0_body.cli100 = true
theorem PRE_first_tail_x15_r0_body.cncl100 (h : Conv.NClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx) : Conv.NClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle100 PRE_first_tail_x15_r0_body.ckA100 PRE_first_tail_x15_r0_body.cobjsK100 PRE_first_tail_x15_r0_body.cnodesK100 PRE_first_tail_x15_r0_body.citemsK100 PRE_first_tail_x15_r0_body.cbd100 PRE_first_tail_x15_r0_body.cck100

end Host.Load.Run.Tpl
end

section -- SiteS100
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 100 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc100 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P100 : LoadP := PRE_first_tail_x15_r0_body.Pc100.raise 17277
kernel_rfl PRE_first_tail_x15_r0_body.craise100 : Nat.ble PRE_first_tail_x15_r0_body.Pc100.N0 17277 = true
theorem PRE_first_tail_x15_r0_body.raised100 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc100 PRE_first_tail_x15_r0_body.P100 :=
  .inr ⟨17277, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise100, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_100 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_100 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s974.ffi)
def PRE_first_tail_x15_r0_body.khinv100 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv100 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS100 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS100 : List Nat := List.range' 17277 0
def PRE_first_tail_x15_r0_body.ciS100 : List Nat := [] ++ List.range' 17277 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0100 : PRE_first_tail_x15_r0_body.kd100.nh0 = PRE_first_tail_x15_r0_body.cx0_100.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1100 : PRE_first_tail_x15_r0_body.kd100.nh1 = PRE_first_tail_x15_r0_body.cx1_100.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0100 : PRE_first_tail_x15_r0_body.kd100.nn0 = PRE_first_tail_x15_r0_body.cx0_100.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1100 : PRE_first_tail_x15_r0_body.kd100.nn1 = PRE_first_tail_x15_r0_body.cx1_100.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo100 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P100.lo && Nat.ble PRE_first_tail_x15_r0_body.P100.lo PRE_first_tail_x15_r0_body.cx0_100.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P100.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P100.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt100 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_100.mlx.next PRE_first_tail_x15_r0_body.cx1_100.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_100.mlx.nnext PRE_first_tail_x15_r0_body.cx1_100.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband100 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P100.NL && Nat.ble PRE_first_tail_x15_r0_body.P100.NL PRE_first_tail_x15_r0_body.P100.N0 && Nat.ble PRE_first_tail_x15_r0_body.P100.N0 PRE_first_tail_x15_r0_body.cx0_100.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow100 : PRE_first_tail_x15_r0_body.kd100.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren100 : checkRenG PRE_first_tail_x15_r0_body.kd100.hnd PRE_first_tail_x15_r0_body.khinv100 (phB PRE_first_tail_x15_r0_body.cx0_100.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband100 : PRE_first_tail_x15_r0_body.kd100.checkBand PRE_first_tail_x15_r0_body.P100.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos100 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd100.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren100 : checkRenG PRE_first_tail_x15_r0_body.kd100.node PRE_first_tail_x15_r0_body.kninv100 (pnB PRE_first_tail_x15_r0_body.cx0_100.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P100.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd100.nodeF j) PRE_first_tail_x15_r0_body.cx1_100.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a100 : PRE_first_tail_x15_r0_body.cx0_100.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b100 : PRE_first_tail_x15_r0_body.cx0_100.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.pending = PRE_first_tail_x15_r0_body.cx0_100.mlx.pending.map PRE_first_tail_x15_r0_body.kappa100.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.errh = PRE_first_tail_x15_r0_body.cx0_100.mlx.errh.map PRE_first_tail_x15_r0_body.kappa100.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.files = PRE_first_tail_x15_r0_body.cx0_100.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.arch = PRE_first_tail_x15_r0_body.cx0_100.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_100.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.wired = PRE_first_tail_x15_r0_body.cx0_100.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost100 : PRE_first_tail_x15_r0_body.cx1_100.host = PRE_first_tail_x15_r0_body.cx0_100.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd100`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0100 : PRE_first_tail_x15_r0_body.kd100.n0 = 2753547
kernel_rfl PRE_first_tail_x15_r0_body.ckn1100 : PRE_first_tail_x15_r0_body.kd100.n1 = 2753549
kernel_rfl PRE_first_tail_x15_r0_body.ckheap100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.heap).all (fun x => Nat.ble 2753547 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl100 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd100.heap.get (2753547 + j) = nth? PRE_first_tail_x15_r0_body.pl100 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja100 : Nat.ble 2753547 2753547 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn100 : Nat.ble 4355 4355 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD100 : Nat.ble 2753547 PRE_first_tail_x15_r0_body.kd100.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn100 : Nat.ble 20177 PRE_first_tail_x15_r0_body.kd100.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn100 : Nat.ble 17277 PRE_first_tail_x15_r0_body.kd100.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb100 : Nat.ble 20177 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.heap).all (Nat.ble (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.hnd).all (Nat.ble (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.node).all (Nat.ble (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix100 : Conv.FixOld (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa100 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja100) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn100) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD100) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn100) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn100) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb100) PRE_first_tail_x15_r0_body.fheap100 PRE_first_tail_x15_r0_body.fhnd100 PRE_first_tail_x15_r0_body.fnode100
kernel_rfl PRE_first_tail_x15_r0_body.fcxn100 : (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn100 : (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0100 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_100.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_100.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS100.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_100.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS100.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_100.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS100.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_100.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS100.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_100.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd100 : (PRE_first_tail_x15_r0_body.clo100 ++ PRE_first_tail_x15_r0_body.cln100 ++ PRE_first_tail_x15_r0_body.cli100 ++ PRE_first_tail_x15_r0_body.cwS100 ++ PRE_first_tail_x15_r0_body.cnS100 ++ PRE_first_tail_x15_r0_body.ciS100).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW100 : PRE_first_tail_x15_r0_body.cwS100.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo100.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI100 : PRE_first_tail_x15_r0_body.ciS100.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli100.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN100 : PRE_first_tail_x15_r0_body.cnS100.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF100 : PRE_first_tail_x15_r0_body.cln100.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh100 : PRE_first_tail_x15_r0_body.clo100.all (handleOK PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.P100.lo PRE_first_tail_x15_r0_body.cx0_100.mlx PRE_first_tail_x15_r0_body.cx1_100.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo100 : PRE_first_tail_x15_r0_body.clo100.map (fun h => PRE_first_tail_x15_r0_body.cx1_100.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa100.handle h)) = PRE_first_tail_x15_r0_body.clo100.map (fun h => (PRE_first_tail_x15_r0_body.cx0_100.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa100.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok100 : PRE_first_tail_x15_r0_body.clo100.all (objOK PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.P100.NL PRE_first_tail_x15_r0_body.cx0_100.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd100 : PRE_first_tail_x15_r0_body.cln100.all (nodeOKF PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.P100 PRE_first_tail_x15_r0_body.cx0_100.mlx PRE_first_tail_x15_r0_body.cx1_100.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp100 : ((PRE_first_tail_x15_r0_body.cln100.filter (fullB PRE_first_tail_x15_r0_body.P100))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_100.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa100.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln100.filter (fullB PRE_first_tail_x15_r0_body.P100))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_100.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa100.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI100 : incrB PRE_first_tail_x15_r0_body.kd100.nodeF (List.range' 17277 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.node).all (fun k => Nat.ble 17277 k && Nat.blt k 17277) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL100 : (PRE_first_tail_x15_r0_body.cln100.filter (Nat.ble PRE_first_tail_x15_r0_body.P100.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd100.nodeF i) && (Nat.blt i 17277 || Nat.ble PRE_first_tail_x15_r0_body.kd100.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord100 : (PRE_first_tail_x15_r0_body.cln100.filter (Nat.ble PRE_first_tail_x15_r0_body.P100.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd100.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd100.nodeF j) (PRE_first_tail_x15_r0_body.kd100.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow100 PRE_first_tail_x15_r0_body.cnn1100 PRE_first_tail_x15_r0_body.fnordI100 PRE_first_tail_x15_r0_body.fnordK100 PRE_first_tail_x15_r0_body.fnordL100
kernel_rfl PRE_first_tail_x15_r0_body.fi100 : PRE_first_tail_x15_r0_body.cli100.all (pnB PRE_first_tail_x15_r0_body.cx0_100.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii100 : PRE_first_tail_x15_r0_body.cli100.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_100.mlx.items.get (PRE_first_tail_x15_r0_body.kappa100.node k) = (PRE_first_tail_x15_r0_body.cx0_100.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa100.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot100 (clean : Conv.NClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P100.NL) (cl : SSt (· < 4355) PRE_first_tail_x15_r0_body.cx0_100.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P100 4355 PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.kd100 PRE_first_tail_x15_r0_body.khinv100 PRE_first_tail_x15_r0_body.kninv100 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx PRE_first_tail_x15_r0_body.cx0_100.mlx PRE_first_tail_x15_r0_body.cx1_100.mlx (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo100 PRE_first_tail_x15_r0_body.cln100 PRE_first_tail_x15_r0_body.cli100 PRE_first_tail_x15_r0_body.cwS100 PRE_first_tail_x15_r0_body.cnS100 PRE_first_tail_x15_r0_body.ciS100 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0100, PRE_first_tail_x15_r0_body.cnh1100, PRE_first_tail_x15_r0_body.cnn0100, PRE_first_tail_x15_r0_body.cnn1100, PRE_first_tail_x15_r0_body.cplo100, PRE_first_tail_x15_r0_body.ccnt100, PRE_first_tail_x15_r0_body.cnband100, PRE_first_tail_x15_r0_body.chbelow100, PRE_first_tail_x15_r0_body.chren100, PRE_first_tail_x15_r0_body.cband100, PRE_first_tail_x15_r0_body.cnh1pos100, PRE_first_tail_x15_r0_body.cnren100, PRE_first_tail_x15_r0_body.cnlow100, PRE_first_tail_x15_r0_body.cabs0a100, PRE_first_tail_x15_r0_body.cabs0b100, PRE_first_tail_x15_r0_body.ctok1100, PRE_first_tail_x15_r0_body.cpend100, PRE_first_tail_x15_r0_body.cerrh100, PRE_first_tail_x15_r0_body.cfiles100, PRE_first_tail_x15_r0_body.carch100, PRE_first_tail_x15_r0_body.csizes100, PRE_first_tail_x15_r0_body.cwired100, PRE_first_tail_x15_r0_body.cfix100, clean, PRE_first_tail_x15_r0_body.fcxn100, PRE_first_tail_x15_r0_body.fcnn100, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0100, PRE_first_tail_x15_r0_body.fnk100, PRE_first_tail_x15_r0_body.ckA100, PRE_first_tail_x15_r0_body.cobjsK100, PRE_first_tail_x15_r0_body.cnodesK100, PRE_first_tail_x15_r0_body.citemsK100, PRE_first_tail_x15_r0_body.f1A100, PRE_first_tail_x15_r0_body.f1O100, PRE_first_tail_x15_r0_body.f1N100, PRE_first_tail_x15_r0_body.f1I100, PRE_first_tail_x15_r0_body.fbd100, PRE_first_tail_x15_r0_body.fincW100, PRE_first_tail_x15_r0_body.fincI100, PRE_first_tail_x15_r0_body.fincN100, PRE_first_tail_x15_r0_body.flnF100, PRE_first_tail_x15_r0_body.fh100, PRE_first_tail_x15_r0_body.fo100, PRE_first_tail_x15_r0_body.fok100, PRE_first_tail_x15_r0_body.fnd100, PRE_first_tail_x15_r0_body.fp100, PRE_first_tail_x15_r0_body.fnord100, PRE_first_tail_x15_r0_body.fi100, PRE_first_tail_x15_r0_body.fii100⟩
theorem PRE_first_tail_x15_r0_body.cnshift100 (clean : Conv.NClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P100.NL) (cl : SSt (· < 4355) PRE_first_tail_x15_r0_body.cx0_100.mlx) : NShift PRE_first_tail_x15_r0_body.P100 4355 PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.cx0_100 PRE_first_tail_x15_r0_body.cx1_100 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot100 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost100 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0100 PRE_first_tail_x15_r0_body.ckn1100 PRE_first_tail_x15_r0_body.ckheap100 PRE_first_tail_x15_r0_body.ckpl100)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_100 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s973.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_100 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s973.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_100 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s973.ffi) = some PRE_first_tail_x15_r0_body.fxC_100
kernel_rfl PRE_first_tail_x15_r0_body.okrC_100 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s973.ffi) = some PRE_first_tail_x15_r0_body.krC_100
noncomputable def PRE_first_tail_x15_r0_body.fx0_100 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s975.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_100 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s975.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_100 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s975.ffi) = some PRE_first_tail_x15_r0_body.fx0_100
kernel_rfl PRE_first_tail_x15_r0_body.okr0_100 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s975.ffi) = some PRE_first_tail_x15_r0_body.kr0_100
noncomputable def PRE_first_tail_x15_r0_body.fx1_100 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s974.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_100 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s974.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_100 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s974.ffi) = some PRE_first_tail_x15_r0_body.fx1_100
kernel_rfl PRE_first_tail_x15_r0_body.okr1_100 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s974.ffi) = some PRE_first_tail_x15_r0_body.kr1_100
kernel_rfl PRE_first_tail_x15_r0_body.ff0100 : PRE_first_tail_x15_r0_body.fx0_100 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_100 (PRE_first_tail_x15_r0_body.clo100.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_100.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1100 : PRE_first_tail_x15_r0_body.fx1_100 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_100 (PRE_first_tail_x15_r0_body.cwS100.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_100.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck100 : freedLB PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.cx0_100.mlx PRE_first_tail_x15_r0_body.fx0_100 PRE_first_tail_x15_r0_body.fx1_100 PRE_first_tail_x15_r0_body.clo100 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0100 : PRE_first_tail_x15_r0_body.kr0_100.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_100.flags (PRE_first_tail_x15_r0_body.clo100.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_100.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0100 : PRE_first_tail_x15_r0_body.kr0_100.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_100.targs (PRE_first_tail_x15_r0_body.clo100.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_100.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1100 : PRE_first_tail_x15_r0_body.kr1_100.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_100.flags (PRE_first_tail_x15_r0_body.cwS100.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_100.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1100 : PRE_first_tail_x15_r0_body.kr1_100.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_100.targs (PRE_first_tail_x15_r0_body.cwS100.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_100.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck100 : krecLB PRE_first_tail_x15_r0_body.kappa100 4355 PRE_first_tail_x15_r0_body.cx0_100.mlx PRE_first_tail_x15_r0_body.kr0_100 PRE_first_tail_x15_r0_body.kr1_100 PRE_first_tail_x15_r0_body.clo100 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn100 : Nat.ble 4355 4355 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge100 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s974.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s975.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR100 : pendRegB PRE_first_tail_x15_r0_body.kappa100 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe100 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s974.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift100 (clean : Conv.NClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P100.NL) (cl : SSt (· < 4355) PRE_first_tail_x15_r0_body.cx0_100.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_100.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_100.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_100.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_100.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P100 4355 PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.s975.ffi PRE_first_tail_x15_r0_body.s974.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift100 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue100, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp100 t ht),
    PRE_first_tail_x15_r0_body.cbridge100,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s975.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s974.ffi) (PRE_first_tail_x15_r0_body.cfoot100 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_100 PRE_first_tail_x15_r0_body.ofx1_100 hobjC PRE_first_tail_x15_r0_body.ff0100 PRE_first_tail_x15_r0_body.ff1100 PRE_first_tail_x15_r0_body.ffck100,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s975.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s974.ffi) (PRE_first_tail_x15_r0_body.cfoot100 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_100 PRE_first_tail_x15_r0_body.okr1_100 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn100) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0100 PRE_first_tail_x15_r0_body.fkt0100 PRE_first_tail_x15_r0_body.fkf1100 PRE_first_tail_x15_r0_body.fkt1100 PRE_first_tail_x15_r0_body.fkck100,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0100 PRE_first_tail_x15_r0_body.cnh1100 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe100) PRE_first_tail_x15_r0_body.cpendR100⟩

end Host.Load.Run.Tpl
end

section -- st100/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st100 0
host_stream_state PRE_first_tail_x15_r0_body.st100 1
host_stream_state PRE_first_tail_x15_r0_body.st100 2
end Host.Load.Run.Tpl
end

section -- Site100
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 100 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g100__g101` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s973`, the merged state `PRE_first_tail_x15_r0_body.s974`,
the site template `PRE_first_tail_x15_r0_body.st100` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s975`: the merge.
The footprint's facts are in `SiteF100`, the compaction's in `SiteC100`, `SiteK100`, `SiteNa100`, `SiteNb100`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso100 : PRE_first_tail_x15_r0_body.st100.s0 = { PRE_first_tail_x15_r0_body.s973 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs100 : List Frame := PRE_first_tail_x15_r0_body.s973.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_100 : PRE_first_tail_x15_r0_body.S973.tab.length = 4355
kernel_rfl PRE_first_tail_x15_r0_body.tab0_100 : PRE_first_tail_x15_r0_body.st100.S0.tab = PRE_first_tail_x15_r0_body.S973.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws100 : List Nat := [2707, 2708]
kernel_rfl PRE_first_tail_x15_r0_body.fresh100 : (PRE_first_tail_x15_r0_body.S973.tab.all fun e => PRE_first_tail_x15_r0_body.ws100.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S973.oracle.all fun q => PRE_first_tail_x15_r0_body.ws100.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab100 : PRE_first_tail_x15_r0_body.S974.tab = PRE_first_tail_x15_r0_body.S973.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws100
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen100 : PRE_first_tail_x15_r0_body.st100.S2.tab.length - PRE_first_tail_x15_r0_body.st100.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged100`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap100 : PRE_first_tail_x15_r0_body.s974.heap = PRE_first_tail_x15_r0_body.st100.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext100 : PRE_first_tail_x15_r0_body.s974.next = PRE_first_tail_x15_r0_body.st100.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl100 : PRE_first_tail_x15_r0_body.s974.ctl = PRE_first_tail_x15_r0_body.st100.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack100 : PRE_first_tail_x15_r0_body.s974.stack = PRE_first_tail_x15_r0_body.st100.s2.stack ++ PRE_first_tail_x15_r0_body.s973.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs100 : PRE_first_tail_x15_r0_body.s974.jobs = PRE_first_tail_x15_r0_body.st100.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi100 : PRE_first_tail_x15_r0_body.s974.ffi = PRE_first_tail_x15_r0_body.st100.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace100 : PRE_first_tail_x15_r0_body.s974.trace = PRE_first_tail_x15_r0_body.st100.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores100 : PRE_first_tail_x15_r0_body.s974.stores = PRE_first_tail_x15_r0_body.st100.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD100
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 100 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived100 : PRE_first_tail_x15_r0_body.nr100.map (fun r => nth? PRE_first_tail_x15_r0_body.st100.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo100 : PRE_first_tail_x15_r0_body.nr100.all (Nat.ble 4355) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj100 : PRE_first_tail_x15_r0_body.cws100.all (fun c => !PRE_first_tail_x15_r0_body.ws100.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ100 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws100 PRE_first_tail_x15_r0_body.crs100 PRE_first_tail_x15_r0_body.ws100

end Host.Load.Run.Tpl
end

section -- st100/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st100`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st100.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st100.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st100.s2.heap PRE_first_tail_x15_r0_body.st100.wrR ++ freshOf PRE_first_tail_x15_r0_body.st100.s2.heap PRE_first_tail_x15_r0_body.st100.s0.next PRE_first_tail_x15_r0_body.st100.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st100.wr : List Nat := PRE_first_tail_x15_r0_body.st100.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st100.heapFoot : PRE_first_tail_x15_r0_body.st100.s2.heap = setAll PRE_first_tail_x15_r0_body.st100.s0.heap PRE_first_tail_x15_r0_body.st100.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st100.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st100.s0.next PRE_first_tail_x15_r0_body.st100.s2.next = true
theorem PRE_first_tail_x15_r0_body.st100.grows : PRE_first_tail_x15_r0_body.st100.s0.next ≤ PRE_first_tail_x15_r0_body.st100.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st100.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st100.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st100.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st100.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st100.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st100.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st100.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st100.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st100.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st100.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st100.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st100.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF100
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 100 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB100 : nodupT PRE_first_tail_x15_r0_body.st100.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup100 : PRE_first_tail_x15_r0_body.st100.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB100).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB100 : PRE_first_tail_x15_r0_body.st100.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound100 : ∀ b ∈ PRE_first_tail_x15_r0_body.st100.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB100 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr100 := PRE_first_tail_x15_r0_body.st100.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq100 : PRE_first_tail_x15_r0_body.st100.s2.trace = PRE_first_tail_x15_r0_body.trFr100 ++ PRE_first_tail_x15_r0_body.st100.s0.trace
theorem PRE_first_tail_x15_r0_body.trace100 : ∃ fr, PRE_first_tail_x15_r0_body.st100.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st100.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq100⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide100 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB100 : (PRE_first_tail_x15_r0_body.wide100.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st100.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix100 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide100, WFix Map.id (Present PRE_first_tail_x15_r0_body.st100.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB100 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL100
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 100 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s974`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO100 : PRE_first_tail_x15_r0_body.st100.S0.oracle = PRE_first_tail_x15_r0_body.st100.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B100 : PRE_first_tail_x15_r0_body.st100.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st100.s0.next || (PRE_first_tail_x15_r0_body.st100.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot100 : Conv.StageFoot PRE_first_tail_x15_r0_body.st100.wr PRE_first_tail_x15_r0_body.st100.s0 PRE_first_tail_x15_r0_body.st100.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st100.heapFoot PRE_first_tail_x15_r0_body.wrNodup100 PRE_first_tail_x15_r0_body.wrBound100 PRE_first_tail_x15_r0_body.wr0B100 PRE_first_tail_x15_r0_body.st100.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged100 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st100.F.S → PRE_first_tail_x15_r0_body.st100.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st100.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st100.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs100 PRE_first_tail_x15_r0_body.st100.wr PRE_first_tail_x15_r0_body.s973 PRE_first_tail_x15_r0_body.st100.s2 PRE_first_tail_x15_r0_body.st100.s0
      PRE_first_tail_x15_r0_body.st100.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st100.F FR W stk M ν K PRE_first_tail_x15_r0_body.s974 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso100 PRE_first_tail_x15_r0_body.stFoot100 PRE_first_tail_x15_r0_body.wrNodup100 PRE_first_tail_x15_r0_body.wrBound100 PRE_first_tail_x15_r0_body.trace100 PRE_first_tail_x15_r0_body.mheap100
    PRE_first_tail_x15_r0_body.mnext100 PRE_first_tail_x15_r0_body.mctl100 PRE_first_tail_x15_r0_body.mstack100 PRE_first_tail_x15_r0_body.mjobs100 PRE_first_tail_x15_r0_body.mffi100 PRE_first_tail_x15_r0_body.mtrace100 PRE_first_tail_x15_r0_body.mstores100 h

def PRE_first_tail_x15_r0_body.arrEl100_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE100_2665 : arrOf PRE_first_tail_x15_r0_body.s974 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl100_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA100_2665 : isArrB PRE_first_tail_x15_r0_body.s974 2665 = true
theorem PRE_first_tail_x15_r0_body.arr100_2665 : ∃ o, PRE_first_tail_x15_r0_body.s974.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl100_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE100_2665 PRE_first_tail_x15_r0_body.arrA100_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN100_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl100_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR100_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl100_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN100_2665

def PRE_first_tail_x15_r0_body.arrEl100_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE100_2673467 : arrOf PRE_first_tail_x15_r0_body.s974 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl100_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA100_2673467 : isArrB PRE_first_tail_x15_r0_body.s974 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr100_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s974.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl100_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE100_2673467 PRE_first_tail_x15_r0_body.arrA100_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN100_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl100_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR100_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl100_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN100_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k100 : isArrB PRE_first_tail_x15_r0_body.s974 4910 = false
theorem PRE_first_tail_x15_r0_body.keep100 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s974 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k100 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr100_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl100_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ100
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 100 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s973`, the merged
state `PRE_first_tail_x15_r0_body.s974`, the canonical state `PRE_first_tail_x15_r0_body.s975`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl100 : PRE_first_tail_x15_r0_body.pl100.all (Nat.ble PRE_first_tail_x15_r0_body.s973.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd100 : nodupT PRE_first_tail_x15_r0_body.pl100 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1100 : Nat.ble PRE_first_tail_x15_r0_body.s973.next 2753549 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst100 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s973.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn100 : PRE_first_tail_x15_r0_body.s975.next = PRE_first_tail_x15_r0_body.s973.next + PRE_first_tail_x15_r0_body.pl100.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn100 : PRE_first_tail_x15_r0_body.s974.next = 2753549
kernel_rfl PRE_first_tail_x15_r0_body.zgrow100 : Nat.ble PRE_first_tail_x15_r0_body.s975.next PRE_first_tail_x15_r0_body.s974.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh100 : PRE_first_tail_x15_r0_body.S973.tab.all (fun e => PRE_first_tail_x15_r0_body.cws100.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd100 : nodupT PRE_first_tail_x15_r0_body.cws100 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi100 : PRE_first_tail_x15_r0_body.nr100.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S974.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt100 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s973.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg100_2665 : PRE_first_tail_x15_r0_body.s975.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s975 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk100_2665 : (objOf PRE_first_tail_x15_r0_body.s975 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm100_2665 : PRE_first_tail_x15_r0_body.s974.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa100.obj (objOf PRE_first_tail_x15_r0_body.s975 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s974 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg100_2673467 : PRE_first_tail_x15_r0_body.s975.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s975 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk100_2673467 : (objOf PRE_first_tail_x15_r0_body.s975 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm100_2673467 : PRE_first_tail_x15_r0_body.s974.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa100.obj (objOf PRE_first_tail_x15_r0_body.s975 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s974 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw100_4910 : (PRE_first_tail_x15_r0_body.s975.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw100_2673472 : (PRE_first_tail_x15_r0_body.s975.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw100_2673473 : (PRE_first_tail_x15_r0_body.s975.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd100 : PRE_first_tail_x15_r0_body.cl100.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr100 : PRE_first_tail_x15_r0_body.st100.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s973.next || PRE_first_tail_x15_r0_body.cl100.contains b) = true
def PRE_first_tail_x15_r0_body.zl100 : List Nat := PRE_first_tail_x15_r0_body.cl100.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE100 : PRE_first_tail_x15_r0_body.zl100.map (fun a => PRE_first_tail_x15_r0_body.s974.heap.get (PRE_first_tail_x15_r0_body.kappa100.a a)) = PRE_first_tail_x15_r0_body.zl100.map (fun a => (PRE_first_tail_x15_r0_body.s975.heap.get a).map PRE_first_tail_x15_r0_body.kappa100.hobj)
theorem PRE_first_tail_x15_r0_body.zimg100 : HeapImg PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.s975 PRE_first_tail_x15_r0_body.s974 PRE_first_tail_x15_r0_body.zl100 := PRE_first_tail_x15_r0_body.zimgE100
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl100 : PRE_first_tail_x15_r0_body.s974.ctl = PRE_first_tail_x15_r0_body.kappa100.ctl PRE_first_tail_x15_r0_body.s975.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack100 : PRE_first_tail_x15_r0_body.s974.stack = PRE_first_tail_x15_r0_body.s975.stack.map PRE_first_tail_x15_r0_body.kappa100.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs100 : PRE_first_tail_x15_r0_body.s974.jobs = PRE_first_tail_x15_r0_body.s975.jobs.map PRE_first_tail_x15_r0_body.kappa100.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores100 : PRE_first_tail_x15_r0_body.s974.stores = PRE_first_tail_x15_r0_body.kappa100.stores PRE_first_tail_x15_r0_body.s975.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots100 : checkRootsSupp PRE_first_tail_x15_r0_body.s975 4355 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC100 : PRE_first_tail_x15_r0_body.S973.tab.length + PRE_first_tail_x15_r0_body.cws100.length = 4355
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap100 : PRE_first_tail_x15_r0_body.kappa100 = Conv.Map.compact PRE_first_tail_x15_r0_body.s973.next 2753549 PRE_first_tail_x15_r0_body.S973.tab.length PRE_first_tail_x15_r0_body.pl100 (PRE_first_tail_x15_r0_body.nr100.map NumV.ref) PRE_first_tail_x15_r0_body.kd100.big
  PRE_first_tail_x15_r0_body.kd100.region PRE_first_tail_x15_r0_body.kd100.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin100 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s975.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc100 : Conv.jcleanListB (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s975 PRE_first_tail_x15_r0_body.cl100 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB100 : noBigRootsP (fun i => !Conv.oldBigB (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s975.trace PRE_first_tail_x15_r0_body.s975 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm100 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17277 = true
theorem PRE_first_tail_x15_r0_body.cjcl100 (h : Conv.JClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s973) : Conv.JClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s975 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle100)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap100 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd100 a ha)) PRE_first_tail_x15_r0_body.zjc100

end Host.Load.Run.Tpl
end

section -- st100/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st100.bodyLast from PRE_first_tail_x15_r0_body.st100.s1 to PRE_first_tail_x15_r0_body.st100.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st100.F PRE_first_tail_x15_r0_body.st100.s1).run PRE_first_tail_x15_r0_body.st100.S1 = some (PRE_first_tail_x15_r0_body.st100.s2, PRE_first_tail_x15_r0_body.st100.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st100.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st100.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st100.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st100.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st100/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st100.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st100.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st100.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st100.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st100.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st100.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st100.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st100.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st100.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st100.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st100.s0 PRE_first_tail_x15_r0_body.st100.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st100.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st100.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st100.s1 PRE_first_tail_x15_r0_body.st100.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st100/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st100.bodyK0F from PRE_first_tail_x15_r0_body.st100.s0 to PRE_first_tail_x15_r0_body.st100.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st100.F (PRE_first_tail_x15_r0_body.st100.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st100.ks 0).getD 0) PRE_first_tail_x15_r0_body.st100.s0 PRE_first_tail_x15_r0_body.st100.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st100.s1, PRE_first_tail_x15_r0_body.st100.S1)
theorem PRE_first_tail_x15_r0_body.st100.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st100.F (PRE_first_tail_x15_r0_body.st100.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st100.ks 0).getD 0) PRE_first_tail_x15_r0_body.st100.s0 PRE_first_tail_x15_r0_body.st100.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st100.s1, PRE_first_tail_x15_r0_body.st100.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st100.bodyOkLN_ok PRE_first_tail_x15_r0_body.st100.bodyK0F
end Host.Load.Run.Tpl
end

section -- st100/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st100.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st100.F (PRE_first_tail_x15_r0_body.st100.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st100.s0 PRE_first_tail_x15_r0_body.st100.S0 = some (PRE_first_tail_x15_r0_body.st100.s1, PRE_first_tail_x15_r0_body.st100.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st100.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st100.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st100.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st100.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st100.F (PRE_first_tail_x15_r0_body.st100.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st100.s0
  S0 := PRE_first_tail_x15_r0_body.st100.S0
  s1 := PRE_first_tail_x15_r0_body.st100.s1
  S1 := PRE_first_tail_x15_r0_body.st100.S1
  s2 := PRE_first_tail_x15_r0_body.st100.s2
  S2 := PRE_first_tail_x15_r0_body.st100.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st100.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st100.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st100.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st100.bodyHalt
  last := PRE_first_tail_x15_r0_body.st100.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st100.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC101
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 101 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s979` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa101` into the merged state
`PRE_first_tail_x15_r0_body.s978`. -/

def PRE_first_tail_x15_r0_body.pl101 : List Nat := [2753854]
def PRE_first_tail_x15_r0_body.nr101 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd101 : RData :=
  ⟨2753836, 2753855, Stage.setAll PTrie.nil [(2753835, 2753854)], Stage.setAll PTrie.nil [],
   20184, 20184, 17281, 17281, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa101 : Map :=
  Conv.Map.compact 2753835 2753855 4372 PRE_first_tail_x15_r0_body.pl101 (PRE_first_tail_x15_r0_body.nr101.map NumV.ref) PRE_first_tail_x15_r0_body.kd101.big
    PRE_first_tail_x15_r0_body.kd101.region PRE_first_tail_x15_r0_body.kd101.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws101 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs101 : List SymE := PRE_first_tail_x15_r0_body.nr101.map fun r => (nth? PRE_first_tail_x15_r0_body.S978.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta101 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws101 PRE_first_tail_x15_r0_body.crs101
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB101 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab101 : PRE_first_tail_x15_r0_body.S979.tab = PRE_first_tail_x15_r0_body.S977.tab ++ PRE_first_tail_x15_r0_body.cws101.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace101 : PRE_first_tail_x15_r0_body.s979.trace = PRE_first_tail_x15_r0_body.s977.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext101 : PRE_first_tail_x15_r0_body.s979.next = 2753836
kernel_rfl PRE_first_tail_x15_r0_body.ccounters101 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.nnext) = (20184, 17281)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue101 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s978.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa101.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp101 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.tokens.all (bSN 4372) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean101 : Conv.cleanListB 20184 131072 (fun r => Nat.ble 80736 r) PRE_first_tail_x15_r0_body.s979
    (PRE_first_tail_x15_r0_body.wrB101 ++ (List.range 1).map (2753835 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs101 : bigsOutB 20184 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK101
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl101`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl101 : List Nat := [2665, 2673467, 2753835]
def PRE_first_tail_x15_r0_body.clo101 : List Nat := []
def PRE_first_tail_x15_r0_body.cln101 : List Nat := []
def PRE_first_tail_x15_r0_body.cli101 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap101 : PRE_first_tail_x15_r0_body.s979.heap = Stage.setAll PRE_first_tail_x15_r0_body.s977.heap (PRE_first_tail_x15_r0_body.cl101.filterMap fun a => (PRE_first_tail_x15_r0_body.s979.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe101 : Nat.ble PRE_first_tail_x15_r0_body.s977.next PRE_first_tail_x15_r0_body.s979.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP101 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s977 PRE_first_tail_x15_r0_body.s979 PRE_first_tail_x15_r0_body.cl101 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp101 : Conv.suppListB PRE_first_tail_x15_r0_body.s979 4372 PRE_first_tail_x15_r0_body.cl101 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound101 : Conv.boundListB PRE_first_tail_x15_r0_body.s979 PRE_first_tail_x15_r0_body.cl101 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK101 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln101.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK101 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo101.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK101 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli101.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst101 : Conv.sstListB 4372 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx PRE_first_tail_x15_r0_body.cln101 PRE_first_tail_x15_r0_body.clo101 PRE_first_tail_x15_r0_body.cli101 = true

end Host.Load.Run.Tpl
end

section -- SiteCl101
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA101 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo101.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd101 : (PRE_first_tail_x15_r0_body.clo101 ++ PRE_first_tail_x15_r0_body.cln101 ++ PRE_first_tail_x15_r0_body.cli101).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle101 : Conv.Cnt.leB (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt) (⟨20184, 17281, 2753836, 4372⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck101 : Conv.ncleanListB (⟨20184, 17281, 2753836, 4372⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx PRE_first_tail_x15_r0_body.clo101 PRE_first_tail_x15_r0_body.cln101 PRE_first_tail_x15_r0_body.cli101 = true
theorem PRE_first_tail_x15_r0_body.cncl101 (h : Conv.NClean (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx) : Conv.NClean (⟨20184, 17281, 2753836, 4372⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle101 PRE_first_tail_x15_r0_body.ckA101 PRE_first_tail_x15_r0_body.cobjsK101 PRE_first_tail_x15_r0_body.cnodesK101 PRE_first_tail_x15_r0_body.citemsK101 PRE_first_tail_x15_r0_body.cbd101 PRE_first_tail_x15_r0_body.cck101

end Host.Load.Run.Tpl
end

section -- SiteS101
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 101 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc101 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P101 : LoadP := PRE_first_tail_x15_r0_body.Pc101.raise 17281
kernel_rfl PRE_first_tail_x15_r0_body.craise101 : Nat.ble PRE_first_tail_x15_r0_body.Pc101.N0 17281 = true
theorem PRE_first_tail_x15_r0_body.raised101 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc101 PRE_first_tail_x15_r0_body.P101 :=
  .inr ⟨17281, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise101, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_101 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_101 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s978.ffi)
def PRE_first_tail_x15_r0_body.khinv101 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv101 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS101 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS101 : List Nat := List.range' 17281 0
def PRE_first_tail_x15_r0_body.ciS101 : List Nat := [] ++ List.range' 17281 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0101 : PRE_first_tail_x15_r0_body.kd101.nh0 = PRE_first_tail_x15_r0_body.cx0_101.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1101 : PRE_first_tail_x15_r0_body.kd101.nh1 = PRE_first_tail_x15_r0_body.cx1_101.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0101 : PRE_first_tail_x15_r0_body.kd101.nn0 = PRE_first_tail_x15_r0_body.cx0_101.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1101 : PRE_first_tail_x15_r0_body.kd101.nn1 = PRE_first_tail_x15_r0_body.cx1_101.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo101 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P101.lo && Nat.ble PRE_first_tail_x15_r0_body.P101.lo PRE_first_tail_x15_r0_body.cx0_101.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P101.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P101.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt101 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_101.mlx.next PRE_first_tail_x15_r0_body.cx1_101.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_101.mlx.nnext PRE_first_tail_x15_r0_body.cx1_101.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband101 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P101.NL && Nat.ble PRE_first_tail_x15_r0_body.P101.NL PRE_first_tail_x15_r0_body.P101.N0 && Nat.ble PRE_first_tail_x15_r0_body.P101.N0 PRE_first_tail_x15_r0_body.cx0_101.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow101 : PRE_first_tail_x15_r0_body.kd101.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren101 : checkRenG PRE_first_tail_x15_r0_body.kd101.hnd PRE_first_tail_x15_r0_body.khinv101 (phB PRE_first_tail_x15_r0_body.cx0_101.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband101 : PRE_first_tail_x15_r0_body.kd101.checkBand PRE_first_tail_x15_r0_body.P101.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos101 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd101.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren101 : checkRenG PRE_first_tail_x15_r0_body.kd101.node PRE_first_tail_x15_r0_body.kninv101 (pnB PRE_first_tail_x15_r0_body.cx0_101.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow101 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd101.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P101.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd101.nodeF j) PRE_first_tail_x15_r0_body.cx1_101.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a101 : PRE_first_tail_x15_r0_body.cx0_101.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b101 : PRE_first_tail_x15_r0_body.cx0_101.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1101 : PRE_first_tail_x15_r0_body.cx1_101.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend101 : PRE_first_tail_x15_r0_body.cx1_101.mlx.pending = PRE_first_tail_x15_r0_body.cx0_101.mlx.pending.map PRE_first_tail_x15_r0_body.kappa101.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh101 : PRE_first_tail_x15_r0_body.cx1_101.mlx.errh = PRE_first_tail_x15_r0_body.cx0_101.mlx.errh.map PRE_first_tail_x15_r0_body.kappa101.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles101 : PRE_first_tail_x15_r0_body.cx1_101.mlx.files = PRE_first_tail_x15_r0_body.cx0_101.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch101 : PRE_first_tail_x15_r0_body.cx1_101.mlx.arch = PRE_first_tail_x15_r0_body.cx0_101.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes101 : PRE_first_tail_x15_r0_body.cx1_101.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_101.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired101 : PRE_first_tail_x15_r0_body.cx1_101.mlx.wired = PRE_first_tail_x15_r0_body.cx0_101.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost101 : PRE_first_tail_x15_r0_body.cx1_101.host = PRE_first_tail_x15_r0_body.cx0_101.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd101`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0101 : PRE_first_tail_x15_r0_body.kd101.n0 = 2753836
kernel_rfl PRE_first_tail_x15_r0_body.ckn1101 : PRE_first_tail_x15_r0_body.kd101.n1 = 2753855
kernel_rfl PRE_first_tail_x15_r0_body.ckheap101 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd101.heap).all (fun x => Nat.ble 2753835 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl101 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd101.heap.get (2753835 + j) = nth? PRE_first_tail_x15_r0_body.pl101 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja101 : Nat.ble 2753835 2753835 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn101 : Nat.ble 4372 4372 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD101 : Nat.ble 2753835 PRE_first_tail_x15_r0_body.kd101.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn101 : Nat.ble 20184 PRE_first_tail_x15_r0_body.kd101.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn101 : Nat.ble 17281 PRE_first_tail_x15_r0_body.kd101.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb101 : Nat.ble 20184 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap101 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd101.heap).all (Nat.ble (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd101 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd101.hnd).all (Nat.ble (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode101 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd101.node).all (Nat.ble (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix101 : Conv.FixOld (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa101 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja101) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn101) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD101) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn101) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn101) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb101) PRE_first_tail_x15_r0_body.fheap101 PRE_first_tail_x15_r0_body.fhnd101 PRE_first_tail_x15_r0_body.fnode101
kernel_rfl PRE_first_tail_x15_r0_body.fcxn101 : (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn101 : (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0101 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_101.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_101.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk101 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd101.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A101 : PRE_first_tail_x15_r0_body.cx1_101.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS101.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_101.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O101 : PRE_first_tail_x15_r0_body.cx1_101.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS101.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_101.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N101 : PRE_first_tail_x15_r0_body.cx1_101.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS101.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_101.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I101 : PRE_first_tail_x15_r0_body.cx1_101.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS101.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_101.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd101 : (PRE_first_tail_x15_r0_body.clo101 ++ PRE_first_tail_x15_r0_body.cln101 ++ PRE_first_tail_x15_r0_body.cli101 ++ PRE_first_tail_x15_r0_body.cwS101 ++ PRE_first_tail_x15_r0_body.cnS101 ++ PRE_first_tail_x15_r0_body.ciS101).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW101 : PRE_first_tail_x15_r0_body.cwS101.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo101.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI101 : PRE_first_tail_x15_r0_body.ciS101.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli101.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN101 : PRE_first_tail_x15_r0_body.cnS101.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF101 : PRE_first_tail_x15_r0_body.cln101.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh101 : PRE_first_tail_x15_r0_body.clo101.all (handleOK PRE_first_tail_x15_r0_body.kappa101 PRE_first_tail_x15_r0_body.P101.lo PRE_first_tail_x15_r0_body.cx0_101.mlx PRE_first_tail_x15_r0_body.cx1_101.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo101 : PRE_first_tail_x15_r0_body.clo101.map (fun h => PRE_first_tail_x15_r0_body.cx1_101.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa101.handle h)) = PRE_first_tail_x15_r0_body.clo101.map (fun h => (PRE_first_tail_x15_r0_body.cx0_101.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa101.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok101 : PRE_first_tail_x15_r0_body.clo101.all (objOK PRE_first_tail_x15_r0_body.kappa101 PRE_first_tail_x15_r0_body.P101.NL PRE_first_tail_x15_r0_body.cx0_101.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd101 : PRE_first_tail_x15_r0_body.cln101.all (nodeOKF PRE_first_tail_x15_r0_body.kappa101 PRE_first_tail_x15_r0_body.P101 PRE_first_tail_x15_r0_body.cx0_101.mlx PRE_first_tail_x15_r0_body.cx1_101.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp101 : ((PRE_first_tail_x15_r0_body.cln101.filter (fullB PRE_first_tail_x15_r0_body.P101))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_101.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa101.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln101.filter (fullB PRE_first_tail_x15_r0_body.P101))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_101.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa101.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI101 : incrB PRE_first_tail_x15_r0_body.kd101.nodeF (List.range' 17281 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK101 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd101.node).all (fun k => Nat.ble 17281 k && Nat.blt k 17281) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL101 : (PRE_first_tail_x15_r0_body.cln101.filter (Nat.ble PRE_first_tail_x15_r0_body.P101.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd101.nodeF i) && (Nat.blt i 17281 || Nat.ble PRE_first_tail_x15_r0_body.kd101.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord101 : (PRE_first_tail_x15_r0_body.cln101.filter (Nat.ble PRE_first_tail_x15_r0_body.P101.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd101.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd101.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd101.nodeF j) (PRE_first_tail_x15_r0_body.kd101.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow101 PRE_first_tail_x15_r0_body.cnn1101 PRE_first_tail_x15_r0_body.fnordI101 PRE_first_tail_x15_r0_body.fnordK101 PRE_first_tail_x15_r0_body.fnordL101
kernel_rfl PRE_first_tail_x15_r0_body.fi101 : PRE_first_tail_x15_r0_body.cli101.all (pnB PRE_first_tail_x15_r0_body.cx0_101.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii101 : PRE_first_tail_x15_r0_body.cli101.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_101.mlx.items.get (PRE_first_tail_x15_r0_body.kappa101.node k) = (PRE_first_tail_x15_r0_body.cx0_101.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa101.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot101 (clean : Conv.NClean (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P101.NL) (cl : SSt (· < 4372) PRE_first_tail_x15_r0_body.cx0_101.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P101 4372 PRE_first_tail_x15_r0_body.kappa101 PRE_first_tail_x15_r0_body.kd101 PRE_first_tail_x15_r0_body.khinv101 PRE_first_tail_x15_r0_body.kninv101 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx PRE_first_tail_x15_r0_body.cx0_101.mlx PRE_first_tail_x15_r0_body.cx1_101.mlx (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo101 PRE_first_tail_x15_r0_body.cln101 PRE_first_tail_x15_r0_body.cli101 PRE_first_tail_x15_r0_body.cwS101 PRE_first_tail_x15_r0_body.cnS101 PRE_first_tail_x15_r0_body.ciS101 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0101, PRE_first_tail_x15_r0_body.cnh1101, PRE_first_tail_x15_r0_body.cnn0101, PRE_first_tail_x15_r0_body.cnn1101, PRE_first_tail_x15_r0_body.cplo101, PRE_first_tail_x15_r0_body.ccnt101, PRE_first_tail_x15_r0_body.cnband101, PRE_first_tail_x15_r0_body.chbelow101, PRE_first_tail_x15_r0_body.chren101, PRE_first_tail_x15_r0_body.cband101, PRE_first_tail_x15_r0_body.cnh1pos101, PRE_first_tail_x15_r0_body.cnren101, PRE_first_tail_x15_r0_body.cnlow101, PRE_first_tail_x15_r0_body.cabs0a101, PRE_first_tail_x15_r0_body.cabs0b101, PRE_first_tail_x15_r0_body.ctok1101, PRE_first_tail_x15_r0_body.cpend101, PRE_first_tail_x15_r0_body.cerrh101, PRE_first_tail_x15_r0_body.cfiles101, PRE_first_tail_x15_r0_body.carch101, PRE_first_tail_x15_r0_body.csizes101, PRE_first_tail_x15_r0_body.cwired101, PRE_first_tail_x15_r0_body.cfix101, clean, PRE_first_tail_x15_r0_body.fcxn101, PRE_first_tail_x15_r0_body.fcnn101, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0101, PRE_first_tail_x15_r0_body.fnk101, PRE_first_tail_x15_r0_body.ckA101, PRE_first_tail_x15_r0_body.cobjsK101, PRE_first_tail_x15_r0_body.cnodesK101, PRE_first_tail_x15_r0_body.citemsK101, PRE_first_tail_x15_r0_body.f1A101, PRE_first_tail_x15_r0_body.f1O101, PRE_first_tail_x15_r0_body.f1N101, PRE_first_tail_x15_r0_body.f1I101, PRE_first_tail_x15_r0_body.fbd101, PRE_first_tail_x15_r0_body.fincW101, PRE_first_tail_x15_r0_body.fincI101, PRE_first_tail_x15_r0_body.fincN101, PRE_first_tail_x15_r0_body.flnF101, PRE_first_tail_x15_r0_body.fh101, PRE_first_tail_x15_r0_body.fo101, PRE_first_tail_x15_r0_body.fok101, PRE_first_tail_x15_r0_body.fnd101, PRE_first_tail_x15_r0_body.fp101, PRE_first_tail_x15_r0_body.fnord101, PRE_first_tail_x15_r0_body.fi101, PRE_first_tail_x15_r0_body.fii101⟩
theorem PRE_first_tail_x15_r0_body.cnshift101 (clean : Conv.NClean (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P101.NL) (cl : SSt (· < 4372) PRE_first_tail_x15_r0_body.cx0_101.mlx) : NShift PRE_first_tail_x15_r0_body.P101 4372 PRE_first_tail_x15_r0_body.kappa101 PRE_first_tail_x15_r0_body.cx0_101 PRE_first_tail_x15_r0_body.cx1_101 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot101 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost101 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0101 PRE_first_tail_x15_r0_body.ckn1101 PRE_first_tail_x15_r0_body.ckheap101 PRE_first_tail_x15_r0_body.ckpl101)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_101 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s977.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_101 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s977.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_101 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s977.ffi) = some PRE_first_tail_x15_r0_body.fxC_101
kernel_rfl PRE_first_tail_x15_r0_body.okrC_101 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s977.ffi) = some PRE_first_tail_x15_r0_body.krC_101
noncomputable def PRE_first_tail_x15_r0_body.fx0_101 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s979.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_101 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s979.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_101 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s979.ffi) = some PRE_first_tail_x15_r0_body.fx0_101
kernel_rfl PRE_first_tail_x15_r0_body.okr0_101 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s979.ffi) = some PRE_first_tail_x15_r0_body.kr0_101
noncomputable def PRE_first_tail_x15_r0_body.fx1_101 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s978.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_101 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s978.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_101 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s978.ffi) = some PRE_first_tail_x15_r0_body.fx1_101
kernel_rfl PRE_first_tail_x15_r0_body.okr1_101 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s978.ffi) = some PRE_first_tail_x15_r0_body.kr1_101
kernel_rfl PRE_first_tail_x15_r0_body.ff0101 : PRE_first_tail_x15_r0_body.fx0_101 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_101 (PRE_first_tail_x15_r0_body.clo101.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_101.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1101 : PRE_first_tail_x15_r0_body.fx1_101 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_101 (PRE_first_tail_x15_r0_body.cwS101.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_101.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck101 : freedLB PRE_first_tail_x15_r0_body.kappa101 PRE_first_tail_x15_r0_body.cx0_101.mlx PRE_first_tail_x15_r0_body.fx0_101 PRE_first_tail_x15_r0_body.fx1_101 PRE_first_tail_x15_r0_body.clo101 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0101 : PRE_first_tail_x15_r0_body.kr0_101.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_101.flags (PRE_first_tail_x15_r0_body.clo101.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_101.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0101 : PRE_first_tail_x15_r0_body.kr0_101.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_101.targs (PRE_first_tail_x15_r0_body.clo101.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_101.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1101 : PRE_first_tail_x15_r0_body.kr1_101.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_101.flags (PRE_first_tail_x15_r0_body.cwS101.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_101.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1101 : PRE_first_tail_x15_r0_body.kr1_101.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_101.targs (PRE_first_tail_x15_r0_body.cwS101.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_101.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck101 : krecLB PRE_first_tail_x15_r0_body.kappa101 4372 PRE_first_tail_x15_r0_body.cx0_101.mlx PRE_first_tail_x15_r0_body.kr0_101 PRE_first_tail_x15_r0_body.kr1_101 PRE_first_tail_x15_r0_body.clo101 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn101 : Nat.ble 4372 4372 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge101 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s978.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s979.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR101 : pendRegB PRE_first_tail_x15_r0_body.kappa101 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe101 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s978.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift101 (clean : Conv.NClean (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P101.NL) (cl : SSt (· < 4372) PRE_first_tail_x15_r0_body.cx0_101.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_101.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_101.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_101.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_101.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P101 4372 PRE_first_tail_x15_r0_body.kappa101 PRE_first_tail_x15_r0_body.s979.ffi PRE_first_tail_x15_r0_body.s978.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift101 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue101, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp101 t ht),
    PRE_first_tail_x15_r0_body.cbridge101,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s979.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s978.ffi) (PRE_first_tail_x15_r0_body.cfoot101 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_101 PRE_first_tail_x15_r0_body.ofx1_101 hobjC PRE_first_tail_x15_r0_body.ff0101 PRE_first_tail_x15_r0_body.ff1101 PRE_first_tail_x15_r0_body.ffck101,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s979.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s978.ffi) (PRE_first_tail_x15_r0_body.cfoot101 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_101 PRE_first_tail_x15_r0_body.okr1_101 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn101) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0101 PRE_first_tail_x15_r0_body.fkt0101 PRE_first_tail_x15_r0_body.fkf1101 PRE_first_tail_x15_r0_body.fkt1101 PRE_first_tail_x15_r0_body.fkck101,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0101 PRE_first_tail_x15_r0_body.cnh1101 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe101) PRE_first_tail_x15_r0_body.cpendR101⟩

end Host.Load.Run.Tpl
end

section -- st101/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st101 0
host_stream_state PRE_first_tail_x15_r0_body.st101 1
host_stream_state PRE_first_tail_x15_r0_body.st101 2
end Host.Load.Run.Tpl
end

section -- Site101
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 101 of chain `PRE_first_tail_x15_r0_body`: `plan__g101__g102` (`plan`), the call state `PRE_first_tail_x15_r0_body.s977`, the merged state `PRE_first_tail_x15_r0_body.s978`,
the site template `PRE_first_tail_x15_r0_body.st101` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s979`: the merge.
The footprint's facts are in `SiteF101`, the compaction's in `SiteC101`, `SiteK101`, `SiteNa101`, `SiteNb101`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso101 : PRE_first_tail_x15_r0_body.st101.s0 = { PRE_first_tail_x15_r0_body.s977 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs101 : List Frame := PRE_first_tail_x15_r0_body.s977.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_101 : PRE_first_tail_x15_r0_body.S977.tab.length = 4372
kernel_rfl PRE_first_tail_x15_r0_body.tab0_101 : PRE_first_tail_x15_r0_body.st101.S0.tab = PRE_first_tail_x15_r0_body.S977.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws101 : List Nat := [2709, 2710, 2711, 2712, 2713, 2714, 2715, 2716, 2717]
kernel_rfl PRE_first_tail_x15_r0_body.fresh101 : (PRE_first_tail_x15_r0_body.S977.tab.all fun e => PRE_first_tail_x15_r0_body.ws101.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S977.oracle.all fun q => PRE_first_tail_x15_r0_body.ws101.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab101 : PRE_first_tail_x15_r0_body.S978.tab = PRE_first_tail_x15_r0_body.S977.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws101
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen101 : PRE_first_tail_x15_r0_body.st101.S2.tab.length - PRE_first_tail_x15_r0_body.st101.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged101`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap101 : PRE_first_tail_x15_r0_body.s978.heap = PRE_first_tail_x15_r0_body.st101.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext101 : PRE_first_tail_x15_r0_body.s978.next = PRE_first_tail_x15_r0_body.st101.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl101 : PRE_first_tail_x15_r0_body.s978.ctl = PRE_first_tail_x15_r0_body.st101.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack101 : PRE_first_tail_x15_r0_body.s978.stack = PRE_first_tail_x15_r0_body.st101.s2.stack ++ PRE_first_tail_x15_r0_body.s977.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs101 : PRE_first_tail_x15_r0_body.s978.jobs = PRE_first_tail_x15_r0_body.st101.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi101 : PRE_first_tail_x15_r0_body.s978.ffi = PRE_first_tail_x15_r0_body.st101.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace101 : PRE_first_tail_x15_r0_body.s978.trace = PRE_first_tail_x15_r0_body.st101.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores101 : PRE_first_tail_x15_r0_body.s978.stores = PRE_first_tail_x15_r0_body.st101.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD101
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 101 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived101 : PRE_first_tail_x15_r0_body.nr101.map (fun r => nth? PRE_first_tail_x15_r0_body.st101.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo101 : PRE_first_tail_x15_r0_body.nr101.all (Nat.ble 4372) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj101 : PRE_first_tail_x15_r0_body.cws101.all (fun c => !PRE_first_tail_x15_r0_body.ws101.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ101 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws101 PRE_first_tail_x15_r0_body.crs101 PRE_first_tail_x15_r0_body.ws101

end Host.Load.Run.Tpl
end

section -- st101/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st101`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st101.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st101.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st101.s2.heap PRE_first_tail_x15_r0_body.st101.wrR ++ freshOf PRE_first_tail_x15_r0_body.st101.s2.heap PRE_first_tail_x15_r0_body.st101.s0.next PRE_first_tail_x15_r0_body.st101.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st101.wr : List Nat := PRE_first_tail_x15_r0_body.st101.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st101.heapFoot : PRE_first_tail_x15_r0_body.st101.s2.heap = setAll PRE_first_tail_x15_r0_body.st101.s0.heap PRE_first_tail_x15_r0_body.st101.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st101.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st101.s0.next PRE_first_tail_x15_r0_body.st101.s2.next = true
theorem PRE_first_tail_x15_r0_body.st101.grows : PRE_first_tail_x15_r0_body.st101.s0.next ≤ PRE_first_tail_x15_r0_body.st101.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st101.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st101.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st101.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st101.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st101.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st101.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st101.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st101.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st101.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st101.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st101.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st101.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF101
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 101 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB101 : nodupT PRE_first_tail_x15_r0_body.st101.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup101 : PRE_first_tail_x15_r0_body.st101.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB101).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB101 : PRE_first_tail_x15_r0_body.st101.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound101 : ∀ b ∈ PRE_first_tail_x15_r0_body.st101.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB101 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr101 := PRE_first_tail_x15_r0_body.st101.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq101 : PRE_first_tail_x15_r0_body.st101.s2.trace = PRE_first_tail_x15_r0_body.trFr101 ++ PRE_first_tail_x15_r0_body.st101.s0.trace
theorem PRE_first_tail_x15_r0_body.trace101 : ∃ fr, PRE_first_tail_x15_r0_body.st101.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st101.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq101⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide101 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB101 : (PRE_first_tail_x15_r0_body.wide101.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st101.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix101 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide101, WFix Map.id (Present PRE_first_tail_x15_r0_body.st101.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB101 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL101
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 101 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s978`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO101 : PRE_first_tail_x15_r0_body.st101.S0.oracle = PRE_first_tail_x15_r0_body.st101.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B101 : PRE_first_tail_x15_r0_body.st101.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st101.s0.next || (PRE_first_tail_x15_r0_body.st101.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot101 : Conv.StageFoot PRE_first_tail_x15_r0_body.st101.wr PRE_first_tail_x15_r0_body.st101.s0 PRE_first_tail_x15_r0_body.st101.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st101.heapFoot PRE_first_tail_x15_r0_body.wrNodup101 PRE_first_tail_x15_r0_body.wrBound101 PRE_first_tail_x15_r0_body.wr0B101 PRE_first_tail_x15_r0_body.st101.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged101 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st101.F.S → PRE_first_tail_x15_r0_body.st101.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st101.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st101.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs101 PRE_first_tail_x15_r0_body.st101.wr PRE_first_tail_x15_r0_body.s977 PRE_first_tail_x15_r0_body.st101.s2 PRE_first_tail_x15_r0_body.st101.s0
      PRE_first_tail_x15_r0_body.st101.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st101.F FR W stk M ν K PRE_first_tail_x15_r0_body.s978 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso101 PRE_first_tail_x15_r0_body.stFoot101 PRE_first_tail_x15_r0_body.wrNodup101 PRE_first_tail_x15_r0_body.wrBound101 PRE_first_tail_x15_r0_body.trace101 PRE_first_tail_x15_r0_body.mheap101
    PRE_first_tail_x15_r0_body.mnext101 PRE_first_tail_x15_r0_body.mctl101 PRE_first_tail_x15_r0_body.mstack101 PRE_first_tail_x15_r0_body.mjobs101 PRE_first_tail_x15_r0_body.mffi101 PRE_first_tail_x15_r0_body.mtrace101 PRE_first_tail_x15_r0_body.mstores101 h

def PRE_first_tail_x15_r0_body.arrEl101_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE101_2665 : arrOf PRE_first_tail_x15_r0_body.s978 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl101_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA101_2665 : isArrB PRE_first_tail_x15_r0_body.s978 2665 = true
theorem PRE_first_tail_x15_r0_body.arr101_2665 : ∃ o, PRE_first_tail_x15_r0_body.s978.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl101_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE101_2665 PRE_first_tail_x15_r0_body.arrA101_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN101_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl101_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR101_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl101_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN101_2665

def PRE_first_tail_x15_r0_body.arrEl101_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE101_2673467 : arrOf PRE_first_tail_x15_r0_body.s978 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl101_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA101_2673467 : isArrB PRE_first_tail_x15_r0_body.s978 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr101_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s978.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl101_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE101_2673467 PRE_first_tail_x15_r0_body.arrA101_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN101_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl101_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR101_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl101_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN101_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k101 : isArrB PRE_first_tail_x15_r0_body.s978 4910 = false
theorem PRE_first_tail_x15_r0_body.keep101 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s978 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k101 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr101_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl101_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ101
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 101 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s977`, the merged
state `PRE_first_tail_x15_r0_body.s978`, the canonical state `PRE_first_tail_x15_r0_body.s979`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl101 : PRE_first_tail_x15_r0_body.pl101.all (Nat.ble PRE_first_tail_x15_r0_body.s977.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd101 : nodupT PRE_first_tail_x15_r0_body.pl101 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1101 : Nat.ble PRE_first_tail_x15_r0_body.s977.next 2753855 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst101 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s977.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn101 : PRE_first_tail_x15_r0_body.s979.next = PRE_first_tail_x15_r0_body.s977.next + PRE_first_tail_x15_r0_body.pl101.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn101 : PRE_first_tail_x15_r0_body.s978.next = 2753855
kernel_rfl PRE_first_tail_x15_r0_body.zgrow101 : Nat.ble PRE_first_tail_x15_r0_body.s979.next PRE_first_tail_x15_r0_body.s978.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh101 : PRE_first_tail_x15_r0_body.S977.tab.all (fun e => PRE_first_tail_x15_r0_body.cws101.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd101 : nodupT PRE_first_tail_x15_r0_body.cws101 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi101 : PRE_first_tail_x15_r0_body.nr101.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S978.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt101 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s977.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg101_2665 : PRE_first_tail_x15_r0_body.s979.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s979 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk101_2665 : (objOf PRE_first_tail_x15_r0_body.s979 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm101_2665 : PRE_first_tail_x15_r0_body.s978.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa101.obj (objOf PRE_first_tail_x15_r0_body.s979 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s978 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg101_2673467 : PRE_first_tail_x15_r0_body.s979.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s979 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk101_2673467 : (objOf PRE_first_tail_x15_r0_body.s979 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm101_2673467 : PRE_first_tail_x15_r0_body.s978.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa101.obj (objOf PRE_first_tail_x15_r0_body.s979 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s978 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw101_4910 : (PRE_first_tail_x15_r0_body.s979.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw101_2673472 : (PRE_first_tail_x15_r0_body.s979.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw101_2673473 : (PRE_first_tail_x15_r0_body.s979.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd101 : PRE_first_tail_x15_r0_body.cl101.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr101 : PRE_first_tail_x15_r0_body.st101.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s977.next || PRE_first_tail_x15_r0_body.cl101.contains b) = true
def PRE_first_tail_x15_r0_body.zl101 : List Nat := PRE_first_tail_x15_r0_body.cl101.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE101 : PRE_first_tail_x15_r0_body.zl101.map (fun a => PRE_first_tail_x15_r0_body.s978.heap.get (PRE_first_tail_x15_r0_body.kappa101.a a)) = PRE_first_tail_x15_r0_body.zl101.map (fun a => (PRE_first_tail_x15_r0_body.s979.heap.get a).map PRE_first_tail_x15_r0_body.kappa101.hobj)
theorem PRE_first_tail_x15_r0_body.zimg101 : HeapImg PRE_first_tail_x15_r0_body.kappa101 PRE_first_tail_x15_r0_body.s979 PRE_first_tail_x15_r0_body.s978 PRE_first_tail_x15_r0_body.zl101 := PRE_first_tail_x15_r0_body.zimgE101
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl101 : PRE_first_tail_x15_r0_body.s978.ctl = PRE_first_tail_x15_r0_body.kappa101.ctl PRE_first_tail_x15_r0_body.s979.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack101 : PRE_first_tail_x15_r0_body.s978.stack = PRE_first_tail_x15_r0_body.s979.stack.map PRE_first_tail_x15_r0_body.kappa101.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs101 : PRE_first_tail_x15_r0_body.s978.jobs = PRE_first_tail_x15_r0_body.s979.jobs.map PRE_first_tail_x15_r0_body.kappa101.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores101 : PRE_first_tail_x15_r0_body.s978.stores = PRE_first_tail_x15_r0_body.kappa101.stores PRE_first_tail_x15_r0_body.s979.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots101 : checkRootsSupp PRE_first_tail_x15_r0_body.s979 4372 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC101 : PRE_first_tail_x15_r0_body.S977.tab.length + PRE_first_tail_x15_r0_body.cws101.length = 4372
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap101 : PRE_first_tail_x15_r0_body.kappa101 = Conv.Map.compact PRE_first_tail_x15_r0_body.s977.next 2753855 PRE_first_tail_x15_r0_body.S977.tab.length PRE_first_tail_x15_r0_body.pl101 (PRE_first_tail_x15_r0_body.nr101.map NumV.ref) PRE_first_tail_x15_r0_body.kd101.big
  PRE_first_tail_x15_r0_body.kd101.region PRE_first_tail_x15_r0_body.kd101.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin101 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s979.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc101 : Conv.jcleanListB (⟨20184, 17281, 2753836, 4372⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s979 PRE_first_tail_x15_r0_body.cl101 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB101 : noBigRootsP (fun i => !Conv.oldBigB (⟨20184, 17281, 2753836, 4372⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s979.trace PRE_first_tail_x15_r0_body.s979 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm101 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17281 = true
theorem PRE_first_tail_x15_r0_body.cjcl101 (h : Conv.JClean (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s977) : Conv.JClean (⟨20184, 17281, 2753836, 4372⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s979 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle101)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap101 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd101 a ha)) PRE_first_tail_x15_r0_body.zjc101

end Host.Load.Run.Tpl
end

section -- st101/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st101.bodyLast from PRE_first_tail_x15_r0_body.st101.s1 to PRE_first_tail_x15_r0_body.st101.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st101.F PRE_first_tail_x15_r0_body.st101.s1).run PRE_first_tail_x15_r0_body.st101.S1 = some (PRE_first_tail_x15_r0_body.st101.s2, PRE_first_tail_x15_r0_body.st101.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st101.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st101.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st101.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st101.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st101/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st101.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st101.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st101.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st101.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st101.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st101.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st101.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st101.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st101.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st101.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st101.s0 PRE_first_tail_x15_r0_body.st101.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st101.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st101.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st101.s1 PRE_first_tail_x15_r0_body.st101.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st101/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st101.bodyK0F from PRE_first_tail_x15_r0_body.st101.s0 to PRE_first_tail_x15_r0_body.st101.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st101.F (PRE_first_tail_x15_r0_body.st101.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st101.ks 0).getD 0) PRE_first_tail_x15_r0_body.st101.s0 PRE_first_tail_x15_r0_body.st101.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st101.s1, PRE_first_tail_x15_r0_body.st101.S1)
theorem PRE_first_tail_x15_r0_body.st101.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st101.F (PRE_first_tail_x15_r0_body.st101.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st101.ks 0).getD 0) PRE_first_tail_x15_r0_body.st101.s0 PRE_first_tail_x15_r0_body.st101.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st101.s1, PRE_first_tail_x15_r0_body.st101.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st101.bodyOkLN_ok PRE_first_tail_x15_r0_body.st101.bodyK0F
end Host.Load.Run.Tpl
end

section -- st101/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st101.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st101.F (PRE_first_tail_x15_r0_body.st101.bodyOkL bytes rows) 206 PRE_first_tail_x15_r0_body.st101.s0 PRE_first_tail_x15_r0_body.st101.S0 = some (PRE_first_tail_x15_r0_body.st101.s1, PRE_first_tail_x15_r0_body.st101.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st101.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st101.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st101.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st101.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st101.F (PRE_first_tail_x15_r0_body.st101.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st101.s0
  S0 := PRE_first_tail_x15_r0_body.st101.S0
  s1 := PRE_first_tail_x15_r0_body.st101.s1
  S1 := PRE_first_tail_x15_r0_body.st101.S1
  s2 := PRE_first_tail_x15_r0_body.st101.s2
  S2 := PRE_first_tail_x15_r0_body.st101.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st101.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st101.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st101.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st101.bodyHalt
  last := PRE_first_tail_x15_r0_body.st101.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st101.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC102
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 102 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s996` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa102` into the merged state
`PRE_first_tail_x15_r0_body.s995`. -/

def PRE_first_tail_x15_r0_body.pl102 : List Nat := [2756423, 2755598, 2756429, 2756425, 2755600, 2756431]
def PRE_first_tail_x15_r0_body.nr102 : List Nat := [4475, 4474, 4450, 4458, 4463, 4468, 4473, 4447, 4448, 4449, 4456, 4457, 4445, 4452, 4453, 4454, 4455, 4451]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd102 : RData :=
  ⟨2755317, 2756466, Stage.setAll PTrie.nil [(2755311, 2756423), (2755312, 2755598), (2755313, 2756429), (2755314, 2756425), (2755315, 2755600), (2755316, 2756431)], Stage.setAll PTrie.nil [(20218, 20244), (20219, 20222), (20220, 20245)],
   20221, 20246, 17327, 17327, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4445, .ref 4475), (4446, .ref 4474), (4447, .ref 4450), (4448, .ref 4458), (4449, .ref 4463), (4450, .ref 4468), (4451, .ref 4473), (4452, .ref 4447), (4453, .ref 4448), (4454, .ref 4449), (4455, .ref 4456), (4456, .ref 4457), (4457, .ref 4445), (4458, .ref 4452), (4459, .ref 4453), (4460, .ref 4454), (4461, .ref 4455), (4462, .ref 4451)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa102 : Map :=
  Conv.Map.compact 2755311 2756466 4445 PRE_first_tail_x15_r0_body.pl102 (PRE_first_tail_x15_r0_body.nr102.map NumV.ref) PRE_first_tail_x15_r0_body.kd102.big
    PRE_first_tail_x15_r0_body.kd102.region PRE_first_tail_x15_r0_body.kd102.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws102 : List Nat := [2749, 2750, 2751, 2752, 2753, 2754, 2755, 2756, 2757, 2758, 2759, 2760, 2761, 2762, 2763, 2764, 2765, 2766]
noncomputable def PRE_first_tail_x15_r0_body.crs102 : List SymE := PRE_first_tail_x15_r0_body.nr102.map fun r => (nth? PRE_first_tail_x15_r0_body.S995.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta102 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws102 PRE_first_tail_x15_r0_body.crs102
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB102 : List Nat := [2665, 2672558, 2673467, 2754485, 2755030, 2755286]

kernel_rfl PRE_first_tail_x15_r0_body.ctab102 : PRE_first_tail_x15_r0_body.S996.tab = PRE_first_tail_x15_r0_body.S994.tab ++ PRE_first_tail_x15_r0_body.cws102.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace102 : PRE_first_tail_x15_r0_body.s996.trace = PRE_first_tail_x15_r0_body.s994.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext102 : PRE_first_tail_x15_r0_body.s996.next = 2755317
kernel_rfl PRE_first_tail_x15_r0_body.ccounters102 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.nnext) = (20221, 17327)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue102 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s995.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa102.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp102 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.tokens.all (bSN 4463) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean102 : Conv.cleanListB 20221 131072 (fun r => Nat.ble 80884 r) PRE_first_tail_x15_r0_body.s996
    (PRE_first_tail_x15_r0_body.wrB102 ++ (List.range 6).map (2755311 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs102 : bigsOutB 20221 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK102
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl102`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl102 : List Nat := [2665, 2672558, 2673467, 2754485, 2755030, 2755286, 2755311, 2755312, 2755313, 2755314, 2755315, 2755316]
def PRE_first_tail_x15_r0_body.clo102 : List Nat := [20198, 20211, 20217, 20218, 20219, 20220]
def PRE_first_tail_x15_r0_body.cln102 : List Nat := [17300, 17301, 17302, 17303, 17304, 17305, 17306, 17307, 17308, 17309, 17310, 17311, 17312, 17313, 17314, 17315, 17316, 17317, 17318, 17319, 17320, 17321, 17322, 17323, 17324, 17325, 17326]
def PRE_first_tail_x15_r0_body.cli102 : List Nat := [17300, 17301, 17302, 17303, 17304, 17305, 17306, 17307, 17308, 17309, 17310, 17311, 17312, 17313, 17314, 17315, 17316, 17317, 17318, 17319, 17320, 17321, 17322, 17323, 17324, 17325, 17326]
kernel_rfl PRE_first_tail_x15_r0_body.cheap102 : PRE_first_tail_x15_r0_body.s996.heap = Stage.setAll PRE_first_tail_x15_r0_body.s994.heap (PRE_first_tail_x15_r0_body.cl102.filterMap fun a => (PRE_first_tail_x15_r0_body.s996.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe102 : Nat.ble PRE_first_tail_x15_r0_body.s994.next PRE_first_tail_x15_r0_body.s996.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP102 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s994 PRE_first_tail_x15_r0_body.s996 PRE_first_tail_x15_r0_body.cl102 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp102 : Conv.suppListB PRE_first_tail_x15_r0_body.s996 4463 PRE_first_tail_x15_r0_body.cl102 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound102 : Conv.boundListB PRE_first_tail_x15_r0_body.s996 PRE_first_tail_x15_r0_body.cl102 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK102 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln102.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK102 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo102.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK102 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli102.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst102 : Conv.sstListB 4463 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx PRE_first_tail_x15_r0_body.cln102 PRE_first_tail_x15_r0_body.clo102 PRE_first_tail_x15_r0_body.cli102 = true

end Host.Load.Run.Tpl
end

section -- SiteCl102
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA102 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo102.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd102 : (PRE_first_tail_x15_r0_body.clo102 ++ PRE_first_tail_x15_r0_body.cln102 ++ PRE_first_tail_x15_r0_body.cli102).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle102 : Conv.Cnt.leB (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt) (⟨20221, 17327, 2755317, 4463⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck102 : Conv.ncleanListB (⟨20221, 17327, 2755317, 4463⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx PRE_first_tail_x15_r0_body.clo102 PRE_first_tail_x15_r0_body.cln102 PRE_first_tail_x15_r0_body.cli102 = true
theorem PRE_first_tail_x15_r0_body.cncl102 (h : Conv.NClean (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx) : Conv.NClean (⟨20221, 17327, 2755317, 4463⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle102 PRE_first_tail_x15_r0_body.ckA102 PRE_first_tail_x15_r0_body.cobjsK102 PRE_first_tail_x15_r0_body.cnodesK102 PRE_first_tail_x15_r0_body.citemsK102 PRE_first_tail_x15_r0_body.cbd102 PRE_first_tail_x15_r0_body.cck102

end Host.Load.Run.Tpl
end

section -- SiteS102
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 102 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc102 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P102 : LoadP := PRE_first_tail_x15_r0_body.Pc102.raise 17327
kernel_rfl PRE_first_tail_x15_r0_body.craise102 : Nat.ble PRE_first_tail_x15_r0_body.Pc102.N0 17327 = true
theorem PRE_first_tail_x15_r0_body.raised102 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc102 PRE_first_tail_x15_r0_body.P102 :=
  .inr ⟨17327, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise102, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_102 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_102 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s995.ffi)
def PRE_first_tail_x15_r0_body.khinv102 : PTrie Nat := Stage.setAll PTrie.nil [(20244, 20218), (20222, 20219), (20245, 20220)]
def PRE_first_tail_x15_r0_body.kninv102 : PTrie Nat := Stage.setAll PTrie.nil [(17300, 17300), (17301, 17301), (17302, 17302), (17303, 17303), (17304, 17304), (17305, 17305), (17306, 17306), (17307, 17307), (17308, 17308), (17309, 17309), (17310, 17310), (17311, 17311), (17312, 17312), (17313, 17313), (17314, 17314), (17315, 17315), (17316, 17316), (17317, 17317), (17318, 17318), (17319, 17319), (17320, 17320), (17321, 17321), (17322, 17322), (17323, 17323), (17324, 17324), (17325, 17325), (17326, 17326)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS102 : List Nat := [20198, 20211, 20217, 20218, 20219, 20220, 20221, 20222, 20223, 20224, 20225, 20226, 20227, 20228, 20229, 20230, 20231, 20232, 20233, 20234, 20235, 20236, 20237, 20238, 20239, 20240, 20241, 20242, 20243, 20244, 20245]
def PRE_first_tail_x15_r0_body.cnS102 : List Nat := List.range' 17300 27
def PRE_first_tail_x15_r0_body.ciS102 : List Nat := [] ++ List.range' 17300 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0102 : PRE_first_tail_x15_r0_body.kd102.nh0 = PRE_first_tail_x15_r0_body.cx0_102.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1102 : PRE_first_tail_x15_r0_body.kd102.nh1 = PRE_first_tail_x15_r0_body.cx1_102.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0102 : PRE_first_tail_x15_r0_body.kd102.nn0 = PRE_first_tail_x15_r0_body.cx0_102.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1102 : PRE_first_tail_x15_r0_body.kd102.nn1 = PRE_first_tail_x15_r0_body.cx1_102.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo102 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P102.lo && Nat.ble PRE_first_tail_x15_r0_body.P102.lo PRE_first_tail_x15_r0_body.cx0_102.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P102.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P102.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt102 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_102.mlx.next PRE_first_tail_x15_r0_body.cx1_102.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_102.mlx.nnext PRE_first_tail_x15_r0_body.cx1_102.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband102 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P102.NL && Nat.ble PRE_first_tail_x15_r0_body.P102.NL PRE_first_tail_x15_r0_body.P102.N0 && Nat.ble PRE_first_tail_x15_r0_body.P102.N0 PRE_first_tail_x15_r0_body.cx0_102.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow102 : PRE_first_tail_x15_r0_body.kd102.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren102 : checkRenG PRE_first_tail_x15_r0_body.kd102.hnd PRE_first_tail_x15_r0_body.khinv102 (phB PRE_first_tail_x15_r0_body.cx0_102.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband102 : PRE_first_tail_x15_r0_body.kd102.checkBand PRE_first_tail_x15_r0_body.P102.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos102 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd102.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren102 : checkRenG PRE_first_tail_x15_r0_body.kd102.node PRE_first_tail_x15_r0_body.kninv102 (pnB PRE_first_tail_x15_r0_body.cx0_102.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow102 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd102.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P102.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd102.nodeF j) PRE_first_tail_x15_r0_body.cx1_102.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a102 : PRE_first_tail_x15_r0_body.cx0_102.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b102 : PRE_first_tail_x15_r0_body.cx0_102.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1102 : PRE_first_tail_x15_r0_body.cx1_102.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend102 : PRE_first_tail_x15_r0_body.cx1_102.mlx.pending = PRE_first_tail_x15_r0_body.cx0_102.mlx.pending.map PRE_first_tail_x15_r0_body.kappa102.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh102 : PRE_first_tail_x15_r0_body.cx1_102.mlx.errh = PRE_first_tail_x15_r0_body.cx0_102.mlx.errh.map PRE_first_tail_x15_r0_body.kappa102.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles102 : PRE_first_tail_x15_r0_body.cx1_102.mlx.files = PRE_first_tail_x15_r0_body.cx0_102.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch102 : PRE_first_tail_x15_r0_body.cx1_102.mlx.arch = PRE_first_tail_x15_r0_body.cx0_102.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes102 : PRE_first_tail_x15_r0_body.cx1_102.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_102.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired102 : PRE_first_tail_x15_r0_body.cx1_102.mlx.wired = PRE_first_tail_x15_r0_body.cx0_102.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost102 : PRE_first_tail_x15_r0_body.cx1_102.host = PRE_first_tail_x15_r0_body.cx0_102.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd102`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0102 : PRE_first_tail_x15_r0_body.kd102.n0 = 2755317
kernel_rfl PRE_first_tail_x15_r0_body.ckn1102 : PRE_first_tail_x15_r0_body.kd102.n1 = 2756466
kernel_rfl PRE_first_tail_x15_r0_body.ckheap102 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd102.heap).all (fun x => Nat.ble 2755311 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl102 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd102.heap.get (2755311 + j) = nth? PRE_first_tail_x15_r0_body.pl102 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja102 : Nat.ble 2755311 2755311 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn102 : Nat.ble 4445 4445 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD102 : Nat.ble 2755311 PRE_first_tail_x15_r0_body.kd102.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn102 : Nat.ble 20218 PRE_first_tail_x15_r0_body.kd102.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn102 : Nat.ble 17300 PRE_first_tail_x15_r0_body.kd102.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb102 : Nat.ble 20218 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap102 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd102.heap).all (Nat.ble (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd102 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd102.hnd).all (Nat.ble (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode102 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd102.node).all (Nat.ble (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix102 : Conv.FixOld (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa102 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja102) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn102) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD102) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn102) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn102) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb102) PRE_first_tail_x15_r0_body.fheap102 PRE_first_tail_x15_r0_body.fhnd102 PRE_first_tail_x15_r0_body.fnode102
kernel_rfl PRE_first_tail_x15_r0_body.fcxn102 : (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn102 : (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0102 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_102.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_102.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk102 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd102.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A102 : PRE_first_tail_x15_r0_body.cx1_102.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS102.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_102.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O102 : PRE_first_tail_x15_r0_body.cx1_102.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS102.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_102.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N102 : PRE_first_tail_x15_r0_body.cx1_102.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS102.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_102.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I102 : PRE_first_tail_x15_r0_body.cx1_102.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS102.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_102.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd102 : (PRE_first_tail_x15_r0_body.clo102 ++ PRE_first_tail_x15_r0_body.cln102 ++ PRE_first_tail_x15_r0_body.cli102 ++ PRE_first_tail_x15_r0_body.cwS102 ++ PRE_first_tail_x15_r0_body.cnS102 ++ PRE_first_tail_x15_r0_body.ciS102).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW102 : PRE_first_tail_x15_r0_body.cwS102.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo102.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI102 : PRE_first_tail_x15_r0_body.ciS102.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli102.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN102 : PRE_first_tail_x15_r0_body.cnS102.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF102 : PRE_first_tail_x15_r0_body.cln102.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh102 : PRE_first_tail_x15_r0_body.clo102.all (handleOK PRE_first_tail_x15_r0_body.kappa102 PRE_first_tail_x15_r0_body.P102.lo PRE_first_tail_x15_r0_body.cx0_102.mlx PRE_first_tail_x15_r0_body.cx1_102.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo102 : PRE_first_tail_x15_r0_body.clo102.map (fun h => PRE_first_tail_x15_r0_body.cx1_102.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa102.handle h)) = PRE_first_tail_x15_r0_body.clo102.map (fun h => (PRE_first_tail_x15_r0_body.cx0_102.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa102.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok102 : PRE_first_tail_x15_r0_body.clo102.all (objOK PRE_first_tail_x15_r0_body.kappa102 PRE_first_tail_x15_r0_body.P102.NL PRE_first_tail_x15_r0_body.cx0_102.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd102 : PRE_first_tail_x15_r0_body.cln102.all (nodeOKF PRE_first_tail_x15_r0_body.kappa102 PRE_first_tail_x15_r0_body.P102 PRE_first_tail_x15_r0_body.cx0_102.mlx PRE_first_tail_x15_r0_body.cx1_102.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp102 : ((PRE_first_tail_x15_r0_body.cln102.filter (fullB PRE_first_tail_x15_r0_body.P102))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_102.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa102.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln102.filter (fullB PRE_first_tail_x15_r0_body.P102))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_102.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa102.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI102 : incrB PRE_first_tail_x15_r0_body.kd102.nodeF (List.range' 17300 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK102 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd102.node).all (fun k => Nat.ble 17300 k && Nat.blt k 17327) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL102 : (PRE_first_tail_x15_r0_body.cln102.filter (Nat.ble PRE_first_tail_x15_r0_body.P102.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd102.nodeF i) && (Nat.blt i 17327 || Nat.ble PRE_first_tail_x15_r0_body.kd102.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord102 : (PRE_first_tail_x15_r0_body.cln102.filter (Nat.ble PRE_first_tail_x15_r0_body.P102.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd102.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd102.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd102.nodeF j) (PRE_first_tail_x15_r0_body.kd102.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow102 PRE_first_tail_x15_r0_body.cnn1102 PRE_first_tail_x15_r0_body.fnordI102 PRE_first_tail_x15_r0_body.fnordK102 PRE_first_tail_x15_r0_body.fnordL102
kernel_rfl PRE_first_tail_x15_r0_body.fi102 : PRE_first_tail_x15_r0_body.cli102.all (pnB PRE_first_tail_x15_r0_body.cx0_102.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii102 : PRE_first_tail_x15_r0_body.cli102.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_102.mlx.items.get (PRE_first_tail_x15_r0_body.kappa102.node k) = (PRE_first_tail_x15_r0_body.cx0_102.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa102.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot102 (clean : Conv.NClean (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P102.NL) (cl : SSt (· < 4463) PRE_first_tail_x15_r0_body.cx0_102.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P102 4463 PRE_first_tail_x15_r0_body.kappa102 PRE_first_tail_x15_r0_body.kd102 PRE_first_tail_x15_r0_body.khinv102 PRE_first_tail_x15_r0_body.kninv102 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx PRE_first_tail_x15_r0_body.cx0_102.mlx PRE_first_tail_x15_r0_body.cx1_102.mlx (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo102 PRE_first_tail_x15_r0_body.cln102 PRE_first_tail_x15_r0_body.cli102 PRE_first_tail_x15_r0_body.cwS102 PRE_first_tail_x15_r0_body.cnS102 PRE_first_tail_x15_r0_body.ciS102 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0102, PRE_first_tail_x15_r0_body.cnh1102, PRE_first_tail_x15_r0_body.cnn0102, PRE_first_tail_x15_r0_body.cnn1102, PRE_first_tail_x15_r0_body.cplo102, PRE_first_tail_x15_r0_body.ccnt102, PRE_first_tail_x15_r0_body.cnband102, PRE_first_tail_x15_r0_body.chbelow102, PRE_first_tail_x15_r0_body.chren102, PRE_first_tail_x15_r0_body.cband102, PRE_first_tail_x15_r0_body.cnh1pos102, PRE_first_tail_x15_r0_body.cnren102, PRE_first_tail_x15_r0_body.cnlow102, PRE_first_tail_x15_r0_body.cabs0a102, PRE_first_tail_x15_r0_body.cabs0b102, PRE_first_tail_x15_r0_body.ctok1102, PRE_first_tail_x15_r0_body.cpend102, PRE_first_tail_x15_r0_body.cerrh102, PRE_first_tail_x15_r0_body.cfiles102, PRE_first_tail_x15_r0_body.carch102, PRE_first_tail_x15_r0_body.csizes102, PRE_first_tail_x15_r0_body.cwired102, PRE_first_tail_x15_r0_body.cfix102, clean, PRE_first_tail_x15_r0_body.fcxn102, PRE_first_tail_x15_r0_body.fcnn102, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0102, PRE_first_tail_x15_r0_body.fnk102, PRE_first_tail_x15_r0_body.ckA102, PRE_first_tail_x15_r0_body.cobjsK102, PRE_first_tail_x15_r0_body.cnodesK102, PRE_first_tail_x15_r0_body.citemsK102, PRE_first_tail_x15_r0_body.f1A102, PRE_first_tail_x15_r0_body.f1O102, PRE_first_tail_x15_r0_body.f1N102, PRE_first_tail_x15_r0_body.f1I102, PRE_first_tail_x15_r0_body.fbd102, PRE_first_tail_x15_r0_body.fincW102, PRE_first_tail_x15_r0_body.fincI102, PRE_first_tail_x15_r0_body.fincN102, PRE_first_tail_x15_r0_body.flnF102, PRE_first_tail_x15_r0_body.fh102, PRE_first_tail_x15_r0_body.fo102, PRE_first_tail_x15_r0_body.fok102, PRE_first_tail_x15_r0_body.fnd102, PRE_first_tail_x15_r0_body.fp102, PRE_first_tail_x15_r0_body.fnord102, PRE_first_tail_x15_r0_body.fi102, PRE_first_tail_x15_r0_body.fii102⟩
theorem PRE_first_tail_x15_r0_body.cnshift102 (clean : Conv.NClean (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P102.NL) (cl : SSt (· < 4463) PRE_first_tail_x15_r0_body.cx0_102.mlx) : NShift PRE_first_tail_x15_r0_body.P102 4463 PRE_first_tail_x15_r0_body.kappa102 PRE_first_tail_x15_r0_body.cx0_102 PRE_first_tail_x15_r0_body.cx1_102 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot102 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost102 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0102 PRE_first_tail_x15_r0_body.ckn1102 PRE_first_tail_x15_r0_body.ckheap102 PRE_first_tail_x15_r0_body.ckpl102)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_102 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s994.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_102 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s994.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_102 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s994.ffi) = some PRE_first_tail_x15_r0_body.fxC_102
kernel_rfl PRE_first_tail_x15_r0_body.okrC_102 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s994.ffi) = some PRE_first_tail_x15_r0_body.krC_102
noncomputable def PRE_first_tail_x15_r0_body.fx0_102 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s996.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_102 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s996.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_102 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s996.ffi) = some PRE_first_tail_x15_r0_body.fx0_102
kernel_rfl PRE_first_tail_x15_r0_body.okr0_102 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s996.ffi) = some PRE_first_tail_x15_r0_body.kr0_102
noncomputable def PRE_first_tail_x15_r0_body.fx1_102 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s995.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_102 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s995.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_102 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s995.ffi) = some PRE_first_tail_x15_r0_body.fx1_102
kernel_rfl PRE_first_tail_x15_r0_body.okr1_102 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s995.ffi) = some PRE_first_tail_x15_r0_body.kr1_102
kernel_rfl PRE_first_tail_x15_r0_body.ff0102 : PRE_first_tail_x15_r0_body.fx0_102 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_102 (PRE_first_tail_x15_r0_body.clo102.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_102.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1102 : PRE_first_tail_x15_r0_body.fx1_102 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_102 (PRE_first_tail_x15_r0_body.cwS102.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_102.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck102 : freedLB PRE_first_tail_x15_r0_body.kappa102 PRE_first_tail_x15_r0_body.cx0_102.mlx PRE_first_tail_x15_r0_body.fx0_102 PRE_first_tail_x15_r0_body.fx1_102 PRE_first_tail_x15_r0_body.clo102 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0102 : PRE_first_tail_x15_r0_body.kr0_102.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_102.flags (PRE_first_tail_x15_r0_body.clo102.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_102.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0102 : PRE_first_tail_x15_r0_body.kr0_102.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_102.targs (PRE_first_tail_x15_r0_body.clo102.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_102.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1102 : PRE_first_tail_x15_r0_body.kr1_102.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_102.flags (PRE_first_tail_x15_r0_body.cwS102.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_102.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1102 : PRE_first_tail_x15_r0_body.kr1_102.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_102.targs (PRE_first_tail_x15_r0_body.cwS102.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_102.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck102 : krecLB PRE_first_tail_x15_r0_body.kappa102 4463 PRE_first_tail_x15_r0_body.cx0_102.mlx PRE_first_tail_x15_r0_body.kr0_102 PRE_first_tail_x15_r0_body.kr1_102 PRE_first_tail_x15_r0_body.clo102 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn102 : Nat.ble 4445 4463 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge102 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s995.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s996.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR102 : pendRegB PRE_first_tail_x15_r0_body.kappa102 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe102 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s995.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift102 (clean : Conv.NClean (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P102.NL) (cl : SSt (· < 4463) PRE_first_tail_x15_r0_body.cx0_102.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_102.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_102.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_102.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_102.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P102 4463 PRE_first_tail_x15_r0_body.kappa102 PRE_first_tail_x15_r0_body.s996.ffi PRE_first_tail_x15_r0_body.s995.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift102 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue102, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp102 t ht),
    PRE_first_tail_x15_r0_body.cbridge102,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s996.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s995.ffi) (PRE_first_tail_x15_r0_body.cfoot102 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_102 PRE_first_tail_x15_r0_body.ofx1_102 hobjC PRE_first_tail_x15_r0_body.ff0102 PRE_first_tail_x15_r0_body.ff1102 PRE_first_tail_x15_r0_body.ffck102,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s996.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s995.ffi) (PRE_first_tail_x15_r0_body.cfoot102 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_102 PRE_first_tail_x15_r0_body.okr1_102 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn102) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0102 PRE_first_tail_x15_r0_body.fkt0102 PRE_first_tail_x15_r0_body.fkf1102 PRE_first_tail_x15_r0_body.fkt1102 PRE_first_tail_x15_r0_body.fkck102,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0102 PRE_first_tail_x15_r0_body.cnh1102 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe102) PRE_first_tail_x15_r0_body.cpendR102⟩

end Host.Load.Run.Tpl
end

section -- st102/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st102 0
host_stream_state PRE_first_tail_x15_r0_body.st102 1
host_stream_state PRE_first_tail_x15_r0_body.st102 2
host_stream_state PRE_first_tail_x15_r0_body.st102 3
host_stream_state PRE_first_tail_x15_r0_body.st102 4
host_stream_state PRE_first_tail_x15_r0_body.st102 5
end Host.Load.Run.Tpl
end

section -- Site102
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 102 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g102__g103` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s994`, the merged state `PRE_first_tail_x15_r0_body.s995`,
the site template `PRE_first_tail_x15_r0_body.st102` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s996`: the merge.
The footprint's facts are in `SiteF102`, the compaction's in `SiteC102`, `SiteK102`, `SiteNa102`, `SiteNb102`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso102 : PRE_first_tail_x15_r0_body.st102.s0 = { PRE_first_tail_x15_r0_body.s994 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs102 : List Frame := PRE_first_tail_x15_r0_body.s994.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_102 : PRE_first_tail_x15_r0_body.S994.tab.length = 4445
kernel_rfl PRE_first_tail_x15_r0_body.tab0_102 : PRE_first_tail_x15_r0_body.st102.S0.tab = PRE_first_tail_x15_r0_body.S994.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws102 : List Nat := [2718, 2719, 2720, 2721, 2722, 2723, 2724, 2725, 2726, 2727, 2728, 2729, 2730, 2731, 2732, 2733, 2734, 2735, 2736, 2737, 2738, 2739, 2740, 2741, 2742, 2743, 2744, 2745, 2746, 2747, 2748]
kernel_rfl PRE_first_tail_x15_r0_body.fresh102 : (PRE_first_tail_x15_r0_body.S994.tab.all fun e => PRE_first_tail_x15_r0_body.ws102.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S994.oracle.all fun q => PRE_first_tail_x15_r0_body.ws102.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab102 : PRE_first_tail_x15_r0_body.S995.tab = PRE_first_tail_x15_r0_body.S994.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws102
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen102 : PRE_first_tail_x15_r0_body.st102.S5.tab.length - PRE_first_tail_x15_r0_body.st102.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged102`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap102 : PRE_first_tail_x15_r0_body.s995.heap = PRE_first_tail_x15_r0_body.st102.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext102 : PRE_first_tail_x15_r0_body.s995.next = PRE_first_tail_x15_r0_body.st102.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl102 : PRE_first_tail_x15_r0_body.s995.ctl = PRE_first_tail_x15_r0_body.st102.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack102 : PRE_first_tail_x15_r0_body.s995.stack = PRE_first_tail_x15_r0_body.st102.s5.stack ++ PRE_first_tail_x15_r0_body.s994.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs102 : PRE_first_tail_x15_r0_body.s995.jobs = PRE_first_tail_x15_r0_body.st102.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi102 : PRE_first_tail_x15_r0_body.s995.ffi = PRE_first_tail_x15_r0_body.st102.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace102 : PRE_first_tail_x15_r0_body.s995.trace = PRE_first_tail_x15_r0_body.st102.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores102 : PRE_first_tail_x15_r0_body.s995.stores = PRE_first_tail_x15_r0_body.st102.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD102
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 102 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived102 : PRE_first_tail_x15_r0_body.nr102.map (fun r => nth? PRE_first_tail_x15_r0_body.st102.S5.tab r) =
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
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo102 : PRE_first_tail_x15_r0_body.nr102.all (Nat.ble 4445) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj102 : PRE_first_tail_x15_r0_body.cws102.all (fun c => !PRE_first_tail_x15_r0_body.ws102.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ102 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws102 PRE_first_tail_x15_r0_body.crs102 PRE_first_tail_x15_r0_body.ws102

end Host.Load.Run.Tpl
end

section -- st102/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st102`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st102.wrR : List (Nat × Nat) := [(2672558, 2672559), (2754485, 2754486), (2755030, 2755031), (2755286, 2755287)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st102.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st102.s5.heap PRE_first_tail_x15_r0_body.st102.wrR ++ freshOf PRE_first_tail_x15_r0_body.st102.s5.heap PRE_first_tail_x15_r0_body.st102.s0.next PRE_first_tail_x15_r0_body.st102.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st102.wr : List Nat := PRE_first_tail_x15_r0_body.st102.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st102.heapFoot : PRE_first_tail_x15_r0_body.st102.s5.heap = setAll PRE_first_tail_x15_r0_body.st102.s0.heap PRE_first_tail_x15_r0_body.st102.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st102.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st102.s0.next PRE_first_tail_x15_r0_body.st102.s5.next = true
theorem PRE_first_tail_x15_r0_body.st102.grows : PRE_first_tail_x15_r0_body.st102.s0.next ≤ PRE_first_tail_x15_r0_body.st102.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st102.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st102.wh : List Nat := [20198, 20211, 20217, 20218, 20219, 20220, 20221, 20222, 20223, 20224, 20225, 20226, 20227, 20228, 20229, 20230, 20231, 20232, 20233, 20234, 20235, 20236, 20237, 20238, 20239, 20240, 20241, 20242, 20243, 20244, 20245]
def PRE_first_tail_x15_r0_body.st102.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st102.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st102.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st102.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st102.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st102.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st102.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st102.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st102.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF102
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 102 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB102 : nodupT PRE_first_tail_x15_r0_body.st102.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup102 : PRE_first_tail_x15_r0_body.st102.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB102).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB102 : PRE_first_tail_x15_r0_body.st102.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound102 : ∀ b ∈ PRE_first_tail_x15_r0_body.st102.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB102 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr102 := PRE_first_tail_x15_r0_body.st102.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq102 : PRE_first_tail_x15_r0_body.st102.s5.trace = PRE_first_tail_x15_r0_body.trFr102 ++ PRE_first_tail_x15_r0_body.st102.s0.trace
theorem PRE_first_tail_x15_r0_body.trace102 : ∃ fr, PRE_first_tail_x15_r0_body.st102.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st102.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq102⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide102 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB102 : (PRE_first_tail_x15_r0_body.wide102.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st102.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix102 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide102, WFix Map.id (Present PRE_first_tail_x15_r0_body.st102.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB102 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL102
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 102 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s995`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO102 : PRE_first_tail_x15_r0_body.st102.S0.oracle = PRE_first_tail_x15_r0_body.st102.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B102 : PRE_first_tail_x15_r0_body.st102.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st102.s0.next || (PRE_first_tail_x15_r0_body.st102.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot102 : Conv.StageFoot PRE_first_tail_x15_r0_body.st102.wr PRE_first_tail_x15_r0_body.st102.s0 PRE_first_tail_x15_r0_body.st102.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st102.heapFoot PRE_first_tail_x15_r0_body.wrNodup102 PRE_first_tail_x15_r0_body.wrBound102 PRE_first_tail_x15_r0_body.wr0B102 PRE_first_tail_x15_r0_body.st102.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged102 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st102.F.S → PRE_first_tail_x15_r0_body.st102.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st102.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st102.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs102 PRE_first_tail_x15_r0_body.st102.wr PRE_first_tail_x15_r0_body.s994 PRE_first_tail_x15_r0_body.st102.s5 PRE_first_tail_x15_r0_body.st102.s0
      PRE_first_tail_x15_r0_body.st102.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st102.F FR W stk M ν K PRE_first_tail_x15_r0_body.s995 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso102 PRE_first_tail_x15_r0_body.stFoot102 PRE_first_tail_x15_r0_body.wrNodup102 PRE_first_tail_x15_r0_body.wrBound102 PRE_first_tail_x15_r0_body.trace102 PRE_first_tail_x15_r0_body.mheap102
    PRE_first_tail_x15_r0_body.mnext102 PRE_first_tail_x15_r0_body.mctl102 PRE_first_tail_x15_r0_body.mstack102 PRE_first_tail_x15_r0_body.mjobs102 PRE_first_tail_x15_r0_body.mffi102 PRE_first_tail_x15_r0_body.mtrace102 PRE_first_tail_x15_r0_body.mstores102 h

def PRE_first_tail_x15_r0_body.arrEl102_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE102_2665 : arrOf PRE_first_tail_x15_r0_body.s995 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl102_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA102_2665 : isArrB PRE_first_tail_x15_r0_body.s995 2665 = true
theorem PRE_first_tail_x15_r0_body.arr102_2665 : ∃ o, PRE_first_tail_x15_r0_body.s995.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl102_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE102_2665 PRE_first_tail_x15_r0_body.arrA102_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN102_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl102_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR102_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl102_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN102_2665

def PRE_first_tail_x15_r0_body.arrEl102_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE102_2673467 : arrOf PRE_first_tail_x15_r0_body.s995 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl102_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA102_2673467 : isArrB PRE_first_tail_x15_r0_body.s995 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr102_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s995.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl102_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE102_2673467 PRE_first_tail_x15_r0_body.arrA102_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN102_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl102_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR102_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl102_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN102_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k102 : isArrB PRE_first_tail_x15_r0_body.s995 4910 = false
theorem PRE_first_tail_x15_r0_body.keep102 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s995 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k102 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr102_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl102_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ102
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 102 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s994`, the merged
state `PRE_first_tail_x15_r0_body.s995`, the canonical state `PRE_first_tail_x15_r0_body.s996`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl102 : PRE_first_tail_x15_r0_body.pl102.all (Nat.ble PRE_first_tail_x15_r0_body.s994.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd102 : nodupT PRE_first_tail_x15_r0_body.pl102 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1102 : Nat.ble PRE_first_tail_x15_r0_body.s994.next 2756466 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst102 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s994.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn102 : PRE_first_tail_x15_r0_body.s996.next = PRE_first_tail_x15_r0_body.s994.next + PRE_first_tail_x15_r0_body.pl102.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn102 : PRE_first_tail_x15_r0_body.s995.next = 2756466
kernel_rfl PRE_first_tail_x15_r0_body.zgrow102 : Nat.ble PRE_first_tail_x15_r0_body.s996.next PRE_first_tail_x15_r0_body.s995.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh102 : PRE_first_tail_x15_r0_body.S994.tab.all (fun e => PRE_first_tail_x15_r0_body.cws102.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd102 : nodupT PRE_first_tail_x15_r0_body.cws102 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi102 : PRE_first_tail_x15_r0_body.nr102.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S995.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt102 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s994.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg102_2665 : PRE_first_tail_x15_r0_body.s996.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s996 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk102_2665 : (objOf PRE_first_tail_x15_r0_body.s996 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm102_2665 : PRE_first_tail_x15_r0_body.s995.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa102.obj (objOf PRE_first_tail_x15_r0_body.s996 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s995 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg102_2673467 : PRE_first_tail_x15_r0_body.s996.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s996 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk102_2673467 : (objOf PRE_first_tail_x15_r0_body.s996 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm102_2673467 : PRE_first_tail_x15_r0_body.s995.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa102.obj (objOf PRE_first_tail_x15_r0_body.s996 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s995 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw102_4910 : (PRE_first_tail_x15_r0_body.s996.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw102_2673472 : (PRE_first_tail_x15_r0_body.s996.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw102_2673473 : (PRE_first_tail_x15_r0_body.s996.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd102 : PRE_first_tail_x15_r0_body.cl102.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr102 : PRE_first_tail_x15_r0_body.st102.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s994.next || PRE_first_tail_x15_r0_body.cl102.contains b) = true
def PRE_first_tail_x15_r0_body.zl102 : List Nat := PRE_first_tail_x15_r0_body.cl102.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE102 : PRE_first_tail_x15_r0_body.zl102.map (fun a => PRE_first_tail_x15_r0_body.s995.heap.get (PRE_first_tail_x15_r0_body.kappa102.a a)) = PRE_first_tail_x15_r0_body.zl102.map (fun a => (PRE_first_tail_x15_r0_body.s996.heap.get a).map PRE_first_tail_x15_r0_body.kappa102.hobj)
theorem PRE_first_tail_x15_r0_body.zimg102 : HeapImg PRE_first_tail_x15_r0_body.kappa102 PRE_first_tail_x15_r0_body.s996 PRE_first_tail_x15_r0_body.s995 PRE_first_tail_x15_r0_body.zl102 := PRE_first_tail_x15_r0_body.zimgE102
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl102 : PRE_first_tail_x15_r0_body.s995.ctl = PRE_first_tail_x15_r0_body.kappa102.ctl PRE_first_tail_x15_r0_body.s996.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack102 : PRE_first_tail_x15_r0_body.s995.stack = PRE_first_tail_x15_r0_body.s996.stack.map PRE_first_tail_x15_r0_body.kappa102.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs102 : PRE_first_tail_x15_r0_body.s995.jobs = PRE_first_tail_x15_r0_body.s996.jobs.map PRE_first_tail_x15_r0_body.kappa102.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores102 : PRE_first_tail_x15_r0_body.s995.stores = PRE_first_tail_x15_r0_body.kappa102.stores PRE_first_tail_x15_r0_body.s996.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots102 : checkRootsSupp PRE_first_tail_x15_r0_body.s996 4463 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC102 : PRE_first_tail_x15_r0_body.S994.tab.length + PRE_first_tail_x15_r0_body.cws102.length = 4463
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap102 : PRE_first_tail_x15_r0_body.kappa102 = Conv.Map.compact PRE_first_tail_x15_r0_body.s994.next 2756466 PRE_first_tail_x15_r0_body.S994.tab.length PRE_first_tail_x15_r0_body.pl102 (PRE_first_tail_x15_r0_body.nr102.map NumV.ref) PRE_first_tail_x15_r0_body.kd102.big
  PRE_first_tail_x15_r0_body.kd102.region PRE_first_tail_x15_r0_body.kd102.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin102 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s996.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc102 : Conv.jcleanListB (⟨20221, 17327, 2755317, 4463⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s996 PRE_first_tail_x15_r0_body.cl102 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB102 : noBigRootsP (fun i => !Conv.oldBigB (⟨20221, 17327, 2755317, 4463⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s996.trace PRE_first_tail_x15_r0_body.s996 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm102 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17300 = true
theorem PRE_first_tail_x15_r0_body.cjcl102 (h : Conv.JClean (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s994) : Conv.JClean (⟨20221, 17327, 2755317, 4463⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s996 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle102)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap102 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd102 a ha)) PRE_first_tail_x15_r0_body.zjc102

end Host.Load.Run.Tpl
end

section -- st102/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st102.bodyLast from PRE_first_tail_x15_r0_body.st102.s4 to PRE_first_tail_x15_r0_body.st102.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st102.F PRE_first_tail_x15_r0_body.st102.s4).run PRE_first_tail_x15_r0_body.st102.S4 = some (PRE_first_tail_x15_r0_body.st102.s5, PRE_first_tail_x15_r0_body.st102.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st102.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st102.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st102.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st102.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st102/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st102.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st102.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st102.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st102.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st102.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st102.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st102.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st102.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st102.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st102.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st102.s0 PRE_first_tail_x15_r0_body.st102.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st102.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st102.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st102.s4 PRE_first_tail_x15_r0_body.st102.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st102/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st102.bodyK0F from PRE_first_tail_x15_r0_body.st102.s0 to PRE_first_tail_x15_r0_body.st102.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st102.F (PRE_first_tail_x15_r0_body.st102.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st102.ks 0).getD 0) PRE_first_tail_x15_r0_body.st102.s0 PRE_first_tail_x15_r0_body.st102.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st102.s1, PRE_first_tail_x15_r0_body.st102.S1)
theorem PRE_first_tail_x15_r0_body.st102.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st102.F (PRE_first_tail_x15_r0_body.st102.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st102.ks 0).getD 0) PRE_first_tail_x15_r0_body.st102.s0 PRE_first_tail_x15_r0_body.st102.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st102.s1, PRE_first_tail_x15_r0_body.st102.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st102.bodyOkLN_ok PRE_first_tail_x15_r0_body.st102.bodyK0F
end Host.Load.Run.Tpl
end

section -- st102/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st102.bodyK1F from PRE_first_tail_x15_r0_body.st102.s1 to PRE_first_tail_x15_r0_body.st102.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st102.F (PRE_first_tail_x15_r0_body.st102.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st102.ks 1).getD 0) PRE_first_tail_x15_r0_body.st102.s1 PRE_first_tail_x15_r0_body.st102.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st102.s2, PRE_first_tail_x15_r0_body.st102.S2)
theorem PRE_first_tail_x15_r0_body.st102.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st102.F (PRE_first_tail_x15_r0_body.st102.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st102.ks 1).getD 0) PRE_first_tail_x15_r0_body.st102.s1 PRE_first_tail_x15_r0_body.st102.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st102.s2, PRE_first_tail_x15_r0_body.st102.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st102.bodyOkLN_ok PRE_first_tail_x15_r0_body.st102.bodyK1F
end Host.Load.Run.Tpl
end

section -- st102/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st102.bodyK2F from PRE_first_tail_x15_r0_body.st102.s2 to PRE_first_tail_x15_r0_body.st102.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st102.F (PRE_first_tail_x15_r0_body.st102.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st102.ks 2).getD 0) PRE_first_tail_x15_r0_body.st102.s2 PRE_first_tail_x15_r0_body.st102.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st102.s3, PRE_first_tail_x15_r0_body.st102.S3)
theorem PRE_first_tail_x15_r0_body.st102.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st102.F (PRE_first_tail_x15_r0_body.st102.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st102.ks 2).getD 0) PRE_first_tail_x15_r0_body.st102.s2 PRE_first_tail_x15_r0_body.st102.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st102.s3, PRE_first_tail_x15_r0_body.st102.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st102.bodyOkLN_ok PRE_first_tail_x15_r0_body.st102.bodyK2F
end Host.Load.Run.Tpl
end

section -- st102/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st102.bodyK3F from PRE_first_tail_x15_r0_body.st102.s3 to PRE_first_tail_x15_r0_body.st102.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st102.F (PRE_first_tail_x15_r0_body.st102.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st102.ks 3).getD 0) PRE_first_tail_x15_r0_body.st102.s3 PRE_first_tail_x15_r0_body.st102.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st102.s4, PRE_first_tail_x15_r0_body.st102.S4)
theorem PRE_first_tail_x15_r0_body.st102.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st102.F (PRE_first_tail_x15_r0_body.st102.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st102.ks 3).getD 0) PRE_first_tail_x15_r0_body.st102.s3 PRE_first_tail_x15_r0_body.st102.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st102.s4, PRE_first_tail_x15_r0_body.st102.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st102.bodyOkLN_ok PRE_first_tail_x15_r0_body.st102.bodyK3F
end Host.Load.Run.Tpl
end

section -- st102/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st102.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st102.F (PRE_first_tail_x15_r0_body.st102.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st102.s0 PRE_first_tail_x15_r0_body.st102.S0 = some (PRE_first_tail_x15_r0_body.st102.s4, PRE_first_tail_x15_r0_body.st102.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st102.F (PRE_first_tail_x15_r0_body.st102.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st102.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st102.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st102.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st102.ks 3).getD 0) PRE_first_tail_x15_r0_body.st102.s0 PRE_first_tail_x15_r0_body.st102.s3 PRE_first_tail_x15_r0_body.st102.s4 PRE_first_tail_x15_r0_body.st102.S0 PRE_first_tail_x15_r0_body.st102.S3 PRE_first_tail_x15_r0_body.st102.S4 (runOk_trans PRE_first_tail_x15_r0_body.st102.F (PRE_first_tail_x15_r0_body.st102.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st102.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st102.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st102.ks 2).getD 0) PRE_first_tail_x15_r0_body.st102.s0 PRE_first_tail_x15_r0_body.st102.s2 PRE_first_tail_x15_r0_body.st102.s3 PRE_first_tail_x15_r0_body.st102.S0 PRE_first_tail_x15_r0_body.st102.S2 PRE_first_tail_x15_r0_body.st102.S3 (runOk_trans PRE_first_tail_x15_r0_body.st102.F (PRE_first_tail_x15_r0_body.st102.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st102.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st102.ks 1).getD 0) PRE_first_tail_x15_r0_body.st102.s0 PRE_first_tail_x15_r0_body.st102.s1 PRE_first_tail_x15_r0_body.st102.s2 PRE_first_tail_x15_r0_body.st102.S0 PRE_first_tail_x15_r0_body.st102.S1 PRE_first_tail_x15_r0_body.st102.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st102.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st102.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st102.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st102.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st102.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st102.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st102.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st102.F (PRE_first_tail_x15_r0_body.st102.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st102.s0
  S0 := PRE_first_tail_x15_r0_body.st102.S0
  s1 := PRE_first_tail_x15_r0_body.st102.s4
  S1 := PRE_first_tail_x15_r0_body.st102.S4
  s2 := PRE_first_tail_x15_r0_body.st102.s5
  S2 := PRE_first_tail_x15_r0_body.st102.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st102.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st102.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st102.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st102.bodyHalt
  last := PRE_first_tail_x15_r0_body.st102.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st102.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC103
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 103 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1004` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa103` into the merged state
`PRE_first_tail_x15_r0_body.s1003`. -/

def PRE_first_tail_x15_r0_body.pl103 : List Nat := []
def PRE_first_tail_x15_r0_body.nr103 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd103 : RData :=
  ⟨2755807, 2755809, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20234, 20234, 17340, 17340, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa103 : Map :=
  Conv.Map.compact 2755807 2755809 4484 PRE_first_tail_x15_r0_body.pl103 (PRE_first_tail_x15_r0_body.nr103.map NumV.ref) PRE_first_tail_x15_r0_body.kd103.big
    PRE_first_tail_x15_r0_body.kd103.region PRE_first_tail_x15_r0_body.kd103.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws103 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs103 : List SymE := PRE_first_tail_x15_r0_body.nr103.map fun r => (nth? PRE_first_tail_x15_r0_body.S1003.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta103 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws103 PRE_first_tail_x15_r0_body.crs103
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB103 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab103 : PRE_first_tail_x15_r0_body.S1004.tab = PRE_first_tail_x15_r0_body.S1002.tab ++ PRE_first_tail_x15_r0_body.cws103.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace103 : PRE_first_tail_x15_r0_body.s1004.trace = PRE_first_tail_x15_r0_body.s1002.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext103 : PRE_first_tail_x15_r0_body.s1004.next = 2755807
kernel_rfl PRE_first_tail_x15_r0_body.ccounters103 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.nnext) = (20234, 17340)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue103 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1003.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa103.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp103 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.tokens.all (bSN 4484) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean103 : Conv.cleanListB 20234 131072 (fun r => Nat.ble 80936 r) PRE_first_tail_x15_r0_body.s1004
    (PRE_first_tail_x15_r0_body.wrB103 ++ (List.range 0).map (2755807 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs103 : bigsOutB 20234 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK103
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl103`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl103 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo103 : List Nat := []
def PRE_first_tail_x15_r0_body.cln103 : List Nat := []
def PRE_first_tail_x15_r0_body.cli103 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap103 : PRE_first_tail_x15_r0_body.s1004.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1002.heap (PRE_first_tail_x15_r0_body.cl103.filterMap fun a => (PRE_first_tail_x15_r0_body.s1004.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe103 : Nat.ble PRE_first_tail_x15_r0_body.s1002.next PRE_first_tail_x15_r0_body.s1004.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP103 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1002 PRE_first_tail_x15_r0_body.s1004 PRE_first_tail_x15_r0_body.cl103 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp103 : Conv.suppListB PRE_first_tail_x15_r0_body.s1004 4484 PRE_first_tail_x15_r0_body.cl103 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound103 : Conv.boundListB PRE_first_tail_x15_r0_body.s1004 PRE_first_tail_x15_r0_body.cl103 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK103 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln103.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK103 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo103.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK103 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli103.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst103 : Conv.sstListB 4484 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx PRE_first_tail_x15_r0_body.cln103 PRE_first_tail_x15_r0_body.clo103 PRE_first_tail_x15_r0_body.cli103 = true

end Host.Load.Run.Tpl
end

section -- SiteCl103
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA103 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo103.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd103 : (PRE_first_tail_x15_r0_body.clo103 ++ PRE_first_tail_x15_r0_body.cln103 ++ PRE_first_tail_x15_r0_body.cli103).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle103 : Conv.Cnt.leB (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck103 : Conv.ncleanListB (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx PRE_first_tail_x15_r0_body.clo103 PRE_first_tail_x15_r0_body.cln103 PRE_first_tail_x15_r0_body.cli103 = true
theorem PRE_first_tail_x15_r0_body.cncl103 (h : Conv.NClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx) : Conv.NClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle103 PRE_first_tail_x15_r0_body.ckA103 PRE_first_tail_x15_r0_body.cobjsK103 PRE_first_tail_x15_r0_body.cnodesK103 PRE_first_tail_x15_r0_body.citemsK103 PRE_first_tail_x15_r0_body.cbd103 PRE_first_tail_x15_r0_body.cck103

end Host.Load.Run.Tpl
end

section -- SiteS103
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 103 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc103 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P103 : LoadP := PRE_first_tail_x15_r0_body.Pc103.raise 17340
kernel_rfl PRE_first_tail_x15_r0_body.craise103 : Nat.ble PRE_first_tail_x15_r0_body.Pc103.N0 17340 = true
theorem PRE_first_tail_x15_r0_body.raised103 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc103 PRE_first_tail_x15_r0_body.P103 :=
  .inr ⟨17340, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise103, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_103 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_103 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1003.ffi)
def PRE_first_tail_x15_r0_body.khinv103 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv103 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS103 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS103 : List Nat := List.range' 17340 0
def PRE_first_tail_x15_r0_body.ciS103 : List Nat := [] ++ List.range' 17340 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0103 : PRE_first_tail_x15_r0_body.kd103.nh0 = PRE_first_tail_x15_r0_body.cx0_103.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1103 : PRE_first_tail_x15_r0_body.kd103.nh1 = PRE_first_tail_x15_r0_body.cx1_103.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0103 : PRE_first_tail_x15_r0_body.kd103.nn0 = PRE_first_tail_x15_r0_body.cx0_103.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1103 : PRE_first_tail_x15_r0_body.kd103.nn1 = PRE_first_tail_x15_r0_body.cx1_103.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo103 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P103.lo && Nat.ble PRE_first_tail_x15_r0_body.P103.lo PRE_first_tail_x15_r0_body.cx0_103.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P103.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P103.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt103 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_103.mlx.next PRE_first_tail_x15_r0_body.cx1_103.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_103.mlx.nnext PRE_first_tail_x15_r0_body.cx1_103.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband103 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P103.NL && Nat.ble PRE_first_tail_x15_r0_body.P103.NL PRE_first_tail_x15_r0_body.P103.N0 && Nat.ble PRE_first_tail_x15_r0_body.P103.N0 PRE_first_tail_x15_r0_body.cx0_103.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow103 : PRE_first_tail_x15_r0_body.kd103.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren103 : checkRenG PRE_first_tail_x15_r0_body.kd103.hnd PRE_first_tail_x15_r0_body.khinv103 (phB PRE_first_tail_x15_r0_body.cx0_103.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband103 : PRE_first_tail_x15_r0_body.kd103.checkBand PRE_first_tail_x15_r0_body.P103.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos103 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd103.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren103 : checkRenG PRE_first_tail_x15_r0_body.kd103.node PRE_first_tail_x15_r0_body.kninv103 (pnB PRE_first_tail_x15_r0_body.cx0_103.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P103.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd103.nodeF j) PRE_first_tail_x15_r0_body.cx1_103.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a103 : PRE_first_tail_x15_r0_body.cx0_103.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b103 : PRE_first_tail_x15_r0_body.cx0_103.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.pending = PRE_first_tail_x15_r0_body.cx0_103.mlx.pending.map PRE_first_tail_x15_r0_body.kappa103.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.errh = PRE_first_tail_x15_r0_body.cx0_103.mlx.errh.map PRE_first_tail_x15_r0_body.kappa103.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.files = PRE_first_tail_x15_r0_body.cx0_103.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.arch = PRE_first_tail_x15_r0_body.cx0_103.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_103.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.wired = PRE_first_tail_x15_r0_body.cx0_103.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost103 : PRE_first_tail_x15_r0_body.cx1_103.host = PRE_first_tail_x15_r0_body.cx0_103.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd103`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0103 : PRE_first_tail_x15_r0_body.kd103.n0 = 2755807
kernel_rfl PRE_first_tail_x15_r0_body.ckn1103 : PRE_first_tail_x15_r0_body.kd103.n1 = 2755809
kernel_rfl PRE_first_tail_x15_r0_body.ckheap103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.heap).all (fun x => Nat.ble 2755807 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl103 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd103.heap.get (2755807 + j) = nth? PRE_first_tail_x15_r0_body.pl103 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja103 : Nat.ble 2755807 2755807 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn103 : Nat.ble 4484 4484 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD103 : Nat.ble 2755807 PRE_first_tail_x15_r0_body.kd103.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn103 : Nat.ble 20234 PRE_first_tail_x15_r0_body.kd103.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn103 : Nat.ble 17340 PRE_first_tail_x15_r0_body.kd103.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb103 : Nat.ble 20234 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.heap).all (Nat.ble (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.hnd).all (Nat.ble (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.node).all (Nat.ble (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix103 : Conv.FixOld (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa103 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja103) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn103) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD103) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn103) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn103) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb103) PRE_first_tail_x15_r0_body.fheap103 PRE_first_tail_x15_r0_body.fhnd103 PRE_first_tail_x15_r0_body.fnode103
kernel_rfl PRE_first_tail_x15_r0_body.fcxn103 : (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn103 : (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0103 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_103.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_103.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS103.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_103.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS103.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_103.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS103.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_103.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS103.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_103.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd103 : (PRE_first_tail_x15_r0_body.clo103 ++ PRE_first_tail_x15_r0_body.cln103 ++ PRE_first_tail_x15_r0_body.cli103 ++ PRE_first_tail_x15_r0_body.cwS103 ++ PRE_first_tail_x15_r0_body.cnS103 ++ PRE_first_tail_x15_r0_body.ciS103).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW103 : PRE_first_tail_x15_r0_body.cwS103.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo103.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI103 : PRE_first_tail_x15_r0_body.ciS103.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli103.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN103 : PRE_first_tail_x15_r0_body.cnS103.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF103 : PRE_first_tail_x15_r0_body.cln103.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh103 : PRE_first_tail_x15_r0_body.clo103.all (handleOK PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.P103.lo PRE_first_tail_x15_r0_body.cx0_103.mlx PRE_first_tail_x15_r0_body.cx1_103.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo103 : PRE_first_tail_x15_r0_body.clo103.map (fun h => PRE_first_tail_x15_r0_body.cx1_103.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa103.handle h)) = PRE_first_tail_x15_r0_body.clo103.map (fun h => (PRE_first_tail_x15_r0_body.cx0_103.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa103.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok103 : PRE_first_tail_x15_r0_body.clo103.all (objOK PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.P103.NL PRE_first_tail_x15_r0_body.cx0_103.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd103 : PRE_first_tail_x15_r0_body.cln103.all (nodeOKF PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.P103 PRE_first_tail_x15_r0_body.cx0_103.mlx PRE_first_tail_x15_r0_body.cx1_103.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp103 : ((PRE_first_tail_x15_r0_body.cln103.filter (fullB PRE_first_tail_x15_r0_body.P103))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_103.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa103.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln103.filter (fullB PRE_first_tail_x15_r0_body.P103))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_103.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa103.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI103 : incrB PRE_first_tail_x15_r0_body.kd103.nodeF (List.range' 17340 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.node).all (fun k => Nat.ble 17340 k && Nat.blt k 17340) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL103 : (PRE_first_tail_x15_r0_body.cln103.filter (Nat.ble PRE_first_tail_x15_r0_body.P103.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd103.nodeF i) && (Nat.blt i 17340 || Nat.ble PRE_first_tail_x15_r0_body.kd103.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord103 : (PRE_first_tail_x15_r0_body.cln103.filter (Nat.ble PRE_first_tail_x15_r0_body.P103.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd103.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd103.nodeF j) (PRE_first_tail_x15_r0_body.kd103.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow103 PRE_first_tail_x15_r0_body.cnn1103 PRE_first_tail_x15_r0_body.fnordI103 PRE_first_tail_x15_r0_body.fnordK103 PRE_first_tail_x15_r0_body.fnordL103
kernel_rfl PRE_first_tail_x15_r0_body.fi103 : PRE_first_tail_x15_r0_body.cli103.all (pnB PRE_first_tail_x15_r0_body.cx0_103.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii103 : PRE_first_tail_x15_r0_body.cli103.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_103.mlx.items.get (PRE_first_tail_x15_r0_body.kappa103.node k) = (PRE_first_tail_x15_r0_body.cx0_103.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa103.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot103 (clean : Conv.NClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P103.NL) (cl : SSt (· < 4484) PRE_first_tail_x15_r0_body.cx0_103.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P103 4484 PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.kd103 PRE_first_tail_x15_r0_body.khinv103 PRE_first_tail_x15_r0_body.kninv103 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx PRE_first_tail_x15_r0_body.cx0_103.mlx PRE_first_tail_x15_r0_body.cx1_103.mlx (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo103 PRE_first_tail_x15_r0_body.cln103 PRE_first_tail_x15_r0_body.cli103 PRE_first_tail_x15_r0_body.cwS103 PRE_first_tail_x15_r0_body.cnS103 PRE_first_tail_x15_r0_body.ciS103 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0103, PRE_first_tail_x15_r0_body.cnh1103, PRE_first_tail_x15_r0_body.cnn0103, PRE_first_tail_x15_r0_body.cnn1103, PRE_first_tail_x15_r0_body.cplo103, PRE_first_tail_x15_r0_body.ccnt103, PRE_first_tail_x15_r0_body.cnband103, PRE_first_tail_x15_r0_body.chbelow103, PRE_first_tail_x15_r0_body.chren103, PRE_first_tail_x15_r0_body.cband103, PRE_first_tail_x15_r0_body.cnh1pos103, PRE_first_tail_x15_r0_body.cnren103, PRE_first_tail_x15_r0_body.cnlow103, PRE_first_tail_x15_r0_body.cabs0a103, PRE_first_tail_x15_r0_body.cabs0b103, PRE_first_tail_x15_r0_body.ctok1103, PRE_first_tail_x15_r0_body.cpend103, PRE_first_tail_x15_r0_body.cerrh103, PRE_first_tail_x15_r0_body.cfiles103, PRE_first_tail_x15_r0_body.carch103, PRE_first_tail_x15_r0_body.csizes103, PRE_first_tail_x15_r0_body.cwired103, PRE_first_tail_x15_r0_body.cfix103, clean, PRE_first_tail_x15_r0_body.fcxn103, PRE_first_tail_x15_r0_body.fcnn103, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0103, PRE_first_tail_x15_r0_body.fnk103, PRE_first_tail_x15_r0_body.ckA103, PRE_first_tail_x15_r0_body.cobjsK103, PRE_first_tail_x15_r0_body.cnodesK103, PRE_first_tail_x15_r0_body.citemsK103, PRE_first_tail_x15_r0_body.f1A103, PRE_first_tail_x15_r0_body.f1O103, PRE_first_tail_x15_r0_body.f1N103, PRE_first_tail_x15_r0_body.f1I103, PRE_first_tail_x15_r0_body.fbd103, PRE_first_tail_x15_r0_body.fincW103, PRE_first_tail_x15_r0_body.fincI103, PRE_first_tail_x15_r0_body.fincN103, PRE_first_tail_x15_r0_body.flnF103, PRE_first_tail_x15_r0_body.fh103, PRE_first_tail_x15_r0_body.fo103, PRE_first_tail_x15_r0_body.fok103, PRE_first_tail_x15_r0_body.fnd103, PRE_first_tail_x15_r0_body.fp103, PRE_first_tail_x15_r0_body.fnord103, PRE_first_tail_x15_r0_body.fi103, PRE_first_tail_x15_r0_body.fii103⟩
theorem PRE_first_tail_x15_r0_body.cnshift103 (clean : Conv.NClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P103.NL) (cl : SSt (· < 4484) PRE_first_tail_x15_r0_body.cx0_103.mlx) : NShift PRE_first_tail_x15_r0_body.P103 4484 PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.cx0_103 PRE_first_tail_x15_r0_body.cx1_103 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot103 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost103 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0103 PRE_first_tail_x15_r0_body.ckn1103 PRE_first_tail_x15_r0_body.ckheap103 PRE_first_tail_x15_r0_body.ckpl103)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_103 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1002.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_103 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1002.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_103 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1002.ffi) = some PRE_first_tail_x15_r0_body.fxC_103
kernel_rfl PRE_first_tail_x15_r0_body.okrC_103 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1002.ffi) = some PRE_first_tail_x15_r0_body.krC_103
noncomputable def PRE_first_tail_x15_r0_body.fx0_103 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1004.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_103 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1004.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_103 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1004.ffi) = some PRE_first_tail_x15_r0_body.fx0_103
kernel_rfl PRE_first_tail_x15_r0_body.okr0_103 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1004.ffi) = some PRE_first_tail_x15_r0_body.kr0_103
noncomputable def PRE_first_tail_x15_r0_body.fx1_103 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1003.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_103 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1003.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_103 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1003.ffi) = some PRE_first_tail_x15_r0_body.fx1_103
kernel_rfl PRE_first_tail_x15_r0_body.okr1_103 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1003.ffi) = some PRE_first_tail_x15_r0_body.kr1_103
kernel_rfl PRE_first_tail_x15_r0_body.ff0103 : PRE_first_tail_x15_r0_body.fx0_103 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_103 (PRE_first_tail_x15_r0_body.clo103.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_103.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1103 : PRE_first_tail_x15_r0_body.fx1_103 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_103 (PRE_first_tail_x15_r0_body.cwS103.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_103.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck103 : freedLB PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.cx0_103.mlx PRE_first_tail_x15_r0_body.fx0_103 PRE_first_tail_x15_r0_body.fx1_103 PRE_first_tail_x15_r0_body.clo103 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0103 : PRE_first_tail_x15_r0_body.kr0_103.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_103.flags (PRE_first_tail_x15_r0_body.clo103.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_103.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0103 : PRE_first_tail_x15_r0_body.kr0_103.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_103.targs (PRE_first_tail_x15_r0_body.clo103.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_103.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1103 : PRE_first_tail_x15_r0_body.kr1_103.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_103.flags (PRE_first_tail_x15_r0_body.cwS103.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_103.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1103 : PRE_first_tail_x15_r0_body.kr1_103.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_103.targs (PRE_first_tail_x15_r0_body.cwS103.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_103.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck103 : krecLB PRE_first_tail_x15_r0_body.kappa103 4484 PRE_first_tail_x15_r0_body.cx0_103.mlx PRE_first_tail_x15_r0_body.kr0_103 PRE_first_tail_x15_r0_body.kr1_103 PRE_first_tail_x15_r0_body.clo103 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn103 : Nat.ble 4484 4484 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge103 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1003.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1004.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR103 : pendRegB PRE_first_tail_x15_r0_body.kappa103 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe103 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1003.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift103 (clean : Conv.NClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P103.NL) (cl : SSt (· < 4484) PRE_first_tail_x15_r0_body.cx0_103.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_103.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_103.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_103.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_103.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P103 4484 PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.s1004.ffi PRE_first_tail_x15_r0_body.s1003.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift103 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue103, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp103 t ht),
    PRE_first_tail_x15_r0_body.cbridge103,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1004.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1003.ffi) (PRE_first_tail_x15_r0_body.cfoot103 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_103 PRE_first_tail_x15_r0_body.ofx1_103 hobjC PRE_first_tail_x15_r0_body.ff0103 PRE_first_tail_x15_r0_body.ff1103 PRE_first_tail_x15_r0_body.ffck103,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1004.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1003.ffi) (PRE_first_tail_x15_r0_body.cfoot103 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_103 PRE_first_tail_x15_r0_body.okr1_103 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn103) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0103 PRE_first_tail_x15_r0_body.fkt0103 PRE_first_tail_x15_r0_body.fkf1103 PRE_first_tail_x15_r0_body.fkt1103 PRE_first_tail_x15_r0_body.fkck103,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0103 PRE_first_tail_x15_r0_body.cnh1103 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe103) PRE_first_tail_x15_r0_body.cpendR103⟩

end Host.Load.Run.Tpl
end

section -- st103/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st103 0
host_stream_state PRE_first_tail_x15_r0_body.st103 1
host_stream_state PRE_first_tail_x15_r0_body.st103 2
end Host.Load.Run.Tpl
end

section -- Site103
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 103 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g103__g104` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1002`, the merged state `PRE_first_tail_x15_r0_body.s1003`,
the site template `PRE_first_tail_x15_r0_body.st103` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1004`: the merge.
The footprint's facts are in `SiteF103`, the compaction's in `SiteC103`, `SiteK103`, `SiteNa103`, `SiteNb103`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso103 : PRE_first_tail_x15_r0_body.st103.s0 = { PRE_first_tail_x15_r0_body.s1002 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs103 : List Frame := PRE_first_tail_x15_r0_body.s1002.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_103 : PRE_first_tail_x15_r0_body.S1002.tab.length = 4484
kernel_rfl PRE_first_tail_x15_r0_body.tab0_103 : PRE_first_tail_x15_r0_body.st103.S0.tab = PRE_first_tail_x15_r0_body.S1002.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws103 : List Nat := [2767, 2768]
kernel_rfl PRE_first_tail_x15_r0_body.fresh103 : (PRE_first_tail_x15_r0_body.S1002.tab.all fun e => PRE_first_tail_x15_r0_body.ws103.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1002.oracle.all fun q => PRE_first_tail_x15_r0_body.ws103.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab103 : PRE_first_tail_x15_r0_body.S1003.tab = PRE_first_tail_x15_r0_body.S1002.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws103
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen103 : PRE_first_tail_x15_r0_body.st103.S2.tab.length - PRE_first_tail_x15_r0_body.st103.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged103`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap103 : PRE_first_tail_x15_r0_body.s1003.heap = PRE_first_tail_x15_r0_body.st103.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext103 : PRE_first_tail_x15_r0_body.s1003.next = PRE_first_tail_x15_r0_body.st103.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl103 : PRE_first_tail_x15_r0_body.s1003.ctl = PRE_first_tail_x15_r0_body.st103.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack103 : PRE_first_tail_x15_r0_body.s1003.stack = PRE_first_tail_x15_r0_body.st103.s2.stack ++ PRE_first_tail_x15_r0_body.s1002.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs103 : PRE_first_tail_x15_r0_body.s1003.jobs = PRE_first_tail_x15_r0_body.st103.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi103 : PRE_first_tail_x15_r0_body.s1003.ffi = PRE_first_tail_x15_r0_body.st103.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace103 : PRE_first_tail_x15_r0_body.s1003.trace = PRE_first_tail_x15_r0_body.st103.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores103 : PRE_first_tail_x15_r0_body.s1003.stores = PRE_first_tail_x15_r0_body.st103.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD103
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 103 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived103 : PRE_first_tail_x15_r0_body.nr103.map (fun r => nth? PRE_first_tail_x15_r0_body.st103.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo103 : PRE_first_tail_x15_r0_body.nr103.all (Nat.ble 4484) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj103 : PRE_first_tail_x15_r0_body.cws103.all (fun c => !PRE_first_tail_x15_r0_body.ws103.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ103 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws103 PRE_first_tail_x15_r0_body.crs103 PRE_first_tail_x15_r0_body.ws103

end Host.Load.Run.Tpl
end

section -- st103/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st103`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st103.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st103.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st103.s2.heap PRE_first_tail_x15_r0_body.st103.wrR ++ freshOf PRE_first_tail_x15_r0_body.st103.s2.heap PRE_first_tail_x15_r0_body.st103.s0.next PRE_first_tail_x15_r0_body.st103.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st103.wr : List Nat := PRE_first_tail_x15_r0_body.st103.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st103.heapFoot : PRE_first_tail_x15_r0_body.st103.s2.heap = setAll PRE_first_tail_x15_r0_body.st103.s0.heap PRE_first_tail_x15_r0_body.st103.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st103.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st103.s0.next PRE_first_tail_x15_r0_body.st103.s2.next = true
theorem PRE_first_tail_x15_r0_body.st103.grows : PRE_first_tail_x15_r0_body.st103.s0.next ≤ PRE_first_tail_x15_r0_body.st103.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st103.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st103.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st103.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st103.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st103.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st103.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st103.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st103.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st103.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st103.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st103.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st103.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF103
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 103 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB103 : nodupT PRE_first_tail_x15_r0_body.st103.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup103 : PRE_first_tail_x15_r0_body.st103.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB103).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB103 : PRE_first_tail_x15_r0_body.st103.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound103 : ∀ b ∈ PRE_first_tail_x15_r0_body.st103.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB103 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr103 := PRE_first_tail_x15_r0_body.st103.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq103 : PRE_first_tail_x15_r0_body.st103.s2.trace = PRE_first_tail_x15_r0_body.trFr103 ++ PRE_first_tail_x15_r0_body.st103.s0.trace
theorem PRE_first_tail_x15_r0_body.trace103 : ∃ fr, PRE_first_tail_x15_r0_body.st103.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st103.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq103⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide103 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB103 : (PRE_first_tail_x15_r0_body.wide103.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st103.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix103 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide103, WFix Map.id (Present PRE_first_tail_x15_r0_body.st103.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB103 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL103
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 103 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1003`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO103 : PRE_first_tail_x15_r0_body.st103.S0.oracle = PRE_first_tail_x15_r0_body.st103.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B103 : PRE_first_tail_x15_r0_body.st103.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st103.s0.next || (PRE_first_tail_x15_r0_body.st103.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot103 : Conv.StageFoot PRE_first_tail_x15_r0_body.st103.wr PRE_first_tail_x15_r0_body.st103.s0 PRE_first_tail_x15_r0_body.st103.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st103.heapFoot PRE_first_tail_x15_r0_body.wrNodup103 PRE_first_tail_x15_r0_body.wrBound103 PRE_first_tail_x15_r0_body.wr0B103 PRE_first_tail_x15_r0_body.st103.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged103 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st103.F.S → PRE_first_tail_x15_r0_body.st103.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st103.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st103.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs103 PRE_first_tail_x15_r0_body.st103.wr PRE_first_tail_x15_r0_body.s1002 PRE_first_tail_x15_r0_body.st103.s2 PRE_first_tail_x15_r0_body.st103.s0
      PRE_first_tail_x15_r0_body.st103.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st103.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1003 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso103 PRE_first_tail_x15_r0_body.stFoot103 PRE_first_tail_x15_r0_body.wrNodup103 PRE_first_tail_x15_r0_body.wrBound103 PRE_first_tail_x15_r0_body.trace103 PRE_first_tail_x15_r0_body.mheap103
    PRE_first_tail_x15_r0_body.mnext103 PRE_first_tail_x15_r0_body.mctl103 PRE_first_tail_x15_r0_body.mstack103 PRE_first_tail_x15_r0_body.mjobs103 PRE_first_tail_x15_r0_body.mffi103 PRE_first_tail_x15_r0_body.mtrace103 PRE_first_tail_x15_r0_body.mstores103 h

def PRE_first_tail_x15_r0_body.arrEl103_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE103_2665 : arrOf PRE_first_tail_x15_r0_body.s1003 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl103_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA103_2665 : isArrB PRE_first_tail_x15_r0_body.s1003 2665 = true
theorem PRE_first_tail_x15_r0_body.arr103_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1003.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl103_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE103_2665 PRE_first_tail_x15_r0_body.arrA103_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN103_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl103_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR103_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl103_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN103_2665

def PRE_first_tail_x15_r0_body.arrEl103_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE103_2673467 : arrOf PRE_first_tail_x15_r0_body.s1003 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl103_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA103_2673467 : isArrB PRE_first_tail_x15_r0_body.s1003 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr103_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1003.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl103_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE103_2673467 PRE_first_tail_x15_r0_body.arrA103_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN103_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl103_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR103_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl103_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN103_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k103 : isArrB PRE_first_tail_x15_r0_body.s1003 4910 = false
theorem PRE_first_tail_x15_r0_body.keep103 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1003 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k103 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr103_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl103_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ103
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 103 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1002`, the merged
state `PRE_first_tail_x15_r0_body.s1003`, the canonical state `PRE_first_tail_x15_r0_body.s1004`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl103 : PRE_first_tail_x15_r0_body.pl103.all (Nat.ble PRE_first_tail_x15_r0_body.s1002.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd103 : nodupT PRE_first_tail_x15_r0_body.pl103 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1103 : Nat.ble PRE_first_tail_x15_r0_body.s1002.next 2755809 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst103 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1002.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn103 : PRE_first_tail_x15_r0_body.s1004.next = PRE_first_tail_x15_r0_body.s1002.next + PRE_first_tail_x15_r0_body.pl103.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn103 : PRE_first_tail_x15_r0_body.s1003.next = 2755809
kernel_rfl PRE_first_tail_x15_r0_body.zgrow103 : Nat.ble PRE_first_tail_x15_r0_body.s1004.next PRE_first_tail_x15_r0_body.s1003.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh103 : PRE_first_tail_x15_r0_body.S1002.tab.all (fun e => PRE_first_tail_x15_r0_body.cws103.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd103 : nodupT PRE_first_tail_x15_r0_body.cws103 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi103 : PRE_first_tail_x15_r0_body.nr103.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1003.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt103 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1002.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg103_2665 : PRE_first_tail_x15_r0_body.s1004.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1004 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk103_2665 : (objOf PRE_first_tail_x15_r0_body.s1004 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm103_2665 : PRE_first_tail_x15_r0_body.s1003.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa103.obj (objOf PRE_first_tail_x15_r0_body.s1004 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1003 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg103_2673467 : PRE_first_tail_x15_r0_body.s1004.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1004 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk103_2673467 : (objOf PRE_first_tail_x15_r0_body.s1004 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm103_2673467 : PRE_first_tail_x15_r0_body.s1003.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa103.obj (objOf PRE_first_tail_x15_r0_body.s1004 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1003 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw103_4910 : (PRE_first_tail_x15_r0_body.s1004.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw103_2673472 : (PRE_first_tail_x15_r0_body.s1004.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw103_2673473 : (PRE_first_tail_x15_r0_body.s1004.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd103 : PRE_first_tail_x15_r0_body.cl103.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr103 : PRE_first_tail_x15_r0_body.st103.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1002.next || PRE_first_tail_x15_r0_body.cl103.contains b) = true
def PRE_first_tail_x15_r0_body.zl103 : List Nat := PRE_first_tail_x15_r0_body.cl103.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE103 : PRE_first_tail_x15_r0_body.zl103.map (fun a => PRE_first_tail_x15_r0_body.s1003.heap.get (PRE_first_tail_x15_r0_body.kappa103.a a)) = PRE_first_tail_x15_r0_body.zl103.map (fun a => (PRE_first_tail_x15_r0_body.s1004.heap.get a).map PRE_first_tail_x15_r0_body.kappa103.hobj)
theorem PRE_first_tail_x15_r0_body.zimg103 : HeapImg PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.s1004 PRE_first_tail_x15_r0_body.s1003 PRE_first_tail_x15_r0_body.zl103 := PRE_first_tail_x15_r0_body.zimgE103
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl103 : PRE_first_tail_x15_r0_body.s1003.ctl = PRE_first_tail_x15_r0_body.kappa103.ctl PRE_first_tail_x15_r0_body.s1004.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack103 : PRE_first_tail_x15_r0_body.s1003.stack = PRE_first_tail_x15_r0_body.s1004.stack.map PRE_first_tail_x15_r0_body.kappa103.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs103 : PRE_first_tail_x15_r0_body.s1003.jobs = PRE_first_tail_x15_r0_body.s1004.jobs.map PRE_first_tail_x15_r0_body.kappa103.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores103 : PRE_first_tail_x15_r0_body.s1003.stores = PRE_first_tail_x15_r0_body.kappa103.stores PRE_first_tail_x15_r0_body.s1004.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots103 : checkRootsSupp PRE_first_tail_x15_r0_body.s1004 4484 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC103 : PRE_first_tail_x15_r0_body.S1002.tab.length + PRE_first_tail_x15_r0_body.cws103.length = 4484
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap103 : PRE_first_tail_x15_r0_body.kappa103 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1002.next 2755809 PRE_first_tail_x15_r0_body.S1002.tab.length PRE_first_tail_x15_r0_body.pl103 (PRE_first_tail_x15_r0_body.nr103.map NumV.ref) PRE_first_tail_x15_r0_body.kd103.big
  PRE_first_tail_x15_r0_body.kd103.region PRE_first_tail_x15_r0_body.kd103.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin103 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1004.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc103 : Conv.jcleanListB (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1004 PRE_first_tail_x15_r0_body.cl103 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB103 : noBigRootsP (fun i => !Conv.oldBigB (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1004.trace PRE_first_tail_x15_r0_body.s1004 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm103 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17340 = true
theorem PRE_first_tail_x15_r0_body.cjcl103 (h : Conv.JClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1002) : Conv.JClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1004 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle103)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap103 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd103 a ha)) PRE_first_tail_x15_r0_body.zjc103

end Host.Load.Run.Tpl
end

section -- st103/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st103.bodyLast from PRE_first_tail_x15_r0_body.st103.s1 to PRE_first_tail_x15_r0_body.st103.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st103.F PRE_first_tail_x15_r0_body.st103.s1).run PRE_first_tail_x15_r0_body.st103.S1 = some (PRE_first_tail_x15_r0_body.st103.s2, PRE_first_tail_x15_r0_body.st103.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st103.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st103.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st103.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st103.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st103/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st103.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st103.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st103.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st103.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st103.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st103.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st103.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st103.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st103.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st103.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st103.s0 PRE_first_tail_x15_r0_body.st103.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st103.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st103.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st103.s1 PRE_first_tail_x15_r0_body.st103.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st103/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st103.bodyK0F from PRE_first_tail_x15_r0_body.st103.s0 to PRE_first_tail_x15_r0_body.st103.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st103.F (PRE_first_tail_x15_r0_body.st103.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st103.ks 0).getD 0) PRE_first_tail_x15_r0_body.st103.s0 PRE_first_tail_x15_r0_body.st103.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st103.s1, PRE_first_tail_x15_r0_body.st103.S1)
theorem PRE_first_tail_x15_r0_body.st103.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st103.F (PRE_first_tail_x15_r0_body.st103.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st103.ks 0).getD 0) PRE_first_tail_x15_r0_body.st103.s0 PRE_first_tail_x15_r0_body.st103.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st103.s1, PRE_first_tail_x15_r0_body.st103.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st103.bodyOkLN_ok PRE_first_tail_x15_r0_body.st103.bodyK0F
end Host.Load.Run.Tpl
end

section -- st103/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st103.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st103.F (PRE_first_tail_x15_r0_body.st103.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st103.s0 PRE_first_tail_x15_r0_body.st103.S0 = some (PRE_first_tail_x15_r0_body.st103.s1, PRE_first_tail_x15_r0_body.st103.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st103.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st103.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st103.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st103.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st103.F (PRE_first_tail_x15_r0_body.st103.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st103.s0
  S0 := PRE_first_tail_x15_r0_body.st103.S0
  s1 := PRE_first_tail_x15_r0_body.st103.s1
  S1 := PRE_first_tail_x15_r0_body.st103.S1
  s2 := PRE_first_tail_x15_r0_body.st103.s2
  S2 := PRE_first_tail_x15_r0_body.st103.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st103.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st103.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st103.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st103.bodyHalt
  last := PRE_first_tail_x15_r0_body.st103.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st103.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC104
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 104 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1008` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa104` into the merged state
`PRE_first_tail_x15_r0_body.s1007`. -/

def PRE_first_tail_x15_r0_body.pl104 : List Nat := [2756105]
def PRE_first_tail_x15_r0_body.nr104 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd104 : RData :=
  ⟨2756096, 2756106, Stage.setAll PTrie.nil [(2756095, 2756105)], Stage.setAll PTrie.nil [],
   20241, 20241, 17344, 17344, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa104 : Map :=
  Conv.Map.compact 2756095 2756106 4501 PRE_first_tail_x15_r0_body.pl104 (PRE_first_tail_x15_r0_body.nr104.map NumV.ref) PRE_first_tail_x15_r0_body.kd104.big
    PRE_first_tail_x15_r0_body.kd104.region PRE_first_tail_x15_r0_body.kd104.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws104 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs104 : List SymE := PRE_first_tail_x15_r0_body.nr104.map fun r => (nth? PRE_first_tail_x15_r0_body.S1007.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta104 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws104 PRE_first_tail_x15_r0_body.crs104
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB104 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab104 : PRE_first_tail_x15_r0_body.S1008.tab = PRE_first_tail_x15_r0_body.S1006.tab ++ PRE_first_tail_x15_r0_body.cws104.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace104 : PRE_first_tail_x15_r0_body.s1008.trace = PRE_first_tail_x15_r0_body.s1006.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext104 : PRE_first_tail_x15_r0_body.s1008.next = 2756096
kernel_rfl PRE_first_tail_x15_r0_body.ccounters104 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.nnext) = (20241, 17344)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue104 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1007.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa104.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp104 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.tokens.all (bSN 4501) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean104 : Conv.cleanListB 20241 131072 (fun r => Nat.ble 80964 r) PRE_first_tail_x15_r0_body.s1008
    (PRE_first_tail_x15_r0_body.wrB104 ++ (List.range 1).map (2756095 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs104 : bigsOutB 20241 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK104
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl104`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl104 : List Nat := [2665, 2673467, 2756095]
def PRE_first_tail_x15_r0_body.clo104 : List Nat := []
def PRE_first_tail_x15_r0_body.cln104 : List Nat := []
def PRE_first_tail_x15_r0_body.cli104 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap104 : PRE_first_tail_x15_r0_body.s1008.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1006.heap (PRE_first_tail_x15_r0_body.cl104.filterMap fun a => (PRE_first_tail_x15_r0_body.s1008.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe104 : Nat.ble PRE_first_tail_x15_r0_body.s1006.next PRE_first_tail_x15_r0_body.s1008.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP104 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1006 PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.cl104 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp104 : Conv.suppListB PRE_first_tail_x15_r0_body.s1008 4501 PRE_first_tail_x15_r0_body.cl104 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound104 : Conv.boundListB PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.cl104 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK104 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln104.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK104 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo104.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK104 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli104.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst104 : Conv.sstListB 4501 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx PRE_first_tail_x15_r0_body.cln104 PRE_first_tail_x15_r0_body.clo104 PRE_first_tail_x15_r0_body.cli104 = true

end Host.Load.Run.Tpl
end

section -- SiteCl104
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA104 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo104.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd104 : (PRE_first_tail_x15_r0_body.clo104 ++ PRE_first_tail_x15_r0_body.cln104 ++ PRE_first_tail_x15_r0_body.cli104).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle104 : Conv.Cnt.leB (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) (⟨20241, 17344, 2756096, 4501⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck104 : Conv.ncleanListB (⟨20241, 17344, 2756096, 4501⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx PRE_first_tail_x15_r0_body.clo104 PRE_first_tail_x15_r0_body.cln104 PRE_first_tail_x15_r0_body.cli104 = true
theorem PRE_first_tail_x15_r0_body.cncl104 (h : Conv.NClean (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx) : Conv.NClean (⟨20241, 17344, 2756096, 4501⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle104 PRE_first_tail_x15_r0_body.ckA104 PRE_first_tail_x15_r0_body.cobjsK104 PRE_first_tail_x15_r0_body.cnodesK104 PRE_first_tail_x15_r0_body.citemsK104 PRE_first_tail_x15_r0_body.cbd104 PRE_first_tail_x15_r0_body.cck104

end Host.Load.Run.Tpl
end

section -- SiteS104
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 104 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc104 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P104 : LoadP := PRE_first_tail_x15_r0_body.Pc104.raise 17344
kernel_rfl PRE_first_tail_x15_r0_body.craise104 : Nat.ble PRE_first_tail_x15_r0_body.Pc104.N0 17344 = true
theorem PRE_first_tail_x15_r0_body.raised104 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc104 PRE_first_tail_x15_r0_body.P104 :=
  .inr ⟨17344, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise104, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_104 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_104 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1007.ffi)
def PRE_first_tail_x15_r0_body.khinv104 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv104 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS104 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS104 : List Nat := List.range' 17344 0
def PRE_first_tail_x15_r0_body.ciS104 : List Nat := [] ++ List.range' 17344 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0104 : PRE_first_tail_x15_r0_body.kd104.nh0 = PRE_first_tail_x15_r0_body.cx0_104.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1104 : PRE_first_tail_x15_r0_body.kd104.nh1 = PRE_first_tail_x15_r0_body.cx1_104.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0104 : PRE_first_tail_x15_r0_body.kd104.nn0 = PRE_first_tail_x15_r0_body.cx0_104.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1104 : PRE_first_tail_x15_r0_body.kd104.nn1 = PRE_first_tail_x15_r0_body.cx1_104.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo104 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P104.lo && Nat.ble PRE_first_tail_x15_r0_body.P104.lo PRE_first_tail_x15_r0_body.cx0_104.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P104.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P104.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt104 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_104.mlx.next PRE_first_tail_x15_r0_body.cx1_104.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_104.mlx.nnext PRE_first_tail_x15_r0_body.cx1_104.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband104 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P104.NL && Nat.ble PRE_first_tail_x15_r0_body.P104.NL PRE_first_tail_x15_r0_body.P104.N0 && Nat.ble PRE_first_tail_x15_r0_body.P104.N0 PRE_first_tail_x15_r0_body.cx0_104.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow104 : PRE_first_tail_x15_r0_body.kd104.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren104 : checkRenG PRE_first_tail_x15_r0_body.kd104.hnd PRE_first_tail_x15_r0_body.khinv104 (phB PRE_first_tail_x15_r0_body.cx0_104.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband104 : PRE_first_tail_x15_r0_body.kd104.checkBand PRE_first_tail_x15_r0_body.P104.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos104 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd104.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren104 : checkRenG PRE_first_tail_x15_r0_body.kd104.node PRE_first_tail_x15_r0_body.kninv104 (pnB PRE_first_tail_x15_r0_body.cx0_104.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P104.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd104.nodeF j) PRE_first_tail_x15_r0_body.cx1_104.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a104 : PRE_first_tail_x15_r0_body.cx0_104.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b104 : PRE_first_tail_x15_r0_body.cx0_104.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.pending = PRE_first_tail_x15_r0_body.cx0_104.mlx.pending.map PRE_first_tail_x15_r0_body.kappa104.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.errh = PRE_first_tail_x15_r0_body.cx0_104.mlx.errh.map PRE_first_tail_x15_r0_body.kappa104.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.files = PRE_first_tail_x15_r0_body.cx0_104.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.arch = PRE_first_tail_x15_r0_body.cx0_104.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_104.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.wired = PRE_first_tail_x15_r0_body.cx0_104.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost104 : PRE_first_tail_x15_r0_body.cx1_104.host = PRE_first_tail_x15_r0_body.cx0_104.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd104`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0104 : PRE_first_tail_x15_r0_body.kd104.n0 = 2756096
kernel_rfl PRE_first_tail_x15_r0_body.ckn1104 : PRE_first_tail_x15_r0_body.kd104.n1 = 2756106
kernel_rfl PRE_first_tail_x15_r0_body.ckheap104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.heap).all (fun x => Nat.ble 2756095 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl104 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd104.heap.get (2756095 + j) = nth? PRE_first_tail_x15_r0_body.pl104 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja104 : Nat.ble 2756095 2756095 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn104 : Nat.ble 4501 4501 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD104 : Nat.ble 2756095 PRE_first_tail_x15_r0_body.kd104.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn104 : Nat.ble 20241 PRE_first_tail_x15_r0_body.kd104.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn104 : Nat.ble 17344 PRE_first_tail_x15_r0_body.kd104.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb104 : Nat.ble 20241 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.heap).all (Nat.ble (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.hnd).all (Nat.ble (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.node).all (Nat.ble (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix104 : Conv.FixOld (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa104 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja104) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn104) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD104) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn104) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn104) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb104) PRE_first_tail_x15_r0_body.fheap104 PRE_first_tail_x15_r0_body.fhnd104 PRE_first_tail_x15_r0_body.fnode104
kernel_rfl PRE_first_tail_x15_r0_body.fcxn104 : (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn104 : (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0104 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_104.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_104.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS104.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_104.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS104.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_104.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS104.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_104.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS104.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_104.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd104 : (PRE_first_tail_x15_r0_body.clo104 ++ PRE_first_tail_x15_r0_body.cln104 ++ PRE_first_tail_x15_r0_body.cli104 ++ PRE_first_tail_x15_r0_body.cwS104 ++ PRE_first_tail_x15_r0_body.cnS104 ++ PRE_first_tail_x15_r0_body.ciS104).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW104 : PRE_first_tail_x15_r0_body.cwS104.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo104.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI104 : PRE_first_tail_x15_r0_body.ciS104.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli104.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN104 : PRE_first_tail_x15_r0_body.cnS104.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF104 : PRE_first_tail_x15_r0_body.cln104.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh104 : PRE_first_tail_x15_r0_body.clo104.all (handleOK PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.P104.lo PRE_first_tail_x15_r0_body.cx0_104.mlx PRE_first_tail_x15_r0_body.cx1_104.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo104 : PRE_first_tail_x15_r0_body.clo104.map (fun h => PRE_first_tail_x15_r0_body.cx1_104.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa104.handle h)) = PRE_first_tail_x15_r0_body.clo104.map (fun h => (PRE_first_tail_x15_r0_body.cx0_104.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa104.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok104 : PRE_first_tail_x15_r0_body.clo104.all (objOK PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.P104.NL PRE_first_tail_x15_r0_body.cx0_104.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd104 : PRE_first_tail_x15_r0_body.cln104.all (nodeOKF PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.P104 PRE_first_tail_x15_r0_body.cx0_104.mlx PRE_first_tail_x15_r0_body.cx1_104.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp104 : ((PRE_first_tail_x15_r0_body.cln104.filter (fullB PRE_first_tail_x15_r0_body.P104))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_104.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa104.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln104.filter (fullB PRE_first_tail_x15_r0_body.P104))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_104.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa104.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI104 : incrB PRE_first_tail_x15_r0_body.kd104.nodeF (List.range' 17344 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.node).all (fun k => Nat.ble 17344 k && Nat.blt k 17344) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL104 : (PRE_first_tail_x15_r0_body.cln104.filter (Nat.ble PRE_first_tail_x15_r0_body.P104.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd104.nodeF i) && (Nat.blt i 17344 || Nat.ble PRE_first_tail_x15_r0_body.kd104.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord104 : (PRE_first_tail_x15_r0_body.cln104.filter (Nat.ble PRE_first_tail_x15_r0_body.P104.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd104.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd104.nodeF j) (PRE_first_tail_x15_r0_body.kd104.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow104 PRE_first_tail_x15_r0_body.cnn1104 PRE_first_tail_x15_r0_body.fnordI104 PRE_first_tail_x15_r0_body.fnordK104 PRE_first_tail_x15_r0_body.fnordL104
kernel_rfl PRE_first_tail_x15_r0_body.fi104 : PRE_first_tail_x15_r0_body.cli104.all (pnB PRE_first_tail_x15_r0_body.cx0_104.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii104 : PRE_first_tail_x15_r0_body.cli104.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_104.mlx.items.get (PRE_first_tail_x15_r0_body.kappa104.node k) = (PRE_first_tail_x15_r0_body.cx0_104.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa104.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot104 (clean : Conv.NClean (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P104.NL) (cl : SSt (· < 4501) PRE_first_tail_x15_r0_body.cx0_104.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P104 4501 PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.kd104 PRE_first_tail_x15_r0_body.khinv104 PRE_first_tail_x15_r0_body.kninv104 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx PRE_first_tail_x15_r0_body.cx0_104.mlx PRE_first_tail_x15_r0_body.cx1_104.mlx (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo104 PRE_first_tail_x15_r0_body.cln104 PRE_first_tail_x15_r0_body.cli104 PRE_first_tail_x15_r0_body.cwS104 PRE_first_tail_x15_r0_body.cnS104 PRE_first_tail_x15_r0_body.ciS104 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0104, PRE_first_tail_x15_r0_body.cnh1104, PRE_first_tail_x15_r0_body.cnn0104, PRE_first_tail_x15_r0_body.cnn1104, PRE_first_tail_x15_r0_body.cplo104, PRE_first_tail_x15_r0_body.ccnt104, PRE_first_tail_x15_r0_body.cnband104, PRE_first_tail_x15_r0_body.chbelow104, PRE_first_tail_x15_r0_body.chren104, PRE_first_tail_x15_r0_body.cband104, PRE_first_tail_x15_r0_body.cnh1pos104, PRE_first_tail_x15_r0_body.cnren104, PRE_first_tail_x15_r0_body.cnlow104, PRE_first_tail_x15_r0_body.cabs0a104, PRE_first_tail_x15_r0_body.cabs0b104, PRE_first_tail_x15_r0_body.ctok1104, PRE_first_tail_x15_r0_body.cpend104, PRE_first_tail_x15_r0_body.cerrh104, PRE_first_tail_x15_r0_body.cfiles104, PRE_first_tail_x15_r0_body.carch104, PRE_first_tail_x15_r0_body.csizes104, PRE_first_tail_x15_r0_body.cwired104, PRE_first_tail_x15_r0_body.cfix104, clean, PRE_first_tail_x15_r0_body.fcxn104, PRE_first_tail_x15_r0_body.fcnn104, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0104, PRE_first_tail_x15_r0_body.fnk104, PRE_first_tail_x15_r0_body.ckA104, PRE_first_tail_x15_r0_body.cobjsK104, PRE_first_tail_x15_r0_body.cnodesK104, PRE_first_tail_x15_r0_body.citemsK104, PRE_first_tail_x15_r0_body.f1A104, PRE_first_tail_x15_r0_body.f1O104, PRE_first_tail_x15_r0_body.f1N104, PRE_first_tail_x15_r0_body.f1I104, PRE_first_tail_x15_r0_body.fbd104, PRE_first_tail_x15_r0_body.fincW104, PRE_first_tail_x15_r0_body.fincI104, PRE_first_tail_x15_r0_body.fincN104, PRE_first_tail_x15_r0_body.flnF104, PRE_first_tail_x15_r0_body.fh104, PRE_first_tail_x15_r0_body.fo104, PRE_first_tail_x15_r0_body.fok104, PRE_first_tail_x15_r0_body.fnd104, PRE_first_tail_x15_r0_body.fp104, PRE_first_tail_x15_r0_body.fnord104, PRE_first_tail_x15_r0_body.fi104, PRE_first_tail_x15_r0_body.fii104⟩
theorem PRE_first_tail_x15_r0_body.cnshift104 (clean : Conv.NClean (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P104.NL) (cl : SSt (· < 4501) PRE_first_tail_x15_r0_body.cx0_104.mlx) : NShift PRE_first_tail_x15_r0_body.P104 4501 PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.cx0_104 PRE_first_tail_x15_r0_body.cx1_104 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot104 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost104 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0104 PRE_first_tail_x15_r0_body.ckn1104 PRE_first_tail_x15_r0_body.ckheap104 PRE_first_tail_x15_r0_body.ckpl104)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_104 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1006.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_104 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1006.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_104 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1006.ffi) = some PRE_first_tail_x15_r0_body.fxC_104
kernel_rfl PRE_first_tail_x15_r0_body.okrC_104 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1006.ffi) = some PRE_first_tail_x15_r0_body.krC_104
noncomputable def PRE_first_tail_x15_r0_body.fx0_104 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1008.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_104 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1008.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_104 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1008.ffi) = some PRE_first_tail_x15_r0_body.fx0_104
kernel_rfl PRE_first_tail_x15_r0_body.okr0_104 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1008.ffi) = some PRE_first_tail_x15_r0_body.kr0_104
noncomputable def PRE_first_tail_x15_r0_body.fx1_104 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1007.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_104 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1007.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_104 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1007.ffi) = some PRE_first_tail_x15_r0_body.fx1_104
kernel_rfl PRE_first_tail_x15_r0_body.okr1_104 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1007.ffi) = some PRE_first_tail_x15_r0_body.kr1_104
kernel_rfl PRE_first_tail_x15_r0_body.ff0104 : PRE_first_tail_x15_r0_body.fx0_104 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_104 (PRE_first_tail_x15_r0_body.clo104.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_104.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1104 : PRE_first_tail_x15_r0_body.fx1_104 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_104 (PRE_first_tail_x15_r0_body.cwS104.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_104.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck104 : freedLB PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.cx0_104.mlx PRE_first_tail_x15_r0_body.fx0_104 PRE_first_tail_x15_r0_body.fx1_104 PRE_first_tail_x15_r0_body.clo104 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0104 : PRE_first_tail_x15_r0_body.kr0_104.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_104.flags (PRE_first_tail_x15_r0_body.clo104.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_104.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0104 : PRE_first_tail_x15_r0_body.kr0_104.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_104.targs (PRE_first_tail_x15_r0_body.clo104.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_104.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1104 : PRE_first_tail_x15_r0_body.kr1_104.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_104.flags (PRE_first_tail_x15_r0_body.cwS104.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_104.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1104 : PRE_first_tail_x15_r0_body.kr1_104.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_104.targs (PRE_first_tail_x15_r0_body.cwS104.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_104.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck104 : krecLB PRE_first_tail_x15_r0_body.kappa104 4501 PRE_first_tail_x15_r0_body.cx0_104.mlx PRE_first_tail_x15_r0_body.kr0_104 PRE_first_tail_x15_r0_body.kr1_104 PRE_first_tail_x15_r0_body.clo104 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn104 : Nat.ble 4501 4501 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge104 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1007.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1008.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR104 : pendRegB PRE_first_tail_x15_r0_body.kappa104 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe104 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1007.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift104 (clean : Conv.NClean (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P104.NL) (cl : SSt (· < 4501) PRE_first_tail_x15_r0_body.cx0_104.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_104.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_104.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_104.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_104.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P104 4501 PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.s1008.ffi PRE_first_tail_x15_r0_body.s1007.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift104 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue104, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp104 t ht),
    PRE_first_tail_x15_r0_body.cbridge104,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1008.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1007.ffi) (PRE_first_tail_x15_r0_body.cfoot104 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_104 PRE_first_tail_x15_r0_body.ofx1_104 hobjC PRE_first_tail_x15_r0_body.ff0104 PRE_first_tail_x15_r0_body.ff1104 PRE_first_tail_x15_r0_body.ffck104,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1008.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1007.ffi) (PRE_first_tail_x15_r0_body.cfoot104 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_104 PRE_first_tail_x15_r0_body.okr1_104 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn104) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0104 PRE_first_tail_x15_r0_body.fkt0104 PRE_first_tail_x15_r0_body.fkf1104 PRE_first_tail_x15_r0_body.fkt1104 PRE_first_tail_x15_r0_body.fkck104,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0104 PRE_first_tail_x15_r0_body.cnh1104 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe104) PRE_first_tail_x15_r0_body.cpendR104⟩

end Host.Load.Run.Tpl
end

section -- st104/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st104 0
host_stream_state PRE_first_tail_x15_r0_body.st104 1
host_stream_state PRE_first_tail_x15_r0_body.st104 2
end Host.Load.Run.Tpl
end

section -- Site104
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 104 of chain `PRE_first_tail_x15_r0_body`: `plan__g104__g105` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1006`, the merged state `PRE_first_tail_x15_r0_body.s1007`,
the site template `PRE_first_tail_x15_r0_body.st104` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1008`: the merge.
The footprint's facts are in `SiteF104`, the compaction's in `SiteC104`, `SiteK104`, `SiteNa104`, `SiteNb104`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso104 : PRE_first_tail_x15_r0_body.st104.s0 = { PRE_first_tail_x15_r0_body.s1006 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs104 : List Frame := PRE_first_tail_x15_r0_body.s1006.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_104 : PRE_first_tail_x15_r0_body.S1006.tab.length = 4501
kernel_rfl PRE_first_tail_x15_r0_body.tab0_104 : PRE_first_tail_x15_r0_body.st104.S0.tab = PRE_first_tail_x15_r0_body.S1006.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws104 : List Nat := [2769, 2770, 2771]
kernel_rfl PRE_first_tail_x15_r0_body.fresh104 : (PRE_first_tail_x15_r0_body.S1006.tab.all fun e => PRE_first_tail_x15_r0_body.ws104.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1006.oracle.all fun q => PRE_first_tail_x15_r0_body.ws104.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab104 : PRE_first_tail_x15_r0_body.S1007.tab = PRE_first_tail_x15_r0_body.S1006.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws104
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen104 : PRE_first_tail_x15_r0_body.st104.S2.tab.length - PRE_first_tail_x15_r0_body.st104.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged104`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap104 : PRE_first_tail_x15_r0_body.s1007.heap = PRE_first_tail_x15_r0_body.st104.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext104 : PRE_first_tail_x15_r0_body.s1007.next = PRE_first_tail_x15_r0_body.st104.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl104 : PRE_first_tail_x15_r0_body.s1007.ctl = PRE_first_tail_x15_r0_body.st104.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack104 : PRE_first_tail_x15_r0_body.s1007.stack = PRE_first_tail_x15_r0_body.st104.s2.stack ++ PRE_first_tail_x15_r0_body.s1006.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs104 : PRE_first_tail_x15_r0_body.s1007.jobs = PRE_first_tail_x15_r0_body.st104.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi104 : PRE_first_tail_x15_r0_body.s1007.ffi = PRE_first_tail_x15_r0_body.st104.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace104 : PRE_first_tail_x15_r0_body.s1007.trace = PRE_first_tail_x15_r0_body.st104.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores104 : PRE_first_tail_x15_r0_body.s1007.stores = PRE_first_tail_x15_r0_body.st104.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD104
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 104 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived104 : PRE_first_tail_x15_r0_body.nr104.map (fun r => nth? PRE_first_tail_x15_r0_body.st104.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo104 : PRE_first_tail_x15_r0_body.nr104.all (Nat.ble 4501) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj104 : PRE_first_tail_x15_r0_body.cws104.all (fun c => !PRE_first_tail_x15_r0_body.ws104.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ104 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws104 PRE_first_tail_x15_r0_body.crs104 PRE_first_tail_x15_r0_body.ws104

end Host.Load.Run.Tpl
end

section -- st104/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st104`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st104.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st104.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st104.s2.heap PRE_first_tail_x15_r0_body.st104.wrR ++ freshOf PRE_first_tail_x15_r0_body.st104.s2.heap PRE_first_tail_x15_r0_body.st104.s0.next PRE_first_tail_x15_r0_body.st104.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st104.wr : List Nat := PRE_first_tail_x15_r0_body.st104.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st104.heapFoot : PRE_first_tail_x15_r0_body.st104.s2.heap = setAll PRE_first_tail_x15_r0_body.st104.s0.heap PRE_first_tail_x15_r0_body.st104.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st104.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st104.s0.next PRE_first_tail_x15_r0_body.st104.s2.next = true
theorem PRE_first_tail_x15_r0_body.st104.grows : PRE_first_tail_x15_r0_body.st104.s0.next ≤ PRE_first_tail_x15_r0_body.st104.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st104.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st104.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st104.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st104.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st104.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st104.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st104.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st104.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st104.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st104.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st104.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st104.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF104
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 104 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB104 : nodupT PRE_first_tail_x15_r0_body.st104.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup104 : PRE_first_tail_x15_r0_body.st104.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB104).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB104 : PRE_first_tail_x15_r0_body.st104.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound104 : ∀ b ∈ PRE_first_tail_x15_r0_body.st104.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB104 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr104 := PRE_first_tail_x15_r0_body.st104.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq104 : PRE_first_tail_x15_r0_body.st104.s2.trace = PRE_first_tail_x15_r0_body.trFr104 ++ PRE_first_tail_x15_r0_body.st104.s0.trace
theorem PRE_first_tail_x15_r0_body.trace104 : ∃ fr, PRE_first_tail_x15_r0_body.st104.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st104.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq104⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide104 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB104 : (PRE_first_tail_x15_r0_body.wide104.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st104.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix104 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide104, WFix Map.id (Present PRE_first_tail_x15_r0_body.st104.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB104 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL104
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 104 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1007`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO104 : PRE_first_tail_x15_r0_body.st104.S0.oracle = PRE_first_tail_x15_r0_body.st104.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B104 : PRE_first_tail_x15_r0_body.st104.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st104.s0.next || (PRE_first_tail_x15_r0_body.st104.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot104 : Conv.StageFoot PRE_first_tail_x15_r0_body.st104.wr PRE_first_tail_x15_r0_body.st104.s0 PRE_first_tail_x15_r0_body.st104.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st104.heapFoot PRE_first_tail_x15_r0_body.wrNodup104 PRE_first_tail_x15_r0_body.wrBound104 PRE_first_tail_x15_r0_body.wr0B104 PRE_first_tail_x15_r0_body.st104.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged104 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st104.F.S → PRE_first_tail_x15_r0_body.st104.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st104.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st104.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs104 PRE_first_tail_x15_r0_body.st104.wr PRE_first_tail_x15_r0_body.s1006 PRE_first_tail_x15_r0_body.st104.s2 PRE_first_tail_x15_r0_body.st104.s0
      PRE_first_tail_x15_r0_body.st104.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st104.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1007 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso104 PRE_first_tail_x15_r0_body.stFoot104 PRE_first_tail_x15_r0_body.wrNodup104 PRE_first_tail_x15_r0_body.wrBound104 PRE_first_tail_x15_r0_body.trace104 PRE_first_tail_x15_r0_body.mheap104
    PRE_first_tail_x15_r0_body.mnext104 PRE_first_tail_x15_r0_body.mctl104 PRE_first_tail_x15_r0_body.mstack104 PRE_first_tail_x15_r0_body.mjobs104 PRE_first_tail_x15_r0_body.mffi104 PRE_first_tail_x15_r0_body.mtrace104 PRE_first_tail_x15_r0_body.mstores104 h

def PRE_first_tail_x15_r0_body.arrEl104_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE104_2665 : arrOf PRE_first_tail_x15_r0_body.s1007 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl104_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA104_2665 : isArrB PRE_first_tail_x15_r0_body.s1007 2665 = true
theorem PRE_first_tail_x15_r0_body.arr104_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1007.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl104_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE104_2665 PRE_first_tail_x15_r0_body.arrA104_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN104_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl104_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR104_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl104_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN104_2665

def PRE_first_tail_x15_r0_body.arrEl104_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE104_2673467 : arrOf PRE_first_tail_x15_r0_body.s1007 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl104_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA104_2673467 : isArrB PRE_first_tail_x15_r0_body.s1007 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr104_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1007.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl104_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE104_2673467 PRE_first_tail_x15_r0_body.arrA104_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN104_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl104_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR104_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl104_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN104_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k104 : isArrB PRE_first_tail_x15_r0_body.s1007 4910 = false
theorem PRE_first_tail_x15_r0_body.keep104 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1007 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k104 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr104_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl104_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ104
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 104 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1006`, the merged
state `PRE_first_tail_x15_r0_body.s1007`, the canonical state `PRE_first_tail_x15_r0_body.s1008`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl104 : PRE_first_tail_x15_r0_body.pl104.all (Nat.ble PRE_first_tail_x15_r0_body.s1006.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd104 : nodupT PRE_first_tail_x15_r0_body.pl104 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1104 : Nat.ble PRE_first_tail_x15_r0_body.s1006.next 2756106 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst104 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1006.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn104 : PRE_first_tail_x15_r0_body.s1008.next = PRE_first_tail_x15_r0_body.s1006.next + PRE_first_tail_x15_r0_body.pl104.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn104 : PRE_first_tail_x15_r0_body.s1007.next = 2756106
kernel_rfl PRE_first_tail_x15_r0_body.zgrow104 : Nat.ble PRE_first_tail_x15_r0_body.s1008.next PRE_first_tail_x15_r0_body.s1007.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh104 : PRE_first_tail_x15_r0_body.S1006.tab.all (fun e => PRE_first_tail_x15_r0_body.cws104.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd104 : nodupT PRE_first_tail_x15_r0_body.cws104 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi104 : PRE_first_tail_x15_r0_body.nr104.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1007.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt104 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1006.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg104_2665 : PRE_first_tail_x15_r0_body.s1008.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1008 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk104_2665 : (objOf PRE_first_tail_x15_r0_body.s1008 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm104_2665 : PRE_first_tail_x15_r0_body.s1007.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa104.obj (objOf PRE_first_tail_x15_r0_body.s1008 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1007 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg104_2673467 : PRE_first_tail_x15_r0_body.s1008.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1008 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk104_2673467 : (objOf PRE_first_tail_x15_r0_body.s1008 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm104_2673467 : PRE_first_tail_x15_r0_body.s1007.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa104.obj (objOf PRE_first_tail_x15_r0_body.s1008 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1007 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw104_4910 : (PRE_first_tail_x15_r0_body.s1008.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw104_2673472 : (PRE_first_tail_x15_r0_body.s1008.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw104_2673473 : (PRE_first_tail_x15_r0_body.s1008.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd104 : PRE_first_tail_x15_r0_body.cl104.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr104 : PRE_first_tail_x15_r0_body.st104.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1006.next || PRE_first_tail_x15_r0_body.cl104.contains b) = true
def PRE_first_tail_x15_r0_body.zl104 : List Nat := PRE_first_tail_x15_r0_body.cl104.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE104 : PRE_first_tail_x15_r0_body.zl104.map (fun a => PRE_first_tail_x15_r0_body.s1007.heap.get (PRE_first_tail_x15_r0_body.kappa104.a a)) = PRE_first_tail_x15_r0_body.zl104.map (fun a => (PRE_first_tail_x15_r0_body.s1008.heap.get a).map PRE_first_tail_x15_r0_body.kappa104.hobj)
theorem PRE_first_tail_x15_r0_body.zimg104 : HeapImg PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.s1007 PRE_first_tail_x15_r0_body.zl104 := PRE_first_tail_x15_r0_body.zimgE104
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl104 : PRE_first_tail_x15_r0_body.s1007.ctl = PRE_first_tail_x15_r0_body.kappa104.ctl PRE_first_tail_x15_r0_body.s1008.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack104 : PRE_first_tail_x15_r0_body.s1007.stack = PRE_first_tail_x15_r0_body.s1008.stack.map PRE_first_tail_x15_r0_body.kappa104.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs104 : PRE_first_tail_x15_r0_body.s1007.jobs = PRE_first_tail_x15_r0_body.s1008.jobs.map PRE_first_tail_x15_r0_body.kappa104.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores104 : PRE_first_tail_x15_r0_body.s1007.stores = PRE_first_tail_x15_r0_body.kappa104.stores PRE_first_tail_x15_r0_body.s1008.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots104 : checkRootsSupp PRE_first_tail_x15_r0_body.s1008 4501 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC104 : PRE_first_tail_x15_r0_body.S1006.tab.length + PRE_first_tail_x15_r0_body.cws104.length = 4501
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap104 : PRE_first_tail_x15_r0_body.kappa104 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1006.next 2756106 PRE_first_tail_x15_r0_body.S1006.tab.length PRE_first_tail_x15_r0_body.pl104 (PRE_first_tail_x15_r0_body.nr104.map NumV.ref) PRE_first_tail_x15_r0_body.kd104.big
  PRE_first_tail_x15_r0_body.kd104.region PRE_first_tail_x15_r0_body.kd104.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin104 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1008.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc104 : Conv.jcleanListB (⟨20241, 17344, 2756096, 4501⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.cl104 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB104 : noBigRootsP (fun i => !Conv.oldBigB (⟨20241, 17344, 2756096, 4501⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1008.trace PRE_first_tail_x15_r0_body.s1008 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm104 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17344 = true
theorem PRE_first_tail_x15_r0_body.cjcl104 (h : Conv.JClean (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1006) : Conv.JClean (⟨20241, 17344, 2756096, 4501⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1008 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle104)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap104 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd104 a ha)) PRE_first_tail_x15_r0_body.zjc104

end Host.Load.Run.Tpl
end

section -- st104/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st104.bodyLast from PRE_first_tail_x15_r0_body.st104.s1 to PRE_first_tail_x15_r0_body.st104.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st104.F PRE_first_tail_x15_r0_body.st104.s1).run PRE_first_tail_x15_r0_body.st104.S1 = some (PRE_first_tail_x15_r0_body.st104.s2, PRE_first_tail_x15_r0_body.st104.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st104.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st104.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st104.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st104.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st104/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st104.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st104.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st104.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st104.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st104.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st104.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st104.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st104.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st104.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st104.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st104.s0 PRE_first_tail_x15_r0_body.st104.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st104.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st104.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st104.s1 PRE_first_tail_x15_r0_body.st104.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st104/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st104.bodyK0F from PRE_first_tail_x15_r0_body.st104.s0 to PRE_first_tail_x15_r0_body.st104.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st104.F (PRE_first_tail_x15_r0_body.st104.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st104.ks 0).getD 0) PRE_first_tail_x15_r0_body.st104.s0 PRE_first_tail_x15_r0_body.st104.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st104.s1, PRE_first_tail_x15_r0_body.st104.S1)
theorem PRE_first_tail_x15_r0_body.st104.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st104.F (PRE_first_tail_x15_r0_body.st104.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st104.ks 0).getD 0) PRE_first_tail_x15_r0_body.st104.s0 PRE_first_tail_x15_r0_body.st104.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st104.s1, PRE_first_tail_x15_r0_body.st104.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st104.bodyOkLN_ok PRE_first_tail_x15_r0_body.st104.bodyK0F
end Host.Load.Run.Tpl
end

section -- st104/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st104.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st104.F (PRE_first_tail_x15_r0_body.st104.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st104.s0 PRE_first_tail_x15_r0_body.st104.S0 = some (PRE_first_tail_x15_r0_body.st104.s1, PRE_first_tail_x15_r0_body.st104.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st104.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st104.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st104.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st104.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st104.F (PRE_first_tail_x15_r0_body.st104.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st104.s0
  S0 := PRE_first_tail_x15_r0_body.st104.S0
  s1 := PRE_first_tail_x15_r0_body.st104.s1
  S1 := PRE_first_tail_x15_r0_body.st104.S1
  s2 := PRE_first_tail_x15_r0_body.st104.s2
  S2 := PRE_first_tail_x15_r0_body.st104.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st104.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st104.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st104.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st104.bodyHalt
  last := PRE_first_tail_x15_r0_body.st104.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st104.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC105
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 105 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1024` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa105` into the merged state
`PRE_first_tail_x15_r0_body.s1023`. -/

def PRE_first_tail_x15_r0_body.pl105 : List Nat := [2758194, 2758030, 2758082, 2758195, 2758196, 2758032, 2758084, 2758193, 2758192, 2758191, 2758190, 2758184, 2758135, 2758186, 2758137]
def PRE_first_tail_x15_r0_body.nr105 : List Nat := [4586, 4587, 4583, 4589, 4585, 4593, 4594, 4591, 4592]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd105 : RData :=
  ⟨2757847, 2758197, Stage.setAll PTrie.nil [(2757832, 2758194), (2757833, 2758030), (2757834, 2758082), (2757835, 2758195), (2757836, 2758196), (2757837, 2758032), (2757838, 2758084), (2757839, 2758193), (2757840, 2758192), (2757841, 2758191), (2757842, 2758190), (2757843, 2758184), (2757844, 2758135), (2757845, 2758186), (2757846, 2758137)], Stage.setAll PTrie.nil [(20281, 20283), (20282, 20284), (20283, 20286), (20284, 20285)],
   20285, 20287, 17378, 17378, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4578, .ref 4586), (4579, .ref 4587), (4580, .ref 4583), (4581, .ref 4589), (4582, .ref 4585), (4583, .ref 4593), (4584, .ref 4594), (4585, .ref 4591), (4586, .ref 4592)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa105 : Map :=
  Conv.Map.compact 2757832 2758197 4578 PRE_first_tail_x15_r0_body.pl105 (PRE_first_tail_x15_r0_body.nr105.map NumV.ref) PRE_first_tail_x15_r0_body.kd105.big
    PRE_first_tail_x15_r0_body.kd105.region PRE_first_tail_x15_r0_body.kd105.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws105 : List Nat := [2789, 2790, 2791, 2792, 2793, 2794, 2795, 2796, 2797]
noncomputable def PRE_first_tail_x15_r0_body.crs105 : List SymE := PRE_first_tail_x15_r0_body.nr105.map fun r => (nth? PRE_first_tail_x15_r0_body.S1023.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta105 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws105 PRE_first_tail_x15_r0_body.crs105
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB105 : List Nat := [2665, 2672570, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab105 : PRE_first_tail_x15_r0_body.S1024.tab = PRE_first_tail_x15_r0_body.S1022.tab ++ PRE_first_tail_x15_r0_body.cws105.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace105 : PRE_first_tail_x15_r0_body.s1024.trace = PRE_first_tail_x15_r0_body.s1022.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext105 : PRE_first_tail_x15_r0_body.s1024.next = 2757847
kernel_rfl PRE_first_tail_x15_r0_body.ccounters105 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.nnext) = (20285, 17378)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue105 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1023.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa105.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp105 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.tokens.all (bSN 4587) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean105 : Conv.cleanListB 20285 131072 (fun r => Nat.ble 81140 r) PRE_first_tail_x15_r0_body.s1024
    (PRE_first_tail_x15_r0_body.wrB105 ++ (List.range 15).map (2757832 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs105 : bigsOutB 20285 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK105
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl105`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl105 : List Nat := [2665, 2672570, 2673467, 2757832, 2757833, 2757834, 2757835, 2757836, 2757837, 2757838, 2757839, 2757840, 2757841, 2757842, 2757843, 2757844, 2757845, 2757846]
def PRE_first_tail_x15_r0_body.clo105 : List Nat := [20281, 20282, 20283, 20284]
def PRE_first_tail_x15_r0_body.cln105 : List Nat := [17372, 17373, 17374, 17375, 17376, 17377]
def PRE_first_tail_x15_r0_body.cli105 : List Nat := [17372, 17373, 17374, 17375, 17376, 17377]
kernel_rfl PRE_first_tail_x15_r0_body.cheap105 : PRE_first_tail_x15_r0_body.s1024.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1022.heap (PRE_first_tail_x15_r0_body.cl105.filterMap fun a => (PRE_first_tail_x15_r0_body.s1024.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe105 : Nat.ble PRE_first_tail_x15_r0_body.s1022.next PRE_first_tail_x15_r0_body.s1024.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP105 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1022 PRE_first_tail_x15_r0_body.s1024 PRE_first_tail_x15_r0_body.cl105 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp105 : Conv.suppListB PRE_first_tail_x15_r0_body.s1024 4587 PRE_first_tail_x15_r0_body.cl105 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound105 : Conv.boundListB PRE_first_tail_x15_r0_body.s1024 PRE_first_tail_x15_r0_body.cl105 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK105 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln105.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK105 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo105.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK105 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli105.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst105 : Conv.sstListB 4587 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx PRE_first_tail_x15_r0_body.cln105 PRE_first_tail_x15_r0_body.clo105 PRE_first_tail_x15_r0_body.cli105 = true

end Host.Load.Run.Tpl
end

section -- SiteCl105
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA105 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo105.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd105 : (PRE_first_tail_x15_r0_body.clo105 ++ PRE_first_tail_x15_r0_body.cln105 ++ PRE_first_tail_x15_r0_body.cli105).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle105 : Conv.Cnt.leB (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) (⟨20285, 17378, 2757847, 4587⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck105 : Conv.ncleanListB (⟨20285, 17378, 2757847, 4587⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx PRE_first_tail_x15_r0_body.clo105 PRE_first_tail_x15_r0_body.cln105 PRE_first_tail_x15_r0_body.cli105 = true
theorem PRE_first_tail_x15_r0_body.cncl105 (h : Conv.NClean (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx) : Conv.NClean (⟨20285, 17378, 2757847, 4587⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle105 PRE_first_tail_x15_r0_body.ckA105 PRE_first_tail_x15_r0_body.cobjsK105 PRE_first_tail_x15_r0_body.cnodesK105 PRE_first_tail_x15_r0_body.citemsK105 PRE_first_tail_x15_r0_body.cbd105 PRE_first_tail_x15_r0_body.cck105

end Host.Load.Run.Tpl
end

section -- SiteS105
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 105 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc105 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P105 : LoadP := PRE_first_tail_x15_r0_body.Pc105.raise 17378
kernel_rfl PRE_first_tail_x15_r0_body.craise105 : Nat.ble PRE_first_tail_x15_r0_body.Pc105.N0 17378 = true
theorem PRE_first_tail_x15_r0_body.raised105 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc105 PRE_first_tail_x15_r0_body.P105 :=
  .inr ⟨17378, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise105, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_105 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_105 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1023.ffi)
def PRE_first_tail_x15_r0_body.khinv105 : PTrie Nat := Stage.setAll PTrie.nil [(20283, 20281), (20284, 20282), (20286, 20283), (20285, 20284)]
def PRE_first_tail_x15_r0_body.kninv105 : PTrie Nat := Stage.setAll PTrie.nil [(17372, 17372), (17373, 17373), (17374, 17374), (17375, 17375), (17376, 17376), (17377, 17377)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS105 : List Nat := [20281, 20282, 20283, 20284, 20285, 20286]
def PRE_first_tail_x15_r0_body.cnS105 : List Nat := List.range' 17372 6
def PRE_first_tail_x15_r0_body.ciS105 : List Nat := [] ++ List.range' 17372 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0105 : PRE_first_tail_x15_r0_body.kd105.nh0 = PRE_first_tail_x15_r0_body.cx0_105.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1105 : PRE_first_tail_x15_r0_body.kd105.nh1 = PRE_first_tail_x15_r0_body.cx1_105.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0105 : PRE_first_tail_x15_r0_body.kd105.nn0 = PRE_first_tail_x15_r0_body.cx0_105.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1105 : PRE_first_tail_x15_r0_body.kd105.nn1 = PRE_first_tail_x15_r0_body.cx1_105.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo105 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P105.lo && Nat.ble PRE_first_tail_x15_r0_body.P105.lo PRE_first_tail_x15_r0_body.cx0_105.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P105.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P105.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt105 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_105.mlx.next PRE_first_tail_x15_r0_body.cx1_105.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_105.mlx.nnext PRE_first_tail_x15_r0_body.cx1_105.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband105 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P105.NL && Nat.ble PRE_first_tail_x15_r0_body.P105.NL PRE_first_tail_x15_r0_body.P105.N0 && Nat.ble PRE_first_tail_x15_r0_body.P105.N0 PRE_first_tail_x15_r0_body.cx0_105.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow105 : PRE_first_tail_x15_r0_body.kd105.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren105 : checkRenG PRE_first_tail_x15_r0_body.kd105.hnd PRE_first_tail_x15_r0_body.khinv105 (phB PRE_first_tail_x15_r0_body.cx0_105.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband105 : PRE_first_tail_x15_r0_body.kd105.checkBand PRE_first_tail_x15_r0_body.P105.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos105 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd105.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren105 : checkRenG PRE_first_tail_x15_r0_body.kd105.node PRE_first_tail_x15_r0_body.kninv105 (pnB PRE_first_tail_x15_r0_body.cx0_105.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P105.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd105.nodeF j) PRE_first_tail_x15_r0_body.cx1_105.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a105 : PRE_first_tail_x15_r0_body.cx0_105.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b105 : PRE_first_tail_x15_r0_body.cx0_105.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.pending = PRE_first_tail_x15_r0_body.cx0_105.mlx.pending.map PRE_first_tail_x15_r0_body.kappa105.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.errh = PRE_first_tail_x15_r0_body.cx0_105.mlx.errh.map PRE_first_tail_x15_r0_body.kappa105.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.files = PRE_first_tail_x15_r0_body.cx0_105.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.arch = PRE_first_tail_x15_r0_body.cx0_105.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_105.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.wired = PRE_first_tail_x15_r0_body.cx0_105.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost105 : PRE_first_tail_x15_r0_body.cx1_105.host = PRE_first_tail_x15_r0_body.cx0_105.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd105`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0105 : PRE_first_tail_x15_r0_body.kd105.n0 = 2757847
kernel_rfl PRE_first_tail_x15_r0_body.ckn1105 : PRE_first_tail_x15_r0_body.kd105.n1 = 2758197
kernel_rfl PRE_first_tail_x15_r0_body.ckheap105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.heap).all (fun x => Nat.ble 2757832 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl105 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd105.heap.get (2757832 + j) = nth? PRE_first_tail_x15_r0_body.pl105 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja105 : Nat.ble 2757832 2757832 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn105 : Nat.ble 4578 4578 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD105 : Nat.ble 2757832 PRE_first_tail_x15_r0_body.kd105.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn105 : Nat.ble 20281 PRE_first_tail_x15_r0_body.kd105.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn105 : Nat.ble 17372 PRE_first_tail_x15_r0_body.kd105.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb105 : Nat.ble 20281 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.heap).all (Nat.ble (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.hnd).all (Nat.ble (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.node).all (Nat.ble (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix105 : Conv.FixOld (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa105 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja105) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn105) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD105) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn105) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn105) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb105) PRE_first_tail_x15_r0_body.fheap105 PRE_first_tail_x15_r0_body.fhnd105 PRE_first_tail_x15_r0_body.fnode105
kernel_rfl PRE_first_tail_x15_r0_body.fcxn105 : (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn105 : (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0105 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_105.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_105.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS105.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_105.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS105.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_105.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS105.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_105.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS105.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_105.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd105 : (PRE_first_tail_x15_r0_body.clo105 ++ PRE_first_tail_x15_r0_body.cln105 ++ PRE_first_tail_x15_r0_body.cli105 ++ PRE_first_tail_x15_r0_body.cwS105 ++ PRE_first_tail_x15_r0_body.cnS105 ++ PRE_first_tail_x15_r0_body.ciS105).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW105 : PRE_first_tail_x15_r0_body.cwS105.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo105.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI105 : PRE_first_tail_x15_r0_body.ciS105.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli105.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN105 : PRE_first_tail_x15_r0_body.cnS105.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF105 : PRE_first_tail_x15_r0_body.cln105.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh105 : PRE_first_tail_x15_r0_body.clo105.all (handleOK PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.P105.lo PRE_first_tail_x15_r0_body.cx0_105.mlx PRE_first_tail_x15_r0_body.cx1_105.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo105 : PRE_first_tail_x15_r0_body.clo105.map (fun h => PRE_first_tail_x15_r0_body.cx1_105.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa105.handle h)) = PRE_first_tail_x15_r0_body.clo105.map (fun h => (PRE_first_tail_x15_r0_body.cx0_105.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa105.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok105 : PRE_first_tail_x15_r0_body.clo105.all (objOK PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.P105.NL PRE_first_tail_x15_r0_body.cx0_105.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd105 : PRE_first_tail_x15_r0_body.cln105.all (nodeOKF PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.P105 PRE_first_tail_x15_r0_body.cx0_105.mlx PRE_first_tail_x15_r0_body.cx1_105.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp105 : ((PRE_first_tail_x15_r0_body.cln105.filter (fullB PRE_first_tail_x15_r0_body.P105))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_105.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa105.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln105.filter (fullB PRE_first_tail_x15_r0_body.P105))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_105.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa105.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI105 : incrB PRE_first_tail_x15_r0_body.kd105.nodeF (List.range' 17372 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.node).all (fun k => Nat.ble 17372 k && Nat.blt k 17378) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL105 : (PRE_first_tail_x15_r0_body.cln105.filter (Nat.ble PRE_first_tail_x15_r0_body.P105.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd105.nodeF i) && (Nat.blt i 17378 || Nat.ble PRE_first_tail_x15_r0_body.kd105.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord105 : (PRE_first_tail_x15_r0_body.cln105.filter (Nat.ble PRE_first_tail_x15_r0_body.P105.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd105.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd105.nodeF j) (PRE_first_tail_x15_r0_body.kd105.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow105 PRE_first_tail_x15_r0_body.cnn1105 PRE_first_tail_x15_r0_body.fnordI105 PRE_first_tail_x15_r0_body.fnordK105 PRE_first_tail_x15_r0_body.fnordL105
kernel_rfl PRE_first_tail_x15_r0_body.fi105 : PRE_first_tail_x15_r0_body.cli105.all (pnB PRE_first_tail_x15_r0_body.cx0_105.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii105 : PRE_first_tail_x15_r0_body.cli105.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_105.mlx.items.get (PRE_first_tail_x15_r0_body.kappa105.node k) = (PRE_first_tail_x15_r0_body.cx0_105.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa105.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot105 (clean : Conv.NClean (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P105.NL) (cl : SSt (· < 4587) PRE_first_tail_x15_r0_body.cx0_105.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P105 4587 PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.kd105 PRE_first_tail_x15_r0_body.khinv105 PRE_first_tail_x15_r0_body.kninv105 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx PRE_first_tail_x15_r0_body.cx0_105.mlx PRE_first_tail_x15_r0_body.cx1_105.mlx (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo105 PRE_first_tail_x15_r0_body.cln105 PRE_first_tail_x15_r0_body.cli105 PRE_first_tail_x15_r0_body.cwS105 PRE_first_tail_x15_r0_body.cnS105 PRE_first_tail_x15_r0_body.ciS105 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0105, PRE_first_tail_x15_r0_body.cnh1105, PRE_first_tail_x15_r0_body.cnn0105, PRE_first_tail_x15_r0_body.cnn1105, PRE_first_tail_x15_r0_body.cplo105, PRE_first_tail_x15_r0_body.ccnt105, PRE_first_tail_x15_r0_body.cnband105, PRE_first_tail_x15_r0_body.chbelow105, PRE_first_tail_x15_r0_body.chren105, PRE_first_tail_x15_r0_body.cband105, PRE_first_tail_x15_r0_body.cnh1pos105, PRE_first_tail_x15_r0_body.cnren105, PRE_first_tail_x15_r0_body.cnlow105, PRE_first_tail_x15_r0_body.cabs0a105, PRE_first_tail_x15_r0_body.cabs0b105, PRE_first_tail_x15_r0_body.ctok1105, PRE_first_tail_x15_r0_body.cpend105, PRE_first_tail_x15_r0_body.cerrh105, PRE_first_tail_x15_r0_body.cfiles105, PRE_first_tail_x15_r0_body.carch105, PRE_first_tail_x15_r0_body.csizes105, PRE_first_tail_x15_r0_body.cwired105, PRE_first_tail_x15_r0_body.cfix105, clean, PRE_first_tail_x15_r0_body.fcxn105, PRE_first_tail_x15_r0_body.fcnn105, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0105, PRE_first_tail_x15_r0_body.fnk105, PRE_first_tail_x15_r0_body.ckA105, PRE_first_tail_x15_r0_body.cobjsK105, PRE_first_tail_x15_r0_body.cnodesK105, PRE_first_tail_x15_r0_body.citemsK105, PRE_first_tail_x15_r0_body.f1A105, PRE_first_tail_x15_r0_body.f1O105, PRE_first_tail_x15_r0_body.f1N105, PRE_first_tail_x15_r0_body.f1I105, PRE_first_tail_x15_r0_body.fbd105, PRE_first_tail_x15_r0_body.fincW105, PRE_first_tail_x15_r0_body.fincI105, PRE_first_tail_x15_r0_body.fincN105, PRE_first_tail_x15_r0_body.flnF105, PRE_first_tail_x15_r0_body.fh105, PRE_first_tail_x15_r0_body.fo105, PRE_first_tail_x15_r0_body.fok105, PRE_first_tail_x15_r0_body.fnd105, PRE_first_tail_x15_r0_body.fp105, PRE_first_tail_x15_r0_body.fnord105, PRE_first_tail_x15_r0_body.fi105, PRE_first_tail_x15_r0_body.fii105⟩
theorem PRE_first_tail_x15_r0_body.cnshift105 (clean : Conv.NClean (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P105.NL) (cl : SSt (· < 4587) PRE_first_tail_x15_r0_body.cx0_105.mlx) : NShift PRE_first_tail_x15_r0_body.P105 4587 PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.cx0_105 PRE_first_tail_x15_r0_body.cx1_105 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot105 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost105 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0105 PRE_first_tail_x15_r0_body.ckn1105 PRE_first_tail_x15_r0_body.ckheap105 PRE_first_tail_x15_r0_body.ckpl105)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_105 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1022.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_105 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1022.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_105 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1022.ffi) = some PRE_first_tail_x15_r0_body.fxC_105
kernel_rfl PRE_first_tail_x15_r0_body.okrC_105 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1022.ffi) = some PRE_first_tail_x15_r0_body.krC_105
noncomputable def PRE_first_tail_x15_r0_body.fx0_105 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1024.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_105 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1024.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_105 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1024.ffi) = some PRE_first_tail_x15_r0_body.fx0_105
kernel_rfl PRE_first_tail_x15_r0_body.okr0_105 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1024.ffi) = some PRE_first_tail_x15_r0_body.kr0_105
noncomputable def PRE_first_tail_x15_r0_body.fx1_105 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1023.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_105 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1023.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_105 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1023.ffi) = some PRE_first_tail_x15_r0_body.fx1_105
kernel_rfl PRE_first_tail_x15_r0_body.okr1_105 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1023.ffi) = some PRE_first_tail_x15_r0_body.kr1_105
kernel_rfl PRE_first_tail_x15_r0_body.ff0105 : PRE_first_tail_x15_r0_body.fx0_105 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_105 (PRE_first_tail_x15_r0_body.clo105.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_105.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1105 : PRE_first_tail_x15_r0_body.fx1_105 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_105 (PRE_first_tail_x15_r0_body.cwS105.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_105.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck105 : freedLB PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.cx0_105.mlx PRE_first_tail_x15_r0_body.fx0_105 PRE_first_tail_x15_r0_body.fx1_105 PRE_first_tail_x15_r0_body.clo105 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0105 : PRE_first_tail_x15_r0_body.kr0_105.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_105.flags (PRE_first_tail_x15_r0_body.clo105.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_105.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0105 : PRE_first_tail_x15_r0_body.kr0_105.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_105.targs (PRE_first_tail_x15_r0_body.clo105.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_105.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1105 : PRE_first_tail_x15_r0_body.kr1_105.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_105.flags (PRE_first_tail_x15_r0_body.cwS105.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_105.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1105 : PRE_first_tail_x15_r0_body.kr1_105.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_105.targs (PRE_first_tail_x15_r0_body.cwS105.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_105.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck105 : krecLB PRE_first_tail_x15_r0_body.kappa105 4587 PRE_first_tail_x15_r0_body.cx0_105.mlx PRE_first_tail_x15_r0_body.kr0_105 PRE_first_tail_x15_r0_body.kr1_105 PRE_first_tail_x15_r0_body.clo105 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn105 : Nat.ble 4578 4587 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge105 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1023.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1024.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR105 : pendRegB PRE_first_tail_x15_r0_body.kappa105 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe105 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1023.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift105 (clean : Conv.NClean (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P105.NL) (cl : SSt (· < 4587) PRE_first_tail_x15_r0_body.cx0_105.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_105.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_105.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_105.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_105.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P105 4587 PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.s1024.ffi PRE_first_tail_x15_r0_body.s1023.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift105 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue105, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp105 t ht),
    PRE_first_tail_x15_r0_body.cbridge105,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1024.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1023.ffi) (PRE_first_tail_x15_r0_body.cfoot105 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_105 PRE_first_tail_x15_r0_body.ofx1_105 hobjC PRE_first_tail_x15_r0_body.ff0105 PRE_first_tail_x15_r0_body.ff1105 PRE_first_tail_x15_r0_body.ffck105,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1024.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1023.ffi) (PRE_first_tail_x15_r0_body.cfoot105 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_105 PRE_first_tail_x15_r0_body.okr1_105 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn105) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0105 PRE_first_tail_x15_r0_body.fkt0105 PRE_first_tail_x15_r0_body.fkf1105 PRE_first_tail_x15_r0_body.fkt1105 PRE_first_tail_x15_r0_body.fkck105,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0105 PRE_first_tail_x15_r0_body.cnh1105 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe105) PRE_first_tail_x15_r0_body.cpendR105⟩

end Host.Load.Run.Tpl
end

section -- st105/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st105 0
host_stream_state PRE_first_tail_x15_r0_body.st105 1
host_stream_state PRE_first_tail_x15_r0_body.st105 2
host_stream_state PRE_first_tail_x15_r0_body.st105 3
end Host.Load.Run.Tpl
end

section -- Site105
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 105 of chain `PRE_first_tail_x15_r0_body`: `kvW__g105__g106` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s1022`, the merged state `PRE_first_tail_x15_r0_body.s1023`,
the site template `PRE_first_tail_x15_r0_body.st105` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1024`: the merge.
The footprint's facts are in `SiteF105`, the compaction's in `SiteC105`, `SiteK105`, `SiteNa105`, `SiteNb105`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso105 : PRE_first_tail_x15_r0_body.st105.s0 = { PRE_first_tail_x15_r0_body.s1022 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs105 : List Frame := PRE_first_tail_x15_r0_body.s1022.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_105 : PRE_first_tail_x15_r0_body.S1022.tab.length = 4578
kernel_rfl PRE_first_tail_x15_r0_body.tab0_105 : PRE_first_tail_x15_r0_body.st105.S0.tab = PRE_first_tail_x15_r0_body.S1022.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws105 : List Nat := [2772, 2773, 2774, 2775, 2776, 2777, 2778, 2779, 2780, 2781, 2782, 2783, 2784, 2785, 2786, 2787, 2788]
kernel_rfl PRE_first_tail_x15_r0_body.fresh105 : (PRE_first_tail_x15_r0_body.S1022.tab.all fun e => PRE_first_tail_x15_r0_body.ws105.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1022.oracle.all fun q => PRE_first_tail_x15_r0_body.ws105.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab105 : PRE_first_tail_x15_r0_body.S1023.tab = PRE_first_tail_x15_r0_body.S1022.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws105
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen105 : PRE_first_tail_x15_r0_body.st105.S3.tab.length - PRE_first_tail_x15_r0_body.st105.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged105`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap105 : PRE_first_tail_x15_r0_body.s1023.heap = PRE_first_tail_x15_r0_body.st105.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext105 : PRE_first_tail_x15_r0_body.s1023.next = PRE_first_tail_x15_r0_body.st105.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl105 : PRE_first_tail_x15_r0_body.s1023.ctl = PRE_first_tail_x15_r0_body.st105.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack105 : PRE_first_tail_x15_r0_body.s1023.stack = PRE_first_tail_x15_r0_body.st105.s3.stack ++ PRE_first_tail_x15_r0_body.s1022.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs105 : PRE_first_tail_x15_r0_body.s1023.jobs = PRE_first_tail_x15_r0_body.st105.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi105 : PRE_first_tail_x15_r0_body.s1023.ffi = PRE_first_tail_x15_r0_body.st105.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace105 : PRE_first_tail_x15_r0_body.s1023.trace = PRE_first_tail_x15_r0_body.st105.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores105 : PRE_first_tail_x15_r0_body.s1023.stores = PRE_first_tail_x15_r0_body.st105.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD105
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 105 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived105 : PRE_first_tail_x15_r0_body.nr105.map (fun r => nth? PRE_first_tail_x15_r0_body.st105.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo105 : PRE_first_tail_x15_r0_body.nr105.all (Nat.ble 4578) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj105 : PRE_first_tail_x15_r0_body.cws105.all (fun c => !PRE_first_tail_x15_r0_body.ws105.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ105 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws105 PRE_first_tail_x15_r0_body.crs105 PRE_first_tail_x15_r0_body.ws105

end Host.Load.Run.Tpl
end

section -- st105/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st105`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st105.wrR : List (Nat × Nat) := [(2672570, 2672571)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st105.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st105.s3.heap PRE_first_tail_x15_r0_body.st105.wrR ++ freshOf PRE_first_tail_x15_r0_body.st105.s3.heap PRE_first_tail_x15_r0_body.st105.s0.next PRE_first_tail_x15_r0_body.st105.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st105.wr : List Nat := PRE_first_tail_x15_r0_body.st105.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st105.heapFoot : PRE_first_tail_x15_r0_body.st105.s3.heap = setAll PRE_first_tail_x15_r0_body.st105.s0.heap PRE_first_tail_x15_r0_body.st105.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st105.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st105.s0.next PRE_first_tail_x15_r0_body.st105.s3.next = true
theorem PRE_first_tail_x15_r0_body.st105.grows : PRE_first_tail_x15_r0_body.st105.s0.next ≤ PRE_first_tail_x15_r0_body.st105.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st105.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st105.wh : List Nat := [20281, 20282, 20283, 20284, 20285, 20286]
def PRE_first_tail_x15_r0_body.st105.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st105.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st105.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st105.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st105.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st105.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st105.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st105.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st105.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st105.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF105
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 105 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB105 : nodupT PRE_first_tail_x15_r0_body.st105.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup105 : PRE_first_tail_x15_r0_body.st105.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB105).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB105 : PRE_first_tail_x15_r0_body.st105.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound105 : ∀ b ∈ PRE_first_tail_x15_r0_body.st105.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB105 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr105 := PRE_first_tail_x15_r0_body.st105.s3.trace.take 26
kernel_rfl PRE_first_tail_x15_r0_body.traceEq105 : PRE_first_tail_x15_r0_body.st105.s3.trace = PRE_first_tail_x15_r0_body.trFr105 ++ PRE_first_tail_x15_r0_body.st105.s0.trace
theorem PRE_first_tail_x15_r0_body.trace105 : ∃ fr, PRE_first_tail_x15_r0_body.st105.s3.trace = fr ++ PRE_first_tail_x15_r0_body.st105.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq105⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide105 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB105 : (PRE_first_tail_x15_r0_body.wide105.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st105.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix105 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide105, WFix Map.id (Present PRE_first_tail_x15_r0_body.st105.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB105 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL105
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 105 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1023`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO105 : PRE_first_tail_x15_r0_body.st105.S0.oracle = PRE_first_tail_x15_r0_body.st105.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B105 : PRE_first_tail_x15_r0_body.st105.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st105.s0.next || (PRE_first_tail_x15_r0_body.st105.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot105 : Conv.StageFoot PRE_first_tail_x15_r0_body.st105.wr PRE_first_tail_x15_r0_body.st105.s0 PRE_first_tail_x15_r0_body.st105.s3 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st105.heapFoot PRE_first_tail_x15_r0_body.wrNodup105 PRE_first_tail_x15_r0_body.wrBound105 PRE_first_tail_x15_r0_body.wr0B105 PRE_first_tail_x15_r0_body.st105.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged105 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st105.F.S → PRE_first_tail_x15_r0_body.st105.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st105.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st105.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs105 PRE_first_tail_x15_r0_body.st105.wr PRE_first_tail_x15_r0_body.s1022 PRE_first_tail_x15_r0_body.st105.s3 PRE_first_tail_x15_r0_body.st105.s0
      PRE_first_tail_x15_r0_body.st105.s3.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st105.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1023 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso105 PRE_first_tail_x15_r0_body.stFoot105 PRE_first_tail_x15_r0_body.wrNodup105 PRE_first_tail_x15_r0_body.wrBound105 PRE_first_tail_x15_r0_body.trace105 PRE_first_tail_x15_r0_body.mheap105
    PRE_first_tail_x15_r0_body.mnext105 PRE_first_tail_x15_r0_body.mctl105 PRE_first_tail_x15_r0_body.mstack105 PRE_first_tail_x15_r0_body.mjobs105 PRE_first_tail_x15_r0_body.mffi105 PRE_first_tail_x15_r0_body.mtrace105 PRE_first_tail_x15_r0_body.mstores105 h

def PRE_first_tail_x15_r0_body.arrEl105_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE105_2665 : arrOf PRE_first_tail_x15_r0_body.s1023 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl105_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA105_2665 : isArrB PRE_first_tail_x15_r0_body.s1023 2665 = true
theorem PRE_first_tail_x15_r0_body.arr105_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1023.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl105_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE105_2665 PRE_first_tail_x15_r0_body.arrA105_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN105_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl105_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR105_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl105_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN105_2665

def PRE_first_tail_x15_r0_body.arrEl105_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE105_2673467 : arrOf PRE_first_tail_x15_r0_body.s1023 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl105_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA105_2673467 : isArrB PRE_first_tail_x15_r0_body.s1023 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr105_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1023.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl105_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE105_2673467 PRE_first_tail_x15_r0_body.arrA105_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN105_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl105_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR105_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl105_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN105_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k105 : isArrB PRE_first_tail_x15_r0_body.s1023 4910 = false
theorem PRE_first_tail_x15_r0_body.keep105 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1023 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k105 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr105_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl105_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ105
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 105 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1022`, the merged
state `PRE_first_tail_x15_r0_body.s1023`, the canonical state `PRE_first_tail_x15_r0_body.s1024`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl105 : PRE_first_tail_x15_r0_body.pl105.all (Nat.ble PRE_first_tail_x15_r0_body.s1022.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd105 : nodupT PRE_first_tail_x15_r0_body.pl105 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1105 : Nat.ble PRE_first_tail_x15_r0_body.s1022.next 2758197 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst105 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1022.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn105 : PRE_first_tail_x15_r0_body.s1024.next = PRE_first_tail_x15_r0_body.s1022.next + PRE_first_tail_x15_r0_body.pl105.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn105 : PRE_first_tail_x15_r0_body.s1023.next = 2758197
kernel_rfl PRE_first_tail_x15_r0_body.zgrow105 : Nat.ble PRE_first_tail_x15_r0_body.s1024.next PRE_first_tail_x15_r0_body.s1023.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh105 : PRE_first_tail_x15_r0_body.S1022.tab.all (fun e => PRE_first_tail_x15_r0_body.cws105.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd105 : nodupT PRE_first_tail_x15_r0_body.cws105 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi105 : PRE_first_tail_x15_r0_body.nr105.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1023.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt105 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1022.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg105_2665 : PRE_first_tail_x15_r0_body.s1024.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1024 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk105_2665 : (objOf PRE_first_tail_x15_r0_body.s1024 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm105_2665 : PRE_first_tail_x15_r0_body.s1023.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa105.obj (objOf PRE_first_tail_x15_r0_body.s1024 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1023 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg105_2673467 : PRE_first_tail_x15_r0_body.s1024.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1024 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk105_2673467 : (objOf PRE_first_tail_x15_r0_body.s1024 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm105_2673467 : PRE_first_tail_x15_r0_body.s1023.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa105.obj (objOf PRE_first_tail_x15_r0_body.s1024 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1023 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw105_4910 : (PRE_first_tail_x15_r0_body.s1024.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw105_2673472 : (PRE_first_tail_x15_r0_body.s1024.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw105_2673473 : (PRE_first_tail_x15_r0_body.s1024.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd105 : PRE_first_tail_x15_r0_body.cl105.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr105 : PRE_first_tail_x15_r0_body.st105.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1022.next || PRE_first_tail_x15_r0_body.cl105.contains b) = true
def PRE_first_tail_x15_r0_body.zl105 : List Nat := PRE_first_tail_x15_r0_body.cl105.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE105 : PRE_first_tail_x15_r0_body.zl105.map (fun a => PRE_first_tail_x15_r0_body.s1023.heap.get (PRE_first_tail_x15_r0_body.kappa105.a a)) = PRE_first_tail_x15_r0_body.zl105.map (fun a => (PRE_first_tail_x15_r0_body.s1024.heap.get a).map PRE_first_tail_x15_r0_body.kappa105.hobj)
theorem PRE_first_tail_x15_r0_body.zimg105 : HeapImg PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.s1024 PRE_first_tail_x15_r0_body.s1023 PRE_first_tail_x15_r0_body.zl105 := PRE_first_tail_x15_r0_body.zimgE105
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl105 : PRE_first_tail_x15_r0_body.s1023.ctl = PRE_first_tail_x15_r0_body.kappa105.ctl PRE_first_tail_x15_r0_body.s1024.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack105 : PRE_first_tail_x15_r0_body.s1023.stack = PRE_first_tail_x15_r0_body.s1024.stack.map PRE_first_tail_x15_r0_body.kappa105.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs105 : PRE_first_tail_x15_r0_body.s1023.jobs = PRE_first_tail_x15_r0_body.s1024.jobs.map PRE_first_tail_x15_r0_body.kappa105.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores105 : PRE_first_tail_x15_r0_body.s1023.stores = PRE_first_tail_x15_r0_body.kappa105.stores PRE_first_tail_x15_r0_body.s1024.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots105 : checkRootsSupp PRE_first_tail_x15_r0_body.s1024 4587 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC105 : PRE_first_tail_x15_r0_body.S1022.tab.length + PRE_first_tail_x15_r0_body.cws105.length = 4587
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap105 : PRE_first_tail_x15_r0_body.kappa105 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1022.next 2758197 PRE_first_tail_x15_r0_body.S1022.tab.length PRE_first_tail_x15_r0_body.pl105 (PRE_first_tail_x15_r0_body.nr105.map NumV.ref) PRE_first_tail_x15_r0_body.kd105.big
  PRE_first_tail_x15_r0_body.kd105.region PRE_first_tail_x15_r0_body.kd105.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin105 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1024.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc105 : Conv.jcleanListB (⟨20285, 17378, 2757847, 4587⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1024 PRE_first_tail_x15_r0_body.cl105 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB105 : noBigRootsP (fun i => !Conv.oldBigB (⟨20285, 17378, 2757847, 4587⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1024.trace PRE_first_tail_x15_r0_body.s1024 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm105 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17372 = true
theorem PRE_first_tail_x15_r0_body.cjcl105 (h : Conv.JClean (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1022) : Conv.JClean (⟨20285, 17378, 2757847, 4587⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1024 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle105)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap105 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd105 a ha)) PRE_first_tail_x15_r0_body.zjc105

end Host.Load.Run.Tpl
end

section -- st105/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st105.bodyLast from PRE_first_tail_x15_r0_body.st105.s2 to PRE_first_tail_x15_r0_body.st105.s3 :
  interpS (step PRE_first_tail_x15_r0_body.st105.F PRE_first_tail_x15_r0_body.st105.s2).run PRE_first_tail_x15_r0_body.st105.S2 = some (PRE_first_tail_x15_r0_body.st105.s3, PRE_first_tail_x15_r0_body.st105.S3)
kernel_rfl PRE_first_tail_x15_r0_body.st105.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st105.s2.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st105.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st105.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st105/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st105.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st105.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st105.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st105.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st105.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st105.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st105.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st105.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st105.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st105.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st105.s0 PRE_first_tail_x15_r0_body.st105.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st105.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st105.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st105.s2 PRE_first_tail_x15_r0_body.st105.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st105/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st105.bodyK0F from PRE_first_tail_x15_r0_body.st105.s0 to PRE_first_tail_x15_r0_body.st105.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st105.F (PRE_first_tail_x15_r0_body.st105.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st105.ks 0).getD 0) PRE_first_tail_x15_r0_body.st105.s0 PRE_first_tail_x15_r0_body.st105.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st105.s1, PRE_first_tail_x15_r0_body.st105.S1)
theorem PRE_first_tail_x15_r0_body.st105.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st105.F (PRE_first_tail_x15_r0_body.st105.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st105.ks 0).getD 0) PRE_first_tail_x15_r0_body.st105.s0 PRE_first_tail_x15_r0_body.st105.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st105.s1, PRE_first_tail_x15_r0_body.st105.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st105.bodyOkLN_ok PRE_first_tail_x15_r0_body.st105.bodyK0F
end Host.Load.Run.Tpl
end

section -- st105/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st105.bodyK1F from PRE_first_tail_x15_r0_body.st105.s1 to PRE_first_tail_x15_r0_body.st105.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st105.F (PRE_first_tail_x15_r0_body.st105.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st105.ks 1).getD 0) PRE_first_tail_x15_r0_body.st105.s1 PRE_first_tail_x15_r0_body.st105.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st105.s2, PRE_first_tail_x15_r0_body.st105.S2)
theorem PRE_first_tail_x15_r0_body.st105.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st105.F (PRE_first_tail_x15_r0_body.st105.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st105.ks 1).getD 0) PRE_first_tail_x15_r0_body.st105.s1 PRE_first_tail_x15_r0_body.st105.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st105.s2, PRE_first_tail_x15_r0_body.st105.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st105.bodyOkLN_ok PRE_first_tail_x15_r0_body.st105.bodyK1F
end Host.Load.Run.Tpl
end

section -- st105/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st105.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st105.F (PRE_first_tail_x15_r0_body.st105.bodyOkL bytes rows) 3452 PRE_first_tail_x15_r0_body.st105.s0 PRE_first_tail_x15_r0_body.st105.S0 = some (PRE_first_tail_x15_r0_body.st105.s2, PRE_first_tail_x15_r0_body.st105.S2) :=
  runOk_trans PRE_first_tail_x15_r0_body.st105.F (PRE_first_tail_x15_r0_body.st105.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st105.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st105.ks 1).getD 0) PRE_first_tail_x15_r0_body.st105.s0 PRE_first_tail_x15_r0_body.st105.s1 PRE_first_tail_x15_r0_body.st105.s2 PRE_first_tail_x15_r0_body.st105.S0 PRE_first_tail_x15_r0_body.st105.S1 PRE_first_tail_x15_r0_body.st105.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st105.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st105.bodyK1 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st105.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st105.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st105.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st105.F (PRE_first_tail_x15_r0_body.st105.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st105.s0
  S0 := PRE_first_tail_x15_r0_body.st105.S0
  s1 := PRE_first_tail_x15_r0_body.st105.s2
  S1 := PRE_first_tail_x15_r0_body.st105.S2
  s2 := PRE_first_tail_x15_r0_body.st105.s3
  S2 := PRE_first_tail_x15_r0_body.st105.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st105.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st105.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st105.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st105.bodyHalt
  last := PRE_first_tail_x15_r0_body.st105.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st105.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC106
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 106 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1032` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa106` into the merged state
`PRE_first_tail_x15_r0_body.s1031`. -/

def PRE_first_tail_x15_r0_body.pl106 : List Nat := []
def PRE_first_tail_x15_r0_body.nr106 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd106 : RData :=
  ⟨2758429, 2758431, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20298, 20298, 17388, 17388, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa106 : Map :=
  Conv.Map.compact 2758429 2758431 4610 PRE_first_tail_x15_r0_body.pl106 (PRE_first_tail_x15_r0_body.nr106.map NumV.ref) PRE_first_tail_x15_r0_body.kd106.big
    PRE_first_tail_x15_r0_body.kd106.region PRE_first_tail_x15_r0_body.kd106.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws106 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs106 : List SymE := PRE_first_tail_x15_r0_body.nr106.map fun r => (nth? PRE_first_tail_x15_r0_body.S1031.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta106 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws106 PRE_first_tail_x15_r0_body.crs106
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB106 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab106 : PRE_first_tail_x15_r0_body.S1032.tab = PRE_first_tail_x15_r0_body.S1030.tab ++ PRE_first_tail_x15_r0_body.cws106.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace106 : PRE_first_tail_x15_r0_body.s1032.trace = PRE_first_tail_x15_r0_body.s1030.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext106 : PRE_first_tail_x15_r0_body.s1032.next = 2758429
kernel_rfl PRE_first_tail_x15_r0_body.ccounters106 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.nnext) = (20298, 17388)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue106 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1031.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa106.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp106 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.tokens.all (bSN 4610) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean106 : Conv.cleanListB 20298 131072 (fun r => Nat.ble 81192 r) PRE_first_tail_x15_r0_body.s1032
    (PRE_first_tail_x15_r0_body.wrB106 ++ (List.range 0).map (2758429 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs106 : bigsOutB 20298 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK106
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl106`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl106 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo106 : List Nat := []
def PRE_first_tail_x15_r0_body.cln106 : List Nat := []
def PRE_first_tail_x15_r0_body.cli106 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap106 : PRE_first_tail_x15_r0_body.s1032.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1030.heap (PRE_first_tail_x15_r0_body.cl106.filterMap fun a => (PRE_first_tail_x15_r0_body.s1032.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe106 : Nat.ble PRE_first_tail_x15_r0_body.s1030.next PRE_first_tail_x15_r0_body.s1032.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP106 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1030 PRE_first_tail_x15_r0_body.s1032 PRE_first_tail_x15_r0_body.cl106 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp106 : Conv.suppListB PRE_first_tail_x15_r0_body.s1032 4610 PRE_first_tail_x15_r0_body.cl106 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound106 : Conv.boundListB PRE_first_tail_x15_r0_body.s1032 PRE_first_tail_x15_r0_body.cl106 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK106 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln106.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK106 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo106.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK106 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli106.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst106 : Conv.sstListB 4610 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx PRE_first_tail_x15_r0_body.cln106 PRE_first_tail_x15_r0_body.clo106 PRE_first_tail_x15_r0_body.cli106 = true

end Host.Load.Run.Tpl
end

section -- SiteCl106
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA106 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo106.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd106 : (PRE_first_tail_x15_r0_body.clo106 ++ PRE_first_tail_x15_r0_body.cln106 ++ PRE_first_tail_x15_r0_body.cli106).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle106 : Conv.Cnt.leB (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck106 : Conv.ncleanListB (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx PRE_first_tail_x15_r0_body.clo106 PRE_first_tail_x15_r0_body.cln106 PRE_first_tail_x15_r0_body.cli106 = true
theorem PRE_first_tail_x15_r0_body.cncl106 (h : Conv.NClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx) : Conv.NClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle106 PRE_first_tail_x15_r0_body.ckA106 PRE_first_tail_x15_r0_body.cobjsK106 PRE_first_tail_x15_r0_body.cnodesK106 PRE_first_tail_x15_r0_body.citemsK106 PRE_first_tail_x15_r0_body.cbd106 PRE_first_tail_x15_r0_body.cck106

end Host.Load.Run.Tpl
end

section -- SiteS106
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 106 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc106 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P106 : LoadP := PRE_first_tail_x15_r0_body.Pc106.raise 17388
kernel_rfl PRE_first_tail_x15_r0_body.craise106 : Nat.ble PRE_first_tail_x15_r0_body.Pc106.N0 17388 = true
theorem PRE_first_tail_x15_r0_body.raised106 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc106 PRE_first_tail_x15_r0_body.P106 :=
  .inr ⟨17388, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise106, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_106 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_106 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1031.ffi)
def PRE_first_tail_x15_r0_body.khinv106 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv106 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS106 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS106 : List Nat := List.range' 17388 0
def PRE_first_tail_x15_r0_body.ciS106 : List Nat := [] ++ List.range' 17388 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0106 : PRE_first_tail_x15_r0_body.kd106.nh0 = PRE_first_tail_x15_r0_body.cx0_106.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1106 : PRE_first_tail_x15_r0_body.kd106.nh1 = PRE_first_tail_x15_r0_body.cx1_106.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0106 : PRE_first_tail_x15_r0_body.kd106.nn0 = PRE_first_tail_x15_r0_body.cx0_106.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1106 : PRE_first_tail_x15_r0_body.kd106.nn1 = PRE_first_tail_x15_r0_body.cx1_106.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo106 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P106.lo && Nat.ble PRE_first_tail_x15_r0_body.P106.lo PRE_first_tail_x15_r0_body.cx0_106.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P106.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P106.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt106 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_106.mlx.next PRE_first_tail_x15_r0_body.cx1_106.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_106.mlx.nnext PRE_first_tail_x15_r0_body.cx1_106.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband106 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P106.NL && Nat.ble PRE_first_tail_x15_r0_body.P106.NL PRE_first_tail_x15_r0_body.P106.N0 && Nat.ble PRE_first_tail_x15_r0_body.P106.N0 PRE_first_tail_x15_r0_body.cx0_106.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow106 : PRE_first_tail_x15_r0_body.kd106.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren106 : checkRenG PRE_first_tail_x15_r0_body.kd106.hnd PRE_first_tail_x15_r0_body.khinv106 (phB PRE_first_tail_x15_r0_body.cx0_106.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband106 : PRE_first_tail_x15_r0_body.kd106.checkBand PRE_first_tail_x15_r0_body.P106.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos106 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd106.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren106 : checkRenG PRE_first_tail_x15_r0_body.kd106.node PRE_first_tail_x15_r0_body.kninv106 (pnB PRE_first_tail_x15_r0_body.cx0_106.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P106.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd106.nodeF j) PRE_first_tail_x15_r0_body.cx1_106.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a106 : PRE_first_tail_x15_r0_body.cx0_106.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b106 : PRE_first_tail_x15_r0_body.cx0_106.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.pending = PRE_first_tail_x15_r0_body.cx0_106.mlx.pending.map PRE_first_tail_x15_r0_body.kappa106.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.errh = PRE_first_tail_x15_r0_body.cx0_106.mlx.errh.map PRE_first_tail_x15_r0_body.kappa106.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.files = PRE_first_tail_x15_r0_body.cx0_106.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.arch = PRE_first_tail_x15_r0_body.cx0_106.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_106.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.wired = PRE_first_tail_x15_r0_body.cx0_106.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost106 : PRE_first_tail_x15_r0_body.cx1_106.host = PRE_first_tail_x15_r0_body.cx0_106.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd106`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0106 : PRE_first_tail_x15_r0_body.kd106.n0 = 2758429
kernel_rfl PRE_first_tail_x15_r0_body.ckn1106 : PRE_first_tail_x15_r0_body.kd106.n1 = 2758431
kernel_rfl PRE_first_tail_x15_r0_body.ckheap106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.heap).all (fun x => Nat.ble 2758429 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl106 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd106.heap.get (2758429 + j) = nth? PRE_first_tail_x15_r0_body.pl106 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja106 : Nat.ble 2758429 2758429 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn106 : Nat.ble 4610 4610 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD106 : Nat.ble 2758429 PRE_first_tail_x15_r0_body.kd106.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn106 : Nat.ble 20298 PRE_first_tail_x15_r0_body.kd106.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn106 : Nat.ble 17388 PRE_first_tail_x15_r0_body.kd106.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb106 : Nat.ble 20298 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.heap).all (Nat.ble (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.hnd).all (Nat.ble (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.node).all (Nat.ble (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix106 : Conv.FixOld (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa106 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja106) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn106) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD106) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn106) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn106) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb106) PRE_first_tail_x15_r0_body.fheap106 PRE_first_tail_x15_r0_body.fhnd106 PRE_first_tail_x15_r0_body.fnode106
kernel_rfl PRE_first_tail_x15_r0_body.fcxn106 : (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn106 : (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0106 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_106.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_106.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS106.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_106.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS106.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_106.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS106.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_106.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS106.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_106.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd106 : (PRE_first_tail_x15_r0_body.clo106 ++ PRE_first_tail_x15_r0_body.cln106 ++ PRE_first_tail_x15_r0_body.cli106 ++ PRE_first_tail_x15_r0_body.cwS106 ++ PRE_first_tail_x15_r0_body.cnS106 ++ PRE_first_tail_x15_r0_body.ciS106).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW106 : PRE_first_tail_x15_r0_body.cwS106.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo106.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI106 : PRE_first_tail_x15_r0_body.ciS106.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli106.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN106 : PRE_first_tail_x15_r0_body.cnS106.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF106 : PRE_first_tail_x15_r0_body.cln106.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh106 : PRE_first_tail_x15_r0_body.clo106.all (handleOK PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.P106.lo PRE_first_tail_x15_r0_body.cx0_106.mlx PRE_first_tail_x15_r0_body.cx1_106.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo106 : PRE_first_tail_x15_r0_body.clo106.map (fun h => PRE_first_tail_x15_r0_body.cx1_106.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa106.handle h)) = PRE_first_tail_x15_r0_body.clo106.map (fun h => (PRE_first_tail_x15_r0_body.cx0_106.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa106.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok106 : PRE_first_tail_x15_r0_body.clo106.all (objOK PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.P106.NL PRE_first_tail_x15_r0_body.cx0_106.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd106 : PRE_first_tail_x15_r0_body.cln106.all (nodeOKF PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.P106 PRE_first_tail_x15_r0_body.cx0_106.mlx PRE_first_tail_x15_r0_body.cx1_106.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp106 : ((PRE_first_tail_x15_r0_body.cln106.filter (fullB PRE_first_tail_x15_r0_body.P106))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_106.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa106.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln106.filter (fullB PRE_first_tail_x15_r0_body.P106))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_106.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa106.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI106 : incrB PRE_first_tail_x15_r0_body.kd106.nodeF (List.range' 17388 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.node).all (fun k => Nat.ble 17388 k && Nat.blt k 17388) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL106 : (PRE_first_tail_x15_r0_body.cln106.filter (Nat.ble PRE_first_tail_x15_r0_body.P106.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd106.nodeF i) && (Nat.blt i 17388 || Nat.ble PRE_first_tail_x15_r0_body.kd106.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord106 : (PRE_first_tail_x15_r0_body.cln106.filter (Nat.ble PRE_first_tail_x15_r0_body.P106.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd106.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd106.nodeF j) (PRE_first_tail_x15_r0_body.kd106.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow106 PRE_first_tail_x15_r0_body.cnn1106 PRE_first_tail_x15_r0_body.fnordI106 PRE_first_tail_x15_r0_body.fnordK106 PRE_first_tail_x15_r0_body.fnordL106
kernel_rfl PRE_first_tail_x15_r0_body.fi106 : PRE_first_tail_x15_r0_body.cli106.all (pnB PRE_first_tail_x15_r0_body.cx0_106.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii106 : PRE_first_tail_x15_r0_body.cli106.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_106.mlx.items.get (PRE_first_tail_x15_r0_body.kappa106.node k) = (PRE_first_tail_x15_r0_body.cx0_106.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa106.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot106 (clean : Conv.NClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P106.NL) (cl : SSt (· < 4610) PRE_first_tail_x15_r0_body.cx0_106.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P106 4610 PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.kd106 PRE_first_tail_x15_r0_body.khinv106 PRE_first_tail_x15_r0_body.kninv106 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx PRE_first_tail_x15_r0_body.cx0_106.mlx PRE_first_tail_x15_r0_body.cx1_106.mlx (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo106 PRE_first_tail_x15_r0_body.cln106 PRE_first_tail_x15_r0_body.cli106 PRE_first_tail_x15_r0_body.cwS106 PRE_first_tail_x15_r0_body.cnS106 PRE_first_tail_x15_r0_body.ciS106 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0106, PRE_first_tail_x15_r0_body.cnh1106, PRE_first_tail_x15_r0_body.cnn0106, PRE_first_tail_x15_r0_body.cnn1106, PRE_first_tail_x15_r0_body.cplo106, PRE_first_tail_x15_r0_body.ccnt106, PRE_first_tail_x15_r0_body.cnband106, PRE_first_tail_x15_r0_body.chbelow106, PRE_first_tail_x15_r0_body.chren106, PRE_first_tail_x15_r0_body.cband106, PRE_first_tail_x15_r0_body.cnh1pos106, PRE_first_tail_x15_r0_body.cnren106, PRE_first_tail_x15_r0_body.cnlow106, PRE_first_tail_x15_r0_body.cabs0a106, PRE_first_tail_x15_r0_body.cabs0b106, PRE_first_tail_x15_r0_body.ctok1106, PRE_first_tail_x15_r0_body.cpend106, PRE_first_tail_x15_r0_body.cerrh106, PRE_first_tail_x15_r0_body.cfiles106, PRE_first_tail_x15_r0_body.carch106, PRE_first_tail_x15_r0_body.csizes106, PRE_first_tail_x15_r0_body.cwired106, PRE_first_tail_x15_r0_body.cfix106, clean, PRE_first_tail_x15_r0_body.fcxn106, PRE_first_tail_x15_r0_body.fcnn106, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0106, PRE_first_tail_x15_r0_body.fnk106, PRE_first_tail_x15_r0_body.ckA106, PRE_first_tail_x15_r0_body.cobjsK106, PRE_first_tail_x15_r0_body.cnodesK106, PRE_first_tail_x15_r0_body.citemsK106, PRE_first_tail_x15_r0_body.f1A106, PRE_first_tail_x15_r0_body.f1O106, PRE_first_tail_x15_r0_body.f1N106, PRE_first_tail_x15_r0_body.f1I106, PRE_first_tail_x15_r0_body.fbd106, PRE_first_tail_x15_r0_body.fincW106, PRE_first_tail_x15_r0_body.fincI106, PRE_first_tail_x15_r0_body.fincN106, PRE_first_tail_x15_r0_body.flnF106, PRE_first_tail_x15_r0_body.fh106, PRE_first_tail_x15_r0_body.fo106, PRE_first_tail_x15_r0_body.fok106, PRE_first_tail_x15_r0_body.fnd106, PRE_first_tail_x15_r0_body.fp106, PRE_first_tail_x15_r0_body.fnord106, PRE_first_tail_x15_r0_body.fi106, PRE_first_tail_x15_r0_body.fii106⟩
theorem PRE_first_tail_x15_r0_body.cnshift106 (clean : Conv.NClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P106.NL) (cl : SSt (· < 4610) PRE_first_tail_x15_r0_body.cx0_106.mlx) : NShift PRE_first_tail_x15_r0_body.P106 4610 PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.cx0_106 PRE_first_tail_x15_r0_body.cx1_106 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot106 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost106 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0106 PRE_first_tail_x15_r0_body.ckn1106 PRE_first_tail_x15_r0_body.ckheap106 PRE_first_tail_x15_r0_body.ckpl106)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_106 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1030.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_106 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1030.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_106 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1030.ffi) = some PRE_first_tail_x15_r0_body.fxC_106
kernel_rfl PRE_first_tail_x15_r0_body.okrC_106 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1030.ffi) = some PRE_first_tail_x15_r0_body.krC_106
noncomputable def PRE_first_tail_x15_r0_body.fx0_106 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1032.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_106 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1032.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_106 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1032.ffi) = some PRE_first_tail_x15_r0_body.fx0_106
kernel_rfl PRE_first_tail_x15_r0_body.okr0_106 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1032.ffi) = some PRE_first_tail_x15_r0_body.kr0_106
noncomputable def PRE_first_tail_x15_r0_body.fx1_106 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1031.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_106 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1031.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_106 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1031.ffi) = some PRE_first_tail_x15_r0_body.fx1_106
kernel_rfl PRE_first_tail_x15_r0_body.okr1_106 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1031.ffi) = some PRE_first_tail_x15_r0_body.kr1_106
kernel_rfl PRE_first_tail_x15_r0_body.ff0106 : PRE_first_tail_x15_r0_body.fx0_106 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_106 (PRE_first_tail_x15_r0_body.clo106.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_106.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1106 : PRE_first_tail_x15_r0_body.fx1_106 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_106 (PRE_first_tail_x15_r0_body.cwS106.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_106.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck106 : freedLB PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.cx0_106.mlx PRE_first_tail_x15_r0_body.fx0_106 PRE_first_tail_x15_r0_body.fx1_106 PRE_first_tail_x15_r0_body.clo106 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0106 : PRE_first_tail_x15_r0_body.kr0_106.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_106.flags (PRE_first_tail_x15_r0_body.clo106.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_106.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0106 : PRE_first_tail_x15_r0_body.kr0_106.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_106.targs (PRE_first_tail_x15_r0_body.clo106.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_106.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1106 : PRE_first_tail_x15_r0_body.kr1_106.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_106.flags (PRE_first_tail_x15_r0_body.cwS106.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_106.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1106 : PRE_first_tail_x15_r0_body.kr1_106.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_106.targs (PRE_first_tail_x15_r0_body.cwS106.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_106.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck106 : krecLB PRE_first_tail_x15_r0_body.kappa106 4610 PRE_first_tail_x15_r0_body.cx0_106.mlx PRE_first_tail_x15_r0_body.kr0_106 PRE_first_tail_x15_r0_body.kr1_106 PRE_first_tail_x15_r0_body.clo106 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn106 : Nat.ble 4610 4610 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge106 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1031.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1032.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR106 : pendRegB PRE_first_tail_x15_r0_body.kappa106 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe106 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1031.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift106 (clean : Conv.NClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P106.NL) (cl : SSt (· < 4610) PRE_first_tail_x15_r0_body.cx0_106.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_106.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_106.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_106.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_106.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P106 4610 PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.s1032.ffi PRE_first_tail_x15_r0_body.s1031.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift106 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue106, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp106 t ht),
    PRE_first_tail_x15_r0_body.cbridge106,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1032.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1031.ffi) (PRE_first_tail_x15_r0_body.cfoot106 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_106 PRE_first_tail_x15_r0_body.ofx1_106 hobjC PRE_first_tail_x15_r0_body.ff0106 PRE_first_tail_x15_r0_body.ff1106 PRE_first_tail_x15_r0_body.ffck106,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1032.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1031.ffi) (PRE_first_tail_x15_r0_body.cfoot106 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_106 PRE_first_tail_x15_r0_body.okr1_106 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn106) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0106 PRE_first_tail_x15_r0_body.fkt0106 PRE_first_tail_x15_r0_body.fkf1106 PRE_first_tail_x15_r0_body.fkt1106 PRE_first_tail_x15_r0_body.fkck106,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0106 PRE_first_tail_x15_r0_body.cnh1106 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe106) PRE_first_tail_x15_r0_body.cpendR106⟩

end Host.Load.Run.Tpl
end

section -- st106/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st106 0
host_stream_state PRE_first_tail_x15_r0_body.st106 1
host_stream_state PRE_first_tail_x15_r0_body.st106 2
end Host.Load.Run.Tpl
end

section -- Site106
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 106 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g106__g107` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1030`, the merged state `PRE_first_tail_x15_r0_body.s1031`,
the site template `PRE_first_tail_x15_r0_body.st106` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1032`: the merge.
The footprint's facts are in `SiteF106`, the compaction's in `SiteC106`, `SiteK106`, `SiteNa106`, `SiteNb106`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso106 : PRE_first_tail_x15_r0_body.st106.s0 = { PRE_first_tail_x15_r0_body.s1030 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs106 : List Frame := PRE_first_tail_x15_r0_body.s1030.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_106 : PRE_first_tail_x15_r0_body.S1030.tab.length = 4610
kernel_rfl PRE_first_tail_x15_r0_body.tab0_106 : PRE_first_tail_x15_r0_body.st106.S0.tab = PRE_first_tail_x15_r0_body.S1030.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws106 : List Nat := [2798, 2799]
kernel_rfl PRE_first_tail_x15_r0_body.fresh106 : (PRE_first_tail_x15_r0_body.S1030.tab.all fun e => PRE_first_tail_x15_r0_body.ws106.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1030.oracle.all fun q => PRE_first_tail_x15_r0_body.ws106.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab106 : PRE_first_tail_x15_r0_body.S1031.tab = PRE_first_tail_x15_r0_body.S1030.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws106
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen106 : PRE_first_tail_x15_r0_body.st106.S2.tab.length - PRE_first_tail_x15_r0_body.st106.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged106`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap106 : PRE_first_tail_x15_r0_body.s1031.heap = PRE_first_tail_x15_r0_body.st106.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext106 : PRE_first_tail_x15_r0_body.s1031.next = PRE_first_tail_x15_r0_body.st106.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl106 : PRE_first_tail_x15_r0_body.s1031.ctl = PRE_first_tail_x15_r0_body.st106.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack106 : PRE_first_tail_x15_r0_body.s1031.stack = PRE_first_tail_x15_r0_body.st106.s2.stack ++ PRE_first_tail_x15_r0_body.s1030.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs106 : PRE_first_tail_x15_r0_body.s1031.jobs = PRE_first_tail_x15_r0_body.st106.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi106 : PRE_first_tail_x15_r0_body.s1031.ffi = PRE_first_tail_x15_r0_body.st106.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace106 : PRE_first_tail_x15_r0_body.s1031.trace = PRE_first_tail_x15_r0_body.st106.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores106 : PRE_first_tail_x15_r0_body.s1031.stores = PRE_first_tail_x15_r0_body.st106.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD106
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 106 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived106 : PRE_first_tail_x15_r0_body.nr106.map (fun r => nth? PRE_first_tail_x15_r0_body.st106.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo106 : PRE_first_tail_x15_r0_body.nr106.all (Nat.ble 4610) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj106 : PRE_first_tail_x15_r0_body.cws106.all (fun c => !PRE_first_tail_x15_r0_body.ws106.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ106 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws106 PRE_first_tail_x15_r0_body.crs106 PRE_first_tail_x15_r0_body.ws106

end Host.Load.Run.Tpl
end

section -- st106/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st106`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st106.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st106.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st106.s2.heap PRE_first_tail_x15_r0_body.st106.wrR ++ freshOf PRE_first_tail_x15_r0_body.st106.s2.heap PRE_first_tail_x15_r0_body.st106.s0.next PRE_first_tail_x15_r0_body.st106.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st106.wr : List Nat := PRE_first_tail_x15_r0_body.st106.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st106.heapFoot : PRE_first_tail_x15_r0_body.st106.s2.heap = setAll PRE_first_tail_x15_r0_body.st106.s0.heap PRE_first_tail_x15_r0_body.st106.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st106.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st106.s0.next PRE_first_tail_x15_r0_body.st106.s2.next = true
theorem PRE_first_tail_x15_r0_body.st106.grows : PRE_first_tail_x15_r0_body.st106.s0.next ≤ PRE_first_tail_x15_r0_body.st106.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st106.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st106.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st106.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st106.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st106.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st106.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st106.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st106.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st106.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st106.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st106.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st106.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF106
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 106 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB106 : nodupT PRE_first_tail_x15_r0_body.st106.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup106 : PRE_first_tail_x15_r0_body.st106.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB106).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB106 : PRE_first_tail_x15_r0_body.st106.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound106 : ∀ b ∈ PRE_first_tail_x15_r0_body.st106.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB106 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr106 := PRE_first_tail_x15_r0_body.st106.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq106 : PRE_first_tail_x15_r0_body.st106.s2.trace = PRE_first_tail_x15_r0_body.trFr106 ++ PRE_first_tail_x15_r0_body.st106.s0.trace
theorem PRE_first_tail_x15_r0_body.trace106 : ∃ fr, PRE_first_tail_x15_r0_body.st106.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st106.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq106⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide106 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB106 : (PRE_first_tail_x15_r0_body.wide106.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st106.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix106 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide106, WFix Map.id (Present PRE_first_tail_x15_r0_body.st106.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB106 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL106
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 106 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1031`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO106 : PRE_first_tail_x15_r0_body.st106.S0.oracle = PRE_first_tail_x15_r0_body.st106.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B106 : PRE_first_tail_x15_r0_body.st106.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st106.s0.next || (PRE_first_tail_x15_r0_body.st106.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot106 : Conv.StageFoot PRE_first_tail_x15_r0_body.st106.wr PRE_first_tail_x15_r0_body.st106.s0 PRE_first_tail_x15_r0_body.st106.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st106.heapFoot PRE_first_tail_x15_r0_body.wrNodup106 PRE_first_tail_x15_r0_body.wrBound106 PRE_first_tail_x15_r0_body.wr0B106 PRE_first_tail_x15_r0_body.st106.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged106 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st106.F.S → PRE_first_tail_x15_r0_body.st106.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st106.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st106.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs106 PRE_first_tail_x15_r0_body.st106.wr PRE_first_tail_x15_r0_body.s1030 PRE_first_tail_x15_r0_body.st106.s2 PRE_first_tail_x15_r0_body.st106.s0
      PRE_first_tail_x15_r0_body.st106.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st106.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1031 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso106 PRE_first_tail_x15_r0_body.stFoot106 PRE_first_tail_x15_r0_body.wrNodup106 PRE_first_tail_x15_r0_body.wrBound106 PRE_first_tail_x15_r0_body.trace106 PRE_first_tail_x15_r0_body.mheap106
    PRE_first_tail_x15_r0_body.mnext106 PRE_first_tail_x15_r0_body.mctl106 PRE_first_tail_x15_r0_body.mstack106 PRE_first_tail_x15_r0_body.mjobs106 PRE_first_tail_x15_r0_body.mffi106 PRE_first_tail_x15_r0_body.mtrace106 PRE_first_tail_x15_r0_body.mstores106 h

def PRE_first_tail_x15_r0_body.arrEl106_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE106_2665 : arrOf PRE_first_tail_x15_r0_body.s1031 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl106_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA106_2665 : isArrB PRE_first_tail_x15_r0_body.s1031 2665 = true
theorem PRE_first_tail_x15_r0_body.arr106_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1031.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl106_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE106_2665 PRE_first_tail_x15_r0_body.arrA106_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN106_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl106_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR106_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl106_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN106_2665

def PRE_first_tail_x15_r0_body.arrEl106_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE106_2673467 : arrOf PRE_first_tail_x15_r0_body.s1031 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl106_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA106_2673467 : isArrB PRE_first_tail_x15_r0_body.s1031 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr106_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1031.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl106_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE106_2673467 PRE_first_tail_x15_r0_body.arrA106_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN106_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl106_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR106_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl106_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN106_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k106 : isArrB PRE_first_tail_x15_r0_body.s1031 4910 = false
theorem PRE_first_tail_x15_r0_body.keep106 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1031 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k106 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr106_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl106_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ106
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 106 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1030`, the merged
state `PRE_first_tail_x15_r0_body.s1031`, the canonical state `PRE_first_tail_x15_r0_body.s1032`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl106 : PRE_first_tail_x15_r0_body.pl106.all (Nat.ble PRE_first_tail_x15_r0_body.s1030.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd106 : nodupT PRE_first_tail_x15_r0_body.pl106 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1106 : Nat.ble PRE_first_tail_x15_r0_body.s1030.next 2758431 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst106 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1030.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn106 : PRE_first_tail_x15_r0_body.s1032.next = PRE_first_tail_x15_r0_body.s1030.next + PRE_first_tail_x15_r0_body.pl106.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn106 : PRE_first_tail_x15_r0_body.s1031.next = 2758431
kernel_rfl PRE_first_tail_x15_r0_body.zgrow106 : Nat.ble PRE_first_tail_x15_r0_body.s1032.next PRE_first_tail_x15_r0_body.s1031.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh106 : PRE_first_tail_x15_r0_body.S1030.tab.all (fun e => PRE_first_tail_x15_r0_body.cws106.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd106 : nodupT PRE_first_tail_x15_r0_body.cws106 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi106 : PRE_first_tail_x15_r0_body.nr106.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1031.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt106 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1030.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg106_2665 : PRE_first_tail_x15_r0_body.s1032.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1032 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk106_2665 : (objOf PRE_first_tail_x15_r0_body.s1032 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm106_2665 : PRE_first_tail_x15_r0_body.s1031.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa106.obj (objOf PRE_first_tail_x15_r0_body.s1032 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1031 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg106_2673467 : PRE_first_tail_x15_r0_body.s1032.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1032 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk106_2673467 : (objOf PRE_first_tail_x15_r0_body.s1032 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm106_2673467 : PRE_first_tail_x15_r0_body.s1031.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa106.obj (objOf PRE_first_tail_x15_r0_body.s1032 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1031 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw106_4910 : (PRE_first_tail_x15_r0_body.s1032.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw106_2673472 : (PRE_first_tail_x15_r0_body.s1032.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw106_2673473 : (PRE_first_tail_x15_r0_body.s1032.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd106 : PRE_first_tail_x15_r0_body.cl106.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr106 : PRE_first_tail_x15_r0_body.st106.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1030.next || PRE_first_tail_x15_r0_body.cl106.contains b) = true
def PRE_first_tail_x15_r0_body.zl106 : List Nat := PRE_first_tail_x15_r0_body.cl106.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE106 : PRE_first_tail_x15_r0_body.zl106.map (fun a => PRE_first_tail_x15_r0_body.s1031.heap.get (PRE_first_tail_x15_r0_body.kappa106.a a)) = PRE_first_tail_x15_r0_body.zl106.map (fun a => (PRE_first_tail_x15_r0_body.s1032.heap.get a).map PRE_first_tail_x15_r0_body.kappa106.hobj)
theorem PRE_first_tail_x15_r0_body.zimg106 : HeapImg PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.s1032 PRE_first_tail_x15_r0_body.s1031 PRE_first_tail_x15_r0_body.zl106 := PRE_first_tail_x15_r0_body.zimgE106
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl106 : PRE_first_tail_x15_r0_body.s1031.ctl = PRE_first_tail_x15_r0_body.kappa106.ctl PRE_first_tail_x15_r0_body.s1032.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack106 : PRE_first_tail_x15_r0_body.s1031.stack = PRE_first_tail_x15_r0_body.s1032.stack.map PRE_first_tail_x15_r0_body.kappa106.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs106 : PRE_first_tail_x15_r0_body.s1031.jobs = PRE_first_tail_x15_r0_body.s1032.jobs.map PRE_first_tail_x15_r0_body.kappa106.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores106 : PRE_first_tail_x15_r0_body.s1031.stores = PRE_first_tail_x15_r0_body.kappa106.stores PRE_first_tail_x15_r0_body.s1032.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots106 : checkRootsSupp PRE_first_tail_x15_r0_body.s1032 4610 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC106 : PRE_first_tail_x15_r0_body.S1030.tab.length + PRE_first_tail_x15_r0_body.cws106.length = 4610
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap106 : PRE_first_tail_x15_r0_body.kappa106 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1030.next 2758431 PRE_first_tail_x15_r0_body.S1030.tab.length PRE_first_tail_x15_r0_body.pl106 (PRE_first_tail_x15_r0_body.nr106.map NumV.ref) PRE_first_tail_x15_r0_body.kd106.big
  PRE_first_tail_x15_r0_body.kd106.region PRE_first_tail_x15_r0_body.kd106.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin106 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1032.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc106 : Conv.jcleanListB (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1032 PRE_first_tail_x15_r0_body.cl106 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB106 : noBigRootsP (fun i => !Conv.oldBigB (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1032.trace PRE_first_tail_x15_r0_body.s1032 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm106 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17388 = true
theorem PRE_first_tail_x15_r0_body.cjcl106 (h : Conv.JClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1030) : Conv.JClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1032 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle106)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap106 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd106 a ha)) PRE_first_tail_x15_r0_body.zjc106

end Host.Load.Run.Tpl
end

section -- st106/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st106.bodyLast from PRE_first_tail_x15_r0_body.st106.s1 to PRE_first_tail_x15_r0_body.st106.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st106.F PRE_first_tail_x15_r0_body.st106.s1).run PRE_first_tail_x15_r0_body.st106.S1 = some (PRE_first_tail_x15_r0_body.st106.s2, PRE_first_tail_x15_r0_body.st106.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st106.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st106.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st106.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st106.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st106/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st106.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st106.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st106.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st106.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st106.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st106.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st106.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st106.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st106.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st106.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st106.s0 PRE_first_tail_x15_r0_body.st106.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st106.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st106.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st106.s1 PRE_first_tail_x15_r0_body.st106.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st106/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st106.bodyK0F from PRE_first_tail_x15_r0_body.st106.s0 to PRE_first_tail_x15_r0_body.st106.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st106.F (PRE_first_tail_x15_r0_body.st106.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st106.ks 0).getD 0) PRE_first_tail_x15_r0_body.st106.s0 PRE_first_tail_x15_r0_body.st106.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st106.s1, PRE_first_tail_x15_r0_body.st106.S1)
theorem PRE_first_tail_x15_r0_body.st106.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st106.F (PRE_first_tail_x15_r0_body.st106.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st106.ks 0).getD 0) PRE_first_tail_x15_r0_body.st106.s0 PRE_first_tail_x15_r0_body.st106.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st106.s1, PRE_first_tail_x15_r0_body.st106.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st106.bodyOkLN_ok PRE_first_tail_x15_r0_body.st106.bodyK0F
end Host.Load.Run.Tpl
end

section -- st106/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st106.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st106.F (PRE_first_tail_x15_r0_body.st106.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st106.s0 PRE_first_tail_x15_r0_body.st106.S0 = some (PRE_first_tail_x15_r0_body.st106.s1, PRE_first_tail_x15_r0_body.st106.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st106.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st106.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st106.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st106.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st106.F (PRE_first_tail_x15_r0_body.st106.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st106.s0
  S0 := PRE_first_tail_x15_r0_body.st106.S0
  s1 := PRE_first_tail_x15_r0_body.st106.s1
  S1 := PRE_first_tail_x15_r0_body.st106.S1
  s2 := PRE_first_tail_x15_r0_body.st106.s2
  S2 := PRE_first_tail_x15_r0_body.st106.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st106.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st106.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st106.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st106.bodyHalt
  last := PRE_first_tail_x15_r0_body.st106.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st106.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC107
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 107 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1036` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa107` into the merged state
`PRE_first_tail_x15_r0_body.s1035`. -/

def PRE_first_tail_x15_r0_body.pl107 : List Nat := [2758727]
def PRE_first_tail_x15_r0_body.nr107 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd107 : RData :=
  ⟨2758718, 2758728, Stage.setAll PTrie.nil [(2758717, 2758727)], Stage.setAll PTrie.nil [],
   20305, 20305, 17392, 17392, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa107 : Map :=
  Conv.Map.compact 2758717 2758728 4627 PRE_first_tail_x15_r0_body.pl107 (PRE_first_tail_x15_r0_body.nr107.map NumV.ref) PRE_first_tail_x15_r0_body.kd107.big
    PRE_first_tail_x15_r0_body.kd107.region PRE_first_tail_x15_r0_body.kd107.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws107 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs107 : List SymE := PRE_first_tail_x15_r0_body.nr107.map fun r => (nth? PRE_first_tail_x15_r0_body.S1035.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta107 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws107 PRE_first_tail_x15_r0_body.crs107
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB107 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab107 : PRE_first_tail_x15_r0_body.S1036.tab = PRE_first_tail_x15_r0_body.S1034.tab ++ PRE_first_tail_x15_r0_body.cws107.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace107 : PRE_first_tail_x15_r0_body.s1036.trace = PRE_first_tail_x15_r0_body.s1034.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext107 : PRE_first_tail_x15_r0_body.s1036.next = 2758718
kernel_rfl PRE_first_tail_x15_r0_body.ccounters107 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.nnext) = (20305, 17392)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue107 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1035.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa107.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp107 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.tokens.all (bSN 4627) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean107 : Conv.cleanListB 20305 131072 (fun r => Nat.ble 81220 r) PRE_first_tail_x15_r0_body.s1036
    (PRE_first_tail_x15_r0_body.wrB107 ++ (List.range 1).map (2758717 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs107 : bigsOutB 20305 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK107
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl107`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl107 : List Nat := [2665, 2673467, 2758717]
def PRE_first_tail_x15_r0_body.clo107 : List Nat := []
def PRE_first_tail_x15_r0_body.cln107 : List Nat := []
def PRE_first_tail_x15_r0_body.cli107 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap107 : PRE_first_tail_x15_r0_body.s1036.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1034.heap (PRE_first_tail_x15_r0_body.cl107.filterMap fun a => (PRE_first_tail_x15_r0_body.s1036.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe107 : Nat.ble PRE_first_tail_x15_r0_body.s1034.next PRE_first_tail_x15_r0_body.s1036.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP107 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1034 PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.cl107 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp107 : Conv.suppListB PRE_first_tail_x15_r0_body.s1036 4627 PRE_first_tail_x15_r0_body.cl107 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound107 : Conv.boundListB PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.cl107 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK107 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln107.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK107 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo107.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK107 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli107.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst107 : Conv.sstListB 4627 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx PRE_first_tail_x15_r0_body.cln107 PRE_first_tail_x15_r0_body.clo107 PRE_first_tail_x15_r0_body.cli107 = true

end Host.Load.Run.Tpl
end

section -- SiteCl107
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA107 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo107.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd107 : (PRE_first_tail_x15_r0_body.clo107 ++ PRE_first_tail_x15_r0_body.cln107 ++ PRE_first_tail_x15_r0_body.cli107).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle107 : Conv.Cnt.leB (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) (⟨20305, 17392, 2758718, 4627⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck107 : Conv.ncleanListB (⟨20305, 17392, 2758718, 4627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx PRE_first_tail_x15_r0_body.clo107 PRE_first_tail_x15_r0_body.cln107 PRE_first_tail_x15_r0_body.cli107 = true
theorem PRE_first_tail_x15_r0_body.cncl107 (h : Conv.NClean (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx) : Conv.NClean (⟨20305, 17392, 2758718, 4627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle107 PRE_first_tail_x15_r0_body.ckA107 PRE_first_tail_x15_r0_body.cobjsK107 PRE_first_tail_x15_r0_body.cnodesK107 PRE_first_tail_x15_r0_body.citemsK107 PRE_first_tail_x15_r0_body.cbd107 PRE_first_tail_x15_r0_body.cck107

end Host.Load.Run.Tpl
end

section -- SiteS107
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 107 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc107 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P107 : LoadP := PRE_first_tail_x15_r0_body.Pc107.raise 17392
kernel_rfl PRE_first_tail_x15_r0_body.craise107 : Nat.ble PRE_first_tail_x15_r0_body.Pc107.N0 17392 = true
theorem PRE_first_tail_x15_r0_body.raised107 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc107 PRE_first_tail_x15_r0_body.P107 :=
  .inr ⟨17392, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise107, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_107 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_107 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1035.ffi)
def PRE_first_tail_x15_r0_body.khinv107 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv107 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS107 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS107 : List Nat := List.range' 17392 0
def PRE_first_tail_x15_r0_body.ciS107 : List Nat := [] ++ List.range' 17392 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0107 : PRE_first_tail_x15_r0_body.kd107.nh0 = PRE_first_tail_x15_r0_body.cx0_107.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1107 : PRE_first_tail_x15_r0_body.kd107.nh1 = PRE_first_tail_x15_r0_body.cx1_107.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0107 : PRE_first_tail_x15_r0_body.kd107.nn0 = PRE_first_tail_x15_r0_body.cx0_107.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1107 : PRE_first_tail_x15_r0_body.kd107.nn1 = PRE_first_tail_x15_r0_body.cx1_107.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo107 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P107.lo && Nat.ble PRE_first_tail_x15_r0_body.P107.lo PRE_first_tail_x15_r0_body.cx0_107.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P107.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P107.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt107 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_107.mlx.next PRE_first_tail_x15_r0_body.cx1_107.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_107.mlx.nnext PRE_first_tail_x15_r0_body.cx1_107.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband107 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P107.NL && Nat.ble PRE_first_tail_x15_r0_body.P107.NL PRE_first_tail_x15_r0_body.P107.N0 && Nat.ble PRE_first_tail_x15_r0_body.P107.N0 PRE_first_tail_x15_r0_body.cx0_107.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow107 : PRE_first_tail_x15_r0_body.kd107.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren107 : checkRenG PRE_first_tail_x15_r0_body.kd107.hnd PRE_first_tail_x15_r0_body.khinv107 (phB PRE_first_tail_x15_r0_body.cx0_107.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband107 : PRE_first_tail_x15_r0_body.kd107.checkBand PRE_first_tail_x15_r0_body.P107.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos107 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd107.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren107 : checkRenG PRE_first_tail_x15_r0_body.kd107.node PRE_first_tail_x15_r0_body.kninv107 (pnB PRE_first_tail_x15_r0_body.cx0_107.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P107.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd107.nodeF j) PRE_first_tail_x15_r0_body.cx1_107.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a107 : PRE_first_tail_x15_r0_body.cx0_107.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b107 : PRE_first_tail_x15_r0_body.cx0_107.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.pending = PRE_first_tail_x15_r0_body.cx0_107.mlx.pending.map PRE_first_tail_x15_r0_body.kappa107.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.errh = PRE_first_tail_x15_r0_body.cx0_107.mlx.errh.map PRE_first_tail_x15_r0_body.kappa107.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.files = PRE_first_tail_x15_r0_body.cx0_107.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.arch = PRE_first_tail_x15_r0_body.cx0_107.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_107.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.wired = PRE_first_tail_x15_r0_body.cx0_107.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost107 : PRE_first_tail_x15_r0_body.cx1_107.host = PRE_first_tail_x15_r0_body.cx0_107.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd107`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0107 : PRE_first_tail_x15_r0_body.kd107.n0 = 2758718
kernel_rfl PRE_first_tail_x15_r0_body.ckn1107 : PRE_first_tail_x15_r0_body.kd107.n1 = 2758728
kernel_rfl PRE_first_tail_x15_r0_body.ckheap107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.heap).all (fun x => Nat.ble 2758717 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl107 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd107.heap.get (2758717 + j) = nth? PRE_first_tail_x15_r0_body.pl107 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja107 : Nat.ble 2758717 2758717 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn107 : Nat.ble 4627 4627 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD107 : Nat.ble 2758717 PRE_first_tail_x15_r0_body.kd107.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn107 : Nat.ble 20305 PRE_first_tail_x15_r0_body.kd107.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn107 : Nat.ble 17392 PRE_first_tail_x15_r0_body.kd107.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb107 : Nat.ble 20305 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.heap).all (Nat.ble (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.hnd).all (Nat.ble (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.node).all (Nat.ble (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix107 : Conv.FixOld (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa107 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja107) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn107) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD107) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn107) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn107) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb107) PRE_first_tail_x15_r0_body.fheap107 PRE_first_tail_x15_r0_body.fhnd107 PRE_first_tail_x15_r0_body.fnode107
kernel_rfl PRE_first_tail_x15_r0_body.fcxn107 : (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn107 : (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0107 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_107.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_107.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS107.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_107.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS107.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_107.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS107.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_107.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS107.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_107.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd107 : (PRE_first_tail_x15_r0_body.clo107 ++ PRE_first_tail_x15_r0_body.cln107 ++ PRE_first_tail_x15_r0_body.cli107 ++ PRE_first_tail_x15_r0_body.cwS107 ++ PRE_first_tail_x15_r0_body.cnS107 ++ PRE_first_tail_x15_r0_body.ciS107).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW107 : PRE_first_tail_x15_r0_body.cwS107.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo107.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI107 : PRE_first_tail_x15_r0_body.ciS107.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli107.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN107 : PRE_first_tail_x15_r0_body.cnS107.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF107 : PRE_first_tail_x15_r0_body.cln107.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh107 : PRE_first_tail_x15_r0_body.clo107.all (handleOK PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.P107.lo PRE_first_tail_x15_r0_body.cx0_107.mlx PRE_first_tail_x15_r0_body.cx1_107.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo107 : PRE_first_tail_x15_r0_body.clo107.map (fun h => PRE_first_tail_x15_r0_body.cx1_107.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa107.handle h)) = PRE_first_tail_x15_r0_body.clo107.map (fun h => (PRE_first_tail_x15_r0_body.cx0_107.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa107.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok107 : PRE_first_tail_x15_r0_body.clo107.all (objOK PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.P107.NL PRE_first_tail_x15_r0_body.cx0_107.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd107 : PRE_first_tail_x15_r0_body.cln107.all (nodeOKF PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.P107 PRE_first_tail_x15_r0_body.cx0_107.mlx PRE_first_tail_x15_r0_body.cx1_107.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp107 : ((PRE_first_tail_x15_r0_body.cln107.filter (fullB PRE_first_tail_x15_r0_body.P107))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_107.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa107.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln107.filter (fullB PRE_first_tail_x15_r0_body.P107))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_107.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa107.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI107 : incrB PRE_first_tail_x15_r0_body.kd107.nodeF (List.range' 17392 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.node).all (fun k => Nat.ble 17392 k && Nat.blt k 17392) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL107 : (PRE_first_tail_x15_r0_body.cln107.filter (Nat.ble PRE_first_tail_x15_r0_body.P107.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd107.nodeF i) && (Nat.blt i 17392 || Nat.ble PRE_first_tail_x15_r0_body.kd107.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord107 : (PRE_first_tail_x15_r0_body.cln107.filter (Nat.ble PRE_first_tail_x15_r0_body.P107.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd107.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd107.nodeF j) (PRE_first_tail_x15_r0_body.kd107.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow107 PRE_first_tail_x15_r0_body.cnn1107 PRE_first_tail_x15_r0_body.fnordI107 PRE_first_tail_x15_r0_body.fnordK107 PRE_first_tail_x15_r0_body.fnordL107
kernel_rfl PRE_first_tail_x15_r0_body.fi107 : PRE_first_tail_x15_r0_body.cli107.all (pnB PRE_first_tail_x15_r0_body.cx0_107.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii107 : PRE_first_tail_x15_r0_body.cli107.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_107.mlx.items.get (PRE_first_tail_x15_r0_body.kappa107.node k) = (PRE_first_tail_x15_r0_body.cx0_107.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa107.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot107 (clean : Conv.NClean (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P107.NL) (cl : SSt (· < 4627) PRE_first_tail_x15_r0_body.cx0_107.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P107 4627 PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.kd107 PRE_first_tail_x15_r0_body.khinv107 PRE_first_tail_x15_r0_body.kninv107 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx PRE_first_tail_x15_r0_body.cx0_107.mlx PRE_first_tail_x15_r0_body.cx1_107.mlx (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo107 PRE_first_tail_x15_r0_body.cln107 PRE_first_tail_x15_r0_body.cli107 PRE_first_tail_x15_r0_body.cwS107 PRE_first_tail_x15_r0_body.cnS107 PRE_first_tail_x15_r0_body.ciS107 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0107, PRE_first_tail_x15_r0_body.cnh1107, PRE_first_tail_x15_r0_body.cnn0107, PRE_first_tail_x15_r0_body.cnn1107, PRE_first_tail_x15_r0_body.cplo107, PRE_first_tail_x15_r0_body.ccnt107, PRE_first_tail_x15_r0_body.cnband107, PRE_first_tail_x15_r0_body.chbelow107, PRE_first_tail_x15_r0_body.chren107, PRE_first_tail_x15_r0_body.cband107, PRE_first_tail_x15_r0_body.cnh1pos107, PRE_first_tail_x15_r0_body.cnren107, PRE_first_tail_x15_r0_body.cnlow107, PRE_first_tail_x15_r0_body.cabs0a107, PRE_first_tail_x15_r0_body.cabs0b107, PRE_first_tail_x15_r0_body.ctok1107, PRE_first_tail_x15_r0_body.cpend107, PRE_first_tail_x15_r0_body.cerrh107, PRE_first_tail_x15_r0_body.cfiles107, PRE_first_tail_x15_r0_body.carch107, PRE_first_tail_x15_r0_body.csizes107, PRE_first_tail_x15_r0_body.cwired107, PRE_first_tail_x15_r0_body.cfix107, clean, PRE_first_tail_x15_r0_body.fcxn107, PRE_first_tail_x15_r0_body.fcnn107, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0107, PRE_first_tail_x15_r0_body.fnk107, PRE_first_tail_x15_r0_body.ckA107, PRE_first_tail_x15_r0_body.cobjsK107, PRE_first_tail_x15_r0_body.cnodesK107, PRE_first_tail_x15_r0_body.citemsK107, PRE_first_tail_x15_r0_body.f1A107, PRE_first_tail_x15_r0_body.f1O107, PRE_first_tail_x15_r0_body.f1N107, PRE_first_tail_x15_r0_body.f1I107, PRE_first_tail_x15_r0_body.fbd107, PRE_first_tail_x15_r0_body.fincW107, PRE_first_tail_x15_r0_body.fincI107, PRE_first_tail_x15_r0_body.fincN107, PRE_first_tail_x15_r0_body.flnF107, PRE_first_tail_x15_r0_body.fh107, PRE_first_tail_x15_r0_body.fo107, PRE_first_tail_x15_r0_body.fok107, PRE_first_tail_x15_r0_body.fnd107, PRE_first_tail_x15_r0_body.fp107, PRE_first_tail_x15_r0_body.fnord107, PRE_first_tail_x15_r0_body.fi107, PRE_first_tail_x15_r0_body.fii107⟩
theorem PRE_first_tail_x15_r0_body.cnshift107 (clean : Conv.NClean (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P107.NL) (cl : SSt (· < 4627) PRE_first_tail_x15_r0_body.cx0_107.mlx) : NShift PRE_first_tail_x15_r0_body.P107 4627 PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.cx0_107 PRE_first_tail_x15_r0_body.cx1_107 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot107 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost107 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0107 PRE_first_tail_x15_r0_body.ckn1107 PRE_first_tail_x15_r0_body.ckheap107 PRE_first_tail_x15_r0_body.ckpl107)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_107 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1034.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_107 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1034.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_107 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1034.ffi) = some PRE_first_tail_x15_r0_body.fxC_107
kernel_rfl PRE_first_tail_x15_r0_body.okrC_107 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1034.ffi) = some PRE_first_tail_x15_r0_body.krC_107
noncomputable def PRE_first_tail_x15_r0_body.fx0_107 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1036.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_107 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1036.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_107 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1036.ffi) = some PRE_first_tail_x15_r0_body.fx0_107
kernel_rfl PRE_first_tail_x15_r0_body.okr0_107 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1036.ffi) = some PRE_first_tail_x15_r0_body.kr0_107
noncomputable def PRE_first_tail_x15_r0_body.fx1_107 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1035.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_107 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1035.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_107 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1035.ffi) = some PRE_first_tail_x15_r0_body.fx1_107
kernel_rfl PRE_first_tail_x15_r0_body.okr1_107 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1035.ffi) = some PRE_first_tail_x15_r0_body.kr1_107
kernel_rfl PRE_first_tail_x15_r0_body.ff0107 : PRE_first_tail_x15_r0_body.fx0_107 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_107 (PRE_first_tail_x15_r0_body.clo107.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_107.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1107 : PRE_first_tail_x15_r0_body.fx1_107 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_107 (PRE_first_tail_x15_r0_body.cwS107.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_107.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck107 : freedLB PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.cx0_107.mlx PRE_first_tail_x15_r0_body.fx0_107 PRE_first_tail_x15_r0_body.fx1_107 PRE_first_tail_x15_r0_body.clo107 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0107 : PRE_first_tail_x15_r0_body.kr0_107.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_107.flags (PRE_first_tail_x15_r0_body.clo107.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_107.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0107 : PRE_first_tail_x15_r0_body.kr0_107.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_107.targs (PRE_first_tail_x15_r0_body.clo107.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_107.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1107 : PRE_first_tail_x15_r0_body.kr1_107.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_107.flags (PRE_first_tail_x15_r0_body.cwS107.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_107.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1107 : PRE_first_tail_x15_r0_body.kr1_107.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_107.targs (PRE_first_tail_x15_r0_body.cwS107.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_107.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck107 : krecLB PRE_first_tail_x15_r0_body.kappa107 4627 PRE_first_tail_x15_r0_body.cx0_107.mlx PRE_first_tail_x15_r0_body.kr0_107 PRE_first_tail_x15_r0_body.kr1_107 PRE_first_tail_x15_r0_body.clo107 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn107 : Nat.ble 4627 4627 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge107 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1035.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1036.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR107 : pendRegB PRE_first_tail_x15_r0_body.kappa107 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe107 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1035.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift107 (clean : Conv.NClean (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P107.NL) (cl : SSt (· < 4627) PRE_first_tail_x15_r0_body.cx0_107.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_107.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_107.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_107.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_107.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P107 4627 PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.s1036.ffi PRE_first_tail_x15_r0_body.s1035.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift107 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue107, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp107 t ht),
    PRE_first_tail_x15_r0_body.cbridge107,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1036.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1035.ffi) (PRE_first_tail_x15_r0_body.cfoot107 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_107 PRE_first_tail_x15_r0_body.ofx1_107 hobjC PRE_first_tail_x15_r0_body.ff0107 PRE_first_tail_x15_r0_body.ff1107 PRE_first_tail_x15_r0_body.ffck107,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1036.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1035.ffi) (PRE_first_tail_x15_r0_body.cfoot107 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_107 PRE_first_tail_x15_r0_body.okr1_107 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn107) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0107 PRE_first_tail_x15_r0_body.fkt0107 PRE_first_tail_x15_r0_body.fkf1107 PRE_first_tail_x15_r0_body.fkt1107 PRE_first_tail_x15_r0_body.fkck107,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0107 PRE_first_tail_x15_r0_body.cnh1107 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe107) PRE_first_tail_x15_r0_body.cpendR107⟩

end Host.Load.Run.Tpl
end

section -- st107/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st107 0
host_stream_state PRE_first_tail_x15_r0_body.st107 1
host_stream_state PRE_first_tail_x15_r0_body.st107 2
end Host.Load.Run.Tpl
end

section -- Site107
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 107 of chain `PRE_first_tail_x15_r0_body`: `plan__g107__g108` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1034`, the merged state `PRE_first_tail_x15_r0_body.s1035`,
the site template `PRE_first_tail_x15_r0_body.st107` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1036`: the merge.
The footprint's facts are in `SiteF107`, the compaction's in `SiteC107`, `SiteK107`, `SiteNa107`, `SiteNb107`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso107 : PRE_first_tail_x15_r0_body.st107.s0 = { PRE_first_tail_x15_r0_body.s1034 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs107 : List Frame := PRE_first_tail_x15_r0_body.s1034.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_107 : PRE_first_tail_x15_r0_body.S1034.tab.length = 4627
kernel_rfl PRE_first_tail_x15_r0_body.tab0_107 : PRE_first_tail_x15_r0_body.st107.S0.tab = PRE_first_tail_x15_r0_body.S1034.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws107 : List Nat := [2800, 2801, 2802]
kernel_rfl PRE_first_tail_x15_r0_body.fresh107 : (PRE_first_tail_x15_r0_body.S1034.tab.all fun e => PRE_first_tail_x15_r0_body.ws107.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1034.oracle.all fun q => PRE_first_tail_x15_r0_body.ws107.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab107 : PRE_first_tail_x15_r0_body.S1035.tab = PRE_first_tail_x15_r0_body.S1034.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws107
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen107 : PRE_first_tail_x15_r0_body.st107.S2.tab.length - PRE_first_tail_x15_r0_body.st107.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged107`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap107 : PRE_first_tail_x15_r0_body.s1035.heap = PRE_first_tail_x15_r0_body.st107.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext107 : PRE_first_tail_x15_r0_body.s1035.next = PRE_first_tail_x15_r0_body.st107.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl107 : PRE_first_tail_x15_r0_body.s1035.ctl = PRE_first_tail_x15_r0_body.st107.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack107 : PRE_first_tail_x15_r0_body.s1035.stack = PRE_first_tail_x15_r0_body.st107.s2.stack ++ PRE_first_tail_x15_r0_body.s1034.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs107 : PRE_first_tail_x15_r0_body.s1035.jobs = PRE_first_tail_x15_r0_body.st107.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi107 : PRE_first_tail_x15_r0_body.s1035.ffi = PRE_first_tail_x15_r0_body.st107.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace107 : PRE_first_tail_x15_r0_body.s1035.trace = PRE_first_tail_x15_r0_body.st107.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores107 : PRE_first_tail_x15_r0_body.s1035.stores = PRE_first_tail_x15_r0_body.st107.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD107
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 107 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived107 : PRE_first_tail_x15_r0_body.nr107.map (fun r => nth? PRE_first_tail_x15_r0_body.st107.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo107 : PRE_first_tail_x15_r0_body.nr107.all (Nat.ble 4627) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj107 : PRE_first_tail_x15_r0_body.cws107.all (fun c => !PRE_first_tail_x15_r0_body.ws107.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ107 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws107 PRE_first_tail_x15_r0_body.crs107 PRE_first_tail_x15_r0_body.ws107

end Host.Load.Run.Tpl
end

section -- st107/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st107`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st107.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st107.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st107.s2.heap PRE_first_tail_x15_r0_body.st107.wrR ++ freshOf PRE_first_tail_x15_r0_body.st107.s2.heap PRE_first_tail_x15_r0_body.st107.s0.next PRE_first_tail_x15_r0_body.st107.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st107.wr : List Nat := PRE_first_tail_x15_r0_body.st107.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st107.heapFoot : PRE_first_tail_x15_r0_body.st107.s2.heap = setAll PRE_first_tail_x15_r0_body.st107.s0.heap PRE_first_tail_x15_r0_body.st107.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st107.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st107.s0.next PRE_first_tail_x15_r0_body.st107.s2.next = true
theorem PRE_first_tail_x15_r0_body.st107.grows : PRE_first_tail_x15_r0_body.st107.s0.next ≤ PRE_first_tail_x15_r0_body.st107.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st107.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st107.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st107.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st107.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st107.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st107.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st107.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st107.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st107.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st107.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st107.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st107.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF107
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 107 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB107 : nodupT PRE_first_tail_x15_r0_body.st107.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup107 : PRE_first_tail_x15_r0_body.st107.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB107).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB107 : PRE_first_tail_x15_r0_body.st107.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound107 : ∀ b ∈ PRE_first_tail_x15_r0_body.st107.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB107 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr107 := PRE_first_tail_x15_r0_body.st107.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq107 : PRE_first_tail_x15_r0_body.st107.s2.trace = PRE_first_tail_x15_r0_body.trFr107 ++ PRE_first_tail_x15_r0_body.st107.s0.trace
theorem PRE_first_tail_x15_r0_body.trace107 : ∃ fr, PRE_first_tail_x15_r0_body.st107.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st107.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq107⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide107 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB107 : (PRE_first_tail_x15_r0_body.wide107.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st107.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix107 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide107, WFix Map.id (Present PRE_first_tail_x15_r0_body.st107.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB107 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL107
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 107 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1035`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO107 : PRE_first_tail_x15_r0_body.st107.S0.oracle = PRE_first_tail_x15_r0_body.st107.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B107 : PRE_first_tail_x15_r0_body.st107.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st107.s0.next || (PRE_first_tail_x15_r0_body.st107.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot107 : Conv.StageFoot PRE_first_tail_x15_r0_body.st107.wr PRE_first_tail_x15_r0_body.st107.s0 PRE_first_tail_x15_r0_body.st107.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st107.heapFoot PRE_first_tail_x15_r0_body.wrNodup107 PRE_first_tail_x15_r0_body.wrBound107 PRE_first_tail_x15_r0_body.wr0B107 PRE_first_tail_x15_r0_body.st107.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged107 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st107.F.S → PRE_first_tail_x15_r0_body.st107.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st107.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st107.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs107 PRE_first_tail_x15_r0_body.st107.wr PRE_first_tail_x15_r0_body.s1034 PRE_first_tail_x15_r0_body.st107.s2 PRE_first_tail_x15_r0_body.st107.s0
      PRE_first_tail_x15_r0_body.st107.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st107.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1035 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso107 PRE_first_tail_x15_r0_body.stFoot107 PRE_first_tail_x15_r0_body.wrNodup107 PRE_first_tail_x15_r0_body.wrBound107 PRE_first_tail_x15_r0_body.trace107 PRE_first_tail_x15_r0_body.mheap107
    PRE_first_tail_x15_r0_body.mnext107 PRE_first_tail_x15_r0_body.mctl107 PRE_first_tail_x15_r0_body.mstack107 PRE_first_tail_x15_r0_body.mjobs107 PRE_first_tail_x15_r0_body.mffi107 PRE_first_tail_x15_r0_body.mtrace107 PRE_first_tail_x15_r0_body.mstores107 h

def PRE_first_tail_x15_r0_body.arrEl107_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE107_2665 : arrOf PRE_first_tail_x15_r0_body.s1035 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl107_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA107_2665 : isArrB PRE_first_tail_x15_r0_body.s1035 2665 = true
theorem PRE_first_tail_x15_r0_body.arr107_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1035.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl107_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE107_2665 PRE_first_tail_x15_r0_body.arrA107_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN107_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl107_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR107_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl107_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN107_2665

def PRE_first_tail_x15_r0_body.arrEl107_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE107_2673467 : arrOf PRE_first_tail_x15_r0_body.s1035 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl107_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA107_2673467 : isArrB PRE_first_tail_x15_r0_body.s1035 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr107_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1035.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl107_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE107_2673467 PRE_first_tail_x15_r0_body.arrA107_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN107_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl107_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR107_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl107_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN107_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k107 : isArrB PRE_first_tail_x15_r0_body.s1035 4910 = false
theorem PRE_first_tail_x15_r0_body.keep107 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1035 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k107 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr107_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl107_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ107
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 107 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1034`, the merged
state `PRE_first_tail_x15_r0_body.s1035`, the canonical state `PRE_first_tail_x15_r0_body.s1036`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl107 : PRE_first_tail_x15_r0_body.pl107.all (Nat.ble PRE_first_tail_x15_r0_body.s1034.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd107 : nodupT PRE_first_tail_x15_r0_body.pl107 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1107 : Nat.ble PRE_first_tail_x15_r0_body.s1034.next 2758728 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst107 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1034.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn107 : PRE_first_tail_x15_r0_body.s1036.next = PRE_first_tail_x15_r0_body.s1034.next + PRE_first_tail_x15_r0_body.pl107.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn107 : PRE_first_tail_x15_r0_body.s1035.next = 2758728
kernel_rfl PRE_first_tail_x15_r0_body.zgrow107 : Nat.ble PRE_first_tail_x15_r0_body.s1036.next PRE_first_tail_x15_r0_body.s1035.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh107 : PRE_first_tail_x15_r0_body.S1034.tab.all (fun e => PRE_first_tail_x15_r0_body.cws107.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd107 : nodupT PRE_first_tail_x15_r0_body.cws107 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi107 : PRE_first_tail_x15_r0_body.nr107.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1035.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt107 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1034.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg107_2665 : PRE_first_tail_x15_r0_body.s1036.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1036 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk107_2665 : (objOf PRE_first_tail_x15_r0_body.s1036 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm107_2665 : PRE_first_tail_x15_r0_body.s1035.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa107.obj (objOf PRE_first_tail_x15_r0_body.s1036 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1035 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg107_2673467 : PRE_first_tail_x15_r0_body.s1036.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1036 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk107_2673467 : (objOf PRE_first_tail_x15_r0_body.s1036 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm107_2673467 : PRE_first_tail_x15_r0_body.s1035.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa107.obj (objOf PRE_first_tail_x15_r0_body.s1036 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1035 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw107_4910 : (PRE_first_tail_x15_r0_body.s1036.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw107_2673472 : (PRE_first_tail_x15_r0_body.s1036.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw107_2673473 : (PRE_first_tail_x15_r0_body.s1036.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd107 : PRE_first_tail_x15_r0_body.cl107.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr107 : PRE_first_tail_x15_r0_body.st107.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1034.next || PRE_first_tail_x15_r0_body.cl107.contains b) = true
def PRE_first_tail_x15_r0_body.zl107 : List Nat := PRE_first_tail_x15_r0_body.cl107.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE107 : PRE_first_tail_x15_r0_body.zl107.map (fun a => PRE_first_tail_x15_r0_body.s1035.heap.get (PRE_first_tail_x15_r0_body.kappa107.a a)) = PRE_first_tail_x15_r0_body.zl107.map (fun a => (PRE_first_tail_x15_r0_body.s1036.heap.get a).map PRE_first_tail_x15_r0_body.kappa107.hobj)
theorem PRE_first_tail_x15_r0_body.zimg107 : HeapImg PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.s1035 PRE_first_tail_x15_r0_body.zl107 := PRE_first_tail_x15_r0_body.zimgE107
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl107 : PRE_first_tail_x15_r0_body.s1035.ctl = PRE_first_tail_x15_r0_body.kappa107.ctl PRE_first_tail_x15_r0_body.s1036.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack107 : PRE_first_tail_x15_r0_body.s1035.stack = PRE_first_tail_x15_r0_body.s1036.stack.map PRE_first_tail_x15_r0_body.kappa107.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs107 : PRE_first_tail_x15_r0_body.s1035.jobs = PRE_first_tail_x15_r0_body.s1036.jobs.map PRE_first_tail_x15_r0_body.kappa107.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores107 : PRE_first_tail_x15_r0_body.s1035.stores = PRE_first_tail_x15_r0_body.kappa107.stores PRE_first_tail_x15_r0_body.s1036.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots107 : checkRootsSupp PRE_first_tail_x15_r0_body.s1036 4627 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC107 : PRE_first_tail_x15_r0_body.S1034.tab.length + PRE_first_tail_x15_r0_body.cws107.length = 4627
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap107 : PRE_first_tail_x15_r0_body.kappa107 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1034.next 2758728 PRE_first_tail_x15_r0_body.S1034.tab.length PRE_first_tail_x15_r0_body.pl107 (PRE_first_tail_x15_r0_body.nr107.map NumV.ref) PRE_first_tail_x15_r0_body.kd107.big
  PRE_first_tail_x15_r0_body.kd107.region PRE_first_tail_x15_r0_body.kd107.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin107 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1036.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc107 : Conv.jcleanListB (⟨20305, 17392, 2758718, 4627⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.cl107 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB107 : noBigRootsP (fun i => !Conv.oldBigB (⟨20305, 17392, 2758718, 4627⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1036.trace PRE_first_tail_x15_r0_body.s1036 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm107 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17392 = true
theorem PRE_first_tail_x15_r0_body.cjcl107 (h : Conv.JClean (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1034) : Conv.JClean (⟨20305, 17392, 2758718, 4627⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1036 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle107)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap107 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd107 a ha)) PRE_first_tail_x15_r0_body.zjc107

end Host.Load.Run.Tpl
end

section -- st107/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st107.bodyLast from PRE_first_tail_x15_r0_body.st107.s1 to PRE_first_tail_x15_r0_body.st107.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st107.F PRE_first_tail_x15_r0_body.st107.s1).run PRE_first_tail_x15_r0_body.st107.S1 = some (PRE_first_tail_x15_r0_body.st107.s2, PRE_first_tail_x15_r0_body.st107.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st107.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st107.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st107.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st107.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st107/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st107.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st107.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st107.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st107.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st107.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st107.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st107.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st107.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st107.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st107.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st107.s0 PRE_first_tail_x15_r0_body.st107.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st107.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st107.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st107.s1 PRE_first_tail_x15_r0_body.st107.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st107/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st107.bodyK0F from PRE_first_tail_x15_r0_body.st107.s0 to PRE_first_tail_x15_r0_body.st107.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st107.F (PRE_first_tail_x15_r0_body.st107.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st107.ks 0).getD 0) PRE_first_tail_x15_r0_body.st107.s0 PRE_first_tail_x15_r0_body.st107.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st107.s1, PRE_first_tail_x15_r0_body.st107.S1)
theorem PRE_first_tail_x15_r0_body.st107.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st107.F (PRE_first_tail_x15_r0_body.st107.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st107.ks 0).getD 0) PRE_first_tail_x15_r0_body.st107.s0 PRE_first_tail_x15_r0_body.st107.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st107.s1, PRE_first_tail_x15_r0_body.st107.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st107.bodyOkLN_ok PRE_first_tail_x15_r0_body.st107.bodyK0F
end Host.Load.Run.Tpl
end

section -- st107/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st107.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st107.F (PRE_first_tail_x15_r0_body.st107.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st107.s0 PRE_first_tail_x15_r0_body.st107.S0 = some (PRE_first_tail_x15_r0_body.st107.s1, PRE_first_tail_x15_r0_body.st107.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st107.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st107.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st107.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st107.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st107.F (PRE_first_tail_x15_r0_body.st107.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st107.s0
  S0 := PRE_first_tail_x15_r0_body.st107.S0
  s1 := PRE_first_tail_x15_r0_body.st107.s1
  S1 := PRE_first_tail_x15_r0_body.st107.S1
  s2 := PRE_first_tail_x15_r0_body.st107.s2
  S2 := PRE_first_tail_x15_r0_body.st107.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st107.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st107.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st107.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st107.bodyHalt
  last := PRE_first_tail_x15_r0_body.st107.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st107.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC108
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 108 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1053` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa108` into the merged state
`PRE_first_tail_x15_r0_body.s1052`. -/

def PRE_first_tail_x15_r0_body.pl108 : List Nat := [2761323, 2760498, 2761329, 2761325, 2760500, 2761331]
def PRE_first_tail_x15_r0_body.nr108 : List Nat := [4730, 4729, 4705, 4713, 4718, 4723, 4728, 4702, 4703, 4704, 4711, 4712, 4700, 4707, 4708, 4709, 4710, 4706]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd108 : RData :=
  ⟨2760217, 2761366, Stage.setAll PTrie.nil [(2760211, 2761323), (2760212, 2760498), (2760213, 2761329), (2760214, 2761325), (2760215, 2760500), (2760216, 2761331)], Stage.setAll PTrie.nil [(20340, 20366), (20341, 20344), (20342, 20367)],
   20343, 20368, 17438, 17438, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4700, .ref 4730), (4701, .ref 4729), (4702, .ref 4705), (4703, .ref 4713), (4704, .ref 4718), (4705, .ref 4723), (4706, .ref 4728), (4707, .ref 4702), (4708, .ref 4703), (4709, .ref 4704), (4710, .ref 4711), (4711, .ref 4712), (4712, .ref 4700), (4713, .ref 4707), (4714, .ref 4708), (4715, .ref 4709), (4716, .ref 4710), (4717, .ref 4706)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa108 : Map :=
  Conv.Map.compact 2760211 2761366 4700 PRE_first_tail_x15_r0_body.pl108 (PRE_first_tail_x15_r0_body.nr108.map NumV.ref) PRE_first_tail_x15_r0_body.kd108.big
    PRE_first_tail_x15_r0_body.kd108.region PRE_first_tail_x15_r0_body.kd108.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws108 : List Nat := [2834, 2835, 2836, 2837, 2838, 2839, 2840, 2841, 2842, 2843, 2844, 2845, 2846, 2847, 2848, 2849, 2850, 2851]
noncomputable def PRE_first_tail_x15_r0_body.crs108 : List SymE := PRE_first_tail_x15_r0_body.nr108.map fun r => (nth? PRE_first_tail_x15_r0_body.S1052.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta108 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws108 PRE_first_tail_x15_r0_body.crs108
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB108 : List Nat := [2665, 2672579, 2673467, 2759385, 2759930, 2760186]

kernel_rfl PRE_first_tail_x15_r0_body.ctab108 : PRE_first_tail_x15_r0_body.S1053.tab = PRE_first_tail_x15_r0_body.S1051.tab ++ PRE_first_tail_x15_r0_body.cws108.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace108 : PRE_first_tail_x15_r0_body.s1053.trace = PRE_first_tail_x15_r0_body.s1051.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext108 : PRE_first_tail_x15_r0_body.s1053.next = 2760217
kernel_rfl PRE_first_tail_x15_r0_body.ccounters108 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.nnext) = (20343, 17438)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue108 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1052.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa108.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp108 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.tokens.all (bSN 4718) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean108 : Conv.cleanListB 20343 131072 (fun r => Nat.ble 81372 r) PRE_first_tail_x15_r0_body.s1053
    (PRE_first_tail_x15_r0_body.wrB108 ++ (List.range 6).map (2760211 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs108 : bigsOutB 20343 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK108
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl108`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl108 : List Nat := [2665, 2672579, 2673467, 2759385, 2759930, 2760186, 2760211, 2760212, 2760213, 2760214, 2760215, 2760216]
def PRE_first_tail_x15_r0_body.clo108 : List Nat := [20320, 20333, 20339, 20340, 20341, 20342]
def PRE_first_tail_x15_r0_body.cln108 : List Nat := [17411, 17412, 17413, 17414, 17415, 17416, 17417, 17418, 17419, 17420, 17421, 17422, 17423, 17424, 17425, 17426, 17427, 17428, 17429, 17430, 17431, 17432, 17433, 17434, 17435, 17436, 17437]
def PRE_first_tail_x15_r0_body.cli108 : List Nat := [17411, 17412, 17413, 17414, 17415, 17416, 17417, 17418, 17419, 17420, 17421, 17422, 17423, 17424, 17425, 17426, 17427, 17428, 17429, 17430, 17431, 17432, 17433, 17434, 17435, 17436, 17437]
kernel_rfl PRE_first_tail_x15_r0_body.cheap108 : PRE_first_tail_x15_r0_body.s1053.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1051.heap (PRE_first_tail_x15_r0_body.cl108.filterMap fun a => (PRE_first_tail_x15_r0_body.s1053.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe108 : Nat.ble PRE_first_tail_x15_r0_body.s1051.next PRE_first_tail_x15_r0_body.s1053.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP108 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1051 PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.cl108 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp108 : Conv.suppListB PRE_first_tail_x15_r0_body.s1053 4718 PRE_first_tail_x15_r0_body.cl108 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound108 : Conv.boundListB PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.cl108 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK108 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln108.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK108 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo108.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK108 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli108.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst108 : Conv.sstListB 4718 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx PRE_first_tail_x15_r0_body.cln108 PRE_first_tail_x15_r0_body.clo108 PRE_first_tail_x15_r0_body.cli108 = true

end Host.Load.Run.Tpl
end

section -- SiteCl108
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA108 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo108.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd108 : (PRE_first_tail_x15_r0_body.clo108 ++ PRE_first_tail_x15_r0_body.cln108 ++ PRE_first_tail_x15_r0_body.cli108).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle108 : Conv.Cnt.leB (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) (⟨20343, 17438, 2760217, 4718⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck108 : Conv.ncleanListB (⟨20343, 17438, 2760217, 4718⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx PRE_first_tail_x15_r0_body.clo108 PRE_first_tail_x15_r0_body.cln108 PRE_first_tail_x15_r0_body.cli108 = true
theorem PRE_first_tail_x15_r0_body.cncl108 (h : Conv.NClean (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx) : Conv.NClean (⟨20343, 17438, 2760217, 4718⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle108 PRE_first_tail_x15_r0_body.ckA108 PRE_first_tail_x15_r0_body.cobjsK108 PRE_first_tail_x15_r0_body.cnodesK108 PRE_first_tail_x15_r0_body.citemsK108 PRE_first_tail_x15_r0_body.cbd108 PRE_first_tail_x15_r0_body.cck108

end Host.Load.Run.Tpl
end

section -- SiteS108
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 108 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc108 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P108 : LoadP := PRE_first_tail_x15_r0_body.Pc108.raise 17438
kernel_rfl PRE_first_tail_x15_r0_body.craise108 : Nat.ble PRE_first_tail_x15_r0_body.Pc108.N0 17438 = true
theorem PRE_first_tail_x15_r0_body.raised108 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc108 PRE_first_tail_x15_r0_body.P108 :=
  .inr ⟨17438, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise108, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_108 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_108 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1052.ffi)
def PRE_first_tail_x15_r0_body.khinv108 : PTrie Nat := Stage.setAll PTrie.nil [(20366, 20340), (20344, 20341), (20367, 20342)]
def PRE_first_tail_x15_r0_body.kninv108 : PTrie Nat := Stage.setAll PTrie.nil [(17411, 17411), (17412, 17412), (17413, 17413), (17414, 17414), (17415, 17415), (17416, 17416), (17417, 17417), (17418, 17418), (17419, 17419), (17420, 17420), (17421, 17421), (17422, 17422), (17423, 17423), (17424, 17424), (17425, 17425), (17426, 17426), (17427, 17427), (17428, 17428), (17429, 17429), (17430, 17430), (17431, 17431), (17432, 17432), (17433, 17433), (17434, 17434), (17435, 17435), (17436, 17436), (17437, 17437)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS108 : List Nat := [20320, 20333, 20339, 20340, 20341, 20342, 20343, 20344, 20345, 20346, 20347, 20348, 20349, 20350, 20351, 20352, 20353, 20354, 20355, 20356, 20357, 20358, 20359, 20360, 20361, 20362, 20363, 20364, 20365, 20366, 20367]
def PRE_first_tail_x15_r0_body.cnS108 : List Nat := List.range' 17411 27
def PRE_first_tail_x15_r0_body.ciS108 : List Nat := [] ++ List.range' 17411 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0108 : PRE_first_tail_x15_r0_body.kd108.nh0 = PRE_first_tail_x15_r0_body.cx0_108.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1108 : PRE_first_tail_x15_r0_body.kd108.nh1 = PRE_first_tail_x15_r0_body.cx1_108.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0108 : PRE_first_tail_x15_r0_body.kd108.nn0 = PRE_first_tail_x15_r0_body.cx0_108.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1108 : PRE_first_tail_x15_r0_body.kd108.nn1 = PRE_first_tail_x15_r0_body.cx1_108.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo108 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P108.lo && Nat.ble PRE_first_tail_x15_r0_body.P108.lo PRE_first_tail_x15_r0_body.cx0_108.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P108.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P108.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt108 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_108.mlx.next PRE_first_tail_x15_r0_body.cx1_108.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_108.mlx.nnext PRE_first_tail_x15_r0_body.cx1_108.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband108 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P108.NL && Nat.ble PRE_first_tail_x15_r0_body.P108.NL PRE_first_tail_x15_r0_body.P108.N0 && Nat.ble PRE_first_tail_x15_r0_body.P108.N0 PRE_first_tail_x15_r0_body.cx0_108.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow108 : PRE_first_tail_x15_r0_body.kd108.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren108 : checkRenG PRE_first_tail_x15_r0_body.kd108.hnd PRE_first_tail_x15_r0_body.khinv108 (phB PRE_first_tail_x15_r0_body.cx0_108.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband108 : PRE_first_tail_x15_r0_body.kd108.checkBand PRE_first_tail_x15_r0_body.P108.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos108 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd108.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren108 : checkRenG PRE_first_tail_x15_r0_body.kd108.node PRE_first_tail_x15_r0_body.kninv108 (pnB PRE_first_tail_x15_r0_body.cx0_108.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P108.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd108.nodeF j) PRE_first_tail_x15_r0_body.cx1_108.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a108 : PRE_first_tail_x15_r0_body.cx0_108.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b108 : PRE_first_tail_x15_r0_body.cx0_108.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.pending = PRE_first_tail_x15_r0_body.cx0_108.mlx.pending.map PRE_first_tail_x15_r0_body.kappa108.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.errh = PRE_first_tail_x15_r0_body.cx0_108.mlx.errh.map PRE_first_tail_x15_r0_body.kappa108.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.files = PRE_first_tail_x15_r0_body.cx0_108.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.arch = PRE_first_tail_x15_r0_body.cx0_108.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_108.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.wired = PRE_first_tail_x15_r0_body.cx0_108.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost108 : PRE_first_tail_x15_r0_body.cx1_108.host = PRE_first_tail_x15_r0_body.cx0_108.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd108`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0108 : PRE_first_tail_x15_r0_body.kd108.n0 = 2760217
kernel_rfl PRE_first_tail_x15_r0_body.ckn1108 : PRE_first_tail_x15_r0_body.kd108.n1 = 2761366
kernel_rfl PRE_first_tail_x15_r0_body.ckheap108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.heap).all (fun x => Nat.ble 2760211 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl108 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd108.heap.get (2760211 + j) = nth? PRE_first_tail_x15_r0_body.pl108 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja108 : Nat.ble 2760211 2760211 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn108 : Nat.ble 4700 4700 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD108 : Nat.ble 2760211 PRE_first_tail_x15_r0_body.kd108.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn108 : Nat.ble 20340 PRE_first_tail_x15_r0_body.kd108.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn108 : Nat.ble 17411 PRE_first_tail_x15_r0_body.kd108.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb108 : Nat.ble 20340 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.heap).all (Nat.ble (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.hnd).all (Nat.ble (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.node).all (Nat.ble (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix108 : Conv.FixOld (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa108 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja108) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn108) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD108) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn108) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn108) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb108) PRE_first_tail_x15_r0_body.fheap108 PRE_first_tail_x15_r0_body.fhnd108 PRE_first_tail_x15_r0_body.fnode108
kernel_rfl PRE_first_tail_x15_r0_body.fcxn108 : (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn108 : (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0108 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_108.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_108.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS108.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_108.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS108.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_108.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS108.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_108.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS108.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_108.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd108 : (PRE_first_tail_x15_r0_body.clo108 ++ PRE_first_tail_x15_r0_body.cln108 ++ PRE_first_tail_x15_r0_body.cli108 ++ PRE_first_tail_x15_r0_body.cwS108 ++ PRE_first_tail_x15_r0_body.cnS108 ++ PRE_first_tail_x15_r0_body.ciS108).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW108 : PRE_first_tail_x15_r0_body.cwS108.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo108.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI108 : PRE_first_tail_x15_r0_body.ciS108.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli108.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN108 : PRE_first_tail_x15_r0_body.cnS108.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF108 : PRE_first_tail_x15_r0_body.cln108.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh108 : PRE_first_tail_x15_r0_body.clo108.all (handleOK PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.P108.lo PRE_first_tail_x15_r0_body.cx0_108.mlx PRE_first_tail_x15_r0_body.cx1_108.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo108 : PRE_first_tail_x15_r0_body.clo108.map (fun h => PRE_first_tail_x15_r0_body.cx1_108.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa108.handle h)) = PRE_first_tail_x15_r0_body.clo108.map (fun h => (PRE_first_tail_x15_r0_body.cx0_108.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa108.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok108 : PRE_first_tail_x15_r0_body.clo108.all (objOK PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.P108.NL PRE_first_tail_x15_r0_body.cx0_108.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd108 : PRE_first_tail_x15_r0_body.cln108.all (nodeOKF PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.P108 PRE_first_tail_x15_r0_body.cx0_108.mlx PRE_first_tail_x15_r0_body.cx1_108.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp108 : ((PRE_first_tail_x15_r0_body.cln108.filter (fullB PRE_first_tail_x15_r0_body.P108))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_108.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa108.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln108.filter (fullB PRE_first_tail_x15_r0_body.P108))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_108.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa108.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI108 : incrB PRE_first_tail_x15_r0_body.kd108.nodeF (List.range' 17411 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.node).all (fun k => Nat.ble 17411 k && Nat.blt k 17438) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL108 : (PRE_first_tail_x15_r0_body.cln108.filter (Nat.ble PRE_first_tail_x15_r0_body.P108.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd108.nodeF i) && (Nat.blt i 17438 || Nat.ble PRE_first_tail_x15_r0_body.kd108.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord108 : (PRE_first_tail_x15_r0_body.cln108.filter (Nat.ble PRE_first_tail_x15_r0_body.P108.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd108.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd108.nodeF j) (PRE_first_tail_x15_r0_body.kd108.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow108 PRE_first_tail_x15_r0_body.cnn1108 PRE_first_tail_x15_r0_body.fnordI108 PRE_first_tail_x15_r0_body.fnordK108 PRE_first_tail_x15_r0_body.fnordL108
kernel_rfl PRE_first_tail_x15_r0_body.fi108 : PRE_first_tail_x15_r0_body.cli108.all (pnB PRE_first_tail_x15_r0_body.cx0_108.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii108 : PRE_first_tail_x15_r0_body.cli108.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_108.mlx.items.get (PRE_first_tail_x15_r0_body.kappa108.node k) = (PRE_first_tail_x15_r0_body.cx0_108.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa108.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot108 (clean : Conv.NClean (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P108.NL) (cl : SSt (· < 4718) PRE_first_tail_x15_r0_body.cx0_108.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P108 4718 PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.kd108 PRE_first_tail_x15_r0_body.khinv108 PRE_first_tail_x15_r0_body.kninv108 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx PRE_first_tail_x15_r0_body.cx0_108.mlx PRE_first_tail_x15_r0_body.cx1_108.mlx (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo108 PRE_first_tail_x15_r0_body.cln108 PRE_first_tail_x15_r0_body.cli108 PRE_first_tail_x15_r0_body.cwS108 PRE_first_tail_x15_r0_body.cnS108 PRE_first_tail_x15_r0_body.ciS108 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0108, PRE_first_tail_x15_r0_body.cnh1108, PRE_first_tail_x15_r0_body.cnn0108, PRE_first_tail_x15_r0_body.cnn1108, PRE_first_tail_x15_r0_body.cplo108, PRE_first_tail_x15_r0_body.ccnt108, PRE_first_tail_x15_r0_body.cnband108, PRE_first_tail_x15_r0_body.chbelow108, PRE_first_tail_x15_r0_body.chren108, PRE_first_tail_x15_r0_body.cband108, PRE_first_tail_x15_r0_body.cnh1pos108, PRE_first_tail_x15_r0_body.cnren108, PRE_first_tail_x15_r0_body.cnlow108, PRE_first_tail_x15_r0_body.cabs0a108, PRE_first_tail_x15_r0_body.cabs0b108, PRE_first_tail_x15_r0_body.ctok1108, PRE_first_tail_x15_r0_body.cpend108, PRE_first_tail_x15_r0_body.cerrh108, PRE_first_tail_x15_r0_body.cfiles108, PRE_first_tail_x15_r0_body.carch108, PRE_first_tail_x15_r0_body.csizes108, PRE_first_tail_x15_r0_body.cwired108, PRE_first_tail_x15_r0_body.cfix108, clean, PRE_first_tail_x15_r0_body.fcxn108, PRE_first_tail_x15_r0_body.fcnn108, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0108, PRE_first_tail_x15_r0_body.fnk108, PRE_first_tail_x15_r0_body.ckA108, PRE_first_tail_x15_r0_body.cobjsK108, PRE_first_tail_x15_r0_body.cnodesK108, PRE_first_tail_x15_r0_body.citemsK108, PRE_first_tail_x15_r0_body.f1A108, PRE_first_tail_x15_r0_body.f1O108, PRE_first_tail_x15_r0_body.f1N108, PRE_first_tail_x15_r0_body.f1I108, PRE_first_tail_x15_r0_body.fbd108, PRE_first_tail_x15_r0_body.fincW108, PRE_first_tail_x15_r0_body.fincI108, PRE_first_tail_x15_r0_body.fincN108, PRE_first_tail_x15_r0_body.flnF108, PRE_first_tail_x15_r0_body.fh108, PRE_first_tail_x15_r0_body.fo108, PRE_first_tail_x15_r0_body.fok108, PRE_first_tail_x15_r0_body.fnd108, PRE_first_tail_x15_r0_body.fp108, PRE_first_tail_x15_r0_body.fnord108, PRE_first_tail_x15_r0_body.fi108, PRE_first_tail_x15_r0_body.fii108⟩
theorem PRE_first_tail_x15_r0_body.cnshift108 (clean : Conv.NClean (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P108.NL) (cl : SSt (· < 4718) PRE_first_tail_x15_r0_body.cx0_108.mlx) : NShift PRE_first_tail_x15_r0_body.P108 4718 PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.cx0_108 PRE_first_tail_x15_r0_body.cx1_108 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot108 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost108 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0108 PRE_first_tail_x15_r0_body.ckn1108 PRE_first_tail_x15_r0_body.ckheap108 PRE_first_tail_x15_r0_body.ckpl108)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_108 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1051.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_108 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1051.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_108 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1051.ffi) = some PRE_first_tail_x15_r0_body.fxC_108
kernel_rfl PRE_first_tail_x15_r0_body.okrC_108 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1051.ffi) = some PRE_first_tail_x15_r0_body.krC_108
noncomputable def PRE_first_tail_x15_r0_body.fx0_108 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1053.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_108 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1053.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_108 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1053.ffi) = some PRE_first_tail_x15_r0_body.fx0_108
kernel_rfl PRE_first_tail_x15_r0_body.okr0_108 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1053.ffi) = some PRE_first_tail_x15_r0_body.kr0_108
noncomputable def PRE_first_tail_x15_r0_body.fx1_108 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1052.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_108 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1052.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_108 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1052.ffi) = some PRE_first_tail_x15_r0_body.fx1_108
kernel_rfl PRE_first_tail_x15_r0_body.okr1_108 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1052.ffi) = some PRE_first_tail_x15_r0_body.kr1_108
kernel_rfl PRE_first_tail_x15_r0_body.ff0108 : PRE_first_tail_x15_r0_body.fx0_108 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_108 (PRE_first_tail_x15_r0_body.clo108.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_108.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1108 : PRE_first_tail_x15_r0_body.fx1_108 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_108 (PRE_first_tail_x15_r0_body.cwS108.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_108.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck108 : freedLB PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.cx0_108.mlx PRE_first_tail_x15_r0_body.fx0_108 PRE_first_tail_x15_r0_body.fx1_108 PRE_first_tail_x15_r0_body.clo108 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0108 : PRE_first_tail_x15_r0_body.kr0_108.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_108.flags (PRE_first_tail_x15_r0_body.clo108.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_108.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0108 : PRE_first_tail_x15_r0_body.kr0_108.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_108.targs (PRE_first_tail_x15_r0_body.clo108.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_108.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1108 : PRE_first_tail_x15_r0_body.kr1_108.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_108.flags (PRE_first_tail_x15_r0_body.cwS108.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_108.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1108 : PRE_first_tail_x15_r0_body.kr1_108.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_108.targs (PRE_first_tail_x15_r0_body.cwS108.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_108.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck108 : krecLB PRE_first_tail_x15_r0_body.kappa108 4718 PRE_first_tail_x15_r0_body.cx0_108.mlx PRE_first_tail_x15_r0_body.kr0_108 PRE_first_tail_x15_r0_body.kr1_108 PRE_first_tail_x15_r0_body.clo108 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn108 : Nat.ble 4700 4718 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge108 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1052.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1053.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR108 : pendRegB PRE_first_tail_x15_r0_body.kappa108 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe108 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1052.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift108 (clean : Conv.NClean (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P108.NL) (cl : SSt (· < 4718) PRE_first_tail_x15_r0_body.cx0_108.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_108.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_108.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_108.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_108.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P108 4718 PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.s1053.ffi PRE_first_tail_x15_r0_body.s1052.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift108 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue108, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp108 t ht),
    PRE_first_tail_x15_r0_body.cbridge108,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1053.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1052.ffi) (PRE_first_tail_x15_r0_body.cfoot108 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_108 PRE_first_tail_x15_r0_body.ofx1_108 hobjC PRE_first_tail_x15_r0_body.ff0108 PRE_first_tail_x15_r0_body.ff1108 PRE_first_tail_x15_r0_body.ffck108,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1053.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1052.ffi) (PRE_first_tail_x15_r0_body.cfoot108 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_108 PRE_first_tail_x15_r0_body.okr1_108 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn108) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0108 PRE_first_tail_x15_r0_body.fkt0108 PRE_first_tail_x15_r0_body.fkf1108 PRE_first_tail_x15_r0_body.fkt1108 PRE_first_tail_x15_r0_body.fkck108,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0108 PRE_first_tail_x15_r0_body.cnh1108 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe108) PRE_first_tail_x15_r0_body.cpendR108⟩

end Host.Load.Run.Tpl
end

section -- st108/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st108 0
host_stream_state PRE_first_tail_x15_r0_body.st108 1
host_stream_state PRE_first_tail_x15_r0_body.st108 2
host_stream_state PRE_first_tail_x15_r0_body.st108 3
host_stream_state PRE_first_tail_x15_r0_body.st108 4
host_stream_state PRE_first_tail_x15_r0_body.st108 5
end Host.Load.Run.Tpl
end

section -- Site108
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 108 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g108__g109` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1051`, the merged state `PRE_first_tail_x15_r0_body.s1052`,
the site template `PRE_first_tail_x15_r0_body.st108` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1053`: the merge.
The footprint's facts are in `SiteF108`, the compaction's in `SiteC108`, `SiteK108`, `SiteNa108`, `SiteNb108`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso108 : PRE_first_tail_x15_r0_body.st108.s0 = { PRE_first_tail_x15_r0_body.s1051 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs108 : List Frame := PRE_first_tail_x15_r0_body.s1051.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_108 : PRE_first_tail_x15_r0_body.S1051.tab.length = 4700
kernel_rfl PRE_first_tail_x15_r0_body.tab0_108 : PRE_first_tail_x15_r0_body.st108.S0.tab = PRE_first_tail_x15_r0_body.S1051.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws108 : List Nat := [2803, 2804, 2805, 2806, 2807, 2808, 2809, 2810, 2811, 2812, 2813, 2814, 2815, 2816, 2817, 2818, 2819, 2820, 2821, 2822, 2823, 2824, 2825, 2826, 2827, 2828, 2829, 2830, 2831, 2832, 2833]
kernel_rfl PRE_first_tail_x15_r0_body.fresh108 : (PRE_first_tail_x15_r0_body.S1051.tab.all fun e => PRE_first_tail_x15_r0_body.ws108.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1051.oracle.all fun q => PRE_first_tail_x15_r0_body.ws108.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab108 : PRE_first_tail_x15_r0_body.S1052.tab = PRE_first_tail_x15_r0_body.S1051.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws108
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen108 : PRE_first_tail_x15_r0_body.st108.S5.tab.length - PRE_first_tail_x15_r0_body.st108.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged108`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap108 : PRE_first_tail_x15_r0_body.s1052.heap = PRE_first_tail_x15_r0_body.st108.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext108 : PRE_first_tail_x15_r0_body.s1052.next = PRE_first_tail_x15_r0_body.st108.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl108 : PRE_first_tail_x15_r0_body.s1052.ctl = PRE_first_tail_x15_r0_body.st108.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack108 : PRE_first_tail_x15_r0_body.s1052.stack = PRE_first_tail_x15_r0_body.st108.s5.stack ++ PRE_first_tail_x15_r0_body.s1051.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs108 : PRE_first_tail_x15_r0_body.s1052.jobs = PRE_first_tail_x15_r0_body.st108.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi108 : PRE_first_tail_x15_r0_body.s1052.ffi = PRE_first_tail_x15_r0_body.st108.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace108 : PRE_first_tail_x15_r0_body.s1052.trace = PRE_first_tail_x15_r0_body.st108.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores108 : PRE_first_tail_x15_r0_body.s1052.stores = PRE_first_tail_x15_r0_body.st108.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD108
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 108 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived108 : PRE_first_tail_x15_r0_body.nr108.map (fun r => nth? PRE_first_tail_x15_r0_body.st108.S5.tab r) =
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
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo108 : PRE_first_tail_x15_r0_body.nr108.all (Nat.ble 4700) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj108 : PRE_first_tail_x15_r0_body.cws108.all (fun c => !PRE_first_tail_x15_r0_body.ws108.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ108 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws108 PRE_first_tail_x15_r0_body.crs108 PRE_first_tail_x15_r0_body.ws108

end Host.Load.Run.Tpl
end

section -- st108/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st108`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st108.wrR : List (Nat × Nat) := [(2672579, 2672580), (2759385, 2759386), (2759930, 2759931), (2760186, 2760187)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st108.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st108.s5.heap PRE_first_tail_x15_r0_body.st108.wrR ++ freshOf PRE_first_tail_x15_r0_body.st108.s5.heap PRE_first_tail_x15_r0_body.st108.s0.next PRE_first_tail_x15_r0_body.st108.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st108.wr : List Nat := PRE_first_tail_x15_r0_body.st108.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st108.heapFoot : PRE_first_tail_x15_r0_body.st108.s5.heap = setAll PRE_first_tail_x15_r0_body.st108.s0.heap PRE_first_tail_x15_r0_body.st108.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st108.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st108.s0.next PRE_first_tail_x15_r0_body.st108.s5.next = true
theorem PRE_first_tail_x15_r0_body.st108.grows : PRE_first_tail_x15_r0_body.st108.s0.next ≤ PRE_first_tail_x15_r0_body.st108.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st108.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st108.wh : List Nat := [20320, 20333, 20339, 20340, 20341, 20342, 20343, 20344, 20345, 20346, 20347, 20348, 20349, 20350, 20351, 20352, 20353, 20354, 20355, 20356, 20357, 20358, 20359, 20360, 20361, 20362, 20363, 20364, 20365, 20366, 20367]
def PRE_first_tail_x15_r0_body.st108.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st108.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st108.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st108.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st108.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st108.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st108.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st108.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st108.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF108
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 108 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB108 : nodupT PRE_first_tail_x15_r0_body.st108.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup108 : PRE_first_tail_x15_r0_body.st108.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB108).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB108 : PRE_first_tail_x15_r0_body.st108.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound108 : ∀ b ∈ PRE_first_tail_x15_r0_body.st108.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB108 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr108 := PRE_first_tail_x15_r0_body.st108.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq108 : PRE_first_tail_x15_r0_body.st108.s5.trace = PRE_first_tail_x15_r0_body.trFr108 ++ PRE_first_tail_x15_r0_body.st108.s0.trace
theorem PRE_first_tail_x15_r0_body.trace108 : ∃ fr, PRE_first_tail_x15_r0_body.st108.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st108.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq108⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide108 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB108 : (PRE_first_tail_x15_r0_body.wide108.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st108.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix108 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide108, WFix Map.id (Present PRE_first_tail_x15_r0_body.st108.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB108 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL108
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 108 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1052`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO108 : PRE_first_tail_x15_r0_body.st108.S0.oracle = PRE_first_tail_x15_r0_body.st108.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B108 : PRE_first_tail_x15_r0_body.st108.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st108.s0.next || (PRE_first_tail_x15_r0_body.st108.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot108 : Conv.StageFoot PRE_first_tail_x15_r0_body.st108.wr PRE_first_tail_x15_r0_body.st108.s0 PRE_first_tail_x15_r0_body.st108.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st108.heapFoot PRE_first_tail_x15_r0_body.wrNodup108 PRE_first_tail_x15_r0_body.wrBound108 PRE_first_tail_x15_r0_body.wr0B108 PRE_first_tail_x15_r0_body.st108.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged108 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st108.F.S → PRE_first_tail_x15_r0_body.st108.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st108.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st108.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs108 PRE_first_tail_x15_r0_body.st108.wr PRE_first_tail_x15_r0_body.s1051 PRE_first_tail_x15_r0_body.st108.s5 PRE_first_tail_x15_r0_body.st108.s0
      PRE_first_tail_x15_r0_body.st108.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st108.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1052 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso108 PRE_first_tail_x15_r0_body.stFoot108 PRE_first_tail_x15_r0_body.wrNodup108 PRE_first_tail_x15_r0_body.wrBound108 PRE_first_tail_x15_r0_body.trace108 PRE_first_tail_x15_r0_body.mheap108
    PRE_first_tail_x15_r0_body.mnext108 PRE_first_tail_x15_r0_body.mctl108 PRE_first_tail_x15_r0_body.mstack108 PRE_first_tail_x15_r0_body.mjobs108 PRE_first_tail_x15_r0_body.mffi108 PRE_first_tail_x15_r0_body.mtrace108 PRE_first_tail_x15_r0_body.mstores108 h

def PRE_first_tail_x15_r0_body.arrEl108_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE108_2665 : arrOf PRE_first_tail_x15_r0_body.s1052 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl108_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA108_2665 : isArrB PRE_first_tail_x15_r0_body.s1052 2665 = true
theorem PRE_first_tail_x15_r0_body.arr108_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1052.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl108_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE108_2665 PRE_first_tail_x15_r0_body.arrA108_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN108_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl108_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR108_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl108_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN108_2665

def PRE_first_tail_x15_r0_body.arrEl108_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE108_2673467 : arrOf PRE_first_tail_x15_r0_body.s1052 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl108_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA108_2673467 : isArrB PRE_first_tail_x15_r0_body.s1052 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr108_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1052.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl108_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE108_2673467 PRE_first_tail_x15_r0_body.arrA108_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN108_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl108_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR108_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl108_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN108_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k108 : isArrB PRE_first_tail_x15_r0_body.s1052 4910 = false
theorem PRE_first_tail_x15_r0_body.keep108 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1052 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k108 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr108_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl108_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ108
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 108 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1051`, the merged
state `PRE_first_tail_x15_r0_body.s1052`, the canonical state `PRE_first_tail_x15_r0_body.s1053`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl108 : PRE_first_tail_x15_r0_body.pl108.all (Nat.ble PRE_first_tail_x15_r0_body.s1051.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd108 : nodupT PRE_first_tail_x15_r0_body.pl108 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1108 : Nat.ble PRE_first_tail_x15_r0_body.s1051.next 2761366 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst108 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1051.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn108 : PRE_first_tail_x15_r0_body.s1053.next = PRE_first_tail_x15_r0_body.s1051.next + PRE_first_tail_x15_r0_body.pl108.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn108 : PRE_first_tail_x15_r0_body.s1052.next = 2761366
kernel_rfl PRE_first_tail_x15_r0_body.zgrow108 : Nat.ble PRE_first_tail_x15_r0_body.s1053.next PRE_first_tail_x15_r0_body.s1052.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh108 : PRE_first_tail_x15_r0_body.S1051.tab.all (fun e => PRE_first_tail_x15_r0_body.cws108.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd108 : nodupT PRE_first_tail_x15_r0_body.cws108 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi108 : PRE_first_tail_x15_r0_body.nr108.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1052.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt108 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1051.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg108_2665 : PRE_first_tail_x15_r0_body.s1053.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1053 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk108_2665 : (objOf PRE_first_tail_x15_r0_body.s1053 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm108_2665 : PRE_first_tail_x15_r0_body.s1052.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa108.obj (objOf PRE_first_tail_x15_r0_body.s1053 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1052 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg108_2673467 : PRE_first_tail_x15_r0_body.s1053.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1053 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk108_2673467 : (objOf PRE_first_tail_x15_r0_body.s1053 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm108_2673467 : PRE_first_tail_x15_r0_body.s1052.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa108.obj (objOf PRE_first_tail_x15_r0_body.s1053 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1052 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw108_4910 : (PRE_first_tail_x15_r0_body.s1053.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw108_2673472 : (PRE_first_tail_x15_r0_body.s1053.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw108_2673473 : (PRE_first_tail_x15_r0_body.s1053.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd108 : PRE_first_tail_x15_r0_body.cl108.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr108 : PRE_first_tail_x15_r0_body.st108.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1051.next || PRE_first_tail_x15_r0_body.cl108.contains b) = true
def PRE_first_tail_x15_r0_body.zl108 : List Nat := PRE_first_tail_x15_r0_body.cl108.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE108 : PRE_first_tail_x15_r0_body.zl108.map (fun a => PRE_first_tail_x15_r0_body.s1052.heap.get (PRE_first_tail_x15_r0_body.kappa108.a a)) = PRE_first_tail_x15_r0_body.zl108.map (fun a => (PRE_first_tail_x15_r0_body.s1053.heap.get a).map PRE_first_tail_x15_r0_body.kappa108.hobj)
theorem PRE_first_tail_x15_r0_body.zimg108 : HeapImg PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.s1052 PRE_first_tail_x15_r0_body.zl108 := PRE_first_tail_x15_r0_body.zimgE108
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl108 : PRE_first_tail_x15_r0_body.s1052.ctl = PRE_first_tail_x15_r0_body.kappa108.ctl PRE_first_tail_x15_r0_body.s1053.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack108 : PRE_first_tail_x15_r0_body.s1052.stack = PRE_first_tail_x15_r0_body.s1053.stack.map PRE_first_tail_x15_r0_body.kappa108.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs108 : PRE_first_tail_x15_r0_body.s1052.jobs = PRE_first_tail_x15_r0_body.s1053.jobs.map PRE_first_tail_x15_r0_body.kappa108.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores108 : PRE_first_tail_x15_r0_body.s1052.stores = PRE_first_tail_x15_r0_body.kappa108.stores PRE_first_tail_x15_r0_body.s1053.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots108 : checkRootsSupp PRE_first_tail_x15_r0_body.s1053 4718 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC108 : PRE_first_tail_x15_r0_body.S1051.tab.length + PRE_first_tail_x15_r0_body.cws108.length = 4718
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap108 : PRE_first_tail_x15_r0_body.kappa108 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1051.next 2761366 PRE_first_tail_x15_r0_body.S1051.tab.length PRE_first_tail_x15_r0_body.pl108 (PRE_first_tail_x15_r0_body.nr108.map NumV.ref) PRE_first_tail_x15_r0_body.kd108.big
  PRE_first_tail_x15_r0_body.kd108.region PRE_first_tail_x15_r0_body.kd108.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin108 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1053.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc108 : Conv.jcleanListB (⟨20343, 17438, 2760217, 4718⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.cl108 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB108 : noBigRootsP (fun i => !Conv.oldBigB (⟨20343, 17438, 2760217, 4718⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1053.trace PRE_first_tail_x15_r0_body.s1053 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm108 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17411 = true
theorem PRE_first_tail_x15_r0_body.cjcl108 (h : Conv.JClean (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1051) : Conv.JClean (⟨20343, 17438, 2760217, 4718⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1053 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle108)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap108 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd108 a ha)) PRE_first_tail_x15_r0_body.zjc108

end Host.Load.Run.Tpl
end

section -- st108/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st108.bodyLast from PRE_first_tail_x15_r0_body.st108.s4 to PRE_first_tail_x15_r0_body.st108.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st108.F PRE_first_tail_x15_r0_body.st108.s4).run PRE_first_tail_x15_r0_body.st108.S4 = some (PRE_first_tail_x15_r0_body.st108.s5, PRE_first_tail_x15_r0_body.st108.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st108.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st108.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st108.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st108.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st108/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st108.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st108.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st108.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st108.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st108.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st108.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st108.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st108.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st108.s0 PRE_first_tail_x15_r0_body.st108.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st108.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st108.s4 PRE_first_tail_x15_r0_body.st108.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st108/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st108.bodyK0F from PRE_first_tail_x15_r0_body.st108.s0 to PRE_first_tail_x15_r0_body.st108.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st108.ks 0).getD 0) PRE_first_tail_x15_r0_body.st108.s0 PRE_first_tail_x15_r0_body.st108.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st108.s1, PRE_first_tail_x15_r0_body.st108.S1)
theorem PRE_first_tail_x15_r0_body.st108.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st108.ks 0).getD 0) PRE_first_tail_x15_r0_body.st108.s0 PRE_first_tail_x15_r0_body.st108.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st108.s1, PRE_first_tail_x15_r0_body.st108.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st108.bodyOkLN_ok PRE_first_tail_x15_r0_body.st108.bodyK0F
end Host.Load.Run.Tpl
end

section -- st108/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st108.bodyK1F from PRE_first_tail_x15_r0_body.st108.s1 to PRE_first_tail_x15_r0_body.st108.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st108.ks 1).getD 0) PRE_first_tail_x15_r0_body.st108.s1 PRE_first_tail_x15_r0_body.st108.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st108.s2, PRE_first_tail_x15_r0_body.st108.S2)
theorem PRE_first_tail_x15_r0_body.st108.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st108.ks 1).getD 0) PRE_first_tail_x15_r0_body.st108.s1 PRE_first_tail_x15_r0_body.st108.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st108.s2, PRE_first_tail_x15_r0_body.st108.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st108.bodyOkLN_ok PRE_first_tail_x15_r0_body.st108.bodyK1F
end Host.Load.Run.Tpl
end

section -- st108/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st108.bodyK2F from PRE_first_tail_x15_r0_body.st108.s2 to PRE_first_tail_x15_r0_body.st108.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st108.ks 2).getD 0) PRE_first_tail_x15_r0_body.st108.s2 PRE_first_tail_x15_r0_body.st108.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st108.s3, PRE_first_tail_x15_r0_body.st108.S3)
theorem PRE_first_tail_x15_r0_body.st108.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st108.ks 2).getD 0) PRE_first_tail_x15_r0_body.st108.s2 PRE_first_tail_x15_r0_body.st108.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st108.s3, PRE_first_tail_x15_r0_body.st108.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st108.bodyOkLN_ok PRE_first_tail_x15_r0_body.st108.bodyK2F
end Host.Load.Run.Tpl
end

section -- st108/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st108.bodyK3F from PRE_first_tail_x15_r0_body.st108.s3 to PRE_first_tail_x15_r0_body.st108.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st108.ks 3).getD 0) PRE_first_tail_x15_r0_body.st108.s3 PRE_first_tail_x15_r0_body.st108.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st108.s4, PRE_first_tail_x15_r0_body.st108.S4)
theorem PRE_first_tail_x15_r0_body.st108.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st108.ks 3).getD 0) PRE_first_tail_x15_r0_body.st108.s3 PRE_first_tail_x15_r0_body.st108.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st108.s4, PRE_first_tail_x15_r0_body.st108.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st108.bodyOkLN_ok PRE_first_tail_x15_r0_body.st108.bodyK3F
end Host.Load.Run.Tpl
end

section -- st108/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st108.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st108.s0 PRE_first_tail_x15_r0_body.st108.S0 = some (PRE_first_tail_x15_r0_body.st108.s4, PRE_first_tail_x15_r0_body.st108.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st108.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st108.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st108.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st108.ks 3).getD 0) PRE_first_tail_x15_r0_body.st108.s0 PRE_first_tail_x15_r0_body.st108.s3 PRE_first_tail_x15_r0_body.st108.s4 PRE_first_tail_x15_r0_body.st108.S0 PRE_first_tail_x15_r0_body.st108.S3 PRE_first_tail_x15_r0_body.st108.S4 (runOk_trans PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st108.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st108.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st108.ks 2).getD 0) PRE_first_tail_x15_r0_body.st108.s0 PRE_first_tail_x15_r0_body.st108.s2 PRE_first_tail_x15_r0_body.st108.s3 PRE_first_tail_x15_r0_body.st108.S0 PRE_first_tail_x15_r0_body.st108.S2 PRE_first_tail_x15_r0_body.st108.S3 (runOk_trans PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st108.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st108.ks 1).getD 0) PRE_first_tail_x15_r0_body.st108.s0 PRE_first_tail_x15_r0_body.st108.s1 PRE_first_tail_x15_r0_body.st108.s2 PRE_first_tail_x15_r0_body.st108.S0 PRE_first_tail_x15_r0_body.st108.S1 PRE_first_tail_x15_r0_body.st108.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st108.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st108.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st108.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st108.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st108.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st108.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st108.s0
  S0 := PRE_first_tail_x15_r0_body.st108.S0
  s1 := PRE_first_tail_x15_r0_body.st108.s4
  S1 := PRE_first_tail_x15_r0_body.st108.S4
  s2 := PRE_first_tail_x15_r0_body.st108.s5
  S2 := PRE_first_tail_x15_r0_body.st108.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st108.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st108.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st108.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st108.bodyHalt
  last := PRE_first_tail_x15_r0_body.st108.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st108.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC109
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 109 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1061` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa109` into the merged state
`PRE_first_tail_x15_r0_body.s1060`. -/

def PRE_first_tail_x15_r0_body.pl109 : List Nat := []
def PRE_first_tail_x15_r0_body.nr109 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd109 : RData :=
  ⟨2760707, 2760709, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20356, 20356, 17451, 17451, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa109 : Map :=
  Conv.Map.compact 2760707 2760709 4739 PRE_first_tail_x15_r0_body.pl109 (PRE_first_tail_x15_r0_body.nr109.map NumV.ref) PRE_first_tail_x15_r0_body.kd109.big
    PRE_first_tail_x15_r0_body.kd109.region PRE_first_tail_x15_r0_body.kd109.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws109 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs109 : List SymE := PRE_first_tail_x15_r0_body.nr109.map fun r => (nth? PRE_first_tail_x15_r0_body.S1060.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta109 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws109 PRE_first_tail_x15_r0_body.crs109
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB109 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab109 : PRE_first_tail_x15_r0_body.S1061.tab = PRE_first_tail_x15_r0_body.S1059.tab ++ PRE_first_tail_x15_r0_body.cws109.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace109 : PRE_first_tail_x15_r0_body.s1061.trace = PRE_first_tail_x15_r0_body.s1059.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext109 : PRE_first_tail_x15_r0_body.s1061.next = 2760707
kernel_rfl PRE_first_tail_x15_r0_body.ccounters109 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.nnext) = (20356, 17451)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue109 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1060.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa109.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp109 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.tokens.all (bSN 4739) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean109 : Conv.cleanListB 20356 131072 (fun r => Nat.ble 81424 r) PRE_first_tail_x15_r0_body.s1061
    (PRE_first_tail_x15_r0_body.wrB109 ++ (List.range 0).map (2760707 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs109 : bigsOutB 20356 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK109
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl109`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl109 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo109 : List Nat := []
def PRE_first_tail_x15_r0_body.cln109 : List Nat := []
def PRE_first_tail_x15_r0_body.cli109 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap109 : PRE_first_tail_x15_r0_body.s1061.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1059.heap (PRE_first_tail_x15_r0_body.cl109.filterMap fun a => (PRE_first_tail_x15_r0_body.s1061.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe109 : Nat.ble PRE_first_tail_x15_r0_body.s1059.next PRE_first_tail_x15_r0_body.s1061.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP109 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1059 PRE_first_tail_x15_r0_body.s1061 PRE_first_tail_x15_r0_body.cl109 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp109 : Conv.suppListB PRE_first_tail_x15_r0_body.s1061 4739 PRE_first_tail_x15_r0_body.cl109 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound109 : Conv.boundListB PRE_first_tail_x15_r0_body.s1061 PRE_first_tail_x15_r0_body.cl109 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK109 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln109.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK109 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo109.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK109 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli109.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst109 : Conv.sstListB 4739 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx PRE_first_tail_x15_r0_body.cln109 PRE_first_tail_x15_r0_body.clo109 PRE_first_tail_x15_r0_body.cli109 = true

end Host.Load.Run.Tpl
end

section -- SiteCl109
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA109 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo109.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd109 : (PRE_first_tail_x15_r0_body.clo109 ++ PRE_first_tail_x15_r0_body.cln109 ++ PRE_first_tail_x15_r0_body.cli109).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle109 : Conv.Cnt.leB (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck109 : Conv.ncleanListB (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx PRE_first_tail_x15_r0_body.clo109 PRE_first_tail_x15_r0_body.cln109 PRE_first_tail_x15_r0_body.cli109 = true
theorem PRE_first_tail_x15_r0_body.cncl109 (h : Conv.NClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx) : Conv.NClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle109 PRE_first_tail_x15_r0_body.ckA109 PRE_first_tail_x15_r0_body.cobjsK109 PRE_first_tail_x15_r0_body.cnodesK109 PRE_first_tail_x15_r0_body.citemsK109 PRE_first_tail_x15_r0_body.cbd109 PRE_first_tail_x15_r0_body.cck109

end Host.Load.Run.Tpl
end

section -- SiteS109
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 109 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc109 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P109 : LoadP := PRE_first_tail_x15_r0_body.Pc109.raise 17451
kernel_rfl PRE_first_tail_x15_r0_body.craise109 : Nat.ble PRE_first_tail_x15_r0_body.Pc109.N0 17451 = true
theorem PRE_first_tail_x15_r0_body.raised109 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc109 PRE_first_tail_x15_r0_body.P109 :=
  .inr ⟨17451, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise109, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_109 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_109 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1060.ffi)
def PRE_first_tail_x15_r0_body.khinv109 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv109 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS109 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS109 : List Nat := List.range' 17451 0
def PRE_first_tail_x15_r0_body.ciS109 : List Nat := [] ++ List.range' 17451 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0109 : PRE_first_tail_x15_r0_body.kd109.nh0 = PRE_first_tail_x15_r0_body.cx0_109.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1109 : PRE_first_tail_x15_r0_body.kd109.nh1 = PRE_first_tail_x15_r0_body.cx1_109.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0109 : PRE_first_tail_x15_r0_body.kd109.nn0 = PRE_first_tail_x15_r0_body.cx0_109.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1109 : PRE_first_tail_x15_r0_body.kd109.nn1 = PRE_first_tail_x15_r0_body.cx1_109.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo109 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P109.lo && Nat.ble PRE_first_tail_x15_r0_body.P109.lo PRE_first_tail_x15_r0_body.cx0_109.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P109.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P109.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt109 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_109.mlx.next PRE_first_tail_x15_r0_body.cx1_109.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_109.mlx.nnext PRE_first_tail_x15_r0_body.cx1_109.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband109 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P109.NL && Nat.ble PRE_first_tail_x15_r0_body.P109.NL PRE_first_tail_x15_r0_body.P109.N0 && Nat.ble PRE_first_tail_x15_r0_body.P109.N0 PRE_first_tail_x15_r0_body.cx0_109.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow109 : PRE_first_tail_x15_r0_body.kd109.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren109 : checkRenG PRE_first_tail_x15_r0_body.kd109.hnd PRE_first_tail_x15_r0_body.khinv109 (phB PRE_first_tail_x15_r0_body.cx0_109.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband109 : PRE_first_tail_x15_r0_body.kd109.checkBand PRE_first_tail_x15_r0_body.P109.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos109 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd109.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren109 : checkRenG PRE_first_tail_x15_r0_body.kd109.node PRE_first_tail_x15_r0_body.kninv109 (pnB PRE_first_tail_x15_r0_body.cx0_109.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P109.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd109.nodeF j) PRE_first_tail_x15_r0_body.cx1_109.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a109 : PRE_first_tail_x15_r0_body.cx0_109.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b109 : PRE_first_tail_x15_r0_body.cx0_109.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.pending = PRE_first_tail_x15_r0_body.cx0_109.mlx.pending.map PRE_first_tail_x15_r0_body.kappa109.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.errh = PRE_first_tail_x15_r0_body.cx0_109.mlx.errh.map PRE_first_tail_x15_r0_body.kappa109.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.files = PRE_first_tail_x15_r0_body.cx0_109.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.arch = PRE_first_tail_x15_r0_body.cx0_109.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_109.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.wired = PRE_first_tail_x15_r0_body.cx0_109.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost109 : PRE_first_tail_x15_r0_body.cx1_109.host = PRE_first_tail_x15_r0_body.cx0_109.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd109`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0109 : PRE_first_tail_x15_r0_body.kd109.n0 = 2760707
kernel_rfl PRE_first_tail_x15_r0_body.ckn1109 : PRE_first_tail_x15_r0_body.kd109.n1 = 2760709
kernel_rfl PRE_first_tail_x15_r0_body.ckheap109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.heap).all (fun x => Nat.ble 2760707 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl109 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd109.heap.get (2760707 + j) = nth? PRE_first_tail_x15_r0_body.pl109 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja109 : Nat.ble 2760707 2760707 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn109 : Nat.ble 4739 4739 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD109 : Nat.ble 2760707 PRE_first_tail_x15_r0_body.kd109.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn109 : Nat.ble 20356 PRE_first_tail_x15_r0_body.kd109.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn109 : Nat.ble 17451 PRE_first_tail_x15_r0_body.kd109.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb109 : Nat.ble 20356 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.heap).all (Nat.ble (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.hnd).all (Nat.ble (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.node).all (Nat.ble (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix109 : Conv.FixOld (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa109 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja109) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn109) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD109) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn109) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn109) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb109) PRE_first_tail_x15_r0_body.fheap109 PRE_first_tail_x15_r0_body.fhnd109 PRE_first_tail_x15_r0_body.fnode109
kernel_rfl PRE_first_tail_x15_r0_body.fcxn109 : (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn109 : (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0109 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_109.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_109.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS109.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_109.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS109.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_109.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS109.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_109.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS109.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_109.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd109 : (PRE_first_tail_x15_r0_body.clo109 ++ PRE_first_tail_x15_r0_body.cln109 ++ PRE_first_tail_x15_r0_body.cli109 ++ PRE_first_tail_x15_r0_body.cwS109 ++ PRE_first_tail_x15_r0_body.cnS109 ++ PRE_first_tail_x15_r0_body.ciS109).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW109 : PRE_first_tail_x15_r0_body.cwS109.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo109.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI109 : PRE_first_tail_x15_r0_body.ciS109.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli109.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN109 : PRE_first_tail_x15_r0_body.cnS109.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF109 : PRE_first_tail_x15_r0_body.cln109.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh109 : PRE_first_tail_x15_r0_body.clo109.all (handleOK PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.P109.lo PRE_first_tail_x15_r0_body.cx0_109.mlx PRE_first_tail_x15_r0_body.cx1_109.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo109 : PRE_first_tail_x15_r0_body.clo109.map (fun h => PRE_first_tail_x15_r0_body.cx1_109.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa109.handle h)) = PRE_first_tail_x15_r0_body.clo109.map (fun h => (PRE_first_tail_x15_r0_body.cx0_109.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa109.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok109 : PRE_first_tail_x15_r0_body.clo109.all (objOK PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.P109.NL PRE_first_tail_x15_r0_body.cx0_109.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd109 : PRE_first_tail_x15_r0_body.cln109.all (nodeOKF PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.P109 PRE_first_tail_x15_r0_body.cx0_109.mlx PRE_first_tail_x15_r0_body.cx1_109.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp109 : ((PRE_first_tail_x15_r0_body.cln109.filter (fullB PRE_first_tail_x15_r0_body.P109))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_109.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa109.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln109.filter (fullB PRE_first_tail_x15_r0_body.P109))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_109.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa109.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI109 : incrB PRE_first_tail_x15_r0_body.kd109.nodeF (List.range' 17451 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.node).all (fun k => Nat.ble 17451 k && Nat.blt k 17451) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL109 : (PRE_first_tail_x15_r0_body.cln109.filter (Nat.ble PRE_first_tail_x15_r0_body.P109.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd109.nodeF i) && (Nat.blt i 17451 || Nat.ble PRE_first_tail_x15_r0_body.kd109.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord109 : (PRE_first_tail_x15_r0_body.cln109.filter (Nat.ble PRE_first_tail_x15_r0_body.P109.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd109.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd109.nodeF j) (PRE_first_tail_x15_r0_body.kd109.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow109 PRE_first_tail_x15_r0_body.cnn1109 PRE_first_tail_x15_r0_body.fnordI109 PRE_first_tail_x15_r0_body.fnordK109 PRE_first_tail_x15_r0_body.fnordL109
kernel_rfl PRE_first_tail_x15_r0_body.fi109 : PRE_first_tail_x15_r0_body.cli109.all (pnB PRE_first_tail_x15_r0_body.cx0_109.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii109 : PRE_first_tail_x15_r0_body.cli109.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_109.mlx.items.get (PRE_first_tail_x15_r0_body.kappa109.node k) = (PRE_first_tail_x15_r0_body.cx0_109.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa109.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot109 (clean : Conv.NClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P109.NL) (cl : SSt (· < 4739) PRE_first_tail_x15_r0_body.cx0_109.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P109 4739 PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.kd109 PRE_first_tail_x15_r0_body.khinv109 PRE_first_tail_x15_r0_body.kninv109 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx PRE_first_tail_x15_r0_body.cx0_109.mlx PRE_first_tail_x15_r0_body.cx1_109.mlx (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo109 PRE_first_tail_x15_r0_body.cln109 PRE_first_tail_x15_r0_body.cli109 PRE_first_tail_x15_r0_body.cwS109 PRE_first_tail_x15_r0_body.cnS109 PRE_first_tail_x15_r0_body.ciS109 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0109, PRE_first_tail_x15_r0_body.cnh1109, PRE_first_tail_x15_r0_body.cnn0109, PRE_first_tail_x15_r0_body.cnn1109, PRE_first_tail_x15_r0_body.cplo109, PRE_first_tail_x15_r0_body.ccnt109, PRE_first_tail_x15_r0_body.cnband109, PRE_first_tail_x15_r0_body.chbelow109, PRE_first_tail_x15_r0_body.chren109, PRE_first_tail_x15_r0_body.cband109, PRE_first_tail_x15_r0_body.cnh1pos109, PRE_first_tail_x15_r0_body.cnren109, PRE_first_tail_x15_r0_body.cnlow109, PRE_first_tail_x15_r0_body.cabs0a109, PRE_first_tail_x15_r0_body.cabs0b109, PRE_first_tail_x15_r0_body.ctok1109, PRE_first_tail_x15_r0_body.cpend109, PRE_first_tail_x15_r0_body.cerrh109, PRE_first_tail_x15_r0_body.cfiles109, PRE_first_tail_x15_r0_body.carch109, PRE_first_tail_x15_r0_body.csizes109, PRE_first_tail_x15_r0_body.cwired109, PRE_first_tail_x15_r0_body.cfix109, clean, PRE_first_tail_x15_r0_body.fcxn109, PRE_first_tail_x15_r0_body.fcnn109, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0109, PRE_first_tail_x15_r0_body.fnk109, PRE_first_tail_x15_r0_body.ckA109, PRE_first_tail_x15_r0_body.cobjsK109, PRE_first_tail_x15_r0_body.cnodesK109, PRE_first_tail_x15_r0_body.citemsK109, PRE_first_tail_x15_r0_body.f1A109, PRE_first_tail_x15_r0_body.f1O109, PRE_first_tail_x15_r0_body.f1N109, PRE_first_tail_x15_r0_body.f1I109, PRE_first_tail_x15_r0_body.fbd109, PRE_first_tail_x15_r0_body.fincW109, PRE_first_tail_x15_r0_body.fincI109, PRE_first_tail_x15_r0_body.fincN109, PRE_first_tail_x15_r0_body.flnF109, PRE_first_tail_x15_r0_body.fh109, PRE_first_tail_x15_r0_body.fo109, PRE_first_tail_x15_r0_body.fok109, PRE_first_tail_x15_r0_body.fnd109, PRE_first_tail_x15_r0_body.fp109, PRE_first_tail_x15_r0_body.fnord109, PRE_first_tail_x15_r0_body.fi109, PRE_first_tail_x15_r0_body.fii109⟩
theorem PRE_first_tail_x15_r0_body.cnshift109 (clean : Conv.NClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P109.NL) (cl : SSt (· < 4739) PRE_first_tail_x15_r0_body.cx0_109.mlx) : NShift PRE_first_tail_x15_r0_body.P109 4739 PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.cx0_109 PRE_first_tail_x15_r0_body.cx1_109 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot109 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost109 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0109 PRE_first_tail_x15_r0_body.ckn1109 PRE_first_tail_x15_r0_body.ckheap109 PRE_first_tail_x15_r0_body.ckpl109)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_109 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1059.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_109 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1059.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_109 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1059.ffi) = some PRE_first_tail_x15_r0_body.fxC_109
kernel_rfl PRE_first_tail_x15_r0_body.okrC_109 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1059.ffi) = some PRE_first_tail_x15_r0_body.krC_109
noncomputable def PRE_first_tail_x15_r0_body.fx0_109 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1061.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_109 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1061.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_109 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1061.ffi) = some PRE_first_tail_x15_r0_body.fx0_109
kernel_rfl PRE_first_tail_x15_r0_body.okr0_109 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1061.ffi) = some PRE_first_tail_x15_r0_body.kr0_109
noncomputable def PRE_first_tail_x15_r0_body.fx1_109 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1060.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_109 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1060.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_109 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1060.ffi) = some PRE_first_tail_x15_r0_body.fx1_109
kernel_rfl PRE_first_tail_x15_r0_body.okr1_109 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1060.ffi) = some PRE_first_tail_x15_r0_body.kr1_109
kernel_rfl PRE_first_tail_x15_r0_body.ff0109 : PRE_first_tail_x15_r0_body.fx0_109 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_109 (PRE_first_tail_x15_r0_body.clo109.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_109.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1109 : PRE_first_tail_x15_r0_body.fx1_109 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_109 (PRE_first_tail_x15_r0_body.cwS109.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_109.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck109 : freedLB PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.cx0_109.mlx PRE_first_tail_x15_r0_body.fx0_109 PRE_first_tail_x15_r0_body.fx1_109 PRE_first_tail_x15_r0_body.clo109 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0109 : PRE_first_tail_x15_r0_body.kr0_109.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_109.flags (PRE_first_tail_x15_r0_body.clo109.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_109.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0109 : PRE_first_tail_x15_r0_body.kr0_109.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_109.targs (PRE_first_tail_x15_r0_body.clo109.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_109.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1109 : PRE_first_tail_x15_r0_body.kr1_109.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_109.flags (PRE_first_tail_x15_r0_body.cwS109.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_109.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1109 : PRE_first_tail_x15_r0_body.kr1_109.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_109.targs (PRE_first_tail_x15_r0_body.cwS109.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_109.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck109 : krecLB PRE_first_tail_x15_r0_body.kappa109 4739 PRE_first_tail_x15_r0_body.cx0_109.mlx PRE_first_tail_x15_r0_body.kr0_109 PRE_first_tail_x15_r0_body.kr1_109 PRE_first_tail_x15_r0_body.clo109 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn109 : Nat.ble 4739 4739 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge109 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1060.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1061.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR109 : pendRegB PRE_first_tail_x15_r0_body.kappa109 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe109 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1060.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift109 (clean : Conv.NClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P109.NL) (cl : SSt (· < 4739) PRE_first_tail_x15_r0_body.cx0_109.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_109.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_109.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_109.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_109.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P109 4739 PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.s1061.ffi PRE_first_tail_x15_r0_body.s1060.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift109 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue109, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp109 t ht),
    PRE_first_tail_x15_r0_body.cbridge109,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1061.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1060.ffi) (PRE_first_tail_x15_r0_body.cfoot109 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_109 PRE_first_tail_x15_r0_body.ofx1_109 hobjC PRE_first_tail_x15_r0_body.ff0109 PRE_first_tail_x15_r0_body.ff1109 PRE_first_tail_x15_r0_body.ffck109,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1061.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1060.ffi) (PRE_first_tail_x15_r0_body.cfoot109 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_109 PRE_first_tail_x15_r0_body.okr1_109 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn109) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0109 PRE_first_tail_x15_r0_body.fkt0109 PRE_first_tail_x15_r0_body.fkf1109 PRE_first_tail_x15_r0_body.fkt1109 PRE_first_tail_x15_r0_body.fkck109,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0109 PRE_first_tail_x15_r0_body.cnh1109 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe109) PRE_first_tail_x15_r0_body.cpendR109⟩

end Host.Load.Run.Tpl
end

section -- st109/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st109 0
host_stream_state PRE_first_tail_x15_r0_body.st109 1
host_stream_state PRE_first_tail_x15_r0_body.st109 2
end Host.Load.Run.Tpl
end

section -- Site109
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 109 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g109__g110` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1059`, the merged state `PRE_first_tail_x15_r0_body.s1060`,
the site template `PRE_first_tail_x15_r0_body.st109` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1061`: the merge.
The footprint's facts are in `SiteF109`, the compaction's in `SiteC109`, `SiteK109`, `SiteNa109`, `SiteNb109`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso109 : PRE_first_tail_x15_r0_body.st109.s0 = { PRE_first_tail_x15_r0_body.s1059 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs109 : List Frame := PRE_first_tail_x15_r0_body.s1059.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_109 : PRE_first_tail_x15_r0_body.S1059.tab.length = 4739
kernel_rfl PRE_first_tail_x15_r0_body.tab0_109 : PRE_first_tail_x15_r0_body.st109.S0.tab = PRE_first_tail_x15_r0_body.S1059.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws109 : List Nat := [2852, 2853]
kernel_rfl PRE_first_tail_x15_r0_body.fresh109 : (PRE_first_tail_x15_r0_body.S1059.tab.all fun e => PRE_first_tail_x15_r0_body.ws109.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1059.oracle.all fun q => PRE_first_tail_x15_r0_body.ws109.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab109 : PRE_first_tail_x15_r0_body.S1060.tab = PRE_first_tail_x15_r0_body.S1059.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws109
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen109 : PRE_first_tail_x15_r0_body.st109.S2.tab.length - PRE_first_tail_x15_r0_body.st109.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged109`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap109 : PRE_first_tail_x15_r0_body.s1060.heap = PRE_first_tail_x15_r0_body.st109.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext109 : PRE_first_tail_x15_r0_body.s1060.next = PRE_first_tail_x15_r0_body.st109.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl109 : PRE_first_tail_x15_r0_body.s1060.ctl = PRE_first_tail_x15_r0_body.st109.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack109 : PRE_first_tail_x15_r0_body.s1060.stack = PRE_first_tail_x15_r0_body.st109.s2.stack ++ PRE_first_tail_x15_r0_body.s1059.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs109 : PRE_first_tail_x15_r0_body.s1060.jobs = PRE_first_tail_x15_r0_body.st109.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi109 : PRE_first_tail_x15_r0_body.s1060.ffi = PRE_first_tail_x15_r0_body.st109.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace109 : PRE_first_tail_x15_r0_body.s1060.trace = PRE_first_tail_x15_r0_body.st109.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores109 : PRE_first_tail_x15_r0_body.s1060.stores = PRE_first_tail_x15_r0_body.st109.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD109
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 109 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived109 : PRE_first_tail_x15_r0_body.nr109.map (fun r => nth? PRE_first_tail_x15_r0_body.st109.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo109 : PRE_first_tail_x15_r0_body.nr109.all (Nat.ble 4739) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj109 : PRE_first_tail_x15_r0_body.cws109.all (fun c => !PRE_first_tail_x15_r0_body.ws109.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ109 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws109 PRE_first_tail_x15_r0_body.crs109 PRE_first_tail_x15_r0_body.ws109

end Host.Load.Run.Tpl
end

section -- st109/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st109`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st109.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st109.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st109.s2.heap PRE_first_tail_x15_r0_body.st109.wrR ++ freshOf PRE_first_tail_x15_r0_body.st109.s2.heap PRE_first_tail_x15_r0_body.st109.s0.next PRE_first_tail_x15_r0_body.st109.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st109.wr : List Nat := PRE_first_tail_x15_r0_body.st109.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st109.heapFoot : PRE_first_tail_x15_r0_body.st109.s2.heap = setAll PRE_first_tail_x15_r0_body.st109.s0.heap PRE_first_tail_x15_r0_body.st109.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st109.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st109.s0.next PRE_first_tail_x15_r0_body.st109.s2.next = true
theorem PRE_first_tail_x15_r0_body.st109.grows : PRE_first_tail_x15_r0_body.st109.s0.next ≤ PRE_first_tail_x15_r0_body.st109.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st109.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st109.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st109.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st109.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st109.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st109.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st109.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st109.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st109.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st109.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st109.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st109.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF109
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 109 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB109 : nodupT PRE_first_tail_x15_r0_body.st109.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup109 : PRE_first_tail_x15_r0_body.st109.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB109).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB109 : PRE_first_tail_x15_r0_body.st109.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound109 : ∀ b ∈ PRE_first_tail_x15_r0_body.st109.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB109 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr109 := PRE_first_tail_x15_r0_body.st109.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq109 : PRE_first_tail_x15_r0_body.st109.s2.trace = PRE_first_tail_x15_r0_body.trFr109 ++ PRE_first_tail_x15_r0_body.st109.s0.trace
theorem PRE_first_tail_x15_r0_body.trace109 : ∃ fr, PRE_first_tail_x15_r0_body.st109.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st109.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq109⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide109 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB109 : (PRE_first_tail_x15_r0_body.wide109.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st109.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix109 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide109, WFix Map.id (Present PRE_first_tail_x15_r0_body.st109.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB109 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL109
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 109 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1060`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO109 : PRE_first_tail_x15_r0_body.st109.S0.oracle = PRE_first_tail_x15_r0_body.st109.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B109 : PRE_first_tail_x15_r0_body.st109.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st109.s0.next || (PRE_first_tail_x15_r0_body.st109.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot109 : Conv.StageFoot PRE_first_tail_x15_r0_body.st109.wr PRE_first_tail_x15_r0_body.st109.s0 PRE_first_tail_x15_r0_body.st109.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st109.heapFoot PRE_first_tail_x15_r0_body.wrNodup109 PRE_first_tail_x15_r0_body.wrBound109 PRE_first_tail_x15_r0_body.wr0B109 PRE_first_tail_x15_r0_body.st109.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged109 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st109.F.S → PRE_first_tail_x15_r0_body.st109.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st109.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st109.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs109 PRE_first_tail_x15_r0_body.st109.wr PRE_first_tail_x15_r0_body.s1059 PRE_first_tail_x15_r0_body.st109.s2 PRE_first_tail_x15_r0_body.st109.s0
      PRE_first_tail_x15_r0_body.st109.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st109.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1060 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso109 PRE_first_tail_x15_r0_body.stFoot109 PRE_first_tail_x15_r0_body.wrNodup109 PRE_first_tail_x15_r0_body.wrBound109 PRE_first_tail_x15_r0_body.trace109 PRE_first_tail_x15_r0_body.mheap109
    PRE_first_tail_x15_r0_body.mnext109 PRE_first_tail_x15_r0_body.mctl109 PRE_first_tail_x15_r0_body.mstack109 PRE_first_tail_x15_r0_body.mjobs109 PRE_first_tail_x15_r0_body.mffi109 PRE_first_tail_x15_r0_body.mtrace109 PRE_first_tail_x15_r0_body.mstores109 h

def PRE_first_tail_x15_r0_body.arrEl109_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE109_2665 : arrOf PRE_first_tail_x15_r0_body.s1060 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl109_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA109_2665 : isArrB PRE_first_tail_x15_r0_body.s1060 2665 = true
theorem PRE_first_tail_x15_r0_body.arr109_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1060.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl109_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE109_2665 PRE_first_tail_x15_r0_body.arrA109_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN109_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl109_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR109_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl109_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN109_2665

def PRE_first_tail_x15_r0_body.arrEl109_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE109_2673467 : arrOf PRE_first_tail_x15_r0_body.s1060 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl109_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA109_2673467 : isArrB PRE_first_tail_x15_r0_body.s1060 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr109_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1060.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl109_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE109_2673467 PRE_first_tail_x15_r0_body.arrA109_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN109_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl109_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR109_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl109_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN109_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k109 : isArrB PRE_first_tail_x15_r0_body.s1060 4910 = false
theorem PRE_first_tail_x15_r0_body.keep109 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1060 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k109 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr109_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl109_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ109
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 109 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1059`, the merged
state `PRE_first_tail_x15_r0_body.s1060`, the canonical state `PRE_first_tail_x15_r0_body.s1061`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl109 : PRE_first_tail_x15_r0_body.pl109.all (Nat.ble PRE_first_tail_x15_r0_body.s1059.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd109 : nodupT PRE_first_tail_x15_r0_body.pl109 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1109 : Nat.ble PRE_first_tail_x15_r0_body.s1059.next 2760709 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst109 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1059.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn109 : PRE_first_tail_x15_r0_body.s1061.next = PRE_first_tail_x15_r0_body.s1059.next + PRE_first_tail_x15_r0_body.pl109.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn109 : PRE_first_tail_x15_r0_body.s1060.next = 2760709
kernel_rfl PRE_first_tail_x15_r0_body.zgrow109 : Nat.ble PRE_first_tail_x15_r0_body.s1061.next PRE_first_tail_x15_r0_body.s1060.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh109 : PRE_first_tail_x15_r0_body.S1059.tab.all (fun e => PRE_first_tail_x15_r0_body.cws109.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd109 : nodupT PRE_first_tail_x15_r0_body.cws109 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi109 : PRE_first_tail_x15_r0_body.nr109.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1060.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt109 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1059.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg109_2665 : PRE_first_tail_x15_r0_body.s1061.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1061 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk109_2665 : (objOf PRE_first_tail_x15_r0_body.s1061 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm109_2665 : PRE_first_tail_x15_r0_body.s1060.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa109.obj (objOf PRE_first_tail_x15_r0_body.s1061 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1060 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg109_2673467 : PRE_first_tail_x15_r0_body.s1061.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1061 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk109_2673467 : (objOf PRE_first_tail_x15_r0_body.s1061 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm109_2673467 : PRE_first_tail_x15_r0_body.s1060.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa109.obj (objOf PRE_first_tail_x15_r0_body.s1061 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1060 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw109_4910 : (PRE_first_tail_x15_r0_body.s1061.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw109_2673472 : (PRE_first_tail_x15_r0_body.s1061.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw109_2673473 : (PRE_first_tail_x15_r0_body.s1061.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd109 : PRE_first_tail_x15_r0_body.cl109.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr109 : PRE_first_tail_x15_r0_body.st109.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1059.next || PRE_first_tail_x15_r0_body.cl109.contains b) = true
def PRE_first_tail_x15_r0_body.zl109 : List Nat := PRE_first_tail_x15_r0_body.cl109.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE109 : PRE_first_tail_x15_r0_body.zl109.map (fun a => PRE_first_tail_x15_r0_body.s1060.heap.get (PRE_first_tail_x15_r0_body.kappa109.a a)) = PRE_first_tail_x15_r0_body.zl109.map (fun a => (PRE_first_tail_x15_r0_body.s1061.heap.get a).map PRE_first_tail_x15_r0_body.kappa109.hobj)
theorem PRE_first_tail_x15_r0_body.zimg109 : HeapImg PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.s1061 PRE_first_tail_x15_r0_body.s1060 PRE_first_tail_x15_r0_body.zl109 := PRE_first_tail_x15_r0_body.zimgE109
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl109 : PRE_first_tail_x15_r0_body.s1060.ctl = PRE_first_tail_x15_r0_body.kappa109.ctl PRE_first_tail_x15_r0_body.s1061.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack109 : PRE_first_tail_x15_r0_body.s1060.stack = PRE_first_tail_x15_r0_body.s1061.stack.map PRE_first_tail_x15_r0_body.kappa109.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs109 : PRE_first_tail_x15_r0_body.s1060.jobs = PRE_first_tail_x15_r0_body.s1061.jobs.map PRE_first_tail_x15_r0_body.kappa109.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores109 : PRE_first_tail_x15_r0_body.s1060.stores = PRE_first_tail_x15_r0_body.kappa109.stores PRE_first_tail_x15_r0_body.s1061.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots109 : checkRootsSupp PRE_first_tail_x15_r0_body.s1061 4739 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC109 : PRE_first_tail_x15_r0_body.S1059.tab.length + PRE_first_tail_x15_r0_body.cws109.length = 4739
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap109 : PRE_first_tail_x15_r0_body.kappa109 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1059.next 2760709 PRE_first_tail_x15_r0_body.S1059.tab.length PRE_first_tail_x15_r0_body.pl109 (PRE_first_tail_x15_r0_body.nr109.map NumV.ref) PRE_first_tail_x15_r0_body.kd109.big
  PRE_first_tail_x15_r0_body.kd109.region PRE_first_tail_x15_r0_body.kd109.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin109 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1061.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc109 : Conv.jcleanListB (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1061 PRE_first_tail_x15_r0_body.cl109 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB109 : noBigRootsP (fun i => !Conv.oldBigB (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1061.trace PRE_first_tail_x15_r0_body.s1061 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm109 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17451 = true
theorem PRE_first_tail_x15_r0_body.cjcl109 (h : Conv.JClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1059) : Conv.JClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1061 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle109)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap109 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd109 a ha)) PRE_first_tail_x15_r0_body.zjc109

end Host.Load.Run.Tpl
end

section -- st109/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st109.bodyLast from PRE_first_tail_x15_r0_body.st109.s1 to PRE_first_tail_x15_r0_body.st109.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st109.F PRE_first_tail_x15_r0_body.st109.s1).run PRE_first_tail_x15_r0_body.st109.S1 = some (PRE_first_tail_x15_r0_body.st109.s2, PRE_first_tail_x15_r0_body.st109.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st109.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st109.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st109.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st109.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st109/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st109.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st109.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st109.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st109.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st109.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st109.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st109.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st109.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st109.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st109.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st109.s0 PRE_first_tail_x15_r0_body.st109.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st109.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st109.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st109.s1 PRE_first_tail_x15_r0_body.st109.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end
