import host.sim.template.a4dec_clearFill.st1.FootS0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_clearFill.st1.fR32 : List (Nat × Nat) := [(3123796, 3123797), (3153401, 3153402), (3153467, 3153468), (3155081, 3155082), (3155135, 3155136), (3155141, 3155142), (3155147, 3155148), (3155401, 3155402)]
kernel_rfl DEC_clearFill.st1.fh32 : DEC_clearFill.st1.s33.heap = setAll DEC_clearFill.st1.s32.heap (rangesOf DEC_clearFill.st1.s33.heap DEC_clearFill.st1.fR32 ++ freshOf DEC_clearFill.st1.s33.heap DEC_clearFill.st1.s32.next DEC_clearFill.st1.s33.next)
kernel_rfl DEC_clearFill.st1.fb32 : footRB DEC_clearFill.st1.s32 DEC_clearFill.st1.s33 DEC_clearFill.st1.fR32 = true
kernel_rfl DEC_clearFill.st1.fc32 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s32.next && Nat.ble DEC_clearFill.st1.s33.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR32 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa33 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s33 :=
  DEC_clearFill.st1.fa32.step (stageFoot_ofRF DEC_clearFill.st1.fh32 DEC_clearFill.st1.fb32) (incl_of_footW DEC_clearFill.st1.fb32 DEC_clearFill.st1.fc32)

def DEC_clearFill.st1.fR33 : List (Nat × Nat) := [(2672403, 2672404), (3008846, 3008847), (3009275, 3009276), (3155881, 3155887), (3156077, 3156078), (3156302, 3156303), (3156388, 3156389), (3156404, 3156405)]
kernel_rfl DEC_clearFill.st1.fh33 : DEC_clearFill.st1.s34.heap = setAll DEC_clearFill.st1.s33.heap (rangesOf DEC_clearFill.st1.s34.heap DEC_clearFill.st1.fR33 ++ freshOf DEC_clearFill.st1.s34.heap DEC_clearFill.st1.s33.next DEC_clearFill.st1.s34.next)
kernel_rfl DEC_clearFill.st1.fb33 : footRB DEC_clearFill.st1.s33 DEC_clearFill.st1.s34 DEC_clearFill.st1.fR33 = true
kernel_rfl DEC_clearFill.st1.fc33 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s33.next && Nat.ble DEC_clearFill.st1.s34.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR33 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa34 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s34 :=
  DEC_clearFill.st1.fa33.step (stageFoot_ofRF DEC_clearFill.st1.fh33 DEC_clearFill.st1.fb33) (incl_of_footW DEC_clearFill.st1.fb33 DEC_clearFill.st1.fc33)

def DEC_clearFill.st1.fR34 : List (Nat × Nat) := [(3123796, 3123797), (3155797, 3155798), (3155835, 3155838), (3155863, 3155864), (3155887, 3155888), (3157294, 3157295), (3157319, 3157320), (3157387, 3157388), (3157390, 3157400)]
kernel_rfl DEC_clearFill.st1.fh34 : DEC_clearFill.st1.s35.heap = setAll DEC_clearFill.st1.s34.heap (rangesOf DEC_clearFill.st1.s35.heap DEC_clearFill.st1.fR34 ++ freshOf DEC_clearFill.st1.s35.heap DEC_clearFill.st1.s34.next DEC_clearFill.st1.s35.next)
kernel_rfl DEC_clearFill.st1.fb34 : footRB DEC_clearFill.st1.s34 DEC_clearFill.st1.s35 DEC_clearFill.st1.fR34 = true
kernel_rfl DEC_clearFill.st1.fc34 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s34.next && Nat.ble DEC_clearFill.st1.s35.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR34 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa35 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s35 :=
  DEC_clearFill.st1.fa34.step (stageFoot_ofRF DEC_clearFill.st1.fh34 DEC_clearFill.st1.fb34) (incl_of_footW DEC_clearFill.st1.fb34 DEC_clearFill.st1.fc34)

def DEC_clearFill.st1.fR35 : List (Nat × Nat) := [(4841, 4842), (2672415, 2672416), (3011330, 3011331), (3011382, 3011383), (3158286, 3158296), (3158318, 3158319)]
kernel_rfl DEC_clearFill.st1.fh35 : DEC_clearFill.st1.s36.heap = setAll DEC_clearFill.st1.s35.heap (rangesOf DEC_clearFill.st1.s36.heap DEC_clearFill.st1.fR35 ++ freshOf DEC_clearFill.st1.s36.heap DEC_clearFill.st1.s35.next DEC_clearFill.st1.s36.next)
kernel_rfl DEC_clearFill.st1.fb35 : footRB DEC_clearFill.st1.s35 DEC_clearFill.st1.s36 DEC_clearFill.st1.fR35 = true
kernel_rfl DEC_clearFill.st1.fc35 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s35.next && Nat.ble DEC_clearFill.st1.s36.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR35 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa36 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s36 :=
  DEC_clearFill.st1.fa35.step (stageFoot_ofRF DEC_clearFill.st1.fh35 DEC_clearFill.st1.fb35) (incl_of_footW DEC_clearFill.st1.fb35 DEC_clearFill.st1.fc35)

def DEC_clearFill.st1.fR36 : List (Nat × Nat) := [(3158228, 3158231), (3158295, 3158301), (3158617, 3158618), (3159062, 3159063), (3159341, 3159342), (3159390, 3159391)]
kernel_rfl DEC_clearFill.st1.fh36 : DEC_clearFill.st1.s37.heap = setAll DEC_clearFill.st1.s36.heap (rangesOf DEC_clearFill.st1.s37.heap DEC_clearFill.st1.fR36 ++ freshOf DEC_clearFill.st1.s37.heap DEC_clearFill.st1.s36.next DEC_clearFill.st1.s37.next)
kernel_rfl DEC_clearFill.st1.fb36 : footRB DEC_clearFill.st1.s36 DEC_clearFill.st1.s37 DEC_clearFill.st1.fR36 = true
kernel_rfl DEC_clearFill.st1.fc36 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s36.next && Nat.ble DEC_clearFill.st1.s37.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR36 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa37 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s37 :=
  DEC_clearFill.st1.fa36.step (stageFoot_ofRF DEC_clearFill.st1.fh36 DEC_clearFill.st1.fb36) (incl_of_footW DEC_clearFill.st1.fb36 DEC_clearFill.st1.fc36)

def DEC_clearFill.st1.fR37 : List (Nat × Nat) := [(2672424, 2672425), (3013440, 3013441), (3123796, 3123797), (3158189, 3158190), (3158256, 3158257), (3159649, 3159650), (3159707, 3159708), (3159713, 3159714), (3160324, 3160325)]
kernel_rfl DEC_clearFill.st1.fh37 : DEC_clearFill.st1.s38.heap = setAll DEC_clearFill.st1.s37.heap (rangesOf DEC_clearFill.st1.s38.heap DEC_clearFill.st1.fR37 ++ freshOf DEC_clearFill.st1.s38.heap DEC_clearFill.st1.s37.next DEC_clearFill.st1.s38.next)
kernel_rfl DEC_clearFill.st1.fb37 : footRB DEC_clearFill.st1.s37 DEC_clearFill.st1.s38 DEC_clearFill.st1.fR37 = true
kernel_rfl DEC_clearFill.st1.fc37 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s37.next && Nat.ble DEC_clearFill.st1.s38.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR37 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa38 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s38 :=
  DEC_clearFill.st1.fa37.step (stageFoot_ofRF DEC_clearFill.st1.fh37 DEC_clearFill.st1.fb37) (incl_of_footW DEC_clearFill.st1.fb37 DEC_clearFill.st1.fc37)

def DEC_clearFill.st1.fR38 : List (Nat × Nat) := [(2672424, 2672425), (3013869, 3013870), (3160429, 3160432), (3160477, 3160482), (3160671, 3160672), (3160896, 3160897), (3160982, 3160983), (3161071, 3161072), (3161111, 3161116), (3161380, 3161381), (3161394, 3161397), (3161432, 3161434)]
kernel_rfl DEC_clearFill.st1.fh38 : DEC_clearFill.st1.s39.heap = setAll DEC_clearFill.st1.s38.heap (rangesOf DEC_clearFill.st1.s39.heap DEC_clearFill.st1.fR38 ++ freshOf DEC_clearFill.st1.s39.heap DEC_clearFill.st1.s38.next DEC_clearFill.st1.s39.next)
kernel_rfl DEC_clearFill.st1.fb38 : footRB DEC_clearFill.st1.s38 DEC_clearFill.st1.s39 DEC_clearFill.st1.fR38 = true
kernel_rfl DEC_clearFill.st1.fc38 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s38.next && Nat.ble DEC_clearFill.st1.s39.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR38 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa39 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s39 :=
  DEC_clearFill.st1.fa38.step (stageFoot_ofRF DEC_clearFill.st1.fh38 DEC_clearFill.st1.fb38) (incl_of_footW DEC_clearFill.st1.fb38 DEC_clearFill.st1.fc38)

def DEC_clearFill.st1.fR39 : List (Nat × Nat) := [(3123796, 3123797), (3160369, 3160370), (3160457, 3160458), (3162071, 3162072), (3162125, 3162126), (3162131, 3162132), (3162137, 3162138), (3162145, 3162146), (3162158, 3162160), (3162214, 3162215), (3162355, 3162357)]
kernel_rfl DEC_clearFill.st1.fh39 : DEC_clearFill.st1.s40.heap = setAll DEC_clearFill.st1.s39.heap (rangesOf DEC_clearFill.st1.s40.heap DEC_clearFill.st1.fR39 ++ freshOf DEC_clearFill.st1.s40.heap DEC_clearFill.st1.s39.next DEC_clearFill.st1.s40.next)
kernel_rfl DEC_clearFill.st1.fb39 : footRB DEC_clearFill.st1.s39 DEC_clearFill.st1.s40 DEC_clearFill.st1.fR39 = true
kernel_rfl DEC_clearFill.st1.fc39 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s39.next && Nat.ble DEC_clearFill.st1.s40.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR39 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa40 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s40 :=
  DEC_clearFill.st1.fa39.step (stageFoot_ofRF DEC_clearFill.st1.fh39 DEC_clearFill.st1.fb39) (incl_of_footW DEC_clearFill.st1.fb39 DEC_clearFill.st1.fc39)

def DEC_clearFill.st1.fR40 : List (Nat × Nat) := [(2672429, 2672430), (3015836, 3015837), (3016265, 3016266), (3162870, 3162877), (3163067, 3163068), (3163292, 3163293), (3163305, 3163306)]
kernel_rfl DEC_clearFill.st1.fh40 : DEC_clearFill.st1.s41.heap = setAll DEC_clearFill.st1.s40.heap (rangesOf DEC_clearFill.st1.s41.heap DEC_clearFill.st1.fR40 ++ freshOf DEC_clearFill.st1.s41.heap DEC_clearFill.st1.s40.next DEC_clearFill.st1.s41.next)
kernel_rfl DEC_clearFill.st1.fb40 : footRB DEC_clearFill.st1.s40 DEC_clearFill.st1.s41 DEC_clearFill.st1.fR40 = true
kernel_rfl DEC_clearFill.st1.fc40 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s40.next && Nat.ble DEC_clearFill.st1.s41.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR40 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa41 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s41 :=
  DEC_clearFill.st1.fa40.step (stageFoot_ofRF DEC_clearFill.st1.fh40 DEC_clearFill.st1.fb40) (incl_of_footW DEC_clearFill.st1.fb40 DEC_clearFill.st1.fc40)

def DEC_clearFill.st1.fR41 : List (Nat × Nat) := [(3123796, 3123797), (3162787, 3162788), (3162825, 3162828), (3162853, 3162854), (3162877, 3162878), (3164284, 3164285), (3164309, 3164310), (3164341, 3164343)]
kernel_rfl DEC_clearFill.st1.fh41 : DEC_clearFill.st1.s42.heap = setAll DEC_clearFill.st1.s41.heap (rangesOf DEC_clearFill.st1.s42.heap DEC_clearFill.st1.fR41 ++ freshOf DEC_clearFill.st1.s42.heap DEC_clearFill.st1.s41.next DEC_clearFill.st1.s42.next)
kernel_rfl DEC_clearFill.st1.fb41 : footRB DEC_clearFill.st1.s41 DEC_clearFill.st1.s42 DEC_clearFill.st1.fR41 = true
kernel_rfl DEC_clearFill.st1.fc41 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s41.next && Nat.ble DEC_clearFill.st1.s42.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR41 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa42 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s42 :=
  DEC_clearFill.st1.fa41.step (stageFoot_ofRF DEC_clearFill.st1.fh41 DEC_clearFill.st1.fb41) (incl_of_footW DEC_clearFill.st1.fb41 DEC_clearFill.st1.fc41)

def DEC_clearFill.st1.fR42 : List (Nat × Nat) := [(2672434, 2672435), (3018232, 3018233), (3165264, 3165269), (3165302, 3165306)]
kernel_rfl DEC_clearFill.st1.fh42 : DEC_clearFill.st1.s43.heap = setAll DEC_clearFill.st1.s42.heap (rangesOf DEC_clearFill.st1.s43.heap DEC_clearFill.st1.fR42 ++ freshOf DEC_clearFill.st1.s43.heap DEC_clearFill.st1.s42.next DEC_clearFill.st1.s43.next)
kernel_rfl DEC_clearFill.st1.fb42 : footRB DEC_clearFill.st1.s42 DEC_clearFill.st1.s43 DEC_clearFill.st1.fR42 = true
kernel_rfl DEC_clearFill.st1.fc42 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s42.next && Nat.ble DEC_clearFill.st1.s43.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR42 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa43 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s43 :=
  DEC_clearFill.st1.fa42.step (stageFoot_ofRF DEC_clearFill.st1.fh42 DEC_clearFill.st1.fb42) (incl_of_footW DEC_clearFill.st1.fb42 DEC_clearFill.st1.fc42)

def DEC_clearFill.st1.fR43 : List (Nat × Nat) := [(2672434, 2672435), (3018661, 3018662), (3165221, 3165224), (3165269, 3165274), (3165463, 3165464), (3165688, 3165689), (3165774, 3165775), (3165863, 3165864), (3165906, 3165908), (3166229, 3166230), (3166235, 3166236), (3166241, 3166242), (3166267, 3166272), (3166316, 3166317), (3166355, 3166357)]
kernel_rfl DEC_clearFill.st1.fh43 : DEC_clearFill.st1.s44.heap = setAll DEC_clearFill.st1.s43.heap (rangesOf DEC_clearFill.st1.s44.heap DEC_clearFill.st1.fR43 ++ freshOf DEC_clearFill.st1.s44.heap DEC_clearFill.st1.s43.next DEC_clearFill.st1.s44.next)
kernel_rfl DEC_clearFill.st1.fb43 : footRB DEC_clearFill.st1.s43 DEC_clearFill.st1.s44 DEC_clearFill.st1.fR43 = true
kernel_rfl DEC_clearFill.st1.fc43 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s43.next && Nat.ble DEC_clearFill.st1.s44.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR43 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa44 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s44 :=
  DEC_clearFill.st1.fa43.step (stageFoot_ofRF DEC_clearFill.st1.fh43 DEC_clearFill.st1.fb43) (incl_of_footW DEC_clearFill.st1.fb43 DEC_clearFill.st1.fc43)

def DEC_clearFill.st1.fR44 : List (Nat × Nat) := [(3123796, 3123797), (3165183, 3165184), (3165249, 3165250), (3166863, 3166864), (3166917, 3166918), (3166923, 3166924), (3166929, 3166930), (3167183, 3167184), (3167204, 3167205), (3167254, 3167255), (3167276, 3167278), (3167281, 3167282)]
kernel_rfl DEC_clearFill.st1.fh44 : DEC_clearFill.st1.s45.heap = setAll DEC_clearFill.st1.s44.heap (rangesOf DEC_clearFill.st1.s45.heap DEC_clearFill.st1.fR44 ++ freshOf DEC_clearFill.st1.s45.heap DEC_clearFill.st1.s44.next DEC_clearFill.st1.s45.next)
kernel_rfl DEC_clearFill.st1.fb44 : footRB DEC_clearFill.st1.s44 DEC_clearFill.st1.s45 DEC_clearFill.st1.fR44 = true
kernel_rfl DEC_clearFill.st1.fc44 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s44.next && Nat.ble DEC_clearFill.st1.s45.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR44 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa45 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s45 :=
  DEC_clearFill.st1.fa44.step (stageFoot_ofRF DEC_clearFill.st1.fh44 DEC_clearFill.st1.fb44) (incl_of_footW DEC_clearFill.st1.fb44 DEC_clearFill.st1.fc44)

def DEC_clearFill.st1.fR45 : List (Nat × Nat) := [(4841, 4842), (2672446, 2672447), (3020720, 3020721), (3020772, 3020773), (3167618, 3167621), (3167681, 3167691), (3168007, 3168008), (3168182, 3168183), (3168250, 3168251), (3168283, 3168284)]
kernel_rfl DEC_clearFill.st1.fh45 : DEC_clearFill.st1.s46.heap = setAll DEC_clearFill.st1.s45.heap (rangesOf DEC_clearFill.st1.s46.heap DEC_clearFill.st1.fR45 ++ freshOf DEC_clearFill.st1.s46.heap DEC_clearFill.st1.s45.next DEC_clearFill.st1.s46.next)
kernel_rfl DEC_clearFill.st1.fb45 : footRB DEC_clearFill.st1.s45 DEC_clearFill.st1.s46 DEC_clearFill.st1.fR45 = true
kernel_rfl DEC_clearFill.st1.fc45 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s45.next && Nat.ble DEC_clearFill.st1.s46.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR45 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa46 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s46 :=
  DEC_clearFill.st1.fa45.step (stageFoot_ofRF DEC_clearFill.st1.fh45 DEC_clearFill.st1.fb45) (incl_of_footW DEC_clearFill.st1.fb45 DEC_clearFill.st1.fc45)

def DEC_clearFill.st1.fR46 : List (Nat × Nat) := [(3123796, 3123797), (3167579, 3167580), (3167646, 3167647), (3169039, 3169040), (3169097, 3169098), (3169103, 3169104), (3169109, 3169110), (3169117, 3169118), (3169130, 3169132), (3169186, 3169187), (3169214, 3169215), (3169217, 3169227), (3169299, 3169300)]
kernel_rfl DEC_clearFill.st1.fh46 : DEC_clearFill.st1.s47.heap = setAll DEC_clearFill.st1.s46.heap (rangesOf DEC_clearFill.st1.s47.heap DEC_clearFill.st1.fR46 ++ freshOf DEC_clearFill.st1.s47.heap DEC_clearFill.st1.s46.next DEC_clearFill.st1.s47.next)
kernel_rfl DEC_clearFill.st1.fb46 : footRB DEC_clearFill.st1.s46 DEC_clearFill.st1.s47 DEC_clearFill.st1.fR46 = true
kernel_rfl DEC_clearFill.st1.fc46 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s46.next && Nat.ble DEC_clearFill.st1.s47.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR46 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa47 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s47 :=
  DEC_clearFill.st1.fa46.step (stageFoot_ofRF DEC_clearFill.st1.fh46 DEC_clearFill.st1.fb46) (incl_of_footW DEC_clearFill.st1.fb46 DEC_clearFill.st1.fc46)

def DEC_clearFill.st1.fR47 : List (Nat × Nat) := [(2672455, 2672456), (3022826, 3022827), (3023255, 3023256), (3169859, 3169867), (3170057, 3170058), (3170246, 3170247), (3170274, 3170276)]
kernel_rfl DEC_clearFill.st1.fh47 : DEC_clearFill.st1.s48.heap = setAll DEC_clearFill.st1.s47.heap (rangesOf DEC_clearFill.st1.s48.heap DEC_clearFill.st1.fR47 ++ freshOf DEC_clearFill.st1.s48.heap DEC_clearFill.st1.s47.next DEC_clearFill.st1.s48.next)
kernel_rfl DEC_clearFill.st1.fb47 : footRB DEC_clearFill.st1.s47 DEC_clearFill.st1.s48 DEC_clearFill.st1.fR47 = true
kernel_rfl DEC_clearFill.st1.fc47 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s47.next && Nat.ble DEC_clearFill.st1.s48.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR47 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa48 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s48 :=
  DEC_clearFill.st1.fa47.step (stageFoot_ofRF DEC_clearFill.st1.fh47 DEC_clearFill.st1.fb47) (incl_of_footW DEC_clearFill.st1.fb47 DEC_clearFill.st1.fc47)

def DEC_clearFill.st1.fR48 : List (Nat × Nat) := [(3123796, 3123797), (3169755, 3169756), (3169815, 3169818), (3169843, 3169844), (3169867, 3169868), (3171274, 3171275)]
kernel_rfl DEC_clearFill.st1.fh48 : DEC_clearFill.st1.s49.heap = setAll DEC_clearFill.st1.s48.heap (rangesOf DEC_clearFill.st1.s49.heap DEC_clearFill.st1.fR48 ++ freshOf DEC_clearFill.st1.s49.heap DEC_clearFill.st1.s48.next DEC_clearFill.st1.s49.next)
kernel_rfl DEC_clearFill.st1.fb48 : footRB DEC_clearFill.st1.s48 DEC_clearFill.st1.s49 DEC_clearFill.st1.fR48 = true
kernel_rfl DEC_clearFill.st1.fc48 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s48.next && Nat.ble DEC_clearFill.st1.s49.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR48 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa49 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s49 :=
  DEC_clearFill.st1.fa48.step (stageFoot_ofRF DEC_clearFill.st1.fh48 DEC_clearFill.st1.fb48) (incl_of_footW DEC_clearFill.st1.fb48 DEC_clearFill.st1.fc48)

def DEC_clearFill.st1.fR49 : List (Nat × Nat) := [(2672460, 2672461), (3025218, 3025219), (3172206, 3172207), (3172226, 3172227)]
kernel_rfl DEC_clearFill.st1.fh49 : DEC_clearFill.st1.s50.heap = setAll DEC_clearFill.st1.s49.heap (rangesOf DEC_clearFill.st1.s50.heap DEC_clearFill.st1.fR49 ++ freshOf DEC_clearFill.st1.s50.heap DEC_clearFill.st1.s49.next DEC_clearFill.st1.s50.next)
kernel_rfl DEC_clearFill.st1.fb49 : footRB DEC_clearFill.st1.s49 DEC_clearFill.st1.s50 DEC_clearFill.st1.fR49 = true
kernel_rfl DEC_clearFill.st1.fc49 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s49.next && Nat.ble DEC_clearFill.st1.s50.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR49 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa50 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s50 :=
  DEC_clearFill.st1.fa49.step (stageFoot_ofRF DEC_clearFill.st1.fh49 DEC_clearFill.st1.fb49) (incl_of_footW DEC_clearFill.st1.fb49 DEC_clearFill.st1.fc49)

def DEC_clearFill.st1.fR50 : List (Nat × Nat) := [(2672460, 2672461), (3025647, 3025648), (3172207, 3172210), (3172255, 3172260), (3172449, 3172450), (3172674, 3172675), (3172760, 3172761), (3172849, 3172850), (3172892, 3172894), (3173215, 3173216), (3173221, 3173222), (3173227, 3173228), (3173252, 3173258), (3173294, 3173296)]
kernel_rfl DEC_clearFill.st1.fh50 : DEC_clearFill.st1.s51.heap = setAll DEC_clearFill.st1.s50.heap (rangesOf DEC_clearFill.st1.s51.heap DEC_clearFill.st1.fR50 ++ freshOf DEC_clearFill.st1.s51.heap DEC_clearFill.st1.s50.next DEC_clearFill.st1.s51.next)
kernel_rfl DEC_clearFill.st1.fb50 : footRB DEC_clearFill.st1.s50 DEC_clearFill.st1.s51 DEC_clearFill.st1.fR50 = true
kernel_rfl DEC_clearFill.st1.fc50 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s50.next && Nat.ble DEC_clearFill.st1.s51.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR50 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa51 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s51 :=
  DEC_clearFill.st1.fa50.step (stageFoot_ofRF DEC_clearFill.st1.fh50 DEC_clearFill.st1.fb50) (incl_of_footW DEC_clearFill.st1.fb50 DEC_clearFill.st1.fc50)

def DEC_clearFill.st1.fR51 : List (Nat × Nat) := [(3123796, 3123797), (3172169, 3172170), (3172235, 3172236), (3173849, 3173850), (3173903, 3173904), (3173909, 3173910), (3173915, 3173916), (3174169, 3174170), (3174189, 3174191), (3174211, 3174213)]
kernel_rfl DEC_clearFill.st1.fh51 : DEC_clearFill.st1.s52.heap = setAll DEC_clearFill.st1.s51.heap (rangesOf DEC_clearFill.st1.s52.heap DEC_clearFill.st1.fR51 ++ freshOf DEC_clearFill.st1.s52.heap DEC_clearFill.st1.s51.next DEC_clearFill.st1.s52.next)
kernel_rfl DEC_clearFill.st1.fb51 : footRB DEC_clearFill.st1.s51 DEC_clearFill.st1.s52 DEC_clearFill.st1.fR51 = true
kernel_rfl DEC_clearFill.st1.fc51 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s51.next && Nat.ble DEC_clearFill.st1.s52.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR51 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa52 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s52 :=
  DEC_clearFill.st1.fa51.step (stageFoot_ofRF DEC_clearFill.st1.fh51 DEC_clearFill.st1.fb51) (incl_of_footW DEC_clearFill.st1.fb51 DEC_clearFill.st1.fc51)

def DEC_clearFill.st1.fR52 : List (Nat × Nat) := [(2672465, 2672466), (3027610, 3027611), (3028039, 3028040), (3174645, 3174651), (3174841, 3174842), (3175066, 3175067), (3175152, 3175153), (3175168, 3175169), (3175218, 3175222)]
kernel_rfl DEC_clearFill.st1.fh52 : DEC_clearFill.st1.s53.heap = setAll DEC_clearFill.st1.s52.heap (rangesOf DEC_clearFill.st1.s53.heap DEC_clearFill.st1.fR52 ++ freshOf DEC_clearFill.st1.s53.heap DEC_clearFill.st1.s52.next DEC_clearFill.st1.s53.next)
kernel_rfl DEC_clearFill.st1.fb52 : footRB DEC_clearFill.st1.s52 DEC_clearFill.st1.s53 DEC_clearFill.st1.fR52 = true
kernel_rfl DEC_clearFill.st1.fc52 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s52.next && Nat.ble DEC_clearFill.st1.s53.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR52 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa53 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s53 :=
  DEC_clearFill.st1.fa52.step (stageFoot_ofRF DEC_clearFill.st1.fh52 DEC_clearFill.st1.fb52) (incl_of_footW DEC_clearFill.st1.fb52 DEC_clearFill.st1.fc52)

def DEC_clearFill.st1.fR53 : List (Nat × Nat) := [(3123796, 3123797), (3174561, 3174562), (3174599, 3174602), (3174627, 3174628), (3174651, 3174652), (3176058, 3176059), (3176083, 3176084), (3176151, 3176152), (3176154, 3176164), (3176212, 3176213)]
kernel_rfl DEC_clearFill.st1.fh53 : DEC_clearFill.st1.s54.heap = setAll DEC_clearFill.st1.s53.heap (rangesOf DEC_clearFill.st1.s54.heap DEC_clearFill.st1.fR53 ++ freshOf DEC_clearFill.st1.s54.heap DEC_clearFill.st1.s53.next DEC_clearFill.st1.s54.next)
kernel_rfl DEC_clearFill.st1.fb53 : footRB DEC_clearFill.st1.s53 DEC_clearFill.st1.s54 DEC_clearFill.st1.fR53 = true
kernel_rfl DEC_clearFill.st1.fc53 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s53.next && Nat.ble DEC_clearFill.st1.s54.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR53 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa54 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s54 :=
  DEC_clearFill.st1.fa53.step (stageFoot_ofRF DEC_clearFill.st1.fh53 DEC_clearFill.st1.fb53) (incl_of_footW DEC_clearFill.st1.fb53 DEC_clearFill.st1.fc53)

def DEC_clearFill.st1.fR54 : List (Nat × Nat) := [(4841, 4842), (2672477, 2672478), (3030094, 3030095), (3030146, 3030147), (3177051, 3177060), (3177155, 3177156), (3177191, 3177192), (3177195, 3177196)]
kernel_rfl DEC_clearFill.st1.fh54 : DEC_clearFill.st1.s55.heap = setAll DEC_clearFill.st1.s54.heap (rangesOf DEC_clearFill.st1.s55.heap DEC_clearFill.st1.fR54 ++ freshOf DEC_clearFill.st1.s55.heap DEC_clearFill.st1.s54.next DEC_clearFill.st1.s55.next)
kernel_rfl DEC_clearFill.st1.fb54 : footRB DEC_clearFill.st1.s54 DEC_clearFill.st1.s55 DEC_clearFill.st1.fR54 = true
kernel_rfl DEC_clearFill.st1.fc54 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s54.next && Nat.ble DEC_clearFill.st1.s55.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR54 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa55 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s55 :=
  DEC_clearFill.st1.fa54.step (stageFoot_ofRF DEC_clearFill.st1.fh54 DEC_clearFill.st1.fb54) (incl_of_footW DEC_clearFill.st1.fb54 DEC_clearFill.st1.fc54)

def DEC_clearFill.st1.fR55 : List (Nat × Nat) := [(3123796, 3123797), (3176953, 3176954), (3176992, 3176995), (3177020, 3177021), (3177060, 3177065), (3177381, 3177382), (3177826, 3177827), (3178105, 3178106), (3178154, 3178155), (3178203, 3178204)]
kernel_rfl DEC_clearFill.st1.fh55 : DEC_clearFill.st1.s56.heap = setAll DEC_clearFill.st1.s55.heap (rangesOf DEC_clearFill.st1.s56.heap DEC_clearFill.st1.fR55 ++ freshOf DEC_clearFill.st1.s56.heap DEC_clearFill.st1.s55.next DEC_clearFill.st1.s56.next)
kernel_rfl DEC_clearFill.st1.fb55 : footRB DEC_clearFill.st1.s55 DEC_clearFill.st1.s56 DEC_clearFill.st1.fR55 = true
kernel_rfl DEC_clearFill.st1.fc55 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s55.next && Nat.ble DEC_clearFill.st1.s56.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR55 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa56 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s56 :=
  DEC_clearFill.st1.fa55.step (stageFoot_ofRF DEC_clearFill.st1.fh55 DEC_clearFill.st1.fb55) (incl_of_footW DEC_clearFill.st1.fb55 DEC_clearFill.st1.fc55)

def DEC_clearFill.st1.fR56 : List (Nat × Nat) := [(2672486, 2672487), (3032200, 3032201)]
kernel_rfl DEC_clearFill.st1.fh56 : DEC_clearFill.st1.s57.heap = setAll DEC_clearFill.st1.s56.heap (rangesOf DEC_clearFill.st1.s57.heap DEC_clearFill.st1.fR56 ++ freshOf DEC_clearFill.st1.s57.heap DEC_clearFill.st1.s56.next DEC_clearFill.st1.s57.next)
kernel_rfl DEC_clearFill.st1.fb56 : footRB DEC_clearFill.st1.s56 DEC_clearFill.st1.s57 DEC_clearFill.st1.fR56 = true
kernel_rfl DEC_clearFill.st1.fc56 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s56.next && Nat.ble DEC_clearFill.st1.s57.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR56 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa57 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s57 :=
  DEC_clearFill.st1.fa56.step (stageFoot_ofRF DEC_clearFill.st1.fh56 DEC_clearFill.st1.fb56) (incl_of_footW DEC_clearFill.st1.fb56 DEC_clearFill.st1.fc56)

def DEC_clearFill.st1.fR57 : List (Nat × Nat) := [(2672486, 2672487), (3032629, 3032630), (3179189, 3179192), (3179237, 3179242), (3179431, 3179432), (3179656, 3179657), (3179742, 3179743), (3179831, 3179832), (3179874, 3179876), (3180197, 3180198), (3180203, 3180204), (3180209, 3180210)]
kernel_rfl DEC_clearFill.st1.fh57 : DEC_clearFill.st1.s58.heap = setAll DEC_clearFill.st1.s57.heap (rangesOf DEC_clearFill.st1.s58.heap DEC_clearFill.st1.fR57 ++ freshOf DEC_clearFill.st1.s58.heap DEC_clearFill.st1.s57.next DEC_clearFill.st1.s58.next)
kernel_rfl DEC_clearFill.st1.fb57 : footRB DEC_clearFill.st1.s57 DEC_clearFill.st1.s58 DEC_clearFill.st1.fR57 = true
kernel_rfl DEC_clearFill.st1.fc57 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s57.next && Nat.ble DEC_clearFill.st1.s58.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR57 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa58 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s58 :=
  DEC_clearFill.st1.fa57.step (stageFoot_ofRF DEC_clearFill.st1.fh57 DEC_clearFill.st1.fb57) (incl_of_footW DEC_clearFill.st1.fb57 DEC_clearFill.st1.fc57)

def DEC_clearFill.st1.fR58 : List (Nat × Nat) := [(3123796, 3123797), (3179129, 3179130), (3179217, 3179218), (3180831, 3180832), (3180885, 3180886), (3180891, 3180892), (3180897, 3180898), (3180905, 3180906), (3180919, 3180920), (3181120, 3181121), (3181151, 3181152)]
kernel_rfl DEC_clearFill.st1.fh58 : DEC_clearFill.st1.s59.heap = setAll DEC_clearFill.st1.s58.heap (rangesOf DEC_clearFill.st1.s59.heap DEC_clearFill.st1.fR58 ++ freshOf DEC_clearFill.st1.s59.heap DEC_clearFill.st1.s58.next DEC_clearFill.st1.s59.next)
kernel_rfl DEC_clearFill.st1.fb58 : footRB DEC_clearFill.st1.s58 DEC_clearFill.st1.s59 DEC_clearFill.st1.fR58 = true
kernel_rfl DEC_clearFill.st1.fc58 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s58.next && Nat.ble DEC_clearFill.st1.s59.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR58 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa59 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s59 :=
  DEC_clearFill.st1.fa58.step (stageFoot_ofRF DEC_clearFill.st1.fh58 DEC_clearFill.st1.fb58) (incl_of_footW DEC_clearFill.st1.fb58 DEC_clearFill.st1.fc58)

def DEC_clearFill.st1.fR59 : List (Nat × Nat) := [(2672491, 2672492), (3034492, 3034493), (3034921, 3034922), (3181581, 3181582), (3181629, 3181634), (3181823, 3181824), (3181948, 3181949), (3182034, 3182035), (3182123, 3182124), (3182157, 3182168), (3182183, 3182185)]
kernel_rfl DEC_clearFill.st1.fh59 : DEC_clearFill.st1.s60.heap = setAll DEC_clearFill.st1.s59.heap (rangesOf DEC_clearFill.st1.s60.heap DEC_clearFill.st1.fR59 ++ freshOf DEC_clearFill.st1.s60.heap DEC_clearFill.st1.s59.next DEC_clearFill.st1.s60.next)
kernel_rfl DEC_clearFill.st1.fb59 : footRB DEC_clearFill.st1.s59 DEC_clearFill.st1.s60 DEC_clearFill.st1.fR59 = true
kernel_rfl DEC_clearFill.st1.fc59 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s59.next && Nat.ble DEC_clearFill.st1.s60.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR59 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa60 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s60 :=
  DEC_clearFill.st1.fa59.step (stageFoot_ofRF DEC_clearFill.st1.fh59 DEC_clearFill.st1.fb59) (incl_of_footW DEC_clearFill.st1.fb59 DEC_clearFill.st1.fc59)

def DEC_clearFill.st1.fR60 : List (Nat × Nat) := [(3123796, 3123797), (3181543, 3181544), (3181582, 3181584), (3181609, 3181610), (3183123, 3183124), (3183147, 3183157)]
kernel_rfl DEC_clearFill.st1.fh60 : DEC_clearFill.st1.s61.heap = setAll DEC_clearFill.st1.s60.heap (rangesOf DEC_clearFill.st1.s61.heap DEC_clearFill.st1.fR60 ++ freshOf DEC_clearFill.st1.s61.heap DEC_clearFill.st1.s60.next DEC_clearFill.st1.s61.next)
kernel_rfl DEC_clearFill.st1.fb60 : footRB DEC_clearFill.st1.s60 DEC_clearFill.st1.s61 DEC_clearFill.st1.fR60 = true
kernel_rfl DEC_clearFill.st1.fc60 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s60.next && Nat.ble DEC_clearFill.st1.s61.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR60 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa61 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s61 :=
  DEC_clearFill.st1.fa60.step (stageFoot_ofRF DEC_clearFill.st1.fh60 DEC_clearFill.st1.fb60) (incl_of_footW DEC_clearFill.st1.fb60 DEC_clearFill.st1.fc60)

def DEC_clearFill.st1.fR61 : List (Nat × Nat) := [(2672496, 2672497), (3036884, 3036885), (3183916, 3183921), (3183957, 3183958), (3184110, 3184111), (3184115, 3184116)]
kernel_rfl DEC_clearFill.st1.fh61 : DEC_clearFill.st1.s62.heap = setAll DEC_clearFill.st1.s61.heap (rangesOf DEC_clearFill.st1.s62.heap DEC_clearFill.st1.fR61 ++ freshOf DEC_clearFill.st1.s62.heap DEC_clearFill.st1.s61.next DEC_clearFill.st1.s62.next)
kernel_rfl DEC_clearFill.st1.fb61 : footRB DEC_clearFill.st1.s61 DEC_clearFill.st1.s62 DEC_clearFill.st1.fR61 = true
kernel_rfl DEC_clearFill.st1.fc61 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s61.next && Nat.ble DEC_clearFill.st1.s62.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR61 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa62 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s62 :=
  DEC_clearFill.st1.fa61.step (stageFoot_ofRF DEC_clearFill.st1.fh61 DEC_clearFill.st1.fb61) (incl_of_footW DEC_clearFill.st1.fb61 DEC_clearFill.st1.fc61)

def DEC_clearFill.st1.fR62 : List (Nat × Nat) := [(2672496, 2672497), (3037313, 3037314), (3183873, 3183876), (3183921, 3183926), (3184115, 3184116), (3184340, 3184341), (3184426, 3184427), (3184515, 3184516), (3184558, 3184560), (3184881, 3184882), (3184887, 3184888), (3184893, 3184894), (3184922, 3184924), (3184968, 3184969), (3185012, 3185013), (3185034, 3185036), (3185075, 3185076), (3185107, 3185108), (3185110, 3185120), (3185172, 3185173)]
kernel_rfl DEC_clearFill.st1.fh62 : DEC_clearFill.st1.s63.heap = setAll DEC_clearFill.st1.s62.heap (rangesOf DEC_clearFill.st1.s63.heap DEC_clearFill.st1.fR62 ++ freshOf DEC_clearFill.st1.s63.heap DEC_clearFill.st1.s62.next DEC_clearFill.st1.s63.next)
kernel_rfl DEC_clearFill.st1.fb62 : footRB DEC_clearFill.st1.s62 DEC_clearFill.st1.s63 DEC_clearFill.st1.fR62 = true
kernel_rfl DEC_clearFill.st1.fc62 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s62.next && Nat.ble DEC_clearFill.st1.s63.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR62 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa63 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s63 :=
  DEC_clearFill.st1.fa62.step (stageFoot_ofRF DEC_clearFill.st1.fh62 DEC_clearFill.st1.fb62) (incl_of_footW DEC_clearFill.st1.fb62 DEC_clearFill.st1.fc62)

def DEC_clearFill.st1.fR63 : List (Nat × Nat) := [(4841, 4842), (3123796, 3123797), (3183835, 3183836), (3183901, 3183902), (3185515, 3185516), (3185569, 3185570), (3185575, 3185576), (3185581, 3185582), (3185835, 3185836), (3185856, 3185857), (3185906, 3185907), (3185925, 3185926), (3186068, 3186069), (3186075, 3186077)]
kernel_rfl DEC_clearFill.st1.fh63 : DEC_clearFill.st1.s64.heap = setAll DEC_clearFill.st1.s63.heap (rangesOf DEC_clearFill.st1.s64.heap DEC_clearFill.st1.fR63 ++ freshOf DEC_clearFill.st1.s64.heap DEC_clearFill.st1.s63.next DEC_clearFill.st1.s64.next)
kernel_rfl DEC_clearFill.st1.fb63 : footRB DEC_clearFill.st1.s63 DEC_clearFill.st1.s64 DEC_clearFill.st1.fR63 = true
kernel_rfl DEC_clearFill.st1.fc63 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s63.next && Nat.ble DEC_clearFill.st1.s64.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR63 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa64 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s64 :=
  DEC_clearFill.st1.fa63.step (stageFoot_ofRF DEC_clearFill.st1.fh63 DEC_clearFill.st1.fb63) (incl_of_footW DEC_clearFill.st1.fb63 DEC_clearFill.st1.fc63)

end Host.Load.Run.Tpl
