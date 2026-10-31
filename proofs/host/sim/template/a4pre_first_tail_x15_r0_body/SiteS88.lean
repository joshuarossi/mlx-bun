import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl88
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 88 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc88 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P88 : LoadP := PRE_first_tail_x15_r0_body.Pc88.raise 17040
kernel_rfl PRE_first_tail_x15_r0_body.craise88 : Nat.ble PRE_first_tail_x15_r0_body.Pc88.N0 17040 = true
theorem PRE_first_tail_x15_r0_body.raised88 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc88 PRE_first_tail_x15_r0_body.P88 :=
  .inr ⟨17040, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise88, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_88 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s860.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_88 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s859.ffi)
def PRE_first_tail_x15_r0_body.khinv88 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv88 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS88 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS88 : List Nat := List.range' 17040 0
def PRE_first_tail_x15_r0_body.ciS88 : List Nat := [] ++ List.range' 17040 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh088 : PRE_first_tail_x15_r0_body.kd88.nh0 = PRE_first_tail_x15_r0_body.cx0_88.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh188 : PRE_first_tail_x15_r0_body.kd88.nh1 = PRE_first_tail_x15_r0_body.cx1_88.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn088 : PRE_first_tail_x15_r0_body.kd88.nn0 = PRE_first_tail_x15_r0_body.cx0_88.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn188 : PRE_first_tail_x15_r0_body.kd88.nn1 = PRE_first_tail_x15_r0_body.cx1_88.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo88 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P88.lo && Nat.ble PRE_first_tail_x15_r0_body.P88.lo PRE_first_tail_x15_r0_body.cx0_88.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P88.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P88.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt88 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_88.mlx.next PRE_first_tail_x15_r0_body.cx1_88.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_88.mlx.nnext PRE_first_tail_x15_r0_body.cx1_88.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband88 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P88.NL && Nat.ble PRE_first_tail_x15_r0_body.P88.NL PRE_first_tail_x15_r0_body.P88.N0 && Nat.ble PRE_first_tail_x15_r0_body.P88.N0 PRE_first_tail_x15_r0_body.cx0_88.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow88 : PRE_first_tail_x15_r0_body.kd88.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren88 : checkRenG PRE_first_tail_x15_r0_body.kd88.hnd PRE_first_tail_x15_r0_body.khinv88 (phB PRE_first_tail_x15_r0_body.cx0_88.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband88 : PRE_first_tail_x15_r0_body.kd88.checkBand PRE_first_tail_x15_r0_body.P88.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos88 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd88.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren88 : checkRenG PRE_first_tail_x15_r0_body.kd88.node PRE_first_tail_x15_r0_body.kninv88 (pnB PRE_first_tail_x15_r0_body.cx0_88.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow88 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd88.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P88.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd88.nodeF j) PRE_first_tail_x15_r0_body.cx1_88.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a88 : PRE_first_tail_x15_r0_body.cx0_88.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b88 : PRE_first_tail_x15_r0_body.cx0_88.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok188 : PRE_first_tail_x15_r0_body.cx1_88.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend88 : PRE_first_tail_x15_r0_body.cx1_88.mlx.pending = PRE_first_tail_x15_r0_body.cx0_88.mlx.pending.map PRE_first_tail_x15_r0_body.kappa88.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh88 : PRE_first_tail_x15_r0_body.cx1_88.mlx.errh = PRE_first_tail_x15_r0_body.cx0_88.mlx.errh.map PRE_first_tail_x15_r0_body.kappa88.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles88 : PRE_first_tail_x15_r0_body.cx1_88.mlx.files = PRE_first_tail_x15_r0_body.cx0_88.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch88 : PRE_first_tail_x15_r0_body.cx1_88.mlx.arch = PRE_first_tail_x15_r0_body.cx0_88.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes88 : PRE_first_tail_x15_r0_body.cx1_88.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_88.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired88 : PRE_first_tail_x15_r0_body.cx1_88.mlx.wired = PRE_first_tail_x15_r0_body.cx0_88.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost88 : PRE_first_tail_x15_r0_body.cx1_88.host = PRE_first_tail_x15_r0_body.cx0_88.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd88`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn088 : PRE_first_tail_x15_r0_body.kd88.n0 = 2744123
kernel_rfl PRE_first_tail_x15_r0_body.ckn188 : PRE_first_tail_x15_r0_body.kd88.n1 = 2744125
kernel_rfl PRE_first_tail_x15_r0_body.ckheap88 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd88.heap).all (fun x => Nat.ble 2744123 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl88 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd88.heap.get (2744123 + j) = nth? PRE_first_tail_x15_r0_body.pl88 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja88 : Nat.ble 2744123 2744123 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn88 : Nat.ble 3842 3842 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD88 : Nat.ble 2744123 PRE_first_tail_x15_r0_body.kd88.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn88 : Nat.ble 19941 PRE_first_tail_x15_r0_body.kd88.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn88 : Nat.ble 17040 PRE_first_tail_x15_r0_body.kd88.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb88 : Nat.ble 19941 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap88 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd88.heap).all (Nat.ble (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd88 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd88.hnd).all (Nat.ble (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode88 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd88.node).all (Nat.ble (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix88 : Conv.FixOld (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa88 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja88) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn88) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD88) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn88) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn88) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb88) PRE_first_tail_x15_r0_body.fheap88 PRE_first_tail_x15_r0_body.fhnd88 PRE_first_tail_x15_r0_body.fnode88
kernel_rfl PRE_first_tail_x15_r0_body.fcxn88 : (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn88 : (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle088 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_88.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_88.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk88 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd88.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A88 : PRE_first_tail_x15_r0_body.cx1_88.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS88.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_88.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O88 : PRE_first_tail_x15_r0_body.cx1_88.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS88.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_88.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N88 : PRE_first_tail_x15_r0_body.cx1_88.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS88.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_88.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I88 : PRE_first_tail_x15_r0_body.cx1_88.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS88.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_88.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd88 : (PRE_first_tail_x15_r0_body.clo88 ++ PRE_first_tail_x15_r0_body.cln88 ++ PRE_first_tail_x15_r0_body.cli88 ++ PRE_first_tail_x15_r0_body.cwS88 ++ PRE_first_tail_x15_r0_body.cnS88 ++ PRE_first_tail_x15_r0_body.ciS88).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW88 : PRE_first_tail_x15_r0_body.cwS88.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo88.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI88 : PRE_first_tail_x15_r0_body.ciS88.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli88.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN88 : PRE_first_tail_x15_r0_body.cnS88.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF88 : PRE_first_tail_x15_r0_body.cln88.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh88 : PRE_first_tail_x15_r0_body.clo88.all (handleOK PRE_first_tail_x15_r0_body.kappa88 PRE_first_tail_x15_r0_body.P88.lo PRE_first_tail_x15_r0_body.cx0_88.mlx PRE_first_tail_x15_r0_body.cx1_88.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo88 : PRE_first_tail_x15_r0_body.clo88.map (fun h => PRE_first_tail_x15_r0_body.cx1_88.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa88.handle h)) = PRE_first_tail_x15_r0_body.clo88.map (fun h => (PRE_first_tail_x15_r0_body.cx0_88.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa88.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok88 : PRE_first_tail_x15_r0_body.clo88.all (objOK PRE_first_tail_x15_r0_body.kappa88 PRE_first_tail_x15_r0_body.P88.NL PRE_first_tail_x15_r0_body.cx0_88.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd88 : PRE_first_tail_x15_r0_body.cln88.all (nodeOKF PRE_first_tail_x15_r0_body.kappa88 PRE_first_tail_x15_r0_body.P88 PRE_first_tail_x15_r0_body.cx0_88.mlx PRE_first_tail_x15_r0_body.cx1_88.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp88 : ((PRE_first_tail_x15_r0_body.cln88.filter (fullB PRE_first_tail_x15_r0_body.P88))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_88.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa88.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln88.filter (fullB PRE_first_tail_x15_r0_body.P88))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_88.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa88.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI88 : incrB PRE_first_tail_x15_r0_body.kd88.nodeF (List.range' 17040 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK88 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd88.node).all (fun k => Nat.ble 17040 k && Nat.blt k 17040) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL88 : (PRE_first_tail_x15_r0_body.cln88.filter (Nat.ble PRE_first_tail_x15_r0_body.P88.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd88.nodeF i) && (Nat.blt i 17040 || Nat.ble PRE_first_tail_x15_r0_body.kd88.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord88 : (PRE_first_tail_x15_r0_body.cln88.filter (Nat.ble PRE_first_tail_x15_r0_body.P88.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd88.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd88.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd88.nodeF j) (PRE_first_tail_x15_r0_body.kd88.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow88 PRE_first_tail_x15_r0_body.cnn188 PRE_first_tail_x15_r0_body.fnordI88 PRE_first_tail_x15_r0_body.fnordK88 PRE_first_tail_x15_r0_body.fnordL88
kernel_rfl PRE_first_tail_x15_r0_body.fi88 : PRE_first_tail_x15_r0_body.cli88.all (pnB PRE_first_tail_x15_r0_body.cx0_88.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii88 : PRE_first_tail_x15_r0_body.cli88.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_88.mlx.items.get (PRE_first_tail_x15_r0_body.kappa88.node k) = (PRE_first_tail_x15_r0_body.cx0_88.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa88.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot88 (clean : Conv.NClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P88.NL) (cl : SSt (· < 3842) PRE_first_tail_x15_r0_body.cx0_88.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P88 3842 PRE_first_tail_x15_r0_body.kappa88 PRE_first_tail_x15_r0_body.kd88 PRE_first_tail_x15_r0_body.khinv88 PRE_first_tail_x15_r0_body.kninv88 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx PRE_first_tail_x15_r0_body.cx0_88.mlx PRE_first_tail_x15_r0_body.cx1_88.mlx (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo88 PRE_first_tail_x15_r0_body.cln88 PRE_first_tail_x15_r0_body.cli88 PRE_first_tail_x15_r0_body.cwS88 PRE_first_tail_x15_r0_body.cnS88 PRE_first_tail_x15_r0_body.ciS88 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh088, PRE_first_tail_x15_r0_body.cnh188, PRE_first_tail_x15_r0_body.cnn088, PRE_first_tail_x15_r0_body.cnn188, PRE_first_tail_x15_r0_body.cplo88, PRE_first_tail_x15_r0_body.ccnt88, PRE_first_tail_x15_r0_body.cnband88, PRE_first_tail_x15_r0_body.chbelow88, PRE_first_tail_x15_r0_body.chren88, PRE_first_tail_x15_r0_body.cband88, PRE_first_tail_x15_r0_body.cnh1pos88, PRE_first_tail_x15_r0_body.cnren88, PRE_first_tail_x15_r0_body.cnlow88, PRE_first_tail_x15_r0_body.cabs0a88, PRE_first_tail_x15_r0_body.cabs0b88, PRE_first_tail_x15_r0_body.ctok188, PRE_first_tail_x15_r0_body.cpend88, PRE_first_tail_x15_r0_body.cerrh88, PRE_first_tail_x15_r0_body.cfiles88, PRE_first_tail_x15_r0_body.carch88, PRE_first_tail_x15_r0_body.csizes88, PRE_first_tail_x15_r0_body.cwired88, PRE_first_tail_x15_r0_body.cfix88, clean, PRE_first_tail_x15_r0_body.fcxn88, PRE_first_tail_x15_r0_body.fcnn88, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle088, PRE_first_tail_x15_r0_body.fnk88, PRE_first_tail_x15_r0_body.ckA88, PRE_first_tail_x15_r0_body.cobjsK88, PRE_first_tail_x15_r0_body.cnodesK88, PRE_first_tail_x15_r0_body.citemsK88, PRE_first_tail_x15_r0_body.f1A88, PRE_first_tail_x15_r0_body.f1O88, PRE_first_tail_x15_r0_body.f1N88, PRE_first_tail_x15_r0_body.f1I88, PRE_first_tail_x15_r0_body.fbd88, PRE_first_tail_x15_r0_body.fincW88, PRE_first_tail_x15_r0_body.fincI88, PRE_first_tail_x15_r0_body.fincN88, PRE_first_tail_x15_r0_body.flnF88, PRE_first_tail_x15_r0_body.fh88, PRE_first_tail_x15_r0_body.fo88, PRE_first_tail_x15_r0_body.fok88, PRE_first_tail_x15_r0_body.fnd88, PRE_first_tail_x15_r0_body.fp88, PRE_first_tail_x15_r0_body.fnord88, PRE_first_tail_x15_r0_body.fi88, PRE_first_tail_x15_r0_body.fii88⟩
theorem PRE_first_tail_x15_r0_body.cnshift88 (clean : Conv.NClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P88.NL) (cl : SSt (· < 3842) PRE_first_tail_x15_r0_body.cx0_88.mlx) : NShift PRE_first_tail_x15_r0_body.P88 3842 PRE_first_tail_x15_r0_body.kappa88 PRE_first_tail_x15_r0_body.cx0_88 PRE_first_tail_x15_r0_body.cx1_88 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot88 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost88 (compact_a_eq PRE_first_tail_x15_r0_body.ckn088 PRE_first_tail_x15_r0_body.ckn188 PRE_first_tail_x15_r0_body.ckheap88 PRE_first_tail_x15_r0_body.ckpl88)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_88 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s858.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_88 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s858.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_88 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s858.ffi) = some PRE_first_tail_x15_r0_body.fxC_88
kernel_rfl PRE_first_tail_x15_r0_body.okrC_88 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s858.ffi) = some PRE_first_tail_x15_r0_body.krC_88
noncomputable def PRE_first_tail_x15_r0_body.fx0_88 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s860.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_88 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s860.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_88 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s860.ffi) = some PRE_first_tail_x15_r0_body.fx0_88
kernel_rfl PRE_first_tail_x15_r0_body.okr0_88 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s860.ffi) = some PRE_first_tail_x15_r0_body.kr0_88
noncomputable def PRE_first_tail_x15_r0_body.fx1_88 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s859.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_88 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s859.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_88 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s859.ffi) = some PRE_first_tail_x15_r0_body.fx1_88
kernel_rfl PRE_first_tail_x15_r0_body.okr1_88 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s859.ffi) = some PRE_first_tail_x15_r0_body.kr1_88
kernel_rfl PRE_first_tail_x15_r0_body.ff088 : PRE_first_tail_x15_r0_body.fx0_88 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_88 (PRE_first_tail_x15_r0_body.clo88.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_88.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff188 : PRE_first_tail_x15_r0_body.fx1_88 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_88 (PRE_first_tail_x15_r0_body.cwS88.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_88.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck88 : freedLB PRE_first_tail_x15_r0_body.kappa88 PRE_first_tail_x15_r0_body.cx0_88.mlx PRE_first_tail_x15_r0_body.fx0_88 PRE_first_tail_x15_r0_body.fx1_88 PRE_first_tail_x15_r0_body.clo88 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf088 : PRE_first_tail_x15_r0_body.kr0_88.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_88.flags (PRE_first_tail_x15_r0_body.clo88.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_88.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt088 : PRE_first_tail_x15_r0_body.kr0_88.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_88.targs (PRE_first_tail_x15_r0_body.clo88.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_88.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf188 : PRE_first_tail_x15_r0_body.kr1_88.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_88.flags (PRE_first_tail_x15_r0_body.cwS88.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_88.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt188 : PRE_first_tail_x15_r0_body.kr1_88.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_88.targs (PRE_first_tail_x15_r0_body.cwS88.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_88.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck88 : krecLB PRE_first_tail_x15_r0_body.kappa88 3842 PRE_first_tail_x15_r0_body.cx0_88.mlx PRE_first_tail_x15_r0_body.kr0_88 PRE_first_tail_x15_r0_body.kr1_88 PRE_first_tail_x15_r0_body.clo88 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn88 : Nat.ble 3842 3842 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge88 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s859.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s860.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR88 : pendRegB PRE_first_tail_x15_r0_body.kappa88 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s860.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe88 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s860.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s859.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift88 (clean : Conv.NClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P88.NL) (cl : SSt (· < 3842) PRE_first_tail_x15_r0_body.cx0_88.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_88.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_88.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_88.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_88.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P88 3842 PRE_first_tail_x15_r0_body.kappa88 PRE_first_tail_x15_r0_body.s860.ffi PRE_first_tail_x15_r0_body.s859.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift88 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue88, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp88 t ht),
    PRE_first_tail_x15_r0_body.cbridge88,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s860.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s859.ffi) (PRE_first_tail_x15_r0_body.cfoot88 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_88 PRE_first_tail_x15_r0_body.ofx1_88 hobjC PRE_first_tail_x15_r0_body.ff088 PRE_first_tail_x15_r0_body.ff188 PRE_first_tail_x15_r0_body.ffck88,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s860.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s859.ffi) (PRE_first_tail_x15_r0_body.cfoot88 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_88 PRE_first_tail_x15_r0_body.okr1_88 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn88) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf088 PRE_first_tail_x15_r0_body.fkt088 PRE_first_tail_x15_r0_body.fkf188 PRE_first_tail_x15_r0_body.fkt188 PRE_first_tail_x15_r0_body.fkck88,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh088 PRE_first_tail_x15_r0_body.cnh188 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe88) PRE_first_tail_x15_r0_body.cpendR88⟩

end Host.Load.Run.Tpl
