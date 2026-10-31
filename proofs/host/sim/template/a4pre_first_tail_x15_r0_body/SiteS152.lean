import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl152
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 152 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc152 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P152 : LoadP := PRE_first_tail_x15_r0_body.Pc152.raise 18292
kernel_rfl PRE_first_tail_x15_r0_body.craise152 : Nat.ble PRE_first_tail_x15_r0_body.Pc152.N0 18292 = true
theorem PRE_first_tail_x15_r0_body.raised152 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc152 PRE_first_tail_x15_r0_body.P152 :=
  .inr ⟨18292, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise152, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_152 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1468.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_152 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1467.ffi)
def PRE_first_tail_x15_r0_body.khinv152 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv152 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS152 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS152 : List Nat := List.range' 18292 0
def PRE_first_tail_x15_r0_body.ciS152 : List Nat := [] ++ List.range' 18292 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0152 : PRE_first_tail_x15_r0_body.kd152.nh0 = PRE_first_tail_x15_r0_body.cx0_152.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1152 : PRE_first_tail_x15_r0_body.kd152.nh1 = PRE_first_tail_x15_r0_body.cx1_152.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0152 : PRE_first_tail_x15_r0_body.kd152.nn0 = PRE_first_tail_x15_r0_body.cx0_152.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1152 : PRE_first_tail_x15_r0_body.kd152.nn1 = PRE_first_tail_x15_r0_body.cx1_152.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo152 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P152.lo && Nat.ble PRE_first_tail_x15_r0_body.P152.lo PRE_first_tail_x15_r0_body.cx0_152.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P152.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P152.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt152 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_152.mlx.next PRE_first_tail_x15_r0_body.cx1_152.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_152.mlx.nnext PRE_first_tail_x15_r0_body.cx1_152.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband152 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P152.NL && Nat.ble PRE_first_tail_x15_r0_body.P152.NL PRE_first_tail_x15_r0_body.P152.N0 && Nat.ble PRE_first_tail_x15_r0_body.P152.N0 PRE_first_tail_x15_r0_body.cx0_152.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow152 : PRE_first_tail_x15_r0_body.kd152.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren152 : checkRenG PRE_first_tail_x15_r0_body.kd152.hnd PRE_first_tail_x15_r0_body.khinv152 (phB PRE_first_tail_x15_r0_body.cx0_152.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband152 : PRE_first_tail_x15_r0_body.kd152.checkBand PRE_first_tail_x15_r0_body.P152.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos152 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd152.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren152 : checkRenG PRE_first_tail_x15_r0_body.kd152.node PRE_first_tail_x15_r0_body.kninv152 (pnB PRE_first_tail_x15_r0_body.cx0_152.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow152 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd152.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P152.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd152.nodeF j) PRE_first_tail_x15_r0_body.cx1_152.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a152 : PRE_first_tail_x15_r0_body.cx0_152.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b152 : PRE_first_tail_x15_r0_body.cx0_152.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1152 : PRE_first_tail_x15_r0_body.cx1_152.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend152 : PRE_first_tail_x15_r0_body.cx1_152.mlx.pending = PRE_first_tail_x15_r0_body.cx0_152.mlx.pending.map PRE_first_tail_x15_r0_body.kappa152.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh152 : PRE_first_tail_x15_r0_body.cx1_152.mlx.errh = PRE_first_tail_x15_r0_body.cx0_152.mlx.errh.map PRE_first_tail_x15_r0_body.kappa152.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles152 : PRE_first_tail_x15_r0_body.cx1_152.mlx.files = PRE_first_tail_x15_r0_body.cx0_152.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch152 : PRE_first_tail_x15_r0_body.cx1_152.mlx.arch = PRE_first_tail_x15_r0_body.cx0_152.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes152 : PRE_first_tail_x15_r0_body.cx1_152.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_152.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired152 : PRE_first_tail_x15_r0_body.cx1_152.mlx.wired = PRE_first_tail_x15_r0_body.cx0_152.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost152 : PRE_first_tail_x15_r0_body.cx1_152.host = PRE_first_tail_x15_r0_body.cx0_152.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd152`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0152 : PRE_first_tail_x15_r0_body.kd152.n0 = 2793764
kernel_rfl PRE_first_tail_x15_r0_body.ckn1152 : PRE_first_tail_x15_r0_body.kd152.n1 = 2793774
kernel_rfl PRE_first_tail_x15_r0_body.ckheap152 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd152.heap).all (fun x => Nat.ble 2793763 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl152 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd152.heap.get (2793763 + j) = nth? PRE_first_tail_x15_r0_body.pl152 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja152 : Nat.ble 2793763 2793763 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn152 : Nat.ble 6553 6553 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD152 : Nat.ble 2793763 PRE_first_tail_x15_r0_body.kd152.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn152 : Nat.ble 21185 PRE_first_tail_x15_r0_body.kd152.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn152 : Nat.ble 18292 PRE_first_tail_x15_r0_body.kd152.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb152 : Nat.ble 21185 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap152 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd152.heap).all (Nat.ble (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd152 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd152.hnd).all (Nat.ble (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode152 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd152.node).all (Nat.ble (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix152 : Conv.FixOld (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa152 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja152) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn152) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD152) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn152) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn152) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb152) PRE_first_tail_x15_r0_body.fheap152 PRE_first_tail_x15_r0_body.fhnd152 PRE_first_tail_x15_r0_body.fnode152
kernel_rfl PRE_first_tail_x15_r0_body.fcxn152 : (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn152 : (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0152 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_152.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_152.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk152 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd152.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A152 : PRE_first_tail_x15_r0_body.cx1_152.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS152.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_152.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O152 : PRE_first_tail_x15_r0_body.cx1_152.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS152.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_152.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N152 : PRE_first_tail_x15_r0_body.cx1_152.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS152.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_152.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I152 : PRE_first_tail_x15_r0_body.cx1_152.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS152.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_152.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd152 : (PRE_first_tail_x15_r0_body.clo152 ++ PRE_first_tail_x15_r0_body.cln152 ++ PRE_first_tail_x15_r0_body.cli152 ++ PRE_first_tail_x15_r0_body.cwS152 ++ PRE_first_tail_x15_r0_body.cnS152 ++ PRE_first_tail_x15_r0_body.ciS152).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW152 : PRE_first_tail_x15_r0_body.cwS152.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo152.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI152 : PRE_first_tail_x15_r0_body.ciS152.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli152.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN152 : PRE_first_tail_x15_r0_body.cnS152.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF152 : PRE_first_tail_x15_r0_body.cln152.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh152 : PRE_first_tail_x15_r0_body.clo152.all (handleOK PRE_first_tail_x15_r0_body.kappa152 PRE_first_tail_x15_r0_body.P152.lo PRE_first_tail_x15_r0_body.cx0_152.mlx PRE_first_tail_x15_r0_body.cx1_152.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo152 : PRE_first_tail_x15_r0_body.clo152.map (fun h => PRE_first_tail_x15_r0_body.cx1_152.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa152.handle h)) = PRE_first_tail_x15_r0_body.clo152.map (fun h => (PRE_first_tail_x15_r0_body.cx0_152.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa152.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok152 : PRE_first_tail_x15_r0_body.clo152.all (objOK PRE_first_tail_x15_r0_body.kappa152 PRE_first_tail_x15_r0_body.P152.NL PRE_first_tail_x15_r0_body.cx0_152.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd152 : PRE_first_tail_x15_r0_body.cln152.all (nodeOKF PRE_first_tail_x15_r0_body.kappa152 PRE_first_tail_x15_r0_body.P152 PRE_first_tail_x15_r0_body.cx0_152.mlx PRE_first_tail_x15_r0_body.cx1_152.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp152 : ((PRE_first_tail_x15_r0_body.cln152.filter (fullB PRE_first_tail_x15_r0_body.P152))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_152.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa152.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln152.filter (fullB PRE_first_tail_x15_r0_body.P152))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_152.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa152.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI152 : incrB PRE_first_tail_x15_r0_body.kd152.nodeF (List.range' 18292 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK152 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd152.node).all (fun k => Nat.ble 18292 k && Nat.blt k 18292) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL152 : (PRE_first_tail_x15_r0_body.cln152.filter (Nat.ble PRE_first_tail_x15_r0_body.P152.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd152.nodeF i) && (Nat.blt i 18292 || Nat.ble PRE_first_tail_x15_r0_body.kd152.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord152 : (PRE_first_tail_x15_r0_body.cln152.filter (Nat.ble PRE_first_tail_x15_r0_body.P152.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd152.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd152.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd152.nodeF j) (PRE_first_tail_x15_r0_body.kd152.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow152 PRE_first_tail_x15_r0_body.cnn1152 PRE_first_tail_x15_r0_body.fnordI152 PRE_first_tail_x15_r0_body.fnordK152 PRE_first_tail_x15_r0_body.fnordL152
kernel_rfl PRE_first_tail_x15_r0_body.fi152 : PRE_first_tail_x15_r0_body.cli152.all (pnB PRE_first_tail_x15_r0_body.cx0_152.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii152 : PRE_first_tail_x15_r0_body.cli152.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_152.mlx.items.get (PRE_first_tail_x15_r0_body.kappa152.node k) = (PRE_first_tail_x15_r0_body.cx0_152.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa152.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot152 (clean : Conv.NClean (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P152.NL) (cl : SSt (· < 6553) PRE_first_tail_x15_r0_body.cx0_152.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P152 6553 PRE_first_tail_x15_r0_body.kappa152 PRE_first_tail_x15_r0_body.kd152 PRE_first_tail_x15_r0_body.khinv152 PRE_first_tail_x15_r0_body.kninv152 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx PRE_first_tail_x15_r0_body.cx0_152.mlx PRE_first_tail_x15_r0_body.cx1_152.mlx (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo152 PRE_first_tail_x15_r0_body.cln152 PRE_first_tail_x15_r0_body.cli152 PRE_first_tail_x15_r0_body.cwS152 PRE_first_tail_x15_r0_body.cnS152 PRE_first_tail_x15_r0_body.ciS152 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0152, PRE_first_tail_x15_r0_body.cnh1152, PRE_first_tail_x15_r0_body.cnn0152, PRE_first_tail_x15_r0_body.cnn1152, PRE_first_tail_x15_r0_body.cplo152, PRE_first_tail_x15_r0_body.ccnt152, PRE_first_tail_x15_r0_body.cnband152, PRE_first_tail_x15_r0_body.chbelow152, PRE_first_tail_x15_r0_body.chren152, PRE_first_tail_x15_r0_body.cband152, PRE_first_tail_x15_r0_body.cnh1pos152, PRE_first_tail_x15_r0_body.cnren152, PRE_first_tail_x15_r0_body.cnlow152, PRE_first_tail_x15_r0_body.cabs0a152, PRE_first_tail_x15_r0_body.cabs0b152, PRE_first_tail_x15_r0_body.ctok1152, PRE_first_tail_x15_r0_body.cpend152, PRE_first_tail_x15_r0_body.cerrh152, PRE_first_tail_x15_r0_body.cfiles152, PRE_first_tail_x15_r0_body.carch152, PRE_first_tail_x15_r0_body.csizes152, PRE_first_tail_x15_r0_body.cwired152, PRE_first_tail_x15_r0_body.cfix152, clean, PRE_first_tail_x15_r0_body.fcxn152, PRE_first_tail_x15_r0_body.fcnn152, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0152, PRE_first_tail_x15_r0_body.fnk152, PRE_first_tail_x15_r0_body.ckA152, PRE_first_tail_x15_r0_body.cobjsK152, PRE_first_tail_x15_r0_body.cnodesK152, PRE_first_tail_x15_r0_body.citemsK152, PRE_first_tail_x15_r0_body.f1A152, PRE_first_tail_x15_r0_body.f1O152, PRE_first_tail_x15_r0_body.f1N152, PRE_first_tail_x15_r0_body.f1I152, PRE_first_tail_x15_r0_body.fbd152, PRE_first_tail_x15_r0_body.fincW152, PRE_first_tail_x15_r0_body.fincI152, PRE_first_tail_x15_r0_body.fincN152, PRE_first_tail_x15_r0_body.flnF152, PRE_first_tail_x15_r0_body.fh152, PRE_first_tail_x15_r0_body.fo152, PRE_first_tail_x15_r0_body.fok152, PRE_first_tail_x15_r0_body.fnd152, PRE_first_tail_x15_r0_body.fp152, PRE_first_tail_x15_r0_body.fnord152, PRE_first_tail_x15_r0_body.fi152, PRE_first_tail_x15_r0_body.fii152⟩
theorem PRE_first_tail_x15_r0_body.cnshift152 (clean : Conv.NClean (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P152.NL) (cl : SSt (· < 6553) PRE_first_tail_x15_r0_body.cx0_152.mlx) : NShift PRE_first_tail_x15_r0_body.P152 6553 PRE_first_tail_x15_r0_body.kappa152 PRE_first_tail_x15_r0_body.cx0_152 PRE_first_tail_x15_r0_body.cx1_152 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot152 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost152 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0152 PRE_first_tail_x15_r0_body.ckn1152 PRE_first_tail_x15_r0_body.ckheap152 PRE_first_tail_x15_r0_body.ckpl152)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_152 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1466.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_152 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1466.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_152 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1466.ffi) = some PRE_first_tail_x15_r0_body.fxC_152
kernel_rfl PRE_first_tail_x15_r0_body.okrC_152 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1466.ffi) = some PRE_first_tail_x15_r0_body.krC_152
noncomputable def PRE_first_tail_x15_r0_body.fx0_152 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1468.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_152 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1468.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_152 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1468.ffi) = some PRE_first_tail_x15_r0_body.fx0_152
kernel_rfl PRE_first_tail_x15_r0_body.okr0_152 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1468.ffi) = some PRE_first_tail_x15_r0_body.kr0_152
noncomputable def PRE_first_tail_x15_r0_body.fx1_152 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1467.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_152 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1467.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_152 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1467.ffi) = some PRE_first_tail_x15_r0_body.fx1_152
kernel_rfl PRE_first_tail_x15_r0_body.okr1_152 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1467.ffi) = some PRE_first_tail_x15_r0_body.kr1_152
kernel_rfl PRE_first_tail_x15_r0_body.ff0152 : PRE_first_tail_x15_r0_body.fx0_152 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_152 (PRE_first_tail_x15_r0_body.clo152.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_152.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1152 : PRE_first_tail_x15_r0_body.fx1_152 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_152 (PRE_first_tail_x15_r0_body.cwS152.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_152.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck152 : freedLB PRE_first_tail_x15_r0_body.kappa152 PRE_first_tail_x15_r0_body.cx0_152.mlx PRE_first_tail_x15_r0_body.fx0_152 PRE_first_tail_x15_r0_body.fx1_152 PRE_first_tail_x15_r0_body.clo152 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0152 : PRE_first_tail_x15_r0_body.kr0_152.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_152.flags (PRE_first_tail_x15_r0_body.clo152.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_152.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0152 : PRE_first_tail_x15_r0_body.kr0_152.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_152.targs (PRE_first_tail_x15_r0_body.clo152.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_152.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1152 : PRE_first_tail_x15_r0_body.kr1_152.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_152.flags (PRE_first_tail_x15_r0_body.cwS152.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_152.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1152 : PRE_first_tail_x15_r0_body.kr1_152.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_152.targs (PRE_first_tail_x15_r0_body.cwS152.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_152.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck152 : krecLB PRE_first_tail_x15_r0_body.kappa152 6553 PRE_first_tail_x15_r0_body.cx0_152.mlx PRE_first_tail_x15_r0_body.kr0_152 PRE_first_tail_x15_r0_body.kr1_152 PRE_first_tail_x15_r0_body.clo152 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn152 : Nat.ble 6553 6553 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge152 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1467.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1468.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR152 : pendRegB PRE_first_tail_x15_r0_body.kappa152 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1468.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe152 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1468.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1467.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift152 (clean : Conv.NClean (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P152.NL) (cl : SSt (· < 6553) PRE_first_tail_x15_r0_body.cx0_152.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_152.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_152.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_152.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_152.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P152 6553 PRE_first_tail_x15_r0_body.kappa152 PRE_first_tail_x15_r0_body.s1468.ffi PRE_first_tail_x15_r0_body.s1467.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift152 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue152, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp152 t ht),
    PRE_first_tail_x15_r0_body.cbridge152,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1468.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1467.ffi) (PRE_first_tail_x15_r0_body.cfoot152 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_152 PRE_first_tail_x15_r0_body.ofx1_152 hobjC PRE_first_tail_x15_r0_body.ff0152 PRE_first_tail_x15_r0_body.ff1152 PRE_first_tail_x15_r0_body.ffck152,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1468.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1467.ffi) (PRE_first_tail_x15_r0_body.cfoot152 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_152 PRE_first_tail_x15_r0_body.okr1_152 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn152) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0152 PRE_first_tail_x15_r0_body.fkt0152 PRE_first_tail_x15_r0_body.fkf1152 PRE_first_tail_x15_r0_body.fkt1152 PRE_first_tail_x15_r0_body.fkck152,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0152 PRE_first_tail_x15_r0_body.cnh1152 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe152) PRE_first_tail_x15_r0_body.cpendR152⟩

end Host.Load.Run.Tpl
