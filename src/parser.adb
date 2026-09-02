with Core_Types; use Core_Types;
with Errors;
package body Parser is
   function Is_Whitespace (C : Character) return Boolean is
   begin return C = ' ' or C = ASCII.HT or C = ASCII.CR or C = ASCII.LF; end Is_Whitespace;
   function Is_Digit (C : Character) return Boolean is (C >= '0' and C <= '9');
   function Is_Alpha (C : Character) return Boolean is
   begin return (C >= 'A' and C <= 'Z') or (C >= 'a' and C <= 'z'); end Is_Alpha;
   function Is_Alnum (C : Character) return Boolean is (Is_Alpha (C) or Is_Digit (C));
   function Char_To_Byte (C : Character) return Byte is (Byte (Character'Pos (C)));
   function Byte_To_Char (B : Byte) return Character is
   begin if B > 127 then return '?'; else return Character'Val (Integer (B)); end if; end Byte_To_Char;
   function To_Upper (C : Character) return Character is
   begin if C >= 'a' and C <= 'z' then return Character'Val (Character'Pos (C) - 32); else return C; end if; end To_Upper;
   function Match_Command (Token : String) return Command_Id is
      Upper : String (Token'Range);
   begin
      for I in Token'Range loop Upper (I) := To_Upper (Token (I)); end loop;
      if Upper = "HELP" then return Cmd_Help;
      elsif Upper = "SET" or Upper = "SET_CONFIG" then return Cmd_Set_Config;
      elsif Upper = "PROCESS" or Upper = "PROCESS_DATA" then return Cmd_Process_Data;
      elsif Upper = "STATE" or Upper = "QUERY_STATE" then return Cmd_Query_State;
      elsif Upper = "SERIALIZE" then return Cmd_Serialize;
      elsif Upper = "VERIFY" then return Cmd_Verify;
      elsif Upper = "TEST" or Upper = "SELF_TEST" then return Cmd_Self_Test;
      elsif Upper = "RESET" then return Cmd_Reset;
      elsif Upper = "AUTH" or Upper = "AUTHORIZE" then return Cmd_Authorize;
      elsif Upper = "EXIT" or Upper = "QUIT" then return Cmd_Exit;
      else return Cmd_None;
      end if;
   end Match_Command;
   function Parse_Line (Line : String; Cmd : out Parsed_Command; Log : in out Errors.Error_Log) return Status_Code is
      I : Natural := Line'First; Start : Natural; Token_Len : Natural;
      Token : String (1 .. 32); Arg_Idx : Natural := 0; Val : Integer; Digit_Count : Natural;
   begin
      Cmd := (Id => Cmd_None, Arg_Count => 0, Args => (others => 0), Raw => (others => ' '));
      if Line'Length = 0 then return Success; end if;
      if Line'Length > Cmd.Raw'Length then
         Errors.Set_Error (Log, Buffer_Overflow, 0, "long"); return Buffer_Overflow;
      end if;
      for J in Line'Range loop
         if J - Line'First < Cmd.Raw'Length then Cmd.Raw (J - Line'First) := Line (J); end if;
      end loop;
      while I <= Line'Last and Is_Whitespace (Line (I)) loop I := I + 1; end loop;
      if I > Line'Last then return Success; end if;
      Start := I;
      while I <= Line'Last and not Is_Whitespace (Line (I)) loop I := I + 1; end loop;
      Token_Len := I - Start;
      if Token_Len = 0 or Token_Len > Token'Length then
         Errors.Set_Error (Log, Parse_Error, 0, "token"); return Parse_Error;
      end if;
      for K in 0 .. Token_Len - 1 loop Token (K + 1) := Line (Start + K); end loop;
      Cmd.Id := Match_Command (Token (1 .. Token_Len));
      if Cmd.Id = Cmd_None then
         Errors.Set_Error (Log, Parse_Error, 0, "unknown"); return Parse_Error;
      end if;
      while I <= Line'Last loop
         while I <= Line'Last and Is_Whitespace (Line (I)) loop I := I + 1; end loop;
         if I > Line'Last then exit; end if;
         if Arg_Idx >= Max_Command_Args then
            Errors.Set_Error (Log, Buffer_Overflow, 0, "args"); return Buffer_Overflow;
         end if;
         Val := 0; Digit_Count := 0;
         while I <= Line'Last and Is_Digit (Line (I)) loop
            Val := Val * 10 + (Character'Pos (Line (I)) - Character'Pos ('0'));
            if Val > 255 then Errors.Set_Error (Log, Out_Of_Range, 0, "arg"); return Out_Of_Range; end if;
            Digit_Count := Digit_Count + 1; I := I + 1;
         end loop;
         if Digit_Count = 0 then Errors.Set_Error (Log, Parse_Error, 0, "num"); return Parse_Error; end if;
         Cmd.Args (Arg_Idx) := Byte (Val); Arg_Idx := Arg_Idx + 1;
      end loop;
      Cmd.Arg_Count := Arg_Idx;
      return Success;
   end Parse_Line;
   function Command_Requires_Args (C : Command_Id) return Boolean is
   begin
      case C is
         when Cmd_Set_Config | Cmd_Process_Data | Cmd_Authorize => return True;
         when others => return False;
      end case;
   end Command_Requires_Args;
end Parser;
