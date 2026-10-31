import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl35
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 35 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc35 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P35 : LoadP := PRE_first_tail_x15_r0_body.Pc35.raise 15970
kernel_rfl PRE_first_tail_x15_r0_body.craise35 : Nat.ble PRE_first_tail_x15_r0_body.Pc35.N0 15970 = true
theorem PRE_first_tail_x15_r0_body.raised35 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc35 PRE_first_tail_x15_r0_body.P35 :=
  .inr ⟨15970, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise35, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_35 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s315.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_35 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s314.ffi)
def PRE_first_tail_x15_r0_body.khinv35 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv35 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS35 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS35 : List Nat := List.range' 15970 0
def PRE_first_tail_x15_r0_body.ciS35 : List Nat := [] ++ List.range' 15970 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh035 : PRE_first_tail_x15_r0_body.kd35.nh0 = PRE_first_tail_x15_r0_body.cx0_35.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh135 : PRE_first_tail_x15_r0_body.kd35.nh1 = PRE_first_tail_x15_r0_body.cx1_35.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn035 : PRE_first_tail_x15_r0_body.kd35.nn0 = PRE_first_tail_x15_r0_body.cx0_35.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn135 : PRE_first_tail_x15_r0_body.kd35.nn1 = PRE_first_tail_x15_r0_body.cx1_35.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo35 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P35.lo && Nat.ble PRE_first_tail_x15_r0_body.P35.lo PRE_first_tail_x15_r0_body.cx0_35.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P35.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P35.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt35 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_35.mlx.next PRE_first_tail_x15_r0_body.cx1_35.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_35.mlx.nnext PRE_first_tail_x15_r0_body.cx1_35.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband35 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P35.NL && Nat.ble PRE_first_tail_x15_r0_body.P35.NL PRE_first_tail_x15_r0_body.P35.N0 && Nat.ble PRE_first_tail_x15_r0_body.P35.N0 PRE_first_tail_x15_r0_body.cx0_35.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow35 : PRE_first_tail_x15_r0_body.kd35.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren35 : checkRenG PRE_first_tail_x15_r0_body.kd35.hnd PRE_first_tail_x15_r0_body.khinv35 (phB PRE_first_tail_x15_r0_body.cx0_35.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband35 : PRE_first_tail_x15_r0_body.kd35.checkBand PRE_first_tail_x15_r0_body.P35.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos35 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd35.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren35 : checkRenG PRE_first_tail_x15_r0_body.kd35.node PRE_first_tail_x15_r0_body.kninv35 (pnB PRE_first_tail_x15_r0_body.cx0_35.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow35 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd35.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P35.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd35.nodeF j) PRE_first_tail_x15_r0_body.cx1_35.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a35 : PRE_first_tail_x15_r0_body.cx0_35.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b35 : PRE_first_tail_x15_r0_body.cx0_35.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok135 : PRE_first_tail_x15_r0_body.cx1_35.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend35 : PRE_first_tail_x15_r0_body.cx1_35.mlx.pending = PRE_first_tail_x15_r0_body.cx0_35.mlx.pending.map PRE_first_tail_x15_r0_body.kappa35.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh35 : PRE_first_tail_x15_r0_body.cx1_35.mlx.errh = PRE_first_tail_x15_r0_body.cx0_35.mlx.errh.map PRE_first_tail_x15_r0_body.kappa35.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles35 : PRE_first_tail_x15_r0_body.cx1_35.mlx.files = PRE_first_tail_x15_r0_body.cx0_35.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch35 : PRE_first_tail_x15_r0_body.cx1_35.mlx.arch = PRE_first_tail_x15_r0_body.cx0_35.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes35 : PRE_first_tail_x15_r0_body.cx1_35.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_35.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired35 : PRE_first_tail_x15_r0_body.cx1_35.mlx.wired = PRE_first_tail_x15_r0_body.cx0_35.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost35 : PRE_first_tail_x15_r0_body.cx1_35.host = PRE_first_tail_x15_r0_body.cx0_35.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd35`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn035 : PRE_first_tail_x15_r0_body.kd35.n0 = 2702206
kernel_rfl PRE_first_tail_x15_r0_body.ckn135 : PRE_first_tail_x15_r0_body.kd35.n1 = 2702225
kernel_rfl PRE_first_tail_x15_r0_body.ckheap35 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd35.heap).all (fun x => Nat.ble 2702205 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl35 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd35.heap.get (2702205 + j) = nth? PRE_first_tail_x15_r0_body.pl35 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja35 : Nat.ble 2702205 2702205 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn35 : Nat.ble 1549 1549 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD35 : Nat.ble 2702205 PRE_first_tail_x15_r0_body.kd35.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn35 : Nat.ble 18889 PRE_first_tail_x15_r0_body.kd35.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn35 : Nat.ble 15970 PRE_first_tail_x15_r0_body.kd35.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb35 : Nat.ble 18889 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap35 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd35.heap).all (Nat.ble (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd35 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd35.hnd).all (Nat.ble (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode35 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd35.node).all (Nat.ble (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix35 : Conv.FixOld (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa35 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja35) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn35) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD35) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn35) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn35) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb35) PRE_first_tail_x15_r0_body.fheap35 PRE_first_tail_x15_r0_body.fhnd35 PRE_first_tail_x15_r0_body.fnode35
kernel_rfl PRE_first_tail_x15_r0_body.fcxn35 : (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn35 : (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle035 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_35.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_35.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk35 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd35.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A35 : PRE_first_tail_x15_r0_body.cx1_35.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS35.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_35.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O35 : PRE_first_tail_x15_r0_body.cx1_35.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS35.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_35.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N35 : PRE_first_tail_x15_r0_body.cx1_35.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS35.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_35.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I35 : PRE_first_tail_x15_r0_body.cx1_35.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS35.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_35.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd35 : (PRE_first_tail_x15_r0_body.clo35 ++ PRE_first_tail_x15_r0_body.cln35 ++ PRE_first_tail_x15_r0_body.cli35 ++ PRE_first_tail_x15_r0_body.cwS35 ++ PRE_first_tail_x15_r0_body.cnS35 ++ PRE_first_tail_x15_r0_body.ciS35).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW35 : PRE_first_tail_x15_r0_body.cwS35.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo35.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI35 : PRE_first_tail_x15_r0_body.ciS35.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli35.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN35 : PRE_first_tail_x15_r0_body.cnS35.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF35 : PRE_first_tail_x15_r0_body.cln35.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh35 : PRE_first_tail_x15_r0_body.clo35.all (handleOK PRE_first_tail_x15_r0_body.kappa35 PRE_first_tail_x15_r0_body.P35.lo PRE_first_tail_x15_r0_body.cx0_35.mlx PRE_first_tail_x15_r0_body.cx1_35.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo35 : PRE_first_tail_x15_r0_body.clo35.map (fun h => PRE_first_tail_x15_r0_body.cx1_35.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa35.handle h)) = PRE_first_tail_x15_r0_body.clo35.map (fun h => (PRE_first_tail_x15_r0_body.cx0_35.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa35.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok35 : PRE_first_tail_x15_r0_body.clo35.all (objOK PRE_first_tail_x15_r0_body.kappa35 PRE_first_tail_x15_r0_body.P35.NL PRE_first_tail_x15_r0_body.cx0_35.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd35 : PRE_first_tail_x15_r0_body.cln35.all (nodeOKF PRE_first_tail_x15_r0_body.kappa35 PRE_first_tail_x15_r0_body.P35 PRE_first_tail_x15_r0_body.cx0_35.mlx PRE_first_tail_x15_r0_body.cx1_35.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp35 : ((PRE_first_tail_x15_r0_body.cln35.filter (fullB PRE_first_tail_x15_r0_body.P35))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_35.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa35.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln35.filter (fullB PRE_first_tail_x15_r0_body.P35))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_35.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa35.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI35 : incrB PRE_first_tail_x15_r0_body.kd35.nodeF (List.range' 15970 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK35 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd35.node).all (fun k => Nat.ble 15970 k && Nat.blt k 15970) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL35 : (PRE_first_tail_x15_r0_body.cln35.filter (Nat.ble PRE_first_tail_x15_r0_body.P35.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd35.nodeF i) && (Nat.blt i 15970 || Nat.ble PRE_first_tail_x15_r0_body.kd35.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord35 : (PRE_first_tail_x15_r0_body.cln35.filter (Nat.ble PRE_first_tail_x15_r0_body.P35.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd35.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd35.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd35.nodeF j) (PRE_first_tail_x15_r0_body.kd35.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow35 PRE_first_tail_x15_r0_body.cnn135 PRE_first_tail_x15_r0_body.fnordI35 PRE_first_tail_x15_r0_body.fnordK35 PRE_first_tail_x15_r0_body.fnordL35
kernel_rfl PRE_first_tail_x15_r0_body.fi35 : PRE_first_tail_x15_r0_body.cli35.all (pnB PRE_first_tail_x15_r0_body.cx0_35.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii35 : PRE_first_tail_x15_r0_body.cli35.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_35.mlx.items.get (PRE_first_tail_x15_r0_body.kappa35.node k) = (PRE_first_tail_x15_r0_body.cx0_35.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa35.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot35 (clean : Conv.NClean (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P35.NL) (cl : SSt (· < 1549) PRE_first_tail_x15_r0_body.cx0_35.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P35 1549 PRE_first_tail_x15_r0_body.kappa35 PRE_first_tail_x15_r0_body.kd35 PRE_first_tail_x15_r0_body.khinv35 PRE_first_tail_x15_r0_body.kninv35 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx PRE_first_tail_x15_r0_body.cx0_35.mlx PRE_first_tail_x15_r0_body.cx1_35.mlx (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo35 PRE_first_tail_x15_r0_body.cln35 PRE_first_tail_x15_r0_body.cli35 PRE_first_tail_x15_r0_body.cwS35 PRE_first_tail_x15_r0_body.cnS35 PRE_first_tail_x15_r0_body.ciS35 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh035, PRE_first_tail_x15_r0_body.cnh135, PRE_first_tail_x15_r0_body.cnn035, PRE_first_tail_x15_r0_body.cnn135, PRE_first_tail_x15_r0_body.cplo35, PRE_first_tail_x15_r0_body.ccnt35, PRE_first_tail_x15_r0_body.cnband35, PRE_first_tail_x15_r0_body.chbelow35, PRE_first_tail_x15_r0_body.chren35, PRE_first_tail_x15_r0_body.cband35, PRE_first_tail_x15_r0_body.cnh1pos35, PRE_first_tail_x15_r0_body.cnren35, PRE_first_tail_x15_r0_body.cnlow35, PRE_first_tail_x15_r0_body.cabs0a35, PRE_first_tail_x15_r0_body.cabs0b35, PRE_first_tail_x15_r0_body.ctok135, PRE_first_tail_x15_r0_body.cpend35, PRE_first_tail_x15_r0_body.cerrh35, PRE_first_tail_x15_r0_body.cfiles35, PRE_first_tail_x15_r0_body.carch35, PRE_first_tail_x15_r0_body.csizes35, PRE_first_tail_x15_r0_body.cwired35, PRE_first_tail_x15_r0_body.cfix35, clean, PRE_first_tail_x15_r0_body.fcxn35, PRE_first_tail_x15_r0_body.fcnn35, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle035, PRE_first_tail_x15_r0_body.fnk35, PRE_first_tail_x15_r0_body.ckA35, PRE_first_tail_x15_r0_body.cobjsK35, PRE_first_tail_x15_r0_body.cnodesK35, PRE_first_tail_x15_r0_body.citemsK35, PRE_first_tail_x15_r0_body.f1A35, PRE_first_tail_x15_r0_body.f1O35, PRE_first_tail_x15_r0_body.f1N35, PRE_first_tail_x15_r0_body.f1I35, PRE_first_tail_x15_r0_body.fbd35, PRE_first_tail_x15_r0_body.fincW35, PRE_first_tail_x15_r0_body.fincI35, PRE_first_tail_x15_r0_body.fincN35, PRE_first_tail_x15_r0_body.flnF35, PRE_first_tail_x15_r0_body.fh35, PRE_first_tail_x15_r0_body.fo35, PRE_first_tail_x15_r0_body.fok35, PRE_first_tail_x15_r0_body.fnd35, PRE_first_tail_x15_r0_body.fp35, PRE_first_tail_x15_r0_body.fnord35, PRE_first_tail_x15_r0_body.fi35, PRE_first_tail_x15_r0_body.fii35⟩
theorem PRE_first_tail_x15_r0_body.cnshift35 (clean : Conv.NClean (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P35.NL) (cl : SSt (· < 1549) PRE_first_tail_x15_r0_body.cx0_35.mlx) : NShift PRE_first_tail_x15_r0_body.P35 1549 PRE_first_tail_x15_r0_body.kappa35 PRE_first_tail_x15_r0_body.cx0_35 PRE_first_tail_x15_r0_body.cx1_35 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot35 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost35 (compact_a_eq PRE_first_tail_x15_r0_body.ckn035 PRE_first_tail_x15_r0_body.ckn135 PRE_first_tail_x15_r0_body.ckheap35 PRE_first_tail_x15_r0_body.ckpl35)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_35 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s313.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_35 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s313.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_35 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s313.ffi) = some PRE_first_tail_x15_r0_body.fxC_35
kernel_rfl PRE_first_tail_x15_r0_body.okrC_35 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s313.ffi) = some PRE_first_tail_x15_r0_body.krC_35
noncomputable def PRE_first_tail_x15_r0_body.fx0_35 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s315.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_35 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s315.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_35 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s315.ffi) = some PRE_first_tail_x15_r0_body.fx0_35
kernel_rfl PRE_first_tail_x15_r0_body.okr0_35 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s315.ffi) = some PRE_first_tail_x15_r0_body.kr0_35
noncomputable def PRE_first_tail_x15_r0_body.fx1_35 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s314.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_35 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s314.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_35 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s314.ffi) = some PRE_first_tail_x15_r0_body.fx1_35
kernel_rfl PRE_first_tail_x15_r0_body.okr1_35 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s314.ffi) = some PRE_first_tail_x15_r0_body.kr1_35
kernel_rfl PRE_first_tail_x15_r0_body.ff035 : PRE_first_tail_x15_r0_body.fx0_35 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_35 (PRE_first_tail_x15_r0_body.clo35.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_35.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff135 : PRE_first_tail_x15_r0_body.fx1_35 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_35 (PRE_first_tail_x15_r0_body.cwS35.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_35.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck35 : freedLB PRE_first_tail_x15_r0_body.kappa35 PRE_first_tail_x15_r0_body.cx0_35.mlx PRE_first_tail_x15_r0_body.fx0_35 PRE_first_tail_x15_r0_body.fx1_35 PRE_first_tail_x15_r0_body.clo35 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf035 : PRE_first_tail_x15_r0_body.kr0_35.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_35.flags (PRE_first_tail_x15_r0_body.clo35.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_35.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt035 : PRE_first_tail_x15_r0_body.kr0_35.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_35.targs (PRE_first_tail_x15_r0_body.clo35.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_35.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf135 : PRE_first_tail_x15_r0_body.kr1_35.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_35.flags (PRE_first_tail_x15_r0_body.cwS35.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_35.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt135 : PRE_first_tail_x15_r0_body.kr1_35.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_35.targs (PRE_first_tail_x15_r0_body.cwS35.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_35.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck35 : krecLB PRE_first_tail_x15_r0_body.kappa35 1549 PRE_first_tail_x15_r0_body.cx0_35.mlx PRE_first_tail_x15_r0_body.kr0_35 PRE_first_tail_x15_r0_body.kr1_35 PRE_first_tail_x15_r0_body.clo35 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn35 : Nat.ble 1549 1549 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge35 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s314.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s315.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR35 : pendRegB PRE_first_tail_x15_r0_body.kappa35 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s315.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe35 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s315.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s314.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift35 (clean : Conv.NClean (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P35.NL) (cl : SSt (· < 1549) PRE_first_tail_x15_r0_body.cx0_35.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_35.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_35.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_35.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_35.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P35 1549 PRE_first_tail_x15_r0_body.kappa35 PRE_first_tail_x15_r0_body.s315.ffi PRE_first_tail_x15_r0_body.s314.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift35 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue35, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp35 t ht),
    PRE_first_tail_x15_r0_body.cbridge35,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s315.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s314.ffi) (PRE_first_tail_x15_r0_body.cfoot35 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_35 PRE_first_tail_x15_r0_body.ofx1_35 hobjC PRE_first_tail_x15_r0_body.ff035 PRE_first_tail_x15_r0_body.ff135 PRE_first_tail_x15_r0_body.ffck35,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s315.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s314.ffi) (PRE_first_tail_x15_r0_body.cfoot35 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_35 PRE_first_tail_x15_r0_body.okr1_35 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn35) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf035 PRE_first_tail_x15_r0_body.fkt035 PRE_first_tail_x15_r0_body.fkf135 PRE_first_tail_x15_r0_body.fkt135 PRE_first_tail_x15_r0_body.fkck35,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh035 PRE_first_tail_x15_r0_body.cnh135 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe35) PRE_first_tail_x15_r0_body.cpendR35⟩

end Host.Load.Run.Tpl
