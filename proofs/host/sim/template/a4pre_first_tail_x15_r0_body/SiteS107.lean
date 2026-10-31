import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl107
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 107 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc107 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P107 : LoadP := PRE_first_tail_x15_r0_body.Pc107.raise 17392
kernel_rfl PRE_first_tail_x15_r0_body.craise107 : Nat.ble PRE_first_tail_x15_r0_body.Pc107.N0 17392 = true
theorem PRE_first_tail_x15_r0_body.raised107 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc107 PRE_first_tail_x15_r0_body.P107 :=
  .inr ⟨17392, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise107, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_107 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s945.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_107 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s944.ffi)
def PRE_first_tail_x15_r0_body.khinv107 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv107 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS107 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS107 : List Nat := List.range' 17392 0
def PRE_first_tail_x15_r0_body.ciS107 : List Nat := [] ++ List.range' 17392 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0107 : PRE_first_tail_x15_r0_body.kd107.nh0 = PRE_first_tail_x15_r0_body.cx0_107.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1107 : PRE_first_tail_x15_r0_body.kd107.nh1 = PRE_first_tail_x15_r0_body.cx1_107.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0107 : PRE_first_tail_x15_r0_body.kd107.nn0 = PRE_first_tail_x15_r0_body.cx0_107.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1107 : PRE_first_tail_x15_r0_body.kd107.nn1 = PRE_first_tail_x15_r0_body.cx1_107.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo107 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P107.lo && Nat.ble PRE_first_tail_x15_r0_body.P107.lo PRE_first_tail_x15_r0_body.cx0_107.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P107.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P107.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt107 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_107.mlx.next PRE_first_tail_x15_r0_body.cx1_107.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_107.mlx.nnext PRE_first_tail_x15_r0_body.cx1_107.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband107 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P107.NL && Nat.ble PRE_first_tail_x15_r0_body.P107.NL PRE_first_tail_x15_r0_body.P107.N0 && Nat.ble PRE_first_tail_x15_r0_body.P107.N0 PRE_first_tail_x15_r0_body.cx0_107.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow107 : PRE_first_tail_x15_r0_body.kd107.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren107 : checkRenG PRE_first_tail_x15_r0_body.kd107.hnd PRE_first_tail_x15_r0_body.khinv107 (phB PRE_first_tail_x15_r0_body.cx0_107.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband107 : PRE_first_tail_x15_r0_body.kd107.checkBand PRE_first_tail_x15_r0_body.P107.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos107 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd107.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren107 : checkRenG PRE_first_tail_x15_r0_body.kd107.node PRE_first_tail_x15_r0_body.kninv107 (pnB PRE_first_tail_x15_r0_body.cx0_107.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P107.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd107.nodeF j) PRE_first_tail_x15_r0_body.cx1_107.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a107 : PRE_first_tail_x15_r0_body.cx0_107.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b107 : PRE_first_tail_x15_r0_body.cx0_107.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.pending = PRE_first_tail_x15_r0_body.cx0_107.mlx.pending.map PRE_first_tail_x15_r0_body.kappa107.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.errh = PRE_first_tail_x15_r0_body.cx0_107.mlx.errh.map PRE_first_tail_x15_r0_body.kappa107.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.files = PRE_first_tail_x15_r0_body.cx0_107.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.arch = PRE_first_tail_x15_r0_body.cx0_107.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_107.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.wired = PRE_first_tail_x15_r0_body.cx0_107.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost107 : PRE_first_tail_x15_r0_body.cx1_107.host = PRE_first_tail_x15_r0_body.cx0_107.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd107`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0107 : PRE_first_tail_x15_r0_body.kd107.n0 = 2758718
kernel_rfl PRE_first_tail_x15_r0_body.ckn1107 : PRE_first_tail_x15_r0_body.kd107.n1 = 2758728
kernel_rfl PRE_first_tail_x15_r0_body.ckheap107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.heap).all (fun x => Nat.ble 2758717 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl107 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd107.heap.get (2758717 + j) = nth? PRE_first_tail_x15_r0_body.pl107 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja107 : Nat.ble 2758717 2758717 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn107 : Nat.ble 4627 4627 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD107 : Nat.ble 2758717 PRE_first_tail_x15_r0_body.kd107.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn107 : Nat.ble 20305 PRE_first_tail_x15_r0_body.kd107.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn107 : Nat.ble 17392 PRE_first_tail_x15_r0_body.kd107.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb107 : Nat.ble 20305 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.heap).all (Nat.ble (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.hnd).all (Nat.ble (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.node).all (Nat.ble (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix107 : Conv.FixOld (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa107 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja107) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn107) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD107) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn107) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn107) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb107) PRE_first_tail_x15_r0_body.fheap107 PRE_first_tail_x15_r0_body.fhnd107 PRE_first_tail_x15_r0_body.fnode107
kernel_rfl PRE_first_tail_x15_r0_body.fcxn107 : (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn107 : (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0107 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_107.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_107.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS107.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_107.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS107.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_107.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS107.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_107.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I107 : PRE_first_tail_x15_r0_body.cx1_107.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS107.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_107.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd107 : (PRE_first_tail_x15_r0_body.clo107 ++ PRE_first_tail_x15_r0_body.cln107 ++ PRE_first_tail_x15_r0_body.cli107 ++ PRE_first_tail_x15_r0_body.cwS107 ++ PRE_first_tail_x15_r0_body.cnS107 ++ PRE_first_tail_x15_r0_body.ciS107).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW107 : PRE_first_tail_x15_r0_body.cwS107.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo107.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI107 : PRE_first_tail_x15_r0_body.ciS107.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli107.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN107 : PRE_first_tail_x15_r0_body.cnS107.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF107 : PRE_first_tail_x15_r0_body.cln107.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh107 : PRE_first_tail_x15_r0_body.clo107.all (handleOK PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.P107.lo PRE_first_tail_x15_r0_body.cx0_107.mlx PRE_first_tail_x15_r0_body.cx1_107.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo107 : PRE_first_tail_x15_r0_body.clo107.map (fun h => PRE_first_tail_x15_r0_body.cx1_107.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa107.handle h)) = PRE_first_tail_x15_r0_body.clo107.map (fun h => (PRE_first_tail_x15_r0_body.cx0_107.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa107.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok107 : PRE_first_tail_x15_r0_body.clo107.all (objOK PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.P107.NL PRE_first_tail_x15_r0_body.cx0_107.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd107 : PRE_first_tail_x15_r0_body.cln107.all (nodeOKF PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.P107 PRE_first_tail_x15_r0_body.cx0_107.mlx PRE_first_tail_x15_r0_body.cx1_107.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp107 : ((PRE_first_tail_x15_r0_body.cln107.filter (fullB PRE_first_tail_x15_r0_body.P107))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_107.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa107.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln107.filter (fullB PRE_first_tail_x15_r0_body.P107))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_107.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa107.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI107 : incrB PRE_first_tail_x15_r0_body.kd107.nodeF (List.range' 17392 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK107 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.node).all (fun k => Nat.ble 17392 k && Nat.blt k 17392) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL107 : (PRE_first_tail_x15_r0_body.cln107.filter (Nat.ble PRE_first_tail_x15_r0_body.P107.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd107.nodeF i) && (Nat.blt i 17392 || Nat.ble PRE_first_tail_x15_r0_body.kd107.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord107 : (PRE_first_tail_x15_r0_body.cln107.filter (Nat.ble PRE_first_tail_x15_r0_body.P107.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd107.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd107.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd107.nodeF j) (PRE_first_tail_x15_r0_body.kd107.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow107 PRE_first_tail_x15_r0_body.cnn1107 PRE_first_tail_x15_r0_body.fnordI107 PRE_first_tail_x15_r0_body.fnordK107 PRE_first_tail_x15_r0_body.fnordL107
kernel_rfl PRE_first_tail_x15_r0_body.fi107 : PRE_first_tail_x15_r0_body.cli107.all (pnB PRE_first_tail_x15_r0_body.cx0_107.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii107 : PRE_first_tail_x15_r0_body.cli107.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_107.mlx.items.get (PRE_first_tail_x15_r0_body.kappa107.node k) = (PRE_first_tail_x15_r0_body.cx0_107.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa107.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot107 (clean : Conv.NClean (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P107.NL) (cl : SSt (· < 4627) PRE_first_tail_x15_r0_body.cx0_107.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P107 4627 PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.kd107 PRE_first_tail_x15_r0_body.khinv107 PRE_first_tail_x15_r0_body.kninv107 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx PRE_first_tail_x15_r0_body.cx0_107.mlx PRE_first_tail_x15_r0_body.cx1_107.mlx (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo107 PRE_first_tail_x15_r0_body.cln107 PRE_first_tail_x15_r0_body.cli107 PRE_first_tail_x15_r0_body.cwS107 PRE_first_tail_x15_r0_body.cnS107 PRE_first_tail_x15_r0_body.ciS107 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0107, PRE_first_tail_x15_r0_body.cnh1107, PRE_first_tail_x15_r0_body.cnn0107, PRE_first_tail_x15_r0_body.cnn1107, PRE_first_tail_x15_r0_body.cplo107, PRE_first_tail_x15_r0_body.ccnt107, PRE_first_tail_x15_r0_body.cnband107, PRE_first_tail_x15_r0_body.chbelow107, PRE_first_tail_x15_r0_body.chren107, PRE_first_tail_x15_r0_body.cband107, PRE_first_tail_x15_r0_body.cnh1pos107, PRE_first_tail_x15_r0_body.cnren107, PRE_first_tail_x15_r0_body.cnlow107, PRE_first_tail_x15_r0_body.cabs0a107, PRE_first_tail_x15_r0_body.cabs0b107, PRE_first_tail_x15_r0_body.ctok1107, PRE_first_tail_x15_r0_body.cpend107, PRE_first_tail_x15_r0_body.cerrh107, PRE_first_tail_x15_r0_body.cfiles107, PRE_first_tail_x15_r0_body.carch107, PRE_first_tail_x15_r0_body.csizes107, PRE_first_tail_x15_r0_body.cwired107, PRE_first_tail_x15_r0_body.cfix107, clean, PRE_first_tail_x15_r0_body.fcxn107, PRE_first_tail_x15_r0_body.fcnn107, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0107, PRE_first_tail_x15_r0_body.fnk107, PRE_first_tail_x15_r0_body.ckA107, PRE_first_tail_x15_r0_body.cobjsK107, PRE_first_tail_x15_r0_body.cnodesK107, PRE_first_tail_x15_r0_body.citemsK107, PRE_first_tail_x15_r0_body.f1A107, PRE_first_tail_x15_r0_body.f1O107, PRE_first_tail_x15_r0_body.f1N107, PRE_first_tail_x15_r0_body.f1I107, PRE_first_tail_x15_r0_body.fbd107, PRE_first_tail_x15_r0_body.fincW107, PRE_first_tail_x15_r0_body.fincI107, PRE_first_tail_x15_r0_body.fincN107, PRE_first_tail_x15_r0_body.flnF107, PRE_first_tail_x15_r0_body.fh107, PRE_first_tail_x15_r0_body.fo107, PRE_first_tail_x15_r0_body.fok107, PRE_first_tail_x15_r0_body.fnd107, PRE_first_tail_x15_r0_body.fp107, PRE_first_tail_x15_r0_body.fnord107, PRE_first_tail_x15_r0_body.fi107, PRE_first_tail_x15_r0_body.fii107⟩
theorem PRE_first_tail_x15_r0_body.cnshift107 (clean : Conv.NClean (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P107.NL) (cl : SSt (· < 4627) PRE_first_tail_x15_r0_body.cx0_107.mlx) : NShift PRE_first_tail_x15_r0_body.P107 4627 PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.cx0_107 PRE_first_tail_x15_r0_body.cx1_107 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot107 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost107 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0107 PRE_first_tail_x15_r0_body.ckn1107 PRE_first_tail_x15_r0_body.ckheap107 PRE_first_tail_x15_r0_body.ckpl107)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_107 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s943.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_107 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s943.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_107 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s943.ffi) = some PRE_first_tail_x15_r0_body.fxC_107
kernel_rfl PRE_first_tail_x15_r0_body.okrC_107 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s943.ffi) = some PRE_first_tail_x15_r0_body.krC_107
noncomputable def PRE_first_tail_x15_r0_body.fx0_107 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s945.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_107 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s945.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_107 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s945.ffi) = some PRE_first_tail_x15_r0_body.fx0_107
kernel_rfl PRE_first_tail_x15_r0_body.okr0_107 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s945.ffi) = some PRE_first_tail_x15_r0_body.kr0_107
noncomputable def PRE_first_tail_x15_r0_body.fx1_107 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s944.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_107 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s944.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_107 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s944.ffi) = some PRE_first_tail_x15_r0_body.fx1_107
kernel_rfl PRE_first_tail_x15_r0_body.okr1_107 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s944.ffi) = some PRE_first_tail_x15_r0_body.kr1_107
kernel_rfl PRE_first_tail_x15_r0_body.ff0107 : PRE_first_tail_x15_r0_body.fx0_107 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_107 (PRE_first_tail_x15_r0_body.clo107.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_107.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1107 : PRE_first_tail_x15_r0_body.fx1_107 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_107 (PRE_first_tail_x15_r0_body.cwS107.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_107.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck107 : freedLB PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.cx0_107.mlx PRE_first_tail_x15_r0_body.fx0_107 PRE_first_tail_x15_r0_body.fx1_107 PRE_first_tail_x15_r0_body.clo107 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0107 : PRE_first_tail_x15_r0_body.kr0_107.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_107.flags (PRE_first_tail_x15_r0_body.clo107.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_107.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0107 : PRE_first_tail_x15_r0_body.kr0_107.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_107.targs (PRE_first_tail_x15_r0_body.clo107.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_107.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1107 : PRE_first_tail_x15_r0_body.kr1_107.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_107.flags (PRE_first_tail_x15_r0_body.cwS107.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_107.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1107 : PRE_first_tail_x15_r0_body.kr1_107.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_107.targs (PRE_first_tail_x15_r0_body.cwS107.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_107.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck107 : krecLB PRE_first_tail_x15_r0_body.kappa107 4627 PRE_first_tail_x15_r0_body.cx0_107.mlx PRE_first_tail_x15_r0_body.kr0_107 PRE_first_tail_x15_r0_body.kr1_107 PRE_first_tail_x15_r0_body.clo107 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn107 : Nat.ble 4627 4627 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge107 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s944.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s945.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR107 : pendRegB PRE_first_tail_x15_r0_body.kappa107 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s945.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe107 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s945.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s944.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift107 (clean : Conv.NClean (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P107.NL) (cl : SSt (· < 4627) PRE_first_tail_x15_r0_body.cx0_107.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_107.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_107.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_107.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s943.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_107.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P107 4627 PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.s945.ffi PRE_first_tail_x15_r0_body.s944.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift107 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue107, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp107 t ht),
    PRE_first_tail_x15_r0_body.cbridge107,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s945.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s944.ffi) (PRE_first_tail_x15_r0_body.cfoot107 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_107 PRE_first_tail_x15_r0_body.ofx1_107 hobjC PRE_first_tail_x15_r0_body.ff0107 PRE_first_tail_x15_r0_body.ff1107 PRE_first_tail_x15_r0_body.ffck107,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s945.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s944.ffi) (PRE_first_tail_x15_r0_body.cfoot107 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_107 PRE_first_tail_x15_r0_body.okr1_107 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn107) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0107 PRE_first_tail_x15_r0_body.fkt0107 PRE_first_tail_x15_r0_body.fkf1107 PRE_first_tail_x15_r0_body.fkt1107 PRE_first_tail_x15_r0_body.fkck107,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0107 PRE_first_tail_x15_r0_body.cnh1107 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe107) PRE_first_tail_x15_r0_body.cpendR107⟩

end Host.Load.Run.Tpl
