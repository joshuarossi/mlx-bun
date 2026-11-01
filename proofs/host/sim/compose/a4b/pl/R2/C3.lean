import host.sim.compose.PostChain
import host.sim.template.a4pre_pl_r2.Good
import host.sim.template.a4pre_pl_r2.K238
import host.sim.template.a4pre_pl_r2.Accept3
import host.sim.template.a4pre_pl_r2.Size48
import host.sim.template.a4pre_pl_r2.H7
import host.sim.template.a4pre_pl_r2.K241
import host.sim.template.a4pre_pl_r2.K242
import host.sim.template.a4pre_pl_r2.K243
import host.sim.template.a4pre_pl_r2.K244
import host.sim.template.a4pre_pl_r2.Size49
import host.sim.template.a4pre_pl_r2.K247
import host.sim.template.a4pre_pl_r2.Size50
import host.sim.template.a4pre_pl_r2.K250
import host.sim.template.a4pre_pl_r2.K251
import host.sim.template.a4pre_pl_r2.K252
import host.sim.template.a4pre_pl_r2.Accept4
import host.sim.template.a4pre_pl_r2.Size51
import host.sim.template.a4pre_pl_r2.K255
import host.sim.template.a4pre_pl_r2.Size52
import host.sim.template.a4pre_pl_r2.H8
import host.sim.template.a4pre_pl_r2.K258
import host.sim.template.a4pre_pl_r2.K259
import host.sim.template.a4pre_pl_r2.K260
import host.sim.template.a4pre_pl_r2.K261
import host.sim.template.a4pre_pl_r2.Size53
import host.sim.template.a4pre_pl_r2.K264
import host.sim.template.a4pre_pl_r2.Size54
import host.sim.template.a4pre_pl_r2.K267
import host.sim.template.a4pre_pl_r2.K268
import host.sim.template.a4pre_pl_r2.K269
import host.sim.template.a4pre_pl_r2.K270
import host.sim.template.a4pre_pl_r2.K271
import host.sim.template.a4pre_pl_r2.K272
import host.sim.template.a4pre_pl_r2.K273
import host.sim.template.a4pre_pl_r2.Size55
import host.sim.template.a4pre_pl_r2.K276
import host.sim.template.a4pre_pl_r2.K277
import host.sim.template.a4pre_pl_r2.K278
import host.sim.template.a4pre_pl_r2.Size56
import host.sim.template.a4pre_pl_r2.K281
import host.sim.template.a4pre_pl_r2.Size57
import host.sim.template.a4pre_pl_r2.K284
import host.sim.template.a4pre_pl_r2.K285
import host.sim.template.a4pre_pl_r2.K286
import host.sim.template.a4pre_pl_r2.K287
import host.sim.template.a4pre_pl_r2.Size58
import host.sim.template.a4pre_pl_r2.H9
import host.sim.template.a4pre_pl_r2.K290
import host.sim.template.a4pre_pl_r2.Size59
import host.sim.template.a4pre_pl_r2.K293
import host.sim.template.a4pre_pl_r2.K294
import host.sim.template.a4pre_pl_r2.K295
import host.sim.template.a4pre_pl_r2.Size60
import host.sim.template.a4pre_pl_r2.K298
import host.sim.template.a4pre_pl_r2.Size61
import host.sim.template.a4pre_pl_r2.K301
import host.sim.template.a4pre_pl_r2.K302
import host.sim.template.a4pre_pl_r2.K303
import host.sim.template.a4pre_pl_r2.K304
import host.sim.template.a4pre_pl_r2.Size62
import host.sim.template.a4pre_pl_r2.K307
import host.sim.template.a4pre_pl_r2.Size63
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.R2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl oa238 : PRE_pl_r2.S238.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S238.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live239 : isHalt PRE_pl_r2.s239.ctl = false
kernel_rfl br238_240 : bridgeOf PRE_pl_r2.s240.ffi = bridgeOf PRE_pl_r2.s238.ffi
kernel_rfl cnt238_240 : countersOkB PRE_pl_r2.s238 PRE_pl_r2.s240 = true
kernel_rfl oa240 : PRE_pl_r2.S240.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S240.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt240_241 : countersOkB PRE_pl_r2.s240 PRE_pl_r2.s241 = true
kernel_rfl oa241 : PRE_pl_r2.S241.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S241.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live245 : isHalt PRE_pl_r2.s245.ctl = false
kernel_rfl br241_246 : bridgeOf PRE_pl_r2.s246.ffi = bridgeOf PRE_pl_r2.s241.ffi
kernel_rfl cnt241_246 : countersOkB PRE_pl_r2.s241 PRE_pl_r2.s246 = true
kernel_rfl oa246 : PRE_pl_r2.S246.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S246.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt246_247 : countersOkB PRE_pl_r2.s246 PRE_pl_r2.s247 = true
kernel_rfl oa247 : PRE_pl_r2.S247.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S247.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live248 : isHalt PRE_pl_r2.s248.ctl = false
kernel_rfl br247_249 : bridgeOf PRE_pl_r2.s249.ffi = bridgeOf PRE_pl_r2.s247.ffi
kernel_rfl cnt247_249 : countersOkB PRE_pl_r2.s247 PRE_pl_r2.s249 = true
kernel_rfl oa249 : PRE_pl_r2.S249.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S249.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt249_250 : countersOkB PRE_pl_r2.s249 PRE_pl_r2.s250 = true
kernel_rfl oa250 : PRE_pl_r2.S250.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S250.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live253 : isHalt PRE_pl_r2.s253.ctl = false
kernel_rfl br250_254 : bridgeOf PRE_pl_r2.s254.ffi = bridgeOf PRE_pl_r2.s250.ffi
kernel_rfl cnt250_254 : countersOkB PRE_pl_r2.s250 PRE_pl_r2.s254 = true
kernel_rfl oa254 : PRE_pl_r2.S254.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S254.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt254_255 : countersOkB PRE_pl_r2.s254 PRE_pl_r2.s255 = true
kernel_rfl oa255 : PRE_pl_r2.S255.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S255.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live256 : isHalt PRE_pl_r2.s256.ctl = false
kernel_rfl br255_257 : bridgeOf PRE_pl_r2.s257.ffi = bridgeOf PRE_pl_r2.s255.ffi
kernel_rfl cnt255_257 : countersOkB PRE_pl_r2.s255 PRE_pl_r2.s257 = true
kernel_rfl oa257 : PRE_pl_r2.S257.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S257.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt257_258 : countersOkB PRE_pl_r2.s257 PRE_pl_r2.s258 = true
kernel_rfl oa258 : PRE_pl_r2.S258.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S258.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live262 : isHalt PRE_pl_r2.s262.ctl = false
kernel_rfl br258_263 : bridgeOf PRE_pl_r2.s263.ffi = bridgeOf PRE_pl_r2.s258.ffi
kernel_rfl cnt258_263 : countersOkB PRE_pl_r2.s258 PRE_pl_r2.s263 = true
kernel_rfl oa263 : PRE_pl_r2.S263.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S263.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt263_264 : countersOkB PRE_pl_r2.s263 PRE_pl_r2.s264 = true
kernel_rfl oa264 : PRE_pl_r2.S264.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S264.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live265 : isHalt PRE_pl_r2.s265.ctl = false
kernel_rfl br264_266 : bridgeOf PRE_pl_r2.s266.ffi = bridgeOf PRE_pl_r2.s264.ffi
kernel_rfl cnt264_266 : countersOkB PRE_pl_r2.s264 PRE_pl_r2.s266 = true
kernel_rfl oa266 : PRE_pl_r2.S266.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S266.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt266_267 : countersOkB PRE_pl_r2.s266 PRE_pl_r2.s267 = true
kernel_rfl oa267 : PRE_pl_r2.S267.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S267.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live274 : isHalt PRE_pl_r2.s274.ctl = false
kernel_rfl br267_275 : bridgeOf PRE_pl_r2.s275.ffi = bridgeOf PRE_pl_r2.s267.ffi
kernel_rfl cnt267_275 : countersOkB PRE_pl_r2.s267 PRE_pl_r2.s275 = true
kernel_rfl oa275 : PRE_pl_r2.S275.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S275.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt275_276 : countersOkB PRE_pl_r2.s275 PRE_pl_r2.s276 = true
kernel_rfl oa276 : PRE_pl_r2.S276.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S276.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live279 : isHalt PRE_pl_r2.s279.ctl = false
kernel_rfl br276_280 : bridgeOf PRE_pl_r2.s280.ffi = bridgeOf PRE_pl_r2.s276.ffi
kernel_rfl cnt276_280 : countersOkB PRE_pl_r2.s276 PRE_pl_r2.s280 = true
kernel_rfl oa280 : PRE_pl_r2.S280.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S280.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt280_281 : countersOkB PRE_pl_r2.s280 PRE_pl_r2.s281 = true
kernel_rfl oa281 : PRE_pl_r2.S281.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S281.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live282 : isHalt PRE_pl_r2.s282.ctl = false
kernel_rfl br281_283 : bridgeOf PRE_pl_r2.s283.ffi = bridgeOf PRE_pl_r2.s281.ffi
kernel_rfl cnt281_283 : countersOkB PRE_pl_r2.s281 PRE_pl_r2.s283 = true
kernel_rfl oa283 : PRE_pl_r2.S283.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S283.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt283_284 : countersOkB PRE_pl_r2.s283 PRE_pl_r2.s284 = true
kernel_rfl oa284 : PRE_pl_r2.S284.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S284.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live288 : isHalt PRE_pl_r2.s288.ctl = false
kernel_rfl br284_289 : bridgeOf PRE_pl_r2.s289.ffi = bridgeOf PRE_pl_r2.s284.ffi
kernel_rfl cnt284_289 : countersOkB PRE_pl_r2.s284 PRE_pl_r2.s289 = true
kernel_rfl oa289 : PRE_pl_r2.S289.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S289.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt289_290 : countersOkB PRE_pl_r2.s289 PRE_pl_r2.s290 = true
kernel_rfl oa290 : PRE_pl_r2.S290.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S290.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live291 : isHalt PRE_pl_r2.s291.ctl = false
kernel_rfl br290_292 : bridgeOf PRE_pl_r2.s292.ffi = bridgeOf PRE_pl_r2.s290.ffi
kernel_rfl cnt290_292 : countersOkB PRE_pl_r2.s290 PRE_pl_r2.s292 = true
kernel_rfl oa292 : PRE_pl_r2.S292.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S292.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt292_293 : countersOkB PRE_pl_r2.s292 PRE_pl_r2.s293 = true
kernel_rfl oa293 : PRE_pl_r2.S293.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S293.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live296 : isHalt PRE_pl_r2.s296.ctl = false
kernel_rfl br293_297 : bridgeOf PRE_pl_r2.s297.ffi = bridgeOf PRE_pl_r2.s293.ffi
kernel_rfl cnt293_297 : countersOkB PRE_pl_r2.s293 PRE_pl_r2.s297 = true
kernel_rfl oa297 : PRE_pl_r2.S297.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S297.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt297_298 : countersOkB PRE_pl_r2.s297 PRE_pl_r2.s298 = true
kernel_rfl oa298 : PRE_pl_r2.S298.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S298.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live299 : isHalt PRE_pl_r2.s299.ctl = false
kernel_rfl br298_300 : bridgeOf PRE_pl_r2.s300.ffi = bridgeOf PRE_pl_r2.s298.ffi
kernel_rfl cnt298_300 : countersOkB PRE_pl_r2.s298 PRE_pl_r2.s300 = true
kernel_rfl oa300 : PRE_pl_r2.S300.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S300.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt300_301 : countersOkB PRE_pl_r2.s300 PRE_pl_r2.s301 = true
kernel_rfl oa301 : PRE_pl_r2.S301.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S301.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live305 : isHalt PRE_pl_r2.s305.ctl = false
kernel_rfl br301_306 : bridgeOf PRE_pl_r2.s306.ffi = bridgeOf PRE_pl_r2.s301.ffi
kernel_rfl cnt301_306 : countersOkB PRE_pl_r2.s301 PRE_pl_r2.s306 = true
kernel_rfl oa306 : PRE_pl_r2.S306.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S306.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt306_307 : countersOkB PRE_pl_r2.s306 PRE_pl_r2.s307 = true
kernel_rfl oa307 : PRE_pl_r2.S307.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S307.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl live308 : isHalt PRE_pl_r2.s308.ctl = false
kernel_rfl br307_309 : bridgeOf PRE_pl_r2.s309.ffi = bridgeOf PRE_pl_r2.s307.ffi
kernel_rfl cnt307_309 : countersOkB PRE_pl_r2.s307 PRE_pl_r2.s309 = true
kernel_rfl oa309 : PRE_pl_r2.S309.oracle = List.drop (PRE_pl_r2.S0.oracle.length - PRE_pl_r2.S309.oracle.length) PRE_pl_r2.S0.oracle
kernel_rfl cnt309_310 : countersOkB PRE_pl_r2.s309 PRE_pl_r2.s310 = true

abbrev n3 : Nat := ((((((((((((((((((((((((((((((((((nth? PRE_pl_r2.ks 238).getD 0) + 1) + 3) + ((((((nth? PRE_pl_r2.ks 241).getD 0) + ((nth? PRE_pl_r2.ks 242).getD 0)) + ((nth? PRE_pl_r2.ks 243).getD 0)) + ((nth? PRE_pl_r2.ks 244).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 247).getD 0) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 250).getD 0) + ((nth? PRE_pl_r2.ks 251).getD 0)) + ((nth? PRE_pl_r2.ks 252).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 255).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r2.ks 258).getD 0) + ((nth? PRE_pl_r2.ks 259).getD 0)) + ((nth? PRE_pl_r2.ks 260).getD 0)) + ((nth? PRE_pl_r2.ks 261).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 264).getD 0) + 1)) + 3) + (((((((((nth? PRE_pl_r2.ks 267).getD 0) + ((nth? PRE_pl_r2.ks 268).getD 0)) + ((nth? PRE_pl_r2.ks 269).getD 0)) + ((nth? PRE_pl_r2.ks 270).getD 0)) + ((nth? PRE_pl_r2.ks 271).getD 0)) + ((nth? PRE_pl_r2.ks 272).getD 0)) + ((nth? PRE_pl_r2.ks 273).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 276).getD 0) + ((nth? PRE_pl_r2.ks 277).getD 0)) + ((nth? PRE_pl_r2.ks 278).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 281).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r2.ks 284).getD 0) + ((nth? PRE_pl_r2.ks 285).getD 0)) + ((nth? PRE_pl_r2.ks 286).getD 0)) + ((nth? PRE_pl_r2.ks 287).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 290).getD 0) + 1)) + 3) + (((((nth? PRE_pl_r2.ks 293).getD 0) + ((nth? PRE_pl_r2.ks 294).getD 0)) + ((nth? PRE_pl_r2.ks 295).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 298).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r2.ks 301).getD 0) + ((nth? PRE_pl_r2.ks 302).getD 0)) + ((nth? PRE_pl_r2.ks 303).getD 0)) + ((nth? PRE_pl_r2.ks 304).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r2.ks 307).getD 0) + 1)) + 3)

theorem c3 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_r2.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r2.s238 PRE_pl_r2.S238)) (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r2.s310 PRE_pl_r2.S310)) n3 :=
  ((((((((((((((((((((((((((((((((callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted238 PRE_pl_r2.run238 PRE_pl_r2.accepted239 live239 PRE_pl_r2.b48.step PRE_pl_r2.b48.top (fun ν h => by rw [oa238]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br238_240 cnt238_240 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b48.parts PRE_pl_r2.b48.args_ok PRE_pl_r2.b48.sym PRE_pl_r2.b48.mlx PRE_pl_r2.b48.pay (by decide) PRE_pl_r2.b48.decode PRE_pl_r2.b48.pre PRE_pl_r2.b48.runS (fun ν h => by rw [oa240]; exact good_drop _ (hg ν h)) PRE_pl_r2.b48.inactive PRE_pl_r2.b48.bridge cnt240_241 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted241 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run241 PRE_pl_r2.run242) PRE_pl_r2.run243) PRE_pl_r2.run244) PRE_pl_r2.accepted245 live245 PRE_pl_r2.b49.step PRE_pl_r2.b49.top (fun ν h => by rw [oa241]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br241_246 cnt241_246 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b49.parts PRE_pl_r2.b49.args_ok PRE_pl_r2.b49.sym PRE_pl_r2.b49.mlx PRE_pl_r2.b49.pay (by decide) PRE_pl_r2.b49.decode PRE_pl_r2.b49.pre PRE_pl_r2.b49.runS (fun ν h => by rw [oa246]; exact good_drop _ (hg ν h)) PRE_pl_r2.b49.inactive PRE_pl_r2.b49.bridge cnt246_247 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted247 PRE_pl_r2.run247 PRE_pl_r2.accepted248 live248 PRE_pl_r2.b50.step PRE_pl_r2.b50.top (fun ν h => by rw [oa247]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br247_249 cnt247_249 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b50.parts PRE_pl_r2.b50.args_ok PRE_pl_r2.b50.sym PRE_pl_r2.b50.mlx PRE_pl_r2.b50.pay (by decide) PRE_pl_r2.b50.decode PRE_pl_r2.b50.pre PRE_pl_r2.b50.runS (fun ν h => by rw [oa249]; exact good_drop _ (hg ν h)) PRE_pl_r2.b50.inactive PRE_pl_r2.b50.bridge cnt249_250 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted250 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run250 PRE_pl_r2.run251) PRE_pl_r2.run252) PRE_pl_r2.accepted253 live253 PRE_pl_r2.b51.step PRE_pl_r2.b51.top (fun ν h => by rw [oa250]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br250_254 cnt250_254 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b51.parts PRE_pl_r2.b51.args_ok PRE_pl_r2.b51.sym PRE_pl_r2.b51.mlx PRE_pl_r2.b51.pay (by decide) PRE_pl_r2.b51.decode PRE_pl_r2.b51.pre PRE_pl_r2.b51.runS (fun ν h => by rw [oa254]; exact good_drop _ (hg ν h)) PRE_pl_r2.b51.inactive PRE_pl_r2.b51.bridge cnt254_255 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted255 PRE_pl_r2.run255 PRE_pl_r2.accepted256 live256 PRE_pl_r2.b52.step PRE_pl_r2.b52.top (fun ν h => by rw [oa255]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br255_257 cnt255_257 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b52.parts PRE_pl_r2.b52.args_ok PRE_pl_r2.b52.sym PRE_pl_r2.b52.mlx PRE_pl_r2.b52.pay (by decide) PRE_pl_r2.b52.decode PRE_pl_r2.b52.pre PRE_pl_r2.b52.runS (fun ν h => by rw [oa257]; exact good_drop _ (hg ν h)) PRE_pl_r2.b52.inactive PRE_pl_r2.b52.bridge cnt257_258 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted258 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run258 PRE_pl_r2.run259) PRE_pl_r2.run260) PRE_pl_r2.run261) PRE_pl_r2.accepted262 live262 PRE_pl_r2.b53.step PRE_pl_r2.b53.top (fun ν h => by rw [oa258]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br258_263 cnt258_263 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b53.parts PRE_pl_r2.b53.args_ok PRE_pl_r2.b53.sym PRE_pl_r2.b53.mlx PRE_pl_r2.b53.pay (by decide) PRE_pl_r2.b53.decode PRE_pl_r2.b53.pre PRE_pl_r2.b53.runS (fun ν h => by rw [oa263]; exact good_drop _ (hg ν h)) PRE_pl_r2.b53.inactive PRE_pl_r2.b53.bridge cnt263_264 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted264 PRE_pl_r2.run264 PRE_pl_r2.accepted265 live265 PRE_pl_r2.b54.step PRE_pl_r2.b54.top (fun ν h => by rw [oa264]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br264_266 cnt264_266 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b54.parts PRE_pl_r2.b54.args_ok PRE_pl_r2.b54.sym PRE_pl_r2.b54.mlx PRE_pl_r2.b54.pay (by decide) PRE_pl_r2.b54.decode PRE_pl_r2.b54.pre PRE_pl_r2.b54.runS (fun ν h => by rw [oa266]; exact good_drop _ (hg ν h)) PRE_pl_r2.b54.inactive PRE_pl_r2.b54.bridge cnt266_267 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted267 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run267 PRE_pl_r2.run268) PRE_pl_r2.run269) PRE_pl_r2.run270) PRE_pl_r2.run271) PRE_pl_r2.run272) PRE_pl_r2.run273) PRE_pl_r2.accepted274 live274 PRE_pl_r2.b55.step PRE_pl_r2.b55.top (fun ν h => by rw [oa267]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br267_275 cnt267_275 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b55.parts PRE_pl_r2.b55.args_ok PRE_pl_r2.b55.sym PRE_pl_r2.b55.mlx PRE_pl_r2.b55.pay (by decide) PRE_pl_r2.b55.decode PRE_pl_r2.b55.pre PRE_pl_r2.b55.runS (fun ν h => by rw [oa275]; exact good_drop _ (hg ν h)) PRE_pl_r2.b55.inactive PRE_pl_r2.b55.bridge cnt275_276 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted276 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run276 PRE_pl_r2.run277) PRE_pl_r2.run278) PRE_pl_r2.accepted279 live279 PRE_pl_r2.b56.step PRE_pl_r2.b56.top (fun ν h => by rw [oa276]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br276_280 cnt276_280 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b56.parts PRE_pl_r2.b56.args_ok PRE_pl_r2.b56.sym PRE_pl_r2.b56.mlx PRE_pl_r2.b56.pay (by decide) PRE_pl_r2.b56.decode PRE_pl_r2.b56.pre PRE_pl_r2.b56.runS (fun ν h => by rw [oa280]; exact good_drop _ (hg ν h)) PRE_pl_r2.b56.inactive PRE_pl_r2.b56.bridge cnt280_281 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted281 PRE_pl_r2.run281 PRE_pl_r2.accepted282 live282 PRE_pl_r2.b57.step PRE_pl_r2.b57.top (fun ν h => by rw [oa281]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br281_283 cnt281_283 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b57.parts PRE_pl_r2.b57.args_ok PRE_pl_r2.b57.sym PRE_pl_r2.b57.mlx PRE_pl_r2.b57.pay (by decide) PRE_pl_r2.b57.decode PRE_pl_r2.b57.pre PRE_pl_r2.b57.runS (fun ν h => by rw [oa283]; exact good_drop _ (hg ν h)) PRE_pl_r2.b57.inactive PRE_pl_r2.b57.bridge cnt283_284 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted284 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run284 PRE_pl_r2.run285) PRE_pl_r2.run286) PRE_pl_r2.run287) PRE_pl_r2.accepted288 live288 PRE_pl_r2.b58.step PRE_pl_r2.b58.top (fun ν h => by rw [oa284]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br284_289 cnt284_289 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b58.parts PRE_pl_r2.b58.args_ok PRE_pl_r2.b58.sym PRE_pl_r2.b58.mlx PRE_pl_r2.b58.pay (by decide) PRE_pl_r2.b58.decode PRE_pl_r2.b58.pre PRE_pl_r2.b58.runS (fun ν h => by rw [oa289]; exact good_drop _ (hg ν h)) PRE_pl_r2.b58.inactive PRE_pl_r2.b58.bridge cnt289_290 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted290 PRE_pl_r2.run290 PRE_pl_r2.accepted291 live291 PRE_pl_r2.b59.step PRE_pl_r2.b59.top (fun ν h => by rw [oa290]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br290_292 cnt290_292 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b59.parts PRE_pl_r2.b59.args_ok PRE_pl_r2.b59.sym PRE_pl_r2.b59.mlx PRE_pl_r2.b59.pay (by decide) PRE_pl_r2.b59.decode PRE_pl_r2.b59.pre PRE_pl_r2.b59.runS (fun ν h => by rw [oa292]; exact good_drop _ (hg ν h)) PRE_pl_r2.b59.inactive PRE_pl_r2.b59.bridge cnt292_293 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted293 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run293 PRE_pl_r2.run294) PRE_pl_r2.run295) PRE_pl_r2.accepted296 live296 PRE_pl_r2.b60.step PRE_pl_r2.b60.top (fun ν h => by rw [oa293]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br293_297 cnt293_297 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b60.parts PRE_pl_r2.b60.args_ok PRE_pl_r2.b60.sym PRE_pl_r2.b60.mlx PRE_pl_r2.b60.pay (by decide) PRE_pl_r2.b60.decode PRE_pl_r2.b60.pre PRE_pl_r2.b60.runS (fun ν h => by rw [oa297]; exact good_drop _ (hg ν h)) PRE_pl_r2.b60.inactive PRE_pl_r2.b60.bridge cnt297_298 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted298 PRE_pl_r2.run298 PRE_pl_r2.accepted299 live299 PRE_pl_r2.b61.step PRE_pl_r2.b61.top (fun ν h => by rw [oa298]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br298_300 cnt298_300 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b61.parts PRE_pl_r2.b61.args_ok PRE_pl_r2.b61.sym PRE_pl_r2.b61.mlx PRE_pl_r2.b61.pay (by decide) PRE_pl_r2.b61.decode PRE_pl_r2.b61.pre PRE_pl_r2.b61.runS (fun ν h => by rw [oa300]; exact good_drop _ (hg ν h)) PRE_pl_r2.b61.inactive PRE_pl_r2.b61.bridge cnt300_301 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted301 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r2.run301 PRE_pl_r2.run302) PRE_pl_r2.run303) PRE_pl_r2.run304) PRE_pl_r2.accepted305 live305 PRE_pl_r2.b62.step PRE_pl_r2.b62.top (fun ν h => by rw [oa301]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br301_306 cnt301_306 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b62.parts PRE_pl_r2.b62.args_ok PRE_pl_r2.b62.sym PRE_pl_r2.b62.mlx PRE_pl_r2.b62.pay (by decide) PRE_pl_r2.b62.decode PRE_pl_r2.b62.pre PRE_pl_r2.b62.runS (fun ν h => by rw [oa306]; exact good_drop _ (hg ν h)) PRE_pl_r2.b62.inactive PRE_pl_r2.b62.bridge cnt306_307 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r2.accepted307 PRE_pl_r2.run307 PRE_pl_r2.accepted308 live308 PRE_pl_r2.b63.step PRE_pl_r2.b63.top (fun ν h => by rw [oa307]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br307_309 cnt307_309 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r2.b63.parts PRE_pl_r2.b63.args_ok PRE_pl_r2.b63.sym PRE_pl_r2.b63.mlx PRE_pl_r2.b63.pay (by decide) PRE_pl_r2.b63.decode PRE_pl_r2.b63.pre PRE_pl_r2.b63.runS (fun ν h => by rw [oa309]; exact good_drop _ (hg ν h)) PRE_pl_r2.b63.inactive PRE_pl_r2.b63.bridge cnt309_310 hT)

end Host.Ts.Sim.Compose.Post.PL.R2
