import host.sim.compose.PostChain
import host.sim.template.a4pre_pl_r1.Good
import host.sim.template.a4pre_pl_r1.K607
import host.sim.template.a4pre_pl_r1.K608
import host.sim.template.a4pre_pl_r1.K609
import host.sim.template.a4pre_pl_r1.Accept9
import host.sim.template.a4pre_pl_r1.Size128
import host.sim.template.a4pre_pl_r1.H18
import host.sim.template.a4pre_pl_r1.H19
import host.sim.template.a4pre_pl_r1.K612
import host.sim.template.a4pre_pl_r1.Size129
import host.sim.template.a4pre_pl_r1.K615
import host.sim.template.a4pre_pl_r1.K616
import host.sim.template.a4pre_pl_r1.K617
import host.sim.template.a4pre_pl_r1.K618
import host.sim.template.a4pre_pl_r1.Size130
import host.sim.template.a4pre_pl_r1.K621
import host.sim.template.a4pre_pl_r1.Size131
import host.sim.template.a4pre_pl_r1.K624
import host.sim.template.a4pre_pl_r1.K625
import host.sim.template.a4pre_pl_r1.K626
import host.sim.template.a4pre_pl_r1.K627
import host.sim.template.a4pre_pl_r1.K628
import host.sim.template.a4pre_pl_r1.K629
import host.sim.template.a4pre_pl_r1.K630
import host.sim.template.a4pre_pl_r1.Size132
import host.sim.template.a4pre_pl_r1.K633
import host.sim.template.a4pre_pl_r1.K634
import host.sim.template.a4pre_pl_r1.K635
import host.sim.template.a4pre_pl_r1.Accept10
import host.sim.template.a4pre_pl_r1.Size133
import host.sim.template.a4pre_pl_r1.K638
import host.sim.template.a4pre_pl_r1.Size134
import host.sim.template.a4pre_pl_r1.H20
import host.sim.template.a4pre_pl_r1.K641
import host.sim.template.a4pre_pl_r1.K642
import host.sim.template.a4pre_pl_r1.K643
import host.sim.template.a4pre_pl_r1.K644
import host.sim.template.a4pre_pl_r1.Size135
import host.sim.template.a4pre_pl_r1.K647
import host.sim.template.a4pre_pl_r1.Size136
import host.sim.template.a4pre_pl_r1.K650
import host.sim.template.a4pre_pl_r1.K651
import host.sim.template.a4pre_pl_r1.K652
import host.sim.template.a4pre_pl_r1.Size137
import host.sim.template.a4pre_pl_r1.K655
import host.sim.template.a4pre_pl_r1.Size138
import host.sim.template.a4pre_pl_r1.K658
import host.sim.template.a4pre_pl_r1.K659
import host.sim.template.a4pre_pl_r1.K660
import host.sim.template.a4pre_pl_r1.K661
import host.sim.template.a4pre_pl_r1.Size139
import host.sim.template.a4pre_pl_r1.K664
import host.sim.template.a4pre_pl_r1.Size140
import host.sim.template.a4pre_pl_r1.K667
import host.sim.template.a4pre_pl_r1.K668
import host.sim.template.a4pre_pl_r1.K669
import host.sim.template.a4pre_pl_r1.Size141
import host.sim.template.a4pre_pl_r1.H21
import host.sim.template.a4pre_pl_r1.K672
import host.sim.template.a4pre_pl_r1.Size142
import host.sim.template.a4pre_pl_r1.K675
import host.sim.template.a4pre_pl_r1.K676
import host.sim.template.a4pre_pl_r1.K677
import host.sim.template.a4pre_pl_r1.K678
import host.sim.template.a4pre_pl_r1.Size143
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.R1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl oa607 : PRE_pl_r1.S607.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S607.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live610 : isHalt PRE_pl_r1.s610.ctl = false
kernel_rfl br607_611 : bridgeOf PRE_pl_r1.s611.ffi = bridgeOf PRE_pl_r1.s607.ffi
kernel_rfl cnt607_611 : countersOkB PRE_pl_r1.s607 PRE_pl_r1.s611 = true
kernel_rfl oa611 : PRE_pl_r1.S611.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S611.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt611_612 : countersOkB PRE_pl_r1.s611 PRE_pl_r1.s612 = true
kernel_rfl oa612 : PRE_pl_r1.S612.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S612.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live613 : isHalt PRE_pl_r1.s613.ctl = false
kernel_rfl br612_614 : bridgeOf PRE_pl_r1.s614.ffi = bridgeOf PRE_pl_r1.s612.ffi
kernel_rfl cnt612_614 : countersOkB PRE_pl_r1.s612 PRE_pl_r1.s614 = true
kernel_rfl oa614 : PRE_pl_r1.S614.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S614.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt614_615 : countersOkB PRE_pl_r1.s614 PRE_pl_r1.s615 = true
kernel_rfl oa615 : PRE_pl_r1.S615.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S615.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live619 : isHalt PRE_pl_r1.s619.ctl = false
kernel_rfl br615_620 : bridgeOf PRE_pl_r1.s620.ffi = bridgeOf PRE_pl_r1.s615.ffi
kernel_rfl cnt615_620 : countersOkB PRE_pl_r1.s615 PRE_pl_r1.s620 = true
kernel_rfl oa620 : PRE_pl_r1.S620.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S620.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt620_621 : countersOkB PRE_pl_r1.s620 PRE_pl_r1.s621 = true
kernel_rfl oa621 : PRE_pl_r1.S621.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S621.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live622 : isHalt PRE_pl_r1.s622.ctl = false
kernel_rfl br621_623 : bridgeOf PRE_pl_r1.s623.ffi = bridgeOf PRE_pl_r1.s621.ffi
kernel_rfl cnt621_623 : countersOkB PRE_pl_r1.s621 PRE_pl_r1.s623 = true
kernel_rfl oa623 : PRE_pl_r1.S623.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S623.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt623_624 : countersOkB PRE_pl_r1.s623 PRE_pl_r1.s624 = true
kernel_rfl oa624 : PRE_pl_r1.S624.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S624.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live631 : isHalt PRE_pl_r1.s631.ctl = false
kernel_rfl br624_632 : bridgeOf PRE_pl_r1.s632.ffi = bridgeOf PRE_pl_r1.s624.ffi
kernel_rfl cnt624_632 : countersOkB PRE_pl_r1.s624 PRE_pl_r1.s632 = true
kernel_rfl oa632 : PRE_pl_r1.S632.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S632.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt632_633 : countersOkB PRE_pl_r1.s632 PRE_pl_r1.s633 = true
kernel_rfl oa633 : PRE_pl_r1.S633.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S633.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live636 : isHalt PRE_pl_r1.s636.ctl = false
kernel_rfl br633_637 : bridgeOf PRE_pl_r1.s637.ffi = bridgeOf PRE_pl_r1.s633.ffi
kernel_rfl cnt633_637 : countersOkB PRE_pl_r1.s633 PRE_pl_r1.s637 = true
kernel_rfl oa637 : PRE_pl_r1.S637.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S637.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt637_638 : countersOkB PRE_pl_r1.s637 PRE_pl_r1.s638 = true
kernel_rfl oa638 : PRE_pl_r1.S638.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S638.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live639 : isHalt PRE_pl_r1.s639.ctl = false
kernel_rfl br638_640 : bridgeOf PRE_pl_r1.s640.ffi = bridgeOf PRE_pl_r1.s638.ffi
kernel_rfl cnt638_640 : countersOkB PRE_pl_r1.s638 PRE_pl_r1.s640 = true
kernel_rfl oa640 : PRE_pl_r1.S640.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S640.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt640_641 : countersOkB PRE_pl_r1.s640 PRE_pl_r1.s641 = true
kernel_rfl oa641 : PRE_pl_r1.S641.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S641.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live645 : isHalt PRE_pl_r1.s645.ctl = false
kernel_rfl br641_646 : bridgeOf PRE_pl_r1.s646.ffi = bridgeOf PRE_pl_r1.s641.ffi
kernel_rfl cnt641_646 : countersOkB PRE_pl_r1.s641 PRE_pl_r1.s646 = true
kernel_rfl oa646 : PRE_pl_r1.S646.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S646.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt646_647 : countersOkB PRE_pl_r1.s646 PRE_pl_r1.s647 = true
kernel_rfl oa647 : PRE_pl_r1.S647.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S647.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live648 : isHalt PRE_pl_r1.s648.ctl = false
kernel_rfl br647_649 : bridgeOf PRE_pl_r1.s649.ffi = bridgeOf PRE_pl_r1.s647.ffi
kernel_rfl cnt647_649 : countersOkB PRE_pl_r1.s647 PRE_pl_r1.s649 = true
kernel_rfl oa649 : PRE_pl_r1.S649.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S649.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt649_650 : countersOkB PRE_pl_r1.s649 PRE_pl_r1.s650 = true
kernel_rfl oa650 : PRE_pl_r1.S650.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S650.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live653 : isHalt PRE_pl_r1.s653.ctl = false
kernel_rfl br650_654 : bridgeOf PRE_pl_r1.s654.ffi = bridgeOf PRE_pl_r1.s650.ffi
kernel_rfl cnt650_654 : countersOkB PRE_pl_r1.s650 PRE_pl_r1.s654 = true
kernel_rfl oa654 : PRE_pl_r1.S654.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S654.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt654_655 : countersOkB PRE_pl_r1.s654 PRE_pl_r1.s655 = true
kernel_rfl oa655 : PRE_pl_r1.S655.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S655.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live656 : isHalt PRE_pl_r1.s656.ctl = false
kernel_rfl br655_657 : bridgeOf PRE_pl_r1.s657.ffi = bridgeOf PRE_pl_r1.s655.ffi
kernel_rfl cnt655_657 : countersOkB PRE_pl_r1.s655 PRE_pl_r1.s657 = true
kernel_rfl oa657 : PRE_pl_r1.S657.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S657.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt657_658 : countersOkB PRE_pl_r1.s657 PRE_pl_r1.s658 = true
kernel_rfl oa658 : PRE_pl_r1.S658.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S658.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live662 : isHalt PRE_pl_r1.s662.ctl = false
kernel_rfl br658_663 : bridgeOf PRE_pl_r1.s663.ffi = bridgeOf PRE_pl_r1.s658.ffi
kernel_rfl cnt658_663 : countersOkB PRE_pl_r1.s658 PRE_pl_r1.s663 = true
kernel_rfl oa663 : PRE_pl_r1.S663.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S663.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt663_664 : countersOkB PRE_pl_r1.s663 PRE_pl_r1.s664 = true
kernel_rfl oa664 : PRE_pl_r1.S664.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S664.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live665 : isHalt PRE_pl_r1.s665.ctl = false
kernel_rfl br664_666 : bridgeOf PRE_pl_r1.s666.ffi = bridgeOf PRE_pl_r1.s664.ffi
kernel_rfl cnt664_666 : countersOkB PRE_pl_r1.s664 PRE_pl_r1.s666 = true
kernel_rfl oa666 : PRE_pl_r1.S666.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S666.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt666_667 : countersOkB PRE_pl_r1.s666 PRE_pl_r1.s667 = true
kernel_rfl oa667 : PRE_pl_r1.S667.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S667.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live670 : isHalt PRE_pl_r1.s670.ctl = false
kernel_rfl br667_671 : bridgeOf PRE_pl_r1.s671.ffi = bridgeOf PRE_pl_r1.s667.ffi
kernel_rfl cnt667_671 : countersOkB PRE_pl_r1.s667 PRE_pl_r1.s671 = true
kernel_rfl oa671 : PRE_pl_r1.S671.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S671.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt671_672 : countersOkB PRE_pl_r1.s671 PRE_pl_r1.s672 = true
kernel_rfl oa672 : PRE_pl_r1.S672.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S672.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live673 : isHalt PRE_pl_r1.s673.ctl = false
kernel_rfl br672_674 : bridgeOf PRE_pl_r1.s674.ffi = bridgeOf PRE_pl_r1.s672.ffi
kernel_rfl cnt672_674 : countersOkB PRE_pl_r1.s672 PRE_pl_r1.s674 = true
kernel_rfl oa674 : PRE_pl_r1.S674.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S674.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt674_675 : countersOkB PRE_pl_r1.s674 PRE_pl_r1.s675 = true
kernel_rfl oa675 : PRE_pl_r1.S675.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S675.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live679 : isHalt PRE_pl_r1.s679.ctl = false
kernel_rfl br675_680 : bridgeOf PRE_pl_r1.s680.ffi = bridgeOf PRE_pl_r1.s675.ffi
kernel_rfl cnt675_680 : countersOkB PRE_pl_r1.s675 PRE_pl_r1.s680 = true
kernel_rfl oa680 : PRE_pl_r1.S680.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S680.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt680_681 : countersOkB PRE_pl_r1.s680 PRE_pl_r1.s681 = true

abbrev n8 : Nat := ((((((((((((((((((((((((((((((((((((nth? PRE_pl_r1.ks 607).getD 0) + ((nth? PRE_pl_r1.ks 608).getD 0)) + ((nth? PRE_pl_r1.ks 609).getD 0)) + 1) + 3) + (((nth? PRE_pl_r1.ks 612).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r1.ks 615).getD 0) + ((nth? PRE_pl_r1.ks 616).getD 0)) + ((nth? PRE_pl_r1.ks 617).getD 0)) + ((nth? PRE_pl_r1.ks 618).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 621).getD 0) + 1)) + 3) + (((((((((nth? PRE_pl_r1.ks 624).getD 0) + ((nth? PRE_pl_r1.ks 625).getD 0)) + ((nth? PRE_pl_r1.ks 626).getD 0)) + ((nth? PRE_pl_r1.ks 627).getD 0)) + ((nth? PRE_pl_r1.ks 628).getD 0)) + ((nth? PRE_pl_r1.ks 629).getD 0)) + ((nth? PRE_pl_r1.ks 630).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_r1.ks 633).getD 0) + ((nth? PRE_pl_r1.ks 634).getD 0)) + ((nth? PRE_pl_r1.ks 635).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 638).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r1.ks 641).getD 0) + ((nth? PRE_pl_r1.ks 642).getD 0)) + ((nth? PRE_pl_r1.ks 643).getD 0)) + ((nth? PRE_pl_r1.ks 644).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 647).getD 0) + 1)) + 3) + (((((nth? PRE_pl_r1.ks 650).getD 0) + ((nth? PRE_pl_r1.ks 651).getD 0)) + ((nth? PRE_pl_r1.ks 652).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 655).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r1.ks 658).getD 0) + ((nth? PRE_pl_r1.ks 659).getD 0)) + ((nth? PRE_pl_r1.ks 660).getD 0)) + ((nth? PRE_pl_r1.ks 661).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 664).getD 0) + 1)) + 3) + (((((nth? PRE_pl_r1.ks 667).getD 0) + ((nth? PRE_pl_r1.ks 668).getD 0)) + ((nth? PRE_pl_r1.ks 669).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 672).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r1.ks 675).getD 0) + ((nth? PRE_pl_r1.ks 676).getD 0)) + ((nth? PRE_pl_r1.ks 677).getD 0)) + ((nth? PRE_pl_r1.ks 678).getD 0)) + 1)) + 3)

theorem c8 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_r1.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r1.s607 PRE_pl_r1.S607)) (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r1.s681 PRE_pl_r1.S681)) n8 :=
  ((((((((((((((((((((((((((((((((callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted607 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run607 PRE_pl_r1.run608) PRE_pl_r1.run609) PRE_pl_r1.accepted610 live610 PRE_pl_r1.b128.step PRE_pl_r1.b128.top (fun ν h => by rw [oa607]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br607_611 cnt607_611 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b128.parts PRE_pl_r1.b128.args_ok PRE_pl_r1.b128.sym PRE_pl_r1.b128.mlx PRE_pl_r1.b128.pay (by decide) PRE_pl_r1.b128.decode PRE_pl_r1.b128.pre PRE_pl_r1.b128.runS (fun ν h => by rw [oa611]; exact good_drop _ (hg ν h)) PRE_pl_r1.b128.inactive PRE_pl_r1.b128.bridge cnt611_612 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted612 PRE_pl_r1.run612 PRE_pl_r1.accepted613 live613 PRE_pl_r1.b129.step PRE_pl_r1.b129.top (fun ν h => by rw [oa612]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br612_614 cnt612_614 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b129.parts PRE_pl_r1.b129.args_ok PRE_pl_r1.b129.sym PRE_pl_r1.b129.mlx PRE_pl_r1.b129.pay (by decide) PRE_pl_r1.b129.decode PRE_pl_r1.b129.pre PRE_pl_r1.b129.runS (fun ν h => by rw [oa614]; exact good_drop _ (hg ν h)) PRE_pl_r1.b129.inactive PRE_pl_r1.b129.bridge cnt614_615 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted615 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run615 PRE_pl_r1.run616) PRE_pl_r1.run617) PRE_pl_r1.run618) PRE_pl_r1.accepted619 live619 PRE_pl_r1.b130.step PRE_pl_r1.b130.top (fun ν h => by rw [oa615]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br615_620 cnt615_620 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b130.parts PRE_pl_r1.b130.args_ok PRE_pl_r1.b130.sym PRE_pl_r1.b130.mlx PRE_pl_r1.b130.pay (by decide) PRE_pl_r1.b130.decode PRE_pl_r1.b130.pre PRE_pl_r1.b130.runS (fun ν h => by rw [oa620]; exact good_drop _ (hg ν h)) PRE_pl_r1.b130.inactive PRE_pl_r1.b130.bridge cnt620_621 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted621 PRE_pl_r1.run621 PRE_pl_r1.accepted622 live622 PRE_pl_r1.b131.step PRE_pl_r1.b131.top (fun ν h => by rw [oa621]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br621_623 cnt621_623 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b131.parts PRE_pl_r1.b131.args_ok PRE_pl_r1.b131.sym PRE_pl_r1.b131.mlx PRE_pl_r1.b131.pay (by decide) PRE_pl_r1.b131.decode PRE_pl_r1.b131.pre PRE_pl_r1.b131.runS (fun ν h => by rw [oa623]; exact good_drop _ (hg ν h)) PRE_pl_r1.b131.inactive PRE_pl_r1.b131.bridge cnt623_624 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted624 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run624 PRE_pl_r1.run625) PRE_pl_r1.run626) PRE_pl_r1.run627) PRE_pl_r1.run628) PRE_pl_r1.run629) PRE_pl_r1.run630) PRE_pl_r1.accepted631 live631 PRE_pl_r1.b132.step PRE_pl_r1.b132.top (fun ν h => by rw [oa624]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br624_632 cnt624_632 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b132.parts PRE_pl_r1.b132.args_ok PRE_pl_r1.b132.sym PRE_pl_r1.b132.mlx PRE_pl_r1.b132.pay (by decide) PRE_pl_r1.b132.decode PRE_pl_r1.b132.pre PRE_pl_r1.b132.runS (fun ν h => by rw [oa632]; exact good_drop _ (hg ν h)) PRE_pl_r1.b132.inactive PRE_pl_r1.b132.bridge cnt632_633 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted633 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run633 PRE_pl_r1.run634) PRE_pl_r1.run635) PRE_pl_r1.accepted636 live636 PRE_pl_r1.b133.step PRE_pl_r1.b133.top (fun ν h => by rw [oa633]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br633_637 cnt633_637 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b133.parts PRE_pl_r1.b133.args_ok PRE_pl_r1.b133.sym PRE_pl_r1.b133.mlx PRE_pl_r1.b133.pay (by decide) PRE_pl_r1.b133.decode PRE_pl_r1.b133.pre PRE_pl_r1.b133.runS (fun ν h => by rw [oa637]; exact good_drop _ (hg ν h)) PRE_pl_r1.b133.inactive PRE_pl_r1.b133.bridge cnt637_638 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted638 PRE_pl_r1.run638 PRE_pl_r1.accepted639 live639 PRE_pl_r1.b134.step PRE_pl_r1.b134.top (fun ν h => by rw [oa638]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br638_640 cnt638_640 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b134.parts PRE_pl_r1.b134.args_ok PRE_pl_r1.b134.sym PRE_pl_r1.b134.mlx PRE_pl_r1.b134.pay (by decide) PRE_pl_r1.b134.decode PRE_pl_r1.b134.pre PRE_pl_r1.b134.runS (fun ν h => by rw [oa640]; exact good_drop _ (hg ν h)) PRE_pl_r1.b134.inactive PRE_pl_r1.b134.bridge cnt640_641 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted641 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run641 PRE_pl_r1.run642) PRE_pl_r1.run643) PRE_pl_r1.run644) PRE_pl_r1.accepted645 live645 PRE_pl_r1.b135.step PRE_pl_r1.b135.top (fun ν h => by rw [oa641]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br641_646 cnt641_646 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b135.parts PRE_pl_r1.b135.args_ok PRE_pl_r1.b135.sym PRE_pl_r1.b135.mlx PRE_pl_r1.b135.pay (by decide) PRE_pl_r1.b135.decode PRE_pl_r1.b135.pre PRE_pl_r1.b135.runS (fun ν h => by rw [oa646]; exact good_drop _ (hg ν h)) PRE_pl_r1.b135.inactive PRE_pl_r1.b135.bridge cnt646_647 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted647 PRE_pl_r1.run647 PRE_pl_r1.accepted648 live648 PRE_pl_r1.b136.step PRE_pl_r1.b136.top (fun ν h => by rw [oa647]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br647_649 cnt647_649 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b136.parts PRE_pl_r1.b136.args_ok PRE_pl_r1.b136.sym PRE_pl_r1.b136.mlx PRE_pl_r1.b136.pay (by decide) PRE_pl_r1.b136.decode PRE_pl_r1.b136.pre PRE_pl_r1.b136.runS (fun ν h => by rw [oa649]; exact good_drop _ (hg ν h)) PRE_pl_r1.b136.inactive PRE_pl_r1.b136.bridge cnt649_650 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted650 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run650 PRE_pl_r1.run651) PRE_pl_r1.run652) PRE_pl_r1.accepted653 live653 PRE_pl_r1.b137.step PRE_pl_r1.b137.top (fun ν h => by rw [oa650]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br650_654 cnt650_654 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b137.parts PRE_pl_r1.b137.args_ok PRE_pl_r1.b137.sym PRE_pl_r1.b137.mlx PRE_pl_r1.b137.pay (by decide) PRE_pl_r1.b137.decode PRE_pl_r1.b137.pre PRE_pl_r1.b137.runS (fun ν h => by rw [oa654]; exact good_drop _ (hg ν h)) PRE_pl_r1.b137.inactive PRE_pl_r1.b137.bridge cnt654_655 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted655 PRE_pl_r1.run655 PRE_pl_r1.accepted656 live656 PRE_pl_r1.b138.step PRE_pl_r1.b138.top (fun ν h => by rw [oa655]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br655_657 cnt655_657 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b138.parts PRE_pl_r1.b138.args_ok PRE_pl_r1.b138.sym PRE_pl_r1.b138.mlx PRE_pl_r1.b138.pay (by decide) PRE_pl_r1.b138.decode PRE_pl_r1.b138.pre PRE_pl_r1.b138.runS (fun ν h => by rw [oa657]; exact good_drop _ (hg ν h)) PRE_pl_r1.b138.inactive PRE_pl_r1.b138.bridge cnt657_658 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted658 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run658 PRE_pl_r1.run659) PRE_pl_r1.run660) PRE_pl_r1.run661) PRE_pl_r1.accepted662 live662 PRE_pl_r1.b139.step PRE_pl_r1.b139.top (fun ν h => by rw [oa658]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br658_663 cnt658_663 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b139.parts PRE_pl_r1.b139.args_ok PRE_pl_r1.b139.sym PRE_pl_r1.b139.mlx PRE_pl_r1.b139.pay (by decide) PRE_pl_r1.b139.decode PRE_pl_r1.b139.pre PRE_pl_r1.b139.runS (fun ν h => by rw [oa663]; exact good_drop _ (hg ν h)) PRE_pl_r1.b139.inactive PRE_pl_r1.b139.bridge cnt663_664 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted664 PRE_pl_r1.run664 PRE_pl_r1.accepted665 live665 PRE_pl_r1.b140.step PRE_pl_r1.b140.top (fun ν h => by rw [oa664]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br664_666 cnt664_666 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b140.parts PRE_pl_r1.b140.args_ok PRE_pl_r1.b140.sym PRE_pl_r1.b140.mlx PRE_pl_r1.b140.pay (by decide) PRE_pl_r1.b140.decode PRE_pl_r1.b140.pre PRE_pl_r1.b140.runS (fun ν h => by rw [oa666]; exact good_drop _ (hg ν h)) PRE_pl_r1.b140.inactive PRE_pl_r1.b140.bridge cnt666_667 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted667 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run667 PRE_pl_r1.run668) PRE_pl_r1.run669) PRE_pl_r1.accepted670 live670 PRE_pl_r1.b141.step PRE_pl_r1.b141.top (fun ν h => by rw [oa667]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br667_671 cnt667_671 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b141.parts PRE_pl_r1.b141.args_ok PRE_pl_r1.b141.sym PRE_pl_r1.b141.mlx PRE_pl_r1.b141.pay (by decide) PRE_pl_r1.b141.decode PRE_pl_r1.b141.pre PRE_pl_r1.b141.runS (fun ν h => by rw [oa671]; exact good_drop _ (hg ν h)) PRE_pl_r1.b141.inactive PRE_pl_r1.b141.bridge cnt671_672 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted672 PRE_pl_r1.run672 PRE_pl_r1.accepted673 live673 PRE_pl_r1.b142.step PRE_pl_r1.b142.top (fun ν h => by rw [oa672]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br672_674 cnt672_674 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b142.parts PRE_pl_r1.b142.args_ok PRE_pl_r1.b142.sym PRE_pl_r1.b142.mlx PRE_pl_r1.b142.pay (by decide) PRE_pl_r1.b142.decode PRE_pl_r1.b142.pre PRE_pl_r1.b142.runS (fun ν h => by rw [oa674]; exact good_drop _ (hg ν h)) PRE_pl_r1.b142.inactive PRE_pl_r1.b142.bridge cnt674_675 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted675 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run675 PRE_pl_r1.run676) PRE_pl_r1.run677) PRE_pl_r1.run678) PRE_pl_r1.accepted679 live679 PRE_pl_r1.b143.step PRE_pl_r1.b143.top (fun ν h => by rw [oa675]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br675_680 cnt675_680 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b143.parts PRE_pl_r1.b143.args_ok PRE_pl_r1.b143.sym PRE_pl_r1.b143.mlx PRE_pl_r1.b143.pay (by decide) PRE_pl_r1.b143.decode PRE_pl_r1.b143.pre PRE_pl_r1.b143.runS (fun ν h => by rw [oa680]; exact good_drop _ (hg ν h)) PRE_pl_r1.b143.inactive PRE_pl_r1.b143.bridge cnt680_681 hT)

end Host.Ts.Sim.Compose.Post.PL.R1
