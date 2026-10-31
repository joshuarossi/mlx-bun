import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl178
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 178 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc178 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P178 : LoadP := PRE_first_tail_x15_r0_body.Pc178.raise 18810
kernel_rfl PRE_first_tail_x15_r0_body.craise178 : Nat.ble PRE_first_tail_x15_r0_body.Pc178.N0 18810 = true
theorem PRE_first_tail_x15_r0_body.raised178 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc178 PRE_first_tail_x15_r0_body.P178 :=
  .inr ⟨18810, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise178, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_178 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1722.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_178 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1721.ffi)
def PRE_first_tail_x15_r0_body.khinv178 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv178 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS178 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS178 : List Nat := List.range' 18810 0
def PRE_first_tail_x15_r0_body.ciS178 : List Nat := [] ++ List.range' 18810 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0178 : PRE_first_tail_x15_r0_body.kd178.nh0 = PRE_first_tail_x15_r0_body.cx0_178.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1178 : PRE_first_tail_x15_r0_body.kd178.nh1 = PRE_first_tail_x15_r0_body.cx1_178.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0178 : PRE_first_tail_x15_r0_body.kd178.nn0 = PRE_first_tail_x15_r0_body.cx0_178.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1178 : PRE_first_tail_x15_r0_body.kd178.nn1 = PRE_first_tail_x15_r0_body.cx1_178.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo178 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P178.lo && Nat.ble PRE_first_tail_x15_r0_body.P178.lo PRE_first_tail_x15_r0_body.cx0_178.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P178.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P178.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt178 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_178.mlx.next PRE_first_tail_x15_r0_body.cx1_178.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_178.mlx.nnext PRE_first_tail_x15_r0_body.cx1_178.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband178 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P178.NL && Nat.ble PRE_first_tail_x15_r0_body.P178.NL PRE_first_tail_x15_r0_body.P178.N0 && Nat.ble PRE_first_tail_x15_r0_body.P178.N0 PRE_first_tail_x15_r0_body.cx0_178.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow178 : PRE_first_tail_x15_r0_body.kd178.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren178 : checkRenG PRE_first_tail_x15_r0_body.kd178.hnd PRE_first_tail_x15_r0_body.khinv178 (phB PRE_first_tail_x15_r0_body.cx0_178.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband178 : PRE_first_tail_x15_r0_body.kd178.checkBand PRE_first_tail_x15_r0_body.P178.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos178 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd178.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren178 : checkRenG PRE_first_tail_x15_r0_body.kd178.node PRE_first_tail_x15_r0_body.kninv178 (pnB PRE_first_tail_x15_r0_body.cx0_178.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow178 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd178.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P178.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd178.nodeF j) PRE_first_tail_x15_r0_body.cx1_178.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a178 : PRE_first_tail_x15_r0_body.cx0_178.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b178 : PRE_first_tail_x15_r0_body.cx0_178.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1178 : PRE_first_tail_x15_r0_body.cx1_178.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend178 : PRE_first_tail_x15_r0_body.cx1_178.mlx.pending = PRE_first_tail_x15_r0_body.cx0_178.mlx.pending.map PRE_first_tail_x15_r0_body.kappa178.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh178 : PRE_first_tail_x15_r0_body.cx1_178.mlx.errh = PRE_first_tail_x15_r0_body.cx0_178.mlx.errh.map PRE_first_tail_x15_r0_body.kappa178.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles178 : PRE_first_tail_x15_r0_body.cx1_178.mlx.files = PRE_first_tail_x15_r0_body.cx0_178.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch178 : PRE_first_tail_x15_r0_body.cx1_178.mlx.arch = PRE_first_tail_x15_r0_body.cx0_178.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes178 : PRE_first_tail_x15_r0_body.cx1_178.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_178.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired178 : PRE_first_tail_x15_r0_body.cx1_178.mlx.wired = PRE_first_tail_x15_r0_body.cx0_178.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost178 : PRE_first_tail_x15_r0_body.cx1_178.host = PRE_first_tail_x15_r0_body.cx0_178.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd178`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0178 : PRE_first_tail_x15_r0_body.kd178.n0 = 2814941
kernel_rfl PRE_first_tail_x15_r0_body.ckn1178 : PRE_first_tail_x15_r0_body.kd178.n1 = 2814943
kernel_rfl PRE_first_tail_x15_r0_body.ckheap178 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd178.heap).all (fun x => Nat.ble 2814941 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl178 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd178.heap.get (2814941 + j) = nth? PRE_first_tail_x15_r0_body.pl178 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja178 : Nat.ble 2814941 2814941 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn178 : Nat.ble 7688 7688 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD178 : Nat.ble 2814941 PRE_first_tail_x15_r0_body.kd178.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn178 : Nat.ble 21714 PRE_first_tail_x15_r0_body.kd178.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn178 : Nat.ble 18810 PRE_first_tail_x15_r0_body.kd178.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb178 : Nat.ble 21714 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap178 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd178.heap).all (Nat.ble (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd178 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd178.hnd).all (Nat.ble (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode178 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd178.node).all (Nat.ble (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix178 : Conv.FixOld (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa178 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja178) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn178) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD178) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn178) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn178) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb178) PRE_first_tail_x15_r0_body.fheap178 PRE_first_tail_x15_r0_body.fhnd178 PRE_first_tail_x15_r0_body.fnode178
kernel_rfl PRE_first_tail_x15_r0_body.fcxn178 : (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn178 : (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0178 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_178.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_178.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk178 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd178.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A178 : PRE_first_tail_x15_r0_body.cx1_178.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS178.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_178.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O178 : PRE_first_tail_x15_r0_body.cx1_178.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS178.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_178.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N178 : PRE_first_tail_x15_r0_body.cx1_178.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS178.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_178.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I178 : PRE_first_tail_x15_r0_body.cx1_178.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS178.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_178.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd178 : (PRE_first_tail_x15_r0_body.clo178 ++ PRE_first_tail_x15_r0_body.cln178 ++ PRE_first_tail_x15_r0_body.cli178 ++ PRE_first_tail_x15_r0_body.cwS178 ++ PRE_first_tail_x15_r0_body.cnS178 ++ PRE_first_tail_x15_r0_body.ciS178).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW178 : PRE_first_tail_x15_r0_body.cwS178.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo178.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI178 : PRE_first_tail_x15_r0_body.ciS178.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli178.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN178 : PRE_first_tail_x15_r0_body.cnS178.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF178 : PRE_first_tail_x15_r0_body.cln178.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh178 : PRE_first_tail_x15_r0_body.clo178.all (handleOK PRE_first_tail_x15_r0_body.kappa178 PRE_first_tail_x15_r0_body.P178.lo PRE_first_tail_x15_r0_body.cx0_178.mlx PRE_first_tail_x15_r0_body.cx1_178.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo178 : PRE_first_tail_x15_r0_body.clo178.map (fun h => PRE_first_tail_x15_r0_body.cx1_178.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa178.handle h)) = PRE_first_tail_x15_r0_body.clo178.map (fun h => (PRE_first_tail_x15_r0_body.cx0_178.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa178.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok178 : PRE_first_tail_x15_r0_body.clo178.all (objOK PRE_first_tail_x15_r0_body.kappa178 PRE_first_tail_x15_r0_body.P178.NL PRE_first_tail_x15_r0_body.cx0_178.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd178 : PRE_first_tail_x15_r0_body.cln178.all (nodeOKF PRE_first_tail_x15_r0_body.kappa178 PRE_first_tail_x15_r0_body.P178 PRE_first_tail_x15_r0_body.cx0_178.mlx PRE_first_tail_x15_r0_body.cx1_178.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp178 : ((PRE_first_tail_x15_r0_body.cln178.filter (fullB PRE_first_tail_x15_r0_body.P178))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_178.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa178.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln178.filter (fullB PRE_first_tail_x15_r0_body.P178))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_178.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa178.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI178 : incrB PRE_first_tail_x15_r0_body.kd178.nodeF (List.range' 18810 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK178 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd178.node).all (fun k => Nat.ble 18810 k && Nat.blt k 18810) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL178 : (PRE_first_tail_x15_r0_body.cln178.filter (Nat.ble PRE_first_tail_x15_r0_body.P178.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd178.nodeF i) && (Nat.blt i 18810 || Nat.ble PRE_first_tail_x15_r0_body.kd178.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord178 : (PRE_first_tail_x15_r0_body.cln178.filter (Nat.ble PRE_first_tail_x15_r0_body.P178.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd178.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd178.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd178.nodeF j) (PRE_first_tail_x15_r0_body.kd178.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow178 PRE_first_tail_x15_r0_body.cnn1178 PRE_first_tail_x15_r0_body.fnordI178 PRE_first_tail_x15_r0_body.fnordK178 PRE_first_tail_x15_r0_body.fnordL178
kernel_rfl PRE_first_tail_x15_r0_body.fi178 : PRE_first_tail_x15_r0_body.cli178.all (pnB PRE_first_tail_x15_r0_body.cx0_178.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii178 : PRE_first_tail_x15_r0_body.cli178.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_178.mlx.items.get (PRE_first_tail_x15_r0_body.kappa178.node k) = (PRE_first_tail_x15_r0_body.cx0_178.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa178.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot178 (clean : Conv.NClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P178.NL) (cl : SSt (· < 7688) PRE_first_tail_x15_r0_body.cx0_178.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P178 7688 PRE_first_tail_x15_r0_body.kappa178 PRE_first_tail_x15_r0_body.kd178 PRE_first_tail_x15_r0_body.khinv178 PRE_first_tail_x15_r0_body.kninv178 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx PRE_first_tail_x15_r0_body.cx0_178.mlx PRE_first_tail_x15_r0_body.cx1_178.mlx (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo178 PRE_first_tail_x15_r0_body.cln178 PRE_first_tail_x15_r0_body.cli178 PRE_first_tail_x15_r0_body.cwS178 PRE_first_tail_x15_r0_body.cnS178 PRE_first_tail_x15_r0_body.ciS178 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0178, PRE_first_tail_x15_r0_body.cnh1178, PRE_first_tail_x15_r0_body.cnn0178, PRE_first_tail_x15_r0_body.cnn1178, PRE_first_tail_x15_r0_body.cplo178, PRE_first_tail_x15_r0_body.ccnt178, PRE_first_tail_x15_r0_body.cnband178, PRE_first_tail_x15_r0_body.chbelow178, PRE_first_tail_x15_r0_body.chren178, PRE_first_tail_x15_r0_body.cband178, PRE_first_tail_x15_r0_body.cnh1pos178, PRE_first_tail_x15_r0_body.cnren178, PRE_first_tail_x15_r0_body.cnlow178, PRE_first_tail_x15_r0_body.cabs0a178, PRE_first_tail_x15_r0_body.cabs0b178, PRE_first_tail_x15_r0_body.ctok1178, PRE_first_tail_x15_r0_body.cpend178, PRE_first_tail_x15_r0_body.cerrh178, PRE_first_tail_x15_r0_body.cfiles178, PRE_first_tail_x15_r0_body.carch178, PRE_first_tail_x15_r0_body.csizes178, PRE_first_tail_x15_r0_body.cwired178, PRE_first_tail_x15_r0_body.cfix178, clean, PRE_first_tail_x15_r0_body.fcxn178, PRE_first_tail_x15_r0_body.fcnn178, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0178, PRE_first_tail_x15_r0_body.fnk178, PRE_first_tail_x15_r0_body.ckA178, PRE_first_tail_x15_r0_body.cobjsK178, PRE_first_tail_x15_r0_body.cnodesK178, PRE_first_tail_x15_r0_body.citemsK178, PRE_first_tail_x15_r0_body.f1A178, PRE_first_tail_x15_r0_body.f1O178, PRE_first_tail_x15_r0_body.f1N178, PRE_first_tail_x15_r0_body.f1I178, PRE_first_tail_x15_r0_body.fbd178, PRE_first_tail_x15_r0_body.fincW178, PRE_first_tail_x15_r0_body.fincI178, PRE_first_tail_x15_r0_body.fincN178, PRE_first_tail_x15_r0_body.flnF178, PRE_first_tail_x15_r0_body.fh178, PRE_first_tail_x15_r0_body.fo178, PRE_first_tail_x15_r0_body.fok178, PRE_first_tail_x15_r0_body.fnd178, PRE_first_tail_x15_r0_body.fp178, PRE_first_tail_x15_r0_body.fnord178, PRE_first_tail_x15_r0_body.fi178, PRE_first_tail_x15_r0_body.fii178⟩
theorem PRE_first_tail_x15_r0_body.cnshift178 (clean : Conv.NClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P178.NL) (cl : SSt (· < 7688) PRE_first_tail_x15_r0_body.cx0_178.mlx) : NShift PRE_first_tail_x15_r0_body.P178 7688 PRE_first_tail_x15_r0_body.kappa178 PRE_first_tail_x15_r0_body.cx0_178 PRE_first_tail_x15_r0_body.cx1_178 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot178 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost178 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0178 PRE_first_tail_x15_r0_body.ckn1178 PRE_first_tail_x15_r0_body.ckheap178 PRE_first_tail_x15_r0_body.ckpl178)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_178 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1720.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_178 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1720.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_178 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1720.ffi) = some PRE_first_tail_x15_r0_body.fxC_178
kernel_rfl PRE_first_tail_x15_r0_body.okrC_178 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1720.ffi) = some PRE_first_tail_x15_r0_body.krC_178
noncomputable def PRE_first_tail_x15_r0_body.fx0_178 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1722.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_178 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1722.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_178 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1722.ffi) = some PRE_first_tail_x15_r0_body.fx0_178
kernel_rfl PRE_first_tail_x15_r0_body.okr0_178 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1722.ffi) = some PRE_first_tail_x15_r0_body.kr0_178
noncomputable def PRE_first_tail_x15_r0_body.fx1_178 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1721.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_178 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1721.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_178 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1721.ffi) = some PRE_first_tail_x15_r0_body.fx1_178
kernel_rfl PRE_first_tail_x15_r0_body.okr1_178 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1721.ffi) = some PRE_first_tail_x15_r0_body.kr1_178
kernel_rfl PRE_first_tail_x15_r0_body.ff0178 : PRE_first_tail_x15_r0_body.fx0_178 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_178 (PRE_first_tail_x15_r0_body.clo178.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_178.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1178 : PRE_first_tail_x15_r0_body.fx1_178 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_178 (PRE_first_tail_x15_r0_body.cwS178.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_178.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck178 : freedLB PRE_first_tail_x15_r0_body.kappa178 PRE_first_tail_x15_r0_body.cx0_178.mlx PRE_first_tail_x15_r0_body.fx0_178 PRE_first_tail_x15_r0_body.fx1_178 PRE_first_tail_x15_r0_body.clo178 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0178 : PRE_first_tail_x15_r0_body.kr0_178.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_178.flags (PRE_first_tail_x15_r0_body.clo178.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_178.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0178 : PRE_first_tail_x15_r0_body.kr0_178.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_178.targs (PRE_first_tail_x15_r0_body.clo178.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_178.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1178 : PRE_first_tail_x15_r0_body.kr1_178.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_178.flags (PRE_first_tail_x15_r0_body.cwS178.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_178.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1178 : PRE_first_tail_x15_r0_body.kr1_178.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_178.targs (PRE_first_tail_x15_r0_body.cwS178.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_178.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck178 : krecLB PRE_first_tail_x15_r0_body.kappa178 7688 PRE_first_tail_x15_r0_body.cx0_178.mlx PRE_first_tail_x15_r0_body.kr0_178 PRE_first_tail_x15_r0_body.kr1_178 PRE_first_tail_x15_r0_body.clo178 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn178 : Nat.ble 7688 7688 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge178 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1721.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1722.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR178 : pendRegB PRE_first_tail_x15_r0_body.kappa178 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1722.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe178 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1722.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1721.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift178 (clean : Conv.NClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P178.NL) (cl : SSt (· < 7688) PRE_first_tail_x15_r0_body.cx0_178.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_178.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_178.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_178.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_178.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P178 7688 PRE_first_tail_x15_r0_body.kappa178 PRE_first_tail_x15_r0_body.s1722.ffi PRE_first_tail_x15_r0_body.s1721.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift178 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue178, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp178 t ht),
    PRE_first_tail_x15_r0_body.cbridge178,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1722.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1721.ffi) (PRE_first_tail_x15_r0_body.cfoot178 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_178 PRE_first_tail_x15_r0_body.ofx1_178 hobjC PRE_first_tail_x15_r0_body.ff0178 PRE_first_tail_x15_r0_body.ff1178 PRE_first_tail_x15_r0_body.ffck178,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1722.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1721.ffi) (PRE_first_tail_x15_r0_body.cfoot178 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_178 PRE_first_tail_x15_r0_body.okr1_178 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn178) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0178 PRE_first_tail_x15_r0_body.fkt0178 PRE_first_tail_x15_r0_body.fkf1178 PRE_first_tail_x15_r0_body.fkt1178 PRE_first_tail_x15_r0_body.fkck178,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0178 PRE_first_tail_x15_r0_body.cnh1178 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe178) PRE_first_tail_x15_r0_body.cpendR178⟩

end Host.Load.Run.Tpl
