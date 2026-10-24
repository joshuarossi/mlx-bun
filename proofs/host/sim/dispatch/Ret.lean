import host.sim.dispatch.Ret2
import host.sim.dispatch.Ret3
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Dispatch of `.ret v` by the top frame (an empty stack runs the next job) -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F}

def okRet (P : JSP F) (s : St F.S) (n : Nat) (v : Val) : List Frame → Bool
  | [] => true
  | f :: fs => match f with
    | .e x => okRetE P s n v x
    | .c x => okRetC P s n v x
    | .l x => okRetL P s n v x
    | .a x => okRetA P s n v x
    | .s x => okRetS P s v x
    | .lp x => okRetLp P s n v x
    | .b x => okRetB P s n v x
    | .k x => okRetK P s n v fs x

theorem simRet {okBack : F.S → Arg → Bool} {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack) (hFR : FRLaws FR) (hK : Kp P K)
    (hW : Wp P W) (hN : NativeFacts F FR P) (h : RelB F FR W stk M ν K s S t C) {v : Val} (hc : s.ctl = .ret v)
    (hn : s.next + margin < Sim.bound) (hok : okRet P s S.tab.length v s.stack = true)
    (hloc : stk = [] ∨ localB s = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  cases hs : s.stack with
  | nil => exact MSim.toX (step_ret_empty h (hloc.resolve_right fun hl => localB_nil_ret hl hs hc) hc hs hn)
  | cons f fs =>
    rw [hs] at hok
    cases f with
    | e x => exact simRetE hF hFR hK hW hN h hc hs hn hok
    | c x => exact simRetC hF hK hW h hc hs hn hok
    | l x => exact simRetL hF hK hW h hc hs hn hok
    | a x => exact simRetA hF hFR hK hW hN h hc hs hn hok
    | s x => exact simRetS hF hFR hK hW h hc hs hn hok hloc
    | lp x => exact simRetLp hF hFR hK hW hN h hc hs hn hok
    | b x => exact simRetB hF hFR hK hW hN h hc hs hn hok
    | k x => exact simRetK hF hFR hK hW h hc hs hn hok hloc

end
end Host.Ts.Sim.Disp
