import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl158
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 158 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc158 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P158 : LoadP := PRE_first_tail_x15_r0_body.Pc158.raise 18403
kernel_rfl PRE_first_tail_x15_r0_body.craise158 : Nat.ble PRE_first_tail_x15_r0_body.Pc158.N0 18403 = true
theorem PRE_first_tail_x15_r0_body.raised158 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc158 PRE_first_tail_x15_r0_body.P158 :=
  .inr ⟨18403, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise158, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_158 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1392.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_158 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1391.ffi)
def PRE_first_tail_x15_r0_body.khinv158 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv158 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS158 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS158 : List Nat := List.range' 18403 0
def PRE_first_tail_x15_r0_body.ciS158 : List Nat := [] ++ List.range' 18403 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0158 : PRE_first_tail_x15_r0_body.kd158.nh0 = PRE_first_tail_x15_r0_body.cx0_158.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1158 : PRE_first_tail_x15_r0_body.kd158.nh1 = PRE_first_tail_x15_r0_body.cx1_158.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0158 : PRE_first_tail_x15_r0_body.kd158.nn0 = PRE_first_tail_x15_r0_body.cx0_158.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1158 : PRE_first_tail_x15_r0_body.kd158.nn1 = PRE_first_tail_x15_r0_body.cx1_158.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo158 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P158.lo && Nat.ble PRE_first_tail_x15_r0_body.P158.lo PRE_first_tail_x15_r0_body.cx0_158.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P158.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P158.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt158 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_158.mlx.next PRE_first_tail_x15_r0_body.cx1_158.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_158.mlx.nnext PRE_first_tail_x15_r0_body.cx1_158.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband158 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P158.NL && Nat.ble PRE_first_tail_x15_r0_body.P158.NL PRE_first_tail_x15_r0_body.P158.N0 && Nat.ble PRE_first_tail_x15_r0_body.P158.N0 PRE_first_tail_x15_r0_body.cx0_158.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow158 : PRE_first_tail_x15_r0_body.kd158.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren158 : checkRenG PRE_first_tail_x15_r0_body.kd158.hnd PRE_first_tail_x15_r0_body.khinv158 (phB PRE_first_tail_x15_r0_body.cx0_158.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband158 : PRE_first_tail_x15_r0_body.kd158.checkBand PRE_first_tail_x15_r0_body.P158.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos158 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd158.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren158 : checkRenG PRE_first_tail_x15_r0_body.kd158.node PRE_first_tail_x15_r0_body.kninv158 (pnB PRE_first_tail_x15_r0_body.cx0_158.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow158 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd158.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P158.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd158.nodeF j) PRE_first_tail_x15_r0_body.cx1_158.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a158 : PRE_first_tail_x15_r0_body.cx0_158.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b158 : PRE_first_tail_x15_r0_body.cx0_158.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1158 : PRE_first_tail_x15_r0_body.cx1_158.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend158 : PRE_first_tail_x15_r0_body.cx1_158.mlx.pending = PRE_first_tail_x15_r0_body.cx0_158.mlx.pending.map PRE_first_tail_x15_r0_body.kappa158.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh158 : PRE_first_tail_x15_r0_body.cx1_158.mlx.errh = PRE_first_tail_x15_r0_body.cx0_158.mlx.errh.map PRE_first_tail_x15_r0_body.kappa158.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles158 : PRE_first_tail_x15_r0_body.cx1_158.mlx.files = PRE_first_tail_x15_r0_body.cx0_158.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch158 : PRE_first_tail_x15_r0_body.cx1_158.mlx.arch = PRE_first_tail_x15_r0_body.cx0_158.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes158 : PRE_first_tail_x15_r0_body.cx1_158.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_158.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired158 : PRE_first_tail_x15_r0_body.cx1_158.mlx.wired = PRE_first_tail_x15_r0_body.cx0_158.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost158 : PRE_first_tail_x15_r0_body.cx1_158.host = PRE_first_tail_x15_r0_body.cx0_158.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd158`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0158 : PRE_first_tail_x15_r0_body.kd158.n0 = 2798664
kernel_rfl PRE_first_tail_x15_r0_body.ckn1158 : PRE_first_tail_x15_r0_body.kd158.n1 = 2798674
kernel_rfl PRE_first_tail_x15_r0_body.ckheap158 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd158.heap).all (fun x => Nat.ble 2798663 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl158 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd158.heap.get (2798663 + j) = nth? PRE_first_tail_x15_r0_body.pl158 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja158 : Nat.ble 2798663 2798663 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn158 : Nat.ble 6808 6808 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD158 : Nat.ble 2798663 PRE_first_tail_x15_r0_body.kd158.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn158 : Nat.ble 21307 PRE_first_tail_x15_r0_body.kd158.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn158 : Nat.ble 18403 PRE_first_tail_x15_r0_body.kd158.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb158 : Nat.ble 21307 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap158 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd158.heap).all (Nat.ble (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd158 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd158.hnd).all (Nat.ble (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode158 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd158.node).all (Nat.ble (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix158 : Conv.FixOld (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa158 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja158) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn158) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD158) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn158) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn158) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb158) PRE_first_tail_x15_r0_body.fheap158 PRE_first_tail_x15_r0_body.fhnd158 PRE_first_tail_x15_r0_body.fnode158
kernel_rfl PRE_first_tail_x15_r0_body.fcxn158 : (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn158 : (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0158 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_158.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_158.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk158 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd158.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A158 : PRE_first_tail_x15_r0_body.cx1_158.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS158.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_158.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O158 : PRE_first_tail_x15_r0_body.cx1_158.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS158.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_158.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N158 : PRE_first_tail_x15_r0_body.cx1_158.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS158.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_158.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I158 : PRE_first_tail_x15_r0_body.cx1_158.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS158.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_158.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd158 : (PRE_first_tail_x15_r0_body.clo158 ++ PRE_first_tail_x15_r0_body.cln158 ++ PRE_first_tail_x15_r0_body.cli158 ++ PRE_first_tail_x15_r0_body.cwS158 ++ PRE_first_tail_x15_r0_body.cnS158 ++ PRE_first_tail_x15_r0_body.ciS158).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW158 : PRE_first_tail_x15_r0_body.cwS158.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo158.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI158 : PRE_first_tail_x15_r0_body.ciS158.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli158.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN158 : PRE_first_tail_x15_r0_body.cnS158.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF158 : PRE_first_tail_x15_r0_body.cln158.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh158 : PRE_first_tail_x15_r0_body.clo158.all (handleOK PRE_first_tail_x15_r0_body.kappa158 PRE_first_tail_x15_r0_body.P158.lo PRE_first_tail_x15_r0_body.cx0_158.mlx PRE_first_tail_x15_r0_body.cx1_158.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo158 : PRE_first_tail_x15_r0_body.clo158.map (fun h => PRE_first_tail_x15_r0_body.cx1_158.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa158.handle h)) = PRE_first_tail_x15_r0_body.clo158.map (fun h => (PRE_first_tail_x15_r0_body.cx0_158.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa158.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok158 : PRE_first_tail_x15_r0_body.clo158.all (objOK PRE_first_tail_x15_r0_body.kappa158 PRE_first_tail_x15_r0_body.P158.NL PRE_first_tail_x15_r0_body.cx0_158.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd158 : PRE_first_tail_x15_r0_body.cln158.all (nodeOKF PRE_first_tail_x15_r0_body.kappa158 PRE_first_tail_x15_r0_body.P158 PRE_first_tail_x15_r0_body.cx0_158.mlx PRE_first_tail_x15_r0_body.cx1_158.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp158 : ((PRE_first_tail_x15_r0_body.cln158.filter (fullB PRE_first_tail_x15_r0_body.P158))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_158.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa158.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln158.filter (fullB PRE_first_tail_x15_r0_body.P158))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_158.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa158.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI158 : incrB PRE_first_tail_x15_r0_body.kd158.nodeF (List.range' 18403 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK158 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd158.node).all (fun k => Nat.ble 18403 k && Nat.blt k 18403) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL158 : (PRE_first_tail_x15_r0_body.cln158.filter (Nat.ble PRE_first_tail_x15_r0_body.P158.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd158.nodeF i) && (Nat.blt i 18403 || Nat.ble PRE_first_tail_x15_r0_body.kd158.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord158 : (PRE_first_tail_x15_r0_body.cln158.filter (Nat.ble PRE_first_tail_x15_r0_body.P158.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd158.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd158.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd158.nodeF j) (PRE_first_tail_x15_r0_body.kd158.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow158 PRE_first_tail_x15_r0_body.cnn1158 PRE_first_tail_x15_r0_body.fnordI158 PRE_first_tail_x15_r0_body.fnordK158 PRE_first_tail_x15_r0_body.fnordL158
kernel_rfl PRE_first_tail_x15_r0_body.fi158 : PRE_first_tail_x15_r0_body.cli158.all (pnB PRE_first_tail_x15_r0_body.cx0_158.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii158 : PRE_first_tail_x15_r0_body.cli158.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_158.mlx.items.get (PRE_first_tail_x15_r0_body.kappa158.node k) = (PRE_first_tail_x15_r0_body.cx0_158.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa158.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot158 (clean : Conv.NClean (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P158.NL) (cl : SSt (· < 6808) PRE_first_tail_x15_r0_body.cx0_158.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P158 6808 PRE_first_tail_x15_r0_body.kappa158 PRE_first_tail_x15_r0_body.kd158 PRE_first_tail_x15_r0_body.khinv158 PRE_first_tail_x15_r0_body.kninv158 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx PRE_first_tail_x15_r0_body.cx0_158.mlx PRE_first_tail_x15_r0_body.cx1_158.mlx (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo158 PRE_first_tail_x15_r0_body.cln158 PRE_first_tail_x15_r0_body.cli158 PRE_first_tail_x15_r0_body.cwS158 PRE_first_tail_x15_r0_body.cnS158 PRE_first_tail_x15_r0_body.ciS158 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0158, PRE_first_tail_x15_r0_body.cnh1158, PRE_first_tail_x15_r0_body.cnn0158, PRE_first_tail_x15_r0_body.cnn1158, PRE_first_tail_x15_r0_body.cplo158, PRE_first_tail_x15_r0_body.ccnt158, PRE_first_tail_x15_r0_body.cnband158, PRE_first_tail_x15_r0_body.chbelow158, PRE_first_tail_x15_r0_body.chren158, PRE_first_tail_x15_r0_body.cband158, PRE_first_tail_x15_r0_body.cnh1pos158, PRE_first_tail_x15_r0_body.cnren158, PRE_first_tail_x15_r0_body.cnlow158, PRE_first_tail_x15_r0_body.cabs0a158, PRE_first_tail_x15_r0_body.cabs0b158, PRE_first_tail_x15_r0_body.ctok1158, PRE_first_tail_x15_r0_body.cpend158, PRE_first_tail_x15_r0_body.cerrh158, PRE_first_tail_x15_r0_body.cfiles158, PRE_first_tail_x15_r0_body.carch158, PRE_first_tail_x15_r0_body.csizes158, PRE_first_tail_x15_r0_body.cwired158, PRE_first_tail_x15_r0_body.cfix158, clean, PRE_first_tail_x15_r0_body.fcxn158, PRE_first_tail_x15_r0_body.fcnn158, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0158, PRE_first_tail_x15_r0_body.fnk158, PRE_first_tail_x15_r0_body.ckA158, PRE_first_tail_x15_r0_body.cobjsK158, PRE_first_tail_x15_r0_body.cnodesK158, PRE_first_tail_x15_r0_body.citemsK158, PRE_first_tail_x15_r0_body.f1A158, PRE_first_tail_x15_r0_body.f1O158, PRE_first_tail_x15_r0_body.f1N158, PRE_first_tail_x15_r0_body.f1I158, PRE_first_tail_x15_r0_body.fbd158, PRE_first_tail_x15_r0_body.fincW158, PRE_first_tail_x15_r0_body.fincI158, PRE_first_tail_x15_r0_body.fincN158, PRE_first_tail_x15_r0_body.flnF158, PRE_first_tail_x15_r0_body.fh158, PRE_first_tail_x15_r0_body.fo158, PRE_first_tail_x15_r0_body.fok158, PRE_first_tail_x15_r0_body.fnd158, PRE_first_tail_x15_r0_body.fp158, PRE_first_tail_x15_r0_body.fnord158, PRE_first_tail_x15_r0_body.fi158, PRE_first_tail_x15_r0_body.fii158⟩
theorem PRE_first_tail_x15_r0_body.cnshift158 (clean : Conv.NClean (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P158.NL) (cl : SSt (· < 6808) PRE_first_tail_x15_r0_body.cx0_158.mlx) : NShift PRE_first_tail_x15_r0_body.P158 6808 PRE_first_tail_x15_r0_body.kappa158 PRE_first_tail_x15_r0_body.cx0_158 PRE_first_tail_x15_r0_body.cx1_158 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot158 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost158 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0158 PRE_first_tail_x15_r0_body.ckn1158 PRE_first_tail_x15_r0_body.ckheap158 PRE_first_tail_x15_r0_body.ckpl158)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_158 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1390.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_158 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1390.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_158 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1390.ffi) = some PRE_first_tail_x15_r0_body.fxC_158
kernel_rfl PRE_first_tail_x15_r0_body.okrC_158 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1390.ffi) = some PRE_first_tail_x15_r0_body.krC_158
noncomputable def PRE_first_tail_x15_r0_body.fx0_158 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1392.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_158 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1392.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_158 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1392.ffi) = some PRE_first_tail_x15_r0_body.fx0_158
kernel_rfl PRE_first_tail_x15_r0_body.okr0_158 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1392.ffi) = some PRE_first_tail_x15_r0_body.kr0_158
noncomputable def PRE_first_tail_x15_r0_body.fx1_158 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1391.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_158 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1391.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_158 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1391.ffi) = some PRE_first_tail_x15_r0_body.fx1_158
kernel_rfl PRE_first_tail_x15_r0_body.okr1_158 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1391.ffi) = some PRE_first_tail_x15_r0_body.kr1_158
kernel_rfl PRE_first_tail_x15_r0_body.ff0158 : PRE_first_tail_x15_r0_body.fx0_158 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_158 (PRE_first_tail_x15_r0_body.clo158.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_158.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1158 : PRE_first_tail_x15_r0_body.fx1_158 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_158 (PRE_first_tail_x15_r0_body.cwS158.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_158.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck158 : freedLB PRE_first_tail_x15_r0_body.kappa158 PRE_first_tail_x15_r0_body.cx0_158.mlx PRE_first_tail_x15_r0_body.fx0_158 PRE_first_tail_x15_r0_body.fx1_158 PRE_first_tail_x15_r0_body.clo158 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0158 : PRE_first_tail_x15_r0_body.kr0_158.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_158.flags (PRE_first_tail_x15_r0_body.clo158.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_158.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0158 : PRE_first_tail_x15_r0_body.kr0_158.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_158.targs (PRE_first_tail_x15_r0_body.clo158.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_158.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1158 : PRE_first_tail_x15_r0_body.kr1_158.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_158.flags (PRE_first_tail_x15_r0_body.cwS158.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_158.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1158 : PRE_first_tail_x15_r0_body.kr1_158.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_158.targs (PRE_first_tail_x15_r0_body.cwS158.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_158.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck158 : krecLB PRE_first_tail_x15_r0_body.kappa158 6808 PRE_first_tail_x15_r0_body.cx0_158.mlx PRE_first_tail_x15_r0_body.kr0_158 PRE_first_tail_x15_r0_body.kr1_158 PRE_first_tail_x15_r0_body.clo158 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn158 : Nat.ble 6808 6808 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge158 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1391.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1392.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR158 : pendRegB PRE_first_tail_x15_r0_body.kappa158 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1392.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe158 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1392.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1391.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift158 (clean : Conv.NClean (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P158.NL) (cl : SSt (· < 6808) PRE_first_tail_x15_r0_body.cx0_158.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_158.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_158.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_158.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1390.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_158.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P158 6808 PRE_first_tail_x15_r0_body.kappa158 PRE_first_tail_x15_r0_body.s1392.ffi PRE_first_tail_x15_r0_body.s1391.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift158 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue158, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp158 t ht),
    PRE_first_tail_x15_r0_body.cbridge158,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1392.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1391.ffi) (PRE_first_tail_x15_r0_body.cfoot158 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_158 PRE_first_tail_x15_r0_body.ofx1_158 hobjC PRE_first_tail_x15_r0_body.ff0158 PRE_first_tail_x15_r0_body.ff1158 PRE_first_tail_x15_r0_body.ffck158,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1392.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1391.ffi) (PRE_first_tail_x15_r0_body.cfoot158 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_158 PRE_first_tail_x15_r0_body.okr1_158 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn158) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0158 PRE_first_tail_x15_r0_body.fkt0158 PRE_first_tail_x15_r0_body.fkf1158 PRE_first_tail_x15_r0_body.fkt1158 PRE_first_tail_x15_r0_body.fkck158,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0158 PRE_first_tail_x15_r0_body.cnh1158 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe158) PRE_first_tail_x15_r0_body.cpendR158⟩

end Host.Load.Run.Tpl
