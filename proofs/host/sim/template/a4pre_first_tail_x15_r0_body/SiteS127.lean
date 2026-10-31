import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl127
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 127 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc127 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P127 : LoadP := PRE_first_tail_x15_r0_body.Pc127.raise 17814
kernel_rfl PRE_first_tail_x15_r0_body.craise127 : Nat.ble PRE_first_tail_x15_r0_body.Pc127.N0 17814 = true
theorem PRE_first_tail_x15_r0_body.raised127 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc127 PRE_first_tail_x15_r0_body.P127 :=
  .inr ⟨17814, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise127, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_127 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_127 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1233.ffi)
def PRE_first_tail_x15_r0_body.khinv127 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv127 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS127 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS127 : List Nat := List.range' 17814 0
def PRE_first_tail_x15_r0_body.ciS127 : List Nat := [] ++ List.range' 17814 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0127 : PRE_first_tail_x15_r0_body.kd127.nh0 = PRE_first_tail_x15_r0_body.cx0_127.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1127 : PRE_first_tail_x15_r0_body.kd127.nh1 = PRE_first_tail_x15_r0_body.cx1_127.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0127 : PRE_first_tail_x15_r0_body.kd127.nn0 = PRE_first_tail_x15_r0_body.cx0_127.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1127 : PRE_first_tail_x15_r0_body.kd127.nn1 = PRE_first_tail_x15_r0_body.cx1_127.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo127 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P127.lo && Nat.ble PRE_first_tail_x15_r0_body.P127.lo PRE_first_tail_x15_r0_body.cx0_127.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P127.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P127.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt127 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_127.mlx.next PRE_first_tail_x15_r0_body.cx1_127.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_127.mlx.nnext PRE_first_tail_x15_r0_body.cx1_127.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband127 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P127.NL && Nat.ble PRE_first_tail_x15_r0_body.P127.NL PRE_first_tail_x15_r0_body.P127.N0 && Nat.ble PRE_first_tail_x15_r0_body.P127.N0 PRE_first_tail_x15_r0_body.cx0_127.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow127 : PRE_first_tail_x15_r0_body.kd127.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren127 : checkRenG PRE_first_tail_x15_r0_body.kd127.hnd PRE_first_tail_x15_r0_body.khinv127 (phB PRE_first_tail_x15_r0_body.cx0_127.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband127 : PRE_first_tail_x15_r0_body.kd127.checkBand PRE_first_tail_x15_r0_body.P127.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos127 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd127.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren127 : checkRenG PRE_first_tail_x15_r0_body.kd127.node PRE_first_tail_x15_r0_body.kninv127 (pnB PRE_first_tail_x15_r0_body.cx0_127.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P127.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd127.nodeF j) PRE_first_tail_x15_r0_body.cx1_127.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a127 : PRE_first_tail_x15_r0_body.cx0_127.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b127 : PRE_first_tail_x15_r0_body.cx0_127.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.pending = PRE_first_tail_x15_r0_body.cx0_127.mlx.pending.map PRE_first_tail_x15_r0_body.kappa127.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.errh = PRE_first_tail_x15_r0_body.cx0_127.mlx.errh.map PRE_first_tail_x15_r0_body.kappa127.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.files = PRE_first_tail_x15_r0_body.cx0_127.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.arch = PRE_first_tail_x15_r0_body.cx0_127.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_127.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.wired = PRE_first_tail_x15_r0_body.cx0_127.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost127 : PRE_first_tail_x15_r0_body.cx1_127.host = PRE_first_tail_x15_r0_body.cx0_127.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd127`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0127 : PRE_first_tail_x15_r0_body.kd127.n0 = 2774631
kernel_rfl PRE_first_tail_x15_r0_body.ckn1127 : PRE_first_tail_x15_r0_body.kd127.n1 = 2774633
kernel_rfl PRE_first_tail_x15_r0_body.ckheap127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.heap).all (fun x => Nat.ble 2774631 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl127 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd127.heap.get (2774631 + j) = nth? PRE_first_tail_x15_r0_body.pl127 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja127 : Nat.ble 2774631 2774631 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn127 : Nat.ble 5510 5510 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD127 : Nat.ble 2774631 PRE_first_tail_x15_r0_body.kd127.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn127 : Nat.ble 20706 PRE_first_tail_x15_r0_body.kd127.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn127 : Nat.ble 17814 PRE_first_tail_x15_r0_body.kd127.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb127 : Nat.ble 20706 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.heap).all (Nat.ble (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.hnd).all (Nat.ble (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.node).all (Nat.ble (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix127 : Conv.FixOld (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa127 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja127) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn127) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD127) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn127) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn127) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb127) PRE_first_tail_x15_r0_body.fheap127 PRE_first_tail_x15_r0_body.fhnd127 PRE_first_tail_x15_r0_body.fnode127
kernel_rfl PRE_first_tail_x15_r0_body.fcxn127 : (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn127 : (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0127 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_127.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_127.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS127.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_127.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS127.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_127.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS127.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_127.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS127.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_127.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd127 : (PRE_first_tail_x15_r0_body.clo127 ++ PRE_first_tail_x15_r0_body.cln127 ++ PRE_first_tail_x15_r0_body.cli127 ++ PRE_first_tail_x15_r0_body.cwS127 ++ PRE_first_tail_x15_r0_body.cnS127 ++ PRE_first_tail_x15_r0_body.ciS127).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW127 : PRE_first_tail_x15_r0_body.cwS127.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo127.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI127 : PRE_first_tail_x15_r0_body.ciS127.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli127.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN127 : PRE_first_tail_x15_r0_body.cnS127.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF127 : PRE_first_tail_x15_r0_body.cln127.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh127 : PRE_first_tail_x15_r0_body.clo127.all (handleOK PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.P127.lo PRE_first_tail_x15_r0_body.cx0_127.mlx PRE_first_tail_x15_r0_body.cx1_127.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo127 : PRE_first_tail_x15_r0_body.clo127.map (fun h => PRE_first_tail_x15_r0_body.cx1_127.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa127.handle h)) = PRE_first_tail_x15_r0_body.clo127.map (fun h => (PRE_first_tail_x15_r0_body.cx0_127.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa127.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok127 : PRE_first_tail_x15_r0_body.clo127.all (objOK PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.P127.NL PRE_first_tail_x15_r0_body.cx0_127.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd127 : PRE_first_tail_x15_r0_body.cln127.all (nodeOKF PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.P127 PRE_first_tail_x15_r0_body.cx0_127.mlx PRE_first_tail_x15_r0_body.cx1_127.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp127 : ((PRE_first_tail_x15_r0_body.cln127.filter (fullB PRE_first_tail_x15_r0_body.P127))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_127.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa127.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln127.filter (fullB PRE_first_tail_x15_r0_body.P127))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_127.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa127.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI127 : incrB PRE_first_tail_x15_r0_body.kd127.nodeF (List.range' 17814 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.node).all (fun k => Nat.ble 17814 k && Nat.blt k 17814) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL127 : (PRE_first_tail_x15_r0_body.cln127.filter (Nat.ble PRE_first_tail_x15_r0_body.P127.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd127.nodeF i) && (Nat.blt i 17814 || Nat.ble PRE_first_tail_x15_r0_body.kd127.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord127 : (PRE_first_tail_x15_r0_body.cln127.filter (Nat.ble PRE_first_tail_x15_r0_body.P127.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd127.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd127.nodeF j) (PRE_first_tail_x15_r0_body.kd127.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow127 PRE_first_tail_x15_r0_body.cnn1127 PRE_first_tail_x15_r0_body.fnordI127 PRE_first_tail_x15_r0_body.fnordK127 PRE_first_tail_x15_r0_body.fnordL127
kernel_rfl PRE_first_tail_x15_r0_body.fi127 : PRE_first_tail_x15_r0_body.cli127.all (pnB PRE_first_tail_x15_r0_body.cx0_127.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii127 : PRE_first_tail_x15_r0_body.cli127.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_127.mlx.items.get (PRE_first_tail_x15_r0_body.kappa127.node k) = (PRE_first_tail_x15_r0_body.cx0_127.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa127.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot127 (clean : Conv.NClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P127.NL) (cl : SSt (· < 5510) PRE_first_tail_x15_r0_body.cx0_127.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P127 5510 PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.kd127 PRE_first_tail_x15_r0_body.khinv127 PRE_first_tail_x15_r0_body.kninv127 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx PRE_first_tail_x15_r0_body.cx0_127.mlx PRE_first_tail_x15_r0_body.cx1_127.mlx (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo127 PRE_first_tail_x15_r0_body.cln127 PRE_first_tail_x15_r0_body.cli127 PRE_first_tail_x15_r0_body.cwS127 PRE_first_tail_x15_r0_body.cnS127 PRE_first_tail_x15_r0_body.ciS127 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0127, PRE_first_tail_x15_r0_body.cnh1127, PRE_first_tail_x15_r0_body.cnn0127, PRE_first_tail_x15_r0_body.cnn1127, PRE_first_tail_x15_r0_body.cplo127, PRE_first_tail_x15_r0_body.ccnt127, PRE_first_tail_x15_r0_body.cnband127, PRE_first_tail_x15_r0_body.chbelow127, PRE_first_tail_x15_r0_body.chren127, PRE_first_tail_x15_r0_body.cband127, PRE_first_tail_x15_r0_body.cnh1pos127, PRE_first_tail_x15_r0_body.cnren127, PRE_first_tail_x15_r0_body.cnlow127, PRE_first_tail_x15_r0_body.cabs0a127, PRE_first_tail_x15_r0_body.cabs0b127, PRE_first_tail_x15_r0_body.ctok1127, PRE_first_tail_x15_r0_body.cpend127, PRE_first_tail_x15_r0_body.cerrh127, PRE_first_tail_x15_r0_body.cfiles127, PRE_first_tail_x15_r0_body.carch127, PRE_first_tail_x15_r0_body.csizes127, PRE_first_tail_x15_r0_body.cwired127, PRE_first_tail_x15_r0_body.cfix127, clean, PRE_first_tail_x15_r0_body.fcxn127, PRE_first_tail_x15_r0_body.fcnn127, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0127, PRE_first_tail_x15_r0_body.fnk127, PRE_first_tail_x15_r0_body.ckA127, PRE_first_tail_x15_r0_body.cobjsK127, PRE_first_tail_x15_r0_body.cnodesK127, PRE_first_tail_x15_r0_body.citemsK127, PRE_first_tail_x15_r0_body.f1A127, PRE_first_tail_x15_r0_body.f1O127, PRE_first_tail_x15_r0_body.f1N127, PRE_first_tail_x15_r0_body.f1I127, PRE_first_tail_x15_r0_body.fbd127, PRE_first_tail_x15_r0_body.fincW127, PRE_first_tail_x15_r0_body.fincI127, PRE_first_tail_x15_r0_body.fincN127, PRE_first_tail_x15_r0_body.flnF127, PRE_first_tail_x15_r0_body.fh127, PRE_first_tail_x15_r0_body.fo127, PRE_first_tail_x15_r0_body.fok127, PRE_first_tail_x15_r0_body.fnd127, PRE_first_tail_x15_r0_body.fp127, PRE_first_tail_x15_r0_body.fnord127, PRE_first_tail_x15_r0_body.fi127, PRE_first_tail_x15_r0_body.fii127⟩
theorem PRE_first_tail_x15_r0_body.cnshift127 (clean : Conv.NClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P127.NL) (cl : SSt (· < 5510) PRE_first_tail_x15_r0_body.cx0_127.mlx) : NShift PRE_first_tail_x15_r0_body.P127 5510 PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.cx0_127 PRE_first_tail_x15_r0_body.cx1_127 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot127 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost127 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0127 PRE_first_tail_x15_r0_body.ckn1127 PRE_first_tail_x15_r0_body.ckheap127 PRE_first_tail_x15_r0_body.ckpl127)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_127 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1232.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_127 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1232.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_127 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1232.ffi) = some PRE_first_tail_x15_r0_body.fxC_127
kernel_rfl PRE_first_tail_x15_r0_body.okrC_127 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1232.ffi) = some PRE_first_tail_x15_r0_body.krC_127
noncomputable def PRE_first_tail_x15_r0_body.fx0_127 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1234.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_127 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1234.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_127 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1234.ffi) = some PRE_first_tail_x15_r0_body.fx0_127
kernel_rfl PRE_first_tail_x15_r0_body.okr0_127 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1234.ffi) = some PRE_first_tail_x15_r0_body.kr0_127
noncomputable def PRE_first_tail_x15_r0_body.fx1_127 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1233.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_127 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1233.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_127 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1233.ffi) = some PRE_first_tail_x15_r0_body.fx1_127
kernel_rfl PRE_first_tail_x15_r0_body.okr1_127 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1233.ffi) = some PRE_first_tail_x15_r0_body.kr1_127
kernel_rfl PRE_first_tail_x15_r0_body.ff0127 : PRE_first_tail_x15_r0_body.fx0_127 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_127 (PRE_first_tail_x15_r0_body.clo127.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_127.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1127 : PRE_first_tail_x15_r0_body.fx1_127 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_127 (PRE_first_tail_x15_r0_body.cwS127.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_127.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck127 : freedLB PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.cx0_127.mlx PRE_first_tail_x15_r0_body.fx0_127 PRE_first_tail_x15_r0_body.fx1_127 PRE_first_tail_x15_r0_body.clo127 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0127 : PRE_first_tail_x15_r0_body.kr0_127.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_127.flags (PRE_first_tail_x15_r0_body.clo127.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_127.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0127 : PRE_first_tail_x15_r0_body.kr0_127.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_127.targs (PRE_first_tail_x15_r0_body.clo127.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_127.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1127 : PRE_first_tail_x15_r0_body.kr1_127.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_127.flags (PRE_first_tail_x15_r0_body.cwS127.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_127.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1127 : PRE_first_tail_x15_r0_body.kr1_127.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_127.targs (PRE_first_tail_x15_r0_body.cwS127.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_127.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck127 : krecLB PRE_first_tail_x15_r0_body.kappa127 5510 PRE_first_tail_x15_r0_body.cx0_127.mlx PRE_first_tail_x15_r0_body.kr0_127 PRE_first_tail_x15_r0_body.kr1_127 PRE_first_tail_x15_r0_body.clo127 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn127 : Nat.ble 5510 5510 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge127 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1233.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1234.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR127 : pendRegB PRE_first_tail_x15_r0_body.kappa127 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe127 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1233.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift127 (clean : Conv.NClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P127.NL) (cl : SSt (· < 5510) PRE_first_tail_x15_r0_body.cx0_127.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_127.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_127.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_127.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_127.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P127 5510 PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.s1234.ffi PRE_first_tail_x15_r0_body.s1233.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift127 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue127, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp127 t ht),
    PRE_first_tail_x15_r0_body.cbridge127,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1234.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1233.ffi) (PRE_first_tail_x15_r0_body.cfoot127 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_127 PRE_first_tail_x15_r0_body.ofx1_127 hobjC PRE_first_tail_x15_r0_body.ff0127 PRE_first_tail_x15_r0_body.ff1127 PRE_first_tail_x15_r0_body.ffck127,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1234.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1233.ffi) (PRE_first_tail_x15_r0_body.cfoot127 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_127 PRE_first_tail_x15_r0_body.okr1_127 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn127) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0127 PRE_first_tail_x15_r0_body.fkt0127 PRE_first_tail_x15_r0_body.fkf1127 PRE_first_tail_x15_r0_body.fkt1127 PRE_first_tail_x15_r0_body.fkck127,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0127 PRE_first_tail_x15_r0_body.cnh1127 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe127) PRE_first_tail_x15_r0_body.cpendR127⟩

end Host.Load.Run.Tpl
