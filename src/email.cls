 
/*------------------------------------------------------------------------
   File        : email
   Purpose     : Validate Email
   Syntax      : 
   Description : Validate Email and build array of error messages 
   Author(s)   : Verghese
   Created     : 
   Notes       : v_errorMessage - Is a Dynamic Array and extened as needed
                 Does not support comments validation
                 Quoted validation of local-part not implemented
                 Quoted validation of domain part not implemented
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS src.email: 

    DEFINE PRIVATE PROPERTY v_lettersLower AS CHARACTER INITIAL "a@b@c@d@e@f@g@h@i@j@k@l@m@n@o@p@q@r@s@t@u@v@w@x@y@z" GET.
    DEFINE PRIVATE PROPERTY v_numbers AS CHARACTER INITIAL "0@1@2@3@4@5@6@7@8@9" GET.
    DEFINE PRIVATE PROPERTY v_specialChars AS CHARACTER INITIAL "!@#@$@%@&@'@*@+@-@/@=@?@^@_@`@~{!|@~}@~~" GET.
    DEFINE PRIVATE PROPERTY v_period AS CHARACTER INITIAL '.' GET.
    DEFINE PRIVATE PROPERTY v_hyphens AS CHARACTER INITIAL '-' GET.
    DEFINE PUBLIC PROPERTY v_errorMessage AS CHARACTER EXTENT GET. 
        SET.
    DEFINE PRIVATE PROPERTY v_personalChars AS CHARACTER GET. 
        PRIVATE SET.
    DEFINE PRIVATE PROPERTY v_domainChars AS CHARACTER GET. 
        PRIVATE SET. 

    /*------------------------------------------------------------------------------------
     Purpose: Set the values for strings
     Notes: Set the values for strings using delimiter @
            v_removeSpecialCharcters - If set to true then special characters are ignored
            v_addUserCharsToPersonalInfo - Add your own special characters to personal info
                                           must be delimitted by @
    --------------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC email (INPUT v_removeSpecialCharcters AS LOGICAL, INPUT v_addUserCharsToPersonalInfo AS CHARACTER): 
            
        IF v_removeSpecialCharcters THEN 
            THIS-OBJECT:v_personalChars = SUBSTITUTE("&1@&2@&3",v_lettersLower,CAPS(v_lettersLower),v_numbers).
        ELSE THIS-OBJECT:v_personalChars = SUBSTITUTE("&1@&2@&3@&4@&5",v_lettersLower,CAPS(v_lettersLower),v_numbers,v_specialChars,v_period). 
        
        IF v_addUserCharsToPersonalInfo <> "" AND v_addUserCharsToPersonalInfo <> ? THEN 
            THIS-OBJECT:v_personalChars = SUBSTITUTE("&1@&2",THIS-OBJECT:v_personalChars,v_addUserCharsToPersonalInfo). 
        
        THIS-OBJECT:v_domainChars = SUBSTITUTE("&1@&2@&3@&4@&5",v_lettersLower,CAPS(v_lettersLower),v_numbers,v_hyphens,v_period). 
        
    END CONSTRUCTOR. /* email */


    /*------------------------------------------------------------------------------
     Purpose: Add Message to Array 
     Notes: Extent Array and Add Message
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID addMessage(v_message AS CHARACTER):
        
        DEFINE VARIABLE v_holdingArray AS CHARACTER EXTENT NO-UNDO.
        DEFINE VARIABLE v_count        AS INTEGER   NO-UNDO.
        
        IF EXTENT(THIS-OBJECT:v_errorMessage) = ? THEN 
        DO:
            ASSIGN
                EXTENT(THIS-OBJECT:v_errorMessage) = 1
                THIS-OBJECT:v_errorMessage[1]      = v_message.
            RETURN.
        END.
       
        ASSIGN              
            EXTENT(v_holdingArray)             = ?
            EXTENT(v_holdingArray)             = EXTENT(THIS-OBJECT:v_errorMessage)  
            v_holdingArray                     = THIS-OBJECT:v_errorMessage
            v_errorMessage                     = ""
            EXTENT(THIS-OBJECT:v_errorMessage) = ?
            EXTENT(THIS-OBJECT:v_errorMessage) = EXTENT(v_holdingArray) + 1.
        
        DO v_count = 1 TO EXTENT(v_holdingArray):
            THIS-OBJECT:v_errorMessage[v_count] = v_holdingArray[v_count]. 
        END.    
                      
        ASSIGN
            THIS-OBJECT:v_errorMessage[EXTENT(THIS-OBJECT:v_errorMessage)] = v_message
            v_holdingArray                                                 = ""
            EXTENT(v_holdingArray)                                         = ?.
        
        RETURN.

    END METHOD. /* addMessage */


    /*------------------------------------------------------------------------------
     Purpose: Validate Email
     Notes: Validate Email. Set error message and set invalid chracters variable
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL ValidateEmail(INPUT v_email AS CHARACTER):
        
        DEFINE VARIABLE v_personalInfo AS CHARACTER NO-UNDO.
        DEFINE VARIABLE v_domainInfo   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE v_count        AS INTEGER   NO-UNDO.
        
        EXTENT(v_errorMessage) = ?.
              
        IF SUBSTRING(v_email,1,1) = v_period THEN 
        DO:
            THIS-OBJECT:addMessage("Period not allowed as first character").
        END.
        
        IF SUBSTRING(v_email,LENGTH(v_email),1) = v_period THEN 
        DO:
            THIS-OBJECT:addMessage("Period not allowed as last character").
        END.  
        
        IF NUM-ENTRIES(v_email,'@') <> 2 THEN 
        DO:
            THIS-OBJECT:addMessage("Invalid Domain").
            RETURN FALSE.
        END. 
        
        IF INDEX(v_email,'..') <> 0 THEN 
        DO:
            THIS-OBJECT:addMessage("Invalid Email with ..").
            RETURN FALSE.
        END.           
        
        ASSIGN
            v_personalInfo = ENTRY(1,v_email,'@')
            v_domainInfo   = ENTRY(2,v_email,'@').    
            
        DO v_count =  1 TO LENGTH(v_personalInfo):
            IF LOOKUP(SUBSTRING(v_personalInfo,v_count,1),THIS-OBJECT:v_personalChars,'@') = 0 THEN 
                THIS-OBJECT:addMessage(SUBSTITUTE("Invalid character '&1' in personal info",SUBSTRING(v_personalInfo,v_count,1))).
        END. 
        
        DO v_count =  1 TO LENGTH(v_domainInfo):          
            IF LOOKUP(SUBSTRING(v_domainInfo,v_count,1),THIS-OBJECT:v_domainChars,'@') = 0 THEN 
                THIS-OBJECT:addMessage(SUBSTITUTE("Invalid character '&1' in domain",SUBSTRING(v_domainInfo,v_count,1))).
        END.      
        
        IF LENGTH(ENTRY(NUM-ENTRIES(v_domainInfo,'.'),v_domainInfo,'.')) LT 2 THEN 
        DO:
            THIS-OBJECT:addMessage("The last portion must have at least two characters").
        END.        
        
        RETURN EXTENT(THIS-OBJECT:v_errorMessage) = ?.

    END METHOD. /* ValidateEmail */
    
END CLASS.