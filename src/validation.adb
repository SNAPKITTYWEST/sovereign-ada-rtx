with Core_Types; use Core_Types;
with Errors;
with Config;
package body Validation is
   function Validate_Buffer_Length (Len : Length_Type; Max : Length_Type) return Status_Code is
   begin if Len > Max then return Buffer_Overflow; end if; return Success; end Validate_Buffer_Length;
   function Validate_Byte_Range (V : Integer) return Status_Code is
   begin if V < 0 or else V > 255 then return Out_Of_Range; end if; return Success; end Validate_Byte_Range;
   function Validate_Word16_Range (V : Integer) return Status_Code is
   begin if V < 0 or else V > 65535 then return Out_Of_Range; end if; return Success; end Validate_Word16_Range;
   function Validate_Word32_Range (V : Long_Long_Integer) return Status_Code is
   begin if V < 0 or else V > Long_Long_Integer (Word32'Last) then return Out_Of_Range; end if; return Success; end Validate_Word32_Range;
   function Validate_Data_Item (Item : Data_Item) return Status_Code is
   begin if not Item.Valid or else Item.Id = 0 then return Invalid_Input; end if; return Success; end Validate_Data_Item;
   function Validate_Command_Args (Cmd : Command_Id; Args : Byte_Array; Cfg : Config.Configuration) return Status_Code is
      Max_Len : Length_Type := Config.Get_Max_Length (Cfg);
   begin
      if Args'Length > Natural (Max_Len) then return Buffer_Overflow; end if;
      case Cmd is
         when Cmd_None | Cmd_Help | Cmd_Query_State | Cmd_Self_Test | Cmd_Reset | Cmd_Exit =>
            if Args'Length > 0 then return Invalid_Input; end if;
         when Cmd_Set_Config => if Args'Length < 2 then return Invalid_Input; end if;
         when Cmd_Process_Data => if Args'Length = 0 then return Invalid_Input; end if;
         when Cmd_Serialize | Cmd_Verify => null;
         when Cmd_Authorize => if Args'Length < 1 then return Invalid_Input; end if;
      end case;
      return Success;
   end Validate_Command_Args;
   function Validate_State_Transition (From : App_State; To : App_State) return Status_Code is
   begin
      case From is
         when Idle => if To = Initializing or To = Shutdown or To = Error_State then return Success; end if;
         when Initializing => if To = Configured or To = Error_State then return Success; end if;
         when Configured => if To = Awaiting_Input or To = Error_State or To = Shutdown then return Success; end if;
         when Awaiting_Input => if To = Parsing or To = Error_State or To = Shutdown then return Success; end if;
         when Parsing => if To = Validating or To = Error_State then return Success; end if;
         when Validating => if To = Processing or To = Error_State then return Success; end if;
         when Processing => if To = Serializing or To = Checking_Integrity or To = Authorized or To = Awaiting_Input or To = Error_State then return Success; end if;
         when Serializing => if To = Checking_Integrity or To = Awaiting_Input or To = Error_State then return Success; end if;
         when Checking_Integrity => if To = Authorized or To = Awaiting_Input or To = Error_State then return Success; end if;
         when Authorized => if To = Awaiting_Input or To = Processing or To = Shutdown or To = Error_State then return Success; end if;
         when Error_State => if To = Idle or To = Shutdown or To = Awaiting_Input then return Success; end if;
         when Shutdown => return State_Error;
      end case;
      return State_Error;
   end Validate_State_Transition;
   function Validate_Serialized_Header (Hdr : Serial_Header) return Status_Code is
   begin
      if Hdr.Magic /= 16#ADA1# then return Integrity_Failure; end if;
      if Hdr.Version = 0 or Hdr.Version > 2 then return Invalid_Input; end if;
      if Hdr.Length > Max_Serial_Record_Size then return Buffer_Overflow; end if;
      return Success;
   end Validate_Serialized_Header;
   function Validate_Auth_Required (Level_Required : Auth_Level; Current : Auth_Level) return Status_Code is
   begin if Current < Level_Required then return Authorization_Denied; end if; return Success; end Validate_Auth_Required;
   procedure Validate_And_Set_Error (St : Status_Code; Log : in out Errors.Error_Log; Msg : String := "") is
   begin if St /= Success then Errors.Set_Error (Log, St, 0, Msg); end if; end Validate_And_Set_Error;
   function Is_Valid_Transition (From : App_State; To : App_State) return Boolean is
   begin return Validate_State_Transition (From, To) = Success; end Is_Valid_Transition;
end Validation;
