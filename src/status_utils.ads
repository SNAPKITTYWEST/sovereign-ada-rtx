with Core_Types; use Core_Types;
package Status_Utils is
   function Is_Success (S : Status_Code) return Boolean;
   function Is_Failure (S : Status_Code) return Boolean;
   function Is_Integrity_Related (S : Status_Code) return Boolean;
   function Is_Input_Related (S : Status_Code) return Boolean;
   function Severity_Level (S : Status_Code) return Natural;
   function Can_Retry (S : Status_Code) return Boolean;
end Status_Utils;
