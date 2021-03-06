C MEMBER PRPE26
C  (from old member FCPRPE26)
C
      SUBROUTINE PRPE26(PO,LP,LT)
C
C***********************************************************************
C
C     INDUCED SURCHARGE COMPUTATIONAL SCHEME
C
      DIMENSION PO(*),X(365),Y(365),IDAY(365),ANAME(5),
     1 EMTY(10),LISTOP(10),NEEDVA(8,10),NEEDIT(8),FLOPT(2)
      COMMON/IONUM/IN,IPR,IPU
      COMMON/CNVP26/CONV1,CONV2,CONV3,CONV4,CONV5,UNT1,UNT2,UNT3,UNT4,
     .        UNT5
      LOGICAL NEEDIT,NEEDVA
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_res/RCS/prpe26.f,v $
     . $',                                                             '
     .$Id: prpe26.f,v 1.4 2000/03/13 21:04:52 page Exp $
     . $' /
C    ===================================================================
C
C
      DATA BLANK,AMP,FLOPT/4H    ,4H&   ,4HNO  ,4HYES /
C
      DATA NEEDVA/.TRUE.,6*.FALSE.,2*.TRUE.,7*.FALSE.,
     3    .FALSE.,.TRUE.,.TRUE.,.TRUE.,.TRUE.,.FALSE.,.TRUE.,.TRUE.,
     4    .FALSE.,.TRUE.,.TRUE.,.FALSE.,.TRUE.,.FALSE.,.TRUE.,.FALSE.,
     5    .TRUE.,.FALSE.,.TRUE.,.FALSE.,.TRUE.,.FALSE.,.TRUE.,.TRUE.,
     6    .TRUE.,.FALSE.,.TRUE.,.FALSE.,.TRUE.,.FALSE.,.TRUE.,.FALSE.,
     7    .FALSE.,.FALSE.,.TRUE.,.FALSE.,.TRUE.,.FALSE.,.TRUE.,.FALSE.,
     8    .FALSE.,6*.TRUE.,.FALSE.,
     9    8*.TRUE.,7*.TRUE.,.FALSE./
C
C  POINTER FOR ADDITIONAL VARIABLES FOR 1993 FEBRUARY MANUAL
      LO=LP+4
      NSCQI=PO(LO)
      NSCEL=PO(LO+1)
      LO=LO+1
      LO=LO+NSCQI
      LO=LO+NSCEL
      NSCQO=NSCQI*NSCEL
      LO=LO+NSCQO+2
      NDT=PO(LO)
      LO=LO+1
      DO 10 J=1,10
   10 EMTY(J)=BLANK
      NLINES=PO(LO)
      LO=LO+1
      IF(NDT.GT.3)GO TO 12
      DO 14 J=1,NLINES
      N=PO(LO+1)
      EMTY(N)=AMP
      LO=LO+2
   14 CONTINUE
      GO TO 18
C
   12 DO 16 J=1,NLINES
      N=PO(LO+2)
      EMTY(N)=AMP
      LO=LO+3
   16 CONTINUE
   18 NOPT=0
      KI=0
      DO 20 J=1,10
      IF(EMTY(J).EQ.BLANK)GO TO 20
      KI=KI+1
      LISTOP(KI)=J
      NOPT=KI
   20 CONTINUE
      DO 22 J=1,8
   22 NEEDIT(J)=.FALSE.
      DO 24 KK=1,NOPT
      IOPT=LISTOP(KK)
      DO 26 N=1,8
      NEEDIT(N)=NEEDIT(N).OR.NEEDVA(N,IOPT)
   26 CONTINUE
   24 CONTINUE
      IF(NEEDIT(1)) LO=LO+1
      IF(NEEDIT(2)) LO=LO+1
      IF(NEEDIT(3)) LO=LO+1
      IF(NEEDIT(4)) LO=LO+1
      IF(NEEDIT(5)) LO=LO+1
      IF(NEEDIT(6)) LO=LO+1
      IF(NEEDIT(7)) LO=LO+1
      IF(.NOT.NEEDIT(8)) GO TO 54
      NGEL=PO(LO)
      LO=LO+1
      NGO=PO(LO)
      LO=LO+NGEL
      LO=LO+NGO
      NGA=NGEL*NGO
      LO=LO+NGA+2
  54  LO=LO+1
      NR=PO(LO)
      IF(NR.GT.0) LO=LO+2*NR+1
      LO=LO+1
      L9302=LO
      I9302=PO(L9302)
C
      IF(I9302.NE.199302) GO TO 7010
      IHRSCH=PO(L9302+1)
      IF (IHRSCH.GT.0) WRITE(IPR,7011)IHRSCH
 7011 FORMAT(1H0,20X,50HTIME INTERVAL FOR CHECKING SURCHARGE CURVE
     1 =,I8,6H HOURS)
 7010 CONTINUE
C
      HUP=PO(LP)
      LO=LP+1
      HCH=PO(LO)
      HLO=PO(LO+1)
      LO=LO+2
C
      IF(HUP.GT.0.0)GO TO 102
      FACT=(HCH+999.)*CONV1
      IF(FACT.LT..0001 .AND. FACT.GT.-.0001)GO TO 103
      IF(FACT.LT.0.)WRITE(IPR,5044)FACT,UNT1
      IF(FACT.GE.0.)WRITE(IPR,5046)FACT,UNT1
 5044 FORMAT(1H0,20X,50HFOLLOW SURCHARGE SCHEDULE ABOVE HUPPER  (HUPPER)
     1 =,5H RULE,F5.1,A4)
 5046 FORMAT(1H0,20X,50HFOLLOW SURCHARGE SCHEDULE ABOVE HUPPER  (HUPPER)
     1 =,7H RULE +,F4.1,A4)
      GO TO 104
 103  WRITE(IPR,5044)
      GO TO 104
 102  HUP=HUP*CONV1
      WRITE(IPR,5052)HUP,UNT1
 5052 FORMAT(1H0,20X,50HFOLLOW SURCHARGE SCHEDULE ABOVE HUPPER  (HUPPER)
     1 =,F11.2,1X,A4)
 104  CONTINUE
C
      IF(HLO.GT.0.)GO TO 206
      FACT=(HLO+999.)*CONV1
      IF(FACT.LT..0001 .AND. FACT.GT.-.0001)GO TO 207
      IF(FACT.LT.0.)WRITE(IPR,5060)FACT,UNT1
      IF(FACT.GE.0.)WRITE(IPR,5062)FACT,UNT1
 5060 FORMAT(1H0,20X,50HNORMAL RESERVOIR OPERATION BELOW HLOWER (HLOWER)
     1 =,5H RULE,F5.1,A4)
 5062 FORMAT(1H0,20X,50HNORMAL RESERVOIR OPERATION BELOW HLOWER (HLOWER)
     1 =,7H RULE +,F4.1,A4)
      GO TO 208
 207  WRITE(IPR,5060)
      GO TO 208
 206  HLO=HLO*CONV1
      WRITE(IPR,5064)HLO,UNT1
 5064 FORMAT(1H0,20X,50HNORMAL RESERVOIR OPERATION BELOW HLOWER (HLOWER)
     1 =,F11.2,1X,A4)
 208  CONTINUE
C
      IF(I9302.NE.199302) GO TO 7120
      IX=PO(L9302+12)
      IF(IX.EQ.-999) GO TO 7120
      QGENMX=PO(L9302+12)*CONV2
      WRITE(IPR,7121)QGENMX,UNT2
 7121 FORMAT(1H0,20X,50HMAXIMUM POWER GEN. DISCHCHARGE         (QGENMAX)
     1 =,F11.2,1X,A4)
 7120 CONTINUE
C
      IX=HCH
      IF(IX.EQ.-9998) GO TO 204
      IF(HCH.GT.0.0)GO TO 202
      FACT=(HCH+999.)*CONV1
      IF(FACT.LT..0001 .AND. FACT.GT.-.0001)GO TO 203
      IF(FACT.LT.0.)WRITE(IPR,5054)FACT,UNT1
      IF(FACT.GE.0.)WRITE(IPR,5056)FACT,UNT1
 5054 FORMAT(1H0,20X,50HCHECKING ELEVATION DURING INCREASING INFLOW     
     1 =,5H RULE,F5.1,A4)
 5056 FORMAT(1H0,20X,50HCHECKING ELEVATION DURING INCREASING INFLOW     
     1 =,7H RULE +,F4.1,A4)
      GO TO 204
 203  WRITE(IPR,5054)
      GO TO 204
 202  HCH=HCH*CONV1
      WRITE(IPR,5058)HCH,UNT1
 5058 FORMAT(1H0,20X,50HCHECKING ELEVATION                      (HCHECK)
     1 =,F11.2,1X,A4)
C
 204  CONTINUE
      IF(I9302.NE.199302) GO TO 7030
      IX=PO(L9302+2)
      IF(IX.EQ.-999) GO TO 7020
      QCHECK=PO(L9302+2)*CONV2
      WRITE(IPR,7021)QCHECK,UNT2
 7021 FORMAT(1H0,20X,50HCHECKING DISCHARGE                      (QCHECK)
     1 =,F11.2,1X,A4)
 7020 IX=PO(L9302+3)
      IF(IX.EQ.-999) GO TO 7030
      QDIFF=PO(L9302+3)*CONV2
      WRITE(IPR,7031)QDIFF,UNT2
 7031 FORMAT(1H0,20X,50HDISCHARGE DIFFERENCE BELOW INFLOW        (QDIFF)
     1 =,F11.2,1X,A4)
 7030 CONTINUE
      ICP=PO(LO)
      LO=LO+1
      WRITE(IPR,5065)ICP
 5065 FORMAT(1H0,20X,50HTIME INTERVAL TO COMPUTE MEAN SURCHARGE INFLOW
     1 =,I8,6H HOURS)
C
      NSCQI=PO(LO)
      NSCEL=PO(LO+1)
      LO=LO+1
      DO 8000 J=1,NSCQI
 8000 X(J)=PO(LO+J)*CONV2
      LO=LO+NSCQI
      IF (X(NSCQI).LE.10.0) THEN 
         WRITE(IPR,5066)UNT1
         WRITE(IPR,5068)(X(J),J=1,NSCQI)
      ELSE
         WRITE(IPR,5067)UNT2
         WRITE(IPR,5069)(X(J),J=1,NSCQI)
      ENDIF
 5066 FORMAT(1H0,20X,'RATE OF RISE OF POOL (',A4,'/HR',
     & 20H) IN SURCHARGE CURVE/)
 5067 FORMAT(1H0,20X,8HINFLOWS(,A4,20H) IN SURCHARGE CURVE/)
 5069 FORMAT(1H ,25X,8F10.0)
      DO 8002 J=1,NSCEL
 8002 X(J)=PO(LO+J)*CONV1
      LO=LO+NSCEL
      WRITE(IPR,5070)UNT1
 5070 FORMAT(1H0,20X,11HELEVATIONS(,A4,20H) IN SURCHARGE CURVE/)
      WRITE(IPR,5068)(X(J),J=1,NSCEL)
 5068 FORMAT(1H ,25X,8F10.2)
C
      NSCQO=NSCQI*NSCEL
      DO 8004 J=1,NSCQO
 8004 X(J)=PO(LO+J)*CONV2
      WRITE(IPR,5072)UNT2
 5072 FORMAT(1H0,20X,10HDISCHARGE(,A4,20H) IN SURCHARGE CURVE/)
      JST=1
      JND=NSCEL
      DO 8005 I=1,NSCQI
      WRITE(IPR,5069)(X(J),J=JST,JND)
      JST=JND+1
      JND=JST+NSCEL-1
 8005 CONTINUE
      LO=LO+NSCQO+1
C      GO TO 8008
C 8006 NLOC=LO
C      LO=-1*HUP+PO(10)-1
C      HUP=PO(LO)
C      WRITE(IPR,5074)HUP,UNT1
C 5074 FORMAT(1H0,20X,50HUPPER LIMITING ELEVATION
C     1 =,F11.2,1X,A4)
C      LO=NLOC+1
C
C 8008 CONV=PO(LO)
C
      IF(I9302.NE.199302) GO TO 7110
      IX=PO(L9302+9)
      IF(IX.EQ.-999) GO TO 7090
      SCQIMN=PO(L9302+9)
      WRITE(IPR,7091)SCQIMN,UNT2
 7091 FORMAT(1H0,20X,50HLOWEST INFLOW IN THE SURCHARGE CURVE   (MINSCQI)
     1 =,F11.2,1X,A4)
 7090 IX=PO(L9302+11)
      IF(IX.EQ.-999) GO TO 7110
      SCQOMN=PO(L9302+11)*CONV2
      WRITE(IPR,7111)SCQOMN,UNT2
 7111 FORMAT(1H0,20X,50HLOWEST OUTFLOW IN THE SURCHARGE CURVE  (MINSCQO)
     1 =,F11.2,1X,A4)
 7110 CONTINUE
C
      CONV=PO(LO)
      NDT=PO(LO+1)
      WRITE(IPR,5076)CONV
 5076 FORMAT(1H0,20X,50HITERATION CONVERGENCE CRITERION
     1 =,F11.2)
      WRITE(IPR,5078)NDT
 5078 FORMAT(1H0,20X,20HDECISION TABLE(TYPE=,I2,1H))
      LO=LO+2
      DO 8010 J=1,10
 8010 EMTY(J)=BLANK
      NLINES=PO(LO)
      LO=LO+1
      IF(NDT.GT.3)GO TO 8012
      CNVIS = CONV1
      UNTIS = UNT1
      IF (NDT.EQ.2) CNVIS = CONV2
      IF (NDT.EQ.2) UNTIS = UNT2
      DO 8014 J=1,NLINES
      IPO=PO(LO+1)
      PPO = PO(LO) * CNVIS
      WRITE(IPR,5080) PPO,UNTIS,IPO
 5080 FORMAT(1H0,25X,F11.2,1X,A4,I5)
      N=PO(LO+1)
      EMTY(N)=AMP
      LO=LO+2
 8014 CONTINUE
      GO TO 8018
C
 8012 DO 8016 J=1,NLINES
      IPO=PO(LO+2)
      PPO1 = PO(LO) * CONV1
      PPO2 = PO(LO+1) * CONV2
      WRITE(IPR,5082) PPO1,UNT1,PPO2,UNT2,IPO
 5082 FORMAT(1H0,25X,2(F11.2,1X,A4),I5)
      N=PO(LO+2)
      EMTY(N)=AMP
      LO=LO+3
 8016 CONTINUE
C
C     CHECK 'EMTY' TO SEE WHICH EVACUATION OPTIONS HAVE BEEN
C     SELECTED(POSITION CONTAINS AN AMPERSAND)
 8018 NOPT=0
      KI=0
      DO 8020 J=1,10
      IF(EMTY(J).EQ.BLANK)GO TO 8020
      KI=KI+1
      LISTOP(KI)=J
      NOPT=KI
 8020 CONTINUE
      DO 8022 J=1,8
 8022 NEEDIT(J)=.FALSE.
      DO 8024 KK=1,NOPT
      IOPT=LISTOP(KK)
      DO 8026 N=1,8
      NEEDIT(N)=NEEDIT(N).OR.NEEDVA(N,IOPT)
 8026 CONTINUE
 8024 CONTINUE
C
C
      WRITE(IPR,5083)
 5083 FORMAT(1H0,20X,19HEVACUATION OPTIONS:)
C
      IF(I9302.NE.199302) GO TO 7140
      IX=PO(L9302+10)
      IF(IX.EQ.-9998) GO TO 7100
      HPREVQ=PO(L9302+10)
      IF(HPREVQ.GT.0.)GO TO 7104
      FACT=(HPREVQ+999.)*CONV1
      IF(FACT.LT..0001 .AND. FACT.GT.-.0001)GO TO 7103
      IF(FACT.LT.0.)WRITE(IPR,7101)FACT,UNT1
 7101 FORMAT(1H0,25X,40HELEV. TO USE PREVIOUS OUTFLOW  (HPREVQ)=,
     & 1X,4HRULE,F5.1,A4)
      IF(FACT.GE.0.)WRITE(IPR,7102)FACT,UNT1
 7102 FORMAT(1H0,25X,40HELEV. TO USE PREVIOUS OUTFLOW  (HPREVQ)=,
     & 1X,6HRULE +,F4.1,A4)
      GO TO 7100
 7103 WRITE(IPR,7101)
      GO TO 7100
 7104 HPREVQ=HPREVQ*CONV1
      WRITE(IPR,7105)HPREVQ,UNT1
 7105 FORMAT(1H0,25X,40HELEV. TO USE PREVIOUS OUTFLOW  (HPREVQ)=,
     & F11.2,1X,A4)
 7100 CONTINUE
      IX=PO(L9302+14)
      IF(IX.EQ.-9998) GO TO 7140
      HEVACE=PO(L9302+14)
      IF(HEVACE.GT.0.)GO TO 7144
      FACT=(HEVACE+999.)*CONV1
      IF(FACT.LT..0001 .AND. FACT.GT.-.0001)GO TO 7143
      IF(FACT.LT.0.)WRITE(IPR,7141)FACT,UNT1
 7141 FORMAT(1H0,25X,34HELEV TO END EVACUATION (HEVACEND)=,
     & 1X,4HRULE,F5.1,A4)
      IF(FACT.GE.0.)WRITE(IPR,7142)FACT,UNT1
 7142 FORMAT(1H0,25X,34HELEV TO END EVACUATION (HEVACEND)=,
     & 1X,6HRULE +,F4.1,A4)
      GO TO 7140
 7143 WRITE(IPR,7141)
      GO TO 7140
 7144 HEVACE=HEVACE*CONV1
      WRITE(IPR,7145)HEVACE,UNT1
 7145 FORMAT(1H0,25X,40HELEV. TO END EVACUATION      (HEVACEND)=,
     & F11.2,1X,A4)
 7140 CONTINUE
C 
      IF(.NOT.NEEDIT(1)) GO TO 8034
      HTARG=PO(LO)
      IF(HTARG.GT.0.)GO TO 8030
      FACT=(HTARG+999.)*CONV1
      IF(FACT.LT..0001 .AND. FACT.GT.-.0001)GO TO 8025
      IF(FACT.LT.0.)WRITE(IPR,5084)FACT,UNT1
 5084 FORMAT(1H0,25X,34HTARGET ELEVATION 1     (HTARGET1)=,
     & 1X,4HRULE,F5.1,A4)
      IF(FACT.GE.0.)WRITE(IPR,5086)FACT,UNT1
 5086 FORMAT(1H0,25X,34HTARGET ELEVATION 1     (HTARGET1)=,
     & 1X,6HRULE +,F4.1,A4)
      GO TO 8032
 8025 WRITE(IPR,5084)
      GO TO 8032
 8030 HTARG=HTARG*CONV1
      WRITE(IPR,5088)HTARG,UNT1
 5088 FORMAT(1H0,25X,40HTARGET ELEVATION 1           (HTARGET1)=,
     & F11.2,1X,A4)
 8032 LO=LO+1
C
 8034 CONTINUE
      IF(I9302.NE.199302) GO TO 7050
      IX=PO(L9302+4)
      IF(IX.EQ.-9998) GO TO 7040
      HTARG2=PO(L9302+4)
      IF(HTARG2.GT.0.)GO TO 7044
      FACT=(HTARG2+999.)*CONV1
      IF(FACT.LT..0001 .AND. FACT.GT.-.0001)GO TO 7043
      IF(FACT.LT.0.)WRITE(IPR,7041)FACT,UNT1
 7041 FORMAT(1H0,25X,34HTARGET ELEVATION 2     (HTARGET2)=,
     & 1X,4HRULE,F5.1,A4)
      IF(FACT.GE.0.)WRITE(IPR,7042)FACT,UNT1
 7042 FORMAT(1H0,25X,34HTARGET ELEVATION 2     (HTARGET2)=,
     & 1X,6HRULE +,F4.1,A4)
      GO TO 7040
 7043 WRITE(IPR,7041)
      GO TO 7040
 7044 HTARG2=HTARG2*CONV1
      WRITE(IPR,7045)HTARG2,UNT1
 7045 FORMAT(1H0,25X,40HTARGET ELEVATION 2           (HTARGET2)=,
     & F11.2,1X,A4)
 7040 CONTINUE
      IX=PO(L9302+5)
      IF(IX.EQ.-9998) GO TO 7050
      HTARG3=PO(L9302+5)
      IF(HTARG3.GT.0.)GO TO 7054
      FACT=(HTARG3+999.)*CONV1
      IF(FACT.LT..0001 .AND. FACT.GT.-.0001)GO TO 7053
      IF(FACT.LT.0.)WRITE(IPR,7051)FACT,UNT1
 7051 FORMAT(1H0,25X,34HTARGET ELEVATION 3     (HTARGET3)=,
     & 1X,4HRULE,F5.1,A4)
      IF(FACT.GE.0.)WRITE(IPR,7052)FACT,UNT1
 7052 FORMAT(1H0,25X,34HTARGET ELEVATION 3     (HTARGET3)=,
     & 1X,6HRULE +,F4.1,A4)
      GO TO 7050
 7053 WRITE(IPR,7051)
      GO TO 7050
 7054 HTARG3=HTARG3*CONV1
      WRITE(IPR,7055)HTARG3,UNT1
 7055 FORMAT(1H0,25X,40HTARGET ELEVATION 3           (HTARGET3)=,
     & F11.2,1X,A4)
 7050 CONTINUE
      IF(.NOT.NEEDIT(2)) GO TO 8036
      DIFQI1=PO(LO)*CONV2
      LO=LO+1
C
 8036 IF(.NOT.NEEDIT(3)) GO TO 8038
      RED=PO(LO)*CONV2
      WRITE(IPR,5092)RED,UNT2
 5092 FORMAT(1H0,25X,40HDISCHARGE REDUCTION RATE      (REDUCE1)=,
     & F11.2,1X,A4)
      LO=LO+1
C
 8038 CONTINUE
      IF(I9302.NE.199302) GO TO 7070
      IX=PO(L9302+6)
      IF(IX.EQ.-999) GO TO 7060
      REDUC1=PO(L9302+6)*CONV2
      WRITE(IPR,7061)REDUC1,UNT2
 7061 FORMAT(1H0,25X,40HDISCHARGE REDUCTION RATE 1    (REDUCE1)=,
     & F11.2,1X,A4)
 7060 CONTINUE
      IX=PO(L9302+7)
      IF(IX.EQ.-999) GO TO 7070
      REDUC2=PO(L9302+7)*CONV2
      WRITE(IPR,7071)REDUC2,UNT2
 7071 FORMAT(1H0,25X,40HDISCHARGE REDUCTION RATE 2    (REDUCE1)=,
     & F11.2,1X,A4)
 7070 CONTINUE
      IF(.NOT.NEEDIT(4)) GO TO 8040
      QT1=PO(LO)*CONV2
      WRITE(IPR,5094)QT1,UNT2
 5094 FORMAT(1H0,25X,40HTARGET DISCHARGE 1           (QTARGET1)=,
     & F11.2,1X,A4)
      LO=LO+1
C
 8040 IF(.NOT.NEEDIT(5)) GO TO 8042
      QT2=PO(LO)*CONV2
      WRITE(IPR,5096)QT2,UNT2
 5096 FORMAT(1H0,25X,40HTARGET DISCHARGE 2           (QTARGET2)=,
     & F11.2,1X,A4)
      LO=LO+1
C
 8042 CONTINUE
      IF(I9302.NE.199302) GO TO 7080
      IX=PO(L9302+8)
      IF(IX.EQ.-999) GO TO 7080
      QTARG3=PO(L9302+8)*CONV2
      WRITE(IPR,7081)QTARG3,UNT2
 7081 FORMAT(1H0,25X,40HTARGET DISCHARGE 3           (QTARGET3)=,
     & F11.2,1X,A4)
 7080 CONTINUE
      IF(NEEDIT(2)) WRITE(IPR,5090)DIFQI1,UNT2
 5090 FORMAT(1H0,25X,40HINFLOW DIFFERENCE 1           (DIFFQI1)=,
     & F11.2,1X,A4)
      IF(.NOT.NEEDIT(6)) GO TO 8044
      DIFF=PO(LO)*CONV2
      WRITE(IPR,5098)DIFF,UNT2
 5098 FORMAT(1H0,25X,40HINFLOW DIFFERENCE 2           (DIFFQI2)=,
     & F11.2,1X,A4)
      LO=LO+1
C
 8044 IF(.NOT.NEEDIT(7)) GO TO 8046
      DIFF=PO(LO)*CONV2
      WRITE(IPR,6000)DIFF,UNT2
 6000 FORMAT(1H0,25X,40HINFLOW DIFFERENCE 3           (DIFFQI3)=,
     & F11.2,1X,A4)
      LO=LO+1
C
      IF(I9302.NE.199302) GO TO 7130
      IX=PO(L9302+13)
      IF(IX.EQ.-999) GO TO 7130
      PEAKQ1=PO(L9302+13)*CONV2
      WRITE(IPR,7131) PEAKQ1,UNT2
 7131 FORMAT(1H0,25X,40HPEAK RESERVOIR DISCHARGE 1    (PEAKQO1)=,
     & F11.2,1X,A4)
 7130 CONTINUE
C
 8046 IF(.NOT.NEEDIT(8)) GO TO 8054
      NGEL=PO(LO)
      LO=LO+1
      LOEL=LO
      NGO=PO(LO)
      WRITE(IPR,6001)
 6001 FORMAT(1H0,25X,17HGATE RATING CURVE)
      LO=LO+NGEL
      DO 8050 J=1,NGO
 8050 X(J)=PO(LO+J)*CONV1
      WRITE(IPR,6006)UNT1
 6006 FORMAT(1H0,26X,14HGATE OPENINGS(,A4,2H):/)
      WRITE(IPR,6004)(X(J),J=1,NGO)
      WRITE(IPR,6002)UNT1
 6002 FORMAT(1H0,26X,16HPOOL ELEVATIONS(,A4,2H):/)
      DO 8048 J=1,NGEL
 8048 X(J)=PO(LOEL+J)*CONV1
      WRITE(IPR,6004)(X(J),J=1,NGEL)
 6004 FORMAT(1H ,25X,8F10.2)
      LO=LO+NGO
      NGA=NGEL*NGO
      DO 8052 J=1,NGA
 8052 X(J)=PO(LO+J)*CONV2
      WRITE(IPR,6008)UNT2
 6008 FORMAT(1H0,26X,11HDISCHARGES(,A4,2H):/)
      JST=1
      JND=NGEL
      DO 8053 I=1,NGO
      WRITE(IPR,6005)(X(J),J=JST,JND)
      JST=JND+1
      JND=JST+NGEL-1
 8053 CONTINUE
 6005 FORMAT(1H ,25X,8F10.0)
      LO=LO+NGA+1
C
      IGS=PO(LO)
      WRITE(IPR,6010)IGS
 6010 FORMAT(1H0,20X,50HTIME INTERVAL FOR RESETTING GATES
     1 =,I8,6H HOURS)
      LO=LO+1
 8054 IOP=PO(LO)
      M=2
      IF(IOP.EQ.1)M=1
      WRITE(IPR,6012)FLOPT(M)
 6012 FORMAT(1H0,20X,'REDUCE GATE OPENING TO FOLLOW INDUCED SURCHARGE',
     1' CURVE FOR RISING POOL = ',A4)
      LO=LO+1
      NR=PO(LO)
      MOVE=0
      IF(NR.EQ.0)GO TO 8065
      IF(NR.GT.0)GO TO 8056
      NLOC=LO
      MOVE=1
      LO=-1*NR+PO(10)-1
      NR=PO(LO)
 8056 DO 8058 J=1,NR
 8058 IDAY(J)=PO(LO+J)
      LO=LO+NR
      DO 8060 J=1,NR
 8060 X(J)=PO(LO+J)*CONV1
      WRITE(IPR,820)
      JB=1
      JE=NR
      IF(JE.GT.8)JE=8
 8062 WRITE(IPR,825)(IDAY(J),J=JB,JE)
      WRITE(IPR,830)UNT1,(X(J),J=JB,JE)
      IF(JE.GE.NR)GO TO 8064
      JB=JE+1
      JE=JE+8
      IF(JE.GT.NR)JE=NR
      GO TO 8062
 8064 LO=LO+NR+1
      ITIME=PO(LO)
      IF(ITIME.GE.0) WRITE(IPR,6014) ITIME
 6014 FORMAT(1H0,20X,50HTIME OF RULE CURVE SETTING
     1 =,I8,6H HOURS)
C
 8065 CONTINUE
C
 500  CONTINUE
 740  FORMAT(1H0,10X,37HLINEAR INTERPOLATION IS USED IN CURVE)
 742  FORMAT(1H0,10X,42HLOGARITHMIC INTERPOLATION IS USED IN CURVE)
 795  FORMAT(1H0,20X,64HADDITIONAL TIME SERIES:         ID         TYPE
     1        TIME(HR)/)
  798 FORMAT(1H ,52X,2A4,3X,A4,11X,I2)
 820  FORMAT(1H0,20X,16HRULECURVE VALUES)
 825  FORMAT(1H0,25X,10HJULIAN DAY,8I11)
 830  FORMAT(1H ,25X,5HELEV(,A4,1H),8F11.2)
 832  FORMAT(1H0,20X,50HTIME OF DAY RULE CURVE IS SET
     1 -,I8)
 862  FORMAT(1H0,20X,21HSPILLWAY RATING CURVE)
 864  FORMAT(1H0,25X,5HELEV(,A4,1H),1X,8F11.2)
 866  FORMAT(1H ,25X,6HDISCH(,A4,1H),8F11.2)
 874  FORMAT(1H0,20X,23HHEAD VS DISCHARGE CURVE)
 876  FORMAT(1H0,25X,5HHEAD(,A4,1H),1X,8F11.2)
 877  FORMAT(1H ,25X,6HDISCH(,A4,1H),8F11.2)
 872  FORMAT(1H0,20X,30HTAILWATER RATING CURVE NAME - ,2A4)
      RETURN
      END

