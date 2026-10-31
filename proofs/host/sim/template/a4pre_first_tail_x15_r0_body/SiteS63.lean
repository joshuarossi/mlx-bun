import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl63
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 63 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc63 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P63 : LoadP := PRE_first_tail_x15_r0_body.Pc63.raise 16553
kernel_rfl PRE_first_tail_x15_r0_body.craise63 : Nat.ble PRE_first_tail_x15_r0_body.Pc63.N0 16553 = true
theorem PRE_first_tail_x15_r0_body.raised63 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc63 PRE_first_tail_x15_r0_body.P63 :=
  .inr ⟨16553, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise63, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_63 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_63 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s621.ffi)
def PRE_first_tail_x15_r0_body.khinv63 : PTrie Nat := Stage.setAll PTrie.nil [(19479, 19453), (19457, 19454), (19480, 19455)]
def PRE_first_tail_x15_r0_body.kninv63 : PTrie Nat := Stage.setAll PTrie.nil [(16526, 16526), (16527, 16527), (16528, 16528), (16529, 16529), (16530, 16530), (16531, 16531), (16532, 16532), (16533, 16533), (16534, 16534), (16535, 16535), (16536, 16536), (16537, 16537), (16538, 16538), (16539, 16539), (16540, 16540), (16541, 16541), (16542, 16542), (16543, 16543), (16544, 16544), (16545, 16545), (16546, 16546), (16547, 16547), (16548, 16548), (16549, 16549), (16550, 16550), (16551, 16551), (16552, 16552)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS63 : List Nat := [19433, 19446, 19452, 19453, 19454, 19455, 19456, 19457, 19458, 19459, 19460, 19461, 19462, 19463, 19464, 19465, 19466, 19467, 19468, 19469, 19470, 19471, 19472, 19473, 19474, 19475, 19476, 19477, 19478, 19479, 19480]
def PRE_first_tail_x15_r0_body.cnS63 : List Nat := List.range' 16526 27
def PRE_first_tail_x15_r0_body.ciS63 : List Nat := [] ++ List.range' 16526 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh063 : PRE_first_tail_x15_r0_body.kd63.nh0 = PRE_first_tail_x15_r0_body.cx0_63.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh163 : PRE_first_tail_x15_r0_body.kd63.nh1 = PRE_first_tail_x15_r0_body.cx1_63.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn063 : PRE_first_tail_x15_r0_body.kd63.nn0 = PRE_first_tail_x15_r0_body.cx0_63.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn163 : PRE_first_tail_x15_r0_body.kd63.nn1 = PRE_first_tail_x15_r0_body.cx1_63.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo63 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P63.lo && Nat.ble PRE_first_tail_x15_r0_body.P63.lo PRE_first_tail_x15_r0_body.cx0_63.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P63.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P63.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt63 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_63.mlx.next PRE_first_tail_x15_r0_body.cx1_63.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_63.mlx.nnext PRE_first_tail_x15_r0_body.cx1_63.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband63 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P63.NL && Nat.ble PRE_first_tail_x15_r0_body.P63.NL PRE_first_tail_x15_r0_body.P63.N0 && Nat.ble PRE_first_tail_x15_r0_body.P63.N0 PRE_first_tail_x15_r0_body.cx0_63.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow63 : PRE_first_tail_x15_r0_body.kd63.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren63 : checkRenG PRE_first_tail_x15_r0_body.kd63.hnd PRE_first_tail_x15_r0_body.khinv63 (phB PRE_first_tail_x15_r0_body.cx0_63.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband63 : PRE_first_tail_x15_r0_body.kd63.checkBand PRE_first_tail_x15_r0_body.P63.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos63 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd63.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren63 : checkRenG PRE_first_tail_x15_r0_body.kd63.node PRE_first_tail_x15_r0_body.kninv63 (pnB PRE_first_tail_x15_r0_body.cx0_63.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P63.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd63.nodeF j) PRE_first_tail_x15_r0_body.cx1_63.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a63 : PRE_first_tail_x15_r0_body.cx0_63.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b63 : PRE_first_tail_x15_r0_body.cx0_63.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok163 : PRE_first_tail_x15_r0_body.cx1_63.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.pending = PRE_first_tail_x15_r0_body.cx0_63.mlx.pending.map PRE_first_tail_x15_r0_body.kappa63.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.errh = PRE_first_tail_x15_r0_body.cx0_63.mlx.errh.map PRE_first_tail_x15_r0_body.kappa63.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.files = PRE_first_tail_x15_r0_body.cx0_63.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.arch = PRE_first_tail_x15_r0_body.cx0_63.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_63.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.wired = PRE_first_tail_x15_r0_body.cx0_63.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost63 : PRE_first_tail_x15_r0_body.cx1_63.host = PRE_first_tail_x15_r0_body.cx0_63.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd63`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn063 : PRE_first_tail_x15_r0_body.kd63.n0 = 2724809
kernel_rfl PRE_first_tail_x15_r0_body.ckn163 : PRE_first_tail_x15_r0_body.kd63.n1 = 2725958
kernel_rfl PRE_first_tail_x15_r0_body.ckheap63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.heap).all (fun x => Nat.ble 2724803 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl63 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd63.heap.get (2724803 + j) = nth? PRE_first_tail_x15_r0_body.pl63 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja63 : Nat.ble 2724803 2724803 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn63 : Nat.ble 2777 2777 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD63 : Nat.ble 2724803 PRE_first_tail_x15_r0_body.kd63.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn63 : Nat.ble 19453 PRE_first_tail_x15_r0_body.kd63.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn63 : Nat.ble 16526 PRE_first_tail_x15_r0_body.kd63.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb63 : Nat.ble 19453 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.heap).all (Nat.ble (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.hnd).all (Nat.ble (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.node).all (Nat.ble (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix63 : Conv.FixOld (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa63 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja63) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn63) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD63) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn63) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn63) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb63) PRE_first_tail_x15_r0_body.fheap63 PRE_first_tail_x15_r0_body.fhnd63 PRE_first_tail_x15_r0_body.fnode63
kernel_rfl PRE_first_tail_x15_r0_body.fcxn63 : (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn63 : (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle063 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_63.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_63.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS63.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_63.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS63.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_63.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS63.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_63.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS63.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_63.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd63 : (PRE_first_tail_x15_r0_body.clo63 ++ PRE_first_tail_x15_r0_body.cln63 ++ PRE_first_tail_x15_r0_body.cli63 ++ PRE_first_tail_x15_r0_body.cwS63 ++ PRE_first_tail_x15_r0_body.cnS63 ++ PRE_first_tail_x15_r0_body.ciS63).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW63 : PRE_first_tail_x15_r0_body.cwS63.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo63.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI63 : PRE_first_tail_x15_r0_body.ciS63.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli63.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN63 : PRE_first_tail_x15_r0_body.cnS63.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF63 : PRE_first_tail_x15_r0_body.cln63.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh63 : PRE_first_tail_x15_r0_body.clo63.all (handleOK PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.P63.lo PRE_first_tail_x15_r0_body.cx0_63.mlx PRE_first_tail_x15_r0_body.cx1_63.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo63 : PRE_first_tail_x15_r0_body.clo63.map (fun h => PRE_first_tail_x15_r0_body.cx1_63.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa63.handle h)) = PRE_first_tail_x15_r0_body.clo63.map (fun h => (PRE_first_tail_x15_r0_body.cx0_63.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa63.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok63 : PRE_first_tail_x15_r0_body.clo63.all (objOK PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.P63.NL PRE_first_tail_x15_r0_body.cx0_63.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd63 : PRE_first_tail_x15_r0_body.cln63.all (nodeOKF PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.P63 PRE_first_tail_x15_r0_body.cx0_63.mlx PRE_first_tail_x15_r0_body.cx1_63.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp63 : ((PRE_first_tail_x15_r0_body.cln63.filter (fullB PRE_first_tail_x15_r0_body.P63))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_63.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa63.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln63.filter (fullB PRE_first_tail_x15_r0_body.P63))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_63.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa63.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI63 : incrB PRE_first_tail_x15_r0_body.kd63.nodeF (List.range' 16526 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.node).all (fun k => Nat.ble 16526 k && Nat.blt k 16553) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL63 : (PRE_first_tail_x15_r0_body.cln63.filter (Nat.ble PRE_first_tail_x15_r0_body.P63.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd63.nodeF i) && (Nat.blt i 16553 || Nat.ble PRE_first_tail_x15_r0_body.kd63.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord63 : (PRE_first_tail_x15_r0_body.cln63.filter (Nat.ble PRE_first_tail_x15_r0_body.P63.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd63.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd63.nodeF j) (PRE_first_tail_x15_r0_body.kd63.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow63 PRE_first_tail_x15_r0_body.cnn163 PRE_first_tail_x15_r0_body.fnordI63 PRE_first_tail_x15_r0_body.fnordK63 PRE_first_tail_x15_r0_body.fnordL63
kernel_rfl PRE_first_tail_x15_r0_body.fi63 : PRE_first_tail_x15_r0_body.cli63.all (pnB PRE_first_tail_x15_r0_body.cx0_63.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii63 : PRE_first_tail_x15_r0_body.cli63.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_63.mlx.items.get (PRE_first_tail_x15_r0_body.kappa63.node k) = (PRE_first_tail_x15_r0_body.cx0_63.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa63.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot63 (clean : Conv.NClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P63.NL) (cl : SSt (· < 2795) PRE_first_tail_x15_r0_body.cx0_63.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P63 2795 PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.kd63 PRE_first_tail_x15_r0_body.khinv63 PRE_first_tail_x15_r0_body.kninv63 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx PRE_first_tail_x15_r0_body.cx0_63.mlx PRE_first_tail_x15_r0_body.cx1_63.mlx (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo63 PRE_first_tail_x15_r0_body.cln63 PRE_first_tail_x15_r0_body.cli63 PRE_first_tail_x15_r0_body.cwS63 PRE_first_tail_x15_r0_body.cnS63 PRE_first_tail_x15_r0_body.ciS63 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh063, PRE_first_tail_x15_r0_body.cnh163, PRE_first_tail_x15_r0_body.cnn063, PRE_first_tail_x15_r0_body.cnn163, PRE_first_tail_x15_r0_body.cplo63, PRE_first_tail_x15_r0_body.ccnt63, PRE_first_tail_x15_r0_body.cnband63, PRE_first_tail_x15_r0_body.chbelow63, PRE_first_tail_x15_r0_body.chren63, PRE_first_tail_x15_r0_body.cband63, PRE_first_tail_x15_r0_body.cnh1pos63, PRE_first_tail_x15_r0_body.cnren63, PRE_first_tail_x15_r0_body.cnlow63, PRE_first_tail_x15_r0_body.cabs0a63, PRE_first_tail_x15_r0_body.cabs0b63, PRE_first_tail_x15_r0_body.ctok163, PRE_first_tail_x15_r0_body.cpend63, PRE_first_tail_x15_r0_body.cerrh63, PRE_first_tail_x15_r0_body.cfiles63, PRE_first_tail_x15_r0_body.carch63, PRE_first_tail_x15_r0_body.csizes63, PRE_first_tail_x15_r0_body.cwired63, PRE_first_tail_x15_r0_body.cfix63, clean, PRE_first_tail_x15_r0_body.fcxn63, PRE_first_tail_x15_r0_body.fcnn63, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle063, PRE_first_tail_x15_r0_body.fnk63, PRE_first_tail_x15_r0_body.ckA63, PRE_first_tail_x15_r0_body.cobjsK63, PRE_first_tail_x15_r0_body.cnodesK63, PRE_first_tail_x15_r0_body.citemsK63, PRE_first_tail_x15_r0_body.f1A63, PRE_first_tail_x15_r0_body.f1O63, PRE_first_tail_x15_r0_body.f1N63, PRE_first_tail_x15_r0_body.f1I63, PRE_first_tail_x15_r0_body.fbd63, PRE_first_tail_x15_r0_body.fincW63, PRE_first_tail_x15_r0_body.fincI63, PRE_first_tail_x15_r0_body.fincN63, PRE_first_tail_x15_r0_body.flnF63, PRE_first_tail_x15_r0_body.fh63, PRE_first_tail_x15_r0_body.fo63, PRE_first_tail_x15_r0_body.fok63, PRE_first_tail_x15_r0_body.fnd63, PRE_first_tail_x15_r0_body.fp63, PRE_first_tail_x15_r0_body.fnord63, PRE_first_tail_x15_r0_body.fi63, PRE_first_tail_x15_r0_body.fii63⟩
theorem PRE_first_tail_x15_r0_body.cnshift63 (clean : Conv.NClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P63.NL) (cl : SSt (· < 2795) PRE_first_tail_x15_r0_body.cx0_63.mlx) : NShift PRE_first_tail_x15_r0_body.P63 2795 PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.cx0_63 PRE_first_tail_x15_r0_body.cx1_63 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot63 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost63 (compact_a_eq PRE_first_tail_x15_r0_body.ckn063 PRE_first_tail_x15_r0_body.ckn163 PRE_first_tail_x15_r0_body.ckheap63 PRE_first_tail_x15_r0_body.ckpl63)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_63 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s620.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_63 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s620.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_63 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s620.ffi) = some PRE_first_tail_x15_r0_body.fxC_63
kernel_rfl PRE_first_tail_x15_r0_body.okrC_63 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s620.ffi) = some PRE_first_tail_x15_r0_body.krC_63
noncomputable def PRE_first_tail_x15_r0_body.fx0_63 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s622.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_63 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s622.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_63 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s622.ffi) = some PRE_first_tail_x15_r0_body.fx0_63
kernel_rfl PRE_first_tail_x15_r0_body.okr0_63 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s622.ffi) = some PRE_first_tail_x15_r0_body.kr0_63
noncomputable def PRE_first_tail_x15_r0_body.fx1_63 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s621.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_63 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s621.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_63 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s621.ffi) = some PRE_first_tail_x15_r0_body.fx1_63
kernel_rfl PRE_first_tail_x15_r0_body.okr1_63 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s621.ffi) = some PRE_first_tail_x15_r0_body.kr1_63
kernel_rfl PRE_first_tail_x15_r0_body.ff063 : PRE_first_tail_x15_r0_body.fx0_63 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_63 (PRE_first_tail_x15_r0_body.clo63.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_63.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff163 : PRE_first_tail_x15_r0_body.fx1_63 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_63 (PRE_first_tail_x15_r0_body.cwS63.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_63.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck63 : freedLB PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.cx0_63.mlx PRE_first_tail_x15_r0_body.fx0_63 PRE_first_tail_x15_r0_body.fx1_63 PRE_first_tail_x15_r0_body.clo63 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf063 : PRE_first_tail_x15_r0_body.kr0_63.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_63.flags (PRE_first_tail_x15_r0_body.clo63.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_63.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt063 : PRE_first_tail_x15_r0_body.kr0_63.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_63.targs (PRE_first_tail_x15_r0_body.clo63.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_63.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf163 : PRE_first_tail_x15_r0_body.kr1_63.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_63.flags (PRE_first_tail_x15_r0_body.cwS63.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_63.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt163 : PRE_first_tail_x15_r0_body.kr1_63.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_63.targs (PRE_first_tail_x15_r0_body.cwS63.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_63.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck63 : krecLB PRE_first_tail_x15_r0_body.kappa63 2795 PRE_first_tail_x15_r0_body.cx0_63.mlx PRE_first_tail_x15_r0_body.kr0_63 PRE_first_tail_x15_r0_body.kr1_63 PRE_first_tail_x15_r0_body.clo63 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn63 : Nat.ble 2777 2795 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge63 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s621.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s622.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR63 : pendRegB PRE_first_tail_x15_r0_body.kappa63 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe63 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s621.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift63 (clean : Conv.NClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P63.NL) (cl : SSt (· < 2795) PRE_first_tail_x15_r0_body.cx0_63.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_63.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_63.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_63.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_63.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P63 2795 PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.s622.ffi PRE_first_tail_x15_r0_body.s621.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift63 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue63, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp63 t ht),
    PRE_first_tail_x15_r0_body.cbridge63,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s622.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s621.ffi) (PRE_first_tail_x15_r0_body.cfoot63 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_63 PRE_first_tail_x15_r0_body.ofx1_63 hobjC PRE_first_tail_x15_r0_body.ff063 PRE_first_tail_x15_r0_body.ff163 PRE_first_tail_x15_r0_body.ffck63,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s622.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s621.ffi) (PRE_first_tail_x15_r0_body.cfoot63 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_63 PRE_first_tail_x15_r0_body.okr1_63 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn63) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf063 PRE_first_tail_x15_r0_body.fkt063 PRE_first_tail_x15_r0_body.fkf163 PRE_first_tail_x15_r0_body.fkt163 PRE_first_tail_x15_r0_body.fkck63,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh063 PRE_first_tail_x15_r0_body.cnh163 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe63) PRE_first_tail_x15_r0_body.cpendR63⟩

end Host.Load.Run.Tpl
