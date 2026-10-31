import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl182
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 182 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc182 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P182 : LoadP := PRE_first_tail_x15_r0_body.Pc182.raise 18877
kernel_rfl PRE_first_tail_x15_r0_body.craise182 : Nat.ble PRE_first_tail_x15_r0_body.Pc182.N0 18877 = true
theorem PRE_first_tail_x15_r0_body.raised182 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc182 PRE_first_tail_x15_r0_body.P182 :=
  .inr ⟨18877, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise182, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_182 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1602.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_182 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1601.ffi)
def PRE_first_tail_x15_r0_body.khinv182 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv182 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS182 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS182 : List Nat := List.range' 18877 0
def PRE_first_tail_x15_r0_body.ciS182 : List Nat := [] ++ List.range' 18877 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0182 : PRE_first_tail_x15_r0_body.kd182.nh0 = PRE_first_tail_x15_r0_body.cx0_182.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1182 : PRE_first_tail_x15_r0_body.kd182.nh1 = PRE_first_tail_x15_r0_body.cx1_182.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0182 : PRE_first_tail_x15_r0_body.kd182.nn0 = PRE_first_tail_x15_r0_body.cx0_182.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1182 : PRE_first_tail_x15_r0_body.kd182.nn1 = PRE_first_tail_x15_r0_body.cx1_182.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo182 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P182.lo && Nat.ble PRE_first_tail_x15_r0_body.P182.lo PRE_first_tail_x15_r0_body.cx0_182.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P182.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P182.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt182 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_182.mlx.next PRE_first_tail_x15_r0_body.cx1_182.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_182.mlx.nnext PRE_first_tail_x15_r0_body.cx1_182.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband182 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P182.NL && Nat.ble PRE_first_tail_x15_r0_body.P182.NL PRE_first_tail_x15_r0_body.P182.N0 && Nat.ble PRE_first_tail_x15_r0_body.P182.N0 PRE_first_tail_x15_r0_body.cx0_182.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow182 : PRE_first_tail_x15_r0_body.kd182.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren182 : checkRenG PRE_first_tail_x15_r0_body.kd182.hnd PRE_first_tail_x15_r0_body.khinv182 (phB PRE_first_tail_x15_r0_body.cx0_182.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband182 : PRE_first_tail_x15_r0_body.kd182.checkBand PRE_first_tail_x15_r0_body.P182.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos182 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd182.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren182 : checkRenG PRE_first_tail_x15_r0_body.kd182.node PRE_first_tail_x15_r0_body.kninv182 (pnB PRE_first_tail_x15_r0_body.cx0_182.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow182 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd182.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P182.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd182.nodeF j) PRE_first_tail_x15_r0_body.cx1_182.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a182 : PRE_first_tail_x15_r0_body.cx0_182.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b182 : PRE_first_tail_x15_r0_body.cx0_182.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1182 : PRE_first_tail_x15_r0_body.cx1_182.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend182 : PRE_first_tail_x15_r0_body.cx1_182.mlx.pending = PRE_first_tail_x15_r0_body.cx0_182.mlx.pending.map PRE_first_tail_x15_r0_body.kappa182.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh182 : PRE_first_tail_x15_r0_body.cx1_182.mlx.errh = PRE_first_tail_x15_r0_body.cx0_182.mlx.errh.map PRE_first_tail_x15_r0_body.kappa182.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles182 : PRE_first_tail_x15_r0_body.cx1_182.mlx.files = PRE_first_tail_x15_r0_body.cx0_182.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch182 : PRE_first_tail_x15_r0_body.cx1_182.mlx.arch = PRE_first_tail_x15_r0_body.cx0_182.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes182 : PRE_first_tail_x15_r0_body.cx1_182.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_182.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired182 : PRE_first_tail_x15_r0_body.cx1_182.mlx.wired = PRE_first_tail_x15_r0_body.cx0_182.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost182 : PRE_first_tail_x15_r0_body.cx1_182.host = PRE_first_tail_x15_r0_body.cx0_182.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd182`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0182 : PRE_first_tail_x15_r0_body.kd182.n0 = 2817512
kernel_rfl PRE_first_tail_x15_r0_body.ckn1182 : PRE_first_tail_x15_r0_body.kd182.n1 = 2817531
kernel_rfl PRE_first_tail_x15_r0_body.ckheap182 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd182.heap).all (fun x => Nat.ble 2817511 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl182 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd182.heap.get (2817511 + j) = nth? PRE_first_tail_x15_r0_body.pl182 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja182 : Nat.ble 2817511 2817511 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn182 : Nat.ble 7834 7834 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD182 : Nat.ble 2817511 PRE_first_tail_x15_r0_body.kd182.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn182 : Nat.ble 21779 PRE_first_tail_x15_r0_body.kd182.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn182 : Nat.ble 18877 PRE_first_tail_x15_r0_body.kd182.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb182 : Nat.ble 21779 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap182 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd182.heap).all (Nat.ble (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd182 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd182.hnd).all (Nat.ble (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode182 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd182.node).all (Nat.ble (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix182 : Conv.FixOld (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa182 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja182) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn182) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD182) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn182) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn182) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb182) PRE_first_tail_x15_r0_body.fheap182 PRE_first_tail_x15_r0_body.fhnd182 PRE_first_tail_x15_r0_body.fnode182
kernel_rfl PRE_first_tail_x15_r0_body.fcxn182 : (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn182 : (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0182 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_182.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_182.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk182 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd182.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A182 : PRE_first_tail_x15_r0_body.cx1_182.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS182.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_182.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O182 : PRE_first_tail_x15_r0_body.cx1_182.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS182.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_182.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N182 : PRE_first_tail_x15_r0_body.cx1_182.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS182.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_182.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I182 : PRE_first_tail_x15_r0_body.cx1_182.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS182.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_182.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd182 : (PRE_first_tail_x15_r0_body.clo182 ++ PRE_first_tail_x15_r0_body.cln182 ++ PRE_first_tail_x15_r0_body.cli182 ++ PRE_first_tail_x15_r0_body.cwS182 ++ PRE_first_tail_x15_r0_body.cnS182 ++ PRE_first_tail_x15_r0_body.ciS182).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW182 : PRE_first_tail_x15_r0_body.cwS182.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo182.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI182 : PRE_first_tail_x15_r0_body.ciS182.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli182.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN182 : PRE_first_tail_x15_r0_body.cnS182.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF182 : PRE_first_tail_x15_r0_body.cln182.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh182 : PRE_first_tail_x15_r0_body.clo182.all (handleOK PRE_first_tail_x15_r0_body.kappa182 PRE_first_tail_x15_r0_body.P182.lo PRE_first_tail_x15_r0_body.cx0_182.mlx PRE_first_tail_x15_r0_body.cx1_182.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo182 : PRE_first_tail_x15_r0_body.clo182.map (fun h => PRE_first_tail_x15_r0_body.cx1_182.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa182.handle h)) = PRE_first_tail_x15_r0_body.clo182.map (fun h => (PRE_first_tail_x15_r0_body.cx0_182.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa182.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok182 : PRE_first_tail_x15_r0_body.clo182.all (objOK PRE_first_tail_x15_r0_body.kappa182 PRE_first_tail_x15_r0_body.P182.NL PRE_first_tail_x15_r0_body.cx0_182.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd182 : PRE_first_tail_x15_r0_body.cln182.all (nodeOKF PRE_first_tail_x15_r0_body.kappa182 PRE_first_tail_x15_r0_body.P182 PRE_first_tail_x15_r0_body.cx0_182.mlx PRE_first_tail_x15_r0_body.cx1_182.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp182 : ((PRE_first_tail_x15_r0_body.cln182.filter (fullB PRE_first_tail_x15_r0_body.P182))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_182.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa182.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln182.filter (fullB PRE_first_tail_x15_r0_body.P182))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_182.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa182.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI182 : incrB PRE_first_tail_x15_r0_body.kd182.nodeF (List.range' 18877 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK182 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd182.node).all (fun k => Nat.ble 18877 k && Nat.blt k 18877) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL182 : (PRE_first_tail_x15_r0_body.cln182.filter (Nat.ble PRE_first_tail_x15_r0_body.P182.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd182.nodeF i) && (Nat.blt i 18877 || Nat.ble PRE_first_tail_x15_r0_body.kd182.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord182 : (PRE_first_tail_x15_r0_body.cln182.filter (Nat.ble PRE_first_tail_x15_r0_body.P182.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd182.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd182.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd182.nodeF j) (PRE_first_tail_x15_r0_body.kd182.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow182 PRE_first_tail_x15_r0_body.cnn1182 PRE_first_tail_x15_r0_body.fnordI182 PRE_first_tail_x15_r0_body.fnordK182 PRE_first_tail_x15_r0_body.fnordL182
kernel_rfl PRE_first_tail_x15_r0_body.fi182 : PRE_first_tail_x15_r0_body.cli182.all (pnB PRE_first_tail_x15_r0_body.cx0_182.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii182 : PRE_first_tail_x15_r0_body.cli182.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_182.mlx.items.get (PRE_first_tail_x15_r0_body.kappa182.node k) = (PRE_first_tail_x15_r0_body.cx0_182.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa182.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot182 (clean : Conv.NClean (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P182.NL) (cl : SSt (· < 7834) PRE_first_tail_x15_r0_body.cx0_182.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P182 7834 PRE_first_tail_x15_r0_body.kappa182 PRE_first_tail_x15_r0_body.kd182 PRE_first_tail_x15_r0_body.khinv182 PRE_first_tail_x15_r0_body.kninv182 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx PRE_first_tail_x15_r0_body.cx0_182.mlx PRE_first_tail_x15_r0_body.cx1_182.mlx (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo182 PRE_first_tail_x15_r0_body.cln182 PRE_first_tail_x15_r0_body.cli182 PRE_first_tail_x15_r0_body.cwS182 PRE_first_tail_x15_r0_body.cnS182 PRE_first_tail_x15_r0_body.ciS182 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0182, PRE_first_tail_x15_r0_body.cnh1182, PRE_first_tail_x15_r0_body.cnn0182, PRE_first_tail_x15_r0_body.cnn1182, PRE_first_tail_x15_r0_body.cplo182, PRE_first_tail_x15_r0_body.ccnt182, PRE_first_tail_x15_r0_body.cnband182, PRE_first_tail_x15_r0_body.chbelow182, PRE_first_tail_x15_r0_body.chren182, PRE_first_tail_x15_r0_body.cband182, PRE_first_tail_x15_r0_body.cnh1pos182, PRE_first_tail_x15_r0_body.cnren182, PRE_first_tail_x15_r0_body.cnlow182, PRE_first_tail_x15_r0_body.cabs0a182, PRE_first_tail_x15_r0_body.cabs0b182, PRE_first_tail_x15_r0_body.ctok1182, PRE_first_tail_x15_r0_body.cpend182, PRE_first_tail_x15_r0_body.cerrh182, PRE_first_tail_x15_r0_body.cfiles182, PRE_first_tail_x15_r0_body.carch182, PRE_first_tail_x15_r0_body.csizes182, PRE_first_tail_x15_r0_body.cwired182, PRE_first_tail_x15_r0_body.cfix182, clean, PRE_first_tail_x15_r0_body.fcxn182, PRE_first_tail_x15_r0_body.fcnn182, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0182, PRE_first_tail_x15_r0_body.fnk182, PRE_first_tail_x15_r0_body.ckA182, PRE_first_tail_x15_r0_body.cobjsK182, PRE_first_tail_x15_r0_body.cnodesK182, PRE_first_tail_x15_r0_body.citemsK182, PRE_first_tail_x15_r0_body.f1A182, PRE_first_tail_x15_r0_body.f1O182, PRE_first_tail_x15_r0_body.f1N182, PRE_first_tail_x15_r0_body.f1I182, PRE_first_tail_x15_r0_body.fbd182, PRE_first_tail_x15_r0_body.fincW182, PRE_first_tail_x15_r0_body.fincI182, PRE_first_tail_x15_r0_body.fincN182, PRE_first_tail_x15_r0_body.flnF182, PRE_first_tail_x15_r0_body.fh182, PRE_first_tail_x15_r0_body.fo182, PRE_first_tail_x15_r0_body.fok182, PRE_first_tail_x15_r0_body.fnd182, PRE_first_tail_x15_r0_body.fp182, PRE_first_tail_x15_r0_body.fnord182, PRE_first_tail_x15_r0_body.fi182, PRE_first_tail_x15_r0_body.fii182⟩
theorem PRE_first_tail_x15_r0_body.cnshift182 (clean : Conv.NClean (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P182.NL) (cl : SSt (· < 7834) PRE_first_tail_x15_r0_body.cx0_182.mlx) : NShift PRE_first_tail_x15_r0_body.P182 7834 PRE_first_tail_x15_r0_body.kappa182 PRE_first_tail_x15_r0_body.cx0_182 PRE_first_tail_x15_r0_body.cx1_182 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot182 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost182 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0182 PRE_first_tail_x15_r0_body.ckn1182 PRE_first_tail_x15_r0_body.ckheap182 PRE_first_tail_x15_r0_body.ckpl182)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_182 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1600.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_182 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1600.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_182 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1600.ffi) = some PRE_first_tail_x15_r0_body.fxC_182
kernel_rfl PRE_first_tail_x15_r0_body.okrC_182 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1600.ffi) = some PRE_first_tail_x15_r0_body.krC_182
noncomputable def PRE_first_tail_x15_r0_body.fx0_182 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1602.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_182 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1602.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_182 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1602.ffi) = some PRE_first_tail_x15_r0_body.fx0_182
kernel_rfl PRE_first_tail_x15_r0_body.okr0_182 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1602.ffi) = some PRE_first_tail_x15_r0_body.kr0_182
noncomputable def PRE_first_tail_x15_r0_body.fx1_182 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1601.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_182 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1601.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_182 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1601.ffi) = some PRE_first_tail_x15_r0_body.fx1_182
kernel_rfl PRE_first_tail_x15_r0_body.okr1_182 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1601.ffi) = some PRE_first_tail_x15_r0_body.kr1_182
kernel_rfl PRE_first_tail_x15_r0_body.ff0182 : PRE_first_tail_x15_r0_body.fx0_182 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_182 (PRE_first_tail_x15_r0_body.clo182.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_182.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1182 : PRE_first_tail_x15_r0_body.fx1_182 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_182 (PRE_first_tail_x15_r0_body.cwS182.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_182.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck182 : freedLB PRE_first_tail_x15_r0_body.kappa182 PRE_first_tail_x15_r0_body.cx0_182.mlx PRE_first_tail_x15_r0_body.fx0_182 PRE_first_tail_x15_r0_body.fx1_182 PRE_first_tail_x15_r0_body.clo182 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0182 : PRE_first_tail_x15_r0_body.kr0_182.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_182.flags (PRE_first_tail_x15_r0_body.clo182.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_182.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0182 : PRE_first_tail_x15_r0_body.kr0_182.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_182.targs (PRE_first_tail_x15_r0_body.clo182.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_182.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1182 : PRE_first_tail_x15_r0_body.kr1_182.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_182.flags (PRE_first_tail_x15_r0_body.cwS182.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_182.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1182 : PRE_first_tail_x15_r0_body.kr1_182.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_182.targs (PRE_first_tail_x15_r0_body.cwS182.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_182.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck182 : krecLB PRE_first_tail_x15_r0_body.kappa182 7834 PRE_first_tail_x15_r0_body.cx0_182.mlx PRE_first_tail_x15_r0_body.kr0_182 PRE_first_tail_x15_r0_body.kr1_182 PRE_first_tail_x15_r0_body.clo182 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn182 : Nat.ble 7834 7834 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge182 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1601.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1602.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR182 : pendRegB PRE_first_tail_x15_r0_body.kappa182 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1602.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe182 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1602.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1601.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift182 (clean : Conv.NClean (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P182.NL) (cl : SSt (· < 7834) PRE_first_tail_x15_r0_body.cx0_182.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_182.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_182.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_182.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_182.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P182 7834 PRE_first_tail_x15_r0_body.kappa182 PRE_first_tail_x15_r0_body.s1602.ffi PRE_first_tail_x15_r0_body.s1601.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift182 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue182, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp182 t ht),
    PRE_first_tail_x15_r0_body.cbridge182,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1602.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1601.ffi) (PRE_first_tail_x15_r0_body.cfoot182 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_182 PRE_first_tail_x15_r0_body.ofx1_182 hobjC PRE_first_tail_x15_r0_body.ff0182 PRE_first_tail_x15_r0_body.ff1182 PRE_first_tail_x15_r0_body.ffck182,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1602.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1601.ffi) (PRE_first_tail_x15_r0_body.cfoot182 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_182 PRE_first_tail_x15_r0_body.okr1_182 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn182) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0182 PRE_first_tail_x15_r0_body.fkt0182 PRE_first_tail_x15_r0_body.fkf1182 PRE_first_tail_x15_r0_body.fkt1182 PRE_first_tail_x15_r0_body.fkck182,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0182 PRE_first_tail_x15_r0_body.cnh1182 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe182) PRE_first_tail_x15_r0_body.cpendR182⟩

end Host.Load.Run.Tpl
