import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl97
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 97 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc97 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P97 : LoadP := PRE_first_tail_x15_r0_body.Pc97.raise 17214
kernel_rfl PRE_first_tail_x15_r0_body.craise97 : Nat.ble PRE_first_tail_x15_r0_body.Pc97.N0 17214 = true
theorem PRE_first_tail_x15_r0_body.raised97 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc97 PRE_first_tail_x15_r0_body.P97 :=
  .inr ⟨17214, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise97, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_97 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_97 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi)
def PRE_first_tail_x15_r0_body.khinv97 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv97 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS97 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS97 : List Nat := List.range' 17214 0
def PRE_first_tail_x15_r0_body.ciS97 : List Nat := [] ++ List.range' 17214 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh097 : PRE_first_tail_x15_r0_body.kd97.nh0 = PRE_first_tail_x15_r0_body.cx0_97.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh197 : PRE_first_tail_x15_r0_body.kd97.nh1 = PRE_first_tail_x15_r0_body.cx1_97.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn097 : PRE_first_tail_x15_r0_body.kd97.nn0 = PRE_first_tail_x15_r0_body.cx0_97.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn197 : PRE_first_tail_x15_r0_body.kd97.nn1 = PRE_first_tail_x15_r0_body.cx1_97.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo97 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P97.lo && Nat.ble PRE_first_tail_x15_r0_body.P97.lo PRE_first_tail_x15_r0_body.cx0_97.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P97.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P97.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt97 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_97.mlx.next PRE_first_tail_x15_r0_body.cx1_97.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_97.mlx.nnext PRE_first_tail_x15_r0_body.cx1_97.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband97 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P97.NL && Nat.ble PRE_first_tail_x15_r0_body.P97.NL PRE_first_tail_x15_r0_body.P97.N0 && Nat.ble PRE_first_tail_x15_r0_body.P97.N0 PRE_first_tail_x15_r0_body.cx0_97.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow97 : PRE_first_tail_x15_r0_body.kd97.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren97 : checkRenG PRE_first_tail_x15_r0_body.kd97.hnd PRE_first_tail_x15_r0_body.khinv97 (phB PRE_first_tail_x15_r0_body.cx0_97.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband97 : PRE_first_tail_x15_r0_body.kd97.checkBand PRE_first_tail_x15_r0_body.P97.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos97 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd97.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren97 : checkRenG PRE_first_tail_x15_r0_body.kd97.node PRE_first_tail_x15_r0_body.kninv97 (pnB PRE_first_tail_x15_r0_body.cx0_97.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow97 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd97.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P97.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd97.nodeF j) PRE_first_tail_x15_r0_body.cx1_97.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a97 : PRE_first_tail_x15_r0_body.cx0_97.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b97 : PRE_first_tail_x15_r0_body.cx0_97.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok197 : PRE_first_tail_x15_r0_body.cx1_97.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend97 : PRE_first_tail_x15_r0_body.cx1_97.mlx.pending = PRE_first_tail_x15_r0_body.cx0_97.mlx.pending.map PRE_first_tail_x15_r0_body.kappa97.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh97 : PRE_first_tail_x15_r0_body.cx1_97.mlx.errh = PRE_first_tail_x15_r0_body.cx0_97.mlx.errh.map PRE_first_tail_x15_r0_body.kappa97.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles97 : PRE_first_tail_x15_r0_body.cx1_97.mlx.files = PRE_first_tail_x15_r0_body.cx0_97.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch97 : PRE_first_tail_x15_r0_body.cx1_97.mlx.arch = PRE_first_tail_x15_r0_body.cx0_97.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes97 : PRE_first_tail_x15_r0_body.cx1_97.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_97.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired97 : PRE_first_tail_x15_r0_body.cx1_97.mlx.wired = PRE_first_tail_x15_r0_body.cx0_97.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost97 : PRE_first_tail_x15_r0_body.cx1_97.host = PRE_first_tail_x15_r0_body.cx0_97.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd97`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn097 : PRE_first_tail_x15_r0_body.kd97.n0 = 2751287
kernel_rfl PRE_first_tail_x15_r0_body.ckn197 : PRE_first_tail_x15_r0_body.kd97.n1 = 2751289
kernel_rfl PRE_first_tail_x15_r0_body.ckheap97 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd97.heap).all (fun x => Nat.ble 2751287 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl97 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd97.heap.get (2751287 + j) = nth? PRE_first_tail_x15_r0_body.pl97 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja97 : Nat.ble 2751287 2751287 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn97 : Nat.ble 4226 4226 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD97 : Nat.ble 2751287 PRE_first_tail_x15_r0_body.kd97.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn97 : Nat.ble 20120 PRE_first_tail_x15_r0_body.kd97.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn97 : Nat.ble 17214 PRE_first_tail_x15_r0_body.kd97.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb97 : Nat.ble 20120 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap97 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd97.heap).all (Nat.ble (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd97 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd97.hnd).all (Nat.ble (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode97 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd97.node).all (Nat.ble (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix97 : Conv.FixOld (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa97 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja97) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn97) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD97) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn97) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn97) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb97) PRE_first_tail_x15_r0_body.fheap97 PRE_first_tail_x15_r0_body.fhnd97 PRE_first_tail_x15_r0_body.fnode97
kernel_rfl PRE_first_tail_x15_r0_body.fcxn97 : (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn97 : (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle097 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_97.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_97.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk97 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd97.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A97 : PRE_first_tail_x15_r0_body.cx1_97.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS97.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_97.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O97 : PRE_first_tail_x15_r0_body.cx1_97.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS97.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_97.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N97 : PRE_first_tail_x15_r0_body.cx1_97.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS97.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_97.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I97 : PRE_first_tail_x15_r0_body.cx1_97.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS97.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_97.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd97 : (PRE_first_tail_x15_r0_body.clo97 ++ PRE_first_tail_x15_r0_body.cln97 ++ PRE_first_tail_x15_r0_body.cli97 ++ PRE_first_tail_x15_r0_body.cwS97 ++ PRE_first_tail_x15_r0_body.cnS97 ++ PRE_first_tail_x15_r0_body.ciS97).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW97 : PRE_first_tail_x15_r0_body.cwS97.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo97.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI97 : PRE_first_tail_x15_r0_body.ciS97.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli97.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN97 : PRE_first_tail_x15_r0_body.cnS97.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF97 : PRE_first_tail_x15_r0_body.cln97.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh97 : PRE_first_tail_x15_r0_body.clo97.all (handleOK PRE_first_tail_x15_r0_body.kappa97 PRE_first_tail_x15_r0_body.P97.lo PRE_first_tail_x15_r0_body.cx0_97.mlx PRE_first_tail_x15_r0_body.cx1_97.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo97 : PRE_first_tail_x15_r0_body.clo97.map (fun h => PRE_first_tail_x15_r0_body.cx1_97.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa97.handle h)) = PRE_first_tail_x15_r0_body.clo97.map (fun h => (PRE_first_tail_x15_r0_body.cx0_97.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa97.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok97 : PRE_first_tail_x15_r0_body.clo97.all (objOK PRE_first_tail_x15_r0_body.kappa97 PRE_first_tail_x15_r0_body.P97.NL PRE_first_tail_x15_r0_body.cx0_97.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd97 : PRE_first_tail_x15_r0_body.cln97.all (nodeOKF PRE_first_tail_x15_r0_body.kappa97 PRE_first_tail_x15_r0_body.P97 PRE_first_tail_x15_r0_body.cx0_97.mlx PRE_first_tail_x15_r0_body.cx1_97.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp97 : ((PRE_first_tail_x15_r0_body.cln97.filter (fullB PRE_first_tail_x15_r0_body.P97))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_97.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa97.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln97.filter (fullB PRE_first_tail_x15_r0_body.P97))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_97.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa97.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI97 : incrB PRE_first_tail_x15_r0_body.kd97.nodeF (List.range' 17214 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK97 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd97.node).all (fun k => Nat.ble 17214 k && Nat.blt k 17214) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL97 : (PRE_first_tail_x15_r0_body.cln97.filter (Nat.ble PRE_first_tail_x15_r0_body.P97.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd97.nodeF i) && (Nat.blt i 17214 || Nat.ble PRE_first_tail_x15_r0_body.kd97.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord97 : (PRE_first_tail_x15_r0_body.cln97.filter (Nat.ble PRE_first_tail_x15_r0_body.P97.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd97.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd97.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd97.nodeF j) (PRE_first_tail_x15_r0_body.kd97.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow97 PRE_first_tail_x15_r0_body.cnn197 PRE_first_tail_x15_r0_body.fnordI97 PRE_first_tail_x15_r0_body.fnordK97 PRE_first_tail_x15_r0_body.fnordL97
kernel_rfl PRE_first_tail_x15_r0_body.fi97 : PRE_first_tail_x15_r0_body.cli97.all (pnB PRE_first_tail_x15_r0_body.cx0_97.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii97 : PRE_first_tail_x15_r0_body.cli97.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_97.mlx.items.get (PRE_first_tail_x15_r0_body.kappa97.node k) = (PRE_first_tail_x15_r0_body.cx0_97.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa97.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot97 (clean : Conv.NClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P97.NL) (cl : SSt (· < 4226) PRE_first_tail_x15_r0_body.cx0_97.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P97 4226 PRE_first_tail_x15_r0_body.kappa97 PRE_first_tail_x15_r0_body.kd97 PRE_first_tail_x15_r0_body.khinv97 PRE_first_tail_x15_r0_body.kninv97 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx PRE_first_tail_x15_r0_body.cx0_97.mlx PRE_first_tail_x15_r0_body.cx1_97.mlx (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo97 PRE_first_tail_x15_r0_body.cln97 PRE_first_tail_x15_r0_body.cli97 PRE_first_tail_x15_r0_body.cwS97 PRE_first_tail_x15_r0_body.cnS97 PRE_first_tail_x15_r0_body.ciS97 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh097, PRE_first_tail_x15_r0_body.cnh197, PRE_first_tail_x15_r0_body.cnn097, PRE_first_tail_x15_r0_body.cnn197, PRE_first_tail_x15_r0_body.cplo97, PRE_first_tail_x15_r0_body.ccnt97, PRE_first_tail_x15_r0_body.cnband97, PRE_first_tail_x15_r0_body.chbelow97, PRE_first_tail_x15_r0_body.chren97, PRE_first_tail_x15_r0_body.cband97, PRE_first_tail_x15_r0_body.cnh1pos97, PRE_first_tail_x15_r0_body.cnren97, PRE_first_tail_x15_r0_body.cnlow97, PRE_first_tail_x15_r0_body.cabs0a97, PRE_first_tail_x15_r0_body.cabs0b97, PRE_first_tail_x15_r0_body.ctok197, PRE_first_tail_x15_r0_body.cpend97, PRE_first_tail_x15_r0_body.cerrh97, PRE_first_tail_x15_r0_body.cfiles97, PRE_first_tail_x15_r0_body.carch97, PRE_first_tail_x15_r0_body.csizes97, PRE_first_tail_x15_r0_body.cwired97, PRE_first_tail_x15_r0_body.cfix97, clean, PRE_first_tail_x15_r0_body.fcxn97, PRE_first_tail_x15_r0_body.fcnn97, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle097, PRE_first_tail_x15_r0_body.fnk97, PRE_first_tail_x15_r0_body.ckA97, PRE_first_tail_x15_r0_body.cobjsK97, PRE_first_tail_x15_r0_body.cnodesK97, PRE_first_tail_x15_r0_body.citemsK97, PRE_first_tail_x15_r0_body.f1A97, PRE_first_tail_x15_r0_body.f1O97, PRE_first_tail_x15_r0_body.f1N97, PRE_first_tail_x15_r0_body.f1I97, PRE_first_tail_x15_r0_body.fbd97, PRE_first_tail_x15_r0_body.fincW97, PRE_first_tail_x15_r0_body.fincI97, PRE_first_tail_x15_r0_body.fincN97, PRE_first_tail_x15_r0_body.flnF97, PRE_first_tail_x15_r0_body.fh97, PRE_first_tail_x15_r0_body.fo97, PRE_first_tail_x15_r0_body.fok97, PRE_first_tail_x15_r0_body.fnd97, PRE_first_tail_x15_r0_body.fp97, PRE_first_tail_x15_r0_body.fnord97, PRE_first_tail_x15_r0_body.fi97, PRE_first_tail_x15_r0_body.fii97⟩
theorem PRE_first_tail_x15_r0_body.cnshift97 (clean : Conv.NClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P97.NL) (cl : SSt (· < 4226) PRE_first_tail_x15_r0_body.cx0_97.mlx) : NShift PRE_first_tail_x15_r0_body.P97 4226 PRE_first_tail_x15_r0_body.kappa97 PRE_first_tail_x15_r0_body.cx0_97 PRE_first_tail_x15_r0_body.cx1_97 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot97 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost97 (compact_a_eq PRE_first_tail_x15_r0_body.ckn097 PRE_first_tail_x15_r0_body.ckn197 PRE_first_tail_x15_r0_body.ckheap97 PRE_first_tail_x15_r0_body.ckpl97)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_97 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s861.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_97 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s861.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_97 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s861.ffi) = some PRE_first_tail_x15_r0_body.fxC_97
kernel_rfl PRE_first_tail_x15_r0_body.okrC_97 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s861.ffi) = some PRE_first_tail_x15_r0_body.krC_97
noncomputable def PRE_first_tail_x15_r0_body.fx0_97 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s863.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_97 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s863.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_97 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s863.ffi) = some PRE_first_tail_x15_r0_body.fx0_97
kernel_rfl PRE_first_tail_x15_r0_body.okr0_97 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s863.ffi) = some PRE_first_tail_x15_r0_body.kr0_97
noncomputable def PRE_first_tail_x15_r0_body.fx1_97 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s862.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_97 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s862.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_97 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s862.ffi) = some PRE_first_tail_x15_r0_body.fx1_97
kernel_rfl PRE_first_tail_x15_r0_body.okr1_97 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s862.ffi) = some PRE_first_tail_x15_r0_body.kr1_97
kernel_rfl PRE_first_tail_x15_r0_body.ff097 : PRE_first_tail_x15_r0_body.fx0_97 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_97 (PRE_first_tail_x15_r0_body.clo97.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_97.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff197 : PRE_first_tail_x15_r0_body.fx1_97 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_97 (PRE_first_tail_x15_r0_body.cwS97.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_97.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck97 : freedLB PRE_first_tail_x15_r0_body.kappa97 PRE_first_tail_x15_r0_body.cx0_97.mlx PRE_first_tail_x15_r0_body.fx0_97 PRE_first_tail_x15_r0_body.fx1_97 PRE_first_tail_x15_r0_body.clo97 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf097 : PRE_first_tail_x15_r0_body.kr0_97.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_97.flags (PRE_first_tail_x15_r0_body.clo97.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_97.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt097 : PRE_first_tail_x15_r0_body.kr0_97.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_97.targs (PRE_first_tail_x15_r0_body.clo97.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_97.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf197 : PRE_first_tail_x15_r0_body.kr1_97.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_97.flags (PRE_first_tail_x15_r0_body.cwS97.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_97.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt197 : PRE_first_tail_x15_r0_body.kr1_97.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_97.targs (PRE_first_tail_x15_r0_body.cwS97.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_97.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck97 : krecLB PRE_first_tail_x15_r0_body.kappa97 4226 PRE_first_tail_x15_r0_body.cx0_97.mlx PRE_first_tail_x15_r0_body.kr0_97 PRE_first_tail_x15_r0_body.kr1_97 PRE_first_tail_x15_r0_body.clo97 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn97 : Nat.ble 4226 4226 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge97 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s862.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s863.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR97 : pendRegB PRE_first_tail_x15_r0_body.kappa97 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe97 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift97 (clean : Conv.NClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P97.NL) (cl : SSt (· < 4226) PRE_first_tail_x15_r0_body.cx0_97.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_97.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_97.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_97.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_97.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P97 4226 PRE_first_tail_x15_r0_body.kappa97 PRE_first_tail_x15_r0_body.s863.ffi PRE_first_tail_x15_r0_body.s862.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift97 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue97, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp97 t ht),
    PRE_first_tail_x15_r0_body.cbridge97,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s863.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s862.ffi) (PRE_first_tail_x15_r0_body.cfoot97 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_97 PRE_first_tail_x15_r0_body.ofx1_97 hobjC PRE_first_tail_x15_r0_body.ff097 PRE_first_tail_x15_r0_body.ff197 PRE_first_tail_x15_r0_body.ffck97,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s863.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s862.ffi) (PRE_first_tail_x15_r0_body.cfoot97 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_97 PRE_first_tail_x15_r0_body.okr1_97 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn97) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf097 PRE_first_tail_x15_r0_body.fkt097 PRE_first_tail_x15_r0_body.fkf197 PRE_first_tail_x15_r0_body.fkt197 PRE_first_tail_x15_r0_body.fkck97,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh097 PRE_first_tail_x15_r0_body.cnh197 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe97) PRE_first_tail_x15_r0_body.cpendR97⟩

end Host.Load.Run.Tpl
