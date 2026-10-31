import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl105
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 105 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc105 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P105 : LoadP := PRE_first_tail_x15_r0_body.Pc105.raise 17378
kernel_rfl PRE_first_tail_x15_r0_body.craise105 : Nat.ble PRE_first_tail_x15_r0_body.Pc105.N0 17378 = true
theorem PRE_first_tail_x15_r0_body.raised105 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc105 PRE_first_tail_x15_r0_body.P105 :=
  .inr ⟨17378, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise105, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_105 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_105 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1023.ffi)
def PRE_first_tail_x15_r0_body.khinv105 : PTrie Nat := Stage.setAll PTrie.nil [(20283, 20281), (20284, 20282), (20286, 20283), (20285, 20284)]
def PRE_first_tail_x15_r0_body.kninv105 : PTrie Nat := Stage.setAll PTrie.nil [(17372, 17372), (17373, 17373), (17374, 17374), (17375, 17375), (17376, 17376), (17377, 17377)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS105 : List Nat := [20281, 20282, 20283, 20284, 20285, 20286]
def PRE_first_tail_x15_r0_body.cnS105 : List Nat := List.range' 17372 6
def PRE_first_tail_x15_r0_body.ciS105 : List Nat := [] ++ List.range' 17372 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0105 : PRE_first_tail_x15_r0_body.kd105.nh0 = PRE_first_tail_x15_r0_body.cx0_105.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1105 : PRE_first_tail_x15_r0_body.kd105.nh1 = PRE_first_tail_x15_r0_body.cx1_105.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0105 : PRE_first_tail_x15_r0_body.kd105.nn0 = PRE_first_tail_x15_r0_body.cx0_105.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1105 : PRE_first_tail_x15_r0_body.kd105.nn1 = PRE_first_tail_x15_r0_body.cx1_105.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo105 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P105.lo && Nat.ble PRE_first_tail_x15_r0_body.P105.lo PRE_first_tail_x15_r0_body.cx0_105.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P105.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P105.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt105 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_105.mlx.next PRE_first_tail_x15_r0_body.cx1_105.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_105.mlx.nnext PRE_first_tail_x15_r0_body.cx1_105.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband105 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P105.NL && Nat.ble PRE_first_tail_x15_r0_body.P105.NL PRE_first_tail_x15_r0_body.P105.N0 && Nat.ble PRE_first_tail_x15_r0_body.P105.N0 PRE_first_tail_x15_r0_body.cx0_105.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow105 : PRE_first_tail_x15_r0_body.kd105.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren105 : checkRenG PRE_first_tail_x15_r0_body.kd105.hnd PRE_first_tail_x15_r0_body.khinv105 (phB PRE_first_tail_x15_r0_body.cx0_105.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband105 : PRE_first_tail_x15_r0_body.kd105.checkBand PRE_first_tail_x15_r0_body.P105.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos105 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd105.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren105 : checkRenG PRE_first_tail_x15_r0_body.kd105.node PRE_first_tail_x15_r0_body.kninv105 (pnB PRE_first_tail_x15_r0_body.cx0_105.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P105.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd105.nodeF j) PRE_first_tail_x15_r0_body.cx1_105.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a105 : PRE_first_tail_x15_r0_body.cx0_105.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b105 : PRE_first_tail_x15_r0_body.cx0_105.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.pending = PRE_first_tail_x15_r0_body.cx0_105.mlx.pending.map PRE_first_tail_x15_r0_body.kappa105.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.errh = PRE_first_tail_x15_r0_body.cx0_105.mlx.errh.map PRE_first_tail_x15_r0_body.kappa105.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.files = PRE_first_tail_x15_r0_body.cx0_105.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.arch = PRE_first_tail_x15_r0_body.cx0_105.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_105.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.wired = PRE_first_tail_x15_r0_body.cx0_105.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost105 : PRE_first_tail_x15_r0_body.cx1_105.host = PRE_first_tail_x15_r0_body.cx0_105.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd105`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0105 : PRE_first_tail_x15_r0_body.kd105.n0 = 2757847
kernel_rfl PRE_first_tail_x15_r0_body.ckn1105 : PRE_first_tail_x15_r0_body.kd105.n1 = 2758197
kernel_rfl PRE_first_tail_x15_r0_body.ckheap105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.heap).all (fun x => Nat.ble 2757832 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl105 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd105.heap.get (2757832 + j) = nth? PRE_first_tail_x15_r0_body.pl105 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja105 : Nat.ble 2757832 2757832 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn105 : Nat.ble 4578 4578 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD105 : Nat.ble 2757832 PRE_first_tail_x15_r0_body.kd105.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn105 : Nat.ble 20281 PRE_first_tail_x15_r0_body.kd105.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn105 : Nat.ble 17372 PRE_first_tail_x15_r0_body.kd105.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb105 : Nat.ble 20281 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.heap).all (Nat.ble (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.hnd).all (Nat.ble (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.node).all (Nat.ble (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix105 : Conv.FixOld (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa105 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja105) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn105) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD105) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn105) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn105) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb105) PRE_first_tail_x15_r0_body.fheap105 PRE_first_tail_x15_r0_body.fhnd105 PRE_first_tail_x15_r0_body.fnode105
kernel_rfl PRE_first_tail_x15_r0_body.fcxn105 : (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn105 : (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0105 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_105.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_105.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS105.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_105.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS105.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_105.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS105.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_105.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I105 : PRE_first_tail_x15_r0_body.cx1_105.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS105.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_105.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd105 : (PRE_first_tail_x15_r0_body.clo105 ++ PRE_first_tail_x15_r0_body.cln105 ++ PRE_first_tail_x15_r0_body.cli105 ++ PRE_first_tail_x15_r0_body.cwS105 ++ PRE_first_tail_x15_r0_body.cnS105 ++ PRE_first_tail_x15_r0_body.ciS105).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW105 : PRE_first_tail_x15_r0_body.cwS105.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo105.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI105 : PRE_first_tail_x15_r0_body.ciS105.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli105.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN105 : PRE_first_tail_x15_r0_body.cnS105.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF105 : PRE_first_tail_x15_r0_body.cln105.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh105 : PRE_first_tail_x15_r0_body.clo105.all (handleOK PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.P105.lo PRE_first_tail_x15_r0_body.cx0_105.mlx PRE_first_tail_x15_r0_body.cx1_105.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo105 : PRE_first_tail_x15_r0_body.clo105.map (fun h => PRE_first_tail_x15_r0_body.cx1_105.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa105.handle h)) = PRE_first_tail_x15_r0_body.clo105.map (fun h => (PRE_first_tail_x15_r0_body.cx0_105.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa105.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok105 : PRE_first_tail_x15_r0_body.clo105.all (objOK PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.P105.NL PRE_first_tail_x15_r0_body.cx0_105.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd105 : PRE_first_tail_x15_r0_body.cln105.all (nodeOKF PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.P105 PRE_first_tail_x15_r0_body.cx0_105.mlx PRE_first_tail_x15_r0_body.cx1_105.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp105 : ((PRE_first_tail_x15_r0_body.cln105.filter (fullB PRE_first_tail_x15_r0_body.P105))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_105.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa105.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln105.filter (fullB PRE_first_tail_x15_r0_body.P105))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_105.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa105.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI105 : incrB PRE_first_tail_x15_r0_body.kd105.nodeF (List.range' 17372 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK105 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.node).all (fun k => Nat.ble 17372 k && Nat.blt k 17378) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL105 : (PRE_first_tail_x15_r0_body.cln105.filter (Nat.ble PRE_first_tail_x15_r0_body.P105.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd105.nodeF i) && (Nat.blt i 17378 || Nat.ble PRE_first_tail_x15_r0_body.kd105.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord105 : (PRE_first_tail_x15_r0_body.cln105.filter (Nat.ble PRE_first_tail_x15_r0_body.P105.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd105.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd105.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd105.nodeF j) (PRE_first_tail_x15_r0_body.kd105.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow105 PRE_first_tail_x15_r0_body.cnn1105 PRE_first_tail_x15_r0_body.fnordI105 PRE_first_tail_x15_r0_body.fnordK105 PRE_first_tail_x15_r0_body.fnordL105
kernel_rfl PRE_first_tail_x15_r0_body.fi105 : PRE_first_tail_x15_r0_body.cli105.all (pnB PRE_first_tail_x15_r0_body.cx0_105.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii105 : PRE_first_tail_x15_r0_body.cli105.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_105.mlx.items.get (PRE_first_tail_x15_r0_body.kappa105.node k) = (PRE_first_tail_x15_r0_body.cx0_105.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa105.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot105 (clean : Conv.NClean (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P105.NL) (cl : SSt (· < 4587) PRE_first_tail_x15_r0_body.cx0_105.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P105 4587 PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.kd105 PRE_first_tail_x15_r0_body.khinv105 PRE_first_tail_x15_r0_body.kninv105 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx PRE_first_tail_x15_r0_body.cx0_105.mlx PRE_first_tail_x15_r0_body.cx1_105.mlx (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo105 PRE_first_tail_x15_r0_body.cln105 PRE_first_tail_x15_r0_body.cli105 PRE_first_tail_x15_r0_body.cwS105 PRE_first_tail_x15_r0_body.cnS105 PRE_first_tail_x15_r0_body.ciS105 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0105, PRE_first_tail_x15_r0_body.cnh1105, PRE_first_tail_x15_r0_body.cnn0105, PRE_first_tail_x15_r0_body.cnn1105, PRE_first_tail_x15_r0_body.cplo105, PRE_first_tail_x15_r0_body.ccnt105, PRE_first_tail_x15_r0_body.cnband105, PRE_first_tail_x15_r0_body.chbelow105, PRE_first_tail_x15_r0_body.chren105, PRE_first_tail_x15_r0_body.cband105, PRE_first_tail_x15_r0_body.cnh1pos105, PRE_first_tail_x15_r0_body.cnren105, PRE_first_tail_x15_r0_body.cnlow105, PRE_first_tail_x15_r0_body.cabs0a105, PRE_first_tail_x15_r0_body.cabs0b105, PRE_first_tail_x15_r0_body.ctok1105, PRE_first_tail_x15_r0_body.cpend105, PRE_first_tail_x15_r0_body.cerrh105, PRE_first_tail_x15_r0_body.cfiles105, PRE_first_tail_x15_r0_body.carch105, PRE_first_tail_x15_r0_body.csizes105, PRE_first_tail_x15_r0_body.cwired105, PRE_first_tail_x15_r0_body.cfix105, clean, PRE_first_tail_x15_r0_body.fcxn105, PRE_first_tail_x15_r0_body.fcnn105, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0105, PRE_first_tail_x15_r0_body.fnk105, PRE_first_tail_x15_r0_body.ckA105, PRE_first_tail_x15_r0_body.cobjsK105, PRE_first_tail_x15_r0_body.cnodesK105, PRE_first_tail_x15_r0_body.citemsK105, PRE_first_tail_x15_r0_body.f1A105, PRE_first_tail_x15_r0_body.f1O105, PRE_first_tail_x15_r0_body.f1N105, PRE_first_tail_x15_r0_body.f1I105, PRE_first_tail_x15_r0_body.fbd105, PRE_first_tail_x15_r0_body.fincW105, PRE_first_tail_x15_r0_body.fincI105, PRE_first_tail_x15_r0_body.fincN105, PRE_first_tail_x15_r0_body.flnF105, PRE_first_tail_x15_r0_body.fh105, PRE_first_tail_x15_r0_body.fo105, PRE_first_tail_x15_r0_body.fok105, PRE_first_tail_x15_r0_body.fnd105, PRE_first_tail_x15_r0_body.fp105, PRE_first_tail_x15_r0_body.fnord105, PRE_first_tail_x15_r0_body.fi105, PRE_first_tail_x15_r0_body.fii105⟩
theorem PRE_first_tail_x15_r0_body.cnshift105 (clean : Conv.NClean (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P105.NL) (cl : SSt (· < 4587) PRE_first_tail_x15_r0_body.cx0_105.mlx) : NShift PRE_first_tail_x15_r0_body.P105 4587 PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.cx0_105 PRE_first_tail_x15_r0_body.cx1_105 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot105 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost105 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0105 PRE_first_tail_x15_r0_body.ckn1105 PRE_first_tail_x15_r0_body.ckheap105 PRE_first_tail_x15_r0_body.ckpl105)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_105 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1022.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_105 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1022.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_105 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1022.ffi) = some PRE_first_tail_x15_r0_body.fxC_105
kernel_rfl PRE_first_tail_x15_r0_body.okrC_105 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1022.ffi) = some PRE_first_tail_x15_r0_body.krC_105
noncomputable def PRE_first_tail_x15_r0_body.fx0_105 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1024.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_105 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1024.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_105 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1024.ffi) = some PRE_first_tail_x15_r0_body.fx0_105
kernel_rfl PRE_first_tail_x15_r0_body.okr0_105 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1024.ffi) = some PRE_first_tail_x15_r0_body.kr0_105
noncomputable def PRE_first_tail_x15_r0_body.fx1_105 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1023.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_105 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1023.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_105 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1023.ffi) = some PRE_first_tail_x15_r0_body.fx1_105
kernel_rfl PRE_first_tail_x15_r0_body.okr1_105 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1023.ffi) = some PRE_first_tail_x15_r0_body.kr1_105
kernel_rfl PRE_first_tail_x15_r0_body.ff0105 : PRE_first_tail_x15_r0_body.fx0_105 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_105 (PRE_first_tail_x15_r0_body.clo105.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_105.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1105 : PRE_first_tail_x15_r0_body.fx1_105 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_105 (PRE_first_tail_x15_r0_body.cwS105.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_105.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck105 : freedLB PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.cx0_105.mlx PRE_first_tail_x15_r0_body.fx0_105 PRE_first_tail_x15_r0_body.fx1_105 PRE_first_tail_x15_r0_body.clo105 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0105 : PRE_first_tail_x15_r0_body.kr0_105.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_105.flags (PRE_first_tail_x15_r0_body.clo105.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_105.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0105 : PRE_first_tail_x15_r0_body.kr0_105.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_105.targs (PRE_first_tail_x15_r0_body.clo105.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_105.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1105 : PRE_first_tail_x15_r0_body.kr1_105.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_105.flags (PRE_first_tail_x15_r0_body.cwS105.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_105.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1105 : PRE_first_tail_x15_r0_body.kr1_105.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_105.targs (PRE_first_tail_x15_r0_body.cwS105.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_105.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck105 : krecLB PRE_first_tail_x15_r0_body.kappa105 4587 PRE_first_tail_x15_r0_body.cx0_105.mlx PRE_first_tail_x15_r0_body.kr0_105 PRE_first_tail_x15_r0_body.kr1_105 PRE_first_tail_x15_r0_body.clo105 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn105 : Nat.ble 4578 4587 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge105 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1023.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1024.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR105 : pendRegB PRE_first_tail_x15_r0_body.kappa105 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe105 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1023.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift105 (clean : Conv.NClean (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P105.NL) (cl : SSt (· < 4587) PRE_first_tail_x15_r0_body.cx0_105.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_105.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_105.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_105.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_105.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P105 4587 PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.s1024.ffi PRE_first_tail_x15_r0_body.s1023.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift105 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue105, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp105 t ht),
    PRE_first_tail_x15_r0_body.cbridge105,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1024.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1023.ffi) (PRE_first_tail_x15_r0_body.cfoot105 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_105 PRE_first_tail_x15_r0_body.ofx1_105 hobjC PRE_first_tail_x15_r0_body.ff0105 PRE_first_tail_x15_r0_body.ff1105 PRE_first_tail_x15_r0_body.ffck105,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1024.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1023.ffi) (PRE_first_tail_x15_r0_body.cfoot105 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_105 PRE_first_tail_x15_r0_body.okr1_105 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn105) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0105 PRE_first_tail_x15_r0_body.fkt0105 PRE_first_tail_x15_r0_body.fkf1105 PRE_first_tail_x15_r0_body.fkt1105 PRE_first_tail_x15_r0_body.fkck105,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0105 PRE_first_tail_x15_r0_body.cnh1105 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe105) PRE_first_tail_x15_r0_body.cpendR105⟩

end Host.Load.Run.Tpl
