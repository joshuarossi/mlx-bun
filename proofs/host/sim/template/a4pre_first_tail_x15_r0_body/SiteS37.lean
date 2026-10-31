import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl37
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 37 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc37 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P37 : LoadP := PRE_first_tail_x15_r0_body.Pc37.raise 16029
kernel_rfl PRE_first_tail_x15_r0_body.craise37 : Nat.ble PRE_first_tail_x15_r0_body.Pc37.N0 16029 = true
theorem PRE_first_tail_x15_r0_body.raised37 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc37 PRE_first_tail_x15_r0_body.P37 :=
  .inr ⟨16029, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise37, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_37 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s338.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_37 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s337.ffi)
def PRE_first_tail_x15_r0_body.khinv37 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv37 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS37 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS37 : List Nat := List.range' 16029 0
def PRE_first_tail_x15_r0_body.ciS37 : List Nat := [] ++ List.range' 16029 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh037 : PRE_first_tail_x15_r0_body.kd37.nh0 = PRE_first_tail_x15_r0_body.cx0_37.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh137 : PRE_first_tail_x15_r0_body.kd37.nh1 = PRE_first_tail_x15_r0_body.cx1_37.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn037 : PRE_first_tail_x15_r0_body.kd37.nn0 = PRE_first_tail_x15_r0_body.cx0_37.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn137 : PRE_first_tail_x15_r0_body.kd37.nn1 = PRE_first_tail_x15_r0_body.cx1_37.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo37 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P37.lo && Nat.ble PRE_first_tail_x15_r0_body.P37.lo PRE_first_tail_x15_r0_body.cx0_37.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P37.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P37.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt37 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_37.mlx.next PRE_first_tail_x15_r0_body.cx1_37.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_37.mlx.nnext PRE_first_tail_x15_r0_body.cx1_37.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband37 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P37.NL && Nat.ble PRE_first_tail_x15_r0_body.P37.NL PRE_first_tail_x15_r0_body.P37.N0 && Nat.ble PRE_first_tail_x15_r0_body.P37.N0 PRE_first_tail_x15_r0_body.cx0_37.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow37 : PRE_first_tail_x15_r0_body.kd37.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren37 : checkRenG PRE_first_tail_x15_r0_body.kd37.hnd PRE_first_tail_x15_r0_body.khinv37 (phB PRE_first_tail_x15_r0_body.cx0_37.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband37 : PRE_first_tail_x15_r0_body.kd37.checkBand PRE_first_tail_x15_r0_body.P37.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos37 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd37.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren37 : checkRenG PRE_first_tail_x15_r0_body.kd37.node PRE_first_tail_x15_r0_body.kninv37 (pnB PRE_first_tail_x15_r0_body.cx0_37.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow37 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd37.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P37.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd37.nodeF j) PRE_first_tail_x15_r0_body.cx1_37.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a37 : PRE_first_tail_x15_r0_body.cx0_37.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b37 : PRE_first_tail_x15_r0_body.cx0_37.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok137 : PRE_first_tail_x15_r0_body.cx1_37.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend37 : PRE_first_tail_x15_r0_body.cx1_37.mlx.pending = PRE_first_tail_x15_r0_body.cx0_37.mlx.pending.map PRE_first_tail_x15_r0_body.kappa37.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh37 : PRE_first_tail_x15_r0_body.cx1_37.mlx.errh = PRE_first_tail_x15_r0_body.cx0_37.mlx.errh.map PRE_first_tail_x15_r0_body.kappa37.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles37 : PRE_first_tail_x15_r0_body.cx1_37.mlx.files = PRE_first_tail_x15_r0_body.cx0_37.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch37 : PRE_first_tail_x15_r0_body.cx1_37.mlx.arch = PRE_first_tail_x15_r0_body.cx0_37.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes37 : PRE_first_tail_x15_r0_body.cx1_37.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_37.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired37 : PRE_first_tail_x15_r0_body.cx1_37.mlx.wired = PRE_first_tail_x15_r0_body.cx0_37.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost37 : PRE_first_tail_x15_r0_body.cx1_37.host = PRE_first_tail_x15_r0_body.cx0_37.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd37`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn037 : PRE_first_tail_x15_r0_body.kd37.n0 = 2704199
kernel_rfl PRE_first_tail_x15_r0_body.ckn137 : PRE_first_tail_x15_r0_body.kd37.n1 = 2704201
kernel_rfl PRE_first_tail_x15_r0_body.ckheap37 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd37.heap).all (fun x => Nat.ble 2704199 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl37 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd37.heap.get (2704199 + j) = nth? PRE_first_tail_x15_r0_body.pl37 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja37 : Nat.ble 2704199 2704199 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn37 : Nat.ble 1661 1661 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD37 : Nat.ble 2704199 PRE_first_tail_x15_r0_body.kd37.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn37 : Nat.ble 18940 PRE_first_tail_x15_r0_body.kd37.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn37 : Nat.ble 16029 PRE_first_tail_x15_r0_body.kd37.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb37 : Nat.ble 18940 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap37 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd37.heap).all (Nat.ble (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd37 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd37.hnd).all (Nat.ble (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode37 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd37.node).all (Nat.ble (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix37 : Conv.FixOld (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa37 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja37) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn37) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD37) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn37) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn37) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb37) PRE_first_tail_x15_r0_body.fheap37 PRE_first_tail_x15_r0_body.fhnd37 PRE_first_tail_x15_r0_body.fnode37
kernel_rfl PRE_first_tail_x15_r0_body.fcxn37 : (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn37 : (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle037 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_37.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_37.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk37 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd37.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A37 : PRE_first_tail_x15_r0_body.cx1_37.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS37.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_37.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O37 : PRE_first_tail_x15_r0_body.cx1_37.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS37.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_37.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N37 : PRE_first_tail_x15_r0_body.cx1_37.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS37.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_37.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I37 : PRE_first_tail_x15_r0_body.cx1_37.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS37.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_37.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd37 : (PRE_first_tail_x15_r0_body.clo37 ++ PRE_first_tail_x15_r0_body.cln37 ++ PRE_first_tail_x15_r0_body.cli37 ++ PRE_first_tail_x15_r0_body.cwS37 ++ PRE_first_tail_x15_r0_body.cnS37 ++ PRE_first_tail_x15_r0_body.ciS37).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW37 : PRE_first_tail_x15_r0_body.cwS37.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo37.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI37 : PRE_first_tail_x15_r0_body.ciS37.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli37.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN37 : PRE_first_tail_x15_r0_body.cnS37.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF37 : PRE_first_tail_x15_r0_body.cln37.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh37 : PRE_first_tail_x15_r0_body.clo37.all (handleOK PRE_first_tail_x15_r0_body.kappa37 PRE_first_tail_x15_r0_body.P37.lo PRE_first_tail_x15_r0_body.cx0_37.mlx PRE_first_tail_x15_r0_body.cx1_37.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo37 : PRE_first_tail_x15_r0_body.clo37.map (fun h => PRE_first_tail_x15_r0_body.cx1_37.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa37.handle h)) = PRE_first_tail_x15_r0_body.clo37.map (fun h => (PRE_first_tail_x15_r0_body.cx0_37.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa37.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok37 : PRE_first_tail_x15_r0_body.clo37.all (objOK PRE_first_tail_x15_r0_body.kappa37 PRE_first_tail_x15_r0_body.P37.NL PRE_first_tail_x15_r0_body.cx0_37.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd37 : PRE_first_tail_x15_r0_body.cln37.all (nodeOKF PRE_first_tail_x15_r0_body.kappa37 PRE_first_tail_x15_r0_body.P37 PRE_first_tail_x15_r0_body.cx0_37.mlx PRE_first_tail_x15_r0_body.cx1_37.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp37 : ((PRE_first_tail_x15_r0_body.cln37.filter (fullB PRE_first_tail_x15_r0_body.P37))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_37.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa37.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln37.filter (fullB PRE_first_tail_x15_r0_body.P37))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_37.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa37.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI37 : incrB PRE_first_tail_x15_r0_body.kd37.nodeF (List.range' 16029 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK37 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd37.node).all (fun k => Nat.ble 16029 k && Nat.blt k 16029) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL37 : (PRE_first_tail_x15_r0_body.cln37.filter (Nat.ble PRE_first_tail_x15_r0_body.P37.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd37.nodeF i) && (Nat.blt i 16029 || Nat.ble PRE_first_tail_x15_r0_body.kd37.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord37 : (PRE_first_tail_x15_r0_body.cln37.filter (Nat.ble PRE_first_tail_x15_r0_body.P37.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd37.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd37.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd37.nodeF j) (PRE_first_tail_x15_r0_body.kd37.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow37 PRE_first_tail_x15_r0_body.cnn137 PRE_first_tail_x15_r0_body.fnordI37 PRE_first_tail_x15_r0_body.fnordK37 PRE_first_tail_x15_r0_body.fnordL37
kernel_rfl PRE_first_tail_x15_r0_body.fi37 : PRE_first_tail_x15_r0_body.cli37.all (pnB PRE_first_tail_x15_r0_body.cx0_37.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii37 : PRE_first_tail_x15_r0_body.cli37.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_37.mlx.items.get (PRE_first_tail_x15_r0_body.kappa37.node k) = (PRE_first_tail_x15_r0_body.cx0_37.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa37.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot37 (clean : Conv.NClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P37.NL) (cl : SSt (· < 1661) PRE_first_tail_x15_r0_body.cx0_37.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P37 1661 PRE_first_tail_x15_r0_body.kappa37 PRE_first_tail_x15_r0_body.kd37 PRE_first_tail_x15_r0_body.khinv37 PRE_first_tail_x15_r0_body.kninv37 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx PRE_first_tail_x15_r0_body.cx0_37.mlx PRE_first_tail_x15_r0_body.cx1_37.mlx (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo37 PRE_first_tail_x15_r0_body.cln37 PRE_first_tail_x15_r0_body.cli37 PRE_first_tail_x15_r0_body.cwS37 PRE_first_tail_x15_r0_body.cnS37 PRE_first_tail_x15_r0_body.ciS37 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh037, PRE_first_tail_x15_r0_body.cnh137, PRE_first_tail_x15_r0_body.cnn037, PRE_first_tail_x15_r0_body.cnn137, PRE_first_tail_x15_r0_body.cplo37, PRE_first_tail_x15_r0_body.ccnt37, PRE_first_tail_x15_r0_body.cnband37, PRE_first_tail_x15_r0_body.chbelow37, PRE_first_tail_x15_r0_body.chren37, PRE_first_tail_x15_r0_body.cband37, PRE_first_tail_x15_r0_body.cnh1pos37, PRE_first_tail_x15_r0_body.cnren37, PRE_first_tail_x15_r0_body.cnlow37, PRE_first_tail_x15_r0_body.cabs0a37, PRE_first_tail_x15_r0_body.cabs0b37, PRE_first_tail_x15_r0_body.ctok137, PRE_first_tail_x15_r0_body.cpend37, PRE_first_tail_x15_r0_body.cerrh37, PRE_first_tail_x15_r0_body.cfiles37, PRE_first_tail_x15_r0_body.carch37, PRE_first_tail_x15_r0_body.csizes37, PRE_first_tail_x15_r0_body.cwired37, PRE_first_tail_x15_r0_body.cfix37, clean, PRE_first_tail_x15_r0_body.fcxn37, PRE_first_tail_x15_r0_body.fcnn37, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle037, PRE_first_tail_x15_r0_body.fnk37, PRE_first_tail_x15_r0_body.ckA37, PRE_first_tail_x15_r0_body.cobjsK37, PRE_first_tail_x15_r0_body.cnodesK37, PRE_first_tail_x15_r0_body.citemsK37, PRE_first_tail_x15_r0_body.f1A37, PRE_first_tail_x15_r0_body.f1O37, PRE_first_tail_x15_r0_body.f1N37, PRE_first_tail_x15_r0_body.f1I37, PRE_first_tail_x15_r0_body.fbd37, PRE_first_tail_x15_r0_body.fincW37, PRE_first_tail_x15_r0_body.fincI37, PRE_first_tail_x15_r0_body.fincN37, PRE_first_tail_x15_r0_body.flnF37, PRE_first_tail_x15_r0_body.fh37, PRE_first_tail_x15_r0_body.fo37, PRE_first_tail_x15_r0_body.fok37, PRE_first_tail_x15_r0_body.fnd37, PRE_first_tail_x15_r0_body.fp37, PRE_first_tail_x15_r0_body.fnord37, PRE_first_tail_x15_r0_body.fi37, PRE_first_tail_x15_r0_body.fii37⟩
theorem PRE_first_tail_x15_r0_body.cnshift37 (clean : Conv.NClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P37.NL) (cl : SSt (· < 1661) PRE_first_tail_x15_r0_body.cx0_37.mlx) : NShift PRE_first_tail_x15_r0_body.P37 1661 PRE_first_tail_x15_r0_body.kappa37 PRE_first_tail_x15_r0_body.cx0_37 PRE_first_tail_x15_r0_body.cx1_37 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot37 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost37 (compact_a_eq PRE_first_tail_x15_r0_body.ckn037 PRE_first_tail_x15_r0_body.ckn137 PRE_first_tail_x15_r0_body.ckheap37 PRE_first_tail_x15_r0_body.ckpl37)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_37 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s336.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_37 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s336.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_37 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s336.ffi) = some PRE_first_tail_x15_r0_body.fxC_37
kernel_rfl PRE_first_tail_x15_r0_body.okrC_37 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s336.ffi) = some PRE_first_tail_x15_r0_body.krC_37
noncomputable def PRE_first_tail_x15_r0_body.fx0_37 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s338.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_37 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s338.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_37 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s338.ffi) = some PRE_first_tail_x15_r0_body.fx0_37
kernel_rfl PRE_first_tail_x15_r0_body.okr0_37 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s338.ffi) = some PRE_first_tail_x15_r0_body.kr0_37
noncomputable def PRE_first_tail_x15_r0_body.fx1_37 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s337.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_37 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s337.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_37 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s337.ffi) = some PRE_first_tail_x15_r0_body.fx1_37
kernel_rfl PRE_first_tail_x15_r0_body.okr1_37 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s337.ffi) = some PRE_first_tail_x15_r0_body.kr1_37
kernel_rfl PRE_first_tail_x15_r0_body.ff037 : PRE_first_tail_x15_r0_body.fx0_37 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_37 (PRE_first_tail_x15_r0_body.clo37.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_37.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff137 : PRE_first_tail_x15_r0_body.fx1_37 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_37 (PRE_first_tail_x15_r0_body.cwS37.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_37.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck37 : freedLB PRE_first_tail_x15_r0_body.kappa37 PRE_first_tail_x15_r0_body.cx0_37.mlx PRE_first_tail_x15_r0_body.fx0_37 PRE_first_tail_x15_r0_body.fx1_37 PRE_first_tail_x15_r0_body.clo37 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf037 : PRE_first_tail_x15_r0_body.kr0_37.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_37.flags (PRE_first_tail_x15_r0_body.clo37.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_37.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt037 : PRE_first_tail_x15_r0_body.kr0_37.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_37.targs (PRE_first_tail_x15_r0_body.clo37.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_37.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf137 : PRE_first_tail_x15_r0_body.kr1_37.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_37.flags (PRE_first_tail_x15_r0_body.cwS37.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_37.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt137 : PRE_first_tail_x15_r0_body.kr1_37.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_37.targs (PRE_first_tail_x15_r0_body.cwS37.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_37.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck37 : krecLB PRE_first_tail_x15_r0_body.kappa37 1661 PRE_first_tail_x15_r0_body.cx0_37.mlx PRE_first_tail_x15_r0_body.kr0_37 PRE_first_tail_x15_r0_body.kr1_37 PRE_first_tail_x15_r0_body.clo37 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn37 : Nat.ble 1661 1661 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge37 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s337.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s338.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR37 : pendRegB PRE_first_tail_x15_r0_body.kappa37 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s338.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe37 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s338.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s337.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift37 (clean : Conv.NClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P37.NL) (cl : SSt (· < 1661) PRE_first_tail_x15_r0_body.cx0_37.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_37.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_37.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_37.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s336.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_37.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P37 1661 PRE_first_tail_x15_r0_body.kappa37 PRE_first_tail_x15_r0_body.s338.ffi PRE_first_tail_x15_r0_body.s337.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift37 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue37, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp37 t ht),
    PRE_first_tail_x15_r0_body.cbridge37,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s338.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s337.ffi) (PRE_first_tail_x15_r0_body.cfoot37 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_37 PRE_first_tail_x15_r0_body.ofx1_37 hobjC PRE_first_tail_x15_r0_body.ff037 PRE_first_tail_x15_r0_body.ff137 PRE_first_tail_x15_r0_body.ffck37,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s338.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s337.ffi) (PRE_first_tail_x15_r0_body.cfoot37 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_37 PRE_first_tail_x15_r0_body.okr1_37 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn37) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf037 PRE_first_tail_x15_r0_body.fkt037 PRE_first_tail_x15_r0_body.fkf137 PRE_first_tail_x15_r0_body.fkt137 PRE_first_tail_x15_r0_body.fkck37,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh037 PRE_first_tail_x15_r0_body.cnh137 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe37) PRE_first_tail_x15_r0_body.cpendR37⟩

end Host.Load.Run.Tpl
