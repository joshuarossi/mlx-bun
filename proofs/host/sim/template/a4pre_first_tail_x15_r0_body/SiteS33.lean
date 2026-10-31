import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl33
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 33 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc33 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P33 : LoadP := PRE_first_tail_x15_r0_body.Pc33.raise 15956
kernel_rfl PRE_first_tail_x15_r0_body.craise33 : Nat.ble PRE_first_tail_x15_r0_body.Pc33.N0 15956 = true
theorem PRE_first_tail_x15_r0_body.raised33 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc33 PRE_first_tail_x15_r0_body.P33 :=
  .inr ⟨15956, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise33, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_33 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_33 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s303.ffi)
def PRE_first_tail_x15_r0_body.khinv33 : PTrie Nat := Stage.setAll PTrie.nil [(18867, 18865), (18868, 18866), (18870, 18867), (18869, 18868)]
def PRE_first_tail_x15_r0_body.kninv33 : PTrie Nat := Stage.setAll PTrie.nil [(15950, 15950), (15951, 15951), (15952, 15952), (15953, 15953), (15954, 15954), (15955, 15955)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS33 : List Nat := [18865, 18866, 18867, 18868, 18869, 18870]
def PRE_first_tail_x15_r0_body.cnS33 : List Nat := List.range' 15950 6
def PRE_first_tail_x15_r0_body.ciS33 : List Nat := [] ++ List.range' 15950 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh033 : PRE_first_tail_x15_r0_body.kd33.nh0 = PRE_first_tail_x15_r0_body.cx0_33.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh133 : PRE_first_tail_x15_r0_body.kd33.nh1 = PRE_first_tail_x15_r0_body.cx1_33.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn033 : PRE_first_tail_x15_r0_body.kd33.nn0 = PRE_first_tail_x15_r0_body.cx0_33.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn133 : PRE_first_tail_x15_r0_body.kd33.nn1 = PRE_first_tail_x15_r0_body.cx1_33.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo33 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P33.lo && Nat.ble PRE_first_tail_x15_r0_body.P33.lo PRE_first_tail_x15_r0_body.cx0_33.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P33.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P33.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt33 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_33.mlx.next PRE_first_tail_x15_r0_body.cx1_33.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_33.mlx.nnext PRE_first_tail_x15_r0_body.cx1_33.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband33 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P33.NL && Nat.ble PRE_first_tail_x15_r0_body.P33.NL PRE_first_tail_x15_r0_body.P33.N0 && Nat.ble PRE_first_tail_x15_r0_body.P33.N0 PRE_first_tail_x15_r0_body.cx0_33.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow33 : PRE_first_tail_x15_r0_body.kd33.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren33 : checkRenG PRE_first_tail_x15_r0_body.kd33.hnd PRE_first_tail_x15_r0_body.khinv33 (phB PRE_first_tail_x15_r0_body.cx0_33.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband33 : PRE_first_tail_x15_r0_body.kd33.checkBand PRE_first_tail_x15_r0_body.P33.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos33 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd33.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren33 : checkRenG PRE_first_tail_x15_r0_body.kd33.node PRE_first_tail_x15_r0_body.kninv33 (pnB PRE_first_tail_x15_r0_body.cx0_33.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow33 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd33.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P33.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd33.nodeF j) PRE_first_tail_x15_r0_body.cx1_33.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a33 : PRE_first_tail_x15_r0_body.cx0_33.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b33 : PRE_first_tail_x15_r0_body.cx0_33.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok133 : PRE_first_tail_x15_r0_body.cx1_33.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend33 : PRE_first_tail_x15_r0_body.cx1_33.mlx.pending = PRE_first_tail_x15_r0_body.cx0_33.mlx.pending.map PRE_first_tail_x15_r0_body.kappa33.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh33 : PRE_first_tail_x15_r0_body.cx1_33.mlx.errh = PRE_first_tail_x15_r0_body.cx0_33.mlx.errh.map PRE_first_tail_x15_r0_body.kappa33.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles33 : PRE_first_tail_x15_r0_body.cx1_33.mlx.files = PRE_first_tail_x15_r0_body.cx0_33.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch33 : PRE_first_tail_x15_r0_body.cx1_33.mlx.arch = PRE_first_tail_x15_r0_body.cx0_33.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes33 : PRE_first_tail_x15_r0_body.cx1_33.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_33.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired33 : PRE_first_tail_x15_r0_body.cx1_33.mlx.wired = PRE_first_tail_x15_r0_body.cx0_33.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost33 : PRE_first_tail_x15_r0_body.cx1_33.host = PRE_first_tail_x15_r0_body.cx0_33.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd33`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn033 : PRE_first_tail_x15_r0_body.kd33.n0 = 2701335
kernel_rfl PRE_first_tail_x15_r0_body.ckn133 : PRE_first_tail_x15_r0_body.kd33.n1 = 2701685
kernel_rfl PRE_first_tail_x15_r0_body.ckheap33 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd33.heap).all (fun x => Nat.ble 2701320 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl33 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd33.heap.get (2701320 + j) = nth? PRE_first_tail_x15_r0_body.pl33 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja33 : Nat.ble 2701320 2701320 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn33 : Nat.ble 1500 1500 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD33 : Nat.ble 2701320 PRE_first_tail_x15_r0_body.kd33.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn33 : Nat.ble 18865 PRE_first_tail_x15_r0_body.kd33.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn33 : Nat.ble 15950 PRE_first_tail_x15_r0_body.kd33.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb33 : Nat.ble 18865 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap33 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd33.heap).all (Nat.ble (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd33 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd33.hnd).all (Nat.ble (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode33 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd33.node).all (Nat.ble (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix33 : Conv.FixOld (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa33 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja33) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn33) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD33) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn33) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn33) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb33) PRE_first_tail_x15_r0_body.fheap33 PRE_first_tail_x15_r0_body.fhnd33 PRE_first_tail_x15_r0_body.fnode33
kernel_rfl PRE_first_tail_x15_r0_body.fcxn33 : (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn33 : (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle033 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_33.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_33.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk33 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd33.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A33 : PRE_first_tail_x15_r0_body.cx1_33.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS33.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_33.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O33 : PRE_first_tail_x15_r0_body.cx1_33.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS33.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_33.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N33 : PRE_first_tail_x15_r0_body.cx1_33.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS33.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_33.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I33 : PRE_first_tail_x15_r0_body.cx1_33.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS33.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_33.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd33 : (PRE_first_tail_x15_r0_body.clo33 ++ PRE_first_tail_x15_r0_body.cln33 ++ PRE_first_tail_x15_r0_body.cli33 ++ PRE_first_tail_x15_r0_body.cwS33 ++ PRE_first_tail_x15_r0_body.cnS33 ++ PRE_first_tail_x15_r0_body.ciS33).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW33 : PRE_first_tail_x15_r0_body.cwS33.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo33.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI33 : PRE_first_tail_x15_r0_body.ciS33.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli33.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN33 : PRE_first_tail_x15_r0_body.cnS33.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF33 : PRE_first_tail_x15_r0_body.cln33.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh33 : PRE_first_tail_x15_r0_body.clo33.all (handleOK PRE_first_tail_x15_r0_body.kappa33 PRE_first_tail_x15_r0_body.P33.lo PRE_first_tail_x15_r0_body.cx0_33.mlx PRE_first_tail_x15_r0_body.cx1_33.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo33 : PRE_first_tail_x15_r0_body.clo33.map (fun h => PRE_first_tail_x15_r0_body.cx1_33.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa33.handle h)) = PRE_first_tail_x15_r0_body.clo33.map (fun h => (PRE_first_tail_x15_r0_body.cx0_33.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa33.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok33 : PRE_first_tail_x15_r0_body.clo33.all (objOK PRE_first_tail_x15_r0_body.kappa33 PRE_first_tail_x15_r0_body.P33.NL PRE_first_tail_x15_r0_body.cx0_33.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd33 : PRE_first_tail_x15_r0_body.cln33.all (nodeOKF PRE_first_tail_x15_r0_body.kappa33 PRE_first_tail_x15_r0_body.P33 PRE_first_tail_x15_r0_body.cx0_33.mlx PRE_first_tail_x15_r0_body.cx1_33.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp33 : ((PRE_first_tail_x15_r0_body.cln33.filter (fullB PRE_first_tail_x15_r0_body.P33))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_33.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa33.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln33.filter (fullB PRE_first_tail_x15_r0_body.P33))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_33.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa33.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI33 : incrB PRE_first_tail_x15_r0_body.kd33.nodeF (List.range' 15950 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK33 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd33.node).all (fun k => Nat.ble 15950 k && Nat.blt k 15956) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL33 : (PRE_first_tail_x15_r0_body.cln33.filter (Nat.ble PRE_first_tail_x15_r0_body.P33.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd33.nodeF i) && (Nat.blt i 15956 || Nat.ble PRE_first_tail_x15_r0_body.kd33.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord33 : (PRE_first_tail_x15_r0_body.cln33.filter (Nat.ble PRE_first_tail_x15_r0_body.P33.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd33.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd33.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd33.nodeF j) (PRE_first_tail_x15_r0_body.kd33.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow33 PRE_first_tail_x15_r0_body.cnn133 PRE_first_tail_x15_r0_body.fnordI33 PRE_first_tail_x15_r0_body.fnordK33 PRE_first_tail_x15_r0_body.fnordL33
kernel_rfl PRE_first_tail_x15_r0_body.fi33 : PRE_first_tail_x15_r0_body.cli33.all (pnB PRE_first_tail_x15_r0_body.cx0_33.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii33 : PRE_first_tail_x15_r0_body.cli33.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_33.mlx.items.get (PRE_first_tail_x15_r0_body.kappa33.node k) = (PRE_first_tail_x15_r0_body.cx0_33.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa33.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot33 (clean : Conv.NClean (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P33.NL) (cl : SSt (· < 1509) PRE_first_tail_x15_r0_body.cx0_33.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P33 1509 PRE_first_tail_x15_r0_body.kappa33 PRE_first_tail_x15_r0_body.kd33 PRE_first_tail_x15_r0_body.khinv33 PRE_first_tail_x15_r0_body.kninv33 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx PRE_first_tail_x15_r0_body.cx0_33.mlx PRE_first_tail_x15_r0_body.cx1_33.mlx (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo33 PRE_first_tail_x15_r0_body.cln33 PRE_first_tail_x15_r0_body.cli33 PRE_first_tail_x15_r0_body.cwS33 PRE_first_tail_x15_r0_body.cnS33 PRE_first_tail_x15_r0_body.ciS33 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh033, PRE_first_tail_x15_r0_body.cnh133, PRE_first_tail_x15_r0_body.cnn033, PRE_first_tail_x15_r0_body.cnn133, PRE_first_tail_x15_r0_body.cplo33, PRE_first_tail_x15_r0_body.ccnt33, PRE_first_tail_x15_r0_body.cnband33, PRE_first_tail_x15_r0_body.chbelow33, PRE_first_tail_x15_r0_body.chren33, PRE_first_tail_x15_r0_body.cband33, PRE_first_tail_x15_r0_body.cnh1pos33, PRE_first_tail_x15_r0_body.cnren33, PRE_first_tail_x15_r0_body.cnlow33, PRE_first_tail_x15_r0_body.cabs0a33, PRE_first_tail_x15_r0_body.cabs0b33, PRE_first_tail_x15_r0_body.ctok133, PRE_first_tail_x15_r0_body.cpend33, PRE_first_tail_x15_r0_body.cerrh33, PRE_first_tail_x15_r0_body.cfiles33, PRE_first_tail_x15_r0_body.carch33, PRE_first_tail_x15_r0_body.csizes33, PRE_first_tail_x15_r0_body.cwired33, PRE_first_tail_x15_r0_body.cfix33, clean, PRE_first_tail_x15_r0_body.fcxn33, PRE_first_tail_x15_r0_body.fcnn33, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle033, PRE_first_tail_x15_r0_body.fnk33, PRE_first_tail_x15_r0_body.ckA33, PRE_first_tail_x15_r0_body.cobjsK33, PRE_first_tail_x15_r0_body.cnodesK33, PRE_first_tail_x15_r0_body.citemsK33, PRE_first_tail_x15_r0_body.f1A33, PRE_first_tail_x15_r0_body.f1O33, PRE_first_tail_x15_r0_body.f1N33, PRE_first_tail_x15_r0_body.f1I33, PRE_first_tail_x15_r0_body.fbd33, PRE_first_tail_x15_r0_body.fincW33, PRE_first_tail_x15_r0_body.fincI33, PRE_first_tail_x15_r0_body.fincN33, PRE_first_tail_x15_r0_body.flnF33, PRE_first_tail_x15_r0_body.fh33, PRE_first_tail_x15_r0_body.fo33, PRE_first_tail_x15_r0_body.fok33, PRE_first_tail_x15_r0_body.fnd33, PRE_first_tail_x15_r0_body.fp33, PRE_first_tail_x15_r0_body.fnord33, PRE_first_tail_x15_r0_body.fi33, PRE_first_tail_x15_r0_body.fii33⟩
theorem PRE_first_tail_x15_r0_body.cnshift33 (clean : Conv.NClean (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P33.NL) (cl : SSt (· < 1509) PRE_first_tail_x15_r0_body.cx0_33.mlx) : NShift PRE_first_tail_x15_r0_body.P33 1509 PRE_first_tail_x15_r0_body.kappa33 PRE_first_tail_x15_r0_body.cx0_33 PRE_first_tail_x15_r0_body.cx1_33 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot33 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost33 (compact_a_eq PRE_first_tail_x15_r0_body.ckn033 PRE_first_tail_x15_r0_body.ckn133 PRE_first_tail_x15_r0_body.ckheap33 PRE_first_tail_x15_r0_body.ckpl33)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_33 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s302.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_33 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s302.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_33 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s302.ffi) = some PRE_first_tail_x15_r0_body.fxC_33
kernel_rfl PRE_first_tail_x15_r0_body.okrC_33 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s302.ffi) = some PRE_first_tail_x15_r0_body.krC_33
noncomputable def PRE_first_tail_x15_r0_body.fx0_33 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s304.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_33 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s304.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_33 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s304.ffi) = some PRE_first_tail_x15_r0_body.fx0_33
kernel_rfl PRE_first_tail_x15_r0_body.okr0_33 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s304.ffi) = some PRE_first_tail_x15_r0_body.kr0_33
noncomputable def PRE_first_tail_x15_r0_body.fx1_33 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s303.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_33 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s303.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_33 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s303.ffi) = some PRE_first_tail_x15_r0_body.fx1_33
kernel_rfl PRE_first_tail_x15_r0_body.okr1_33 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s303.ffi) = some PRE_first_tail_x15_r0_body.kr1_33
kernel_rfl PRE_first_tail_x15_r0_body.ff033 : PRE_first_tail_x15_r0_body.fx0_33 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_33 (PRE_first_tail_x15_r0_body.clo33.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_33.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff133 : PRE_first_tail_x15_r0_body.fx1_33 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_33 (PRE_first_tail_x15_r0_body.cwS33.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_33.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck33 : freedLB PRE_first_tail_x15_r0_body.kappa33 PRE_first_tail_x15_r0_body.cx0_33.mlx PRE_first_tail_x15_r0_body.fx0_33 PRE_first_tail_x15_r0_body.fx1_33 PRE_first_tail_x15_r0_body.clo33 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf033 : PRE_first_tail_x15_r0_body.kr0_33.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_33.flags (PRE_first_tail_x15_r0_body.clo33.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_33.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt033 : PRE_first_tail_x15_r0_body.kr0_33.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_33.targs (PRE_first_tail_x15_r0_body.clo33.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_33.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf133 : PRE_first_tail_x15_r0_body.kr1_33.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_33.flags (PRE_first_tail_x15_r0_body.cwS33.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_33.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt133 : PRE_first_tail_x15_r0_body.kr1_33.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_33.targs (PRE_first_tail_x15_r0_body.cwS33.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_33.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck33 : krecLB PRE_first_tail_x15_r0_body.kappa33 1509 PRE_first_tail_x15_r0_body.cx0_33.mlx PRE_first_tail_x15_r0_body.kr0_33 PRE_first_tail_x15_r0_body.kr1_33 PRE_first_tail_x15_r0_body.clo33 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn33 : Nat.ble 1500 1509 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge33 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s303.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s304.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR33 : pendRegB PRE_first_tail_x15_r0_body.kappa33 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe33 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s303.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift33 (clean : Conv.NClean (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P33.NL) (cl : SSt (· < 1509) PRE_first_tail_x15_r0_body.cx0_33.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_33.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_33.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_33.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_33.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P33 1509 PRE_first_tail_x15_r0_body.kappa33 PRE_first_tail_x15_r0_body.s304.ffi PRE_first_tail_x15_r0_body.s303.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift33 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue33, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp33 t ht),
    PRE_first_tail_x15_r0_body.cbridge33,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s304.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s303.ffi) (PRE_first_tail_x15_r0_body.cfoot33 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_33 PRE_first_tail_x15_r0_body.ofx1_33 hobjC PRE_first_tail_x15_r0_body.ff033 PRE_first_tail_x15_r0_body.ff133 PRE_first_tail_x15_r0_body.ffck33,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s304.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s303.ffi) (PRE_first_tail_x15_r0_body.cfoot33 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_33 PRE_first_tail_x15_r0_body.okr1_33 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn33) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf033 PRE_first_tail_x15_r0_body.fkt033 PRE_first_tail_x15_r0_body.fkf133 PRE_first_tail_x15_r0_body.fkt133 PRE_first_tail_x15_r0_body.fkck33,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh033 PRE_first_tail_x15_r0_body.cnh133 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe33) PRE_first_tail_x15_r0_body.cpendR33⟩

end Host.Load.Run.Tpl
