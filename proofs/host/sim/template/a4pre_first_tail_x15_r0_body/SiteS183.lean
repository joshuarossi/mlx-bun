import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl183
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 183 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc183 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P183 : LoadP := PRE_first_tail_x15_r0_body.Pc183.raise 18923
kernel_rfl PRE_first_tail_x15_r0_body.craise183 : Nat.ble PRE_first_tail_x15_r0_body.Pc183.N0 18923 = true
theorem PRE_first_tail_x15_r0_body.raised183 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc183 PRE_first_tail_x15_r0_body.P183 :=
  .inr ⟨18923, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise183, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_183 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_183 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1771.ffi)
def PRE_first_tail_x15_r0_body.khinv183 : PTrie Nat := Stage.setAll PTrie.nil [(21839, 21813), (21817, 21814), (21840, 21815)]
def PRE_first_tail_x15_r0_body.kninv183 : PTrie Nat := Stage.setAll PTrie.nil [(18896, 18896), (18897, 18897), (18898, 18898), (18899, 18899), (18900, 18900), (18901, 18901), (18902, 18902), (18903, 18903), (18904, 18904), (18905, 18905), (18906, 18906), (18907, 18907), (18908, 18908), (18909, 18909), (18910, 18910), (18911, 18911), (18912, 18912), (18913, 18913), (18914, 18914), (18915, 18915), (18916, 18916), (18917, 18917), (18918, 18918), (18919, 18919), (18920, 18920), (18921, 18921), (18922, 18922)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS183 : List Nat := [21793, 21806, 21812, 21813, 21814, 21815, 21816, 21817, 21818, 21819, 21820, 21821, 21822, 21823, 21824, 21825, 21826, 21827, 21828, 21829, 21830, 21831, 21832, 21833, 21834, 21835, 21836, 21837, 21838, 21839, 21840]
def PRE_first_tail_x15_r0_body.cnS183 : List Nat := List.range' 18896 27
def PRE_first_tail_x15_r0_body.ciS183 : List Nat := [] ++ List.range' 18896 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0183 : PRE_first_tail_x15_r0_body.kd183.nh0 = PRE_first_tail_x15_r0_body.cx0_183.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1183 : PRE_first_tail_x15_r0_body.kd183.nh1 = PRE_first_tail_x15_r0_body.cx1_183.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0183 : PRE_first_tail_x15_r0_body.kd183.nn0 = PRE_first_tail_x15_r0_body.cx0_183.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1183 : PRE_first_tail_x15_r0_body.kd183.nn1 = PRE_first_tail_x15_r0_body.cx1_183.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo183 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P183.lo && Nat.ble PRE_first_tail_x15_r0_body.P183.lo PRE_first_tail_x15_r0_body.cx0_183.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P183.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P183.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt183 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_183.mlx.next PRE_first_tail_x15_r0_body.cx1_183.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_183.mlx.nnext PRE_first_tail_x15_r0_body.cx1_183.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband183 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P183.NL && Nat.ble PRE_first_tail_x15_r0_body.P183.NL PRE_first_tail_x15_r0_body.P183.N0 && Nat.ble PRE_first_tail_x15_r0_body.P183.N0 PRE_first_tail_x15_r0_body.cx0_183.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow183 : PRE_first_tail_x15_r0_body.kd183.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren183 : checkRenG PRE_first_tail_x15_r0_body.kd183.hnd PRE_first_tail_x15_r0_body.khinv183 (phB PRE_first_tail_x15_r0_body.cx0_183.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband183 : PRE_first_tail_x15_r0_body.kd183.checkBand PRE_first_tail_x15_r0_body.P183.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos183 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd183.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren183 : checkRenG PRE_first_tail_x15_r0_body.kd183.node PRE_first_tail_x15_r0_body.kninv183 (pnB PRE_first_tail_x15_r0_body.cx0_183.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow183 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd183.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P183.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd183.nodeF j) PRE_first_tail_x15_r0_body.cx1_183.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a183 : PRE_first_tail_x15_r0_body.cx0_183.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b183 : PRE_first_tail_x15_r0_body.cx0_183.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1183 : PRE_first_tail_x15_r0_body.cx1_183.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend183 : PRE_first_tail_x15_r0_body.cx1_183.mlx.pending = PRE_first_tail_x15_r0_body.cx0_183.mlx.pending.map PRE_first_tail_x15_r0_body.kappa183.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh183 : PRE_first_tail_x15_r0_body.cx1_183.mlx.errh = PRE_first_tail_x15_r0_body.cx0_183.mlx.errh.map PRE_first_tail_x15_r0_body.kappa183.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles183 : PRE_first_tail_x15_r0_body.cx1_183.mlx.files = PRE_first_tail_x15_r0_body.cx0_183.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch183 : PRE_first_tail_x15_r0_body.cx1_183.mlx.arch = PRE_first_tail_x15_r0_body.cx0_183.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes183 : PRE_first_tail_x15_r0_body.cx1_183.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_183.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired183 : PRE_first_tail_x15_r0_body.cx1_183.mlx.wired = PRE_first_tail_x15_r0_body.cx0_183.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost183 : PRE_first_tail_x15_r0_body.cx1_183.host = PRE_first_tail_x15_r0_body.cx0_183.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd183`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0183 : PRE_first_tail_x15_r0_body.kd183.n0 = 2818993
kernel_rfl PRE_first_tail_x15_r0_body.ckn1183 : PRE_first_tail_x15_r0_body.kd183.n1 = 2820142
kernel_rfl PRE_first_tail_x15_r0_body.ckheap183 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd183.heap).all (fun x => Nat.ble 2818987 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl183 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd183.heap.get (2818987 + j) = nth? PRE_first_tail_x15_r0_body.pl183 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja183 : Nat.ble 2818987 2818987 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn183 : Nat.ble 7907 7907 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD183 : Nat.ble 2818987 PRE_first_tail_x15_r0_body.kd183.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn183 : Nat.ble 21813 PRE_first_tail_x15_r0_body.kd183.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn183 : Nat.ble 18896 PRE_first_tail_x15_r0_body.kd183.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb183 : Nat.ble 21813 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap183 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd183.heap).all (Nat.ble (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd183 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd183.hnd).all (Nat.ble (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode183 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd183.node).all (Nat.ble (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix183 : Conv.FixOld (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa183 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja183) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn183) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD183) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn183) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn183) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb183) PRE_first_tail_x15_r0_body.fheap183 PRE_first_tail_x15_r0_body.fhnd183 PRE_first_tail_x15_r0_body.fnode183
kernel_rfl PRE_first_tail_x15_r0_body.fcxn183 : (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn183 : (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0183 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_183.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_183.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk183 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd183.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A183 : PRE_first_tail_x15_r0_body.cx1_183.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS183.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_183.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O183 : PRE_first_tail_x15_r0_body.cx1_183.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS183.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_183.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N183 : PRE_first_tail_x15_r0_body.cx1_183.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS183.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_183.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I183 : PRE_first_tail_x15_r0_body.cx1_183.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS183.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_183.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd183 : (PRE_first_tail_x15_r0_body.clo183 ++ PRE_first_tail_x15_r0_body.cln183 ++ PRE_first_tail_x15_r0_body.cli183 ++ PRE_first_tail_x15_r0_body.cwS183 ++ PRE_first_tail_x15_r0_body.cnS183 ++ PRE_first_tail_x15_r0_body.ciS183).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW183 : PRE_first_tail_x15_r0_body.cwS183.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo183.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI183 : PRE_first_tail_x15_r0_body.ciS183.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli183.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN183 : PRE_first_tail_x15_r0_body.cnS183.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF183 : PRE_first_tail_x15_r0_body.cln183.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh183 : PRE_first_tail_x15_r0_body.clo183.all (handleOK PRE_first_tail_x15_r0_body.kappa183 PRE_first_tail_x15_r0_body.P183.lo PRE_first_tail_x15_r0_body.cx0_183.mlx PRE_first_tail_x15_r0_body.cx1_183.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo183 : PRE_first_tail_x15_r0_body.clo183.map (fun h => PRE_first_tail_x15_r0_body.cx1_183.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa183.handle h)) = PRE_first_tail_x15_r0_body.clo183.map (fun h => (PRE_first_tail_x15_r0_body.cx0_183.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa183.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok183 : PRE_first_tail_x15_r0_body.clo183.all (objOK PRE_first_tail_x15_r0_body.kappa183 PRE_first_tail_x15_r0_body.P183.NL PRE_first_tail_x15_r0_body.cx0_183.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd183 : PRE_first_tail_x15_r0_body.cln183.all (nodeOKF PRE_first_tail_x15_r0_body.kappa183 PRE_first_tail_x15_r0_body.P183 PRE_first_tail_x15_r0_body.cx0_183.mlx PRE_first_tail_x15_r0_body.cx1_183.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp183 : ((PRE_first_tail_x15_r0_body.cln183.filter (fullB PRE_first_tail_x15_r0_body.P183))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_183.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa183.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln183.filter (fullB PRE_first_tail_x15_r0_body.P183))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_183.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa183.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI183 : incrB PRE_first_tail_x15_r0_body.kd183.nodeF (List.range' 18896 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK183 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd183.node).all (fun k => Nat.ble 18896 k && Nat.blt k 18923) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL183 : (PRE_first_tail_x15_r0_body.cln183.filter (Nat.ble PRE_first_tail_x15_r0_body.P183.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd183.nodeF i) && (Nat.blt i 18923 || Nat.ble PRE_first_tail_x15_r0_body.kd183.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord183 : (PRE_first_tail_x15_r0_body.cln183.filter (Nat.ble PRE_first_tail_x15_r0_body.P183.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd183.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd183.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd183.nodeF j) (PRE_first_tail_x15_r0_body.kd183.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow183 PRE_first_tail_x15_r0_body.cnn1183 PRE_first_tail_x15_r0_body.fnordI183 PRE_first_tail_x15_r0_body.fnordK183 PRE_first_tail_x15_r0_body.fnordL183
kernel_rfl PRE_first_tail_x15_r0_body.fi183 : PRE_first_tail_x15_r0_body.cli183.all (pnB PRE_first_tail_x15_r0_body.cx0_183.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii183 : PRE_first_tail_x15_r0_body.cli183.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_183.mlx.items.get (PRE_first_tail_x15_r0_body.kappa183.node k) = (PRE_first_tail_x15_r0_body.cx0_183.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa183.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot183 (clean : Conv.NClean (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P183.NL) (cl : SSt (· < 7925) PRE_first_tail_x15_r0_body.cx0_183.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P183 7925 PRE_first_tail_x15_r0_body.kappa183 PRE_first_tail_x15_r0_body.kd183 PRE_first_tail_x15_r0_body.khinv183 PRE_first_tail_x15_r0_body.kninv183 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx PRE_first_tail_x15_r0_body.cx0_183.mlx PRE_first_tail_x15_r0_body.cx1_183.mlx (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo183 PRE_first_tail_x15_r0_body.cln183 PRE_first_tail_x15_r0_body.cli183 PRE_first_tail_x15_r0_body.cwS183 PRE_first_tail_x15_r0_body.cnS183 PRE_first_tail_x15_r0_body.ciS183 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0183, PRE_first_tail_x15_r0_body.cnh1183, PRE_first_tail_x15_r0_body.cnn0183, PRE_first_tail_x15_r0_body.cnn1183, PRE_first_tail_x15_r0_body.cplo183, PRE_first_tail_x15_r0_body.ccnt183, PRE_first_tail_x15_r0_body.cnband183, PRE_first_tail_x15_r0_body.chbelow183, PRE_first_tail_x15_r0_body.chren183, PRE_first_tail_x15_r0_body.cband183, PRE_first_tail_x15_r0_body.cnh1pos183, PRE_first_tail_x15_r0_body.cnren183, PRE_first_tail_x15_r0_body.cnlow183, PRE_first_tail_x15_r0_body.cabs0a183, PRE_first_tail_x15_r0_body.cabs0b183, PRE_first_tail_x15_r0_body.ctok1183, PRE_first_tail_x15_r0_body.cpend183, PRE_first_tail_x15_r0_body.cerrh183, PRE_first_tail_x15_r0_body.cfiles183, PRE_first_tail_x15_r0_body.carch183, PRE_first_tail_x15_r0_body.csizes183, PRE_first_tail_x15_r0_body.cwired183, PRE_first_tail_x15_r0_body.cfix183, clean, PRE_first_tail_x15_r0_body.fcxn183, PRE_first_tail_x15_r0_body.fcnn183, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0183, PRE_first_tail_x15_r0_body.fnk183, PRE_first_tail_x15_r0_body.ckA183, PRE_first_tail_x15_r0_body.cobjsK183, PRE_first_tail_x15_r0_body.cnodesK183, PRE_first_tail_x15_r0_body.citemsK183, PRE_first_tail_x15_r0_body.f1A183, PRE_first_tail_x15_r0_body.f1O183, PRE_first_tail_x15_r0_body.f1N183, PRE_first_tail_x15_r0_body.f1I183, PRE_first_tail_x15_r0_body.fbd183, PRE_first_tail_x15_r0_body.fincW183, PRE_first_tail_x15_r0_body.fincI183, PRE_first_tail_x15_r0_body.fincN183, PRE_first_tail_x15_r0_body.flnF183, PRE_first_tail_x15_r0_body.fh183, PRE_first_tail_x15_r0_body.fo183, PRE_first_tail_x15_r0_body.fok183, PRE_first_tail_x15_r0_body.fnd183, PRE_first_tail_x15_r0_body.fp183, PRE_first_tail_x15_r0_body.fnord183, PRE_first_tail_x15_r0_body.fi183, PRE_first_tail_x15_r0_body.fii183⟩
theorem PRE_first_tail_x15_r0_body.cnshift183 (clean : Conv.NClean (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P183.NL) (cl : SSt (· < 7925) PRE_first_tail_x15_r0_body.cx0_183.mlx) : NShift PRE_first_tail_x15_r0_body.P183 7925 PRE_first_tail_x15_r0_body.kappa183 PRE_first_tail_x15_r0_body.cx0_183 PRE_first_tail_x15_r0_body.cx1_183 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot183 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost183 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0183 PRE_first_tail_x15_r0_body.ckn1183 PRE_first_tail_x15_r0_body.ckheap183 PRE_first_tail_x15_r0_body.ckpl183)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_183 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1770.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_183 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1770.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_183 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1770.ffi) = some PRE_first_tail_x15_r0_body.fxC_183
kernel_rfl PRE_first_tail_x15_r0_body.okrC_183 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1770.ffi) = some PRE_first_tail_x15_r0_body.krC_183
noncomputable def PRE_first_tail_x15_r0_body.fx0_183 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1772.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_183 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1772.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_183 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1772.ffi) = some PRE_first_tail_x15_r0_body.fx0_183
kernel_rfl PRE_first_tail_x15_r0_body.okr0_183 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1772.ffi) = some PRE_first_tail_x15_r0_body.kr0_183
noncomputable def PRE_first_tail_x15_r0_body.fx1_183 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1771.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_183 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1771.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_183 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1771.ffi) = some PRE_first_tail_x15_r0_body.fx1_183
kernel_rfl PRE_first_tail_x15_r0_body.okr1_183 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1771.ffi) = some PRE_first_tail_x15_r0_body.kr1_183
kernel_rfl PRE_first_tail_x15_r0_body.ff0183 : PRE_first_tail_x15_r0_body.fx0_183 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_183 (PRE_first_tail_x15_r0_body.clo183.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_183.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1183 : PRE_first_tail_x15_r0_body.fx1_183 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_183 (PRE_first_tail_x15_r0_body.cwS183.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_183.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck183 : freedLB PRE_first_tail_x15_r0_body.kappa183 PRE_first_tail_x15_r0_body.cx0_183.mlx PRE_first_tail_x15_r0_body.fx0_183 PRE_first_tail_x15_r0_body.fx1_183 PRE_first_tail_x15_r0_body.clo183 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0183 : PRE_first_tail_x15_r0_body.kr0_183.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_183.flags (PRE_first_tail_x15_r0_body.clo183.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_183.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0183 : PRE_first_tail_x15_r0_body.kr0_183.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_183.targs (PRE_first_tail_x15_r0_body.clo183.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_183.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1183 : PRE_first_tail_x15_r0_body.kr1_183.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_183.flags (PRE_first_tail_x15_r0_body.cwS183.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_183.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1183 : PRE_first_tail_x15_r0_body.kr1_183.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_183.targs (PRE_first_tail_x15_r0_body.cwS183.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_183.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck183 : krecLB PRE_first_tail_x15_r0_body.kappa183 7925 PRE_first_tail_x15_r0_body.cx0_183.mlx PRE_first_tail_x15_r0_body.kr0_183 PRE_first_tail_x15_r0_body.kr1_183 PRE_first_tail_x15_r0_body.clo183 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn183 : Nat.ble 7907 7925 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge183 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1771.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1772.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR183 : pendRegB PRE_first_tail_x15_r0_body.kappa183 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe183 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1771.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift183 (clean : Conv.NClean (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P183.NL) (cl : SSt (· < 7925) PRE_first_tail_x15_r0_body.cx0_183.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_183.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_183.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_183.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_183.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P183 7925 PRE_first_tail_x15_r0_body.kappa183 PRE_first_tail_x15_r0_body.s1772.ffi PRE_first_tail_x15_r0_body.s1771.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift183 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue183, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp183 t ht),
    PRE_first_tail_x15_r0_body.cbridge183,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1772.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1771.ffi) (PRE_first_tail_x15_r0_body.cfoot183 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_183 PRE_first_tail_x15_r0_body.ofx1_183 hobjC PRE_first_tail_x15_r0_body.ff0183 PRE_first_tail_x15_r0_body.ff1183 PRE_first_tail_x15_r0_body.ffck183,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1772.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1771.ffi) (PRE_first_tail_x15_r0_body.cfoot183 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_183 PRE_first_tail_x15_r0_body.okr1_183 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn183) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0183 PRE_first_tail_x15_r0_body.fkt0183 PRE_first_tail_x15_r0_body.fkf1183 PRE_first_tail_x15_r0_body.fkt1183 PRE_first_tail_x15_r0_body.fkck183,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0183 PRE_first_tail_x15_r0_body.cnh1183 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe183) PRE_first_tail_x15_r0_body.cpendR183⟩

end Host.Load.Run.Tpl
