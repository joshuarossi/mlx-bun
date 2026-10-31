import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl167
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 167 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc167 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P167 : LoadP := PRE_first_tail_x15_r0_body.Pc167.raise 18577
kernel_rfl PRE_first_tail_x15_r0_body.craise167 : Nat.ble PRE_first_tail_x15_r0_body.Pc167.N0 18577 = true
theorem PRE_first_tail_x15_r0_body.raised167 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc167 PRE_first_tail_x15_r0_body.P167 :=
  .inr ⟨18577, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise167, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_167 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_167 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1610.ffi)
def PRE_first_tail_x15_r0_body.khinv167 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv167 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS167 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS167 : List Nat := List.range' 18577 0
def PRE_first_tail_x15_r0_body.ciS167 : List Nat := [] ++ List.range' 18577 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0167 : PRE_first_tail_x15_r0_body.kd167.nh0 = PRE_first_tail_x15_r0_body.cx0_167.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1167 : PRE_first_tail_x15_r0_body.kd167.nh1 = PRE_first_tail_x15_r0_body.cx1_167.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0167 : PRE_first_tail_x15_r0_body.kd167.nn0 = PRE_first_tail_x15_r0_body.cx0_167.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1167 : PRE_first_tail_x15_r0_body.kd167.nn1 = PRE_first_tail_x15_r0_body.cx1_167.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo167 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P167.lo && Nat.ble PRE_first_tail_x15_r0_body.P167.lo PRE_first_tail_x15_r0_body.cx0_167.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P167.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P167.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt167 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_167.mlx.next PRE_first_tail_x15_r0_body.cx1_167.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_167.mlx.nnext PRE_first_tail_x15_r0_body.cx1_167.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband167 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P167.NL && Nat.ble PRE_first_tail_x15_r0_body.P167.NL PRE_first_tail_x15_r0_body.P167.N0 && Nat.ble PRE_first_tail_x15_r0_body.P167.N0 PRE_first_tail_x15_r0_body.cx0_167.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow167 : PRE_first_tail_x15_r0_body.kd167.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren167 : checkRenG PRE_first_tail_x15_r0_body.kd167.hnd PRE_first_tail_x15_r0_body.khinv167 (phB PRE_first_tail_x15_r0_body.cx0_167.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband167 : PRE_first_tail_x15_r0_body.kd167.checkBand PRE_first_tail_x15_r0_body.P167.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos167 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd167.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren167 : checkRenG PRE_first_tail_x15_r0_body.kd167.node PRE_first_tail_x15_r0_body.kninv167 (pnB PRE_first_tail_x15_r0_body.cx0_167.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow167 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd167.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P167.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd167.nodeF j) PRE_first_tail_x15_r0_body.cx1_167.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a167 : PRE_first_tail_x15_r0_body.cx0_167.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b167 : PRE_first_tail_x15_r0_body.cx0_167.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1167 : PRE_first_tail_x15_r0_body.cx1_167.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend167 : PRE_first_tail_x15_r0_body.cx1_167.mlx.pending = PRE_first_tail_x15_r0_body.cx0_167.mlx.pending.map PRE_first_tail_x15_r0_body.kappa167.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh167 : PRE_first_tail_x15_r0_body.cx1_167.mlx.errh = PRE_first_tail_x15_r0_body.cx0_167.mlx.errh.map PRE_first_tail_x15_r0_body.kappa167.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles167 : PRE_first_tail_x15_r0_body.cx1_167.mlx.files = PRE_first_tail_x15_r0_body.cx0_167.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch167 : PRE_first_tail_x15_r0_body.cx1_167.mlx.arch = PRE_first_tail_x15_r0_body.cx0_167.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes167 : PRE_first_tail_x15_r0_body.cx1_167.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_167.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired167 : PRE_first_tail_x15_r0_body.cx1_167.mlx.wired = PRE_first_tail_x15_r0_body.cx0_167.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost167 : PRE_first_tail_x15_r0_body.cx1_167.host = PRE_first_tail_x15_r0_body.cx0_167.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd167`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0167 : PRE_first_tail_x15_r0_body.kd167.n0 = 2805802
kernel_rfl PRE_first_tail_x15_r0_body.ckn1167 : PRE_first_tail_x15_r0_body.kd167.n1 = 2805821
kernel_rfl PRE_first_tail_x15_r0_body.ckheap167 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd167.heap).all (fun x => Nat.ble 2805801 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl167 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd167.heap.get (2805801 + j) = nth? PRE_first_tail_x15_r0_body.pl167 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja167 : Nat.ble 2805801 2805801 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn167 : Nat.ble 7192 7192 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD167 : Nat.ble 2805801 PRE_first_tail_x15_r0_body.kd167.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn167 : Nat.ble 21485 PRE_first_tail_x15_r0_body.kd167.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn167 : Nat.ble 18577 PRE_first_tail_x15_r0_body.kd167.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb167 : Nat.ble 21485 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap167 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd167.heap).all (Nat.ble (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd167 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd167.hnd).all (Nat.ble (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode167 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd167.node).all (Nat.ble (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix167 : Conv.FixOld (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa167 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja167) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn167) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD167) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn167) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn167) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb167) PRE_first_tail_x15_r0_body.fheap167 PRE_first_tail_x15_r0_body.fhnd167 PRE_first_tail_x15_r0_body.fnode167
kernel_rfl PRE_first_tail_x15_r0_body.fcxn167 : (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn167 : (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0167 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_167.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_167.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk167 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd167.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A167 : PRE_first_tail_x15_r0_body.cx1_167.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS167.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_167.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O167 : PRE_first_tail_x15_r0_body.cx1_167.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS167.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_167.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N167 : PRE_first_tail_x15_r0_body.cx1_167.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS167.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_167.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I167 : PRE_first_tail_x15_r0_body.cx1_167.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS167.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_167.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd167 : (PRE_first_tail_x15_r0_body.clo167 ++ PRE_first_tail_x15_r0_body.cln167 ++ PRE_first_tail_x15_r0_body.cli167 ++ PRE_first_tail_x15_r0_body.cwS167 ++ PRE_first_tail_x15_r0_body.cnS167 ++ PRE_first_tail_x15_r0_body.ciS167).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW167 : PRE_first_tail_x15_r0_body.cwS167.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo167.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI167 : PRE_first_tail_x15_r0_body.ciS167.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli167.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN167 : PRE_first_tail_x15_r0_body.cnS167.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF167 : PRE_first_tail_x15_r0_body.cln167.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh167 : PRE_first_tail_x15_r0_body.clo167.all (handleOK PRE_first_tail_x15_r0_body.kappa167 PRE_first_tail_x15_r0_body.P167.lo PRE_first_tail_x15_r0_body.cx0_167.mlx PRE_first_tail_x15_r0_body.cx1_167.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo167 : PRE_first_tail_x15_r0_body.clo167.map (fun h => PRE_first_tail_x15_r0_body.cx1_167.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa167.handle h)) = PRE_first_tail_x15_r0_body.clo167.map (fun h => (PRE_first_tail_x15_r0_body.cx0_167.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa167.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok167 : PRE_first_tail_x15_r0_body.clo167.all (objOK PRE_first_tail_x15_r0_body.kappa167 PRE_first_tail_x15_r0_body.P167.NL PRE_first_tail_x15_r0_body.cx0_167.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd167 : PRE_first_tail_x15_r0_body.cln167.all (nodeOKF PRE_first_tail_x15_r0_body.kappa167 PRE_first_tail_x15_r0_body.P167 PRE_first_tail_x15_r0_body.cx0_167.mlx PRE_first_tail_x15_r0_body.cx1_167.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp167 : ((PRE_first_tail_x15_r0_body.cln167.filter (fullB PRE_first_tail_x15_r0_body.P167))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_167.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa167.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln167.filter (fullB PRE_first_tail_x15_r0_body.P167))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_167.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa167.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI167 : incrB PRE_first_tail_x15_r0_body.kd167.nodeF (List.range' 18577 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK167 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd167.node).all (fun k => Nat.ble 18577 k && Nat.blt k 18577) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL167 : (PRE_first_tail_x15_r0_body.cln167.filter (Nat.ble PRE_first_tail_x15_r0_body.P167.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd167.nodeF i) && (Nat.blt i 18577 || Nat.ble PRE_first_tail_x15_r0_body.kd167.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord167 : (PRE_first_tail_x15_r0_body.cln167.filter (Nat.ble PRE_first_tail_x15_r0_body.P167.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd167.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd167.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd167.nodeF j) (PRE_first_tail_x15_r0_body.kd167.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow167 PRE_first_tail_x15_r0_body.cnn1167 PRE_first_tail_x15_r0_body.fnordI167 PRE_first_tail_x15_r0_body.fnordK167 PRE_first_tail_x15_r0_body.fnordL167
kernel_rfl PRE_first_tail_x15_r0_body.fi167 : PRE_first_tail_x15_r0_body.cli167.all (pnB PRE_first_tail_x15_r0_body.cx0_167.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii167 : PRE_first_tail_x15_r0_body.cli167.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_167.mlx.items.get (PRE_first_tail_x15_r0_body.kappa167.node k) = (PRE_first_tail_x15_r0_body.cx0_167.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa167.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot167 (clean : Conv.NClean (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P167.NL) (cl : SSt (· < 7192) PRE_first_tail_x15_r0_body.cx0_167.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P167 7192 PRE_first_tail_x15_r0_body.kappa167 PRE_first_tail_x15_r0_body.kd167 PRE_first_tail_x15_r0_body.khinv167 PRE_first_tail_x15_r0_body.kninv167 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx PRE_first_tail_x15_r0_body.cx0_167.mlx PRE_first_tail_x15_r0_body.cx1_167.mlx (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo167 PRE_first_tail_x15_r0_body.cln167 PRE_first_tail_x15_r0_body.cli167 PRE_first_tail_x15_r0_body.cwS167 PRE_first_tail_x15_r0_body.cnS167 PRE_first_tail_x15_r0_body.ciS167 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0167, PRE_first_tail_x15_r0_body.cnh1167, PRE_first_tail_x15_r0_body.cnn0167, PRE_first_tail_x15_r0_body.cnn1167, PRE_first_tail_x15_r0_body.cplo167, PRE_first_tail_x15_r0_body.ccnt167, PRE_first_tail_x15_r0_body.cnband167, PRE_first_tail_x15_r0_body.chbelow167, PRE_first_tail_x15_r0_body.chren167, PRE_first_tail_x15_r0_body.cband167, PRE_first_tail_x15_r0_body.cnh1pos167, PRE_first_tail_x15_r0_body.cnren167, PRE_first_tail_x15_r0_body.cnlow167, PRE_first_tail_x15_r0_body.cabs0a167, PRE_first_tail_x15_r0_body.cabs0b167, PRE_first_tail_x15_r0_body.ctok1167, PRE_first_tail_x15_r0_body.cpend167, PRE_first_tail_x15_r0_body.cerrh167, PRE_first_tail_x15_r0_body.cfiles167, PRE_first_tail_x15_r0_body.carch167, PRE_first_tail_x15_r0_body.csizes167, PRE_first_tail_x15_r0_body.cwired167, PRE_first_tail_x15_r0_body.cfix167, clean, PRE_first_tail_x15_r0_body.fcxn167, PRE_first_tail_x15_r0_body.fcnn167, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0167, PRE_first_tail_x15_r0_body.fnk167, PRE_first_tail_x15_r0_body.ckA167, PRE_first_tail_x15_r0_body.cobjsK167, PRE_first_tail_x15_r0_body.cnodesK167, PRE_first_tail_x15_r0_body.citemsK167, PRE_first_tail_x15_r0_body.f1A167, PRE_first_tail_x15_r0_body.f1O167, PRE_first_tail_x15_r0_body.f1N167, PRE_first_tail_x15_r0_body.f1I167, PRE_first_tail_x15_r0_body.fbd167, PRE_first_tail_x15_r0_body.fincW167, PRE_first_tail_x15_r0_body.fincI167, PRE_first_tail_x15_r0_body.fincN167, PRE_first_tail_x15_r0_body.flnF167, PRE_first_tail_x15_r0_body.fh167, PRE_first_tail_x15_r0_body.fo167, PRE_first_tail_x15_r0_body.fok167, PRE_first_tail_x15_r0_body.fnd167, PRE_first_tail_x15_r0_body.fp167, PRE_first_tail_x15_r0_body.fnord167, PRE_first_tail_x15_r0_body.fi167, PRE_first_tail_x15_r0_body.fii167⟩
theorem PRE_first_tail_x15_r0_body.cnshift167 (clean : Conv.NClean (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P167.NL) (cl : SSt (· < 7192) PRE_first_tail_x15_r0_body.cx0_167.mlx) : NShift PRE_first_tail_x15_r0_body.P167 7192 PRE_first_tail_x15_r0_body.kappa167 PRE_first_tail_x15_r0_body.cx0_167 PRE_first_tail_x15_r0_body.cx1_167 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot167 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost167 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0167 PRE_first_tail_x15_r0_body.ckn1167 PRE_first_tail_x15_r0_body.ckheap167 PRE_first_tail_x15_r0_body.ckpl167)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_167 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1609.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_167 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1609.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_167 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1609.ffi) = some PRE_first_tail_x15_r0_body.fxC_167
kernel_rfl PRE_first_tail_x15_r0_body.okrC_167 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1609.ffi) = some PRE_first_tail_x15_r0_body.krC_167
noncomputable def PRE_first_tail_x15_r0_body.fx0_167 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1611.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_167 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1611.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_167 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1611.ffi) = some PRE_first_tail_x15_r0_body.fx0_167
kernel_rfl PRE_first_tail_x15_r0_body.okr0_167 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1611.ffi) = some PRE_first_tail_x15_r0_body.kr0_167
noncomputable def PRE_first_tail_x15_r0_body.fx1_167 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1610.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_167 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1610.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_167 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1610.ffi) = some PRE_first_tail_x15_r0_body.fx1_167
kernel_rfl PRE_first_tail_x15_r0_body.okr1_167 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1610.ffi) = some PRE_first_tail_x15_r0_body.kr1_167
kernel_rfl PRE_first_tail_x15_r0_body.ff0167 : PRE_first_tail_x15_r0_body.fx0_167 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_167 (PRE_first_tail_x15_r0_body.clo167.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_167.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1167 : PRE_first_tail_x15_r0_body.fx1_167 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_167 (PRE_first_tail_x15_r0_body.cwS167.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_167.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck167 : freedLB PRE_first_tail_x15_r0_body.kappa167 PRE_first_tail_x15_r0_body.cx0_167.mlx PRE_first_tail_x15_r0_body.fx0_167 PRE_first_tail_x15_r0_body.fx1_167 PRE_first_tail_x15_r0_body.clo167 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0167 : PRE_first_tail_x15_r0_body.kr0_167.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_167.flags (PRE_first_tail_x15_r0_body.clo167.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_167.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0167 : PRE_first_tail_x15_r0_body.kr0_167.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_167.targs (PRE_first_tail_x15_r0_body.clo167.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_167.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1167 : PRE_first_tail_x15_r0_body.kr1_167.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_167.flags (PRE_first_tail_x15_r0_body.cwS167.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_167.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1167 : PRE_first_tail_x15_r0_body.kr1_167.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_167.targs (PRE_first_tail_x15_r0_body.cwS167.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_167.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck167 : krecLB PRE_first_tail_x15_r0_body.kappa167 7192 PRE_first_tail_x15_r0_body.cx0_167.mlx PRE_first_tail_x15_r0_body.kr0_167 PRE_first_tail_x15_r0_body.kr1_167 PRE_first_tail_x15_r0_body.clo167 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn167 : Nat.ble 7192 7192 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge167 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1610.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1611.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR167 : pendRegB PRE_first_tail_x15_r0_body.kappa167 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe167 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1610.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift167 (clean : Conv.NClean (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P167.NL) (cl : SSt (· < 7192) PRE_first_tail_x15_r0_body.cx0_167.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_167.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_167.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_167.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_167.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P167 7192 PRE_first_tail_x15_r0_body.kappa167 PRE_first_tail_x15_r0_body.s1611.ffi PRE_first_tail_x15_r0_body.s1610.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift167 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue167, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp167 t ht),
    PRE_first_tail_x15_r0_body.cbridge167,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1611.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1610.ffi) (PRE_first_tail_x15_r0_body.cfoot167 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_167 PRE_first_tail_x15_r0_body.ofx1_167 hobjC PRE_first_tail_x15_r0_body.ff0167 PRE_first_tail_x15_r0_body.ff1167 PRE_first_tail_x15_r0_body.ffck167,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1611.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1610.ffi) (PRE_first_tail_x15_r0_body.cfoot167 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_167 PRE_first_tail_x15_r0_body.okr1_167 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn167) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0167 PRE_first_tail_x15_r0_body.fkt0167 PRE_first_tail_x15_r0_body.fkf1167 PRE_first_tail_x15_r0_body.fkt1167 PRE_first_tail_x15_r0_body.fkck167,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0167 PRE_first_tail_x15_r0_body.cnh1167 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe167) PRE_first_tail_x15_r0_body.cpendR167⟩

end Host.Load.Run.Tpl
