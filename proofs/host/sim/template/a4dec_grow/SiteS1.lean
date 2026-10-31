import host.sim.template.a4dec_grow.SiteSn1_0
import host.sim.template.a4dec_grow.SiteSn1_1
import host.sim.template.a4dec_grow.SiteSn1_2
import host.sim.template.a4dec_grow.SiteSn1_3
import host.sim.template.a4dec_grow.SiteSn1_4
import host.sim.template.a4dec_grow.SiteSn1_5
import host.sim.template.a4dec_grow.SiteSn1_6
import host.sim.template.a4dec_grow.SiteSn1_7
import host.sim.template.a4dec_grow.SiteSn1_8
import host.sim.template.a4dec_grow.SiteSn1_9
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

-- the checks over the changed lists
kernel_rfl DEC_grow.fh1 : DEC_grow.clo1.all (handleOK DEC_grow.kappa1 DEC_grow.P1.lo DEC_grow.cx0_1.mlx DEC_grow.cx1_1.mlx) = true
kernel_rfl DEC_grow.fo1 : DEC_grow.clo1.map (fun h => DEC_grow.cx1_1.mlx.objs.get (DEC_grow.kappa1.handle h)) = DEC_grow.clo1.map (fun h => (DEC_grow.cx0_1.mlx.objs.get h).map DEC_grow.kappa1.nobj)
kernel_rfl DEC_grow.fok1 : DEC_grow.clo1.all (objOK DEC_grow.kappa1 DEC_grow.P1.NL DEC_grow.cx0_1.mlx) = true
kernel_rfl DEC_grow.fnd1_end : (((((DEC_grow.cln1).drop 600).drop 600).drop 600).drop 600).drop 600 = []
theorem DEC_grow.fnd1 : (DEC_grow.cln1).all (nodeOKF DEC_grow.kappa1 DEC_grow.P1 DEC_grow.cx0_1.mlx DEC_grow.cx1_1.mlx) = true :=
  all_take_drop 600 DEC_grow.fnd1_0 (all_take_drop 600 DEC_grow.fnd1_1 (all_take_drop 600 DEC_grow.fnd1_2 (all_take_drop 600 DEC_grow.fnd1_3 (all_take_drop 600 DEC_grow.fnd1_4 (all_of_nil DEC_grow.fnd1_end)))))
kernel_rfl DEC_grow.fp1_end : ((((((DEC_grow.cln1.filter (fullB DEC_grow.P1))).drop 600).drop 600).drop 600).drop 600).drop 600 = []
theorem DEC_grow.fp1 : ((DEC_grow.cln1.filter (fullB DEC_grow.P1))).map (fun i => (DEC_grow.cx1_1.mlx.nodes.get (DEC_grow.kappa1.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_grow.cln1.filter (fullB DEC_grow.P1))).map (fun i => (DEC_grow.cx0_1.mlx.nodes.get i).map fun nd => DEC_grow.kappa1.prim nd.prim) :=
  map_take_drop 600 DEC_grow.fp1_0 (map_take_drop 600 DEC_grow.fp1_1 (map_take_drop 600 DEC_grow.fp1_2 (map_take_drop 600 DEC_grow.fp1_3 (map_take_drop 600 DEC_grow.fp1_4 (map_of_nil DEC_grow.fp1_end)))))
kernel_rfl DEC_grow.fnordI1 : incrB DEC_grow.kd1.nodeF (List.range' 22540 2437) = true
kernel_rfl DEC_grow.fnordK1 : (PTrie.keysA DEC_grow.kd1.node).all (fun k => Nat.ble 22540 k && Nat.blt k 24977) = true
kernel_rfl DEC_grow.fnordL1 : (DEC_grow.cln1.filter (Nat.ble DEC_grow.P1.N0)).all (fun i => Nat.ble i (DEC_grow.kd1.nodeF i) && (Nat.blt i 24977 || Nat.ble DEC_grow.kd1.nn0 i)) = true
theorem DEC_grow.fnord1 : (DEC_grow.cln1.filter (Nat.ble DEC_grow.P1.N0)).all (fun i => Nat.ble i (DEC_grow.kd1.nodeF i) &&
    (PTrie.keysA DEC_grow.kd1.node).all fun j => !Nat.blt j i || Nat.blt (DEC_grow.kd1.nodeF j) (DEC_grow.kd1.nodeF i)) = true :=
  cnord_of DEC_grow.cnlow1 DEC_grow.cnn11 DEC_grow.fnordI1 DEC_grow.fnordK1 DEC_grow.fnordL1
kernel_rfl DEC_grow.fi1 : DEC_grow.cli1.all (pnB DEC_grow.cx0_1.mlx) = true
kernel_rfl DEC_grow.fii1 : DEC_grow.cli1.all (fun k => decide (DEC_grow.cx1_1.mlx.items.get (DEC_grow.kappa1.node k) = (DEC_grow.cx0_1.mlx.items.get k).map DEC_grow.kappa1.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_grow.cfoot1 (clean : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_grow.P1.NL) (cl : SSt (· < 385) DEC_grow.cx0_1.mlx) :
    Conv.MFoot DEC_grow.P1 385 DEC_grow.kappa1 DEC_grow.kd1 DEC_grow.khinv1 DEC_grow.kninv1 (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx DEC_grow.cx0_1.mlx DEC_grow.cx1_1.mlx (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) DEC_grow.clo1 DEC_grow.cln1 DEC_grow.cli1 DEC_grow.cwS1 DEC_grow.cnS1 DEC_grow.ciS1 :=
  ⟨rfl, rfl, rfl, DEC_grow.cnh01, DEC_grow.cnh11, DEC_grow.cnn01, DEC_grow.cnn11, DEC_grow.cplo1, DEC_grow.ccnt1, DEC_grow.cnband1, DEC_grow.chbelow1, DEC_grow.chren1, DEC_grow.cband1, DEC_grow.cnh1pos1, DEC_grow.cnren1, DEC_grow.cnlow1, DEC_grow.cabs0a1, DEC_grow.cabs0b1, DEC_grow.ctok11, DEC_grow.cpend1, DEC_grow.cerrh1, DEC_grow.cfiles1, DEC_grow.carch1, DEC_grow.csizes1, DEC_grow.cwired1, DEC_grow.cfix1, clean, DEC_grow.fcxn1, DEC_grow.fcnn1, hltC, nltC, itemsC, tracedC, cl, DEC_grow.fle01, DEC_grow.fnk1, DEC_grow.ckA1, DEC_grow.cobjsK1, DEC_grow.cnodesK1, DEC_grow.citemsK1, DEC_grow.f1A1, DEC_grow.f1O1, DEC_grow.f1N1, DEC_grow.f1I1, DEC_grow.fbd1, DEC_grow.fincW1, DEC_grow.fincI1, DEC_grow.fincN1, DEC_grow.flnF1, DEC_grow.fh1, DEC_grow.fo1, DEC_grow.fok1, DEC_grow.fnd1, DEC_grow.fp1, DEC_grow.fnord1, DEC_grow.fi1, DEC_grow.fii1⟩
theorem DEC_grow.cnshift1 (clean : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_grow.P1.NL) (cl : SSt (· < 385) DEC_grow.cx0_1.mlx) : NShift DEC_grow.P1 385 DEC_grow.kappa1 DEC_grow.cx0_1 DEC_grow.cx1_1 :=
  Conv.nshift_of_foot (DEC_grow.cfoot1 clean hltC nltC itemsC tracedC cl) DEC_grow.chost1 (compact_a_eq DEC_grow.ckn01 DEC_grow.ckn11 DEC_grow.ckheap1 DEC_grow.ckpl1)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_grow.fxC_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_grow.s4.ffi).getD PTrie.nil
noncomputable def DEC_grow.krC_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_grow.s4.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_grow.ofxC_1 : (Host.Ts.Sim.Full.freedOf DEC_grow.s4.ffi) = some DEC_grow.fxC_1
kernel_rfl DEC_grow.okrC_1 : (Host.Ts.Sim.Full.krecOf DEC_grow.s4.ffi) = some DEC_grow.krC_1
noncomputable def DEC_grow.fx0_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_grow.s6.ffi).getD PTrie.nil
noncomputable def DEC_grow.kr0_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_grow.s6.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_grow.ofx0_1 : (Host.Ts.Sim.Full.freedOf DEC_grow.s6.ffi) = some DEC_grow.fx0_1
kernel_rfl DEC_grow.okr0_1 : (Host.Ts.Sim.Full.krecOf DEC_grow.s6.ffi) = some DEC_grow.kr0_1
noncomputable def DEC_grow.fx1_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_grow.s5.ffi).getD PTrie.nil
noncomputable def DEC_grow.kr1_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_grow.s5.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_grow.ofx1_1 : (Host.Ts.Sim.Full.freedOf DEC_grow.s5.ffi) = some DEC_grow.fx1_1
kernel_rfl DEC_grow.okr1_1 : (Host.Ts.Sim.Full.krecOf DEC_grow.s5.ffi) = some DEC_grow.kr1_1
kernel_rfl DEC_grow.ff01 : DEC_grow.fx0_1 = Stage.setAll DEC_grow.fxC_1 (DEC_grow.clo1.filterMap fun i => (DEC_grow.fx0_1.get i).map (i, ·))
kernel_rfl DEC_grow.ff11 : DEC_grow.fx1_1 = Stage.setAll DEC_grow.fxC_1 (DEC_grow.cwS1.filterMap fun i => (DEC_grow.fx1_1.get i).map (i, ·))
kernel_rfl DEC_grow.ffck1 : freedLB DEC_grow.kappa1 DEC_grow.cx0_1.mlx DEC_grow.fx0_1 DEC_grow.fx1_1 DEC_grow.clo1 = true
kernel_rfl DEC_grow.fkf01 : DEC_grow.kr0_1.flags = Stage.setAll DEC_grow.krC_1.flags (DEC_grow.clo1.filterMap fun i => (DEC_grow.kr0_1.flags.get i).map (i, ·))
kernel_rfl DEC_grow.fkt01 : DEC_grow.kr0_1.targs = Stage.setAll DEC_grow.krC_1.targs (DEC_grow.clo1.filterMap fun i => (DEC_grow.kr0_1.targs.get i).map (i, ·))
kernel_rfl DEC_grow.fkf11 : DEC_grow.kr1_1.flags = Stage.setAll DEC_grow.krC_1.flags (DEC_grow.cwS1.filterMap fun i => (DEC_grow.kr1_1.flags.get i).map (i, ·))
kernel_rfl DEC_grow.fkt11 : DEC_grow.kr1_1.targs = Stage.setAll DEC_grow.krC_1.targs (DEC_grow.cwS1.filterMap fun i => (DEC_grow.kr1_1.targs.get i).map (i, ·))
kernel_rfl DEC_grow.fkck1 : krecLB DEC_grow.kappa1 385 DEC_grow.cx0_1.mlx DEC_grow.kr0_1 DEC_grow.kr1_1 DEC_grow.clo1 = true
kernel_rfl DEC_grow.fkn1 : Nat.ble 129 385 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_grow.cbridge1 : Host.Ts.Sim.Full.bridgeOf DEC_grow.s5.ffi = Host.Ts.Sim.Full.bridgeOf DEC_grow.s6.ffi
kernel_rfl DEC_grow.cpendR1 : pendRegB DEC_grow.kappa1 (Host.Load.Layers.toLoad DEC_grow.s6.ffi).mlx = true
kernel_rfl DEC_grow.cpendLe1 : Nat.ble (Host.Load.Layers.toLoad DEC_grow.s6.ffi).mlx.next (Host.Load.Layers.toLoad DEC_grow.s5.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_grow.cshift1 (clean : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_grow.P1.NL) (cl : SSt (· < 385) DEC_grow.cx0_1.mlx)
    (hobjC : ∀ h, DEC_grow.fxC_1.get h = some () → ((Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_grow.krC_1.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_grow.krC_1.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_grow.krC_1.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_grow.P1 385 DEC_grow.kappa1 DEC_grow.s6.ffi DEC_grow.s5.ffi :=
  ⟨DEC_grow.cnshift1 clean hltC nltC itemsC tracedC cl, DEC_grow.cqueue1, fun t ht => bSN_sound (List.all_eq_true.mp DEC_grow.ctokSupp1 t ht),
    DEC_grow.cbridge1,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_grow.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_grow.s5.ffi) (DEC_grow.cfoot1 clean hltC nltC itemsC tracedC cl) rfl DEC_grow.ofx0_1 DEC_grow.ofx1_1 hobjC DEC_grow.ff01 DEC_grow.ff11 DEC_grow.ffck1,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_grow.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_grow.s5.ffi) (DEC_grow.cfoot1 clean hltC nltC itemsC tracedC cl) rfl DEC_grow.okr0_1 DEC_grow.okr1_1 (Nat.le_of_ble_eq_true DEC_grow.fkn1) hfC htC hclC
      DEC_grow.fkf01 DEC_grow.fkt01 DEC_grow.fkf11 DEC_grow.fkt11 DEC_grow.fkck1,
    pendReg_of rfl DEC_grow.cnh01 DEC_grow.cnh11 (Nat.le_of_ble_eq_true DEC_grow.cpendLe1) DEC_grow.cpendR1⟩

end Host.Load.Run.Tpl
