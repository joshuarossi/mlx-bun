import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl77
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 77 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc77 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P77 : LoadP := PRE_first_tail_x15_r0_body.Pc77.raise 16807
kernel_rfl PRE_first_tail_x15_r0_body.craise77 : Nat.ble PRE_first_tail_x15_r0_body.Pc77.N0 16807 = true
theorem PRE_first_tail_x15_r0_body.raised77 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc77 PRE_first_tail_x15_r0_body.P77 :=
  .inr ⟨16807, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise77, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_77 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s749.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_77 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s748.ffi)
def PRE_first_tail_x15_r0_body.khinv77 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv77 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS77 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS77 : List Nat := List.range' 16807 0
def PRE_first_tail_x15_r0_body.ciS77 : List Nat := [] ++ List.range' 16807 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh077 : PRE_first_tail_x15_r0_body.kd77.nh0 = PRE_first_tail_x15_r0_body.cx0_77.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh177 : PRE_first_tail_x15_r0_body.kd77.nh1 = PRE_first_tail_x15_r0_body.cx1_77.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn077 : PRE_first_tail_x15_r0_body.kd77.nn0 = PRE_first_tail_x15_r0_body.cx0_77.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn177 : PRE_first_tail_x15_r0_body.kd77.nn1 = PRE_first_tail_x15_r0_body.cx1_77.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo77 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P77.lo && Nat.ble PRE_first_tail_x15_r0_body.P77.lo PRE_first_tail_x15_r0_body.cx0_77.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P77.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P77.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt77 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_77.mlx.next PRE_first_tail_x15_r0_body.cx1_77.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_77.mlx.nnext PRE_first_tail_x15_r0_body.cx1_77.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband77 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P77.NL && Nat.ble PRE_first_tail_x15_r0_body.P77.NL PRE_first_tail_x15_r0_body.P77.N0 && Nat.ble PRE_first_tail_x15_r0_body.P77.N0 PRE_first_tail_x15_r0_body.cx0_77.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow77 : PRE_first_tail_x15_r0_body.kd77.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren77 : checkRenG PRE_first_tail_x15_r0_body.kd77.hnd PRE_first_tail_x15_r0_body.khinv77 (phB PRE_first_tail_x15_r0_body.cx0_77.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband77 : PRE_first_tail_x15_r0_body.kd77.checkBand PRE_first_tail_x15_r0_body.P77.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos77 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd77.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren77 : checkRenG PRE_first_tail_x15_r0_body.kd77.node PRE_first_tail_x15_r0_body.kninv77 (pnB PRE_first_tail_x15_r0_body.cx0_77.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow77 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd77.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P77.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd77.nodeF j) PRE_first_tail_x15_r0_body.cx1_77.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a77 : PRE_first_tail_x15_r0_body.cx0_77.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b77 : PRE_first_tail_x15_r0_body.cx0_77.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok177 : PRE_first_tail_x15_r0_body.cx1_77.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend77 : PRE_first_tail_x15_r0_body.cx1_77.mlx.pending = PRE_first_tail_x15_r0_body.cx0_77.mlx.pending.map PRE_first_tail_x15_r0_body.kappa77.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh77 : PRE_first_tail_x15_r0_body.cx1_77.mlx.errh = PRE_first_tail_x15_r0_body.cx0_77.mlx.errh.map PRE_first_tail_x15_r0_body.kappa77.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles77 : PRE_first_tail_x15_r0_body.cx1_77.mlx.files = PRE_first_tail_x15_r0_body.cx0_77.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch77 : PRE_first_tail_x15_r0_body.cx1_77.mlx.arch = PRE_first_tail_x15_r0_body.cx0_77.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes77 : PRE_first_tail_x15_r0_body.cx1_77.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_77.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired77 : PRE_first_tail_x15_r0_body.cx1_77.mlx.wired = PRE_first_tail_x15_r0_body.cx0_77.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost77 : PRE_first_tail_x15_r0_body.cx1_77.host = PRE_first_tail_x15_r0_body.cx0_77.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd77`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn077 : PRE_first_tail_x15_r0_body.kd77.n0 = 2735000
kernel_rfl PRE_first_tail_x15_r0_body.ckn177 : PRE_first_tail_x15_r0_body.kd77.n1 = 2735010
kernel_rfl PRE_first_tail_x15_r0_body.ckheap77 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd77.heap).all (fun x => Nat.ble 2734999 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl77 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd77.heap.get (2734999 + j) = nth? PRE_first_tail_x15_r0_body.pl77 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja77 : Nat.ble 2734999 2734999 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn77 : Nat.ble 3346 3346 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD77 : Nat.ble 2734999 PRE_first_tail_x15_r0_body.kd77.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn77 : Nat.ble 19712 PRE_first_tail_x15_r0_body.kd77.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn77 : Nat.ble 16807 PRE_first_tail_x15_r0_body.kd77.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb77 : Nat.ble 19712 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap77 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd77.heap).all (Nat.ble (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd77 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd77.hnd).all (Nat.ble (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode77 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd77.node).all (Nat.ble (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix77 : Conv.FixOld (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa77 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja77) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn77) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD77) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn77) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn77) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb77) PRE_first_tail_x15_r0_body.fheap77 PRE_first_tail_x15_r0_body.fhnd77 PRE_first_tail_x15_r0_body.fnode77
kernel_rfl PRE_first_tail_x15_r0_body.fcxn77 : (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn77 : (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle077 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_77.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_77.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk77 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd77.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A77 : PRE_first_tail_x15_r0_body.cx1_77.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS77.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_77.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O77 : PRE_first_tail_x15_r0_body.cx1_77.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS77.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_77.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N77 : PRE_first_tail_x15_r0_body.cx1_77.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS77.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_77.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I77 : PRE_first_tail_x15_r0_body.cx1_77.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS77.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_77.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd77 : (PRE_first_tail_x15_r0_body.clo77 ++ PRE_first_tail_x15_r0_body.cln77 ++ PRE_first_tail_x15_r0_body.cli77 ++ PRE_first_tail_x15_r0_body.cwS77 ++ PRE_first_tail_x15_r0_body.cnS77 ++ PRE_first_tail_x15_r0_body.ciS77).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW77 : PRE_first_tail_x15_r0_body.cwS77.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo77.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI77 : PRE_first_tail_x15_r0_body.ciS77.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli77.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN77 : PRE_first_tail_x15_r0_body.cnS77.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF77 : PRE_first_tail_x15_r0_body.cln77.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh77 : PRE_first_tail_x15_r0_body.clo77.all (handleOK PRE_first_tail_x15_r0_body.kappa77 PRE_first_tail_x15_r0_body.P77.lo PRE_first_tail_x15_r0_body.cx0_77.mlx PRE_first_tail_x15_r0_body.cx1_77.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo77 : PRE_first_tail_x15_r0_body.clo77.map (fun h => PRE_first_tail_x15_r0_body.cx1_77.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa77.handle h)) = PRE_first_tail_x15_r0_body.clo77.map (fun h => (PRE_first_tail_x15_r0_body.cx0_77.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa77.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok77 : PRE_first_tail_x15_r0_body.clo77.all (objOK PRE_first_tail_x15_r0_body.kappa77 PRE_first_tail_x15_r0_body.P77.NL PRE_first_tail_x15_r0_body.cx0_77.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd77 : PRE_first_tail_x15_r0_body.cln77.all (nodeOKF PRE_first_tail_x15_r0_body.kappa77 PRE_first_tail_x15_r0_body.P77 PRE_first_tail_x15_r0_body.cx0_77.mlx PRE_first_tail_x15_r0_body.cx1_77.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp77 : ((PRE_first_tail_x15_r0_body.cln77.filter (fullB PRE_first_tail_x15_r0_body.P77))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_77.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa77.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln77.filter (fullB PRE_first_tail_x15_r0_body.P77))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_77.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa77.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI77 : incrB PRE_first_tail_x15_r0_body.kd77.nodeF (List.range' 16807 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK77 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd77.node).all (fun k => Nat.ble 16807 k && Nat.blt k 16807) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL77 : (PRE_first_tail_x15_r0_body.cln77.filter (Nat.ble PRE_first_tail_x15_r0_body.P77.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd77.nodeF i) && (Nat.blt i 16807 || Nat.ble PRE_first_tail_x15_r0_body.kd77.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord77 : (PRE_first_tail_x15_r0_body.cln77.filter (Nat.ble PRE_first_tail_x15_r0_body.P77.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd77.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd77.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd77.nodeF j) (PRE_first_tail_x15_r0_body.kd77.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow77 PRE_first_tail_x15_r0_body.cnn177 PRE_first_tail_x15_r0_body.fnordI77 PRE_first_tail_x15_r0_body.fnordK77 PRE_first_tail_x15_r0_body.fnordL77
kernel_rfl PRE_first_tail_x15_r0_body.fi77 : PRE_first_tail_x15_r0_body.cli77.all (pnB PRE_first_tail_x15_r0_body.cx0_77.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii77 : PRE_first_tail_x15_r0_body.cli77.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_77.mlx.items.get (PRE_first_tail_x15_r0_body.kappa77.node k) = (PRE_first_tail_x15_r0_body.cx0_77.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa77.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot77 (clean : Conv.NClean (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P77.NL) (cl : SSt (· < 3346) PRE_first_tail_x15_r0_body.cx0_77.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P77 3346 PRE_first_tail_x15_r0_body.kappa77 PRE_first_tail_x15_r0_body.kd77 PRE_first_tail_x15_r0_body.khinv77 PRE_first_tail_x15_r0_body.kninv77 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx PRE_first_tail_x15_r0_body.cx0_77.mlx PRE_first_tail_x15_r0_body.cx1_77.mlx (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo77 PRE_first_tail_x15_r0_body.cln77 PRE_first_tail_x15_r0_body.cli77 PRE_first_tail_x15_r0_body.cwS77 PRE_first_tail_x15_r0_body.cnS77 PRE_first_tail_x15_r0_body.ciS77 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh077, PRE_first_tail_x15_r0_body.cnh177, PRE_first_tail_x15_r0_body.cnn077, PRE_first_tail_x15_r0_body.cnn177, PRE_first_tail_x15_r0_body.cplo77, PRE_first_tail_x15_r0_body.ccnt77, PRE_first_tail_x15_r0_body.cnband77, PRE_first_tail_x15_r0_body.chbelow77, PRE_first_tail_x15_r0_body.chren77, PRE_first_tail_x15_r0_body.cband77, PRE_first_tail_x15_r0_body.cnh1pos77, PRE_first_tail_x15_r0_body.cnren77, PRE_first_tail_x15_r0_body.cnlow77, PRE_first_tail_x15_r0_body.cabs0a77, PRE_first_tail_x15_r0_body.cabs0b77, PRE_first_tail_x15_r0_body.ctok177, PRE_first_tail_x15_r0_body.cpend77, PRE_first_tail_x15_r0_body.cerrh77, PRE_first_tail_x15_r0_body.cfiles77, PRE_first_tail_x15_r0_body.carch77, PRE_first_tail_x15_r0_body.csizes77, PRE_first_tail_x15_r0_body.cwired77, PRE_first_tail_x15_r0_body.cfix77, clean, PRE_first_tail_x15_r0_body.fcxn77, PRE_first_tail_x15_r0_body.fcnn77, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle077, PRE_first_tail_x15_r0_body.fnk77, PRE_first_tail_x15_r0_body.ckA77, PRE_first_tail_x15_r0_body.cobjsK77, PRE_first_tail_x15_r0_body.cnodesK77, PRE_first_tail_x15_r0_body.citemsK77, PRE_first_tail_x15_r0_body.f1A77, PRE_first_tail_x15_r0_body.f1O77, PRE_first_tail_x15_r0_body.f1N77, PRE_first_tail_x15_r0_body.f1I77, PRE_first_tail_x15_r0_body.fbd77, PRE_first_tail_x15_r0_body.fincW77, PRE_first_tail_x15_r0_body.fincI77, PRE_first_tail_x15_r0_body.fincN77, PRE_first_tail_x15_r0_body.flnF77, PRE_first_tail_x15_r0_body.fh77, PRE_first_tail_x15_r0_body.fo77, PRE_first_tail_x15_r0_body.fok77, PRE_first_tail_x15_r0_body.fnd77, PRE_first_tail_x15_r0_body.fp77, PRE_first_tail_x15_r0_body.fnord77, PRE_first_tail_x15_r0_body.fi77, PRE_first_tail_x15_r0_body.fii77⟩
theorem PRE_first_tail_x15_r0_body.cnshift77 (clean : Conv.NClean (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P77.NL) (cl : SSt (· < 3346) PRE_first_tail_x15_r0_body.cx0_77.mlx) : NShift PRE_first_tail_x15_r0_body.P77 3346 PRE_first_tail_x15_r0_body.kappa77 PRE_first_tail_x15_r0_body.cx0_77 PRE_first_tail_x15_r0_body.cx1_77 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot77 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost77 (compact_a_eq PRE_first_tail_x15_r0_body.ckn077 PRE_first_tail_x15_r0_body.ckn177 PRE_first_tail_x15_r0_body.ckheap77 PRE_first_tail_x15_r0_body.ckpl77)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_77 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s747.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_77 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s747.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_77 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s747.ffi) = some PRE_first_tail_x15_r0_body.fxC_77
kernel_rfl PRE_first_tail_x15_r0_body.okrC_77 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s747.ffi) = some PRE_first_tail_x15_r0_body.krC_77
noncomputable def PRE_first_tail_x15_r0_body.fx0_77 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s749.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_77 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s749.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_77 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s749.ffi) = some PRE_first_tail_x15_r0_body.fx0_77
kernel_rfl PRE_first_tail_x15_r0_body.okr0_77 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s749.ffi) = some PRE_first_tail_x15_r0_body.kr0_77
noncomputable def PRE_first_tail_x15_r0_body.fx1_77 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s748.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_77 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s748.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_77 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s748.ffi) = some PRE_first_tail_x15_r0_body.fx1_77
kernel_rfl PRE_first_tail_x15_r0_body.okr1_77 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s748.ffi) = some PRE_first_tail_x15_r0_body.kr1_77
kernel_rfl PRE_first_tail_x15_r0_body.ff077 : PRE_first_tail_x15_r0_body.fx0_77 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_77 (PRE_first_tail_x15_r0_body.clo77.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_77.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff177 : PRE_first_tail_x15_r0_body.fx1_77 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_77 (PRE_first_tail_x15_r0_body.cwS77.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_77.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck77 : freedLB PRE_first_tail_x15_r0_body.kappa77 PRE_first_tail_x15_r0_body.cx0_77.mlx PRE_first_tail_x15_r0_body.fx0_77 PRE_first_tail_x15_r0_body.fx1_77 PRE_first_tail_x15_r0_body.clo77 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf077 : PRE_first_tail_x15_r0_body.kr0_77.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_77.flags (PRE_first_tail_x15_r0_body.clo77.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_77.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt077 : PRE_first_tail_x15_r0_body.kr0_77.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_77.targs (PRE_first_tail_x15_r0_body.clo77.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_77.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf177 : PRE_first_tail_x15_r0_body.kr1_77.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_77.flags (PRE_first_tail_x15_r0_body.cwS77.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_77.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt177 : PRE_first_tail_x15_r0_body.kr1_77.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_77.targs (PRE_first_tail_x15_r0_body.cwS77.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_77.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck77 : krecLB PRE_first_tail_x15_r0_body.kappa77 3346 PRE_first_tail_x15_r0_body.cx0_77.mlx PRE_first_tail_x15_r0_body.kr0_77 PRE_first_tail_x15_r0_body.kr1_77 PRE_first_tail_x15_r0_body.clo77 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn77 : Nat.ble 3346 3346 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge77 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s748.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s749.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR77 : pendRegB PRE_first_tail_x15_r0_body.kappa77 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s749.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe77 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s749.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s748.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift77 (clean : Conv.NClean (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P77.NL) (cl : SSt (· < 3346) PRE_first_tail_x15_r0_body.cx0_77.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_77.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_77.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_77.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_77.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P77 3346 PRE_first_tail_x15_r0_body.kappa77 PRE_first_tail_x15_r0_body.s749.ffi PRE_first_tail_x15_r0_body.s748.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift77 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue77, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp77 t ht),
    PRE_first_tail_x15_r0_body.cbridge77,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s749.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s748.ffi) (PRE_first_tail_x15_r0_body.cfoot77 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_77 PRE_first_tail_x15_r0_body.ofx1_77 hobjC PRE_first_tail_x15_r0_body.ff077 PRE_first_tail_x15_r0_body.ff177 PRE_first_tail_x15_r0_body.ffck77,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s749.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s748.ffi) (PRE_first_tail_x15_r0_body.cfoot77 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_77 PRE_first_tail_x15_r0_body.okr1_77 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn77) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf077 PRE_first_tail_x15_r0_body.fkt077 PRE_first_tail_x15_r0_body.fkf177 PRE_first_tail_x15_r0_body.fkt177 PRE_first_tail_x15_r0_body.fkck77,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh077 PRE_first_tail_x15_r0_body.cnh177 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe77) PRE_first_tail_x15_r0_body.cpendR77⟩

end Host.Load.Run.Tpl
