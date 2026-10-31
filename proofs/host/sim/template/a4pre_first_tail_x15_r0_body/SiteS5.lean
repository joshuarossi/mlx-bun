import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl5
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 5 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc5 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P5 : LoadP := PRE_first_tail_x15_r0_body.Pc5.raise 15385
kernel_rfl PRE_first_tail_x15_r0_body.craise5 : Nat.ble PRE_first_tail_x15_r0_body.Pc5.N0 15385 = true
theorem PRE_first_tail_x15_r0_body.raised5 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc5 PRE_first_tail_x15_r0_body.P5 :=
  .inr ⟨15385, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise5, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_5 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_5 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s58.ffi)
def PRE_first_tail_x15_r0_body.khinv5 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv5 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS5 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS5 : List Nat := List.range' 15385 0
def PRE_first_tail_x15_r0_body.ciS5 : List Nat := [] ++ List.range' 15385 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh05 : PRE_first_tail_x15_r0_body.kd5.nh0 = PRE_first_tail_x15_r0_body.cx0_5.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh15 : PRE_first_tail_x15_r0_body.kd5.nh1 = PRE_first_tail_x15_r0_body.cx1_5.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn05 : PRE_first_tail_x15_r0_body.kd5.nn0 = PRE_first_tail_x15_r0_body.cx0_5.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn15 : PRE_first_tail_x15_r0_body.kd5.nn1 = PRE_first_tail_x15_r0_body.cx1_5.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo5 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P5.lo && Nat.ble PRE_first_tail_x15_r0_body.P5.lo PRE_first_tail_x15_r0_body.cx0_5.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P5.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P5.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt5 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_5.mlx.next PRE_first_tail_x15_r0_body.cx1_5.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_5.mlx.nnext PRE_first_tail_x15_r0_body.cx1_5.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband5 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P5.NL && Nat.ble PRE_first_tail_x15_r0_body.P5.NL PRE_first_tail_x15_r0_body.P5.N0 && Nat.ble PRE_first_tail_x15_r0_body.P5.N0 PRE_first_tail_x15_r0_body.cx0_5.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow5 : PRE_first_tail_x15_r0_body.kd5.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren5 : checkRenG PRE_first_tail_x15_r0_body.kd5.hnd PRE_first_tail_x15_r0_body.khinv5 (phB PRE_first_tail_x15_r0_body.cx0_5.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband5 : PRE_first_tail_x15_r0_body.kd5.checkBand PRE_first_tail_x15_r0_body.P5.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos5 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd5.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren5 : checkRenG PRE_first_tail_x15_r0_body.kd5.node PRE_first_tail_x15_r0_body.kninv5 (pnB PRE_first_tail_x15_r0_body.cx0_5.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow5 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd5.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P5.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd5.nodeF j) PRE_first_tail_x15_r0_body.cx1_5.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a5 : PRE_first_tail_x15_r0_body.cx0_5.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b5 : PRE_first_tail_x15_r0_body.cx0_5.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok15 : PRE_first_tail_x15_r0_body.cx1_5.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend5 : PRE_first_tail_x15_r0_body.cx1_5.mlx.pending = PRE_first_tail_x15_r0_body.cx0_5.mlx.pending.map PRE_first_tail_x15_r0_body.kappa5.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh5 : PRE_first_tail_x15_r0_body.cx1_5.mlx.errh = PRE_first_tail_x15_r0_body.cx0_5.mlx.errh.map PRE_first_tail_x15_r0_body.kappa5.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles5 : PRE_first_tail_x15_r0_body.cx1_5.mlx.files = PRE_first_tail_x15_r0_body.cx0_5.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch5 : PRE_first_tail_x15_r0_body.cx1_5.mlx.arch = PRE_first_tail_x15_r0_body.cx0_5.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes5 : PRE_first_tail_x15_r0_body.cx1_5.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_5.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired5 : PRE_first_tail_x15_r0_body.cx1_5.mlx.wired = PRE_first_tail_x15_r0_body.cx0_5.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost5 : PRE_first_tail_x15_r0_body.cx1_5.host = PRE_first_tail_x15_r0_body.cx0_5.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd5`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn05 : PRE_first_tail_x15_r0_body.kd5.n0 = 2678408
kernel_rfl PRE_first_tail_x15_r0_body.ckn15 : PRE_first_tail_x15_r0_body.kd5.n1 = 2678418
kernel_rfl PRE_first_tail_x15_r0_body.ckheap5 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd5.heap).all (fun x => Nat.ble 2678407 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl5 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd5.heap.get (2678407 + j) = nth? PRE_first_tail_x15_r0_body.pl5 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja5 : Nat.ble 2678407 2678407 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn5 : Nat.ble 268 268 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD5 : Nat.ble 2678407 PRE_first_tail_x15_r0_body.kd5.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn5 : Nat.ble 18293 PRE_first_tail_x15_r0_body.kd5.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn5 : Nat.ble 15385 PRE_first_tail_x15_r0_body.kd5.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb5 : Nat.ble 18293 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap5 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd5.heap).all (Nat.ble (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd5 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd5.hnd).all (Nat.ble (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode5 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd5.node).all (Nat.ble (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix5 : Conv.FixOld (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa5 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja5) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn5) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD5) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn5) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn5) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb5) PRE_first_tail_x15_r0_body.fheap5 PRE_first_tail_x15_r0_body.fhnd5 PRE_first_tail_x15_r0_body.fnode5
kernel_rfl PRE_first_tail_x15_r0_body.fcxn5 : (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn5 : (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle05 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_5.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_5.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk5 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd5.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A5 : PRE_first_tail_x15_r0_body.cx1_5.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS5.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_5.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O5 : PRE_first_tail_x15_r0_body.cx1_5.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS5.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_5.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N5 : PRE_first_tail_x15_r0_body.cx1_5.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS5.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_5.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I5 : PRE_first_tail_x15_r0_body.cx1_5.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS5.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_5.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd5 : (PRE_first_tail_x15_r0_body.clo5 ++ PRE_first_tail_x15_r0_body.cln5 ++ PRE_first_tail_x15_r0_body.cli5 ++ PRE_first_tail_x15_r0_body.cwS5 ++ PRE_first_tail_x15_r0_body.cnS5 ++ PRE_first_tail_x15_r0_body.ciS5).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW5 : PRE_first_tail_x15_r0_body.cwS5.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo5.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI5 : PRE_first_tail_x15_r0_body.ciS5.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli5.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN5 : PRE_first_tail_x15_r0_body.cnS5.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF5 : PRE_first_tail_x15_r0_body.cln5.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh5 : PRE_first_tail_x15_r0_body.clo5.all (handleOK PRE_first_tail_x15_r0_body.kappa5 PRE_first_tail_x15_r0_body.P5.lo PRE_first_tail_x15_r0_body.cx0_5.mlx PRE_first_tail_x15_r0_body.cx1_5.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo5 : PRE_first_tail_x15_r0_body.clo5.map (fun h => PRE_first_tail_x15_r0_body.cx1_5.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa5.handle h)) = PRE_first_tail_x15_r0_body.clo5.map (fun h => (PRE_first_tail_x15_r0_body.cx0_5.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa5.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok5 : PRE_first_tail_x15_r0_body.clo5.all (objOK PRE_first_tail_x15_r0_body.kappa5 PRE_first_tail_x15_r0_body.P5.NL PRE_first_tail_x15_r0_body.cx0_5.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd5 : PRE_first_tail_x15_r0_body.cln5.all (nodeOKF PRE_first_tail_x15_r0_body.kappa5 PRE_first_tail_x15_r0_body.P5 PRE_first_tail_x15_r0_body.cx0_5.mlx PRE_first_tail_x15_r0_body.cx1_5.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp5 : ((PRE_first_tail_x15_r0_body.cln5.filter (fullB PRE_first_tail_x15_r0_body.P5))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_5.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa5.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln5.filter (fullB PRE_first_tail_x15_r0_body.P5))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_5.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa5.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI5 : incrB PRE_first_tail_x15_r0_body.kd5.nodeF (List.range' 15385 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK5 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd5.node).all (fun k => Nat.ble 15385 k && Nat.blt k 15385) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL5 : (PRE_first_tail_x15_r0_body.cln5.filter (Nat.ble PRE_first_tail_x15_r0_body.P5.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd5.nodeF i) && (Nat.blt i 15385 || Nat.ble PRE_first_tail_x15_r0_body.kd5.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord5 : (PRE_first_tail_x15_r0_body.cln5.filter (Nat.ble PRE_first_tail_x15_r0_body.P5.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd5.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd5.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd5.nodeF j) (PRE_first_tail_x15_r0_body.kd5.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow5 PRE_first_tail_x15_r0_body.cnn15 PRE_first_tail_x15_r0_body.fnordI5 PRE_first_tail_x15_r0_body.fnordK5 PRE_first_tail_x15_r0_body.fnordL5
kernel_rfl PRE_first_tail_x15_r0_body.fi5 : PRE_first_tail_x15_r0_body.cli5.all (pnB PRE_first_tail_x15_r0_body.cx0_5.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii5 : PRE_first_tail_x15_r0_body.cli5.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_5.mlx.items.get (PRE_first_tail_x15_r0_body.kappa5.node k) = (PRE_first_tail_x15_r0_body.cx0_5.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa5.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot5 (clean : Conv.NClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P5.NL) (cl : SSt (· < 268) PRE_first_tail_x15_r0_body.cx0_5.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P5 268 PRE_first_tail_x15_r0_body.kappa5 PRE_first_tail_x15_r0_body.kd5 PRE_first_tail_x15_r0_body.khinv5 PRE_first_tail_x15_r0_body.kninv5 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx PRE_first_tail_x15_r0_body.cx0_5.mlx PRE_first_tail_x15_r0_body.cx1_5.mlx (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo5 PRE_first_tail_x15_r0_body.cln5 PRE_first_tail_x15_r0_body.cli5 PRE_first_tail_x15_r0_body.cwS5 PRE_first_tail_x15_r0_body.cnS5 PRE_first_tail_x15_r0_body.ciS5 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh05, PRE_first_tail_x15_r0_body.cnh15, PRE_first_tail_x15_r0_body.cnn05, PRE_first_tail_x15_r0_body.cnn15, PRE_first_tail_x15_r0_body.cplo5, PRE_first_tail_x15_r0_body.ccnt5, PRE_first_tail_x15_r0_body.cnband5, PRE_first_tail_x15_r0_body.chbelow5, PRE_first_tail_x15_r0_body.chren5, PRE_first_tail_x15_r0_body.cband5, PRE_first_tail_x15_r0_body.cnh1pos5, PRE_first_tail_x15_r0_body.cnren5, PRE_first_tail_x15_r0_body.cnlow5, PRE_first_tail_x15_r0_body.cabs0a5, PRE_first_tail_x15_r0_body.cabs0b5, PRE_first_tail_x15_r0_body.ctok15, PRE_first_tail_x15_r0_body.cpend5, PRE_first_tail_x15_r0_body.cerrh5, PRE_first_tail_x15_r0_body.cfiles5, PRE_first_tail_x15_r0_body.carch5, PRE_first_tail_x15_r0_body.csizes5, PRE_first_tail_x15_r0_body.cwired5, PRE_first_tail_x15_r0_body.cfix5, clean, PRE_first_tail_x15_r0_body.fcxn5, PRE_first_tail_x15_r0_body.fcnn5, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle05, PRE_first_tail_x15_r0_body.fnk5, PRE_first_tail_x15_r0_body.ckA5, PRE_first_tail_x15_r0_body.cobjsK5, PRE_first_tail_x15_r0_body.cnodesK5, PRE_first_tail_x15_r0_body.citemsK5, PRE_first_tail_x15_r0_body.f1A5, PRE_first_tail_x15_r0_body.f1O5, PRE_first_tail_x15_r0_body.f1N5, PRE_first_tail_x15_r0_body.f1I5, PRE_first_tail_x15_r0_body.fbd5, PRE_first_tail_x15_r0_body.fincW5, PRE_first_tail_x15_r0_body.fincI5, PRE_first_tail_x15_r0_body.fincN5, PRE_first_tail_x15_r0_body.flnF5, PRE_first_tail_x15_r0_body.fh5, PRE_first_tail_x15_r0_body.fo5, PRE_first_tail_x15_r0_body.fok5, PRE_first_tail_x15_r0_body.fnd5, PRE_first_tail_x15_r0_body.fp5, PRE_first_tail_x15_r0_body.fnord5, PRE_first_tail_x15_r0_body.fi5, PRE_first_tail_x15_r0_body.fii5⟩
theorem PRE_first_tail_x15_r0_body.cnshift5 (clean : Conv.NClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P5.NL) (cl : SSt (· < 268) PRE_first_tail_x15_r0_body.cx0_5.mlx) : NShift PRE_first_tail_x15_r0_body.P5 268 PRE_first_tail_x15_r0_body.kappa5 PRE_first_tail_x15_r0_body.cx0_5 PRE_first_tail_x15_r0_body.cx1_5 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot5 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost5 (compact_a_eq PRE_first_tail_x15_r0_body.ckn05 PRE_first_tail_x15_r0_body.ckn15 PRE_first_tail_x15_r0_body.ckheap5 PRE_first_tail_x15_r0_body.ckpl5)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_5 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s57.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_5 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s57.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_5 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s57.ffi) = some PRE_first_tail_x15_r0_body.fxC_5
kernel_rfl PRE_first_tail_x15_r0_body.okrC_5 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s57.ffi) = some PRE_first_tail_x15_r0_body.krC_5
noncomputable def PRE_first_tail_x15_r0_body.fx0_5 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s59.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_5 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s59.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_5 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s59.ffi) = some PRE_first_tail_x15_r0_body.fx0_5
kernel_rfl PRE_first_tail_x15_r0_body.okr0_5 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s59.ffi) = some PRE_first_tail_x15_r0_body.kr0_5
noncomputable def PRE_first_tail_x15_r0_body.fx1_5 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s58.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_5 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s58.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_5 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s58.ffi) = some PRE_first_tail_x15_r0_body.fx1_5
kernel_rfl PRE_first_tail_x15_r0_body.okr1_5 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s58.ffi) = some PRE_first_tail_x15_r0_body.kr1_5
kernel_rfl PRE_first_tail_x15_r0_body.ff05 : PRE_first_tail_x15_r0_body.fx0_5 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_5 (PRE_first_tail_x15_r0_body.clo5.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_5.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff15 : PRE_first_tail_x15_r0_body.fx1_5 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_5 (PRE_first_tail_x15_r0_body.cwS5.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_5.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck5 : freedLB PRE_first_tail_x15_r0_body.kappa5 PRE_first_tail_x15_r0_body.cx0_5.mlx PRE_first_tail_x15_r0_body.fx0_5 PRE_first_tail_x15_r0_body.fx1_5 PRE_first_tail_x15_r0_body.clo5 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf05 : PRE_first_tail_x15_r0_body.kr0_5.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_5.flags (PRE_first_tail_x15_r0_body.clo5.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_5.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt05 : PRE_first_tail_x15_r0_body.kr0_5.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_5.targs (PRE_first_tail_x15_r0_body.clo5.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_5.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf15 : PRE_first_tail_x15_r0_body.kr1_5.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_5.flags (PRE_first_tail_x15_r0_body.cwS5.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_5.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt15 : PRE_first_tail_x15_r0_body.kr1_5.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_5.targs (PRE_first_tail_x15_r0_body.cwS5.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_5.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck5 : krecLB PRE_first_tail_x15_r0_body.kappa5 268 PRE_first_tail_x15_r0_body.cx0_5.mlx PRE_first_tail_x15_r0_body.kr0_5 PRE_first_tail_x15_r0_body.kr1_5 PRE_first_tail_x15_r0_body.clo5 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn5 : Nat.ble 268 268 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge5 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s58.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s59.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR5 : pendRegB PRE_first_tail_x15_r0_body.kappa5 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe5 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s58.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift5 (clean : Conv.NClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P5.NL) (cl : SSt (· < 268) PRE_first_tail_x15_r0_body.cx0_5.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_5.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_5.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_5.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_5.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P5 268 PRE_first_tail_x15_r0_body.kappa5 PRE_first_tail_x15_r0_body.s59.ffi PRE_first_tail_x15_r0_body.s58.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift5 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue5, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp5 t ht),
    PRE_first_tail_x15_r0_body.cbridge5,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s59.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s58.ffi) (PRE_first_tail_x15_r0_body.cfoot5 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_5 PRE_first_tail_x15_r0_body.ofx1_5 hobjC PRE_first_tail_x15_r0_body.ff05 PRE_first_tail_x15_r0_body.ff15 PRE_first_tail_x15_r0_body.ffck5,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s59.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s58.ffi) (PRE_first_tail_x15_r0_body.cfoot5 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_5 PRE_first_tail_x15_r0_body.okr1_5 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn5) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf05 PRE_first_tail_x15_r0_body.fkt05 PRE_first_tail_x15_r0_body.fkf15 PRE_first_tail_x15_r0_body.fkt15 PRE_first_tail_x15_r0_body.fkck5,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh05 PRE_first_tail_x15_r0_body.cnh15 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe5) PRE_first_tail_x15_r0_body.cpendR5⟩

end Host.Load.Run.Tpl
