import host.sim.template.a4dec_clearGrow.SiteSn1_0
import host.sim.template.a4dec_clearGrow.SiteSn1_1
import host.sim.template.a4dec_clearGrow.SiteSn1_2
import host.sim.template.a4dec_clearGrow.SiteSn1_3
import host.sim.template.a4dec_clearGrow.SiteSn1_4
import host.sim.template.a4dec_clearGrow.SiteSn1_5
import host.sim.template.a4dec_clearGrow.SiteSn1_6
import host.sim.template.a4dec_clearGrow.SiteSn1_7
import host.sim.template.a4dec_clearGrow.SiteSn1_8
import host.sim.template.a4dec_clearGrow.SiteSn1_9
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

-- the checks over the changed lists
kernel_rfl DEC_clearGrow.fh1 : DEC_clearGrow.clo1.all (handleOK DEC_clearGrow.kappa1 DEC_clearGrow.P1.lo DEC_clearGrow.cx0_1.mlx DEC_clearGrow.cx1_1.mlx) = true
kernel_rfl DEC_clearGrow.fo1 : DEC_clearGrow.clo1.map (fun h => DEC_clearGrow.cx1_1.mlx.objs.get (DEC_clearGrow.kappa1.handle h)) = DEC_clearGrow.clo1.map (fun h => (DEC_clearGrow.cx0_1.mlx.objs.get h).map DEC_clearGrow.kappa1.nobj)
kernel_rfl DEC_clearGrow.fok1 : DEC_clearGrow.clo1.all (objOK DEC_clearGrow.kappa1 DEC_clearGrow.P1.NL DEC_clearGrow.cx0_1.mlx) = true
kernel_rfl DEC_clearGrow.fnd1_end : (((((DEC_clearGrow.cln1).drop 600).drop 600).drop 600).drop 600).drop 600 = []
theorem DEC_clearGrow.fnd1 : (DEC_clearGrow.cln1).all (nodeOKF DEC_clearGrow.kappa1 DEC_clearGrow.P1 DEC_clearGrow.cx0_1.mlx DEC_clearGrow.cx1_1.mlx) = true :=
  all_take_drop 600 DEC_clearGrow.fnd1_0 (all_take_drop 600 DEC_clearGrow.fnd1_1 (all_take_drop 600 DEC_clearGrow.fnd1_2 (all_take_drop 600 DEC_clearGrow.fnd1_3 (all_take_drop 600 DEC_clearGrow.fnd1_4 (all_of_nil DEC_clearGrow.fnd1_end)))))
kernel_rfl DEC_clearGrow.fp1_end : ((((((DEC_clearGrow.cln1.filter (fullB DEC_clearGrow.P1))).drop 600).drop 600).drop 600).drop 600).drop 600 = []
theorem DEC_clearGrow.fp1 : ((DEC_clearGrow.cln1.filter (fullB DEC_clearGrow.P1))).map (fun i => (DEC_clearGrow.cx1_1.mlx.nodes.get (DEC_clearGrow.kappa1.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_clearGrow.cln1.filter (fullB DEC_clearGrow.P1))).map (fun i => (DEC_clearGrow.cx0_1.mlx.nodes.get i).map fun nd => DEC_clearGrow.kappa1.prim nd.prim) :=
  map_take_drop 600 DEC_clearGrow.fp1_0 (map_take_drop 600 DEC_clearGrow.fp1_1 (map_take_drop 600 DEC_clearGrow.fp1_2 (map_take_drop 600 DEC_clearGrow.fp1_3 (map_take_drop 600 DEC_clearGrow.fp1_4 (map_of_nil DEC_clearGrow.fp1_end)))))
kernel_rfl DEC_clearGrow.fnordI1 : incrB DEC_clearGrow.kd1.nodeF (List.range' 22540 2437) = true
kernel_rfl DEC_clearGrow.fnordK1 : (PTrie.keysA DEC_clearGrow.kd1.node).all (fun k => Nat.ble 22540 k && Nat.blt k 24977) = true
kernel_rfl DEC_clearGrow.fnordL1 : (DEC_clearGrow.cln1.filter (Nat.ble DEC_clearGrow.P1.N0)).all (fun i => Nat.ble i (DEC_clearGrow.kd1.nodeF i) && (Nat.blt i 24977 || Nat.ble DEC_clearGrow.kd1.nn0 i)) = true
theorem DEC_clearGrow.fnord1 : (DEC_clearGrow.cln1.filter (Nat.ble DEC_clearGrow.P1.N0)).all (fun i => Nat.ble i (DEC_clearGrow.kd1.nodeF i) &&
    (PTrie.keysA DEC_clearGrow.kd1.node).all fun j => !Nat.blt j i || Nat.blt (DEC_clearGrow.kd1.nodeF j) (DEC_clearGrow.kd1.nodeF i)) = true :=
  cnord_of DEC_clearGrow.cnlow1 DEC_clearGrow.cnn11 DEC_clearGrow.fnordI1 DEC_clearGrow.fnordK1 DEC_clearGrow.fnordL1
kernel_rfl DEC_clearGrow.fi1 : DEC_clearGrow.cli1.all (pnB DEC_clearGrow.cx0_1.mlx) = true
kernel_rfl DEC_clearGrow.fii1 : DEC_clearGrow.cli1.all (fun k => decide (DEC_clearGrow.cx1_1.mlx.items.get (DEC_clearGrow.kappa1.node k) = (DEC_clearGrow.cx0_1.mlx.items.get k).map DEC_clearGrow.kappa1.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_clearGrow.cfoot1 (clean : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearGrow.P1.NL) (cl : SSt (· < 385) DEC_clearGrow.cx0_1.mlx) :
    Conv.MFoot DEC_clearGrow.P1 385 DEC_clearGrow.kappa1 DEC_clearGrow.kd1 DEC_clearGrow.khinv1 DEC_clearGrow.kninv1 (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx DEC_clearGrow.cx0_1.mlx DEC_clearGrow.cx1_1.mlx (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) DEC_clearGrow.clo1 DEC_clearGrow.cln1 DEC_clearGrow.cli1 DEC_clearGrow.cwS1 DEC_clearGrow.cnS1 DEC_clearGrow.ciS1 :=
  ⟨rfl, rfl, rfl, DEC_clearGrow.cnh01, DEC_clearGrow.cnh11, DEC_clearGrow.cnn01, DEC_clearGrow.cnn11, DEC_clearGrow.cplo1, DEC_clearGrow.ccnt1, DEC_clearGrow.cnband1, DEC_clearGrow.chbelow1, DEC_clearGrow.chren1, DEC_clearGrow.cband1, DEC_clearGrow.cnh1pos1, DEC_clearGrow.cnren1, DEC_clearGrow.cnlow1, DEC_clearGrow.cabs0a1, DEC_clearGrow.cabs0b1, DEC_clearGrow.ctok11, DEC_clearGrow.cpend1, DEC_clearGrow.cerrh1, DEC_clearGrow.cfiles1, DEC_clearGrow.carch1, DEC_clearGrow.csizes1, DEC_clearGrow.cwired1, DEC_clearGrow.cfix1, clean, DEC_clearGrow.fcxn1, DEC_clearGrow.fcnn1, hltC, nltC, itemsC, tracedC, cl, DEC_clearGrow.fle01, DEC_clearGrow.fnk1, DEC_clearGrow.ckA1, DEC_clearGrow.cobjsK1, DEC_clearGrow.cnodesK1, DEC_clearGrow.citemsK1, DEC_clearGrow.f1A1, DEC_clearGrow.f1O1, DEC_clearGrow.f1N1, DEC_clearGrow.f1I1, DEC_clearGrow.fbd1, DEC_clearGrow.fincW1, DEC_clearGrow.fincI1, DEC_clearGrow.fincN1, DEC_clearGrow.flnF1, DEC_clearGrow.fh1, DEC_clearGrow.fo1, DEC_clearGrow.fok1, DEC_clearGrow.fnd1, DEC_clearGrow.fp1, DEC_clearGrow.fnord1, DEC_clearGrow.fi1, DEC_clearGrow.fii1⟩
theorem DEC_clearGrow.cnshift1 (clean : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearGrow.P1.NL) (cl : SSt (· < 385) DEC_clearGrow.cx0_1.mlx) : NShift DEC_clearGrow.P1 385 DEC_clearGrow.kappa1 DEC_clearGrow.cx0_1 DEC_clearGrow.cx1_1 :=
  Conv.nshift_of_foot (DEC_clearGrow.cfoot1 clean hltC nltC itemsC tracedC cl) DEC_clearGrow.chost1 (compact_a_eq DEC_clearGrow.ckn01 DEC_clearGrow.ckn11 DEC_clearGrow.ckheap1 DEC_clearGrow.ckpl1)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_clearGrow.fxC_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s4.ffi).getD PTrie.nil
noncomputable def DEC_clearGrow.krC_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s4.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearGrow.ofxC_1 : (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s4.ffi) = some DEC_clearGrow.fxC_1
kernel_rfl DEC_clearGrow.okrC_1 : (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s4.ffi) = some DEC_clearGrow.krC_1
noncomputable def DEC_clearGrow.fx0_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s6.ffi).getD PTrie.nil
noncomputable def DEC_clearGrow.kr0_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s6.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearGrow.ofx0_1 : (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s6.ffi) = some DEC_clearGrow.fx0_1
kernel_rfl DEC_clearGrow.okr0_1 : (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s6.ffi) = some DEC_clearGrow.kr0_1
noncomputable def DEC_clearGrow.fx1_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s5.ffi).getD PTrie.nil
noncomputable def DEC_clearGrow.kr1_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s5.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearGrow.ofx1_1 : (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s5.ffi) = some DEC_clearGrow.fx1_1
kernel_rfl DEC_clearGrow.okr1_1 : (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s5.ffi) = some DEC_clearGrow.kr1_1
kernel_rfl DEC_clearGrow.ff01 : DEC_clearGrow.fx0_1 = Stage.setAll DEC_clearGrow.fxC_1 (DEC_clearGrow.clo1.filterMap fun i => (DEC_clearGrow.fx0_1.get i).map (i, ·))
kernel_rfl DEC_clearGrow.ff11 : DEC_clearGrow.fx1_1 = Stage.setAll DEC_clearGrow.fxC_1 (DEC_clearGrow.cwS1.filterMap fun i => (DEC_clearGrow.fx1_1.get i).map (i, ·))
kernel_rfl DEC_clearGrow.ffck1 : freedLB DEC_clearGrow.kappa1 DEC_clearGrow.cx0_1.mlx DEC_clearGrow.fx0_1 DEC_clearGrow.fx1_1 DEC_clearGrow.clo1 = true
kernel_rfl DEC_clearGrow.fkf01 : DEC_clearGrow.kr0_1.flags = Stage.setAll DEC_clearGrow.krC_1.flags (DEC_clearGrow.clo1.filterMap fun i => (DEC_clearGrow.kr0_1.flags.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fkt01 : DEC_clearGrow.kr0_1.targs = Stage.setAll DEC_clearGrow.krC_1.targs (DEC_clearGrow.clo1.filterMap fun i => (DEC_clearGrow.kr0_1.targs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fkf11 : DEC_clearGrow.kr1_1.flags = Stage.setAll DEC_clearGrow.krC_1.flags (DEC_clearGrow.cwS1.filterMap fun i => (DEC_clearGrow.kr1_1.flags.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fkt11 : DEC_clearGrow.kr1_1.targs = Stage.setAll DEC_clearGrow.krC_1.targs (DEC_clearGrow.cwS1.filterMap fun i => (DEC_clearGrow.kr1_1.targs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fkck1 : krecLB DEC_clearGrow.kappa1 385 DEC_clearGrow.cx0_1.mlx DEC_clearGrow.kr0_1 DEC_clearGrow.kr1_1 DEC_clearGrow.clo1 = true
kernel_rfl DEC_clearGrow.fkn1 : Nat.ble 129 385 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_clearGrow.cbridge1 : Host.Ts.Sim.Full.bridgeOf DEC_clearGrow.s5.ffi = Host.Ts.Sim.Full.bridgeOf DEC_clearGrow.s6.ffi
kernel_rfl DEC_clearGrow.cpendR1 : pendRegB DEC_clearGrow.kappa1 (Host.Load.Layers.toLoad DEC_clearGrow.s6.ffi).mlx = true
kernel_rfl DEC_clearGrow.cpendLe1 : Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s6.ffi).mlx.next (Host.Load.Layers.toLoad DEC_clearGrow.s5.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_clearGrow.cshift1 (clean : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearGrow.P1.NL) (cl : SSt (· < 385) DEC_clearGrow.cx0_1.mlx)
    (hobjC : ∀ h, DEC_clearGrow.fxC_1.get h = some () → ((Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_clearGrow.krC_1.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_clearGrow.krC_1.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_clearGrow.krC_1.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_clearGrow.P1 385 DEC_clearGrow.kappa1 DEC_clearGrow.s6.ffi DEC_clearGrow.s5.ffi :=
  ⟨DEC_clearGrow.cnshift1 clean hltC nltC itemsC tracedC cl, DEC_clearGrow.cqueue1, fun t ht => bSN_sound (List.all_eq_true.mp DEC_clearGrow.ctokSupp1 t ht),
    DEC_clearGrow.cbridge1,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s5.ffi) (DEC_clearGrow.cfoot1 clean hltC nltC itemsC tracedC cl) rfl DEC_clearGrow.ofx0_1 DEC_clearGrow.ofx1_1 hobjC DEC_clearGrow.ff01 DEC_clearGrow.ff11 DEC_clearGrow.ffck1,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s5.ffi) (DEC_clearGrow.cfoot1 clean hltC nltC itemsC tracedC cl) rfl DEC_clearGrow.okr0_1 DEC_clearGrow.okr1_1 (Nat.le_of_ble_eq_true DEC_clearGrow.fkn1) hfC htC hclC
      DEC_clearGrow.fkf01 DEC_clearGrow.fkt01 DEC_clearGrow.fkf11 DEC_clearGrow.fkt11 DEC_clearGrow.fkck1,
    pendReg_of rfl DEC_clearGrow.cnh01 DEC_clearGrow.cnh11 (Nat.le_of_ble_eq_true DEC_clearGrow.cpendLe1) DEC_clearGrow.cpendR1⟩

end Host.Load.Run.Tpl
