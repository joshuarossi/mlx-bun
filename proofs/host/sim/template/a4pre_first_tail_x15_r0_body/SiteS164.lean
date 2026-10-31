import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl164
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 164 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc164 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P164 : LoadP := PRE_first_tail_x15_r0_body.Pc164.raise 18529
kernel_rfl PRE_first_tail_x15_r0_body.craise164 : Nat.ble PRE_first_tail_x15_r0_body.Pc164.N0 18529 = true
theorem PRE_first_tail_x15_r0_body.raised164 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc164 PRE_first_tail_x15_r0_body.P164 :=
  .inr ⟨18529, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise164, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_164 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1446.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_164 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1445.ffi)
def PRE_first_tail_x15_r0_body.khinv164 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv164 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS164 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS164 : List Nat := List.range' 18529 0
def PRE_first_tail_x15_r0_body.ciS164 : List Nat := [] ++ List.range' 18529 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0164 : PRE_first_tail_x15_r0_body.kd164.nh0 = PRE_first_tail_x15_r0_body.cx0_164.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1164 : PRE_first_tail_x15_r0_body.kd164.nh1 = PRE_first_tail_x15_r0_body.cx1_164.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0164 : PRE_first_tail_x15_r0_body.kd164.nn0 = PRE_first_tail_x15_r0_body.cx0_164.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1164 : PRE_first_tail_x15_r0_body.kd164.nn1 = PRE_first_tail_x15_r0_body.cx1_164.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo164 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P164.lo && Nat.ble PRE_first_tail_x15_r0_body.P164.lo PRE_first_tail_x15_r0_body.cx0_164.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P164.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P164.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt164 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_164.mlx.next PRE_first_tail_x15_r0_body.cx1_164.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_164.mlx.nnext PRE_first_tail_x15_r0_body.cx1_164.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband164 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P164.NL && Nat.ble PRE_first_tail_x15_r0_body.P164.NL PRE_first_tail_x15_r0_body.P164.N0 && Nat.ble PRE_first_tail_x15_r0_body.P164.N0 PRE_first_tail_x15_r0_body.cx0_164.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow164 : PRE_first_tail_x15_r0_body.kd164.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren164 : checkRenG PRE_first_tail_x15_r0_body.kd164.hnd PRE_first_tail_x15_r0_body.khinv164 (phB PRE_first_tail_x15_r0_body.cx0_164.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband164 : PRE_first_tail_x15_r0_body.kd164.checkBand PRE_first_tail_x15_r0_body.P164.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos164 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd164.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren164 : checkRenG PRE_first_tail_x15_r0_body.kd164.node PRE_first_tail_x15_r0_body.kninv164 (pnB PRE_first_tail_x15_r0_body.cx0_164.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow164 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd164.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P164.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd164.nodeF j) PRE_first_tail_x15_r0_body.cx1_164.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a164 : PRE_first_tail_x15_r0_body.cx0_164.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b164 : PRE_first_tail_x15_r0_body.cx0_164.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1164 : PRE_first_tail_x15_r0_body.cx1_164.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend164 : PRE_first_tail_x15_r0_body.cx1_164.mlx.pending = PRE_first_tail_x15_r0_body.cx0_164.mlx.pending.map PRE_first_tail_x15_r0_body.kappa164.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh164 : PRE_first_tail_x15_r0_body.cx1_164.mlx.errh = PRE_first_tail_x15_r0_body.cx0_164.mlx.errh.map PRE_first_tail_x15_r0_body.kappa164.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles164 : PRE_first_tail_x15_r0_body.cx1_164.mlx.files = PRE_first_tail_x15_r0_body.cx0_164.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch164 : PRE_first_tail_x15_r0_body.cx1_164.mlx.arch = PRE_first_tail_x15_r0_body.cx0_164.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes164 : PRE_first_tail_x15_r0_body.cx1_164.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_164.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired164 : PRE_first_tail_x15_r0_body.cx1_164.mlx.wired = PRE_first_tail_x15_r0_body.cx0_164.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost164 : PRE_first_tail_x15_r0_body.cx1_164.host = PRE_first_tail_x15_r0_body.cx0_164.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd164`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0164 : PRE_first_tail_x15_r0_body.kd164.n0 = 2803176
kernel_rfl PRE_first_tail_x15_r0_body.ckn1164 : PRE_first_tail_x15_r0_body.kd164.n1 = 2803195
kernel_rfl PRE_first_tail_x15_r0_body.ckheap164 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd164.heap).all (fun x => Nat.ble 2803175 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl164 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd164.heap.get (2803175 + j) = nth? PRE_first_tail_x15_r0_body.pl164 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja164 : Nat.ble 2803175 2803175 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn164 : Nat.ble 7066 7066 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD164 : Nat.ble 2803175 PRE_first_tail_x15_r0_body.kd164.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn164 : Nat.ble 21421 PRE_first_tail_x15_r0_body.kd164.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn164 : Nat.ble 18529 PRE_first_tail_x15_r0_body.kd164.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb164 : Nat.ble 21421 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap164 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd164.heap).all (Nat.ble (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd164 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd164.hnd).all (Nat.ble (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode164 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd164.node).all (Nat.ble (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix164 : Conv.FixOld (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa164 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja164) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn164) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD164) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn164) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn164) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb164) PRE_first_tail_x15_r0_body.fheap164 PRE_first_tail_x15_r0_body.fhnd164 PRE_first_tail_x15_r0_body.fnode164
kernel_rfl PRE_first_tail_x15_r0_body.fcxn164 : (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn164 : (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0164 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_164.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_164.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk164 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd164.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A164 : PRE_first_tail_x15_r0_body.cx1_164.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS164.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_164.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O164 : PRE_first_tail_x15_r0_body.cx1_164.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS164.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_164.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N164 : PRE_first_tail_x15_r0_body.cx1_164.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS164.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_164.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I164 : PRE_first_tail_x15_r0_body.cx1_164.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS164.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_164.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd164 : (PRE_first_tail_x15_r0_body.clo164 ++ PRE_first_tail_x15_r0_body.cln164 ++ PRE_first_tail_x15_r0_body.cli164 ++ PRE_first_tail_x15_r0_body.cwS164 ++ PRE_first_tail_x15_r0_body.cnS164 ++ PRE_first_tail_x15_r0_body.ciS164).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW164 : PRE_first_tail_x15_r0_body.cwS164.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo164.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI164 : PRE_first_tail_x15_r0_body.ciS164.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli164.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN164 : PRE_first_tail_x15_r0_body.cnS164.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF164 : PRE_first_tail_x15_r0_body.cln164.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh164 : PRE_first_tail_x15_r0_body.clo164.all (handleOK PRE_first_tail_x15_r0_body.kappa164 PRE_first_tail_x15_r0_body.P164.lo PRE_first_tail_x15_r0_body.cx0_164.mlx PRE_first_tail_x15_r0_body.cx1_164.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo164 : PRE_first_tail_x15_r0_body.clo164.map (fun h => PRE_first_tail_x15_r0_body.cx1_164.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa164.handle h)) = PRE_first_tail_x15_r0_body.clo164.map (fun h => (PRE_first_tail_x15_r0_body.cx0_164.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa164.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok164 : PRE_first_tail_x15_r0_body.clo164.all (objOK PRE_first_tail_x15_r0_body.kappa164 PRE_first_tail_x15_r0_body.P164.NL PRE_first_tail_x15_r0_body.cx0_164.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd164 : PRE_first_tail_x15_r0_body.cln164.all (nodeOKF PRE_first_tail_x15_r0_body.kappa164 PRE_first_tail_x15_r0_body.P164 PRE_first_tail_x15_r0_body.cx0_164.mlx PRE_first_tail_x15_r0_body.cx1_164.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp164 : ((PRE_first_tail_x15_r0_body.cln164.filter (fullB PRE_first_tail_x15_r0_body.P164))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_164.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa164.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln164.filter (fullB PRE_first_tail_x15_r0_body.P164))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_164.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa164.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI164 : incrB PRE_first_tail_x15_r0_body.kd164.nodeF (List.range' 18529 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK164 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd164.node).all (fun k => Nat.ble 18529 k && Nat.blt k 18529) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL164 : (PRE_first_tail_x15_r0_body.cln164.filter (Nat.ble PRE_first_tail_x15_r0_body.P164.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd164.nodeF i) && (Nat.blt i 18529 || Nat.ble PRE_first_tail_x15_r0_body.kd164.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord164 : (PRE_first_tail_x15_r0_body.cln164.filter (Nat.ble PRE_first_tail_x15_r0_body.P164.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd164.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd164.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd164.nodeF j) (PRE_first_tail_x15_r0_body.kd164.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow164 PRE_first_tail_x15_r0_body.cnn1164 PRE_first_tail_x15_r0_body.fnordI164 PRE_first_tail_x15_r0_body.fnordK164 PRE_first_tail_x15_r0_body.fnordL164
kernel_rfl PRE_first_tail_x15_r0_body.fi164 : PRE_first_tail_x15_r0_body.cli164.all (pnB PRE_first_tail_x15_r0_body.cx0_164.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii164 : PRE_first_tail_x15_r0_body.cli164.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_164.mlx.items.get (PRE_first_tail_x15_r0_body.kappa164.node k) = (PRE_first_tail_x15_r0_body.cx0_164.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa164.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot164 (clean : Conv.NClean (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P164.NL) (cl : SSt (· < 7066) PRE_first_tail_x15_r0_body.cx0_164.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P164 7066 PRE_first_tail_x15_r0_body.kappa164 PRE_first_tail_x15_r0_body.kd164 PRE_first_tail_x15_r0_body.khinv164 PRE_first_tail_x15_r0_body.kninv164 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx PRE_first_tail_x15_r0_body.cx0_164.mlx PRE_first_tail_x15_r0_body.cx1_164.mlx (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo164 PRE_first_tail_x15_r0_body.cln164 PRE_first_tail_x15_r0_body.cli164 PRE_first_tail_x15_r0_body.cwS164 PRE_first_tail_x15_r0_body.cnS164 PRE_first_tail_x15_r0_body.ciS164 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0164, PRE_first_tail_x15_r0_body.cnh1164, PRE_first_tail_x15_r0_body.cnn0164, PRE_first_tail_x15_r0_body.cnn1164, PRE_first_tail_x15_r0_body.cplo164, PRE_first_tail_x15_r0_body.ccnt164, PRE_first_tail_x15_r0_body.cnband164, PRE_first_tail_x15_r0_body.chbelow164, PRE_first_tail_x15_r0_body.chren164, PRE_first_tail_x15_r0_body.cband164, PRE_first_tail_x15_r0_body.cnh1pos164, PRE_first_tail_x15_r0_body.cnren164, PRE_first_tail_x15_r0_body.cnlow164, PRE_first_tail_x15_r0_body.cabs0a164, PRE_first_tail_x15_r0_body.cabs0b164, PRE_first_tail_x15_r0_body.ctok1164, PRE_first_tail_x15_r0_body.cpend164, PRE_first_tail_x15_r0_body.cerrh164, PRE_first_tail_x15_r0_body.cfiles164, PRE_first_tail_x15_r0_body.carch164, PRE_first_tail_x15_r0_body.csizes164, PRE_first_tail_x15_r0_body.cwired164, PRE_first_tail_x15_r0_body.cfix164, clean, PRE_first_tail_x15_r0_body.fcxn164, PRE_first_tail_x15_r0_body.fcnn164, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0164, PRE_first_tail_x15_r0_body.fnk164, PRE_first_tail_x15_r0_body.ckA164, PRE_first_tail_x15_r0_body.cobjsK164, PRE_first_tail_x15_r0_body.cnodesK164, PRE_first_tail_x15_r0_body.citemsK164, PRE_first_tail_x15_r0_body.f1A164, PRE_first_tail_x15_r0_body.f1O164, PRE_first_tail_x15_r0_body.f1N164, PRE_first_tail_x15_r0_body.f1I164, PRE_first_tail_x15_r0_body.fbd164, PRE_first_tail_x15_r0_body.fincW164, PRE_first_tail_x15_r0_body.fincI164, PRE_first_tail_x15_r0_body.fincN164, PRE_first_tail_x15_r0_body.flnF164, PRE_first_tail_x15_r0_body.fh164, PRE_first_tail_x15_r0_body.fo164, PRE_first_tail_x15_r0_body.fok164, PRE_first_tail_x15_r0_body.fnd164, PRE_first_tail_x15_r0_body.fp164, PRE_first_tail_x15_r0_body.fnord164, PRE_first_tail_x15_r0_body.fi164, PRE_first_tail_x15_r0_body.fii164⟩
theorem PRE_first_tail_x15_r0_body.cnshift164 (clean : Conv.NClean (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P164.NL) (cl : SSt (· < 7066) PRE_first_tail_x15_r0_body.cx0_164.mlx) : NShift PRE_first_tail_x15_r0_body.P164 7066 PRE_first_tail_x15_r0_body.kappa164 PRE_first_tail_x15_r0_body.cx0_164 PRE_first_tail_x15_r0_body.cx1_164 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot164 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost164 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0164 PRE_first_tail_x15_r0_body.ckn1164 PRE_first_tail_x15_r0_body.ckheap164 PRE_first_tail_x15_r0_body.ckpl164)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_164 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1444.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_164 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1444.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_164 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1444.ffi) = some PRE_first_tail_x15_r0_body.fxC_164
kernel_rfl PRE_first_tail_x15_r0_body.okrC_164 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1444.ffi) = some PRE_first_tail_x15_r0_body.krC_164
noncomputable def PRE_first_tail_x15_r0_body.fx0_164 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1446.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_164 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1446.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_164 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1446.ffi) = some PRE_first_tail_x15_r0_body.fx0_164
kernel_rfl PRE_first_tail_x15_r0_body.okr0_164 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1446.ffi) = some PRE_first_tail_x15_r0_body.kr0_164
noncomputable def PRE_first_tail_x15_r0_body.fx1_164 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1445.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_164 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1445.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_164 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1445.ffi) = some PRE_first_tail_x15_r0_body.fx1_164
kernel_rfl PRE_first_tail_x15_r0_body.okr1_164 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1445.ffi) = some PRE_first_tail_x15_r0_body.kr1_164
kernel_rfl PRE_first_tail_x15_r0_body.ff0164 : PRE_first_tail_x15_r0_body.fx0_164 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_164 (PRE_first_tail_x15_r0_body.clo164.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_164.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1164 : PRE_first_tail_x15_r0_body.fx1_164 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_164 (PRE_first_tail_x15_r0_body.cwS164.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_164.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck164 : freedLB PRE_first_tail_x15_r0_body.kappa164 PRE_first_tail_x15_r0_body.cx0_164.mlx PRE_first_tail_x15_r0_body.fx0_164 PRE_first_tail_x15_r0_body.fx1_164 PRE_first_tail_x15_r0_body.clo164 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0164 : PRE_first_tail_x15_r0_body.kr0_164.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_164.flags (PRE_first_tail_x15_r0_body.clo164.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_164.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0164 : PRE_first_tail_x15_r0_body.kr0_164.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_164.targs (PRE_first_tail_x15_r0_body.clo164.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_164.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1164 : PRE_first_tail_x15_r0_body.kr1_164.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_164.flags (PRE_first_tail_x15_r0_body.cwS164.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_164.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1164 : PRE_first_tail_x15_r0_body.kr1_164.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_164.targs (PRE_first_tail_x15_r0_body.cwS164.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_164.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck164 : krecLB PRE_first_tail_x15_r0_body.kappa164 7066 PRE_first_tail_x15_r0_body.cx0_164.mlx PRE_first_tail_x15_r0_body.kr0_164 PRE_first_tail_x15_r0_body.kr1_164 PRE_first_tail_x15_r0_body.clo164 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn164 : Nat.ble 7066 7066 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge164 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1445.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1446.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR164 : pendRegB PRE_first_tail_x15_r0_body.kappa164 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1446.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe164 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1446.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1445.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift164 (clean : Conv.NClean (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P164.NL) (cl : SSt (· < 7066) PRE_first_tail_x15_r0_body.cx0_164.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_164.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_164.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_164.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1444.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_164.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P164 7066 PRE_first_tail_x15_r0_body.kappa164 PRE_first_tail_x15_r0_body.s1446.ffi PRE_first_tail_x15_r0_body.s1445.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift164 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue164, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp164 t ht),
    PRE_first_tail_x15_r0_body.cbridge164,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1446.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1445.ffi) (PRE_first_tail_x15_r0_body.cfoot164 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_164 PRE_first_tail_x15_r0_body.ofx1_164 hobjC PRE_first_tail_x15_r0_body.ff0164 PRE_first_tail_x15_r0_body.ff1164 PRE_first_tail_x15_r0_body.ffck164,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1446.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1445.ffi) (PRE_first_tail_x15_r0_body.cfoot164 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_164 PRE_first_tail_x15_r0_body.okr1_164 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn164) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0164 PRE_first_tail_x15_r0_body.fkt0164 PRE_first_tail_x15_r0_body.fkf1164 PRE_first_tail_x15_r0_body.fkt1164 PRE_first_tail_x15_r0_body.fkck164,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0164 PRE_first_tail_x15_r0_body.cnh1164 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe164) PRE_first_tail_x15_r0_body.cpendR164⟩

end Host.Load.Run.Tpl
