with Core_Types; use Core_Types;
with Memory_Structures;
with Math_Utils;
with Errors;
package body Integrity is
   function Compute_Item_Checksum (Item : Data_Item; Seed : Word16) return Word16 is
      Bytes : Byte_Array (0 .. 7); Tmp : Word32;
   begin
      Tmp := Word32 (Item.Id);
      Bytes (0) := Byte (Tmp mod 256); Bytes (1) := Byte ((Tmp / 256) mod 256);
      Tmp := Item.Value;
      Bytes (2) := Byte (Tmp mod 256); Bytes (3) := Byte ((Tmp / 256) mod 256);
      Bytes (4) := Byte ((Tmp / 65536) mod 256); Bytes (5) := Byte ((Tmp / 16777216) mod 256);
      Bytes (6) := Item.Flags; Bytes (7) := 0;
      return Math_Utils.Simple_Checksum (Bytes, Seed);
   end Compute_Item_Checksum;
   function Verify_Item (Item : Data_Item; Seed : Word16) return Status_Code is
   begin
      if not Item.Valid then return Invalid_Input; end if;
      if Compute_Item_Checksum (Item, Seed) /= Item.Checksum then return Integrity_Failure; end if;
      return Success;
   end Verify_Item;
   function Compute_Buffer_Checksum (Buf : Memory_Structures.Buffer; Seed : Word16) return Word16 is
      Len : Length_Type := Memory_Structures.Buffer_Length (Buf);
      Data : Byte_Array (0 .. Max_Buffer_Size - 1); St : Status_Code; Dummy : Byte;
   begin
      if Len = 0 then return Seed; end if;
      for I in 0 .. Len - 1 loop
         St := Memory_Structures.Get_Byte (Buf, I, Dummy);
         if St = Success then Data (I) := Dummy; else Data (I) := 0; end if;
      end loop;
      return Math_Utils.Simple_Checksum (Data (0 .. Len - 1), Seed);
   end Compute_Buffer_Checksum;
   function Verify_Buffer (Buf : Memory_Structures.Buffer; Expected : Word16; Seed : Word16) return Status_Code is
   begin
      if Compute_Buffer_Checksum (Buf, Seed) /= Expected then return Integrity_Failure; end if;
      return Success;
   end Verify_Buffer;
   function Compute_Header_Checksum (Hdr : Serial_Header) return Word16 is
      Bytes : Byte_Array (0 .. 7); Tmp : Word32;
   begin
      Tmp := Word32 (Hdr.Magic);
      Bytes (0) := Byte (Tmp mod 256); Bytes (1) := Byte ((Tmp / 256) mod 256);
      Bytes (2) := Hdr.Version; Bytes (3) := Byte (Hdr.Length);
      Bytes (4) := 0; Bytes (5) := 0;
      Bytes (6) := Byte (App_State'Pos (Hdr.State)); Bytes (7) := 0;
      return Math_Utils.Fletcher16 (Bytes);
   end Compute_Header_Checksum;
   function Verify_Header (Hdr : Serial_Header) return Status_Code is
   begin
      if Hdr.Magic /= 16#ADA1# then return Integrity_Failure; end if;
      if Compute_Header_Checksum (Hdr) /= Hdr.Checksum then return Integrity_Failure; end if;
      return Success;
   end Verify_Header;
   function Verify_Store_Integrity (Store : Memory_Structures.Data_Store; Seed : Word16; Log : in out Errors.Error_Log) return Status_Code is
      Count : Natural := Memory_Structures.Store_Count (Store);
      Item : Data_Item; St : Status_Code;
   begin
      for I in 0 .. Count - 1 loop
         St := Memory_Structures.Get_Item (Store, I, Item);
         if St /= Success then Errors.Set_Error (Log, St, Medium_Natural (I), "get"); return St; end if;
         St := Verify_Item (Item, Seed);
         if St /= Success then Errors.Set_Error (Log, St, Medium_Natural (I), "chk"); return St; end if;
      end loop;
      return Success;
   end Verify_Store_Integrity;
   function Is_Item_Integrity_Ok (Item : Data_Item; Seed : Word16) return Boolean is
   begin return Verify_Item (Item, Seed) = Success; end Is_Item_Integrity_Ok;
end Integrity;
