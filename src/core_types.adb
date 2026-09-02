package body Core_Types is
   function Status_To_String (S : Status_Code) return String is
   begin
      case S is
         when Success => return "SUCCESS";
         when Invalid_Input => return "INVALID_INPUT";
         when Out_Of_Range => return "OUT_OF_RANGE";
         when Buffer_Overflow => return "BUFFER_OVERFLOW";
         when State_Error => return "STATE_ERROR";
         when Integrity_Failure => return "INTEGRITY_FAILURE";
         when Parse_Error => return "PARSE_ERROR";
         when Authorization_Denied => return "AUTHORIZATION_DENIED";
         when Configuration_Error => return "CONFIGURATION_ERROR";
         when Arithmetic_Overflow => return "ARITHMETIC_OVERFLOW";
         when Serialization_Error => return "SERIALIZATION_ERROR";
         when Test_Failure => return "TEST_FAILURE";
      end case;
   end Status_To_String;
   function State_To_String (S : App_State) return String is
   begin
      case S is
         when Idle => return "IDLE";
         when Initializing => return "INITIALIZING";
         when Configured => return "CONFIGURED";
         when Awaiting_Input => return "AWAITING_INPUT";
         when Parsing => return "PARSING";
         when Validating => return "VALIDATING";
         when Processing => return "PROCESSING";
         when Serializing => return "SERIALIZING";
         when Checking_Integrity => return "CHECKING_INTEGRITY";
         when Authorized => return "AUTHORIZED";
         when Error_State => return "ERROR_STATE";
         when Shutdown => return "SHUTDOWN";
      end case;
   end State_To_String;
   function Command_To_String (C : Command_Id) return String is
   begin
      case C is
         when Cmd_None => return "NONE";
         when Cmd_Help => return "HELP";
         when Cmd_Set_Config => return "SET_CONFIG";
         when Cmd_Process_Data => return "PROCESS_DATA";
         when Cmd_Query_State => return "QUERY_STATE";
         when Cmd_Serialize => return "SERIALIZE";
         when Cmd_Verify => return "VERIFY";
         when Cmd_Self_Test => return "SELF_TEST";
         when Cmd_Reset => return "RESET";
         when Cmd_Authorize => return "AUTHORIZE";
         when Cmd_Exit => return "EXIT";
      end case;
   end Command_To_String;
   function Auth_To_String (A : Auth_Level) return String is
   begin
      case A is
         when None => return "NONE";
         when Guest => return "GUEST";
         when Operator => return "OPERATOR";
         when Admin => return "ADMIN";
      end case;
   end Auth_To_String;
   function Config_Key_To_String (K : Config_Key) return String is
   begin
      case K is
         when Key_Max_Length => return "MAX_LENGTH";
         when Key_Timeout => return "TIMEOUT";
         when Key_Auth_Level => return "AUTH_LEVEL";
         when Key_Checksum_Seed => return "CHECKSUM_SEED";
         when Key_Enable_Strict => return "ENABLE_STRICT";
         when Key_Buffer_Limit => return "BUFFER_LIMIT";
         when Key_Math_Mode => return "MATH_MODE";
         when Key_Reserved => return "RESERVED";
      end case;
   end Config_Key_To_String;
   function Is_Success_Status (S : Status_Code) return Boolean is
   begin
      return S = Success;
   end Is_Success_Status;
end Core_Types;
