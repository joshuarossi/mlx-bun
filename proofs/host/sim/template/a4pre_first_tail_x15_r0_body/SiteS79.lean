import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl79
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 79 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc79 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P79 : LoadP := PRE_first_tail_x15_r0_body.Pc79.raise 16866
kernel_rfl PRE_first_tail_x15_r0_body.craise79 : Nat.ble PRE_first_tail_x15_r0_body.Pc79.N0 16866 = true
theorem PRE_first_tail_x15_r0_body.raised79 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc79 PRE_first_tail_x15_r0_body.P79 :=
  .inr ⟨16866, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise79, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_79 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_79 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s773.ffi)
def PRE_first_tail_x15_r0_body.khinv79 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv79 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS79 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS79 : List Nat := List.range' 16866 0
def PRE_first_tail_x15_r0_body.ciS79 : List Nat := [] ++ List.range' 16866 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh079 : PRE_first_tail_x15_r0_body.kd79.nh0 = PRE_first_tail_x15_r0_body.cx0_79.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh179 : PRE_first_tail_x15_r0_body.kd79.nh1 = PRE_first_tail_x15_r0_body.cx1_79.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn079 : PRE_first_tail_x15_r0_body.kd79.nn0 = PRE_first_tail_x15_r0_body.cx0_79.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn179 : PRE_first_tail_x15_r0_body.kd79.nn1 = PRE_first_tail_x15_r0_body.cx1_79.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo79 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P79.lo && Nat.ble PRE_first_tail_x15_r0_body.P79.lo PRE_first_tail_x15_r0_body.cx0_79.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P79.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P79.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt79 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_79.mlx.next PRE_first_tail_x15_r0_body.cx1_79.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_79.mlx.nnext PRE_first_tail_x15_r0_body.cx1_79.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband79 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P79.NL && Nat.ble PRE_first_tail_x15_r0_body.P79.NL PRE_first_tail_x15_r0_body.P79.N0 && Nat.ble PRE_first_tail_x15_r0_body.P79.N0 PRE_first_tail_x15_r0_body.cx0_79.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow79 : PRE_first_tail_x15_r0_body.kd79.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren79 : checkRenG PRE_first_tail_x15_r0_body.kd79.hnd PRE_first_tail_x15_r0_body.khinv79 (phB PRE_first_tail_x15_r0_body.cx0_79.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband79 : PRE_first_tail_x15_r0_body.kd79.checkBand PRE_first_tail_x15_r0_body.P79.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos79 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd79.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren79 : checkRenG PRE_first_tail_x15_r0_body.kd79.node PRE_first_tail_x15_r0_body.kninv79 (pnB PRE_first_tail_x15_r0_body.cx0_79.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow79 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd79.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P79.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd79.nodeF j) PRE_first_tail_x15_r0_body.cx1_79.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a79 : PRE_first_tail_x15_r0_body.cx0_79.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b79 : PRE_first_tail_x15_r0_body.cx0_79.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok179 : PRE_first_tail_x15_r0_body.cx1_79.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend79 : PRE_first_tail_x15_r0_body.cx1_79.mlx.pending = PRE_first_tail_x15_r0_body.cx0_79.mlx.pending.map PRE_first_tail_x15_r0_body.kappa79.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh79 : PRE_first_tail_x15_r0_body.cx1_79.mlx.errh = PRE_first_tail_x15_r0_body.cx0_79.mlx.errh.map PRE_first_tail_x15_r0_body.kappa79.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles79 : PRE_first_tail_x15_r0_body.cx1_79.mlx.files = PRE_first_tail_x15_r0_body.cx0_79.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch79 : PRE_first_tail_x15_r0_body.cx1_79.mlx.arch = PRE_first_tail_x15_r0_body.cx0_79.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes79 : PRE_first_tail_x15_r0_body.cx1_79.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_79.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired79 : PRE_first_tail_x15_r0_body.cx1_79.mlx.wired = PRE_first_tail_x15_r0_body.cx0_79.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost79 : PRE_first_tail_x15_r0_body.cx1_79.host = PRE_first_tail_x15_r0_body.cx0_79.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd79`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn079 : PRE_first_tail_x15_r0_body.kd79.n0 = 2736967
kernel_rfl PRE_first_tail_x15_r0_body.ckn179 : PRE_first_tail_x15_r0_body.kd79.n1 = 2736969
kernel_rfl PRE_first_tail_x15_r0_body.ckheap79 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd79.heap).all (fun x => Nat.ble 2736967 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl79 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd79.heap.get (2736967 + j) = nth? PRE_first_tail_x15_r0_body.pl79 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja79 : Nat.ble 2736967 2736967 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn79 : Nat.ble 3458 3458 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD79 : Nat.ble 2736967 PRE_first_tail_x15_r0_body.kd79.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn79 : Nat.ble 19762 PRE_first_tail_x15_r0_body.kd79.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn79 : Nat.ble 16866 PRE_first_tail_x15_r0_body.kd79.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb79 : Nat.ble 19762 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap79 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd79.heap).all (Nat.ble (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd79 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd79.hnd).all (Nat.ble (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode79 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd79.node).all (Nat.ble (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix79 : Conv.FixOld (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa79 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja79) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn79) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD79) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn79) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn79) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb79) PRE_first_tail_x15_r0_body.fheap79 PRE_first_tail_x15_r0_body.fhnd79 PRE_first_tail_x15_r0_body.fnode79
kernel_rfl PRE_first_tail_x15_r0_body.fcxn79 : (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn79 : (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle079 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_79.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_79.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk79 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd79.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A79 : PRE_first_tail_x15_r0_body.cx1_79.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS79.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_79.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O79 : PRE_first_tail_x15_r0_body.cx1_79.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS79.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_79.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N79 : PRE_first_tail_x15_r0_body.cx1_79.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS79.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_79.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I79 : PRE_first_tail_x15_r0_body.cx1_79.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS79.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_79.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd79 : (PRE_first_tail_x15_r0_body.clo79 ++ PRE_first_tail_x15_r0_body.cln79 ++ PRE_first_tail_x15_r0_body.cli79 ++ PRE_first_tail_x15_r0_body.cwS79 ++ PRE_first_tail_x15_r0_body.cnS79 ++ PRE_first_tail_x15_r0_body.ciS79).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW79 : PRE_first_tail_x15_r0_body.cwS79.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo79.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI79 : PRE_first_tail_x15_r0_body.ciS79.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli79.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN79 : PRE_first_tail_x15_r0_body.cnS79.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF79 : PRE_first_tail_x15_r0_body.cln79.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh79 : PRE_first_tail_x15_r0_body.clo79.all (handleOK PRE_first_tail_x15_r0_body.kappa79 PRE_first_tail_x15_r0_body.P79.lo PRE_first_tail_x15_r0_body.cx0_79.mlx PRE_first_tail_x15_r0_body.cx1_79.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo79 : PRE_first_tail_x15_r0_body.clo79.map (fun h => PRE_first_tail_x15_r0_body.cx1_79.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa79.handle h)) = PRE_first_tail_x15_r0_body.clo79.map (fun h => (PRE_first_tail_x15_r0_body.cx0_79.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa79.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok79 : PRE_first_tail_x15_r0_body.clo79.all (objOK PRE_first_tail_x15_r0_body.kappa79 PRE_first_tail_x15_r0_body.P79.NL PRE_first_tail_x15_r0_body.cx0_79.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd79 : PRE_first_tail_x15_r0_body.cln79.all (nodeOKF PRE_first_tail_x15_r0_body.kappa79 PRE_first_tail_x15_r0_body.P79 PRE_first_tail_x15_r0_body.cx0_79.mlx PRE_first_tail_x15_r0_body.cx1_79.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp79 : ((PRE_first_tail_x15_r0_body.cln79.filter (fullB PRE_first_tail_x15_r0_body.P79))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_79.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa79.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln79.filter (fullB PRE_first_tail_x15_r0_body.P79))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_79.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa79.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI79 : incrB PRE_first_tail_x15_r0_body.kd79.nodeF (List.range' 16866 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK79 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd79.node).all (fun k => Nat.ble 16866 k && Nat.blt k 16866) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL79 : (PRE_first_tail_x15_r0_body.cln79.filter (Nat.ble PRE_first_tail_x15_r0_body.P79.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd79.nodeF i) && (Nat.blt i 16866 || Nat.ble PRE_first_tail_x15_r0_body.kd79.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord79 : (PRE_first_tail_x15_r0_body.cln79.filter (Nat.ble PRE_first_tail_x15_r0_body.P79.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd79.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd79.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd79.nodeF j) (PRE_first_tail_x15_r0_body.kd79.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow79 PRE_first_tail_x15_r0_body.cnn179 PRE_first_tail_x15_r0_body.fnordI79 PRE_first_tail_x15_r0_body.fnordK79 PRE_first_tail_x15_r0_body.fnordL79
kernel_rfl PRE_first_tail_x15_r0_body.fi79 : PRE_first_tail_x15_r0_body.cli79.all (pnB PRE_first_tail_x15_r0_body.cx0_79.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii79 : PRE_first_tail_x15_r0_body.cli79.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_79.mlx.items.get (PRE_first_tail_x15_r0_body.kappa79.node k) = (PRE_first_tail_x15_r0_body.cx0_79.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa79.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot79 (clean : Conv.NClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P79.NL) (cl : SSt (· < 3458) PRE_first_tail_x15_r0_body.cx0_79.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P79 3458 PRE_first_tail_x15_r0_body.kappa79 PRE_first_tail_x15_r0_body.kd79 PRE_first_tail_x15_r0_body.khinv79 PRE_first_tail_x15_r0_body.kninv79 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx PRE_first_tail_x15_r0_body.cx0_79.mlx PRE_first_tail_x15_r0_body.cx1_79.mlx (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo79 PRE_first_tail_x15_r0_body.cln79 PRE_first_tail_x15_r0_body.cli79 PRE_first_tail_x15_r0_body.cwS79 PRE_first_tail_x15_r0_body.cnS79 PRE_first_tail_x15_r0_body.ciS79 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh079, PRE_first_tail_x15_r0_body.cnh179, PRE_first_tail_x15_r0_body.cnn079, PRE_first_tail_x15_r0_body.cnn179, PRE_first_tail_x15_r0_body.cplo79, PRE_first_tail_x15_r0_body.ccnt79, PRE_first_tail_x15_r0_body.cnband79, PRE_first_tail_x15_r0_body.chbelow79, PRE_first_tail_x15_r0_body.chren79, PRE_first_tail_x15_r0_body.cband79, PRE_first_tail_x15_r0_body.cnh1pos79, PRE_first_tail_x15_r0_body.cnren79, PRE_first_tail_x15_r0_body.cnlow79, PRE_first_tail_x15_r0_body.cabs0a79, PRE_first_tail_x15_r0_body.cabs0b79, PRE_first_tail_x15_r0_body.ctok179, PRE_first_tail_x15_r0_body.cpend79, PRE_first_tail_x15_r0_body.cerrh79, PRE_first_tail_x15_r0_body.cfiles79, PRE_first_tail_x15_r0_body.carch79, PRE_first_tail_x15_r0_body.csizes79, PRE_first_tail_x15_r0_body.cwired79, PRE_first_tail_x15_r0_body.cfix79, clean, PRE_first_tail_x15_r0_body.fcxn79, PRE_first_tail_x15_r0_body.fcnn79, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle079, PRE_first_tail_x15_r0_body.fnk79, PRE_first_tail_x15_r0_body.ckA79, PRE_first_tail_x15_r0_body.cobjsK79, PRE_first_tail_x15_r0_body.cnodesK79, PRE_first_tail_x15_r0_body.citemsK79, PRE_first_tail_x15_r0_body.f1A79, PRE_first_tail_x15_r0_body.f1O79, PRE_first_tail_x15_r0_body.f1N79, PRE_first_tail_x15_r0_body.f1I79, PRE_first_tail_x15_r0_body.fbd79, PRE_first_tail_x15_r0_body.fincW79, PRE_first_tail_x15_r0_body.fincI79, PRE_first_tail_x15_r0_body.fincN79, PRE_first_tail_x15_r0_body.flnF79, PRE_first_tail_x15_r0_body.fh79, PRE_first_tail_x15_r0_body.fo79, PRE_first_tail_x15_r0_body.fok79, PRE_first_tail_x15_r0_body.fnd79, PRE_first_tail_x15_r0_body.fp79, PRE_first_tail_x15_r0_body.fnord79, PRE_first_tail_x15_r0_body.fi79, PRE_first_tail_x15_r0_body.fii79⟩
theorem PRE_first_tail_x15_r0_body.cnshift79 (clean : Conv.NClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P79.NL) (cl : SSt (· < 3458) PRE_first_tail_x15_r0_body.cx0_79.mlx) : NShift PRE_first_tail_x15_r0_body.P79 3458 PRE_first_tail_x15_r0_body.kappa79 PRE_first_tail_x15_r0_body.cx0_79 PRE_first_tail_x15_r0_body.cx1_79 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot79 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost79 (compact_a_eq PRE_first_tail_x15_r0_body.ckn079 PRE_first_tail_x15_r0_body.ckn179 PRE_first_tail_x15_r0_body.ckheap79 PRE_first_tail_x15_r0_body.ckpl79)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_79 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s772.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_79 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s772.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_79 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s772.ffi) = some PRE_first_tail_x15_r0_body.fxC_79
kernel_rfl PRE_first_tail_x15_r0_body.okrC_79 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s772.ffi) = some PRE_first_tail_x15_r0_body.krC_79
noncomputable def PRE_first_tail_x15_r0_body.fx0_79 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s774.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_79 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s774.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_79 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s774.ffi) = some PRE_first_tail_x15_r0_body.fx0_79
kernel_rfl PRE_first_tail_x15_r0_body.okr0_79 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s774.ffi) = some PRE_first_tail_x15_r0_body.kr0_79
noncomputable def PRE_first_tail_x15_r0_body.fx1_79 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s773.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_79 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s773.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_79 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s773.ffi) = some PRE_first_tail_x15_r0_body.fx1_79
kernel_rfl PRE_first_tail_x15_r0_body.okr1_79 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s773.ffi) = some PRE_first_tail_x15_r0_body.kr1_79
kernel_rfl PRE_first_tail_x15_r0_body.ff079 : PRE_first_tail_x15_r0_body.fx0_79 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_79 (PRE_first_tail_x15_r0_body.clo79.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_79.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff179 : PRE_first_tail_x15_r0_body.fx1_79 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_79 (PRE_first_tail_x15_r0_body.cwS79.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_79.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck79 : freedLB PRE_first_tail_x15_r0_body.kappa79 PRE_first_tail_x15_r0_body.cx0_79.mlx PRE_first_tail_x15_r0_body.fx0_79 PRE_first_tail_x15_r0_body.fx1_79 PRE_first_tail_x15_r0_body.clo79 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf079 : PRE_first_tail_x15_r0_body.kr0_79.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_79.flags (PRE_first_tail_x15_r0_body.clo79.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_79.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt079 : PRE_first_tail_x15_r0_body.kr0_79.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_79.targs (PRE_first_tail_x15_r0_body.clo79.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_79.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf179 : PRE_first_tail_x15_r0_body.kr1_79.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_79.flags (PRE_first_tail_x15_r0_body.cwS79.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_79.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt179 : PRE_first_tail_x15_r0_body.kr1_79.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_79.targs (PRE_first_tail_x15_r0_body.cwS79.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_79.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck79 : krecLB PRE_first_tail_x15_r0_body.kappa79 3458 PRE_first_tail_x15_r0_body.cx0_79.mlx PRE_first_tail_x15_r0_body.kr0_79 PRE_first_tail_x15_r0_body.kr1_79 PRE_first_tail_x15_r0_body.clo79 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn79 : Nat.ble 3458 3458 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge79 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s773.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s774.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR79 : pendRegB PRE_first_tail_x15_r0_body.kappa79 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe79 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s773.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift79 (clean : Conv.NClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P79.NL) (cl : SSt (· < 3458) PRE_first_tail_x15_r0_body.cx0_79.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_79.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_79.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_79.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_79.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P79 3458 PRE_first_tail_x15_r0_body.kappa79 PRE_first_tail_x15_r0_body.s774.ffi PRE_first_tail_x15_r0_body.s773.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift79 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue79, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp79 t ht),
    PRE_first_tail_x15_r0_body.cbridge79,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s774.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s773.ffi) (PRE_first_tail_x15_r0_body.cfoot79 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_79 PRE_first_tail_x15_r0_body.ofx1_79 hobjC PRE_first_tail_x15_r0_body.ff079 PRE_first_tail_x15_r0_body.ff179 PRE_first_tail_x15_r0_body.ffck79,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s774.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s773.ffi) (PRE_first_tail_x15_r0_body.cfoot79 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_79 PRE_first_tail_x15_r0_body.okr1_79 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn79) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf079 PRE_first_tail_x15_r0_body.fkt079 PRE_first_tail_x15_r0_body.fkf179 PRE_first_tail_x15_r0_body.fkt179 PRE_first_tail_x15_r0_body.fkck79,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh079 PRE_first_tail_x15_r0_body.cnh179 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe79) PRE_first_tail_x15_r0_body.cpendR79⟩

end Host.Load.Run.Tpl
