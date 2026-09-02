package body Memory_Structures is
   procedure Init_Buffer (Buf : in out Buffer) is
   begin
      Buf.Data := (others => 0); Buf.Length := 0;
   end Init_Buffer;
   procedure Clear_Buffer (Buf : in out Buffer) is
   begin
      Init_Buffer (Buf);
   end Clear_Buffer;
   function Buffer_Length (Buf : Buffer) return Length_Type is (Buf.Length);
   function Buffer_Capacity (Buf : Buffer) return Length_Type is (Max_Buffer_Size);
   function Is_Buffer_Full (Buf : Buffer) return Boolean is (Buf.Length >= Max_Buffer_Size);
   function Is_Buffer_Empty (Buf : Buffer) return Boolean is (Buf.Length = 0);
   function Append_Byte (Buf : in out Buffer; Value : Byte) return Status_Code is
   begin
      if Is_Buffer_Full (Buf) then return Buffer_Overflow; end if;
      Buf.Data (Buf.Length) := Value;
      Buf.Length := Buf.Length + 1;
      return Success;
   end Append_Byte;
   function Append_Bytes (Buf : in out Buffer; Data : Byte_Array) return Status_Code is
      Needed : Length_Type;
   begin
      if Data'Length = 0 then return Success; end if;
      Needed := Length_Type (Data'Length);
      if Buf.Length + Needed > Max_Buffer_Size then return Buffer_Overflow; end if;
      for I in Data'Range loop
         Buf.Data (Buf.Length) := Data (I);
         Buf.Length := Buf.Length + 1;
      end loop;
      return Success;
   end Append_Bytes;
   function Get_Byte (Buf : Buffer; Index : Index_Type; Value : out Byte) return Status_Code is
   begin
      if Index >= Buf.Length then Value := 0; return Out_Of_Range; end if;
      Value := Buf.Data (Index);
      return Success;
   end Get_Byte;
   function Get_Slice (Buf : Buffer; Start : Index_Type; Count : Length_Type; Result : out Byte_Array) return Status_Code is
      End_Idx : Index_Type;
   begin
      if Count = 0 then return Success; end if;
      if Start >= Buf.Length then return Out_Of_Range; end if;
      End_Idx := Start + Index_Type (Count) - 1;
      if End_Idx >= Buf.Length or Count > Result'Length then return Out_Of_Range; end if;
      for I in 0 .. Count - 1 loop
         Result (Result'First + I) := Buf.Data (Start + Index_Type (I));
      end loop;
      return Success;
   end Get_Slice;
   procedure Copy_Buffer (Src : Buffer; Dst : in out Buffer) is
   begin
      Dst.Data := Src.Data; Dst.Length := Src.Length;
   end Copy_Buffer;
   procedure Fill_Buffer (Buf : in out Buffer; Value : Byte; Count : Length_Type) is
      Limit : Length_Type;
   begin
      if Count = 0 then return; end if;
      Limit := Length_Type'Min (Count, Max_Buffer_Size);
      for I in 0 .. Limit - 1 loop
         Buf.Data (I) := Value;
      end loop;
      Buf.Length := Limit;
   end Fill_Buffer;
   procedure Zero_Buffer (Buf : in out Buffer) is
   begin
      Fill_Buffer (Buf, 0, Max_Buffer_Size);
      Buf.Length := 0;
   end Zero_Buffer;
   function Buffer_Equals (A, B : Buffer) return Boolean is
   begin
      if A.Length /= B.Length then return False; end if;
      for I in 0 .. A.Length - 1 loop
         if A.Data (I) /= B.Data (I) then return False; end if;
      end loop;
      return True;
   end Buffer_Equals;
   procedure Init_Store (Store : in out Data_Store) is
   begin
      Store.Items := (others => (Id => 0, Value => 0, Flags => 0, Checksum => 0, Valid => False));
      Store.Count := 0;
   end Init_Store;
   procedure Clear_Store (Store : in out Data_Store) is
   begin
      Init_Store (Store);
   end Clear_Store;
   function Store_Count (Store : Data_Store) return Natural is (Store.Count);
   function Store_Capacity (Store : Data_Store) return Natural is (Store.Items'Length);
   function Insert_Item (Store : in out Data_Store; Item : Data_Item) return Status_Code is
   begin
      if Store.Count >= Store.Items'Length then return Buffer_Overflow; end if;
      if not Item.Valid then return Invalid_Input; end if;
      Store.Items (Store.Count) := Item;
      Store.Count := Store.Count + 1;
      return Success;
   end Insert_Item;
   function Get_Item (Store : Data_Store; Index : Index_Type; Item : out Data_Item) return Status_Code is
   begin
      if Index >= Store.Count then
         Item := (Id => 0, Value => 0, Flags => 0, Checksum => 0, Valid => False);
         return Out_Of_Range;
      end if;
      Item := Store.Items (Index);
      return Success;
   end Get_Item;
   function Find_Item_By_Id (Store : Data_Store; Id : Word16; Item : out Data_Item; Found : out Boolean) return Status_Code is
   begin
      Found := False;
      Item := (Id => 0, Value => 0, Flags => 0, Checksum => 0, Valid => False);
      for I in 0 .. Store.Count - 1 loop
         if Store.Items (I).Valid and Store.Items (I).Id = Id then
            Item := Store.Items (I); Found := True; return Success;
         end if;
      end loop;
      return Success;
   end Find_Item_By_Id;
   function Update_Item (Store : in out Data_Store; Index : Index_Type; Item : Data_Item) return Status_Code is
   begin
      if Index >= Store.Count then return Out_Of_Range; end if;
      if not Item.Valid then return Invalid_Input; end if;
      Store.Items (Index) := Item;
      return Success;
   end Update_Item;
   function Remove_Item_By_Id (Store : in out Data_Store; Id : Word16) return Status_Code is
      Found_Idx : Natural := Store.Count;
   begin
      for I in 0 .. Store.Count - 1 loop
         if Store.Items (I).Valid and Store.Items (I).Id = Id then
            Found_Idx := I; exit;
         end if;
      end loop;
      if Found_Idx = Store.Count then return Invalid_Input; end if;
      for J in Found_Idx .. Store.Count - 2 loop
         Store.Items (J) := Store.Items (J + 1);
      end loop;
      Store.Items (Store.Count - 1) := (Id => 0, Value => 0, Flags => 0, Checksum => 0, Valid => False);
      Store.Count := Store.Count - 1;
      return Success;
   end Remove_Item_By_Id;
   function Store_Contains_Id (Store : Data_Store; Id : Word16) return Boolean is
      Item : Data_Item; Found : Boolean; St : Status_Code;
   begin
      St := Find_Item_By_Id (Store, Id, Item, Found);
      return Found;
   end Store_Contains_Id;
end Memory_Structures;
