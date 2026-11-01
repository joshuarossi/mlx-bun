import host.sim.compose.PostChain
import host.sim.template.a4pre_pl_r2.Good
import host.sim.template.a4pre_pl_r2.K681
import host.sim.template.a4pre_pl_r2.Accept10
import host.sim.template.a4pre_pl_r2.Size144
import host.sim.template.a4pre_pl_r2.H21
import host.sim.template.a4pre_pl_r2.K684
import host.sim.template.a4pre_pl_r2.K685
import host.sim.template.a4pre_pl_r2.K686
import host.sim.template.a4pre_pl_r2.K687
import host.sim.template.a4pre_pl_r2.K688
import host.sim.template.a4pre_pl_r2.K689
import host.sim.template.a4pre_pl_r2.K690
import host.sim.template.a4pre_pl_r2.Size145
import host.sim.template.a4pre_pl_r2.K693
import host.sim.template.a4pre_pl_r2.K694
import host.sim.template.a4pre_pl_r2.K695
import host.sim.template.a4pre_pl_r2.Accept11
import host.sim.template.a4pre_pl_r2.Size146
import host.sim.template.a4pre_pl_r2.K698
import host.sim.template.a4pre_pl_r2.Size147
import host.sim.template.a4pre_pl_r2.K701
import host.sim.template.a4pre_pl_r2.K702
import host.sim.template.a4pre_pl_r2.K703
import host.sim.template.a4pre_pl_r2.K704
import host.sim.template.a4pre_pl_r2.Size148
import host.sim.template.a4pre_pl_r2.H22
import host.sim.template.a4pre_pl_r2.K707
import host.sim.template.a4pre_pl_r2.Size149
import host.sim.template.a4pre_pl_r2.K710
import host.sim.template.a4pre_pl_r2.K711
import host.sim.template.a4pre_pl_r2.K712
import host.sim.template.a4pre_pl_r2.Size150
import host.sim.template.a4pre_pl_r2.K715
import host.sim.template.a4pre_pl_r2.Size151
import host.sim.template.a4pre_pl_r2.K718
import host.sim.template.a4pre_pl_r2.K719
import host.sim.template.a4pre_pl_r2.K720
import host.sim.template.a4pre_pl_r2.K721
import host.sim.template.a4pre_pl_r2.Size152
import host.sim.template.a4pre_pl_r2.K724
import host.sim.template.a4pre_pl_r2.Size153
import host.sim.template.a4pre_pl_r2.K727
import host.sim.template.a4pre_pl_r2.K728
import host.sim.template.a4pre_pl_r2.K729
import host.sim.template.a4pre_pl_r2.Size154
import host.sim.template.a4pre_pl_r2.K732
import host.sim.template.a4pre_pl_r2.Size155
import host.sim.template.a4pre_pl_r2.K735
import host.sim.template.a4pre_pl_r2.K736
import host.sim.template.a4pre_pl_r2.K737
import host.sim.template.a4pre_pl_r2.K738
import host.sim.template.a4pre_pl_r2.Size156
import host.sim.template.a4pre_pl_r2.H23
import host.sim.template.a4pre_pl_r2.K741
import host.sim.template.a4pre_pl_r2.Size157
import host.sim.template.a4pre_pl_r2.K744
import host.sim.template.a4pre_pl_r2.K745
import host.sim.template.a4pre_pl_r2.K746
import host.sim.template.a4pre_pl_r2.K747
import host.sim.template.a4pre_pl_r2.K748
import host.sim.template.a4pre_pl_r2.K749
import host.sim.template.a4pre_pl_r2.K750
import host.sim.template.a4pre_pl_r2.Size158
import host.sim.template.a4pre_pl_r2.K753
import host.sim.template.a4pre_pl_r2.K754
import host.sim.template.a4pre_pl_r2.K755
import host.sim.template.a4pre_pl_r2.Size159
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.R2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl oa681 : PRE_pl_r2.S681.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S681.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live682 : isHalt PRE_pl_r2.s682.ctl = false
kernel_rfl br681_683 : bridgeOf PRE_pl_r2.s683.ffi = bridgeOf PRE_pl_r2.s681.ffi
kernel_rfl cnt681_683 : countersOkB PRE_pl_r2.s681 PRE_pl_r2.s683 = true
kernel_rfl oa683 : PRE_pl_r2.S683.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S683.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt683_684 : countersOkB PRE_pl_r2.s683 PRE_pl_r2.s684 = true
kernel_rfl oa684 : PRE_pl_r2.S684.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S684.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live691 : isHalt PRE_pl_r2.s691.ctl = false
kernel_rfl br684_692 : bridgeOf PRE_pl_r2.s692.ffi = bridgeOf PRE_pl_r2.s684.ffi
kernel_rfl cnt684_692 : countersOkB PRE_pl_r2.s684 PRE_pl_r2.s692 = true
kernel_rfl oa692 : PRE_pl_r2.S692.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S692.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt692_693 : countersOkB PRE_pl_r2.s692 PRE_pl_r2.s693 = true
kernel_rfl oa693 : PRE_pl_r2.S693.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S693.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live696 : isHalt PRE_pl_r2.s696.ctl = false
kernel_rfl br693_697 : bridgeOf PRE_pl_r2.s697.ffi = bridgeOf PRE_pl_r2.s693.ffi
kernel_rfl cnt693_697 : countersOkB PRE_pl_r2.s693 PRE_pl_r2.s697 = true
kernel_rfl oa697 : PRE_pl_r2.S697.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S697.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt697_698 : countersOkB PRE_pl_r2.s697 PRE_pl_r2.s698 = true
kernel_rfl oa698 : PRE_pl_r2.S698.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S698.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live699 : isHalt PRE_pl_r2.s699.ctl = false
kernel_rfl br698_700 : bridgeOf PRE_pl_r2.s700.ffi = bridgeOf PRE_pl_r2.s698.ffi
kernel_rfl cnt698_700 : countersOkB PRE_pl_r2.s698 PRE_pl_r2.s700 = true
kernel_rfl oa700 : PRE_pl_r2.S700.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S700.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt700_701 : countersOkB PRE_pl_r2.s700 PRE_pl_r2.s701 = true
kernel_rfl oa701 : PRE_pl_r2.S701.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S701.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live705 : isHalt PRE_pl_r2.s705.ctl = false
kernel_rfl br701_706 : bridgeOf PRE_pl_r2.s706.ffi = bridgeOf PRE_pl_r2.s701.ffi
kernel_rfl cnt701_706 : countersOkB PRE_pl_r2.s701 PRE_pl_r2.s706 = true
kernel_rfl oa706 : PRE_pl_r2.S706.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S706.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt706_707 : countersOkB PRE_pl_r2.s706 PRE_pl_r2.s707 = true
kernel_rfl oa707 : PRE_pl_r2.S707.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S707.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live708 : isHalt PRE_pl_r2.s708.ctl = false
kernel_rfl br707_709 : bridgeOf PRE_pl_r2.s709.ffi = bridgeOf PRE_pl_r2.s707.ffi
kernel_rfl cnt707_709 : countersOkB PRE_pl_r2.s707 PRE_pl_r2.s709 = true
kernel_rfl oa709 : PRE_pl_r2.S709.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S709.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt709_710 : countersOkB PRE_pl_r2.s709 PRE_pl_r2.s710 = true
kernel_rfl oa710 : PRE_pl_r2.S710.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S710.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live713 : isHalt PRE_pl_r2.s713.ctl = false
kernel_rfl br710_714 : bridgeOf PRE_pl_r2.s714.ffi = bridgeOf PRE_pl_r2.s710.ffi
kernel_rfl cnt710_714 : countersOkB PRE_pl_r2.s710 PRE_pl_r2.s714 = true
kernel_rfl oa714 : PRE_pl_r2.S714.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S714.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt714_715 : countersOkB PRE_pl_r2.s714 PRE_pl_r2.s715 = true
kernel_rfl oa715 : PRE_pl_r2.S715.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S715.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live716 : isHalt PRE_pl_r2.s716.ctl = false
kernel_rfl br715_717 : bridgeOf PRE_pl_r2.s717.ffi = bridgeOf PRE_pl_r2.s715.ffi
kernel_rfl cnt715_717 : countersOkB PRE_pl_r2.s715 PRE_pl_r2.s717 = true
kernel_rfl oa717 : PRE_pl_r2.S717.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S717.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt717_718 : countersOkB PRE_pl_r2.s717 PRE_pl_r2.s718 = true
kernel_rfl oa718 : PRE_pl_r2.S718.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S718.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live722 : isHalt PRE_pl_r2.s722.ctl = false
kernel_rfl br718_723 : bridgeOf PRE_pl_r2.s723.ffi = bridgeOf PRE_pl_r2.s718.ffi
kernel_rfl cnt718_723 : countersOkB PRE_pl_r2.s718 PRE_pl_r2.s723 = true
kernel_rfl oa723 : PRE_pl_r2.S723.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S723.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt723_724 : countersOkB PRE_pl_r2.s723 PRE_pl_r2.s724 = true
kernel_rfl oa724 : PRE_pl_r2.S724.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S724.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live725 : isHalt PRE_pl_r2.s725.ctl = false
kernel_rfl br724_726 : bridgeOf PRE_pl_r2.s726.ffi = bridgeOf PRE_pl_r2.s724.ffi
kernel_rfl cnt724_726 : countersOkB PRE_pl_r2.s724 PRE_pl_r2.s726 = true
kernel_rfl oa726 : PRE_pl_r2.S726.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S726.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt726_727 : countersOkB PRE_pl_r2.s726 PRE_pl_r2.s727 = true
kernel_rfl oa727 : PRE_pl_r2.S727.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S727.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live730 : isHalt PRE_pl_r2.s730.ctl = false
kernel_rfl br727_731 : bridgeOf PRE_pl_r2.s731.ffi = bridgeOf PRE_pl_r2.s727.ffi
kernel_rfl cnt727_731 : countersOkB PRE_pl_r2.s727 PRE_pl_r2.s731 = true
kernel_rfl oa731 : PRE_pl_r2.S731.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S731.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt731_732 : countersOkB PRE_pl_r2.s731 PRE_pl_r2.s732 = true
kernel_rfl oa732 : PRE_pl_r2.S732.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S732.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live733 : isHalt PRE_pl_r2.s733.ctl = false
kernel_rfl br732_734 : bridgeOf PRE_pl_r2.s734.ffi = bridgeOf PRE_pl_r2.s732.ffi
kernel_rfl cnt732_734 : countersOkB PRE_pl_r2.s732 PRE_pl_r2.s734 = true
kernel_rfl oa734 : PRE_pl_r2.S734.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S734.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt734_735 : countersOkB PRE_pl_r2.s734 PRE_pl_r2.s735 = true
kernel_rfl oa735 : PRE_pl_r2.S735.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S735.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live739 : isHalt PRE_pl_r2.s739.ctl = false
kernel_rfl br735_740 : bridgeOf PRE_pl_r2.s740.ffi = bridgeOf PRE_pl_r2.s735.ffi
kernel_rfl cnt735_740 : countersOkB PRE_pl_r2.s735 PRE_pl_r2.s740 = true
kernel_rfl oa740 : PRE_pl_r2.S740.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S740.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt740_741 : countersOkB PRE_pl_r2.s740 PRE_pl_r2.s741 = true
kernel_rfl oa741 : PRE_pl_r2.S741.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S741.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live742 : isHalt PRE_pl_r2.s742.ctl = false
kernel_rfl br741_743 : bridgeOf PRE_pl_r2.s743.ffi = bridgeOf PRE_pl_r2.s741.ffi
kernel_rfl cnt741_743 : countersOkB PRE_pl_r2.s741 PRE_pl_r2.s743 = true
kernel_rfl oa743 : PRE_pl_r2.S743.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S743.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt743_744 : countersOkB PRE_pl_r2.s743 PRE_pl_r2.s744 = true
kernel_rfl oa744 : PRE_pl_r2.S744.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S744.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live751 : isHalt PRE_pl_r2.s751.ctl = false
kernel_rfl br744_752 : bridgeOf PRE_pl_r2.s752.ffi = bridgeOf PRE_pl_r2.s744.ffi
kernel_rfl cnt744_752 : countersOkB PRE_pl_r2.s744 PRE_pl_r2.s752 = true
kernel_rfl oa752 : PRE_pl_r2.S752.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S752.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt752_753 : countersOkB PRE_pl_r2.s752 PRE_pl_r2.s753 = true
kernel_rfl oa753 : PRE_pl_r2.S753.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S753.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live756 : isHalt PRE_pl_r2.s756.ctl = false
kernel_rfl br753_757 : bridgeOf PRE_pl_r2.s757.ffi = bridgeOf PRE_pl_r2.s753.ffi
kernel_rfl cnt753_757 : countersOkB PRE_pl_r2.s753 PRE_pl_r2.s757 = true
kernel_rfl oa757 : PRE_pl_r2.S757.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S757.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt757_758 : countersOkB PRE_pl_r2.s757 PRE_pl_r2.s758 = true

abbrev n9 : Nat := ((((((((((((((((((((((((((((((((((nth? PRE_pl_r2.ks 681).getD 0) + 1) + 3) + (((((((((nth? PRE_pl_r2.ks 684).getD 0) + ((nth? PRE_pl_r2.ks 685).getD 0)) + ((nth? PRE_pl_r2.ks 686).getD 0)) + ((nth? PRE_pl_r2.ks 687).getD 0)) + ((nth? PRE_pl_r2.ks 688).getD 0)) + ((nth? PRE_pl_r2.ks 689).getD 0)) + ((nth? PRE_pl_r2.ks 690).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 693).getD 0) + ((nth? PRE_pl_r2.ks 694).getD 0)) + ((nth? PRE_pl_r2.ks 695).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 698).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r2.ks 701).getD 0) + ((nth? PRE_pl_r2.ks 702).getD 0)) + ((nth? PRE_pl_r2.ks 703).getD 0)) + ((nth? PRE_pl_r2.ks 704).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 707).getD 0) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 710).getD 0) + ((nth? PRE_pl_r2.ks 711).getD 0)) + ((nth? PRE_pl_r2.ks 712).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 715).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r2.ks 718).getD 0) + ((nth? PRE_pl_r2.ks 719).getD 0)) + ((nth? PRE_pl_r2.ks 720).getD 0)) + ((nth? PRE_pl_r2.ks 721).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 724).getD 0) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 727).getD 0) + ((nth? PRE_pl_r2.ks 728).getD 0)) + ((nth? PRE_pl_r2.ks 729).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 732).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r2.ks 735).getD 0) + ((nth? PRE_pl_r2.ks 736).getD 0)) + ((nth? PRE_pl_r2.ks 737).getD 0)) + ((nth? PRE_pl_r2.ks 738).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 741).getD 0) + 1)) + 3) + (((((((((nth? PRE_pl_r2.ks 744).getD 0) + ((nth? PRE_pl_r2.ks 745).getD 0)) + ((nth? PRE_pl_r2.ks 746).getD 0)) + ((nth? PRE_pl_r2.ks 747).getD 0)) + ((nth? PRE_pl_r2.ks 748).getD 0)) + ((nth? PRE_pl_r2.ks 749).getD 0)) + ((nth? PRE_pl_r2.ks 750).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 753).getD 0) + ((nth? PRE_pl_r2.ks 754).getD 0)) + ((nth? PRE_pl_r2.ks 755).getD 0)) + 1)) + 3)

theorem c9 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_r2.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r2.s681 PRE_pl_r2.S681)) (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r2.s758 PRE_pl_r2.S758)) n9 :=
  ((((((((((((((((((((((((((((((((callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted681 PRE_pl_r2.run681 PRE_pl_r2.accepted682 live682 PRE_pl_r2.b144.step PRE_pl_r2.b144.top (fun ν h => by rw [oa681]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br681_683 cnt681_683 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b144.parts PRE_pl_r2.b144.args_ok PRE_pl_r2.b144.sym PRE_pl_r2.b144.mlx PRE_pl_r2.b144.pay (by decide) PRE_pl_r2.b144.decode PRE_pl_r2.b144.pre PRE_pl_r2.b144.runS (fun ν h => by rw [oa683]; exact good_drop _ (hg ν h)) PRE_pl_r2.b144.inactive PRE_pl_r2.b144.bridge cnt683_684 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted684 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run684 PRE_pl_r2.run685) PRE_pl_r2.run686) PRE_pl_r2.run687) PRE_pl_r2.run688) PRE_pl_r2.run689) PRE_pl_r2.run690) PRE_pl_r2.accepted691 live691 PRE_pl_r2.b145.step PRE_pl_r2.b145.top (fun ν h => by rw [oa684]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br684_692 cnt684_692 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b145.parts PRE_pl_r2.b145.args_ok PRE_pl_r2.b145.sym PRE_pl_r2.b145.mlx PRE_pl_r2.b145.pay (by decide) PRE_pl_r2.b145.decode PRE_pl_r2.b145.pre PRE_pl_r2.b145.runS (fun ν h => by rw [oa692]; exact good_drop _ (hg ν h)) PRE_pl_r2.b145.inactive PRE_pl_r2.b145.bridge cnt692_693 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted693 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run693 PRE_pl_r2.run694) PRE_pl_r2.run695) PRE_pl_r2.accepted696 live696 PRE_pl_r2.b146.step PRE_pl_r2.b146.top (fun ν h => by rw [oa693]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br693_697 cnt693_697 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b146.parts PRE_pl_r2.b146.args_ok PRE_pl_r2.b146.sym PRE_pl_r2.b146.mlx PRE_pl_r2.b146.pay (by decide) PRE_pl_r2.b146.decode PRE_pl_r2.b146.pre PRE_pl_r2.b146.runS (fun ν h => by rw [oa697]; exact good_drop _ (hg ν h)) PRE_pl_r2.b146.inactive PRE_pl_r2.b146.bridge cnt697_698 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted698 PRE_pl_r2.run698 PRE_pl_r2.accepted699 live699 PRE_pl_r2.b147.step PRE_pl_r2.b147.top (fun ν h => by rw [oa698]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br698_700 cnt698_700 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b147.parts PRE_pl_r2.b147.args_ok PRE_pl_r2.b147.sym PRE_pl_r2.b147.mlx PRE_pl_r2.b147.pay (by decide) PRE_pl_r2.b147.decode PRE_pl_r2.b147.pre PRE_pl_r2.b147.runS (fun ν h => by rw [oa700]; exact good_drop _ (hg ν h)) PRE_pl_r2.b147.inactive PRE_pl_r2.b147.bridge cnt700_701 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted701 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run701 PRE_pl_r2.run702) PRE_pl_r2.run703) PRE_pl_r2.run704) PRE_pl_r2.accepted705 live705 PRE_pl_r2.b148.step PRE_pl_r2.b148.top (fun ν h => by rw [oa701]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br701_706 cnt701_706 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b148.parts PRE_pl_r2.b148.args_ok PRE_pl_r2.b148.sym PRE_pl_r2.b148.mlx PRE_pl_r2.b148.pay (by decide) PRE_pl_r2.b148.decode PRE_pl_r2.b148.pre PRE_pl_r2.b148.runS (fun ν h => by rw [oa706]; exact good_drop _ (hg ν h)) PRE_pl_r2.b148.inactive PRE_pl_r2.b148.bridge cnt706_707 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted707 PRE_pl_r2.run707 PRE_pl_r2.accepted708 live708 PRE_pl_r2.b149.step PRE_pl_r2.b149.top (fun ν h => by rw [oa707]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br707_709 cnt707_709 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b149.parts PRE_pl_r2.b149.args_ok PRE_pl_r2.b149.sym PRE_pl_r2.b149.mlx PRE_pl_r2.b149.pay (by decide) PRE_pl_r2.b149.decode PRE_pl_r2.b149.pre PRE_pl_r2.b149.runS (fun ν h => by rw [oa709]; exact good_drop _ (hg ν h)) PRE_pl_r2.b149.inactive PRE_pl_r2.b149.bridge cnt709_710 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted710 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run710 PRE_pl_r2.run711) PRE_pl_r2.run712) PRE_pl_r2.accepted713 live713 PRE_pl_r2.b150.step PRE_pl_r2.b150.top (fun ν h => by rw [oa710]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br710_714 cnt710_714 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b150.parts PRE_pl_r2.b150.args_ok PRE_pl_r2.b150.sym PRE_pl_r2.b150.mlx PRE_pl_r2.b150.pay (by decide) PRE_pl_r2.b150.decode PRE_pl_r2.b150.pre PRE_pl_r2.b150.runS (fun ν h => by rw [oa714]; exact good_drop _ (hg ν h)) PRE_pl_r2.b150.inactive PRE_pl_r2.b150.bridge cnt714_715 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted715 PRE_pl_r2.run715 PRE_pl_r2.accepted716 live716 PRE_pl_r2.b151.step PRE_pl_r2.b151.top (fun ν h => by rw [oa715]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br715_717 cnt715_717 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b151.parts PRE_pl_r2.b151.args_ok PRE_pl_r2.b151.sym PRE_pl_r2.b151.mlx PRE_pl_r2.b151.pay (by decide) PRE_pl_r2.b151.decode PRE_pl_r2.b151.pre PRE_pl_r2.b151.runS (fun ν h => by rw [oa717]; exact good_drop _ (hg ν h)) PRE_pl_r2.b151.inactive PRE_pl_r2.b151.bridge cnt717_718 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted718 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run718 PRE_pl_r2.run719) PRE_pl_r2.run720) PRE_pl_r2.run721) PRE_pl_r2.accepted722 live722 PRE_pl_r2.b152.step PRE_pl_r2.b152.top (fun ν h => by rw [oa718]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br718_723 cnt718_723 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b152.parts PRE_pl_r2.b152.args_ok PRE_pl_r2.b152.sym PRE_pl_r2.b152.mlx PRE_pl_r2.b152.pay (by decide) PRE_pl_r2.b152.decode PRE_pl_r2.b152.pre PRE_pl_r2.b152.runS (fun ν h => by rw [oa723]; exact good_drop _ (hg ν h)) PRE_pl_r2.b152.inactive PRE_pl_r2.b152.bridge cnt723_724 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted724 PRE_pl_r2.run724 PRE_pl_r2.accepted725 live725 PRE_pl_r2.b153.step PRE_pl_r2.b153.top (fun ν h => by rw [oa724]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br724_726 cnt724_726 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b153.parts PRE_pl_r2.b153.args_ok PRE_pl_r2.b153.sym PRE_pl_r2.b153.mlx PRE_pl_r2.b153.pay (by decide) PRE_pl_r2.b153.decode PRE_pl_r2.b153.pre PRE_pl_r2.b153.runS (fun ν h => by rw [oa726]; exact good_drop _ (hg ν h)) PRE_pl_r2.b153.inactive PRE_pl_r2.b153.bridge cnt726_727 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted727 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run727 PRE_pl_r2.run728) PRE_pl_r2.run729) PRE_pl_r2.accepted730 live730 PRE_pl_r2.b154.step PRE_pl_r2.b154.top (fun ν h => by rw [oa727]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br727_731 cnt727_731 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b154.parts PRE_pl_r2.b154.args_ok PRE_pl_r2.b154.sym PRE_pl_r2.b154.mlx PRE_pl_r2.b154.pay (by decide) PRE_pl_r2.b154.decode PRE_pl_r2.b154.pre PRE_pl_r2.b154.runS (fun ν h => by rw [oa731]; exact good_drop _ (hg ν h)) PRE_pl_r2.b154.inactive PRE_pl_r2.b154.bridge cnt731_732 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted732 PRE_pl_r2.run732 PRE_pl_r2.accepted733 live733 PRE_pl_r2.b155.step PRE_pl_r2.b155.top (fun ν h => by rw [oa732]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br732_734 cnt732_734 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b155.parts PRE_pl_r2.b155.args_ok PRE_pl_r2.b155.sym PRE_pl_r2.b155.mlx PRE_pl_r2.b155.pay (by decide) PRE_pl_r2.b155.decode PRE_pl_r2.b155.pre PRE_pl_r2.b155.runS (fun ν h => by rw [oa734]; exact good_drop _ (hg ν h)) PRE_pl_r2.b155.inactive PRE_pl_r2.b155.bridge cnt734_735 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted735 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run735 PRE_pl_r2.run736) PRE_pl_r2.run737) PRE_pl_r2.run738) PRE_pl_r2.accepted739 live739 PRE_pl_r2.b156.step PRE_pl_r2.b156.top (fun ν h => by rw [oa735]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br735_740 cnt735_740 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b156.parts PRE_pl_r2.b156.args_ok PRE_pl_r2.b156.sym PRE_pl_r2.b156.mlx PRE_pl_r2.b156.pay (by decide) PRE_pl_r2.b156.decode PRE_pl_r2.b156.pre PRE_pl_r2.b156.runS (fun ν h => by rw [oa740]; exact good_drop _ (hg ν h)) PRE_pl_r2.b156.inactive PRE_pl_r2.b156.bridge cnt740_741 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted741 PRE_pl_r2.run741 PRE_pl_r2.accepted742 live742 PRE_pl_r2.b157.step PRE_pl_r2.b157.top (fun ν h => by rw [oa741]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br741_743 cnt741_743 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b157.parts PRE_pl_r2.b157.args_ok PRE_pl_r2.b157.sym PRE_pl_r2.b157.mlx PRE_pl_r2.b157.pay (by decide) PRE_pl_r2.b157.decode PRE_pl_r2.b157.pre PRE_pl_r2.b157.runS (fun ν h => by rw [oa743]; exact good_drop _ (hg ν h)) PRE_pl_r2.b157.inactive PRE_pl_r2.b157.bridge cnt743_744 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted744 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run744 PRE_pl_r2.run745) PRE_pl_r2.run746) PRE_pl_r2.run747) PRE_pl_r2.run748) PRE_pl_r2.run749) PRE_pl_r2.run750) PRE_pl_r2.accepted751 live751 PRE_pl_r2.b158.step PRE_pl_r2.b158.top (fun ν h => by rw [oa744]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br744_752 cnt744_752 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b158.parts PRE_pl_r2.b158.args_ok PRE_pl_r2.b158.sym PRE_pl_r2.b158.mlx PRE_pl_r2.b158.pay (by decide) PRE_pl_r2.b158.decode PRE_pl_r2.b158.pre PRE_pl_r2.b158.runS (fun ν h => by rw [oa752]; exact good_drop _ (hg ν h)) PRE_pl_r2.b158.inactive PRE_pl_r2.b158.bridge cnt752_753 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted753 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run753 PRE_pl_r2.run754) PRE_pl_r2.run755) PRE_pl_r2.accepted756 live756 PRE_pl_r2.b159.step PRE_pl_r2.b159.top (fun ν h => by rw [oa753]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br753_757 cnt753_757 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b159.parts PRE_pl_r2.b159.args_ok PRE_pl_r2.b159.sym PRE_pl_r2.b159.mlx PRE_pl_r2.b159.pay (by decide) PRE_pl_r2.b159.decode PRE_pl_r2.b159.pre PRE_pl_r2.b159.runS (fun ν h => by rw [oa757]; exact good_drop _ (hg ν h)) PRE_pl_r2.b159.inactive PRE_pl_r2.b159.bridge cnt757_758 hT)

end Host.Ts.Sim.Compose.Post.PL.R2
