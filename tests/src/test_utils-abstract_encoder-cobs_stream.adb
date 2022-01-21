package body Test_Utils.Abstract_Encoder.COBS_Stream is

   -------------
   -- Receive --
   -------------

   overriding
   procedure Receive  (This : in out Instance; Data : Storage_Element)
   is
   begin
      This.Encoder.Push (Data);
   end Receive;

   ------------------
   -- End_Of_Frame --
   ------------------

   overriding
   procedure End_Of_Frame (This : in out Instance) is
   begin
      This.Encoder.End_Frame;

      for Elt of This.Encoder.Output loop
         This.Push_To_Frame (Elt);
      end loop;

      This.Encoder.Output.Clear;
   end End_Of_Frame;

   ------------
   -- Update --
   ------------

   overriding
   procedure Update (This : in out Instance) is
   begin
      null;
   end Update;

   -----------------
   -- End_Of_Test --
   -----------------

   overriding
   procedure End_Of_Test (This : in out Instance) is
   begin
      This.Save_Frame;
   end End_Of_Test;

   -----------
   -- Flush --
   -----------

   overriding
   procedure Flush (This : in out Test_Instance; Data : Storage_Array) is
   begin
      for Elt of Data loop
         This.Output.Append (Elt);
      end loop;
   end Flush;

end Test_Utils.Abstract_Encoder.COBS_Stream;
