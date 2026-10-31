import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl181
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 181 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc181 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P181 : LoadP := PRE_first_tail_x15_r0_body.Pc181.raise 18873
kernel_rfl PRE_first_tail_x15_r0_body.craise181 : Nat.ble PRE_first_tail_x15_r0_body.Pc181.N0 18873 = true
theorem PRE_first_tail_x15_r0_body.raised181 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc181 PRE_first_tail_x15_r0_body.P181 :=
  .inr ⟨18873, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise181, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_181 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_181 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1750.ffi)
def PRE_first_tail_x15_r0_body.khinv181 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv181 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS181 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS181 : List Nat := List.range' 18873 0
def PRE_first_tail_x15_r0_body.ciS181 : List Nat := [] ++ List.range' 18873 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0181 : PRE_first_tail_x15_r0_body.kd181.nh0 = PRE_first_tail_x15_r0_body.cx0_181.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1181 : PRE_first_tail_x15_r0_body.kd181.nh1 = PRE_first_tail_x15_r0_body.cx1_181.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0181 : PRE_first_tail_x15_r0_body.kd181.nn0 = PRE_first_tail_x15_r0_body.cx0_181.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1181 : PRE_first_tail_x15_r0_body.kd181.nn1 = PRE_first_tail_x15_r0_body.cx1_181.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo181 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P181.lo && Nat.ble PRE_first_tail_x15_r0_body.P181.lo PRE_first_tail_x15_r0_body.cx0_181.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P181.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P181.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt181 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_181.mlx.next PRE_first_tail_x15_r0_body.cx1_181.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_181.mlx.nnext PRE_first_tail_x15_r0_body.cx1_181.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband181 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P181.NL && Nat.ble PRE_first_tail_x15_r0_body.P181.NL PRE_first_tail_x15_r0_body.P181.N0 && Nat.ble PRE_first_tail_x15_r0_body.P181.N0 PRE_first_tail_x15_r0_body.cx0_181.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow181 : PRE_first_tail_x15_r0_body.kd181.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren181 : checkRenG PRE_first_tail_x15_r0_body.kd181.hnd PRE_first_tail_x15_r0_body.khinv181 (phB PRE_first_tail_x15_r0_body.cx0_181.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband181 : PRE_first_tail_x15_r0_body.kd181.checkBand PRE_first_tail_x15_r0_body.P181.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos181 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd181.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren181 : checkRenG PRE_first_tail_x15_r0_body.kd181.node PRE_first_tail_x15_r0_body.kninv181 (pnB PRE_first_tail_x15_r0_body.cx0_181.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow181 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd181.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P181.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd181.nodeF j) PRE_first_tail_x15_r0_body.cx1_181.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a181 : PRE_first_tail_x15_r0_body.cx0_181.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b181 : PRE_first_tail_x15_r0_body.cx0_181.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1181 : PRE_first_tail_x15_r0_body.cx1_181.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend181 : PRE_first_tail_x15_r0_body.cx1_181.mlx.pending = PRE_first_tail_x15_r0_body.cx0_181.mlx.pending.map PRE_first_tail_x15_r0_body.kappa181.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh181 : PRE_first_tail_x15_r0_body.cx1_181.mlx.errh = PRE_first_tail_x15_r0_body.cx0_181.mlx.errh.map PRE_first_tail_x15_r0_body.kappa181.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles181 : PRE_first_tail_x15_r0_body.cx1_181.mlx.files = PRE_first_tail_x15_r0_body.cx0_181.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch181 : PRE_first_tail_x15_r0_body.cx1_181.mlx.arch = PRE_first_tail_x15_r0_body.cx0_181.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes181 : PRE_first_tail_x15_r0_body.cx1_181.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_181.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired181 : PRE_first_tail_x15_r0_body.cx1_181.mlx.wired = PRE_first_tail_x15_r0_body.cx0_181.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost181 : PRE_first_tail_x15_r0_body.cx1_181.host = PRE_first_tail_x15_r0_body.cx0_181.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd181`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0181 : PRE_first_tail_x15_r0_body.kd181.n0 = 2817223
kernel_rfl PRE_first_tail_x15_r0_body.ckn1181 : PRE_first_tail_x15_r0_body.kd181.n1 = 2817225
kernel_rfl PRE_first_tail_x15_r0_body.ckheap181 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd181.heap).all (fun x => Nat.ble 2817223 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl181 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd181.heap.get (2817223 + j) = nth? PRE_first_tail_x15_r0_body.pl181 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja181 : Nat.ble 2817223 2817223 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn181 : Nat.ble 7817 7817 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD181 : Nat.ble 2817223 PRE_first_tail_x15_r0_body.kd181.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn181 : Nat.ble 21772 PRE_first_tail_x15_r0_body.kd181.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn181 : Nat.ble 18873 PRE_first_tail_x15_r0_body.kd181.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb181 : Nat.ble 21772 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap181 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd181.heap).all (Nat.ble (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd181 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd181.hnd).all (Nat.ble (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode181 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd181.node).all (Nat.ble (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix181 : Conv.FixOld (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa181 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja181) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn181) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD181) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn181) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn181) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb181) PRE_first_tail_x15_r0_body.fheap181 PRE_first_tail_x15_r0_body.fhnd181 PRE_first_tail_x15_r0_body.fnode181
kernel_rfl PRE_first_tail_x15_r0_body.fcxn181 : (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn181 : (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0181 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_181.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_181.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk181 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd181.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A181 : PRE_first_tail_x15_r0_body.cx1_181.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS181.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_181.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O181 : PRE_first_tail_x15_r0_body.cx1_181.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS181.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_181.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N181 : PRE_first_tail_x15_r0_body.cx1_181.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS181.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_181.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I181 : PRE_first_tail_x15_r0_body.cx1_181.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS181.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_181.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd181 : (PRE_first_tail_x15_r0_body.clo181 ++ PRE_first_tail_x15_r0_body.cln181 ++ PRE_first_tail_x15_r0_body.cli181 ++ PRE_first_tail_x15_r0_body.cwS181 ++ PRE_first_tail_x15_r0_body.cnS181 ++ PRE_first_tail_x15_r0_body.ciS181).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW181 : PRE_first_tail_x15_r0_body.cwS181.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo181.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI181 : PRE_first_tail_x15_r0_body.ciS181.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli181.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN181 : PRE_first_tail_x15_r0_body.cnS181.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF181 : PRE_first_tail_x15_r0_body.cln181.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh181 : PRE_first_tail_x15_r0_body.clo181.all (handleOK PRE_first_tail_x15_r0_body.kappa181 PRE_first_tail_x15_r0_body.P181.lo PRE_first_tail_x15_r0_body.cx0_181.mlx PRE_first_tail_x15_r0_body.cx1_181.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo181 : PRE_first_tail_x15_r0_body.clo181.map (fun h => PRE_first_tail_x15_r0_body.cx1_181.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa181.handle h)) = PRE_first_tail_x15_r0_body.clo181.map (fun h => (PRE_first_tail_x15_r0_body.cx0_181.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa181.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok181 : PRE_first_tail_x15_r0_body.clo181.all (objOK PRE_first_tail_x15_r0_body.kappa181 PRE_first_tail_x15_r0_body.P181.NL PRE_first_tail_x15_r0_body.cx0_181.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd181 : PRE_first_tail_x15_r0_body.cln181.all (nodeOKF PRE_first_tail_x15_r0_body.kappa181 PRE_first_tail_x15_r0_body.P181 PRE_first_tail_x15_r0_body.cx0_181.mlx PRE_first_tail_x15_r0_body.cx1_181.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp181 : ((PRE_first_tail_x15_r0_body.cln181.filter (fullB PRE_first_tail_x15_r0_body.P181))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_181.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa181.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln181.filter (fullB PRE_first_tail_x15_r0_body.P181))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_181.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa181.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI181 : incrB PRE_first_tail_x15_r0_body.kd181.nodeF (List.range' 18873 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK181 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd181.node).all (fun k => Nat.ble 18873 k && Nat.blt k 18873) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL181 : (PRE_first_tail_x15_r0_body.cln181.filter (Nat.ble PRE_first_tail_x15_r0_body.P181.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd181.nodeF i) && (Nat.blt i 18873 || Nat.ble PRE_first_tail_x15_r0_body.kd181.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord181 : (PRE_first_tail_x15_r0_body.cln181.filter (Nat.ble PRE_first_tail_x15_r0_body.P181.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd181.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd181.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd181.nodeF j) (PRE_first_tail_x15_r0_body.kd181.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow181 PRE_first_tail_x15_r0_body.cnn1181 PRE_first_tail_x15_r0_body.fnordI181 PRE_first_tail_x15_r0_body.fnordK181 PRE_first_tail_x15_r0_body.fnordL181
kernel_rfl PRE_first_tail_x15_r0_body.fi181 : PRE_first_tail_x15_r0_body.cli181.all (pnB PRE_first_tail_x15_r0_body.cx0_181.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii181 : PRE_first_tail_x15_r0_body.cli181.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_181.mlx.items.get (PRE_first_tail_x15_r0_body.kappa181.node k) = (PRE_first_tail_x15_r0_body.cx0_181.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa181.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot181 (clean : Conv.NClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P181.NL) (cl : SSt (· < 7817) PRE_first_tail_x15_r0_body.cx0_181.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P181 7817 PRE_first_tail_x15_r0_body.kappa181 PRE_first_tail_x15_r0_body.kd181 PRE_first_tail_x15_r0_body.khinv181 PRE_first_tail_x15_r0_body.kninv181 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx PRE_first_tail_x15_r0_body.cx0_181.mlx PRE_first_tail_x15_r0_body.cx1_181.mlx (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo181 PRE_first_tail_x15_r0_body.cln181 PRE_first_tail_x15_r0_body.cli181 PRE_first_tail_x15_r0_body.cwS181 PRE_first_tail_x15_r0_body.cnS181 PRE_first_tail_x15_r0_body.ciS181 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0181, PRE_first_tail_x15_r0_body.cnh1181, PRE_first_tail_x15_r0_body.cnn0181, PRE_first_tail_x15_r0_body.cnn1181, PRE_first_tail_x15_r0_body.cplo181, PRE_first_tail_x15_r0_body.ccnt181, PRE_first_tail_x15_r0_body.cnband181, PRE_first_tail_x15_r0_body.chbelow181, PRE_first_tail_x15_r0_body.chren181, PRE_first_tail_x15_r0_body.cband181, PRE_first_tail_x15_r0_body.cnh1pos181, PRE_first_tail_x15_r0_body.cnren181, PRE_first_tail_x15_r0_body.cnlow181, PRE_first_tail_x15_r0_body.cabs0a181, PRE_first_tail_x15_r0_body.cabs0b181, PRE_first_tail_x15_r0_body.ctok1181, PRE_first_tail_x15_r0_body.cpend181, PRE_first_tail_x15_r0_body.cerrh181, PRE_first_tail_x15_r0_body.cfiles181, PRE_first_tail_x15_r0_body.carch181, PRE_first_tail_x15_r0_body.csizes181, PRE_first_tail_x15_r0_body.cwired181, PRE_first_tail_x15_r0_body.cfix181, clean, PRE_first_tail_x15_r0_body.fcxn181, PRE_first_tail_x15_r0_body.fcnn181, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0181, PRE_first_tail_x15_r0_body.fnk181, PRE_first_tail_x15_r0_body.ckA181, PRE_first_tail_x15_r0_body.cobjsK181, PRE_first_tail_x15_r0_body.cnodesK181, PRE_first_tail_x15_r0_body.citemsK181, PRE_first_tail_x15_r0_body.f1A181, PRE_first_tail_x15_r0_body.f1O181, PRE_first_tail_x15_r0_body.f1N181, PRE_first_tail_x15_r0_body.f1I181, PRE_first_tail_x15_r0_body.fbd181, PRE_first_tail_x15_r0_body.fincW181, PRE_first_tail_x15_r0_body.fincI181, PRE_first_tail_x15_r0_body.fincN181, PRE_first_tail_x15_r0_body.flnF181, PRE_first_tail_x15_r0_body.fh181, PRE_first_tail_x15_r0_body.fo181, PRE_first_tail_x15_r0_body.fok181, PRE_first_tail_x15_r0_body.fnd181, PRE_first_tail_x15_r0_body.fp181, PRE_first_tail_x15_r0_body.fnord181, PRE_first_tail_x15_r0_body.fi181, PRE_first_tail_x15_r0_body.fii181⟩
theorem PRE_first_tail_x15_r0_body.cnshift181 (clean : Conv.NClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P181.NL) (cl : SSt (· < 7817) PRE_first_tail_x15_r0_body.cx0_181.mlx) : NShift PRE_first_tail_x15_r0_body.P181 7817 PRE_first_tail_x15_r0_body.kappa181 PRE_first_tail_x15_r0_body.cx0_181 PRE_first_tail_x15_r0_body.cx1_181 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot181 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost181 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0181 PRE_first_tail_x15_r0_body.ckn1181 PRE_first_tail_x15_r0_body.ckheap181 PRE_first_tail_x15_r0_body.ckpl181)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_181 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1749.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_181 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1749.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_181 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1749.ffi) = some PRE_first_tail_x15_r0_body.fxC_181
kernel_rfl PRE_first_tail_x15_r0_body.okrC_181 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1749.ffi) = some PRE_first_tail_x15_r0_body.krC_181
noncomputable def PRE_first_tail_x15_r0_body.fx0_181 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1751.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_181 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1751.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_181 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1751.ffi) = some PRE_first_tail_x15_r0_body.fx0_181
kernel_rfl PRE_first_tail_x15_r0_body.okr0_181 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1751.ffi) = some PRE_first_tail_x15_r0_body.kr0_181
noncomputable def PRE_first_tail_x15_r0_body.fx1_181 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1750.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_181 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1750.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_181 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1750.ffi) = some PRE_first_tail_x15_r0_body.fx1_181
kernel_rfl PRE_first_tail_x15_r0_body.okr1_181 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1750.ffi) = some PRE_first_tail_x15_r0_body.kr1_181
kernel_rfl PRE_first_tail_x15_r0_body.ff0181 : PRE_first_tail_x15_r0_body.fx0_181 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_181 (PRE_first_tail_x15_r0_body.clo181.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_181.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1181 : PRE_first_tail_x15_r0_body.fx1_181 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_181 (PRE_first_tail_x15_r0_body.cwS181.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_181.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck181 : freedLB PRE_first_tail_x15_r0_body.kappa181 PRE_first_tail_x15_r0_body.cx0_181.mlx PRE_first_tail_x15_r0_body.fx0_181 PRE_first_tail_x15_r0_body.fx1_181 PRE_first_tail_x15_r0_body.clo181 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0181 : PRE_first_tail_x15_r0_body.kr0_181.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_181.flags (PRE_first_tail_x15_r0_body.clo181.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_181.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0181 : PRE_first_tail_x15_r0_body.kr0_181.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_181.targs (PRE_first_tail_x15_r0_body.clo181.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_181.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1181 : PRE_first_tail_x15_r0_body.kr1_181.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_181.flags (PRE_first_tail_x15_r0_body.cwS181.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_181.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1181 : PRE_first_tail_x15_r0_body.kr1_181.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_181.targs (PRE_first_tail_x15_r0_body.cwS181.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_181.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck181 : krecLB PRE_first_tail_x15_r0_body.kappa181 7817 PRE_first_tail_x15_r0_body.cx0_181.mlx PRE_first_tail_x15_r0_body.kr0_181 PRE_first_tail_x15_r0_body.kr1_181 PRE_first_tail_x15_r0_body.clo181 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn181 : Nat.ble 7817 7817 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge181 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1750.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1751.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR181 : pendRegB PRE_first_tail_x15_r0_body.kappa181 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe181 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1750.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift181 (clean : Conv.NClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P181.NL) (cl : SSt (· < 7817) PRE_first_tail_x15_r0_body.cx0_181.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_181.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_181.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_181.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_181.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P181 7817 PRE_first_tail_x15_r0_body.kappa181 PRE_first_tail_x15_r0_body.s1751.ffi PRE_first_tail_x15_r0_body.s1750.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift181 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue181, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp181 t ht),
    PRE_first_tail_x15_r0_body.cbridge181,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1751.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1750.ffi) (PRE_first_tail_x15_r0_body.cfoot181 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_181 PRE_first_tail_x15_r0_body.ofx1_181 hobjC PRE_first_tail_x15_r0_body.ff0181 PRE_first_tail_x15_r0_body.ff1181 PRE_first_tail_x15_r0_body.ffck181,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1751.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1750.ffi) (PRE_first_tail_x15_r0_body.cfoot181 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_181 PRE_first_tail_x15_r0_body.okr1_181 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn181) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0181 PRE_first_tail_x15_r0_body.fkt0181 PRE_first_tail_x15_r0_body.fkf1181 PRE_first_tail_x15_r0_body.fkt1181 PRE_first_tail_x15_r0_body.fkck181,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0181 PRE_first_tail_x15_r0_body.cnh1181 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe181) PRE_first_tail_x15_r0_body.cpendR181⟩

end Host.Load.Run.Tpl
