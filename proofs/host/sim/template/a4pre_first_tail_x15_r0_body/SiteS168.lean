import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl168
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 168 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc168 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P168 : LoadP := PRE_first_tail_x15_r0_body.Pc168.raise 18623
kernel_rfl PRE_first_tail_x15_r0_body.craise168 : Nat.ble PRE_first_tail_x15_r0_body.Pc168.N0 18623 = true
theorem PRE_first_tail_x15_r0_body.raised168 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc168 PRE_first_tail_x15_r0_body.P168 :=
  .inr ⟨18623, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise168, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_168 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_168 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi)
def PRE_first_tail_x15_r0_body.khinv168 : PTrie Nat := Stage.setAll PTrie.nil [(21546, 21520), (21524, 21521), (21547, 21522)]
def PRE_first_tail_x15_r0_body.kninv168 : PTrie Nat := Stage.setAll PTrie.nil [(18596, 18596), (18597, 18597), (18598, 18598), (18599, 18599), (18600, 18600), (18601, 18601), (18602, 18602), (18603, 18603), (18604, 18604), (18605, 18605), (18606, 18606), (18607, 18607), (18608, 18608), (18609, 18609), (18610, 18610), (18611, 18611), (18612, 18612), (18613, 18613), (18614, 18614), (18615, 18615), (18616, 18616), (18617, 18617), (18618, 18618), (18619, 18619), (18620, 18620), (18621, 18621), (18622, 18622)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS168 : List Nat := [21500, 21513, 21519, 21520, 21521, 21522, 21523, 21524, 21525, 21526, 21527, 21528, 21529, 21530, 21531, 21532, 21533, 21534, 21535, 21536, 21537, 21538, 21539, 21540, 21541, 21542, 21543, 21544, 21545, 21546, 21547]
def PRE_first_tail_x15_r0_body.cnS168 : List Nat := List.range' 18596 27
def PRE_first_tail_x15_r0_body.ciS168 : List Nat := [] ++ List.range' 18596 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0168 : PRE_first_tail_x15_r0_body.kd168.nh0 = PRE_first_tail_x15_r0_body.cx0_168.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1168 : PRE_first_tail_x15_r0_body.kd168.nh1 = PRE_first_tail_x15_r0_body.cx1_168.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0168 : PRE_first_tail_x15_r0_body.kd168.nn0 = PRE_first_tail_x15_r0_body.cx0_168.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1168 : PRE_first_tail_x15_r0_body.kd168.nn1 = PRE_first_tail_x15_r0_body.cx1_168.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo168 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P168.lo && Nat.ble PRE_first_tail_x15_r0_body.P168.lo PRE_first_tail_x15_r0_body.cx0_168.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P168.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P168.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt168 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_168.mlx.next PRE_first_tail_x15_r0_body.cx1_168.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_168.mlx.nnext PRE_first_tail_x15_r0_body.cx1_168.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband168 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P168.NL && Nat.ble PRE_first_tail_x15_r0_body.P168.NL PRE_first_tail_x15_r0_body.P168.N0 && Nat.ble PRE_first_tail_x15_r0_body.P168.N0 PRE_first_tail_x15_r0_body.cx0_168.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow168 : PRE_first_tail_x15_r0_body.kd168.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren168 : checkRenG PRE_first_tail_x15_r0_body.kd168.hnd PRE_first_tail_x15_r0_body.khinv168 (phB PRE_first_tail_x15_r0_body.cx0_168.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband168 : PRE_first_tail_x15_r0_body.kd168.checkBand PRE_first_tail_x15_r0_body.P168.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos168 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd168.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren168 : checkRenG PRE_first_tail_x15_r0_body.kd168.node PRE_first_tail_x15_r0_body.kninv168 (pnB PRE_first_tail_x15_r0_body.cx0_168.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow168 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd168.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P168.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd168.nodeF j) PRE_first_tail_x15_r0_body.cx1_168.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a168 : PRE_first_tail_x15_r0_body.cx0_168.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b168 : PRE_first_tail_x15_r0_body.cx0_168.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1168 : PRE_first_tail_x15_r0_body.cx1_168.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend168 : PRE_first_tail_x15_r0_body.cx1_168.mlx.pending = PRE_first_tail_x15_r0_body.cx0_168.mlx.pending.map PRE_first_tail_x15_r0_body.kappa168.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh168 : PRE_first_tail_x15_r0_body.cx1_168.mlx.errh = PRE_first_tail_x15_r0_body.cx0_168.mlx.errh.map PRE_first_tail_x15_r0_body.kappa168.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles168 : PRE_first_tail_x15_r0_body.cx1_168.mlx.files = PRE_first_tail_x15_r0_body.cx0_168.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch168 : PRE_first_tail_x15_r0_body.cx1_168.mlx.arch = PRE_first_tail_x15_r0_body.cx0_168.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes168 : PRE_first_tail_x15_r0_body.cx1_168.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_168.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired168 : PRE_first_tail_x15_r0_body.cx1_168.mlx.wired = PRE_first_tail_x15_r0_body.cx0_168.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost168 : PRE_first_tail_x15_r0_body.cx1_168.host = PRE_first_tail_x15_r0_body.cx0_168.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd168`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0168 : PRE_first_tail_x15_r0_body.kd168.n0 = 2807305
kernel_rfl PRE_first_tail_x15_r0_body.ckn1168 : PRE_first_tail_x15_r0_body.kd168.n1 = 2808454
kernel_rfl PRE_first_tail_x15_r0_body.ckheap168 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd168.heap).all (fun x => Nat.ble 2807299 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl168 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd168.heap.get (2807299 + j) = nth? PRE_first_tail_x15_r0_body.pl168 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja168 : Nat.ble 2807299 2807299 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn168 : Nat.ble 7265 7265 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD168 : Nat.ble 2807299 PRE_first_tail_x15_r0_body.kd168.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn168 : Nat.ble 21520 PRE_first_tail_x15_r0_body.kd168.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn168 : Nat.ble 18596 PRE_first_tail_x15_r0_body.kd168.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb168 : Nat.ble 21520 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap168 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd168.heap).all (Nat.ble (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd168 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd168.hnd).all (Nat.ble (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode168 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd168.node).all (Nat.ble (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix168 : Conv.FixOld (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa168 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja168) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn168) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD168) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn168) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn168) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb168) PRE_first_tail_x15_r0_body.fheap168 PRE_first_tail_x15_r0_body.fhnd168 PRE_first_tail_x15_r0_body.fnode168
kernel_rfl PRE_first_tail_x15_r0_body.fcxn168 : (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn168 : (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0168 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_168.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_168.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk168 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd168.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A168 : PRE_first_tail_x15_r0_body.cx1_168.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS168.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_168.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O168 : PRE_first_tail_x15_r0_body.cx1_168.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS168.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_168.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N168 : PRE_first_tail_x15_r0_body.cx1_168.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS168.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_168.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I168 : PRE_first_tail_x15_r0_body.cx1_168.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS168.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_168.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd168 : (PRE_first_tail_x15_r0_body.clo168 ++ PRE_first_tail_x15_r0_body.cln168 ++ PRE_first_tail_x15_r0_body.cli168 ++ PRE_first_tail_x15_r0_body.cwS168 ++ PRE_first_tail_x15_r0_body.cnS168 ++ PRE_first_tail_x15_r0_body.ciS168).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW168 : PRE_first_tail_x15_r0_body.cwS168.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo168.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI168 : PRE_first_tail_x15_r0_body.ciS168.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli168.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN168 : PRE_first_tail_x15_r0_body.cnS168.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF168 : PRE_first_tail_x15_r0_body.cln168.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh168 : PRE_first_tail_x15_r0_body.clo168.all (handleOK PRE_first_tail_x15_r0_body.kappa168 PRE_first_tail_x15_r0_body.P168.lo PRE_first_tail_x15_r0_body.cx0_168.mlx PRE_first_tail_x15_r0_body.cx1_168.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo168 : PRE_first_tail_x15_r0_body.clo168.map (fun h => PRE_first_tail_x15_r0_body.cx1_168.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa168.handle h)) = PRE_first_tail_x15_r0_body.clo168.map (fun h => (PRE_first_tail_x15_r0_body.cx0_168.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa168.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok168 : PRE_first_tail_x15_r0_body.clo168.all (objOK PRE_first_tail_x15_r0_body.kappa168 PRE_first_tail_x15_r0_body.P168.NL PRE_first_tail_x15_r0_body.cx0_168.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd168 : PRE_first_tail_x15_r0_body.cln168.all (nodeOKF PRE_first_tail_x15_r0_body.kappa168 PRE_first_tail_x15_r0_body.P168 PRE_first_tail_x15_r0_body.cx0_168.mlx PRE_first_tail_x15_r0_body.cx1_168.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp168 : ((PRE_first_tail_x15_r0_body.cln168.filter (fullB PRE_first_tail_x15_r0_body.P168))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_168.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa168.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln168.filter (fullB PRE_first_tail_x15_r0_body.P168))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_168.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa168.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI168 : incrB PRE_first_tail_x15_r0_body.kd168.nodeF (List.range' 18596 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK168 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd168.node).all (fun k => Nat.ble 18596 k && Nat.blt k 18623) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL168 : (PRE_first_tail_x15_r0_body.cln168.filter (Nat.ble PRE_first_tail_x15_r0_body.P168.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd168.nodeF i) && (Nat.blt i 18623 || Nat.ble PRE_first_tail_x15_r0_body.kd168.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord168 : (PRE_first_tail_x15_r0_body.cln168.filter (Nat.ble PRE_first_tail_x15_r0_body.P168.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd168.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd168.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd168.nodeF j) (PRE_first_tail_x15_r0_body.kd168.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow168 PRE_first_tail_x15_r0_body.cnn1168 PRE_first_tail_x15_r0_body.fnordI168 PRE_first_tail_x15_r0_body.fnordK168 PRE_first_tail_x15_r0_body.fnordL168
kernel_rfl PRE_first_tail_x15_r0_body.fi168 : PRE_first_tail_x15_r0_body.cli168.all (pnB PRE_first_tail_x15_r0_body.cx0_168.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii168 : PRE_first_tail_x15_r0_body.cli168.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_168.mlx.items.get (PRE_first_tail_x15_r0_body.kappa168.node k) = (PRE_first_tail_x15_r0_body.cx0_168.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa168.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot168 (clean : Conv.NClean (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P168.NL) (cl : SSt (· < 7283) PRE_first_tail_x15_r0_body.cx0_168.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P168 7283 PRE_first_tail_x15_r0_body.kappa168 PRE_first_tail_x15_r0_body.kd168 PRE_first_tail_x15_r0_body.khinv168 PRE_first_tail_x15_r0_body.kninv168 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx PRE_first_tail_x15_r0_body.cx0_168.mlx PRE_first_tail_x15_r0_body.cx1_168.mlx (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo168 PRE_first_tail_x15_r0_body.cln168 PRE_first_tail_x15_r0_body.cli168 PRE_first_tail_x15_r0_body.cwS168 PRE_first_tail_x15_r0_body.cnS168 PRE_first_tail_x15_r0_body.ciS168 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0168, PRE_first_tail_x15_r0_body.cnh1168, PRE_first_tail_x15_r0_body.cnn0168, PRE_first_tail_x15_r0_body.cnn1168, PRE_first_tail_x15_r0_body.cplo168, PRE_first_tail_x15_r0_body.ccnt168, PRE_first_tail_x15_r0_body.cnband168, PRE_first_tail_x15_r0_body.chbelow168, PRE_first_tail_x15_r0_body.chren168, PRE_first_tail_x15_r0_body.cband168, PRE_first_tail_x15_r0_body.cnh1pos168, PRE_first_tail_x15_r0_body.cnren168, PRE_first_tail_x15_r0_body.cnlow168, PRE_first_tail_x15_r0_body.cabs0a168, PRE_first_tail_x15_r0_body.cabs0b168, PRE_first_tail_x15_r0_body.ctok1168, PRE_first_tail_x15_r0_body.cpend168, PRE_first_tail_x15_r0_body.cerrh168, PRE_first_tail_x15_r0_body.cfiles168, PRE_first_tail_x15_r0_body.carch168, PRE_first_tail_x15_r0_body.csizes168, PRE_first_tail_x15_r0_body.cwired168, PRE_first_tail_x15_r0_body.cfix168, clean, PRE_first_tail_x15_r0_body.fcxn168, PRE_first_tail_x15_r0_body.fcnn168, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0168, PRE_first_tail_x15_r0_body.fnk168, PRE_first_tail_x15_r0_body.ckA168, PRE_first_tail_x15_r0_body.cobjsK168, PRE_first_tail_x15_r0_body.cnodesK168, PRE_first_tail_x15_r0_body.citemsK168, PRE_first_tail_x15_r0_body.f1A168, PRE_first_tail_x15_r0_body.f1O168, PRE_first_tail_x15_r0_body.f1N168, PRE_first_tail_x15_r0_body.f1I168, PRE_first_tail_x15_r0_body.fbd168, PRE_first_tail_x15_r0_body.fincW168, PRE_first_tail_x15_r0_body.fincI168, PRE_first_tail_x15_r0_body.fincN168, PRE_first_tail_x15_r0_body.flnF168, PRE_first_tail_x15_r0_body.fh168, PRE_first_tail_x15_r0_body.fo168, PRE_first_tail_x15_r0_body.fok168, PRE_first_tail_x15_r0_body.fnd168, PRE_first_tail_x15_r0_body.fp168, PRE_first_tail_x15_r0_body.fnord168, PRE_first_tail_x15_r0_body.fi168, PRE_first_tail_x15_r0_body.fii168⟩
theorem PRE_first_tail_x15_r0_body.cnshift168 (clean : Conv.NClean (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P168.NL) (cl : SSt (· < 7283) PRE_first_tail_x15_r0_body.cx0_168.mlx) : NShift PRE_first_tail_x15_r0_body.P168 7283 PRE_first_tail_x15_r0_body.kappa168 PRE_first_tail_x15_r0_body.cx0_168 PRE_first_tail_x15_r0_body.cx1_168 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot168 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost168 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0168 PRE_first_tail_x15_r0_body.ckn1168 PRE_first_tail_x15_r0_body.ckheap168 PRE_first_tail_x15_r0_body.ckpl168)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_168 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1626.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_168 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1626.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_168 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1626.ffi) = some PRE_first_tail_x15_r0_body.fxC_168
kernel_rfl PRE_first_tail_x15_r0_body.okrC_168 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1626.ffi) = some PRE_first_tail_x15_r0_body.krC_168
noncomputable def PRE_first_tail_x15_r0_body.fx0_168 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1628.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_168 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1628.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_168 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1628.ffi) = some PRE_first_tail_x15_r0_body.fx0_168
kernel_rfl PRE_first_tail_x15_r0_body.okr0_168 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1628.ffi) = some PRE_first_tail_x15_r0_body.kr0_168
noncomputable def PRE_first_tail_x15_r0_body.fx1_168 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1627.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_168 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1627.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_168 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1627.ffi) = some PRE_first_tail_x15_r0_body.fx1_168
kernel_rfl PRE_first_tail_x15_r0_body.okr1_168 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1627.ffi) = some PRE_first_tail_x15_r0_body.kr1_168
kernel_rfl PRE_first_tail_x15_r0_body.ff0168 : PRE_first_tail_x15_r0_body.fx0_168 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_168 (PRE_first_tail_x15_r0_body.clo168.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_168.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1168 : PRE_first_tail_x15_r0_body.fx1_168 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_168 (PRE_first_tail_x15_r0_body.cwS168.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_168.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck168 : freedLB PRE_first_tail_x15_r0_body.kappa168 PRE_first_tail_x15_r0_body.cx0_168.mlx PRE_first_tail_x15_r0_body.fx0_168 PRE_first_tail_x15_r0_body.fx1_168 PRE_first_tail_x15_r0_body.clo168 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0168 : PRE_first_tail_x15_r0_body.kr0_168.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_168.flags (PRE_first_tail_x15_r0_body.clo168.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_168.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0168 : PRE_first_tail_x15_r0_body.kr0_168.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_168.targs (PRE_first_tail_x15_r0_body.clo168.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_168.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1168 : PRE_first_tail_x15_r0_body.kr1_168.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_168.flags (PRE_first_tail_x15_r0_body.cwS168.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_168.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1168 : PRE_first_tail_x15_r0_body.kr1_168.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_168.targs (PRE_first_tail_x15_r0_body.cwS168.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_168.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck168 : krecLB PRE_first_tail_x15_r0_body.kappa168 7283 PRE_first_tail_x15_r0_body.cx0_168.mlx PRE_first_tail_x15_r0_body.kr0_168 PRE_first_tail_x15_r0_body.kr1_168 PRE_first_tail_x15_r0_body.clo168 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn168 : Nat.ble 7265 7283 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge168 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1627.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1628.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR168 : pendRegB PRE_first_tail_x15_r0_body.kappa168 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe168 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift168 (clean : Conv.NClean (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P168.NL) (cl : SSt (· < 7283) PRE_first_tail_x15_r0_body.cx0_168.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_168.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_168.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_168.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_168.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P168 7283 PRE_first_tail_x15_r0_body.kappa168 PRE_first_tail_x15_r0_body.s1628.ffi PRE_first_tail_x15_r0_body.s1627.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift168 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue168, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp168 t ht),
    PRE_first_tail_x15_r0_body.cbridge168,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1628.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1627.ffi) (PRE_first_tail_x15_r0_body.cfoot168 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_168 PRE_first_tail_x15_r0_body.ofx1_168 hobjC PRE_first_tail_x15_r0_body.ff0168 PRE_first_tail_x15_r0_body.ff1168 PRE_first_tail_x15_r0_body.ffck168,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1628.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1627.ffi) (PRE_first_tail_x15_r0_body.cfoot168 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_168 PRE_first_tail_x15_r0_body.okr1_168 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn168) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0168 PRE_first_tail_x15_r0_body.fkt0168 PRE_first_tail_x15_r0_body.fkf1168 PRE_first_tail_x15_r0_body.fkt1168 PRE_first_tail_x15_r0_body.fkck168,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0168 PRE_first_tail_x15_r0_body.cnh1168 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe168) PRE_first_tail_x15_r0_body.cpendR168⟩

end Host.Load.Run.Tpl
