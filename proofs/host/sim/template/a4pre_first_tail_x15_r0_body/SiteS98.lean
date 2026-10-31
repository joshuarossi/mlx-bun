import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl98
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 98 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc98 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P98 : LoadP := PRE_first_tail_x15_r0_body.Pc98.raise 17218
kernel_rfl PRE_first_tail_x15_r0_body.craise98 : Nat.ble PRE_first_tail_x15_r0_body.Pc98.N0 17218 = true
theorem PRE_first_tail_x15_r0_body.raised98 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc98 PRE_first_tail_x15_r0_body.P98 :=
  .inr ⟨17218, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise98, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_98 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s867.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_98 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s866.ffi)
def PRE_first_tail_x15_r0_body.khinv98 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv98 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS98 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS98 : List Nat := List.range' 17218 0
def PRE_first_tail_x15_r0_body.ciS98 : List Nat := [] ++ List.range' 17218 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh098 : PRE_first_tail_x15_r0_body.kd98.nh0 = PRE_first_tail_x15_r0_body.cx0_98.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh198 : PRE_first_tail_x15_r0_body.kd98.nh1 = PRE_first_tail_x15_r0_body.cx1_98.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn098 : PRE_first_tail_x15_r0_body.kd98.nn0 = PRE_first_tail_x15_r0_body.cx0_98.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn198 : PRE_first_tail_x15_r0_body.kd98.nn1 = PRE_first_tail_x15_r0_body.cx1_98.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo98 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P98.lo && Nat.ble PRE_first_tail_x15_r0_body.P98.lo PRE_first_tail_x15_r0_body.cx0_98.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P98.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P98.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt98 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_98.mlx.next PRE_first_tail_x15_r0_body.cx1_98.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_98.mlx.nnext PRE_first_tail_x15_r0_body.cx1_98.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband98 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P98.NL && Nat.ble PRE_first_tail_x15_r0_body.P98.NL PRE_first_tail_x15_r0_body.P98.N0 && Nat.ble PRE_first_tail_x15_r0_body.P98.N0 PRE_first_tail_x15_r0_body.cx0_98.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow98 : PRE_first_tail_x15_r0_body.kd98.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren98 : checkRenG PRE_first_tail_x15_r0_body.kd98.hnd PRE_first_tail_x15_r0_body.khinv98 (phB PRE_first_tail_x15_r0_body.cx0_98.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband98 : PRE_first_tail_x15_r0_body.kd98.checkBand PRE_first_tail_x15_r0_body.P98.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos98 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd98.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren98 : checkRenG PRE_first_tail_x15_r0_body.kd98.node PRE_first_tail_x15_r0_body.kninv98 (pnB PRE_first_tail_x15_r0_body.cx0_98.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow98 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd98.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P98.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd98.nodeF j) PRE_first_tail_x15_r0_body.cx1_98.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a98 : PRE_first_tail_x15_r0_body.cx0_98.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b98 : PRE_first_tail_x15_r0_body.cx0_98.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok198 : PRE_first_tail_x15_r0_body.cx1_98.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend98 : PRE_first_tail_x15_r0_body.cx1_98.mlx.pending = PRE_first_tail_x15_r0_body.cx0_98.mlx.pending.map PRE_first_tail_x15_r0_body.kappa98.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh98 : PRE_first_tail_x15_r0_body.cx1_98.mlx.errh = PRE_first_tail_x15_r0_body.cx0_98.mlx.errh.map PRE_first_tail_x15_r0_body.kappa98.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles98 : PRE_first_tail_x15_r0_body.cx1_98.mlx.files = PRE_first_tail_x15_r0_body.cx0_98.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch98 : PRE_first_tail_x15_r0_body.cx1_98.mlx.arch = PRE_first_tail_x15_r0_body.cx0_98.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes98 : PRE_first_tail_x15_r0_body.cx1_98.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_98.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired98 : PRE_first_tail_x15_r0_body.cx1_98.mlx.wired = PRE_first_tail_x15_r0_body.cx0_98.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost98 : PRE_first_tail_x15_r0_body.cx1_98.host = PRE_first_tail_x15_r0_body.cx0_98.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd98`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn098 : PRE_first_tail_x15_r0_body.kd98.n0 = 2751576
kernel_rfl PRE_first_tail_x15_r0_body.ckn198 : PRE_first_tail_x15_r0_body.kd98.n1 = 2751595
kernel_rfl PRE_first_tail_x15_r0_body.ckheap98 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd98.heap).all (fun x => Nat.ble 2751575 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl98 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd98.heap.get (2751575 + j) = nth? PRE_first_tail_x15_r0_body.pl98 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja98 : Nat.ble 2751575 2751575 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn98 : Nat.ble 4243 4243 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD98 : Nat.ble 2751575 PRE_first_tail_x15_r0_body.kd98.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn98 : Nat.ble 20127 PRE_first_tail_x15_r0_body.kd98.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn98 : Nat.ble 17218 PRE_first_tail_x15_r0_body.kd98.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb98 : Nat.ble 20127 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap98 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd98.heap).all (Nat.ble (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd98 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd98.hnd).all (Nat.ble (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode98 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd98.node).all (Nat.ble (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix98 : Conv.FixOld (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa98 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja98) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn98) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD98) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn98) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn98) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb98) PRE_first_tail_x15_r0_body.fheap98 PRE_first_tail_x15_r0_body.fhnd98 PRE_first_tail_x15_r0_body.fnode98
kernel_rfl PRE_first_tail_x15_r0_body.fcxn98 : (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn98 : (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle098 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_98.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_98.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk98 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd98.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A98 : PRE_first_tail_x15_r0_body.cx1_98.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS98.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_98.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O98 : PRE_first_tail_x15_r0_body.cx1_98.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS98.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_98.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N98 : PRE_first_tail_x15_r0_body.cx1_98.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS98.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_98.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I98 : PRE_first_tail_x15_r0_body.cx1_98.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS98.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_98.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd98 : (PRE_first_tail_x15_r0_body.clo98 ++ PRE_first_tail_x15_r0_body.cln98 ++ PRE_first_tail_x15_r0_body.cli98 ++ PRE_first_tail_x15_r0_body.cwS98 ++ PRE_first_tail_x15_r0_body.cnS98 ++ PRE_first_tail_x15_r0_body.ciS98).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW98 : PRE_first_tail_x15_r0_body.cwS98.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo98.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI98 : PRE_first_tail_x15_r0_body.ciS98.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli98.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN98 : PRE_first_tail_x15_r0_body.cnS98.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF98 : PRE_first_tail_x15_r0_body.cln98.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh98 : PRE_first_tail_x15_r0_body.clo98.all (handleOK PRE_first_tail_x15_r0_body.kappa98 PRE_first_tail_x15_r0_body.P98.lo PRE_first_tail_x15_r0_body.cx0_98.mlx PRE_first_tail_x15_r0_body.cx1_98.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo98 : PRE_first_tail_x15_r0_body.clo98.map (fun h => PRE_first_tail_x15_r0_body.cx1_98.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa98.handle h)) = PRE_first_tail_x15_r0_body.clo98.map (fun h => (PRE_first_tail_x15_r0_body.cx0_98.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa98.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok98 : PRE_first_tail_x15_r0_body.clo98.all (objOK PRE_first_tail_x15_r0_body.kappa98 PRE_first_tail_x15_r0_body.P98.NL PRE_first_tail_x15_r0_body.cx0_98.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd98 : PRE_first_tail_x15_r0_body.cln98.all (nodeOKF PRE_first_tail_x15_r0_body.kappa98 PRE_first_tail_x15_r0_body.P98 PRE_first_tail_x15_r0_body.cx0_98.mlx PRE_first_tail_x15_r0_body.cx1_98.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp98 : ((PRE_first_tail_x15_r0_body.cln98.filter (fullB PRE_first_tail_x15_r0_body.P98))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_98.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa98.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln98.filter (fullB PRE_first_tail_x15_r0_body.P98))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_98.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa98.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI98 : incrB PRE_first_tail_x15_r0_body.kd98.nodeF (List.range' 17218 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK98 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd98.node).all (fun k => Nat.ble 17218 k && Nat.blt k 17218) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL98 : (PRE_first_tail_x15_r0_body.cln98.filter (Nat.ble PRE_first_tail_x15_r0_body.P98.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd98.nodeF i) && (Nat.blt i 17218 || Nat.ble PRE_first_tail_x15_r0_body.kd98.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord98 : (PRE_first_tail_x15_r0_body.cln98.filter (Nat.ble PRE_first_tail_x15_r0_body.P98.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd98.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd98.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd98.nodeF j) (PRE_first_tail_x15_r0_body.kd98.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow98 PRE_first_tail_x15_r0_body.cnn198 PRE_first_tail_x15_r0_body.fnordI98 PRE_first_tail_x15_r0_body.fnordK98 PRE_first_tail_x15_r0_body.fnordL98
kernel_rfl PRE_first_tail_x15_r0_body.fi98 : PRE_first_tail_x15_r0_body.cli98.all (pnB PRE_first_tail_x15_r0_body.cx0_98.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii98 : PRE_first_tail_x15_r0_body.cli98.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_98.mlx.items.get (PRE_first_tail_x15_r0_body.kappa98.node k) = (PRE_first_tail_x15_r0_body.cx0_98.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa98.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot98 (clean : Conv.NClean (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P98.NL) (cl : SSt (· < 4243) PRE_first_tail_x15_r0_body.cx0_98.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P98 4243 PRE_first_tail_x15_r0_body.kappa98 PRE_first_tail_x15_r0_body.kd98 PRE_first_tail_x15_r0_body.khinv98 PRE_first_tail_x15_r0_body.kninv98 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx PRE_first_tail_x15_r0_body.cx0_98.mlx PRE_first_tail_x15_r0_body.cx1_98.mlx (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo98 PRE_first_tail_x15_r0_body.cln98 PRE_first_tail_x15_r0_body.cli98 PRE_first_tail_x15_r0_body.cwS98 PRE_first_tail_x15_r0_body.cnS98 PRE_first_tail_x15_r0_body.ciS98 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh098, PRE_first_tail_x15_r0_body.cnh198, PRE_first_tail_x15_r0_body.cnn098, PRE_first_tail_x15_r0_body.cnn198, PRE_first_tail_x15_r0_body.cplo98, PRE_first_tail_x15_r0_body.ccnt98, PRE_first_tail_x15_r0_body.cnband98, PRE_first_tail_x15_r0_body.chbelow98, PRE_first_tail_x15_r0_body.chren98, PRE_first_tail_x15_r0_body.cband98, PRE_first_tail_x15_r0_body.cnh1pos98, PRE_first_tail_x15_r0_body.cnren98, PRE_first_tail_x15_r0_body.cnlow98, PRE_first_tail_x15_r0_body.cabs0a98, PRE_first_tail_x15_r0_body.cabs0b98, PRE_first_tail_x15_r0_body.ctok198, PRE_first_tail_x15_r0_body.cpend98, PRE_first_tail_x15_r0_body.cerrh98, PRE_first_tail_x15_r0_body.cfiles98, PRE_first_tail_x15_r0_body.carch98, PRE_first_tail_x15_r0_body.csizes98, PRE_first_tail_x15_r0_body.cwired98, PRE_first_tail_x15_r0_body.cfix98, clean, PRE_first_tail_x15_r0_body.fcxn98, PRE_first_tail_x15_r0_body.fcnn98, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle098, PRE_first_tail_x15_r0_body.fnk98, PRE_first_tail_x15_r0_body.ckA98, PRE_first_tail_x15_r0_body.cobjsK98, PRE_first_tail_x15_r0_body.cnodesK98, PRE_first_tail_x15_r0_body.citemsK98, PRE_first_tail_x15_r0_body.f1A98, PRE_first_tail_x15_r0_body.f1O98, PRE_first_tail_x15_r0_body.f1N98, PRE_first_tail_x15_r0_body.f1I98, PRE_first_tail_x15_r0_body.fbd98, PRE_first_tail_x15_r0_body.fincW98, PRE_first_tail_x15_r0_body.fincI98, PRE_first_tail_x15_r0_body.fincN98, PRE_first_tail_x15_r0_body.flnF98, PRE_first_tail_x15_r0_body.fh98, PRE_first_tail_x15_r0_body.fo98, PRE_first_tail_x15_r0_body.fok98, PRE_first_tail_x15_r0_body.fnd98, PRE_first_tail_x15_r0_body.fp98, PRE_first_tail_x15_r0_body.fnord98, PRE_first_tail_x15_r0_body.fi98, PRE_first_tail_x15_r0_body.fii98⟩
theorem PRE_first_tail_x15_r0_body.cnshift98 (clean : Conv.NClean (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P98.NL) (cl : SSt (· < 4243) PRE_first_tail_x15_r0_body.cx0_98.mlx) : NShift PRE_first_tail_x15_r0_body.P98 4243 PRE_first_tail_x15_r0_body.kappa98 PRE_first_tail_x15_r0_body.cx0_98 PRE_first_tail_x15_r0_body.cx1_98 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot98 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost98 (compact_a_eq PRE_first_tail_x15_r0_body.ckn098 PRE_first_tail_x15_r0_body.ckn198 PRE_first_tail_x15_r0_body.ckheap98 PRE_first_tail_x15_r0_body.ckpl98)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_98 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s865.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_98 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s865.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_98 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s865.ffi) = some PRE_first_tail_x15_r0_body.fxC_98
kernel_rfl PRE_first_tail_x15_r0_body.okrC_98 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s865.ffi) = some PRE_first_tail_x15_r0_body.krC_98
noncomputable def PRE_first_tail_x15_r0_body.fx0_98 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s867.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_98 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s867.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_98 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s867.ffi) = some PRE_first_tail_x15_r0_body.fx0_98
kernel_rfl PRE_first_tail_x15_r0_body.okr0_98 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s867.ffi) = some PRE_first_tail_x15_r0_body.kr0_98
noncomputable def PRE_first_tail_x15_r0_body.fx1_98 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s866.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_98 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s866.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_98 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s866.ffi) = some PRE_first_tail_x15_r0_body.fx1_98
kernel_rfl PRE_first_tail_x15_r0_body.okr1_98 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s866.ffi) = some PRE_first_tail_x15_r0_body.kr1_98
kernel_rfl PRE_first_tail_x15_r0_body.ff098 : PRE_first_tail_x15_r0_body.fx0_98 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_98 (PRE_first_tail_x15_r0_body.clo98.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_98.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff198 : PRE_first_tail_x15_r0_body.fx1_98 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_98 (PRE_first_tail_x15_r0_body.cwS98.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_98.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck98 : freedLB PRE_first_tail_x15_r0_body.kappa98 PRE_first_tail_x15_r0_body.cx0_98.mlx PRE_first_tail_x15_r0_body.fx0_98 PRE_first_tail_x15_r0_body.fx1_98 PRE_first_tail_x15_r0_body.clo98 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf098 : PRE_first_tail_x15_r0_body.kr0_98.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_98.flags (PRE_first_tail_x15_r0_body.clo98.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_98.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt098 : PRE_first_tail_x15_r0_body.kr0_98.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_98.targs (PRE_first_tail_x15_r0_body.clo98.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_98.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf198 : PRE_first_tail_x15_r0_body.kr1_98.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_98.flags (PRE_first_tail_x15_r0_body.cwS98.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_98.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt198 : PRE_first_tail_x15_r0_body.kr1_98.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_98.targs (PRE_first_tail_x15_r0_body.cwS98.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_98.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck98 : krecLB PRE_first_tail_x15_r0_body.kappa98 4243 PRE_first_tail_x15_r0_body.cx0_98.mlx PRE_first_tail_x15_r0_body.kr0_98 PRE_first_tail_x15_r0_body.kr1_98 PRE_first_tail_x15_r0_body.clo98 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn98 : Nat.ble 4243 4243 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge98 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s866.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s867.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR98 : pendRegB PRE_first_tail_x15_r0_body.kappa98 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s867.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe98 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s867.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s866.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift98 (clean : Conv.NClean (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P98.NL) (cl : SSt (· < 4243) PRE_first_tail_x15_r0_body.cx0_98.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_98.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_98.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_98.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_98.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P98 4243 PRE_first_tail_x15_r0_body.kappa98 PRE_first_tail_x15_r0_body.s867.ffi PRE_first_tail_x15_r0_body.s866.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift98 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue98, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp98 t ht),
    PRE_first_tail_x15_r0_body.cbridge98,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s867.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s866.ffi) (PRE_first_tail_x15_r0_body.cfoot98 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_98 PRE_first_tail_x15_r0_body.ofx1_98 hobjC PRE_first_tail_x15_r0_body.ff098 PRE_first_tail_x15_r0_body.ff198 PRE_first_tail_x15_r0_body.ffck98,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s867.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s866.ffi) (PRE_first_tail_x15_r0_body.cfoot98 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_98 PRE_first_tail_x15_r0_body.okr1_98 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn98) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf098 PRE_first_tail_x15_r0_body.fkt098 PRE_first_tail_x15_r0_body.fkf198 PRE_first_tail_x15_r0_body.fkt198 PRE_first_tail_x15_r0_body.fkck98,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh098 PRE_first_tail_x15_r0_body.cnh198 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe98) PRE_first_tail_x15_r0_body.cpendR98⟩

end Host.Load.Run.Tpl
