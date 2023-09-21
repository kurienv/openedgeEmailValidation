
/*------------------------------------------------------------------------
    File        : testEmail.p
    Purpose     : Test Email Validation Class

    Syntax      :

    Description : 

    Author(s)   : Verghese
    Created     : 
    Notes       : Examples to call email validation class
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE vEmail AS CLASS   src.email NO-UNDO.
DEFINE VARIABLE vCount AS INTEGER NO-UNDO.

/* ***************************  Main Block  *************************** */

vEmail = NEW src.email(FALSE,"").

ETIME(YES).
vEmail:ValidateEmail("som%e#e-mail@google.com").
MESSAGE "Time to Run 1" ETIME VIEW-AS ALERT-BOX.

DO vCount = 1 TO EXTENT(vEmail:v_errorMessage):
    MESSAGE "Error 1" vEmail:v_errorMessage[vCount] VIEW-AS ALERT-BOX.
END.
DELETE OBJECT vEmail.

vEmail = NEW src.email(TRUE,"").
ETIME(YES).
vEmail:ValidateEmail("som.e-ema_il@google.com").
MESSAGE "Time to Run 2" ETIME VIEW-AS ALERT-BOX.

DO vCount = 1 TO EXTENT(vEmail:v_errorMessage):
    MESSAGE "Error 2" vEmail:v_errorMessage[vCount] VIEW-AS ALERT-BOX.
END.

ETIME(YES).
vEmail:ValidateEmail("someemail@google.com").
MESSAGE "Time to Run 3" ETIME VIEW-AS ALERT-BOX.

DO vCount = 1 TO EXTENT(vEmail:v_errorMessage):
    MESSAGE "Error 3" vEmail:v_errorMessage[vCount] VIEW-AS ALERT-BOX.
END.

DELETE OBJECT vEmail.

vEmail = NEW src.email(TRUE,".@-@_").
ETIME(YES).
vEmail:ValidateEmail("som.e-ema_il@google.com").
MESSAGE "Time to Run 4" ETIME VIEW-AS ALERT-BOX.

DO vCount = 1 TO EXTENT(vEmail:v_errorMessage):
    MESSAGE "Error 4" vEmail:v_errorMessage[vCount] VIEW-AS ALERT-BOX.
END.

DELETE OBJECT vEmail.

