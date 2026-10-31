import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl141
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 141 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc141 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P141 : LoadP := PRE_first_tail_x15_r0_body.Pc141.raise 18089
kernel_rfl PRE_first_tail_x15_r0_body.craise141 : Nat.ble PRE_first_tail_x15_r0_body.Pc141.N0 18089 = true
theorem PRE_first_tail_x15_r0_body.raised141 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc141 PRE_first_tail_x15_r0_body.P141 :=
  .inr ⟨18089, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise141, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_141 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_141 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1368.ffi)
def PRE_first_tail_x15_r0_body.khinv141 : PTrie Nat := Stage.setAll PTrie.nil [(20991, 20989), (20992, 20990), (20994, 20991), (20993, 20992)]
def PRE_first_tail_x15_r0_body.kninv141 : PTrie Nat := Stage.setAll PTrie.nil [(18083, 18083), (18084, 18084), (18085, 18085), (18086, 18086), (18087, 18087), (18088, 18088)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS141 : List Nat := [20989, 20990, 20991, 20992, 20993, 20994]
def PRE_first_tail_x15_r0_body.cnS141 : List Nat := List.range' 18083 6
def PRE_first_tail_x15_r0_body.ciS141 : List Nat := [] ++ List.range' 18083 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0141 : PRE_first_tail_x15_r0_body.kd141.nh0 = PRE_first_tail_x15_r0_body.cx0_141.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1141 : PRE_first_tail_x15_r0_body.kd141.nh1 = PRE_first_tail_x15_r0_body.cx1_141.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0141 : PRE_first_tail_x15_r0_body.kd141.nn0 = PRE_first_tail_x15_r0_body.cx0_141.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1141 : PRE_first_tail_x15_r0_body.kd141.nn1 = PRE_first_tail_x15_r0_body.cx1_141.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo141 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P141.lo && Nat.ble PRE_first_tail_x15_r0_body.P141.lo PRE_first_tail_x15_r0_body.cx0_141.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P141.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P141.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt141 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_141.mlx.next PRE_first_tail_x15_r0_body.cx1_141.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_141.mlx.nnext PRE_first_tail_x15_r0_body.cx1_141.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband141 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P141.NL && Nat.ble PRE_first_tail_x15_r0_body.P141.NL PRE_first_tail_x15_r0_body.P141.N0 && Nat.ble PRE_first_tail_x15_r0_body.P141.N0 PRE_first_tail_x15_r0_body.cx0_141.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow141 : PRE_first_tail_x15_r0_body.kd141.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren141 : checkRenG PRE_first_tail_x15_r0_body.kd141.hnd PRE_first_tail_x15_r0_body.khinv141 (phB PRE_first_tail_x15_r0_body.cx0_141.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband141 : PRE_first_tail_x15_r0_body.kd141.checkBand PRE_first_tail_x15_r0_body.P141.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos141 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd141.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren141 : checkRenG PRE_first_tail_x15_r0_body.kd141.node PRE_first_tail_x15_r0_body.kninv141 (pnB PRE_first_tail_x15_r0_body.cx0_141.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P141.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd141.nodeF j) PRE_first_tail_x15_r0_body.cx1_141.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a141 : PRE_first_tail_x15_r0_body.cx0_141.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b141 : PRE_first_tail_x15_r0_body.cx0_141.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.pending = PRE_first_tail_x15_r0_body.cx0_141.mlx.pending.map PRE_first_tail_x15_r0_body.kappa141.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.errh = PRE_first_tail_x15_r0_body.cx0_141.mlx.errh.map PRE_first_tail_x15_r0_body.kappa141.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.files = PRE_first_tail_x15_r0_body.cx0_141.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.arch = PRE_first_tail_x15_r0_body.cx0_141.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_141.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.wired = PRE_first_tail_x15_r0_body.cx0_141.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost141 : PRE_first_tail_x15_r0_body.cx1_141.host = PRE_first_tail_x15_r0_body.cx0_141.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd141`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0141 : PRE_first_tail_x15_r0_body.kd141.n0 = 2786091
kernel_rfl PRE_first_tail_x15_r0_body.ckn1141 : PRE_first_tail_x15_r0_body.kd141.n1 = 2786441
kernel_rfl PRE_first_tail_x15_r0_body.ckheap141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.heap).all (fun x => Nat.ble 2786076 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl141 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd141.heap.get (2786076 + j) = nth? PRE_first_tail_x15_r0_body.pl141 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja141 : Nat.ble 2786076 2786076 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn141 : Nat.ble 6117 6117 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD141 : Nat.ble 2786076 PRE_first_tail_x15_r0_body.kd141.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn141 : Nat.ble 20989 PRE_first_tail_x15_r0_body.kd141.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn141 : Nat.ble 18083 PRE_first_tail_x15_r0_body.kd141.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb141 : Nat.ble 20989 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.heap).all (Nat.ble (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.hnd).all (Nat.ble (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.node).all (Nat.ble (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix141 : Conv.FixOld (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa141 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja141) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn141) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD141) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn141) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn141) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb141) PRE_first_tail_x15_r0_body.fheap141 PRE_first_tail_x15_r0_body.fhnd141 PRE_first_tail_x15_r0_body.fnode141
kernel_rfl PRE_first_tail_x15_r0_body.fcxn141 : (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn141 : (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0141 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_141.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_141.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS141.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_141.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS141.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_141.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS141.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_141.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS141.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_141.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd141 : (PRE_first_tail_x15_r0_body.clo141 ++ PRE_first_tail_x15_r0_body.cln141 ++ PRE_first_tail_x15_r0_body.cli141 ++ PRE_first_tail_x15_r0_body.cwS141 ++ PRE_first_tail_x15_r0_body.cnS141 ++ PRE_first_tail_x15_r0_body.ciS141).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW141 : PRE_first_tail_x15_r0_body.cwS141.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo141.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI141 : PRE_first_tail_x15_r0_body.ciS141.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli141.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN141 : PRE_first_tail_x15_r0_body.cnS141.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF141 : PRE_first_tail_x15_r0_body.cln141.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh141 : PRE_first_tail_x15_r0_body.clo141.all (handleOK PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.P141.lo PRE_first_tail_x15_r0_body.cx0_141.mlx PRE_first_tail_x15_r0_body.cx1_141.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo141 : PRE_first_tail_x15_r0_body.clo141.map (fun h => PRE_first_tail_x15_r0_body.cx1_141.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa141.handle h)) = PRE_first_tail_x15_r0_body.clo141.map (fun h => (PRE_first_tail_x15_r0_body.cx0_141.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa141.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok141 : PRE_first_tail_x15_r0_body.clo141.all (objOK PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.P141.NL PRE_first_tail_x15_r0_body.cx0_141.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd141 : PRE_first_tail_x15_r0_body.cln141.all (nodeOKF PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.P141 PRE_first_tail_x15_r0_body.cx0_141.mlx PRE_first_tail_x15_r0_body.cx1_141.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp141 : ((PRE_first_tail_x15_r0_body.cln141.filter (fullB PRE_first_tail_x15_r0_body.P141))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_141.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa141.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln141.filter (fullB PRE_first_tail_x15_r0_body.P141))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_141.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa141.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI141 : incrB PRE_first_tail_x15_r0_body.kd141.nodeF (List.range' 18083 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.node).all (fun k => Nat.ble 18083 k && Nat.blt k 18089) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL141 : (PRE_first_tail_x15_r0_body.cln141.filter (Nat.ble PRE_first_tail_x15_r0_body.P141.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd141.nodeF i) && (Nat.blt i 18089 || Nat.ble PRE_first_tail_x15_r0_body.kd141.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord141 : (PRE_first_tail_x15_r0_body.cln141.filter (Nat.ble PRE_first_tail_x15_r0_body.P141.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd141.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd141.nodeF j) (PRE_first_tail_x15_r0_body.kd141.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow141 PRE_first_tail_x15_r0_body.cnn1141 PRE_first_tail_x15_r0_body.fnordI141 PRE_first_tail_x15_r0_body.fnordK141 PRE_first_tail_x15_r0_body.fnordL141
kernel_rfl PRE_first_tail_x15_r0_body.fi141 : PRE_first_tail_x15_r0_body.cli141.all (pnB PRE_first_tail_x15_r0_body.cx0_141.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii141 : PRE_first_tail_x15_r0_body.cli141.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_141.mlx.items.get (PRE_first_tail_x15_r0_body.kappa141.node k) = (PRE_first_tail_x15_r0_body.cx0_141.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa141.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot141 (clean : Conv.NClean (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P141.NL) (cl : SSt (· < 6126) PRE_first_tail_x15_r0_body.cx0_141.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P141 6126 PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.kd141 PRE_first_tail_x15_r0_body.khinv141 PRE_first_tail_x15_r0_body.kninv141 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx PRE_first_tail_x15_r0_body.cx0_141.mlx PRE_first_tail_x15_r0_body.cx1_141.mlx (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo141 PRE_first_tail_x15_r0_body.cln141 PRE_first_tail_x15_r0_body.cli141 PRE_first_tail_x15_r0_body.cwS141 PRE_first_tail_x15_r0_body.cnS141 PRE_first_tail_x15_r0_body.ciS141 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0141, PRE_first_tail_x15_r0_body.cnh1141, PRE_first_tail_x15_r0_body.cnn0141, PRE_first_tail_x15_r0_body.cnn1141, PRE_first_tail_x15_r0_body.cplo141, PRE_first_tail_x15_r0_body.ccnt141, PRE_first_tail_x15_r0_body.cnband141, PRE_first_tail_x15_r0_body.chbelow141, PRE_first_tail_x15_r0_body.chren141, PRE_first_tail_x15_r0_body.cband141, PRE_first_tail_x15_r0_body.cnh1pos141, PRE_first_tail_x15_r0_body.cnren141, PRE_first_tail_x15_r0_body.cnlow141, PRE_first_tail_x15_r0_body.cabs0a141, PRE_first_tail_x15_r0_body.cabs0b141, PRE_first_tail_x15_r0_body.ctok1141, PRE_first_tail_x15_r0_body.cpend141, PRE_first_tail_x15_r0_body.cerrh141, PRE_first_tail_x15_r0_body.cfiles141, PRE_first_tail_x15_r0_body.carch141, PRE_first_tail_x15_r0_body.csizes141, PRE_first_tail_x15_r0_body.cwired141, PRE_first_tail_x15_r0_body.cfix141, clean, PRE_first_tail_x15_r0_body.fcxn141, PRE_first_tail_x15_r0_body.fcnn141, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0141, PRE_first_tail_x15_r0_body.fnk141, PRE_first_tail_x15_r0_body.ckA141, PRE_first_tail_x15_r0_body.cobjsK141, PRE_first_tail_x15_r0_body.cnodesK141, PRE_first_tail_x15_r0_body.citemsK141, PRE_first_tail_x15_r0_body.f1A141, PRE_first_tail_x15_r0_body.f1O141, PRE_first_tail_x15_r0_body.f1N141, PRE_first_tail_x15_r0_body.f1I141, PRE_first_tail_x15_r0_body.fbd141, PRE_first_tail_x15_r0_body.fincW141, PRE_first_tail_x15_r0_body.fincI141, PRE_first_tail_x15_r0_body.fincN141, PRE_first_tail_x15_r0_body.flnF141, PRE_first_tail_x15_r0_body.fh141, PRE_first_tail_x15_r0_body.fo141, PRE_first_tail_x15_r0_body.fok141, PRE_first_tail_x15_r0_body.fnd141, PRE_first_tail_x15_r0_body.fp141, PRE_first_tail_x15_r0_body.fnord141, PRE_first_tail_x15_r0_body.fi141, PRE_first_tail_x15_r0_body.fii141⟩
theorem PRE_first_tail_x15_r0_body.cnshift141 (clean : Conv.NClean (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P141.NL) (cl : SSt (· < 6126) PRE_first_tail_x15_r0_body.cx0_141.mlx) : NShift PRE_first_tail_x15_r0_body.P141 6126 PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.cx0_141 PRE_first_tail_x15_r0_body.cx1_141 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot141 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost141 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0141 PRE_first_tail_x15_r0_body.ckn1141 PRE_first_tail_x15_r0_body.ckheap141 PRE_first_tail_x15_r0_body.ckpl141)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_141 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1367.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_141 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1367.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_141 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1367.ffi) = some PRE_first_tail_x15_r0_body.fxC_141
kernel_rfl PRE_first_tail_x15_r0_body.okrC_141 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1367.ffi) = some PRE_first_tail_x15_r0_body.krC_141
noncomputable def PRE_first_tail_x15_r0_body.fx0_141 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1369.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_141 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1369.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_141 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1369.ffi) = some PRE_first_tail_x15_r0_body.fx0_141
kernel_rfl PRE_first_tail_x15_r0_body.okr0_141 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1369.ffi) = some PRE_first_tail_x15_r0_body.kr0_141
noncomputable def PRE_first_tail_x15_r0_body.fx1_141 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1368.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_141 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1368.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_141 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1368.ffi) = some PRE_first_tail_x15_r0_body.fx1_141
kernel_rfl PRE_first_tail_x15_r0_body.okr1_141 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1368.ffi) = some PRE_first_tail_x15_r0_body.kr1_141
kernel_rfl PRE_first_tail_x15_r0_body.ff0141 : PRE_first_tail_x15_r0_body.fx0_141 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_141 (PRE_first_tail_x15_r0_body.clo141.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_141.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1141 : PRE_first_tail_x15_r0_body.fx1_141 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_141 (PRE_first_tail_x15_r0_body.cwS141.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_141.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck141 : freedLB PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.cx0_141.mlx PRE_first_tail_x15_r0_body.fx0_141 PRE_first_tail_x15_r0_body.fx1_141 PRE_first_tail_x15_r0_body.clo141 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0141 : PRE_first_tail_x15_r0_body.kr0_141.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_141.flags (PRE_first_tail_x15_r0_body.clo141.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_141.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0141 : PRE_first_tail_x15_r0_body.kr0_141.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_141.targs (PRE_first_tail_x15_r0_body.clo141.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_141.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1141 : PRE_first_tail_x15_r0_body.kr1_141.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_141.flags (PRE_first_tail_x15_r0_body.cwS141.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_141.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1141 : PRE_first_tail_x15_r0_body.kr1_141.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_141.targs (PRE_first_tail_x15_r0_body.cwS141.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_141.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck141 : krecLB PRE_first_tail_x15_r0_body.kappa141 6126 PRE_first_tail_x15_r0_body.cx0_141.mlx PRE_first_tail_x15_r0_body.kr0_141 PRE_first_tail_x15_r0_body.kr1_141 PRE_first_tail_x15_r0_body.clo141 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn141 : Nat.ble 6117 6126 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge141 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1368.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1369.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR141 : pendRegB PRE_first_tail_x15_r0_body.kappa141 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe141 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1368.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift141 (clean : Conv.NClean (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P141.NL) (cl : SSt (· < 6126) PRE_first_tail_x15_r0_body.cx0_141.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_141.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_141.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_141.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_141.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P141 6126 PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.s1369.ffi PRE_first_tail_x15_r0_body.s1368.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift141 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue141, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp141 t ht),
    PRE_first_tail_x15_r0_body.cbridge141,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1369.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1368.ffi) (PRE_first_tail_x15_r0_body.cfoot141 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_141 PRE_first_tail_x15_r0_body.ofx1_141 hobjC PRE_first_tail_x15_r0_body.ff0141 PRE_first_tail_x15_r0_body.ff1141 PRE_first_tail_x15_r0_body.ffck141,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1369.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1368.ffi) (PRE_first_tail_x15_r0_body.cfoot141 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_141 PRE_first_tail_x15_r0_body.okr1_141 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn141) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0141 PRE_first_tail_x15_r0_body.fkt0141 PRE_first_tail_x15_r0_body.fkf1141 PRE_first_tail_x15_r0_body.fkt1141 PRE_first_tail_x15_r0_body.fkck141,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0141 PRE_first_tail_x15_r0_body.cnh1141 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe141) PRE_first_tail_x15_r0_body.cpendR141⟩

end Host.Load.Run.Tpl
