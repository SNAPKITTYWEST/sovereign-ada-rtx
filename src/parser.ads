with Core_Types; use Core_Types;
with Memory_Structures;
with Errors;

package Parser is

   type Parsed_Command is record
      Id : Command_Id := Cmd_None;
      Arg_Count : Natural := 0;
      Args : Byte_Array (0 .. Max_Command_Args - 1) := (others => 0);
      Raw : Bounded_String := (others => ' ');
   end record;

   function Parse_Line
     (Line : String;
      Cmd : out Parsed_Command;
      Log : in out Errors.Error_Log) return Status_Code;

   function Is_Whitespace (C : Character) return Boolean;
   function Is_Digit (C : Character) return Boolean;
   function Is_Alpha (C : Character) return Boolean;
   function Is_Alnum (C : Character) return Boolean;

   function Char_To_Byte (C : Character) return Byte;
   function Byte_To_Char (B : Byte) return Character;

end Parser;
