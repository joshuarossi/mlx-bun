import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl191
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 191 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc191 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P191 : LoadP := PRE_first_tail_x15_r0_body.Pc191.raise 19051
kernel_rfl PRE_first_tail_x15_r0_body.craise191 : Nat.ble PRE_first_tail_x15_r0_body.Pc191.N0 19051 = true
theorem PRE_first_tail_x15_r0_body.raised191 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc191 PRE_first_tail_x15_r0_body.P191 :=
  .inr ⟨19051, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise191, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_191 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_191 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1840.ffi)
def PRE_first_tail_x15_r0_body.khinv191 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv191 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS191 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS191 : List Nat := List.range' 19051 0
def PRE_first_tail_x15_r0_body.ciS191 : List Nat := [] ++ List.range' 19051 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0191 : PRE_first_tail_x15_r0_body.kd191.nh0 = PRE_first_tail_x15_r0_body.cx0_191.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1191 : PRE_first_tail_x15_r0_body.kd191.nh1 = PRE_first_tail_x15_r0_body.cx1_191.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0191 : PRE_first_tail_x15_r0_body.kd191.nn0 = PRE_first_tail_x15_r0_body.cx0_191.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1191 : PRE_first_tail_x15_r0_body.kd191.nn1 = PRE_first_tail_x15_r0_body.cx1_191.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo191 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P191.lo && Nat.ble PRE_first_tail_x15_r0_body.P191.lo PRE_first_tail_x15_r0_body.cx0_191.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P191.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P191.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt191 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_191.mlx.next PRE_first_tail_x15_r0_body.cx1_191.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_191.mlx.nnext PRE_first_tail_x15_r0_body.cx1_191.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband191 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P191.NL && Nat.ble PRE_first_tail_x15_r0_body.P191.NL PRE_first_tail_x15_r0_body.P191.N0 && Nat.ble PRE_first_tail_x15_r0_body.P191.N0 PRE_first_tail_x15_r0_body.cx0_191.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow191 : PRE_first_tail_x15_r0_body.kd191.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren191 : checkRenG PRE_first_tail_x15_r0_body.kd191.hnd PRE_first_tail_x15_r0_body.khinv191 (phB PRE_first_tail_x15_r0_body.cx0_191.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband191 : PRE_first_tail_x15_r0_body.kd191.checkBand PRE_first_tail_x15_r0_body.P191.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos191 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd191.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren191 : checkRenG PRE_first_tail_x15_r0_body.kd191.node PRE_first_tail_x15_r0_body.kninv191 (pnB PRE_first_tail_x15_r0_body.cx0_191.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P191.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd191.nodeF j) PRE_first_tail_x15_r0_body.cx1_191.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a191 : PRE_first_tail_x15_r0_body.cx0_191.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b191 : PRE_first_tail_x15_r0_body.cx0_191.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.pending = PRE_first_tail_x15_r0_body.cx0_191.mlx.pending.map PRE_first_tail_x15_r0_body.kappa191.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.errh = PRE_first_tail_x15_r0_body.cx0_191.mlx.errh.map PRE_first_tail_x15_r0_body.kappa191.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.files = PRE_first_tail_x15_r0_body.cx0_191.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.arch = PRE_first_tail_x15_r0_body.cx0_191.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_191.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.wired = PRE_first_tail_x15_r0_body.cx0_191.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost191 : PRE_first_tail_x15_r0_body.cx1_191.host = PRE_first_tail_x15_r0_body.cx0_191.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd191`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0191 : PRE_first_tail_x15_r0_body.kd191.n0 = 2824654
kernel_rfl PRE_first_tail_x15_r0_body.ckn1191 : PRE_first_tail_x15_r0_body.kd191.n1 = 2824664
kernel_rfl PRE_first_tail_x15_r0_body.ckheap191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.heap).all (fun x => Nat.ble 2824653 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl191 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd191.heap.get (2824653 + j) = nth? PRE_first_tail_x15_r0_body.pl191 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja191 : Nat.ble 2824653 2824653 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn191 : Nat.ble 8218 8218 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD191 : Nat.ble 2824653 PRE_first_tail_x15_r0_body.kd191.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn191 : Nat.ble 21957 PRE_first_tail_x15_r0_body.kd191.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn191 : Nat.ble 19051 PRE_first_tail_x15_r0_body.kd191.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb191 : Nat.ble 21957 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.heap).all (Nat.ble (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.hnd).all (Nat.ble (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.node).all (Nat.ble (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix191 : Conv.FixOld (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa191 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja191) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn191) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD191) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn191) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn191) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb191) PRE_first_tail_x15_r0_body.fheap191 PRE_first_tail_x15_r0_body.fhnd191 PRE_first_tail_x15_r0_body.fnode191
kernel_rfl PRE_first_tail_x15_r0_body.fcxn191 : (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn191 : (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0191 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_191.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_191.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS191.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_191.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS191.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_191.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS191.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_191.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS191.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_191.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd191 : (PRE_first_tail_x15_r0_body.clo191 ++ PRE_first_tail_x15_r0_body.cln191 ++ PRE_first_tail_x15_r0_body.cli191 ++ PRE_first_tail_x15_r0_body.cwS191 ++ PRE_first_tail_x15_r0_body.cnS191 ++ PRE_first_tail_x15_r0_body.ciS191).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW191 : PRE_first_tail_x15_r0_body.cwS191.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo191.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI191 : PRE_first_tail_x15_r0_body.ciS191.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli191.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN191 : PRE_first_tail_x15_r0_body.cnS191.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF191 : PRE_first_tail_x15_r0_body.cln191.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh191 : PRE_first_tail_x15_r0_body.clo191.all (handleOK PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.P191.lo PRE_first_tail_x15_r0_body.cx0_191.mlx PRE_first_tail_x15_r0_body.cx1_191.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo191 : PRE_first_tail_x15_r0_body.clo191.map (fun h => PRE_first_tail_x15_r0_body.cx1_191.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa191.handle h)) = PRE_first_tail_x15_r0_body.clo191.map (fun h => (PRE_first_tail_x15_r0_body.cx0_191.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa191.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok191 : PRE_first_tail_x15_r0_body.clo191.all (objOK PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.P191.NL PRE_first_tail_x15_r0_body.cx0_191.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd191 : PRE_first_tail_x15_r0_body.cln191.all (nodeOKF PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.P191 PRE_first_tail_x15_r0_body.cx0_191.mlx PRE_first_tail_x15_r0_body.cx1_191.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp191 : ((PRE_first_tail_x15_r0_body.cln191.filter (fullB PRE_first_tail_x15_r0_body.P191))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_191.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa191.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln191.filter (fullB PRE_first_tail_x15_r0_body.P191))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_191.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa191.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI191 : incrB PRE_first_tail_x15_r0_body.kd191.nodeF (List.range' 19051 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.node).all (fun k => Nat.ble 19051 k && Nat.blt k 19051) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL191 : (PRE_first_tail_x15_r0_body.cln191.filter (Nat.ble PRE_first_tail_x15_r0_body.P191.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd191.nodeF i) && (Nat.blt i 19051 || Nat.ble PRE_first_tail_x15_r0_body.kd191.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord191 : (PRE_first_tail_x15_r0_body.cln191.filter (Nat.ble PRE_first_tail_x15_r0_body.P191.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd191.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd191.nodeF j) (PRE_first_tail_x15_r0_body.kd191.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow191 PRE_first_tail_x15_r0_body.cnn1191 PRE_first_tail_x15_r0_body.fnordI191 PRE_first_tail_x15_r0_body.fnordK191 PRE_first_tail_x15_r0_body.fnordL191
kernel_rfl PRE_first_tail_x15_r0_body.fi191 : PRE_first_tail_x15_r0_body.cli191.all (pnB PRE_first_tail_x15_r0_body.cx0_191.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii191 : PRE_first_tail_x15_r0_body.cli191.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_191.mlx.items.get (PRE_first_tail_x15_r0_body.kappa191.node k) = (PRE_first_tail_x15_r0_body.cx0_191.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa191.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot191 (clean : Conv.NClean (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P191.NL) (cl : SSt (· < 8218) PRE_first_tail_x15_r0_body.cx0_191.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P191 8218 PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.kd191 PRE_first_tail_x15_r0_body.khinv191 PRE_first_tail_x15_r0_body.kninv191 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx PRE_first_tail_x15_r0_body.cx0_191.mlx PRE_first_tail_x15_r0_body.cx1_191.mlx (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo191 PRE_first_tail_x15_r0_body.cln191 PRE_first_tail_x15_r0_body.cli191 PRE_first_tail_x15_r0_body.cwS191 PRE_first_tail_x15_r0_body.cnS191 PRE_first_tail_x15_r0_body.ciS191 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0191, PRE_first_tail_x15_r0_body.cnh1191, PRE_first_tail_x15_r0_body.cnn0191, PRE_first_tail_x15_r0_body.cnn1191, PRE_first_tail_x15_r0_body.cplo191, PRE_first_tail_x15_r0_body.ccnt191, PRE_first_tail_x15_r0_body.cnband191, PRE_first_tail_x15_r0_body.chbelow191, PRE_first_tail_x15_r0_body.chren191, PRE_first_tail_x15_r0_body.cband191, PRE_first_tail_x15_r0_body.cnh1pos191, PRE_first_tail_x15_r0_body.cnren191, PRE_first_tail_x15_r0_body.cnlow191, PRE_first_tail_x15_r0_body.cabs0a191, PRE_first_tail_x15_r0_body.cabs0b191, PRE_first_tail_x15_r0_body.ctok1191, PRE_first_tail_x15_r0_body.cpend191, PRE_first_tail_x15_r0_body.cerrh191, PRE_first_tail_x15_r0_body.cfiles191, PRE_first_tail_x15_r0_body.carch191, PRE_first_tail_x15_r0_body.csizes191, PRE_first_tail_x15_r0_body.cwired191, PRE_first_tail_x15_r0_body.cfix191, clean, PRE_first_tail_x15_r0_body.fcxn191, PRE_first_tail_x15_r0_body.fcnn191, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0191, PRE_first_tail_x15_r0_body.fnk191, PRE_first_tail_x15_r0_body.ckA191, PRE_first_tail_x15_r0_body.cobjsK191, PRE_first_tail_x15_r0_body.cnodesK191, PRE_first_tail_x15_r0_body.citemsK191, PRE_first_tail_x15_r0_body.f1A191, PRE_first_tail_x15_r0_body.f1O191, PRE_first_tail_x15_r0_body.f1N191, PRE_first_tail_x15_r0_body.f1I191, PRE_first_tail_x15_r0_body.fbd191, PRE_first_tail_x15_r0_body.fincW191, PRE_first_tail_x15_r0_body.fincI191, PRE_first_tail_x15_r0_body.fincN191, PRE_first_tail_x15_r0_body.flnF191, PRE_first_tail_x15_r0_body.fh191, PRE_first_tail_x15_r0_body.fo191, PRE_first_tail_x15_r0_body.fok191, PRE_first_tail_x15_r0_body.fnd191, PRE_first_tail_x15_r0_body.fp191, PRE_first_tail_x15_r0_body.fnord191, PRE_first_tail_x15_r0_body.fi191, PRE_first_tail_x15_r0_body.fii191⟩
theorem PRE_first_tail_x15_r0_body.cnshift191 (clean : Conv.NClean (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P191.NL) (cl : SSt (· < 8218) PRE_first_tail_x15_r0_body.cx0_191.mlx) : NShift PRE_first_tail_x15_r0_body.P191 8218 PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.cx0_191 PRE_first_tail_x15_r0_body.cx1_191 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot191 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost191 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0191 PRE_first_tail_x15_r0_body.ckn1191 PRE_first_tail_x15_r0_body.ckheap191 PRE_first_tail_x15_r0_body.ckpl191)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_191 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1839.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_191 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1839.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_191 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1839.ffi) = some PRE_first_tail_x15_r0_body.fxC_191
kernel_rfl PRE_first_tail_x15_r0_body.okrC_191 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1839.ffi) = some PRE_first_tail_x15_r0_body.krC_191
noncomputable def PRE_first_tail_x15_r0_body.fx0_191 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1841.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_191 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1841.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_191 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1841.ffi) = some PRE_first_tail_x15_r0_body.fx0_191
kernel_rfl PRE_first_tail_x15_r0_body.okr0_191 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1841.ffi) = some PRE_first_tail_x15_r0_body.kr0_191
noncomputable def PRE_first_tail_x15_r0_body.fx1_191 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1840.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_191 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1840.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_191 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1840.ffi) = some PRE_first_tail_x15_r0_body.fx1_191
kernel_rfl PRE_first_tail_x15_r0_body.okr1_191 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1840.ffi) = some PRE_first_tail_x15_r0_body.kr1_191
kernel_rfl PRE_first_tail_x15_r0_body.ff0191 : PRE_first_tail_x15_r0_body.fx0_191 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_191 (PRE_first_tail_x15_r0_body.clo191.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_191.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1191 : PRE_first_tail_x15_r0_body.fx1_191 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_191 (PRE_first_tail_x15_r0_body.cwS191.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_191.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck191 : freedLB PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.cx0_191.mlx PRE_first_tail_x15_r0_body.fx0_191 PRE_first_tail_x15_r0_body.fx1_191 PRE_first_tail_x15_r0_body.clo191 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0191 : PRE_first_tail_x15_r0_body.kr0_191.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_191.flags (PRE_first_tail_x15_r0_body.clo191.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_191.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0191 : PRE_first_tail_x15_r0_body.kr0_191.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_191.targs (PRE_first_tail_x15_r0_body.clo191.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_191.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1191 : PRE_first_tail_x15_r0_body.kr1_191.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_191.flags (PRE_first_tail_x15_r0_body.cwS191.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_191.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1191 : PRE_first_tail_x15_r0_body.kr1_191.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_191.targs (PRE_first_tail_x15_r0_body.cwS191.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_191.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck191 : krecLB PRE_first_tail_x15_r0_body.kappa191 8218 PRE_first_tail_x15_r0_body.cx0_191.mlx PRE_first_tail_x15_r0_body.kr0_191 PRE_first_tail_x15_r0_body.kr1_191 PRE_first_tail_x15_r0_body.clo191 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn191 : Nat.ble 8218 8218 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge191 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1840.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1841.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR191 : pendRegB PRE_first_tail_x15_r0_body.kappa191 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe191 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1840.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift191 (clean : Conv.NClean (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P191.NL) (cl : SSt (· < 8218) PRE_first_tail_x15_r0_body.cx0_191.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_191.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_191.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_191.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_191.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P191 8218 PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.s1841.ffi PRE_first_tail_x15_r0_body.s1840.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift191 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue191, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp191 t ht),
    PRE_first_tail_x15_r0_body.cbridge191,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1841.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1840.ffi) (PRE_first_tail_x15_r0_body.cfoot191 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_191 PRE_first_tail_x15_r0_body.ofx1_191 hobjC PRE_first_tail_x15_r0_body.ff0191 PRE_first_tail_x15_r0_body.ff1191 PRE_first_tail_x15_r0_body.ffck191,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1841.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1840.ffi) (PRE_first_tail_x15_r0_body.cfoot191 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_191 PRE_first_tail_x15_r0_body.okr1_191 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn191) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0191 PRE_first_tail_x15_r0_body.fkt0191 PRE_first_tail_x15_r0_body.fkf1191 PRE_first_tail_x15_r0_body.fkt1191 PRE_first_tail_x15_r0_body.fkck191,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0191 PRE_first_tail_x15_r0_body.cnh1191 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe191) PRE_first_tail_x15_r0_body.cpendR191⟩

end Host.Load.Run.Tpl
