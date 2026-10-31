import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl54
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 54 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc54 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P54 : LoadP := PRE_first_tail_x15_r0_body.Pc54.raise 16379
kernel_rfl PRE_first_tail_x15_r0_body.craise54 : Nat.ble PRE_first_tail_x15_r0_body.Pc54.N0 16379 = true
theorem PRE_first_tail_x15_r0_body.raised54 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc54 PRE_first_tail_x15_r0_body.P54 :=
  .inr ⟨16379, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise54, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_54 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_54 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s535.ffi)
def PRE_first_tail_x15_r0_body.khinv54 : PTrie Nat := Stage.setAll PTrie.nil [(19300, 19274), (19278, 19275), (19301, 19276)]
def PRE_first_tail_x15_r0_body.kninv54 : PTrie Nat := Stage.setAll PTrie.nil [(16352, 16352), (16353, 16353), (16354, 16354), (16355, 16355), (16356, 16356), (16357, 16357), (16358, 16358), (16359, 16359), (16360, 16360), (16361, 16361), (16362, 16362), (16363, 16363), (16364, 16364), (16365, 16365), (16366, 16366), (16367, 16367), (16368, 16368), (16369, 16369), (16370, 16370), (16371, 16371), (16372, 16372), (16373, 16373), (16374, 16374), (16375, 16375), (16376, 16376), (16377, 16377), (16378, 16378)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS54 : List Nat := [19254, 19267, 19273, 19274, 19275, 19276, 19277, 19278, 19279, 19280, 19281, 19282, 19283, 19284, 19285, 19286, 19287, 19288, 19289, 19290, 19291, 19292, 19293, 19294, 19295, 19296, 19297, 19298, 19299, 19300, 19301]
def PRE_first_tail_x15_r0_body.cnS54 : List Nat := List.range' 16352 27
def PRE_first_tail_x15_r0_body.ciS54 : List Nat := [] ++ List.range' 16352 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh054 : PRE_first_tail_x15_r0_body.kd54.nh0 = PRE_first_tail_x15_r0_body.cx0_54.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh154 : PRE_first_tail_x15_r0_body.kd54.nh1 = PRE_first_tail_x15_r0_body.cx1_54.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn054 : PRE_first_tail_x15_r0_body.kd54.nn0 = PRE_first_tail_x15_r0_body.cx0_54.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn154 : PRE_first_tail_x15_r0_body.kd54.nn1 = PRE_first_tail_x15_r0_body.cx1_54.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo54 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P54.lo && Nat.ble PRE_first_tail_x15_r0_body.P54.lo PRE_first_tail_x15_r0_body.cx0_54.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P54.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P54.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt54 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_54.mlx.next PRE_first_tail_x15_r0_body.cx1_54.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_54.mlx.nnext PRE_first_tail_x15_r0_body.cx1_54.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband54 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P54.NL && Nat.ble PRE_first_tail_x15_r0_body.P54.NL PRE_first_tail_x15_r0_body.P54.N0 && Nat.ble PRE_first_tail_x15_r0_body.P54.N0 PRE_first_tail_x15_r0_body.cx0_54.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow54 : PRE_first_tail_x15_r0_body.kd54.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren54 : checkRenG PRE_first_tail_x15_r0_body.kd54.hnd PRE_first_tail_x15_r0_body.khinv54 (phB PRE_first_tail_x15_r0_body.cx0_54.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband54 : PRE_first_tail_x15_r0_body.kd54.checkBand PRE_first_tail_x15_r0_body.P54.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos54 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd54.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren54 : checkRenG PRE_first_tail_x15_r0_body.kd54.node PRE_first_tail_x15_r0_body.kninv54 (pnB PRE_first_tail_x15_r0_body.cx0_54.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P54.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd54.nodeF j) PRE_first_tail_x15_r0_body.cx1_54.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a54 : PRE_first_tail_x15_r0_body.cx0_54.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b54 : PRE_first_tail_x15_r0_body.cx0_54.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok154 : PRE_first_tail_x15_r0_body.cx1_54.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.pending = PRE_first_tail_x15_r0_body.cx0_54.mlx.pending.map PRE_first_tail_x15_r0_body.kappa54.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.errh = PRE_first_tail_x15_r0_body.cx0_54.mlx.errh.map PRE_first_tail_x15_r0_body.kappa54.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.files = PRE_first_tail_x15_r0_body.cx0_54.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.arch = PRE_first_tail_x15_r0_body.cx0_54.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_54.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.wired = PRE_first_tail_x15_r0_body.cx0_54.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost54 : PRE_first_tail_x15_r0_body.cx1_54.host = PRE_first_tail_x15_r0_body.cx0_54.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd54`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn054 : PRE_first_tail_x15_r0_body.kd54.n0 = 2717649
kernel_rfl PRE_first_tail_x15_r0_body.ckn154 : PRE_first_tail_x15_r0_body.kd54.n1 = 2718798
kernel_rfl PRE_first_tail_x15_r0_body.ckheap54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.heap).all (fun x => Nat.ble 2717643 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl54 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd54.heap.get (2717643 + j) = nth? PRE_first_tail_x15_r0_body.pl54 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja54 : Nat.ble 2717643 2717643 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn54 : Nat.ble 2393 2393 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD54 : Nat.ble 2717643 PRE_first_tail_x15_r0_body.kd54.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn54 : Nat.ble 19274 PRE_first_tail_x15_r0_body.kd54.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn54 : Nat.ble 16352 PRE_first_tail_x15_r0_body.kd54.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb54 : Nat.ble 19274 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.heap).all (Nat.ble (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.hnd).all (Nat.ble (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.node).all (Nat.ble (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix54 : Conv.FixOld (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa54 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja54) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn54) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD54) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn54) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn54) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb54) PRE_first_tail_x15_r0_body.fheap54 PRE_first_tail_x15_r0_body.fhnd54 PRE_first_tail_x15_r0_body.fnode54
kernel_rfl PRE_first_tail_x15_r0_body.fcxn54 : (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn54 : (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle054 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_54.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_54.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS54.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_54.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS54.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_54.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS54.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_54.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS54.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_54.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd54 : (PRE_first_tail_x15_r0_body.clo54 ++ PRE_first_tail_x15_r0_body.cln54 ++ PRE_first_tail_x15_r0_body.cli54 ++ PRE_first_tail_x15_r0_body.cwS54 ++ PRE_first_tail_x15_r0_body.cnS54 ++ PRE_first_tail_x15_r0_body.ciS54).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW54 : PRE_first_tail_x15_r0_body.cwS54.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo54.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI54 : PRE_first_tail_x15_r0_body.ciS54.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli54.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN54 : PRE_first_tail_x15_r0_body.cnS54.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF54 : PRE_first_tail_x15_r0_body.cln54.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh54 : PRE_first_tail_x15_r0_body.clo54.all (handleOK PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.P54.lo PRE_first_tail_x15_r0_body.cx0_54.mlx PRE_first_tail_x15_r0_body.cx1_54.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo54 : PRE_first_tail_x15_r0_body.clo54.map (fun h => PRE_first_tail_x15_r0_body.cx1_54.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa54.handle h)) = PRE_first_tail_x15_r0_body.clo54.map (fun h => (PRE_first_tail_x15_r0_body.cx0_54.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa54.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok54 : PRE_first_tail_x15_r0_body.clo54.all (objOK PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.P54.NL PRE_first_tail_x15_r0_body.cx0_54.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd54 : PRE_first_tail_x15_r0_body.cln54.all (nodeOKF PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.P54 PRE_first_tail_x15_r0_body.cx0_54.mlx PRE_first_tail_x15_r0_body.cx1_54.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp54 : ((PRE_first_tail_x15_r0_body.cln54.filter (fullB PRE_first_tail_x15_r0_body.P54))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_54.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa54.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln54.filter (fullB PRE_first_tail_x15_r0_body.P54))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_54.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa54.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI54 : incrB PRE_first_tail_x15_r0_body.kd54.nodeF (List.range' 16352 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.node).all (fun k => Nat.ble 16352 k && Nat.blt k 16379) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL54 : (PRE_first_tail_x15_r0_body.cln54.filter (Nat.ble PRE_first_tail_x15_r0_body.P54.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd54.nodeF i) && (Nat.blt i 16379 || Nat.ble PRE_first_tail_x15_r0_body.kd54.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord54 : (PRE_first_tail_x15_r0_body.cln54.filter (Nat.ble PRE_first_tail_x15_r0_body.P54.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd54.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd54.nodeF j) (PRE_first_tail_x15_r0_body.kd54.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow54 PRE_first_tail_x15_r0_body.cnn154 PRE_first_tail_x15_r0_body.fnordI54 PRE_first_tail_x15_r0_body.fnordK54 PRE_first_tail_x15_r0_body.fnordL54
kernel_rfl PRE_first_tail_x15_r0_body.fi54 : PRE_first_tail_x15_r0_body.cli54.all (pnB PRE_first_tail_x15_r0_body.cx0_54.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii54 : PRE_first_tail_x15_r0_body.cli54.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_54.mlx.items.get (PRE_first_tail_x15_r0_body.kappa54.node k) = (PRE_first_tail_x15_r0_body.cx0_54.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa54.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot54 (clean : Conv.NClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P54.NL) (cl : SSt (· < 2411) PRE_first_tail_x15_r0_body.cx0_54.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P54 2411 PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.kd54 PRE_first_tail_x15_r0_body.khinv54 PRE_first_tail_x15_r0_body.kninv54 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx PRE_first_tail_x15_r0_body.cx0_54.mlx PRE_first_tail_x15_r0_body.cx1_54.mlx (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo54 PRE_first_tail_x15_r0_body.cln54 PRE_first_tail_x15_r0_body.cli54 PRE_first_tail_x15_r0_body.cwS54 PRE_first_tail_x15_r0_body.cnS54 PRE_first_tail_x15_r0_body.ciS54 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh054, PRE_first_tail_x15_r0_body.cnh154, PRE_first_tail_x15_r0_body.cnn054, PRE_first_tail_x15_r0_body.cnn154, PRE_first_tail_x15_r0_body.cplo54, PRE_first_tail_x15_r0_body.ccnt54, PRE_first_tail_x15_r0_body.cnband54, PRE_first_tail_x15_r0_body.chbelow54, PRE_first_tail_x15_r0_body.chren54, PRE_first_tail_x15_r0_body.cband54, PRE_first_tail_x15_r0_body.cnh1pos54, PRE_first_tail_x15_r0_body.cnren54, PRE_first_tail_x15_r0_body.cnlow54, PRE_first_tail_x15_r0_body.cabs0a54, PRE_first_tail_x15_r0_body.cabs0b54, PRE_first_tail_x15_r0_body.ctok154, PRE_first_tail_x15_r0_body.cpend54, PRE_first_tail_x15_r0_body.cerrh54, PRE_first_tail_x15_r0_body.cfiles54, PRE_first_tail_x15_r0_body.carch54, PRE_first_tail_x15_r0_body.csizes54, PRE_first_tail_x15_r0_body.cwired54, PRE_first_tail_x15_r0_body.cfix54, clean, PRE_first_tail_x15_r0_body.fcxn54, PRE_first_tail_x15_r0_body.fcnn54, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle054, PRE_first_tail_x15_r0_body.fnk54, PRE_first_tail_x15_r0_body.ckA54, PRE_first_tail_x15_r0_body.cobjsK54, PRE_first_tail_x15_r0_body.cnodesK54, PRE_first_tail_x15_r0_body.citemsK54, PRE_first_tail_x15_r0_body.f1A54, PRE_first_tail_x15_r0_body.f1O54, PRE_first_tail_x15_r0_body.f1N54, PRE_first_tail_x15_r0_body.f1I54, PRE_first_tail_x15_r0_body.fbd54, PRE_first_tail_x15_r0_body.fincW54, PRE_first_tail_x15_r0_body.fincI54, PRE_first_tail_x15_r0_body.fincN54, PRE_first_tail_x15_r0_body.flnF54, PRE_first_tail_x15_r0_body.fh54, PRE_first_tail_x15_r0_body.fo54, PRE_first_tail_x15_r0_body.fok54, PRE_first_tail_x15_r0_body.fnd54, PRE_first_tail_x15_r0_body.fp54, PRE_first_tail_x15_r0_body.fnord54, PRE_first_tail_x15_r0_body.fi54, PRE_first_tail_x15_r0_body.fii54⟩
theorem PRE_first_tail_x15_r0_body.cnshift54 (clean : Conv.NClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P54.NL) (cl : SSt (· < 2411) PRE_first_tail_x15_r0_body.cx0_54.mlx) : NShift PRE_first_tail_x15_r0_body.P54 2411 PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.cx0_54 PRE_first_tail_x15_r0_body.cx1_54 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot54 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost54 (compact_a_eq PRE_first_tail_x15_r0_body.ckn054 PRE_first_tail_x15_r0_body.ckn154 PRE_first_tail_x15_r0_body.ckheap54 PRE_first_tail_x15_r0_body.ckpl54)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_54 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s534.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_54 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s534.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_54 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s534.ffi) = some PRE_first_tail_x15_r0_body.fxC_54
kernel_rfl PRE_first_tail_x15_r0_body.okrC_54 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s534.ffi) = some PRE_first_tail_x15_r0_body.krC_54
noncomputable def PRE_first_tail_x15_r0_body.fx0_54 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s536.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_54 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s536.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_54 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s536.ffi) = some PRE_first_tail_x15_r0_body.fx0_54
kernel_rfl PRE_first_tail_x15_r0_body.okr0_54 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s536.ffi) = some PRE_first_tail_x15_r0_body.kr0_54
noncomputable def PRE_first_tail_x15_r0_body.fx1_54 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s535.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_54 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s535.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_54 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s535.ffi) = some PRE_first_tail_x15_r0_body.fx1_54
kernel_rfl PRE_first_tail_x15_r0_body.okr1_54 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s535.ffi) = some PRE_first_tail_x15_r0_body.kr1_54
kernel_rfl PRE_first_tail_x15_r0_body.ff054 : PRE_first_tail_x15_r0_body.fx0_54 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_54 (PRE_first_tail_x15_r0_body.clo54.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_54.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff154 : PRE_first_tail_x15_r0_body.fx1_54 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_54 (PRE_first_tail_x15_r0_body.cwS54.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_54.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck54 : freedLB PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.cx0_54.mlx PRE_first_tail_x15_r0_body.fx0_54 PRE_first_tail_x15_r0_body.fx1_54 PRE_first_tail_x15_r0_body.clo54 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf054 : PRE_first_tail_x15_r0_body.kr0_54.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_54.flags (PRE_first_tail_x15_r0_body.clo54.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_54.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt054 : PRE_first_tail_x15_r0_body.kr0_54.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_54.targs (PRE_first_tail_x15_r0_body.clo54.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_54.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf154 : PRE_first_tail_x15_r0_body.kr1_54.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_54.flags (PRE_first_tail_x15_r0_body.cwS54.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_54.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt154 : PRE_first_tail_x15_r0_body.kr1_54.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_54.targs (PRE_first_tail_x15_r0_body.cwS54.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_54.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck54 : krecLB PRE_first_tail_x15_r0_body.kappa54 2411 PRE_first_tail_x15_r0_body.cx0_54.mlx PRE_first_tail_x15_r0_body.kr0_54 PRE_first_tail_x15_r0_body.kr1_54 PRE_first_tail_x15_r0_body.clo54 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn54 : Nat.ble 2393 2411 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge54 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s535.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s536.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR54 : pendRegB PRE_first_tail_x15_r0_body.kappa54 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe54 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s535.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift54 (clean : Conv.NClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P54.NL) (cl : SSt (· < 2411) PRE_first_tail_x15_r0_body.cx0_54.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_54.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_54.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_54.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_54.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P54 2411 PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.s536.ffi PRE_first_tail_x15_r0_body.s535.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift54 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue54, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp54 t ht),
    PRE_first_tail_x15_r0_body.cbridge54,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s536.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s535.ffi) (PRE_first_tail_x15_r0_body.cfoot54 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_54 PRE_first_tail_x15_r0_body.ofx1_54 hobjC PRE_first_tail_x15_r0_body.ff054 PRE_first_tail_x15_r0_body.ff154 PRE_first_tail_x15_r0_body.ffck54,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s536.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s535.ffi) (PRE_first_tail_x15_r0_body.cfoot54 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_54 PRE_first_tail_x15_r0_body.okr1_54 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn54) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf054 PRE_first_tail_x15_r0_body.fkt054 PRE_first_tail_x15_r0_body.fkf154 PRE_first_tail_x15_r0_body.fkt154 PRE_first_tail_x15_r0_body.fkck54,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh054 PRE_first_tail_x15_r0_body.cnh154 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe54) PRE_first_tail_x15_r0_body.cpendR54⟩

end Host.Load.Run.Tpl
