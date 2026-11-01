import host.sim.compose.PostChain
import host.sim.template.a4pre_pl_r2.Good
import host.sim.template.a4pre_pl_r2.K461
import host.sim.template.a4pre_pl_r2.K462
import host.sim.template.a4pre_pl_r2.K463
import host.sim.template.a4pre_pl_r2.K464
import host.sim.template.a4pre_pl_r2.Accept7
import host.sim.template.a4pre_pl_r2.Size96
import host.sim.template.a4pre_pl_r2.H14
import host.sim.template.a4pre_pl_r2.K467
import host.sim.template.a4pre_pl_r2.Size97
import host.sim.template.a4pre_pl_r2.K470
import host.sim.template.a4pre_pl_r2.K471
import host.sim.template.a4pre_pl_r2.K472
import host.sim.template.a4pre_pl_r2.Size98
import host.sim.template.a4pre_pl_r2.K475
import host.sim.template.a4pre_pl_r2.Size99
import host.sim.template.a4pre_pl_r2.K478
import host.sim.template.a4pre_pl_r2.K479
import host.sim.template.a4pre_pl_r2.K480
import host.sim.template.a4pre_pl_r2.K481
import host.sim.template.a4pre_pl_r2.Size100
import host.sim.template.a4pre_pl_r2.H15
import host.sim.template.a4pre_pl_r2.K484
import host.sim.template.a4pre_pl_r2.Size101
import host.sim.template.a4pre_pl_r2.K487
import host.sim.template.a4pre_pl_r2.K488
import host.sim.template.a4pre_pl_r2.K489
import host.sim.template.a4pre_pl_r2.Size102
import host.sim.template.a4pre_pl_r2.K492
import host.sim.template.a4pre_pl_r2.Size103
import host.sim.template.a4pre_pl_r2.K495
import host.sim.template.a4pre_pl_r2.K496
import host.sim.template.a4pre_pl_r2.K497
import host.sim.template.a4pre_pl_r2.K498
import host.sim.template.a4pre_pl_r2.Size104
import host.sim.template.a4pre_pl_r2.K501
import host.sim.template.a4pre_pl_r2.Size105
import host.sim.template.a4pre_pl_r2.K504
import host.sim.template.a4pre_pl_r2.K505
import host.sim.template.a4pre_pl_r2.K506
import host.sim.template.a4pre_pl_r2.K507
import host.sim.template.a4pre_pl_r2.K508
import host.sim.template.a4pre_pl_r2.K509
import host.sim.template.a4pre_pl_r2.K510
import host.sim.template.a4pre_pl_r2.Accept8
import host.sim.template.a4pre_pl_r2.Size106
import host.sim.template.a4pre_pl_r2.H16
import host.sim.template.a4pre_pl_r2.K513
import host.sim.template.a4pre_pl_r2.K514
import host.sim.template.a4pre_pl_r2.K515
import host.sim.template.a4pre_pl_r2.Size107
import host.sim.template.a4pre_pl_r2.K518
import host.sim.template.a4pre_pl_r2.Size108
import host.sim.template.a4pre_pl_r2.K521
import host.sim.template.a4pre_pl_r2.K522
import host.sim.template.a4pre_pl_r2.K523
import host.sim.template.a4pre_pl_r2.K524
import host.sim.template.a4pre_pl_r2.Size109
import host.sim.template.a4pre_pl_r2.K527
import host.sim.template.a4pre_pl_r2.Size110
import host.sim.template.a4pre_pl_r2.K530
import host.sim.template.a4pre_pl_r2.K531
import host.sim.template.a4pre_pl_r2.K532
import host.sim.template.a4pre_pl_r2.Size111
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.R2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl oa461 : PRE_pl_r2.S461.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S461.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live465 : isHalt PRE_pl_r2.s465.ctl = false
kernel_rfl br461_466 : bridgeOf PRE_pl_r2.s466.ffi = bridgeOf PRE_pl_r2.s461.ffi
kernel_rfl cnt461_466 : countersOkB PRE_pl_r2.s461 PRE_pl_r2.s466 = true
kernel_rfl oa466 : PRE_pl_r2.S466.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S466.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt466_467 : countersOkB PRE_pl_r2.s466 PRE_pl_r2.s467 = true
kernel_rfl oa467 : PRE_pl_r2.S467.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S467.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live468 : isHalt PRE_pl_r2.s468.ctl = false
kernel_rfl br467_469 : bridgeOf PRE_pl_r2.s469.ffi = bridgeOf PRE_pl_r2.s467.ffi
kernel_rfl cnt467_469 : countersOkB PRE_pl_r2.s467 PRE_pl_r2.s469 = true
kernel_rfl oa469 : PRE_pl_r2.S469.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S469.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt469_470 : countersOkB PRE_pl_r2.s469 PRE_pl_r2.s470 = true
kernel_rfl oa470 : PRE_pl_r2.S470.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S470.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live473 : isHalt PRE_pl_r2.s473.ctl = false
kernel_rfl br470_474 : bridgeOf PRE_pl_r2.s474.ffi = bridgeOf PRE_pl_r2.s470.ffi
kernel_rfl cnt470_474 : countersOkB PRE_pl_r2.s470 PRE_pl_r2.s474 = true
kernel_rfl oa474 : PRE_pl_r2.S474.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S474.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt474_475 : countersOkB PRE_pl_r2.s474 PRE_pl_r2.s475 = true
kernel_rfl oa475 : PRE_pl_r2.S475.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S475.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live476 : isHalt PRE_pl_r2.s476.ctl = false
kernel_rfl br475_477 : bridgeOf PRE_pl_r2.s477.ffi = bridgeOf PRE_pl_r2.s475.ffi
kernel_rfl cnt475_477 : countersOkB PRE_pl_r2.s475 PRE_pl_r2.s477 = true
kernel_rfl oa477 : PRE_pl_r2.S477.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S477.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt477_478 : countersOkB PRE_pl_r2.s477 PRE_pl_r2.s478 = true
kernel_rfl oa478 : PRE_pl_r2.S478.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S478.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live482 : isHalt PRE_pl_r2.s482.ctl = false
kernel_rfl br478_483 : bridgeOf PRE_pl_r2.s483.ffi = bridgeOf PRE_pl_r2.s478.ffi
kernel_rfl cnt478_483 : countersOkB PRE_pl_r2.s478 PRE_pl_r2.s483 = true
kernel_rfl oa483 : PRE_pl_r2.S483.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S483.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt483_484 : countersOkB PRE_pl_r2.s483 PRE_pl_r2.s484 = true
kernel_rfl oa484 : PRE_pl_r2.S484.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S484.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live485 : isHalt PRE_pl_r2.s485.ctl = false
kernel_rfl br484_486 : bridgeOf PRE_pl_r2.s486.ffi = bridgeOf PRE_pl_r2.s484.ffi
kernel_rfl cnt484_486 : countersOkB PRE_pl_r2.s484 PRE_pl_r2.s486 = true
kernel_rfl oa486 : PRE_pl_r2.S486.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S486.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt486_487 : countersOkB PRE_pl_r2.s486 PRE_pl_r2.s487 = true
kernel_rfl oa487 : PRE_pl_r2.S487.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S487.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live490 : isHalt PRE_pl_r2.s490.ctl = false
kernel_rfl br487_491 : bridgeOf PRE_pl_r2.s491.ffi = bridgeOf PRE_pl_r2.s487.ffi
kernel_rfl cnt487_491 : countersOkB PRE_pl_r2.s487 PRE_pl_r2.s491 = true
kernel_rfl oa491 : PRE_pl_r2.S491.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S491.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt491_492 : countersOkB PRE_pl_r2.s491 PRE_pl_r2.s492 = true
kernel_rfl oa492 : PRE_pl_r2.S492.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S492.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live493 : isHalt PRE_pl_r2.s493.ctl = false
kernel_rfl br492_494 : bridgeOf PRE_pl_r2.s494.ffi = bridgeOf PRE_pl_r2.s492.ffi
kernel_rfl cnt492_494 : countersOkB PRE_pl_r2.s492 PRE_pl_r2.s494 = true
kernel_rfl oa494 : PRE_pl_r2.S494.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S494.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt494_495 : countersOkB PRE_pl_r2.s494 PRE_pl_r2.s495 = true
kernel_rfl oa495 : PRE_pl_r2.S495.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S495.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live499 : isHalt PRE_pl_r2.s499.ctl = false
kernel_rfl br495_500 : bridgeOf PRE_pl_r2.s500.ffi = bridgeOf PRE_pl_r2.s495.ffi
kernel_rfl cnt495_500 : countersOkB PRE_pl_r2.s495 PRE_pl_r2.s500 = true
kernel_rfl oa500 : PRE_pl_r2.S500.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S500.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt500_501 : countersOkB PRE_pl_r2.s500 PRE_pl_r2.s501 = true
kernel_rfl oa501 : PRE_pl_r2.S501.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S501.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live502 : isHalt PRE_pl_r2.s502.ctl = false
kernel_rfl br501_503 : bridgeOf PRE_pl_r2.s503.ffi = bridgeOf PRE_pl_r2.s501.ffi
kernel_rfl cnt501_503 : countersOkB PRE_pl_r2.s501 PRE_pl_r2.s503 = true
kernel_rfl oa503 : PRE_pl_r2.S503.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S503.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt503_504 : countersOkB PRE_pl_r2.s503 PRE_pl_r2.s504 = true
kernel_rfl oa504 : PRE_pl_r2.S504.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S504.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live511 : isHalt PRE_pl_r2.s511.ctl = false
kernel_rfl br504_512 : bridgeOf PRE_pl_r2.s512.ffi = bridgeOf PRE_pl_r2.s504.ffi
kernel_rfl cnt504_512 : countersOkB PRE_pl_r2.s504 PRE_pl_r2.s512 = true
kernel_rfl oa512 : PRE_pl_r2.S512.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S512.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt512_513 : countersOkB PRE_pl_r2.s512 PRE_pl_r2.s513 = true
kernel_rfl oa513 : PRE_pl_r2.S513.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S513.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live516 : isHalt PRE_pl_r2.s516.ctl = false
kernel_rfl br513_517 : bridgeOf PRE_pl_r2.s517.ffi = bridgeOf PRE_pl_r2.s513.ffi
kernel_rfl cnt513_517 : countersOkB PRE_pl_r2.s513 PRE_pl_r2.s517 = true
kernel_rfl oa517 : PRE_pl_r2.S517.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S517.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt517_518 : countersOkB PRE_pl_r2.s517 PRE_pl_r2.s518 = true
kernel_rfl oa518 : PRE_pl_r2.S518.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S518.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live519 : isHalt PRE_pl_r2.s519.ctl = false
kernel_rfl br518_520 : bridgeOf PRE_pl_r2.s520.ffi = bridgeOf PRE_pl_r2.s518.ffi
kernel_rfl cnt518_520 : countersOkB PRE_pl_r2.s518 PRE_pl_r2.s520 = true
kernel_rfl oa520 : PRE_pl_r2.S520.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S520.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt520_521 : countersOkB PRE_pl_r2.s520 PRE_pl_r2.s521 = true
kernel_rfl oa521 : PRE_pl_r2.S521.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S521.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live525 : isHalt PRE_pl_r2.s525.ctl = false
kernel_rfl br521_526 : bridgeOf PRE_pl_r2.s526.ffi = bridgeOf PRE_pl_r2.s521.ffi
kernel_rfl cnt521_526 : countersOkB PRE_pl_r2.s521 PRE_pl_r2.s526 = true
kernel_rfl oa526 : PRE_pl_r2.S526.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S526.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt526_527 : countersOkB PRE_pl_r2.s526 PRE_pl_r2.s527 = true
kernel_rfl oa527 : PRE_pl_r2.S527.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S527.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live528 : isHalt PRE_pl_r2.s528.ctl = false
kernel_rfl br527_529 : bridgeOf PRE_pl_r2.s529.ffi = bridgeOf PRE_pl_r2.s527.ffi
kernel_rfl cnt527_529 : countersOkB PRE_pl_r2.s527 PRE_pl_r2.s529 = true
kernel_rfl oa529 : PRE_pl_r2.S529.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S529.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt529_530 : countersOkB PRE_pl_r2.s529 PRE_pl_r2.s530 = true
kernel_rfl oa530 : PRE_pl_r2.S530.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S530.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live533 : isHalt PRE_pl_r2.s533.ctl = false
kernel_rfl br530_534 : bridgeOf PRE_pl_r2.s534.ffi = bridgeOf PRE_pl_r2.s530.ffi
kernel_rfl cnt530_534 : countersOkB PRE_pl_r2.s530 PRE_pl_r2.s534 = true
kernel_rfl oa534 : PRE_pl_r2.S534.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S534.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt534_535 : countersOkB PRE_pl_r2.s534 PRE_pl_r2.s535 = true

abbrev n6 : Nat := (((((((((((((((((((((((((((((((((((((nth? PRE_pl_r2.ks 461).getD 0) + ((nth? PRE_pl_r2.ks 462).getD 0)) + ((nth? PRE_pl_r2.ks 463).getD 0)) + ((nth? PRE_pl_r2.ks 464).getD 0)) + 1) + 3) + (((nth? PRE_pl_r2.ks 467).getD 0) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 470).getD 0) + ((nth? PRE_pl_r2.ks 471).getD 0)) + ((nth? PRE_pl_r2.ks 472).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 475).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r2.ks 478).getD 0) + ((nth? PRE_pl_r2.ks 479).getD 0)) + ((nth? PRE_pl_r2.ks 480).getD 0)) + ((nth? PRE_pl_r2.ks 481).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 484).getD 0) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 487).getD 0) + ((nth? PRE_pl_r2.ks 488).getD 0)) + ((nth? PRE_pl_r2.ks 489).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 492).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r2.ks 495).getD 0) + ((nth? PRE_pl_r2.ks 496).getD 0)) + ((nth? PRE_pl_r2.ks 497).getD 0)) + ((nth? PRE_pl_r2.ks 498).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 501).getD 0) + 1)) + 3) + (((((((((nth? PRE_pl_r2.ks 504).getD 0) + ((nth? PRE_pl_r2.ks 505).getD 0)) + ((nth? PRE_pl_r2.ks 506).getD 0)) + ((nth? PRE_pl_r2.ks 507).getD 0)) + ((nth? PRE_pl_r2.ks 508).getD 0)) + ((nth? PRE_pl_r2.ks 509).getD 0)) + ((nth? PRE_pl_r2.ks 510).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 513).getD 0) + ((nth? PRE_pl_r2.ks 514).getD 0)) + ((nth? PRE_pl_r2.ks 515).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 518).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r2.ks 521).getD 0) + ((nth? PRE_pl_r2.ks 522).getD 0)) + ((nth? PRE_pl_r2.ks 523).getD 0)) + ((nth? PRE_pl_r2.ks 524).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 527).getD 0) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 530).getD 0) + ((nth? PRE_pl_r2.ks 531).getD 0)) + ((nth? PRE_pl_r2.ks 532).getD 0)) + 1)) + 3)

theorem c6 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_r2.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r2.s461 PRE_pl_r2.S461)) (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r2.s535 PRE_pl_r2.S535)) n6 :=
  ((((((((((((((((((((((((((((((((callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted461 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run461 PRE_pl_r2.run462) PRE_pl_r2.run463) PRE_pl_r2.run464) PRE_pl_r2.accepted465 live465 PRE_pl_r2.b96.step PRE_pl_r2.b96.top (fun ν h => by rw [oa461]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br461_466 cnt461_466 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b96.parts PRE_pl_r2.b96.args_ok PRE_pl_r2.b96.sym PRE_pl_r2.b96.mlx PRE_pl_r2.b96.pay (by decide) PRE_pl_r2.b96.decode PRE_pl_r2.b96.pre PRE_pl_r2.b96.runS (fun ν h => by rw [oa466]; exact good_drop _ (hg ν h)) PRE_pl_r2.b96.inactive PRE_pl_r2.b96.bridge cnt466_467 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted467 PRE_pl_r2.run467 PRE_pl_r2.accepted468 live468 PRE_pl_r2.b97.step PRE_pl_r2.b97.top (fun ν h => by rw [oa467]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br467_469 cnt467_469 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b97.parts PRE_pl_r2.b97.args_ok PRE_pl_r2.b97.sym PRE_pl_r2.b97.mlx PRE_pl_r2.b97.pay (by decide) PRE_pl_r2.b97.decode PRE_pl_r2.b97.pre PRE_pl_r2.b97.runS (fun ν h => by rw [oa469]; exact good_drop _ (hg ν h)) PRE_pl_r2.b97.inactive PRE_pl_r2.b97.bridge cnt469_470 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted470 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run470 PRE_pl_r2.run471) PRE_pl_r2.run472) PRE_pl_r2.accepted473 live473 PRE_pl_r2.b98.step PRE_pl_r2.b98.top (fun ν h => by rw [oa470]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br470_474 cnt470_474 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b98.parts PRE_pl_r2.b98.args_ok PRE_pl_r2.b98.sym PRE_pl_r2.b98.mlx PRE_pl_r2.b98.pay (by decide) PRE_pl_r2.b98.decode PRE_pl_r2.b98.pre PRE_pl_r2.b98.runS (fun ν h => by rw [oa474]; exact good_drop _ (hg ν h)) PRE_pl_r2.b98.inactive PRE_pl_r2.b98.bridge cnt474_475 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted475 PRE_pl_r2.run475 PRE_pl_r2.accepted476 live476 PRE_pl_r2.b99.step PRE_pl_r2.b99.top (fun ν h => by rw [oa475]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br475_477 cnt475_477 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b99.parts PRE_pl_r2.b99.args_ok PRE_pl_r2.b99.sym PRE_pl_r2.b99.mlx PRE_pl_r2.b99.pay (by decide) PRE_pl_r2.b99.decode PRE_pl_r2.b99.pre PRE_pl_r2.b99.runS (fun ν h => by rw [oa477]; exact good_drop _ (hg ν h)) PRE_pl_r2.b99.inactive PRE_pl_r2.b99.bridge cnt477_478 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted478 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run478 PRE_pl_r2.run479) PRE_pl_r2.run480) PRE_pl_r2.run481) PRE_pl_r2.accepted482 live482 PRE_pl_r2.b100.step PRE_pl_r2.b100.top (fun ν h => by rw [oa478]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br478_483 cnt478_483 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b100.parts PRE_pl_r2.b100.args_ok PRE_pl_r2.b100.sym PRE_pl_r2.b100.mlx PRE_pl_r2.b100.pay (by decide) PRE_pl_r2.b100.decode PRE_pl_r2.b100.pre PRE_pl_r2.b100.runS (fun ν h => by rw [oa483]; exact good_drop _ (hg ν h)) PRE_pl_r2.b100.inactive PRE_pl_r2.b100.bridge cnt483_484 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted484 PRE_pl_r2.run484 PRE_pl_r2.accepted485 live485 PRE_pl_r2.b101.step PRE_pl_r2.b101.top (fun ν h => by rw [oa484]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br484_486 cnt484_486 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b101.parts PRE_pl_r2.b101.args_ok PRE_pl_r2.b101.sym PRE_pl_r2.b101.mlx PRE_pl_r2.b101.pay (by decide) PRE_pl_r2.b101.decode PRE_pl_r2.b101.pre PRE_pl_r2.b101.runS (fun ν h => by rw [oa486]; exact good_drop _ (hg ν h)) PRE_pl_r2.b101.inactive PRE_pl_r2.b101.bridge cnt486_487 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted487 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run487 PRE_pl_r2.run488) PRE_pl_r2.run489) PRE_pl_r2.accepted490 live490 PRE_pl_r2.b102.step PRE_pl_r2.b102.top (fun ν h => by rw [oa487]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br487_491 cnt487_491 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b102.parts PRE_pl_r2.b102.args_ok PRE_pl_r2.b102.sym PRE_pl_r2.b102.mlx PRE_pl_r2.b102.pay (by decide) PRE_pl_r2.b102.decode PRE_pl_r2.b102.pre PRE_pl_r2.b102.runS (fun ν h => by rw [oa491]; exact good_drop _ (hg ν h)) PRE_pl_r2.b102.inactive PRE_pl_r2.b102.bridge cnt491_492 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted492 PRE_pl_r2.run492 PRE_pl_r2.accepted493 live493 PRE_pl_r2.b103.step PRE_pl_r2.b103.top (fun ν h => by rw [oa492]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br492_494 cnt492_494 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b103.parts PRE_pl_r2.b103.args_ok PRE_pl_r2.b103.sym PRE_pl_r2.b103.mlx PRE_pl_r2.b103.pay (by decide) PRE_pl_r2.b103.decode PRE_pl_r2.b103.pre PRE_pl_r2.b103.runS (fun ν h => by rw [oa494]; exact good_drop _ (hg ν h)) PRE_pl_r2.b103.inactive PRE_pl_r2.b103.bridge cnt494_495 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted495 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run495 PRE_pl_r2.run496) PRE_pl_r2.run497) PRE_pl_r2.run498) PRE_pl_r2.accepted499 live499 PRE_pl_r2.b104.step PRE_pl_r2.b104.top (fun ν h => by rw [oa495]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br495_500 cnt495_500 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b104.parts PRE_pl_r2.b104.args_ok PRE_pl_r2.b104.sym PRE_pl_r2.b104.mlx PRE_pl_r2.b104.pay (by decide) PRE_pl_r2.b104.decode PRE_pl_r2.b104.pre PRE_pl_r2.b104.runS (fun ν h => by rw [oa500]; exact good_drop _ (hg ν h)) PRE_pl_r2.b104.inactive PRE_pl_r2.b104.bridge cnt500_501 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted501 PRE_pl_r2.run501 PRE_pl_r2.accepted502 live502 PRE_pl_r2.b105.step PRE_pl_r2.b105.top (fun ν h => by rw [oa501]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br501_503 cnt501_503 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b105.parts PRE_pl_r2.b105.args_ok PRE_pl_r2.b105.sym PRE_pl_r2.b105.mlx PRE_pl_r2.b105.pay (by decide) PRE_pl_r2.b105.decode PRE_pl_r2.b105.pre PRE_pl_r2.b105.runS (fun ν h => by rw [oa503]; exact good_drop _ (hg ν h)) PRE_pl_r2.b105.inactive PRE_pl_r2.b105.bridge cnt503_504 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted504 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run504 PRE_pl_r2.run505) PRE_pl_r2.run506) PRE_pl_r2.run507) PRE_pl_r2.run508) PRE_pl_r2.run509) PRE_pl_r2.run510) PRE_pl_r2.accepted511 live511 PRE_pl_r2.b106.step PRE_pl_r2.b106.top (fun ν h => by rw [oa504]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br504_512 cnt504_512 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b106.parts PRE_pl_r2.b106.args_ok PRE_pl_r2.b106.sym PRE_pl_r2.b106.mlx PRE_pl_r2.b106.pay (by decide) PRE_pl_r2.b106.decode PRE_pl_r2.b106.pre PRE_pl_r2.b106.runS (fun ν h => by rw [oa512]; exact good_drop _ (hg ν h)) PRE_pl_r2.b106.inactive PRE_pl_r2.b106.bridge cnt512_513 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted513 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run513 PRE_pl_r2.run514) PRE_pl_r2.run515) PRE_pl_r2.accepted516 live516 PRE_pl_r2.b107.step PRE_pl_r2.b107.top (fun ν h => by rw [oa513]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br513_517 cnt513_517 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b107.parts PRE_pl_r2.b107.args_ok PRE_pl_r2.b107.sym PRE_pl_r2.b107.mlx PRE_pl_r2.b107.pay (by decide) PRE_pl_r2.b107.decode PRE_pl_r2.b107.pre PRE_pl_r2.b107.runS (fun ν h => by rw [oa517]; exact good_drop _ (hg ν h)) PRE_pl_r2.b107.inactive PRE_pl_r2.b107.bridge cnt517_518 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted518 PRE_pl_r2.run518 PRE_pl_r2.accepted519 live519 PRE_pl_r2.b108.step PRE_pl_r2.b108.top (fun ν h => by rw [oa518]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br518_520 cnt518_520 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b108.parts PRE_pl_r2.b108.args_ok PRE_pl_r2.b108.sym PRE_pl_r2.b108.mlx PRE_pl_r2.b108.pay (by decide) PRE_pl_r2.b108.decode PRE_pl_r2.b108.pre PRE_pl_r2.b108.runS (fun ν h => by rw [oa520]; exact good_drop _ (hg ν h)) PRE_pl_r2.b108.inactive PRE_pl_r2.b108.bridge cnt520_521 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted521 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run521 PRE_pl_r2.run522) PRE_pl_r2.run523) PRE_pl_r2.run524) PRE_pl_r2.accepted525 live525 PRE_pl_r2.b109.step PRE_pl_r2.b109.top (fun ν h => by rw [oa521]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br521_526 cnt521_526 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b109.parts PRE_pl_r2.b109.args_ok PRE_pl_r2.b109.sym PRE_pl_r2.b109.mlx PRE_pl_r2.b109.pay (by decide) PRE_pl_r2.b109.decode PRE_pl_r2.b109.pre PRE_pl_r2.b109.runS (fun ν h => by rw [oa526]; exact good_drop _ (hg ν h)) PRE_pl_r2.b109.inactive PRE_pl_r2.b109.bridge cnt526_527 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted527 PRE_pl_r2.run527 PRE_pl_r2.accepted528 live528 PRE_pl_r2.b110.step PRE_pl_r2.b110.top (fun ν h => by rw [oa527]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br527_529 cnt527_529 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b110.parts PRE_pl_r2.b110.args_ok PRE_pl_r2.b110.sym PRE_pl_r2.b110.mlx PRE_pl_r2.b110.pay (by decide) PRE_pl_r2.b110.decode PRE_pl_r2.b110.pre PRE_pl_r2.b110.runS (fun ν h => by rw [oa529]; exact good_drop _ (hg ν h)) PRE_pl_r2.b110.inactive PRE_pl_r2.b110.bridge cnt529_530 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted530 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run530 PRE_pl_r2.run531) PRE_pl_r2.run532) PRE_pl_r2.accepted533 live533 PRE_pl_r2.b111.step PRE_pl_r2.b111.top (fun ν h => by rw [oa530]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br530_534 cnt530_534 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b111.parts PRE_pl_r2.b111.args_ok PRE_pl_r2.b111.sym PRE_pl_r2.b111.mlx PRE_pl_r2.b111.pay (by decide) PRE_pl_r2.b111.decode PRE_pl_r2.b111.pre PRE_pl_r2.b111.runS (fun ν h => by rw [oa534]; exact good_drop _ (hg ν h)) PRE_pl_r2.b111.inactive PRE_pl_r2.b111.bridge cnt534_535 hT)

end Host.Ts.Sim.Compose.Post.PL.R2
