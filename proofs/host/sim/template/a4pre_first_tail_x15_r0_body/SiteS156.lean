import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl156
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 156 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc156 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P156 : LoadP := PRE_first_tail_x15_r0_body.Pc156.raise 18386
kernel_rfl PRE_first_tail_x15_r0_body.craise156 : Nat.ble PRE_first_tail_x15_r0_body.Pc156.N0 18386 = true
theorem PRE_first_tail_x15_r0_body.raised156 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc156 PRE_first_tail_x15_r0_body.P156 :=
  .inr ⟨18386, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise156, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_156 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_156 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1380.ffi)
def PRE_first_tail_x15_r0_body.khinv156 : PTrie Nat := Stage.setAll PTrie.nil [(21310, 21284), (21288, 21285), (21311, 21286)]
def PRE_first_tail_x15_r0_body.kninv156 : PTrie Nat := Stage.setAll PTrie.nil [(18359, 18359), (18360, 18360), (18361, 18361), (18362, 18362), (18363, 18363), (18364, 18364), (18365, 18365), (18366, 18366), (18367, 18367), (18368, 18368), (18369, 18369), (18370, 18370), (18371, 18371), (18372, 18372), (18373, 18373), (18374, 18374), (18375, 18375), (18376, 18376), (18377, 18377), (18378, 18378), (18379, 18379), (18380, 18380), (18381, 18381), (18382, 18382), (18383, 18383), (18384, 18384), (18385, 18385)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS156 : List Nat := [21264, 21277, 21283, 21284, 21285, 21286, 21287, 21288, 21289, 21290, 21291, 21292, 21293, 21294, 21295, 21296, 21297, 21298, 21299, 21300, 21301, 21302, 21303, 21304, 21305, 21306, 21307, 21308, 21309, 21310, 21311]
def PRE_first_tail_x15_r0_body.cnS156 : List Nat := List.range' 18359 27
def PRE_first_tail_x15_r0_body.ciS156 : List Nat := [] ++ List.range' 18359 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0156 : PRE_first_tail_x15_r0_body.kd156.nh0 = PRE_first_tail_x15_r0_body.cx0_156.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1156 : PRE_first_tail_x15_r0_body.kd156.nh1 = PRE_first_tail_x15_r0_body.cx1_156.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0156 : PRE_first_tail_x15_r0_body.kd156.nn0 = PRE_first_tail_x15_r0_body.cx0_156.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1156 : PRE_first_tail_x15_r0_body.kd156.nn1 = PRE_first_tail_x15_r0_body.cx1_156.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo156 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P156.lo && Nat.ble PRE_first_tail_x15_r0_body.P156.lo PRE_first_tail_x15_r0_body.cx0_156.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P156.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P156.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt156 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_156.mlx.next PRE_first_tail_x15_r0_body.cx1_156.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_156.mlx.nnext PRE_first_tail_x15_r0_body.cx1_156.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband156 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P156.NL && Nat.ble PRE_first_tail_x15_r0_body.P156.NL PRE_first_tail_x15_r0_body.P156.N0 && Nat.ble PRE_first_tail_x15_r0_body.P156.N0 PRE_first_tail_x15_r0_body.cx0_156.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow156 : PRE_first_tail_x15_r0_body.kd156.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren156 : checkRenG PRE_first_tail_x15_r0_body.kd156.hnd PRE_first_tail_x15_r0_body.khinv156 (phB PRE_first_tail_x15_r0_body.cx0_156.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband156 : PRE_first_tail_x15_r0_body.kd156.checkBand PRE_first_tail_x15_r0_body.P156.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos156 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd156.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren156 : checkRenG PRE_first_tail_x15_r0_body.kd156.node PRE_first_tail_x15_r0_body.kninv156 (pnB PRE_first_tail_x15_r0_body.cx0_156.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow156 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd156.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P156.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd156.nodeF j) PRE_first_tail_x15_r0_body.cx1_156.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a156 : PRE_first_tail_x15_r0_body.cx0_156.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b156 : PRE_first_tail_x15_r0_body.cx0_156.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1156 : PRE_first_tail_x15_r0_body.cx1_156.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend156 : PRE_first_tail_x15_r0_body.cx1_156.mlx.pending = PRE_first_tail_x15_r0_body.cx0_156.mlx.pending.map PRE_first_tail_x15_r0_body.kappa156.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh156 : PRE_first_tail_x15_r0_body.cx1_156.mlx.errh = PRE_first_tail_x15_r0_body.cx0_156.mlx.errh.map PRE_first_tail_x15_r0_body.kappa156.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles156 : PRE_first_tail_x15_r0_body.cx1_156.mlx.files = PRE_first_tail_x15_r0_body.cx0_156.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch156 : PRE_first_tail_x15_r0_body.cx1_156.mlx.arch = PRE_first_tail_x15_r0_body.cx0_156.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes156 : PRE_first_tail_x15_r0_body.cx1_156.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_156.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired156 : PRE_first_tail_x15_r0_body.cx1_156.mlx.wired = PRE_first_tail_x15_r0_body.cx0_156.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost156 : PRE_first_tail_x15_r0_body.cx1_156.host = PRE_first_tail_x15_r0_body.cx0_156.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd156`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0156 : PRE_first_tail_x15_r0_body.kd156.n0 = 2797885
kernel_rfl PRE_first_tail_x15_r0_body.ckn1156 : PRE_first_tail_x15_r0_body.kd156.n1 = 2799034
kernel_rfl PRE_first_tail_x15_r0_body.ckheap156 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd156.heap).all (fun x => Nat.ble 2797879 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl156 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd156.heap.get (2797879 + j) = nth? PRE_first_tail_x15_r0_body.pl156 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja156 : Nat.ble 2797879 2797879 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn156 : Nat.ble 6752 6752 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD156 : Nat.ble 2797879 PRE_first_tail_x15_r0_body.kd156.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn156 : Nat.ble 21284 PRE_first_tail_x15_r0_body.kd156.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn156 : Nat.ble 18359 PRE_first_tail_x15_r0_body.kd156.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb156 : Nat.ble 21284 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap156 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd156.heap).all (Nat.ble (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd156 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd156.hnd).all (Nat.ble (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode156 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd156.node).all (Nat.ble (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix156 : Conv.FixOld (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa156 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja156) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn156) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD156) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn156) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn156) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb156) PRE_first_tail_x15_r0_body.fheap156 PRE_first_tail_x15_r0_body.fhnd156 PRE_first_tail_x15_r0_body.fnode156
kernel_rfl PRE_first_tail_x15_r0_body.fcxn156 : (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn156 : (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0156 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_156.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_156.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk156 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd156.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A156 : PRE_first_tail_x15_r0_body.cx1_156.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS156.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_156.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O156 : PRE_first_tail_x15_r0_body.cx1_156.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS156.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_156.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N156 : PRE_first_tail_x15_r0_body.cx1_156.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS156.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_156.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I156 : PRE_first_tail_x15_r0_body.cx1_156.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS156.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_156.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd156 : (PRE_first_tail_x15_r0_body.clo156 ++ PRE_first_tail_x15_r0_body.cln156 ++ PRE_first_tail_x15_r0_body.cli156 ++ PRE_first_tail_x15_r0_body.cwS156 ++ PRE_first_tail_x15_r0_body.cnS156 ++ PRE_first_tail_x15_r0_body.ciS156).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW156 : PRE_first_tail_x15_r0_body.cwS156.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo156.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI156 : PRE_first_tail_x15_r0_body.ciS156.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli156.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN156 : PRE_first_tail_x15_r0_body.cnS156.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF156 : PRE_first_tail_x15_r0_body.cln156.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh156 : PRE_first_tail_x15_r0_body.clo156.all (handleOK PRE_first_tail_x15_r0_body.kappa156 PRE_first_tail_x15_r0_body.P156.lo PRE_first_tail_x15_r0_body.cx0_156.mlx PRE_first_tail_x15_r0_body.cx1_156.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo156 : PRE_first_tail_x15_r0_body.clo156.map (fun h => PRE_first_tail_x15_r0_body.cx1_156.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa156.handle h)) = PRE_first_tail_x15_r0_body.clo156.map (fun h => (PRE_first_tail_x15_r0_body.cx0_156.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa156.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok156 : PRE_first_tail_x15_r0_body.clo156.all (objOK PRE_first_tail_x15_r0_body.kappa156 PRE_first_tail_x15_r0_body.P156.NL PRE_first_tail_x15_r0_body.cx0_156.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd156 : PRE_first_tail_x15_r0_body.cln156.all (nodeOKF PRE_first_tail_x15_r0_body.kappa156 PRE_first_tail_x15_r0_body.P156 PRE_first_tail_x15_r0_body.cx0_156.mlx PRE_first_tail_x15_r0_body.cx1_156.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp156 : ((PRE_first_tail_x15_r0_body.cln156.filter (fullB PRE_first_tail_x15_r0_body.P156))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_156.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa156.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln156.filter (fullB PRE_first_tail_x15_r0_body.P156))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_156.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa156.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI156 : incrB PRE_first_tail_x15_r0_body.kd156.nodeF (List.range' 18359 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK156 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd156.node).all (fun k => Nat.ble 18359 k && Nat.blt k 18386) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL156 : (PRE_first_tail_x15_r0_body.cln156.filter (Nat.ble PRE_first_tail_x15_r0_body.P156.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd156.nodeF i) && (Nat.blt i 18386 || Nat.ble PRE_first_tail_x15_r0_body.kd156.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord156 : (PRE_first_tail_x15_r0_body.cln156.filter (Nat.ble PRE_first_tail_x15_r0_body.P156.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd156.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd156.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd156.nodeF j) (PRE_first_tail_x15_r0_body.kd156.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow156 PRE_first_tail_x15_r0_body.cnn1156 PRE_first_tail_x15_r0_body.fnordI156 PRE_first_tail_x15_r0_body.fnordK156 PRE_first_tail_x15_r0_body.fnordL156
kernel_rfl PRE_first_tail_x15_r0_body.fi156 : PRE_first_tail_x15_r0_body.cli156.all (pnB PRE_first_tail_x15_r0_body.cx0_156.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii156 : PRE_first_tail_x15_r0_body.cli156.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_156.mlx.items.get (PRE_first_tail_x15_r0_body.kappa156.node k) = (PRE_first_tail_x15_r0_body.cx0_156.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa156.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot156 (clean : Conv.NClean (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P156.NL) (cl : SSt (· < 6770) PRE_first_tail_x15_r0_body.cx0_156.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P156 6770 PRE_first_tail_x15_r0_body.kappa156 PRE_first_tail_x15_r0_body.kd156 PRE_first_tail_x15_r0_body.khinv156 PRE_first_tail_x15_r0_body.kninv156 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx PRE_first_tail_x15_r0_body.cx0_156.mlx PRE_first_tail_x15_r0_body.cx1_156.mlx (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo156 PRE_first_tail_x15_r0_body.cln156 PRE_first_tail_x15_r0_body.cli156 PRE_first_tail_x15_r0_body.cwS156 PRE_first_tail_x15_r0_body.cnS156 PRE_first_tail_x15_r0_body.ciS156 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0156, PRE_first_tail_x15_r0_body.cnh1156, PRE_first_tail_x15_r0_body.cnn0156, PRE_first_tail_x15_r0_body.cnn1156, PRE_first_tail_x15_r0_body.cplo156, PRE_first_tail_x15_r0_body.ccnt156, PRE_first_tail_x15_r0_body.cnband156, PRE_first_tail_x15_r0_body.chbelow156, PRE_first_tail_x15_r0_body.chren156, PRE_first_tail_x15_r0_body.cband156, PRE_first_tail_x15_r0_body.cnh1pos156, PRE_first_tail_x15_r0_body.cnren156, PRE_first_tail_x15_r0_body.cnlow156, PRE_first_tail_x15_r0_body.cabs0a156, PRE_first_tail_x15_r0_body.cabs0b156, PRE_first_tail_x15_r0_body.ctok1156, PRE_first_tail_x15_r0_body.cpend156, PRE_first_tail_x15_r0_body.cerrh156, PRE_first_tail_x15_r0_body.cfiles156, PRE_first_tail_x15_r0_body.carch156, PRE_first_tail_x15_r0_body.csizes156, PRE_first_tail_x15_r0_body.cwired156, PRE_first_tail_x15_r0_body.cfix156, clean, PRE_first_tail_x15_r0_body.fcxn156, PRE_first_tail_x15_r0_body.fcnn156, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0156, PRE_first_tail_x15_r0_body.fnk156, PRE_first_tail_x15_r0_body.ckA156, PRE_first_tail_x15_r0_body.cobjsK156, PRE_first_tail_x15_r0_body.cnodesK156, PRE_first_tail_x15_r0_body.citemsK156, PRE_first_tail_x15_r0_body.f1A156, PRE_first_tail_x15_r0_body.f1O156, PRE_first_tail_x15_r0_body.f1N156, PRE_first_tail_x15_r0_body.f1I156, PRE_first_tail_x15_r0_body.fbd156, PRE_first_tail_x15_r0_body.fincW156, PRE_first_tail_x15_r0_body.fincI156, PRE_first_tail_x15_r0_body.fincN156, PRE_first_tail_x15_r0_body.flnF156, PRE_first_tail_x15_r0_body.fh156, PRE_first_tail_x15_r0_body.fo156, PRE_first_tail_x15_r0_body.fok156, PRE_first_tail_x15_r0_body.fnd156, PRE_first_tail_x15_r0_body.fp156, PRE_first_tail_x15_r0_body.fnord156, PRE_first_tail_x15_r0_body.fi156, PRE_first_tail_x15_r0_body.fii156⟩
theorem PRE_first_tail_x15_r0_body.cnshift156 (clean : Conv.NClean (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P156.NL) (cl : SSt (· < 6770) PRE_first_tail_x15_r0_body.cx0_156.mlx) : NShift PRE_first_tail_x15_r0_body.P156 6770 PRE_first_tail_x15_r0_body.kappa156 PRE_first_tail_x15_r0_body.cx0_156 PRE_first_tail_x15_r0_body.cx1_156 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot156 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost156 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0156 PRE_first_tail_x15_r0_body.ckn1156 PRE_first_tail_x15_r0_body.ckheap156 PRE_first_tail_x15_r0_body.ckpl156)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_156 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1379.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_156 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1379.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_156 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1379.ffi) = some PRE_first_tail_x15_r0_body.fxC_156
kernel_rfl PRE_first_tail_x15_r0_body.okrC_156 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1379.ffi) = some PRE_first_tail_x15_r0_body.krC_156
noncomputable def PRE_first_tail_x15_r0_body.fx0_156 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1381.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_156 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1381.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_156 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1381.ffi) = some PRE_first_tail_x15_r0_body.fx0_156
kernel_rfl PRE_first_tail_x15_r0_body.okr0_156 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1381.ffi) = some PRE_first_tail_x15_r0_body.kr0_156
noncomputable def PRE_first_tail_x15_r0_body.fx1_156 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1380.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_156 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1380.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_156 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1380.ffi) = some PRE_first_tail_x15_r0_body.fx1_156
kernel_rfl PRE_first_tail_x15_r0_body.okr1_156 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1380.ffi) = some PRE_first_tail_x15_r0_body.kr1_156
kernel_rfl PRE_first_tail_x15_r0_body.ff0156 : PRE_first_tail_x15_r0_body.fx0_156 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_156 (PRE_first_tail_x15_r0_body.clo156.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_156.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1156 : PRE_first_tail_x15_r0_body.fx1_156 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_156 (PRE_first_tail_x15_r0_body.cwS156.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_156.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck156 : freedLB PRE_first_tail_x15_r0_body.kappa156 PRE_first_tail_x15_r0_body.cx0_156.mlx PRE_first_tail_x15_r0_body.fx0_156 PRE_first_tail_x15_r0_body.fx1_156 PRE_first_tail_x15_r0_body.clo156 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0156 : PRE_first_tail_x15_r0_body.kr0_156.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_156.flags (PRE_first_tail_x15_r0_body.clo156.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_156.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0156 : PRE_first_tail_x15_r0_body.kr0_156.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_156.targs (PRE_first_tail_x15_r0_body.clo156.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_156.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1156 : PRE_first_tail_x15_r0_body.kr1_156.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_156.flags (PRE_first_tail_x15_r0_body.cwS156.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_156.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1156 : PRE_first_tail_x15_r0_body.kr1_156.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_156.targs (PRE_first_tail_x15_r0_body.cwS156.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_156.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck156 : krecLB PRE_first_tail_x15_r0_body.kappa156 6770 PRE_first_tail_x15_r0_body.cx0_156.mlx PRE_first_tail_x15_r0_body.kr0_156 PRE_first_tail_x15_r0_body.kr1_156 PRE_first_tail_x15_r0_body.clo156 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn156 : Nat.ble 6752 6770 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge156 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1380.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1381.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR156 : pendRegB PRE_first_tail_x15_r0_body.kappa156 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe156 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1380.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift156 (clean : Conv.NClean (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P156.NL) (cl : SSt (· < 6770) PRE_first_tail_x15_r0_body.cx0_156.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_156.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_156.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_156.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_156.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P156 6770 PRE_first_tail_x15_r0_body.kappa156 PRE_first_tail_x15_r0_body.s1381.ffi PRE_first_tail_x15_r0_body.s1380.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift156 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue156, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp156 t ht),
    PRE_first_tail_x15_r0_body.cbridge156,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1381.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1380.ffi) (PRE_first_tail_x15_r0_body.cfoot156 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_156 PRE_first_tail_x15_r0_body.ofx1_156 hobjC PRE_first_tail_x15_r0_body.ff0156 PRE_first_tail_x15_r0_body.ff1156 PRE_first_tail_x15_r0_body.ffck156,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1381.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1380.ffi) (PRE_first_tail_x15_r0_body.cfoot156 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_156 PRE_first_tail_x15_r0_body.okr1_156 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn156) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0156 PRE_first_tail_x15_r0_body.fkt0156 PRE_first_tail_x15_r0_body.fkf1156 PRE_first_tail_x15_r0_body.fkt1156 PRE_first_tail_x15_r0_body.fkck156,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0156 PRE_first_tail_x15_r0_body.cnh1156 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe156) PRE_first_tail_x15_r0_body.cpendR156⟩

end Host.Load.Run.Tpl
