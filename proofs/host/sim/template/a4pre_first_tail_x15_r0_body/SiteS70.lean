import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl70
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 70 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc70 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P70 : LoadP := PRE_first_tail_x15_r0_body.Pc70.raise 16677
kernel_rfl PRE_first_tail_x15_r0_body.craise70 : Nat.ble PRE_first_tail_x15_r0_body.Pc70.N0 16677 = true
theorem PRE_first_tail_x15_r0_body.raised70 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc70 PRE_first_tail_x15_r0_body.P70 :=
  .inr ⟨16677, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise70, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_70 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s626.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_70 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s625.ffi)
def PRE_first_tail_x15_r0_body.khinv70 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv70 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS70 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS70 : List Nat := List.range' 16677 0
def PRE_first_tail_x15_r0_body.ciS70 : List Nat := [] ++ List.range' 16677 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh070 : PRE_first_tail_x15_r0_body.kd70.nh0 = PRE_first_tail_x15_r0_body.cx0_70.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh170 : PRE_first_tail_x15_r0_body.kd70.nh1 = PRE_first_tail_x15_r0_body.cx1_70.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn070 : PRE_first_tail_x15_r0_body.kd70.nn0 = PRE_first_tail_x15_r0_body.cx0_70.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn170 : PRE_first_tail_x15_r0_body.kd70.nn1 = PRE_first_tail_x15_r0_body.cx1_70.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo70 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P70.lo && Nat.ble PRE_first_tail_x15_r0_body.P70.lo PRE_first_tail_x15_r0_body.cx0_70.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P70.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P70.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt70 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_70.mlx.next PRE_first_tail_x15_r0_body.cx1_70.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_70.mlx.nnext PRE_first_tail_x15_r0_body.cx1_70.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband70 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P70.NL && Nat.ble PRE_first_tail_x15_r0_body.P70.NL PRE_first_tail_x15_r0_body.P70.N0 && Nat.ble PRE_first_tail_x15_r0_body.P70.N0 PRE_first_tail_x15_r0_body.cx0_70.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow70 : PRE_first_tail_x15_r0_body.kd70.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren70 : checkRenG PRE_first_tail_x15_r0_body.kd70.hnd PRE_first_tail_x15_r0_body.khinv70 (phB PRE_first_tail_x15_r0_body.cx0_70.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband70 : PRE_first_tail_x15_r0_body.kd70.checkBand PRE_first_tail_x15_r0_body.P70.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos70 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd70.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren70 : checkRenG PRE_first_tail_x15_r0_body.kd70.node PRE_first_tail_x15_r0_body.kninv70 (pnB PRE_first_tail_x15_r0_body.cx0_70.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P70.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd70.nodeF j) PRE_first_tail_x15_r0_body.cx1_70.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a70 : PRE_first_tail_x15_r0_body.cx0_70.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b70 : PRE_first_tail_x15_r0_body.cx0_70.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok170 : PRE_first_tail_x15_r0_body.cx1_70.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.pending = PRE_first_tail_x15_r0_body.cx0_70.mlx.pending.map PRE_first_tail_x15_r0_body.kappa70.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.errh = PRE_first_tail_x15_r0_body.cx0_70.mlx.errh.map PRE_first_tail_x15_r0_body.kappa70.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.files = PRE_first_tail_x15_r0_body.cx0_70.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.arch = PRE_first_tail_x15_r0_body.cx0_70.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_70.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.wired = PRE_first_tail_x15_r0_body.cx0_70.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost70 : PRE_first_tail_x15_r0_body.cx1_70.host = PRE_first_tail_x15_r0_body.cx0_70.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd70`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn070 : PRE_first_tail_x15_r0_body.kd70.n0 = 2730177
kernel_rfl PRE_first_tail_x15_r0_body.ckn170 : PRE_first_tail_x15_r0_body.kd70.n1 = 2730179
kernel_rfl PRE_first_tail_x15_r0_body.ckheap70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.heap).all (fun x => Nat.ble 2730177 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl70 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd70.heap.get (2730177 + j) = nth? PRE_first_tail_x15_r0_body.pl70 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja70 : Nat.ble 2730177 2730177 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn70 : Nat.ble 3071 3071 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD70 : Nat.ble 2730177 PRE_first_tail_x15_r0_body.kd70.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn70 : Nat.ble 19590 PRE_first_tail_x15_r0_body.kd70.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn70 : Nat.ble 16677 PRE_first_tail_x15_r0_body.kd70.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb70 : Nat.ble 19590 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.heap).all (Nat.ble (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.hnd).all (Nat.ble (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.node).all (Nat.ble (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix70 : Conv.FixOld (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa70 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja70) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn70) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD70) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn70) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn70) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb70) PRE_first_tail_x15_r0_body.fheap70 PRE_first_tail_x15_r0_body.fhnd70 PRE_first_tail_x15_r0_body.fnode70
kernel_rfl PRE_first_tail_x15_r0_body.fcxn70 : (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn70 : (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle070 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_70.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_70.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS70.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_70.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS70.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_70.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS70.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_70.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS70.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_70.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd70 : (PRE_first_tail_x15_r0_body.clo70 ++ PRE_first_tail_x15_r0_body.cln70 ++ PRE_first_tail_x15_r0_body.cli70 ++ PRE_first_tail_x15_r0_body.cwS70 ++ PRE_first_tail_x15_r0_body.cnS70 ++ PRE_first_tail_x15_r0_body.ciS70).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW70 : PRE_first_tail_x15_r0_body.cwS70.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo70.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI70 : PRE_first_tail_x15_r0_body.ciS70.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli70.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN70 : PRE_first_tail_x15_r0_body.cnS70.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF70 : PRE_first_tail_x15_r0_body.cln70.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh70 : PRE_first_tail_x15_r0_body.clo70.all (handleOK PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.P70.lo PRE_first_tail_x15_r0_body.cx0_70.mlx PRE_first_tail_x15_r0_body.cx1_70.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo70 : PRE_first_tail_x15_r0_body.clo70.map (fun h => PRE_first_tail_x15_r0_body.cx1_70.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa70.handle h)) = PRE_first_tail_x15_r0_body.clo70.map (fun h => (PRE_first_tail_x15_r0_body.cx0_70.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa70.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok70 : PRE_first_tail_x15_r0_body.clo70.all (objOK PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.P70.NL PRE_first_tail_x15_r0_body.cx0_70.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd70 : PRE_first_tail_x15_r0_body.cln70.all (nodeOKF PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.P70 PRE_first_tail_x15_r0_body.cx0_70.mlx PRE_first_tail_x15_r0_body.cx1_70.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp70 : ((PRE_first_tail_x15_r0_body.cln70.filter (fullB PRE_first_tail_x15_r0_body.P70))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_70.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa70.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln70.filter (fullB PRE_first_tail_x15_r0_body.P70))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_70.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa70.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI70 : incrB PRE_first_tail_x15_r0_body.kd70.nodeF (List.range' 16677 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.node).all (fun k => Nat.ble 16677 k && Nat.blt k 16677) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL70 : (PRE_first_tail_x15_r0_body.cln70.filter (Nat.ble PRE_first_tail_x15_r0_body.P70.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd70.nodeF i) && (Nat.blt i 16677 || Nat.ble PRE_first_tail_x15_r0_body.kd70.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord70 : (PRE_first_tail_x15_r0_body.cln70.filter (Nat.ble PRE_first_tail_x15_r0_body.P70.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd70.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd70.nodeF j) (PRE_first_tail_x15_r0_body.kd70.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow70 PRE_first_tail_x15_r0_body.cnn170 PRE_first_tail_x15_r0_body.fnordI70 PRE_first_tail_x15_r0_body.fnordK70 PRE_first_tail_x15_r0_body.fnordL70
kernel_rfl PRE_first_tail_x15_r0_body.fi70 : PRE_first_tail_x15_r0_body.cli70.all (pnB PRE_first_tail_x15_r0_body.cx0_70.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii70 : PRE_first_tail_x15_r0_body.cli70.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_70.mlx.items.get (PRE_first_tail_x15_r0_body.kappa70.node k) = (PRE_first_tail_x15_r0_body.cx0_70.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa70.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot70 (clean : Conv.NClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P70.NL) (cl : SSt (· < 3071) PRE_first_tail_x15_r0_body.cx0_70.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P70 3071 PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.kd70 PRE_first_tail_x15_r0_body.khinv70 PRE_first_tail_x15_r0_body.kninv70 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx PRE_first_tail_x15_r0_body.cx0_70.mlx PRE_first_tail_x15_r0_body.cx1_70.mlx (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo70 PRE_first_tail_x15_r0_body.cln70 PRE_first_tail_x15_r0_body.cli70 PRE_first_tail_x15_r0_body.cwS70 PRE_first_tail_x15_r0_body.cnS70 PRE_first_tail_x15_r0_body.ciS70 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh070, PRE_first_tail_x15_r0_body.cnh170, PRE_first_tail_x15_r0_body.cnn070, PRE_first_tail_x15_r0_body.cnn170, PRE_first_tail_x15_r0_body.cplo70, PRE_first_tail_x15_r0_body.ccnt70, PRE_first_tail_x15_r0_body.cnband70, PRE_first_tail_x15_r0_body.chbelow70, PRE_first_tail_x15_r0_body.chren70, PRE_first_tail_x15_r0_body.cband70, PRE_first_tail_x15_r0_body.cnh1pos70, PRE_first_tail_x15_r0_body.cnren70, PRE_first_tail_x15_r0_body.cnlow70, PRE_first_tail_x15_r0_body.cabs0a70, PRE_first_tail_x15_r0_body.cabs0b70, PRE_first_tail_x15_r0_body.ctok170, PRE_first_tail_x15_r0_body.cpend70, PRE_first_tail_x15_r0_body.cerrh70, PRE_first_tail_x15_r0_body.cfiles70, PRE_first_tail_x15_r0_body.carch70, PRE_first_tail_x15_r0_body.csizes70, PRE_first_tail_x15_r0_body.cwired70, PRE_first_tail_x15_r0_body.cfix70, clean, PRE_first_tail_x15_r0_body.fcxn70, PRE_first_tail_x15_r0_body.fcnn70, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle070, PRE_first_tail_x15_r0_body.fnk70, PRE_first_tail_x15_r0_body.ckA70, PRE_first_tail_x15_r0_body.cobjsK70, PRE_first_tail_x15_r0_body.cnodesK70, PRE_first_tail_x15_r0_body.citemsK70, PRE_first_tail_x15_r0_body.f1A70, PRE_first_tail_x15_r0_body.f1O70, PRE_first_tail_x15_r0_body.f1N70, PRE_first_tail_x15_r0_body.f1I70, PRE_first_tail_x15_r0_body.fbd70, PRE_first_tail_x15_r0_body.fincW70, PRE_first_tail_x15_r0_body.fincI70, PRE_first_tail_x15_r0_body.fincN70, PRE_first_tail_x15_r0_body.flnF70, PRE_first_tail_x15_r0_body.fh70, PRE_first_tail_x15_r0_body.fo70, PRE_first_tail_x15_r0_body.fok70, PRE_first_tail_x15_r0_body.fnd70, PRE_first_tail_x15_r0_body.fp70, PRE_first_tail_x15_r0_body.fnord70, PRE_first_tail_x15_r0_body.fi70, PRE_first_tail_x15_r0_body.fii70⟩
theorem PRE_first_tail_x15_r0_body.cnshift70 (clean : Conv.NClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P70.NL) (cl : SSt (· < 3071) PRE_first_tail_x15_r0_body.cx0_70.mlx) : NShift PRE_first_tail_x15_r0_body.P70 3071 PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.cx0_70 PRE_first_tail_x15_r0_body.cx1_70 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot70 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost70 (compact_a_eq PRE_first_tail_x15_r0_body.ckn070 PRE_first_tail_x15_r0_body.ckn170 PRE_first_tail_x15_r0_body.ckheap70 PRE_first_tail_x15_r0_body.ckpl70)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_70 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s624.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_70 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s624.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_70 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s624.ffi) = some PRE_first_tail_x15_r0_body.fxC_70
kernel_rfl PRE_first_tail_x15_r0_body.okrC_70 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s624.ffi) = some PRE_first_tail_x15_r0_body.krC_70
noncomputable def PRE_first_tail_x15_r0_body.fx0_70 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s626.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_70 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s626.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_70 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s626.ffi) = some PRE_first_tail_x15_r0_body.fx0_70
kernel_rfl PRE_first_tail_x15_r0_body.okr0_70 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s626.ffi) = some PRE_first_tail_x15_r0_body.kr0_70
noncomputable def PRE_first_tail_x15_r0_body.fx1_70 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s625.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_70 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s625.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_70 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s625.ffi) = some PRE_first_tail_x15_r0_body.fx1_70
kernel_rfl PRE_first_tail_x15_r0_body.okr1_70 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s625.ffi) = some PRE_first_tail_x15_r0_body.kr1_70
kernel_rfl PRE_first_tail_x15_r0_body.ff070 : PRE_first_tail_x15_r0_body.fx0_70 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_70 (PRE_first_tail_x15_r0_body.clo70.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_70.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff170 : PRE_first_tail_x15_r0_body.fx1_70 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_70 (PRE_first_tail_x15_r0_body.cwS70.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_70.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck70 : freedLB PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.cx0_70.mlx PRE_first_tail_x15_r0_body.fx0_70 PRE_first_tail_x15_r0_body.fx1_70 PRE_first_tail_x15_r0_body.clo70 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf070 : PRE_first_tail_x15_r0_body.kr0_70.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_70.flags (PRE_first_tail_x15_r0_body.clo70.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_70.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt070 : PRE_first_tail_x15_r0_body.kr0_70.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_70.targs (PRE_first_tail_x15_r0_body.clo70.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_70.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf170 : PRE_first_tail_x15_r0_body.kr1_70.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_70.flags (PRE_first_tail_x15_r0_body.cwS70.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_70.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt170 : PRE_first_tail_x15_r0_body.kr1_70.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_70.targs (PRE_first_tail_x15_r0_body.cwS70.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_70.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck70 : krecLB PRE_first_tail_x15_r0_body.kappa70 3071 PRE_first_tail_x15_r0_body.cx0_70.mlx PRE_first_tail_x15_r0_body.kr0_70 PRE_first_tail_x15_r0_body.kr1_70 PRE_first_tail_x15_r0_body.clo70 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn70 : Nat.ble 3071 3071 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge70 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s625.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s626.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR70 : pendRegB PRE_first_tail_x15_r0_body.kappa70 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s626.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe70 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s626.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s625.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift70 (clean : Conv.NClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P70.NL) (cl : SSt (· < 3071) PRE_first_tail_x15_r0_body.cx0_70.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_70.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_70.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_70.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s624.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_70.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P70 3071 PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.s626.ffi PRE_first_tail_x15_r0_body.s625.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift70 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue70, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp70 t ht),
    PRE_first_tail_x15_r0_body.cbridge70,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s626.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s625.ffi) (PRE_first_tail_x15_r0_body.cfoot70 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_70 PRE_first_tail_x15_r0_body.ofx1_70 hobjC PRE_first_tail_x15_r0_body.ff070 PRE_first_tail_x15_r0_body.ff170 PRE_first_tail_x15_r0_body.ffck70,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s626.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s625.ffi) (PRE_first_tail_x15_r0_body.cfoot70 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_70 PRE_first_tail_x15_r0_body.okr1_70 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn70) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf070 PRE_first_tail_x15_r0_body.fkt070 PRE_first_tail_x15_r0_body.fkf170 PRE_first_tail_x15_r0_body.fkt170 PRE_first_tail_x15_r0_body.fkck70,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh070 PRE_first_tail_x15_r0_body.cnh170 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe70) PRE_first_tail_x15_r0_body.cpendR70⟩

end Host.Load.Run.Tpl
