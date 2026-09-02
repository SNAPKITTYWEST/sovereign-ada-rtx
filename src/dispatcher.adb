with Ada.Text_IO;
with Core_Types; use Core_Types;
with Parser;
with Config;
with State_Machine;
with Memory_Structures;
with Errors;
with Serialization;
with Integrity;
with Validation;
with Math_Utils;

package body Dispatcher is

   procedure Init_Context (Ctx : in out Context) is
   begin
      State_Machine.Init_Machine (Ctx.SM);
      Config.Init_Config (Ctx.Cfg);
      Config.Apply_Defaults (Ctx.Cfg);
      Memory_Structures.Init_Store (Ctx.Store);
      Memory_Structures.Init_Buffer (Ctx.Buf);
      Ctx.Auth := None;
      Ctx.Seed := Config.Get_Checksum_Seed (Ctx.Cfg);
   end Init_Context;

   procedure Reset_Context (Ctx : in out Context) is
   begin
      Init_Context (Ctx);
   end Reset_Context;

   function Get_Current_State (Ctx : Context) return App_State is
   begin
      return State_Machine.Get_State (Ctx.SM);
   end Get_Current_State;

   function Get_Config (Ctx : Context) return Config.Configuration is
   begin
      return Ctx.Cfg;
   end Get_Config;

   function Get_Store (Ctx : Context) return Memory_Structures.Data_Store is
   begin
      return Ctx.Store;
   end Get_Store;

   function Handle_Help (Log : in out Errors.Error_Log) return Status_Code is
   begin
      Ada.Text_IO.Put_Line ("Commands: HELP SET PROCESS STATE SERIALIZE VERIFY TEST RESET AUTH EXIT");
      return Success;
   end Handle_Help;

   function Handle_Set_Config (Ctx : in out Context; Cmd : Parser.Parsed_Command; Log : in out Errors.Error_Log) return Status_Code is
      St : Status_Code; Key : Config_Key; Val : Word32;
   begin
      if Cmd.Arg_Count < 2 then
         Errors.Set_Error (Log, Invalid_Input, 0, "SET needs key value"); return Invalid_Input;
      end if;
      if Cmd.Args (0) > 7 then
         Errors.Set_Error (Log, Out_Of_Range, 0, "bad key"); return Out_Of_Range;
      end if;
      Key := Config_Key'Val (Integer (Cmd.Args (0)));
      Val := Word32 (Cmd.Args (1));
      if Cmd.Arg_Count > 2 then Val := Val * 256 + Word32 (Cmd.Args (2)); end if;
      St := Config.Set_Value (Ctx.Cfg, Key, Val, Log);
      if St = Success then
         Ctx.Seed := Config.Get_Checksum_Seed (Ctx.Cfg);
         Ctx.Auth := Config.Get_Auth_Level (Ctx.Cfg);
         St := State_Machine.Transition (Ctx.SM, Configured, Log);
      end if;
      return St;
   end Handle_Set_Config;

   function Handle_Process (Ctx : in out Context; Cmd : Parser.Parsed_Command; Log : in out Errors.Error_Log) return Status_Code is
      St : Status_Code; Item : Data_Item; Val : Word32 := 0; Ov : Boolean;
   begin
      St := State_Machine.Transition (Ctx.SM, Processing, Log);
      if St /= Success then return St; end if;
      if Cmd.Arg_Count = 0 then
         Errors.Set_Error (Log, Invalid_Input, 0, "no data"); return Invalid_Input;
      end if;
      for I in 0 .. Cmd.Arg_Count - 1 loop
         Val := Math_Utils.Safe_Add (Val, Word32 (Cmd.Args (I)), Ov);
      end loop;
      Item := (Id => 1, Value => Val, Flags => Byte (Cmd.Arg_Count), Checksum => 0, Valid => True);
      Item.Checksum := Integrity.Compute_Item_Checksum (Item, Ctx.Seed);
      St := Memory_Structures.Insert_Item (Ctx.Store, Item);
      if St /= Success then Errors.Set_Error (Log, St, 0, "insert"); return St; end if;
      return State_Machine.Transition (Ctx.SM, Awaiting_Input, Log);
   end Handle_Process;

   function Handle_Query_State (Ctx : Context; Log : in out Errors.Error_Log) return Status_Code is
   begin
      Ada.Text_IO.Put_Line ("STATE=" & State_To_String (State_Machine.Get_State (Ctx.SM)));
      Ada.Text_IO.Put_Line ("AUTH=" & Auth_Level'Image (Ctx.Auth));
      Ada.Text_IO.Put_Line ("ITEMS=" & Natural'Image (Memory_Structures.Store_Count (Ctx.Store)));
      return Success;
   end Handle_Query_State;

   function Handle_Serialize (Ctx : in out Context; Log : in out Errors.Error_Log) return Status_Code is
      St : Status_Code;
   begin
      St := State_Machine.Transition (Ctx.SM, Serializing, Log);
      if St /= Success then return St; end if;
      St := Serialization.Serialize_Store (Ctx.Store, Ctx.Buf, Log);
      if St /= Success then return St; end if;
      Ada.Text_IO.Put_Line ("SERIALIZED_LEN=" & Length_Type'Image (Memory_Structures.Buffer_Length (Ctx.Buf)));
      return State_Machine.Transition (Ctx.SM, Awaiting_Input, Log);
   end Handle_Serialize;

   function Handle_Verify (Ctx : in out Context; Log : in out Errors.Error_Log) return Status_Code is
      St : Status_Code;
   begin
      St := State_Machine.Transition (Ctx.SM, Checking_Integrity, Log);
      if St /= Success then return St; end if;
      St := Integrity.Verify_Store_Integrity (Ctx.Store, Ctx.Seed, Log);
      if St = Success then Ada.Text_IO.Put_Line ("INTEGRITY=PASS");
      else Ada.Text_IO.Put_Line ("INTEGRITY=FAIL"); end if;
      return State_Machine.Transition (Ctx.SM, Awaiting_Input, Log);
   end Handle_Verify;

   function Handle_Authorize (Ctx : in out Context; Cmd : Parser.Parsed_Command; Log : in out Errors.Error_Log) return Status_Code is
      St : Status_Code; Lvl : Auth_Level;
   begin
      if Cmd.Arg_Count < 1 then
         Errors.Set_Error (Log, Invalid_Input, 0, "AUTH needs level"); return Invalid_Input;
      end if;
      case Cmd.Args (0) is
         when 0 => Lvl := None;
         when 1 => Lvl := Guest;
         when 2 => Lvl := Operator;
         when 3 => Lvl := Admin;
         when others => Errors.Set_Error (Log, Out_Of_Range, 0, "bad level"); return Out_Of_Range;
      end case;
      Ctx.Auth := Lvl;
      St := Config.Set_Value (Ctx.Cfg, Key_Auth_Level, Word32 (Cmd.Args (0)), Log);
      if St = Success then St := State_Machine.Transition (Ctx.SM, Authorized, Log); end if;
      return St;
   end Handle_Authorize;

   function Handle_Reset (Ctx : in out Context; Log : in out Errors.Error_Log) return Status_Code is
   begin
      Reset_Context (Ctx);
      return State_Machine.Transition (Ctx.SM, Idle, Log);
   end Handle_Reset;

   function Dispatch (Ctx : in out Context; Cmd : Parser.Parsed_Command; Log : in out Errors.Error_Log) return Status_Code is
      St : Status_Code;
   begin
      case Cmd.Id is
         when Cmd_None => return Success;
         when Cmd_Help => return Handle_Help (Log);
         when Cmd_Set_Config =>
            St := Validation.Validate_Auth_Required (Operator, Ctx.Auth);
            if St /= Success then Errors.Set_Error (Log, St, 0, "auth"); return St; end if;
            return Handle_Set_Config (Ctx, Cmd, Log);
         when Cmd_Process_Data => return Handle_Process (Ctx, Cmd, Log);
         when Cmd_Query_State => return Handle_Query_State (Ctx, Log);
         when Cmd_Serialize => return Handle_Serialize (Ctx, Log);
         when Cmd_Verify => return Handle_Verify (Ctx, Log);
         when Cmd_Self_Test => return Success;
         when Cmd_Reset => return Handle_Reset (Ctx, Log);
         when Cmd_Authorize => return Handle_Authorize (Ctx, Cmd, Log);
         when Cmd_Exit => return State_Machine.Transition (Ctx.SM, Shutdown, Log);
      end case;
   end Dispatch;

end Dispatcher;
