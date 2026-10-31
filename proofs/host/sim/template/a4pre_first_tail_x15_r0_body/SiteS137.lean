import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl137
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 137 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc137 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P137 : LoadP := PRE_first_tail_x15_r0_body.Pc137.raise 17992
kernel_rfl PRE_first_tail_x15_r0_body.craise137 : Nat.ble PRE_first_tail_x15_r0_body.Pc137.N0 17992 = true
theorem PRE_first_tail_x15_r0_body.raised137 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc137 PRE_first_tail_x15_r0_body.P137 :=
  .inr ⟨17992, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise137, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_137 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_137 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1208.ffi)
def PRE_first_tail_x15_r0_body.khinv137 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv137 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS137 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS137 : List Nat := List.range' 17992 0
def PRE_first_tail_x15_r0_body.ciS137 : List Nat := [] ++ List.range' 17992 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0137 : PRE_first_tail_x15_r0_body.kd137.nh0 = PRE_first_tail_x15_r0_body.cx0_137.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1137 : PRE_first_tail_x15_r0_body.kd137.nh1 = PRE_first_tail_x15_r0_body.cx1_137.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0137 : PRE_first_tail_x15_r0_body.kd137.nn0 = PRE_first_tail_x15_r0_body.cx0_137.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1137 : PRE_first_tail_x15_r0_body.kd137.nn1 = PRE_first_tail_x15_r0_body.cx1_137.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo137 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P137.lo && Nat.ble PRE_first_tail_x15_r0_body.P137.lo PRE_first_tail_x15_r0_body.cx0_137.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P137.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P137.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt137 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_137.mlx.next PRE_first_tail_x15_r0_body.cx1_137.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_137.mlx.nnext PRE_first_tail_x15_r0_body.cx1_137.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband137 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P137.NL && Nat.ble PRE_first_tail_x15_r0_body.P137.NL PRE_first_tail_x15_r0_body.P137.N0 && Nat.ble PRE_first_tail_x15_r0_body.P137.N0 PRE_first_tail_x15_r0_body.cx0_137.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow137 : PRE_first_tail_x15_r0_body.kd137.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren137 : checkRenG PRE_first_tail_x15_r0_body.kd137.hnd PRE_first_tail_x15_r0_body.khinv137 (phB PRE_first_tail_x15_r0_body.cx0_137.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband137 : PRE_first_tail_x15_r0_body.kd137.checkBand PRE_first_tail_x15_r0_body.P137.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos137 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd137.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren137 : checkRenG PRE_first_tail_x15_r0_body.kd137.node PRE_first_tail_x15_r0_body.kninv137 (pnB PRE_first_tail_x15_r0_body.cx0_137.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P137.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd137.nodeF j) PRE_first_tail_x15_r0_body.cx1_137.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a137 : PRE_first_tail_x15_r0_body.cx0_137.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b137 : PRE_first_tail_x15_r0_body.cx0_137.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.pending = PRE_first_tail_x15_r0_body.cx0_137.mlx.pending.map PRE_first_tail_x15_r0_body.kappa137.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.errh = PRE_first_tail_x15_r0_body.cx0_137.mlx.errh.map PRE_first_tail_x15_r0_body.kappa137.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.files = PRE_first_tail_x15_r0_body.cx0_137.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.arch = PRE_first_tail_x15_r0_body.cx0_137.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_137.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.wired = PRE_first_tail_x15_r0_body.cx0_137.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost137 : PRE_first_tail_x15_r0_body.cx1_137.host = PRE_first_tail_x15_r0_body.cx0_137.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd137`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0137 : PRE_first_tail_x15_r0_body.kd137.n0 = 2782076
kernel_rfl PRE_first_tail_x15_r0_body.ckn1137 : PRE_first_tail_x15_r0_body.kd137.n1 = 2782095
kernel_rfl PRE_first_tail_x15_r0_body.ckheap137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.heap).all (fun x => Nat.ble 2782075 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl137 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd137.heap.get (2782075 + j) = nth? PRE_first_tail_x15_r0_body.pl137 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja137 : Nat.ble 2782075 2782075 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn137 : Nat.ble 5911 5911 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD137 : Nat.ble 2782075 PRE_first_tail_x15_r0_body.kd137.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn137 : Nat.ble 20892 PRE_first_tail_x15_r0_body.kd137.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn137 : Nat.ble 17992 PRE_first_tail_x15_r0_body.kd137.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb137 : Nat.ble 20892 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.heap).all (Nat.ble (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.hnd).all (Nat.ble (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.node).all (Nat.ble (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix137 : Conv.FixOld (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa137 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja137) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn137) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD137) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn137) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn137) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb137) PRE_first_tail_x15_r0_body.fheap137 PRE_first_tail_x15_r0_body.fhnd137 PRE_first_tail_x15_r0_body.fnode137
kernel_rfl PRE_first_tail_x15_r0_body.fcxn137 : (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn137 : (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0137 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_137.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_137.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS137.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_137.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS137.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_137.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS137.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_137.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS137.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_137.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd137 : (PRE_first_tail_x15_r0_body.clo137 ++ PRE_first_tail_x15_r0_body.cln137 ++ PRE_first_tail_x15_r0_body.cli137 ++ PRE_first_tail_x15_r0_body.cwS137 ++ PRE_first_tail_x15_r0_body.cnS137 ++ PRE_first_tail_x15_r0_body.ciS137).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW137 : PRE_first_tail_x15_r0_body.cwS137.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo137.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI137 : PRE_first_tail_x15_r0_body.ciS137.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli137.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN137 : PRE_first_tail_x15_r0_body.cnS137.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF137 : PRE_first_tail_x15_r0_body.cln137.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh137 : PRE_first_tail_x15_r0_body.clo137.all (handleOK PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.P137.lo PRE_first_tail_x15_r0_body.cx0_137.mlx PRE_first_tail_x15_r0_body.cx1_137.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo137 : PRE_first_tail_x15_r0_body.clo137.map (fun h => PRE_first_tail_x15_r0_body.cx1_137.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa137.handle h)) = PRE_first_tail_x15_r0_body.clo137.map (fun h => (PRE_first_tail_x15_r0_body.cx0_137.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa137.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok137 : PRE_first_tail_x15_r0_body.clo137.all (objOK PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.P137.NL PRE_first_tail_x15_r0_body.cx0_137.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd137 : PRE_first_tail_x15_r0_body.cln137.all (nodeOKF PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.P137 PRE_first_tail_x15_r0_body.cx0_137.mlx PRE_first_tail_x15_r0_body.cx1_137.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp137 : ((PRE_first_tail_x15_r0_body.cln137.filter (fullB PRE_first_tail_x15_r0_body.P137))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_137.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa137.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln137.filter (fullB PRE_first_tail_x15_r0_body.P137))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_137.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa137.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI137 : incrB PRE_first_tail_x15_r0_body.kd137.nodeF (List.range' 17992 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.node).all (fun k => Nat.ble 17992 k && Nat.blt k 17992) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL137 : (PRE_first_tail_x15_r0_body.cln137.filter (Nat.ble PRE_first_tail_x15_r0_body.P137.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd137.nodeF i) && (Nat.blt i 17992 || Nat.ble PRE_first_tail_x15_r0_body.kd137.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord137 : (PRE_first_tail_x15_r0_body.cln137.filter (Nat.ble PRE_first_tail_x15_r0_body.P137.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd137.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd137.nodeF j) (PRE_first_tail_x15_r0_body.kd137.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow137 PRE_first_tail_x15_r0_body.cnn1137 PRE_first_tail_x15_r0_body.fnordI137 PRE_first_tail_x15_r0_body.fnordK137 PRE_first_tail_x15_r0_body.fnordL137
kernel_rfl PRE_first_tail_x15_r0_body.fi137 : PRE_first_tail_x15_r0_body.cli137.all (pnB PRE_first_tail_x15_r0_body.cx0_137.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii137 : PRE_first_tail_x15_r0_body.cli137.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_137.mlx.items.get (PRE_first_tail_x15_r0_body.kappa137.node k) = (PRE_first_tail_x15_r0_body.cx0_137.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa137.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot137 (clean : Conv.NClean (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P137.NL) (cl : SSt (· < 5911) PRE_first_tail_x15_r0_body.cx0_137.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P137 5911 PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.kd137 PRE_first_tail_x15_r0_body.khinv137 PRE_first_tail_x15_r0_body.kninv137 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx PRE_first_tail_x15_r0_body.cx0_137.mlx PRE_first_tail_x15_r0_body.cx1_137.mlx (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo137 PRE_first_tail_x15_r0_body.cln137 PRE_first_tail_x15_r0_body.cli137 PRE_first_tail_x15_r0_body.cwS137 PRE_first_tail_x15_r0_body.cnS137 PRE_first_tail_x15_r0_body.ciS137 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0137, PRE_first_tail_x15_r0_body.cnh1137, PRE_first_tail_x15_r0_body.cnn0137, PRE_first_tail_x15_r0_body.cnn1137, PRE_first_tail_x15_r0_body.cplo137, PRE_first_tail_x15_r0_body.ccnt137, PRE_first_tail_x15_r0_body.cnband137, PRE_first_tail_x15_r0_body.chbelow137, PRE_first_tail_x15_r0_body.chren137, PRE_first_tail_x15_r0_body.cband137, PRE_first_tail_x15_r0_body.cnh1pos137, PRE_first_tail_x15_r0_body.cnren137, PRE_first_tail_x15_r0_body.cnlow137, PRE_first_tail_x15_r0_body.cabs0a137, PRE_first_tail_x15_r0_body.cabs0b137, PRE_first_tail_x15_r0_body.ctok1137, PRE_first_tail_x15_r0_body.cpend137, PRE_first_tail_x15_r0_body.cerrh137, PRE_first_tail_x15_r0_body.cfiles137, PRE_first_tail_x15_r0_body.carch137, PRE_first_tail_x15_r0_body.csizes137, PRE_first_tail_x15_r0_body.cwired137, PRE_first_tail_x15_r0_body.cfix137, clean, PRE_first_tail_x15_r0_body.fcxn137, PRE_first_tail_x15_r0_body.fcnn137, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0137, PRE_first_tail_x15_r0_body.fnk137, PRE_first_tail_x15_r0_body.ckA137, PRE_first_tail_x15_r0_body.cobjsK137, PRE_first_tail_x15_r0_body.cnodesK137, PRE_first_tail_x15_r0_body.citemsK137, PRE_first_tail_x15_r0_body.f1A137, PRE_first_tail_x15_r0_body.f1O137, PRE_first_tail_x15_r0_body.f1N137, PRE_first_tail_x15_r0_body.f1I137, PRE_first_tail_x15_r0_body.fbd137, PRE_first_tail_x15_r0_body.fincW137, PRE_first_tail_x15_r0_body.fincI137, PRE_first_tail_x15_r0_body.fincN137, PRE_first_tail_x15_r0_body.flnF137, PRE_first_tail_x15_r0_body.fh137, PRE_first_tail_x15_r0_body.fo137, PRE_first_tail_x15_r0_body.fok137, PRE_first_tail_x15_r0_body.fnd137, PRE_first_tail_x15_r0_body.fp137, PRE_first_tail_x15_r0_body.fnord137, PRE_first_tail_x15_r0_body.fi137, PRE_first_tail_x15_r0_body.fii137⟩
theorem PRE_first_tail_x15_r0_body.cnshift137 (clean : Conv.NClean (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P137.NL) (cl : SSt (· < 5911) PRE_first_tail_x15_r0_body.cx0_137.mlx) : NShift PRE_first_tail_x15_r0_body.P137 5911 PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.cx0_137 PRE_first_tail_x15_r0_body.cx1_137 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot137 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost137 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0137 PRE_first_tail_x15_r0_body.ckn1137 PRE_first_tail_x15_r0_body.ckheap137 PRE_first_tail_x15_r0_body.ckpl137)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_137 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1207.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_137 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1207.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_137 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1207.ffi) = some PRE_first_tail_x15_r0_body.fxC_137
kernel_rfl PRE_first_tail_x15_r0_body.okrC_137 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1207.ffi) = some PRE_first_tail_x15_r0_body.krC_137
noncomputable def PRE_first_tail_x15_r0_body.fx0_137 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1209.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_137 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1209.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_137 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1209.ffi) = some PRE_first_tail_x15_r0_body.fx0_137
kernel_rfl PRE_first_tail_x15_r0_body.okr0_137 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1209.ffi) = some PRE_first_tail_x15_r0_body.kr0_137
noncomputable def PRE_first_tail_x15_r0_body.fx1_137 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1208.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_137 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1208.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_137 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1208.ffi) = some PRE_first_tail_x15_r0_body.fx1_137
kernel_rfl PRE_first_tail_x15_r0_body.okr1_137 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1208.ffi) = some PRE_first_tail_x15_r0_body.kr1_137
kernel_rfl PRE_first_tail_x15_r0_body.ff0137 : PRE_first_tail_x15_r0_body.fx0_137 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_137 (PRE_first_tail_x15_r0_body.clo137.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_137.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1137 : PRE_first_tail_x15_r0_body.fx1_137 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_137 (PRE_first_tail_x15_r0_body.cwS137.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_137.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck137 : freedLB PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.cx0_137.mlx PRE_first_tail_x15_r0_body.fx0_137 PRE_first_tail_x15_r0_body.fx1_137 PRE_first_tail_x15_r0_body.clo137 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0137 : PRE_first_tail_x15_r0_body.kr0_137.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_137.flags (PRE_first_tail_x15_r0_body.clo137.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_137.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0137 : PRE_first_tail_x15_r0_body.kr0_137.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_137.targs (PRE_first_tail_x15_r0_body.clo137.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_137.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1137 : PRE_first_tail_x15_r0_body.kr1_137.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_137.flags (PRE_first_tail_x15_r0_body.cwS137.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_137.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1137 : PRE_first_tail_x15_r0_body.kr1_137.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_137.targs (PRE_first_tail_x15_r0_body.cwS137.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_137.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck137 : krecLB PRE_first_tail_x15_r0_body.kappa137 5911 PRE_first_tail_x15_r0_body.cx0_137.mlx PRE_first_tail_x15_r0_body.kr0_137 PRE_first_tail_x15_r0_body.kr1_137 PRE_first_tail_x15_r0_body.clo137 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn137 : Nat.ble 5911 5911 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge137 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1208.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1209.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR137 : pendRegB PRE_first_tail_x15_r0_body.kappa137 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe137 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1208.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift137 (clean : Conv.NClean (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P137.NL) (cl : SSt (· < 5911) PRE_first_tail_x15_r0_body.cx0_137.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_137.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_137.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_137.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_137.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P137 5911 PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.s1209.ffi PRE_first_tail_x15_r0_body.s1208.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift137 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue137, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp137 t ht),
    PRE_first_tail_x15_r0_body.cbridge137,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1209.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1208.ffi) (PRE_first_tail_x15_r0_body.cfoot137 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_137 PRE_first_tail_x15_r0_body.ofx1_137 hobjC PRE_first_tail_x15_r0_body.ff0137 PRE_first_tail_x15_r0_body.ff1137 PRE_first_tail_x15_r0_body.ffck137,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1209.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1208.ffi) (PRE_first_tail_x15_r0_body.cfoot137 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_137 PRE_first_tail_x15_r0_body.okr1_137 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn137) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0137 PRE_first_tail_x15_r0_body.fkt0137 PRE_first_tail_x15_r0_body.fkf1137 PRE_first_tail_x15_r0_body.fkt1137 PRE_first_tail_x15_r0_body.fkck137,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0137 PRE_first_tail_x15_r0_body.cnh1137 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe137) PRE_first_tail_x15_r0_body.cpendR137⟩

end Host.Load.Run.Tpl
