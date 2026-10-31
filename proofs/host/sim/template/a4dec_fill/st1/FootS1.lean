import host.sim.template.a4dec_fill.st1.FootS0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_fill.st1.fR32 : List (Nat × Nat) := [(3123795, 3123796), (3153400, 3153401), (3153466, 3153467), (3155080, 3155081), (3155134, 3155135), (3155140, 3155141), (3155146, 3155147), (3155400, 3155401)]
kernel_rfl DEC_fill.st1.fh32 : DEC_fill.st1.s33.heap = setAll DEC_fill.st1.s32.heap (rangesOf DEC_fill.st1.s33.heap DEC_fill.st1.fR32 ++ freshOf DEC_fill.st1.s33.heap DEC_fill.st1.s32.next DEC_fill.st1.s33.next)
kernel_rfl DEC_fill.st1.fb32 : footRB DEC_fill.st1.s32 DEC_fill.st1.s33 DEC_fill.st1.fR32 = true
kernel_rfl DEC_fill.st1.fc32 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s32.next && Nat.ble DEC_fill.st1.s33.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR32 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa33 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s33 :=
  DEC_fill.st1.fa32.step (stageFoot_ofRF DEC_fill.st1.fh32 DEC_fill.st1.fb32) (incl_of_footW DEC_fill.st1.fb32 DEC_fill.st1.fc32)

def DEC_fill.st1.fR33 : List (Nat × Nat) := [(2672403, 2672404), (3008846, 3008847), (3009275, 3009276), (3155880, 3155886), (3156076, 3156077), (3156301, 3156302), (3156387, 3156388), (3156403, 3156404)]
kernel_rfl DEC_fill.st1.fh33 : DEC_fill.st1.s34.heap = setAll DEC_fill.st1.s33.heap (rangesOf DEC_fill.st1.s34.heap DEC_fill.st1.fR33 ++ freshOf DEC_fill.st1.s34.heap DEC_fill.st1.s33.next DEC_fill.st1.s34.next)
kernel_rfl DEC_fill.st1.fb33 : footRB DEC_fill.st1.s33 DEC_fill.st1.s34 DEC_fill.st1.fR33 = true
kernel_rfl DEC_fill.st1.fc33 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s33.next && Nat.ble DEC_fill.st1.s34.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR33 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa34 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s34 :=
  DEC_fill.st1.fa33.step (stageFoot_ofRF DEC_fill.st1.fh33 DEC_fill.st1.fb33) (incl_of_footW DEC_fill.st1.fb33 DEC_fill.st1.fc33)

def DEC_fill.st1.fR34 : List (Nat × Nat) := [(3123795, 3123796), (3155796, 3155797), (3155834, 3155837), (3155862, 3155863), (3155886, 3155887), (3157293, 3157294), (3157318, 3157319), (3157386, 3157387), (3157389, 3157399)]
kernel_rfl DEC_fill.st1.fh34 : DEC_fill.st1.s35.heap = setAll DEC_fill.st1.s34.heap (rangesOf DEC_fill.st1.s35.heap DEC_fill.st1.fR34 ++ freshOf DEC_fill.st1.s35.heap DEC_fill.st1.s34.next DEC_fill.st1.s35.next)
kernel_rfl DEC_fill.st1.fb34 : footRB DEC_fill.st1.s34 DEC_fill.st1.s35 DEC_fill.st1.fR34 = true
kernel_rfl DEC_fill.st1.fc34 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s34.next && Nat.ble DEC_fill.st1.s35.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR34 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa35 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s35 :=
  DEC_fill.st1.fa34.step (stageFoot_ofRF DEC_fill.st1.fh34 DEC_fill.st1.fb34) (incl_of_footW DEC_fill.st1.fb34 DEC_fill.st1.fc34)

def DEC_fill.st1.fR35 : List (Nat × Nat) := [(4841, 4842), (2672415, 2672416), (3011330, 3011331), (3011382, 3011383), (3158285, 3158295), (3158317, 3158318)]
kernel_rfl DEC_fill.st1.fh35 : DEC_fill.st1.s36.heap = setAll DEC_fill.st1.s35.heap (rangesOf DEC_fill.st1.s36.heap DEC_fill.st1.fR35 ++ freshOf DEC_fill.st1.s36.heap DEC_fill.st1.s35.next DEC_fill.st1.s36.next)
kernel_rfl DEC_fill.st1.fb35 : footRB DEC_fill.st1.s35 DEC_fill.st1.s36 DEC_fill.st1.fR35 = true
kernel_rfl DEC_fill.st1.fc35 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s35.next && Nat.ble DEC_fill.st1.s36.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR35 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa36 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s36 :=
  DEC_fill.st1.fa35.step (stageFoot_ofRF DEC_fill.st1.fh35 DEC_fill.st1.fb35) (incl_of_footW DEC_fill.st1.fb35 DEC_fill.st1.fc35)

def DEC_fill.st1.fR36 : List (Nat × Nat) := [(3158227, 3158230), (3158294, 3158300), (3158616, 3158617), (3159061, 3159062), (3159340, 3159341), (3159389, 3159390)]
kernel_rfl DEC_fill.st1.fh36 : DEC_fill.st1.s37.heap = setAll DEC_fill.st1.s36.heap (rangesOf DEC_fill.st1.s37.heap DEC_fill.st1.fR36 ++ freshOf DEC_fill.st1.s37.heap DEC_fill.st1.s36.next DEC_fill.st1.s37.next)
kernel_rfl DEC_fill.st1.fb36 : footRB DEC_fill.st1.s36 DEC_fill.st1.s37 DEC_fill.st1.fR36 = true
kernel_rfl DEC_fill.st1.fc36 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s36.next && Nat.ble DEC_fill.st1.s37.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR36 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa37 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s37 :=
  DEC_fill.st1.fa36.step (stageFoot_ofRF DEC_fill.st1.fh36 DEC_fill.st1.fb36) (incl_of_footW DEC_fill.st1.fb36 DEC_fill.st1.fc36)

def DEC_fill.st1.fR37 : List (Nat × Nat) := [(2672424, 2672425), (3013440, 3013441), (3123795, 3123796), (3158188, 3158189), (3158255, 3158256), (3159648, 3159649), (3159706, 3159707), (3159712, 3159713), (3160323, 3160324)]
kernel_rfl DEC_fill.st1.fh37 : DEC_fill.st1.s38.heap = setAll DEC_fill.st1.s37.heap (rangesOf DEC_fill.st1.s38.heap DEC_fill.st1.fR37 ++ freshOf DEC_fill.st1.s38.heap DEC_fill.st1.s37.next DEC_fill.st1.s38.next)
kernel_rfl DEC_fill.st1.fb37 : footRB DEC_fill.st1.s37 DEC_fill.st1.s38 DEC_fill.st1.fR37 = true
kernel_rfl DEC_fill.st1.fc37 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s37.next && Nat.ble DEC_fill.st1.s38.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR37 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa38 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s38 :=
  DEC_fill.st1.fa37.step (stageFoot_ofRF DEC_fill.st1.fh37 DEC_fill.st1.fb37) (incl_of_footW DEC_fill.st1.fb37 DEC_fill.st1.fc37)

def DEC_fill.st1.fR38 : List (Nat × Nat) := [(2672424, 2672425), (3013869, 3013870), (3160428, 3160431), (3160476, 3160481), (3160670, 3160671), (3160895, 3160896), (3160981, 3160982), (3161070, 3161071), (3161110, 3161115), (3161379, 3161380), (3161393, 3161396), (3161431, 3161433)]
kernel_rfl DEC_fill.st1.fh38 : DEC_fill.st1.s39.heap = setAll DEC_fill.st1.s38.heap (rangesOf DEC_fill.st1.s39.heap DEC_fill.st1.fR38 ++ freshOf DEC_fill.st1.s39.heap DEC_fill.st1.s38.next DEC_fill.st1.s39.next)
kernel_rfl DEC_fill.st1.fb38 : footRB DEC_fill.st1.s38 DEC_fill.st1.s39 DEC_fill.st1.fR38 = true
kernel_rfl DEC_fill.st1.fc38 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s38.next && Nat.ble DEC_fill.st1.s39.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR38 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa39 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s39 :=
  DEC_fill.st1.fa38.step (stageFoot_ofRF DEC_fill.st1.fh38 DEC_fill.st1.fb38) (incl_of_footW DEC_fill.st1.fb38 DEC_fill.st1.fc38)

def DEC_fill.st1.fR39 : List (Nat × Nat) := [(3123795, 3123796), (3160368, 3160369), (3160456, 3160457), (3162070, 3162071), (3162124, 3162125), (3162130, 3162131), (3162136, 3162137), (3162144, 3162145), (3162157, 3162159), (3162213, 3162214), (3162354, 3162356)]
kernel_rfl DEC_fill.st1.fh39 : DEC_fill.st1.s40.heap = setAll DEC_fill.st1.s39.heap (rangesOf DEC_fill.st1.s40.heap DEC_fill.st1.fR39 ++ freshOf DEC_fill.st1.s40.heap DEC_fill.st1.s39.next DEC_fill.st1.s40.next)
kernel_rfl DEC_fill.st1.fb39 : footRB DEC_fill.st1.s39 DEC_fill.st1.s40 DEC_fill.st1.fR39 = true
kernel_rfl DEC_fill.st1.fc39 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s39.next && Nat.ble DEC_fill.st1.s40.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR39 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa40 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s40 :=
  DEC_fill.st1.fa39.step (stageFoot_ofRF DEC_fill.st1.fh39 DEC_fill.st1.fb39) (incl_of_footW DEC_fill.st1.fb39 DEC_fill.st1.fc39)

def DEC_fill.st1.fR40 : List (Nat × Nat) := [(2672429, 2672430), (3015836, 3015837), (3016265, 3016266), (3162869, 3162876), (3163066, 3163067), (3163291, 3163292), (3163304, 3163305)]
kernel_rfl DEC_fill.st1.fh40 : DEC_fill.st1.s41.heap = setAll DEC_fill.st1.s40.heap (rangesOf DEC_fill.st1.s41.heap DEC_fill.st1.fR40 ++ freshOf DEC_fill.st1.s41.heap DEC_fill.st1.s40.next DEC_fill.st1.s41.next)
kernel_rfl DEC_fill.st1.fb40 : footRB DEC_fill.st1.s40 DEC_fill.st1.s41 DEC_fill.st1.fR40 = true
kernel_rfl DEC_fill.st1.fc40 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s40.next && Nat.ble DEC_fill.st1.s41.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR40 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa41 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s41 :=
  DEC_fill.st1.fa40.step (stageFoot_ofRF DEC_fill.st1.fh40 DEC_fill.st1.fb40) (incl_of_footW DEC_fill.st1.fb40 DEC_fill.st1.fc40)

def DEC_fill.st1.fR41 : List (Nat × Nat) := [(3123795, 3123796), (3162786, 3162787), (3162824, 3162827), (3162852, 3162853), (3162876, 3162877), (3164283, 3164284), (3164308, 3164309), (3164340, 3164342)]
kernel_rfl DEC_fill.st1.fh41 : DEC_fill.st1.s42.heap = setAll DEC_fill.st1.s41.heap (rangesOf DEC_fill.st1.s42.heap DEC_fill.st1.fR41 ++ freshOf DEC_fill.st1.s42.heap DEC_fill.st1.s41.next DEC_fill.st1.s42.next)
kernel_rfl DEC_fill.st1.fb41 : footRB DEC_fill.st1.s41 DEC_fill.st1.s42 DEC_fill.st1.fR41 = true
kernel_rfl DEC_fill.st1.fc41 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s41.next && Nat.ble DEC_fill.st1.s42.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR41 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa42 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s42 :=
  DEC_fill.st1.fa41.step (stageFoot_ofRF DEC_fill.st1.fh41 DEC_fill.st1.fb41) (incl_of_footW DEC_fill.st1.fb41 DEC_fill.st1.fc41)

def DEC_fill.st1.fR42 : List (Nat × Nat) := [(2672434, 2672435), (3018232, 3018233), (3165263, 3165268), (3165301, 3165305)]
kernel_rfl DEC_fill.st1.fh42 : DEC_fill.st1.s43.heap = setAll DEC_fill.st1.s42.heap (rangesOf DEC_fill.st1.s43.heap DEC_fill.st1.fR42 ++ freshOf DEC_fill.st1.s43.heap DEC_fill.st1.s42.next DEC_fill.st1.s43.next)
kernel_rfl DEC_fill.st1.fb42 : footRB DEC_fill.st1.s42 DEC_fill.st1.s43 DEC_fill.st1.fR42 = true
kernel_rfl DEC_fill.st1.fc42 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s42.next && Nat.ble DEC_fill.st1.s43.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR42 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa43 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s43 :=
  DEC_fill.st1.fa42.step (stageFoot_ofRF DEC_fill.st1.fh42 DEC_fill.st1.fb42) (incl_of_footW DEC_fill.st1.fb42 DEC_fill.st1.fc42)

def DEC_fill.st1.fR43 : List (Nat × Nat) := [(2672434, 2672435), (3018661, 3018662), (3165220, 3165223), (3165268, 3165273), (3165462, 3165463), (3165687, 3165688), (3165773, 3165774), (3165862, 3165863), (3165905, 3165907), (3166228, 3166229), (3166234, 3166235), (3166240, 3166241), (3166266, 3166271), (3166315, 3166316), (3166354, 3166356)]
kernel_rfl DEC_fill.st1.fh43 : DEC_fill.st1.s44.heap = setAll DEC_fill.st1.s43.heap (rangesOf DEC_fill.st1.s44.heap DEC_fill.st1.fR43 ++ freshOf DEC_fill.st1.s44.heap DEC_fill.st1.s43.next DEC_fill.st1.s44.next)
kernel_rfl DEC_fill.st1.fb43 : footRB DEC_fill.st1.s43 DEC_fill.st1.s44 DEC_fill.st1.fR43 = true
kernel_rfl DEC_fill.st1.fc43 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s43.next && Nat.ble DEC_fill.st1.s44.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR43 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa44 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s44 :=
  DEC_fill.st1.fa43.step (stageFoot_ofRF DEC_fill.st1.fh43 DEC_fill.st1.fb43) (incl_of_footW DEC_fill.st1.fb43 DEC_fill.st1.fc43)

def DEC_fill.st1.fR44 : List (Nat × Nat) := [(3123795, 3123796), (3165182, 3165183), (3165248, 3165249), (3166862, 3166863), (3166916, 3166917), (3166922, 3166923), (3166928, 3166929), (3167182, 3167183), (3167203, 3167204), (3167253, 3167254), (3167275, 3167277), (3167280, 3167281)]
kernel_rfl DEC_fill.st1.fh44 : DEC_fill.st1.s45.heap = setAll DEC_fill.st1.s44.heap (rangesOf DEC_fill.st1.s45.heap DEC_fill.st1.fR44 ++ freshOf DEC_fill.st1.s45.heap DEC_fill.st1.s44.next DEC_fill.st1.s45.next)
kernel_rfl DEC_fill.st1.fb44 : footRB DEC_fill.st1.s44 DEC_fill.st1.s45 DEC_fill.st1.fR44 = true
kernel_rfl DEC_fill.st1.fc44 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s44.next && Nat.ble DEC_fill.st1.s45.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR44 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa45 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s45 :=
  DEC_fill.st1.fa44.step (stageFoot_ofRF DEC_fill.st1.fh44 DEC_fill.st1.fb44) (incl_of_footW DEC_fill.st1.fb44 DEC_fill.st1.fc44)

def DEC_fill.st1.fR45 : List (Nat × Nat) := [(4841, 4842), (2672446, 2672447), (3020720, 3020721), (3020772, 3020773), (3167617, 3167620), (3167680, 3167690), (3168006, 3168007), (3168181, 3168182), (3168249, 3168250), (3168282, 3168283)]
kernel_rfl DEC_fill.st1.fh45 : DEC_fill.st1.s46.heap = setAll DEC_fill.st1.s45.heap (rangesOf DEC_fill.st1.s46.heap DEC_fill.st1.fR45 ++ freshOf DEC_fill.st1.s46.heap DEC_fill.st1.s45.next DEC_fill.st1.s46.next)
kernel_rfl DEC_fill.st1.fb45 : footRB DEC_fill.st1.s45 DEC_fill.st1.s46 DEC_fill.st1.fR45 = true
kernel_rfl DEC_fill.st1.fc45 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s45.next && Nat.ble DEC_fill.st1.s46.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR45 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa46 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s46 :=
  DEC_fill.st1.fa45.step (stageFoot_ofRF DEC_fill.st1.fh45 DEC_fill.st1.fb45) (incl_of_footW DEC_fill.st1.fb45 DEC_fill.st1.fc45)

def DEC_fill.st1.fR46 : List (Nat × Nat) := [(3123795, 3123796), (3167578, 3167579), (3167645, 3167646), (3169038, 3169039), (3169096, 3169097), (3169102, 3169103), (3169108, 3169109), (3169116, 3169117), (3169129, 3169131), (3169185, 3169186), (3169213, 3169214), (3169216, 3169226), (3169298, 3169299)]
kernel_rfl DEC_fill.st1.fh46 : DEC_fill.st1.s47.heap = setAll DEC_fill.st1.s46.heap (rangesOf DEC_fill.st1.s47.heap DEC_fill.st1.fR46 ++ freshOf DEC_fill.st1.s47.heap DEC_fill.st1.s46.next DEC_fill.st1.s47.next)
kernel_rfl DEC_fill.st1.fb46 : footRB DEC_fill.st1.s46 DEC_fill.st1.s47 DEC_fill.st1.fR46 = true
kernel_rfl DEC_fill.st1.fc46 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s46.next && Nat.ble DEC_fill.st1.s47.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR46 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa47 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s47 :=
  DEC_fill.st1.fa46.step (stageFoot_ofRF DEC_fill.st1.fh46 DEC_fill.st1.fb46) (incl_of_footW DEC_fill.st1.fb46 DEC_fill.st1.fc46)

def DEC_fill.st1.fR47 : List (Nat × Nat) := [(2672455, 2672456), (3022826, 3022827), (3023255, 3023256), (3169858, 3169866), (3170056, 3170057), (3170245, 3170246), (3170273, 3170275)]
kernel_rfl DEC_fill.st1.fh47 : DEC_fill.st1.s48.heap = setAll DEC_fill.st1.s47.heap (rangesOf DEC_fill.st1.s48.heap DEC_fill.st1.fR47 ++ freshOf DEC_fill.st1.s48.heap DEC_fill.st1.s47.next DEC_fill.st1.s48.next)
kernel_rfl DEC_fill.st1.fb47 : footRB DEC_fill.st1.s47 DEC_fill.st1.s48 DEC_fill.st1.fR47 = true
kernel_rfl DEC_fill.st1.fc47 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s47.next && Nat.ble DEC_fill.st1.s48.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR47 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa48 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s48 :=
  DEC_fill.st1.fa47.step (stageFoot_ofRF DEC_fill.st1.fh47 DEC_fill.st1.fb47) (incl_of_footW DEC_fill.st1.fb47 DEC_fill.st1.fc47)

def DEC_fill.st1.fR48 : List (Nat × Nat) := [(3123795, 3123796), (3169754, 3169755), (3169814, 3169817), (3169842, 3169843), (3169866, 3169867), (3171273, 3171274)]
kernel_rfl DEC_fill.st1.fh48 : DEC_fill.st1.s49.heap = setAll DEC_fill.st1.s48.heap (rangesOf DEC_fill.st1.s49.heap DEC_fill.st1.fR48 ++ freshOf DEC_fill.st1.s49.heap DEC_fill.st1.s48.next DEC_fill.st1.s49.next)
kernel_rfl DEC_fill.st1.fb48 : footRB DEC_fill.st1.s48 DEC_fill.st1.s49 DEC_fill.st1.fR48 = true
kernel_rfl DEC_fill.st1.fc48 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s48.next && Nat.ble DEC_fill.st1.s49.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR48 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa49 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s49 :=
  DEC_fill.st1.fa48.step (stageFoot_ofRF DEC_fill.st1.fh48 DEC_fill.st1.fb48) (incl_of_footW DEC_fill.st1.fb48 DEC_fill.st1.fc48)

def DEC_fill.st1.fR49 : List (Nat × Nat) := [(2672460, 2672461), (3025218, 3025219), (3172205, 3172206), (3172225, 3172226)]
kernel_rfl DEC_fill.st1.fh49 : DEC_fill.st1.s50.heap = setAll DEC_fill.st1.s49.heap (rangesOf DEC_fill.st1.s50.heap DEC_fill.st1.fR49 ++ freshOf DEC_fill.st1.s50.heap DEC_fill.st1.s49.next DEC_fill.st1.s50.next)
kernel_rfl DEC_fill.st1.fb49 : footRB DEC_fill.st1.s49 DEC_fill.st1.s50 DEC_fill.st1.fR49 = true
kernel_rfl DEC_fill.st1.fc49 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s49.next && Nat.ble DEC_fill.st1.s50.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR49 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa50 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s50 :=
  DEC_fill.st1.fa49.step (stageFoot_ofRF DEC_fill.st1.fh49 DEC_fill.st1.fb49) (incl_of_footW DEC_fill.st1.fb49 DEC_fill.st1.fc49)

def DEC_fill.st1.fR50 : List (Nat × Nat) := [(2672460, 2672461), (3025647, 3025648), (3172206, 3172209), (3172254, 3172259), (3172448, 3172449), (3172673, 3172674), (3172759, 3172760), (3172848, 3172849), (3172891, 3172893), (3173214, 3173215), (3173220, 3173221), (3173226, 3173227), (3173251, 3173257), (3173293, 3173295)]
kernel_rfl DEC_fill.st1.fh50 : DEC_fill.st1.s51.heap = setAll DEC_fill.st1.s50.heap (rangesOf DEC_fill.st1.s51.heap DEC_fill.st1.fR50 ++ freshOf DEC_fill.st1.s51.heap DEC_fill.st1.s50.next DEC_fill.st1.s51.next)
kernel_rfl DEC_fill.st1.fb50 : footRB DEC_fill.st1.s50 DEC_fill.st1.s51 DEC_fill.st1.fR50 = true
kernel_rfl DEC_fill.st1.fc50 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s50.next && Nat.ble DEC_fill.st1.s51.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR50 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa51 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s51 :=
  DEC_fill.st1.fa50.step (stageFoot_ofRF DEC_fill.st1.fh50 DEC_fill.st1.fb50) (incl_of_footW DEC_fill.st1.fb50 DEC_fill.st1.fc50)

def DEC_fill.st1.fR51 : List (Nat × Nat) := [(3123795, 3123796), (3172168, 3172169), (3172234, 3172235), (3173848, 3173849), (3173902, 3173903), (3173908, 3173909), (3173914, 3173915), (3174168, 3174169), (3174188, 3174190), (3174210, 3174212)]
kernel_rfl DEC_fill.st1.fh51 : DEC_fill.st1.s52.heap = setAll DEC_fill.st1.s51.heap (rangesOf DEC_fill.st1.s52.heap DEC_fill.st1.fR51 ++ freshOf DEC_fill.st1.s52.heap DEC_fill.st1.s51.next DEC_fill.st1.s52.next)
kernel_rfl DEC_fill.st1.fb51 : footRB DEC_fill.st1.s51 DEC_fill.st1.s52 DEC_fill.st1.fR51 = true
kernel_rfl DEC_fill.st1.fc51 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s51.next && Nat.ble DEC_fill.st1.s52.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR51 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa52 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s52 :=
  DEC_fill.st1.fa51.step (stageFoot_ofRF DEC_fill.st1.fh51 DEC_fill.st1.fb51) (incl_of_footW DEC_fill.st1.fb51 DEC_fill.st1.fc51)

def DEC_fill.st1.fR52 : List (Nat × Nat) := [(2672465, 2672466), (3027610, 3027611), (3028039, 3028040), (3174644, 3174650), (3174840, 3174841), (3175065, 3175066), (3175151, 3175152), (3175167, 3175168), (3175217, 3175221)]
kernel_rfl DEC_fill.st1.fh52 : DEC_fill.st1.s53.heap = setAll DEC_fill.st1.s52.heap (rangesOf DEC_fill.st1.s53.heap DEC_fill.st1.fR52 ++ freshOf DEC_fill.st1.s53.heap DEC_fill.st1.s52.next DEC_fill.st1.s53.next)
kernel_rfl DEC_fill.st1.fb52 : footRB DEC_fill.st1.s52 DEC_fill.st1.s53 DEC_fill.st1.fR52 = true
kernel_rfl DEC_fill.st1.fc52 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s52.next && Nat.ble DEC_fill.st1.s53.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR52 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa53 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s53 :=
  DEC_fill.st1.fa52.step (stageFoot_ofRF DEC_fill.st1.fh52 DEC_fill.st1.fb52) (incl_of_footW DEC_fill.st1.fb52 DEC_fill.st1.fc52)

def DEC_fill.st1.fR53 : List (Nat × Nat) := [(3123795, 3123796), (3174560, 3174561), (3174598, 3174601), (3174626, 3174627), (3174650, 3174651), (3176057, 3176058), (3176082, 3176083), (3176150, 3176151), (3176153, 3176163), (3176211, 3176212)]
kernel_rfl DEC_fill.st1.fh53 : DEC_fill.st1.s54.heap = setAll DEC_fill.st1.s53.heap (rangesOf DEC_fill.st1.s54.heap DEC_fill.st1.fR53 ++ freshOf DEC_fill.st1.s54.heap DEC_fill.st1.s53.next DEC_fill.st1.s54.next)
kernel_rfl DEC_fill.st1.fb53 : footRB DEC_fill.st1.s53 DEC_fill.st1.s54 DEC_fill.st1.fR53 = true
kernel_rfl DEC_fill.st1.fc53 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s53.next && Nat.ble DEC_fill.st1.s54.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR53 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa54 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s54 :=
  DEC_fill.st1.fa53.step (stageFoot_ofRF DEC_fill.st1.fh53 DEC_fill.st1.fb53) (incl_of_footW DEC_fill.st1.fb53 DEC_fill.st1.fc53)

def DEC_fill.st1.fR54 : List (Nat × Nat) := [(4841, 4842), (2672477, 2672478), (3030094, 3030095), (3030146, 3030147), (3177050, 3177059), (3177154, 3177155), (3177190, 3177191), (3177194, 3177195)]
kernel_rfl DEC_fill.st1.fh54 : DEC_fill.st1.s55.heap = setAll DEC_fill.st1.s54.heap (rangesOf DEC_fill.st1.s55.heap DEC_fill.st1.fR54 ++ freshOf DEC_fill.st1.s55.heap DEC_fill.st1.s54.next DEC_fill.st1.s55.next)
kernel_rfl DEC_fill.st1.fb54 : footRB DEC_fill.st1.s54 DEC_fill.st1.s55 DEC_fill.st1.fR54 = true
kernel_rfl DEC_fill.st1.fc54 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s54.next && Nat.ble DEC_fill.st1.s55.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR54 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa55 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s55 :=
  DEC_fill.st1.fa54.step (stageFoot_ofRF DEC_fill.st1.fh54 DEC_fill.st1.fb54) (incl_of_footW DEC_fill.st1.fb54 DEC_fill.st1.fc54)

def DEC_fill.st1.fR55 : List (Nat × Nat) := [(3123795, 3123796), (3176952, 3176953), (3176991, 3176994), (3177019, 3177020), (3177059, 3177064), (3177380, 3177381), (3177825, 3177826), (3178104, 3178105), (3178153, 3178154), (3178202, 3178203)]
kernel_rfl DEC_fill.st1.fh55 : DEC_fill.st1.s56.heap = setAll DEC_fill.st1.s55.heap (rangesOf DEC_fill.st1.s56.heap DEC_fill.st1.fR55 ++ freshOf DEC_fill.st1.s56.heap DEC_fill.st1.s55.next DEC_fill.st1.s56.next)
kernel_rfl DEC_fill.st1.fb55 : footRB DEC_fill.st1.s55 DEC_fill.st1.s56 DEC_fill.st1.fR55 = true
kernel_rfl DEC_fill.st1.fc55 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s55.next && Nat.ble DEC_fill.st1.s56.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR55 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa56 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s56 :=
  DEC_fill.st1.fa55.step (stageFoot_ofRF DEC_fill.st1.fh55 DEC_fill.st1.fb55) (incl_of_footW DEC_fill.st1.fb55 DEC_fill.st1.fc55)

def DEC_fill.st1.fR56 : List (Nat × Nat) := [(2672486, 2672487), (3032200, 3032201)]
kernel_rfl DEC_fill.st1.fh56 : DEC_fill.st1.s57.heap = setAll DEC_fill.st1.s56.heap (rangesOf DEC_fill.st1.s57.heap DEC_fill.st1.fR56 ++ freshOf DEC_fill.st1.s57.heap DEC_fill.st1.s56.next DEC_fill.st1.s57.next)
kernel_rfl DEC_fill.st1.fb56 : footRB DEC_fill.st1.s56 DEC_fill.st1.s57 DEC_fill.st1.fR56 = true
kernel_rfl DEC_fill.st1.fc56 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s56.next && Nat.ble DEC_fill.st1.s57.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR56 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa57 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s57 :=
  DEC_fill.st1.fa56.step (stageFoot_ofRF DEC_fill.st1.fh56 DEC_fill.st1.fb56) (incl_of_footW DEC_fill.st1.fb56 DEC_fill.st1.fc56)

def DEC_fill.st1.fR57 : List (Nat × Nat) := [(2672486, 2672487), (3032629, 3032630), (3179188, 3179191), (3179236, 3179241), (3179430, 3179431), (3179655, 3179656), (3179741, 3179742), (3179830, 3179831), (3179873, 3179875), (3180196, 3180197), (3180202, 3180203), (3180208, 3180209)]
kernel_rfl DEC_fill.st1.fh57 : DEC_fill.st1.s58.heap = setAll DEC_fill.st1.s57.heap (rangesOf DEC_fill.st1.s58.heap DEC_fill.st1.fR57 ++ freshOf DEC_fill.st1.s58.heap DEC_fill.st1.s57.next DEC_fill.st1.s58.next)
kernel_rfl DEC_fill.st1.fb57 : footRB DEC_fill.st1.s57 DEC_fill.st1.s58 DEC_fill.st1.fR57 = true
kernel_rfl DEC_fill.st1.fc57 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s57.next && Nat.ble DEC_fill.st1.s58.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR57 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa58 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s58 :=
  DEC_fill.st1.fa57.step (stageFoot_ofRF DEC_fill.st1.fh57 DEC_fill.st1.fb57) (incl_of_footW DEC_fill.st1.fb57 DEC_fill.st1.fc57)

def DEC_fill.st1.fR58 : List (Nat × Nat) := [(3123795, 3123796), (3179128, 3179129), (3179216, 3179217), (3180830, 3180831), (3180884, 3180885), (3180890, 3180891), (3180896, 3180897), (3180904, 3180905), (3180918, 3180919), (3181119, 3181120), (3181150, 3181151)]
kernel_rfl DEC_fill.st1.fh58 : DEC_fill.st1.s59.heap = setAll DEC_fill.st1.s58.heap (rangesOf DEC_fill.st1.s59.heap DEC_fill.st1.fR58 ++ freshOf DEC_fill.st1.s59.heap DEC_fill.st1.s58.next DEC_fill.st1.s59.next)
kernel_rfl DEC_fill.st1.fb58 : footRB DEC_fill.st1.s58 DEC_fill.st1.s59 DEC_fill.st1.fR58 = true
kernel_rfl DEC_fill.st1.fc58 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s58.next && Nat.ble DEC_fill.st1.s59.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR58 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa59 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s59 :=
  DEC_fill.st1.fa58.step (stageFoot_ofRF DEC_fill.st1.fh58 DEC_fill.st1.fb58) (incl_of_footW DEC_fill.st1.fb58 DEC_fill.st1.fc58)

def DEC_fill.st1.fR59 : List (Nat × Nat) := [(2672491, 2672492), (3034492, 3034493), (3034921, 3034922), (3181580, 3181581), (3181628, 3181633), (3181822, 3181823), (3181947, 3181948), (3182033, 3182034), (3182122, 3182123), (3182156, 3182167), (3182182, 3182184)]
kernel_rfl DEC_fill.st1.fh59 : DEC_fill.st1.s60.heap = setAll DEC_fill.st1.s59.heap (rangesOf DEC_fill.st1.s60.heap DEC_fill.st1.fR59 ++ freshOf DEC_fill.st1.s60.heap DEC_fill.st1.s59.next DEC_fill.st1.s60.next)
kernel_rfl DEC_fill.st1.fb59 : footRB DEC_fill.st1.s59 DEC_fill.st1.s60 DEC_fill.st1.fR59 = true
kernel_rfl DEC_fill.st1.fc59 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s59.next && Nat.ble DEC_fill.st1.s60.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR59 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa60 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s60 :=
  DEC_fill.st1.fa59.step (stageFoot_ofRF DEC_fill.st1.fh59 DEC_fill.st1.fb59) (incl_of_footW DEC_fill.st1.fb59 DEC_fill.st1.fc59)

def DEC_fill.st1.fR60 : List (Nat × Nat) := [(3123795, 3123796), (3181542, 3181543), (3181581, 3181583), (3181608, 3181609), (3183122, 3183123), (3183146, 3183156)]
kernel_rfl DEC_fill.st1.fh60 : DEC_fill.st1.s61.heap = setAll DEC_fill.st1.s60.heap (rangesOf DEC_fill.st1.s61.heap DEC_fill.st1.fR60 ++ freshOf DEC_fill.st1.s61.heap DEC_fill.st1.s60.next DEC_fill.st1.s61.next)
kernel_rfl DEC_fill.st1.fb60 : footRB DEC_fill.st1.s60 DEC_fill.st1.s61 DEC_fill.st1.fR60 = true
kernel_rfl DEC_fill.st1.fc60 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s60.next && Nat.ble DEC_fill.st1.s61.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR60 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa61 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s61 :=
  DEC_fill.st1.fa60.step (stageFoot_ofRF DEC_fill.st1.fh60 DEC_fill.st1.fb60) (incl_of_footW DEC_fill.st1.fb60 DEC_fill.st1.fc60)

def DEC_fill.st1.fR61 : List (Nat × Nat) := [(2672496, 2672497), (3036884, 3036885), (3183915, 3183920), (3183956, 3183957), (3184109, 3184110), (3184114, 3184115)]
kernel_rfl DEC_fill.st1.fh61 : DEC_fill.st1.s62.heap = setAll DEC_fill.st1.s61.heap (rangesOf DEC_fill.st1.s62.heap DEC_fill.st1.fR61 ++ freshOf DEC_fill.st1.s62.heap DEC_fill.st1.s61.next DEC_fill.st1.s62.next)
kernel_rfl DEC_fill.st1.fb61 : footRB DEC_fill.st1.s61 DEC_fill.st1.s62 DEC_fill.st1.fR61 = true
kernel_rfl DEC_fill.st1.fc61 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s61.next && Nat.ble DEC_fill.st1.s62.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR61 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa62 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s62 :=
  DEC_fill.st1.fa61.step (stageFoot_ofRF DEC_fill.st1.fh61 DEC_fill.st1.fb61) (incl_of_footW DEC_fill.st1.fb61 DEC_fill.st1.fc61)

def DEC_fill.st1.fR62 : List (Nat × Nat) := [(2672496, 2672497), (3037313, 3037314), (3183872, 3183875), (3183920, 3183925), (3184114, 3184115), (3184339, 3184340), (3184425, 3184426), (3184514, 3184515), (3184557, 3184559), (3184880, 3184881), (3184886, 3184887), (3184892, 3184893), (3184921, 3184923), (3184967, 3184968), (3185011, 3185012), (3185033, 3185035), (3185074, 3185075), (3185106, 3185107), (3185109, 3185119), (3185171, 3185172)]
kernel_rfl DEC_fill.st1.fh62 : DEC_fill.st1.s63.heap = setAll DEC_fill.st1.s62.heap (rangesOf DEC_fill.st1.s63.heap DEC_fill.st1.fR62 ++ freshOf DEC_fill.st1.s63.heap DEC_fill.st1.s62.next DEC_fill.st1.s63.next)
kernel_rfl DEC_fill.st1.fb62 : footRB DEC_fill.st1.s62 DEC_fill.st1.s63 DEC_fill.st1.fR62 = true
kernel_rfl DEC_fill.st1.fc62 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s62.next && Nat.ble DEC_fill.st1.s63.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR62 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa63 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s63 :=
  DEC_fill.st1.fa62.step (stageFoot_ofRF DEC_fill.st1.fh62 DEC_fill.st1.fb62) (incl_of_footW DEC_fill.st1.fb62 DEC_fill.st1.fc62)

def DEC_fill.st1.fR63 : List (Nat × Nat) := [(4841, 4842), (3123795, 3123796), (3183834, 3183835), (3183900, 3183901), (3185514, 3185515), (3185568, 3185569), (3185574, 3185575), (3185580, 3185581), (3185834, 3185835), (3185855, 3185856), (3185905, 3185906), (3185924, 3185925), (3186067, 3186068), (3186074, 3186076)]
kernel_rfl DEC_fill.st1.fh63 : DEC_fill.st1.s64.heap = setAll DEC_fill.st1.s63.heap (rangesOf DEC_fill.st1.s64.heap DEC_fill.st1.fR63 ++ freshOf DEC_fill.st1.s64.heap DEC_fill.st1.s63.next DEC_fill.st1.s64.next)
kernel_rfl DEC_fill.st1.fb63 : footRB DEC_fill.st1.s63 DEC_fill.st1.s64 DEC_fill.st1.fR63 = true
kernel_rfl DEC_fill.st1.fc63 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s63.next && Nat.ble DEC_fill.st1.s64.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR63 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa64 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s64 :=
  DEC_fill.st1.fa63.step (stageFoot_ofRF DEC_fill.st1.fh63 DEC_fill.st1.fb63) (incl_of_footW DEC_fill.st1.fb63 DEC_fill.st1.fc63)

end Host.Load.Run.Tpl
