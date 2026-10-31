import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl69
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 69 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc69 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P69 : LoadP := PRE_first_tail_x15_r0_body.Pc69.raise 16667
kernel_rfl PRE_first_tail_x15_r0_body.craise69 : Nat.ble PRE_first_tail_x15_r0_body.Pc69.N0 16667 = true
theorem PRE_first_tail_x15_r0_body.raised69 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc69 PRE_first_tail_x15_r0_body.P69 :=
  .inr ⟨16667, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise69, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_69 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_69 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s618.ffi)
def PRE_first_tail_x15_r0_body.khinv69 : PTrie Nat := Stage.setAll PTrie.nil [(19575, 19573), (19576, 19574), (19578, 19575), (19577, 19576)]
def PRE_first_tail_x15_r0_body.kninv69 : PTrie Nat := Stage.setAll PTrie.nil [(16661, 16661), (16662, 16662), (16663, 16663), (16664, 16664), (16665, 16665), (16666, 16666)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS69 : List Nat := [19573, 19574, 19575, 19576, 19577, 19578]
def PRE_first_tail_x15_r0_body.cnS69 : List Nat := List.range' 16661 6
def PRE_first_tail_x15_r0_body.ciS69 : List Nat := [] ++ List.range' 16661 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh069 : PRE_first_tail_x15_r0_body.kd69.nh0 = PRE_first_tail_x15_r0_body.cx0_69.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh169 : PRE_first_tail_x15_r0_body.kd69.nh1 = PRE_first_tail_x15_r0_body.cx1_69.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn069 : PRE_first_tail_x15_r0_body.kd69.nn0 = PRE_first_tail_x15_r0_body.cx0_69.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn169 : PRE_first_tail_x15_r0_body.kd69.nn1 = PRE_first_tail_x15_r0_body.cx1_69.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo69 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P69.lo && Nat.ble PRE_first_tail_x15_r0_body.P69.lo PRE_first_tail_x15_r0_body.cx0_69.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P69.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P69.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt69 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_69.mlx.next PRE_first_tail_x15_r0_body.cx1_69.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_69.mlx.nnext PRE_first_tail_x15_r0_body.cx1_69.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband69 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P69.NL && Nat.ble PRE_first_tail_x15_r0_body.P69.NL PRE_first_tail_x15_r0_body.P69.N0 && Nat.ble PRE_first_tail_x15_r0_body.P69.N0 PRE_first_tail_x15_r0_body.cx0_69.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow69 : PRE_first_tail_x15_r0_body.kd69.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren69 : checkRenG PRE_first_tail_x15_r0_body.kd69.hnd PRE_first_tail_x15_r0_body.khinv69 (phB PRE_first_tail_x15_r0_body.cx0_69.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband69 : PRE_first_tail_x15_r0_body.kd69.checkBand PRE_first_tail_x15_r0_body.P69.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos69 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd69.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren69 : checkRenG PRE_first_tail_x15_r0_body.kd69.node PRE_first_tail_x15_r0_body.kninv69 (pnB PRE_first_tail_x15_r0_body.cx0_69.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P69.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd69.nodeF j) PRE_first_tail_x15_r0_body.cx1_69.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a69 : PRE_first_tail_x15_r0_body.cx0_69.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b69 : PRE_first_tail_x15_r0_body.cx0_69.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok169 : PRE_first_tail_x15_r0_body.cx1_69.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.pending = PRE_first_tail_x15_r0_body.cx0_69.mlx.pending.map PRE_first_tail_x15_r0_body.kappa69.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.errh = PRE_first_tail_x15_r0_body.cx0_69.mlx.errh.map PRE_first_tail_x15_r0_body.kappa69.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.files = PRE_first_tail_x15_r0_body.cx0_69.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.arch = PRE_first_tail_x15_r0_body.cx0_69.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_69.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.wired = PRE_first_tail_x15_r0_body.cx0_69.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost69 : PRE_first_tail_x15_r0_body.cx1_69.host = PRE_first_tail_x15_r0_body.cx0_69.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd69`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn069 : PRE_first_tail_x15_r0_body.kd69.n0 = 2729595
kernel_rfl PRE_first_tail_x15_r0_body.ckn169 : PRE_first_tail_x15_r0_body.kd69.n1 = 2729945
kernel_rfl PRE_first_tail_x15_r0_body.ckheap69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.heap).all (fun x => Nat.ble 2729580 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl69 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd69.heap.get (2729580 + j) = nth? PRE_first_tail_x15_r0_body.pl69 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja69 : Nat.ble 2729580 2729580 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn69 : Nat.ble 3039 3039 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD69 : Nat.ble 2729580 PRE_first_tail_x15_r0_body.kd69.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn69 : Nat.ble 19573 PRE_first_tail_x15_r0_body.kd69.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn69 : Nat.ble 16661 PRE_first_tail_x15_r0_body.kd69.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb69 : Nat.ble 19573 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.heap).all (Nat.ble (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.hnd).all (Nat.ble (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.node).all (Nat.ble (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix69 : Conv.FixOld (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa69 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja69) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn69) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD69) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn69) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn69) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb69) PRE_first_tail_x15_r0_body.fheap69 PRE_first_tail_x15_r0_body.fhnd69 PRE_first_tail_x15_r0_body.fnode69
kernel_rfl PRE_first_tail_x15_r0_body.fcxn69 : (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn69 : (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle069 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_69.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_69.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS69.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_69.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS69.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_69.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS69.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_69.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS69.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_69.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd69 : (PRE_first_tail_x15_r0_body.clo69 ++ PRE_first_tail_x15_r0_body.cln69 ++ PRE_first_tail_x15_r0_body.cli69 ++ PRE_first_tail_x15_r0_body.cwS69 ++ PRE_first_tail_x15_r0_body.cnS69 ++ PRE_first_tail_x15_r0_body.ciS69).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW69 : PRE_first_tail_x15_r0_body.cwS69.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo69.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI69 : PRE_first_tail_x15_r0_body.ciS69.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli69.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN69 : PRE_first_tail_x15_r0_body.cnS69.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF69 : PRE_first_tail_x15_r0_body.cln69.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh69 : PRE_first_tail_x15_r0_body.clo69.all (handleOK PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.P69.lo PRE_first_tail_x15_r0_body.cx0_69.mlx PRE_first_tail_x15_r0_body.cx1_69.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo69 : PRE_first_tail_x15_r0_body.clo69.map (fun h => PRE_first_tail_x15_r0_body.cx1_69.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa69.handle h)) = PRE_first_tail_x15_r0_body.clo69.map (fun h => (PRE_first_tail_x15_r0_body.cx0_69.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa69.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok69 : PRE_first_tail_x15_r0_body.clo69.all (objOK PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.P69.NL PRE_first_tail_x15_r0_body.cx0_69.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd69 : PRE_first_tail_x15_r0_body.cln69.all (nodeOKF PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.P69 PRE_first_tail_x15_r0_body.cx0_69.mlx PRE_first_tail_x15_r0_body.cx1_69.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp69 : ((PRE_first_tail_x15_r0_body.cln69.filter (fullB PRE_first_tail_x15_r0_body.P69))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_69.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa69.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln69.filter (fullB PRE_first_tail_x15_r0_body.P69))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_69.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa69.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI69 : incrB PRE_first_tail_x15_r0_body.kd69.nodeF (List.range' 16661 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.node).all (fun k => Nat.ble 16661 k && Nat.blt k 16667) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL69 : (PRE_first_tail_x15_r0_body.cln69.filter (Nat.ble PRE_first_tail_x15_r0_body.P69.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd69.nodeF i) && (Nat.blt i 16667 || Nat.ble PRE_first_tail_x15_r0_body.kd69.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord69 : (PRE_first_tail_x15_r0_body.cln69.filter (Nat.ble PRE_first_tail_x15_r0_body.P69.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd69.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd69.nodeF j) (PRE_first_tail_x15_r0_body.kd69.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow69 PRE_first_tail_x15_r0_body.cnn169 PRE_first_tail_x15_r0_body.fnordI69 PRE_first_tail_x15_r0_body.fnordK69 PRE_first_tail_x15_r0_body.fnordL69
kernel_rfl PRE_first_tail_x15_r0_body.fi69 : PRE_first_tail_x15_r0_body.cli69.all (pnB PRE_first_tail_x15_r0_body.cx0_69.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii69 : PRE_first_tail_x15_r0_body.cli69.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_69.mlx.items.get (PRE_first_tail_x15_r0_body.kappa69.node k) = (PRE_first_tail_x15_r0_body.cx0_69.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa69.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot69 (clean : Conv.NClean (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P69.NL) (cl : SSt (· < 3048) PRE_first_tail_x15_r0_body.cx0_69.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P69 3048 PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.kd69 PRE_first_tail_x15_r0_body.khinv69 PRE_first_tail_x15_r0_body.kninv69 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx PRE_first_tail_x15_r0_body.cx0_69.mlx PRE_first_tail_x15_r0_body.cx1_69.mlx (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo69 PRE_first_tail_x15_r0_body.cln69 PRE_first_tail_x15_r0_body.cli69 PRE_first_tail_x15_r0_body.cwS69 PRE_first_tail_x15_r0_body.cnS69 PRE_first_tail_x15_r0_body.ciS69 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh069, PRE_first_tail_x15_r0_body.cnh169, PRE_first_tail_x15_r0_body.cnn069, PRE_first_tail_x15_r0_body.cnn169, PRE_first_tail_x15_r0_body.cplo69, PRE_first_tail_x15_r0_body.ccnt69, PRE_first_tail_x15_r0_body.cnband69, PRE_first_tail_x15_r0_body.chbelow69, PRE_first_tail_x15_r0_body.chren69, PRE_first_tail_x15_r0_body.cband69, PRE_first_tail_x15_r0_body.cnh1pos69, PRE_first_tail_x15_r0_body.cnren69, PRE_first_tail_x15_r0_body.cnlow69, PRE_first_tail_x15_r0_body.cabs0a69, PRE_first_tail_x15_r0_body.cabs0b69, PRE_first_tail_x15_r0_body.ctok169, PRE_first_tail_x15_r0_body.cpend69, PRE_first_tail_x15_r0_body.cerrh69, PRE_first_tail_x15_r0_body.cfiles69, PRE_first_tail_x15_r0_body.carch69, PRE_first_tail_x15_r0_body.csizes69, PRE_first_tail_x15_r0_body.cwired69, PRE_first_tail_x15_r0_body.cfix69, clean, PRE_first_tail_x15_r0_body.fcxn69, PRE_first_tail_x15_r0_body.fcnn69, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle069, PRE_first_tail_x15_r0_body.fnk69, PRE_first_tail_x15_r0_body.ckA69, PRE_first_tail_x15_r0_body.cobjsK69, PRE_first_tail_x15_r0_body.cnodesK69, PRE_first_tail_x15_r0_body.citemsK69, PRE_first_tail_x15_r0_body.f1A69, PRE_first_tail_x15_r0_body.f1O69, PRE_first_tail_x15_r0_body.f1N69, PRE_first_tail_x15_r0_body.f1I69, PRE_first_tail_x15_r0_body.fbd69, PRE_first_tail_x15_r0_body.fincW69, PRE_first_tail_x15_r0_body.fincI69, PRE_first_tail_x15_r0_body.fincN69, PRE_first_tail_x15_r0_body.flnF69, PRE_first_tail_x15_r0_body.fh69, PRE_first_tail_x15_r0_body.fo69, PRE_first_tail_x15_r0_body.fok69, PRE_first_tail_x15_r0_body.fnd69, PRE_first_tail_x15_r0_body.fp69, PRE_first_tail_x15_r0_body.fnord69, PRE_first_tail_x15_r0_body.fi69, PRE_first_tail_x15_r0_body.fii69⟩
theorem PRE_first_tail_x15_r0_body.cnshift69 (clean : Conv.NClean (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P69.NL) (cl : SSt (· < 3048) PRE_first_tail_x15_r0_body.cx0_69.mlx) : NShift PRE_first_tail_x15_r0_body.P69 3048 PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.cx0_69 PRE_first_tail_x15_r0_body.cx1_69 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot69 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost69 (compact_a_eq PRE_first_tail_x15_r0_body.ckn069 PRE_first_tail_x15_r0_body.ckn169 PRE_first_tail_x15_r0_body.ckheap69 PRE_first_tail_x15_r0_body.ckpl69)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_69 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s617.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_69 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s617.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_69 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s617.ffi) = some PRE_first_tail_x15_r0_body.fxC_69
kernel_rfl PRE_first_tail_x15_r0_body.okrC_69 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s617.ffi) = some PRE_first_tail_x15_r0_body.krC_69
noncomputable def PRE_first_tail_x15_r0_body.fx0_69 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s619.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_69 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s619.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_69 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s619.ffi) = some PRE_first_tail_x15_r0_body.fx0_69
kernel_rfl PRE_first_tail_x15_r0_body.okr0_69 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s619.ffi) = some PRE_first_tail_x15_r0_body.kr0_69
noncomputable def PRE_first_tail_x15_r0_body.fx1_69 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s618.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_69 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s618.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_69 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s618.ffi) = some PRE_first_tail_x15_r0_body.fx1_69
kernel_rfl PRE_first_tail_x15_r0_body.okr1_69 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s618.ffi) = some PRE_first_tail_x15_r0_body.kr1_69
kernel_rfl PRE_first_tail_x15_r0_body.ff069 : PRE_first_tail_x15_r0_body.fx0_69 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_69 (PRE_first_tail_x15_r0_body.clo69.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_69.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff169 : PRE_first_tail_x15_r0_body.fx1_69 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_69 (PRE_first_tail_x15_r0_body.cwS69.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_69.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck69 : freedLB PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.cx0_69.mlx PRE_first_tail_x15_r0_body.fx0_69 PRE_first_tail_x15_r0_body.fx1_69 PRE_first_tail_x15_r0_body.clo69 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf069 : PRE_first_tail_x15_r0_body.kr0_69.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_69.flags (PRE_first_tail_x15_r0_body.clo69.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_69.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt069 : PRE_first_tail_x15_r0_body.kr0_69.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_69.targs (PRE_first_tail_x15_r0_body.clo69.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_69.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf169 : PRE_first_tail_x15_r0_body.kr1_69.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_69.flags (PRE_first_tail_x15_r0_body.cwS69.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_69.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt169 : PRE_first_tail_x15_r0_body.kr1_69.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_69.targs (PRE_first_tail_x15_r0_body.cwS69.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_69.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck69 : krecLB PRE_first_tail_x15_r0_body.kappa69 3048 PRE_first_tail_x15_r0_body.cx0_69.mlx PRE_first_tail_x15_r0_body.kr0_69 PRE_first_tail_x15_r0_body.kr1_69 PRE_first_tail_x15_r0_body.clo69 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn69 : Nat.ble 3039 3048 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge69 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s618.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s619.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR69 : pendRegB PRE_first_tail_x15_r0_body.kappa69 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe69 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s618.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift69 (clean : Conv.NClean (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P69.NL) (cl : SSt (· < 3048) PRE_first_tail_x15_r0_body.cx0_69.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_69.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_69.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_69.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_69.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P69 3048 PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.s619.ffi PRE_first_tail_x15_r0_body.s618.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift69 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue69, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp69 t ht),
    PRE_first_tail_x15_r0_body.cbridge69,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s619.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s618.ffi) (PRE_first_tail_x15_r0_body.cfoot69 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_69 PRE_first_tail_x15_r0_body.ofx1_69 hobjC PRE_first_tail_x15_r0_body.ff069 PRE_first_tail_x15_r0_body.ff169 PRE_first_tail_x15_r0_body.ffck69,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s619.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s618.ffi) (PRE_first_tail_x15_r0_body.cfoot69 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_69 PRE_first_tail_x15_r0_body.okr1_69 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn69) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf069 PRE_first_tail_x15_r0_body.fkt069 PRE_first_tail_x15_r0_body.fkf169 PRE_first_tail_x15_r0_body.fkt169 PRE_first_tail_x15_r0_body.fkck69,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh069 PRE_first_tail_x15_r0_body.cnh169 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe69) PRE_first_tail_x15_r0_body.cpendR69⟩

end Host.Load.Run.Tpl
