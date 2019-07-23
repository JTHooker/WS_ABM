globals [ NoRecoverycount
  DisputeCount]


breed [ VicPops VicPop ]
breed [ AcuteCares AcuteCare ]
breed [ GPs GP ]
breed [ ClaimAccepteds ClaimAccepted ]
breed [ NoRecoverys NoRecovery ]
breed [ TreatmentCentres TreatmentCentre ]
breed [ Disputes Death ]
breed [ Employer1s Employer1 ]
breed [ RTWs RTW ]
breed [ OccRehabProviders OccRehabProvider ]
breed [ LodgeClaims LodgeClaim ]
breed [ Workers Worker ]
breed [ OccRehabResources OccRehabResource ]

Workers-own ; Attributes that individual Workers have or are in at any stage
[
  State1
  InGP
  InEmergency
  InNoRecovery
  InClaimAccepted
  InTreatment
  InDispute
  InOccRehabProvider
  InEmployer1
  InRTW
  InLodgeClaim

  GoingtoGP
  GoingtoAcuteCare
  GoingtoNoRecovery
  GoingtoClaimAccepted
  GoingtoTreatment
  GoingtoDispute
  GoingtoOccRehabProvider
  GoingtoEmployer1
  GoingtoRTW
  GoingtoLodgeClaim
  GoingtoVicPops

  InSystem ;; They have had their claim accepted
  Trust ;; Trust in the system that increases if they have a good experience and decreases if their expectations aren't met
  Memory ;; A boolean memory variable related to their recollection of past treatment or service events
  Memory_Span ;; They forget abut their previous experiences after a certain time-span
  Health ;; They have an incoming health variable related to their injury / 100
  ClaimType ;; A boolean flag determining if their injury is a mental health claim
  Satisfaction ;; Overall satisfaction score / 100 rises with treatment and access, decreases with disputes - need to link it to health
  Entrytime ;; The tick that the worker's claim is accepted by the injury rehabilitation system
  Timenow ;; Ticks on initial referral to WorkSafe Claim
  Timenow1 ;; Tiicks related to ultimate assessment of eligibility
  saliencyexpectation ;; How connected the expectation of service is to the experience
  saliencyexperience ;; How connected the experience is to the expectation
  initialassociationstrength ;; The association (essentially learning rate ) between the worker's experience of the system and how they react to it.
  newv ;; used in calculatio nof the above
  newassociationstrength ;; as above
  vmax ;; maximum association
  vmin ;; minimum association
  speed ;; speed of the agent through the network across the plane
  LodgeClaimExpectations ;; expectations of how long it will take for their claim to be accepted
  engaged ;; Flag for if the worker remembers events
  Responsiveness ;; How responsive the worker is to treatment provided
  CostsTreatment ;; Costs of treatment received
  CostsWageReplacement ;; Costs of Wage Replacement
  Salary ;; Salary of the individual

  ;; need to add costs

]

Employer1s-own [
  readiness ;; How ready the employer is to take the worker back with adjusted duties
]


to setup
  clear-all
  ask patches [ set pcolor green ]
  create-GPs 1 [ set shape "person doctor" set size 5 set label "GP" set xcor 13.92 set ycor 42.25 set color brown]
  create-AcuteCares 1 [ set shape "ambulance" set size 5 set label "Emergency Care" set xcor 6.35 set ycor 33.52 set color red ]
  create-LodgeClaims 1 [ set shape "person business" set size 5 set label "LodgeClaim" set xcor 4.71 set ycor 22.1 set color orange ]
  create-ClaimAccepteds 1 [ set shape "computer workstation" set size 5 set label "Accepted_Claim" set xcor 9.51 set ycor 11.58 set color white ]
  create-NoRecoverys 1 [ set shape "Garbage Can"  set size 5 set label "No Recovery" set xcor 19.22 set ycor 5.33 set color white]
  create-TreatmentCentres 1 [ set shape "Building institution"  set size 5 set label "Treatment Centre" set xcor 30.77 set ycor 5.33 set color grey ]
  create-Disputes 1 [ set shape "Exclamation"  set size 5 set label "Disputes" set xcor 40.49 set ycor 11.58 set color red ]
  create-Employer1s 1 [ set shape "person construction" set size 5 set label "Employer" set xcor 45.29 set ycor 22.08 set color white set readiness random-normal 50 10 ]
  create-RTWs 1 [ set shape "box" set size 5 set label "Return to Work Pool" set xcor 43.65 set ycor 33.52 set color red ]
  create-OccRehabProviders 1 [ set shape "box" set size 5 set label "Occ Rehab Provider" set xcor 36.08 set ycor 42.25 set color yellow ]
  create-VicPops 1 [ set shape "Factory" set xcor 25 set ycor 25 set size 5 set label "General Population" set xcor 25 set ycor 45.5 set color white ]
  create-OccRehabResources 1 [ set shape "dot" set color blue move-to one-of OccRehabProviders ]
  ask turtles [ create-links-with other turtles show label ]
  create-workers Population [ set shape one-of [ "person" "person doctor" "person construction" "person business" "person farmer"] set state1 0 move-to one-of VicPops set color white set trust random-normal 80 3 set speed random-normal 1 .1 ]
  ask workers [ set satisfaction random-normal 70 5 set responsiveness random-normal 1 .01 resettrust set memory_Span random-normal Memoryspan 30 set memory 0 set initialassociationstrength InitialV
    set saliencyExpectation random-normal ExpectationSaliency .1 set SaliencyExperience random-normal ExperienceSaliency .1 set LodgeClaimExpectations ManageExpectations
    set health random-normal 50 10 isClaimType set salary random-normal 55 20 ]
  setup-image
  reset-ticks
end

to isClaimType
  set ClaimType one-of [ 0 1 2 ]

  if claimType = 0 [ set label "A" ]
  if claimType = 1 [ set label "C" ]
  if claimType = 2 [ set label "M" ]

end

to setup-image
 ;; import-drawing "wslogo.jpg"
end


to resettrust
  if trust > 100 or trust < 1 [ set trust random-normal 80 3 ]
  if saliencyExpectation > 1 or saliencyExpectation <= 0 [ set saliencyExpectation random-normal ExpectationSaliency 10 ]
  if saliencyExperience > 1 or saliencyExperience <= 0 [ set saliencyExpectation random-normal ExpectationSaliency 10 ]
  if health > 100 or health < 1 [ set health random-normal 50 10 ]
  if satisfaction > 100 or satisfaction < 10 [ set satisfaction trust ]
  if salary < 25 [ set salary random-normal 55 20 ]
end

to go
  ask workers [
    initialise
    GPreferral
    Emergency
    Disputesincare
    BecomeAcceptedClaim
    AccessTreatment
    ToEmployerfromTreatment
    ReturntoWork
    OccRehabSupport
    becomeNoRecovery
    UntreatedReEnter
    EmployernotReady
    becomeLodgeClaim
    NewtoLodgeClaim
    EmployerfromGP
    TreatmentToGeneral
    DisputetoGeneral
    TestDispute
    Captrust
    calculateTrustFactor
    Rememberevents
    Resetinitial
    LimitInitialAssociation
    OverCapReview
    OverCapNew
    SocialEpi
    EngageExpectations
    Colourme
    RemoveHealthyWorkers
    CountTreatmentCosts
    CountWageReplacementCosts
  ]


  ask turtles [
    set size (5 + sqrt count Workers in-radius 1 )
      ]
  ask Workers [ set size 1 ]
  createClaimAccepteds
  countNoRecoverys
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
  if GP_referral_barrier < random 100 and state1 = 1 and any? VicPops-here  [
    face one-of GPs fd speed set goingtoGP 1 set state1 0 ]
     if goingtoGP = 1 [ face one-of GPs fd speed ]
       if any? GPs in-radius 1 [ move-to one-of GPs set InGP 1 set goingtoGP 0 set state1 0 set CostsTreatment Coststreatment + .1 ]
end

to Emergency ;; individuals emerging from the general population into emergency areas of hospitals
    if Emergency_Pres < random 100 and state1 = 1 and InEmergency = 0 and any? VicPops-here [
      face one-of AcuteCares fd speed  set GoingtoAcuteCare 1 set State1 0 ]
       if GoingtoAcuteCare = 1 [ face one-of AcuteCares fd speed ]
        if any? AcuteCares in-radius 1 [ move-to one-of AcuteCares set InEmergency 1 set InGP 0 set GoingtoAcuteCare 0 set CostsTreatment Coststreatment + 1 ]
end

to BecomeLodgeClaim ;;
     if Acute_Care_Barrier < random 100 and InEmergency = 1 and any? AcuteCares-here and health < Claim_Threshold [
    face one-of LodgeClaims fd speed  set goingtoLodgeClaim 1 set InEmergency 0 ]
   if goingtoLodgeClaim = 1 [ Face one-of LodgeClaims fd speed ]
        if any? LodgeClaims in-radius 1 [ move-to one-of LodgeClaims Set InLodgeClaim 1 set InEmergency 0 set GoingtoLodgeClaim 0  ]

    if GP_Referral_Barrier < random 100 and InGP = 1 and any? GPs-here and health < Claim_Threshold [
      face one-of LodgeClaims fd speed  set goingtoLodgeClaim 1 set InGP 0 ]
    if goingtoLodgeClaim = 1 [ Face one-of LodgeClaims fd speed ]
        if any? LodgeClaims in-radius 1 [ move-to one-of LodgeClaims Set InLodgeClaim 1 set InGP 0 set GoingtoLodgeClaim 0  ]
end

to BecomeAcceptedClaim
  if Label = "A" and InLodgeClaim = 1 and any? LodgeClaims-here
  and count Workers with [  InClaimAccepted = ( 1 * OverbookingRate )]  < New_Capacity and (random-normal 0.9 .1 ) * (random-normal 0.8 .1 ) > Accept_Threshold [
  face one-of ClaimAccepteds fd speed set goingtoClaimAccepted 1 Set InLodgeClaim 0  ]

   if Label = "C" and InLodgeClaim = 1 and any? LodgeClaims-here
  and count Workers with [  InClaimAccepted = ( 1 * OverbookingRate )]  < New_Capacity and (random-normal 0.6 .1 ) * (random-normal 0.8 .1 ) > Accept_Threshold [
  face one-of ClaimAccepteds fd speed set goingtoClaimAccepted 1 Set InLodgeClaim 0  ]

   if Label = "M" and InLodgeClaim = 1 and any? LodgeClaims-here
   and count Workers with [  InClaimAccepted = ( 1 * OverbookingRate )]  < New_Capacity and (random-normal 0.4 .1 ) * (random-normal 0.8 .1 ) > Accept_Threshold [
   face one-of ClaimAccepteds fd speed set goingtoClaimAccepted 1 Set InLodgeClaim 0  ]

  if any? ClaimAccepteds in-radius 1 [ move-to one-of ClaimAccepteds Set InClaimAccepted 1 Set InLodgeClaim 0 set goingtoClaimAccepted 0 set InSystem 1 set Entrytime ticks ]

end

to AccessTreatment
    if Accepted_to_treatment < random 100 and InClaimAccepted = 1 and any? ClaimAccepteds-here and count Workers with [  InTreatment = 1 ] < Review_Capacity  [
      face one-of TreatmentCentres fd speed  set Goingtotreatment 1 Set InClaimAccepted 0  ]
    if GoingtoTreatment = 1 [ face one-of TreatmentCentres fd speed  ]
      if any? TreatmentCentres in-radius 1 [ move-to one-of TreatmentCentres Set InTreatment 1 Set InClaimAccepted 0 set GoingtoTreatment 0 set health ( health * 1.01 * Responsiveness )]

if Emergency_to_Accepted > random 100 and InEmergency = 1 and any? AcuteCares-here [
      face one-of ClaimAccepteds fd speed set GoingtoClaimAccepted 1 Set InEmergency 0 ]
    if GoingtoClaimAccepted = 1 [ face one-of ClaimAccepteds fd speed  ]
      if any? ClaimAccepteds in-radius 1 [ move-to one-of ClaimAccepteds Set InClaimAccepted 1 set GoingtoCLaimAccepted 0 ]
end

to OverCapNew
  if inClaimAccepted = 1 and count Workers with [ inClaimAccepted = 1 ] > New_Capacity [
    face one-of LodgeClaims fd speed  set goingtoLodgeClaim 1 set InClaimAccepted 0 ]
    if goingtoLodgeClaim = 1 [ Face one-of LodgeClaims fd speed ]
    if any? LodgeClaims in-radius 1 [ move-to one-of LodgeClaims Set InLodgeClaim 1 set InClaimAccepted 0 set GoingtoLodgeClaim 0  ]
end

to OverCapReview
    if InTreatment = 1 and count Workers with [ InTreatment = 1 ] > Review_Capacity [
    face one-of LodgeClaims fd speed  set goingtoLodgeClaim 1 set InTreatment 0 ]
    if goingtoLodgeClaim = 1 [ Face one-of LodgeClaims fd speed ]
        if any? LodgeClaims in-radius 1 [ move-to one-of LodgeClaims Set InLodgeClaim 1 set InTreatment 0 set GoingtoLodgeClaim 0  ]
end

to ToEmployerfromTreatment ;; in here is where trust is going to affect the DNA rate
   if (health + (100 - trust)) > random 100 and InTreatment = 1 and any? TreatmentCentres-here [ ;; people are more likely to DNA at any stage if their levels of trust are lower
     face one-of Employer1s fd speed set GoingtoEmployer1 1 set InTreatment 0 ]
     if GoingtoEmployer1 = 1 [ face one-of Employer1s fd speed ]
    if any? Employer1s in-radius 1 [ move-to one-of Employer1s Set InEmployer1 1 set InTreatment 0 set GoingtoEmployer1 0 ]
end

to EmployerFromGP ;; trust is going affect the DNA rate here
  if (Employer_from_GP_Rate + (100 - trust) ) > random 100 and InGP = 1 and any? GPs-here and health > 50 [
     face one-of Employer1s fd speed  set GoingtoEmployer1 1 set InGP 0 ]
     if GoingtoEmployer1 = 1 [ face one-of Employer1s fd speed ]
    if any? Employer1s in-radius 1 [ move-to one-of Employer1s Set InEmployer1 1 set InGP 0 set GoingtoEmployer1 0 ]
end

to TreatmentToGeneral
  if Review_General > random 100 and InTreatment = 1 and any? TreatmentCentres-here [
     face one-of VicPops fd speed  set GoingtoVicPops 1 set InTreatment 0  ] ;;DNA Rate is inversely proportional to trust
     if GoingtoVicPops = 1 [ face one-of VicPops fd speed ]
    if any? VicPops in-radius 1 [ move-to one-of VicPops die ]
end

to TestDispute
   ifelse Success_Dispute_Lodge > random 100 and InDispute = 1 and any? Disputes-here and InSystem = 0 [
     face one-of LodgeClaims fd speed  set GoingtoLodgeClaim 1 set InDispute 0 set trust (trust * .99) ] [ DisputetoGeneral ]
    if GoingtoLodgeClaim = 1 [ face one-of LodgeClaims fd speed ]
    if any? LodgeClaims in-radius 1 [ move-to one-of LodgeClaims Set InLodgeClaim 1 set GoingtoLodgeClaim 0 ]
end

to DisputetoGeneral
    if Success_Dispute_Lodge > random 100 and InDispute = 1 and any? Disputes-here and InSystem = 1 [
    face one-of VicPops fd speed  set GoingtoVicPops 1 set InDispute 0  ]
     if GoingtoVicPops = 1 [ face one-of VicPops fd speed ]
    if any? VicPops in-radius 1 [ move-to one-of VicPops die  ]
end

to DisputeToTreatment
  if Success_Dispute_Lodge > random 100 and InDispute = 1 and any? Disputes-here and InSystem = 1 [
     face one-of TreatmentCentres fd speed  set GoingtoTreatment 1 set InDispute 0 set trust (trust * .9) set satisfaction satisfaction * .95 ]
    if GoingtoTreatment = 1 [ face one-of TreatmentCentres fd speed ]
    if any? TreatmentCentres in-radius 1 [ move-to one-of TreatmentCentres set InTreatment 1 set GoingtoTreatment 0 set health (health * responsiveness) ]
end

to ReturntoWork ;; trust is going to affec the DNA2 rate here
  if health + [ readiness ] of one-of Employer1s > random 100 and InEmployer1 = 1 and any? Employer1s-here [
     face one-of RTWs fd speed set GoingtoRTW 1 set InEmployer1 0 ]
     if GoingtoRTW = 1 [ face one-of RTWs fd speed ]
    if any? RTWs in-radius 1 [ move-to one-of RTWs Set InRTW 1 set InEmployer1 0 set GoingtoRTW 0 ]
end

to EmployernotReady ;; trust is going to affect the likelihood that anyone comes ouut of DNA1 back to review here
  if [ readiness ] of one-of Employer1s < 50 and any? Employer1s-here [
      face one-of TreatmentCentres fd speed  set GoingtoTreatment 1 Set InEmployer1 0 ]
    if GoingtoTreatment = 1 [ face one-of TreatmentCentres fd speed  ]
      if any? TreatmentCentres in-radius 1 [ move-to one-of TreatmentCentres Set InTreatment 1 Set InEmployer1 0 set GoingtoTreatment 0 ]

  ;; trust is going to affect the likelihood that anyone comes ouut of DNA1 back to review here
if Trust > random 100 and InRTW = 1 and any? RTWs-here [
      face one-of VicPops fd speed  set GoingtoVicPops 1 Set InRTW 0 ]
    if GoingtoVicPops = 1 [ face one-of VicPops fd speed  ]
      if any? VicPops in-radius 1 [ move-to one-of VicPops Set InRTW 0 die ]
end

to OccRehabSupport
    if Occ_Rehab_Support_Need > random 100 and InRTW = 1 and any? RTWs-here [
     face one-of OccRehabProviders fd speed  set GoingtoOccRehabProvider 1 Set InRTW 0 ]
     if GoingtoOccRehabProvider = 1 [ face one-of OccRehabProviders fd speed ]
    if any? OccRehabProviders in-radius 1 [ move-to one-of OccRehabProviders Set InRTW 0 set InOccRehabProvider 1 set GoingtoOccRehabProvider 0 ]
end

to Disputesincare

 if (Dispute_Rate_LodgeClaim  + (100 - trust )) > random 1000 and InLodgeClaim = 1 and any? LodgeClaims-here [
    face one-of Disputes fd speed set GoingtoDispute 1 set InLodgeClaim 0 ]
   if GoingtoDispute = 1 [ face one-of Disputes fd speed  ]
    if any? Disputes in-radius 1 [ move-to one-of Disputes set GoingtoDispute 0 set InDispute 1 set InLodgeClaim 0 set satisfaction satisfaction * .99 set trust trust * .5 ]

  if (Dispute_Rate_Review + (100 - trust )) > random 100 and InTreatment = 1 and any? TreatmentCentres-here  [
     face one-of Disputes fd speed  set GoingtoDispute 1 set InTreatment 0 ]
   if GoingtoDispute = 1 [ face one-of Disputes fd speed ]
    if any? Disputes in-radius 1 [ move-to one-of Disputes set GoingtoDispute 0 set InDispute 1 set InTreatment 0 set satisfaction satisfaction * .99 set trust trust * .5 ]
end

to CountNoRecoverys
  set NoRecoverycount ( count Workers with [ goingtoNoRecovery = 1 ] )
  set DisputeCount ( count Workers with [ GoingtoDispute = 1 ] )
end

to UntreatedReEnter
  if Return_to_General > random 100 and InOccRehabProvider = 1 and any? OccRehabProviders-here and any? OccRehabResources-here [
     face one-of VicPops fd speed  set GoingtoVicPops 1 set inOccRehabProvider 0 ]
   if GoingtoVicPops = 1 [ face one-of VicPops fd speed ]
    if any? VicPops in-radius 1 [ move-to one-of VicPops set State1 1 set GoingtoVicPops 0 set inOccRehabProvider 0 die ]

ifelse Return_to_General > random 100 and InOccRehabProvider = 1 and any? OccRehabProviders-here and not any? OccrehabResources-here [
    face one-of TreatmentCentres fd speed  set GoingtoTreatment 1 set inOccRehabProvider 0 ] [ BecomeNoRecovery ]
   if GoingtoTreatment = 1 [ face one-of TreatmentCentres fd speed ]
    if any? TreatmentCentres in-radius 1 [ move-to one-of TreatmentCentres set InTreatment 1 set GoingtoTreatment 0 set inOccRehabProvider 0 ]
end

to BecomeNoRecovery
  if InOccRehabProvider = 1 and any? OccRehabProviders-here and not any? OccRehabResources-here [
     face one-of NoRecoverys fd speed set GoingtoNoRecovery 1 set inOccRehabProvider 0  ]
   if GoingtoNoRecovery = 1 [ face one-of NoRecoverys fd speed ]
    if any? NoRecoverys in-radius 1 [ move-to one-of NoRecoverys set inOccRehabProvider 0 set InNoRecovery 1 die ]
end

to NewtoLodgeClaim
  if New_LodgeClaim > random 100 and InClaimAccepted = 1 and any? ClaimAccepteds-here [ ;; Workers move from being New back into the General Population
     face one-of LodgeClaims fd speed  set GoingtoLodgeClaim 1 set InClaimAccepted 0 ]
  if GoingtoLodgeClaim = 1 [ face one-of LodgeClaims fd speed ]
    if any? LodgeClaims in-radius 1 [ move-to one-of LodgeClaims set InLodgeClaim 1 set GoingtoLodgeClaim 0 set InClaimAccepted 0 ]
end

to burnpatches
  ask patches [
    if any? Workers-here [ set pcolor pcolor + .01 ]
  ]
end

to EngageExpectations
  if goingtoLodgeClaim = 1 [ set timenow1 ticks ] ;; need this to record once and then forget about it
  if any? LodgeClaims-here and ticks - timenow1 > (LodgeClaimexpectations + random Error_of_Estimate - random Error_of_Estimate) [ rememberevents set engaged true set color red ]  ;; OK, so now timmenow only starts at the point at which people go into the LodgeClaim
end

to rememberevents
    if any? LodgeClaims-here and engaged = true [ set memory 1 set timenow ticks ]
   ;; add in more conditions here
    if any? TreatmentCentres-here [ set memory 1 set timenow ticks ]
    if any? ClaimAccepteds-here [ set memory 1 set timenow ticks ]
    if any? acuteCares-here [ set memory 1 set timenow ticks ]
    if any? GPs-here and memory = 1 [ set timenow ticks ]

  if ticks - timenow > memoryspan [ set memory 0 set trust trust ] ;; it needs to do nothing if memory = 0 here. Trust needs to go up if a good thing happens, that's all.
      if memory = 0 [ set color white ]
end

to calculatetrustfactor
  if memory = 1 and any? LodgeClaims-here [ set newv ( ( saliencyExpectation * SaliencyExperience ) * (( (MaxTrust / 100) - initialassociationstrength ) ))
    set newassociationstrength ( initialassociationstrength + newv ) set trust trust - newassociationstrength ]
  ;;add in more here
  if memory = 1 and any? TreatmentCentres-here [ set newv ( ( saliencyExpectation * SaliencyExperience ) * (( (MaxTrust / 100) - initialassociationstrength ) ))
    set newAssociationStrength ( initialassociationstrength - newv ) set trust trust + newassociationstrength]
  if memory = 1 and any? ClaimAccepteds-here [ set newv ( ( saliencyExpectation * SaliencyExperience ) * (( (MaxTrust / 100) - initialassociationstrength ) ))
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

to createClaimAccepteds
 if count Workers < MaxWorkers [ create-Workers Injured_Workers [ set shape "person" set state1 0 move-to one-of VicPops set color white set speed random-normal 1 .1
    set trust random-normal 80 3 set satisfaction random-normal 70 5 set responsiveness random-normal 1 .01 set memory_Span random-normal Memoryspan 30 set memory 0 set initialassociationstrength InitialV
    set saliencyExpectation random-normal ExpectationSaliency .1 set SaliencyExperience random-normal ExperienceSaliency .1 set LodgeClaimExpectations ManageExpectations set health random-normal 50 10 IsClaimType
    set salary random-normal 55 20 resettrust
   ] ;;ifelse any? Workers with [ GoingtoVicPops = 1 ] and Expectation > random 100   set trust mean [ trust ] of Workers with [ GoingtoVicPops = 1 ] ][ set trust random-normal 80 10 resettrust
  ]
end

to limitInitialAssociation
  if initialassociationstrength < InitialV [ set initialassociationstrength InitialV ]
end

to SocialEpi
  if any? other Workers-here with [ trust <  [ trust ] of myself ] [ set trust trust - 1 ]
  if any? other Workers-here with [ trust >  [ trust ] of myself ] [ set trust trust + 1 ]
end

to colourme
  if satisfaction = 0  [ set color blue ]
end

to RemoveHealthyWorkers
  if InSystem = 0 and health > Claim_Threshold [ die ]
end

to CountTreatmentCosts
  if InSystem = 1 and any? TreatmentCentres-here [ set CostsTreatment CostsTreatment + random-normal .1 .02 ]
end

to CountWageReplacementCosts
  if InSystem = 1 [ set CostsWageReplacement CostsWageReplacement + (Salary / 365 * .8 ) ]
end
@#$#@#$#@
GRAPHICS-WINDOW
315
10
854
550
-1
-1
7.24
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
1505
462
1570
495
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
1505
502
1570
535
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
Total Workers
count Workers * 10
0
1
11

SLIDER
38
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
count Workers with [ inGP = 1 ] * 10
0
1
11

PLOT
878
11
1641
347
Worker States
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
"New Claimants" 1.0 0 -11085214 true "" "plot count workers with [ inClaimAccepted = 1 ] "
"TreatedPatients" 1.0 0 -14454117 true "" "plot count workers with [ inTreatment = 1 ] "
"With GP" 1.0 0 -2674135 true "" "plot count workers with [ InGP = 1 ] "
"Waiting to Lodge" 1.0 0 -16777216 true "" "plot count workers with [ inLodgeClaim = 1 ] "
"Trust of Accepted" 1.0 0 -7500403 true "" "plot mean [ trust ] of workers with [ inSystem = 1 ] "
"Trust In Waitlist" 1.0 0 -955883 true "" "plot mean [ trust ] of workers with [ inLodgeClaim = 1 ] "
"Trust In New" 1.0 0 -1184463 true "" "plot mean [ trust ] of workers with [ inClaimAccepted = 1 ] "
"Trust In Review" 1.0 0 -13345367 true "" "plot mean [ trust ] of workers with [ inTreatment = 1 ] "

MONITOR
1338
401
1429
446
New Patients
count workers with [InClaimAccepted = 1] * 10
0
1
11

MONITOR
1319
352
1429
397
Review Workers
count workers with [InTreatment = 1 ] * 10
0
1
11

BUTTON
196
12
308
45
Reset Patients
ask workers [ die ] \nask turtles [ set size 5 ] 
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
ask workers [ pen-down ] 
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
472
Costs
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
"Treatment Costs" 1.0 0 -5298144 true "" "plot sum [ CostsTreatment ] of workers with [ InSystem = 1 ] "

PLOT
880
477
1203
597
Unresolved Disputes
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
"Disputes" 1.0 0 -2674135 true "" "plot DisputeCount"

SLIDER
20
155
146
188
GP_Referral_Barrier
GP_Referral_Barrier
0
100
77.0
1
1
NIL
HORIZONTAL

SLIDER
150
156
282
189
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
61
465
236
498
Accepted_to_Treatment
Accepted_to_Treatment
1
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
59
256
239
289
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
59
291
241
324
RTW_to_General_Population
RTW_to_General_Population
0
100
91.0
1
1
NIL
HORIZONTAL

SLIDER
59
326
238
359
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
60
360
238
393
Dispute_Rate_LodgeClaim
Dispute_Rate_LodgeClaim
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
60
728
238
764
Occ_Rehab_Support_Need
Occ_Rehab_Support_Need
0
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
59
399
237
432
Dispute_Rate_Review
Dispute_Rate_Review
0
100
51.0
1
1
NIL
HORIZONTAL

MONITOR
1278
401
1335
446
Lodged
count workers with [ inLodgeClaim = 1 ] * 10
0
1
11

SLIDER
61
433
237
466
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

SLIDER
61
500
237
533
Emergency_Pres
Emergency_Pres
0
100
13.0
1
1
NIL
HORIZONTAL

SLIDER
61
535
240
568
Emergency_to_Accepted
Emergency_to_Accepted
0
100
35.0
1
1
NIL
HORIZONTAL

SLIDER
62
575
237
608
Employer_From_GP_Rate
Employer_From_GP_Rate
0
100
53.0
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
696
649
869
682
MemorySpan
MemorySpan
0
365
53.0
1
1
NIL
HORIZONTAL

SLIDER
695
683
868
716
MaxTrust
MaxTrust
0
100
90.0
1
1
NIL
HORIZONTAL

SLIDER
696
716
869
749
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
0.5
.01
1
NIL
HORIZONTAL

SLIDER
878
610
1051
643
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
879
646
1052
679
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
1503
542
1583
576
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
62
613
235
646
New_General
New_General
0
100
35.0
1
1
NIL
HORIZONTAL

SLIDER
60
652
233
685
New_LodgeClaim
New_LodgeClaim
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
61
690
234
723
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
1693
243
1835
277
Mass-Incident
create-Workers 500 [ set shape \"person\" set state1 0 move-to one-of VicPops set color white set trust random-normal 80 10 set speed random-normal 1 .1\n    resettrust set memory_Span random-normal Memoryspan 30 set memory 0 set initialassociationstrength InitialV \n    set saliencyExpectation random-normal ExpectationSaliency .1 set SaliencyExperience random-normal ExperienceSaliency .1 set LodgeClaimExpectations ManageExpectations ]
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
50.0
1
0
Number

INPUTBOX
589
654
683
714
New_Capacity
100.0
1
0
Number

MONITOR
908
63
966
108
Trust
Mean [ trust ] of workers with [ InSystem = 1 ]
1
1
11

BUTTON
497
717
590
751
Day_Off
\nif remainder ticks Processing_Capacity = 0 [ \nset Review_Capacity 0 ]\n\n\nif remainder ticks Processing_Capacity = 1 [ \nset Review_Capacity 50 ]\n
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
if remainder ticks Processing_Capacity = 0 [ \nset New_Capacity 0 ]\n\nif remainder ticks Processing_Capacity = 1 [ \nset New_Capacity 100 ]
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
306
635
478
668
MaxWorkers
MaxWorkers
0
2000
2000.0
50
1
NIL
HORIZONTAL

SLIDER
308
676
480
709
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
696
752
868
785
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
88
235
251
257
No Barrier to High Barrier
14
0.0
1

MONITOR
1439
354
1589
399
Trust of Accepted Claims
mean [ trust ] of workers with [ InSystem = 1 ]
1
1
11

PLOT
1064
612
1277
762
Trust histogram
NIL
NIL
0.0
100.0
0.0
10.0
true
true
"" ""
PENS
"Trust" 1.0 0 -5298144 true "" "histogram [ trust ] of workers"
"Health" 1.0 0 -14070903 true "" "histogram [ health ] of workers"
"Satisfaction" 1.0 0 -14439633 true "" "histogram [ Satisfaction ] of workers"

SLIDER
881
686
1054
719
ManageExpectations
ManageExpectations
0
50
20.0
1
1
NIL
HORIZONTAL

SLIDER
881
726
1056
759
Error_of_Estimate
Error_of_Estimate
0
50
9.0
1
1
NIL
HORIZONTAL

PLOT
1212
475
1429
599
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
"Association" 1.0 0 -16777216 true "" " plot mean [ newassociationstrength * 10 ] of workers "

PLOT
1286
612
1650
762
Overall Trust
NIL
NIL
0.0
10.0
40.0
100.0
true
true
"" ""
PENS
"Mean Trust" 1.0 0 -5298144 true "" "if ticks > 0 [ plot mean [ trust ] of workers ]"
"Mean Satisfaction" 1.0 0 -13840069 true "" "if ticks > 0 [ plot mean [ satisfaction ] of workers ] "

SLIDER
60
765
235
798
Dispute_to_General
Dispute_to_General
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
59
803
235
836
Success_Dispute_Lodge
Success_Dispute_Lodge
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
505
757
677
790
Processing_Capacity
Processing_Capacity
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
308
713
480
746
Recovery_Threshold
Recovery_Threshold
0
100
80.0
1
1
NIL
HORIZONTAL

SLIDER
306
753
478
786
Claim_Threshold
Claim_Threshold
0
100
70.0
1
1
NIL
HORIZONTAL

SLIDER
37
47
185
80
Injured_Workers
Injured_Workers
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
1668
22
1841
57
Mental_health_freq
Mental_health_freq
0
100
5.0
1
1
NIL
HORIZONTAL

PLOT
1656
612
1856
762
Salary
NIL
NIL
0.0
200.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "histogram [ salary ] of workers"

SLIDER
330
482
463
517
Accept_Threshold
Accept_Threshold
0
2
0.1
.1
1
NIL
HORIZONTAL

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

ambulance
false
0
Rectangle -7500403 true true 30 90 210 195
Polygon -7500403 true true 296 190 296 150 259 134 244 104 210 105 210 190
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Circle -16777216 true false 69 174 42
Rectangle -1 true false 288 158 297 173
Rectangle -1184463 true false 289 180 298 172
Rectangle -2674135 true false 29 151 298 158
Line -16777216 false 210 90 210 195
Rectangle -16777216 true false 83 116 128 133
Rectangle -16777216 true false 153 111 176 134
Line -7500403 true 165 105 165 135
Rectangle -7500403 true true 14 186 33 195
Line -13345367 false 45 135 75 120
Line -13345367 false 75 135 45 120
Line -13345367 false 60 112 60 142

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

building institution
false
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Rectangle -16777216 false false 0 255 300 270
Polygon -7500403 true true 0 60 150 15 300 60
Polygon -16777216 false false 0 60 150 15 300 60
Circle -1 true false 135 26 30
Circle -16777216 false false 135 25 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

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

clock
true
0
Circle -7500403 true true 30 30 240
Polygon -16777216 true false 150 31 128 75 143 75 143 150 158 150 158 75 173 75
Circle -16777216 true false 135 135 30

computer workstation
false
0
Rectangle -7500403 true true 60 45 240 180
Polygon -7500403 true true 90 180 105 195 135 195 135 210 165 210 165 195 195 195 210 180
Rectangle -16777216 true false 75 60 225 165
Rectangle -7500403 true true 45 210 255 255
Rectangle -10899396 true false 249 223 237 217
Line -16777216 false 60 225 120 225

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

exclamation
false
0
Circle -7500403 true true 103 198 95
Polygon -7500403 true true 135 180 165 180 210 30 180 0 120 0 90 30

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

factory
false
0
Rectangle -7500403 true true 76 194 285 270
Rectangle -7500403 true true 36 95 59 231
Rectangle -16777216 true false 90 210 270 240
Line -7500403 true 90 195 90 255
Line -7500403 true 120 195 120 255
Line -7500403 true 150 195 150 240
Line -7500403 true 180 195 180 255
Line -7500403 true 210 210 210 240
Line -7500403 true 240 210 240 240
Line -7500403 true 90 225 270 225
Circle -1 true false 37 73 32
Circle -1 true false 55 38 54
Circle -1 true false 96 21 42
Circle -1 true false 105 40 32
Circle -1 true false 129 19 42
Rectangle -7500403 true true 14 228 78 270

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

garbage can
false
0
Polygon -16777216 false false 60 240 66 257 90 285 134 299 164 299 209 284 234 259 240 240
Rectangle -7500403 true true 60 75 240 240
Polygon -7500403 true true 60 238 66 256 90 283 135 298 165 298 210 283 235 256 240 238
Polygon -7500403 true true 60 75 66 57 90 30 135 15 165 15 210 30 235 57 240 75
Polygon -7500403 true true 60 75 66 93 90 120 135 135 165 135 210 120 235 93 240 75
Polygon -16777216 false false 59 75 66 57 89 30 134 15 164 15 209 30 234 56 239 75 235 91 209 120 164 135 134 135 89 120 64 90
Line -16777216 false 210 120 210 285
Line -16777216 false 90 120 90 285
Line -16777216 false 125 131 125 296
Line -16777216 false 65 93 65 258
Line -16777216 false 175 131 175 296
Line -16777216 false 235 93 235 258
Polygon -16777216 false false 112 52 112 66 127 51 162 64 170 87 185 85 192 71 180 54 155 39 127 36

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

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person construction
false
0
Rectangle -7500403 true true 123 76 176 95
Polygon -1 true false 105 90 60 195 90 210 115 162 184 163 210 210 240 195 195 90
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Circle -7500403 true true 110 5 80
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -955883 true false 180 90 195 90 195 165 195 195 150 195 150 120 180 90
Polygon -955883 true false 120 90 105 90 105 165 105 195 150 195 150 120 120 90
Rectangle -16777216 true false 135 114 150 120
Rectangle -16777216 true false 135 144 150 150
Rectangle -16777216 true false 135 174 150 180
Polygon -955883 true false 105 42 111 16 128 2 149 0 178 6 190 18 192 28 220 29 216 34 201 39 167 35
Polygon -6459832 true false 54 253 54 238 219 73 227 78
Polygon -16777216 true false 15 285 15 255 30 225 45 225 75 255 75 270 45 285

person doctor
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -13345367 true false 135 90 150 105 135 135 150 150 165 135 150 105 165 90
Polygon -7500403 true true 105 90 60 195 90 210 135 105
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -1 true false 105 90 60 195 90 210 114 156 120 195 90 270 210 270 180 195 186 155 210 210 240 195 195 90 165 90 150 150 135 90
Line -16777216 false 150 148 150 270
Line -16777216 false 196 90 151 149
Line -16777216 false 104 90 149 149
Circle -1 true false 180 0 30
Line -16777216 false 180 15 120 15
Line -16777216 false 150 195 165 195
Line -16777216 false 150 240 165 240
Line -16777216 false 150 150 165 150

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

person lumberjack
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -2674135 true false 60 196 90 211 114 155 120 196 180 196 187 158 210 211 240 196 195 91 165 91 150 106 150 135 135 91 105 91
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -6459832 true false 174 90 181 90 180 195 165 195
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 126 90 119 90 120 195 135 195
Rectangle -6459832 true false 45 180 255 195
Polygon -16777216 true false 255 165 255 195 240 225 255 240 285 240 300 225 285 195 285 165
Line -16777216 false 135 165 165 165
Line -16777216 false 135 135 165 135
Line -16777216 false 90 135 120 135
Line -16777216 false 105 120 120 120
Line -16777216 false 180 120 195 120
Line -16777216 false 180 135 210 135
Line -16777216 false 90 150 105 165
Line -16777216 false 225 165 210 180
Line -16777216 false 75 165 90 180
Line -16777216 false 210 150 195 165
Line -16777216 false 180 105 210 180
Line -16777216 false 120 105 90 180
Line -16777216 false 150 135 150 165
Polygon -2674135 true false 100 30 104 44 189 24 185 10 173 10 166 1 138 -1 111 3 109 28

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

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
