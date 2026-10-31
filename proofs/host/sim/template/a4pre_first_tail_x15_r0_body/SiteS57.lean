import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl57
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 57 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc57 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P57 : LoadP := PRE_first_tail_x15_r0_body.Pc57.raise 16430
kernel_rfl PRE_first_tail_x15_r0_body.craise57 : Nat.ble PRE_first_tail_x15_r0_body.Pc57.N0 16430 = true
theorem PRE_first_tail_x15_r0_body.raised57 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc57 PRE_first_tail_x15_r0_body.P57 :=
  .inr ⟨16430, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise57, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_57 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_57 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s563.ffi)
def PRE_first_tail_x15_r0_body.khinv57 : PTrie Nat := Stage.setAll PTrie.nil [(19339, 19337), (19340, 19338), (19342, 19339), (19341, 19340)]
def PRE_first_tail_x15_r0_body.kninv57 : PTrie Nat := Stage.setAll PTrie.nil [(16424, 16424), (16425, 16425), (16426, 16426), (16427, 16427), (16428, 16428), (16429, 16429)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS57 : List Nat := [19337, 19338, 19339, 19340, 19341, 19342]
def PRE_first_tail_x15_r0_body.cnS57 : List Nat := List.range' 16424 6
def PRE_first_tail_x15_r0_body.ciS57 : List Nat := [] ++ List.range' 16424 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh057 : PRE_first_tail_x15_r0_body.kd57.nh0 = PRE_first_tail_x15_r0_body.cx0_57.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh157 : PRE_first_tail_x15_r0_body.kd57.nh1 = PRE_first_tail_x15_r0_body.cx1_57.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn057 : PRE_first_tail_x15_r0_body.kd57.nn0 = PRE_first_tail_x15_r0_body.cx0_57.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn157 : PRE_first_tail_x15_r0_body.kd57.nn1 = PRE_first_tail_x15_r0_body.cx1_57.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo57 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P57.lo && Nat.ble PRE_first_tail_x15_r0_body.P57.lo PRE_first_tail_x15_r0_body.cx0_57.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P57.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P57.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt57 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_57.mlx.next PRE_first_tail_x15_r0_body.cx1_57.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_57.mlx.nnext PRE_first_tail_x15_r0_body.cx1_57.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband57 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P57.NL && Nat.ble PRE_first_tail_x15_r0_body.P57.NL PRE_first_tail_x15_r0_body.P57.N0 && Nat.ble PRE_first_tail_x15_r0_body.P57.N0 PRE_first_tail_x15_r0_body.cx0_57.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow57 : PRE_first_tail_x15_r0_body.kd57.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren57 : checkRenG PRE_first_tail_x15_r0_body.kd57.hnd PRE_first_tail_x15_r0_body.khinv57 (phB PRE_first_tail_x15_r0_body.cx0_57.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband57 : PRE_first_tail_x15_r0_body.kd57.checkBand PRE_first_tail_x15_r0_body.P57.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos57 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd57.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren57 : checkRenG PRE_first_tail_x15_r0_body.kd57.node PRE_first_tail_x15_r0_body.kninv57 (pnB PRE_first_tail_x15_r0_body.cx0_57.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P57.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd57.nodeF j) PRE_first_tail_x15_r0_body.cx1_57.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a57 : PRE_first_tail_x15_r0_body.cx0_57.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b57 : PRE_first_tail_x15_r0_body.cx0_57.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok157 : PRE_first_tail_x15_r0_body.cx1_57.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.pending = PRE_first_tail_x15_r0_body.cx0_57.mlx.pending.map PRE_first_tail_x15_r0_body.kappa57.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.errh = PRE_first_tail_x15_r0_body.cx0_57.mlx.errh.map PRE_first_tail_x15_r0_body.kappa57.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.files = PRE_first_tail_x15_r0_body.cx0_57.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.arch = PRE_first_tail_x15_r0_body.cx0_57.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_57.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.wired = PRE_first_tail_x15_r0_body.cx0_57.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost57 : PRE_first_tail_x15_r0_body.cx1_57.host = PRE_first_tail_x15_r0_body.cx0_57.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd57`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn057 : PRE_first_tail_x15_r0_body.kd57.n0 = 2720183
kernel_rfl PRE_first_tail_x15_r0_body.ckn157 : PRE_first_tail_x15_r0_body.kd57.n1 = 2720533
kernel_rfl PRE_first_tail_x15_r0_body.ckheap57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.heap).all (fun x => Nat.ble 2720168 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl57 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd57.heap.get (2720168 + j) = nth? PRE_first_tail_x15_r0_body.pl57 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja57 : Nat.ble 2720168 2720168 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn57 : Nat.ble 2526 2526 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD57 : Nat.ble 2720168 PRE_first_tail_x15_r0_body.kd57.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn57 : Nat.ble 19337 PRE_first_tail_x15_r0_body.kd57.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn57 : Nat.ble 16424 PRE_first_tail_x15_r0_body.kd57.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb57 : Nat.ble 19337 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.heap).all (Nat.ble (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.hnd).all (Nat.ble (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.node).all (Nat.ble (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix57 : Conv.FixOld (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa57 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja57) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn57) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD57) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn57) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn57) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb57) PRE_first_tail_x15_r0_body.fheap57 PRE_first_tail_x15_r0_body.fhnd57 PRE_first_tail_x15_r0_body.fnode57
kernel_rfl PRE_first_tail_x15_r0_body.fcxn57 : (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn57 : (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle057 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_57.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_57.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS57.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_57.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS57.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_57.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS57.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_57.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS57.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_57.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd57 : (PRE_first_tail_x15_r0_body.clo57 ++ PRE_first_tail_x15_r0_body.cln57 ++ PRE_first_tail_x15_r0_body.cli57 ++ PRE_first_tail_x15_r0_body.cwS57 ++ PRE_first_tail_x15_r0_body.cnS57 ++ PRE_first_tail_x15_r0_body.ciS57).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW57 : PRE_first_tail_x15_r0_body.cwS57.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo57.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI57 : PRE_first_tail_x15_r0_body.ciS57.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli57.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN57 : PRE_first_tail_x15_r0_body.cnS57.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF57 : PRE_first_tail_x15_r0_body.cln57.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh57 : PRE_first_tail_x15_r0_body.clo57.all (handleOK PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.P57.lo PRE_first_tail_x15_r0_body.cx0_57.mlx PRE_first_tail_x15_r0_body.cx1_57.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo57 : PRE_first_tail_x15_r0_body.clo57.map (fun h => PRE_first_tail_x15_r0_body.cx1_57.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa57.handle h)) = PRE_first_tail_x15_r0_body.clo57.map (fun h => (PRE_first_tail_x15_r0_body.cx0_57.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa57.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok57 : PRE_first_tail_x15_r0_body.clo57.all (objOK PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.P57.NL PRE_first_tail_x15_r0_body.cx0_57.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd57 : PRE_first_tail_x15_r0_body.cln57.all (nodeOKF PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.P57 PRE_first_tail_x15_r0_body.cx0_57.mlx PRE_first_tail_x15_r0_body.cx1_57.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp57 : ((PRE_first_tail_x15_r0_body.cln57.filter (fullB PRE_first_tail_x15_r0_body.P57))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_57.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa57.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln57.filter (fullB PRE_first_tail_x15_r0_body.P57))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_57.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa57.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI57 : incrB PRE_first_tail_x15_r0_body.kd57.nodeF (List.range' 16424 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.node).all (fun k => Nat.ble 16424 k && Nat.blt k 16430) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL57 : (PRE_first_tail_x15_r0_body.cln57.filter (Nat.ble PRE_first_tail_x15_r0_body.P57.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd57.nodeF i) && (Nat.blt i 16430 || Nat.ble PRE_first_tail_x15_r0_body.kd57.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord57 : (PRE_first_tail_x15_r0_body.cln57.filter (Nat.ble PRE_first_tail_x15_r0_body.P57.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd57.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd57.nodeF j) (PRE_first_tail_x15_r0_body.kd57.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow57 PRE_first_tail_x15_r0_body.cnn157 PRE_first_tail_x15_r0_body.fnordI57 PRE_first_tail_x15_r0_body.fnordK57 PRE_first_tail_x15_r0_body.fnordL57
kernel_rfl PRE_first_tail_x15_r0_body.fi57 : PRE_first_tail_x15_r0_body.cli57.all (pnB PRE_first_tail_x15_r0_body.cx0_57.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii57 : PRE_first_tail_x15_r0_body.cli57.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_57.mlx.items.get (PRE_first_tail_x15_r0_body.kappa57.node k) = (PRE_first_tail_x15_r0_body.cx0_57.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa57.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot57 (clean : Conv.NClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P57.NL) (cl : SSt (· < 2535) PRE_first_tail_x15_r0_body.cx0_57.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P57 2535 PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.kd57 PRE_first_tail_x15_r0_body.khinv57 PRE_first_tail_x15_r0_body.kninv57 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx PRE_first_tail_x15_r0_body.cx0_57.mlx PRE_first_tail_x15_r0_body.cx1_57.mlx (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo57 PRE_first_tail_x15_r0_body.cln57 PRE_first_tail_x15_r0_body.cli57 PRE_first_tail_x15_r0_body.cwS57 PRE_first_tail_x15_r0_body.cnS57 PRE_first_tail_x15_r0_body.ciS57 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh057, PRE_first_tail_x15_r0_body.cnh157, PRE_first_tail_x15_r0_body.cnn057, PRE_first_tail_x15_r0_body.cnn157, PRE_first_tail_x15_r0_body.cplo57, PRE_first_tail_x15_r0_body.ccnt57, PRE_first_tail_x15_r0_body.cnband57, PRE_first_tail_x15_r0_body.chbelow57, PRE_first_tail_x15_r0_body.chren57, PRE_first_tail_x15_r0_body.cband57, PRE_first_tail_x15_r0_body.cnh1pos57, PRE_first_tail_x15_r0_body.cnren57, PRE_first_tail_x15_r0_body.cnlow57, PRE_first_tail_x15_r0_body.cabs0a57, PRE_first_tail_x15_r0_body.cabs0b57, PRE_first_tail_x15_r0_body.ctok157, PRE_first_tail_x15_r0_body.cpend57, PRE_first_tail_x15_r0_body.cerrh57, PRE_first_tail_x15_r0_body.cfiles57, PRE_first_tail_x15_r0_body.carch57, PRE_first_tail_x15_r0_body.csizes57, PRE_first_tail_x15_r0_body.cwired57, PRE_first_tail_x15_r0_body.cfix57, clean, PRE_first_tail_x15_r0_body.fcxn57, PRE_first_tail_x15_r0_body.fcnn57, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle057, PRE_first_tail_x15_r0_body.fnk57, PRE_first_tail_x15_r0_body.ckA57, PRE_first_tail_x15_r0_body.cobjsK57, PRE_first_tail_x15_r0_body.cnodesK57, PRE_first_tail_x15_r0_body.citemsK57, PRE_first_tail_x15_r0_body.f1A57, PRE_first_tail_x15_r0_body.f1O57, PRE_first_tail_x15_r0_body.f1N57, PRE_first_tail_x15_r0_body.f1I57, PRE_first_tail_x15_r0_body.fbd57, PRE_first_tail_x15_r0_body.fincW57, PRE_first_tail_x15_r0_body.fincI57, PRE_first_tail_x15_r0_body.fincN57, PRE_first_tail_x15_r0_body.flnF57, PRE_first_tail_x15_r0_body.fh57, PRE_first_tail_x15_r0_body.fo57, PRE_first_tail_x15_r0_body.fok57, PRE_first_tail_x15_r0_body.fnd57, PRE_first_tail_x15_r0_body.fp57, PRE_first_tail_x15_r0_body.fnord57, PRE_first_tail_x15_r0_body.fi57, PRE_first_tail_x15_r0_body.fii57⟩
theorem PRE_first_tail_x15_r0_body.cnshift57 (clean : Conv.NClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P57.NL) (cl : SSt (· < 2535) PRE_first_tail_x15_r0_body.cx0_57.mlx) : NShift PRE_first_tail_x15_r0_body.P57 2535 PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.cx0_57 PRE_first_tail_x15_r0_body.cx1_57 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot57 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost57 (compact_a_eq PRE_first_tail_x15_r0_body.ckn057 PRE_first_tail_x15_r0_body.ckn157 PRE_first_tail_x15_r0_body.ckheap57 PRE_first_tail_x15_r0_body.ckpl57)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_57 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s562.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_57 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s562.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_57 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s562.ffi) = some PRE_first_tail_x15_r0_body.fxC_57
kernel_rfl PRE_first_tail_x15_r0_body.okrC_57 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s562.ffi) = some PRE_first_tail_x15_r0_body.krC_57
noncomputable def PRE_first_tail_x15_r0_body.fx0_57 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s564.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_57 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s564.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_57 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s564.ffi) = some PRE_first_tail_x15_r0_body.fx0_57
kernel_rfl PRE_first_tail_x15_r0_body.okr0_57 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s564.ffi) = some PRE_first_tail_x15_r0_body.kr0_57
noncomputable def PRE_first_tail_x15_r0_body.fx1_57 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s563.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_57 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s563.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_57 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s563.ffi) = some PRE_first_tail_x15_r0_body.fx1_57
kernel_rfl PRE_first_tail_x15_r0_body.okr1_57 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s563.ffi) = some PRE_first_tail_x15_r0_body.kr1_57
kernel_rfl PRE_first_tail_x15_r0_body.ff057 : PRE_first_tail_x15_r0_body.fx0_57 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_57 (PRE_first_tail_x15_r0_body.clo57.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_57.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff157 : PRE_first_tail_x15_r0_body.fx1_57 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_57 (PRE_first_tail_x15_r0_body.cwS57.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_57.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck57 : freedLB PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.cx0_57.mlx PRE_first_tail_x15_r0_body.fx0_57 PRE_first_tail_x15_r0_body.fx1_57 PRE_first_tail_x15_r0_body.clo57 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf057 : PRE_first_tail_x15_r0_body.kr0_57.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_57.flags (PRE_first_tail_x15_r0_body.clo57.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_57.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt057 : PRE_first_tail_x15_r0_body.kr0_57.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_57.targs (PRE_first_tail_x15_r0_body.clo57.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_57.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf157 : PRE_first_tail_x15_r0_body.kr1_57.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_57.flags (PRE_first_tail_x15_r0_body.cwS57.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_57.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt157 : PRE_first_tail_x15_r0_body.kr1_57.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_57.targs (PRE_first_tail_x15_r0_body.cwS57.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_57.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck57 : krecLB PRE_first_tail_x15_r0_body.kappa57 2535 PRE_first_tail_x15_r0_body.cx0_57.mlx PRE_first_tail_x15_r0_body.kr0_57 PRE_first_tail_x15_r0_body.kr1_57 PRE_first_tail_x15_r0_body.clo57 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn57 : Nat.ble 2526 2535 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge57 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s563.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s564.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR57 : pendRegB PRE_first_tail_x15_r0_body.kappa57 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe57 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s563.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift57 (clean : Conv.NClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P57.NL) (cl : SSt (· < 2535) PRE_first_tail_x15_r0_body.cx0_57.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_57.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_57.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_57.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_57.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P57 2535 PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.s564.ffi PRE_first_tail_x15_r0_body.s563.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift57 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue57, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp57 t ht),
    PRE_first_tail_x15_r0_body.cbridge57,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s564.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s563.ffi) (PRE_first_tail_x15_r0_body.cfoot57 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_57 PRE_first_tail_x15_r0_body.ofx1_57 hobjC PRE_first_tail_x15_r0_body.ff057 PRE_first_tail_x15_r0_body.ff157 PRE_first_tail_x15_r0_body.ffck57,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s564.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s563.ffi) (PRE_first_tail_x15_r0_body.cfoot57 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_57 PRE_first_tail_x15_r0_body.okr1_57 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn57) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf057 PRE_first_tail_x15_r0_body.fkt057 PRE_first_tail_x15_r0_body.fkf157 PRE_first_tail_x15_r0_body.fkt157 PRE_first_tail_x15_r0_body.fkck57,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh057 PRE_first_tail_x15_r0_body.cnh157 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe57) PRE_first_tail_x15_r0_body.cpendR57⟩

end Host.Load.Run.Tpl
