with Core_Types; use Core_Types;
with Errors;

package Config is

   type Configuration is limited private;

   procedure Init_Config (Cfg : in out Configuration);
   procedure Reset_Config (Cfg : in out Configuration);

   function Set_Value
     (Cfg : in out Configuration;
      Key : Config_Key;
      Value : Word32;
      Log : in out Errors.Error_Log) return Status_Code;

   function Get_Value
     (Cfg : Configuration;
      Key : Config_Key;
      Value : out Word32) return Status_Code;

   function Is_Set (Cfg : Configuration; Key : Config_Key) return Boolean;
   function Get_Auth_Level (Cfg : Configuration) return Auth_Level;
   function Get_Max_Length (Cfg : Configuration) return Length_Type;
   function Get_Checksum_Seed (Cfg : Configuration) return Word16;
   function Is_Strict (Cfg : Configuration) return Boolean;

   procedure Apply_Defaults (Cfg : in out Configuration);

private

   type Configuration is record
      Table : Config_Table := (others => (Key => Key_Reserved, Value => 0, Set => False));
      Level : Auth_Level := None;
   end record;

end Config;
