import host.sim.compose.PostChain
import host.sim.template.a4pre_pl_r2.Good
import host.sim.template.a4pre_pl_r2.K0
import host.sim.template.a4pre_pl_r2.K1
import host.sim.template.a4pre_pl_r2.K2
import host.sim.template.a4pre_pl_r2.K3
import host.sim.template.a4pre_pl_r2.K4
import host.sim.template.a4pre_pl_r2.Accept0
import host.sim.template.a4pre_pl_r2.Size0
import host.sim.template.a4pre_pl_r2.H0
import host.sim.template.a4pre_pl_r2.K7
import host.sim.template.a4pre_pl_r2.K8
import host.sim.template.a4pre_pl_r2.K9
import host.sim.template.a4pre_pl_r2.Size1
import host.sim.template.a4pre_pl_r2.K12
import host.sim.template.a4pre_pl_r2.Size2
import host.sim.template.a4pre_pl_r2.K15
import host.sim.template.a4pre_pl_r2.K16
import host.sim.template.a4pre_pl_r2.K17
import host.sim.template.a4pre_pl_r2.K18
import host.sim.template.a4pre_pl_r2.K19
import host.sim.template.a4pre_pl_r2.Size3
import host.sim.template.a4pre_pl_r2.K22
import host.sim.template.a4pre_pl_r2.K23
import host.sim.template.a4pre_pl_r2.K24
import host.sim.template.a4pre_pl_r2.Size4
import host.sim.template.a4pre_pl_r2.K27
import host.sim.template.a4pre_pl_r2.Size5
import host.sim.template.a4pre_pl_r2.K30
import host.sim.template.a4pre_pl_r2.K31
import host.sim.template.a4pre_pl_r2.K32
import host.sim.template.a4pre_pl_r2.K33
import host.sim.template.a4pre_pl_r2.K34
import host.sim.template.a4pre_pl_r2.Size6
import host.sim.template.a4pre_pl_r2.H1
import host.sim.template.a4pre_pl_r2.K37
import host.sim.template.a4pre_pl_r2.K38
import host.sim.template.a4pre_pl_r2.K39
import host.sim.template.a4pre_pl_r2.K40
import host.sim.template.a4pre_pl_r2.K41
import host.sim.template.a4pre_pl_r2.K42
import host.sim.template.a4pre_pl_r2.K43
import host.sim.template.a4pre_pl_r2.Size7
import host.sim.template.a4pre_pl_r2.K46
import host.sim.template.a4pre_pl_r2.K47
import host.sim.template.a4pre_pl_r2.K48
import host.sim.template.a4pre_pl_r2.Size8
import host.sim.template.a4pre_pl_r2.K51
import host.sim.template.a4pre_pl_r2.K52
import host.sim.template.a4pre_pl_r2.K53
import host.sim.template.a4pre_pl_r2.K54
import host.sim.template.a4pre_pl_r2.K55
import host.sim.template.a4pre_pl_r2.Size9
import host.sim.template.a4pre_pl_r2.K58
import host.sim.template.a4pre_pl_r2.K59
import host.sim.template.a4pre_pl_r2.K60
import host.sim.template.a4pre_pl_r2.Accept1
import host.sim.template.a4pre_pl_r2.Size10
import host.sim.template.a4pre_pl_r2.K63
import host.sim.template.a4pre_pl_r2.K64
import host.sim.template.a4pre_pl_r2.K65
import host.sim.template.a4pre_pl_r2.K66
import host.sim.template.a4pre_pl_r2.K67
import host.sim.template.a4pre_pl_r2.Size11
import host.sim.template.a4pre_pl_r2.H2
import host.sim.template.a4pre_pl_r2.K70
import host.sim.template.a4pre_pl_r2.K71
import host.sim.template.a4pre_pl_r2.K72
import host.sim.template.a4pre_pl_r2.Size12
import host.sim.template.a4pre_pl_r2.K75
import host.sim.template.a4pre_pl_r2.Size13
import host.sim.template.a4pre_pl_r2.K78
import host.sim.template.a4pre_pl_r2.K79
import host.sim.template.a4pre_pl_r2.K80
import host.sim.template.a4pre_pl_r2.K81
import host.sim.template.a4pre_pl_r2.Size14
import host.sim.template.a4pre_pl_r2.K84
import host.sim.template.a4pre_pl_r2.Size15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.R2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl live5 : isHalt PRE_pl_r2.s5.ctl = false
kernel_rfl br0_6 : bridgeOf PRE_pl_r2.s6.ffi = bridgeOf PRE_pl_r2.s0.ffi
kernel_rfl cnt0_6 : countersOkB PRE_pl_r2.s0 PRE_pl_r2.s6 = true
kernel_rfl oa6 : PRE_pl_r2.S6.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S6.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt6_7 : countersOkB PRE_pl_r2.s6 PRE_pl_r2.s7 = true
kernel_rfl oa7 : PRE_pl_r2.S7.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S7.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live10 : isHalt PRE_pl_r2.s10.ctl = false
kernel_rfl br7_11 : bridgeOf PRE_pl_r2.s11.ffi = bridgeOf PRE_pl_r2.s7.ffi
kernel_rfl cnt7_11 : countersOkB PRE_pl_r2.s7 PRE_pl_r2.s11 = true
kernel_rfl oa11 : PRE_pl_r2.S11.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S11.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt11_12 : countersOkB PRE_pl_r2.s11 PRE_pl_r2.s12 = true
kernel_rfl oa12 : PRE_pl_r2.S12.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S12.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live13 : isHalt PRE_pl_r2.s13.ctl = false
kernel_rfl br12_14 : bridgeOf PRE_pl_r2.s14.ffi = bridgeOf PRE_pl_r2.s12.ffi
kernel_rfl cnt12_14 : countersOkB PRE_pl_r2.s12 PRE_pl_r2.s14 = true
kernel_rfl oa14 : PRE_pl_r2.S14.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S14.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt14_15 : countersOkB PRE_pl_r2.s14 PRE_pl_r2.s15 = true
kernel_rfl oa15 : PRE_pl_r2.S15.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S15.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live20 : isHalt PRE_pl_r2.s20.ctl = false
kernel_rfl br15_21 : bridgeOf PRE_pl_r2.s21.ffi = bridgeOf PRE_pl_r2.s15.ffi
kernel_rfl cnt15_21 : countersOkB PRE_pl_r2.s15 PRE_pl_r2.s21 = true
kernel_rfl oa21 : PRE_pl_r2.S21.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S21.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt21_22 : countersOkB PRE_pl_r2.s21 PRE_pl_r2.s22 = true
kernel_rfl oa22 : PRE_pl_r2.S22.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S22.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live25 : isHalt PRE_pl_r2.s25.ctl = false
kernel_rfl br22_26 : bridgeOf PRE_pl_r2.s26.ffi = bridgeOf PRE_pl_r2.s22.ffi
kernel_rfl cnt22_26 : countersOkB PRE_pl_r2.s22 PRE_pl_r2.s26 = true
kernel_rfl oa26 : PRE_pl_r2.S26.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S26.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt26_27 : countersOkB PRE_pl_r2.s26 PRE_pl_r2.s27 = true
kernel_rfl oa27 : PRE_pl_r2.S27.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S27.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live28 : isHalt PRE_pl_r2.s28.ctl = false
kernel_rfl br27_29 : bridgeOf PRE_pl_r2.s29.ffi = bridgeOf PRE_pl_r2.s27.ffi
kernel_rfl cnt27_29 : countersOkB PRE_pl_r2.s27 PRE_pl_r2.s29 = true
kernel_rfl oa29 : PRE_pl_r2.S29.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S29.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt29_30 : countersOkB PRE_pl_r2.s29 PRE_pl_r2.s30 = true
kernel_rfl oa30 : PRE_pl_r2.S30.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S30.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live35 : isHalt PRE_pl_r2.s35.ctl = false
kernel_rfl br30_36 : bridgeOf PRE_pl_r2.s36.ffi = bridgeOf PRE_pl_r2.s30.ffi
kernel_rfl cnt30_36 : countersOkB PRE_pl_r2.s30 PRE_pl_r2.s36 = true
kernel_rfl oa36 : PRE_pl_r2.S36.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S36.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt36_37 : countersOkB PRE_pl_r2.s36 PRE_pl_r2.s37 = true
kernel_rfl oa37 : PRE_pl_r2.S37.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S37.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live44 : isHalt PRE_pl_r2.s44.ctl = false
kernel_rfl br37_45 : bridgeOf PRE_pl_r2.s45.ffi = bridgeOf PRE_pl_r2.s37.ffi
kernel_rfl cnt37_45 : countersOkB PRE_pl_r2.s37 PRE_pl_r2.s45 = true
kernel_rfl oa45 : PRE_pl_r2.S45.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S45.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt45_46 : countersOkB PRE_pl_r2.s45 PRE_pl_r2.s46 = true
kernel_rfl oa46 : PRE_pl_r2.S46.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S46.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live49 : isHalt PRE_pl_r2.s49.ctl = false
kernel_rfl br46_50 : bridgeOf PRE_pl_r2.s50.ffi = bridgeOf PRE_pl_r2.s46.ffi
kernel_rfl cnt46_50 : countersOkB PRE_pl_r2.s46 PRE_pl_r2.s50 = true
kernel_rfl oa50 : PRE_pl_r2.S50.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S50.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt50_51 : countersOkB PRE_pl_r2.s50 PRE_pl_r2.s51 = true
kernel_rfl oa51 : PRE_pl_r2.S51.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S51.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live56 : isHalt PRE_pl_r2.s56.ctl = false
kernel_rfl br51_57 : bridgeOf PRE_pl_r2.s57.ffi = bridgeOf PRE_pl_r2.s51.ffi
kernel_rfl cnt51_57 : countersOkB PRE_pl_r2.s51 PRE_pl_r2.s57 = true
kernel_rfl oa57 : PRE_pl_r2.S57.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S57.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt57_58 : countersOkB PRE_pl_r2.s57 PRE_pl_r2.s58 = true
kernel_rfl oa58 : PRE_pl_r2.S58.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S58.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live61 : isHalt PRE_pl_r2.s61.ctl = false
kernel_rfl br58_62 : bridgeOf PRE_pl_r2.s62.ffi = bridgeOf PRE_pl_r2.s58.ffi
kernel_rfl cnt58_62 : countersOkB PRE_pl_r2.s58 PRE_pl_r2.s62 = true
kernel_rfl oa62 : PRE_pl_r2.S62.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S62.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt62_63 : countersOkB PRE_pl_r2.s62 PRE_pl_r2.s63 = true
kernel_rfl oa63 : PRE_pl_r2.S63.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S63.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live68 : isHalt PRE_pl_r2.s68.ctl = false
kernel_rfl br63_69 : bridgeOf PRE_pl_r2.s69.ffi = bridgeOf PRE_pl_r2.s63.ffi
kernel_rfl cnt63_69 : countersOkB PRE_pl_r2.s63 PRE_pl_r2.s69 = true
kernel_rfl oa69 : PRE_pl_r2.S69.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S69.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt69_70 : countersOkB PRE_pl_r2.s69 PRE_pl_r2.s70 = true
kernel_rfl oa70 : PRE_pl_r2.S70.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S70.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live73 : isHalt PRE_pl_r2.s73.ctl = false
kernel_rfl br70_74 : bridgeOf PRE_pl_r2.s74.ffi = bridgeOf PRE_pl_r2.s70.ffi
kernel_rfl cnt70_74 : countersOkB PRE_pl_r2.s70 PRE_pl_r2.s74 = true
kernel_rfl oa74 : PRE_pl_r2.S74.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S74.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt74_75 : countersOkB PRE_pl_r2.s74 PRE_pl_r2.s75 = true
kernel_rfl oa75 : PRE_pl_r2.S75.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S75.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live76 : isHalt PRE_pl_r2.s76.ctl = false
kernel_rfl br75_77 : bridgeOf PRE_pl_r2.s77.ffi = bridgeOf PRE_pl_r2.s75.ffi
kernel_rfl cnt75_77 : countersOkB PRE_pl_r2.s75 PRE_pl_r2.s77 = true
kernel_rfl oa77 : PRE_pl_r2.S77.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S77.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt77_78 : countersOkB PRE_pl_r2.s77 PRE_pl_r2.s78 = true
kernel_rfl oa78 : PRE_pl_r2.S78.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S78.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live82 : isHalt PRE_pl_r2.s82.ctl = false
kernel_rfl br78_83 : bridgeOf PRE_pl_r2.s83.ffi = bridgeOf PRE_pl_r2.s78.ffi
kernel_rfl cnt78_83 : countersOkB PRE_pl_r2.s78 PRE_pl_r2.s83 = true
kernel_rfl oa83 : PRE_pl_r2.S83.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S83.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt83_84 : countersOkB PRE_pl_r2.s83 PRE_pl_r2.s84 = true
kernel_rfl oa84 : PRE_pl_r2.S84.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S84.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live85 : isHalt PRE_pl_r2.s85.ctl = false
kernel_rfl br84_86 : bridgeOf PRE_pl_r2.s86.ffi = bridgeOf PRE_pl_r2.s84.ffi
kernel_rfl cnt84_86 : countersOkB PRE_pl_r2.s84 PRE_pl_r2.s86 = true
kernel_rfl oa86 : PRE_pl_r2.S86.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S86.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt86_87 : countersOkB PRE_pl_r2.s86 PRE_pl_r2.s87 = true

abbrev n0 : Nat := ((((((((((((((((((((((((((((((((((((((nth? PRE_pl_r2.ks 0).getD 0) + ((nth? PRE_pl_r2.ks 1).getD 0)) + ((nth? PRE_pl_r2.ks 2).getD 0)) + ((nth? PRE_pl_r2.ks 3).getD 0)) + ((nth? PRE_pl_r2.ks 4).getD 0)) + 1) + 3) + (((((nth? PRE_pl_r2.ks 7).getD 0) + ((nth? PRE_pl_r2.ks 8).getD 0)) + ((nth? PRE_pl_r2.ks 9).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 12).getD 0) + 1)) + 3) + (((((((nth? PRE_pl_r2.ks 15).getD 0) + ((nth? PRE_pl_r2.ks 16).getD 0)) + ((nth? PRE_pl_r2.ks 17).getD 0)) + ((nth? PRE_pl_r2.ks 18).getD 0)) + ((nth? PRE_pl_r2.ks 19).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 22).getD 0) + ((nth? PRE_pl_r2.ks 23).getD 0)) + ((nth? PRE_pl_r2.ks 24).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 27).getD 0) + 1)) + 3) + (((((((nth? PRE_pl_r2.ks 30).getD 0) + ((nth? PRE_pl_r2.ks 31).getD 0)) + ((nth? PRE_pl_r2.ks 32).getD 0)) + ((nth? PRE_pl_r2.ks 33).getD 0)) + ((nth? PRE_pl_r2.ks 34).getD 0)) + 1)) + 3) + (((((((((nth? PRE_pl_r2.ks 37).getD 0) + ((nth? PRE_pl_r2.ks 38).getD 0)) + ((nth? PRE_pl_r2.ks 39).getD 0)) + ((nth? PRE_pl_r2.ks 40).getD 0)) + ((nth? PRE_pl_r2.ks 41).getD 0)) + ((nth? PRE_pl_r2.ks 42).getD 0)) + ((nth? PRE_pl_r2.ks 43).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 46).getD 0) + ((nth? PRE_pl_r2.ks 47).getD 0)) + ((nth? PRE_pl_r2.ks 48).getD 0)) + 1)) + 3) + (((((((nth? PRE_pl_r2.ks 51).getD 0) + ((nth? PRE_pl_r2.ks 52).getD 0)) + ((nth? PRE_pl_r2.ks 53).getD 0)) + ((nth? PRE_pl_r2.ks 54).getD 0)) + ((nth? PRE_pl_r2.ks 55).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 58).getD 0) + ((nth? PRE_pl_r2.ks 59).getD 0)) + ((nth? PRE_pl_r2.ks 60).getD 0)) + 1)) + 3) + (((((((nth? PRE_pl_r2.ks 63).getD 0) + ((nth? PRE_pl_r2.ks 64).getD 0)) + ((nth? PRE_pl_r2.ks 65).getD 0)) + ((nth? PRE_pl_r2.ks 66).getD 0)) + ((nth? PRE_pl_r2.ks 67).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 70).getD 0) + ((nth? PRE_pl_r2.ks 71).getD 0)) + ((nth? PRE_pl_r2.ks 72).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 75).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r2.ks 78).getD 0) + ((nth? PRE_pl_r2.ks 79).getD 0)) + ((nth? PRE_pl_r2.ks 80).getD 0)) + ((nth? PRE_pl_r2.ks 81).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 84).getD 0) + 1)) + 3)

theorem c0 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_r2.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r2.s0 PRE_pl_r2.S0)) (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r2.s87 PRE_pl_r2.S87)) n0 :=
  ((((((((((((((((((((((((((((((((callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted0 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run0 PRE_pl_r2.run1) PRE_pl_r2.run2) PRE_pl_r2.run3) PRE_pl_r2.run4) PRE_pl_r2.accepted5 live5 PRE_pl_r2.b0.step PRE_pl_r2.b0.top hg (Host.Load.Boot.replay_active _) br0_6 cnt0_6 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b0.parts PRE_pl_r2.b0.args_ok PRE_pl_r2.b0.sym PRE_pl_r2.b0.mlx PRE_pl_r2.b0.pay (by decide) PRE_pl_r2.b0.decode PRE_pl_r2.b0.pre PRE_pl_r2.b0.runS (fun ν h => by rw [oa6]; exact good_drop _ (hg ν h)) PRE_pl_r2.b0.inactive PRE_pl_r2.b0.bridge cnt6_7 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted7 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run7 PRE_pl_r2.run8) PRE_pl_r2.run9) PRE_pl_r2.accepted10 live10 PRE_pl_r2.b1.step PRE_pl_r2.b1.top (fun ν h => by rw [oa7]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br7_11 cnt7_11 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b1.parts PRE_pl_r2.b1.args_ok PRE_pl_r2.b1.sym PRE_pl_r2.b1.mlx PRE_pl_r2.b1.pay (by decide) PRE_pl_r2.b1.decode PRE_pl_r2.b1.pre PRE_pl_r2.b1.runS (fun ν h => by rw [oa11]; exact good_drop _ (hg ν h)) PRE_pl_r2.b1.inactive PRE_pl_r2.b1.bridge cnt11_12 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted12 PRE_pl_r2.run12 PRE_pl_r2.accepted13 live13 PRE_pl_r2.b2.step PRE_pl_r2.b2.top (fun ν h => by rw [oa12]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br12_14 cnt12_14 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b2.parts PRE_pl_r2.b2.args_ok PRE_pl_r2.b2.sym PRE_pl_r2.b2.mlx PRE_pl_r2.b2.pay (by decide) PRE_pl_r2.b2.decode PRE_pl_r2.b2.pre PRE_pl_r2.b2.runS (fun ν h => by rw [oa14]; exact good_drop _ (hg ν h)) PRE_pl_r2.b2.inactive PRE_pl_r2.b2.bridge cnt14_15 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted15 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run15 PRE_pl_r2.run16) PRE_pl_r2.run17) PRE_pl_r2.run18) PRE_pl_r2.run19) PRE_pl_r2.accepted20 live20 PRE_pl_r2.b3.step PRE_pl_r2.b3.top (fun ν h => by rw [oa15]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br15_21 cnt15_21 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b3.parts PRE_pl_r2.b3.args_ok PRE_pl_r2.b3.sym PRE_pl_r2.b3.mlx PRE_pl_r2.b3.pay (by decide) PRE_pl_r2.b3.decode PRE_pl_r2.b3.pre PRE_pl_r2.b3.runS (fun ν h => by rw [oa21]; exact good_drop _ (hg ν h)) PRE_pl_r2.b3.inactive PRE_pl_r2.b3.bridge cnt21_22 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted22 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run22 PRE_pl_r2.run23) PRE_pl_r2.run24) PRE_pl_r2.accepted25 live25 PRE_pl_r2.b4.step PRE_pl_r2.b4.top (fun ν h => by rw [oa22]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br22_26 cnt22_26 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b4.parts PRE_pl_r2.b4.args_ok PRE_pl_r2.b4.sym PRE_pl_r2.b4.mlx PRE_pl_r2.b4.pay (by decide) PRE_pl_r2.b4.decode PRE_pl_r2.b4.pre PRE_pl_r2.b4.runS (fun ν h => by rw [oa26]; exact good_drop _ (hg ν h)) PRE_pl_r2.b4.inactive PRE_pl_r2.b4.bridge cnt26_27 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted27 PRE_pl_r2.run27 PRE_pl_r2.accepted28 live28 PRE_pl_r2.b5.step PRE_pl_r2.b5.top (fun ν h => by rw [oa27]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br27_29 cnt27_29 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b5.parts PRE_pl_r2.b5.args_ok PRE_pl_r2.b5.sym PRE_pl_r2.b5.mlx PRE_pl_r2.b5.pay (by decide) PRE_pl_r2.b5.decode PRE_pl_r2.b5.pre PRE_pl_r2.b5.runS (fun ν h => by rw [oa29]; exact good_drop _ (hg ν h)) PRE_pl_r2.b5.inactive PRE_pl_r2.b5.bridge cnt29_30 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted30 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run30 PRE_pl_r2.run31) PRE_pl_r2.run32) PRE_pl_r2.run33) PRE_pl_r2.run34) PRE_pl_r2.accepted35 live35 PRE_pl_r2.b6.step PRE_pl_r2.b6.top (fun ν h => by rw [oa30]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br30_36 cnt30_36 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b6.parts PRE_pl_r2.b6.args_ok PRE_pl_r2.b6.sym PRE_pl_r2.b6.mlx PRE_pl_r2.b6.pay (by decide) PRE_pl_r2.b6.decode PRE_pl_r2.b6.pre PRE_pl_r2.b6.runS (fun ν h => by rw [oa36]; exact good_drop _ (hg ν h)) PRE_pl_r2.b6.inactive PRE_pl_r2.b6.bridge cnt36_37 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted37 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run37 PRE_pl_r2.run38) PRE_pl_r2.run39) PRE_pl_r2.run40) PRE_pl_r2.run41) PRE_pl_r2.run42) PRE_pl_r2.run43) PRE_pl_r2.accepted44 live44 PRE_pl_r2.b7.step PRE_pl_r2.b7.top (fun ν h => by rw [oa37]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br37_45 cnt37_45 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b7.parts PRE_pl_r2.b7.args_ok PRE_pl_r2.b7.sym PRE_pl_r2.b7.mlx PRE_pl_r2.b7.pay (by decide) PRE_pl_r2.b7.decode PRE_pl_r2.b7.pre PRE_pl_r2.b7.runS (fun ν h => by rw [oa45]; exact good_drop _ (hg ν h)) PRE_pl_r2.b7.inactive PRE_pl_r2.b7.bridge cnt45_46 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted46 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run46 PRE_pl_r2.run47) PRE_pl_r2.run48) PRE_pl_r2.accepted49 live49 PRE_pl_r2.b8.step PRE_pl_r2.b8.top (fun ν h => by rw [oa46]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br46_50 cnt46_50 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b8.parts PRE_pl_r2.b8.args_ok PRE_pl_r2.b8.sym PRE_pl_r2.b8.mlx PRE_pl_r2.b8.pay (by decide) PRE_pl_r2.b8.decode PRE_pl_r2.b8.pre PRE_pl_r2.b8.runS (fun ν h => by rw [oa50]; exact good_drop _ (hg ν h)) PRE_pl_r2.b8.inactive PRE_pl_r2.b8.bridge cnt50_51 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted51 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run51 PRE_pl_r2.run52) PRE_pl_r2.run53) PRE_pl_r2.run54) PRE_pl_r2.run55) PRE_pl_r2.accepted56 live56 PRE_pl_r2.b9.step PRE_pl_r2.b9.top (fun ν h => by rw [oa51]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br51_57 cnt51_57 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b9.parts PRE_pl_r2.b9.args_ok PRE_pl_r2.b9.sym PRE_pl_r2.b9.mlx PRE_pl_r2.b9.pay (by decide) PRE_pl_r2.b9.decode PRE_pl_r2.b9.pre PRE_pl_r2.b9.runS (fun ν h => by rw [oa57]; exact good_drop _ (hg ν h)) PRE_pl_r2.b9.inactive PRE_pl_r2.b9.bridge cnt57_58 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted58 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run58 PRE_pl_r2.run59) PRE_pl_r2.run60) PRE_pl_r2.accepted61 live61 PRE_pl_r2.b10.step PRE_pl_r2.b10.top (fun ν h => by rw [oa58]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br58_62 cnt58_62 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b10.parts PRE_pl_r2.b10.args_ok PRE_pl_r2.b10.sym PRE_pl_r2.b10.mlx PRE_pl_r2.b10.pay (by decide) PRE_pl_r2.b10.decode PRE_pl_r2.b10.pre PRE_pl_r2.b10.runS (fun ν h => by rw [oa62]; exact good_drop _ (hg ν h)) PRE_pl_r2.b10.inactive PRE_pl_r2.b10.bridge cnt62_63 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted63 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run63 PRE_pl_r2.run64) PRE_pl_r2.run65) PRE_pl_r2.run66) PRE_pl_r2.run67) PRE_pl_r2.accepted68 live68 PRE_pl_r2.b11.step PRE_pl_r2.b11.top (fun ν h => by rw [oa63]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br63_69 cnt63_69 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b11.parts PRE_pl_r2.b11.args_ok PRE_pl_r2.b11.sym PRE_pl_r2.b11.mlx PRE_pl_r2.b11.pay (by decide) PRE_pl_r2.b11.decode PRE_pl_r2.b11.pre PRE_pl_r2.b11.runS (fun ν h => by rw [oa69]; exact good_drop _ (hg ν h)) PRE_pl_r2.b11.inactive PRE_pl_r2.b11.bridge cnt69_70 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted70 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run70 PRE_pl_r2.run71) PRE_pl_r2.run72) PRE_pl_r2.accepted73 live73 PRE_pl_r2.b12.step PRE_pl_r2.b12.top (fun ν h => by rw [oa70]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br70_74 cnt70_74 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b12.parts PRE_pl_r2.b12.args_ok PRE_pl_r2.b12.sym PRE_pl_r2.b12.mlx PRE_pl_r2.b12.pay (by decide) PRE_pl_r2.b12.decode PRE_pl_r2.b12.pre PRE_pl_r2.b12.runS (fun ν h => by rw [oa74]; exact good_drop _ (hg ν h)) PRE_pl_r2.b12.inactive PRE_pl_r2.b12.bridge cnt74_75 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted75 PRE_pl_r2.run75 PRE_pl_r2.accepted76 live76 PRE_pl_r2.b13.step PRE_pl_r2.b13.top (fun ν h => by rw [oa75]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br75_77 cnt75_77 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b13.parts PRE_pl_r2.b13.args_ok PRE_pl_r2.b13.sym PRE_pl_r2.b13.mlx PRE_pl_r2.b13.pay (by decide) PRE_pl_r2.b13.decode PRE_pl_r2.b13.pre PRE_pl_r2.b13.runS (fun ν h => by rw [oa77]; exact good_drop _ (hg ν h)) PRE_pl_r2.b13.inactive PRE_pl_r2.b13.bridge cnt77_78 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted78 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run78 PRE_pl_r2.run79) PRE_pl_r2.run80) PRE_pl_r2.run81) PRE_pl_r2.accepted82 live82 PRE_pl_r2.b14.step PRE_pl_r2.b14.top (fun ν h => by rw [oa78]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br78_83 cnt78_83 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b14.parts PRE_pl_r2.b14.args_ok PRE_pl_r2.b14.sym PRE_pl_r2.b14.mlx PRE_pl_r2.b14.pay (by decide) PRE_pl_r2.b14.decode PRE_pl_r2.b14.pre PRE_pl_r2.b14.runS (fun ν h => by rw [oa83]; exact good_drop _ (hg ν h)) PRE_pl_r2.b14.inactive PRE_pl_r2.b14.bridge cnt83_84 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted84 PRE_pl_r2.run84 PRE_pl_r2.accepted85 live85 PRE_pl_r2.b15.step PRE_pl_r2.b15.top (fun ν h => by rw [oa84]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br84_86 cnt84_86 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b15.parts PRE_pl_r2.b15.args_ok PRE_pl_r2.b15.sym PRE_pl_r2.b15.mlx PRE_pl_r2.b15.pay (by decide) PRE_pl_r2.b15.decode PRE_pl_r2.b15.pre PRE_pl_r2.b15.runS (fun ν h => by rw [oa86]; exact good_drop _ (hg ν h)) PRE_pl_r2.b15.inactive PRE_pl_r2.b15.bridge cnt86_87 hT)

end Host.Ts.Sim.Compose.Post.PL.R2
