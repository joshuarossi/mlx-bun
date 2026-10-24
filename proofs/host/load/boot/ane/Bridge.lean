import host.load.boot.ane.b.B1
import host.load.boot.ane.b.B2
import host.load.boot.ane.b.B3
import host.load.boot.ane.b.B4
namespace Host.Load.Run.Prompt
open Host.Load.Boot

/-! # The bridge at `loadDone`

The boot's create log replayed in four pieces (`aneB_step1` … `aneB_step4`, each a kernel check): the bridge
the boot leaves is `aneB4`. -/

theorem aneB_eq : replay P.oblog2818 = aneB4 := by
  have h1 : (P.oblog2818.drop 548).drop 548 = P.oblog2818.drop 1096 := by rw [List.drop_drop]
  have h2 : (P.oblog2818.drop 1096).drop 548 = P.oblog2818.drop 1644 := by rw [List.drop_drop]
  rw [replay_onto, replayOnto_split _ _ 548, replayOnto_split _ (P.oblog2818.drop 548) 548, h1,
    replayOnto_split _ (P.oblog2818.drop 1096) 548, h2, aneB_step1, aneB_step2, aneB_step3, aneB_step4]

end Host.Load.Run.Prompt
