--write a program to change the salary value to 20000 when it is less than 20000 for the given employee
	
declare 
	@eid int,@bsal int,@asal int
begin
	set @eid=101
	select @bsal=sal from emp1 where empid=@eid
	if(@bsal<20000)
		begin
			update emp1 set sal=20000 where empid=@eid
			print 'Salary value modified'
		end
	else
		begin
			set @asal=12*@bsal
			print 'Annual Salary : ' + cast(@asal as char)
		end
end

--write a program to get the sum of first 10 numbers

declare 
	@i int,@s int=0
begin
	set @i=1
	while @i<=10
		begin
			set @s=@s+@i
			set @i=@i+1
		end
	print 'The sum of first 10 numbers is : ' + cast(@s as char)
end

--display employee details along with salary grades
salary		grade
	
<30000		C

>=30000
&& <=40000	B

>40000		A

select empid,ename,sal,
case
	when sal<30000 then 'C'
	when sal between 30000 and 40000 then 'B'
	when sal>40000 then 'A'
end Grade
from emp