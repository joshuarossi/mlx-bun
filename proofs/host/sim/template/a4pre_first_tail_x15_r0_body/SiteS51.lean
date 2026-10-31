import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl51
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 51 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc51 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P51 : LoadP := PRE_first_tail_x15_r0_body.Pc51.raise 16316
kernel_rfl PRE_first_tail_x15_r0_body.craise51 : Nat.ble PRE_first_tail_x15_r0_body.Pc51.N0 16316 = true
theorem PRE_first_tail_x15_r0_body.raised51 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc51 PRE_first_tail_x15_r0_body.P51 :=
  .inr ⟨16316, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise51, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_51 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s463.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_51 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s462.ffi)
def PRE_first_tail_x15_r0_body.khinv51 : PTrie Nat := Stage.setAll PTrie.nil [(19243, 19217), (19221, 19218), (19244, 19219)]
def PRE_first_tail_x15_r0_body.kninv51 : PTrie Nat := Stage.setAll PTrie.nil [(16289, 16289), (16290, 16290), (16291, 16291), (16292, 16292), (16293, 16293), (16294, 16294), (16295, 16295), (16296, 16296), (16297, 16297), (16298, 16298), (16299, 16299), (16300, 16300), (16301, 16301), (16302, 16302), (16303, 16303), (16304, 16304), (16305, 16305), (16306, 16306), (16307, 16307), (16308, 16308), (16309, 16309), (16310, 16310), (16311, 16311), (16312, 16312), (16313, 16313), (16314, 16314), (16315, 16315)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS51 : List Nat := [19197, 19210, 19216, 19217, 19218, 19219, 19220, 19221, 19222, 19223, 19224, 19225, 19226, 19227, 19228, 19229, 19230, 19231, 19232, 19233, 19234, 19235, 19236, 19237, 19238, 19239, 19240, 19241, 19242, 19243, 19244]
def PRE_first_tail_x15_r0_body.cnS51 : List Nat := List.range' 16289 27
def PRE_first_tail_x15_r0_body.ciS51 : List Nat := [] ++ List.range' 16289 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh051 : PRE_first_tail_x15_r0_body.kd51.nh0 = PRE_first_tail_x15_r0_body.cx0_51.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh151 : PRE_first_tail_x15_r0_body.kd51.nh1 = PRE_first_tail_x15_r0_body.cx1_51.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn051 : PRE_first_tail_x15_r0_body.kd51.nn0 = PRE_first_tail_x15_r0_body.cx0_51.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn151 : PRE_first_tail_x15_r0_body.kd51.nn1 = PRE_first_tail_x15_r0_body.cx1_51.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo51 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P51.lo && Nat.ble PRE_first_tail_x15_r0_body.P51.lo PRE_first_tail_x15_r0_body.cx0_51.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P51.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P51.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt51 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_51.mlx.next PRE_first_tail_x15_r0_body.cx1_51.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_51.mlx.nnext PRE_first_tail_x15_r0_body.cx1_51.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband51 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P51.NL && Nat.ble PRE_first_tail_x15_r0_body.P51.NL PRE_first_tail_x15_r0_body.P51.N0 && Nat.ble PRE_first_tail_x15_r0_body.P51.N0 PRE_first_tail_x15_r0_body.cx0_51.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow51 : PRE_first_tail_x15_r0_body.kd51.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren51 : checkRenG PRE_first_tail_x15_r0_body.kd51.hnd PRE_first_tail_x15_r0_body.khinv51 (phB PRE_first_tail_x15_r0_body.cx0_51.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband51 : PRE_first_tail_x15_r0_body.kd51.checkBand PRE_first_tail_x15_r0_body.P51.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos51 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd51.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren51 : checkRenG PRE_first_tail_x15_r0_body.kd51.node PRE_first_tail_x15_r0_body.kninv51 (pnB PRE_first_tail_x15_r0_body.cx0_51.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P51.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd51.nodeF j) PRE_first_tail_x15_r0_body.cx1_51.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a51 : PRE_first_tail_x15_r0_body.cx0_51.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b51 : PRE_first_tail_x15_r0_body.cx0_51.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok151 : PRE_first_tail_x15_r0_body.cx1_51.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.pending = PRE_first_tail_x15_r0_body.cx0_51.mlx.pending.map PRE_first_tail_x15_r0_body.kappa51.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.errh = PRE_first_tail_x15_r0_body.cx0_51.mlx.errh.map PRE_first_tail_x15_r0_body.kappa51.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.files = PRE_first_tail_x15_r0_body.cx0_51.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.arch = PRE_first_tail_x15_r0_body.cx0_51.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_51.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.wired = PRE_first_tail_x15_r0_body.cx0_51.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost51 : PRE_first_tail_x15_r0_body.cx1_51.host = PRE_first_tail_x15_r0_body.cx0_51.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd51`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn051 : PRE_first_tail_x15_r0_body.kd51.n0 = 2715389
kernel_rfl PRE_first_tail_x15_r0_body.ckn151 : PRE_first_tail_x15_r0_body.kd51.n1 = 2716538
kernel_rfl PRE_first_tail_x15_r0_body.ckheap51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.heap).all (fun x => Nat.ble 2715383 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl51 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd51.heap.get (2715383 + j) = nth? PRE_first_tail_x15_r0_body.pl51 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja51 : Nat.ble 2715383 2715383 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn51 : Nat.ble 2264 2264 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD51 : Nat.ble 2715383 PRE_first_tail_x15_r0_body.kd51.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn51 : Nat.ble 19217 PRE_first_tail_x15_r0_body.kd51.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn51 : Nat.ble 16289 PRE_first_tail_x15_r0_body.kd51.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb51 : Nat.ble 19217 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.heap).all (Nat.ble (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.hnd).all (Nat.ble (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.node).all (Nat.ble (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix51 : Conv.FixOld (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa51 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja51) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn51) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD51) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn51) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn51) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb51) PRE_first_tail_x15_r0_body.fheap51 PRE_first_tail_x15_r0_body.fhnd51 PRE_first_tail_x15_r0_body.fnode51
kernel_rfl PRE_first_tail_x15_r0_body.fcxn51 : (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn51 : (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle051 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_51.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_51.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS51.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_51.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS51.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_51.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS51.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_51.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS51.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_51.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd51 : (PRE_first_tail_x15_r0_body.clo51 ++ PRE_first_tail_x15_r0_body.cln51 ++ PRE_first_tail_x15_r0_body.cli51 ++ PRE_first_tail_x15_r0_body.cwS51 ++ PRE_first_tail_x15_r0_body.cnS51 ++ PRE_first_tail_x15_r0_body.ciS51).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW51 : PRE_first_tail_x15_r0_body.cwS51.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo51.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI51 : PRE_first_tail_x15_r0_body.ciS51.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli51.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN51 : PRE_first_tail_x15_r0_body.cnS51.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF51 : PRE_first_tail_x15_r0_body.cln51.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh51 : PRE_first_tail_x15_r0_body.clo51.all (handleOK PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.P51.lo PRE_first_tail_x15_r0_body.cx0_51.mlx PRE_first_tail_x15_r0_body.cx1_51.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo51 : PRE_first_tail_x15_r0_body.clo51.map (fun h => PRE_first_tail_x15_r0_body.cx1_51.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa51.handle h)) = PRE_first_tail_x15_r0_body.clo51.map (fun h => (PRE_first_tail_x15_r0_body.cx0_51.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa51.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok51 : PRE_first_tail_x15_r0_body.clo51.all (objOK PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.P51.NL PRE_first_tail_x15_r0_body.cx0_51.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd51 : PRE_first_tail_x15_r0_body.cln51.all (nodeOKF PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.P51 PRE_first_tail_x15_r0_body.cx0_51.mlx PRE_first_tail_x15_r0_body.cx1_51.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp51 : ((PRE_first_tail_x15_r0_body.cln51.filter (fullB PRE_first_tail_x15_r0_body.P51))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_51.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa51.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln51.filter (fullB PRE_first_tail_x15_r0_body.P51))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_51.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa51.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI51 : incrB PRE_first_tail_x15_r0_body.kd51.nodeF (List.range' 16289 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.node).all (fun k => Nat.ble 16289 k && Nat.blt k 16316) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL51 : (PRE_first_tail_x15_r0_body.cln51.filter (Nat.ble PRE_first_tail_x15_r0_body.P51.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd51.nodeF i) && (Nat.blt i 16316 || Nat.ble PRE_first_tail_x15_r0_body.kd51.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord51 : (PRE_first_tail_x15_r0_body.cln51.filter (Nat.ble PRE_first_tail_x15_r0_body.P51.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd51.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd51.nodeF j) (PRE_first_tail_x15_r0_body.kd51.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow51 PRE_first_tail_x15_r0_body.cnn151 PRE_first_tail_x15_r0_body.fnordI51 PRE_first_tail_x15_r0_body.fnordK51 PRE_first_tail_x15_r0_body.fnordL51
kernel_rfl PRE_first_tail_x15_r0_body.fi51 : PRE_first_tail_x15_r0_body.cli51.all (pnB PRE_first_tail_x15_r0_body.cx0_51.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii51 : PRE_first_tail_x15_r0_body.cli51.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_51.mlx.items.get (PRE_first_tail_x15_r0_body.kappa51.node k) = (PRE_first_tail_x15_r0_body.cx0_51.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa51.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot51 (clean : Conv.NClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P51.NL) (cl : SSt (· < 2282) PRE_first_tail_x15_r0_body.cx0_51.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P51 2282 PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.kd51 PRE_first_tail_x15_r0_body.khinv51 PRE_first_tail_x15_r0_body.kninv51 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx PRE_first_tail_x15_r0_body.cx0_51.mlx PRE_first_tail_x15_r0_body.cx1_51.mlx (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo51 PRE_first_tail_x15_r0_body.cln51 PRE_first_tail_x15_r0_body.cli51 PRE_first_tail_x15_r0_body.cwS51 PRE_first_tail_x15_r0_body.cnS51 PRE_first_tail_x15_r0_body.ciS51 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh051, PRE_first_tail_x15_r0_body.cnh151, PRE_first_tail_x15_r0_body.cnn051, PRE_first_tail_x15_r0_body.cnn151, PRE_first_tail_x15_r0_body.cplo51, PRE_first_tail_x15_r0_body.ccnt51, PRE_first_tail_x15_r0_body.cnband51, PRE_first_tail_x15_r0_body.chbelow51, PRE_first_tail_x15_r0_body.chren51, PRE_first_tail_x15_r0_body.cband51, PRE_first_tail_x15_r0_body.cnh1pos51, PRE_first_tail_x15_r0_body.cnren51, PRE_first_tail_x15_r0_body.cnlow51, PRE_first_tail_x15_r0_body.cabs0a51, PRE_first_tail_x15_r0_body.cabs0b51, PRE_first_tail_x15_r0_body.ctok151, PRE_first_tail_x15_r0_body.cpend51, PRE_first_tail_x15_r0_body.cerrh51, PRE_first_tail_x15_r0_body.cfiles51, PRE_first_tail_x15_r0_body.carch51, PRE_first_tail_x15_r0_body.csizes51, PRE_first_tail_x15_r0_body.cwired51, PRE_first_tail_x15_r0_body.cfix51, clean, PRE_first_tail_x15_r0_body.fcxn51, PRE_first_tail_x15_r0_body.fcnn51, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle051, PRE_first_tail_x15_r0_body.fnk51, PRE_first_tail_x15_r0_body.ckA51, PRE_first_tail_x15_r0_body.cobjsK51, PRE_first_tail_x15_r0_body.cnodesK51, PRE_first_tail_x15_r0_body.citemsK51, PRE_first_tail_x15_r0_body.f1A51, PRE_first_tail_x15_r0_body.f1O51, PRE_first_tail_x15_r0_body.f1N51, PRE_first_tail_x15_r0_body.f1I51, PRE_first_tail_x15_r0_body.fbd51, PRE_first_tail_x15_r0_body.fincW51, PRE_first_tail_x15_r0_body.fincI51, PRE_first_tail_x15_r0_body.fincN51, PRE_first_tail_x15_r0_body.flnF51, PRE_first_tail_x15_r0_body.fh51, PRE_first_tail_x15_r0_body.fo51, PRE_first_tail_x15_r0_body.fok51, PRE_first_tail_x15_r0_body.fnd51, PRE_first_tail_x15_r0_body.fp51, PRE_first_tail_x15_r0_body.fnord51, PRE_first_tail_x15_r0_body.fi51, PRE_first_tail_x15_r0_body.fii51⟩
theorem PRE_first_tail_x15_r0_body.cnshift51 (clean : Conv.NClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P51.NL) (cl : SSt (· < 2282) PRE_first_tail_x15_r0_body.cx0_51.mlx) : NShift PRE_first_tail_x15_r0_body.P51 2282 PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.cx0_51 PRE_first_tail_x15_r0_body.cx1_51 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot51 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost51 (compact_a_eq PRE_first_tail_x15_r0_body.ckn051 PRE_first_tail_x15_r0_body.ckn151 PRE_first_tail_x15_r0_body.ckheap51 PRE_first_tail_x15_r0_body.ckpl51)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_51 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s461.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_51 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s461.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_51 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s461.ffi) = some PRE_first_tail_x15_r0_body.fxC_51
kernel_rfl PRE_first_tail_x15_r0_body.okrC_51 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s461.ffi) = some PRE_first_tail_x15_r0_body.krC_51
noncomputable def PRE_first_tail_x15_r0_body.fx0_51 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s463.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_51 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s463.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_51 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s463.ffi) = some PRE_first_tail_x15_r0_body.fx0_51
kernel_rfl PRE_first_tail_x15_r0_body.okr0_51 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s463.ffi) = some PRE_first_tail_x15_r0_body.kr0_51
noncomputable def PRE_first_tail_x15_r0_body.fx1_51 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s462.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_51 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s462.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_51 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s462.ffi) = some PRE_first_tail_x15_r0_body.fx1_51
kernel_rfl PRE_first_tail_x15_r0_body.okr1_51 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s462.ffi) = some PRE_first_tail_x15_r0_body.kr1_51
kernel_rfl PRE_first_tail_x15_r0_body.ff051 : PRE_first_tail_x15_r0_body.fx0_51 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_51 (PRE_first_tail_x15_r0_body.clo51.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_51.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff151 : PRE_first_tail_x15_r0_body.fx1_51 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_51 (PRE_first_tail_x15_r0_body.cwS51.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_51.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck51 : freedLB PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.cx0_51.mlx PRE_first_tail_x15_r0_body.fx0_51 PRE_first_tail_x15_r0_body.fx1_51 PRE_first_tail_x15_r0_body.clo51 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf051 : PRE_first_tail_x15_r0_body.kr0_51.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_51.flags (PRE_first_tail_x15_r0_body.clo51.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_51.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt051 : PRE_first_tail_x15_r0_body.kr0_51.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_51.targs (PRE_first_tail_x15_r0_body.clo51.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_51.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf151 : PRE_first_tail_x15_r0_body.kr1_51.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_51.flags (PRE_first_tail_x15_r0_body.cwS51.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_51.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt151 : PRE_first_tail_x15_r0_body.kr1_51.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_51.targs (PRE_first_tail_x15_r0_body.cwS51.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_51.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck51 : krecLB PRE_first_tail_x15_r0_body.kappa51 2282 PRE_first_tail_x15_r0_body.cx0_51.mlx PRE_first_tail_x15_r0_body.kr0_51 PRE_first_tail_x15_r0_body.kr1_51 PRE_first_tail_x15_r0_body.clo51 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn51 : Nat.ble 2264 2282 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge51 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s462.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s463.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR51 : pendRegB PRE_first_tail_x15_r0_body.kappa51 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s463.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe51 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s463.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s462.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift51 (clean : Conv.NClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P51.NL) (cl : SSt (· < 2282) PRE_first_tail_x15_r0_body.cx0_51.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_51.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_51.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_51.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_51.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P51 2282 PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.s463.ffi PRE_first_tail_x15_r0_body.s462.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift51 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue51, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp51 t ht),
    PRE_first_tail_x15_r0_body.cbridge51,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s463.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s462.ffi) (PRE_first_tail_x15_r0_body.cfoot51 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_51 PRE_first_tail_x15_r0_body.ofx1_51 hobjC PRE_first_tail_x15_r0_body.ff051 PRE_first_tail_x15_r0_body.ff151 PRE_first_tail_x15_r0_body.ffck51,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s463.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s462.ffi) (PRE_first_tail_x15_r0_body.cfoot51 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_51 PRE_first_tail_x15_r0_body.okr1_51 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn51) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf051 PRE_first_tail_x15_r0_body.fkt051 PRE_first_tail_x15_r0_body.fkf151 PRE_first_tail_x15_r0_body.fkt151 PRE_first_tail_x15_r0_body.fkck51,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh051 PRE_first_tail_x15_r0_body.cnh151 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe51) PRE_first_tail_x15_r0_body.cpendR51⟩

end Host.Load.Run.Tpl
