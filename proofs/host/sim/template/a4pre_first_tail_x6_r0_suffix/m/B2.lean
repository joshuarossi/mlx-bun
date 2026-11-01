import host.sim.template.a4pre_first_tail_x6_r0_suffix.m.B0
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen
import host.sim.stage.Mlx
import host.sim.conv.Closed
import host.sim.conv.NClean
import host.sim.conv.CompactFull
import host.sim.template.FootGen
import host.sim.template.a4pre_first_tail_x6_r0_suffix.States
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

/-! The compaction after the merge at call site 0 of chain `PRE_first_tail_x6_r0_suffix` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_suffix.s4` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_suffix.kappa0` into the merged state
`PRE_first_tail_x6_r0_suffix.s3`. -/

def PRE_first_tail_x6_r0_suffix.pl0 : List Nat := []
def PRE_first_tail_x6_r0_suffix.nr0 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_suffix.kd0 : RData :=
  ⟨2825030, 2828013, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21966, 21967, 19057, 19057, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_suffix.kappa0 : Map :=
  Conv.Map.compact 2825030 2828013 8226 PRE_first_tail_x6_r0_suffix.pl0 (PRE_first_tail_x6_r0_suffix.nr0.map NumV.ref) PRE_first_tail_x6_r0_suffix.kd0.big
    PRE_first_tail_x6_r0_suffix.kd0.region PRE_first_tail_x6_r0_suffix.kd0.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_suffix.cws0 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_suffix.crs0 : List SymE := PRE_first_tail_x6_r0_suffix.nr0.map fun r => (nth? PRE_first_tail_x6_r0_suffix.S3.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_suffix.ctheta0 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_suffix.cws0 PRE_first_tail_x6_r0_suffix.crs0
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_suffix.wrB0 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_suffix.ctab0 : PRE_first_tail_x6_r0_suffix.S4.tab = PRE_first_tail_x6_r0_suffix.S2.tab ++ PRE_first_tail_x6_r0_suffix.cws0.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_suffix.ctrace0 : PRE_first_tail_x6_r0_suffix.s4.trace = PRE_first_tail_x6_r0_suffix.s2.trace
kernel_rfl PRE_first_tail_x6_r0_suffix.cnext0 : PRE_first_tail_x6_r0_suffix.s4.next = 2825030
kernel_rfl PRE_first_tail_x6_r0_suffix.ccounters0 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx.nnext) = (21966, 19057)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_suffix.cqueue0 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s3.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx.tokens.map PRE_first_tail_x6_r0_suffix.kappa0.nv
kernel_rfl PRE_first_tail_x6_r0_suffix.ctokSupp0 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx.tokens.all (bSN 8226) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_suffix.cclean0 : Conv.cleanListB 21966 131072 (fun r => Nat.ble 87864 r) PRE_first_tail_x6_r0_suffix.s4
    (PRE_first_tail_x6_r0_suffix.wrB0 ++ (List.range 0).map (2825030 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.cbigs0 : bigsOutB 21966 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_suffix.cl0`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_suffix.cl0 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_suffix.clo0 : List Nat := []
def PRE_first_tail_x6_r0_suffix.cln0 : List Nat := []
def PRE_first_tail_x6_r0_suffix.cli0 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_suffix.cheap0 : PRE_first_tail_x6_r0_suffix.s4.heap = Stage.setAll PRE_first_tail_x6_r0_suffix.s2.heap (PRE_first_tail_x6_r0_suffix.cl0.filterMap fun a => (PRE_first_tail_x6_r0_suffix.s4.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.cnextLe0 : Nat.ble PRE_first_tail_x6_r0_suffix.s2.next PRE_first_tail_x6_r0_suffix.s4.next = true
kernel_rfl PRE_first_tail_x6_r0_suffix.ckeepP0 : Conv.keptPresentB PRE_first_tail_x6_r0_suffix.s2 PRE_first_tail_x6_r0_suffix.s4 PRE_first_tail_x6_r0_suffix.cl0 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.csupp0 : Conv.suppListB PRE_first_tail_x6_r0_suffix.s4 8226 PRE_first_tail_x6_r0_suffix.cl0 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.cbound0 : Conv.boundListB PRE_first_tail_x6_r0_suffix.s4 PRE_first_tail_x6_r0_suffix.cl0 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.cnodesK0 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.nodes (PRE_first_tail_x6_r0_suffix.cln0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.cobjsK0 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.objs (PRE_first_tail_x6_r0_suffix.clo0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.citemsK0 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.items (PRE_first_tail_x6_r0_suffix.cli0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.csst0 : Conv.sstListB 8226 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx PRE_first_tail_x6_r0_suffix.cln0 PRE_first_tail_x6_r0_suffix.clo0 PRE_first_tail_x6_r0_suffix.cli0 = true

end Host.Load.Run.Tpl
end

section -- SiteCl0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_suffix.ckA0 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.arrs (PRE_first_tail_x6_r0_suffix.clo0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.cbd0 : (PRE_first_tail_x6_r0_suffix.clo0 ++ PRE_first_tail_x6_r0_suffix.cln0 ++ PRE_first_tail_x6_r0_suffix.cli0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.cle0 : Conv.Cnt.leB (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.cck0 : Conv.ncleanListB (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx PRE_first_tail_x6_r0_suffix.clo0 PRE_first_tail_x6_r0_suffix.cln0 PRE_first_tail_x6_r0_suffix.cli0 = true
theorem PRE_first_tail_x6_r0_suffix.cncl0 (h : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx) : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_suffix.cle0 PRE_first_tail_x6_r0_suffix.ckA0 PRE_first_tail_x6_r0_suffix.cobjsK0 PRE_first_tail_x6_r0_suffix.cnodesK0 PRE_first_tail_x6_r0_suffix.citemsK0 PRE_first_tail_x6_r0_suffix.cbd0 PRE_first_tail_x6_r0_suffix.cck0

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
def PRE_first_tail_x6_r0_suffix.Pc0 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_suffix.P0 : LoadP := PRE_first_tail_x6_r0_suffix.Pc0.raise 19057
kernel_rfl PRE_first_tail_x6_r0_suffix.craise0 : Nat.ble PRE_first_tail_x6_r0_suffix.Pc0.N0 19057 = true
theorem PRE_first_tail_x6_r0_suffix.raised0 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_suffix.Pc0 PRE_first_tail_x6_r0_suffix.P0 :=
  .inr ⟨19057, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_suffix.craise0, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_suffix.cx0_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_suffix.cx1_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s3.ffi)
def PRE_first_tail_x6_r0_suffix.khinv0 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_suffix.kninv0 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_suffix.cwS0 : List Nat := [21966]
def PRE_first_tail_x6_r0_suffix.cnS0 : List Nat := List.range' 19057 0
def PRE_first_tail_x6_r0_suffix.ciS0 : List Nat := [] ++ List.range' 19057 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_suffix.cnh00 : PRE_first_tail_x6_r0_suffix.kd0.nh0 = PRE_first_tail_x6_r0_suffix.cx0_0.mlx.next
kernel_rfl PRE_first_tail_x6_r0_suffix.cnh10 : PRE_first_tail_x6_r0_suffix.kd0.nh1 = PRE_first_tail_x6_r0_suffix.cx1_0.mlx.next
kernel_rfl PRE_first_tail_x6_r0_suffix.cnn00 : PRE_first_tail_x6_r0_suffix.kd0.nn0 = PRE_first_tail_x6_r0_suffix.cx0_0.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_suffix.cnn10 : PRE_first_tail_x6_r0_suffix.kd0.nn1 = PRE_first_tail_x6_r0_suffix.cx1_0.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_suffix.cplo0 : (Nat.blt 0 PRE_first_tail_x6_r0_suffix.P0.lo && Nat.ble PRE_first_tail_x6_r0_suffix.P0.lo PRE_first_tail_x6_r0_suffix.cx0_0.mlx.next && Nat.ble PRE_first_tail_x6_r0_suffix.P0.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_suffix.P0.E) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.ccnt0 : (Nat.ble PRE_first_tail_x6_r0_suffix.cx0_0.mlx.next PRE_first_tail_x6_r0_suffix.cx1_0.mlx.next && Nat.ble PRE_first_tail_x6_r0_suffix.cx0_0.mlx.nnext PRE_first_tail_x6_r0_suffix.cx1_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.cnband0 : (Nat.blt 0 PRE_first_tail_x6_r0_suffix.P0.NL && Nat.ble PRE_first_tail_x6_r0_suffix.P0.NL PRE_first_tail_x6_r0_suffix.P0.N0 && Nat.ble PRE_first_tail_x6_r0_suffix.P0.N0 PRE_first_tail_x6_r0_suffix.cx0_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.chbelow0 : PRE_first_tail_x6_r0_suffix.kd0.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_suffix.chren0 : checkRenG PRE_first_tail_x6_r0_suffix.kd0.hnd PRE_first_tail_x6_r0_suffix.khinv0 (phB PRE_first_tail_x6_r0_suffix.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.cband0 : PRE_first_tail_x6_r0_suffix.kd0.checkBand PRE_first_tail_x6_r0_suffix.P0.lo = true
kernel_rfl PRE_first_tail_x6_r0_suffix.cnh1pos0 : Nat.blt 0 PRE_first_tail_x6_r0_suffix.kd0.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.cnren0 : checkRenG PRE_first_tail_x6_r0_suffix.kd0.node PRE_first_tail_x6_r0_suffix.kninv0 (pnB PRE_first_tail_x6_r0_suffix.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.cnlow0 : (PTrie.keysA PRE_first_tail_x6_r0_suffix.kd0.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_suffix.P0.NL j && Nat.blt (PRE_first_tail_x6_r0_suffix.kd0.nodeF j) PRE_first_tail_x6_r0_suffix.cx1_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.cabs0a0 : PRE_first_tail_x6_r0_suffix.cx0_0.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_suffix.cabs0b0 : PRE_first_tail_x6_r0_suffix.cx0_0.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_suffix.ctok10 : PRE_first_tail_x6_r0_suffix.cx1_0.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_suffix.cpend0 : PRE_first_tail_x6_r0_suffix.cx1_0.mlx.pending = PRE_first_tail_x6_r0_suffix.cx0_0.mlx.pending.map PRE_first_tail_x6_r0_suffix.kappa0.pend
kernel_rfl PRE_first_tail_x6_r0_suffix.cerrh0 : PRE_first_tail_x6_r0_suffix.cx1_0.mlx.errh = PRE_first_tail_x6_r0_suffix.cx0_0.mlx.errh.map PRE_first_tail_x6_r0_suffix.kappa0.arg
kernel_rfl PRE_first_tail_x6_r0_suffix.cfiles0 : PRE_first_tail_x6_r0_suffix.cx1_0.mlx.files = PRE_first_tail_x6_r0_suffix.cx0_0.mlx.files
kernel_rfl PRE_first_tail_x6_r0_suffix.carch0 : PRE_first_tail_x6_r0_suffix.cx1_0.mlx.arch = PRE_first_tail_x6_r0_suffix.cx0_0.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_suffix.csizes0 : PRE_first_tail_x6_r0_suffix.cx1_0.mlx.deviceSizes = PRE_first_tail_x6_r0_suffix.cx0_0.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_suffix.cwired0 : PRE_first_tail_x6_r0_suffix.cx1_0.mlx.wired = PRE_first_tail_x6_r0_suffix.cx0_0.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_suffix.chost0 : PRE_first_tail_x6_r0_suffix.cx1_0.host = PRE_first_tail_x6_r0_suffix.cx0_0.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_suffix.kd0`'s
kernel_rfl PRE_first_tail_x6_r0_suffix.ckn00 : PRE_first_tail_x6_r0_suffix.kd0.n0 = 2825030
kernel_rfl PRE_first_tail_x6_r0_suffix.ckn10 : PRE_first_tail_x6_r0_suffix.kd0.n1 = 2828013
kernel_rfl PRE_first_tail_x6_r0_suffix.ckheap0 : (PTrie.keysA PRE_first_tail_x6_r0_suffix.kd0.heap).all (fun x => Nat.ble 2825030 x) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.ckpl0 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_suffix.kd0.heap.get (2825030 + j) = nth? PRE_first_tail_x6_r0_suffix.pl0 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_suffix.fja0 : Nat.ble 2825030 2825030 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fn0 : Nat.ble 8226 8226 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fjaD0 : Nat.ble 2825030 PRE_first_tail_x6_r0_suffix.kd0.n0 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fxn0 : Nat.ble 21966 PRE_first_tail_x6_r0_suffix.kd0.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fnn0 : Nat.ble 19057 PRE_first_tail_x6_r0_suffix.kd0.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fxb0 : Nat.ble 21966 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fheap0 : (PTrie.keysA PRE_first_tail_x6_r0_suffix.kd0.heap).all (Nat.ble (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fhnd0 : (PTrie.keysA PRE_first_tail_x6_r0_suffix.kd0.hnd).all (Nat.ble (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fnode0 : (PTrie.keysA PRE_first_tail_x6_r0_suffix.kd0.node).all (Nat.ble (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_suffix.cfix0 : Conv.FixOld (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) PRE_first_tail_x6_r0_suffix.kappa0 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_suffix.fja0) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_suffix.fn0) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_suffix.fjaD0) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_suffix.fxn0) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_suffix.fnn0) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_suffix.fxb0) PRE_first_tail_x6_r0_suffix.fheap0 PRE_first_tail_x6_r0_suffix.fhnd0 PRE_first_tail_x6_r0_suffix.fnode0
kernel_rfl PRE_first_tail_x6_r0_suffix.fcxn0 : (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_suffix.fcnn0 : (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_suffix.fle00 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.next PRE_first_tail_x6_r0_suffix.cx0_0.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.nnext PRE_first_tail_x6_r0_suffix.cx0_0.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fnk0 : (PTrie.keysA PRE_first_tail_x6_r0_suffix.kd0.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_suffix.f1A0 : PRE_first_tail_x6_r0_suffix.cx1_0.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.arrs (PRE_first_tail_x6_r0_suffix.cwS0.filterMap fun i => (PRE_first_tail_x6_r0_suffix.cx1_0.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.f1O0 : PRE_first_tail_x6_r0_suffix.cx1_0.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.objs (PRE_first_tail_x6_r0_suffix.cwS0.filterMap fun i => (PRE_first_tail_x6_r0_suffix.cx1_0.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.f1N0 : PRE_first_tail_x6_r0_suffix.cx1_0.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.nodes (PRE_first_tail_x6_r0_suffix.cnS0.filterMap fun i => (PRE_first_tail_x6_r0_suffix.cx1_0.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.f1I0 : PRE_first_tail_x6_r0_suffix.cx1_0.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.items (PRE_first_tail_x6_r0_suffix.ciS0.filterMap fun i => (PRE_first_tail_x6_r0_suffix.cx1_0.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.fbd0 : (PRE_first_tail_x6_r0_suffix.clo0 ++ PRE_first_tail_x6_r0_suffix.cln0 ++ PRE_first_tail_x6_r0_suffix.cli0 ++ PRE_first_tail_x6_r0_suffix.cwS0 ++ PRE_first_tail_x6_r0_suffix.cnS0 ++ PRE_first_tail_x6_r0_suffix.ciS0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fincW0 : PRE_first_tail_x6_r0_suffix.cwS0.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.next || PRE_first_tail_x6_r0_suffix.clo0.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fincI0 : PRE_first_tail_x6_r0_suffix.ciS0.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.nnext || PRE_first_tail_x6_r0_suffix.cli0.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fincN0 : PRE_first_tail_x6_r0_suffix.cnS0.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.flnF0 : PRE_first_tail_x6_r0_suffix.cln0.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_suffix.fh0 : PRE_first_tail_x6_r0_suffix.clo0.all (handleOK PRE_first_tail_x6_r0_suffix.kappa0 PRE_first_tail_x6_r0_suffix.P0.lo PRE_first_tail_x6_r0_suffix.cx0_0.mlx PRE_first_tail_x6_r0_suffix.cx1_0.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fo0 : PRE_first_tail_x6_r0_suffix.clo0.map (fun h => PRE_first_tail_x6_r0_suffix.cx1_0.mlx.objs.get (PRE_first_tail_x6_r0_suffix.kappa0.handle h)) = PRE_first_tail_x6_r0_suffix.clo0.map (fun h => (PRE_first_tail_x6_r0_suffix.cx0_0.mlx.objs.get h).map PRE_first_tail_x6_r0_suffix.kappa0.nobj)
kernel_rfl PRE_first_tail_x6_r0_suffix.fok0 : PRE_first_tail_x6_r0_suffix.clo0.all (objOK PRE_first_tail_x6_r0_suffix.kappa0 PRE_first_tail_x6_r0_suffix.P0.NL PRE_first_tail_x6_r0_suffix.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fnd0 : PRE_first_tail_x6_r0_suffix.cln0.all (nodeOKF PRE_first_tail_x6_r0_suffix.kappa0 PRE_first_tail_x6_r0_suffix.P0 PRE_first_tail_x6_r0_suffix.cx0_0.mlx PRE_first_tail_x6_r0_suffix.cx1_0.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fp0 : ((PRE_first_tail_x6_r0_suffix.cln0.filter (fullB PRE_first_tail_x6_r0_suffix.P0))).map (fun i => (PRE_first_tail_x6_r0_suffix.cx1_0.mlx.nodes.get (PRE_first_tail_x6_r0_suffix.kappa0.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_suffix.cln0.filter (fullB PRE_first_tail_x6_r0_suffix.P0))).map (fun i => (PRE_first_tail_x6_r0_suffix.cx0_0.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_suffix.kappa0.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_suffix.fnordI0 : incrB PRE_first_tail_x6_r0_suffix.kd0.nodeF (List.range' 19057 0) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fnordK0 : (PTrie.keysA PRE_first_tail_x6_r0_suffix.kd0.node).all (fun k => Nat.ble 19057 k && Nat.blt k 19057) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fnordL0 : (PRE_first_tail_x6_r0_suffix.cln0.filter (Nat.ble PRE_first_tail_x6_r0_suffix.P0.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_suffix.kd0.nodeF i) && (Nat.blt i 19057 || Nat.ble PRE_first_tail_x6_r0_suffix.kd0.nn0 i)) = true
theorem PRE_first_tail_x6_r0_suffix.fnord0 : (PRE_first_tail_x6_r0_suffix.cln0.filter (Nat.ble PRE_first_tail_x6_r0_suffix.P0.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_suffix.kd0.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_suffix.kd0.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_suffix.kd0.nodeF j) (PRE_first_tail_x6_r0_suffix.kd0.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_suffix.cnlow0 PRE_first_tail_x6_r0_suffix.cnn10 PRE_first_tail_x6_r0_suffix.fnordI0 PRE_first_tail_x6_r0_suffix.fnordK0 PRE_first_tail_x6_r0_suffix.fnordL0
kernel_rfl PRE_first_tail_x6_r0_suffix.fi0 : PRE_first_tail_x6_r0_suffix.cli0.all (pnB PRE_first_tail_x6_r0_suffix.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fii0 : PRE_first_tail_x6_r0_suffix.cli0.all (fun k => decide (PRE_first_tail_x6_r0_suffix.cx1_0.mlx.items.get (PRE_first_tail_x6_r0_suffix.kappa0.node k) = (PRE_first_tail_x6_r0_suffix.cx0_0.mlx.items.get k).map PRE_first_tail_x6_r0_suffix.kappa0.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_suffix.cfoot0 (clean : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_suffix.P0.NL) (cl : SSt (· < 8226) PRE_first_tail_x6_r0_suffix.cx0_0.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_suffix.P0 8226 PRE_first_tail_x6_r0_suffix.kappa0 PRE_first_tail_x6_r0_suffix.kd0 PRE_first_tail_x6_r0_suffix.khinv0 PRE_first_tail_x6_r0_suffix.kninv0 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx PRE_first_tail_x6_r0_suffix.cx0_0.mlx PRE_first_tail_x6_r0_suffix.cx1_0.mlx (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) PRE_first_tail_x6_r0_suffix.clo0 PRE_first_tail_x6_r0_suffix.cln0 PRE_first_tail_x6_r0_suffix.cli0 PRE_first_tail_x6_r0_suffix.cwS0 PRE_first_tail_x6_r0_suffix.cnS0 PRE_first_tail_x6_r0_suffix.ciS0 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_suffix.cnh00, PRE_first_tail_x6_r0_suffix.cnh10, PRE_first_tail_x6_r0_suffix.cnn00, PRE_first_tail_x6_r0_suffix.cnn10, PRE_first_tail_x6_r0_suffix.cplo0, PRE_first_tail_x6_r0_suffix.ccnt0, PRE_first_tail_x6_r0_suffix.cnband0, PRE_first_tail_x6_r0_suffix.chbelow0, PRE_first_tail_x6_r0_suffix.chren0, PRE_first_tail_x6_r0_suffix.cband0, PRE_first_tail_x6_r0_suffix.cnh1pos0, PRE_first_tail_x6_r0_suffix.cnren0, PRE_first_tail_x6_r0_suffix.cnlow0, PRE_first_tail_x6_r0_suffix.cabs0a0, PRE_first_tail_x6_r0_suffix.cabs0b0, PRE_first_tail_x6_r0_suffix.ctok10, PRE_first_tail_x6_r0_suffix.cpend0, PRE_first_tail_x6_r0_suffix.cerrh0, PRE_first_tail_x6_r0_suffix.cfiles0, PRE_first_tail_x6_r0_suffix.carch0, PRE_first_tail_x6_r0_suffix.csizes0, PRE_first_tail_x6_r0_suffix.cwired0, PRE_first_tail_x6_r0_suffix.cfix0, clean, PRE_first_tail_x6_r0_suffix.fcxn0, PRE_first_tail_x6_r0_suffix.fcnn0, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_suffix.fle00, PRE_first_tail_x6_r0_suffix.fnk0, PRE_first_tail_x6_r0_suffix.ckA0, PRE_first_tail_x6_r0_suffix.cobjsK0, PRE_first_tail_x6_r0_suffix.cnodesK0, PRE_first_tail_x6_r0_suffix.citemsK0, PRE_first_tail_x6_r0_suffix.f1A0, PRE_first_tail_x6_r0_suffix.f1O0, PRE_first_tail_x6_r0_suffix.f1N0, PRE_first_tail_x6_r0_suffix.f1I0, PRE_first_tail_x6_r0_suffix.fbd0, PRE_first_tail_x6_r0_suffix.fincW0, PRE_first_tail_x6_r0_suffix.fincI0, PRE_first_tail_x6_r0_suffix.fincN0, PRE_first_tail_x6_r0_suffix.flnF0, PRE_first_tail_x6_r0_suffix.fh0, PRE_first_tail_x6_r0_suffix.fo0, PRE_first_tail_x6_r0_suffix.fok0, PRE_first_tail_x6_r0_suffix.fnd0, PRE_first_tail_x6_r0_suffix.fp0, PRE_first_tail_x6_r0_suffix.fnord0, PRE_first_tail_x6_r0_suffix.fi0, PRE_first_tail_x6_r0_suffix.fii0⟩
theorem PRE_first_tail_x6_r0_suffix.cnshift0 (clean : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_suffix.P0.NL) (cl : SSt (· < 8226) PRE_first_tail_x6_r0_suffix.cx0_0.mlx) : NShift PRE_first_tail_x6_r0_suffix.P0 8226 PRE_first_tail_x6_r0_suffix.kappa0 PRE_first_tail_x6_r0_suffix.cx0_0 PRE_first_tail_x6_r0_suffix.cx1_0 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_suffix.cfoot0 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_suffix.chost0 (compact_a_eq PRE_first_tail_x6_r0_suffix.ckn00 PRE_first_tail_x6_r0_suffix.ckn10 PRE_first_tail_x6_r0_suffix.ckheap0 PRE_first_tail_x6_r0_suffix.ckpl0)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_suffix.fxC_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_suffix.s2.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_suffix.krC_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_suffix.s2.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_suffix.ofxC_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_suffix.s2.ffi) = some PRE_first_tail_x6_r0_suffix.fxC_0
kernel_rfl PRE_first_tail_x6_r0_suffix.okrC_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_suffix.s2.ffi) = some PRE_first_tail_x6_r0_suffix.krC_0
noncomputable def PRE_first_tail_x6_r0_suffix.fx0_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_suffix.s4.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_suffix.kr0_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_suffix.s4.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_suffix.ofx0_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_suffix.s4.ffi) = some PRE_first_tail_x6_r0_suffix.fx0_0
kernel_rfl PRE_first_tail_x6_r0_suffix.okr0_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_suffix.s4.ffi) = some PRE_first_tail_x6_r0_suffix.kr0_0
noncomputable def PRE_first_tail_x6_r0_suffix.fx1_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_suffix.s3.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_suffix.kr1_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_suffix.s3.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_suffix.ofx1_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_suffix.s3.ffi) = some PRE_first_tail_x6_r0_suffix.fx1_0
kernel_rfl PRE_first_tail_x6_r0_suffix.okr1_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_suffix.s3.ffi) = some PRE_first_tail_x6_r0_suffix.kr1_0
kernel_rfl PRE_first_tail_x6_r0_suffix.ff00 : PRE_first_tail_x6_r0_suffix.fx0_0 = Stage.setAll PRE_first_tail_x6_r0_suffix.fxC_0 (PRE_first_tail_x6_r0_suffix.clo0.filterMap fun i => (PRE_first_tail_x6_r0_suffix.fx0_0.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.ff10 : PRE_first_tail_x6_r0_suffix.fx1_0 = Stage.setAll PRE_first_tail_x6_r0_suffix.fxC_0 (PRE_first_tail_x6_r0_suffix.cwS0.filterMap fun i => (PRE_first_tail_x6_r0_suffix.fx1_0.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.ffck0 : freedLB PRE_first_tail_x6_r0_suffix.kappa0 PRE_first_tail_x6_r0_suffix.cx0_0.mlx PRE_first_tail_x6_r0_suffix.fx0_0 PRE_first_tail_x6_r0_suffix.fx1_0 PRE_first_tail_x6_r0_suffix.clo0 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fkf00 : PRE_first_tail_x6_r0_suffix.kr0_0.flags = Stage.setAll PRE_first_tail_x6_r0_suffix.krC_0.flags (PRE_first_tail_x6_r0_suffix.clo0.filterMap fun i => (PRE_first_tail_x6_r0_suffix.kr0_0.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.fkt00 : PRE_first_tail_x6_r0_suffix.kr0_0.targs = Stage.setAll PRE_first_tail_x6_r0_suffix.krC_0.targs (PRE_first_tail_x6_r0_suffix.clo0.filterMap fun i => (PRE_first_tail_x6_r0_suffix.kr0_0.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.fkf10 : PRE_first_tail_x6_r0_suffix.kr1_0.flags = Stage.setAll PRE_first_tail_x6_r0_suffix.krC_0.flags (PRE_first_tail_x6_r0_suffix.cwS0.filterMap fun i => (PRE_first_tail_x6_r0_suffix.kr1_0.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.fkt10 : PRE_first_tail_x6_r0_suffix.kr1_0.targs = Stage.setAll PRE_first_tail_x6_r0_suffix.krC_0.targs (PRE_first_tail_x6_r0_suffix.cwS0.filterMap fun i => (PRE_first_tail_x6_r0_suffix.kr1_0.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.fkck0 : krecLB PRE_first_tail_x6_r0_suffix.kappa0 8226 PRE_first_tail_x6_r0_suffix.cx0_0.mlx PRE_first_tail_x6_r0_suffix.kr0_0 PRE_first_tail_x6_r0_suffix.kr1_0 PRE_first_tail_x6_r0_suffix.clo0 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.fkn0 : Nat.ble 8226 8226 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_suffix.cbridge0 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_suffix.s3.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_suffix.s4.ffi
kernel_rfl PRE_first_tail_x6_r0_suffix.cpendR0 : pendRegB PRE_first_tail_x6_r0_suffix.kappa0 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_suffix.cpendLe0 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s4.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s3.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_suffix.cshift0 (clean : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_suffix.P0.NL) (cl : SSt (· < 8226) PRE_first_tail_x6_r0_suffix.cx0_0.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_suffix.fxC_0.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_suffix.krC_0.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_suffix.krC_0.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s2.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_suffix.krC_0.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_suffix.P0 8226 PRE_first_tail_x6_r0_suffix.kappa0 PRE_first_tail_x6_r0_suffix.s4.ffi PRE_first_tail_x6_r0_suffix.s3.ffi :=
  ⟨PRE_first_tail_x6_r0_suffix.cnshift0 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_suffix.cqueue0, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_suffix.ctokSupp0 t ht),
    PRE_first_tail_x6_r0_suffix.cbridge0,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_suffix.s4.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_suffix.s3.ffi) (PRE_first_tail_x6_r0_suffix.cfoot0 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_suffix.ofx0_0 PRE_first_tail_x6_r0_suffix.ofx1_0 hobjC PRE_first_tail_x6_r0_suffix.ff00 PRE_first_tail_x6_r0_suffix.ff10 PRE_first_tail_x6_r0_suffix.ffck0,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_suffix.s4.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_suffix.s3.ffi) (PRE_first_tail_x6_r0_suffix.cfoot0 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_suffix.okr0_0 PRE_first_tail_x6_r0_suffix.okr1_0 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_suffix.fkn0) hfC htC hclC
      PRE_first_tail_x6_r0_suffix.fkf00 PRE_first_tail_x6_r0_suffix.fkt00 PRE_first_tail_x6_r0_suffix.fkf10 PRE_first_tail_x6_r0_suffix.fkt10 PRE_first_tail_x6_r0_suffix.fkck0,
    pendReg_of rfl PRE_first_tail_x6_r0_suffix.cnh00 PRE_first_tail_x6_r0_suffix.cnh10 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_suffix.cpendLe0) PRE_first_tail_x6_r0_suffix.cpendR0⟩

end Host.Load.Run.Tpl
end

section -- st0/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_suffix.st0 0
host_stream_state PRE_first_tail_x6_r0_suffix.st0 1
host_stream_state PRE_first_tail_x6_r0_suffix.st0 2
host_stream_state PRE_first_tail_x6_r0_suffix.st0 3
host_stream_state PRE_first_tail_x6_r0_suffix.st0 4
host_stream_state PRE_first_tail_x6_r0_suffix.st0 5
end Host.Load.Run.Tpl
end

section -- Site0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `PRE_first_tail_x6_r0_suffix`: `eval__g3d_first__g4_pf_first` (`evalCacheState`), the call state `PRE_first_tail_x6_r0_suffix.s2`, the merged state `PRE_first_tail_x6_r0_suffix.s3`,
the site template `PRE_first_tail_x6_r0_suffix.st0` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_suffix.s4`: the merge.
The footprint's facts are in `SiteF0`, the compaction's in `SiteC0`, `SiteK0`, `SiteNa0`, `SiteNb0`. -/

kernel_rfl PRE_first_tail_x6_r0_suffix.iso0 : PRE_first_tail_x6_r0_suffix.st0.s0 = { PRE_first_tail_x6_r0_suffix.s2 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_suffix.rs0 : List Frame := PRE_first_tail_x6_r0_suffix.s2.stack
kernel_rfl PRE_first_tail_x6_r0_suffix.n0_0 : PRE_first_tail_x6_r0_suffix.S2.tab.length = 8226
kernel_rfl PRE_first_tail_x6_r0_suffix.tab0_0 : PRE_first_tail_x6_r0_suffix.st0.S0.tab = PRE_first_tail_x6_r0_suffix.S2.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_suffix.ws0 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_suffix.fresh0 : (PRE_first_tail_x6_r0_suffix.S2.tab.all fun e => PRE_first_tail_x6_r0_suffix.ws0.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_suffix.S2.oracle.all fun q => PRE_first_tail_x6_r0_suffix.ws0.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.mergeTab0 : PRE_first_tail_x6_r0_suffix.S3.tab = PRE_first_tail_x6_r0_suffix.S2.tab ++ Conv.resTab PRE_first_tail_x6_r0_suffix.ws0
kernel_rfl PRE_first_tail_x6_r0_suffix.mergeLen0 : PRE_first_tail_x6_r0_suffix.st0.S5.tab.length - PRE_first_tail_x6_r0_suffix.st0.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_suffix.merged0`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_suffix.mheap0 : PRE_first_tail_x6_r0_suffix.s3.heap = PRE_first_tail_x6_r0_suffix.st0.s5.heap
kernel_rfl PRE_first_tail_x6_r0_suffix.mnext0 : PRE_first_tail_x6_r0_suffix.s3.next = PRE_first_tail_x6_r0_suffix.st0.s5.next
kernel_rfl PRE_first_tail_x6_r0_suffix.mctl0 : PRE_first_tail_x6_r0_suffix.s3.ctl = PRE_first_tail_x6_r0_suffix.st0.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_suffix.mstack0 : PRE_first_tail_x6_r0_suffix.s3.stack = PRE_first_tail_x6_r0_suffix.st0.s5.stack ++ PRE_first_tail_x6_r0_suffix.s2.stack
kernel_rfl PRE_first_tail_x6_r0_suffix.mjobs0 : PRE_first_tail_x6_r0_suffix.s3.jobs = PRE_first_tail_x6_r0_suffix.st0.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_suffix.mffi0 : PRE_first_tail_x6_r0_suffix.s3.ffi = PRE_first_tail_x6_r0_suffix.st0.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_suffix.mtrace0 : PRE_first_tail_x6_r0_suffix.s3.trace = PRE_first_tail_x6_r0_suffix.st0.s5.trace
kernel_rfl PRE_first_tail_x6_r0_suffix.mstores0 : PRE_first_tail_x6_r0_suffix.s3.stores = PRE_first_tail_x6_r0_suffix.st0.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 0 of chain `PRE_first_tail_x6_r0_suffix`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_suffix.cderived0 : PRE_first_tail_x6_r0_suffix.nr0.map (fun r => nth? PRE_first_tail_x6_r0_suffix.st0.S5.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_suffix.cnrLo0 : PRE_first_tail_x6_r0_suffix.nr0.all (Nat.ble 8226) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.cwsDisj0 : PRE_first_tail_x6_r0_suffix.cws0.all (fun c => !PRE_first_tail_x6_r0_suffix.ws0.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_suffix.cthetaZ0 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_suffix.cws0 PRE_first_tail_x6_r0_suffix.crs0 PRE_first_tail_x6_r0_suffix.ws0

end Host.Load.Run.Tpl
end

section -- st0/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_suffix.st0`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_suffix.st0.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_suffix.st0.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_suffix.st0.s5.heap PRE_first_tail_x6_r0_suffix.st0.wrR ++ freshOf PRE_first_tail_x6_r0_suffix.st0.s5.heap PRE_first_tail_x6_r0_suffix.st0.s0.next PRE_first_tail_x6_r0_suffix.st0.s5.next
noncomputable def PRE_first_tail_x6_r0_suffix.st0.wr : List Nat := PRE_first_tail_x6_r0_suffix.st0.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_suffix.st0.heapFoot : PRE_first_tail_x6_r0_suffix.st0.s5.heap = setAll PRE_first_tail_x6_r0_suffix.st0.s0.heap PRE_first_tail_x6_r0_suffix.st0.wrE
kernel_rfl PRE_first_tail_x6_r0_suffix.st0.grows_check : Nat.ble PRE_first_tail_x6_r0_suffix.st0.s0.next PRE_first_tail_x6_r0_suffix.st0.s5.next = true
theorem PRE_first_tail_x6_r0_suffix.st0.grows : PRE_first_tail_x6_r0_suffix.st0.s0.next ≤ PRE_first_tail_x6_r0_suffix.st0.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_suffix.st0.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_suffix.st0.wh : List Nat := [21966]
def PRE_first_tail_x6_r0_suffix.st0.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_suffix.st0.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_suffix.st0.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.st0.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_suffix.st0.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_suffix.st0.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_suffix.st0.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_suffix.st0.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_suffix.st0.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.st0.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `PRE_first_tail_x6_r0_suffix`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_suffix.wrNodupB0 : nodupT PRE_first_tail_x6_r0_suffix.st0.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_suffix.wrNodup0 : PRE_first_tail_x6_r0_suffix.st0.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_suffix.wrNodupB0).2
kernel_rfl PRE_first_tail_x6_r0_suffix.wrBoundB0 : PRE_first_tail_x6_r0_suffix.st0.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_suffix.wrBound0 : ∀ b ∈ PRE_first_tail_x6_r0_suffix.st0.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_suffix.wrBoundB0 b hb)
noncomputable def PRE_first_tail_x6_r0_suffix.trFr0 := PRE_first_tail_x6_r0_suffix.st0.s5.trace.take 3
kernel_rfl PRE_first_tail_x6_r0_suffix.traceEq0 : PRE_first_tail_x6_r0_suffix.st0.s5.trace = PRE_first_tail_x6_r0_suffix.trFr0 ++ PRE_first_tail_x6_r0_suffix.st0.s0.trace
theorem PRE_first_tail_x6_r0_suffix.trace0 : ∃ fr, PRE_first_tail_x6_r0_suffix.st0.s5.trace = fr ++ PRE_first_tail_x6_r0_suffix.st0.s0.trace := ⟨_, PRE_first_tail_x6_r0_suffix.traceEq0⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_suffix.wide0 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_suffix.wfixB0 : (PRE_first_tail_x6_r0_suffix.wide0.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_suffix.st0.s0) p.2) = true
theorem PRE_first_tail_x6_r0_suffix.wfix0 : ∀ p ∈ PRE_first_tail_x6_r0_suffix.wide0, WFix Map.id (Present PRE_first_tail_x6_r0_suffix.st0.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_suffix.wfixB0 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 0 of chain `PRE_first_tail_x6_r0_suffix`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_suffix.s3`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_suffix.srvO0 : PRE_first_tail_x6_r0_suffix.st0.S0.oracle = PRE_first_tail_x6_r0_suffix.st0.O
kernel_rfl PRE_first_tail_x6_r0_suffix.wr0B0 : PRE_first_tail_x6_r0_suffix.st0.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_suffix.st0.s0.next || (PRE_first_tail_x6_r0_suffix.st0.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_suffix.stFoot0 : Conv.StageFoot PRE_first_tail_x6_r0_suffix.st0.wr PRE_first_tail_x6_r0_suffix.st0.s0 PRE_first_tail_x6_r0_suffix.st0.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_suffix.st0.heapFoot PRE_first_tail_x6_r0_suffix.wrNodup0 PRE_first_tail_x6_r0_suffix.wrBound0 PRE_first_tail_x6_r0_suffix.wr0B0 PRE_first_tail_x6_r0_suffix.st0.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_suffix.merged0 {FR : Map → Nat → PRE_first_tail_x6_r0_suffix.st0.F.S → PRE_first_tail_x6_r0_suffix.st0.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_suffix.st0.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_suffix.st0.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_suffix.rs0 PRE_first_tail_x6_r0_suffix.st0.wr PRE_first_tail_x6_r0_suffix.s2 PRE_first_tail_x6_r0_suffix.st0.s5 PRE_first_tail_x6_r0_suffix.st0.s0
      PRE_first_tail_x6_r0_suffix.st0.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_suffix.st0.F FR W stk M ν K PRE_first_tail_x6_r0_suffix.s3 S t C :=
  merged_relB PRE_first_tail_x6_r0_suffix.iso0 PRE_first_tail_x6_r0_suffix.stFoot0 PRE_first_tail_x6_r0_suffix.wrNodup0 PRE_first_tail_x6_r0_suffix.wrBound0 PRE_first_tail_x6_r0_suffix.trace0 PRE_first_tail_x6_r0_suffix.mheap0
    PRE_first_tail_x6_r0_suffix.mnext0 PRE_first_tail_x6_r0_suffix.mctl0 PRE_first_tail_x6_r0_suffix.mstack0 PRE_first_tail_x6_r0_suffix.mjobs0 PRE_first_tail_x6_r0_suffix.mffi0 PRE_first_tail_x6_r0_suffix.mtrace0 PRE_first_tail_x6_r0_suffix.mstores0 h

def PRE_first_tail_x6_r0_suffix.arrEl0_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_suffix.arrE0_2665 : arrOf PRE_first_tail_x6_r0_suffix.s3 2665 = arrOf PRE_first_tail_x6_r0_suffix.s0 2665 ++ PRE_first_tail_x6_r0_suffix.arrEl0_2665
kernel_rfl PRE_first_tail_x6_r0_suffix.arrA0_2665 : isArrB PRE_first_tail_x6_r0_suffix.s3 2665 = true
theorem PRE_first_tail_x6_r0_suffix.arr0_2665 : ∃ o, PRE_first_tail_x6_r0_suffix.s3.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_suffix.s0 2665 ++ PRE_first_tail_x6_r0_suffix.arrEl0_2665) :=
  arrExt_of PRE_first_tail_x6_r0_suffix.arrE0_2665 PRE_first_tail_x6_r0_suffix.arrA0_2665
kernel_rfl PRE_first_tail_x6_r0_suffix.arrN0_2665 : numRefsB PRE_first_tail_x6_r0_suffix.S0.tab.length PRE_first_tail_x6_r0_suffix.arrEl0_2665 = true
theorem PRE_first_tail_x6_r0_suffix.arrR0_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_suffix.S0.tab.length PRE_first_tail_x6_r0_suffix.arrEl0_2665 := numRefs_of PRE_first_tail_x6_r0_suffix.arrN0_2665

def PRE_first_tail_x6_r0_suffix.arrEl0_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_suffix.arrE0_2673467 : arrOf PRE_first_tail_x6_r0_suffix.s3 2673467 = arrOf PRE_first_tail_x6_r0_suffix.s0 2673467 ++ PRE_first_tail_x6_r0_suffix.arrEl0_2673467
kernel_rfl PRE_first_tail_x6_r0_suffix.arrA0_2673467 : isArrB PRE_first_tail_x6_r0_suffix.s3 2673467 = true
theorem PRE_first_tail_x6_r0_suffix.arr0_2673467 : ∃ o, PRE_first_tail_x6_r0_suffix.s3.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_suffix.s0 2673467 ++ PRE_first_tail_x6_r0_suffix.arrEl0_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_suffix.arrE0_2673467 PRE_first_tail_x6_r0_suffix.arrA0_2673467
kernel_rfl PRE_first_tail_x6_r0_suffix.arrN0_2673467 : numRefsB PRE_first_tail_x6_r0_suffix.S0.tab.length PRE_first_tail_x6_r0_suffix.arrEl0_2673467 = true
theorem PRE_first_tail_x6_r0_suffix.arrR0_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_suffix.S0.tab.length PRE_first_tail_x6_r0_suffix.arrEl0_2673467 := numRefs_of PRE_first_tail_x6_r0_suffix.arrN0_2673467

kernel_rfl PRE_first_tail_x6_r0_suffix.w4910k0 : isArrB PRE_first_tail_x6_r0_suffix.s3 4910 = false
theorem PRE_first_tail_x6_r0_suffix.keep0 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_suffix.s0 q) PRE_first_tail_x6_r0_suffix.s3 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_suffix.w4910k0 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_suffix.arr0_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_suffix.arrEl0_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 0 of chain `PRE_first_tail_x6_r0_suffix` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_suffix.s2`, the merged
state `PRE_first_tail_x6_r0_suffix.s3`, the canonical state `PRE_first_tail_x6_r0_suffix.s4`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_suffix.zpl0 : PRE_first_tail_x6_r0_suffix.pl0.all (Nat.ble PRE_first_tail_x6_r0_suffix.s2.next) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.zplnd0 : nodupT PRE_first_tail_x6_r0_suffix.pl0 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_suffix.zn10 : Nat.ble PRE_first_tail_x6_r0_suffix.s2.next 2828013 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.zfirst0 : Nat.ble aFirst PRE_first_tail_x6_r0_suffix.s2.next = true
kernel_rfl PRE_first_tail_x6_r0_suffix.zscn0 : PRE_first_tail_x6_r0_suffix.s4.next = PRE_first_tail_x6_r0_suffix.s2.next + PRE_first_tail_x6_r0_suffix.pl0.length
kernel_rfl PRE_first_tail_x6_r0_suffix.zsmn0 : PRE_first_tail_x6_r0_suffix.s3.next = 2828013
kernel_rfl PRE_first_tail_x6_r0_suffix.zgrow0 : Nat.ble PRE_first_tail_x6_r0_suffix.s4.next PRE_first_tail_x6_r0_suffix.s3.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_suffix.zfresh0 : PRE_first_tail_x6_r0_suffix.S2.tab.all (fun e => PRE_first_tail_x6_r0_suffix.cws0.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.zcnd0 : nodupT PRE_first_tail_x6_r0_suffix.cws0 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_suffix.znrHi0 : PRE_first_tail_x6_r0_suffix.nr0.all (fun r => Nat.blt r PRE_first_tail_x6_r0_suffix.S3.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_suffix.zfrlt0 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_suffix.s2.next) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.zg0_2665 : PRE_first_tail_x6_r0_suffix.s4.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_suffix.s4 2665))
kernel_rfl PRE_first_tail_x6_r0_suffix.zk0_2665 : (objOf PRE_first_tail_x6_r0_suffix.s4 2665).kind = .array (arrOf PRE_first_tail_x6_r0_suffix.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_suffix.zm0_2665 : PRE_first_tail_x6_r0_suffix.s3.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_suffix.kappa0.obj (objOf PRE_first_tail_x6_r0_suffix.s4 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_suffix.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_suffix.s3 2665).drop (arrOf PRE_first_tail_x6_r0_suffix.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_suffix.zg0_2673467 : PRE_first_tail_x6_r0_suffix.s4.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_suffix.s4 2673467))
kernel_rfl PRE_first_tail_x6_r0_suffix.zk0_2673467 : (objOf PRE_first_tail_x6_r0_suffix.s4 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_suffix.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_suffix.zm0_2673467 : PRE_first_tail_x6_r0_suffix.s3.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_suffix.kappa0.obj (objOf PRE_first_tail_x6_r0_suffix.s4 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_suffix.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_suffix.s3 2673467).drop (arrOf PRE_first_tail_x6_r0_suffix.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_suffix.zw0_4910 : (PRE_first_tail_x6_r0_suffix.s4.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_suffix.zw0_2673472 : (PRE_first_tail_x6_r0_suffix.s4.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_suffix.zw0_2673473 : (PRE_first_tail_x6_r0_suffix.s4.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_suffix.zclbd0 : PRE_first_tail_x6_r0_suffix.cl0.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_suffix.zwr0 : PRE_first_tail_x6_r0_suffix.st0.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_suffix.s2.next || PRE_first_tail_x6_r0_suffix.cl0.contains b) = true
def PRE_first_tail_x6_r0_suffix.zl0 : List Nat := PRE_first_tail_x6_r0_suffix.cl0.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_suffix.zimgE0 : PRE_first_tail_x6_r0_suffix.zl0.map (fun a => PRE_first_tail_x6_r0_suffix.s3.heap.get (PRE_first_tail_x6_r0_suffix.kappa0.a a)) = PRE_first_tail_x6_r0_suffix.zl0.map (fun a => (PRE_first_tail_x6_r0_suffix.s4.heap.get a).map PRE_first_tail_x6_r0_suffix.kappa0.hobj)
theorem PRE_first_tail_x6_r0_suffix.zimg0 : HeapImg PRE_first_tail_x6_r0_suffix.kappa0 PRE_first_tail_x6_r0_suffix.s4 PRE_first_tail_x6_r0_suffix.s3 PRE_first_tail_x6_r0_suffix.zl0 := PRE_first_tail_x6_r0_suffix.zimgE0
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_suffix.zctl0 : PRE_first_tail_x6_r0_suffix.s3.ctl = PRE_first_tail_x6_r0_suffix.kappa0.ctl PRE_first_tail_x6_r0_suffix.s4.ctl
kernel_rfl PRE_first_tail_x6_r0_suffix.zstack0 : PRE_first_tail_x6_r0_suffix.s3.stack = PRE_first_tail_x6_r0_suffix.s4.stack.map PRE_first_tail_x6_r0_suffix.kappa0.frame
kernel_rfl PRE_first_tail_x6_r0_suffix.zjobs0 : PRE_first_tail_x6_r0_suffix.s3.jobs = PRE_first_tail_x6_r0_suffix.s4.jobs.map PRE_first_tail_x6_r0_suffix.kappa0.job
kernel_rfl PRE_first_tail_x6_r0_suffix.zstores0 : PRE_first_tail_x6_r0_suffix.s3.stores = PRE_first_tail_x6_r0_suffix.kappa0.stores PRE_first_tail_x6_r0_suffix.s4.stores
kernel_rfl PRE_first_tail_x6_r0_suffix.zroots0 : checkRootsSupp PRE_first_tail_x6_r0_suffix.s4 8226 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.znC0 : PRE_first_tail_x6_r0_suffix.S2.tab.length + PRE_first_tail_x6_r0_suffix.cws0.length = 8226
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_suffix.zkap0 : PRE_first_tail_x6_r0_suffix.kappa0 = Conv.Map.compact PRE_first_tail_x6_r0_suffix.s2.next 2828013 PRE_first_tail_x6_r0_suffix.S2.tab.length PRE_first_tail_x6_r0_suffix.pl0 (PRE_first_tail_x6_r0_suffix.nr0.map NumV.ref) PRE_first_tail_x6_r0_suffix.kd0.big
  PRE_first_tail_x6_r0_suffix.kd0.region PRE_first_tail_x6_r0_suffix.kd0.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_suffix.zbin0 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_suffix.s4.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_suffix.zjc0 : Conv.jcleanListB (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) PRE_first_tail_x6_r0_suffix.s4 PRE_first_tail_x6_r0_suffix.cl0 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.zroots20 : noBigRootsP (fun i => !Conv.oldBigB (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_suffix.s4.trace PRE_first_tail_x6_r0_suffix.s4 = true
kernel_rfl PRE_first_tail_x6_r0_suffix.zhm0 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_suffix.s0.ffi).mlx.nnext 19057 = true
theorem PRE_first_tail_x6_r0_suffix.cjcl0 (h : Conv.JClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) PRE_first_tail_x6_r0_suffix.s2) : Conv.JClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) PRE_first_tail_x6_r0_suffix.s4 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_suffix.cle0)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_suffix.cheap0 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_suffix.zclbd0 a ha)) PRE_first_tail_x6_r0_suffix.zjc0

end Host.Load.Run.Tpl
end

section -- st0/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_suffix.st0.bodyLast from PRE_first_tail_x6_r0_suffix.st0.s4 to PRE_first_tail_x6_r0_suffix.st0.s5 :
  interpS (step PRE_first_tail_x6_r0_suffix.st0.F PRE_first_tail_x6_r0_suffix.st0.s4).run PRE_first_tail_x6_r0_suffix.st0.S4 = some (PRE_first_tail_x6_r0_suffix.st0.s5, PRE_first_tail_x6_r0_suffix.st0.S5)
kernel_rfl PRE_first_tail_x6_r0_suffix.st0.bodyHalt : isHalt PRE_first_tail_x6_r0_suffix.st0.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_suffix.st0.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_suffix.st0.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st0/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_suffix.st0.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_suffix.st0.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_suffix.st0.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_suffix.st0.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_suffix.st0.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_suffix.st0.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_suffix.st0.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_suffix.st0.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_suffix.st0.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_suffix.st0.bodyOkL bytes rows PRE_first_tail_x6_r0_suffix.st0.s0 PRE_first_tail_x6_r0_suffix.st0.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_suffix.st0.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_suffix.st0.bodyOkL bytes rows PRE_first_tail_x6_r0_suffix.st0.s4 PRE_first_tail_x6_r0_suffix.st0.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st0/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_suffix.st0.bodyK0F from PRE_first_tail_x6_r0_suffix.st0.s0 to PRE_first_tail_x6_r0_suffix.st0.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_suffix.st0.F (PRE_first_tail_x6_r0_suffix.st0.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 0).getD 0) PRE_first_tail_x6_r0_suffix.st0.s0 PRE_first_tail_x6_r0_suffix.st0.S0) = fun _ _ => some (PRE_first_tail_x6_r0_suffix.st0.s1, PRE_first_tail_x6_r0_suffix.st0.S1)
theorem PRE_first_tail_x6_r0_suffix.st0.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_suffix.st0.F (PRE_first_tail_x6_r0_suffix.st0.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 0).getD 0) PRE_first_tail_x6_r0_suffix.st0.s0 PRE_first_tail_x6_r0_suffix.st0.S0) = fun _ _ => some (PRE_first_tail_x6_r0_suffix.st0.s1, PRE_first_tail_x6_r0_suffix.st0.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_suffix.st0.bodyOkLN_ok PRE_first_tail_x6_r0_suffix.st0.bodyK0F
end Host.Load.Run.Tpl
end

section -- st0/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_suffix.st0.bodyK1F from PRE_first_tail_x6_r0_suffix.st0.s1 to PRE_first_tail_x6_r0_suffix.st0.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_suffix.st0.F (PRE_first_tail_x6_r0_suffix.st0.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 1).getD 0) PRE_first_tail_x6_r0_suffix.st0.s1 PRE_first_tail_x6_r0_suffix.st0.S1) = fun _ _ => some (PRE_first_tail_x6_r0_suffix.st0.s2, PRE_first_tail_x6_r0_suffix.st0.S2)
theorem PRE_first_tail_x6_r0_suffix.st0.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_suffix.st0.F (PRE_first_tail_x6_r0_suffix.st0.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 1).getD 0) PRE_first_tail_x6_r0_suffix.st0.s1 PRE_first_tail_x6_r0_suffix.st0.S1) = fun _ _ => some (PRE_first_tail_x6_r0_suffix.st0.s2, PRE_first_tail_x6_r0_suffix.st0.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_suffix.st0.bodyOkLN_ok PRE_first_tail_x6_r0_suffix.st0.bodyK1F
end Host.Load.Run.Tpl
end

section -- st0/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_suffix.st0.bodyK2F from PRE_first_tail_x6_r0_suffix.st0.s2 to PRE_first_tail_x6_r0_suffix.st0.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_suffix.st0.F (PRE_first_tail_x6_r0_suffix.st0.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 2).getD 0) PRE_first_tail_x6_r0_suffix.st0.s2 PRE_first_tail_x6_r0_suffix.st0.S2) = fun _ _ => some (PRE_first_tail_x6_r0_suffix.st0.s3, PRE_first_tail_x6_r0_suffix.st0.S3)
theorem PRE_first_tail_x6_r0_suffix.st0.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_suffix.st0.F (PRE_first_tail_x6_r0_suffix.st0.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 2).getD 0) PRE_first_tail_x6_r0_suffix.st0.s2 PRE_first_tail_x6_r0_suffix.st0.S2) = fun _ _ => some (PRE_first_tail_x6_r0_suffix.st0.s3, PRE_first_tail_x6_r0_suffix.st0.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_suffix.st0.bodyOkLN_ok PRE_first_tail_x6_r0_suffix.st0.bodyK2F
end Host.Load.Run.Tpl
end

section -- st0/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_suffix.st0.bodyK3F from PRE_first_tail_x6_r0_suffix.st0.s3 to PRE_first_tail_x6_r0_suffix.st0.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_suffix.st0.F (PRE_first_tail_x6_r0_suffix.st0.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 3).getD 0) PRE_first_tail_x6_r0_suffix.st0.s3 PRE_first_tail_x6_r0_suffix.st0.S3) = fun _ _ => some (PRE_first_tail_x6_r0_suffix.st0.s4, PRE_first_tail_x6_r0_suffix.st0.S4)
theorem PRE_first_tail_x6_r0_suffix.st0.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_suffix.st0.F (PRE_first_tail_x6_r0_suffix.st0.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 3).getD 0) PRE_first_tail_x6_r0_suffix.st0.s3 PRE_first_tail_x6_r0_suffix.st0.S3) = fun _ _ => some (PRE_first_tail_x6_r0_suffix.st0.s4, PRE_first_tail_x6_r0_suffix.st0.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_suffix.st0.bodyOkLN_ok PRE_first_tail_x6_r0_suffix.st0.bodyK3F
end Host.Load.Run.Tpl
end

section -- st0/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_suffix.st0.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_suffix.st0.F (PRE_first_tail_x6_r0_suffix.st0.bodyOkL bytes rows) 31188 PRE_first_tail_x6_r0_suffix.st0.s0 PRE_first_tail_x6_r0_suffix.st0.S0 = some (PRE_first_tail_x6_r0_suffix.st0.s4, PRE_first_tail_x6_r0_suffix.st0.S4) :=
  runOk_trans PRE_first_tail_x6_r0_suffix.st0.F (PRE_first_tail_x6_r0_suffix.st0.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_suffix.st0.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 3).getD 0) PRE_first_tail_x6_r0_suffix.st0.s0 PRE_first_tail_x6_r0_suffix.st0.s3 PRE_first_tail_x6_r0_suffix.st0.s4 PRE_first_tail_x6_r0_suffix.st0.S0 PRE_first_tail_x6_r0_suffix.st0.S3 PRE_first_tail_x6_r0_suffix.st0.S4 (runOk_trans PRE_first_tail_x6_r0_suffix.st0.F (PRE_first_tail_x6_r0_suffix.st0.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_suffix.st0.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 2).getD 0) PRE_first_tail_x6_r0_suffix.st0.s0 PRE_first_tail_x6_r0_suffix.st0.s2 PRE_first_tail_x6_r0_suffix.st0.s3 PRE_first_tail_x6_r0_suffix.st0.S0 PRE_first_tail_x6_r0_suffix.st0.S2 PRE_first_tail_x6_r0_suffix.st0.S3 (runOk_trans PRE_first_tail_x6_r0_suffix.st0.F (PRE_first_tail_x6_r0_suffix.st0.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_suffix.st0.ks 1).getD 0) PRE_first_tail_x6_r0_suffix.st0.s0 PRE_first_tail_x6_r0_suffix.st0.s1 PRE_first_tail_x6_r0_suffix.st0.s2 PRE_first_tail_x6_r0_suffix.st0.S0 PRE_first_tail_x6_r0_suffix.st0.S1 PRE_first_tail_x6_r0_suffix.st0.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_suffix.st0.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_suffix.st0.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_suffix.st0.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_suffix.st0.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_suffix.st0.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_suffix.st0.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_suffix.st0.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_suffix.st0.F (PRE_first_tail_x6_r0_suffix.st0.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_suffix.st0.s0
  S0 := PRE_first_tail_x6_r0_suffix.st0.S0
  s1 := PRE_first_tail_x6_r0_suffix.st0.s4
  S1 := PRE_first_tail_x6_r0_suffix.st0.S4
  s2 := PRE_first_tail_x6_r0_suffix.st0.s5
  S2 := PRE_first_tail_x6_r0_suffix.st0.S5
  n := 31188
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_suffix.st0.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_suffix.st0.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_suffix.st0.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_suffix.st0.bodyHalt
  last := PRE_first_tail_x6_r0_suffix.st0.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_suffix.st0.bodyTopCheck
end Host.Load.Run.Tpl
end
