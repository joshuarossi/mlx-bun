import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl177
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 177 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc177 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P177 : LoadP := PRE_first_tail_x15_r0_body.Pc177.raise 18800
kernel_rfl PRE_first_tail_x15_r0_body.craise177 : Nat.ble PRE_first_tail_x15_r0_body.Pc177.N0 18800 = true
theorem PRE_first_tail_x15_r0_body.raised177 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc177 PRE_first_tail_x15_r0_body.P177 :=
  .inr ⟨18800, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise177, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_177 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_177 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1713.ffi)
def PRE_first_tail_x15_r0_body.khinv177 : PTrie Nat := Stage.setAll PTrie.nil [(21699, 21697), (21700, 21698), (21702, 21699), (21701, 21700)]
def PRE_first_tail_x15_r0_body.kninv177 : PTrie Nat := Stage.setAll PTrie.nil [(18794, 18794), (18795, 18795), (18796, 18796), (18797, 18797), (18798, 18798), (18799, 18799)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS177 : List Nat := [21697, 21698, 21699, 21700, 21701, 21702]
def PRE_first_tail_x15_r0_body.cnS177 : List Nat := List.range' 18794 6
def PRE_first_tail_x15_r0_body.ciS177 : List Nat := [] ++ List.range' 18794 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0177 : PRE_first_tail_x15_r0_body.kd177.nh0 = PRE_first_tail_x15_r0_body.cx0_177.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1177 : PRE_first_tail_x15_r0_body.kd177.nh1 = PRE_first_tail_x15_r0_body.cx1_177.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0177 : PRE_first_tail_x15_r0_body.kd177.nn0 = PRE_first_tail_x15_r0_body.cx0_177.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1177 : PRE_first_tail_x15_r0_body.kd177.nn1 = PRE_first_tail_x15_r0_body.cx1_177.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo177 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P177.lo && Nat.ble PRE_first_tail_x15_r0_body.P177.lo PRE_first_tail_x15_r0_body.cx0_177.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P177.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P177.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt177 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_177.mlx.next PRE_first_tail_x15_r0_body.cx1_177.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_177.mlx.nnext PRE_first_tail_x15_r0_body.cx1_177.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband177 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P177.NL && Nat.ble PRE_first_tail_x15_r0_body.P177.NL PRE_first_tail_x15_r0_body.P177.N0 && Nat.ble PRE_first_tail_x15_r0_body.P177.N0 PRE_first_tail_x15_r0_body.cx0_177.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow177 : PRE_first_tail_x15_r0_body.kd177.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren177 : checkRenG PRE_first_tail_x15_r0_body.kd177.hnd PRE_first_tail_x15_r0_body.khinv177 (phB PRE_first_tail_x15_r0_body.cx0_177.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband177 : PRE_first_tail_x15_r0_body.kd177.checkBand PRE_first_tail_x15_r0_body.P177.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos177 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd177.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren177 : checkRenG PRE_first_tail_x15_r0_body.kd177.node PRE_first_tail_x15_r0_body.kninv177 (pnB PRE_first_tail_x15_r0_body.cx0_177.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow177 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd177.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P177.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd177.nodeF j) PRE_first_tail_x15_r0_body.cx1_177.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a177 : PRE_first_tail_x15_r0_body.cx0_177.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b177 : PRE_first_tail_x15_r0_body.cx0_177.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1177 : PRE_first_tail_x15_r0_body.cx1_177.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend177 : PRE_first_tail_x15_r0_body.cx1_177.mlx.pending = PRE_first_tail_x15_r0_body.cx0_177.mlx.pending.map PRE_first_tail_x15_r0_body.kappa177.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh177 : PRE_first_tail_x15_r0_body.cx1_177.mlx.errh = PRE_first_tail_x15_r0_body.cx0_177.mlx.errh.map PRE_first_tail_x15_r0_body.kappa177.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles177 : PRE_first_tail_x15_r0_body.cx1_177.mlx.files = PRE_first_tail_x15_r0_body.cx0_177.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch177 : PRE_first_tail_x15_r0_body.cx1_177.mlx.arch = PRE_first_tail_x15_r0_body.cx0_177.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes177 : PRE_first_tail_x15_r0_body.cx1_177.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_177.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired177 : PRE_first_tail_x15_r0_body.cx1_177.mlx.wired = PRE_first_tail_x15_r0_body.cx0_177.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost177 : PRE_first_tail_x15_r0_body.cx1_177.host = PRE_first_tail_x15_r0_body.cx0_177.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd177`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0177 : PRE_first_tail_x15_r0_body.kd177.n0 = 2814359
kernel_rfl PRE_first_tail_x15_r0_body.ckn1177 : PRE_first_tail_x15_r0_body.kd177.n1 = 2814709
kernel_rfl PRE_first_tail_x15_r0_body.ckheap177 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd177.heap).all (fun x => Nat.ble 2814344 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl177 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd177.heap.get (2814344 + j) = nth? PRE_first_tail_x15_r0_body.pl177 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja177 : Nat.ble 2814344 2814344 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn177 : Nat.ble 7656 7656 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD177 : Nat.ble 2814344 PRE_first_tail_x15_r0_body.kd177.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn177 : Nat.ble 21697 PRE_first_tail_x15_r0_body.kd177.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn177 : Nat.ble 18794 PRE_first_tail_x15_r0_body.kd177.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb177 : Nat.ble 21697 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap177 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd177.heap).all (Nat.ble (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd177 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd177.hnd).all (Nat.ble (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode177 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd177.node).all (Nat.ble (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix177 : Conv.FixOld (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa177 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja177) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn177) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD177) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn177) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn177) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb177) PRE_first_tail_x15_r0_body.fheap177 PRE_first_tail_x15_r0_body.fhnd177 PRE_first_tail_x15_r0_body.fnode177
kernel_rfl PRE_first_tail_x15_r0_body.fcxn177 : (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn177 : (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0177 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_177.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_177.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk177 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd177.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A177 : PRE_first_tail_x15_r0_body.cx1_177.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS177.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_177.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O177 : PRE_first_tail_x15_r0_body.cx1_177.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS177.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_177.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N177 : PRE_first_tail_x15_r0_body.cx1_177.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS177.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_177.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I177 : PRE_first_tail_x15_r0_body.cx1_177.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS177.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_177.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd177 : (PRE_first_tail_x15_r0_body.clo177 ++ PRE_first_tail_x15_r0_body.cln177 ++ PRE_first_tail_x15_r0_body.cli177 ++ PRE_first_tail_x15_r0_body.cwS177 ++ PRE_first_tail_x15_r0_body.cnS177 ++ PRE_first_tail_x15_r0_body.ciS177).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW177 : PRE_first_tail_x15_r0_body.cwS177.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo177.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI177 : PRE_first_tail_x15_r0_body.ciS177.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli177.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN177 : PRE_first_tail_x15_r0_body.cnS177.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF177 : PRE_first_tail_x15_r0_body.cln177.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh177 : PRE_first_tail_x15_r0_body.clo177.all (handleOK PRE_first_tail_x15_r0_body.kappa177 PRE_first_tail_x15_r0_body.P177.lo PRE_first_tail_x15_r0_body.cx0_177.mlx PRE_first_tail_x15_r0_body.cx1_177.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo177 : PRE_first_tail_x15_r0_body.clo177.map (fun h => PRE_first_tail_x15_r0_body.cx1_177.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa177.handle h)) = PRE_first_tail_x15_r0_body.clo177.map (fun h => (PRE_first_tail_x15_r0_body.cx0_177.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa177.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok177 : PRE_first_tail_x15_r0_body.clo177.all (objOK PRE_first_tail_x15_r0_body.kappa177 PRE_first_tail_x15_r0_body.P177.NL PRE_first_tail_x15_r0_body.cx0_177.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd177 : PRE_first_tail_x15_r0_body.cln177.all (nodeOKF PRE_first_tail_x15_r0_body.kappa177 PRE_first_tail_x15_r0_body.P177 PRE_first_tail_x15_r0_body.cx0_177.mlx PRE_first_tail_x15_r0_body.cx1_177.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp177 : ((PRE_first_tail_x15_r0_body.cln177.filter (fullB PRE_first_tail_x15_r0_body.P177))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_177.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa177.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln177.filter (fullB PRE_first_tail_x15_r0_body.P177))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_177.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa177.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI177 : incrB PRE_first_tail_x15_r0_body.kd177.nodeF (List.range' 18794 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK177 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd177.node).all (fun k => Nat.ble 18794 k && Nat.blt k 18800) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL177 : (PRE_first_tail_x15_r0_body.cln177.filter (Nat.ble PRE_first_tail_x15_r0_body.P177.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd177.nodeF i) && (Nat.blt i 18800 || Nat.ble PRE_first_tail_x15_r0_body.kd177.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord177 : (PRE_first_tail_x15_r0_body.cln177.filter (Nat.ble PRE_first_tail_x15_r0_body.P177.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd177.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd177.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd177.nodeF j) (PRE_first_tail_x15_r0_body.kd177.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow177 PRE_first_tail_x15_r0_body.cnn1177 PRE_first_tail_x15_r0_body.fnordI177 PRE_first_tail_x15_r0_body.fnordK177 PRE_first_tail_x15_r0_body.fnordL177
kernel_rfl PRE_first_tail_x15_r0_body.fi177 : PRE_first_tail_x15_r0_body.cli177.all (pnB PRE_first_tail_x15_r0_body.cx0_177.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii177 : PRE_first_tail_x15_r0_body.cli177.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_177.mlx.items.get (PRE_first_tail_x15_r0_body.kappa177.node k) = (PRE_first_tail_x15_r0_body.cx0_177.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa177.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot177 (clean : Conv.NClean (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P177.NL) (cl : SSt (· < 7665) PRE_first_tail_x15_r0_body.cx0_177.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P177 7665 PRE_first_tail_x15_r0_body.kappa177 PRE_first_tail_x15_r0_body.kd177 PRE_first_tail_x15_r0_body.khinv177 PRE_first_tail_x15_r0_body.kninv177 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx PRE_first_tail_x15_r0_body.cx0_177.mlx PRE_first_tail_x15_r0_body.cx1_177.mlx (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo177 PRE_first_tail_x15_r0_body.cln177 PRE_first_tail_x15_r0_body.cli177 PRE_first_tail_x15_r0_body.cwS177 PRE_first_tail_x15_r0_body.cnS177 PRE_first_tail_x15_r0_body.ciS177 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0177, PRE_first_tail_x15_r0_body.cnh1177, PRE_first_tail_x15_r0_body.cnn0177, PRE_first_tail_x15_r0_body.cnn1177, PRE_first_tail_x15_r0_body.cplo177, PRE_first_tail_x15_r0_body.ccnt177, PRE_first_tail_x15_r0_body.cnband177, PRE_first_tail_x15_r0_body.chbelow177, PRE_first_tail_x15_r0_body.chren177, PRE_first_tail_x15_r0_body.cband177, PRE_first_tail_x15_r0_body.cnh1pos177, PRE_first_tail_x15_r0_body.cnren177, PRE_first_tail_x15_r0_body.cnlow177, PRE_first_tail_x15_r0_body.cabs0a177, PRE_first_tail_x15_r0_body.cabs0b177, PRE_first_tail_x15_r0_body.ctok1177, PRE_first_tail_x15_r0_body.cpend177, PRE_first_tail_x15_r0_body.cerrh177, PRE_first_tail_x15_r0_body.cfiles177, PRE_first_tail_x15_r0_body.carch177, PRE_first_tail_x15_r0_body.csizes177, PRE_first_tail_x15_r0_body.cwired177, PRE_first_tail_x15_r0_body.cfix177, clean, PRE_first_tail_x15_r0_body.fcxn177, PRE_first_tail_x15_r0_body.fcnn177, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0177, PRE_first_tail_x15_r0_body.fnk177, PRE_first_tail_x15_r0_body.ckA177, PRE_first_tail_x15_r0_body.cobjsK177, PRE_first_tail_x15_r0_body.cnodesK177, PRE_first_tail_x15_r0_body.citemsK177, PRE_first_tail_x15_r0_body.f1A177, PRE_first_tail_x15_r0_body.f1O177, PRE_first_tail_x15_r0_body.f1N177, PRE_first_tail_x15_r0_body.f1I177, PRE_first_tail_x15_r0_body.fbd177, PRE_first_tail_x15_r0_body.fincW177, PRE_first_tail_x15_r0_body.fincI177, PRE_first_tail_x15_r0_body.fincN177, PRE_first_tail_x15_r0_body.flnF177, PRE_first_tail_x15_r0_body.fh177, PRE_first_tail_x15_r0_body.fo177, PRE_first_tail_x15_r0_body.fok177, PRE_first_tail_x15_r0_body.fnd177, PRE_first_tail_x15_r0_body.fp177, PRE_first_tail_x15_r0_body.fnord177, PRE_first_tail_x15_r0_body.fi177, PRE_first_tail_x15_r0_body.fii177⟩
theorem PRE_first_tail_x15_r0_body.cnshift177 (clean : Conv.NClean (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P177.NL) (cl : SSt (· < 7665) PRE_first_tail_x15_r0_body.cx0_177.mlx) : NShift PRE_first_tail_x15_r0_body.P177 7665 PRE_first_tail_x15_r0_body.kappa177 PRE_first_tail_x15_r0_body.cx0_177 PRE_first_tail_x15_r0_body.cx1_177 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot177 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost177 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0177 PRE_first_tail_x15_r0_body.ckn1177 PRE_first_tail_x15_r0_body.ckheap177 PRE_first_tail_x15_r0_body.ckpl177)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_177 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1712.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_177 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1712.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_177 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1712.ffi) = some PRE_first_tail_x15_r0_body.fxC_177
kernel_rfl PRE_first_tail_x15_r0_body.okrC_177 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1712.ffi) = some PRE_first_tail_x15_r0_body.krC_177
noncomputable def PRE_first_tail_x15_r0_body.fx0_177 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1714.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_177 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1714.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_177 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1714.ffi) = some PRE_first_tail_x15_r0_body.fx0_177
kernel_rfl PRE_first_tail_x15_r0_body.okr0_177 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1714.ffi) = some PRE_first_tail_x15_r0_body.kr0_177
noncomputable def PRE_first_tail_x15_r0_body.fx1_177 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1713.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_177 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1713.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_177 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1713.ffi) = some PRE_first_tail_x15_r0_body.fx1_177
kernel_rfl PRE_first_tail_x15_r0_body.okr1_177 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1713.ffi) = some PRE_first_tail_x15_r0_body.kr1_177
kernel_rfl PRE_first_tail_x15_r0_body.ff0177 : PRE_first_tail_x15_r0_body.fx0_177 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_177 (PRE_first_tail_x15_r0_body.clo177.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_177.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1177 : PRE_first_tail_x15_r0_body.fx1_177 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_177 (PRE_first_tail_x15_r0_body.cwS177.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_177.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck177 : freedLB PRE_first_tail_x15_r0_body.kappa177 PRE_first_tail_x15_r0_body.cx0_177.mlx PRE_first_tail_x15_r0_body.fx0_177 PRE_first_tail_x15_r0_body.fx1_177 PRE_first_tail_x15_r0_body.clo177 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0177 : PRE_first_tail_x15_r0_body.kr0_177.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_177.flags (PRE_first_tail_x15_r0_body.clo177.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_177.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0177 : PRE_first_tail_x15_r0_body.kr0_177.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_177.targs (PRE_first_tail_x15_r0_body.clo177.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_177.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1177 : PRE_first_tail_x15_r0_body.kr1_177.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_177.flags (PRE_first_tail_x15_r0_body.cwS177.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_177.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1177 : PRE_first_tail_x15_r0_body.kr1_177.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_177.targs (PRE_first_tail_x15_r0_body.cwS177.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_177.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck177 : krecLB PRE_first_tail_x15_r0_body.kappa177 7665 PRE_first_tail_x15_r0_body.cx0_177.mlx PRE_first_tail_x15_r0_body.kr0_177 PRE_first_tail_x15_r0_body.kr1_177 PRE_first_tail_x15_r0_body.clo177 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn177 : Nat.ble 7656 7665 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge177 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1713.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1714.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR177 : pendRegB PRE_first_tail_x15_r0_body.kappa177 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe177 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1713.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift177 (clean : Conv.NClean (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P177.NL) (cl : SSt (· < 7665) PRE_first_tail_x15_r0_body.cx0_177.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_177.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_177.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_177.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_177.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P177 7665 PRE_first_tail_x15_r0_body.kappa177 PRE_first_tail_x15_r0_body.s1714.ffi PRE_first_tail_x15_r0_body.s1713.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift177 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue177, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp177 t ht),
    PRE_first_tail_x15_r0_body.cbridge177,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1714.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1713.ffi) (PRE_first_tail_x15_r0_body.cfoot177 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_177 PRE_first_tail_x15_r0_body.ofx1_177 hobjC PRE_first_tail_x15_r0_body.ff0177 PRE_first_tail_x15_r0_body.ff1177 PRE_first_tail_x15_r0_body.ffck177,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1714.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1713.ffi) (PRE_first_tail_x15_r0_body.cfoot177 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_177 PRE_first_tail_x15_r0_body.okr1_177 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn177) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0177 PRE_first_tail_x15_r0_body.fkt0177 PRE_first_tail_x15_r0_body.fkf1177 PRE_first_tail_x15_r0_body.fkt1177 PRE_first_tail_x15_r0_body.fkck177,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0177 PRE_first_tail_x15_r0_body.cnh1177 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe177) PRE_first_tail_x15_r0_body.cpendR177⟩

end Host.Load.Run.Tpl
