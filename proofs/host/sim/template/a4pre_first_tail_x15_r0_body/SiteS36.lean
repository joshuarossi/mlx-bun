import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl36
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 36 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc36 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P36 : LoadP := PRE_first_tail_x15_r0_body.Pc36.raise 16016
kernel_rfl PRE_first_tail_x15_r0_body.craise36 : Nat.ble PRE_first_tail_x15_r0_body.Pc36.N0 16016 = true
theorem PRE_first_tail_x15_r0_body.raised36 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc36 PRE_first_tail_x15_r0_body.P36 :=
  .inr ⟨16016, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise36, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_36 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_36 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s362.ffi)
def PRE_first_tail_x15_r0_body.khinv36 : PTrie Nat := Stage.setAll PTrie.nil [(18950, 18924), (18928, 18925), (18951, 18926)]
def PRE_first_tail_x15_r0_body.kninv36 : PTrie Nat := Stage.setAll PTrie.nil [(15989, 15989), (15990, 15990), (15991, 15991), (15992, 15992), (15993, 15993), (15994, 15994), (15995, 15995), (15996, 15996), (15997, 15997), (15998, 15998), (15999, 15999), (16000, 16000), (16001, 16001), (16002, 16002), (16003, 16003), (16004, 16004), (16005, 16005), (16006, 16006), (16007, 16007), (16008, 16008), (16009, 16009), (16010, 16010), (16011, 16011), (16012, 16012), (16013, 16013), (16014, 16014), (16015, 16015)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS36 : List Nat := [18904, 18917, 18923, 18924, 18925, 18926, 18927, 18928, 18929, 18930, 18931, 18932, 18933, 18934, 18935, 18936, 18937, 18938, 18939, 18940, 18941, 18942, 18943, 18944, 18945, 18946, 18947, 18948, 18949, 18950, 18951]
def PRE_first_tail_x15_r0_body.cnS36 : List Nat := List.range' 15989 27
def PRE_first_tail_x15_r0_body.ciS36 : List Nat := [] ++ List.range' 15989 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh036 : PRE_first_tail_x15_r0_body.kd36.nh0 = PRE_first_tail_x15_r0_body.cx0_36.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh136 : PRE_first_tail_x15_r0_body.kd36.nh1 = PRE_first_tail_x15_r0_body.cx1_36.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn036 : PRE_first_tail_x15_r0_body.kd36.nn0 = PRE_first_tail_x15_r0_body.cx0_36.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn136 : PRE_first_tail_x15_r0_body.kd36.nn1 = PRE_first_tail_x15_r0_body.cx1_36.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo36 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P36.lo && Nat.ble PRE_first_tail_x15_r0_body.P36.lo PRE_first_tail_x15_r0_body.cx0_36.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P36.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P36.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt36 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_36.mlx.next PRE_first_tail_x15_r0_body.cx1_36.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_36.mlx.nnext PRE_first_tail_x15_r0_body.cx1_36.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband36 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P36.NL && Nat.ble PRE_first_tail_x15_r0_body.P36.NL PRE_first_tail_x15_r0_body.P36.N0 && Nat.ble PRE_first_tail_x15_r0_body.P36.N0 PRE_first_tail_x15_r0_body.cx0_36.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow36 : PRE_first_tail_x15_r0_body.kd36.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren36 : checkRenG PRE_first_tail_x15_r0_body.kd36.hnd PRE_first_tail_x15_r0_body.khinv36 (phB PRE_first_tail_x15_r0_body.cx0_36.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband36 : PRE_first_tail_x15_r0_body.kd36.checkBand PRE_first_tail_x15_r0_body.P36.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos36 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd36.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren36 : checkRenG PRE_first_tail_x15_r0_body.kd36.node PRE_first_tail_x15_r0_body.kninv36 (pnB PRE_first_tail_x15_r0_body.cx0_36.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow36 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd36.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P36.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd36.nodeF j) PRE_first_tail_x15_r0_body.cx1_36.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a36 : PRE_first_tail_x15_r0_body.cx0_36.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b36 : PRE_first_tail_x15_r0_body.cx0_36.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok136 : PRE_first_tail_x15_r0_body.cx1_36.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend36 : PRE_first_tail_x15_r0_body.cx1_36.mlx.pending = PRE_first_tail_x15_r0_body.cx0_36.mlx.pending.map PRE_first_tail_x15_r0_body.kappa36.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh36 : PRE_first_tail_x15_r0_body.cx1_36.mlx.errh = PRE_first_tail_x15_r0_body.cx0_36.mlx.errh.map PRE_first_tail_x15_r0_body.kappa36.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles36 : PRE_first_tail_x15_r0_body.cx1_36.mlx.files = PRE_first_tail_x15_r0_body.cx0_36.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch36 : PRE_first_tail_x15_r0_body.cx1_36.mlx.arch = PRE_first_tail_x15_r0_body.cx0_36.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes36 : PRE_first_tail_x15_r0_body.cx1_36.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_36.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired36 : PRE_first_tail_x15_r0_body.cx1_36.mlx.wired = PRE_first_tail_x15_r0_body.cx0_36.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost36 : PRE_first_tail_x15_r0_body.cx1_36.host = PRE_first_tail_x15_r0_body.cx0_36.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd36`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn036 : PRE_first_tail_x15_r0_body.kd36.n0 = 2703709
kernel_rfl PRE_first_tail_x15_r0_body.ckn136 : PRE_first_tail_x15_r0_body.kd36.n1 = 2704858
kernel_rfl PRE_first_tail_x15_r0_body.ckheap36 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd36.heap).all (fun x => Nat.ble 2703703 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl36 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd36.heap.get (2703703 + j) = nth? PRE_first_tail_x15_r0_body.pl36 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja36 : Nat.ble 2703703 2703703 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn36 : Nat.ble 1622 1622 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD36 : Nat.ble 2703703 PRE_first_tail_x15_r0_body.kd36.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn36 : Nat.ble 18924 PRE_first_tail_x15_r0_body.kd36.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn36 : Nat.ble 15989 PRE_first_tail_x15_r0_body.kd36.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb36 : Nat.ble 18924 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap36 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd36.heap).all (Nat.ble (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd36 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd36.hnd).all (Nat.ble (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode36 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd36.node).all (Nat.ble (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix36 : Conv.FixOld (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa36 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja36) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn36) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD36) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn36) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn36) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb36) PRE_first_tail_x15_r0_body.fheap36 PRE_first_tail_x15_r0_body.fhnd36 PRE_first_tail_x15_r0_body.fnode36
kernel_rfl PRE_first_tail_x15_r0_body.fcxn36 : (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn36 : (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle036 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_36.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_36.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk36 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd36.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A36 : PRE_first_tail_x15_r0_body.cx1_36.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS36.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_36.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O36 : PRE_first_tail_x15_r0_body.cx1_36.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS36.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_36.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N36 : PRE_first_tail_x15_r0_body.cx1_36.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS36.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_36.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I36 : PRE_first_tail_x15_r0_body.cx1_36.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS36.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_36.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd36 : (PRE_first_tail_x15_r0_body.clo36 ++ PRE_first_tail_x15_r0_body.cln36 ++ PRE_first_tail_x15_r0_body.cli36 ++ PRE_first_tail_x15_r0_body.cwS36 ++ PRE_first_tail_x15_r0_body.cnS36 ++ PRE_first_tail_x15_r0_body.ciS36).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW36 : PRE_first_tail_x15_r0_body.cwS36.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo36.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI36 : PRE_first_tail_x15_r0_body.ciS36.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli36.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN36 : PRE_first_tail_x15_r0_body.cnS36.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF36 : PRE_first_tail_x15_r0_body.cln36.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh36 : PRE_first_tail_x15_r0_body.clo36.all (handleOK PRE_first_tail_x15_r0_body.kappa36 PRE_first_tail_x15_r0_body.P36.lo PRE_first_tail_x15_r0_body.cx0_36.mlx PRE_first_tail_x15_r0_body.cx1_36.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo36 : PRE_first_tail_x15_r0_body.clo36.map (fun h => PRE_first_tail_x15_r0_body.cx1_36.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa36.handle h)) = PRE_first_tail_x15_r0_body.clo36.map (fun h => (PRE_first_tail_x15_r0_body.cx0_36.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa36.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok36 : PRE_first_tail_x15_r0_body.clo36.all (objOK PRE_first_tail_x15_r0_body.kappa36 PRE_first_tail_x15_r0_body.P36.NL PRE_first_tail_x15_r0_body.cx0_36.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd36 : PRE_first_tail_x15_r0_body.cln36.all (nodeOKF PRE_first_tail_x15_r0_body.kappa36 PRE_first_tail_x15_r0_body.P36 PRE_first_tail_x15_r0_body.cx0_36.mlx PRE_first_tail_x15_r0_body.cx1_36.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp36 : ((PRE_first_tail_x15_r0_body.cln36.filter (fullB PRE_first_tail_x15_r0_body.P36))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_36.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa36.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln36.filter (fullB PRE_first_tail_x15_r0_body.P36))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_36.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa36.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI36 : incrB PRE_first_tail_x15_r0_body.kd36.nodeF (List.range' 15989 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK36 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd36.node).all (fun k => Nat.ble 15989 k && Nat.blt k 16016) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL36 : (PRE_first_tail_x15_r0_body.cln36.filter (Nat.ble PRE_first_tail_x15_r0_body.P36.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd36.nodeF i) && (Nat.blt i 16016 || Nat.ble PRE_first_tail_x15_r0_body.kd36.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord36 : (PRE_first_tail_x15_r0_body.cln36.filter (Nat.ble PRE_first_tail_x15_r0_body.P36.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd36.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd36.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd36.nodeF j) (PRE_first_tail_x15_r0_body.kd36.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow36 PRE_first_tail_x15_r0_body.cnn136 PRE_first_tail_x15_r0_body.fnordI36 PRE_first_tail_x15_r0_body.fnordK36 PRE_first_tail_x15_r0_body.fnordL36
kernel_rfl PRE_first_tail_x15_r0_body.fi36 : PRE_first_tail_x15_r0_body.cli36.all (pnB PRE_first_tail_x15_r0_body.cx0_36.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii36 : PRE_first_tail_x15_r0_body.cli36.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_36.mlx.items.get (PRE_first_tail_x15_r0_body.kappa36.node k) = (PRE_first_tail_x15_r0_body.cx0_36.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa36.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot36 (clean : Conv.NClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P36.NL) (cl : SSt (· < 1640) PRE_first_tail_x15_r0_body.cx0_36.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P36 1640 PRE_first_tail_x15_r0_body.kappa36 PRE_first_tail_x15_r0_body.kd36 PRE_first_tail_x15_r0_body.khinv36 PRE_first_tail_x15_r0_body.kninv36 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx PRE_first_tail_x15_r0_body.cx0_36.mlx PRE_first_tail_x15_r0_body.cx1_36.mlx (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo36 PRE_first_tail_x15_r0_body.cln36 PRE_first_tail_x15_r0_body.cli36 PRE_first_tail_x15_r0_body.cwS36 PRE_first_tail_x15_r0_body.cnS36 PRE_first_tail_x15_r0_body.ciS36 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh036, PRE_first_tail_x15_r0_body.cnh136, PRE_first_tail_x15_r0_body.cnn036, PRE_first_tail_x15_r0_body.cnn136, PRE_first_tail_x15_r0_body.cplo36, PRE_first_tail_x15_r0_body.ccnt36, PRE_first_tail_x15_r0_body.cnband36, PRE_first_tail_x15_r0_body.chbelow36, PRE_first_tail_x15_r0_body.chren36, PRE_first_tail_x15_r0_body.cband36, PRE_first_tail_x15_r0_body.cnh1pos36, PRE_first_tail_x15_r0_body.cnren36, PRE_first_tail_x15_r0_body.cnlow36, PRE_first_tail_x15_r0_body.cabs0a36, PRE_first_tail_x15_r0_body.cabs0b36, PRE_first_tail_x15_r0_body.ctok136, PRE_first_tail_x15_r0_body.cpend36, PRE_first_tail_x15_r0_body.cerrh36, PRE_first_tail_x15_r0_body.cfiles36, PRE_first_tail_x15_r0_body.carch36, PRE_first_tail_x15_r0_body.csizes36, PRE_first_tail_x15_r0_body.cwired36, PRE_first_tail_x15_r0_body.cfix36, clean, PRE_first_tail_x15_r0_body.fcxn36, PRE_first_tail_x15_r0_body.fcnn36, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle036, PRE_first_tail_x15_r0_body.fnk36, PRE_first_tail_x15_r0_body.ckA36, PRE_first_tail_x15_r0_body.cobjsK36, PRE_first_tail_x15_r0_body.cnodesK36, PRE_first_tail_x15_r0_body.citemsK36, PRE_first_tail_x15_r0_body.f1A36, PRE_first_tail_x15_r0_body.f1O36, PRE_first_tail_x15_r0_body.f1N36, PRE_first_tail_x15_r0_body.f1I36, PRE_first_tail_x15_r0_body.fbd36, PRE_first_tail_x15_r0_body.fincW36, PRE_first_tail_x15_r0_body.fincI36, PRE_first_tail_x15_r0_body.fincN36, PRE_first_tail_x15_r0_body.flnF36, PRE_first_tail_x15_r0_body.fh36, PRE_first_tail_x15_r0_body.fo36, PRE_first_tail_x15_r0_body.fok36, PRE_first_tail_x15_r0_body.fnd36, PRE_first_tail_x15_r0_body.fp36, PRE_first_tail_x15_r0_body.fnord36, PRE_first_tail_x15_r0_body.fi36, PRE_first_tail_x15_r0_body.fii36⟩
theorem PRE_first_tail_x15_r0_body.cnshift36 (clean : Conv.NClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P36.NL) (cl : SSt (· < 1640) PRE_first_tail_x15_r0_body.cx0_36.mlx) : NShift PRE_first_tail_x15_r0_body.P36 1640 PRE_first_tail_x15_r0_body.kappa36 PRE_first_tail_x15_r0_body.cx0_36 PRE_first_tail_x15_r0_body.cx1_36 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot36 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost36 (compact_a_eq PRE_first_tail_x15_r0_body.ckn036 PRE_first_tail_x15_r0_body.ckn136 PRE_first_tail_x15_r0_body.ckheap36 PRE_first_tail_x15_r0_body.ckpl36)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_36 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s361.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_36 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s361.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_36 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s361.ffi) = some PRE_first_tail_x15_r0_body.fxC_36
kernel_rfl PRE_first_tail_x15_r0_body.okrC_36 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s361.ffi) = some PRE_first_tail_x15_r0_body.krC_36
noncomputable def PRE_first_tail_x15_r0_body.fx0_36 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s363.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_36 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s363.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_36 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s363.ffi) = some PRE_first_tail_x15_r0_body.fx0_36
kernel_rfl PRE_first_tail_x15_r0_body.okr0_36 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s363.ffi) = some PRE_first_tail_x15_r0_body.kr0_36
noncomputable def PRE_first_tail_x15_r0_body.fx1_36 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s362.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_36 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s362.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_36 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s362.ffi) = some PRE_first_tail_x15_r0_body.fx1_36
kernel_rfl PRE_first_tail_x15_r0_body.okr1_36 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s362.ffi) = some PRE_first_tail_x15_r0_body.kr1_36
kernel_rfl PRE_first_tail_x15_r0_body.ff036 : PRE_first_tail_x15_r0_body.fx0_36 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_36 (PRE_first_tail_x15_r0_body.clo36.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_36.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff136 : PRE_first_tail_x15_r0_body.fx1_36 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_36 (PRE_first_tail_x15_r0_body.cwS36.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_36.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck36 : freedLB PRE_first_tail_x15_r0_body.kappa36 PRE_first_tail_x15_r0_body.cx0_36.mlx PRE_first_tail_x15_r0_body.fx0_36 PRE_first_tail_x15_r0_body.fx1_36 PRE_first_tail_x15_r0_body.clo36 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf036 : PRE_first_tail_x15_r0_body.kr0_36.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_36.flags (PRE_first_tail_x15_r0_body.clo36.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_36.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt036 : PRE_first_tail_x15_r0_body.kr0_36.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_36.targs (PRE_first_tail_x15_r0_body.clo36.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_36.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf136 : PRE_first_tail_x15_r0_body.kr1_36.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_36.flags (PRE_first_tail_x15_r0_body.cwS36.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_36.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt136 : PRE_first_tail_x15_r0_body.kr1_36.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_36.targs (PRE_first_tail_x15_r0_body.cwS36.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_36.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck36 : krecLB PRE_first_tail_x15_r0_body.kappa36 1640 PRE_first_tail_x15_r0_body.cx0_36.mlx PRE_first_tail_x15_r0_body.kr0_36 PRE_first_tail_x15_r0_body.kr1_36 PRE_first_tail_x15_r0_body.clo36 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn36 : Nat.ble 1622 1640 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge36 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s362.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s363.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR36 : pendRegB PRE_first_tail_x15_r0_body.kappa36 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe36 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s362.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift36 (clean : Conv.NClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P36.NL) (cl : SSt (· < 1640) PRE_first_tail_x15_r0_body.cx0_36.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_36.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_36.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_36.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_36.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P36 1640 PRE_first_tail_x15_r0_body.kappa36 PRE_first_tail_x15_r0_body.s363.ffi PRE_first_tail_x15_r0_body.s362.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift36 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue36, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp36 t ht),
    PRE_first_tail_x15_r0_body.cbridge36,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s363.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s362.ffi) (PRE_first_tail_x15_r0_body.cfoot36 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_36 PRE_first_tail_x15_r0_body.ofx1_36 hobjC PRE_first_tail_x15_r0_body.ff036 PRE_first_tail_x15_r0_body.ff136 PRE_first_tail_x15_r0_body.ffck36,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s363.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s362.ffi) (PRE_first_tail_x15_r0_body.cfoot36 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_36 PRE_first_tail_x15_r0_body.okr1_36 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn36) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf036 PRE_first_tail_x15_r0_body.fkt036 PRE_first_tail_x15_r0_body.fkf136 PRE_first_tail_x15_r0_body.fkt136 PRE_first_tail_x15_r0_body.fkck36,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh036 PRE_first_tail_x15_r0_body.cnh136 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe36) PRE_first_tail_x15_r0_body.cpendR36⟩

end Host.Load.Run.Tpl
