import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl140
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 140 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc140 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P140 : LoadP := PRE_first_tail_x15_r0_body.Pc140.raise 18055
kernel_rfl PRE_first_tail_x15_r0_body.craise140 : Nat.ble PRE_first_tail_x15_r0_body.Pc140.N0 18055 = true
theorem PRE_first_tail_x15_r0_body.raised140 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc140 PRE_first_tail_x15_r0_body.P140 :=
  .inr ⟨18055, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise140, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_140 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_140 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1235.ffi)
def PRE_first_tail_x15_r0_body.khinv140 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv140 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS140 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS140 : List Nat := List.range' 18055 0
def PRE_first_tail_x15_r0_body.ciS140 : List Nat := [] ++ List.range' 18055 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0140 : PRE_first_tail_x15_r0_body.kd140.nh0 = PRE_first_tail_x15_r0_body.cx0_140.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1140 : PRE_first_tail_x15_r0_body.kd140.nh1 = PRE_first_tail_x15_r0_body.cx1_140.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0140 : PRE_first_tail_x15_r0_body.kd140.nn0 = PRE_first_tail_x15_r0_body.cx0_140.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1140 : PRE_first_tail_x15_r0_body.kd140.nn1 = PRE_first_tail_x15_r0_body.cx1_140.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo140 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P140.lo && Nat.ble PRE_first_tail_x15_r0_body.P140.lo PRE_first_tail_x15_r0_body.cx0_140.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P140.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P140.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt140 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_140.mlx.next PRE_first_tail_x15_r0_body.cx1_140.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_140.mlx.nnext PRE_first_tail_x15_r0_body.cx1_140.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband140 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P140.NL && Nat.ble PRE_first_tail_x15_r0_body.P140.NL PRE_first_tail_x15_r0_body.P140.N0 && Nat.ble PRE_first_tail_x15_r0_body.P140.N0 PRE_first_tail_x15_r0_body.cx0_140.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow140 : PRE_first_tail_x15_r0_body.kd140.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren140 : checkRenG PRE_first_tail_x15_r0_body.kd140.hnd PRE_first_tail_x15_r0_body.khinv140 (phB PRE_first_tail_x15_r0_body.cx0_140.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband140 : PRE_first_tail_x15_r0_body.kd140.checkBand PRE_first_tail_x15_r0_body.P140.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos140 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd140.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren140 : checkRenG PRE_first_tail_x15_r0_body.kd140.node PRE_first_tail_x15_r0_body.kninv140 (pnB PRE_first_tail_x15_r0_body.cx0_140.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P140.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd140.nodeF j) PRE_first_tail_x15_r0_body.cx1_140.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a140 : PRE_first_tail_x15_r0_body.cx0_140.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b140 : PRE_first_tail_x15_r0_body.cx0_140.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.pending = PRE_first_tail_x15_r0_body.cx0_140.mlx.pending.map PRE_first_tail_x15_r0_body.kappa140.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.errh = PRE_first_tail_x15_r0_body.cx0_140.mlx.errh.map PRE_first_tail_x15_r0_body.kappa140.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.files = PRE_first_tail_x15_r0_body.cx0_140.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.arch = PRE_first_tail_x15_r0_body.cx0_140.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_140.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.wired = PRE_first_tail_x15_r0_body.cx0_140.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost140 : PRE_first_tail_x15_r0_body.cx1_140.host = PRE_first_tail_x15_r0_body.cx0_140.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd140`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0140 : PRE_first_tail_x15_r0_body.kd140.n0 = 2784336
kernel_rfl PRE_first_tail_x15_r0_body.ckn1140 : PRE_first_tail_x15_r0_body.kd140.n1 = 2784355
kernel_rfl PRE_first_tail_x15_r0_body.ckheap140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.heap).all (fun x => Nat.ble 2784335 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl140 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd140.heap.get (2784335 + j) = nth? PRE_first_tail_x15_r0_body.pl140 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja140 : Nat.ble 2784335 2784335 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn140 : Nat.ble 6040 6040 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD140 : Nat.ble 2784335 PRE_first_tail_x15_r0_body.kd140.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn140 : Nat.ble 20949 PRE_first_tail_x15_r0_body.kd140.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn140 : Nat.ble 18055 PRE_first_tail_x15_r0_body.kd140.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb140 : Nat.ble 20949 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.heap).all (Nat.ble (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.hnd).all (Nat.ble (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.node).all (Nat.ble (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix140 : Conv.FixOld (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa140 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja140) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn140) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD140) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn140) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn140) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb140) PRE_first_tail_x15_r0_body.fheap140 PRE_first_tail_x15_r0_body.fhnd140 PRE_first_tail_x15_r0_body.fnode140
kernel_rfl PRE_first_tail_x15_r0_body.fcxn140 : (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn140 : (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0140 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_140.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_140.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS140.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_140.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS140.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_140.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS140.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_140.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS140.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_140.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd140 : (PRE_first_tail_x15_r0_body.clo140 ++ PRE_first_tail_x15_r0_body.cln140 ++ PRE_first_tail_x15_r0_body.cli140 ++ PRE_first_tail_x15_r0_body.cwS140 ++ PRE_first_tail_x15_r0_body.cnS140 ++ PRE_first_tail_x15_r0_body.ciS140).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW140 : PRE_first_tail_x15_r0_body.cwS140.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo140.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI140 : PRE_first_tail_x15_r0_body.ciS140.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli140.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN140 : PRE_first_tail_x15_r0_body.cnS140.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF140 : PRE_first_tail_x15_r0_body.cln140.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh140 : PRE_first_tail_x15_r0_body.clo140.all (handleOK PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.P140.lo PRE_first_tail_x15_r0_body.cx0_140.mlx PRE_first_tail_x15_r0_body.cx1_140.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo140 : PRE_first_tail_x15_r0_body.clo140.map (fun h => PRE_first_tail_x15_r0_body.cx1_140.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa140.handle h)) = PRE_first_tail_x15_r0_body.clo140.map (fun h => (PRE_first_tail_x15_r0_body.cx0_140.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa140.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok140 : PRE_first_tail_x15_r0_body.clo140.all (objOK PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.P140.NL PRE_first_tail_x15_r0_body.cx0_140.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd140 : PRE_first_tail_x15_r0_body.cln140.all (nodeOKF PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.P140 PRE_first_tail_x15_r0_body.cx0_140.mlx PRE_first_tail_x15_r0_body.cx1_140.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp140 : ((PRE_first_tail_x15_r0_body.cln140.filter (fullB PRE_first_tail_x15_r0_body.P140))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_140.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa140.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln140.filter (fullB PRE_first_tail_x15_r0_body.P140))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_140.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa140.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI140 : incrB PRE_first_tail_x15_r0_body.kd140.nodeF (List.range' 18055 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.node).all (fun k => Nat.ble 18055 k && Nat.blt k 18055) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL140 : (PRE_first_tail_x15_r0_body.cln140.filter (Nat.ble PRE_first_tail_x15_r0_body.P140.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd140.nodeF i) && (Nat.blt i 18055 || Nat.ble PRE_first_tail_x15_r0_body.kd140.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord140 : (PRE_first_tail_x15_r0_body.cln140.filter (Nat.ble PRE_first_tail_x15_r0_body.P140.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd140.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd140.nodeF j) (PRE_first_tail_x15_r0_body.kd140.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow140 PRE_first_tail_x15_r0_body.cnn1140 PRE_first_tail_x15_r0_body.fnordI140 PRE_first_tail_x15_r0_body.fnordK140 PRE_first_tail_x15_r0_body.fnordL140
kernel_rfl PRE_first_tail_x15_r0_body.fi140 : PRE_first_tail_x15_r0_body.cli140.all (pnB PRE_first_tail_x15_r0_body.cx0_140.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii140 : PRE_first_tail_x15_r0_body.cli140.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_140.mlx.items.get (PRE_first_tail_x15_r0_body.kappa140.node k) = (PRE_first_tail_x15_r0_body.cx0_140.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa140.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot140 (clean : Conv.NClean (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P140.NL) (cl : SSt (· < 6040) PRE_first_tail_x15_r0_body.cx0_140.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P140 6040 PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.kd140 PRE_first_tail_x15_r0_body.khinv140 PRE_first_tail_x15_r0_body.kninv140 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx PRE_first_tail_x15_r0_body.cx0_140.mlx PRE_first_tail_x15_r0_body.cx1_140.mlx (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo140 PRE_first_tail_x15_r0_body.cln140 PRE_first_tail_x15_r0_body.cli140 PRE_first_tail_x15_r0_body.cwS140 PRE_first_tail_x15_r0_body.cnS140 PRE_first_tail_x15_r0_body.ciS140 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0140, PRE_first_tail_x15_r0_body.cnh1140, PRE_first_tail_x15_r0_body.cnn0140, PRE_first_tail_x15_r0_body.cnn1140, PRE_first_tail_x15_r0_body.cplo140, PRE_first_tail_x15_r0_body.ccnt140, PRE_first_tail_x15_r0_body.cnband140, PRE_first_tail_x15_r0_body.chbelow140, PRE_first_tail_x15_r0_body.chren140, PRE_first_tail_x15_r0_body.cband140, PRE_first_tail_x15_r0_body.cnh1pos140, PRE_first_tail_x15_r0_body.cnren140, PRE_first_tail_x15_r0_body.cnlow140, PRE_first_tail_x15_r0_body.cabs0a140, PRE_first_tail_x15_r0_body.cabs0b140, PRE_first_tail_x15_r0_body.ctok1140, PRE_first_tail_x15_r0_body.cpend140, PRE_first_tail_x15_r0_body.cerrh140, PRE_first_tail_x15_r0_body.cfiles140, PRE_first_tail_x15_r0_body.carch140, PRE_first_tail_x15_r0_body.csizes140, PRE_first_tail_x15_r0_body.cwired140, PRE_first_tail_x15_r0_body.cfix140, clean, PRE_first_tail_x15_r0_body.fcxn140, PRE_first_tail_x15_r0_body.fcnn140, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0140, PRE_first_tail_x15_r0_body.fnk140, PRE_first_tail_x15_r0_body.ckA140, PRE_first_tail_x15_r0_body.cobjsK140, PRE_first_tail_x15_r0_body.cnodesK140, PRE_first_tail_x15_r0_body.citemsK140, PRE_first_tail_x15_r0_body.f1A140, PRE_first_tail_x15_r0_body.f1O140, PRE_first_tail_x15_r0_body.f1N140, PRE_first_tail_x15_r0_body.f1I140, PRE_first_tail_x15_r0_body.fbd140, PRE_first_tail_x15_r0_body.fincW140, PRE_first_tail_x15_r0_body.fincI140, PRE_first_tail_x15_r0_body.fincN140, PRE_first_tail_x15_r0_body.flnF140, PRE_first_tail_x15_r0_body.fh140, PRE_first_tail_x15_r0_body.fo140, PRE_first_tail_x15_r0_body.fok140, PRE_first_tail_x15_r0_body.fnd140, PRE_first_tail_x15_r0_body.fp140, PRE_first_tail_x15_r0_body.fnord140, PRE_first_tail_x15_r0_body.fi140, PRE_first_tail_x15_r0_body.fii140⟩
theorem PRE_first_tail_x15_r0_body.cnshift140 (clean : Conv.NClean (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P140.NL) (cl : SSt (· < 6040) PRE_first_tail_x15_r0_body.cx0_140.mlx) : NShift PRE_first_tail_x15_r0_body.P140 6040 PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.cx0_140 PRE_first_tail_x15_r0_body.cx1_140 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot140 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost140 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0140 PRE_first_tail_x15_r0_body.ckn1140 PRE_first_tail_x15_r0_body.ckheap140 PRE_first_tail_x15_r0_body.ckpl140)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_140 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1234.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_140 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1234.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_140 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1234.ffi) = some PRE_first_tail_x15_r0_body.fxC_140
kernel_rfl PRE_first_tail_x15_r0_body.okrC_140 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1234.ffi) = some PRE_first_tail_x15_r0_body.krC_140
noncomputable def PRE_first_tail_x15_r0_body.fx0_140 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1236.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_140 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1236.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_140 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1236.ffi) = some PRE_first_tail_x15_r0_body.fx0_140
kernel_rfl PRE_first_tail_x15_r0_body.okr0_140 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1236.ffi) = some PRE_first_tail_x15_r0_body.kr0_140
noncomputable def PRE_first_tail_x15_r0_body.fx1_140 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1235.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_140 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1235.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_140 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1235.ffi) = some PRE_first_tail_x15_r0_body.fx1_140
kernel_rfl PRE_first_tail_x15_r0_body.okr1_140 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1235.ffi) = some PRE_first_tail_x15_r0_body.kr1_140
kernel_rfl PRE_first_tail_x15_r0_body.ff0140 : PRE_first_tail_x15_r0_body.fx0_140 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_140 (PRE_first_tail_x15_r0_body.clo140.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_140.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1140 : PRE_first_tail_x15_r0_body.fx1_140 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_140 (PRE_first_tail_x15_r0_body.cwS140.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_140.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck140 : freedLB PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.cx0_140.mlx PRE_first_tail_x15_r0_body.fx0_140 PRE_first_tail_x15_r0_body.fx1_140 PRE_first_tail_x15_r0_body.clo140 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0140 : PRE_first_tail_x15_r0_body.kr0_140.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_140.flags (PRE_first_tail_x15_r0_body.clo140.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_140.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0140 : PRE_first_tail_x15_r0_body.kr0_140.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_140.targs (PRE_first_tail_x15_r0_body.clo140.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_140.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1140 : PRE_first_tail_x15_r0_body.kr1_140.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_140.flags (PRE_first_tail_x15_r0_body.cwS140.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_140.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1140 : PRE_first_tail_x15_r0_body.kr1_140.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_140.targs (PRE_first_tail_x15_r0_body.cwS140.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_140.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck140 : krecLB PRE_first_tail_x15_r0_body.kappa140 6040 PRE_first_tail_x15_r0_body.cx0_140.mlx PRE_first_tail_x15_r0_body.kr0_140 PRE_first_tail_x15_r0_body.kr1_140 PRE_first_tail_x15_r0_body.clo140 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn140 : Nat.ble 6040 6040 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge140 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1235.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1236.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR140 : pendRegB PRE_first_tail_x15_r0_body.kappa140 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe140 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1235.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift140 (clean : Conv.NClean (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P140.NL) (cl : SSt (· < 6040) PRE_first_tail_x15_r0_body.cx0_140.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_140.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_140.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_140.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_140.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P140 6040 PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.s1236.ffi PRE_first_tail_x15_r0_body.s1235.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift140 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue140, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp140 t ht),
    PRE_first_tail_x15_r0_body.cbridge140,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1236.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1235.ffi) (PRE_first_tail_x15_r0_body.cfoot140 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_140 PRE_first_tail_x15_r0_body.ofx1_140 hobjC PRE_first_tail_x15_r0_body.ff0140 PRE_first_tail_x15_r0_body.ff1140 PRE_first_tail_x15_r0_body.ffck140,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1236.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1235.ffi) (PRE_first_tail_x15_r0_body.cfoot140 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_140 PRE_first_tail_x15_r0_body.okr1_140 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn140) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0140 PRE_first_tail_x15_r0_body.fkt0140 PRE_first_tail_x15_r0_body.fkf1140 PRE_first_tail_x15_r0_body.fkt1140 PRE_first_tail_x15_r0_body.fkck140,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0140 PRE_first_tail_x15_r0_body.cnh1140 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe140) PRE_first_tail_x15_r0_body.cpendR140⟩

end Host.Load.Run.Tpl
