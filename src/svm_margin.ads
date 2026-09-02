-- SVM Geometric Margin Maximization Specification.

package SVM_Margin is
   type Float_32 is digits 6;
   type Vector is array (Positive range <>) of Float_32;

   -- Maximize the geometric margin: y(w^T x + b) / ||w||
   procedure Optimize_Hyperplane (
      Features : in Vector;
      Label : in Float_32;
      Weights : in out Vector;
      Bias : in out Float_32;
      Learning_Rate : in Float_32;
      Lambda : in Float_32
   );
end SVM_Margin;
