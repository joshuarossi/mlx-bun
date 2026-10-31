import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl15
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 15 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc15 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P15 : LoadP := PRE_first_tail_x15_r0_body.Pc15.raise 15605
kernel_rfl PRE_first_tail_x15_r0_body.craise15 : Nat.ble PRE_first_tail_x15_r0_body.Pc15.N0 15605 = true
theorem PRE_first_tail_x15_r0_body.raised15 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc15 PRE_first_tail_x15_r0_body.P15 :=
  .inr ⟨15605, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise15, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_15 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s162.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_15 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s161.ffi)
def PRE_first_tail_x15_r0_body.khinv15 : PTrie Nat := Stage.setAll PTrie.nil [(18535, 18509), (18513, 18510), (18536, 18511)]
def PRE_first_tail_x15_r0_body.kninv15 : PTrie Nat := Stage.setAll PTrie.nil [(15578, 15578), (15579, 15579), (15580, 15580), (15581, 15581), (15582, 15582), (15583, 15583), (15584, 15584), (15585, 15585), (15586, 15586), (15587, 15587), (15588, 15588), (15589, 15589), (15590, 15590), (15591, 15591), (15592, 15592), (15593, 15593), (15594, 15594), (15595, 15595), (15596, 15596), (15597, 15597), (15598, 15598), (15599, 15599), (15600, 15600), (15601, 15601), (15602, 15602), (15603, 15603), (15604, 15604)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS15 : List Nat := [18489, 18502, 18508, 18509, 18510, 18511, 18512, 18513, 18514, 18515, 18516, 18517, 18518, 18519, 18520, 18521, 18522, 18523, 18524, 18525, 18526, 18527, 18528, 18529, 18530, 18531, 18532, 18533, 18534, 18535, 18536]
def PRE_first_tail_x15_r0_body.cnS15 : List Nat := List.range' 15578 27
def PRE_first_tail_x15_r0_body.ciS15 : List Nat := [] ++ List.range' 15578 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh015 : PRE_first_tail_x15_r0_body.kd15.nh0 = PRE_first_tail_x15_r0_body.cx0_15.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh115 : PRE_first_tail_x15_r0_body.kd15.nh1 = PRE_first_tail_x15_r0_body.cx1_15.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn015 : PRE_first_tail_x15_r0_body.kd15.nn0 = PRE_first_tail_x15_r0_body.cx0_15.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn115 : PRE_first_tail_x15_r0_body.kd15.nn1 = PRE_first_tail_x15_r0_body.cx1_15.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo15 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P15.lo && Nat.ble PRE_first_tail_x15_r0_body.P15.lo PRE_first_tail_x15_r0_body.cx0_15.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P15.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P15.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt15 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_15.mlx.next PRE_first_tail_x15_r0_body.cx1_15.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_15.mlx.nnext PRE_first_tail_x15_r0_body.cx1_15.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband15 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P15.NL && Nat.ble PRE_first_tail_x15_r0_body.P15.NL PRE_first_tail_x15_r0_body.P15.N0 && Nat.ble PRE_first_tail_x15_r0_body.P15.N0 PRE_first_tail_x15_r0_body.cx0_15.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow15 : PRE_first_tail_x15_r0_body.kd15.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren15 : checkRenG PRE_first_tail_x15_r0_body.kd15.hnd PRE_first_tail_x15_r0_body.khinv15 (phB PRE_first_tail_x15_r0_body.cx0_15.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband15 : PRE_first_tail_x15_r0_body.kd15.checkBand PRE_first_tail_x15_r0_body.P15.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos15 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd15.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren15 : checkRenG PRE_first_tail_x15_r0_body.kd15.node PRE_first_tail_x15_r0_body.kninv15 (pnB PRE_first_tail_x15_r0_body.cx0_15.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow15 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd15.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P15.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd15.nodeF j) PRE_first_tail_x15_r0_body.cx1_15.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a15 : PRE_first_tail_x15_r0_body.cx0_15.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b15 : PRE_first_tail_x15_r0_body.cx0_15.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok115 : PRE_first_tail_x15_r0_body.cx1_15.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend15 : PRE_first_tail_x15_r0_body.cx1_15.mlx.pending = PRE_first_tail_x15_r0_body.cx0_15.mlx.pending.map PRE_first_tail_x15_r0_body.kappa15.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh15 : PRE_first_tail_x15_r0_body.cx1_15.mlx.errh = PRE_first_tail_x15_r0_body.cx0_15.mlx.errh.map PRE_first_tail_x15_r0_body.kappa15.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles15 : PRE_first_tail_x15_r0_body.cx1_15.mlx.files = PRE_first_tail_x15_r0_body.cx0_15.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch15 : PRE_first_tail_x15_r0_body.cx1_15.mlx.arch = PRE_first_tail_x15_r0_body.cx0_15.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes15 : PRE_first_tail_x15_r0_body.cx1_15.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_15.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired15 : PRE_first_tail_x15_r0_body.cx1_15.mlx.wired = PRE_first_tail_x15_r0_body.cx0_15.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost15 : PRE_first_tail_x15_r0_body.cx1_15.host = PRE_first_tail_x15_r0_body.cx0_15.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd15`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn015 : PRE_first_tail_x15_r0_body.kd15.n0 = 2687137
kernel_rfl PRE_first_tail_x15_r0_body.ckn115 : PRE_first_tail_x15_r0_body.kd15.n1 = 2688286
kernel_rfl PRE_first_tail_x15_r0_body.ckheap15 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd15.heap).all (fun x => Nat.ble 2687131 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl15 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd15.heap.get (2687131 + j) = nth? PRE_first_tail_x15_r0_body.pl15 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja15 : Nat.ble 2687131 2687131 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn15 : Nat.ble 725 725 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD15 : Nat.ble 2687131 PRE_first_tail_x15_r0_body.kd15.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn15 : Nat.ble 18509 PRE_first_tail_x15_r0_body.kd15.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn15 : Nat.ble 15578 PRE_first_tail_x15_r0_body.kd15.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb15 : Nat.ble 18509 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap15 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd15.heap).all (Nat.ble (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd15 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd15.hnd).all (Nat.ble (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode15 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd15.node).all (Nat.ble (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix15 : Conv.FixOld (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa15 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja15) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn15) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD15) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn15) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn15) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb15) PRE_first_tail_x15_r0_body.fheap15 PRE_first_tail_x15_r0_body.fhnd15 PRE_first_tail_x15_r0_body.fnode15
kernel_rfl PRE_first_tail_x15_r0_body.fcxn15 : (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn15 : (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle015 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_15.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_15.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk15 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd15.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A15 : PRE_first_tail_x15_r0_body.cx1_15.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS15.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_15.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O15 : PRE_first_tail_x15_r0_body.cx1_15.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS15.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_15.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N15 : PRE_first_tail_x15_r0_body.cx1_15.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS15.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_15.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I15 : PRE_first_tail_x15_r0_body.cx1_15.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS15.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_15.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd15 : (PRE_first_tail_x15_r0_body.clo15 ++ PRE_first_tail_x15_r0_body.cln15 ++ PRE_first_tail_x15_r0_body.cli15 ++ PRE_first_tail_x15_r0_body.cwS15 ++ PRE_first_tail_x15_r0_body.cnS15 ++ PRE_first_tail_x15_r0_body.ciS15).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW15 : PRE_first_tail_x15_r0_body.cwS15.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo15.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI15 : PRE_first_tail_x15_r0_body.ciS15.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli15.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN15 : PRE_first_tail_x15_r0_body.cnS15.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF15 : PRE_first_tail_x15_r0_body.cln15.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh15 : PRE_first_tail_x15_r0_body.clo15.all (handleOK PRE_first_tail_x15_r0_body.kappa15 PRE_first_tail_x15_r0_body.P15.lo PRE_first_tail_x15_r0_body.cx0_15.mlx PRE_first_tail_x15_r0_body.cx1_15.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo15 : PRE_first_tail_x15_r0_body.clo15.map (fun h => PRE_first_tail_x15_r0_body.cx1_15.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa15.handle h)) = PRE_first_tail_x15_r0_body.clo15.map (fun h => (PRE_first_tail_x15_r0_body.cx0_15.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa15.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok15 : PRE_first_tail_x15_r0_body.clo15.all (objOK PRE_first_tail_x15_r0_body.kappa15 PRE_first_tail_x15_r0_body.P15.NL PRE_first_tail_x15_r0_body.cx0_15.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd15 : PRE_first_tail_x15_r0_body.cln15.all (nodeOKF PRE_first_tail_x15_r0_body.kappa15 PRE_first_tail_x15_r0_body.P15 PRE_first_tail_x15_r0_body.cx0_15.mlx PRE_first_tail_x15_r0_body.cx1_15.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp15 : ((PRE_first_tail_x15_r0_body.cln15.filter (fullB PRE_first_tail_x15_r0_body.P15))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_15.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa15.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln15.filter (fullB PRE_first_tail_x15_r0_body.P15))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_15.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa15.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI15 : incrB PRE_first_tail_x15_r0_body.kd15.nodeF (List.range' 15578 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK15 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd15.node).all (fun k => Nat.ble 15578 k && Nat.blt k 15605) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL15 : (PRE_first_tail_x15_r0_body.cln15.filter (Nat.ble PRE_first_tail_x15_r0_body.P15.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd15.nodeF i) && (Nat.blt i 15605 || Nat.ble PRE_first_tail_x15_r0_body.kd15.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord15 : (PRE_first_tail_x15_r0_body.cln15.filter (Nat.ble PRE_first_tail_x15_r0_body.P15.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd15.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd15.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd15.nodeF j) (PRE_first_tail_x15_r0_body.kd15.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow15 PRE_first_tail_x15_r0_body.cnn115 PRE_first_tail_x15_r0_body.fnordI15 PRE_first_tail_x15_r0_body.fnordK15 PRE_first_tail_x15_r0_body.fnordL15
kernel_rfl PRE_first_tail_x15_r0_body.fi15 : PRE_first_tail_x15_r0_body.cli15.all (pnB PRE_first_tail_x15_r0_body.cx0_15.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii15 : PRE_first_tail_x15_r0_body.cli15.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_15.mlx.items.get (PRE_first_tail_x15_r0_body.kappa15.node k) = (PRE_first_tail_x15_r0_body.cx0_15.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa15.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot15 (clean : Conv.NClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P15.NL) (cl : SSt (· < 743) PRE_first_tail_x15_r0_body.cx0_15.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P15 743 PRE_first_tail_x15_r0_body.kappa15 PRE_first_tail_x15_r0_body.kd15 PRE_first_tail_x15_r0_body.khinv15 PRE_first_tail_x15_r0_body.kninv15 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx PRE_first_tail_x15_r0_body.cx0_15.mlx PRE_first_tail_x15_r0_body.cx1_15.mlx (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo15 PRE_first_tail_x15_r0_body.cln15 PRE_first_tail_x15_r0_body.cli15 PRE_first_tail_x15_r0_body.cwS15 PRE_first_tail_x15_r0_body.cnS15 PRE_first_tail_x15_r0_body.ciS15 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh015, PRE_first_tail_x15_r0_body.cnh115, PRE_first_tail_x15_r0_body.cnn015, PRE_first_tail_x15_r0_body.cnn115, PRE_first_tail_x15_r0_body.cplo15, PRE_first_tail_x15_r0_body.ccnt15, PRE_first_tail_x15_r0_body.cnband15, PRE_first_tail_x15_r0_body.chbelow15, PRE_first_tail_x15_r0_body.chren15, PRE_first_tail_x15_r0_body.cband15, PRE_first_tail_x15_r0_body.cnh1pos15, PRE_first_tail_x15_r0_body.cnren15, PRE_first_tail_x15_r0_body.cnlow15, PRE_first_tail_x15_r0_body.cabs0a15, PRE_first_tail_x15_r0_body.cabs0b15, PRE_first_tail_x15_r0_body.ctok115, PRE_first_tail_x15_r0_body.cpend15, PRE_first_tail_x15_r0_body.cerrh15, PRE_first_tail_x15_r0_body.cfiles15, PRE_first_tail_x15_r0_body.carch15, PRE_first_tail_x15_r0_body.csizes15, PRE_first_tail_x15_r0_body.cwired15, PRE_first_tail_x15_r0_body.cfix15, clean, PRE_first_tail_x15_r0_body.fcxn15, PRE_first_tail_x15_r0_body.fcnn15, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle015, PRE_first_tail_x15_r0_body.fnk15, PRE_first_tail_x15_r0_body.ckA15, PRE_first_tail_x15_r0_body.cobjsK15, PRE_first_tail_x15_r0_body.cnodesK15, PRE_first_tail_x15_r0_body.citemsK15, PRE_first_tail_x15_r0_body.f1A15, PRE_first_tail_x15_r0_body.f1O15, PRE_first_tail_x15_r0_body.f1N15, PRE_first_tail_x15_r0_body.f1I15, PRE_first_tail_x15_r0_body.fbd15, PRE_first_tail_x15_r0_body.fincW15, PRE_first_tail_x15_r0_body.fincI15, PRE_first_tail_x15_r0_body.fincN15, PRE_first_tail_x15_r0_body.flnF15, PRE_first_tail_x15_r0_body.fh15, PRE_first_tail_x15_r0_body.fo15, PRE_first_tail_x15_r0_body.fok15, PRE_first_tail_x15_r0_body.fnd15, PRE_first_tail_x15_r0_body.fp15, PRE_first_tail_x15_r0_body.fnord15, PRE_first_tail_x15_r0_body.fi15, PRE_first_tail_x15_r0_body.fii15⟩
theorem PRE_first_tail_x15_r0_body.cnshift15 (clean : Conv.NClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P15.NL) (cl : SSt (· < 743) PRE_first_tail_x15_r0_body.cx0_15.mlx) : NShift PRE_first_tail_x15_r0_body.P15 743 PRE_first_tail_x15_r0_body.kappa15 PRE_first_tail_x15_r0_body.cx0_15 PRE_first_tail_x15_r0_body.cx1_15 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot15 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost15 (compact_a_eq PRE_first_tail_x15_r0_body.ckn015 PRE_first_tail_x15_r0_body.ckn115 PRE_first_tail_x15_r0_body.ckheap15 PRE_first_tail_x15_r0_body.ckpl15)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_15 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s160.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_15 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s160.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_15 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s160.ffi) = some PRE_first_tail_x15_r0_body.fxC_15
kernel_rfl PRE_first_tail_x15_r0_body.okrC_15 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s160.ffi) = some PRE_first_tail_x15_r0_body.krC_15
noncomputable def PRE_first_tail_x15_r0_body.fx0_15 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s162.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_15 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s162.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_15 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s162.ffi) = some PRE_first_tail_x15_r0_body.fx0_15
kernel_rfl PRE_first_tail_x15_r0_body.okr0_15 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s162.ffi) = some PRE_first_tail_x15_r0_body.kr0_15
noncomputable def PRE_first_tail_x15_r0_body.fx1_15 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s161.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_15 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s161.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_15 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s161.ffi) = some PRE_first_tail_x15_r0_body.fx1_15
kernel_rfl PRE_first_tail_x15_r0_body.okr1_15 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s161.ffi) = some PRE_first_tail_x15_r0_body.kr1_15
kernel_rfl PRE_first_tail_x15_r0_body.ff015 : PRE_first_tail_x15_r0_body.fx0_15 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_15 (PRE_first_tail_x15_r0_body.clo15.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_15.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff115 : PRE_first_tail_x15_r0_body.fx1_15 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_15 (PRE_first_tail_x15_r0_body.cwS15.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_15.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck15 : freedLB PRE_first_tail_x15_r0_body.kappa15 PRE_first_tail_x15_r0_body.cx0_15.mlx PRE_first_tail_x15_r0_body.fx0_15 PRE_first_tail_x15_r0_body.fx1_15 PRE_first_tail_x15_r0_body.clo15 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf015 : PRE_first_tail_x15_r0_body.kr0_15.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_15.flags (PRE_first_tail_x15_r0_body.clo15.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_15.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt015 : PRE_first_tail_x15_r0_body.kr0_15.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_15.targs (PRE_first_tail_x15_r0_body.clo15.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_15.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf115 : PRE_first_tail_x15_r0_body.kr1_15.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_15.flags (PRE_first_tail_x15_r0_body.cwS15.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_15.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt115 : PRE_first_tail_x15_r0_body.kr1_15.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_15.targs (PRE_first_tail_x15_r0_body.cwS15.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_15.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck15 : krecLB PRE_first_tail_x15_r0_body.kappa15 743 PRE_first_tail_x15_r0_body.cx0_15.mlx PRE_first_tail_x15_r0_body.kr0_15 PRE_first_tail_x15_r0_body.kr1_15 PRE_first_tail_x15_r0_body.clo15 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn15 : Nat.ble 725 743 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge15 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s161.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s162.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR15 : pendRegB PRE_first_tail_x15_r0_body.kappa15 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s162.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe15 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s162.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s161.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift15 (clean : Conv.NClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P15.NL) (cl : SSt (· < 743) PRE_first_tail_x15_r0_body.cx0_15.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_15.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_15.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_15.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_15.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P15 743 PRE_first_tail_x15_r0_body.kappa15 PRE_first_tail_x15_r0_body.s162.ffi PRE_first_tail_x15_r0_body.s161.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift15 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue15, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp15 t ht),
    PRE_first_tail_x15_r0_body.cbridge15,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s162.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s161.ffi) (PRE_first_tail_x15_r0_body.cfoot15 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_15 PRE_first_tail_x15_r0_body.ofx1_15 hobjC PRE_first_tail_x15_r0_body.ff015 PRE_first_tail_x15_r0_body.ff115 PRE_first_tail_x15_r0_body.ffck15,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s162.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s161.ffi) (PRE_first_tail_x15_r0_body.cfoot15 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_15 PRE_first_tail_x15_r0_body.okr1_15 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn15) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf015 PRE_first_tail_x15_r0_body.fkt015 PRE_first_tail_x15_r0_body.fkf115 PRE_first_tail_x15_r0_body.fkt115 PRE_first_tail_x15_r0_body.fkck15,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh015 PRE_first_tail_x15_r0_body.cnh115 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe15) PRE_first_tail_x15_r0_body.cpendR15⟩

end Host.Load.Run.Tpl
