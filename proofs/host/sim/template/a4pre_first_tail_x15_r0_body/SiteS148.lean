import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl148
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 148 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc148 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P148 : LoadP := PRE_first_tail_x15_r0_body.Pc148.raise 18225
kernel_rfl PRE_first_tail_x15_r0_body.craise148 : Nat.ble PRE_first_tail_x15_r0_body.Pc148.N0 18225 = true
theorem PRE_first_tail_x15_r0_body.raised148 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc148 PRE_first_tail_x15_r0_body.P148 :=
  .inr ⟨18225, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise148, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_148 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_148 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1434.ffi)
def PRE_first_tail_x15_r0_body.khinv148 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv148 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS148 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS148 : List Nat := List.range' 18225 0
def PRE_first_tail_x15_r0_body.ciS148 : List Nat := [] ++ List.range' 18225 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0148 : PRE_first_tail_x15_r0_body.kd148.nh0 = PRE_first_tail_x15_r0_body.cx0_148.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1148 : PRE_first_tail_x15_r0_body.kd148.nh1 = PRE_first_tail_x15_r0_body.cx1_148.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0148 : PRE_first_tail_x15_r0_body.kd148.nn0 = PRE_first_tail_x15_r0_body.cx0_148.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1148 : PRE_first_tail_x15_r0_body.kd148.nn1 = PRE_first_tail_x15_r0_body.cx1_148.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo148 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P148.lo && Nat.ble PRE_first_tail_x15_r0_body.P148.lo PRE_first_tail_x15_r0_body.cx0_148.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P148.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P148.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt148 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_148.mlx.next PRE_first_tail_x15_r0_body.cx1_148.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_148.mlx.nnext PRE_first_tail_x15_r0_body.cx1_148.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband148 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P148.NL && Nat.ble PRE_first_tail_x15_r0_body.P148.NL PRE_first_tail_x15_r0_body.P148.N0 && Nat.ble PRE_first_tail_x15_r0_body.P148.N0 PRE_first_tail_x15_r0_body.cx0_148.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow148 : PRE_first_tail_x15_r0_body.kd148.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren148 : checkRenG PRE_first_tail_x15_r0_body.kd148.hnd PRE_first_tail_x15_r0_body.khinv148 (phB PRE_first_tail_x15_r0_body.cx0_148.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband148 : PRE_first_tail_x15_r0_body.kd148.checkBand PRE_first_tail_x15_r0_body.P148.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos148 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd148.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren148 : checkRenG PRE_first_tail_x15_r0_body.kd148.node PRE_first_tail_x15_r0_body.kninv148 (pnB PRE_first_tail_x15_r0_body.cx0_148.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow148 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd148.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P148.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd148.nodeF j) PRE_first_tail_x15_r0_body.cx1_148.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a148 : PRE_first_tail_x15_r0_body.cx0_148.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b148 : PRE_first_tail_x15_r0_body.cx0_148.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1148 : PRE_first_tail_x15_r0_body.cx1_148.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend148 : PRE_first_tail_x15_r0_body.cx1_148.mlx.pending = PRE_first_tail_x15_r0_body.cx0_148.mlx.pending.map PRE_first_tail_x15_r0_body.kappa148.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh148 : PRE_first_tail_x15_r0_body.cx1_148.mlx.errh = PRE_first_tail_x15_r0_body.cx0_148.mlx.errh.map PRE_first_tail_x15_r0_body.kappa148.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles148 : PRE_first_tail_x15_r0_body.cx1_148.mlx.files = PRE_first_tail_x15_r0_body.cx0_148.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch148 : PRE_first_tail_x15_r0_body.cx1_148.mlx.arch = PRE_first_tail_x15_r0_body.cx0_148.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes148 : PRE_first_tail_x15_r0_body.cx1_148.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_148.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired148 : PRE_first_tail_x15_r0_body.cx1_148.mlx.wired = PRE_first_tail_x15_r0_body.cx0_148.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost148 : PRE_first_tail_x15_r0_body.cx1_148.host = PRE_first_tail_x15_r0_body.cx0_148.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd148`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0148 : PRE_first_tail_x15_r0_body.kd148.n0 = 2791215
kernel_rfl PRE_first_tail_x15_r0_body.ckn1148 : PRE_first_tail_x15_r0_body.kd148.n1 = 2791217
kernel_rfl PRE_first_tail_x15_r0_body.ckheap148 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd148.heap).all (fun x => Nat.ble 2791215 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl148 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd148.heap.get (2791215 + j) = nth? PRE_first_tail_x15_r0_body.pl148 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja148 : Nat.ble 2791215 2791215 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn148 : Nat.ble 6407 6407 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD148 : Nat.ble 2791215 PRE_first_tail_x15_r0_body.kd148.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn148 : Nat.ble 21121 PRE_first_tail_x15_r0_body.kd148.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn148 : Nat.ble 18225 PRE_first_tail_x15_r0_body.kd148.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb148 : Nat.ble 21121 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap148 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd148.heap).all (Nat.ble (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd148 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd148.hnd).all (Nat.ble (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode148 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd148.node).all (Nat.ble (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix148 : Conv.FixOld (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa148 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja148) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn148) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD148) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn148) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn148) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb148) PRE_first_tail_x15_r0_body.fheap148 PRE_first_tail_x15_r0_body.fhnd148 PRE_first_tail_x15_r0_body.fnode148
kernel_rfl PRE_first_tail_x15_r0_body.fcxn148 : (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn148 : (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0148 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_148.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_148.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk148 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd148.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A148 : PRE_first_tail_x15_r0_body.cx1_148.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS148.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_148.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O148 : PRE_first_tail_x15_r0_body.cx1_148.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS148.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_148.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N148 : PRE_first_tail_x15_r0_body.cx1_148.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS148.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_148.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I148 : PRE_first_tail_x15_r0_body.cx1_148.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS148.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_148.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd148 : (PRE_first_tail_x15_r0_body.clo148 ++ PRE_first_tail_x15_r0_body.cln148 ++ PRE_first_tail_x15_r0_body.cli148 ++ PRE_first_tail_x15_r0_body.cwS148 ++ PRE_first_tail_x15_r0_body.cnS148 ++ PRE_first_tail_x15_r0_body.ciS148).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW148 : PRE_first_tail_x15_r0_body.cwS148.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo148.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI148 : PRE_first_tail_x15_r0_body.ciS148.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli148.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN148 : PRE_first_tail_x15_r0_body.cnS148.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF148 : PRE_first_tail_x15_r0_body.cln148.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh148 : PRE_first_tail_x15_r0_body.clo148.all (handleOK PRE_first_tail_x15_r0_body.kappa148 PRE_first_tail_x15_r0_body.P148.lo PRE_first_tail_x15_r0_body.cx0_148.mlx PRE_first_tail_x15_r0_body.cx1_148.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo148 : PRE_first_tail_x15_r0_body.clo148.map (fun h => PRE_first_tail_x15_r0_body.cx1_148.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa148.handle h)) = PRE_first_tail_x15_r0_body.clo148.map (fun h => (PRE_first_tail_x15_r0_body.cx0_148.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa148.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok148 : PRE_first_tail_x15_r0_body.clo148.all (objOK PRE_first_tail_x15_r0_body.kappa148 PRE_first_tail_x15_r0_body.P148.NL PRE_first_tail_x15_r0_body.cx0_148.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd148 : PRE_first_tail_x15_r0_body.cln148.all (nodeOKF PRE_first_tail_x15_r0_body.kappa148 PRE_first_tail_x15_r0_body.P148 PRE_first_tail_x15_r0_body.cx0_148.mlx PRE_first_tail_x15_r0_body.cx1_148.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp148 : ((PRE_first_tail_x15_r0_body.cln148.filter (fullB PRE_first_tail_x15_r0_body.P148))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_148.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa148.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln148.filter (fullB PRE_first_tail_x15_r0_body.P148))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_148.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa148.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI148 : incrB PRE_first_tail_x15_r0_body.kd148.nodeF (List.range' 18225 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK148 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd148.node).all (fun k => Nat.ble 18225 k && Nat.blt k 18225) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL148 : (PRE_first_tail_x15_r0_body.cln148.filter (Nat.ble PRE_first_tail_x15_r0_body.P148.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd148.nodeF i) && (Nat.blt i 18225 || Nat.ble PRE_first_tail_x15_r0_body.kd148.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord148 : (PRE_first_tail_x15_r0_body.cln148.filter (Nat.ble PRE_first_tail_x15_r0_body.P148.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd148.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd148.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd148.nodeF j) (PRE_first_tail_x15_r0_body.kd148.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow148 PRE_first_tail_x15_r0_body.cnn1148 PRE_first_tail_x15_r0_body.fnordI148 PRE_first_tail_x15_r0_body.fnordK148 PRE_first_tail_x15_r0_body.fnordL148
kernel_rfl PRE_first_tail_x15_r0_body.fi148 : PRE_first_tail_x15_r0_body.cli148.all (pnB PRE_first_tail_x15_r0_body.cx0_148.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii148 : PRE_first_tail_x15_r0_body.cli148.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_148.mlx.items.get (PRE_first_tail_x15_r0_body.kappa148.node k) = (PRE_first_tail_x15_r0_body.cx0_148.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa148.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot148 (clean : Conv.NClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P148.NL) (cl : SSt (· < 6407) PRE_first_tail_x15_r0_body.cx0_148.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P148 6407 PRE_first_tail_x15_r0_body.kappa148 PRE_first_tail_x15_r0_body.kd148 PRE_first_tail_x15_r0_body.khinv148 PRE_first_tail_x15_r0_body.kninv148 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx PRE_first_tail_x15_r0_body.cx0_148.mlx PRE_first_tail_x15_r0_body.cx1_148.mlx (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo148 PRE_first_tail_x15_r0_body.cln148 PRE_first_tail_x15_r0_body.cli148 PRE_first_tail_x15_r0_body.cwS148 PRE_first_tail_x15_r0_body.cnS148 PRE_first_tail_x15_r0_body.ciS148 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0148, PRE_first_tail_x15_r0_body.cnh1148, PRE_first_tail_x15_r0_body.cnn0148, PRE_first_tail_x15_r0_body.cnn1148, PRE_first_tail_x15_r0_body.cplo148, PRE_first_tail_x15_r0_body.ccnt148, PRE_first_tail_x15_r0_body.cnband148, PRE_first_tail_x15_r0_body.chbelow148, PRE_first_tail_x15_r0_body.chren148, PRE_first_tail_x15_r0_body.cband148, PRE_first_tail_x15_r0_body.cnh1pos148, PRE_first_tail_x15_r0_body.cnren148, PRE_first_tail_x15_r0_body.cnlow148, PRE_first_tail_x15_r0_body.cabs0a148, PRE_first_tail_x15_r0_body.cabs0b148, PRE_first_tail_x15_r0_body.ctok1148, PRE_first_tail_x15_r0_body.cpend148, PRE_first_tail_x15_r0_body.cerrh148, PRE_first_tail_x15_r0_body.cfiles148, PRE_first_tail_x15_r0_body.carch148, PRE_first_tail_x15_r0_body.csizes148, PRE_first_tail_x15_r0_body.cwired148, PRE_first_tail_x15_r0_body.cfix148, clean, PRE_first_tail_x15_r0_body.fcxn148, PRE_first_tail_x15_r0_body.fcnn148, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0148, PRE_first_tail_x15_r0_body.fnk148, PRE_first_tail_x15_r0_body.ckA148, PRE_first_tail_x15_r0_body.cobjsK148, PRE_first_tail_x15_r0_body.cnodesK148, PRE_first_tail_x15_r0_body.citemsK148, PRE_first_tail_x15_r0_body.f1A148, PRE_first_tail_x15_r0_body.f1O148, PRE_first_tail_x15_r0_body.f1N148, PRE_first_tail_x15_r0_body.f1I148, PRE_first_tail_x15_r0_body.fbd148, PRE_first_tail_x15_r0_body.fincW148, PRE_first_tail_x15_r0_body.fincI148, PRE_first_tail_x15_r0_body.fincN148, PRE_first_tail_x15_r0_body.flnF148, PRE_first_tail_x15_r0_body.fh148, PRE_first_tail_x15_r0_body.fo148, PRE_first_tail_x15_r0_body.fok148, PRE_first_tail_x15_r0_body.fnd148, PRE_first_tail_x15_r0_body.fp148, PRE_first_tail_x15_r0_body.fnord148, PRE_first_tail_x15_r0_body.fi148, PRE_first_tail_x15_r0_body.fii148⟩
theorem PRE_first_tail_x15_r0_body.cnshift148 (clean : Conv.NClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P148.NL) (cl : SSt (· < 6407) PRE_first_tail_x15_r0_body.cx0_148.mlx) : NShift PRE_first_tail_x15_r0_body.P148 6407 PRE_first_tail_x15_r0_body.kappa148 PRE_first_tail_x15_r0_body.cx0_148 PRE_first_tail_x15_r0_body.cx1_148 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot148 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost148 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0148 PRE_first_tail_x15_r0_body.ckn1148 PRE_first_tail_x15_r0_body.ckheap148 PRE_first_tail_x15_r0_body.ckpl148)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_148 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1433.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_148 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1433.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_148 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1433.ffi) = some PRE_first_tail_x15_r0_body.fxC_148
kernel_rfl PRE_first_tail_x15_r0_body.okrC_148 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1433.ffi) = some PRE_first_tail_x15_r0_body.krC_148
noncomputable def PRE_first_tail_x15_r0_body.fx0_148 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1435.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_148 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1435.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_148 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1435.ffi) = some PRE_first_tail_x15_r0_body.fx0_148
kernel_rfl PRE_first_tail_x15_r0_body.okr0_148 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1435.ffi) = some PRE_first_tail_x15_r0_body.kr0_148
noncomputable def PRE_first_tail_x15_r0_body.fx1_148 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1434.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_148 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1434.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_148 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1434.ffi) = some PRE_first_tail_x15_r0_body.fx1_148
kernel_rfl PRE_first_tail_x15_r0_body.okr1_148 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1434.ffi) = some PRE_first_tail_x15_r0_body.kr1_148
kernel_rfl PRE_first_tail_x15_r0_body.ff0148 : PRE_first_tail_x15_r0_body.fx0_148 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_148 (PRE_first_tail_x15_r0_body.clo148.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_148.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1148 : PRE_first_tail_x15_r0_body.fx1_148 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_148 (PRE_first_tail_x15_r0_body.cwS148.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_148.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck148 : freedLB PRE_first_tail_x15_r0_body.kappa148 PRE_first_tail_x15_r0_body.cx0_148.mlx PRE_first_tail_x15_r0_body.fx0_148 PRE_first_tail_x15_r0_body.fx1_148 PRE_first_tail_x15_r0_body.clo148 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0148 : PRE_first_tail_x15_r0_body.kr0_148.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_148.flags (PRE_first_tail_x15_r0_body.clo148.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_148.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0148 : PRE_first_tail_x15_r0_body.kr0_148.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_148.targs (PRE_first_tail_x15_r0_body.clo148.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_148.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1148 : PRE_first_tail_x15_r0_body.kr1_148.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_148.flags (PRE_first_tail_x15_r0_body.cwS148.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_148.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1148 : PRE_first_tail_x15_r0_body.kr1_148.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_148.targs (PRE_first_tail_x15_r0_body.cwS148.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_148.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck148 : krecLB PRE_first_tail_x15_r0_body.kappa148 6407 PRE_first_tail_x15_r0_body.cx0_148.mlx PRE_first_tail_x15_r0_body.kr0_148 PRE_first_tail_x15_r0_body.kr1_148 PRE_first_tail_x15_r0_body.clo148 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn148 : Nat.ble 6407 6407 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge148 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1434.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1435.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR148 : pendRegB PRE_first_tail_x15_r0_body.kappa148 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe148 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1434.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift148 (clean : Conv.NClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P148.NL) (cl : SSt (· < 6407) PRE_first_tail_x15_r0_body.cx0_148.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_148.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_148.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_148.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_148.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P148 6407 PRE_first_tail_x15_r0_body.kappa148 PRE_first_tail_x15_r0_body.s1435.ffi PRE_first_tail_x15_r0_body.s1434.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift148 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue148, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp148 t ht),
    PRE_first_tail_x15_r0_body.cbridge148,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1435.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1434.ffi) (PRE_first_tail_x15_r0_body.cfoot148 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_148 PRE_first_tail_x15_r0_body.ofx1_148 hobjC PRE_first_tail_x15_r0_body.ff0148 PRE_first_tail_x15_r0_body.ff1148 PRE_first_tail_x15_r0_body.ffck148,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1435.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1434.ffi) (PRE_first_tail_x15_r0_body.cfoot148 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_148 PRE_first_tail_x15_r0_body.okr1_148 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn148) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0148 PRE_first_tail_x15_r0_body.fkt0148 PRE_first_tail_x15_r0_body.fkf1148 PRE_first_tail_x15_r0_body.fkt1148 PRE_first_tail_x15_r0_body.fkck148,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0148 PRE_first_tail_x15_r0_body.cnh1148 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe148) PRE_first_tail_x15_r0_body.cpendR148⟩

end Host.Load.Run.Tpl
