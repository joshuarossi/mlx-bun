import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl157
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 157 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc157 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P157 : LoadP := PRE_first_tail_x15_r0_body.Pc157.raise 18399
kernel_rfl PRE_first_tail_x15_r0_body.craise157 : Nat.ble PRE_first_tail_x15_r0_body.Pc157.N0 18399 = true
theorem PRE_first_tail_x15_r0_body.raised157 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc157 PRE_first_tail_x15_r0_body.P157 :=
  .inr ⟨18399, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise157, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_157 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1521.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_157 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1520.ffi)
def PRE_first_tail_x15_r0_body.khinv157 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv157 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS157 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS157 : List Nat := List.range' 18399 0
def PRE_first_tail_x15_r0_body.ciS157 : List Nat := [] ++ List.range' 18399 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0157 : PRE_first_tail_x15_r0_body.kd157.nh0 = PRE_first_tail_x15_r0_body.cx0_157.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1157 : PRE_first_tail_x15_r0_body.kd157.nh1 = PRE_first_tail_x15_r0_body.cx1_157.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0157 : PRE_first_tail_x15_r0_body.kd157.nn0 = PRE_first_tail_x15_r0_body.cx0_157.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1157 : PRE_first_tail_x15_r0_body.kd157.nn1 = PRE_first_tail_x15_r0_body.cx1_157.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo157 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P157.lo && Nat.ble PRE_first_tail_x15_r0_body.P157.lo PRE_first_tail_x15_r0_body.cx0_157.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P157.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P157.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt157 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_157.mlx.next PRE_first_tail_x15_r0_body.cx1_157.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_157.mlx.nnext PRE_first_tail_x15_r0_body.cx1_157.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband157 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P157.NL && Nat.ble PRE_first_tail_x15_r0_body.P157.NL PRE_first_tail_x15_r0_body.P157.N0 && Nat.ble PRE_first_tail_x15_r0_body.P157.N0 PRE_first_tail_x15_r0_body.cx0_157.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow157 : PRE_first_tail_x15_r0_body.kd157.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren157 : checkRenG PRE_first_tail_x15_r0_body.kd157.hnd PRE_first_tail_x15_r0_body.khinv157 (phB PRE_first_tail_x15_r0_body.cx0_157.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband157 : PRE_first_tail_x15_r0_body.kd157.checkBand PRE_first_tail_x15_r0_body.P157.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos157 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd157.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren157 : checkRenG PRE_first_tail_x15_r0_body.kd157.node PRE_first_tail_x15_r0_body.kninv157 (pnB PRE_first_tail_x15_r0_body.cx0_157.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow157 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd157.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P157.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd157.nodeF j) PRE_first_tail_x15_r0_body.cx1_157.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a157 : PRE_first_tail_x15_r0_body.cx0_157.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b157 : PRE_first_tail_x15_r0_body.cx0_157.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1157 : PRE_first_tail_x15_r0_body.cx1_157.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend157 : PRE_first_tail_x15_r0_body.cx1_157.mlx.pending = PRE_first_tail_x15_r0_body.cx0_157.mlx.pending.map PRE_first_tail_x15_r0_body.kappa157.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh157 : PRE_first_tail_x15_r0_body.cx1_157.mlx.errh = PRE_first_tail_x15_r0_body.cx0_157.mlx.errh.map PRE_first_tail_x15_r0_body.kappa157.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles157 : PRE_first_tail_x15_r0_body.cx1_157.mlx.files = PRE_first_tail_x15_r0_body.cx0_157.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch157 : PRE_first_tail_x15_r0_body.cx1_157.mlx.arch = PRE_first_tail_x15_r0_body.cx0_157.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes157 : PRE_first_tail_x15_r0_body.cx1_157.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_157.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired157 : PRE_first_tail_x15_r0_body.cx1_157.mlx.wired = PRE_first_tail_x15_r0_body.cx0_157.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost157 : PRE_first_tail_x15_r0_body.cx1_157.host = PRE_first_tail_x15_r0_body.cx0_157.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd157`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0157 : PRE_first_tail_x15_r0_body.kd157.n0 = 2798375
kernel_rfl PRE_first_tail_x15_r0_body.ckn1157 : PRE_first_tail_x15_r0_body.kd157.n1 = 2798377
kernel_rfl PRE_first_tail_x15_r0_body.ckheap157 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd157.heap).all (fun x => Nat.ble 2798375 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl157 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd157.heap.get (2798375 + j) = nth? PRE_first_tail_x15_r0_body.pl157 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja157 : Nat.ble 2798375 2798375 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn157 : Nat.ble 6791 6791 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD157 : Nat.ble 2798375 PRE_first_tail_x15_r0_body.kd157.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn157 : Nat.ble 21300 PRE_first_tail_x15_r0_body.kd157.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn157 : Nat.ble 18399 PRE_first_tail_x15_r0_body.kd157.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb157 : Nat.ble 21300 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap157 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd157.heap).all (Nat.ble (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd157 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd157.hnd).all (Nat.ble (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode157 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd157.node).all (Nat.ble (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix157 : Conv.FixOld (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa157 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja157) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn157) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD157) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn157) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn157) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb157) PRE_first_tail_x15_r0_body.fheap157 PRE_first_tail_x15_r0_body.fhnd157 PRE_first_tail_x15_r0_body.fnode157
kernel_rfl PRE_first_tail_x15_r0_body.fcxn157 : (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn157 : (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0157 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_157.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_157.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk157 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd157.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A157 : PRE_first_tail_x15_r0_body.cx1_157.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS157.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_157.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O157 : PRE_first_tail_x15_r0_body.cx1_157.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS157.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_157.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N157 : PRE_first_tail_x15_r0_body.cx1_157.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS157.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_157.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I157 : PRE_first_tail_x15_r0_body.cx1_157.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS157.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_157.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd157 : (PRE_first_tail_x15_r0_body.clo157 ++ PRE_first_tail_x15_r0_body.cln157 ++ PRE_first_tail_x15_r0_body.cli157 ++ PRE_first_tail_x15_r0_body.cwS157 ++ PRE_first_tail_x15_r0_body.cnS157 ++ PRE_first_tail_x15_r0_body.ciS157).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW157 : PRE_first_tail_x15_r0_body.cwS157.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo157.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI157 : PRE_first_tail_x15_r0_body.ciS157.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli157.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN157 : PRE_first_tail_x15_r0_body.cnS157.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF157 : PRE_first_tail_x15_r0_body.cln157.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh157 : PRE_first_tail_x15_r0_body.clo157.all (handleOK PRE_first_tail_x15_r0_body.kappa157 PRE_first_tail_x15_r0_body.P157.lo PRE_first_tail_x15_r0_body.cx0_157.mlx PRE_first_tail_x15_r0_body.cx1_157.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo157 : PRE_first_tail_x15_r0_body.clo157.map (fun h => PRE_first_tail_x15_r0_body.cx1_157.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa157.handle h)) = PRE_first_tail_x15_r0_body.clo157.map (fun h => (PRE_first_tail_x15_r0_body.cx0_157.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa157.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok157 : PRE_first_tail_x15_r0_body.clo157.all (objOK PRE_first_tail_x15_r0_body.kappa157 PRE_first_tail_x15_r0_body.P157.NL PRE_first_tail_x15_r0_body.cx0_157.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd157 : PRE_first_tail_x15_r0_body.cln157.all (nodeOKF PRE_first_tail_x15_r0_body.kappa157 PRE_first_tail_x15_r0_body.P157 PRE_first_tail_x15_r0_body.cx0_157.mlx PRE_first_tail_x15_r0_body.cx1_157.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp157 : ((PRE_first_tail_x15_r0_body.cln157.filter (fullB PRE_first_tail_x15_r0_body.P157))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_157.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa157.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln157.filter (fullB PRE_first_tail_x15_r0_body.P157))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_157.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa157.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI157 : incrB PRE_first_tail_x15_r0_body.kd157.nodeF (List.range' 18399 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK157 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd157.node).all (fun k => Nat.ble 18399 k && Nat.blt k 18399) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL157 : (PRE_first_tail_x15_r0_body.cln157.filter (Nat.ble PRE_first_tail_x15_r0_body.P157.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd157.nodeF i) && (Nat.blt i 18399 || Nat.ble PRE_first_tail_x15_r0_body.kd157.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord157 : (PRE_first_tail_x15_r0_body.cln157.filter (Nat.ble PRE_first_tail_x15_r0_body.P157.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd157.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd157.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd157.nodeF j) (PRE_first_tail_x15_r0_body.kd157.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow157 PRE_first_tail_x15_r0_body.cnn1157 PRE_first_tail_x15_r0_body.fnordI157 PRE_first_tail_x15_r0_body.fnordK157 PRE_first_tail_x15_r0_body.fnordL157
kernel_rfl PRE_first_tail_x15_r0_body.fi157 : PRE_first_tail_x15_r0_body.cli157.all (pnB PRE_first_tail_x15_r0_body.cx0_157.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii157 : PRE_first_tail_x15_r0_body.cli157.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_157.mlx.items.get (PRE_first_tail_x15_r0_body.kappa157.node k) = (PRE_first_tail_x15_r0_body.cx0_157.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa157.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot157 (clean : Conv.NClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P157.NL) (cl : SSt (· < 6791) PRE_first_tail_x15_r0_body.cx0_157.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P157 6791 PRE_first_tail_x15_r0_body.kappa157 PRE_first_tail_x15_r0_body.kd157 PRE_first_tail_x15_r0_body.khinv157 PRE_first_tail_x15_r0_body.kninv157 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx PRE_first_tail_x15_r0_body.cx0_157.mlx PRE_first_tail_x15_r0_body.cx1_157.mlx (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo157 PRE_first_tail_x15_r0_body.cln157 PRE_first_tail_x15_r0_body.cli157 PRE_first_tail_x15_r0_body.cwS157 PRE_first_tail_x15_r0_body.cnS157 PRE_first_tail_x15_r0_body.ciS157 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0157, PRE_first_tail_x15_r0_body.cnh1157, PRE_first_tail_x15_r0_body.cnn0157, PRE_first_tail_x15_r0_body.cnn1157, PRE_first_tail_x15_r0_body.cplo157, PRE_first_tail_x15_r0_body.ccnt157, PRE_first_tail_x15_r0_body.cnband157, PRE_first_tail_x15_r0_body.chbelow157, PRE_first_tail_x15_r0_body.chren157, PRE_first_tail_x15_r0_body.cband157, PRE_first_tail_x15_r0_body.cnh1pos157, PRE_first_tail_x15_r0_body.cnren157, PRE_first_tail_x15_r0_body.cnlow157, PRE_first_tail_x15_r0_body.cabs0a157, PRE_first_tail_x15_r0_body.cabs0b157, PRE_first_tail_x15_r0_body.ctok1157, PRE_first_tail_x15_r0_body.cpend157, PRE_first_tail_x15_r0_body.cerrh157, PRE_first_tail_x15_r0_body.cfiles157, PRE_first_tail_x15_r0_body.carch157, PRE_first_tail_x15_r0_body.csizes157, PRE_first_tail_x15_r0_body.cwired157, PRE_first_tail_x15_r0_body.cfix157, clean, PRE_first_tail_x15_r0_body.fcxn157, PRE_first_tail_x15_r0_body.fcnn157, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0157, PRE_first_tail_x15_r0_body.fnk157, PRE_first_tail_x15_r0_body.ckA157, PRE_first_tail_x15_r0_body.cobjsK157, PRE_first_tail_x15_r0_body.cnodesK157, PRE_first_tail_x15_r0_body.citemsK157, PRE_first_tail_x15_r0_body.f1A157, PRE_first_tail_x15_r0_body.f1O157, PRE_first_tail_x15_r0_body.f1N157, PRE_first_tail_x15_r0_body.f1I157, PRE_first_tail_x15_r0_body.fbd157, PRE_first_tail_x15_r0_body.fincW157, PRE_first_tail_x15_r0_body.fincI157, PRE_first_tail_x15_r0_body.fincN157, PRE_first_tail_x15_r0_body.flnF157, PRE_first_tail_x15_r0_body.fh157, PRE_first_tail_x15_r0_body.fo157, PRE_first_tail_x15_r0_body.fok157, PRE_first_tail_x15_r0_body.fnd157, PRE_first_tail_x15_r0_body.fp157, PRE_first_tail_x15_r0_body.fnord157, PRE_first_tail_x15_r0_body.fi157, PRE_first_tail_x15_r0_body.fii157⟩
theorem PRE_first_tail_x15_r0_body.cnshift157 (clean : Conv.NClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P157.NL) (cl : SSt (· < 6791) PRE_first_tail_x15_r0_body.cx0_157.mlx) : NShift PRE_first_tail_x15_r0_body.P157 6791 PRE_first_tail_x15_r0_body.kappa157 PRE_first_tail_x15_r0_body.cx0_157 PRE_first_tail_x15_r0_body.cx1_157 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot157 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost157 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0157 PRE_first_tail_x15_r0_body.ckn1157 PRE_first_tail_x15_r0_body.ckheap157 PRE_first_tail_x15_r0_body.ckpl157)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_157 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1519.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_157 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1519.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_157 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1519.ffi) = some PRE_first_tail_x15_r0_body.fxC_157
kernel_rfl PRE_first_tail_x15_r0_body.okrC_157 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1519.ffi) = some PRE_first_tail_x15_r0_body.krC_157
noncomputable def PRE_first_tail_x15_r0_body.fx0_157 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1521.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_157 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1521.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_157 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1521.ffi) = some PRE_first_tail_x15_r0_body.fx0_157
kernel_rfl PRE_first_tail_x15_r0_body.okr0_157 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1521.ffi) = some PRE_first_tail_x15_r0_body.kr0_157
noncomputable def PRE_first_tail_x15_r0_body.fx1_157 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1520.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_157 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1520.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_157 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1520.ffi) = some PRE_first_tail_x15_r0_body.fx1_157
kernel_rfl PRE_first_tail_x15_r0_body.okr1_157 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1520.ffi) = some PRE_first_tail_x15_r0_body.kr1_157
kernel_rfl PRE_first_tail_x15_r0_body.ff0157 : PRE_first_tail_x15_r0_body.fx0_157 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_157 (PRE_first_tail_x15_r0_body.clo157.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_157.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1157 : PRE_first_tail_x15_r0_body.fx1_157 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_157 (PRE_first_tail_x15_r0_body.cwS157.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_157.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck157 : freedLB PRE_first_tail_x15_r0_body.kappa157 PRE_first_tail_x15_r0_body.cx0_157.mlx PRE_first_tail_x15_r0_body.fx0_157 PRE_first_tail_x15_r0_body.fx1_157 PRE_first_tail_x15_r0_body.clo157 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0157 : PRE_first_tail_x15_r0_body.kr0_157.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_157.flags (PRE_first_tail_x15_r0_body.clo157.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_157.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0157 : PRE_first_tail_x15_r0_body.kr0_157.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_157.targs (PRE_first_tail_x15_r0_body.clo157.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_157.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1157 : PRE_first_tail_x15_r0_body.kr1_157.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_157.flags (PRE_first_tail_x15_r0_body.cwS157.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_157.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1157 : PRE_first_tail_x15_r0_body.kr1_157.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_157.targs (PRE_first_tail_x15_r0_body.cwS157.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_157.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck157 : krecLB PRE_first_tail_x15_r0_body.kappa157 6791 PRE_first_tail_x15_r0_body.cx0_157.mlx PRE_first_tail_x15_r0_body.kr0_157 PRE_first_tail_x15_r0_body.kr1_157 PRE_first_tail_x15_r0_body.clo157 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn157 : Nat.ble 6791 6791 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge157 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1520.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1521.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR157 : pendRegB PRE_first_tail_x15_r0_body.kappa157 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1521.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe157 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1521.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1520.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift157 (clean : Conv.NClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P157.NL) (cl : SSt (· < 6791) PRE_first_tail_x15_r0_body.cx0_157.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_157.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_157.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_157.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_157.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P157 6791 PRE_first_tail_x15_r0_body.kappa157 PRE_first_tail_x15_r0_body.s1521.ffi PRE_first_tail_x15_r0_body.s1520.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift157 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue157, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp157 t ht),
    PRE_first_tail_x15_r0_body.cbridge157,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1521.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1520.ffi) (PRE_first_tail_x15_r0_body.cfoot157 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_157 PRE_first_tail_x15_r0_body.ofx1_157 hobjC PRE_first_tail_x15_r0_body.ff0157 PRE_first_tail_x15_r0_body.ff1157 PRE_first_tail_x15_r0_body.ffck157,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1521.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1520.ffi) (PRE_first_tail_x15_r0_body.cfoot157 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_157 PRE_first_tail_x15_r0_body.okr1_157 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn157) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0157 PRE_first_tail_x15_r0_body.fkt0157 PRE_first_tail_x15_r0_body.fkf1157 PRE_first_tail_x15_r0_body.fkt1157 PRE_first_tail_x15_r0_body.fkck157,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0157 PRE_first_tail_x15_r0_body.cnh1157 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe157) PRE_first_tail_x15_r0_body.cpendR157⟩

end Host.Load.Run.Tpl
