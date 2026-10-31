import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl58
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 58 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc58 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P58 : LoadP := PRE_first_tail_x15_r0_body.Pc58.raise 16440
kernel_rfl PRE_first_tail_x15_r0_body.craise58 : Nat.ble PRE_first_tail_x15_r0_body.Pc58.N0 16440 = true
theorem PRE_first_tail_x15_r0_body.raised58 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc58 PRE_first_tail_x15_r0_body.P58 :=
  .inr ⟨16440, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise58, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_58 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_58 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s571.ffi)
def PRE_first_tail_x15_r0_body.khinv58 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv58 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS58 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS58 : List Nat := List.range' 16440 0
def PRE_first_tail_x15_r0_body.ciS58 : List Nat := [] ++ List.range' 16440 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh058 : PRE_first_tail_x15_r0_body.kd58.nh0 = PRE_first_tail_x15_r0_body.cx0_58.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh158 : PRE_first_tail_x15_r0_body.kd58.nh1 = PRE_first_tail_x15_r0_body.cx1_58.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn058 : PRE_first_tail_x15_r0_body.kd58.nn0 = PRE_first_tail_x15_r0_body.cx0_58.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn158 : PRE_first_tail_x15_r0_body.kd58.nn1 = PRE_first_tail_x15_r0_body.cx1_58.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo58 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P58.lo && Nat.ble PRE_first_tail_x15_r0_body.P58.lo PRE_first_tail_x15_r0_body.cx0_58.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P58.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P58.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt58 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_58.mlx.next PRE_first_tail_x15_r0_body.cx1_58.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_58.mlx.nnext PRE_first_tail_x15_r0_body.cx1_58.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband58 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P58.NL && Nat.ble PRE_first_tail_x15_r0_body.P58.NL PRE_first_tail_x15_r0_body.P58.N0 && Nat.ble PRE_first_tail_x15_r0_body.P58.N0 PRE_first_tail_x15_r0_body.cx0_58.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow58 : PRE_first_tail_x15_r0_body.kd58.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren58 : checkRenG PRE_first_tail_x15_r0_body.kd58.hnd PRE_first_tail_x15_r0_body.khinv58 (phB PRE_first_tail_x15_r0_body.cx0_58.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband58 : PRE_first_tail_x15_r0_body.kd58.checkBand PRE_first_tail_x15_r0_body.P58.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos58 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd58.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren58 : checkRenG PRE_first_tail_x15_r0_body.kd58.node PRE_first_tail_x15_r0_body.kninv58 (pnB PRE_first_tail_x15_r0_body.cx0_58.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P58.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd58.nodeF j) PRE_first_tail_x15_r0_body.cx1_58.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a58 : PRE_first_tail_x15_r0_body.cx0_58.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b58 : PRE_first_tail_x15_r0_body.cx0_58.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok158 : PRE_first_tail_x15_r0_body.cx1_58.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.pending = PRE_first_tail_x15_r0_body.cx0_58.mlx.pending.map PRE_first_tail_x15_r0_body.kappa58.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.errh = PRE_first_tail_x15_r0_body.cx0_58.mlx.errh.map PRE_first_tail_x15_r0_body.kappa58.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.files = PRE_first_tail_x15_r0_body.cx0_58.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.arch = PRE_first_tail_x15_r0_body.cx0_58.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_58.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.wired = PRE_first_tail_x15_r0_body.cx0_58.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost58 : PRE_first_tail_x15_r0_body.cx1_58.host = PRE_first_tail_x15_r0_body.cx0_58.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd58`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn058 : PRE_first_tail_x15_r0_body.kd58.n0 = 2720765
kernel_rfl PRE_first_tail_x15_r0_body.ckn158 : PRE_first_tail_x15_r0_body.kd58.n1 = 2720767
kernel_rfl PRE_first_tail_x15_r0_body.ckheap58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.heap).all (fun x => Nat.ble 2720765 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl58 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd58.heap.get (2720765 + j) = nth? PRE_first_tail_x15_r0_body.pl58 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja58 : Nat.ble 2720765 2720765 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn58 : Nat.ble 2558 2558 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD58 : Nat.ble 2720765 PRE_first_tail_x15_r0_body.kd58.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn58 : Nat.ble 19354 PRE_first_tail_x15_r0_body.kd58.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn58 : Nat.ble 16440 PRE_first_tail_x15_r0_body.kd58.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb58 : Nat.ble 19354 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.heap).all (Nat.ble (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.hnd).all (Nat.ble (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.node).all (Nat.ble (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix58 : Conv.FixOld (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa58 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja58) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn58) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD58) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn58) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn58) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb58) PRE_first_tail_x15_r0_body.fheap58 PRE_first_tail_x15_r0_body.fhnd58 PRE_first_tail_x15_r0_body.fnode58
kernel_rfl PRE_first_tail_x15_r0_body.fcxn58 : (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn58 : (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle058 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_58.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_58.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS58.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_58.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS58.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_58.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS58.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_58.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS58.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_58.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd58 : (PRE_first_tail_x15_r0_body.clo58 ++ PRE_first_tail_x15_r0_body.cln58 ++ PRE_first_tail_x15_r0_body.cli58 ++ PRE_first_tail_x15_r0_body.cwS58 ++ PRE_first_tail_x15_r0_body.cnS58 ++ PRE_first_tail_x15_r0_body.ciS58).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW58 : PRE_first_tail_x15_r0_body.cwS58.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo58.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI58 : PRE_first_tail_x15_r0_body.ciS58.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli58.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN58 : PRE_first_tail_x15_r0_body.cnS58.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF58 : PRE_first_tail_x15_r0_body.cln58.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh58 : PRE_first_tail_x15_r0_body.clo58.all (handleOK PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.P58.lo PRE_first_tail_x15_r0_body.cx0_58.mlx PRE_first_tail_x15_r0_body.cx1_58.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo58 : PRE_first_tail_x15_r0_body.clo58.map (fun h => PRE_first_tail_x15_r0_body.cx1_58.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa58.handle h)) = PRE_first_tail_x15_r0_body.clo58.map (fun h => (PRE_first_tail_x15_r0_body.cx0_58.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa58.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok58 : PRE_first_tail_x15_r0_body.clo58.all (objOK PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.P58.NL PRE_first_tail_x15_r0_body.cx0_58.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd58 : PRE_first_tail_x15_r0_body.cln58.all (nodeOKF PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.P58 PRE_first_tail_x15_r0_body.cx0_58.mlx PRE_first_tail_x15_r0_body.cx1_58.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp58 : ((PRE_first_tail_x15_r0_body.cln58.filter (fullB PRE_first_tail_x15_r0_body.P58))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_58.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa58.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln58.filter (fullB PRE_first_tail_x15_r0_body.P58))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_58.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa58.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI58 : incrB PRE_first_tail_x15_r0_body.kd58.nodeF (List.range' 16440 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.node).all (fun k => Nat.ble 16440 k && Nat.blt k 16440) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL58 : (PRE_first_tail_x15_r0_body.cln58.filter (Nat.ble PRE_first_tail_x15_r0_body.P58.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd58.nodeF i) && (Nat.blt i 16440 || Nat.ble PRE_first_tail_x15_r0_body.kd58.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord58 : (PRE_first_tail_x15_r0_body.cln58.filter (Nat.ble PRE_first_tail_x15_r0_body.P58.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd58.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd58.nodeF j) (PRE_first_tail_x15_r0_body.kd58.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow58 PRE_first_tail_x15_r0_body.cnn158 PRE_first_tail_x15_r0_body.fnordI58 PRE_first_tail_x15_r0_body.fnordK58 PRE_first_tail_x15_r0_body.fnordL58
kernel_rfl PRE_first_tail_x15_r0_body.fi58 : PRE_first_tail_x15_r0_body.cli58.all (pnB PRE_first_tail_x15_r0_body.cx0_58.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii58 : PRE_first_tail_x15_r0_body.cli58.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_58.mlx.items.get (PRE_first_tail_x15_r0_body.kappa58.node k) = (PRE_first_tail_x15_r0_body.cx0_58.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa58.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot58 (clean : Conv.NClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P58.NL) (cl : SSt (· < 2558) PRE_first_tail_x15_r0_body.cx0_58.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P58 2558 PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.kd58 PRE_first_tail_x15_r0_body.khinv58 PRE_first_tail_x15_r0_body.kninv58 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx PRE_first_tail_x15_r0_body.cx0_58.mlx PRE_first_tail_x15_r0_body.cx1_58.mlx (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo58 PRE_first_tail_x15_r0_body.cln58 PRE_first_tail_x15_r0_body.cli58 PRE_first_tail_x15_r0_body.cwS58 PRE_first_tail_x15_r0_body.cnS58 PRE_first_tail_x15_r0_body.ciS58 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh058, PRE_first_tail_x15_r0_body.cnh158, PRE_first_tail_x15_r0_body.cnn058, PRE_first_tail_x15_r0_body.cnn158, PRE_first_tail_x15_r0_body.cplo58, PRE_first_tail_x15_r0_body.ccnt58, PRE_first_tail_x15_r0_body.cnband58, PRE_first_tail_x15_r0_body.chbelow58, PRE_first_tail_x15_r0_body.chren58, PRE_first_tail_x15_r0_body.cband58, PRE_first_tail_x15_r0_body.cnh1pos58, PRE_first_tail_x15_r0_body.cnren58, PRE_first_tail_x15_r0_body.cnlow58, PRE_first_tail_x15_r0_body.cabs0a58, PRE_first_tail_x15_r0_body.cabs0b58, PRE_first_tail_x15_r0_body.ctok158, PRE_first_tail_x15_r0_body.cpend58, PRE_first_tail_x15_r0_body.cerrh58, PRE_first_tail_x15_r0_body.cfiles58, PRE_first_tail_x15_r0_body.carch58, PRE_first_tail_x15_r0_body.csizes58, PRE_first_tail_x15_r0_body.cwired58, PRE_first_tail_x15_r0_body.cfix58, clean, PRE_first_tail_x15_r0_body.fcxn58, PRE_first_tail_x15_r0_body.fcnn58, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle058, PRE_first_tail_x15_r0_body.fnk58, PRE_first_tail_x15_r0_body.ckA58, PRE_first_tail_x15_r0_body.cobjsK58, PRE_first_tail_x15_r0_body.cnodesK58, PRE_first_tail_x15_r0_body.citemsK58, PRE_first_tail_x15_r0_body.f1A58, PRE_first_tail_x15_r0_body.f1O58, PRE_first_tail_x15_r0_body.f1N58, PRE_first_tail_x15_r0_body.f1I58, PRE_first_tail_x15_r0_body.fbd58, PRE_first_tail_x15_r0_body.fincW58, PRE_first_tail_x15_r0_body.fincI58, PRE_first_tail_x15_r0_body.fincN58, PRE_first_tail_x15_r0_body.flnF58, PRE_first_tail_x15_r0_body.fh58, PRE_first_tail_x15_r0_body.fo58, PRE_first_tail_x15_r0_body.fok58, PRE_first_tail_x15_r0_body.fnd58, PRE_first_tail_x15_r0_body.fp58, PRE_first_tail_x15_r0_body.fnord58, PRE_first_tail_x15_r0_body.fi58, PRE_first_tail_x15_r0_body.fii58⟩
theorem PRE_first_tail_x15_r0_body.cnshift58 (clean : Conv.NClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P58.NL) (cl : SSt (· < 2558) PRE_first_tail_x15_r0_body.cx0_58.mlx) : NShift PRE_first_tail_x15_r0_body.P58 2558 PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.cx0_58 PRE_first_tail_x15_r0_body.cx1_58 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot58 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost58 (compact_a_eq PRE_first_tail_x15_r0_body.ckn058 PRE_first_tail_x15_r0_body.ckn158 PRE_first_tail_x15_r0_body.ckheap58 PRE_first_tail_x15_r0_body.ckpl58)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_58 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s570.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_58 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s570.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_58 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s570.ffi) = some PRE_first_tail_x15_r0_body.fxC_58
kernel_rfl PRE_first_tail_x15_r0_body.okrC_58 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s570.ffi) = some PRE_first_tail_x15_r0_body.krC_58
noncomputable def PRE_first_tail_x15_r0_body.fx0_58 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s572.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_58 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s572.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_58 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s572.ffi) = some PRE_first_tail_x15_r0_body.fx0_58
kernel_rfl PRE_first_tail_x15_r0_body.okr0_58 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s572.ffi) = some PRE_first_tail_x15_r0_body.kr0_58
noncomputable def PRE_first_tail_x15_r0_body.fx1_58 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s571.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_58 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s571.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_58 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s571.ffi) = some PRE_first_tail_x15_r0_body.fx1_58
kernel_rfl PRE_first_tail_x15_r0_body.okr1_58 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s571.ffi) = some PRE_first_tail_x15_r0_body.kr1_58
kernel_rfl PRE_first_tail_x15_r0_body.ff058 : PRE_first_tail_x15_r0_body.fx0_58 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_58 (PRE_first_tail_x15_r0_body.clo58.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_58.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff158 : PRE_first_tail_x15_r0_body.fx1_58 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_58 (PRE_first_tail_x15_r0_body.cwS58.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_58.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck58 : freedLB PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.cx0_58.mlx PRE_first_tail_x15_r0_body.fx0_58 PRE_first_tail_x15_r0_body.fx1_58 PRE_first_tail_x15_r0_body.clo58 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf058 : PRE_first_tail_x15_r0_body.kr0_58.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_58.flags (PRE_first_tail_x15_r0_body.clo58.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_58.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt058 : PRE_first_tail_x15_r0_body.kr0_58.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_58.targs (PRE_first_tail_x15_r0_body.clo58.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_58.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf158 : PRE_first_tail_x15_r0_body.kr1_58.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_58.flags (PRE_first_tail_x15_r0_body.cwS58.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_58.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt158 : PRE_first_tail_x15_r0_body.kr1_58.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_58.targs (PRE_first_tail_x15_r0_body.cwS58.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_58.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck58 : krecLB PRE_first_tail_x15_r0_body.kappa58 2558 PRE_first_tail_x15_r0_body.cx0_58.mlx PRE_first_tail_x15_r0_body.kr0_58 PRE_first_tail_x15_r0_body.kr1_58 PRE_first_tail_x15_r0_body.clo58 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn58 : Nat.ble 2558 2558 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge58 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s571.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s572.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR58 : pendRegB PRE_first_tail_x15_r0_body.kappa58 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe58 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s571.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift58 (clean : Conv.NClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P58.NL) (cl : SSt (· < 2558) PRE_first_tail_x15_r0_body.cx0_58.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_58.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_58.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_58.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_58.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P58 2558 PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.s572.ffi PRE_first_tail_x15_r0_body.s571.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift58 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue58, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp58 t ht),
    PRE_first_tail_x15_r0_body.cbridge58,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s572.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s571.ffi) (PRE_first_tail_x15_r0_body.cfoot58 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_58 PRE_first_tail_x15_r0_body.ofx1_58 hobjC PRE_first_tail_x15_r0_body.ff058 PRE_first_tail_x15_r0_body.ff158 PRE_first_tail_x15_r0_body.ffck58,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s572.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s571.ffi) (PRE_first_tail_x15_r0_body.cfoot58 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_58 PRE_first_tail_x15_r0_body.okr1_58 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn58) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf058 PRE_first_tail_x15_r0_body.fkt058 PRE_first_tail_x15_r0_body.fkf158 PRE_first_tail_x15_r0_body.fkt158 PRE_first_tail_x15_r0_body.fkck58,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh058 PRE_first_tail_x15_r0_body.cnh158 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe58) PRE_first_tail_x15_r0_body.cpendR58⟩

end Host.Load.Run.Tpl
