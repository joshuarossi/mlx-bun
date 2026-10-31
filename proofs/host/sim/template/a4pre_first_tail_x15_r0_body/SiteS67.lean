import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl67
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 67 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc67 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P67 : LoadP := PRE_first_tail_x15_r0_body.Pc67.raise 16629
kernel_rfl PRE_first_tail_x15_r0_body.craise67 : Nat.ble PRE_first_tail_x15_r0_body.Pc67.N0 16629 = true
theorem PRE_first_tail_x15_r0_body.raised67 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc67 PRE_first_tail_x15_r0_body.P67 :=
  .inr ⟨16629, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise67, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_67 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_67 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi)
def PRE_first_tail_x15_r0_body.khinv67 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv67 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS67 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS67 : List Nat := List.range' 16629 0
def PRE_first_tail_x15_r0_body.ciS67 : List Nat := [] ++ List.range' 16629 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh067 : PRE_first_tail_x15_r0_body.kd67.nh0 = PRE_first_tail_x15_r0_body.cx0_67.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh167 : PRE_first_tail_x15_r0_body.kd67.nh1 = PRE_first_tail_x15_r0_body.cx1_67.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn067 : PRE_first_tail_x15_r0_body.kd67.nn0 = PRE_first_tail_x15_r0_body.cx0_67.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn167 : PRE_first_tail_x15_r0_body.kd67.nn1 = PRE_first_tail_x15_r0_body.cx1_67.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo67 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P67.lo && Nat.ble PRE_first_tail_x15_r0_body.P67.lo PRE_first_tail_x15_r0_body.cx0_67.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P67.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P67.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt67 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_67.mlx.next PRE_first_tail_x15_r0_body.cx1_67.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_67.mlx.nnext PRE_first_tail_x15_r0_body.cx1_67.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband67 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P67.NL && Nat.ble PRE_first_tail_x15_r0_body.P67.NL PRE_first_tail_x15_r0_body.P67.N0 && Nat.ble PRE_first_tail_x15_r0_body.P67.N0 PRE_first_tail_x15_r0_body.cx0_67.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow67 : PRE_first_tail_x15_r0_body.kd67.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren67 : checkRenG PRE_first_tail_x15_r0_body.kd67.hnd PRE_first_tail_x15_r0_body.khinv67 (phB PRE_first_tail_x15_r0_body.cx0_67.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband67 : PRE_first_tail_x15_r0_body.kd67.checkBand PRE_first_tail_x15_r0_body.P67.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos67 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd67.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren67 : checkRenG PRE_first_tail_x15_r0_body.kd67.node PRE_first_tail_x15_r0_body.kninv67 (pnB PRE_first_tail_x15_r0_body.cx0_67.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P67.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd67.nodeF j) PRE_first_tail_x15_r0_body.cx1_67.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a67 : PRE_first_tail_x15_r0_body.cx0_67.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b67 : PRE_first_tail_x15_r0_body.cx0_67.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok167 : PRE_first_tail_x15_r0_body.cx1_67.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.pending = PRE_first_tail_x15_r0_body.cx0_67.mlx.pending.map PRE_first_tail_x15_r0_body.kappa67.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.errh = PRE_first_tail_x15_r0_body.cx0_67.mlx.errh.map PRE_first_tail_x15_r0_body.kappa67.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.files = PRE_first_tail_x15_r0_body.cx0_67.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.arch = PRE_first_tail_x15_r0_body.cx0_67.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_67.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.wired = PRE_first_tail_x15_r0_body.cx0_67.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost67 : PRE_first_tail_x15_r0_body.cx1_67.host = PRE_first_tail_x15_r0_body.cx0_67.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd67`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn067 : PRE_first_tail_x15_r0_body.kd67.n0 = 2727555
kernel_rfl PRE_first_tail_x15_r0_body.ckn167 : PRE_first_tail_x15_r0_body.kd67.n1 = 2727557
kernel_rfl PRE_first_tail_x15_r0_body.ckheap67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.heap).all (fun x => Nat.ble 2727555 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl67 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd67.heap.get (2727555 + j) = nth? PRE_first_tail_x15_r0_body.pl67 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja67 : Nat.ble 2727555 2727555 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn67 : Nat.ble 2945 2945 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD67 : Nat.ble 2727555 PRE_first_tail_x15_r0_body.kd67.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn67 : Nat.ble 19526 PRE_first_tail_x15_r0_body.kd67.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn67 : Nat.ble 16629 PRE_first_tail_x15_r0_body.kd67.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb67 : Nat.ble 19526 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.heap).all (Nat.ble (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.hnd).all (Nat.ble (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.node).all (Nat.ble (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix67 : Conv.FixOld (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa67 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja67) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn67) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD67) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn67) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn67) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb67) PRE_first_tail_x15_r0_body.fheap67 PRE_first_tail_x15_r0_body.fhnd67 PRE_first_tail_x15_r0_body.fnode67
kernel_rfl PRE_first_tail_x15_r0_body.fcxn67 : (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn67 : (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle067 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_67.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_67.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS67.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_67.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS67.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_67.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS67.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_67.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS67.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_67.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd67 : (PRE_first_tail_x15_r0_body.clo67 ++ PRE_first_tail_x15_r0_body.cln67 ++ PRE_first_tail_x15_r0_body.cli67 ++ PRE_first_tail_x15_r0_body.cwS67 ++ PRE_first_tail_x15_r0_body.cnS67 ++ PRE_first_tail_x15_r0_body.ciS67).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW67 : PRE_first_tail_x15_r0_body.cwS67.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo67.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI67 : PRE_first_tail_x15_r0_body.ciS67.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli67.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN67 : PRE_first_tail_x15_r0_body.cnS67.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF67 : PRE_first_tail_x15_r0_body.cln67.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh67 : PRE_first_tail_x15_r0_body.clo67.all (handleOK PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.P67.lo PRE_first_tail_x15_r0_body.cx0_67.mlx PRE_first_tail_x15_r0_body.cx1_67.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo67 : PRE_first_tail_x15_r0_body.clo67.map (fun h => PRE_first_tail_x15_r0_body.cx1_67.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa67.handle h)) = PRE_first_tail_x15_r0_body.clo67.map (fun h => (PRE_first_tail_x15_r0_body.cx0_67.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa67.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok67 : PRE_first_tail_x15_r0_body.clo67.all (objOK PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.P67.NL PRE_first_tail_x15_r0_body.cx0_67.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd67 : PRE_first_tail_x15_r0_body.cln67.all (nodeOKF PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.P67 PRE_first_tail_x15_r0_body.cx0_67.mlx PRE_first_tail_x15_r0_body.cx1_67.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp67 : ((PRE_first_tail_x15_r0_body.cln67.filter (fullB PRE_first_tail_x15_r0_body.P67))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_67.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa67.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln67.filter (fullB PRE_first_tail_x15_r0_body.P67))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_67.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa67.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI67 : incrB PRE_first_tail_x15_r0_body.kd67.nodeF (List.range' 16629 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.node).all (fun k => Nat.ble 16629 k && Nat.blt k 16629) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL67 : (PRE_first_tail_x15_r0_body.cln67.filter (Nat.ble PRE_first_tail_x15_r0_body.P67.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd67.nodeF i) && (Nat.blt i 16629 || Nat.ble PRE_first_tail_x15_r0_body.kd67.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord67 : (PRE_first_tail_x15_r0_body.cln67.filter (Nat.ble PRE_first_tail_x15_r0_body.P67.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd67.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd67.nodeF j) (PRE_first_tail_x15_r0_body.kd67.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow67 PRE_first_tail_x15_r0_body.cnn167 PRE_first_tail_x15_r0_body.fnordI67 PRE_first_tail_x15_r0_body.fnordK67 PRE_first_tail_x15_r0_body.fnordL67
kernel_rfl PRE_first_tail_x15_r0_body.fi67 : PRE_first_tail_x15_r0_body.cli67.all (pnB PRE_first_tail_x15_r0_body.cx0_67.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii67 : PRE_first_tail_x15_r0_body.cli67.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_67.mlx.items.get (PRE_first_tail_x15_r0_body.kappa67.node k) = (PRE_first_tail_x15_r0_body.cx0_67.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa67.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot67 (clean : Conv.NClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P67.NL) (cl : SSt (· < 2945) PRE_first_tail_x15_r0_body.cx0_67.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P67 2945 PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.kd67 PRE_first_tail_x15_r0_body.khinv67 PRE_first_tail_x15_r0_body.kninv67 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx PRE_first_tail_x15_r0_body.cx0_67.mlx PRE_first_tail_x15_r0_body.cx1_67.mlx (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo67 PRE_first_tail_x15_r0_body.cln67 PRE_first_tail_x15_r0_body.cli67 PRE_first_tail_x15_r0_body.cwS67 PRE_first_tail_x15_r0_body.cnS67 PRE_first_tail_x15_r0_body.ciS67 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh067, PRE_first_tail_x15_r0_body.cnh167, PRE_first_tail_x15_r0_body.cnn067, PRE_first_tail_x15_r0_body.cnn167, PRE_first_tail_x15_r0_body.cplo67, PRE_first_tail_x15_r0_body.ccnt67, PRE_first_tail_x15_r0_body.cnband67, PRE_first_tail_x15_r0_body.chbelow67, PRE_first_tail_x15_r0_body.chren67, PRE_first_tail_x15_r0_body.cband67, PRE_first_tail_x15_r0_body.cnh1pos67, PRE_first_tail_x15_r0_body.cnren67, PRE_first_tail_x15_r0_body.cnlow67, PRE_first_tail_x15_r0_body.cabs0a67, PRE_first_tail_x15_r0_body.cabs0b67, PRE_first_tail_x15_r0_body.ctok167, PRE_first_tail_x15_r0_body.cpend67, PRE_first_tail_x15_r0_body.cerrh67, PRE_first_tail_x15_r0_body.cfiles67, PRE_first_tail_x15_r0_body.carch67, PRE_first_tail_x15_r0_body.csizes67, PRE_first_tail_x15_r0_body.cwired67, PRE_first_tail_x15_r0_body.cfix67, clean, PRE_first_tail_x15_r0_body.fcxn67, PRE_first_tail_x15_r0_body.fcnn67, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle067, PRE_first_tail_x15_r0_body.fnk67, PRE_first_tail_x15_r0_body.ckA67, PRE_first_tail_x15_r0_body.cobjsK67, PRE_first_tail_x15_r0_body.cnodesK67, PRE_first_tail_x15_r0_body.citemsK67, PRE_first_tail_x15_r0_body.f1A67, PRE_first_tail_x15_r0_body.f1O67, PRE_first_tail_x15_r0_body.f1N67, PRE_first_tail_x15_r0_body.f1I67, PRE_first_tail_x15_r0_body.fbd67, PRE_first_tail_x15_r0_body.fincW67, PRE_first_tail_x15_r0_body.fincI67, PRE_first_tail_x15_r0_body.fincN67, PRE_first_tail_x15_r0_body.flnF67, PRE_first_tail_x15_r0_body.fh67, PRE_first_tail_x15_r0_body.fo67, PRE_first_tail_x15_r0_body.fok67, PRE_first_tail_x15_r0_body.fnd67, PRE_first_tail_x15_r0_body.fp67, PRE_first_tail_x15_r0_body.fnord67, PRE_first_tail_x15_r0_body.fi67, PRE_first_tail_x15_r0_body.fii67⟩
theorem PRE_first_tail_x15_r0_body.cnshift67 (clean : Conv.NClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P67.NL) (cl : SSt (· < 2945) PRE_first_tail_x15_r0_body.cx0_67.mlx) : NShift PRE_first_tail_x15_r0_body.P67 2945 PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.cx0_67 PRE_first_tail_x15_r0_body.cx1_67 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot67 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost67 (compact_a_eq PRE_first_tail_x15_r0_body.ckn067 PRE_first_tail_x15_r0_body.ckn167 PRE_first_tail_x15_r0_body.ckheap67 PRE_first_tail_x15_r0_body.ckpl67)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_67 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s600.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_67 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s600.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_67 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s600.ffi) = some PRE_first_tail_x15_r0_body.fxC_67
kernel_rfl PRE_first_tail_x15_r0_body.okrC_67 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s600.ffi) = some PRE_first_tail_x15_r0_body.krC_67
noncomputable def PRE_first_tail_x15_r0_body.fx0_67 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s602.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_67 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s602.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_67 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s602.ffi) = some PRE_first_tail_x15_r0_body.fx0_67
kernel_rfl PRE_first_tail_x15_r0_body.okr0_67 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s602.ffi) = some PRE_first_tail_x15_r0_body.kr0_67
noncomputable def PRE_first_tail_x15_r0_body.fx1_67 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s601.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_67 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s601.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_67 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s601.ffi) = some PRE_first_tail_x15_r0_body.fx1_67
kernel_rfl PRE_first_tail_x15_r0_body.okr1_67 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s601.ffi) = some PRE_first_tail_x15_r0_body.kr1_67
kernel_rfl PRE_first_tail_x15_r0_body.ff067 : PRE_first_tail_x15_r0_body.fx0_67 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_67 (PRE_first_tail_x15_r0_body.clo67.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_67.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff167 : PRE_first_tail_x15_r0_body.fx1_67 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_67 (PRE_first_tail_x15_r0_body.cwS67.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_67.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck67 : freedLB PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.cx0_67.mlx PRE_first_tail_x15_r0_body.fx0_67 PRE_first_tail_x15_r0_body.fx1_67 PRE_first_tail_x15_r0_body.clo67 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf067 : PRE_first_tail_x15_r0_body.kr0_67.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_67.flags (PRE_first_tail_x15_r0_body.clo67.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_67.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt067 : PRE_first_tail_x15_r0_body.kr0_67.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_67.targs (PRE_first_tail_x15_r0_body.clo67.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_67.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf167 : PRE_first_tail_x15_r0_body.kr1_67.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_67.flags (PRE_first_tail_x15_r0_body.cwS67.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_67.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt167 : PRE_first_tail_x15_r0_body.kr1_67.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_67.targs (PRE_first_tail_x15_r0_body.cwS67.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_67.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck67 : krecLB PRE_first_tail_x15_r0_body.kappa67 2945 PRE_first_tail_x15_r0_body.cx0_67.mlx PRE_first_tail_x15_r0_body.kr0_67 PRE_first_tail_x15_r0_body.kr1_67 PRE_first_tail_x15_r0_body.clo67 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn67 : Nat.ble 2945 2945 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge67 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s601.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s602.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR67 : pendRegB PRE_first_tail_x15_r0_body.kappa67 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe67 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift67 (clean : Conv.NClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P67.NL) (cl : SSt (· < 2945) PRE_first_tail_x15_r0_body.cx0_67.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_67.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_67.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_67.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_67.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P67 2945 PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.s602.ffi PRE_first_tail_x15_r0_body.s601.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift67 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue67, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp67 t ht),
    PRE_first_tail_x15_r0_body.cbridge67,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s602.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s601.ffi) (PRE_first_tail_x15_r0_body.cfoot67 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_67 PRE_first_tail_x15_r0_body.ofx1_67 hobjC PRE_first_tail_x15_r0_body.ff067 PRE_first_tail_x15_r0_body.ff167 PRE_first_tail_x15_r0_body.ffck67,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s602.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s601.ffi) (PRE_first_tail_x15_r0_body.cfoot67 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_67 PRE_first_tail_x15_r0_body.okr1_67 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn67) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf067 PRE_first_tail_x15_r0_body.fkt067 PRE_first_tail_x15_r0_body.fkf167 PRE_first_tail_x15_r0_body.fkt167 PRE_first_tail_x15_r0_body.fkck67,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh067 PRE_first_tail_x15_r0_body.cnh167 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe67) PRE_first_tail_x15_r0_body.cpendR67⟩

end Host.Load.Run.Tpl
