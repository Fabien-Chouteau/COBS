with COBS;

package body Test_Utils.Abstract_Decoder.COBS_Stream is

   -------------
   -- Receive --
   -------------

   overriding
   procedure Receive (This : in out Instance; Data : Storage_Element)
   is
   begin
      This.Decoder.Push (Data);
   end Receive;

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
      This.Frames := This.Decoder.Frames;
      This.Decoder.Frames.Clear;
      This.Decoder.Output.Clear;
   end End_Of_Test;

   -----------
   -- Flush --
   -----------

   overriding
   procedure Flush (This : in out Test_Decoder;
                    Data : Storage_Array)
   is
   begin
      for Elt of Data loop
         This.Output.Append (Elt);
      end loop;
   end Flush;

   ------------------
   -- End_Of_Frame --
   ------------------

   overriding
   procedure End_Of_Frame (This : in out Test_Decoder) is
   begin
      This.Frames.Append (This.Output);
      This.Output.Clear;
   end End_Of_Frame;

end Test_Utils.Abstract_Decoder.COBS_Stream;
