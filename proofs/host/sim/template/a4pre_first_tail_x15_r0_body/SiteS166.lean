import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl166
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 166 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc166 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P166 : LoadP := PRE_first_tail_x15_r0_body.Pc166.raise 18573
kernel_rfl PRE_first_tail_x15_r0_body.craise166 : Nat.ble PRE_first_tail_x15_r0_body.Pc166.N0 18573 = true
theorem PRE_first_tail_x15_r0_body.raised166 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc166 PRE_first_tail_x15_r0_body.P166 :=
  .inr ⟨18573, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise166, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_166 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_166 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1465.ffi)
def PRE_first_tail_x15_r0_body.khinv166 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv166 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS166 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS166 : List Nat := List.range' 18573 0
def PRE_first_tail_x15_r0_body.ciS166 : List Nat := [] ++ List.range' 18573 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0166 : PRE_first_tail_x15_r0_body.kd166.nh0 = PRE_first_tail_x15_r0_body.cx0_166.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1166 : PRE_first_tail_x15_r0_body.kd166.nh1 = PRE_first_tail_x15_r0_body.cx1_166.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0166 : PRE_first_tail_x15_r0_body.kd166.nn0 = PRE_first_tail_x15_r0_body.cx0_166.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1166 : PRE_first_tail_x15_r0_body.kd166.nn1 = PRE_first_tail_x15_r0_body.cx1_166.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo166 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P166.lo && Nat.ble PRE_first_tail_x15_r0_body.P166.lo PRE_first_tail_x15_r0_body.cx0_166.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P166.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P166.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt166 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_166.mlx.next PRE_first_tail_x15_r0_body.cx1_166.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_166.mlx.nnext PRE_first_tail_x15_r0_body.cx1_166.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband166 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P166.NL && Nat.ble PRE_first_tail_x15_r0_body.P166.NL PRE_first_tail_x15_r0_body.P166.N0 && Nat.ble PRE_first_tail_x15_r0_body.P166.N0 PRE_first_tail_x15_r0_body.cx0_166.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow166 : PRE_first_tail_x15_r0_body.kd166.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren166 : checkRenG PRE_first_tail_x15_r0_body.kd166.hnd PRE_first_tail_x15_r0_body.khinv166 (phB PRE_first_tail_x15_r0_body.cx0_166.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband166 : PRE_first_tail_x15_r0_body.kd166.checkBand PRE_first_tail_x15_r0_body.P166.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos166 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd166.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren166 : checkRenG PRE_first_tail_x15_r0_body.kd166.node PRE_first_tail_x15_r0_body.kninv166 (pnB PRE_first_tail_x15_r0_body.cx0_166.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow166 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd166.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P166.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd166.nodeF j) PRE_first_tail_x15_r0_body.cx1_166.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a166 : PRE_first_tail_x15_r0_body.cx0_166.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b166 : PRE_first_tail_x15_r0_body.cx0_166.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1166 : PRE_first_tail_x15_r0_body.cx1_166.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend166 : PRE_first_tail_x15_r0_body.cx1_166.mlx.pending = PRE_first_tail_x15_r0_body.cx0_166.mlx.pending.map PRE_first_tail_x15_r0_body.kappa166.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh166 : PRE_first_tail_x15_r0_body.cx1_166.mlx.errh = PRE_first_tail_x15_r0_body.cx0_166.mlx.errh.map PRE_first_tail_x15_r0_body.kappa166.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles166 : PRE_first_tail_x15_r0_body.cx1_166.mlx.files = PRE_first_tail_x15_r0_body.cx0_166.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch166 : PRE_first_tail_x15_r0_body.cx1_166.mlx.arch = PRE_first_tail_x15_r0_body.cx0_166.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes166 : PRE_first_tail_x15_r0_body.cx1_166.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_166.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired166 : PRE_first_tail_x15_r0_body.cx1_166.mlx.wired = PRE_first_tail_x15_r0_body.cx0_166.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost166 : PRE_first_tail_x15_r0_body.cx1_166.host = PRE_first_tail_x15_r0_body.cx0_166.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd166`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0166 : PRE_first_tail_x15_r0_body.kd166.n0 = 2805513
kernel_rfl PRE_first_tail_x15_r0_body.ckn1166 : PRE_first_tail_x15_r0_body.kd166.n1 = 2805515
kernel_rfl PRE_first_tail_x15_r0_body.ckheap166 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd166.heap).all (fun x => Nat.ble 2805513 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl166 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd166.heap.get (2805513 + j) = nth? PRE_first_tail_x15_r0_body.pl166 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja166 : Nat.ble 2805513 2805513 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn166 : Nat.ble 7175 7175 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD166 : Nat.ble 2805513 PRE_first_tail_x15_r0_body.kd166.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn166 : Nat.ble 21478 PRE_first_tail_x15_r0_body.kd166.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn166 : Nat.ble 18573 PRE_first_tail_x15_r0_body.kd166.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb166 : Nat.ble 21478 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap166 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd166.heap).all (Nat.ble (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd166 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd166.hnd).all (Nat.ble (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode166 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd166.node).all (Nat.ble (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix166 : Conv.FixOld (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa166 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja166) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn166) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD166) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn166) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn166) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb166) PRE_first_tail_x15_r0_body.fheap166 PRE_first_tail_x15_r0_body.fhnd166 PRE_first_tail_x15_r0_body.fnode166
kernel_rfl PRE_first_tail_x15_r0_body.fcxn166 : (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn166 : (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0166 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_166.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_166.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk166 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd166.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A166 : PRE_first_tail_x15_r0_body.cx1_166.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS166.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_166.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O166 : PRE_first_tail_x15_r0_body.cx1_166.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS166.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_166.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N166 : PRE_first_tail_x15_r0_body.cx1_166.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS166.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_166.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I166 : PRE_first_tail_x15_r0_body.cx1_166.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS166.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_166.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd166 : (PRE_first_tail_x15_r0_body.clo166 ++ PRE_first_tail_x15_r0_body.cln166 ++ PRE_first_tail_x15_r0_body.cli166 ++ PRE_first_tail_x15_r0_body.cwS166 ++ PRE_first_tail_x15_r0_body.cnS166 ++ PRE_first_tail_x15_r0_body.ciS166).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW166 : PRE_first_tail_x15_r0_body.cwS166.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo166.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI166 : PRE_first_tail_x15_r0_body.ciS166.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli166.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN166 : PRE_first_tail_x15_r0_body.cnS166.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF166 : PRE_first_tail_x15_r0_body.cln166.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh166 : PRE_first_tail_x15_r0_body.clo166.all (handleOK PRE_first_tail_x15_r0_body.kappa166 PRE_first_tail_x15_r0_body.P166.lo PRE_first_tail_x15_r0_body.cx0_166.mlx PRE_first_tail_x15_r0_body.cx1_166.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo166 : PRE_first_tail_x15_r0_body.clo166.map (fun h => PRE_first_tail_x15_r0_body.cx1_166.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa166.handle h)) = PRE_first_tail_x15_r0_body.clo166.map (fun h => (PRE_first_tail_x15_r0_body.cx0_166.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa166.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok166 : PRE_first_tail_x15_r0_body.clo166.all (objOK PRE_first_tail_x15_r0_body.kappa166 PRE_first_tail_x15_r0_body.P166.NL PRE_first_tail_x15_r0_body.cx0_166.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd166 : PRE_first_tail_x15_r0_body.cln166.all (nodeOKF PRE_first_tail_x15_r0_body.kappa166 PRE_first_tail_x15_r0_body.P166 PRE_first_tail_x15_r0_body.cx0_166.mlx PRE_first_tail_x15_r0_body.cx1_166.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp166 : ((PRE_first_tail_x15_r0_body.cln166.filter (fullB PRE_first_tail_x15_r0_body.P166))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_166.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa166.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln166.filter (fullB PRE_first_tail_x15_r0_body.P166))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_166.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa166.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI166 : incrB PRE_first_tail_x15_r0_body.kd166.nodeF (List.range' 18573 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK166 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd166.node).all (fun k => Nat.ble 18573 k && Nat.blt k 18573) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL166 : (PRE_first_tail_x15_r0_body.cln166.filter (Nat.ble PRE_first_tail_x15_r0_body.P166.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd166.nodeF i) && (Nat.blt i 18573 || Nat.ble PRE_first_tail_x15_r0_body.kd166.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord166 : (PRE_first_tail_x15_r0_body.cln166.filter (Nat.ble PRE_first_tail_x15_r0_body.P166.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd166.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd166.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd166.nodeF j) (PRE_first_tail_x15_r0_body.kd166.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow166 PRE_first_tail_x15_r0_body.cnn1166 PRE_first_tail_x15_r0_body.fnordI166 PRE_first_tail_x15_r0_body.fnordK166 PRE_first_tail_x15_r0_body.fnordL166
kernel_rfl PRE_first_tail_x15_r0_body.fi166 : PRE_first_tail_x15_r0_body.cli166.all (pnB PRE_first_tail_x15_r0_body.cx0_166.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii166 : PRE_first_tail_x15_r0_body.cli166.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_166.mlx.items.get (PRE_first_tail_x15_r0_body.kappa166.node k) = (PRE_first_tail_x15_r0_body.cx0_166.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa166.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot166 (clean : Conv.NClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P166.NL) (cl : SSt (· < 7175) PRE_first_tail_x15_r0_body.cx0_166.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P166 7175 PRE_first_tail_x15_r0_body.kappa166 PRE_first_tail_x15_r0_body.kd166 PRE_first_tail_x15_r0_body.khinv166 PRE_first_tail_x15_r0_body.kninv166 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx PRE_first_tail_x15_r0_body.cx0_166.mlx PRE_first_tail_x15_r0_body.cx1_166.mlx (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo166 PRE_first_tail_x15_r0_body.cln166 PRE_first_tail_x15_r0_body.cli166 PRE_first_tail_x15_r0_body.cwS166 PRE_first_tail_x15_r0_body.cnS166 PRE_first_tail_x15_r0_body.ciS166 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0166, PRE_first_tail_x15_r0_body.cnh1166, PRE_first_tail_x15_r0_body.cnn0166, PRE_first_tail_x15_r0_body.cnn1166, PRE_first_tail_x15_r0_body.cplo166, PRE_first_tail_x15_r0_body.ccnt166, PRE_first_tail_x15_r0_body.cnband166, PRE_first_tail_x15_r0_body.chbelow166, PRE_first_tail_x15_r0_body.chren166, PRE_first_tail_x15_r0_body.cband166, PRE_first_tail_x15_r0_body.cnh1pos166, PRE_first_tail_x15_r0_body.cnren166, PRE_first_tail_x15_r0_body.cnlow166, PRE_first_tail_x15_r0_body.cabs0a166, PRE_first_tail_x15_r0_body.cabs0b166, PRE_first_tail_x15_r0_body.ctok1166, PRE_first_tail_x15_r0_body.cpend166, PRE_first_tail_x15_r0_body.cerrh166, PRE_first_tail_x15_r0_body.cfiles166, PRE_first_tail_x15_r0_body.carch166, PRE_first_tail_x15_r0_body.csizes166, PRE_first_tail_x15_r0_body.cwired166, PRE_first_tail_x15_r0_body.cfix166, clean, PRE_first_tail_x15_r0_body.fcxn166, PRE_first_tail_x15_r0_body.fcnn166, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0166, PRE_first_tail_x15_r0_body.fnk166, PRE_first_tail_x15_r0_body.ckA166, PRE_first_tail_x15_r0_body.cobjsK166, PRE_first_tail_x15_r0_body.cnodesK166, PRE_first_tail_x15_r0_body.citemsK166, PRE_first_tail_x15_r0_body.f1A166, PRE_first_tail_x15_r0_body.f1O166, PRE_first_tail_x15_r0_body.f1N166, PRE_first_tail_x15_r0_body.f1I166, PRE_first_tail_x15_r0_body.fbd166, PRE_first_tail_x15_r0_body.fincW166, PRE_first_tail_x15_r0_body.fincI166, PRE_first_tail_x15_r0_body.fincN166, PRE_first_tail_x15_r0_body.flnF166, PRE_first_tail_x15_r0_body.fh166, PRE_first_tail_x15_r0_body.fo166, PRE_first_tail_x15_r0_body.fok166, PRE_first_tail_x15_r0_body.fnd166, PRE_first_tail_x15_r0_body.fp166, PRE_first_tail_x15_r0_body.fnord166, PRE_first_tail_x15_r0_body.fi166, PRE_first_tail_x15_r0_body.fii166⟩
theorem PRE_first_tail_x15_r0_body.cnshift166 (clean : Conv.NClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P166.NL) (cl : SSt (· < 7175) PRE_first_tail_x15_r0_body.cx0_166.mlx) : NShift PRE_first_tail_x15_r0_body.P166 7175 PRE_first_tail_x15_r0_body.kappa166 PRE_first_tail_x15_r0_body.cx0_166 PRE_first_tail_x15_r0_body.cx1_166 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot166 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost166 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0166 PRE_first_tail_x15_r0_body.ckn1166 PRE_first_tail_x15_r0_body.ckheap166 PRE_first_tail_x15_r0_body.ckpl166)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_166 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1464.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_166 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1464.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_166 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1464.ffi) = some PRE_first_tail_x15_r0_body.fxC_166
kernel_rfl PRE_first_tail_x15_r0_body.okrC_166 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1464.ffi) = some PRE_first_tail_x15_r0_body.krC_166
noncomputable def PRE_first_tail_x15_r0_body.fx0_166 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1466.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_166 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1466.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_166 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1466.ffi) = some PRE_first_tail_x15_r0_body.fx0_166
kernel_rfl PRE_first_tail_x15_r0_body.okr0_166 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1466.ffi) = some PRE_first_tail_x15_r0_body.kr0_166
noncomputable def PRE_first_tail_x15_r0_body.fx1_166 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1465.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_166 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1465.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_166 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1465.ffi) = some PRE_first_tail_x15_r0_body.fx1_166
kernel_rfl PRE_first_tail_x15_r0_body.okr1_166 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1465.ffi) = some PRE_first_tail_x15_r0_body.kr1_166
kernel_rfl PRE_first_tail_x15_r0_body.ff0166 : PRE_first_tail_x15_r0_body.fx0_166 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_166 (PRE_first_tail_x15_r0_body.clo166.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_166.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1166 : PRE_first_tail_x15_r0_body.fx1_166 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_166 (PRE_first_tail_x15_r0_body.cwS166.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_166.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck166 : freedLB PRE_first_tail_x15_r0_body.kappa166 PRE_first_tail_x15_r0_body.cx0_166.mlx PRE_first_tail_x15_r0_body.fx0_166 PRE_first_tail_x15_r0_body.fx1_166 PRE_first_tail_x15_r0_body.clo166 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0166 : PRE_first_tail_x15_r0_body.kr0_166.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_166.flags (PRE_first_tail_x15_r0_body.clo166.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_166.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0166 : PRE_first_tail_x15_r0_body.kr0_166.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_166.targs (PRE_first_tail_x15_r0_body.clo166.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_166.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1166 : PRE_first_tail_x15_r0_body.kr1_166.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_166.flags (PRE_first_tail_x15_r0_body.cwS166.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_166.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1166 : PRE_first_tail_x15_r0_body.kr1_166.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_166.targs (PRE_first_tail_x15_r0_body.cwS166.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_166.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck166 : krecLB PRE_first_tail_x15_r0_body.kappa166 7175 PRE_first_tail_x15_r0_body.cx0_166.mlx PRE_first_tail_x15_r0_body.kr0_166 PRE_first_tail_x15_r0_body.kr1_166 PRE_first_tail_x15_r0_body.clo166 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn166 : Nat.ble 7175 7175 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge166 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1465.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1466.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR166 : pendRegB PRE_first_tail_x15_r0_body.kappa166 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe166 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1465.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift166 (clean : Conv.NClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P166.NL) (cl : SSt (· < 7175) PRE_first_tail_x15_r0_body.cx0_166.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_166.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_166.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_166.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_166.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P166 7175 PRE_first_tail_x15_r0_body.kappa166 PRE_first_tail_x15_r0_body.s1466.ffi PRE_first_tail_x15_r0_body.s1465.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift166 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue166, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp166 t ht),
    PRE_first_tail_x15_r0_body.cbridge166,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1466.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1465.ffi) (PRE_first_tail_x15_r0_body.cfoot166 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_166 PRE_first_tail_x15_r0_body.ofx1_166 hobjC PRE_first_tail_x15_r0_body.ff0166 PRE_first_tail_x15_r0_body.ff1166 PRE_first_tail_x15_r0_body.ffck166,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1466.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1465.ffi) (PRE_first_tail_x15_r0_body.cfoot166 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_166 PRE_first_tail_x15_r0_body.okr1_166 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn166) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0166 PRE_first_tail_x15_r0_body.fkt0166 PRE_first_tail_x15_r0_body.fkf1166 PRE_first_tail_x15_r0_body.fkt1166 PRE_first_tail_x15_r0_body.fkck166,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0166 PRE_first_tail_x15_r0_body.cnh1166 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe166) PRE_first_tail_x15_r0_body.cpendR166⟩

end Host.Load.Run.Tpl
