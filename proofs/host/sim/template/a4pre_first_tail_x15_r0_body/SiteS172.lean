import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl172
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 172 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc172 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P172 : LoadP := PRE_first_tail_x15_r0_body.Pc172.raise 18699
kernel_rfl PRE_first_tail_x15_r0_body.craise172 : Nat.ble PRE_first_tail_x15_r0_body.Pc172.N0 18699 = true
theorem PRE_first_tail_x15_r0_body.raised172 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc172 PRE_first_tail_x15_r0_body.P172 :=
  .inr ⟨18699, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise172, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_172 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1520.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_172 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi)
def PRE_first_tail_x15_r0_body.khinv172 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv172 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS172 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS172 : List Nat := List.range' 18699 0
def PRE_first_tail_x15_r0_body.ciS172 : List Nat := [] ++ List.range' 18699 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0172 : PRE_first_tail_x15_r0_body.kd172.nh0 = PRE_first_tail_x15_r0_body.cx0_172.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1172 : PRE_first_tail_x15_r0_body.kd172.nh1 = PRE_first_tail_x15_r0_body.cx1_172.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0172 : PRE_first_tail_x15_r0_body.kd172.nn0 = PRE_first_tail_x15_r0_body.cx0_172.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1172 : PRE_first_tail_x15_r0_body.kd172.nn1 = PRE_first_tail_x15_r0_body.cx1_172.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo172 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P172.lo && Nat.ble PRE_first_tail_x15_r0_body.P172.lo PRE_first_tail_x15_r0_body.cx0_172.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P172.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P172.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt172 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_172.mlx.next PRE_first_tail_x15_r0_body.cx1_172.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_172.mlx.nnext PRE_first_tail_x15_r0_body.cx1_172.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband172 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P172.NL && Nat.ble PRE_first_tail_x15_r0_body.P172.NL PRE_first_tail_x15_r0_body.P172.N0 && Nat.ble PRE_first_tail_x15_r0_body.P172.N0 PRE_first_tail_x15_r0_body.cx0_172.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow172 : PRE_first_tail_x15_r0_body.kd172.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren172 : checkRenG PRE_first_tail_x15_r0_body.kd172.hnd PRE_first_tail_x15_r0_body.khinv172 (phB PRE_first_tail_x15_r0_body.cx0_172.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband172 : PRE_first_tail_x15_r0_body.kd172.checkBand PRE_first_tail_x15_r0_body.P172.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos172 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd172.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren172 : checkRenG PRE_first_tail_x15_r0_body.kd172.node PRE_first_tail_x15_r0_body.kninv172 (pnB PRE_first_tail_x15_r0_body.cx0_172.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow172 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd172.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P172.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd172.nodeF j) PRE_first_tail_x15_r0_body.cx1_172.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a172 : PRE_first_tail_x15_r0_body.cx0_172.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b172 : PRE_first_tail_x15_r0_body.cx0_172.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1172 : PRE_first_tail_x15_r0_body.cx1_172.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend172 : PRE_first_tail_x15_r0_body.cx1_172.mlx.pending = PRE_first_tail_x15_r0_body.cx0_172.mlx.pending.map PRE_first_tail_x15_r0_body.kappa172.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh172 : PRE_first_tail_x15_r0_body.cx1_172.mlx.errh = PRE_first_tail_x15_r0_body.cx0_172.mlx.errh.map PRE_first_tail_x15_r0_body.kappa172.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles172 : PRE_first_tail_x15_r0_body.cx1_172.mlx.files = PRE_first_tail_x15_r0_body.cx0_172.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch172 : PRE_first_tail_x15_r0_body.cx1_172.mlx.arch = PRE_first_tail_x15_r0_body.cx0_172.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes172 : PRE_first_tail_x15_r0_body.cx1_172.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_172.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired172 : PRE_first_tail_x15_r0_body.cx1_172.mlx.wired = PRE_first_tail_x15_r0_body.cx0_172.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost172 : PRE_first_tail_x15_r0_body.cx1_172.host = PRE_first_tail_x15_r0_body.cx0_172.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd172`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0172 : PRE_first_tail_x15_r0_body.kd172.n0 = 2810055
kernel_rfl PRE_first_tail_x15_r0_body.ckn1172 : PRE_first_tail_x15_r0_body.kd172.n1 = 2810057
kernel_rfl PRE_first_tail_x15_r0_body.ckheap172 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd172.heap).all (fun x => Nat.ble 2810055 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl172 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd172.heap.get (2810055 + j) = nth? PRE_first_tail_x15_r0_body.pl172 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja172 : Nat.ble 2810055 2810055 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn172 : Nat.ble 7433 7433 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD172 : Nat.ble 2810055 PRE_first_tail_x15_r0_body.kd172.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn172 : Nat.ble 21593 PRE_first_tail_x15_r0_body.kd172.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn172 : Nat.ble 18699 PRE_first_tail_x15_r0_body.kd172.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb172 : Nat.ble 21593 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap172 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd172.heap).all (Nat.ble (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd172 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd172.hnd).all (Nat.ble (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode172 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd172.node).all (Nat.ble (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix172 : Conv.FixOld (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa172 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja172) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn172) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD172) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn172) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn172) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb172) PRE_first_tail_x15_r0_body.fheap172 PRE_first_tail_x15_r0_body.fhnd172 PRE_first_tail_x15_r0_body.fnode172
kernel_rfl PRE_first_tail_x15_r0_body.fcxn172 : (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn172 : (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0172 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_172.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_172.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk172 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd172.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A172 : PRE_first_tail_x15_r0_body.cx1_172.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS172.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_172.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O172 : PRE_first_tail_x15_r0_body.cx1_172.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS172.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_172.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N172 : PRE_first_tail_x15_r0_body.cx1_172.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS172.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_172.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I172 : PRE_first_tail_x15_r0_body.cx1_172.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS172.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_172.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd172 : (PRE_first_tail_x15_r0_body.clo172 ++ PRE_first_tail_x15_r0_body.cln172 ++ PRE_first_tail_x15_r0_body.cli172 ++ PRE_first_tail_x15_r0_body.cwS172 ++ PRE_first_tail_x15_r0_body.cnS172 ++ PRE_first_tail_x15_r0_body.ciS172).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW172 : PRE_first_tail_x15_r0_body.cwS172.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo172.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI172 : PRE_first_tail_x15_r0_body.ciS172.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli172.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN172 : PRE_first_tail_x15_r0_body.cnS172.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF172 : PRE_first_tail_x15_r0_body.cln172.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh172 : PRE_first_tail_x15_r0_body.clo172.all (handleOK PRE_first_tail_x15_r0_body.kappa172 PRE_first_tail_x15_r0_body.P172.lo PRE_first_tail_x15_r0_body.cx0_172.mlx PRE_first_tail_x15_r0_body.cx1_172.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo172 : PRE_first_tail_x15_r0_body.clo172.map (fun h => PRE_first_tail_x15_r0_body.cx1_172.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa172.handle h)) = PRE_first_tail_x15_r0_body.clo172.map (fun h => (PRE_first_tail_x15_r0_body.cx0_172.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa172.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok172 : PRE_first_tail_x15_r0_body.clo172.all (objOK PRE_first_tail_x15_r0_body.kappa172 PRE_first_tail_x15_r0_body.P172.NL PRE_first_tail_x15_r0_body.cx0_172.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd172 : PRE_first_tail_x15_r0_body.cln172.all (nodeOKF PRE_first_tail_x15_r0_body.kappa172 PRE_first_tail_x15_r0_body.P172 PRE_first_tail_x15_r0_body.cx0_172.mlx PRE_first_tail_x15_r0_body.cx1_172.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp172 : ((PRE_first_tail_x15_r0_body.cln172.filter (fullB PRE_first_tail_x15_r0_body.P172))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_172.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa172.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln172.filter (fullB PRE_first_tail_x15_r0_body.P172))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_172.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa172.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI172 : incrB PRE_first_tail_x15_r0_body.kd172.nodeF (List.range' 18699 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK172 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd172.node).all (fun k => Nat.ble 18699 k && Nat.blt k 18699) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL172 : (PRE_first_tail_x15_r0_body.cln172.filter (Nat.ble PRE_first_tail_x15_r0_body.P172.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd172.nodeF i) && (Nat.blt i 18699 || Nat.ble PRE_first_tail_x15_r0_body.kd172.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord172 : (PRE_first_tail_x15_r0_body.cln172.filter (Nat.ble PRE_first_tail_x15_r0_body.P172.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd172.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd172.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd172.nodeF j) (PRE_first_tail_x15_r0_body.kd172.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow172 PRE_first_tail_x15_r0_body.cnn1172 PRE_first_tail_x15_r0_body.fnordI172 PRE_first_tail_x15_r0_body.fnordK172 PRE_first_tail_x15_r0_body.fnordL172
kernel_rfl PRE_first_tail_x15_r0_body.fi172 : PRE_first_tail_x15_r0_body.cli172.all (pnB PRE_first_tail_x15_r0_body.cx0_172.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii172 : PRE_first_tail_x15_r0_body.cli172.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_172.mlx.items.get (PRE_first_tail_x15_r0_body.kappa172.node k) = (PRE_first_tail_x15_r0_body.cx0_172.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa172.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot172 (clean : Conv.NClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P172.NL) (cl : SSt (· < 7433) PRE_first_tail_x15_r0_body.cx0_172.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P172 7433 PRE_first_tail_x15_r0_body.kappa172 PRE_first_tail_x15_r0_body.kd172 PRE_first_tail_x15_r0_body.khinv172 PRE_first_tail_x15_r0_body.kninv172 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx PRE_first_tail_x15_r0_body.cx0_172.mlx PRE_first_tail_x15_r0_body.cx1_172.mlx (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo172 PRE_first_tail_x15_r0_body.cln172 PRE_first_tail_x15_r0_body.cli172 PRE_first_tail_x15_r0_body.cwS172 PRE_first_tail_x15_r0_body.cnS172 PRE_first_tail_x15_r0_body.ciS172 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0172, PRE_first_tail_x15_r0_body.cnh1172, PRE_first_tail_x15_r0_body.cnn0172, PRE_first_tail_x15_r0_body.cnn1172, PRE_first_tail_x15_r0_body.cplo172, PRE_first_tail_x15_r0_body.ccnt172, PRE_first_tail_x15_r0_body.cnband172, PRE_first_tail_x15_r0_body.chbelow172, PRE_first_tail_x15_r0_body.chren172, PRE_first_tail_x15_r0_body.cband172, PRE_first_tail_x15_r0_body.cnh1pos172, PRE_first_tail_x15_r0_body.cnren172, PRE_first_tail_x15_r0_body.cnlow172, PRE_first_tail_x15_r0_body.cabs0a172, PRE_first_tail_x15_r0_body.cabs0b172, PRE_first_tail_x15_r0_body.ctok1172, PRE_first_tail_x15_r0_body.cpend172, PRE_first_tail_x15_r0_body.cerrh172, PRE_first_tail_x15_r0_body.cfiles172, PRE_first_tail_x15_r0_body.carch172, PRE_first_tail_x15_r0_body.csizes172, PRE_first_tail_x15_r0_body.cwired172, PRE_first_tail_x15_r0_body.cfix172, clean, PRE_first_tail_x15_r0_body.fcxn172, PRE_first_tail_x15_r0_body.fcnn172, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0172, PRE_first_tail_x15_r0_body.fnk172, PRE_first_tail_x15_r0_body.ckA172, PRE_first_tail_x15_r0_body.cobjsK172, PRE_first_tail_x15_r0_body.cnodesK172, PRE_first_tail_x15_r0_body.citemsK172, PRE_first_tail_x15_r0_body.f1A172, PRE_first_tail_x15_r0_body.f1O172, PRE_first_tail_x15_r0_body.f1N172, PRE_first_tail_x15_r0_body.f1I172, PRE_first_tail_x15_r0_body.fbd172, PRE_first_tail_x15_r0_body.fincW172, PRE_first_tail_x15_r0_body.fincI172, PRE_first_tail_x15_r0_body.fincN172, PRE_first_tail_x15_r0_body.flnF172, PRE_first_tail_x15_r0_body.fh172, PRE_first_tail_x15_r0_body.fo172, PRE_first_tail_x15_r0_body.fok172, PRE_first_tail_x15_r0_body.fnd172, PRE_first_tail_x15_r0_body.fp172, PRE_first_tail_x15_r0_body.fnord172, PRE_first_tail_x15_r0_body.fi172, PRE_first_tail_x15_r0_body.fii172⟩
theorem PRE_first_tail_x15_r0_body.cnshift172 (clean : Conv.NClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P172.NL) (cl : SSt (· < 7433) PRE_first_tail_x15_r0_body.cx0_172.mlx) : NShift PRE_first_tail_x15_r0_body.P172 7433 PRE_first_tail_x15_r0_body.kappa172 PRE_first_tail_x15_r0_body.cx0_172 PRE_first_tail_x15_r0_body.cx1_172 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot172 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost172 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0172 PRE_first_tail_x15_r0_body.ckn1172 PRE_first_tail_x15_r0_body.ckheap172 PRE_first_tail_x15_r0_body.ckpl172)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_172 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1518.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_172 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1518.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_172 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1518.ffi) = some PRE_first_tail_x15_r0_body.fxC_172
kernel_rfl PRE_first_tail_x15_r0_body.okrC_172 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1518.ffi) = some PRE_first_tail_x15_r0_body.krC_172
noncomputable def PRE_first_tail_x15_r0_body.fx0_172 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1520.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_172 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1520.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_172 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1520.ffi) = some PRE_first_tail_x15_r0_body.fx0_172
kernel_rfl PRE_first_tail_x15_r0_body.okr0_172 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1520.ffi) = some PRE_first_tail_x15_r0_body.kr0_172
noncomputable def PRE_first_tail_x15_r0_body.fx1_172 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1519.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_172 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1519.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_172 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1519.ffi) = some PRE_first_tail_x15_r0_body.fx1_172
kernel_rfl PRE_first_tail_x15_r0_body.okr1_172 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1519.ffi) = some PRE_first_tail_x15_r0_body.kr1_172
kernel_rfl PRE_first_tail_x15_r0_body.ff0172 : PRE_first_tail_x15_r0_body.fx0_172 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_172 (PRE_first_tail_x15_r0_body.clo172.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_172.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1172 : PRE_first_tail_x15_r0_body.fx1_172 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_172 (PRE_first_tail_x15_r0_body.cwS172.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_172.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck172 : freedLB PRE_first_tail_x15_r0_body.kappa172 PRE_first_tail_x15_r0_body.cx0_172.mlx PRE_first_tail_x15_r0_body.fx0_172 PRE_first_tail_x15_r0_body.fx1_172 PRE_first_tail_x15_r0_body.clo172 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0172 : PRE_first_tail_x15_r0_body.kr0_172.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_172.flags (PRE_first_tail_x15_r0_body.clo172.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_172.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0172 : PRE_first_tail_x15_r0_body.kr0_172.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_172.targs (PRE_first_tail_x15_r0_body.clo172.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_172.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1172 : PRE_first_tail_x15_r0_body.kr1_172.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_172.flags (PRE_first_tail_x15_r0_body.cwS172.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_172.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1172 : PRE_first_tail_x15_r0_body.kr1_172.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_172.targs (PRE_first_tail_x15_r0_body.cwS172.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_172.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck172 : krecLB PRE_first_tail_x15_r0_body.kappa172 7433 PRE_first_tail_x15_r0_body.cx0_172.mlx PRE_first_tail_x15_r0_body.kr0_172 PRE_first_tail_x15_r0_body.kr1_172 PRE_first_tail_x15_r0_body.clo172 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn172 : Nat.ble 7433 7433 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge172 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1519.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1520.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR172 : pendRegB PRE_first_tail_x15_r0_body.kappa172 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1520.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe172 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1520.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift172 (clean : Conv.NClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P172.NL) (cl : SSt (· < 7433) PRE_first_tail_x15_r0_body.cx0_172.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_172.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_172.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_172.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_172.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P172 7433 PRE_first_tail_x15_r0_body.kappa172 PRE_first_tail_x15_r0_body.s1520.ffi PRE_first_tail_x15_r0_body.s1519.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift172 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue172, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp172 t ht),
    PRE_first_tail_x15_r0_body.cbridge172,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1520.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1519.ffi) (PRE_first_tail_x15_r0_body.cfoot172 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_172 PRE_first_tail_x15_r0_body.ofx1_172 hobjC PRE_first_tail_x15_r0_body.ff0172 PRE_first_tail_x15_r0_body.ff1172 PRE_first_tail_x15_r0_body.ffck172,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1520.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1519.ffi) (PRE_first_tail_x15_r0_body.cfoot172 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_172 PRE_first_tail_x15_r0_body.okr1_172 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn172) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0172 PRE_first_tail_x15_r0_body.fkt0172 PRE_first_tail_x15_r0_body.fkf1172 PRE_first_tail_x15_r0_body.fkt1172 PRE_first_tail_x15_r0_body.fkck172,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0172 PRE_first_tail_x15_r0_body.cnh1172 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe172) PRE_first_tail_x15_r0_body.cpendR172⟩

end Host.Load.Run.Tpl
