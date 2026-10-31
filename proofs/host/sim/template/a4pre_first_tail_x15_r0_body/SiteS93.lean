import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl93
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 93 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc93 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P93 : LoadP := PRE_first_tail_x15_r0_body.Pc93.raise 17141
kernel_rfl PRE_first_tail_x15_r0_body.craise93 : Nat.ble PRE_first_tail_x15_r0_body.Pc93.N0 17141 = true
theorem PRE_first_tail_x15_r0_body.raised93 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc93 PRE_first_tail_x15_r0_body.P93 :=
  .inr ⟨17141, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise93, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_93 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_93 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s908.ffi)
def PRE_first_tail_x15_r0_body.khinv93 : PTrie Nat := Stage.setAll PTrie.nil [(20047, 20045), (20048, 20046), (20050, 20047), (20049, 20048)]
def PRE_first_tail_x15_r0_body.kninv93 : PTrie Nat := Stage.setAll PTrie.nil [(17135, 17135), (17136, 17136), (17137, 17137), (17138, 17138), (17139, 17139), (17140, 17140)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS93 : List Nat := [20045, 20046, 20047, 20048, 20049, 20050]
def PRE_first_tail_x15_r0_body.cnS93 : List Nat := List.range' 17135 6
def PRE_first_tail_x15_r0_body.ciS93 : List Nat := [] ++ List.range' 17135 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh093 : PRE_first_tail_x15_r0_body.kd93.nh0 = PRE_first_tail_x15_r0_body.cx0_93.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh193 : PRE_first_tail_x15_r0_body.kd93.nh1 = PRE_first_tail_x15_r0_body.cx1_93.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn093 : PRE_first_tail_x15_r0_body.kd93.nn0 = PRE_first_tail_x15_r0_body.cx0_93.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn193 : PRE_first_tail_x15_r0_body.kd93.nn1 = PRE_first_tail_x15_r0_body.cx1_93.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo93 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P93.lo && Nat.ble PRE_first_tail_x15_r0_body.P93.lo PRE_first_tail_x15_r0_body.cx0_93.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P93.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P93.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt93 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_93.mlx.next PRE_first_tail_x15_r0_body.cx1_93.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_93.mlx.nnext PRE_first_tail_x15_r0_body.cx1_93.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband93 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P93.NL && Nat.ble PRE_first_tail_x15_r0_body.P93.NL PRE_first_tail_x15_r0_body.P93.N0 && Nat.ble PRE_first_tail_x15_r0_body.P93.N0 PRE_first_tail_x15_r0_body.cx0_93.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow93 : PRE_first_tail_x15_r0_body.kd93.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren93 : checkRenG PRE_first_tail_x15_r0_body.kd93.hnd PRE_first_tail_x15_r0_body.khinv93 (phB PRE_first_tail_x15_r0_body.cx0_93.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband93 : PRE_first_tail_x15_r0_body.kd93.checkBand PRE_first_tail_x15_r0_body.P93.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos93 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd93.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren93 : checkRenG PRE_first_tail_x15_r0_body.kd93.node PRE_first_tail_x15_r0_body.kninv93 (pnB PRE_first_tail_x15_r0_body.cx0_93.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow93 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd93.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P93.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd93.nodeF j) PRE_first_tail_x15_r0_body.cx1_93.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a93 : PRE_first_tail_x15_r0_body.cx0_93.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b93 : PRE_first_tail_x15_r0_body.cx0_93.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok193 : PRE_first_tail_x15_r0_body.cx1_93.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend93 : PRE_first_tail_x15_r0_body.cx1_93.mlx.pending = PRE_first_tail_x15_r0_body.cx0_93.mlx.pending.map PRE_first_tail_x15_r0_body.kappa93.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh93 : PRE_first_tail_x15_r0_body.cx1_93.mlx.errh = PRE_first_tail_x15_r0_body.cx0_93.mlx.errh.map PRE_first_tail_x15_r0_body.kappa93.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles93 : PRE_first_tail_x15_r0_body.cx1_93.mlx.files = PRE_first_tail_x15_r0_body.cx0_93.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch93 : PRE_first_tail_x15_r0_body.cx1_93.mlx.arch = PRE_first_tail_x15_r0_body.cx0_93.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes93 : PRE_first_tail_x15_r0_body.cx1_93.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_93.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired93 : PRE_first_tail_x15_r0_body.cx1_93.mlx.wired = PRE_first_tail_x15_r0_body.cx0_93.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost93 : PRE_first_tail_x15_r0_body.cx1_93.host = PRE_first_tail_x15_r0_body.cx0_93.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd93`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn093 : PRE_first_tail_x15_r0_body.kd93.n0 = 2748423
kernel_rfl PRE_first_tail_x15_r0_body.ckn193 : PRE_first_tail_x15_r0_body.kd93.n1 = 2748773
kernel_rfl PRE_first_tail_x15_r0_body.ckheap93 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd93.heap).all (fun x => Nat.ble 2748408 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl93 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd93.heap.get (2748408 + j) = nth? PRE_first_tail_x15_r0_body.pl93 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja93 : Nat.ble 2748408 2748408 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn93 : Nat.ble 4065 4065 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD93 : Nat.ble 2748408 PRE_first_tail_x15_r0_body.kd93.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn93 : Nat.ble 20045 PRE_first_tail_x15_r0_body.kd93.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn93 : Nat.ble 17135 PRE_first_tail_x15_r0_body.kd93.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb93 : Nat.ble 20045 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap93 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd93.heap).all (Nat.ble (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd93 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd93.hnd).all (Nat.ble (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode93 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd93.node).all (Nat.ble (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix93 : Conv.FixOld (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa93 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja93) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn93) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD93) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn93) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn93) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb93) PRE_first_tail_x15_r0_body.fheap93 PRE_first_tail_x15_r0_body.fhnd93 PRE_first_tail_x15_r0_body.fnode93
kernel_rfl PRE_first_tail_x15_r0_body.fcxn93 : (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn93 : (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle093 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_93.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_93.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk93 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd93.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A93 : PRE_first_tail_x15_r0_body.cx1_93.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS93.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_93.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O93 : PRE_first_tail_x15_r0_body.cx1_93.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS93.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_93.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N93 : PRE_first_tail_x15_r0_body.cx1_93.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS93.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_93.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I93 : PRE_first_tail_x15_r0_body.cx1_93.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS93.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_93.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd93 : (PRE_first_tail_x15_r0_body.clo93 ++ PRE_first_tail_x15_r0_body.cln93 ++ PRE_first_tail_x15_r0_body.cli93 ++ PRE_first_tail_x15_r0_body.cwS93 ++ PRE_first_tail_x15_r0_body.cnS93 ++ PRE_first_tail_x15_r0_body.ciS93).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW93 : PRE_first_tail_x15_r0_body.cwS93.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo93.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI93 : PRE_first_tail_x15_r0_body.ciS93.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli93.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN93 : PRE_first_tail_x15_r0_body.cnS93.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF93 : PRE_first_tail_x15_r0_body.cln93.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh93 : PRE_first_tail_x15_r0_body.clo93.all (handleOK PRE_first_tail_x15_r0_body.kappa93 PRE_first_tail_x15_r0_body.P93.lo PRE_first_tail_x15_r0_body.cx0_93.mlx PRE_first_tail_x15_r0_body.cx1_93.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo93 : PRE_first_tail_x15_r0_body.clo93.map (fun h => PRE_first_tail_x15_r0_body.cx1_93.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa93.handle h)) = PRE_first_tail_x15_r0_body.clo93.map (fun h => (PRE_first_tail_x15_r0_body.cx0_93.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa93.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok93 : PRE_first_tail_x15_r0_body.clo93.all (objOK PRE_first_tail_x15_r0_body.kappa93 PRE_first_tail_x15_r0_body.P93.NL PRE_first_tail_x15_r0_body.cx0_93.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd93 : PRE_first_tail_x15_r0_body.cln93.all (nodeOKF PRE_first_tail_x15_r0_body.kappa93 PRE_first_tail_x15_r0_body.P93 PRE_first_tail_x15_r0_body.cx0_93.mlx PRE_first_tail_x15_r0_body.cx1_93.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp93 : ((PRE_first_tail_x15_r0_body.cln93.filter (fullB PRE_first_tail_x15_r0_body.P93))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_93.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa93.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln93.filter (fullB PRE_first_tail_x15_r0_body.P93))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_93.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa93.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI93 : incrB PRE_first_tail_x15_r0_body.kd93.nodeF (List.range' 17135 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK93 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd93.node).all (fun k => Nat.ble 17135 k && Nat.blt k 17141) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL93 : (PRE_first_tail_x15_r0_body.cln93.filter (Nat.ble PRE_first_tail_x15_r0_body.P93.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd93.nodeF i) && (Nat.blt i 17141 || Nat.ble PRE_first_tail_x15_r0_body.kd93.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord93 : (PRE_first_tail_x15_r0_body.cln93.filter (Nat.ble PRE_first_tail_x15_r0_body.P93.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd93.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd93.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd93.nodeF j) (PRE_first_tail_x15_r0_body.kd93.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow93 PRE_first_tail_x15_r0_body.cnn193 PRE_first_tail_x15_r0_body.fnordI93 PRE_first_tail_x15_r0_body.fnordK93 PRE_first_tail_x15_r0_body.fnordL93
kernel_rfl PRE_first_tail_x15_r0_body.fi93 : PRE_first_tail_x15_r0_body.cli93.all (pnB PRE_first_tail_x15_r0_body.cx0_93.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii93 : PRE_first_tail_x15_r0_body.cli93.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_93.mlx.items.get (PRE_first_tail_x15_r0_body.kappa93.node k) = (PRE_first_tail_x15_r0_body.cx0_93.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa93.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot93 (clean : Conv.NClean (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P93.NL) (cl : SSt (· < 4074) PRE_first_tail_x15_r0_body.cx0_93.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P93 4074 PRE_first_tail_x15_r0_body.kappa93 PRE_first_tail_x15_r0_body.kd93 PRE_first_tail_x15_r0_body.khinv93 PRE_first_tail_x15_r0_body.kninv93 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx PRE_first_tail_x15_r0_body.cx0_93.mlx PRE_first_tail_x15_r0_body.cx1_93.mlx (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo93 PRE_first_tail_x15_r0_body.cln93 PRE_first_tail_x15_r0_body.cli93 PRE_first_tail_x15_r0_body.cwS93 PRE_first_tail_x15_r0_body.cnS93 PRE_first_tail_x15_r0_body.ciS93 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh093, PRE_first_tail_x15_r0_body.cnh193, PRE_first_tail_x15_r0_body.cnn093, PRE_first_tail_x15_r0_body.cnn193, PRE_first_tail_x15_r0_body.cplo93, PRE_first_tail_x15_r0_body.ccnt93, PRE_first_tail_x15_r0_body.cnband93, PRE_first_tail_x15_r0_body.chbelow93, PRE_first_tail_x15_r0_body.chren93, PRE_first_tail_x15_r0_body.cband93, PRE_first_tail_x15_r0_body.cnh1pos93, PRE_first_tail_x15_r0_body.cnren93, PRE_first_tail_x15_r0_body.cnlow93, PRE_first_tail_x15_r0_body.cabs0a93, PRE_first_tail_x15_r0_body.cabs0b93, PRE_first_tail_x15_r0_body.ctok193, PRE_first_tail_x15_r0_body.cpend93, PRE_first_tail_x15_r0_body.cerrh93, PRE_first_tail_x15_r0_body.cfiles93, PRE_first_tail_x15_r0_body.carch93, PRE_first_tail_x15_r0_body.csizes93, PRE_first_tail_x15_r0_body.cwired93, PRE_first_tail_x15_r0_body.cfix93, clean, PRE_first_tail_x15_r0_body.fcxn93, PRE_first_tail_x15_r0_body.fcnn93, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle093, PRE_first_tail_x15_r0_body.fnk93, PRE_first_tail_x15_r0_body.ckA93, PRE_first_tail_x15_r0_body.cobjsK93, PRE_first_tail_x15_r0_body.cnodesK93, PRE_first_tail_x15_r0_body.citemsK93, PRE_first_tail_x15_r0_body.f1A93, PRE_first_tail_x15_r0_body.f1O93, PRE_first_tail_x15_r0_body.f1N93, PRE_first_tail_x15_r0_body.f1I93, PRE_first_tail_x15_r0_body.fbd93, PRE_first_tail_x15_r0_body.fincW93, PRE_first_tail_x15_r0_body.fincI93, PRE_first_tail_x15_r0_body.fincN93, PRE_first_tail_x15_r0_body.flnF93, PRE_first_tail_x15_r0_body.fh93, PRE_first_tail_x15_r0_body.fo93, PRE_first_tail_x15_r0_body.fok93, PRE_first_tail_x15_r0_body.fnd93, PRE_first_tail_x15_r0_body.fp93, PRE_first_tail_x15_r0_body.fnord93, PRE_first_tail_x15_r0_body.fi93, PRE_first_tail_x15_r0_body.fii93⟩
theorem PRE_first_tail_x15_r0_body.cnshift93 (clean : Conv.NClean (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P93.NL) (cl : SSt (· < 4074) PRE_first_tail_x15_r0_body.cx0_93.mlx) : NShift PRE_first_tail_x15_r0_body.P93 4074 PRE_first_tail_x15_r0_body.kappa93 PRE_first_tail_x15_r0_body.cx0_93 PRE_first_tail_x15_r0_body.cx1_93 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot93 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost93 (compact_a_eq PRE_first_tail_x15_r0_body.ckn093 PRE_first_tail_x15_r0_body.ckn193 PRE_first_tail_x15_r0_body.ckheap93 PRE_first_tail_x15_r0_body.ckpl93)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_93 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s907.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_93 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s907.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_93 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s907.ffi) = some PRE_first_tail_x15_r0_body.fxC_93
kernel_rfl PRE_first_tail_x15_r0_body.okrC_93 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s907.ffi) = some PRE_first_tail_x15_r0_body.krC_93
noncomputable def PRE_first_tail_x15_r0_body.fx0_93 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s909.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_93 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s909.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_93 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s909.ffi) = some PRE_first_tail_x15_r0_body.fx0_93
kernel_rfl PRE_first_tail_x15_r0_body.okr0_93 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s909.ffi) = some PRE_first_tail_x15_r0_body.kr0_93
noncomputable def PRE_first_tail_x15_r0_body.fx1_93 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s908.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_93 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s908.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_93 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s908.ffi) = some PRE_first_tail_x15_r0_body.fx1_93
kernel_rfl PRE_first_tail_x15_r0_body.okr1_93 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s908.ffi) = some PRE_first_tail_x15_r0_body.kr1_93
kernel_rfl PRE_first_tail_x15_r0_body.ff093 : PRE_first_tail_x15_r0_body.fx0_93 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_93 (PRE_first_tail_x15_r0_body.clo93.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_93.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff193 : PRE_first_tail_x15_r0_body.fx1_93 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_93 (PRE_first_tail_x15_r0_body.cwS93.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_93.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck93 : freedLB PRE_first_tail_x15_r0_body.kappa93 PRE_first_tail_x15_r0_body.cx0_93.mlx PRE_first_tail_x15_r0_body.fx0_93 PRE_first_tail_x15_r0_body.fx1_93 PRE_first_tail_x15_r0_body.clo93 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf093 : PRE_first_tail_x15_r0_body.kr0_93.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_93.flags (PRE_first_tail_x15_r0_body.clo93.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_93.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt093 : PRE_first_tail_x15_r0_body.kr0_93.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_93.targs (PRE_first_tail_x15_r0_body.clo93.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_93.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf193 : PRE_first_tail_x15_r0_body.kr1_93.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_93.flags (PRE_first_tail_x15_r0_body.cwS93.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_93.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt193 : PRE_first_tail_x15_r0_body.kr1_93.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_93.targs (PRE_first_tail_x15_r0_body.cwS93.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_93.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck93 : krecLB PRE_first_tail_x15_r0_body.kappa93 4074 PRE_first_tail_x15_r0_body.cx0_93.mlx PRE_first_tail_x15_r0_body.kr0_93 PRE_first_tail_x15_r0_body.kr1_93 PRE_first_tail_x15_r0_body.clo93 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn93 : Nat.ble 4065 4074 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge93 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s908.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s909.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR93 : pendRegB PRE_first_tail_x15_r0_body.kappa93 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe93 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s908.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift93 (clean : Conv.NClean (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P93.NL) (cl : SSt (· < 4074) PRE_first_tail_x15_r0_body.cx0_93.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_93.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_93.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_93.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_93.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P93 4074 PRE_first_tail_x15_r0_body.kappa93 PRE_first_tail_x15_r0_body.s909.ffi PRE_first_tail_x15_r0_body.s908.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift93 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue93, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp93 t ht),
    PRE_first_tail_x15_r0_body.cbridge93,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s909.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s908.ffi) (PRE_first_tail_x15_r0_body.cfoot93 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_93 PRE_first_tail_x15_r0_body.ofx1_93 hobjC PRE_first_tail_x15_r0_body.ff093 PRE_first_tail_x15_r0_body.ff193 PRE_first_tail_x15_r0_body.ffck93,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s909.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s908.ffi) (PRE_first_tail_x15_r0_body.cfoot93 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_93 PRE_first_tail_x15_r0_body.okr1_93 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn93) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf093 PRE_first_tail_x15_r0_body.fkt093 PRE_first_tail_x15_r0_body.fkf193 PRE_first_tail_x15_r0_body.fkt193 PRE_first_tail_x15_r0_body.fkck93,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh093 PRE_first_tail_x15_r0_body.cnh193 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe93) PRE_first_tail_x15_r0_body.cpendR93⟩

end Host.Load.Run.Tpl
