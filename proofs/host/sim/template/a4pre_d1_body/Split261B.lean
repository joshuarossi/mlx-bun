import host.sim.template.a4pre_d1_body.Split261Data2
import host.sim.template.a4pre_d1_body.TraceStep
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

kernel_rfl D1BodySplit261.part1 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 3333 D1BodySplit261.s1 D1BodySplit261.originalS1) =
    fun _ => some (D1BodySplit261.s2, D1BodySplit261.originalS2)

theorem D1BodySplit261.run1 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 3333 D1BodySplit261.s1 D1BodySplit261.originalS1 =
      some (D1BodySplit261.s2, D1BodySplit261.originalS2) := congrFun D1BodySplit261.part1 bs

end Host.Load.Run.Tpl
