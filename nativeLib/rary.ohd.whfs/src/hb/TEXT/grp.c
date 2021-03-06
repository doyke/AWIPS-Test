/*
** Generated by X-Designer
*/
/*
**LIBS: -lXm -lXt -lX11
*/

#include <stdlib.h>
#include <X11/Xatom.h>
#include <X11/Intrinsic.h>
#include <X11/Shell.h>

#include <Xm/Xm.h>
#include <Xm/DialogS.h>
#include <Xm/Form.h>
#include <Xm/Label.h>
#include <Xm/List.h>
#include <Xm/PushB.h>
#include <Xm/ScrollBar.h>
#include <Xm/Separator.h>


Widget glDS = (Widget) NULL;
Widget glFM = (Widget) NULL;
Widget glLbl = (Widget) NULL;
Widget glSLB = (Widget) NULL;
Widget glHSB = (Widget) NULL;
Widget glVSB = (Widget) NULL;
Widget glLB = (Widget) NULL;
Widget glSP = (Widget) NULL;
Widget glokPB = (Widget) NULL;
Widget glclearPB = (Widget) NULL;
Widget glclosePB = (Widget) NULL;



void create_glDS (Widget parent)
{
	Widget children[6];      /* Children to manage */
	Arg al[64];                    /* Arg List */
	register int ac = 0;           /* Arg Count */
	XmString xmstrings[16];    /* temporary storage for XmStrings */

	XtSetArg(al[ac], XmNallowShellResize, TRUE); ac++;
	XtSetArg(al[ac], XmNminWidth, 300); ac++;
	XtSetArg(al[ac], XmNminHeight, 260); ac++;
	XtSetArg(al[ac], XmNmaxWidth, 300); ac++;
	XtSetArg(al[ac], XmNmaxHeight, 260); ac++;
	XtSetArg(al[ac], XmNbaseWidth, 0); ac++;
	XtSetArg(al[ac], XmNbaseHeight, 0); ac++;
	glDS = XmCreateDialogShell ( parent, "glDS", al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNdialogStyle, XmDIALOG_FULL_APPLICATION_MODAL); ac++;
	XtSetArg(al[ac], XmNautoUnmanage, FALSE); ac++;
	glFM = XmCreateForm ( glDS, "glFM", al, ac );
	ac = 0;
	glLbl = XmCreateLabel ( glFM, "glLbl", al, ac );
	XtSetArg(al[ac], XmNlistSizePolicy, XmRESIZE_IF_POSSIBLE); ac++;
	glLB = XmCreateScrolledList ( glFM, "glLB", al, ac );
	ac = 0;
	glSLB = XtParent ( glLB );

	XtSetArg(al[ac], XmNhorizontalScrollBar, &glHSB); ac++;
	XtSetArg(al[ac], XmNverticalScrollBar, &glVSB); ac++;
	XtGetValues(glSLB, al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNlistSizePolicy, XmRESIZE_IF_POSSIBLE); ac++;
	XtSetValues ( glLB,al, ac );
	ac = 0;
	glSP = XmCreateSeparator ( glFM, "glSP", al, ac );
	glokPB = XmCreatePushButton ( glFM, "glokPB", al, ac );
	XtSetArg(al[ac], XmNwidth, 85); ac++;
	XtSetArg(al[ac], XmNheight, 35); ac++;
	xmstrings[0] = XmStringCreateLtoR ( "Clear", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG );
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	glclearPB = XmCreatePushButton ( glFM, "glclearPB", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	glclosePB = XmCreatePushButton ( glFM, "glclosePB", al, ac );


	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 15); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_NONE); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 10); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_NONE); ac++;
	XtSetValues ( glLbl,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 38); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, 80); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 10); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, 10); ac++;
	XtSetValues ( glSLB,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_NONE); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, 60); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 0); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, 0); ac++;
	XtSetValues ( glSP,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_WIDGET); ac++;
	XtSetArg(al[ac], XmNtopOffset, 10); ac++;
	XtSetArg(al[ac], XmNtopWidget, glSP); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_NONE); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 10); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_NONE); ac++;
	XtSetValues ( glokPB,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_WIDGET); ac++;
	XtSetArg(al[ac], XmNtopOffset, 10); ac++;
	XtSetArg(al[ac], XmNtopWidget, glSP); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_NONE); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_WIDGET); ac++;
	XtSetArg(al[ac], XmNleftOffset, 13); ac++;
	XtSetArg(al[ac], XmNleftWidget, glokPB); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_NONE); ac++;
	XtSetValues ( glclearPB,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_WIDGET); ac++;
	XtSetArg(al[ac], XmNtopOffset, 10); ac++;
	XtSetArg(al[ac], XmNtopWidget, glSP); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_NONE); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_NONE); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, 10); ac++;
	XtSetValues ( glclosePB,al, ac );
	ac = 0;
	XtManageChild(glLB);
	children[ac++] = glLbl;
	children[ac++] = glSP;
	children[ac++] = glokPB;
	children[ac++] = glclearPB;
	children[ac++] = glclosePB;
	XtManageChildren(children, ac);
	ac = 0;
}

