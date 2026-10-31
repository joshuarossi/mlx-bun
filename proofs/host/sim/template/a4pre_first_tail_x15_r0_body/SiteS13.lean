import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl13
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 13 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc13 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P13 : LoadP := PRE_first_tail_x15_r0_body.Pc13.raise 15555
kernel_rfl PRE_first_tail_x15_r0_body.craise13 : Nat.ble PRE_first_tail_x15_r0_body.Pc13.N0 15555 = true
theorem PRE_first_tail_x15_r0_body.raised13 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc13 PRE_first_tail_x15_r0_body.P13 :=
  .inr ⟨15555, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise13, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_13 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s128.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_13 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s127.ffi)
def PRE_first_tail_x15_r0_body.khinv13 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv13 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS13 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS13 : List Nat := List.range' 15555 0
def PRE_first_tail_x15_r0_body.ciS13 : List Nat := [] ++ List.range' 15555 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh013 : PRE_first_tail_x15_r0_body.kd13.nh0 = PRE_first_tail_x15_r0_body.cx0_13.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh113 : PRE_first_tail_x15_r0_body.kd13.nh1 = PRE_first_tail_x15_r0_body.cx1_13.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn013 : PRE_first_tail_x15_r0_body.kd13.nn0 = PRE_first_tail_x15_r0_body.cx0_13.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn113 : PRE_first_tail_x15_r0_body.kd13.nn1 = PRE_first_tail_x15_r0_body.cx1_13.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo13 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P13.lo && Nat.ble PRE_first_tail_x15_r0_body.P13.lo PRE_first_tail_x15_r0_body.cx0_13.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P13.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P13.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt13 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_13.mlx.next PRE_first_tail_x15_r0_body.cx1_13.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_13.mlx.nnext PRE_first_tail_x15_r0_body.cx1_13.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband13 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P13.NL && Nat.ble PRE_first_tail_x15_r0_body.P13.NL PRE_first_tail_x15_r0_body.P13.N0 && Nat.ble PRE_first_tail_x15_r0_body.P13.N0 PRE_first_tail_x15_r0_body.cx0_13.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow13 : PRE_first_tail_x15_r0_body.kd13.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren13 : checkRenG PRE_first_tail_x15_r0_body.kd13.hnd PRE_first_tail_x15_r0_body.khinv13 (phB PRE_first_tail_x15_r0_body.cx0_13.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband13 : PRE_first_tail_x15_r0_body.kd13.checkBand PRE_first_tail_x15_r0_body.P13.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos13 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd13.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren13 : checkRenG PRE_first_tail_x15_r0_body.kd13.node PRE_first_tail_x15_r0_body.kninv13 (pnB PRE_first_tail_x15_r0_body.cx0_13.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow13 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd13.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P13.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd13.nodeF j) PRE_first_tail_x15_r0_body.cx1_13.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a13 : PRE_first_tail_x15_r0_body.cx0_13.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b13 : PRE_first_tail_x15_r0_body.cx0_13.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok113 : PRE_first_tail_x15_r0_body.cx1_13.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend13 : PRE_first_tail_x15_r0_body.cx1_13.mlx.pending = PRE_first_tail_x15_r0_body.cx0_13.mlx.pending.map PRE_first_tail_x15_r0_body.kappa13.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh13 : PRE_first_tail_x15_r0_body.cx1_13.mlx.errh = PRE_first_tail_x15_r0_body.cx0_13.mlx.errh.map PRE_first_tail_x15_r0_body.kappa13.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles13 : PRE_first_tail_x15_r0_body.cx1_13.mlx.files = PRE_first_tail_x15_r0_body.cx0_13.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch13 : PRE_first_tail_x15_r0_body.cx1_13.mlx.arch = PRE_first_tail_x15_r0_body.cx0_13.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes13 : PRE_first_tail_x15_r0_body.cx1_13.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_13.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired13 : PRE_first_tail_x15_r0_body.cx1_13.mlx.wired = PRE_first_tail_x15_r0_body.cx0_13.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost13 : PRE_first_tail_x15_r0_body.cx1_13.host = PRE_first_tail_x15_r0_body.cx0_13.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd13`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn013 : PRE_first_tail_x15_r0_body.kd13.n0 = 2685371
kernel_rfl PRE_first_tail_x15_r0_body.ckn113 : PRE_first_tail_x15_r0_body.kd13.n1 = 2685373
kernel_rfl PRE_first_tail_x15_r0_body.ckheap13 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd13.heap).all (fun x => Nat.ble 2685371 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl13 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd13.heap.get (2685371 + j) = nth? PRE_first_tail_x15_r0_body.pl13 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja13 : Nat.ble 2685371 2685371 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn13 : Nat.ble 635 635 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD13 : Nat.ble 2685371 PRE_first_tail_x15_r0_body.kd13.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn13 : Nat.ble 18468 PRE_first_tail_x15_r0_body.kd13.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn13 : Nat.ble 15555 PRE_first_tail_x15_r0_body.kd13.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb13 : Nat.ble 18468 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap13 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd13.heap).all (Nat.ble (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd13 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd13.hnd).all (Nat.ble (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode13 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd13.node).all (Nat.ble (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix13 : Conv.FixOld (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa13 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja13) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn13) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD13) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn13) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn13) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb13) PRE_first_tail_x15_r0_body.fheap13 PRE_first_tail_x15_r0_body.fhnd13 PRE_first_tail_x15_r0_body.fnode13
kernel_rfl PRE_first_tail_x15_r0_body.fcxn13 : (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn13 : (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle013 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_13.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_13.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk13 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd13.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A13 : PRE_first_tail_x15_r0_body.cx1_13.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS13.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_13.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O13 : PRE_first_tail_x15_r0_body.cx1_13.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS13.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_13.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N13 : PRE_first_tail_x15_r0_body.cx1_13.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS13.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_13.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I13 : PRE_first_tail_x15_r0_body.cx1_13.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS13.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_13.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd13 : (PRE_first_tail_x15_r0_body.clo13 ++ PRE_first_tail_x15_r0_body.cln13 ++ PRE_first_tail_x15_r0_body.cli13 ++ PRE_first_tail_x15_r0_body.cwS13 ++ PRE_first_tail_x15_r0_body.cnS13 ++ PRE_first_tail_x15_r0_body.ciS13).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW13 : PRE_first_tail_x15_r0_body.cwS13.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo13.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI13 : PRE_first_tail_x15_r0_body.ciS13.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli13.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN13 : PRE_first_tail_x15_r0_body.cnS13.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF13 : PRE_first_tail_x15_r0_body.cln13.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh13 : PRE_first_tail_x15_r0_body.clo13.all (handleOK PRE_first_tail_x15_r0_body.kappa13 PRE_first_tail_x15_r0_body.P13.lo PRE_first_tail_x15_r0_body.cx0_13.mlx PRE_first_tail_x15_r0_body.cx1_13.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo13 : PRE_first_tail_x15_r0_body.clo13.map (fun h => PRE_first_tail_x15_r0_body.cx1_13.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa13.handle h)) = PRE_first_tail_x15_r0_body.clo13.map (fun h => (PRE_first_tail_x15_r0_body.cx0_13.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa13.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok13 : PRE_first_tail_x15_r0_body.clo13.all (objOK PRE_first_tail_x15_r0_body.kappa13 PRE_first_tail_x15_r0_body.P13.NL PRE_first_tail_x15_r0_body.cx0_13.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd13 : PRE_first_tail_x15_r0_body.cln13.all (nodeOKF PRE_first_tail_x15_r0_body.kappa13 PRE_first_tail_x15_r0_body.P13 PRE_first_tail_x15_r0_body.cx0_13.mlx PRE_first_tail_x15_r0_body.cx1_13.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp13 : ((PRE_first_tail_x15_r0_body.cln13.filter (fullB PRE_first_tail_x15_r0_body.P13))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_13.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa13.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln13.filter (fullB PRE_first_tail_x15_r0_body.P13))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_13.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa13.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI13 : incrB PRE_first_tail_x15_r0_body.kd13.nodeF (List.range' 15555 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK13 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd13.node).all (fun k => Nat.ble 15555 k && Nat.blt k 15555) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL13 : (PRE_first_tail_x15_r0_body.cln13.filter (Nat.ble PRE_first_tail_x15_r0_body.P13.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd13.nodeF i) && (Nat.blt i 15555 || Nat.ble PRE_first_tail_x15_r0_body.kd13.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord13 : (PRE_first_tail_x15_r0_body.cln13.filter (Nat.ble PRE_first_tail_x15_r0_body.P13.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd13.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd13.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd13.nodeF j) (PRE_first_tail_x15_r0_body.kd13.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow13 PRE_first_tail_x15_r0_body.cnn113 PRE_first_tail_x15_r0_body.fnordI13 PRE_first_tail_x15_r0_body.fnordK13 PRE_first_tail_x15_r0_body.fnordL13
kernel_rfl PRE_first_tail_x15_r0_body.fi13 : PRE_first_tail_x15_r0_body.cli13.all (pnB PRE_first_tail_x15_r0_body.cx0_13.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii13 : PRE_first_tail_x15_r0_body.cli13.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_13.mlx.items.get (PRE_first_tail_x15_r0_body.kappa13.node k) = (PRE_first_tail_x15_r0_body.cx0_13.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa13.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot13 (clean : Conv.NClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P13.NL) (cl : SSt (· < 635) PRE_first_tail_x15_r0_body.cx0_13.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P13 635 PRE_first_tail_x15_r0_body.kappa13 PRE_first_tail_x15_r0_body.kd13 PRE_first_tail_x15_r0_body.khinv13 PRE_first_tail_x15_r0_body.kninv13 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx PRE_first_tail_x15_r0_body.cx0_13.mlx PRE_first_tail_x15_r0_body.cx1_13.mlx (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo13 PRE_first_tail_x15_r0_body.cln13 PRE_first_tail_x15_r0_body.cli13 PRE_first_tail_x15_r0_body.cwS13 PRE_first_tail_x15_r0_body.cnS13 PRE_first_tail_x15_r0_body.ciS13 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh013, PRE_first_tail_x15_r0_body.cnh113, PRE_first_tail_x15_r0_body.cnn013, PRE_first_tail_x15_r0_body.cnn113, PRE_first_tail_x15_r0_body.cplo13, PRE_first_tail_x15_r0_body.ccnt13, PRE_first_tail_x15_r0_body.cnband13, PRE_first_tail_x15_r0_body.chbelow13, PRE_first_tail_x15_r0_body.chren13, PRE_first_tail_x15_r0_body.cband13, PRE_first_tail_x15_r0_body.cnh1pos13, PRE_first_tail_x15_r0_body.cnren13, PRE_first_tail_x15_r0_body.cnlow13, PRE_first_tail_x15_r0_body.cabs0a13, PRE_first_tail_x15_r0_body.cabs0b13, PRE_first_tail_x15_r0_body.ctok113, PRE_first_tail_x15_r0_body.cpend13, PRE_first_tail_x15_r0_body.cerrh13, PRE_first_tail_x15_r0_body.cfiles13, PRE_first_tail_x15_r0_body.carch13, PRE_first_tail_x15_r0_body.csizes13, PRE_first_tail_x15_r0_body.cwired13, PRE_first_tail_x15_r0_body.cfix13, clean, PRE_first_tail_x15_r0_body.fcxn13, PRE_first_tail_x15_r0_body.fcnn13, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle013, PRE_first_tail_x15_r0_body.fnk13, PRE_first_tail_x15_r0_body.ckA13, PRE_first_tail_x15_r0_body.cobjsK13, PRE_first_tail_x15_r0_body.cnodesK13, PRE_first_tail_x15_r0_body.citemsK13, PRE_first_tail_x15_r0_body.f1A13, PRE_first_tail_x15_r0_body.f1O13, PRE_first_tail_x15_r0_body.f1N13, PRE_first_tail_x15_r0_body.f1I13, PRE_first_tail_x15_r0_body.fbd13, PRE_first_tail_x15_r0_body.fincW13, PRE_first_tail_x15_r0_body.fincI13, PRE_first_tail_x15_r0_body.fincN13, PRE_first_tail_x15_r0_body.flnF13, PRE_first_tail_x15_r0_body.fh13, PRE_first_tail_x15_r0_body.fo13, PRE_first_tail_x15_r0_body.fok13, PRE_first_tail_x15_r0_body.fnd13, PRE_first_tail_x15_r0_body.fp13, PRE_first_tail_x15_r0_body.fnord13, PRE_first_tail_x15_r0_body.fi13, PRE_first_tail_x15_r0_body.fii13⟩
theorem PRE_first_tail_x15_r0_body.cnshift13 (clean : Conv.NClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P13.NL) (cl : SSt (· < 635) PRE_first_tail_x15_r0_body.cx0_13.mlx) : NShift PRE_first_tail_x15_r0_body.P13 635 PRE_first_tail_x15_r0_body.kappa13 PRE_first_tail_x15_r0_body.cx0_13 PRE_first_tail_x15_r0_body.cx1_13 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot13 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost13 (compact_a_eq PRE_first_tail_x15_r0_body.ckn013 PRE_first_tail_x15_r0_body.ckn113 PRE_first_tail_x15_r0_body.ckheap13 PRE_first_tail_x15_r0_body.ckpl13)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_13 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s126.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_13 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s126.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_13 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s126.ffi) = some PRE_first_tail_x15_r0_body.fxC_13
kernel_rfl PRE_first_tail_x15_r0_body.okrC_13 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s126.ffi) = some PRE_first_tail_x15_r0_body.krC_13
noncomputable def PRE_first_tail_x15_r0_body.fx0_13 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s128.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_13 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s128.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_13 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s128.ffi) = some PRE_first_tail_x15_r0_body.fx0_13
kernel_rfl PRE_first_tail_x15_r0_body.okr0_13 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s128.ffi) = some PRE_first_tail_x15_r0_body.kr0_13
noncomputable def PRE_first_tail_x15_r0_body.fx1_13 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s127.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_13 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s127.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_13 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s127.ffi) = some PRE_first_tail_x15_r0_body.fx1_13
kernel_rfl PRE_first_tail_x15_r0_body.okr1_13 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s127.ffi) = some PRE_first_tail_x15_r0_body.kr1_13
kernel_rfl PRE_first_tail_x15_r0_body.ff013 : PRE_first_tail_x15_r0_body.fx0_13 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_13 (PRE_first_tail_x15_r0_body.clo13.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_13.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff113 : PRE_first_tail_x15_r0_body.fx1_13 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_13 (PRE_first_tail_x15_r0_body.cwS13.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_13.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck13 : freedLB PRE_first_tail_x15_r0_body.kappa13 PRE_first_tail_x15_r0_body.cx0_13.mlx PRE_first_tail_x15_r0_body.fx0_13 PRE_first_tail_x15_r0_body.fx1_13 PRE_first_tail_x15_r0_body.clo13 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf013 : PRE_first_tail_x15_r0_body.kr0_13.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_13.flags (PRE_first_tail_x15_r0_body.clo13.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_13.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt013 : PRE_first_tail_x15_r0_body.kr0_13.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_13.targs (PRE_first_tail_x15_r0_body.clo13.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_13.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf113 : PRE_first_tail_x15_r0_body.kr1_13.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_13.flags (PRE_first_tail_x15_r0_body.cwS13.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_13.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt113 : PRE_first_tail_x15_r0_body.kr1_13.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_13.targs (PRE_first_tail_x15_r0_body.cwS13.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_13.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck13 : krecLB PRE_first_tail_x15_r0_body.kappa13 635 PRE_first_tail_x15_r0_body.cx0_13.mlx PRE_first_tail_x15_r0_body.kr0_13 PRE_first_tail_x15_r0_body.kr1_13 PRE_first_tail_x15_r0_body.clo13 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn13 : Nat.ble 635 635 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge13 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s127.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s128.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR13 : pendRegB PRE_first_tail_x15_r0_body.kappa13 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s128.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe13 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s128.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s127.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift13 (clean : Conv.NClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P13.NL) (cl : SSt (· < 635) PRE_first_tail_x15_r0_body.cx0_13.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_13.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_13.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_13.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s126.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_13.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P13 635 PRE_first_tail_x15_r0_body.kappa13 PRE_first_tail_x15_r0_body.s128.ffi PRE_first_tail_x15_r0_body.s127.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift13 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue13, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp13 t ht),
    PRE_first_tail_x15_r0_body.cbridge13,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s128.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s127.ffi) (PRE_first_tail_x15_r0_body.cfoot13 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_13 PRE_first_tail_x15_r0_body.ofx1_13 hobjC PRE_first_tail_x15_r0_body.ff013 PRE_first_tail_x15_r0_body.ff113 PRE_first_tail_x15_r0_body.ffck13,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s128.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s127.ffi) (PRE_first_tail_x15_r0_body.cfoot13 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_13 PRE_first_tail_x15_r0_body.okr1_13 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn13) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf013 PRE_first_tail_x15_r0_body.fkt013 PRE_first_tail_x15_r0_body.fkf113 PRE_first_tail_x15_r0_body.fkt113 PRE_first_tail_x15_r0_body.fkck13,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh013 PRE_first_tail_x15_r0_body.cnh113 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe13) PRE_first_tail_x15_r0_body.cpendR13⟩

end Host.Load.Run.Tpl
