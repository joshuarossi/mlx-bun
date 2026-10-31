import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl165
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 165 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc165 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P165 : LoadP := PRE_first_tail_x15_r0_body.Pc165.raise 18563
kernel_rfl PRE_first_tail_x15_r0_body.craise165 : Nat.ble PRE_first_tail_x15_r0_body.Pc165.N0 18563 = true
theorem PRE_first_tail_x15_r0_body.raised165 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc165 PRE_first_tail_x15_r0_body.P165 :=
  .inr ⟨18563, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise165, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_165 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1459.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_165 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1458.ffi)
def PRE_first_tail_x15_r0_body.khinv165 : PTrie Nat := Stage.setAll PTrie.nil [(21463, 21461), (21464, 21462), (21466, 21463), (21465, 21464)]
def PRE_first_tail_x15_r0_body.kninv165 : PTrie Nat := Stage.setAll PTrie.nil [(18557, 18557), (18558, 18558), (18559, 18559), (18560, 18560), (18561, 18561), (18562, 18562)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS165 : List Nat := [21461, 21462, 21463, 21464, 21465, 21466]
def PRE_first_tail_x15_r0_body.cnS165 : List Nat := List.range' 18557 6
def PRE_first_tail_x15_r0_body.ciS165 : List Nat := [] ++ List.range' 18557 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0165 : PRE_first_tail_x15_r0_body.kd165.nh0 = PRE_first_tail_x15_r0_body.cx0_165.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1165 : PRE_first_tail_x15_r0_body.kd165.nh1 = PRE_first_tail_x15_r0_body.cx1_165.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0165 : PRE_first_tail_x15_r0_body.kd165.nn0 = PRE_first_tail_x15_r0_body.cx0_165.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1165 : PRE_first_tail_x15_r0_body.kd165.nn1 = PRE_first_tail_x15_r0_body.cx1_165.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo165 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P165.lo && Nat.ble PRE_first_tail_x15_r0_body.P165.lo PRE_first_tail_x15_r0_body.cx0_165.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P165.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P165.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt165 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_165.mlx.next PRE_first_tail_x15_r0_body.cx1_165.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_165.mlx.nnext PRE_first_tail_x15_r0_body.cx1_165.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband165 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P165.NL && Nat.ble PRE_first_tail_x15_r0_body.P165.NL PRE_first_tail_x15_r0_body.P165.N0 && Nat.ble PRE_first_tail_x15_r0_body.P165.N0 PRE_first_tail_x15_r0_body.cx0_165.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow165 : PRE_first_tail_x15_r0_body.kd165.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren165 : checkRenG PRE_first_tail_x15_r0_body.kd165.hnd PRE_first_tail_x15_r0_body.khinv165 (phB PRE_first_tail_x15_r0_body.cx0_165.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband165 : PRE_first_tail_x15_r0_body.kd165.checkBand PRE_first_tail_x15_r0_body.P165.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos165 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd165.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren165 : checkRenG PRE_first_tail_x15_r0_body.kd165.node PRE_first_tail_x15_r0_body.kninv165 (pnB PRE_first_tail_x15_r0_body.cx0_165.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow165 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd165.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P165.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd165.nodeF j) PRE_first_tail_x15_r0_body.cx1_165.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a165 : PRE_first_tail_x15_r0_body.cx0_165.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b165 : PRE_first_tail_x15_r0_body.cx0_165.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1165 : PRE_first_tail_x15_r0_body.cx1_165.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend165 : PRE_first_tail_x15_r0_body.cx1_165.mlx.pending = PRE_first_tail_x15_r0_body.cx0_165.mlx.pending.map PRE_first_tail_x15_r0_body.kappa165.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh165 : PRE_first_tail_x15_r0_body.cx1_165.mlx.errh = PRE_first_tail_x15_r0_body.cx0_165.mlx.errh.map PRE_first_tail_x15_r0_body.kappa165.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles165 : PRE_first_tail_x15_r0_body.cx1_165.mlx.files = PRE_first_tail_x15_r0_body.cx0_165.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch165 : PRE_first_tail_x15_r0_body.cx1_165.mlx.arch = PRE_first_tail_x15_r0_body.cx0_165.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes165 : PRE_first_tail_x15_r0_body.cx1_165.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_165.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired165 : PRE_first_tail_x15_r0_body.cx1_165.mlx.wired = PRE_first_tail_x15_r0_body.cx0_165.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost165 : PRE_first_tail_x15_r0_body.cx1_165.host = PRE_first_tail_x15_r0_body.cx0_165.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd165`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0165 : PRE_first_tail_x15_r0_body.kd165.n0 = 2804931
kernel_rfl PRE_first_tail_x15_r0_body.ckn1165 : PRE_first_tail_x15_r0_body.kd165.n1 = 2805281
kernel_rfl PRE_first_tail_x15_r0_body.ckheap165 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd165.heap).all (fun x => Nat.ble 2804916 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl165 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd165.heap.get (2804916 + j) = nth? PRE_first_tail_x15_r0_body.pl165 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja165 : Nat.ble 2804916 2804916 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn165 : Nat.ble 7143 7143 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD165 : Nat.ble 2804916 PRE_first_tail_x15_r0_body.kd165.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn165 : Nat.ble 21461 PRE_first_tail_x15_r0_body.kd165.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn165 : Nat.ble 18557 PRE_first_tail_x15_r0_body.kd165.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb165 : Nat.ble 21461 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap165 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd165.heap).all (Nat.ble (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd165 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd165.hnd).all (Nat.ble (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode165 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd165.node).all (Nat.ble (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix165 : Conv.FixOld (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa165 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja165) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn165) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD165) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn165) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn165) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb165) PRE_first_tail_x15_r0_body.fheap165 PRE_first_tail_x15_r0_body.fhnd165 PRE_first_tail_x15_r0_body.fnode165
kernel_rfl PRE_first_tail_x15_r0_body.fcxn165 : (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn165 : (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0165 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_165.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_165.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk165 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd165.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A165 : PRE_first_tail_x15_r0_body.cx1_165.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS165.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_165.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O165 : PRE_first_tail_x15_r0_body.cx1_165.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS165.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_165.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N165 : PRE_first_tail_x15_r0_body.cx1_165.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS165.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_165.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I165 : PRE_first_tail_x15_r0_body.cx1_165.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS165.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_165.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd165 : (PRE_first_tail_x15_r0_body.clo165 ++ PRE_first_tail_x15_r0_body.cln165 ++ PRE_first_tail_x15_r0_body.cli165 ++ PRE_first_tail_x15_r0_body.cwS165 ++ PRE_first_tail_x15_r0_body.cnS165 ++ PRE_first_tail_x15_r0_body.ciS165).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW165 : PRE_first_tail_x15_r0_body.cwS165.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo165.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI165 : PRE_first_tail_x15_r0_body.ciS165.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli165.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN165 : PRE_first_tail_x15_r0_body.cnS165.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF165 : PRE_first_tail_x15_r0_body.cln165.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh165 : PRE_first_tail_x15_r0_body.clo165.all (handleOK PRE_first_tail_x15_r0_body.kappa165 PRE_first_tail_x15_r0_body.P165.lo PRE_first_tail_x15_r0_body.cx0_165.mlx PRE_first_tail_x15_r0_body.cx1_165.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo165 : PRE_first_tail_x15_r0_body.clo165.map (fun h => PRE_first_tail_x15_r0_body.cx1_165.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa165.handle h)) = PRE_first_tail_x15_r0_body.clo165.map (fun h => (PRE_first_tail_x15_r0_body.cx0_165.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa165.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok165 : PRE_first_tail_x15_r0_body.clo165.all (objOK PRE_first_tail_x15_r0_body.kappa165 PRE_first_tail_x15_r0_body.P165.NL PRE_first_tail_x15_r0_body.cx0_165.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd165 : PRE_first_tail_x15_r0_body.cln165.all (nodeOKF PRE_first_tail_x15_r0_body.kappa165 PRE_first_tail_x15_r0_body.P165 PRE_first_tail_x15_r0_body.cx0_165.mlx PRE_first_tail_x15_r0_body.cx1_165.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp165 : ((PRE_first_tail_x15_r0_body.cln165.filter (fullB PRE_first_tail_x15_r0_body.P165))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_165.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa165.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln165.filter (fullB PRE_first_tail_x15_r0_body.P165))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_165.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa165.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI165 : incrB PRE_first_tail_x15_r0_body.kd165.nodeF (List.range' 18557 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK165 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd165.node).all (fun k => Nat.ble 18557 k && Nat.blt k 18563) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL165 : (PRE_first_tail_x15_r0_body.cln165.filter (Nat.ble PRE_first_tail_x15_r0_body.P165.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd165.nodeF i) && (Nat.blt i 18563 || Nat.ble PRE_first_tail_x15_r0_body.kd165.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord165 : (PRE_first_tail_x15_r0_body.cln165.filter (Nat.ble PRE_first_tail_x15_r0_body.P165.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd165.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd165.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd165.nodeF j) (PRE_first_tail_x15_r0_body.kd165.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow165 PRE_first_tail_x15_r0_body.cnn1165 PRE_first_tail_x15_r0_body.fnordI165 PRE_first_tail_x15_r0_body.fnordK165 PRE_first_tail_x15_r0_body.fnordL165
kernel_rfl PRE_first_tail_x15_r0_body.fi165 : PRE_first_tail_x15_r0_body.cli165.all (pnB PRE_first_tail_x15_r0_body.cx0_165.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii165 : PRE_first_tail_x15_r0_body.cli165.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_165.mlx.items.get (PRE_first_tail_x15_r0_body.kappa165.node k) = (PRE_first_tail_x15_r0_body.cx0_165.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa165.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot165 (clean : Conv.NClean (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P165.NL) (cl : SSt (· < 7152) PRE_first_tail_x15_r0_body.cx0_165.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P165 7152 PRE_first_tail_x15_r0_body.kappa165 PRE_first_tail_x15_r0_body.kd165 PRE_first_tail_x15_r0_body.khinv165 PRE_first_tail_x15_r0_body.kninv165 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx PRE_first_tail_x15_r0_body.cx0_165.mlx PRE_first_tail_x15_r0_body.cx1_165.mlx (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo165 PRE_first_tail_x15_r0_body.cln165 PRE_first_tail_x15_r0_body.cli165 PRE_first_tail_x15_r0_body.cwS165 PRE_first_tail_x15_r0_body.cnS165 PRE_first_tail_x15_r0_body.ciS165 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0165, PRE_first_tail_x15_r0_body.cnh1165, PRE_first_tail_x15_r0_body.cnn0165, PRE_first_tail_x15_r0_body.cnn1165, PRE_first_tail_x15_r0_body.cplo165, PRE_first_tail_x15_r0_body.ccnt165, PRE_first_tail_x15_r0_body.cnband165, PRE_first_tail_x15_r0_body.chbelow165, PRE_first_tail_x15_r0_body.chren165, PRE_first_tail_x15_r0_body.cband165, PRE_first_tail_x15_r0_body.cnh1pos165, PRE_first_tail_x15_r0_body.cnren165, PRE_first_tail_x15_r0_body.cnlow165, PRE_first_tail_x15_r0_body.cabs0a165, PRE_first_tail_x15_r0_body.cabs0b165, PRE_first_tail_x15_r0_body.ctok1165, PRE_first_tail_x15_r0_body.cpend165, PRE_first_tail_x15_r0_body.cerrh165, PRE_first_tail_x15_r0_body.cfiles165, PRE_first_tail_x15_r0_body.carch165, PRE_first_tail_x15_r0_body.csizes165, PRE_first_tail_x15_r0_body.cwired165, PRE_first_tail_x15_r0_body.cfix165, clean, PRE_first_tail_x15_r0_body.fcxn165, PRE_first_tail_x15_r0_body.fcnn165, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0165, PRE_first_tail_x15_r0_body.fnk165, PRE_first_tail_x15_r0_body.ckA165, PRE_first_tail_x15_r0_body.cobjsK165, PRE_first_tail_x15_r0_body.cnodesK165, PRE_first_tail_x15_r0_body.citemsK165, PRE_first_tail_x15_r0_body.f1A165, PRE_first_tail_x15_r0_body.f1O165, PRE_first_tail_x15_r0_body.f1N165, PRE_first_tail_x15_r0_body.f1I165, PRE_first_tail_x15_r0_body.fbd165, PRE_first_tail_x15_r0_body.fincW165, PRE_first_tail_x15_r0_body.fincI165, PRE_first_tail_x15_r0_body.fincN165, PRE_first_tail_x15_r0_body.flnF165, PRE_first_tail_x15_r0_body.fh165, PRE_first_tail_x15_r0_body.fo165, PRE_first_tail_x15_r0_body.fok165, PRE_first_tail_x15_r0_body.fnd165, PRE_first_tail_x15_r0_body.fp165, PRE_first_tail_x15_r0_body.fnord165, PRE_first_tail_x15_r0_body.fi165, PRE_first_tail_x15_r0_body.fii165⟩
theorem PRE_first_tail_x15_r0_body.cnshift165 (clean : Conv.NClean (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P165.NL) (cl : SSt (· < 7152) PRE_first_tail_x15_r0_body.cx0_165.mlx) : NShift PRE_first_tail_x15_r0_body.P165 7152 PRE_first_tail_x15_r0_body.kappa165 PRE_first_tail_x15_r0_body.cx0_165 PRE_first_tail_x15_r0_body.cx1_165 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot165 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost165 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0165 PRE_first_tail_x15_r0_body.ckn1165 PRE_first_tail_x15_r0_body.ckheap165 PRE_first_tail_x15_r0_body.ckpl165)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_165 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1457.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_165 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1457.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_165 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1457.ffi) = some PRE_first_tail_x15_r0_body.fxC_165
kernel_rfl PRE_first_tail_x15_r0_body.okrC_165 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1457.ffi) = some PRE_first_tail_x15_r0_body.krC_165
noncomputable def PRE_first_tail_x15_r0_body.fx0_165 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1459.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_165 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1459.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_165 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1459.ffi) = some PRE_first_tail_x15_r0_body.fx0_165
kernel_rfl PRE_first_tail_x15_r0_body.okr0_165 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1459.ffi) = some PRE_first_tail_x15_r0_body.kr0_165
noncomputable def PRE_first_tail_x15_r0_body.fx1_165 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1458.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_165 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1458.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_165 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1458.ffi) = some PRE_first_tail_x15_r0_body.fx1_165
kernel_rfl PRE_first_tail_x15_r0_body.okr1_165 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1458.ffi) = some PRE_first_tail_x15_r0_body.kr1_165
kernel_rfl PRE_first_tail_x15_r0_body.ff0165 : PRE_first_tail_x15_r0_body.fx0_165 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_165 (PRE_first_tail_x15_r0_body.clo165.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_165.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1165 : PRE_first_tail_x15_r0_body.fx1_165 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_165 (PRE_first_tail_x15_r0_body.cwS165.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_165.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck165 : freedLB PRE_first_tail_x15_r0_body.kappa165 PRE_first_tail_x15_r0_body.cx0_165.mlx PRE_first_tail_x15_r0_body.fx0_165 PRE_first_tail_x15_r0_body.fx1_165 PRE_first_tail_x15_r0_body.clo165 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0165 : PRE_first_tail_x15_r0_body.kr0_165.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_165.flags (PRE_first_tail_x15_r0_body.clo165.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_165.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0165 : PRE_first_tail_x15_r0_body.kr0_165.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_165.targs (PRE_first_tail_x15_r0_body.clo165.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_165.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1165 : PRE_first_tail_x15_r0_body.kr1_165.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_165.flags (PRE_first_tail_x15_r0_body.cwS165.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_165.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1165 : PRE_first_tail_x15_r0_body.kr1_165.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_165.targs (PRE_first_tail_x15_r0_body.cwS165.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_165.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck165 : krecLB PRE_first_tail_x15_r0_body.kappa165 7152 PRE_first_tail_x15_r0_body.cx0_165.mlx PRE_first_tail_x15_r0_body.kr0_165 PRE_first_tail_x15_r0_body.kr1_165 PRE_first_tail_x15_r0_body.clo165 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn165 : Nat.ble 7143 7152 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge165 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1458.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1459.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR165 : pendRegB PRE_first_tail_x15_r0_body.kappa165 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1459.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe165 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1459.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1458.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift165 (clean : Conv.NClean (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P165.NL) (cl : SSt (· < 7152) PRE_first_tail_x15_r0_body.cx0_165.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_165.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_165.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_165.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1457.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_165.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P165 7152 PRE_first_tail_x15_r0_body.kappa165 PRE_first_tail_x15_r0_body.s1459.ffi PRE_first_tail_x15_r0_body.s1458.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift165 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue165, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp165 t ht),
    PRE_first_tail_x15_r0_body.cbridge165,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1459.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1458.ffi) (PRE_first_tail_x15_r0_body.cfoot165 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_165 PRE_first_tail_x15_r0_body.ofx1_165 hobjC PRE_first_tail_x15_r0_body.ff0165 PRE_first_tail_x15_r0_body.ff1165 PRE_first_tail_x15_r0_body.ffck165,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1459.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1458.ffi) (PRE_first_tail_x15_r0_body.cfoot165 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_165 PRE_first_tail_x15_r0_body.okr1_165 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn165) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0165 PRE_first_tail_x15_r0_body.fkt0165 PRE_first_tail_x15_r0_body.fkf1165 PRE_first_tail_x15_r0_body.fkt1165 PRE_first_tail_x15_r0_body.fkck165,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0165 PRE_first_tail_x15_r0_body.cnh1165 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe165) PRE_first_tail_x15_r0_body.cpendR165⟩

end Host.Load.Run.Tpl
