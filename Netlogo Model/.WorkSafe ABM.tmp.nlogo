globals [ preventabledeathcount
  naturaldeathcount]


breed [ SAPops SAPop ]
breed [ AcuteCares AcuteCare ]
breed [ GPs GP ]
breed [ NewPatients NewPatient ]
breed [ PreventableDeaths PreventableDeath ]
breed [ ReviewPatients ReviewPatient ]
breed [ Deathpools Death ]
breed [ DNAPool1s DNAPool1 ]
breed [ DNAPool2s DNAPool2 ]
breed [ UntreatedPopulations UntreatedPopulation ]
breed [ LodgeClaims LodgeClaim ]
breed [ Patients Patient ]

Patients-own ; states and qualities that individual patients have or are in at any stage
[
  motivation
  InGP
  InAcuteCare
  InPreventableDeaths
  InNewPatients
  InReviewPatients
  InDeath
  InUntreatedPopulation
  InDNAPool1
  InDNAPool2
  InLodgeClaim
  State1
  GoingtoGP
  GoingtoAcuteCare
  GoingtoPreventableDeath
  GoingtoNewPatient
  GoingtoReviewPatient
  GoingtoDeath
  GoingtoUntreatedPopulation
  GoingtoDNAPool1
  GoingtoDNAPool2
  GoingtoLodgeClaim
  GoingtoSAPops
  Trust
  Memory
  memory_Span
  Health
  Satisfaction
  Entrytime
  Timenow
  Timenow1
  saliencyexpectation
  saliencyexperience
  initialassociationstrength
  newv
  newassociationstrength
  vmax
  vmin
  speed
  LodgeClaimExpectations
  engaged
]

to setup
  clear-all
  create-GPs 1 [ set shape "box" set size 5 set label "GP" set xcor 13.92 set ycor 42.25 set color red]
  create-AcuteCares 1 [ set shape "box" set size 5 set label "Acute Care" set xcor 6.35 set ycor 33.52 set color green ]
  create-LodgeClaims 1 [ set shape "box" set size 5 set label "LodgeClaim" set xcor 4.71 set ycor 22.1 set color orange ]
  create-newPatients 1 [ set shape "box" set size 5 set label "New Patients" set xcor 9.51 set ycor 11.58 set color yellow ]
  create-Preventabledeaths 1 [ set shape "x"  set size 5 set label "Preventable Deaths" set xcor 19.22 set ycor 5.33 set color white]
  create-ReviewPatients 1 [ set shape "box"  set size 5 set label "Review Patients" set xcor 30.77 set ycor 5.33 set color blue ]
  create-DeathPools 1 [ set shape "x"  set size 5 set label "Natural Deaths" set xcor 40.49 set ycor 11.58 set color blue - 10]
  create-DNAPool1s 1 [ set shape "box" set size 5 set label "First DNA" set xcor 45.29 set ycor 22.08 set color green - 10 ]
  create-DNAPool2s 1 [ set shape "box" set size 5 set label "Second DNA" set xcor 43.65 set ycor 33.52 set color red - 10 ]
  create-UntreatedPopulations 1 [ set shape "box" set size 5 set label "Untreated Population" set xcor 36.08 set ycor 42.25 set color yellow - 10 ]
  create-SAPops 1 [ set shape "circle 2" set xcor 25 set ycor 25 set size 5 set label "General Population" set xcor 25 set ycor 45.5 set color white + 10 ]
  ask turtles [ create-links-with other turtles show label ]
  create-patients Population [ set shape "person" set state1 0 move-to one-of SAPops set color white set trust random-normal 80 10 set speed random-normal 1 .1 ]
  ask patients [ resettrust set memory_Span random-normal Memoryspan 30 set memory 0 set initialassociationstrength InitialV
    set saliencyExpectation random-normal ExpectationSaliency .1 set SaliencyExperience random-normal ExperienceSaliency .1 set LodgeClaimExpectations ManageExpectations] ;;; made a change
  reset-ticks
end

to resettrust
  if trust > 100 or trust < 1 [ set trust random-normal 70 15 ]
  if saliencyExpectation > 1 or saliencyExpectation <= 0 [ set saliencyExpectation random-normal ExpectationSaliency 10 ]
  if saliencyExperience > 1 or saliencyExperience <= 0 [ set saliencyExpectation random-normal ExpectationSaliency 10 ]
end

to go
  ask patients [
    initialise
    gpreferral
    emergency
    deathincare
    becomenew
    becomeReview
    becomeDNA1
    becomeDNA2
    DNA2decisions
    becomePreventableDeath
    UntreatedReEnter
    BecomeReviewfromDNA
    becomeLodgeClaim
    newtoGeneral
    newtoLodgeClaim
    DNAFromGP
    ReviewtoGeneral
    Captrust
    calculateTrustFactor
    rememberevents
    resetinitial
    limitInitialAssociation
    OverCapReview
    OverCapNew
    SocialEpi
    EngageExpectations
    colourme
  ]


  ask turtles [
    set size (5 + sqrt count patients in-radius 1 )
      ]
  ask patients [ set size 1 ]
  createnewpatients
  countpreventabledeaths
   ;; burnpatches
  if ticks = 10000 [ stop ]
  tick
end

to capTrust
  if trust > 100 [ set trust Maxtrust ]
  if trust < 1 [ set trust MinTrust ]
end

to initialise
  set state1 1
end

to gpreferral ;; individuals emerging from the general population into GPs
  if GP_referral_barrier < random 100 and state1 = 1 and any? SAPops-here  [
    face one-of GPs fd speed set goingtoGP 1 set state1 0 ]
     if goingtoGP = 1 [ face one-of GPs fd speed ]
       if any? GPs in-radius 1 [ move-to one-of GPs set InGP 1 set goingtoGP 0 set state1 0 ]
end

to emergency ;; individuals emerging from the general population into emergency areas of hospitals
    if Emergency_Pres < random 100 and state1 = 1 and InAcuteCare = 0 and any? SAPops-here [
      face one-of AcuteCares fd speed  set GoingtoAcuteCare 1 set State1 0 ]
       if GoingtoAcuteCare = 1 [ face one-of AcuteCares fd speed ]
        if any? AcuteCares in-radius 1 [ move-to one-of AcuteCares set InAcuteCare 1 set InGP 0 set GoingtoAcuteCare 0 ]
end

to becomeLodgeClaim ;;
     if Acute_Care_Barrier < random 100 and InAcuteCare = 1 and any? AcuteCares-here [
      face one-of LodgeClaims fd speed  set goingtoLodgeClaim 1 set InAcuteCare 0 ]
    if goingtoLodgeClaim = 1 [ Face one-of LodgeClaims fd speed ]
        if any? LodgeClaims in-radius 1 [ move-to one-of LodgeClaims Set InLodgeClaim 1 set InAcuteCare 0 set GoingtoLodgeClaim 0  ]

    if GP_Referral_Barrier < random 100 and InGP = 1 and any? GPs-here [
      face one-of LodgeClaims fd speed  set goingtoLodgeClaim 1 set InGP 0 ]
    if goingtoLodgeClaim = 1 [ Face one-of LodgeClaims fd speed ]
        if any? LodgeClaims in-radius 1 [ move-to one-of LodgeClaims Set InLodgeClaim 1 set InGP 0 set GoingtoLodgeClaim 0  ]
end

to becomeNew
  if LodgeClaim_Delay < random 100 and InLodgeClaim = 1 and any? LodgeClaims-here and count patients with [  InNewPatients = ( 1 * OverbookingRate )]  < New_Capacity [
      face one-of NewPatients fd speed  set goingtoNewPatient 1 Set InLodgeClaim 0  ]
     if goingtoNewPatient = 1 [ Face one-of NewPatients fd speed ]
      if any? Newpatients in-radius 1 [ move-to one-of NewPatients Set InNewPatients 1 Set InLodgeClaim 0 set goingtoNewPatient 0 ]
end

to becomeReview
    if New_to_Review < random 100 and InNewPatients = 1 and any? NewPatients-here and count patients with [  InReviewPatients = 1 ] < Review_Capacity  [
      face one-of ReviewPatients fd speed  set GoingtoReviewPatient 1 Set InNewPatients 0  ]
    if GoingtoreviewPatient = 1 [ face one-of ReviewPatients fd speed  ]
      if any? Reviewpatients in-radius 1 [ move-to one-of ReviewPatients Set InReviewPatients 1 Set InNewPatients 0 set GoingtoreviewPatient 0 ]

if Acute_to_Review < random 100 and InAcuteCare = 1 and any? AcuteCares-here [
      face one-of ReviewPatients fd speed  set GoingtoReviewPatient 1 Set InNewPatients 0 ]
    if GoingtoreviewPatient = 1 [ face one-of ReviewPatients fd speed  ]
      if any? Reviewpatients in-radius 1 [ move-to one-of ReviewPatients Set InReviewPatients 1 Set InNewPatients 0 set GoingtoreviewPatient 0 ]
end

to OverCapNew
  if inNewPatients = 1 and count patients with [ innewpatients = 1 ] > New_Capacity [
    face one-of LodgeClaims fd speed  set goingtoLodgeClaim 1 set InNewPatients 0 ]
    if goingtoLodgeClaim = 1 [ Face one-of LodgeClaims fd speed ]
        if any? LodgeClaims in-radius 1 [ move-to one-of LodgeClaims Set InLodgeClaim 1 set InNewPatients 0 set GoingtoLodgeClaim 0  ]
end

to OverCapReview
    if inReviewPatients = 1 and count patients with [ inReviewpatients = 1 ] > Review_Capacity [
    face one-of LodgeClaims fd speed  set goingtoLodgeClaim 1 set InReviewPatients 0 ]
    if goingtoLodgeClaim = 1 [ Face one-of LodgeClaims fd speed ]
        if any? LodgeClaims in-radius 1 [ move-to one-of LodgeClaims Set InLodgeClaim 1 set InReviewPatients 0 set GoingtoLodgeClaim 0  ]
end

to becomeDNA1 ;; in here is where trust is going to affect the DNA rate
   if (DNA1_Rate + (100 - trust)) > random 100 and InReviewPatients = 1 and any? ReviewPatients-here [ ;; people are more likely to DNA at any stage if their levels of trust are lower
     face one-of DNAPool1s fd speed  set GoingtoDNAPool1 1 set InReviewPatients 0 ]
     if GoingtoDNAPool1 = 1 [ face one-of DNAPool1s fd speed ]
    if any? DNAPool1s in-radius 1 [ move-to one-of DNAPool1s Set InDNAPool1 1 set InReviewPatients 0 set GoingtoDNAPool1 0 ]
end

to ReviewtoGeneral
  if Review_General > random 100 and InReviewPatients = 1 and any? ReviewPatients-here [
     face one-of SAPops fd speed  set GoingtoSAPops 1 set InReviewPatients 0  ] ;;DNA Rate is inversely proportional to trust
     if GoingtoSAPops = 1 [ face one-of SAPops fd speed ]
    if any? SAPops in-radius 1 [ move-to one-of SAPops Set State1 1 set InReviewPatients 0 set GoingtoSAPops 0 die ]
end

to DNAFromGP ;; trust is going affect the DNA rate here
  if (DNA_from_GP_Rate + (100 - trust) ) > random 100 and InGP = 1 and any? GPs-here [
     face one-of DNAPool1s fd speed  set GoingtoDNAPool1 1 set InGP 0 ]
     if GoingtoDNAPool1 = 1 [ face one-of DNAPool1s fd speed ]
    if any? DNAPool1s in-radius 1 [ move-to one-of DNAPool1s Set InDNAPool1 1 set InGP 0 set GoingtoDNAPool1 0 ]
end

to becomeDNA2 ;; trust is going to affec the DNA2 rate here
     if (DNA2_Rate + (100 - trust )) > random 100 and InDNAPool1 = 1 and any? DNAPool1s-here [
     face one-of DNAPool2s fd speed  set GoingtoDNAPool2 1 set InDNAPool1 0 ]
     if GoingtoDNAPool2 = 1 [ face one-of DNAPool2s fd speed ]
    if any? DNAPool2s in-radius 1 [ move-to one-of DNAPool2s Set InDNAPool2 1 set InDNAPool1 0 set GoingtoDNAPool2 0 ]
end

to BecomeReviewfromDNA ;; trust is going to affect the likelihood that anyone comes ouut of DNA1 back to review here
if Trust > random 100 and InDNAPool1 = 1 and any? DNAPool1s-here [
      face one-of ReviewPatients fd speed  set GoingtoReviewPatient 1 Set InDNAPool1 0 ]
    if GoingtoreviewPatient = 1 [ face one-of ReviewPatients fd speed  ]
      if any? Reviewpatients in-radius 1 [ move-to one-of ReviewPatients Set InReviewPatients 1 Set InDNAPool1 0 set GoingtoreviewPatient 0 ]

  ;; trust is going to affect the likelihood that anyone comes ouut of DNA1 back to review here
if Trust > random 100 and InDNAPool2 = 1 and any? DNAPool2s-here [
      face one-of ReviewPatients fd speed  set GoingtoReviewPatient 1 Set InDNAPool2 0 ]
    if GoingtoreviewPatient = 1 [ face one-of ReviewPatients fd speed  ]
      if any? Reviewpatients in-radius 1 [ move-to one-of ReviewPatients Set InReviewPatients 1 Set InDNAPool2 0 set GoingtoreviewPatient 0 ]
end

to DNA2Decisions
    if Active_Discharge_Rate > random 100 and InDNAPool2 = 1 and any? DNAPool2s-here [
     face one-of UntreatedPopulations fd speed  set GoingtoUntreatedPopulation 1 Set InDNAPool2 0 ]
     if GoingtoUntreatedPopulation = 1 [ face one-of UntreatedPopulations fd speed ]
    if any? UntreatedPopulations in-radius 1 [ move-to one-of UntreatedPopulations Set InDNAPool2 0 set InUntreatedPopulation 1 set GoingtoUntreatedPopulation 0 ]
end

to deathincare
   if 60 < random 100 and InAcuteCare = 1 and any? AcuteCares-here [
     face one-of Deathpools fd speed  set GoingtoDeath 1 set InAcutecare 0 ]
   if GoingtoDeath = 1 [ face one-of DeathPools fd speed  ]
    if any? Deathpools in-radius 1 [ move-to one-of Deathpools set InDeath 1 die set InAcutecare 0 ]

 if Death_Rate_Review > random 100 and InReviewPatients = 1 and any? ReviewPatients-here  [
     face one-of Deathpools fd speed  set GoingtoDeath 1 set InReviewPatients 0 ]
   if GoingtoDeath = 1 [ face one-of DeathPools fd speed ]
    if any? Deathpools in-radius 1 [ move-to one-of Deathpools set InDeath 1 die set InReviewPatients 0 ]

 if Death_Rate_LodgeClaim > random 100 and InLodgeClaim = 1 and any? LodgeClaims-here [
    face one-of Deathpools fd speed  set GoingtoDeath 1 set InLodgeClaim 0 ]
   if GoingtoDeath = 1 [ face one-of DeathPools fd speed  ]
    if any? Deathpools in-radius 1 [ move-to one-of Deathpools set InDeath 1 die set InLodgeClaim 0 ]
end

to becomePreventableDeath
  if Death_Rate_Untreated > random 100 and InUntreatedPopulation = 1 and any? UntreatedPopulations-here [
     face one-of PreventableDeaths fd speed  set GoingtoPreventableDeath 1 set inUntreatedPopulation 0  ]
   if GoingtoPreventableDeath = 1 [ face one-of PreventableDeaths fd speed ]
    if any? PreventableDeaths in-radius 1 [ move-to one-of PreventableDeaths set InPreventableDeaths 1 die set inUntreatedPopulation 0 ]
end

to countpreventabledeaths
  set preventabledeathcount ( count patients with [ goingtopreventabledeath = 1 ] )
  set naturaldeathcount ( count patients with [ GoingtoDeath = 1 ] )

end

to UntreatedReEnter
  if Return_to_General > random 100 and InUntreatedPopulation = 1 and any? UntreatedPopulations-here [
     face one-of SAPops fd speed  set GoingtoSAPops 1 set inUntreatedPopulation 0 ]
   if GoingtoSAPops = 1 [ face one-of SAPops fd speed ]
    if any? SAPops in-radius 1 [ move-to one-of SAPops set State1 1 set GoingtoSAPops 0 set inUntreatedPopulation 0 die ]

if Return_to_General > random 100 and InUntreatedPopulation = 1 and any? UntreatedPopulations-here [
     face one-of ReviewPatients fd speed  set GoingtoReviewPatient 1 set inUntreatedPopulation 0 ]
   if GoingtoReviewPatient = 1 [ face one-of ReviewPatients fd speed ]
    if any? Reviewpatients in-radius 1 [ move-to one-of ReviewPatients set InReviewpatients 1 set GoingtoReviewPatient 0 set inUntreatedPopulation 0 ]
end

to NewtoGeneral
  if New_General > random 100 and InNewpatients = 1 and any? newPatients-here [ ;; Patients move from being New back into the General Population
     face one-of SAPops fd speed  set GoingtoSAPops 1 set InNewPatients 0 ]
  if GoingtoSAPops = 1 [ face one-of SAPops fd speed ]
    if any? SAPops in-radius 1 [ move-to one-of SAPops set State1 1 set GoingtoSAPops 0 set InNewPatients 0 die ]
end

to NewtoLodgeClaim
  if New_LodgeClaim > random 100 and InNewpatients = 1 and any? newPatients-here [ ;; Patients move from being New back into the General Population
     face one-of LodgeClaims fd speed  set GoingtoLodgeClaim 1 set InNewPatients 0 ]
  if GoingtoLodgeClaim = 1 [ face one-of LodgeClaims fd speed ]
    if any? LodgeClaims in-radius 1 [ move-to one-of LodgeClaims set InLodgeClaim 1 set GoingtoLodgeClaim 0 set InNewPatients 0 ]
end

to burnpatches
  ask patches [
    if any? patients-here [ set pcolor pcolor + .01 ]
  ]
end

to EngageExpectations
  if goingtoLodgeClaim = 1 [ set timenow1 ticks ] ;; need this to record once and then forget about it
  if any? LodgeClaims-here and ticks - timenow1 > (LodgeClaimexpectations + random Error_of_Estimate - random Error_of_Estimate) [ rememberevents set engaged true set color red ]  ;; OK, so now timmenow only starts at the point at which people go into the LodgeClaim
end

to rememberevents
    if any? LodgeClaims-here and engaged = true [ set memory 1 set timenow ticks ]
   ;; add in more conditions here
    if any? reviewPatients-here [ set memory 1 set timenow ticks ]
    if any? newPatients-here [ set memory 1 set timenow ticks ]
    if any? acuteCares-here [ set memory 1 set timenow ticks ]
    if any? GPs-here and memory = 1 [ set timenow ticks ]

  if ticks - timenow > memoryspan [ set memory 0 set trust trust ] ;; it needs to do nothing if memory = 0 here. Trust needs to go up if a good thing happens, that's all.
      if memory = 0 [ set color white ]
end

to calculatetrustfactor
  if memory = 1 and any? LodgeClaims-here [ set newv ( ( saliencyExpectation * SaliencyExperience ) * (( (MaxTrust / 100) - initialassociationstrength ) ))
    set newassociationstrength ( initialassociationstrength + newv ) set trust trust - newassociationstrength ]
  ;;add in more here
  if memory = 1 and any? reviewPatients-here [ set newv ( ( saliencyExpectation * SaliencyExperience ) * (( (MaxTrust / 100) - initialassociationstrength ) ))
    set newAssociationStrength ( initialassociationstrength - newv ) set trust trust + newassociationstrength]
  if memory = 1 and any? newPatients-here [ set newv ( ( saliencyExpectation * SaliencyExperience ) * (( (MaxTrust / 100) - initialassociationstrength ) ))
    set newassociationstrength ( initialassociationstrength - newv ) set trust trust + newassociationstrength]
  if memory = 1 and any? acuteCares-here [ set newv ( ( saliencyExpectation * SaliencyExperience ) * (( (MaxTrust / 100) - initialassociationstrength ) ))
    set newassociationstrength ( initialassociationstrength - newv ) set trust trust + newassociationstrength]

  set vmax (MaxTrust / 100) set vmin MinTrust
  if newv > (MaxTrust / 100) [ set newv (MaxTrust / 100) ]
  if newv < MinTrust [ set newv MinTrust ]

  if saliencyExpectation > 1 [ set saliencyExpectation 1 ]
  if saliencyExpectation <= 0 [ set saliencyExpectation 0 ]
  if saliencyExperience > 1 [ set SaliencyExperience 1 ]
  if saliencyExperience <= 0 [ set SaliencyExperience 0 ]
end

to resetinitial
    if newassociationstrength <= MaxTrust [ set initialassociationstrength ( newassociationstrength ) ]
end

to createNewPatients
 if count patients < MaxPatients [ create-patients New_Patients  [ set shape "person" set state1 0 move-to one-of SAPops set color white set trust random-normal 80 10 set speed random-normal 1 .1
    resettrust set memory_Span random-normal Memoryspan 30 set memory 0 set initialassociationstrength InitialV
    set saliencyExpectation random-normal ExpectationSaliency .1 set SaliencyExperience random-normal ExperienceSaliency .1 set LodgeClaimExpectations ManageExpectations ] ;;ifelse any? patients with [ GoingtoSAPops = 1 ] and Expectation > random 100   set trust mean [ trust ] of patients with [ GoingtoSApops = 1 ] ][ set trust random-normal 80 10 resettrust

  ]
end


to limitInitialAssociation
  if initialassociationstrength < InitialV [ set initialassociationstrength InitialV ]
end

to SocialEpi
  if any? other patients-here with [ trust <  [ trust ] of myself ] [ set trust trust - 1 ]
  if any? other patients-here with [ trust >  [ trust ] of myself ] [ set trust trust + 1 ]
end

to colourme
  if trust < 0 [ set color green ]
end
@#$#@#$#@
GRAPHICS-WINDOW
315
10
866
562
-1
-1
10.65
1
10
1
1
1
0
0
0
1
0
50
0
50
1
1
1
ticks
30.0

BUTTON
10
10
75
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
10
50
75
83
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
1208
352
1315
397
Total Patients
count Patients * 10
0
1
11

SLIDER
80
10
185
43
Population
Population
0
500
0.0
10
1
NIL
HORIZONTAL

MONITOR
1208
401
1274
446
With GP
count Patients with [ inGP = 1 ] * 10
0
1
11

PLOT
878
11
1641
347
Patient States
Time
Amount
0.0
3.0
0.0
10.0
true
true
"" "if ticks = 100 [ clear-plot ] \n\nif \"Reset Patients\" = true [ clear-plot ] "
PENS
"New Patients" 1.0 0 -11085214 true "" "plot count patients with [ inNewPatients = 1 ] "
"Review Patients" 1.0 0 -14454117 true "" "plot count patients with [ inreviewPatients = 1 ] "
"With GP" 1.0 0 -2674135 true "" "plot count patients with [ InGP = 1 ] "
"In Waitlist" 1.0 0 -16777216 true "" "plot count patients with [ inLodgeClaim = 1 ] "
"Trust" 1.0 0 -7500403 true "" "plot mean [ trust ] of patients"
"Trust In Waitlist" 1.0 0 -955883 true "" "plot mean [ trust ] of patients with [ inWaitlist = 1 ] "
"Trust In New" 1.0 0 -1184463 true "" "plot mean [ trust ] of patients with [ inNewPatients = 1 ] "
"Trust In Review" 1.0 0 -13345367 true "" "plot mean [ trust ] of patients with [ inReviewPatients = 1 ] "

MONITOR
1338
401
1429
446
New Patients
count patients with [InNewPatients = 1] * 10
0
1
11

MONITOR
1319
352
1429
397
Review Patients
count patients with [Inreviewpatients = 1 ] * 10
0
1
11

BUTTON
196
12
308
45
Reset Patients
ask patients [ die ] \nask turtles [ set size 5 ] 
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
197
48
308
81
Trace Paths
ask patients [ pen-down ] 
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
878
352
1203
573
DNA States
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" "if remainder ticks 3000 =  0 [ clear-plot ]  \n\n;;if \"Reset patients\" = true [ clear-plot ] "
PENS
"DNA Pool 1 " 1.0 0 -16777216 true "" "plot count patients with [ InDNAPool1 = 1 ] "
"DNA Pool 2 " 1.0 0 -7500403 true "" "plot count patients with [ InDNAPool2 = 1 ] "
"Total DNA Costs" 1.0 0 -2674135 true "" "plot count patients with [ InDNAPool1 = 1 ] + count patients with [ InDNAPool2 = 1 ] "

PLOT
1210
479
1646
599
Deaths
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" "if ticks = 100 [ clear-plot ] \nif remainder ticks 3001 =  0 [ clear-plot ]  \n\n;; if \"Reset Patients\" = true [ clear-plot ] "
PENS
"Preventable Deaths" 1.0 0 -14070903 true "" "plot preventabledeathcount"
"Natural Deaths" 1.0 0 -2674135 true "" "plot naturaldeathcount"

SLIDER
20
155
146
188
GP_Referral_Barrier
GP_Referral_Barrier
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
20
188
145
221
LodgeClaim_Delay
LodgeClaim_Delay
0
100
90.0
1
1
NIL
HORIZONTAL

SLIDER
149
157
281
190
Acute_Care_Barrier
Acute_Care_Barrier
0
100
70.0
1
1
NIL
HORIZONTAL

SLIDER
69
473
246
506
New_to_Review
New_to_Review
1
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
67
264
247
297
DNA1_to_Review_Rate
DNA1_to_Review_Rate
0
100
86.0
1
1
NIL
HORIZONTAL

SLIDER
67
299
246
332
DNA2_to_Review_Rate
DNA2_to_Review_Rate
0
100
91.0
1
1
NIL
HORIZONTAL

SLIDER
325
612
456
645
DNA1_Rate
DNA1_Rate
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
325
647
457
680
DNA2_Rate
DNA2_Rate
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
67
334
246
367
Death_Rate_Untreated
Death_Rate_Untreated
0
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
68
368
255
402
Death_Rate_LodgeClaim
Death_Rate_LodgeClaim
0
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
70
733
245
766
Active_Discharge_Rate
Active_Discharge_Rate
0
100
2.0
1
1
NIL
HORIZONTAL

CHOOSER
81
48
189
93
New_Patients
New_Patients
1 2 3 4 5 10 20
6

SLIDER
67
407
245
440
Death_Rate_Review
Death_Rate_Review
0
100
6.0
1
1
NIL
HORIZONTAL

MONITOR
1278
401
1335
446
Waitlist
count patients with [ inwaitlist = 1 ] * 10
0
1
11

SLIDER
69
441
245
474
Return_to_General
Return_to_General
0
100
6.0
1
1
NIL
HORIZONTAL

TEXTBOX
325
577
475
605
Rate at which patients DNA\nat each level
11
0.0
1

MONITOR
1433
352
1510
397
DNA Total
( count patients with [ InDNAPool1 = 1 ] +\ncount patients with [ InDNAPool2 = 1 ] ) * 10
0
1
11

SLIDER
149
190
281
223
SOSCapacity
SOSCapacity
1
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
69
508
245
541
Emergency_Pres
Emergency_Pres
0
100
17.0
1
1
NIL
HORIZONTAL

SLIDER
69
543
245
576
Acute_to_Review
Acute_to_Review
0
100
82.0
1
1
NIL
HORIZONTAL

SLIDER
70
583
245
616
DNA_From_GP_Rate
DNA_From_GP_Rate
0
100
13.0
1
1
NIL
HORIZONTAL

BUTTON
520
571
666
604
System Performance
ask patches [ set pcolor black ] 
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
693
572
866
605
MemorySpan
MemorySpan
0
365
180.0
1
1
NIL
HORIZONTAL

SLIDER
692
606
865
639
MaxTrust
MaxTrust
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
693
640
866
673
MinTrust
MinTrust
0
1
0.0
.01
1
NIL
HORIZONTAL

SLIDER
504
612
677
645
InitialV
InitialV
0
1
0.0
.01
1
NIL
HORIZONTAL

SLIDER
882
579
1055
612
ExperienceSaliency
ExperienceSaliency
0
1
0.8
.01
1
NIL
HORIZONTAL

SLIDER
883
615
1056
648
ExpectationSaliency
ExpectationSaliency
0
1
0.8
.01
1
NIL
HORIZONTAL

BUTTON
210
99
290
133
Go Once
Go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
70
621
243
654
New_General
New_General
0
100
13.0
1
1
NIL
HORIZONTAL

SLIDER
70
657
243
690
New_LodgeClaim
New_LodgeClaim
0
100
42.0
1
1
NIL
HORIZONTAL

SLIDER
71
695
244
728
Review_General
Review_General
0
100
49.0
1
1
NIL
HORIZONTAL

BUTTON
38
100
180
134
Heat Wave
create-patients 500 [ set shape \"person\" set state1 0 move-to one-of SAPops set color white set trust random-normal 80 10 set speed random-normal 1 .1\n    resettrust set memory_Span random-normal Memoryspan 30 set memory 0 set initialassociationstrength InitialV \n    set saliencyExpectation random-normal ExpectationSaliency .1 set SaliencyExperience random-normal ExperienceSaliency .1 set LodgeClaimExpectations ManageExpectations ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
497
654
591
714
Review_Capacity
30.0
1
0
Number

INPUTBOX
589
654
683
714
New_Capacity
60.0
1
0
Number

MONITOR
1090
604
1149
649
Patients
count patients
0
1
11

MONITOR
908
63
966
108
Trust
Mean [ trust ] of patients
1
1
11

BUTTON
497
717
590
751
Day_Off
\nif remainder ticks 50 = 0 [ \nset Review_Capacity 0 ]\n\n\nif remainder ticks 50 = 1 [ \nset Review_Capacity 30 ]\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
593
717
688
751
Day_Off_New
if remainder ticks 50 = 0 [ \nset New_Capacity 0 ]\n\nif remainder ticks 50 = 1 [ \nset New_Capacity 60 ]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
302
688
474
721
MaxPatients
MaxPatients
0
2000
2000.0
50
1
NIL
HORIZONTAL

SLIDER
303
729
475
762
Expectation
Expectation
0
100
90.0
10
1
NIL
HORIZONTAL

SLIDER
693
675
865
708
OverBookingRate
OverBookingRate
0
2
1.0
.01
1
NIL
HORIZONTAL

TEXTBOX
78
235
241
257
No Barrier to High Barrier
14
0.0
1

MONITOR
1435
402
1511
447
Trust
mean [ trust ] of patients with [ InWaitlist = 1 ]
1
1
11

PLOT
1213
605
1426
755
Trust histogram
NIL
NIL
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "histogram [ trust ] of patients"

SLIDER
885
655
1058
688
ManageExpectations
ManageExpectations
0
50
6.0
1
1
NIL
HORIZONTAL

SLIDER
885
695
1060
728
Error_of_Estimate
Error_of_Estimate
0
50
10.0
1
1
NIL
HORIZONTAL

PLOT
1430
605
1647
755
Association
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Association" 1.0 0 -16777216 true "" "plot mean [ newassociationstrength ] of patients * 10"

PLOT
707
737
1215
887
Overall Trust
NIL
NIL
0.0
10.0
40.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [ trust ] of patients"

@#$#@#$#@
## WHAT IS IT?
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="RAH" repetitions="8" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go

if ticks = 500 [ create-patients 500 [ set shape "person" set state1 0 move-to one-of SAPops set color white set trust random-normal 80 10 set speed random-normal 1 .1
    resettrust set memory_Span random-normal Memoryspan 30 set memory 0 set initialassociationstrength InitialV 
    set saliencyExpectation random-normal ExpectationSaliency .1 set SaliencyExperience random-normal ExperienceSaliency .1 set waitlistExpectations ManageExpectations ]]</go>
    <timeLimit steps="700"/>
    <metric>count patients</metric>
    <metric>mean [ trust ] of patients with [ Inwaitlist = 1 ]</metric>
    <metric>mean [ trust ] of patients</metric>
    <metric>count patients with [ InDNAPool1 = 1 ]</metric>
    <metric>count patients with [ InDNAPool2 = 1 ]</metric>
    <metric>count patients with [ InWaitlist = 1 ]</metric>
    <metric>count patients with [ InReviewPatients = 1 ]</metric>
    <metric>count patients with [ InNewPatients = 1 ]</metric>
    <metric>count patients with [ InDeath = 1 ]</metric>
    <metric>count patients with [ InPreventableDeaths = 1 ]</metric>
    <metric>count patients with [ InGP = 1 ]</metric>
    <metric>count patients with [ InAcuteCare = 1 ]</metric>
    <metric>count patients with [ InUntreatedPopulation = 1 ]</metric>
    <enumeratedValueSet variable="DNA1_Rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="New_General">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="New_Patients">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Review_Capacity">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExpectationSaliency">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Emergency_Pres">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Return_to_General">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DNA_From_GP_Rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Population">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DNA2_Rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Death_Rate_Waitlist">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MemorySpan">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acute_Care_Barrier">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperienceSaliency">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Active_Discharge_Rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acute_to_Review">
      <value value="82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="InitialV">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SOSCapacity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="New_Capacity">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Death_Rate_Review">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Waitlist_Delay">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxTrust">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MinTrust">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GP_Referral_Barrier">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DNA1_to_Review_Rate">
      <value value="86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Review_General">
      <value value="49"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DNA2_to_Review_Rate">
      <value value="91"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="New_to_Review">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Death_Rate_Untreated">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="New_Waitlist">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ManageExpectations">
      <value value="0"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Accuracy_of_Estimate">
      <value value="0"/>
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
