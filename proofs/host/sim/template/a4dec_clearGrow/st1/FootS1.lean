import host.sim.template.a4dec_clearGrow.st1.FootS0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_clearGrow.st1.fR32 : List (Nat × Nat) := [(3123796, 3123797), (3153989, 3153990), (3154027, 3154030), (3154055, 3154056), (3154078, 3154080), (3155453, 3155454), (3155477, 3155480), (3155481, 3155482)]
kernel_rfl DEC_clearGrow.st1.fh32 : DEC_clearGrow.st1.s33.heap = setAll DEC_clearGrow.st1.s32.heap (rangesOf DEC_clearGrow.st1.s33.heap DEC_clearGrow.st1.fR32 ++ freshOf DEC_clearGrow.st1.s33.heap DEC_clearGrow.st1.s32.next DEC_clearGrow.st1.s33.next)
kernel_rfl DEC_clearGrow.st1.fb32 : footRB DEC_clearGrow.st1.s32 DEC_clearGrow.st1.s33 DEC_clearGrow.st1.fR32 = true
kernel_rfl DEC_clearGrow.st1.fc32 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s32.next && Nat.ble DEC_clearGrow.st1.s33.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR32 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa33 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s33 :=
  DEC_clearGrow.st1.fa32.step (stageFoot_ofRF DEC_clearGrow.st1.fh32 DEC_clearGrow.st1.fb32) (incl_of_footW DEC_clearGrow.st1.fb32 DEC_clearGrow.st1.fc32)

def DEC_clearGrow.st1.fR33 : List (Nat × Nat) := [(2672403, 2672404), (3008846, 3008847)]
kernel_rfl DEC_clearGrow.st1.fh33 : DEC_clearGrow.st1.s34.heap = setAll DEC_clearGrow.st1.s33.heap (rangesOf DEC_clearGrow.st1.s34.heap DEC_clearGrow.st1.fR33 ++ freshOf DEC_clearGrow.st1.s34.heap DEC_clearGrow.st1.s33.next DEC_clearGrow.st1.s34.next)
kernel_rfl DEC_clearGrow.st1.fb33 : footRB DEC_clearGrow.st1.s33 DEC_clearGrow.st1.s34 DEC_clearGrow.st1.fR33 = true
kernel_rfl DEC_clearGrow.st1.fc33 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s33.next && Nat.ble DEC_clearGrow.st1.s34.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR33 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa34 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s34 :=
  DEC_clearGrow.st1.fa33.step (stageFoot_ofRF DEC_clearGrow.st1.fh33 DEC_clearGrow.st1.fb33) (incl_of_footW DEC_clearGrow.st1.fb33 DEC_clearGrow.st1.fc33)

def DEC_clearGrow.st1.fR34 : List (Nat × Nat) := [(2672403, 2672404), (3009275, 3009276), (3156423, 3156426), (3156471, 3156476), (3156665, 3156666), (3156890, 3156891), (3156976, 3156977), (3157065, 3157066), (3157108, 3157110), (3157431, 3157432), (3157437, 3157438), (3157443, 3157444), (3157466, 3157474)]
kernel_rfl DEC_clearGrow.st1.fh34 : DEC_clearGrow.st1.s35.heap = setAll DEC_clearGrow.st1.s34.heap (rangesOf DEC_clearGrow.st1.s35.heap DEC_clearGrow.st1.fR34 ++ freshOf DEC_clearGrow.st1.s35.heap DEC_clearGrow.st1.s34.next DEC_clearGrow.st1.s35.next)
kernel_rfl DEC_clearGrow.st1.fb34 : footRB DEC_clearGrow.st1.s34 DEC_clearGrow.st1.s35 DEC_clearGrow.st1.fR34 = true
kernel_rfl DEC_clearGrow.st1.fc34 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s34.next && Nat.ble DEC_clearGrow.st1.s35.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR34 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa35 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s35 :=
  DEC_clearGrow.st1.fa34.step (stageFoot_ofRF DEC_clearGrow.st1.fh34 DEC_clearGrow.st1.fb34) (incl_of_footW DEC_clearGrow.st1.fb34 DEC_clearGrow.st1.fc34)

def DEC_clearGrow.st1.fR35 : List (Nat × Nat) := [(3123796, 3123797), (3156385, 3156386), (3156451, 3156452), (3158065, 3158066), (3158119, 3158120), (3158125, 3158126), (3158131, 3158132), (3158385, 3158386), (3158404, 3158407), (3158409, 3158411)]
kernel_rfl DEC_clearGrow.st1.fh35 : DEC_clearGrow.st1.s36.heap = setAll DEC_clearGrow.st1.s35.heap (rangesOf DEC_clearGrow.st1.s36.heap DEC_clearGrow.st1.fR35 ++ freshOf DEC_clearGrow.st1.s36.heap DEC_clearGrow.st1.s35.next DEC_clearGrow.st1.s36.next)
kernel_rfl DEC_clearGrow.st1.fb35 : footRB DEC_clearGrow.st1.s35 DEC_clearGrow.st1.s36 DEC_clearGrow.st1.fR35 = true
kernel_rfl DEC_clearGrow.st1.fc35 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s35.next && Nat.ble DEC_clearGrow.st1.s36.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR35 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa36 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s36 :=
  DEC_clearGrow.st1.fa35.step (stageFoot_ofRF DEC_clearGrow.st1.fh35 DEC_clearGrow.st1.fb35) (incl_of_footW DEC_clearGrow.st1.fb35 DEC_clearGrow.st1.fc35)

def DEC_clearGrow.st1.fR36 : List (Nat × Nat) := [(4841, 4842), (2672415, 2672416), (3011330, 3011331), (3011382, 3011383), (3158816, 3158817), (3158879, 3158889), (3159110, 3159111), (3159205, 3159206), (3159291, 3159292), (3159380, 3159381), (3159418, 3159419)]
kernel_rfl DEC_clearGrow.st1.fh36 : DEC_clearGrow.st1.s37.heap = setAll DEC_clearGrow.st1.s36.heap (rangesOf DEC_clearGrow.st1.s37.heap DEC_clearGrow.st1.fR36 ++ freshOf DEC_clearGrow.st1.s37.heap DEC_clearGrow.st1.s36.next DEC_clearGrow.st1.s37.next)
kernel_rfl DEC_clearGrow.st1.fb36 : footRB DEC_clearGrow.st1.s36 DEC_clearGrow.st1.s37 DEC_clearGrow.st1.fR36 = true
kernel_rfl DEC_clearGrow.st1.fc36 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s36.next && Nat.ble DEC_clearGrow.st1.s37.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR36 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa37 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s37 :=
  DEC_clearGrow.st1.fa36.step (stageFoot_ofRF DEC_clearGrow.st1.fh36 DEC_clearGrow.st1.fb36) (incl_of_footW DEC_clearGrow.st1.fb36 DEC_clearGrow.st1.fc36)

def DEC_clearGrow.st1.fR37 : List (Nat × Nat) := [(3123796, 3123797), (3158777, 3158778), (3158817, 3158819), (3158844, 3158845), (3160433, 3160434)]
kernel_rfl DEC_clearGrow.st1.fh37 : DEC_clearGrow.st1.s38.heap = setAll DEC_clearGrow.st1.s37.heap (rangesOf DEC_clearGrow.st1.s38.heap DEC_clearGrow.st1.fR37 ++ freshOf DEC_clearGrow.st1.s38.heap DEC_clearGrow.st1.s37.next DEC_clearGrow.st1.s38.next)
kernel_rfl DEC_clearGrow.st1.fb37 : footRB DEC_clearGrow.st1.s37 DEC_clearGrow.st1.s38 DEC_clearGrow.st1.fR37 = true
kernel_rfl DEC_clearGrow.st1.fc37 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s37.next && Nat.ble DEC_clearGrow.st1.s38.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR37 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa38 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s38 :=
  DEC_clearGrow.st1.fa37.step (stageFoot_ofRF DEC_clearGrow.st1.fh37 DEC_clearGrow.st1.fb37) (incl_of_footW DEC_clearGrow.st1.fb37 DEC_clearGrow.st1.fc37)

def DEC_clearGrow.st1.fR38 : List (Nat × Nat) := [(2672424, 2672425), (3013440, 3013441), (3161256, 3161261), (3161297, 3161298), (3161365, 3161366), (3161368, 3161378), (3161426, 3161427)]
kernel_rfl DEC_clearGrow.st1.fh38 : DEC_clearGrow.st1.s39.heap = setAll DEC_clearGrow.st1.s38.heap (rangesOf DEC_clearGrow.st1.s39.heap DEC_clearGrow.st1.fR38 ++ freshOf DEC_clearGrow.st1.s39.heap DEC_clearGrow.st1.s38.next DEC_clearGrow.st1.s39.next)
kernel_rfl DEC_clearGrow.st1.fb38 : footRB DEC_clearGrow.st1.s38 DEC_clearGrow.st1.s39 DEC_clearGrow.st1.fR38 = true
kernel_rfl DEC_clearGrow.st1.fc38 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s38.next && Nat.ble DEC_clearGrow.st1.s39.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR38 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa39 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s39 :=
  DEC_clearGrow.st1.fa38.step (stageFoot_ofRF DEC_clearGrow.st1.fh38 DEC_clearGrow.st1.fb38) (incl_of_footW DEC_clearGrow.st1.fb38 DEC_clearGrow.st1.fc38)

def DEC_clearGrow.st1.fR39 : List (Nat × Nat) := [(2672424, 2672425), (3013869, 3013870), (3161213, 3161216), (3161261, 3161266), (3161455, 3161456), (3161680, 3161681), (3161766, 3161767), (3161855, 3161856), (3161898, 3161900), (3162221, 3162222), (3162227, 3162228), (3162233, 3162234), (3162262, 3162264), (3162308, 3162309), (3162352, 3162353), (3162374, 3162376), (3162415, 3162416), (3162447, 3162448), (3162450, 3162460), (3162493, 3162494)]
kernel_rfl DEC_clearGrow.st1.fh39 : DEC_clearGrow.st1.s40.heap = setAll DEC_clearGrow.st1.s39.heap (rangesOf DEC_clearGrow.st1.s40.heap DEC_clearGrow.st1.fR39 ++ freshOf DEC_clearGrow.st1.s40.heap DEC_clearGrow.st1.s39.next DEC_clearGrow.st1.s40.next)
kernel_rfl DEC_clearGrow.st1.fb39 : footRB DEC_clearGrow.st1.s39 DEC_clearGrow.st1.s40 DEC_clearGrow.st1.fR39 = true
kernel_rfl DEC_clearGrow.st1.fc39 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s39.next && Nat.ble DEC_clearGrow.st1.s40.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR39 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa40 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s40 :=
  DEC_clearGrow.st1.fa39.step (stageFoot_ofRF DEC_clearGrow.st1.fh39 DEC_clearGrow.st1.fb39) (incl_of_footW DEC_clearGrow.st1.fb39 DEC_clearGrow.st1.fc39)

def DEC_clearGrow.st1.fR40 : List (Nat × Nat) := [(3123796, 3123797), (3161153, 3161154), (3161241, 3161242), (3162855, 3162856), (3162909, 3162910), (3162915, 3162916), (3162921, 3162922), (3163175, 3163176), (3163196, 3163197), (3163246, 3163247), (3163268, 3163270), (3163302, 3163303), (3163305, 3163315)]
kernel_rfl DEC_clearGrow.st1.fh40 : DEC_clearGrow.st1.s41.heap = setAll DEC_clearGrow.st1.s40.heap (rangesOf DEC_clearGrow.st1.s41.heap DEC_clearGrow.st1.fR40 ++ freshOf DEC_clearGrow.st1.s41.heap DEC_clearGrow.st1.s40.next DEC_clearGrow.st1.s41.next)
kernel_rfl DEC_clearGrow.st1.fb40 : footRB DEC_clearGrow.st1.s40 DEC_clearGrow.st1.s41 DEC_clearGrow.st1.fR40 = true
kernel_rfl DEC_clearGrow.st1.fc40 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s40.next && Nat.ble DEC_clearGrow.st1.s41.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR40 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa41 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s41 :=
  DEC_clearGrow.st1.fa40.step (stageFoot_ofRF DEC_clearGrow.st1.fh40 DEC_clearGrow.st1.fb40) (incl_of_footW DEC_clearGrow.st1.fb40 DEC_clearGrow.st1.fc40)

def DEC_clearGrow.st1.fR41 : List (Nat × Nat) := [(2672429, 2672430), (3015836, 3015837), (3016265, 3016266), (3163609, 3163612), (3163657, 3163662), (3163851, 3163852), (3164076, 3164077), (3164162, 3164163), (3164251, 3164252), (3164289, 3164296), (3164335, 3164337), (3164389, 3164390), (3164412, 3164415)]
kernel_rfl DEC_clearGrow.st1.fh41 : DEC_clearGrow.st1.s42.heap = setAll DEC_clearGrow.st1.s41.heap (rangesOf DEC_clearGrow.st1.s42.heap DEC_clearGrow.st1.fR41 ++ freshOf DEC_clearGrow.st1.s42.heap DEC_clearGrow.st1.s41.next DEC_clearGrow.st1.s42.next)
kernel_rfl DEC_clearGrow.st1.fb41 : footRB DEC_clearGrow.st1.s41 DEC_clearGrow.st1.s42 DEC_clearGrow.st1.fR41 = true
kernel_rfl DEC_clearGrow.st1.fc41 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s41.next && Nat.ble DEC_clearGrow.st1.s42.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR41 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa42 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s42 :=
  DEC_clearGrow.st1.fa41.step (stageFoot_ofRF DEC_clearGrow.st1.fh41 DEC_clearGrow.st1.fb41) (incl_of_footW DEC_clearGrow.st1.fb41 DEC_clearGrow.st1.fc41)

def DEC_clearGrow.st1.fR42 : List (Nat × Nat) := [(3123796, 3123797), (3163571, 3163572), (3163637, 3163638), (3165251, 3165252), (3165305, 3165306), (3165311, 3165312), (3165317, 3165318), (3165325, 3165326), (3165336, 3165340)]
kernel_rfl DEC_clearGrow.st1.fh42 : DEC_clearGrow.st1.s43.heap = setAll DEC_clearGrow.st1.s42.heap (rangesOf DEC_clearGrow.st1.s43.heap DEC_clearGrow.st1.fR42 ++ freshOf DEC_clearGrow.st1.s43.heap DEC_clearGrow.st1.s42.next DEC_clearGrow.st1.s43.next)
kernel_rfl DEC_clearGrow.st1.fb42 : footRB DEC_clearGrow.st1.s42 DEC_clearGrow.st1.s43 DEC_clearGrow.st1.fR42 = true
kernel_rfl DEC_clearGrow.st1.fc42 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s42.next && Nat.ble DEC_clearGrow.st1.s43.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR42 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa43 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s43 :=
  DEC_clearGrow.st1.fa42.step (stageFoot_ofRF DEC_clearGrow.st1.fh42 DEC_clearGrow.st1.fb42) (incl_of_footW DEC_clearGrow.st1.fb42 DEC_clearGrow.st1.fc42)

def DEC_clearGrow.st1.fR43 : List (Nat × Nat) := [(2672434, 2672435), (3018232, 3018233), (3166049, 3166053), (3166278, 3166279), (3166346, 3166347), (3166349, 3166359)]
kernel_rfl DEC_clearGrow.st1.fh43 : DEC_clearGrow.st1.s44.heap = setAll DEC_clearGrow.st1.s43.heap (rangesOf DEC_clearGrow.st1.s44.heap DEC_clearGrow.st1.fR43 ++ freshOf DEC_clearGrow.st1.s44.heap DEC_clearGrow.st1.s43.next DEC_clearGrow.st1.s44.next)
kernel_rfl DEC_clearGrow.st1.fb43 : footRB DEC_clearGrow.st1.s43 DEC_clearGrow.st1.s44 DEC_clearGrow.st1.fR43 = true
kernel_rfl DEC_clearGrow.st1.fc43 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s43.next && Nat.ble DEC_clearGrow.st1.s44.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR43 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa44 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s44 :=
  DEC_clearGrow.st1.fa43.step (stageFoot_ofRF DEC_clearGrow.st1.fh43 DEC_clearGrow.st1.fb43) (incl_of_footW DEC_clearGrow.st1.fb43 DEC_clearGrow.st1.fc43)

def DEC_clearGrow.st1.fR44 : List (Nat × Nat) := [(2672434, 2672435), (3018661, 3018662), (3166005, 3166008), (3166053, 3166058), (3166247, 3166248), (3166472, 3166473), (3166558, 3166559), (3166647, 3166648), (3167019, 3167020), (3167025, 3167026), (3167345, 3167346)]
kernel_rfl DEC_clearGrow.st1.fh44 : DEC_clearGrow.st1.s45.heap = setAll DEC_clearGrow.st1.s44.heap (rangesOf DEC_clearGrow.st1.s45.heap DEC_clearGrow.st1.fR44 ++ freshOf DEC_clearGrow.st1.s45.heap DEC_clearGrow.st1.s44.next DEC_clearGrow.st1.s45.next)
kernel_rfl DEC_clearGrow.st1.fb44 : footRB DEC_clearGrow.st1.s44 DEC_clearGrow.st1.s45 DEC_clearGrow.st1.fR44 = true
kernel_rfl DEC_clearGrow.st1.fc44 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s44.next && Nat.ble DEC_clearGrow.st1.s45.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR44 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa45 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s45 :=
  DEC_clearGrow.st1.fa44.step (stageFoot_ofRF DEC_clearGrow.st1.fh44 DEC_clearGrow.st1.fb44) (incl_of_footW DEC_clearGrow.st1.fb44 DEC_clearGrow.st1.fc44)

def DEC_clearGrow.st1.fR45 : List (Nat × Nat) := [(4841, 4842), (3123796, 3123797), (3165967, 3165968), (3166033, 3166034), (3167647, 3167648), (3167701, 3167702), (3167707, 3167708), (3167713, 3167714), (3167967, 3167968), (3167988, 3167989), (3168038, 3168039), (3168061, 3168062), (3168204, 3168205), (3168287, 3168288)]
kernel_rfl DEC_clearGrow.st1.fh45 : DEC_clearGrow.st1.s46.heap = setAll DEC_clearGrow.st1.s45.heap (rangesOf DEC_clearGrow.st1.s46.heap DEC_clearGrow.st1.fR45 ++ freshOf DEC_clearGrow.st1.s46.heap DEC_clearGrow.st1.s45.next DEC_clearGrow.st1.s46.next)
kernel_rfl DEC_clearGrow.st1.fb45 : footRB DEC_clearGrow.st1.s45 DEC_clearGrow.st1.s46 DEC_clearGrow.st1.fR45 = true
kernel_rfl DEC_clearGrow.st1.fc45 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s45.next && Nat.ble DEC_clearGrow.st1.s46.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR45 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa46 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s46 :=
  DEC_clearGrow.st1.fa45.step (stageFoot_ofRF DEC_clearGrow.st1.fh45 DEC_clearGrow.st1.fb45) (incl_of_footW DEC_clearGrow.st1.fb45 DEC_clearGrow.st1.fc45)

def DEC_clearGrow.st1.fR46 : List (Nat × Nat) := [(2672446, 2672447), (3020720, 3020721), (3020772, 3020773), (3168402, 3168405), (3168468, 3168475), (3168791, 3168792), (3169201, 3169202), (3169236, 3169237), (3169271, 3169272), (3169296, 3169298), (3169304, 3169311), (3169340, 3169344), (3169360, 3169361)]
kernel_rfl DEC_clearGrow.st1.fh46 : DEC_clearGrow.st1.s47.heap = setAll DEC_clearGrow.st1.s46.heap (rangesOf DEC_clearGrow.st1.s47.heap DEC_clearGrow.st1.fR46 ++ freshOf DEC_clearGrow.st1.s47.heap DEC_clearGrow.st1.s46.next DEC_clearGrow.st1.s47.next)
kernel_rfl DEC_clearGrow.st1.fb46 : footRB DEC_clearGrow.st1.s46 DEC_clearGrow.st1.s47 DEC_clearGrow.st1.fR46 = true
kernel_rfl DEC_clearGrow.st1.fc46 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s46.next && Nat.ble DEC_clearGrow.st1.s47.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR46 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa47 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s47 :=
  DEC_clearGrow.st1.fa46.step (stageFoot_ofRF DEC_clearGrow.st1.fh46 DEC_clearGrow.st1.fb46) (incl_of_footW DEC_clearGrow.st1.fb46 DEC_clearGrow.st1.fc46)

def DEC_clearGrow.st1.fR47 : List (Nat × Nat) := [(3123796, 3123797), (3168363, 3168364), (3168430, 3168431), (3170019, 3170020), (3170077, 3170078), (3170083, 3170084), (3170089, 3170090), (3170097, 3170098), (3170111, 3170112), (3170312, 3170313), (3170335, 3170337), (3170338, 3170339)]
kernel_rfl DEC_clearGrow.st1.fh47 : DEC_clearGrow.st1.s48.heap = setAll DEC_clearGrow.st1.s47.heap (rangesOf DEC_clearGrow.st1.s48.heap DEC_clearGrow.st1.fR47 ++ freshOf DEC_clearGrow.st1.s48.heap DEC_clearGrow.st1.s47.next DEC_clearGrow.st1.s48.next)
kernel_rfl DEC_clearGrow.st1.fb47 : footRB DEC_clearGrow.st1.s47 DEC_clearGrow.st1.s48 DEC_clearGrow.st1.fR47 = true
kernel_rfl DEC_clearGrow.st1.fc47 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s47.next && Nat.ble DEC_clearGrow.st1.s48.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR47 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa48 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s48 :=
  DEC_clearGrow.st1.fa47.step (stageFoot_ofRF DEC_clearGrow.st1.fh47 DEC_clearGrow.st1.fb47) (incl_of_footW DEC_clearGrow.st1.fb47 DEC_clearGrow.st1.fc47)

def DEC_clearGrow.st1.fR48 : List (Nat × Nat) := [(2672455, 2672456), (3022826, 3022827), (3023255, 3023256), (3170840, 3170847), (3171037, 3171038), (3171262, 3171263), (3171275, 3171276), (3171327, 3171329), (3171330, 3171331)]
kernel_rfl DEC_clearGrow.st1.fh48 : DEC_clearGrow.st1.s49.heap = setAll DEC_clearGrow.st1.s48.heap (rangesOf DEC_clearGrow.st1.s49.heap DEC_clearGrow.st1.fR48 ++ freshOf DEC_clearGrow.st1.s49.heap DEC_clearGrow.st1.s48.next DEC_clearGrow.st1.s49.next)
kernel_rfl DEC_clearGrow.st1.fb48 : footRB DEC_clearGrow.st1.s48 DEC_clearGrow.st1.s49 DEC_clearGrow.st1.fR48 = true
kernel_rfl DEC_clearGrow.st1.fc48 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s48.next && Nat.ble DEC_clearGrow.st1.s49.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR48 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa49 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s49 :=
  DEC_clearGrow.st1.fa48.step (stageFoot_ofRF DEC_clearGrow.st1.fh48 DEC_clearGrow.st1.fb48) (incl_of_footW DEC_clearGrow.st1.fb48 DEC_clearGrow.st1.fc48)

def DEC_clearGrow.st1.fR49 : List (Nat × Nat) := [(3123796, 3123797), (3170735, 3170736), (3170795, 3170798), (3170823, 3170824), (3170847, 3170848), (3172254, 3172255), (3172279, 3172280), (3172345, 3172347)]
kernel_rfl DEC_clearGrow.st1.fh49 : DEC_clearGrow.st1.s50.heap = setAll DEC_clearGrow.st1.s49.heap (rangesOf DEC_clearGrow.st1.s50.heap DEC_clearGrow.st1.fR49 ++ freshOf DEC_clearGrow.st1.s50.heap DEC_clearGrow.st1.s49.next DEC_clearGrow.st1.s50.next)
kernel_rfl DEC_clearGrow.st1.fb49 : footRB DEC_clearGrow.st1.s49 DEC_clearGrow.st1.s50 DEC_clearGrow.st1.fR49 = true
kernel_rfl DEC_clearGrow.st1.fc49 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s49.next && Nat.ble DEC_clearGrow.st1.s50.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR49 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa50 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s50 :=
  DEC_clearGrow.st1.fa49.step (stageFoot_ofRF DEC_clearGrow.st1.fh49 DEC_clearGrow.st1.fb49) (incl_of_footW DEC_clearGrow.st1.fb49 DEC_clearGrow.st1.fc49)

def DEC_clearGrow.st1.fR50 : List (Nat × Nat) := [(2672460, 2672461), (3025218, 3025219), (3173230, 3173235), (3173271, 3173272)]
kernel_rfl DEC_clearGrow.st1.fh50 : DEC_clearGrow.st1.s51.heap = setAll DEC_clearGrow.st1.s50.heap (rangesOf DEC_clearGrow.st1.s51.heap DEC_clearGrow.st1.fR50 ++ freshOf DEC_clearGrow.st1.s51.heap DEC_clearGrow.st1.s50.next DEC_clearGrow.st1.s51.next)
kernel_rfl DEC_clearGrow.st1.fb50 : footRB DEC_clearGrow.st1.s50 DEC_clearGrow.st1.s51 DEC_clearGrow.st1.fR50 = true
kernel_rfl DEC_clearGrow.st1.fc50 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s50.next && Nat.ble DEC_clearGrow.st1.s51.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR50 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa51 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s51 :=
  DEC_clearGrow.st1.fa50.step (stageFoot_ofRF DEC_clearGrow.st1.fh50 DEC_clearGrow.st1.fb50) (incl_of_footW DEC_clearGrow.st1.fb50 DEC_clearGrow.st1.fc50)

def DEC_clearGrow.st1.fR51 : List (Nat × Nat) := [(2672460, 2672461), (3025647, 3025648), (3173187, 3173190), (3173235, 3173240), (3173429, 3173430), (3173654, 3173655), (3173740, 3173741), (3173829, 3173830), (3173872, 3173874), (3174195, 3174196), (3174201, 3174202), (3174207, 3174208), (3174236, 3174238), (3174282, 3174283), (3174326, 3174327), (3174340, 3174350), (3174352, 3174354)]
kernel_rfl DEC_clearGrow.st1.fh51 : DEC_clearGrow.st1.s52.heap = setAll DEC_clearGrow.st1.s51.heap (rangesOf DEC_clearGrow.st1.s52.heap DEC_clearGrow.st1.fR51 ++ freshOf DEC_clearGrow.st1.s52.heap DEC_clearGrow.st1.s51.next DEC_clearGrow.st1.s52.next)
kernel_rfl DEC_clearGrow.st1.fb51 : footRB DEC_clearGrow.st1.s51 DEC_clearGrow.st1.s52 DEC_clearGrow.st1.fR51 = true
kernel_rfl DEC_clearGrow.st1.fc51 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s51.next && Nat.ble DEC_clearGrow.st1.s52.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR51 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa52 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s52 :=
  DEC_clearGrow.st1.fa51.step (stageFoot_ofRF DEC_clearGrow.st1.fh51 DEC_clearGrow.st1.fb51) (incl_of_footW DEC_clearGrow.st1.fb51 DEC_clearGrow.st1.fc51)

def DEC_clearGrow.st1.fR52 : List (Nat × Nat) := [(3123796, 3123797), (3173149, 3173150), (3173215, 3173216), (3174829, 3174830), (3174883, 3174884), (3174889, 3174890), (3174895, 3174896), (3175149, 3175150), (3175170, 3175171), (3175220, 3175221), (3175238, 3175240), (3175269, 3175270)]
kernel_rfl DEC_clearGrow.st1.fh52 : DEC_clearGrow.st1.s53.heap = setAll DEC_clearGrow.st1.s52.heap (rangesOf DEC_clearGrow.st1.s53.heap DEC_clearGrow.st1.fR52 ++ freshOf DEC_clearGrow.st1.s53.heap DEC_clearGrow.st1.s52.next DEC_clearGrow.st1.s53.next)
kernel_rfl DEC_clearGrow.st1.fb52 : footRB DEC_clearGrow.st1.s52 DEC_clearGrow.st1.s53 DEC_clearGrow.st1.fR52 = true
kernel_rfl DEC_clearGrow.st1.fc52 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s52.next && Nat.ble DEC_clearGrow.st1.s53.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR52 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa53 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s53 :=
  DEC_clearGrow.st1.fa52.step (stageFoot_ofRF DEC_clearGrow.st1.fh52 DEC_clearGrow.st1.fb52) (incl_of_footW DEC_clearGrow.st1.fb52 DEC_clearGrow.st1.fc52)

def DEC_clearGrow.st1.fR53 : List (Nat × Nat) := [(2672465, 2672466), (3027610, 3027611), (3028039, 3028040), (3175579, 3175580), (3175627, 3175632), (3175821, 3175822), (3176046, 3176047), (3176132, 3176133), (3176221, 3176222), (3176255, 3176266), (3176281, 3176283)]
kernel_rfl DEC_clearGrow.st1.fh53 : DEC_clearGrow.st1.s54.heap = setAll DEC_clearGrow.st1.s53.heap (rangesOf DEC_clearGrow.st1.s54.heap DEC_clearGrow.st1.fR53 ++ freshOf DEC_clearGrow.st1.s54.heap DEC_clearGrow.st1.s53.next DEC_clearGrow.st1.s54.next)
kernel_rfl DEC_clearGrow.st1.fb53 : footRB DEC_clearGrow.st1.s53 DEC_clearGrow.st1.s54 DEC_clearGrow.st1.fR53 = true
kernel_rfl DEC_clearGrow.st1.fc53 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s53.next && Nat.ble DEC_clearGrow.st1.s54.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR53 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa54 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s54 :=
  DEC_clearGrow.st1.fa53.step (stageFoot_ofRF DEC_clearGrow.st1.fh53 DEC_clearGrow.st1.fb53) (incl_of_footW DEC_clearGrow.st1.fb53 DEC_clearGrow.st1.fc53)

def DEC_clearGrow.st1.fR54 : List (Nat × Nat) := [(3123796, 3123797), (3175541, 3175542), (3175580, 3175582), (3175607, 3175608), (3177221, 3177222), (3177245, 3177255)]
kernel_rfl DEC_clearGrow.st1.fh54 : DEC_clearGrow.st1.s55.heap = setAll DEC_clearGrow.st1.s54.heap (rangesOf DEC_clearGrow.st1.s55.heap DEC_clearGrow.st1.fR54 ++ freshOf DEC_clearGrow.st1.s55.heap DEC_clearGrow.st1.s54.next DEC_clearGrow.st1.s55.next)
kernel_rfl DEC_clearGrow.st1.fb54 : footRB DEC_clearGrow.st1.s54 DEC_clearGrow.st1.s55 DEC_clearGrow.st1.fR54 = true
kernel_rfl DEC_clearGrow.st1.fc54 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s54.next && Nat.ble DEC_clearGrow.st1.s55.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR54 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa55 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s55 :=
  DEC_clearGrow.st1.fa54.step (stageFoot_ofRF DEC_clearGrow.st1.fh54 DEC_clearGrow.st1.fb54) (incl_of_footW DEC_clearGrow.st1.fb54 DEC_clearGrow.st1.fc54)

def DEC_clearGrow.st1.fR55 : List (Nat × Nat) := [(4841, 4842), (2672477, 2672478), (3030094, 3030095), (3030146, 3030147), (3178032, 3178038), (3178171, 3178172), (3178205, 3178206), (3178231, 3178232), (3178242, 3178243), (3178245, 3178246)]
kernel_rfl DEC_clearGrow.st1.fh55 : DEC_clearGrow.st1.s56.heap = setAll DEC_clearGrow.st1.s55.heap (rangesOf DEC_clearGrow.st1.s56.heap DEC_clearGrow.st1.fR55 ++ freshOf DEC_clearGrow.st1.s56.heap DEC_clearGrow.st1.s55.next DEC_clearGrow.st1.s56.next)
kernel_rfl DEC_clearGrow.st1.fb55 : footRB DEC_clearGrow.st1.s55 DEC_clearGrow.st1.s56 DEC_clearGrow.st1.fR55 = true
kernel_rfl DEC_clearGrow.st1.fc55 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s55.next && Nat.ble DEC_clearGrow.st1.s56.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR55 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa56 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s56 :=
  DEC_clearGrow.st1.fa55.step (stageFoot_ofRF DEC_clearGrow.st1.fh55 DEC_clearGrow.st1.fb55) (incl_of_footW DEC_clearGrow.st1.fb55 DEC_clearGrow.st1.fc55)

def DEC_clearGrow.st1.fR56 : List (Nat × Nat) := [(3177972, 3177975), (3178038, 3178045), (3178361, 3178362), (3178771, 3178772), (3178806, 3178807), (3178841, 3178842), (3178866, 3178868), (3179271, 3179275)]
kernel_rfl DEC_clearGrow.st1.fh56 : DEC_clearGrow.st1.s57.heap = setAll DEC_clearGrow.st1.s56.heap (rangesOf DEC_clearGrow.st1.s57.heap DEC_clearGrow.st1.fR56 ++ freshOf DEC_clearGrow.st1.s57.heap DEC_clearGrow.st1.s56.next DEC_clearGrow.st1.s57.next)
kernel_rfl DEC_clearGrow.st1.fb56 : footRB DEC_clearGrow.st1.s56 DEC_clearGrow.st1.s57 DEC_clearGrow.st1.fR56 = true
kernel_rfl DEC_clearGrow.st1.fc56 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s56.next && Nat.ble DEC_clearGrow.st1.s57.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR56 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa57 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s57 :=
  DEC_clearGrow.st1.fa56.step (stageFoot_ofRF DEC_clearGrow.st1.fh56 DEC_clearGrow.st1.fb56) (incl_of_footW DEC_clearGrow.st1.fb56 DEC_clearGrow.st1.fc56)

def DEC_clearGrow.st1.fR57 : List (Nat × Nat) := [(3123796, 3123797), (3177933, 3177934), (3178000, 3178001), (3179589, 3179590), (3179647, 3179648), (3179653, 3179654), (3179659, 3179660), (3179913, 3179914), (3179934, 3179935), (3179984, 3179985), (3180003, 3180004), (3180146, 3180147), (3180224, 3180225)]
kernel_rfl DEC_clearGrow.st1.fh57 : DEC_clearGrow.st1.s58.heap = setAll DEC_clearGrow.st1.s57.heap (rangesOf DEC_clearGrow.st1.s58.heap DEC_clearGrow.st1.fR57 ++ freshOf DEC_clearGrow.st1.s58.heap DEC_clearGrow.st1.s57.next DEC_clearGrow.st1.s58.next)
kernel_rfl DEC_clearGrow.st1.fb57 : footRB DEC_clearGrow.st1.s57 DEC_clearGrow.st1.s58 DEC_clearGrow.st1.fR57 = true
kernel_rfl DEC_clearGrow.st1.fc57 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s57.next && Nat.ble DEC_clearGrow.st1.s58.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR57 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa58 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s58 :=
  DEC_clearGrow.st1.fa57.step (stageFoot_ofRF DEC_clearGrow.st1.fh57 DEC_clearGrow.st1.fb57) (incl_of_footW DEC_clearGrow.st1.fb57 DEC_clearGrow.st1.fc57)

def DEC_clearGrow.st1.fR58 : List (Nat × Nat) := [(2672486, 2672487), (3032200, 3032201), (3032629, 3032630), (3180365, 3180368), (3180413, 3180418), (3180607, 3180608), (3180832, 3180833), (3180918, 3180919), (3181007, 3181008), (3181045, 3181052), (3181092, 3181093), (3181145, 3181146), (3181292, 3181299)]
kernel_rfl DEC_clearGrow.st1.fh58 : DEC_clearGrow.st1.s59.heap = setAll DEC_clearGrow.st1.s58.heap (rangesOf DEC_clearGrow.st1.s59.heap DEC_clearGrow.st1.fR58 ++ freshOf DEC_clearGrow.st1.s59.heap DEC_clearGrow.st1.s58.next DEC_clearGrow.st1.s59.next)
kernel_rfl DEC_clearGrow.st1.fb58 : footRB DEC_clearGrow.st1.s58 DEC_clearGrow.st1.s59 DEC_clearGrow.st1.fR58 = true
kernel_rfl DEC_clearGrow.st1.fc58 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s58.next && Nat.ble DEC_clearGrow.st1.s59.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR58 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa59 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s59 :=
  DEC_clearGrow.st1.fa58.step (stageFoot_ofRF DEC_clearGrow.st1.fh58 DEC_clearGrow.st1.fb58) (incl_of_footW DEC_clearGrow.st1.fb58 DEC_clearGrow.st1.fc58)

def DEC_clearGrow.st1.fR59 : List (Nat × Nat) := [(3123796, 3123797), (3180305, 3180306), (3180393, 3180394), (3182007, 3182008), (3182061, 3182062), (3182067, 3182068), (3182073, 3182074), (3182081, 3182082), (3182094, 3182096), (3182150, 3182151), (3182178, 3182179), (3182181, 3182191), (3182234, 3182235)]
kernel_rfl DEC_clearGrow.st1.fh59 : DEC_clearGrow.st1.s60.heap = setAll DEC_clearGrow.st1.s59.heap (rangesOf DEC_clearGrow.st1.s60.heap DEC_clearGrow.st1.fR59 ++ freshOf DEC_clearGrow.st1.s60.heap DEC_clearGrow.st1.s59.next DEC_clearGrow.st1.s60.next)
kernel_rfl DEC_clearGrow.st1.fb59 : footRB DEC_clearGrow.st1.s59 DEC_clearGrow.st1.s60 DEC_clearGrow.st1.fR59 = true
kernel_rfl DEC_clearGrow.st1.fc59 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s59.next && Nat.ble DEC_clearGrow.st1.s60.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR59 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa60 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s60 :=
  DEC_clearGrow.st1.fa59.step (stageFoot_ofRF DEC_clearGrow.st1.fh59 DEC_clearGrow.st1.fb59) (incl_of_footW DEC_clearGrow.st1.fb59 DEC_clearGrow.st1.fc59)

def DEC_clearGrow.st1.fR60 : List (Nat × Nat) := [(2672491, 2672492), (3034492, 3034493), (3034921, 3034922), (3182802, 3182809), (3182999, 3183000), (3183124, 3183125), (3183137, 3183138), (3183210, 3183211)]
kernel_rfl DEC_clearGrow.st1.fh60 : DEC_clearGrow.st1.s61.heap = setAll DEC_clearGrow.st1.s60.heap (rangesOf DEC_clearGrow.st1.s61.heap DEC_clearGrow.st1.fR60 ++ freshOf DEC_clearGrow.st1.s61.heap DEC_clearGrow.st1.s60.next DEC_clearGrow.st1.s61.next)
kernel_rfl DEC_clearGrow.st1.fb60 : footRB DEC_clearGrow.st1.s60 DEC_clearGrow.st1.s61 DEC_clearGrow.st1.fR60 = true
kernel_rfl DEC_clearGrow.st1.fc60 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s60.next && Nat.ble DEC_clearGrow.st1.s61.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR60 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa61 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s61 :=
  DEC_clearGrow.st1.fa60.step (stageFoot_ofRF DEC_clearGrow.st1.fh60 DEC_clearGrow.st1.fb60) (incl_of_footW DEC_clearGrow.st1.fb60 DEC_clearGrow.st1.fc60)

def DEC_clearGrow.st1.fR61 : List (Nat × Nat) := [(3123796, 3123797), (3182719, 3182720), (3182757, 3182760), (3182785, 3182786), (3182809, 3182810), (3184116, 3184117), (3184141, 3184142), (3184209, 3184210), (3184212, 3184222)]
kernel_rfl DEC_clearGrow.st1.fh61 : DEC_clearGrow.st1.s62.heap = setAll DEC_clearGrow.st1.s61.heap (rangesOf DEC_clearGrow.st1.s62.heap DEC_clearGrow.st1.fR61 ++ freshOf DEC_clearGrow.st1.s62.heap DEC_clearGrow.st1.s61.next DEC_clearGrow.st1.s62.next)
kernel_rfl DEC_clearGrow.st1.fb61 : footRB DEC_clearGrow.st1.s61 DEC_clearGrow.st1.s62 DEC_clearGrow.st1.fR61 = true
kernel_rfl DEC_clearGrow.st1.fc61 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s61.next && Nat.ble DEC_clearGrow.st1.s62.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR61 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa62 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s62 :=
  DEC_clearGrow.st1.fa61.step (stageFoot_ofRF DEC_clearGrow.st1.fh61 DEC_clearGrow.st1.fb61) (incl_of_footW DEC_clearGrow.st1.fb61 DEC_clearGrow.st1.fc61)

def DEC_clearGrow.st1.fR62 : List (Nat × Nat) := [(2672496, 2672497), (3036884, 3036885), (3185092, 3185097), (3185133, 3185134), (3185165, 3185166)]
kernel_rfl DEC_clearGrow.st1.fh62 : DEC_clearGrow.st1.s63.heap = setAll DEC_clearGrow.st1.s62.heap (rangesOf DEC_clearGrow.st1.s63.heap DEC_clearGrow.st1.fR62 ++ freshOf DEC_clearGrow.st1.s63.heap DEC_clearGrow.st1.s62.next DEC_clearGrow.st1.s63.next)
kernel_rfl DEC_clearGrow.st1.fb62 : footRB DEC_clearGrow.st1.s62 DEC_clearGrow.st1.s63 DEC_clearGrow.st1.fR62 = true
kernel_rfl DEC_clearGrow.st1.fc62 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s62.next && Nat.ble DEC_clearGrow.st1.s63.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR62 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa63 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s63 :=
  DEC_clearGrow.st1.fa62.step (stageFoot_ofRF DEC_clearGrow.st1.fh62 DEC_clearGrow.st1.fb62) (incl_of_footW DEC_clearGrow.st1.fb62 DEC_clearGrow.st1.fc62)

def DEC_clearGrow.st1.fR63 : List (Nat × Nat) := [(2672496, 2672497), (3037313, 3037314), (3185049, 3185052), (3185097, 3185102), (3185291, 3185292), (3185516, 3185517), (3185602, 3185603), (3185691, 3185692), (3185734, 3185736), (3186057, 3186058), (3186063, 3186064), (3186069, 3186070), (3186098, 3186100), (3186144, 3186145), (3186188, 3186189), (3186206, 3186212)]
kernel_rfl DEC_clearGrow.st1.fh63 : DEC_clearGrow.st1.s64.heap = setAll DEC_clearGrow.st1.s63.heap (rangesOf DEC_clearGrow.st1.s64.heap DEC_clearGrow.st1.fR63 ++ freshOf DEC_clearGrow.st1.s64.heap DEC_clearGrow.st1.s63.next DEC_clearGrow.st1.s64.next)
kernel_rfl DEC_clearGrow.st1.fb63 : footRB DEC_clearGrow.st1.s63 DEC_clearGrow.st1.s64 DEC_clearGrow.st1.fR63 = true
kernel_rfl DEC_clearGrow.st1.fc63 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s63.next && Nat.ble DEC_clearGrow.st1.s64.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR63 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa64 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s64 :=
  DEC_clearGrow.st1.fa63.step (stageFoot_ofRF DEC_clearGrow.st1.fh63 DEC_clearGrow.st1.fb63) (incl_of_footW DEC_clearGrow.st1.fb63 DEC_clearGrow.st1.fc63)

end Host.Load.Run.Tpl
