import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl187
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 187 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc187 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P187 : LoadP := PRE_first_tail_x15_r0_body.Pc187.raise 18999
kernel_rfl PRE_first_tail_x15_r0_body.craise187 : Nat.ble PRE_first_tail_x15_r0_body.Pc187.N0 18999 = true
theorem PRE_first_tail_x15_r0_body.raised187 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc187 PRE_first_tail_x15_r0_body.P187 :=
  .inr ⟨18999, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise187, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_187 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_187 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1808.ffi)
def PRE_first_tail_x15_r0_body.khinv187 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv187 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS187 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS187 : List Nat := List.range' 18999 0
def PRE_first_tail_x15_r0_body.ciS187 : List Nat := [] ++ List.range' 18999 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0187 : PRE_first_tail_x15_r0_body.kd187.nh0 = PRE_first_tail_x15_r0_body.cx0_187.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1187 : PRE_first_tail_x15_r0_body.kd187.nh1 = PRE_first_tail_x15_r0_body.cx1_187.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0187 : PRE_first_tail_x15_r0_body.kd187.nn0 = PRE_first_tail_x15_r0_body.cx0_187.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1187 : PRE_first_tail_x15_r0_body.kd187.nn1 = PRE_first_tail_x15_r0_body.cx1_187.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo187 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P187.lo && Nat.ble PRE_first_tail_x15_r0_body.P187.lo PRE_first_tail_x15_r0_body.cx0_187.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P187.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P187.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt187 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_187.mlx.next PRE_first_tail_x15_r0_body.cx1_187.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_187.mlx.nnext PRE_first_tail_x15_r0_body.cx1_187.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband187 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P187.NL && Nat.ble PRE_first_tail_x15_r0_body.P187.NL PRE_first_tail_x15_r0_body.P187.N0 && Nat.ble PRE_first_tail_x15_r0_body.P187.N0 PRE_first_tail_x15_r0_body.cx0_187.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow187 : PRE_first_tail_x15_r0_body.kd187.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren187 : checkRenG PRE_first_tail_x15_r0_body.kd187.hnd PRE_first_tail_x15_r0_body.khinv187 (phB PRE_first_tail_x15_r0_body.cx0_187.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband187 : PRE_first_tail_x15_r0_body.kd187.checkBand PRE_first_tail_x15_r0_body.P187.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos187 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd187.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren187 : checkRenG PRE_first_tail_x15_r0_body.kd187.node PRE_first_tail_x15_r0_body.kninv187 (pnB PRE_first_tail_x15_r0_body.cx0_187.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P187.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd187.nodeF j) PRE_first_tail_x15_r0_body.cx1_187.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a187 : PRE_first_tail_x15_r0_body.cx0_187.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b187 : PRE_first_tail_x15_r0_body.cx0_187.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.pending = PRE_first_tail_x15_r0_body.cx0_187.mlx.pending.map PRE_first_tail_x15_r0_body.kappa187.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.errh = PRE_first_tail_x15_r0_body.cx0_187.mlx.errh.map PRE_first_tail_x15_r0_body.kappa187.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.files = PRE_first_tail_x15_r0_body.cx0_187.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.arch = PRE_first_tail_x15_r0_body.cx0_187.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_187.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.wired = PRE_first_tail_x15_r0_body.cx0_187.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost187 : PRE_first_tail_x15_r0_body.cx1_187.host = PRE_first_tail_x15_r0_body.cx0_187.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd187`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0187 : PRE_first_tail_x15_r0_body.kd187.n0 = 2821743
kernel_rfl PRE_first_tail_x15_r0_body.ckn1187 : PRE_first_tail_x15_r0_body.kd187.n1 = 2821745
kernel_rfl PRE_first_tail_x15_r0_body.ckheap187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.heap).all (fun x => Nat.ble 2821743 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl187 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd187.heap.get (2821743 + j) = nth? PRE_first_tail_x15_r0_body.pl187 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja187 : Nat.ble 2821743 2821743 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn187 : Nat.ble 8075 8075 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD187 : Nat.ble 2821743 PRE_first_tail_x15_r0_body.kd187.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn187 : Nat.ble 21886 PRE_first_tail_x15_r0_body.kd187.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn187 : Nat.ble 18999 PRE_first_tail_x15_r0_body.kd187.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb187 : Nat.ble 21886 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.heap).all (Nat.ble (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.hnd).all (Nat.ble (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.node).all (Nat.ble (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix187 : Conv.FixOld (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa187 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja187) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn187) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD187) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn187) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn187) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb187) PRE_first_tail_x15_r0_body.fheap187 PRE_first_tail_x15_r0_body.fhnd187 PRE_first_tail_x15_r0_body.fnode187
kernel_rfl PRE_first_tail_x15_r0_body.fcxn187 : (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn187 : (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0187 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_187.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_187.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS187.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_187.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS187.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_187.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS187.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_187.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS187.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_187.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd187 : (PRE_first_tail_x15_r0_body.clo187 ++ PRE_first_tail_x15_r0_body.cln187 ++ PRE_first_tail_x15_r0_body.cli187 ++ PRE_first_tail_x15_r0_body.cwS187 ++ PRE_first_tail_x15_r0_body.cnS187 ++ PRE_first_tail_x15_r0_body.ciS187).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW187 : PRE_first_tail_x15_r0_body.cwS187.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo187.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI187 : PRE_first_tail_x15_r0_body.ciS187.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli187.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN187 : PRE_first_tail_x15_r0_body.cnS187.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF187 : PRE_first_tail_x15_r0_body.cln187.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh187 : PRE_first_tail_x15_r0_body.clo187.all (handleOK PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.P187.lo PRE_first_tail_x15_r0_body.cx0_187.mlx PRE_first_tail_x15_r0_body.cx1_187.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo187 : PRE_first_tail_x15_r0_body.clo187.map (fun h => PRE_first_tail_x15_r0_body.cx1_187.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa187.handle h)) = PRE_first_tail_x15_r0_body.clo187.map (fun h => (PRE_first_tail_x15_r0_body.cx0_187.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa187.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok187 : PRE_first_tail_x15_r0_body.clo187.all (objOK PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.P187.NL PRE_first_tail_x15_r0_body.cx0_187.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd187 : PRE_first_tail_x15_r0_body.cln187.all (nodeOKF PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.P187 PRE_first_tail_x15_r0_body.cx0_187.mlx PRE_first_tail_x15_r0_body.cx1_187.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp187 : ((PRE_first_tail_x15_r0_body.cln187.filter (fullB PRE_first_tail_x15_r0_body.P187))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_187.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa187.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln187.filter (fullB PRE_first_tail_x15_r0_body.P187))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_187.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa187.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI187 : incrB PRE_first_tail_x15_r0_body.kd187.nodeF (List.range' 18999 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.node).all (fun k => Nat.ble 18999 k && Nat.blt k 18999) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL187 : (PRE_first_tail_x15_r0_body.cln187.filter (Nat.ble PRE_first_tail_x15_r0_body.P187.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd187.nodeF i) && (Nat.blt i 18999 || Nat.ble PRE_first_tail_x15_r0_body.kd187.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord187 : (PRE_first_tail_x15_r0_body.cln187.filter (Nat.ble PRE_first_tail_x15_r0_body.P187.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd187.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd187.nodeF j) (PRE_first_tail_x15_r0_body.kd187.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow187 PRE_first_tail_x15_r0_body.cnn1187 PRE_first_tail_x15_r0_body.fnordI187 PRE_first_tail_x15_r0_body.fnordK187 PRE_first_tail_x15_r0_body.fnordL187
kernel_rfl PRE_first_tail_x15_r0_body.fi187 : PRE_first_tail_x15_r0_body.cli187.all (pnB PRE_first_tail_x15_r0_body.cx0_187.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii187 : PRE_first_tail_x15_r0_body.cli187.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_187.mlx.items.get (PRE_first_tail_x15_r0_body.kappa187.node k) = (PRE_first_tail_x15_r0_body.cx0_187.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa187.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot187 (clean : Conv.NClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P187.NL) (cl : SSt (· < 8075) PRE_first_tail_x15_r0_body.cx0_187.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P187 8075 PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.kd187 PRE_first_tail_x15_r0_body.khinv187 PRE_first_tail_x15_r0_body.kninv187 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx PRE_first_tail_x15_r0_body.cx0_187.mlx PRE_first_tail_x15_r0_body.cx1_187.mlx (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo187 PRE_first_tail_x15_r0_body.cln187 PRE_first_tail_x15_r0_body.cli187 PRE_first_tail_x15_r0_body.cwS187 PRE_first_tail_x15_r0_body.cnS187 PRE_first_tail_x15_r0_body.ciS187 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0187, PRE_first_tail_x15_r0_body.cnh1187, PRE_first_tail_x15_r0_body.cnn0187, PRE_first_tail_x15_r0_body.cnn1187, PRE_first_tail_x15_r0_body.cplo187, PRE_first_tail_x15_r0_body.ccnt187, PRE_first_tail_x15_r0_body.cnband187, PRE_first_tail_x15_r0_body.chbelow187, PRE_first_tail_x15_r0_body.chren187, PRE_first_tail_x15_r0_body.cband187, PRE_first_tail_x15_r0_body.cnh1pos187, PRE_first_tail_x15_r0_body.cnren187, PRE_first_tail_x15_r0_body.cnlow187, PRE_first_tail_x15_r0_body.cabs0a187, PRE_first_tail_x15_r0_body.cabs0b187, PRE_first_tail_x15_r0_body.ctok1187, PRE_first_tail_x15_r0_body.cpend187, PRE_first_tail_x15_r0_body.cerrh187, PRE_first_tail_x15_r0_body.cfiles187, PRE_first_tail_x15_r0_body.carch187, PRE_first_tail_x15_r0_body.csizes187, PRE_first_tail_x15_r0_body.cwired187, PRE_first_tail_x15_r0_body.cfix187, clean, PRE_first_tail_x15_r0_body.fcxn187, PRE_first_tail_x15_r0_body.fcnn187, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0187, PRE_first_tail_x15_r0_body.fnk187, PRE_first_tail_x15_r0_body.ckA187, PRE_first_tail_x15_r0_body.cobjsK187, PRE_first_tail_x15_r0_body.cnodesK187, PRE_first_tail_x15_r0_body.citemsK187, PRE_first_tail_x15_r0_body.f1A187, PRE_first_tail_x15_r0_body.f1O187, PRE_first_tail_x15_r0_body.f1N187, PRE_first_tail_x15_r0_body.f1I187, PRE_first_tail_x15_r0_body.fbd187, PRE_first_tail_x15_r0_body.fincW187, PRE_first_tail_x15_r0_body.fincI187, PRE_first_tail_x15_r0_body.fincN187, PRE_first_tail_x15_r0_body.flnF187, PRE_first_tail_x15_r0_body.fh187, PRE_first_tail_x15_r0_body.fo187, PRE_first_tail_x15_r0_body.fok187, PRE_first_tail_x15_r0_body.fnd187, PRE_first_tail_x15_r0_body.fp187, PRE_first_tail_x15_r0_body.fnord187, PRE_first_tail_x15_r0_body.fi187, PRE_first_tail_x15_r0_body.fii187⟩
theorem PRE_first_tail_x15_r0_body.cnshift187 (clean : Conv.NClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P187.NL) (cl : SSt (· < 8075) PRE_first_tail_x15_r0_body.cx0_187.mlx) : NShift PRE_first_tail_x15_r0_body.P187 8075 PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.cx0_187 PRE_first_tail_x15_r0_body.cx1_187 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot187 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost187 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0187 PRE_first_tail_x15_r0_body.ckn1187 PRE_first_tail_x15_r0_body.ckheap187 PRE_first_tail_x15_r0_body.ckpl187)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_187 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1807.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_187 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1807.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_187 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1807.ffi) = some PRE_first_tail_x15_r0_body.fxC_187
kernel_rfl PRE_first_tail_x15_r0_body.okrC_187 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1807.ffi) = some PRE_first_tail_x15_r0_body.krC_187
noncomputable def PRE_first_tail_x15_r0_body.fx0_187 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1809.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_187 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1809.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_187 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1809.ffi) = some PRE_first_tail_x15_r0_body.fx0_187
kernel_rfl PRE_first_tail_x15_r0_body.okr0_187 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1809.ffi) = some PRE_first_tail_x15_r0_body.kr0_187
noncomputable def PRE_first_tail_x15_r0_body.fx1_187 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1808.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_187 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1808.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_187 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1808.ffi) = some PRE_first_tail_x15_r0_body.fx1_187
kernel_rfl PRE_first_tail_x15_r0_body.okr1_187 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1808.ffi) = some PRE_first_tail_x15_r0_body.kr1_187
kernel_rfl PRE_first_tail_x15_r0_body.ff0187 : PRE_first_tail_x15_r0_body.fx0_187 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_187 (PRE_first_tail_x15_r0_body.clo187.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_187.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1187 : PRE_first_tail_x15_r0_body.fx1_187 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_187 (PRE_first_tail_x15_r0_body.cwS187.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_187.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck187 : freedLB PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.cx0_187.mlx PRE_first_tail_x15_r0_body.fx0_187 PRE_first_tail_x15_r0_body.fx1_187 PRE_first_tail_x15_r0_body.clo187 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0187 : PRE_first_tail_x15_r0_body.kr0_187.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_187.flags (PRE_first_tail_x15_r0_body.clo187.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_187.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0187 : PRE_first_tail_x15_r0_body.kr0_187.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_187.targs (PRE_first_tail_x15_r0_body.clo187.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_187.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1187 : PRE_first_tail_x15_r0_body.kr1_187.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_187.flags (PRE_first_tail_x15_r0_body.cwS187.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_187.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1187 : PRE_first_tail_x15_r0_body.kr1_187.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_187.targs (PRE_first_tail_x15_r0_body.cwS187.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_187.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck187 : krecLB PRE_first_tail_x15_r0_body.kappa187 8075 PRE_first_tail_x15_r0_body.cx0_187.mlx PRE_first_tail_x15_r0_body.kr0_187 PRE_first_tail_x15_r0_body.kr1_187 PRE_first_tail_x15_r0_body.clo187 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn187 : Nat.ble 8075 8075 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge187 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1808.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1809.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR187 : pendRegB PRE_first_tail_x15_r0_body.kappa187 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe187 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1808.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift187 (clean : Conv.NClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P187.NL) (cl : SSt (· < 8075) PRE_first_tail_x15_r0_body.cx0_187.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_187.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_187.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_187.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_187.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P187 8075 PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.s1809.ffi PRE_first_tail_x15_r0_body.s1808.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift187 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue187, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp187 t ht),
    PRE_first_tail_x15_r0_body.cbridge187,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1809.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1808.ffi) (PRE_first_tail_x15_r0_body.cfoot187 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_187 PRE_first_tail_x15_r0_body.ofx1_187 hobjC PRE_first_tail_x15_r0_body.ff0187 PRE_first_tail_x15_r0_body.ff1187 PRE_first_tail_x15_r0_body.ffck187,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1809.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1808.ffi) (PRE_first_tail_x15_r0_body.cfoot187 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_187 PRE_first_tail_x15_r0_body.okr1_187 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn187) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0187 PRE_first_tail_x15_r0_body.fkt0187 PRE_first_tail_x15_r0_body.fkf1187 PRE_first_tail_x15_r0_body.fkt1187 PRE_first_tail_x15_r0_body.fkck187,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0187 PRE_first_tail_x15_r0_body.cnh1187 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe187) PRE_first_tail_x15_r0_body.cpendR187⟩

end Host.Load.Run.Tpl
