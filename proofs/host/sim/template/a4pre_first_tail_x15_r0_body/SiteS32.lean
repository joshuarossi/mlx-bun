import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl32
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 32 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc32 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P32 : LoadP := PRE_first_tail_x15_r0_body.Pc32.raise 15922
kernel_rfl PRE_first_tail_x15_r0_body.craise32 : Nat.ble PRE_first_tail_x15_r0_body.Pc32.N0 15922 = true
theorem PRE_first_tail_x15_r0_body.raised32 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc32 PRE_first_tail_x15_r0_body.P32 :=
  .inr ⟨15922, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise32, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_32 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s291.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_32 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s290.ffi)
def PRE_first_tail_x15_r0_body.khinv32 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv32 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS32 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS32 : List Nat := List.range' 15922 0
def PRE_first_tail_x15_r0_body.ciS32 : List Nat := [] ++ List.range' 15922 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh032 : PRE_first_tail_x15_r0_body.kd32.nh0 = PRE_first_tail_x15_r0_body.cx0_32.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh132 : PRE_first_tail_x15_r0_body.kd32.nh1 = PRE_first_tail_x15_r0_body.cx1_32.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn032 : PRE_first_tail_x15_r0_body.kd32.nn0 = PRE_first_tail_x15_r0_body.cx0_32.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn132 : PRE_first_tail_x15_r0_body.kd32.nn1 = PRE_first_tail_x15_r0_body.cx1_32.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo32 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P32.lo && Nat.ble PRE_first_tail_x15_r0_body.P32.lo PRE_first_tail_x15_r0_body.cx0_32.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P32.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P32.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt32 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_32.mlx.next PRE_first_tail_x15_r0_body.cx1_32.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_32.mlx.nnext PRE_first_tail_x15_r0_body.cx1_32.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband32 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P32.NL && Nat.ble PRE_first_tail_x15_r0_body.P32.NL PRE_first_tail_x15_r0_body.P32.N0 && Nat.ble PRE_first_tail_x15_r0_body.P32.N0 PRE_first_tail_x15_r0_body.cx0_32.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow32 : PRE_first_tail_x15_r0_body.kd32.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren32 : checkRenG PRE_first_tail_x15_r0_body.kd32.hnd PRE_first_tail_x15_r0_body.khinv32 (phB PRE_first_tail_x15_r0_body.cx0_32.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband32 : PRE_first_tail_x15_r0_body.kd32.checkBand PRE_first_tail_x15_r0_body.P32.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos32 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd32.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren32 : checkRenG PRE_first_tail_x15_r0_body.kd32.node PRE_first_tail_x15_r0_body.kninv32 (pnB PRE_first_tail_x15_r0_body.cx0_32.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow32 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd32.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P32.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd32.nodeF j) PRE_first_tail_x15_r0_body.cx1_32.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a32 : PRE_first_tail_x15_r0_body.cx0_32.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b32 : PRE_first_tail_x15_r0_body.cx0_32.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok132 : PRE_first_tail_x15_r0_body.cx1_32.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend32 : PRE_first_tail_x15_r0_body.cx1_32.mlx.pending = PRE_first_tail_x15_r0_body.cx0_32.mlx.pending.map PRE_first_tail_x15_r0_body.kappa32.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh32 : PRE_first_tail_x15_r0_body.cx1_32.mlx.errh = PRE_first_tail_x15_r0_body.cx0_32.mlx.errh.map PRE_first_tail_x15_r0_body.kappa32.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles32 : PRE_first_tail_x15_r0_body.cx1_32.mlx.files = PRE_first_tail_x15_r0_body.cx0_32.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch32 : PRE_first_tail_x15_r0_body.cx1_32.mlx.arch = PRE_first_tail_x15_r0_body.cx0_32.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes32 : PRE_first_tail_x15_r0_body.cx1_32.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_32.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired32 : PRE_first_tail_x15_r0_body.cx1_32.mlx.wired = PRE_first_tail_x15_r0_body.cx0_32.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost32 : PRE_first_tail_x15_r0_body.cx1_32.host = PRE_first_tail_x15_r0_body.cx0_32.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd32`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn032 : PRE_first_tail_x15_r0_body.kd32.n0 = 2699584
kernel_rfl PRE_first_tail_x15_r0_body.ckn132 : PRE_first_tail_x15_r0_body.kd32.n1 = 2699594
kernel_rfl PRE_first_tail_x15_r0_body.ckheap32 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd32.heap).all (fun x => Nat.ble 2699583 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl32 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd32.heap.get (2699583 + j) = nth? PRE_first_tail_x15_r0_body.pl32 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja32 : Nat.ble 2699583 2699583 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn32 : Nat.ble 1423 1423 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD32 : Nat.ble 2699583 PRE_first_tail_x15_r0_body.kd32.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn32 : Nat.ble 18825 PRE_first_tail_x15_r0_body.kd32.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn32 : Nat.ble 15922 PRE_first_tail_x15_r0_body.kd32.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb32 : Nat.ble 18825 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap32 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd32.heap).all (Nat.ble (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd32 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd32.hnd).all (Nat.ble (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode32 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd32.node).all (Nat.ble (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix32 : Conv.FixOld (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa32 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja32) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn32) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD32) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn32) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn32) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb32) PRE_first_tail_x15_r0_body.fheap32 PRE_first_tail_x15_r0_body.fhnd32 PRE_first_tail_x15_r0_body.fnode32
kernel_rfl PRE_first_tail_x15_r0_body.fcxn32 : (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn32 : (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle032 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_32.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_32.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk32 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd32.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A32 : PRE_first_tail_x15_r0_body.cx1_32.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS32.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_32.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O32 : PRE_first_tail_x15_r0_body.cx1_32.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS32.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_32.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N32 : PRE_first_tail_x15_r0_body.cx1_32.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS32.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_32.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I32 : PRE_first_tail_x15_r0_body.cx1_32.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS32.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_32.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd32 : (PRE_first_tail_x15_r0_body.clo32 ++ PRE_first_tail_x15_r0_body.cln32 ++ PRE_first_tail_x15_r0_body.cli32 ++ PRE_first_tail_x15_r0_body.cwS32 ++ PRE_first_tail_x15_r0_body.cnS32 ++ PRE_first_tail_x15_r0_body.ciS32).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW32 : PRE_first_tail_x15_r0_body.cwS32.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo32.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI32 : PRE_first_tail_x15_r0_body.ciS32.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli32.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN32 : PRE_first_tail_x15_r0_body.cnS32.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF32 : PRE_first_tail_x15_r0_body.cln32.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh32 : PRE_first_tail_x15_r0_body.clo32.all (handleOK PRE_first_tail_x15_r0_body.kappa32 PRE_first_tail_x15_r0_body.P32.lo PRE_first_tail_x15_r0_body.cx0_32.mlx PRE_first_tail_x15_r0_body.cx1_32.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo32 : PRE_first_tail_x15_r0_body.clo32.map (fun h => PRE_first_tail_x15_r0_body.cx1_32.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa32.handle h)) = PRE_first_tail_x15_r0_body.clo32.map (fun h => (PRE_first_tail_x15_r0_body.cx0_32.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa32.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok32 : PRE_first_tail_x15_r0_body.clo32.all (objOK PRE_first_tail_x15_r0_body.kappa32 PRE_first_tail_x15_r0_body.P32.NL PRE_first_tail_x15_r0_body.cx0_32.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd32 : PRE_first_tail_x15_r0_body.cln32.all (nodeOKF PRE_first_tail_x15_r0_body.kappa32 PRE_first_tail_x15_r0_body.P32 PRE_first_tail_x15_r0_body.cx0_32.mlx PRE_first_tail_x15_r0_body.cx1_32.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp32 : ((PRE_first_tail_x15_r0_body.cln32.filter (fullB PRE_first_tail_x15_r0_body.P32))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_32.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa32.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln32.filter (fullB PRE_first_tail_x15_r0_body.P32))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_32.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa32.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI32 : incrB PRE_first_tail_x15_r0_body.kd32.nodeF (List.range' 15922 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK32 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd32.node).all (fun k => Nat.ble 15922 k && Nat.blt k 15922) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL32 : (PRE_first_tail_x15_r0_body.cln32.filter (Nat.ble PRE_first_tail_x15_r0_body.P32.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd32.nodeF i) && (Nat.blt i 15922 || Nat.ble PRE_first_tail_x15_r0_body.kd32.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord32 : (PRE_first_tail_x15_r0_body.cln32.filter (Nat.ble PRE_first_tail_x15_r0_body.P32.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd32.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd32.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd32.nodeF j) (PRE_first_tail_x15_r0_body.kd32.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow32 PRE_first_tail_x15_r0_body.cnn132 PRE_first_tail_x15_r0_body.fnordI32 PRE_first_tail_x15_r0_body.fnordK32 PRE_first_tail_x15_r0_body.fnordL32
kernel_rfl PRE_first_tail_x15_r0_body.fi32 : PRE_first_tail_x15_r0_body.cli32.all (pnB PRE_first_tail_x15_r0_body.cx0_32.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii32 : PRE_first_tail_x15_r0_body.cli32.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_32.mlx.items.get (PRE_first_tail_x15_r0_body.kappa32.node k) = (PRE_first_tail_x15_r0_body.cx0_32.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa32.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot32 (clean : Conv.NClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P32.NL) (cl : SSt (· < 1423) PRE_first_tail_x15_r0_body.cx0_32.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P32 1423 PRE_first_tail_x15_r0_body.kappa32 PRE_first_tail_x15_r0_body.kd32 PRE_first_tail_x15_r0_body.khinv32 PRE_first_tail_x15_r0_body.kninv32 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx PRE_first_tail_x15_r0_body.cx0_32.mlx PRE_first_tail_x15_r0_body.cx1_32.mlx (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo32 PRE_first_tail_x15_r0_body.cln32 PRE_first_tail_x15_r0_body.cli32 PRE_first_tail_x15_r0_body.cwS32 PRE_first_tail_x15_r0_body.cnS32 PRE_first_tail_x15_r0_body.ciS32 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh032, PRE_first_tail_x15_r0_body.cnh132, PRE_first_tail_x15_r0_body.cnn032, PRE_first_tail_x15_r0_body.cnn132, PRE_first_tail_x15_r0_body.cplo32, PRE_first_tail_x15_r0_body.ccnt32, PRE_first_tail_x15_r0_body.cnband32, PRE_first_tail_x15_r0_body.chbelow32, PRE_first_tail_x15_r0_body.chren32, PRE_first_tail_x15_r0_body.cband32, PRE_first_tail_x15_r0_body.cnh1pos32, PRE_first_tail_x15_r0_body.cnren32, PRE_first_tail_x15_r0_body.cnlow32, PRE_first_tail_x15_r0_body.cabs0a32, PRE_first_tail_x15_r0_body.cabs0b32, PRE_first_tail_x15_r0_body.ctok132, PRE_first_tail_x15_r0_body.cpend32, PRE_first_tail_x15_r0_body.cerrh32, PRE_first_tail_x15_r0_body.cfiles32, PRE_first_tail_x15_r0_body.carch32, PRE_first_tail_x15_r0_body.csizes32, PRE_first_tail_x15_r0_body.cwired32, PRE_first_tail_x15_r0_body.cfix32, clean, PRE_first_tail_x15_r0_body.fcxn32, PRE_first_tail_x15_r0_body.fcnn32, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle032, PRE_first_tail_x15_r0_body.fnk32, PRE_first_tail_x15_r0_body.ckA32, PRE_first_tail_x15_r0_body.cobjsK32, PRE_first_tail_x15_r0_body.cnodesK32, PRE_first_tail_x15_r0_body.citemsK32, PRE_first_tail_x15_r0_body.f1A32, PRE_first_tail_x15_r0_body.f1O32, PRE_first_tail_x15_r0_body.f1N32, PRE_first_tail_x15_r0_body.f1I32, PRE_first_tail_x15_r0_body.fbd32, PRE_first_tail_x15_r0_body.fincW32, PRE_first_tail_x15_r0_body.fincI32, PRE_first_tail_x15_r0_body.fincN32, PRE_first_tail_x15_r0_body.flnF32, PRE_first_tail_x15_r0_body.fh32, PRE_first_tail_x15_r0_body.fo32, PRE_first_tail_x15_r0_body.fok32, PRE_first_tail_x15_r0_body.fnd32, PRE_first_tail_x15_r0_body.fp32, PRE_first_tail_x15_r0_body.fnord32, PRE_first_tail_x15_r0_body.fi32, PRE_first_tail_x15_r0_body.fii32⟩
theorem PRE_first_tail_x15_r0_body.cnshift32 (clean : Conv.NClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P32.NL) (cl : SSt (· < 1423) PRE_first_tail_x15_r0_body.cx0_32.mlx) : NShift PRE_first_tail_x15_r0_body.P32 1423 PRE_first_tail_x15_r0_body.kappa32 PRE_first_tail_x15_r0_body.cx0_32 PRE_first_tail_x15_r0_body.cx1_32 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot32 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost32 (compact_a_eq PRE_first_tail_x15_r0_body.ckn032 PRE_first_tail_x15_r0_body.ckn132 PRE_first_tail_x15_r0_body.ckheap32 PRE_first_tail_x15_r0_body.ckpl32)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_32 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s289.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_32 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s289.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_32 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s289.ffi) = some PRE_first_tail_x15_r0_body.fxC_32
kernel_rfl PRE_first_tail_x15_r0_body.okrC_32 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s289.ffi) = some PRE_first_tail_x15_r0_body.krC_32
noncomputable def PRE_first_tail_x15_r0_body.fx0_32 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s291.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_32 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s291.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_32 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s291.ffi) = some PRE_first_tail_x15_r0_body.fx0_32
kernel_rfl PRE_first_tail_x15_r0_body.okr0_32 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s291.ffi) = some PRE_first_tail_x15_r0_body.kr0_32
noncomputable def PRE_first_tail_x15_r0_body.fx1_32 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s290.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_32 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s290.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_32 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s290.ffi) = some PRE_first_tail_x15_r0_body.fx1_32
kernel_rfl PRE_first_tail_x15_r0_body.okr1_32 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s290.ffi) = some PRE_first_tail_x15_r0_body.kr1_32
kernel_rfl PRE_first_tail_x15_r0_body.ff032 : PRE_first_tail_x15_r0_body.fx0_32 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_32 (PRE_first_tail_x15_r0_body.clo32.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_32.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff132 : PRE_first_tail_x15_r0_body.fx1_32 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_32 (PRE_first_tail_x15_r0_body.cwS32.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_32.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck32 : freedLB PRE_first_tail_x15_r0_body.kappa32 PRE_first_tail_x15_r0_body.cx0_32.mlx PRE_first_tail_x15_r0_body.fx0_32 PRE_first_tail_x15_r0_body.fx1_32 PRE_first_tail_x15_r0_body.clo32 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf032 : PRE_first_tail_x15_r0_body.kr0_32.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_32.flags (PRE_first_tail_x15_r0_body.clo32.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_32.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt032 : PRE_first_tail_x15_r0_body.kr0_32.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_32.targs (PRE_first_tail_x15_r0_body.clo32.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_32.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf132 : PRE_first_tail_x15_r0_body.kr1_32.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_32.flags (PRE_first_tail_x15_r0_body.cwS32.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_32.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt132 : PRE_first_tail_x15_r0_body.kr1_32.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_32.targs (PRE_first_tail_x15_r0_body.cwS32.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_32.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck32 : krecLB PRE_first_tail_x15_r0_body.kappa32 1423 PRE_first_tail_x15_r0_body.cx0_32.mlx PRE_first_tail_x15_r0_body.kr0_32 PRE_first_tail_x15_r0_body.kr1_32 PRE_first_tail_x15_r0_body.clo32 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn32 : Nat.ble 1423 1423 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge32 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s290.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s291.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR32 : pendRegB PRE_first_tail_x15_r0_body.kappa32 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s291.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe32 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s291.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s290.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift32 (clean : Conv.NClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P32.NL) (cl : SSt (· < 1423) PRE_first_tail_x15_r0_body.cx0_32.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_32.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_32.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_32.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_32.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P32 1423 PRE_first_tail_x15_r0_body.kappa32 PRE_first_tail_x15_r0_body.s291.ffi PRE_first_tail_x15_r0_body.s290.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift32 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue32, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp32 t ht),
    PRE_first_tail_x15_r0_body.cbridge32,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s291.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s290.ffi) (PRE_first_tail_x15_r0_body.cfoot32 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_32 PRE_first_tail_x15_r0_body.ofx1_32 hobjC PRE_first_tail_x15_r0_body.ff032 PRE_first_tail_x15_r0_body.ff132 PRE_first_tail_x15_r0_body.ffck32,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s291.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s290.ffi) (PRE_first_tail_x15_r0_body.cfoot32 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_32 PRE_first_tail_x15_r0_body.okr1_32 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn32) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf032 PRE_first_tail_x15_r0_body.fkt032 PRE_first_tail_x15_r0_body.fkf132 PRE_first_tail_x15_r0_body.fkt132 PRE_first_tail_x15_r0_body.fkck32,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh032 PRE_first_tail_x15_r0_body.cnh132 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe32) PRE_first_tail_x15_r0_body.cpendR32⟩

end Host.Load.Run.Tpl
