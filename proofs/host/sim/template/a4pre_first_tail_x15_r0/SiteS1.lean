import host.sim.template.a4pre_first_tail_x15_r0.SiteCl1
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 1 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0.Pc1 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the call's node counter (`Conv.full_compactQD`; `κ` fixes the call's nodes). -/
def PRE_first_tail_x15_r0.P1 : LoadP := PRE_first_tail_x15_r0.Pc1.raise 15235
kernel_rfl PRE_first_tail_x15_r0.craise1 : Nat.ble PRE_first_tail_x15_r0.Pc1.N0 15235 = true
theorem PRE_first_tail_x15_r0.raised1 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0.Pc1 PRE_first_tail_x15_r0.P1 :=
  .inr ⟨15235, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.craise1, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0.cx0_1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi)
noncomputable abbrev PRE_first_tail_x15_r0.cx1_1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s18.ffi)
def PRE_first_tail_x15_r0.khinv1 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0.kninv1 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0.cwS1 : List Nat := []
def PRE_first_tail_x15_r0.cnS1 : List Nat := List.range' 15235 0
def PRE_first_tail_x15_r0.ciS1 : List Nat := [] ++ List.range' 15235 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0.cnh01 : PRE_first_tail_x15_r0.kd1.nh0 = PRE_first_tail_x15_r0.cx0_1.mlx.next
kernel_rfl PRE_first_tail_x15_r0.cnh11 : PRE_first_tail_x15_r0.kd1.nh1 = PRE_first_tail_x15_r0.cx1_1.mlx.next
kernel_rfl PRE_first_tail_x15_r0.cnn01 : PRE_first_tail_x15_r0.kd1.nn0 = PRE_first_tail_x15_r0.cx0_1.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0.cnn11 : PRE_first_tail_x15_r0.kd1.nn1 = PRE_first_tail_x15_r0.cx1_1.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0.cplo1 : (Nat.blt 0 PRE_first_tail_x15_r0.P1.lo && Nat.ble PRE_first_tail_x15_r0.P1.lo PRE_first_tail_x15_r0.cx0_1.mlx.next && Nat.ble PRE_first_tail_x15_r0.P1.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0.P1.E) = true
kernel_rfl PRE_first_tail_x15_r0.ccnt1 : (Nat.ble PRE_first_tail_x15_r0.cx0_1.mlx.next PRE_first_tail_x15_r0.cx1_1.mlx.next && Nat.ble PRE_first_tail_x15_r0.cx0_1.mlx.nnext PRE_first_tail_x15_r0.cx1_1.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0.cnband1 : (Nat.blt 0 PRE_first_tail_x15_r0.P1.NL && Nat.ble PRE_first_tail_x15_r0.P1.NL PRE_first_tail_x15_r0.P1.N0 && Nat.ble PRE_first_tail_x15_r0.P1.N0 PRE_first_tail_x15_r0.cx0_1.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0.chbelow1 : PRE_first_tail_x15_r0.kd1.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0.chren1 : checkRenG PRE_first_tail_x15_r0.kd1.hnd PRE_first_tail_x15_r0.khinv1 (phB PRE_first_tail_x15_r0.cx0_1.mlx) = true
kernel_rfl PRE_first_tail_x15_r0.cband1 : PRE_first_tail_x15_r0.kd1.checkBand PRE_first_tail_x15_r0.P1.lo = true
kernel_rfl PRE_first_tail_x15_r0.cnh1pos1 : Nat.blt 0 PRE_first_tail_x15_r0.kd1.nh1 = true
kernel_rfl PRE_first_tail_x15_r0.cnren1 : checkRenG PRE_first_tail_x15_r0.kd1.node PRE_first_tail_x15_r0.kninv1 (pnB PRE_first_tail_x15_r0.cx0_1.mlx) = true
kernel_rfl PRE_first_tail_x15_r0.cnlow1 : (PTrie.keysA PRE_first_tail_x15_r0.kd1.node).all (fun j => Nat.ble PRE_first_tail_x15_r0.P1.NL j && Nat.blt (PRE_first_tail_x15_r0.kd1.nodeF j) PRE_first_tail_x15_r0.cx1_1.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0.cabs0a1 : PRE_first_tail_x15_r0.cx0_1.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0.cabs0b1 : PRE_first_tail_x15_r0.cx0_1.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0.ctok11 : PRE_first_tail_x15_r0.cx1_1.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0.cpend1 : PRE_first_tail_x15_r0.cx1_1.mlx.pending = PRE_first_tail_x15_r0.cx0_1.mlx.pending.map PRE_first_tail_x15_r0.kappa1.pend
kernel_rfl PRE_first_tail_x15_r0.cerrh1 : PRE_first_tail_x15_r0.cx1_1.mlx.errh = PRE_first_tail_x15_r0.cx0_1.mlx.errh.map PRE_first_tail_x15_r0.kappa1.arg
kernel_rfl PRE_first_tail_x15_r0.cfiles1 : PRE_first_tail_x15_r0.cx1_1.mlx.files = PRE_first_tail_x15_r0.cx0_1.mlx.files
kernel_rfl PRE_first_tail_x15_r0.carch1 : PRE_first_tail_x15_r0.cx1_1.mlx.arch = PRE_first_tail_x15_r0.cx0_1.mlx.arch
kernel_rfl PRE_first_tail_x15_r0.csizes1 : PRE_first_tail_x15_r0.cx1_1.mlx.deviceSizes = PRE_first_tail_x15_r0.cx0_1.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0.cwired1 : PRE_first_tail_x15_r0.cx1_1.mlx.wired = PRE_first_tail_x15_r0.cx0_1.mlx.wired
kernel_rfl PRE_first_tail_x15_r0.chost1 : PRE_first_tail_x15_r0.cx1_1.host = PRE_first_tail_x15_r0.cx0_1.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0.kd1`'s
kernel_rfl PRE_first_tail_x15_r0.ckn01 : PRE_first_tail_x15_r0.kd1.n0 = 2673458
kernel_rfl PRE_first_tail_x15_r0.ckn11 : PRE_first_tail_x15_r0.kd1.n1 = 2673472
kernel_rfl PRE_first_tail_x15_r0.ckheap1 : (PTrie.keysA PRE_first_tail_x15_r0.kd1.heap).all (fun x => Nat.ble 2673457 x) = true
kernel_rfl PRE_first_tail_x15_r0.ckpl1 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0.kd1.heap.get (2673457 + j) = nth? PRE_first_tail_x15_r0.pl1 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0.fja1 : Nat.ble 2673457 2673457 = true
kernel_rfl PRE_first_tail_x15_r0.fn1 : Nat.ble 14 14 = true
kernel_rfl PRE_first_tail_x15_r0.fjaD1 : Nat.ble 2673457 PRE_first_tail_x15_r0.kd1.n0 = true
kernel_rfl PRE_first_tail_x15_r0.fxn1 : Nat.ble 18155 PRE_first_tail_x15_r0.kd1.nh0 = true
kernel_rfl PRE_first_tail_x15_r0.fnn1 : Nat.ble 15235 PRE_first_tail_x15_r0.kd1.nn0 = true
kernel_rfl PRE_first_tail_x15_r0.fxb1 : Nat.ble 18155 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0.fheap1 : (PTrie.keysA PRE_first_tail_x15_r0.kd1.heap).all (Nat.ble (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0.fhnd1 : (PTrie.keysA PRE_first_tail_x15_r0.kd1.hnd).all (Nat.ble (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0.fnode1 : (PTrie.keysA PRE_first_tail_x15_r0.kd1.node).all (Nat.ble (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0.cfix1 : Conv.FixOld (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) PRE_first_tail_x15_r0.kappa1 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fja1) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fn1) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fjaD1) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fxn1) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fnn1) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fxb1) PRE_first_tail_x15_r0.fheap1 PRE_first_tail_x15_r0.fhnd1 PRE_first_tail_x15_r0.fnode1
kernel_rfl PRE_first_tail_x15_r0.fcxn1 : (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0.fcnn1 : (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0.fle01 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.next PRE_first_tail_x15_r0.cx0_1.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.nnext PRE_first_tail_x15_r0.cx0_1.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0.fnk1 : (PTrie.keysA PRE_first_tail_x15_r0.kd1.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0.f1A1 : PRE_first_tail_x15_r0.cx1_1.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.arrs (PRE_first_tail_x15_r0.cwS1.filterMap fun i => (PRE_first_tail_x15_r0.cx1_1.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.f1O1 : PRE_first_tail_x15_r0.cx1_1.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.objs (PRE_first_tail_x15_r0.cwS1.filterMap fun i => (PRE_first_tail_x15_r0.cx1_1.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.f1N1 : PRE_first_tail_x15_r0.cx1_1.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.nodes (PRE_first_tail_x15_r0.cnS1.filterMap fun i => (PRE_first_tail_x15_r0.cx1_1.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.f1I1 : PRE_first_tail_x15_r0.cx1_1.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.items (PRE_first_tail_x15_r0.ciS1.filterMap fun i => (PRE_first_tail_x15_r0.cx1_1.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.fbd1 : (PRE_first_tail_x15_r0.clo1 ++ PRE_first_tail_x15_r0.cln1 ++ PRE_first_tail_x15_r0.cli1 ++ PRE_first_tail_x15_r0.cwS1 ++ PRE_first_tail_x15_r0.cnS1 ++ PRE_first_tail_x15_r0.ciS1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0.fincW1 : PRE_first_tail_x15_r0.cwS1.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.next || PRE_first_tail_x15_r0.clo1.contains h) = true
kernel_rfl PRE_first_tail_x15_r0.fincI1 : PRE_first_tail_x15_r0.ciS1.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.nnext || PRE_first_tail_x15_r0.cli1.contains k) = true
kernel_rfl PRE_first_tail_x15_r0.fincN1 : PRE_first_tail_x15_r0.cnS1.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0.flnF1 : PRE_first_tail_x15_r0.cln1.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0.fh1 : PRE_first_tail_x15_r0.clo1.all (handleOK PRE_first_tail_x15_r0.kappa1 PRE_first_tail_x15_r0.P1.lo PRE_first_tail_x15_r0.cx0_1.mlx PRE_first_tail_x15_r0.cx1_1.mlx) = true
kernel_rfl PRE_first_tail_x15_r0.fo1 : PRE_first_tail_x15_r0.clo1.map (fun h => PRE_first_tail_x15_r0.cx1_1.mlx.objs.get (PRE_first_tail_x15_r0.kappa1.handle h)) = PRE_first_tail_x15_r0.clo1.map (fun h => (PRE_first_tail_x15_r0.cx0_1.mlx.objs.get h).map PRE_first_tail_x15_r0.kappa1.nobj)
kernel_rfl PRE_first_tail_x15_r0.fok1 : PRE_first_tail_x15_r0.clo1.all (objOK PRE_first_tail_x15_r0.kappa1 PRE_first_tail_x15_r0.P1.NL PRE_first_tail_x15_r0.cx0_1.mlx) = true
kernel_rfl PRE_first_tail_x15_r0.fnd1 : PRE_first_tail_x15_r0.cln1.all (nodeOKF PRE_first_tail_x15_r0.kappa1 PRE_first_tail_x15_r0.P1 PRE_first_tail_x15_r0.cx0_1.mlx PRE_first_tail_x15_r0.cx1_1.mlx) = true
kernel_rfl PRE_first_tail_x15_r0.fp1 : ((PRE_first_tail_x15_r0.cln1.filter (fullB PRE_first_tail_x15_r0.P1))).map (fun i => (PRE_first_tail_x15_r0.cx1_1.mlx.nodes.get (PRE_first_tail_x15_r0.kappa1.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0.cln1.filter (fullB PRE_first_tail_x15_r0.P1))).map (fun i => (PRE_first_tail_x15_r0.cx0_1.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0.kappa1.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0.fnordI1 : incrB PRE_first_tail_x15_r0.kd1.nodeF (List.range' 15235 0) = true
kernel_rfl PRE_first_tail_x15_r0.fnordK1 : (PTrie.keysA PRE_first_tail_x15_r0.kd1.node).all (fun k => Nat.ble 15235 k && Nat.blt k 15235) = true
kernel_rfl PRE_first_tail_x15_r0.fnordL1 : (PRE_first_tail_x15_r0.cln1.filter (Nat.ble PRE_first_tail_x15_r0.P1.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0.kd1.nodeF i) && (Nat.blt i 15235 || Nat.ble PRE_first_tail_x15_r0.kd1.nn0 i)) = true
theorem PRE_first_tail_x15_r0.fnord1 : (PRE_first_tail_x15_r0.cln1.filter (Nat.ble PRE_first_tail_x15_r0.P1.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0.kd1.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0.kd1.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0.kd1.nodeF j) (PRE_first_tail_x15_r0.kd1.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0.cnlow1 PRE_first_tail_x15_r0.cnn11 PRE_first_tail_x15_r0.fnordI1 PRE_first_tail_x15_r0.fnordK1 PRE_first_tail_x15_r0.fnordL1
kernel_rfl PRE_first_tail_x15_r0.fi1 : PRE_first_tail_x15_r0.cli1.all (pnB PRE_first_tail_x15_r0.cx0_1.mlx) = true
kernel_rfl PRE_first_tail_x15_r0.fii1 : PRE_first_tail_x15_r0.cli1.all (fun k => decide (PRE_first_tail_x15_r0.cx1_1.mlx.items.get (PRE_first_tail_x15_r0.kappa1.node k) = (PRE_first_tail_x15_r0.cx0_1.mlx.items.get k).map PRE_first_tail_x15_r0.kappa1.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0.cfoot1 (clean : Conv.NClean (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0.P1.NL) (cl : SSt (· < 15) PRE_first_tail_x15_r0.cx0_1.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0.P1 15 PRE_first_tail_x15_r0.kappa1 PRE_first_tail_x15_r0.kd1 PRE_first_tail_x15_r0.khinv1 PRE_first_tail_x15_r0.kninv1 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx PRE_first_tail_x15_r0.cx0_1.mlx PRE_first_tail_x15_r0.cx1_1.mlx (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) PRE_first_tail_x15_r0.clo1 PRE_first_tail_x15_r0.cln1 PRE_first_tail_x15_r0.cli1 PRE_first_tail_x15_r0.cwS1 PRE_first_tail_x15_r0.cnS1 PRE_first_tail_x15_r0.ciS1 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0.cnh01, PRE_first_tail_x15_r0.cnh11, PRE_first_tail_x15_r0.cnn01, PRE_first_tail_x15_r0.cnn11, PRE_first_tail_x15_r0.cplo1, PRE_first_tail_x15_r0.ccnt1, PRE_first_tail_x15_r0.cnband1, PRE_first_tail_x15_r0.chbelow1, PRE_first_tail_x15_r0.chren1, PRE_first_tail_x15_r0.cband1, PRE_first_tail_x15_r0.cnh1pos1, PRE_first_tail_x15_r0.cnren1, PRE_first_tail_x15_r0.cnlow1, PRE_first_tail_x15_r0.cabs0a1, PRE_first_tail_x15_r0.cabs0b1, PRE_first_tail_x15_r0.ctok11, PRE_first_tail_x15_r0.cpend1, PRE_first_tail_x15_r0.cerrh1, PRE_first_tail_x15_r0.cfiles1, PRE_first_tail_x15_r0.carch1, PRE_first_tail_x15_r0.csizes1, PRE_first_tail_x15_r0.cwired1, PRE_first_tail_x15_r0.cfix1, clean, PRE_first_tail_x15_r0.fcxn1, PRE_first_tail_x15_r0.fcnn1, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0.fle01, PRE_first_tail_x15_r0.fnk1, PRE_first_tail_x15_r0.ckA1, PRE_first_tail_x15_r0.cobjsK1, PRE_first_tail_x15_r0.cnodesK1, PRE_first_tail_x15_r0.citemsK1, PRE_first_tail_x15_r0.f1A1, PRE_first_tail_x15_r0.f1O1, PRE_first_tail_x15_r0.f1N1, PRE_first_tail_x15_r0.f1I1, PRE_first_tail_x15_r0.fbd1, PRE_first_tail_x15_r0.fincW1, PRE_first_tail_x15_r0.fincI1, PRE_first_tail_x15_r0.fincN1, PRE_first_tail_x15_r0.flnF1, PRE_first_tail_x15_r0.fh1, PRE_first_tail_x15_r0.fo1, PRE_first_tail_x15_r0.fok1, PRE_first_tail_x15_r0.fnd1, PRE_first_tail_x15_r0.fp1, PRE_first_tail_x15_r0.fnord1, PRE_first_tail_x15_r0.fi1, PRE_first_tail_x15_r0.fii1⟩
theorem PRE_first_tail_x15_r0.cnshift1 (clean : Conv.NClean (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0.P1.NL) (cl : SSt (· < 15) PRE_first_tail_x15_r0.cx0_1.mlx) : NShift PRE_first_tail_x15_r0.P1 15 PRE_first_tail_x15_r0.kappa1 PRE_first_tail_x15_r0.cx0_1 PRE_first_tail_x15_r0.cx1_1 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0.cfoot1 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0.chost1 (compact_a_eq PRE_first_tail_x15_r0.ckn01 PRE_first_tail_x15_r0.ckn11 PRE_first_tail_x15_r0.ckheap1 PRE_first_tail_x15_r0.ckpl1)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0.fxC_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0.s17.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0.krC_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0.s17.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0.ofxC_1 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0.s17.ffi) = some PRE_first_tail_x15_r0.fxC_1
kernel_rfl PRE_first_tail_x15_r0.okrC_1 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0.s17.ffi) = some PRE_first_tail_x15_r0.krC_1
noncomputable def PRE_first_tail_x15_r0.fx0_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0.s19.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0.kr0_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0.s19.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0.ofx0_1 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0.s19.ffi) = some PRE_first_tail_x15_r0.fx0_1
kernel_rfl PRE_first_tail_x15_r0.okr0_1 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0.s19.ffi) = some PRE_first_tail_x15_r0.kr0_1
noncomputable def PRE_first_tail_x15_r0.fx1_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0.s18.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0.kr1_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0.s18.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0.ofx1_1 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0.s18.ffi) = some PRE_first_tail_x15_r0.fx1_1
kernel_rfl PRE_first_tail_x15_r0.okr1_1 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0.s18.ffi) = some PRE_first_tail_x15_r0.kr1_1
kernel_rfl PRE_first_tail_x15_r0.ff01 : PRE_first_tail_x15_r0.fx0_1 = Stage.setAll PRE_first_tail_x15_r0.fxC_1 (PRE_first_tail_x15_r0.clo1.filterMap fun i => (PRE_first_tail_x15_r0.fx0_1.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.ff11 : PRE_first_tail_x15_r0.fx1_1 = Stage.setAll PRE_first_tail_x15_r0.fxC_1 (PRE_first_tail_x15_r0.cwS1.filterMap fun i => (PRE_first_tail_x15_r0.fx1_1.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.ffck1 : freedLB PRE_first_tail_x15_r0.kappa1 PRE_first_tail_x15_r0.cx0_1.mlx PRE_first_tail_x15_r0.fx0_1 PRE_first_tail_x15_r0.fx1_1 PRE_first_tail_x15_r0.clo1 = true
kernel_rfl PRE_first_tail_x15_r0.fkf01 : PRE_first_tail_x15_r0.kr0_1.flags = Stage.setAll PRE_first_tail_x15_r0.krC_1.flags (PRE_first_tail_x15_r0.clo1.filterMap fun i => (PRE_first_tail_x15_r0.kr0_1.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.fkt01 : PRE_first_tail_x15_r0.kr0_1.targs = Stage.setAll PRE_first_tail_x15_r0.krC_1.targs (PRE_first_tail_x15_r0.clo1.filterMap fun i => (PRE_first_tail_x15_r0.kr0_1.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.fkf11 : PRE_first_tail_x15_r0.kr1_1.flags = Stage.setAll PRE_first_tail_x15_r0.krC_1.flags (PRE_first_tail_x15_r0.cwS1.filterMap fun i => (PRE_first_tail_x15_r0.kr1_1.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.fkt11 : PRE_first_tail_x15_r0.kr1_1.targs = Stage.setAll PRE_first_tail_x15_r0.krC_1.targs (PRE_first_tail_x15_r0.cwS1.filterMap fun i => (PRE_first_tail_x15_r0.kr1_1.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.fkck1 : krecLB PRE_first_tail_x15_r0.kappa1 15 PRE_first_tail_x15_r0.cx0_1.mlx PRE_first_tail_x15_r0.kr0_1 PRE_first_tail_x15_r0.kr1_1 PRE_first_tail_x15_r0.clo1 = true
kernel_rfl PRE_first_tail_x15_r0.fkn1 : Nat.ble 14 15 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0.cbridge1 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0.s18.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0.s19.ffi
kernel_rfl PRE_first_tail_x15_r0.cpendR1 : pendRegB PRE_first_tail_x15_r0.kappa1 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0.cpendLe1 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s18.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0.cshift1 (clean : Conv.NClean (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0.P1.NL) (cl : SSt (· < 15) PRE_first_tail_x15_r0.cx0_1.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0.fxC_1.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0.krC_1.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0.krC_1.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0.krC_1.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0.P1 15 PRE_first_tail_x15_r0.kappa1 PRE_first_tail_x15_r0.s19.ffi PRE_first_tail_x15_r0.s18.ffi :=
  ⟨PRE_first_tail_x15_r0.cnshift1 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0.cqueue1, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0.ctokSupp1 t ht),
    PRE_first_tail_x15_r0.cbridge1,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0.s19.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0.s18.ffi) (PRE_first_tail_x15_r0.cfoot1 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0.ofx0_1 PRE_first_tail_x15_r0.ofx1_1 hobjC PRE_first_tail_x15_r0.ff01 PRE_first_tail_x15_r0.ff11 PRE_first_tail_x15_r0.ffck1,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0.s19.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0.s18.ffi) (PRE_first_tail_x15_r0.cfoot1 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0.okr0_1 PRE_first_tail_x15_r0.okr1_1 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fkn1) hfC htC hclC
      PRE_first_tail_x15_r0.fkf01 PRE_first_tail_x15_r0.fkt01 PRE_first_tail_x15_r0.fkf11 PRE_first_tail_x15_r0.fkt11 PRE_first_tail_x15_r0.fkck1,
    pendReg_of rfl PRE_first_tail_x15_r0.cnh01 PRE_first_tail_x15_r0.cnh11 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.cpendLe1) PRE_first_tail_x15_r0.cpendR1⟩

end Host.Load.Run.Tpl
