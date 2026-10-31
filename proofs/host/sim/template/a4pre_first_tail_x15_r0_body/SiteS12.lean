import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl12
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 12 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc12 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P12 : LoadP := PRE_first_tail_x15_r0_body.Pc12.raise 15542
kernel_rfl PRE_first_tail_x15_r0_body.craise12 : Nat.ble PRE_first_tail_x15_r0_body.Pc12.N0 15542 = true
theorem PRE_first_tail_x15_r0_body.raised12 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc12 PRE_first_tail_x15_r0_body.P12 :=
  .inr ⟨15542, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise12, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_12 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_12 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s120.ffi)
def PRE_first_tail_x15_r0_body.khinv12 : PTrie Nat := Stage.setAll PTrie.nil [(18478, 18452), (18456, 18453), (18479, 18454)]
def PRE_first_tail_x15_r0_body.kninv12 : PTrie Nat := Stage.setAll PTrie.nil [(15515, 15515), (15516, 15516), (15517, 15517), (15518, 15518), (15519, 15519), (15520, 15520), (15521, 15521), (15522, 15522), (15523, 15523), (15524, 15524), (15525, 15525), (15526, 15526), (15527, 15527), (15528, 15528), (15529, 15529), (15530, 15530), (15531, 15531), (15532, 15532), (15533, 15533), (15534, 15534), (15535, 15535), (15536, 15536), (15537, 15537), (15538, 15538), (15539, 15539), (15540, 15540), (15541, 15541)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS12 : List Nat := [18432, 18445, 18451, 18452, 18453, 18454, 18455, 18456, 18457, 18458, 18459, 18460, 18461, 18462, 18463, 18464, 18465, 18466, 18467, 18468, 18469, 18470, 18471, 18472, 18473, 18474, 18475, 18476, 18477, 18478, 18479]
def PRE_first_tail_x15_r0_body.cnS12 : List Nat := List.range' 15515 27
def PRE_first_tail_x15_r0_body.ciS12 : List Nat := [] ++ List.range' 15515 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh012 : PRE_first_tail_x15_r0_body.kd12.nh0 = PRE_first_tail_x15_r0_body.cx0_12.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh112 : PRE_first_tail_x15_r0_body.kd12.nh1 = PRE_first_tail_x15_r0_body.cx1_12.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn012 : PRE_first_tail_x15_r0_body.kd12.nn0 = PRE_first_tail_x15_r0_body.cx0_12.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn112 : PRE_first_tail_x15_r0_body.kd12.nn1 = PRE_first_tail_x15_r0_body.cx1_12.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo12 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P12.lo && Nat.ble PRE_first_tail_x15_r0_body.P12.lo PRE_first_tail_x15_r0_body.cx0_12.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P12.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P12.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt12 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_12.mlx.next PRE_first_tail_x15_r0_body.cx1_12.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_12.mlx.nnext PRE_first_tail_x15_r0_body.cx1_12.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband12 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P12.NL && Nat.ble PRE_first_tail_x15_r0_body.P12.NL PRE_first_tail_x15_r0_body.P12.N0 && Nat.ble PRE_first_tail_x15_r0_body.P12.N0 PRE_first_tail_x15_r0_body.cx0_12.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow12 : PRE_first_tail_x15_r0_body.kd12.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren12 : checkRenG PRE_first_tail_x15_r0_body.kd12.hnd PRE_first_tail_x15_r0_body.khinv12 (phB PRE_first_tail_x15_r0_body.cx0_12.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband12 : PRE_first_tail_x15_r0_body.kd12.checkBand PRE_first_tail_x15_r0_body.P12.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos12 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd12.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren12 : checkRenG PRE_first_tail_x15_r0_body.kd12.node PRE_first_tail_x15_r0_body.kninv12 (pnB PRE_first_tail_x15_r0_body.cx0_12.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow12 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd12.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P12.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd12.nodeF j) PRE_first_tail_x15_r0_body.cx1_12.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a12 : PRE_first_tail_x15_r0_body.cx0_12.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b12 : PRE_first_tail_x15_r0_body.cx0_12.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok112 : PRE_first_tail_x15_r0_body.cx1_12.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend12 : PRE_first_tail_x15_r0_body.cx1_12.mlx.pending = PRE_first_tail_x15_r0_body.cx0_12.mlx.pending.map PRE_first_tail_x15_r0_body.kappa12.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh12 : PRE_first_tail_x15_r0_body.cx1_12.mlx.errh = PRE_first_tail_x15_r0_body.cx0_12.mlx.errh.map PRE_first_tail_x15_r0_body.kappa12.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles12 : PRE_first_tail_x15_r0_body.cx1_12.mlx.files = PRE_first_tail_x15_r0_body.cx0_12.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch12 : PRE_first_tail_x15_r0_body.cx1_12.mlx.arch = PRE_first_tail_x15_r0_body.cx0_12.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes12 : PRE_first_tail_x15_r0_body.cx1_12.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_12.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired12 : PRE_first_tail_x15_r0_body.cx1_12.mlx.wired = PRE_first_tail_x15_r0_body.cx0_12.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost12 : PRE_first_tail_x15_r0_body.cx1_12.host = PRE_first_tail_x15_r0_body.cx0_12.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd12`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn012 : PRE_first_tail_x15_r0_body.kd12.n0 = 2684881
kernel_rfl PRE_first_tail_x15_r0_body.ckn112 : PRE_first_tail_x15_r0_body.kd12.n1 = 2686030
kernel_rfl PRE_first_tail_x15_r0_body.ckheap12 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd12.heap).all (fun x => Nat.ble 2684875 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl12 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd12.heap.get (2684875 + j) = nth? PRE_first_tail_x15_r0_body.pl12 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja12 : Nat.ble 2684875 2684875 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn12 : Nat.ble 596 596 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD12 : Nat.ble 2684875 PRE_first_tail_x15_r0_body.kd12.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn12 : Nat.ble 18452 PRE_first_tail_x15_r0_body.kd12.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn12 : Nat.ble 15515 PRE_first_tail_x15_r0_body.kd12.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb12 : Nat.ble 18452 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap12 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd12.heap).all (Nat.ble (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd12 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd12.hnd).all (Nat.ble (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode12 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd12.node).all (Nat.ble (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix12 : Conv.FixOld (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa12 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja12) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn12) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD12) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn12) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn12) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb12) PRE_first_tail_x15_r0_body.fheap12 PRE_first_tail_x15_r0_body.fhnd12 PRE_first_tail_x15_r0_body.fnode12
kernel_rfl PRE_first_tail_x15_r0_body.fcxn12 : (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn12 : (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle012 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_12.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_12.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk12 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd12.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A12 : PRE_first_tail_x15_r0_body.cx1_12.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS12.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_12.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O12 : PRE_first_tail_x15_r0_body.cx1_12.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS12.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_12.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N12 : PRE_first_tail_x15_r0_body.cx1_12.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS12.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_12.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I12 : PRE_first_tail_x15_r0_body.cx1_12.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS12.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_12.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd12 : (PRE_first_tail_x15_r0_body.clo12 ++ PRE_first_tail_x15_r0_body.cln12 ++ PRE_first_tail_x15_r0_body.cli12 ++ PRE_first_tail_x15_r0_body.cwS12 ++ PRE_first_tail_x15_r0_body.cnS12 ++ PRE_first_tail_x15_r0_body.ciS12).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW12 : PRE_first_tail_x15_r0_body.cwS12.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo12.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI12 : PRE_first_tail_x15_r0_body.ciS12.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli12.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN12 : PRE_first_tail_x15_r0_body.cnS12.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF12 : PRE_first_tail_x15_r0_body.cln12.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh12 : PRE_first_tail_x15_r0_body.clo12.all (handleOK PRE_first_tail_x15_r0_body.kappa12 PRE_first_tail_x15_r0_body.P12.lo PRE_first_tail_x15_r0_body.cx0_12.mlx PRE_first_tail_x15_r0_body.cx1_12.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo12 : PRE_first_tail_x15_r0_body.clo12.map (fun h => PRE_first_tail_x15_r0_body.cx1_12.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa12.handle h)) = PRE_first_tail_x15_r0_body.clo12.map (fun h => (PRE_first_tail_x15_r0_body.cx0_12.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa12.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok12 : PRE_first_tail_x15_r0_body.clo12.all (objOK PRE_first_tail_x15_r0_body.kappa12 PRE_first_tail_x15_r0_body.P12.NL PRE_first_tail_x15_r0_body.cx0_12.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd12 : PRE_first_tail_x15_r0_body.cln12.all (nodeOKF PRE_first_tail_x15_r0_body.kappa12 PRE_first_tail_x15_r0_body.P12 PRE_first_tail_x15_r0_body.cx0_12.mlx PRE_first_tail_x15_r0_body.cx1_12.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp12 : ((PRE_first_tail_x15_r0_body.cln12.filter (fullB PRE_first_tail_x15_r0_body.P12))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_12.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa12.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln12.filter (fullB PRE_first_tail_x15_r0_body.P12))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_12.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa12.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI12 : incrB PRE_first_tail_x15_r0_body.kd12.nodeF (List.range' 15515 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK12 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd12.node).all (fun k => Nat.ble 15515 k && Nat.blt k 15542) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL12 : (PRE_first_tail_x15_r0_body.cln12.filter (Nat.ble PRE_first_tail_x15_r0_body.P12.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd12.nodeF i) && (Nat.blt i 15542 || Nat.ble PRE_first_tail_x15_r0_body.kd12.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord12 : (PRE_first_tail_x15_r0_body.cln12.filter (Nat.ble PRE_first_tail_x15_r0_body.P12.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd12.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd12.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd12.nodeF j) (PRE_first_tail_x15_r0_body.kd12.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow12 PRE_first_tail_x15_r0_body.cnn112 PRE_first_tail_x15_r0_body.fnordI12 PRE_first_tail_x15_r0_body.fnordK12 PRE_first_tail_x15_r0_body.fnordL12
kernel_rfl PRE_first_tail_x15_r0_body.fi12 : PRE_first_tail_x15_r0_body.cli12.all (pnB PRE_first_tail_x15_r0_body.cx0_12.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii12 : PRE_first_tail_x15_r0_body.cli12.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_12.mlx.items.get (PRE_first_tail_x15_r0_body.kappa12.node k) = (PRE_first_tail_x15_r0_body.cx0_12.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa12.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot12 (clean : Conv.NClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P12.NL) (cl : SSt (· < 614) PRE_first_tail_x15_r0_body.cx0_12.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P12 614 PRE_first_tail_x15_r0_body.kappa12 PRE_first_tail_x15_r0_body.kd12 PRE_first_tail_x15_r0_body.khinv12 PRE_first_tail_x15_r0_body.kninv12 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx PRE_first_tail_x15_r0_body.cx0_12.mlx PRE_first_tail_x15_r0_body.cx1_12.mlx (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo12 PRE_first_tail_x15_r0_body.cln12 PRE_first_tail_x15_r0_body.cli12 PRE_first_tail_x15_r0_body.cwS12 PRE_first_tail_x15_r0_body.cnS12 PRE_first_tail_x15_r0_body.ciS12 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh012, PRE_first_tail_x15_r0_body.cnh112, PRE_first_tail_x15_r0_body.cnn012, PRE_first_tail_x15_r0_body.cnn112, PRE_first_tail_x15_r0_body.cplo12, PRE_first_tail_x15_r0_body.ccnt12, PRE_first_tail_x15_r0_body.cnband12, PRE_first_tail_x15_r0_body.chbelow12, PRE_first_tail_x15_r0_body.chren12, PRE_first_tail_x15_r0_body.cband12, PRE_first_tail_x15_r0_body.cnh1pos12, PRE_first_tail_x15_r0_body.cnren12, PRE_first_tail_x15_r0_body.cnlow12, PRE_first_tail_x15_r0_body.cabs0a12, PRE_first_tail_x15_r0_body.cabs0b12, PRE_first_tail_x15_r0_body.ctok112, PRE_first_tail_x15_r0_body.cpend12, PRE_first_tail_x15_r0_body.cerrh12, PRE_first_tail_x15_r0_body.cfiles12, PRE_first_tail_x15_r0_body.carch12, PRE_first_tail_x15_r0_body.csizes12, PRE_first_tail_x15_r0_body.cwired12, PRE_first_tail_x15_r0_body.cfix12, clean, PRE_first_tail_x15_r0_body.fcxn12, PRE_first_tail_x15_r0_body.fcnn12, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle012, PRE_first_tail_x15_r0_body.fnk12, PRE_first_tail_x15_r0_body.ckA12, PRE_first_tail_x15_r0_body.cobjsK12, PRE_first_tail_x15_r0_body.cnodesK12, PRE_first_tail_x15_r0_body.citemsK12, PRE_first_tail_x15_r0_body.f1A12, PRE_first_tail_x15_r0_body.f1O12, PRE_first_tail_x15_r0_body.f1N12, PRE_first_tail_x15_r0_body.f1I12, PRE_first_tail_x15_r0_body.fbd12, PRE_first_tail_x15_r0_body.fincW12, PRE_first_tail_x15_r0_body.fincI12, PRE_first_tail_x15_r0_body.fincN12, PRE_first_tail_x15_r0_body.flnF12, PRE_first_tail_x15_r0_body.fh12, PRE_first_tail_x15_r0_body.fo12, PRE_first_tail_x15_r0_body.fok12, PRE_first_tail_x15_r0_body.fnd12, PRE_first_tail_x15_r0_body.fp12, PRE_first_tail_x15_r0_body.fnord12, PRE_first_tail_x15_r0_body.fi12, PRE_first_tail_x15_r0_body.fii12⟩
theorem PRE_first_tail_x15_r0_body.cnshift12 (clean : Conv.NClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P12.NL) (cl : SSt (· < 614) PRE_first_tail_x15_r0_body.cx0_12.mlx) : NShift PRE_first_tail_x15_r0_body.P12 614 PRE_first_tail_x15_r0_body.kappa12 PRE_first_tail_x15_r0_body.cx0_12 PRE_first_tail_x15_r0_body.cx1_12 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot12 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost12 (compact_a_eq PRE_first_tail_x15_r0_body.ckn012 PRE_first_tail_x15_r0_body.ckn112 PRE_first_tail_x15_r0_body.ckheap12 PRE_first_tail_x15_r0_body.ckpl12)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_12 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s119.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_12 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s119.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_12 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s119.ffi) = some PRE_first_tail_x15_r0_body.fxC_12
kernel_rfl PRE_first_tail_x15_r0_body.okrC_12 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s119.ffi) = some PRE_first_tail_x15_r0_body.krC_12
noncomputable def PRE_first_tail_x15_r0_body.fx0_12 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s121.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_12 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s121.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_12 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s121.ffi) = some PRE_first_tail_x15_r0_body.fx0_12
kernel_rfl PRE_first_tail_x15_r0_body.okr0_12 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s121.ffi) = some PRE_first_tail_x15_r0_body.kr0_12
noncomputable def PRE_first_tail_x15_r0_body.fx1_12 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s120.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_12 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s120.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_12 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s120.ffi) = some PRE_first_tail_x15_r0_body.fx1_12
kernel_rfl PRE_first_tail_x15_r0_body.okr1_12 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s120.ffi) = some PRE_first_tail_x15_r0_body.kr1_12
kernel_rfl PRE_first_tail_x15_r0_body.ff012 : PRE_first_tail_x15_r0_body.fx0_12 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_12 (PRE_first_tail_x15_r0_body.clo12.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_12.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff112 : PRE_first_tail_x15_r0_body.fx1_12 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_12 (PRE_first_tail_x15_r0_body.cwS12.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_12.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck12 : freedLB PRE_first_tail_x15_r0_body.kappa12 PRE_first_tail_x15_r0_body.cx0_12.mlx PRE_first_tail_x15_r0_body.fx0_12 PRE_first_tail_x15_r0_body.fx1_12 PRE_first_tail_x15_r0_body.clo12 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf012 : PRE_first_tail_x15_r0_body.kr0_12.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_12.flags (PRE_first_tail_x15_r0_body.clo12.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_12.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt012 : PRE_first_tail_x15_r0_body.kr0_12.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_12.targs (PRE_first_tail_x15_r0_body.clo12.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_12.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf112 : PRE_first_tail_x15_r0_body.kr1_12.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_12.flags (PRE_first_tail_x15_r0_body.cwS12.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_12.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt112 : PRE_first_tail_x15_r0_body.kr1_12.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_12.targs (PRE_first_tail_x15_r0_body.cwS12.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_12.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck12 : krecLB PRE_first_tail_x15_r0_body.kappa12 614 PRE_first_tail_x15_r0_body.cx0_12.mlx PRE_first_tail_x15_r0_body.kr0_12 PRE_first_tail_x15_r0_body.kr1_12 PRE_first_tail_x15_r0_body.clo12 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn12 : Nat.ble 596 614 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge12 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s120.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s121.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR12 : pendRegB PRE_first_tail_x15_r0_body.kappa12 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe12 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s120.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift12 (clean : Conv.NClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P12.NL) (cl : SSt (· < 614) PRE_first_tail_x15_r0_body.cx0_12.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_12.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_12.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_12.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_12.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P12 614 PRE_first_tail_x15_r0_body.kappa12 PRE_first_tail_x15_r0_body.s121.ffi PRE_first_tail_x15_r0_body.s120.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift12 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue12, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp12 t ht),
    PRE_first_tail_x15_r0_body.cbridge12,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s121.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s120.ffi) (PRE_first_tail_x15_r0_body.cfoot12 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_12 PRE_first_tail_x15_r0_body.ofx1_12 hobjC PRE_first_tail_x15_r0_body.ff012 PRE_first_tail_x15_r0_body.ff112 PRE_first_tail_x15_r0_body.ffck12,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s121.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s120.ffi) (PRE_first_tail_x15_r0_body.cfoot12 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_12 PRE_first_tail_x15_r0_body.okr1_12 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn12) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf012 PRE_first_tail_x15_r0_body.fkt012 PRE_first_tail_x15_r0_body.fkf112 PRE_first_tail_x15_r0_body.fkt112 PRE_first_tail_x15_r0_body.fkck12,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh012 PRE_first_tail_x15_r0_body.cnh112 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe12) PRE_first_tail_x15_r0_body.cpendR12⟩

end Host.Load.Run.Tpl
