with Core_Types; use Core_Types;
with Math_Utils;
with Errors;

package RTX_Sovereign_Driver is
   pragma Pure;

   -- Enforce dimensionality invariants at compile time
   Max_Dimensions : constant := 256;
   subtype Tensor_Index is Natural range 0 .. Max_Dimensions - 1;

   -- Fixed-point tensor representation for deterministic air-gapped execution
   type Tensor_State is array (Tensor_Index) of Word32;

   procedure Initialize_Engine (
      Weights : out Tensor_State;
      Bias : out Word32
   );

   function Execute_Forward_Pass (
      Features : Tensor_State;
      Weights : Tensor_State;
      Bias : Word32;
      Log : in out Errors.Error_Log
   ) return Word32;

   -- Maximizes SVM geometric margin using deterministic safe math
   function Optimize_Margin (
      Features : Tensor_State;
      Label : Word32;
      Weights : in out Tensor_State;
      Bias : in out Word32;
      Log : in out Errors.Error_Log
   ) return Status_Code;
end RTX_Sovereign_Driver;
