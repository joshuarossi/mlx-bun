import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl62
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 62 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc62 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P62 : LoadP := PRE_first_tail_x15_r0_body.Pc62.raise 16507
kernel_rfl PRE_first_tail_x15_r0_body.craise62 : Nat.ble PRE_first_tail_x15_r0_body.Pc62.N0 16507 = true
theorem PRE_first_tail_x15_r0_body.raised62 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc62 PRE_first_tail_x15_r0_body.P62 :=
  .inr ⟨16507, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise62, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_62 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s552.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_62 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s551.ffi)
def PRE_first_tail_x15_r0_body.khinv62 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv62 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS62 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS62 : List Nat := List.range' 16507 0
def PRE_first_tail_x15_r0_body.ciS62 : List Nat := [] ++ List.range' 16507 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh062 : PRE_first_tail_x15_r0_body.kd62.nh0 = PRE_first_tail_x15_r0_body.cx0_62.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh162 : PRE_first_tail_x15_r0_body.kd62.nh1 = PRE_first_tail_x15_r0_body.cx1_62.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn062 : PRE_first_tail_x15_r0_body.kd62.nn0 = PRE_first_tail_x15_r0_body.cx0_62.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn162 : PRE_first_tail_x15_r0_body.kd62.nn1 = PRE_first_tail_x15_r0_body.cx1_62.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo62 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P62.lo && Nat.ble PRE_first_tail_x15_r0_body.P62.lo PRE_first_tail_x15_r0_body.cx0_62.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P62.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P62.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt62 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_62.mlx.next PRE_first_tail_x15_r0_body.cx1_62.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_62.mlx.nnext PRE_first_tail_x15_r0_body.cx1_62.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband62 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P62.NL && Nat.ble PRE_first_tail_x15_r0_body.P62.NL PRE_first_tail_x15_r0_body.P62.N0 && Nat.ble PRE_first_tail_x15_r0_body.P62.N0 PRE_first_tail_x15_r0_body.cx0_62.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow62 : PRE_first_tail_x15_r0_body.kd62.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren62 : checkRenG PRE_first_tail_x15_r0_body.kd62.hnd PRE_first_tail_x15_r0_body.khinv62 (phB PRE_first_tail_x15_r0_body.cx0_62.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband62 : PRE_first_tail_x15_r0_body.kd62.checkBand PRE_first_tail_x15_r0_body.P62.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos62 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd62.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren62 : checkRenG PRE_first_tail_x15_r0_body.kd62.node PRE_first_tail_x15_r0_body.kninv62 (pnB PRE_first_tail_x15_r0_body.cx0_62.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P62.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd62.nodeF j) PRE_first_tail_x15_r0_body.cx1_62.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a62 : PRE_first_tail_x15_r0_body.cx0_62.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b62 : PRE_first_tail_x15_r0_body.cx0_62.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok162 : PRE_first_tail_x15_r0_body.cx1_62.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.pending = PRE_first_tail_x15_r0_body.cx0_62.mlx.pending.map PRE_first_tail_x15_r0_body.kappa62.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.errh = PRE_first_tail_x15_r0_body.cx0_62.mlx.errh.map PRE_first_tail_x15_r0_body.kappa62.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.files = PRE_first_tail_x15_r0_body.cx0_62.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.arch = PRE_first_tail_x15_r0_body.cx0_62.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_62.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.wired = PRE_first_tail_x15_r0_body.cx0_62.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost62 : PRE_first_tail_x15_r0_body.cx1_62.host = PRE_first_tail_x15_r0_body.cx0_62.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd62`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn062 : PRE_first_tail_x15_r0_body.kd62.n0 = 2723332
kernel_rfl PRE_first_tail_x15_r0_body.ckn162 : PRE_first_tail_x15_r0_body.kd62.n1 = 2723342
kernel_rfl PRE_first_tail_x15_r0_body.ckheap62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.heap).all (fun x => Nat.ble 2723331 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl62 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd62.heap.get (2723331 + j) = nth? PRE_first_tail_x15_r0_body.pl62 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja62 : Nat.ble 2723331 2723331 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn62 : Nat.ble 2704 2704 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD62 : Nat.ble 2723331 PRE_first_tail_x15_r0_body.kd62.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn62 : Nat.ble 19419 PRE_first_tail_x15_r0_body.kd62.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn62 : Nat.ble 16507 PRE_first_tail_x15_r0_body.kd62.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb62 : Nat.ble 19419 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.heap).all (Nat.ble (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.hnd).all (Nat.ble (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.node).all (Nat.ble (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix62 : Conv.FixOld (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa62 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja62) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn62) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD62) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn62) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn62) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb62) PRE_first_tail_x15_r0_body.fheap62 PRE_first_tail_x15_r0_body.fhnd62 PRE_first_tail_x15_r0_body.fnode62
kernel_rfl PRE_first_tail_x15_r0_body.fcxn62 : (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn62 : (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle062 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_62.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_62.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS62.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_62.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS62.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_62.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS62.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_62.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS62.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_62.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd62 : (PRE_first_tail_x15_r0_body.clo62 ++ PRE_first_tail_x15_r0_body.cln62 ++ PRE_first_tail_x15_r0_body.cli62 ++ PRE_first_tail_x15_r0_body.cwS62 ++ PRE_first_tail_x15_r0_body.cnS62 ++ PRE_first_tail_x15_r0_body.ciS62).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW62 : PRE_first_tail_x15_r0_body.cwS62.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo62.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI62 : PRE_first_tail_x15_r0_body.ciS62.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli62.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN62 : PRE_first_tail_x15_r0_body.cnS62.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF62 : PRE_first_tail_x15_r0_body.cln62.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh62 : PRE_first_tail_x15_r0_body.clo62.all (handleOK PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.P62.lo PRE_first_tail_x15_r0_body.cx0_62.mlx PRE_first_tail_x15_r0_body.cx1_62.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo62 : PRE_first_tail_x15_r0_body.clo62.map (fun h => PRE_first_tail_x15_r0_body.cx1_62.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa62.handle h)) = PRE_first_tail_x15_r0_body.clo62.map (fun h => (PRE_first_tail_x15_r0_body.cx0_62.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa62.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok62 : PRE_first_tail_x15_r0_body.clo62.all (objOK PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.P62.NL PRE_first_tail_x15_r0_body.cx0_62.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd62 : PRE_first_tail_x15_r0_body.cln62.all (nodeOKF PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.P62 PRE_first_tail_x15_r0_body.cx0_62.mlx PRE_first_tail_x15_r0_body.cx1_62.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp62 : ((PRE_first_tail_x15_r0_body.cln62.filter (fullB PRE_first_tail_x15_r0_body.P62))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_62.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa62.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln62.filter (fullB PRE_first_tail_x15_r0_body.P62))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_62.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa62.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI62 : incrB PRE_first_tail_x15_r0_body.kd62.nodeF (List.range' 16507 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.node).all (fun k => Nat.ble 16507 k && Nat.blt k 16507) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL62 : (PRE_first_tail_x15_r0_body.cln62.filter (Nat.ble PRE_first_tail_x15_r0_body.P62.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd62.nodeF i) && (Nat.blt i 16507 || Nat.ble PRE_first_tail_x15_r0_body.kd62.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord62 : (PRE_first_tail_x15_r0_body.cln62.filter (Nat.ble PRE_first_tail_x15_r0_body.P62.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd62.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd62.nodeF j) (PRE_first_tail_x15_r0_body.kd62.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow62 PRE_first_tail_x15_r0_body.cnn162 PRE_first_tail_x15_r0_body.fnordI62 PRE_first_tail_x15_r0_body.fnordK62 PRE_first_tail_x15_r0_body.fnordL62
kernel_rfl PRE_first_tail_x15_r0_body.fi62 : PRE_first_tail_x15_r0_body.cli62.all (pnB PRE_first_tail_x15_r0_body.cx0_62.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii62 : PRE_first_tail_x15_r0_body.cli62.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_62.mlx.items.get (PRE_first_tail_x15_r0_body.kappa62.node k) = (PRE_first_tail_x15_r0_body.cx0_62.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa62.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot62 (clean : Conv.NClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P62.NL) (cl : SSt (· < 2704) PRE_first_tail_x15_r0_body.cx0_62.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P62 2704 PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.kd62 PRE_first_tail_x15_r0_body.khinv62 PRE_first_tail_x15_r0_body.kninv62 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx PRE_first_tail_x15_r0_body.cx0_62.mlx PRE_first_tail_x15_r0_body.cx1_62.mlx (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo62 PRE_first_tail_x15_r0_body.cln62 PRE_first_tail_x15_r0_body.cli62 PRE_first_tail_x15_r0_body.cwS62 PRE_first_tail_x15_r0_body.cnS62 PRE_first_tail_x15_r0_body.ciS62 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh062, PRE_first_tail_x15_r0_body.cnh162, PRE_first_tail_x15_r0_body.cnn062, PRE_first_tail_x15_r0_body.cnn162, PRE_first_tail_x15_r0_body.cplo62, PRE_first_tail_x15_r0_body.ccnt62, PRE_first_tail_x15_r0_body.cnband62, PRE_first_tail_x15_r0_body.chbelow62, PRE_first_tail_x15_r0_body.chren62, PRE_first_tail_x15_r0_body.cband62, PRE_first_tail_x15_r0_body.cnh1pos62, PRE_first_tail_x15_r0_body.cnren62, PRE_first_tail_x15_r0_body.cnlow62, PRE_first_tail_x15_r0_body.cabs0a62, PRE_first_tail_x15_r0_body.cabs0b62, PRE_first_tail_x15_r0_body.ctok162, PRE_first_tail_x15_r0_body.cpend62, PRE_first_tail_x15_r0_body.cerrh62, PRE_first_tail_x15_r0_body.cfiles62, PRE_first_tail_x15_r0_body.carch62, PRE_first_tail_x15_r0_body.csizes62, PRE_first_tail_x15_r0_body.cwired62, PRE_first_tail_x15_r0_body.cfix62, clean, PRE_first_tail_x15_r0_body.fcxn62, PRE_first_tail_x15_r0_body.fcnn62, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle062, PRE_first_tail_x15_r0_body.fnk62, PRE_first_tail_x15_r0_body.ckA62, PRE_first_tail_x15_r0_body.cobjsK62, PRE_first_tail_x15_r0_body.cnodesK62, PRE_first_tail_x15_r0_body.citemsK62, PRE_first_tail_x15_r0_body.f1A62, PRE_first_tail_x15_r0_body.f1O62, PRE_first_tail_x15_r0_body.f1N62, PRE_first_tail_x15_r0_body.f1I62, PRE_first_tail_x15_r0_body.fbd62, PRE_first_tail_x15_r0_body.fincW62, PRE_first_tail_x15_r0_body.fincI62, PRE_first_tail_x15_r0_body.fincN62, PRE_first_tail_x15_r0_body.flnF62, PRE_first_tail_x15_r0_body.fh62, PRE_first_tail_x15_r0_body.fo62, PRE_first_tail_x15_r0_body.fok62, PRE_first_tail_x15_r0_body.fnd62, PRE_first_tail_x15_r0_body.fp62, PRE_first_tail_x15_r0_body.fnord62, PRE_first_tail_x15_r0_body.fi62, PRE_first_tail_x15_r0_body.fii62⟩
theorem PRE_first_tail_x15_r0_body.cnshift62 (clean : Conv.NClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P62.NL) (cl : SSt (· < 2704) PRE_first_tail_x15_r0_body.cx0_62.mlx) : NShift PRE_first_tail_x15_r0_body.P62 2704 PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.cx0_62 PRE_first_tail_x15_r0_body.cx1_62 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot62 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost62 (compact_a_eq PRE_first_tail_x15_r0_body.ckn062 PRE_first_tail_x15_r0_body.ckn162 PRE_first_tail_x15_r0_body.ckheap62 PRE_first_tail_x15_r0_body.ckpl62)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_62 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s550.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_62 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s550.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_62 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s550.ffi) = some PRE_first_tail_x15_r0_body.fxC_62
kernel_rfl PRE_first_tail_x15_r0_body.okrC_62 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s550.ffi) = some PRE_first_tail_x15_r0_body.krC_62
noncomputable def PRE_first_tail_x15_r0_body.fx0_62 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s552.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_62 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s552.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_62 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s552.ffi) = some PRE_first_tail_x15_r0_body.fx0_62
kernel_rfl PRE_first_tail_x15_r0_body.okr0_62 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s552.ffi) = some PRE_first_tail_x15_r0_body.kr0_62
noncomputable def PRE_first_tail_x15_r0_body.fx1_62 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s551.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_62 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s551.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_62 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s551.ffi) = some PRE_first_tail_x15_r0_body.fx1_62
kernel_rfl PRE_first_tail_x15_r0_body.okr1_62 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s551.ffi) = some PRE_first_tail_x15_r0_body.kr1_62
kernel_rfl PRE_first_tail_x15_r0_body.ff062 : PRE_first_tail_x15_r0_body.fx0_62 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_62 (PRE_first_tail_x15_r0_body.clo62.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_62.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff162 : PRE_first_tail_x15_r0_body.fx1_62 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_62 (PRE_first_tail_x15_r0_body.cwS62.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_62.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck62 : freedLB PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.cx0_62.mlx PRE_first_tail_x15_r0_body.fx0_62 PRE_first_tail_x15_r0_body.fx1_62 PRE_first_tail_x15_r0_body.clo62 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf062 : PRE_first_tail_x15_r0_body.kr0_62.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_62.flags (PRE_first_tail_x15_r0_body.clo62.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_62.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt062 : PRE_first_tail_x15_r0_body.kr0_62.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_62.targs (PRE_first_tail_x15_r0_body.clo62.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_62.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf162 : PRE_first_tail_x15_r0_body.kr1_62.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_62.flags (PRE_first_tail_x15_r0_body.cwS62.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_62.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt162 : PRE_first_tail_x15_r0_body.kr1_62.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_62.targs (PRE_first_tail_x15_r0_body.cwS62.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_62.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck62 : krecLB PRE_first_tail_x15_r0_body.kappa62 2704 PRE_first_tail_x15_r0_body.cx0_62.mlx PRE_first_tail_x15_r0_body.kr0_62 PRE_first_tail_x15_r0_body.kr1_62 PRE_first_tail_x15_r0_body.clo62 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn62 : Nat.ble 2704 2704 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge62 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s551.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s552.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR62 : pendRegB PRE_first_tail_x15_r0_body.kappa62 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s552.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe62 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s552.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s551.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift62 (clean : Conv.NClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P62.NL) (cl : SSt (· < 2704) PRE_first_tail_x15_r0_body.cx0_62.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_62.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_62.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_62.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_62.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P62 2704 PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.s552.ffi PRE_first_tail_x15_r0_body.s551.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift62 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue62, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp62 t ht),
    PRE_first_tail_x15_r0_body.cbridge62,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s552.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s551.ffi) (PRE_first_tail_x15_r0_body.cfoot62 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_62 PRE_first_tail_x15_r0_body.ofx1_62 hobjC PRE_first_tail_x15_r0_body.ff062 PRE_first_tail_x15_r0_body.ff162 PRE_first_tail_x15_r0_body.ffck62,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s552.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s551.ffi) (PRE_first_tail_x15_r0_body.cfoot62 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_62 PRE_first_tail_x15_r0_body.okr1_62 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn62) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf062 PRE_first_tail_x15_r0_body.fkt062 PRE_first_tail_x15_r0_body.fkf162 PRE_first_tail_x15_r0_body.fkt162 PRE_first_tail_x15_r0_body.fkck62,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh062 PRE_first_tail_x15_r0_body.cnh162 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe62) PRE_first_tail_x15_r0_body.cpendR62⟩

end Host.Load.Run.Tpl
