import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl142
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 142 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc142 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P142 : LoadP := PRE_first_tail_x15_r0_body.Pc142.raise 18099
kernel_rfl PRE_first_tail_x15_r0_body.craise142 : Nat.ble PRE_first_tail_x15_r0_body.Pc142.N0 18099 = true
theorem PRE_first_tail_x15_r0_body.raised142 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc142 PRE_first_tail_x15_r0_body.P142 :=
  .inr ⟨18099, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise142, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_142 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1256.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_142 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1255.ffi)
def PRE_first_tail_x15_r0_body.khinv142 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv142 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS142 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS142 : List Nat := List.range' 18099 0
def PRE_first_tail_x15_r0_body.ciS142 : List Nat := [] ++ List.range' 18099 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0142 : PRE_first_tail_x15_r0_body.kd142.nh0 = PRE_first_tail_x15_r0_body.cx0_142.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1142 : PRE_first_tail_x15_r0_body.kd142.nh1 = PRE_first_tail_x15_r0_body.cx1_142.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0142 : PRE_first_tail_x15_r0_body.kd142.nn0 = PRE_first_tail_x15_r0_body.cx0_142.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1142 : PRE_first_tail_x15_r0_body.kd142.nn1 = PRE_first_tail_x15_r0_body.cx1_142.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo142 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P142.lo && Nat.ble PRE_first_tail_x15_r0_body.P142.lo PRE_first_tail_x15_r0_body.cx0_142.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P142.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P142.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt142 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_142.mlx.next PRE_first_tail_x15_r0_body.cx1_142.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_142.mlx.nnext PRE_first_tail_x15_r0_body.cx1_142.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband142 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P142.NL && Nat.ble PRE_first_tail_x15_r0_body.P142.NL PRE_first_tail_x15_r0_body.P142.N0 && Nat.ble PRE_first_tail_x15_r0_body.P142.N0 PRE_first_tail_x15_r0_body.cx0_142.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow142 : PRE_first_tail_x15_r0_body.kd142.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren142 : checkRenG PRE_first_tail_x15_r0_body.kd142.hnd PRE_first_tail_x15_r0_body.khinv142 (phB PRE_first_tail_x15_r0_body.cx0_142.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband142 : PRE_first_tail_x15_r0_body.kd142.checkBand PRE_first_tail_x15_r0_body.P142.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos142 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd142.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren142 : checkRenG PRE_first_tail_x15_r0_body.kd142.node PRE_first_tail_x15_r0_body.kninv142 (pnB PRE_first_tail_x15_r0_body.cx0_142.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P142.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd142.nodeF j) PRE_first_tail_x15_r0_body.cx1_142.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a142 : PRE_first_tail_x15_r0_body.cx0_142.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b142 : PRE_first_tail_x15_r0_body.cx0_142.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.pending = PRE_first_tail_x15_r0_body.cx0_142.mlx.pending.map PRE_first_tail_x15_r0_body.kappa142.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.errh = PRE_first_tail_x15_r0_body.cx0_142.mlx.errh.map PRE_first_tail_x15_r0_body.kappa142.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.files = PRE_first_tail_x15_r0_body.cx0_142.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.arch = PRE_first_tail_x15_r0_body.cx0_142.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_142.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.wired = PRE_first_tail_x15_r0_body.cx0_142.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost142 : PRE_first_tail_x15_r0_body.cx1_142.host = PRE_first_tail_x15_r0_body.cx0_142.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd142`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0142 : PRE_first_tail_x15_r0_body.kd142.n0 = 2786673
kernel_rfl PRE_first_tail_x15_r0_body.ckn1142 : PRE_first_tail_x15_r0_body.kd142.n1 = 2786675
kernel_rfl PRE_first_tail_x15_r0_body.ckheap142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.heap).all (fun x => Nat.ble 2786673 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl142 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd142.heap.get (2786673 + j) = nth? PRE_first_tail_x15_r0_body.pl142 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja142 : Nat.ble 2786673 2786673 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn142 : Nat.ble 6149 6149 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD142 : Nat.ble 2786673 PRE_first_tail_x15_r0_body.kd142.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn142 : Nat.ble 21006 PRE_first_tail_x15_r0_body.kd142.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn142 : Nat.ble 18099 PRE_first_tail_x15_r0_body.kd142.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb142 : Nat.ble 21006 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.heap).all (Nat.ble (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.hnd).all (Nat.ble (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.node).all (Nat.ble (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix142 : Conv.FixOld (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa142 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja142) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn142) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD142) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn142) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn142) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb142) PRE_first_tail_x15_r0_body.fheap142 PRE_first_tail_x15_r0_body.fhnd142 PRE_first_tail_x15_r0_body.fnode142
kernel_rfl PRE_first_tail_x15_r0_body.fcxn142 : (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn142 : (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0142 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_142.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_142.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS142.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_142.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS142.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_142.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS142.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_142.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS142.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_142.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd142 : (PRE_first_tail_x15_r0_body.clo142 ++ PRE_first_tail_x15_r0_body.cln142 ++ PRE_first_tail_x15_r0_body.cli142 ++ PRE_first_tail_x15_r0_body.cwS142 ++ PRE_first_tail_x15_r0_body.cnS142 ++ PRE_first_tail_x15_r0_body.ciS142).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW142 : PRE_first_tail_x15_r0_body.cwS142.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo142.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI142 : PRE_first_tail_x15_r0_body.ciS142.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli142.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN142 : PRE_first_tail_x15_r0_body.cnS142.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF142 : PRE_first_tail_x15_r0_body.cln142.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh142 : PRE_first_tail_x15_r0_body.clo142.all (handleOK PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.P142.lo PRE_first_tail_x15_r0_body.cx0_142.mlx PRE_first_tail_x15_r0_body.cx1_142.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo142 : PRE_first_tail_x15_r0_body.clo142.map (fun h => PRE_first_tail_x15_r0_body.cx1_142.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa142.handle h)) = PRE_first_tail_x15_r0_body.clo142.map (fun h => (PRE_first_tail_x15_r0_body.cx0_142.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa142.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok142 : PRE_first_tail_x15_r0_body.clo142.all (objOK PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.P142.NL PRE_first_tail_x15_r0_body.cx0_142.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd142 : PRE_first_tail_x15_r0_body.cln142.all (nodeOKF PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.P142 PRE_first_tail_x15_r0_body.cx0_142.mlx PRE_first_tail_x15_r0_body.cx1_142.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp142 : ((PRE_first_tail_x15_r0_body.cln142.filter (fullB PRE_first_tail_x15_r0_body.P142))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_142.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa142.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln142.filter (fullB PRE_first_tail_x15_r0_body.P142))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_142.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa142.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI142 : incrB PRE_first_tail_x15_r0_body.kd142.nodeF (List.range' 18099 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.node).all (fun k => Nat.ble 18099 k && Nat.blt k 18099) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL142 : (PRE_first_tail_x15_r0_body.cln142.filter (Nat.ble PRE_first_tail_x15_r0_body.P142.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd142.nodeF i) && (Nat.blt i 18099 || Nat.ble PRE_first_tail_x15_r0_body.kd142.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord142 : (PRE_first_tail_x15_r0_body.cln142.filter (Nat.ble PRE_first_tail_x15_r0_body.P142.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd142.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd142.nodeF j) (PRE_first_tail_x15_r0_body.kd142.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow142 PRE_first_tail_x15_r0_body.cnn1142 PRE_first_tail_x15_r0_body.fnordI142 PRE_first_tail_x15_r0_body.fnordK142 PRE_first_tail_x15_r0_body.fnordL142
kernel_rfl PRE_first_tail_x15_r0_body.fi142 : PRE_first_tail_x15_r0_body.cli142.all (pnB PRE_first_tail_x15_r0_body.cx0_142.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii142 : PRE_first_tail_x15_r0_body.cli142.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_142.mlx.items.get (PRE_first_tail_x15_r0_body.kappa142.node k) = (PRE_first_tail_x15_r0_body.cx0_142.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa142.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot142 (clean : Conv.NClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P142.NL) (cl : SSt (· < 6149) PRE_first_tail_x15_r0_body.cx0_142.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P142 6149 PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.kd142 PRE_first_tail_x15_r0_body.khinv142 PRE_first_tail_x15_r0_body.kninv142 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx PRE_first_tail_x15_r0_body.cx0_142.mlx PRE_first_tail_x15_r0_body.cx1_142.mlx (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo142 PRE_first_tail_x15_r0_body.cln142 PRE_first_tail_x15_r0_body.cli142 PRE_first_tail_x15_r0_body.cwS142 PRE_first_tail_x15_r0_body.cnS142 PRE_first_tail_x15_r0_body.ciS142 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0142, PRE_first_tail_x15_r0_body.cnh1142, PRE_first_tail_x15_r0_body.cnn0142, PRE_first_tail_x15_r0_body.cnn1142, PRE_first_tail_x15_r0_body.cplo142, PRE_first_tail_x15_r0_body.ccnt142, PRE_first_tail_x15_r0_body.cnband142, PRE_first_tail_x15_r0_body.chbelow142, PRE_first_tail_x15_r0_body.chren142, PRE_first_tail_x15_r0_body.cband142, PRE_first_tail_x15_r0_body.cnh1pos142, PRE_first_tail_x15_r0_body.cnren142, PRE_first_tail_x15_r0_body.cnlow142, PRE_first_tail_x15_r0_body.cabs0a142, PRE_first_tail_x15_r0_body.cabs0b142, PRE_first_tail_x15_r0_body.ctok1142, PRE_first_tail_x15_r0_body.cpend142, PRE_first_tail_x15_r0_body.cerrh142, PRE_first_tail_x15_r0_body.cfiles142, PRE_first_tail_x15_r0_body.carch142, PRE_first_tail_x15_r0_body.csizes142, PRE_first_tail_x15_r0_body.cwired142, PRE_first_tail_x15_r0_body.cfix142, clean, PRE_first_tail_x15_r0_body.fcxn142, PRE_first_tail_x15_r0_body.fcnn142, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0142, PRE_first_tail_x15_r0_body.fnk142, PRE_first_tail_x15_r0_body.ckA142, PRE_first_tail_x15_r0_body.cobjsK142, PRE_first_tail_x15_r0_body.cnodesK142, PRE_first_tail_x15_r0_body.citemsK142, PRE_first_tail_x15_r0_body.f1A142, PRE_first_tail_x15_r0_body.f1O142, PRE_first_tail_x15_r0_body.f1N142, PRE_first_tail_x15_r0_body.f1I142, PRE_first_tail_x15_r0_body.fbd142, PRE_first_tail_x15_r0_body.fincW142, PRE_first_tail_x15_r0_body.fincI142, PRE_first_tail_x15_r0_body.fincN142, PRE_first_tail_x15_r0_body.flnF142, PRE_first_tail_x15_r0_body.fh142, PRE_first_tail_x15_r0_body.fo142, PRE_first_tail_x15_r0_body.fok142, PRE_first_tail_x15_r0_body.fnd142, PRE_first_tail_x15_r0_body.fp142, PRE_first_tail_x15_r0_body.fnord142, PRE_first_tail_x15_r0_body.fi142, PRE_first_tail_x15_r0_body.fii142⟩
theorem PRE_first_tail_x15_r0_body.cnshift142 (clean : Conv.NClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P142.NL) (cl : SSt (· < 6149) PRE_first_tail_x15_r0_body.cx0_142.mlx) : NShift PRE_first_tail_x15_r0_body.P142 6149 PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.cx0_142 PRE_first_tail_x15_r0_body.cx1_142 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot142 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost142 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0142 PRE_first_tail_x15_r0_body.ckn1142 PRE_first_tail_x15_r0_body.ckheap142 PRE_first_tail_x15_r0_body.ckpl142)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_142 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1254.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_142 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1254.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_142 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1254.ffi) = some PRE_first_tail_x15_r0_body.fxC_142
kernel_rfl PRE_first_tail_x15_r0_body.okrC_142 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1254.ffi) = some PRE_first_tail_x15_r0_body.krC_142
noncomputable def PRE_first_tail_x15_r0_body.fx0_142 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1256.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_142 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1256.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_142 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1256.ffi) = some PRE_first_tail_x15_r0_body.fx0_142
kernel_rfl PRE_first_tail_x15_r0_body.okr0_142 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1256.ffi) = some PRE_first_tail_x15_r0_body.kr0_142
noncomputable def PRE_first_tail_x15_r0_body.fx1_142 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1255.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_142 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1255.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_142 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1255.ffi) = some PRE_first_tail_x15_r0_body.fx1_142
kernel_rfl PRE_first_tail_x15_r0_body.okr1_142 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1255.ffi) = some PRE_first_tail_x15_r0_body.kr1_142
kernel_rfl PRE_first_tail_x15_r0_body.ff0142 : PRE_first_tail_x15_r0_body.fx0_142 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_142 (PRE_first_tail_x15_r0_body.clo142.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_142.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1142 : PRE_first_tail_x15_r0_body.fx1_142 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_142 (PRE_first_tail_x15_r0_body.cwS142.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_142.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck142 : freedLB PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.cx0_142.mlx PRE_first_tail_x15_r0_body.fx0_142 PRE_first_tail_x15_r0_body.fx1_142 PRE_first_tail_x15_r0_body.clo142 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0142 : PRE_first_tail_x15_r0_body.kr0_142.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_142.flags (PRE_first_tail_x15_r0_body.clo142.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_142.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0142 : PRE_first_tail_x15_r0_body.kr0_142.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_142.targs (PRE_first_tail_x15_r0_body.clo142.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_142.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1142 : PRE_first_tail_x15_r0_body.kr1_142.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_142.flags (PRE_first_tail_x15_r0_body.cwS142.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_142.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1142 : PRE_first_tail_x15_r0_body.kr1_142.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_142.targs (PRE_first_tail_x15_r0_body.cwS142.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_142.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck142 : krecLB PRE_first_tail_x15_r0_body.kappa142 6149 PRE_first_tail_x15_r0_body.cx0_142.mlx PRE_first_tail_x15_r0_body.kr0_142 PRE_first_tail_x15_r0_body.kr1_142 PRE_first_tail_x15_r0_body.clo142 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn142 : Nat.ble 6149 6149 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge142 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1255.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1256.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR142 : pendRegB PRE_first_tail_x15_r0_body.kappa142 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1256.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe142 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1256.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1255.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift142 (clean : Conv.NClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P142.NL) (cl : SSt (· < 6149) PRE_first_tail_x15_r0_body.cx0_142.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_142.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_142.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_142.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_142.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P142 6149 PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.s1256.ffi PRE_first_tail_x15_r0_body.s1255.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift142 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue142, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp142 t ht),
    PRE_first_tail_x15_r0_body.cbridge142,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1256.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1255.ffi) (PRE_first_tail_x15_r0_body.cfoot142 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_142 PRE_first_tail_x15_r0_body.ofx1_142 hobjC PRE_first_tail_x15_r0_body.ff0142 PRE_first_tail_x15_r0_body.ff1142 PRE_first_tail_x15_r0_body.ffck142,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1256.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1255.ffi) (PRE_first_tail_x15_r0_body.cfoot142 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_142 PRE_first_tail_x15_r0_body.okr1_142 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn142) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0142 PRE_first_tail_x15_r0_body.fkt0142 PRE_first_tail_x15_r0_body.fkf1142 PRE_first_tail_x15_r0_body.fkt1142 PRE_first_tail_x15_r0_body.fkck142,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0142 PRE_first_tail_x15_r0_body.cnh1142 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe142) PRE_first_tail_x15_r0_body.cpendR142⟩

end Host.Load.Run.Tpl
