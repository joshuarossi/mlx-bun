import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl59
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 59 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc59 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P59 : LoadP := PRE_first_tail_x15_r0_body.Pc59.raise 16444
kernel_rfl PRE_first_tail_x15_r0_body.craise59 : Nat.ble PRE_first_tail_x15_r0_body.Pc59.N0 16444 = true
theorem PRE_first_tail_x15_r0_body.raised59 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc59 PRE_first_tail_x15_r0_body.P59 :=
  .inr ⟨16444, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise59, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_59 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s525.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_59 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s524.ffi)
def PRE_first_tail_x15_r0_body.khinv59 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv59 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS59 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS59 : List Nat := List.range' 16444 0
def PRE_first_tail_x15_r0_body.ciS59 : List Nat := [] ++ List.range' 16444 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh059 : PRE_first_tail_x15_r0_body.kd59.nh0 = PRE_first_tail_x15_r0_body.cx0_59.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh159 : PRE_first_tail_x15_r0_body.kd59.nh1 = PRE_first_tail_x15_r0_body.cx1_59.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn059 : PRE_first_tail_x15_r0_body.kd59.nn0 = PRE_first_tail_x15_r0_body.cx0_59.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn159 : PRE_first_tail_x15_r0_body.kd59.nn1 = PRE_first_tail_x15_r0_body.cx1_59.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo59 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P59.lo && Nat.ble PRE_first_tail_x15_r0_body.P59.lo PRE_first_tail_x15_r0_body.cx0_59.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P59.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P59.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt59 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_59.mlx.next PRE_first_tail_x15_r0_body.cx1_59.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_59.mlx.nnext PRE_first_tail_x15_r0_body.cx1_59.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband59 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P59.NL && Nat.ble PRE_first_tail_x15_r0_body.P59.NL PRE_first_tail_x15_r0_body.P59.N0 && Nat.ble PRE_first_tail_x15_r0_body.P59.N0 PRE_first_tail_x15_r0_body.cx0_59.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow59 : PRE_first_tail_x15_r0_body.kd59.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren59 : checkRenG PRE_first_tail_x15_r0_body.kd59.hnd PRE_first_tail_x15_r0_body.khinv59 (phB PRE_first_tail_x15_r0_body.cx0_59.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband59 : PRE_first_tail_x15_r0_body.kd59.checkBand PRE_first_tail_x15_r0_body.P59.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos59 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd59.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren59 : checkRenG PRE_first_tail_x15_r0_body.kd59.node PRE_first_tail_x15_r0_body.kninv59 (pnB PRE_first_tail_x15_r0_body.cx0_59.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P59.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd59.nodeF j) PRE_first_tail_x15_r0_body.cx1_59.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a59 : PRE_first_tail_x15_r0_body.cx0_59.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b59 : PRE_first_tail_x15_r0_body.cx0_59.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok159 : PRE_first_tail_x15_r0_body.cx1_59.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.pending = PRE_first_tail_x15_r0_body.cx0_59.mlx.pending.map PRE_first_tail_x15_r0_body.kappa59.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.errh = PRE_first_tail_x15_r0_body.cx0_59.mlx.errh.map PRE_first_tail_x15_r0_body.kappa59.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.files = PRE_first_tail_x15_r0_body.cx0_59.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.arch = PRE_first_tail_x15_r0_body.cx0_59.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_59.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.wired = PRE_first_tail_x15_r0_body.cx0_59.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost59 : PRE_first_tail_x15_r0_body.cx1_59.host = PRE_first_tail_x15_r0_body.cx0_59.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd59`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn059 : PRE_first_tail_x15_r0_body.kd59.n0 = 2721054
kernel_rfl PRE_first_tail_x15_r0_body.ckn159 : PRE_first_tail_x15_r0_body.kd59.n1 = 2721064
kernel_rfl PRE_first_tail_x15_r0_body.ckheap59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.heap).all (fun x => Nat.ble 2721053 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl59 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd59.heap.get (2721053 + j) = nth? PRE_first_tail_x15_r0_body.pl59 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja59 : Nat.ble 2721053 2721053 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn59 : Nat.ble 2575 2575 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD59 : Nat.ble 2721053 PRE_first_tail_x15_r0_body.kd59.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn59 : Nat.ble 19361 PRE_first_tail_x15_r0_body.kd59.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn59 : Nat.ble 16444 PRE_first_tail_x15_r0_body.kd59.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb59 : Nat.ble 19361 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.heap).all (Nat.ble (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.hnd).all (Nat.ble (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.node).all (Nat.ble (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix59 : Conv.FixOld (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa59 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja59) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn59) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD59) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn59) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn59) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb59) PRE_first_tail_x15_r0_body.fheap59 PRE_first_tail_x15_r0_body.fhnd59 PRE_first_tail_x15_r0_body.fnode59
kernel_rfl PRE_first_tail_x15_r0_body.fcxn59 : (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn59 : (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle059 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_59.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_59.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS59.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_59.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS59.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_59.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS59.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_59.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS59.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_59.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd59 : (PRE_first_tail_x15_r0_body.clo59 ++ PRE_first_tail_x15_r0_body.cln59 ++ PRE_first_tail_x15_r0_body.cli59 ++ PRE_first_tail_x15_r0_body.cwS59 ++ PRE_first_tail_x15_r0_body.cnS59 ++ PRE_first_tail_x15_r0_body.ciS59).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW59 : PRE_first_tail_x15_r0_body.cwS59.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo59.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI59 : PRE_first_tail_x15_r0_body.ciS59.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli59.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN59 : PRE_first_tail_x15_r0_body.cnS59.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF59 : PRE_first_tail_x15_r0_body.cln59.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh59 : PRE_first_tail_x15_r0_body.clo59.all (handleOK PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.P59.lo PRE_first_tail_x15_r0_body.cx0_59.mlx PRE_first_tail_x15_r0_body.cx1_59.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo59 : PRE_first_tail_x15_r0_body.clo59.map (fun h => PRE_first_tail_x15_r0_body.cx1_59.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa59.handle h)) = PRE_first_tail_x15_r0_body.clo59.map (fun h => (PRE_first_tail_x15_r0_body.cx0_59.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa59.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok59 : PRE_first_tail_x15_r0_body.clo59.all (objOK PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.P59.NL PRE_first_tail_x15_r0_body.cx0_59.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd59 : PRE_first_tail_x15_r0_body.cln59.all (nodeOKF PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.P59 PRE_first_tail_x15_r0_body.cx0_59.mlx PRE_first_tail_x15_r0_body.cx1_59.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp59 : ((PRE_first_tail_x15_r0_body.cln59.filter (fullB PRE_first_tail_x15_r0_body.P59))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_59.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa59.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln59.filter (fullB PRE_first_tail_x15_r0_body.P59))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_59.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa59.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI59 : incrB PRE_first_tail_x15_r0_body.kd59.nodeF (List.range' 16444 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.node).all (fun k => Nat.ble 16444 k && Nat.blt k 16444) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL59 : (PRE_first_tail_x15_r0_body.cln59.filter (Nat.ble PRE_first_tail_x15_r0_body.P59.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd59.nodeF i) && (Nat.blt i 16444 || Nat.ble PRE_first_tail_x15_r0_body.kd59.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord59 : (PRE_first_tail_x15_r0_body.cln59.filter (Nat.ble PRE_first_tail_x15_r0_body.P59.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd59.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd59.nodeF j) (PRE_first_tail_x15_r0_body.kd59.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow59 PRE_first_tail_x15_r0_body.cnn159 PRE_first_tail_x15_r0_body.fnordI59 PRE_first_tail_x15_r0_body.fnordK59 PRE_first_tail_x15_r0_body.fnordL59
kernel_rfl PRE_first_tail_x15_r0_body.fi59 : PRE_first_tail_x15_r0_body.cli59.all (pnB PRE_first_tail_x15_r0_body.cx0_59.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii59 : PRE_first_tail_x15_r0_body.cli59.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_59.mlx.items.get (PRE_first_tail_x15_r0_body.kappa59.node k) = (PRE_first_tail_x15_r0_body.cx0_59.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa59.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot59 (clean : Conv.NClean (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P59.NL) (cl : SSt (· < 2575) PRE_first_tail_x15_r0_body.cx0_59.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P59 2575 PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.kd59 PRE_first_tail_x15_r0_body.khinv59 PRE_first_tail_x15_r0_body.kninv59 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx PRE_first_tail_x15_r0_body.cx0_59.mlx PRE_first_tail_x15_r0_body.cx1_59.mlx (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo59 PRE_first_tail_x15_r0_body.cln59 PRE_first_tail_x15_r0_body.cli59 PRE_first_tail_x15_r0_body.cwS59 PRE_first_tail_x15_r0_body.cnS59 PRE_first_tail_x15_r0_body.ciS59 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh059, PRE_first_tail_x15_r0_body.cnh159, PRE_first_tail_x15_r0_body.cnn059, PRE_first_tail_x15_r0_body.cnn159, PRE_first_tail_x15_r0_body.cplo59, PRE_first_tail_x15_r0_body.ccnt59, PRE_first_tail_x15_r0_body.cnband59, PRE_first_tail_x15_r0_body.chbelow59, PRE_first_tail_x15_r0_body.chren59, PRE_first_tail_x15_r0_body.cband59, PRE_first_tail_x15_r0_body.cnh1pos59, PRE_first_tail_x15_r0_body.cnren59, PRE_first_tail_x15_r0_body.cnlow59, PRE_first_tail_x15_r0_body.cabs0a59, PRE_first_tail_x15_r0_body.cabs0b59, PRE_first_tail_x15_r0_body.ctok159, PRE_first_tail_x15_r0_body.cpend59, PRE_first_tail_x15_r0_body.cerrh59, PRE_first_tail_x15_r0_body.cfiles59, PRE_first_tail_x15_r0_body.carch59, PRE_first_tail_x15_r0_body.csizes59, PRE_first_tail_x15_r0_body.cwired59, PRE_first_tail_x15_r0_body.cfix59, clean, PRE_first_tail_x15_r0_body.fcxn59, PRE_first_tail_x15_r0_body.fcnn59, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle059, PRE_first_tail_x15_r0_body.fnk59, PRE_first_tail_x15_r0_body.ckA59, PRE_first_tail_x15_r0_body.cobjsK59, PRE_first_tail_x15_r0_body.cnodesK59, PRE_first_tail_x15_r0_body.citemsK59, PRE_first_tail_x15_r0_body.f1A59, PRE_first_tail_x15_r0_body.f1O59, PRE_first_tail_x15_r0_body.f1N59, PRE_first_tail_x15_r0_body.f1I59, PRE_first_tail_x15_r0_body.fbd59, PRE_first_tail_x15_r0_body.fincW59, PRE_first_tail_x15_r0_body.fincI59, PRE_first_tail_x15_r0_body.fincN59, PRE_first_tail_x15_r0_body.flnF59, PRE_first_tail_x15_r0_body.fh59, PRE_first_tail_x15_r0_body.fo59, PRE_first_tail_x15_r0_body.fok59, PRE_first_tail_x15_r0_body.fnd59, PRE_first_tail_x15_r0_body.fp59, PRE_first_tail_x15_r0_body.fnord59, PRE_first_tail_x15_r0_body.fi59, PRE_first_tail_x15_r0_body.fii59⟩
theorem PRE_first_tail_x15_r0_body.cnshift59 (clean : Conv.NClean (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P59.NL) (cl : SSt (· < 2575) PRE_first_tail_x15_r0_body.cx0_59.mlx) : NShift PRE_first_tail_x15_r0_body.P59 2575 PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.cx0_59 PRE_first_tail_x15_r0_body.cx1_59 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot59 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost59 (compact_a_eq PRE_first_tail_x15_r0_body.ckn059 PRE_first_tail_x15_r0_body.ckn159 PRE_first_tail_x15_r0_body.ckheap59 PRE_first_tail_x15_r0_body.ckpl59)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_59 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s523.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_59 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s523.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_59 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s523.ffi) = some PRE_first_tail_x15_r0_body.fxC_59
kernel_rfl PRE_first_tail_x15_r0_body.okrC_59 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s523.ffi) = some PRE_first_tail_x15_r0_body.krC_59
noncomputable def PRE_first_tail_x15_r0_body.fx0_59 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s525.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_59 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s525.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_59 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s525.ffi) = some PRE_first_tail_x15_r0_body.fx0_59
kernel_rfl PRE_first_tail_x15_r0_body.okr0_59 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s525.ffi) = some PRE_first_tail_x15_r0_body.kr0_59
noncomputable def PRE_first_tail_x15_r0_body.fx1_59 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s524.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_59 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s524.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_59 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s524.ffi) = some PRE_first_tail_x15_r0_body.fx1_59
kernel_rfl PRE_first_tail_x15_r0_body.okr1_59 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s524.ffi) = some PRE_first_tail_x15_r0_body.kr1_59
kernel_rfl PRE_first_tail_x15_r0_body.ff059 : PRE_first_tail_x15_r0_body.fx0_59 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_59 (PRE_first_tail_x15_r0_body.clo59.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_59.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff159 : PRE_first_tail_x15_r0_body.fx1_59 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_59 (PRE_first_tail_x15_r0_body.cwS59.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_59.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck59 : freedLB PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.cx0_59.mlx PRE_first_tail_x15_r0_body.fx0_59 PRE_first_tail_x15_r0_body.fx1_59 PRE_first_tail_x15_r0_body.clo59 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf059 : PRE_first_tail_x15_r0_body.kr0_59.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_59.flags (PRE_first_tail_x15_r0_body.clo59.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_59.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt059 : PRE_first_tail_x15_r0_body.kr0_59.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_59.targs (PRE_first_tail_x15_r0_body.clo59.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_59.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf159 : PRE_first_tail_x15_r0_body.kr1_59.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_59.flags (PRE_first_tail_x15_r0_body.cwS59.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_59.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt159 : PRE_first_tail_x15_r0_body.kr1_59.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_59.targs (PRE_first_tail_x15_r0_body.cwS59.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_59.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck59 : krecLB PRE_first_tail_x15_r0_body.kappa59 2575 PRE_first_tail_x15_r0_body.cx0_59.mlx PRE_first_tail_x15_r0_body.kr0_59 PRE_first_tail_x15_r0_body.kr1_59 PRE_first_tail_x15_r0_body.clo59 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn59 : Nat.ble 2575 2575 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge59 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s524.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s525.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR59 : pendRegB PRE_first_tail_x15_r0_body.kappa59 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s525.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe59 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s525.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s524.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift59 (clean : Conv.NClean (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P59.NL) (cl : SSt (· < 2575) PRE_first_tail_x15_r0_body.cx0_59.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_59.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_59.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_59.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s523.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_59.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P59 2575 PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.s525.ffi PRE_first_tail_x15_r0_body.s524.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift59 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue59, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp59 t ht),
    PRE_first_tail_x15_r0_body.cbridge59,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s525.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s524.ffi) (PRE_first_tail_x15_r0_body.cfoot59 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_59 PRE_first_tail_x15_r0_body.ofx1_59 hobjC PRE_first_tail_x15_r0_body.ff059 PRE_first_tail_x15_r0_body.ff159 PRE_first_tail_x15_r0_body.ffck59,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s525.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s524.ffi) (PRE_first_tail_x15_r0_body.cfoot59 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_59 PRE_first_tail_x15_r0_body.okr1_59 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn59) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf059 PRE_first_tail_x15_r0_body.fkt059 PRE_first_tail_x15_r0_body.fkf159 PRE_first_tail_x15_r0_body.fkt159 PRE_first_tail_x15_r0_body.fkck59,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh059 PRE_first_tail_x15_r0_body.cnh159 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe59) PRE_first_tail_x15_r0_body.cpendR59⟩

end Host.Load.Run.Tpl
