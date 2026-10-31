import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl3
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 3 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc3 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P3 : LoadP := PRE_first_tail_x15_r0_body.Pc3.raise 15368
kernel_rfl PRE_first_tail_x15_r0_body.craise3 : Nat.ble PRE_first_tail_x15_r0_body.Pc3.N0 15368 = true
theorem PRE_first_tail_x15_r0_body.raised3 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc3 PRE_first_tail_x15_r0_body.P3 :=
  .inr ⟨15368, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise3, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_3 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s43.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_3 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s42.ffi)
def PRE_first_tail_x15_r0_body.khinv3 : PTrie Nat := Stage.setAll PTrie.nil [(18296, 18270), (18274, 18271), (18297, 18272)]
def PRE_first_tail_x15_r0_body.kninv3 : PTrie Nat := Stage.setAll PTrie.nil [(15341, 15341), (15342, 15342), (15343, 15343), (15344, 15344), (15345, 15345), (15346, 15346), (15347, 15347), (15348, 15348), (15349, 15349), (15350, 15350), (15351, 15351), (15352, 15352), (15353, 15353), (15354, 15354), (15355, 15355), (15356, 15356), (15357, 15357), (15358, 15358), (15359, 15359), (15360, 15360), (15361, 15361), (15362, 15362), (15363, 15363), (15364, 15364), (15365, 15365), (15366, 15366), (15367, 15367)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS3 : List Nat := [18250, 18263, 18269, 18270, 18271, 18272, 18273, 18274, 18275, 18276, 18277, 18278, 18279, 18280, 18281, 18282, 18283, 18284, 18285, 18286, 18287, 18288, 18289, 18290, 18291, 18292, 18293, 18294, 18295, 18296, 18297]
def PRE_first_tail_x15_r0_body.cnS3 : List Nat := List.range' 15341 27
def PRE_first_tail_x15_r0_body.ciS3 : List Nat := [] ++ List.range' 15341 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh03 : PRE_first_tail_x15_r0_body.kd3.nh0 = PRE_first_tail_x15_r0_body.cx0_3.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh13 : PRE_first_tail_x15_r0_body.kd3.nh1 = PRE_first_tail_x15_r0_body.cx1_3.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn03 : PRE_first_tail_x15_r0_body.kd3.nn0 = PRE_first_tail_x15_r0_body.cx0_3.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn13 : PRE_first_tail_x15_r0_body.kd3.nn1 = PRE_first_tail_x15_r0_body.cx1_3.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo3 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P3.lo && Nat.ble PRE_first_tail_x15_r0_body.P3.lo PRE_first_tail_x15_r0_body.cx0_3.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P3.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P3.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt3 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_3.mlx.next PRE_first_tail_x15_r0_body.cx1_3.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_3.mlx.nnext PRE_first_tail_x15_r0_body.cx1_3.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband3 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P3.NL && Nat.ble PRE_first_tail_x15_r0_body.P3.NL PRE_first_tail_x15_r0_body.P3.N0 && Nat.ble PRE_first_tail_x15_r0_body.P3.N0 PRE_first_tail_x15_r0_body.cx0_3.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow3 : PRE_first_tail_x15_r0_body.kd3.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren3 : checkRenG PRE_first_tail_x15_r0_body.kd3.hnd PRE_first_tail_x15_r0_body.khinv3 (phB PRE_first_tail_x15_r0_body.cx0_3.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband3 : PRE_first_tail_x15_r0_body.kd3.checkBand PRE_first_tail_x15_r0_body.P3.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos3 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd3.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren3 : checkRenG PRE_first_tail_x15_r0_body.kd3.node PRE_first_tail_x15_r0_body.kninv3 (pnB PRE_first_tail_x15_r0_body.cx0_3.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow3 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd3.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P3.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd3.nodeF j) PRE_first_tail_x15_r0_body.cx1_3.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a3 : PRE_first_tail_x15_r0_body.cx0_3.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b3 : PRE_first_tail_x15_r0_body.cx0_3.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok13 : PRE_first_tail_x15_r0_body.cx1_3.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend3 : PRE_first_tail_x15_r0_body.cx1_3.mlx.pending = PRE_first_tail_x15_r0_body.cx0_3.mlx.pending.map PRE_first_tail_x15_r0_body.kappa3.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh3 : PRE_first_tail_x15_r0_body.cx1_3.mlx.errh = PRE_first_tail_x15_r0_body.cx0_3.mlx.errh.map PRE_first_tail_x15_r0_body.kappa3.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles3 : PRE_first_tail_x15_r0_body.cx1_3.mlx.files = PRE_first_tail_x15_r0_body.cx0_3.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch3 : PRE_first_tail_x15_r0_body.cx1_3.mlx.arch = PRE_first_tail_x15_r0_body.cx0_3.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes3 : PRE_first_tail_x15_r0_body.cx1_3.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_3.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired3 : PRE_first_tail_x15_r0_body.cx1_3.mlx.wired = PRE_first_tail_x15_r0_body.cx0_3.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost3 : PRE_first_tail_x15_r0_body.cx1_3.host = PRE_first_tail_x15_r0_body.cx0_3.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd3`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn03 : PRE_first_tail_x15_r0_body.kd3.n0 = 2677629
kernel_rfl PRE_first_tail_x15_r0_body.ckn13 : PRE_first_tail_x15_r0_body.kd3.n1 = 2678778
kernel_rfl PRE_first_tail_x15_r0_body.ckheap3 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd3.heap).all (fun x => Nat.ble 2677623 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl3 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd3.heap.get (2677623 + j) = nth? PRE_first_tail_x15_r0_body.pl3 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja3 : Nat.ble 2677623 2677623 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn3 : Nat.ble 212 212 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD3 : Nat.ble 2677623 PRE_first_tail_x15_r0_body.kd3.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn3 : Nat.ble 18270 PRE_first_tail_x15_r0_body.kd3.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn3 : Nat.ble 15341 PRE_first_tail_x15_r0_body.kd3.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb3 : Nat.ble 18270 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap3 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd3.heap).all (Nat.ble (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd3 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd3.hnd).all (Nat.ble (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode3 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd3.node).all (Nat.ble (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix3 : Conv.FixOld (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa3 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja3) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn3) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD3) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn3) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn3) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb3) PRE_first_tail_x15_r0_body.fheap3 PRE_first_tail_x15_r0_body.fhnd3 PRE_first_tail_x15_r0_body.fnode3
kernel_rfl PRE_first_tail_x15_r0_body.fcxn3 : (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn3 : (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle03 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_3.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_3.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk3 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd3.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A3 : PRE_first_tail_x15_r0_body.cx1_3.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS3.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_3.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O3 : PRE_first_tail_x15_r0_body.cx1_3.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS3.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_3.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N3 : PRE_first_tail_x15_r0_body.cx1_3.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS3.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_3.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I3 : PRE_first_tail_x15_r0_body.cx1_3.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS3.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_3.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd3 : (PRE_first_tail_x15_r0_body.clo3 ++ PRE_first_tail_x15_r0_body.cln3 ++ PRE_first_tail_x15_r0_body.cli3 ++ PRE_first_tail_x15_r0_body.cwS3 ++ PRE_first_tail_x15_r0_body.cnS3 ++ PRE_first_tail_x15_r0_body.ciS3).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW3 : PRE_first_tail_x15_r0_body.cwS3.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo3.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI3 : PRE_first_tail_x15_r0_body.ciS3.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli3.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN3 : PRE_first_tail_x15_r0_body.cnS3.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF3 : PRE_first_tail_x15_r0_body.cln3.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh3 : PRE_first_tail_x15_r0_body.clo3.all (handleOK PRE_first_tail_x15_r0_body.kappa3 PRE_first_tail_x15_r0_body.P3.lo PRE_first_tail_x15_r0_body.cx0_3.mlx PRE_first_tail_x15_r0_body.cx1_3.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo3 : PRE_first_tail_x15_r0_body.clo3.map (fun h => PRE_first_tail_x15_r0_body.cx1_3.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa3.handle h)) = PRE_first_tail_x15_r0_body.clo3.map (fun h => (PRE_first_tail_x15_r0_body.cx0_3.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa3.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok3 : PRE_first_tail_x15_r0_body.clo3.all (objOK PRE_first_tail_x15_r0_body.kappa3 PRE_first_tail_x15_r0_body.P3.NL PRE_first_tail_x15_r0_body.cx0_3.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd3 : PRE_first_tail_x15_r0_body.cln3.all (nodeOKF PRE_first_tail_x15_r0_body.kappa3 PRE_first_tail_x15_r0_body.P3 PRE_first_tail_x15_r0_body.cx0_3.mlx PRE_first_tail_x15_r0_body.cx1_3.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp3 : ((PRE_first_tail_x15_r0_body.cln3.filter (fullB PRE_first_tail_x15_r0_body.P3))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_3.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa3.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln3.filter (fullB PRE_first_tail_x15_r0_body.P3))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_3.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa3.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI3 : incrB PRE_first_tail_x15_r0_body.kd3.nodeF (List.range' 15341 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK3 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd3.node).all (fun k => Nat.ble 15341 k && Nat.blt k 15368) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL3 : (PRE_first_tail_x15_r0_body.cln3.filter (Nat.ble PRE_first_tail_x15_r0_body.P3.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd3.nodeF i) && (Nat.blt i 15368 || Nat.ble PRE_first_tail_x15_r0_body.kd3.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord3 : (PRE_first_tail_x15_r0_body.cln3.filter (Nat.ble PRE_first_tail_x15_r0_body.P3.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd3.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd3.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd3.nodeF j) (PRE_first_tail_x15_r0_body.kd3.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow3 PRE_first_tail_x15_r0_body.cnn13 PRE_first_tail_x15_r0_body.fnordI3 PRE_first_tail_x15_r0_body.fnordK3 PRE_first_tail_x15_r0_body.fnordL3
kernel_rfl PRE_first_tail_x15_r0_body.fi3 : PRE_first_tail_x15_r0_body.cli3.all (pnB PRE_first_tail_x15_r0_body.cx0_3.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii3 : PRE_first_tail_x15_r0_body.cli3.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_3.mlx.items.get (PRE_first_tail_x15_r0_body.kappa3.node k) = (PRE_first_tail_x15_r0_body.cx0_3.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa3.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot3 (clean : Conv.NClean (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P3.NL) (cl : SSt (· < 230) PRE_first_tail_x15_r0_body.cx0_3.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P3 230 PRE_first_tail_x15_r0_body.kappa3 PRE_first_tail_x15_r0_body.kd3 PRE_first_tail_x15_r0_body.khinv3 PRE_first_tail_x15_r0_body.kninv3 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx PRE_first_tail_x15_r0_body.cx0_3.mlx PRE_first_tail_x15_r0_body.cx1_3.mlx (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo3 PRE_first_tail_x15_r0_body.cln3 PRE_first_tail_x15_r0_body.cli3 PRE_first_tail_x15_r0_body.cwS3 PRE_first_tail_x15_r0_body.cnS3 PRE_first_tail_x15_r0_body.ciS3 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh03, PRE_first_tail_x15_r0_body.cnh13, PRE_first_tail_x15_r0_body.cnn03, PRE_first_tail_x15_r0_body.cnn13, PRE_first_tail_x15_r0_body.cplo3, PRE_first_tail_x15_r0_body.ccnt3, PRE_first_tail_x15_r0_body.cnband3, PRE_first_tail_x15_r0_body.chbelow3, PRE_first_tail_x15_r0_body.chren3, PRE_first_tail_x15_r0_body.cband3, PRE_first_tail_x15_r0_body.cnh1pos3, PRE_first_tail_x15_r0_body.cnren3, PRE_first_tail_x15_r0_body.cnlow3, PRE_first_tail_x15_r0_body.cabs0a3, PRE_first_tail_x15_r0_body.cabs0b3, PRE_first_tail_x15_r0_body.ctok13, PRE_first_tail_x15_r0_body.cpend3, PRE_first_tail_x15_r0_body.cerrh3, PRE_first_tail_x15_r0_body.cfiles3, PRE_first_tail_x15_r0_body.carch3, PRE_first_tail_x15_r0_body.csizes3, PRE_first_tail_x15_r0_body.cwired3, PRE_first_tail_x15_r0_body.cfix3, clean, PRE_first_tail_x15_r0_body.fcxn3, PRE_first_tail_x15_r0_body.fcnn3, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle03, PRE_first_tail_x15_r0_body.fnk3, PRE_first_tail_x15_r0_body.ckA3, PRE_first_tail_x15_r0_body.cobjsK3, PRE_first_tail_x15_r0_body.cnodesK3, PRE_first_tail_x15_r0_body.citemsK3, PRE_first_tail_x15_r0_body.f1A3, PRE_first_tail_x15_r0_body.f1O3, PRE_first_tail_x15_r0_body.f1N3, PRE_first_tail_x15_r0_body.f1I3, PRE_first_tail_x15_r0_body.fbd3, PRE_first_tail_x15_r0_body.fincW3, PRE_first_tail_x15_r0_body.fincI3, PRE_first_tail_x15_r0_body.fincN3, PRE_first_tail_x15_r0_body.flnF3, PRE_first_tail_x15_r0_body.fh3, PRE_first_tail_x15_r0_body.fo3, PRE_first_tail_x15_r0_body.fok3, PRE_first_tail_x15_r0_body.fnd3, PRE_first_tail_x15_r0_body.fp3, PRE_first_tail_x15_r0_body.fnord3, PRE_first_tail_x15_r0_body.fi3, PRE_first_tail_x15_r0_body.fii3⟩
theorem PRE_first_tail_x15_r0_body.cnshift3 (clean : Conv.NClean (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P3.NL) (cl : SSt (· < 230) PRE_first_tail_x15_r0_body.cx0_3.mlx) : NShift PRE_first_tail_x15_r0_body.P3 230 PRE_first_tail_x15_r0_body.kappa3 PRE_first_tail_x15_r0_body.cx0_3 PRE_first_tail_x15_r0_body.cx1_3 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot3 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost3 (compact_a_eq PRE_first_tail_x15_r0_body.ckn03 PRE_first_tail_x15_r0_body.ckn13 PRE_first_tail_x15_r0_body.ckheap3 PRE_first_tail_x15_r0_body.ckpl3)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_3 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s41.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_3 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s41.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_3 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s41.ffi) = some PRE_first_tail_x15_r0_body.fxC_3
kernel_rfl PRE_first_tail_x15_r0_body.okrC_3 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s41.ffi) = some PRE_first_tail_x15_r0_body.krC_3
noncomputable def PRE_first_tail_x15_r0_body.fx0_3 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s43.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_3 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s43.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_3 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s43.ffi) = some PRE_first_tail_x15_r0_body.fx0_3
kernel_rfl PRE_first_tail_x15_r0_body.okr0_3 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s43.ffi) = some PRE_first_tail_x15_r0_body.kr0_3
noncomputable def PRE_first_tail_x15_r0_body.fx1_3 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s42.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_3 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s42.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_3 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s42.ffi) = some PRE_first_tail_x15_r0_body.fx1_3
kernel_rfl PRE_first_tail_x15_r0_body.okr1_3 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s42.ffi) = some PRE_first_tail_x15_r0_body.kr1_3
kernel_rfl PRE_first_tail_x15_r0_body.ff03 : PRE_first_tail_x15_r0_body.fx0_3 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_3 (PRE_first_tail_x15_r0_body.clo3.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_3.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff13 : PRE_first_tail_x15_r0_body.fx1_3 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_3 (PRE_first_tail_x15_r0_body.cwS3.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_3.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck3 : freedLB PRE_first_tail_x15_r0_body.kappa3 PRE_first_tail_x15_r0_body.cx0_3.mlx PRE_first_tail_x15_r0_body.fx0_3 PRE_first_tail_x15_r0_body.fx1_3 PRE_first_tail_x15_r0_body.clo3 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf03 : PRE_first_tail_x15_r0_body.kr0_3.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_3.flags (PRE_first_tail_x15_r0_body.clo3.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_3.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt03 : PRE_first_tail_x15_r0_body.kr0_3.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_3.targs (PRE_first_tail_x15_r0_body.clo3.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_3.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf13 : PRE_first_tail_x15_r0_body.kr1_3.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_3.flags (PRE_first_tail_x15_r0_body.cwS3.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_3.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt13 : PRE_first_tail_x15_r0_body.kr1_3.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_3.targs (PRE_first_tail_x15_r0_body.cwS3.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_3.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck3 : krecLB PRE_first_tail_x15_r0_body.kappa3 230 PRE_first_tail_x15_r0_body.cx0_3.mlx PRE_first_tail_x15_r0_body.kr0_3 PRE_first_tail_x15_r0_body.kr1_3 PRE_first_tail_x15_r0_body.clo3 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn3 : Nat.ble 212 230 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge3 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s42.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s43.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR3 : pendRegB PRE_first_tail_x15_r0_body.kappa3 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s43.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe3 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s43.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s42.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift3 (clean : Conv.NClean (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P3.NL) (cl : SSt (· < 230) PRE_first_tail_x15_r0_body.cx0_3.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_3.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_3.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_3.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_3.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P3 230 PRE_first_tail_x15_r0_body.kappa3 PRE_first_tail_x15_r0_body.s43.ffi PRE_first_tail_x15_r0_body.s42.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift3 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue3, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp3 t ht),
    PRE_first_tail_x15_r0_body.cbridge3,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s43.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s42.ffi) (PRE_first_tail_x15_r0_body.cfoot3 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_3 PRE_first_tail_x15_r0_body.ofx1_3 hobjC PRE_first_tail_x15_r0_body.ff03 PRE_first_tail_x15_r0_body.ff13 PRE_first_tail_x15_r0_body.ffck3,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s43.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s42.ffi) (PRE_first_tail_x15_r0_body.cfoot3 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_3 PRE_first_tail_x15_r0_body.okr1_3 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn3) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf03 PRE_first_tail_x15_r0_body.fkt03 PRE_first_tail_x15_r0_body.fkf13 PRE_first_tail_x15_r0_body.fkt13 PRE_first_tail_x15_r0_body.fkck3,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh03 PRE_first_tail_x15_r0_body.cnh13 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe3) PRE_first_tail_x15_r0_body.cpendR3⟩

end Host.Load.Run.Tpl
