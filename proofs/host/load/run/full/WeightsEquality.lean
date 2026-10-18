import host.load.run.full.WeightsEquality0
import host.load.run.full.WeightsEquality1
import host.load.run.full.WeightsEquality2
import host.load.run.full.WeightsEquality3
import host.load.run.full.WeightsEquality4
set_option Elab.async false
set_option maxRecDepth 100000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.GlueLayers
theorem weights_congr (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) : weights v = weights v' := by
  unfold weights
  congr 1
  · exact h _ weights.covered1650
  · exact h _ weights.covered1651
  · exact h _ weights.covered1652
  · funext i
    fin_cases i
    · exact stage0_values_eq v v' h
    · exact stage1_values_eq v v' h
    · exact stage2_values_eq v v' h
    · exact stage4_values_eq v v' h
    · exact stage5_values_eq v v' h
    · exact stage6_values_eq v v' h
    · exact stage8_values_eq v v' h
    · exact stage9_values_eq v v' h
    · exact stage10_values_eq v v' h
    · exact stage12_values_eq v v' h
    · exact stage13_values_eq v v' h
    · exact stage14_values_eq v v' h
    · exact stage16_values_eq v v' h
    · exact stage17_values_eq v v' h
    · exact stage18_values_eq v v' h
    · exact stage20_values_eq v v' h
    · exact stage21_values_eq v v' h
    · exact stage22_values_eq v v' h
    · exact stage24_values_eq v v' h
    · exact stage25_values_eq v v' h
    · exact stage26_values_eq v v' h
    · exact stage28_values_eq v v' h
    · exact stage29_values_eq v v' h
    · exact stage30_values_eq v v' h
    · exact stage32_values_eq v v' h
    · exact stage33_values_eq v v' h
    · exact stage34_values_eq v v' h
    · exact stage36_values_eq v v' h
    · exact stage37_values_eq v v' h
    · exact stage38_values_eq v v' h
    · exact stage40_values_eq v v' h
    · exact stage41_values_eq v v' h
    · exact stage42_values_eq v v' h
    · exact stage44_values_eq v v' h
    · exact stage45_values_eq v v' h
    · exact stage46_values_eq v v' h
    · exact stage48_values_eq v v' h
    · exact stage49_values_eq v v' h
    · exact stage50_values_eq v v' h
    · exact stage52_values_eq v v' h
    · exact stage53_values_eq v v' h
    · exact stage54_values_eq v v' h
    · exact stage56_values_eq v v' h
    · exact stage57_values_eq v v' h
    · exact stage58_values_eq v v' h
    · exact stage60_values_eq v v' h
    · exact stage61_values_eq v v' h
    · exact stage62_values_eq v v' h
  · funext i
    fin_cases i
    · exact stage3_values_eq v v' h
    · exact stage7_values_eq v v' h
    · exact stage11_values_eq v v' h
    · exact stage15_values_eq v v' h
    · exact stage19_values_eq v v' h
    · exact stage23_values_eq v v' h
    · exact stage27_values_eq v v' h
    · exact stage31_values_eq v v' h
    · exact stage35_values_eq v v' h
    · exact stage39_values_eq v v' h
    · exact stage43_values_eq v v' h
    · exact stage47_values_eq v v' h
    · exact stage51_values_eq v v' h
    · exact stage55_values_eq v v' h
    · exact stage59_values_eq v v' h
    · exact stage63_values_eq v v' h
  · exact h _ weights.covered1653
  · congr 1
    · exact h _ weights.covered1654
    · exact h _ weights.covered1655
    · exact h _ weights.covered1656
end Host.Load.Run.Full
