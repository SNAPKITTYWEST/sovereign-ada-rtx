package Core_Types is

   pragma Pure;

   subtype Byte is Integer range 0 .. 255;
   subtype Word16 is Integer range 0 .. 65535;
   subtype Word32 is Integer range 0 .. 2**31 - 1;
   subtype Small_Natural is Natural range 0 .. 1023;
   subtype Medium_Natural is Natural range 0 .. 65535;
   subtype Index_Type is Natural range 0 .. 511;
   subtype Length_Type is Natural range 0 .. 256;

   type Status_Code is (
      Success,
      Invalid_Input,
      Out_Of_Range,
      Buffer_Overflow,
      State_Error,
      Integrity_Failure,
      Parse_Error,
      Authorization_Denied,
      Configuration_Error,
      Arithmetic_Overflow,
      Serialization_Error,
      Test_Failure
   );

   type App_State is (
      Idle,
      Initializing,
      Configured,
      Awaiting_Input,
      Parsing,
      Validating,
      Processing,
      Serializing,
      Checking_Integrity,
      Authorized,
      Error_State,
      Shutdown
   );

   type Command_Id is (
      Cmd_None,
      Cmd_Help,
      Cmd_Set_Config,
      Cmd_Process_Data,
      Cmd_Query_State,
      Cmd_Serialize,
      Cmd_Verify,
      Cmd_Self_Test,
      Cmd_Reset,
      Cmd_Authorize,
      Cmd_Exit
   );

   Max_Buffer_Size : constant := 128;
   Max_Config_Entries : constant := 16;
   Max_Command_Args : constant := 8;
   Max_Serial_Record_Size : constant := 64;

   type Byte_Array is array (Index_Type range <>) of Byte;
   subtype Fixed_Buffer is Byte_Array (0 .. Max_Buffer_Size - 1);

   type Char_Array is array (Index_Type range <>) of Character;
   subtype Bounded_String is Char_Array (0 .. 63);

   type Data_Item is record
      Id : Word16 := 0;
      Value : Word32 := 0;
      Flags : Byte := 0;
      Checksum : Word16 := 0;
      Valid : Boolean := False;
   end record;

   type Data_Item_Array is array (Index_Type range <>) of Data_Item;
   subtype Fixed_Data_Store is Data_Item_Array (0 .. 31);

   type Config_Key is (
      Key_Max_Length,
      Key_Timeout,
      Key_Auth_Level,
      Key_Checksum_Seed,
      Key_Enable_Strict,
      Key_Buffer_Limit,
      Key_Math_Mode,
      Key_Reserved
   );

   type Config_Entry is record
      Key : Config_Key := Key_Reserved;
      Value : Word32 := 0;
      Set : Boolean := False;
   end record;

   type Config_Table is array (0 .. Max_Config_Entries - 1) of Config_Entry;

   type Serial_Header is record
      Magic : Word16 := 16#ADA1#;
      Version : Byte := 1;
      Length : Length_Type := 0;
      Checksum : Word16 := 0;
      State : App_State := Idle;
   end record;

   type Error_Context is record
      Code : Status_Code := Success;
      Line_Hint : Medium_Natural := 0;
      Detail : Bounded_String := (others => ' ');
   end record;

   type Auth_Level is (None, Guest, Operator, Admin);

   function Status_To_String (S : Status_Code) return String;
   function State_To_String (S : App_State) return String;
   function Command_To_String (C : Command_Id) return String;

end Core_Types;
