import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl150
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 150 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc150 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P150 : LoadP := PRE_first_tail_x15_r0_body.Pc150.raise 18275
kernel_rfl PRE_first_tail_x15_r0_body.craise150 : Nat.ble PRE_first_tail_x15_r0_body.Pc150.N0 18275 = true
theorem PRE_first_tail_x15_r0_body.raised150 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc150 PRE_first_tail_x15_r0_body.P150 :=
  .inr ⟨18275, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise150, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_150 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1456.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_150 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1455.ffi)
def PRE_first_tail_x15_r0_body.khinv150 : PTrie Nat := Stage.setAll PTrie.nil [(21188, 21162), (21166, 21163), (21189, 21164)]
def PRE_first_tail_x15_r0_body.kninv150 : PTrie Nat := Stage.setAll PTrie.nil [(18248, 18248), (18249, 18249), (18250, 18250), (18251, 18251), (18252, 18252), (18253, 18253), (18254, 18254), (18255, 18255), (18256, 18256), (18257, 18257), (18258, 18258), (18259, 18259), (18260, 18260), (18261, 18261), (18262, 18262), (18263, 18263), (18264, 18264), (18265, 18265), (18266, 18266), (18267, 18267), (18268, 18268), (18269, 18269), (18270, 18270), (18271, 18271), (18272, 18272), (18273, 18273), (18274, 18274)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS150 : List Nat := [21142, 21155, 21161, 21162, 21163, 21164, 21165, 21166, 21167, 21168, 21169, 21170, 21171, 21172, 21173, 21174, 21175, 21176, 21177, 21178, 21179, 21180, 21181, 21182, 21183, 21184, 21185, 21186, 21187, 21188, 21189]
def PRE_first_tail_x15_r0_body.cnS150 : List Nat := List.range' 18248 27
def PRE_first_tail_x15_r0_body.ciS150 : List Nat := [] ++ List.range' 18248 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0150 : PRE_first_tail_x15_r0_body.kd150.nh0 = PRE_first_tail_x15_r0_body.cx0_150.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1150 : PRE_first_tail_x15_r0_body.kd150.nh1 = PRE_first_tail_x15_r0_body.cx1_150.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0150 : PRE_first_tail_x15_r0_body.kd150.nn0 = PRE_first_tail_x15_r0_body.cx0_150.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1150 : PRE_first_tail_x15_r0_body.kd150.nn1 = PRE_first_tail_x15_r0_body.cx1_150.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo150 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P150.lo && Nat.ble PRE_first_tail_x15_r0_body.P150.lo PRE_first_tail_x15_r0_body.cx0_150.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P150.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P150.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt150 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_150.mlx.next PRE_first_tail_x15_r0_body.cx1_150.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_150.mlx.nnext PRE_first_tail_x15_r0_body.cx1_150.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband150 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P150.NL && Nat.ble PRE_first_tail_x15_r0_body.P150.NL PRE_first_tail_x15_r0_body.P150.N0 && Nat.ble PRE_first_tail_x15_r0_body.P150.N0 PRE_first_tail_x15_r0_body.cx0_150.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow150 : PRE_first_tail_x15_r0_body.kd150.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren150 : checkRenG PRE_first_tail_x15_r0_body.kd150.hnd PRE_first_tail_x15_r0_body.khinv150 (phB PRE_first_tail_x15_r0_body.cx0_150.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband150 : PRE_first_tail_x15_r0_body.kd150.checkBand PRE_first_tail_x15_r0_body.P150.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos150 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd150.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren150 : checkRenG PRE_first_tail_x15_r0_body.kd150.node PRE_first_tail_x15_r0_body.kninv150 (pnB PRE_first_tail_x15_r0_body.cx0_150.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow150 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd150.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P150.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd150.nodeF j) PRE_first_tail_x15_r0_body.cx1_150.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a150 : PRE_first_tail_x15_r0_body.cx0_150.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b150 : PRE_first_tail_x15_r0_body.cx0_150.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1150 : PRE_first_tail_x15_r0_body.cx1_150.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend150 : PRE_first_tail_x15_r0_body.cx1_150.mlx.pending = PRE_first_tail_x15_r0_body.cx0_150.mlx.pending.map PRE_first_tail_x15_r0_body.kappa150.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh150 : PRE_first_tail_x15_r0_body.cx1_150.mlx.errh = PRE_first_tail_x15_r0_body.cx0_150.mlx.errh.map PRE_first_tail_x15_r0_body.kappa150.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles150 : PRE_first_tail_x15_r0_body.cx1_150.mlx.files = PRE_first_tail_x15_r0_body.cx0_150.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch150 : PRE_first_tail_x15_r0_body.cx1_150.mlx.arch = PRE_first_tail_x15_r0_body.cx0_150.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes150 : PRE_first_tail_x15_r0_body.cx1_150.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_150.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired150 : PRE_first_tail_x15_r0_body.cx1_150.mlx.wired = PRE_first_tail_x15_r0_body.cx0_150.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost150 : PRE_first_tail_x15_r0_body.cx1_150.host = PRE_first_tail_x15_r0_body.cx0_150.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd150`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0150 : PRE_first_tail_x15_r0_body.kd150.n0 = 2792985
kernel_rfl PRE_first_tail_x15_r0_body.ckn1150 : PRE_first_tail_x15_r0_body.kd150.n1 = 2794134
kernel_rfl PRE_first_tail_x15_r0_body.ckheap150 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd150.heap).all (fun x => Nat.ble 2792979 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl150 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd150.heap.get (2792979 + j) = nth? PRE_first_tail_x15_r0_body.pl150 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja150 : Nat.ble 2792979 2792979 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn150 : Nat.ble 6497 6497 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD150 : Nat.ble 2792979 PRE_first_tail_x15_r0_body.kd150.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn150 : Nat.ble 21162 PRE_first_tail_x15_r0_body.kd150.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn150 : Nat.ble 18248 PRE_first_tail_x15_r0_body.kd150.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb150 : Nat.ble 21162 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap150 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd150.heap).all (Nat.ble (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd150 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd150.hnd).all (Nat.ble (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode150 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd150.node).all (Nat.ble (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix150 : Conv.FixOld (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa150 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja150) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn150) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD150) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn150) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn150) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb150) PRE_first_tail_x15_r0_body.fheap150 PRE_first_tail_x15_r0_body.fhnd150 PRE_first_tail_x15_r0_body.fnode150
kernel_rfl PRE_first_tail_x15_r0_body.fcxn150 : (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn150 : (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0150 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_150.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_150.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk150 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd150.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A150 : PRE_first_tail_x15_r0_body.cx1_150.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS150.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_150.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O150 : PRE_first_tail_x15_r0_body.cx1_150.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS150.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_150.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N150 : PRE_first_tail_x15_r0_body.cx1_150.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS150.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_150.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I150 : PRE_first_tail_x15_r0_body.cx1_150.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS150.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_150.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd150 : (PRE_first_tail_x15_r0_body.clo150 ++ PRE_first_tail_x15_r0_body.cln150 ++ PRE_first_tail_x15_r0_body.cli150 ++ PRE_first_tail_x15_r0_body.cwS150 ++ PRE_first_tail_x15_r0_body.cnS150 ++ PRE_first_tail_x15_r0_body.ciS150).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW150 : PRE_first_tail_x15_r0_body.cwS150.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo150.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI150 : PRE_first_tail_x15_r0_body.ciS150.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli150.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN150 : PRE_first_tail_x15_r0_body.cnS150.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF150 : PRE_first_tail_x15_r0_body.cln150.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh150 : PRE_first_tail_x15_r0_body.clo150.all (handleOK PRE_first_tail_x15_r0_body.kappa150 PRE_first_tail_x15_r0_body.P150.lo PRE_first_tail_x15_r0_body.cx0_150.mlx PRE_first_tail_x15_r0_body.cx1_150.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo150 : PRE_first_tail_x15_r0_body.clo150.map (fun h => PRE_first_tail_x15_r0_body.cx1_150.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa150.handle h)) = PRE_first_tail_x15_r0_body.clo150.map (fun h => (PRE_first_tail_x15_r0_body.cx0_150.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa150.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok150 : PRE_first_tail_x15_r0_body.clo150.all (objOK PRE_first_tail_x15_r0_body.kappa150 PRE_first_tail_x15_r0_body.P150.NL PRE_first_tail_x15_r0_body.cx0_150.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd150 : PRE_first_tail_x15_r0_body.cln150.all (nodeOKF PRE_first_tail_x15_r0_body.kappa150 PRE_first_tail_x15_r0_body.P150 PRE_first_tail_x15_r0_body.cx0_150.mlx PRE_first_tail_x15_r0_body.cx1_150.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp150 : ((PRE_first_tail_x15_r0_body.cln150.filter (fullB PRE_first_tail_x15_r0_body.P150))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_150.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa150.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln150.filter (fullB PRE_first_tail_x15_r0_body.P150))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_150.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa150.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI150 : incrB PRE_first_tail_x15_r0_body.kd150.nodeF (List.range' 18248 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK150 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd150.node).all (fun k => Nat.ble 18248 k && Nat.blt k 18275) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL150 : (PRE_first_tail_x15_r0_body.cln150.filter (Nat.ble PRE_first_tail_x15_r0_body.P150.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd150.nodeF i) && (Nat.blt i 18275 || Nat.ble PRE_first_tail_x15_r0_body.kd150.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord150 : (PRE_first_tail_x15_r0_body.cln150.filter (Nat.ble PRE_first_tail_x15_r0_body.P150.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd150.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd150.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd150.nodeF j) (PRE_first_tail_x15_r0_body.kd150.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow150 PRE_first_tail_x15_r0_body.cnn1150 PRE_first_tail_x15_r0_body.fnordI150 PRE_first_tail_x15_r0_body.fnordK150 PRE_first_tail_x15_r0_body.fnordL150
kernel_rfl PRE_first_tail_x15_r0_body.fi150 : PRE_first_tail_x15_r0_body.cli150.all (pnB PRE_first_tail_x15_r0_body.cx0_150.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii150 : PRE_first_tail_x15_r0_body.cli150.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_150.mlx.items.get (PRE_first_tail_x15_r0_body.kappa150.node k) = (PRE_first_tail_x15_r0_body.cx0_150.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa150.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot150 (clean : Conv.NClean (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P150.NL) (cl : SSt (· < 6515) PRE_first_tail_x15_r0_body.cx0_150.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P150 6515 PRE_first_tail_x15_r0_body.kappa150 PRE_first_tail_x15_r0_body.kd150 PRE_first_tail_x15_r0_body.khinv150 PRE_first_tail_x15_r0_body.kninv150 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx PRE_first_tail_x15_r0_body.cx0_150.mlx PRE_first_tail_x15_r0_body.cx1_150.mlx (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo150 PRE_first_tail_x15_r0_body.cln150 PRE_first_tail_x15_r0_body.cli150 PRE_first_tail_x15_r0_body.cwS150 PRE_first_tail_x15_r0_body.cnS150 PRE_first_tail_x15_r0_body.ciS150 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0150, PRE_first_tail_x15_r0_body.cnh1150, PRE_first_tail_x15_r0_body.cnn0150, PRE_first_tail_x15_r0_body.cnn1150, PRE_first_tail_x15_r0_body.cplo150, PRE_first_tail_x15_r0_body.ccnt150, PRE_first_tail_x15_r0_body.cnband150, PRE_first_tail_x15_r0_body.chbelow150, PRE_first_tail_x15_r0_body.chren150, PRE_first_tail_x15_r0_body.cband150, PRE_first_tail_x15_r0_body.cnh1pos150, PRE_first_tail_x15_r0_body.cnren150, PRE_first_tail_x15_r0_body.cnlow150, PRE_first_tail_x15_r0_body.cabs0a150, PRE_first_tail_x15_r0_body.cabs0b150, PRE_first_tail_x15_r0_body.ctok1150, PRE_first_tail_x15_r0_body.cpend150, PRE_first_tail_x15_r0_body.cerrh150, PRE_first_tail_x15_r0_body.cfiles150, PRE_first_tail_x15_r0_body.carch150, PRE_first_tail_x15_r0_body.csizes150, PRE_first_tail_x15_r0_body.cwired150, PRE_first_tail_x15_r0_body.cfix150, clean, PRE_first_tail_x15_r0_body.fcxn150, PRE_first_tail_x15_r0_body.fcnn150, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0150, PRE_first_tail_x15_r0_body.fnk150, PRE_first_tail_x15_r0_body.ckA150, PRE_first_tail_x15_r0_body.cobjsK150, PRE_first_tail_x15_r0_body.cnodesK150, PRE_first_tail_x15_r0_body.citemsK150, PRE_first_tail_x15_r0_body.f1A150, PRE_first_tail_x15_r0_body.f1O150, PRE_first_tail_x15_r0_body.f1N150, PRE_first_tail_x15_r0_body.f1I150, PRE_first_tail_x15_r0_body.fbd150, PRE_first_tail_x15_r0_body.fincW150, PRE_first_tail_x15_r0_body.fincI150, PRE_first_tail_x15_r0_body.fincN150, PRE_first_tail_x15_r0_body.flnF150, PRE_first_tail_x15_r0_body.fh150, PRE_first_tail_x15_r0_body.fo150, PRE_first_tail_x15_r0_body.fok150, PRE_first_tail_x15_r0_body.fnd150, PRE_first_tail_x15_r0_body.fp150, PRE_first_tail_x15_r0_body.fnord150, PRE_first_tail_x15_r0_body.fi150, PRE_first_tail_x15_r0_body.fii150⟩
theorem PRE_first_tail_x15_r0_body.cnshift150 (clean : Conv.NClean (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P150.NL) (cl : SSt (· < 6515) PRE_first_tail_x15_r0_body.cx0_150.mlx) : NShift PRE_first_tail_x15_r0_body.P150 6515 PRE_first_tail_x15_r0_body.kappa150 PRE_first_tail_x15_r0_body.cx0_150 PRE_first_tail_x15_r0_body.cx1_150 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot150 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost150 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0150 PRE_first_tail_x15_r0_body.ckn1150 PRE_first_tail_x15_r0_body.ckheap150 PRE_first_tail_x15_r0_body.ckpl150)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_150 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1454.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_150 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1454.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_150 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1454.ffi) = some PRE_first_tail_x15_r0_body.fxC_150
kernel_rfl PRE_first_tail_x15_r0_body.okrC_150 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1454.ffi) = some PRE_first_tail_x15_r0_body.krC_150
noncomputable def PRE_first_tail_x15_r0_body.fx0_150 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1456.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_150 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1456.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_150 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1456.ffi) = some PRE_first_tail_x15_r0_body.fx0_150
kernel_rfl PRE_first_tail_x15_r0_body.okr0_150 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1456.ffi) = some PRE_first_tail_x15_r0_body.kr0_150
noncomputable def PRE_first_tail_x15_r0_body.fx1_150 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1455.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_150 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1455.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_150 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1455.ffi) = some PRE_first_tail_x15_r0_body.fx1_150
kernel_rfl PRE_first_tail_x15_r0_body.okr1_150 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1455.ffi) = some PRE_first_tail_x15_r0_body.kr1_150
kernel_rfl PRE_first_tail_x15_r0_body.ff0150 : PRE_first_tail_x15_r0_body.fx0_150 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_150 (PRE_first_tail_x15_r0_body.clo150.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_150.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1150 : PRE_first_tail_x15_r0_body.fx1_150 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_150 (PRE_first_tail_x15_r0_body.cwS150.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_150.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck150 : freedLB PRE_first_tail_x15_r0_body.kappa150 PRE_first_tail_x15_r0_body.cx0_150.mlx PRE_first_tail_x15_r0_body.fx0_150 PRE_first_tail_x15_r0_body.fx1_150 PRE_first_tail_x15_r0_body.clo150 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0150 : PRE_first_tail_x15_r0_body.kr0_150.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_150.flags (PRE_first_tail_x15_r0_body.clo150.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_150.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0150 : PRE_first_tail_x15_r0_body.kr0_150.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_150.targs (PRE_first_tail_x15_r0_body.clo150.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_150.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1150 : PRE_first_tail_x15_r0_body.kr1_150.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_150.flags (PRE_first_tail_x15_r0_body.cwS150.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_150.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1150 : PRE_first_tail_x15_r0_body.kr1_150.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_150.targs (PRE_first_tail_x15_r0_body.cwS150.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_150.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck150 : krecLB PRE_first_tail_x15_r0_body.kappa150 6515 PRE_first_tail_x15_r0_body.cx0_150.mlx PRE_first_tail_x15_r0_body.kr0_150 PRE_first_tail_x15_r0_body.kr1_150 PRE_first_tail_x15_r0_body.clo150 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn150 : Nat.ble 6497 6515 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge150 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1455.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1456.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR150 : pendRegB PRE_first_tail_x15_r0_body.kappa150 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1456.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe150 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1456.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1455.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift150 (clean : Conv.NClean (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P150.NL) (cl : SSt (· < 6515) PRE_first_tail_x15_r0_body.cx0_150.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_150.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_150.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_150.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_150.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P150 6515 PRE_first_tail_x15_r0_body.kappa150 PRE_first_tail_x15_r0_body.s1456.ffi PRE_first_tail_x15_r0_body.s1455.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift150 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue150, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp150 t ht),
    PRE_first_tail_x15_r0_body.cbridge150,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1456.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1455.ffi) (PRE_first_tail_x15_r0_body.cfoot150 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_150 PRE_first_tail_x15_r0_body.ofx1_150 hobjC PRE_first_tail_x15_r0_body.ff0150 PRE_first_tail_x15_r0_body.ff1150 PRE_first_tail_x15_r0_body.ffck150,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1456.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1455.ffi) (PRE_first_tail_x15_r0_body.cfoot150 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_150 PRE_first_tail_x15_r0_body.okr1_150 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn150) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0150 PRE_first_tail_x15_r0_body.fkt0150 PRE_first_tail_x15_r0_body.fkf1150 PRE_first_tail_x15_r0_body.fkt1150 PRE_first_tail_x15_r0_body.fkck150,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0150 PRE_first_tail_x15_r0_body.cnh1150 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe150) PRE_first_tail_x15_r0_body.cpendR150⟩

end Host.Load.Run.Tpl
