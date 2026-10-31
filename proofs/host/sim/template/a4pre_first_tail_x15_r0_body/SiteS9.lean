import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl9
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 9 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc9 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P9 : LoadP := PRE_first_tail_x15_r0_body.Pc9.raise 15482
kernel_rfl PRE_first_tail_x15_r0_body.craise9 : Nat.ble PRE_first_tail_x15_r0_body.Pc9.N0 15482 = true
theorem PRE_first_tail_x15_r0_body.raised9 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc9 PRE_first_tail_x15_r0_body.P9 :=
  .inr ⟨15482, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise9, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_9 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_9 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s103.ffi)
def PRE_first_tail_x15_r0_body.khinv9 : PTrie Nat := Stage.setAll PTrie.nil [(18395, 18393), (18396, 18394), (18398, 18395), (18397, 18396)]
def PRE_first_tail_x15_r0_body.kninv9 : PTrie Nat := Stage.setAll PTrie.nil [(15476, 15476), (15477, 15477), (15478, 15478), (15479, 15479), (15480, 15480), (15481, 15481)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS9 : List Nat := [18393, 18394, 18395, 18396, 18397, 18398]
def PRE_first_tail_x15_r0_body.cnS9 : List Nat := List.range' 15476 6
def PRE_first_tail_x15_r0_body.ciS9 : List Nat := [] ++ List.range' 15476 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh09 : PRE_first_tail_x15_r0_body.kd9.nh0 = PRE_first_tail_x15_r0_body.cx0_9.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh19 : PRE_first_tail_x15_r0_body.kd9.nh1 = PRE_first_tail_x15_r0_body.cx1_9.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn09 : PRE_first_tail_x15_r0_body.kd9.nn0 = PRE_first_tail_x15_r0_body.cx0_9.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn19 : PRE_first_tail_x15_r0_body.kd9.nn1 = PRE_first_tail_x15_r0_body.cx1_9.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo9 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P9.lo && Nat.ble PRE_first_tail_x15_r0_body.P9.lo PRE_first_tail_x15_r0_body.cx0_9.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P9.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P9.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt9 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_9.mlx.next PRE_first_tail_x15_r0_body.cx1_9.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_9.mlx.nnext PRE_first_tail_x15_r0_body.cx1_9.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband9 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P9.NL && Nat.ble PRE_first_tail_x15_r0_body.P9.NL PRE_first_tail_x15_r0_body.P9.N0 && Nat.ble PRE_first_tail_x15_r0_body.P9.N0 PRE_first_tail_x15_r0_body.cx0_9.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow9 : PRE_first_tail_x15_r0_body.kd9.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren9 : checkRenG PRE_first_tail_x15_r0_body.kd9.hnd PRE_first_tail_x15_r0_body.khinv9 (phB PRE_first_tail_x15_r0_body.cx0_9.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband9 : PRE_first_tail_x15_r0_body.kd9.checkBand PRE_first_tail_x15_r0_body.P9.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos9 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd9.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren9 : checkRenG PRE_first_tail_x15_r0_body.kd9.node PRE_first_tail_x15_r0_body.kninv9 (pnB PRE_first_tail_x15_r0_body.cx0_9.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow9 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd9.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P9.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd9.nodeF j) PRE_first_tail_x15_r0_body.cx1_9.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a9 : PRE_first_tail_x15_r0_body.cx0_9.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b9 : PRE_first_tail_x15_r0_body.cx0_9.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok19 : PRE_first_tail_x15_r0_body.cx1_9.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend9 : PRE_first_tail_x15_r0_body.cx1_9.mlx.pending = PRE_first_tail_x15_r0_body.cx0_9.mlx.pending.map PRE_first_tail_x15_r0_body.kappa9.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh9 : PRE_first_tail_x15_r0_body.cx1_9.mlx.errh = PRE_first_tail_x15_r0_body.cx0_9.mlx.errh.map PRE_first_tail_x15_r0_body.kappa9.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles9 : PRE_first_tail_x15_r0_body.cx1_9.mlx.files = PRE_first_tail_x15_r0_body.cx0_9.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch9 : PRE_first_tail_x15_r0_body.cx1_9.mlx.arch = PRE_first_tail_x15_r0_body.cx0_9.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes9 : PRE_first_tail_x15_r0_body.cx1_9.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_9.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired9 : PRE_first_tail_x15_r0_body.cx1_9.mlx.wired = PRE_first_tail_x15_r0_body.cx0_9.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost9 : PRE_first_tail_x15_r0_body.cx1_9.host = PRE_first_tail_x15_r0_body.cx0_9.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd9`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn09 : PRE_first_tail_x15_r0_body.kd9.n0 = 2682509
kernel_rfl PRE_first_tail_x15_r0_body.ckn19 : PRE_first_tail_x15_r0_body.kd9.n1 = 2682859
kernel_rfl PRE_first_tail_x15_r0_body.ckheap9 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd9.heap).all (fun x => Nat.ble 2682494 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl9 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd9.heap.get (2682494 + j) = nth? PRE_first_tail_x15_r0_body.pl9 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja9 : Nat.ble 2682494 2682494 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn9 : Nat.ble 474 474 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD9 : Nat.ble 2682494 PRE_first_tail_x15_r0_body.kd9.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn9 : Nat.ble 18393 PRE_first_tail_x15_r0_body.kd9.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn9 : Nat.ble 15476 PRE_first_tail_x15_r0_body.kd9.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb9 : Nat.ble 18393 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap9 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd9.heap).all (Nat.ble (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd9 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd9.hnd).all (Nat.ble (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode9 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd9.node).all (Nat.ble (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix9 : Conv.FixOld (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa9 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja9) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn9) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD9) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn9) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn9) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb9) PRE_first_tail_x15_r0_body.fheap9 PRE_first_tail_x15_r0_body.fhnd9 PRE_first_tail_x15_r0_body.fnode9
kernel_rfl PRE_first_tail_x15_r0_body.fcxn9 : (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn9 : (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle09 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_9.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_9.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk9 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd9.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A9 : PRE_first_tail_x15_r0_body.cx1_9.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS9.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_9.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O9 : PRE_first_tail_x15_r0_body.cx1_9.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS9.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_9.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N9 : PRE_first_tail_x15_r0_body.cx1_9.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS9.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_9.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I9 : PRE_first_tail_x15_r0_body.cx1_9.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS9.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_9.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd9 : (PRE_first_tail_x15_r0_body.clo9 ++ PRE_first_tail_x15_r0_body.cln9 ++ PRE_first_tail_x15_r0_body.cli9 ++ PRE_first_tail_x15_r0_body.cwS9 ++ PRE_first_tail_x15_r0_body.cnS9 ++ PRE_first_tail_x15_r0_body.ciS9).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW9 : PRE_first_tail_x15_r0_body.cwS9.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo9.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI9 : PRE_first_tail_x15_r0_body.ciS9.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli9.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN9 : PRE_first_tail_x15_r0_body.cnS9.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF9 : PRE_first_tail_x15_r0_body.cln9.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh9 : PRE_first_tail_x15_r0_body.clo9.all (handleOK PRE_first_tail_x15_r0_body.kappa9 PRE_first_tail_x15_r0_body.P9.lo PRE_first_tail_x15_r0_body.cx0_9.mlx PRE_first_tail_x15_r0_body.cx1_9.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo9 : PRE_first_tail_x15_r0_body.clo9.map (fun h => PRE_first_tail_x15_r0_body.cx1_9.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa9.handle h)) = PRE_first_tail_x15_r0_body.clo9.map (fun h => (PRE_first_tail_x15_r0_body.cx0_9.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa9.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok9 : PRE_first_tail_x15_r0_body.clo9.all (objOK PRE_first_tail_x15_r0_body.kappa9 PRE_first_tail_x15_r0_body.P9.NL PRE_first_tail_x15_r0_body.cx0_9.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd9 : PRE_first_tail_x15_r0_body.cln9.all (nodeOKF PRE_first_tail_x15_r0_body.kappa9 PRE_first_tail_x15_r0_body.P9 PRE_first_tail_x15_r0_body.cx0_9.mlx PRE_first_tail_x15_r0_body.cx1_9.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp9 : ((PRE_first_tail_x15_r0_body.cln9.filter (fullB PRE_first_tail_x15_r0_body.P9))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_9.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa9.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln9.filter (fullB PRE_first_tail_x15_r0_body.P9))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_9.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa9.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI9 : incrB PRE_first_tail_x15_r0_body.kd9.nodeF (List.range' 15476 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK9 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd9.node).all (fun k => Nat.ble 15476 k && Nat.blt k 15482) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL9 : (PRE_first_tail_x15_r0_body.cln9.filter (Nat.ble PRE_first_tail_x15_r0_body.P9.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd9.nodeF i) && (Nat.blt i 15482 || Nat.ble PRE_first_tail_x15_r0_body.kd9.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord9 : (PRE_first_tail_x15_r0_body.cln9.filter (Nat.ble PRE_first_tail_x15_r0_body.P9.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd9.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd9.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd9.nodeF j) (PRE_first_tail_x15_r0_body.kd9.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow9 PRE_first_tail_x15_r0_body.cnn19 PRE_first_tail_x15_r0_body.fnordI9 PRE_first_tail_x15_r0_body.fnordK9 PRE_first_tail_x15_r0_body.fnordL9
kernel_rfl PRE_first_tail_x15_r0_body.fi9 : PRE_first_tail_x15_r0_body.cli9.all (pnB PRE_first_tail_x15_r0_body.cx0_9.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii9 : PRE_first_tail_x15_r0_body.cli9.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_9.mlx.items.get (PRE_first_tail_x15_r0_body.kappa9.node k) = (PRE_first_tail_x15_r0_body.cx0_9.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa9.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot9 (clean : Conv.NClean (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P9.NL) (cl : SSt (· < 483) PRE_first_tail_x15_r0_body.cx0_9.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P9 483 PRE_first_tail_x15_r0_body.kappa9 PRE_first_tail_x15_r0_body.kd9 PRE_first_tail_x15_r0_body.khinv9 PRE_first_tail_x15_r0_body.kninv9 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx PRE_first_tail_x15_r0_body.cx0_9.mlx PRE_first_tail_x15_r0_body.cx1_9.mlx (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo9 PRE_first_tail_x15_r0_body.cln9 PRE_first_tail_x15_r0_body.cli9 PRE_first_tail_x15_r0_body.cwS9 PRE_first_tail_x15_r0_body.cnS9 PRE_first_tail_x15_r0_body.ciS9 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh09, PRE_first_tail_x15_r0_body.cnh19, PRE_first_tail_x15_r0_body.cnn09, PRE_first_tail_x15_r0_body.cnn19, PRE_first_tail_x15_r0_body.cplo9, PRE_first_tail_x15_r0_body.ccnt9, PRE_first_tail_x15_r0_body.cnband9, PRE_first_tail_x15_r0_body.chbelow9, PRE_first_tail_x15_r0_body.chren9, PRE_first_tail_x15_r0_body.cband9, PRE_first_tail_x15_r0_body.cnh1pos9, PRE_first_tail_x15_r0_body.cnren9, PRE_first_tail_x15_r0_body.cnlow9, PRE_first_tail_x15_r0_body.cabs0a9, PRE_first_tail_x15_r0_body.cabs0b9, PRE_first_tail_x15_r0_body.ctok19, PRE_first_tail_x15_r0_body.cpend9, PRE_first_tail_x15_r0_body.cerrh9, PRE_first_tail_x15_r0_body.cfiles9, PRE_first_tail_x15_r0_body.carch9, PRE_first_tail_x15_r0_body.csizes9, PRE_first_tail_x15_r0_body.cwired9, PRE_first_tail_x15_r0_body.cfix9, clean, PRE_first_tail_x15_r0_body.fcxn9, PRE_first_tail_x15_r0_body.fcnn9, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle09, PRE_first_tail_x15_r0_body.fnk9, PRE_first_tail_x15_r0_body.ckA9, PRE_first_tail_x15_r0_body.cobjsK9, PRE_first_tail_x15_r0_body.cnodesK9, PRE_first_tail_x15_r0_body.citemsK9, PRE_first_tail_x15_r0_body.f1A9, PRE_first_tail_x15_r0_body.f1O9, PRE_first_tail_x15_r0_body.f1N9, PRE_first_tail_x15_r0_body.f1I9, PRE_first_tail_x15_r0_body.fbd9, PRE_first_tail_x15_r0_body.fincW9, PRE_first_tail_x15_r0_body.fincI9, PRE_first_tail_x15_r0_body.fincN9, PRE_first_tail_x15_r0_body.flnF9, PRE_first_tail_x15_r0_body.fh9, PRE_first_tail_x15_r0_body.fo9, PRE_first_tail_x15_r0_body.fok9, PRE_first_tail_x15_r0_body.fnd9, PRE_first_tail_x15_r0_body.fp9, PRE_first_tail_x15_r0_body.fnord9, PRE_first_tail_x15_r0_body.fi9, PRE_first_tail_x15_r0_body.fii9⟩
theorem PRE_first_tail_x15_r0_body.cnshift9 (clean : Conv.NClean (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P9.NL) (cl : SSt (· < 483) PRE_first_tail_x15_r0_body.cx0_9.mlx) : NShift PRE_first_tail_x15_r0_body.P9 483 PRE_first_tail_x15_r0_body.kappa9 PRE_first_tail_x15_r0_body.cx0_9 PRE_first_tail_x15_r0_body.cx1_9 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot9 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost9 (compact_a_eq PRE_first_tail_x15_r0_body.ckn09 PRE_first_tail_x15_r0_body.ckn19 PRE_first_tail_x15_r0_body.ckheap9 PRE_first_tail_x15_r0_body.ckpl9)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_9 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s102.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_9 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s102.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_9 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s102.ffi) = some PRE_first_tail_x15_r0_body.fxC_9
kernel_rfl PRE_first_tail_x15_r0_body.okrC_9 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s102.ffi) = some PRE_first_tail_x15_r0_body.krC_9
noncomputable def PRE_first_tail_x15_r0_body.fx0_9 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s104.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_9 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s104.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_9 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s104.ffi) = some PRE_first_tail_x15_r0_body.fx0_9
kernel_rfl PRE_first_tail_x15_r0_body.okr0_9 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s104.ffi) = some PRE_first_tail_x15_r0_body.kr0_9
noncomputable def PRE_first_tail_x15_r0_body.fx1_9 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s103.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_9 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s103.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_9 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s103.ffi) = some PRE_first_tail_x15_r0_body.fx1_9
kernel_rfl PRE_first_tail_x15_r0_body.okr1_9 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s103.ffi) = some PRE_first_tail_x15_r0_body.kr1_9
kernel_rfl PRE_first_tail_x15_r0_body.ff09 : PRE_first_tail_x15_r0_body.fx0_9 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_9 (PRE_first_tail_x15_r0_body.clo9.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_9.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff19 : PRE_first_tail_x15_r0_body.fx1_9 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_9 (PRE_first_tail_x15_r0_body.cwS9.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_9.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck9 : freedLB PRE_first_tail_x15_r0_body.kappa9 PRE_first_tail_x15_r0_body.cx0_9.mlx PRE_first_tail_x15_r0_body.fx0_9 PRE_first_tail_x15_r0_body.fx1_9 PRE_first_tail_x15_r0_body.clo9 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf09 : PRE_first_tail_x15_r0_body.kr0_9.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_9.flags (PRE_first_tail_x15_r0_body.clo9.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_9.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt09 : PRE_first_tail_x15_r0_body.kr0_9.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_9.targs (PRE_first_tail_x15_r0_body.clo9.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_9.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf19 : PRE_first_tail_x15_r0_body.kr1_9.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_9.flags (PRE_first_tail_x15_r0_body.cwS9.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_9.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt19 : PRE_first_tail_x15_r0_body.kr1_9.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_9.targs (PRE_first_tail_x15_r0_body.cwS9.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_9.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck9 : krecLB PRE_first_tail_x15_r0_body.kappa9 483 PRE_first_tail_x15_r0_body.cx0_9.mlx PRE_first_tail_x15_r0_body.kr0_9 PRE_first_tail_x15_r0_body.kr1_9 PRE_first_tail_x15_r0_body.clo9 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn9 : Nat.ble 474 483 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge9 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s103.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s104.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR9 : pendRegB PRE_first_tail_x15_r0_body.kappa9 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe9 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s103.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift9 (clean : Conv.NClean (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P9.NL) (cl : SSt (· < 483) PRE_first_tail_x15_r0_body.cx0_9.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_9.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_9.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_9.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_9.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P9 483 PRE_first_tail_x15_r0_body.kappa9 PRE_first_tail_x15_r0_body.s104.ffi PRE_first_tail_x15_r0_body.s103.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift9 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue9, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp9 t ht),
    PRE_first_tail_x15_r0_body.cbridge9,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s104.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s103.ffi) (PRE_first_tail_x15_r0_body.cfoot9 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_9 PRE_first_tail_x15_r0_body.ofx1_9 hobjC PRE_first_tail_x15_r0_body.ff09 PRE_first_tail_x15_r0_body.ff19 PRE_first_tail_x15_r0_body.ffck9,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s104.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s103.ffi) (PRE_first_tail_x15_r0_body.cfoot9 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_9 PRE_first_tail_x15_r0_body.okr1_9 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn9) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf09 PRE_first_tail_x15_r0_body.fkt09 PRE_first_tail_x15_r0_body.fkf19 PRE_first_tail_x15_r0_body.fkt19 PRE_first_tail_x15_r0_body.fkck9,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh09 PRE_first_tail_x15_r0_body.cnh19 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe9) PRE_first_tail_x15_r0_body.cpendR9⟩

end Host.Load.Run.Tpl
