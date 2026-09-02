with Core_Types; use Core_Types;
with Errors;

package Self_Test is

   type Test_Result is record
      Name : Bounded_String := (others => ' ');
      Passed : Boolean := False;
      Code : Status_Code := Success;
   end record;

   Max_Tests : constant := 32;
   type Test_Results is array (0 .. Max_Tests - 1) of Test_Result;

   procedure Run_All_Tests
     (Results : out Test_Results;
      Count : out Natural;
      Overall : out Boolean);

   procedure Report_Results
     (Results : Test_Results;
      Count : Natural;
      Overall : Boolean);

end Self_Test;
