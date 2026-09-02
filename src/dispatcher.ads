with Core_Types; use Core_Types;
with Parser;
with Config;
with State_Machine;
with Memory_Structures;
with Errors;
with Serialization;
with Integrity;

package Dispatcher is

   type Context is limited private;

   procedure Init_Context (Ctx : in out Context);
   procedure Reset_Context (Ctx : in out Context);

   function Dispatch
     (Ctx : in out Context;
      Cmd : Parser.Parsed_Command;
      Log : in out Errors.Error_Log) return Status_Code;

   function Get_Current_State (Ctx : Context) return App_State;
   function Get_Config (Ctx : Context) return Config.Configuration;
   function Get_Store (Ctx : Context) return Memory_Structures.Data_Store;

private

   type Context is record
      SM : State_Machine.Machine;
      Cfg : Config.Configuration;
      Store : Memory_Structures.Data_Store;
      Buf : Memory_Structures.Buffer;
      Auth : Auth_Level := None;
      Seed : Word16 := 16#ADA1#;
   end record;

end Dispatcher;
