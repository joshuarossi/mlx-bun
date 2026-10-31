import host.sim.template.a4dec_clearFill.SiteSn1_0
import host.sim.template.a4dec_clearFill.SiteSn1_1
import host.sim.template.a4dec_clearFill.SiteSn1_2
import host.sim.template.a4dec_clearFill.SiteSn1_3
import host.sim.template.a4dec_clearFill.SiteSn1_4
import host.sim.template.a4dec_clearFill.SiteSn1_5
import host.sim.template.a4dec_clearFill.SiteSn1_6
import host.sim.template.a4dec_clearFill.SiteSn1_7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

-- the checks over the changed lists
kernel_rfl DEC_clearFill.fh1 : DEC_clearFill.clo1.all (handleOK DEC_clearFill.kappa1 DEC_clearFill.P1.lo DEC_clearFill.cx0_1.mlx DEC_clearFill.cx1_1.mlx) = true
kernel_rfl DEC_clearFill.fo1 : DEC_clearFill.clo1.map (fun h => DEC_clearFill.cx1_1.mlx.objs.get (DEC_clearFill.kappa1.handle h)) = DEC_clearFill.clo1.map (fun h => (DEC_clearFill.cx0_1.mlx.objs.get h).map DEC_clearFill.kappa1.nobj)
kernel_rfl DEC_clearFill.fok1 : DEC_clearFill.clo1.all (objOK DEC_clearFill.kappa1 DEC_clearFill.P1.NL DEC_clearFill.cx0_1.mlx) = true
kernel_rfl DEC_clearFill.fnd1_end : ((((DEC_clearFill.cln1).drop 600).drop 600).drop 600).drop 600 = []
theorem DEC_clearFill.fnd1 : (DEC_clearFill.cln1).all (nodeOKF DEC_clearFill.kappa1 DEC_clearFill.P1 DEC_clearFill.cx0_1.mlx DEC_clearFill.cx1_1.mlx) = true :=
  all_take_drop 600 DEC_clearFill.fnd1_0 (all_take_drop 600 DEC_clearFill.fnd1_1 (all_take_drop 600 DEC_clearFill.fnd1_2 (all_take_drop 600 DEC_clearFill.fnd1_3 (all_of_nil DEC_clearFill.fnd1_end))))
kernel_rfl DEC_clearFill.fp1_end : (((((DEC_clearFill.cln1.filter (fullB DEC_clearFill.P1))).drop 600).drop 600).drop 600).drop 600 = []
theorem DEC_clearFill.fp1 : ((DEC_clearFill.cln1.filter (fullB DEC_clearFill.P1))).map (fun i => (DEC_clearFill.cx1_1.mlx.nodes.get (DEC_clearFill.kappa1.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_clearFill.cln1.filter (fullB DEC_clearFill.P1))).map (fun i => (DEC_clearFill.cx0_1.mlx.nodes.get i).map fun nd => DEC_clearFill.kappa1.prim nd.prim) :=
  map_take_drop 600 DEC_clearFill.fp1_0 (map_take_drop 600 DEC_clearFill.fp1_1 (map_take_drop 600 DEC_clearFill.fp1_2 (map_take_drop 600 DEC_clearFill.fp1_3 (map_of_nil DEC_clearFill.fp1_end))))
kernel_rfl DEC_clearFill.fnordI1 : incrB DEC_clearFill.kd1.nodeF (List.range' 22540 2341) = true
kernel_rfl DEC_clearFill.fnordK1 : (PTrie.keysA DEC_clearFill.kd1.node).all (fun k => Nat.ble 22540 k && Nat.blt k 24881) = true
kernel_rfl DEC_clearFill.fnordL1 : (DEC_clearFill.cln1.filter (Nat.ble DEC_clearFill.P1.N0)).all (fun i => Nat.ble i (DEC_clearFill.kd1.nodeF i) && (Nat.blt i 24881 || Nat.ble DEC_clearFill.kd1.nn0 i)) = true
theorem DEC_clearFill.fnord1 : (DEC_clearFill.cln1.filter (Nat.ble DEC_clearFill.P1.N0)).all (fun i => Nat.ble i (DEC_clearFill.kd1.nodeF i) &&
    (PTrie.keysA DEC_clearFill.kd1.node).all fun j => !Nat.blt j i || Nat.blt (DEC_clearFill.kd1.nodeF j) (DEC_clearFill.kd1.nodeF i)) = true :=
  cnord_of DEC_clearFill.cnlow1 DEC_clearFill.cnn11 DEC_clearFill.fnordI1 DEC_clearFill.fnordK1 DEC_clearFill.fnordL1
kernel_rfl DEC_clearFill.fi1 : DEC_clearFill.cli1.all (pnB DEC_clearFill.cx0_1.mlx) = true
kernel_rfl DEC_clearFill.fii1 : DEC_clearFill.cli1.all (fun k => decide (DEC_clearFill.cx1_1.mlx.items.get (DEC_clearFill.kappa1.node k) = (DEC_clearFill.cx0_1.mlx.items.get k).map DEC_clearFill.kappa1.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_clearFill.cfoot1 (clean : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearFill.P1.NL) (cl : SSt (· < 289) DEC_clearFill.cx0_1.mlx) :
    Conv.MFoot DEC_clearFill.P1 289 DEC_clearFill.kappa1 DEC_clearFill.kd1 DEC_clearFill.khinv1 DEC_clearFill.kninv1 (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx DEC_clearFill.cx0_1.mlx DEC_clearFill.cx1_1.mlx (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) DEC_clearFill.clo1 DEC_clearFill.cln1 DEC_clearFill.cli1 DEC_clearFill.cwS1 DEC_clearFill.cnS1 DEC_clearFill.ciS1 :=
  ⟨rfl, rfl, rfl, DEC_clearFill.cnh01, DEC_clearFill.cnh11, DEC_clearFill.cnn01, DEC_clearFill.cnn11, DEC_clearFill.cplo1, DEC_clearFill.ccnt1, DEC_clearFill.cnband1, DEC_clearFill.chbelow1, DEC_clearFill.chren1, DEC_clearFill.cband1, DEC_clearFill.cnh1pos1, DEC_clearFill.cnren1, DEC_clearFill.cnlow1, DEC_clearFill.cabs0a1, DEC_clearFill.cabs0b1, DEC_clearFill.ctok11, DEC_clearFill.cpend1, DEC_clearFill.cerrh1, DEC_clearFill.cfiles1, DEC_clearFill.carch1, DEC_clearFill.csizes1, DEC_clearFill.cwired1, DEC_clearFill.cfix1, clean, DEC_clearFill.fcxn1, DEC_clearFill.fcnn1, hltC, nltC, itemsC, tracedC, cl, DEC_clearFill.fle01, DEC_clearFill.fnk1, DEC_clearFill.ckA1, DEC_clearFill.cobjsK1, DEC_clearFill.cnodesK1, DEC_clearFill.citemsK1, DEC_clearFill.f1A1, DEC_clearFill.f1O1, DEC_clearFill.f1N1, DEC_clearFill.f1I1, DEC_clearFill.fbd1, DEC_clearFill.fincW1, DEC_clearFill.fincI1, DEC_clearFill.fincN1, DEC_clearFill.flnF1, DEC_clearFill.fh1, DEC_clearFill.fo1, DEC_clearFill.fok1, DEC_clearFill.fnd1, DEC_clearFill.fp1, DEC_clearFill.fnord1, DEC_clearFill.fi1, DEC_clearFill.fii1⟩
theorem DEC_clearFill.cnshift1 (clean : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearFill.P1.NL) (cl : SSt (· < 289) DEC_clearFill.cx0_1.mlx) : NShift DEC_clearFill.P1 289 DEC_clearFill.kappa1 DEC_clearFill.cx0_1 DEC_clearFill.cx1_1 :=
  Conv.nshift_of_foot (DEC_clearFill.cfoot1 clean hltC nltC itemsC tracedC cl) DEC_clearFill.chost1 (compact_a_eq DEC_clearFill.ckn01 DEC_clearFill.ckn11 DEC_clearFill.ckheap1 DEC_clearFill.ckpl1)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_clearFill.fxC_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearFill.s4.ffi).getD PTrie.nil
noncomputable def DEC_clearFill.krC_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearFill.s4.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearFill.ofxC_1 : (Host.Ts.Sim.Full.freedOf DEC_clearFill.s4.ffi) = some DEC_clearFill.fxC_1
kernel_rfl DEC_clearFill.okrC_1 : (Host.Ts.Sim.Full.krecOf DEC_clearFill.s4.ffi) = some DEC_clearFill.krC_1
noncomputable def DEC_clearFill.fx0_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearFill.s6.ffi).getD PTrie.nil
noncomputable def DEC_clearFill.kr0_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearFill.s6.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearFill.ofx0_1 : (Host.Ts.Sim.Full.freedOf DEC_clearFill.s6.ffi) = some DEC_clearFill.fx0_1
kernel_rfl DEC_clearFill.okr0_1 : (Host.Ts.Sim.Full.krecOf DEC_clearFill.s6.ffi) = some DEC_clearFill.kr0_1
noncomputable def DEC_clearFill.fx1_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearFill.s5.ffi).getD PTrie.nil
noncomputable def DEC_clearFill.kr1_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearFill.s5.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearFill.ofx1_1 : (Host.Ts.Sim.Full.freedOf DEC_clearFill.s5.ffi) = some DEC_clearFill.fx1_1
kernel_rfl DEC_clearFill.okr1_1 : (Host.Ts.Sim.Full.krecOf DEC_clearFill.s5.ffi) = some DEC_clearFill.kr1_1
kernel_rfl DEC_clearFill.ff01 : DEC_clearFill.fx0_1 = Stage.setAll DEC_clearFill.fxC_1 (DEC_clearFill.clo1.filterMap fun i => (DEC_clearFill.fx0_1.get i).map (i, ·))
kernel_rfl DEC_clearFill.ff11 : DEC_clearFill.fx1_1 = Stage.setAll DEC_clearFill.fxC_1 (DEC_clearFill.cwS1.filterMap fun i => (DEC_clearFill.fx1_1.get i).map (i, ·))
kernel_rfl DEC_clearFill.ffck1 : freedLB DEC_clearFill.kappa1 DEC_clearFill.cx0_1.mlx DEC_clearFill.fx0_1 DEC_clearFill.fx1_1 DEC_clearFill.clo1 = true
kernel_rfl DEC_clearFill.fkf01 : DEC_clearFill.kr0_1.flags = Stage.setAll DEC_clearFill.krC_1.flags (DEC_clearFill.clo1.filterMap fun i => (DEC_clearFill.kr0_1.flags.get i).map (i, ·))
kernel_rfl DEC_clearFill.fkt01 : DEC_clearFill.kr0_1.targs = Stage.setAll DEC_clearFill.krC_1.targs (DEC_clearFill.clo1.filterMap fun i => (DEC_clearFill.kr0_1.targs.get i).map (i, ·))
kernel_rfl DEC_clearFill.fkf11 : DEC_clearFill.kr1_1.flags = Stage.setAll DEC_clearFill.krC_1.flags (DEC_clearFill.cwS1.filterMap fun i => (DEC_clearFill.kr1_1.flags.get i).map (i, ·))
kernel_rfl DEC_clearFill.fkt11 : DEC_clearFill.kr1_1.targs = Stage.setAll DEC_clearFill.krC_1.targs (DEC_clearFill.cwS1.filterMap fun i => (DEC_clearFill.kr1_1.targs.get i).map (i, ·))
kernel_rfl DEC_clearFill.fkck1 : krecLB DEC_clearFill.kappa1 289 DEC_clearFill.cx0_1.mlx DEC_clearFill.kr0_1 DEC_clearFill.kr1_1 DEC_clearFill.clo1 = true
kernel_rfl DEC_clearFill.fkn1 : Nat.ble 129 289 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_clearFill.cbridge1 : Host.Ts.Sim.Full.bridgeOf DEC_clearFill.s5.ffi = Host.Ts.Sim.Full.bridgeOf DEC_clearFill.s6.ffi
kernel_rfl DEC_clearFill.cpendR1 : pendRegB DEC_clearFill.kappa1 (Host.Load.Layers.toLoad DEC_clearFill.s6.ffi).mlx = true
kernel_rfl DEC_clearFill.cpendLe1 : Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s6.ffi).mlx.next (Host.Load.Layers.toLoad DEC_clearFill.s5.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_clearFill.cshift1 (clean : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearFill.P1.NL) (cl : SSt (· < 289) DEC_clearFill.cx0_1.mlx)
    (hobjC : ∀ h, DEC_clearFill.fxC_1.get h = some () → ((Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_clearFill.krC_1.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_clearFill.krC_1.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_clearFill.krC_1.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_clearFill.P1 289 DEC_clearFill.kappa1 DEC_clearFill.s6.ffi DEC_clearFill.s5.ffi :=
  ⟨DEC_clearFill.cnshift1 clean hltC nltC itemsC tracedC cl, DEC_clearFill.cqueue1, fun t ht => bSN_sound (List.all_eq_true.mp DEC_clearFill.ctokSupp1 t ht),
    DEC_clearFill.cbridge1,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clearFill.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clearFill.s5.ffi) (DEC_clearFill.cfoot1 clean hltC nltC itemsC tracedC cl) rfl DEC_clearFill.ofx0_1 DEC_clearFill.ofx1_1 hobjC DEC_clearFill.ff01 DEC_clearFill.ff11 DEC_clearFill.ffck1,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clearFill.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clearFill.s5.ffi) (DEC_clearFill.cfoot1 clean hltC nltC itemsC tracedC cl) rfl DEC_clearFill.okr0_1 DEC_clearFill.okr1_1 (Nat.le_of_ble_eq_true DEC_clearFill.fkn1) hfC htC hclC
      DEC_clearFill.fkf01 DEC_clearFill.fkt01 DEC_clearFill.fkf11 DEC_clearFill.fkt11 DEC_clearFill.fkck1,
    pendReg_of rfl DEC_clearFill.cnh01 DEC_clearFill.cnh11 (Nat.le_of_ble_eq_true DEC_clearFill.cpendLe1) DEC_clearFill.cpendR1⟩

end Host.Load.Run.Tpl
