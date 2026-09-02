package body Command_Utils is
   function Is_Query_Command (C : Command_Id) return Boolean is
   begin
      return C = Cmd_Help or C = Cmd_Query_State or C = Cmd_Verify or C = Cmd_Self_Test;
   end Is_Query_Command;
   function Is_Mutating_Command (C : Command_Id) return Boolean is
   begin
      return C = Cmd_Set_Config or C = Cmd_Process_Data or C = Cmd_Serialize or C = Cmd_Reset or C = Cmd_Authorize;
   end Is_Mutating_Command;
   function Is_Auth_Command (C : Command_Id) return Boolean is
   begin
      return C = Cmd_Authorize;
   end Is_Auth_Command;
   function Expected_Arg_Count (C : Command_Id) return Natural is
   begin
      case C is
         when Cmd_None | Cmd_Help | Cmd_Query_State | Cmd_Self_Test | Cmd_Reset | Cmd_Exit => return 0;
         when Cmd_Set_Config => return 2;
         when Cmd_Process_Data => return 1;
         when Cmd_Serialize | Cmd_Verify => return 0;
         when Cmd_Authorize => return 1;
      end case;
   end Expected_Arg_Count;
   function Command_Help_Text (C : Command_Id) return String is
   begin
      case C is
         when Cmd_None => return "No command";
         when Cmd_Help => return "Show available commands";
         when Cmd_Set_Config => return "SET <key> <value> - Set configuration";
         when Cmd_Process_Data => return "PROCESS <bytes...> - Process data";
         when Cmd_Query_State => return "STATE - Query current state";
         when Cmd_Serialize => return "SERIALIZE - Serialize store to buffer";
         when Cmd_Verify => return "VERIFY - Verify store integrity";
         when Cmd_Self_Test => return "TEST - Run self-test suite";
         when Cmd_Reset => return "RESET - Reset to idle";
         when Cmd_Authorize => return "AUTH <level> - Set auth level";
         when Cmd_Exit => return "EXIT - Shutdown";
      end case;
   end Command_Help_Text;
end Command_Utils;
