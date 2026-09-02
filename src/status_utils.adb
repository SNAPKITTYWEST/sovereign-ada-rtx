package body Status_Utils is
   function Is_Success (S : Status_Code) return Boolean is (S = Success);
   function Is_Failure (S : Status_Code) return Boolean is (S /= Success);
   function Is_Integrity_Related (S : Status_Code) return Boolean is
   begin
      return S = Integrity_Failure or S = Serialization_Error;
   end Is_Integrity_Related;
   function Is_Input_Related (S : Status_Code) return Boolean is
   begin
      return S = Invalid_Input or S = Out_Of_Range or S = Parse_Error;
   end Is_Input_Related;
   function Severity_Level (S : Status_Code) return Natural is
   begin
      case S is
         when Success => return 0;
         when Invalid_Input | Out_Of_Range | Parse_Error => return 1;
         when Buffer_Overflow | Configuration_Error | Arithmetic_Overflow => return 2;
         when State_Error | Authorization_Denied => return 3;
         when Integrity_Failure | Serialization_Error => return 4;
         when Test_Failure => return 5;
      end case;
   end Severity_Level;
   function Can_Retry (S : Status_Code) return Boolean is
   begin
      return S = Buffer_Overflow or S = State_Error or S = Arithmetic_Overflow;
   end Can_Retry;
end Status_Utils;
