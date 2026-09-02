with Core_Types; use Core_Types;
with Memory_Structures;
with Errors;
with Integrity;
package body Serialization is
   function Put_Word16 (Buf : in out Memory_Structures.Buffer; V : Word16) return Status_Code is
      St : Status_Code;
   begin
      St := Memory_Structures.Append_Byte (Buf, Byte (V mod 256));
      if St /= Success then return St; end if;
      return Memory_Structures.Append_Byte (Buf, Byte ((V / 256) mod 256));
   end Put_Word16;
   function Put_Word32 (Buf : in out Memory_Structures.Buffer; V : Word32) return Status_Code is
      St : Status_Code; T : Word32 := V;
   begin
      for I in 1 .. 4 loop
         St := Memory_Structures.Append_Byte (Buf, Byte (T mod 256));
         if St /= Success then return St; end if;
         T := T / 256;
      end loop;
      return Success;
   end Put_Word32;
   function Get_Word16 (Buf : Memory_Structures.Buffer; Offset : Index_Type; V : out Word16) return Status_Code is
      B0, B1 : Byte; St : Status_Code;
   begin
      St := Memory_Structures.Get_Byte (Buf, Offset, B0);
      if St /= Success then return St; end if;
      St := Memory_Structures.Get_Byte (Buf, Offset + 1, B1);
      if St /= Success then return St; end if;
      V := Word16 (B0) + Word16 (B1) * 256;
      return Success;
   end Get_Word16;
   function Get_Word32 (Buf : Memory_Structures.Buffer; Offset : Index_Type; V : out Word32) return Status_Code is
      B : Byte; St : Status_Code; Acc : Word32 := 0; Mult : Word32 := 1;
   begin
      for I in 0 .. 3 loop
         St := Memory_Structures.Get_Byte (Buf, Offset + Index_Type (I), B);
         if St /= Success then return St; end if;
         Acc := Acc + Word32 (B) * Mult;
         Mult := Mult * 256;
      end loop;
      V := Acc;
      return Success;
   end Get_Word32;
   function Serialize_Header (Hdr : Serial_Header; Buf : in out Memory_Structures.Buffer) return Status_Code is
      St : Status_Code; Local : Serial_Header := Hdr;
   begin
      Memory_Structures.Clear_Buffer (Buf);
      Local.Checksum := Integrity.Compute_Header_Checksum (Local);
      St := Put_Word16 (Buf, Local.Magic);
      if St /= Success then return St; end if;
      St := Memory_Structures.Append_Byte (Buf, Local.Version);
      if St /= Success then return St; end if;
      St := Memory_Structures.Append_Byte (Buf, Byte (Local.Length));
      if St /= Success then return St; end if;
      St := Put_Word16 (Buf, Local.Checksum);
      if St /= Success then return St; end if;
      return Memory_Structures.Append_Byte (Buf, Byte (App_State'Pos (Local.State)));
   end Serialize_Header;
   function Deserialize_Header (Buf : Memory_Structures.Buffer; Hdr : out Serial_Header) return Status_Code is
      St : Status_Code; B : Byte; Pos : Index_Type := 0;
   begin
      Hdr := (Magic => 0, Version => 0, Length => 0, Checksum => 0, State => Idle);
      if Memory_Structures.Buffer_Length (Buf) < 7 then return Parse_Error; end if;
      St := Get_Word16 (Buf, Pos, Hdr.Magic); if St /= Success then return St; end if;
      Pos := Pos + 2;
      St := Memory_Structures.Get_Byte (Buf, Pos, B); if St /= Success then return St; end if;
      Hdr.Version := B; Pos := Pos + 1;
      St := Memory_Structures.Get_Byte (Buf, Pos, B); if St /= Success then return St; end if;
      Hdr.Length := Length_Type (B); Pos := Pos + 1;
      St := Get_Word16 (Buf, Pos, Hdr.Checksum); if St /= Success then return St; end if;
      Pos := Pos + 2;
      St := Memory_Structures.Get_Byte (Buf, Pos, B); if St /= Success then return St; end if;
      if Integer (B) > App_State'Pos (App_State'Last) then return Parse_Error; end if;
      Hdr.State := App_State'Val (Integer (B));
      return Integrity.Verify_Header (Hdr);
   end Deserialize_Header;
   function Serialize_Item (Item : Data_Item; Buf : in out Memory_Structures.Buffer) return Status_Code is
      St : Status_Code;
   begin
      St := Put_Word16 (Buf, Item.Id); if St /= Success then return St; end if;
      St := Put_Word32 (Buf, Item.Value); if St /= Success then return St; end if;
      St := Memory_Structures.Append_Byte (Buf, Item.Flags); if St /= Success then return St; end if;
      St := Put_Word16 (Buf, Item.Checksum); if St /= Success then return St; end if;
      if Item.Valid then return Memory_Structures.Append_Byte (Buf, 1); else return Memory_Structures.Append_Byte (Buf, 0); end if;
   end Serialize_Item;
   function Deserialize_Item (Buf : Memory_Structures.Buffer; Offset : Index_Type; Item : out Data_Item; Next : out Index_Type) return Status_Code is
      St : Status_Code; B : Byte; Pos : Index_Type := Offset;
   begin
      Item := (Id => 0, Value => 0, Flags => 0, Checksum => 0, Valid => False);
      Next := Offset;
      St := Get_Word16 (Buf, Pos, Item.Id); if St /= Success then return St; end if; Pos := Pos + 2;
      St := Get_Word32 (Buf, Pos, Item.Value); if St /= Success then return St; end if; Pos := Pos + 4;
      St := Memory_Structures.Get_Byte (Buf, Pos, Item.Flags); if St /= Success then return St; end if; Pos := Pos + 1;
      St := Get_Word16 (Buf, Pos, Item.Checksum); if St /= Success then return St; end if; Pos := Pos + 2;
      St := Memory_Structures.Get_Byte (Buf, Pos, B); if St /= Success then return St; end if;
      Item.Valid := (B = 1); Next := Pos + 1;
      return Success;
   end Deserialize_Item;
   function Serialize_Store (Store : Memory_Structures.Data_Store; Buf : in out Memory_Structures.Buffer; Log : in out Errors.Error_Log) return Status_Code is
      Count : Natural := Memory_Structures.Store_Count (Store);
      Item : Data_Item; St : Status_Code; Hdr : Serial_Header;
   begin
      Memory_Structures.Clear_Buffer (Buf);
      Hdr := (Magic => 16#ADA1#, Version => 1, Length => Length_Type (Count), Checksum => 0, State => Processing);
      St := Serialize_Header (Hdr, Buf);
      if St /= Success then Errors.Set_Error (Log, St, 0, "header"); return St; end if;
      for I in 0 .. Count - 1 loop
         St := Memory_Structures.Get_Item (Store, I, Item);
         if St /= Success then Errors.Set_Error (Log, St, Medium_Natural (I), "get"); return St; end if;
         St := Serialize_Item (Item, Buf);
         if St /= Success then Errors.Set_Error (Log, St, Medium_Natural (I), "ser"); return St; end if;
      end loop;
      return Success;
   end Serialize_Store;
   function Deserialize_Store (Buf : Memory_Structures.Buffer; Store : in out Memory_Structures.Data_Store; Log : in out Errors.Error_Log) return Status_Code is
      Hdr : Serial_Header; St : Status_Code; Item : Data_Item; Pos : Index_Type := 7; Next : Index_Type; Count : Natural;
   begin
      Memory_Structures.Clear_Store (Store);
      St := Deserialize_Header (Buf, Hdr);
      if St /= Success then Errors.Set_Error (Log, St, 0, "hdr"); return St; end if;
      Count := Natural (Hdr.Length);
      if Count > Memory_Structures.Store_Capacity (Store) then
         Errors.Set_Error (Log, Buffer_Overflow, 0, "many"); return Buffer_Overflow;
      end if;
      for I in 1 .. Count loop
         St := Deserialize_Item (Buf, Pos, Item, Next);
         if St /= Success then Errors.Set_Error (Log, St, Medium_Natural (I), "item"); return St; end if;
         St := Memory_Structures.Insert_Item (Store, Item);
         if St /= Success then Errors.Set_Error (Log, St, Medium_Natural (I), "ins"); return St; end if;
         Pos := Next;
      end loop;
      return Success;
   end Deserialize_Store;
   function Header_Size return Length_Type is (7);
end Serialization;
