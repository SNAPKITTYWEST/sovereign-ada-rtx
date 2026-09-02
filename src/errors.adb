with Ada.Text_IO;
with Core_Types; use Core_Types;

package body Errors is

   procedure Clear_Error (Log : in out Error_Log) is
   begin
      Log.Context.Code := Success;
      Log.Context.Line_Hint := 0;
      Log.Context.Detail := (others => ' ');
      Log.Active := False;
   end Clear_Error;

   procedure Set_Error
     (Log : in out Error_Log;
      Code : Status_Code;
      Hint : Medium_Natural := 0;
      Message : String := "")
   is
      Len : Natural;
   begin
      Log.Context.Code := Code;
      Log.Context.Line_Hint := Hint;
      Log.Context.Detail := (others => ' ');
      if Message'Length > 0 then
         Len := Natural'Min (Message'Length, Log.Context.Detail'Length);
         for I in 0 .. Len - 1 loop
            Log.Context.Detail (I) := Message (Message'First + I);
         end loop;
      end if;
      Log.Active := True;
   end Set_Error;

   function Get_Code (Log : Error_Log) return Status_Code is
   begin
      return Log.Context.Code;
   end Get_Code;

   function Get_Hint (Log : Error_Log) return Medium_Natural is
   begin
      return Log.Context.Line_Hint;
   end Get_Hint;

   function Has_Error (Log : Error_Log) return Boolean is
   begin
      return Log.Active and then Log.Context.Code /= Success;
   end Has_Error;

   function Get_Message (Log : Error_Log) return String is
      Last : Natural := 0;
   begin
      for I in Log.Context.Detail'Range loop
         if Log.Context.Detail (I) /= ' ' then
            Last := I + 1;
         end if;
      end loop;
      if Last = 0 then
         return "";
      else
         return String (Log.Context.Detail (0 .. Last - 1));
      end if;
   end Get_Message;

   procedure Report_Error (Log : Error_Log) is
   begin
      if Has_Error (Log) then
         Ada.Text_IO.Put_Line
           ("ERROR: " & Status_To_String (Log.Context.Code) &
            " hint=" & Medium_Natural'Image (Log.Context.Line_Hint) &
            " msg=" & Get_Message (Log));
      else
         Ada.Text_IO.Put_Line ("NO_ERROR");
      end if;
   end Report_Error;

end Errors;
