import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl66
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 66 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc66 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P66 : LoadP := PRE_first_tail_x15_r0_body.Pc66.raise 16616
kernel_rfl PRE_first_tail_x15_r0_body.craise66 : Nat.ble PRE_first_tail_x15_r0_body.Pc66.N0 16616 = true
theorem PRE_first_tail_x15_r0_body.raised66 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc66 PRE_first_tail_x15_r0_body.P66 :=
  .inr ⟨16616, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise66, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_66 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_66 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s650.ffi)
def PRE_first_tail_x15_r0_body.khinv66 : PTrie Nat := Stage.setAll PTrie.nil [(19536, 19510), (19514, 19511), (19537, 19512)]
def PRE_first_tail_x15_r0_body.kninv66 : PTrie Nat := Stage.setAll PTrie.nil [(16589, 16589), (16590, 16590), (16591, 16591), (16592, 16592), (16593, 16593), (16594, 16594), (16595, 16595), (16596, 16596), (16597, 16597), (16598, 16598), (16599, 16599), (16600, 16600), (16601, 16601), (16602, 16602), (16603, 16603), (16604, 16604), (16605, 16605), (16606, 16606), (16607, 16607), (16608, 16608), (16609, 16609), (16610, 16610), (16611, 16611), (16612, 16612), (16613, 16613), (16614, 16614), (16615, 16615)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS66 : List Nat := [19490, 19503, 19509, 19510, 19511, 19512, 19513, 19514, 19515, 19516, 19517, 19518, 19519, 19520, 19521, 19522, 19523, 19524, 19525, 19526, 19527, 19528, 19529, 19530, 19531, 19532, 19533, 19534, 19535, 19536, 19537]
def PRE_first_tail_x15_r0_body.cnS66 : List Nat := List.range' 16589 27
def PRE_first_tail_x15_r0_body.ciS66 : List Nat := [] ++ List.range' 16589 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh066 : PRE_first_tail_x15_r0_body.kd66.nh0 = PRE_first_tail_x15_r0_body.cx0_66.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh166 : PRE_first_tail_x15_r0_body.kd66.nh1 = PRE_first_tail_x15_r0_body.cx1_66.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn066 : PRE_first_tail_x15_r0_body.kd66.nn0 = PRE_first_tail_x15_r0_body.cx0_66.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn166 : PRE_first_tail_x15_r0_body.kd66.nn1 = PRE_first_tail_x15_r0_body.cx1_66.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo66 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P66.lo && Nat.ble PRE_first_tail_x15_r0_body.P66.lo PRE_first_tail_x15_r0_body.cx0_66.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P66.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P66.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt66 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_66.mlx.next PRE_first_tail_x15_r0_body.cx1_66.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_66.mlx.nnext PRE_first_tail_x15_r0_body.cx1_66.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband66 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P66.NL && Nat.ble PRE_first_tail_x15_r0_body.P66.NL PRE_first_tail_x15_r0_body.P66.N0 && Nat.ble PRE_first_tail_x15_r0_body.P66.N0 PRE_first_tail_x15_r0_body.cx0_66.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow66 : PRE_first_tail_x15_r0_body.kd66.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren66 : checkRenG PRE_first_tail_x15_r0_body.kd66.hnd PRE_first_tail_x15_r0_body.khinv66 (phB PRE_first_tail_x15_r0_body.cx0_66.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband66 : PRE_first_tail_x15_r0_body.kd66.checkBand PRE_first_tail_x15_r0_body.P66.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos66 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd66.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren66 : checkRenG PRE_first_tail_x15_r0_body.kd66.node PRE_first_tail_x15_r0_body.kninv66 (pnB PRE_first_tail_x15_r0_body.cx0_66.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P66.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd66.nodeF j) PRE_first_tail_x15_r0_body.cx1_66.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a66 : PRE_first_tail_x15_r0_body.cx0_66.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b66 : PRE_first_tail_x15_r0_body.cx0_66.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok166 : PRE_first_tail_x15_r0_body.cx1_66.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.pending = PRE_first_tail_x15_r0_body.cx0_66.mlx.pending.map PRE_first_tail_x15_r0_body.kappa66.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.errh = PRE_first_tail_x15_r0_body.cx0_66.mlx.errh.map PRE_first_tail_x15_r0_body.kappa66.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.files = PRE_first_tail_x15_r0_body.cx0_66.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.arch = PRE_first_tail_x15_r0_body.cx0_66.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_66.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.wired = PRE_first_tail_x15_r0_body.cx0_66.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost66 : PRE_first_tail_x15_r0_body.cx1_66.host = PRE_first_tail_x15_r0_body.cx0_66.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd66`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn066 : PRE_first_tail_x15_r0_body.kd66.n0 = 2727065
kernel_rfl PRE_first_tail_x15_r0_body.ckn166 : PRE_first_tail_x15_r0_body.kd66.n1 = 2728214
kernel_rfl PRE_first_tail_x15_r0_body.ckheap66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.heap).all (fun x => Nat.ble 2727059 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl66 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd66.heap.get (2727059 + j) = nth? PRE_first_tail_x15_r0_body.pl66 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja66 : Nat.ble 2727059 2727059 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn66 : Nat.ble 2906 2906 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD66 : Nat.ble 2727059 PRE_first_tail_x15_r0_body.kd66.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn66 : Nat.ble 19510 PRE_first_tail_x15_r0_body.kd66.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn66 : Nat.ble 16589 PRE_first_tail_x15_r0_body.kd66.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb66 : Nat.ble 19510 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.heap).all (Nat.ble (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.hnd).all (Nat.ble (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.node).all (Nat.ble (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix66 : Conv.FixOld (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa66 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja66) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn66) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD66) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn66) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn66) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb66) PRE_first_tail_x15_r0_body.fheap66 PRE_first_tail_x15_r0_body.fhnd66 PRE_first_tail_x15_r0_body.fnode66
kernel_rfl PRE_first_tail_x15_r0_body.fcxn66 : (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn66 : (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle066 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_66.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_66.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS66.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_66.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS66.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_66.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS66.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_66.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS66.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_66.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd66 : (PRE_first_tail_x15_r0_body.clo66 ++ PRE_first_tail_x15_r0_body.cln66 ++ PRE_first_tail_x15_r0_body.cli66 ++ PRE_first_tail_x15_r0_body.cwS66 ++ PRE_first_tail_x15_r0_body.cnS66 ++ PRE_first_tail_x15_r0_body.ciS66).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW66 : PRE_first_tail_x15_r0_body.cwS66.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo66.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI66 : PRE_first_tail_x15_r0_body.ciS66.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli66.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN66 : PRE_first_tail_x15_r0_body.cnS66.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF66 : PRE_first_tail_x15_r0_body.cln66.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh66 : PRE_first_tail_x15_r0_body.clo66.all (handleOK PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.P66.lo PRE_first_tail_x15_r0_body.cx0_66.mlx PRE_first_tail_x15_r0_body.cx1_66.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo66 : PRE_first_tail_x15_r0_body.clo66.map (fun h => PRE_first_tail_x15_r0_body.cx1_66.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa66.handle h)) = PRE_first_tail_x15_r0_body.clo66.map (fun h => (PRE_first_tail_x15_r0_body.cx0_66.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa66.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok66 : PRE_first_tail_x15_r0_body.clo66.all (objOK PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.P66.NL PRE_first_tail_x15_r0_body.cx0_66.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd66 : PRE_first_tail_x15_r0_body.cln66.all (nodeOKF PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.P66 PRE_first_tail_x15_r0_body.cx0_66.mlx PRE_first_tail_x15_r0_body.cx1_66.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp66 : ((PRE_first_tail_x15_r0_body.cln66.filter (fullB PRE_first_tail_x15_r0_body.P66))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_66.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa66.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln66.filter (fullB PRE_first_tail_x15_r0_body.P66))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_66.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa66.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI66 : incrB PRE_first_tail_x15_r0_body.kd66.nodeF (List.range' 16589 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.node).all (fun k => Nat.ble 16589 k && Nat.blt k 16616) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL66 : (PRE_first_tail_x15_r0_body.cln66.filter (Nat.ble PRE_first_tail_x15_r0_body.P66.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd66.nodeF i) && (Nat.blt i 16616 || Nat.ble PRE_first_tail_x15_r0_body.kd66.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord66 : (PRE_first_tail_x15_r0_body.cln66.filter (Nat.ble PRE_first_tail_x15_r0_body.P66.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd66.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd66.nodeF j) (PRE_first_tail_x15_r0_body.kd66.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow66 PRE_first_tail_x15_r0_body.cnn166 PRE_first_tail_x15_r0_body.fnordI66 PRE_first_tail_x15_r0_body.fnordK66 PRE_first_tail_x15_r0_body.fnordL66
kernel_rfl PRE_first_tail_x15_r0_body.fi66 : PRE_first_tail_x15_r0_body.cli66.all (pnB PRE_first_tail_x15_r0_body.cx0_66.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii66 : PRE_first_tail_x15_r0_body.cli66.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_66.mlx.items.get (PRE_first_tail_x15_r0_body.kappa66.node k) = (PRE_first_tail_x15_r0_body.cx0_66.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa66.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot66 (clean : Conv.NClean (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P66.NL) (cl : SSt (· < 2924) PRE_first_tail_x15_r0_body.cx0_66.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P66 2924 PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.kd66 PRE_first_tail_x15_r0_body.khinv66 PRE_first_tail_x15_r0_body.kninv66 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx PRE_first_tail_x15_r0_body.cx0_66.mlx PRE_first_tail_x15_r0_body.cx1_66.mlx (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo66 PRE_first_tail_x15_r0_body.cln66 PRE_first_tail_x15_r0_body.cli66 PRE_first_tail_x15_r0_body.cwS66 PRE_first_tail_x15_r0_body.cnS66 PRE_first_tail_x15_r0_body.ciS66 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh066, PRE_first_tail_x15_r0_body.cnh166, PRE_first_tail_x15_r0_body.cnn066, PRE_first_tail_x15_r0_body.cnn166, PRE_first_tail_x15_r0_body.cplo66, PRE_first_tail_x15_r0_body.ccnt66, PRE_first_tail_x15_r0_body.cnband66, PRE_first_tail_x15_r0_body.chbelow66, PRE_first_tail_x15_r0_body.chren66, PRE_first_tail_x15_r0_body.cband66, PRE_first_tail_x15_r0_body.cnh1pos66, PRE_first_tail_x15_r0_body.cnren66, PRE_first_tail_x15_r0_body.cnlow66, PRE_first_tail_x15_r0_body.cabs0a66, PRE_first_tail_x15_r0_body.cabs0b66, PRE_first_tail_x15_r0_body.ctok166, PRE_first_tail_x15_r0_body.cpend66, PRE_first_tail_x15_r0_body.cerrh66, PRE_first_tail_x15_r0_body.cfiles66, PRE_first_tail_x15_r0_body.carch66, PRE_first_tail_x15_r0_body.csizes66, PRE_first_tail_x15_r0_body.cwired66, PRE_first_tail_x15_r0_body.cfix66, clean, PRE_first_tail_x15_r0_body.fcxn66, PRE_first_tail_x15_r0_body.fcnn66, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle066, PRE_first_tail_x15_r0_body.fnk66, PRE_first_tail_x15_r0_body.ckA66, PRE_first_tail_x15_r0_body.cobjsK66, PRE_first_tail_x15_r0_body.cnodesK66, PRE_first_tail_x15_r0_body.citemsK66, PRE_first_tail_x15_r0_body.f1A66, PRE_first_tail_x15_r0_body.f1O66, PRE_first_tail_x15_r0_body.f1N66, PRE_first_tail_x15_r0_body.f1I66, PRE_first_tail_x15_r0_body.fbd66, PRE_first_tail_x15_r0_body.fincW66, PRE_first_tail_x15_r0_body.fincI66, PRE_first_tail_x15_r0_body.fincN66, PRE_first_tail_x15_r0_body.flnF66, PRE_first_tail_x15_r0_body.fh66, PRE_first_tail_x15_r0_body.fo66, PRE_first_tail_x15_r0_body.fok66, PRE_first_tail_x15_r0_body.fnd66, PRE_first_tail_x15_r0_body.fp66, PRE_first_tail_x15_r0_body.fnord66, PRE_first_tail_x15_r0_body.fi66, PRE_first_tail_x15_r0_body.fii66⟩
theorem PRE_first_tail_x15_r0_body.cnshift66 (clean : Conv.NClean (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P66.NL) (cl : SSt (· < 2924) PRE_first_tail_x15_r0_body.cx0_66.mlx) : NShift PRE_first_tail_x15_r0_body.P66 2924 PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.cx0_66 PRE_first_tail_x15_r0_body.cx1_66 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot66 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost66 (compact_a_eq PRE_first_tail_x15_r0_body.ckn066 PRE_first_tail_x15_r0_body.ckn166 PRE_first_tail_x15_r0_body.ckheap66 PRE_first_tail_x15_r0_body.ckpl66)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_66 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s649.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_66 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s649.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_66 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s649.ffi) = some PRE_first_tail_x15_r0_body.fxC_66
kernel_rfl PRE_first_tail_x15_r0_body.okrC_66 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s649.ffi) = some PRE_first_tail_x15_r0_body.krC_66
noncomputable def PRE_first_tail_x15_r0_body.fx0_66 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s651.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_66 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s651.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_66 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s651.ffi) = some PRE_first_tail_x15_r0_body.fx0_66
kernel_rfl PRE_first_tail_x15_r0_body.okr0_66 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s651.ffi) = some PRE_first_tail_x15_r0_body.kr0_66
noncomputable def PRE_first_tail_x15_r0_body.fx1_66 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s650.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_66 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s650.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_66 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s650.ffi) = some PRE_first_tail_x15_r0_body.fx1_66
kernel_rfl PRE_first_tail_x15_r0_body.okr1_66 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s650.ffi) = some PRE_first_tail_x15_r0_body.kr1_66
kernel_rfl PRE_first_tail_x15_r0_body.ff066 : PRE_first_tail_x15_r0_body.fx0_66 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_66 (PRE_first_tail_x15_r0_body.clo66.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_66.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff166 : PRE_first_tail_x15_r0_body.fx1_66 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_66 (PRE_first_tail_x15_r0_body.cwS66.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_66.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck66 : freedLB PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.cx0_66.mlx PRE_first_tail_x15_r0_body.fx0_66 PRE_first_tail_x15_r0_body.fx1_66 PRE_first_tail_x15_r0_body.clo66 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf066 : PRE_first_tail_x15_r0_body.kr0_66.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_66.flags (PRE_first_tail_x15_r0_body.clo66.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_66.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt066 : PRE_first_tail_x15_r0_body.kr0_66.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_66.targs (PRE_first_tail_x15_r0_body.clo66.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_66.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf166 : PRE_first_tail_x15_r0_body.kr1_66.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_66.flags (PRE_first_tail_x15_r0_body.cwS66.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_66.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt166 : PRE_first_tail_x15_r0_body.kr1_66.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_66.targs (PRE_first_tail_x15_r0_body.cwS66.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_66.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck66 : krecLB PRE_first_tail_x15_r0_body.kappa66 2924 PRE_first_tail_x15_r0_body.cx0_66.mlx PRE_first_tail_x15_r0_body.kr0_66 PRE_first_tail_x15_r0_body.kr1_66 PRE_first_tail_x15_r0_body.clo66 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn66 : Nat.ble 2906 2924 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge66 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s650.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s651.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR66 : pendRegB PRE_first_tail_x15_r0_body.kappa66 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe66 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s650.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift66 (clean : Conv.NClean (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P66.NL) (cl : SSt (· < 2924) PRE_first_tail_x15_r0_body.cx0_66.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_66.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_66.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_66.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_66.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P66 2924 PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.s651.ffi PRE_first_tail_x15_r0_body.s650.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift66 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue66, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp66 t ht),
    PRE_first_tail_x15_r0_body.cbridge66,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s651.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s650.ffi) (PRE_first_tail_x15_r0_body.cfoot66 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_66 PRE_first_tail_x15_r0_body.ofx1_66 hobjC PRE_first_tail_x15_r0_body.ff066 PRE_first_tail_x15_r0_body.ff166 PRE_first_tail_x15_r0_body.ffck66,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s651.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s650.ffi) (PRE_first_tail_x15_r0_body.cfoot66 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_66 PRE_first_tail_x15_r0_body.okr1_66 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn66) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf066 PRE_first_tail_x15_r0_body.fkt066 PRE_first_tail_x15_r0_body.fkf166 PRE_first_tail_x15_r0_body.fkt166 PRE_first_tail_x15_r0_body.fkck66,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh066 PRE_first_tail_x15_r0_body.cnh166 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe66) PRE_first_tail_x15_r0_body.cpendR66⟩

end Host.Load.Run.Tpl
