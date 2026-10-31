import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl11
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 11 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc11 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P11 : LoadP := PRE_first_tail_x15_r0_body.Pc11.raise 15496
kernel_rfl PRE_first_tail_x15_r0_body.craise11 : Nat.ble PRE_first_tail_x15_r0_body.Pc11.N0 15496 = true
theorem PRE_first_tail_x15_r0_body.raised11 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc11 PRE_first_tail_x15_r0_body.P11 :=
  .inr ⟨15496, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise11, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_11 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_11 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s115.ffi)
def PRE_first_tail_x15_r0_body.khinv11 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv11 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS11 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS11 : List Nat := List.range' 15496 0
def PRE_first_tail_x15_r0_body.ciS11 : List Nat := [] ++ List.range' 15496 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh011 : PRE_first_tail_x15_r0_body.kd11.nh0 = PRE_first_tail_x15_r0_body.cx0_11.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh111 : PRE_first_tail_x15_r0_body.kd11.nh1 = PRE_first_tail_x15_r0_body.cx1_11.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn011 : PRE_first_tail_x15_r0_body.kd11.nn0 = PRE_first_tail_x15_r0_body.cx0_11.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn111 : PRE_first_tail_x15_r0_body.kd11.nn1 = PRE_first_tail_x15_r0_body.cx1_11.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo11 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P11.lo && Nat.ble PRE_first_tail_x15_r0_body.P11.lo PRE_first_tail_x15_r0_body.cx0_11.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P11.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P11.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt11 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_11.mlx.next PRE_first_tail_x15_r0_body.cx1_11.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_11.mlx.nnext PRE_first_tail_x15_r0_body.cx1_11.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband11 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P11.NL && Nat.ble PRE_first_tail_x15_r0_body.P11.NL PRE_first_tail_x15_r0_body.P11.N0 && Nat.ble PRE_first_tail_x15_r0_body.P11.N0 PRE_first_tail_x15_r0_body.cx0_11.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow11 : PRE_first_tail_x15_r0_body.kd11.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren11 : checkRenG PRE_first_tail_x15_r0_body.kd11.hnd PRE_first_tail_x15_r0_body.khinv11 (phB PRE_first_tail_x15_r0_body.cx0_11.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband11 : PRE_first_tail_x15_r0_body.kd11.checkBand PRE_first_tail_x15_r0_body.P11.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos11 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd11.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren11 : checkRenG PRE_first_tail_x15_r0_body.kd11.node PRE_first_tail_x15_r0_body.kninv11 (pnB PRE_first_tail_x15_r0_body.cx0_11.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow11 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd11.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P11.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd11.nodeF j) PRE_first_tail_x15_r0_body.cx1_11.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a11 : PRE_first_tail_x15_r0_body.cx0_11.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b11 : PRE_first_tail_x15_r0_body.cx0_11.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok111 : PRE_first_tail_x15_r0_body.cx1_11.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend11 : PRE_first_tail_x15_r0_body.cx1_11.mlx.pending = PRE_first_tail_x15_r0_body.cx0_11.mlx.pending.map PRE_first_tail_x15_r0_body.kappa11.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh11 : PRE_first_tail_x15_r0_body.cx1_11.mlx.errh = PRE_first_tail_x15_r0_body.cx0_11.mlx.errh.map PRE_first_tail_x15_r0_body.kappa11.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles11 : PRE_first_tail_x15_r0_body.cx1_11.mlx.files = PRE_first_tail_x15_r0_body.cx0_11.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch11 : PRE_first_tail_x15_r0_body.cx1_11.mlx.arch = PRE_first_tail_x15_r0_body.cx0_11.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes11 : PRE_first_tail_x15_r0_body.cx1_11.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_11.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired11 : PRE_first_tail_x15_r0_body.cx1_11.mlx.wired = PRE_first_tail_x15_r0_body.cx0_11.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost11 : PRE_first_tail_x15_r0_body.cx1_11.host = PRE_first_tail_x15_r0_body.cx0_11.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd11`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn011 : PRE_first_tail_x15_r0_body.kd11.n0 = 2683382
kernel_rfl PRE_first_tail_x15_r0_body.ckn111 : PRE_first_tail_x15_r0_body.kd11.n1 = 2683392
kernel_rfl PRE_first_tail_x15_r0_body.ckheap11 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd11.heap).all (fun x => Nat.ble 2683381 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl11 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd11.heap.get (2683381 + j) = nth? PRE_first_tail_x15_r0_body.pl11 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja11 : Nat.ble 2683381 2683381 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn11 : Nat.ble 523 523 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD11 : Nat.ble 2683381 PRE_first_tail_x15_r0_body.kd11.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn11 : Nat.ble 18417 PRE_first_tail_x15_r0_body.kd11.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn11 : Nat.ble 15496 PRE_first_tail_x15_r0_body.kd11.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb11 : Nat.ble 18417 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap11 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd11.heap).all (Nat.ble (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd11 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd11.hnd).all (Nat.ble (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode11 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd11.node).all (Nat.ble (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix11 : Conv.FixOld (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa11 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja11) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn11) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD11) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn11) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn11) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb11) PRE_first_tail_x15_r0_body.fheap11 PRE_first_tail_x15_r0_body.fhnd11 PRE_first_tail_x15_r0_body.fnode11
kernel_rfl PRE_first_tail_x15_r0_body.fcxn11 : (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn11 : (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle011 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_11.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_11.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk11 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd11.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A11 : PRE_first_tail_x15_r0_body.cx1_11.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS11.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_11.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O11 : PRE_first_tail_x15_r0_body.cx1_11.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS11.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_11.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N11 : PRE_first_tail_x15_r0_body.cx1_11.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS11.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_11.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I11 : PRE_first_tail_x15_r0_body.cx1_11.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS11.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_11.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd11 : (PRE_first_tail_x15_r0_body.clo11 ++ PRE_first_tail_x15_r0_body.cln11 ++ PRE_first_tail_x15_r0_body.cli11 ++ PRE_first_tail_x15_r0_body.cwS11 ++ PRE_first_tail_x15_r0_body.cnS11 ++ PRE_first_tail_x15_r0_body.ciS11).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW11 : PRE_first_tail_x15_r0_body.cwS11.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo11.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI11 : PRE_first_tail_x15_r0_body.ciS11.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli11.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN11 : PRE_first_tail_x15_r0_body.cnS11.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF11 : PRE_first_tail_x15_r0_body.cln11.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh11 : PRE_first_tail_x15_r0_body.clo11.all (handleOK PRE_first_tail_x15_r0_body.kappa11 PRE_first_tail_x15_r0_body.P11.lo PRE_first_tail_x15_r0_body.cx0_11.mlx PRE_first_tail_x15_r0_body.cx1_11.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo11 : PRE_first_tail_x15_r0_body.clo11.map (fun h => PRE_first_tail_x15_r0_body.cx1_11.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa11.handle h)) = PRE_first_tail_x15_r0_body.clo11.map (fun h => (PRE_first_tail_x15_r0_body.cx0_11.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa11.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok11 : PRE_first_tail_x15_r0_body.clo11.all (objOK PRE_first_tail_x15_r0_body.kappa11 PRE_first_tail_x15_r0_body.P11.NL PRE_first_tail_x15_r0_body.cx0_11.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd11 : PRE_first_tail_x15_r0_body.cln11.all (nodeOKF PRE_first_tail_x15_r0_body.kappa11 PRE_first_tail_x15_r0_body.P11 PRE_first_tail_x15_r0_body.cx0_11.mlx PRE_first_tail_x15_r0_body.cx1_11.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp11 : ((PRE_first_tail_x15_r0_body.cln11.filter (fullB PRE_first_tail_x15_r0_body.P11))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_11.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa11.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln11.filter (fullB PRE_first_tail_x15_r0_body.P11))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_11.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa11.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI11 : incrB PRE_first_tail_x15_r0_body.kd11.nodeF (List.range' 15496 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK11 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd11.node).all (fun k => Nat.ble 15496 k && Nat.blt k 15496) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL11 : (PRE_first_tail_x15_r0_body.cln11.filter (Nat.ble PRE_first_tail_x15_r0_body.P11.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd11.nodeF i) && (Nat.blt i 15496 || Nat.ble PRE_first_tail_x15_r0_body.kd11.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord11 : (PRE_first_tail_x15_r0_body.cln11.filter (Nat.ble PRE_first_tail_x15_r0_body.P11.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd11.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd11.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd11.nodeF j) (PRE_first_tail_x15_r0_body.kd11.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow11 PRE_first_tail_x15_r0_body.cnn111 PRE_first_tail_x15_r0_body.fnordI11 PRE_first_tail_x15_r0_body.fnordK11 PRE_first_tail_x15_r0_body.fnordL11
kernel_rfl PRE_first_tail_x15_r0_body.fi11 : PRE_first_tail_x15_r0_body.cli11.all (pnB PRE_first_tail_x15_r0_body.cx0_11.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii11 : PRE_first_tail_x15_r0_body.cli11.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_11.mlx.items.get (PRE_first_tail_x15_r0_body.kappa11.node k) = (PRE_first_tail_x15_r0_body.cx0_11.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa11.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot11 (clean : Conv.NClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P11.NL) (cl : SSt (· < 523) PRE_first_tail_x15_r0_body.cx0_11.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P11 523 PRE_first_tail_x15_r0_body.kappa11 PRE_first_tail_x15_r0_body.kd11 PRE_first_tail_x15_r0_body.khinv11 PRE_first_tail_x15_r0_body.kninv11 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx PRE_first_tail_x15_r0_body.cx0_11.mlx PRE_first_tail_x15_r0_body.cx1_11.mlx (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo11 PRE_first_tail_x15_r0_body.cln11 PRE_first_tail_x15_r0_body.cli11 PRE_first_tail_x15_r0_body.cwS11 PRE_first_tail_x15_r0_body.cnS11 PRE_first_tail_x15_r0_body.ciS11 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh011, PRE_first_tail_x15_r0_body.cnh111, PRE_first_tail_x15_r0_body.cnn011, PRE_first_tail_x15_r0_body.cnn111, PRE_first_tail_x15_r0_body.cplo11, PRE_first_tail_x15_r0_body.ccnt11, PRE_first_tail_x15_r0_body.cnband11, PRE_first_tail_x15_r0_body.chbelow11, PRE_first_tail_x15_r0_body.chren11, PRE_first_tail_x15_r0_body.cband11, PRE_first_tail_x15_r0_body.cnh1pos11, PRE_first_tail_x15_r0_body.cnren11, PRE_first_tail_x15_r0_body.cnlow11, PRE_first_tail_x15_r0_body.cabs0a11, PRE_first_tail_x15_r0_body.cabs0b11, PRE_first_tail_x15_r0_body.ctok111, PRE_first_tail_x15_r0_body.cpend11, PRE_first_tail_x15_r0_body.cerrh11, PRE_first_tail_x15_r0_body.cfiles11, PRE_first_tail_x15_r0_body.carch11, PRE_first_tail_x15_r0_body.csizes11, PRE_first_tail_x15_r0_body.cwired11, PRE_first_tail_x15_r0_body.cfix11, clean, PRE_first_tail_x15_r0_body.fcxn11, PRE_first_tail_x15_r0_body.fcnn11, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle011, PRE_first_tail_x15_r0_body.fnk11, PRE_first_tail_x15_r0_body.ckA11, PRE_first_tail_x15_r0_body.cobjsK11, PRE_first_tail_x15_r0_body.cnodesK11, PRE_first_tail_x15_r0_body.citemsK11, PRE_first_tail_x15_r0_body.f1A11, PRE_first_tail_x15_r0_body.f1O11, PRE_first_tail_x15_r0_body.f1N11, PRE_first_tail_x15_r0_body.f1I11, PRE_first_tail_x15_r0_body.fbd11, PRE_first_tail_x15_r0_body.fincW11, PRE_first_tail_x15_r0_body.fincI11, PRE_first_tail_x15_r0_body.fincN11, PRE_first_tail_x15_r0_body.flnF11, PRE_first_tail_x15_r0_body.fh11, PRE_first_tail_x15_r0_body.fo11, PRE_first_tail_x15_r0_body.fok11, PRE_first_tail_x15_r0_body.fnd11, PRE_first_tail_x15_r0_body.fp11, PRE_first_tail_x15_r0_body.fnord11, PRE_first_tail_x15_r0_body.fi11, PRE_first_tail_x15_r0_body.fii11⟩
theorem PRE_first_tail_x15_r0_body.cnshift11 (clean : Conv.NClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P11.NL) (cl : SSt (· < 523) PRE_first_tail_x15_r0_body.cx0_11.mlx) : NShift PRE_first_tail_x15_r0_body.P11 523 PRE_first_tail_x15_r0_body.kappa11 PRE_first_tail_x15_r0_body.cx0_11 PRE_first_tail_x15_r0_body.cx1_11 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot11 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost11 (compact_a_eq PRE_first_tail_x15_r0_body.ckn011 PRE_first_tail_x15_r0_body.ckn111 PRE_first_tail_x15_r0_body.ckheap11 PRE_first_tail_x15_r0_body.ckpl11)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_11 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s114.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_11 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s114.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_11 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s114.ffi) = some PRE_first_tail_x15_r0_body.fxC_11
kernel_rfl PRE_first_tail_x15_r0_body.okrC_11 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s114.ffi) = some PRE_first_tail_x15_r0_body.krC_11
noncomputable def PRE_first_tail_x15_r0_body.fx0_11 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s116.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_11 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s116.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_11 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s116.ffi) = some PRE_first_tail_x15_r0_body.fx0_11
kernel_rfl PRE_first_tail_x15_r0_body.okr0_11 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s116.ffi) = some PRE_first_tail_x15_r0_body.kr0_11
noncomputable def PRE_first_tail_x15_r0_body.fx1_11 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s115.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_11 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s115.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_11 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s115.ffi) = some PRE_first_tail_x15_r0_body.fx1_11
kernel_rfl PRE_first_tail_x15_r0_body.okr1_11 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s115.ffi) = some PRE_first_tail_x15_r0_body.kr1_11
kernel_rfl PRE_first_tail_x15_r0_body.ff011 : PRE_first_tail_x15_r0_body.fx0_11 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_11 (PRE_first_tail_x15_r0_body.clo11.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_11.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff111 : PRE_first_tail_x15_r0_body.fx1_11 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_11 (PRE_first_tail_x15_r0_body.cwS11.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_11.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck11 : freedLB PRE_first_tail_x15_r0_body.kappa11 PRE_first_tail_x15_r0_body.cx0_11.mlx PRE_first_tail_x15_r0_body.fx0_11 PRE_first_tail_x15_r0_body.fx1_11 PRE_first_tail_x15_r0_body.clo11 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf011 : PRE_first_tail_x15_r0_body.kr0_11.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_11.flags (PRE_first_tail_x15_r0_body.clo11.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_11.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt011 : PRE_first_tail_x15_r0_body.kr0_11.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_11.targs (PRE_first_tail_x15_r0_body.clo11.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_11.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf111 : PRE_first_tail_x15_r0_body.kr1_11.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_11.flags (PRE_first_tail_x15_r0_body.cwS11.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_11.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt111 : PRE_first_tail_x15_r0_body.kr1_11.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_11.targs (PRE_first_tail_x15_r0_body.cwS11.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_11.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck11 : krecLB PRE_first_tail_x15_r0_body.kappa11 523 PRE_first_tail_x15_r0_body.cx0_11.mlx PRE_first_tail_x15_r0_body.kr0_11 PRE_first_tail_x15_r0_body.kr1_11 PRE_first_tail_x15_r0_body.clo11 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn11 : Nat.ble 523 523 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge11 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s115.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s116.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR11 : pendRegB PRE_first_tail_x15_r0_body.kappa11 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe11 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s115.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift11 (clean : Conv.NClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P11.NL) (cl : SSt (· < 523) PRE_first_tail_x15_r0_body.cx0_11.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_11.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_11.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_11.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_11.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P11 523 PRE_first_tail_x15_r0_body.kappa11 PRE_first_tail_x15_r0_body.s116.ffi PRE_first_tail_x15_r0_body.s115.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift11 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue11, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp11 t ht),
    PRE_first_tail_x15_r0_body.cbridge11,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s116.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s115.ffi) (PRE_first_tail_x15_r0_body.cfoot11 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_11 PRE_first_tail_x15_r0_body.ofx1_11 hobjC PRE_first_tail_x15_r0_body.ff011 PRE_first_tail_x15_r0_body.ff111 PRE_first_tail_x15_r0_body.ffck11,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s116.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s115.ffi) (PRE_first_tail_x15_r0_body.cfoot11 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_11 PRE_first_tail_x15_r0_body.okr1_11 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn11) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf011 PRE_first_tail_x15_r0_body.fkt011 PRE_first_tail_x15_r0_body.fkf111 PRE_first_tail_x15_r0_body.fkt111 PRE_first_tail_x15_r0_body.fkck11,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh011 PRE_first_tail_x15_r0_body.cnh111 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe11) PRE_first_tail_x15_r0_body.cpendR11⟩

end Host.Load.Run.Tpl
