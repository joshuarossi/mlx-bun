import host.sim.compose.PostPath
import host.sim.template.a4pre_pl_ta.m.B11
import host.sim.template.a4pre_pl_ta.m.B02
import host.sim.template.a4pre_pl_ta.m.B12
import host.sim.template.a4pre_pl_ta.H7
import host.sim.template.a4pre_pl_ta.m.B03
import host.sim.template.a4pre_pl_ta.H8
import host.sim.template.a4pre_pl_ta.H9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.Ta
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl oa238 : PRE_pl_ta.S238.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S238.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live239 : isHalt PRE_pl_ta.s239.ctl = false
kernel_rfl br238_240 : bridgeOf PRE_pl_ta.s240.ffi = bridgeOf PRE_pl_ta.s238.ffi
kernel_rfl cnt238_240 : countersOkB PRE_pl_ta.s238 PRE_pl_ta.s240 = true
kernel_rfl oa240 : PRE_pl_ta.S240.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S240.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt240_241 : countersOkB PRE_pl_ta.s240 PRE_pl_ta.s241 = true
kernel_rfl oa241 : PRE_pl_ta.S241.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S241.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live245 : isHalt PRE_pl_ta.s245.ctl = false
kernel_rfl br241_246 : bridgeOf PRE_pl_ta.s246.ffi = bridgeOf PRE_pl_ta.s241.ffi
kernel_rfl cnt241_246 : countersOkB PRE_pl_ta.s241 PRE_pl_ta.s246 = true
kernel_rfl oa246 : PRE_pl_ta.S246.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S246.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt246_247 : countersOkB PRE_pl_ta.s246 PRE_pl_ta.s247 = true
kernel_rfl oa247 : PRE_pl_ta.S247.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S247.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live248 : isHalt PRE_pl_ta.s248.ctl = false
kernel_rfl br247_249 : bridgeOf PRE_pl_ta.s249.ffi = bridgeOf PRE_pl_ta.s247.ffi
kernel_rfl cnt247_249 : countersOkB PRE_pl_ta.s247 PRE_pl_ta.s249 = true
kernel_rfl oa249 : PRE_pl_ta.S249.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S249.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt249_250 : countersOkB PRE_pl_ta.s249 PRE_pl_ta.s250 = true
kernel_rfl oa250 : PRE_pl_ta.S250.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S250.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live253 : isHalt PRE_pl_ta.s253.ctl = false
kernel_rfl br250_254 : bridgeOf PRE_pl_ta.s254.ffi = bridgeOf PRE_pl_ta.s250.ffi
kernel_rfl cnt250_254 : countersOkB PRE_pl_ta.s250 PRE_pl_ta.s254 = true
kernel_rfl oa254 : PRE_pl_ta.S254.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S254.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt254_255 : countersOkB PRE_pl_ta.s254 PRE_pl_ta.s255 = true
kernel_rfl oa255 : PRE_pl_ta.S255.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S255.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live256 : isHalt PRE_pl_ta.s256.ctl = false
kernel_rfl br255_257 : bridgeOf PRE_pl_ta.s257.ffi = bridgeOf PRE_pl_ta.s255.ffi
kernel_rfl cnt255_257 : countersOkB PRE_pl_ta.s255 PRE_pl_ta.s257 = true
kernel_rfl oa257 : PRE_pl_ta.S257.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S257.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt257_258 : countersOkB PRE_pl_ta.s257 PRE_pl_ta.s258 = true
kernel_rfl oa258 : PRE_pl_ta.S258.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S258.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live262 : isHalt PRE_pl_ta.s262.ctl = false
kernel_rfl br258_263 : bridgeOf PRE_pl_ta.s263.ffi = bridgeOf PRE_pl_ta.s258.ffi
kernel_rfl cnt258_263 : countersOkB PRE_pl_ta.s258 PRE_pl_ta.s263 = true
kernel_rfl oa263 : PRE_pl_ta.S263.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S263.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt263_264 : countersOkB PRE_pl_ta.s263 PRE_pl_ta.s264 = true
kernel_rfl oa264 : PRE_pl_ta.S264.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S264.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live265 : isHalt PRE_pl_ta.s265.ctl = false
kernel_rfl br264_266 : bridgeOf PRE_pl_ta.s266.ffi = bridgeOf PRE_pl_ta.s264.ffi
kernel_rfl cnt264_266 : countersOkB PRE_pl_ta.s264 PRE_pl_ta.s266 = true
kernel_rfl oa266 : PRE_pl_ta.S266.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S266.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt266_267 : countersOkB PRE_pl_ta.s266 PRE_pl_ta.s267 = true
kernel_rfl oa267 : PRE_pl_ta.S267.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S267.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live274 : isHalt PRE_pl_ta.s274.ctl = false
kernel_rfl br267_275 : bridgeOf PRE_pl_ta.s275.ffi = bridgeOf PRE_pl_ta.s267.ffi
kernel_rfl cnt267_275 : countersOkB PRE_pl_ta.s267 PRE_pl_ta.s275 = true
kernel_rfl oa275 : PRE_pl_ta.S275.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S275.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt275_276 : countersOkB PRE_pl_ta.s275 PRE_pl_ta.s276 = true
kernel_rfl oa276 : PRE_pl_ta.S276.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S276.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live279 : isHalt PRE_pl_ta.s279.ctl = false
kernel_rfl br276_280 : bridgeOf PRE_pl_ta.s280.ffi = bridgeOf PRE_pl_ta.s276.ffi
kernel_rfl cnt276_280 : countersOkB PRE_pl_ta.s276 PRE_pl_ta.s280 = true
kernel_rfl oa280 : PRE_pl_ta.S280.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S280.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt280_281 : countersOkB PRE_pl_ta.s280 PRE_pl_ta.s281 = true
kernel_rfl oa281 : PRE_pl_ta.S281.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S281.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live282 : isHalt PRE_pl_ta.s282.ctl = false
kernel_rfl br281_283 : bridgeOf PRE_pl_ta.s283.ffi = bridgeOf PRE_pl_ta.s281.ffi
kernel_rfl cnt281_283 : countersOkB PRE_pl_ta.s281 PRE_pl_ta.s283 = true
kernel_rfl oa283 : PRE_pl_ta.S283.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S283.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt283_284 : countersOkB PRE_pl_ta.s283 PRE_pl_ta.s284 = true
kernel_rfl oa284 : PRE_pl_ta.S284.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S284.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live288 : isHalt PRE_pl_ta.s288.ctl = false
kernel_rfl br284_289 : bridgeOf PRE_pl_ta.s289.ffi = bridgeOf PRE_pl_ta.s284.ffi
kernel_rfl cnt284_289 : countersOkB PRE_pl_ta.s284 PRE_pl_ta.s289 = true
kernel_rfl oa289 : PRE_pl_ta.S289.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S289.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt289_290 : countersOkB PRE_pl_ta.s289 PRE_pl_ta.s290 = true
kernel_rfl oa290 : PRE_pl_ta.S290.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S290.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live291 : isHalt PRE_pl_ta.s291.ctl = false
kernel_rfl br290_292 : bridgeOf PRE_pl_ta.s292.ffi = bridgeOf PRE_pl_ta.s290.ffi
kernel_rfl cnt290_292 : countersOkB PRE_pl_ta.s290 PRE_pl_ta.s292 = true
kernel_rfl oa292 : PRE_pl_ta.S292.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S292.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt292_293 : countersOkB PRE_pl_ta.s292 PRE_pl_ta.s293 = true
kernel_rfl oa293 : PRE_pl_ta.S293.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S293.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live296 : isHalt PRE_pl_ta.s296.ctl = false
kernel_rfl br293_297 : bridgeOf PRE_pl_ta.s297.ffi = bridgeOf PRE_pl_ta.s293.ffi
kernel_rfl cnt293_297 : countersOkB PRE_pl_ta.s293 PRE_pl_ta.s297 = true
kernel_rfl oa297 : PRE_pl_ta.S297.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S297.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt297_298 : countersOkB PRE_pl_ta.s297 PRE_pl_ta.s298 = true
kernel_rfl oa298 : PRE_pl_ta.S298.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S298.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live299 : isHalt PRE_pl_ta.s299.ctl = false
kernel_rfl br298_300 : bridgeOf PRE_pl_ta.s300.ffi = bridgeOf PRE_pl_ta.s298.ffi
kernel_rfl cnt298_300 : countersOkB PRE_pl_ta.s298 PRE_pl_ta.s300 = true
kernel_rfl oa300 : PRE_pl_ta.S300.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S300.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt300_301 : countersOkB PRE_pl_ta.s300 PRE_pl_ta.s301 = true
kernel_rfl oa301 : PRE_pl_ta.S301.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S301.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live305 : isHalt PRE_pl_ta.s305.ctl = false
kernel_rfl br301_306 : bridgeOf PRE_pl_ta.s306.ffi = bridgeOf PRE_pl_ta.s301.ffi
kernel_rfl cnt301_306 : countersOkB PRE_pl_ta.s301 PRE_pl_ta.s306 = true
kernel_rfl oa306 : PRE_pl_ta.S306.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S306.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt306_307 : countersOkB PRE_pl_ta.s306 PRE_pl_ta.s307 = true
kernel_rfl oa307 : PRE_pl_ta.S307.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S307.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live308 : isHalt PRE_pl_ta.s308.ctl = false
kernel_rfl br307_309 : bridgeOf PRE_pl_ta.s309.ffi = bridgeOf PRE_pl_ta.s307.ffi
kernel_rfl cnt307_309 : countersOkB PRE_pl_ta.s307 PRE_pl_ta.s309 = true
kernel_rfl oa309 : PRE_pl_ta.S309.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S309.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt309_310 : countersOkB PRE_pl_ta.s309 PRE_pl_ta.s310 = true

abbrev n3 : Nat := ((((((((((((((((((((((((((((((((((nth? PRE_pl_ta.ks 238).getD 0) + 1) + 3) + ((((((nth? PRE_pl_ta.ks 241).getD 0) + ((nth? PRE_pl_ta.ks 242).getD 0)) + ((nth? PRE_pl_ta.ks 243).getD 0)) + ((nth? PRE_pl_ta.ks 244).getD 0)) + 1)) + 3) + (((nth? PRE_pl_ta.ks 247).getD 0) + 1)) + 3) + (((((nth? PRE_pl_ta.ks 250).getD 0) + ((nth? PRE_pl_ta.ks 251).getD 0)) + ((nth? PRE_pl_ta.ks 252).getD 0)) + 1)) + 3) + (((nth? PRE_pl_ta.ks 255).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_ta.ks 258).getD 0) + ((nth? PRE_pl_ta.ks 259).getD 0)) + ((nth? PRE_pl_ta.ks 260).getD 0)) + ((nth? PRE_pl_ta.ks 261).getD 0)) + 1)) + 3) + (((nth? PRE_pl_ta.ks 264).getD 0) + 1)) + 3) + (((((((((nth? PRE_pl_ta.ks 267).getD 0) + ((nth? PRE_pl_ta.ks 268).getD 0)) + ((nth? PRE_pl_ta.ks 269).getD 0)) + ((nth? PRE_pl_ta.ks 270).getD 0)) + ((nth? PRE_pl_ta.ks 271).getD 0)) + ((nth? PRE_pl_ta.ks 272).getD 0)) + ((nth? PRE_pl_ta.ks 273).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_ta.ks 276).getD 0) + ((nth? PRE_pl_ta.ks 277).getD 0)) + ((nth? PRE_pl_ta.ks 278).getD 0)) + 1)) + 3) + (((nth? PRE_pl_ta.ks 281).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_ta.ks 284).getD 0) + ((nth? PRE_pl_ta.ks 285).getD 0)) + ((nth? PRE_pl_ta.ks 286).getD 0)) + ((nth? PRE_pl_ta.ks 287).getD 0)) + 1)) + 3) + (((nth? PRE_pl_ta.ks 290).getD 0) + 1)) + 3) + (((((nth? PRE_pl_ta.ks 293).getD 0) + ((nth? PRE_pl_ta.ks 294).getD 0)) + ((nth? PRE_pl_ta.ks 295).getD 0)) + 1)) + 3) + (((nth? PRE_pl_ta.ks 298).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_ta.ks 301).getD 0) + ((nth? PRE_pl_ta.ks 302).getD 0)) + ((nth? PRE_pl_ta.ks 303).getD 0)) + ((nth? PRE_pl_ta.ks 304).getD 0)) + 1)) + 3) + (((nth? PRE_pl_ta.ks 307).getD 0) + 1)) + 3)

theorem c3 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_ta.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_ta.s238 PRE_pl_ta.S238)) (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_ta.s310 PRE_pl_ta.S310)) n3 :=
  ((((((((((((((((((((((((((((((((callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted238 PRE_pl_ta.run238 PRE_pl_ta.accepted239 live239 PRE_pl_ta.b48.step PRE_pl_ta.b48.top (fun ν h => by rw [oa238]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br238_240 cnt238_240 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b48.parts PRE_pl_ta.b48.args_ok PRE_pl_ta.b48.sym PRE_pl_ta.b48.mlx PRE_pl_ta.b48.pay (by decide) PRE_pl_ta.b48.decode PRE_pl_ta.b48.pre PRE_pl_ta.b48.runS (fun ν h => by rw [oa240]; exact good_drop _ (hg ν h)) PRE_pl_ta.b48.inactive PRE_pl_ta.b48.bridge cnt240_241 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted241 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_ta.run241 PRE_pl_ta.run242) PRE_pl_ta.run243) PRE_pl_ta.run244) PRE_pl_ta.accepted245 live245 PRE_pl_ta.b49.step PRE_pl_ta.b49.top (fun ν h => by rw [oa241]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br241_246 cnt241_246 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b49.parts PRE_pl_ta.b49.args_ok PRE_pl_ta.b49.sym PRE_pl_ta.b49.mlx PRE_pl_ta.b49.pay (by decide) PRE_pl_ta.b49.decode PRE_pl_ta.b49.pre PRE_pl_ta.b49.runS (fun ν h => by rw [oa246]; exact good_drop _ (hg ν h)) PRE_pl_ta.b49.inactive PRE_pl_ta.b49.bridge cnt246_247 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted247 PRE_pl_ta.run247 PRE_pl_ta.accepted248 live248 PRE_pl_ta.b50.step PRE_pl_ta.b50.top (fun ν h => by rw [oa247]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br247_249 cnt247_249 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b50.parts PRE_pl_ta.b50.args_ok PRE_pl_ta.b50.sym PRE_pl_ta.b50.mlx PRE_pl_ta.b50.pay (by decide) PRE_pl_ta.b50.decode PRE_pl_ta.b50.pre PRE_pl_ta.b50.runS (fun ν h => by rw [oa249]; exact good_drop _ (hg ν h)) PRE_pl_ta.b50.inactive PRE_pl_ta.b50.bridge cnt249_250 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted250 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_ta.run250 PRE_pl_ta.run251) PRE_pl_ta.run252) PRE_pl_ta.accepted253 live253 PRE_pl_ta.b51.step PRE_pl_ta.b51.top (fun ν h => by rw [oa250]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br250_254 cnt250_254 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b51.parts PRE_pl_ta.b51.args_ok PRE_pl_ta.b51.sym PRE_pl_ta.b51.mlx PRE_pl_ta.b51.pay (by decide) PRE_pl_ta.b51.decode PRE_pl_ta.b51.pre PRE_pl_ta.b51.runS (fun ν h => by rw [oa254]; exact good_drop _ (hg ν h)) PRE_pl_ta.b51.inactive PRE_pl_ta.b51.bridge cnt254_255 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted255 PRE_pl_ta.run255 PRE_pl_ta.accepted256 live256 PRE_pl_ta.b52.step PRE_pl_ta.b52.top (fun ν h => by rw [oa255]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br255_257 cnt255_257 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b52.parts PRE_pl_ta.b52.args_ok PRE_pl_ta.b52.sym PRE_pl_ta.b52.mlx PRE_pl_ta.b52.pay (by decide) PRE_pl_ta.b52.decode PRE_pl_ta.b52.pre PRE_pl_ta.b52.runS (fun ν h => by rw [oa257]; exact good_drop _ (hg ν h)) PRE_pl_ta.b52.inactive PRE_pl_ta.b52.bridge cnt257_258 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted258 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_ta.run258 PRE_pl_ta.run259) PRE_pl_ta.run260) PRE_pl_ta.run261) PRE_pl_ta.accepted262 live262 PRE_pl_ta.b53.step PRE_pl_ta.b53.top (fun ν h => by rw [oa258]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br258_263 cnt258_263 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b53.parts PRE_pl_ta.b53.args_ok PRE_pl_ta.b53.sym PRE_pl_ta.b53.mlx PRE_pl_ta.b53.pay (by decide) PRE_pl_ta.b53.decode PRE_pl_ta.b53.pre PRE_pl_ta.b53.runS (fun ν h => by rw [oa263]; exact good_drop _ (hg ν h)) PRE_pl_ta.b53.inactive PRE_pl_ta.b53.bridge cnt263_264 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted264 PRE_pl_ta.run264 PRE_pl_ta.accepted265 live265 PRE_pl_ta.b54.step PRE_pl_ta.b54.top (fun ν h => by rw [oa264]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br264_266 cnt264_266 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b54.parts PRE_pl_ta.b54.args_ok PRE_pl_ta.b54.sym PRE_pl_ta.b54.mlx PRE_pl_ta.b54.pay (by decide) PRE_pl_ta.b54.decode PRE_pl_ta.b54.pre PRE_pl_ta.b54.runS (fun ν h => by rw [oa266]; exact good_drop _ (hg ν h)) PRE_pl_ta.b54.inactive PRE_pl_ta.b54.bridge cnt266_267 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted267 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_ta.run267 PRE_pl_ta.run268) PRE_pl_ta.run269) PRE_pl_ta.run270) PRE_pl_ta.run271) PRE_pl_ta.run272) PRE_pl_ta.run273) PRE_pl_ta.accepted274 live274 PRE_pl_ta.b55.step PRE_pl_ta.b55.top (fun ν h => by rw [oa267]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br267_275 cnt267_275 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b55.parts PRE_pl_ta.b55.args_ok PRE_pl_ta.b55.sym PRE_pl_ta.b55.mlx PRE_pl_ta.b55.pay (by decide) PRE_pl_ta.b55.decode PRE_pl_ta.b55.pre PRE_pl_ta.b55.runS (fun ν h => by rw [oa275]; exact good_drop _ (hg ν h)) PRE_pl_ta.b55.inactive PRE_pl_ta.b55.bridge cnt275_276 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted276 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_ta.run276 PRE_pl_ta.run277) PRE_pl_ta.run278) PRE_pl_ta.accepted279 live279 PRE_pl_ta.b56.step PRE_pl_ta.b56.top (fun ν h => by rw [oa276]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br276_280 cnt276_280 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b56.parts PRE_pl_ta.b56.args_ok PRE_pl_ta.b56.sym PRE_pl_ta.b56.mlx PRE_pl_ta.b56.pay (by decide) PRE_pl_ta.b56.decode PRE_pl_ta.b56.pre PRE_pl_ta.b56.runS (fun ν h => by rw [oa280]; exact good_drop _ (hg ν h)) PRE_pl_ta.b56.inactive PRE_pl_ta.b56.bridge cnt280_281 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted281 PRE_pl_ta.run281 PRE_pl_ta.accepted282 live282 PRE_pl_ta.b57.step PRE_pl_ta.b57.top (fun ν h => by rw [oa281]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br281_283 cnt281_283 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b57.parts PRE_pl_ta.b57.args_ok PRE_pl_ta.b57.sym PRE_pl_ta.b57.mlx PRE_pl_ta.b57.pay (by decide) PRE_pl_ta.b57.decode PRE_pl_ta.b57.pre PRE_pl_ta.b57.runS (fun ν h => by rw [oa283]; exact good_drop _ (hg ν h)) PRE_pl_ta.b57.inactive PRE_pl_ta.b57.bridge cnt283_284 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted284 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_ta.run284 PRE_pl_ta.run285) PRE_pl_ta.run286) PRE_pl_ta.run287) PRE_pl_ta.accepted288 live288 PRE_pl_ta.b58.step PRE_pl_ta.b58.top (fun ν h => by rw [oa284]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br284_289 cnt284_289 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b58.parts PRE_pl_ta.b58.args_ok PRE_pl_ta.b58.sym PRE_pl_ta.b58.mlx PRE_pl_ta.b58.pay (by decide) PRE_pl_ta.b58.decode PRE_pl_ta.b58.pre PRE_pl_ta.b58.runS (fun ν h => by rw [oa289]; exact good_drop _ (hg ν h)) PRE_pl_ta.b58.inactive PRE_pl_ta.b58.bridge cnt289_290 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted290 PRE_pl_ta.run290 PRE_pl_ta.accepted291 live291 PRE_pl_ta.b59.step PRE_pl_ta.b59.top (fun ν h => by rw [oa290]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br290_292 cnt290_292 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b59.parts PRE_pl_ta.b59.args_ok PRE_pl_ta.b59.sym PRE_pl_ta.b59.mlx PRE_pl_ta.b59.pay (by decide) PRE_pl_ta.b59.decode PRE_pl_ta.b59.pre PRE_pl_ta.b59.runS (fun ν h => by rw [oa292]; exact good_drop _ (hg ν h)) PRE_pl_ta.b59.inactive PRE_pl_ta.b59.bridge cnt292_293 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted293 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_ta.run293 PRE_pl_ta.run294) PRE_pl_ta.run295) PRE_pl_ta.accepted296 live296 PRE_pl_ta.b60.step PRE_pl_ta.b60.top (fun ν h => by rw [oa293]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br293_297 cnt293_297 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b60.parts PRE_pl_ta.b60.args_ok PRE_pl_ta.b60.sym PRE_pl_ta.b60.mlx PRE_pl_ta.b60.pay (by decide) PRE_pl_ta.b60.decode PRE_pl_ta.b60.pre PRE_pl_ta.b60.runS (fun ν h => by rw [oa297]; exact good_drop _ (hg ν h)) PRE_pl_ta.b60.inactive PRE_pl_ta.b60.bridge cnt297_298 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted298 PRE_pl_ta.run298 PRE_pl_ta.accepted299 live299 PRE_pl_ta.b61.step PRE_pl_ta.b61.top (fun ν h => by rw [oa298]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br298_300 cnt298_300 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b61.parts PRE_pl_ta.b61.args_ok PRE_pl_ta.b61.sym PRE_pl_ta.b61.mlx PRE_pl_ta.b61.pay (by decide) PRE_pl_ta.b61.decode PRE_pl_ta.b61.pre PRE_pl_ta.b61.runS (fun ν h => by rw [oa300]; exact good_drop _ (hg ν h)) PRE_pl_ta.b61.inactive PRE_pl_ta.b61.bridge cnt300_301 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted301 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_ta.run301 PRE_pl_ta.run302) PRE_pl_ta.run303) PRE_pl_ta.run304) PRE_pl_ta.accepted305 live305 PRE_pl_ta.b62.step PRE_pl_ta.b62.top (fun ν h => by rw [oa301]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br301_306 cnt301_306 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b62.parts PRE_pl_ta.b62.args_ok PRE_pl_ta.b62.sym PRE_pl_ta.b62.mlx PRE_pl_ta.b62.pay (by decide) PRE_pl_ta.b62.decode PRE_pl_ta.b62.pre PRE_pl_ta.b62.runS (fun ν h => by rw [oa306]; exact good_drop _ (hg ν h)) PRE_pl_ta.b62.inactive PRE_pl_ta.b62.bridge cnt306_307 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted307 PRE_pl_ta.run307 PRE_pl_ta.accepted308 live308 PRE_pl_ta.b63.step PRE_pl_ta.b63.top (fun ν h => by rw [oa307]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br307_309 cnt307_309 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b63.parts PRE_pl_ta.b63.args_ok PRE_pl_ta.b63.sym PRE_pl_ta.b63.mlx PRE_pl_ta.b63.pay (by decide) PRE_pl_ta.b63.decode PRE_pl_ta.b63.pre PRE_pl_ta.b63.runS (fun ν h => by rw [oa309]; exact good_drop _ (hg ν h)) PRE_pl_ta.b63.inactive PRE_pl_ta.b63.bridge cnt309_310 hT)

end Host.Ts.Sim.Compose.Post.PL.Ta
