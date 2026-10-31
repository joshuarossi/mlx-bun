import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl114
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 114 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc114 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P114 : LoadP := PRE_first_tail_x15_r0_body.Pc114.raise 17564
kernel_rfl PRE_first_tail_x15_r0_body.craise114 : Nat.ble PRE_first_tail_x15_r0_body.Pc114.N0 17564 = true
theorem PRE_first_tail_x15_r0_body.raised114 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc114 PRE_first_tail_x15_r0_body.P114 :=
  .inr ⟨17564, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise114, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_114 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1111.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_114 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1110.ffi)
def PRE_first_tail_x15_r0_body.khinv114 : PTrie Nat := Stage.setAll PTrie.nil [(20480, 20454), (20458, 20455), (20481, 20456)]
def PRE_first_tail_x15_r0_body.kninv114 : PTrie Nat := Stage.setAll PTrie.nil [(17537, 17537), (17538, 17538), (17539, 17539), (17540, 17540), (17541, 17541), (17542, 17542), (17543, 17543), (17544, 17544), (17545, 17545), (17546, 17546), (17547, 17547), (17548, 17548), (17549, 17549), (17550, 17550), (17551, 17551), (17552, 17552), (17553, 17553), (17554, 17554), (17555, 17555), (17556, 17556), (17557, 17557), (17558, 17558), (17559, 17559), (17560, 17560), (17561, 17561), (17562, 17562), (17563, 17563)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS114 : List Nat := [20434, 20447, 20453, 20454, 20455, 20456, 20457, 20458, 20459, 20460, 20461, 20462, 20463, 20464, 20465, 20466, 20467, 20468, 20469, 20470, 20471, 20472, 20473, 20474, 20475, 20476, 20477, 20478, 20479, 20480, 20481]
def PRE_first_tail_x15_r0_body.cnS114 : List Nat := List.range' 17537 27
def PRE_first_tail_x15_r0_body.ciS114 : List Nat := [] ++ List.range' 17537 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0114 : PRE_first_tail_x15_r0_body.kd114.nh0 = PRE_first_tail_x15_r0_body.cx0_114.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1114 : PRE_first_tail_x15_r0_body.kd114.nh1 = PRE_first_tail_x15_r0_body.cx1_114.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0114 : PRE_first_tail_x15_r0_body.kd114.nn0 = PRE_first_tail_x15_r0_body.cx0_114.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1114 : PRE_first_tail_x15_r0_body.kd114.nn1 = PRE_first_tail_x15_r0_body.cx1_114.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo114 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P114.lo && Nat.ble PRE_first_tail_x15_r0_body.P114.lo PRE_first_tail_x15_r0_body.cx0_114.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P114.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P114.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt114 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_114.mlx.next PRE_first_tail_x15_r0_body.cx1_114.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_114.mlx.nnext PRE_first_tail_x15_r0_body.cx1_114.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband114 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P114.NL && Nat.ble PRE_first_tail_x15_r0_body.P114.NL PRE_first_tail_x15_r0_body.P114.N0 && Nat.ble PRE_first_tail_x15_r0_body.P114.N0 PRE_first_tail_x15_r0_body.cx0_114.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow114 : PRE_first_tail_x15_r0_body.kd114.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren114 : checkRenG PRE_first_tail_x15_r0_body.kd114.hnd PRE_first_tail_x15_r0_body.khinv114 (phB PRE_first_tail_x15_r0_body.cx0_114.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband114 : PRE_first_tail_x15_r0_body.kd114.checkBand PRE_first_tail_x15_r0_body.P114.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos114 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd114.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren114 : checkRenG PRE_first_tail_x15_r0_body.kd114.node PRE_first_tail_x15_r0_body.kninv114 (pnB PRE_first_tail_x15_r0_body.cx0_114.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow114 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd114.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P114.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd114.nodeF j) PRE_first_tail_x15_r0_body.cx1_114.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a114 : PRE_first_tail_x15_r0_body.cx0_114.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b114 : PRE_first_tail_x15_r0_body.cx0_114.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1114 : PRE_first_tail_x15_r0_body.cx1_114.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend114 : PRE_first_tail_x15_r0_body.cx1_114.mlx.pending = PRE_first_tail_x15_r0_body.cx0_114.mlx.pending.map PRE_first_tail_x15_r0_body.kappa114.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh114 : PRE_first_tail_x15_r0_body.cx1_114.mlx.errh = PRE_first_tail_x15_r0_body.cx0_114.mlx.errh.map PRE_first_tail_x15_r0_body.kappa114.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles114 : PRE_first_tail_x15_r0_body.cx1_114.mlx.files = PRE_first_tail_x15_r0_body.cx0_114.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch114 : PRE_first_tail_x15_r0_body.cx1_114.mlx.arch = PRE_first_tail_x15_r0_body.cx0_114.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes114 : PRE_first_tail_x15_r0_body.cx1_114.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_114.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired114 : PRE_first_tail_x15_r0_body.cx1_114.mlx.wired = PRE_first_tail_x15_r0_body.cx0_114.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost114 : PRE_first_tail_x15_r0_body.cx1_114.host = PRE_first_tail_x15_r0_body.cx0_114.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd114`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0114 : PRE_first_tail_x15_r0_body.kd114.n0 = 2764729
kernel_rfl PRE_first_tail_x15_r0_body.ckn1114 : PRE_first_tail_x15_r0_body.kd114.n1 = 2765878
kernel_rfl PRE_first_tail_x15_r0_body.ckheap114 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd114.heap).all (fun x => Nat.ble 2764723 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl114 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd114.heap.get (2764723 + j) = nth? PRE_first_tail_x15_r0_body.pl114 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja114 : Nat.ble 2764723 2764723 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn114 : Nat.ble 4958 4958 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD114 : Nat.ble 2764723 PRE_first_tail_x15_r0_body.kd114.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn114 : Nat.ble 20454 PRE_first_tail_x15_r0_body.kd114.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn114 : Nat.ble 17537 PRE_first_tail_x15_r0_body.kd114.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb114 : Nat.ble 20454 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap114 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd114.heap).all (Nat.ble (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd114 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd114.hnd).all (Nat.ble (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode114 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd114.node).all (Nat.ble (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix114 : Conv.FixOld (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa114 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja114) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn114) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD114) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn114) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn114) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb114) PRE_first_tail_x15_r0_body.fheap114 PRE_first_tail_x15_r0_body.fhnd114 PRE_first_tail_x15_r0_body.fnode114
kernel_rfl PRE_first_tail_x15_r0_body.fcxn114 : (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn114 : (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0114 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_114.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_114.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk114 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd114.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A114 : PRE_first_tail_x15_r0_body.cx1_114.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS114.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_114.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O114 : PRE_first_tail_x15_r0_body.cx1_114.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS114.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_114.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N114 : PRE_first_tail_x15_r0_body.cx1_114.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS114.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_114.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I114 : PRE_first_tail_x15_r0_body.cx1_114.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS114.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_114.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd114 : (PRE_first_tail_x15_r0_body.clo114 ++ PRE_first_tail_x15_r0_body.cln114 ++ PRE_first_tail_x15_r0_body.cli114 ++ PRE_first_tail_x15_r0_body.cwS114 ++ PRE_first_tail_x15_r0_body.cnS114 ++ PRE_first_tail_x15_r0_body.ciS114).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW114 : PRE_first_tail_x15_r0_body.cwS114.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo114.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI114 : PRE_first_tail_x15_r0_body.ciS114.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli114.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN114 : PRE_first_tail_x15_r0_body.cnS114.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF114 : PRE_first_tail_x15_r0_body.cln114.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh114 : PRE_first_tail_x15_r0_body.clo114.all (handleOK PRE_first_tail_x15_r0_body.kappa114 PRE_first_tail_x15_r0_body.P114.lo PRE_first_tail_x15_r0_body.cx0_114.mlx PRE_first_tail_x15_r0_body.cx1_114.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo114 : PRE_first_tail_x15_r0_body.clo114.map (fun h => PRE_first_tail_x15_r0_body.cx1_114.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa114.handle h)) = PRE_first_tail_x15_r0_body.clo114.map (fun h => (PRE_first_tail_x15_r0_body.cx0_114.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa114.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok114 : PRE_first_tail_x15_r0_body.clo114.all (objOK PRE_first_tail_x15_r0_body.kappa114 PRE_first_tail_x15_r0_body.P114.NL PRE_first_tail_x15_r0_body.cx0_114.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd114 : PRE_first_tail_x15_r0_body.cln114.all (nodeOKF PRE_first_tail_x15_r0_body.kappa114 PRE_first_tail_x15_r0_body.P114 PRE_first_tail_x15_r0_body.cx0_114.mlx PRE_first_tail_x15_r0_body.cx1_114.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp114 : ((PRE_first_tail_x15_r0_body.cln114.filter (fullB PRE_first_tail_x15_r0_body.P114))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_114.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa114.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln114.filter (fullB PRE_first_tail_x15_r0_body.P114))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_114.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa114.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI114 : incrB PRE_first_tail_x15_r0_body.kd114.nodeF (List.range' 17537 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK114 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd114.node).all (fun k => Nat.ble 17537 k && Nat.blt k 17564) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL114 : (PRE_first_tail_x15_r0_body.cln114.filter (Nat.ble PRE_first_tail_x15_r0_body.P114.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd114.nodeF i) && (Nat.blt i 17564 || Nat.ble PRE_first_tail_x15_r0_body.kd114.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord114 : (PRE_first_tail_x15_r0_body.cln114.filter (Nat.ble PRE_first_tail_x15_r0_body.P114.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd114.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd114.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd114.nodeF j) (PRE_first_tail_x15_r0_body.kd114.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow114 PRE_first_tail_x15_r0_body.cnn1114 PRE_first_tail_x15_r0_body.fnordI114 PRE_first_tail_x15_r0_body.fnordK114 PRE_first_tail_x15_r0_body.fnordL114
kernel_rfl PRE_first_tail_x15_r0_body.fi114 : PRE_first_tail_x15_r0_body.cli114.all (pnB PRE_first_tail_x15_r0_body.cx0_114.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii114 : PRE_first_tail_x15_r0_body.cli114.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_114.mlx.items.get (PRE_first_tail_x15_r0_body.kappa114.node k) = (PRE_first_tail_x15_r0_body.cx0_114.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa114.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot114 (clean : Conv.NClean (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P114.NL) (cl : SSt (· < 4976) PRE_first_tail_x15_r0_body.cx0_114.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P114 4976 PRE_first_tail_x15_r0_body.kappa114 PRE_first_tail_x15_r0_body.kd114 PRE_first_tail_x15_r0_body.khinv114 PRE_first_tail_x15_r0_body.kninv114 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx PRE_first_tail_x15_r0_body.cx0_114.mlx PRE_first_tail_x15_r0_body.cx1_114.mlx (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo114 PRE_first_tail_x15_r0_body.cln114 PRE_first_tail_x15_r0_body.cli114 PRE_first_tail_x15_r0_body.cwS114 PRE_first_tail_x15_r0_body.cnS114 PRE_first_tail_x15_r0_body.ciS114 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0114, PRE_first_tail_x15_r0_body.cnh1114, PRE_first_tail_x15_r0_body.cnn0114, PRE_first_tail_x15_r0_body.cnn1114, PRE_first_tail_x15_r0_body.cplo114, PRE_first_tail_x15_r0_body.ccnt114, PRE_first_tail_x15_r0_body.cnband114, PRE_first_tail_x15_r0_body.chbelow114, PRE_first_tail_x15_r0_body.chren114, PRE_first_tail_x15_r0_body.cband114, PRE_first_tail_x15_r0_body.cnh1pos114, PRE_first_tail_x15_r0_body.cnren114, PRE_first_tail_x15_r0_body.cnlow114, PRE_first_tail_x15_r0_body.cabs0a114, PRE_first_tail_x15_r0_body.cabs0b114, PRE_first_tail_x15_r0_body.ctok1114, PRE_first_tail_x15_r0_body.cpend114, PRE_first_tail_x15_r0_body.cerrh114, PRE_first_tail_x15_r0_body.cfiles114, PRE_first_tail_x15_r0_body.carch114, PRE_first_tail_x15_r0_body.csizes114, PRE_first_tail_x15_r0_body.cwired114, PRE_first_tail_x15_r0_body.cfix114, clean, PRE_first_tail_x15_r0_body.fcxn114, PRE_first_tail_x15_r0_body.fcnn114, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0114, PRE_first_tail_x15_r0_body.fnk114, PRE_first_tail_x15_r0_body.ckA114, PRE_first_tail_x15_r0_body.cobjsK114, PRE_first_tail_x15_r0_body.cnodesK114, PRE_first_tail_x15_r0_body.citemsK114, PRE_first_tail_x15_r0_body.f1A114, PRE_first_tail_x15_r0_body.f1O114, PRE_first_tail_x15_r0_body.f1N114, PRE_first_tail_x15_r0_body.f1I114, PRE_first_tail_x15_r0_body.fbd114, PRE_first_tail_x15_r0_body.fincW114, PRE_first_tail_x15_r0_body.fincI114, PRE_first_tail_x15_r0_body.fincN114, PRE_first_tail_x15_r0_body.flnF114, PRE_first_tail_x15_r0_body.fh114, PRE_first_tail_x15_r0_body.fo114, PRE_first_tail_x15_r0_body.fok114, PRE_first_tail_x15_r0_body.fnd114, PRE_first_tail_x15_r0_body.fp114, PRE_first_tail_x15_r0_body.fnord114, PRE_first_tail_x15_r0_body.fi114, PRE_first_tail_x15_r0_body.fii114⟩
theorem PRE_first_tail_x15_r0_body.cnshift114 (clean : Conv.NClean (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P114.NL) (cl : SSt (· < 4976) PRE_first_tail_x15_r0_body.cx0_114.mlx) : NShift PRE_first_tail_x15_r0_body.P114 4976 PRE_first_tail_x15_r0_body.kappa114 PRE_first_tail_x15_r0_body.cx0_114 PRE_first_tail_x15_r0_body.cx1_114 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot114 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost114 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0114 PRE_first_tail_x15_r0_body.ckn1114 PRE_first_tail_x15_r0_body.ckheap114 PRE_first_tail_x15_r0_body.ckpl114)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_114 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1109.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_114 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1109.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_114 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1109.ffi) = some PRE_first_tail_x15_r0_body.fxC_114
kernel_rfl PRE_first_tail_x15_r0_body.okrC_114 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1109.ffi) = some PRE_first_tail_x15_r0_body.krC_114
noncomputable def PRE_first_tail_x15_r0_body.fx0_114 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1111.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_114 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1111.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_114 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1111.ffi) = some PRE_first_tail_x15_r0_body.fx0_114
kernel_rfl PRE_first_tail_x15_r0_body.okr0_114 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1111.ffi) = some PRE_first_tail_x15_r0_body.kr0_114
noncomputable def PRE_first_tail_x15_r0_body.fx1_114 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1110.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_114 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1110.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_114 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1110.ffi) = some PRE_first_tail_x15_r0_body.fx1_114
kernel_rfl PRE_first_tail_x15_r0_body.okr1_114 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1110.ffi) = some PRE_first_tail_x15_r0_body.kr1_114
kernel_rfl PRE_first_tail_x15_r0_body.ff0114 : PRE_first_tail_x15_r0_body.fx0_114 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_114 (PRE_first_tail_x15_r0_body.clo114.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_114.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1114 : PRE_first_tail_x15_r0_body.fx1_114 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_114 (PRE_first_tail_x15_r0_body.cwS114.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_114.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck114 : freedLB PRE_first_tail_x15_r0_body.kappa114 PRE_first_tail_x15_r0_body.cx0_114.mlx PRE_first_tail_x15_r0_body.fx0_114 PRE_first_tail_x15_r0_body.fx1_114 PRE_first_tail_x15_r0_body.clo114 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0114 : PRE_first_tail_x15_r0_body.kr0_114.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_114.flags (PRE_first_tail_x15_r0_body.clo114.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_114.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0114 : PRE_first_tail_x15_r0_body.kr0_114.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_114.targs (PRE_first_tail_x15_r0_body.clo114.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_114.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1114 : PRE_first_tail_x15_r0_body.kr1_114.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_114.flags (PRE_first_tail_x15_r0_body.cwS114.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_114.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1114 : PRE_first_tail_x15_r0_body.kr1_114.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_114.targs (PRE_first_tail_x15_r0_body.cwS114.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_114.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck114 : krecLB PRE_first_tail_x15_r0_body.kappa114 4976 PRE_first_tail_x15_r0_body.cx0_114.mlx PRE_first_tail_x15_r0_body.kr0_114 PRE_first_tail_x15_r0_body.kr1_114 PRE_first_tail_x15_r0_body.clo114 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn114 : Nat.ble 4958 4976 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge114 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1110.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1111.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR114 : pendRegB PRE_first_tail_x15_r0_body.kappa114 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1111.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe114 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1111.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1110.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift114 (clean : Conv.NClean (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P114.NL) (cl : SSt (· < 4976) PRE_first_tail_x15_r0_body.cx0_114.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_114.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_114.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_114.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_114.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P114 4976 PRE_first_tail_x15_r0_body.kappa114 PRE_first_tail_x15_r0_body.s1111.ffi PRE_first_tail_x15_r0_body.s1110.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift114 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue114, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp114 t ht),
    PRE_first_tail_x15_r0_body.cbridge114,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1111.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1110.ffi) (PRE_first_tail_x15_r0_body.cfoot114 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_114 PRE_first_tail_x15_r0_body.ofx1_114 hobjC PRE_first_tail_x15_r0_body.ff0114 PRE_first_tail_x15_r0_body.ff1114 PRE_first_tail_x15_r0_body.ffck114,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1111.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1110.ffi) (PRE_first_tail_x15_r0_body.cfoot114 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_114 PRE_first_tail_x15_r0_body.okr1_114 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn114) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0114 PRE_first_tail_x15_r0_body.fkt0114 PRE_first_tail_x15_r0_body.fkf1114 PRE_first_tail_x15_r0_body.fkt1114 PRE_first_tail_x15_r0_body.fkck114,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0114 PRE_first_tail_x15_r0_body.cnh1114 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe114) PRE_first_tail_x15_r0_body.cpendR114⟩

end Host.Load.Run.Tpl
