with Ada.Text_IO;
with Core_Types; use Core_Types;
with Errors;
with Math_Utils;
with Memory_Structures;
with Config;
with Validation;
with Integrity;
with Serialization;
with Parser;
with State_Machine;
with Dispatcher;

package body Self_Test is

   procedure Set_Name (R : in out Test_Result; S : String) is
      Len : Natural := Natural'Min (S'Length, R.Name'Length);
   begin
      R.Name := (others => ' ');
      for I in 0 .. Len - 1 loop
         R.Name (I) := S (S'First + I);
      end loop;
   end Set_Name;

   procedure Run_All_Tests
     (Results : out Test_Results;
      Count : out Natural;
      Overall : out Boolean)
   is
      Idx : Natural := 0;
      Log : Errors.Error_Log;
      St : Status_Code;
      Ov : Boolean;
      Buf : Memory_Structures.Buffer;
      Store : Memory_Structures.Data_Store;
      Item : Data_Item;
      Cfg : Config.Configuration;
      Hdr : Serial_Header;
      Cmd : Parser.Parsed_Command;
      SM : State_Machine.Machine;
      Ctx : Dispatcher.Context;
      W : Word32;
      W16 : Word16;
   begin
      Results := (others => (Name => (others => ' '), Passed => False, Code => Success));
      Overall := True;

      Set_Name (Results (Idx), "Safe_Add_Normal");
      W := Math_Utils.Safe_Add (10, 20, Ov);
      Results (Idx).Passed := (not Ov) and then (W = 30);
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Safe_Add_Overflow");
      W := Math_Utils.Safe_Add (Word32'Last, 1, Ov);
      Results (Idx).Passed := Ov;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Safe_Sub_Under");
      W := Math_Utils.Safe_Sub (5, 10, Ov);
      Results (Idx).Passed := Ov and then (W = 0);
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "ISqrt");
      Results (Idx).Passed := Math_Utils.ISqrt (100) = 10;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Power2");
      Results (Idx).Passed := Math_Utils.Is_Power_Of_Two (16) and not Math_Utils.Is_Power_Of_Two (15);
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Buffer_Ops");
      Memory_Structures.Init_Buffer (Buf);
      St := Memory_Structures.Append_Byte (Buf, 42);
      Results (Idx).Passed := St = Success and Memory_Structures.Buffer_Length (Buf) = 1;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Buffer_Full");
      Memory_Structures.Init_Buffer (Buf);
      for I in 1 .. Max_Buffer_Size loop
         St := Memory_Structures.Append_Byte (Buf, 1);
      end loop;
      St := Memory_Structures.Append_Byte (Buf, 0);
      Results (Idx).Passed := St = Buffer_Overflow;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Store_Insert");
      Memory_Structures.Init_Store (Store);
      Item := (Id => 100, Value => 999, Flags => 1, Checksum => 0, Valid => True);
      Item.Checksum := Integrity.Compute_Item_Checksum (Item, 16#ADA1#);
      St := Memory_Structures.Insert_Item (Store, Item);
      declare
         Found : Boolean; FI : Data_Item;
      begin
         St := Memory_Structures.Find_Item_By_Id (Store, 100, FI, Found);
         Results (Idx).Passed := Found and FI.Value = 999;
      end;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Invalid_Item");
      Item.Valid := False;
      St := Memory_Structures.Insert_Item (Store, Item);
      Results (Idx).Passed := St = Invalid_Input;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Header_Ser");
      Hdr := (Magic => 16#ADA1#, Version => 1, Length => 0, Checksum => 0, State => Idle);
      Memory_Structures.Init_Buffer (Buf);
      St := Serialization.Serialize_Header (Hdr, Buf);
      Results (Idx).Passed := St = Success and Memory_Structures.Buffer_Length (Buf) = 7;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Header_De");
      declare
         Hdr2 : Serial_Header;
      begin
         St := Serialization.Deserialize_Header (Buf, Hdr2);
         Results (Idx).Passed := St = Success and Hdr2.Magic = 16#ADA1#;
      end;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Item_Ser");
      Item := (Id => 16#ABCD#, Value => 12345, Flags => 7, Checksum => 0, Valid => True);
      Item.Checksum := Integrity.Compute_Item_Checksum (Item, 16#ADA1#);
      Memory_Structures.Init_Buffer (Buf);
      St := Serialization.Serialize_Item (Item, Buf);
      Results (Idx).Passed := St = Success;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Item_De");
      declare
         Item2 : Data_Item; Next : Index_Type;
      begin
         St := Serialization.Deserialize_Item (Buf, 0, Item2, Next);
         Results (Idx).Passed := St = Success and Item2.Id = 16#ABCD# and Item2.Value = 12345;
      end;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Integrity");
      Item := (Id => 42, Value => 9999, Flags => 3, Checksum => 0, Valid => True);
      Item.Checksum := Integrity.Compute_Item_Checksum (Item, 16#ADA1#);
      St := Integrity.Verify_Item (Item, 16#ADA1#);
      Results (Idx).Passed := St = Success;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Integrity_Fail");
      Item.Checksum := Item.Checksum + 1;
      St := Integrity.Verify_Item (Item, 16#ADA1#);
      Results (Idx).Passed := St = Integrity_Failure;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "State_Trans");
      State_Machine.Init_Machine (SM);
      St := State_Machine.Transition (SM, Initializing, Log);
      Results (Idx).Passed := St = Success;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "State_Invalid");
      St := State_Machine.Transition (SM, Serializing, Log);
      Results (Idx).Passed := St = State_Error;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Config_Set");
      Config.Init_Config (Cfg);
      St := Config.Set_Value (Cfg, Key_Max_Length, 32, Log);
      Results (Idx).Passed := St = Success and Config.Get_Max_Length (Cfg) = 32;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Config_Bad");
      St := Config.Set_Value (Cfg, Key_Max_Length, 999, Log);
      Results (Idx).Passed := St = Out_Of_Range;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Dispatch");
      Dispatcher.Init_Context (Ctx);
      St := Dispatcher.Get_Current_State (Ctx)'Pos = Idle'Pos;
      Results (Idx).Passed := St = Success;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Parse_Help");
      St := Parser.Parse_Line ("HELP", Cmd, Log);
      Results (Idx).Passed := St = Success and Cmd.Id = Cmd_Help;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Parse_Bad");
      St := Parser.Parse_Line ("NOCMD", Cmd, Log);
      Results (Idx).Passed := St = Parse_Error;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Validate_Buf");
      St := Validation.Validate_Buffer_Length (100, 64);
      Results (Idx).Passed := St = Buffer_Overflow;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Validate_Item");
      Item := (Id => 0, Value => 0, Flags => 0, Checksum => 0, Valid => False);
      St := Validation.Validate_Data_Item (Item);
      Results (Idx).Passed := St = Invalid_Input;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Auth_Deny");
      St := Validation.Validate_Auth_Required (Admin, Guest);
      Results (Idx).Passed := St = Authorization_Denied;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Auth_Ok");
      St := Validation.Validate_Auth_Required (Operator, Admin);
      Results (Idx).Passed := St = Success;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Store_Ser");
      Memory_Structures.Init_Store (Store);
      for I in 1 .. 5 loop
         Item := (Id => Word16 (I), Value => Word32 (I * 100), Flags => 0, Checksum => 0, Valid => True);
         Item.Checksum := Integrity.Compute_Item_Checksum (Item, 16#ADA1#);
         St := Memory_Structures.Insert_Item (Store, Item);
      end loop;
      Memory_Structures.Init_Buffer (Buf);
      St := Serialization.Serialize_Store (Store, Buf, Log);
      Results (Idx).Passed := St = Success;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Store_De");
      declare
         Store2 : Memory_Structures.Data_Store;
      begin
         St := Serialization.Deserialize_Store (Buf, Store2, Log);
         Results (Idx).Passed := St = Success and Memory_Structures.Store_Count (Store2) = 5;
      end;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Rotate");
      W16 := Math_Utils.Rotate_Left (16#0001#, 4);
      Results (Idx).Passed := W16 = 16#0010#;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Count := Idx;
   end Run_All_Tests;

   procedure Report_Results
     (Results : Test_Results;
      Count : Natural;
      Overall : Boolean)
   is
      Name_Str : String (1 .. 64); Name_Len : Natural;
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("=== SOVEREIGN ADA RTX SELF TEST ===");
      Ada.Text_IO.Put_Line ("Tests: " & Natural'Image (Count));
      for I in 0 .. Count - 1 loop
         Name_Len := 0;
         for J in Results (I).Name'Range loop
            if Results (I).Name (J) /= ' ' then
               Name_Len := J + 1;
            end if;
         end loop;
         if Name_Len > 0 then
            Name_Str := (others => ' ');
            for J in 0 .. Name_Len - 1 loop
               Name_Str (J + 1) := Results (I).Name (J);
            end loop;
            if Results (I).Passed then
               Ada.Text_IO.Put_Line ("  [PASS] " & Name_Str (1 .. Name_Len));
            else
               Ada.Text_IO.Put_Line ("  [FAIL] " & Name_Str (1 .. Name_Len));
            end if;
         end if;
      end loop;
      Ada.Text_IO.New_Line;
      if Overall then
         Ada.Text_IO.Put_Line ("RESULT: ALL TESTS PASSED");
      else
         Ada.Text_IO.Put_Line ("RESULT: SOME TESTS FAILED");
      end if;
   end Report_Results;

end Self_Test;
