C MODULE PPT12
C-----------------------------------------------------------------------
C     THIS ROUTINE DETERMINES THE PLOT LOCATION AND FORMAT TO PLOT
C     INSTANTANEOUS DISCHARGE AND TABULATE PCPN AND/OR RUNOFF
C     TIME SERIES
C     THIS ROUTINE PERFORMS THE PLOT OPERATION ALSO
C-----------------------------------------------------------------------
      SUBROUTINE PPT12(P,D,PCPN,RO,ORDI,PSBL,LSYM,ORD,LPLOTQ,IDTQ,DIV,
     1  KDA,KHR,KDART,KHRRT,IDTPN,IDTRO,NPLOTS,IOPTAB,IPTIM,
     2  IDTPLT,LOCFS,LOCLL,LOCUL,IRC,JBUG)
C
      LOGICAL FILORD
      DIMENSION D(*),IDTQ(*),LSYM(*),ORD(101),ORDI(*),PSBL(*),PCPN(*)
      DIMENSION P(*),RO(*),LPLOTQ(*)
      CHARACTER*4   FMT(14),FVAL(6)
C
      INCLUDE 'common/ionum'
      INCLUDE 'common/fengmt'
      INCLUDE 'common/fctime'
      INCLUDE 'common/fprog'
      INCLUDE 'common/fdbug'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_insqplot/RCS/ppt12.f,v $
     . $',                                                             '
     .$Id: ppt12.f,v 1.3 2000/12/19 15:06:31 dws Exp $
     . $' /
C    ===================================================================
C
C
      DATA FMT/4H(1H ,4H,I2,,4H1H-,,4HI2,1,4HX,A3,4H,1X,,4HA3, ,
     1   4H    ,4HFH.3,4H   ,,4HFH.3,4H,1X,,4H101A,4H1)  /
      DATA FVAL/4H 8X ,4HF8.0,4HF8.1,4HF8.2,4HF8.3,4HG8.1/
      DATA BLANK/1H /,DOT/1H./,BLANK3/3H   /,RMSG3/-0./
      DATA DASH/1H-/,EXCLAM/1H!/,XXXX/4HXXXX/
C
      FILORD=.FALSE.
      IF(JBUG.EQ.1)WRITE(IODBUG,627)
  627 FORMAT(5X,'*** PPT12 ENTERED ***')
C
      IF(MAINUM.NE.1)GO TO 850
      DOT=EXCLAM
      JLKDA=KDA*24 + KHR
      JLCPD=LDACPD*24 + LHRCPD
      IF(JLKDA.EQ.JLCPD.OR.(JLKDA.LT.JLCPD.AND.JLKDA+IDTPLT.GT.
     1                     JLCPD))GO TO 851
      GO TO 850
  851 DO 852 IXXX=1,101
  852 ORD(IXXX)=DASH
      DO 853 IXXX=1,101,10
  853 ORD(IXXX)=EXCLAM
      FILORD=.TRUE.
C
  850 IF(IRC.EQ.0)GO TO 855
      IF(LOCLL.GT.0)ORD(LOCLL)=P(IRC+3)
      IF(LOCUL.GT.0)ORD(LOCUL)=P(IRC+4)
      IF(LOCFS.GT.0)ORD(LOCFS)=P(IRC+2)
C
  855 CONVMM=1.
      CONVQ=1.
      IF(METRIC.EQ.0)CONVMM=0.03937
      IF(METRIC.EQ.0)CONVQ=35.3147
      DO 310 I=1,NPLOTS
      IF(((IPTIM/IDTQ(I))*IDTQ(I)).EQ.IPTIM) GO TO 301
      GO TO 309
  301 J=(KDA-IDADAT)*24/IDTQ(I)+KHR/IDTQ(I)
      LOC=LPLOTQ(I)+J-1
      FLOW=D(LOC)*CONVQ
      IF(FLOW.LT.0.)GO TO 309
      T=FLOW/DIV+1.0
      LS=T+0.5
      IF(LS.GT.101)LS=101
      IF(LS.LT.1)LS=1
      LSYM(I)=LS
      ORDI(I)=ORD(LS)
      ORD(LS)=PSBL(I)
      GO TO 310
  309 LSYM(I)=0
      ORDI(I)=XXXX
  310 CONTINUE
      IF(IOPTAB.GT.0) GO TO 350
      PCN=BLANK3
      RUNOF=BLANK3
      IF(NPLOTS.GT.1)GO TO 371
      I=(KDA-IDADAT)*24/IDTQ(1)+KHR/IDTQ(1)
      LOC=LPLOTQ(1)+I-1
      FLOW=D(LOC)*CONVQ
      IF(FLOW.LT.0.)FLOW=-0.00001
      IF(FLOW.LT.10.)FMT(9)=FVAL(4)
      IF((FLOW.LT.100.).AND.(FLOW.GE.10.))FMT(9)=FVAL(3)
      IF(FLOW.GE.100.) FMT(9)=FVAL(2)
      IF(FLOW.GT.10000000.)FMT(9)=FVAL(6)
      FMT(11)=FVAL(1)
      WRITE(IPR,FMT)KDART,KHRRT,PCN,RUNOF,FLOW,ORD
      GO TO 399
  350 GO TO (351,352,353),IOPTAB
  351 RUNOF=BLANK3
  353 IF(((IPTIM/IDTPN)*IDTPN).EQ.IPTIM)GO TO 354
      PCN=BLANK3
      GO TO 360
  354 I=(KDA-IDADAT)*24/IDTPN+KHR/IDTPN
      VAL=PCPN(I)*CONVMM
      IF(VAL.LT.0.)GO TO 355
      NDEC=2
      IF (VAL.GE.1.AND.VAL.LT.9.95) NDEC=1
      IF (VAL.GE.9.95) NDEC=0
      CALL UFF2A(VAL,PCN,1,3,NDEC,0,6,IER)
      GO TO 360
  355 PCN=RMSG3
  360 IF(IOPTAB.EQ.1)GO TO 371
      GO TO 358
  352 PCN=BLANK3
  358 IF(((IPTIM/IDTRO)*IDTRO).EQ.IPTIM)GO TO 356
      RUNOF=BLANK3
      GO TO 371
  356 I=(KDA-IDADAT)*24/IDTRO+KHR/IDTRO
      VAL=RO(I)*CONVMM
      IF(VAL.LT.0.0)GO TO 357
      NDEC=2
      IF (VAL.GE.1.AND.VAL.LT.9.95) NDEC=1
      IF (VAL.GE.9.95) NDEC=0
      CALL UFF2A(VAL,RUNOF,1,3,NDEC,0,6,IER)
      GO TO 371
  357 RUNOF=RMSG3
  371 CONTINUE
      IF(((IPTIM/IDTQ(1))*IDTQ(1)).EQ.IPTIM)GO TO 321
      FMT(9)=FVAL(1)
      IFG=0
      GO TO 322
  321 I=(KDA-IDADAT)*24/IDTQ(1)+KHR/IDTQ(1)
      LOC=LPLOTQ(1)+I-1
      IFG=1
      FLOW1=D(LOC)*CONVQ
      IF(FLOW1.LT.0.)FLOW1=-0.00001
      IF(FLOW1.LT.10.)FMT(9)=FVAL(4)
      IF((FLOW1.LT.100.).AND.(FLOW1.GE.10.0))FMT(9)=FVAL(3)
      IF(FLOW1.GE.100.)FMT(9)=FVAL(2)
      IF(FLOW1.GT.10000000.)FMT(9)=FVAL(6)
  322 IF(((IPTIM/IDTQ(2))*IDTQ(2)).EQ.IPTIM)GO TO 324
      FMT(11)=FVAL(1)
      IF(IFG.EQ.1)WRITE(IPR,FMT)KDART,KHRRT,PCN,RUNOF,FLOW1,ORD
      IF(IFG.EQ.0)WRITE(IPR,FMT)KDART,KHRRT,PCN,RUNOF,ORD
      GO TO 399
  324 I=(KDA-IDADAT)*24/IDTQ(2)+KHR/IDTQ(2)
      LOC=LPLOTQ(2)+I-1
      FLOW2=D(LOC)*CONVQ
      IF(FLOW2.LT.0.)FLOW2=-0.00001
      IF(FLOW2.LT.10.)FMT(11)=FVAL(4)
      IF((FLOW2.LT.100.).AND.(FLOW2.GE.10.))FMT(11)=FVAL(3)
      IF(FLOW2.GE.100.)FMT(11)=FVAL(2)
      IF(FLOW2.GE.10000000.)FMT(11)=FVAL(6)
      IF(IFG.EQ.1)GO TO 326
      WRITE(IPR,FMT)KDART,KHRRT,PCN,RUNOF,FLOW2,ORD
      GO TO 399
  326 WRITE(IPR,FMT)KDART,KHRRT,PCN,RUNOF,FLOW1,FLOW2,ORD
C
      I101=101
      IONE=1
      ITEN=10
      IF(JBUG.EQ.1)WRITE(IODBUG,632)FILORD,IONE,ITEN,I101
  632 FORMAT(5X,'** JUST WROTE STATEMENT LABEL 326 **',
     1  /5X,'FILORD=',L4,', IONE=',I5,', ITEN=',I5,', I101=',I5)
C
  399 IF(.NOT.FILORD)GO TO 860
      IF(JBUG.EQ.1)WRITE(IODBUG,633)BLANK
  633 FORMAT(5X,'** ABOUT TO ENTER DO LOOP 861 - BLANK = ',A4,'.')
      DO 861 IXXX=1,101
  861 ORD(IXXX)=BLANK
      IF(JBUG.EQ.1)WRITE(IODBUG,634)EXCLAM
  634 FORMAT(5X,'** ABOUT TO ENTER DO LOOP 862 - EXCLAM = ',A4,'.')
      DO 862 IXXX=1,101,10
  862 ORD(IXXX)=EXCLAM
      GO TO 863
C
  860 IF(JBUG.EQ.0)GO TO 865
      WRITE(IODBUG,635)NPLOTS,IPTIM,BLANK,DOT
  635 FORMAT(5X,'*** AT LABEL 860 - NPLOTS = ',I5,', IPTIM = ',I11,
     1  ', BLANK = ',A4,', DOT = ',A4,'.')
      WRITE(IODBUG,636)(IDTQ(I),LSYM(I),ORDI(I),I=1,NPLOTS)
  636 FORMAT(5X,'** IDTQ(I),LSYM(I),ORDI(I),I=1,NPLOTS **'
     1  / (5X,I7,I9,6X,A4,'.'))
C
  865 DO 501 I=1,NPLOTS
      IF(((IPTIM/IDTQ(I))*IDTQ(I)).EQ.IPTIM)GO TO 502
      GO TO 501
  502 IF(ORDI(I).EQ.BLANK)GO TO 503
      IF(ORDI(I).EQ.DOT)GO TO 503
      GO TO 501
  503 LS=LSYM(I)
      ORD(LS)=ORDI(I)
  501 CONTINUE
  863 IF(JBUG.EQ.1)WRITE(IODBUG,628)
  628 FORMAT(5X,'*** LEAVING PPT12 ***')
C
      RETURN
C
      END
