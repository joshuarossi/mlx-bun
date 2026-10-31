import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl102
import host.sim.conv.CompactFull
import host.sim.template.FootGen
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
