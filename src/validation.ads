with Core_Types; use Core_Types;
with Memory_Structures;
with Config;
with Errors;
package Validation is
   function Validate_Buffer_Length (Len : Length_Type; Max : Length_Type) return Status_Code;
   function Validate_Byte_Range (V : Integer) return Status_Code;
   function Validate_Word16_Range (V : Integer) return Status_Code;
   function Validate_Word32_Range (V : Long_Long_Integer) return Status_Code;
   function Validate_Data_Item (Item : Data_Item) return Status_Code;
   function Validate_Command_Args (Cmd : Command_Id; Args : Byte_Array; Cfg : Config.Configuration) return Status_Code;
   function Validate_State_Transition (From : App_State; To : App_State) return Status_Code;
   function Validate_Serialized_Header (Hdr : Serial_Header) return Status_Code;
   function Validate_Auth_Required (Level_Required : Auth_Level; Current : Auth_Level) return Status_Code;
   procedure Validate_And_Set_Error (St : Status_Code; Log : in out Errors.Error_Log; Msg : String := "");
   function Is_Valid_Transition (From : App_State; To : App_State) return Boolean;
end Validation;
