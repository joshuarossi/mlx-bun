import host.simgraph.tpl.fam.V588.Stages15
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.V588
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

def cacheNodes : List (Nat × Nat) := [
  (fragment0.1.2.1, fragment0.1.2.2),
  (fragment1.1.2.1, fragment1.1.2.2),
  (fragment2.1.2.1, fragment2.1.2.2),
  (fragment3.1.2.1, fragment3.1.2.2),
  (fragment4.1.2.1, fragment4.1.2.2),
  (fragment5.1.2.1, fragment5.1.2.2),
  (fragment6.1.2.1, fragment6.1.2.2),
  (fragment7.1.2.1, fragment7.1.2.2),
  (fragment8.1.2.1, fragment8.1.2.2),
  (fragment9.1.2.1, fragment9.1.2.2),
  (fragment10.1.2.1, fragment10.1.2.2),
  (fragment11.1.2.1, fragment11.1.2.2),
  (fragment12.1.2.1, fragment12.1.2.2),
  (fragment13.1.2.1, fragment13.1.2.2),
  (fragment14.1.2.1, fragment14.1.2.2),
  (fragment15.1.2.1, fragment15.1.2.2),
  (fragment16.1.2.1, fragment16.1.2.2),
  (fragment17.1.2.1, fragment17.1.2.2),
  (fragment18.1.2.1, fragment18.1.2.2),
  (fragment19.1.2.1, fragment19.1.2.2),
  (fragment20.1.2.1, fragment20.1.2.2),
  (fragment21.1.2.1, fragment21.1.2.2),
  (fragment22.1.2.1, fragment22.1.2.2),
  (fragment23.1.2.1, fragment23.1.2.2),
  (fragment24.1.2.1, fragment24.1.2.2),
  (fragment25.1.2.1, fragment25.1.2.2),
  (fragment26.1.2.1, fragment26.1.2.2),
  (fragment27.1.2.1, fragment27.1.2.2),
  (fragment28.1.2.1, fragment28.1.2.2),
  (fragment29.1.2.1, fragment29.1.2.2),
  (fragment30.1.2.1, fragment30.1.2.2),
  (fragment31.1.2.1, fragment31.1.2.2),
  (fragment32.1.2.1, fragment32.1.2.2),
  (fragment33.1.2.1, fragment33.1.2.2),
  (fragment34.1.2.1, fragment34.1.2.2),
  (fragment35.1.2.1, fragment35.1.2.2),
  (fragment36.1.2.1, fragment36.1.2.2),
  (fragment37.1.2.1, fragment37.1.2.2),
  (fragment38.1.2.1, fragment38.1.2.2),
  (fragment39.1.2.1, fragment39.1.2.2),
  (fragment40.1.2.1, fragment40.1.2.2),
  (fragment41.1.2.1, fragment41.1.2.2),
  (fragment42.1.2.1, fragment42.1.2.2),
  (fragment43.1.2.1, fragment43.1.2.2),
  (fragment44.1.2.1, fragment44.1.2.2),
  (fragment45.1.2.1, fragment45.1.2.2),
  (fragment46.1.2.1, fragment46.1.2.2),
  (fragment47.1.2.1, fragment47.1.2.2),
  (fragment48.1.2.1, fragment48.1.2.2),
  (fragment49.1.2.1, fragment49.1.2.2),
  (fragment50.1.2.1, fragment50.1.2.2),
  (fragment51.1.2.1, fragment51.1.2.2),
  (fragment52.1.2.1, fragment52.1.2.2),
  (fragment53.1.2.1, fragment53.1.2.2),
  (fragment54.1.2.1, fragment54.1.2.2),
  (fragment55.1.2.1, fragment55.1.2.2),
  (fragment56.1.2.1, fragment56.1.2.2),
  (fragment57.1.2.1, fragment57.1.2.2),
  (fragment58.1.2.1, fragment58.1.2.2),
  (fragment59.1.2.1, fragment59.1.2.2),
  (fragment60.1.2.1, fragment60.1.2.2),
  (fragment61.1.2.1, fragment61.1.2.2),
  (fragment62.1.2.1, fragment62.1.2.2),
  (fragment63.1.2.1, fragment63.1.2.2)]

theorem suffix63 :
  run (chainP F id 0 124 63 (stages.drop 63) fragment62.1.1) fragment62.2 =
    ((fragment63.1.1, cacheNodes.drop 63), fragment63.2) := by
  exact chainP_join F id 0 124 63 stages[63] [] fragment62.1.1 fragment63.1.1 fragment63.1.2.1 fragment63.1.2.2 fragment63.1.1
    [] fragment62.2 fragment63.2 fragment63.2 fragment63.eq_original.symm (chainP_nil F id 0 124 64 fragment63.1.1 fragment63.2)

theorem suffix62 :
  run (chainP F id 0 124 62 (stages.drop 62) fragment61.1.1) fragment61.2 =
    ((fragment63.1.1, cacheNodes.drop 62), fragment63.2) := by
  exact chainP_join F id 0 124 62 stages[62] (stages.drop 63) fragment61.1.1 fragment62.1.1 fragment62.1.2.1 fragment62.1.2.2 fragment63.1.1
    (cacheNodes.drop 63) fragment61.2 fragment62.2 fragment63.2 fragment62.eq_original.symm suffix63

theorem suffix61 :
  run (chainP F id 0 124 61 (stages.drop 61) fragment60.1.1) fragment60.2 =
    ((fragment63.1.1, cacheNodes.drop 61), fragment63.2) := by
  exact chainP_join F id 0 124 61 stages[61] (stages.drop 62) fragment60.1.1 fragment61.1.1 fragment61.1.2.1 fragment61.1.2.2 fragment63.1.1
    (cacheNodes.drop 62) fragment60.2 fragment61.2 fragment63.2 fragment61.eq_original.symm suffix62

theorem suffix60 :
  run (chainP F id 0 124 60 (stages.drop 60) fragment59.1.1) fragment59.2 =
    ((fragment63.1.1, cacheNodes.drop 60), fragment63.2) := by
  exact chainP_join F id 0 124 60 stages[60] (stages.drop 61) fragment59.1.1 fragment60.1.1 fragment60.1.2.1 fragment60.1.2.2 fragment63.1.1
    (cacheNodes.drop 61) fragment59.2 fragment60.2 fragment63.2 fragment60.eq_original.symm suffix61

theorem suffix59 :
  run (chainP F id 0 124 59 (stages.drop 59) fragment58.1.1) fragment58.2 =
    ((fragment63.1.1, cacheNodes.drop 59), fragment63.2) := by
  exact chainP_join F id 0 124 59 stages[59] (stages.drop 60) fragment58.1.1 fragment59.1.1 fragment59.1.2.1 fragment59.1.2.2 fragment63.1.1
    (cacheNodes.drop 60) fragment58.2 fragment59.2 fragment63.2 fragment59.eq_original.symm suffix60

theorem suffix58 :
  run (chainP F id 0 124 58 (stages.drop 58) fragment57.1.1) fragment57.2 =
    ((fragment63.1.1, cacheNodes.drop 58), fragment63.2) := by
  exact chainP_join F id 0 124 58 stages[58] (stages.drop 59) fragment57.1.1 fragment58.1.1 fragment58.1.2.1 fragment58.1.2.2 fragment63.1.1
    (cacheNodes.drop 59) fragment57.2 fragment58.2 fragment63.2 fragment58.eq_original.symm suffix59

theorem suffix57 :
  run (chainP F id 0 124 57 (stages.drop 57) fragment56.1.1) fragment56.2 =
    ((fragment63.1.1, cacheNodes.drop 57), fragment63.2) := by
  exact chainP_join F id 0 124 57 stages[57] (stages.drop 58) fragment56.1.1 fragment57.1.1 fragment57.1.2.1 fragment57.1.2.2 fragment63.1.1
    (cacheNodes.drop 58) fragment56.2 fragment57.2 fragment63.2 fragment57.eq_original.symm suffix58

theorem suffix56 :
  run (chainP F id 0 124 56 (stages.drop 56) fragment55.1.1) fragment55.2 =
    ((fragment63.1.1, cacheNodes.drop 56), fragment63.2) := by
  exact chainP_join F id 0 124 56 stages[56] (stages.drop 57) fragment55.1.1 fragment56.1.1 fragment56.1.2.1 fragment56.1.2.2 fragment63.1.1
    (cacheNodes.drop 57) fragment55.2 fragment56.2 fragment63.2 fragment56.eq_original.symm suffix57

theorem suffix55 :
  run (chainP F id 0 124 55 (stages.drop 55) fragment54.1.1) fragment54.2 =
    ((fragment63.1.1, cacheNodes.drop 55), fragment63.2) := by
  exact chainP_join F id 0 124 55 stages[55] (stages.drop 56) fragment54.1.1 fragment55.1.1 fragment55.1.2.1 fragment55.1.2.2 fragment63.1.1
    (cacheNodes.drop 56) fragment54.2 fragment55.2 fragment63.2 fragment55.eq_original.symm suffix56

theorem suffix54 :
  run (chainP F id 0 124 54 (stages.drop 54) fragment53.1.1) fragment53.2 =
    ((fragment63.1.1, cacheNodes.drop 54), fragment63.2) := by
  exact chainP_join F id 0 124 54 stages[54] (stages.drop 55) fragment53.1.1 fragment54.1.1 fragment54.1.2.1 fragment54.1.2.2 fragment63.1.1
    (cacheNodes.drop 55) fragment53.2 fragment54.2 fragment63.2 fragment54.eq_original.symm suffix55

theorem suffix53 :
  run (chainP F id 0 124 53 (stages.drop 53) fragment52.1.1) fragment52.2 =
    ((fragment63.1.1, cacheNodes.drop 53), fragment63.2) := by
  exact chainP_join F id 0 124 53 stages[53] (stages.drop 54) fragment52.1.1 fragment53.1.1 fragment53.1.2.1 fragment53.1.2.2 fragment63.1.1
    (cacheNodes.drop 54) fragment52.2 fragment53.2 fragment63.2 fragment53.eq_original.symm suffix54

theorem suffix52 :
  run (chainP F id 0 124 52 (stages.drop 52) fragment51.1.1) fragment51.2 =
    ((fragment63.1.1, cacheNodes.drop 52), fragment63.2) := by
  exact chainP_join F id 0 124 52 stages[52] (stages.drop 53) fragment51.1.1 fragment52.1.1 fragment52.1.2.1 fragment52.1.2.2 fragment63.1.1
    (cacheNodes.drop 53) fragment51.2 fragment52.2 fragment63.2 fragment52.eq_original.symm suffix53

theorem suffix51 :
  run (chainP F id 0 124 51 (stages.drop 51) fragment50.1.1) fragment50.2 =
    ((fragment63.1.1, cacheNodes.drop 51), fragment63.2) := by
  exact chainP_join F id 0 124 51 stages[51] (stages.drop 52) fragment50.1.1 fragment51.1.1 fragment51.1.2.1 fragment51.1.2.2 fragment63.1.1
    (cacheNodes.drop 52) fragment50.2 fragment51.2 fragment63.2 fragment51.eq_original.symm suffix52

theorem suffix50 :
  run (chainP F id 0 124 50 (stages.drop 50) fragment49.1.1) fragment49.2 =
    ((fragment63.1.1, cacheNodes.drop 50), fragment63.2) := by
  exact chainP_join F id 0 124 50 stages[50] (stages.drop 51) fragment49.1.1 fragment50.1.1 fragment50.1.2.1 fragment50.1.2.2 fragment63.1.1
    (cacheNodes.drop 51) fragment49.2 fragment50.2 fragment63.2 fragment50.eq_original.symm suffix51

theorem suffix49 :
  run (chainP F id 0 124 49 (stages.drop 49) fragment48.1.1) fragment48.2 =
    ((fragment63.1.1, cacheNodes.drop 49), fragment63.2) := by
  exact chainP_join F id 0 124 49 stages[49] (stages.drop 50) fragment48.1.1 fragment49.1.1 fragment49.1.2.1 fragment49.1.2.2 fragment63.1.1
    (cacheNodes.drop 50) fragment48.2 fragment49.2 fragment63.2 fragment49.eq_original.symm suffix50

theorem suffix48 :
  run (chainP F id 0 124 48 (stages.drop 48) fragment47.1.1) fragment47.2 =
    ((fragment63.1.1, cacheNodes.drop 48), fragment63.2) := by
  exact chainP_join F id 0 124 48 stages[48] (stages.drop 49) fragment47.1.1 fragment48.1.1 fragment48.1.2.1 fragment48.1.2.2 fragment63.1.1
    (cacheNodes.drop 49) fragment47.2 fragment48.2 fragment63.2 fragment48.eq_original.symm suffix49

theorem suffix47 :
  run (chainP F id 0 124 47 (stages.drop 47) fragment46.1.1) fragment46.2 =
    ((fragment63.1.1, cacheNodes.drop 47), fragment63.2) := by
  exact chainP_join F id 0 124 47 stages[47] (stages.drop 48) fragment46.1.1 fragment47.1.1 fragment47.1.2.1 fragment47.1.2.2 fragment63.1.1
    (cacheNodes.drop 48) fragment46.2 fragment47.2 fragment63.2 fragment47.eq_original.symm suffix48

theorem suffix46 :
  run (chainP F id 0 124 46 (stages.drop 46) fragment45.1.1) fragment45.2 =
    ((fragment63.1.1, cacheNodes.drop 46), fragment63.2) := by
  exact chainP_join F id 0 124 46 stages[46] (stages.drop 47) fragment45.1.1 fragment46.1.1 fragment46.1.2.1 fragment46.1.2.2 fragment63.1.1
    (cacheNodes.drop 47) fragment45.2 fragment46.2 fragment63.2 fragment46.eq_original.symm suffix47

theorem suffix45 :
  run (chainP F id 0 124 45 (stages.drop 45) fragment44.1.1) fragment44.2 =
    ((fragment63.1.1, cacheNodes.drop 45), fragment63.2) := by
  exact chainP_join F id 0 124 45 stages[45] (stages.drop 46) fragment44.1.1 fragment45.1.1 fragment45.1.2.1 fragment45.1.2.2 fragment63.1.1
    (cacheNodes.drop 46) fragment44.2 fragment45.2 fragment63.2 fragment45.eq_original.symm suffix46

theorem suffix44 :
  run (chainP F id 0 124 44 (stages.drop 44) fragment43.1.1) fragment43.2 =
    ((fragment63.1.1, cacheNodes.drop 44), fragment63.2) := by
  exact chainP_join F id 0 124 44 stages[44] (stages.drop 45) fragment43.1.1 fragment44.1.1 fragment44.1.2.1 fragment44.1.2.2 fragment63.1.1
    (cacheNodes.drop 45) fragment43.2 fragment44.2 fragment63.2 fragment44.eq_original.symm suffix45

theorem suffix43 :
  run (chainP F id 0 124 43 (stages.drop 43) fragment42.1.1) fragment42.2 =
    ((fragment63.1.1, cacheNodes.drop 43), fragment63.2) := by
  exact chainP_join F id 0 124 43 stages[43] (stages.drop 44) fragment42.1.1 fragment43.1.1 fragment43.1.2.1 fragment43.1.2.2 fragment63.1.1
    (cacheNodes.drop 44) fragment42.2 fragment43.2 fragment63.2 fragment43.eq_original.symm suffix44

theorem suffix42 :
  run (chainP F id 0 124 42 (stages.drop 42) fragment41.1.1) fragment41.2 =
    ((fragment63.1.1, cacheNodes.drop 42), fragment63.2) := by
  exact chainP_join F id 0 124 42 stages[42] (stages.drop 43) fragment41.1.1 fragment42.1.1 fragment42.1.2.1 fragment42.1.2.2 fragment63.1.1
    (cacheNodes.drop 43) fragment41.2 fragment42.2 fragment63.2 fragment42.eq_original.symm suffix43

theorem suffix41 :
  run (chainP F id 0 124 41 (stages.drop 41) fragment40.1.1) fragment40.2 =
    ((fragment63.1.1, cacheNodes.drop 41), fragment63.2) := by
  exact chainP_join F id 0 124 41 stages[41] (stages.drop 42) fragment40.1.1 fragment41.1.1 fragment41.1.2.1 fragment41.1.2.2 fragment63.1.1
    (cacheNodes.drop 42) fragment40.2 fragment41.2 fragment63.2 fragment41.eq_original.symm suffix42

theorem suffix40 :
  run (chainP F id 0 124 40 (stages.drop 40) fragment39.1.1) fragment39.2 =
    ((fragment63.1.1, cacheNodes.drop 40), fragment63.2) := by
  exact chainP_join F id 0 124 40 stages[40] (stages.drop 41) fragment39.1.1 fragment40.1.1 fragment40.1.2.1 fragment40.1.2.2 fragment63.1.1
    (cacheNodes.drop 41) fragment39.2 fragment40.2 fragment63.2 fragment40.eq_original.symm suffix41

theorem suffix39 :
  run (chainP F id 0 124 39 (stages.drop 39) fragment38.1.1) fragment38.2 =
    ((fragment63.1.1, cacheNodes.drop 39), fragment63.2) := by
  exact chainP_join F id 0 124 39 stages[39] (stages.drop 40) fragment38.1.1 fragment39.1.1 fragment39.1.2.1 fragment39.1.2.2 fragment63.1.1
    (cacheNodes.drop 40) fragment38.2 fragment39.2 fragment63.2 fragment39.eq_original.symm suffix40

theorem suffix38 :
  run (chainP F id 0 124 38 (stages.drop 38) fragment37.1.1) fragment37.2 =
    ((fragment63.1.1, cacheNodes.drop 38), fragment63.2) := by
  exact chainP_join F id 0 124 38 stages[38] (stages.drop 39) fragment37.1.1 fragment38.1.1 fragment38.1.2.1 fragment38.1.2.2 fragment63.1.1
    (cacheNodes.drop 39) fragment37.2 fragment38.2 fragment63.2 fragment38.eq_original.symm suffix39

theorem suffix37 :
  run (chainP F id 0 124 37 (stages.drop 37) fragment36.1.1) fragment36.2 =
    ((fragment63.1.1, cacheNodes.drop 37), fragment63.2) := by
  exact chainP_join F id 0 124 37 stages[37] (stages.drop 38) fragment36.1.1 fragment37.1.1 fragment37.1.2.1 fragment37.1.2.2 fragment63.1.1
    (cacheNodes.drop 38) fragment36.2 fragment37.2 fragment63.2 fragment37.eq_original.symm suffix38

theorem suffix36 :
  run (chainP F id 0 124 36 (stages.drop 36) fragment35.1.1) fragment35.2 =
    ((fragment63.1.1, cacheNodes.drop 36), fragment63.2) := by
  exact chainP_join F id 0 124 36 stages[36] (stages.drop 37) fragment35.1.1 fragment36.1.1 fragment36.1.2.1 fragment36.1.2.2 fragment63.1.1
    (cacheNodes.drop 37) fragment35.2 fragment36.2 fragment63.2 fragment36.eq_original.symm suffix37

theorem suffix35 :
  run (chainP F id 0 124 35 (stages.drop 35) fragment34.1.1) fragment34.2 =
    ((fragment63.1.1, cacheNodes.drop 35), fragment63.2) := by
  exact chainP_join F id 0 124 35 stages[35] (stages.drop 36) fragment34.1.1 fragment35.1.1 fragment35.1.2.1 fragment35.1.2.2 fragment63.1.1
    (cacheNodes.drop 36) fragment34.2 fragment35.2 fragment63.2 fragment35.eq_original.symm suffix36

theorem suffix34 :
  run (chainP F id 0 124 34 (stages.drop 34) fragment33.1.1) fragment33.2 =
    ((fragment63.1.1, cacheNodes.drop 34), fragment63.2) := by
  exact chainP_join F id 0 124 34 stages[34] (stages.drop 35) fragment33.1.1 fragment34.1.1 fragment34.1.2.1 fragment34.1.2.2 fragment63.1.1
    (cacheNodes.drop 35) fragment33.2 fragment34.2 fragment63.2 fragment34.eq_original.symm suffix35

theorem suffix33 :
  run (chainP F id 0 124 33 (stages.drop 33) fragment32.1.1) fragment32.2 =
    ((fragment63.1.1, cacheNodes.drop 33), fragment63.2) := by
  exact chainP_join F id 0 124 33 stages[33] (stages.drop 34) fragment32.1.1 fragment33.1.1 fragment33.1.2.1 fragment33.1.2.2 fragment63.1.1
    (cacheNodes.drop 34) fragment32.2 fragment33.2 fragment63.2 fragment33.eq_original.symm suffix34

theorem suffix32 :
  run (chainP F id 0 124 32 (stages.drop 32) fragment31.1.1) fragment31.2 =
    ((fragment63.1.1, cacheNodes.drop 32), fragment63.2) := by
  exact chainP_join F id 0 124 32 stages[32] (stages.drop 33) fragment31.1.1 fragment32.1.1 fragment32.1.2.1 fragment32.1.2.2 fragment63.1.1
    (cacheNodes.drop 33) fragment31.2 fragment32.2 fragment63.2 fragment32.eq_original.symm suffix33

theorem suffix31 :
  run (chainP F id 0 124 31 (stages.drop 31) fragment30.1.1) fragment30.2 =
    ((fragment63.1.1, cacheNodes.drop 31), fragment63.2) := by
  exact chainP_join F id 0 124 31 stages[31] (stages.drop 32) fragment30.1.1 fragment31.1.1 fragment31.1.2.1 fragment31.1.2.2 fragment63.1.1
    (cacheNodes.drop 32) fragment30.2 fragment31.2 fragment63.2 fragment31.eq_original.symm suffix32

theorem suffix30 :
  run (chainP F id 0 124 30 (stages.drop 30) fragment29.1.1) fragment29.2 =
    ((fragment63.1.1, cacheNodes.drop 30), fragment63.2) := by
  exact chainP_join F id 0 124 30 stages[30] (stages.drop 31) fragment29.1.1 fragment30.1.1 fragment30.1.2.1 fragment30.1.2.2 fragment63.1.1
    (cacheNodes.drop 31) fragment29.2 fragment30.2 fragment63.2 fragment30.eq_original.symm suffix31

theorem suffix29 :
  run (chainP F id 0 124 29 (stages.drop 29) fragment28.1.1) fragment28.2 =
    ((fragment63.1.1, cacheNodes.drop 29), fragment63.2) := by
  exact chainP_join F id 0 124 29 stages[29] (stages.drop 30) fragment28.1.1 fragment29.1.1 fragment29.1.2.1 fragment29.1.2.2 fragment63.1.1
    (cacheNodes.drop 30) fragment28.2 fragment29.2 fragment63.2 fragment29.eq_original.symm suffix30

theorem suffix28 :
  run (chainP F id 0 124 28 (stages.drop 28) fragment27.1.1) fragment27.2 =
    ((fragment63.1.1, cacheNodes.drop 28), fragment63.2) := by
  exact chainP_join F id 0 124 28 stages[28] (stages.drop 29) fragment27.1.1 fragment28.1.1 fragment28.1.2.1 fragment28.1.2.2 fragment63.1.1
    (cacheNodes.drop 29) fragment27.2 fragment28.2 fragment63.2 fragment28.eq_original.symm suffix29

theorem suffix27 :
  run (chainP F id 0 124 27 (stages.drop 27) fragment26.1.1) fragment26.2 =
    ((fragment63.1.1, cacheNodes.drop 27), fragment63.2) := by
  exact chainP_join F id 0 124 27 stages[27] (stages.drop 28) fragment26.1.1 fragment27.1.1 fragment27.1.2.1 fragment27.1.2.2 fragment63.1.1
    (cacheNodes.drop 28) fragment26.2 fragment27.2 fragment63.2 fragment27.eq_original.symm suffix28

theorem suffix26 :
  run (chainP F id 0 124 26 (stages.drop 26) fragment25.1.1) fragment25.2 =
    ((fragment63.1.1, cacheNodes.drop 26), fragment63.2) := by
  exact chainP_join F id 0 124 26 stages[26] (stages.drop 27) fragment25.1.1 fragment26.1.1 fragment26.1.2.1 fragment26.1.2.2 fragment63.1.1
    (cacheNodes.drop 27) fragment25.2 fragment26.2 fragment63.2 fragment26.eq_original.symm suffix27

theorem suffix25 :
  run (chainP F id 0 124 25 (stages.drop 25) fragment24.1.1) fragment24.2 =
    ((fragment63.1.1, cacheNodes.drop 25), fragment63.2) := by
  exact chainP_join F id 0 124 25 stages[25] (stages.drop 26) fragment24.1.1 fragment25.1.1 fragment25.1.2.1 fragment25.1.2.2 fragment63.1.1
    (cacheNodes.drop 26) fragment24.2 fragment25.2 fragment63.2 fragment25.eq_original.symm suffix26

theorem suffix24 :
  run (chainP F id 0 124 24 (stages.drop 24) fragment23.1.1) fragment23.2 =
    ((fragment63.1.1, cacheNodes.drop 24), fragment63.2) := by
  exact chainP_join F id 0 124 24 stages[24] (stages.drop 25) fragment23.1.1 fragment24.1.1 fragment24.1.2.1 fragment24.1.2.2 fragment63.1.1
    (cacheNodes.drop 25) fragment23.2 fragment24.2 fragment63.2 fragment24.eq_original.symm suffix25

theorem suffix23 :
  run (chainP F id 0 124 23 (stages.drop 23) fragment22.1.1) fragment22.2 =
    ((fragment63.1.1, cacheNodes.drop 23), fragment63.2) := by
  exact chainP_join F id 0 124 23 stages[23] (stages.drop 24) fragment22.1.1 fragment23.1.1 fragment23.1.2.1 fragment23.1.2.2 fragment63.1.1
    (cacheNodes.drop 24) fragment22.2 fragment23.2 fragment63.2 fragment23.eq_original.symm suffix24

theorem suffix22 :
  run (chainP F id 0 124 22 (stages.drop 22) fragment21.1.1) fragment21.2 =
    ((fragment63.1.1, cacheNodes.drop 22), fragment63.2) := by
  exact chainP_join F id 0 124 22 stages[22] (stages.drop 23) fragment21.1.1 fragment22.1.1 fragment22.1.2.1 fragment22.1.2.2 fragment63.1.1
    (cacheNodes.drop 23) fragment21.2 fragment22.2 fragment63.2 fragment22.eq_original.symm suffix23

theorem suffix21 :
  run (chainP F id 0 124 21 (stages.drop 21) fragment20.1.1) fragment20.2 =
    ((fragment63.1.1, cacheNodes.drop 21), fragment63.2) := by
  exact chainP_join F id 0 124 21 stages[21] (stages.drop 22) fragment20.1.1 fragment21.1.1 fragment21.1.2.1 fragment21.1.2.2 fragment63.1.1
    (cacheNodes.drop 22) fragment20.2 fragment21.2 fragment63.2 fragment21.eq_original.symm suffix22

theorem suffix20 :
  run (chainP F id 0 124 20 (stages.drop 20) fragment19.1.1) fragment19.2 =
    ((fragment63.1.1, cacheNodes.drop 20), fragment63.2) := by
  exact chainP_join F id 0 124 20 stages[20] (stages.drop 21) fragment19.1.1 fragment20.1.1 fragment20.1.2.1 fragment20.1.2.2 fragment63.1.1
    (cacheNodes.drop 21) fragment19.2 fragment20.2 fragment63.2 fragment20.eq_original.symm suffix21

theorem suffix19 :
  run (chainP F id 0 124 19 (stages.drop 19) fragment18.1.1) fragment18.2 =
    ((fragment63.1.1, cacheNodes.drop 19), fragment63.2) := by
  exact chainP_join F id 0 124 19 stages[19] (stages.drop 20) fragment18.1.1 fragment19.1.1 fragment19.1.2.1 fragment19.1.2.2 fragment63.1.1
    (cacheNodes.drop 20) fragment18.2 fragment19.2 fragment63.2 fragment19.eq_original.symm suffix20

theorem suffix18 :
  run (chainP F id 0 124 18 (stages.drop 18) fragment17.1.1) fragment17.2 =
    ((fragment63.1.1, cacheNodes.drop 18), fragment63.2) := by
  exact chainP_join F id 0 124 18 stages[18] (stages.drop 19) fragment17.1.1 fragment18.1.1 fragment18.1.2.1 fragment18.1.2.2 fragment63.1.1
    (cacheNodes.drop 19) fragment17.2 fragment18.2 fragment63.2 fragment18.eq_original.symm suffix19

theorem suffix17 :
  run (chainP F id 0 124 17 (stages.drop 17) fragment16.1.1) fragment16.2 =
    ((fragment63.1.1, cacheNodes.drop 17), fragment63.2) := by
  exact chainP_join F id 0 124 17 stages[17] (stages.drop 18) fragment16.1.1 fragment17.1.1 fragment17.1.2.1 fragment17.1.2.2 fragment63.1.1
    (cacheNodes.drop 18) fragment16.2 fragment17.2 fragment63.2 fragment17.eq_original.symm suffix18

theorem suffix16 :
  run (chainP F id 0 124 16 (stages.drop 16) fragment15.1.1) fragment15.2 =
    ((fragment63.1.1, cacheNodes.drop 16), fragment63.2) := by
  exact chainP_join F id 0 124 16 stages[16] (stages.drop 17) fragment15.1.1 fragment16.1.1 fragment16.1.2.1 fragment16.1.2.2 fragment63.1.1
    (cacheNodes.drop 17) fragment15.2 fragment16.2 fragment63.2 fragment16.eq_original.symm suffix17

theorem suffix15 :
  run (chainP F id 0 124 15 (stages.drop 15) fragment14.1.1) fragment14.2 =
    ((fragment63.1.1, cacheNodes.drop 15), fragment63.2) := by
  exact chainP_join F id 0 124 15 stages[15] (stages.drop 16) fragment14.1.1 fragment15.1.1 fragment15.1.2.1 fragment15.1.2.2 fragment63.1.1
    (cacheNodes.drop 16) fragment14.2 fragment15.2 fragment63.2 fragment15.eq_original.symm suffix16

theorem suffix14 :
  run (chainP F id 0 124 14 (stages.drop 14) fragment13.1.1) fragment13.2 =
    ((fragment63.1.1, cacheNodes.drop 14), fragment63.2) := by
  exact chainP_join F id 0 124 14 stages[14] (stages.drop 15) fragment13.1.1 fragment14.1.1 fragment14.1.2.1 fragment14.1.2.2 fragment63.1.1
    (cacheNodes.drop 15) fragment13.2 fragment14.2 fragment63.2 fragment14.eq_original.symm suffix15

theorem suffix13 :
  run (chainP F id 0 124 13 (stages.drop 13) fragment12.1.1) fragment12.2 =
    ((fragment63.1.1, cacheNodes.drop 13), fragment63.2) := by
  exact chainP_join F id 0 124 13 stages[13] (stages.drop 14) fragment12.1.1 fragment13.1.1 fragment13.1.2.1 fragment13.1.2.2 fragment63.1.1
    (cacheNodes.drop 14) fragment12.2 fragment13.2 fragment63.2 fragment13.eq_original.symm suffix14

theorem suffix12 :
  run (chainP F id 0 124 12 (stages.drop 12) fragment11.1.1) fragment11.2 =
    ((fragment63.1.1, cacheNodes.drop 12), fragment63.2) := by
  exact chainP_join F id 0 124 12 stages[12] (stages.drop 13) fragment11.1.1 fragment12.1.1 fragment12.1.2.1 fragment12.1.2.2 fragment63.1.1
    (cacheNodes.drop 13) fragment11.2 fragment12.2 fragment63.2 fragment12.eq_original.symm suffix13

theorem suffix11 :
  run (chainP F id 0 124 11 (stages.drop 11) fragment10.1.1) fragment10.2 =
    ((fragment63.1.1, cacheNodes.drop 11), fragment63.2) := by
  exact chainP_join F id 0 124 11 stages[11] (stages.drop 12) fragment10.1.1 fragment11.1.1 fragment11.1.2.1 fragment11.1.2.2 fragment63.1.1
    (cacheNodes.drop 12) fragment10.2 fragment11.2 fragment63.2 fragment11.eq_original.symm suffix12

theorem suffix10 :
  run (chainP F id 0 124 10 (stages.drop 10) fragment9.1.1) fragment9.2 =
    ((fragment63.1.1, cacheNodes.drop 10), fragment63.2) := by
  exact chainP_join F id 0 124 10 stages[10] (stages.drop 11) fragment9.1.1 fragment10.1.1 fragment10.1.2.1 fragment10.1.2.2 fragment63.1.1
    (cacheNodes.drop 11) fragment9.2 fragment10.2 fragment63.2 fragment10.eq_original.symm suffix11

theorem suffix9 :
  run (chainP F id 0 124 9 (stages.drop 9) fragment8.1.1) fragment8.2 =
    ((fragment63.1.1, cacheNodes.drop 9), fragment63.2) := by
  exact chainP_join F id 0 124 9 stages[9] (stages.drop 10) fragment8.1.1 fragment9.1.1 fragment9.1.2.1 fragment9.1.2.2 fragment63.1.1
    (cacheNodes.drop 10) fragment8.2 fragment9.2 fragment63.2 fragment9.eq_original.symm suffix10

theorem suffix8 :
  run (chainP F id 0 124 8 (stages.drop 8) fragment7.1.1) fragment7.2 =
    ((fragment63.1.1, cacheNodes.drop 8), fragment63.2) := by
  exact chainP_join F id 0 124 8 stages[8] (stages.drop 9) fragment7.1.1 fragment8.1.1 fragment8.1.2.1 fragment8.1.2.2 fragment63.1.1
    (cacheNodes.drop 9) fragment7.2 fragment8.2 fragment63.2 fragment8.eq_original.symm suffix9

theorem suffix7 :
  run (chainP F id 0 124 7 (stages.drop 7) fragment6.1.1) fragment6.2 =
    ((fragment63.1.1, cacheNodes.drop 7), fragment63.2) := by
  exact chainP_join F id 0 124 7 stages[7] (stages.drop 8) fragment6.1.1 fragment7.1.1 fragment7.1.2.1 fragment7.1.2.2 fragment63.1.1
    (cacheNodes.drop 8) fragment6.2 fragment7.2 fragment63.2 fragment7.eq_original.symm suffix8

theorem suffix6 :
  run (chainP F id 0 124 6 (stages.drop 6) fragment5.1.1) fragment5.2 =
    ((fragment63.1.1, cacheNodes.drop 6), fragment63.2) := by
  exact chainP_join F id 0 124 6 stages[6] (stages.drop 7) fragment5.1.1 fragment6.1.1 fragment6.1.2.1 fragment6.1.2.2 fragment63.1.1
    (cacheNodes.drop 7) fragment5.2 fragment6.2 fragment63.2 fragment6.eq_original.symm suffix7

theorem suffix5 :
  run (chainP F id 0 124 5 (stages.drop 5) fragment4.1.1) fragment4.2 =
    ((fragment63.1.1, cacheNodes.drop 5), fragment63.2) := by
  exact chainP_join F id 0 124 5 stages[5] (stages.drop 6) fragment4.1.1 fragment5.1.1 fragment5.1.2.1 fragment5.1.2.2 fragment63.1.1
    (cacheNodes.drop 6) fragment4.2 fragment5.2 fragment63.2 fragment5.eq_original.symm suffix6

theorem suffix4 :
  run (chainP F id 0 124 4 (stages.drop 4) fragment3.1.1) fragment3.2 =
    ((fragment63.1.1, cacheNodes.drop 4), fragment63.2) := by
  exact chainP_join F id 0 124 4 stages[4] (stages.drop 5) fragment3.1.1 fragment4.1.1 fragment4.1.2.1 fragment4.1.2.2 fragment63.1.1
    (cacheNodes.drop 5) fragment3.2 fragment4.2 fragment63.2 fragment4.eq_original.symm suffix5

theorem suffix3 :
  run (chainP F id 0 124 3 (stages.drop 3) fragment2.1.1) fragment2.2 =
    ((fragment63.1.1, cacheNodes.drop 3), fragment63.2) := by
  exact chainP_join F id 0 124 3 stages[3] (stages.drop 4) fragment2.1.1 fragment3.1.1 fragment3.1.2.1 fragment3.1.2.2 fragment63.1.1
    (cacheNodes.drop 4) fragment2.2 fragment3.2 fragment63.2 fragment3.eq_original.symm suffix4

theorem suffix2 :
  run (chainP F id 0 124 2 (stages.drop 2) fragment1.1.1) fragment1.2 =
    ((fragment63.1.1, cacheNodes.drop 2), fragment63.2) := by
  exact chainP_join F id 0 124 2 stages[2] (stages.drop 3) fragment1.1.1 fragment2.1.1 fragment2.1.2.1 fragment2.1.2.2 fragment63.1.1
    (cacheNodes.drop 3) fragment1.2 fragment2.2 fragment63.2 fragment2.eq_original.symm suffix3

theorem suffix1 :
  run (chainP F id 0 124 1 (stages.drop 1) fragment0.1.1) fragment0.2 =
    ((fragment63.1.1, cacheNodes.drop 1), fragment63.2) := by
  exact chainP_join F id 0 124 1 stages[1] (stages.drop 2) fragment0.1.1 fragment1.1.1 fragment1.1.2.1 fragment1.1.2.2 fragment63.1.1
    (cacheNodes.drop 2) fragment0.2 fragment1.2 fragment63.2 fragment1.eq_original.symm suffix2

theorem suffix0 :
  run (chainP F id 0 124 0 (stages.drop 0) embedded.1) embedded.2 =
    ((fragment63.1.1, cacheNodes.drop 0), fragment63.2) := by
  exact chainP_join F id 0 124 0 stages[0] (stages.drop 1) embedded.1 fragment0.1.1 fragment0.1.2.1 fragment0.1.2.2 fragment63.1.1
    (cacheNodes.drop 1) embedded.2 fragment0.2 fragment63.2 fragment0.eq_original.symm suffix1

ffi_value_literal finished : run (F.final (δ := PDim) id fragment63.1.1) fragment63.2
ffi_value_literal_eq finished : run (F.final (δ := PDim) id fragment63.1.1) fragment63.2

def graph : List (RNode PDim SimGraph.PKey) := finished.2
def outNode : Nat := finished.1

/-- **The family's expected graph** at the cold layout. -/
theorem family_eq : familyGraph F id 0 124 stages = (graph, outNode, cacheNodes) :=
  familyGraph_join F id 0 124 stages embedded.1 fragment63.1.1 finished.1 cacheNodes embedded.2 fragment63.2 finished.2
    embedded.eq_original.symm suffix0 finished.eq_original.symm

end Host.Mlx.SimGraph.Tpl.Fam.V588
