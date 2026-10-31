import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl161
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 161 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc161 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P161 : LoadP := PRE_first_tail_x15_r0_body.Pc161.raise 18466
kernel_rfl PRE_first_tail_x15_r0_body.craise161 : Nat.ble PRE_first_tail_x15_r0_body.Pc161.N0 18466 = true
theorem PRE_first_tail_x15_r0_body.raised161 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc161 PRE_first_tail_x15_r0_body.P161 :=
  .inr ⟨18466, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise161, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_161 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1419.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_161 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1418.ffi)
def PRE_first_tail_x15_r0_body.khinv161 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv161 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS161 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS161 : List Nat := List.range' 18466 0
def PRE_first_tail_x15_r0_body.ciS161 : List Nat := [] ++ List.range' 18466 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0161 : PRE_first_tail_x15_r0_body.kd161.nh0 = PRE_first_tail_x15_r0_body.cx0_161.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1161 : PRE_first_tail_x15_r0_body.kd161.nh1 = PRE_first_tail_x15_r0_body.cx1_161.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0161 : PRE_first_tail_x15_r0_body.kd161.nn0 = PRE_first_tail_x15_r0_body.cx0_161.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1161 : PRE_first_tail_x15_r0_body.kd161.nn1 = PRE_first_tail_x15_r0_body.cx1_161.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo161 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P161.lo && Nat.ble PRE_first_tail_x15_r0_body.P161.lo PRE_first_tail_x15_r0_body.cx0_161.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P161.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P161.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt161 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_161.mlx.next PRE_first_tail_x15_r0_body.cx1_161.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_161.mlx.nnext PRE_first_tail_x15_r0_body.cx1_161.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband161 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P161.NL && Nat.ble PRE_first_tail_x15_r0_body.P161.NL PRE_first_tail_x15_r0_body.P161.N0 && Nat.ble PRE_first_tail_x15_r0_body.P161.N0 PRE_first_tail_x15_r0_body.cx0_161.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow161 : PRE_first_tail_x15_r0_body.kd161.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren161 : checkRenG PRE_first_tail_x15_r0_body.kd161.hnd PRE_first_tail_x15_r0_body.khinv161 (phB PRE_first_tail_x15_r0_body.cx0_161.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband161 : PRE_first_tail_x15_r0_body.kd161.checkBand PRE_first_tail_x15_r0_body.P161.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos161 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd161.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren161 : checkRenG PRE_first_tail_x15_r0_body.kd161.node PRE_first_tail_x15_r0_body.kninv161 (pnB PRE_first_tail_x15_r0_body.cx0_161.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow161 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd161.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P161.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd161.nodeF j) PRE_first_tail_x15_r0_body.cx1_161.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a161 : PRE_first_tail_x15_r0_body.cx0_161.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b161 : PRE_first_tail_x15_r0_body.cx0_161.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1161 : PRE_first_tail_x15_r0_body.cx1_161.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend161 : PRE_first_tail_x15_r0_body.cx1_161.mlx.pending = PRE_first_tail_x15_r0_body.cx0_161.mlx.pending.map PRE_first_tail_x15_r0_body.kappa161.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh161 : PRE_first_tail_x15_r0_body.cx1_161.mlx.errh = PRE_first_tail_x15_r0_body.cx0_161.mlx.errh.map PRE_first_tail_x15_r0_body.kappa161.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles161 : PRE_first_tail_x15_r0_body.cx1_161.mlx.files = PRE_first_tail_x15_r0_body.cx0_161.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch161 : PRE_first_tail_x15_r0_body.cx1_161.mlx.arch = PRE_first_tail_x15_r0_body.cx0_161.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes161 : PRE_first_tail_x15_r0_body.cx1_161.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_161.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired161 : PRE_first_tail_x15_r0_body.cx1_161.mlx.wired = PRE_first_tail_x15_r0_body.cx0_161.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost161 : PRE_first_tail_x15_r0_body.cx1_161.host = PRE_first_tail_x15_r0_body.cx0_161.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd161`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0161 : PRE_first_tail_x15_r0_body.kd161.n0 = 2800920
kernel_rfl PRE_first_tail_x15_r0_body.ckn1161 : PRE_first_tail_x15_r0_body.kd161.n1 = 2800930
kernel_rfl PRE_first_tail_x15_r0_body.ckheap161 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd161.heap).all (fun x => Nat.ble 2800919 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl161 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd161.heap.get (2800919 + j) = nth? PRE_first_tail_x15_r0_body.pl161 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja161 : Nat.ble 2800919 2800919 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn161 : Nat.ble 6937 6937 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD161 : Nat.ble 2800919 PRE_first_tail_x15_r0_body.kd161.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn161 : Nat.ble 21364 PRE_first_tail_x15_r0_body.kd161.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn161 : Nat.ble 18466 PRE_first_tail_x15_r0_body.kd161.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb161 : Nat.ble 21364 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap161 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd161.heap).all (Nat.ble (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd161 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd161.hnd).all (Nat.ble (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode161 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd161.node).all (Nat.ble (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix161 : Conv.FixOld (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa161 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja161) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn161) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD161) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn161) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn161) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb161) PRE_first_tail_x15_r0_body.fheap161 PRE_first_tail_x15_r0_body.fhnd161 PRE_first_tail_x15_r0_body.fnode161
kernel_rfl PRE_first_tail_x15_r0_body.fcxn161 : (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn161 : (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0161 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_161.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_161.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk161 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd161.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A161 : PRE_first_tail_x15_r0_body.cx1_161.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS161.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_161.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O161 : PRE_first_tail_x15_r0_body.cx1_161.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS161.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_161.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N161 : PRE_first_tail_x15_r0_body.cx1_161.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS161.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_161.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I161 : PRE_first_tail_x15_r0_body.cx1_161.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS161.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_161.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd161 : (PRE_first_tail_x15_r0_body.clo161 ++ PRE_first_tail_x15_r0_body.cln161 ++ PRE_first_tail_x15_r0_body.cli161 ++ PRE_first_tail_x15_r0_body.cwS161 ++ PRE_first_tail_x15_r0_body.cnS161 ++ PRE_first_tail_x15_r0_body.ciS161).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW161 : PRE_first_tail_x15_r0_body.cwS161.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo161.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI161 : PRE_first_tail_x15_r0_body.ciS161.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli161.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN161 : PRE_first_tail_x15_r0_body.cnS161.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF161 : PRE_first_tail_x15_r0_body.cln161.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh161 : PRE_first_tail_x15_r0_body.clo161.all (handleOK PRE_first_tail_x15_r0_body.kappa161 PRE_first_tail_x15_r0_body.P161.lo PRE_first_tail_x15_r0_body.cx0_161.mlx PRE_first_tail_x15_r0_body.cx1_161.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo161 : PRE_first_tail_x15_r0_body.clo161.map (fun h => PRE_first_tail_x15_r0_body.cx1_161.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa161.handle h)) = PRE_first_tail_x15_r0_body.clo161.map (fun h => (PRE_first_tail_x15_r0_body.cx0_161.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa161.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok161 : PRE_first_tail_x15_r0_body.clo161.all (objOK PRE_first_tail_x15_r0_body.kappa161 PRE_first_tail_x15_r0_body.P161.NL PRE_first_tail_x15_r0_body.cx0_161.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd161 : PRE_first_tail_x15_r0_body.cln161.all (nodeOKF PRE_first_tail_x15_r0_body.kappa161 PRE_first_tail_x15_r0_body.P161 PRE_first_tail_x15_r0_body.cx0_161.mlx PRE_first_tail_x15_r0_body.cx1_161.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp161 : ((PRE_first_tail_x15_r0_body.cln161.filter (fullB PRE_first_tail_x15_r0_body.P161))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_161.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa161.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln161.filter (fullB PRE_first_tail_x15_r0_body.P161))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_161.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa161.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI161 : incrB PRE_first_tail_x15_r0_body.kd161.nodeF (List.range' 18466 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK161 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd161.node).all (fun k => Nat.ble 18466 k && Nat.blt k 18466) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL161 : (PRE_first_tail_x15_r0_body.cln161.filter (Nat.ble PRE_first_tail_x15_r0_body.P161.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd161.nodeF i) && (Nat.blt i 18466 || Nat.ble PRE_first_tail_x15_r0_body.kd161.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord161 : (PRE_first_tail_x15_r0_body.cln161.filter (Nat.ble PRE_first_tail_x15_r0_body.P161.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd161.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd161.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd161.nodeF j) (PRE_first_tail_x15_r0_body.kd161.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow161 PRE_first_tail_x15_r0_body.cnn1161 PRE_first_tail_x15_r0_body.fnordI161 PRE_first_tail_x15_r0_body.fnordK161 PRE_first_tail_x15_r0_body.fnordL161
kernel_rfl PRE_first_tail_x15_r0_body.fi161 : PRE_first_tail_x15_r0_body.cli161.all (pnB PRE_first_tail_x15_r0_body.cx0_161.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii161 : PRE_first_tail_x15_r0_body.cli161.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_161.mlx.items.get (PRE_first_tail_x15_r0_body.kappa161.node k) = (PRE_first_tail_x15_r0_body.cx0_161.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa161.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot161 (clean : Conv.NClean (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P161.NL) (cl : SSt (· < 6937) PRE_first_tail_x15_r0_body.cx0_161.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P161 6937 PRE_first_tail_x15_r0_body.kappa161 PRE_first_tail_x15_r0_body.kd161 PRE_first_tail_x15_r0_body.khinv161 PRE_first_tail_x15_r0_body.kninv161 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx PRE_first_tail_x15_r0_body.cx0_161.mlx PRE_first_tail_x15_r0_body.cx1_161.mlx (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo161 PRE_first_tail_x15_r0_body.cln161 PRE_first_tail_x15_r0_body.cli161 PRE_first_tail_x15_r0_body.cwS161 PRE_first_tail_x15_r0_body.cnS161 PRE_first_tail_x15_r0_body.ciS161 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0161, PRE_first_tail_x15_r0_body.cnh1161, PRE_first_tail_x15_r0_body.cnn0161, PRE_first_tail_x15_r0_body.cnn1161, PRE_first_tail_x15_r0_body.cplo161, PRE_first_tail_x15_r0_body.ccnt161, PRE_first_tail_x15_r0_body.cnband161, PRE_first_tail_x15_r0_body.chbelow161, PRE_first_tail_x15_r0_body.chren161, PRE_first_tail_x15_r0_body.cband161, PRE_first_tail_x15_r0_body.cnh1pos161, PRE_first_tail_x15_r0_body.cnren161, PRE_first_tail_x15_r0_body.cnlow161, PRE_first_tail_x15_r0_body.cabs0a161, PRE_first_tail_x15_r0_body.cabs0b161, PRE_first_tail_x15_r0_body.ctok1161, PRE_first_tail_x15_r0_body.cpend161, PRE_first_tail_x15_r0_body.cerrh161, PRE_first_tail_x15_r0_body.cfiles161, PRE_first_tail_x15_r0_body.carch161, PRE_first_tail_x15_r0_body.csizes161, PRE_first_tail_x15_r0_body.cwired161, PRE_first_tail_x15_r0_body.cfix161, clean, PRE_first_tail_x15_r0_body.fcxn161, PRE_first_tail_x15_r0_body.fcnn161, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0161, PRE_first_tail_x15_r0_body.fnk161, PRE_first_tail_x15_r0_body.ckA161, PRE_first_tail_x15_r0_body.cobjsK161, PRE_first_tail_x15_r0_body.cnodesK161, PRE_first_tail_x15_r0_body.citemsK161, PRE_first_tail_x15_r0_body.f1A161, PRE_first_tail_x15_r0_body.f1O161, PRE_first_tail_x15_r0_body.f1N161, PRE_first_tail_x15_r0_body.f1I161, PRE_first_tail_x15_r0_body.fbd161, PRE_first_tail_x15_r0_body.fincW161, PRE_first_tail_x15_r0_body.fincI161, PRE_first_tail_x15_r0_body.fincN161, PRE_first_tail_x15_r0_body.flnF161, PRE_first_tail_x15_r0_body.fh161, PRE_first_tail_x15_r0_body.fo161, PRE_first_tail_x15_r0_body.fok161, PRE_first_tail_x15_r0_body.fnd161, PRE_first_tail_x15_r0_body.fp161, PRE_first_tail_x15_r0_body.fnord161, PRE_first_tail_x15_r0_body.fi161, PRE_first_tail_x15_r0_body.fii161⟩
theorem PRE_first_tail_x15_r0_body.cnshift161 (clean : Conv.NClean (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P161.NL) (cl : SSt (· < 6937) PRE_first_tail_x15_r0_body.cx0_161.mlx) : NShift PRE_first_tail_x15_r0_body.P161 6937 PRE_first_tail_x15_r0_body.kappa161 PRE_first_tail_x15_r0_body.cx0_161 PRE_first_tail_x15_r0_body.cx1_161 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot161 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost161 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0161 PRE_first_tail_x15_r0_body.ckn1161 PRE_first_tail_x15_r0_body.ckheap161 PRE_first_tail_x15_r0_body.ckpl161)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_161 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1417.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_161 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1417.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_161 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1417.ffi) = some PRE_first_tail_x15_r0_body.fxC_161
kernel_rfl PRE_first_tail_x15_r0_body.okrC_161 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1417.ffi) = some PRE_first_tail_x15_r0_body.krC_161
noncomputable def PRE_first_tail_x15_r0_body.fx0_161 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1419.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_161 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1419.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_161 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1419.ffi) = some PRE_first_tail_x15_r0_body.fx0_161
kernel_rfl PRE_first_tail_x15_r0_body.okr0_161 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1419.ffi) = some PRE_first_tail_x15_r0_body.kr0_161
noncomputable def PRE_first_tail_x15_r0_body.fx1_161 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1418.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_161 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1418.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_161 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1418.ffi) = some PRE_first_tail_x15_r0_body.fx1_161
kernel_rfl PRE_first_tail_x15_r0_body.okr1_161 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1418.ffi) = some PRE_first_tail_x15_r0_body.kr1_161
kernel_rfl PRE_first_tail_x15_r0_body.ff0161 : PRE_first_tail_x15_r0_body.fx0_161 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_161 (PRE_first_tail_x15_r0_body.clo161.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_161.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1161 : PRE_first_tail_x15_r0_body.fx1_161 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_161 (PRE_first_tail_x15_r0_body.cwS161.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_161.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck161 : freedLB PRE_first_tail_x15_r0_body.kappa161 PRE_first_tail_x15_r0_body.cx0_161.mlx PRE_first_tail_x15_r0_body.fx0_161 PRE_first_tail_x15_r0_body.fx1_161 PRE_first_tail_x15_r0_body.clo161 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0161 : PRE_first_tail_x15_r0_body.kr0_161.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_161.flags (PRE_first_tail_x15_r0_body.clo161.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_161.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0161 : PRE_first_tail_x15_r0_body.kr0_161.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_161.targs (PRE_first_tail_x15_r0_body.clo161.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_161.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1161 : PRE_first_tail_x15_r0_body.kr1_161.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_161.flags (PRE_first_tail_x15_r0_body.cwS161.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_161.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1161 : PRE_first_tail_x15_r0_body.kr1_161.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_161.targs (PRE_first_tail_x15_r0_body.cwS161.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_161.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck161 : krecLB PRE_first_tail_x15_r0_body.kappa161 6937 PRE_first_tail_x15_r0_body.cx0_161.mlx PRE_first_tail_x15_r0_body.kr0_161 PRE_first_tail_x15_r0_body.kr1_161 PRE_first_tail_x15_r0_body.clo161 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn161 : Nat.ble 6937 6937 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge161 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1418.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1419.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR161 : pendRegB PRE_first_tail_x15_r0_body.kappa161 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1419.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe161 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1419.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1418.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift161 (clean : Conv.NClean (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P161.NL) (cl : SSt (· < 6937) PRE_first_tail_x15_r0_body.cx0_161.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_161.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_161.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_161.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1417.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_161.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P161 6937 PRE_first_tail_x15_r0_body.kappa161 PRE_first_tail_x15_r0_body.s1419.ffi PRE_first_tail_x15_r0_body.s1418.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift161 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue161, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp161 t ht),
    PRE_first_tail_x15_r0_body.cbridge161,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1419.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1418.ffi) (PRE_first_tail_x15_r0_body.cfoot161 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_161 PRE_first_tail_x15_r0_body.ofx1_161 hobjC PRE_first_tail_x15_r0_body.ff0161 PRE_first_tail_x15_r0_body.ff1161 PRE_first_tail_x15_r0_body.ffck161,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1419.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1418.ffi) (PRE_first_tail_x15_r0_body.cfoot161 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_161 PRE_first_tail_x15_r0_body.okr1_161 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn161) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0161 PRE_first_tail_x15_r0_body.fkt0161 PRE_first_tail_x15_r0_body.fkf1161 PRE_first_tail_x15_r0_body.fkt1161 PRE_first_tail_x15_r0_body.fkck161,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0161 PRE_first_tail_x15_r0_body.cnh1161 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe161) PRE_first_tail_x15_r0_body.cpendR161⟩

end Host.Load.Run.Tpl
