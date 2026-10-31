import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl184
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 184 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc184 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P184 : LoadP := PRE_first_tail_x15_r0_body.Pc184.raise 18936
kernel_rfl PRE_first_tail_x15_r0_body.craise184 : Nat.ble PRE_first_tail_x15_r0_body.Pc184.N0 18936 = true
theorem PRE_first_tail_x15_r0_body.raised184 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc184 PRE_first_tail_x15_r0_body.P184 :=
  .inr ⟨18936, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise184, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_184 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1780.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_184 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1779.ffi)
def PRE_first_tail_x15_r0_body.khinv184 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv184 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS184 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS184 : List Nat := List.range' 18936 0
def PRE_first_tail_x15_r0_body.ciS184 : List Nat := [] ++ List.range' 18936 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0184 : PRE_first_tail_x15_r0_body.kd184.nh0 = PRE_first_tail_x15_r0_body.cx0_184.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1184 : PRE_first_tail_x15_r0_body.kd184.nh1 = PRE_first_tail_x15_r0_body.cx1_184.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0184 : PRE_first_tail_x15_r0_body.kd184.nn0 = PRE_first_tail_x15_r0_body.cx0_184.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1184 : PRE_first_tail_x15_r0_body.kd184.nn1 = PRE_first_tail_x15_r0_body.cx1_184.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo184 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P184.lo && Nat.ble PRE_first_tail_x15_r0_body.P184.lo PRE_first_tail_x15_r0_body.cx0_184.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P184.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P184.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt184 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_184.mlx.next PRE_first_tail_x15_r0_body.cx1_184.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_184.mlx.nnext PRE_first_tail_x15_r0_body.cx1_184.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband184 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P184.NL && Nat.ble PRE_first_tail_x15_r0_body.P184.NL PRE_first_tail_x15_r0_body.P184.N0 && Nat.ble PRE_first_tail_x15_r0_body.P184.N0 PRE_first_tail_x15_r0_body.cx0_184.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow184 : PRE_first_tail_x15_r0_body.kd184.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren184 : checkRenG PRE_first_tail_x15_r0_body.kd184.hnd PRE_first_tail_x15_r0_body.khinv184 (phB PRE_first_tail_x15_r0_body.cx0_184.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband184 : PRE_first_tail_x15_r0_body.kd184.checkBand PRE_first_tail_x15_r0_body.P184.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos184 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd184.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren184 : checkRenG PRE_first_tail_x15_r0_body.kd184.node PRE_first_tail_x15_r0_body.kninv184 (pnB PRE_first_tail_x15_r0_body.cx0_184.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow184 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd184.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P184.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd184.nodeF j) PRE_first_tail_x15_r0_body.cx1_184.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a184 : PRE_first_tail_x15_r0_body.cx0_184.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b184 : PRE_first_tail_x15_r0_body.cx0_184.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1184 : PRE_first_tail_x15_r0_body.cx1_184.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend184 : PRE_first_tail_x15_r0_body.cx1_184.mlx.pending = PRE_first_tail_x15_r0_body.cx0_184.mlx.pending.map PRE_first_tail_x15_r0_body.kappa184.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh184 : PRE_first_tail_x15_r0_body.cx1_184.mlx.errh = PRE_first_tail_x15_r0_body.cx0_184.mlx.errh.map PRE_first_tail_x15_r0_body.kappa184.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles184 : PRE_first_tail_x15_r0_body.cx1_184.mlx.files = PRE_first_tail_x15_r0_body.cx0_184.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch184 : PRE_first_tail_x15_r0_body.cx1_184.mlx.arch = PRE_first_tail_x15_r0_body.cx0_184.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes184 : PRE_first_tail_x15_r0_body.cx1_184.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_184.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired184 : PRE_first_tail_x15_r0_body.cx1_184.mlx.wired = PRE_first_tail_x15_r0_body.cx0_184.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost184 : PRE_first_tail_x15_r0_body.cx1_184.host = PRE_first_tail_x15_r0_body.cx0_184.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd184`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0184 : PRE_first_tail_x15_r0_body.kd184.n0 = 2819483
kernel_rfl PRE_first_tail_x15_r0_body.ckn1184 : PRE_first_tail_x15_r0_body.kd184.n1 = 2819485
kernel_rfl PRE_first_tail_x15_r0_body.ckheap184 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd184.heap).all (fun x => Nat.ble 2819483 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl184 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd184.heap.get (2819483 + j) = nth? PRE_first_tail_x15_r0_body.pl184 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja184 : Nat.ble 2819483 2819483 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn184 : Nat.ble 7946 7946 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD184 : Nat.ble 2819483 PRE_first_tail_x15_r0_body.kd184.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn184 : Nat.ble 21829 PRE_first_tail_x15_r0_body.kd184.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn184 : Nat.ble 18936 PRE_first_tail_x15_r0_body.kd184.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb184 : Nat.ble 21829 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap184 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd184.heap).all (Nat.ble (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd184 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd184.hnd).all (Nat.ble (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode184 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd184.node).all (Nat.ble (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix184 : Conv.FixOld (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa184 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja184) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn184) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD184) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn184) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn184) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb184) PRE_first_tail_x15_r0_body.fheap184 PRE_first_tail_x15_r0_body.fhnd184 PRE_first_tail_x15_r0_body.fnode184
kernel_rfl PRE_first_tail_x15_r0_body.fcxn184 : (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn184 : (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0184 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_184.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_184.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk184 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd184.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A184 : PRE_first_tail_x15_r0_body.cx1_184.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS184.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_184.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O184 : PRE_first_tail_x15_r0_body.cx1_184.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS184.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_184.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N184 : PRE_first_tail_x15_r0_body.cx1_184.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS184.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_184.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I184 : PRE_first_tail_x15_r0_body.cx1_184.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS184.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_184.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd184 : (PRE_first_tail_x15_r0_body.clo184 ++ PRE_first_tail_x15_r0_body.cln184 ++ PRE_first_tail_x15_r0_body.cli184 ++ PRE_first_tail_x15_r0_body.cwS184 ++ PRE_first_tail_x15_r0_body.cnS184 ++ PRE_first_tail_x15_r0_body.ciS184).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW184 : PRE_first_tail_x15_r0_body.cwS184.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo184.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI184 : PRE_first_tail_x15_r0_body.ciS184.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli184.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN184 : PRE_first_tail_x15_r0_body.cnS184.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF184 : PRE_first_tail_x15_r0_body.cln184.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh184 : PRE_first_tail_x15_r0_body.clo184.all (handleOK PRE_first_tail_x15_r0_body.kappa184 PRE_first_tail_x15_r0_body.P184.lo PRE_first_tail_x15_r0_body.cx0_184.mlx PRE_first_tail_x15_r0_body.cx1_184.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo184 : PRE_first_tail_x15_r0_body.clo184.map (fun h => PRE_first_tail_x15_r0_body.cx1_184.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa184.handle h)) = PRE_first_tail_x15_r0_body.clo184.map (fun h => (PRE_first_tail_x15_r0_body.cx0_184.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa184.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok184 : PRE_first_tail_x15_r0_body.clo184.all (objOK PRE_first_tail_x15_r0_body.kappa184 PRE_first_tail_x15_r0_body.P184.NL PRE_first_tail_x15_r0_body.cx0_184.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd184 : PRE_first_tail_x15_r0_body.cln184.all (nodeOKF PRE_first_tail_x15_r0_body.kappa184 PRE_first_tail_x15_r0_body.P184 PRE_first_tail_x15_r0_body.cx0_184.mlx PRE_first_tail_x15_r0_body.cx1_184.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp184 : ((PRE_first_tail_x15_r0_body.cln184.filter (fullB PRE_first_tail_x15_r0_body.P184))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_184.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa184.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln184.filter (fullB PRE_first_tail_x15_r0_body.P184))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_184.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa184.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI184 : incrB PRE_first_tail_x15_r0_body.kd184.nodeF (List.range' 18936 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK184 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd184.node).all (fun k => Nat.ble 18936 k && Nat.blt k 18936) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL184 : (PRE_first_tail_x15_r0_body.cln184.filter (Nat.ble PRE_first_tail_x15_r0_body.P184.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd184.nodeF i) && (Nat.blt i 18936 || Nat.ble PRE_first_tail_x15_r0_body.kd184.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord184 : (PRE_first_tail_x15_r0_body.cln184.filter (Nat.ble PRE_first_tail_x15_r0_body.P184.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd184.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd184.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd184.nodeF j) (PRE_first_tail_x15_r0_body.kd184.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow184 PRE_first_tail_x15_r0_body.cnn1184 PRE_first_tail_x15_r0_body.fnordI184 PRE_first_tail_x15_r0_body.fnordK184 PRE_first_tail_x15_r0_body.fnordL184
kernel_rfl PRE_first_tail_x15_r0_body.fi184 : PRE_first_tail_x15_r0_body.cli184.all (pnB PRE_first_tail_x15_r0_body.cx0_184.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii184 : PRE_first_tail_x15_r0_body.cli184.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_184.mlx.items.get (PRE_first_tail_x15_r0_body.kappa184.node k) = (PRE_first_tail_x15_r0_body.cx0_184.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa184.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot184 (clean : Conv.NClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P184.NL) (cl : SSt (· < 7946) PRE_first_tail_x15_r0_body.cx0_184.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P184 7946 PRE_first_tail_x15_r0_body.kappa184 PRE_first_tail_x15_r0_body.kd184 PRE_first_tail_x15_r0_body.khinv184 PRE_first_tail_x15_r0_body.kninv184 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx PRE_first_tail_x15_r0_body.cx0_184.mlx PRE_first_tail_x15_r0_body.cx1_184.mlx (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo184 PRE_first_tail_x15_r0_body.cln184 PRE_first_tail_x15_r0_body.cli184 PRE_first_tail_x15_r0_body.cwS184 PRE_first_tail_x15_r0_body.cnS184 PRE_first_tail_x15_r0_body.ciS184 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0184, PRE_first_tail_x15_r0_body.cnh1184, PRE_first_tail_x15_r0_body.cnn0184, PRE_first_tail_x15_r0_body.cnn1184, PRE_first_tail_x15_r0_body.cplo184, PRE_first_tail_x15_r0_body.ccnt184, PRE_first_tail_x15_r0_body.cnband184, PRE_first_tail_x15_r0_body.chbelow184, PRE_first_tail_x15_r0_body.chren184, PRE_first_tail_x15_r0_body.cband184, PRE_first_tail_x15_r0_body.cnh1pos184, PRE_first_tail_x15_r0_body.cnren184, PRE_first_tail_x15_r0_body.cnlow184, PRE_first_tail_x15_r0_body.cabs0a184, PRE_first_tail_x15_r0_body.cabs0b184, PRE_first_tail_x15_r0_body.ctok1184, PRE_first_tail_x15_r0_body.cpend184, PRE_first_tail_x15_r0_body.cerrh184, PRE_first_tail_x15_r0_body.cfiles184, PRE_first_tail_x15_r0_body.carch184, PRE_first_tail_x15_r0_body.csizes184, PRE_first_tail_x15_r0_body.cwired184, PRE_first_tail_x15_r0_body.cfix184, clean, PRE_first_tail_x15_r0_body.fcxn184, PRE_first_tail_x15_r0_body.fcnn184, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0184, PRE_first_tail_x15_r0_body.fnk184, PRE_first_tail_x15_r0_body.ckA184, PRE_first_tail_x15_r0_body.cobjsK184, PRE_first_tail_x15_r0_body.cnodesK184, PRE_first_tail_x15_r0_body.citemsK184, PRE_first_tail_x15_r0_body.f1A184, PRE_first_tail_x15_r0_body.f1O184, PRE_first_tail_x15_r0_body.f1N184, PRE_first_tail_x15_r0_body.f1I184, PRE_first_tail_x15_r0_body.fbd184, PRE_first_tail_x15_r0_body.fincW184, PRE_first_tail_x15_r0_body.fincI184, PRE_first_tail_x15_r0_body.fincN184, PRE_first_tail_x15_r0_body.flnF184, PRE_first_tail_x15_r0_body.fh184, PRE_first_tail_x15_r0_body.fo184, PRE_first_tail_x15_r0_body.fok184, PRE_first_tail_x15_r0_body.fnd184, PRE_first_tail_x15_r0_body.fp184, PRE_first_tail_x15_r0_body.fnord184, PRE_first_tail_x15_r0_body.fi184, PRE_first_tail_x15_r0_body.fii184⟩
theorem PRE_first_tail_x15_r0_body.cnshift184 (clean : Conv.NClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P184.NL) (cl : SSt (· < 7946) PRE_first_tail_x15_r0_body.cx0_184.mlx) : NShift PRE_first_tail_x15_r0_body.P184 7946 PRE_first_tail_x15_r0_body.kappa184 PRE_first_tail_x15_r0_body.cx0_184 PRE_first_tail_x15_r0_body.cx1_184 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot184 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost184 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0184 PRE_first_tail_x15_r0_body.ckn1184 PRE_first_tail_x15_r0_body.ckheap184 PRE_first_tail_x15_r0_body.ckpl184)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_184 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1778.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_184 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1778.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_184 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1778.ffi) = some PRE_first_tail_x15_r0_body.fxC_184
kernel_rfl PRE_first_tail_x15_r0_body.okrC_184 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1778.ffi) = some PRE_first_tail_x15_r0_body.krC_184
noncomputable def PRE_first_tail_x15_r0_body.fx0_184 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1780.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_184 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1780.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_184 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1780.ffi) = some PRE_first_tail_x15_r0_body.fx0_184
kernel_rfl PRE_first_tail_x15_r0_body.okr0_184 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1780.ffi) = some PRE_first_tail_x15_r0_body.kr0_184
noncomputable def PRE_first_tail_x15_r0_body.fx1_184 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1779.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_184 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1779.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_184 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1779.ffi) = some PRE_first_tail_x15_r0_body.fx1_184
kernel_rfl PRE_first_tail_x15_r0_body.okr1_184 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1779.ffi) = some PRE_first_tail_x15_r0_body.kr1_184
kernel_rfl PRE_first_tail_x15_r0_body.ff0184 : PRE_first_tail_x15_r0_body.fx0_184 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_184 (PRE_first_tail_x15_r0_body.clo184.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_184.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1184 : PRE_first_tail_x15_r0_body.fx1_184 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_184 (PRE_first_tail_x15_r0_body.cwS184.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_184.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck184 : freedLB PRE_first_tail_x15_r0_body.kappa184 PRE_first_tail_x15_r0_body.cx0_184.mlx PRE_first_tail_x15_r0_body.fx0_184 PRE_first_tail_x15_r0_body.fx1_184 PRE_first_tail_x15_r0_body.clo184 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0184 : PRE_first_tail_x15_r0_body.kr0_184.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_184.flags (PRE_first_tail_x15_r0_body.clo184.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_184.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0184 : PRE_first_tail_x15_r0_body.kr0_184.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_184.targs (PRE_first_tail_x15_r0_body.clo184.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_184.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1184 : PRE_first_tail_x15_r0_body.kr1_184.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_184.flags (PRE_first_tail_x15_r0_body.cwS184.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_184.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1184 : PRE_first_tail_x15_r0_body.kr1_184.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_184.targs (PRE_first_tail_x15_r0_body.cwS184.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_184.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck184 : krecLB PRE_first_tail_x15_r0_body.kappa184 7946 PRE_first_tail_x15_r0_body.cx0_184.mlx PRE_first_tail_x15_r0_body.kr0_184 PRE_first_tail_x15_r0_body.kr1_184 PRE_first_tail_x15_r0_body.clo184 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn184 : Nat.ble 7946 7946 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge184 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1779.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1780.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR184 : pendRegB PRE_first_tail_x15_r0_body.kappa184 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1780.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe184 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1780.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1779.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift184 (clean : Conv.NClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P184.NL) (cl : SSt (· < 7946) PRE_first_tail_x15_r0_body.cx0_184.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_184.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_184.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_184.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_184.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P184 7946 PRE_first_tail_x15_r0_body.kappa184 PRE_first_tail_x15_r0_body.s1780.ffi PRE_first_tail_x15_r0_body.s1779.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift184 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue184, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp184 t ht),
    PRE_first_tail_x15_r0_body.cbridge184,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1780.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1779.ffi) (PRE_first_tail_x15_r0_body.cfoot184 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_184 PRE_first_tail_x15_r0_body.ofx1_184 hobjC PRE_first_tail_x15_r0_body.ff0184 PRE_first_tail_x15_r0_body.ff1184 PRE_first_tail_x15_r0_body.ffck184,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1780.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1779.ffi) (PRE_first_tail_x15_r0_body.cfoot184 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_184 PRE_first_tail_x15_r0_body.okr1_184 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn184) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0184 PRE_first_tail_x15_r0_body.fkt0184 PRE_first_tail_x15_r0_body.fkf1184 PRE_first_tail_x15_r0_body.fkt1184 PRE_first_tail_x15_r0_body.fkck184,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0184 PRE_first_tail_x15_r0_body.cnh1184 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe184) PRE_first_tail_x15_r0_body.cpendR184⟩

end Host.Load.Run.Tpl
