-- NOTES:
-- task<=>thread
-- access<=> pointer

with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Float_Random;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Float_Random;
procedure exercise7 is
   Count_Failed : exception; -- Exception to be raised when counting fails
   Gen : Generator; -- Random number generator
   protected type Transaction_Manager (N : Positive) is
      entry Finished;
      entry Wait_until_Aborted;
      procedure Signal_Abort;
   private
      Finished_Gate_Open : Boolean := False;
      Aborted : Boolean := False;
      Worker_Count : Integer := 0; 
   end Transaction_Manager;

   protected body Transaction_Manager is
      entry Finished when Finished_Gate_Open or Finished'Count = N is
      begin
         ------------------------------------------
         -- PART 3: Complete the exit protocol here
         ------------------------------------------
         --wait for all threads (tasks) to finish and make sure all votes are counted

         Put_Line("A thread is Finished: Threads blocked/remaining ="& Integer'Image(Finished'Count)
                  &"; Did a thread ABORT? :"&Boolean'Image(Aborted));

         --On first thread arrival/finish; OPEN GATE for remaining threads.
         if (Finished'Count=(N-1)) then
            Finished_Gate_Open:=True;
         end if;

         --On last thread arrival/finish; CLOSE gate for next "thread run"
         if Finished'Count = 0 then
            Finished_Gate_Open:=False;
         end if;
         
      end Finished;
      
      entry Wait_until_Aborted when Aborted is
      begin
         Worker_Count := Worker_Count + 1;
         if Worker_Count = N then
            Aborted := False;
            Worker_Count := 0;
         end if;
      end Wait_until_Aborted;

      procedure Signal_Abort is
      begin
         Aborted := True;
      end Signal_Abort;
            
   end Transaction_Manager;


   function Unreliable_Slow_Add (x : Integer) return Integer is
      Error_Rate : Constant := 0.15; -- (between 0 and 1)
      Random_Number : Float := 0.0;
   begin
      -------------------------------------------
      -- PART 1: Create the transaction work here
      -------------------------------------------
      Random_Number := Random(Gen);

      if Random_Number <= Error_Rate then
         delay Duration(Random_Number*0.5);
         raise Count_Failed;
      else
         delay Duration(random_number*4.0);
         return (10+x);
      end if;

   end Unreliable_Slow_Add;


   task type Transaction_Worker (Initial : Integer; Manager : access Transaction_Manager);
   task body Transaction_Worker is
      Num : Integer := Initial;
      Prev : Integer := Num;
      Round_Num : Integer := 0;
   begin
      Put_Line ("Worker" & Integer'Image(Initial) & " started");

      loop
         Put_Line ("Worker" & Integer'Image(Initial) & " started round" & Integer'Image(Round_Num));
         Round_Num := Round_Num + 1;
         ---------------------------------------
         -- PART 2: Do the transaction work here
         ---------------------------------------
         select
            Manager.Wait_Until_Aborted;
            Num:=Num+5;
            Put_Line (" Worker" & Integer'Image(Initial) & " comitting num + 5 =" & Integer'Image(Num));
            
         then abort   
            begin
               Num:=Unreliable_Slow_Add(Num);--'tis what we want??
            exception
               When Count_Failed =>
                     Put_Line( "Worker" & Integer'Image(Initial)&" told TM to abort!");
                     Manager.Signal_Abort;                     
            end;
            Manager.Finished;
            Put_Line (" Worker" & Integer'Image(Initial) & " comitting num + 10 =" & Integer'Image(Num));
         end select;

         delay 0.5;

      end loop;
   end Transaction_Worker;

   Manager : aliased Transaction_Manager (3);

   Worker_1 : Transaction_Worker (0, Manager'Access);
   Worker_2 : Transaction_Worker (1, Manager'Access);
   Worker_3 : Transaction_Worker (2, Manager'Access);

begin
   Reset(Gen); -- Seed the random number generator
end exercise7;
