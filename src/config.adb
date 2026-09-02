with Core_Types; use Core_Types;
with Errors;

package body Config is

   procedure Init_Config (Cfg : in out Configuration) is
   begin
      Cfg.Table := (others => (Key => Key_Reserved, Value => 0, Set => False));
      Cfg.Level := None;
   end Init_Config;

   procedure Reset_Config (Cfg : in out Configuration) is
   begin
      Init_Config (Cfg);
   end Reset_Config;

   function Validate_Value (Key : Config_Key; Value : Word32) return Boolean is
   begin
      case Key is
         when Key_Max_Length => return Value >= 1 and Value <= Word32 (Max_Buffer_Size);
         when Key_Timeout => return Value <= 10000;
         when Key_Auth_Level => return Value <= 3;
         when Key_Checksum_Seed => return Value <= 65535;
         when Key_Enable_Strict => return Value = 0 or Value = 1;
         when Key_Buffer_Limit => return Value >= 8 and Value <= Word32 (Max_Buffer_Size);
         when Key_Math_Mode => return Value <= 2;
         when Key_Reserved => return False;
      end case;
   end Validate_Value;

   function Set_Value (Cfg : in out Configuration; Key : Config_Key; Value : Word32; Log : in out Errors.Error_Log) return Status_Code is
      Idx : Natural;
   begin
      if Key = Key_Reserved then
         Errors.Set_Error (Log, Configuration_Error, 0, "reserved"); return Configuration_Error;
      end if;
      if not Validate_Value (Key, Value) then
         Errors.Set_Error (Log, Out_Of_Range, 0, "range"); return Out_Of_Range;
      end if;
      Idx := Max_Config_Entries;
      for I in Cfg.Table'Range loop
         if Cfg.Table (I).Set and Cfg.Table (I).Key = Key then Idx := I; exit;
         elsif not Cfg.Table (I).Set and Idx = Max_Config_Entries then Idx := I;
         end if;
      end loop;
      if Idx = Max_Config_Entries then
         Errors.Set_Error (Log, Buffer_Overflow, 0, "full"); return Buffer_Overflow;
      end if;
      Cfg.Table (Idx) := (Key => Key, Value => Value, Set => True);
      if Key = Key_Auth_Level then
         case Value is
            when 0 => Cfg.Level := None;
            when 1 => Cfg.Level := Guest;
            when 2 => Cfg.Level := Operator;
            when 3 => Cfg.Level := Admin;
            when others => Cfg.Level := None;
         end case;
      end if;
      return Success;
   end Set_Value;

   function Get_Value (Cfg : Configuration; Key : Config_Key; Value : out Word32) return Status_Code is
   begin
      Value := 0;
      for I in Cfg.Table'Range loop
         if Cfg.Table (I).Set and Cfg.Table (I).Key = Key then
            Value := Cfg.Table (I).Value; return Success;
         end if;
      end loop;
      return Configuration_Error;
   end Get_Value;

   function Is_Set (Cfg : Configuration; Key : Config_Key) return Boolean is
   begin
      for I in Cfg.Table'Range loop
         if Cfg.Table (I).Set and Cfg.Table (I).Key = Key then return True; end if;
      end loop;
      return False;
   end Is_Set;

   function Get_Auth_Level (Cfg : Configuration) return Auth_Level is (Cfg.Level);

   function Get_Max_Length (Cfg : Configuration) return Length_Type is
      V : Word32; St : Status_Code;
   begin
      St := Get_Value (Cfg, Key_Max_Length, V);
      if St = Success then return Length_Type (V); else return 64; end if;
   end Get_Max_Length;

   function Get_Checksum_Seed (Cfg : Configuration) return Word16 is
      V : Word32; St : Status_Code;
   begin
      St := Get_Value (Cfg, Key_Checksum_Seed, V);
      if St = Success then return Word16 (V); else return 16#ADA1#; end if;
   end Get_Checksum_Seed;

   function Is_Strict (Cfg : Configuration) return Boolean is
      V : Word32; St : Status_Code;
   begin
      St := Get_Value (Cfg, Key_Enable_Strict, V);
      return St = Success and V = 1;
   end Is_Strict;

   procedure Apply_Defaults (Cfg : in out Configuration) is
      Dummy : Errors.Error_Log; St : Status_Code;
   begin
      Errors.Clear_Error (Dummy);
      St := Set_Value (Cfg, Key_Max_Length, 64, Dummy);
      St := Set_Value (Cfg, Key_Timeout, 1000, Dummy);
      St := Set_Value (Cfg, Key_Auth_Level, 0, Dummy);
      St := Set_Value (Cfg, Key_Checksum_Seed, 16#ADA1#, Dummy);
      St := Set_Value (Cfg, Key_Enable_Strict, 1, Dummy);
      St := Set_Value (Cfg, Key_Buffer_Limit, 128, Dummy);
      St := Set_Value (Cfg, Key_Math_Mode, 0, Dummy);
   end Apply_Defaults;

end Config;
