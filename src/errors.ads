with Core_Types; use Core_Types;
package Errors is
   type Error_Log is limited private;
   procedure Clear_Error (Log : in out Error_Log);
   procedure Set_Error (Log : in out Error_Log; Code : Status_Code; Hint : Medium_Natural := 0; Message : String := "");
   function Get_Code (Log : Error_Log) return Status_Code;
   function Get_Hint (Log : Error_Log) return Medium_Natural;
   function Has_Error (Log : Error_Log) return Boolean;
   function Get_Message (Log : Error_Log) return String;
   procedure Report_Error (Log : Error_Log);
   function Error_Is (Log : Error_Log; Code : Status_Code) return Boolean;
private
   type Error_Log is record
      Context : Error_Context;
      Active : Boolean := False;
   end record;
end Errors;
