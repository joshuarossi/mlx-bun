import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl96
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 96 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc96 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P96 : LoadP := PRE_first_tail_x15_r0_body.Pc96.raise 17201
kernel_rfl PRE_first_tail_x15_r0_body.craise96 : Nat.ble PRE_first_tail_x15_r0_body.Pc96.N0 17201 = true
theorem PRE_first_tail_x15_r0_body.raised96 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc96 PRE_first_tail_x15_r0_body.P96 :=
  .inr ⟨17201, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise96, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_96 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s938.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_96 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s937.ffi)
def PRE_first_tail_x15_r0_body.khinv96 : PTrie Nat := Stage.setAll PTrie.nil [(20130, 20104), (20108, 20105), (20131, 20106)]
def PRE_first_tail_x15_r0_body.kninv96 : PTrie Nat := Stage.setAll PTrie.nil [(17174, 17174), (17175, 17175), (17176, 17176), (17177, 17177), (17178, 17178), (17179, 17179), (17180, 17180), (17181, 17181), (17182, 17182), (17183, 17183), (17184, 17184), (17185, 17185), (17186, 17186), (17187, 17187), (17188, 17188), (17189, 17189), (17190, 17190), (17191, 17191), (17192, 17192), (17193, 17193), (17194, 17194), (17195, 17195), (17196, 17196), (17197, 17197), (17198, 17198), (17199, 17199), (17200, 17200)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS96 : List Nat := [20084, 20097, 20103, 20104, 20105, 20106, 20107, 20108, 20109, 20110, 20111, 20112, 20113, 20114, 20115, 20116, 20117, 20118, 20119, 20120, 20121, 20122, 20123, 20124, 20125, 20126, 20127, 20128, 20129, 20130, 20131]
def PRE_first_tail_x15_r0_body.cnS96 : List Nat := List.range' 17174 27
def PRE_first_tail_x15_r0_body.ciS96 : List Nat := [] ++ List.range' 17174 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh096 : PRE_first_tail_x15_r0_body.kd96.nh0 = PRE_first_tail_x15_r0_body.cx0_96.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh196 : PRE_first_tail_x15_r0_body.kd96.nh1 = PRE_first_tail_x15_r0_body.cx1_96.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn096 : PRE_first_tail_x15_r0_body.kd96.nn0 = PRE_first_tail_x15_r0_body.cx0_96.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn196 : PRE_first_tail_x15_r0_body.kd96.nn1 = PRE_first_tail_x15_r0_body.cx1_96.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo96 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P96.lo && Nat.ble PRE_first_tail_x15_r0_body.P96.lo PRE_first_tail_x15_r0_body.cx0_96.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P96.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P96.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt96 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_96.mlx.next PRE_first_tail_x15_r0_body.cx1_96.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_96.mlx.nnext PRE_first_tail_x15_r0_body.cx1_96.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband96 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P96.NL && Nat.ble PRE_first_tail_x15_r0_body.P96.NL PRE_first_tail_x15_r0_body.P96.N0 && Nat.ble PRE_first_tail_x15_r0_body.P96.N0 PRE_first_tail_x15_r0_body.cx0_96.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow96 : PRE_first_tail_x15_r0_body.kd96.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren96 : checkRenG PRE_first_tail_x15_r0_body.kd96.hnd PRE_first_tail_x15_r0_body.khinv96 (phB PRE_first_tail_x15_r0_body.cx0_96.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband96 : PRE_first_tail_x15_r0_body.kd96.checkBand PRE_first_tail_x15_r0_body.P96.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos96 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd96.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren96 : checkRenG PRE_first_tail_x15_r0_body.kd96.node PRE_first_tail_x15_r0_body.kninv96 (pnB PRE_first_tail_x15_r0_body.cx0_96.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow96 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd96.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P96.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd96.nodeF j) PRE_first_tail_x15_r0_body.cx1_96.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a96 : PRE_first_tail_x15_r0_body.cx0_96.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b96 : PRE_first_tail_x15_r0_body.cx0_96.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok196 : PRE_first_tail_x15_r0_body.cx1_96.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend96 : PRE_first_tail_x15_r0_body.cx1_96.mlx.pending = PRE_first_tail_x15_r0_body.cx0_96.mlx.pending.map PRE_first_tail_x15_r0_body.kappa96.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh96 : PRE_first_tail_x15_r0_body.cx1_96.mlx.errh = PRE_first_tail_x15_r0_body.cx0_96.mlx.errh.map PRE_first_tail_x15_r0_body.kappa96.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles96 : PRE_first_tail_x15_r0_body.cx1_96.mlx.files = PRE_first_tail_x15_r0_body.cx0_96.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch96 : PRE_first_tail_x15_r0_body.cx1_96.mlx.arch = PRE_first_tail_x15_r0_body.cx0_96.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes96 : PRE_first_tail_x15_r0_body.cx1_96.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_96.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired96 : PRE_first_tail_x15_r0_body.cx1_96.mlx.wired = PRE_first_tail_x15_r0_body.cx0_96.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost96 : PRE_first_tail_x15_r0_body.cx1_96.host = PRE_first_tail_x15_r0_body.cx0_96.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd96`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn096 : PRE_first_tail_x15_r0_body.kd96.n0 = 2750797
kernel_rfl PRE_first_tail_x15_r0_body.ckn196 : PRE_first_tail_x15_r0_body.kd96.n1 = 2751946
kernel_rfl PRE_first_tail_x15_r0_body.ckheap96 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd96.heap).all (fun x => Nat.ble 2750791 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl96 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd96.heap.get (2750791 + j) = nth? PRE_first_tail_x15_r0_body.pl96 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja96 : Nat.ble 2750791 2750791 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn96 : Nat.ble 4187 4187 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD96 : Nat.ble 2750791 PRE_first_tail_x15_r0_body.kd96.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn96 : Nat.ble 20104 PRE_first_tail_x15_r0_body.kd96.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn96 : Nat.ble 17174 PRE_first_tail_x15_r0_body.kd96.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb96 : Nat.ble 20104 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap96 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd96.heap).all (Nat.ble (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd96 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd96.hnd).all (Nat.ble (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode96 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd96.node).all (Nat.ble (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix96 : Conv.FixOld (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa96 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja96) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn96) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD96) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn96) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn96) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb96) PRE_first_tail_x15_r0_body.fheap96 PRE_first_tail_x15_r0_body.fhnd96 PRE_first_tail_x15_r0_body.fnode96
kernel_rfl PRE_first_tail_x15_r0_body.fcxn96 : (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn96 : (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle096 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_96.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_96.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk96 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd96.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A96 : PRE_first_tail_x15_r0_body.cx1_96.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS96.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_96.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O96 : PRE_first_tail_x15_r0_body.cx1_96.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS96.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_96.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N96 : PRE_first_tail_x15_r0_body.cx1_96.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS96.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_96.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I96 : PRE_first_tail_x15_r0_body.cx1_96.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS96.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_96.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd96 : (PRE_first_tail_x15_r0_body.clo96 ++ PRE_first_tail_x15_r0_body.cln96 ++ PRE_first_tail_x15_r0_body.cli96 ++ PRE_first_tail_x15_r0_body.cwS96 ++ PRE_first_tail_x15_r0_body.cnS96 ++ PRE_first_tail_x15_r0_body.ciS96).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW96 : PRE_first_tail_x15_r0_body.cwS96.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo96.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI96 : PRE_first_tail_x15_r0_body.ciS96.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli96.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN96 : PRE_first_tail_x15_r0_body.cnS96.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF96 : PRE_first_tail_x15_r0_body.cln96.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh96 : PRE_first_tail_x15_r0_body.clo96.all (handleOK PRE_first_tail_x15_r0_body.kappa96 PRE_first_tail_x15_r0_body.P96.lo PRE_first_tail_x15_r0_body.cx0_96.mlx PRE_first_tail_x15_r0_body.cx1_96.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo96 : PRE_first_tail_x15_r0_body.clo96.map (fun h => PRE_first_tail_x15_r0_body.cx1_96.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa96.handle h)) = PRE_first_tail_x15_r0_body.clo96.map (fun h => (PRE_first_tail_x15_r0_body.cx0_96.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa96.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok96 : PRE_first_tail_x15_r0_body.clo96.all (objOK PRE_first_tail_x15_r0_body.kappa96 PRE_first_tail_x15_r0_body.P96.NL PRE_first_tail_x15_r0_body.cx0_96.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd96 : PRE_first_tail_x15_r0_body.cln96.all (nodeOKF PRE_first_tail_x15_r0_body.kappa96 PRE_first_tail_x15_r0_body.P96 PRE_first_tail_x15_r0_body.cx0_96.mlx PRE_first_tail_x15_r0_body.cx1_96.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp96 : ((PRE_first_tail_x15_r0_body.cln96.filter (fullB PRE_first_tail_x15_r0_body.P96))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_96.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa96.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln96.filter (fullB PRE_first_tail_x15_r0_body.P96))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_96.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa96.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI96 : incrB PRE_first_tail_x15_r0_body.kd96.nodeF (List.range' 17174 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK96 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd96.node).all (fun k => Nat.ble 17174 k && Nat.blt k 17201) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL96 : (PRE_first_tail_x15_r0_body.cln96.filter (Nat.ble PRE_first_tail_x15_r0_body.P96.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd96.nodeF i) && (Nat.blt i 17201 || Nat.ble PRE_first_tail_x15_r0_body.kd96.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord96 : (PRE_first_tail_x15_r0_body.cln96.filter (Nat.ble PRE_first_tail_x15_r0_body.P96.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd96.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd96.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd96.nodeF j) (PRE_first_tail_x15_r0_body.kd96.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow96 PRE_first_tail_x15_r0_body.cnn196 PRE_first_tail_x15_r0_body.fnordI96 PRE_first_tail_x15_r0_body.fnordK96 PRE_first_tail_x15_r0_body.fnordL96
kernel_rfl PRE_first_tail_x15_r0_body.fi96 : PRE_first_tail_x15_r0_body.cli96.all (pnB PRE_first_tail_x15_r0_body.cx0_96.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii96 : PRE_first_tail_x15_r0_body.cli96.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_96.mlx.items.get (PRE_first_tail_x15_r0_body.kappa96.node k) = (PRE_first_tail_x15_r0_body.cx0_96.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa96.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot96 (clean : Conv.NClean (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P96.NL) (cl : SSt (· < 4205) PRE_first_tail_x15_r0_body.cx0_96.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P96 4205 PRE_first_tail_x15_r0_body.kappa96 PRE_first_tail_x15_r0_body.kd96 PRE_first_tail_x15_r0_body.khinv96 PRE_first_tail_x15_r0_body.kninv96 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx PRE_first_tail_x15_r0_body.cx0_96.mlx PRE_first_tail_x15_r0_body.cx1_96.mlx (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo96 PRE_first_tail_x15_r0_body.cln96 PRE_first_tail_x15_r0_body.cli96 PRE_first_tail_x15_r0_body.cwS96 PRE_first_tail_x15_r0_body.cnS96 PRE_first_tail_x15_r0_body.ciS96 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh096, PRE_first_tail_x15_r0_body.cnh196, PRE_first_tail_x15_r0_body.cnn096, PRE_first_tail_x15_r0_body.cnn196, PRE_first_tail_x15_r0_body.cplo96, PRE_first_tail_x15_r0_body.ccnt96, PRE_first_tail_x15_r0_body.cnband96, PRE_first_tail_x15_r0_body.chbelow96, PRE_first_tail_x15_r0_body.chren96, PRE_first_tail_x15_r0_body.cband96, PRE_first_tail_x15_r0_body.cnh1pos96, PRE_first_tail_x15_r0_body.cnren96, PRE_first_tail_x15_r0_body.cnlow96, PRE_first_tail_x15_r0_body.cabs0a96, PRE_first_tail_x15_r0_body.cabs0b96, PRE_first_tail_x15_r0_body.ctok196, PRE_first_tail_x15_r0_body.cpend96, PRE_first_tail_x15_r0_body.cerrh96, PRE_first_tail_x15_r0_body.cfiles96, PRE_first_tail_x15_r0_body.carch96, PRE_first_tail_x15_r0_body.csizes96, PRE_first_tail_x15_r0_body.cwired96, PRE_first_tail_x15_r0_body.cfix96, clean, PRE_first_tail_x15_r0_body.fcxn96, PRE_first_tail_x15_r0_body.fcnn96, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle096, PRE_first_tail_x15_r0_body.fnk96, PRE_first_tail_x15_r0_body.ckA96, PRE_first_tail_x15_r0_body.cobjsK96, PRE_first_tail_x15_r0_body.cnodesK96, PRE_first_tail_x15_r0_body.citemsK96, PRE_first_tail_x15_r0_body.f1A96, PRE_first_tail_x15_r0_body.f1O96, PRE_first_tail_x15_r0_body.f1N96, PRE_first_tail_x15_r0_body.f1I96, PRE_first_tail_x15_r0_body.fbd96, PRE_first_tail_x15_r0_body.fincW96, PRE_first_tail_x15_r0_body.fincI96, PRE_first_tail_x15_r0_body.fincN96, PRE_first_tail_x15_r0_body.flnF96, PRE_first_tail_x15_r0_body.fh96, PRE_first_tail_x15_r0_body.fo96, PRE_first_tail_x15_r0_body.fok96, PRE_first_tail_x15_r0_body.fnd96, PRE_first_tail_x15_r0_body.fp96, PRE_first_tail_x15_r0_body.fnord96, PRE_first_tail_x15_r0_body.fi96, PRE_first_tail_x15_r0_body.fii96⟩
theorem PRE_first_tail_x15_r0_body.cnshift96 (clean : Conv.NClean (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P96.NL) (cl : SSt (· < 4205) PRE_first_tail_x15_r0_body.cx0_96.mlx) : NShift PRE_first_tail_x15_r0_body.P96 4205 PRE_first_tail_x15_r0_body.kappa96 PRE_first_tail_x15_r0_body.cx0_96 PRE_first_tail_x15_r0_body.cx1_96 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot96 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost96 (compact_a_eq PRE_first_tail_x15_r0_body.ckn096 PRE_first_tail_x15_r0_body.ckn196 PRE_first_tail_x15_r0_body.ckheap96 PRE_first_tail_x15_r0_body.ckpl96)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_96 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s936.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_96 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s936.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_96 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s936.ffi) = some PRE_first_tail_x15_r0_body.fxC_96
kernel_rfl PRE_first_tail_x15_r0_body.okrC_96 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s936.ffi) = some PRE_first_tail_x15_r0_body.krC_96
noncomputable def PRE_first_tail_x15_r0_body.fx0_96 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s938.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_96 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s938.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_96 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s938.ffi) = some PRE_first_tail_x15_r0_body.fx0_96
kernel_rfl PRE_first_tail_x15_r0_body.okr0_96 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s938.ffi) = some PRE_first_tail_x15_r0_body.kr0_96
noncomputable def PRE_first_tail_x15_r0_body.fx1_96 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s937.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_96 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s937.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_96 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s937.ffi) = some PRE_first_tail_x15_r0_body.fx1_96
kernel_rfl PRE_first_tail_x15_r0_body.okr1_96 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s937.ffi) = some PRE_first_tail_x15_r0_body.kr1_96
kernel_rfl PRE_first_tail_x15_r0_body.ff096 : PRE_first_tail_x15_r0_body.fx0_96 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_96 (PRE_first_tail_x15_r0_body.clo96.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_96.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff196 : PRE_first_tail_x15_r0_body.fx1_96 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_96 (PRE_first_tail_x15_r0_body.cwS96.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_96.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck96 : freedLB PRE_first_tail_x15_r0_body.kappa96 PRE_first_tail_x15_r0_body.cx0_96.mlx PRE_first_tail_x15_r0_body.fx0_96 PRE_first_tail_x15_r0_body.fx1_96 PRE_first_tail_x15_r0_body.clo96 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf096 : PRE_first_tail_x15_r0_body.kr0_96.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_96.flags (PRE_first_tail_x15_r0_body.clo96.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_96.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt096 : PRE_first_tail_x15_r0_body.kr0_96.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_96.targs (PRE_first_tail_x15_r0_body.clo96.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_96.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf196 : PRE_first_tail_x15_r0_body.kr1_96.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_96.flags (PRE_first_tail_x15_r0_body.cwS96.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_96.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt196 : PRE_first_tail_x15_r0_body.kr1_96.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_96.targs (PRE_first_tail_x15_r0_body.cwS96.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_96.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck96 : krecLB PRE_first_tail_x15_r0_body.kappa96 4205 PRE_first_tail_x15_r0_body.cx0_96.mlx PRE_first_tail_x15_r0_body.kr0_96 PRE_first_tail_x15_r0_body.kr1_96 PRE_first_tail_x15_r0_body.clo96 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn96 : Nat.ble 4187 4205 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge96 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s937.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s938.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR96 : pendRegB PRE_first_tail_x15_r0_body.kappa96 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s938.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe96 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s938.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s937.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift96 (clean : Conv.NClean (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P96.NL) (cl : SSt (· < 4205) PRE_first_tail_x15_r0_body.cx0_96.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_96.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_96.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_96.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s936.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_96.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P96 4205 PRE_first_tail_x15_r0_body.kappa96 PRE_first_tail_x15_r0_body.s938.ffi PRE_first_tail_x15_r0_body.s937.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift96 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue96, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp96 t ht),
    PRE_first_tail_x15_r0_body.cbridge96,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s938.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s937.ffi) (PRE_first_tail_x15_r0_body.cfoot96 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_96 PRE_first_tail_x15_r0_body.ofx1_96 hobjC PRE_first_tail_x15_r0_body.ff096 PRE_first_tail_x15_r0_body.ff196 PRE_first_tail_x15_r0_body.ffck96,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s938.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s937.ffi) (PRE_first_tail_x15_r0_body.cfoot96 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_96 PRE_first_tail_x15_r0_body.okr1_96 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn96) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf096 PRE_first_tail_x15_r0_body.fkt096 PRE_first_tail_x15_r0_body.fkf196 PRE_first_tail_x15_r0_body.fkt196 PRE_first_tail_x15_r0_body.fkck96,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh096 PRE_first_tail_x15_r0_body.cnh196 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe96) PRE_first_tail_x15_r0_body.cpendR96⟩

end Host.Load.Run.Tpl
