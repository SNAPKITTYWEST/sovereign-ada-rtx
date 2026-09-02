with Core_Types; use Core_Types;
with Parser;
package Command_Utils is
   function Is_Query_Command (C : Command_Id) return Boolean;
   function Is_Mutating_Command (C : Command_Id) return Boolean;
   function Is_Auth_Command (C : Command_Id) return Boolean;
   function Expected_Arg_Count (C : Command_Id) return Natural;
   function Command_Help_Text (C : Command_Id) return String;
end Command_Utils;
