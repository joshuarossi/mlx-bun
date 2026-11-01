import host.sim.compose.PostChain
import host.sim.template.a4pre_pl_r1.m.B11
import host.sim.template.a4pre_pl_r1.m.B03
import host.sim.template.a4pre_pl_r1.m.B12
import host.sim.template.a4pre_pl_r1.H9
import host.sim.template.a4pre_pl_r1.H10
import host.sim.template.a4pre_pl_r1.m.B04
import host.sim.template.a4pre_pl_r1.H11
import host.sim.template.a4pre_pl_r1.H12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.R1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl oa310 : PRE_pl_r1.S310.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S310.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live313 : isHalt PRE_pl_r1.s313.ctl = false
kernel_rfl br310_314 : bridgeOf PRE_pl_r1.s314.ffi = bridgeOf PRE_pl_r1.s310.ffi
kernel_rfl cnt310_314 : countersOkB PRE_pl_r1.s310 PRE_pl_r1.s314 = true
kernel_rfl oa314 : PRE_pl_r1.S314.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S314.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt314_315 : countersOkB PRE_pl_r1.s314 PRE_pl_r1.s315 = true
kernel_rfl oa315 : PRE_pl_r1.S315.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S315.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live316 : isHalt PRE_pl_r1.s316.ctl = false
kernel_rfl br315_317 : bridgeOf PRE_pl_r1.s317.ffi = bridgeOf PRE_pl_r1.s315.ffi
kernel_rfl cnt315_317 : countersOkB PRE_pl_r1.s315 PRE_pl_r1.s317 = true
kernel_rfl oa317 : PRE_pl_r1.S317.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S317.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt317_318 : countersOkB PRE_pl_r1.s317 PRE_pl_r1.s318 = true
kernel_rfl oa318 : PRE_pl_r1.S318.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S318.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live322 : isHalt PRE_pl_r1.s322.ctl = false
kernel_rfl br318_323 : bridgeOf PRE_pl_r1.s323.ffi = bridgeOf PRE_pl_r1.s318.ffi
kernel_rfl cnt318_323 : countersOkB PRE_pl_r1.s318 PRE_pl_r1.s323 = true
kernel_rfl oa323 : PRE_pl_r1.S323.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S323.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt323_324 : countersOkB PRE_pl_r1.s323 PRE_pl_r1.s324 = true
kernel_rfl oa324 : PRE_pl_r1.S324.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S324.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live325 : isHalt PRE_pl_r1.s325.ctl = false
kernel_rfl br324_326 : bridgeOf PRE_pl_r1.s326.ffi = bridgeOf PRE_pl_r1.s324.ffi
kernel_rfl cnt324_326 : countersOkB PRE_pl_r1.s324 PRE_pl_r1.s326 = true
kernel_rfl oa326 : PRE_pl_r1.S326.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S326.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt326_327 : countersOkB PRE_pl_r1.s326 PRE_pl_r1.s327 = true
kernel_rfl oa327 : PRE_pl_r1.S327.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S327.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live334 : isHalt PRE_pl_r1.s334.ctl = false
kernel_rfl br327_335 : bridgeOf PRE_pl_r1.s335.ffi = bridgeOf PRE_pl_r1.s327.ffi
kernel_rfl cnt327_335 : countersOkB PRE_pl_r1.s327 PRE_pl_r1.s335 = true
kernel_rfl oa335 : PRE_pl_r1.S335.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S335.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt335_336 : countersOkB PRE_pl_r1.s335 PRE_pl_r1.s336 = true
kernel_rfl oa336 : PRE_pl_r1.S336.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S336.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live339 : isHalt PRE_pl_r1.s339.ctl = false
kernel_rfl br336_340 : bridgeOf PRE_pl_r1.s340.ffi = bridgeOf PRE_pl_r1.s336.ffi
kernel_rfl cnt336_340 : countersOkB PRE_pl_r1.s336 PRE_pl_r1.s340 = true
kernel_rfl oa340 : PRE_pl_r1.S340.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S340.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt340_341 : countersOkB PRE_pl_r1.s340 PRE_pl_r1.s341 = true
kernel_rfl oa341 : PRE_pl_r1.S341.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S341.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live342 : isHalt PRE_pl_r1.s342.ctl = false
kernel_rfl br341_343 : bridgeOf PRE_pl_r1.s343.ffi = bridgeOf PRE_pl_r1.s341.ffi
kernel_rfl cnt341_343 : countersOkB PRE_pl_r1.s341 PRE_pl_r1.s343 = true
kernel_rfl oa343 : PRE_pl_r1.S343.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S343.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt343_344 : countersOkB PRE_pl_r1.s343 PRE_pl_r1.s344 = true
kernel_rfl oa344 : PRE_pl_r1.S344.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S344.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live348 : isHalt PRE_pl_r1.s348.ctl = false
kernel_rfl br344_349 : bridgeOf PRE_pl_r1.s349.ffi = bridgeOf PRE_pl_r1.s344.ffi
kernel_rfl cnt344_349 : countersOkB PRE_pl_r1.s344 PRE_pl_r1.s349 = true
kernel_rfl oa349 : PRE_pl_r1.S349.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S349.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt349_350 : countersOkB PRE_pl_r1.s349 PRE_pl_r1.s350 = true
kernel_rfl oa350 : PRE_pl_r1.S350.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S350.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live351 : isHalt PRE_pl_r1.s351.ctl = false
kernel_rfl br350_352 : bridgeOf PRE_pl_r1.s352.ffi = bridgeOf PRE_pl_r1.s350.ffi
kernel_rfl cnt350_352 : countersOkB PRE_pl_r1.s350 PRE_pl_r1.s352 = true
kernel_rfl oa352 : PRE_pl_r1.S352.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S352.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt352_353 : countersOkB PRE_pl_r1.s352 PRE_pl_r1.s353 = true
kernel_rfl oa353 : PRE_pl_r1.S353.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S353.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live356 : isHalt PRE_pl_r1.s356.ctl = false
kernel_rfl br353_357 : bridgeOf PRE_pl_r1.s357.ffi = bridgeOf PRE_pl_r1.s353.ffi
kernel_rfl cnt353_357 : countersOkB PRE_pl_r1.s353 PRE_pl_r1.s357 = true
kernel_rfl oa357 : PRE_pl_r1.S357.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S357.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt357_358 : countersOkB PRE_pl_r1.s357 PRE_pl_r1.s358 = true
kernel_rfl oa358 : PRE_pl_r1.S358.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S358.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live362 : isHalt PRE_pl_r1.s362.ctl = false
kernel_rfl br358_363 : bridgeOf PRE_pl_r1.s363.ffi = bridgeOf PRE_pl_r1.s358.ffi
kernel_rfl cnt358_363 : countersOkB PRE_pl_r1.s358 PRE_pl_r1.s363 = true
kernel_rfl oa363 : PRE_pl_r1.S363.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S363.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt363_364 : countersOkB PRE_pl_r1.s363 PRE_pl_r1.s364 = true
kernel_rfl oa364 : PRE_pl_r1.S364.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S364.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live365 : isHalt PRE_pl_r1.s365.ctl = false
kernel_rfl br364_366 : bridgeOf PRE_pl_r1.s366.ffi = bridgeOf PRE_pl_r1.s364.ffi
kernel_rfl cnt364_366 : countersOkB PRE_pl_r1.s364 PRE_pl_r1.s366 = true
kernel_rfl oa366 : PRE_pl_r1.S366.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S366.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt366_367 : countersOkB PRE_pl_r1.s366 PRE_pl_r1.s367 = true
kernel_rfl oa367 : PRE_pl_r1.S367.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S367.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live370 : isHalt PRE_pl_r1.s370.ctl = false
kernel_rfl br367_371 : bridgeOf PRE_pl_r1.s371.ffi = bridgeOf PRE_pl_r1.s367.ffi
kernel_rfl cnt367_371 : countersOkB PRE_pl_r1.s367 PRE_pl_r1.s371 = true
kernel_rfl oa371 : PRE_pl_r1.S371.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S371.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt371_372 : countersOkB PRE_pl_r1.s371 PRE_pl_r1.s372 = true
kernel_rfl oa372 : PRE_pl_r1.S372.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S372.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live373 : isHalt PRE_pl_r1.s373.ctl = false
kernel_rfl br372_374 : bridgeOf PRE_pl_r1.s374.ffi = bridgeOf PRE_pl_r1.s372.ffi
kernel_rfl cnt372_374 : countersOkB PRE_pl_r1.s372 PRE_pl_r1.s374 = true
kernel_rfl oa374 : PRE_pl_r1.S374.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S374.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt374_375 : countersOkB PRE_pl_r1.s374 PRE_pl_r1.s375 = true
kernel_rfl oa375 : PRE_pl_r1.S375.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S375.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live379 : isHalt PRE_pl_r1.s379.ctl = false
kernel_rfl br375_380 : bridgeOf PRE_pl_r1.s380.ffi = bridgeOf PRE_pl_r1.s375.ffi
kernel_rfl cnt375_380 : countersOkB PRE_pl_r1.s375 PRE_pl_r1.s380 = true
kernel_rfl oa380 : PRE_pl_r1.S380.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S380.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt380_381 : countersOkB PRE_pl_r1.s380 PRE_pl_r1.s381 = true
kernel_rfl oa381 : PRE_pl_r1.S381.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S381.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live382 : isHalt PRE_pl_r1.s382.ctl = false
kernel_rfl br381_383 : bridgeOf PRE_pl_r1.s383.ffi = bridgeOf PRE_pl_r1.s381.ffi
kernel_rfl cnt381_383 : countersOkB PRE_pl_r1.s381 PRE_pl_r1.s383 = true
kernel_rfl oa383 : PRE_pl_r1.S383.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S383.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt383_384 : countersOkB PRE_pl_r1.s383 PRE_pl_r1.s384 = true

abbrev n4 : Nat := ((((((((((((((((((((((((((((((((((((nth? PRE_pl_r1.ks 310).getD 0) + ((nth? PRE_pl_r1.ks 311).getD 0)) + ((nth? PRE_pl_r1.ks 312).getD 0)) + 1) + 3) + (((nth? PRE_pl_r1.ks 315).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r1.ks 318).getD 0) + ((nth? PRE_pl_r1.ks 319).getD 0)) + ((nth? PRE_pl_r1.ks 320).getD 0)) + ((nth? PRE_pl_r1.ks 321).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 324).getD 0) + 1)) + 3) + (((((((((nth? PRE_pl_r1.ks 327).getD 0) + ((nth? PRE_pl_r1.ks 328).getD 0)) + ((nth? PRE_pl_r1.ks 329).getD 0)) + ((nth? PRE_pl_r1.ks 330).getD 0)) + ((nth? PRE_pl_r1.ks 331).getD 0)) + ((nth? PRE_pl_r1.ks 332).getD 0)) + ((nth? PRE_pl_r1.ks 333).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_r1.ks 336).getD 0) + ((nth? PRE_pl_r1.ks 337).getD 0)) + ((nth? PRE_pl_r1.ks 338).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 341).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r1.ks 344).getD 0) + ((nth? PRE_pl_r1.ks 345).getD 0)) + ((nth? PRE_pl_r1.ks 346).getD 0)) + ((nth? PRE_pl_r1.ks 347).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 350).getD 0) + 1)) + 3) + (((((nth? PRE_pl_r1.ks 353).getD 0) + ((nth? PRE_pl_r1.ks 354).getD 0)) + ((nth? PRE_pl_r1.ks 355).getD 0)) + 1)) + 3) + ((((((nth? PRE_pl_r1.ks 358).getD 0) + ((nth? PRE_pl_r1.ks 359).getD 0)) + ((nth? PRE_pl_r1.ks 360).getD 0)) + ((nth? PRE_pl_r1.ks 361).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 364).getD 0) + 1)) + 3) + (((((nth? PRE_pl_r1.ks 367).getD 0) + ((nth? PRE_pl_r1.ks 368).getD 0)) + ((nth? PRE_pl_r1.ks 369).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 372).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r1.ks 375).getD 0) + ((nth? PRE_pl_r1.ks 376).getD 0)) + ((nth? PRE_pl_r1.ks 377).getD 0)) + ((nth? PRE_pl_r1.ks 378).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 381).getD 0) + 1)) + 3)

theorem c4 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_r1.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r1.s310 PRE_pl_r1.S310)) (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r1.s384 PRE_pl_r1.S384)) n4 :=
  ((((((((((((((((((((((((((((((((callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted310 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run310 PRE_pl_r1.run311) PRE_pl_r1.run312) PRE_pl_r1.accepted313 live313 PRE_pl_r1.b64.step PRE_pl_r1.b64.top (fun ν h => by rw [oa310]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br310_314 cnt310_314 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b64.parts PRE_pl_r1.b64.args_ok PRE_pl_r1.b64.sym PRE_pl_r1.b64.mlx PRE_pl_r1.b64.pay (by decide) PRE_pl_r1.b64.decode PRE_pl_r1.b64.pre PRE_pl_r1.b64.runS (fun ν h => by rw [oa314]; exact good_drop _ (hg ν h)) PRE_pl_r1.b64.inactive PRE_pl_r1.b64.bridge cnt314_315 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted315 PRE_pl_r1.run315 PRE_pl_r1.accepted316 live316 PRE_pl_r1.b65.step PRE_pl_r1.b65.top (fun ν h => by rw [oa315]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br315_317 cnt315_317 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b65.parts PRE_pl_r1.b65.args_ok PRE_pl_r1.b65.sym PRE_pl_r1.b65.mlx PRE_pl_r1.b65.pay (by decide) PRE_pl_r1.b65.decode PRE_pl_r1.b65.pre PRE_pl_r1.b65.runS (fun ν h => by rw [oa317]; exact good_drop _ (hg ν h)) PRE_pl_r1.b65.inactive PRE_pl_r1.b65.bridge cnt317_318 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted318 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run318 PRE_pl_r1.run319) PRE_pl_r1.run320) PRE_pl_r1.run321) PRE_pl_r1.accepted322 live322 PRE_pl_r1.b66.step PRE_pl_r1.b66.top (fun ν h => by rw [oa318]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br318_323 cnt318_323 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b66.parts PRE_pl_r1.b66.args_ok PRE_pl_r1.b66.sym PRE_pl_r1.b66.mlx PRE_pl_r1.b66.pay (by decide) PRE_pl_r1.b66.decode PRE_pl_r1.b66.pre PRE_pl_r1.b66.runS (fun ν h => by rw [oa323]; exact good_drop _ (hg ν h)) PRE_pl_r1.b66.inactive PRE_pl_r1.b66.bridge cnt323_324 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted324 PRE_pl_r1.run324 PRE_pl_r1.accepted325 live325 PRE_pl_r1.b67.step PRE_pl_r1.b67.top (fun ν h => by rw [oa324]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br324_326 cnt324_326 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b67.parts PRE_pl_r1.b67.args_ok PRE_pl_r1.b67.sym PRE_pl_r1.b67.mlx PRE_pl_r1.b67.pay (by decide) PRE_pl_r1.b67.decode PRE_pl_r1.b67.pre PRE_pl_r1.b67.runS (fun ν h => by rw [oa326]; exact good_drop _ (hg ν h)) PRE_pl_r1.b67.inactive PRE_pl_r1.b67.bridge cnt326_327 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted327 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run327 PRE_pl_r1.run328) PRE_pl_r1.run329) PRE_pl_r1.run330) PRE_pl_r1.run331) PRE_pl_r1.run332) PRE_pl_r1.run333) PRE_pl_r1.accepted334 live334 PRE_pl_r1.b68.step PRE_pl_r1.b68.top (fun ν h => by rw [oa327]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br327_335 cnt327_335 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b68.parts PRE_pl_r1.b68.args_ok PRE_pl_r1.b68.sym PRE_pl_r1.b68.mlx PRE_pl_r1.b68.pay (by decide) PRE_pl_r1.b68.decode PRE_pl_r1.b68.pre PRE_pl_r1.b68.runS (fun ν h => by rw [oa335]; exact good_drop _ (hg ν h)) PRE_pl_r1.b68.inactive PRE_pl_r1.b68.bridge cnt335_336 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted336 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run336 PRE_pl_r1.run337) PRE_pl_r1.run338) PRE_pl_r1.accepted339 live339 PRE_pl_r1.b69.step PRE_pl_r1.b69.top (fun ν h => by rw [oa336]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br336_340 cnt336_340 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b69.parts PRE_pl_r1.b69.args_ok PRE_pl_r1.b69.sym PRE_pl_r1.b69.mlx PRE_pl_r1.b69.pay (by decide) PRE_pl_r1.b69.decode PRE_pl_r1.b69.pre PRE_pl_r1.b69.runS (fun ν h => by rw [oa340]; exact good_drop _ (hg ν h)) PRE_pl_r1.b69.inactive PRE_pl_r1.b69.bridge cnt340_341 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted341 PRE_pl_r1.run341 PRE_pl_r1.accepted342 live342 PRE_pl_r1.b70.step PRE_pl_r1.b70.top (fun ν h => by rw [oa341]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br341_343 cnt341_343 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b70.parts PRE_pl_r1.b70.args_ok PRE_pl_r1.b70.sym PRE_pl_r1.b70.mlx PRE_pl_r1.b70.pay (by decide) PRE_pl_r1.b70.decode PRE_pl_r1.b70.pre PRE_pl_r1.b70.runS (fun ν h => by rw [oa343]; exact good_drop _ (hg ν h)) PRE_pl_r1.b70.inactive PRE_pl_r1.b70.bridge cnt343_344 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted344 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run344 PRE_pl_r1.run345) PRE_pl_r1.run346) PRE_pl_r1.run347) PRE_pl_r1.accepted348 live348 PRE_pl_r1.b71.step PRE_pl_r1.b71.top (fun ν h => by rw [oa344]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br344_349 cnt344_349 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b71.parts PRE_pl_r1.b71.args_ok PRE_pl_r1.b71.sym PRE_pl_r1.b71.mlx PRE_pl_r1.b71.pay (by decide) PRE_pl_r1.b71.decode PRE_pl_r1.b71.pre PRE_pl_r1.b71.runS (fun ν h => by rw [oa349]; exact good_drop _ (hg ν h)) PRE_pl_r1.b71.inactive PRE_pl_r1.b71.bridge cnt349_350 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted350 PRE_pl_r1.run350 PRE_pl_r1.accepted351 live351 PRE_pl_r1.b72.step PRE_pl_r1.b72.top (fun ν h => by rw [oa350]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br350_352 cnt350_352 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b72.parts PRE_pl_r1.b72.args_ok PRE_pl_r1.b72.sym PRE_pl_r1.b72.mlx PRE_pl_r1.b72.pay (by decide) PRE_pl_r1.b72.decode PRE_pl_r1.b72.pre PRE_pl_r1.b72.runS (fun ν h => by rw [oa352]; exact good_drop _ (hg ν h)) PRE_pl_r1.b72.inactive PRE_pl_r1.b72.bridge cnt352_353 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted353 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run353 PRE_pl_r1.run354) PRE_pl_r1.run355) PRE_pl_r1.accepted356 live356 PRE_pl_r1.b73.step PRE_pl_r1.b73.top (fun ν h => by rw [oa353]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br353_357 cnt353_357 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b73.parts PRE_pl_r1.b73.args_ok PRE_pl_r1.b73.sym PRE_pl_r1.b73.mlx PRE_pl_r1.b73.pay (by decide) PRE_pl_r1.b73.decode PRE_pl_r1.b73.pre PRE_pl_r1.b73.runS (fun ν h => by rw [oa357]; exact good_drop _ (hg ν h)) PRE_pl_r1.b73.inactive PRE_pl_r1.b73.bridge cnt357_358 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted358 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run358 PRE_pl_r1.run359) PRE_pl_r1.run360) PRE_pl_r1.run361) PRE_pl_r1.accepted362 live362 PRE_pl_r1.b74.step PRE_pl_r1.b74.top (fun ν h => by rw [oa358]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br358_363 cnt358_363 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b74.parts PRE_pl_r1.b74.args_ok PRE_pl_r1.b74.sym PRE_pl_r1.b74.mlx PRE_pl_r1.b74.pay (by decide) PRE_pl_r1.b74.decode PRE_pl_r1.b74.pre PRE_pl_r1.b74.runS (fun ν h => by rw [oa363]; exact good_drop _ (hg ν h)) PRE_pl_r1.b74.inactive PRE_pl_r1.b74.bridge cnt363_364 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted364 PRE_pl_r1.run364 PRE_pl_r1.accepted365 live365 PRE_pl_r1.b75.step PRE_pl_r1.b75.top (fun ν h => by rw [oa364]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br364_366 cnt364_366 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b75.parts PRE_pl_r1.b75.args_ok PRE_pl_r1.b75.sym PRE_pl_r1.b75.mlx PRE_pl_r1.b75.pay (by decide) PRE_pl_r1.b75.decode PRE_pl_r1.b75.pre PRE_pl_r1.b75.runS (fun ν h => by rw [oa366]; exact good_drop _ (hg ν h)) PRE_pl_r1.b75.inactive PRE_pl_r1.b75.bridge cnt366_367 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted367 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run367 PRE_pl_r1.run368) PRE_pl_r1.run369) PRE_pl_r1.accepted370 live370 PRE_pl_r1.b76.step PRE_pl_r1.b76.top (fun ν h => by rw [oa367]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br367_371 cnt367_371 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b76.parts PRE_pl_r1.b76.args_ok PRE_pl_r1.b76.sym PRE_pl_r1.b76.mlx PRE_pl_r1.b76.pay (by decide) PRE_pl_r1.b76.decode PRE_pl_r1.b76.pre PRE_pl_r1.b76.runS (fun ν h => by rw [oa371]; exact good_drop _ (hg ν h)) PRE_pl_r1.b76.inactive PRE_pl_r1.b76.bridge cnt371_372 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted372 PRE_pl_r1.run372 PRE_pl_r1.accepted373 live373 PRE_pl_r1.b77.step PRE_pl_r1.b77.top (fun ν h => by rw [oa372]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br372_374 cnt372_374 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b77.parts PRE_pl_r1.b77.args_ok PRE_pl_r1.b77.sym PRE_pl_r1.b77.mlx PRE_pl_r1.b77.pay (by decide) PRE_pl_r1.b77.decode PRE_pl_r1.b77.pre PRE_pl_r1.b77.runS (fun ν h => by rw [oa374]; exact good_drop _ (hg ν h)) PRE_pl_r1.b77.inactive PRE_pl_r1.b77.bridge cnt374_375 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted375 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run375 PRE_pl_r1.run376) PRE_pl_r1.run377) PRE_pl_r1.run378) PRE_pl_r1.accepted379 live379 PRE_pl_r1.b78.step PRE_pl_r1.b78.top (fun ν h => by rw [oa375]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br375_380 cnt375_380 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b78.parts PRE_pl_r1.b78.args_ok PRE_pl_r1.b78.sym PRE_pl_r1.b78.mlx PRE_pl_r1.b78.pay (by decide) PRE_pl_r1.b78.decode PRE_pl_r1.b78.pre PRE_pl_r1.b78.runS (fun ν h => by rw [oa380]; exact good_drop _ (hg ν h)) PRE_pl_r1.b78.inactive PRE_pl_r1.b78.bridge cnt380_381 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted381 PRE_pl_r1.run381 PRE_pl_r1.accepted382 live382 PRE_pl_r1.b79.step PRE_pl_r1.b79.top (fun ν h => by rw [oa381]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br381_383 cnt381_383 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b79.parts PRE_pl_r1.b79.args_ok PRE_pl_r1.b79.sym PRE_pl_r1.b79.mlx PRE_pl_r1.b79.pay (by decide) PRE_pl_r1.b79.decode PRE_pl_r1.b79.pre PRE_pl_r1.b79.runS (fun ν h => by rw [oa383]; exact good_drop _ (hg ν h)) PRE_pl_r1.b79.inactive PRE_pl_r1.b79.bridge cnt383_384 hT)

end Host.Ts.Sim.Compose.Post.PL.R1
