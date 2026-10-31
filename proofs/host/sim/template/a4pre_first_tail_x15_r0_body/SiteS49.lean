import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl49
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 49 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc49 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P49 : LoadP := PRE_first_tail_x15_r0_body.Pc49.raise 16266
kernel_rfl PRE_first_tail_x15_r0_body.craise49 : Nat.ble PRE_first_tail_x15_r0_body.Pc49.N0 16266 = true
theorem PRE_first_tail_x15_r0_body.raised49 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc49 PRE_first_tail_x15_r0_body.P49 :=
  .inr ⟨16266, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise49, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_49 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_49 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s485.ffi)
def PRE_first_tail_x15_r0_body.khinv49 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv49 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS49 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS49 : List Nat := List.range' 16266 0
def PRE_first_tail_x15_r0_body.ciS49 : List Nat := [] ++ List.range' 16266 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh049 : PRE_first_tail_x15_r0_body.kd49.nh0 = PRE_first_tail_x15_r0_body.cx0_49.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh149 : PRE_first_tail_x15_r0_body.kd49.nh1 = PRE_first_tail_x15_r0_body.cx1_49.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn049 : PRE_first_tail_x15_r0_body.kd49.nn0 = PRE_first_tail_x15_r0_body.cx0_49.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn149 : PRE_first_tail_x15_r0_body.kd49.nn1 = PRE_first_tail_x15_r0_body.cx1_49.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo49 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P49.lo && Nat.ble PRE_first_tail_x15_r0_body.P49.lo PRE_first_tail_x15_r0_body.cx0_49.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P49.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P49.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt49 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_49.mlx.next PRE_first_tail_x15_r0_body.cx1_49.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_49.mlx.nnext PRE_first_tail_x15_r0_body.cx1_49.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband49 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P49.NL && Nat.ble PRE_first_tail_x15_r0_body.P49.NL PRE_first_tail_x15_r0_body.P49.N0 && Nat.ble PRE_first_tail_x15_r0_body.P49.N0 PRE_first_tail_x15_r0_body.cx0_49.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow49 : PRE_first_tail_x15_r0_body.kd49.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren49 : checkRenG PRE_first_tail_x15_r0_body.kd49.hnd PRE_first_tail_x15_r0_body.khinv49 (phB PRE_first_tail_x15_r0_body.cx0_49.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband49 : PRE_first_tail_x15_r0_body.kd49.checkBand PRE_first_tail_x15_r0_body.P49.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos49 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd49.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren49 : checkRenG PRE_first_tail_x15_r0_body.kd49.node PRE_first_tail_x15_r0_body.kninv49 (pnB PRE_first_tail_x15_r0_body.cx0_49.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P49.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd49.nodeF j) PRE_first_tail_x15_r0_body.cx1_49.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a49 : PRE_first_tail_x15_r0_body.cx0_49.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b49 : PRE_first_tail_x15_r0_body.cx0_49.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok149 : PRE_first_tail_x15_r0_body.cx1_49.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.pending = PRE_first_tail_x15_r0_body.cx0_49.mlx.pending.map PRE_first_tail_x15_r0_body.kappa49.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.errh = PRE_first_tail_x15_r0_body.cx0_49.mlx.errh.map PRE_first_tail_x15_r0_body.kappa49.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.files = PRE_first_tail_x15_r0_body.cx0_49.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.arch = PRE_first_tail_x15_r0_body.cx0_49.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_49.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.wired = PRE_first_tail_x15_r0_body.cx0_49.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost49 : PRE_first_tail_x15_r0_body.cx1_49.host = PRE_first_tail_x15_r0_body.cx0_49.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd49`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn049 : PRE_first_tail_x15_r0_body.kd49.n0 = 2713619
kernel_rfl PRE_first_tail_x15_r0_body.ckn149 : PRE_first_tail_x15_r0_body.kd49.n1 = 2713621
kernel_rfl PRE_first_tail_x15_r0_body.ckheap49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.heap).all (fun x => Nat.ble 2713619 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl49 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd49.heap.get (2713619 + j) = nth? PRE_first_tail_x15_r0_body.pl49 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja49 : Nat.ble 2713619 2713619 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn49 : Nat.ble 2174 2174 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD49 : Nat.ble 2713619 PRE_first_tail_x15_r0_body.kd49.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn49 : Nat.ble 19176 PRE_first_tail_x15_r0_body.kd49.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn49 : Nat.ble 16266 PRE_first_tail_x15_r0_body.kd49.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb49 : Nat.ble 19176 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.heap).all (Nat.ble (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.hnd).all (Nat.ble (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.node).all (Nat.ble (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix49 : Conv.FixOld (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa49 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja49) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn49) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD49) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn49) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn49) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb49) PRE_first_tail_x15_r0_body.fheap49 PRE_first_tail_x15_r0_body.fhnd49 PRE_first_tail_x15_r0_body.fnode49
kernel_rfl PRE_first_tail_x15_r0_body.fcxn49 : (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn49 : (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle049 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_49.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_49.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS49.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_49.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS49.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_49.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS49.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_49.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS49.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_49.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd49 : (PRE_first_tail_x15_r0_body.clo49 ++ PRE_first_tail_x15_r0_body.cln49 ++ PRE_first_tail_x15_r0_body.cli49 ++ PRE_first_tail_x15_r0_body.cwS49 ++ PRE_first_tail_x15_r0_body.cnS49 ++ PRE_first_tail_x15_r0_body.ciS49).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW49 : PRE_first_tail_x15_r0_body.cwS49.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo49.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI49 : PRE_first_tail_x15_r0_body.ciS49.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli49.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN49 : PRE_first_tail_x15_r0_body.cnS49.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF49 : PRE_first_tail_x15_r0_body.cln49.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh49 : PRE_first_tail_x15_r0_body.clo49.all (handleOK PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.P49.lo PRE_first_tail_x15_r0_body.cx0_49.mlx PRE_first_tail_x15_r0_body.cx1_49.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo49 : PRE_first_tail_x15_r0_body.clo49.map (fun h => PRE_first_tail_x15_r0_body.cx1_49.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa49.handle h)) = PRE_first_tail_x15_r0_body.clo49.map (fun h => (PRE_first_tail_x15_r0_body.cx0_49.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa49.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok49 : PRE_first_tail_x15_r0_body.clo49.all (objOK PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.P49.NL PRE_first_tail_x15_r0_body.cx0_49.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd49 : PRE_first_tail_x15_r0_body.cln49.all (nodeOKF PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.P49 PRE_first_tail_x15_r0_body.cx0_49.mlx PRE_first_tail_x15_r0_body.cx1_49.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp49 : ((PRE_first_tail_x15_r0_body.cln49.filter (fullB PRE_first_tail_x15_r0_body.P49))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_49.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa49.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln49.filter (fullB PRE_first_tail_x15_r0_body.P49))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_49.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa49.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI49 : incrB PRE_first_tail_x15_r0_body.kd49.nodeF (List.range' 16266 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.node).all (fun k => Nat.ble 16266 k && Nat.blt k 16266) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL49 : (PRE_first_tail_x15_r0_body.cln49.filter (Nat.ble PRE_first_tail_x15_r0_body.P49.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd49.nodeF i) && (Nat.blt i 16266 || Nat.ble PRE_first_tail_x15_r0_body.kd49.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord49 : (PRE_first_tail_x15_r0_body.cln49.filter (Nat.ble PRE_first_tail_x15_r0_body.P49.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd49.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd49.nodeF j) (PRE_first_tail_x15_r0_body.kd49.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow49 PRE_first_tail_x15_r0_body.cnn149 PRE_first_tail_x15_r0_body.fnordI49 PRE_first_tail_x15_r0_body.fnordK49 PRE_first_tail_x15_r0_body.fnordL49
kernel_rfl PRE_first_tail_x15_r0_body.fi49 : PRE_first_tail_x15_r0_body.cli49.all (pnB PRE_first_tail_x15_r0_body.cx0_49.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii49 : PRE_first_tail_x15_r0_body.cli49.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_49.mlx.items.get (PRE_first_tail_x15_r0_body.kappa49.node k) = (PRE_first_tail_x15_r0_body.cx0_49.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa49.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot49 (clean : Conv.NClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P49.NL) (cl : SSt (· < 2174) PRE_first_tail_x15_r0_body.cx0_49.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P49 2174 PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.kd49 PRE_first_tail_x15_r0_body.khinv49 PRE_first_tail_x15_r0_body.kninv49 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx PRE_first_tail_x15_r0_body.cx0_49.mlx PRE_first_tail_x15_r0_body.cx1_49.mlx (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo49 PRE_first_tail_x15_r0_body.cln49 PRE_first_tail_x15_r0_body.cli49 PRE_first_tail_x15_r0_body.cwS49 PRE_first_tail_x15_r0_body.cnS49 PRE_first_tail_x15_r0_body.ciS49 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh049, PRE_first_tail_x15_r0_body.cnh149, PRE_first_tail_x15_r0_body.cnn049, PRE_first_tail_x15_r0_body.cnn149, PRE_first_tail_x15_r0_body.cplo49, PRE_first_tail_x15_r0_body.ccnt49, PRE_first_tail_x15_r0_body.cnband49, PRE_first_tail_x15_r0_body.chbelow49, PRE_first_tail_x15_r0_body.chren49, PRE_first_tail_x15_r0_body.cband49, PRE_first_tail_x15_r0_body.cnh1pos49, PRE_first_tail_x15_r0_body.cnren49, PRE_first_tail_x15_r0_body.cnlow49, PRE_first_tail_x15_r0_body.cabs0a49, PRE_first_tail_x15_r0_body.cabs0b49, PRE_first_tail_x15_r0_body.ctok149, PRE_first_tail_x15_r0_body.cpend49, PRE_first_tail_x15_r0_body.cerrh49, PRE_first_tail_x15_r0_body.cfiles49, PRE_first_tail_x15_r0_body.carch49, PRE_first_tail_x15_r0_body.csizes49, PRE_first_tail_x15_r0_body.cwired49, PRE_first_tail_x15_r0_body.cfix49, clean, PRE_first_tail_x15_r0_body.fcxn49, PRE_first_tail_x15_r0_body.fcnn49, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle049, PRE_first_tail_x15_r0_body.fnk49, PRE_first_tail_x15_r0_body.ckA49, PRE_first_tail_x15_r0_body.cobjsK49, PRE_first_tail_x15_r0_body.cnodesK49, PRE_first_tail_x15_r0_body.citemsK49, PRE_first_tail_x15_r0_body.f1A49, PRE_first_tail_x15_r0_body.f1O49, PRE_first_tail_x15_r0_body.f1N49, PRE_first_tail_x15_r0_body.f1I49, PRE_first_tail_x15_r0_body.fbd49, PRE_first_tail_x15_r0_body.fincW49, PRE_first_tail_x15_r0_body.fincI49, PRE_first_tail_x15_r0_body.fincN49, PRE_first_tail_x15_r0_body.flnF49, PRE_first_tail_x15_r0_body.fh49, PRE_first_tail_x15_r0_body.fo49, PRE_first_tail_x15_r0_body.fok49, PRE_first_tail_x15_r0_body.fnd49, PRE_first_tail_x15_r0_body.fp49, PRE_first_tail_x15_r0_body.fnord49, PRE_first_tail_x15_r0_body.fi49, PRE_first_tail_x15_r0_body.fii49⟩
theorem PRE_first_tail_x15_r0_body.cnshift49 (clean : Conv.NClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P49.NL) (cl : SSt (· < 2174) PRE_first_tail_x15_r0_body.cx0_49.mlx) : NShift PRE_first_tail_x15_r0_body.P49 2174 PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.cx0_49 PRE_first_tail_x15_r0_body.cx1_49 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot49 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost49 (compact_a_eq PRE_first_tail_x15_r0_body.ckn049 PRE_first_tail_x15_r0_body.ckn149 PRE_first_tail_x15_r0_body.ckheap49 PRE_first_tail_x15_r0_body.ckpl49)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_49 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s484.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_49 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s484.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_49 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s484.ffi) = some PRE_first_tail_x15_r0_body.fxC_49
kernel_rfl PRE_first_tail_x15_r0_body.okrC_49 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s484.ffi) = some PRE_first_tail_x15_r0_body.krC_49
noncomputable def PRE_first_tail_x15_r0_body.fx0_49 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s486.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_49 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s486.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_49 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s486.ffi) = some PRE_first_tail_x15_r0_body.fx0_49
kernel_rfl PRE_first_tail_x15_r0_body.okr0_49 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s486.ffi) = some PRE_first_tail_x15_r0_body.kr0_49
noncomputable def PRE_first_tail_x15_r0_body.fx1_49 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s485.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_49 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s485.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_49 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s485.ffi) = some PRE_first_tail_x15_r0_body.fx1_49
kernel_rfl PRE_first_tail_x15_r0_body.okr1_49 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s485.ffi) = some PRE_first_tail_x15_r0_body.kr1_49
kernel_rfl PRE_first_tail_x15_r0_body.ff049 : PRE_first_tail_x15_r0_body.fx0_49 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_49 (PRE_first_tail_x15_r0_body.clo49.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_49.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff149 : PRE_first_tail_x15_r0_body.fx1_49 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_49 (PRE_first_tail_x15_r0_body.cwS49.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_49.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck49 : freedLB PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.cx0_49.mlx PRE_first_tail_x15_r0_body.fx0_49 PRE_first_tail_x15_r0_body.fx1_49 PRE_first_tail_x15_r0_body.clo49 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf049 : PRE_first_tail_x15_r0_body.kr0_49.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_49.flags (PRE_first_tail_x15_r0_body.clo49.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_49.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt049 : PRE_first_tail_x15_r0_body.kr0_49.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_49.targs (PRE_first_tail_x15_r0_body.clo49.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_49.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf149 : PRE_first_tail_x15_r0_body.kr1_49.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_49.flags (PRE_first_tail_x15_r0_body.cwS49.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_49.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt149 : PRE_first_tail_x15_r0_body.kr1_49.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_49.targs (PRE_first_tail_x15_r0_body.cwS49.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_49.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck49 : krecLB PRE_first_tail_x15_r0_body.kappa49 2174 PRE_first_tail_x15_r0_body.cx0_49.mlx PRE_first_tail_x15_r0_body.kr0_49 PRE_first_tail_x15_r0_body.kr1_49 PRE_first_tail_x15_r0_body.clo49 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn49 : Nat.ble 2174 2174 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge49 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s485.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s486.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR49 : pendRegB PRE_first_tail_x15_r0_body.kappa49 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe49 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s485.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift49 (clean : Conv.NClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P49.NL) (cl : SSt (· < 2174) PRE_first_tail_x15_r0_body.cx0_49.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_49.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_49.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_49.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_49.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P49 2174 PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.s486.ffi PRE_first_tail_x15_r0_body.s485.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift49 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue49, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp49 t ht),
    PRE_first_tail_x15_r0_body.cbridge49,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s486.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s485.ffi) (PRE_first_tail_x15_r0_body.cfoot49 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_49 PRE_first_tail_x15_r0_body.ofx1_49 hobjC PRE_first_tail_x15_r0_body.ff049 PRE_first_tail_x15_r0_body.ff149 PRE_first_tail_x15_r0_body.ffck49,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s486.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s485.ffi) (PRE_first_tail_x15_r0_body.cfoot49 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_49 PRE_first_tail_x15_r0_body.okr1_49 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn49) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf049 PRE_first_tail_x15_r0_body.fkt049 PRE_first_tail_x15_r0_body.fkf149 PRE_first_tail_x15_r0_body.fkt149 PRE_first_tail_x15_r0_body.fkck49,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh049 PRE_first_tail_x15_r0_body.cnh149 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe49) PRE_first_tail_x15_r0_body.cpendR49⟩

end Host.Load.Run.Tpl
