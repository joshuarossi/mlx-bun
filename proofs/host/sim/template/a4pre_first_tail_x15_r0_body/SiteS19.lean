import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl19
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 19 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc19 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P19 : LoadP := PRE_first_tail_x15_r0_body.Pc19.raise 15681
kernel_rfl PRE_first_tail_x15_r0_body.craise19 : Nat.ble PRE_first_tail_x15_r0_body.Pc19.N0 15681 = true
theorem PRE_first_tail_x15_r0_body.raised19 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc19 PRE_first_tail_x15_r0_body.P19 :=
  .inr ⟨15681, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise19, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_19 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s182.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_19 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s181.ffi)
def PRE_first_tail_x15_r0_body.khinv19 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv19 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS19 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS19 : List Nat := List.range' 15681 0
def PRE_first_tail_x15_r0_body.ciS19 : List Nat := [] ++ List.range' 15681 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh019 : PRE_first_tail_x15_r0_body.kd19.nh0 = PRE_first_tail_x15_r0_body.cx0_19.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh119 : PRE_first_tail_x15_r0_body.kd19.nh1 = PRE_first_tail_x15_r0_body.cx1_19.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn019 : PRE_first_tail_x15_r0_body.kd19.nn0 = PRE_first_tail_x15_r0_body.cx0_19.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn119 : PRE_first_tail_x15_r0_body.kd19.nn1 = PRE_first_tail_x15_r0_body.cx1_19.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo19 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P19.lo && Nat.ble PRE_first_tail_x15_r0_body.P19.lo PRE_first_tail_x15_r0_body.cx0_19.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P19.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P19.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt19 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_19.mlx.next PRE_first_tail_x15_r0_body.cx1_19.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_19.mlx.nnext PRE_first_tail_x15_r0_body.cx1_19.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband19 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P19.NL && Nat.ble PRE_first_tail_x15_r0_body.P19.NL PRE_first_tail_x15_r0_body.P19.N0 && Nat.ble PRE_first_tail_x15_r0_body.P19.N0 PRE_first_tail_x15_r0_body.cx0_19.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow19 : PRE_first_tail_x15_r0_body.kd19.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren19 : checkRenG PRE_first_tail_x15_r0_body.kd19.hnd PRE_first_tail_x15_r0_body.khinv19 (phB PRE_first_tail_x15_r0_body.cx0_19.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband19 : PRE_first_tail_x15_r0_body.kd19.checkBand PRE_first_tail_x15_r0_body.P19.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos19 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd19.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren19 : checkRenG PRE_first_tail_x15_r0_body.kd19.node PRE_first_tail_x15_r0_body.kninv19 (pnB PRE_first_tail_x15_r0_body.cx0_19.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow19 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd19.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P19.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd19.nodeF j) PRE_first_tail_x15_r0_body.cx1_19.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a19 : PRE_first_tail_x15_r0_body.cx0_19.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b19 : PRE_first_tail_x15_r0_body.cx0_19.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok119 : PRE_first_tail_x15_r0_body.cx1_19.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend19 : PRE_first_tail_x15_r0_body.cx1_19.mlx.pending = PRE_first_tail_x15_r0_body.cx0_19.mlx.pending.map PRE_first_tail_x15_r0_body.kappa19.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh19 : PRE_first_tail_x15_r0_body.cx1_19.mlx.errh = PRE_first_tail_x15_r0_body.cx0_19.mlx.errh.map PRE_first_tail_x15_r0_body.kappa19.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles19 : PRE_first_tail_x15_r0_body.cx1_19.mlx.files = PRE_first_tail_x15_r0_body.cx0_19.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch19 : PRE_first_tail_x15_r0_body.cx1_19.mlx.arch = PRE_first_tail_x15_r0_body.cx0_19.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes19 : PRE_first_tail_x15_r0_body.cx1_19.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_19.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired19 : PRE_first_tail_x15_r0_body.cx1_19.mlx.wired = PRE_first_tail_x15_r0_body.cx0_19.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost19 : PRE_first_tail_x15_r0_body.cx1_19.host = PRE_first_tail_x15_r0_body.cx0_19.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd19`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn019 : PRE_first_tail_x15_r0_body.kd19.n0 = 2689883
kernel_rfl PRE_first_tail_x15_r0_body.ckn119 : PRE_first_tail_x15_r0_body.kd19.n1 = 2689885
kernel_rfl PRE_first_tail_x15_r0_body.ckheap19 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd19.heap).all (fun x => Nat.ble 2689883 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl19 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd19.heap.get (2689883 + j) = nth? PRE_first_tail_x15_r0_body.pl19 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja19 : Nat.ble 2689883 2689883 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn19 : Nat.ble 893 893 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD19 : Nat.ble 2689883 PRE_first_tail_x15_r0_body.kd19.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn19 : Nat.ble 18582 PRE_first_tail_x15_r0_body.kd19.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn19 : Nat.ble 15681 PRE_first_tail_x15_r0_body.kd19.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb19 : Nat.ble 18582 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap19 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd19.heap).all (Nat.ble (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd19 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd19.hnd).all (Nat.ble (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode19 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd19.node).all (Nat.ble (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix19 : Conv.FixOld (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa19 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja19) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn19) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD19) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn19) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn19) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb19) PRE_first_tail_x15_r0_body.fheap19 PRE_first_tail_x15_r0_body.fhnd19 PRE_first_tail_x15_r0_body.fnode19
kernel_rfl PRE_first_tail_x15_r0_body.fcxn19 : (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn19 : (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle019 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_19.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_19.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk19 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd19.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A19 : PRE_first_tail_x15_r0_body.cx1_19.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS19.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_19.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O19 : PRE_first_tail_x15_r0_body.cx1_19.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS19.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_19.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N19 : PRE_first_tail_x15_r0_body.cx1_19.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS19.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_19.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I19 : PRE_first_tail_x15_r0_body.cx1_19.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS19.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_19.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd19 : (PRE_first_tail_x15_r0_body.clo19 ++ PRE_first_tail_x15_r0_body.cln19 ++ PRE_first_tail_x15_r0_body.cli19 ++ PRE_first_tail_x15_r0_body.cwS19 ++ PRE_first_tail_x15_r0_body.cnS19 ++ PRE_first_tail_x15_r0_body.ciS19).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW19 : PRE_first_tail_x15_r0_body.cwS19.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo19.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI19 : PRE_first_tail_x15_r0_body.ciS19.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli19.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN19 : PRE_first_tail_x15_r0_body.cnS19.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF19 : PRE_first_tail_x15_r0_body.cln19.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh19 : PRE_first_tail_x15_r0_body.clo19.all (handleOK PRE_first_tail_x15_r0_body.kappa19 PRE_first_tail_x15_r0_body.P19.lo PRE_first_tail_x15_r0_body.cx0_19.mlx PRE_first_tail_x15_r0_body.cx1_19.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo19 : PRE_first_tail_x15_r0_body.clo19.map (fun h => PRE_first_tail_x15_r0_body.cx1_19.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa19.handle h)) = PRE_first_tail_x15_r0_body.clo19.map (fun h => (PRE_first_tail_x15_r0_body.cx0_19.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa19.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok19 : PRE_first_tail_x15_r0_body.clo19.all (objOK PRE_first_tail_x15_r0_body.kappa19 PRE_first_tail_x15_r0_body.P19.NL PRE_first_tail_x15_r0_body.cx0_19.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd19 : PRE_first_tail_x15_r0_body.cln19.all (nodeOKF PRE_first_tail_x15_r0_body.kappa19 PRE_first_tail_x15_r0_body.P19 PRE_first_tail_x15_r0_body.cx0_19.mlx PRE_first_tail_x15_r0_body.cx1_19.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp19 : ((PRE_first_tail_x15_r0_body.cln19.filter (fullB PRE_first_tail_x15_r0_body.P19))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_19.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa19.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln19.filter (fullB PRE_first_tail_x15_r0_body.P19))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_19.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa19.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI19 : incrB PRE_first_tail_x15_r0_body.kd19.nodeF (List.range' 15681 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK19 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd19.node).all (fun k => Nat.ble 15681 k && Nat.blt k 15681) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL19 : (PRE_first_tail_x15_r0_body.cln19.filter (Nat.ble PRE_first_tail_x15_r0_body.P19.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd19.nodeF i) && (Nat.blt i 15681 || Nat.ble PRE_first_tail_x15_r0_body.kd19.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord19 : (PRE_first_tail_x15_r0_body.cln19.filter (Nat.ble PRE_first_tail_x15_r0_body.P19.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd19.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd19.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd19.nodeF j) (PRE_first_tail_x15_r0_body.kd19.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow19 PRE_first_tail_x15_r0_body.cnn119 PRE_first_tail_x15_r0_body.fnordI19 PRE_first_tail_x15_r0_body.fnordK19 PRE_first_tail_x15_r0_body.fnordL19
kernel_rfl PRE_first_tail_x15_r0_body.fi19 : PRE_first_tail_x15_r0_body.cli19.all (pnB PRE_first_tail_x15_r0_body.cx0_19.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii19 : PRE_first_tail_x15_r0_body.cli19.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_19.mlx.items.get (PRE_first_tail_x15_r0_body.kappa19.node k) = (PRE_first_tail_x15_r0_body.cx0_19.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa19.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot19 (clean : Conv.NClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P19.NL) (cl : SSt (· < 893) PRE_first_tail_x15_r0_body.cx0_19.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P19 893 PRE_first_tail_x15_r0_body.kappa19 PRE_first_tail_x15_r0_body.kd19 PRE_first_tail_x15_r0_body.khinv19 PRE_first_tail_x15_r0_body.kninv19 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx PRE_first_tail_x15_r0_body.cx0_19.mlx PRE_first_tail_x15_r0_body.cx1_19.mlx (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo19 PRE_first_tail_x15_r0_body.cln19 PRE_first_tail_x15_r0_body.cli19 PRE_first_tail_x15_r0_body.cwS19 PRE_first_tail_x15_r0_body.cnS19 PRE_first_tail_x15_r0_body.ciS19 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh019, PRE_first_tail_x15_r0_body.cnh119, PRE_first_tail_x15_r0_body.cnn019, PRE_first_tail_x15_r0_body.cnn119, PRE_first_tail_x15_r0_body.cplo19, PRE_first_tail_x15_r0_body.ccnt19, PRE_first_tail_x15_r0_body.cnband19, PRE_first_tail_x15_r0_body.chbelow19, PRE_first_tail_x15_r0_body.chren19, PRE_first_tail_x15_r0_body.cband19, PRE_first_tail_x15_r0_body.cnh1pos19, PRE_first_tail_x15_r0_body.cnren19, PRE_first_tail_x15_r0_body.cnlow19, PRE_first_tail_x15_r0_body.cabs0a19, PRE_first_tail_x15_r0_body.cabs0b19, PRE_first_tail_x15_r0_body.ctok119, PRE_first_tail_x15_r0_body.cpend19, PRE_first_tail_x15_r0_body.cerrh19, PRE_first_tail_x15_r0_body.cfiles19, PRE_first_tail_x15_r0_body.carch19, PRE_first_tail_x15_r0_body.csizes19, PRE_first_tail_x15_r0_body.cwired19, PRE_first_tail_x15_r0_body.cfix19, clean, PRE_first_tail_x15_r0_body.fcxn19, PRE_first_tail_x15_r0_body.fcnn19, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle019, PRE_first_tail_x15_r0_body.fnk19, PRE_first_tail_x15_r0_body.ckA19, PRE_first_tail_x15_r0_body.cobjsK19, PRE_first_tail_x15_r0_body.cnodesK19, PRE_first_tail_x15_r0_body.citemsK19, PRE_first_tail_x15_r0_body.f1A19, PRE_first_tail_x15_r0_body.f1O19, PRE_first_tail_x15_r0_body.f1N19, PRE_first_tail_x15_r0_body.f1I19, PRE_first_tail_x15_r0_body.fbd19, PRE_first_tail_x15_r0_body.fincW19, PRE_first_tail_x15_r0_body.fincI19, PRE_first_tail_x15_r0_body.fincN19, PRE_first_tail_x15_r0_body.flnF19, PRE_first_tail_x15_r0_body.fh19, PRE_first_tail_x15_r0_body.fo19, PRE_first_tail_x15_r0_body.fok19, PRE_first_tail_x15_r0_body.fnd19, PRE_first_tail_x15_r0_body.fp19, PRE_first_tail_x15_r0_body.fnord19, PRE_first_tail_x15_r0_body.fi19, PRE_first_tail_x15_r0_body.fii19⟩
theorem PRE_first_tail_x15_r0_body.cnshift19 (clean : Conv.NClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P19.NL) (cl : SSt (· < 893) PRE_first_tail_x15_r0_body.cx0_19.mlx) : NShift PRE_first_tail_x15_r0_body.P19 893 PRE_first_tail_x15_r0_body.kappa19 PRE_first_tail_x15_r0_body.cx0_19 PRE_first_tail_x15_r0_body.cx1_19 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot19 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost19 (compact_a_eq PRE_first_tail_x15_r0_body.ckn019 PRE_first_tail_x15_r0_body.ckn119 PRE_first_tail_x15_r0_body.ckheap19 PRE_first_tail_x15_r0_body.ckpl19)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_19 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s180.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_19 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s180.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_19 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s180.ffi) = some PRE_first_tail_x15_r0_body.fxC_19
kernel_rfl PRE_first_tail_x15_r0_body.okrC_19 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s180.ffi) = some PRE_first_tail_x15_r0_body.krC_19
noncomputable def PRE_first_tail_x15_r0_body.fx0_19 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s182.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_19 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s182.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_19 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s182.ffi) = some PRE_first_tail_x15_r0_body.fx0_19
kernel_rfl PRE_first_tail_x15_r0_body.okr0_19 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s182.ffi) = some PRE_first_tail_x15_r0_body.kr0_19
noncomputable def PRE_first_tail_x15_r0_body.fx1_19 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s181.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_19 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s181.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_19 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s181.ffi) = some PRE_first_tail_x15_r0_body.fx1_19
kernel_rfl PRE_first_tail_x15_r0_body.okr1_19 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s181.ffi) = some PRE_first_tail_x15_r0_body.kr1_19
kernel_rfl PRE_first_tail_x15_r0_body.ff019 : PRE_first_tail_x15_r0_body.fx0_19 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_19 (PRE_first_tail_x15_r0_body.clo19.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_19.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff119 : PRE_first_tail_x15_r0_body.fx1_19 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_19 (PRE_first_tail_x15_r0_body.cwS19.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_19.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck19 : freedLB PRE_first_tail_x15_r0_body.kappa19 PRE_first_tail_x15_r0_body.cx0_19.mlx PRE_first_tail_x15_r0_body.fx0_19 PRE_first_tail_x15_r0_body.fx1_19 PRE_first_tail_x15_r0_body.clo19 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf019 : PRE_first_tail_x15_r0_body.kr0_19.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_19.flags (PRE_first_tail_x15_r0_body.clo19.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_19.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt019 : PRE_first_tail_x15_r0_body.kr0_19.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_19.targs (PRE_first_tail_x15_r0_body.clo19.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_19.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf119 : PRE_first_tail_x15_r0_body.kr1_19.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_19.flags (PRE_first_tail_x15_r0_body.cwS19.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_19.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt119 : PRE_first_tail_x15_r0_body.kr1_19.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_19.targs (PRE_first_tail_x15_r0_body.cwS19.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_19.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck19 : krecLB PRE_first_tail_x15_r0_body.kappa19 893 PRE_first_tail_x15_r0_body.cx0_19.mlx PRE_first_tail_x15_r0_body.kr0_19 PRE_first_tail_x15_r0_body.kr1_19 PRE_first_tail_x15_r0_body.clo19 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn19 : Nat.ble 893 893 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge19 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s181.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s182.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR19 : pendRegB PRE_first_tail_x15_r0_body.kappa19 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s182.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe19 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s182.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s181.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift19 (clean : Conv.NClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P19.NL) (cl : SSt (· < 893) PRE_first_tail_x15_r0_body.cx0_19.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_19.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_19.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_19.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_19.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P19 893 PRE_first_tail_x15_r0_body.kappa19 PRE_first_tail_x15_r0_body.s182.ffi PRE_first_tail_x15_r0_body.s181.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift19 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue19, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp19 t ht),
    PRE_first_tail_x15_r0_body.cbridge19,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s182.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s181.ffi) (PRE_first_tail_x15_r0_body.cfoot19 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_19 PRE_first_tail_x15_r0_body.ofx1_19 hobjC PRE_first_tail_x15_r0_body.ff019 PRE_first_tail_x15_r0_body.ff119 PRE_first_tail_x15_r0_body.ffck19,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s182.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s181.ffi) (PRE_first_tail_x15_r0_body.cfoot19 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_19 PRE_first_tail_x15_r0_body.okr1_19 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn19) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf019 PRE_first_tail_x15_r0_body.fkt019 PRE_first_tail_x15_r0_body.fkf119 PRE_first_tail_x15_r0_body.fkt119 PRE_first_tail_x15_r0_body.fkck19,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh019 PRE_first_tail_x15_r0_body.cnh119 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe19) PRE_first_tail_x15_r0_body.cpendR19⟩

end Host.Load.Run.Tpl
