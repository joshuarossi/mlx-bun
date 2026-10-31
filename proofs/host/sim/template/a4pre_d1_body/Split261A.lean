import host.sim.template.a4pre_d1_body.Split261Data
import host.sim.template.a4pre_d1_body.TraceStep
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

kernel_rfl D1BodySplit261.part0 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 3333 D1BodySized.s261 D1BodySized.S261) =
    fun _ => some (D1BodySplit261.s1, D1BodySplit261.originalS1)

theorem D1BodySplit261.run0 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 3333 D1BodySized.s261 D1BodySized.S261 =
      some (D1BodySplit261.s1, D1BodySplit261.originalS1) := congrFun D1BodySplit261.part0 bs

end Host.Load.Run.Tpl
