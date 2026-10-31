import host.sim.template.a4dec_grow.st1.FootS0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_grow.st1.fR32 : List (Nat × Nat) := [(3123795, 3123796), (3153988, 3153989), (3154026, 3154029), (3154054, 3154055), (3154077, 3154079), (3155452, 3155453), (3155476, 3155479), (3155480, 3155481)]
kernel_rfl DEC_grow.st1.fh32 : DEC_grow.st1.s33.heap = setAll DEC_grow.st1.s32.heap (rangesOf DEC_grow.st1.s33.heap DEC_grow.st1.fR32 ++ freshOf DEC_grow.st1.s33.heap DEC_grow.st1.s32.next DEC_grow.st1.s33.next)
kernel_rfl DEC_grow.st1.fb32 : footRB DEC_grow.st1.s32 DEC_grow.st1.s33 DEC_grow.st1.fR32 = true
kernel_rfl DEC_grow.st1.fc32 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s32.next && Nat.ble DEC_grow.st1.s33.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR32 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa33 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s33 :=
  DEC_grow.st1.fa32.step (stageFoot_ofRF DEC_grow.st1.fh32 DEC_grow.st1.fb32) (incl_of_footW DEC_grow.st1.fb32 DEC_grow.st1.fc32)

def DEC_grow.st1.fR33 : List (Nat × Nat) := [(2672403, 2672404), (3008846, 3008847)]
kernel_rfl DEC_grow.st1.fh33 : DEC_grow.st1.s34.heap = setAll DEC_grow.st1.s33.heap (rangesOf DEC_grow.st1.s34.heap DEC_grow.st1.fR33 ++ freshOf DEC_grow.st1.s34.heap DEC_grow.st1.s33.next DEC_grow.st1.s34.next)
kernel_rfl DEC_grow.st1.fb33 : footRB DEC_grow.st1.s33 DEC_grow.st1.s34 DEC_grow.st1.fR33 = true
kernel_rfl DEC_grow.st1.fc33 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s33.next && Nat.ble DEC_grow.st1.s34.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR33 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa34 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s34 :=
  DEC_grow.st1.fa33.step (stageFoot_ofRF DEC_grow.st1.fh33 DEC_grow.st1.fb33) (incl_of_footW DEC_grow.st1.fb33 DEC_grow.st1.fc33)

def DEC_grow.st1.fR34 : List (Nat × Nat) := [(2672403, 2672404), (3009275, 3009276), (3156422, 3156425), (3156470, 3156475), (3156664, 3156665), (3156889, 3156890), (3156975, 3156976), (3157064, 3157065), (3157107, 3157109), (3157430, 3157431), (3157436, 3157437), (3157442, 3157443), (3157465, 3157473)]
kernel_rfl DEC_grow.st1.fh34 : DEC_grow.st1.s35.heap = setAll DEC_grow.st1.s34.heap (rangesOf DEC_grow.st1.s35.heap DEC_grow.st1.fR34 ++ freshOf DEC_grow.st1.s35.heap DEC_grow.st1.s34.next DEC_grow.st1.s35.next)
kernel_rfl DEC_grow.st1.fb34 : footRB DEC_grow.st1.s34 DEC_grow.st1.s35 DEC_grow.st1.fR34 = true
kernel_rfl DEC_grow.st1.fc34 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s34.next && Nat.ble DEC_grow.st1.s35.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR34 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa35 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s35 :=
  DEC_grow.st1.fa34.step (stageFoot_ofRF DEC_grow.st1.fh34 DEC_grow.st1.fb34) (incl_of_footW DEC_grow.st1.fb34 DEC_grow.st1.fc34)

def DEC_grow.st1.fR35 : List (Nat × Nat) := [(3123795, 3123796), (3156384, 3156385), (3156450, 3156451), (3158064, 3158065), (3158118, 3158119), (3158124, 3158125), (3158130, 3158131), (3158384, 3158385), (3158403, 3158406), (3158408, 3158410)]
kernel_rfl DEC_grow.st1.fh35 : DEC_grow.st1.s36.heap = setAll DEC_grow.st1.s35.heap (rangesOf DEC_grow.st1.s36.heap DEC_grow.st1.fR35 ++ freshOf DEC_grow.st1.s36.heap DEC_grow.st1.s35.next DEC_grow.st1.s36.next)
kernel_rfl DEC_grow.st1.fb35 : footRB DEC_grow.st1.s35 DEC_grow.st1.s36 DEC_grow.st1.fR35 = true
kernel_rfl DEC_grow.st1.fc35 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s35.next && Nat.ble DEC_grow.st1.s36.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR35 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa36 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s36 :=
  DEC_grow.st1.fa35.step (stageFoot_ofRF DEC_grow.st1.fh35 DEC_grow.st1.fb35) (incl_of_footW DEC_grow.st1.fb35 DEC_grow.st1.fc35)

def DEC_grow.st1.fR36 : List (Nat × Nat) := [(4841, 4842), (2672415, 2672416), (3011330, 3011331), (3011382, 3011383), (3158815, 3158816), (3158878, 3158888), (3159109, 3159110), (3159204, 3159205), (3159290, 3159291), (3159379, 3159380), (3159417, 3159418)]
kernel_rfl DEC_grow.st1.fh36 : DEC_grow.st1.s37.heap = setAll DEC_grow.st1.s36.heap (rangesOf DEC_grow.st1.s37.heap DEC_grow.st1.fR36 ++ freshOf DEC_grow.st1.s37.heap DEC_grow.st1.s36.next DEC_grow.st1.s37.next)
kernel_rfl DEC_grow.st1.fb36 : footRB DEC_grow.st1.s36 DEC_grow.st1.s37 DEC_grow.st1.fR36 = true
kernel_rfl DEC_grow.st1.fc36 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s36.next && Nat.ble DEC_grow.st1.s37.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR36 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa37 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s37 :=
  DEC_grow.st1.fa36.step (stageFoot_ofRF DEC_grow.st1.fh36 DEC_grow.st1.fb36) (incl_of_footW DEC_grow.st1.fb36 DEC_grow.st1.fc36)

def DEC_grow.st1.fR37 : List (Nat × Nat) := [(3123795, 3123796), (3158776, 3158777), (3158816, 3158818), (3158843, 3158844), (3160432, 3160433)]
kernel_rfl DEC_grow.st1.fh37 : DEC_grow.st1.s38.heap = setAll DEC_grow.st1.s37.heap (rangesOf DEC_grow.st1.s38.heap DEC_grow.st1.fR37 ++ freshOf DEC_grow.st1.s38.heap DEC_grow.st1.s37.next DEC_grow.st1.s38.next)
kernel_rfl DEC_grow.st1.fb37 : footRB DEC_grow.st1.s37 DEC_grow.st1.s38 DEC_grow.st1.fR37 = true
kernel_rfl DEC_grow.st1.fc37 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s37.next && Nat.ble DEC_grow.st1.s38.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR37 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa38 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s38 :=
  DEC_grow.st1.fa37.step (stageFoot_ofRF DEC_grow.st1.fh37 DEC_grow.st1.fb37) (incl_of_footW DEC_grow.st1.fb37 DEC_grow.st1.fc37)

def DEC_grow.st1.fR38 : List (Nat × Nat) := [(2672424, 2672425), (3013440, 3013441), (3161255, 3161260), (3161296, 3161297), (3161364, 3161365), (3161367, 3161377), (3161425, 3161426)]
kernel_rfl DEC_grow.st1.fh38 : DEC_grow.st1.s39.heap = setAll DEC_grow.st1.s38.heap (rangesOf DEC_grow.st1.s39.heap DEC_grow.st1.fR38 ++ freshOf DEC_grow.st1.s39.heap DEC_grow.st1.s38.next DEC_grow.st1.s39.next)
kernel_rfl DEC_grow.st1.fb38 : footRB DEC_grow.st1.s38 DEC_grow.st1.s39 DEC_grow.st1.fR38 = true
kernel_rfl DEC_grow.st1.fc38 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s38.next && Nat.ble DEC_grow.st1.s39.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR38 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa39 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s39 :=
  DEC_grow.st1.fa38.step (stageFoot_ofRF DEC_grow.st1.fh38 DEC_grow.st1.fb38) (incl_of_footW DEC_grow.st1.fb38 DEC_grow.st1.fc38)

def DEC_grow.st1.fR39 : List (Nat × Nat) := [(2672424, 2672425), (3013869, 3013870), (3161212, 3161215), (3161260, 3161265), (3161454, 3161455), (3161679, 3161680), (3161765, 3161766), (3161854, 3161855), (3161897, 3161899), (3162220, 3162221), (3162226, 3162227), (3162232, 3162233), (3162261, 3162263), (3162307, 3162308), (3162351, 3162352), (3162373, 3162375), (3162414, 3162415), (3162446, 3162447), (3162449, 3162459), (3162492, 3162493)]
kernel_rfl DEC_grow.st1.fh39 : DEC_grow.st1.s40.heap = setAll DEC_grow.st1.s39.heap (rangesOf DEC_grow.st1.s40.heap DEC_grow.st1.fR39 ++ freshOf DEC_grow.st1.s40.heap DEC_grow.st1.s39.next DEC_grow.st1.s40.next)
kernel_rfl DEC_grow.st1.fb39 : footRB DEC_grow.st1.s39 DEC_grow.st1.s40 DEC_grow.st1.fR39 = true
kernel_rfl DEC_grow.st1.fc39 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s39.next && Nat.ble DEC_grow.st1.s40.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR39 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa40 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s40 :=
  DEC_grow.st1.fa39.step (stageFoot_ofRF DEC_grow.st1.fh39 DEC_grow.st1.fb39) (incl_of_footW DEC_grow.st1.fb39 DEC_grow.st1.fc39)

def DEC_grow.st1.fR40 : List (Nat × Nat) := [(3123795, 3123796), (3161152, 3161153), (3161240, 3161241), (3162854, 3162855), (3162908, 3162909), (3162914, 3162915), (3162920, 3162921), (3163174, 3163175), (3163195, 3163196), (3163245, 3163246), (3163267, 3163269), (3163301, 3163302), (3163304, 3163314)]
kernel_rfl DEC_grow.st1.fh40 : DEC_grow.st1.s41.heap = setAll DEC_grow.st1.s40.heap (rangesOf DEC_grow.st1.s41.heap DEC_grow.st1.fR40 ++ freshOf DEC_grow.st1.s41.heap DEC_grow.st1.s40.next DEC_grow.st1.s41.next)
kernel_rfl DEC_grow.st1.fb40 : footRB DEC_grow.st1.s40 DEC_grow.st1.s41 DEC_grow.st1.fR40 = true
kernel_rfl DEC_grow.st1.fc40 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s40.next && Nat.ble DEC_grow.st1.s41.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR40 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa41 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s41 :=
  DEC_grow.st1.fa40.step (stageFoot_ofRF DEC_grow.st1.fh40 DEC_grow.st1.fb40) (incl_of_footW DEC_grow.st1.fb40 DEC_grow.st1.fc40)

def DEC_grow.st1.fR41 : List (Nat × Nat) := [(2672429, 2672430), (3015836, 3015837), (3016265, 3016266), (3163608, 3163611), (3163656, 3163661), (3163850, 3163851), (3164075, 3164076), (3164161, 3164162), (3164250, 3164251), (3164288, 3164295), (3164334, 3164336), (3164388, 3164389), (3164411, 3164414)]
kernel_rfl DEC_grow.st1.fh41 : DEC_grow.st1.s42.heap = setAll DEC_grow.st1.s41.heap (rangesOf DEC_grow.st1.s42.heap DEC_grow.st1.fR41 ++ freshOf DEC_grow.st1.s42.heap DEC_grow.st1.s41.next DEC_grow.st1.s42.next)
kernel_rfl DEC_grow.st1.fb41 : footRB DEC_grow.st1.s41 DEC_grow.st1.s42 DEC_grow.st1.fR41 = true
kernel_rfl DEC_grow.st1.fc41 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s41.next && Nat.ble DEC_grow.st1.s42.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR41 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa42 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s42 :=
  DEC_grow.st1.fa41.step (stageFoot_ofRF DEC_grow.st1.fh41 DEC_grow.st1.fb41) (incl_of_footW DEC_grow.st1.fb41 DEC_grow.st1.fc41)

def DEC_grow.st1.fR42 : List (Nat × Nat) := [(3123795, 3123796), (3163570, 3163571), (3163636, 3163637), (3165250, 3165251), (3165304, 3165305), (3165310, 3165311), (3165316, 3165317), (3165324, 3165325), (3165335, 3165339)]
kernel_rfl DEC_grow.st1.fh42 : DEC_grow.st1.s43.heap = setAll DEC_grow.st1.s42.heap (rangesOf DEC_grow.st1.s43.heap DEC_grow.st1.fR42 ++ freshOf DEC_grow.st1.s43.heap DEC_grow.st1.s42.next DEC_grow.st1.s43.next)
kernel_rfl DEC_grow.st1.fb42 : footRB DEC_grow.st1.s42 DEC_grow.st1.s43 DEC_grow.st1.fR42 = true
kernel_rfl DEC_grow.st1.fc42 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s42.next && Nat.ble DEC_grow.st1.s43.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR42 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa43 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s43 :=
  DEC_grow.st1.fa42.step (stageFoot_ofRF DEC_grow.st1.fh42 DEC_grow.st1.fb42) (incl_of_footW DEC_grow.st1.fb42 DEC_grow.st1.fc42)

def DEC_grow.st1.fR43 : List (Nat × Nat) := [(2672434, 2672435), (3018232, 3018233), (3166048, 3166052), (3166277, 3166278), (3166345, 3166346), (3166348, 3166358)]
kernel_rfl DEC_grow.st1.fh43 : DEC_grow.st1.s44.heap = setAll DEC_grow.st1.s43.heap (rangesOf DEC_grow.st1.s44.heap DEC_grow.st1.fR43 ++ freshOf DEC_grow.st1.s44.heap DEC_grow.st1.s43.next DEC_grow.st1.s44.next)
kernel_rfl DEC_grow.st1.fb43 : footRB DEC_grow.st1.s43 DEC_grow.st1.s44 DEC_grow.st1.fR43 = true
kernel_rfl DEC_grow.st1.fc43 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s43.next && Nat.ble DEC_grow.st1.s44.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR43 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa44 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s44 :=
  DEC_grow.st1.fa43.step (stageFoot_ofRF DEC_grow.st1.fh43 DEC_grow.st1.fb43) (incl_of_footW DEC_grow.st1.fb43 DEC_grow.st1.fc43)

def DEC_grow.st1.fR44 : List (Nat × Nat) := [(2672434, 2672435), (3018661, 3018662), (3166004, 3166007), (3166052, 3166057), (3166246, 3166247), (3166471, 3166472), (3166557, 3166558), (3166646, 3166647), (3167018, 3167019), (3167024, 3167025), (3167344, 3167345)]
kernel_rfl DEC_grow.st1.fh44 : DEC_grow.st1.s45.heap = setAll DEC_grow.st1.s44.heap (rangesOf DEC_grow.st1.s45.heap DEC_grow.st1.fR44 ++ freshOf DEC_grow.st1.s45.heap DEC_grow.st1.s44.next DEC_grow.st1.s45.next)
kernel_rfl DEC_grow.st1.fb44 : footRB DEC_grow.st1.s44 DEC_grow.st1.s45 DEC_grow.st1.fR44 = true
kernel_rfl DEC_grow.st1.fc44 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s44.next && Nat.ble DEC_grow.st1.s45.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR44 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa45 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s45 :=
  DEC_grow.st1.fa44.step (stageFoot_ofRF DEC_grow.st1.fh44 DEC_grow.st1.fb44) (incl_of_footW DEC_grow.st1.fb44 DEC_grow.st1.fc44)

def DEC_grow.st1.fR45 : List (Nat × Nat) := [(4841, 4842), (3123795, 3123796), (3165966, 3165967), (3166032, 3166033), (3167646, 3167647), (3167700, 3167701), (3167706, 3167707), (3167712, 3167713), (3167966, 3167967), (3167987, 3167988), (3168037, 3168038), (3168060, 3168061), (3168203, 3168204), (3168286, 3168287)]
kernel_rfl DEC_grow.st1.fh45 : DEC_grow.st1.s46.heap = setAll DEC_grow.st1.s45.heap (rangesOf DEC_grow.st1.s46.heap DEC_grow.st1.fR45 ++ freshOf DEC_grow.st1.s46.heap DEC_grow.st1.s45.next DEC_grow.st1.s46.next)
kernel_rfl DEC_grow.st1.fb45 : footRB DEC_grow.st1.s45 DEC_grow.st1.s46 DEC_grow.st1.fR45 = true
kernel_rfl DEC_grow.st1.fc45 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s45.next && Nat.ble DEC_grow.st1.s46.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR45 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa46 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s46 :=
  DEC_grow.st1.fa45.step (stageFoot_ofRF DEC_grow.st1.fh45 DEC_grow.st1.fb45) (incl_of_footW DEC_grow.st1.fb45 DEC_grow.st1.fc45)

def DEC_grow.st1.fR46 : List (Nat × Nat) := [(2672446, 2672447), (3020720, 3020721), (3020772, 3020773), (3168401, 3168404), (3168467, 3168474), (3168790, 3168791), (3169200, 3169201), (3169235, 3169236), (3169270, 3169271), (3169295, 3169297), (3169303, 3169310), (3169339, 3169343), (3169359, 3169360)]
kernel_rfl DEC_grow.st1.fh46 : DEC_grow.st1.s47.heap = setAll DEC_grow.st1.s46.heap (rangesOf DEC_grow.st1.s47.heap DEC_grow.st1.fR46 ++ freshOf DEC_grow.st1.s47.heap DEC_grow.st1.s46.next DEC_grow.st1.s47.next)
kernel_rfl DEC_grow.st1.fb46 : footRB DEC_grow.st1.s46 DEC_grow.st1.s47 DEC_grow.st1.fR46 = true
kernel_rfl DEC_grow.st1.fc46 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s46.next && Nat.ble DEC_grow.st1.s47.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR46 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa47 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s47 :=
  DEC_grow.st1.fa46.step (stageFoot_ofRF DEC_grow.st1.fh46 DEC_grow.st1.fb46) (incl_of_footW DEC_grow.st1.fb46 DEC_grow.st1.fc46)

def DEC_grow.st1.fR47 : List (Nat × Nat) := [(3123795, 3123796), (3168362, 3168363), (3168429, 3168430), (3170018, 3170019), (3170076, 3170077), (3170082, 3170083), (3170088, 3170089), (3170096, 3170097), (3170110, 3170111), (3170311, 3170312), (3170334, 3170336), (3170337, 3170338)]
kernel_rfl DEC_grow.st1.fh47 : DEC_grow.st1.s48.heap = setAll DEC_grow.st1.s47.heap (rangesOf DEC_grow.st1.s48.heap DEC_grow.st1.fR47 ++ freshOf DEC_grow.st1.s48.heap DEC_grow.st1.s47.next DEC_grow.st1.s48.next)
kernel_rfl DEC_grow.st1.fb47 : footRB DEC_grow.st1.s47 DEC_grow.st1.s48 DEC_grow.st1.fR47 = true
kernel_rfl DEC_grow.st1.fc47 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s47.next && Nat.ble DEC_grow.st1.s48.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR47 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa48 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s48 :=
  DEC_grow.st1.fa47.step (stageFoot_ofRF DEC_grow.st1.fh47 DEC_grow.st1.fb47) (incl_of_footW DEC_grow.st1.fb47 DEC_grow.st1.fc47)

def DEC_grow.st1.fR48 : List (Nat × Nat) := [(2672455, 2672456), (3022826, 3022827), (3023255, 3023256), (3170839, 3170846), (3171036, 3171037), (3171261, 3171262), (3171274, 3171275), (3171326, 3171328), (3171329, 3171330)]
kernel_rfl DEC_grow.st1.fh48 : DEC_grow.st1.s49.heap = setAll DEC_grow.st1.s48.heap (rangesOf DEC_grow.st1.s49.heap DEC_grow.st1.fR48 ++ freshOf DEC_grow.st1.s49.heap DEC_grow.st1.s48.next DEC_grow.st1.s49.next)
kernel_rfl DEC_grow.st1.fb48 : footRB DEC_grow.st1.s48 DEC_grow.st1.s49 DEC_grow.st1.fR48 = true
kernel_rfl DEC_grow.st1.fc48 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s48.next && Nat.ble DEC_grow.st1.s49.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR48 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa49 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s49 :=
  DEC_grow.st1.fa48.step (stageFoot_ofRF DEC_grow.st1.fh48 DEC_grow.st1.fb48) (incl_of_footW DEC_grow.st1.fb48 DEC_grow.st1.fc48)

def DEC_grow.st1.fR49 : List (Nat × Nat) := [(3123795, 3123796), (3170734, 3170735), (3170794, 3170797), (3170822, 3170823), (3170846, 3170847), (3172253, 3172254), (3172278, 3172279), (3172344, 3172346)]
kernel_rfl DEC_grow.st1.fh49 : DEC_grow.st1.s50.heap = setAll DEC_grow.st1.s49.heap (rangesOf DEC_grow.st1.s50.heap DEC_grow.st1.fR49 ++ freshOf DEC_grow.st1.s50.heap DEC_grow.st1.s49.next DEC_grow.st1.s50.next)
kernel_rfl DEC_grow.st1.fb49 : footRB DEC_grow.st1.s49 DEC_grow.st1.s50 DEC_grow.st1.fR49 = true
kernel_rfl DEC_grow.st1.fc49 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s49.next && Nat.ble DEC_grow.st1.s50.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR49 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa50 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s50 :=
  DEC_grow.st1.fa49.step (stageFoot_ofRF DEC_grow.st1.fh49 DEC_grow.st1.fb49) (incl_of_footW DEC_grow.st1.fb49 DEC_grow.st1.fc49)

def DEC_grow.st1.fR50 : List (Nat × Nat) := [(2672460, 2672461), (3025218, 3025219), (3173229, 3173234), (3173270, 3173271)]
kernel_rfl DEC_grow.st1.fh50 : DEC_grow.st1.s51.heap = setAll DEC_grow.st1.s50.heap (rangesOf DEC_grow.st1.s51.heap DEC_grow.st1.fR50 ++ freshOf DEC_grow.st1.s51.heap DEC_grow.st1.s50.next DEC_grow.st1.s51.next)
kernel_rfl DEC_grow.st1.fb50 : footRB DEC_grow.st1.s50 DEC_grow.st1.s51 DEC_grow.st1.fR50 = true
kernel_rfl DEC_grow.st1.fc50 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s50.next && Nat.ble DEC_grow.st1.s51.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR50 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa51 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s51 :=
  DEC_grow.st1.fa50.step (stageFoot_ofRF DEC_grow.st1.fh50 DEC_grow.st1.fb50) (incl_of_footW DEC_grow.st1.fb50 DEC_grow.st1.fc50)

def DEC_grow.st1.fR51 : List (Nat × Nat) := [(2672460, 2672461), (3025647, 3025648), (3173186, 3173189), (3173234, 3173239), (3173428, 3173429), (3173653, 3173654), (3173739, 3173740), (3173828, 3173829), (3173871, 3173873), (3174194, 3174195), (3174200, 3174201), (3174206, 3174207), (3174235, 3174237), (3174281, 3174282), (3174325, 3174326), (3174339, 3174349), (3174351, 3174353)]
kernel_rfl DEC_grow.st1.fh51 : DEC_grow.st1.s52.heap = setAll DEC_grow.st1.s51.heap (rangesOf DEC_grow.st1.s52.heap DEC_grow.st1.fR51 ++ freshOf DEC_grow.st1.s52.heap DEC_grow.st1.s51.next DEC_grow.st1.s52.next)
kernel_rfl DEC_grow.st1.fb51 : footRB DEC_grow.st1.s51 DEC_grow.st1.s52 DEC_grow.st1.fR51 = true
kernel_rfl DEC_grow.st1.fc51 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s51.next && Nat.ble DEC_grow.st1.s52.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR51 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa52 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s52 :=
  DEC_grow.st1.fa51.step (stageFoot_ofRF DEC_grow.st1.fh51 DEC_grow.st1.fb51) (incl_of_footW DEC_grow.st1.fb51 DEC_grow.st1.fc51)

def DEC_grow.st1.fR52 : List (Nat × Nat) := [(3123795, 3123796), (3173148, 3173149), (3173214, 3173215), (3174828, 3174829), (3174882, 3174883), (3174888, 3174889), (3174894, 3174895), (3175148, 3175149), (3175169, 3175170), (3175219, 3175220), (3175237, 3175239), (3175268, 3175269)]
kernel_rfl DEC_grow.st1.fh52 : DEC_grow.st1.s53.heap = setAll DEC_grow.st1.s52.heap (rangesOf DEC_grow.st1.s53.heap DEC_grow.st1.fR52 ++ freshOf DEC_grow.st1.s53.heap DEC_grow.st1.s52.next DEC_grow.st1.s53.next)
kernel_rfl DEC_grow.st1.fb52 : footRB DEC_grow.st1.s52 DEC_grow.st1.s53 DEC_grow.st1.fR52 = true
kernel_rfl DEC_grow.st1.fc52 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s52.next && Nat.ble DEC_grow.st1.s53.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR52 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa53 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s53 :=
  DEC_grow.st1.fa52.step (stageFoot_ofRF DEC_grow.st1.fh52 DEC_grow.st1.fb52) (incl_of_footW DEC_grow.st1.fb52 DEC_grow.st1.fc52)

def DEC_grow.st1.fR53 : List (Nat × Nat) := [(2672465, 2672466), (3027610, 3027611), (3028039, 3028040), (3175578, 3175579), (3175626, 3175631), (3175820, 3175821), (3176045, 3176046), (3176131, 3176132), (3176220, 3176221), (3176254, 3176265), (3176280, 3176282)]
kernel_rfl DEC_grow.st1.fh53 : DEC_grow.st1.s54.heap = setAll DEC_grow.st1.s53.heap (rangesOf DEC_grow.st1.s54.heap DEC_grow.st1.fR53 ++ freshOf DEC_grow.st1.s54.heap DEC_grow.st1.s53.next DEC_grow.st1.s54.next)
kernel_rfl DEC_grow.st1.fb53 : footRB DEC_grow.st1.s53 DEC_grow.st1.s54 DEC_grow.st1.fR53 = true
kernel_rfl DEC_grow.st1.fc53 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s53.next && Nat.ble DEC_grow.st1.s54.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR53 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa54 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s54 :=
  DEC_grow.st1.fa53.step (stageFoot_ofRF DEC_grow.st1.fh53 DEC_grow.st1.fb53) (incl_of_footW DEC_grow.st1.fb53 DEC_grow.st1.fc53)

def DEC_grow.st1.fR54 : List (Nat × Nat) := [(3123795, 3123796), (3175540, 3175541), (3175579, 3175581), (3175606, 3175607), (3177220, 3177221), (3177244, 3177254)]
kernel_rfl DEC_grow.st1.fh54 : DEC_grow.st1.s55.heap = setAll DEC_grow.st1.s54.heap (rangesOf DEC_grow.st1.s55.heap DEC_grow.st1.fR54 ++ freshOf DEC_grow.st1.s55.heap DEC_grow.st1.s54.next DEC_grow.st1.s55.next)
kernel_rfl DEC_grow.st1.fb54 : footRB DEC_grow.st1.s54 DEC_grow.st1.s55 DEC_grow.st1.fR54 = true
kernel_rfl DEC_grow.st1.fc54 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s54.next && Nat.ble DEC_grow.st1.s55.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR54 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa55 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s55 :=
  DEC_grow.st1.fa54.step (stageFoot_ofRF DEC_grow.st1.fh54 DEC_grow.st1.fb54) (incl_of_footW DEC_grow.st1.fb54 DEC_grow.st1.fc54)

def DEC_grow.st1.fR55 : List (Nat × Nat) := [(4841, 4842), (2672477, 2672478), (3030094, 3030095), (3030146, 3030147), (3178031, 3178037), (3178170, 3178171), (3178204, 3178205), (3178230, 3178231), (3178241, 3178242), (3178244, 3178245)]
kernel_rfl DEC_grow.st1.fh55 : DEC_grow.st1.s56.heap = setAll DEC_grow.st1.s55.heap (rangesOf DEC_grow.st1.s56.heap DEC_grow.st1.fR55 ++ freshOf DEC_grow.st1.s56.heap DEC_grow.st1.s55.next DEC_grow.st1.s56.next)
kernel_rfl DEC_grow.st1.fb55 : footRB DEC_grow.st1.s55 DEC_grow.st1.s56 DEC_grow.st1.fR55 = true
kernel_rfl DEC_grow.st1.fc55 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s55.next && Nat.ble DEC_grow.st1.s56.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR55 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa56 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s56 :=
  DEC_grow.st1.fa55.step (stageFoot_ofRF DEC_grow.st1.fh55 DEC_grow.st1.fb55) (incl_of_footW DEC_grow.st1.fb55 DEC_grow.st1.fc55)

def DEC_grow.st1.fR56 : List (Nat × Nat) := [(3177971, 3177974), (3178037, 3178044), (3178360, 3178361), (3178770, 3178771), (3178805, 3178806), (3178840, 3178841), (3178865, 3178867), (3179270, 3179274)]
kernel_rfl DEC_grow.st1.fh56 : DEC_grow.st1.s57.heap = setAll DEC_grow.st1.s56.heap (rangesOf DEC_grow.st1.s57.heap DEC_grow.st1.fR56 ++ freshOf DEC_grow.st1.s57.heap DEC_grow.st1.s56.next DEC_grow.st1.s57.next)
kernel_rfl DEC_grow.st1.fb56 : footRB DEC_grow.st1.s56 DEC_grow.st1.s57 DEC_grow.st1.fR56 = true
kernel_rfl DEC_grow.st1.fc56 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s56.next && Nat.ble DEC_grow.st1.s57.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR56 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa57 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s57 :=
  DEC_grow.st1.fa56.step (stageFoot_ofRF DEC_grow.st1.fh56 DEC_grow.st1.fb56) (incl_of_footW DEC_grow.st1.fb56 DEC_grow.st1.fc56)

def DEC_grow.st1.fR57 : List (Nat × Nat) := [(3123795, 3123796), (3177932, 3177933), (3177999, 3178000), (3179588, 3179589), (3179646, 3179647), (3179652, 3179653), (3179658, 3179659), (3179912, 3179913), (3179933, 3179934), (3179983, 3179984), (3180002, 3180003), (3180145, 3180146), (3180223, 3180224)]
kernel_rfl DEC_grow.st1.fh57 : DEC_grow.st1.s58.heap = setAll DEC_grow.st1.s57.heap (rangesOf DEC_grow.st1.s58.heap DEC_grow.st1.fR57 ++ freshOf DEC_grow.st1.s58.heap DEC_grow.st1.s57.next DEC_grow.st1.s58.next)
kernel_rfl DEC_grow.st1.fb57 : footRB DEC_grow.st1.s57 DEC_grow.st1.s58 DEC_grow.st1.fR57 = true
kernel_rfl DEC_grow.st1.fc57 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s57.next && Nat.ble DEC_grow.st1.s58.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR57 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa58 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s58 :=
  DEC_grow.st1.fa57.step (stageFoot_ofRF DEC_grow.st1.fh57 DEC_grow.st1.fb57) (incl_of_footW DEC_grow.st1.fb57 DEC_grow.st1.fc57)

def DEC_grow.st1.fR58 : List (Nat × Nat) := [(2672486, 2672487), (3032200, 3032201), (3032629, 3032630), (3180364, 3180367), (3180412, 3180417), (3180606, 3180607), (3180831, 3180832), (3180917, 3180918), (3181006, 3181007), (3181044, 3181051), (3181091, 3181092), (3181144, 3181145), (3181291, 3181298)]
kernel_rfl DEC_grow.st1.fh58 : DEC_grow.st1.s59.heap = setAll DEC_grow.st1.s58.heap (rangesOf DEC_grow.st1.s59.heap DEC_grow.st1.fR58 ++ freshOf DEC_grow.st1.s59.heap DEC_grow.st1.s58.next DEC_grow.st1.s59.next)
kernel_rfl DEC_grow.st1.fb58 : footRB DEC_grow.st1.s58 DEC_grow.st1.s59 DEC_grow.st1.fR58 = true
kernel_rfl DEC_grow.st1.fc58 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s58.next && Nat.ble DEC_grow.st1.s59.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR58 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa59 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s59 :=
  DEC_grow.st1.fa58.step (stageFoot_ofRF DEC_grow.st1.fh58 DEC_grow.st1.fb58) (incl_of_footW DEC_grow.st1.fb58 DEC_grow.st1.fc58)

def DEC_grow.st1.fR59 : List (Nat × Nat) := [(3123795, 3123796), (3180304, 3180305), (3180392, 3180393), (3182006, 3182007), (3182060, 3182061), (3182066, 3182067), (3182072, 3182073), (3182080, 3182081), (3182093, 3182095), (3182149, 3182150), (3182177, 3182178), (3182180, 3182190), (3182233, 3182234)]
kernel_rfl DEC_grow.st1.fh59 : DEC_grow.st1.s60.heap = setAll DEC_grow.st1.s59.heap (rangesOf DEC_grow.st1.s60.heap DEC_grow.st1.fR59 ++ freshOf DEC_grow.st1.s60.heap DEC_grow.st1.s59.next DEC_grow.st1.s60.next)
kernel_rfl DEC_grow.st1.fb59 : footRB DEC_grow.st1.s59 DEC_grow.st1.s60 DEC_grow.st1.fR59 = true
kernel_rfl DEC_grow.st1.fc59 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s59.next && Nat.ble DEC_grow.st1.s60.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR59 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa60 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s60 :=
  DEC_grow.st1.fa59.step (stageFoot_ofRF DEC_grow.st1.fh59 DEC_grow.st1.fb59) (incl_of_footW DEC_grow.st1.fb59 DEC_grow.st1.fc59)

def DEC_grow.st1.fR60 : List (Nat × Nat) := [(2672491, 2672492), (3034492, 3034493), (3034921, 3034922), (3182801, 3182808), (3182998, 3182999), (3183123, 3183124), (3183136, 3183137), (3183209, 3183210)]
kernel_rfl DEC_grow.st1.fh60 : DEC_grow.st1.s61.heap = setAll DEC_grow.st1.s60.heap (rangesOf DEC_grow.st1.s61.heap DEC_grow.st1.fR60 ++ freshOf DEC_grow.st1.s61.heap DEC_grow.st1.s60.next DEC_grow.st1.s61.next)
kernel_rfl DEC_grow.st1.fb60 : footRB DEC_grow.st1.s60 DEC_grow.st1.s61 DEC_grow.st1.fR60 = true
kernel_rfl DEC_grow.st1.fc60 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s60.next && Nat.ble DEC_grow.st1.s61.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR60 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa61 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s61 :=
  DEC_grow.st1.fa60.step (stageFoot_ofRF DEC_grow.st1.fh60 DEC_grow.st1.fb60) (incl_of_footW DEC_grow.st1.fb60 DEC_grow.st1.fc60)

def DEC_grow.st1.fR61 : List (Nat × Nat) := [(3123795, 3123796), (3182718, 3182719), (3182756, 3182759), (3182784, 3182785), (3182808, 3182809), (3184115, 3184116), (3184140, 3184141), (3184208, 3184209), (3184211, 3184221)]
kernel_rfl DEC_grow.st1.fh61 : DEC_grow.st1.s62.heap = setAll DEC_grow.st1.s61.heap (rangesOf DEC_grow.st1.s62.heap DEC_grow.st1.fR61 ++ freshOf DEC_grow.st1.s62.heap DEC_grow.st1.s61.next DEC_grow.st1.s62.next)
kernel_rfl DEC_grow.st1.fb61 : footRB DEC_grow.st1.s61 DEC_grow.st1.s62 DEC_grow.st1.fR61 = true
kernel_rfl DEC_grow.st1.fc61 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s61.next && Nat.ble DEC_grow.st1.s62.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR61 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa62 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s62 :=
  DEC_grow.st1.fa61.step (stageFoot_ofRF DEC_grow.st1.fh61 DEC_grow.st1.fb61) (incl_of_footW DEC_grow.st1.fb61 DEC_grow.st1.fc61)

def DEC_grow.st1.fR62 : List (Nat × Nat) := [(2672496, 2672497), (3036884, 3036885), (3185091, 3185096), (3185132, 3185133), (3185164, 3185165)]
kernel_rfl DEC_grow.st1.fh62 : DEC_grow.st1.s63.heap = setAll DEC_grow.st1.s62.heap (rangesOf DEC_grow.st1.s63.heap DEC_grow.st1.fR62 ++ freshOf DEC_grow.st1.s63.heap DEC_grow.st1.s62.next DEC_grow.st1.s63.next)
kernel_rfl DEC_grow.st1.fb62 : footRB DEC_grow.st1.s62 DEC_grow.st1.s63 DEC_grow.st1.fR62 = true
kernel_rfl DEC_grow.st1.fc62 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s62.next && Nat.ble DEC_grow.st1.s63.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR62 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa63 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s63 :=
  DEC_grow.st1.fa62.step (stageFoot_ofRF DEC_grow.st1.fh62 DEC_grow.st1.fb62) (incl_of_footW DEC_grow.st1.fb62 DEC_grow.st1.fc62)

def DEC_grow.st1.fR63 : List (Nat × Nat) := [(2672496, 2672497), (3037313, 3037314), (3185048, 3185051), (3185096, 3185101), (3185290, 3185291), (3185515, 3185516), (3185601, 3185602), (3185690, 3185691), (3185733, 3185735), (3186056, 3186057), (3186062, 3186063), (3186068, 3186069), (3186097, 3186099), (3186143, 3186144), (3186187, 3186188), (3186205, 3186211)]
kernel_rfl DEC_grow.st1.fh63 : DEC_grow.st1.s64.heap = setAll DEC_grow.st1.s63.heap (rangesOf DEC_grow.st1.s64.heap DEC_grow.st1.fR63 ++ freshOf DEC_grow.st1.s64.heap DEC_grow.st1.s63.next DEC_grow.st1.s64.next)
kernel_rfl DEC_grow.st1.fb63 : footRB DEC_grow.st1.s63 DEC_grow.st1.s64 DEC_grow.st1.fR63 = true
kernel_rfl DEC_grow.st1.fc63 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s63.next && Nat.ble DEC_grow.st1.s64.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR63 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa64 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s64 :=
  DEC_grow.st1.fa63.step (stageFoot_ofRF DEC_grow.st1.fh63 DEC_grow.st1.fb63) (incl_of_footW DEC_grow.st1.fb63 DEC_grow.st1.fc63)

end Host.Load.Run.Tpl
