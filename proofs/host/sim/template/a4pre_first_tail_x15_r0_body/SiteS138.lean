import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl138
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 138 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc138 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P138 : LoadP := PRE_first_tail_x15_r0_body.Pc138.raise 18038
kernel_rfl PRE_first_tail_x15_r0_body.craise138 : Nat.ble PRE_first_tail_x15_r0_body.Pc138.N0 18038 = true
theorem PRE_first_tail_x15_r0_body.raised138 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc138 PRE_first_tail_x15_r0_body.P138 :=
  .inr ⟨18038, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise138, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_138 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_138 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1340.ffi)
def PRE_first_tail_x15_r0_body.khinv138 : PTrie Nat := Stage.setAll PTrie.nil [(20952, 20926), (20930, 20927), (20953, 20928)]
def PRE_first_tail_x15_r0_body.kninv138 : PTrie Nat := Stage.setAll PTrie.nil [(18011, 18011), (18012, 18012), (18013, 18013), (18014, 18014), (18015, 18015), (18016, 18016), (18017, 18017), (18018, 18018), (18019, 18019), (18020, 18020), (18021, 18021), (18022, 18022), (18023, 18023), (18024, 18024), (18025, 18025), (18026, 18026), (18027, 18027), (18028, 18028), (18029, 18029), (18030, 18030), (18031, 18031), (18032, 18032), (18033, 18033), (18034, 18034), (18035, 18035), (18036, 18036), (18037, 18037)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS138 : List Nat := [20906, 20919, 20925, 20926, 20927, 20928, 20929, 20930, 20931, 20932, 20933, 20934, 20935, 20936, 20937, 20938, 20939, 20940, 20941, 20942, 20943, 20944, 20945, 20946, 20947, 20948, 20949, 20950, 20951, 20952, 20953]
def PRE_first_tail_x15_r0_body.cnS138 : List Nat := List.range' 18011 27
def PRE_first_tail_x15_r0_body.ciS138 : List Nat := [] ++ List.range' 18011 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0138 : PRE_first_tail_x15_r0_body.kd138.nh0 = PRE_first_tail_x15_r0_body.cx0_138.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1138 : PRE_first_tail_x15_r0_body.kd138.nh1 = PRE_first_tail_x15_r0_body.cx1_138.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0138 : PRE_first_tail_x15_r0_body.kd138.nn0 = PRE_first_tail_x15_r0_body.cx0_138.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1138 : PRE_first_tail_x15_r0_body.kd138.nn1 = PRE_first_tail_x15_r0_body.cx1_138.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo138 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P138.lo && Nat.ble PRE_first_tail_x15_r0_body.P138.lo PRE_first_tail_x15_r0_body.cx0_138.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P138.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P138.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt138 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_138.mlx.next PRE_first_tail_x15_r0_body.cx1_138.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_138.mlx.nnext PRE_first_tail_x15_r0_body.cx1_138.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband138 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P138.NL && Nat.ble PRE_first_tail_x15_r0_body.P138.NL PRE_first_tail_x15_r0_body.P138.N0 && Nat.ble PRE_first_tail_x15_r0_body.P138.N0 PRE_first_tail_x15_r0_body.cx0_138.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow138 : PRE_first_tail_x15_r0_body.kd138.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren138 : checkRenG PRE_first_tail_x15_r0_body.kd138.hnd PRE_first_tail_x15_r0_body.khinv138 (phB PRE_first_tail_x15_r0_body.cx0_138.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband138 : PRE_first_tail_x15_r0_body.kd138.checkBand PRE_first_tail_x15_r0_body.P138.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos138 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd138.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren138 : checkRenG PRE_first_tail_x15_r0_body.kd138.node PRE_first_tail_x15_r0_body.kninv138 (pnB PRE_first_tail_x15_r0_body.cx0_138.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P138.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd138.nodeF j) PRE_first_tail_x15_r0_body.cx1_138.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a138 : PRE_first_tail_x15_r0_body.cx0_138.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b138 : PRE_first_tail_x15_r0_body.cx0_138.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.pending = PRE_first_tail_x15_r0_body.cx0_138.mlx.pending.map PRE_first_tail_x15_r0_body.kappa138.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.errh = PRE_first_tail_x15_r0_body.cx0_138.mlx.errh.map PRE_first_tail_x15_r0_body.kappa138.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.files = PRE_first_tail_x15_r0_body.cx0_138.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.arch = PRE_first_tail_x15_r0_body.cx0_138.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_138.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.wired = PRE_first_tail_x15_r0_body.cx0_138.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost138 : PRE_first_tail_x15_r0_body.cx1_138.host = PRE_first_tail_x15_r0_body.cx0_138.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd138`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0138 : PRE_first_tail_x15_r0_body.kd138.n0 = 2783557
kernel_rfl PRE_first_tail_x15_r0_body.ckn1138 : PRE_first_tail_x15_r0_body.kd138.n1 = 2784706
kernel_rfl PRE_first_tail_x15_r0_body.ckheap138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.heap).all (fun x => Nat.ble 2783551 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl138 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd138.heap.get (2783551 + j) = nth? PRE_first_tail_x15_r0_body.pl138 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja138 : Nat.ble 2783551 2783551 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn138 : Nat.ble 5984 5984 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD138 : Nat.ble 2783551 PRE_first_tail_x15_r0_body.kd138.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn138 : Nat.ble 20926 PRE_first_tail_x15_r0_body.kd138.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn138 : Nat.ble 18011 PRE_first_tail_x15_r0_body.kd138.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb138 : Nat.ble 20926 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.heap).all (Nat.ble (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.hnd).all (Nat.ble (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.node).all (Nat.ble (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix138 : Conv.FixOld (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa138 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja138) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn138) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD138) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn138) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn138) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb138) PRE_first_tail_x15_r0_body.fheap138 PRE_first_tail_x15_r0_body.fhnd138 PRE_first_tail_x15_r0_body.fnode138
kernel_rfl PRE_first_tail_x15_r0_body.fcxn138 : (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn138 : (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0138 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_138.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_138.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS138.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_138.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS138.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_138.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS138.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_138.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS138.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_138.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd138 : (PRE_first_tail_x15_r0_body.clo138 ++ PRE_first_tail_x15_r0_body.cln138 ++ PRE_first_tail_x15_r0_body.cli138 ++ PRE_first_tail_x15_r0_body.cwS138 ++ PRE_first_tail_x15_r0_body.cnS138 ++ PRE_first_tail_x15_r0_body.ciS138).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW138 : PRE_first_tail_x15_r0_body.cwS138.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo138.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI138 : PRE_first_tail_x15_r0_body.ciS138.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli138.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN138 : PRE_first_tail_x15_r0_body.cnS138.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF138 : PRE_first_tail_x15_r0_body.cln138.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh138 : PRE_first_tail_x15_r0_body.clo138.all (handleOK PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.P138.lo PRE_first_tail_x15_r0_body.cx0_138.mlx PRE_first_tail_x15_r0_body.cx1_138.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo138 : PRE_first_tail_x15_r0_body.clo138.map (fun h => PRE_first_tail_x15_r0_body.cx1_138.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa138.handle h)) = PRE_first_tail_x15_r0_body.clo138.map (fun h => (PRE_first_tail_x15_r0_body.cx0_138.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa138.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok138 : PRE_first_tail_x15_r0_body.clo138.all (objOK PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.P138.NL PRE_first_tail_x15_r0_body.cx0_138.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd138 : PRE_first_tail_x15_r0_body.cln138.all (nodeOKF PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.P138 PRE_first_tail_x15_r0_body.cx0_138.mlx PRE_first_tail_x15_r0_body.cx1_138.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp138 : ((PRE_first_tail_x15_r0_body.cln138.filter (fullB PRE_first_tail_x15_r0_body.P138))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_138.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa138.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln138.filter (fullB PRE_first_tail_x15_r0_body.P138))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_138.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa138.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI138 : incrB PRE_first_tail_x15_r0_body.kd138.nodeF (List.range' 18011 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.node).all (fun k => Nat.ble 18011 k && Nat.blt k 18038) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL138 : (PRE_first_tail_x15_r0_body.cln138.filter (Nat.ble PRE_first_tail_x15_r0_body.P138.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd138.nodeF i) && (Nat.blt i 18038 || Nat.ble PRE_first_tail_x15_r0_body.kd138.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord138 : (PRE_first_tail_x15_r0_body.cln138.filter (Nat.ble PRE_first_tail_x15_r0_body.P138.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd138.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd138.nodeF j) (PRE_first_tail_x15_r0_body.kd138.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow138 PRE_first_tail_x15_r0_body.cnn1138 PRE_first_tail_x15_r0_body.fnordI138 PRE_first_tail_x15_r0_body.fnordK138 PRE_first_tail_x15_r0_body.fnordL138
kernel_rfl PRE_first_tail_x15_r0_body.fi138 : PRE_first_tail_x15_r0_body.cli138.all (pnB PRE_first_tail_x15_r0_body.cx0_138.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii138 : PRE_first_tail_x15_r0_body.cli138.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_138.mlx.items.get (PRE_first_tail_x15_r0_body.kappa138.node k) = (PRE_first_tail_x15_r0_body.cx0_138.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa138.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot138 (clean : Conv.NClean (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P138.NL) (cl : SSt (· < 6002) PRE_first_tail_x15_r0_body.cx0_138.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P138 6002 PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.kd138 PRE_first_tail_x15_r0_body.khinv138 PRE_first_tail_x15_r0_body.kninv138 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx PRE_first_tail_x15_r0_body.cx0_138.mlx PRE_first_tail_x15_r0_body.cx1_138.mlx (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo138 PRE_first_tail_x15_r0_body.cln138 PRE_first_tail_x15_r0_body.cli138 PRE_first_tail_x15_r0_body.cwS138 PRE_first_tail_x15_r0_body.cnS138 PRE_first_tail_x15_r0_body.ciS138 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0138, PRE_first_tail_x15_r0_body.cnh1138, PRE_first_tail_x15_r0_body.cnn0138, PRE_first_tail_x15_r0_body.cnn1138, PRE_first_tail_x15_r0_body.cplo138, PRE_first_tail_x15_r0_body.ccnt138, PRE_first_tail_x15_r0_body.cnband138, PRE_first_tail_x15_r0_body.chbelow138, PRE_first_tail_x15_r0_body.chren138, PRE_first_tail_x15_r0_body.cband138, PRE_first_tail_x15_r0_body.cnh1pos138, PRE_first_tail_x15_r0_body.cnren138, PRE_first_tail_x15_r0_body.cnlow138, PRE_first_tail_x15_r0_body.cabs0a138, PRE_first_tail_x15_r0_body.cabs0b138, PRE_first_tail_x15_r0_body.ctok1138, PRE_first_tail_x15_r0_body.cpend138, PRE_first_tail_x15_r0_body.cerrh138, PRE_first_tail_x15_r0_body.cfiles138, PRE_first_tail_x15_r0_body.carch138, PRE_first_tail_x15_r0_body.csizes138, PRE_first_tail_x15_r0_body.cwired138, PRE_first_tail_x15_r0_body.cfix138, clean, PRE_first_tail_x15_r0_body.fcxn138, PRE_first_tail_x15_r0_body.fcnn138, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0138, PRE_first_tail_x15_r0_body.fnk138, PRE_first_tail_x15_r0_body.ckA138, PRE_first_tail_x15_r0_body.cobjsK138, PRE_first_tail_x15_r0_body.cnodesK138, PRE_first_tail_x15_r0_body.citemsK138, PRE_first_tail_x15_r0_body.f1A138, PRE_first_tail_x15_r0_body.f1O138, PRE_first_tail_x15_r0_body.f1N138, PRE_first_tail_x15_r0_body.f1I138, PRE_first_tail_x15_r0_body.fbd138, PRE_first_tail_x15_r0_body.fincW138, PRE_first_tail_x15_r0_body.fincI138, PRE_first_tail_x15_r0_body.fincN138, PRE_first_tail_x15_r0_body.flnF138, PRE_first_tail_x15_r0_body.fh138, PRE_first_tail_x15_r0_body.fo138, PRE_first_tail_x15_r0_body.fok138, PRE_first_tail_x15_r0_body.fnd138, PRE_first_tail_x15_r0_body.fp138, PRE_first_tail_x15_r0_body.fnord138, PRE_first_tail_x15_r0_body.fi138, PRE_first_tail_x15_r0_body.fii138⟩
theorem PRE_first_tail_x15_r0_body.cnshift138 (clean : Conv.NClean (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P138.NL) (cl : SSt (· < 6002) PRE_first_tail_x15_r0_body.cx0_138.mlx) : NShift PRE_first_tail_x15_r0_body.P138 6002 PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.cx0_138 PRE_first_tail_x15_r0_body.cx1_138 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot138 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost138 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0138 PRE_first_tail_x15_r0_body.ckn1138 PRE_first_tail_x15_r0_body.ckheap138 PRE_first_tail_x15_r0_body.ckpl138)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_138 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1339.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_138 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1339.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_138 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1339.ffi) = some PRE_first_tail_x15_r0_body.fxC_138
kernel_rfl PRE_first_tail_x15_r0_body.okrC_138 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1339.ffi) = some PRE_first_tail_x15_r0_body.krC_138
noncomputable def PRE_first_tail_x15_r0_body.fx0_138 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1341.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_138 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1341.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_138 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1341.ffi) = some PRE_first_tail_x15_r0_body.fx0_138
kernel_rfl PRE_first_tail_x15_r0_body.okr0_138 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1341.ffi) = some PRE_first_tail_x15_r0_body.kr0_138
noncomputable def PRE_first_tail_x15_r0_body.fx1_138 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1340.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_138 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1340.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_138 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1340.ffi) = some PRE_first_tail_x15_r0_body.fx1_138
kernel_rfl PRE_first_tail_x15_r0_body.okr1_138 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1340.ffi) = some PRE_first_tail_x15_r0_body.kr1_138
kernel_rfl PRE_first_tail_x15_r0_body.ff0138 : PRE_first_tail_x15_r0_body.fx0_138 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_138 (PRE_first_tail_x15_r0_body.clo138.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_138.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1138 : PRE_first_tail_x15_r0_body.fx1_138 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_138 (PRE_first_tail_x15_r0_body.cwS138.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_138.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck138 : freedLB PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.cx0_138.mlx PRE_first_tail_x15_r0_body.fx0_138 PRE_first_tail_x15_r0_body.fx1_138 PRE_first_tail_x15_r0_body.clo138 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0138 : PRE_first_tail_x15_r0_body.kr0_138.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_138.flags (PRE_first_tail_x15_r0_body.clo138.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_138.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0138 : PRE_first_tail_x15_r0_body.kr0_138.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_138.targs (PRE_first_tail_x15_r0_body.clo138.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_138.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1138 : PRE_first_tail_x15_r0_body.kr1_138.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_138.flags (PRE_first_tail_x15_r0_body.cwS138.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_138.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1138 : PRE_first_tail_x15_r0_body.kr1_138.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_138.targs (PRE_first_tail_x15_r0_body.cwS138.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_138.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck138 : krecLB PRE_first_tail_x15_r0_body.kappa138 6002 PRE_first_tail_x15_r0_body.cx0_138.mlx PRE_first_tail_x15_r0_body.kr0_138 PRE_first_tail_x15_r0_body.kr1_138 PRE_first_tail_x15_r0_body.clo138 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn138 : Nat.ble 5984 6002 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge138 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1340.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1341.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR138 : pendRegB PRE_first_tail_x15_r0_body.kappa138 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe138 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1340.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift138 (clean : Conv.NClean (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P138.NL) (cl : SSt (· < 6002) PRE_first_tail_x15_r0_body.cx0_138.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_138.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_138.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_138.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_138.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P138 6002 PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.s1341.ffi PRE_first_tail_x15_r0_body.s1340.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift138 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue138, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp138 t ht),
    PRE_first_tail_x15_r0_body.cbridge138,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1341.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1340.ffi) (PRE_first_tail_x15_r0_body.cfoot138 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_138 PRE_first_tail_x15_r0_body.ofx1_138 hobjC PRE_first_tail_x15_r0_body.ff0138 PRE_first_tail_x15_r0_body.ff1138 PRE_first_tail_x15_r0_body.ffck138,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1341.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1340.ffi) (PRE_first_tail_x15_r0_body.cfoot138 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_138 PRE_first_tail_x15_r0_body.okr1_138 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn138) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0138 PRE_first_tail_x15_r0_body.fkt0138 PRE_first_tail_x15_r0_body.fkf1138 PRE_first_tail_x15_r0_body.fkt1138 PRE_first_tail_x15_r0_body.fkck138,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0138 PRE_first_tail_x15_r0_body.cnh1138 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe138) PRE_first_tail_x15_r0_body.cpendR138⟩

end Host.Load.Run.Tpl
