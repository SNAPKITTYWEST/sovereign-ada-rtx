-- SVM Geometric Margin Maximization Body.

package body SVM_Margin is

   procedure Optimize_Hyperplane (
      Features : in Vector;
      Label : in Float_32;
      Weights : in out Vector;
      Bias : in out Float_32;
      Learning_Rate : in Float_32;
      Lambda : in Float_32
   ) is
      Dot_Product : Float_32 := 0.0;
      Margin_Test : Float_32;
   begin
      -- 1. Calculate the geometric projection: W^T * X
      for I in Features'Range loop
         Dot_Product := Dot_Product + (Weights(I) * Features(I));
      end loop;

      -- 2. Test the functional margin: y_i * (W^T * X_i + b)
      Margin_Test := Label * (Dot_Product + Bias);

      -- 3. Hinge Loss Gradient Update
      if Margin_Test >= 1.0 then
         -- Vector is outside the margin boundary.
         -- Apply weight decay (L2 regularization) to maximize geometric margin width.
         for I in Weights'Range loop
            Weights(I) := Weights(I) - Learning_Rate * (Lambda * Weights(I));
         end loop;
      else
         -- Vector violates the margin boundary (Support Vector).
         -- Adjust the hyperplane geometry toward the structural invariant.
         for I in Weights'Range loop
            Weights(I) := Weights(I) - Learning_Rate * (Lambda * Weights(I) - Label * Features(I));
         end loop;

         -- Mutate the bias threshold
         Bias := Bias - Learning_Rate * (-Label);
      end if;
   end Optimize_Hyperplane;

end SVM_Margin;
