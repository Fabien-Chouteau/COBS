with BBqueue;

package body Test_Utils.Abstract_Encoder.COBS_Queue is

   -------------
   -- Receive --
   -------------

   overriding
   procedure Receive (This : in out Instance; Data : Storage_Element)
   is
      Success : Boolean;
   begin
      COBS.Queue.Encoder.Push (This.Encoder, Data, Success);
      if not Success then
         raise Program_Error;
      end if;
   end Receive;

   ------------------
   -- End_Of_Frame --
   ------------------

   overriding
   procedure End_Of_Frame (This : in out Instance) is
      Success : Boolean;
   begin
      COBS.Queue.Encoder.End_Frame (This.Encoder, Success);
      if not Success then
         raise Program_Error;
      end if;

      This.Update;
   end End_Of_Frame;

   ------------
   -- Update --
   ------------

   overriding
   procedure Update (This : in out Instance) is
      use BBqueue;

      procedure Process_Read (Data : Storage_Array;
                              To_Release : out BBqueue.Count);

      ------------------
      -- Process_Read --
      ------------------

      procedure Process_Read (Data : Storage_Array;
                              To_Release : out BBqueue.Count)
      is
      begin
         for Elt of Data loop
            This.Current_Frame.Append (Elt);
         end loop;
         To_Release := Data'Length;
      end Process_Read;

      procedure Read_CB is new COBS.Queue.Encoder.Read_CB (Process_Read);

      Result : BBqueue.Result_Kind;
   begin

      loop
         Read_CB (This.Encoder, Result);
         exit when Result /= BBqueue.Valid;
      end loop;
   end Update;

   -----------------
   -- End_Of_Test --
   -----------------

   overriding
   procedure End_Of_Test (This : in out Instance) is
   begin
      This.Update;
      This.Save_Frame;
   end End_Of_Test;

end Test_Utils.Abstract_Encoder.COBS_Queue;
