import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl136
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 136 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc136 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P136 : LoadP := PRE_first_tail_x15_r0_body.Pc136.raise 17988
kernel_rfl PRE_first_tail_x15_r0_body.craise136 : Nat.ble PRE_first_tail_x15_r0_body.Pc136.N0 17988 = true
theorem PRE_first_tail_x15_r0_body.raised136 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc136 PRE_first_tail_x15_r0_body.P136 :=
  .inr ⟨17988, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise136, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_136 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_136 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1319.ffi)
def PRE_first_tail_x15_r0_body.khinv136 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv136 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS136 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS136 : List Nat := List.range' 17988 0
def PRE_first_tail_x15_r0_body.ciS136 : List Nat := [] ++ List.range' 17988 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0136 : PRE_first_tail_x15_r0_body.kd136.nh0 = PRE_first_tail_x15_r0_body.cx0_136.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1136 : PRE_first_tail_x15_r0_body.kd136.nh1 = PRE_first_tail_x15_r0_body.cx1_136.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0136 : PRE_first_tail_x15_r0_body.kd136.nn0 = PRE_first_tail_x15_r0_body.cx0_136.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1136 : PRE_first_tail_x15_r0_body.kd136.nn1 = PRE_first_tail_x15_r0_body.cx1_136.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo136 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P136.lo && Nat.ble PRE_first_tail_x15_r0_body.P136.lo PRE_first_tail_x15_r0_body.cx0_136.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P136.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P136.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt136 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_136.mlx.next PRE_first_tail_x15_r0_body.cx1_136.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_136.mlx.nnext PRE_first_tail_x15_r0_body.cx1_136.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband136 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P136.NL && Nat.ble PRE_first_tail_x15_r0_body.P136.NL PRE_first_tail_x15_r0_body.P136.N0 && Nat.ble PRE_first_tail_x15_r0_body.P136.N0 PRE_first_tail_x15_r0_body.cx0_136.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow136 : PRE_first_tail_x15_r0_body.kd136.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren136 : checkRenG PRE_first_tail_x15_r0_body.kd136.hnd PRE_first_tail_x15_r0_body.khinv136 (phB PRE_first_tail_x15_r0_body.cx0_136.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband136 : PRE_first_tail_x15_r0_body.kd136.checkBand PRE_first_tail_x15_r0_body.P136.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos136 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd136.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren136 : checkRenG PRE_first_tail_x15_r0_body.kd136.node PRE_first_tail_x15_r0_body.kninv136 (pnB PRE_first_tail_x15_r0_body.cx0_136.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P136.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd136.nodeF j) PRE_first_tail_x15_r0_body.cx1_136.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a136 : PRE_first_tail_x15_r0_body.cx0_136.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b136 : PRE_first_tail_x15_r0_body.cx0_136.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.pending = PRE_first_tail_x15_r0_body.cx0_136.mlx.pending.map PRE_first_tail_x15_r0_body.kappa136.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.errh = PRE_first_tail_x15_r0_body.cx0_136.mlx.errh.map PRE_first_tail_x15_r0_body.kappa136.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.files = PRE_first_tail_x15_r0_body.cx0_136.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.arch = PRE_first_tail_x15_r0_body.cx0_136.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_136.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.wired = PRE_first_tail_x15_r0_body.cx0_136.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost136 : PRE_first_tail_x15_r0_body.cx1_136.host = PRE_first_tail_x15_r0_body.cx0_136.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd136`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0136 : PRE_first_tail_x15_r0_body.kd136.n0 = 2781787
kernel_rfl PRE_first_tail_x15_r0_body.ckn1136 : PRE_first_tail_x15_r0_body.kd136.n1 = 2781789
kernel_rfl PRE_first_tail_x15_r0_body.ckheap136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.heap).all (fun x => Nat.ble 2781787 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl136 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd136.heap.get (2781787 + j) = nth? PRE_first_tail_x15_r0_body.pl136 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja136 : Nat.ble 2781787 2781787 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn136 : Nat.ble 5894 5894 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD136 : Nat.ble 2781787 PRE_first_tail_x15_r0_body.kd136.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn136 : Nat.ble 20885 PRE_first_tail_x15_r0_body.kd136.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn136 : Nat.ble 17988 PRE_first_tail_x15_r0_body.kd136.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb136 : Nat.ble 20885 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.heap).all (Nat.ble (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.hnd).all (Nat.ble (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.node).all (Nat.ble (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix136 : Conv.FixOld (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa136 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja136) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn136) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD136) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn136) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn136) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb136) PRE_first_tail_x15_r0_body.fheap136 PRE_first_tail_x15_r0_body.fhnd136 PRE_first_tail_x15_r0_body.fnode136
kernel_rfl PRE_first_tail_x15_r0_body.fcxn136 : (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn136 : (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0136 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_136.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_136.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS136.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_136.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS136.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_136.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS136.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_136.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS136.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_136.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd136 : (PRE_first_tail_x15_r0_body.clo136 ++ PRE_first_tail_x15_r0_body.cln136 ++ PRE_first_tail_x15_r0_body.cli136 ++ PRE_first_tail_x15_r0_body.cwS136 ++ PRE_first_tail_x15_r0_body.cnS136 ++ PRE_first_tail_x15_r0_body.ciS136).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW136 : PRE_first_tail_x15_r0_body.cwS136.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo136.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI136 : PRE_first_tail_x15_r0_body.ciS136.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli136.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN136 : PRE_first_tail_x15_r0_body.cnS136.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF136 : PRE_first_tail_x15_r0_body.cln136.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh136 : PRE_first_tail_x15_r0_body.clo136.all (handleOK PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.P136.lo PRE_first_tail_x15_r0_body.cx0_136.mlx PRE_first_tail_x15_r0_body.cx1_136.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo136 : PRE_first_tail_x15_r0_body.clo136.map (fun h => PRE_first_tail_x15_r0_body.cx1_136.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa136.handle h)) = PRE_first_tail_x15_r0_body.clo136.map (fun h => (PRE_first_tail_x15_r0_body.cx0_136.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa136.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok136 : PRE_first_tail_x15_r0_body.clo136.all (objOK PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.P136.NL PRE_first_tail_x15_r0_body.cx0_136.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd136 : PRE_first_tail_x15_r0_body.cln136.all (nodeOKF PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.P136 PRE_first_tail_x15_r0_body.cx0_136.mlx PRE_first_tail_x15_r0_body.cx1_136.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp136 : ((PRE_first_tail_x15_r0_body.cln136.filter (fullB PRE_first_tail_x15_r0_body.P136))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_136.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa136.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln136.filter (fullB PRE_first_tail_x15_r0_body.P136))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_136.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa136.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI136 : incrB PRE_first_tail_x15_r0_body.kd136.nodeF (List.range' 17988 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.node).all (fun k => Nat.ble 17988 k && Nat.blt k 17988) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL136 : (PRE_first_tail_x15_r0_body.cln136.filter (Nat.ble PRE_first_tail_x15_r0_body.P136.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd136.nodeF i) && (Nat.blt i 17988 || Nat.ble PRE_first_tail_x15_r0_body.kd136.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord136 : (PRE_first_tail_x15_r0_body.cln136.filter (Nat.ble PRE_first_tail_x15_r0_body.P136.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd136.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd136.nodeF j) (PRE_first_tail_x15_r0_body.kd136.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow136 PRE_first_tail_x15_r0_body.cnn1136 PRE_first_tail_x15_r0_body.fnordI136 PRE_first_tail_x15_r0_body.fnordK136 PRE_first_tail_x15_r0_body.fnordL136
kernel_rfl PRE_first_tail_x15_r0_body.fi136 : PRE_first_tail_x15_r0_body.cli136.all (pnB PRE_first_tail_x15_r0_body.cx0_136.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii136 : PRE_first_tail_x15_r0_body.cli136.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_136.mlx.items.get (PRE_first_tail_x15_r0_body.kappa136.node k) = (PRE_first_tail_x15_r0_body.cx0_136.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa136.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot136 (clean : Conv.NClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P136.NL) (cl : SSt (· < 5894) PRE_first_tail_x15_r0_body.cx0_136.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P136 5894 PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.kd136 PRE_first_tail_x15_r0_body.khinv136 PRE_first_tail_x15_r0_body.kninv136 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx PRE_first_tail_x15_r0_body.cx0_136.mlx PRE_first_tail_x15_r0_body.cx1_136.mlx (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo136 PRE_first_tail_x15_r0_body.cln136 PRE_first_tail_x15_r0_body.cli136 PRE_first_tail_x15_r0_body.cwS136 PRE_first_tail_x15_r0_body.cnS136 PRE_first_tail_x15_r0_body.ciS136 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0136, PRE_first_tail_x15_r0_body.cnh1136, PRE_first_tail_x15_r0_body.cnn0136, PRE_first_tail_x15_r0_body.cnn1136, PRE_first_tail_x15_r0_body.cplo136, PRE_first_tail_x15_r0_body.ccnt136, PRE_first_tail_x15_r0_body.cnband136, PRE_first_tail_x15_r0_body.chbelow136, PRE_first_tail_x15_r0_body.chren136, PRE_first_tail_x15_r0_body.cband136, PRE_first_tail_x15_r0_body.cnh1pos136, PRE_first_tail_x15_r0_body.cnren136, PRE_first_tail_x15_r0_body.cnlow136, PRE_first_tail_x15_r0_body.cabs0a136, PRE_first_tail_x15_r0_body.cabs0b136, PRE_first_tail_x15_r0_body.ctok1136, PRE_first_tail_x15_r0_body.cpend136, PRE_first_tail_x15_r0_body.cerrh136, PRE_first_tail_x15_r0_body.cfiles136, PRE_first_tail_x15_r0_body.carch136, PRE_first_tail_x15_r0_body.csizes136, PRE_first_tail_x15_r0_body.cwired136, PRE_first_tail_x15_r0_body.cfix136, clean, PRE_first_tail_x15_r0_body.fcxn136, PRE_first_tail_x15_r0_body.fcnn136, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0136, PRE_first_tail_x15_r0_body.fnk136, PRE_first_tail_x15_r0_body.ckA136, PRE_first_tail_x15_r0_body.cobjsK136, PRE_first_tail_x15_r0_body.cnodesK136, PRE_first_tail_x15_r0_body.citemsK136, PRE_first_tail_x15_r0_body.f1A136, PRE_first_tail_x15_r0_body.f1O136, PRE_first_tail_x15_r0_body.f1N136, PRE_first_tail_x15_r0_body.f1I136, PRE_first_tail_x15_r0_body.fbd136, PRE_first_tail_x15_r0_body.fincW136, PRE_first_tail_x15_r0_body.fincI136, PRE_first_tail_x15_r0_body.fincN136, PRE_first_tail_x15_r0_body.flnF136, PRE_first_tail_x15_r0_body.fh136, PRE_first_tail_x15_r0_body.fo136, PRE_first_tail_x15_r0_body.fok136, PRE_first_tail_x15_r0_body.fnd136, PRE_first_tail_x15_r0_body.fp136, PRE_first_tail_x15_r0_body.fnord136, PRE_first_tail_x15_r0_body.fi136, PRE_first_tail_x15_r0_body.fii136⟩
theorem PRE_first_tail_x15_r0_body.cnshift136 (clean : Conv.NClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P136.NL) (cl : SSt (· < 5894) PRE_first_tail_x15_r0_body.cx0_136.mlx) : NShift PRE_first_tail_x15_r0_body.P136 5894 PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.cx0_136 PRE_first_tail_x15_r0_body.cx1_136 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot136 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost136 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0136 PRE_first_tail_x15_r0_body.ckn1136 PRE_first_tail_x15_r0_body.ckheap136 PRE_first_tail_x15_r0_body.ckpl136)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_136 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1318.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_136 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1318.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_136 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1318.ffi) = some PRE_first_tail_x15_r0_body.fxC_136
kernel_rfl PRE_first_tail_x15_r0_body.okrC_136 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1318.ffi) = some PRE_first_tail_x15_r0_body.krC_136
noncomputable def PRE_first_tail_x15_r0_body.fx0_136 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1320.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_136 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1320.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_136 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1320.ffi) = some PRE_first_tail_x15_r0_body.fx0_136
kernel_rfl PRE_first_tail_x15_r0_body.okr0_136 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1320.ffi) = some PRE_first_tail_x15_r0_body.kr0_136
noncomputable def PRE_first_tail_x15_r0_body.fx1_136 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1319.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_136 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1319.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_136 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1319.ffi) = some PRE_first_tail_x15_r0_body.fx1_136
kernel_rfl PRE_first_tail_x15_r0_body.okr1_136 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1319.ffi) = some PRE_first_tail_x15_r0_body.kr1_136
kernel_rfl PRE_first_tail_x15_r0_body.ff0136 : PRE_first_tail_x15_r0_body.fx0_136 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_136 (PRE_first_tail_x15_r0_body.clo136.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_136.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1136 : PRE_first_tail_x15_r0_body.fx1_136 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_136 (PRE_first_tail_x15_r0_body.cwS136.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_136.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck136 : freedLB PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.cx0_136.mlx PRE_first_tail_x15_r0_body.fx0_136 PRE_first_tail_x15_r0_body.fx1_136 PRE_first_tail_x15_r0_body.clo136 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0136 : PRE_first_tail_x15_r0_body.kr0_136.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_136.flags (PRE_first_tail_x15_r0_body.clo136.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_136.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0136 : PRE_first_tail_x15_r0_body.kr0_136.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_136.targs (PRE_first_tail_x15_r0_body.clo136.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_136.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1136 : PRE_first_tail_x15_r0_body.kr1_136.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_136.flags (PRE_first_tail_x15_r0_body.cwS136.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_136.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1136 : PRE_first_tail_x15_r0_body.kr1_136.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_136.targs (PRE_first_tail_x15_r0_body.cwS136.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_136.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck136 : krecLB PRE_first_tail_x15_r0_body.kappa136 5894 PRE_first_tail_x15_r0_body.cx0_136.mlx PRE_first_tail_x15_r0_body.kr0_136 PRE_first_tail_x15_r0_body.kr1_136 PRE_first_tail_x15_r0_body.clo136 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn136 : Nat.ble 5894 5894 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge136 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1319.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1320.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR136 : pendRegB PRE_first_tail_x15_r0_body.kappa136 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe136 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1319.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift136 (clean : Conv.NClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P136.NL) (cl : SSt (· < 5894) PRE_first_tail_x15_r0_body.cx0_136.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_136.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_136.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_136.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_136.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P136 5894 PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.s1320.ffi PRE_first_tail_x15_r0_body.s1319.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift136 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue136, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp136 t ht),
    PRE_first_tail_x15_r0_body.cbridge136,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1320.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1319.ffi) (PRE_first_tail_x15_r0_body.cfoot136 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_136 PRE_first_tail_x15_r0_body.ofx1_136 hobjC PRE_first_tail_x15_r0_body.ff0136 PRE_first_tail_x15_r0_body.ff1136 PRE_first_tail_x15_r0_body.ffck136,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1320.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1319.ffi) (PRE_first_tail_x15_r0_body.cfoot136 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_136 PRE_first_tail_x15_r0_body.okr1_136 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn136) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0136 PRE_first_tail_x15_r0_body.fkt0136 PRE_first_tail_x15_r0_body.fkf1136 PRE_first_tail_x15_r0_body.fkt1136 PRE_first_tail_x15_r0_body.fkck136,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0136 PRE_first_tail_x15_r0_body.cnh1136 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe136) PRE_first_tail_x15_r0_body.cpendR136⟩

end Host.Load.Run.Tpl
