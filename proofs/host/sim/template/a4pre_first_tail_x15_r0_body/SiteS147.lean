import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl147
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 147 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc147 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P147 : LoadP := PRE_first_tail_x15_r0_body.Pc147.raise 18212
kernel_rfl PRE_first_tail_x15_r0_body.craise147 : Nat.ble PRE_first_tail_x15_r0_body.Pc147.N0 18212 = true
theorem PRE_first_tail_x15_r0_body.raised147 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc147 PRE_first_tail_x15_r0_body.P147 :=
  .inr ⟨18212, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise147, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_147 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_147 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1426.ffi)
def PRE_first_tail_x15_r0_body.khinv147 : PTrie Nat := Stage.setAll PTrie.nil [(21131, 21105), (21109, 21106), (21132, 21107)]
def PRE_first_tail_x15_r0_body.kninv147 : PTrie Nat := Stage.setAll PTrie.nil [(18185, 18185), (18186, 18186), (18187, 18187), (18188, 18188), (18189, 18189), (18190, 18190), (18191, 18191), (18192, 18192), (18193, 18193), (18194, 18194), (18195, 18195), (18196, 18196), (18197, 18197), (18198, 18198), (18199, 18199), (18200, 18200), (18201, 18201), (18202, 18202), (18203, 18203), (18204, 18204), (18205, 18205), (18206, 18206), (18207, 18207), (18208, 18208), (18209, 18209), (18210, 18210), (18211, 18211)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS147 : List Nat := [21085, 21098, 21104, 21105, 21106, 21107, 21108, 21109, 21110, 21111, 21112, 21113, 21114, 21115, 21116, 21117, 21118, 21119, 21120, 21121, 21122, 21123, 21124, 21125, 21126, 21127, 21128, 21129, 21130, 21131, 21132]
def PRE_first_tail_x15_r0_body.cnS147 : List Nat := List.range' 18185 27
def PRE_first_tail_x15_r0_body.ciS147 : List Nat := [] ++ List.range' 18185 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0147 : PRE_first_tail_x15_r0_body.kd147.nh0 = PRE_first_tail_x15_r0_body.cx0_147.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1147 : PRE_first_tail_x15_r0_body.kd147.nh1 = PRE_first_tail_x15_r0_body.cx1_147.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0147 : PRE_first_tail_x15_r0_body.kd147.nn0 = PRE_first_tail_x15_r0_body.cx0_147.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1147 : PRE_first_tail_x15_r0_body.kd147.nn1 = PRE_first_tail_x15_r0_body.cx1_147.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo147 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P147.lo && Nat.ble PRE_first_tail_x15_r0_body.P147.lo PRE_first_tail_x15_r0_body.cx0_147.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P147.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P147.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt147 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_147.mlx.next PRE_first_tail_x15_r0_body.cx1_147.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_147.mlx.nnext PRE_first_tail_x15_r0_body.cx1_147.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband147 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P147.NL && Nat.ble PRE_first_tail_x15_r0_body.P147.NL PRE_first_tail_x15_r0_body.P147.N0 && Nat.ble PRE_first_tail_x15_r0_body.P147.N0 PRE_first_tail_x15_r0_body.cx0_147.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow147 : PRE_first_tail_x15_r0_body.kd147.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren147 : checkRenG PRE_first_tail_x15_r0_body.kd147.hnd PRE_first_tail_x15_r0_body.khinv147 (phB PRE_first_tail_x15_r0_body.cx0_147.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband147 : PRE_first_tail_x15_r0_body.kd147.checkBand PRE_first_tail_x15_r0_body.P147.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos147 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd147.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren147 : checkRenG PRE_first_tail_x15_r0_body.kd147.node PRE_first_tail_x15_r0_body.kninv147 (pnB PRE_first_tail_x15_r0_body.cx0_147.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow147 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd147.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P147.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd147.nodeF j) PRE_first_tail_x15_r0_body.cx1_147.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a147 : PRE_first_tail_x15_r0_body.cx0_147.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b147 : PRE_first_tail_x15_r0_body.cx0_147.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1147 : PRE_first_tail_x15_r0_body.cx1_147.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend147 : PRE_first_tail_x15_r0_body.cx1_147.mlx.pending = PRE_first_tail_x15_r0_body.cx0_147.mlx.pending.map PRE_first_tail_x15_r0_body.kappa147.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh147 : PRE_first_tail_x15_r0_body.cx1_147.mlx.errh = PRE_first_tail_x15_r0_body.cx0_147.mlx.errh.map PRE_first_tail_x15_r0_body.kappa147.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles147 : PRE_first_tail_x15_r0_body.cx1_147.mlx.files = PRE_first_tail_x15_r0_body.cx0_147.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch147 : PRE_first_tail_x15_r0_body.cx1_147.mlx.arch = PRE_first_tail_x15_r0_body.cx0_147.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes147 : PRE_first_tail_x15_r0_body.cx1_147.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_147.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired147 : PRE_first_tail_x15_r0_body.cx1_147.mlx.wired = PRE_first_tail_x15_r0_body.cx0_147.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost147 : PRE_first_tail_x15_r0_body.cx1_147.host = PRE_first_tail_x15_r0_body.cx0_147.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd147`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0147 : PRE_first_tail_x15_r0_body.kd147.n0 = 2790725
kernel_rfl PRE_first_tail_x15_r0_body.ckn1147 : PRE_first_tail_x15_r0_body.kd147.n1 = 2791874
kernel_rfl PRE_first_tail_x15_r0_body.ckheap147 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd147.heap).all (fun x => Nat.ble 2790719 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl147 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd147.heap.get (2790719 + j) = nth? PRE_first_tail_x15_r0_body.pl147 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja147 : Nat.ble 2790719 2790719 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn147 : Nat.ble 6368 6368 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD147 : Nat.ble 2790719 PRE_first_tail_x15_r0_body.kd147.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn147 : Nat.ble 21105 PRE_first_tail_x15_r0_body.kd147.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn147 : Nat.ble 18185 PRE_first_tail_x15_r0_body.kd147.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb147 : Nat.ble 21105 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap147 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd147.heap).all (Nat.ble (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd147 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd147.hnd).all (Nat.ble (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode147 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd147.node).all (Nat.ble (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix147 : Conv.FixOld (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa147 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja147) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn147) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD147) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn147) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn147) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb147) PRE_first_tail_x15_r0_body.fheap147 PRE_first_tail_x15_r0_body.fhnd147 PRE_first_tail_x15_r0_body.fnode147
kernel_rfl PRE_first_tail_x15_r0_body.fcxn147 : (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn147 : (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0147 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_147.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_147.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk147 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd147.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A147 : PRE_first_tail_x15_r0_body.cx1_147.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS147.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_147.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O147 : PRE_first_tail_x15_r0_body.cx1_147.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS147.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_147.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N147 : PRE_first_tail_x15_r0_body.cx1_147.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS147.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_147.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I147 : PRE_first_tail_x15_r0_body.cx1_147.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS147.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_147.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd147 : (PRE_first_tail_x15_r0_body.clo147 ++ PRE_first_tail_x15_r0_body.cln147 ++ PRE_first_tail_x15_r0_body.cli147 ++ PRE_first_tail_x15_r0_body.cwS147 ++ PRE_first_tail_x15_r0_body.cnS147 ++ PRE_first_tail_x15_r0_body.ciS147).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW147 : PRE_first_tail_x15_r0_body.cwS147.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo147.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI147 : PRE_first_tail_x15_r0_body.ciS147.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli147.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN147 : PRE_first_tail_x15_r0_body.cnS147.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF147 : PRE_first_tail_x15_r0_body.cln147.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh147 : PRE_first_tail_x15_r0_body.clo147.all (handleOK PRE_first_tail_x15_r0_body.kappa147 PRE_first_tail_x15_r0_body.P147.lo PRE_first_tail_x15_r0_body.cx0_147.mlx PRE_first_tail_x15_r0_body.cx1_147.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo147 : PRE_first_tail_x15_r0_body.clo147.map (fun h => PRE_first_tail_x15_r0_body.cx1_147.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa147.handle h)) = PRE_first_tail_x15_r0_body.clo147.map (fun h => (PRE_first_tail_x15_r0_body.cx0_147.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa147.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok147 : PRE_first_tail_x15_r0_body.clo147.all (objOK PRE_first_tail_x15_r0_body.kappa147 PRE_first_tail_x15_r0_body.P147.NL PRE_first_tail_x15_r0_body.cx0_147.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd147 : PRE_first_tail_x15_r0_body.cln147.all (nodeOKF PRE_first_tail_x15_r0_body.kappa147 PRE_first_tail_x15_r0_body.P147 PRE_first_tail_x15_r0_body.cx0_147.mlx PRE_first_tail_x15_r0_body.cx1_147.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp147 : ((PRE_first_tail_x15_r0_body.cln147.filter (fullB PRE_first_tail_x15_r0_body.P147))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_147.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa147.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln147.filter (fullB PRE_first_tail_x15_r0_body.P147))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_147.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa147.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI147 : incrB PRE_first_tail_x15_r0_body.kd147.nodeF (List.range' 18185 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK147 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd147.node).all (fun k => Nat.ble 18185 k && Nat.blt k 18212) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL147 : (PRE_first_tail_x15_r0_body.cln147.filter (Nat.ble PRE_first_tail_x15_r0_body.P147.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd147.nodeF i) && (Nat.blt i 18212 || Nat.ble PRE_first_tail_x15_r0_body.kd147.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord147 : (PRE_first_tail_x15_r0_body.cln147.filter (Nat.ble PRE_first_tail_x15_r0_body.P147.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd147.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd147.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd147.nodeF j) (PRE_first_tail_x15_r0_body.kd147.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow147 PRE_first_tail_x15_r0_body.cnn1147 PRE_first_tail_x15_r0_body.fnordI147 PRE_first_tail_x15_r0_body.fnordK147 PRE_first_tail_x15_r0_body.fnordL147
kernel_rfl PRE_first_tail_x15_r0_body.fi147 : PRE_first_tail_x15_r0_body.cli147.all (pnB PRE_first_tail_x15_r0_body.cx0_147.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii147 : PRE_first_tail_x15_r0_body.cli147.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_147.mlx.items.get (PRE_first_tail_x15_r0_body.kappa147.node k) = (PRE_first_tail_x15_r0_body.cx0_147.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa147.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot147 (clean : Conv.NClean (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P147.NL) (cl : SSt (· < 6386) PRE_first_tail_x15_r0_body.cx0_147.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P147 6386 PRE_first_tail_x15_r0_body.kappa147 PRE_first_tail_x15_r0_body.kd147 PRE_first_tail_x15_r0_body.khinv147 PRE_first_tail_x15_r0_body.kninv147 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx PRE_first_tail_x15_r0_body.cx0_147.mlx PRE_first_tail_x15_r0_body.cx1_147.mlx (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo147 PRE_first_tail_x15_r0_body.cln147 PRE_first_tail_x15_r0_body.cli147 PRE_first_tail_x15_r0_body.cwS147 PRE_first_tail_x15_r0_body.cnS147 PRE_first_tail_x15_r0_body.ciS147 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0147, PRE_first_tail_x15_r0_body.cnh1147, PRE_first_tail_x15_r0_body.cnn0147, PRE_first_tail_x15_r0_body.cnn1147, PRE_first_tail_x15_r0_body.cplo147, PRE_first_tail_x15_r0_body.ccnt147, PRE_first_tail_x15_r0_body.cnband147, PRE_first_tail_x15_r0_body.chbelow147, PRE_first_tail_x15_r0_body.chren147, PRE_first_tail_x15_r0_body.cband147, PRE_first_tail_x15_r0_body.cnh1pos147, PRE_first_tail_x15_r0_body.cnren147, PRE_first_tail_x15_r0_body.cnlow147, PRE_first_tail_x15_r0_body.cabs0a147, PRE_first_tail_x15_r0_body.cabs0b147, PRE_first_tail_x15_r0_body.ctok1147, PRE_first_tail_x15_r0_body.cpend147, PRE_first_tail_x15_r0_body.cerrh147, PRE_first_tail_x15_r0_body.cfiles147, PRE_first_tail_x15_r0_body.carch147, PRE_first_tail_x15_r0_body.csizes147, PRE_first_tail_x15_r0_body.cwired147, PRE_first_tail_x15_r0_body.cfix147, clean, PRE_first_tail_x15_r0_body.fcxn147, PRE_first_tail_x15_r0_body.fcnn147, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0147, PRE_first_tail_x15_r0_body.fnk147, PRE_first_tail_x15_r0_body.ckA147, PRE_first_tail_x15_r0_body.cobjsK147, PRE_first_tail_x15_r0_body.cnodesK147, PRE_first_tail_x15_r0_body.citemsK147, PRE_first_tail_x15_r0_body.f1A147, PRE_first_tail_x15_r0_body.f1O147, PRE_first_tail_x15_r0_body.f1N147, PRE_first_tail_x15_r0_body.f1I147, PRE_first_tail_x15_r0_body.fbd147, PRE_first_tail_x15_r0_body.fincW147, PRE_first_tail_x15_r0_body.fincI147, PRE_first_tail_x15_r0_body.fincN147, PRE_first_tail_x15_r0_body.flnF147, PRE_first_tail_x15_r0_body.fh147, PRE_first_tail_x15_r0_body.fo147, PRE_first_tail_x15_r0_body.fok147, PRE_first_tail_x15_r0_body.fnd147, PRE_first_tail_x15_r0_body.fp147, PRE_first_tail_x15_r0_body.fnord147, PRE_first_tail_x15_r0_body.fi147, PRE_first_tail_x15_r0_body.fii147⟩
theorem PRE_first_tail_x15_r0_body.cnshift147 (clean : Conv.NClean (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P147.NL) (cl : SSt (· < 6386) PRE_first_tail_x15_r0_body.cx0_147.mlx) : NShift PRE_first_tail_x15_r0_body.P147 6386 PRE_first_tail_x15_r0_body.kappa147 PRE_first_tail_x15_r0_body.cx0_147 PRE_first_tail_x15_r0_body.cx1_147 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot147 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost147 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0147 PRE_first_tail_x15_r0_body.ckn1147 PRE_first_tail_x15_r0_body.ckheap147 PRE_first_tail_x15_r0_body.ckpl147)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_147 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1425.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_147 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1425.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_147 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1425.ffi) = some PRE_first_tail_x15_r0_body.fxC_147
kernel_rfl PRE_first_tail_x15_r0_body.okrC_147 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1425.ffi) = some PRE_first_tail_x15_r0_body.krC_147
noncomputable def PRE_first_tail_x15_r0_body.fx0_147 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1427.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_147 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1427.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_147 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1427.ffi) = some PRE_first_tail_x15_r0_body.fx0_147
kernel_rfl PRE_first_tail_x15_r0_body.okr0_147 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1427.ffi) = some PRE_first_tail_x15_r0_body.kr0_147
noncomputable def PRE_first_tail_x15_r0_body.fx1_147 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1426.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_147 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1426.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_147 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1426.ffi) = some PRE_first_tail_x15_r0_body.fx1_147
kernel_rfl PRE_first_tail_x15_r0_body.okr1_147 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1426.ffi) = some PRE_first_tail_x15_r0_body.kr1_147
kernel_rfl PRE_first_tail_x15_r0_body.ff0147 : PRE_first_tail_x15_r0_body.fx0_147 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_147 (PRE_first_tail_x15_r0_body.clo147.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_147.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1147 : PRE_first_tail_x15_r0_body.fx1_147 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_147 (PRE_first_tail_x15_r0_body.cwS147.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_147.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck147 : freedLB PRE_first_tail_x15_r0_body.kappa147 PRE_first_tail_x15_r0_body.cx0_147.mlx PRE_first_tail_x15_r0_body.fx0_147 PRE_first_tail_x15_r0_body.fx1_147 PRE_first_tail_x15_r0_body.clo147 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0147 : PRE_first_tail_x15_r0_body.kr0_147.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_147.flags (PRE_first_tail_x15_r0_body.clo147.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_147.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0147 : PRE_first_tail_x15_r0_body.kr0_147.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_147.targs (PRE_first_tail_x15_r0_body.clo147.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_147.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1147 : PRE_first_tail_x15_r0_body.kr1_147.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_147.flags (PRE_first_tail_x15_r0_body.cwS147.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_147.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1147 : PRE_first_tail_x15_r0_body.kr1_147.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_147.targs (PRE_first_tail_x15_r0_body.cwS147.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_147.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck147 : krecLB PRE_first_tail_x15_r0_body.kappa147 6386 PRE_first_tail_x15_r0_body.cx0_147.mlx PRE_first_tail_x15_r0_body.kr0_147 PRE_first_tail_x15_r0_body.kr1_147 PRE_first_tail_x15_r0_body.clo147 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn147 : Nat.ble 6368 6386 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge147 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1426.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1427.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR147 : pendRegB PRE_first_tail_x15_r0_body.kappa147 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe147 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1426.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift147 (clean : Conv.NClean (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P147.NL) (cl : SSt (· < 6386) PRE_first_tail_x15_r0_body.cx0_147.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_147.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_147.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_147.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_147.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P147 6386 PRE_first_tail_x15_r0_body.kappa147 PRE_first_tail_x15_r0_body.s1427.ffi PRE_first_tail_x15_r0_body.s1426.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift147 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue147, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp147 t ht),
    PRE_first_tail_x15_r0_body.cbridge147,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1427.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1426.ffi) (PRE_first_tail_x15_r0_body.cfoot147 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_147 PRE_first_tail_x15_r0_body.ofx1_147 hobjC PRE_first_tail_x15_r0_body.ff0147 PRE_first_tail_x15_r0_body.ff1147 PRE_first_tail_x15_r0_body.ffck147,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1427.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1426.ffi) (PRE_first_tail_x15_r0_body.cfoot147 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_147 PRE_first_tail_x15_r0_body.okr1_147 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn147) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0147 PRE_first_tail_x15_r0_body.fkt0147 PRE_first_tail_x15_r0_body.fkf1147 PRE_first_tail_x15_r0_body.fkt1147 PRE_first_tail_x15_r0_body.fkck147,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0147 PRE_first_tail_x15_r0_body.cnh1147 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe147) PRE_first_tail_x15_r0_body.cpendR147⟩

end Host.Load.Run.Tpl
